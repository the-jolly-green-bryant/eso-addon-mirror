-- ***** FavoritePet *****

-- TODO item - Remove global saved variables - noted at version 2.00.  Updatecount: 0


--------------------
-- *** Initialize addon variables
--------------------
FavoritePet = {}  -- In-game global space to hold all elements of this addon
FavoritePet.debug = false -- Set to true to run diagnostics
if FavoritePet.debug then d("FavoritePet: Initialize addon variables") end
FavoritePet.version = "2.02 (20250705)"
FavoritePet.name = "FavoritePet" -- Name of this addon
FavoritePet.website = "https://www.esoui.com/downloads/info2917-FavoritePet.html"
FavoritePet.donation = "https://www.paypal.com/donate/?hosted_button_id=3MACYMHKL9Q4J"
FavoritePet.global_typeVanityPet = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET -- ZOS GLOBAL
ZO_CreateStringId("SI_BINDING_NAME_FAVPET", "Random Favorite Pet")

-- TODO we will remove this after a few versions because this is no longer needed
-- Default account-wide settings mostly used in case we need to save a copy of all available pets
FavoritePet.accountwideDefaults = {}

-- Default character settings if this is their first time using addon
FavoritePet.characterDefaults = {
	favoritePetsList = {},
	switchOnCombat = true,
	switchOnZone = false,
	switchOnMount = false,
	switchOnDismount = false,
	anyPet = false,
}


--------------------
-- *** Addon Loaded - Function run when addon is loaded
--------------------
function FavoritePet.addonLoaded(event, addonName)

	if addonName == FavoritePet.name then
		FavoritePet.Startup()
		FavoritePet.CreateSettingsMenu()
		EVENT_MANAGER:UnregisterForEvent(FavoritePet.name, EVENT_ADD_ON_LOADED)
		if FavoritePet.debug then d("Addon Loaded Favorite Pet List") end
	end
end

EVENT_MANAGER:RegisterForEvent(FavoritePet.name, EVENT_ADD_ON_LOADED, FavoritePet.addonLoaded)
	
	
--------------------
-- *** Startup - Load saved data and use it to initially configure
--------------------
function FavoritePet.Startup()
	if FavoritePet.debug then d("FavoritePet: startup function") end
	
	-- TODO I am currently loading the account-wide variables in order to clear them out
	-- the addon was re-writtent to no longer need them saved.  In a few versions we will eliminate this call
	FavoritePet.GSV = ZO_SavedVars:NewAccountWide("FavoritePetSavedVariables", 2, nil, FavoritePet.globalDefaults)
	FavoritePet.GSV = {}
	
	-- Load saved variables (loading in account-wide variables so we can then clear them out
	FavoritePet.CSV = ZO_SavedVars:NewCharacterIdSettings("FavoritePetSavedVariables", 1, nil, FavoritePet.characterDefaults)
	
	-- Set the switch conditions based on the saved variables
	FavoritePet.SetCombatTrigger(FavoritePet.CSV.switchOnCombat)
	FavoritePet.SetZoneTrigger(FavoritePet.CSV.switchOnZone)
	FavoritePet.SetMountTrigger(FavoritePet.CSV.switchOnMount, FavoritePet.CSV.switchOnDismount)
end


--------------------
-- *** SetCombatTrigger - Set if pet change is triggered by leaving combat
--------------------
function FavoritePet.SetCombatTrigger(toggle)
	if FavoritePet.debug then d("FavoritePet: SetCombatTrigger ") end
	
	if toggle then
		FavoritePet.CSV.switchOnCombat = true
		EVENT_MANAGER:RegisterForEvent(FavoritePet.name, EVENT_PLAYER_COMBAT_STATE, FavoritePet.FireCombatTrigger)
	else
		FavoritePet.CSV.switchOnCombat = false
		EVENT_MANAGER:UnregisterForEvent(FavoritePet.name, EVENT_PLAYER_COMBAT_STATE)
	end	
end


--------------------
-- *** FireCombatTrigger - Switch pet when leaving combat
--------------------
function FavoritePet.FireCombatTrigger(eventCode, inCombat)
	if FavoritePet.debug then d("FavoritePet: FireCombatTrigger") end
	
	if (not inCombat) then FavoritePet.SwitchPet() end
end


--------------------
-- *** SetZoneTrigger - Set if pet change is triggered by changing zone
--------------------
function FavoritePet.SetZoneTrigger(toggle)
	if FavoritePet.debug then d("FavoritePet: SetZoneTrigger ") end
	
	if toggle then
		FavoritePet.CSV.switchOnZone = true
		EVENT_MANAGER:RegisterForEvent(FavoritePet.name, EVENT_ZONE_CHANGED, FavoritePet.SwitchPet)
	else
		FavoritePet.CSV.switchOnZone = false
		EVENT_MANAGER:UnregisterForEvent(FavoritePet.name, EVENT_ZONE_CHANGED)
	end
end


--------------------
-- *** SetMountTrigger - Set if pet change is triggered by mounted status
--------------------
function FavoritePet.SetMountTrigger(mountToggle, dismountToggle)
	if FavoritePet.debug then d("FavoritePet: SetMountTrigger") end
	
	FavoritePet.CSV.switchOnMount = mountToggle
	FavoritePet.CSV.switchOnDismount = dismountToggle
	
	if (FavoritePet.CSV.switchOnMount or FavoritePet.CSV.switchOnDismount) then
		EVENT_MANAGER:RegisterForEvent(FavoritePet.name, EVENT_MOUNTED_STATE_CHANGED, FavoritePet.FireMountTrigger)
	end
	
	if ((not FavoritePet.CSV.switchOnMount) and (not FavoritePet.CSV.switchOnDismount)) then
		EVENT_MANAGER:UnregisterForEvent(FavoritePet.name, EVENT_MOUNTED_STATE_CHANGED)
	end
end


--------------------
-- *** FireMountTrigger - Switch pet based on mounted status
--------------------
function FavoritePet.FireMountTrigger(eventid, mounted)
	if FavoritePet.debug then d("FavoritePet: FireMountTrigger") end
	
	if (mounted and FavoritePet.CSV.switchOnMount) then FavoritePet.SwitchPet() end
	if (not mounted and FavoritePet.CSV.switchOnDismount) then FavoritePet.SwitchPet() end
end


--------------------
-- *** SwitchPet - Switch the active pet
--------------------
function FavoritePet.SwitchPet()
	if FavoritePet.debug then d("FavoritePet: SwitchPet") end
	
	local petList = {}
	local activePet = GetActiveCollectibleByType(FavoritePet.global_typeVanityPet)
	local newPet = activePet
	
	if FavoritePet.CSV.anyPet then 
		local tempList = FavoritePet.CreateUnlockedPetList() 
		for key, value in ipairs(tempList) do
			table.insert(petList, value[1])
		end
	else 
		petList = FavoritePet.CSV.favoritePetsList
	end
	
	if petList == nil then return end
	
	if FavoritePet.SafeToSwitch() then
		if #petList == 1 then
			newPet = petList[1]
		else
			 while activePet == newPet do
				newPet = petList[math.random(#petList)]
			end
		end
	end
	
	if FavoritePet.debug then d("FavoritePet: New Pet ID: " .. newPet) end
	
	zo_callLater(function() FavoritePet.FireSwitch(newPet, 0) end, 1000)
	
end


--------------------
-- *** FireSwitch - Make up to 5 attempts to activate the new pet
--------------------
function FavoritePet.FireSwitch(newPet, attemptNumber)
	if FavoritePet.debug then d("FavoritePet: FireSwitch  newPet: "..newPet.."  Attempt: "..attemptNumber) end
	
	if attemptNumber < 5 then
		if not IsCollectibleActive(newPet, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
			if FavoritePet.SafeToSwitch then
				UseCollectible(newPet, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
			end	
			attemptNumber = attemptNumber + 1
			zo_callLater(function() FavoritePet.FireSwitch(newPet, attemptNumber) end, (500 * attemptNumber))
		end
	end
	
end


--------------------
-- *** SafeToSwitch - Check if it is safe to switch pet
--------------------
function FavoritePet.SafeToSwitch()
	if FavoritePet.debug then d("FavoritePet: SafeToSwitch") end
	
	local safe = true
	
	if IsInteracting() then safe = false end
	if IsUnitSwimming("player") then safe = false end
	if IsUnitInCombat("player") then safe = false end
	if IsUnitDeadOrReincarnating("player") then safe = false end
	if IsPlayerInAvAWorld() then safe = false end
	if IsActiveWorldBattleground() then safe = false end
	if GetCurrentZoneHouseId() ~= 0 then safe = false end
	if #FavoritePet.CSV.favoritePetsList == 0 then safe = false end -- There are no favorite pets
	
	return safe
end




--------------------
-- ***** Settings *****
--------------------



--------------------
-- *** CreateUnlockedPetList - Make a fresh copy of all unlocked pets
--------------------
function FavoritePet.CreateUnlockedPetList()
	if FavoritePet.debug then d("FavoritePet: CreateUnlockedPetList") end
	
	local pets = {}		-- Container for the pets list
	local petCounter = 0
	local totalUnlockedPets = GetTotalUnlockedCollectiblesByCategoryType(FavoritePet.global_typeVanityPet)
	
	if totalUnlockedPets > 0 then
		for counter = 1, GetTotalCollectiblesByCategoryType(FavoritePet.global_typeVanityPet) do
			local collectibleID = GetCollectibleIdFromType(FavoritePet.global_typeVanityPet, counter)
			local name, description, unlockedTexture, lockedTexture, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(collectibleID)
			
			if unlocked then
				petCounter = petCounter +1
				local petCleanName = ZO_CachedStrFormat(SI_UNIT_NAME, name)
				pets[petCounter] = {collectibleID, petCleanName, unlockedTexture}
			end
		end
		table.sort (pets, function(a,b) return a[2] < b[2] end)
		
	end
	
	return pets
end


--------------------------------------------------
-- *** CheckIfFavorite - Check to see if a pet is in the favorites list - used for menu settings
--------------------------------------------------
function FavoritePet.CheckIfFavorite(num)

	local fav = FavoritePet.CSV.favoritePetsList
	local found = false
	
	if fav then
		for count = 1, #fav do
			if num == fav[count] then found = true break end	
		end
	end
	return found
end


--------------------------------------------------
-- *** - SortPets - Sort through the unlocked pets and return menu settings information
-- divided into available pets and favorite pets to help dynamically generate the new dropdown lists
--------------------------------------------------
function FavoritePet.SortPets()
	if FavoritePet.debug then d("FavoritePet: SortPets") end
	
	local availablePetName = {}
	local availablePetID = {}
	local availablePetTooltip = {}
	local favoritePetName = {}
	local favoritePetID = {}
	local favoritePetTooltip = {}
	
	-- value[1] is the ID number of the pet, value[2] is the pet's name, value[3] is the pet's texture
	for key, value in ipairs(FavoritePet.CreateUnlockedPetList()) do
		local found = FavoritePet.CheckIfFavorite(value[1])
		if found then
			table.insert(favoritePetName, value[1])
			table.insert(favoritePetID, value[2])
			table.insert(favoritePetTooltip, "|t600%:600%:"..value[3].."|t")
		else
			table.insert(availablePetName, value[1])
			table.insert(availablePetID, value[2])
			table.insert(availablePetTooltip, "|t600%:600%:"..value[3].."|t")
		end	
	end
	return availablePetID, availablePetName, availablePetTooltip, favoritePetID, favoritePetName, favoritePetTooltip
	
end


--------------------------------------------------
-- SetFavorite - Either insert or remove the pet from the favorites table
--------------------------------------------------
function FavoritePet.SetFavorite(toggle, id)
	if toggle then
		table.insert(FavoritePet.CSV.favoritePetsList, id)
	else
		for key, value in ipairs(FavoritePet.CSV.favoritePetsList) do
			if value == id then
				table.remove(FavoritePet.CSV.favoritePetsList, key)
				break
			end
		end
	end
	local availablePetID, availablePetName, availablePetTooltip, favoritePetID, favoritePetName, favoritePetTooltip = FavoritePet.SortPets()
	Available:UpdateChoices(availablePetID, availablePetName, availablePetTooltip) -- Set as reference in menu settings
	Favorites:UpdateChoices(favoritePetID, favoritePetName, favoritePetTooltip)  -- Set as reference in menu settings
end


--------------------
-- *** CreateSettingsMenu - Create the menu to change addon settings
--------------------
function FavoritePet.CreateSettingsMenu()
	if FavoritePet.debug then d("FavoritePet: CreateSettingsMenu") end
	
	local LAM = LibAddonMenu2
	local panelName = "FavoritePetSettingsPanel"
	
	local panelData = {		-- Table that defines the libaddonmenu2 menu panel
		type = "panel",
		name = "Favorite Pet",
		displayName = "|c00E600Favorite Pet|r",
		author = "|c787878ShadowMau / Pawprints.Shadow|r",
		registerForRefresh = true,
		website = FavoritePet.website,
		version = FavoritePet.version,
		donation = FavoritePet.donation
	}
	
	local optionsData = {}	-- The table that holds all of the libaddonmenu2 menu options
	local tempTable = {} 	-- The reuseable temporary table to bulid the optionsData table
	
	--------------------------------------------------
	-- Change pet when I exit combat
	--------------------------------------------------
	tempTable = {
		type = "checkbox",
		name = "Change pet whenever I exit combat: ",
		getFunc = function() return FavoritePet.CSV.switchOnCombat end,
		setFunc = function(value) FavoritePet.SetCombatTrigger(value) end
	}
	table.insert(optionsData, tempTable)
	
	--------------------------------------------------
	-- Change pet when the zone changes
	--------------------------------------------------
	tempTable = {
		type = "checkbox",
		name = "Change pet when the zone changes: ",
		getFunc = function() return FavoritePet.CSV.switchOnZone end,
		setFunc = function(value) FavoritePet.SetZoneTrigger(value) end
	}
	table.insert(optionsData, tempTable)
	
	--------------------------------------------------
	-- Change pet when I mount
	--------------------------------------------------
	tempTable = {
		type = "checkbox",
		name = "Change pet when I mount: ",
		getFunc = function() return FavoritePet.CSV.switchOnMount end,
		setFunc = function(value) FavoritePet.SetMountTrigger(value, FavoritePet.CSV.switchOnDismount) end
	}
	table.insert(optionsData, tempTable)
	
	--------------------------------------------------
	-- Change pet when I dismount
	--------------------------------------------------
	tempTable = {
		type = "checkbox",
		name = "Change pet when I dismount: ",
		getFunc = function() return FavoritePet.CSV.switchOnDismount end,
		setFunc = function(value) FavoritePet.SetMountTrigger(FavoritePet.CSV.switchOnMount, value) end
	}
	table.insert(optionsData, tempTable)
	
	--------------------------------------------------
	-- A dividing line
	--------------------------------------------------
	tempTable = {
		type = "divider",
		width = "full",
		height = 10, -- optional
		alpha = 0.5 -- optional
	}
	table.insert(optionsData, tempTable)
	
	tempTable = {
		type = "checkbox",
		name = "Randomly choose any unlocked pet: ",
		getFunc = function() return FavoritePet.CSV.anyPet end,
		setFunc = function() FavoritePet.CSV.anyPet = not FavoritePet.CSV.anyPet end,
	}
	table.insert(optionsData, tempTable)
	
	--------------------------------------------------
	-- Generate the list of pets
	--------------------------------------------------
	local availablePetID, availablePetName, availablePetTooltip, favoritePetID, favoritePetName, favoritePetTooltip = FavoritePet.SortPets()

	--------------------------------------------------
	-- List the available pets
	--------------------------------------------------
	tempTable = {
		type = "dropdown",
		name = "Available Pets",
		width = "half",
		scrollable = true,
		reference = "Available",
		getFunc = function() return end,
		setFunc = function(petID) FavoritePet.SetFavorite(true, petID) end,
		disabled = function() return FavoritePet.CSV.anyPet end,
		choices = availablePetID,
		choicesValues = availablePetName,
		choicesTooltips = availablePetTooltip
	}
	table.insert(optionsData, tempTable)
	
	--------------------------------------------------
	-- List the favorite pets
	--------------------------------------------------
	tempTable = {
		type = "dropdown",
		name = "Favorite Pets",
		width = "half",
		scrollable = "true",
		reference = "Favorites",
		getFunc = function() return end,
		setFunc = function(petID) FavoritePet.SetFavorite(false, petID) end,
		disabled = function() return FavoritePet.CSV.anyPet end,
		choices = favoritePetID,
		choicesValues = favoritePetName,
		choicesTooltips = favoritePetTooltip
	}
	table.insert(optionsData, tempTable)
	
	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, optionsData)
end



