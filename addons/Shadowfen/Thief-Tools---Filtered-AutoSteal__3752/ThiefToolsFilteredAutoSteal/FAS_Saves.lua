local SF = LibSFUtils
--local dbg = TTFAS.dbg

local L = GetString

local default = {
    version = TTFAS.version,

    enabled = true,
    banner = true,
    debugMode = false,
	profile = "Account-Wide",
}

local default_profiles = {
	profiles = {
	},
	uses = {
	},
}

local default_profile = {
	profileName = "Account-Wide",

		-- General
	general = {
		closeLootWindow = false,
		turnOffGmAS = true,
		turnOffGmAL = false,
	},

	-- Gear
    gear = {
		minQuality = ITEM_DISPLAY_QUALITY_MAGIC,
		minValue = 0,
		minTTCValue = 0,

		minArmorWeapQuality = ITEM_DISPLAY_QUALITY_MAGIC,
		minArmorWeapValue = 0,

		minCompQuality = ITEM_DISPLAY_QUALITY_MAGIC,
		companionGears = FASFV:val(FAS_ALWAYS),

		minGearQuality = ITEM_DISPLAY_QUALITY_MAGIC,
		minGearValue = 0,
		minJewelQuality = ITEM_DISPLAY_QUALITY_MAGIC,
		minJewelValue = 0,
        set = FASFV:val(FAS_ALWAYS),
		setJewel = FASFV:val(FAS_ALWAYS),
        uncollected = FASFV:val(FAS_ALWAYS),

        unresearched = FASFV:val(FAS_ALWAYS),
        ornate = FASFV:val(FAS_ALWAYS),
        intricate = FASFV:val(FAS_ALWAYS),
        clothIntricate = FASFV:val(FAS_ALWAYS),
        metalIntricate = FASFV:val(FAS_ALWAYS),
        woodIntricate = FASFV:val(FAS_ALWAYS),
        jewelIntricate = FASFV:val(FAS_ALWAYS),

        weapons = FASFV:val(FAS_NEVER),
        armors = FASFV:val(FAS_NEVER),
        jewelry = FASFV:val(FAS_NEVER),
	},

	materials = {
        crafting = FASFV:val(FAS_NEVER),
        trait = FASFV:val(FAS_NEVER),
        style = FASFV:val(FAS_NEVER),
        alchemy = FASFV:val(FAS_NEVER),
        ingredients = FASFV:val(FAS_NEVER),
        runes = FASFV:val(FAS_NEVER),
        furnishing = FASFV:val(FAS_ALWAYS),
	},

	-- Treasures
	treasures = {
		minQuality = ITEM_DISPLAY_QUALITY_MAGIC,
		minValue = 0,
		azandar = "true",
		treasures = FASFV:val(FAS_MIN_QUALITY),
	},

	containers = {
        containers = FASFV:val(FAS_ALWAYS),
		invcontainers = FASFV:val(FAS_TAKE_ALL),
	},

	papers = {
		minQuality = ITEM_DISPLAY_QUALITY_MAGIC,
		minValue = 0,
		-- Papers
        recipes = FASFV:val(FAS_UNKNOWN),
        motifs = FASFV:val(FAS_UNKNOWN),
        stylepages = FASFV:val(FAS_ALWAYS),
        treasureMaps = FASFV:val(FAS_ALWAYS),
        writs = FASFV:val(FAS_NEVER),
		minTTCValue = 0,
		paperTTC = FASFV:val(FAS_NEVER),
	},

	misc = {
		-- Miscellaneous
        glyphs = FASFV:val(FAS_NEVER),
        foodAndDrink = FASFV:val(FAS_NEVER),
        poisons = FASFV:val(FAS_NEVER),
        potions = FASFV:val(FAS_NEVER),

        furniture = FASFV:val(FAS_NEVER),

        lockpicks = FASFV:val(FAS_NEVER),
        soulGems = FASFV:val(FAS_FILLED),

		bait = FASFV:val(FAS_NEVER),
	},

	TTC_baseprice = L(TTFAS_PP_SUGGESTED),
	TTC_profit = L(TTFAS_PP_BASEPRICE),
}


-- get a list of currently defined profile names
-- Includes "Account-Wide"
function TTFAS.getProfileNames()
	local nameList = {}
	for k,v in pairs(TTFAS.profTbl.profiles) do
		table.insert(nameList,k)
	end
	return nameList
end

-- Creates a list of names of existing profiles which
-- also includes "Default" and "Account-Wide"
function TTFAS.getCopyableProfileNames()
	local nameList = {"Default"}
	for k,v in pairs(TTFAS.profTbl.profiles) do
		table.insert(nameList,k)
	end
	return nameList
end

-- get a list of current user-created defined profile names
function TTFAS.getUserProfileNames()
	local nameList = {}
	for k,v in pairs(TTFAS.profTbl.profiles) do
		if not (k == "Account-Wide" or k == "Default") then
			table.insert(nameList,k)
		end
	end
	return nameList
end

-- is the profile name already in use?
function TTFAS.isNewProfileName(name)
	for k,v in pairs(TTFAS.profTbl.profiles) do
		if k == name then return false end
	end
	return true
end

-- create a profile with the specified name and default values
function TTFAS.createProfile(name, from)
    TTFASLogger():Info("Creating profile "..name)
	local fromprof
	if from == nil or from == "Default" then
		from = "Default"
		fromprof = default_profile
	else
		fromprof = TTFAS.profTbl.profiles[from]
		if not fromprof then 
			from = "Default"
			fromprof = default_profile 
		end
	end
	TTFAS.profTbl.profiles[name] = SF.deepCopy(fromprof)
	if TTFAS.profTbl.profiles[name] then
		TTFASLogger():Debug("profTbl.profiles["..name.."] set to values from ",from)
		TTFAS.profTbl.profiles[name].profileName = name
	else
		TTFASLogger():Debug("profTbl.profiles["..name.."] set to nil")
	end
end

-- delete the profile with the specified name
function TTFAS.deleteProfile(name)
	TTFAS.profTbl.profiles[name] = nil
	TTFASLogger():Info("Deleted profile "..name)
end

-- load saved variables
--    saved = character settings
--    profTbl = profiles settings
function TTFAS.loadsv()
    TTFASLogger():Info("Starting TTFAS.loadsv")

    -- load our saved variables
	TTFAS.saved = ZO_SavedVars:NewCharacterIdSettings("TTFAS_VARS", 1, nil, default, GetWorldName())

	TTFAS.profTbl = ZO_SavedVars:NewAccountWide("TTFAS_Profiles", 1, nil, default_profiles, GetWorldName())
	SF.defaultMissing(TTFAS.profiles, default_profiles)

	-- create a profTbl.profiles table if it does not exist
	TTFAS.profTbl.profiles = SF.safeTable(TTFAS.profTbl.profiles)

	-- Create an Account-Wide profile if the profiles table is empty
	-- (and set it to the current profile for the character loaded in).
	if not next(TTFAS.profTbl.profiles) then
		TTFASLogger():Warn("Empty profiles table - creating a profile 'Account-Wide'")
		TTFAS.createProfile("Account-Wide")
		TTFAS.saved.profileName = "Account-Wide"
		TTFAS.currentProfile = TTFAS.profTbl.profiles["Account-Wide"]
		return

	-- if the character does not have an assigned profile then
	-- create "Account-Wide" and assign it.
	-- Should probably check first if "Account-Wide" already exists!
	elseif TTFAS.saved.profileName == nil then
		TTFASLogger():Warn("Empty acct profile for character - looking for 'Account-Wide'")
		if not TTFAS.profTbl.profiles["Account-Wide"] then
			-- Create the Account-Wide profile
			TTFAS.createProfile("Account-Wide")
		end
		TTFAS.saved.profileName = "Account-Wide"
		TTFAS.currentProfile = TTFAS.profTbl.profiles["Account-Wide"]
		return

	-- character assigned profile no longer exists, create it
	elseif TTFAS.profTbl.profiles[TTFAS.saved.profileName] == nil then
		TTFASLogger():Warn(SF.str("acct profile ",TTFAS.saved.profileName, " not found - creating a profile ", TTFAS.saved.profileName))
		TTFAS.createProfile(TTFAS.saved.profileName)
		TTFAS.currentProfile = TTFAS.profTbl.profiles[TTFAS.saved.profileName]

	else
		TTFASLogger():Info(SF.str("Loading profile ", TTFAS.saved.profileName))
		TTFAS.currentProfile = TTFAS.profTbl.profiles[TTFAS.saved.profileName]
	end

end