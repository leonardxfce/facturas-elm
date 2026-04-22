module View.Pedidos exposing (viewEditarPedido, viewListadoPedidos)

import Html exposing (Html, article, button, div, h1, header, input, section, table, tbody, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, id, name, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Messages exposing (ItemMsg(..), Msg(..), NavegacionMsg(..), PedidoMsg(..))
import Types exposing (Estado(..), Pedido, PedidoEditPageData, Producto)
import View.Components exposing (confirmModal)
import View.Pedidos.Actions as PedidosActions
import View.Pedidos.Components as PedidosComponents
import View.Pedidos.Header as PedidosHeader
import View.Pedidos.ProductList as ProductList
import View.Pedidos.Table as PedidosTable


viewListadoPedidos : List Pedido -> Html Msg
viewListadoPedidos pedidos =
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
                    , tbody [] (List.map PedidosComponents.viewResumenPedido pedidos)
                    ]
                ]
            ]
        ]


viewEditarPedido : List Producto -> PedidoEditPageData -> Pedido -> Html Msg
viewEditarPedido catalogo data pedido =
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
        , case data.confirmandoEliminarItem of
            Just _ ->
                confirmModal
                    { titulo = "Confirmar eliminación"
                    , mensaje = "¿Estás seguro de que deseas eliminar este producto del pedido?"
                    , onCancel = ItemMsg CancelarEliminarItem
                    , onConfirm = ItemMsg ConfirmarEliminarItem
                    }

            Nothing ->
                text ""
        , if not esSoloLectura then
            section []
                [ input
                    [ id "busqueda-producto"
                    , name "busqueda"
                    , placeholder "Buscar producto para agregar..."
                    , value data.busqueda
                    , onInput (ItemMsg << InputBusqueda)
                    ]
                    []
                , if String.isEmpty data.busqueda then
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
                                (catalogo
                                    |> List.filter (\p -> String.contains (String.toLower data.busqueda) (String.toLower p.nombre))
                                    |> List.map ProductList.viewAgregarProductoAPedido
                                )
                            ]
                        ]
                ]

          else
            div [] []
        ]
