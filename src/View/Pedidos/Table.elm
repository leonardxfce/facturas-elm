module View.Pedidos.Table exposing (viewTablaItems)

import Html exposing (Html, table, tbody, td, text, tfoot, th, thead, tr)
import Html.Attributes exposing (class, style)
import Messages exposing (Msg)
import Money
import Types exposing (Item)
import View.Pedidos.Components as PedidosComponents


viewTablaItems : Bool -> List Item -> Html Msg
viewTablaItems esSoloLectura items =
    let
        total =
            List.foldl (\item acc -> acc + item.snapshot.precioCents * item.cantidad) 0 items
    in
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
        , tfoot []
            [ tr []
                [ td [] []
                , td [] []
                , td [ style "font-weight" "bold" ] [ text "Total" ]
                , td [ style "font-weight" "bold" ] [ text (Money.formatCents total) ]
                , if esSoloLectura then
                    text ""

                  else
                    td [] []
                ]
            ]
        ]
