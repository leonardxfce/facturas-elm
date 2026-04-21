module Persistence exposing (decodeModel, encodeDatosBase)

import Json.Decode as Decode
import Json.Encode as Encode
import Types exposing (..)


encodeDatosBase : Model -> Encode.Value
encodeDatosBase model =
    Encode.object
        [ ( "catalogo", Encode.list encodeProducto model.catalogo )
        , ( "pedidos", Encode.list encodePedido model.pedidos )
        , ( "nextProductoId", Encode.int model.nextProductoId )
        , ( "nextPedidoId", Encode.int model.nextPedidoId )
        ]


decodeModel : Decode.Decoder (Model -> Model)
decodeModel =
    decodeDatosBase


decodeDatosBase : Decode.Decoder (Model -> Model)
decodeDatosBase =
    Decode.map4 (\c p nP nE -> \base -> { base | catalogo = c, pedidos = p, nextProductoId = nP, nextPedidoId = nE })
        (Decode.oneOf [ Decode.field "catalogo" (Decode.list decodeProducto), Decode.succeed [] ])
        (Decode.oneOf [ Decode.field "pedidos" (Decode.list decodePedido), Decode.succeed [] ])
        (Decode.oneOf [ Decode.field "nextProductoId" Decode.int, Decode.succeed 1 ])
        (Decode.oneOf [ Decode.field "nextPedidoId" Decode.int, Decode.succeed 1 ])


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
        , ( "fechaEntrega", p.fechaEntrega |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
        ]


encodeItem : Item -> Encode.Value
encodeItem i =
    Encode.object
        [ ( "productoId", Encode.int i.productoId )
        , ( "snapshot"
          , Encode.object
                [ ( "nombre", Encode.string i.snapshot.nombre )
                , ( "precio", Encode.float i.snapshot.precio )
                ]
          )
        , ( "cantidad", Encode.int i.cantidad )
        ]


decodeProducto : Decode.Decoder Producto
decodeProducto =
    Decode.map3 Producto
        (Decode.field "id" Decode.int)
        (Decode.oneOf [ Decode.field "nombre" Decode.string, Decode.succeed "Producto sin nombre" ])
        (Decode.oneOf [ Decode.field "precio" Decode.float, Decode.succeed 0.0 ])


decodePedido : Decode.Decoder Pedido
decodePedido =
    Decode.map4 Pedido
        (Decode.field "id" Decode.int)
        (Decode.oneOf [ Decode.field "items" (Decode.list decodeItem), Decode.succeed [] ])
        (Decode.oneOf [ Decode.field "estado" (Decode.string |> Decode.andThen stringToEstadoDecoder), Decode.succeed Borrador ])
        (Decode.maybe (Decode.field "fechaEntrega" Decode.string))


decodeItem : Decode.Decoder Item
decodeItem =
    Decode.map3 Item
        (Decode.field "productoId" Decode.int)
        (Decode.field "snapshot"
            (Decode.map2 (\n p -> { nombre = n, precio = p })
                (Decode.oneOf [ Decode.field "nombre" Decode.string, Decode.succeed "Producto Histórico" ])
                (Decode.oneOf [ Decode.field "precio" Decode.float, Decode.succeed 0.0 ])
            )
        )
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
