module Update.Pedidos exposing (mapPedido, update)

import Browser.Navigation as Nav
import Messages exposing (Msg(..), PedidoMsg(..))
import Routing exposing (Route(..))
import Task
import Time
import Types exposing (Estado(..), Model, PageState(..), Pedido)


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

                newModel =
                    { model
                        | pedidos = model.pedidos ++ [ nuevoPedido ]
                        , nextPedidoId = model.nextPedidoId + 1
                    }
            in
            ( newModel
            , Cmd.batch
                [ saveState newModel
                , Nav.pushUrl model.key (Routing.routeToUrl model.basePath (RouteEditarPedido nuevoPedido.id))
                ]
            )

        EliminarPedido id ->
            let
                newModel =
                    { model | pedidos = List.filter (\p -> p.id /= id) model.pedidos }
            in
            ( newModel, saveState newModel )

        GuardarPedido ->
            ( model, Nav.pushUrl model.key (Routing.routeToUrl model.basePath RouteListadoPedidos) )

        CancelarEdicionPedido ->
            ( model, Nav.pushUrl model.key (Routing.routeToUrl model.basePath RouteListadoPedidos) )

        IniciarEntregaPedido ->
            case model.page of
                PedidoEditPage _ ->
                    ( model, Task.perform (PedMsg << EntregarPedidoConFecha) Time.now )

                _ ->
                    ( model, Cmd.none )

        EntregarPedidoConFecha posix ->
            case model.page of
                PedidoEditPage data ->
                    let
                        fecha =
                            formatPosix Time.utc posix

                        newModel =
                            mapPedido data.pedidoId
                                (\p -> { p | estado = Entregado, fechaEntrega = Just fecha })
                                model
                    in
                    ( newModel
                    , Cmd.batch
                        [ saveState newModel
                        , Nav.pushUrl model.key (Routing.routeToUrl model.basePath RouteListadoPedidos)
                        ]
                    )

                _ ->
                    ( model, Cmd.none )


mapPedido : Int -> (Pedido -> Pedido) -> Model -> Model
mapPedido pedidoId f model =
    { model
        | pedidos =
            List.map
                (\p ->
                    if p.id == pedidoId then
                        f p

                    else
                        p
                )
                model.pedidos
    }


formatPosix : Time.Zone -> Time.Posix -> String
formatPosix zone posix =
    let
        pad n =
            String.padLeft 2 '0' (String.fromInt n)

        y =
            String.fromInt (Time.toYear zone posix)

        mo =
            pad (monthToInt (Time.toMonth zone posix))

        d =
            pad (Time.toDay zone posix)

        h =
            pad (Time.toHour zone posix)

        mi =
            pad (Time.toMinute zone posix)

        s =
            pad (Time.toSecond zone posix)
    in
    y ++ "-" ++ mo ++ "-" ++ d ++ " " ++ h ++ ":" ++ mi ++ ":" ++ s


monthToInt : Time.Month -> Int
monthToInt m =
    case m of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12
