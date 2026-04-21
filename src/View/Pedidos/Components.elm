module View.Pedidos.Components exposing (viewItem, viewResumenPedido)

import Html exposing (Html, button, input, span, td, text, tr)
import Html.Attributes exposing (attribute, class, type_, value)
import Html.Events exposing (onClick, onInput)
import Messages exposing (Msg(..), NavegacionMsg(..), PedidoMsg(..))
import Types exposing (Estado(..), Item, Pedido, estadoToString)


viewResumenPedido : Pedido -> Html Msg
viewResumenPedido pedido =
    tr []
        [ td [] [ text ("#" ++ String.fromInt pedido.id) ]
        , td []
            [ span
                [ class
                    (if pedido.estado == Entregado then
                        "badge-success"

                     else
                        "badge-info"
                    )
                ]
                [ text (estadoToString pedido.estado) ]
            ]
        , td []
            [ button [ class "outline", onClick (NavMsg (IrAEditarPedido pedido.id)), attribute "aria-label" "Ver/Editar" ]
                [ text
                    (if pedido.estado == Entregado then
                        "👁️"

                     else
                        "✏️"
                    )
                ]
            , button [ class "outline secondary", onClick (PedMsg (EliminarPedido pedido.id)), attribute "aria-label" "Eliminar" ] [ text "🗑️" ]
            ]
        ]


viewItem : Bool -> Item -> Html Msg
viewItem esSoloLectura item =
    tr []
        [ td [] [ text item.snapshot.nombre ]
        , td []
            [ if esSoloLectura then
                text (String.fromInt item.cantidad)

              else
                input [ type_ "number", value (String.fromInt item.cantidad), onInput (PedMsg << CambiarCantidadItem item.productoId), attribute "min" "1" ] []
            ]
        , td [] [ text ("$" ++ String.fromFloat item.snapshot.precio) ]
        , td [] [ text ("$" ++ String.fromFloat (item.snapshot.precio * toFloat item.cantidad)) ]
        , if esSoloLectura then
            text ""

          else
            td []
                [ button [ class "outline secondary", onClick (PedMsg (PedirEliminarItem item.productoId)), attribute "aria-label" "Eliminar" ] [ text "🗑️" ]
                ]
        ]
