module Messages exposing (Msg(..))

import Browser
import Url exposing (Url)


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | InputNombreProducto String
    | InputPrecioProducto String
    | InputBusqueda String
    | AgregarProducto
    | EliminarProducto Int
    | PedirEliminarProducto Int
    | ConfirmarEliminarProducto
    | CancelarEliminarProducto
    | EditarProducto Int
    | AgregarPedido
    | EliminarPedido Int
    | AgregarItemAPedido Int Int
    | CambiarCantidadItem Int Int String
    | PedirEliminarItem Int Int
    | ConfirmarEliminarItem
    | CancelarEliminarItem
    | IrAInicio
    | IrAGestionProductos
    | IrAListadoPedidos
    | IrAEditarPedido Int
    | ExportarAPDF
    | ExportarProductosCSV
    | ExportarPedidosCSV
    | CargarProductosCSV
    | ContenidoCSVRecibido String
