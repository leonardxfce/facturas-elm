module Routing exposing (Route(..), parseUrl, routeToPageState, routeToUrl)

import Browser.Navigation as Nav
import Types exposing (Model, PageState(..), emptyProductosPage, initPedidoEditPage)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, s)


type Route
    = RouteInicio
    | RouteProductos
    | RouteListadoPedidos
    | RouteEditarPedido Int


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map RouteInicio Parser.top
        , Parser.map RouteProductos (s "productos")
        , Parser.map RouteListadoPedidos (s "pedidos")
        , Parser.map RouteEditarPedido (s "pedidos" </> int)
        ]


{-| Parse a URL into a Route, after stripping the deployment base path
(e.g. "/facturas-elm" on GitHub Pages, "" on root deployments).
-}
parseUrl : String -> Url -> Route
parseUrl basePath url =
    Parser.parse parser { url | path = stripBasePath basePath url.path }
        |> Maybe.withDefault RouteInicio


stripBasePath : String -> String -> String
stripBasePath basePath path =
    if String.isEmpty basePath then
        path

    else if String.startsWith basePath path then
        let
            rest =
                String.dropLeft (String.length basePath) path
        in
        if String.isEmpty rest then
            "/"

        else
            rest

    else
        path


{-| Build an absolute URL including the deployment base path.
-}
routeToUrl : String -> Route -> String
routeToUrl basePath route =
    let
        sub =
            case route of
                RouteInicio ->
                    "/"

                RouteProductos ->
                    "/productos"

                RouteListadoPedidos ->
                    "/pedidos"

                RouteEditarPedido id ->
                    "/pedidos/" ++ String.fromInt id
    in
    if String.isEmpty basePath then
        sub

    else if sub == "/" then
        basePath ++ "/"

    else
        basePath ++ sub


{-| Given a parsed route and the current model, build the initial
PageState. If the route references a missing pedido, redirect to
the list.
-}
routeToPageState : Route -> Model -> ( PageState, Cmd msg )
routeToPageState route model =
    case route of
        RouteInicio ->
            ( InicioPage, Cmd.none )

        RouteProductos ->
            ( ProductosPage emptyProductosPage, Cmd.none )

        RouteListadoPedidos ->
            ( PedidosListPage, Cmd.none )

        RouteEditarPedido id ->
            if List.any (\p -> p.id == id) model.pedidos then
                ( PedidoEditPage (initPedidoEditPage id), Cmd.none )

            else
                ( PedidosListPage
                , Nav.replaceUrl model.key (routeToUrl model.basePath RouteListadoPedidos)
                )
