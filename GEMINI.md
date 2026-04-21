# GEMINI.md

Este archivo documenta quirks, configuraciones y preferencias técnicas para interactuar con este proyecto usando Gemini CLI en un entorno Windows.

## Comandos y Shell
- **PowerShell:** No admite el operador `&&` para encadenar comandos. Se debe utilizar el formato de comandos separados por una nueva línea o el operador `;` (aunque se recomienda separar en múltiples ejecuciones para mejor manejo de errores).
  - *Incorrecto:* `comando1 && comando2`
  - *Correcto:* `comando1; comando2` o simplemente comandos separados.
  este proyecto usa Bun en ves de npm

## Configuración del Proyecto
- **Persistencia de Estado:** La aplicación utiliza un puerto `saveStorage` para persistir todo el modelo de datos (`catalogo`, `pedidos`, `nextProductoId`) en `localStorage` bajo la clave `facturasData`.
- **Servidor Local:** Se utiliza `bun run serve` para levantar el servidor de desarrollo en `http://localhost:8080`.
- **Build:** La compilación manual de Elm se realiza mediante `elm make src/Main.elm --output=main.js`.

