-- MundusCheck.lua
-- Aim at any player (ally or enemy) to see a small HUD readout of their distinct
-- mundus boons, max health, Champion Points, and permanent buffs. More than two
-- mundus stones is not achievable legitimately, so such targets are flagged.
--
-- Another player's buff list streams in eventually-consistently: a single read on
-- target acquisition often catches a partial list. Distinct mundus stones are
-- therefore union-accumulated per target across an initial scan, several delayed
-- re-scans, and live effect deltas, and reset when the target changes.
-- (Technique borrowed from Green Bar Intel.)

local ADDON_NAME = "MundusCheck"

local MUNDUS_LEGIT_MAX = 2
-- Re-scan the held target a few times so late-streamed buffs are caught.
local REPOLL_DELAYS_MS = { 150, 400, 800, 1300, 2000 }

-- Classic hardcoded mundus ability-id band, kept only as a fallback classifier
-- for the rare case where GetAbilityMundusStoneType is unavailable.
local MUNDUS_ABILITY_ID_MIN = 13940
local MUNDUS_ABILITY_ID_MAX = 13985
local MUNDUS_INVALID = MUNDUS_STONE_INVALID or 0
local DEBUFF_EFFECT_TYPE = BUFF_EFFECT_TYPE_DEBUFF or 2

local MAX_LISTED_PERMANENT_BUFFS = 10
local LABEL_WIDTH = 850
-- Inset from the top-right screen corner; keeps clear of the target unit frame
-- (top-center) and the compass.
local SCREEN_INSET_X = -40
local SCREEN_INSET_Y = 40

local COLOR_HEADER = "C5C29E"
local COLOR_OK = "6BCB77"
local COLOR_PENDING = "9DA3A4"
local COLOR_WARNING = "F52D2D"
local COLOR_BUFFS = "8FB8DE"

-- Distinct-mundus accumulator for the currently held target.
local tracker = {
    targetKey = nil, ---@type string|nil
    observed = {},   ---@type table<string, boolean>
    names = {},      ---@type string[]
}

local ui = nil ---@type {root: TopLevelWindow, label: LabelControl}|nil

---@param color string hex RRGGBB
---@param text string
---@return string
local function Colorize(color, text)
    return string.format("|c%s%s|r", color, text)
end

---@param abilityId number|nil
---@return string|nil # stable distinct-stone key, or nil when not a mundus
local function ClassifyMundusKey(abilityId)
    local id = tonumber(abilityId) or 0
    if id <= 0 then
        return nil
    end

    if GetAbilityMundusStoneType then
        local mundusType = GetAbilityMundusStoneType(id)
        if mundusType and mundusType ~= MUNDUS_INVALID then
            -- Key by stone type so the same boon under multiple ability ids counts once.
            return "t" .. tostring(mundusType)
        end
    end

    if id >= MUNDUS_ABILITY_ID_MIN and id <= MUNDUS_ABILITY_ID_MAX then
        return "a" .. tostring(id)
    end

    return nil
end

---@param unitTag string
---@return string|nil
local function GetUnitIdentityKey(unitTag)
    if not DoesUnitExist(unitTag) then
        return nil
    end

    local rawName = GetRawUnitName(unitTag) or ""
    local displayName = GetUnitDisplayName(unitTag) or ""
    if rawName == "" and displayName == "" then
        return nil
    end

    return rawName .. "|" .. displayName
end

---@param identityKey string|nil
---@return boolean changed
local function SetTrackedTarget(identityKey)
    if tracker.targetKey == identityKey then
        return false
    end

    tracker.targetKey = identityKey
    tracker.observed = {}
    tracker.names = {}
    return true
end

--- Union-accumulate one ability into the current target's distinct mundus set.
---@param abilityId number|nil
---@return boolean added
local function NoteMundusAbility(abilityId)
    local key = ClassifyMundusKey(abilityId)
    if not key or tracker.observed[key] then
        return false
    end

    tracker.observed[key] = true
    local name = zo_strformat("<<1>>", GetAbilityName(abilityId) or "")
    tracker.names[#tracker.names + 1] = name ~= "" and name or ("#" .. tostring(abilityId))
    return true
end

--- Full snapshot read of the unit's effect list; union-merges any mundus found.
--- Excludes debuffs only (mundus frequently reports effectType NOT_AN_EFFECT, so
--- a "must be a buff" filter would silently drop it).
---@param unitTag string
---@return boolean changed
local function ScanUnitForMundus(unitTag)
    if not DoesUnitExist(unitTag) then
        return false
    end

    local changed = false
    local numBuffs = GetNumBuffs(unitTag) or 0
    for index = 1, numBuffs do
        local _name, _timeStarted, _timeEnding, _buffSlot, _stackCount, _icon, _deprecatedBuffType,
        effectType, _abilityType, _statusEffectType, abilityId = GetUnitBuffInfo(unitTag, index)
        if effectType ~= DEBUFF_EFFECT_TYPE and NoteMundusAbility(abilityId) then
            changed = true
        end
    end

    return changed
end

--- Names of the target's current permanent (timeStarted == timeEnding), non-debuff,
--- non-mundus effects. This is where 5-piece set bonuses, vampire/werewolf passives,
--- and suspicious always-on stat buffs show up.
---@param unitTag string
---@return string[]
local function ListPermanentBuffNames(unitTag)
    local names = {}
    if not DoesUnitExist(unitTag) then
        return names
    end

    local numBuffs = GetNumBuffs(unitTag) or 0
    for index = 1, numBuffs do
        local name, timeStarted, timeEnding, _buffSlot, _stackCount, _icon, _deprecatedBuffType,
        effectType, _abilityType, _statusEffectType, abilityId = GetUnitBuffInfo(unitTag, index)
        local isPermanent = (tonumber(timeStarted) or 0) == (tonumber(timeEnding) or 0)
        if isPermanent and effectType ~= DEBUFF_EFFECT_TYPE and ClassifyMundusKey(abilityId) == nil then
            local formatted = zo_strformat("<<1>>", name or "")
            if formatted ~= "" then
                names[#names + 1] = formatted
            end
        end
    end

    return names
end

---@param value number
---@return string
local function FormatThousands(value)
    if value >= 1000 then
        return string.format("%.1fk", value / 1000)
    end
    return tostring(value)
end

local function EnsureUi()
    if ui then
        return ui
    end

    local root = WINDOW_MANAGER:CreateTopLevelWindow("MundusCheck_Root")
    root:SetMouseEnabled(false)
    root:SetClampedToScreen(true)
    root:SetDimensions(LABEL_WIDTH, 220)
    root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, SCREEN_INSET_X, SCREEN_INSET_Y)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl("MundusCheck_Label", root, CT_LABEL)
    label:SetFont("ZoFontGamepad27")
    label:SetAnchor(TOPRIGHT, root, TOPRIGHT, 0, 0, nil)
    label:SetWidth(LABEL_WIDTH)
    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetColor(1, 1, 1, 1)

    -- Fade with the HUD so the readout disappears in menus and cutscenes.
    local fragment = ZO_HUDFadeSceneFragment:New(root)
    for _, sceneName in ipairs({ "hud", "hudui" }) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:AddFragment(fragment)
        end
    end

    ui = { root = root, label = label }
    return ui
end

---@return boolean # whether the reticle target is a live player we can inspect
local function HasInspectablePlayerTarget()
    return DoesUnitExist("reticleover")
        and IsUnitPlayer("reticleover")
        and not IsUnitDead("reticleover")
end

local function BuildDisplayText()
    local unitTag = "reticleover"

    local name = zo_strformat("<<1>>", GetUnitName(unitTag) or "")
    local displayName = GetUnitDisplayName(unitTag) or ""
    if displayName ~= "" and displayName ~= name then
        name = name ~= "" and (name .. " " .. displayName) or displayName
    end

    local headerParts = { name }
    local className = zo_strformat("<<1>>", GetUnitClass(unitTag) or "")
    if className ~= "" then
        headerParts[#headerParts + 1] = className
    end
    local cp = tonumber(GetUnitChampionPoints(unitTag)) or 0
    if cp > 0 then
        headerParts[#headerParts + 1] = "CP " .. tostring(cp)
    end
    local _current, maxHealth, effectiveMax = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
    local health = math.max(tonumber(maxHealth) or 0, tonumber(effectiveMax) or 0)
    if health > 0 then
        headerParts[#headerParts + 1] = FormatThousands(health) .. " HP"
    end

    local lines = { Colorize(COLOR_HEADER, table.concat(headerParts, "  |  ")) }

    local mundusCount = #tracker.names
    if mundusCount == 0 then
        lines[#lines + 1] = Colorize(COLOR_PENDING, "Mundus: none seen yet (buffs may still be loading)")
    else
        local color = mundusCount > MUNDUS_LEGIT_MAX and COLOR_WARNING or COLOR_OK
        local line = string.format("Mundus (%d): %s", mundusCount, table.concat(tracker.names, ", "))
        if mundusCount > MUNDUS_LEGIT_MAX then
            line = line .. "  -- MORE THAN " .. tostring(MUNDUS_LEGIT_MAX) .. ", NOT LEGIT"
        end
        lines[#lines + 1] = Colorize(color, line)
    end

    local permanentNames = ListPermanentBuffNames(unitTag)
    if #permanentNames > 0 then
        local shown = {}
        for index = 1, math.min(#permanentNames, MAX_LISTED_PERMANENT_BUFFS) do
            shown[#shown + 1] = permanentNames[index]
        end
        local suffix = #permanentNames > MAX_LISTED_PERMANENT_BUFFS
            and string.format(" (+%d more)", #permanentNames - MAX_LISTED_PERMANENT_BUFFS) or ""
        lines[#lines + 1] = Colorize(COLOR_BUFFS,
            string.format("Permanent buffs (%d): %s%s", #permanentNames, table.concat(shown, ", "), suffix))
    end

    return table.concat(lines, "\n")
end

local function RefreshDisplay()
    local currentUi = EnsureUi()
    if not HasInspectablePlayerTarget() then
        currentUi.root:SetHidden(true)
        return
    end

    currentUi.label:SetText(BuildDisplayText())
    currentUi.root:SetHidden(false)
end

--- Schedule a few delayed re-scans of the held target so late-streamed buffs are
--- caught. Each callback aborts if the tracked target changed in the meantime.
---@param identityKey string
local function ScheduleRepolls(identityKey)
    for _, delayMs in ipairs(REPOLL_DELAYS_MS) do
        zo_callLater(function()
            if tracker.targetKey ~= identityKey then
                return
            end
            if GetUnitIdentityKey("reticleover") ~= identityKey then
                return
            end
            ScanUnitForMundus("reticleover")
            RefreshDisplay()
        end, delayMs)
    end
end

local function OnReticleTargetChanged()
    if not HasInspectablePlayerTarget() then
        SetTrackedTarget(nil)
        RefreshDisplay()
        return
    end

    local identityKey = GetUnitIdentityKey("reticleover")
    if not identityKey then
        SetTrackedTarget(nil)
        RefreshDisplay()
        return
    end

    local isNewTarget = SetTrackedTarget(identityKey)
    ScanUnitForMundus("reticleover")
    if isNewTarget then
        ScheduleRepolls(identityKey)
    end
    RefreshDisplay()
end

--- Live effect delta. Registered globally and software-filtered to the reticle
--- target (per the proven Srendarr technique); a unit-tag event filter is
--- unreliable here.
---@param changeType number|nil
---@param unitTag string|nil
---@param effectType number|nil
---@param abilityId number|nil
local function OnEffectChanged(changeType, unitTag, effectType, abilityId)
    if unitTag ~= "reticleover" or tracker.targetKey == nil then
        return
    end
    if changeType == EFFECT_RESULT_FADED then
        return
    end
    if effectType == DEBUFF_EFFECT_TYPE then
        return
    end
    if GetUnitIdentityKey("reticleover") ~= tracker.targetKey then
        return
    end

    if NoteMundusAbility(abilityId) then
        RefreshDisplay()
    end
end

local function OnAddOnLoaded(_eventId, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    EnsureUi()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RETICLE_TARGET_PLAYER_CHANGED, OnReticleTargetChanged)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_UNIT_DEATH_STATE_CHANGED, function(_deathEventId, unitTag)
        if unitTag == "reticleover" then
            OnReticleTargetChanged()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME,
        EVENT_EFFECT_CHANGED,
        function(_effectEventId, changeType, _effectSlot, _effectName, unitTag, _beginTime, _endTime, _stackCount,
                 _iconName, _deprecatedBuffType, effectType, _abilityType, _statusEffectType, _unitName, _unitId,
                 abilityId)
            OnEffectChanged(changeType, unitTag, effectType, abilityId)
        end
    )

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        OnReticleTargetChanged()
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
