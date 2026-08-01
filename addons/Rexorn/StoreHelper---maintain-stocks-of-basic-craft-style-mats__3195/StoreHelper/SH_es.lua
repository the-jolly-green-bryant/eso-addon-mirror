local SH_localization  = {
 SH_mod_name = "StoreHelper"
,SH_display_name = "Store Helper"

,SH_bought_mats_msg     = "SH: comprado %u %s"								-- ie purchased 5 Flint
,SH_buy_reduced_msg     = "SH: reduciendo la compra de %s de %u a %u - comprobar oro"
,SH_PA_integration_msg  = "SH: PAJunk/reparación encontrada. SH hará una pausa de 0,2 s."


,SH_OptMenu_header_name = "Store Helper Opciones"
,SH_OptMenu_description = "Tenga a mano una cantidad mínima de tapetes de estilo artesanal. All-Types compra tapete racial de toon para asegurarse de que el toon pueda usar el tapete.\nCuenta solo el inventario actual de toon, el banco y la bolsa de artesanía."
,SH_OptMenu_chk_UseToon_name	 = "Usar configuración de caracteres"
,SH_OptMenu_chk_UseToon_tooltip  = "use la configuración para este personaje en lugar de los valores predeterminados de la cuenta"
,SH_OptMenu_chk_buy2chat_name    = "Comprar mensajes para chatear"
,SH_OptMenu_chk_buy2chat_tooltip = "mostrar mensajes de compra en el chat"
,SH_OptMenu_AllTypes_name	 	 = "todos los tipos de materiales"
,SH_OptMenu_AllTypes_tooltip 	 = "si, después de compras específicas de tapetes, los tapetes suman <esta compra más: 0-250\nIgnora el níquel excepto los caracteres imperiales con override=Niquel."
,SH_OptMenu_AllTypes_desc		 = "Este personaje comprará %s para alcanzar el objetivo de todos los tipos."
,SH_OptMenu_ShowPA_AddFunc_name  = "Mostrar mensajes para otras interacciones de mod"
,SH_OptMenu_ShowPA_AddFunc_tooltip = "Mensaje si se agrega un retraso para PersonalAssistant u otros complementos. Agregar funciones de la tienda."

-- racial style mat names generated in main code using system calls -> no SH_OptMenu_*_name strings
,SH_OptMenu_box_genMat_tooltip	  = "Mínimo para mantener en stock: 0-250 (caja de uso para >250)"

,SH_OptMenu_Nickel_note = "          Solo se cuenta para la decisión de AllTypes si Imperial con anulación establecida en Níquel." 
,SH_OptMenu_Imp_override_name = "Carrera imperial Todos los tipos de alfombras Comprar anular" 
,SH_OptMenu_Imp_override_tooltip = "El Motivo Imperial es raro/caro, pocos toons conocerán el estilo.\nPara evitar comprar tapetes de uso limitado, la compra de AllTypes usará esto para Imperiales para permitir la elección del tapete de compra.\nNO afecta el objetivo de compra específico de Níquel."
,SH_OptMenu_Imp_override_desc = "          Solo tiene efecto en personajes imperiales."

,SH_err_add_for_store_no_addon_name = "SH: otro complemento le pidió a SH que manejara una función de tienda sin proporcionar el nombre del complemento"
,SH_err_add_for_store_no_func_desc  = "SH: %s le pidió a SH que manejara una función de almacenamiento sin una descripción para el aviso de carga"
,SH_err_add_for_store_not_func      = "SH: %s le pidió a SH que manejara una función de almacenamiento pero no pasó una función (%s)"
,SH_err_add_for_store_already_added = "SH: %s le pidió a SH que agregara (%s) que ya estaba incluido"
,SH_accepted_func	                = "SH: función de compra aceptada %s(%s)"
		-- SH: accepted shopping function Bob(buy rune stones)

,SH_err_remove_func_no_addon_name	= "SH: otro complemento solicitó que se elimine una función sin proporcionar el nombre del complemento"
,SH_err_remove_func_no_func_desc	= "SH: %s le pidió a SH que elimine una función de tienda sin una clave de descripción"
,SH_err_remove_func_not_func		= "SH: %s le pidió a SH que elimine una función de almacenamiento pero no pasó una función"
,SH_err_remove_func_not_found		= "SH: %s le pidió a SH que eliminara (%s) pero la función nunca se agregó o ya se eliminó"
,SH_removed_func					= "SH: función de compra eliminada %s(%s)"
,SH_cannot_find_alltypes_matID		= "SH: alltypes_matID"


,SH_debug_msg_off = "SH: mensajes de depuración desactivados"
,SH_debug_msg_on  = "SH: mensajes de depuración en"
,SH_debug_show_ap_entries        = "SH: la tienda acepta entradas de puntos de alianza %u"
,SH_debug_show_gold_entries      = "SH: la tienda acepta entradas de oro %u"
,SH_debug_show_gold_only_entries = "SH: la tienda solo acepta entradas de oro %uu"
,SH_debug_show_telvar_entries    = "SH: la tienda toma las entradas de Telvar %u"


-- if a new race is added define SH_style_*, SH_mat_* here
-- if you need a custom language not included by ZOS set SH_load_ZOS_names to false & fill in values
-- SH_style_* is just a display name
,SH_load_ZOS_names	= true
,SH_style_breton	= "custom style name"
,SH_style_redguard	= "custom style name"
,SH_style_orc		= "custom style name"
,SH_style_darkelf	= "custom style name"
,SH_style_nord		= "custom style name"
,SH_style_argonian	= "custom style name"
,SH_style_highelf	= "custom style name"
,SH_style_woodelf	= "custom style name"
,SH_style_khajiit	= "custom style name"
,SH_style_imperial	= "custom style name"

-- SH_mat_* is used for item matching in store entries.
-- custom mat name MUST match the name from GetStoreEntryInfo() not the formated name shown on the screen
,SH_mat_breton		= "custom mat name"
,SH_mat_redguard	= "custom mat name"
,SH_mat_orc			= "custom mat name"
,SH_mat_darkelf		= "custom mat name"
,SH_mat_nord		= "custom mat name"
,SH_mat_argonian	= "custom mat name"
,SH_mat_highelf		= "custom mat name"
,SH_mat_woodelf		= "custom mat name"
,SH_mat_khajiit		= "custom mat name"
,SH_mat_imperial	= "custom mat name"
-- MUST match the name from GetStoreEntryInfo() - REALLY
}

-- loaded SH main LUA first instead of second
-- quick store local into SH for use
ZO_ShallowTableCopy(SH_localization, StoreHelper.localization)


-- do NOT try to set pointer directly, for some reason it will clear addon
-- StoreHelper.localization = SH_localization

-- another way is copying the strings into the Global table with dup checking
-- probably more overhead than the shallow table copy
--[[ 
for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(StringId, 1)
end

other files use this to find the key on the _G table
for key, value in pairs(strings) do
	SafeAddString(_G[key], value, 1)
end

in code use GetString(xx)
]]
