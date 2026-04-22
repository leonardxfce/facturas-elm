module View.Productos exposing (viewGestionProductos)

import Html exposing (Html, article, button, h1, header, section, text)
import Html.Attributes exposing (attribute, class)
import Html.Events exposing (onClick)
import Messages exposing (ArchivoMsg(..), Msg(..), NavegacionMsg(..), ProductoMsg(..))
import Types exposing (Producto, ProductosPageData)
import View.Components exposing (confirmModal)
import View.Productos.Formulario as ProductosForm
import View.Productos.Tabla as ProductosTabla


viewGestionProductos : List Producto -> ProductosPageData -> Html Msg
viewGestionProductos catalogo data =
    article []
        [ header []
            [ button [ class "outline", onClick (NavMsg IrAInicio), attribute "aria-label" "Volver" ] [ text "⬅️" ]
            , h1 [] [ text "Gestión de Productos" ]
            , button [ class "outline", onClick (ArchivoMsg CargarProductosCSV) ] [ text "📥 Importar" ]
            ]
        , ProductosForm.viewFormulario data
        , section [ class "overflow-auto" ]
            [ ProductosTabla.viewTablaProductos catalogo
            ]
        , case data.confirmandoEliminar of
            Just _ ->
                confirmModal
                    { titulo = "Confirmar eliminación"
                    , mensaje = "¿Estás seguro de que deseas eliminar este producto? Se eliminará del catálogo."
                    , onCancel = ProdMsg CancelarEliminarProducto
                    , onConfirm = ProdMsg ConfirmarEliminarProducto
                    }

            Nothing ->
                text ""
        ]
