------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
KDStatTracker = {}
KDStatTracker.name = "BGStatsTracker"
KDStatTracker.version = "3.0"
KDStatTrackerUI = {}
KDStatTracker.isLoaded = true
local wm = WINDOW_MANAGER

-- ========================
-- Core Data Tables
-- ========================
KDStatTracker.KillStreak = {
    timeout = 10,
    banner = nil,
    label = nil,
}
KDStatTracker.MultiKill = {
    window = 10,
}
KDStatTracker.KDAVars = {
    kills = 0,
    deaths = 0,
}
KDStatTracker.bgActive = false

KDStatTracker.defaults = {
    totalKills = 0,
    totalDeaths = 0,
    perCharKDA = {},
    matchHistory = {},
    matchCounter = 0,
    duels = {
        totalDuels = 0,
        wins = 0,
        losses = 0,
        perCharStats = {},
    },
    deathSources = {},
    killSources = {},
    killStreakHistory = {},
    totalKillStreaks = 0,
    currentKillStreak = {
        count = 0,
        lastKillTime = 0,
        victims = {},
    },
    multiKillHistory = {},
    totalMultiKills = 0,
    currentMultiKill = {
        count = 0,
        lastKillTime = 0,
        victims = {},
    },
}
KDStatTracker.default_settings = {
    showKD = true,
    x = 500,
    y = 500,
    scale = 1.0,
    fontSize = 18,
    fontColor = "FFFFFF",
}

-- ========================
-- Constant Data
-- ========================
KDStatTracker.matchTypes = {
    [1] = "Deathmatch", [2] = "Domination", [3] = "Chaosball",
    [4] = "Capture the Relic", [5] = "King of the Hill",
    [6] = "Murderball", [7] = "Crazy King",
}

KDStatTracker.Streaks = {
    [2]  = { name = "Double Kill",      color = {0.4, 1, 0.4, 1} },
    [3]  = { name = "Triple Kill",      color = {0.3, 0.9, 1, 1} },
    [4]  = { name = "Mega Kill",        color = {0.8, 0.4, 1, 1} },
    [5]  = { name = "Ultra Kill",       color = {1, 0.6, 0.2, 1} },
    [7]  = { name = "Rampage",          color = {1, 0.6, 0.2, 1} },
    [10] = { name = "Demigod",          color = {1, 0.1, 0.8, 1} },
    [12] = { name = "Wicked Sick",      color = {1, 0.1, 0.8, 1} },
    [15] = { name = "Monster Kill",     color = {1, 0.1, 0.8, 1} },
    [18] = { name = "Ludicrous Kill",   color = {1, 0.1, 0.8, 1} },
    [25] = { name = "Unstoppable",      color = {1, 0.1, 0.8, 1} },
    [30] = { name = "Godlike",          color = {1, 0.1, 0.8, 1} },
    [40] = { name = "Beyond Godlike",   color = {1, 0.1, 0.8, 1} },
    [50] = { name = "Legendary",        color = {1, 0.1, 0.8, 1} },
    [70] = { name = "Mythical",         color = {1, 0.1, 0.8, 1} },
    [90] = { name = "Immortal",         color = {1, 0.1, 0.8, 1} },
    [100] = { name = "Unreal",          color = {1, 0.1, 0.8, 1} },
}

KDStatTracker.MultiKillNames = {
    [2] = "Double Kill",
    [3] = "Triple Kill",
    [4] = "Quadra Kill",
    [5] = "Penta Kill",
    [6] = "Hexa Kill",
    [7] = "Hepta Kill",
    [8] = "Octa Kill",
    [9] = "Nona Kill",
    [10] = "Deca Kill",
}

-- ========================
-- Helpers
-- ========================
function safeKD(kills, deaths)
    if deaths == 0 then return "N/A" end
    return string.format("%.2f", kills / deaths)
end

function formatKD(kills, deaths)
    kills = kills or 0
    deaths = deaths or 0
    local kd = deaths == 0 and "N/A" or string.format("%.2f", kills / deaths)
    return string.format("%d/%d (K/D: %s)", kills, deaths, kd)
end

local function GetStreakName(count)
    local bestName = nil
    local bestThreshold = 0
    for threshold, data in pairs(KDStatTracker.Streaks) do
        if count >= threshold and threshold > bestThreshold then
            bestName = data.name
            bestThreshold = threshold
        end
    end
    return bestName or (count .. " Kill Streak")
end

local function GetStreakColor(count)
    local bestColor = {1, 1, 1, 1}
    local bestThreshold = 0
    for threshold, data in pairs(KDStatTracker.Streaks) do
        if count >= threshold and threshold > bestThreshold then
            bestColor = data.color
            bestThreshold = threshold
        end
    end
    return bestColor
end

local function GetSavedKillStreak()
    KDStatTracker.savedVars = KDStatTracker.savedVars or {}
    local streak = KDStatTracker.savedVars.currentKillStreak
    if not streak then
        streak = { count = 0, lastKillTime = 0, victims = {} }
        KDStatTracker.savedVars.currentKillStreak = streak
    end
    streak.count = streak.count or 0
    streak.lastKillTime = streak.lastKillTime or 0
    streak.victims = streak.victims or {}
    return streak
end

local function GetSavedMultiKill()
    KDStatTracker.savedVars = KDStatTracker.savedVars or {}
    local mk = KDStatTracker.savedVars.currentMultiKill
    if not mk then
        mk = { count = 0, lastKillTime = 0, victims = {} }
        KDStatTracker.savedVars.currentMultiKill = mk
    end
    mk.count = mk.count or 0
    mk.lastKillTime = mk.lastKillTime or 0
    mk.victims = mk.victims or {}
    return mk
end

local function GetMultiKillName(count)
    return KDStatTracker.MultiKillNames[count] or (count .. "x Multi Kill")
end

-- ========================
-- Modern UI - Nightblade Shadow Theme
-- ========================
local UI_COLORS = {
    bgDark       = {0.05, 0.02, 0.08, 0.88},
    bgMid        = {0.10, 0.04, 0.14, 0.75},
    border       = {0.76, 0.46, 0.58, 0.90},
    accent       = {0.70, 0.10, 0.30, 1.0},
    accentGlow   = {0.85, 0.15, 0.45, 1.0},
    titleText    = {0.85, 0.15, 0.45, 1.0},
    labelDim     = {0.55, 0.40, 0.60, 1.0},
    valueText    = {0.92, 0.88, 0.95, 1.0},
    killGreen    = {0.30, 1.0, 0.45, 1.0},
    deathRed     = {1.0, 0.25, 0.25, 1.0},
    ratioGold    = {1.0, 0.85, 0.20, 1.0},
    streakPurple = {0.75, 0.30, 1.0, 1.0},
    separator    = {0.45, 0.08, 0.20, 0.50},
}

local function CreateBackdrop(parent, name, r, g, b, a)
    local bg = wm:GetControlByName(name) or wm:CreateControl(name, parent, CT_TEXTURE)
    bg:SetTexture("/esoui/art/miscellaneous/inset_bg.dds")
    bg:SetColor(r or 0.05, g or 0.02, b or 0.08, a or 0.88)
    bg:ClearAnchors()
    bg:SetAnchorFill(parent)
    bg:SetDrawLayer(DL_BACKGROUND)
    bg:SetDrawLevel(0)
    return bg
end

local function CreateBorderEdge(parent, name, side, thickness)
    local edge = wm:GetControlByName(name) or wm:CreateControl(name, parent, CT_TEXTURE)
    edge:SetColor(unpack(UI_COLORS.border))
    edge:SetDrawLayer(DL_BACKGROUND)
    edge:SetDrawLevel(2)
    thickness = thickness or 2
    if side == "top" then
        edge:ClearAnchors()
        edge:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        edge:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
        edge:SetHeight(thickness)
    elseif side == "bottom" then
        edge:ClearAnchors()
        edge:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, 0, 0)
        edge:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
        edge:SetHeight(thickness)
    elseif side == "left" then
        edge:ClearAnchors()
        edge:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        edge:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, 0, 0)
        edge:SetWidth(thickness)
    elseif side == "right" then
        edge:ClearAnchors()
        edge:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
        edge:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
        edge:SetWidth(thickness)
    end
    return edge
end

local function CreateSeparator(parent, name, offsetY)
    local sep = wm:GetControlByName(name) or wm:CreateControl(name, parent, CT_TEXTURE)
    sep:SetColor(unpack(UI_COLORS.separator))
    sep:ClearAnchors()
    sep:SetAnchor(TOPLEFT, parent, TOPLEFT, 10, offsetY)
    sep:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -10, offsetY)
    sep:SetHeight(1)
    sep:SetDrawLayer(DL_CONTROLS)
    return sep
end

local function CreateStatLabel(parent, name, anchorPoint, anchorTo, anchorToPoint, offX, offY, fontSize, color, alignment)
    local label = wm:GetControlByName(name) or wm:CreateControl(name, parent, CT_LABEL)
    local fontPath = string.format("/esoui/common/fonts/univers67.otf|%d|soft-shadow-thick", fontSize or 16)
    label:SetFont(fontPath)
    label:ClearAnchors()
    label:SetAnchor(anchorPoint, anchorTo, anchorToPoint, offX or 0, offY or 0)
    label:SetHorizontalAlignment(alignment or TEXT_ALIGN_LEFT)
    label:SetColor(unpack(color or UI_COLORS.valueText))
    label:SetDrawLayer(DL_CONTROLS)
    label:SetDrawLevel(3)
    return label
end

function KDStatTrackerUI.CreateUI()
    local vars = KDStatTracker.SettingsVars or KDStatTracker.default_settings
    local panelWidth = 320
    local panelHeight = 198

    -- Main window
    local panel = wm:GetControlByName("KDStatTracker_KDDisplay")
    if not panel then
        panel = wm:CreateTopLevelWindow("KDStatTracker_KDDisplay")
    end
    KDStatTrackerUI.kdDisplay = panel
    panel:ClearAnchors()
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, vars.x or 500, vars.y or 500)
    panel:SetDimensions(panelWidth, panelHeight)
    panel:SetMovable(true)
    panel:SetMouseEnabled(true)
    panel:SetClampedToScreen(true)
    panel:SetScale(vars.scale or 1.0)

    panel:SetHandler("OnMoveStop", function(control)
        if KDStatTracker.SettingsVars then
            KDStatTracker.SettingsVars.x = control:GetLeft()
            KDStatTracker.SettingsVars.y = control:GetTop()
        end
    end)

    panel:SetHandler("OnUpdate", function(_, frameTimeMs)
        KDStatTrackerUI._multiKillUpdateElapsed = (KDStatTrackerUI._multiKillUpdateElapsed or 0) + frameTimeMs
        if KDStatTrackerUI._multiKillUpdateElapsed < 250 then return end
        KDStatTrackerUI._multiKillUpdateElapsed = 0
        if KDStatTrackerUI.ExpireMultiKillIfNeeded(true) then
            KDStatTrackerUI.UpdateUI()
        end
    end)

    -- Background (solid dark base)
    CreateBackdrop(panel, "KDStatTracker_BG", 0.02, 0.01, 0.04, 0.85)

    -- Trans flag backdrop stripes (light blue, pink, white, pink, light blue) at 30% opacity
    local stripeH = math.floor(panelHeight / 5)
    local flagColors = {
        {0.36, 0.81, 0.98, 0.30},  -- light blue  #5BCEFA
        {0.96, 0.66, 0.72, 0.30},  -- pink        #F5A9B8
        {1.00, 1.00, 1.00, 0.30},  -- white        #FFFFFF
        {0.96, 0.66, 0.72, 0.30},  -- pink        #F5A9B8
        {0.36, 0.81, 0.98, 0.30},  -- light blue  #5BCEFA
    }
    for i = 1, 5 do
        local ctrlName = "KDStatTracker_TFlag" .. i
        local stripe = wm:GetControlByName(ctrlName)
        if not stripe then
            stripe = wm:CreateControl(ctrlName, panel, CT_TEXTURE)
        end
        stripe:SetTexture("/esoui/art/chatwindow/chat_bg_center.dds")
        stripe:SetColor(flagColors[i][1], flagColors[i][2], flagColors[i][3], flagColors[i][4])
        stripe:ClearAnchors()
        stripe:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, (i - 1) * stripeH)
        stripe:SetAnchor(TOPRIGHT, panel, TOPRIGHT, 0, (i - 1) * stripeH)
        stripe:SetHeight(stripeH)
        stripe:SetDrawLayer(DL_BACKGROUND)
        stripe:SetDrawLevel(1)
        stripe:SetHidden(false)
    end

    -- Borders
    CreateBorderEdge(panel, "KDStatTracker_BorderTop", "top", 2)
    CreateBorderEdge(panel, "KDStatTracker_BorderBottom", "bottom", 2)
    CreateBorderEdge(panel, "KDStatTracker_BorderLeft", "left", 2)
    CreateBorderEdge(panel, "KDStatTracker_BorderRight", "right", 2)

    -- Top accent bar (pink)
    local accentBar = wm:GetControlByName("KDStatTracker_AccentBar") or wm:CreateControl("KDStatTracker_AccentBar", panel, CT_TEXTURE)
    accentBar:SetColor(0.96, 0.66, 0.72, 1.0)
    accentBar:ClearAnchors()
    accentBar:SetAnchor(TOPLEFT, panel, TOPLEFT, 2, 2)
    accentBar:SetAnchor(TOPRIGHT, panel, TOPRIGHT, -2, 2)
    accentBar:SetHeight(3)
    accentBar:SetDrawLayer(DL_CONTROLS)
    accentBar:SetDrawLevel(4)

    -- Title
    local fontSize = vars.fontSize or 18
    local titleLabel = CreateStatLabel(panel, "KDStatTracker_Title",
        TOP, panel, TOP, 0, 8, fontSize + 2, UI_COLORS.titleText, TEXT_ALIGN_CENTER)
    titleLabel:SetText("|cD4266FKDStat|r|c8822AATracker|r")

    CreateSeparator(panel, "KDStatTracker_Sep1", 30)

    -- K / D / KD row
    local killLabel = CreateStatLabel(panel, "KDStatTracker_KillLabel",
        TOPLEFT, panel, TOPLEFT, 14, 38, fontSize - 2, UI_COLORS.labelDim, TEXT_ALIGN_LEFT)
    killLabel:SetText("KILLS")

    KDStatTrackerUI.killValue = CreateStatLabel(panel, "KDStatTracker_KillValue",
        TOPLEFT, panel, TOPLEFT, 14, 52, fontSize + 2, UI_COLORS.killGreen, TEXT_ALIGN_LEFT)

    local deathLabel = CreateStatLabel(panel, "KDStatTracker_DeathLabel",
        TOP, panel, TOP, 0, 38, fontSize - 2, UI_COLORS.labelDim, TEXT_ALIGN_CENTER)
    deathLabel:SetText("DEATHS")

    KDStatTrackerUI.deathValue = CreateStatLabel(panel, "KDStatTracker_DeathValue",
        TOP, panel, TOP, 0, 52, fontSize + 2, UI_COLORS.deathRed, TEXT_ALIGN_CENTER)

    local ratioLabel = CreateStatLabel(panel, "KDStatTracker_RatioLabel",
        TOPRIGHT, panel, TOPRIGHT, -14, 38, fontSize - 2, UI_COLORS.labelDim, TEXT_ALIGN_RIGHT)
    ratioLabel:SetText("K/D")

    KDStatTrackerUI.ratioValue = CreateStatLabel(panel, "KDStatTracker_RatioValue",
        TOPRIGHT, panel, TOPRIGHT, -14, 52, fontSize + 2, UI_COLORS.ratioGold, TEXT_ALIGN_RIGHT)

    CreateSeparator(panel, "KDStatTracker_Sep2", 78)

    -- Streak row
    local streakLabel = CreateStatLabel(panel, "KDStatTracker_StreakLabel",
        TOPLEFT, panel, TOPLEFT, 14, 85, fontSize - 2, UI_COLORS.labelDim, TEXT_ALIGN_LEFT)
    streakLabel:SetText("STREAKS")

    KDStatTrackerUI.streakValue = CreateStatLabel(panel, "KDStatTracker_StreakValue",
        TOPLEFT, panel, TOPLEFT, 80, 85, fontSize, UI_COLORS.streakPurple, TEXT_ALIGN_LEFT)

    local curStreakLabel = CreateStatLabel(panel, "KDStatTracker_CurStreakLabel",
        TOPRIGHT, panel, TOPRIGHT, -14, 85, fontSize - 2, UI_COLORS.labelDim, TEXT_ALIGN_RIGHT)
    curStreakLabel:SetText("CURRENT")

    KDStatTrackerUI.curStreakValue = CreateStatLabel(panel, "KDStatTracker_CurStreakValue",
        TOPRIGHT, panel, TOPRIGHT, -72, 85, fontSize, UI_COLORS.accentGlow, TEXT_ALIGN_RIGHT)

    -- Current multikill row
    local multiKillLabel = CreateStatLabel(panel, "KDStatTracker_MultiKillLabel",
        TOPLEFT, panel, TOPLEFT, 14, 103, fontSize - 4, UI_COLORS.labelDim, TEXT_ALIGN_LEFT)
    multiKillLabel:SetText("MULTI")

    KDStatTrackerUI.multiKillValue = CreateStatLabel(panel, "KDStatTracker_MultiKillValue",
        TOPLEFT, panel, TOPLEFT, 80, 103, fontSize - 3, UI_COLORS.ratioGold, TEXT_ALIGN_LEFT)

    CreateSeparator(panel, "KDStatTracker_Sep3", 120)

    -- Most kills / deaths
    local mostKillLabel = CreateStatLabel(panel, "KDStatTracker_MostKillLabel",
        TOPLEFT, panel, TOPLEFT, 14, 126, fontSize - 4, UI_COLORS.labelDim, TEXT_ALIGN_LEFT)
    mostKillLabel:SetText("TOP KILL")

    KDStatTrackerUI.mostKillValue = CreateStatLabel(panel, "KDStatTracker_MostKillValue",
        TOPLEFT, panel, TOPLEFT, 80, 126, fontSize - 3, UI_COLORS.valueText, TEXT_ALIGN_LEFT)

    local mostDeathLabel = CreateStatLabel(panel, "KDStatTracker_MostDeathLabel",
        TOPLEFT, panel, TOPLEFT, 14, 144, fontSize - 4, UI_COLORS.labelDim, TEXT_ALIGN_LEFT)
    mostDeathLabel:SetText("TOP DEATH")

    KDStatTrackerUI.mostDeathValue = CreateStatLabel(panel, "KDStatTracker_MostDeathValue",
        TOPLEFT, panel, TOPLEFT, 92, 144, fontSize - 3, UI_COLORS.valueText, TEXT_ALIGN_LEFT)

    -- Last victim
    local lastVictimLabel = CreateStatLabel(panel, "KDStatTracker_LastVictimLabel",
        TOPLEFT, panel, TOPLEFT, 14, 162, fontSize - 4, UI_COLORS.labelDim, TEXT_ALIGN_LEFT)
    lastVictimLabel:SetText("LAST KILL")

    KDStatTrackerUI.lastVictimValue = CreateStatLabel(panel, "KDStatTracker_LastVictimValue",
        TOPLEFT, panel, TOPLEFT, 80, 162, fontSize - 3, {0.70, 0.90, 1.0, 1.0}, TEXT_ALIGN_LEFT)

    -- Bottom accent (light blue)
    local bottomAccent = wm:GetControlByName("KDStatTracker_AccentBarBottom") or wm:CreateControl("KDStatTracker_AccentBarBottom", panel, CT_TEXTURE)
    bottomAccent:SetColor(0.36, 0.81, 0.98, 1.0)
    bottomAccent:ClearAnchors()
    bottomAccent:SetAnchor(BOTTOMLEFT, panel, BOTTOMLEFT, 2, -2)
    bottomAccent:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -2, -2)
    bottomAccent:SetHeight(2)
    bottomAccent:SetDrawLayer(DL_CONTROLS)
    bottomAccent:SetDrawLevel(4)

    -- Legacy compat
    KDStatTrackerUI.kdDisplayLabel = KDStatTrackerUI.killValue

    panel:SetHidden(not vars.showKD)
    KDStatTrackerUI.UpdateUI()
end

function KDStatTrackerUI.ExpireMultiKillIfNeeded(saveExpiredEntry)
    local mk = GetSavedMultiKill()
    if (mk.count or 0) <= 0 then return false end

    local now = GetGameTimeSeconds()
    local window = KDStatTracker.MultiKill.window or 10
    if now - (mk.lastKillTime or 0) <= window then
        return false
    end

    if saveExpiredEntry and (mk.count or 0) >= 2 then
        KDStatTrackerUI.SaveMultiKill(mk.count, mk.victims)
    end

    mk.count = 0
    mk.lastKillTime = 0
    mk.victims = {}
    return true
end

-- ========================
-- UI Update
-- ========================
function KDStatTrackerUI.UpdateUI()
    if not KDStatTrackerUI.killValue then return end

    local charName = GetUnitName("player") or "Unknown"
    local kills = KDStatTracker.KDAVars.kills or 0
    local deaths = KDStatTracker.KDAVars.deaths or 0

    local ratio = "N/A"
    if deaths > 0 then
        ratio = string.format("%.2f", kills / deaths)
    elseif kills > 0 then
        ratio = string.format("%.2f", kills)
    end

    KDStatTrackerUI.killValue:SetText(tostring(kills))
    KDStatTrackerUI.deathValue:SetText(tostring(deaths))
    KDStatTrackerUI.ratioValue:SetText(ratio)

    -- Streaks
    local totalStreaks = (KDStatTracker.savedVars and KDStatTracker.savedVars.totalKillStreaks) or 0
    KDStatTrackerUI.streakValue:SetText(tostring(totalStreaks))
    KDStatTrackerUI.curStreakValue:SetText(tostring(GetSavedKillStreak().count))

    KDStatTrackerUI.ExpireMultiKillIfNeeded(true)
    local mk = GetSavedMultiKill()
    if KDStatTrackerUI.multiKillValue then
        local multiText = tostring(mk.count or 0)
        if (mk.count or 0) >= 2 then
            multiText = string.format("%d (%s)", mk.count or 0, GetMultiKillName(mk.count or 0))
        end
        KDStatTrackerUI.multiKillValue:SetText(multiText)
    end

    -- Sources
    KDStatTracker.savedVars = KDStatTracker.savedVars or {}
    KDStatTracker.savedVars.killSources = KDStatTracker.savedVars.killSources or {}
    KDStatTracker.savedVars.deathSources = KDStatTracker.savedVars.deathSources or {}

    local killsources = KDStatTracker.savedVars.killSources[charName] or {}
    local deathsources = KDStatTracker.savedVars.deathSources[charName] or {}

    local topKill, topKillCount, lastVictim = "N/A", 0, "N/A"
    for _, info in pairs(killsources) do
        if info and info.count and info.count > topKillCount then
            topKill = info.abilityName or "Unknown"
            topKillCount = info.count
            lastVictim = info.lastVictim or "N/A"
        end
    end

    local topDeath, topDeathCount = "N/A", 0
    for _, info in pairs(deathsources) do
        if info and info.count and info.count > topDeathCount then
            topDeath = info.abilityName or "Unknown"
            topDeathCount = info.count
        end
    end

    KDStatTrackerUI.mostKillValue:SetText(string.format("%s |cAAAAAAx%d|r", topKill, topKillCount))
    KDStatTrackerUI.mostDeathValue:SetText(string.format("%s |cAAAAAAx%d|r", topDeath, topDeathCount))
    KDStatTrackerUI.lastVictimValue:SetText(lastVictim)
end

function KDStatTrackerUI.UpdateVisibility()
    if KDStatTrackerUI.kdDisplay then
        KDStatTrackerUI.kdDisplay:SetHidden(not KDStatTracker.SettingsVars.showKD)
    end
end

-- ========================
-- Kill Streak Banner (Animated)
-- ========================
function KDStatTrackerUI.ShowKillStreakBanner(count)
    local data = KDStatTracker.Streaks[count]
    if not data then return end

    local vars = KDStatTracker.SettingsVars or KDStatTracker.default_settings

    local banner = wm:GetControlByName("KDStatTracker_KillStreakBanner") or wm:CreateTopLevelWindow("KDStatTracker_KillStreakBanner")
    banner:ClearAnchors()
    banner:SetAnchor(CENTER, GuiRoot, CENTER, 0, -200)
    banner:SetDimensions(600, 80)
    banner:SetHidden(true)

    -- Banner BG
    local bannerBG = wm:GetControlByName("KDStatTracker_BannerBG") or wm:CreateControl("KDStatTracker_BannerBG", banner, CT_TEXTURE)
    bannerBG:SetTexture("/esoui/art/miscellaneous/inset_bg.dds")
    bannerBG:SetColor(0.05, 0.01, 0.08, 0.92)
    bannerBG:ClearAnchors()
    bannerBG:SetAnchorFill(banner)
    bannerBG:SetDrawLayer(DL_BACKGROUND)

    -- Glow edges
    local glowTop = wm:GetControlByName("KDStatTracker_BannerGlowTop") or wm:CreateControl("KDStatTracker_BannerGlowTop", banner, CT_TEXTURE)
    glowTop:SetColor(data.color[1], data.color[2], data.color[3], 0.9)
    glowTop:ClearAnchors()
    glowTop:SetAnchor(TOPLEFT, banner, TOPLEFT)
    glowTop:SetAnchor(TOPRIGHT, banner, TOPRIGHT)
    glowTop:SetHeight(3)
    glowTop:SetDrawLayer(DL_CONTROLS)

    local glowBottom = wm:GetControlByName("KDStatTracker_BannerGlowBot") or wm:CreateControl("KDStatTracker_BannerGlowBot", banner, CT_TEXTURE)
    glowBottom:SetColor(data.color[1], data.color[2], data.color[3], 0.9)
    glowBottom:ClearAnchors()
    glowBottom:SetAnchor(BOTTOMLEFT, banner, BOTTOMLEFT)
    glowBottom:SetAnchor(BOTTOMRIGHT, banner, BOTTOMRIGHT)
    glowBottom:SetHeight(3)
    glowBottom:SetDrawLayer(DL_CONTROLS)

    -- Streak name
    local label = wm:GetControlByName("KDStatTracker_BannerLabel") or wm:CreateControl("KDStatTracker_BannerLabel", banner, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor(CENTER, banner, CENTER, 0, -8)
    label:SetFont("/esoui/common/fonts/univers67.otf|32|soft-shadow-thick")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(unpack(data.color))
    label:SetText(data.name)

    -- Kill count sub-label
    local subLabel = wm:GetControlByName("KDStatTracker_BannerSubLabel") or wm:CreateControl("KDStatTracker_BannerSubLabel", banner, CT_LABEL)
    subLabel:ClearAnchors()
    subLabel:SetAnchor(CENTER, banner, CENTER, 0, 18)
    subLabel:SetFont("/esoui/common/fonts/univers57.otf|16|soft-shadow-thin")
    subLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    subLabel:SetColor(0.75, 0.65, 0.80, 1.0)
    subLabel:SetText(string.format("%d kills", count))

    KDStatTracker.KillStreak.banner = banner
    KDStatTracker.KillStreak.label = label

    d(string.format("|cD4266F[KDStatTracker]|r |c%sKillstreak: %s! (%d kills)|r",
        vars.fontColor or "FFFFFF", data.name, count))

    -- Stop existing animation
    if banner.timeline then
        banner.timeline:Stop()
    end

    -- Animated entrance: scale up + fade in, settle, hold, fade out
    banner:SetAlpha(0)
    banner:SetScale(0.5)
    banner:SetHidden(false)

    local timeline = ANIMATION_MANAGER:CreateTimeline()

    -- Phase 1: Scale up + fade in (0-300ms)
    local scaleIn = timeline:InsertAnimation(ANIMATION_SCALE, banner, 0)
    scaleIn:SetScaleValues(0.5, 1.15)
    scaleIn:SetDuration(300)
    scaleIn:SetEasingFunction(ZO_EaseOutQuadratic)

    local fadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, banner, 0)
    fadeIn:SetAlphaValues(0, 1)
    fadeIn:SetDuration(200)

    -- Phase 2: Scale settle (300-500ms)
    local scaleSettle = timeline:InsertAnimation(ANIMATION_SCALE, banner, 300)
    scaleSettle:SetScaleValues(1.15, 1.0)
    scaleSettle:SetDuration(200)
    scaleSettle:SetEasingFunction(ZO_EaseInOutQuadratic)

    -- Phase 3: Hold then fade out
    local holdDuration = math.min(1500 + (count * 100), 4000)
    local fadeOut = timeline:InsertAnimation(ANIMATION_ALPHA, banner, 500 + holdDuration)
    fadeOut:SetAlphaValues(1, 0)
    fadeOut:SetDuration(800)

    local scaleOut = timeline:InsertAnimation(ANIMATION_SCALE, banner, 500 + holdDuration)
    scaleOut:SetScaleValues(1.0, 0.85)
    scaleOut:SetDuration(800)
    scaleOut:SetEasingFunction(ZO_EaseInQuadratic)

    timeline:SetHandler("OnStop", function()
        banner:SetHidden(true)
        banner:SetScale(1.0)
    end)

    timeline:PlayFromStart()
    banner.timeline = timeline
end

-- ========================
-- Multi-Kill Banner (Animated)
-- ========================
function KDStatTrackerUI.ShowMultiKillBanner(count)
    local text = KDStatTracker.MultiKillNames[count]
    if not text then return end

    local banner = wm:GetControlByName("KDStatTracker_MultiKillBanner") or wm:CreateTopLevelWindow("KDStatTracker_MultiKillBanner")
    banner:ClearAnchors()
    banner:SetAnchor(CENTER, GuiRoot, CENTER, 0, -140)
    banner:SetDimensions(500, 50)
    banner:SetHidden(true)

    local mkBG = wm:GetControlByName("KDStatTracker_MKBG") or wm:CreateControl("KDStatTracker_MKBG", banner, CT_TEXTURE)
    mkBG:SetTexture("/esoui/art/miscellaneous/inset_bg.dds")
    mkBG:SetColor(0.08, 0.02, 0.04, 0.85)
    mkBG:ClearAnchors()
    mkBG:SetAnchorFill(banner)
    mkBG:SetDrawLayer(DL_BACKGROUND)

    local label = wm:GetControlByName("KDStatTracker_MKLabel") or wm:CreateControl("KDStatTracker_MKLabel", banner, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor(CENTER, banner, CENTER)
    label:SetFont("/esoui/common/fonts/univers67.otf|26|soft-shadow-thick")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 0.85, 0.2, 1)
    label:SetText(text)

    if banner.timeline then
        banner.timeline:Stop()
    end

    banner:SetAlpha(0)
    banner:SetScale(0.6)
    banner:SetHidden(false)

    local timeline = ANIMATION_MANAGER:CreateTimeline()

    local scaleIn = timeline:InsertAnimation(ANIMATION_SCALE, banner, 0)
    scaleIn:SetScaleValues(0.6, 1.1)
    scaleIn:SetDuration(200)
    scaleIn:SetEasingFunction(ZO_EaseOutQuadratic)

    local fadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, banner, 0)
    fadeIn:SetAlphaValues(0, 1)
    fadeIn:SetDuration(150)

    local scaleSettle = timeline:InsertAnimation(ANIMATION_SCALE, banner, 200)
    scaleSettle:SetScaleValues(1.1, 1.0)
    scaleSettle:SetDuration(150)

    local fadeOut = timeline:InsertAnimation(ANIMATION_ALPHA, banner, 1500)
    fadeOut:SetAlphaValues(1, 0)
    fadeOut:SetDuration(600)

    timeline:SetHandler("OnStop", function()
        banner:SetHidden(true)
        banner:SetScale(1.0)
    end)

    timeline:PlayFromStart()
    banner.timeline = timeline
end

function KDStatTrackerUI.ResetMultiKill()
    local mk = GetSavedMultiKill()
    if mk.count >= 2 then
        KDStatTrackerUI.SaveMultiKill(mk.count, mk.victims)
    end
    mk.count = 0
    mk.lastKillTime = 0
    mk.victims = {}
end

function KDStatTrackerUI.ProcessMultiKill(victim)
    local now = GetGameTimeSeconds()
    local mk = GetSavedMultiKill()
    local window = KDStatTracker.MultiKill.window or 10

    KDStatTrackerUI.ExpireMultiKillIfNeeded(true)
    mk = GetSavedMultiKill()

    if now - mk.lastKillTime <= window then
        mk.count = mk.count + 1
    else
        mk.count = 1
        mk.victims = {}
    end

    mk.lastKillTime = now
    table.insert(mk.victims, victim or "Unknown")
    KDStatTrackerUI.ShowMultiKillBanner(mk.count)
end

-- ========================
-- Kill Streak Persistence
-- ========================
function KDStatTrackerUI.ResetKillStreak()
    local streak = GetSavedKillStreak()
    -- Save streak of 3+ to history
    if streak.count >= 3 then
        KDStatTrackerUI.SaveKillStreak(streak.count, streak.victims)
    end
    streak.count = 0
    streak.lastKillTime = 0
    streak.victims = {}
    KDStatTrackerUI.UpdateUI()
end

function KDStatTrackerUI.IncrementKillStreak()
    local now = GetGameTimeSeconds()
    local streak = GetSavedKillStreak()
    streak.count = streak.count + 1
    streak.lastKillTime = now
    KDStatTrackerUI.ShowKillStreakBanner(streak.count)
    KDStatTrackerUI.UpdateUI()
end

function KDStatTrackerUI.SaveKillStreak(count, victims)
    if not KDStatTracker.savedVars then return end
    KDStatTracker.savedVars.killStreakHistory = KDStatTracker.savedVars.killStreakHistory or {}
    KDStatTracker.savedVars.totalKillStreaks = (KDStatTracker.savedVars.totalKillStreaks or 0) + 1

    local entry = {
        count = count,
        streakName = GetStreakName(count),
        victims = {},
        timestamp = GetTimeStamp(),
        characterName = GetUnitName("player") or "Unknown",
    }

    if victims then
        for i, v in ipairs(victims) do
            entry.victims[i] = v
        end
    end

    table.insert(KDStatTracker.savedVars.killStreakHistory, entry)

    -- Keep last 50
    while #KDStatTracker.savedVars.killStreakHistory > 50 do
        table.remove(KDStatTracker.savedVars.killStreakHistory, 1)
    end

    d(string.format("|cD4266F[KDStatTracker]|r Killstreak of %d saved! (%s)", count, entry.streakName))
end

function KDStatTrackerUI.SaveMultiKill(count, victims)
    if not KDStatTracker.savedVars then return end
    KDStatTracker.savedVars.multiKillHistory = KDStatTracker.savedVars.multiKillHistory or {}
    KDStatTracker.savedVars.totalMultiKills = (KDStatTracker.savedVars.totalMultiKills or 0) + 1

    local entry = {
        count = count,
        multiKillName = GetMultiKillName(count),
        victims = {},
        timestamp = GetTimeStamp(),
        characterName = GetUnitName("player") or "Unknown",
    }

    if victims then
        for i, v in ipairs(victims) do
            entry.victims[i] = v
        end
    end

    table.insert(KDStatTracker.savedVars.multiKillHistory, entry)

    while #KDStatTracker.savedVars.multiKillHistory > 50 do
        table.remove(KDStatTracker.savedVars.multiKillHistory, 1)
    end

    d(string.format("|cD4266F[KDStatTracker]|r Multikill saved! (%s)", entry.multiKillName))
end

-- ========================
-- Duel Tracking
-- ========================
function isDuelingStateChanged(eventCode, duelResult, wasResultofPlayer, opponentCharName, opponentDisplayName, _, _, _, _)
    local charName = GetUnitName("player")
    local duels = KDStatTracker.savedVars.duels
    duels.perCharStats[charName] = duels.perCharStats[charName] or { duels = 0, wins = 0, losses = 0, charactersFaced = {} }
    local charData = duels.perCharStats[charName]
    charData.charactersFaced[opponentDisplayName] = charData.charactersFaced[opponentDisplayName] or {wins = 0, losses = 0}

    if duelResult == DUEL_RESULT_WON then
        duels.totalDuels = duels.totalDuels + 1
        charData.duels = charData.duels + 1
        if wasResultofPlayer then
            duels.wins = duels.wins + 1
            charData.wins = charData.wins + 1
            charData.charactersFaced[opponentDisplayName].wins = (charData.charactersFaced[opponentDisplayName].wins or 0) + 1
        else
            duels.losses = duels.losses + 1
            charData.losses = charData.losses + 1
            charData.charactersFaced[opponentDisplayName].losses = (charData.charactersFaced[opponentDisplayName].losses or 0) + 1
        end
    elseif duelResult == DUEL_RESULT_FORFEIT then
        duels.totalDuels = duels.totalDuels + 1
        charData.duels = charData.duels + 1
        if wasResultofPlayer then
            duels.losses = duels.losses + 1
            charData.losses = charData.losses + 1
            charData.charactersFaced[opponentDisplayName].losses = (charData.charactersFaced[opponentDisplayName].losses or 0) + 1
        else
            duels.wins = duels.wins + 1
            charData.wins = charData.wins + 1
            charData.charactersFaced[opponentDisplayName].wins = (charData.charactersFaced[opponentDisplayName].wins or 0) + 1
        end
    end
end

-- ========================
-- Death Handler
-- ========================
function OnUnitDeathStateChanged(eventCode, ...)
    local unitTag, isDead = ...
    if unitTag == "player" and isDead then
        local num = GetNumKillingAttacks()
        local attackName, attackDamage, attackIcon, wasKillingBlow, castTime, duration, numHits, abilityId, textureIcon = GetKillingAttackInfo(num)
        local attackerRawName, attackerCP, attackerLevel, attackerAVARank, isPlayer, isBoss, alliance, minion_name, attackerDisplayName = GetKillingAttackerInfo(num)
        local name = zo_strformat("<<1>>", attackerRawName)
        if isPlayer then
            KDStatTrackerUI.ResetKillStreak()
            KDStatTrackerUI.ResetMultiKill()
            KDStatTrackerUI.RecordDeath(abilityId or 0, attackName or "Unknown", name)
        end
    end
end

-- ========================
-- Battleground State
-- ========================
function OnActivityFinderStatusUpdate(eventCode, status, currentStatus)
    if not KDStatTracker.savedVars then return end
    if status == BATTLEGROUND_STATE_PREGAME and currentStatus == BATTLEGROUND_STATE_STARTING then
        d("|cD4266F[KDStatTracker]|r Battleground starting...")
        KDStatTracker.bgActive = true
        KDStatTracker.savedVars.matchCounter = (KDStatTracker.savedVars.matchCounter or 0) + 1
        KDStatTracker.currentMatchId = GetCurrentBattlegroundId()
        KDStatTracker.currentMatchKills = 0
        KDStatTracker.currentMatchDeaths = 0
        KDStatTracker.currentMatchType = GetBattlegroundGameType(KDStatTracker.currentMatchId)

        local typeMap = {
            [BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG] = "Capture the Relic",
            [BATTLEGROUND_GAME_TYPE_DEATHMATCH] = "Deathmatch",
            [BATTLEGROUND_GAME_TYPE_DOMINATION] = "Domination",
            [BATTLEGROUND_GAME_TYPE_CHAOSBALL] = "Chaosball",
            [BATTLEGROUND_GAME_TYPE_KING_OF_THE_HILL] = "King of the Hill",
            [BATTLEGROUND_GAME_TYPE_MURDERBALL] = "Murderball",
            [BATTLEGROUND_GAME_TYPE_CRAZY_KING] = "Crazy King",
        }
        KDStatTracker.MATCHINFO = typeMap[KDStatTracker.currentMatchType] or "Unknown"
        KDStatTracker.currentCharacterName = GetUnitName("player")
        KDStatTrackerUI.ResetKillStreak()
        d("|cD4266F[KDStatTracker]|r Match: " .. KDStatTracker.MATCHINFO)

    elseif currentStatus == BATTLEGROUND_STATE_FINISHED or currentStatus == BATTLEGROUND_STATE_POSTGAME then
        local matchData = {
            matchId = KDStatTracker.currentMatchId or KDStatTracker.savedVars.matchCounter,
            kills = KDStatTracker.currentMatchKills or 0,
            deaths = KDStatTracker.currentMatchDeaths or 0,
            matchType = KDStatTracker.currentMatchType or 0,
            matchInfo = KDStatTracker.MATCHINFO or "Unknown",
            characterName = GetUnitName("player"),
        }
        KDStatTracker.savedVars.matchHistory = KDStatTracker.savedVars.matchHistory or {}
        table.insert(KDStatTracker.savedVars.matchHistory, matchData)
        if #KDStatTracker.savedVars.matchHistory > 20 then
            table.remove(KDStatTracker.savedVars.matchHistory, 1)
        end
        KDStatTracker.bgActive = false
        local kdRatio = safeKD(matchData.kills, matchData.deaths)
        d(string.format("|cD4266F[KDStatTracker]|r Match ended. K/D: %d/%d (%s)", matchData.kills, matchData.deaths, kdRatio))
        KDStatTracker.currentMatchId = nil
        KDStatTracker.currentMatchKills = nil
        KDStatTracker.currentMatchDeaths = nil
        KDStatTracker.currentMatchType = nil
        KDStatTracker.MATCHINFO = nil
    end
end

-- ========================
-- Combat Event
-- ========================
function OnCombatEvent(eventCode, ...)
    local result, isError, abilityName, abilityGraphic, abilityActionSlotType,
          sourceName, sourceType, targetName, targetType,
          hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId = ...
    local player = zo_strformat("<<1>>", GetUnitName("player") or "")
    local src = zo_strformat("<<1>>", sourceName or "")
    local tgt = zo_strformat("<<1>>", targetName or "")
    if sourceType ~= 5 and targetType ~= 5 then return end
    if sourceType ~= 1 and targetType ~= 1 then return end
    if result ~= 2265 and result ~= ACTION_RESULT_TARGET_DEAD and result ~= ACTION_RESULT_KILLING_BLOW and result ~= ACTION_RESULT_DIED and result ~= ACTION_RESULT_DIED_XP then return end

    if src == player and tgt ~= player then
        if abilityId == 0 then return end
        KDStatTrackerUI.ProcessMultiKill(tgt)
        KDStatTrackerUI.IncrementKillStreak()
        KDStatTrackerUI.RecordKill(abilityId or 0, abilityName or "Unknown", tgt)
    end
end

-- ========================
-- Record Kill / Death
-- ========================
function KDStatTrackerUI.RecordKill(abilityId, abilityName, victim)
    local charName = GetUnitName("player") or "Unknown"

    KDStatTracker.savedVars = KDStatTracker.savedVars or {}
    KDStatTracker.savedVars.killSources = KDStatTracker.savedVars.killSources or {}
    KDStatTracker.savedVars.killSources[charName] = KDStatTracker.savedVars.killSources[charName] or {}

    local tbl = KDStatTracker.savedVars.killSources[charName]
    abilityId = abilityId or 0
    tbl[abilityId] = tbl[abilityId] or { count = 0, lastVictim = "N/A", abilityName = abilityName or "Unknown" }
    tbl[abilityId].count = (tbl[abilityId].count or 0) + 1
    tbl[abilityId].lastVictim = victim or "N/A"
    tbl[abilityId].abilityName = abilityName or "Unknown"

    KDStatTracker.perCharKDA = KDStatTracker.perCharKDA or {}
    KDStatTracker.perCharKDA[charName] = KDStatTracker.perCharKDA[charName] or { kills = 0, deaths = 0 }
    KDStatTracker.perCharKDA[charName].kills = (KDStatTracker.perCharKDA[charName].kills or 0) + 1

    KDStatTracker.savedVars.totalKills = (KDStatTracker.savedVars.totalKills or 0) + 1
    KDStatTracker.KDAVars.kills = (KDStatTracker.KDAVars.kills or 0) + 1

    -- Track victim in current streak
    local streak = GetSavedKillStreak()
    table.insert(streak.victims, victim or "Unknown")

    KDStatTrackerUI.UpdateUI()
    if IsActiveWorldBattleground() then
        KDStatTracker.currentMatchKills = (KDStatTracker.currentMatchKills or 0) + 1
        d("|cD4266F[KD BG]|r Killed " .. (victim or "Unknown") .. " with " .. (abilityName or "Unknown"))
        return
    end
    d("|cD4266F[KD]|r Killed " .. (victim or "Unknown") .. " with " .. (abilityName or "Unknown"))
end

function KDStatTrackerUI.RecordDeath(abilityId, abilityName, killer)
    local charName = GetUnitName("player") or "Unknown"

    KDStatTracker.savedVars = KDStatTracker.savedVars or {}
    KDStatTracker.savedVars.deathSources = KDStatTracker.savedVars.deathSources or {}
    KDStatTracker.savedVars.deathSources[charName] = KDStatTracker.savedVars.deathSources[charName] or {}

    if abilityId == 0 then return end
    local tbl = KDStatTracker.savedVars.deathSources[charName]
    abilityId = abilityId or 0
    tbl[abilityId] = tbl[abilityId] or { count = 0, lastKiller = "N/A", abilityName = abilityName or "Unknown" }
    tbl[abilityId].count = (tbl[abilityId].count or 0) + 1
    tbl[abilityId].lastKiller = killer or "N/A"
    tbl[abilityId].abilityName = abilityName or "Unknown"

    KDStatTracker.perCharKDA = KDStatTracker.perCharKDA or {}
    KDStatTracker.perCharKDA[charName] = KDStatTracker.perCharKDA[charName] or { kills = 0, deaths = 0 }
    KDStatTracker.perCharKDA[charName].deaths = (KDStatTracker.perCharKDA[charName].deaths or 0) + 1
    KDStatTracker.savedVars.totalDeaths = (KDStatTracker.savedVars.totalDeaths or 0) + 1
    KDStatTracker.KDAVars.deaths = (KDStatTracker.KDAVars.deaths or 0) + 1

    KDStatTrackerUI.UpdateUI()
    if IsActiveWorldBattleground() then
        KDStatTracker.currentMatchDeaths = (KDStatTracker.currentMatchDeaths or 0) + 1
        d("|cD4266F[KD BG]|r Died to " .. (abilityName or "Unknown") .. " from " .. (killer or "Unknown"))
        return
    end
    d("|cD4266F[KD]|r Died to " .. (abilityName or "Unknown") .. " from " .. (killer or "Unknown"))
end

-- ========================
-- Slash Commands
-- ========================
SLASH_COMMANDS = SLASH_COMMANDS or {}

function CreateSlashCommands()

    local function IsCurrentMode(modeArg)
        if not modeArg then return false end
        local normalized = string.lower((modeArg:gsub("^%s*(.-)%s*$", "%1")))
        return normalized == "current"
    end

    local function PrintKillStreakSummary(modeArg)
        local history = KDStatTracker.savedVars.killStreakHistory or {}
        local totalStreaks = KDStatTracker.savedVars.totalKillStreaks or 0
        local current = GetSavedKillStreak()

        if IsCurrentMode(modeArg) then
            local curCount = current.count or 0
            local curTier = curCount > 0 and GetStreakName(curCount) or "N/A"
            local victimStr = (current.victims and #current.victims > 0) and table.concat(current.victims, ", ") or "N/A"
            d(string.format("|cD4266F[KDStatTracker]|r |cBF40BFCurrent Killstreak|r -- |cff00ff%d|r |c888888Tier:|r |cD4266F%s|r",
                curCount, curTier))
            d(string.format("  |c888888Victims:|r %s", victimStr))
            return
        end

        local bestCount = current.count or 0
        for _, entry in ipairs(history) do
            if (entry.count or 0) > bestCount then
                bestCount = entry.count or 0
            end
        end
        local bestTier = bestCount > 0 and GetStreakName(bestCount) or "N/A"

        d(string.format("|cD4266F[KDStatTracker]|r |cBF40BFKillstreak Summary|r -- Total streaks: |cff00ff%d|r |c888888Highest Tier:|r |cD4266F%s (%d)|r",
            totalStreaks, bestTier, bestCount))

        if #history == 0 then
            d("  |c888888No killstreaks recorded yet. Get 3+ kills without dying!|r")
            return
        end

        local startIdx = math.max(1, #history - 9)
        for i = startIdx, #history do
            local entry = history[i]
            local victimStr = "N/A"
            if entry.victims and #entry.victims > 0 then
                victimStr = table.concat(entry.victims, ", ")
            end
            local dateStr = ""
            if entry.timestamp then
                dateStr = GetDateStringFromTimestamp(entry.timestamp) or ""
            end
            d(string.format("  |cBF40BF#%d|r |cD4266F%s|r (%d kills) %s",
                i,
                entry.streakName or GetStreakName(entry.count or 0),
                entry.count or 0,
                dateStr))
            d(string.format("    |c888888Victims:|r %s", victimStr))
        end
    end

    local function PrintMultiKillSummary(modeArg)
        local history = KDStatTracker.savedVars.multiKillHistory or {}
        local totalMultiKills = KDStatTracker.savedVars.totalMultiKills or 0
        local current = GetSavedMultiKill()

        if IsCurrentMode(modeArg) then
            local curCount = current.count or 0
            local curTier = curCount > 0 and GetMultiKillName(curCount) or "N/A"
            local victimStr = (current.victims and #current.victims > 0) and table.concat(current.victims, ", ") or "N/A"
            d(string.format("|cD4266F[KDStatTracker]|r |cBF40BFCurrent Multikill|r -- |cff00ff%d|r |c888888Tier:|r |cD4266F%s|r",
                curCount, curTier))
            d(string.format("  |c888888Victims:|r %s", victimStr))
            return
        end

        local bestCount = current.count or 0
        for _, entry in ipairs(history) do
            if (entry.count or 0) > bestCount then
                bestCount = entry.count or 0
            end
        end
        local bestTier = bestCount > 0 and GetMultiKillName(bestCount) or "N/A"

        d(string.format("|cD4266F[KDStatTracker]|r |cBF40BFMultikill Summary|r -- Total multikills: |cff00ff%d|r |c888888Highest Tier:|r |cD4266F%s (%d)|r",
            totalMultiKills, bestTier, bestCount))

        if #history == 0 then
            d("  |c888888No multikills recorded yet. Get 2+ kills within the multikill window!|r")
            return
        end

        local startIdx = math.max(1, #history - 9)
        for i = startIdx, #history do
            local entry = history[i]
            local victimStr = "N/A"
            if entry.victims and #entry.victims > 0 then
                victimStr = table.concat(entry.victims, ", ")
            end
            local dateStr = ""
            if entry.timestamp then
                dateStr = GetDateStringFromTimestamp(entry.timestamp) or ""
            end
            d(string.format("  |cBF40BF#%d|r |cD4266F%s|r (%d kills) %s",
                i,
                entry.multiKillName or GetMultiKillName(entry.count or 0),
                entry.count or 0,
                dateStr))
            d(string.format("    |c888888Victims:|r %s", victimStr))
        end
    end

    SLASH_COMMANDS["/kd"] = function()
        local charName = GetUnitDisplayName("player")
        local kda = KDStatTracker.KDAVars or { kills = 0, deaths = 0 }
        d(("|cD4266F[KDStatTracker]|r %s -- %s"):format(charName, formatKD(kda.kills, kda.deaths)))
    end

    SLASH_COMMANDS["/kdchar"] = function()
        local charName = GetUnitName("player")
        KDStatTracker.perCharKDA = KDStatTracker.perCharKDA or {}
        local kda = KDStatTracker.perCharKDA[charName] or { kills = 0, deaths = 0 }
        d(("|cD4266F[KDStatTracker]|r %s -- %s"):format(charName, formatKD(kda.kills, kda.deaths)))
    end

    SLASH_COMMANDS["/bgstats"] = function()
        local history = KDStatTracker.savedVars.matchHistory or {}
        if #history == 0 then
            d("|cD4266F[KDStatTracker]|r No battleground matches recorded.")
            return
        end
        d("|cD4266F[KDStatTracker]|r Last BG Matches:")
        for i = math.max(1, #history - 9), #history do
            local m = history[i]
            local typeName = KDStatTracker.matchTypes[m.matchType] or "Unknown"
            d(("  |c888888#%d|r %s [%s]: %s"):format(i, m.matchInfo or "Unknown", typeName, formatKD(m.kills, m.deaths)))
        end
    end

    SLASH_COMMANDS["/duelstats"] = function()
        local charName = GetUnitName("player")
        local duels = KDStatTracker.savedVars.duels or {}
        local charData = (duels.perCharStats or {})[charName] or { duels = 0, wins = 0, losses = 0 }
        d(("|cD4266F[KDStatTracker]|r Duels for %s -- Total: %d, |c00ff00Wins: %d|r, |cff0000Losses: %d|r"):format(
            charName, charData.duels or 0, charData.wins or 0, charData.losses or 0))
    end

    SLASH_COMMANDS["/killstats"] = function()
        local charName = GetUnitName("player")
        local kills = (KDStatTracker.savedVars.killSources or {})[charName] or {}
        if next(kills) == nil then
            d("|cD4266F[KDStatTracker]|r No kills recorded for " .. charName)
            return
        end
        d("|cD4266F[KDStatTracker]|r Kill Stats for " .. charName)
        for _, info in pairs(kills) do
            d(("  %s -- %d kills (last: %s)"):format(info.abilityName or "Unknown", info.count or 0, info.lastVictim or "N/A"))
        end
    end

    SLASH_COMMANDS["/deathstats"] = function()
        local charName = GetUnitName("player")
        local deaths = (KDStatTracker.savedVars.deathSources or {})[charName] or {}
        if next(deaths) == nil then
            d("|cD4266F[KDStatTracker]|r No deaths recorded for " .. charName)
            return
        end
        d("|cD4266F[KDStatTracker]|r Death Stats for " .. charName)
        for _, info in pairs(deaths) do
            d(("  %s -- %d deaths (last: %s)"):format(info.abilityName or "Unknown", info.count or 0, info.lastKiller or "N/A"))
        end
    end

    SLASH_COMMANDS["/mostkills"] = function()
        local charName = GetUnitName("player")
        local kills = (KDStatTracker.savedVars.killSources or {})[charName] or {}
        if next(kills) == nil then
            d("|cD4266F[KDStatTracker]|r No kills recorded for " .. charName)
            return
        end
        local topAbility, topCount, lastVictim = "N/A", 0, "N/A"
        for _, info in pairs(kills) do
            if (info.count or 0) > topCount then
                topAbility = info.abilityName or "Unknown"
                topCount = info.count
                lastVictim = info.lastVictim or "N/A"
            end
        end
        d(("|cD4266F[KDStatTracker]|r Most kills: %s -- %d (Last: %s)"):format(topAbility, topCount, lastVictim))
    end

    SLASH_COMMANDS["/mostdeaths"] = function()
        local charName = GetUnitName("player")
        local deaths = (KDStatTracker.savedVars.deathSources or {})[charName] or {}
        if next(deaths) == nil then
            d("|cD4266F[KDStatTracker]|r No deaths recorded for " .. charName)
            return
        end
        local topAbility, topCount, lastKiller = "N/A", 0, "N/A"
        for _, info in pairs(deaths) do
            if (info.count or 0) > topCount then
                topAbility = info.abilityName or "Unknown"
                topCount = info.count
                lastKiller = info.lastKiller or "N/A"
            end
        end
        d(("|cD4266F[KDStatTracker]|r Most deaths: %s -- %d (Last: %s)"):format(topAbility, topCount, lastKiller))
    end

    SLASH_COMMANDS["/duels"] = function(displayName)
        local charName = GetUnitName("player")
        local charData = (KDStatTracker.savedVars.duels.perCharStats or {})[charName]
        if not charData then
            d("|cD4266F[KDStatTracker]|r No duel data for " .. charName)
            return
        end
        if displayName == "" or not displayName then
            local wlRatio = string.format("%.2f", charData.wins / math.max(charData.losses, 1))
            d(string.format("|cD4266F[KDStatTracker]|r Duels for %s -- Total: %d, |c00ff00Wins: %d|r, |cff0000Losses: %d|r, |cff00ffW/L: %s|r",
                charName, charData.duels or 0, charData.wins or 0, charData.losses or 0, wlRatio))
            return
        end
        if not string.find(displayName, "@", 1, true) then
            d("|cD4266F[KDStatTracker]|r Use format: /duels @DisplayName")
            return
        end
        if charData.charactersFaced and charData.charactersFaced[displayName] then
            local faced = charData.charactersFaced[displayName]
            local wlRatio = string.format("%.2f", faced.wins / math.max(faced.losses, 1))
            d(string.format("|cD4266F[KDStatTracker]|r vs %s -- |c00ff00Wins: %d|r, |cff0000Losses: %d|r, |cff00ffW/L: %s|r",
                displayName, faced.wins or 0, faced.losses or 0, wlRatio))
        else
            d("|cff0000[KDStatTracker]|r No duel data against " .. displayName)
        end
    end

    SLASH_COMMANDS["/killstreak"] = PrintKillStreakSummary
    SLASH_COMMANDS["/killstreaks"] = PrintKillStreakSummary
    SLASH_COMMANDS["/multikills"] = PrintMultiKillSummary

    SLASH_COMMANDS["/kdhelp"] = function()
        d("|cD4266F[KDStatTracker]|r |cBF40BFCommands:|r")
        d("  /kd -- Current K/D stats")
        d("  /kdchar -- Character-specific K/D")
        d("  /bgstats -- Last BG matches")
        d("  /duelstats -- Duel stats")
        d("  /killstats -- Kills per ability")
        d("  /deathstats -- Deaths per ability")
        d("  /mostkills -- Top kill ability")
        d("  /mostdeaths -- Top death ability")
        d("  /duels @Name -- Duel record vs player")
        d("  |cff00ff/killstreak|r -- |cBF40BFKillstreak summary/history with highest tier|r")
        d("  |cff00ff/killstreak current|r -- |cBF40BFShow only active killstreak chain|r")
        d("  |cff00ff/killstreaks|r -- |cBF40BFAlias of /killstreak|r")
        d("  |cff00ff/multikills|r -- |cBF40BFMultikill summary/history with highest tier|r")
        d("  |cff00ff/multikills current|r -- |cBF40BFShow only active multikill chain|r")
    end
end

-- ========================
-- Initialization
-- ========================
function KDStatTrackerUI.Initialize()
    KDStatTracker.savedVars = ZO_SavedVars:NewAccountWide(
        "KDStatTrackerVars", 1, nil, KDStatTracker.defaults
    )
    KDStatTracker.KDAVars = ZO_SavedVars:NewAccountWide(
        "KDStatTrackerKDA", 1, nil, KDStatTracker.KDAVars
    )
    KDStatTracker.SettingsVars = ZO_SavedVars:NewAccountWide(
        "KDStatTrackerSettings", 1, nil, KDStatTracker.default_settings
    )
    KDStatTracker.perCharKDA = KDStatTracker.savedVars.perCharKDA or {}

    -- Ensure new fields exist on upgrade
    KDStatTracker.savedVars.killStreakHistory = KDStatTracker.savedVars.killStreakHistory or {}
    KDStatTracker.savedVars.totalKillStreaks = KDStatTracker.savedVars.totalKillStreaks or 0
    KDStatTracker.savedVars.currentKillStreak = KDStatTracker.savedVars.currentKillStreak or { count = 0, lastKillTime = 0, victims = {} }
    KDStatTracker.savedVars.currentKillStreak.victims = KDStatTracker.savedVars.currentKillStreak.victims or {}
    KDStatTracker.savedVars.multiKillHistory = KDStatTracker.savedVars.multiKillHistory or {}
    KDStatTracker.savedVars.totalMultiKills = KDStatTracker.savedVars.totalMultiKills or 0
    KDStatTracker.savedVars.currentMultiKill = KDStatTracker.savedVars.currentMultiKill or { count = 0, lastKillTime = 0, victims = {} }
    KDStatTracker.savedVars.currentMultiKill.victims = KDStatTracker.savedVars.currentMultiKill.victims or {}

    KDStatTrackerUI.CreateUI()

    EVENT_MANAGER:RegisterForEvent(KDStatTracker.name .. "_CombatEvent", EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent(KDStatTracker.name .. "_ActivityFinderStatusUpdate", EVENT_BATTLEGROUND_STATE_CHANGED, OnActivityFinderStatusUpdate)
    EVENT_MANAGER:RegisterForEvent(KDStatTracker.name .. "_DuelStateChanged", EVENT_DUEL_FINISHED, isDuelingStateChanged)
    EVENT_MANAGER:RegisterForEvent(KDStatTracker.name .. "_CombatDeath", EVENT_UNIT_DEATH_STATE_CHANGED, OnUnitDeathStateChanged)

    CreateSlashCommands()
end

function KDStatTracker.OnAddOnLoaded(event, addonName)
    if addonName ~= KDStatTracker.name then return end
    EVENT_MANAGER:UnregisterForEvent(KDStatTracker.name, EVENT_ADD_ON_LOADED)
    KDStatTracker.isLoaded = true
    d("|cD4266F[KDStatTracker]|r v" .. KDStatTracker.version .. " loaded. Type |cff00ff/kdhelp|r for commands.")
    KDStatTrackerUI.Initialize()
end

EVENT_MANAGER:RegisterForEvent(KDStatTracker.name, EVENT_ADD_ON_LOADED, KDStatTracker.OnAddOnLoaded)
