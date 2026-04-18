port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, input, li, text, ul)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode


-- PORTS

port savePedidos : Encode.Value -> Cmd msg


-- MODEL

type Estado
    = Borrador
    | Entregado


type alias Producto =
    { id : Int
    , nombre : String
    , precio : Float
    }


type alias Item =
    { productoId : Int
    , cantidad : Int
    }


type alias Pedido =
    { id : Int
    , items : List Item
    , estado : Estado
    }


type alias Model =
    { catalogo : List Producto
    , pedidos : List Pedido
    , nextProductoId : Int
    , nuevoProductoNombre : String
    , nuevoProductoPrecio : String
    , productoEditando : Maybe Int
    }


initialModel : Model
initialModel =
    { catalogo =
        [ { id = 1, nombre = "Café", precio = 150.0 }
        , { id = 2, nombre = "Medialuna", precio = 80.0 }
        ]
    , pedidos =
        [ { id = 1
          , items = [ { productoId = 1, cantidad = 2 } ]
          , estado = Borrador
          }
        ]
    , nextProductoId = 3
    , nuevoProductoNombre = ""
    , nuevoProductoPrecio = ""
    , productoEditando = Nothing
    }


-- UPDATE

type Msg
    = CambiarEstado Int Estado
    | InputNombreProducto String
    | InputPrecioProducto String
    | AgregarProducto
    | EliminarProducto Int
    | EditarProducto Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CambiarEstado id nuevoEstado ->
            let
                actualizarPedido p =
                    if p.id == id then
                        { p | estado = nuevoEstado }
                    else
                        p

                nuevoModel =
                    { model | pedidos = List.map actualizarPedido model.pedidos }
            in
            ( nuevoModel, savePedidos (encodePedidos nuevoModel.pedidos) )

        InputNombreProducto nombre ->
            ( { model | nuevoProductoNombre = nombre }, Cmd.none )

        InputPrecioProducto precio ->
            ( { model | nuevoProductoPrecio = precio }, Cmd.none )

        AgregarProducto ->
            let
                precio = String.toFloat model.nuevoProductoPrecio |> Maybe.withDefault 0.0
                nombre = model.nuevoProductoNombre
            in
            case model.productoEditando of
                Just id ->
                    let
                        actualizar p = if p.id == id then { p | nombre = nombre, precio = precio } else p
                    in
                    ( { model | catalogo = List.map actualizar model.catalogo, productoEditando = Nothing, nuevoProductoNombre = "", nuevoProductoPrecio = "" }, Cmd.none )

                Nothing ->
                    let
                        nuevoProducto = { id = model.nextProductoId, nombre = nombre, precio = precio }
                    in
                    ( { model | catalogo = model.catalogo ++ [ nuevoProducto ], nextProductoId = model.nextProductoId + 1, nuevoProductoNombre = "", nuevoProductoPrecio = "" }, Cmd.none )

        EliminarProducto id ->
            ( { model | catalogo = List.filter (\p -> p.id /= id) model.catalogo }, Cmd.none )

        EditarProducto id ->
            case List.filter (\p -> p.id == id) model.catalogo |> List.head of
                Just p -> ( { model | nuevoProductoNombre = p.nombre, nuevoProductoPrecio = String.fromFloat p.precio, productoEditando = Just id }, Cmd.none )
                Nothing -> ( model, Cmd.none )


encodePedidos : List Pedido -> Encode.Value
encodePedidos pedidos =
    Encode.list encodePedido pedidos


encodePedido : Pedido -> Encode.Value
encodePedido p =
    Encode.object
        [ ( "id", Encode.int p.id )
        , ( "items", Encode.list encodeItem p.items )
        , ( "estado", Encode.string (estadoToString p.estado) )
        ]


encodeItem : Item -> Encode.Value
encodeItem i =
    Encode.object
        [ ( "productoId", Encode.int i.productoId )
        , ( "cantidad", Encode.int i.cantidad )
        ]


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Catálogo de Productos" ]
        , input [ placeholder "Nombre", value model.nuevoProductoNombre, onInput InputNombreProducto ] []
        , input [ placeholder "Precio", type_ "number", value model.nuevoProductoPrecio, onInput InputPrecioProducto ] []
        , button [ onClick AgregarProducto ] [ text (if model.productoEditando == Nothing then "Agregar Producto" else "Actualizar Producto") ]
        , ul [] (List.map viewProducto model.catalogo)
        , h1 [] [ text "Pedidos" ]
        , ul [] (List.map (viewPedido model.catalogo) model.pedidos)
        ]


viewProducto : Producto -> Html Msg
viewProducto producto =
    li []
        [ text (producto.nombre ++ " - $" ++ String.fromFloat producto.precio)
        , button [ onClick (EditarProducto producto.id) ] [ text "Editar" ]
        , button [ onClick (EliminarProducto producto.id) ] [ text "Eliminar" ]
        ]


viewPedido : List Producto -> Pedido -> Html Msg
viewPedido catalogo pedido =
    li []
        [ text ("Pedido #" ++ String.fromInt pedido.id ++ " - " ++ estadoToString pedido.estado)
        , button [ onClick (CambiarEstado pedido.id (alternarEstado pedido.estado)) ] [ text "Cambiar Estado" ]
        , ul [] (List.map (viewItem catalogo) pedido.items)
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


estadoToString : Estado -> String
estadoToString estado =
    case estado of
        Borrador ->
            "Borrador"

        Entregado ->
            "Entregado"


alternarEstado : Estado -> Estado
alternarEstado estado =
    case estado of
        Borrador ->
            Entregado

        Entregado ->
            Borrador


-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, savePedidos (encodePedidos initialModel.pedidos) )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


