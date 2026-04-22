port module Update exposing (update)

import Json.Encode as Encode
import Messages exposing (Msg(..))
import Persistence exposing (encodeDatosBase)
import Types exposing (Model)
import Update.Archivos as UpdateArchivos
import Update.Navegacion as UpdateNavegacion
import Update.Pedidos as UpdatePedidos
import Update.Pedidos.Items as UpdateItems
import Update.Productos as UpdateProductos


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavMsg navMsg ->
            UpdateNavegacion.update navMsg model

        ProdMsg prodMsg ->
            UpdateProductos.update prodMsg model saveState

        PedMsg pedMsg ->
            UpdatePedidos.update pedMsg model saveState

        ItemMsg itemMsg ->
            UpdateItems.update itemMsg model saveState

        ArchivoMsg archMsg ->
            UpdateArchivos.update saveState archMsg model


saveState : Model -> Cmd Msg
saveState model =
    saveStorage (encodeDatosBase model)


port saveStorage : Encode.Value -> Cmd msg
