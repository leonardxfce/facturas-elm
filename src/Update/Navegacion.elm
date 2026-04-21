module Update.Navegacion exposing (update)

import Browser
import Browser.Navigation as Nav
import Messages exposing (Msg, NavegacionMsg(..))
import Types exposing (Model, Pagina(..))
import Url
import Url.Parser as Parser exposing ((</>), Parser, int, s)


routeParser : Parser (Pagina -> a) a
routeParser =
    Parser.oneOf
        [ Parser.map Inicio Parser.top
        , Parser.map GestionProductos (s "productos")
        , Parser.map ListadoPedidos (s "pedidos")
        , Parser.map EditandoPedido (s "pedidos" </> int)
        ]


urlToPage : Url.Url -> Pagina
urlToPage url =
    Parser.parse routeParser url |> Maybe.withDefault Inicio


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
                nuevaPagina =
                    urlToPage url
            in
            ( { model | url = url, paginaActual = nuevaPagina, busquedaProducto = "" }, Cmd.none )

        IrAInicio ->
            ( model, Nav.pushUrl model.key "/" )

        IrAGestionProductos ->
            ( model, Nav.pushUrl model.key "/productos" )

        IrAListadoPedidos ->
            ( model, Nav.pushUrl model.key "/pedidos" )

        IrAEditarPedido id ->
            ( model, Nav.pushUrl model.key ("/pedidos/" ++ String.fromInt id) )
