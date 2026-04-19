module Update.Pedidos exposing (update)

import Json.Encode as Encode
import Messages exposing (Msg(..))
import Persistence exposing (encodeModel)
import Types exposing (Estado(..), Model)


update : Msg -> Model -> (Encode.Value -> Cmd msg) -> ( Model, Cmd msg )
update msg model saveStorage =
    case msg of
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
                producto =
                    List.filter (\p -> p.id == productoId) model.catalogo
                        |> List.head
                        |> Maybe.withDefault { id = 0, nombre = "Desconocido", precio = 0.0 }

                actualizarPedido p =
                    if p.id == pedidoId then
                        { p | items = p.items ++ [ { productoId = productoId, nombreSnapshot = producto.nombre, precioSnapshot = producto.precio, cantidad = 1 } ] }

                    else
                        p

                nuevoModel =
                    { model | pedidos = List.map actualizarPedido model.pedidos }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        CambiarCantidadItem pedidoId productoId nuevaCantidadStr ->
            let
                nuevaCantidad =
                    String.toInt nuevaCantidadStr |> Maybe.withDefault 1

                actualizarPedido p =
                    if p.id == pedidoId then
                        let
                            nuevosItems =
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
                        in
                        { p | items = nuevosItems }

                    else
                        p

                nuevoModel =
                    { model | pedidos = List.map actualizarPedido model.pedidos }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        _ ->
            ( model, Cmd.none )
