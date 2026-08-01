--Helloworld
Yokeda = {}
Yokeda.name = "Yokeda"

-- =========================
-- CONFIG
-- =========================

local MAX_HP_THRESHOLD = 37000
local MAX_TRACKED = 8
local PRUNE_TIME = 10000        -- ms
local UPDATE_INTERVAL = 1000     -- ms
local debugsettotrue = false
local SetMessage = "2"
local NewMessage = "1"
-- >>> REPLACE THIS WITH REAL DEBUFF ID <<<
local VANGUARD_ID = 92916

-- =========================
-- DATA
-- =========================

Yokeda.enemies = {}
Yokeda.label = nil

-- =========================
-- INITIALIZATION
-- =========================

function Yokeda:Initialize()

    -- UI label
    self.label = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_LABEL)
    self.label:SetFont("ZoFontWinH1")
    self.label:SetColor(1, 0, 0, 1)
    self.label:SetAnchor(CENTER, GuiRoot, CENTER, 0, -200)
    self.label:SetHidden(false)

    -- Register events
    --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT,function(...) self:OnCombatEvent(...) end)

    EVENT_MANAGER:AddFilterForEvent(self.name,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, function(...) self:OnEffectChanged(...) end)

    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Update",
        UPDATE_INTERVAL,
        function() self:Update() end)
end

-- =========================
-- COMBAT TRACKING
-- =========================

function Yokeda:OnCombatEvent(eventCode, result, isError,
    abilityName, abilityGraphic, abilityActionSlotType,
    sourceName, sourceType,
    targetName, targetType,
    hitValue, powerType, damageType,
    log, sourceUnitId, targetUnitId, abilityId)

    if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if targetUnitId == 0 then return end

    local now = GetFrameTimeMilliseconds()

    if not self.enemies[targetUnitId] then

        -- Limit to 8 tracked enemies
        local count = 0
        for _ in pairs(self.enemies) do count = count + 1 end
        if count >= MAX_TRACKED then return end
        d(string.format("%s", targetName))
        self.enemies[targetUnitId] = {
            name = targetName or "Unknown",
            maxHealth = 0,
            hasVanguard = false,
            lastSeen = now,
        }
    end

    self.enemies[targetUnitId].lastSeen = now
end

-- =========================
-- EFFECT TRACKING
-- =========================

function Yokeda:OnEffectChanged(eventCode, changeType, effectSlot,
    effectName, unitTag, beginTime, endTime, stackCount,
    iconName, buffType, effectType, abilityType,
    statusEffectType, unitName, unitId, abilityId)
    if debugsettotrue == true
    then
        SetMessage = string.format("[%s]", abilityId).. " : " .. iconName.. " : " .. unitId 
        if SetMessage ~= NewMessage then
            NewMessage = SetMessage
            d(NewMessage)
        end
        --d(string.format("[%s]", abilityId).. " : " .. iconName.. " : " .. unitId )
    end

    if abilityId ~= VANGUARD_ID then return end
    if not self.enemies[unitId] then return end

    if changeType == EFFECT_RESULT_GAINED then
        self.enemies[unitId].hasVanguard = true
    elseif changeType == EFFECT_RESULT_FADED then
        self.enemies[unitId].hasVanguard = false
    end
end

-- =========================
-- TARGET SELECTION
-- =========================

function Yokeda:GetPriorityTarget()

    for unitId, data in pairs(self.enemies) do

        if data.maxHealth > 0
           and data.maxHealth < MAX_HP_THRESHOLD
           and not data.hasVanguard then

            return data
        end
    end

    return nil
end

-- =========================
-- UPDATE LOOP
-- =========================

function Yokeda:Update()

    local now = GetFrameTimeMilliseconds()

    -- Update reticle target HP if valid
    if DoesUnitExist("reticleover") and IsUnitPlayer("reticleover") then
        local unitId = GetUnitUniqueId("reticleover")
        if self.enemies[unitId] then
            local current, max = GetUnitPower("reticleover", POWERTYPE_HEALTH)
            self.enemies[unitId].maxHealth = max
        end
    end

    -- Prune stale enemies
    for unitId, data in pairs(self.enemies) do
        if now - data.lastSeen > PRUNE_TIME then
            self.enemies[unitId] = nil
        end
    end

    -- Select target
    local target = self:GetPriorityTarget()

    if target then
        self.label:SetText("CHALLENGE: " .. target.name)
        self.label:SetHidden(false)
    --else
        --self.label:SetHidden(true)
    end
end

-- =========================
-- ADDON LOAD
-- =========================

local function OnAddOnLoaded(event, addonName)
    if addonName ~= Yokeda.name then return end

    EVENT_MANAGER:UnregisterForEvent(Yokeda.name, EVENT_ADD_ON_LOADED)
    Yokeda:Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    Yokeda.name,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)
