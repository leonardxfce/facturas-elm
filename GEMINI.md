# GEMINI.md

Este archivo documenta quirks, configuraciones y preferencias técnicas para interactuar con este proyecto usando Gemini CLI en un entorno Windows.

## Comandos y Shell
- **PowerShell:** No admite el operador `&&` para encadenar comandos. Se debe utilizar el formato de comandos separados por una nueva línea o el operador `;` (aunque se recomienda separar en múltiples ejecuciones para mejor manejo de errores).
  - *Incorrecto:* `comando1 && comando2`
  - *Correcto:* `comando1; comando2` o simplemente comandos separados.

## Configuración del Proyecto
- **Persistencia de Estado:** La aplicación utiliza un puerto `saveStorage` para persistir todo el modelo de datos (`catalogo`, `pedidos`, `nextProductoId`) en `localStorage` bajo la clave `facturasData`.
- **Servidor Local:** Se utiliza `bun run serve` para levantar el servidor de desarrollo en `http://localhost:8080`.
- **Build:** La compilación manual de Elm se realiza mediante `elm make src/Main.elm --output=main.js`.

## Historial de Cambios

### 18 de Abril de 2026
- Refactorización a estructura SPA: Separación en Dashboard, Gestión de Productos y Gestión de Pedidos.
- Implementación de navegación dedicada para la edición de pedidos (aislamiento de estado de búsqueda).
- Mejora en ABM de pedidos: Alta, Baja y edición de ítems.
- Validación de datos: Impedir creación de productos vacíos o con precios inválidos.
- Mejora de UI: Deshabilitación de botones según validez y filtrado inteligente del catálogo.
- **Calidad de Código:** Configuración e instalación de `elm-format` y `elm-review` con reglas estrictas (código muerto, buenas prácticas, simplificación).
- **Entorno:** Optimización de `.gitignore` y estandarización del flujo de trabajo con `bun`.

