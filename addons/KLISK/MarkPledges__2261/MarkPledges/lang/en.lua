-- Messages settings
local strings = {
	MARKPLEDGES_COLOR								= "Marks: Color",
	MARKPLEDGES_MARK_NORMAL_DUNGEONS				= "Marks: Normal dungeons",
	MARKPLEDGES_MARK_NORMAL_DUNGEONS_TT				= "Marks normal dungeons at the dungeon finder's specific dungeons list",
	MARKPLEDGES_MARK_VET_DUNGEONS					= "Marks: Veteran dungeons",
	MARKPLEDGES_MARK_VET_DUNGEONS_TT				= "Marks Veteran dungeons at the dungeon finder's specific dungeons list",
	MARKPLEDGES_AUTO_CHECK_NORMAL_DUNGEONS			= "Auto-Check: Normals",
	-- MARKPLEDGES_AUTOSELECT_NORMAL_DUNGEONS_TT	= "Auto-Selects the normal dungeons at the dungeon finder's specific dungeons list",
	MARKPLEDGES_AUTO_CHECK_VET_DUNGEONS				= "Auto-Check: Veterans",
	-- MARKPLEDGES_AUTOSELECT_VET_DUNGEONS_TT		= "Auto-Selects the veteran dungeons at the dungeon finder's specific dungeons list",
	-- MARKPLEDGES_ADDITIONAL_VERIFICATION			= "Additional verification",
	-- MARKPLEDGES_ADDITIONAL_VERIFICATION_TT		= "Use only if not all dungeons are marked.",
	-- MARKPLEDGES_DEBUG							= "debug",
	MARKPLEDGES_CHECK_BUTTONS_POSITION_X			= "Check Buttons - Position X.",
	MARKPLEDGES_CHECK_BUTTONS_POSITION_Y			= "Check Buttons - Position Y.",
}
for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end