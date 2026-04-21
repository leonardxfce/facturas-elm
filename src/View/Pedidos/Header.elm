module View.Pedidos.Header exposing (viewHeader)

import Html exposing (Html, button, h1, h3, header, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Messages exposing (ArchivoMsg(..), Msg(..), PedidoMsg(..))
import Types exposing (..)


viewHeader : Pedido -> Html Msg
viewHeader pedido =
    let
        esSoloLectura =
            pedido.estado == Entregado
    in
    header []
        [ button [ class "outline", onClick (PedMsg CancelarEdicionPedido), attribute "aria-label" "Volver" ] [ text "⬅️" ]
        , if esSoloLectura then
            button [ class "outline contrast", onClick (ArchivoMsg ExportarAPDF), attribute "aria-label" "Exportar a PDF" ] [ text "📄" ]

          else
            text ""
        , h1 []
            [ text ("Pedido #" ++ String.fromInt pedido.id) ]
        , if esSoloLectura then
            h3 [] [ text ("Entregado: " ++ Maybe.withDefault "N/A" pedido.fechaEntrega) ]

          else
            text ""
        ]
