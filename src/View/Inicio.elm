module View.Inicio exposing (viewInicio)

import Html exposing (Html, article, button, h1, section, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Messages exposing (..)


viewInicio : Html Msg
viewInicio =
    article []
        [ h1 [] [ text "Sistema de Facturas" ]
        , section [] [ button [ class "w-100", onClick (NavMsg IrAGestionProductos) ] [ text "Gestión de Productos" ] ]
        , section [] [ button [ class "w-100", onClick (NavMsg IrAListadoPedidos) ] [ text "Gestión de Pedidos" ] ]
        , section [ class "grid" ]
            [ button [ class "outline", onClick (ArchivoMsg ExportarProductosCSV) ] [ text "📦 Productos CSV" ]
            , button [ class "outline", onClick (ArchivoMsg ExportarPedidosCSV) ] [ text "📝 Pedidos CSV" ]
            ]
        ]
