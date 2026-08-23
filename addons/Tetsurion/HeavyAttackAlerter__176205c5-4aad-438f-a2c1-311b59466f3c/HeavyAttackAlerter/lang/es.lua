local strings = {
    SI_HAA_PANEL_NAME               = "Heavy Attack Alerter",
    SI_HAA_COMBAT_ONLY_NAME         = "Mostrar solo en combate",
    SI_HAA_COMBAT_ONLY_TIP          = "Oculta el escudo fuera del combate.",
    SI_HAA_SOUND_NAME               = "Sonido de alerta",
    SI_HAA_SOUND_TIP                = "Sonido al comenzar un ataque pesado enemigo.",
    SI_HAA_SOUND_CHAMPION           = "Campana (Puntos de Campeón)",
    SI_HAA_SOUND_DUEL               = "Duelo (Inicio de duelo)",
    SI_HAA_SOUND_QUEST              = "Victoria (Misión completada)",
    SI_HAA_SOUND_NONE               = "Sin sonido",
    SI_HAA_ALPHA_NAME               = "Opacidad del escudo verde (%)",
    SI_HAA_ALPHA_TIP                = "Opacidad del escudo en estado normal.",
    SI_HAA_ALERT_ALPHA_NAME         = "Opacidad del escudo rojo (%)",
    SI_HAA_ALERT_ALPHA_TIP          = "Opacidad del escudo durante una alerta.",
    SI_HAA_SIZE_NAME                = "Tamaño del icono (px)",
    SI_HAA_OFFSET_X_NAME            = "Desplazamiento horizontal (X)",
    SI_HAA_OFFSET_Y_NAME            = "Desplazamiento vertical (Y)",
    SI_HAA_TEST_BUTTON_NAME         = "Probar alerta",
    SI_HAA_TEST_BUTTON_TIP          = "Activa una alerta de prueba de 1.5 segundos con sonido para revisar tus ajustes.",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end