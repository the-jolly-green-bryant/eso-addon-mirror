AF_DungeonSetFilters = AF_DungeonSetFilters or {}
local afDS = AF_DungeonSetFilters

--English translations
afDS.translation = {
    DUNGEON_SETS_MENU_ENTRY         = "Sets - Dungeon: ",
    ALL_DUNGEON_SETS_SUBMENU_ENTRY  = "All dungeon sets",
}


local strings = {
    AFDS_COMMAND_MESSAGE_1             = 'Dungeon Set Filters will show all filters after UI is reloaded',
    AFDS_COMMAND_MESSAGE_2             = 'Dungeon Set Filters will show only "All dungeon sets" entry after UI is reloaded',
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
