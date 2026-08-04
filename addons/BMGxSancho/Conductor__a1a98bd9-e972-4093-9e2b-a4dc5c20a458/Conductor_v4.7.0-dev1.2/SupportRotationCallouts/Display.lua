local SRC = SupportRotationCallouts
SRC.Display = SRC.Display or {}
local Display = SRC.Display
local WM = WINDOW_MANAGER

-- Production visual language. These values affect presentation only; combat
-- state, event handling, rotations, and assignments remain unchanged.
local UI = {
    PANEL_WIDTH = 540,
    PANEL_PADDING = 12,
    HEADER_HEIGHT = 42,
    ROTATION_ROW_WIDTH = 516,
    ROTATION_ROW_HEIGHT = 68,
    ROTATION_ROW_STEP = 72,
    ROTATION_BAR_WIDTH = 500,
    ROTATION_BAR_HEIGHT = 8,
    EFFECT_PANEL_WIDTH = 500,
    EFFECT_ROW_WIDTH = 476,
    EFFECT_ROW_HEIGHT = 82,
    EFFECT_ROW_STEP = 86,
    EFFECT_BAR_WIDTH = 460,
    EFFECT_BAR_HEIGHT = 10,
}

local THEME = {
    PANEL = { 0.012, 0.016, 0.024, 0.90 },
    PANEL_EDGE = { 0.78, 0.58, 0.16, 0.70 },
    CARD = { 0.035, 0.043, 0.060, 0.88 },
    CARD_EDGE = { 0.74, 0.56, 0.20, 0.22 },
    GOLD = { 0.95, 0.73, 0.22, 1 },
    WARM_WHITE = { 0.94, 0.93, 0.89, 1 },
    MUTED = { 0.66, 0.68, 0.72, 1 },
    TRACK = { 0.065, 0.075, 0.095, 0.96 },
}

local ROLE_LEAD = "lead"
local ROLE_SUPPORT = "support"
local ROLE_DD = "dd"
local DASHBOARD_BACKDROPS = {}

local function DashboardVisibilityAllows()
    -- Explicit settings previews may temporarily bypass the master switch.
    if Display and Display.previewVisibilityOverride then return true end
    if not SRC.saved or SRC.saved.enabled ~= true then return false end
    local mode = SRC.saved.dashboardVisibility or "combat"
    if mode == "never" then return false end
    if mode == "always" then return true end
    return SRC.inCombat == true
end

local MODULE_ORDER = { "COLOSSUS", "WARHORN", "BARRIER", "NAZARAY", "SLAYER", "PILLAGER" }
local LEGACY_EFFECT_KEYS = {
    MAJOR_SLAYER = "SLAYER_BUFF",
    MAJOR_BRITTLE = "BRITTLE",
}

local function GetConfiguredEffectOrder()
    local groups = { BUFF_TIMER={}, BUFF_COUNT={}, DEBUFF_TIMER={}, DEBUFF_COUNT={} }
    if not Conductor or not Conductor.Registry then return groups end
    for _, effect in ipairs(Conductor.Registry:GetAll("EFFECTS") or {}) do
        if (effect.effectType == "BUFF" or effect.effectType == "DEBUFF")
            and Conductor.TrackingConfiguration
            and Conductor.TrackingConfiguration:IsEffectEnabled(effect.key) then
            local groupKey = effect.effectType .. "_" .. (effect.dashboardMode or "COUNT")
            groups[groupKey][#groups[groupKey]+1] = effect
        end
    end
    for _, entries in pairs(groups) do
        table.sort(entries, function(a,b) return tostring(a.name or a.key) < tostring(b.name or b.key) end)
    end
    return groups
end
local ALL_MODULE_ORDER = {
    "COLOSSUS", "WARHORN", "BARRIER", "NAZARAY", "SLAYER", "PILLAGER",
    "SLAYER_BUFF", "BRITTLE", "MINOR_COURAGE", "MAJOR_RESOLVE", "POWERFUL_ASSAULT",
}


local MODULE_ENABLED_KEYS = {
    COLOSSUS = "colossusEnabled",
    WARHORN = "warhornEnabled",
    BARRIER = "barrierEnabled",
    NAZARAY = "nazarayEnabled",
    PILLAGER = "pillagerEnabled",
    SLAYER = "majorSlayerEnabled",
    BRITTLE = "majorBrittleTrackingEnabled",
    MINOR_COURAGE = "minorCourageTrackingEnabled",
    MAJOR_RESOLVE = "majorResolveTrackingEnabled",
    POWERFUL_ASSAULT = "powerfulAssaultTrackingEnabled",
    SLAYER_BUFF = "majorSlayerEnabled",
}

local function IsModuleEnabled(key)
    local setting = MODULE_ENABLED_KEYS[key]
    return setting == nil or SRC.saved[setting] == true
end
local MODULE_LABELS = {
    COLOSSUS = "COLOSSUS",
    WARHORN = "HORN",
    BARRIER = "BARRIER",
    NAZARAY = "NAZ EXTEND",
    SLAYER = "SLAYER",
    PILLAGER = "PILLAGER",
    BRITTLE = "BRITTLE",
    MINOR_COURAGE = "MINOR COURAGE",
    MAJOR_RESOLVE = "MAJOR RESOLVE",
    POWERFUL_ASSAULT = "POWERFUL ASSAULT",
    SLAYER_BUFF = "SLAYER",
}

local CALLOUT_COLORS = {
    white = { 1, 1, 1, 1 },
    gold = { 1, 0.82, 0.1, 1 },
    red = { 1, 0.22, 0.18, 1 },
    cyan = { 0.25, 0.85, 1, 1 },
    green = { 0.35, 1, 0.4, 1 },
}

local ALIGNMENTS = {
    left = TEXT_ALIGN_LEFT,
    center = TEXT_ALIGN_CENTER,
    right = TEXT_ALIGN_RIGHT,
}

local function SplitCalloutNames(value)
    if type(value) == "table" then
        local out = {}
        for _, name in ipairs(value) do
            if name and name ~= "" then out[#out + 1] = tostring(name) end
            if #out >= 2 then break end
        end
        return out
    end

    local text = tostring(value or "")
    local out = {}
    for part in string.gmatch(text, "[^|\n]+") do
        local trimmed = zo_strtrim(part)
        if trimmed ~= "" then out[#out + 1] = trimmed end
        if #out >= 2 then break end
    end
    return out
end

local function Normalize(name)
    return SRC:NormalizeAccountName(name or "")
end

local function IsLocalAccount(accountName)
    return Normalize(accountName) ~= "" and Normalize(accountName) == Normalize(GetDisplayName())
end

local function ShowsLead()
    return (SRC.saved.displayRole or ROLE_LEAD) == ROLE_LEAD
end

local function ShowsRotationDashboard()
    return false
end

local function ShowsPersonalDashboard()
    local role = SRC.saved.displayRole or ROLE_LEAD
    return SRC.saved.personalAssignmentsEnabled ~= false and SRC.saved.calloutsEnabled ~= false and (role == ROLE_LEAD or role == ROLE_SUPPORT)
end

local function ShowsDamageDealerDashboard()
    local role = SRC.saved.displayRole or ROLE_LEAD
    return SRC.saved.calloutsEnabled ~= false and (role == ROLE_LEAD or role == ROLE_DD)
end

local function CreateBackdrop(parent, alpha)
    local bg = WM:CreateControl(nil, parent, CT_BACKDROP)
    bg:SetAnchorFill()
    bg._conductorBaseAlpha = alpha or 1
    local opacity = SRC.saved and SRC.saved.dashboardBackgroundOpacity or 0.38
    bg:SetCenterColor(THEME.PANEL[1], THEME.PANEL[2], THEME.PANEL[3], zo_clamp(opacity * bg._conductorBaseAlpha, 0.05, 0.95))
    bg:SetEdgeColor(unpack(THEME.PANEL_EDGE))
    bg:SetEdgeTexture(nil, 2, 2, 2)
    DASHBOARD_BACKDROPS[#DASHBOARD_BACKDROPS + 1] = bg
    return bg
end

local function CreateCardBackdrop(parent)
    local bg = WM:CreateControl(nil, parent, CT_BACKDROP)
    bg:SetAnchorFill()
    bg._conductorBaseAlpha = 1.18
    local opacity = SRC.saved and SRC.saved.dashboardBackgroundOpacity or 0.38
    bg:SetCenterColor(THEME.CARD[1], THEME.CARD[2], THEME.CARD[3], zo_clamp(opacity * bg._conductorBaseAlpha, 0.08, 0.95))
    bg:SetEdgeColor(unpack(THEME.CARD_EDGE))
    bg:SetEdgeTexture(nil, 1, 1, 1)
    DASHBOARD_BACKDROPS[#DASHBOARD_BACKDROPS + 1] = bg
    return bg
end

local function CreateHeaderAccent(parent, width)
    local line = WM:CreateControl(nil, parent, CT_TEXTURE)
    line:SetAnchor(TOPLEFT, parent, TOPLEFT, UI.PANEL_PADDING, UI.HEADER_HEIGHT - 4)
    line:SetDimensions(width, 2)
    line:SetColor(unpack(THEME.GOLD))
    return line
end

local function CreateLabel(parent, font, color)
    local label = WM:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font)
    label:SetColor(unpack(color or { 1, 1, 1, 1 }))
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function StatusText(info)
    if not info then return "--" end
    if info.statusText and info.statusText ~= "" then return info.statusText end
    if info.remaining and info.remaining > 0 then return string.format("%.1f", info.remaining) end
    if info.state == SRC.GroupStats.READY then return "READY" end
    if info.percent ~= nil then return tostring(info.percent) .. "%" end
    return "WAIT"
end


local DEFAULT_ASSIGNMENT_MAP = {
    COLOSSUS = { countKey = "rotationCount", rotationKey = "rotation" },
    WARHORN = { countKey = "warhornRotationCount", rotationKey = "warhornRotation" },
    BARRIER = { countKey = "barrierRotationCount", rotationKey = "barrierRotation" },
    NAZARAY = { countKey = "nazarayRotationCount", rotationKey = "nazarayRotation" },
    PILLAGER = { countKey = "pillagerRotationCount", rotationKey = "pillagerRotation" },
}

local function FirstTwoAssignments(map)
    if not map then return "", "" end
    local rotation = SRC.saved[map.rotationKey] or {}
    local count = zo_clamp(tonumber(SRC.saved[map.countKey]) or 1, 1, 4)
    local found = {}
    for index = 1, count do
        local account = Normalize(rotation[index] or "")
        if account ~= "" then found[#found + 1] = account end
        if #found >= 2 then break end
    end
    return found[1] or "", found[2] or ""
end
local function AccountText(account)
    if not account or account == "" then return "WAITING" end
    if IsLocalAccount(account) then return "YOU" end
    return account
end

function Display:SaveCenteredPosition(control, xKey, yKey)
    if not control or not SRC.saved then return false end
    local centerX, centerY = control:GetCenter()
    if not centerX or not centerY then return false end
    local rootCenterX, rootCenterY = GuiRoot:GetCenter()
    if not rootCenterX or not rootCenterY then
        rootCenterX = (GuiRoot:GetWidth() or 1920) / 2
        rootCenterY = (GuiRoot:GetHeight() or 1080) / 2
    end
    SRC.saved[xKey] = centerX - rootCenterX
    SRC.saved[yKey] = centerY - rootCenterY
    return true
end

function Display:CaptureWindowPositions()
    self:SaveCenteredPosition(self.dashboard, "offsetX", "offsetY")
    self:SaveCenteredPosition(self.effectsDashboard, "buffsDebuffsOffsetX", "buffsDebuffsOffsetY")
    self:SaveCenteredPosition(self.personal, "personalOffsetX", "personalOffsetY")
    self:SaveCenteredPosition(self.callout, "calloutOffsetX", "calloutOffsetY")
    self:SaveCenteredPosition(self.ddCallout, "damageDealerOffsetX", "damageDealerOffsetY")
end

function Display:Initialize()
    self.states = {}
    self.buffDebuffStates = {}

    local dashboard = WM:CreateTopLevelWindow("SupportRotationCalloutsDashboard")
    dashboard:SetDimensions(UI.PANEL_WIDTH, 400)
    dashboard:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.offsetX, SRC.saved.offsetY)
    dashboard:SetMouseEnabled(true)
    dashboard:SetMovable(true)
    dashboard:SetHandler("OnMoveStop", function(control)
        Display:SaveCenteredPosition(control, "offsetX", "offsetY")
    end)
    dashboard:SetClampedToScreen(false)
    dashboard:SetScale(SRC.saved.scale)
    dashboard:SetHidden(true)
    CreateBackdrop(dashboard, 1.0)

    local title = CreateLabel(dashboard, "$(BOLD_FONT)|22|outline", THEME.GOLD)
    title:SetAnchor(TOPLEFT, dashboard, TOPLEFT, UI.PANEL_PADDING, 6)
    title:SetAnchor(TOPRIGHT, dashboard, TOPRIGHT, -UI.PANEL_PADDING, 6)
    title:SetHeight(30)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetText("ROTATION DASHBOARD")
    CreateHeaderAccent(dashboard, UI.ROTATION_ROW_WIDTH)
    title:SetHidden(SRC.saved.dashboardShowTitle == false)

    self.dashboard = dashboard
    if C and C.WindowController then C.WindowController:Register("TIMELINE", dashboard) end
    self.dashboardTitle = title
    self.rows = {}

    for index, key in ipairs(MODULE_ORDER) do
        local row = WM:CreateControl("SupportRotationCalloutsDashboard" .. key, dashboard, CT_CONTROL)
        row:SetDimensions(UI.ROTATION_ROW_WIDTH, UI.ROTATION_ROW_HEIGHT)
        row:SetAnchor(TOPLEFT, dashboard, TOPLEFT, UI.PANEL_PADDING, 10 + ((index - 1) * UI.ROTATION_ROW_STEP))
        row:SetHidden(true)
        CreateCardBackdrop(row)

        local accent = WM:CreateControl(nil, row, CT_TEXTURE)
        accent:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
        accent:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 0, 0)
        accent:SetWidth(3)
        accent:SetColor(unpack(THEME.GOLD))

        local progressBackground = WM:CreateControl(nil, row, CT_TEXTURE)
        progressBackground:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 8, -7)
        progressBackground:SetDimensions(UI.ROTATION_BAR_WIDTH, UI.ROTATION_BAR_HEIGHT)
        progressBackground:SetColor(unpack(THEME.TRACK))

        local progressFill = WM:CreateControl(nil, row, CT_TEXTURE)
        progressFill:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 8, -7)
        progressFill:SetDimensions(1, UI.ROTATION_BAR_HEIGHT)
        progressFill:SetColor(0.85, 0.12, 0.1, 0.95)

        local separator = WM:CreateControl(nil, row, CT_TEXTURE)
        separator:SetAnchor(TOPLEFT, row, TOPLEFT, 8, 0)
        separator:SetAnchor(TOPRIGHT, row, TOPRIGHT, -8, 0)
        separator:SetHeight(1)
        separator:SetColor(1, 0.78, 0.25, 0.10)

        local module = CreateLabel(row, "$(BOLD_FONT)|19|outline", THEME.GOLD)
        module:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 4)
        module:SetDimensions(138, 27)
        module:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        module:SetText(MODULE_LABELS[key] or key)

        local nextPrefix = CreateLabel(row, "$(BOLD_FONT)|14|outline", THEME.MUTED)
        nextPrefix:SetAnchor(TOPLEFT, row, TOPLEFT, 150, 3)
        nextPrefix:SetDimensions(48, 27)
        nextPrefix:SetText("NEXT")

        local nextName = CreateLabel(row, "$(BOLD_FONT)|20|outline", THEME.WARM_WHITE)
        nextName:SetAnchor(LEFT, nextPrefix, RIGHT, 4, 0)
        nextName:SetDimensions(220, 27)
        nextName:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

        local nextStatus = CreateLabel(row, "$(BOLD_FONT)|20|outline", THEME.WARM_WHITE)
        nextStatus:SetAnchor(TOPRIGHT, row, TOPRIGHT, -10, 3)
        nextStatus:SetDimensions(105, 27)
        nextStatus:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

        local afterPrefix = CreateLabel(row, "$(BOLD_FONT)|13|outline", THEME.MUTED)
        afterPrefix:SetAnchor(TOPLEFT, row, TOPLEFT, 150, 30)
        afterPrefix:SetDimensions(48, 25)
        afterPrefix:SetText("AFTER")

        local afterName = CreateLabel(row, "$(BOLD_FONT)|16|outline", THEME.MUTED)
        afterName:SetAnchor(LEFT, afterPrefix, RIGHT, 4, 0)
        afterName:SetDimensions(220, 25)
        afterName:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

        local afterStatus = CreateLabel(row, "$(BOLD_FONT)|16|outline", THEME.MUTED)
        afterStatus:SetAnchor(TOPRIGHT, row, TOPRIGHT, -10, 30)
        afterStatus:SetDimensions(105, 25)
        afterStatus:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

        self.rows[key] = {
            control = row,
            module = module,
            nextName = nextName,
            nextStatus = nextStatus,
            afterName = afterName,
            afterStatus = afterStatus,
            progressBackground = progressBackground,
            progressFill = progressFill,
        }
    end

    -- Buffs & Debuffs is intentionally separate from the rotation dashboard.
    -- Rotation rows answer “who acts next”; this panel answers “what is up”.
    local effectsDashboard = WM:CreateTopLevelWindow("SupportRotationCalloutsBuffsDebuffs")
    effectsDashboard:SetDimensions(UI.EFFECT_PANEL_WIDTH, 320)
    effectsDashboard:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.buffsDebuffsOffsetX or 430, SRC.saved.buffsDebuffsOffsetY or -120)
    effectsDashboard:SetMouseEnabled(SRC.saved.windowsLocked ~= true)
    effectsDashboard:SetMovable(SRC.saved.windowsLocked ~= true)
    effectsDashboard:SetHandler("OnMoveStop", function(control)
        Display:SaveCenteredPosition(control, "buffsDebuffsOffsetX", "buffsDebuffsOffsetY")
    end)
    effectsDashboard:SetClampedToScreen(false)
    effectsDashboard:SetScale(SRC.saved.buffsDebuffsScale or 0.9)
    effectsDashboard:SetHidden(true)
    CreateBackdrop(effectsDashboard, 1.0)

    local effectsTitle = CreateLabel(effectsDashboard, "$(BOLD_FONT)|22|outline", THEME.GOLD)
    effectsTitle:SetAnchor(TOPLEFT, effectsDashboard, TOPLEFT, UI.PANEL_PADDING, 6)
    effectsTitle:SetAnchor(TOPRIGHT, effectsDashboard, TOPRIGHT, -UI.PANEL_PADDING, 6)
    effectsTitle:SetHeight(30)
    effectsTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    effectsTitle:SetText("BUFFS & DEBUFFS")
    CreateHeaderAccent(effectsDashboard, UI.EFFECT_ROW_WIDTH)
    effectsTitle:SetHidden(SRC.saved.buffsDebuffsShowTitle == false)

    self.effectsDashboard = effectsDashboard
    if C and C.WindowController then C.WindowController:Register("BUFFS_DEBUFFS", effectsDashboard) end
    self.effectsTitle = effectsTitle
    self.effectRows = {}

    self.effectSectionHeaders = {}

    function self:EnsureEffectRow(effect)
        local key = effect.key
        if self.effectRows[key] then return self.effectRows[key] end
        local row = WM:CreateControl("SupportRotationCalloutsEffect" .. key, effectsDashboard, CT_CONTROL)
        row:SetDimensions(UI.EFFECT_ROW_WIDTH, UI.EFFECT_ROW_HEIGHT)
        row:SetHidden(true)
        CreateCardBackdrop(row)

        local accent = WM:CreateControl(nil, row, CT_TEXTURE)
        accent:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
        accent:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 0, 0)
        accent:SetWidth(3)
        accent:SetColor(THEME.GOLD[1], THEME.GOLD[2], THEME.GOLD[3], 0.9)

        local label = CreateLabel(row, "$(BOLD_FONT)|15|outline", THEME.WARM_WHITE)
        label:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 6)
        label:SetDimensions(270, 22)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetText(zo_strupper(effect.name or key))

        local status = CreateLabel(row, "$(BOLD_FONT)|16|outline", THEME.GOLD)
        status:SetAnchor(TOPRIGHT, row, TOPRIGHT, -10, 5)
        status:SetDimensions(150, 24)
        status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        status:SetText("DOWN")

        local count = CreateLabel(row, "$(BOLD_FONT)|14|outline", THEME.WARM_WHITE)
        count:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 29)
        count:SetDimensions(130, 20)
        count:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        count:SetHidden(true)

        local missing = CreateLabel(row, "$(BOLD_FONT)|13|outline", { 1, 0.22, 0.18, 1 })
        missing:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 49)
        missing:SetDimensions(UI.EFFECT_ROW_WIDTH - 20, 19)
        missing:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        missing:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        missing:SetHidden(true)

        local barBackground = WM:CreateControl(nil, row, CT_TEXTURE)
        barBackground:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 9, -7)
        barBackground:SetDimensions(UI.EFFECT_BAR_WIDTH, UI.EFFECT_BAR_HEIGHT)
        barBackground:SetColor(THEME.TRACK[1], THEME.TRACK[2], THEME.TRACK[3], THEME.TRACK[4])

        local barFill = WM:CreateControl(nil, barBackground, CT_TEXTURE)
        barFill:SetAnchor(TOPLEFT, barBackground, TOPLEFT, 0, 0)
        barFill:SetDimensions(1, UI.EFFECT_BAR_HEIGHT)
        barFill:SetColor(0.88, 0.12, 0.1, 0.96)

        local blocks = {}
        for blockIndex = 1, 12 do
            local block = WM:CreateControl(nil, row, CT_TEXTURE)
            block:SetDimensions(31, 10)
            block:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 10 + ((blockIndex - 1) * 38), -7)
            block:SetColor(0.22, 0.22, 0.22, 0.78)
            block:SetHidden(true)
            blocks[blockIndex] = block
        end

        local result = { control=row, label=label, status=status, count=count, missing=missing, barBackground=barBackground, barFill=barFill, blocks=blocks, effect=effect }
        self.effectRows[key] = result
        local legacy = LEGACY_EFFECT_KEYS[key]
        if legacy then self.effectRows[legacy] = result end
        return result
    end

    function self:EnsureEffectSectionHeader(sectionKey, labelText)
        local header = self.effectSectionHeaders[sectionKey]
        if header then return header end
        header = CreateLabel(effectsDashboard, "$(BOLD_FONT)|15|outline", THEME.GOLD)
        header:SetDimensions(UI.EFFECT_ROW_WIDTH, 24)
        header:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        header:SetText(labelText)
        self.effectSectionHeaders[sectionKey] = header
        return header
    end

    -- Personal support alert. This only appears when the local player owns the
    -- active callout. It remains separate from the planning dashboard.
    local personal = WM:CreateTopLevelWindow("SupportRotationCalloutsPersonalAlert")
    personal:SetDimensions(390, 145)
    personal:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.personalOffsetX, SRC.saved.personalOffsetY)
    personal:SetMouseEnabled(false)
    personal:SetMovable(false)
    personal:SetClampedToScreen(false)
    personal:SetScale(SRC.saved.personalScale)
    personal:SetHidden(true)
    CreateBackdrop(personal, 1.0)
    CreateHeaderAccent(personal, 366)

    local personalHeading = CreateLabel(personal, "$(BOLD_FONT)|20|outline", THEME.MUTED)
    personalHeading:SetAnchor(TOPLEFT, personal, TOPLEFT, 8, 8)
    personalHeading:SetAnchor(TOPRIGHT, personal, TOPRIGHT, -8, 8)
    personalHeading:SetHeight(28)
    personalHeading:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local personalAction = CreateLabel(personal, "$(BOLD_FONT)|31|outline", THEME.GOLD)
    personalAction:SetAnchor(TOPLEFT, personalHeading, BOTTOMLEFT, 0, 3)
    personalAction:SetAnchor(TOPRIGHT, personalHeading, BOTTOMRIGHT, 0, 3)
    personalAction:SetHeight(42)
    personalAction:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local personalStatus = CreateLabel(personal, "$(BOLD_FONT)|45|outline", { 1, 1, 1, 1 })
    personalStatus:SetAnchor(TOPLEFT, personalAction, BOTTOMLEFT, 0, 0)
    personalStatus:SetAnchor(BOTTOMRIGHT, personal, BOTTOMRIGHT, -8, -8)
    personalStatus:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    self.personal = personal
    self.personalHeading = personalHeading
    self.personalAction = personalAction
    self.personalStatus = personalStatus

    -- Trial-lead execution text. No permanent background or frame.
    -- Vertical, name-first presentation is the default because it matches
    -- ESO alert language and gives raid leads more placement freedom.
    local callout = WM:CreateTopLevelWindow("SupportRotationCalloutsLeadCallout")
    callout:SetDimensions(560, 240)
    callout:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.calloutOffsetX or 0, SRC.saved.calloutOffsetY or -80)
    callout:SetMouseEnabled(false)
    callout:SetMovable(false)
    callout:SetClampedToScreen(true)
    callout:SetScale(SRC.saved.calloutScale or 1.0)
    callout:SetHidden(true)

    local calloutName1 = CreateLabel(callout, "$(BOLD_FONT)|48|thick-outline", CALLOUT_COLORS[SRC.saved.calloutColor or "gold"])
    local calloutName2 = CreateLabel(callout, "$(BOLD_FONT)|48|thick-outline", CALLOUT_COLORS[SRC.saved.calloutColor or "gold"])
    local calloutAction = CreateLabel(callout, "$(BOLD_FONT)|34|thick-outline", { 1, 1, 1, 1 })
    local calloutCombined = CreateLabel(callout, "$(BOLD_FONT)|44|thick-outline", CALLOUT_COLORS[SRC.saved.calloutColor or "gold"])

    for _, label in ipairs({ calloutName1, calloutName2, calloutAction, calloutCombined }) do
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end

    self.callout = callout
    self.calloutName1 = calloutName1
    self.calloutName2 = calloutName2
    self.calloutAction = calloutAction
    self.calloutCombined = calloutCombined
    self:ApplyCalloutLayout()

    -- Damage Dealer burn-window display. It has independent placement and scale
    -- so DDs can position shared encounter guidance without moving Trial Lead callouts.
    local ddCallout = WM:CreateTopLevelWindow("SupportRotationCalloutsDamageDealerCallout")
    ddCallout:SetDimensions(720, 180)
    ddCallout:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.damageDealerOffsetX or 0, SRC.saved.damageDealerOffsetY or -80)
    ddCallout:SetMouseEnabled(false)
    ddCallout:SetMovable(false)
    ddCallout:SetClampedToScreen(false)
    ddCallout:SetScale(SRC.saved.damageDealerScale or 1.0)
    ddCallout:SetHidden(true)

    local ddText = CreateLabel(ddCallout, "$(BOLD_FONT)|46|thick-outline", CALLOUT_COLORS.gold)
    ddText:SetAnchorFill(ddCallout)
    ddText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ddText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ddText:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    self.ddCallout = ddCallout
    self.ddCalloutText = ddText
end

local function PreserveCenteredOffset(offsetX, offsetY, fallbackX, fallbackY)
    local x = tonumber(offsetX)
    local y = tonumber(offsetY)
    if x == nil then x = fallbackX or 0 end
    if y == nil then y = fallbackY or 0 end
    return x, y
end

function Display:ClampSavedDisplayPositions()
    local x, y = PreserveCenteredOffset(SRC.saved.offsetX, SRC.saved.offsetY, 0, -180)
    SRC.saved.offsetX, SRC.saved.offsetY = x, y

    x, y = PreserveCenteredOffset(SRC.saved.buffsDebuffsOffsetX, SRC.saved.buffsDebuffsOffsetY, 430, -120)
    SRC.saved.buffsDebuffsOffsetX, SRC.saved.buffsDebuffsOffsetY = x, y

    x, y = PreserveCenteredOffset(SRC.saved.personalOffsetX, SRC.saved.personalOffsetY, 0, 110)
    SRC.saved.personalOffsetX, SRC.saved.personalOffsetY = x, y

    x, y = PreserveCenteredOffset(SRC.saved.damageDealerOffsetX, SRC.saved.damageDealerOffsetY, 0, -80)
    SRC.saved.damageDealerOffsetX, SRC.saved.damageDealerOffsetY = x, y
end

function Display:ApplySettings()
    local opacity = zo_clamp(tonumber(SRC.saved.dashboardBackgroundOpacity) or 0.38, 0.10, 0.90)
    for _, bg in ipairs(DASHBOARD_BACKDROPS) do
        if bg and bg.SetCenterColor then
            local isCard = bg._conductorBaseAlpha and bg._conductorBaseAlpha > 1
            local color = isCard and THEME.CARD or THEME.PANEL
            bg:SetCenterColor(color[1], color[2], color[3], zo_clamp(opacity * (bg._conductorBaseAlpha or 1), 0.05, 0.95))
        end
    end
    self:ClampSavedDisplayPositions()
    self.dashboard:ClearAnchors()
    self.dashboard:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.offsetX, SRC.saved.offsetY)
    self.dashboard:SetScale(SRC.saved.scale)

    self.effectsDashboard:ClearAnchors()
    self.effectsDashboard:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.buffsDebuffsOffsetX or 430, SRC.saved.buffsDebuffsOffsetY or -120)
    self.effectsDashboard:SetScale(SRC.saved.buffsDebuffsScale or 0.9)

    self.personal:ClearAnchors()
    self.personal:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.personalOffsetX, SRC.saved.personalOffsetY)
    self.personal:SetScale(SRC.saved.personalScale)

    self.callout:ClearAnchors()
    self.callout:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.calloutOffsetX or 0, SRC.saved.calloutOffsetY or -80)
    self.callout:SetScale(SRC.saved.calloutScale or 1.0)

    self.ddCallout:ClearAnchors()
    self.ddCallout:SetAnchor(CENTER, GuiRoot, CENTER, SRC.saved.damageDealerOffsetX or 0, SRC.saved.damageDealerOffsetY or -80)
    self.ddCallout:SetScale(SRC.saved.damageDealerScale or 1.0)
    local color = CALLOUT_COLORS[SRC.saved.calloutColor or "gold"] or CALLOUT_COLORS.gold
    self.calloutName1:SetColor(unpack(color))
    self.calloutName2:SetColor(unpack(color))
    self.calloutCombined:SetColor(unpack(color))
    self.dashboardTitle:SetHidden(SRC.saved.dashboardShowTitle == false)
    self.effectsTitle:SetHidden(SRC.saved.buffsDebuffsShowTitle == false)
    self:ApplyCalloutLayout()

    self:RenderDashboard()
    if not self.buffsDebuffsPreviewActive then self:RenderBuffsDebuffs() end
end


function Display:HideAll()
    self.previewVisibilityOverride = false
    self.buffsDebuffsPreviewActive = false
    local controls = {
        self.dashboard, self.effectsDashboard, self.personal, self.callout,
        self.ddCallout, self.raidHealth, self.pullHealth
    }
    for _, control in ipairs(controls) do
        if control then control:SetHidden(true) end
    end
end

function Display:ApplyMode()
    local visible = DashboardVisibilityAllows()
    if not visible then
        if self.dashboard then self.dashboard:SetHidden(true) end
        if self.effectsDashboard then self.effectsDashboard:SetHidden(true) end
        if self.personal then self.personal:SetHidden(true) end
        return
    end
    if not ShowsPersonalDashboard() then
        self.personal:SetHidden(true)
    elseif self.personal:IsHidden() then
        self:ShowPersonalIdle()
    end
    if not ShowsLead() then self.callout:SetHidden(true) end
    if not ShowsDamageDealerDashboard() and self.ddCallout then self.ddCallout:SetHidden(true) end
    self:RenderDashboard()
    self:RenderBuffsDebuffs()
    if SRC.ColossusRotation and SRC.ColossusRotation.RefreshOpeningDisplay then
        SRC.ColossusRotation:RefreshOpeningDisplay()
    end
end

function Display:GetFollowingColossusPosition(position)
    if not SRC.ColossusRotation or not position then return nil end
    local start = SRC.ColossusRotation:GetNextPosition(position)
    local list = SRC.ColossusRotation:BuildReadinessList()
    return SRC.ColossusRotation:FindNextReadyPosition(start, list) or start
end

function Display:SetColossusState(position, account, remaining, statusText, urgent, opening)
    local previous = self.states.COLOSSUS
    local followingPosition = self:GetFollowingColossusPosition(position)
    local followingAccount = followingPosition and SRC.ColossusRotation:GetAccountAt(followingPosition) or ""
    local followingInfo = followingAccount ~= "" and SRC.GroupStats:GetReadinessInfo(followingAccount) or nil

    self.states.COLOSSUS = {
        label = "COLOSSUS",
        position = position,
        nextAccount = account,
        nextStatusText = statusText,
        remaining = remaining,
        urgent = urgent,
        opening = opening,
        afterPosition = followingPosition,
        afterAccount = followingAccount,
        afterStatusText = StatusText(followingInfo),
        localAssigned = SRC.ColossusRotation:GetConfiguredPosition(GetDisplayName()) ~= nil,
        confirmationAccount = previous and previous.confirmationAccount or nil,
        confirmationUntilMs = previous and previous.confirmationUntilMs or nil,
        confirmationLabel = previous and previous.confirmationLabel or nil,
    }
    self:RenderDashboard()
end

function Display:GetStateProgressPercent(key, state, confirmationActive)
    if confirmationActive or state.active then return 100 end
    if state.urgent then
        local remaining = tonumber(state.remaining) or 0
        if remaining <= 0.5 then return 100 end
        return zo_clamp(((SRC.saved.countdownStart or 3) - remaining) / (SRC.saved.countdownStart or 3) * 100, 0, 99)
    end
    if type(state.percent) == "number" then return zo_clamp(state.percent, 0, 100) end
    local status = tostring(state.nextStatusText or "")
    local parsed = tonumber(string.match(status, "(%d+)%%"))
    if parsed then return zo_clamp(parsed, 0, 100) end
    if status == "READY" or status == "NOW" then return 100 end
    return 0
end

function Display:GetDashboardPriority(key, state)
    if state.urgent then return 5000 end
    local confirmationActive = state.confirmationUntilMs and state.confirmationUntilMs > GetGameTimeMilliseconds()
    if confirmationActive then return 4500 end
    if state.nextStatusText == "READY" or state.state == SRC.GroupStats.READY then return 4000 end
    if state.active then return 3500 end
    return self:GetStateProgressPercent(key, state, false)
end

function Display:SetProgressBar(row, percent, successful)
    percent = zo_clamp(tonumber(percent) or 0, 0, 100)
    row.progressFill:SetDimensions(math.max(1, UI.ROTATION_BAR_WIDTH * (percent / 100)), 5)
    if successful then
        row.progressFill:SetColor(1, 0.72, 0.08, 0.98)
    elseif percent <= 50 then
        row.progressFill:SetColor(0.88, 0.12, 0.1, 0.95)
    elseif percent <= 85 then
        row.progressFill:SetColor(1, 0.72, 0.08, 0.95)
    else
        row.progressFill:SetColor(0.25, 0.9, 0.25, 0.95)
    end
end

function Display:ClearDisabledModuleStates()
    for key in pairs(self.states or {}) do
        if not IsModuleEnabled(key) then
            self.states[key] = nil
            self:HidePersonal(key)
        end
    end
end


function Display:BuildDefaultState(key)
    local map = DEFAULT_ASSIGNMENT_MAP[key]
    local first, second = FirstTwoAssignments(map)
    local info = first ~= "" and SRC.GroupStats and SRC.GroupStats.GetAnyUltimateReadiness and SRC.GroupStats:GetAnyUltimateReadiness(first) or nil
    local status = "WAIT"
    local percent = nil
    local state = nil
    if info then
        state = info.state
        percent = info.percent
        status = StatusText(info)
    end
    if key == "BRITTLE" or key == "MINOR_COURAGE" or key == "MAJOR_RESOLVE" or key == "POWERFUL_ASSAULT" then
        return {
            label = MODULE_LABELS[key] or key,
            nextAccount = key == "BRITTLE" and "NO TARGET" or "0/" .. tostring(math.max(1, GetGroupSize())) .. " COVERED",
            nextStatusText = "DOWN",
            afterAccount = key == "BRITTLE" and "DEBUFF STATUS" or "GROUP COVERAGE",
            afterStatusText = "NEEDS ATTENTION",
            percent = 0,
            localAssigned = true,
            placeholder = true,
        }
    end
    if key == "SLAYER" then
        local assignments = {}
        local function add(list, count)
            for i=1, math.min(tonumber(count) or 0, 2) do
                local account = Normalize((list or {})[i] or "")
                if account ~= "" then assignments[#assignments+1] = account end
            end
        end
        if SRC.saved.roaringOpportunistEnabled then add(SRC.saved.roaringOpportunistRotation, 1) end
        if SRC.saved.masterArchitectEnabled then add(SRC.saved.masterArchitectRotation, SRC.saved.masterArchitectRotationCount) end
        if SRC.saved.warMachineEnabled then add(SRC.saved.warMachineRotation, SRC.saved.warMachineRotationCount) end
        first, second = assignments[1] or "", assignments[2] or ""
        status = "WAIT"
    end
    return {
        label = MODULE_LABELS[key] or key,
        nextAccount = first,
        nextStatusText = status,
        afterAccount = second,
        afterStatusText = second ~= "" and "WAIT" or "--",
        state = state,
        percent = percent,
        localAssigned = IsLocalAccount(first) or IsLocalAccount(second),
        placeholder = true,
    }
end

function Display:EnsureEnabledModuleStates()
    for _, key in ipairs(ALL_MODULE_ORDER) do
        if IsModuleEnabled(key) and not self.states[key] then
            self.states[key] = self:BuildDefaultState(key)
        end
    end
end

function Display:RebuildEnabledModuleStates()
    self:ClearDisabledModuleStates()
    for _, key in ipairs(ALL_MODULE_ORDER) do
        if IsModuleEnabled(key) then
            local existing = self.states[key]
            if not existing or existing.placeholder then self.states[key] = self:BuildDefaultState(key) end
        end
    end
    self:RenderDashboard()
    self:RenderBuffsDebuffs()
end
function Display:RenderDashboard()
    -- Runtime resets can occur during SavedVariables migration before UI controls exist.
    -- Treat an uninitialized display as a valid no-op state.
    if not self.dashboard or not self.rows then return end
    if not DashboardVisibilityAllows() then if self.dashboard then self.dashboard:SetHidden(true) end; return end
    self:ClearDisabledModuleStates()
    self:EnsureEnabledModuleStates()
    if not SRC.saved or not SRC.saved.enabled then
        self.dashboard:SetHidden(true)
        if self.effectsDashboard then self.effectsDashboard:SetHidden(true) end
        return
    end

    local role = SRC.saved.displayRole or ROLE_LEAD
    if not ShowsRotationDashboard() then
        self.dashboard:SetHidden(true)
        return
    end
    local visibleItems = {}
    local baseIndex = {}
    for index, key in ipairs(MODULE_ORDER) do baseIndex[key] = index end

    for _, key in ipairs(MODULE_ORDER) do
        local state = self.states[key]
        local row = self.rows[key]
        local visible = false
        if state and IsModuleEnabled(key) then
            if ShowsRotationDashboard() then
                visible = true
            end
        end
        row.control:SetHidden(not visible)
        if visible then
            visibleItems[#visibleItems + 1] = { key = key, state = state, row = row }
        end
    end

    -- Trial leads benefit from urgent rows rising to the top. Support-only
    -- users need a stable panel: repeatedly reordering rows as ultimate values
    -- change reads as flicker during combat. Keep support rows in module order.
    table.sort(visibleItems, function(a, b)
        if not ShowsRotationDashboard() then
            return baseIndex[a.key] < baseIndex[b.key]
        end
        local ap = Display:GetDashboardPriority(a.key, a.state)
        local bp = Display:GetDashboardPriority(b.key, b.state)
        if ap == bp then return baseIndex[a.key] < baseIndex[b.key] end
        return ap > bp
    end)

    local topOffset = SRC.saved.dashboardShowTitle == false and 10 or 38
    for index, item in ipairs(visibleItems) do
        local key, state, row = item.key, item.state, item.row
        row.control:ClearAnchors()
        row.control:SetAnchor(TOPLEFT, self.dashboard, TOPLEFT, UI.PANEL_PADDING, topOffset + ((index - 1) * UI.ROTATION_ROW_STEP))

        local confirmationActive = state.confirmationUntilMs and state.confirmationUntilMs > GetGameTimeMilliseconds()
        if confirmationActive then
            row.nextName:SetText(AccountText(state.confirmationAccount))
            row.nextStatus:SetText("CONFIRMED")
            row.afterName:SetText(AccountText(state.afterAccount))
            row.afterStatus:SetText(state.afterStatusText or "--")
        else
            row.nextName:SetText(AccountText(state.nextAccount))
            row.nextStatus:SetText(state.nextStatusText or StatusText(state))
            row.afterName:SetText(AccountText(state.afterAccount))
            row.afterStatus:SetText(state.afterStatusText or "--")
        end

        local successful = confirmationActive or state.active
        if successful then
            row.nextStatus:SetColor(1, 0.72, 0.08, 1)
        elseif state.urgent then
            row.nextStatus:SetColor(1, 0.22, 0.18, 1)
        elseif state.nextStatusText == "READY" or state.state == SRC.GroupStats.READY then
            row.nextStatus:SetColor(0.35, 1, 0.4, 1)
        else
            row.nextStatus:SetColor(1, 1, 1, 1)
        end
        self:SetProgressBar(row, self:GetStateProgressPercent(key, state, confirmationActive), successful)
    end

    local visibleCount = #visibleItems
    if visibleCount == 0 then
        self.dashboard:SetHidden(true)
        return
    end

    self.dashboard:SetDimensions(UI.PANEL_WIDTH, topOffset + (visibleCount * UI.ROTATION_ROW_STEP) + 8)
    self.dashboard:SetHidden(false)
end

local function ParseCoverage(text)
    local covered, target = string.match(tostring(text or ""), "(%d+)%/(%d+)")
    return tonumber(covered) or 0, tonumber(target) or 0
end

function Display:SetEffectColor(row, percent, active)
    percent = zo_clamp(tonumber(percent) or 0, 0, 100)
    local r, g, b = 0.88, 0.12, 0.1
    if active and percent >= 90 then r, g, b = 0.25, 0.9, 0.25
    elseif percent >= 60 then r, g, b = 1, 0.72, 0.08 end
    row.barFill:SetColor(r, g, b, 0.96)
    row.status:SetColor(r, g, b, 1)
    return r, g, b
end

function Display:RenderBuffsDebuffs()
    if not DashboardVisibilityAllows() then if self.effectsDashboard then self.effectsDashboard:SetHidden(true) end; return end
    if not self.effectsDashboard then return end
    if not SRC.saved or not SRC.saved.enabled or SRC.saved.buffsDebuffsDashboardEnabled == false then
        self.effectsDashboard:SetHidden(true)
        return
    end

    for _, row in pairs(self.effectRows or {}) do
        if row.control then row.control:SetHidden(true) end
    end
    for _, header in pairs(self.effectSectionHeaders or {}) do header:SetHidden(true) end

    local groups = GetConfiguredEffectOrder()
    local layout = {
        { key="BUFF_TIMER", label="BUFFS - TIMERS" },
        { key="BUFF_COUNT", label="BUFFS - PLAYER COUNT" },
        { key="DEBUFF_TIMER", label="DEBUFFS - TIMERS" },
        { key="DEBUFF_COUNT", label="DEBUFFS - PLAYER COUNT" },
    }
    local y = SRC.saved.buffsDebuffsShowTitle == false and 10 or 40
    local visibleCount = 0

    for _, section in ipairs(layout) do
        local entries = groups[section.key] or {}
        if #entries > 0 then
            local header = self:EnsureEffectSectionHeader(section.key, section.label)
            header:ClearAnchors()
            header:SetAnchor(TOPLEFT, self.effectsDashboard, TOPLEFT, UI.PANEL_PADDING, y)
            header:SetHidden(false)
            y = y + 25
            for _, effect in ipairs(entries) do
                local row = self:EnsureEffectRow(effect)
                local stateKey = LEGACY_EFFECT_KEYS[effect.key] or effect.key
                local stateSource = (self.buffsDebuffsPreviewActive and self.buffsDebuffsPreviewStates) or nil
                local state = stateSource and (stateSource[stateKey] or stateSource[effect.key])
                    or self.buffDebuffStates[effect.key] or self.buffDebuffStates[stateKey]
                    or self.states[effect.key] or self.states[stateKey]
                row.control:ClearAnchors()
                row.control:SetAnchor(TOPLEFT, self.effectsDashboard, TOPLEFT, UI.PANEL_PADDING, y)
                row.control:SetHidden(false)
                visibleCount = visibleCount + 1
                y = y + UI.EFFECT_ROW_STEP

                local percent = zo_clamp(tonumber(state and state.percent) or 0, 0, 100)
                local active = state and state.active == true
                local covered = tonumber(state and state.covered)
                local target = tonumber(state and state.target)
                if covered == nil or target == nil then covered, target = ParseCoverage(state and state.nextAccount) end
                if target <= 0 then target = math.max(1, tonumber(GetGroupSize()) or 1) end

                local missingPlayers = state and state.missingPlayers or nil
                local showCoverage = state and state.showCoverage == true
                row.count:SetHidden(not showCoverage)
                row.count:SetText(showCoverage and ("PLAYERS  " .. tostring(covered) .. "/" .. tostring(target)) or "")
                if showCoverage and state and state.showMissingPlayers == true and missingPlayers and #missingPlayers > 0 then
                    row.missing:SetText("MISSING: " .. table.concat(missingPlayers, "  "))
                    row.missing:SetHidden(false)
                else
                    row.missing:SetText("")
                    row.missing:SetHidden(true)
                end

                if effect.dashboardMode == "TIMER" then
                    local remaining = tonumber(state and state.remaining) or 0
                    row.status:SetText(remaining > 0 and string.format("%.1fs", remaining) or "DOWN")
                    local timerPercent = remaining > 0 and math.min(100, math.max(1, percent)) or 0
                    row.barFill:SetDimensions(math.max(1, UI.EFFECT_BAR_WIDTH * timerPercent / 100), UI.EFFECT_BAR_HEIGHT)
                    row.barFill:SetHidden(false)
                    row.barBackground:SetHidden(false)
                    for _, block in ipairs(row.blocks) do block:SetHidden(true) end
                    self:SetEffectColor(row, timerPercent, remaining > 0)
                else
                    row.status:SetText(tostring(covered) .. "/" .. tostring(target))
                    row.count:SetHidden(true)
                    row.barBackground:SetHidden(true)
                    row.barFill:SetHidden(true)
                    local r, g, b = self:SetEffectColor(row, percent, active)
                    for index, block in ipairs(row.blocks) do
                        local show = index <= math.min(target, 12)
                        block:SetHidden(not show)
                        if show then block:SetColor(index <= covered and r or 0.22, index <= covered and g or 0.22, index <= covered and b or 0.22, index <= covered and 0.95 or 0.78) end
                    end
                end
            end
            y = y + 4
        end
    end

    if visibleCount == 0 then self.effectsDashboard:SetHidden(true); return end
    self.effectsDashboard:SetDimensions(UI.EFFECT_PANEL_WIDTH, y + 8)
    self.effectsDashboard:SetHidden(false)
end

function Display:ApplyCalloutLayout()
    if not self.callout then return end

    local layout = SRC.saved.calloutLayout or "vertical"
    local alignment = ALIGNMENTS[SRC.saved.calloutAlignment or "center"] or TEXT_ALIGN_CENTER

    self.calloutName1:ClearAnchors()
    self.calloutName2:ClearAnchors()
    self.calloutAction:ClearAnchors()
    self.calloutCombined:ClearAnchors()

    self.calloutName1:SetHorizontalAlignment(alignment)
    self.calloutName2:SetHorizontalAlignment(alignment)
    self.calloutAction:SetHorizontalAlignment(alignment)
    self.calloutCombined:SetHorizontalAlignment(alignment)

    if layout == "horizontal" then
        self.calloutName1:SetHidden(true)
        self.calloutName2:SetHidden(true)
        self.calloutAction:SetHidden(true)
        self.calloutCombined:SetHidden(false)
        self.calloutCombined:SetAnchorFill()
    else
        self.calloutCombined:SetHidden(true)
        self.calloutName1:SetHidden(false)
        self.calloutAction:SetHidden(false)

        local nameFirst = (SRC.saved.calloutOrder or "nameFirst") == "nameFirst"
        if nameFirst then
            self.calloutName1:SetAnchor(TOPLEFT, self.callout, TOPLEFT, 8, 12)
            self.calloutName1:SetAnchor(TOPRIGHT, self.callout, TOPRIGHT, -8, 12)
            self.calloutName1:SetHeight(58)
            self.calloutName2:SetAnchor(TOPLEFT, self.calloutName1, BOTTOMLEFT, 0, 0)
            self.calloutName2:SetAnchor(TOPRIGHT, self.calloutName1, BOTTOMRIGHT, 0, 0)
            self.calloutName2:SetHeight(58)
            self.calloutAction:SetAnchor(TOPLEFT, self.calloutName2, BOTTOMLEFT, 0, 4)
            self.calloutAction:SetAnchor(BOTTOMRIGHT, self.callout, BOTTOMRIGHT, -8, -12)
        else
            self.calloutAction:SetAnchor(TOPLEFT, self.callout, TOPLEFT, 8, 12)
            self.calloutAction:SetAnchor(TOPRIGHT, self.callout, TOPRIGHT, -8, 12)
            self.calloutAction:SetHeight(56)
            self.calloutName1:SetAnchor(TOPLEFT, self.calloutAction, BOTTOMLEFT, 0, 4)
            self.calloutName1:SetAnchor(TOPRIGHT, self.calloutAction, BOTTOMRIGHT, 0, 4)
            self.calloutName1:SetHeight(58)
            self.calloutName2:SetAnchor(TOPLEFT, self.calloutName1, BOTTOMLEFT, 0, 0)
            self.calloutName2:SetAnchor(BOTTOMRIGHT, self.callout, BOTTOMRIGHT, -8, -12)
        end
    end
end

function Display:ShowLeadCallout(accountName, action, suffix, holdMs)
    if SRC.saved.calloutsEnabled == false or not ShowsLead() or SRC.saved.leadCalloutEnabled == false then return end

    local names = SplitCalloutNames(accountName)
    local actionText = zo_strupper(tostring(action or "ACTION"))
    local suffixText = zo_strupper(tostring(suffix or "NOW"))
    local fullAction = actionText .. " " .. suffixText

    self.calloutName1:SetText(names[1] or "")
    self.calloutName2:SetText(names[2] or "")
    self.calloutName2:SetHidden((SRC.saved.calloutLayout or "vertical") ~= "vertical" or names[2] == nil)
    self.calloutAction:SetText(fullAction)
    self.calloutCombined:SetText(table.concat(names, "  ") .. "  " .. fullAction)
    self:ApplyCalloutLayout()
    if (SRC.saved.calloutLayout or "vertical") == "vertical" then
        self.calloutName2:SetHidden(names[2] == nil)
    end
    self.callout:SetHidden(false)

    self.calloutToken = (self.calloutToken or 0) + 1
    local token = self.calloutToken
    zo_callLater(function()
        if Display.calloutToken == token then
            Display.callout:SetHidden(true)
        end
    end, holdMs or SRC.saved.calloutHoldMs or 1200)
end


function Display:ShowRaidCallout(accountName, action, suffix, holdMs)
    if SRC.saved.calloutsEnabled == false or SRC.saved.leadCalloutEnabled == false then return end

    local names = SplitCalloutNames(accountName)
    local actionText = zo_strupper(tostring(action or "ACTION"))
    local suffixText = zo_strupper(tostring(suffix or "NOW"))
    local fullAction = actionText .. " " .. suffixText

    self.calloutName1:SetText(names[1] or "")
    self.calloutName2:SetText(names[2] or "")
    self.calloutName2:SetHidden((SRC.saved.calloutLayout or "vertical") ~= "vertical" or names[2] == nil)
    self.calloutAction:SetText(fullAction)
    self.calloutCombined:SetText(table.concat(names, "  ") .. "  " .. fullAction)
    self:ApplyCalloutLayout()
    if (SRC.saved.calloutLayout or "vertical") == "vertical" then
        self.calloutName2:SetHidden(names[2] == nil)
    end
    self.callout:SetHidden(false)

    self.calloutToken = (self.calloutToken or 0) + 1
    local token = self.calloutToken
    zo_callLater(function()
        if Display.calloutToken == token then Display.callout:SetHidden(true) end
    end, holdMs or SRC.saved.calloutHoldMs or 1200)
end

function Display:ShowSharedMessage(message, holdMs, colorName)
    if SRC.saved.calloutsEnabled == false or not self.ddCallout then return false end
    if not ShowsDamageDealerDashboard() then
        if SRC.Diagnostics then
            SRC.Diagnostics:AddFields("DD_CALLOUT", "Shared callout suppressed", {
                message = tostring(message or ""),
                role = tostring(SRC.saved.displayRole or ROLE_LEAD),
                enabled = SRC.saved.damageDealerDashboardEnabled == true,
            })
        end
        return false
    end
    local color = CALLOUT_COLORS[colorName or "gold"] or CALLOUT_COLORS.gold
    self.ddCalloutText:SetColor(unpack(color))
    self.ddCalloutText:SetText(zo_strupper(tostring(message or "")))
    self.ddCallout:SetHidden(false)

    self.damageDealerCalloutToken = (self.damageDealerCalloutToken or 0) + 1
    local token = self.damageDealerCalloutToken
    zo_callLater(function()
        if Display.damageDealerCalloutToken == token then
            Display.ddCallout:SetHidden(true)
        end
    end, holdMs or 1500)
    if SRC.Diagnostics then
        SRC.Diagnostics:AddFields("DD_CALLOUT", "Shared callout displayed", {
            message = tostring(message or ""),
            role = tostring(SRC.saved.displayRole or ROLE_LEAD),
            holdMs = holdMs or 1500,
        })
    end
    return true
end

function Display:ShowModuleConfirmation(key, accountName, label, holdMs)
    if SRC.saved.confirmationEnabled == false then return end
    local state = self.states[key]
    if not state then return end

    state.confirmationAccount = accountName
    state.confirmationUntilMs = GetGameTimeMilliseconds() + (holdMs or SRC.saved.confirmationHoldMs or 900)
    state.confirmationLabel = label or state.label or key
    self:RenderDashboard()

    local token = (self.confirmationTokens and self.confirmationTokens[key] or 0) + 1
    self.confirmationTokens = self.confirmationTokens or {}
    self.confirmationTokens[key] = token
    zo_callLater(function()
        if Display.confirmationTokens and Display.confirmationTokens[key] == token then
            local current = Display.states[key]
            if current then
                current.confirmationAccount = nil
                current.confirmationUntilMs = nil
                current.confirmationLabel = nil
            end
            Display:RenderDashboard()
        end
    end, holdMs or SRC.saved.confirmationHoldMs or 900)
end

function Display:ShowPersonalIdle()
    if not DashboardVisibilityAllows() or not ShowsPersonalDashboard() or not self.personal then return end
    self.personalVisibilityToken = (self.personalVisibilityToken or 0) + 1
    self.personalSignature = "SRC_PERSONAL_IDLE"
    self.personalModuleKey = "IDLE"
    self.personalHeading:SetText("PERSONAL ASSIGNMENTS")
    self.personalAction:SetText("WAITING")
    self.personalStatus:SetText("--")
    self.personalStatus:SetColor(1, 1, 1, 1)
    self.personal:SetHidden(false)
end

function Display:SetPersonal(accountName, heading, action, statusText, nowState, moduleKey)
    if not DashboardVisibilityAllows() or not ShowsPersonalDashboard() or not IsLocalAccount(accountName) or (moduleKey and not IsModuleEnabled(moduleKey)) then
        if not moduleKey or self.personalModuleKey == moduleKey then self:HidePersonal(moduleKey) end
        return
    end

    local statusValue = tostring(statusText or "")
    local isCountdownState = statusValue == "NOW" or tonumber(statusValue) ~= nil
    local nowMs = GetGameTimeMilliseconds()
    if self.personalCountdownLockUntil and nowMs < self.personalCountdownLockUntil and self.personalCountdownModule == moduleKey then
        if statusValue == "READY" or statusValue == "WAIT" or statusValue == "--" then return end
    end
    if isCountdownState then
        self.personalCountdownModule = moduleKey
        self.personalCountdownLockUntil = nowMs + (statusValue == "NOW" and 1400 or 1150)
    end

    -- Cancel any pending hide before updating the existing controls. This keeps
    -- competing readiness callbacks from producing rapid hide/show flicker.
    self.personalVisibilityToken = (self.personalVisibilityToken or 0) + 1

    local signature = table.concat({ moduleKey or "", accountName or "", heading or "", action or "", statusText or "", nowState and "1" or "0" }, "|")
    if self.personalSignature == signature and not self.personal:IsHidden() then return end
    self.personalSignature = signature
    self.personalModuleKey = moduleKey
    self.personalHeading:SetText(heading or "YOU ARE NEXT")
    self.personalAction:SetText(action or "ACTION")
    self.personalStatus:SetText(statusText or "")
    self.personalStatus:SetColor(nowState and 1 or 1, nowState and 0.22 or 1, nowState and 0.18 or 1, 1)
    if self.personal:IsHidden() then self.personal:SetHidden(false) end
end

function Display:HidePersonal(moduleKey, immediate)
    if moduleKey and self.personalModuleKey and self.personalModuleKey ~= moduleKey then return end
    if not self.personal then return end

    self.personalVisibilityToken = (self.personalVisibilityToken or 0) + 1
    local token = self.personalVisibilityToken
    local function CommitHide()
        if Display.personalVisibilityToken ~= token then return end
        if moduleKey and Display.personalModuleKey and Display.personalModuleKey ~= moduleKey then return end
        if ShowsPersonalDashboard() then
            Display:ShowPersonalIdle()
        else
            Display.personal:SetHidden(true)
            Display.personalSignature = nil
            Display.personalModuleKey = nil
        end
    end

    if immediate then
        CommitHide()
    else
        zo_callLater(CommitHide, 180)
    end
end

function Display:ShowNext(accountName, position, remaining, skipped)
    self:SetColossusState(
        position,
        accountName,
        remaining,
        string.format("%.1f", zo_max(0, remaining or 0)),
        false,
        false
    )

    if IsLocalAccount(accountName) then
        self:SetPersonal(accountName, skipped and "YOU ARE NEXT READY" or "YOU ARE NEXT", string.format("COLO %d", position or 0), string.format("%.1f", zo_max(0, remaining or 0)), false, "COLOSSUS")
    else
        self:HidePersonal("COLOSSUS")
    end
end

function Display:ShowOpening(selectedPosition, readinessList)
    local selected = selectedPosition and readinessList[selectedPosition] or nil
    local account = selected and selected.account or "WAITING"
    local status = selectedPosition and "READY" or "WAIT"
    self:SetColossusState(selectedPosition or 1, account, nil, status, false, true)

    if selected and IsLocalAccount(selected.account) then
        self:SetPersonal(selected.account, "YOU OPEN", string.format("COLO %d", selectedPosition), "READY", false, "COLOSSUS")
    else
        self:HidePersonal("COLOSSUS")
    end
end

function Display:ShowNoReady(remaining)
    self:SetColossusState(1, "WAITING", remaining, remaining and string.format("%.1f", remaining) or "WAIT", false, false)
    self:HidePersonal("COLOSSUS")
end

function Display:ShowConfigurationError(message)
    self:SetColossusState(1, message or "CHECK SETTINGS", nil, "ERROR", true, false)
    if ShowsLead() then self:ShowLeadCallout(message or "CHECK SETTINGS", "CONFIGURATION", "ERROR", 1800) end
    self:HidePersonal()
end

function Display:ShowCountdown(accountName, position, value, skipped)
    self:SetColossusState(position, accountName, tonumber(value), tostring(value), true, false)
    if ShowsLead() then
        self:ShowLeadCallout(accountName, "COLOSSUS", tostring(value), 850)
    end
    if IsLocalAccount(accountName) then
        self:SetPersonal(accountName, "YOU ARE NEXT", string.format("COLO %d", position or 0), tostring(value), false, "COLOSSUS")
    else
        self:HidePersonal("COLOSSUS")
    end
end

function Display:ShowNow(accountName, position, skipped)
    self:SetColossusState(position, accountName, 0, "NOW", true, false)
    self:ShowLeadCallout(accountName, "COLOSSUS", "NOW", SRC.saved.calloutHoldMs)
    if IsLocalAccount(accountName) then
        self:SetPersonal(accountName, "DROP NOW", string.format("COLO %d", position or 0), "NOW", true, "COLOSSUS")
    else
        self:HidePersonal("COLOSSUS")
    end
end

function Display:Hide()
    -- LiveSession can invalidate runtime state during startup before display
    -- controls have been created. Treat Hide as an idempotent reset so module
    -- hard resets are always safe, regardless of initialization order.
    self.states = self.states or {}
    self.states.COLOSSUS = nil
    if self.dashboard then self:RenderDashboard() end
    self:HidePersonal()
end


function Display:PreviewBuffsDebuffs()
    -- Run a short isolated simulation so users can see exactly how timer bars
    -- and recipient counts behave during combat. Live state continues updating
    -- underneath and is restored when the preview ends.
    self:StopBuffsDebuffsPreview(false)
    self.previewVisibilityOverride = true
    self.buffsDebuffsPreviewToken = (self.buffsDebuffsPreviewToken or 0) + 1
    local token = self.buffsDebuffsPreviewToken
    self.buffsDebuffsPreviewActive = true
    self.buffsDebuffsPreviewStates = {}

    local groups = GetConfiguredEffectOrder()
    local timerIndex = 0
    local countIndex = 0
    for _, entries in pairs(groups) do
        for _, effect in ipairs(entries) do
            if effect.dashboardMode == "TIMER" then
                timerIndex = timerIndex + 1
                self.buffsDebuffsPreviewStates[effect.key] = {
                    label = effect.name,
                    nextAccount = effect.effectType == "DEBUFF" and "TARGET" or "GROUP",
                    remaining = 13.5 - ((timerIndex - 1) * 1.6),
                    previewDuration = 13.5 - ((timerIndex - 1) * 1.6),
                    active = true,
                    percent = 100,
                    previewKind = "TIMER",
                }
            else
                countIndex = countIndex + 1
                local covered = 2 + ((countIndex * 2) % 9)
                self.buffsDebuffsPreviewStates[effect.key] = {
                    label = effect.name,
                    nextAccount = string.format("%d/12 COVERED", covered),
                    covered = covered,
                    target = 12,
                    active = covered >= 12,
                    percent = (covered / 12) * 100,
                    previewKind = "COUNT",
                    previewDirection = 1,
                }
            end
        end
    end

    local startedAt = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    local function TickPreview()
        if Display.buffsDebuffsPreviewToken ~= token or not Display.buffsDebuffsPreviewActive then return end
        local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or startedAt
        local elapsedSeconds = math.max(0, (now - startedAt) / 1000)
        for _, state in pairs(Display.buffsDebuffsPreviewStates or {}) do
            if state.previewKind == "TIMER" then
                local duration = math.max(3, tonumber(state.previewDuration) or 10)
                local remaining = duration - (elapsedSeconds % duration)
                state.remaining = remaining
                state.active = remaining > 0.15
                state.percent = zo_clamp((remaining / duration) * 100, 0, 100)
            elseif state.previewKind == "COUNT" then
                local covered = tonumber(state.covered) or 0
                local direction = tonumber(state.previewDirection) or 1
                covered = covered + direction
                if covered >= 12 then covered = 12; direction = -1 end
                if covered <= 1 then covered = 1; direction = 1 end
                state.covered = covered
                state.previewDirection = direction
                state.nextAccount = string.format("%d/12 COVERED", covered)
                state.active = covered >= 12
                state.percent = (covered / 12) * 100
            end
        end
        Display:RenderBuffsDebuffs()
        zo_callLater(TickPreview, 350)
    end

    TickPreview()
    zo_callLater(function()
        if Display.buffsDebuffsPreviewToken == token and Display.buffsDebuffsPreviewActive then
            Display:StopBuffsDebuffsPreview()
        end
    end, 8000)
end

function Display:StopBuffsDebuffsPreview(restoreLive)
    self.previewVisibilityOverride = false
    self.buffsDebuffsPreviewToken = (self.buffsDebuffsPreviewToken or 0) + 1
    self.buffsDebuffsPreviewActive = false
    self.buffsDebuffsPreviewStates = nil
    -- Restore the current live state exactly once after a completed preview.
    -- Preview startup passes false so the live panel is not briefly rendered
    -- between clearing an older preview and mounting the new snapshot.
    if restoreLive ~= false then self:RenderBuffsDebuffs() end
end

function Display:PreviewDashboard()
    self.previewVisibilityOverride = true
    local localAccount = GetDisplayName()
    self.states.COLOSSUS = {
        label = "COLO", nextAccount = localAccount, nextStatusText = "READY",
        afterAccount = "@COLO2", afterStatusText = "82%", localAssigned = true,
    }
    self.states.WARHORN = {
        label = "HORN", nextAccount = "@HORN1", nextStatusText = "74%",
        afterAccount = localAccount, afterStatusText = "READY", localAssigned = true,
    }
    self.states.BARRIER = {
        label = "BARRIER", nextAccount = localAccount, nextStatusText = "READY",
        afterAccount = "@BARRIER2", afterStatusText = "61%", localAssigned = true,
    }
    self:RenderDashboard()
end

function Display:PreviewPersonal()
    self.previewVisibilityOverride = true
    -- Preview must work outside combat and regardless of the selected role or
    -- enabled modules. It writes directly to the personal alert controls rather
    -- than using SetPersonal, whose production guards intentionally suppress
    -- alerts that do not belong to the local support player.
    if not self.personal then return end
    self.personalSignature = "SRC_PERSONAL_PREVIEW"
    self.personalModuleKey = "PREVIEW"
    self.personalHeading:SetText("YOU ARE NEXT")
    self.personalAction:SetText("COLOSSUS")
    self.personalStatus:SetText("READY")
    self.personalStatus:SetColor(1, 1, 1, 1)
    self.personal:SetHidden(false)

    self.personalPreviewToken = (self.personalPreviewToken or 0) + 1
    local token = self.personalPreviewToken
    zo_callLater(function()
        if Display.personalPreviewToken == token then
            Display.previewVisibilityOverride = false
            if DashboardVisibilityAllows() and ShowsPersonalDashboard() then
                Display:ShowPersonalIdle()
            else
                Display.personal:SetHidden(true)
                Display.personalSignature = nil
                Display.personalModuleKey = nil
            end
        end
    end, 3000)
end

function Display:PreviewLeadCallout()
    self:ShowLeadCallout(GetDisplayName(), "COLOSSUS", "NOW", 2500)
end

function Display:PreviewDamageDealerDashboard()
    self.previewVisibilityOverride = true
    if not self.ddCallout then return end
    self.damageDealerPreviewToken = (self.damageDealerPreviewToken or 0) + 1
    local token = self.damageDealerPreviewToken
    local steps = {
        { delay = 0, text = "HOLD ULTIMATES", color = "red", hold = 1100 },
        { delay = 1300, text = "BURN WINDOW IN 5", color = "gold", hold = 850 },
        { delay = 2200, text = "BURN WINDOW IN 4", color = "gold", hold = 850 },
        { delay = 3100, text = "BURN WINDOW IN 3", color = "gold", hold = 850 },
        { delay = 4000, text = "BURN WINDOW IN 2", color = "gold", hold = 850 },
        { delay = 4900, text = "BURN WINDOW IN 1", color = "gold", hold = 850 },
        { delay = 6300, text = "DAMAGE ULTIMATES NOW", color = "red", hold = 1600 },
    }
    for _, step in ipairs(steps) do
        zo_callLater(function()
            if Display.damageDealerPreviewToken ~= token or not Display.ddCallout then return end
            -- Preview buttons must work regardless of the user's selected role
            -- or whether live callouts are currently enabled. Render directly
            -- into the DD callout control without changing saved preferences.
            local color = CALLOUT_COLORS[step.color or "gold"] or CALLOUT_COLORS.gold
            Display.ddCalloutText:SetColor(unpack(color))
            Display.ddCalloutText:SetText(zo_strupper(tostring(step.text or "")))
            Display.ddCallout:SetHidden(false)
            Display.damageDealerCalloutToken = (Display.damageDealerCalloutToken or 0) + 1
            local calloutToken = Display.damageDealerCalloutToken
            zo_callLater(function()
                if Display.damageDealerPreviewToken == token and Display.damageDealerCalloutToken == calloutToken then
                    Display.ddCallout:SetHidden(true)
                end
            end, step.hold or 1200)
        end, step.delay)
    end
    zo_callLater(function()
        if Display.damageDealerPreviewToken == token then
            Display.previewVisibilityOverride = false
        end
    end, 8200)
end

function Display:ClearPreview()
    self.previewVisibilityOverride = false
    self:StopBuffsDebuffsPreview()
    self.states.COLOSSUS = nil
    self.states.WARHORN = nil
    self.states.BARRIER = nil
    self.states.BRITTLE = nil
    self.states.MINOR_COURAGE = nil
    self.states.MAJOR_RESOLVE = nil
    self.states.POWERFUL_ASSAULT = nil
    self:RenderDashboard()
    self:RenderBuffsDebuffs()
    self:HidePersonal()
    if self.callout then self.callout:SetHidden(true) end
    if self.ddCallout then self.ddCallout:SetHidden(true) end
    if ShowsPersonalDashboard() then self:ShowPersonalIdle() end
end

function Display:Preview()
    self.previewVisibilityOverride = true
    local localAccount = GetDisplayName()
    self.states.WARHORN = {
        label = "HORN",
        nextAccount = localAccount,
        nextStatusText = "READY",
        afterAccount = "@HORN2",
        afterStatusText = "72%",
        localAssigned = true,
    }
    self.states.BARRIER = {
        label = "BARRIER",
        nextAccount = "@BARRIER1",
        nextStatusText = "64%",
        afterAccount = localAccount,
        afterStatusText = "READY",
        localAssigned = true,
    }
    self:ShowNext(localAccount, 1, 8.7, false)
    zo_callLater(function() self:ShowCountdown(localAccount, 1, 3, false) end, 900)
    zo_callLater(function() self:ShowCountdown(localAccount, 1, 2, false) end, 1700)
    zo_callLater(function() self:ShowCountdown(localAccount, 1, 1, false) end, 2500)
    zo_callLater(function() self:ShowNow(localAccount, 1, false) end, 3300)
    zo_callLater(function() self.previewVisibilityOverride = false; self.callout:SetHidden(true); if DashboardVisibilityAllows() and ShowsPersonalDashboard() then self:ShowPersonalIdle() else self.personal:SetHidden(true) end; self:RenderDashboard(); self:RenderBuffsDebuffs() end, 4800)
end

function Display:UpdateBuffDebuffState(key, state)
    self.buffDebuffStates = self.buffDebuffStates or {}
    if not state then
        self.buffDebuffStates[key] = nil
    else
        self.buffDebuffStates[key] = {
            label = state.label or MODULE_LABELS[key] or key,
            nextAccount = state.account,
            nextStatusText = state.statusText or StatusText(state),
            remaining = state.remaining,
            percent = state.percent,
            active = state.active,
            showCoverage = state.showCoverage == true,
            covered = state.covered,
            target = state.target,
            missingPlayers = state.missingPlayers,
            showMissingPlayers = state.showMissingPlayers == true,
        }
    end
    if not self.buffsDebuffsPreviewActive then self:RenderBuffsDebuffs() end
end

function Display:ClearBuffDebuffState(key)
    self.buffDebuffStates = self.buffDebuffStates or {}
    self.buffDebuffStates[key] = nil
    if not self.buffsDebuffsPreviewActive then self:RenderBuffsDebuffs() end
end

function Display:UpdateModuleState(key, state)
    if not IsModuleEnabled(key) then
        self:ClearModuleState(key)
        return
    end
    if not state then
        self:ClearModuleState(key)
        return
    end

    local previous = self.states[key]
    self.states[key] = {
        label = state.label or MODULE_LABELS[key] or key,
        position = state.position,
        nextAccount = state.account,
        nextStatusText = state.statusText or StatusText(state),
        remaining = state.remaining,
        state = state.state,
        percent = state.percent,
        urgent = state.urgent,
        active = state.active,
        afterPosition = state.followingPosition,
        afterAccount = state.followingAccount,
        afterStatusText = state.followingStatusText,
        localAssigned = state.localAssigned,
        confirmationAccount = previous and previous.confirmationAccount or nil,
        confirmationUntilMs = previous and previous.confirmationUntilMs or nil,
        confirmationLabel = previous and previous.confirmationLabel or nil,
    }

    self:RenderDashboard()
    if not self.buffsDebuffsPreviewActive then self:RenderBuffsDebuffs() end

    if key == "SLAYER" and state.active then
        self:HidePersonal("SLAYER")
    elseif state.urgent then
        local remaining = state.remaining or 0
        local suffix = remaining <= 0.5 and "NOW" or tostring(math.max(1, math.ceil(remaining)))
        self:ShowLeadCallout(state.account, state.label or key, suffix, suffix == "NOW" and SRC.saved.calloutHoldMs or 850)
        if IsLocalAccount(state.account) then
            self:SetPersonal(state.account, "YOU ARE NEXT", state.label or key, suffix, suffix == "NOW", key)
        end
    elseif IsLocalAccount(state.account) and ShowsPersonalDashboard() then
        self:SetPersonal(state.account, "YOU ARE NEXT", state.label or key, state.statusText or StatusText(state), false, key)
    end
end

function Display:ClearModuleState(key)
    self.states = self.states or {}
    self.states[key] = nil
    -- Hard resets can run before Display:Initialize during one-time migrations.
    -- Clear model state immediately and defer rendering until controls exist.
    if not self.dashboard then return end
    self:HidePersonal(key)
    self:RenderDashboard()
    if not self.buffsDebuffsPreviewActive then self:RenderBuffsDebuffs() end
end
