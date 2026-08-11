-- -----------------------------------------------------------------------------
-- HUDGridSnap — inject settings into the ZOS HUD Editor info box popup
-- Observed host: ZO_HUDEditor_Keyboard_TLInfoBox (hudeditor_keyboard.xml)
-- -----------------------------------------------------------------------------

local MIN_GRID_SIZE = 2
local MAX_GRID_SIZE = 100

local infoBoxSection

local function ClampGridSize(value)
    value = zo_floor(tonumber(value) or HUDGridSnap.SV.gridSize)
    if value < MIN_GRID_SIZE then
        return MIN_GRID_SIZE
    end
    if value > MAX_GRID_SIZE then
        return MAX_GRID_SIZE
    end
    return value
end

local function GetInfoBox()
    return HUD_EDITOR_KEYBOARD.control:GetNamedChild("InfoBox")
end

local function ApplyGridSizeFromEdit()
    local row = infoBoxSection:GetNamedChild("GridSizeRow")
    local editBox = row:GetNamedChild("Backdrop"):GetNamedChild("Edit")
    local size = ClampGridSize(editBox:GetText())
    HUDGridSnap.SV.gridSize = size
    editBox:SetText(tostring(size))
    HUDGridSnap.RefreshGridOverlay()
end

local function RefreshInfoBoxControlState()
    local sv = HUDGridSnap.SV
    local snapCheck = infoBoxSection:GetNamedChild("SnapCheck")
    local showGridCheck = infoBoxSection:GetNamedChild("ShowGridCheck")
    local editBox = infoBoxSection:GetNamedChild("GridSizeRow"):GetNamedChild("Backdrop"):GetNamedChild("Edit")

    ZO_CheckButton_SetCheckState(snapCheck, sv.enabled)
    ZO_CheckButton_SetCheckState(showGridCheck, sv.showGrid)
    editBox:SetText(tostring(sv.gridSize))
end

local function CreateInfoBoxSection()
    local infoBox = GetInfoBox()
    local coordinates = infoBox:GetNamedChild("Coordinates")
    local customOptions = infoBox:GetNamedChild("CustomOptions")

    infoBoxSection = CreateControlFromVirtual(infoBox:GetName() .. "HUDGridSnapSection", infoBox, "HUDGridSnap_InfoBoxSection")
    infoBoxSection:ClearAnchors()
    infoBoxSection:SetAnchor(TOPLEFT, coordinates, BOTTOMLEFT, 0, 10)
    infoBoxSection:SetAnchor(TOPRIGHT, coordinates, BOTTOMRIGHT, 0, 10)

    customOptions:ClearAnchors()
    customOptions:SetAnchor(TOPLEFT, infoBoxSection, BOTTOMLEFT, 0, 10)
    customOptions:SetAnchor(TOPRIGHT, infoBoxSection, BOTTOMRIGHT, 0, 10)

    local snapCheck = infoBoxSection:GetNamedChild("SnapCheck")
    local showGridCheck = infoBoxSection:GetNamedChild("ShowGridCheck")
    local editBox = infoBoxSection:GetNamedChild("GridSizeRow"):GetNamedChild("Backdrop"):GetNamedChild("Edit")

    ZO_CheckButton_SetLabelText(snapCheck, "Snap to Grid")
    ZO_CheckButton_SetToggleFunction(snapCheck, function (_, checked)
        HUDGridSnap.SV.enabled = checked
    end)

    ZO_CheckButton_SetLabelText(showGridCheck, "Show Grid")
    ZO_CheckButton_SetToggleFunction(showGridCheck, function (_, checked)
        HUDGridSnap.SV.showGrid = checked
        HUDGridSnap.RefreshGridOverlay()
    end)

    editBox:SetHandler("OnFocusLost", ApplyGridSizeFromEdit)
    editBox:SetHandler("OnEnter", function ()
        editBox:LoseFocus()
        ApplyGridSizeFromEdit()
    end)

    RefreshInfoBoxControlState()
end

local function UpdateInfoBoxSectionVisibility()
    local infoBox = GetInfoBox()
    infoBoxSection:SetHidden(infoBox:IsHidden())
    if not infoBox:IsHidden() then
        RefreshInfoBoxControlState()
    end
end

function HUDGridSnap.InstallInfoBoxControls()
    CreateInfoBoxSection()
    ZO_PostHook(ZO_HUDEditor_Keyboard, "RefreshInfoBox", UpdateInfoBoxSectionVisibility)
end