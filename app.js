// Esperar a que el DOM esté listo para inicializar Elm
document.addEventListener("DOMContentLoaded", function() {
    var app = Elm.Main.init({
        node: document.getElementById('elm-app')
    });
});
