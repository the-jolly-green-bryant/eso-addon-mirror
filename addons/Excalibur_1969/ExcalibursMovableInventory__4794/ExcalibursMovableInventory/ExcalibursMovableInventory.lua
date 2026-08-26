-- Excalibur's Movable Inventory v1.1: reposition + drag the vanilla inventory window (scale-aware).
local EMI = {}
ExcalibursMovableInventory = EMI

EMI.name = "ExcalibursMovableInventory"
EMI.version = "1.1"

EMI.defaults = {
    movePanel     = true,
    offsetX       = 0,
    offsetY       = 0,
    showBackdrop  = false,
    showMenuBar   = false,
}

local sv
local vanillaApplied = false

local function GetTargets()
    return ZO_PlayerInventory, ZO_SharedRightPanelBackground
end

local function Scale()
    local ok, s = pcall(function() return GuiRoot:GetScale() end)
    return (ok and s and s > 0) and s or 1
end

function EMI.ApplyPosition()
    local inv, bg = GetTargets()
    if not inv or not bg then return end

    if not sv.movePanel then
        if vanillaApplied then return end
        EMI.RestoreVanilla()
        vanillaApplied = true
        return
    end
    vanillaApplied = false

    bg:ClearAnchors()
    if sv.showBackdrop then
        bg:SetHidden(false); bg:SetAlpha(1); bg:SetMouseEnabled(true)
        bg:SetAnchor(CENTER, GuiRoot, CENTER, sv.offsetX, sv.offsetY)
    else
        bg:SetAlpha(0); bg:SetMouseEnabled(false)
        bg:SetAnchor(CENTER, GuiRoot, CENTER, sv.offsetX, sv.offsetY)
    end

    -- Inventory: anchor to screen-center, offset by half the panel size.
    inv:ClearAnchors()
    local panelW, panelH = 565, 750
    inv:SetAnchor(TOPLEFT, GuiRoot, CENTER, sv.offsetX - panelW / 2 + 5, sv.offsetY - panelH / 2 + 20)
    inv:SetAnchor(BOTTOMRIGHT, GuiRoot, CENTER, sv.offsetX + panelW / 2 + 5, sv.offsetY + panelH / 2 - 30)
end

function EMI.RestoreVanilla()
    local inv, bg = GetTargets()
    if not inv or not bg then return end
    bg:ClearAnchors(); bg:SetAnchor(RIGHT, GuiRoot, RIGHT, 0, 20)
    bg:SetHidden(false); bg:SetAlpha(1); bg:SetMouseEnabled(true)
    inv:ClearAnchors()
    inv:SetAnchor(TOPLEFT, bg, TOPLEFT, 0, -20)
    inv:SetAnchor(BOTTOMLEFT, bg, BOTTOMLEFT, 0, -30)
end

-----------------------------------------------------------------
-- Dragging
-----------------------------------------------------------------
local dragHandle
local function CreateDragHandle()
    local invCtl = ZO_PlayerInventory
    dragHandle = WINDOW_MANAGER:CreateControl("ExcalibursMovableInventoryDragHandle", GuiRoot, CT_CONTROL)
    dragHandle:SetAnchor(TOPLEFT, invCtl, TOPLEFT, -5, -40)
    dragHandle:SetDimensions(560, 40)
    dragHandle:SetMouseEnabled(true)
    dragHandle:SetDrawLayer(DL_OVERLAY)

    local startX, startY, startOffX, startOffY
    local isDragging = false
    dragHandle:SetHandler("OnMouseDown", function(ctrl, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            startOffX, startOffY = sv.offsetX, sv.offsetY
            startX, startY = GetUIMousePosition()
            isDragging = true
        end
    end)
    dragHandle:SetHandler("OnMouseUp", function(ctrl, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then isDragging = false end
    end)
    dragHandle:SetHandler("OnMouseMove", function()
        if not isDragging then return end
        local x, y = GetUIMousePosition()
        local s = Scale()
        sv.offsetX = zo_clamp(startOffX + (x - startX) / s, -GuiRoot:GetWidth()/2, GuiRoot:GetWidth()/2)
        sv.offsetY = zo_clamp(startOffY + (y - startY) / s, -GuiRoot:GetHeight()/2, GuiRoot:GetHeight()/2)
        EMI.ApplyPosition()
    end)
end

-----------------------------------------------------------------
-- Hide the inventory's keybind strip + floating tab-icon row.
-----------------------------------------------------------------
local function HidePanelChrome()
    if not sv or not sv.movePanel then return end -- never touch UI when disabled
    if KEYBIND_STRIP then KEYBIND_STRIP:SetHidden(true) end
    local menu = ZO_PlayerInventoryMenu
    if menu then
        if sv.showMenuBar then
            menu:SetAlpha(1); menu:SetMouseEnabled(true)
        else
            menu:SetAlpha(0); menu:SetMouseEnabled(false)
        end
    end
end

function EMI.SuppressKeybindStrip()
    local invFragment = INVENTORY_FRAGMENT
    if invFragment then
        invFragment:RegisterCallback("StateChange", function(_, newState)
            if not sv or not sv.movePanel then return end -- never touch UI when disabled
            if newState == SCENE_FRAGMENT_SHOWING then
                zo_callLater(function()
                    if sv and sv.movePanel and KEYBIND_STRIP then
                        KEYBIND_STRIP:SetHidden(true)
                    end
                end, 100)
                if KEYBIND_STRIP then KEYBIND_STRIP:SetHidden(true) end
            elseif newState == SCENE_FRAGMENT_HIDDEN then
                -- restore the keybind strip so other scenes are unaffected
                if KEYBIND_STRIP then KEYBIND_STRIP:SetHidden(false) end
            end
        end)
    end
end

-----------------------------------------------------------------
-- Polling updater: only runs while movePanel is ENABLED.
-- Registered lazily and unregistered when the setting turns off,
-- so it never drains performance for nothing (ESOUI best practice).
-----------------------------------------------------------------
local UPDATER_NAME = EMI.name .. "_Keys"
local function OnUpdateTick()
    local inv = ZO_PlayerInventory
    if inv and not inv:IsHidden() then
        local _, bg = GetTargets()
        if bg and not sv.showBackdrop then bg:SetAlpha(0) end
        EMI.ApplyPosition()
        HidePanelChrome()
        if dragHandle then
            dragHandle:ClearAnchors()
            dragHandle:SetAnchor(TOPLEFT, inv, TOPLEFT, -5, -40)
            dragHandle:SetHidden(false)
        end
    elseif dragHandle then
        dragHandle:SetHidden(true)
    end
end

function EMI.SetMovePanel(enabled)
    sv.movePanel = enabled
    if enabled then
        EVENT_MANAGER:RegisterForUpdate(UPDATER_NAME, 200, OnUpdateTick)
    else
        EVENT_MANAGER:UnregisterForUpdate(UPDATER_NAME)
        EMI.RestoreVanilla()
        HidePanelChrome()
        if dragHandle then dragHandle:SetHidden(true) end
    end
end

function EMI.SyncUpdater()
    -- Called once at load: start the updater only if the setting is on.
    if sv.movePanel then
        EVENT_MANAGER:RegisterForUpdate(UPDATER_NAME, 200, OnUpdateTick)
    end
end

-----------------------------------------------------------------
local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= EMI.name then return end
    EVENT_MANAGER:UnregisterForEvent(EMI.name, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("ExcalibursMovableInventory_SavedVars", 1, nil, EMI.defaults)
    EMI.sv = sv

    EMI.ApplyPosition()

    local bgFragment = RIGHT_PANEL_BG_FRAGMENT
    if bgFragment then
        bgFragment:RegisterCallback("StateChange", function(_, newState)
            if not sv or not sv.movePanel then return end
            if not sv.showBackdrop and newState == SCENE_FRAGMENT_SHOWING then
                local _, bg = GetTargets()
                if bg then bg:SetAlpha(0) end
            end
        end)
    end

    CreateDragHandle()
    EMI.SuppressKeybindStrip()
    EMI.InitializeSettings()
    EMI.SyncUpdater() -- start polling only if movePanel is enabled
end

EVENT_MANAGER:RegisterForEvent(EMI.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
