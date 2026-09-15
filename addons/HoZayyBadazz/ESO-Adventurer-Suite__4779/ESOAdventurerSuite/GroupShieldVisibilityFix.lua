-- ESO Adventurer Suite
-- v0.29.637 - organized Unit Frame shield + mount-stamina visualization.
-- Group/Raid shields keep their existing thin health-bar strip. The Player frame
-- uses the same visual language: SHIELD xx% inside Health and MOUNT xx% inside
-- Stamina. Strip width follows the live rendered bar in every current design.
-- Everything is event-driven; no polling/OnUpdate loop is added.

local EPC = ESOProgressionCoach
if not EPC or not EPC.UnitFrames then return end
local F = EPC.UnitFrames
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

local WHITE_TEXTURE = "EsoUI/Art/Miscellaneous/white_1x1.dds"
local SHIELD_COLOR = { 0.52, 0.72, 1.00, 0.92 }
local SHIELD_TEXT = { 0.78, 0.88, 1.00, 1.00 }
local MOUNT_COLOR = { 0.96, 0.72, 0.24, 0.94 }
local MOUNT_TEXT = { 1.00, 0.86, 0.48, 1.00 }

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d
end

local function healthVisualizerPowerType()
    return rawget(_G, "COMBAT_MECHANIC_FLAGS_HEALTH") or rawget(_G, "POWERTYPE_HEALTH")
end

local function getShield(unitTag)
    if type(GetUnitAttributeVisualizerEffectInfo) ~= "function" then return 0 end
    local shieldVisual = rawget(_G, "ATTRIBUTE_VISUAL_POWER_SHIELDING")
    local mitigation = rawget(_G, "STAT_MITIGATION")
    local healthAttribute = rawget(_G, "ATTRIBUTE_HEALTH")
    local healthPower = healthVisualizerPowerType()
    if shieldVisual == nil or mitigation == nil or healthAttribute == nil or healthPower == nil then
        return 0
    end
    local value = safe(GetUnitAttributeVisualizerEffectInfo, 0,
        unitTag, shieldVisual, mitigation, healthAttribute, healthPower)
    return math.max(0, tonumber(value) or 0)
end

local function getMaxHealth(unitTag)
    local healthPower = rawget(_G, "POWERTYPE_HEALTH")
    if healthPower == nil then return 0 end
    local _, maximum = safe(GetUnitPower, 0, unitTag, healthPower)
    return math.max(0, tonumber(maximum) or 0)
end

local function formatShield(value)
    value = math.max(0, tonumber(value) or 0)
    if value >= 1000000 then
        local text = string.format("%.1fm", value / 1000000)
        return text:gsub("%.0m$", "m")
    elseif value >= 1000 then
        local text = string.format("%.1fk", value / 1000)
        return text:gsub("%.0k$", "k")
    end
    return tostring(math.floor(value + 0.5))
end

local function percent(value, maximum)
    value, maximum = tonumber(value) or 0, tonumber(maximum) or 0
    if maximum <= 0 then return 0 end
    return math.max(0, math.floor((value / maximum) * 100 + 0.5))
end

local function setHiddenIfChanged(control, hidden)
    if not control or type(control.IsHidden) ~= "function" or type(control.SetHidden) ~= "function" then return end
    local ok, current = pcall(control.IsHidden, control)
    if not ok or current ~= hidden then pcall(control.SetHidden, control, hidden) end
end

local function currentBarWidth(bar)
    if not bar then return 1 end
    -- Designs reshape the same bar after construction, so the live control width
    -- is authoritative. epcWidth is only a fallback for controls not yet laid out.
    local liveWidth = tonumber(safe(bar.GetWidth, nil, bar))
    if liveWidth and liveWidth > 2 then return math.max(1, liveWidth - 2) end
    local width = tonumber(bar.epcWidth)
    if width and width > 0 then return width end
    return 1
end

local function setStripWidth(bar, strip, ratio, cacheKey)
    if not bar or not strip then return end
    ratio = math.max(0, math.min(1, tonumber(ratio) or 0))
    local visibleWidth = math.max(2, currentBarWidth(bar) * ratio)
    if bar[cacheKey] == nil or math.abs((tonumber(bar[cacheKey]) or 0) - visibleWidth) > 0.5 then
        bar[cacheKey] = visibleWidth
        strip:SetWidth(visibleWidth)
    end
end

-- Existing Group/Raid shield presentation ------------------------------------
local function ensureShieldUI(bar)
    if not bar then return nil, nil end

    local overlay = bar.epcShieldOverlay029519
    if not overlay then
        overlay = WM:CreateControl(nil, bar, CT_TEXTURE)
        overlay:SetTexture(WHITE_TEXTURE)
        overlay:SetColor(unpack(SHIELD_COLOR))
        overlay:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 1, -1)
        overlay:SetHeight(3)
        if overlay.SetDrawLayer and DL_OVERLAY then overlay:SetDrawLayer(DL_OVERLAY) end
        if overlay.SetDrawLevel then overlay:SetDrawLevel(42) end
        overlay:SetHidden(true)
        bar.epcShieldOverlay029519 = overlay
    else
        if type(overlay.ClearAnchors) == "function" then overlay:ClearAnchors() end
        if type(overlay.SetAnchor) == "function" then overlay:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 1, -1) end
        if type(overlay.SetHeight) == "function" then overlay:SetHeight(3) end
        if type(overlay.SetColor) == "function" then overlay:SetColor(unpack(SHIELD_COLOR)) end
        if type(overlay.SetCenterColor) == "function" then overlay:SetCenterColor(0.52, 0.72, 1.00, 0.74) end
        if type(overlay.SetEdgeColor) == "function" then overlay:SetEdgeColor(0, 0, 0, 0) end
    end

    local valueLabel = bar.epcShieldValue029574
    if not valueLabel then
        valueLabel = WM:CreateControl(nil, bar, CT_LABEL)
        valueLabel:SetFont("ZoFontGameSmall")
        valueLabel:SetColor(unpack(SHIELD_TEXT))
        valueLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        valueLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        valueLabel:SetAnchor(TOPRIGHT, bar, TOPRIGHT, -3, 0)
        valueLabel:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -3, 0)
        valueLabel:SetWidth(42)
        if valueLabel.SetDrawLayer and DL_OVERLAY then valueLabel:SetDrawLayer(DL_OVERLAY) end
        if valueLabel.SetDrawLevel then valueLabel:SetDrawLevel(62) end
        valueLabel:SetHidden(true)
        bar.epcShieldValue029574 = valueLabel
    end

    return overlay, valueLabel
end

local function updateRow(row)
    if not row or row:IsHidden() or not row.epcUnitTag or not row.epcBars then return end
    local bar = row.epcBars.health
    if not bar then return end

    local overlay, valueLabel = ensureShieldUI(bar)
    if not overlay or not valueLabel then return end

    local shield = getShield(row.epcUnitTag)
    local maxHealth = getMaxHealth(row.epcUnitTag)
    if shield <= 0 or maxHealth <= 0 then
        setHiddenIfChanged(overlay, true)
        setHiddenIfChanged(valueLabel, true)
        bar._easShieldText029574 = nil
        bar._easShieldWidth029574 = nil
        return
    end

    setStripWidth(bar, overlay, shield / maxHealth, "_easShieldWidth029574")
    setHiddenIfChanged(overlay, false)

    local text = formatShield(shield)
    if bar._easShieldText029574 ~= text then
        bar._easShieldText029574 = text
        valueLabel:SetText(text)
    end
    setHiddenIfChanged(valueLabel, false)
    if bar.epcLabel and bar.epcLabel.SetDrawLevel then bar.epcLabel:SetDrawLevel(70) end
end

function F:RefreshRosterShields029519()
    local function updateFrame(frame)
        if not frame or frame:IsHidden() then return end
        for _, row in ipairs(frame.epcRows or {}) do updateRow(row) end
    end
    updateFrame(self.groupFrame)
    updateFrame(self.raidFrame)
end

-- Player Health shield --------------------------------------------------------
local function ensurePlayerShieldUI(bar)
    if not bar then return nil, nil end
    local overlay = bar.epcPlayerShieldStrip029636
    if not overlay then
        overlay = WM:CreateControl(nil, bar, CT_TEXTURE)
        overlay:SetTexture(WHITE_TEXTURE)
        overlay:SetColor(unpack(SHIELD_COLOR))
        overlay:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 1, -1)
        overlay:SetHeight(4)
        overlay:SetMouseEnabled(false)
        if overlay.SetDrawLayer and DL_OVERLAY then overlay:SetDrawLayer(DL_OVERLAY) end
        if overlay.SetDrawLevel then overlay:SetDrawLevel(52) end
        overlay:SetHidden(true)
        bar.epcPlayerShieldStrip029636 = overlay
    end

    local label = bar.epcPlayerShieldLabel029636
    if not label then
        label = WM:CreateControl(nil, bar, CT_LABEL)
        label:SetFont("$(BOLD_FONT)|12|soft-shadow-thick")
        label:SetColor(unpack(SHIELD_TEXT))
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetAnchor(TOPRIGHT, bar, TOPRIGHT, -8, 0)
        label:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -8, 0)
        label:SetWidth(92)
        label:SetMouseEnabled(false)
        if label.SetDrawLayer and DL_OVERLAY then label:SetDrawLayer(DL_OVERLAY) end
        if label.SetDrawLevel then label:SetDrawLevel(82) end
        label:SetHidden(true)
        bar.epcPlayerShieldLabel029636 = label
    end
    return overlay, label
end

function F:RefreshPlayerShield029636()
    local frame = self.playerFrame
    local bar = frame and frame.epcBars and frame.epcBars.health
    if not bar then return end
    local overlay, label = ensurePlayerShieldUI(bar)
    if not overlay or not label then return end

    local shield = getShield("player")
    local maxHealth = getMaxHealth("player")
    if shield <= 0 or maxHealth <= 0 then
        setHiddenIfChanged(overlay, true)
        setHiddenIfChanged(label, true)
        bar._easPlayerShieldWidth029636 = nil
        bar._easPlayerShieldText029636 = nil
        return
    end

    local shieldPercent = percent(shield, maxHealth)
    setStripWidth(bar, overlay, shield / maxHealth, "_easPlayerShieldWidth029636")
    setHiddenIfChanged(overlay, false)

    local text = "SHIELD " .. tostring(shieldPercent) .. "%"
    if bar._easPlayerShieldText029636 ~= text then
        bar._easPlayerShieldText029636 = text
        label:SetText(text)
    end
    setHiddenIfChanged(label, false)
    if bar.epcLabel and bar.epcLabel.SetDrawLevel then bar.epcLabel:SetDrawLevel(90) end
end

-- Player Mount Stamina --------------------------------------------------------
local function ensureMountUI(bar)
    if not bar then return nil, nil end
    local overlay = bar.epcMountStaminaStrip029636
    if not overlay then
        overlay = WM:CreateControl(nil, bar, CT_TEXTURE)
        overlay:SetTexture(WHITE_TEXTURE)
        overlay:SetColor(unpack(MOUNT_COLOR))
        overlay:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, 1, -1)
        overlay:SetHeight(4)
        overlay:SetMouseEnabled(false)
        if overlay.SetDrawLayer and DL_OVERLAY then overlay:SetDrawLayer(DL_OVERLAY) end
        if overlay.SetDrawLevel then overlay:SetDrawLevel(52) end
        overlay:SetHidden(true)
        bar.epcMountStaminaStrip029636 = overlay
    end

    local label = bar.epcMountStaminaLabel029636
    if not label then
        label = WM:CreateControl(nil, bar, CT_LABEL)
        label:SetFont("$(BOLD_FONT)|12|soft-shadow-thick")
        label:SetColor(unpack(MOUNT_TEXT))
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetAnchor(TOPRIGHT, bar, TOPRIGHT, -8, 0)
        label:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -8, 0)
        label:SetWidth(92)
        label:SetMouseEnabled(false)
        if label.SetDrawLayer and DL_OVERLAY then label:SetDrawLayer(DL_OVERLAY) end
        if label.SetDrawLevel then label:SetDrawLevel(82) end
        label:SetHidden(true)
        bar.epcMountStaminaLabel029636 = label
    end
    return overlay, label
end

local function isMounted()
    if type(IsMounted) ~= "function" then return false end
    return safe(IsMounted, false) == true
end

function F:RefreshMountStamina029636(currentOverride, maxOverride)
    local frame = self.playerFrame
    local bar = frame and frame.epcBars and frame.epcBars.stamina
    if not bar then return end
    local overlay, label = ensureMountUI(bar)
    if not overlay or not label then return end

    if not isMounted() or rawget(_G, "POWERTYPE_MOUNT_STAMINA") == nil then
        setHiddenIfChanged(overlay, true)
        setHiddenIfChanged(label, true)
        bar._easMountWidth029636 = nil
        bar._easMountText029636 = nil
        return
    end

    local current, maximum = tonumber(currentOverride), tonumber(maxOverride)
    if current == nil or maximum == nil then
        current, maximum = safe(GetUnitPower, 0, "player", POWERTYPE_MOUNT_STAMINA)
        current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    end
    if maximum <= 0 then
        setHiddenIfChanged(overlay, true)
        setHiddenIfChanged(label, true)
        return
    end

    local mountPercent = percent(current, maximum)
    setStripWidth(bar, overlay, current / maximum, "_easMountWidth029636")
    setHiddenIfChanged(overlay, false)

    local text = "MOUNT " .. tostring(mountPercent) .. "%"
    if bar._easMountText029636 ~= text then
        bar._easMountText029636 = text
        label:SetText(text)
    end
    setHiddenIfChanged(label, false)
    if bar.epcLabel and bar.epcLabel.SetDrawLevel then bar.epcLabel:SetDrawLevel(90) end
end

function F:RefreshPlayerStatusIndicators029636()
    self:RefreshPlayerShield029636()
    self:RefreshMountStamina029636()
end

local baseRefresh = F.RefreshGroupFrames
if type(baseRefresh) == "function" and not F._easShieldRefreshWrapped029519 then
    F._easShieldRefreshWrapped029519 = true
    function F:RefreshGroupFrames(...)
        local result = baseRefresh(self, ...)
        self:RefreshRosterShields029519()
        return result
    end
end

local baseInitialize = F.Initialize
if type(baseInitialize) == "function" and not F._easPlayerStatusInitWrapped029636 then
    F._easPlayerStatusInitWrapped029636 = true
    function F:Initialize(...)
        local result = baseInitialize(self, ...)
        self:RefreshPlayerStatusIndicators029636()

        if type(ZO_PostHookHandler) == "function" and self.playerFrame and self.playerFrame.epcBars then
            local health = self.playerFrame.epcBars.health
            local stamina = self.playerFrame.epcBars.stamina
            if health and not health._easPlayerStatusRectHook029636 then
                health._easPlayerStatusRectHook029636 = true
                ZO_PostHookHandler(health, "OnRectChanged", function()
                    if F and F.RefreshPlayerShield029636 then F:RefreshPlayerShield029636() end
                end)
            end
            if stamina and not stamina._easPlayerStatusRectHook029636 then
                stamina._easPlayerStatusRectHook029636 = true
                ZO_PostHookHandler(stamina, "OnRectChanged", function()
                    if F and F.RefreshMountStamina029636 then F:RefreshMountStamina029636() end
                end)
            end
        end
        return result
    end
end

-- Event-driven refresh --------------------------------------------------------
local rosterPending = false
local function requestRosterRefresh()
    if rosterPending then return end
    rosterPending = true
    local function finish()
        rosterPending = false
        if F and F.RefreshRosterShields029519 then F:RefreshRosterShields029519() end
    end
    if type(zo_callLater) == "function" then zo_callLater(finish, 45) else finish() end
end

local playerShieldPending = false
local function requestPlayerShieldRefresh()
    if playerShieldPending then return end
    playerShieldPending = true
    local function finish()
        playerShieldPending = false
        if F and F.RefreshPlayerShield029636 then F:RefreshPlayerShield029636() end
    end
    if type(zo_callLater) == "function" then zo_callLater(finish, 20) else finish() end
end

local function onShieldVisual(_, unitTag, unitAttributeVisual, statType, attributeType)
    if unitAttributeVisual ~= rawget(_G, "ATTRIBUTE_VISUAL_POWER_SHIELDING") then return end
    if rawget(_G, "ATTRIBUTE_HEALTH") ~= nil and attributeType ~= ATTRIBUTE_HEALTH then return end
    unitTag = tostring(unitTag or "")
    if unitTag == "player" then
        requestPlayerShieldRefresh()
    elseif string.sub(unitTag, 1, 5) == "group" then
        requestRosterRefresh()
    end
end

if EM then
    local prefix = (EPC.name or "ESOAdventurerSuite") .. "_UnitFrameStatus029636"
    for index, eventId in ipairs({
        rawget(_G, "EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED"),
        rawget(_G, "EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED"),
        rawget(_G, "EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED"),
    }) do
        if eventId then EM:RegisterForEvent(prefix .. "_Shield_" .. tostring(index), eventId, onShieldVisual) end
    end

    if rawget(_G, "EVENT_POWER_UPDATE") and rawget(_G, "POWERTYPE_MOUNT_STAMINA") ~= nil then
        local mountPowerName = prefix .. "_MountPower"
        EM:RegisterForEvent(mountPowerName, EVENT_POWER_UPDATE,
            function(_, unitTag, powerIndex, powerType, powerValue, powerMax)
                if unitTag == "player" and powerType == POWERTYPE_MOUNT_STAMINA
                    and F and F.RefreshMountStamina029636 then
                    F:RefreshMountStamina029636(powerValue, powerMax)
                end
            end)
        if rawget(_G, "REGISTER_FILTER_UNIT_TAG") ~= nil then
            pcall(EM.AddFilterForEvent, EM, mountPowerName, EVENT_POWER_UPDATE,
                REGISTER_FILTER_UNIT_TAG, "player")
        end
        if rawget(_G, "REGISTER_FILTER_POWER_TYPE") ~= nil then
            pcall(EM.AddFilterForEvent, EM, mountPowerName, EVENT_POWER_UPDATE,
                REGISTER_FILTER_POWER_TYPE, POWERTYPE_MOUNT_STAMINA)
        end
    end

    local mountedEvent = rawget(_G, "EVENT_MOUNTED_STATE_CHANGED")
    if mountedEvent then
        EM:RegisterForEvent(prefix .. "_Mounted", mountedEvent, function()
            if F and F.RefreshMountStamina029636 then F:RefreshMountStamina029636() end
        end)
    end

    if rawget(_G, "EVENT_PLAYER_ACTIVATED") then
        EM:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
            requestPlayerShieldRefresh()
            requestRosterRefresh()
            if F and F.RefreshMountStamina029636 then F:RefreshMountStamina029636() end
        end)
    end
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easplayerstatus"] = function()
    local shield = getShield("player")
    local maxHealth = getMaxHealth("player")
    local mountCurrent, mountMax = 0, 0
    if rawget(_G, "POWERTYPE_MOUNT_STAMINA") ~= nil and type(GetUnitPower) == "function" then
        mountCurrent, mountMax = safe(GetUnitPower, 0, "player", POWERTYPE_MOUNT_STAMINA)
    end
    local text = string.format("EAS Player Status | Shield %d%% (%s) | Mounted=%s | Mount %d%%",
        percent(shield, maxHealth), formatShield(shield), isMounted() and "yes" or "no",
        percent(mountCurrent, mountMax))
    if type(d) == "function" then d(text) end
end

if F.playerFrame then
    F:RefreshPlayerStatusIndicators029636()
elseif type(zo_callLater) == "function" then
    zo_callLater(function()
        if F and F.playerFrame and F.RefreshPlayerStatusIndicators029636 then
            F:RefreshPlayerStatusIndicators029636()
        end
    end, 800)
end
