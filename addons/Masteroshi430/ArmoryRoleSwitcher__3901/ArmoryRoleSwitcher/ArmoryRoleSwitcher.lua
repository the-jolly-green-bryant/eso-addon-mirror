ArmoryRoleSwitcher = {}
ArmoryRoleSwitcher.name = "ArmoryRoleSwitcher"

-- Lookup table: armory icon index -> { LFG role constant, role string id }
-- Built once at load time instead of re-evaluated on every event.
local ICON_TO_ROLE = {
	[1] = { role = LFG_ROLE_DPS,  stringId = SI_LFGROLE1 },
	[2] = { role = LFG_ROLE_HEAL, stringId = SI_LFGROLE4 },
	[3] = { role = LFG_ROLE_TANK, stringId = SI_LFGROLE2 },
}

function ArmoryRoleSwitcher.go(eventCode, result, buildIndex)
	if not IsPlayerActivated() then return end
	if result ~= ARMORY_BUILD_RESTORE_RESULT_SUCCESS then return end

	local entry = ICON_TO_ROLE[GetArmoryBuildIconIndex(buildIndex)]
	if not entry then return end -- unknown/unsupported icon, nothing to do

	local actualRole = GetSelectedLFGRole()
	if actualRole == entry.role then return end -- already the right role, skip work

	UpdateSelectedLFGRole(entry.role)

	-- Only build the (relatively costly) formatted string and pull the
	-- build name once we know we actually need to print something.
	local buildName = GetArmoryBuildName(buildIndex)
	d("[ARS] " .. zo_strformat(SI_TOOLTIP_ITEM_ROLE_FORMAT, GetString(entry.stringId)) .. " (" .. buildName .. ")")
end

EVENT_MANAGER:RegisterForEvent(ArmoryRoleSwitcher.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, ArmoryRoleSwitcher.go)
