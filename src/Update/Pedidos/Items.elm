module Update.Pedidos.Items exposing (update)

import Messages exposing (ItemMsg(..), Msg)
import Types exposing (Model, PageState(..), PedidoEditPageData)
import Update.Pedidos exposing (mapPedido)


update : ItemMsg -> Model -> (Model -> Cmd Msg) -> ( Model, Cmd Msg )
update msg model saveState =
    case model.page of
        PedidoEditPage data ->
            handle msg model data saveState

        _ ->
            ( model, Cmd.none )


handle : ItemMsg -> Model -> PedidoEditPageData -> (Model -> Cmd Msg) -> ( Model, Cmd Msg )
handle msg model data saveState =
    case msg of
        InputBusqueda val ->
            ( { model | page = PedidoEditPage { data | busqueda = val } }
            , Cmd.none
            )

        AgregarItemAPedido productoId ->
            case List.filter (\p -> p.id == productoId) model.catalogo |> List.head of
                Just producto ->
                    let
                        addIfMissing p =
                            if List.any (\i -> i.productoId == productoId) p.items then
                                p

                            else
                                { p
                                    | items =
                                        p.items
                                            ++ [ { productoId = productoId
                                                 , snapshot =
                                                    { nombre = producto.nombre
                                                    , precioCents = producto.precioCents
                                                    }
                                                 , cantidad = 1
                                                 }
                                               ]
                                }

                        newModel =
                            mapPedido data.pedidoId addIfMissing model
                    in
                    ( newModel, saveState newModel )

                Nothing ->
                    ( model, Cmd.none )

        CambiarCantidadItem productoId nuevaCantidadStr ->
            let
                nuevaCantidad =
                    String.toInt nuevaCantidadStr |> Maybe.withDefault 1
            in
            if nuevaCantidad < 1 then
                ( model, Cmd.none )

            else
                let
                    changeQty p =
                        { p
                            | items =
                                List.map
                                    (\i ->
                                        if i.productoId == productoId then
                                            { i | cantidad = nuevaCantidad }

                                        else
                                            i
                                    )
                                    p.items
                        }

                    newModel =
                        mapPedido data.pedidoId changeQty model
                in
                ( newModel, saveState newModel )

        PedirEliminarItem productoId ->
            ( { model | page = PedidoEditPage { data | confirmandoEliminarItem = Just productoId } }
            , Cmd.none
            )

        CancelarEliminarItem ->
            ( { model | page = PedidoEditPage { data | confirmandoEliminarItem = Nothing } }
            , Cmd.none
            )

        ConfirmarEliminarItem ->
            case data.confirmandoEliminarItem of
                Just productoId ->
                    let
                        removeItem p =
                            { p | items = List.filter (\i -> i.productoId /= productoId) p.items }

                        cleared =
                            { model | page = PedidoEditPage { data | confirmandoEliminarItem = Nothing } }

                        newModel =
                            mapPedido data.pedidoId removeItem cleared
                    in
                    ( newModel, saveState newModel )

                Nothing ->
                    ( model, Cmd.none )
