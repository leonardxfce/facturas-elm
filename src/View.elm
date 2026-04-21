module View exposing (view)

import Html exposing (Html, text)
import Messages exposing (..)
import Types exposing (..)
import View.Inicio as Inicio
import View.Pedidos as Pedidos
import View.Productos as Productos


view : Model -> Html Msg
view model =
    case model.paginaActual of
        Inicio ->
            Inicio.viewInicio

        GestionProductos ->
            Productos.viewGestionProductos model

        ListadoPedidos ->
            Pedidos.viewListadoPedidos model

        EditandoPedido id ->
            case List.filter (\p -> p.id == id) model.pedidos |> List.head of
                Just p ->
                    Pedidos.viewEditarPedido model p

                Nothing ->
                    text "Pedido no encontrado"
