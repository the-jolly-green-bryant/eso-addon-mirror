local GroupLog = {}

local GL = GroupLog
local EM = EVENT_MANAGER

GL.name = "GroupLog"

local Group = {}

local enableMessages = false

local ROLE_ICONS = {
	[LFG_ROLE_TANK] = "|t16:16:/esoui/art/lfg/lfg_icon_tank.dds|t",
	[LFG_ROLE_HEAL] = "|t16:16:/esoui/art/lfg/lfg_icon_healer.dds|t",
	[LFG_ROLE_DPS] = "|t16:16:/esoui/art/lfg/lfg_icon_dps.dds|t",
}

local GROUP_ICON = "|t24:24:/esoui/art/tutorial/gamepad/gp_category_u30_companions.dds|t"

local ARROW_JOIN = "|c00FF00←|r "
local ARROW_QUIT = "|cFF0000→|r "
local ARROW_KICKED = "|cFF00FF→|r "
local ARROW_CHANGED = "|c3399FF→|r "

-- =========================
-- Helpers
-- =========================
function GL.CleanName(name)
	return zo_strformat("<<1>>", name)
end

-- =========================
-- GroupRebuild
-- =========================
function GL.RebuildGroup()
	if IsUnitGrouped("player") then
	   enableMessages = true
	end

	ZO_ClearTable(Group)

	for i = 1, GetGroupSize() do
		local unitTag = GetGroupUnitTagByIndex(i)
		local character = GL.CleanName(GetUnitName(unitTag))
		local account = GetUnitDisplayName(unitTag)
		local role = GetGroupMemberSelectedRole(unitTag)

		Group[character] = {
			character = character,
			account = account,
			role = role
		}
	end
end

-- =========================
-- Joined
-- =========================
function GL.OnGroupMemberJoined(_, memberCharacterName, memberDisplayName, isLocalPlayer)
	local charName = GL.CleanName(memberCharacterName)

	if isLocalPlayer then
		enableMessages = true
	end

	if not enableMessages then return end

	GL.RebuildGroup()

	if isLocalPlayer then
		d(ARROW_JOIN .. GROUP_ICON)
	else
		local role = nil
		if IsActiveWorldBattleground() then
			role = LFG_ROLE_DPS
		else
			role = Group[charName].role
		end
		local icon = ROLE_ICONS[role] or ROLE_ICONS[LFG_ROLE_DPS]
		local accLink = "|cCCCCCC" .. ZO_LinkHandler_CreatePlayerLink(memberDisplayName) .. "|r"
		d(ARROW_JOIN .. icon .. " |c00FF00" .. charName .. "|r " .. accLink)
	end
end

-- =========================
-- Left
-- =========================
function GL.OnGroupMemberLeft(_, memberCharacterName, reason, isLocalPlayer, _, memberDisplayName)
	if not enableMessages then return end

	local charName = GL.CleanName(memberCharacterName)

	if isLocalPlayer then
		if reason == GROUP_LEAVE_REASON_KICKED then
			d(ARROW_KICKED .. GROUP_ICON)
		else
			d(ARROW_QUIT .. GROUP_ICON)
		end
		enableMessages = false
		ZO_ClearTable(Group)
		return
	end

	local role = nil
	if IsActiveWorldBattleground() then
		role = LFG_ROLE_DPS
	else
		role = Group[charName].role
	end
	local icon = ROLE_ICONS[role] or ROLE_ICONS[LFG_ROLE_DPS]
	local accLink = "|cCCCCCC" .. ZO_LinkHandler_CreatePlayerLink(memberDisplayName) .. "|r"

	if reason == GROUP_LEAVE_REASON_KICKED then
		d(ARROW_KICKED .. icon .. " |cFF0000" .. charName .. "|r " .. accLink)
	else
		d(ARROW_QUIT .. icon .. " |cFF0000" .. charName .. "|r " .. accLink)
	end

	Group[charName] = nil
end

-- =========================
-- RoleChanged
-- =========================
function GL.OnGroupMemberRoleChanged(_, unitTag, newRole)
	if not enableMessages then return end
	if newRole == 0 then return end

	local charName = GL.CleanName(GetUnitName(unitTag))
	local accName = GetUnitDisplayName(unitTag)

	if not Group[charName] then
		return
	end

	local oldRole = Group[charName].role

	if newRole == oldRole then
		return
	end

	local accLink = "|cBBBBBB" .. ZO_LinkHandler_CreatePlayerLink(accName) .. "|r"
	local oldIcon = ROLE_ICONS[oldRole]
	local newIcon = ROLE_ICONS[newRole]

	d(ARROW_CHANGED .. oldIcon .. newIcon .. " |c3399FF" .. charName .. "|r " .. accLink)

	Group[charName].role = newRole
end

-- =========================
-- Init
-- =========================
function GL.OnAddonLoaded(_, addonName)
	if addonName ~= GL.name then return end
	EM:UnregisterForEvent(GL.name, EVENT_ADD_ON_LOADED)

	EM:RegisterForEvent(GL.name, EVENT_GROUP_MEMBER_JOINED, GL.OnGroupMemberJoined)
	EM:RegisterForEvent(GL.name, EVENT_GROUP_MEMBER_LEFT, GL.OnGroupMemberLeft)
	EM:RegisterForEvent(GL.name, EVENT_GROUP_MEMBER_ROLE_CHANGED, GL.OnGroupMemberRoleChanged)
	EM:RegisterForEvent(GL.name, EVENT_PLAYER_ACTIVATED, GL.RebuildGroup)
end

EM:RegisterForEvent(GL.name, EVENT_ADD_ON_LOADED, GL.OnAddonLoaded)