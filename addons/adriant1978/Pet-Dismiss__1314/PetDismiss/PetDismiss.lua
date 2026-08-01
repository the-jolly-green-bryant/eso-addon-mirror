PetDismiss = {}
PetDismiss.name = "PetDismiss"
PetDismiss.configVersion = 1
PetDismiss.defaults = {
  autodismiss = true,
}

-- All the abilityIDs for Familiars and Clannfears
PetDismiss.Familiars = { 23304, 30631, 30636, 30641, 23319, 30647, 30652, 30657, 23316, 30664, 30669, 30674 }

-- All the abilityIDs for Twilights
PetDismiss.Twilights = { 24613, 30581, 30584, 30587, 24636, 30592, 30595, 30598, 24639, 30618, 30622, 30626 }

-- All the abilityIDs for Grizzly Bears
PetDismiss.Grizzlys = { 85982, 85983, 85984, 85985, 85986, 85987, 85988, 85989, 85990, 85991, 85992, 85993 }

function PetDismiss:DismissAllPets()
	PetDismiss:DismissPet(PetDismiss.Familiars)
	PetDismiss:DismissPet(PetDismiss.Twilights)
	PetDismiss:DismissPet(PetDismiss.Grizzlys)
end

function PetDismiss:DismissPet(petList)

	local i, k, v
	
	-- Walk through the player's active buffs
	for i = 1, GetNumBuffs("player") do
		local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player", i)
		-- Compare each buff's abilityID to the list of IDs we were given
		for k, v in pairs(petList) do
			if abilityId == v then
				-- Cancel the buff if we got a match
				CancelBuff(buffSlot)
			end
		end
	end
	
end

function PetDismiss:OnCraftInteract(eventCode, craftSkill, sameStation)

  if PetDismiss.vars.autodismiss then PetDismiss:DismissAllPets() end
  
end

function PetDismiss:OnChatterBegin(eventCode, optionsCount)

  local isBanker = false
  if optionsCount and optionsCount > 0 then
    for i=1,optionsCount do
      local text, otype = GetChatterOption(i)
	  if otype == CHATTER_START_BANK then
	    isBanker = true
	  end
    end

    if isBanker then
	  if PetDismiss.vars.autodismiss then PetDismiss:DismissAllPets() end
	end
  end
  
end

function PetDismiss.OnAddOnLoaded(event, addonName)

	-- Initialization stuff
	
	if addonName == PetDismiss.name then
	
	-- Register our keybinding names
	ZO_CreateStringId("SI_BINDING_NAME_DISMISS_FAMILIAR", "Dismiss Familiar/Clannfear")
	ZO_CreateStringId("SI_BINDING_NAME_DISMISS_TWILIGHT", "Dismiss Twilight")
	ZO_CreateStringId("SI_BINDING_NAME_DISMISS_GRIZZLY", "Dismiss Grizzly")
	ZO_CreateStringId("SI_BINDING_NAME_DISMISS_ALL", "Dismiss All Pets")
	
	-- Load/create configuration
	PetDismiss.vars = ZO_SavedVars:NewAccountWide("PetDismissVars", PetDismiss.configVersion, nil, PetDismiss.defaults)
	
	-- Fetch addon version, etc
	local myName, myTitle, myAuthor, myDescription, myEnabled, myState, myOutOfDate
	local AddOnManager = GetAddOnManager()
    for i = 1, AddOnManager:GetNumAddOns() do
      myName, myTitle, myAuthor, myDescription, myEnabled, myState, myOutOfDate = AddOnManager:GetAddOnInfo(i)
      if myName == PetDismiss.name then break end
    end
	
	-- Create menu
	local LAM = LibAddonMenu2
	
	local controlData = {
      [1] = {
        type = "checkbox",
        name = "Politely auto-dismiss",
        tooltip = "Auto-dismiss pets at banker or craft station",
        getFunc = function() return PetDismiss.vars.autodismiss end,
        setFunc = function(newValue) PetDismiss.vars.autodismiss = newValue end,
        default = PetDismiss.defaults.autodismiss,
      },
    }
	
    local panelData = {
      type = "panel",
      name = "Pet Dismiss",
      displayName = myTitle,
      author = myAuthor,
      version = myVersion,
      registerForDefaults = true,
    }
	
	LAM:RegisterAddonPanel("PetDismissConfig", panelData)
    LAM:RegisterOptionControls("PetDismissConfig", controlData)

    -- Register for events
	EVENT_MANAGER:RegisterForEvent(PetDismiss.name, EVENT_CRAFTING_STATION_INTERACT, PetDismiss.OnCraftInteract)
	EVENT_MANAGER:RegisterForEvent(PetDismiss.name, EVENT_CHATTER_BEGIN, PetDismiss.OnChatterBegin)
	
	end
	
end

-- Do initialization when we receive EVENT_ADD_ON_LOADED
EVENT_MANAGER:RegisterForEvent(PetDismiss.name, EVENT_ADD_ON_LOADED, PetDismiss.OnAddOnLoaded)