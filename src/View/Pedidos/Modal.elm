module View.Pedidos.Modal exposing (viewModalConfirmacion)

import Html exposing (Html, article, button, div, header, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..), PedidoMsg(..))
import Types exposing (..)


viewModalConfirmacion : Model -> Html Msg
viewModalConfirmacion model =
    case model.interfaz of
        ConfirmandoEliminarItem _ ->
            div [ class "modal-overlay" ]
                [ article []
                    [ header [] [ text "Confirmar eliminación" ]
                    , text "¿Estás seguro de que deseas eliminar este producto del pedido?"
                    , div [ class "modal-actions" ]
                        [ button [ class "secondary", onClick (PedMsg CancelarEliminarItem) ] [ text "Cancelar" ]
                        , button [ onClick (PedMsg ConfirmarEliminarItem) ] [ text "Eliminar" ]
                        ]
                    ]
                ]

        _ ->
            div [] []
