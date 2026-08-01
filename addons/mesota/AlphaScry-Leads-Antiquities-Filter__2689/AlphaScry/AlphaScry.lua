ASY = {}

ASY.name = 'AlphaScry'
ASY.displayname = 'AlphaScry'
ASY.version = 'v1.0.0'
ASY.author = 'mesota'
ASY.init = false
ASY.accountVariableVersion = 1
ASY.characterVariableVersion = 1
ASY.isDebug = false
ASY.useCustomFilter = false

ASY.ZO_SortFunction = nil

ASY.scryFilter = {
    showRequiresLead = true,
    showInProgress = true,
    minimumQuality = 1
}


-- ESO globals
local EM, WM, SM = EVENT_MANAGER, WINDOW_MANAGER, SCENE_MANAGER
local AM = ANTIQUITY_MANAGER
local ADM = ANTIQUITY_DATA_MANAGER 
local AJK = ANTIQUITY_JOURNAL_KEYBOARD

--- Writes trace messages to the console
-- fmt with %d, %s,
local function trace(fmt, ...)
	if ASY.isDebug then
		d(string.format(fmt, ...))
    end
end


function ASY.ToggleDebug(extra)
    ASY.isDebug = not ASY.isDebug
    if ASY.isDebug then
        d("AlphaScry: debug messages ON")
    else
        d("AlphaScry: debug messages OFF")
    end
end



--------------------------------------------------------
-- Liefert bool, ob eine Antiquität erspäht werden kann.
function ASY.IsScryable(antiquityData)
    return not antiquityData:HasAchievedAllGoals() and antiquityData:MeetsLeadRequirements() and antiquityData:MeetsScryingSkillRequirements() -- and antiquityData:MeetsAllScryingRequirements()
end

-------------------------------------------------------
-- Liefert den Namen einer Quality
function ASY.GetQualityString(Quality)
    local QUALITY = {
        [0]={"weiss"},
        [1]={"grün"},
        [2]={"blau"},
        [3]={"lila"},
        [4]={"gold"},
        [5]={"orange"},
        [6]={"rot"}
    }
    return unpack(QUALITY[Quality])
end

-----------------------------------------------------
-- Listet alle Spuren auf, die erspähbar sind.
function ASY.ListHints()
    for antiquityId, antiquityData in pairs (ADM.antiquities) do
--        trace ("A: %s", ADM.antiquities [i].name)
        if antiquityData:HasDiscovered () then
            if ASY.IsScryable(antiquityData) then
                local zoneName = GetZoneNameById(antiquityData.zoneId)
                trace ("Id: %d - ZoneName: %s - Name: %s - Diff: %s", antiquityId, zoneName, antiquityData.name, ASY.GetQualityString (antiquityData:GetQuality()))
               -- trace ("IsScryable: %s", tostring(ASY.IsScryable(antiquityData)))
            end
            -- 
        end
                -- https://github.com/esoui/esoui/blob/master/esoui/ingame/antiquities/antiquitydata.lua
    end
end

--[[ original code
function ZO_Antiquity:MeetsAllScryingRequirements()
    local scryingResult = MeetsAntiquityRequirementsForScrying(self:GetId(), ZO_ExplorationUtils_GetPlayerCurrentZoneId())
    return scryingResult == ANTIQUITY_SCRYING_RESULT_SUCCESS
end
--]]

--[[

sorting not available 

-- Sort by Discovered, Quality (ascending) and Antiquity Name (ascending).
function ASYSortFunction(leftAntiquityData, rightAntiquityData)
    trace ("ASYSortFunction")

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


-- based on
-- https://github.com/esoui/esoui/blob/master/esoui/ingame/antiquities/antiquitydata.lua


function ASY.FilterCore(antiquityData)
    local scryFilter = ASY.scryFilter

    -- Requires lead filter
    if not scryFilter.showRequiresLead and antiquityData:RequiresLead() then return false end

    -- Quality filter
    if scryFilter.minimumQuality > antiquityData:GetQuality() then return false end

    return not antiquityData:HasAchievedAllGoals() and antiquityData:MeetsScryingSkillRequirements() -- and antiquityData:MeetsLeadRequirements()
end


--- this funktion hijacks IsInCurrentPlayerZone and adds additional filters
function ASY:CustomIsInCurrentPlayerZone()
    -- original condition
    if not self:IsInZone(ZO_ExplorationUtils_GetPlayerCurrentZoneId()) then return false end

    local scryFilter = ASY.scryFilter

    -- Requires lead filter
    if not scryFilter.showRequiresLead and self:RequiresLead() then return false end

    -- Quality filter
    if scryFilter.minimumQuality > self:GetQuality() then return false end

    -- In Progress Filter
    if not scryFilter.showInProgress and (self:GetNumGoalsAchieved() > 0) then return false end

    return true
end

--- this funktion hijacks MeetsLeadRequirements and adds additional filters
function ASY:CustomMeetsLeadRequirements()
    -- original condition
    if (not self:RequiresLead() or self:HasLead()) == false then return false end

    local scryFilter = ASY.scryFilter

    -- Requires lead filter
    if not scryFilter.showRequiresLead and self:RequiresLead() then return false end

    -- Quality filter
    if scryFilter.minimumQuality > self:GetQuality() then return false end

    return true
end

--- this funktion hijacks IsInProgress and adds additional filters
function ASY:CustomIsInProgress() 
    local scryFilter = ASY.scryFilter

    -- Requires lead filter
    if not scryFilter.showRequiresLead and self:RequiresLead() then return false end

    -- Quality filter
    if scryFilter.minimumQuality > self:GetQuality() then return false end

    -- In Progress Filter
    return scryFilter.showInProgress and (self:GetNumGoalsAchieved() > 0)
end


function ASY.ApplyFilter()
    trace ("ASY.ApplyFilter")
        
    ASY.useCustomFilter = true
    local filterfuncMR = ASY.CustomMeetsLeadRequirements
    local filterfuncPZ = ASY.CustomIsInCurrentPlayerZone
    local filterfuncIP = ASY.CustomIsInProgress
    ASY.ToggleButton:SetState(BSTATE_PRESSED)

    for _, antiquityData in pairs (ADM.antiquities) do
        -- current zone
        antiquityData.IsInCurrentPlayerZone = filterfuncPZ

        -- all zones
        antiquityData.MeetsLeadRequirements = filterfuncMR
        antiquityData.IsInProgress = filterfuncIP
    end

    ADM:RefreshAll()
end

function ASY.ClearFilter()
    trace ("ASY.ClearFilter")

    ASY.useCustomFilter = false
    local filterfuncPZ = ZO_Antiquity.IsInCurrentPlayerZone
    local filterfuncMR = ZO_Antiquity.MeetsLeadRequirements
    local filterfuncIP = ZO_Antiquity.IsInProgress
    ASY.ToggleButton:SetState(BSTATE_NORMAL)
    
    for _, antiquityData in pairs (ADM.antiquities) do
        -- current zone
        antiquityData.IsInCurrentPlayerZone = filterfuncPZ

        -- all zones
        antiquityData.MeetsLeadRequirements = filterfuncMR
        antiquityData.IsInProgress = filterfuncIP
    end 

    ADM:RefreshAll()
end


function ASY.ShowChangeFilterDialog() 
    trace ("ASY.ShowChangeFilterDialog")
    ZO_Dialogs_ShowDialog("ASY_CHANGE_FILTER_DIALOG", {})
end

function ASY.ToggleShowAll()
    trace ("ASY.ToggleFilter")
    ASY.useCustomFilter = not ASY.useCustomFilter

    if ASY.useCustomFilter then
        ASY.ApplyFilter()
    else
        ASY.ClearFilter()
    end
end

function ASY.InitButton()
    -- create button
    local cParent = WM:GetControlByName("ZO_AntiquityJournal_Keyboard_TopLevelContents")
    local cSearch = cParent:GetNamedChild("Search")

    -- toggle button
    local cTB = WM:CreateControl('ASY_ToggleButton', cParent, CT_BUTTON)
    cTB:SetAnchor(BOTTOMRIGHT, cSearch, TOPRIGHT, 0, 0)
    cTB:SetDimensions(25, 25)
    cTB:SetNormalTexture('esoui/art/inventory/inventory_tabicon_all_up.dds')
    cTB:SetPressedTexture('esoui/art/inventory/inventory_tabicon_all_down.dds')
    cTB:SetMouseOverTexture('esoui/art/inventory/inventory_tabicon_all_over.dds')
    cTB:SetHandler('OnClicked',function() ASY.ToggleShowAll() end)
    ASY.ToggleButton = cTB

    -- change filter button
    local cCF = WM:CreateControl('ASY_ChangeFilterButton', cParent, CT_BUTTON)
    cCF:SetAnchor(RIGHT, cTB, LEFT, -5, 0)
    cCF:SetDimensions(25, 25)
    cCF:SetNormalTexture('esoui/art/chatwindow/chat_options_up.dds')
    cCF:SetPressedTexture('esoui/art/chatwindow/chat_options_down.dds')
    cCF:SetMouseOverTexture('esoui/art/chatwindow/chat_options_over.dds')
    cCF:SetHandler('OnClicked',function() ASY.ShowChangeFilterDialog() end)
end


function ASY:NewFunc()
    d("In NewFunc")
    self:OldFunc()
end

function ASY:Initialize()

    local function OnAntiquityLeadAcquired(event, antiquityId)
        local antiquityData = ADM:GetAntiquityData(antiquityId)

        local colorDef = GetAntiquityQualityColor(antiquityData:GetQuality())
        local name = colorDef:Colorize(antiquityData:GetName())

        d("|cFFAA33AlphaScry - new lead:|r "..name)
    end
    

	SLASH_COMMANDS["/asydbg"] = ASY.ToggleDebug

    AJK.OldFunc = AJK.AcquireAntiquitySectionList
    AJK.AcquireAntiquitySectionList = ASY.NewFunc

    
    EM:RegisterForEvent("AlphaScry", EVENT_ANTIQUITY_LEAD_ACQUIRED, OnAntiquityLeadAcquired)

    -- Create Key Binding Labels
    -- ZO_CreateStringId('SI_BINDING_NAME_ALPHASCRY_LIST_HINTS', "Show Hints")	

    -- save sort function
    ASY.ZO_SortFunction = ZO_DefaultAntiquitySortComparison

    -- initialize toggle button
	zo_callLater(ASY.InitButton, 900)

    ASY.init = true
end

function ASY.OnAddOnLoaded(event, addonName)
  if addonName ~= ASY.name then return end

  EM:UnregisterForEvent('ASY_LOADED',EVENT_ADD_ON_LOADED)
  
  ASY:Initialize()
end


EM:RegisterForEvent('ASY_LOADED', EVENT_ADD_ON_LOADED, ASY.OnAddOnLoaded)

