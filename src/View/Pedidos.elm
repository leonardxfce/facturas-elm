module View.Pedidos exposing (viewEditarPedido, viewListadoPedidos)

import Html exposing (Html, article, button, div, h1, header, input, section, table, tbody, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, id, name, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Messages exposing (..)
import Types exposing (..)
import View.Pedidos.Actions as PedidosActions
import View.Pedidos.Components as PedidosComponents
import View.Pedidos.Header as PedidosHeader
import View.Pedidos.Modal as PedidosModal
import View.Pedidos.ProductList as ProductList
import View.Pedidos.Table as PedidosTable


viewListadoPedidos : Model -> Html Msg
viewListadoPedidos model =
    article []
        [ header []
            [ button [ class "outline", onClick (NavMsg IrAInicio), attribute "aria-label" "Volver" ] [ text "⬅️" ]
            , h1 [] [ text "Gestión de Pedidos" ]
            ]
        , section []
            [ button [ onClick (PedMsg AgregarPedido) ] [ text "➕ Nuevo Pedido" ]
            , section [ class "overflow-auto" ]
                [ table [ class "striped" ]
                    [ thead []
                        [ tr []
                            [ th [] [ text "Pedido" ]
                            , th [] [ text "Estado" ]
                            , th [] [ text "Acciones" ]
                            ]
                        ]
                    , tbody [] (List.map PedidosComponents.viewResumenPedido model.pedidos)
                    ]
                ]
            ]
        ]


viewEditarPedido : Model -> Pedido -> Html Msg
viewEditarPedido model pedido =
    let
        esSoloLectura =
            pedido.estado == Entregado
    in
    article []
        [ PedidosHeader.viewHeader pedido
        , section [ class "overflow-auto" ]
            [ PedidosTable.viewTablaItems esSoloLectura pedido.items
            ]
        , PedidosActions.viewActions pedido
        , PedidosModal.viewModalConfirmacion model
        , if not esSoloLectura then
            section []
                [ input [ id "busqueda-producto", name "busqueda", placeholder "Buscar producto para agregar...", value model.busquedaProducto, onInput (ProdMsg << InputBusqueda) ] []
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
                                    |> List.map ProductList.viewAgregarProductoAPedido
                                )
                            ]
                        ]
                ]

          else
            div [] []
        ]
