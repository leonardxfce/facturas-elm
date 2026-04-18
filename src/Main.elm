port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, input, li, text, ul)
import Html.Attributes exposing (disabled, placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Json.Encode as Encode


-- PORTS

port saveStorage : Encode.Value -> Cmd msg


-- MODEL

type Estado
    = Borrador
    | Entregado

type Pagina
    = Inicio
    | GestionProductos
    | ListadoPedidos
    | EditandoPedido Int



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
    , nextPedidoId : Int
    , nuevoProductoNombre : String
    , nuevoProductoPrecio : String
    , busquedaProducto : String
    , productoEditando : Maybe Int
    , paginaActual : Pagina
    }


initialModel : Model
initialModel =
    { catalogo = []
    , pedidos = []
    , nextProductoId = 1
    , nextPedidoId = 1
    , nuevoProductoNombre = ""
    , nuevoProductoPrecio = ""
    , busquedaProducto = ""
    , productoEditando = Nothing
    , paginaActual = Inicio
    }


-- UPDATE

type Msg
    = CambiarEstado Int Estado
    | InputNombreProducto String
    | InputPrecioProducto String
    | InputBusqueda String
    | AgregarProducto
    | EliminarProducto Int
    | EditarProducto Int
    | AgregarPedido
    | EliminarPedido Int
    | AgregarItemAPedido Int Int
    | IrAInicio
    | IrAGestionProductos
    | IrAListadoPedidos
    | IrAEditarPedido Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- ...
        InputBusqueda busqueda ->
            ( { model | busquedaProducto = busqueda }, Cmd.none )
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
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        InputNombreProducto nombre ->
            ( { model | nuevoProductoNombre = nombre }, Cmd.none )

        InputPrecioProducto precio ->
            ( { model | nuevoProductoPrecio = precio }, Cmd.none )

        AgregarProducto ->
            let
                precio = String.toFloat model.nuevoProductoPrecio |> Maybe.withDefault 0.0
                nombre = String.trim model.nuevoProductoNombre
            in
            if nombre == "" || precio <= 0 then
                ( model, Cmd.none )
            else
                case model.productoEditando of
                    Just id ->
                        let
                            actualizar p = if p.id == id then { p | nombre = nombre, precio = precio } else p
                            nuevoModel = { model | catalogo = List.map actualizar model.catalogo, productoEditando = Nothing, nuevoProductoNombre = "", nuevoProductoPrecio = "" }
                        in
                        ( nuevoModel, saveStorage (encodeModel nuevoModel) )

                    Nothing ->
                        let
                            nuevoProducto = { id = model.nextProductoId, nombre = nombre, precio = precio }
                            nuevoModel = { model | catalogo = model.catalogo ++ [ nuevoProducto ], nextProductoId = model.nextProductoId + 1, nuevoProductoNombre = "", nuevoProductoPrecio = "" }
                        in
                        ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        EliminarProducto id ->
            let
                nuevoModel = { model | catalogo = List.filter (\p -> p.id /= id) model.catalogo }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        EditarProducto id ->
            case List.filter (\p -> p.id == id) model.catalogo |> List.head of
                Just p -> ( { model | nuevoProductoNombre = p.nombre, nuevoProductoPrecio = String.fromFloat p.precio, productoEditando = Just id }, Cmd.none )
                Nothing -> ( model, Cmd.none )

        AgregarPedido ->
            let
                nuevoPedido = { id = model.nextPedidoId, items = [], estado = Borrador }
                nuevoModel = { model | pedidos = model.pedidos ++ [ nuevoPedido ], nextPedidoId = model.nextPedidoId + 1 }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        EliminarPedido id ->
            let
                nuevoModel = { model | pedidos = List.filter (\p -> p.id /= id) model.pedidos }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        AgregarItemAPedido pedidoId productoId ->
            let
                actualizarPedido p =
                    if p.id == pedidoId then
                        { p | items = p.items ++ [{ productoId = productoId, cantidad = 1 }] }
                    else
                        p
                nuevoModel = { model | pedidos = List.map actualizarPedido model.pedidos }
            in
            ( nuevoModel, saveStorage (encodeModel nuevoModel) )

        IrAInicio ->
            ( { model | paginaActual = Inicio, busquedaProducto = "" }, Cmd.none )

        IrAGestionProductos ->
            ( { model | paginaActual = GestionProductos }, Cmd.none )

        IrAListadoPedidos ->
            ( { model | paginaActual = ListadoPedidos, busquedaProducto = "" }, Cmd.none )

        IrAEditarPedido id ->
            ( { model | paginaActual = EditandoPedido id, busquedaProducto = "" }, Cmd.none )


encodeModel : Model -> Encode.Value
encodeModel model =
    Encode.object
        [ ( "catalogo", Encode.list encodeProducto model.catalogo )
        , ( "pedidos", Encode.list encodePedido model.pedidos )
        , ( "nextProductoId", Encode.int model.nextProductoId )
        , ( "nextPedidoId", Encode.int model.nextPedidoId )
        ]

encodeProducto : Producto -> Encode.Value
encodeProducto p =
    Encode.object
        [ ( "id", Encode.int p.id )
        , ( "nombre", Encode.string p.nombre )
        , ( "precio", Encode.float p.precio )
        ]

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


viewGestionProductos : Model -> Html Msg
viewGestionProductos model =
    let
        nombreValido = String.trim model.nuevoProductoNombre /= ""
        precioValido = (String.toFloat model.nuevoProductoPrecio |> Maybe.withDefault 0.0) > 0
        formularioValido = nombreValido && precioValido
    in
    div []
        [ button [ onClick IrAInicio ] [ text "Volver al Inicio" ]
        , h1 [] [ text "Gestión de Productos" ]
        , input [ placeholder "Nombre", value model.nuevoProductoNombre, onInput InputNombreProducto ] []
        , input [ placeholder "Precio", type_ "number", value model.nuevoProductoPrecio, onInput InputPrecioProducto ] []
        , button [ onClick AgregarProducto, disabled (not formularioValido) ] [ text (if model.productoEditando == Nothing then "Agregar Producto" else "Actualizar Producto") ]
        , ul [] (List.map viewProducto model.catalogo)
        ]


viewListadoPedidos : Model -> Html Msg
viewListadoPedidos model =
    div []
        [ button [ onClick IrAInicio ] [ text "Volver al Inicio" ]
        , h1 [] [ text "Gestión de Pedidos" ]
        , button [ onClick AgregarPedido ] [ text "Crear Nuevo Pedido" ]
        , ul [] (List.map viewResumenPedido model.pedidos)
        ]



viewProducto : Producto -> Html Msg
viewProducto producto =
    li []
        [ text (producto.nombre ++ " - $" ++ String.fromFloat producto.precio)
        , button [ onClick (EditarProducto producto.id) ] [ text "Editar" ]
        , button [ onClick (EliminarProducto producto.id) ] [ text "Eliminar" ]
        ]


viewInicio : Model -> Html Msg
viewInicio model =
    let
        nombreValido = String.trim model.nuevoProductoNombre /= ""
        precioValido = (String.toFloat model.nuevoProductoPrecio |> Maybe.withDefault 0.0) > 0
        formularioValido = nombreValido && precioValido
    in
    div []
        [ h1 [] [ text "Catálogo de Productos" ]
        , input [ placeholder "Nombre", value model.nuevoProductoNombre, onInput InputNombreProducto ] []
        , input [ placeholder "Precio", type_ "number", value model.nuevoProductoPrecio, onInput InputPrecioProducto ] []
        , button [ onClick AgregarProducto, disabled (not formularioValido) ] [ text (if model.productoEditando == Nothing then "Agregar Producto" else "Actualizar Producto") ]
        , ul [] (List.map viewProducto model.catalogo)
        , h1 [] [ text "Pedidos" ]
        , button [ onClick AgregarPedido ] [ text "Crear Nuevo Pedido" ]
        , ul [] (List.map viewResumenPedido model.pedidos)
        ]


viewResumenPedido : Pedido -> Html Msg
viewResumenPedido pedido =
    li []
        [ text ("Pedido #" ++ String.fromInt pedido.id ++ " - " ++ estadoToString pedido.estado)
        , button [ onClick (IrAEditarPedido pedido.id) ] [ text "Editar" ]
        , button [ onClick (EliminarPedido pedido.id) ] [ text "Eliminar" ]
        ]


viewEditarPedido : Model -> Pedido -> Html Msg
viewEditarPedido model pedido =
    div []
        [ button [ onClick IrAInicio ] [ text "Volver" ]
        , h1 [] [ text ("Editando Pedido #" ++ String.fromInt pedido.id) ]
        , ul [] (List.map (viewItem model.catalogo) pedido.items)
        , if pedido.estado == Borrador then
            div [] 
                [ input [ placeholder "Buscar producto...", value model.busquedaProducto, onInput InputBusqueda ] []
                , if String.isEmpty model.busquedaProducto then
                    div [] []
                  else
                    ul [] (model.catalogo
                            |> List.filter (\p -> String.contains (String.toLower model.busquedaProducto) (String.toLower p.nombre))
                            |> List.map (viewAgregarProductoAPedido pedido.id))
                ]
          else div [] []
        ]


viewAgregarProductoAPedido : Int -> Producto -> Html Msg
viewAgregarProductoAPedido pedidoId producto =
    li []
        [ button [ onClick (AgregarItemAPedido pedidoId producto.id) ] 
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


view : Model -> Html Msg
view model =
    case model.paginaActual of
        Inicio ->
            div []
                [ h1 [] [ text "Sistema de Facturas" ]
                , button [ onClick IrAGestionProductos ] [ text "Gestión de Productos" ]
                , button [ onClick IrAListadoPedidos ] [ text "Gestión de Pedidos" ]
                ]

        GestionProductos ->
            viewGestionProductos model

        ListadoPedidos ->
            viewListadoPedidos model

        EditandoPedido id ->
            case List.filter (\p -> p.id == id) model.pedidos |> List.head of
                Just pedido -> viewEditarPedido model pedido
                Nothing -> viewListadoPedidos model


-- ...

-- MAIN


main : Program Encode.Value Model Msg
main =
    Browser.element
        { init = \flags -> 
            let
                decoded = Decode.decodeValue decodeModel flags
                
                model = case decoded of
                    Ok m -> m
                    Err _ -> initialModel
            in
            ( model, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- DECODERS

decodeModel : Decode.Decoder Model
decodeModel =
    Decode.map4 (\c p nP nE -> { initialModel | catalogo = c, pedidos = p, nextProductoId = nP, nextPedidoId = nE })
        (Decode.field "catalogo" (Decode.list decodeProducto))
        (Decode.field "pedidos" (Decode.list decodePedido))
        (Decode.field "nextProductoId" Decode.int)
        (Decode.field "nextPedidoId" Decode.int)

decodeProducto : Decode.Decoder Producto
decodeProducto =
    Decode.map3 Producto
        (Decode.field "id" Decode.int)
        (Decode.field "nombre" Decode.string)
        (Decode.field "precio" (Decode.map (\f -> f) Decode.float))

decodePedido : Decode.Decoder Pedido
decodePedido =
    Decode.map3 Pedido
        (Decode.field "id" Decode.int)
        (Decode.field "items" (Decode.list decodeItem))
        (Decode.field "estado" (Decode.string |> Decode.andThen stringToEstadoDecoder))


decodeItem : Decode.Decoder Item
decodeItem =
    Decode.map2 Item
        (Decode.field "productoId" Decode.int)
        (Decode.field "cantidad" Decode.int)


stringToEstadoDecoder : String -> Decode.Decoder Estado
stringToEstadoDecoder str =
    case str of
        "Borrador" ->
            Decode.succeed Borrador
        "Entregado" ->
            Decode.succeed Entregado
        _ ->
            Decode.fail ("Estado desconocido: " ++ str)
