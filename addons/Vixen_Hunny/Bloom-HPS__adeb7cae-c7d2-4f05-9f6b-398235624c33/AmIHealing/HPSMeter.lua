-- ======================
-- HPSMeter - Console & PvP Safe
-- ======================

HPSMeterUI = {}
local tooltip = nil
local LAM = LibAddonMenu2 or {}
-- Default settings
HPSMeterUI.defaults = {
    showLabel = true,
    labelX = 300,
    labelY = 200,
    window = 10,
    scale = 0.5,
    labelColor = "9ff8ba",
    showShields = true,
    shieldLabelx = 350,
    shieldLabely = 200,
    shieldWindow = 10,
    shieldScale = 0.5,
    shieldColor = "b8f7ff",
    showOverall = true,
    overallColor = "d6ffd6",
    resetTimer = 300,
    topHealing = 0,
    topShielding = 0,
    topMitigation = 0,
    bgHistory = {}
}

-- Saved variables

-- Core data
-- Shield SPS rolling window
HPSMeterUI.shieldBuckets = {}
HPSMeterUI.shieldBucketStartSec = 0
HPSMeterUI.shieldBucketTotal = 0
HPSMeterUI.firstShieldTimeMs = 0
HPSMeterUI.bucketStartSec = 0

-- Overall totals (since last reset / idle reset)
HPSMeterUI.overallHealingTotal = 0
HPSMeterUI.overallShieldingTotal = 0
HPSMeterUI.bucketTotal = 0
HPSMeterUI.pvpEvents = {}
HPSMeterUI.buckets = {}
HPSMeterUI.enemyHealing = {}
HPSMeterUI.enemyUnits = {}
HPSMeterUI.enemyLinesControls = {}
HPSMeterUI.graphNumbers = {}
HPSMeterUI.lastHealTime = GetGameTimeMilliseconds()
HPSMeterUI.enemyHP = {}
HPSMeterUI.alliedHP = 0
HPSMeterUI.idleTimeout = 300000
HPSMeterUI.firstHealTime = GetGameTimeMilliseconds()
HPSMeterUI.lastShieldTime = GetGameTimeMilliseconds()
HPSMeterUI.lastEnemyHealTick = 0
-- In your initialization or CreateUI
HPSMeterUI.myShieldedTargets = {} -- Key: unitName, Value: currentShieldValue
HPSMeterUI.currentTotalShields = 0
HPSMeterUI.overallMitigatedTotal = 0
HPSMeterUI.overallPostShieldDamageTotal = 0
HPSMeterUI.personalHealTotal = 0
HPSMeterUI.groupHealTotal = 0
HPSMeterUI.personalShieldTotal = 0
HPSMeterUI.groupShieldTotal = 0


-- Inside HPSMeterUI:Reset()

HPSMeterUI.lastAlliedHealTick = 0
-- ======================
-- Utility functions
-- ======================
function HPSMeterUI:IsPvP()
    return true
end
local function FormatShortNumber(n)
    n = tonumber(n) or 0
    local absN = math.abs(n)

    if absN >= 1000000000 then
        local v = n / 1000000000
        return (absN >= 10000000000) and string.format("%.0fb", v) or string.format("%.1fb", v):gsub("%.0b", "b")
    elseif absN >= 1000000 then
        local v = n / 1000000
        return (absN >= 10000000) and string.format("%.0fm", v) or string.format("%.1fm", v):gsub("%.0m", "m")
    elseif absN >= 1000 then
        local v = n / 1000
        return (absN >= 10000) and string.format("%.0fk", v) or string.format("%.1fk", v):gsub("%.0k", "k")
    else
        return tostring(n)
    end
end

local function HexToRGBA(hex, alpha)
    local clean = tostring(hex or "ffffff"):gsub("#", "")
    if #clean ~= 6 then
        clean = "ffffff"
    end

    local r = tonumber(clean:sub(1, 2), 16) or 255
    local g = tonumber(clean:sub(3, 4), 16) or 255
    local b = tonumber(clean:sub(5, 6), 16) or 255
    return r / 255, g / 255, b / 255, alpha or 1
end

local function StripESOColorCodes(text)
    local clean = tostring(text or "")
    return clean
end

function HPSMeterUI:SetHealingLabelText(text)
    if HPSMeterUI.labelShadowControl then
        HPSMeterUI.labelShadowControl:SetText(StripESOColorCodes(text))
    end
    if HPSMeterUI.labelControl then
        HPSMeterUI.labelControl:SetText(text)
    end
end

function HPSMeterUI:SetShieldLabelText(text)
    if HPSMeterUI.shieldShadowControl then
        HPSMeterUI.shieldShadowControl:SetText(StripESOColorCodes(text))
    end
    if HPSMeterUI.shieldControl then
        HPSMeterUI.shieldControl:SetText(text)
    end
end

function HPSMeterUI:SetHealingOverallText(text)
    if HPSMeterUI.labelOverallShadowControl then
        HPSMeterUI.labelOverallShadowControl:SetText(StripESOColorCodes(text))
    end
    if HPSMeterUI.labelOverallControl then
        HPSMeterUI.labelOverallControl:SetText(text)
    end
end

function HPSMeterUI:RefreshWardenThemeLayout()
    if not HPSMeterUI.control then return end
    if not HPSMeterUI.backdropControl then return end

    if not HPSMeterUI.saved.showLabel then
        HPSMeterUI.backdropControl:SetHidden(true)
        if HPSMeterUI.titleControl then HPSMeterUI.titleControl:SetHidden(true) end
        if HPSMeterUI.flowerTop then HPSMeterUI.flowerTop:SetHidden(true) end
        if HPSMeterUI.flowerBottom then HPSMeterUI.flowerBottom:SetHidden(true) end
        return
    end

    local scale = math.max(HPSMeterUI.saved.scale, 0.3)
    -- Width covers HPS + SPS on line 1 plus group/personal labels below
    local labelWidth  = 520 * scale
    local labelHeight = 90  * scale

    local panelX = HPSMeterUI.saved.labelX - 18
    local panelY = HPSMeterUI.saved.labelY - 24
    local panelW = labelWidth  + 36
    local panelH = labelHeight + 38

    HPSMeterUI.backdropControl:ClearAnchors()
    HPSMeterUI.backdropControl:SetAnchor(TOPLEFT, HPSMeterUI.control, TOPLEFT, panelX, panelY)
    HPSMeterUI.backdropControl:SetDimensions(panelW, panelH)
    HPSMeterUI.backdropControl:SetHidden(false)

    if HPSMeterUI.titleControl then
        HPSMeterUI.titleControl:ClearAnchors()
        HPSMeterUI.titleControl:SetAnchor(TOP, HPSMeterUI.backdropControl, TOP, 0, 2)
        HPSMeterUI.titleControl:SetHidden(false)
    end

    if HPSMeterUI.flowerTop then
        HPSMeterUI.flowerTop:ClearAnchors()
        HPSMeterUI.flowerTop:SetAnchor(TOP, HPSMeterUI.backdropControl, TOP, 0, 16)
        HPSMeterUI.flowerTop:SetHidden(false)
    end

    if HPSMeterUI.flowerBottom then
        HPSMeterUI.flowerBottom:ClearAnchors()
        HPSMeterUI.flowerBottom:SetAnchor(BOTTOM, HPSMeterUI.backdropControl, BOTTOM, 0, -2)
        HPSMeterUI.flowerBottom:SetHidden(false)
    end
end

-- Examples
-- FormatShortNumber(1000)    -> "1k"
-- FormatShortNumber(1500)    -> "1.5k"
-- FormatShortNumber(9999)    -> "10.0k" (see note below)
-- FormatShortNumber(12000)   -> "12k"
-- FormatShortNumber(1000000) -> "1m"
function HPSMeterUI:Reset()
    HPSMeterUI:SavePreviousBGStats()
    HPSMeterUI.bucketTotal = 0
    HPSMeterUI.shieldBucketTotal = 0
    HPSMeterUI.overallHealingTotal = 0
    HPSMeterUI.overallShieldingTotal = 0
    HPSMeterUI.personalHealTotal = 0
    HPSMeterUI.groupHealTotal = 0
    HPSMeterUI.personalShieldTotal = 0
    HPSMeterUI.groupShieldTotal = 0

    HPSMeterUI.bucketStartSec = 0
    HPSMeterUI.shieldBucketStartSec = 0

    HPSMeterUI:InitBuckets()
    HPSMeterUI:InitShieldBuckets()
    HPSMeterUI.overallMitigatedTotal = 0
    HPSMeterUI.overallPostShieldDamageTotal = 0
    HPSMeterUI.firstShieldTimeMs = 0

    HPSMeterUI.myShieldedTargets = {}

    if HPSMeterUI.labelControl then
        HPSMeterUI:SetHealingLabelText(string.format("|c%sHPS: 0|r  |c%sSPS: 0|r",
            HPSMeterUI.saved.labelColor or "9ff8ba",
            HPSMeterUI.saved.shieldColor or "b8f7ff"
        ))
    end
end

function HPSMeterUI:GetMitigatedPercent()
    local mitigated = HPSMeterUI.overallMitigatedTotal or 0
    local post = HPSMeterUI.overallShieldingTotal or 0
    local total = mitigated + post
    if total <= 0 then return 0 end
    return (mitigated / total) * 100
end

function HPSMeterUI:GetSavedBGMaxStats()
    if not HPSMeterUI.saved then
        return 0, 0, 0
    end

    local maxHealing = HPSMeterUI.saved.topHealing or 0
    local maxShielding = HPSMeterUI.saved.topShielding or 0
    local maxMitigation = HPSMeterUI.saved.topMitigation or 0

    if HPSMeterUI.saved.bgHistory then
        for _, entry in ipairs(HPSMeterUI.saved.bgHistory) do
            if entry then
                maxHealing = math.max(maxHealing, tonumber(entry.healing) or 0)
                maxShielding = math.max(maxShielding, tonumber(entry.shielding) or 0)
                maxMitigation = math.max(maxMitigation, tonumber(entry.mitigation) or 0)
            end
        end
    end

    return maxHealing, maxShielding, maxMitigation
end

function HPSMeterUI:SavePreviousBGStats()
    if not HPSMeterUI.saved then return end

    local healing = HPSMeterUI.overallHealingTotal or 0
    local shielding = HPSMeterUI.overallShieldingTotal or 0
    local mitigation = HPSMeterUI:GetMitigatedPercent()

    HPSMeterUI.saved.topHealing = math.max(HPSMeterUI.saved.topHealing or 0, healing)
    HPSMeterUI.saved.topShielding = math.max(HPSMeterUI.saved.topShielding or 0, shielding)
    HPSMeterUI.saved.topMitigation = math.max(HPSMeterUI.saved.topMitigation or 0, mitigation)

    HPSMeterUI.saved.bgHistory = HPSMeterUI.saved.bgHistory or {}
    table.insert(HPSMeterUI.saved.bgHistory, {
        healing = healing,
        shielding = shielding,
        mitigation = mitigation,
        timestamp = GetDateStringFromTimestamp(GetTimeStamp()) or ""
    })

    while #HPSMeterUI.saved.bgHistory > 20 do
        table.remove(HPSMeterUI.saved.bgHistory, 1)
    end
end

function HPSMeterUI:PrintSavedBGStats()
    if not HPSMeterUI.saved then return end

    local maxHealing, maxShielding, maxMitigation = HPSMeterUI:GetSavedBGMaxStats()
    local msg = string.format(
        "Bloom HPS Best Stats | Healing: %s | Shielding: %s | Mitigation: %.1f%% | Entries: %d",
        FormatShortNumber(math.floor(maxHealing)),
        FormatShortNumber(math.floor(maxShielding)),
        maxMitigation,
        #(HPSMeterUI.saved.bgHistory or {})
    )

    if IsConsoleUI() then
        if CHAT_ROUTER then
            CHAT_ROUTER:AddSystemMessage(msg)
        else
            d(msg)
        end
    else
        d(msg)
    end
end

function HPSMeterUI:ResetSavedBGStats()
    if not HPSMeterUI.saved then return end

    HPSMeterUI.saved.topHealing = 0
    HPSMeterUI.saved.topShielding = 0
    HPSMeterUI.saved.topMitigation = 0
    HPSMeterUI.saved.bgHistory = {}

    local msg = "Bloom HPS saved BG history cleared."
    if IsConsoleUI() then
        if CHAT_ROUTER then
            CHAT_ROUTER:AddSystemMessage(msg)
        else
            d(msg)
        end
    else
        StartChatInput(msg)
    end
end


-- ======================
-- UI: Lazy creation
-- ======================
function HPSMeterUI:GetElapsedShieldSeconds()
    if (HPSMeterUI.firstShieldTimeMs or 0) == 0 then return 0 end
    local elapsed = (GetGameTimeMilliseconds() - HPSMeterUI.firstShieldTimeMs) / 1000
    if elapsed < 0 then elapsed = 0 end
    return elapsed
end

function HPSMeterUI:GetAvgShieldPS()
    local elapsed = HPSMeterUI:GetElapsedShieldSeconds()
    if elapsed <= 0 then return 0 end
    return (HPSMeterUI.overallShieldingTotal or 0) / elapsed
end

function HPSMeterUI:CreateUI()
    local control = WINDOW_MANAGER:GetControlByName("HPSMeterControl") or WINDOW_MANAGER:CreateTopLevelWindow("HPSMeterControl")
    HPSMeterUI.control = control
    control:SetClampedToScreen(true)
    control:SetMouseEnabled(false)
    control:ClearAnchors()
    control:SetAnchorFill(GuiRoot)

    HPSMeterUI.backdropControl = WINDOW_MANAGER:GetControlByName("HPSMeterBackdrop") or WINDOW_MANAGER:CreateControl("HPSMeterBackdrop", control, CT_BACKDROP)
    HPSMeterUI.backdropControl:SetCenterTexture("EsoUI/Art/Miscellaneous/white.dds")
    HPSMeterUI.backdropControl:SetEdgeTexture("EsoUI/Art/Miscellaneous/white.dds", 1, 1, 2)
    HPSMeterUI.backdropControl:SetInsets(0, 0, -1, -1)
    HPSMeterUI.backdropControl:SetCenterColor(HexToRGBA("132c1f", 0.72))
    HPSMeterUI.backdropControl:SetEdgeColor(HexToRGBA("8ecf9a", 0.95))

    HPSMeterUI.titleControl = WINDOW_MANAGER:GetControlByName("HPSMeterTitleLabel") or WINDOW_MANAGER:CreateControl("HPSMeterTitleLabel", control, CT_LABEL)
    HPSMeterUI.titleControl:SetFont("ZoFontWinH4")
    HPSMeterUI.titleControl:SetColor(HexToRGBA("c4ffd0", 1))
    HPSMeterUI.titleControl:SetText("")
    HPSMeterUI.titleControl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    HPSMeterUI.flowerTop = WINDOW_MANAGER:GetControlByName("HPSMeterFlowerTop") or WINDOW_MANAGER:CreateControl("HPSMeterFlowerTop", control, CT_LABEL)
    HPSMeterUI.flowerTop:SetFont("ZoFontGame")
    HPSMeterUI.flowerTop:SetColor(HexToRGBA("8bd18d", 1))
    HPSMeterUI.flowerTop:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    HPSMeterUI.flowerTop:SetText("")

    HPSMeterUI.flowerBottom = WINDOW_MANAGER:GetControlByName("HPSMeterFlowerBottom") or WINDOW_MANAGER:CreateControl("HPSMeterFlowerBottom", control, CT_LABEL)
    HPSMeterUI.flowerBottom:SetFont("ZoFontGame")
    HPSMeterUI.flowerBottom:SetColor(HexToRGBA("79bc8f", 1))
    HPSMeterUI.flowerBottom:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    HPSMeterUI.flowerBottom:SetText("")

    HPSMeterUI.labelControl = WINDOW_MANAGER:GetControlByName("HPSMeterLabel") or WINDOW_MANAGER:CreateControl("HPSMeterLabel", control, CT_LABEL)
    HPSMeterUI.labelShadowControl = WINDOW_MANAGER:GetControlByName("HPSMeterLabelShadow") or WINDOW_MANAGER:CreateControl("HPSMeterLabelShadow", control, CT_LABEL)
    HPSMeterUI.labelShadowControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * HPSMeterUI.saved.scale))))
    HPSMeterUI.labelShadowControl:SetColor(0.05, 0.14, 0.08, 0.95)
    HPSMeterUI.labelShadowControl:ClearAnchors()
    HPSMeterUI.labelShadowControl:SetAnchor(TOPLEFT, HPSMeterUI.labelControl, TOPLEFT, 1, 1)
    HPSMeterUI.labelShadowControl:SetScale(HPSMeterUI.saved.scale)
    HPSMeterUI.labelShadowControl:SetHidden(not HPSMeterUI.saved.showLabel)

    HPSMeterUI.labelControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * HPSMeterUI.saved.scale))))
    HPSMeterUI.labelControl:ClearAnchors()
    HPSMeterUI.labelControl:SetAnchor(TOPLEFT, control, TOPLEFT, HPSMeterUI.saved.labelX, HPSMeterUI.saved.labelY)
    HPSMeterUI.labelControl:SetScale(HPSMeterUI.saved.scale)
    HPSMeterUI.labelControl:SetHidden(not HPSMeterUI.saved.showLabel)

    HPSMeterUI.healerIcon = WINDOW_MANAGER:GetControlByName("HPSMeterHealerIcon") or WINDOW_MANAGER:CreateControl("HPSMeterHealerIcon", control, CT_TEXTURE)
    HPSMeterUI.healerIcon:SetTexture("AmIHealing/textures/heart.dds")
    HPSMeterUI.healerIcon:SetDimensions(24, 24)
    HPSMeterUI.healerIcon:ClearAnchors()
    HPSMeterUI.healerIcon:SetAnchor(LEFT, HPSMeterUI.labelControl, RIGHT, 8, 0)
    HPSMeterUI.healerIcon:SetScale(HPSMeterUI.saved.scale)
    HPSMeterUI.healerIcon:SetAlpha(0.6)
    HPSMeterUI.healerIcon:SetHidden(false)

    HPSMeterUI.labelOverallControl = WINDOW_MANAGER:GetControlByName("HPSMeterOverallLabel") or WINDOW_MANAGER:CreateControl("HPSMeterOverallLabel", control, CT_LABEL)
    HPSMeterUI.labelOverallShadowControl = WINDOW_MANAGER:GetControlByName("HPSMeterOverallLabelShadow") or WINDOW_MANAGER:CreateControl("HPSMeterOverallLabelShadow", control, CT_LABEL)
    HPSMeterUI.labelOverallShadowControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * HPSMeterUI.saved.scale))))
    HPSMeterUI.labelOverallShadowControl:SetColor(0.05, 0.14, 0.08, 0.95)
    HPSMeterUI.labelOverallShadowControl:ClearAnchors()
    HPSMeterUI.labelOverallShadowControl:SetAnchor(TOPLEFT, HPSMeterUI.labelOverallControl, TOPLEFT, 1, 1)
    HPSMeterUI.labelOverallShadowControl:SetScale(HPSMeterUI.saved.scale)
    HPSMeterUI.labelOverallShadowControl:SetHidden(not HPSMeterUI.saved.showLabel or not HPSMeterUI.saved.showOverall)

    HPSMeterUI.labelOverallControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * HPSMeterUI.saved.scale))))
    HPSMeterUI.labelOverallControl:ClearAnchors()
    HPSMeterUI.labelOverallControl:SetAnchor(TOPLEFT, HPSMeterUI.labelControl, BOTTOMLEFT, 0, 2)
    HPSMeterUI.labelOverallControl:SetScale(HPSMeterUI.saved.scale)
    HPSMeterUI.labelOverallControl:SetHidden(not HPSMeterUI.saved.showLabel or not HPSMeterUI.saved.showOverall)

    HPSMeterUI.healerIconOverall = WINDOW_MANAGER:GetControlByName("HPSMeterHealerIconOverall") or WINDOW_MANAGER:CreateControl("HPSMeterHealerIconOverall", control, CT_TEXTURE)
    HPSMeterUI.healerIconOverall:SetTexture("AmIHealing/textures/heart.dds")
    HPSMeterUI.healerIconOverall:SetDimensions(24, 24)
    HPSMeterUI.healerIconOverall:ClearAnchors()
    HPSMeterUI.healerIconOverall:SetAnchor(LEFT, HPSMeterUI.labelOverallControl, RIGHT, 8, 0)
    HPSMeterUI.healerIconOverall:SetScale(HPSMeterUI.saved.scale)
    HPSMeterUI.healerIconOverall:SetAlpha(0.6)
    HPSMeterUI.healerIconOverall:SetHidden(not HPSMeterUI.saved.showLabel or not HPSMeterUI.saved.showOverall)

    HPSMeterUI.shieldControl = WINDOW_MANAGER:GetControlByName("HPSMeterShieldLabel") or WINDOW_MANAGER:CreateControl("HPSMeterShieldLabel", control, CT_LABEL)
    HPSMeterUI.shieldShadowControl = WINDOW_MANAGER:GetControlByName("HPSMeterShieldLabelShadow") or WINDOW_MANAGER:CreateControl("HPSMeterShieldLabelShadow", control, CT_LABEL)
    HPSMeterUI.shieldShadowControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * HPSMeterUI.saved.shieldScale))))
    HPSMeterUI.shieldShadowControl:SetColor(0.04, 0.12, 0.16, 0.95)
    HPSMeterUI.shieldShadowControl:ClearAnchors()
    HPSMeterUI.shieldShadowControl:SetAnchor(TOPLEFT, HPSMeterUI.shieldControl, TOPLEFT, 1, 1)
    HPSMeterUI.shieldShadowControl:SetScale(HPSMeterUI.saved.shieldScale)
    HPSMeterUI.shieldShadowControl:SetHidden(not HPSMeterUI.saved.showShields)

    HPSMeterUI.shieldControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * HPSMeterUI.saved.shieldScale))))
    HPSMeterUI.shieldControl:ClearAnchors()
    HPSMeterUI.shieldControl:SetAnchor(TOPLEFT, control, TOPLEFT, HPSMeterUI.saved.shieldLabelx, HPSMeterUI.saved.shieldLabely)
    HPSMeterUI.shieldControl:SetScale(HPSMeterUI.saved.shieldScale)
    HPSMeterUI.shieldControl:SetHidden(not HPSMeterUI.saved.showShields)

    HPSMeterUI.flowerIcon = WINDOW_MANAGER:GetControlByName("HPSMeterFlowerIcon") or WINDOW_MANAGER:CreateControl("HPSMeterFlowerIcon", control, CT_TEXTURE)
    HPSMeterUI.flowerIcon:SetTexture("AmIHealing/textures/shield.dds")
    HPSMeterUI.flowerIcon:SetDimensions(24, 24)
    HPSMeterUI.flowerIcon:ClearAnchors()
    HPSMeterUI.flowerIcon:SetAnchor(LEFT, HPSMeterUI.shieldControl, RIGHT, 8, 0)
    HPSMeterUI.flowerIcon:SetScale(HPSMeterUI.saved.shieldScale)
    HPSMeterUI.flowerIcon:SetAlpha(0.6)
    HPSMeterUI.flowerIcon:SetHidden(not HPSMeterUI.saved.showShields)

    -- Hide controls now merged into the combined labelControl display
    if HPSMeterUI.shieldControl then HPSMeterUI.shieldControl:SetHidden(true) end
    if HPSMeterUI.shieldShadowControl then HPSMeterUI.shieldShadowControl:SetHidden(true) end
    if HPSMeterUI.flowerIcon then HPSMeterUI.flowerIcon:SetHidden(true) end
    if HPSMeterUI.labelOverallControl then HPSMeterUI.labelOverallControl:SetHidden(true) end
    if HPSMeterUI.labelOverallShadowControl then HPSMeterUI.labelOverallShadowControl:SetHidden(true) end
    if HPSMeterUI.healerIcon then HPSMeterUI.healerIcon:SetHidden(true) end
    if HPSMeterUI.healerIconOverall then HPSMeterUI.healerIconOverall:SetHidden(true) end

    HPSMeterUI:RefreshWardenThemeLayout()
    HPSMeterUI:UpdateDisplay()

end
function HPSMeterUI:LinkHealingData()
    local msg = "Bloom HPS Healing Data |"
        .. "  Overall Healing: " .. tostring(FormatShortNumber(math.floor(HPSMeterUI.overallHealingTotal or 0)))
        .. " | Personal Healing: " .. tostring(FormatShortNumber(math.floor(HPSMeterUI.personalHealTotal or 0)))
        .. " | Group Healing: " .. tostring(FormatShortNumber(math.floor(HPSMeterUI.groupHealTotal or 0)))
        .. " | HPS: " .. tostring(math.floor(HPSMeterUI.bucketTotal / math.max(1, HPSMeterUI.saved.window)))
        .. " | Mitigated Total: " .. tostring(FormatShortNumber(math.floor(HPSMeterUI.overallMitigatedTotal or 0)))
        .. " | Mitigated: " .. string.format("%.1f", HPSMeterUI:GetMitigatedPercent()) .. "%"
        .. " | Overall Shielding: " .. tostring(FormatShortNumber(math.floor(HPSMeterUI.overallShieldingTotal or 0)))
        .. " | Personal Shielding: " .. tostring(FormatShortNumber(math.floor(HPSMeterUI.personalShieldTotal or 0)))
        .. " | Group Shielding: " .. tostring(FormatShortNumber(math.floor(HPSMeterUI.groupShieldTotal or 0)))
        .. " | Lifetime SPS: " .. tostring(math.floor(HPSMeterUI:GetLifetimeShieldPS()))
    if IsConsoleUI() then
        -- Console: output to system chat (StartChatInput not available on Xbox)
        if CHAT_ROUTER then
            CHAT_ROUTER:AddSystemMessage(msg)
        else
            d(msg)
        end
    else
        StartChatInput(msg)
    end
end
-- ======================
-- LibAddonMenu
-- ======================
function HPSMeterUI:InitBuckets()
    HPSMeterUI.buckets = {}
    for i = 1, HPSMeterUI.saved.window do HPSMeterUI.buckets[i] = 0 end
    HPSMeterUI.bucketStartSec = math.floor(GetGameTimeMilliseconds() / 1000)
    HPSMeterUI.bucketTotal = 0
end

function HPSMeterUI:AdvanceBuckets(nowSec)
    if (HPSMeterUI.bucketStartSec or 0) == 0 then
        HPSMeterUI.bucketStartSec = nowSec
        return
    end

    local diff = nowSec - HPSMeterUI.bucketStartSec
    if diff <= 0 then return end

    -- drop one bucket per elapsed second so HPS is a true rolling window
    for _ = 1, math.min(diff, HPSMeterUI.saved.window) do
        local dropped = table.remove(HPSMeterUI.buckets, 1)
        HPSMeterUI.bucketTotal = HPSMeterUI.bucketTotal - (dropped or 0)
        table.insert(HPSMeterUI.buckets, 0)
    end

    HPSMeterUI.bucketStartSec = nowSec
end

-- ======================
-- Combined display: HPS | SPS on line 1, Group totals on line 2, Personal totals on line 3
-- ======================
function HPSMeterUI:UpdateDisplay()
    if not HPSMeterUI.labelControl then return end

    local nowSec = math.floor(GetGameTimeMilliseconds() / 1000)
    HPSMeterUI:AdvanceBuckets(nowSec)
    HPSMeterUI:AdvanceShieldBuckets(nowSec)

    local hps = (HPSMeterUI.bucketTotal or 0) / math.max(1, HPSMeterUI.saved.window)
    local sps = (HPSMeterUI.shieldBucketTotal or 0) / math.max(1, HPSMeterUI.saved.shieldWindow)

    local personalHeal   = HPSMeterUI.personalHealTotal or 0
    local groupHeal      = HPSMeterUI.groupHealTotal or 0
    local personalShield = HPSMeterUI.personalShieldTotal or 0
    local groupShield    = HPSMeterUI.groupShieldTotal or 0

    local hColor = HPSMeterUI.saved.labelColor or "9ff8ba"
    local sColor = HPSMeterUI.saved.shieldColor or "b8f7ff"

    -- Line 1: rolling HPS and SPS always shown
    local text = string.format("|c%sHPS: %s|r  |c%sSPS: %s|r",
        hColor, FormatShortNumber(math.floor(hps)),
        sColor, FormatShortNumber(math.floor(sps))
    )

    -- Line 2: group totals (only shown when non-zero)
    local line2parts = {}
    if groupHeal > 0 then
        table.insert(line2parts, string.format("|c%sHeal Group: %s|r", hColor, FormatShortNumber(groupHeal)))
    end
    if groupShield > 0 then
        table.insert(line2parts, string.format("|c%sShield Group: %s|r", sColor, FormatShortNumber(groupShield)))
    end
    if #line2parts > 0 then
        text = text .. "\r\n" .. table.concat(line2parts, "  ")
    end

    -- Line 3: personal totals (only shown when non-zero)
    local line3parts = {}
    if personalHeal > 0 then
        table.insert(line3parts, string.format("|c%sHeal Personal: %s|r", hColor, FormatShortNumber(personalHeal)))
    end
    if personalShield > 0 then
        table.insert(line3parts, string.format("|c%sShield Personal: %s|r", sColor, FormatShortNumber(personalShield)))
    end
    if #line3parts > 0 then
        text = text .. "\r\n" .. table.concat(line3parts, "  ")
    end
    if HPSMeterUI.saved.showShields and HPSMeterUI.saved.showLabel then
        text = text .. string.format("\r\n|c%sMitigated: %s%%|r", sColor, string.format("%.1f", HPSMeterUI:GetMitigatedPercent()))
    end
    if HPSMeterUI.saved.showOverall and HPSMeterUI.saved.showLabel then
        local overallHPS = (HPSMeterUI.overallHealingTotal or 0) / math.max(1, (GetGameTimeMilliseconds() - HPSMeterUI.firstHealTime) / 1000)
        local overallSPS = (HPSMeterUI.overallShieldingTotal or 0) / math.max(1, HPSMeterUI:GetElapsedShieldSeconds())
        text = text .. string.format("\r\n|c%sOverall HPS: %s|r  |c%sOverall SPS: %s|r",
            hColor, FormatShortNumber(math.floor(overallHPS)),
            sColor, FormatShortNumber(math.floor(overallSPS))
        )
    end
    HPSMeterUI:SetHealingLabelText(text)
end

function HPSMeterUI:GetHPS()
    HPSMeterUI:UpdateDisplay()
    return (HPSMeterUI.bucketTotal or 0) / math.max(1, HPSMeterUI.saved.window)
end
function HPSMeterUI:IsMyShieldActive(name)
    local entry = self.myShieldedTargets[name]
    if not entry then return false end
    return (tonumber(entry.activeUntil) or 0) > GetGameTimeMilliseconds()
end


HPSMeterUI.myShieldedTargets = {} -- Track names of people we shielded
function HPSMeterUI:InitShieldBuckets()
    HPSMeterUI.shieldBuckets = {}
    for i = 1, HPSMeterUI.saved.shieldWindow do
        HPSMeterUI.shieldBuckets[i] = 0
    end
    HPSMeterUI.shieldBucketStartSec = math.floor(GetGameTimeMilliseconds() / 1000)
    HPSMeterUI.shieldBucketTotal = 0
end

function HPSMeterUI:AdvanceShieldBuckets(nowSec)
    if HPSMeterUI.shieldBucketStartSec == 0 then
        HPSMeterUI.shieldBucketStartSec = nowSec
        return
    end

    local diff = nowSec - HPSMeterUI.shieldBucketStartSec
    if diff <= 0 then return end

    for _ = 1, math.min(diff, HPSMeterUI.saved.shieldWindow) do
        local dropped = table.remove(HPSMeterUI.shieldBuckets, 1)
        HPSMeterUI.shieldBucketTotal = HPSMeterUI.shieldBucketTotal - (dropped or 0)
        table.insert(HPSMeterUI.shieldBuckets, 0)
    end

    HPSMeterUI.shieldBucketStartSec = nowSec
end
function HPSMeterUI:OnShieldMitigated(result, targetName, hitValue)
    if result ~= ACTION_RESULT_DAMAGE_SHIELDED then return end

    local tName = zo_strformat("<<C:1>>", targetName)
    if not tName or tName == "" then return end

    if not HPSMeterUI:IsMyShieldActive(tName) then return end

    local amount = tonumber(hitValue) or 0
    if amount <= 0 then return end

    HPSMeterUI.overallMitigatedTotal = (HPSMeterUI.overallMitigatedTotal or 0) + amount
end

function HPSMeterUI:OnPostShieldDamage(result, targetName, hitValue)
    if result ~= ACTION_RESULT_DAMAGE then return end

    local tName = zo_strformat("<<C:1>>", targetName)
    if not tName or tName == "" then return end

    if not HPSMeterUI:IsMyShieldActive(tName) then return end

    local amount = tonumber(hitValue) or 0
    if amount <= 0 then return end

    HPSMeterUI.overallPostShieldDamageTotal = (HPSMeterUI.overallPostShieldDamageTotal or 0) + amount
end



function HPSMeterUI:GetShieldSPS()
    HPSMeterUI:UpdateDisplay()
    return (HPSMeterUI.shieldBucketTotal or 0) / math.max(1, HPSMeterUI.saved.shieldWindow)
end



function HPSMeterUI:GetShielding(result, targetName)
    if result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION then return end
    local tName = zo_strformat("<<C:1>>", targetName)
    if not tName or tName == "" then return end
    local entry = HPSMeterUI.myShieldedTargets[tName]
    if not entry then
        entry = { last = 0, activeUntil = 0 }
        HPSMeterUI.myShieldedTargets[tName] = entry
    end
    -- Mark target as shielded for 20s (covers typical ward duration in PvP)
    entry.activeUntil = GetGameTimeMilliseconds() + 20000
end

function HPSMeterUI:GetLifetimeShieldPS()
    if HPSMeterUI.firstShieldTimeMs == 0 then return 0 end
    local elapsedSec = (GetGameTimeMilliseconds() - HPSMeterUI.firstShieldTimeMs) / 1000
    if elapsedSec <= 0 then return 0 end
    return (HPSMeterUI.overallShieldingTotal or 0) / elapsedSec
end

-- Stub: enemy HPS is tracked via OnPowerUpdate but display is not implemented
function HPSMeterUI:GetEnemyHPS() return 0 end

function HPSMeterUI:UpdateShieldVisuals(unitTag, newShieldValue)
    if not HPSMeterUI.saved.showShields then return end

    -- Try character name first (matches combat event targetName), then display name (@account)
    local charName = zo_strformat("<<C:1>>", GetUnitName(unitTag) or "")
    local dispName = zo_strformat("<<C:1>>", GetUnitDisplayName(unitTag) or "")
    local unitName
    if charName ~= "" and HPSMeterUI.myShieldedTargets[charName] then
        unitName = charName
    elseif dispName ~= "" and HPSMeterUI.myShieldedTargets[dispName] then
        unitName = dispName
    end
    if not unitName then return end

    local entry = HPSMeterUI.myShieldedTargets[unitName]
    local nowMs = GetGameTimeMilliseconds()
    local nowSec = math.floor(nowMs / 1000)
    local newValue = tonumber(newShieldValue) or 0
    local oldValue = tonumber(entry.last) or 0
    entry.last = newValue

    -- keep “active” window for mitigation tracking
    if newValue > 0 then
        entry.activeUntil = nowMs + 1500
    else
        entry.activeUntil = 0
    end

    local delta = newValue - oldValue
    if delta < 0 then
        -- cleanup when shield is gone
        if newValue <= 0 then
            HPSMeterUI.myShieldedTargets[unitName] = nil
        end
        return
    end

    -- init buckets first time
    if HPSMeterUI.shieldBucketStartSec == 0 then
        HPSMeterUI:InitShieldBuckets()
        HPSMeterUI.shieldBucketStartSec = nowSec
    end

    HPSMeterUI:AdvanceShieldBuckets(nowSec)

    -- add delta to rolling window
    local idx = #HPSMeterUI.shieldBuckets
    HPSMeterUI.shieldBuckets[idx] = (HPSMeterUI.shieldBuckets[idx] or 0) + delta
    HPSMeterUI.shieldBucketTotal = (HPSMeterUI.shieldBucketTotal or 0) + delta

    -- ✅ overall MUST add delta (not value)
    HPSMeterUI.overallShieldingTotal = (HPSMeterUI.overallShieldingTotal or 0) + delta

    -- Split personal (self) vs group (others we shielded)
    if unitTag == "player" then
        HPSMeterUI.personalShieldTotal = (HPSMeterUI.personalShieldTotal or 0) + delta
    else
        HPSMeterUI.groupShieldTotal = (HPSMeterUI.groupShieldTotal or 0) + delta
    end

    -- start lifetime timer correctly (ms!)
    if HPSMeterUI.firstShieldTimeMs == 0 then
        HPSMeterUI.firstShieldTimeMs = nowMs
    end

    HPSMeterUI.lastShieldTime = nowMs
    HPSMeterUI:UpdateDisplay()
end



local healResults = {
    [ACTION_RESULT_HEAL] = true,
    [ACTION_RESULT_CRITICAL_HEAL] = true,
    [ACTION_RESULT_HOT_TICK] = true,
    [ACTION_RESULT_HOT_TICK_CRITICAL] = true,
}
function GetHealing(eventCode, result, isError, _, _, _, _, _, targetName, _, hitValue, _, _, _, _, _, _)
    if isError then return end
    if not healResults[result] then return end
    if not HPSMeterUI.saved.showLabel then return end

    local timeMs = GetGameTimeMilliseconds()
    local nowSec = math.floor(timeMs / 1000)
    if HPSMeterUI.bucketStartSec == 0 then
        HPSMeterUI:InitBuckets()
        HPSMeterUI.bucketStartSec = nowSec
    end

    HPSMeterUI:AdvanceBuckets(nowSec)

    local amount = hitValue or 0
    HPSMeterUI.buckets[#HPSMeterUI.buckets] = HPSMeterUI.buckets[#HPSMeterUI.buckets] + amount
    HPSMeterUI.bucketTotal = HPSMeterUI.bucketTotal + amount
    HPSMeterUI.lastHealTime = timeMs
    HPSMeterUI.overallHealingTotal = HPSMeterUI.overallHealingTotal + amount

    -- Split personal (self-heals) vs group (heals applied to others)
    local cleanTarget = zo_strformat("<<C:1>>", targetName or "")
    local myName = zo_strformat("<<C:1>>", GetUnitName("player") or "")
    if cleanTarget == myName then
        HPSMeterUI.personalHealTotal = (HPSMeterUI.personalHealTotal or 0) + amount
    else
        HPSMeterUI.groupHealTotal = (HPSMeterUI.groupHealTotal or 0) + amount
    end

    HPSMeterUI:UpdateDisplay()
end
function HPSMeterUI:CreateLAM()
    -- Re-fetch at call time so we always get the fully-initialised library object,
    -- not the potentially-stale value captured when the file was first parsed.
    LAM = LibAddonMenu2
    if not LAM or not LAM.RegisterAddonPanel then return end
    LAM:RegisterAddonPanel("HPSMeterPanel", {
        type="panel", name="Bloom HPS", displayName="Bloom HPS", author="Vixen Hunny", version="1.0",
    })

    local optionsTable = {
        {
        type = "button",
        name = "Reset Bloom HPS Data",
        tooltip = "Clears Bloom HPS Data (Shield, HPS)",
        func = function() HPSMeterUI:Reset() end,
        width = "full",
        warning = "This will permanently clear current Bloom HPS data",
    },
    {
        type = "button",
        name = "Reset Bloom HPS BG Stats",
        tooltip = "Clears Bloom HPS BG stats (top healing, shielding, mitigation)",
        func = function() HPSMeterUI:ResetSavedBGStats() end,
        width = "full",
        warning = "This will permanently clear current Bloom HPS BG stats",
    },
    {
        type = "button",
        name = "Bloom HPS Help Data",
        tooltip = "Outputs Bloom HPS data to chat for the list of slash commands",
        func = function() HPSMeterUI:GetHelp() end,
        width = "full"
    },
        {
            type = "header",
            name = "Healing per second"
        },
        {
            type = "checkbox",
            name = "Show Healing Label",
            getFunc = function() return HPSMeterUI.saved.showLabel end,
            setFunc = function(v)
                HPSMeterUI.saved.showLabel = v
                if HPSMeterUI.labelControl then
                    HPSMeterUI.labelControl:SetHidden(not v)
                end
                if HPSMeterUI.labelShadowControl then
                    HPSMeterUI.labelShadowControl:SetHidden(not v)
                end
                if HPSMeterUI.healerIcon then
                    HPSMeterUI.healerIcon:SetHidden(not v)
                end
                local showOverall = v and HPSMeterUI.saved.showOverall
                if HPSMeterUI.labelOverallControl then
                    HPSMeterUI.labelOverallControl:SetHidden(not showOverall)
                end
                if HPSMeterUI.labelOverallShadowControl then
                    HPSMeterUI.labelOverallShadowControl:SetHidden(not showOverall)
                end
                if HPSMeterUI.healerIconOverall then
                    HPSMeterUI.healerIconOverall:SetHidden(not showOverall)
                end
                HPSMeterUI:RefreshWardenThemeLayout()
            end,
        },
        {
            type = "slider",
            name = "Healing Label X",
            min = 0,
            max = 2000,
            step = 1,
            getFunc = function() return HPSMeterUI.saved.labelX end,
            setFunc = function(v)
                HPSMeterUI.saved.labelX = v
                if HPSMeterUI.labelControl then
                    local control = WINDOW_MANAGER:GetControlByName("HPSMeterControl")
                    HPSMeterUI.labelControl:ClearAnchors()
                    HPSMeterUI.labelControl:SetAnchor(TOPLEFT, control, TOPLEFT, v, HPSMeterUI.saved.labelY)
                end
                HPSMeterUI:RefreshWardenThemeLayout()
            end,
        },
        {
            type = "slider",
            name = "Healing Label Y",
            min = 0,
            max = 2000,
            step = 1,
            getFunc = function() return HPSMeterUI.saved.labelY end,
            setFunc = function(v)
                HPSMeterUI.saved.labelY = v
                if HPSMeterUI.labelControl then
                    local control = WINDOW_MANAGER:GetControlByName("HPSMeterControl")
                    HPSMeterUI.labelControl:ClearAnchors()
                    HPSMeterUI.labelControl:SetAnchor(TOPLEFT, control, TOPLEFT, HPSMeterUI.saved.labelX, v)
                end
                HPSMeterUI:RefreshWardenThemeLayout()
            end,
        },
        {
            type = "slider",
            name = "Healing Label Scale",
            min = 0.01,
            max = 10.0,
            step = 0.01,
            getFunc = function() return HPSMeterUI.saved.scale end,
            setFunc = function(v)
                HPSMeterUI.saved.scale = v
                if HPSMeterUI.labelControl then
                    HPSMeterUI.labelControl:SetScale(v)
                    HPSMeterUI.labelControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * v))))
                    if HPSMeterUI.labelShadowControl then
                        HPSMeterUI.labelShadowControl:SetScale(v)
                        HPSMeterUI.labelShadowControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * v))))
                    end
                    if HPSMeterUI.healerIcon then
                        HPSMeterUI.healerIcon:SetScale(v)
                    end
                    if HPSMeterUI.labelOverallControl then
                        HPSMeterUI.labelOverallControl:SetScale(v)
                        HPSMeterUI.labelOverallControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * v))))
                    end
                    if HPSMeterUI.labelOverallShadowControl then
                        HPSMeterUI.labelOverallShadowControl:SetScale(v)
                        HPSMeterUI.labelOverallShadowControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * v))))
                    end
                    if HPSMeterUI.healerIconOverall then
                        HPSMeterUI.healerIconOverall:SetScale(v)
                    end
                    HPSMeterUI:GetHPS()
                end
                HPSMeterUI:RefreshWardenThemeLayout()
            end,
        },
        {
            type = "editbox",
            name = "Healing Color",
            tooltip = "Healing per second Color",
            default = "9ff8ba",
            getFunc = function() return HPSMeterUI.saved.labelColor end,
            setFunc = function(v)
                HPSMeterUI.saved.labelColor = v
                HPSMeterUI:GetHPS()
            end,
        },
        {
            type = "header",
            name = "Shielding per second"
        },
        {
            type = "checkbox",
            name = "Show Shield per second",
            getFunc = function() return HPSMeterUI.saved.showShields end,
            setFunc = function(v) HPSMeterUI.saved.showShields = v
            if HPSMeterUI.shieldControl then
                HPSMeterUI.shieldControl:SetHidden(not v)
            end
            if HPSMeterUI.shieldShadowControl then
                HPSMeterUI.shieldShadowControl:SetHidden(not v)
            end
            if HPSMeterUI.flowerIcon then
                HPSMeterUI.flowerIcon:SetHidden(not v)
            end
            HPSMeterUI:RefreshWardenThemeLayout()
        end,
    },
            {
                type = "slider",
                name = "Shield per second label X", min=0, max=2000, step=1, getFunc=function() return HPSMeterUI.saved.shieldLabelx end,
                setFunc = function(v) HPSMeterUI.saved.shieldLabelx = v
                if HPSMeterUI.shieldControl then
                    local control = WINDOW_MANAGER:GetControlByName("HPSMeterControl")
                    HPSMeterUI.shieldControl:ClearAnchors()
                    HPSMeterUI.shieldControl:SetAnchor(TOPLEFT, control, TOPLEFT, HPSMeterUI.saved.shieldLabelx, HPSMeterUI.saved.shieldLabely)

                end
                HPSMeterUI:RefreshWardenThemeLayout()
            end
            },
            {
                type = "slider",
                name = "Shield per second label Y", min=0, max=2000, step=1, getFunc=function() return HPSMeterUI.saved.shieldLabely end,
                setFunc = function(v) HPSMeterUI.saved.shieldLabely = v
                if HPSMeterUI.shieldControl then
                    local control = WINDOW_MANAGER:GetControlByName("HPSMeterControl")
                    HPSMeterUI.shieldControl:ClearAnchors()
                    HPSMeterUI.shieldControl:SetAnchor(TOPLEFT, control, TOPLEFT, HPSMeterUI.saved.shieldLabelx, HPSMeterUI.saved.shieldLabely)

                end
                HPSMeterUI:RefreshWardenThemeLayout()
            end
            },
            {
                type = "slider",
                name = "Shield per second label scale", min=0.01, max=10.0, step=0.01, getFunc=function() return HPSMeterUI.saved.shieldScale end,
                setFunc = function(v) HPSMeterUI.saved.shieldScale = v
                if HPSMeterUI.shieldControl then
                    HPSMeterUI.shieldControl:SetScale(v)
                    HPSMeterUI.shieldControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * v))))
                    if HPSMeterUI.shieldShadowControl then
                        HPSMeterUI.shieldShadowControl:SetScale(v)
                        HPSMeterUI.shieldShadowControl:SetFont(string.format("$(MEDIUM_FONT)|%d|outline", math.max(14, math.floor(22 * v))))
                    end
                    if HPSMeterUI.flowerIcon then
                        HPSMeterUI.flowerIcon:SetScale(v)
                    end
                    HPSMeterUI:GetShieldSPS()
                end
                HPSMeterUI:RefreshWardenThemeLayout()
            end
            },
            {
                type = "editbox",
                name = "Shielding Color",
                tooltip = "Shielding per second Color",
                default = "b8f7ff",
                getFunc = function() return HPSMeterUI.saved.shieldColor end,
                setFunc = function(v)
                    HPSMeterUI.saved.shieldColor = v
                    HPSMeterUI:GetShieldSPS()
                end,
            },
            {
                type = "header",
                name = "Overall"
            },
            {
            type = "checkbox",
            name = "Show Overall",
            getFunc = function() return HPSMeterUI.saved.showOverall end,
            setFunc = function(v) HPSMeterUI.saved.showOverall = v
                HPSMeterUI:GetHPS()
                HPSMeterUI:GetShieldSPS()
                HPSMeterUI:RefreshWardenThemeLayout()
        end,
        },
        {
            type="editbox", name="Overall Color", tooltip="Overall Healing/Shielding/Mitigated Color",default="d6ffd6",getFunc=function() return HPSMeterUI.saved.overallColor end, setFunc=function(v) HPSMeterUI.saved.overallColor = v HPSMeterUI:GetHPS() HPSMeterUI:GetShieldSPS() end 
        },
        {
            type = "header",
            name = "Reset Timer"
        },
        {
            type = "slider",
            name = "Idle Reset Timer (seconds)",
            tooltip = "Seconds of no healing activity before Bloom HPS auto-resets. Default: 300 (5 min)",
            min = 1,
            max = 900,
            step = 1,
            default = 300,
            getFunc = function() return HPSMeterUI.saved.resetTimer or 300 end,
            setFunc = function(v)
                HPSMeterUI.saved.resetTimer = v
            end,
        }
    }

    -- Enemy colors

    LAM:RegisterOptionControls("HPSMeterPanel", optionsTable)
end
local function OnPowerUpdate(eventCode, tag, powerIndex, powerType, powerValue, powerMax, powerEMax)
    local name = GetUnitDisplayName(tag)
    if IsUnitAttackable(tag) then
        if name == nil then
            return
        end
        HPSMeterUI.enemyHP[name] = powerValue
    else
        if name == nil then
            return
        end
        HPSMeterUI.alliedHP[name] = powerValue
    end
    if IsUnitAttackable(tag) then
        local unitName = GetUnitDisplayName(tag)
        if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
            if powerMax > HPSMeterUI.enemyHP[unitName] then
                HPSMeterUI.enemyHP[unitName] = powerValue
                HPSMeterUI.lastHealTime = GetGameTimeMilliseconds()
                HPSMeterUI.lastEnemyHealTick = powerMax - powerValue
                        if not HPSMeterUI.saved.showLabel then return end
                        HPSMeterUI:GetEnemyHPS()
                end 
        end
    else
        if IsUnitSoloOrGroupLeader(tag) then
            local unitName = GetUnitDisplayName(tag)
            if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
                if powerMax > HPSMeterUI.alliedHP[unitName] then
            
                    HPSMeterUI.alliedHP[unitName] = powerValue
                    HPSMeterUI.lastHealTime = GetGameTimeMilliseconds()
                    HPSMeterUI.lastAlliedHealTick = powerMax - powerValue
                    HPSMeterUI:GetHPS()
                end
            end
        elseif IsUnitGrouped(tag) then
            local unitName = GetUnitDisplayName(tag)
            if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
                if powerMax > HPSMeterUI.alliedHP[unitName] then
            
                    HPSMeterUI.alliedHP[unitName] = powerValue
                    HPSMeterUI.lastHealTime = GetGameTimeMilliseconds()
                    HPSMeterUI.lastAlliedHealTick = powerMax - powerValue
                    HPSMeterUI:GetHPS()
                end
            end
        end
    end
end


-- ======================
-- Event: AddOn Loaded
-- ======================
function HPSMeterUI:PrintHelp()
    d("Bloom HPS: /bloomhpslink - Link healing data to chat (PC ONLY)")
    d("Bloom HPS: /bloomhpsstats - Show saved battleground stats")
    d("Bloom HPS: /bloomhpsbg - Show saved battleground stats")
    d("Bloom HPS: /bloomhpsmax - Show max healing stats")
    d("Bloom HPS: /bloomhpsbest - Show best healing stats")
    d("Bloom HPS: /bloomhpsresetstats - Reset saved battleground stats")
    d("Bloom HPS: /bloomhpsclear - Clear all saved stats")
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= "HPSMeter" then return end
    HPSMeterUI.saved = ZO_SavedVars:NewAccountWide("HPSMeterSavedVars", 2, nil, HPSMeterUI.defaults)
    if not HPSMeterUI.saved.themeVersion or HPSMeterUI.saved.themeVersion < 1 then
        if not HPSMeterUI.saved.labelColor or HPSMeterUI.saved.labelColor == "ffff00" then
            HPSMeterUI.saved.labelColor = "9ff8ba"
        end
        if not HPSMeterUI.saved.shieldColor or HPSMeterUI.saved.shieldColor == "ffff00" then
            HPSMeterUI.saved.shieldColor = "b8f7ff"
        end
        if not HPSMeterUI.saved.overallColor or HPSMeterUI.saved.overallColor == "ffff00" then
            HPSMeterUI.saved.overallColor = "d6ffd6"
        end
        HPSMeterUI.saved.themeVersion = 1
    end
    for i=1,HPSMeterUI.saved.window do HPSMeterUI.buckets[i] = 0 end
    d("Loaded")
    SLASH_COMMANDS["/bloomhpslink"] = function()
        HPSMeterUI:LinkHealingData()
    end
    SLASH_COMMANDS["/bloomhpsstats"] = function()
        HPSMeterUI:PrintSavedBGStats()
    end
    SLASH_COMMANDS["/bloomhpsbg"] = function()
        HPSMeterUI:PrintSavedBGStats()
    end
    SLASH_COMMANDS["/bloomhpsmax"] = function()
        HPSMeterUI:PrintSavedBGStats()
    end
    SLASH_COMMANDS["/bloomhpsbest"] = function()
        HPSMeterUI:PrintSavedBGStats()
    end
    SLASH_COMMANDS["/bloomhpsresetstats"] = function()
        HPSMeterUI:ResetSavedBGStats()
    end
    SLASH_COMMANDS["/bloomhpsclear"] = function()
        HPSMeterUI:ResetSavedBGStats()
    end
    EVENT_MANAGER:UnregisterForEvent("HPSMeter", EVENT_ADD_ON_LOADED)
    -- Safe LibAddonMenu2
    
    -- Lazy UI
    local ok, err = pcall(function() HPSMeterUI:CreateUI() end)
    if not ok then d("[BloomHPS] CreateUI error: " .. tostring(err)) end
    -- In your Initialization function:
EVENT_MANAGER:RegisterForEvent("HPSMeter_PostShieldDamage", EVENT_COMBAT_EVENT, function(...)
    local _, result, isError, _, _, _, _, _, targetName, _, hitValue = ...
    if isError then return end
    HPSMeterUI:OnPostShieldDamage(result, targetName, hitValue)
end)

EVENT_MANAGER:AddFilterForEvent("HPSMeter_PostShieldDamage", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE, ACTION_RESULT_CRITICAL_DAMAGE, ACTION_RESULT_BLOCKED_DAMAGE
)

        -- 1. Register Combat Event to detect when YOU apply a shield (creates entry for mitigation tracking)
        EVENT_MANAGER:RegisterForEvent("HPSMeter_ShieldCombat", EVENT_COMBAT_EVENT, function(_, result, _, _, _, _, _, _, targetName, _, _, _, _, _, _, _, _)
            HPSMeterUI:GetShielding(result, targetName)
        end)
        -- Filter so it only fires when the PLAYER is the source
        EVENT_MANAGER:AddFilterForEvent("HPSMeter_ShieldCombat", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

        -- 2. Visual attribute events for actual shield values (ADDED and UPDATED share one handler)
        local function OnVisualAddedOrUpdated(_, unitTag, visualType, _, _, _, oldOrValue, newOrMax, oldMaxOrNil, _)
            if visualType ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
            -- ADDED: oldMaxOrNil==nil → value=oldOrValue; UPDATED: oldMaxOrNil set → value=newOrMax
            local value = oldMaxOrNil == nil and oldOrValue or newOrMax
            HPSMeterUI:UpdateShieldVisuals(unitTag, value)
        end
        local function OnVisualRemoved(_, unitTag, visualType, _, _, _, _, _)
            if visualType ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
            HPSMeterUI:UpdateShieldVisuals(unitTag, 0)
        end
        EVENT_MANAGER:RegisterForEvent("HPSMeter_ShieldVisualAdd", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnVisualAddedOrUpdated)
        EVENT_MANAGER:RegisterForEvent("HPSMeter_ShieldVisualUpd", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnVisualAddedOrUpdated)
        EVENT_MANAGER:RegisterForEvent("HPSMeter_ShieldVisualRem", EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnVisualRemoved)
        EVENT_MANAGER:RegisterForEvent("HPSMeter_ShieldMitigated", EVENT_COMBAT_EVENT,
    function(_, result, _, _, _, _, _, _, targetName, _, hitValue, _, _, _, _, _, _, _)
        HPSMeterUI:OnShieldMitigated(result, targetName, hitValue)
    end
)

-- Filter so we ONLY receive shield-absorbed hits (reduces spam a lot)
EVENT_MANAGER:AddFilterForEvent("HPSMeter_ShieldMitigated", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE_SHIELDED
)


    local ok2, err2 = pcall(function() HPSMeterUI:CreateLAM() end)
    if not ok2 then d("[BloomHPS] CreateLAM error: " .. tostring(err2)) end
    -- Register combat event for healing (player source, heal result only)
    EVENT_MANAGER:RegisterForEvent("HPSMeter_Heal", EVENT_COMBAT_EVENT, GetHealing)
    EVENT_MANAGER:AddFilterForEvent("HPSMeter_Heal", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    -- ======================
    -- Auto-reset timer
    -- ======================
    EVENT_MANAGER:RegisterForUpdate("HPSMeter_SPS_Tick", 1000, function()
    local nowSec = math.floor(GetGameTimeMilliseconds() / 1000)
    if HPSMeterUI.bucketStartSec ~= 0 then
        HPSMeterUI:AdvanceBuckets(nowSec)
    end
    if HPSMeterUI.shieldBucketStartSec ~= 0 then
        HPSMeterUI:AdvanceShieldBuckets(nowSec)
    end
    if HPSMeterUI.saved.showLabel then
        HPSMeterUI:UpdateDisplay()
    end
end)

    EVENT_MANAGER:RegisterForUpdate("HPSMeterIdleReset", 1000, function()
        if HPSMeterUI.lastHealTime == 0 then return end
        if GetGameTimeMilliseconds() - HPSMeterUI.lastHealTime > (HPSMeterUI.saved.resetTimer or 300) * 1000 then
            HPSMeterUI:Reset()
            HPSMeterUI.lastHealTime = 0
            HPSMeterUI.firstHealTime = 0
            HPSMeterUI.alliedHP = 0
            HPSMeterUI.bucketTotal = 0
            HPSMeterUI.lastAlliedHealTick = 0
        end
    end)
    EVENT_MANAGER:RegisterForEvent("HPSMeter_Dataset", EVENT_BATTLEGROUND_STATE_CHANGED, function(ec, prevState, newState) 
        if newState == BATTLEGROUND_STATE_FINISHED or newState == BATTLEGROUND_STATE_POSTGAME then
            HPSMeterUI:SavePreviousBGStats()
            HPSMeterUI.lastHealTime = 0
            HPSMeterUI.firstHealTime = 0
            HPSMeterUI.alliedHP = 0
            HPSMeterUI.bucketTotal = 0
            HPSMeterUI.lastAlliedHealTick = 0
            HPSMeterUI:Reset()
        end
    end)
    -- ======================
    -- Label Update
    -- ======================
    -- ======================
    -- Graph Update (placeholder)
    -- ======================
end

EVENT_MANAGER:RegisterForEvent("HPSMeter", EVENT_ADD_ON_LOADED, OnAddOnLoaded)