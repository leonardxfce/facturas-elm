module Update.Archivos exposing (update)

import Messages exposing (ArchivoMsg(..), Msg)
import Money
import Ports exposing (downloadFile, selectFile, triggerPrint)
import Types exposing (Model, estadoToString)


update : (Model -> Cmd Msg) -> ArchivoMsg -> Model -> ( Model, Cmd Msg )
update saveState msg model =
    case msg of
        ExportarAPDF ->
            ( model, triggerPrint () )

        ExportarProductosCSV ->
            let
                row p =
                    escapeCsvField p.nombre ++ "," ++ Money.centsToDecimalString p.precioCents

                contenido =
                    "Nombre,Precio\n" ++ String.join "\n" (List.map row model.catalogo)
            in
            ( model, downloadFile { name = "productos.csv", content = contenido } )

        ExportarPedidosCSV ->
            let
                encabezado =
                    "PedidoID,Estado,Producto,Cantidad,PrecioUnitario,Subtotal\n"

                pedidoToCsvLines pedido =
                    pedido.items
                        |> List.map
                            (\item ->
                                String.join ","
                                    [ String.fromInt pedido.id
                                    , estadoToString pedido.estado
                                    , escapeCsvField item.snapshot.nombre
                                    , String.fromInt item.cantidad
                                    , Money.centsToDecimalString item.snapshot.precioCents
                                    , Money.centsToDecimalString (item.snapshot.precioCents * item.cantidad)
                                    ]
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
                -- NOTE: this importer does not handle CSV fields with quoted
                -- commas. The exporter escapes them correctly but round-tripping
                -- a quoted field through this import will fail. Acceptable for
                -- current use; replace with a real CSV parser if that changes.
                lineas =
                    String.lines content |> List.drop 1

                procesarLinea linea ( actualCatalogo, nextId ) =
                    case String.split "," linea of
                        [ nombreRaw, precioStr ] ->
                            let
                                nombre =
                                    String.trim nombreRaw
                            in
                            case ( nombre, Money.parseCents precioStr ) of
                                ( "", _ ) ->
                                    ( actualCatalogo, nextId )

                                ( _, Nothing ) ->
                                    ( actualCatalogo, nextId )

                                ( _, Just cents ) ->
                                    if cents <= 0 then
                                        ( actualCatalogo, nextId )

                                    else
                                        ( actualCatalogo
                                            ++ [ { id = nextId, nombre = nombre, precioCents = cents } ]
                                        , nextId + 1
                                        )

                        _ ->
                            ( actualCatalogo, nextId )

                ( nuevoCatalogo, finalNextId ) =
                    List.foldl procesarLinea ( model.catalogo, model.nextProductoId ) lineas

                newModel =
                    { model | catalogo = nuevoCatalogo, nextProductoId = finalNextId }
            in
            ( newModel, saveState newModel )


{-| RFC 4180-ish CSV escape: wrap in double-quotes and double any existing
quotes if the field contains any of `,` `"` `\n` `\r`.
-}
escapeCsvField : String -> String
escapeCsvField s =
    let
        needsQuoting =
            String.contains "," s
                || String.contains "\"" s
                || String.contains "\n" s
                || String.contains "\u{000D}" s
    in
    if needsQuoting then
        "\"" ++ String.replace "\"" "\"\"" s ++ "\""

    else
        s
