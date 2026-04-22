module View.Pedidos.ProductList exposing (viewAgregarProductoAPedido)

import Html exposing (Html, button, td, text, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (ItemMsg(..), Msg(..))
import Money
import Types exposing (Producto)


viewAgregarProductoAPedido : Producto -> Html Msg
viewAgregarProductoAPedido producto =
    tr []
        [ td [] [ text producto.nombre ]
        , td [] [ text (Money.formatCents producto.precioCents) ]
        , td []
            [ button [ class "outline", onClick (ItemMsg (AgregarItemAPedido producto.id)) ]
                [ text "➕" ]
            ]
        ]
