-----------------------------------------------------------
-- RefinementTracker
-- Displays boosters obtained from refining raw materials
-- @author Kyzeragon
-----------------------------------------------------------

RefinementTracker = {}
RefinementTracker.name = "RefinementTracker"

local libDialog 

-- Defaults
local defaultOptions = {
    Enable = true,
    IgnoreLowExtraction = true,
    HideLowExtraction = true,
    AutoShow = true,
    Debug = false
}
local defaultValues = {
    Table = {
        [CRAFTING_TYPE_BLACKSMITHING] = {},
        [CRAFTING_TYPE_CLOTHIER] = {},
        [3] = {},
        [CRAFTING_TYPE_WOODWORKING] = {},
        [CRAFTING_TYPE_JEWELRYCRAFTING] = {}
    }
}

-- We start out not inside a crafting station
RefinementTracker.inCraftingStation = false
RefinementTracker.craftSkill = 0
RefinementTracker.refining = nil
RefinementTracker.results = {} -- Format: {[raw mat link] = {[booster link] = number}}

RefinementTracker.isVisible = false

---------------------------------------------------------------------
-- Initialize 
function RefinementTracker:Initialize()
    d("Initializing RefinementTracker...")
    libDialog = LibDialog

    -- Register
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self.OnInventoryChange)
    
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFT_COMPLETED, self.OnCraftingCompleted)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CRAFTING_STATION_INTERACT, self.OnEnterCrafting)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_END_CRAFTING_STATION_INTERACT, self.OnExitCrafting)

    -- Settings and saved variables
    self.SavedOptions = ZO_SavedVars:NewAccountWide("RefinementTrackerSavedVariables", 1, "Options", defaultOptions)
    self.SavedValues = ZO_SavedVars:NewAccountWide("RefinementTrackerSavedVariables", 1, "Values", defaultValues)
    RefinementTracker:CreateSettingsMenu()

    -- Don't know what false means...
    RefinementTracker.initializeWindow()
    SCENE_MANAGER:RegisterTopLevel(RefinementTrackerWindow, false)

    ZO_CreateStringId("SI_BINDING_NAME_REFINED_TOGGLE", "Toggle Refinement Tracker Results")

    libDialog:RegisterDialog("RefinementTracker", "ResetConfirmation", "Refinement Tracker", "Reset all data to 0?\nMake a backup of\n|c99FF99SavedVariables/RefinementTracker.lua|r if you're not sure!", resetData, nil, nil)

    if (RefinementTracker.SavedOptions.Debug) then
        d("RefinementTracker initialized!")
    end
end
 
---------------------------------------------------------------------
-- On Load
function RefinementTracker.OnAddOnLoaded(event, addonName)
    if addonName == RefinementTracker.name then
        EVENT_MANAGER:UnregisterForEvent(RefinementTracker.name, EVENT_ADD_ON_LOADED)
        RefinementTracker:Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(RefinementTracker.name, EVENT_ADD_ON_LOADED, RefinementTracker.OnAddOnLoaded)


---------------------------------------------------------------------
-- Event Handlers

-- EVENT_CRAFT_COMPLETED (number eventCode, TradeskillType craftSkill)
function RefinementTracker.OnCraftingCompleted(eventCode, craftSkill)
    -- d(craftSkill)
end

-- EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
function RefinementTracker.OnInventoryChange(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if (RefinementTracker.inCraftingStation) then
        local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
        local itemType, specializedType = GetItemLinkItemType(link)

        -- This means refining, if losing raw materials
        if (stackCountChange < 0 and isRawMaterial(itemType)) then
            RefinementTracker.refining = link
            if (RefinementTracker.SavedOptions.Debug) then
                d("Lost " .. -stackCountChange .. "x " .. tostring(link))
            end

            -- Add entry if doesn't exist
            if (RefinementTracker.results[link] == nil) then
                RefinementTracker.results[link] = {}
                RefinementTracker.results[link]["used"] = 0
            end
            -- Increment number used
            RefinementTracker.results[link]["used"] = RefinementTracker.results[link]["used"] - stackCountChange
            -- Update GUI immediately
            local _, _, _, rawId = ZO_LinkHandler_ParseLink(RefinementTracker.refining)
            RefinementTracker.mergeToGui(tonumber(rawId),
                RefinementTracker.craftSkill, -1, -stackCountChange)
            return
        end

        -- Losing non-raw means some other kind of crafting 
        if (stackCountChange < 0) then
            RefinementTracker.refining = nil
            return
        end

        -- This means gained... stuff
        if (not (RefinementTracker.refining == nil) and stackCountChange > 0) then
            if (RefinementTracker.SavedOptions.Debug) then
                d("Obtained " .. stackCountChange .. "x " .. tostring(link))
            end

            if (isBooster(itemType)) then
                -- Add entry if doesn't exist
                if (RefinementTracker.results[RefinementTracker.refining][link] == nil) then
                    RefinementTracker.results[RefinementTracker.refining][link] = 0
                end
                -- Increment number obtained
                RefinementTracker.results[RefinementTracker.refining][link] = RefinementTracker.results[RefinementTracker.refining][link] + stackCountChange
                -- Update GUI immediately
                local _, _, _, rawId = ZO_LinkHandler_ParseLink(RefinementTracker.refining)
                RefinementTracker.mergeToGui(tonumber(rawId), RefinementTracker.craftSkill,
                    GetItemLinkQuality(link), stackCountChange)
                return
            end
        end
    end
end

-- EVENT_CRAFTING_STATION_INTERACT (number eventCode, TradeskillType craftSkill, boolean sameStation)
function RefinementTracker.OnEnterCrafting(eventCode, craftSkill, sameStation)
    -- Must be one of the skill types that have refine-able raw materials
    if (craftSkill == CRAFTING_TYPE_BLACKSMITHING or
        craftSkill == CRAFTING_TYPE_CLOTHIER or
        craftSkill == CRAFTING_TYPE_JEWELRYCRAFTING or
        craftSkill == CRAFTING_TYPE_WOODWORKING) then

        local current, max = getExtractionLevel(craftSkill)
        if (RefinementTracker.SavedOptions.Debug) then
            d("Entered crafting station")
            d("Extraction level is " .. current .. " / " .. max)
        end

        RefinementTracker.craftSkill = craftSkill
        RefinementTracker.refining = nil
        RefinementTracker.results = {}

        if (RefinementTracker.SavedOptions.AutoShow) then
            if (current == max or not RefinementTracker.SavedOptions.HideLowExtraction) then
                RefinementTracker.showWindow()
            end
        end

        -- Only record if extraction level is max, or if user has set it to allow non-max
        if (current == max
            or not RefinementTracker.SavedOptions.IgnoreLowExtraction) then
            RefinementTracker.inCraftingStation = true
            RefinementTrackerWindow:GetNamedChild("Warning"):SetHidden(true)
        else
            -- Otherwise, show a warning on the panel
            RefinementTrackerWindow:GetNamedChild("Warning"):SetHidden(false)
        end
    end
end

-- EVENT_END_CRAFTING_STATION_INTERACT (number eventCode, TradeskillType craftSkill)
function RefinementTracker.OnExitCrafting(eventCode, craftSkill)
    RefinementTracker.hideWindow()
    if (not RefinementTracker.inCraftingStation) then
        return
    end

    RefinementTracker.inCraftingStation = false
    if (RefinementTracker.SavedOptions.Debug) then
        d("Exited crafting station")
    end

    if RefinementTracker.SavedOptions.Enable then
        for link, results in pairs(RefinementTracker.results) do
            local prefix = "Refined " .. link .. "x" .. RefinementTracker.results[link]["used"] .. ":"
            local outputString = ""
            for item, num in pairs(results) do
                if (item ~= "used") then
                    outputString = outputString .. " " .. item .. "x" .. num
                end
            end
            if (outputString == "") then
                outputString = " No boosters"
            end
            d(prefix .. outputString)
        end
    end

    -- Redundant reset?
    RefinementTracker.refining = nil

    mergeToStorage()
end


---------------------------------------------------------------------
-- Reset functionality
function resetData()
    -- It would be better to just set the table to default...
    -- but I need it to be zeroes to reset the GUI immediately, because lazy
    for craftId, craftType in pairs(RefinementTracker.SavedValues.Table) do
        for rawId, boosters in pairs(craftType) do
            for boosterId, numObtained in pairs(boosters) do
                RefinementTracker.SavedValues.Table[craftId][rawId][boosterId] = 0
            end
        end
    end

    RefinementTracker.populateGui()
    d("Refinement Tracker values reset!")
end

function RefinementTracker.askReset()
    libDialog:ShowDialog("RefinementTracker", "ResetConfirmation", nil)
end


---------------------------------------------------------------------
-- Data Structure Thingies

-- Merges results into RefinementTracker.SavedValues.Table
-- Do this on crafting station exit, instead of after every refinement
function mergeToStorage()
    -- SavedValues.Table format: {[craftSkill] = {[raw id link] = {[booster id] = number}}}
    -- results format: {[raw mat link] = {[booster link] = number}}

    for rawLink, boosters in pairs(RefinementTracker.results) do
        local _, _, _, rawId = ZO_LinkHandler_ParseLink(rawLink)

        -- This is needed because both light and medium are in Clothing
        local currentCraftSkill = RefinementTracker.craftSkill
        if (RefinementTracker.craftSkill == CRAFTING_TYPE_CLOTHIER) then
            -- Why is Lua so annoying
            if (rawId == "793" or
                rawId == "4448" or
                rawId == "23095" or
                rawId == "6020" or
                rawId == "23097" or
                rawId == "23142" or
                rawId == "23143" or
                rawId == "800" or
                rawId == "4478" or
                rawId == "71239") then
                currentCraftSkill = 3
            end
        end

        if (RefinementTracker.SavedValues.Table[currentCraftSkill][rawId] == nil) then
            RefinementTracker.SavedValues.Table[currentCraftSkill][rawId] = {}
        end

        for boosterLink, total in pairs(boosters) do
            if (boosterLink == "used") then
                if (RefinementTracker.SavedValues.Table[currentCraftSkill][rawId]["used"] == nil) then
                    RefinementTracker.SavedValues.Table[currentCraftSkill][rawId]["used"] = 0
                end
                RefinementTracker.SavedValues.Table[currentCraftSkill][rawId]["used"] =
                    RefinementTracker.SavedValues.Table[currentCraftSkill][rawId]["used"] + total
            else
                local _, _, _, boosterId = ZO_LinkHandler_ParseLink(boosterLink)
                if (RefinementTracker.SavedValues.Table[currentCraftSkill][rawId][boosterId] == nil) then
                    RefinementTracker.SavedValues.Table[currentCraftSkill][rawId][boosterId] = 0
                end
                RefinementTracker.SavedValues.Table[currentCraftSkill][rawId][boosterId] = 
                    RefinementTracker.SavedValues.Table[currentCraftSkill][rawId][boosterId] + total
            end
        end
    end
end

---------------------------------------------------------------------
-- Utility
function isRawMaterial(itemType)
    if (itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or
        itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or
        itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL or
        itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL) then
        return true
    end
    return false
end

function isBooster(itemType)
    if (itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or
        itemType == ITEMTYPE_CLOTHIER_BOOSTER or
        itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER or
        itemType == ITEMTYPE_WOODWORKING_BOOSTER) then
        return true
    end
    return false
end

-- Based on LibLazyCrafting - uses texture to match... interesting
function getExtractionLevel(station)
    local SkillTextures = 
    {
        [CRAFTING_TYPE_BLACKSMITHING] = "/esoui/art/icons/ability_smith_003.dds",
        [CRAFTING_TYPE_CLOTHIER] = "/esoui/art/icons/ability_tradecraft_005.dds",
        [CRAFTING_TYPE_WOODWORKING] = "/esoui/art/icons/ability_tradecraft_006.dds",
        [CRAFTING_TYPE_JEWELRYCRAFTING] = "/esoui/art/icons/passive_jewelryextraction.dds"
    }
    local skillType, skillIndex = GetCraftingSkillLineIndices(station)
    local abilityIndex = nil
    for i = 1, GetNumSkillAbilities(skillType, skillIndex) do
        local _, texture = GetSkillAbilityInfo(skillType, skillIndex, i)
        if texture == SkillTextures[station] then
            abilityIndex = i
        end
    end
    if abilityIndex then

        local currentSkill, maxSkill = GetSkillAbilityUpgradeInfo(skillType,skillIndex,abilityIndex)

        return currentSkill , maxSkill
    else
        return 0,1
    end
end
