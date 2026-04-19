module Types exposing (Estado(..), Item, Model, Pagina(..), Pedido, Producto, estadoToString, initModel)

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


type alias Producto =
    { id : Int
    , nombre : String
    , precio : Float
    }


type alias Item =
    { productoId : Int
    , nombreSnapshot : String
    , precioSnapshot : Float
    , cantidad : Int
    }


type alias Pedido =
    { id : Int
    , items : List Item
    , estado : Estado
    }


type alias Model =
    { key : Nav.Key
    , url : Url
    , catalogo : List Producto
    , pedidos : List Pedido
    , nextProductoId : Int
    , nextPedidoId : Int
    , nuevoProductoNombre : String
    , nuevoProductoPrecio : String
    , busquedaProducto : String
    , productoEditando : Maybe Int
    , confirmarEliminacionItem : Maybe { pedidoId : Int, productoId : Int }
    , confirmarEliminacionProducto : Maybe Int
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
    , nuevoProductoNombre = ""
    , nuevoProductoPrecio = ""
    , busquedaProducto = ""
    , productoEditando = Nothing
    , confirmarEliminacionItem = Nothing
    , confirmarEliminacionProducto = Nothing
    , paginaActual = Inicio
    }


estadoToString : Estado -> String
estadoToString estado =
    case estado of
        Borrador ->
            "Borrador"

        Entregado ->
            "Entregado"
