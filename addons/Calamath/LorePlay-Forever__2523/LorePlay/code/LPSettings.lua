LorePlay = LorePlay or {}
-- --- definitions : local event codes for LibEventHandler
local EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE = "EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE"
local EVENT_INDICATOR_MOVED = "EVENT_INDICATOR_MOVED"

-- ------------------------------------------------------------

-- === LPSettings.lua ===

LorePlay.collectibleType = {
	COLLECTIBLE_CATEGORY_TYPE_COSTUME, 
	COLLECTIBLE_CATEGORY_TYPE_HAT, 
	COLLECTIBLE_CATEGORY_TYPE_HAIR, 
	COLLECTIBLE_CATEGORY_TYPE_SKIN, 
	COLLECTIBLE_CATEGORY_TYPE_POLYMORPH, 
	COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY, 
	COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS, 
	COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING, 
	COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING, 
	COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY, 
	COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, 
	COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, 
	COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, 
}
LorePlay.const = {
	LW_BEHAVIOR_ID_DONT_CARE			= 0, 
	LW_BEHAVIOR_ID_PREVENT_CHANGE		= 1, 
	LW_BEHAVIOR_ID_USE_SPECIFIED_ONE	= 2, 
	LW_BEHAVIOR_ID_CANCEL_HIDE_HELM		= 3, 
	LW_USAGE_ID_NOT_USED				= 0, 
	LW_USAGE_ID_CITY					= 1, 
	LW_USAGE_ID_HOUSING					= 2, 
	LW_USAGE_ID_DUNGEON					= 3, 
	LW_USAGE_ID_ADVENTURE				= 4, 
	LW_USAGE_ID_RIDING					= 5, 
	LW_USAGE_ID_COMBAT					= 6, 
	LW_USAGE_ID_SWIMMING				= 7, 
	LW_PRESET_TURN_OFF_HIDE_HELM		= 10001, 
	LW_PRESET_EQUIP_WEDDING_COSTUME		= 10002, 
	LW_PRESET_TOGGLE_ALL_COLLECTIBLES	= 10003, 
	LW_PRESET_TOGGLE_COSTUME_ONLY		= 10004, 
}
local LW_BEHAVIOR_ID_DONT_CARE			= LorePlay.const.LW_BEHAVIOR_ID_DONT_CARE
local LW_BEHAVIOR_ID_PREVENT_CHANGE		= LorePlay.const.LW_BEHAVIOR_ID_PREVENT_CHANGE
local LW_BEHAVIOR_ID_USE_SPECIFIED_ONE	= LorePlay.const.LW_BEHAVIOR_ID_USE_SPECIFIED_ONE
local LW_BEHAVIOR_ID_CANCEL_HIDE_HELM	= LorePlay.const.LW_BEHAVIOR_ID_CANCEL_HIDE_HELM
local LW_USAGE_ID_NOT_USED				= LorePlay.const.LW_USAGE_ID_NOT_USED
local LW_USAGE_ID_CITY					= LorePlay.const.LW_USAGE_ID_CITY
local LW_USAGE_ID_HOUSING				= LorePlay.const.LW_USAGE_ID_HOUSING
local LW_USAGE_ID_DUNGEON				= LorePlay.const.LW_USAGE_ID_DUNGEON
local LW_USAGE_ID_ADVENTURE				= LorePlay.const.LW_USAGE_ID_ADVENTURE
local LW_USAGE_ID_RIDING				= LorePlay.const.LW_USAGE_ID_RIDING
local LW_USAGE_ID_COMBAT				= LorePlay.const.LW_USAGE_ID_COMBAT
local LW_USAGE_ID_SWIMMING				= LorePlay.const.LW_USAGE_ID_SWIMMING
local LW_PRESET_TURN_OFF_HIDE_HELM		= LorePlay.const.LW_PRESET_TURN_OFF_HIDE_HELM
local LW_PRESET_EQUIP_WEDDING_COSTUME	= LorePlay.const.LW_PRESET_EQUIP_WEDDING_COSTUME
local LW_PRESET_TOGGLE_ALL_COLLECTIBLES = LorePlay.const.LW_PRESET_TOGGLE_ALL_COLLECTIBLES
local LW_PRESET_TOGGLE_COSTUME_ONLY		= LorePlay.const.LW_PRESET_TOGGLE_COSTUME_ONLY

--local LAM2
local LAM2 = LibAddonMenu2
if not LAM2 then d("[LorePlay] Error : 'LibAddonMenu' not found.") return end

local L = GetString
local Settings = LorePlay


-- default account-wide savedata table for [LorePlay Forever]
local default_adb = {
	dataVersion = 1, 
	-- ------------------------------------------------------------
	suppressStartupMessage = false, 
	ieIdleTime = 20000,  -- time period in miliseconds to check whether player is idle
	ieAllowedInHousingEditor = false, 
}


-- default savedata table for [LorePlay Forever]
local default_db = {
	migrated = false, 
	dataVersion = 2, 
	-- ------------------------------------------------------------
	isSmartEmotesIndicatorOn = true, 
	indicatorLeft = nil, 
	indicatorTop = nil, 
	maraSpouseName = "", 
	-- ------------------------------------------------------------
	isIdleEmotesOn = true, 
	canPlayInstrumentsInCities = true, 
	canDanceInCities = true, 
	canBeDrunkInCities = true, 
	canExerciseInZone = true, 
	canWorship = true, 
	isCameraSpinDisabled = true, 
	timeBetweenIdleEmotes = 30000, 
	-- ------------------------------------------------------------
	isLoreWearOn = false, 
	lwControlTable = {
		whileMounted = LW_BEHAVIOR_ID_DONT_CARE, 
		duringSwimming = LW_BEHAVIOR_ID_DONT_CARE, 
		inCombat = LW_BEHAVIOR_ID_DONT_CARE, 
		inFastTraveling = LW_BEHAVIOR_ID_DONT_CARE, 
	}, 
	isUsingCollectible = {
		[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_HAT] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_HAIR] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_SKIN] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = true, 
		[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = false, 
	}, 
	isUsingOutfit = false, 
	equippedPresetIndex = 0, 	-- 0 means unknown
	preferedStylePresetByUsage = { 1, 2, 3, 4, 0, 0, 0, 0, 0,  }, 
	stylePreset = {
		[1] = {
			displayName = "City", 
			usage = LW_USAGE_ID_CITY, 
			collectible = {
				[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAT] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAIR] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_SKIN] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = 0, 
			}, 
			outfitIndex = 0, 
			unregistered = true, 
		}, 
		[2] = {
			displayName = "Housing", 
			usage = LW_USAGE_ID_HOUSING, 
			collectible = {
				[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAT] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAIR] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_SKIN] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = 0, 
			}, 
			outfitIndex = 0, 
			unregistered = true, 
		}, 
		[3] = {
			displayName = "Dungeon", 
			usage = LW_USAGE_ID_DUNGEON, 
			collectible = {
				[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAT] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAIR] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_SKIN] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = 0, 
			}, 
			outfitIndex = 0, 
			unregistered = true, 
		}, 
		[4] = {
			displayName = "Adventure", 
			usage = LW_USAGE_ID_ADVENTURE, 
			collectible = {
				[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAT] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAIR] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_SKIN] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = 0, 
			}, 
			outfitIndex = 0, 
			unregistered = true, 
		}, 
		[5] = {
			displayName = "Option1", 
			usage = LW_USAGE_ID_NOT_USED, 
			collectible = {
				[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAT] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAIR] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_SKIN] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = 0, 
			}, 
			outfitIndex = 0, 
			unregistered = true, 
		}, 
		[6] = {
			displayName = "Option2", 
			usage = LW_USAGE_ID_NOT_USED, 
			collectible = {
				[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAT] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAIR] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_SKIN] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = 0, 
			}, 
			outfitIndex = 0, 
			unregistered = true, 
		}, 
		[7] = {
			displayName = "Option3", 
			usage = LW_USAGE_ID_NOT_USED, 
			collectible = {
				[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAT] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAIR] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_SKIN] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = 0, 
			}, 
			outfitIndex = 0, 
			unregistered = true, 
		}, 
		[8] = {
			displayName = "Option4", 
			usage = LW_USAGE_ID_NOT_USED, 
			collectible = {
				[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAT] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAIR] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_SKIN] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = 0, 
			}, 
			outfitIndex = 0, 
			unregistered = true, 
		}, 
		[9] = {
			displayName = "Option5", 
			usage = LW_USAGE_ID_NOT_USED, 
			collectible = {
				[COLLECTIBLE_CATEGORY_TYPE_COSTUME] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAT] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HAIR] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_SKIN] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = 0, 
				[COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = 0, 
			}, 
			outfitIndex = 0, 
			unregistered = true, 
		}, 
	},
	-- variables for location recognize engine -----
	savedSubZoneName = "", 
	savedSubZoneId = 0, 
	specificPOINameNearby = nil, 
}


-- default savedata table for [LorePlay (standard version)]
--[[
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
		["Costume"] = false,
		["Hat"] = false,
		["Skin"] = false,
		["Hair"] = false,
		["Polymorph"] = false,
		["Facial Accessory"] = false,
		["Facial Hair"] = false,
		["Body Marking"] = false,
		["Head Marking"] = false,
		["Jewelry"] = false,
		["Personality"] = false,
		["Vanity Pet"] = false,
	},

	outfitTable = {
		["City"] = {
			["Costume"] = 0,
			["Hat"] = 0,
			["Hair"] = 0,
			["Skin"] = 0,
			["Polymorph"] = 0,
			["Facial Accessory"] = 0,
			["Facial Hair"] = 0,
			["Body Marking"] = 0,
			["Head Marking"] = 0,
			["Jewelry"] = 0,
			["Personality"] = 0,
			["Vanity Pet"] = 0,
		},
		["Housing"] = {
			["Costume"] = 0,
			["Hat"] = 0,
			["Hair"] = 0,
			["Skin"] = 0,
			["Polymorph"] = 0,
			["Facial Accessory"] = 0,
			["Facial Hair"] = 0,
			["Body Marking"] = 0,
			["Head Marking"] = 0,
			["Jewelry"] = 0,
			["Personality"] = 0,
			["Vanity Pet"] = 0,
		},
		["Dungeon"] = {
			["Costume"] = 0,
			["Hat"] = 0,
			["Hair"] = 0,
			["Skin"] = 0,
			["Polymorph"] = 0,
			["Facial Accessory"] = 0,
			["Facial Hair"] = 0,
			["Body Marking"] = 0,
			["Head Marking"] = 0,
			["Jewelry"] = 0,
			["Personality"] = 0,
			["Vanity Pet"] = 0,
		},
		["Adventure"] = {
			["Costume"] = 0,
			["Hat"] = 0,
			["Hair"] = 0,
			["Skin"] = 0,
			["Polymorph"] = 0,
			["Facial Accessory"] = 0,
			["Facial Hair"] = 0,
			["Body Marking"] = 0,
			["Head Marking"] = 0,
			["Jewelry"] = 0,
			["Personality"] = 0,
			["Vanity Pet"] = 0,
		}
	},

	canActivateLWClothesWhileMounted = false,
	maraSpouseName = "",
	indicatorLeft = nil,
	indicatorTop = nil,
	timeBetweenIdleEmotes = 30000, 

-- variables for location recognize engine -----
	savedSubZoneName = "", 
	savedSubZoneId = 0, 
	specificPOINameNearby = nil, 
-- ---------------------------------------------

}
]]


local function ConvertToForeverSavedata()
	local stringToColTypeTable = {
		["Hat"] = COLLECTIBLE_CATEGORY_TYPE_HAT, 
		["Costume"] = COLLECTIBLE_CATEGORY_TYPE_COSTUME, 
		["Skin"] = COLLECTIBLE_CATEGORY_TYPE_SKIN, 
		["Hair"] = COLLECTIBLE_CATEGORY_TYPE_HAIR, 
		["Polymorph"] = COLLECTIBLE_CATEGORY_TYPE_POLYMORPH, 
		["Facial Accessory"] = COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY, 
		["Facial Hair"] = COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS, 
		["Body Marking"] = COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING, 
		["Head Marking"] = COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING, 
		["Jewelry"] = COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY, 
		["Personality"] = COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, 
		["Vanity Pet"] = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, 
	}

	local sv = Settings.savedVariables

	if sv.isSmartEmotesIndicatorOn			~= nil then LorePlay.db.isSmartEmotesIndicatorOn			= sv.isSmartEmotesIndicatorOn				end
	if sv.indicatorLeft						~= nil then LorePlay.db.indicatorLeft						= sv.indicatorLeft							end
	if sv.indicatorTop						~= nil then LorePlay.db.indicatorTop						= sv.indicatorTop							end
	if sv.maraSpouseName					~= nil then LorePlay.db.maraSpouseName						= sv.maraSpouseName							end
	-- ------------------------------------------------------------
	if sv.isIdleEmotesOn					~= nil then LorePlay.db.isIdleEmotesOn						= sv.isIdleEmotesOn							end
	if sv.canPlayInstrumentsInCities		~= nil then LorePlay.db.canPlayInstrumentsInCities			= sv.canPlayInstrumentsInCities				end
	if sv.canDanceInCities					~= nil then LorePlay.db.canDanceInCities					= sv.canDanceInCities						end
	if sv.canBeDrunkInCities				~= nil then LorePlay.db.canBeDrunkInCities					= sv.canBeDrunkInCities						end
	if sv.canExerciseInZone					~= nil then LorePlay.db.canExerciseInZone					= sv.canExerciseInZone						end
	if sv.canWorship						~= nil then LorePlay.db.canWorship							= sv.canWorship								end
	if sv.isCameraSpinDisabled				~= nil then LorePlay.db.isCameraSpinDisabled				= sv.isCameraSpinDisabled					end
	if sv.timeBetweenIdleEmotes				~= nil then LorePlay.db.timeBetweenIdleEmotes				= sv.timeBetweenIdleEmotes					end
	-- ------------------------------------------------------------
	if sv.isLoreWearOn						~= nil then LorePlay.db.isLoreWearOn						= sv.isLoreWearOn							end
	if sv.canActivateLWClothesWhileMounted	~= nil then 
		if sv.canActivateLWClothesWhileMounted == true then
			LorePlay.db.lwControlTable.whileMounted = LW_BEHAVIOR_ID_DONT_CARE
		else
			LorePlay.db.lwControlTable.whileMounted = LW_BEHAVIOR_ID_PREVENT_CHANGE
		end
	end

	if sv.isUsingFavorite ~= nil then
		for k, v in pairs(sv.isUsingFavorite) do
			LorePlay.db.isUsingCollectible[stringToColTypeTable[k]] = v
		end
	end

	if sv.outfitTable ~= nil then
		for i, j in pairs({ "City", "Housing", "Dungeon", "Adventure", }) do
			for k, v in pairs(sv.outfitTable[j]) do
				LorePlay.db.stylePreset[i].collectible[stringToColTypeTable[k]] = v
			end
			LorePlay.db.stylePreset[i].outfitIndex = 0
			LorePlay.db.stylePreset[i].unregistered = false
		end
	end
	-- ------------------------------------------------------------
	if sv.savedSubZoneName					~= nil then LorePlay.db.savedSubZoneName					= sv.savedSubZoneName						end
	if sv.savedSubZoneId					~= nil then LorePlay.db.savedSubZoneId						= sv.savedSubZoneId							end
	if sv.specificPOINameNearby				~= nil then LorePlay.db.specificPOINameNearby				= sv.specificPOINameNearby					end

	LorePlay.LDL:Debug("savedata migration finished.")
	-- ==========================================================================================================================================
	if sv.savedSubZoneName ~= nil then Settings.savedVariables.savedSubZoneName = nil end
	if sv.savedSubZoneId ~= nil then Settings.savedVariables.savedSubZoneId = nil end
	if sv.specificPOINameNearby ~= nil then Settings.savedVariables.specificPOINameNearby = nil end
end

--[[
-- [HotFix] correct savedata conversion mistakes in Version 1.6.70
local function FixSavedata1670()
	if LorePlay.db.migrated == true and Settings.savedVariables == nil then
		Settings.savedVariables = ZO_SavedVars:New("LorePlaySavedVars", 1, nil, {})	-- save data of LorePlay standard version
		local sv = Settings.savedVariables
		if sv.isSmartEmotesIndicatorOn			== false then LorePlay.db.isSmartEmotesIndicatorOn		= sv.isSmartEmotesIndicatorOn		end
		if sv.isIdleEmotesOn					== false then LorePlay.db.isIdleEmotesOn				= sv.isIdleEmotesOn					end
		if sv.canPlayInstrumentsInCities		== false then LorePlay.db.canPlayInstrumentsInCities	= sv.canPlayInstrumentsInCities		end
		if sv.canDanceInCities					== false then LorePlay.db.canDanceInCities				= sv.canDanceInCities				end
		if sv.canBeDrunkInCities				== false then LorePlay.db.canBeDrunkInCities			= sv.canBeDrunkInCities				end
		if sv.canExerciseInZone					== false then LorePlay.db.canExerciseInZone				= sv.canExerciseInZone				end
		if sv.canWorship						== false then LorePlay.db.canWorship					= sv.canWorship						end
		if sv.isCameraSpinDisabled				== false then LorePlay.db.isCameraSpinDisabled			= sv.isCameraSpinDisabled			end
		if sv.isLoreWearOn						== false then LorePlay.db.isLoreWearOn					= sv.isLoreWearOn					end
		if sv.canActivateLWClothesWhileMounted	== false then LorePlay.db.lwControlTable.whileMounted	= LW_BEHAVIOR_ID_PREVENT_CHANGE		end
		ReloadUI()
	end
end
LorePlay.FixSavedata1670 = FixSavedata1670
]]

local function ComplementAccountWideSaveData()
	if LorePlay.adb.suppressStartupMessage == nil	 		then LorePlay.adb.suppressStartupMessage 			= default_adb.suppressStartupMessage			 end
	if LorePlay.adb.ieIdleTime == nil 						then LorePlay.adb.ieIdleTime 						= default_adb.ieIdleTime						 end
	if LorePlay.adb.ieAllowedInHousingEditor == nil 		then LorePlay.adb.ieAllowedInHousingEditor			= default_adb.ieAllowedInHousingEditor			 end
end

local function ValidateCharacterIdSaveData()
	if LorePlay.db.dataVersion == 1 then
		-- Convert data version 1 to 2
		for presetIndex = 1, #default_db.stylePreset do
			local stylePreset = LorePlay.db.stylePreset[presetIndex]
			if not stylePreset then
				stylePreset = ZO_DeepTableCopy(default_db.stylePreset[presetIndex])
				LorePlay.LDL:Debug("initialize style presetIndex[%s]", tostring(presetIndex))
			else
				-- Estimate whether the user has registered in the past.
				local unregistered = true
				for k, v in pairs(stylePreset.collectible) do
					if v ~= default_db.stylePreset[presetIndex].collectible[k] then
						unregistered = false
						break
					end
				end
				if stylePreset.outfitIndex ~= default_db.stylePreset[presetIndex].outfitIndex then
					unregistered = false
				end
--				LorePlay.LDL:Debug("unregistered flag estimation : presetIndex[%s] -> %s ", tostring(presetIndex), tostring(unregistered))
				stylePreset.unregistered = unregistered
			end
		end
		-- If any of the special presets 1 through 4 are registered, all four are considered to be registered.
		if LorePlay.db.isLoreWearOn then
			if (LorePlay.db.stylePreset[1].unregistered and LorePlay.db.stylePreset[2].unregistered and LorePlay.db.stylePreset[3].unregistered and LorePlay.db.stylePreset[4].unregistered) == false then
				LorePlay.db.stylePreset[1].unregistered = false
				LorePlay.db.stylePreset[2].unregistered = false
				LorePlay.db.stylePreset[3].unregistered = false
				LorePlay.db.stylePreset[4].unregistered = false
			end
		end
		LorePlay.db.dataVersion = 2
	end
end


local function updateSpouseName(newMaraSpouseName)
	LorePlay.db.maraSpouseName = newMaraSpouseName
end


local function ResetIndicator()
	SmartEmotesIndicator:ClearAnchors()
	SmartEmotesIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
	LorePlay.db.indicatorLeft = nil
	LorePlay.db.indicatorTop = nil
end


local function OnIndicatorMoved(eventCode, top, left)
	LorePlay.db.indicatorTop = top
	LorePlay.db.indicatorLeft = left
end


local function SetFavoriteStylePreset(presetIndex)
	local collectibleId = 0
	LorePlay.db.stylePreset[presetIndex].outfitIndex = GetEquippedOutfitIndex(GAMEPLAY_ACTOR_CATEGORY_PLAYER) or 0
	for k, v in pairs(Settings.collectibleType) do
		collectibleId = GetActiveCollectibleByType(v, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
		if collectibleId == 0 then		-- no active collectible
		end
		LorePlay.db.stylePreset[presetIndex].collectible[v] = collectibleId
		LorePlay.LDL:Debug("Preset[%d] collectible[%d] = %s", presetIndex, v, GetCollectibleName(collectibleId))
	end
	LorePlay.db.stylePreset[presetIndex].unregistered = false
end


function Settings.ToggleIdleEmotes(value)
	if LorePlay.db.isIdleEmotesOn == value then return end
	LorePlay.db.isIdleEmotesOn = value
	if not LorePlay.db.isIdleEmotesOn then LorePlay.UnregisterIdleEvents() end
	LorePlay.InitializeIdle()
	if value then 
		CHAT_SYSTEM:AddMessage("[LorePlay] Toggled IdleEmotes on")
	else
		CHAT_SYSTEM:AddMessage("[LorePlay] Toggled IdleEmotes off")
	end
end
LorePlay.ToggleIdleEmotes = Settings.ToggleIdleEmotes


-- ------------------------------------------------------------------------------------------
-- LorePlay Camera Spin Disabler
-- ------------------------------------------------------------------------------------------
-- This feature removes only FRAME_PLAYER_FRAGMENT from various scenes in the game UI.
-- As a result, the camera will not spin to the front of the player character in various situations.
-- Fixes "Cannot play emote at this time" in most situations, but not perfect.
--
		-- NOTE : by Calamath
		-- The original author Justinon probably created this feature long ago, inspired by Garkin's 'No, thank you!' add-on.
		-- Therefore, you can use updated version of that add-on instead, but NEVER turn on both at the same time.
		-- This feature is problematic and should be turned off if something goes wrong.

local scenes = {}
local isFramePlayerFragmentRemoved = false
local blacklistedScenes = {
	market = true, 
	esoPlusOffersSceneKeyboard = true, -- for outfit preview feature
	gamepad_market = true, 
	gamepad_market_bundle_contents = true, 
	gamepad_market_content_list = true, 
	gamepad_market_locked = true, 
	gamepad_market_pre_scene = true, 
	gamepad_market_preview = true, 
	gamepad_market_purchase = true, 
	store = true, 
	gamepad_store = true, 
	crownCrateKeyboard = true, 
	crownCrateGamepad = true, 
	dailyLoginRewards = true, 	-- for outfit preview feature in daily login reward scene
	playerSubmenu = true, 	-- for outfit preview feature in daily login reward scene
	keyboard_housing_furniture_scene = true, 
	gamepad_housing_furniture_scene = true, 
	dyeStampConfirmationKeyboard = true, 
	dyeStampConfirmationGamepad = true, 
	restyle_station_keyboard = true, 
	gamepad_restyle_root = true, 
	gamepad_restyle_station = true, 
	collectionsBook = true, 
	outfitStylesBook = true, 
	gamepadCollectionsBook = true, 
	stats = true, 
	gamepad_stats_root = true, 
--	itemSetsBook = true, 			-- Not needed at this time as there is no preview mode.
--	gamepadItemSetsBook = true, 	-- Not needed at this time as there is no preview mode.
	inventory = true, 				-- added for inventory furniture preview feature introduced in update 29
	gamepad_inventory_root = true,	-- added for inventory furniture preview feature introduced in update 29
	endeavorSealStoreSceneKeyboard = true, 	-- for outfit preview feature in endeavor seal store scene
	groupMenuKeyboard = true, 	-- for Golden Pursuits reward preview feature introduced in update 44
	promotionalEventsPreview_Gamepad = true, -- for Golden Pursuits reward preview feature introduced in update 44
	gameMenuInGame = true, -- Since V10.3.5, a code added in zo_options_keyboard to make SetFrameLocalPlayerInGameCamera true. If we do not go through FRAME_PLAYER_FRAGMENT:Hide(), it will remain true in HUD scene, causing a camera glitch.
	gildbarStoreSceneKeyboard = true, 
	TamrielTomesIntroSceneGamepad = true, 
	TamrielTomesIntroSceneKeyboard = true, 
	tamrielTomesPurchasePreview_Gamepad = true, 
	TamrielTomesPurchaseSceneKeyboard = true, 
	TamrielTomesPurchaseSceneGamepad = true, 
	TamrielTomesRewardPreviewSceneGamepad = true, 
	TamrielTomesSceneKeyboard = true, 
	TamrielTomesSceneGamepad = true, 
	VeterancySceneKeyboard = true, 
	VeterancySceneGamepad = true, 
}
local function noCameraSpin(doRemoveFragment)
	doRemoveFragment = doRemoveFragment or LorePlay.db.isCameraSpinDisabled
	if doRemoveFragment then
		if not isFramePlayerFragmentRemoved then
			for name, scene in pairs(SCENE_MANAGER.scenes) do
				if not blacklistedScenes[name] then
					if scene:HasFragment(FRAME_PLAYER_FRAGMENT) then
						scene:RemoveFragment(FRAME_PLAYER_FRAGMENT)
						scenes[name] = scene
					end
				end
			end
			isFramePlayerFragmentRemoved = true
		end
	else
		if isFramePlayerFragmentRemoved then
			for name, scene in pairs(scenes) do
				scene:AddFragment(FRAME_PLAYER_FRAGMENT)
			end
			ZO_ClearTable(scenes)
			isFramePlayerFragmentRemoved = false
		end
	end
end

-- ------------------------------------------------------------------------------------------

local function OnPlayerMaraResult(eventCode, isGettingMarried, playerMarriedTo)
	if eventCode ~= EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE then return end
	if not isGettingMarried then
		updateSpouseName(playerMarriedTo)
	end
end

-- ------------------------------------------------------------------------------------------
-- LorePlay Forever UI
-- ------------------------------------------------------------------------------------------
local uiPanel
local uiPresetIndex = 1


local function DoChangePresetIndex(value)
	uiPresetIndex = value
end

local function DoChangePresetUsage(value)
	local previousUsage = LorePlay.db.stylePreset[uiPresetIndex].usage
	-- update preferedStylePresetByUsage table if it was registered as prefered preset before the change.
	if previousUsage ~= LW_USAGE_ID_NOT_USED then
		if LorePlay.db.preferedStylePresetByUsage[previousUsage] == uiPresetIndex then
			local previousNext = LorePlay.FindNextPresetIndex(previousUsage, uiPresetIndex) or 0
			if previousNext == uiPresetIndex then	-- it means there was no entry other than itself
				 previousNext = 0
			end
			LorePlay.db.preferedStylePresetByUsage[previousUsage] = previousNext
			LorePlay.db.equippedPresetIndex = previousNext
		end
	end
	-- update preferedStylePresetByUsage table if nothing is registered as prefered preset before the change.
	if LorePlay.db.preferedStylePresetByUsage[value] == 0 then
		LorePlay.db.preferedStylePresetByUsage[value] = uiPresetIndex
	end
	LorePlay.db.stylePreset[uiPresetIndex].usage = value
--	LorePlay.LDL:Debug("preferedStylePresetByUsage=", tostring(table.concat(LorePlay.db.preferedStylePresetByUsage, ", ")))
end


local function OnLAMPanelControlsCreated(panel)
	if panel ~= uiPanel then return end
	CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", OnLAMPanelControlsCreated)
--	LorePlay.LDL:Debug("LAM-Panel Created")

end

local function OnLAMPanelClosed(panel)
	if panel ~= uiPanel then return end
--	LorePlay.LDL:Debug("LAM-Panel Closed")

end

local function OnLAMPanelOpened(panel)
	if panel ~= uiPanel then return end
--	LorePlay.LDL:Debug("LAM-Panel Opened")

end


local function LoadMenuSettings()
	local panelData = {
		type = "panel",
		name = LorePlay.name,
		displayName = "|c8c7037LorePlay Forever|r",
		author = "Justinon, Calamath",
		version = LorePlay.version,
		slashCommand = "/loreplay",
		registerForRefresh = true,
	}

	local optionsTable = {}
	local uiMenuSmartEmote = {}
	local uiMenuIdleEmote = {}
	local uiMenuLoreWear = {}
	local uiSubMenuManagementRange = {}
	local uiSubMenuLoreWearControlPanel = {}
	local uiPresetChoices = { "|c4169e1City|r", "|c4169e1Housing|r", "|c4169e1Dungeon|r", "|c4169e1Adventure|r", "option1", "option2", "option3", "option4", "option5", }
	local uiPresetChoicesValues = { 1, 2, 3, 4, 5, 6, 7, 8, 9,  }
	local uiUsageChoices = { "Not used", "City Outfit", "Housing Outfit", "Dungeon Outfit", "Adventure Outfit", "Riding Clothes", "Combat Uniform", "Wet Suit", }
	local uiUsageChoicesValues = { LW_USAGE_ID_NOT_USED, LW_USAGE_ID_CITY, LW_USAGE_ID_HOUSING, LW_USAGE_ID_DUNGEON, LW_USAGE_ID_ADVENTURE, LW_USAGE_ID_RIDING, LW_USAGE_ID_COMBAT, LW_USAGE_ID_SWIMMING, }
	local uiWhileMountedChoices = { "Don't care", "Prevent change outfit", "Use Riding Clothes", }
	local uiWhileMountedChoicesValues = { LW_BEHAVIOR_ID_DONT_CARE, LW_BEHAVIOR_ID_PREVENT_CHANGE, LW_BEHAVIOR_ID_USE_SPECIFIED_ONE, }
	local uiDuringSwimmingChoices = { "Don't care", "Prevent change outfit", "Use Wet Suit", }
	local uiDuringSwimmingChoicesValues = { LW_BEHAVIOR_ID_DONT_CARE, LW_BEHAVIOR_ID_PREVENT_CHANGE, LW_BEHAVIOR_ID_USE_SPECIFIED_ONE, }
	local uiInCombatChoices = { "Don't care", "Prevent change outfit", "Use Combat Uniform", "Turn off 'HIDE HELM'", }
	local uiInCombatChoicesValues = { LW_BEHAVIOR_ID_DONT_CARE, LW_BEHAVIOR_ID_PREVENT_CHANGE, LW_BEHAVIOR_ID_USE_SPECIFIED_ONE, LW_BEHAVIOR_ID_CANCEL_HIDE_HELM, }
	local uiInFastTravelChoices = { "Don't care", "Prevent change outfit", }
	local uiInFastTravelChoicesValues = { LW_BEHAVIOR_ID_DONT_CARE, LW_BEHAVIOR_ID_PREVENT_CHANGE, }

	uiMenuSmartEmote[#uiMenuSmartEmote + 1] = {
		type = "description",
		title = nil,
		text = L(SI_LOREPLAY_PANEL_SE_DESCRIPTION),
		width = "full",
	}
	uiMenuSmartEmote[#uiMenuSmartEmote + 1] = {
		type = "editbox", 
		name = L(SI_LOREPLAY_PANEL_SE_EDIT_SIGNIFICANT_CHAR_NAME), 
		tooltip = L(SI_LOREPLAY_PANEL_SE_EDIT_SIGNIFICANT_CHAR_TIPS), 
		getFunc = function() return LorePlay.db.maraSpouseName end, 
		setFunc = function(input) LorePlay.db.maraSpouseName = input end, 
		isMultiline = false, 
		width = "full", 
		default = "", 
	}
	uiMenuSmartEmote[#uiMenuSmartEmote + 1] = {
		type = "checkbox",
		name = L(SI_LOREPLAY_PANEL_SE_INDICATOR_SW_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_SE_INDICATOR_SW_TIPS),
		getFunc = function() return LorePlay.db.isSmartEmotesIndicatorOn end, 
		setFunc = function(value) 
			LorePlay.db.isSmartEmotesIndicatorOn = value
			if value == false then
				SmartEmotesIndicator:SetHidden(true)
			end
		end, 
		width = "full", 
	}
	uiMenuSmartEmote[#uiMenuSmartEmote + 1] = {
		type = "button",
		name = L(SI_LOREPLAY_PANEL_SE_INDICATOR_POS_RESET_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_SE_INDICATOR_POS_RESET_TIPS),
		func = function() ResetIndicator() end,
		width = "full",
	}
	optionsTable[#optionsTable + 1] = {
		type = "submenu", 
		name = L(SI_LOREPLAY_PANEL_SE_HEADER), 
		controls = uiMenuSmartEmote, 
	}

	-- ------------------------------------------------------------------

	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "description",
		title = nil,
		text =  L(SI_LOREPLAY_PANEL_IE_DESCRIPTION),
		width = "full",
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "checkbox",
		name =  L(SI_LOREPLAY_PANEL_IE_SW_NAME),
		tooltip =  L(SI_LOREPLAY_PANEL_IE_SW_TIPS),
		getFunc = function() return LorePlay.db.isIdleEmotesOn end,
		setFunc = function(value) 
			LorePlay.ToggleIdleEmotes(value)
		end, 
		width = "full",
		reference = "IdleEmotesToggleCheckbox",
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "slider",
		name = L(SI_LOREPLAY_PANEL_IE_IDLE_TIME_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_IE_IDLE_TIME_TIPS),
		min = 10,
		max = 120,
		step = 1,
		getFunc = function() 
			return LorePlay.adb.ieIdleTime / 1000 -- Converting ms to s
		end, 
		setFunc = function(value)
			LorePlay.adb.ieIdleTime = (value * 1000) -- Converting seconds to ms
		end, 
		width = "full",
		disabled = function() return not LorePlay.db.isIdleEmotesOn end, 
		default = 20,
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "slider",
		name = L(SI_LOREPLAY_PANEL_IE_EMOTE_DURATION_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_IE_EMOTE_DURATION_TIPS),
		min = 10,
		max = 120,
		step = 2,
		getFunc = function() 
			return LorePlay.db.timeBetweenIdleEmotes/1000 -- Converting ms to s
		end, 
		setFunc = function(value)
			LorePlay.db.timeBetweenIdleEmotes = (value*1000) -- Converting seconds to ms
		end, 
		width = "full",
		disabled = function() return not LorePlay.db.isIdleEmotesOn end, 
		default = 30,
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "checkbox",
		name = L(SI_LOREPLAY_PANEL_IE_PLAY_INST_IN_CITY_SW_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_IE_PLAY_INST_IN_CITY_SW_TIPS),
		getFunc = function() return LorePlay.db.canPlayInstrumentsInCities end, 
		setFunc = function(value)
			LorePlay.db.canPlayInstrumentsInCities = value
			LorePlay.CreateDefaultIdleEmotesTable()
		end, 
		width = "full",
		disabled = function() return not LorePlay.db.isIdleEmotesOn end, 
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "checkbox", 
		name = L(SI_LOREPLAY_PANEL_IE_DANCE_IN_CITY_SW_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_IE_DANCE_IN_CITY_SW_TIPS),
		getFunc = function() return LorePlay.db.canDanceInCities end, 
		setFunc = function(value)
			LorePlay.db.canDanceInCities = value
			LorePlay.CreateDefaultIdleEmotesTable()
		end, 
		width = "full",
		disabled = function() return not LorePlay.db.isIdleEmotesOn end, 
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "checkbox",
		name = L(SI_LOREPLAY_PANEL_IE_BE_DRUNK_IN_CITY_SW_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_IE_BE_DRUNK_IN_CITY_SW_TIPS),
		getFunc = function() return LorePlay.db.canBeDrunkInCities end, 
		setFunc = function(value)
			LorePlay.db.canBeDrunkInCities = value
			LorePlay.CreateDefaultIdleEmotesTable()
		end, 
		width = "full",
		disabled = function() return not LorePlay.db.isIdleEmotesOn end, 
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "checkbox",
		name = L(SI_LOREPLAY_PANEL_IE_EXERCISE_IN_ZONE_SW_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_IE_EXERCISE_IN_ZONE_SW_TIPS),
		getFunc = function() return LorePlay.db.canExerciseInZone end, 
		setFunc = function(value)
			LorePlay.db.canExerciseInZone = value
			LorePlay.CreateDefaultIdleEmotesTable()
		end, 
		width = "full",
		disabled = function() return not LorePlay.db.isIdleEmotesOn end, 
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "checkbox",
		name = L(SI_LOREPLAY_PANEL_IE_WORSHIP_SW_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_IE_WORSHIP_SW_TIPS),
		getFunc = function() return LorePlay.db.canWorship end, 
		setFunc = function(value)
			LorePlay.db.canWorship = value
			LorePlay.CreateDefaultIdleEmotesTable()
		end, 
		width = "full",
		disabled = function() return not LorePlay.db.isIdleEmotesOn end, 
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "checkbox",
		name = L(SI_LOREPLAY_PANEL_IE_ALLOWED_IN_HOUSING_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_IE_ALLOWED_IN_HOUSING_TIPS),
		getFunc = function() return LorePlay.adb.ieAllowedInHousingEditor end, 
		setFunc = function(value) LorePlay.adb.ieAllowedInHousingEditor = value end, 
		width = "full",
		disabled = function() return not LorePlay.db.isIdleEmotesOn end, 
	}
	uiMenuIdleEmote[#uiMenuIdleEmote + 1] = {
		type = "checkbox",
		name = L(SI_LOREPLAY_PANEL_IE_CAMERA_SPIN_DISABLER_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_IE_CAMERA_SPIN_DISABLER_TIPS),
		getFunc = function() return LorePlay.db.isCameraSpinDisabled end, 
		setFunc = function(value)
			LorePlay.db.isCameraSpinDisabled = value
			noCameraSpin()
		end, 
		width = "full",
--		disabled = function() return not LorePlay.db.isIdleEmotesOn end, 
	}
	optionsTable[#optionsTable + 1] = {
		type = "submenu", 
		name = L(SI_LOREPLAY_PANEL_IE_HEADER), 
		controls = uiMenuIdleEmote, 
	}

	-- ------------------------------------------------------------------

	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "description",
		title = nil,
		text = L(SI_LOREPLAY_PANEL_LW_DESCRIPTION),
		width = "full",
	}
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "checkbox",
		name = L(SI_LOREPLAY_PANEL_LW_SW_NAME),
		tooltip = L(SI_LOREPLAY_PANEL_LW_SW_TIPS),
		getFunc = function() return LorePlay.db.isLoreWearOn end,
		setFunc = function(value) 
			LorePlay.db.isLoreWearOn = value
			if not LorePlay.db.isLoreWearOn then 
				LorePlay.UnregisterLoreWearEvents()
			else
				LorePlay.ReenableLoreWear()
			end
		end,
		width = "full",
	}

	uiSubMenuManagementRange[#uiSubMenuManagementRange + 1] = {
		type = "description",
		title = nil,
		text = "LoreWear automatically switches the appearance type you turned on.",
		width = "full",
	}
	uiSubMenuManagementRange[#uiSubMenuManagementRange + 1] = {
		type = "button",
		name = "Turn ALL ON", 
		tooltip = "", 
		func = function() 
			LorePlay.db.isUsingOutfit = true
			for _, v in pairs(LorePlay.collectibleType) do
				LorePlay.db.isUsingCollectible[v] = true
			end
		end, 
		width = "half", 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiSubMenuManagementRange[#uiSubMenuManagementRange + 1] = {
		type = "button",
		name = "Turn ALL OFF", 
		tooltip = "", 
		func = function() 
			LorePlay.db.isUsingOutfit = false
			for _, v in pairs(LorePlay.collectibleType) do
				LorePlay.db.isUsingCollectible[v] = false
			end
		end, 
		width = "half", 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiSubMenuManagementRange[#uiSubMenuManagementRange + 1] = {
		type = "checkbox", 
		name = L(SI_LOREPLAY_PANEL_LW_OUTFIT_SW_NAME), 
		tooltip = L(SI_LOREPLAY_PANEL_LW_OUTFIT_SW_TIPS), 
		getFunc = function() return LorePlay.db.isUsingOutfit end, 
		setFunc = function(value) LorePlay.db.isUsingOutfit = value end, 
		width = "full",
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
		default = false,
	}
	for k, v in pairs(LorePlay.collectibleType) do
		uiSubMenuManagementRange[#uiSubMenuManagementRange + 1] = {
			type = "checkbox", 
			name = L("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_NAME_", v), 
			tooltip = L("SI_LOREPLAY_PANEL_LW_COLLECTIBLE_SW_TIPS_", v), 
			getFunc = function() return LorePlay.db.isUsingCollectible[v] end, 
			setFunc = function(value) LorePlay.db.isUsingCollectible[v] = value end, 
			width = "full",
			disabled = function() return not LorePlay.db.isLoreWearOn end, 
			default = false,
		}
	end
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "submenu", 
		name = "Management Range", 
		tooltip = "LoreWear management range", 
		controls = uiSubMenuManagementRange, 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}

	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "description", 
		title = "Outfit Setting", 
		text = "", 
--		width = "half", 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
		reference = "LOREPLAY_UI_PresetUsageLabel", 
	}
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "dropdown", 
		name = "Select Preset", 
		tooltip = "Select your preset", 
		choices = uiPresetChoices, 
		choicesValues = uiPresetChoicesValues, 
		getFunc = function() return uiPresetIndex end, 
		setFunc = DoChangePresetIndex, 
--		width = "half", 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
		default = 1, 
	}
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "dropdown", 
		name = "Usage", 
		tooltip = "Set the usage of the selected preset", 
		choices = uiUsageChoices, 
		choicesValues = uiUsageChoicesValues, 
		getFunc = function() return LorePlay.db.stylePreset[uiPresetIndex].usage end, 
		setFunc = DoChangePresetUsage, 
--		width = "half", 
		disabled = function() 
			if not LorePlay.db.isLoreWearOn then return true end
			if uiPresetIndex > 0 and uiPresetIndex < 5 then return true end		-- the usage of basic 4 slots cannot be changed.
			return false
		end, 
		default = 1, 
	}
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "button",
		name = "Register Outfit", 
		tooltip = "Capture your current appearance and register to the selected preset.", 
		func = function() SetFavoriteStylePreset(uiPresetIndex) end, 
--		width = "half", 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "divider", 
	}
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "description", 
		title = "Dressing room", 
		text = "", 
--		width = "half", 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "button", 
		name = "Equip outfit", 
		tooltip = "Equip this outfit preset", 
		func = function() LorePlay.EquipStylePreset(uiPresetIndex) end, 
		width = "half", 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "button", 
		name = "Modify appearance", 
		tooltip = "Adjustment", 
		func = function() return end, 
		width = "half", 
--		disabled = function() return not LorePlay.db.isLoreWearOn end, 
		disabled = function() return true end, 
	}

	uiSubMenuLoreWearControlPanel[#uiSubMenuLoreWearControlPanel + 1] = {
		type = "description", 
		title = "Detailed operating conditions", 
		text = "If you want to switch automatically to riding clothes, combat uniform and/or wet suit, you have to change the settings here properly.", 
--		width = "half", 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiSubMenuLoreWearControlPanel[#uiSubMenuLoreWearControlPanel + 1] = {
		type = "dropdown", 
		name = "    Behavior : while mounted", 
		tooltip = "", 
		choices = uiWhileMountedChoices, 
		choicesValues = uiWhileMountedChoicesValues, 
		getFunc = function() return LorePlay.db.lwControlTable.whileMounted end, 
		setFunc = function(value) LorePlay.db.lwControlTable.whileMounted = value end, 
		width = "full",
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiSubMenuLoreWearControlPanel[#uiSubMenuLoreWearControlPanel + 1] = {
		type = "dropdown", 
		name = "    Behavior : during swimming", 
		tooltip = "", 
		choices = uiDuringSwimmingChoices, 
		choicesValues = uiDuringSwimmingChoicesValues, 
		getFunc = function() return LorePlay.db.lwControlTable.duringSwimming end, 
		setFunc = function(value) LorePlay.db.lwControlTable.duringSwimming = value end, 
		width = "full",
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiSubMenuLoreWearControlPanel[#uiSubMenuLoreWearControlPanel + 1] = {
		type = "dropdown", 
		name = "    Behavior : in combat", 
		tooltip = "", 
		choices = uiInCombatChoices, 
		choicesValues = uiInCombatChoicesValues, 
		getFunc = function() return LorePlay.db.lwControlTable.inCombat end, 
		setFunc = function(value) LorePlay.db.lwControlTable.inCombat = value end, 
		width = "full",
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiSubMenuLoreWearControlPanel[#uiSubMenuLoreWearControlPanel + 1] = {
		type = "description", 
		title = "Control panel", 
		text = "", 
--		width = "half", 
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiSubMenuLoreWearControlPanel[#uiSubMenuLoreWearControlPanel + 1] = {
		type = "dropdown", 
		name = "    Behavior : in fast travel interaction", 
		tooltip = "", 
		choices = uiInFastTravelChoices, 
		choicesValues = uiInFastTravelChoicesValues, 
		getFunc = function() return LorePlay.db.lwControlTable.inFastTraveling end, 
		setFunc = function(value) LorePlay.db.lwControlTable.inFastTraveling = value end, 
		width = "full",
		disabled = function() return not LorePlay.db.isLoreWearOn end, 
	}
	uiMenuLoreWear[#uiMenuLoreWear + 1] = {
		type = "submenu", 
		name = "Advanced Setting", 
		controls = uiSubMenuLoreWearControlPanel, 
	}
	optionsTable[#optionsTable + 1] = {
		type = "submenu", 
		name = L(SI_LOREPLAY_PANEL_LW_HEADER), 
		controls = uiMenuLoreWear, 
	}
	optionsTable[#optionsTable + 1] = {
		type = "checkbox",
		name =  L(SI_LOREPLAY_PANEL_SUPPRESS_STARTUP_MESSAGE_NAME),
		tooltip =  L(SI_LOREPLAY_PANEL_SUPPRESS_STARTUP_MESSAGE_TIPS),
		getFunc = function() return LorePlay.adb.suppressStartupMessage end,
		setFunc = function(value) LorePlay.adb.suppressStartupMessage = value end, 
		width = "full",
	}

	uiPanel = LAM2:RegisterAddonPanel("LorePlayOptions", panelData)
	LAM2:RegisterOptionControls("LorePlayOptions", optionsTable)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", OnLAMPanelControlsCreated)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", OnLAMPanelClosed)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", OnLAMPanelOpened)
end


local function RegisterSettingsEvents()
	LPEventHandler:RegisterForLocalEvent(EVENT_INDICATOR_MOVED, OnIndicatorMoved)
	LPEventHandler:RegisterForLocalEvent(EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE, OnPlayerMaraResult)
end


local function ReconvertLorePlaySavedata()
	LorePlay.db.migrated = false
	ReloadUI()
end
LorePlay.ReconvertLorePlaySavedata = ReconvertLorePlaySavedata


local function InitializeSettings()
	LorePlay.adb = ZO_SavedVars:NewAccountWide(LorePlay.savedVars, LorePlay.savedVarsVersion, nil, default_adb, "ForeverADB")
	ComplementAccountWideSaveData()

	LorePlay.db = ZO_SavedVars:NewCharacterIdSettings(LorePlay.savedVars, LorePlay.savedVarsVersion, nil, default_db, "ForeverDB")
	if LorePlay.db.migrated == false then
		Settings.savedVariables = ZO_SavedVars:New("LorePlaySavedVars", 1, nil, {})	-- save data of LorePlay standard version
		ConvertToForeverSavedata()
		LorePlay.db.migrated = true
	else
		ValidateCharacterIdSaveData()
	end

--	LAM2 = LibStub("LibAddonMenu-2.0")
	LoadMenuSettings()
	noCameraSpin()
	RegisterSettingsEvents()
end
LorePlay.InitializeSettings = InitializeSettings

