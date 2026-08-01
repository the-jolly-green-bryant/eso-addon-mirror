KayzarUI = KayzarUI or {}
local KayzarUI = KayzarUI

local ADDON_NAME = "KayzarUI"
local EM = EVENT_MANAGER

------------------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------------------
KayzarUI.BAR_TEXTURES = {
    ["Smooth"]      = "KayzarUI/textures/bar_smooth.dds",
    ["Flat"]        = "KayzarUI/textures/bar_flat.dds",
    ["Gloss"]       = "KayzarUI/textures/bar_gloss.dds",
    ["Gradient"]    = "KayzarUI/textures/bar_gradient.dds",
    ["Striped"]     = "KayzarUI/textures/bar_striped.dds",
    ["Glass"]       = "KayzarUI/textures/bar_glass.dds",
    ["Metal"]       = "KayzarUI/textures/bar_metal.dds",
    ["Pixel"]       = "KayzarUI/textures/bar_pixel.dds",
    ["Charcoal"]    = "KayzarUI/textures/bar_charcoal.dds",
    ["Neon"]        = "KayzarUI/textures/bar_neon.dds",
    ["Marble"]      = "KayzarUI/textures/bar_marble.dds",
    ["Minimal"]     = "KayzarUI/textures/bar_minimal.dds",
    ["|cFF4444Electric|r"]    = "KayzarUI/textures/bar_electric.dds",
    ["|cFF4444Plasma|r"]      = "KayzarUI/textures/bar_plasma.dds",
    ["|cFF4444Fire|r"]        = "KayzarUI/textures/bar_fire.dds",
    ["|cFF4444Hex Grid|r"]    = "KayzarUI/textures/bar_hexgrid.dds",
    ["|cFF4444Circuit|r"]     = "KayzarUI/textures/bar_circuit.dds",
    ["|cFF4444Aurora|r"]      = "KayzarUI/textures/bar_aurora.dds",
    ["|cFF4444Hologram|r"]    = "KayzarUI/textures/bar_hologram.dds",
    ["|cFF4444Crystalline|r"] = "KayzarUI/textures/bar_crystalline.dds",
    ["|cFF4444Lava|r"]        = "KayzarUI/textures/bar_lava.dds",
    ["|cFF4444Matrix|r"]      = "KayzarUI/textures/bar_matrix.dds",
    ["|cFF4444Carbon Fiber|r"]= "KayzarUI/textures/bar_carbon.dds",
    ["|cFF4444Frost|r"]       = "KayzarUI/textures/bar_frost.dds",
}

KayzarUI.BAR_TEXTURE_NAMES = {}
for k in pairs(KayzarUI.BAR_TEXTURES) do
    KayzarUI.BAR_TEXTURE_NAMES[#KayzarUI.BAR_TEXTURE_NAMES + 1] = k
end
table.sort(KayzarUI.BAR_TEXTURE_NAMES)

KayzarUI.LAYOUT_MODES    = {"Stacked", "Horizontal", "Vertical", "Minimal", "Pyramid", "Center Stack", "Wide", "Compact", "Diamond"}
KayzarUI.BAR_SHAPES      = {"Rectangle", "Rounded", "Thin", "Thick", "Slim", "Extra Thick", "Flat Line", "Chunky"}
KayzarUI.TEXT_MODES       = {"Value + Percent", "Value Only", "Percent Only", "Current Only", "None"}
KayzarUI.TARGET_NAME_MODES = {"Character Name", "UserID", "Character + UserID"}

------------------------------------------------------------------------
-- STYLE PRESETS
------------------------------------------------------------------------
local function S(ac, hc, mc, sc, uc, bg, bc, nc, lc, ui)
    return {
        accentColor    = ac, healthColor   = hc, magickaColor  = mc,
        staminaColor   = sc, ultimateColor = uc, frameBgColor  = bg,
        frameBorderColor = bc, nameColor   = nc, levelColor    = lc,
        uiSchemeColor  = ui,
    }
end

local function C(r, g, b, a)
    return {r = r, g = g, b = b, a = a or 1}
end

KayzarUI.STYLES = {
    ["Glint Pink"]    = S(C(.95,.30,.55),C(.90,.15,.30),C(.55,.20,.80),C(.85,.35,.50),C(1,.45,.65),C(.08,.03,.06,.85),C(.95,.30,.55,.35),C(.95,.30,.55),C(1,.45,.65),C(.95,.30,.55)),
    ["Glint Magenta"] = S(C(.90,.10,.65),C(.85,.10,.35),C(.60,.15,.85),C(.80,.25,.55),C(1,.30,.70),C(.07,.02,.06,.85),C(.90,.10,.65,.35),C(.90,.10,.65),C(1,.30,.70),C(.90,.10,.65)),
    ["Glint Rose"]    = S(C(1,.45,.55),C(.95,.20,.35),C(.50,.25,.75),C(.90,.40,.50),C(1,.55,.60),C(.09,.04,.05,.85),C(1,.45,.55,.35),C(1,.45,.55),C(1,.55,.60),C(1,.45,.55)),
    ["Glint Coral"]   = S(C(1,.50,.35),C(.92,.25,.20),C(.35,.30,.80),C(.85,.50,.30),C(1,.60,.40),C(.08,.04,.03,.85),C(1,.50,.35,.35),C(1,.50,.35),C(1,.60,.40),C(1,.50,.35)),
    ["Glint Violet"]  = S(C(.70,.30,.90),C(.80,.15,.25),C(.45,.20,.90),C(.60,.35,.80),C(.80,.40,1),C(.05,.02,.08,.85),C(.70,.30,.90,.35),C(.70,.30,.90),C(.80,.40,1),C(.70,.30,.90)),
    ["Glint Cyan"]    = S(C(.20,.85,.90),C(.80,.15,.15),C(.15,.55,.90),C(.20,.80,.60),C(.30,.95,1),C(.02,.06,.08,.85),C(.20,.85,.90,.35),C(.20,.85,.90),C(.30,.95,1),C(.20,.85,.90)),
    ["Glint Amber"]   = S(C(.95,.70,.20),C(.85,.20,.15),C(.25,.40,.85),C(.80,.65,.15),C(1,.80,.25),C(.08,.06,.02,.85),C(.95,.70,.20,.35),C(.95,.70,.20),C(1,.80,.25),C(.95,.70,.20)),
    ["Glint Mint"]    = S(C(.30,.90,.65),C(.75,.18,.18),C(.20,.45,.85),C(.25,.85,.50),C(.40,1,.70),C(.03,.07,.05,.85),C(.30,.90,.65,.35),C(.30,.90,.65),C(.40,1,.70),C(.30,.90,.65)),
    ["Crimson Glow"]  = S(C(.92,.18,.25),C(.95,.10,.15),C(.40,.15,.70),C(.80,.25,.20),C(1,.35,.30),C(.08,.02,.03,.85),C(.92,.18,.25,.35),C(.92,.18,.25),C(1,.35,.30),C(.92,.18,.25)),
    ["Kayzar Orange"] = S(C(.82,.45,.12),C(.78,.15,.15),C(.18,.42,.82),C(.22,.72,.32),C(.92,.78,.15),C(.06,.06,.08,.85),C(.82,.45,.12,.35),C(.82,.45,.12),C(.92,.78,.15),C(.82,.45,.12)),
    ["Nightblade Red"]= S(C(.85,.12,.12),C(.90,.10,.10),C(.20,.35,.80),C(.25,.70,.30),C(.95,.25,.25),C(.08,.03,.03,.85),C(.85,.12,.12,.35),C(.85,.12,.12),C(.95,.25,.25),C(.85,.12,.12)),
    ["Templar Gold"]  = S(C(.90,.75,.30),C(.80,.20,.15),C(.22,.45,.85),C(.25,.75,.35),C(.95,.85,.30),C(.08,.07,.04,.85),C(.90,.75,.30,.35),C(.90,.75,.30),C(.95,.85,.30),C(.90,.75,.30)),
    ["Warden Green"]  = S(C(.20,.72,.40),C(.75,.18,.18),C(.15,.40,.80),C(.18,.78,.35),C(.40,.90,.50),C(.03,.07,.04,.85),C(.20,.72,.40,.35),C(.20,.72,.40),C(.40,.90,.50),C(.20,.72,.40)),
    ["Sorcerer Blue"] = S(C(.30,.55,.95),C(.80,.15,.15),C(.25,.50,.95),C(.22,.72,.32),C(.45,.70,1),C(.03,.04,.09,.85),C(.30,.55,.95,.35),C(.30,.55,.95),C(.45,.70,1),C(.30,.55,.95)),
    ["Necro Purple"]  = S(C(.60,.25,.80),C(.80,.15,.15),C(.20,.40,.82),C(.22,.72,.32),C(.70,.35,.95),C(.06,.03,.08,.85),C(.60,.25,.80,.35),C(.60,.25,.80),C(.70,.35,.95),C(.60,.25,.80)),
    ["Minimal Dark"]  = S(C(.65,.65,.65),C(.70,.18,.18),C(.18,.40,.78),C(.20,.68,.30),C(.80,.80,.30),C(.04,.04,.04,.92),C(.30,.30,.30,.20),C(.65,.65,.65),C(.80,.80,.30),C(.65,.65,.65)),
    ["|cFF4444Neon Viper|r"]    = S(C(0,1,.35),C(0,.95,.15),C(0,.50,1),C(.20,1,.20),C(.60,1,0),C(.01,.04,.01,.92),C(0,1,.35,.40),C(0,1,.45),C(.50,1,0),C(0,1,.35)),
    ["|cFF4444Cyberpunk|r"]     = S(C(1,0,.85),C(.95,.05,.40),C(0,.80,1),C(1,.90,0),C(1,0,.60),C(.05,.01,.06,.90),C(1,0,.85,.35),C(1,0,.90),C(0,.95,1),C(1,0,.85)),
    ["|cFF4444Blood Moon|r"]    = S(C(.85,0,.05),C(.95,.05,.05),C(.15,.08,.50),C(.60,.05,.05),C(1,.10,.10),C(.06,.01,.01,.95),C(.85,0,.05,.30),C(.90,.10,.10),C(1,.15,.10),C(.85,0,.05)),
    ["|cFF4444Arctic Ice|r"]    = S(C(.60,.90,1),C(.15,.70,.90),C(.20,.55,1),C(.50,.85,.95),C(.80,1,1),C(.02,.04,.07,.90),C(.60,.90,1,.30),C(.70,.95,1),C(.85,1,1),C(.60,.90,1)),
    ["|cFF4444Inferno|r"]       = S(C(1,.45,0),C(1,.15,0),C(.30,.10,.80),C(1,.60,0),C(1,.80,.10),C(.08,.03,.01,.92),C(1,.45,0,.35),C(1,.55,.10),C(1,.80,.20),C(1,.45,0)),
    ["|cFF4444Toxic Waste|r"]   = S(C(.50,1,0),C(.70,.15,.15),C(.10,.40,.70),C(.60,.90,.10),C(.80,1,.20),C(.03,.05,.01,.90),C(.50,1,0,.35),C(.55,1,.10),C(.80,1,.30),C(.50,1,0)),
    ["|cFF4444Void|r"]          = S(C(.40,.10,.60),C(.50,.05,.30),C(.15,.10,.50),C(.35,.15,.45),C(.60,.20,.80),C(.02,.01,.04,.95),C(.40,.10,.60,.25),C(.50,.20,.70),C(.60,.30,.80),C(.40,.10,.60)),
    ["|cFF4444Sunset|r"]        = S(C(1,.50,.20),C(.95,.25,.15),C(.30,.20,.70),C(1,.70,.30),C(1,.85,.40),C(.08,.04,.02,.88),C(1,.50,.20,.30),C(1,.60,.25),C(1,.80,.35),C(1,.50,.20)),
    ["|cFF4444Galaxy|r"]        = S(C(.55,.30,1),C(.70,.15,.55),C(.25,.40,1),C(.40,.80,.70),C(.70,.50,1),C(.03,.02,.08,.92),C(.55,.30,1,.30),C(.65,.40,1),C(.80,.55,1),C(.55,.30,1)),
    ["|cFF4444Shadow Gold|r"]   = S(C(.85,.70,.15),C(.80,.20,.10),C(.15,.35,.75),C(.75,.60,.10),C(1,.90,.25),C(.05,.04,.02,.95),C(.85,.70,.15,.25),C(.90,.80,.20),C(1,.95,.30),C(.85,.70,.15)),
    ["|cFF4444Phantom White|r"] = S(C(.92,.92,.95),C(.80,.15,.15),C(.20,.45,.85),C(.22,.75,.35),C(.95,.95,.60),C(.06,.06,.07,.90),C(.85,.85,.90,.20),C(.95,.95,1),C(.85,.85,.90),C(.92,.92,.95)),
    ["|cFF4444Demon King|r"]    = S(C(.90,.10,.10),C(1,0,0),C(.50,0,.70),C(.90,.40,0),C(1,.20,.20),C(.04,.01,.01,.95),C(.90,.10,.10,.40),C(1,.15,.10),C(1,.30,.10),C(.90,.10,.10)),
}

KayzarUI.STYLE_NAMES = {}
for k in pairs(KayzarUI.STYLES) do
    KayzarUI.STYLE_NAMES[#KayzarUI.STYLE_NAMES + 1] = k
end
table.sort(KayzarUI.STYLE_NAMES)

------------------------------------------------------------------------
-- DEFAULTS
------------------------------------------------------------------------
local DEFAULT_SETTINGS = {
    stylePreset     = "Glint Pink",
    lockFrames      = false,
    showWelcome     = true,
    accentColor     = C(.95, .30, .55),
    healthColor     = C(.90, .15, .30),
    magickaColor    = C(.55, .20, .80),
    staminaColor    = C(.85, .35, .50),
    ultimateColor   = C(1, .45, .65),
    frameBgColor    = C(.08, .03, .06, .85),
    frameBorderColor = C(.95, .30, .55, .35),
    nameColor       = C(.95, .30, .55),
    levelColor      = C(1, .45, .65),
    textColor       = C(1, 1, 1),
    uiSchemeEnabled = true,
    uiSchemeColor   = C(.95, .30, .55),
    targetNameMode  = "Character Name",
    showAllElements = false,
    gradientEnabled = false,
    healthGradientEnd  = C(.60, .05, .15),
    magickaGradientEnd = C(.30, .10, .55),
    staminaGradientEnd = C(.55, .20, .30),
    elements = {
        playerName = true, playerLevel = true, playerUlt = true,
        healthBar  = true, magickaBar  = true, staminaBar = true,
        targetName = true, targetLevel = true, targetHealth = true,
        barIndicator = true,
    },
    unitFrames = {
        enabled        = true,
        playerEnabled  = true,
        targetEnabled  = true,
        barWidth       = 280,
        textMode       = "Value + Percent",
        animateBars    = false,
        showBackground = false,
        showBorder     = false,
        bgOpacity      = 85,
        barTexture     = "Smooth",
        barShape       = "Rectangle",
        barSpacing     = 4,
        layoutMode     = "Stacked",
        healthBarHeight  = 22,
        magickaBarHeight = 14,
        staminaBarHeight = 14,
        resourceBarHeight = 14,
        healthBarWidth   = 0,
        magickaBarWidth  = 0,
        staminaBarWidth  = 0,
        independentBars  = false,
        healthOffsetX = 0, healthOffsetY = 0,
        magickaOffsetX = 0, magickaOffsetY = 0,
        staminaOffsetX = 0, staminaOffsetY = 0,
        fadeOutOfCombat = false,
        fadeAlpha       = 40,
        showPlayerName  = true,
        showPlayerLevel = true,
        showTargetName  = true,
        showTargetLevel = true,
        playerOffsetX = -340,
        playerOffsetY = 340,
        targetOffsetX = 340,
        targetOffsetY = 340,
    },
    actionBar = {
        enabled          = true,
        showCooldownText = true,
        showUltimateCost = true,
        showBarIndicator = true,
        barOpacity       = 100,
        barIndicatorWidth  = 44,
        barIndicatorHeight = 26,
        barIndicatorOffsetX = 0,
        barIndicatorOffsetY = 300,
    },
    shield = {
        enabled        = true,
        color          = C(.30, .70, 1, .55),
        overshieldColor = C(.90, .85, .20, .65),
    },
    buffTracker = {
        enabled   = true,
        iconSize  = 36,
        maxBuffs  = 12,
        showTimer = true,
        showName  = false,
    },
    targetDebuffs = {
        enabled    = true,
        iconSize   = 30,
        maxDebuffs = 8,
    },
}
KayzarUI.DEFAULT_SETTINGS = DEFAULT_SETTINGS

------------------------------------------------------------------------
-- UTILITY
------------------------------------------------------------------------
function KayzarUI.Print(msg)
    d("|cF24D8C[KayzarUI]|r " .. tostring(msg))
end

function KayzarUI.FormatNumber(n)
    if n >= 1e6 then
        return string.format("%.1fM", n / 1e6)
    elseif n >= 1e3 then
        return string.format("%.1fK", n / 1e3)
    end
    return tostring(zo_floor(n))
end

function KayzarUI.GetBarTexture()
    local n = KayzarUI.sv and KayzarUI.sv.unitFrames.barTexture or "Smooth"
    return KayzarUI.BAR_TEXTURES[n] or KayzarUI.BAR_TEXTURES["Smooth"]
end

function KayzarUI.FormatBarText(cur, max, pct)
    local mode = KayzarUI.sv.unitFrames.textMode or "Value + Percent"
    if mode == "Value + Percent" then
        return string.format("%s / %s (%d%%)", KayzarUI.FormatNumber(cur), KayzarUI.FormatNumber(max), zo_floor(pct * 100))
    elseif mode == "Value Only" then
        return string.format("%s / %s", KayzarUI.FormatNumber(cur), KayzarUI.FormatNumber(max))
    elseif mode == "Percent Only" then
        return string.format("%d%%", zo_floor(pct * 100))
    elseif mode == "Current Only" then
        return KayzarUI.FormatNumber(cur)
    end
    return ""
end

function KayzarUI.ApplyStyle(name)
    local preset = KayzarUI.STYLES[name]
    if not preset then return end
    local sv = KayzarUI.sv
    for k, v in pairs(preset) do
        sv[k] = {r = v.r, g = v.g, b = v.b, a = v.a}
    end
    sv.stylePreset = name
    KayzarUI.LiveRefreshAll()
end

function KayzarUI.DeepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[KayzarUI.DeepCopy(k)] = KayzarUI.DeepCopy(v)
    end
    return copy
end

------------------------------------------------------------------------
-- LIVE REFRESH
------------------------------------------------------------------------
function KayzarUI.LiveRefreshAll()
    if KayzarUI.UnitFrames then
        KayzarUI.UnitFrames:DestroyAll()
        KayzarUI.UnitFrames:Build()
    end
    if KayzarUI.ActionBar then KayzarUI.ActionBar:Refresh() end
    if KayzarUI.Buffs then KayzarUI.Buffs:Rebuild() end
    if KayzarUI.ApplyUIScheme then KayzarUI.ApplyUIScheme() end
end

function KayzarUI.LiveRecolor()
    if KayzarUI.UnitFrames then KayzarUI.UnitFrames:Rebuild() end
    if KayzarUI.ApplyUIScheme then KayzarUI.ApplyUIScheme() end
end

------------------------------------------------------------------------
-- UI COLOR SCHEME
------------------------------------------------------------------------
function KayzarUI.ApplyUIScheme()
    local sv = KayzarUI.sv
    if not sv.uiSchemeEnabled then return end
    local c = sv.uiSchemeColor
    if not c then return end
    if ZO_CompassFrame and ZO_CompassFrame.SetColor then
        ZO_CompassFrame:SetColor(c.r, c.g, c.b, 0.6)
    end
    if ZO_ReticleContainerReticle and ZO_ReticleContainerReticle.SetColor then
        ZO_ReticleContainerReticle:SetColor(c.r, c.g, c.b, 1)
    end
end

------------------------------------------------------------------------
-- ANIMATION
------------------------------------------------------------------------
KayzarUI.Animation = {}

function KayzarUI.Animation.SmoothBar(bar, cur, max, dur)
    if not bar or not max or max == 0 then return end
    local startVal = bar:GetValue()
    local targetVal = cur / max
    if bar._kzTL then bar._kzTL:Stop() end
    local tl = ANIMATION_MANAGER:CreateTimeline()
    local anim = tl:InsertAnimation(ANIMATION_CUSTOM, bar, 0)
    anim:SetDuration(dur or 200)
    anim:SetEasingFunction(ZO_EaseOutQuadratic)
    anim:SetUpdateFunction(function(_, progress)
        bar:SetValue(startVal + (targetVal - startVal) * progress)
    end)
    bar._kzTL = tl
    tl:PlayFromStart()
end

------------------------------------------------------------------------
-- FRAME LOCK
------------------------------------------------------------------------
function KayzarUI.UpdateFrameLock()
    local movable = not KayzarUI.sv.lockFrames
    local frameNames = {
        "KayzarUI_PlayerFrame", "KayzarUI_TargetFrame",
        "KayzarUI_HealthBarFrame", "KayzarUI_MagickaBarFrame",
        "KayzarUI_StaminaBarFrame", "KayzarUI_BarIndicator",
        "KayzarUI_BuffTracker",
    }
    for _, name in ipairs(frameNames) do
        local frame = _G[name]
        if frame then
            frame:SetMovable(movable)
            frame:SetMouseEnabled(true)
        end
    end
    if KayzarUI.Buffs then KayzarUI.Buffs:UpdateLock() end
end

------------------------------------------------------------------------
-- SHOW ALL ELEMENTS
------------------------------------------------------------------------
function KayzarUI.ToggleShowAllElements(show)
    KayzarUI.sv.showAllElements = show
    if show then
        local frameNames = {
            "KayzarUI_PlayerFrame", "KayzarUI_TargetFrame",
            "KayzarUI_HealthBarFrame", "KayzarUI_MagickaBarFrame",
            "KayzarUI_StaminaBarFrame", "KayzarUI_BarIndicator",
            "KayzarUI_BuffTracker",
        }
        for _, name in ipairs(frameNames) do
            local frame = _G[name]
            if frame then frame:SetHidden(false); frame:SetAlpha(1) end
        end
        local savedLock = KayzarUI.sv.lockFrames
        KayzarUI.sv.lockFrames = false
        KayzarUI.UpdateFrameLock()
        KayzarUI.sv.lockFrames = savedLock
        KayzarUI.Print("Show All Elements: ON")
    else
        KayzarUI.UpdateFrameLock()
        if KayzarUI.UnitFrames then
            KayzarUI.UnitFrames:UT()
        end
        KayzarUI.Print("Show All Elements: OFF")
    end
end

------------------------------------------------------------------------
-- TARGET NAME FORMATTING
------------------------------------------------------------------------
function KayzarUI.GetFormattedTargetName(unitTag)
    local mode = KayzarUI.sv.targetNameMode or "Character Name"
    local charName = zo_strformat("<<1>>", GetUnitName(unitTag))
    local displayName = GetUnitDisplayName(unitTag) or ""
    if mode == "UserID" then
        return displayName ~= "" and displayName or charName
    elseif mode == "Character + UserID" then
        if displayName ~= "" then return charName .. " " .. displayName end
        return charName
    end
    return charName
end

function KayzarUI.GetFormattedTargetTitle(unitTag)
    local rawTitle = GetUnitTitle(unitTag)
    if rawTitle and rawTitle ~= "" then
        return zo_strformat("<<1>>", rawTitle)
    end
    return ""
end
KayzarUI._hudFragments = {}

function KayzarUI.RegisterHUDFragment(controlName)
    local control = _G[controlName]
    if not control then return end
    if KayzarUI._hudFragments[controlName] then return end

    local fragment = ZO_HUDFadeSceneFragment:New(control)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
    KayzarUI._hudFragments[controlName] = fragment
end

function KayzarUI.RegisterAllHUDFragments()
    local frameNames = {
        "KayzarUI_PlayerFrame", "KayzarUI_TargetFrame",
        "KayzarUI_HealthBarFrame", "KayzarUI_MagickaBarFrame",
        "KayzarUI_StaminaBarFrame", "KayzarUI_BarIndicator",
        "KayzarUI_BuffTracker",
    }
    for _, name in ipairs(frameNames) do
        KayzarUI.RegisterHUDFragment(name)
    end
end

------------------------------------------------------------------------
-- COMBAT FADE
------------------------------------------------------------------------
function KayzarUI.RegisterCombatFade()
    local svuf = KayzarUI.sv.unitFrames
    if not svuf.fadeOutOfCombat then return end
    local alpha = svuf.fadeAlpha / 100
    local frames = {
        "KayzarUI_PlayerFrame",
        "KayzarUI_HealthBarFrame", "KayzarUI_MagickaBarFrame",
        "KayzarUI_StaminaBarFrame",
    }
    local function SetCombatAlpha(inCombat)
        for _, name in ipairs(frames) do
            local frame = _G[name]
            if frame then frame:SetAlpha(inCombat and 1.0 or alpha) end
        end
    end
    EM:RegisterForEvent("KUI_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        SetCombatAlpha(inCombat)
    end)
    SetCombatAlpha(IsUnitInCombat("player"))
end

------------------------------------------------------------------------
-- SLASH COMMANDS
------------------------------------------------------------------------
local function Slash(args)
    local cmd = string.lower(args or "")
    if cmd == "" or cmd == "settings" or cmd == "ui" then
        LibAddonMenu2:OpenToPanel(KayzarUI.settingsPanel)
    elseif cmd == "lock" then
        KayzarUI.sv.lockFrames = not KayzarUI.sv.lockFrames
        KayzarUI.Print(KayzarUI.sv.lockFrames and GetString(KAYZARUI_FRAMES_LOCKED) or GetString(KAYZARUI_FRAMES_UNLOCKED))
        KayzarUI.UpdateFrameLock()
    elseif cmd == "showall" then
        KayzarUI.sv.showAllElements = not KayzarUI.sv.showAllElements
        KayzarUI.ToggleShowAllElements(KayzarUI.sv.showAllElements)
    elseif cmd == "save" then
        KayzarUI.Print("|c00FF00Settings saved!|r All positions and settings are stored.")
    elseif cmd == "important" then
        KayzarUI.Print("|cF24D8C========================================|r")
        KayzarUI.Print("|cFFD700KayzarUI - Important Information|r")
        KayzarUI.Print("|cF24D8C========================================|r")
        KayzarUI.Print(" ")
        KayzarUI.Print("|cFFFFFFIf something is not working or you encounter bugs,|r")
        KayzarUI.Print("|cFFFFFFplease contact |cF24D8Chaze.3169|r |cFFFFFFon Discord or on ESOUI.|r")
        KayzarUI.Print(" ")
        KayzarUI.Print("|cF24D8C========================================|r")
    elseif cmd == "rl" or cmd == "reload" then
        ReloadUI()
    else
        KayzarUI.Print("/kayzar | ui | lock | showall | save | important | rl")
    end
end

------------------------------------------------------------------------
-- MIGRATION HELPER
------------------------------------------------------------------------
local function Mig(t, k, d)
    if t[k] == nil then t[k] = d end
end

------------------------------------------------------------------------
-- INIT
------------------------------------------------------------------------
local function OnLoaded(_, name)
    if name ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    KayzarUI.sv = ZO_SavedVars:NewAccountWide("KayzarUI_SavedVars", 6, nil, DEFAULT_SETTINGS)
    local sv = KayzarUI.sv
    local uf = sv.unitFrames

    -- Migrate all fields
    Mig(uf, "textMode",         "Value + Percent")
    Mig(uf, "showBackground",   false)
    Mig(uf, "showBorder",       false)
    Mig(uf, "bgOpacity",        85)
    Mig(uf, "barTexture",       "Smooth")
    Mig(uf, "barShape",         "Rectangle")
    Mig(uf, "barSpacing",       4)
    Mig(uf, "layoutMode",       "Stacked")
    Mig(uf, "healthBarHeight",  22)
    Mig(uf, "magickaBarHeight", uf.resourceBarHeight or 14)
    Mig(uf, "staminaBarHeight", uf.resourceBarHeight or 14)
    Mig(uf, "resourceBarHeight", 14)
    Mig(uf, "healthBarWidth",   0)
    Mig(uf, "magickaBarWidth",  0)
    Mig(uf, "staminaBarWidth",  0)
    Mig(uf, "independentBars",  false)
    Mig(uf, "healthOffsetX",  0)
    Mig(uf, "healthOffsetY",  0)
    Mig(uf, "magickaOffsetX", 0)
    Mig(uf, "magickaOffsetY", 0)
    Mig(uf, "staminaOffsetX", 0)
    Mig(uf, "staminaOffsetY", 0)
    Mig(uf, "showPlayerName", true)
    Mig(uf, "showPlayerLevel", true)
    Mig(uf, "showTargetName", true)
    Mig(uf, "showTargetLevel", true)

    Mig(sv, "nameColor",       C(.95, .30, .55))
    Mig(sv, "levelColor",      C(1, .45, .65))
    Mig(sv, "textColor",       C(1, 1, 1))
    Mig(sv, "targetNameMode",  "Character Name")
    Mig(sv, "uiSchemeEnabled", true)
    Mig(sv, "uiSchemeColor",   C(.95, .30, .55))
    Mig(sv, "showAllElements", false)
    Mig(sv, "gradientEnabled", false)
    Mig(sv, "healthGradientEnd",  C(.60, .05, .15))
    Mig(sv, "magickaGradientEnd", C(.30, .10, .55))
    Mig(sv, "staminaGradientEnd", C(.55, .20, .30))
    Mig(sv, "elements", {
        playerName = true, playerLevel = true, playerUlt = true,
        healthBar = true, magickaBar = true, staminaBar = true,
        targetName = true, targetLevel = true, targetHealth = true,
        barIndicator = true,
    })
    Mig(sv.actionBar, "showBarIndicator", true)

    -- Shield overlay migration
    if not sv.shield then sv.shield = KayzarUI.DeepCopy(DEFAULT_SETTINGS.shield) end
    Mig(sv.shield, "enabled", true)
    Mig(sv.shield, "color", C(.30, .70, 1, .55))
    Mig(sv.shield, "overshieldColor", C(.90, .85, .20, .65))

    -- Buff tracker migration
    if not sv.buffTracker then sv.buffTracker = KayzarUI.DeepCopy(DEFAULT_SETTINGS.buffTracker) end
    Mig(sv.buffTracker, "enabled",   true)
    Mig(sv.buffTracker, "iconSize",  36)
    Mig(sv.buffTracker, "maxBuffs",  12)
    Mig(sv.buffTracker, "showTimer", true)
    Mig(sv.buffTracker, "showName",  false)

    -- Target debuffs migration
    if not sv.targetDebuffs then sv.targetDebuffs = KayzarUI.DeepCopy(DEFAULT_SETTINGS.targetDebuffs) end
    Mig(sv.targetDebuffs, "enabled",    true)
    Mig(sv.targetDebuffs, "iconSize",   30)
    Mig(sv.targetDebuffs, "maxDebuffs", 8)

    -- Remove obsolete group frame saved data
    if sv.groupFrame then sv.groupFrame = nil end
    if sv.groupRoleColors then sv.groupRoleColors = nil end
    if sv.elements and sv.elements.groupFrame ~= nil then sv.elements.groupFrame = nil end
    if uf.groupEnabled ~= nil then uf.groupEnabled = nil end
    if uf.groupOffsetX ~= nil then uf.groupOffsetX = nil end
    if uf.groupOffsetY ~= nil then uf.groupOffsetY = nil end

    -- Migrate old target name modes
    if sv.targetNameMode == "UserID + Title" or sv.targetNameMode == "UserID Only" then
        sv.targetNameMode = "UserID"
    end
    if sv.targetNameMode == "Character + Title" then
        sv.targetNameMode = "Character Name"
    end

    -- Initialize modules
    if uf.enabled and KayzarUI.UnitFrames then
        KayzarUI.UnitFrames:Initialize()
    end
    if sv.actionBar.enabled and KayzarUI.ActionBar then
        KayzarUI.ActionBar:Initialize()
    end
    if KayzarUI.Buffs then KayzarUI.Buffs:Initialize() end
    if KayzarUI.Settings then KayzarUI.Settings:Initialize() end

    SLASH_COMMANDS["/kayzar"] = Slash
    SLASH_COMMANDS["/kui"]    = Slash

    -- Delay fragment registration and UI scheme until scenes are ready
    zo_callLater(function()
        KayzarUI.RegisterAllHUDFragments()
        KayzarUI.RegisterCombatFade()
        KayzarUI.ApplyUIScheme()
    end, 2000)

    if sv.showWelcome then
        zo_callLater(function()
            KayzarUI.Print("|cF24D8Cv1.1|r loaded. |cFFFFFF/kayzar|r for settings.")
        end, 1000)
    end
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)
