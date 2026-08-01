local SH_localization  = {
 SH_mod_name = "StoreHelper"
,SH_display_name = "Store Helper"

,SH_bought_mats_msg     = "SH: purchased %u %s"								-- ie purchased 5 Flint
,SH_buy_reduced_msg     = "SH: reducing %s purchase from %u to %u - check gold"
,SH_PA_integration_msg  = "SH: PAJunk/Repair found. SH will pause 0.2s."

,SH_OptMenu_header_name = "Store Helper Options"
,SH_OptMenu_description = "Keep a minimum number of crafting style mats on hand.  All-Types buys toon racial mat to ensure purchasing toon can use mat.\nCounts craftbag, bank, & current toon inventory only."
,SH_OptMenu_chk_UseToon_name	 = "Use Toon Settings"
,SH_OptMenu_chk_UseToon_tooltip  = "use settings for this toon instead of account defaults"
,SH_OptMenu_chk_buy2chat_name    = "Buy Msgs to Chat"
,SH_OptMenu_chk_buy2chat_tooltip = "display buy messages in chat"
,SH_OptMenu_AllTypes_name	 	 = "All Mat Types"
,SH_OptMenu_AllTypes_tooltip 	 = "if, after specific mat buys, mats total < this buy more: 0-250\nIgnores Nickel except for Imperial Toons with Ovr=Nickel."
,SH_OptMenu_AllTypes_desc		 = "This toon will buy %s to reach All Types goal."
,SH_OptMenu_ShowPA_AddFunc_name  = "Show Msgs for other Mod Interactions"
,SH_OptMenu_ShowPA_AddFunc_tooltip = "Message if delay added for PersonalAssistant or other addons add Store Functions"

-- racial style mat names generated in main code using system calls -> no SH_OptMenu_*_name strings
,SH_OptMenu_box_genMat_tooltip	  = "min to keep in stock: 0-250 (use box for >250)"

,SH_OptMenu_Nickel_note = "          Only Counted for AllTypes decision if Imperial with override set to Nickel." 
,SH_OptMenu_Imp_override_name = "Imperial Race All Mat Types Buy Override" 
,SH_OptMenu_Imp_override_tooltip = "The Imperial Motif is rare/expensive, few toons will know the style.\nTo keep from buying limited use mats AllTypes buy will use this for Imperials to allow choice of buy mat.\nDoes NOT impact Nickel specific buy target."
,SH_OptMenu_Imp_override_desc = "          Only has affect on Imperial toons."

,SH_err_add_for_store_no_addon_name = "SH: another addon asked SH to handle a store function without providing the addon name"
,SH_err_add_for_store_no_func_desc  = "SH: %s asked SH to handle a store function without a description for load notice"
,SH_err_add_for_store_not_func      = "SH: %s asked SH to handle a store function but did not pass a function (%s)"
,SH_err_add_for_store_already_added = "SH: %s asked SH to add (%s) that was already included"
,SH_accepted_func	                = "SH: accepted shopping function %s(%s)"
		-- SH: accepted shopping function Bob(buy rune stones)

,SH_err_remove_func_no_addon_name	= "SH: another addon asked to have a function removed without providing the addon name"
,SH_err_remove_func_no_func_desc	= "SH: %s asked SH to remove a store function without a description key"
,SH_err_remove_func_not_func		= "SH: %s asked SH to remove a store function but did not pass a function"
,SH_err_remove_func_not_found		= "SH: %s asked SH to remove (%s) but the function was never added or already removed"
,SH_removed_func					= "SH: removed shopping function %s(%s)"
,SH_cannot_find_alltypes_matID		= "SH: fatal error cannot find alltypes_matID"

,SH_debug_msg_off = "SH: debug messages off"
,SH_debug_msg_on  = "SH: debug messages on"
,SH_debug_show_ap_entries        = "SH: store takes Alliance Point entries %u"
,SH_debug_show_gold_entries      = "SH: store takes gold entries %u"
,SH_debug_show_gold_only_entries = "SH: store takes gold only entries %u"
,SH_debug_show_telvar_entries    = "SH: store takes telvar entries %u"


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
