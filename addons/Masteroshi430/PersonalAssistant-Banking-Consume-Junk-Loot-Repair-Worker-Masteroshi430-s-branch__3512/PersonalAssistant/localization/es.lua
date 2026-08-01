-- Translated by: Cisneros

local PAC = PersonalAssistant.Constants
local PAStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Profile Settings --
    SI_PA_MENU_PROFILE_PLEASE_SELECT = "<Por favor, selecciona Perfil>",
    SI_PA_MENU_PROFILE_ACTIVE = "Perfil activo",
    SI_PA_MENU_PROFILE_ACTIVE_T = "Selecciona el perfil activo para el Asistente Personal. Cargará automáticamente todas las configuraciones almacenadas bajo ese perfil y los cambios se guardarán en el mismo lugar.",
    SI_PA_MENU_PROFILE_ACTIVE_RENAME = "Renombrar perfil activo",

    -- Create Profiles --
    SI_PA_MENU_PROFILE_CREATE_NEW = "Crear nuevo perfil",
    SI_PA_MENU_PROFILE_CREATE_NEW_DESC = table.concat({"Nota: Puedes tener un máximo de ", PAC.GENERAL.MAX_PROFILES, " perfiles."}),

    -- Copy Profiles --
    SI_PA_MENU_PROFILE_COPY_FROM_DESC = "Copiar la configuración de un perfil existente al perfil actualmente activo.",
    SI_PA_MENU_PROFILE_COPY_FROM = "Copiar desde el perfil",
    SI_PA_MENU_PROFILE_COPY_FROM_CONFIRM = "Confirmar copia",
    SI_PA_MENU_PROFILE_COPY_FROM_CONFIRM_W = "Esto reemplazará la configuración del perfil activo con la configuración del perfil seleccionado. ¿Estás seguro de que quieres hacer eso? \n\nNota: Solo se copiarán las configuraciones de los módulos del Asistente Personal que estén habilitados.",

    -- Delete Profiles --
     SI_PA_MENU_PROFILE_DELETE_DESC = "Eliminar perfiles existentes y no utilizados de la base de datos para ahorrar espacio y limpiar el archivo SavedVariables.",
    SI_PA_MENU_PROFILE_DELETE = "Eliminar un perfil",
    SI_PA_MENU_PROFILE_DELETE_CONFIRM = "Confirmar eliminación",
    SI_PA_MENU_PROFILE_DELETE_CONFIRM_W = "Esto eliminará el perfil seleccionado para todos los personajes. ¿Estás seguro de que quieres hacer eso?",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Rules Menu --
    SI_PA_MENU_RULES_HOW_TO_ADD_PAB = "Para crear una nueva regla para depositar y retirar artículos, simplemente haz clic derecho en un artículo en tu inventario o banco y selecciona en el menú contextual:\n> PA Banking > Añadir nueva regla",
    SI_PA_MENU_RULES_HOW_TO_ADD_PAJ = "Para crear una nueva regla para marcar permanentemente un artículo como basura, simplemente haz clic derecho en un artículo en tu inventario o banco y selecciona en el menú contextual:\n> PA Junk > Marcar como basura permanente",
    SI_PA_MENU_RULES_HOW_TO_FIND_MENU = table.concat({"Puedes encontrar todas las reglas activas a través del icono en el menú principal superior que puedes abrir con la tecla [Alt], con ", PAC.COLOR.YELLOW:Colorize("/parules"), " o haciendo clic en este botón:"}),
    SI_PA_MENU_RULES_HOW_TO_CREATE = "¿Cómo crear nuevas reglas?",

    SI_PA_MENU_DANGEROUS_SETTING = "ADVERTENCIA: ¡Configuración peligrosa por delante! ¡Úselo bajo su propio riesgo!",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Generic Menu --
    SI_PA_MENU_OTHER_SETTINGS_HEADER = "Otras Configuraciones",

    SI_PA_MENU_SILENT_MODE = "Modo silencioso (Desactiva todos los mensajes)",

    SI_PA_MENU_NOT_YET_IMPLEMENTED = table.concat({PAC.COLORS.RED, "¡Aún no implementado!"}),

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAGeneral --
    SI_PA_CHAT_GENERAL_NEW_PROFILE_CREATED = table.concat({" nuevo perfil ", PAC.COLOR.WHITE:Colorize("%s"), " creado y activado!"}),
    SI_PA_CHAT_GENERAL_SELECTED_PROFILE_COPIED = table.concat({" configuraciones del perfil ", PAC.COLOR.WHITE:Colorize("%s"), " han sido ", PAC.COLOR.ORANGE_RED:Colorize("copiadas"), " al perfil activo ", PAC.COLOR.WHITE:Colorize("%s")}),
    SI_PA_CHAT_GENERAL_SELECTED_PROFILE_DELETED = table.concat({" perfil seleccionado ", PAC.COLOR.WHITE:Colorize("%s"), " ha sido ", PAC.COLOR.ORANGE_RED:Colorize("eliminado!")}),

    SI_PA_CHAT_GENERAL_TELEPORT_NO_PRIMARY_HOUSE = table.concat({"Necesitas seleccionar una casa como tu ", PAC.COLOR.ORANGE_RED:Colorize("Casa Principal"), " primero"}),
    SI_PA_CHAT_GENERAL_TELEPORT_ZONE_PREVENTED = table.concat({"Tu ubicación actual ", PAC.COLOR.ORANGE_RED:Colorize("no permite"), " el viaje rápido a tu casa"}),

    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAGeneral --
    SI_PA_PROFILE = "Perfil",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Name Spaces --
    SI_PA_NS_BAG_EQUIPMENT = "", -- not required so far
    SI_PA_NS_BAG_BACKPACK = "Mochila",
    SI_PA_NS_BAG_BANK = "Banco",
    SI_PA_NS_BAG_SUBSCRIBER_BANK = "Banco ESO Plus",
    SI_PA_NS_BAG_VIRTUAL = "Arcón de artesanía",
    SI_PA_NS_BAG_HOUSE_BANK = "Almacenamiento en el Hogar",
    SI_PA_NS_BAG_HOUSE_BANK_NR = "Almacenamiento en el Hogar (%d)",
    SI_PA_NS_BAG_UNKNOWN = "Desconocido",

    -- -----------------------------------------------------------------------------------------------------------------
    -- ItemTypes (Custom Singluar/Plural definition) --
    SI_PA_ITEMTYPE4 = "<<1[Comida/Comidas]>>",
    SI_PA_ITEMTYPE5 = "<<1[Trofeo/Trofeos]>>",
    SI_PA_ITEMTYPE7 = "<<1[Poción/Pociones]>>",
    SI_PA_ITEMTYPE8 = "<<1[Motivo/Motivos]>>",
    SI_PA_ITEMTYPE10 = "<<1[Ingrediente/Ingredientes]>>",
    SI_PA_ITEMTYPE12 = "<<1[Bebida/Bebidas]>>",
    SI_PA_ITEMTYPE16 = "<<1[Cebo/Cebos]>>",
    SI_PA_ITEMTYPE19 = "<<1[Gema de alma/Gemas de alma]>>",
    SI_PA_ITEMTYPE22 = "<<1[Ganzúa/Ganzúas]>>",
    SI_PA_ITEMTYPE29 = "<<1[Receta/Recetas]>>",
    SI_PA_ITEMTYPE30 = "<<1[Veneno/Venenos]>>",
    SI_PA_ITEMTYPE33 = "<<1[Disolvente/Disolventes]>>",
    SI_PA_ITEMTYPE34 = "<<1[Coleccionable/Coleccionables]>>",
    SI_PA_ITEMTYPE47 = "<<1[Reparación AvA/Reparaciones AvA]>>",
    SI_PA_ITEMTYPE56 = "<<1[Tesoro/Tesoros]>>",
    SI_PA_ITEMTYPE60 = "<<1[Encargo maestro/Encargos maestro]>>",

    -- -----------------------------------------------------------------------------------------------------------------
    -- SpecializedItemTypes (Custom Singluar/Plural definition) --
    SI_PA_SPECIALIZEDITEMTYPE102 = "<<1[Fragmento/Fragmentos]>>",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Master Writs based on CraftingType (Custom definition) --
    SI_PA_MASTERWRIT_CRAFTINGTYPE0 = table.concat({"Otros encargos (", GetString("SI_ENCHANTMENTSEARCHCATEGORYTYPE", ENCHANTMENT_SEARCH_CATEGORY_OTHER), ")"}),
    SI_PA_MASTERWRIT_CRAFTINGTYPE1 = "Encargo de Herrería Sellado",
    SI_PA_MASTERWRIT_CRAFTINGTYPE2 = "Encargo de Sastrería Sellado",
    SI_PA_MASTERWRIT_CRAFTINGTYPE3 = "Encargo de Encantamiento Sellado",
    SI_PA_MASTERWRIT_CRAFTINGTYPE4 = "Encargo de Alquimia Sellado",
    SI_PA_MASTERWRIT_CRAFTINGTYPE5 = "Encargo de Cocina Sellado",
    SI_PA_MASTERWRIT_CRAFTINGTYPE6 = "Encargo de Carpintería Sellado",
    SI_PA_MASTERWRIT_CRAFTINGTYPE7 = "Encargo de Joyería Sellado",

    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_PA_BANKING_MOVE_MODE_DONOTHING = "No hacer nada",
    SI_PA_BANKING_MOVE_MODE_TOBANK = "Depositar en el banco",
    SI_PA_BANKING_MOVE_MODE_TOBACKPACK = "Retirar a la mochila",

    SI_PA_MENU_BANKING_ADVANCED_GLYPHS = "Glifos",
    SI_PA_MENU_BANKING_ADVANCED_INTRICATE_ITEMS = "Objetos Intrincados",
    SI_PA_MENU_BANKING_ADVANCED_ORNATE_ITEMS = "Objetos Ornamentados",

    SI_PA_MENU_BANKING_REPAIRKIT = "Kits de Reparación",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Operators --
   SI_PA_REL_OPERATOR_T = "Selecciona el Operador Matemático para este artículo",
    SI_PA_REL_BACKPACK_EQUAL = "MOCHILA ==",
    SI_PA_REL_BACKPACK_LESSTHAN = "MOCHILA <", -- not used so far
    SI_PA_REL_BACKPACK_LESSTHANEQUAL = "MOCHILA <=",
    SI_PA_REL_BACKPACK_GREATERTHAN = "MOCHILA >", -- not used so far
    SI_PA_REL_BACKPACK_GREATERTHANEQUAL = "MOCHILA >=",
    SI_PA_REL_BANK_EQUAL = "BANCO ==",
    SI_PA_REL_BANK_LESSTHAN = "BANCO <", -- not used so far
    SI_PA_REL_BANK_LESSTHANOREQUAL = "BANCO <=",
    SI_PA_REL_BANK_GREATERTHAN = "BANCO >", -- not used so far
    SI_PA_REL_BANK_GREATERTHANOREQUAL = "BANCO >=",


    -- -----------------------------------------------------------------------------------------------------------------
    -- Operator Tooltip --
    SI_PA_REL_BACKPACK_EQUAL_T = "MOCHILA es igual a (==)",
    SI_PA_REL_BACKPACK_LESSTHAN_T = "MOCHILA es menor que (<)", -- not used so far
    SI_PA_REL_BACKPACK_LESSTHANOREQUAL_T = "MOCHILA es menor o igual a (<=)",
    SI_PA_REL_BACKPACK_GREATERTHAN_T = "MOCHILA es mayor que (>)", -- not used so far
    SI_PA_REL_BACKPACK_GREATERTHANOREQUAL_T = "MOCHILA es mayor o igual a (>=)",
    SI_PA_REL_BANK_EQUAL_T = "BANCO es igual a (==)",
    SI_PA_REL_BANK_LESSTHAN_T = "BANCO es menor que (<)", -- not used so far
    SI_PA_REL_BANK_LESSTHANOREQUAL_T = "BANCO es menor o igual a (<=)",
    SI_PA_REL_BANK_GREATERTHAN_T = "BANCO es mayor que (>)", -- nnot used so far
    SI_PA_REL_BANK_GREATERTHANOREQUAL_T = "BANCO es mayor o igual a (>=)",


    -- -----------------------------------------------------------------------------------------------------------------
    -- Text Operators --
    SI_PA_REL_TEXT_OPERATOR0 = "-",
    SI_PA_REL_TEXT_OPERATOR1 = "tiene exactamente",
    SI_PA_REL_TEXT_OPERATOR2 = "tiene menos de", -- no usado hasta ahora
    SI_PA_REL_TEXT_OPERATOR3 = "tiene como máximo",
    SI_PA_REL_TEXT_OPERATOR4 = "tiene más de", -- no usado hasta ahora
    SI_PA_REL_TEXT_OPERATOR5 = "tiene al menos",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Stacking types --
    SI_PA_ST_MOVE_FULL = "Mover todo", -- 0: Full deposit
    SI_PA_ST_MOVE_INCOMPLETE_STACKS_ONLY = "Solamente llenar las acumulaciones existentes", -- 1: Fill existing stacks
    SI_PA_ST_MOVE_ONE_STACK_ONLY = "Limitar a un montón por artículo",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Icon Positions --
    SI_PA_POSITION_AUTO = "Automático",
    SI_PA_POSITION_MANUAL = "Manual",

    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk --
   SI_PA_ITEM_ACTION_NOTHING = "No hacer nada",
    SI_PA_ITEM_ACTION_LAUNDER = "Blanquear en el Refugio", -- no usado hasta ahora
    SI_PA_ITEM_ACTION_MARK_AS_JUNK = "Marcar como Basura",
    SI_PA_ITEM_ACTION_JUNK_DESTROY_WORTHLESS = "Basura o Destruir si no tiene valor",
    SI_PA_ITEM_ACTION_DESTROY_ALWAYS = "Destruir siempre",

    -- =================================================================================================================
    -- == CUSTOM SUB MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_SUBMENU_PAB_ADD_RULE = "Añadir nueva regla",
    SI_PA_SUBMENU_PAB_EDIT_RULE = "Modificar regla",
    SI_PA_SUBMENU_PAB_DELETE_RULE = "Eliminar regla",
    SI_PA_SUBMENU_PAB_ENABLE_RULE = "Habilitar regla",
    SI_PA_SUBMENU_PAB_DISABLE_RULE = "Deshabilitar regla",
    SI_PA_SUBMENU_PAB_ADD_RULE_BUTTON = "Añadir",
    SI_PA_SUBMENU_PAB_UPDATE_RULE_BUTTON = "Guardar",
    SI_PA_SUBMENU_PAB_DELETE_RULE_BUTTON = "Eliminar",
    SI_PA_SUBMENU_PAB_NO_RULES = "Aún no hay reglas de banca definidas",
    SI_PA_SUBMENU_PAB_DISCLAIMER = "Aviso: Estas reglas personalizadas de banca se ejecutarán después de que todas las otras reglas de Auto Banca (Artesanía, Especiales y Artículos AvA) hayan sido ejecutadas primero.",

    SI_PA_SUBMENU_PAJ_MARK_PERM_JUNK = "Marcar como basura permanente",
    SI_PA_SUBMENU_PAJ_UNMARK_PERM_JUNK = "Desmarcar como basura permanente",
    SI_PA_SUBMENU_PAJ_NO_RULES = "Aún no hay reglas de basura permanente definidas",

    -- =================================================================================================================
    -- == KEY BINDINGS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_KEYBINDINGS_CATEGORY_PA_PROFILES = "Perfiles |cFFD700P|rersonal|cFFD700A|rssistant",
    SI_KEYBINDINGS_CATEGORY_PA_MENU = "Menú de |cFFD700P|rersonal|cFFD700A|rssistant Menú",

    SI_BINDING_NAME_PA_RULES_MAIN_MENU = "Reglas del Asistente Personal",
    SI_BINDING_NAME_PA_RULES_TOGGLE_WINDOW = "Alternar Menú de Reglas de Banca/Basura",
    SI_BINDING_NAME_PA_TRAVEL_TO_HOUSE = "Viajar a la Casa Principal",
}

for key, value in pairs(PAStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end