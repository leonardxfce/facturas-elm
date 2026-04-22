module Update.Navegacion exposing (update)

import Browser
import Browser.Navigation as Nav
import Messages exposing (Msg, NavegacionMsg(..))
import Routing exposing (Route(..))
import Types exposing (Model)
import Url


update : NavegacionMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                ( page, cmd ) =
                    Routing.routeToPageState (Routing.parseUrl model.basePath url) model
            in
            ( { model | url = url, page = page }, cmd )

        IrAInicio ->
            ( model, Nav.pushUrl model.key (Routing.routeToUrl model.basePath RouteInicio) )

        IrAGestionProductos ->
            ( model, Nav.pushUrl model.key (Routing.routeToUrl model.basePath RouteProductos) )

        IrAListadoPedidos ->
            ( model, Nav.pushUrl model.key (Routing.routeToUrl model.basePath RouteListadoPedidos) )

        IrAEditarPedido id ->
            ( model, Nav.pushUrl model.key (Routing.routeToUrl model.basePath (RouteEditarPedido id)) )
