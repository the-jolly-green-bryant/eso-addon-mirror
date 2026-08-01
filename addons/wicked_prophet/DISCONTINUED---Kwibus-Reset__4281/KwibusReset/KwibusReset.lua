local ADDON_NAME = "KwibusReset"

local KWR = {
    -- Display name (what users see in settings, chat, etc.)
    name      = "Kwibus Reset",
    addonName = ADDON_NAME,
    version   = "1.11.0",
}

-- ---------------- Locals & Aliases ----------------
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

-- Difficulty constants 
local DIFF_NORMAL  = 1
local DIFF_VETERAN = 2

-- ---------------- SavedVars ----------------
KWR.Defaults = {
    showCSA     = true,                         -- show the (movable) on-screen big notification
    showChat    = true,                         -- echo to chat
    color       = { r = 0.043, g = 1.0, b = 1.0 }, -- outer color (#0BFFFF)
    posX        = 0,                            -- offset from screen center (x)
    posY        = 220,                          -- offset from screen center (y)
    lifespanMs  = 5000,                         -- auto-hide duration when not persistent
    keepVisible = false,                        -- keep last banner visible for moving
    textScale   = 1.0,                          -- label scale (0.5 .. 2.0)
}

-- ---------------- Internal state ----------------
local initialized   = false
local deactivated   = false
local trialDiff     = DIFF_NORMAL -- seeded from game on load/activation

-- Debounce (only show last flip within window)
local COOLDOWN_MS   = 2000
local UPDATE_NAME   = ADDON_NAME .. "_Cooldown"
local pendingMsg    = nil
local lastChangeMs  = 0
local cooldownArmed = false

-- UI (movable big text replaces CSA)
KWR.ui = {
    tlw         = nil,   -- TopLevelWindow (not mouse-enabled; no big hitbox)
    label       = nil,   -- CT_LABEL (mouse-enabled; small hitbox = text + padding)
    hideNonce   = 0,     -- one-shot hide guard
    lastMessage = nil,   -- last uncolored text we showed
    pad         = 12,    -- padding (unscaled) around text for dragging comfort
}

-- ---------------- Helpers ----------------
local function SeedDifficultyFromGame()
    local eff = ZO_GetEffectiveDungeonDifficulty()
    trialDiff = (eff == DUNGEON_DIFFICULTY_VETERAN) and DIFF_VETERAN or DIFF_NORMAL
end

local function DiffToColored(diff)
    -- Keep legacy coloring: Veteran = green, Normal = red
    if diff == DIFF_VETERAN then
        return "|c00FF00Veteran|r"   -- green
    else
        return "|cFF0000Normal|r"    -- red
    end
end

-- {r,g,b} (0..1) -> ESO |cRRGGBB
local function RGBToHex(r, g, b)
    r = zo_clamp(tonumber(r) or 1, 0, 1)
    g = zo_clamp(tonumber(g) or 1, 0, 1)
    b = zo_clamp(tonumber(b) or 1, 0, 1)
    local R = zo_floor(r * 255 + 0.5)
    local G = zo_floor(g * 255 + 0.5)
    local B = zo_floor(b * 255 + 0.5)
    return string.format("|c%02X%02X%02X", R, G, B)
end

local function HideBigNow()
    local tlw = KWR.ui.tlw
    if tlw and not tlw:IsHidden() then
        tlw:SetHidden(true)
    end
end

-- ---------- Movable big text (CSA replacement) ----------
local function ApplyOverlayPosition()
    local tlw = KWR.ui.tlw
    if not tlw then return end
    local sv = KWR.saved or KWR.Defaults
    tlw:ClearAnchors()
    tlw:SetAnchor(CENTER, GuiRoot, CENTER, sv.posX or 0, sv.posY or 0)
end

local function ApplyTextScale()
    local label = KWR.ui.label
    if not label then return end
    local sv = KWR.saved or KWR.Defaults
    local scale = zo_clamp(tonumber(sv.textScale) or 1.0, 0.5, 2.0)
    label:SetScale(scale)
end

local function SizeTLWToText()
    local tlw, label = KWR.ui.tlw, KWR.ui.label
    if not (tlw and label) then return end

    local sv = KWR.saved or KWR.Defaults
    local scale = zo_clamp(tonumber(sv.textScale) or 1.0, 0.5, 2.0)

    -- GetTextWidth/Height are unscaled; multiply by scale
    local w = (label:GetTextWidth()  or 0) * scale + KWR.ui.pad * 2
    local h = (label:GetTextHeight() or 0) * scale + KWR.ui.pad * 2

    -- Fallback if 0 right after SetText; retry next frame
    if w <= 2 or h <= 2 then
        zo_callLater(SizeTLWToText, 0)
        return
    end

    -- Minimums so it's still easy to grab
    w = (w < 120) and 120 or w
    h = (h <  40) and  40 or h

    tlw:SetDimensions(w, h)
end

local function EnsureOverlay()
    if KWR.ui.tlw and KWR.ui.label then return end

    local tlw = WM:CreateTopLevelWindow("KWR_MovableBigTLW")
    -- Keep TLW off mouse so the hitbox is only the label
    tlw:SetMouseEnabled(false)
    tlw:SetMovable(true)
    tlw:SetClampedToScreen(true)
    tlw:SetResizeHandleSize(0)

    tlw:SetDrawTier(DT_HIGH)
    tlw:SetDrawLayer(DL_OVERLAY)
    tlw:SetDrawLevel(999)

    -- Save pos on drop (center-relative)
    tlw:SetHandler("OnMoveStop", function(self)
        local cx, cy = self:GetCenter()
        local rootW, rootH = GuiRoot:GetDimensions()
        local centerX, centerY = rootW * 0.5, rootH * 0.5
        local sv = KWR.saved or KWR.Defaults
        sv.posX = zo_round(cx - centerX)
        sv.posY = zo_round(cy - centerY)
        ApplyOverlayPosition()
    end)

    -- Inner label: the only mouse-enabled area
    local label = WM:CreateControl("KWR_MovableBigLabel", tlw, CT_LABEL)
    label:SetFont("ZoFontAnnounceLarge")      -- CSA-like big font
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetMouseEnabled(true)
    label:ClearAnchors()
    label:SetAnchor(CENTER, tlw, CENTER, 0, 0)

    -- Forward drag events from the label to the TLW (Start/StopMoving)
    label:SetHandler("OnMouseDown", function() tlw:StartMoving() end)
    label:SetHandler("OnMouseUp",   function() tlw:StopMovingOrResizing() end)

    -- Tiny initial size; will auto-fit to text after first SetText
    tlw:SetDimensions(120, 40)

    KWR.ui.tlw, KWR.ui.label = tlw, label
    ApplyTextScale()
    ApplyOverlayPosition()
    tlw:SetHidden(true)
end

local function ShowBigMovable(textNoOuterColor)
    local sv = KWR.saved or KWR.Defaults
    if not (sv.showCSA and textNoOuterColor and textNoOuterColor ~= "") then
        HideBigNow()
        return
    end

    EnsureOverlay()
    ApplyTextScale()

    local color = sv.color or KWR.Defaults.color
    local colorCode = RGBToHex(color.r, color.g, color.b)
    KWR.ui.label:SetText(colorCode .. textNoOuterColor .. "|r")

    -- Fit TLW snugly to the (scaled) text + padding (run twice to catch first-frame metrics)
    SizeTLWToText()
    zo_callLater(SizeTLWToText, 0)

    KWR.ui.tlw:SetHidden(false)

    -- one-shot auto-hide with nonce guard
    KWR.ui.hideNonce = (KWR.ui.hideNonce or 0) + 1
    local myNonce = KWR.ui.hideNonce

    if not sv.keepVisible then
        local ms = sv.lifespanMs or 5000
        zo_callLater(function()
            -- re-check settings on fire to respect toggles changed during the timer
            if myNonce == KWR.ui.hideNonce and (KWR.saved and KWR.saved.showCSA) and not (KWR.saved and KWR.saved.keepVisible) then
                HideBigNow()
            end
        end, ms)
    end
end

-- Build the final message string (diffText already colored)
local function BuildMessageText(diffText)
    return zo_strformat("Instance reset. Difficulty: <<1>> – charge ult", diffText)
end

local function ShowNotification(textNoOuterColor)
    local sv = KWR.saved or KWR.Defaults
    KWR.ui.lastMessage = textNoOuterColor

    -- On-screen (movable big text), respecting the toggle
    if sv.showCSA then
        ShowBigMovable(textNoOuterColor)
    else
        HideBigNow()
    end

    -- Chat
    if sv.showChat and CHAT_SYSTEM then
        local color = sv.color or KWR.Defaults.color
        local colorCode = RGBToHex(color.r, color.g, color.b)
        CHAT_SYSTEM:AddMessage(colorCode .. textNoOuterColor .. "|r")
    end
end

-- Debounce: only show the latest flip after COOLDOWN_MS without further changes
local function ArmCooldown(messageNoOuterColor)
    pendingMsg   = messageNoOuterColor
    lastChangeMs = GetFrameTimeMilliseconds()

    if cooldownArmed then return end
    cooldownArmed = true

    EM:RegisterForUpdate(UPDATE_NAME, 100, function()
        local now = GetFrameTimeMilliseconds()
        if (now - lastChangeMs) >= COOLDOWN_MS then
            EM:UnregisterForUpdate(UPDATE_NAME)
            cooldownArmed = false
            if pendingMsg then
                ShowNotification(pendingMsg)
                pendingMsg = nil
            end
        end
    end)
end

local function QueueResetMessage(newDiff)
    local diffText   = DiffToColored(newDiff)           -- colored
    local textNoCol  = BuildMessageText(diffText)       -- final text (outer color applied later)
    ArmCooldown(textNoCol)
end

-- Centralized difficulty change handler
local function UpdateDifficulty(newDiff)
    if not initialized then
        trialDiff = newDiff
        return
    end
    if newDiff == trialDiff then return end
    trialDiff = newDiff
    if not deactivated then
        QueueResetMessage(newDiff)
    end
end

-- ---------------- Event handlers ----------------
local function OnVeteranDifficultyChanged(_, unitTag, isDifficult)
    UpdateDifficulty(isDifficult and DIFF_VETERAN or DIFF_NORMAL)
end

local function OnGroupVeteranDifficultyChanged(_, isVeteranDifficulty)
    UpdateDifficulty(isVeteranDifficulty and DIFF_VETERAN or DIFF_NORMAL)
end

local function OnGroupChanged(_, _, isPlayer)
    if not isPlayer then return end
    SeedDifficultyFromGame()
end

local function OnDeactivated()
    deactivated = true
end

local function OnPlayerActivated()
    SeedDifficultyFromGame()
    initialized = true
    deactivated = false

    -- cancel any pending cooldown
    if cooldownArmed then
        EM:UnregisterForUpdate(UPDATE_NAME)
        cooldownArmed = false
        pendingMsg = nil
    end

    EnsureOverlay()
    ApplyTextScale()
    ApplyOverlayPosition()

    -- keep state consistent on load
    local sv = KWR.saved or KWR.Defaults
    if sv.showCSA and sv.keepVisible and KWR.ui.lastMessage then
        ShowBigMovable(KWR.ui.lastMessage)
    else
        HideBigNow()
    end
end

-- ---------------- Settings (LibAddonMenu-2.0) ----------------
local function BuildSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = KWR.name,
        displayName = KWR.name .. " |caaaaaa(v" .. KWR.version .. ")|r",
        author = "|ce6202dKwiebe-Kwibus|r",
        version = KWR.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local sv = KWR.saved

    local options = {
        { type = "header", name = "On-screen notification" },
        {
            type = "checkbox",
            name = "Show on-screen notification",
            tooltip = "Show the main big notification (movable replacement for CSA).",
            getFunc = function() return sv.showCSA end,
            setFunc = function(val)
                sv.showCSA = val
                if not val then
                    HideBigNow()
                elseif sv.keepVisible and KWR.ui.lastMessage then
                    ShowBigMovable(KWR.ui.lastMessage)
                end
            end,
            default = KWR.Defaults.showCSA,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Keep on screen for moving",
            tooltip = "Keep the last shown big message visible (no auto-hide) so you can drag it around.",
            getFunc = function() return sv.keepVisible end,
            setFunc = function(val)
                sv.keepVisible = val
                EnsureOverlay()
                if not val then
                    HideBigNow()
                else
                    if sv.showCSA then
                        ShowBigMovable("This is a debug message. Move it to the position you want an alert to be.")
                    else
                        HideBigNow()
                    end
                end
            end,
            default = KWR.Defaults.keepVisible,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Notification color",
            tooltip = "Outer color for the big message (Normal/Veteran stays green/red inside).",
            getFunc = function() return sv.color.r, sv.color.g, sv.color.b end,
            setFunc = function(r, g, b)
                sv.color.r, sv.color.g, sv.color.b = r, g, b
                if sv.showCSA and KWR.ui.tlw and not KWR.ui.tlw:IsHidden() then
                    if sv.keepVisible then
                        ShowBigMovable("This is a debug message. Move it to the position you want an alert to be.")
                    elseif KWR.ui.lastMessage then
                        ShowBigMovable(KWR.ui.lastMessage)
                    end
                end
            end,
            default = { r = KWR.Defaults.color.r, g = KWR.Defaults.color.g, b = KWR.Defaults.color.b },
            width = "full",
        },
        {
            type = "slider",
            name = "Text size (percent)",
            tooltip = "Resize the main notification text.",
            min = 50, max = 200, step = 5,
            getFunc = function()
                return math.floor(((sv.textScale or KWR.Defaults.textScale) * 100) + 0.5)
            end,
            setFunc = function(val)
                sv.textScale = zo_clamp((val or 100) / 100, 0.5, 2.0)
                EnsureOverlay()
                ApplyTextScale()
                if sv.showCSA and KWR.ui.tlw and not KWR.ui.tlw:IsHidden() then
                    if sv.keepVisible then
                        ShowBigMovable("This is a debug message. Move it to the position you want an alert to be.")
                    elseif KWR.ui.lastMessage then
                        ShowBigMovable(KWR.ui.lastMessage)
                    end
                end
            end,
            default = math.floor(KWR.Defaults.textScale * 100),
            width = "full",
        },
        {
            type = "slider",
            name = "Show time (seconds)",
            tooltip = "How long the big notification stays visible when persistence is OFF.",
            min = 1, max = 10, step = 1,
            getFunc = function() return math.floor((sv.lifespanMs or KWR.Defaults.lifespanMs) / 1000) end,
            setFunc = function(val) sv.lifespanMs = (val * 1000) end,
            default = math.floor(KWR.Defaults.lifespanMs / 1000),
            width = "full",
        },

        { type = "header", name = "Position" },
        {
            type = "button",
            name = "Center horizontally",
            tooltip = "Snap the main notification to the horizontal center.",
            func = function()
                EnsureOverlay()
                sv.posX = 0
                ApplyOverlayPosition()
                if sv.showCSA and KWR.ui.tlw and not KWR.ui.tlw:IsHidden() then
                    if sv.keepVisible then
                        ShowBigMovable("This is a debug message. Move it to the position you want an alert to be.")
                    elseif KWR.ui.lastMessage then
                        ShowBigMovable(KWR.ui.lastMessage)
                    end
                end
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Center vertically",
            tooltip = "Snap the main notification to the vertical center.",
            func = function()
                EnsureOverlay()
                sv.posY = 0
                ApplyOverlayPosition()
                if sv.showCSA and KWR.ui.tlw and not KWR.ui.tlw:IsHidden() then
                    if sv.keepVisible then
                        ShowBigMovable("This is a debug message. Move it to the position you want an alert to be.")
                    elseif KWR.ui.lastMessage then
                        ShowBigMovable(KWR.ui.lastMessage)
                    end
                end
            end,
            width = "half",
        },

        { type = "header", name = "Chat" },
        {
            type = "checkbox",
            name = "Show chat message",
            tooltip = "Echo the message to chat alongside the on-screen one.",
            getFunc = function() return sv.showChat end,
            setFunc = function(val) sv.showChat = val end,
            default = KWR.Defaults.showChat,
            width = "full",
        },
    }

    -- Panel ID should be stable across renames
    LAM:RegisterAddonPanel(ADDON_NAME .. "_Panel", panelData)
    LAM:RegisterOptionControls(ADDON_NAME .. "_Panel", options)
end

-- ---------------- Bootstrap ----------------
local function OnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- SavedVars (account-wide)
    KWR.saved = ZO_SavedVars:NewAccountWide("KWR_SV", 12, nil, KWR.Defaults)

    SeedDifficultyFromGame()

    BuildSettingsMenu()
    EnsureOverlay()
    ApplyTextScale()
    ApplyOverlayPosition()

    EM:RegisterForEvent(ADDON_NAME .. "_Deactivated", EVENT_PLAYER_DEACTIVATED, OnDeactivated)
    EM:RegisterForEvent(ADDON_NAME .. "_Vet1", EVENT_VETERAN_DIFFICULTY_CHANGED, OnVeteranDifficultyChanged)
    EM:RegisterForEvent(ADDON_NAME .. "_Vet2", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, OnGroupVeteranDifficultyChanged)

    EM:RegisterForEvent(ADDON_NAME .. "_Joined", EVENT_GROUP_MEMBER_JOINED, OnGroupChanged)
    EM:AddFilterForEvent(ADDON_NAME .. "_Joined", EVENT_GROUP_MEMBER_JOINED, REGISTER_FILTER_UNIT_TAG, "player")

    EM:RegisterForEvent(ADDON_NAME .. "_Left", EVENT_GROUP_MEMBER_LEFT, OnGroupChanged)
    EM:AddFilterForEvent(ADDON_NAME .. "_Left", EVENT_GROUP_MEMBER_LEFT, REGISTER_FILTER_UNIT_TAG, "player")

    EM:RegisterForEvent(ADDON_NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)
