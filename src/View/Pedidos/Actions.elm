module View.Pedidos.Actions exposing (viewActions)

import Html exposing (Html, button, div, section, text)
import Html.Attributes exposing (class, disabled)
import Html.Events exposing (onClick)
import Messages exposing (ArchivoMsg(..), Msg(..), PedidoMsg(..))
import Types exposing (Estado(..), Pedido)


viewActions : Pedido -> Html Msg
viewActions pedido =
    if pedido.estado == Entregado then
        section []
            [ button [ class "w-100 contrast", onClick (ArchivoMsg ExportarAPDF) ] [ text "📄 Imprimir Pedido" ]
            ]

    else
        div [ class "grid" ]
            [ button [ class "secondary", onClick (PedMsg CancelarEdicionPedido) ] [ text "Cancelar" ]
            , button [ class "outline", onClick (PedMsg IniciarEntregaPedido), disabled (List.isEmpty pedido.items) ] [ text "✅ Marcar como Entregado" ]
            , button [ onClick (PedMsg GuardarPedido) ] [ text "💾 Guardar Cambios" ]
            ]
