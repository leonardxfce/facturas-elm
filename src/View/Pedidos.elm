module View.Pedidos exposing (viewEditarPedido, viewListadoPedidos)

import Html exposing (Html, article, button, div, h1, header, input, section, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, id, name, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Messages exposing (..)
import Types exposing (..)


viewListadoPedidos : Model -> Html Msg
viewListadoPedidos model =
    article []
        [ header []
            [ button [ class "outline", onClick IrAInicio, attribute "aria-label" "Volver" ] [ text "⬅️" ]
            , h1 [] [ text "Gestión de Pedidos" ]
            ]
        , section []
            [ button [ onClick AgregarPedido ] [ text "➕ Nuevo Pedido" ]
            , section [ class "overflow-auto" ]
                [ table [ class "striped" ]
                    [ thead []
                        [ tr []
                            [ th [] [ text "Pedido" ]
                            , th [] [ text "Estado" ]
                            , th [] [ text "Acciones" ]
                            ]
                        ]
                    , tbody [] (List.map viewResumenPedido model.pedidos)
                    ]
                ]
            ]
        ]


viewResumenPedido : Pedido -> Html Msg
viewResumenPedido pedido =
    tr []
        [ td [] [ text ("#" ++ String.fromInt pedido.id) ]
        , td [] [ text (estadoToString pedido.estado) ]
        , td []
            [ button [ class "outline", onClick (IrAEditarPedido pedido.id), attribute "aria-label" "Editar" ] [ text "✏️" ]
            , button [ class "outline secondary", onClick (EliminarPedido pedido.id), attribute "aria-label" "Eliminar" ] [ text "🗑️" ]
            ]
        ]


viewEditarPedido : Model -> Pedido -> Html Msg
viewEditarPedido model pedido =
    article []
        [ header []
            [ button [ class "outline", onClick IrAInicio, attribute "aria-label" "Volver" ] [ text "⬅️" ]
            , button [ class "outline contrast", onClick ExportarAPDF, attribute "aria-label" "Exportar a PDF" ] [ text "📄" ]
            , h1 [] [ text ("Pedido #" ++ String.fromInt pedido.id) ]
            ]
        , section [ class "overflow-auto" ]
            [ table [ class "striped" ]
                [ thead []
                    [ tr []
                        [ th [] [ text "Producto" ]
                        , th [] [ text "Cantidad" ]
                        , th [] [ text "Precio Unit." ]
                        , th [] [ text "Subtotal" ]
                        , th [] [ text "Acciones" ]
                        ]
                    ]
                , tbody [] (List.map (viewItem model.catalogo pedido.id) pedido.items)
                ]
            ]
        , viewModalConfirmacion model
        , if pedido.estado == Borrador then
            section []
                [ input [ id "busqueda-producto", name "busqueda", placeholder "Buscar producto...", value model.busquedaProducto, onInput InputBusqueda ] []
                , if String.isEmpty model.busquedaProducto then
                    div [] []

                  else
                    section [ class "overflow-auto" ]
                        [ table [ class "striped" ]
                            [ thead []
                                [ tr []
                                    [ th [] [ text "Producto" ]
                                    , th [] [ text "Precio" ]
                                    , th [] [ text "Acción" ]
                                    ]
                                ]
                            , tbody []
                                (model.catalogo
                                    |> List.filter (\p -> String.contains (String.toLower model.busquedaProducto) (String.toLower p.nombre))
                                    |> List.map (viewAgregarProductoAPedido pedido.id)
                                )
                            ]
                        ]
                ]

          else
            div [] []
        ]


viewAgregarProductoAPedido : Int -> Producto -> Html Msg
viewAgregarProductoAPedido pedidoId producto =
    tr []
        [ td [] [ text producto.nombre ]
        , td [] [ text ("$" ++ String.fromFloat producto.precio) ]
        , td []
            [ button [ class "outline", onClick (AgregarItemAPedido pedidoId producto.id) ]
                [ text "➕" ]
            ]
        ]


viewItem : List Producto -> Int -> Item -> Html Msg
viewItem catalogo pedidoId item =
    let
        producto =
            List.filter (\p -> p.id == item.productoId) catalogo
                |> List.head
                |> Maybe.withDefault { id = 0, nombre = "Producto desconocido", precio = 0.0 }
    in
    tr []
        [ td [] [ text producto.nombre ]
        , td [] [ input [ type_ "number", value (String.fromInt item.cantidad), onInput (CambiarCantidadItem pedidoId item.productoId), attribute "min" "1" ] [] ]
        , td [] [ text ("$" ++ String.fromFloat producto.precio) ]
        , td [] [ text ("$" ++ String.fromFloat (producto.precio * toFloat item.cantidad)) ]
        , td []
            [ button [ class "outline secondary", onClick (PedirEliminarItem pedidoId item.productoId), attribute "aria-label" "Eliminar" ] [ text "🗑️" ]
            ]
        ]


viewModalConfirmacion : Model -> Html Msg
viewModalConfirmacion model =
    case model.confirmarEliminacionItem of
        Just _ ->
            div [ class "modal-overlay" ]
                [ article []
                    [ header [] [ text "Confirmar eliminación" ]
                    , text "¿Estás seguro de que deseas eliminar este producto del pedido?"
                    , div [ class "modal-actions" ]
                        [ button [ class "secondary", onClick CancelarEliminarItem ] [ text "Cancelar" ]
                        , button [ onClick ConfirmarEliminarItem ] [ text "Eliminar" ]
                        ]
                    ]
                ]

        Nothing ->
            div [] []
