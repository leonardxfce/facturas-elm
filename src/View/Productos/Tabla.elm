module View.Productos.Tabla exposing (viewTablaProductos)

import Html exposing (Html, button, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Messages exposing (Msg(..), ProductoMsg(..))
import Money
import Types exposing (Producto)


viewTablaProductos : List Producto -> Html Msg
viewTablaProductos productos =
    table [ class "striped" ]
        [ thead []
            [ tr []
                [ th [] [ text "Nombre" ]
                , th [] [ text "Precio" ]
                , th [] [ text "Acciones" ]
                ]
            ]
        , tbody [] (List.map viewProducto productos)
        ]


viewProducto : Producto -> Html Msg
viewProducto producto =
    tr []
        [ td [] [ text producto.nombre ]
        , td [] [ text (Money.formatCents producto.precioCents) ]
        , td []
            [ button [ class "outline", onClick (ProdMsg (EditarProducto producto.id)), attribute "aria-label" "Editar" ] [ text "✏️" ]
            , button [ class "outline secondary", onClick (ProdMsg (PedirEliminarProducto producto.id)), attribute "aria-label" "Eliminar" ] [ text "🗑️" ]
            ]
        ]
