module View.Pedidos.Table exposing (viewTablaItems)

import Html exposing (Html, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (class, style)
import Messages exposing (..)
import Types exposing (..)
import View.Pedidos.Components as PedidosComponents


viewTablaItems : Bool -> List Item -> Html Msg
viewTablaItems esSoloLectura items =
    table [ class "striped" ]
        [ thead []
            [ tr []
                [ th [] [ text "Producto" ]
                , th [] [ text "Cantidad" ]
                , th [] [ text "Precio Unit." ]
                , th [] [ text "Subtotal" ]
                , if esSoloLectura then
                    text ""

                  else
                    th [] [ text "Acciones" ]
                ]
            ]
        , tbody [] (List.map (PedidosComponents.viewItem esSoloLectura) items)
        , Html.tfoot []
            [ tr []
                [ td [] []
                , td [] []
                , td [ style "font-weight" "bold" ] [ text "Total" ]
                , td [ style "font-weight" "bold" ] [ text ("$" ++ String.fromFloat (List.foldl (\item acc -> acc + (item.snapshot.precio * toFloat item.cantidad)) 0 items)) ]
                , if esSoloLectura then
                    text ""

                  else
                    td [] []
                ]
            ]
        ]
