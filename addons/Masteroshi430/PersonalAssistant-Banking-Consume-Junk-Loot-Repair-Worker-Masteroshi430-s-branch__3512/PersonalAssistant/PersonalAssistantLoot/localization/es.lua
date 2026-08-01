-- Translated by: Cisneros

local PAC = PersonalAssistant.Constants
local PALStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_MENU_LOOT_DESCRIPTION = "PALoot puede informarte sobre objetos de interés especial, como recetas desconocidas, motivos o rasgos",
	
	-- PALoot Loot Auto Loot --
    SI_PA_MENU_AUTO_LOOT_HEADER = "Intelligent Auto Loot",
    SI_PA_MENU_AUTO_LOOT_ENABLE = "Enable Auto Loot",
	
    -- PALoot Loot Events --
    SI_PA_MENU_LOOT_EVENTS_HEADER = "Eventos de botín",
    SI_PA_MENU_LOOT_EVENTS_ENABLE = "Activar eventos de botín",

    -- Loot Recipes
    SI_PA_MENU_LOOT_RECIPES_HEADER = table.concat({"obtener ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), 2)}),
    SI_PA_MENU_LOOT_RECIPES_UNKNOWN_MSG = table.concat({"> una ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), " es desconocida"}),
    SI_PA_MENU_LOOT_RECIPES_UNKNOWN_MSG_T = table.concat({"Cuando se saquea una ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), " que este personaje aún no conoce, se mostrará un mensaje en el chat"}),
    
    SI_PA_MENU_LOOT_AUTO_LEARN_RECIPES = table.concat({"Aprender automáticamente ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_RECIPES_T = table.concat({"Cuando se saquea una ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), " que este personaje aún no conoce, se aprenderá automáticamente"}),	
    
    SI_PA_MENU_LOOT_AUTO_LEARN_FURNISHING_PLAN = table.concat({"Aprender automáticamente ", GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_FURNISHING_PLAN_T = table.concat({"Cuando se saquea una ", GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), " que este personaje aún no conoce, se aprenderá automáticamente"}),
    
    -- Loot Scribing Scripts & Grimoires
    SI_PA_MENU_LOOT_SCRIBING_SCRIPTS_HEADER = table.concat({"obtener ", zo_strformat(GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT),2),"/",zo_strformat(GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY, 2))}),
    SI_PA_MENU_LOOT_SCRIBING_SCRIPTS_UNKNOWN_MSG = table.concat({"> un ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT).."/"..GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY), " es desconocido"}),
    SI_PA_MENU_LOOT_SCRIBING_SCRIPTS_UNKNOWN_MSG_T = table.concat({"Cuando se saquea un ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT).."/"..GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY), " que este personaje aún no conoce, se mostrará un mensaje en el chat"}),
    
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_SCRIPTS = table.concat({"Aprender automáticamente ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_SCRIPTS_T = table.concat({"Cuando se saquea un ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT), " que este personaje aún no conoce, se aprenderá automáticamente"}),
    
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_GRIMOIRES = table.concat({"Aprender automáticamente ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_GRIMOIRES_T = table.concat({"Cuando se saquea un ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY), " que este personaje aún no conoce, se aprenderá automáticamente"}),

    -- Loot Motifs & Style Pages
    SI_PA_MENU_LOOT_STYLES_HEADER = "obtener estilos",
    
    SI_PA_MENU_LOOT_MOTIFS_UNKNOWN_MSG = table.concat({"> un ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " es desconocido"}),
    SI_PA_MENU_LOOT_MOTIFS_UNKNOWN_MSG_T = table.concat({"Cuando se saquea un ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " que este personaje aún no conoce, se mostrará un mensaje en el chat"}),
 
    SI_PA_MENU_LOOT_STYLEPAGES_UNKNOWN_MSG = table.concat({"> una ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), " es desconocida"}),
    SI_PA_MENU_LOOT_STYLEPAGES_UNKNOWN_MSG_T = table.concat({"Cuando se saquea una ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), " que este personaje aún no conoce, se mostrará un mensaje en el chat"}), 
    
    SI_PA_MENU_LOOT_AUTO_LEARN_MOTIFS = table.concat({"Aprender automáticamente ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_MOTIFS_T = table.concat({"Cuando se saquea un ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " que este personaje aún no conoce, se aprenderá automáticamente"}),

    SI_PA_MENU_LOOT_AUTO_LEARN_STYLEPAGES = table.concat({"Aprender automáticamente ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_STYLEPAGES_T = table.concat({"Cuando se saquea una ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), " que este personaje aún no conoce, se aprenderá automáticamente"}),

    -- Loot Equipment (Apparel, Weapons & Jewelries)
    SI_PA_MENU_LOOT_APPARELWEAPONS_HEADER = "obtener equipo",
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNKNOWN_MSG = "> un rasgo aún no ha sido investigado",
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNKNOWN_MSG_T = table.concat({"Cuando se saquea una ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), ", una ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), ", o ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), " que tiene un rasgo que este personaje aún no ha investigado, se mostrará un mensaje en el chat"}),
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNCOLLECTED_MSG = "> un objeto de conjunto aún no ha sido coleccionado",
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNCOLLECTED_MSG_T = table.concat({"Cuando se saquea una ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), ", una ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), ", o ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), " que es parte de un conjunto y aún no se ha añadido a la colección de conjuntos, se mostrará un mensaje en el chat"}),
    SI_PA_MENU_LOOT_APPARELWEAPONS_AUTOBIND = "Vincular automáticamente conjuntos no coleccionados",
    SI_PA_MENU_LOOT_APPARELWEAPONS_AUTOBIND_T = table.concat({"Cuando se saquea una ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), ", una ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), ", o ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), " que es parte de un conjunto y aún no se ha añadido a la colección de conjuntos, se vinculará automáticamente"}),

    -- Loot Companion Items
    SI_PA_MENU_LOOT_COMPANION_ITEMS_HEADER = table.concat({"obtener ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION)}),
    SI_PA_MENU_LOOT_COMPANION_ITEMS_QUALITY_THRESHOLD = table.concat({"> saquear ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION), " con calidad igual o superior a"}),
    SI_PA_MENU_LOOT_COMPANION_ITEMS_QUALITY_THRESHOLD_T = table.concat({"Cuando se saquean ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION), " que son del nivel de calidad seleccionado o superior, se mostrará un mensaje en el chat"}),

    -- Auto Fillet common fish
    SI_PA_MENU_LOOT_AUTO_FILLET_HEADER = table.concat({"Al ", GetString("SI_ITEMTYPE", ITEMTYPE_FISH)}),
    SI_PA_MENU_LOOT_AUTO_FILLET = "Filetear automáticamente peces comunes",
    SI_PA_MENU_LOOT_AUTO_FILLET_T = "Filetea automáticamente peces comunes para obtener pescado o caviar perfecto",
    
    -- Auto Combine collectibles
    SI_PA_MENU_LOOT_AUTO_COMBINE_HEADER = table.concat({"Al obtener ", GetString(SI_SPECIALIZEDITEMTYPE109)}), 
    SI_PA_MENU_LOOT_AUTO_COMBINE = "Auto combina fragmentos de coleccionables bloqueados",
    SI_PA_MENU_LOOT_AUTO_COMBINE_T = "Combina automáticamente fragmentos para desbloquear el coleccionable",

    -- Inventory space warning --
    SI_PA_MENU_LOOT_LOW_INVENTORY_WARNING = "Advertir cuando el espacio en el inventario sea bajo",
    SI_PA_MENU_LOOT_LOW_INVENTORY_WARNING_T = "Mostrar una advertencia en la ventana de chat si tienes poco espacio en el inventario",
    SI_PA_MENU_LOOT_LOW_INVENTORY_THRESHOLD = "Umbral de espacio en el inventario",
    SI_PA_MENU_LOOT_LOW_INVENTORY_THRESHOLD_T = "Si el espacio libre restante en el inventario es igual o inferior a este umbral, se mostrará un mensaje en la ventana de chat",

    -- PALoot Mark Items --
    SI_PA_MENU_LOOT_ICONS_HEADER = "Iconos de objetos",
    SI_PA_MENU_LOOT_ICONS_ENABLE = "Activar iconos de objetos",
    SI_PA_MENU_LOOT_ICONS_ANY_SHOW_TOOLTIP = "Mostrar tooltip del icono",
    
    -- mark known as junk --
    SI_PA_MENU_LOOT_AUTO_MARK_AS_JUNK_KNOWN = "Marcar automáticamente como basura los conocidos",
    SI_PA_MENU_LOOT_AUTO_MARK_AS_JUNK_KNOWN_T = "Marca automáticamente como basura los objetos conocidos para que puedan venderse automáticamente a un comerciante",

    -- Mark Recipes --
    SI_PA_MENU_LOOT_ICONS_RECIPES_HEADER = table.concat({"Marcar ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RECIPE), 2)}),
    SI_PA_MENU_LOOT_ICONS_RECIPE_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "cuando una ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), " ya es conocida"}),
    SI_PA_MENU_LOOT_ICONS_RECIPE_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, "cuando una ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), " aún es desconocida"}),
    
    -- Mark scribing --
    SI_PA_MENU_LOOT_ICONS_SCRIBING_HEADER = table.concat({"Marcar ", GetString(SI_NOTIFICATIONTYPE20), " ", GetString(SI_ITEMTYPE73), "/", GetString(SI_ITEMTYPE72)}),
    SI_PA_MENU_LOOT_ICONS_SCRIBING_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "cuando un ", GetString(SI_NOTIFICATIONTYPE20), " ", GetString(SI_ITEMTYPE73), "/", GetString(SI_ITEMTYPE72), " ya es conocido"}),
    SI_PA_MENU_LOOT_ICONS_SCRIBING_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, "cuando un ", GetString(SI_NOTIFICATIONTYPE20), " ", GetString(SI_ITEMTYPE73), "/", GetString(SI_ITEMTYPE72), " aún es desconocido"}),

    -- Mark Motifs and Style Page Containers --
    SI_PA_MENU_LOOT_ICONS_STYLES_HEADER = "Marcar estilos",
    SI_PA_MENU_LOOT_ICONS_MOTIFS_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "cuando un ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " ya es conocido"}),
    SI_PA_MENU_LOOT_ICONS_MOTIFS_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, "cuando un ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " aún es desconocido"}),
    SI_PA_MENU_LOOT_ICONS_STYLEPAGES_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "cuando una ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), " ya es conocida"}),
    SI_PA_MENU_LOOT_ICONS_STYLEPAGES_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, "cuando una ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), " aún es desconocida"}),

    -- Mark Equipment (Apparel, Weapons & Jewelries) --
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_HEADER = "Marcar equipo",
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "cuando un rasgo de objeto ya ha sido investigado"}),
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.NOT_RESEARCHED.NORMAL, "cuando un rasgo de objeto aún es desconocido"}),
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_SET_UNCOLLECTED = table.concat({">", PAC.ICONS.OTHERS.UNCOLLECTED.NORMAL, "cuando un objeto falta en la colección de conjuntos"}),

	-- Mark Companion Items --
    SI_PA_MENU_LOOT_ICONS_MARK_COMPANION_ITEMS_HEADER = table.concat({"Marcando ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION)}),
    SI_PA_MENU_LOOT_ICONS_MARK_COMPANION_ITEMS_SHOW_ALL = table.concat({">", PAC.ICONS.OTHERS.COMPANION.NORMAL, "cuando un objeto es de compañero"}),

	-- Item Icon Positioning --
    SI_PA_MENU_LOOT_ICONS_POSITIONING_DESCRIPTION = "A continuación, puedes ajustar la posición y el tamaño de los iconos de los objetos",
    SI_PA_MENU_LOOT_ICONS_KNOWN_UNKNOWN_HEADER = "Conocido/desconocido",
    SI_PA_MENU_LOOT_ICONS_SET_COLLECTION_HEADER = "Conjuntos no coleccionados",
    SI_PA_MENU_LOOT_ICONS_COMPANION_ITEMS_HEADER = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION),

    SI_PA_MENU_LOOT_ICONS_SIZE_LIST = "Tamaño del icono (vista de lista)",
    SI_PA_MENU_LOOT_ICONS_SIZE_LIST_T = "Define el tamaño de los iconos de conocido/desconocido en lugares donde los objetos se muestran en vista de lista",
    SI_PA_MENU_LOOT_ICONS_SIZE_GRID = "Tamaño del icono (vista de cuadrícula)",
    SI_PA_MENU_LOOT_ICONS_SIZE_GRID_T = "Define el tamaño de los iconos de conocido/desconocido en lugares donde los objetos se muestran en vista de cuadrícula",

    SI_PA_MENU_LOOT_ICONS_X_OFFSET_LIST = "Desplazamiento X del icono (vista de lista)",
    SI_PA_MENU_LOOT_ICONS_X_OFFSET_LIST_T = "Define el desplazamiento horizontal del icono de conocido/desconocido en la vista de lista",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_LIST = "Desplazamiento Y del icono (vista de lista)",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_LIST_T = "Define el desplazamiento vertical del icono de conocido/desconocido en la vista de lista",

    SI_PA_MENU_LOOT_ICONS_X_OFFSET_GRID = "Desplazamiento X del icono (vista de cuadrícula)",
    SI_PA_MENU_LOOT_ICONS_X_OFFSET_GRID_T = "Define el desplazamiento horizontal del icono de conocido/desconocido en la vista de cuadrícula",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_GRID = "Desplazamiento Y del icono (vista de cuadrícula)",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_GRID_T = "Define el desplazamiento vertical del icono de conocido/desconocido en la vista de cuadrícula",

-- =================================================================================================================
-- == CHAT OUTPUTS == --
-- -----------------------------------------------------------------------------------------------------------------
-- PALoot --
    SI_PA_CHAT_LOOT_RECIPE_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s se puede ", PAC.COLORS.ORANGE,"aprender", PAC.COLORS.DEFAULT, "!"}),
    SI_PA_CHAT_LOOT_MOTIF_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s se puede ", PAC.COLORS.ORANGE,"aprender", PAC.COLORS.DEFAULT, "!"}),	
    SI_PA_CHAT_LOOT_SCRIBING_SCRIPT_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s se puede ", PAC.COLORS.ORANGE,"aprender", PAC.COLORS.DEFAULT, "!"}),	
    SI_PA_CHAT_LOOT_TRAIT_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s tiene [", PAC.COLORS.ORANGE,"%s", PAC.COLORS.DEFAULT,"] que se puede investigar!"}),
    SI_PA_CHAT_LOOT_SET_UNCOLLECTED = table.concat({PAC.ICONS.OTHERS.UNCOLLECTED.SMALL, "%s falta en la colección de conjuntos!"}),
    SI_PA_CHAT_LOOT_COMPANION_ITEM = table.concat({PAC.ICONS.OTHERS.COMPANION.SMALL, "%s nuevo objeto de compañero con ", PAC.COLOR.WHITE:Colorize("%s"), " rasgo!"}),
    SI_PA_CHAT_LOOT_AUTO_FILLET = "%s se está fileteando automáticamente.",

    SI_PA_PATTERN_INVENTORY_COUNT = table.concat({"%sTienes <<1[", PAC.COLORS.WHITE,"ningún/solo ", PAC.COLORS.WHITE, "%d/solo ", PAC.COLORS.WHITE, "%d]>> %s<<1[espacio de inventario/espacios de inventario]>> restante!"}),
    SI_PA_PATTERN_REPAIRKIT_COUNT = table.concat({"%sTienes <<1[", PAC.COLORS.WHITE,"ninguno/solo ", PAC.COLORS.WHITE, "%d/solo ", PAC.COLORS.WHITE, "%d]>> %s<<1[Kits de Reparación/Kit de Reparación/Kits de Reparación]>> restante!"}),
    SI_PA_PATTERN_SOULGEM_COUNT = table.concat({"%sTienes <<1[", PAC.COLORS.WHITE,"ninguna/solo ", PAC.COLORS.WHITE, "%d/solo ", PAC.COLORS.WHITE, "%d]>> %s<<1[Gemas de Alma/Gema de Alma/Gemas de Alma]>> restante!"}),

-- =================================================================================================================
-- == OTHER STRINGS FOR MENU == --
-- -----------------------------------------------------------------------------------------------------------------
-- PALoot --
    SI_PA_DISPLAY_A_MESSAGE_WHEN = "Mostrar un mensaje cuando . . .",
    SI_PA_MARK_WITH = "Marcar con . . .",
    SI_PA_ITEM_KNOWN = "Ya conocido",
    SI_PA_ITEM_UNKNOWN = "Desconocido",
    SI_PA_ITEM_UNCOLLECTED = "No coleccionado",
    SI_PA_ITEM_COMPANION_ITEM = "Objeto de Compañero"
}

for key, value in pairs(PALStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end

