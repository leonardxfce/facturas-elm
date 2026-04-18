module Types exposing (Estado(..), Item, Model, Pagina(..), Pedido, Producto, estadoToString, initialModel)


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
    , cantidad : Int
    }


type alias Pedido =
    { id : Int
    , items : List Item
    , estado : Estado
    }


type alias Model =
    { catalogo : List Producto
    , pedidos : List Pedido
    , nextProductoId : Int
    , nextPedidoId : Int
    , nuevoProductoNombre : String
    , nuevoProductoPrecio : String
    , busquedaProducto : String
    , productoEditando : Maybe Int
    , paginaActual : Pagina
    }


initialModel : Model
initialModel =
    { catalogo = []
    , pedidos = []
    , nextProductoId = 1
    , nextPedidoId = 1
    , nuevoProductoNombre = ""
    , nuevoProductoPrecio = ""
    , busquedaProducto = ""
    , productoEditando = Nothing
    , paginaActual = Inicio
    }


estadoToString : Estado -> String
estadoToString estado =
    case estado of
        Borrador ->
            "Borrador"

        Entregado ->
            "Entregado"
