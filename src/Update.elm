port module Update exposing (update)

import Json.Encode as Encode
import Messages exposing (Msg(..), ProductoMsg(..))
import Persistence exposing (encodeDatosBase)
import Types exposing (Model)
import Update.Archivos as UpdateArchivos
import Update.Navegacion as UpdateNavegacion
import Update.Pedidos as UpdatePedidos
import Update.Productos as UpdateProductos


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavMsg navMsg ->
            UpdateNavegacion.update navMsg model

        ArchivoMsg archMsg ->
            UpdateArchivos.update saveState archMsg model

        ProdMsg prodMsg ->
            case prodMsg of
                AgregarProducto ->
                    ( UpdateProductos.update prodMsg model, saveState model )

                EliminarProducto _ ->
                    ( UpdateProductos.update prodMsg model, saveState model )

                ConfirmarEliminarProducto ->
                    ( UpdateProductos.update prodMsg model, saveState model )

                _ ->
                    ( UpdateProductos.update prodMsg model, Cmd.none )

        PedMsg pedMsg ->
            UpdatePedidos.update pedMsg model saveState


saveState : Model -> Cmd Msg
saveState model =
    saveStorage (encodeDatosBase model)


port saveStorage : Encode.Value -> Cmd msg
