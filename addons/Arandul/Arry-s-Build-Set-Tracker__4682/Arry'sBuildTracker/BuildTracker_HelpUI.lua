-- BuildTracker_HelpUI.lua
--
-- A simple, static help popup explaining basic end-user usage of the
-- paperdoll (opened via the info button in its build-switcher row - see
-- BuildTracker_PaperdollUI.lua). Deliberately plain-language/no
-- implementation detail.  This is for someone using the
-- addon, not someone reading its code.
--


BuildTracker = BuildTracker or {}
BuildTracker.UI = BuildTracker.UI or {}

local UI = BuildTracker.UI
local window -- lazily created singleton popup

local WINDOW_WIDTH = 460
-- Everything below the drag strip (title/text/close button) plus the
-- vertical padding baked into their anchors - the window's actual height is
-- this plus however tall HELP_TEXT renders at WINDOW_WIDTH, computed once
-- below via GetTextHeight() rather than hand-guessed, so editing HELP_TEXT
-- later doesn't silently reintroduce clipped/overflowing text.
local CHROME_HEIGHT = 40 + 50

local HELP_TEXT = table.concat({
    "|cFFD700Assigning gear|r",
    "Left-click any slot to search for and pick a set for it. If a set offers more than one weight or weapon type, you'll be asked to pick one.",
    "",
    "|cFFD700Trait & enchantment notes|r",
    "Right-click an already-assigned slot to optionally note a desired trait and/or enchantment for it. This is just a personal reminder shown on the item's tooltip - it doesn't change which item you need.",
    "",
    "|c00FF00Green|r / |cFF3333red|r / |cFFCC00yellow|r borders",
    "A slot's border color shows whether you've already collected that exact piece (permanently unlocked in your account-wide Set Item Collection, so you can reconstruct it any time):",
    "  |c00FF00Green|r - collected",
    "  |cFF3333Red|r - not yet collected",
    "  |cFFCC00Yellow|r - unknown (usually a craftable set, which isn't tracked this way)",
    "",
    "|cFFD700Managing builds|r",
    "The dropdown at the top switches between your saved builds. |c00FF00+|r creates a new one, |cFF3333-|r deletes the current one, and Rename changes its name.",
    "",
    "|cFFD700Sharing builds|r",
    "The up-arrow button exports the current build as a text string you can share or back up. The down-arrow button imports a build from a pasted string.",
    "",
    "|cFFD700Loot alerts|r",
    "If enabled (see /bt settings, or addon settings ui), you'll get a chat message when you or a groupmate loots something needed for one of your builds that you haven't collected yet.",
}, "\n")

local function CreateTextButton(parent, text, width)
    local btn = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    btn:SetFont("ZoFontGameBold")
    btn:SetText("[ " .. text .. " ]")
    btn:SetColor(unpack(BuildTracker.UI_GOLD_TEXT))
    btn:SetMouseEnabled(true)
    btn:SetDimensions(width or 90, 24)
    btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    btn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
    btn:SetHandler("OnMouseExit", function(self) self:SetColor(unpack(BuildTracker.UI_GOLD_TEXT)) end)
    return btn
end

local function EnsureWindow()
    if window then return window end

    window = WINDOW_MANAGER:CreateTopLevelWindow("BuildTracker_HelpWindow")
    window:SetWidth(WINDOW_WIDTH) -- height is set below once the text control's wrapped height is known
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLevel(10) -- same tie-breaker reasoning as the set picker's own window

    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetCenterColor(0.05, 0.05, 0.08, 0.97)
    BuildTracker.ApplyWindowBorder(bg, window)

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
    title:SetText("Build Tracker - Help")

    local text = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    text:SetAnchor(TOPLEFT, dragHandle, BOTTOMLEFT, 16, 12)
    text:SetAnchor(TOPRIGHT, dragHandle, BOTTOMRIGHT, -16, 12)
    text:SetFont("ZoFontGame")
    text:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    text:SetVerticalAlignment(TEXT_ALIGN_TOP)
    text:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    text:SetText(HELP_TEXT)
    -- GetTextHeight() only returns the correct wrapped height once the
    -- label's width is already resolved, which it is here since both of
    -- text's anchors above are already attached to dragHandle (itself
    -- already sized to window's already-set WIDTH). Explicitly setting the
    -- label's own height (rather than leaving it to auto-size) is what
    -- fixed this window rendering too short for its content and clipping/
    -- overflowing past its own border and the Close button.
    local textHeight = text:GetTextHeight()
    text:SetHeight(textHeight)
    window:SetHeight(CHROME_HEIGHT + textHeight)

    local closeBtn = CreateTextButton(window, "Close")
    closeBtn:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -10)
    closeBtn:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside then window:SetHidden(true) end
    end)

    return window
end

-- Public entry point. No camera-mode toggling - always opened from within
-- the still-open paperdoll window, which already has the cursor active.
function UI.ShowHelp()
    local w = EnsureWindow()
    w:SetHidden(false)
end
