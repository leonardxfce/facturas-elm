module View.Components exposing (confirmModal)

import Html exposing (Html, article, button, div, header, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


confirmModal :
    { titulo : String
    , mensaje : String
    , onCancel : msg
    , onConfirm : msg
    }
    -> Html msg
confirmModal { titulo, mensaje, onCancel, onConfirm } =
    div [ class "modal-overlay" ]
        [ article []
            [ header [] [ text titulo ]
            , text mensaje
            , div [ class "modal-actions" ]
                [ button [ class "secondary", onClick onCancel ] [ text "Cancelar" ]
                , button [ onClick onConfirm ] [ text "Eliminar" ]
                ]
            ]
        ]
