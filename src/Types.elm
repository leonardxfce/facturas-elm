module Types exposing
    ( Estado(..)
    , FormularioProducto
    , Item
    , Model
    , PageState(..)
    , Pedido
    , PedidoEditPageData
    , Producto
    , ProductoSnapshot
    , ProductosPageData
    , emptyProductosPage
    , estadoToString
    , initModel
    , initPedidoEditPage
    )

import Browser.Navigation as Nav
import Money exposing (Cents)
import Url exposing (Url)


type Estado
    = Borrador
    | Entregado


type alias Producto =
    { id : Int
    , nombre : String
    , precioCents : Cents
    }


type alias ProductoSnapshot =
    { nombre : String
    , precioCents : Cents
    }


type alias Item =
    { productoId : Int
    , snapshot : ProductoSnapshot
    , cantidad : Int
    }


type alias Pedido =
    { id : Int
    , items : List Item
    , estado : Estado
    , fechaEntrega : Maybe String
    }


type alias FormularioProducto =
    { nombre : String
    , precio : String
    }


type alias ProductosPageData =
    { form : FormularioProducto
    , editandoId : Maybe Int
    , confirmandoEliminar : Maybe Int
    }


emptyProductosPage : ProductosPageData
emptyProductosPage =
    { form = { nombre = "", precio = "" }
    , editandoId = Nothing
    , confirmandoEliminar = Nothing
    }


type alias PedidoEditPageData =
    { pedidoId : Int
    , busqueda : String
    , confirmandoEliminarItem : Maybe Int
    }


initPedidoEditPage : Int -> PedidoEditPageData
initPedidoEditPage id =
    { pedidoId = id
    , busqueda = ""
    , confirmandoEliminarItem = Nothing
    }


type PageState
    = InicioPage
    | ProductosPage ProductosPageData
    | PedidosListPage
    | PedidoEditPage PedidoEditPageData


type alias Model =
    { key : Nav.Key
    , url : Url
    , basePath : String
    , catalogo : List Producto
    , pedidos : List Pedido
    , nextProductoId : Int
    , nextPedidoId : Int
    , page : PageState
    }


initModel : String -> Nav.Key -> Url -> Model
initModel basePath key url =
    { key = key
    , url = url
    , basePath = basePath
    , catalogo = []
    , pedidos = []
    , nextProductoId = 1
    , nextPedidoId = 1
    , page = InicioPage
    }


estadoToString : Estado -> String
estadoToString estado =
    case estado of
        Borrador ->
            "Borrador"

        Entregado ->
            "Entregado"
