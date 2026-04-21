module Types exposing (Estado(..), InterfazEstado(..), Item, Model, Pagina(..), Pedido, Producto, estadoToString, initModel)

import Browser.Navigation as Nav
import Url exposing (Url)


type Estado
    = Borrador
    | Entregado


type Pagina
    = Inicio
    | GestionProductos
    | ListadoPedidos
    | EditandoPedido Int


type InterfazEstado
    = Normal
    | EditandoProducto Int
    | ConfirmandoEliminarItem { pedidoId : Int, productoId : Int }
    | ConfirmandoEliminarProducto Int


type alias Producto =
    { id : Int
    , nombre : String
    , precio : Float
    }


type alias ProductoSnapshot =
    { nombre : String
    , precio : Float
    }


type alias Item =
    { productoId : Int
    , snapshot : ProductoSnapshot
    , cantidad : Int
    }


type alias FormularioProducto =
    { nombre : String
    , precio : String
    }


type alias Pedido =
    { id : Int
    , items : List Item
    , estado : Estado
    , fechaEntrega : Maybe String
    }


type alias Model =
    { key : Nav.Key
    , url : Url
    , catalogo : List Producto
    , pedidos : List Pedido
    , nextProductoId : Int
    , nextPedidoId : Int
    , nuevoProducto : FormularioProducto
    , busquedaProducto : String
    , interfaz : InterfazEstado
    , paginaActual : Pagina
    }


initModel : Nav.Key -> Url -> Model
initModel key url =
    { key = key
    , url = url
    , catalogo = []
    , pedidos = []
    , nextProductoId = 1
    , nextPedidoId = 1
    , nuevoProducto = { nombre = "", precio = "" }
    , busquedaProducto = ""
    , interfaz = Normal
    , paginaActual = Inicio
    }


estadoToString : Estado -> String
estadoToString estado =
    case estado of
        Borrador ->
            "Borrador"

        Entregado ->
            "Entregado"
