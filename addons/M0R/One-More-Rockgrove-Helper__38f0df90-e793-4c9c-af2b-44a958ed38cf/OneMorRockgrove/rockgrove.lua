OneMorRockgrove = {}
local omr = OneMorRockgrove -- local var for easy access
omr.name = "OneMorRockgrove"
omr.vars = {}



-- This file mainly handles admin stuff such as init + boss detection.
-- For each specific boss, refer to the file in ./bosses/




omr.zonedIn = false
function omr.playerActivated()
	local zone, _, _, _ = GetUnitRawWorldPosition("player")
	if zone == 1263 and (not omr.zonedIn) then
		omr.activateRG()
		omr.zonedIn = true
	elseif (not zone == 1263) and omr.zonedIn then
		omr.deactivateRG()
		omr.zonedIn = false
	end
end



function omr.activateRG()
	--d("Activated")
	EVENT_MANAGER:RegisterForEvent(omr.name, EVENT_PLAYER_COMBAT_STATE, omr.combatStateCheck)
	EVENT_MANAGER:RegisterForEvent(omr.name, EVENT_UNIT_DEATH_STATE_CHANGED, omr.combatStateCheck)
	EVENT_MANAGER:RegisterForEvent(omr.name, EVENT_PLAYER_ACTIVATED, omr.combatStateCheck)
	omr.combatStateCheck(1)
end

function omr.deactivateRG()
	--d("Deactivated")
	omr.activeBoss = nil
	omr.deactivateOax()
	omr.deactivateBahsei()
	EVENT_MANAGER:UnregisterForEvent(omr.name, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForEvent(omr.name, EVENT_UNIT_DEATH_STATE_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(omr.name, EVENT_PLAYER_ACTIVATED)
end



omr.activeBoss = ""
omr.combatState = false
function omr.combatStateCheck(state)
	--d("Activated "..state)
	if IsUnitDead('player') then return end
	if IsUnitInCombat('player') then
		if omr.combatState then return end -- might work to stop edge case scenarios (bahsei portals) where the boss unloads
		omr.combatState = true

		local currentBoss = string.lower(GetUnitName("boss1"))
		--d(currentBoss..' '..omr.activeBoss)
		if not (omr.activeBoss == currentBoss) then
			omr.activeBoss = currentBoss
			local id = omr.bossLookup[currentBoss]
			if id == nil then return end
			omr.bossRegistry[id]()
		end
	else
		omr.activeBoss = ""
		omr.deactivateOax()
		omr.deactivateBahsei()
		omr.combatState = false
	end
end









omr.bossRegistry = {
	[1] = omr.activateOax,
	[2] = omr.activateBahsei
}

-- /script SetCVar("language.2", "de")
-- /script CHAT_SYSTEM:StartTextEntry(string.lower(GetUnitName("boss1")))
omr.bossLookup = { -- for other languages
	["oaxiltso"] = 1,
	["оазилцо"] = 1,
	["奥西索"] = 1,
	["bahsei"] = 2,
	["flame-herald bahsei"] = 2, -- en
	["flammenheroldin bahsei"] = 2, -- de
	["bahsei la emisaria del fuego"] = 2, -- es
	["le héraut des flammes bahsei"] = 2, --fr
	["басей вестница пламени"] = 2, --ru
	["烈焰先驱巴塞"] = 2 --zh
}








omr.varversion = 1

omr.settings = {}
omr.settings.DefaultSettings = {
	reverseRed = false,
	showSafeBorders = true,
	enableRedIndicator = false,
	bahseiInitialCW = "Boring Corner",
	bahseiInitialCCW = "Portal",
	goodConePrediction = true,
	initialConeIndicator = false,
	bahseiInitialGroundArrows = false,
	breadcrumbsOaxLines = true,
	breadcrumbsBahseiInitialLine = true,
	breadcrumbsBahseiPortalLine = true,
	bahseiPortalIcon = true,
	bahseiPortalSegments = true,
	customOaxLines = true,
}





-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function omr.OnAddOnLoaded(event, addonName) -- Runs for all addons which load, so make sure that init is only called for this addon
	if addonName ~= omr.name then return end
	omr:Initialize()
	
end

-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(omr.name, EVENT_ADD_ON_LOADED, omr.OnAddOnLoaded)

-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function omr:Initialize()
	EVENT_MANAGER:UnregisterForEvent(omr.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(omr.name .. "AlwaysActive", EVENT_PLAYER_ACTIVATED, omr.playerActivated)

	omr.worldIcons = LibCombatAlerts.WorldDrawing:New()

	omr.vars = ZO_SavedVars:NewAccountWide("OMRSettings", omr.varversion, nil, omr.settings.DefaultSettings)
	omr.settings.createSettings()
end
