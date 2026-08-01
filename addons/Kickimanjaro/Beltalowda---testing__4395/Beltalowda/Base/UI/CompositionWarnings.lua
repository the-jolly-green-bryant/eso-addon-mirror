-- Beltalowda Composition Warnings & Consumables
-- A draggable button that shows composition warnings and consumable buff
-- status.  Consumable icons appear to the LEFT of the warning count.
-- When a consumable is nearing expiration a red timer appears next to its
-- icon.  Hover an icon for the buff name + remaining time.
-- Click the element for the context menu (composition, warnings, settings).

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.CompositionWarnings = {}

local Indicator = Beltalowda.UI.CompositionWarnings
local wm = WINDOW_MANAGER

-- ============================================================================
-- Constants
-- ============================================================================

Indicator.LABEL_HEIGHT = 28
Indicator.LABEL_PADDING_H = 6    -- horizontal padding each side
Indicator.LABEL_FONT = "ZoFontGameBold"
Indicator.TIMER_FONT = "ZoFontGameSmall"
Indicator.ICON_SIZE = 24
Indicator.CONSUMABLE_ICON_SIZE = 20  -- slightly smaller for consumable icons
Indicator.ICON_GAP = 4           -- gap between elements
Indicator.ALERT_ICON = "/esoui/art/icons/ability_thievesguild_passive_002.dds"
Indicator.NO_WARNINGS_ICON = "/esoui/art/icons/ability_psijic_008.dds"
Indicator.DEFAULT_FOOD_ICON = "/esoui/art/icons/consumable_food_002.dds"
Indicator.DEFAULT_AP_ICON = "/esoui/art/icons/icon_alliancepoints.dds"
Indicator.DEFAULT_XP_ICON = "/esoui/art/icons/icon_experience.dds"

-- Expiration thresholds (seconds) — timers appear in red below these
Indicator.FOOD_CRITICAL_THRESHOLD = 600   -- 10 minutes
Indicator.BUFF_CRITICAL_THRESHOLD = 300   -- 5 minutes

-- ============================================================================
-- Settings
-- ============================================================================

Indicator.settings = {
    enabled = true,
    positionX = 900,
    positionY = 450,
    showFood = true,
    showAP = true,
    showXP = true,
}

-- Tick counter for throttling composition re-analysis
Indicator.analysisTick = 999  -- force immediate analysis on first tick
Indicator.ANALYSIS_INTERVAL = 5  -- re-analyze every 5 ticks (5 seconds)

-- Menu visibility state (set by centralized layer handler)
Indicator.menuHidden = false

-- PvP visibility state (set by centralized PvP zone handler)
Indicator.pvpHidden = false

-- ============================================================================
-- Menu Hidden (centralized layer handler)
-- ============================================================================

function Indicator.SetMenuHidden(hidden)
    Indicator.menuHidden = hidden
    Indicator.SetControlVisibility()
end

function Indicator.SetPvPHidden(hidden)
    Indicator.pvpHidden = hidden
    Indicator.SetControlVisibility()
end

-- ============================================================================
-- Initialize
-- ============================================================================

function Indicator.Initialize()
    if Indicator.initialized then return end

    Indicator.LoadSettings()
    Indicator.CreateButton()

    -- Initialize the companion panel
    if Beltalowda.UI.CompositionWarningsPanel and Beltalowda.UI.CompositionWarningsPanel.Initialize then
        Beltalowda.UI.CompositionWarningsPanel.Initialize()
    end

    -- Update warnings + consumable icons every 1 s
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaCompositionWarnings", 1000, function()
        Indicator.UpdateDisplay()
    end)

    Indicator.UpdateDisplay()
    Indicator.SetControlVisibility()

    Indicator.initialized = true
end

-- ============================================================================
-- Settings persistence
-- ============================================================================

function Indicator.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.compositionWarnings = BeltalowdaVars.ui.compositionWarnings or {}

    local saved = BeltalowdaVars.ui.compositionWarnings
    Indicator.settings.enabled = saved.enabled ~= false
    Indicator.settings.positionX = saved.positionX or 900
    Indicator.settings.positionY = saved.positionY or 450
    if saved.showFood ~= nil then Indicator.settings.showFood = saved.showFood else Indicator.settings.showFood = true end
    if saved.showAP   ~= nil then Indicator.settings.showAP   = saved.showAP   else Indicator.settings.showAP   = true end
    if saved.showXP   ~= nil then Indicator.settings.showXP   = saved.showXP   else Indicator.settings.showXP   = true end
end

function Indicator.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.compositionWarnings = {
        enabled = Indicator.settings.enabled,
        positionX = Indicator.settings.positionX,
        positionY = Indicator.settings.positionY,
        showFood = Indicator.settings.showFood,
        showAP = Indicator.settings.showAP,
        showXP = Indicator.settings.showXP,
    }
end

-- ============================================================================
-- Time formatting
-- ============================================================================

local function FormatTime(seconds)
    if seconds <= 0 then return "" end
    seconds = math.floor(seconds)
    if seconds < 3600 then
        return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
    end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%d:%02d:%02d", h, m, s)
end

local function FormatTimeLong(seconds)
    if not seconds or seconds <= 0 then return "expired" end
    seconds = math.floor(seconds)
    if seconds >= 3600 then
        return string.format("%dh %dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
    elseif seconds >= 60 then
        return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
    end
    return string.format("%ds", seconds)
end

-- ============================================================================
-- Create the button UI
-- ============================================================================

function Indicator.CreateButton()
    if Indicator.controls then return end

    local h = Indicator.LABEL_HEIGHT
    local initW = 80

    -- Top-level window — always draggable
    local win = wm:CreateTopLevelWindow("BeltalowdaCompositionWarnings")
    win:SetDimensions(initW, h)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        Indicator.settings.positionX, Indicator.settings.positionY)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetClampedToScreen(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawLevel(10)
    win:SetHidden(true)

    -- Backdrop
    local bd = wm:CreateControl(nil, win, CT_BACKDROP)
    bd:SetAnchorFill(win)
    bd:SetCenterColor(0.05, 0.05, 0.05, 0.7)
    bd:SetEdgeColor(0.3, 0.3, 0.3, 0.8)
    bd:SetEdgeTexture("", 1, 1, 1)
    bd:SetDrawLevel(0)
    Indicator.backdrop = bd

    -- Warning alert icon (rightmost)
    local alertIcon = wm:CreateControl(nil, win, CT_TEXTURE)
    alertIcon:SetDimensions(Indicator.ICON_SIZE, Indicator.ICON_SIZE)
    alertIcon:SetTexture(Indicator.ALERT_ICON)
    alertIcon:SetMouseEnabled(false)

    -- Warning count label (left of alert icon)
    local lbl = wm:CreateControl(nil, win, CT_LABEL)
    lbl:SetFont(Indicator.LABEL_FONT)
    lbl:SetText("")
    lbl:SetColor(1, 1, 1, 1)
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    lbl:SetMouseEnabled(false)

    -- ── Consumable icon slots ───────────────────────────────────────
    local consSz = Indicator.CONSUMABLE_ICON_SIZE
    local function createConsumableSlot(defaultIcon)
        local container = wm:CreateControl(nil, win, CT_CONTROL)
        container:SetDimensions(consSz, consSz)
        container:SetMouseEnabled(true)
        container:SetDrawTier(DT_HIGH)
        container:SetHidden(true)

        local tex = wm:CreateControl(nil, container, CT_TEXTURE)
        tex:SetAnchorFill(container)
        tex:SetTexture(defaultIcon)

        local timer = wm:CreateControl(nil, win, CT_LABEL)
        timer:SetFont(Indicator.TIMER_FONT)
        timer:SetText("")
        timer:SetColor(1, 0.2, 0.2, 1)
        timer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        timer:SetMouseEnabled(false)
        timer:SetHidden(true)

        container.tooltipText = ""
        container:SetHandler("OnMouseEnter", function(control)
            if control.tooltipText and control.tooltipText ~= "" then
                InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOP)
                SetTooltipText(InformationTooltip, control.tooltipText)
            end
        end)
        container:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)
        -- Pass drag events through to the parent window so the whole
        -- element remains draggable even when clicking on an icon.
        container:SetHandler("OnMouseDown", function(_, button)
            win:StartMoving()
        end)
        container:SetHandler("OnMouseUp", function(_, button, upInside)
            win:StopMovingOrResizing()
            -- Forward left-click to the window's own handler for the context menu
            if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
                local handler = win:GetHandler("OnMouseUp")
                if handler then handler(win, button, upInside) end
            end
        end)

        return { container = container, texture = tex, timer = timer }
    end

    local foodSlot = createConsumableSlot(Indicator.DEFAULT_FOOD_ICON)
    local apSlot   = createConsumableSlot(Indicator.DEFAULT_AP_ICON)
    local xpSlot   = createConsumableSlot(Indicator.DEFAULT_XP_ICON)

    -- ── Click handler — context menu ────────────────────────────────
    win:SetHandler("OnMouseUp", function(control, button, upInside)
        if button == MOUSE_BUTTON_INDEX_LEFT and upInside then
            ClearMenu()
            AddMenuItem("Show Group Warnings", function()
                zo_callLater(function()
                    local CWP = Beltalowda.UI.CompositionWarningsPanel
                    if CWP then
                        CWP.Toggle(control)
                        Indicator.SetControlVisibility()
                    end
                end, 100)
            end)
            AddMenuItem("Show Group Composition", function()
                zo_callLater(function()
                    local GCP = Beltalowda.UI.GroupCompositionPanel
                    if GCP then GCP.Toggle(control) end
                end, 100)
            end)
            AddMenuItem("Configure Preferences", function()
                zo_callLater(function()
                    if LibAddonMenu2 and BeltalowdaCompositionPanel then
                        LibAddonMenu2:OpenToPanel(BeltalowdaCompositionPanel)
                    end
                end, 100)
            end)
            ShowMenu(control)
        end
    end)

    -- Save position on drag stop
    win:SetHandler("OnMoveStop", function(control)
        Indicator.settings.positionX = control:GetLeft()
        Indicator.settings.positionY = control:GetTop()
        Indicator.SaveSettings()
    end)

    -- General tooltip on the window itself
    win:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMLEFT)
        SetTooltipText(InformationTooltip, "Group Composition")
        InformationTooltip:AddLine("Click to view the composition of the current group (including gear and important buffs), and warnings generated from that composition (based on user preferences).", "", 0.8, 0.8, 0.8)
    end)

    win:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    Indicator.controls = {
        window = win,
        alertIcon = alertIcon,
        label = lbl,
        icon = alertIcon,  -- legacy alias
        food = foodSlot,
        ap   = apSlot,
        xp   = xpSlot,
    }
end

-- ============================================================================
-- Update the full display: consumable icons + warning state
-- ============================================================================

function Indicator.UpdateDisplay()
    if not Indicator.controls then return end

    -- ── Gather warning data ─────────────────────────────────────────
    -- Re-analyze composition every N ticks so consumable warnings stay current
    -- without running the full gear/set analysis every second.
    Indicator.analysisTick = (Indicator.analysisTick or 0) + 1
    if Indicator.analysisTick >= Indicator.ANALYSIS_INTERVAL then
        Indicator.analysisTick = 0
        if Beltalowda.Composition and Beltalowda.Composition.AnalyzeComposition then
            Beltalowda.Composition.AnalyzeComposition()
        end
    end

    local hasWarnings = false
    local severity = nil
    local warningCount = 0
    if Beltalowda.Composition then
        hasWarnings, warningCount = Beltalowda.Composition.HasWarnings()
        severity = Beltalowda.Composition.GetHighestSeverity()
    end

    -- ── Gather consumable data ──────────────────────────────────────
    local CT = Beltalowda.Data and Beltalowda.Data.ConsumableTracker
    local localName = GetUnitName("player")
    local cData = CT and CT.GetPlayerConsumableData and CT.GetPlayerConsumableData(localName)
    local foodRemain = cData and cData.foodRemain or 0
    local apRemain   = cData and cData.apRemain   or 0
    local xpRemain   = cData and cData.xpRemain   or 0

    -- ── Update consumable icons / textures ──────────────────────────
    local function updateSlot(slot, remain, threshold, defaultIcon, settingKey, abilityIdField)
        if not Indicator.settings[settingKey] then
            slot.container:SetHidden(true)
            slot.timer:SetHidden(true)
            return
        end

        -- Determine icon from active ability ID
        local iconPath = defaultIcon
        if CT and CT.localState and CT.localState[abilityIdField] then
            local actualIcon = GetAbilityIcon(CT.localState[abilityIdField])
            if actualIcon and actualIcon ~= "" then iconPath = actualIcon end
        end
        slot.texture:SetTexture(iconPath)

        if remain > 0 then
            slot.container:SetHidden(false)
            slot.texture:SetColor(1, 1, 1, 1)

            -- Timer: show only when nearing expiration
            if remain <= threshold then
                slot.timer:SetText(FormatTime(remain))
                slot.timer:SetHidden(false)
            else
                slot.timer:SetText("")
                slot.timer:SetHidden(true)
            end

            -- Tooltip
            local buffName = nil
            if CT and CT.localState and CT.localState[abilityIdField] then
                buffName = GetAbilityName(CT.localState[abilityIdField])
            end
            if not buffName or buffName == "" then
                if settingKey == "showFood" then buffName = "Food/Drink"
                elseif settingKey == "showAP" then buffName = "AP Buff"
                else buffName = "XP Buff" end
            end
            slot.container.tooltipText = string.format("%s \226\128\148 %s remaining", buffName, FormatTimeLong(remain))
        else
            if settingKey == "showFood" then
                -- Food is mandatory — hide icon, show red warning text only
                slot.container:SetHidden(true)
                slot.timer:SetText("No food or drink buff active")
                slot.timer:SetHidden(false)
                slot.container.tooltipText = ""
            else
                -- AP/XP are optional — hide when no buff
                slot.container:SetHidden(true)
                slot.timer:SetHidden(true)
            end
        end
    end

    updateSlot(Indicator.controls.food, foodRemain, Indicator.FOOD_CRITICAL_THRESHOLD,
        Indicator.DEFAULT_FOOD_ICON, "showFood", "foodAbilityId")
    updateSlot(Indicator.controls.ap, apRemain, Indicator.BUFF_CRITICAL_THRESHOLD,
        Indicator.DEFAULT_AP_ICON, "showAP", "apAbilityId")
    updateSlot(Indicator.controls.xp, xpRemain, Indicator.BUFF_CRITICAL_THRESHOLD,
        Indicator.DEFAULT_XP_ICON, "showXP", "xpAbilityId")

    -- ── Layout ──────────────────────────────────────────────────────
    Indicator.LayoutButton(hasWarnings, warningCount, severity)

    -- ── Refresh sub-panels if open ──────────────────────────────────
    if Beltalowda.UI.CompositionWarningsPanel
        and Beltalowda.UI.CompositionWarningsPanel.state
        and Beltalowda.UI.CompositionWarningsPanel.state.visible then
        Beltalowda.UI.CompositionWarningsPanel.Refresh()
    end
end

-- ============================================================================
-- Layout — position all elements and resize the window
-- ============================================================================

function Indicator.LayoutButton(hasWarnings, warningCount, severity)
    local win = Indicator.controls.window
    local lbl = Indicator.controls.label
    local alertIcon = Indicator.controls.alertIcon
    local padH = Indicator.LABEL_PADDING_H
    local iconSz = Indicator.ICON_SIZE
    local consSz = Indicator.CONSUMABLE_ICON_SIZE
    local gap = Indicator.ICON_GAP
    local contentH = Indicator.LABEL_HEIGHT

    -- Build layout from left to right
    local x = padH
    local centerY = math.floor((contentH - consSz) / 2)

    -- Place consumable icons + optional timers
    -- Order: least important (XP) on left → most important (food) on right,
    -- so food is adjacent to the warning count.
    local slots = { Indicator.controls.xp, Indicator.controls.ap, Indicator.controls.food }
    for _, slot in ipairs(slots) do
        local hasIcon = not slot.container:IsHidden()
        local hasTimer = not slot.timer:IsHidden()

        if hasIcon then
            -- Place timer to the LEFT of its icon so it expands outward
            if hasTimer then
                slot.timer:ClearAnchors()
                slot.timer:SetAnchor(TOPLEFT, win, TOPLEFT, x, 0)
                -- Set unconstrained width first so GetTextWidth returns full text width
                slot.timer:SetDimensions(0, contentH)
                local tw = slot.timer:GetTextWidth()
                slot.timer:SetDimensions(tw, contentH)
                x = x + tw + 2
            end

            slot.container:ClearAnchors()
            slot.container:SetAnchor(TOPLEFT, win, TOPLEFT, x, centerY)
            x = x + consSz

            x = x + gap
        elseif hasTimer then
            -- Text only (no icon) — e.g. "No food or drink buff active"
            slot.timer:ClearAnchors()
            slot.timer:SetAnchor(TOPLEFT, win, TOPLEFT, x, 0)
            -- Set unconstrained width first so GetTextWidth returns full text width
            slot.timer:SetDimensions(0, contentH)
            local tw = slot.timer:GetTextWidth()
            slot.timer:SetDimensions(tw, contentH)
            x = x + tw + gap
        end
    end

    -- Warning section
    local alertCenterY = math.floor((contentH - iconSz) / 2)
    if not hasWarnings then
        lbl:SetHidden(true)
        alertIcon:SetTexture(Indicator.NO_WARNINGS_ICON)
        alertIcon:ClearAnchors()
        alertIcon:SetAnchor(TOPLEFT, win, TOPLEFT, x, alertCenterY)
        x = x + iconSz
        lbl:SetColor(1, 1, 1, 1)
    else
        lbl:SetHidden(false)
        alertIcon:SetTexture(Indicator.ALERT_ICON)

        local text = tostring(warningCount)
        lbl:SetText(text)
        lbl:ClearAnchors()
        lbl:SetAnchor(TOPLEFT, win, TOPLEFT, x, alertCenterY)
        local textW = lbl:GetTextWidth()
        lbl:SetDimensions(textW, iconSz)
        x = x + textW + gap

        alertIcon:ClearAnchors()
        alertIcon:SetAnchor(TOPLEFT, win, TOPLEFT, x, alertCenterY)
        x = x + iconSz

        -- Severity colours on label text
        if severity == "high" then
            lbl:SetColor(1, 0.2, 0.2, 1)
        elseif severity == "medium" then
            lbl:SetColor(1, 0.5, 0, 1)
        else
            lbl:SetColor(1, 1, 0, 1)
        end
    end

    x = x + padH
    win:SetDimensions(x, contentH)

    Indicator.SetControlVisibility()
end

-- ============================================================================
-- Legacy compatibility: UpdateWarningState → UpdateDisplay
-- ============================================================================

Indicator.UpdateWarningState = function()
    Indicator.UpdateDisplay()
end

-- ============================================================================
-- Visibility
-- ============================================================================

function Indicator.SetControlVisibility()
    if not Indicator.controls then return end

    local warningsPanelOpen = Beltalowda.UI.CompositionWarningsPanel
                          and Beltalowda.UI.CompositionWarningsPanel.state.visible
    local compositionPanelOpen = Beltalowda.UI.GroupCompositionPanel
                             and Beltalowda.UI.GroupCompositionPanel.state.visible

    local shouldHide = not Indicator.settings.enabled
                    or Indicator.menuHidden
                    or Indicator.pvpHidden

    Indicator.controls.window:SetHidden(shouldHide)

    if not Indicator.settings.enabled then
        if warningsPanelOpen then
            Beltalowda.UI.CompositionWarningsPanel.Hide()
        end
        if compositionPanelOpen then
            Beltalowda.UI.GroupCompositionPanel.Hide()
        end
    end
end

-- ============================================================================
-- Enable / Disable
-- ============================================================================

function Indicator.SetEnabled(value)
    Indicator.settings.enabled = value
    Indicator.SaveSettings()
    Indicator.SetControlVisibility()
end

-- ============================================================================
-- Toggle (legacy compat)
-- ============================================================================

function Indicator.Toggle()
    Indicator.SetEnabled(not Indicator.settings.enabled)
end

-- ============================================================================
-- Settings Controls (appended to main Beltalowda settings panel)
-- ============================================================================

function Indicator.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFWarnings|r |t24:24:/esoui/art/icons/ability_thievesguild_passive_002.dds|t",
            tooltip = "A draggable element showing the group composition warning count and consumable buff icons. Click to toggle the warning detail panel.",
            controls = {
                {
                    type = "description",
                    text = "Displays a draggable element showing the group composition warning count and your active consumable buff icons. When a consumable is nearing expiration, a red countdown timer appears to the left of its icon. When no food or drink buff is active, a red warning text is shown instead. Hover a consumable icon for the buff name and time remaining. Click the element to open the composition or warnings panels.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Warnings Tracker",
                    tooltip = "Show the composition warning indicator and consumable icons on-screen",
                    getFunc = function() return Indicator.settings.enabled end,
                    setFunc = function(value) Indicator.SetEnabled(value) end,
                    width = "full",
                    default = true,
                },
                {
                    type = "header",
                    name = "Consumable Display",
                },
                {
                    type = "checkbox",
                    name = "Show Food/Drink",
                    tooltip = "Show an icon for your active food or drink buff. When missing, a red warning text is displayed instead.",
                    getFunc = function() return Indicator.settings.showFood end,
                    setFunc = function(value)
                        Indicator.settings.showFood = value
                        Indicator.SaveSettings()
                        Indicator.UpdateDisplay()
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Show AP Buff",
                    tooltip = "Show an icon when you have an Alliance Point buff active (War Tortes, etc.). Hidden when no buff.",
                    getFunc = function() return Indicator.settings.showAP end,
                    setFunc = function(value)
                        Indicator.settings.showAP = value
                        Indicator.SaveSettings()
                        Indicator.UpdateDisplay()
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Show XP Buff",
                    tooltip = "Show an icon when you have an Experience buff active (Psijic Ambrosia, Crown Scrolls, etc.). Hidden when no buff.",
                    getFunc = function() return Indicator.settings.showXP end,
                    setFunc = function(value)
                        Indicator.settings.showXP = value
                        Indicator.SaveSettings()
                        Indicator.UpdateDisplay()
                    end,
                    width = "full",
                    default = true,
                },
            },
        },
    }
end
