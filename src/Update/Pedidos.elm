module Update.Pedidos exposing (update)

import Browser.Navigation as Nav
import Messages exposing (Msg, PedidoMsg(..))
import Types exposing (Estado(..), Model)
import Update.Pedidos.Items as UpdateItems


update : PedidoMsg -> Model -> (Model -> Cmd Msg) -> ( Model, Cmd Msg )
update msg model saveState =
    case msg of
        AgregarPedido ->
            let
                nuevoPedido =
                    { id = model.nextPedidoId
                    , items = []
                    , estado = Borrador
                    , fechaEntrega = Nothing
                    }

                nuevoModel =
                    { model
                        | pedidos = model.pedidos ++ [ nuevoPedido ]
                        , nextPedidoId = model.nextPedidoId + 1
                    }
            in
            ( nuevoModel
            , Cmd.batch
                [ saveState nuevoModel
                , Nav.pushUrl model.key ("/pedidos/" ++ String.fromInt nuevoPedido.id)
                ]
            )

        EliminarPedido id ->
            let
                nuevoModel =
                    { model | pedidos = List.filter (\p -> p.id /= id) model.pedidos }
            in
            ( nuevoModel, saveState nuevoModel )

        GuardarPedido ->
            ( model, Nav.pushUrl model.key "/pedidos" )

        CancelarEdicionPedido ->
            ( model, Nav.pushUrl model.key "/pedidos" )

        EntregarPedido ->
            case model.paginaActual of
                Types.EditandoPedido id ->
                    let
                        nuevosPedidos =
                            List.map
                                (\p ->
                                    if p.id == id then
                                        { p
                                            | estado = Entregado
                                            , fechaEntrega = Just "2026-04-19 12:00:00"
                                        }

                                    else
                                        p
                                )
                                model.pedidos

                        nuevoModel =
                            { model | pedidos = nuevosPedidos }
                    in
                    ( nuevoModel
                    , Cmd.batch
                        [ saveState nuevoModel
                        , Nav.pushUrl model.key "/pedidos"
                        ]
                    )

                _ ->
                    ( model, Cmd.none )

        AgregarItemAPedido _ ->
            UpdateItems.updateItems msg model saveState

        CambiarCantidadItem _ _ ->
            UpdateItems.updateItems msg model saveState

        PedirEliminarItem _ ->
            UpdateItems.updateItems msg model saveState

        CancelarEliminarItem ->
            UpdateItems.updateItems msg model saveState

        ConfirmarEliminarItem ->
            UpdateItems.updateItems msg model saveState
