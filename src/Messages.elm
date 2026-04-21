module Messages exposing (ArchivoMsg(..), Msg(..), NavegacionMsg(..), PedidoMsg(..), ProductoMsg(..))

import Browser
import Url exposing (Url)


type Msg
    = NavMsg NavegacionMsg
    | ProdMsg ProductoMsg
    | PedMsg PedidoMsg
    | ArchivoMsg ArchivoMsg


type NavegacionMsg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | IrAInicio
    | IrAGestionProductos
    | IrAListadoPedidos
    | IrAEditarPedido Int


type ProductoMsg
    = InputNombreProducto String
    | InputPrecioProducto String
    | InputBusqueda String
    | AgregarProducto
    | EliminarProducto Int
    | PedirEliminarProducto Int
    | ConfirmarEliminarProducto
    | CancelarEliminarProducto
    | EditarProducto Int


type PedidoMsg
    = AgregarPedido
    | EliminarPedido Int
    | AgregarItemAPedido Int
    | CambiarCantidadItem Int String
    | PedirEliminarItem Int
    | ConfirmarEliminarItem
    | CancelarEliminarItem
    | GuardarPedido
    | EntregarPedido
    | CancelarEdicionPedido


type ArchivoMsg
    = ExportarAPDF
    | ExportarProductosCSV
    | ExportarPedidosCSV
    | CargarProductosCSV
    | ContenidoCSVRecibido String
