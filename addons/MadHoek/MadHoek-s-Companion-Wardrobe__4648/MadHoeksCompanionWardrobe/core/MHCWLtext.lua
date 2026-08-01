-- ============================================================================
-- Companion Wardrobe
-- Text, Notifications and Tooltip Helpers
--
-- Responsibilities:
-- - Centralize addon chat notifications.
-- - Provide tooltip mode handling.
-- - Build simple/tutorial tooltip variants.
-- - Keep tooltip behavior consistent across all UI elements.
-- ============================================================================
if MHCWL == nil then MHCWL = {} end
local MHCWL = MHCWL

MHCWL.FONT_FACE = "EsoUI/Common/Fonts/Univers57.otf"
MHCWL.FONT_STYLE = "soft-shadow-thin"

MHCWL.FONT_BASE_SIZE = 18

MHCWL.FONT_SIZE_OFFSETS = {
    gameSmall = -5,
    game = 0,
    gameBold = 0,
    header = 2,
    inspectText = -3,
}

function MHCWL.GetFontSize(key)
    local base = MHCWL.FONT_BASE_SIZE or 18
    local offset = MHCWL.FONT_SIZE_OFFSETS[key] or 0

    return math.max(8, math.floor(base + offset))
end

function MHCWL.BuildFont(size, style)
    return MHCWL.FONT_FACE
        .. "|"
        .. tostring(size)
        .. "|"
        .. tostring(style or MHCWL.FONT_STYLE)
end

function MHCWL.RefreshFonts()
    MHCWL.FONTS = {
        gameSmall = MHCWL.BuildFont(MHCWL.GetFontSize("gameSmall")),
        game = MHCWL.BuildFont(MHCWL.GetFontSize("game")),
        gameBold = MHCWL.BuildFont(MHCWL.GetFontSize("gameBold"), "soft-shadow-thick"),
        header = MHCWL.BuildFont(MHCWL.GetFontSize("header"), "soft-shadow-thick"),
        inspectText = MHCWL.BuildFont(MHCWL.GetFontSize("inspectText")),
    }
end

function MHCWL.GetInspectTextFont()
    return MHCWL.FONTS.inspectText
end

MHCWL.RefreshFonts()

function MHCWL.ColorizeText(hex, text)
    return "|c" .. tostring(hex) .. tostring(text) .. "|r"
end

function MHCWL.CleanEsoName(rawName)
    if rawName and rawName ~= "" then
        return ZO_CachedStrFormat("<<C:1>>", rawName)
    end

    return nil
end

function MHCWL.SlotName(slot)
    return MHCWL.CleanEsoName(GetString("SI_EQUIPSLOT", slot)) or tostring(slot)
end

function MHCWL.GetLoadoutSortModeLabel(mode)
    if not mode then return "" end

    if mode.labelString and _G[mode.labelString] then
        return GetString(_G[mode.labelString])
    end

    return tostring(mode.label or mode.labelString or "")
end

function MHCWL.GetDisplaySkillSlotName(slotIndex)
    if slotIndex == 8 then
        return GetString(MHCWL_WINDOW_INSPECT_SKILL_ULTIMATE_SLOTNAME)
    end

    return GetString(MHCWL_WINDOW_INSPECT_SKILL_SLOTNAME) .. tostring(slotIndex - 2)
end

function MHCWL.TruncateTextToWidth(text, font, maxWidth)
    text = tostring(text or "")
    font = font or MHCWL.FONTS.game
    maxWidth = tonumber(maxWidth) or 0

    if maxWidth <= 0 then
        return text
    end

    if not MHCWL.measureLabel then
        MHCWL.measureLabel = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_LABEL)
        MHCWL.measureLabel:SetHidden(true)
    end

    local measure = MHCWL.measureLabel

    measure:SetFont(font)
    measure:SetHidden(true)
    measure:SetText(text)

    local width = measure:GetTextDimensions()

    if width <= maxWidth then
        return text
    end

    local ellipsis = "..."
    local low = 1
    local high = #text
    local best = ellipsis

    while low <= high do
        local mid = math.floor((low + high) / 2)
        local candidate = string.sub(text, 1, mid) .. ellipsis

        measure:SetText(candidate)
        width = measure:GetTextDimensions()

        if width <= maxWidth then
            best = candidate
            low = mid + 1
        else
            high = mid - 1
        end
    end

    return best
end

-- Display a center-screen addon notification.
function MHCWL.Notify(message, sound)
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
    params:SetText(tostring(message))
    params:SetSound(sound or SOUNDS.NONE)

    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

function MHCWL.GetMouseTooltipAnchor()
    if not MHCWL.mouseTooltipAnchor then
        MHCWL.mouseTooltipAnchor =
            WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_CONTROL)

        MHCWL.mouseTooltipAnchor:SetDimensions(1, 1)
        MHCWL.mouseTooltipAnchor:SetMouseEnabled(false)
        MHCWL.mouseTooltipAnchor:SetHidden(true)
    end

    local mx, my = GetUIMousePosition()

    MHCWL.mouseTooltipAnchor:ClearAnchors()
    MHCWL.mouseTooltipAnchor:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        mx,
        my
    )

    return MHCWL.mouseTooltipAnchor
end

-- Return the currently selected tooltip behavior mode.
function MHCWL.GetTooltipMode()
    return MHCWL.saved
        and MHCWL.saved.settings
        and MHCWL.saved.settings.tooltipMode
        or MHCWL.TOOLTIP_MODE_TUTORIAL
end

-- Convenience helper used by UI code to check for no, simple or tutorial tooltips.
function MHCWL.AreTooltipsEnabled()
    return MHCWL.GetTooltipMode() ~= MHCWL.TOOLTIP_MODE_OFF
end

-- Convenience helper used when tutorial-only information should be shown.
function MHCWL.AreTutorialTooltipsEnabled()
    return MHCWL.GetTooltipMode() == MHCWL.TOOLTIP_MODE_TUTORIAL
end

function MHCWL.GetTooltipText(tooltipText)
    if type(tooltipText) == "function" then
        return tooltipText()
    end

    return tooltipText
end

-- Return the correct tooltip variant based on the selected tooltip mode.
function MHCWL.GetTutorialTooltip(simpleTextId, tutorialTextId)
    local mode = MHCWL.GetTooltipMode()

    if mode == MHCWL.TOOLTIP_MODE_OFF then
        return ""
    end

    if mode == MHCWL.TOOLTIP_MODE_TUTORIAL then
        return GetString(tutorialTextId)
    end

    return GetString(simpleTextId)
end

function MHCWL.ShowControlTooltip(control, tooltipText)
    local tooltip = MHCWL.GetTooltipText(tooltipText)

    if not tooltip or tooltip == "" then return end

    InitializeTooltip(InformationTooltip, control, TOPLEFT, 12, 8)
    SetTooltipText(InformationTooltip, tooltip)
end

function MHCWL.HideControlTooltip()
    ClearTooltip(InformationTooltip)
end