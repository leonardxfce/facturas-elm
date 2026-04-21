module View.Pedidos.ProductList exposing (viewAgregarProductoAPedido)

import Html exposing (Html, button, td, text, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..), PedidoMsg(..))
import Types exposing (Producto)


viewAgregarProductoAPedido : Producto -> Html Msg
viewAgregarProductoAPedido producto =
    tr []
        [ td [] [ text producto.nombre ]
        , td [] [ text ("$" ++ String.fromFloat producto.precio) ]
        , td []
            [ button [ class "outline", onClick (PedMsg (AgregarItemAPedido producto.id)) ]
                [ text "➕" ]
            ]
        ]
