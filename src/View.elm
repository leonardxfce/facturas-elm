module View exposing (view)

import Html exposing (Html, text)
import Messages exposing (Msg)
import Types exposing (Model, PageState(..))
import View.Inicio as Inicio
import View.Pedidos as Pedidos
import View.Productos as Productos


view : Model -> Html Msg
view model =
    case model.page of
        InicioPage ->
            Inicio.viewInicio

        ProductosPage data ->
            Productos.viewGestionProductos model.catalogo data

        PedidosListPage ->
            Pedidos.viewListadoPedidos model.pedidos

        PedidoEditPage data ->
            case List.filter (\p -> p.id == data.pedidoId) model.pedidos |> List.head of
                Just pedido ->
                    Pedidos.viewEditarPedido model.catalogo data pedido

                Nothing ->
                    text ""
