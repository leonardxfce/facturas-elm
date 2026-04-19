module View exposing (view)

import Html exposing (Html, article, button, div, h1, header, input, section, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, disabled, id, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Messages exposing (..)
import Types exposing (..)
import View.Pedidos exposing (..)


view : Model -> Html Msg
view model =
    case model.paginaActual of
        Inicio ->
            article []
                [ h1 [] [ text "Sistema de Facturas" ]
                , section [] [ button [ class "w-100", onClick IrAGestionProductos ] [ text "Gestión de Productos" ] ]
                , section [] [ button [ class "w-100", onClick IrAListadoPedidos ] [ text "Gestión de Pedidos" ] ]
                , section [ class "grid" ]
                    [ button [ class "outline", onClick ExportarProductosCSV ] [ text "📦 Productos CSV" ]
                    , button [ class "outline", onClick ExportarPedidosCSV ] [ text "📝 Pedidos CSV" ]
                    ]
                ]

        GestionProductos ->
            viewGestionProductos model

        ListadoPedidos ->
            viewListadoPedidos model

        EditandoPedido id ->
            case List.filter (\p -> p.id == id) model.pedidos |> List.head of
                Just pedido ->
                    viewEditarPedido model pedido

                Nothing ->
                    viewListadoPedidos model


viewGestionProductos : Model -> Html Msg
viewGestionProductos model =
    let
        nombreValido =
            String.trim model.nuevoProductoNombre /= ""

        precioValido =
            (String.toFloat model.nuevoProductoPrecio |> Maybe.withDefault 0.0) > 0

        formularioValido =
            nombreValido && precioValido
    in
    article []
        [ header []
            [ button [ class "outline", onClick IrAInicio, attribute "aria-label" "Volver" ] [ text "⬅️" ]
            , h1 [] [ text "Gestión de Productos" ]
            , button [ class "outline", onClick CargarProductosCSV ] [ text "📥 Importar" ]
            ]

        , section []
            [ input [ id "producto-nombre", name "nombre", placeholder "Nombre", value model.nuevoProductoNombre, onInput InputNombreProducto ] []
            , input [ id "producto-precio", name "precio", placeholder "Precio", type_ "number", value model.nuevoProductoPrecio, onInput InputPrecioProducto ] []
            , button [ onClick AgregarProducto, disabled (not formularioValido) ]
                [ text
                    (if model.productoEditando == Nothing then
                        "➕"

                     else
                        "💾"
                    )
                ]
            ]
        , section [ class "overflow-auto" ]
            [ table [ class "striped" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Nombre" ]
                        , th [] [ text "Precio" ]
                        , th [] [ text "Acciones" ]
                        ]
                    ]
                , tbody [] (List.map viewProducto model.catalogo)
                ]
            ]
        , viewModalConfirmacionProducto model
        ]


viewProducto : Producto -> Html Msg
viewProducto producto =
    tr []
        [ td [] [ text producto.nombre ]
        , td [] [ text ("$" ++ String.fromFloat producto.precio) ]
        , td []
            [ button [ class "outline", onClick (EditarProducto producto.id), attribute "aria-label" "Editar" ] [ text "✏️" ]
            , button [ class "outline secondary", onClick (PedirEliminarProducto producto.id), attribute "aria-label" "Eliminar" ] [ text "🗑️" ]
            ]
        ]


viewModalConfirmacionProducto : Model -> Html Msg
viewModalConfirmacionProducto model =
    case model.confirmarEliminacionProducto of
        Just _ ->
            div [ class "modal-overlay" ]
                [ article []
                    [ header [] [ text "Confirmar eliminación" ]
                    , text "¿Estás seguro de que deseas eliminar este producto? Se eliminará del catálogo."
                    , div [ class "modal-actions" ]
                        [ button [ class "secondary", onClick CancelarEliminarProducto ] [ text "Cancelar" ]
                        , button [ onClick ConfirmarEliminarProducto ] [ text "Eliminar" ]
                        ]
                    ]
                ]

        Nothing ->
            div [] []
