-- Configuracion de plugins

-- Bordes completos, con las esquinas redondeadas 
require("full-border"):setup {
    type = ui.Border.ROUNDED,
}

-- Abrir archivos al presionar enter
require("smart-enter"):setup {
    open_multi = true
}

-- Mostrar estado de git en yazi
require("git"):setup()
require("githead"):setup()

Header:children_add(function()
    -- Aquí podrías añadir lógica personalizada si no usas el plugin
    -- Pero el plugin githead ya gestiona esto automáticamente tras el setup()
end, 500, Header.LEFT)

