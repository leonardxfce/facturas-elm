module Update.Productos exposing (update)

import Messages exposing (Msg, ProductoMsg(..))
import Money
import Types exposing (Model, PageState(..), ProductosPageData)


update : ProductoMsg -> Model -> (Model -> Cmd Msg) -> ( Model, Cmd Msg )
update msg model saveState =
    case model.page of
        ProductosPage data ->
            let
                ( newModel, persist ) =
                    handle msg model data
            in
            if persist then
                ( newModel, saveState newModel )

            else
                ( newModel, Cmd.none )

        _ ->
            ( model, Cmd.none )


handle : ProductoMsg -> Model -> ProductosPageData -> ( Model, Bool )
handle msg model data =
    case msg of
        InputNombreProducto val ->
            let
                form =
                    data.form
            in
            ( setPage model { data | form = { form | nombre = val } }, False )

        InputPrecioProducto val ->
            let
                form =
                    data.form
            in
            ( setPage model { data | form = { form | precio = val } }, False )

        CrearProducto ->
            case validateForm data.form of
                Just ( nombre, cents ) ->
                    let
                        nuevo =
                            { id = model.nextProductoId
                            , nombre = nombre
                            , precioCents = cents
                            }
                    in
                    ( { model
                        | catalogo = model.catalogo ++ [ nuevo ]
                        , nextProductoId = model.nextProductoId + 1
                        , page = ProductosPage (resetForm data)
                      }
                    , True
                    )

                Nothing ->
                    ( model, False )

        GuardarEdicionProducto id ->
            case validateForm data.form of
                Just ( nombre, cents ) ->
                    let
                        actualizar p =
                            if p.id == id then
                                { p | nombre = nombre, precioCents = cents }

                            else
                                p
                    in
                    ( { model
                        | catalogo = List.map actualizar model.catalogo
                        , page = ProductosPage (resetForm data)
                      }
                    , True
                    )

                Nothing ->
                    ( model, False )

        EditarProducto id ->
            case List.filter (\p -> p.id == id) model.catalogo |> List.head of
                Just p ->
                    ( setPage model
                        { data
                            | form =
                                { nombre = p.nombre
                                , precio = Money.centsToDecimalString p.precioCents
                                }
                            , editandoId = Just id
                        }
                    , False
                    )

                Nothing ->
                    ( model, False )

        PedirEliminarProducto id ->
            ( setPage model { data | confirmandoEliminar = Just id }, False )

        CancelarEliminarProducto ->
            ( setPage model { data | confirmandoEliminar = Nothing }, False )

        ConfirmarEliminarProducto ->
            case data.confirmandoEliminar of
                Just id ->
                    ( { model
                        | catalogo = List.filter (\p -> p.id /= id) model.catalogo
                        , page = ProductosPage { data | confirmandoEliminar = Nothing }
                      }
                    , True
                    )

                Nothing ->
                    ( model, False )


validateForm : { nombre : String, precio : String } -> Maybe ( String, Int )
validateForm form =
    let
        nombre =
            String.trim form.nombre
    in
    if nombre == "" then
        Nothing

    else
        case Money.parseCents form.precio of
            Just cents ->
                if cents > 0 then
                    Just ( nombre, cents )

                else
                    Nothing

            Nothing ->
                Nothing


resetForm : ProductosPageData -> ProductosPageData
resetForm data =
    { data | form = { nombre = "", precio = "" }, editandoId = Nothing }


setPage : Model -> ProductosPageData -> Model
setPage model data =
    { model | page = ProductosPage data }
