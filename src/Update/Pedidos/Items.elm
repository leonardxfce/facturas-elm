module Update.Pedidos.Items exposing (updateItems)

import Messages exposing (Msg, PedidoMsg(..))
import Types exposing (InterfazEstado(..), Model, Pagina(..))


updateItems : PedidoMsg -> Model -> (Model -> Cmd Msg) -> ( Model, Cmd Msg )
updateItems msg model saveState =
    case msg of
        AgregarItemAPedido productoId ->
            case model.paginaActual of
                EditandoPedido pedidoId ->
                    let
                        producto =
                            List.filter (\p -> p.id == productoId) model.catalogo
                                |> List.head
                                |> Maybe.withDefault { id = 0, nombre = "Desconocido", precio = 0.0 }

                        nuevosPedidos =
                            List.map
                                (\p ->
                                    if p.id == pedidoId then
                                        if List.any (\i -> i.productoId == productoId) p.items then
                                            p

                                        else
                                            { p | items = p.items ++ [ { productoId = productoId, snapshot = { nombre = producto.nombre, precio = producto.precio }, cantidad = 1 } ] }

                                    else
                                        p
                                )
                                model.pedidos

                        nuevoModel =
                            { model | pedidos = nuevosPedidos }
                    in
                    ( nuevoModel, saveState nuevoModel )

                _ ->
                    ( model, Cmd.none )

        CambiarCantidadItem productoId nuevaCantidadStr ->
            let
                nuevaCantidad =
                    String.toInt nuevaCantidadStr |> Maybe.withDefault 1
            in
            case model.paginaActual of
                EditandoPedido pedidoId ->
                    let
                        nuevosPedidos =
                            List.map
                                (\p ->
                                    if p.id == pedidoId then
                                        { p
                                            | items =
                                                if nuevaCantidad < 1 then
                                                    p.items

                                                else
                                                    List.map
                                                        (\i ->
                                                            if i.productoId == productoId then
                                                                { i | cantidad = nuevaCantidad }

                                                            else
                                                                i
                                                        )
                                                        p.items
                                        }

                                    else
                                        p
                                )
                                model.pedidos

                        nuevoModel =
                            { model | pedidos = nuevosPedidos }
                    in
                    ( nuevoModel, saveState nuevoModel )

                _ ->
                    ( model, Cmd.none )

        PedirEliminarItem productoId ->
            case model.paginaActual of
                EditandoPedido pedidoId ->
                    ( { model | interfaz = ConfirmandoEliminarItem { pedidoId = pedidoId, productoId = productoId } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        CancelarEliminarItem ->
            ( { model | interfaz = Normal }, Cmd.none )

        ConfirmarEliminarItem ->
            case ( model.paginaActual, model.interfaz ) of
                ( EditandoPedido pedidoId, ConfirmandoEliminarItem confirmacion ) ->
                    let
                        nuevosPedidos =
                            List.map
                                (\p ->
                                    if p.id == pedidoId then
                                        { p | items = List.filter (\i -> i.productoId /= confirmacion.productoId) p.items }

                                    else
                                        p
                                )
                                model.pedidos

                        nuevoModel =
                            { model | pedidos = nuevosPedidos, interfaz = Normal }
                    in
                    ( nuevoModel, saveState nuevoModel )

                _ ->
                    ( { model | interfaz = Normal }, Cmd.none )

        _ ->
            ( model, Cmd.none )
