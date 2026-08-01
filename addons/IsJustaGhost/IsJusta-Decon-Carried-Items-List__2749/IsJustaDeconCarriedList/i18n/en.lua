------------------------------------------------
-- English localization for IsJustaKeyboardDeconCarriedList
------------------------------------------------

local strings = {
    SI_IJADECON_CARRIED = "Carried",
	
    SI_IJADECON_USE_CLEAN_REFINMENT_TAB = "Clean Refinement Tab",
    SI_IJADECON_USE_CLEAN_REFINMENT_TOOLTIP = "Enabled: shows only the raw materials you have 10 or more of in the Refinement tab.",
    SI_IJADECON_AUTOADD = "Add All",
    SI_IJADECON_AUTOADD_HEADER = "Include in Add All.",
    SI_IJADECON_AUTOADD_TOOLTIP = "Enabled: Include <<1>> when adding all.",
	SI_IJADECON_OPEN_TO_DECON_TAB = "Open to Deconstruct",
	SI_IJADECON_USE_ADDALL_FOR_OTHERS= "Use Add All for other tabs",
	SI_IJADECON_USE_ADDALL_FOR_OTHERS_TOOLTIP = "Enabled: will enable the \"Add All\" button for " .. GetString(SI_TRADINGHOUSECATEGORYHEADER5) .. " / " .. GetString(SI_TRADINGHOUSECATEGORYHEADER2) .. " / " .. GetString(SI_TRADINGHOUSECATEGORYHEADER1) .. " / " .. GetString(SI_TRADINGHOUSECATEGORYHEADER8) .. ".",
	
	-- need translations -V-
    SI_IJADECON_MIN_QUALITY = "Minimum Quality",
    SI_IJADECON_MAX_QUALITY = "Maximum Quality",
	
	SI_IJADECON_OPEN_TO_DECON_ASSISTANT = "Auto open Assistant.",
	SI_IJADECON_OPEN_TO_DECON_ASSISTANT_TOOLTIP = "Enabled: will automatically open the Deconstruction assistant and switch to the carried tab if you have carried items to deconstruct that pass filters.",
	
	SI_IJADECON_OPEN_TO_DECON_TAB_TOOLTIP = "Enabled: will automatically open and switch to the Deconstruct tab on entering the crafting station if you have carried items to deconstruct that pass filters.",
	
	SI_IJADECON_DEFAULT_TOOLTIP = "items not included in other filters",
	
	SI_IJADECON_IGNORE_BOP = "Ignore Group Tradeable",
	SI_IJADECON_IGNORE_BOP_TOOLTIP = "Enabled: Items that are Bind On Pickup and Trade-able will be excluded from Add All.",
	
	SI_IJADECON_WARN_BOP = "Warn Group Tradeable",
	SI_IJADECON_WARN_BOP_TOOLTIP = "Enabled: Items that are Bind On Pickup and Trade-able will require confirmation to Add All.",
	
	
	SI_IJADECON_WARN_BOP_TITLE = "Notice!",
	SI_IJADECON_WARN_BOP_DESCRIPTION = "Would you like to add all \"filtered\" Bind On Pickup and Trade-able items to be deconstructed?",
	
	SI_IJADECON_AUTOADD_TITLE = "Add All On Open",
	SI_IJADECON_AUTOADD_DESCRIPTION = "Enabled: Items matching filter will be automatically added to deconstruct on opening station or assistant.",

	SI_IJADECON_DIALOGUE_TITLE = "Include BOP and Trade-able?",
	SI_IJADECON_DIALOGUE_DESCRIPTION = "Confirming will add all BOP and Trade-able items that pass filters to be deconstucted.",
	
	SI_IJADECON_USE_ADDALL_IGNORESTOLEN = "Ignore stolen",
	SI_IJADECON_USE_ADDALL_IGNORESTOLEN_TOOLTIP = "Enabled: stolen items will not be added with the \"Add All\" button",	
}

-- Dynamically create variable to allow changes by ZOS
IJA_SMITHING_FILTER_TYPE_CARRIED = SMITHING_FILTER_TYPE_MAX_VALUE + 1

-- Should I make this for fully dynamic use. If other addons did the same thing this would work.
-- SMITHING_FILTER_TYPE_MAX_VALUE = IJA_SMITHING_FILTER_TYPE_CARRIED
-- It works for stuff like the following without having to recode everything separately.
-- Appending variable to sting id for use as GetString("SI_SMITHINGFILTERTYPE_EXTRACTNONE", filterType)
strings["SI_SMITHINGFILTERTYPE_EXTRACTNONE" .. IJA_SMITHING_FILTER_TYPE_CARRIED] = "No carried items to deconstruct."
strings["SI_SMITHINGFILTERTYPE" .. IJA_SMITHING_FILTER_TYPE_CARRIED] = "Carried"


for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
