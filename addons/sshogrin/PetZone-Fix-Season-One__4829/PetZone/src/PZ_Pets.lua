if PZ == nil then PZ = {} end
local PetZone = PZ

--Check the collectibles and build the Pet data
--> Taken this code to check collectibles from addon PimpMyride by Ayantir:
--http://www.esoui.com/downloads/info1140-PimpmyRide-CollectibleRandomizerOutfitter.html
function PetZone.BuildPetData()
	PetZone.PetData = {}
    local PetData = {}

    for categoryIndex=1, GetNumCollectibleCategories() do
	
        local name, numSubCatgories, numCollectibles, unlockedCollectibles = GetCollectibleCategoryInfo(categoryIndex)
		
        for subCategoryIndex=1, numSubCatgories do

            local subCategoryName, subCategoryNumCollectibles, subCategoryUnlockedCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)

            for collectibleIndex=1, subCategoryNumCollectibles do

                local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
                local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
                --Only Pets
                if categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET then
                    if unlocked then
                        if not PetData[collectibleId] then
                            local PetName = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName)
                            PetData[collectibleId] = PetName
                        end
                    end
               end
            end
		end
        for collectibleIndex=1, numCollectibles do

            local collectibleId = GetCollectibleId(categoryIndex, nil, collectibleIndex)
            local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
            if categoryType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET then
                if unlocked then
                    if not PetData[collectibleId] then
                        local PetName = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName)
                        PetData[collectibleId] = PetName
                    end
                end
            end

        end

    end
    PetZone.PetData = PetData
end

function PetZone.GetPetByZone(zone, subZone)
	local PetToUse = 0
	if GetMapType() <= MAPTYPE_ZONE  then	
		local settings = PetZone.settingsVars.settings
		local settingsZone2Pet = settings.zone2Pet
		-- Abort if no zone is specified
		if zone == PZ_NONE_ENTRIES then
			return 0
		end
		if zone == nil or subZone == nil then
			zone, subZone = PetZone.GetZoneAndSubzone()
		end
		local zoneData = PetZone.GetZoneData(zone, subZone)
		if zoneData ~= nil then
		--d(">found zoneData, subZone: " ..tostring(subZone))
			--Use the zone or subZone name to get the saved Pet for it
			if zone ~= nil and subZone ~= nil and settingsZone2Pet[zone] ~= nil and settingsZone2Pet[zone][subZone] ~= nil and settingsZone2Pet[zone][subZone] ~= 0 then --settingsZone2Pet[zone][subZone].PetId ~= 0
                PetToUse = settingsZone2Pet[zone][subZone] --settingsZone2Pet[zone][subZone].PetId
				--d(">pet assigned to both zone and subzone: " ..tostring(PetToUse))
                --Use the zone PetId (-ALL- subZone) as subZone PetId is not set yet
            elseif zone ~= nil and settingsZone2Pet[zone] ~= nil and settingsZone2Pet[zone].PetId ~= nil and settingsZone2Pet[zone].PetId ~= 0 then
                PetToUse = settingsZone2Pet[zone].PetId
				--d(">Pet assigned to zone: " ..tostring(PetToUse))
			elseif settingsZone2Pet["-ALL-"] ~= nil and settingsZone2Pet["-ALL-"].PetId ~= nil then
				--Use the PetId for -ALL- zones if this zone isn't set
				PetToUse = settingsZone2Pet["-ALL-"].PetId
				--d(">Pet assigned to all zones: " ..tostring(PetToUse))
			end
		end
	end
	--d("<PetToUse: " ..tostring(PetToUse))
	return PetToUse
end

--Get the currently active/used Pet ID from the collectibles
function PetZone.GetActivePet()
    local activePetId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
    if activePetId == nil or activePetId == 0 then
        -- * GetCollectibleInfo(*integer* _collectibleId_)
        -- ** _Returns:_ *string* _name_, *string* _description_, *textureName* _icon_, *textureName* _deprecatedLockedIcon_, *bool* _unlocked_, *bool* _purchasable_, *bool* _isActive_, *[CollectibleCategoryType|#CollectibleCategoryType]* _categoryType_, *string* _hint_, *bool* _isPlaceholder_
        for _, PetId in ipairs(PetZone.DropdownPetValues) do
            if type(PetId) == "number" then
				local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint, isPlaceholder = GetCollectibleInfo(PetId)
            --d(">name: " .. tostring(name) .. ", unlocked: " ..tostring(unlocked) .. ", isActive: " .. tostring(isActive))
				if isActive then
					return PetId
				end
			end
        end
    end
    return activePetId
end

--Assistants trade out with your pets. This keeps your pets from interrupting transactions
function PZ.isAssistantActive()
	local activeAssistant = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
	if activeAssistant == nil or activeAssistant == 0 then return false end
	return true
end

function PetZone.hidePet()
	local petBlock = GetCollectibleBlockReason(PetZone.DropdownPetValues[table.maxn(PetZone.DropdownPetValues)])
	local currentPetId = PetZone.GetActivePet()
	if currentPetId ~= 0 and not PZ.isAssistantActive() and petBlock == 0 then
		PetZone.preventerVars.doNotChangePresetPet = true
--		d("hidehide")
		ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_COLLECTIBLE_USE_BLOCKED, function() return true end)
		EVENT_MANAGER:RegisterForEvent(PetZone.addonVars.addonName,  EVENT_COLLECTIBLE_USE_BLOCKED, function() zo_callLater(PetZone.OnBlocked, 250) end)
		UseCollectible(currentPetId)
		EVENT_MANAGER:UnregisterForEvent(PetZone.addonVars.addonName,  EVENT_COLLECTIBLE_USE_BLOCKED)
		ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_COLLECTIBLE_USE_BLOCKED, function() return false end)
		zo_callLater(function() PetZone.hidePet() end, 200) --gotta make sure this sucker is gone. Combat is wonky.
	end
end

--choose the pet now
function PetZone.ChoosePetNow(PetId)
	local currentPetId = PetZone.GetActivePet()
	--check to see if there's a cooldown, and delay if so. This hopefully helps with those pesky "collectible not ready" errors
	if GetCollectibleBlockReason(PetZone.DropdownPetValues[table.maxn(PetZone.DropdownPetValues)]) ~= 0 then
		return zo_callLater(function()
            PetZone.ChoosePetNow(PetId)
        end, 1000)
	end
	if PetId == -2 then --clear any active pets if it's -NONE-
		PetZone.hidePet()
		return true
	elseif PetId == -1 then --get a random pet if it's -RANDOM-
		local RandomPet = 0
		local maxPets = table.maxn(PetZone.DropdownPetValues)
		while RandomPet == 0 or RandomPet == currentPetId or type(RandomPet) ~= "number" or PZ.tableContains(PetZone.settingsVars.settings.ExList, RandomPet) do --make sure it doesn't return the current active pet, an invalid selection, or a kenneled pet
			local Rand = math.random(4, maxPets) --starting later since beginning positions are - -, -RANDOM-, -NONE-
			RandomPet = PetZone.DropdownPetValues[Rand]
		end
		if not IsCollectibleBlocked(RandomPet) then
			PetZone.preventerVars.doNotChangePresetPet = true
			ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_COLLECTIBLE_USE_BLOCKED, function() return true end)
			EVENT_MANAGER:RegisterForEvent(PetZone.addonVars.addonName,  EVENT_COLLECTIBLE_USE_BLOCKED, function() zo_callLater(PetZone.OnBlocked, 250) end)
			UseCollectible(RandomPet)
			EVENT_MANAGER:UnregisterForEvent(PetZone.addonVars.addonName,  EVENT_COLLECTIBLE_USE_BLOCKED)
			ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_COLLECTIBLE_USE_BLOCKED, function() return false end)
			return true
		end
	elseif PetId ~= currentPetId and not IsCollectibleBlocked(PetId) and type(PetId) ~= "table" then
		PetZone.preventerVars.doNotChangePresetPet = true
		ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_COLLECTIBLE_USE_BLOCKED, function() return true end)
		EVENT_MANAGER:RegisterForEvent(PetZone.addonVars.addonName,  EVENT_COLLECTIBLE_USE_BLOCKED, function() zo_callLater(PetZone.OnBlocked, 250) end)
		UseCollectible(PetId)
		EVENT_MANAGER:UnregisterForEvent(PetZone.addonVars.addonName,  EVENT_COLLECTIBLE_USE_BLOCKED)
		ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_COLLECTIBLE_USE_BLOCKED, function() return false end)
		return true
	end
	return false
end

--Check the zone & subzone Pet settings and set the collectible as active now, if already set for the zone & subzone
function PetZone.ActivatePetForZone(zone, subZone)
	--stop switch if any assistants are active. That's getting annoying.
	if PZ.isAssistantActive() then return false end
	--stop switch if the pet is hidden for combat, dungeons, groups or stealth
	local CombatBlock = (IsUnitInCombat("player") and PetZone.settingsVars.settings.HideInCombat)
	local DungeonBlock = (IsUnitInDungeon("player") and PetZone.settingsVars.settings.HideInDungeons)
	local GroupBlock = (IsPlayerInGroup(GetUnitDisplayName("player")) and PetZone.settingsVars.settings.HideInGroups)
	local StealthBlock = (GetUnitStealthState("player") ~= 0 and PetZone.settingsVars.settings.HideInStealth)
--	d("combat: " .. tostring(CombatBlock) .. "! dungeon: " .. tostring(DungeonBlock) .. "! group: " .. tostring(GroupBlock) .. "! stealth: " .. tostring(StealthBlock) .. "!")
	if CombatBlock or DungeonBlock or GroupBlock or StealthBlock then
		PetZone.hidePet()
--		d("hiding pet..")
		return false 
	end
    --Get the chosen Pet for this zone and subzone
    if zone == nil then
        zone, subZone = PetZone.GetZoneAndSubzone()
    end
--d("ActivatePetForZone - zone: " .. tostring(zone) .. ", subZone: " .. tostring(subZone))
    --Get the Pet from the settings by help of the zone name, and subzone name
    local PetId = PetZone.GetPetByZone(zone, subZone)
	local currentPetId = PetZone.GetActivePet()
	if type(PetId) == "string" then --custom random lists!
		local masterList = PetZone.settingsVars.settings.CustRandLists
		if not PZ.tableContains(masterList, PetId, false, true) then return false end
		for name, randTable in pairs(masterList) do
			if name == PetId then 
				PetId = randTable
				break
			end
		end
		local RandomPet = 0
		local maxPets = table.maxn(PetId)
		if maxPets == 1 then 
			RandomPet = PetId[1]  --skips the while loop
		elseif maxPets > 1 then
			while RandomPet == 0 do
				local Rand = math.random(1, maxPets)
				RandomPet = PetId[Rand]
			end
		end
		PetId = RandomPet
	end
	--checking for various reasons not to continue
	if PetId > 0 and GetCollectibleBlockReason(PetId) ~= 0 then --check to see if the pet is blocked for any reason, like being in a player house             
--		d("Blocked! block id: " ..GetCollectibleBlockReason(PetId) .." pet id: " ..PetId)
		return false
	elseif PetId == -2 and currentPetId == 0 then --pet is already hidden
		return false 
	end
--d(">PetId: " .. tostring(PetId) .. ", PetName:  " .. ZO_CachedStrFormat("<<C:1>>", GetCollectibleInfo(PetId)))
    --Was a Pet chosen? Is it not the current Pet? Then activate it now
    if PetId ~= currentPetId then
		if PetId ~= nil and PetId ~= 0 then
--			d("choosing pet...")
			return PetZone.ChoosePetNow(PetId)
		end
	end
    return false
end

--Check if the currently active Pet is the one to be used for the zone & subzone, and if not set the active Pet as
--the one for the zone & subzone now!
function PetZone.checkAndPresetPetForZone()
    local presetPet = false
    --Get the chosen Pet for this zone and subzone
    local zone, subZone = PetZone.GetZoneAndSubzone()
    --Get the Pet from the settings by help of the zone name, and subzone name
    local savedPetIdForZone = PetZone.GetPetByZone(zone, subZone)
    --Get the actively used Pet
    local activePetId = PetZone.GetActivePet()

--d("[PetZone.checkAndPresetPetForZone] zone: " .. tostring(zone) ..", subZone: " .. tostring(subZone) .. ", savedPetIdForZone: " ..tostring(savedPetIdForZone) .. ", activePetId: " .. tostring(activePetId))

    --Is any Pet set for the current zone and subzone yet?
    if savedPetIdForZone == nil or savedPetIdForZone == 0 then
        --No Pet set yet so just set it now
        presetPet = true
    else
        --The Pet set in the settings for the current zone & subzone is not the actively chosen Pet?
        if savedPetIdForZone ~= activePetId then
            presetPet = true
        end
    end
    --Should the Pet be saved as preset Pet for the zone & subzone now?
--d(">presetPet: " ..tostring(presetPet))
    if presetPet then
        --Set the current active Pet as new Pet now
        PetZone.SavePetIdToSettings(activePetId, false, zone, subZone)
    end
end
