-- Translated by: Cisneros

local PAIStrings = {
    -- =================================================================================================================
    -- Textos específicos del idioma que necesitan ser traducidos --

    -- =================================================================================================================
    -- == TEXTOS DE MENÚ/PANEL == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Menú de PAIntegration --
    SI_PA_MENU_INTEGRATION_DESCRIPTION = "PAIntegration puede integrar la funcionalidad de los complementos de PersonalAssistant con otros complementos de terceros como Dolgubon's Lazy Writ Crafter o FCO ItemSaver",
    SI_PA_MENU_INTEGRATION_NOTHING_AVAILABLE = "Actualmente no tienes instalados/habilitados complementos que sean compatibles con PAIntegration",

    -- Conocimiento del Personaje --
    SI_PA_MENU_INTEGRATION_CK_CHARACTER = "Considerar conocido si lo conoce",
    SI_PA_MENU_INTEGRATION_CK_ENABLE = "Habilitar integración con Character Knowledge",
    SI_PA_MENU_INTEGRATION_CK_ENABLE_T = table.concat({"Usar Character Knowledge para determinar si una ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), " o ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " es conocida"}),
    SI_PA_MENU_INTEGRATION_CK_INITIALIZING = "Character Knowledge inicializando ...",

    -- Dolgubon's Lazy Writ Crafter --
    SI_PA_MENU_INTEGRATION_LWC_COMPATIBILITY = "Compatibilidad con Dolgubon's Lazy Writ Crafter",
    SI_PA_MENU_INTEGRATION_LWC_COMPATIBILITY_T = "Cuando tienes misiones de creación de escrituras activas y 'Retirar objetos de escrituras' está habilitado en Dolgubon's Lazy Writ Crafter, entonces para estos objetos se ignora la configuración de 'Depositar en el banco'. Esto es para evitar que los objetos retirados se vuelvan a depositar inmediatamente",

    -- FCO ItemSaver --
    SI_PA_MENU_INTEGRATION_FCOIS_LOCKED_PREVENT_SELLING = "Evitar la venta automática de objetos que están bloqueados",
    SI_PA_MENU_INTEGRATION_FCOIS_LOCKED_PREVENT_MOVING = "Evitar mover objetos que están bloqueados",
    SI_PA_MENU_INTEGRATION_FCOIS_LOCKED_PREVENT_MOVING_T = "Si está activado, los objetos que están bloqueados con FCO ItemSaver no se depositarán en el banco ni se retirarán de él",
    SI_PA_MENU_INTEGRATION_FCOIS_SELL_AUTOSELL_MARKED = "¿Vender automáticamente objetos marcados en Comerciantes/Alguaciles?",
    SI_PA_MENU_INTEGRATION_FCOIS_ITEM_MOVE_MARKED = "¿Mover objetos marcados al acceder al banco?",

    -- =================================================================================================================
    -- == SALIDAS DE CHAT == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAIntegration --

    -- =================================================================================================================
    -- == OTROS TEXTOS PARA MENÚ == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Menú de PAIntegration --
    SI_PA_MENU_INTEGRATION_PAB_REQUIRED = "Configuraciones adicionales se hacen visibles cuando PABanking está habilitado",
    SI_PA_MENU_INTEGRATION_PAJ_REQUIRED = "Configuraciones adicionales se hacen visibles cuando PAJunk está habilitado",

    SI_PA_MENU_INTEGRATION_MORE_TO_COME = "Más integraciones con FCO ItemSaver llegarán en futuras actualizaciones",
}

for key, value in pairs(PAIStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end

local PAIGenericStrings = {
    -- =================================================================================================================
    -- Textos independientes del idioma (no necesitan ser traducidos/copiados a otros idiomas) --

    -- =================================================================================================================
    -- == TEXTOS DE MENÚ/PANEL == --
    -- -----------------------------------------------------------------------------------------------------------------

    -- Conocimiento del Personaje
    SI_PA_MENU_INTEGRATION_CK_HEADER = "Character Knowledge",

    -- Dolgubon's Lazy Writ Crafter --
    SI_PA_MENU_INTEGRATION_LWC_HEADER = "Dolgubon's Lazy Writ Crafter",

    -- FCO ItemSaver --
    SI_PA_MENU_INTEGRATION_FCOIS_HEADER = "FCO Item Saver",
}

for key, value in pairs(PAIGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end