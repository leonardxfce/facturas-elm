port module Update exposing (update)

import Json.Encode as Encode
import Messages exposing (..)
import Persistence exposing (..)
import Ports exposing (downloadFile, triggerPrint)
import Types exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ExportarAPDF ->
            ( model, triggerPrint () )

        ExportarCSV ->
            ( model, downloadFile { name = "datos.csv", content = modelToCsv model } )

        InputBusqueda busqueda ->
            ( { model | busquedaProducto = busqueda }, Cmd.none )

        InputNombreProducto nombre ->
            ( { model | nuevoProductoNombre = nombre }, Cmd.none )

        InputPrecioProducto precio ->
            ( { model | nuevoProductoPrecio = precio }, Cmd.none )

        AgregarProducto ->
            let
                precio =
                    String.toFloat model.nuevoProductoPrecio |> Maybe.withDefault 0.0

                nombre =
                    String.trim model.nuevoProductoNombre
            in
            if nombre == "" || precio <= 0 then
                ( model, Cmd.none )

            else
                case model.productoEditando of
                    Just id ->
                        let
                            actualizar p =
                                if p.id == id then
                                    { p | nombre = nombre, precio = precio }

                                else
                                    p

                            nuevoModel =
                                { model | catalogo = List.map actualizar model.catalogo, productoEditando = Nothing, nuevoProductoNombre = "", nuevoProductoPrecio = "" }
                        in
                        ( nuevoModel, saveStorage (encodeModel nuevoModel) )

                    Nothing ->
                        let
                            nuevoProducto =
                                { id = model.nextProductoId, nombre = nombre, precio = precio }

                            nuevoModel =
                                { model | catalogo = model.catalogo ++ [ nuevoProducto ], nextProductoId = model.nextProductoId + 1, nuevoProductoNombre = "", nuevoProductoPrecio = "" }
                        in
                        ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        EliminarProducto id ->
            let
                nuevoModel =
                    { model | catalogo = List.filter (\p -> p.id /= id) model.catalogo }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        EditarProducto id ->
            case List.filter (\p -> p.id == id) model.catalogo |> List.head of
                Just p ->
                    ( { model | nuevoProductoNombre = p.nombre, nuevoProductoPrecio = String.fromFloat p.precio, productoEditando = Just id }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        AgregarPedido ->
            let
                nuevoPedido =
                    { id = model.nextPedidoId, items = [], estado = Borrador }

                nuevoModel =
                    { model | pedidos = model.pedidos ++ [ nuevoPedido ], nextPedidoId = model.nextPedidoId + 1 }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        EliminarPedido id ->
            let
                nuevoModel =
                    { model | pedidos = List.filter (\p -> p.id /= id) model.pedidos }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        AgregarItemAPedido pedidoId productoId ->
            let
                actualizarPedido p =
                    if p.id == pedidoId then
                        { p | items = p.items ++ [ { productoId = productoId, cantidad = 1 } ] }

                    else
                        p

                nuevoModel =
                    { model | pedidos = List.map actualizarPedido model.pedidos }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        IrAInicio ->
            ( { model | paginaActual = Inicio, busquedaProducto = "" }, Cmd.none )

        IrAGestionProductos ->
            ( { model | paginaActual = GestionProductos }, Cmd.none )

        IrAListadoPedidos ->
            ( { model | paginaActual = ListadoPedidos, busquedaProducto = "" }, Cmd.none )

        IrAEditarPedido id ->
            ( { model | paginaActual = EditandoPedido id, busquedaProducto = "" }, Cmd.none )


port saveStorage : Encode.Value -> Cmd msg
