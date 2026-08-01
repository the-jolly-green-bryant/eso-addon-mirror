ProcReminder.UI = ProcReminder.UI or {}
local UI = ProcReminder.UI
local em = EVENT_MANAGER

-- UI Configuration
UI.panels = {}
UI.activeProc = nil
UI.animationDuration = 0.5  -- seconds for animation
UI.displayDuration = 4.0    -- seconds to show proc
UI.hideDelay = 0.3          -- delay before fading out

local function RGBToHex(r, g, b)
    r = math.floor(r * 255)
    g = math.floor(g * 255)
    b = math.floor(b * 255)
    if r == 65025 and g == 65025 and b == 65025 then
        return "FFFFFF"
    end
    return string.format("%02X%02X%02X", r, g, b)
end

local FONT_BOLD   = "EsoUI/Common/Fonts/FiraSansOP-ExtraBold.ttf"
local FONT_NORMAL = "EsoUI/Common/Fonts/FiraSansOP-Regular.ttf"

local function BuildFont(path, size, style)
    return path .. "|" .. tostring(math.floor(size)) .. "|" .. (style or "soft-shadow-thick")
end

function UI:CreateProcPanel()
    local s = ProcReminder.settings
    local iconSize = (s and s.iconSize) or 80
    local posX     = (s and s.posX)     or 0
    local posY     = (s and s.posY)     or -150
    local fontSize = (s and s.fontSize) or 30
    local uiScale  = (s and s.uiScale)  or 1.0

    local panel = WINDOW_MANAGER:CreateTopLevelWindow("ProcReminder_Panel")
    panel:SetDimensions(520, 130)
    panel:SetAnchor(CENTER, GuiRoot, CENTER, posX, posY)
    panel:SetScale(uiScale)

    -- Glow behind icon
    local iconBg = WINDOW_MANAGER:CreateControl("ProcReminder_IconBG", panel, CT_TEXTURE)
    iconBg:SetDimensions(iconSize + 10, iconSize + 10)
    iconBg:SetAnchor(LEFT, panel, LEFT, 0, 0)
    iconBg:SetTexture("esoui/art/buttons/roundbutton01_normal.dds")
    iconBg:SetColor(1, 0.5, 0)
    iconBg:SetAlpha(0.3)

    -- Ability icon
    local icon = WINDOW_MANAGER:CreateControl("ProcReminder_Icon", panel, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(LEFT, panel, LEFT, 5, 0)
    icon:SetTexture("esoui/art/abilities/ability_generic.dds")

    -- Ability slot frame on top of icon
    local iconFrame = WINDOW_MANAGER:CreateControl("ProcReminder_IconFrame", panel, CT_TEXTURE)
    iconFrame:SetDimensions(iconSize, iconSize)
    iconFrame:SetAnchor(CENTER, icon, CENTER, 0, 0)
    iconFrame:SetTexture("esoui/art/actionbar/actionslot_normalframe.dds")

    -- Proc name label
    local procLabel = WINDOW_MANAGER:CreateControl("ProcReminder_ProcLabel", panel, CT_LABEL)
    procLabel:SetDimensions(400, 55)
    procLabel:SetAnchor(TOPLEFT, icon, TOPRIGHT, 14, 0)
    procLabel:SetFont(BuildFont(FONT_BOLD, fontSize))
    procLabel:SetText("Proc Ready!")
    procLabel:SetColor(1, 0.7, 0)

    -- Sub label
    local statusLabel = WINDOW_MANAGER:CreateControl("ProcReminder_StatusLabel", panel, CT_LABEL)
    statusLabel:SetDimensions(400, 28)
    statusLabel:SetAnchor(TOPLEFT, procLabel, BOTTOMLEFT, 0, 0)
    statusLabel:SetFont(BuildFont(FONT_NORMAL, math.max(14, fontSize - 12)))
    statusLabel:SetText("Use Soon!")
    statusLabel:SetColor(1, 1, 1)

    -- Status bar track
    local statusBarBg = WINDOW_MANAGER:CreateControl("ProcReminder_StatusBarBG", panel, CT_TEXTURE)
    statusBarBg:SetDimensions(400, 4)
    statusBarBg:SetAnchor(TOPLEFT, statusLabel, BOTTOMLEFT, 0, 6)
    statusBarBg:SetTexture("esoui/art/miscellaneous/horizontalline.dds")
    statusBarBg:SetColor(0.3, 0.3, 0.3)
    statusBarBg:SetAlpha(0.6)

    -- Status bar fill
    local statusBar = WINDOW_MANAGER:CreateControl("ProcReminder_StatusBar", panel, CT_TEXTURE)
    statusBar:SetDimensions(400, 4)
    statusBar:SetAnchor(TOPLEFT, statusBarBg, TOPLEFT, 0, 0)
    statusBar:SetTexture("esoui/art/miscellaneous/horizontalline.dds")
    statusBar:SetColor(1, 0.5, 0)
    statusBar:SetAlpha(0.9)

    panel:SetHidden(true)

    self.panels = {
        panel        = panel,
        icon         = icon,
        iconBg       = iconBg,
        iconFrame    = iconFrame,
        procLabel    = procLabel,
        statusLabel  = statusLabel,
        statusBar    = statusBar,
        statusBarBg  = statusBarBg,
    }
end

function UI:ApplySettings()
    local p = self.panels
    if not p or not p.panel then return end

    local s = ProcReminder.settings
    local iconSize = s.iconSize or 80
    local fontSize = s.fontSize or 30

    p.panel:ClearAnchors()
    p.panel:SetAnchor(CENTER, GuiRoot, CENTER, s.posX or 0, s.posY or -150)
    p.panel:SetScale(s.uiScale or 1.0)

    p.icon:SetDimensions(iconSize, iconSize)
    p.iconBg:SetDimensions(iconSize + 10, iconSize + 10)
    p.iconFrame:SetDimensions(iconSize, iconSize)

    p.procLabel:SetFont(BuildFont(FONT_BOLD, fontSize))
    p.statusLabel:SetFont(BuildFont(FONT_NORMAL, math.max(14, fontSize - 12)))
end

function UI:AnimateIn()
    local p = self.panels
    if not p or not p.panel then return end

    p.panel:SetAlpha(0)
    p.panel:SetHidden(false)

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local anim = timeline:InsertAnimation(ANIMATION_ALPHA, p.panel, 0)
    anim:SetAlphaValues(0, 1)
    anim:SetDuration(UI.animationDuration * 1000)
    timeline:PlayFromStart()
end

function UI:AnimateStatusBar(duration)
    local p = self.panels
    if not p or not p.statusBar then return end

    -- Drain the bar width over time using periodic updates
    local barWidth = 400
    local stepMs = 50
    local steps = (duration * 1000) / stepMs
    local widthPerStep = barWidth / steps
    local currentWidth = barWidth
    p.statusBar:SetWidth(barWidth)

    local function drain()
        currentWidth = currentWidth - widthPerStep
        if currentWidth <= 0 then
            p.statusBar:SetWidth(0)
            return
        end
        p.statusBar:SetWidth(currentWidth)
        zo_callLater(drain, stepMs)
    end
    zo_callLater(drain, stepMs)
end

function UI:SetStatusBarColor(r, g, b)
    if self.panels and self.panels.statusBar then
        self.panels.statusBar:SetColor(r, g, b)
    end
end

function UI:FadeOut()
    local p = self.panels
    if not p or not p.panel or p.panel:IsHidden() then return end

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local anim = timeline:InsertAnimation(ANIMATION_ALPHA, p.panel, 0)
    anim:SetAlphaValues(1, 0)
    anim:SetDuration(500)
    timeline:SetHandler("OnStop", function()
        p.panel:SetHidden(true)
    end)
    timeline:PlayFromStart()
end

function UI:ShowProc(procText, iconPath, duration)
    if not self.panels or not self.panels.panel then
        self:CreateProcPanel()
    end

    local p = self.panels
    if not p or not p.panel then return end

    duration = duration or UI.displayDuration

    -- Set text
    p.procLabel:SetText(procText)

    -- Set icon
    if iconPath and iconPath ~= "" then
        p.icon:SetTexture(iconPath)
    end

    -- Apply settings colors (with fallbacks)
    local primColor = (ProcReminder.settings and ProcReminder.settings.primColor) or {r = 1, g = 0.7, b = 0}
    local secColor = (ProcReminder.settings and ProcReminder.settings.secColor) or {r = 1, g = 1, b = 1}

    p.procLabel:SetColor(primColor.r, primColor.g, primColor.b)
    p.statusLabel:SetColor(secColor.r, secColor.g, secColor.b)

    -- Apply status bar color
    local barColor = (ProcReminder.settings and ProcReminder.settings.statusBarColor) or {r = 1, g = 0.5, b = 0}
    self:SetStatusBarColor(barColor.r, barColor.g, barColor.b)

    -- Show with fade-in and drain status bar
    self:AnimateIn()
    self:AnimateStatusBar(duration)

    -- Schedule fade out
    zo_callLater(function()
        UI:FadeOut()
    end, duration * 1000)
end

function UI:Initialize()
    self:CreateProcPanel()
    self:ApplySettings()
end
