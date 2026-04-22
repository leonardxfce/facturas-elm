module Messages exposing
    ( ArchivoMsg(..)
    , ItemMsg(..)
    , Msg(..)
    , NavegacionMsg(..)
    , PedidoMsg(..)
    , ProductoMsg(..)
    )

import Browser
import Time
import Url exposing (Url)


type Msg
    = NavMsg NavegacionMsg
    | ProdMsg ProductoMsg
    | PedMsg PedidoMsg
    | ItemMsg ItemMsg
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
    | CrearProducto
    | GuardarEdicionProducto Int
    | EditarProducto Int
    | PedirEliminarProducto Int
    | ConfirmarEliminarProducto
    | CancelarEliminarProducto


type PedidoMsg
    = AgregarPedido
    | EliminarPedido Int
    | GuardarPedido
    | CancelarEdicionPedido
    | IniciarEntregaPedido
    | EntregarPedidoConFecha Time.Posix


type ItemMsg
    = InputBusqueda String
    | AgregarItemAPedido Int
    | CambiarCantidadItem Int String
    | PedirEliminarItem Int
    | ConfirmarEliminarItem
    | CancelarEliminarItem


type ArchivoMsg
    = ExportarAPDF
    | ExportarProductosCSV
    | ExportarPedidosCSV
    | CargarProductosCSV
    | ContenidoCSVRecibido String
