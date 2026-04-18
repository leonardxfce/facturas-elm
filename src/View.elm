module View exposing (view)

import Html exposing (Html, article, button, div, h1, header, input, li, section, table, tbody, td, text, th, thead, tr, ul)
import Html.Attributes exposing (attribute, class, disabled, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Messages exposing (..)
import Types exposing (..)


view : Model -> Html Msg
view model =
    case model.paginaActual of
        Inicio ->
            article []
                [ h1 [] [ text "Sistema de Facturas" ]
                , button [ onClick IrAGestionProductos ] [ text "Gestión de Productos" ]
                , button [ onClick IrAListadoPedidos ] [ text "Gestión de Pedidos" ]
                , button [ class "outline", onClick ExportarCSV ] [ text "📊 Exportar CSV" ]
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
            ]
        , section []
            [ input [ placeholder "Nombre", value model.nuevoProductoNombre, onInput InputNombreProducto ] []
            , input [ placeholder "Precio", type_ "number", value model.nuevoProductoPrecio, onInput InputPrecioProducto ] []
            , button [ onClick AgregarProducto, disabled (not formularioValido) ]
                [ text
                    (if model.productoEditando == Nothing then
                        "➕"

                     else
                        "💾"
                    )
                ]
            ]
        , section []
            [ table []
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
        ]


viewListadoPedidos : Model -> Html Msg
viewListadoPedidos model =
    article []
        [ header []
            [ button [ class "outline", onClick IrAInicio, attribute "aria-label" "Volver" ] [ text "⬅️" ]
            , h1 [] [ text "Gestión de Pedidos" ]
            ]
        , section []
            [ button [ onClick AgregarPedido ] [ text "➕ Nuevo Pedido" ]
            , table []
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


viewProducto : Producto -> Html Msg
viewProducto producto =
    tr []
        [ td [] [ text producto.nombre ]
        , td [] [ text ("$" ++ String.fromFloat producto.precio) ]
        , td []
            [ button [ class "outline", onClick (EditarProducto producto.id), attribute "aria-label" "Editar" ] [ text "✏️" ]
            , button [ class "outline secondary", onClick (EliminarProducto producto.id), attribute "aria-label" "Eliminar" ] [ text "🗑️" ]
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
        , section []
            [ ul [] (List.map (viewItem model.catalogo) pedido.items) ]
        , if pedido.estado == Borrador then
            section []
                [ input [ placeholder "Buscar producto...", value model.busquedaProducto, onInput InputBusqueda ] []
                , if String.isEmpty model.busquedaProducto then
                    div [] []

                  else
                    ul []
                        (model.catalogo
                            |> List.filter (\p -> String.contains (String.toLower model.busquedaProducto) (String.toLower p.nombre))
                            |> List.map (viewAgregarProductoAPedido pedido.id)
                        )
                ]

          else
            div [] []
        ]


viewAgregarProductoAPedido : Int -> Producto -> Html Msg
viewAgregarProductoAPedido pedidoId producto =
    li []
        [ button [ class "outline", onClick (AgregarItemAPedido pedidoId producto.id) ]
            [ text ("Agregar " ++ producto.nombre ++ " ($" ++ String.fromFloat producto.precio ++ ")") ]
        ]


viewItem : List Producto -> Item -> Html Msg
viewItem catalogo item =
    let
        producto =
            List.filter (\p -> p.id == item.productoId) catalogo
                |> List.head
                |> Maybe.withDefault { id = 0, nombre = "Producto desconocido", precio = 0.0 }
    in
    li [] [ text (producto.nombre ++ " x " ++ String.fromInt item.cantidad ++ " ($" ++ String.fromFloat (producto.precio * toFloat item.cantidad) ++ ")") ]
