local Settings = {}
local LAM2

EVENT_INDICATOR_MOVED = "EVENT_INDICATOR_MOVED"

local defaultSettingsTable = {
	isIdleEmotesOn = true,
	isLoreWearOn = true,
	isSmartEmotesIndicatorOn = true,
	canPlayInstrumentsInCities = true,
	canDanceInCities = true,
	canBeDrunkInCities = true,
	canExerciseInZone = true,
	canWorship = true,
	isCameraSpinDisabled = true,

	isUsingFavorite = {
		[Costumes] = false,
		[Hats] = false,
		[Skins] = false,
		[Hair] = false,
		[Polymorphs] = false,
		[FacialAcc] = false,
		[FacialHair] = false,
		[BodyMarkings] = false,
		[HeadMarkings] = false,
		[Jewelry] = false,
		[Personalities] = false,
		[VanityPets] = false,
	},

	outfitTable = {
		[City] = {
			[Costumes] = 0,
			[Hats] = 0,
			[Hair] = 0,
			[Skins] = 0,
			[Polymorphs] = 0,
			[FacialAcc] = 0,
			[FacialHair] = 0,
			[BodyMarkings] = 0,
			[HeadMarkings] = 0,
			[Jewelry] = 0,
			[Personalities] = 0,
			[VanityPets] = 0,
		},
		[Housing] = {
			[Costumes] = 0,
			[Hats] = 0,
			[Hair] = 0,
			[Skins] = 0,
			[Polymorphs] = 0,
			[FacialAcc] = 0,
			[FacialHair] = 0,
			[BodyMarkings] = 0,
			[HeadMarkings] = 0,
			[Jewelry] = 0,
			[Personalities] = 0,
			[VanityPets] = 0,
		},
		[Dungeon] = {
			[Costumes] = 0,
			[Hats] = 0,
			[Hair] = 0,
			[Skins] = 0,
			[Polymorphs] = 0,
			[FacialAcc] = 0,
			[FacialHair] = 0,
			[BodyMarkings] = 0,
			[HeadMarkings] = 0,
			[Jewelry] = 0,
			[Personalities] = 0,
			[VanityPets] = 0,
		},
		[Adventure] = {
			[Costumes] = 0,
			[Hats] = 0,
			[Hair] = 0,
			[Skins] = 0,
			[Polymorphs] = 0,
			[FacialAcc] = 0,
			[FacialHair] = 0,
			[BodyMarkings] = 0,
			[HeadMarkings] = 0,
			[Jewelry] = 0,
			[Personalities] = 0,
			[VanityPets] = 0,
		}
	},

	canActivateLWClothesWhileMounted = false,
	maraSpouseName = "",
	indicatorLeft = nil,
	indicatorTop = nil,
	timeBetweenIdleEmotes = 30000
}


local function updateSpouseName(newMaraSpouseName)
	Settings.savedSettingsTable.maraSpouseName = newMaraSpouseName
	Settings.savedVariables.maraSpouseName = Settings.savedSettingsTable.maraSpouseName
end


function Settings.LoadSavedSettings()
	Settings.savedSettingsTable = {}
	Settings.savedSettingsTable.isIdleEmotesOn = Settings.savedVariables.isIdleEmotesOn
	Settings.savedSettingsTable.isLoreWearOn = Settings.savedVariables.isLoreWearOn
	Settings.savedSettingsTable.isSmartEmotesIndicatorOn = Settings.savedVariables.isSmartEmotesIndicatorOn
	Settings.savedSettingsTable.canPlayInstrumentsInCities = Settings.savedVariables.canPlayInstrumentsInCities
	Settings.savedSettingsTable.canDanceInCities = Settings.savedVariables.canDanceInCities
	Settings.savedSettingsTable.canBeDrunkInCities = Settings.savedVariables.canBeDrunkInCities
	Settings.savedSettingsTable.canExerciseInZone = Settings.savedVariables.canExerciseInZone
	Settings.savedSettingsTable.canWorship = Settings.savedVariables.canWorship
	Settings.savedSettingsTable.isCameraSpinDisabled = Settings.savedVariables.isCameraSpinDisabled
	Settings.savedSettingsTable.isUsingFavorite = Settings.savedVariables.isUsingFavorite
	Settings.savedSettingsTable.outfitTable = Settings.savedVariables.outfitTable
	Settings.savedSettingsTable.maraSpouseName = Settings.savedVariables.maraSpouseName
	Settings.savedSettingsTable.canActivateLWClothesWhileMounted = Settings.savedVariables.canActivateLWClothesWhileMounted
	Settings.savedSettingsTable.indicatorLeft = Settings.savedVariables.indicatorLeft
	Settings.savedSettingsTable.indicatorTop = Settings.savedVariables.indicatorTop
	Settings.savedSettingsTable.timeBetweenIdleEmotes = Settings.savedVariables.timeBetweenIdleEmotes
end


local function ResetIndicator()
	SmartEmotesIndicator:ClearAnchors()
	SmartEmotesIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
	Settings.savedSettingsTable.indicatorLeft = nil
	Settings.savedSettingsTable.indicatorTop = nil
	Settings.savedVariables.indicatorLeft = Settings.savedSettingsTable.indicatorLeft
	Settings.savedVariables.indicatorTop = Settings.savedSettingsTable.indicatorTop
end


local function OnIndicatorMoved(eventCode, top, left)
	Settings.savedSettingsTable.indicatorTop = top
	Settings.savedSettingsTable.indicatorLeft = left
	Settings.savedVariables.indicatorTop = Settings.savedSettingsTable.indicatorTop
	Settings.savedVariables.indicatorLeft = Settings.savedSettingsTable.indicatorLeft
end

--[[
local function SetFavoriteCostume(tableToOutfit)
	local collectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)
	if collectibleId == 0 then CHAT_SYSTEM:AddMessage("No costume was detected.") end
	tableToOutfit[Costumes] = collectibleId
	Settings.savedVariables.outfitTable = Settings.savedSettingsTable.outfitTable
	Settings.savedSettingsTable.isUsingFavorite[Costumes] = true
	Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
	CHAT_SYSTEM:AddMessage("Favorite costume set as '"..GetCollectibleName(collectibleId).."'")
end


local function SetFavoriteHat(tableToOutfit)
	local didChange = true
	local collectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT)
	local name = GetCollectibleName(collectibleId)
	if collectibleId == 0 then 
		CHAT_SYSTEM:AddMessage("No hat was detected.") 
		name = "None"
		didChange = false
	end
	tableToOutfit[Hats] = collectibleId
	Settings.savedVariables.outfitTable = Settings.savedSettingsTable.outfitTable
	if didChange then
		Settings.savedSettingsTable.isUsingFavorite[Hats] = true
		Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
	end
	CHAT_SYSTEM:AddMessage("Favorite hat set as '"..name.."'")
end


local function SetFavoriteHair(tableToOutfit)
	local didChange = true
	local collectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAIR)
	local name = GetCollectibleName(collectibleId)
	if collectibleId == 0 then 
		CHAT_SYSTEM:AddMessage("Default hair detected.") 
		name = "Default"
		didChange = false
	end
	tableToOutfit[Hair] = collectibleId
	Settings.savedVariables.outfitTable = Settings.savedSettingsTable.outfitTable
	if didChange then
		Settings.savedSettingsTable.isUsingFavorite[Hair] = true
		Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
	end
	CHAT_SYSTEM:AddMessage("Favorite hair set as '"..name.."'")
end


local function SetFavoriteSkin(tableToOutfit)
	local didChange = true
	local collectibleId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN)
	local name = GetCollectibleName(collectibleId)
	if collectibleId == 0 then 
		CHAT_SYSTEM:AddMessage("No skin was detected.") 
		name = "None"
		didChange = false
	end
	tableToOutfit[Skins] = collectibleId
	Settings.savedVariables.outfitTable = Settings.savedSettingsTable.outfitTable
	if didChange then
		Settings.savedSettingsTable.isUsingFavorite[Skins] = true
		Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
	end
	CHAT_SYSTEM:AddMessage("Favorite skin set as '"..name.."'")
end
]]--





local function SetFavoriteCollectible(tableToOutfit, LPCatString)
	local didChange = true
	local collectibleId = GetActiveCollectibleByType(stringToColTypeTable[LPCatString])
	local name = GetCollectibleName(collectibleId)
	if collectibleId == 0 then 
		name = "None"
		didChange = false
	end
	tableToOutfit[LPCatString] = collectibleId
	Settings.savedVariables.outfitTable = Settings.savedSettingsTable.outfitTable
	if didChange then
		Settings.savedSettingsTable.isUsingFavorite[LPCatString] = true
		Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
	end
	CHAT_SYSTEM:AddMessage(LPCatString.." set as ".."'"..name.."'.")
end



local function SetFavoriteOutfit(outfitsTable, whichOutfitString)
	CHAT_SYSTEM:AddMessage(whichOutfitString.." Outfit:")

	for i,_ in pairs(stringToColTypeTable) do
		if Settings.savedSettingsTable.isUsingFavorite[i] then
			SetFavoriteCollectible(outfitsTable[whichOutfitString], i)
		end
	end
	CHAT_SYSTEM:AddMessage("Success.")
end


function Settings.ToggleIdleEmotes(settings)
	if Settings.savedSettingsTable.isIdleEmotesOn == settings then return end
	Settings.savedSettingsTable.isIdleEmotesOn = settings
	Settings.savedVariables.isIdleEmotesOn = Settings.savedSettingsTable.isIdleEmotesOn
	if not Settings.savedSettingsTable.isIdleEmotesOn then LorePlay.UnregisterIdleEvents() end
	LorePlay.InitializeIdle()
	if settings then 
		CHAT_SYSTEM:AddMessage("Toggled IdleEmotes on")
	else
		CHAT_SYSTEM:AddMessage("Toggled IdleEmotes off")
	end
end


-- Fixes "Cannot play emote at this time" in most circumstances
local scenes = {}
local function noCameraSpin()
	if Settings.savedSettingsTable.isCameraSpinDisabled then
	    for name, scene in pairs(SCENE_MANAGER.scenes) do
	      if not name:find("market") and not name:find("store") and not name:find("crownCrate") and not name:find("housing") and scene:HasFragment(FRAME_PLAYER_FRAGMENT) then
	        scene:RemoveFragment(FRAME_PLAYER_FRAGMENT)
	        scenes[name] = scene
	      end
	    end
	else
		for name, scene in pairs(scenes) do
    		scene:AddFragment(FRAME_PLAYER_FRAGMENT)
    	end
    end
end

local function OnPlayerMaraResult(eventCode, isGettingMarried, playerMarriedTo)
	if eventCode ~= EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE then return end
	if not isGettingMarried then
		updateSpouseName(playerMarriedTo)
	end
end


function Settings.LoadMenuSettings()
	local panelData = {
		type = "panel",
		name = LorePlay.name,
		displayName = "|c8c7037LorePlay",
		author = "Justinon",
		version = LorePlay.version,
		slashCommand = "/loreplay",
		registerForRefresh = true,
	}

	local optionsTable = {
		[1] = {
			type = "header",
			name = "Smart Emotes",
			width = "full",
		},
		[2] = {
			type = "description",
			title = nil,
			text = "Contextual, appropriate emotes to perform at the touch of a button.\nBy default, pressing performs an emote based on location. However, it adapts and conforms to many different special environmental situations along your travels as well.\n|cFF0000Don't forget to bind your SmartEmotes button!|r",
			width = "full",
		},
		[3] = {
			type = "editbox",
			name = "Significant Other's Character Name",
			tooltip = "For those who have wed with the Ring of Mara, entering the exact character name of your loved one allows for special emotes between you two!\n(Note: Must be friends!)",
			getFunc = function() return Settings.savedSettingsTable.maraSpouseName end,
			setFunc = function(input)
				Settings.savedSettingsTable.maraSpouseName = input
				Settings.savedVariables.maraSpouseName = Settings.savedSettingsTable.maraSpouseName
			end,
			isMultiline = false,
			width = "full",
			default = "",
		},
		[4] = {
			type = "checkbox",
			name = "Toggle Indicator On/Off",
			tooltip = "Turns on/off the small, moveable indicator (drama masks) that appears on your screen whenever new special adaptive SmartEmotes are available to be performed.",
			getFunc = function() return Settings.savedSettingsTable.isSmartEmotesIndicatorOn end,
			setFunc = function(setting) 
				Settings.savedSettingsTable.isSmartEmotesIndicatorOn = setting
				Settings.savedVariables.isSmartEmotesIndicatorOn = Settings.savedSettingsTable.isSmartEmotesIndicatorOn
				if not Settings.savedSettingsTable.isSmartEmotesIndicatorOn then
					SmartEmotesIndicator:SetHidden(true)
				end
			end,
			width = "full",
		},
		[5] = {
			type = "button",
			name = "Reset Indicator Position",
			tooltip = "Resets the indicator to be positioned in the top left of the screen.",
			func = function() ResetIndicator() end,
			width = "full",
		},
		[6] = {
			type = "header",
			name = "Idle Emotes",
			width = "full",
		},
		[7] = {
			type = "description",
			title = nil,
			text = "Contextual, automatic emotes that occur when you go idle or AFK (Not moving, not fighting, not stealthing).\n|cFF0000Don't forget to bind your IdleEmotes keypress for quick toggling!|r",
			width = "full",
		},
		[8] = {
			type = "checkbox",
			name = "Toggle IdleEmotes On/Off",
			tooltip = "Turns on/off the automatic, contextual emotes that occur when you go idle or AFK.\n(Note: Disabling IdleEmotes displays all its settings as off, but will persist after re-enabling.)",
			getFunc = function() return Settings.savedSettingsTable.isIdleEmotesOn end,
			setFunc = function(setting) 
				Settings.ToggleIdleEmotes(setting)
			end,
			width = "full",
			reference = "IdleEmotesToggleCheckbox",
		},
		[9] = {
			type = "slider",
			name = "Emote Duration",
			tooltip = "Determines how long in seconds a given idle emote will be performed before switching to a new one.\nDefault is 30 seconds.",
			min = 10,
			max = 120,
			step = 2,
			getFunc = function() 
				return Settings.savedSettingsTable.timeBetweenIdleEmotes/1000 -- Converting ms to s
			end,
			setFunc = function(value)
				if not Settings.savedSettingsTable.isIdleEmotesOn then return end
				Settings.savedSettingsTable.timeBetweenIdleEmotes = (value*1000) -- Converting seconds to ms
				Settings.savedVariables.timeBetweenIdleEmotes = Settings.savedSettingsTable.timeBetweenIdleEmotes
			end,
			width = "full",
			default = 30,
		},
		[10] = {
			type = "checkbox",
			name = "Can Play Instruments In Cities",
			tooltip = "Determines whether or not your character can perform instrument emotes when idle in cities.",
			getFunc = function() 
				if Settings.savedSettingsTable.isIdleEmotesOn then
					return Settings.savedSettingsTable.canPlayInstrumentsInCities
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isIdleEmotesOn then return end
				Settings.savedSettingsTable.canPlayInstrumentsInCities = setting
				Settings.savedVariables.canPlayInstrumentsInCities = Settings.savedSettingsTable.canPlayInstrumentsInCities
				LorePlay.CreateDefaultIdleEmotesTable()
			end,
			width = "full",
		},
		[11] = {
			type = "checkbox",
			name = "Can Dance In Cities",
			tooltip = "Determines whether or not your character can perform dance emotes when idle in cities.",
			getFunc = function() 
				if Settings.savedSettingsTable.isIdleEmotesOn then
					return Settings.savedSettingsTable.canDanceInCities
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isIdleEmotesOn then return end
				Settings.savedSettingsTable.canDanceInCities = setting
				Settings.savedVariables.canDanceInCities = Settings.savedSettingsTable.canDanceInCities
				LorePlay.CreateDefaultIdleEmotesTable()
			end,
			width = "full",
		},
		[12] = {
			type = "checkbox",
			name = "Can Be Drunk In Cities",
			tooltip = "Determines whether or not your character can perform drunken emotes when idle in cities.",
			getFunc = function() 
				if Settings.savedSettingsTable.isIdleEmotesOn then
					return Settings.savedSettingsTable.canBeDrunkInCities
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isIdleEmotesOn then return end
				Settings.savedSettingsTable.canBeDrunkInCities = setting
				Settings.savedVariables.canBeDrunkInCities = Settings.savedSettingsTable.canBeDrunkInCities
				LorePlay.CreateDefaultIdleEmotesTable()
			end,
			width = "full",
		},
		[13] = {
			type = "checkbox",
			name = "Can Exercise Outside Cities",
			tooltip = "Determines whether or not your character can perform exercise emotes when idle outside of cities.",
			getFunc = function() 
				if Settings.savedSettingsTable.isIdleEmotesOn then
					return Settings.savedSettingsTable.canExerciseInZone
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isIdleEmotesOn then return end
				Settings.savedSettingsTable.canExerciseInZone = setting
				Settings.savedVariables.canExerciseInZone = Settings.savedSettingsTable.canExerciseInZone
				LorePlay.CreateDefaultIdleEmotesTable()
			end,
			width = "full",
		},
		[14] = {
			type = "checkbox",
			name = "Can Worship/Pray",
			tooltip = "Determines whether or not your character can perform prayer and worship emotes when idle in general.",
			getFunc = function() 
				if Settings.savedSettingsTable.isIdleEmotesOn then
					return Settings.savedSettingsTable.canWorship
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isIdleEmotesOn then return end
				Settings.savedSettingsTable.canWorship = setting
				Settings.savedVariables.canWorship = Settings.savedSettingsTable.canWorship
				LorePlay.CreateDefaultIdleEmotesTable()
			end,
			width = "full",
		},
		[15] = {
			type = "checkbox",
			name = "Camera Spin Disabler",
			tooltip = "Allows for emotes to be performed while in menus. Disables camera spin in menus. Removes 'Cannot play emote at this time' message.",
			getFunc = function() 
				if Settings.savedSettingsTable.isCameraSpinDisabled then
					return true
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isIdleEmotesOn then return end
				Settings.savedSettingsTable.isCameraSpinDisabled = setting
				Settings.savedVariables.isCameraSpinDisabled = Settings.savedSettingsTable.isCameraSpinDisabled
				noCameraSpin()
			end,
			width = "full",
		},
		[16] = {
			type = "header",
			name = "Lore Wear",
			width = "full",
		},
		[17] = {
			type = "description",
			title = nil,
			text = "Armor should be worn when venturing Tamriel, but not when in comfortable cities! Your character will automatically and appropriately equip their favorite collectibles depending on where they are.\n|cFF0000Don't forget to bind your LoreWear show/hide clothes button!|r",
			width = "full",
		},
		[18] = {
			type = "checkbox",
			name = "Toggle LoreWear On/Off",
			tooltip = "Turns on/off the automatic, contextual clothing that will be put on when entering the areas respective to your outfits.\n(Note: Disabling LoreWear displays all its settings as off, but will persist after re-enabling.)",
			getFunc = function() return Settings.savedSettingsTable.isLoreWearOn end,
			setFunc = function(setting) 
				Settings.savedSettingsTable.isLoreWearOn = setting
				Settings.savedVariables.isLoreWearOn = Settings.savedSettingsTable.isLoreWearOn
				if not Settings.savedSettingsTable.isLoreWearOn then 
					LorePlay.UnregisterLoreWearEvents()
				else
					LorePlay.ReenableLoreWear()
				end
			end,
			width = "full",
		},
		[19] = {
			type = "checkbox",
			name = "Allow Equip While Mounted",
			tooltip = "Turns on/off the automatic, contextual clothing that can be put on while riding your trusty steed.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.canActivateLWClothesWhileMounted
				else
					return false
				end
			end,
			setFunc = function(setting) 
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.canActivateLWClothesWhileMounted = setting
				Settings.savedVariables.canActivateLWClothesWhileMounted = Settings.savedSettingsTable.canActivateLWClothesWhileMounted 
			end,
			width = "full",
		},
		[20] = {
			type = "checkbox",
			name = "Use Favorite Costume",
			tooltip = "If enabled, uses your favorite costume in outfits, along with your other favrotie collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[Costumes] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[Costumes] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite 
			end,
			width = "full",
			default = false,
		},
		[21] = {
			type = "checkbox",
			name = "Use Favorite Hat",
			tooltip = "If enabled, uses your favorite hat in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[Hats]
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[Hats] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[22] = {
			type = "checkbox",
			name = "Use Favorite Hair",
			tooltip = "If enabled, uses your favorite hair in outfits, along with your other favorite collecibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[Hair]
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[Hair] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[23] = {
			type = "checkbox",
			name = "Use Favorite Skin",
			tooltip = "If enabled, uses your favorite skin in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[Skins] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[Skins] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[24] = {
			type = "checkbox",
			name = "Use Favorite Polymorphs",
			tooltip = "If enabled, uses your favorite polymorph in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[Polymorphs] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[Polymorphs] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[25] = {
			type = "checkbox",
			name = "Use Favorite Facial Accessories",
			tooltip = "If enabled, uses your favorite facial accessories in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[FacialAcc] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[FacialAcc] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[26] = {
			type = "checkbox",
			name = "Use Favorite Facial Hair",
			tooltip = "If enabled, uses your favorite facial hairs/horns in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[FacialHair] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[FacialHair] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[27] = {
			type = "checkbox",
			name = "Use Favorite Body Markings",
			tooltip = "If enabled, uses your favorite body markings in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[BodyMarkings] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[BodyMarkings] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[28] = {
			type = "checkbox",
			name = "Use Favorite Head Markings",
			tooltip = "If enabled, uses your favorite head markings in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[HeadMarkings] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[HeadMarkings] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[29] = {
			type = "checkbox",
			name = "Use Favorite Jewelry",
			tooltip = "If enabled, uses your favorite jewelry in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[Jewelry] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[Jewelry] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[30] = {
			type = "checkbox",
			name = "Use Favorite Personalities",
			tooltip = "If enabled, uses your favorite personalities in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[Personalities] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[Personalities] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[31] = {
			type = "checkbox",
			name = "Use Favorite Pets",
			tooltip = "If enabled, uses your favorite vanity pets in outfits, along with your other favorite collectibles.\n|cFF0000Note|r: Use if you want to save 'None' as your favorite, treating the empty slot as a piece of your outfit.",
			getFunc = function() 
				if Settings.savedSettingsTable.isLoreWearOn then
					return Settings.savedSettingsTable.isUsingFavorite[VanityPets] 
				else
					return false
				end
			end,
			setFunc = function(setting)
				if not Settings.savedSettingsTable.isLoreWearOn then return end
				Settings.savedSettingsTable.isUsingFavorite[VanityPets] = setting
				Settings.savedVariables.isUsingFavorite = Settings.savedSettingsTable.isUsingFavorite
			end,
			width = "full",
			default = false,
		},
		[32] = {
			type = "button",
			name = "Set City Outfit",
			tooltip = "Sets the current outfit (collectibles) your character is wearing as their city outfit, allowing for automatic collectible changing when entering a city.\nAlso saves |cFF0000empty slots|r if the 'Use Favorite ...' setting for that category is enabled!",
			func = function()
				SetFavoriteOutfit(Settings.savedSettingsTable.outfitTable, City)
			end,
			width = "half",
		},
		[33] = {
			type = "button",
			name = "Set Housing Outfit",
			tooltip = "Sets the current outfit (collectibles) your character is wearing as their housing outfit, allowing for automatic collectible changing when entering a house.\nAlso saves |cFF0000empty slots|r if the 'Use Favorite ...' setting for that category is enabled!",
			func = function()
				SetFavoriteOutfit(Settings.savedSettingsTable.outfitTable, Housing)
			end,
			width = "half",
		},
		[34] = {
			type = "button",
			name = "Set Dungeon Outfit",
			tooltip = "Sets the current outfit (collectibles) your character is wearing as their dungeon outfit, allowing for automatic collectible changing when entering a dungeon.\nAlso saves |cFF0000empty slots|r if the 'Use Favorite ...' setting for that category is enabled!",
			func = function()
				SetFavoriteOutfit(Settings.savedSettingsTable.outfitTable, Dungeon)
			end,
			width = "half",
		},
		[35] = {
			type = "button",
			name = "Set Adventure Outfit",
			tooltip = "Sets the current outfit (collectibles) your character is wearing as their adventuring outfit, allowing for automatic collectible changing when running around the land of Tamriel.\nAlso saves |cFF0000empty slots|r if the 'Use Favorite ...' setting for that category is enabled!",
			func = function()
				SetFavoriteOutfit(Settings.savedSettingsTable.outfitTable, Adventure)
			end,
			width = "half",
		},
	}

	LAM2:RegisterAddonPanel("LorePlayOptions", panelData)
	LAM2:RegisterOptionControls("LorePlayOptions", optionsTable)
end


local function RegisterSettingsEvents()
	LPEventHandler:RegisterForLocalEvent(EVENT_INDICATOR_MOVED, OnIndicatorMoved)
	LPEventHandler:RegisterForLocalEvent(EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE, OnPlayerMaraResult)
end


function Settings.InitializeSettings()
	Settings.savedVariables = ZO_SavedVars:New("LorePlaySavedVars", LorePlay.majorVersion, nil, defaultSettingsTable)
	Settings.LoadSavedSettings()
	LAM2 = LibStub("LibAddonMenu-2.0")
	Settings.LoadMenuSettings()
	noCameraSpin()
	RegisterSettingsEvents()
end


LorePlay = Settings