AF_TrialSetFilters = AF_TrialSetFilters or {}
local afTS = AF_TrialSetFilters

--English translations
afTS.translation = {
    TRIAL_SETS_MENU_ENTRY         = "Sets - Trial: ",
    ALL_TRIAL_SETS_SUBMENU_ENTRY  = "All trial sets",
}


local strings = {
    AFTS_COMMAND_MESSAGE_1             = 'Trial Set Filters will show all filters after UI is reloaded',
    AFTS_COMMAND_MESSAGE_2             = 'Trial Set Filters will show only "All trial sets" entry after UI is reloaded',
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
