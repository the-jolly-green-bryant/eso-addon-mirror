AF_ArenaSetFilters = AF_ArenaSetFilters or {}
local afAS = AF_ArenaSetFilters

--English translations
afAS.translation = {
    ARENA_SETS_MENU_ENTRY         = "Sets - Arena: ",
    ALL_ARENA_SETS_SUBMENU_ENTRY  = "All arena sets",
}


local strings = {
    AFAS_COMMAND_MESSAGE_1             = 'Arena Set Filters will show all filters after UI is reloaded',
    AFAS_COMMAND_MESSAGE_2             = 'Arena Set Filters will show only "All arena sets" entry after UI is reloaded',
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
