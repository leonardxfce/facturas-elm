module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Msg(..))
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
        , subscriptions = \_ -> fileContentReceived ContenidoCSVRecibido
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
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
        finalModel =
            { model | paginaActual = urlToPage url }
    in
    ( finalModel, Cmd.none )
