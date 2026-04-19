port module Update exposing (update)

import Browser
import Browser.Navigation as Nav
import Json.Encode as Encode
import Messages exposing (Msg(..))
import Persistence exposing (encodeModel)
import Ports exposing (downloadFile, selectFile, triggerPrint)
import Types exposing (Model, Pagina(..), estadoToString)
import Update.Pedidos as UpdatePedidos
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, s)



-- ROUTING HELPERS


routeParser : Parser (Pagina -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Inicio Parser.top
        , Parser.map GestionProductos (s "productos")
        , Parser.map ListadoPedidos (s "pedidos")
        , Parser.map EditandoPedido (s "pedidos" </> int)
        ]


urlToPage : Url -> Pagina
urlToPage url =
    Parser.parse routeParser url |> Maybe.withDefault Inicio



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url, paginaActual = urlToPage url, busquedaProducto = "" }, Cmd.none )

        InputNombreProducto val ->
            ( { model | nuevoProductoNombre = val }, Cmd.none )

        InputPrecioProducto val ->
            ( { model | nuevoProductoPrecio = val }, Cmd.none )

        InputBusqueda val ->
            ( { model | busquedaProducto = val }, Cmd.none )

        AgregarProducto ->
            let
                nuevoProducto =
                    case model.productoEditando of
                        Just id ->
                            { id = id, nombre = model.nuevoProductoNombre, precio = String.toFloat model.nuevoProductoPrecio |> Maybe.withDefault 0.0 }

                        Nothing ->
                            { id = model.nextProductoId, nombre = model.nuevoProductoNombre, precio = String.toFloat model.nuevoProductoPrecio |> Maybe.withDefault 0.0 }

                nuevoCatalogo =
                    case model.productoEditando of
                        Just id ->
                            List.map
                                (\p ->
                                    if p.id == id then
                                        nuevoProducto

                                    else
                                        p
                                )
                                model.catalogo

                        Nothing ->
                            model.catalogo ++ [ nuevoProducto ]

                nuevoModel =
                    { model
                        | catalogo = nuevoCatalogo
                        , nextProductoId =
                            if model.productoEditando == Nothing then
                                model.nextProductoId + 1

                            else
                                model.nextProductoId
                        , nuevoProductoNombre = ""
                        , nuevoProductoPrecio = ""
                        , productoEditando = Nothing
                    }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        EliminarProducto id ->
            let
                nuevoModel =
                    { model | catalogo = List.filter (\p -> p.id /= id) model.catalogo }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        PedirEliminarProducto id ->
            ( { model | confirmarEliminacionProducto = Just id }, Cmd.none )

        CancelarEliminarProducto ->
            ( { model | confirmarEliminacionProducto = Nothing }, Cmd.none )

        ConfirmarEliminarProducto ->
            case model.confirmarEliminacionProducto of
                Just id ->
                    update (EliminarProducto id) { model | confirmarEliminacionProducto = Nothing }

                Nothing ->
                    ( model, Cmd.none )

        EditarProducto id ->
            case List.filter (\p -> p.id == id) model.catalogo |> List.head of
                Just p ->
                    ( { model | productoEditando = Just id, nuevoProductoNombre = p.nombre, nuevoProductoPrecio = String.fromFloat p.precio }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        PedirEliminarItem pedidoId productoId ->
            ( { model | confirmarEliminacionItem = Just { pedidoId = pedidoId, productoId = productoId } }, Cmd.none )

        CancelarEliminarItem ->
            ( { model | confirmarEliminacionItem = Nothing }, Cmd.none )

        ConfirmarEliminarItem ->
            case model.confirmarEliminacionItem of
                Just { pedidoId, productoId } ->
                    update (CambiarCantidadItem pedidoId productoId "0") { model | confirmarEliminacionItem = Nothing }

                Nothing ->
                    ( model, Cmd.none )

        IrAInicio ->
            ( model, Nav.pushUrl model.key "/" )

        IrAGestionProductos ->
            ( model, Nav.pushUrl model.key "/productos" )

        IrAListadoPedidos ->
            ( model, Nav.pushUrl model.key "/pedidos" )

        IrAEditarPedido id ->
            ( model, Nav.pushUrl model.key ("/pedidos/" ++ String.fromInt id) )

        ExportarAPDF ->
            ( model, triggerPrint () )

        ExportarProductosCSV ->
            ( model, downloadFile { name = "productos.csv", content = "Nombre,Precio\n" ++ (model.catalogo |> List.map (\p -> p.nombre ++ "," ++ String.fromFloat p.precio) |> String.join "\n") } )

        ExportarPedidosCSV ->
            let
                encabezado =
                    "PedidoID,Estado,Producto,Cantidad,PrecioUnitario,Subtotal\n"

                -- Convertir un pedido en varias líneas de CSV (una por ítem)
                pedidoToCsvLines pedido =
                    pedido.items
                        |> List.map
                            (\item ->
                                String.fromInt pedido.id
                                    ++ ","
                                    ++ estadoToString pedido.estado
                                    ++ ","
                                    ++ item.nombreSnapshot
                                    ++ ","
                                    ++ String.fromInt item.cantidad
                                    ++ ","
                                    ++ String.fromFloat item.precioSnapshot
                                    ++ ","
                                    ++ String.fromFloat (item.precioSnapshot * toFloat item.cantidad)
                            )
                        |> String.join "\n"

                contenido =
                    encabezado ++ (model.pedidos |> List.map pedidoToCsvLines |> String.join "\n")
            in
            ( model, downloadFile { name = "pedidos.csv", content = contenido } )

        CargarProductosCSV ->
            ( model, selectFile () )

        ContenidoCSVRecibido content ->
            let
                lineas =
                    String.lines content |> List.drop 1 -- Ignorar el header

                procesarLinea linea ( actualCatalogo, nextId ) =
                    let
                        partes =
                            String.split "," linea
                    in
                    case partes of
                        [ nombre, precioStr ] ->
                            let
                                precio =
                                    String.toFloat precioStr |> Maybe.withDefault 0.0

                                nuevoProducto =
                                    { id = nextId, nombre = nombre, precio = precio }
                            in
                            if String.trim nombre /= "" && precio > 0 then
                                ( actualCatalogo ++ [ nuevoProducto ], nextId + 1 )

                            else
                                ( actualCatalogo, nextId )

                        _ ->
                            ( actualCatalogo, nextId )

                ( nuevoCatalogo, finalNextId ) =
                    List.foldl procesarLinea ( model.catalogo, model.nextProductoId ) lineas

                nuevoModel =
                    { model | catalogo = nuevoCatalogo, nextProductoId = finalNextId }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        _ ->
            UpdatePedidos.update msg model saveStorage


port saveStorage : Encode.Value -> Cmd msg
