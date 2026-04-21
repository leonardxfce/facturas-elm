module Update.Archivos exposing (update)

import Messages exposing (ArchivoMsg(..), Msg)
import Ports exposing (downloadFile, selectFile, triggerPrint)
import Types exposing (Model, estadoToString)


update : (Model -> Cmd Msg) -> ArchivoMsg -> Model -> ( Model, Cmd Msg )
update saveState msg model =
    case msg of
        ExportarAPDF ->
            ( model, triggerPrint () )

        ExportarProductosCSV ->
            ( model, downloadFile { name = "productos.csv", content = "Nombre,Precio\n" ++ (model.catalogo |> List.map (\p -> p.nombre ++ "," ++ String.fromFloat p.precio) |> String.join "\n") } )

        ExportarPedidosCSV ->
            let
                encabezado =
                    "PedidoID,Estado,Producto,Cantidad,PrecioUnitario,Subtotal\n"

                pedidoToCsvLines pedido =
                    pedido.items
                        |> List.map
                            (\item ->
                                String.fromInt pedido.id
                                    ++ ","
                                    ++ estadoToString pedido.estado
                                    ++ ","
                                    ++ item.snapshot.nombre
                                    ++ ","
                                    ++ String.fromInt item.cantidad
                                    ++ ","
                                    ++ String.fromFloat item.snapshot.precio
                                    ++ ","
                                    ++ String.fromFloat (item.snapshot.precio * toFloat item.cantidad)
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
                    String.lines content |> List.drop 1

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
            ( nuevoModel, saveState nuevoModel )
