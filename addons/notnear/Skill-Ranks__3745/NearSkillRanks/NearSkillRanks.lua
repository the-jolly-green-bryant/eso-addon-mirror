NEAR_SR = {
	name       = "NearSkillRanks",
	title      = "Near's Skill Ranks",
	shortTitle = "Skill Ranks",
	author     = "|cCC99FFnotnear|r",
}
local addon = NEAR_SR

NEAR_SR.SKILL_TYPE_TRADESKILL = 7

local function RegisterSlashCommands()
	-- toggle window
	SLASH_COMMANDS["/sr"] = NEAR_SR.gui.ToggleWindow
	SLASH_COMMANDS["/srq"] = NEAR_SR.gui.quick.ToggleWindow
	SLASH_COMMANDS["/sru"] = NEAR_SR.gui.unranked.ToggleWindow
end

local function OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED)
	addon.func.Init()
	addon.gui.Init()
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon loading
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)

	local asv_version = 1
	addon.ASV = {}
	addon.ASV.settings = ZO_SavedVars:NewAccountWide(addon.name .. "_Data", asv_version, 'settings', addon.defaults.settings, GetWorldName())
	addon.ASV.char     = ZO_SavedVars:NewAccountWide(addon.name .. "_Data", asv_version, 'char_data', addon.defaults.char, GetWorldName())

	RegisterSlashCommands()

	-- Events
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ABILITY_PROGRESSION_RANK_UPDATE, NEAR_SR.func.OnMorphRankUpdate)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_SKILL_RANK_UPDATE, NEAR_SR.func.OnSkillRankUpdate)
	EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_SKILL_LINE_ADDED, NEAR_SR.func.OnSkillLineAdded)

	if AddonCategory then
		AddonCategory.AssignAddonToCategory(addon.name, AddonCategory.baseCategories.Util)
	end
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
