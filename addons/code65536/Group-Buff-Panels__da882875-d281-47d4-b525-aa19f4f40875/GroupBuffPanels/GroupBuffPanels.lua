local LCA = LibCombatAlerts

GroupBuffPanels = {
	ID = "GroupBuffPanels",
	URL = "https://www.esoui.com/downloads/info4226.html",
}
local GBP = GroupBuffPanels


--------------------------------------------------------------------------------
-- Bootstrap
--------------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(GBP.ID, EVENT_ADD_ON_LOADED, function( eventCode, addonName )
	if (addonName ~= GBP.ID) then return end

	EVENT_MANAGER:UnregisterForEvent(GBP.ID, EVENT_ADD_ON_LOADED)

	-- Initialize settings
	GBP.LoadSettings()
	LCA.RunAfterInitialLoadscreen(GBP.RegisterSettingsPanel)

	-- Monitor the events that would load or unload panels
	local GroupChange = function( _, _, _, isLocalPlayer )
		if (isLocalPlayer) then
			GBP.RefreshEnablementStates()
		end
	end
	EVENT_MANAGER:RegisterForEvent(GBP.ID, EVENT_GROUP_MEMBER_JOINED, GroupChange)
	EVENT_MANAGER:RegisterForEvent(GBP.ID, EVENT_GROUP_MEMBER_LEFT, GroupChange)

	GBP.RegisterStockConditionalEnablements()

	-- The return from IsUnitGrouped is sometimes wrong immediately after a port
	LCA.MonitorZoneChanges(GBP.ID, function() zo_callLater(GBP.RefreshEnablementStates, IsUnitGrouped("player") and 500 or 2500) end)
end)


--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

do
	local SOLO_ZONES = {
		[ 677] = true, -- Maelstrom Arena
		[1227] = true, -- Vateshran Hollows
	}

	function GBP.GetLocationType( )
		local isInGroupPvE = LCA.IsInDungeonTrialArena() and not SOLO_ZONES[LCA.GetZoneId()]
		local isInPvP = IsPlayerInAvAWorld() or IsActiveWorldBattleground()
		local isInOther = not isInGroupPvE and not isInPvP
		return isInGroupPvE, isInPvP, isInOther
	end
end

function GBP.GetItemSetEquippedCount( itemSetId )
	local n, p = select(4, GetItemSetInfo(itemSetId))
	return n + p
end

do
	local HOTBARS = { HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP }
	local WWBAR = { HOTBAR_CATEGORY_WEREWOLF }

	function GBP.DoesPlayerHaveSkillSlotted( skills )
		for _, hotbarCategory in ipairs(GBP.wwState and WWBAR or HOTBARS) do
			for i = 3, 8 do
				local actionType = GetSlotType(i, hotbarCategory)
				if (actionType == ACTION_TYPE_ABILITY) then
					local abilityId = GetSlotBoundId(i, hotbarCategory)
					if (abilityId == skills) then
						return true
					elseif (type(skills) == "table") then
						for _, skillId in ipairs(skills) do
							if (abilityId == skillId) then
								return true
							end
						end
					end
				end
			end
		end
		return false
	end
end

do
	local ICON_OVERRIDES = {
		[172056] = 172055, -- Pillager's Profit
		[234295] = 160823, -- Arkay's Charity
	}

	function GBP.GetAbilityIcon( abilityId )
		return GetAbilityIcon(ICON_OVERRIDES[abilityId] or abilityId)
	end

	function GBP.OverrideAbilityIcon( abilityId, abilityIdNew )
		ICON_OVERRIDES[abilityId] = abilityIdNew
	end
end


--------------------------------------------------------------------------------
-- Color wheel traversal
--------------------------------------------------------------------------------

do
	local cache = { }

	function GBP.ClearColorCache( abilityId )
		if (abilityId) then
			cache[abilityId] = nil
		else
			cache = { }
		end
	end

	function GBP.GetColorUnpacked( abilityId, current, max )
		local c = cache[abilityId or 0]
		if (not c) then
			c = {
				s = { LCA.UnpackHSLA(GBP.GetPanelSetting("colorStart", abilityId)) },
				e = { LCA.UnpackHSLA(GBP.GetPanelSetting("colorEnd", abilityId)) },
			}
			if (GBP.GetPanelSetting("colorReverse", abilityId)) then
				c.e[1] = c.e[1] + (c.e[1] < c.s[1] and 1 or -1)
			end
			cache[abilityId or 0] = c
		end
		local sr = current / max
		local er = 1 - sr
		return LCA.HSLToRGB(
			c.s[1] * sr + c.e[1] * er,
			c.s[2] * sr + c.e[2] * er,
			c.s[3] * sr + c.e[3] * er,
			c.s[4] * sr + c.e[4] * er
		)
	end

	function GBP.GetColor( ... )
		return LCA.PackRGBA(GBP.GetColorUnpacked(...))
	end
end
