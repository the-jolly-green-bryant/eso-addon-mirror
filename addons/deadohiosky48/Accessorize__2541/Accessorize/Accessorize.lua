--[[
-------------------------------------------------------------------------------
-- Accessorize by deadohiosky48
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at :
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

Much was learned (and some code shamelessly lifted) from:
		- PetZone by Brotanks
		- pChat by DesertDwellers
		- Daily Alchemy by Marify
]]

--[[
	TODO:
		- Update settings panel on outfit name change [EVENT_OUTFIT_RENAME_RESPONSE (number eventCode, SetOutfitNameResult response, number outfitIndex)] also look into [SET_OUTFIT_NAME_RESULT_SUCCESS]
		- Update settings panel on outfit slot acquisition (how to test??)
		- Update dropdowns on collectible add event (how to test??)
			??? EVENT_COLLECTIBLE_NEW_STATUS_CLEARED (number eventCode, number collectibleId)
			??? EVENT_COLLECTIBLE_NOTIFICATION_NEW (number eventCode, number collectibleId, number notificationId)
			??? EVENT_COLLECTIBLES_UPDATED (number eventCode, number numJustUnlocked)
		- Test for missing LibAddonMenu-2.0 and LibStub
		
		- Instead of updating on collectible add event, might be easier to add button to trigger refresh of dropdowns, need to test that
]]

Accessorize = Accessorize or {}

local ADDON_NAME			= "Accessorize"
local ADDON_MENUNAME		= "Accessorize"
local ADDON_VERSION			= "24"
local ADDON_VAR_VERSION		= 1013
local ADDON_AUTHOR			= "deadohiosky48"
local ADDON_WEBSITE			= "https://www.esoui.com/downloads/info2541-Accessorize.html"
local DEFAULT_COLLECTIBLE	= "--NONE--"
local LAM2 					= LibAddonMenu2

local db
local ddlData = {}

local defaults = {
	mount			= {},
	pet				= {},
	hairStyle		= {},
	bodyMarking		= {},
	facialAccessory	= {},
	facialHairHorns	= {},
	hat				= {},
	headMarking		= {},
	piercingJewelry	= {},
	skin			= {},
}

-- Fetch list of unlocked collectibles for a given collectible category that will be used to populate settings drop-down control
local function BuildCollectibleData(CollectibleData, CollectibleCategoryType, Choices, Values)
	local collectibleData = {}
	collectibleData[0] = DEFAULT_COLLECTIBLE

    for categoryIndex=1, GetNumCollectibleCategories() do

        local name, numSubCatgories, numCollectibles, unlockedCollectibles = GetCollectibleCategoryInfo(categoryIndex)

        for subCategoryIndex=1, numSubCatgories do

            local subCategoryName, subCategoryNumCollectibles, subCategoryUnlockedCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)

            for collectibleIndex=1, subCategoryNumCollectibles do

                local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
                local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)

				if categoryType == CollectibleCategoryType then
                    if unlocked and IsCollectibleValidForPlayer(collectibleId) then
						if not collectibleData[collectibleId] then
							collectibleData[collectibleId] = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName)
                        end
                    end
                end
            end
        end

        for collectibleIndex=1, numCollectibles do

            local collectibleId = GetCollectibleId(categoryIndex, nil, collectibleIndex)
            local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
            if categoryType == CollectibleCategoryType then
                if unlocked and IsCollectibleValidForPlayer(collectibleId) then
                    if not collectibleData[collectibleId] then
                        collectibleData[collectibleId] = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName)
                    end
                end
            end

        end

    end
	CollectibleData = collectibleData
	
	for k, v in pairs(CollectibleData) do
		table.insert(Choices, v)
		table.insert(Values, k)
	end
end

local function BuildLAMPanel()
	ddlData.PetData = {}
	ddlData.MountData = {}
	ddlData.HairStyleData = {}
	ddlData.BodyMarkingData = {}
	ddlData.FacialAccessoryData = {}
	ddlData.FacialHairHornsData = {}
	ddlData.HatData = {}
	ddlData.HeadMarkingData = {}
	ddlData.PiercingJewelryData = {}
	ddlData.SkinData = {}

	local mountChoices = {}
	local mountValues = {}
	local petChoices = {}
	local petValues = {}
	local hairStyleChoices = {}
	local hairStyleValues = {}
	local bodyMarkingChoices = {}
	local bodyMarkingValues = {}
	local facialAccessoryChoices = {}
	local facialAccessoryValues = {}
	local facialHairHornsChoices = {}
	local facialHairHornsValues = {}
	local hatChoices = {}
	local hatValues = {}
	local headMarkingChoices = {}
	local headMarkingValues = {}
	local piercingJewelryChoices = {}
	local piercingJewelryValues = {}
	local skinChoices = {}
	local skinValues = {}

	BuildCollectibleData(ddlData.PetData, COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, petChoices, petValues)
	BuildCollectibleData(ddlData.MountData, COLLECTIBLE_CATEGORY_TYPE_MOUNT, mountChoices, mountValues)
	BuildCollectibleData(ddlData.HairStyleData, COLLECTIBLE_CATEGORY_TYPE_HAIR, hairStyleChoices, hairStyleValues)
	BuildCollectibleData(ddlData.BodyMarkingData, COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING, bodyMarkingChoices, bodyMarkingValues)
	BuildCollectibleData(ddlData.FacialAccessoryData, COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY, facialAccessoryChoices, facialAccessoryValues)
	BuildCollectibleData(ddlData.FacialHairHornsData, COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS, facialHairHornsChoices, facialHairHornsValues)
	BuildCollectibleData(ddlData.HatData, COLLECTIBLE_CATEGORY_TYPE_HAT, hatChoices, hatValues)
	BuildCollectibleData(ddlData.HeadMarkingData, COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING, headMarkingChoices, headMarkingValues)
	BuildCollectibleData(ddlData.PiercingJewelryData, COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY, piercingJewelryChoices, piercingJewelryValues)
	BuildCollectibleData(ddlData.SkinData, COLLECTIBLE_CATEGORY_TYPE_SKIN, skinChoices, skinValues)

	-- Loop through each outfit and build submenu
	local submenuOptions = {}

	for outfitIndex = 1, GetNumUnlockedOutfits() do
		local outfitName = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, outfitIndex)

		-- If outfit has never been renamed by user, default name to Outfit + index (e.g. Outfit 1, Outfit 2, etc.)
		if string.len(outfitName) == 0 then
			outfitName = string.format("Outfit %s", outfitIndex)
		end

		submenuOptions[#submenuOptions + 1] = {
			type = "submenu",
			name = string.format("Outfit: %s", outfitName),
			controls = {
				{
					type = "dropdown",
					name = "Mount",
					reference = string.format("Mount_%s", outfitName),
					tooltip = "",
					sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
					choices = mountChoices,
					choicesValues = mountValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.mount[outfitName] then
							return db.mount[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedMount)
						db.mount[outfitName] = selectedMount

					end,
					width = "full", --or "half" (optional)
				},
				{
					type = "dropdown",
					name = "Non-Combat Pet",
					reference = string.format("Pet_%s", outfitName),
					tooltip = "",
					sort = "name-up",
					choices = petChoices,
					choicesValues = petValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.pet[outfitName] then
							return db.pet[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedPet)
						db.pet[outfitName] = selectedPet
					end,
					width = "full", --or "half" (optional)
				},
				{
					type = "dropdown",
					name = "Hair Style",
					reference = string.format("HairStyle_%s", outfitName),
					tooltip = "",
					sort = "name-up",
					choices = hairStyleChoices,
					choicesValues = hairStyleValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.hairStyle[outfitName] then
							return db.hairStyle[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedHairStyle)
						db.hairStyle[outfitName] = selectedHairStyle
					end,
					width = "full", --or "half" (optional)
				},
				{
					type = "dropdown",
					name = "Hat",
					reference = string.format("Hat_%s", outfitName),
					tooltip = "",
					sort = "name-up",
					choices = hatChoices,
					choicesValues = hatValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.hat[outfitName] then
							return db.hat[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedHat)
						db.hat[outfitName] = selectedHat
					end,
					width = "full", --or "half" (optional)
				},
				{
					type = "dropdown",
					name = "Body Marking",
					reference = string.format("BodyMarking_%s", outfitName),
					tooltip = "",
					sort = "name-up",
					choices = bodyMarkingChoices,
					choicesValues = bodyMarkingValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.bodyMarking[outfitName] then
							return db.bodyMarking[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedBodyMarking)
						db.bodyMarking[outfitName] = selectedBodyMarking
					end,
					width = "full", --or "half" (optional)
				},
				{
					type = "dropdown",
					name = "Head Marking",
					reference = string.format("HeadMarking_%s", outfitName),
					tooltip = "",
					sort = "name-up",
					choices = headMarkingChoices,
					choicesValues = headMarkingValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.headMarking[outfitName] then
							return db.headMarking[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedHeadMarking)
						db.headMarking[outfitName] = selectedHeadMarking
					end,
					width = "full", --or "half" (optional)
				},
				{
					type = "dropdown",
					name = "Facial Accessory",
					reference = string.format("FacialAccessory_%s", outfitName),
					tooltip = "",
					sort = "name-up",
					choices = facialAccessoryChoices,
					choicesValues = facialAccessoryValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.facialAccessory[outfitName] then
							return db.facialAccessory[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedFacialAccessory)
						db.facialAccessory[outfitName] = selectedFacialAccessory
					end,
					width = "full", --or "half" (optional)
				},
				{
					type = "dropdown",
					name = "Facial Hair/Horns",
					reference = string.format("FacialHairHorns_%s", outfitName),
					tooltip = "",
					sort = "name-up",
					choices = facialHairHornsChoices,
					choicesValues = facialHairHornsValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.facialHairHorns[outfitName] then
							return db.facialHairHorns[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedFacialHairHorns)
						db.facialHairHorns[outfitName] = selectedFacialHairHorns
					end,
					width = "full", --or "half" (optional)
				},
				{
					type = "dropdown",
					name = "Piercing Jewelry",
					reference = string.format("PiercingJewelry_%s", outfitName),
					tooltip = "",
					sort = "name-up",
					choices = piercingJewelryChoices,
					choicesValues = piercingJewelryValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.piercingJewelry[outfitName] then
							return db.piercingJewelry[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedPiercingJewelry)
						db.piercingJewelry[outfitName] = selectedPiercingJewelry
					end,
					width = "full", --or "half" (optional)
				},
				{
					type = "dropdown",
					name = "Skin",
					reference = string.format("Skin_%s", outfitName),
					tooltip = "",
					sort = "name-up",
					choices = skinChoices,
					choicesValues = skinValues,
					scrollable = true,
					default = 0,
					getFunc = function()
						if db.skin[outfitName] then
							return db.skin[outfitName]
						end

						return 0
					end,
					setFunc = function(selectedSkin)
						db.skin[outfitName] = selectedSkin
					end,
					width = "full", --or "half" (optional)
				},
			},
		}
	end

	LAM2:RegisterOptionControls("Accessorize_Settings", submenuOptions)
end

local function CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = ADDON_NAME,
		displayName = ADDON_MENUNAME,
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		website = ADDON_WEBSITE,
		slashCommand = "/accessorize",
		registerForRefresh = true,
	}

	LAM2:RegisterAddonPanel("Accessorize_Settings", panelData)

	local optionsData = {
		[1] = {
			type = "header",
			name = "Settings",
		},
		[2] = {
			type = "description",
			text = "Tired of roaming Tamriel with clashing collectibles? Choose which mount, pet, hair style, and other appearance collectibles you want to pair with your outfits and show off your sense of fashion!",
		},
	}

	BuildLAMPanel()
end

local function SwapCollectible(collectibleId, CollectibleCategoryType)
	-- Brief delay before changing collectible to help collision avoidance
	if GetCollectibleBlockReason(collectibleId) ~= 0 then
		return zo_callLater(function() SwapCollectible(collectibleId, CollectibleCategoryType) end, 2000)
	end

	local activeCollectibleId = GetActiveCollectibleByType(CollectibleCategoryType)
	
	-- Deactivate collectible if replacing it with nothing
	if collectibleId < 1 and activeCollectibleId > 0 and IsCollectibleValidForPlayer(activeCollectibleId) then
		UseCollectible(activeCollectibleId)
	end

	-- If same collectible is used for changed outfit, avoid using it because that will deactivate it
	if collectibleId ~= activeCollectibleId and IsCollectibleValidForPlayer(collectibleId) then
		UseCollectible(collectibleId)
	end
end

-- Set saved collectibles when outfit is equipped
local function OnPlayerOutfitEquip(event, equipOutfitResult)
	local outfitIndex = GetEquippedOutfitIndex()

	if outfitIndex then
		local outfitName = GetOutfitName(outfitIndex)

		if db.mount[outfitName] then
			SwapCollectible(db.mount[outfitName], COLLECTIBLE_CATEGORY_TYPE_MOUNT)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_MOUNT)
		end

		if db.pet[outfitName] then
			SwapCollectible(db.pet[outfitName], COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)
		end

		if db.hairStyle[outfitName] then
			SwapCollectible(db.hairStyle[outfitName], COLLECTIBLE_CATEGORY_TYPE_HAIR)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_HAIR)
		end

		if db.bodyMarking[outfitName] then
			SwapCollectible(db.bodyMarking[outfitName], COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING)
		end
		
		if db.facialAccessory[outfitName] then
			SwapCollectible(db.facialAccessory[outfitName], COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY)
		end

		if db.facialHairHorns[outfitName] then
			SwapCollectible(db.facialHairHorns[outfitName], COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS)
		end

		if db.hat[outfitName] then
			SwapCollectible(db.hat[outfitName], COLLECTIBLE_CATEGORY_TYPE_HAT)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_HAT)
		end

		if db.headMarking[outfitName] then
			SwapCollectible(db.headMarking[outfitName], COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING)
		end

		if db.piercingJewelry[outfitName] then
			SwapCollectible(db.piercingJewelry[outfitName], COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY)
		end

		if db.skin[outfitName] then
			SwapCollectible(db.skin[outfitName], COLLECTIBLE_CATEGORY_TYPE_SKIN)
		else
			SwapCollectible(0, COLLECTIBLE_CATEGORY_TYPE_SKIN)
		end
	end
end

local function OnPlayerOutfitRename(_, _, _)
	-- TODO: Refresh settings window to reflect outfit name change
end

-- For debugging
-- local function OnCollectibleUse(_, blockReason, _)
-- 	if blockReason > 0 then
-- 		d(string.format("Block reason: %s", blockReason))
-- 	end
-- end

function Accessorize:Initialize()
	-- Save/retrieve outfit/collectible pairings for each character independently
	db = ZO_SavedVars:NewCharacterIdSettings("AccessorizeVars", ADDON_VAR_VERSION, nil, defaults)
	Accessorize.db = db

	CreateSettingsWindow()

	-- Register for events
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OUTFIT_EQUIP_RESPONSE, OnPlayerOutfitEquip)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_OUTFIT_RENAME_RESPONSE, OnPlayerOutfitRename)
	-- EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COLLECTIBLE_USE_RESULT, OnCollectibleUse) -- For debugging

	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

	d(string.format("%s is ready to Accessorize!", GetUnitName("player")))
end

local function OnPlayerActivated(_, initial)
	-- Make sure dependency LibAddonMenu-2.0 is present
	if initial then
		if not LAM2 and LibStub then
			LAM2 = LibStub("LibAddonMenu-2.0")
		end
		if not LAM2 then d("Library LibAddonMenu-2.0 is missing!") return end
	end

	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
end

local function OnAddOnLoaded(event, addonName)
	if addonName == ADDON_NAME then
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

		Accessorize:Initialize()

		Accessorize.db = db
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)