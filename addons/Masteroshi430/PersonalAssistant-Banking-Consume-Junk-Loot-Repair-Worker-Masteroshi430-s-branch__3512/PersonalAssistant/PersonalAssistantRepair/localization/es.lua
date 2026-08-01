-- Translated by: Cisneros

local PAC = PersonalAssistant.Constants
local PARStrings = {
    -- =================================================================================================================
    -- Textos específicos del idioma que necesitan ser traducidos --

    -- =================================================================================================================
    -- == TEXTOS DEL MENÚ/PANEL == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Menú PARepair --
    SI_PA_MENU_REPAIR_DESCRIPTION = "PARepair & Restock repara tu armadura y recarga tus armas por ti, ya sea en un comerciante o en el campo. También repone artículos útiles en los comerciantes.",

    -- Objetos Equipados --
    SI_PA_MENU_REPAIR_EQUIPPED_HEADER = "Objetos Equipados",
    SI_PA_MENU_REPAIR_ENABLE = "Habilitar auto reparación de objetos equipados",

    SI_PA_MENU_REPAIR_GOLD_HEADER = table.concat({"Reparar con ", GetCurrencyName(CURT_MONEY)}),
    SI_PA_MENU_REPAIR_GOLD_ENABLE = table.concat({"¿Reparar objetos equipados con ", GetCurrencyName(CURT_MONEY), "?"}),
    SI_PA_MENU_REPAIR_GOLD_ENABLE_T = "Al visitar un comerciante, todos los objetos equipados que estén en o por debajo del umbral definido se repararán automáticamente",
    SI_PA_MENU_REPAIR_GOLD_DURABILITY = "Umbral de durabilidad en %",
    SI_PA_MENU_REPAIR_GOLD_DURABILITY_T = "Repara objetos equipados solo si están en o por debajo del umbral de durabilidad definido",

    SI_PA_MENU_REPAIR_REPAIRKIT_HEADER = table.concat({"Reparar con ", GetString(SI_PA_MENU_BANKING_REPAIRKIT)}),
    SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE = table.concat({"¿Reparar objetos equipados con ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), "?"}),
    SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE_T = "Cuando estés en el campo, todos los objetos equipados que estén en o por debajo del umbral definido se repararán automáticamente",
    SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT = "Kit de reparación predeterminado",
    SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT_T = "Tu kit de reparación predeterminado se usará primero al reparar objetos",
    SI_PA_MENU_REPAIR_REPAIRKIT_GROUP = "Usar kits de reparación de grupo",
    SI_PA_MENU_REPAIR_REPAIRKIT_GROUP_T = "Los kits de reparación de grupo se usarán primero al reparar objetos mientras estés en grupo",
    SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY = "Umbral de durabilidad en %",
    SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY_T = "Reparar objetos equipados solo si están en o por debajo del umbral de durabilidad definido",
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING = table.concat({"Advertir cuando haya pocos ", GetString(SI_PA_MENU_BANKING_REPAIRKIT)}),
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING_T = table.concat({"Muestra una advertencia en el chat si te quedan pocos ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), ". Si no te quedan, te advertirá como máximo una vez cada 10 minutos."}),
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD = "Umbral de kit de reparación",
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD_T = table.concat({"Si la cantidad restante de ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), " está por debajo de este umbral, se muestra un mensaje en la ventana de chat"}),

    SI_PA_MENU_REPAIR_RECHARGE_HEADER = table.concat({"Recargar armas con ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2)}),
    SI_PA_MENU_REPAIR_RECHARGE_ENABLE = table.concat({"¿Recargar armas equipadas con ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), "?"}),
    SI_PA_MENU_REPAIR_RECHARGE_ENABLE_T = "Recarga armas equipadas cuando su nivel de carga llegue a cero. Primero se usarán las Gemas de alma seleccionadas como predeterminadas.",
    SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM = "Gema de alma predeterminada",
    SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM_T = "Tu gema de alma predeterminada se usará primero al recargar armas.",
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING = table.concat({"Advertir cuando haya pocas ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2)}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING_T = table.concat({"Muestra una advertencia en el chat si te quedan pocas ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), ". Si no te quedan, te advertirá como máximo una vez cada 10 minutos."}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD = table.concat({GetString("SI_ITEMTYPE", ITEMTYPE_SOUL_GEM), " umbral"}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD_T = table.concat({"Si la cantidad restante de ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), " está por debajo de este umbral, se muestra un mensaje en la ventana de chat"}),

    -- Objetos del Inventario --
    SI_PA_MENU_REPAIR_INVENTORY_HEADER = "Objetos del inventario",
    SI_PA_MENU_REPAIR_INVENTORY_ENABLE = "Habilitar autoeparación para objetos del inventario",

    SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE = table.concat({"¿Reparar objetos del inventario con ", GetCurrencyName(CURT_MONEY), "?"}),
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE_T = "Al visitar un comerciante, todos los objetos en el inventario que estén en o por debajo del umbral definido se repararán automáticamente",
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY = "Umbral de durabilidad en %",
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY_T = "Reparar objetos del inventario solo si están en o por debajo del umbral de durabilidad definido",
    
    -- Comprar kits de reparación --
    SI_PA_MENU_BUY_REPAIR_KITS_HEADER = "Comprar kits de reparación",
    SI_PA_MENU_BUY_REPAIR_KITS_ENABLE = "Habilitar auto compra de kits de reparación",
    
    -- Menús dinámicos de compra de artículos --
    SI_PA_MENU_BUY_ITEM_HEADER = "Comprar %s",
    SI_PA_MENU_BUY_ITEM_ENABLE = "¿Comprar %s automáticamente?",
    SI_PA_MENU_BUY_ITEM_ENABLE_T = "Al visitar un comerciante, se comprarán automáticamente los %s que falten",
    SI_PA_MENU_BUY_ITEM_THRESHOLD = "Umbral de inventario de %s",
    SI_PA_MENU_BUY_ITEM_THRESHOLD_T = "Cuando tu cantidad de %s esté por debajo de ese umbral, se comprará la cantidad que falte",
    SI_PA_MENU_BUY_ITEM_PRIORITY = "Prioridad de Moneda para %s",
    SI_PA_MENU_BUY_ITEM_PRIORITY_T = "Selecciona qué moneda se usará primero para intentar comprar %s", 
    
    -- Comprar Gemas de Alma --
    SI_PA_MENU_BUY_SOUL_GEMS_HEADER = "Comprar gemas de alma y ganzúas",
    SI_PA_MENU_BUY_SOUL_GEMS_ENABLE = "Habilitar auto compra de gemas de alma y ganzúas",  
    
    -- Comprar artículos de asedio -- 
    SI_PA_MENU_BUY_SIEGE_ITEMS_HEADER = "Comprar "..GetString(SI_ITEMTYPEDISPLAYCATEGORY32),
    SI_PA_MENU_BUY_SIEGE_ITEMS_ENABLE = "Habilitar comprar "..GetString(SI_ITEMTYPEDISPLAYCATEGORY32).." automáticamente",
    
    

    -- =================================================================================================================
    -- == SALIDAS DE CHAT == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PARepair --
    SI_PA_CHAT_REPAIR_SUMMARY_FULL = "Se han reparado los objetos equipados por %s",
    SI_PA_CHAT_REPAIR_SUMMARY_PARTIAL = "Se han reparado los objetos equipados por %s (%s faltantes)",

    SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_FULL = "Se han reparado los objetos del inventario por %s",
    SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_PARTIAL = "Se han reparado los objetos del inventario por %s (%s faltantes)",

    SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED = table.concat({"Se ha reparado %s ", PAC.COLORS.WHITE, "(%d%%)", PAC.COLORS.DEFAULT, " con %s"}),
    SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED_ALL = table.concat({"Se ha reparado %s ", PAC.COLORS.WHITE, "(%d%%)", PAC.COLORS.DEFAULT, " y todos los demás objetos con %s"}),
    
    SI_PA_CHAT_BUY_SUMMARY_BOUGHT = "Se ha comprado %s x %s por %s",
    SI_PA_CHAT_BUY_SUMMARY_MISSING = "No se pudo comprar %s por %s (%s faltantes)",
    
}

for key, value in pairs(PARStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end


local PARGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_CHAT_REPAIR_CHARGE_WEAPON = "%s (%d%% --> %d%%) - %s",
}

for key, value in pairs(PARGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
