module Update.Productos exposing (update)

import Messages exposing (ProductoMsg(..))
import Types exposing (InterfazEstado(..), Model)


update : ProductoMsg -> Model -> Model
update msg model =
    case msg of
        InputNombreProducto val ->
            { model | nuevoProducto = { nombre = val, precio = model.nuevoProducto.precio } }

        InputPrecioProducto val ->
            { model | nuevoProducto = { nombre = model.nuevoProducto.nombre, precio = val } }

        InputBusqueda val ->
            { model | busquedaProducto = val }

        AgregarProducto ->
            let
                nuevoProducto =
                    case model.interfaz of
                        EditandoProducto id ->
                            { id = id, nombre = model.nuevoProducto.nombre, precio = String.toFloat model.nuevoProducto.precio |> Maybe.withDefault 0.0 }

                        _ ->
                            { id = model.nextProductoId, nombre = model.nuevoProducto.nombre, precio = String.toFloat model.nuevoProducto.precio |> Maybe.withDefault 0.0 }

                nuevoCatalogo =
                    case model.interfaz of
                        EditandoProducto id ->
                            List.map
                                (\p ->
                                    if p.id == id then
                                        nuevoProducto

                                    else
                                        p
                                )
                                model.catalogo

                        _ ->
                            model.catalogo ++ [ nuevoProducto ]
            in
            { model
                | catalogo = nuevoCatalogo
                , nextProductoId =
                    case model.interfaz of
                        EditandoProducto _ ->
                            model.nextProductoId

                        _ ->
                            model.nextProductoId + 1
                , nuevoProducto = { nombre = "", precio = "" }
                , interfaz = Normal
            }

        EliminarProducto id ->
            { model | catalogo = List.filter (\p -> p.id /= id) model.catalogo, interfaz = Normal }

        PedirEliminarProducto id ->
            { model | interfaz = ConfirmandoEliminarProducto id }

        CancelarEliminarProducto ->
            { model | interfaz = Normal }

        ConfirmarEliminarProducto ->
            case model.interfaz of
                ConfirmandoEliminarProducto id ->
                    update (EliminarProducto id) model

                _ ->
                    model

        EditarProducto id ->
            case List.filter (\p -> p.id == id) model.catalogo |> List.head of
                Just p ->
                    { model | interfaz = EditandoProducto id, nuevoProducto = { nombre = p.nombre, precio = String.fromFloat p.precio } }

                Nothing ->
                    model
