-- Translated by: Cisneros

local PAC = PersonalAssistant.Constants
local PABStrings = {
    -- =================================================================================================================
    -- Textos específicos del idioma que necesitan ser traducidos --

    -- =================================================================================================================
    -- == TEXTOS DE MENÚ/PANEL == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Menú de PABanking --
    SI_PA_MENU_BANKING_DESCRIPTION = "PABanking puede mover divisas, objetos de artesanía y otros ítems entre la mochila de tu personaje y el banco",

    -- Divisas --
    SI_PA_MENU_BANKING_CURRENCY_HEADER = GetString(SI_INVENTORY_CURRENCIES),
    SI_PA_MENU_BANKING_CURRENCY_ENABLE = table.concat({"Habilitar Banco Automático para ", GetString(SI_INVENTORY_CURRENCIES)}),
    SI_PA_MENU_BANKING_CURRENCY_MINTOKEEP = "Mínimo a mantener en el personaje",
    SI_PA_MENU_BANKING_CURRENCY_MAXTOKEEP = "Maximum to keep on character", -- Se mantiene en inglés como referencia si no se requiere traducir, o "Máximo a mantener en el personaje"

    -- Objetos de artesanía --
    SI_PA_MENU_BANKING_CRAFTING_HEADER = "Objetos de artesanía",
    SI_PA_MENU_BANKING_CRAFTING_ENABLE = "Habilitar Banco Automático para objetos de artesanía",
    SI_PA_MENU_BANKING_CRAFTING_ENABLE_T = "¿Habilitar depósito y retiro automático en el banco para los diferentes objetos de artesanía?",
    SI_PA_MENU_BANKING_CRAFTING_DESCRIPTION = "Define un comportamiento individual (depositar, retirar o no hacer nada) para los objetos de artesanía",
    SI_PA_MENU_BANKING_CRAFTING_ESOPLUS_DESC = "Como miembro de ESO Plus, el depósito/retiro de materiales de artesanía no es relevante, ya que todos pueden llevarse en cantidad infinita en el arcón de artesanía",
    SI_PA_MENU_BANKING_CRAFTING_GLOBAL_MOVEMODE = "Cambiar todos los menús desplegables de objetos de artesanía a",
    SI_PA_MENU_BANKING_CRAFTING_GLOBAL_MOVEMODE_T = "Cambia todos los valores de los menús desplegables de objetos de artesanía a 'Depositar en el banco', 'Retirar a la mochila' o 'No hacer nada'",

    -- Objetos Especiales --
    SI_PA_MENU_BANKING_ADVANCED_HEADER = "Objetos Especiales",
    SI_PA_MENU_BANKING_ADVANCED_ENABLE = "Habilitar Banco Automático para Objetos Especiales",
    SI_PA_MENU_BANKING_ADVANCED_ENABLE_T = "¿Habilitar depósito y retiro automático en el banco para los diferentes objetos especiales?",
    SI_PA_MENU_BANKING_ADVANCED_DESCRIPTION = "Define un comportamiento individual (depositar, retirar o no hacer nada) para los objetos especiales",

    SI_PA_MENU_BANKING_ADVANCED_GLOBAL_MOVEMODE = "Cambiar todos los menús desplegables de objetos especiales a",
    SI_PA_MENU_BANKING_ADVANCED_GLOBAL_MOVEMODE_T = "Cambia todos los valores de los menús desplegables de objetos especiales a 'Depositar en el banco', 'Retirar a la mochila' o 'No hacer nada'",

    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE8 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Motivos Conocidos"}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE29 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Recetas Conocidas"}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE8 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Motivos Desconocidos"}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE29 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Recetas Desconocidas"}),

    -- Objetos Individuales --
    SI_PA_MENU_BANKING_INDIVIDUAL_HEADER = "Objetos Individuales",
    SI_PA_MENU_BANKING_INDIVIDUAL_DISABLED_DESCRIPTION = table.concat({"Con la introducción de reglas bancarias personalizadas, la configuración \"Individual\" ha sido migrada allí. ", GetString(SI_PA_MENU_RULES_HOW_TO_ADD_PAB), "\n\n", GetString(SI_PA_MENU_RULES_HOW_TO_FIND_MENU)}),

    -- Objetos de AvA --
    SI_PA_MENU_BANKING_AVA_HEADER = "Objetos de AvA",
    SI_PA_MENU_BANKING_AVA_ENABLE = "Habilitar Banco Automático para Objetos de AvA",
    SI_PA_MENU_BANKING_AVA_ENABLE_T = "¿Habilitar depósito y retiro automático en el banco para los diferentes objetos de Alianza contra Alianza (AvA)?",
    SI_PA_MENU_BANKING_AVA_DESCRIPTION = "Define la cantidad de diferentes objetos de Alianza contra Alianza (AvA) que te gustaría mantener en tu inventario",
    SI_PA_MENU_BANKING_AVA_OTHER_HEADER = "Otros",

    -- Otras Configuraciones --
    SI_PA_MENU_BANKING_AUTO_ITEM_TRANSFER_EXECUTION = "Ejecución automática de transferencias de ítems de PABanking",
    SI_PA_MENU_BANKING_AUTO_ITEM_TRANSFER_EXECUTION_T = "¿Ejecutar automáticamente todas las transferencias de ítems entre la mochila y el banco al acceder al banco? Si está desactivado, aún puedes ejecutar una transferencia de ítems de PABanking manualmente en la interfaz del banco",

    SI_PA_MENU_BANKING_OTHER_DEPOSIT_STACKING = "Regla de apilamiento al depositar",
    SI_PA_MENU_BANKING_OTHER_DEPOSIT_STACKING_T = "Define si se deben depositar todos los ítems, o solo cuando haya pilas existentes que puedan completarse",
    SI_PA_MENU_BANKING_OTHER_WITHDRAWAL_STACKING = "Regla de apilamiento al retirar",
    SI_PA_MENU_BANKING_OTHER_WITHDRAWAL_STACKING_T = "Define si se deben retirar todos los ítems, o solo cuando haya pilas existentes que puedan completarse",

    SI_PA_MENU_BANKING_EXCLUDE_JUNK = "No mover ítems marcados como basura",

    SI_PA_MENU_BANKING_OTHER_AUTOSTACKBAGS = "Apilar automáticamente todos los ítems al abrir el banco",
    SI_PA_MENU_BANKING_OTHER_AUTOSTACKBAGS_T = "¿Apilar automáticamente todos los ítems en el banco y en la mochila al acceder al banco? Ayuda a mantener todo mejor organizado",

    -- Definiciones genéricas para cualquier tipo --
    SI_PA_MENU_BANKING_ANY_CURRENCY_ENABLE = "Depositar/Retirar %s",

    SI_PA_MENU_BANKING_ANY_KEEPINBACKPACK = "Cantidad a mantener",
    SI_PA_MENU_BANKING_ANY_KEEPINBACKPACK_T = "Define la cantidad que (según el operador matemático) se mantendrá en el banco o en la mochila",

    SI_PA_MENU_BANKING_ANY_MINTOKEEP_T = "Cantidad mínima de %s para mantener siempre en el personaje; si es necesario, con retiros adicionales del banco",
    SI_PA_MENU_BANKING_ANY_MAXTOKEEP_T = "Cantidad máxima de %s para mantener siempre en el personaje; todo lo que supere esta cantidad se depositará en el banco",

    SI_PA_MENU_BANKING_ANY_GLOBAL_MOVEMODE_W = "Esto no se puede deshacer; todos los valores seleccionados individualmente se perderán",

    -- =================================================================================================================
    -- == TEXTOS DEL MENÚ PRINCIPAL == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_PA_MAINMENU_BANKING_HEADER = "Reglas Bancarias",

    SI_PA_MAINMENU_BANKING_HEADER_CATEGORY = "C", -- Primera letra de "Categoría"
    SI_PA_MAINMENU_BANKING_HEADER_BAG = "Ubicación",
    SI_PA_MAINMENU_BANKING_HEADER_RULE = "Regla",
    SI_PA_MAINMENU_BANKING_HEADER_AMOUNT = "Cantidad",
    SI_PA_MAINMENU_BANKING_HEADER_ITEM = "Ítem",
    SI_PA_MAINMENU_BANKING_HEADER_ACTIONS = "Acciones",

    -- =================================================================================================================
    -- == OTROS TEXTOS PARA MENÚ == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Descripción de Agregar Regla Personalizada de PABanking --
    SI_PA_DIALOG_BANKING_BANK_EXACTLY_PRE = "El %s debe tener exactamente %d del ítem seleccionado.",
    SI_PA_DIALOG_BANKING_BANK_LESSTHANOREQUAL_PRE = "El %s debe tener como máximo %d del ítem seleccionado.",
    SI_PA_DIALOG_BANKING_BANK_GREATERTHANOREQUAL_PRE = "El %s debe tener al menos %d del ítem seleccionado.",
    SI_PA_DIALOG_BANKING_BANK_EXACTLY_NOTHING = "> %d en tu %s => no pasa nada.",
    SI_PA_DIALOG_BANKING_BANK_EXACTLY_DEPOSIT = "> %d en tu %s => transfiere ítems al %s hasta que haya %d.",
    SI_PA_DIALOG_BANKING_BANK_FROM_TO_NOTHING = "> %d - %d en tu %s => no pasa nada.",
    SI_PA_DIALOG_BANKING_BANK_FROM_TO_DEPOSIT = "> %d - %d en tu %s => transfiere ítems al %s hasta que haya %d.",
    SI_PA_DIALOG_BANKING_BANK_FROM_TO_WITHDRAW = "> %d - %d en tu %s => transfiere ítems del %s hasta que queden %d.",

    SI_PA_DIALOG_BANKING_BACKPACK_EXACTLY_PRE = "El %s debe tener exactamente %d del ítem seleccionado.",
    SI_PA_DIALOG_BANKING_BACKPACK_LESSTHANOREQUAL_PRE = "El %s debe tener como máximo %d del ítem seleccionado.",
    SI_PA_DIALOG_BANKING_BACKPACK_GREATERTHANOREQUAL_PRE = "El %s debe tener al menos %d del ítem seleccionado.",
    SI_PA_DIALOG_BANKING_BACKPACK_EXACTLY_NOTHING = "> %d en tu %s => no pasa nada.",
    SI_PA_DIALOG_BANKING_BACKPACK_EXACTLY_DEPOSIT = "> %d en tu %s => transfiere ítems al %s hasta que haya %d.",
    SI_PA_DIALOG_BANKING_BACKPACK_FROM_TO_NOTHING = "> %d - %d en tu %s => no pasa nada.",
    SI_PA_DIALOG_BANKING_BACKPACK_FROM_TO_DEPOSIT = "> %d - %d en tu %s => transfiere ítems al %s hasta que haya %d.",
    SI_PA_DIALOG_BANKING_BACKPACK_FROM_TO_WITHDRAW = "> %d - %d en tu %s => transfiere ítems del %s hasta que queden %d.",

    SI_PA_DIALOG_BANKING_EXPLANATION = "Esto significa, si tienes . . .",

    -- =================================================================================================================
    -- == SALIDAS DE CHAT == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_PA_CHAT_BANKING_FINISHED = "Todas las transferencias de ítems completadas",

    SI_PA_CHAT_BANKING_WITHDRAWAL_COMPLETE = "%s retirados",
    SI_PA_CHAT_BANKING_WITHDRAWAL_PARTIAL_SOURCE = "%s / %s retirados (El banco está vacío)",
    SI_PA_CHAT_BANKING_WITHDRAWAL_PARTIAL_TARGET = "%s / %s retirados (No hay suficiente espacio en el personaje)",

    SI_PA_CHAT_BANKING_DEPOSIT_COMPLETE = "%s depositados",
    SI_PA_CHAT_BANKING_DEPOSIT_PARTIAL_SOURCE = "%s / %s depositados (El personaje está vacío)",
    SI_PA_CHAT_BANKING_DEPOSIT_PARTIAL_TARGET = "%s / %s depositados (No hay suficiente espacio en el banco)",

    SI_PA_CHAT_BANKING_ITEMS_MOVED_COMPLETE = "%d x %s movidos a %s",
    SI_PA_CHAT_BANKING_ITEMS_NOT_MOVED_OUTOFSPACE = "No se pudo mover %s a %s. ¡No hay suficiente espacio!",
    SI_PA_CHAT_BANKING_ITEMS_NOT_MOVED_BANKCLOSED = "No se pudo mover %s a %s. ¡La ventana estaba cerrada!",
    SI_PA_CHAT_BANKING_ITEMS_SKIPPED_LWC = "Algunos ítems NO se depositaron para evitar posibles interferencias con Dolgubon's Lazy Writ Crafter",

    SI_PA_CHAT_BANKING_RULES_ADDED = table.concat({"¡La regla para %s ha sido ", PAC.COLOR.ORANGE:Colorize("agregada"), "!"}),
    SI_PA_CHAT_BANKING_RULES_UPDATED = table.concat({"¡La regla para %s ha sido ", PAC.COLOR.ORANGE:Colorize("actualizada"), "!"}),
    SI_PA_CHAT_BANKING_RULES_DELETED = table.concat({"¡La regla para %s ha sido ", PAC.COLOR.ORANGE:Colorize("eliminada"), "!"}),
    SI_PA_CHAT_BANKING_RULES_ENABLED = table.concat({"¡La regla para %s ha sido ", PAC.COLOR.ORANGE:Colorize("habilitada"), "!"}),
    SI_PA_CHAT_BANKING_RULES_DISABLED = table.concat({"¡La regla para %s ha sido ", PAC.COLOR.ORANGE:Colorize("deshabilitada"), "!"}),

    -- =================================================================================================================
    -- == ASIGNACIONES DE TECLAS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_BINDING_NAME_PA_BANKING_EXECUTE_ITEM_TRANSFERS = "Ejecutar PABanking",
    SI_BINDING_NAME_PA_BANKING_EXECUTE_ITEM_TRANSFERS_PENDING = "PABanking en ejecución...",
}

for key, value in pairs(PABStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end