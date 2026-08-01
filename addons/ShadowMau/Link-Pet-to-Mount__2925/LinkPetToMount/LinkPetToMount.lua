-- ***** LinkPetToMount *****


--------------------------------------------------
-- Initialize addon variables
--------------------------------------------------
local LinkPetToMount = {}
LinkPetToMount.name = "LinkPetToMount"
LinkPetToMount.slashCommand = "/lptm"
LinkPetToMount.debug = false
LinkPetToMount.website = "https://www.esoui.com/downloads/fileinfo.php?id=2925"
LinkPetToMount.version = "1.3.2 (20210711)"
--  -- Added in a check for if the user is currently mounted in case of rapid dismount / mount before the mount switch occurs.

LinkPetToMount.chosenMount = 0
LinkPetToMount.chosenPet = 0
LinkPetToMount.chosenLink = 0
LinkPetToMount.collectible = 0


--------------------------------------------------
-- Link local variables to the in-game Globals
--------------------------------------------------
LinkPetToMount.typeMounts = COLLECTIBLE_CATEGORY_TYPE_MOUNT
LinkPetToMount.typePets = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET
LinkPetToMount.cooldown = COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN


--------------------------------------------------
-- Default saved variable settings
--
-- unlockedMountsList table structure - [index] = {mountid, mount name, unlocked texture file name}
-- unlockedPetsList table structure - [index] = {petid, pet name, unlocked texture file name}
-- linkedSets table structure [index] = {mountid, petid}
--------------------------------------------------
LinkPetToMount.accountDefaults = {
	unlockedMountsList = {},
	unlockedMountsCount = 0,
	unlockedPetsList = {},
	unlockedPetsCount = 0
}


LinkPetToMount.characterDefaults = {
	linkedSets = {}
}


--------------------------------------------------
-- Initialize settings, load saved variables and register event triggers.
--------------------------------------------------
function LinkPetToMount.Initialize()
	LinkPetToMount.ASV = ZO_SavedVars:NewAccountWide("LinkPetToMountSavedVariables", 1, nil, LinkPetToMount.accountDefaults, GetWorldName())
	LinkPetToMount.CSV = ZO_SavedVars:NewCharacterIdSettings("LinkPetToMountSavedVariables", 1, nil, LinkPetToMount.characterDefaults, GetWorldName())
	
	LinkPetToMount.Check()
	
	EVENT_MANAGER:RegisterForEvent(LinkPetToMount.name, EVENT_COLLECTIBLE_NOTIFICATION_NEW, LinkPetToMount.Check)
	EVENT_MANAGER:RegisterForEvent(LinkPetToMount.name, EVENT_MOUNTED_STATE_CHANGED, LinkPetToMount.MountSwitch)
end


--------------------------------------------------
-- Check that the number of mountes and pets saved matches the total number unlocked
--------------------------------------------------
function LinkPetToMount.Check()
	local umountscount	= GetTotalUnlockedCollectiblesByCategoryType(LinkPetToMount.typeMounts)
	local upetscount = GetTotalUnlockedCollectiblesByCategoryType(LinkPetToMount.typePets)
	local smountscount = LinkPetToMount.ASV.unlockedMountsCount
	local spetscount = LinkPetToMount.ASV.unlockedPetsCount
	
	if LinkPetToMount.debug then
		smountscount = 0
		spetscount = 0
		d("FUNCTION: Check")
	end
	
	if smountscount ~= umountscount then LinkPetToMount.Populate("mounts") end
	if spetscount ~= upetscount then LinkPetToMount.Populate("pets") end
end


--------------------------------------------------
-- Populate the unlocked mounts or pets list and save to account saved variables
--------------------------------------------------
function LinkPetToMount.Populate(poptype)
	if LinkPetToMount.debug then d("FUNCTION: Populate "..poptype) end
	local population = {}
	local popcounter = 0
	local unlockedpop = 0
	
	if poptype == "mounts" then
		unlockedpop = GetTotalUnlockedCollectiblesByCategoryType(LinkPetToMount.typeMounts)
		populationtype = LinkPetToMount.typeMounts
	elseif poptype == "pets" then
		unlockedpop = GetTotalUnlockedCollectiblesByCategoryType(LinkPetToMount.typePets)
		populationtype = LinkPetToMount.typePets
	else
		d("LPTM ERROR: Collectible type mismatch.")
	end
	
	--------------------------------------------------
	-- Generate the population
	--------------------------------------------------
	if unlockedpop > 0 then
		for count =1, GetTotalCollectiblesByCategoryType(populationtype) do
			local index = GetCollectibleIdFromType(populationtype, count)
			local p1, p2, p3, p4, p5, p6, p7, p8, p9 = GetCollectibleInfo(index)
			
			--------------------------------------------------
			-- If the current collectible is unlocked, add it to the list (p5 - see comments below)
			--------------------------------------------------
			if p5 then
				--------------------------------------------------
				-- Clean up the name because of translation strings passed from the system
				-- See: https://wiki.esoui.com/How_to_format_strings_with_zo_strformat#Translations
				--------------------------------------------------
				local nameClean = ZO_CachedStrFormat(SI_UNIT_NAME, p1)
				popcounter = popcounter + 1
				population[popcounter] = {index, nameClean, p3}
			end			
		end
		
		--------------------------------------------------
		-- Store the population in the appropriate place
		--------------------------------------------------
		if population then 
			table.sort(population, function (a,b) return a[2] < b[2] end)
			if poptype == "mounts" then
				LinkPetToMount.ASV.unlockedMountsList = population
				LinkPetToMount.ASV.unlockedMountsCount = unlockedpop
			elseif poptype == "pets" then
				LinkPetToMount.ASV.unlockedPetsList = population
				LinkPetToMount.ASV.unlockedPetsCount = unlockedpop
			end
		end
	else -- There is no population
		if poptype == "mounts" then
			LinkPetToMount.ASV.unlockedMountsList = {}
			LinkPetToMount.ASV.unlockedMountsCount = 0
		elseif poptype == "pets" then
			LinkPetToMount.ASV.unlockedPetsList = {}
			LinkPetToMount.ASV.unlockedPetsCount = 0
		end
	end
	--[[ 
		GetCollectibleInfo() returns
		p1 = name(string)
		p2 = description(string)
		p3 = path to the item's texture if unlocked
		p4 = path to the item's texture if locked
		p5 = unlocked(boolean)
		p6 = purchasable(boolean)
		p7 = isActive(boolean)
		p8 = Collectible Category Type (number matches the constant used in pre-initialize)
		p9 = hint text for finding the item
	]]--
end


--------------------------------------------------
-- Safely switch by using event to check usecollectible success
--------------------------------------------------
function LinkPetToMount.SafelySwitch(eventCode, blockReason, attemptActivation)	
	if blockReason == LinkPetToMount.cooldownError then
		if LinkPetToMount.debug then d("COOLDOWN ERROR") end
		zo_callLater(function() if not IsMounted() then UseCollectible(LinkPetToMount.collectible) end end, 1500)
	else
		if LinkPetToMount.debug then d("COOLDOWN SUCCESSFUL") end
		LinkPetToMount.collectible = 0
		EVENT_MANAGER:UnregisterForEvent(LinkPetToMount.name, EVENT_COLLECTIBLE_USE_RESULT)
	end
end


--------------------------------------------------
-- Called whenever mount state changes.  Will either summon pet, or switch to next mount - called from Event Handler
--------------------------------------------------
function LinkPetToMount.MountSwitch(eventCode, mountedState)
	local list = LinkPetToMount.CSV.linkedSets
	local activeMount = GetActiveCollectibleByType(LinkPetToMount.typeMounts)
	local activePet = GetActiveCollectibleByType(LinkPetToMount.typePets)
	local useMount = activeMount
	
	if #list == 0 then return end
	
	--------------------------------------------------
	-- Call associated pet
	--------------------------------------------------
	if mountedState == true then
		local usePet = 0
		for count = 1, #list do
			if list[count][1] == activeMount then
				usePet = list[count][2]
				if usePet ~= activePet then 
					LinkPetToMount.collectible = usePet
					EVENT_MANAGER:RegisterForEvent(LinkPetToMount.name,  EVENT_COLLECTIBLE_USE_RESULT, LinkPetToMount.SafelySwitch)
					zo_callLater(function() UseCollectible(LinkPetToMount.collectible) end, 1500)
					--  Will unregister for event upon successful usecollectible	
				end
				break
			end
		end
	else -- Character is not mounted and there needs to switch to the next random mount
	--------------------------------------------------
	-- Select the next mount
	-- Only change the mount after the user dismounts.  If you try to change the mount while mounted it causes an error.
	--------------------------------------------------
		if #list > 1 then
			while activeMount == useMount do
				useMount = list[math.random(#list)][1]
			end
			LinkPetToMount.collectible = useMount
			EVENT_MANAGER:RegisterForEvent(LinkPetToMount.name,  EVENT_COLLECTIBLE_USE_RESULT, LinkPetToMount.SafelySwitch)				
			zo_callLater(function() if not IsMounted() then UseCollectible(LinkPetToMount.collectible) end end, 1500)
			--  Will unregister for event upon successful usecollectible	
		else -- there is only one entry in the list
			--------------------------------------------------
			-- Added this check because the list of linked pets to mounts may hold only one entry.
			-- And if this is the first time they have used the addon, we need to switch to their choice.
			--------------------------------------------------			
			useMount = list[1][1]
			if useMount ~= activeMount then 
				LinkPetToMount.collectible = useMount
				EVENT_MANAGER:RegisterForEvent(LinkPetToMount.name,  EVENT_COLLECTIBLE_USE_RESULT, LinkPetToMount.SafelySwitch)				
				zo_callLater(function() if not IsMounted() then UseCollectible(LinkPetToMount.collectible) end end, 1500)
				--  Will unregister for event upon successful usecollectible	
			end
		end
	end
end


--------------------------------------------------
-- Insert an entry in the linked mounts and pets table - called from settings menu
--------------------------------------------------
function LinkPetToMount.MakeLink()
	if (LinkPetToMount.chosenMount ~= 0 and LinkPetToMount.chosenPet ~= 0) then
		local temptable = {LinkPetToMount.chosenMount, LinkPetToMount.chosenPet}
		table.insert(LinkPetToMount.CSV.linkedSets, temptable)
	end
	LinkPetToMount.chosenMount = 0
	LinkPetToMount.chosenPet = 0
	LinkPetToMount.MountsDropdownUpdate()
	LinkPetToMount.PetsDropdownUpdate()
	LinkPetToMount.LinksDropdownUpdate()
end


--------------------------------------------------
-- Removes an entry in the linked mounts and pets table - called from settings menu
--------------------------------------------------
function LinkPetToMount.RemoveLink()
	local mountid = LinkPetToMount.chosenLink
	for key, value in ipairs(LinkPetToMount.CSV.linkedSets) do
		if value[1] == mountid then
			table.remove(LinkPetToMount.CSV.linkedSets, key)
			break
		end
	end
	LinkPetToMount.chosenLink = 0
	LinkPetToMount.MountsDropdownUpdate()
	LinkPetToMount.PetsDropdownUpdate()
	LinkPetToMount.LinksDropdownUpdate()
end


--------------------------------------------------
-- SlashCommand Debug - various debug and development information triggered by the slash command
--------------------------------------------------
function LinkPetToMount.PingDebug()

	LinkPetToMount.Populate()
	
end


-- ***** Main *****


--------------------------------------------------
-- Check to see if this addon is the one loaded
--------------------------------------------------
function LinkPetToMount.OnAddOnLoaded(event, addonName)
	if addonName == LinkPetToMount.name then
		if LinkPetToMount.debug then SLASH_COMMANDS[LinkPetToMount.slashCommand] = LinkPetToMount.PingDebug end
		
		LinkPetToMount.Initialize()
		
		--------------------------------------------------
		-- Was getting an error message from LAM saying the settings panel was trying to load before the
		-- rest of the addon loaded.  Wrapping it in a function seems to have fixed it.
		--------------------------------------------------
		LinkPetToMount.InitializeSettingsMenu()
		EVENT_MANAGER:UnregisterForEvent(LinkPetToMount.name, EVENT_ADD_ON_LOADED)
	end
end


EVENT_MANAGER:RegisterForEvent(LinkPetToMount.name, EVENT_ADD_ON_LOADED, LinkPetToMount.OnAddOnLoaded)


--------------------------------------------------
-- ***** Settings *****
--------------------------------------------------


--------------------------------------------------
-- Dynamically rebuild the mounts drowpdown list and register with the settings menu
--------------------------------------------------
function LinkPetToMount.MountsDropdownUpdate()
	local unlockedM = LinkPetToMount.ASV.unlockedMountsList
	local temptable = {}
	temptable.choices = {}
	temptable.choicesValues = {}
	temptable.choicesTooltips = {}
	
	for key, value in ipairs(unlockedM) do
		local mfound = false
		local used = LinkPetToMount.CSV.linkedSets
	
		if used then
			for count = 1, #used do
				if value[1] == used[count][1] then mfound = true break end	
			end
		end
		
		if not mfound then 		
			table.insert(temptable.choices, value[2])
			table.insert(temptable.choicesValues, value[1])
			table.insert(temptable.choicesTooltips, "|t400%:400%:"..value[3].."|t")
		end
	end
	
	if MountDropdown then
		MountDropdown:UpdateChoices(temptable.choices, temptable.choicesValues, temptable.choicesTooltips)
	end
end


--------------------------------------------------
-- Dynamically rebuild the pets drowpdown list and register with the settings menu
--------------------------------------------------
function LinkPetToMount.PetsDropdownUpdate()
	if LinkPetToMount.debug then d("FUNCTION: PetsDropdownUpdate") end
	local unlockedP = LinkPetToMount.ASV.unlockedPetsList
	local temptable = {}
	temptable.choices = {}
	temptable.choicesValues = {}
	temptable.choicesTooltips = {}
	
	for key, value in ipairs(unlockedP) do
		local pfound = false
		local used = LinkPetToMount.CSV.linkedSets
		
		if used then
			for count = 1, #used do
				if value[1] == used[count][2] then pfound = true break end
			end
		end
		if not pfound then
			table.insert(temptable.choices, value[2])
			table.insert(temptable.choicesValues, value[1])
			table.insert(temptable.choicesTooltips, "|t400%:400%:"..value[3].."|t")
		end
	end
	
	if PetDropdown then
		PetDropdown:UpdateChoices(temptable.choices, temptable.choicesValues, temptable.choicesTooltips)
	end
end


--------------------------------------------------
-- Dynamically rebuild the linked mounts to pets drowpdown list and register with the settings menu
--------------------------------------------------
function LinkPetToMount.LinksDropdownUpdate()
	if LinkPetToMount.debug then d("FUNCTION: LinksDropdownUpdate") end
	local linkedSets = LinkPetToMount.CSV.linkedSets
	local temptable = {}
	temptable.choices = {}
	temptable.choicesValues = {}
	
	for key, value in ipairs(linkedSets) do
		local linkedMountid = value[1]
		local linkedPetid = value[2]
		
		local Mname = GetCollectibleInfo(linkedMountid)
		local Pname = GetCollectibleInfo(linkedPetid)
		local linkedMountName = ZO_CachedStrFormat(SI_UNIT_NAME, Mname)
		local linkedPetName = ZO_CachedStrFormat(SI_UNIT_NAME, Pname)
		
		table.insert(temptable.choices, linkedMountName.." ---> "..linkedPetName)
		table.insert(temptable.choicesValues, linkedMountid)
	end
	
	if LinkedDropdown then
		LinkedDropdown:UpdateChoices(temptable.choices, temptable.choicesValues)
	end
end


--------------------------------------------------
-- Generate the settings menu using LibAddonMenu2
--------------------------------------------------
function LinkPetToMount.InitializeSettingsMenu()
	if LinkPetToMount.debug then d("Settings Menu") end

	local LAM = LibAddonMenu2
	local panelName = "LinkPetToMountSettingsPanel"
	
	
	--------------------------------------------------
	-- Table containing the settings panel data
	--------------------------------------------------	 
	local panelData = {
		type = "panel",
		name = "Link Pet To Mount",
		displayName = "|c00E600Link Pet to Mount|r",
		author = "|c787878ShadowMau|r",
		registerForRefresh = true,
		website = LinkPetToMount.website,
		version = LinkPetToMount.version
	}
	
	
	--------------------------------------------------
	-- Table defining a dividing line
	--------------------------------------------------
	local tempDivider = {
		type = "divider",
		width = "full",
		height = 10, -- optional
		alpha = 0.5 -- optional
	}
	
	
	--------------------------------------------------
	-- Table containing the menu options data - generated dynamically
	--------------------------------------------------	 
	local optionsData = {}
	
	
	--------------------------------------------------
	-- Dynamically generate the dropdown list of Mounts
	--------------------------------------------------
	local unlockedM = LinkPetToMount.ASV.unlockedMountsList
	local tempMountTable = {
		type = "dropdown",
		name = "Available Mounts",
		width = "half",
		scrollable = true,
		reference = "MountDropdown",
		getFunc = function() return LinkPetToMount.chosenMount end,
		setFunc = function(mountid) LinkPetToMount.chosenMount = mountid end,
		choices = {},
		choicesValues = {},
		choicesTooltips = {}
	}
	for key, value in ipairs(unlockedM) do
		local mfound = false
		local used = LinkPetToMount.CSV.linkedSets
	
		if used then
			for count = 1, #used do
				if value[1] == used[count][1] then mfound = true break end	
			end
		end
		
		if not mfound then 		
			table.insert(tempMountTable.choices, value[2])
			table.insert(tempMountTable.choicesValues, value[1])
			table.insert(tempMountTable.choicesTooltips, "|t400%:400%:"..value[3].."|t")
		end
	end
	table.insert(optionsData,tempMountTable)
	
	
	--------------------------------------------------
	-- Dynamically generate the dropdown list of Pets
	--------------------------------------------------
	local unlockedP = LinkPetToMount.ASV.unlockedPetsList
	local tempPetTable = {
		type = "dropdown",
		name = "Available Pets",
		width = "half",
		reference = "PetDropdown",
		getFunc = function() return LinkPetToMount.chosenPet end,
		setFunc = function(petid) LinkPetToMount.chosenPet = petid end,
		scrollable = true,
		
		choices = {},
		choicesValues = {},
		choicesTooltips = {}
	}
	for key, value in ipairs(unlockedP) do
		local pfound = false
		local used = LinkPetToMount.CSV.linkedSets
		
		if used then
			for count = 1, #used do
				if value[1] == used[count][2] then pfound = true break end
			end
		end
		if not pfound then
			table.insert(tempPetTable.choices, value[2])
			table.insert(tempPetTable.choicesValues, value[1])
			table.insert(tempPetTable.choicesTooltips, "|t400%:400%:"..value[3].."|t")
		end
	end
	table.insert(optionsData,tempPetTable)
	
	
	--------------------------------------------------
	-- Add a link button and a divider
	--------------------------------------------------
	local tempLinkTable = {
		type = "button",
		name = "Link Pet to Mount",
		func = function() LinkPetToMount.MakeLink() end
	}
	table.insert(optionsData, tempLinkTable)
	table.insert(optionsData,tempDivider)

	
	--------------------------------------------------
	-- Dynamically generate the dropdown list of linked pets and mounts
	--------------------------------------------------
	temptable = {
		type = "dropdown",
		name = "Linked Mounts and Pets",
		width = "half",
		reference = "LinkedDropdown",
		getFunc = function() return LinkPetToMount.chosenLink end,
		setFunc = function(linkid) LinkPetToMount.chosenLink = linkid end,
		choices = {},
		choicesValues = {}
	}
	local linkedSets = LinkPetToMount.CSV.linkedSets
	for key, value in ipairs(linkedSets) do
		local linkedMountid = value[1]
		local linkedPetid = value[2]
		
		local Mname = GetCollectibleInfo(linkedMountid)
		local Pname = GetCollectibleInfo(linkedPetid)
		local linkedMountName = ZO_CachedStrFormat(SI_UNIT_NAME, Mname)
		local linkedPetName = ZO_CachedStrFormat(SI_UNIT_NAME, Pname)
		
		table.insert(temptable.choices, linkedMountName.." ---> "..linkedPetName)
		table.insert(temptable.choicesValues, linkedMountid)
	end
	table.insert(optionsData,temptable)

	--------------------------------------------------
	-- Add an unlink button
	--------------------------------------------------	 		
		local temptable = {
			type = "button",
			name = "Unlink",
			func = function() LinkPetToMount.RemoveLink() end
		}
		table.insert(optionsData, temptable)

	panel = LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, optionsData)
end