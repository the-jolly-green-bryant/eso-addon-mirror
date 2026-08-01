-- Translated by: Cisneros

local PAC = PersonalAssistant.Constants
local PAStrings = {
    -- =================================================================================================================
    -- Textos específicos del idioma que necesitan ser traducidos --

    -- Mensajes de Bienvenida --
    SI_PA_WELCOME_NO_SUPPORT = "¡a su servicio!   -   no hay traducción disponible para el idioma [%s] (aún)",
    SI_PA_WELCOME_SUPPORT = "¡a su servicio!",
    SI_PA_WELCOME_PLEASE_SELECT_PROFILE = table.concat({"¡te da la bienvenida! Para comenzar, por favor ve a la configuración del complemento y selecciona un perfil. Gracias :-)"}),

    -- =================================================================================================================
    -- == TEXTOS DE MENÚ/PANEL == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_MENU_GENERAL_DESCRIPTION = "PersonalAssistant es una colección de varias funciones que tienen el objetivo de hacer que jugar ESO sea más conveniente para ti.\n\nCada módulo tiene su propia lista de perfiles para toda la cuenta, donde puedes seleccionar para cada personaje cuál debería ser el activo.",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Configuración General --
    SI_PA_MENU_GENERAL_HEADER = "Configuración General",
    SI_PA_MENU_GENERAL_SHOW_WELCOME = "Mostrar mensaje de bienvenida",

    SI_PA_MENU_GENERAL_TELEPORT_HEADER = "Vivienda",
    SI_PA_MENU_GENERAL_TELEPORT_PRIMARY_HOUSE = table.concat({PAC.ICONS.OTHERS.HOME.NORMAL, " Viajar a la casa"}),
    SI_PA_MENU_GENERAL_TELEPORT_PRIMARY_HOUSE_W = "Si la ubicación actual permite viaje rápido, esto iniciará el teletransporte a tu casa principal.",
    SI_PA_MENU_GENERAL_TELEPORT_OUTSIDE = "Viajar frente a la casa",
    SI_PA_MENU_GENERAL_TELEPORT_OUTSIDE_T = "Si está desactivado, viajarás al interior de la casa en su lugar",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Configuración de Administración --
    SI_PA_MENU_ADMIN_HEADER = "Configuración de Administración",
}

for key, value in pairs(PAStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end