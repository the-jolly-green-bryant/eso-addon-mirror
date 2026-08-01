BSY = {}

BSY.name = 'BetaScry'
BSY.displayname = 'BetaScry'
BSY.version = 'v1.0.0'
BSY.author = 'Latetide'
BSY.init = false
BSY.accountVariableVersion = 1
BSY.characterVariableVersion = 1
BSY.isDebug = false                      -- switch this on for debugging to the console, or use /bsydbg
BSY.useCustomFilter = false

BSY.ZO_SortFunction = nil

BSY.sortingType = 1 -- should pick from the enum below

BSY.sortingTypeEnum = { -- not used, but maybe in the future
    "None", -- 1
    "Quality", -- 2
    "Type", -- 3
    "Expiry" -- 4 
}

-- This stores the filtering settings, modified in the Dialog lua code
BSY.scryFilter = {
    showRequiresLead = true,
    showInProgress = true,
    minimumQuality = 1,
    maximumQuality = 5,
    atype = nil -- nil is used for "not filtering"
}

-- ESO globals
local EM, WM, SM = EVENT_MANAGER, WINDOW_MANAGER, SCENE_MANAGER
local AM = ANTIQUITY_MANAGER
local ADM = ANTIQUITY_DATA_MANAGER 
local AJK = ANTIQUITY_JOURNAL_KEYBOARD
local RM = REWARDS_MANAGER -- to get the type of the lead

--- Writes trace messages to the console
-- fmt with %d, %s,
local function trace(fmt, ...)
	if BSY.isDebug then
		d(string.format(fmt, ...))
    end
end

-- walks through the table and creates a formatted string to represent it
local function printTableKeys(tbl)
    local output = ""

    if type(tbl) ~= "table" then
        output = "Printing non table: " .. type(tbl)
    else
        output = "Keys: \n"
        for k, v in pairs(tbl) do
            local add = "?"
            if type(v) == "table" then
                add = "table"
            else
                add = tostring(v)
            end
            output = output .. k .. " -> " .. add .. "\n"
        end
    end
    trace(output)
    return output
end

function BSY.ToggleDebug(extra)
    BSY.isDebug = not BSY.isDebug
    if BSY.isDebug then
        d("BetaScry: debug messages ON")
    else
        d("BetaScry: debug messages OFF")
    end
end

--------------------------------------------------------
-- True if an antique is scryable
function BSY.IsScryable(antiquityData)
    return not antiquityData:HasAchievedAllGoals() and antiquityData:MeetsLeadRequirements() and antiquityData:MeetsScryingSkillRequirements() -- and antiquityData:MeetsAllScryingRequirements()
end

-------------------------------------------------------
-- Returns the name of the quality (int -> string)
function BSY.GetQualityString(Quality)
    local QUALITY = {
        [0]={"White"},
        [1]={"Green"},
        [2]={"Blue"},
        [3]={"Purple"},
        [4]={"Gold"},
        [5]={"Orange"},
        [6]={"Red"}
    }
    return unpack(QUALITY[Quality])
end

-----------------------------------------------------
-- Lists all leads which are scryable
function BSY.ListHints()
    for antiquityId, antiquityData in pairs (ADM.antiquities) do
--        trace ("A: %s", ADM.antiquities [i].name)
        if antiquityData:HasDiscovered () then
            if BSY.IsScryable(antiquityData) then
                local zoneName = GetZoneNameById(antiquityData.zoneId)
                trace ("Id: %d - ZoneName: %s - Name: %s - Diff: %s", antiquityId, zoneName, antiquityData.name, BSY.GetQualityString (antiquityData:GetQuality()))
               -- trace ("IsScryable: %s", tostring(BSY.IsScryable(antiquityData)))
            end
            -- 
        end
                -- https://github.com/esoui/esoui/blob/master/esoui/ingame/antiquities/antiquitydata.lua
    end
end

-- based on
-- https://github.com/esoui/esoui/blob/master/esoui/ingame/antiquities/antiquitydata.lua -> Antiquity data and methods
-- https://github.com/esoui/esoui/blob/master/esoui/ingame/rewards/ingame_rewards_manager.lua -> Lead type string

-- gets the type of the lead from the Reward manager - uses Part if empty. "Part" *must* match with the code in the dialog code
function getAType(antiquityData)
    return RM:GetRewardContextualTypeString(antiquityData.rewardId) or "Part"
end

-- not sure when this is used, but I decided to keep it up to date, just to be sure
function BSY.FilterCore(antiquityData)
    local scryFilter = BSY.scryFilter

    -- Requires lead filter
    if not scryFilter.showRequiresLead and antiquityData:RequiresLead() then return false end

    local fit = true

    -- Quality filter
    if scryFilter.minimumQuality >= scryFilter.maximumQuality then
        fit = scryFilter.minimumQuality > antiquityData:GetQuality()
    else
        fit = scryFilter.minimumQuality <= antiquityData:GetQuality() and scryFilter.maximumQuality >= antiquityData:GetQuality() 
    end

    local typed = true
    if scryFilter.atype == nil then 
        typed = true
    else
        typed = getAType(antiquityData) == scryFilter.atype
    end

    return not antiquityData:HasAchievedAllGoals() and fit and typed and antiquityData:MeetsScryingSkillRequirements() -- and antiquityData:MeetsLeadRequirements()
end


--- this function hijacks IsInCurrentPlayerZone and adds additional filters
function BSY:CustomIsInCurrentPlayerZone()
    -- original condition
    if not self:IsInZone(ZO_ExplorationUtils_GetPlayerCurrentZoneId()) then return false end

    local scryFilter = BSY.scryFilter

    -- Requires lead filter
    if not scryFilter.showRequiresLead and self:RequiresLead() then return false end

    -- Quality filter
    if scryFilter.minimumQuality > self:GetQuality() or scryFilter.maximumQuality < self:GetQuality() then return false end

    -- Type filter
    if scryFilter.atype ~= nil and scryFilter.atype ~= getAType(self) then return false end

    -- In Progress Filter
    if not scryFilter.showInProgress and (self:GetNumGoalsAchieved() > 0) then return false end

    return true
end

--- this function hijacks MeetsLeadRequirements and adds additional filters
function BSY:CustomMeetsLeadRequirements()
    -- original condition
    if (not self:RequiresLead() or self:HasLead()) == false then return false end

    local scryFilter = BSY.scryFilter

    -- Requires lead filter
    if not scryFilter.showRequiresLead and self:RequiresLead() then return false end

    -- Quality filter
    if scryFilter.minimumQuality > self:GetQuality() or scryFilter.maximumQuality < self:GetQuality() then return false end

    -- Type filter
    if scryFilter.atype ~= nil and scryFilter.atype ~= getAType(self) then return false end

    return true
end

--- this function hijacks IsInProgress and adds additional filters
function BSY:CustomIsInProgress() 
    local scryFilter = BSY.scryFilter

    -- Requires lead filter
    if not scryFilter.showRequiresLead and self:RequiresLead() then return false end

    -- Quality filter
    if scryFilter.minimumQuality > self:GetQuality() or scryFilter.maximumQuality < self:GetQuality() then return false end

    -- Type filter
    if scryFilter.atype ~= nil and scryFilter.atype ~= getAType(self) then return false end

    -- In Progress Filter
    return scryFilter.showInProgress and (self:GetNumGoalsAchieved() > 0)
end

-- called when you accept the changes on the dialog or switch the apply button on
function BSY.ApplyFilter()
    trace ("BSY.ApplyFilter")
        
    BSY.useCustomFilter = true
    local filterfuncMR = BSY.CustomMeetsLeadRequirements
    local filterfuncPZ = BSY.CustomIsInCurrentPlayerZone
    local filterfuncIP = BSY.CustomIsInProgress
    BSY.ToggleButton:SetState(BSTATE_PRESSED)

    local count = 0

    for _, antiquityData in pairs (ADM.antiquities) do
        -- current zone
        antiquityData.IsInCurrentPlayerZone = filterfuncPZ

        -- all zones
        antiquityData.MeetsLeadRequirements = filterfuncMR
        antiquityData.IsInProgress = filterfuncIP

        count = count + 1

    end
    trace("Total antiquity count: " .. count)

    ADM:RefreshAll()
end


function BSY.ClearFilter()
    trace ("BSY.ClearFilter")

    BSY.useCustomFilter = false
    local filterfuncPZ = ZO_Antiquity.IsInCurrentPlayerZone
    local filterfuncMR = ZO_Antiquity.MeetsLeadRequirements
    local filterfuncIP = ZO_Antiquity.IsInProgress
    BSY.ToggleButton:SetState(BSTATE_NORMAL)
    
    for _, antiquityData in pairs (ADM.antiquities) do
        -- current zone
        antiquityData.IsInCurrentPlayerZone = filterfuncPZ

        -- all zones
        antiquityData.MeetsLeadRequirements = filterfuncMR
        antiquityData.IsInProgress = filterfuncIP
    end 

    ADM:RefreshAll()
end


function BSY.ShowChangeFilterDialog() 
    trace ("BSY.ShowChangeFilterDialog")
    ZO_Dialogs_ShowDialog("BSY_CHANGE_FILTER_DIALOG", {})
end

function BSY.ToggleShowAll()
    trace ("BSY.ToggleFilter")
    BSY.useCustomFilter = not BSY.useCustomFilter

    if BSY.useCustomFilter then
        BSY.ApplyFilter()
    else
        BSY.ClearFilter()
    end
end

function BSY.InitButton()
    -- create button
    local cParent = WM:GetControlByName("ZO_AntiquityJournal_Keyboard_TopLevelContents")
    local cSearch = cParent:GetNamedChild("Search")

    -- toggle button
    local cTB = WM:CreateControl('BSY_ToggleButton', cParent, CT_BUTTON)
    cTB:SetAnchor(BOTTOMRIGHT, cSearch, TOPRIGHT, 0, 0)
    cTB:SetDimensions(25, 25)
    cTB:SetNormalTexture('esoui/art/inventory/inventory_tabicon_all_up.dds')
    cTB:SetPressedTexture('esoui/art/inventory/inventory_tabicon_all_down.dds')
    cTB:SetMouseOverTexture('esoui/art/inventory/inventory_tabicon_all_over.dds')
    cTB:SetHandler('OnClicked',function() BSY.ToggleShowAll() end)
    BSY.ToggleButton = cTB

    -- change filter button
    local cCF = WM:CreateControl('BSY_ChangeFilterButton', cParent, CT_BUTTON)
    cCF:SetAnchor(RIGHT, cTB, LEFT, -5, 0)
    cCF:SetDimensions(25, 25)
    cCF:SetNormalTexture('esoui/art/chatwindow/chat_options_up.dds')
    cCF:SetPressedTexture('esoui/art/chatwindow/chat_options_down.dds')
    cCF:SetMouseOverTexture('esoui/art/chatwindow/chat_options_over.dds')
    cCF:SetHandler('OnClicked',function() BSY.ShowChangeFilterDialog() end)
end


function BSY:NewFunc()
    trace("In NewFunc")
    self:OldFunc()
end

function BSY:Initialize()

    local function OnAntiquityLeadAcquired(event, antiquityId)
        local antiquityData = ADM:GetAntiquityData(antiquityId)

        local colorDef = GetAntiquityQualityColor(antiquityData:GetQuality())
        local name = colorDef:Colorize(antiquityData:GetName())
        --d(antiquityData.antiquityCategoryData)

        d("|cFFAA33BetaScry - new lead:|r "..name)
    end
    

	SLASH_COMMANDS["/bsydbg"] = BSY.ToggleDebug

    AJK.OldFunc = AJK.AcquireAntiquitySectionList
    AJK.AcquireAntiquitySectionList = BSY.NewFunc

    
    EM:RegisterForEvent("BetaScry", EVENT_ANTIQUITY_LEAD_ACQUIRED, OnAntiquityLeadAcquired)

    -- Create Key Binding Labels
    -- ZO_CreateStringId('SI_BINDING_NAME_BETASCRY_LIST_HINTS', "Show Hints")	

    -- save sort function
    BSY.ZO_SortFunction = ZO_DefaultAntiquitySortComparison

    -- initialize toggle button
	zo_callLater(BSY.InitButton, 900)

    BSY.init = true
end

function BSY.OnAddOnLoaded(event, addonName)
  if addonName ~= BSY.name then return end

  EM:UnregisterForEvent('BSY_LOADED',EVENT_ADD_ON_LOADED)
  
  BSY:Initialize()
end

EM:RegisterForEvent('BSY_LOADED', EVENT_ADD_ON_LOADED, BSY.OnAddOnLoaded)


--ANTIQUITY_MANAGER = ZO_AntiquityManager:New()

-- antiquityCategoryData


-- antiquityData:
-- -- name -> Antique Map of Bangkorai
-- -- antiquityCategoryData -> Table (see below)
-- -- needsCombination -> boolean
-- -- IsInProgress -> function
-- -- isRepeatable -> boolean
-- -- requiresLead -> boolean
-- -- hasLead -> boolean
-- -- numGoalsAchieved -> int
-- -- difficulty -> int
-- -- quality => int
-- -- zoneId -> int
-- -- leadExpirationTimeS -> float (9333.6723423) -- this would be awesome for sorting
-- -- numRecovered -> int
-- -- antiquityId -> int
-- -- numDigSites -> int


--[[ original code
function ZO_Antiquity:MeetsAllScryingRequirements()
    local scryingResult = MeetsAntiquityRequirementsForScrying(self:GetId(), ZO_ExplorationUtils_GetPlayerCurrentZoneId())
    return scryingResult == ANTIQUITY_SCRYING_RESULT_SUCCESS
end
--]]

--[[

I inherited this block commented out, didn't look into it yet. - @Latetide

sorting not available 

-- Sort by Discovered, Quality (ascending) and Antiquity Name (ascending).
function BSYSortFunction(leftAntiquityData, rightAntiquityData)
    trace ("BSYSortFunction")

    if leftAntiquityData:HasDiscovered() ~= rightAntiquityData:HasDiscovered() then
        return leftAntiquityData:HasDiscovered()
    elseif leftAntiquityData:GetQuality() < rightAntiquityData:GetQuality() then
        return true
    elseif leftAntiquityData:GetQuality() == rightAntiquityData:GetQuality() then
        return ZO_Antiquity.CompareNameTo(leftAntiquityData, rightAntiquityData)
    end

    return false
end

--]]

--[[
-- A 'generic' function to add a new key to a table, or increase the count in the value if it already exists
-- used for collecting the available types from the antiquities
function addOrIncrease(types, ant_type) 
    if types[ant_type] == nil then
        types[ant_type] = 0
    end

    types[ant_type] = types[ant_type] + 1

    return types
end
--]]

-- here is some code I used for debugging
-- add it to the inner loop of ApplyFilter, and switch "false" to "true" for the one you want to run
--[[ 
        -- to list the antiquity data structure
        if false and antiquityData.antiquityId == 145  then 
            local ids = {}
            ids[1] = antiquityData.antiquityId
            local tableKeys = printTableKeys(ADM.GetAntiquityData(ADM, antiquityData.antiquityId))
            savedVars[antiquityData.antiquityId] = tableKeys

            d("-> " .. ADM:GetAntiquityData(antiquityData.antiquityId):GetRewardId())
        end

        -- this is the one that returns the type
        --local rewardContextualTypeString = REWARDS_MANAGER:GetRewardContextualTypeString(tileData:GetRewardId()) or GetString(SI_ANTIQUITY_TYPE_FALLBACK)
        --RM:GetInfoForReward(antiquityData.rewardId, 1) -- or "not found"
        if false and (antiquityData.antiquityId == 20 or antiquityData.antiquityId == 133 or antiquityData.antiquityId == 72)  then 
            local rewardContextualTypeString
            rewardContextualTypeString = RM:GetRewardContextualTypeString(antiquityData.rewardId) -- or "not found"
            d("<".. antiquityData.antiquityId .. "> -> " .. tostring(rewardContextualTypeString) .. " (" .. tostring(antiquityData.rewardId) .. ")")
        end

        -- collect all the types in the local types table - then dump it to debug
        if false then 
            local rewardContextualTypeString
            rewardContextualTypeString = RM:GetRewardContextualTypeString(antiquityData.rewardId) or "Unknown"
            types = addOrIncrease(types, rewardContextualTypeString)
            d("<".. antiquityData.antiquityId .. "> -> " .. tostring(rewardContextualTypeString) .. " (" .. tostring(antiquityData.rewardId) .. ")")
        end

        -- this one saves the dumped data, so you can see it all in a file
        local savedVars = ZO_SavedVars:NewAccountWide("BetaScry_Character", 1) -- add this line to the top of ApplyFilter if you want to save stuff

        if false and antiquityData.antiquityId == 145 then
            local tableKeys = printTableKeys(AM.GetScryingToolCollectibleData())
            savedVars[antiquityData.antiquityId] = tableKeys            
            d(AM.GetScryingToolCollectibleData())
        end

        -- this is how to see what is in a zone
        if false and antiquityData.antiquityCategoryData.name == "Stormhaven" then
            d(antiquityData.name)
            d(antiquityData.antiquityId)

        end
-- ]]

