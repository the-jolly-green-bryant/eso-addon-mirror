-- -----------------------------------------------------------------------------
-- HUDitorTools — GridSnap inject settings into the ZOS HUD Editor info box popup
-- Observed host: ZO_HUDEditor_Keyboard_TLInfoBox (hudeditor_keyboard.xml)
-- -----------------------------------------------------------------------------
local HT = HUDitorTools

local MIN_GRID_SIZE = 2
local MAX_GRID_SIZE = 100

local infoBoxSection

local HE_KB = HUD_EDITOR_KEYBOARD

local function ClampGridSize(value)
    value = zo_floor(tonumber(value) or HT.SV.gridSize)
    if value < MIN_GRID_SIZE then
        return MIN_GRID_SIZE
    end
    if value > MAX_GRID_SIZE then
        return MAX_GRID_SIZE
    end
    return value
end

local function GetInfoBox()
    return HE_KB.control:GetNamedChild("InfoBox")
end
HT.GetInfoBox = GetInfoBox

local function ApplyGridSizeFromEdit()
    local row = infoBoxSection:GetNamedChild("GridSizeRow")
    local editBox = row:GetNamedChild("Backdrop"):GetNamedChild("Edit")
    local size = ClampGridSize(editBox:GetText())
    HT.SV.gridSize = size
    editBox:SetText(tostring(size))
    HT.RefreshGridOverlay()
end

local function RefreshInfoBoxControlState()
    local sv = HT.SV
    local snapCheck = infoBoxSection:GetNamedChild("SnapCheck")
    local showGridCheck = infoBoxSection:GetNamedChild("ShowGridCheck")
    local editBox = infoBoxSection:GetNamedChild("GridSizeRow"):GetNamedChild("Backdrop"):GetNamedChild("Edit")

    ZO_CheckButton_SetCheckState(snapCheck, sv.gridSnap)
    ZO_CheckButton_SetCheckState(showGridCheck, sv.showGrid)
    editBox:SetText(tostring(sv.gridSize))
end

local function UpdateInfoBoxSectionAnchors(isContextMenuSettingsButtonActive)
    if not infoBoxSection then return end
    local infoBox = GetInfoBox()
    local coordinates = infoBox:GetNamedChild("Coordinates")
    local customOptions = infoBox:GetNamedChild("CustomOptions")

    infoBoxSection:ClearAnchors()
    if not isContextMenuSettingsButtonActive then
        infoBoxSection:SetAnchor(TOPLEFT, coordinates, BOTTOMLEFT, 0, 10)
        infoBoxSection:SetAnchor(TOPRIGHT, coordinates, BOTTOMRIGHT, 0, 10)
        customOptions:ClearAnchors()
        customOptions:SetAnchor(TOPLEFT, infoBoxSection, BOTTOMLEFT, 0, 10)
        customOptions:SetAnchor(TOPRIGHT, infoBoxSection, BOTTOMRIGHT, 0, 10)
    else
        infoBoxSection:SetHeight(0)
        customOptions:ClearAnchors()
        customOptions:SetAnchor(TOPLEFT, coordinates, BOTTOMLEFT, 0, 10)
        customOptions:SetAnchor(TOPRIGHT, coordinates, BOTTOMRIGHT, 0, 10)
    end
    infoBoxSection:SetMouseEnabled(not isContextMenuSettingsButtonActive)
end

local function CreateInfoBoxSection()
    local infoBox = GetInfoBox()
    local coordinates = infoBox:GetNamedChild("Coordinates")
    local customOptions = infoBox:GetNamedChild("CustomOptions")

    infoBoxSection = CreateControlFromVirtual(infoBox:GetName() .. "HUDitorToolsSection", infoBox, "HUDitorTools_InfoBoxSection")
    UpdateInfoBoxSectionAnchors(HT.SV.HUDEditorShowInfoBoxSettingsButton)


    local snapCheck = infoBoxSection:GetNamedChild("SnapCheck")
    local showGridCheck = infoBoxSection:GetNamedChild("ShowGridCheck")
    local editBox = infoBoxSection:GetNamedChild("GridSizeRow"):GetNamedChild("Backdrop"):GetNamedChild("Edit")

    ZO_CheckButton_SetLabelText(snapCheck, "Snap to Grid")
    ZO_CheckButton_SetToggleFunction(snapCheck, function (_, checked)
        HT.SV.gridSnap = checked
    end)

    ZO_CheckButton_SetLabelText(showGridCheck, "Show Grid")
    ZO_CheckButton_SetToggleFunction(showGridCheck, function (_, checked)
        HT.SV.showGrid = checked
        HT.RefreshGridOverlay()
    end)

    editBox:SetHandler("OnFocusLost", ApplyGridSizeFromEdit)
    editBox:SetHandler("OnEnter", function ()
        editBox:LoseFocus()
        ApplyGridSizeFromEdit()
    end)

    RefreshInfoBoxControlState()
end

function HT.UpdateInfoBoxSectionVisibility()
    local infoBox = GetInfoBox()
    local HUDEditorShowInfoBoxSettingsButton = HT.SV.HUDEditorShowInfoBoxSettingsButton

    infoBoxSection:SetHidden(HUDEditorShowInfoBoxSettingsButton or infoBox:IsHidden())
    if not HUDEditorShowInfoBoxSettingsButton and not infoBox:IsHidden() then
        RefreshInfoBoxControlState()
    end
    UpdateInfoBoxSectionAnchors(HUDEditorShowInfoBoxSettingsButton)
end

function HT.InstallInfoBoxControls()
    CreateInfoBoxSection()
end