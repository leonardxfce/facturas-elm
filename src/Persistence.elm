module Persistence exposing (decodeModel, encodeModel, modelToCsv)

import Json.Decode as Decode
import Json.Encode as Encode
import Types exposing (..)


modelToCsv : Model -> String
modelToCsv model =
    let
        header =
            "Tipo,ID,Nombre,Precio/Estado\n"

        productos =
            List.map (\p -> "Producto," ++ String.fromInt p.id ++ "," ++ p.nombre ++ "," ++ String.fromFloat p.precio) model.catalogo

        pedidos =
            List.map (\p -> "Pedido," ++ String.fromInt p.id ++ ",," ++ estadoToString p.estado) model.pedidos
    in
    header ++ String.join "\n" productos ++ "\n" ++ String.join "\n" pedidos


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
        (Decode.field "precio" Decode.float)


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
