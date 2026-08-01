
-- en localization for Dyer

local strings = {
   DYER_TOGGLE_MODE						= "Toggle Mode",
   DYER_SAVE_FAVORITE_TITLE			= "Save new Dyestamp",
	DYER_FAVORITE_NAME_HEADER			= "Enter a name for your personalized dyestamp",
	DYER_FAVORITE_NAME_DEFAULT_TEXT	= "E.g: Rainbow",
	DYER_ADD_SOLO_TO_DYESTAMPS			= "Add this slot to Dyestamps",
	DYER_ADD_WHOLE_TO_DYESTAMPS		= "Add the whole set to Dyestamps",
	DYER_DYESTAMP_LABEL					= "Colors used :",
	DYER_DELETE_DYESTAMP					= "Delete Dyestamp",
	DYER_SET_LABEL							= "Set",
	DYER_INVALID_MODE_FOR_SET			= "Invalid mode for this set",
	DYER_REMOVE_FROM_RANDOM				= "Remove from Random",
	DYER_ADD_FROM_RANDOM					= "Add back to Random",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end