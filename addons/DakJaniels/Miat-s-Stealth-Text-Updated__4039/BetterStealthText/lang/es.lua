local strings =
{
    -- Main state strings
    BETTERSTEALTHTEXT_INVISIBLE = "Invisible",
    BETTERSTEALTHTEXT_REVEALED = "Revelado",
    BETTERSTEALTHTEXT_HIDING = "Ocultándose",

    -- Addon menu and option strings
    BETTERSTEALTHTEXT_ADDON_NAME = "Texto de Sigilo de Miat",
    BETTERSTEALTHTEXT_ADDON_OPTIONS = "Opciones del Texto de Sigilo de Miat",
    BETTERSTEALTHTEXT_ADDON_ENABLED = "COMPLEMENTO ACTIVADO",
    BETTERSTEALTHTEXT_ADDON_ENABLED_TOOLTIP = "ON - activado, OFF - desactivado",
    BETTERSTEALTHTEXT_ACCOUNTWIDE = "Mismos ajustes para todos los personajes",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_TOOLTIP = "ON - Cada personaje tiene el mismo conjunto de ajustes, OFF - Ajustes separados para cada personaje",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_WARNING = "Activar esta opción recargará la interfaz",
    BETTERSTEALTHTEXT_DISPLAY_OPTIONS = "Opciones de visualización",
    BETTERSTEALTHTEXT_SCALE = "Establecer escala del texto de sigilo (%)",
    BETTERSTEALTHTEXT_SCALE_TOOLTIP = "La escala del icono y texto va del 50% al 400% de la escala original",
    BETTERSTEALTHTEXT_STEALTH_COLORS_OPTIONS = "Opciones de colores de sigilo",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE = "Mismo color para los estados de sigilo OCULTO e INVISIBLE",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE_TOOLTIP = "ON - activado (el color OCULTO se aplica a INVISIBLE), OFF - desactivado (ajustes separados para OCULTO e INVISIBLE)",
    BETTERSTEALTHTEXT_HIDDEN_COLOR = "Elegir color para el estado OCULTO",
    BETTERSTEALTHTEXT_HIDDEN_COLOR_TOOLTIP = "Elegir el color del texto para el estado de sigilo OCULTO",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR = "Elegir color para el estado INVISIBLE",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR_TOOLTIP = "Elegir el color del texto para el estado de sigilo INVISIBLE",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE = "Mismo color para los estados de sigilo OCULTO e INVISIBLE casi detectados",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE_TOOLTIP = "ON - activado (el color OCULTO se aplica a INVISIBLE) para estados casi detectados, OFF - desactivado (ajustes separados para OCULTO e INVISIBLE) para estados casi detectados",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR = "Elegir color para el estado OCULTO CASI DETECTADO",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR_TOOLTIP = "Elegir el color del texto para el estado de sigilo OCULTO CASI DETECTADO",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR = "Elegir color para el estado INVISIBLE CASI DETECTADO",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR_TOOLTIP = "Elegir el color del texto para el estado de sigilo INVISIBLE CASI DETECTADO",
    BETTERSTEALTHTEXT_ENABLE_HIDING = "Activar texto 'OCULTÁNDOSE'",
    BETTERSTEALTHTEXT_ENABLE_HIDING_TOOLTIP = "ON - activado, OFF - desactivado",
    BETTERSTEALTHTEXT_HIDING_COLOR = "Elegir color para el estado OCULTÁNDOSE",
    BETTERSTEALTHTEXT_HIDING_COLOR_TOOLTIP = "Elegir el color del texto para el estado de sigilo OCULTÁNDOSE",
    BETTERSTEALTHTEXT_DETECTED_COLOR = "Elegir color para el estado DETECTADO",
    BETTERSTEALTHTEXT_DETECTED_COLOR_TOOLTIP = "Elegir el color del texto para el estado de sigilo DETECTADO",
    BETTERSTEALTHTEXT_REVEALED_COLOR = "Elegir color para el estado REVELADO",
    BETTERSTEALTHTEXT_REVEALED_COLOR_TOOLTIP = "Elegir el color del texto para el estado de sigilo REVELADO",
    BETTERSTEALTHTEXT_DISGUISE_COLORS_OPTIONS = "Opciones de colores de disfraz",
    BETTERSTEALTHTEXT_DISGUISED_COLOR = "Elegir color para el estado DISFRAZADO",
    BETTERSTEALTHTEXT_DISGUISED_COLOR_TOOLTIP = "Elegir el color del texto para el estado de disfraz DISFRAZADO",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR = "Elegir color para el estado SOSPECHOSO",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR_TOOLTIP = "Elegir el color del texto para el estado de disfraz SOSPECHOSO",
    BETTERSTEALTHTEXT_DANGER_COLOR = "Elegir color para el estado PELIGRO",
    BETTERSTEALTHTEXT_DANGER_COLOR_TOOLTIP = "Elegir el color del texto para el estado de disfraz PELIGRO",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR = "Elegir color para el estado DESCUBIERTO",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR_TOOLTIP = "Elegir el color del texto para el estado de disfraz DESCUBIERTO"
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
