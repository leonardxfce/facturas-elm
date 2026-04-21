module View.Productos.Formulario exposing (viewFormulario)

import Html exposing (Html, button, input, section, text)
import Html.Attributes exposing (disabled, id, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Messages exposing (Msg(..), ProductoMsg(..))
import Types exposing (..)


viewFormulario : Model -> Html Msg
viewFormulario model =
    let
        nombreValido =
            String.trim model.nuevoProducto.nombre /= ""

        precioValido =
            (String.toFloat model.nuevoProducto.precio |> Maybe.withDefault 0.0) > 0

        formularioValido =
            nombreValido && precioValido
    in
    section []
        [ input [ id "producto-nombre", name "nombre", placeholder "Nombre", value model.nuevoProducto.nombre, onInput (ProdMsg << InputNombreProducto) ] []
        , input [ id "producto-precio", name "precio", placeholder "Precio", type_ "number", value model.nuevoProducto.precio, onInput (ProdMsg << InputPrecioProducto) ] []
        , button [ onClick (ProdMsg AgregarProducto), disabled (not formularioValido) ]
            [ text
                (case model.interfaz of
                    EditandoProducto _ ->
                        "💾"

                    _ ->
                        "➕"
                )
            ]
        ]
