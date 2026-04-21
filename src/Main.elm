module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (ArchivoMsg(..), Msg(..), NavegacionMsg(..))
import Persistence exposing (decodeModel)
import Ports exposing (fileContentReceived)
import Types exposing (Model, Pagina(..), initModel)
import Update exposing (update)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, s)
import View exposing (view)



-- ROUTING


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



-- MAIN


main : Program Encode.Value Model Msg
main =
    Browser.application
        { init = init
        , view = \model -> { title = "Sistema de Pedidos", body = [ view model ] }
        , update = update
        , subscriptions = \_ -> fileContentReceived (ArchivoMsg << ContenidoCSVRecibido)
        , onUrlRequest = NavMsg << LinkClicked
        , onUrlChange = NavMsg << UrlChanged
        }


init : Encode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        decoded =
            Decode.decodeValue decodeModel flags

        baseModel =
            initModel key url

        model =
            case decoded of
                Ok patcher ->
                    patcher baseModel

                Err _ ->
                    baseModel

        -- Sincronizar página actual con la URL inicial
        pagina =
            urlToPage url

        modelConPagina =
            { model | paginaActual = pagina }

        -- Lógica de recuperación
        ( finalModel, cmd ) =
            case pagina of
                EditandoPedido id ->
                    case List.filter (\p -> p.id == id) modelConPagina.pedidos |> List.head of
                        Just _ ->
                            ( modelConPagina, Cmd.none )

                        Nothing ->
                            ( { modelConPagina | paginaActual = ListadoPedidos }, Nav.replaceUrl key "/pedidos" )

                _ ->
                    ( modelConPagina, Cmd.none )
    in
    ( finalModel, cmd )
