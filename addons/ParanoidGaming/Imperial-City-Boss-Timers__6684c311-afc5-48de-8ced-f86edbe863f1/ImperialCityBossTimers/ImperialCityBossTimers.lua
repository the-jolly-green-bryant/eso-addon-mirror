ImperialCityBossTimers = ImperialCityBossTimers or {}

local ICBT = ImperialCityBossTimers
local ADDON_NAME = "ImperialCityBossTimers"
local DISPLAY_NAME = "Imperial City Boss Timers"
local VERSION = "1.4.0"
local SAVED_VARIABLES_NAME = "ImperialCityBossTimersSavedVariables"
local SAVED_VARIABLES_VERSION = 1
local UPDATE_INTERVAL_MS = 250
local DEATH_EVENT_DEDUPLICATION_SECONDS = 6
local RETICLE_LIVE_CONFIRMATION_SECONDS = 90
local NORMAL_HUD_DRAW_LEVEL = 5
local MENU_PREVIEW_DRAW_LEVEL = (ZO_HIGH_TIER_ANCHOR_EDITOR_HIGHLIGHT or ZO_HIGH_TIER_TOOLTIPS or 150) + 5

local DEFAULT_TIMER_SECONDS = 15 * 60
local SPECIAL_EVENT_TIMER_SECONDS = 7 * 60

local DISTRICT_ORDER = {
    "arboretum",
    "nobles",
    "memorial",
    "arena",
    "elvenGardens",
    "temple",
}

local DISTRICT_ORDER_INDEX = {}
for index, districtKey in ipairs(DISTRICT_ORDER) do
    DISTRICT_ORDER_INDEX[districtKey] = index
end

local DISTRICTS = {
    arboretum = {
        name = "Arboretum District",
        bosses = { "Lady Malygda", "Ysenda Resplendent" },
    },
    nobles = {
        name = "Nobles District",
        bosses = { "Amoncrul", "Baron Thirsk" },
    },
    memorial = {
        name = "Memorial District",
        bosses = { "Nunatak", "Volghass" },
    },
    arena = {
        name = "Arena District",
        bosses = { "Glorgoloch the Destroyer", "King Khrogo" },
    },
    elvenGardens = {
        name = "Elven Gardens District",
        bosses = { "The Screeching Matron", "Zoal the Ever-Wakeful" },
    },
    temple = {
        name = "Temple District",
        bosses = { "Immolator Charr", "Mazaluhad" },
    },
}

-- These values reproduce the example screenshot at the 15-minute setting.
-- They are proportionally shortened while Special Event Timer is selected.
local PREVIEW_REFERENCE_SECONDS = {
    arboretum = 86,
    nobles = 0,
    memorial = 355,
    arena = 442,
    elvenGardens = 0,
    temple = 793,
}

local DEFAULTS = {
    layoutRevision = 0,
    showHud = true,
    onlyInImperialCity = true,
    timerMode = "default",
    sizePercent = 65,
    positionX = 1700,
    positionY = 1000,
    showPositionPreview = false,
    lockPosition = true,
    showTitle = false,
    showLastBoss = false,
    readyTextMode = "ready",
    sortActiveTimers = true,
    backgroundAlpha = 68,
    showBorder = false,
    showCountdownBars = true,
    countdownBarAlpha = 100,
    colors = {
        countdown = { 1.00, 1.00, 1.00, 1.00 },
        countdownBar = { 1.00, 0.00, 0.00, 1.00 },
        ready = { 1.00, 1.00, 1.00, 1.00 },
        countdownTimer = { 1.00, 0.00, 0.00, 1.00 },
        readyTimer = { 0.00, 1.00, 0.10, 1.00 },
        title = { 1.00, 0.82, 0.18, 1.00 },
        boss = { 0.76, 0.76, 0.76, 1.00 },
        border = { 0.78, 0.62, 0.20, 1.00 },
    },
    chatOnKill = true,
    chatOnReady = true,
    soundOnReady = true,
    manualDistrict = "arboretum",
    timers = {},
}

ICBT.name = ADDON_NAME
ICBT.displayName = DISPLAY_NAME
ICBT.version = VERSION
ICBT.districts = DISTRICTS
ICBT.districtOrder = DISTRICT_ORDER

local function Clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function CopyColor(color, fallback)
    local source = type(color) == "table" and color or fallback
    return {
        Clamp(source[1], 0, 1),
        Clamp(source[2], 0, 1),
        Clamp(source[3], 0, 1),
        Clamp(source[4] or 1, 0, 1),
    }
end

local function Trim(text)
    return tostring(text or ""):match("^%s*(.-)%s*$")
end

local function NormalizeUnitName(name)
    if type(name) ~= "string" or name == "" then return "" end

    local normalized = name
    if zo_strformat and SI_UNIT_NAME then
        normalized = zo_strformat(SI_UNIT_NAME, normalized)
    else
        normalized = normalized:gsub("%^%a+$", "")
    end

    normalized = normalized:gsub("|c%x%x%x%x%x%x", "")
    normalized = normalized:gsub("|r", "")
    normalized = Trim(normalized)

    if zo_strlower then
        return zo_strlower(normalized)
    end
    return string.lower(normalized)
end

local BOSS_LOOKUP = {}
local BOSS_CANONICAL_NAMES = {}

for _, districtKey in ipairs(DISTRICT_ORDER) do
    local district = DISTRICTS[districtKey]
    for _, bossName in ipairs(district.bosses) do
        local normalizedName = NormalizeUnitName(bossName)
        BOSS_LOOKUP[normalizedName] = districtKey
        BOSS_CANONICAL_NAMES[normalizedName] = bossName
    end
end

-- ESO can report this boss with or without the leading article.
BOSS_LOOKUP["screeching matron"] = "elvenGardens"
BOSS_CANONICAL_NAMES["screeching matron"] = "The Screeching Matron"

local function FormatSeconds(totalSeconds)
    totalSeconds = math.max(0, math.ceil(tonumber(totalSeconds) or 0))
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

local function SetLabelColor(label, color)
    label:SetColor(color[1], color[2], color[3], color[4] or 1)
end

local function SetLabelFont(label, size, outline)
    local face = IsInGamepadPreferredMode() and "$(GAMEPAD_BOLD_FONT)" or "$(BOLD_FONT)"
    local effect = outline or "soft-shadow-thick"
    label:SetFont(string.format("%s|%d|%s", face, math.max(10, math.floor(size + 0.5)), effect))
end

function ICBT:GetTimerDurationSeconds()
    if self.sv.timerMode == "event" then
        return SPECIAL_EVENT_TIMER_SECONDS
    end
    return DEFAULT_TIMER_SECONDS
end

function ICBT:GetTimerModeLabel()
    if self.sv.timerMode == "event" then
        return "Special Event Timer (7 minutes)"
    end
    return "Default Timer (15 minutes)"
end

function ICBT:ValidateSavedVariables()
    local sv = self.sv
    local layoutRevision = tonumber(sv.layoutRevision) or 0

    sv.showHud = sv.showHud ~= false
    sv.onlyInImperialCity = sv.onlyInImperialCity ~= false
    sv.timerMode = sv.timerMode == "event" and "event" or "default"
    sv.sizePercent = Clamp(sv.sizePercent or DEFAULTS.sizePercent, 40, 165)
    sv.positionX = Clamp(sv.positionX or DEFAULTS.positionX, 0, 3840)
    sv.positionY = Clamp(sv.positionY or DEFAULTS.positionY, 0, 2160)
    sv.showPositionPreview = sv.showPositionPreview == true
    sv.lockPosition = sv.lockPosition ~= false
    sv.showTitle = sv.showTitle == true
    sv.showLastBoss = sv.showLastBoss == true
    sv.readyTextMode = sv.readyTextMode == "ready" and "ready" or "zero"
    sv.sortActiveTimers = sv.sortActiveTimers ~= false
    sv.backgroundAlpha = Clamp(sv.backgroundAlpha, 0, 100)
    sv.showBorder = sv.showBorder == true
    sv.showCountdownBars = sv.showCountdownBars ~= false
    sv.countdownBarAlpha = Clamp(sv.countdownBarAlpha or DEFAULTS.countdownBarAlpha, 0, 100)
    sv.chatOnKill = sv.chatOnKill ~= false
    sv.chatOnReady = sv.chatOnReady ~= false
    sv.soundOnReady = sv.soundOnReady ~= false

    if not DISTRICTS[sv.manualDistrict] then
        sv.manualDistrict = DEFAULTS.manualDistrict
    end

    sv.colors = type(sv.colors) == "table" and sv.colors or {}
    for colorName, defaultColor in pairs(DEFAULTS.colors) do
        sv.colors[colorName] = CopyColor(sv.colors[colorName], defaultColor)
    end

    -- Apply the compact 1.2 layout once so upgrades receive its revised defaults.
    if layoutRevision < 1 then
        sv.sizePercent = DEFAULTS.sizePercent
        sv.positionX = DEFAULTS.positionX
        sv.positionY = DEFAULTS.positionY
        sv.readyTextMode = DEFAULTS.readyTextMode
        sv.sortActiveTimers = DEFAULTS.sortActiveTimers
        sv.showBorder = DEFAULTS.showBorder
        sv.showCountdownBars = DEFAULTS.showCountdownBars
        sv.countdownBarAlpha = DEFAULTS.countdownBarAlpha
        sv.colors.countdown = CopyColor(DEFAULTS.colors.countdown, DEFAULTS.colors.countdown)
        sv.colors.ready = CopyColor(DEFAULTS.colors.ready, DEFAULTS.colors.ready)
        sv.colors.countdownBar = CopyColor(DEFAULTS.colors.countdownBar, DEFAULTS.colors.countdownBar)
        sv.colors.countdownTimer = CopyColor(DEFAULTS.colors.countdownTimer, DEFAULTS.colors.countdownTimer)
        sv.colors.readyTimer = CopyColor(DEFAULTS.colors.readyTimer, DEFAULTS.colors.readyTimer)
    end

    -- Apply the 1.3 placement and true-red bar defaults once to existing installs.
    if layoutRevision < 2 then
        sv.positionX = DEFAULTS.positionX
        sv.positionY = DEFAULTS.positionY
        sv.showCountdownBars = true
        sv.countdownBarAlpha = 100
        sv.colors.countdownBar = CopyColor(DEFAULTS.colors.countdownBar, DEFAULTS.colors.countdownBar)
    end
    sv.layoutRevision = math.max(layoutRevision, 2)

    sv.timers = type(sv.timers) == "table" and sv.timers or {}
    for _, districtKey in ipairs(DISTRICT_ORDER) do
        local timer = sv.timers[districtKey]
        if type(timer) ~= "table" then
            timer = {}
            sv.timers[districtKey] = timer
        end

        timer.killedAt = tonumber(timer.killedAt) or 0
        timer.endsAt = tonumber(timer.endsAt) or 0
        timer.bossName = type(timer.bossName) == "string" and timer.bossName or ""
        timer.readyNotified = timer.readyNotified == true
    end
end

function ICBT:MarkOldTimersAsNotified()
    local now = GetTimeStamp()
    for _, districtKey in ipairs(DISTRICT_ORDER) do
        local timer = self.sv.timers[districtKey]
        if timer.endsAt <= now then
            timer.readyNotified = true
        end
    end
end

function ICBT:Print(message)
    local formatted = "|cE2B544[IC Boss Timers]|r " .. tostring(message)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(formatted)
    else
        d(formatted)
    end
end

function ICBT:CreateLabel(name, parent)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetDrawLevel(1)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

function ICBT:CreateHud()
    local window = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "Hud")
    window:SetClampedToScreen(true)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawLevel(NORMAL_HUD_DRAW_LEVEL)
    window:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "HudBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backdrop:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    backdrop:SetInsets(5, 5, -5, -5)

    local title = self:CreateLabel(ADDON_NAME .. "HudTitle", window)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetText("IMPERIAL CITY BOSS TIMERS")

    self.window = window
    self.backdrop = backdrop
    self.titleLabel = title
    self.rows = {}

    for index, districtKey in ipairs(DISTRICT_ORDER) do
        local rowControl = WINDOW_MANAGER:CreateControl(
            string.format("%sHudRow%d", ADDON_NAME, index),
            window,
            CT_CONTROL
        )

        local countdownBar = WINDOW_MANAGER:CreateControl(
            string.format("%sHudRow%dCountdownBar", ADDON_NAME, index),
            rowControl,
            CT_BACKDROP
        )
        -- An untextured backdrop is a native solid fill. This avoids unsupported
        -- DDS formats and lets SetCenterColor apply the selected color exactly.
        countdownBar:SetInsets(0, 0, 0, 0)
        countdownBar:SetEdgeColor(0, 0, 0, 0)

        local nameLabel = self:CreateLabel(
            string.format("%sHudRow%dName", ADDON_NAME, index),
            rowControl
        )
        nameLabel:SetText(DISTRICTS[districtKey].name)

        local bossLabel = self:CreateLabel(
            string.format("%sHudRow%dBoss", ADDON_NAME, index),
            rowControl
        )

        local timeLabel = self:CreateLabel(
            string.format("%sHudRow%dTime", ADDON_NAME, index),
            rowControl
        )
        timeLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

        self.rows[districtKey] = {
            control = rowControl,
            countdownBar = countdownBar,
            name = nameLabel,
            boss = bossLabel,
            time = timeLabel,
        }
    end

    window:SetHandler("OnMoveStop", function()
        self:SaveDraggedPosition()
    end)

    self.menuPreviewDrawOrder = nil
    self:ApplyHudDrawOrder(false)
    self:ApplyHudLayout()
    self:ApplyHudAppearance()
end

function ICBT:ApplyHudDrawOrder(menuPreview)
    if not self.window or self.menuPreviewDrawOrder == menuPreview then return end

    local baseLevel = menuPreview and MENU_PREVIEW_DRAW_LEVEL or NORMAL_HUD_DRAW_LEVEL
    local function SetOrder(control, level)
        control:SetDrawTier(DT_HIGH)
        control:SetDrawLayer(DL_OVERLAY)
        control:SetDrawLevel(level)
    end

    SetOrder(self.window, baseLevel)
    SetOrder(self.backdrop, baseLevel)
    SetOrder(self.titleLabel, baseLevel + 2)

    for _, districtKey in ipairs(DISTRICT_ORDER) do
        local row = self.rows[districtKey]
        SetOrder(row.control, baseLevel + 1)
        SetOrder(row.countdownBar, baseLevel + 1)
        SetOrder(row.name, baseLevel + 2)
        SetOrder(row.boss, baseLevel + 2)
        SetOrder(row.time, baseLevel + 2)
    end

    self.menuPreviewDrawOrder = menuPreview
end

function ICBT:SetPositionFromPixels()
    if not self.window then return end

    local maximumX = math.max(0, GuiRoot:GetWidth() - self.window:GetWidth())
    local maximumY = math.max(0, GuiRoot:GetHeight() - self.window:GetHeight())
    local x = Clamp(self.sv.positionX, 0, maximumX)
    local y = Clamp(self.sv.positionY, 0, maximumY)

    self.window:ClearAnchors()
    self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function ICBT:SaveDraggedPosition()
    if not self.window or self.sv.lockPosition then return end

    local maximumX = math.max(0, GuiRoot:GetWidth() - self.window:GetWidth())
    local maximumY = math.max(0, GuiRoot:GetHeight() - self.window:GetHeight())
    local rootLeft = GuiRoot:GetLeft() or 0
    local rootTop = GuiRoot:GetTop() or 0
    self.sv.positionX = Clamp((self.window:GetLeft() or rootLeft) - rootLeft, 0, maximumX)
    self.sv.positionY = Clamp((self.window:GetTop() or rootTop) - rootTop, 0, maximumY)
end

function ICBT:ApplyHudLayout()
    if not self.window then return end

    local scale = self.sv.sizePercent / 100
    local width = math.floor(500 * scale)
    local padding = math.max(6, math.floor(14 * scale))
    local rowHeight = math.floor((self.sv.showLastBoss and 64 or 52) * scale)
    local titleHeight = self.sv.showTitle and math.floor(38 * scale) or 0
    local height = (padding * 2) + titleHeight + (#DISTRICT_ORDER * rowHeight)
    local contentWidth = width - (padding * 2)
    local timerWidth = math.floor(110 * scale)
    local nameWidth = contentWidth - timerWidth - math.max(1, math.floor(2 * scale))

    self.window:SetDimensions(width, height)
    self.window:SetMouseEnabled(not self.sv.lockPosition)
    self.window:SetMovable(not self.sv.lockPosition)

    self.titleLabel:ClearAnchors()
    self.titleLabel:SetAnchor(TOPLEFT, self.window, TOPLEFT, padding, padding)
    self.titleLabel:SetDimensions(contentWidth, titleHeight)
    self.titleLabel:SetHidden(not self.sv.showTitle)
    SetLabelFont(self.titleLabel, 20 * scale)

    self.layoutPadding = padding
    self.layoutRowStartY = padding + titleHeight
    self.layoutRowHeight = rowHeight
    self.lastRowOrderSignature = nil

    for _, districtKey in ipairs(DISTRICT_ORDER) do
        local row = self.rows[districtKey]
        row.control:SetDimensions(contentWidth, rowHeight)

        row.countdownBar:ClearAnchors()
        row.countdownBar:SetAnchor(LEFT, row.control, LEFT, 0, 0)
        row.countdownBar:SetDimensions(nameWidth, math.max(1, rowHeight - math.max(2, math.floor(4 * scale))))
        row.countdownBarMaxWidth = nameWidth

        row.time:ClearAnchors()
        row.time:SetAnchor(RIGHT, row.control, RIGHT, 0, 0)
        row.time:SetDimensions(timerWidth, rowHeight)
        SetLabelFont(row.time, 30 * scale)

        row.name:ClearAnchors()
        if self.sv.showLastBoss then
            local nameHeight = math.floor(rowHeight * 0.60)
            row.name:SetAnchor(TOPLEFT, row.control, TOPLEFT, 0, 0)
            row.name:SetDimensions(nameWidth, nameHeight)
            row.boss:ClearAnchors()
            row.boss:SetAnchor(BOTTOMLEFT, row.control, BOTTOMLEFT, 2 * scale, 0)
            row.boss:SetDimensions(nameWidth, rowHeight - nameHeight)
            row.boss:SetHidden(false)
            SetLabelFont(row.name, 28 * scale)
            SetLabelFont(row.boss, 14 * scale, "soft-shadow-thin")
        else
            row.name:SetAnchor(LEFT, row.control, LEFT, 0, 0)
            row.name:SetDimensions(nameWidth, rowHeight)
            row.boss:SetHidden(true)
            SetLabelFont(row.name, 31 * scale)
        end
    end

    self:ApplyRowOrder(self:GetDisplayOrder(self:IsPreviewActive()))
    self:SetPositionFromPixels()
end

function ICBT:ApplyHudAppearance()
    if not self.window then return end

    local colors = self.sv.colors
    local backgroundAlpha = self.sv.backgroundAlpha / 100
    self.backdrop:SetCenterColor(0, 0, 0, backgroundAlpha)
    self.backdrop:SetEdgeColor(
        colors.border[1],
        colors.border[2],
        colors.border[3],
        self.sv.showBorder and math.min(1, backgroundAlpha + 0.20) or 0
    )
    SetLabelColor(self.titleLabel, colors.title)

    for _, districtKey in ipairs(DISTRICT_ORDER) do
        local barColor = colors.countdownBar
        self.rows[districtKey].countdownBar:SetCenterColor(
            barColor[1],
            barColor[2],
            barColor[3],
            (barColor[4] or 1) * (self.sv.countdownBarAlpha / 100)
        )
        SetLabelColor(self.rows[districtKey].boss, colors.boss)
    end
end

function ICBT:BuildPreviewSamples()
    local timerDuration = self:GetTimerDurationSeconds()
    local ratio = timerDuration / DEFAULT_TIMER_SECONDS
    self.previewSamples = {}

    for _, districtKey in ipairs(DISTRICT_ORDER) do
        self.previewSamples[districtKey] = math.floor(PREVIEW_REFERENCE_SECONDS[districtKey] * ratio + 0.5)
    end

    self.previewStartedAt = GetFrameTimeSeconds()
end

function ICBT:IsSettingsPositionPreviewActive()
    return self.settingsPanelOpen
        and self.sv.showPositionPreview
end

function ICBT:IsPreviewActive()
    return self:IsSettingsPositionPreviewActive()
end

function ICBT:PreviewAfterSettingChange(rebuildSamples)
    if rebuildSamples or not self.previewSamples then
        self:BuildPreviewSamples()
    end
    self:ApplyHudLayout()
    self:ApplyHudAppearance()
    self:OnUpdate()
end

function ICBT:GetRemainingSeconds(districtKey, previewActive)
    if previewActive then
        local elapsed = math.max(0, GetFrameTimeSeconds() - (self.previewStartedAt or 0))
        return math.max(0, (self.previewSamples[districtKey] or 0) - elapsed)
    end

    local timer = self.sv.timers[districtKey]
    return math.max(0, timer.endsAt - GetTimeStamp())
end

function ICBT:GetDisplayOrder(previewActive)
    local order = {}
    for index, districtKey in ipairs(DISTRICT_ORDER) do
        order[index] = districtKey
    end

    if not self.sv.sortActiveTimers then
        return order
    end

    local remainingByDistrict = {}
    for _, districtKey in ipairs(order) do
        remainingByDistrict[districtKey] = self:GetRemainingSeconds(districtKey, previewActive)
    end

    table.sort(order, function(firstKey, secondKey)
        local firstRemaining = remainingByDistrict[firstKey]
        local secondRemaining = remainingByDistrict[secondKey]
        local firstActive = firstRemaining > 0
        local secondActive = secondRemaining > 0

        if firstActive ~= secondActive then
            return firstActive
        end
        if firstActive and firstRemaining ~= secondRemaining then
            return firstRemaining < secondRemaining
        end
        return DISTRICT_ORDER_INDEX[firstKey] < DISTRICT_ORDER_INDEX[secondKey]
    end)

    return order
end

function ICBT:ApplyRowOrder(order)
    if not self.layoutPadding or not self.layoutRowStartY or not self.layoutRowHeight then return end

    local signature = table.concat(order, ",")
    if signature == self.lastRowOrderSignature then return end

    for index, districtKey in ipairs(order) do
        local row = self.rows[districtKey]
        row.control:ClearAnchors()
        row.control:SetAnchor(
            TOPLEFT,
            self.window,
            TOPLEFT,
            self.layoutPadding,
            self.layoutRowStartY + ((index - 1) * self.layoutRowHeight)
        )
    end

    self.lastRowOrderSignature = signature
end

function ICBT:RefreshRows(previewActive)
    local colors = self.sv.colors
    local timerDuration = self:GetTimerDurationSeconds()

    for _, districtKey in ipairs(DISTRICT_ORDER) do
        local district = DISTRICTS[districtKey]
        local timer = self.sv.timers[districtKey]
        local row = self.rows[districtKey]
        local remaining = self:GetRemainingSeconds(districtKey, previewActive)
        local isReady = remaining <= 0
        local showCountdownBar = self.sv.showCountdownBars and not isReady

        row.countdownBar:SetHidden(not showCountdownBar)
        if showCountdownBar then
            local progress = Clamp(remaining / timerDuration, 0, 1)
            row.countdownBar:SetWidth(math.max(1, row.countdownBarMaxWidth * progress))
        end

        row.name:SetText(district.name)
        SetLabelColor(row.name, isReady and colors.ready or colors.countdown)
        row.time:SetText(
            isReady and (self.sv.readyTextMode == "ready" and "READY" or "00:00")
            or FormatSeconds(remaining)
        )
        SetLabelColor(row.time, isReady and colors.readyTimer or colors.countdownTimer)

        if self.sv.showLastBoss then
            local bossName
            if previewActive then
                bossName = district.bosses[1]
            elseif timer.bossName ~= "" then
                bossName = "Last: " .. timer.bossName
            else
                bossName = "No boss recorded"
            end
            row.boss:SetText(bossName)
        end
    end

    self:ApplyRowOrder(self:GetDisplayOrder(previewActive))
end

function ICBT:ShouldShowNormalHud()
    if not self.sv.showHud then return false end
    if self.sv.onlyInImperialCity and not IsInImperialCity() then return false end
    return true
end

function ICBT:IsGameplayHudSceneShowing()
    if HUD_SCENE and HUD_SCENE.IsShowing then
        return HUD_SCENE:IsShowing()
    end

    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene then
        local currentScene = SCENE_MANAGER:GetCurrentScene()
        return currentScene and currentScene.GetName and currentScene:GetName() == "hud"
    end

    return false
end

function ICBT:CheckReadyNotifications()
    local now = GetTimeStamp()
    for _, districtKey in ipairs(DISTRICT_ORDER) do
        local timer = self.sv.timers[districtKey]
        if timer.killedAt > 0 and not timer.readyNotified and timer.endsAt <= now then
            timer.readyNotified = true

            if self.sv.chatOnReady then
                self:Print(string.format("|c52FF52%s|r boss timer is ready.", DISTRICTS[districtKey].name))
            end
            if self.sv.soundOnReady then
                PlaySound(SOUNDS.OBJECTIVE_COMPLETED)
            end
        end
    end
end

function ICBT:OnUpdate()
    if not self.window then return end

    local positionPreviewActive = self:IsSettingsPositionPreviewActive()
    local previewActive = positionPreviewActive
    local shouldShow = positionPreviewActive
        or (self:IsGameplayHudSceneShowing() and self:ShouldShowNormalHud())
    self:ApplyHudDrawOrder(positionPreviewActive)
    self.window:SetHidden(not shouldShow)

    if shouldShow then
        self:RefreshRows(previewActive)
    end
    if not previewActive then
        self:CheckReadyNotifications()
    end
end

function ICBT:StartTimer(districtKey, bossName, manualStart)
    local district = DISTRICTS[districtKey]
    if not district then return end

    local now = GetTimeStamp()
    local timer = self.sv.timers[districtKey]
    timer.killedAt = now
    timer.endsAt = now + self:GetTimerDurationSeconds()
    timer.bossName = bossName or "Manual start"
    timer.readyNotified = false

    if self.sv.chatOnKill then
        local sourceText = manualStart and "manually started" or string.format("started after %s was defeated", timer.bossName)
        self:Print(string.format(
            "|cFF6A5C%s|r %s: %s.",
            district.name,
            sourceText,
            self:GetTimerModeLabel()
        ))
    end

    self:OnUpdate()
end

function ICBT:ClearTimer(districtKey)
    local timer = self.sv.timers[districtKey]
    if not timer then return end

    timer.killedAt = 0
    timer.endsAt = 0
    timer.bossName = ""
    timer.readyNotified = true
    self:OnUpdate()
end

function ICBT:ClearAllTimers()
    for _, districtKey in ipairs(DISTRICT_ORDER) do
        self:ClearTimer(districtKey)
    end
    self:Print("All district timers were reset to ready.")
end

function ICBT:RecalculateActiveTimers()
    local now = GetTimeStamp()
    local duration = self:GetTimerDurationSeconds()

    for _, districtKey in ipairs(DISTRICT_ORDER) do
        local timer = self.sv.timers[districtKey]
        if timer.killedAt > 0 then
            timer.endsAt = timer.killedAt + duration
            timer.readyNotified = timer.endsAt <= now
        end
    end
end

function ICBT:HandleBossDeathByName(unitName)
    if not IsInImperialCity() then return end

    local normalizedName = NormalizeUnitName(unitName)
    local districtKey = BOSS_LOOKUP[normalizedName]
    if not districtKey then return false end

    local now = GetTimeStamp()
    local lastEventAt = self.lastBossDeathEvents[normalizedName] or 0
    if now - lastEventAt < DEATH_EVENT_DEDUPLICATION_SECONDS then return false end

    self.lastBossDeathEvents[normalizedName] = now
    self.recentLiveBossSightings[normalizedName] = nil
    self:StartTimer(districtKey, BOSS_CANONICAL_NAMES[normalizedName] or unitName, false)
    return true
end

function ICBT:OnCombatEvent(_, result, _, _, _, _, _, _, targetName)
    if result ~= ACTION_RESULT_DIED and result ~= ACTION_RESULT_DIED_XP then return end
    self:HandleBossDeathByName(targetName)
end

function ICBT:OnUnitDeathStateChanged(_, unitTag, isDead)
    if not isDead or not unitTag then return end
    self:HandleBossDeathByName(GetUnitName(unitTag))
end

function ICBT:OnReticleTargetChanged()
    if not IsInImperialCity() then return end

    local unitName = GetUnitNameHighlightedByReticle()
    if not unitName or unitName == "" then
        unitName = GetUnitName("reticleover")
    end

    local normalizedName = NormalizeUnitName(unitName)
    if not BOSS_LOOKUP[normalizedName] then return end

    local now = GetTimeStamp()
    if not IsUnitDead("reticleover") then
        self.recentLiveBossSightings[normalizedName] = now
        return
    end

    local lastSeenAlive = self.recentLiveBossSightings[normalizedName]
    if lastSeenAlive and now - lastSeenAlive <= RETICLE_LIVE_CONFIRMATION_SECONDS then
        self:HandleBossDeathByName(unitName)
    end
end

function ICBT:RegisterBossDetectionEvents()
    local diedEventName = ADDON_NAME .. "CombatDied"
    local diedXpEventName = ADDON_NAME .. "CombatDiedXp"
    local unitDeathEventName = ADDON_NAME .. "UnitDeath"
    local reticleEventName = ADDON_NAME .. "ReticleTarget"

    EVENT_MANAGER:RegisterForEvent(diedEventName, EVENT_COMBAT_EVENT, function(...)
        self:OnCombatEvent(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(
        diedEventName,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_COMBAT_RESULT,
        ACTION_RESULT_DIED
    )

    EVENT_MANAGER:RegisterForEvent(diedXpEventName, EVENT_COMBAT_EVENT, function(...)
        self:OnCombatEvent(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(
        diedXpEventName,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_COMBAT_RESULT,
        ACTION_RESULT_DIED_XP
    )

    EVENT_MANAGER:RegisterForEvent(unitDeathEventName, EVENT_UNIT_DEATH_STATE_CHANGED, function(...)
        self:OnUnitDeathStateChanged(...)
    end)

    EVENT_MANAGER:RegisterForEvent(reticleEventName, EVENT_RETICLE_TARGET_CHANGED, function(...)
        self:OnReticleTargetChanged(...)
    end)
end

function ICBT:RegisterSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        self:Print("LibAddonMenu-2.0 r43 or newer is required.")
        return
    end

    local panelData = {
        type = "panel",
        name = DISPLAY_NAME,
        displayName = "|cFFD34E" .. DISPLAY_NAME .. "|r",
        author = "Paranoid Gaming",
        version = VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.settingsPanel = LAM:RegisterAddonPanel(ADDON_NAME .. "Settings", panelData)

    local districtChoices = {}
    local districtChoiceValues = {}
    for index, districtKey in ipairs(DISTRICT_ORDER) do
        districtChoices[index] = DISTRICTS[districtKey].name
        districtChoiceValues[index] = districtKey
    end

    local function SetColor(colorName, r, g, b, a)
        self.sv.colors[colorName] = CopyColor({ r, g, b, a or 1 }, DEFAULTS.colors[colorName])
        self:PreviewAfterSettingChange(false)
    end

    local optionsData = {
        {
            type = "description",
            text = "Tracks the Patrolling Horror respawn window for all six Imperial City districts. The HUD hides in menus and on the map. Turn on Preview HUD position below to keep a live sample above this settings menu while customizing it.",
        },
        {
            type = "checkbox",
            name = "Show timer HUD",
            tooltip = "Shows or hides the on-screen timer panel. Boss deaths continue to be tracked while the panel is hidden.",
            getFunc = function() return self.sv.showHud end,
            setFunc = function(value)
                self.sv.showHud = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.showHud,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Only show in Imperial City",
            tooltip = "Keeps the HUD hidden outside Imperial City. The explicit positioning preview can still appear in this add-on settings panel.",
            getFunc = function() return self.sv.onlyInImperialCity end,
            setFunc = function(value)
                self.sv.onlyInImperialCity = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.onlyInImperialCity,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Respawn timer mode",
            tooltip = "Default Timer is 15 minutes. Special Event Timer is 7 minutes. Changing this also recalculates timers already running from their recorded kill time.",
            choices = {
                "Default Timer: 15 minutes",
                "Special Event Timer: 7 minutes",
            },
            choicesValues = { "default", "event" },
            getFunc = function() return self.sv.timerMode end,
            setFunc = function(value)
                self.sv.timerMode = value == "event" and "event" or "default"
                self:RecalculateActiveTimers()
                self:PreviewAfterSettingChange(true)
            end,
            default = DEFAULTS.timerMode,
            width = "full",
        },
        {
            type = "header",
            name = "Layout and Preview",
        },
        {
            type = "checkbox",
            name = "Preview HUD position",
            tooltip = "Shows a live HUD sample above this add-on settings menu until switched off. It remains hidden in every other menu and on the map.",
            getFunc = function() return self.sv.showPositionPreview end,
            setFunc = function(value)
                self.sv.showPositionPreview = value
                self.settingsPanelOpen = true
                if value then
                    self:BuildPreviewSamples()
                end
                self:OnUpdate()
            end,
            default = DEFAULTS.showPositionPreview,
            width = "full",
        },
        {
            type = "slider",
            name = "HUD size",
            tooltip = "Scales the compact timer panel. The default is 65%, and it can be reduced to 40%.",
            min = 40,
            max = 165,
            step = 5,
            getFunc = function() return self.sv.sizePercent end,
            setFunc = function(value)
                self.sv.sizePercent = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.sizePercent,
            width = "full",
        },
        {
            type = "slider",
            name = "X position",
            tooltip = "Horizontal pixel offset from the top-left of the screen. The default is 1700. Turn on Preview HUD position to see changes above this menu.",
            min = 0,
            max = 3840,
            step = 5,
            getFunc = function() return self.sv.positionX end,
            setFunc = function(value)
                self.sv.positionX = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.positionX,
            width = "full",
        },
        {
            type = "slider",
            name = "Y position",
            tooltip = "Vertical pixel offset from the top-left of the screen. The default is 1000. Turn on Preview HUD position to see changes above this menu.",
            min = 0,
            max = 2160,
            step = 5,
            getFunc = function() return self.sv.positionY end,
            setFunc = function(value)
                self.sv.positionY = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.positionY,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Lock HUD position",
            tooltip = "Controller users can always use the position sliders. On PC, turning this off also allows mouse dragging.",
            getFunc = function() return self.sv.lockPosition end,
            setFunc = function(value)
                self.sv.lockPosition = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.lockPosition,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show title",
            tooltip = "Adds an Imperial City Boss Timers title above the six district rows.",
            getFunc = function() return self.sv.showTitle end,
            setFunc = function(value)
                self.sv.showTitle = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.showTitle,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show last defeated boss",
            tooltip = "Shows the most recently recorded boss beneath each district name.",
            getFunc = function() return self.sv.showLastBoss end,
            setFunc = function(value)
                self.sv.showLastBoss = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.showLastBoss,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Ready display",
            tooltip = "Choose the reference-style 00:00 display or the word READY when a district timer has finished.",
            choices = { "00:00", "READY" },
            choicesValues = { "zero", "ready" },
            getFunc = function() return self.sv.readyTextMode end,
            setFunc = function(value)
                self.sv.readyTextMode = value == "ready" and "ready" or "zero"
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.readyTextMode,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Sort active timers by shortest time",
            tooltip = "Moves active districts above ready districts and places the boss returning soonest at the top.",
            getFunc = function() return self.sv.sortActiveTimers end,
            setFunc = function(value)
                self.sv.sortActiveTimers = value
                self.lastRowOrderSignature = nil
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.sortActiveTimers,
            width = "full",
        },
        {
            type = "header",
            name = "Appearance",
        },
        {
            type = "checkbox",
            name = "Enable countdown bars",
            tooltip = "Shows a solid bar behind each active district name. The bar stops before the timer text and drains to empty when the boss is ready.",
            getFunc = function() return self.sv.showCountdownBars end,
            setFunc = function(value)
                self.sv.showCountdownBars = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.showCountdownBars,
            width = "full",
        },
        {
            type = "slider",
            name = "Countdown bar opacity",
            tooltip = "Controls how strongly the solid red bars appear behind active district names.",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return self.sv.countdownBarAlpha end,
            setFunc = function(value)
                self.sv.countdownBarAlpha = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.countdownBarAlpha,
            width = "full",
            disabled = function() return not self.sv.showCountdownBars end,
        },
        {
            type = "colorpicker",
            name = "Countdown bar color",
            tooltip = "Changes the color of the solid draining bars behind active timers.",
            getFunc = function() return unpack(self.sv.colors.countdownBar) end,
            setFunc = function(...) SetColor("countdownBar", ...) end,
            default = DEFAULTS.colors.countdownBar,
            width = "full",
            disabled = function() return not self.sv.showCountdownBars end,
        },
        {
            type = "slider",
            name = "Black background opacity",
            tooltip = "Controls the transparency of the black panel behind the timers. Set to 0% for fully transparent or 100% for solid black.",
            min = 0,
            max = 100,
            step = 5,
            getFunc = function() return self.sv.backgroundAlpha end,
            setFunc = function(value)
                self.sv.backgroundAlpha = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.backgroundAlpha,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Countdown district color",
            tooltip = "Color used for a district name while its timer is running.",
            getFunc = function() return unpack(self.sv.colors.countdown) end,
            setFunc = function(...) SetColor("countdown", ...) end,
            default = DEFAULTS.colors.countdown,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Ready district color",
            tooltip = "Color used for a district name after its timer reaches zero.",
            getFunc = function() return unpack(self.sv.colors.ready) end,
            setFunc = function(...) SetColor("ready", ...) end,
            default = DEFAULTS.colors.ready,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Countdown text color",
            tooltip = "Color used for the countdown numbers. The default is red.",
            getFunc = function() return unpack(self.sv.colors.countdownTimer) end,
            setFunc = function(...) SetColor("countdownTimer", ...) end,
            default = DEFAULTS.colors.countdownTimer,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Ready text color",
            tooltip = "Color used for READY or 00:00 after a boss can respawn. The default is green.",
            getFunc = function() return unpack(self.sv.colors.readyTimer) end,
            setFunc = function(...) SetColor("readyTimer", ...) end,
            default = DEFAULTS.colors.readyTimer,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Title color",
            tooltip = "Color of the optional title.",
            getFunc = function() return unpack(self.sv.colors.title) end,
            setFunc = function(...) SetColor("title", ...) end,
            default = DEFAULTS.colors.title,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Last boss color",
            tooltip = "Color of the optional last-defeated boss line.",
            getFunc = function() return unpack(self.sv.colors.boss) end,
            setFunc = function(...) SetColor("boss", ...) end,
            default = DEFAULTS.colors.boss,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show window border",
            tooltip = "Displays the thin border around the timer window. This is off by default.",
            getFunc = function() return self.sv.showBorder end,
            setFunc = function(value)
                self.sv.showBorder = value
                self:PreviewAfterSettingChange(false)
            end,
            default = DEFAULTS.showBorder,
            width = "full",
        },
        {
            type = "colorpicker",
            name = "Border color",
            tooltip = "Color of the thin border around the black timer panel.",
            getFunc = function() return unpack(self.sv.colors.border) end,
            setFunc = function(...) SetColor("border", ...) end,
            default = DEFAULTS.colors.border,
            width = "full",
            disabled = function() return not self.sv.showBorder end,
        },
        {
            type = "header",
            name = "Notifications",
        },
        {
            type = "checkbox",
            name = "Chat message when a boss dies",
            tooltip = "Confirms the boss name, district, and timer mode when a timer starts.",
            getFunc = function() return self.sv.chatOnKill end,
            setFunc = function(value) self.sv.chatOnKill = value end,
            default = DEFAULTS.chatOnKill,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Chat message when a timer is ready",
            tooltip = "Posts a system message when a district countdown reaches zero.",
            getFunc = function() return self.sv.chatOnReady end,
            setFunc = function(value) self.sv.chatOnReady = value end,
            default = DEFAULTS.chatOnReady,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Sound when a timer is ready",
            tooltip = "Plays ESO's objective-completed sound when a district countdown reaches zero.",
            getFunc = function() return self.sv.soundOnReady end,
            setFunc = function(value) self.sv.soundOnReady = value end,
            default = DEFAULTS.soundOnReady,
            width = "full",
        },
        {
            type = "header",
            name = "Manual Timer Controls",
        },
        {
            type = "description",
            text = "Automatic detection checks combat results, unit death state, and a boss you recently targeted. Use these controller-friendly controls if ESO misses every death event or you need to correct a timer.",
        },
        {
            type = "dropdown",
            name = "District",
            choices = districtChoices,
            choicesValues = districtChoiceValues,
            getFunc = function() return self.sv.manualDistrict end,
            setFunc = function(value) self.sv.manualDistrict = value end,
            default = DEFAULTS.manualDistrict,
            width = "full",
        },
        {
            type = "button",
            name = "Start selected district timer",
            tooltip = "Starts the selected district using the current 15-minute or 7-minute mode.",
            func = function()
                self:StartTimer(self.sv.manualDistrict, "Manual start", true)
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Set selected district ready",
            tooltip = "Clears the selected district countdown and displays it as ready.",
            func = function()
                self:ClearTimer(self.sv.manualDistrict)
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Reset all district timers",
            tooltip = "Clears all six countdowns and sets every district to ready.",
            func = function()
                self:ClearAllTimers()
            end,
            isDangerous = true,
            warning = "This clears all six recorded timers.",
            width = "full",
        },
    }

    LAM:RegisterOptionControls(ADDON_NAME .. "Settings", optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == self.settingsPanel then
            self.settingsPanelOpen = true
            if self.sv.showPositionPreview then
                self:BuildPreviewSamples()
            end
            self:OnUpdate()
        end
    end)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == self.settingsPanel then
            self.settingsPanelOpen = false
            self:OnUpdate()
        end
    end)
end

function ICBT:OpenSettings()
    if LibAddonMenu2 and self.settingsPanel then
        LibAddonMenu2:OpenToPanel(self.settingsPanel)
    else
        self:Print("The settings panel is unavailable. Check that LibAddonMenu-2.0 r43 or newer is enabled.")
    end
end

function ICBT:RegisterSlashCommand()
    SLASH_COMMANDS["/icbt"] = function(text)
        local command = string.lower(Trim(text))
        if command == "preview" then
            self.sv.showPositionPreview = true
            self:OpenSettings()
        elseif command == "show" then
            self.sv.showHud = true
            self:OnUpdate()
        elseif command == "hide" then
            self.sv.showHud = false
            self:OnUpdate()
        elseif command == "help" then
            self:Print("Commands: /icbt, /icbt preview, /icbt show, /icbt hide. Preview enables the settings toggle and opens the panel.")
        else
            self:OpenSettings()
        end
    end
end

function ICBT:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide(
        SAVED_VARIABLES_NAME,
        SAVED_VARIABLES_VERSION,
        nil,
        DEFAULTS,
        GetWorldName()
    )

    self.lastBossDeathEvents = {}
    self.recentLiveBossSightings = {}
    self.settingsPanelOpen = false
    self.previewSamples = nil

    self:ValidateSavedVariables()
    self:MarkOldTimersAsNotified()
    self:CreateHud()
    self:RegisterSettings()
    self:RegisterBossDetectionEvents()
    self:RegisterSlashCommand()

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "Update", UPDATE_INTERVAL_MS, function()
        self:OnUpdate()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        self:SetPositionFromPixels()
        self:OnUpdate()
    end)

    self:OnUpdate()
    self:Print("Loaded. Open Settings > Add-ons > Imperial City Boss Timers, or type /icbt.")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, loadedAddonName)
    if loadedAddonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    ICBT:Initialize()
end)
