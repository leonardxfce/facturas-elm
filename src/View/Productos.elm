module View.Productos exposing (viewGestionProductos)

import Html exposing (Html, article, button, h1, header, section, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Types exposing (..)
import View.Productos.Formulario as ProductosForm
import View.Productos.Modal as ProductosModal
import View.Productos.Tabla as ProductosTabla


viewGestionProductos : Model -> Html Msg
viewGestionProductos model =
    article []
        [ header []
            [ button [ class "outline", onClick (NavMsg IrAInicio), attribute "aria-label" "Volver" ] [ text "⬅️" ]
            , h1 [] [ text "Gestión de Productos" ]
            , button [ class "outline", onClick (ArchivoMsg CargarProductosCSV) ] [ text "📥 Importar" ]
            ]
        , ProductosForm.viewFormulario model
        , section [ class "overflow-auto" ]
            [ ProductosTabla.viewTablaProductos model.catalogo
            ]
        , ProductosModal.viewModalConfirmacionProducto model
        ]
