function RAS.initializeSettingsMenu()

	local defaults = {
		changePoly = true,
		lastPoly = 0,
		polyId = 0,
		changeOutfit = false,
		lastOutfit = 0,
		outfitId = 0,
		lastZone = 0,
		zones = {
			["636"] = true,  -- Hel Ra Citadel
			["638"] = true,  -- Aetherian Archive
			["639"] = true,  -- Sanctum Ophidia
			["725"] = true,  -- Maw of Lorkhaj
			["975"] = true,  -- Halls of Fabrication
			["1000"] = true, -- Asylum Sanctorium
			["1051"] = true, -- Cloudrest
			["1121"] = true, -- Sunspire
			["635"] = true,  -- Dragonstar Arena
			["677"] = true,  -- Maelstrom Arena
			["1082"] = true, -- Blackrose Prison
		},
	}

	local panelData = {
		type = "panel",
		name = "Raid Auto Skeleton",
		displayName = "Raid Auto |cF0E68CSkeleton|r",
		author = "ownedbynico",
		version = RAS.version,
		registerForRefresh = true,
	}
	
	local outfitChoices = { [1] = "None"}
	local outfitChoicesValues = { [1] = 0 }
	for i = 1, GetNumUnlockedOutfits() do
		local outfitName = GetOutfitName(i)
		if outfitName == nil or outfitName == "" then outfitName = ("Outfit " .. i) end
		outfitChoices[i + 1] = outfitName
		outfitChoicesValues[i + 1] = i
	end
	
	local optionsData = {
		{
			type = "checkbox",
			name = "Change polymorph",
			tooltip = "This will hide your outfit",
			getFunc = function() return RAS.savedVariables.changePoly end,
			setFunc = function(value) RAS.savedVariables.changePoly = value end,
			width = "half",
		},
		{
			type = "dropdown",
			name = "",
			getFunc = function() return RAS.savedVariables.polyId end,
			setFunc = function(value) RAS.savedVariables.polyId = value end,
			choices = {"None", "Skeleton", "Factotum", "Clockwork Curator"},
			choicesValues = {0, 34, 1480, 4660},
			disabled = function() return not RAS.savedVariables.changePoly end,
			width = "half",
		},
		{
			type = "description",
			text = ""
		},
		{
			type = "checkbox",
			name = "Change outfit",
			getFunc = function() return RAS.savedVariables.changeOutfit end,
			setFunc = function(value) RAS.savedVariables.changeOutfit = value end,
			width = "half",
		},
		{
			type = "dropdown",
			name = "",
			getFunc = function() return RAS.savedVariables.outfitId end,
			setFunc = function(value) RAS.savedVariables.outfitId = value end,
			choices = outfitChoices,
			choicesValues = outfitChoicesValues,
			disabled = function() return not RAS.savedVariables.changeOutfit end,
			width = "half",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Hel Ra Citadel",
			getFunc = function() return RAS.savedVariables.zones["636"] end,
			setFunc = function(value) RAS.savedVariables.zones["636"] = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Aetherian Archive",
			getFunc = function() return RAS.savedVariables.zones["638"] end,
			setFunc = function(value) RAS.savedVariables.zones["638"] = value end,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Sanctum Ophidia",
			getFunc = function() return RAS.savedVariables.zones["639"] end,
			setFunc = function(value) RAS.savedVariables.zones["639"] = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Maw of Lorkhaj",
			getFunc = function() return RAS.savedVariables.zones["725"] end,
			setFunc = function(value) RAS.savedVariables.zones["725"] = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Halls of Fabrication",
			getFunc = function() return RAS.savedVariables.zones["975"] end,
			setFunc = function(value) RAS.savedVariables.zones["975"] = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Asylum Sanctorium",
			getFunc = function() return RAS.savedVariables.zones["1000"] end,
			setFunc = function(value) RAS.savedVariables.zones["1000"] = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Cloudrest",
			getFunc = function() return RAS.savedVariables.zones["1051"] end,
			setFunc = function(value) RAS.savedVariables.zones["1051"] = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Sunspire",
			getFunc = function() return RAS.savedVariables.zones["1121"] end,
			setFunc = function(value) RAS.savedVariables.zones["1121"] = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Dragonstar Arena",
			getFunc = function() return RAS.savedVariables.zones["635"] end,
			setFunc = function(value) RAS.savedVariables.zones["635"] = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Maelstrom Arena",
			getFunc = function() return RAS.savedVariables.zones["677"] end,
			setFunc = function(value) RAS.savedVariables.zones["677"] = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Blackrose Prison",
			getFunc = function() return RAS.savedVariables.zones["1082"] end,
			setFunc = function(value) RAS.savedVariables.zones["1082"] = value end,
			width = "full",
		},
	}

	RAS.savedVariables = ZO_SavedVars:NewCharacterIdSettings("RASSV", 1, nil, defaults)
	LibAddonMenu2:RegisterAddonPanel("RASS", panelData)
	LibAddonMenu2:RegisterOptionControls("RASS", optionsData)
end