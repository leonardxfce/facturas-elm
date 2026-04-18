module Messages exposing (Msg(..))


type Msg
    = InputNombreProducto String
    | InputPrecioProducto String
    | InputBusqueda String
    | AgregarProducto
    | EliminarProducto Int
    | EditarProducto Int
    | AgregarPedido
    | EliminarPedido Int
    | AgregarItemAPedido Int Int
    | IrAInicio
    | IrAGestionProductos
    | IrAListadoPedidos
    | IrAEditarPedido Int
    | ExportarAPDF
    | ExportarCSV
