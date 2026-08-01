-- AntiquitiesTracker.lua
-- Addon principal para gestionar pistas de antigüedades en ESO

AntiquitiesTracker = {}
AntiquitiesTracker.name = "AntiquitiesTracker"
AntiquitiesTracker.version = "1.0"
AntiquitiesTracker.savedVariables = {}
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER

-- Configuración por defecto
local defaults = {
    alertDays = 5,
    enableAlerts = true,
}

function AntiquitiesTracker.OnAddOnLoaded(event, addonName)
    if addonName ~= AntiquitiesTracker.name then return end

    AntiquitiesTracker.savedVariables = ZO_SavedVars:NewAccountWide("AntiquitiesTrackerSavedVars", 1, nil, defaults)
    AntiquitiesTracker:InitializeUI()
    AntiquitiesTracker:InitializeEvents()
end

function AntiquitiesTracker:InitializeEvents()
    EM:RegisterForEvent(self.name, EVENT_ANTIQUITY_LEAD_ACQUIRED, function(_, antiquityId)
        self:CheckExpiration(antiquityId)
        self:RefreshUI()
    end)
    EM:RegisterForEvent(self.name, EVENT_ANTIQUITY_UPDATED, function(_, antiquityId)
        self:RefreshUI()
    end)
end

function AntiquitiesTracker:CheckExpiration(antiquityId)
    local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(antiquityId)
    if not antiquityData or antiquityData:HasRecovered() then return end

    local remainingSecs = antiquityData:GetTimeLeftSeconds()
    if not remainingSecs then return end

    local remainingDays = math.floor(remainingSecs / 86400)
    if remainingDays <= self.savedVariables.alertDays and self.savedVariables.enableAlerts then
        local name = antiquityData:GetName()
        CHAT_SYSTEM:AddMessage("[AntiquitiesTracker] La pista '" .. name .. "' expira en " .. remainingDays .. " días.")
    end
end

function AntiquitiesTracker:InitializeUI()
    AntiquitiesTrackerUI_Init()
end

function AntiquitiesTracker:RefreshUI()
    if AntiquitiesTrackerUI and AntiquitiesTrackerUI.Refresh then
        AntiquitiesTrackerUI:Refresh()
    end
end

-- UI --
AntiquitiesTrackerUI = {}

function AntiquitiesTrackerUI_Init()
    AntiquitiesTrackerUI.control = WINDOW_MANAGER:CreateTopLevelWindow("AntiquitiesTrackerUI")
    local ui = AntiquitiesTrackerUI.control
    ui:SetDimensions(800, 500)
    ui:SetMovable(true)
    ui:SetMouseEnabled(true)
    ui:SetHidden(false)
    ui:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

    local bg = WINDOW_MANAGER:CreateControl(nil, ui, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.7)
    bg:SetEdgeColor(1, 1, 1, 0.6)

    -- Filtros desplegables
    AntiquitiesTrackerUI.zoneFilter = ZO_ComboBox:New(WINDOW_MANAGER:CreateControlFromVirtual("$ParentZoneFilter", ui, "ZO_ComboBox"))
    AntiquitiesTrackerUI.zoneFilter.control:SetAnchor(TOPLEFT, ui, TOPLEFT, 20, 20)

    AntiquitiesTrackerUI.difficultyFilter = ZO_ComboBox:New(WINDOW_MANAGER:CreateControlFromVirtual("$ParentDiffFilter", ui, "ZO_ComboBox"))
    AntiquitiesTrackerUI.difficultyFilter.control:SetAnchor(LEFT, AntiquitiesTrackerUI.zoneFilter.control, RIGHT, 20, 0)

    AntiquitiesTrackerUI.typeFilter = ZO_ComboBox:New(WINDOW_MANAGER:CreateControlFromVirtual("$ParentTypeFilter", ui, "ZO_ComboBox"))
    AntiquitiesTrackerUI.typeFilter.control:SetAnchor(LEFT, AntiquitiesTrackerUI.difficultyFilter.control, RIGHT, 20, 0)

    -- Lista scroll
    AntiquitiesTrackerUI.scrollList = WINDOW_MANAGER:CreateControlFromVirtual("$ParentList", ui, "ZO_ScrollList")
    AntiquitiesTrackerUI.scrollList:SetAnchor(TOPLEFT, ui, TOPLEFT, 20, 60)
    AntiquitiesTrackerUI.scrollList:SetDimensions(760, 400)

    ZO_ScrollList_AddDataType(AntiquitiesTrackerUI.scrollList, 1, "AntiquityRowTemplate", 30, function(control, data)
        control:GetNamedChild("Name"):SetText(data.name)
    end)
    ZO_ScrollList_SetTypeSelectable(AntiquitiesTrackerUI.scrollList, 1, true)

    AntiquitiesTrackerUI:Refresh()
end

function AntiquitiesTrackerUI:Refresh()
    local scrollData = ZO_ScrollList_GetDataList(self.scrollList)
    ZO_ClearNumericallyIndexedTable(scrollData)

    for _, zoneData in pairs(ANTIQUITY_DATA_MANAGER:GetZoneAntiquityData()) do
        for _, antiquityData in ipairs(zoneData.antiquities) do
            local name = antiquityData:GetName()
            local entry = ZO_ScrollList_CreateDataEntry(1, { name = name })
            table.insert(scrollData, entry)
        end
    end

    ZO_ScrollList_Commit(self.scrollList)
end