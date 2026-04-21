module View.Productos.Modal exposing (viewModalConfirmacionProducto)

import Html exposing (Html, article, button, div, header, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..), ProductoMsg(..))
import Types exposing (..)


viewModalConfirmacionProducto : Model -> Html Msg
viewModalConfirmacionProducto model =
    case model.interfaz of
        ConfirmandoEliminarProducto _ ->
            div [ class "modal-overlay" ]
                [ article []
                    [ header [] [ text "Confirmar eliminación" ]
                    , text "¿Estás seguro de que deseas eliminar este producto? Se eliminará del catálogo."
                    , div [ class "modal-actions" ]
                        [ button [ class "secondary", onClick (ProdMsg CancelarEliminarProducto) ] [ text "Cancelar" ]
                        , button [ onClick (ProdMsg ConfirmarEliminarProducto) ] [ text "Eliminar" ]
                        ]
                    ]
                ]

        _ ->
            div [] []
