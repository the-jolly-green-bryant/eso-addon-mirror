BSCACInteraction = BSCACInteraction or {}
local BSCACI = BSCACInteraction

BSCACI.Name = "BSCs-AntiCombatInteract"
BSCACI.NameSpaced = "BloodStainChild666's Anti Combat Interaction"
BSCACI.Author = "BloodStainChild666"
BSCACI.Version = "1.2"
BSCACI.SavedVar = "BSCACISaved"

local EM = GetEventManager()

local defaultSV = 
{
	ENABLED = true,
	ENABLED_ALWAYS_DISABLE = false,
	PVP_AREA_ENABLED = false,
}

function BSCACI.PreHook()	
	ZO_PreHook(PLAYER_TO_PLAYER, "ShowPlayerInteractMenu", function(isIgnored)  
		
		if BSCACI.SV.ENABLED then   
		
			local enable = true
			
			if IsUnitInCombat("player") and not BSCACI.SV.ENABLED_ALWAYS_DISABLE then enable = false end	
			if BSCACI.SV.PVP_AREA_ENABLED and (IsInCampaign() or IsActiveWorldBattleground()) then enable = true end			
			if BSCACI.SV.ENABLED_ALWAYS_DISABLE then enable = false end	
			
			if not enable then return true end  -- do not run original code 
			
			
			
		end
	end)
end


function BSCACI.InitAddon(event, addonName)
	if addonName ~= BSCACI.Name then return end	
	EM:UnregisterForEvent(BSCACI.Name, EVENT_ADD_ON_LOADED)		
	-- Saved vars are needed
	BSCACI.SV = ZO_SavedVars:NewCharacterNameSettings(BSCACI.SavedVar, "1", nil, defaultSV)
	BSCACI.buildMenu()
	BSCACI.PreHook()	
end

EM:RegisterForEvent(BSCACI.Name, EVENT_ADD_ON_LOADED, BSCACI.InitAddon)