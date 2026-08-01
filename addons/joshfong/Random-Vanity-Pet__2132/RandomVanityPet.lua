local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

RandomVanityPet = {}

RandomVanityPet.name = 'RandomVanityPet'
RandomVanityPet.version = 13 -- This should probably not be updated unless we're pushing a major update

RandomVanityPet.Default = {
	logPet = true,
	freq = GetString(RVP_FREQ_ON_LOGIN),
}

function RandomVanityPet.OnAddOnLoaded(event, addonName)
	if addonName == RandomVanityPet.name then
		RandomVanityPet:Initialize()
	end
end

function RandomVanityPet:Initialize()
	RandomVanityPet.savedVariables = ZO_SavedVars:New("RandomVanityPetVars", RandomVanityPet.version, nil, RandomVanityPet.Default)
	RandomVanityPet.CreateSettingsWindow()

	if (RandomVanityPet.savedVariables.freq ~= GetString(RVP_FREQ_NEVER)) then
		EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.TriggerRandomPet)
	end

	SLASH_COMMANDS["/randompet"] = function()
		RandomVanityPet.PickRandomPet()
	end

	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
end

function RandomVanityPet.CreateSettingsWindow()
	sv = RandomVanityPet.savedVariables

	local settingsWindowData = {
		type = "panel",
		name = "Random Vanity Pet",
		displayName = "Random Vanity Pet",
		author = "joshfong",
		version = "1.5.0",
		registerForRefresh = false,
		registerForDefaults = false,
	}

	local settingsOptionPanel = LAM2:RegisterAddonPanel("RandomVanityPet_Settings", settingsWindowData)

	local checkLabel = GetString(RVP_CHAT_DISPLAY_LABEL)
	local checkTooltip = GetString(RVP_CHAT_DISPLAY_TOOLTIP)
	local freqLabel = GetString(RVP_FREQ_LABEL)
	local freqTooltip = GetString(RVP_FREQ_TOOLTIP)
	local freqOnLogin = GetString(RVP_FREQ_ON_LOGIN)
	local freqOnLoadScreen = GetString(RVP_FREQ_ON_LOAD_SCREEN)
	local freqNever = GetString(RVP_FREQ_NEVER)
	local freqWarning = GetString(RVP_FREQ_WARNING)
	local reloadUILabel = GetString(RVP_RELOAD_UI_LABEL)

	local settingsOptionsData = {
		[1] = {
			type = "checkbox",
			name = checkLabel,
			tooltip = checkTooltip,
			default = true,
			getFunc = function() return sv.logPet end,
			setFunc = function(newValue) sv.logPet = newValue end,
		},
		[2] = {
			type = "dropdown",
			name = freqLabel,
			tooltip = freqTooltip,
			choices = {freqOnLogin, freqOnLoadScreen, freqNever},
			getFunc = function() return sv.freq end,
			setFunc = function(newValue) sv.freq = newValue end,
			warning = freqWarning,
		},
		[3] = {
			type = "button",
			name = reloadUILabel,
			func = function() ReloadUI() end,
			width = "half"
		}
	}

	LAM2:RegisterOptionControls("RandomVanityPet_Settings", settingsOptionsData)
end

function RandomVanityPet.TriggerRandomPet(eventCode, initial)
	-- We don't want a notification saying we can't equip a pet!
	flagged = IsUnitPvPFlagged('player')
	houseLimit = GetCurrentHousePopulationCap()
	sv = RandomVanityPet.savedVariables

	if (flagged == false and houseLimit == 1000) then
		if (sv.freq == GetString(RVP_FREQ_ON_LOGIN)) then
			EVENT_MANAGER:UnregisterForEvent(RandomVanityPet.name, eventCode)
		end
		RandomVanityPet.PickRandomPet()
	end
end

function RandomVanityPet.PickRandomPet()
	sv = RandomVanityPet.savedVariables

	-- Non-combat pets
	-- Top-level index: 9
	-- Category ID: 3

	topLevel = 9
	petsId = 3

	totalPets = GetTotalUnlockedCollectiblesByCategoryType(petsId)
	--whichPet = math.random(totalPets)
	whichPet = math.random(1000)

	petId = GetCollectibleIdFromType(petsId, whichPet)
	link = GetCollectibleLink(petId, 1)

	canBeUsed = IsCollectibleUsable(petId)
	inUse = IsCollectibleActive(petId)

	if (canBeUsed and inUse == false) then
		UseCollectible(petId)

		if (sv.logPet == true) then
			local chatLogText = GetString(RVP_PET_CHAT_LOG)

			CHAT_SYSTEM.containers[1].windows[1].buffer:AddMessage(chatLogText .. link)
		end
	else
		RandomVanityPet.PickRandomPet()
	end
end

EVENT_MANAGER:RegisterForEvent(RandomVanityPet.name, EVENT_ADD_ON_LOADED, RandomVanityPet.OnAddOnLoaded)
