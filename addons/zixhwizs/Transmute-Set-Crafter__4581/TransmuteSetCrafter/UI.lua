-- Transmute Set Crafter — Window orchestrator + divider drag
--
-- Owns the top-level main-window lifecycle: SetupUI delegates to the four
-- sibling UI modules and seeds saved-vars-driven positions. Also hosts the
-- vertical splitter, side-panel toggles, the Transmute button state, and
-- the EVENT_ITEM_SET_COLLECTIONS_UPDATED watcher.
--
-- Sibling modules:
--   UI_Lists.lua    — set + piece list, row setup, search, navigation
--   UI_QueueRow.lua — queue row, column layout, add/edit/cancel flow
--   UI_Dropdowns.lua — Trait / Quality / Enchant pickers
--   UI_Cost.lua     — Materials window + cost label

local TSC = TransmuteSetCrafter
local ADDON_NAME = TSC.name

-- ── Vertical divider drag ─────────────────────────────────
-- Splitter between the set/inventory list and the queue list. The XML anchors
-- both panels relative to TransmuteSetCrafterWindowVDivider so simply moving
-- the divider re-flows everything that depends on it.

local MIN_LEFT_PANEL  = 220
local MIN_RIGHT_PANEL = 420
local dividerDragging       = false
local dividerDragStartMouse = 0
local dividerDragStartX     = 0

function TSC.SetDividerX(x)
    local win     = TransmuteSetCrafterWindow
    local divider = TransmuteSetCrafterWindowVDivider
    if not win or not divider then return end
    local winW = win:GetWidth()
    if winW > 0 then
        local maxX = winW - MIN_RIGHT_PANEL
        if maxX < MIN_LEFT_PANEL then maxX = MIN_LEFT_PANEL end
        if x < MIN_LEFT_PANEL then x = MIN_LEFT_PANEL end
        if x > maxX            then x = maxX end
    end
    divider:ClearAnchors()
    divider:SetAnchor(TOPLEFT,    win, TOPLEFT,    x, 0)
    divider:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, x, 0)
    -- Cheap reflow: re-run the queue rows' SetupQueueRow (which recomputes
    -- per-column widths from the list's new width) and the column headers.
    -- Avoid the full Refresh*List rebuilds that walk the entire piece
    -- collection — drag fires this every frame.
    TSC.UpdateQueueColumnHeaders()
    local qList = TransmuteSetCrafterWindowQueueList
    if qList then ZO_ScrollList_RefreshVisible(qList) end
end

local function SetDividerHighlight(ctrl, highlighted)
    if not ctrl then return end
    local strip = ctrl:GetNamedChild("Strip")
    if not strip then return end
    if highlighted then
        strip:SetCenterColor(TSC.Color.TEAL:UnpackRGBA())
    else
        strip:SetCenterColor(0.41, 0.41, 0.41, 1)  -- 0x696969 idle
    end
end

function TSC.OnVDividerMouseEnter(ctrl)
    WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_EW)
    SetDividerHighlight(ctrl, true)
end

function TSC.OnVDividerMouseExit(ctrl)
    if not dividerDragging then
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
        SetDividerHighlight(ctrl, false)
    end
end

local function OnDividerDragEnd(_, button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
    if not dividerDragging then return end
    dividerDragging = false
    local divider = TransmuteSetCrafterWindowVDivider
    if divider then divider:SetHandler("OnUpdate", nil) end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_DivDragEnd", EVENT_GLOBAL_MOUSE_UP)
    WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
    local win = TransmuteSetCrafterWindow
    if win and divider and TSC.savedVars then
        TSC.savedVars.dividerX = divider:GetLeft() - win:GetLeft()
        SetDividerHighlight(divider, MouseIsOver(divider))
    end
end

function TSC.OnVDividerMouseDown(ctrl, button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then return end
    local win = TransmuteSetCrafterWindow
    if not win then return end
    dividerDragging       = true
    dividerDragStartMouse = GetUIMousePosition()
    dividerDragStartX     = ctrl:GetLeft() - win:GetLeft()
    ctrl:SetHandler("OnUpdate", function()
        if not dividerDragging then return end
        local mouseX = GetUIMousePosition()
        TSC.SetDividerX(dividerDragStartX + (mouseX - dividerDragStartMouse))
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DivDragEnd", EVENT_GLOBAL_MOUSE_UP, OnDividerDragEnd)
end

-- ── Setup ──────────────────────────────────────────────────

function TSC.SetupUI()
    local win = TransmuteSetCrafterWindow

    -- Restore saved size then position (order matters: size before anchor)
    if TSC.savedVars.windowWidth and TSC.savedVars.windowHeight then
        win:SetDimensions(TSC.savedVars.windowWidth, TSC.savedVars.windowHeight)
    end
    if TSC.savedVars.xPos and TSC.savedVars.yPos then
        win:ClearAnchors()
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                      TSC.savedVars.xPos, TSC.savedVars.yPos)
    end

    -- Enable resize (bottom-right corner grip)
    win:SetResizeHandleSize(8)

    -- Cost window — restore saved size and position, enable resize.
    -- If no saved position, keep the XML default (docked to main window).
    local costWin = TransmuteSetCrafterCostWindow
    if costWin then
        if TSC.savedVars.costWindowWidth and TSC.savedVars.costWindowHeight then
            costWin:SetDimensions(TSC.savedVars.costWindowWidth, TSC.savedVars.costWindowHeight)
        end
        if TSC.savedVars.costXPos and TSC.savedVars.costYPos then
            costWin:ClearAnchors()
            costWin:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
                              TSC.savedVars.costXPos, TSC.savedVars.costYPos)
        end
        costWin:SetResizeHandleSize(8)
    end

    -- Quicksave window setup (deferred to its own module)
    if TSC.SetupQuicksavePanel then
        TSC.SetupQuicksavePanel()
    end

    TransmuteSetCrafterWindowTitle:SetText(GetString(SI_TSC_TITLE))
    TransmuteSetCrafterWindowQueueHeader:SetText(GetString(SI_TSC_QUEUE_HEADER))
    TransmuteSetCrafterWindowTraitLabel:SetText(GetString(SI_TSC_TARGET_TRAIT_LABEL))
    TransmuteSetCrafterWindowQualityLabel:SetText(GetString(SI_TSC_QUALITY_LABEL))

    TransmuteSetCrafterWindowToggleCost:SetText(GetString(SI_TSC_LABEL_MATERIALS))
    TransmuteSetCrafterWindowToggleQuicksaves:SetText(GetString(SI_TSC_LABEL_QUICKSAVES))

    TransmuteSetCrafterWindowClearQueueButton:SetText(GetString(SI_TSC_CLEAR_QUEUE))
    TransmuteSetCrafterWindowCancelEditButton:SetText(GetString(SI_TSC_LABEL_CANCEL_EDIT))
    TransmuteSetCrafterWindowQueueEquippedButton:SetText(GetString(SI_TSC_LABEL_QUEUE_EQUIPPED))

    local searchBox = TransmuteSetCrafterWindowSearchBox
    searchBox:SetText("")
    searchBox:SetDefaultText(GetString(SI_TSC_SEARCH_PLACEHOLDER))

    TSC.SetupInventoryList()  -- inventory ScrollList data types + highlight
    TSC.SetupQueueList()      -- queue ScrollList data type + headers
    TSC.SetupCostPanel()      -- cost ScrollList data type + headers
    TSC.SetupDropdowns()      -- bind ZO_ComboBox containers

    TransmuteSetCrafterWindowEnchantLabel:SetText(GetString(SI_TSC_ENCHANTMENT_LABEL))

    TSC.UpdateNavigationState()
    TSC.UpdateAddButton()
    TSC.UpdateTransmuteButton()
    TSC.UpdateCostDisplay()

    -- Apply divider position last — SetDividerX needs the ScrollList data
    -- types registered (they're set above) and it calls UpdateQueueColumnHeaders
    -- + ZO_ScrollList_RefreshVisible on the queue list internally.
    TSC.SetDividerX(TSC.savedVars.dividerX or 384)
end

-- ── Window open / close / toggle ───────────────────────────

function TSC.OpenWindow()
    if IsInGamepadPreferredMode() then
        TSC.Notify(TSC.NOTIFY_ERROR, GetString(SI_TSC_GAMEPAD_UNSUPPORTED))
        return
    end

    TSC._UI.browsingMode = "sets"
    TSC._UI.selectedSet  = nil
    TSC.ClearPieceSelection()

    TransmuteSetCrafterWindow:SetHidden(false)
    TransmuteSetCrafterCostWindow:SetHidden(TSC.savedVars.costWindowHidden or false)
    TransmuteSetCrafterQuicksaveWindow:SetHidden(TSC.savedVars.quicksaveWindowHidden or false)
    TSC.UpdateQueueColumnHeaders()
    TSC.RefreshInventoryList()
    TSC.RefreshQueueList()
    TSC.UpdateCostDisplay()
    if TSC.RefreshQuicksavePanel then TSC.RefreshQuicksavePanel() end
end

function TSC.CloseWindow()
    TransmuteSetCrafterWindow:SetHidden(true)
    TransmuteSetCrafterCostWindow:SetHidden(true)
    TransmuteSetCrafterQuicksaveWindow:SetHidden(true)
end

-- ── Side-panel visibility toggles ─────────────────────────

function TSC.ToggleCostWindow()
    local win = TransmuteSetCrafterCostWindow
    if not win then return end
    local nowHidden = not win:IsHidden()
    win:SetHidden(nowHidden)
    TSC.savedVars.costWindowHidden = nowHidden
    if not nowHidden then
        TSC.RefreshCostPanel()
    end
end

function TSC.ToggleQuicksaveWindow()
    local win = TransmuteSetCrafterQuicksaveWindow
    if not win then return end
    local nowHidden = not win:IsHidden()
    win:SetHidden(nowHidden)
    TSC.savedVars.quicksaveWindowHidden = nowHidden
    if not nowHidden and TSC.RefreshQuicksavePanel then
        TSC.RefreshQuicksavePanel()
    end
end

function TSC.ToggleWindow()
    if TransmuteSetCrafterWindow:IsHidden() then
        TSC.OpenWindow()
    else
        TSC.CloseWindow()
    end
end

-- ── Transmute / Clear buttons ──────────────────────────────

function TSC.UpdateTransmuteButton()
    local pending = TSC.GetPendingCount()
    TransmuteSetCrafterWindowTransmuteButton:SetText(
        zo_strformat(SI_TSC_TRANSMUTE_ALL, pending))
    TransmuteSetCrafterWindowTransmuteButton:SetEnabled(pending > 0)
end

-- ── Dirty event ────────────────────────────────────────────

local function OnCollectionsUpdated()
    if not TransmuteSetCrafterWindow:IsHidden() then
        TSC.RefreshInventoryList()
    end
end

EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME .. "_UI", EVENT_ITEM_SET_COLLECTIONS_UPDATED, OnCollectionsUpdated)
