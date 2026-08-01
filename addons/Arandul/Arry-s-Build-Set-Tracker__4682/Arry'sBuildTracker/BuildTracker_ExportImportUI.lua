-- BuildTracker_ExportImportUI.lua
--
-- A minimal, reusable popup with one editbox - used to display an export
-- string for easy Ctrl+A/Ctrl+C copying, and to accept a pasted import
-- string with a one-click Import button. This is NOT the paperdoll UI;
-- it's just a reliable copy/paste surface so export/import is actually
-- usable while the rest of the UI doesn't exist yet.
--
-- Built from raw control types (CT_BACKDROP/CT_LABEL/CT_EDITBOX) rather than
-- a stock dialog template, so it has no dependency beyond the base game UI.

BuildTracker = BuildTracker or {}
BuildTracker.UI = BuildTracker.UI or {}

local UI = BuildTracker.UI
local window -- lazily created singleton popup, reused for both export and import

local WINDOW_WIDTH = 560
local WINDOW_HEIGHT = 320

-- Shows or hides the window and switches the game's UI input mode to match.
-- Without this, keystrokes (including Ctrl+A/Ctrl+C) are consumed by normal
-- gameplay keybinds instead of reaching the edit box - this is what stock
-- panels (inventory, settings, etc.) do automatically and our custom window
-- has to do explicitly.
local function SetWindowShown(shown)
    window:SetHidden(not shown)
    SetGameCameraUIMode(shown)
end

local function CreateTextButton(parent, text, width)
    local btn = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    btn:SetFont("ZoFontGameBold")
    btn:SetText("[ " .. text .. " ]")
    btn:SetColor(unpack(BuildTracker.UI_GOLD_TEXT))
    btn:SetMouseEnabled(true)
    btn:SetDimensions(width or 110, 24)
    btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    btn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
    btn:SetHandler("OnMouseExit", function(self) self:SetColor(unpack(BuildTracker.UI_GOLD_TEXT)) end)
    return btn
end

local function EnsureWindow()
    if window then return window end

    window = WINDOW_MANAGER:CreateTopLevelWindow("BuildTracker_CopyWindow")
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -150)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    -- Same fix as the rename/delete-confirm popups (see BuildTracker_PaperdollUI.lua) -
    -- without an explicit DrawTier/DrawLevel this window sits behind the
    -- paperdoll's own DT_HIGH window whenever opened from within it.
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLevel(10)

    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetCenterColor(0.05, 0.05, 0.08, 0.95)
    BuildTracker.ApplyWindowBorder(bg, window)

    -- Whole top strip is draggable so the window can be moved out of the way.
    local dragHandle = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    dragHandle:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    dragHandle:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    dragHandle:SetHeight(28)
    dragHandle:SetMouseEnabled(true)
    dragHandle:SetHandler("OnDragStart", function() window:StartMoving() end)
    dragHandle:SetHandler("OnMouseUp", function() window:StopMovingOrResizing() end)

    local title = WINDOW_MANAGER:CreateControl(nil, dragHandle, CT_LABEL)
    title:SetAnchor(TOPLEFT, dragHandle, TOPLEFT, 10, 6)
    title:SetFont("ZoFontWinH4")
    title:SetText("Build Tracker")
    window.title = title

    local instructions = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    instructions:SetAnchor(TOPLEFT, dragHandle, BOTTOMLEFT, 10, 6)
    instructions:SetAnchor(TOPRIGHT, dragHandle, BOTTOMRIGHT, -10, 6)
    instructions:SetFont("ZoFontGame")
    instructions:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    window.instructions = instructions

    local editBoxBG = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    editBoxBG:SetAnchor(TOPLEFT, instructions, BOTTOMLEFT, 0, 10)
    editBoxBG:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -44)
    editBoxBG:SetCenterColor(0, 0, 0, 0.6)
    editBoxBG:SetEdgeColor(0.3, 0.3, 0.3, 1)

    local editBox = WINDOW_MANAGER:CreateControl(nil, editBoxBG, CT_EDITBOX)
    editBox:SetAnchorFill(editBoxBG)
    editBox:SetFont("ZoFontGame")
    editBox:SetMultiLine(true)
    editBox:SetMaxInputChars(8000)
    editBox:SetMouseEnabled(true)
    -- Clicking anywhere in the box re-focuses and re-selects it. Without
    -- this, only the very first TakeFocus() call (when the window opens)
    -- worked - clicking elsewhere lost focus permanently until the window
    -- was reopened, since there was no way to click back into the box.
    editBox:SetHandler("OnMouseUp", function(self, button, upInside)
        if upInside then
            self:TakeFocus()
            self:SelectAll()
        end
    end)
    editBox:SetHandler("OnEscape", function(self) SetWindowShown(false) end)
    window.editBox = editBox

    local closeBtn = CreateTextButton(window, "Close")
    closeBtn:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -10)
    closeBtn:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside then SetWindowShown(false) end
    end)
    window.closeBtn = closeBtn

    -- Generic action button - what it does depends on which mode opened the
    -- window (Copy for export, Import for import). window.actionBtnHandler
    -- is set fresh each time ShowExportBox/ShowImportBox is called.
    local actionBtn = CreateTextButton(window, "Import", 170)
    actionBtn:SetAnchor(BOTTOMRIGHT, closeBtn, BOTTOMLEFT, -10, 0)
    actionBtn:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside and window.actionBtnHandler then
            window.actionBtnHandler()
        end
    end)
    window.actionBtn = actionBtn

    return window
end

-- Shows the popup pre-filled with `text`, focused and selected. There is no
-- "Copy to Clipboard" button - CopyAllTextToClipboard() turns out to be a
-- protected/private function ZOS reserves for their own code; addons get an
-- "illegally call" error regardless of how it's invoked. The Select All
-- button instead just re-focuses + re-selects the box (handy after clicking
-- away), then Ctrl+C does the actual copying.
function UI.ShowExportBox(title, text)
    local w = EnsureWindow()
    w.title:SetText(title)
    w.instructions:SetText("Ctrl+C to copy. Click the box (or Select All) any time to reselect.")
    w.editBox:SetText(text)
    w.editBox:SetEditEnabled(true) -- must stay true for selection/copy to work
    w.actionBtn:SetHidden(false)
    w.actionBtn:SetText("[ Select All ]")
    w.actionBtnHandler = function()
        w.editBox:TakeFocus()
        w.editBox:SelectAll()
    end
    SetWindowShown(true)
    w.editBox:TakeFocus()
    w.editBox:SelectAll()
end

-- Shows an empty popup for pasting an import string; onSubmit(text) fires
-- when the Import button is clicked. The window stays open on failure so
-- the user can see the chat error and try again without re-pasting.
function UI.ShowImportBox(onSubmit)
    local w = EnsureWindow()
    w.title:SetText("Build Tracker - Import")
    w.instructions:SetText("Paste an export string below (Ctrl+V), then click Import.")
    w.editBox:SetText("")
    w.editBox:SetEditEnabled(true)
    w.actionBtn:SetHidden(false)
    w.actionBtn:SetText("[ Import ]")
    w.actionBtnHandler = function()
        onSubmit(w.editBox:GetText())
    end
    SetWindowShown(true)
    w.editBox:TakeFocus()
end
