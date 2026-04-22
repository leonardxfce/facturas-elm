module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (ArchivoMsg(..), Msg(..), NavegacionMsg(..))
import Persistence exposing (decodeModel)
import Ports exposing (fileContentReceived)
import Routing
import Types exposing (Model, initModel)
import Update exposing (update)
import Url exposing (Url)
import View exposing (view)


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
        basePath =
            Decode.decodeValue (Decode.field "basePath" Decode.string) flags
                |> Result.withDefault ""

        storage =
            Decode.decodeValue (Decode.field "storage" Decode.value) flags
                |> Result.withDefault Encode.null

        base =
            initModel basePath key url

        withData =
            case Decode.decodeValue decodeModel storage of
                Ok patcher ->
                    patcher base

                Err _ ->
                    base

        ( page, cmd ) =
            Routing.routeToPageState (Routing.parseUrl basePath url) withData
    in
    ( { withData | page = page }, cmd )
