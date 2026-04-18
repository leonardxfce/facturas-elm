module Main exposing (main)

import Browser
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Msg)
import Persistence exposing (decodeModel)
import Types exposing (Model, initialModel)
import Update exposing (update)
import View exposing (view)


main : Program Encode.Value Model Msg
main =
    Browser.element
        { init =
            \flags ->
                let
                    decoded =
                        Decode.decodeValue decodeModel flags

                    model =
                        case decoded of
                            Ok m ->
                                m

                            Err _ ->
                                initialModel
                in
                ( model, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
