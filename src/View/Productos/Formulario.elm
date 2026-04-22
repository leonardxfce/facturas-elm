module View.Productos.Formulario exposing (viewFormulario)

import Html exposing (Html, button, input, section, text)
import Html.Attributes exposing (disabled, id, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Messages exposing (Msg(..), ProductoMsg(..))
import Money
import Types exposing (ProductosPageData)


viewFormulario : ProductosPageData -> Html Msg
viewFormulario data =
    let
        nombreValido =
            String.trim data.form.nombre /= ""

        precioValido =
            case Money.parseCents data.form.precio of
                Just c ->
                    c > 0

                Nothing ->
                    False

        formularioValido =
            nombreValido && precioValido

        ( btnMsg, btnText ) =
            case data.editandoId of
                Just productoId ->
                    ( ProdMsg (GuardarEdicionProducto productoId), "💾" )

                Nothing ->
                    ( ProdMsg CrearProducto, "➕" )
    in
    section []
        [ input [ id "producto-nombre", name "nombre", placeholder "Nombre", value data.form.nombre, onInput (ProdMsg << InputNombreProducto) ] []
        , input [ id "producto-precio", name "precio", placeholder "Precio", type_ "number", value data.form.precio, onInput (ProdMsg << InputPrecioProducto) ] []
        , button [ onClick btnMsg, disabled (not formularioValido) ] [ text btnText ]
        ]
