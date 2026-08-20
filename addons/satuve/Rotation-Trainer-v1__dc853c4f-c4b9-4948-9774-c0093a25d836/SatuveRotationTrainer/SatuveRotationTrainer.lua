SatuveRotationTrainer = SatuveRotationTrainer or {}
local SRT = SatuveRotationTrainer

SRT.name = "SatuveRotationTrainer"
SRT.version = "0.6.37"
SRT.maxPriorities = 10
SRT.routeLength = 2

local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER
local HOTBAR_PRIMARY = HOTBAR_CATEGORY_PRIMARY
local HOTBAR_BACKUP = HOTBAR_CATEGORY_BACKUP

local FONT_TITLE  = "$(BOLD_FONT)|32|soft-shadow-thick"
local FONT_HEADER = "$(BOLD_FONT)|25|soft-shadow-thick"
local FONT_TEXT   = "$(MEDIUM_FONT)|23|soft-shadow-thick"
local FONT_BUTTON = "$(BOLD_FONT)|21|soft-shadow-thick"
local FONT_SMALL  = "$(MEDIUM_FONT)|19|soft-shadow-thick"
local FONT_FLOW_KEY = "$(BOLD_FONT)|32|soft-shadow-thick"
local FONT_FLOW_SWAP = "$(BOLD_FONT)|20|soft-shadow-thick"

-- v0.6.21: feste maschinenlesbare RGB-Codes fuer AHK PixelSearch.
-- Die Schrift bleibt hell/pastellig, die Farben sind aber weit genug auseinander.
local AHK_ACTION_COLORS = {
    ["1"]    = {255/255, 184/255, 184/255}, -- #FFB8B8
    ["2"]    = {184/255, 255/255, 184/255}, -- #B8FFB8
    ["3"]    = {184/255, 212/255, 255/255}, -- #B8D4FF
    ["4"]    = {255/255, 240/255, 168/255}, -- #FFF0A8
    ["5"]    = {228/255, 184/255, 255/255}, -- #E4B8FF
    ["SWAP"] = {168/255, 255/255, 255/255}, -- #A8FFFF
    ["ULT"]  = {255/255, 208/255, 160/255}, -- #FFD0A0
}
local FLOW_ITEM_GAP_PX = 8      -- minimum visual gap so Skill / SWAP / Skill never overlap
local MISSED_MIN_SPEED = 0.035  -- almost-stop speed after an unpressed action passes PRESS

local defaults = {
    enabled = true,
    x = 420,
    y = 300,
    scale = 1.0,
    gcdMs = 1000,
    pressLeadMs = 950,
    skillDetectLeadMs = 250,  -- extra visual recognition window before PRESS
    skillDetectTrailMs = 200, -- keep pressed skill visible before fade-out begins
    pressVisualHoldEnabled = true, -- freeze CURRENT exactly on PRESS briefly for screen recognition
    pressVisualHoldMs = 200,       -- fixed visual hold duration; toggleable in menu
    ahkColorMarkersEnabled = false, -- legacy; recognition now uses the separate white image box
    ahkDataCodeEnabled = false, -- legacy data-code disabled in v0.6.25
    fixedFlowSpeed = false,    -- false = existing easing/slowdown, true = constant movement speed
    swapLeadMs = 250,         -- BAR SWAP: spacing before SWAP, expressed as travel-time at normal skill speed
    swapTrailMs = 200,        -- BAR SWAP: spacing after SWAP, expressed as travel-time at normal skill speed
    iconSize = 58,
    hitZoneX = 120,
    executeHp = 25,
    rotationMode = "dynamic", -- dynamic planner or fixed static priority sequence
    spammable = nil,
    execute = nil,
    ultimate = nil,
    priorities = {},
    -- legacy field kept only for one-time migration from v0.3.x
    skills = {},
    rhythmSamples = {},        -- last 20 real skill-to-skill intervals
    practiceMs = 0,            -- accumulated valid training time for long-term coaching
    adaptiveRhythmMs = 1000,   -- current coached rhythm
    rhythmCalibrated = false,   -- becomes true after first 20 cadence samples
    hitSamples = {},            -- last 20 recommendation/timing results (1=hit, 0=miss)
    hitsSinceAdjust = 0,        -- adjust coaching only once per 20 evaluated presses
    observedDurations = {},     -- learned full ESO effect durations per configured skill
}

-- Helix-inspired rotation-time overrides. These represent a useful recast interval,
-- not necessarily the exact tooltip duration.
local DURATION_OVERRIDES_MS = {
    [40382] = 16000, -- Barbed Trap
    [77182] = 10000, -- Volatile Familiar
    [103706] = 34700, -- Channeled Acceleration
    [117749] = 3000, -- Stalking Blastbones
    [40465] = 12000, -- Scalding Rune
}

-- Generic, data-driven proc rules.  The engine itself is class agnostic: adding a
-- new proc only requires another rule instead of special-casing the planner.
-- effectId = ESO buff/effect that means the proc is ready.
local PROC_RULES = {
    [46327]  = {baseId=46324, procId=114716, minStacks=1}, -- Crystal Fragments
    [61920]  = {baseId=61919, procId=61930,  minStacks=4}, -- Merciless Resolve
    [122658] = {baseId=20805, procId=20805,   minStacks=3}, -- Seething Fury / Molten Whip
}

local PROC_BASE_BY_PROC = {}
for _, rule in pairs(PROC_RULES) do
    if rule.procId and rule.baseId then PROC_BASE_BY_PROC[rule.procId] = rule.baseId end
end

local PROC_RULE_BY_BASE = {}
for effectId, rule in pairs(PROC_RULES) do
    if rule.baseId then
        PROC_RULE_BY_BASE[rule.baseId] = rule
        rule.effectId = effectId
    end
end

local function msg(t)
    local text = "|c66ccff[SRT]|r " .. tostring(t)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(text)
    elseif d then
        d(text)
    end
end

local function now()
    return GetGameTimeMilliseconds()
end

local function currentBar()
    return GetActiveHotbarCategory and GetActiveHotbarCategory() or HOTBAR_PRIMARY
end

local ULTIMATE_SLOT = 8 -- ESO action-bar ultimate slot; keep distinct from normal slots 3-7
local ULTIMATE_LOCKOUT_MS = 10000 -- hard 10 second lock after any ultimate cast

-- Controller-native pseudo action. Heavy Attack is not a normal action-bar ability,
-- so the trainer represents it as its own rotation item.
local HEAVY_ATTACK_ID = -900001
local HEAVY_ATTACK_CHANNEL_MS = 2200
local HEAVY_ATTACK_ICON = "SatuveRotationTrainer/Textures/HeavyAttack.dds"

local function isHeavyAttackSkill(skill)
    return skill and (skill.isHeavyAttack == true or tonumber(skill.abilityId) == HEAVY_ATTACK_ID)
end

local function validRotationSkill(skill)
    return skill and (isHeavyAttackSkill(skill) or (tonumber(skill.abilityId) or 0) > 0)
end

local function isGamepadInputMode()
    return IsInGamepadPreferredMode and IsInGamepadPreferredMode() == true
end

local function slotInputLabel(slot)
    local numericSlot = tonumber(slot)
    if not numericSlot then return "?" end
    if numericSlot == ULTIMATE_SLOT then return "ULT" end

    -- Follow ESO's active preferred input mode live. In gamepad mode show
    -- controller buttons; in keyboard/mouse mode show the familiar 1-5 slots.
    if isGamepadInputMode() then
        local controllerLabels = {
            [3] = "X",
            [4] = "Y",
            [5] = "B",
            [6] = "LB",
            [7] = "RB",
        }
        return controllerLabels[numericSlot] or tostring(numericSlot)
    end

    if numericSlot >= 3 and numericSlot <= 7 then
        return tostring(numericSlot - 2)
    end
    return tostring(numericSlot)
end

local function heavyAttackInputLabel()
    return isGamepadInputMode() and "HOLD RT" or "HOLD LMB"
end
local function hotbarSlots()
    return {3, 4, 5, 6, 7}
end

local function barText(b)
    return b == HOTBAR_BACKUP and "BACK" or "FRONT"
end

local function getUltimatePoints()
    if not GetUnitPower or not POWERTYPE_ULTIMATE then return 0 end
    local ok, current = pcall(function()
        local value = GetUnitPower("player", POWERTYPE_ULTIMATE)
        return value
    end)
    return (ok and tonumber(current)) or 0
end

local function getUltimateCost(abilityId, hotbar)
    if not abilityId or abilityId == 0 then return 0 end

    -- ESO API variants have changed over time, so use the most specific
    -- available call first and keep guarded fallbacks for console clients.
    if type(GetAbilityCost) == "function" then
        local ok, cost = pcall(GetAbilityCost, abilityId)
        if ok and tonumber(cost) and tonumber(cost) > 0 then return tonumber(cost) end
    end
    if type(GetSlotAbilityCost) == "function" then
        local ok, cost = pcall(GetSlotAbilityCost, ULTIMATE_SLOT, hotbar or currentBar())
        if ok and tonumber(cost) and tonumber(cost) > 0 then return tonumber(cost) end
    end
    return 0
end

local function abilityName(id)
    if tonumber(id) == HEAVY_ATTACK_ID then return "Heavy Attack" end
    local n = GetAbilityName(id or 0)
    return (n and n ~= "") and n or ("Ability " .. tostring(id or 0))
end

local function abilityIcon(id)
    if tonumber(id) == HEAVY_ATTACK_ID then return HEAVY_ATTACK_ICON end
    local i = GetAbilityIcon(id or 0)
    return (i and i ~= "") and i or "/esoui/art/icons/icon_missing.dds"
end

local function label(parent, name, x, y, w, h, font, text)
    local c = WM:CreateControl(name, parent, CT_LABEL)
    c:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    c:SetDimensions(w, h)
    c:SetFont(font)
    c:SetText(text or "")
    c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return c
end

local function button(parent, name, x, y, w, h, text, cb)
    local b = WM:CreateControl(name, parent, CT_BUTTON)
    b:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    b:SetDimensions(w, h)
    b:SetFont(FONT_BUTTON)
    b:SetText(text)
    b:SetMouseEnabled(true)
    b:SetHandler("OnClicked", cb)
    return b
end

local function copySkill(s)
    if not validRotationSkill(s) then return nil end
    return {
        abilityId = s.abilityId,
        slotIndex = s.slotIndex,
        hotbar = s.hotbar,
        earlyMs = s.earlyMs,
        manualDurationMs = s.manualDurationMs,
        isHeavyAttack = s.isHeavyAttack == true,
        channelMs = s.channelMs,
    }
end

function SRT:MigrateLegacy()
    self.sv.priorities = self.sv.priorities or {}
    if #self.sv.priorities == 0 and self.sv.skills and #self.sv.skills > 0 then
        for i = 1, math.min(self.maxPriorities, #self.sv.skills) do
            local old = copySkill(self.sv.skills[i])
            if old then
                old.earlyMs = 0
                self.sv.priorities[i] = old
            end
        end
    end
end

-- Adaptive rhythm: short-term cadence comes from the last 20 real skill presses.
-- Coaching speed is adjusted only after 20 evaluated recommendations so the metronome
-- does not oscillate. >90% = gently faster, 80-90% = hold, <80% = slightly easier.
function SRT:GetRawRhythmAverage()
    local samples = self.sv.rhythmSamples or {}
    if #samples == 0 then return tonumber(self.sv.gcdMs) or 1000 end
    local total = 0
    for i = 1, #samples do total = total + (tonumber(samples[i]) or 1000) end
    return total / #samples
end

function SRT:GetHitRate()
    local samples = self.sv.hitSamples or {}
    if #samples == 0 then return 1, 0 end
    local hits = 0
    for i = 1, #samples do
        if tonumber(samples[i]) == 1 then hits = hits + 1 end
    end
    return hits / #samples, #samples
end

function SRT:GetAdaptiveRhythmMs()
    local target = tonumber(self.sv.adaptiveRhythmMs) or tonumber(self.sv.gcdMs) or 1000
    -- First calibrate to the player's actual 20-press cadence. After calibration the
    -- performance coach, not frame-by-frame math, moves the target.
    local rhythmSamples = self.sv.rhythmSamples or {}
    if not self.sv.rhythmCalibrated and #rhythmSamples >= 20 then
        target = math.max(1000, math.floor(self:GetRawRhythmAverage() + 0.5))
        self.sv.rhythmCalibrated = true
        self.sv.adaptiveRhythmMs = zo_clamp(target, 1000, 1400)
    end
    target = zo_clamp(tonumber(self.sv.adaptiveRhythmMs) or target, 1000, 1400)
    self.sv.adaptiveRhythmMs = math.floor(target + 0.5)
    return self.sv.adaptiveRhythmMs
end

function SRT:RecordPerformanceResult(hit)
    self.sv.hitSamples = self.sv.hitSamples or {}
    table.insert(self.sv.hitSamples, hit and 1 or 0)
    while #self.sv.hitSamples > 20 do table.remove(self.sv.hitSamples, 1) end
    self.sv.hitsSinceAdjust = (tonumber(self.sv.hitsSinceAdjust) or 0) + 1

    if #self.sv.hitSamples < 20 or self.sv.hitsSinceAdjust < 20 then return end
    self.sv.hitsSinceAdjust = 0

    local rate = self:GetHitRate()
    local target = self:GetAdaptiveRhythmMs()
    local raw = math.max(1000, math.floor(self:GetRawRhythmAverage() + 0.5))

    if rate > 0.90 then
        -- One millisecond per successful 20-action block: intentionally slow.
        -- From ~1200 ms this takes sustained practice over a long session to approach 1s.
        target = target - 1
    elseif rate < 0.80 then
        -- Give some room back when accuracy breaks down. Also never coach much faster
        -- than the player's current measured cadence while they are struggling.
        target = math.max(target + 5, math.min(1400, raw))
    end
    -- 80-90% intentionally holds the current target.
    self.sv.adaptiveRhythmMs = zo_clamp(math.floor(target + 0.5), 1000, 1400)
end

function SRT:RecordRhythmPress(t)
    if not t then return nil end
    local delta = nil
    if self.lastRhythmPressMs then
        delta = t - self.lastRhythmPressMs
        -- Ignore obvious pauses/double fires; only real rotation cadence samples.
        if delta >= 550 and delta <= 2200 then
            self.sv.rhythmSamples = self.sv.rhythmSamples or {}
            table.insert(self.sv.rhythmSamples, delta)
            while #self.sv.rhythmSamples > 20 do table.remove(self.sv.rhythmSamples, 1) end
            self.sv.practiceMs = (tonumber(self.sv.practiceMs) or 0) + delta
            self:GetAdaptiveRhythmMs()
        end
    end
    self.lastRhythmPressMs = t
    return delta
end

function SRT:ClearHeldRecommendation()
    self.heldRecommendation = nil
    self.heldReachedPress = false
    self.heldStartMs = nil
    self.currentHeldX = nil
    -- v0.6.16: BAR SWAP is planned once when a recommendation becomes current.
    -- Never create a new swap later just because the live bar/proc state changed.
    self.heldPlannedSwapBar = nil
    self.heldPlannedSwapDone = nil
end

function SRT:StartFadeRecommendation(item, atMs)
    if not item then return end
    self.fadingRecommendation = item
    self.fadeStartMs = atMs or now()
    self.fadeHoldMs = tonumber(self.sv.skillDetectTrailMs) or 200
    self.fadeDurationMs = 260
    -- Keep the recognized skill stable briefly after the real press, then fade it
    -- from its actual screen position. This gives screen-reading helpers a clean
    -- post-press window without changing the planner/GCD itself.
    self.fadeFromX = self.currentHeldX
end

function SRT:ClearFadeRecommendation()
    self.fadingRecommendation = nil
    self.fadeStartMs = nil
    self.fadeFromX = nil
    self.fadeHoldMs = nil
end

function SRT:ResetFlow()
    self.abilityTimers = {}
    self.esoEffectTimers = {}
    self.procReady = {}
    self.seethingFuryReady = false
    self.lastActionMs = now()
    self.lastRhythmPressMs = nil
    self.staticStepIndex = 1
    self:ClearHeldRecommendation()
    self:ClearFadeRecommendation()
end

function SRT:SyncActivePlayerEffects()
    -- Prebuffs may already be active before EVENT_PLAYER_COMBAT_STATE fires.
    -- Read ESO's current player-buff table so the route starts from the real state
    -- instead of assuming every configured buff is ready at the pull.
    local count = GetNumBuffs and (GetNumBuffs("player") or 0) or 0
    for i = 1, count do
        local buffName, beginTimeSec, endTimeSec, _, _, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo("player", i)
        if beginTimeSec and endTimeSec and endTimeSec > beginTimeSec then
            if castByPlayer == nil or castByPlayer == true then
                local sourceId = self:GetConfiguredSourceIdForEffect(abilityId, buffName)
                if sourceId then
                    self:SetEsoEffectTimer(sourceId, abilityId, beginTimeSec, endTimeSec, "player")
                end
            end
        end
    end
end

function SRT:SetCombatState(inCombat)
    local entering = (inCombat == true) and not self.inCombat
    self:ResetDynamicLockQueue()
    local leaving = (inCombat ~= true) and self.inCombat
    self.inCombat = inCombat == true

    if leaving then
        -- Leaving combat is the real hard reset. Effects applied afterwards as
        -- prebuffs will be captured again by EVENT_EFFECT_CHANGED.
        self:ResetFlow()
    elseif entering then
        -- Do NOT wipe ESO effect timers here: prebuffs cast before the pull are
        -- intentionally preserved. Refresh from the live ESO buff table as a
        -- safety net in case their apply event happened before addon tracking.
        self.lastActionMs = now()
        self.lastRhythmPressMs = nil
        self:ClearHeldRecommendation()
        self:ClearFadeRecommendation()
        self:SyncActivePlayerEffects()
        self:RefreshProcState()
        -- Freeze button numbers + selected bars at combat start. Proc state may change
        -- icons/recommendations, but never the visible key label or mapped bar.
        self:CaptureCombatDisplayMap()
        self.lastUltimatePoints = getUltimatePoints()
    end

    if self.main then
        self.main:SetHidden(not self.inCombat or not self.sv.enabled)
    end
end

function SRT:GetAllConfiguredSkills()
    local out = {}
    if self.sv.spammable then table.insert(out, self.sv.spammable) end
    if self.sv.execute then table.insert(out, self.sv.execute) end
    if self.sv.ultimate then table.insert(out, self.sv.ultimate) end
    for i = 1, self.maxPriorities do
        if self.sv.priorities[i] then table.insert(out, self.sv.priorities[i]) end
    end
    return out
end

-- v0.6.16: Freeze the visual key/bar mapping for the duration of combat.
-- Proc replacements are allowed to change the shown ability icon, but they must NEVER
-- change the number/key that a screen reader sees on top of that configured skill.
function SRT:CaptureCombatDisplayMap()
    self.combatDisplayMap = {}
    self:RefreshBarMap()

    for _, skill in ipairs(self:GetAllConfiguredSkills()) do
        if skill and skill.abilityId and skill.abilityId > 0 then
            local bar = skill.hotbar
            local slot = tonumber(skill.slotIndex)

            -- Repair missing saved placement once, BEFORE the combat display is frozen.
            if (not bar or not slot) then
                for _, hb in ipairs({HOTBAR_PRIMARY, HOTBAR_BACKUP}) do
                    local found = self.barSlots and self.barSlots[hb] and self.barSlots[hb][skill.abilityId]
                    if found then
                        bar, slot = hb, tonumber(found)
                        break
                    end
                end
            end

            if bar and slot then
                self.combatDisplayMap[skill.abilityId] = {
                    hotbar = bar,
                    slotIndex = slot,
                    inputLabel = slotInputLabel(slot),
                }
            end
        end
    end
end

function SRT:GetStableDisplayPlacement(item)
    if not item then return nil, nil end
    if item.type == "heavyAttack" or isHeavyAttackSkill(item.skill) or tonumber(item.abilityId) == HEAVY_ATTACK_ID then
        return currentBar(), nil
    end
    local sourceId = item.sourceAbilityId or item.abilityId
    local skill = item.skill

    -- A proc always inherits the configured base skill's frozen combat mapping.
    if self.combatDisplayMap then
        local entry = sourceId and self.combatDisplayMap[sourceId] or nil
        if not entry and skill and skill.abilityId then entry = self.combatDisplayMap[skill.abilityId] end
        if not entry and item.abilityId and PROC_BASE_BY_PROC[item.abilityId] then
            entry = self.combatDisplayMap[PROC_BASE_BY_PROC[item.abilityId]]
        end
        if entry then return entry.hotbar, entry.slotIndex end
    end

    -- Outside combat/test fallback: prefer the configured placement, not the temporary proc id.
    if skill and skill.hotbar and skill.slotIndex then
        return skill.hotbar, tonumber(skill.slotIndex)
    end
    return self:ResolveItemPlacement(item)
end

function SRT:GetStableDisplayLabel(item)
    if not item then return "?" end
    if item.type == "ultimate" then return "ULT" end
    if item.type == "heavyAttack" or isHeavyAttackSkill(item.skill) or tonumber(item.abilityId) == HEAVY_ATTACK_ID then return heavyAttackInputLabel() end
    local sourceId = item.sourceAbilityId or item.abilityId
    local skill = item.skill

    if self.combatDisplayMap then
        local entry = sourceId and self.combatDisplayMap[sourceId] or nil
        if not entry and skill and skill.abilityId then entry = self.combatDisplayMap[skill.abilityId] end
        if not entry and item.abilityId and PROC_BASE_BY_PROC[item.abilityId] then
            entry = self.combatDisplayMap[PROC_BASE_BY_PROC[item.abilityId]]
        end
        if entry and entry.slotIndex then
            -- Input labels must stay live so switching between keyboard/mouse
            -- and controller immediately changes 1-5 <-> X/Y/B/LB/RB.
            return slotInputLabel(entry.slotIndex)
        end
    end

    local _, slot = self:GetStableDisplayPlacement(item)
    return slotInputLabel(slot)
end

function SRT:IsConfiguredAbility(id)
    if not id then return false end
    for _, s in ipairs(self:GetAllConfiguredSkills()) do
        if s.abilityId == id then return true end
    end
    -- Known and runtime-discovered proc aliases resolve back to their configured base skill.
    local base = PROC_BASE_BY_PROC[id]
    if base then
        for _, sk in ipairs(self:GetAllConfiguredSkills()) do
            if sk.abilityId == base then return true end
        end
    end
    return false
end

-- Accept slightly early presses so a player is not punished for anticipating the beat.
-- Priority 1 stays tight; lower priorities are intentionally allowed a wider early window.
function SRT:GetConfiguredRoleForAbility(id)
    if not id then return nil end
    local sourceId = id
    sourceId = PROC_BASE_BY_PROC[id] or sourceId

    if self.sv.spammable and self.sv.spammable.abilityId == sourceId then
        return "spammable", nil, self.sv.spammable, sourceId
    end
    if self.sv.execute and self.sv.execute.abilityId == sourceId then
        return "execute", nil, self.sv.execute, sourceId
    end
    for i = 1, self.maxPriorities do
        local sk = self.sv.priorities[i]
        if sk and sk.abilityId == sourceId then
            return "priority", i, sk, sourceId
        end
    end
    return nil
end

-- Resolve an actual button press by its physical action slot and active hotbar.
-- This is more reliable than the transient ability id for morphs, ground AoEs and
-- proc-replaced slots, where ESO can report an id different from the configured skill.
function SRT:GetConfiguredRoleForSlot(slotIndex, hotbar)
    slotIndex = tonumber(slotIndex)
    if not slotIndex then return nil end
    hotbar = hotbar or currentBar()

    local function matches(skill)
        if not skill or not skill.abilityId then return false end
        if tonumber(skill.slotIndex) == slotIndex and skill.hotbar == hotbar then return true end
        -- Saved placement can become stale after a bar edit. Verify the live slot too.
        if skill.hotbar == hotbar and self.barSlots and self.barSlots[hotbar] then
            return tonumber(self.barSlots[hotbar][skill.abilityId]) == slotIndex
        end
        return false
    end

    if matches(self.sv.spammable) then
        return "spammable", nil, self.sv.spammable, self.sv.spammable.abilityId
    end
    if matches(self.sv.execute) then
        return "execute", nil, self.sv.execute, self.sv.execute.abilityId
    end
    if matches(self.sv.ultimate) then
        return "ultimate", nil, self.sv.ultimate, self.sv.ultimate.abilityId
    end
    for i = 1, self.maxPriorities do
        local sk = self.sv.priorities[i]
        if matches(sk) then return "priority", i, sk, sk.abilityId end
    end
    return nil
end

function SRT:RecommendationMatchesAbility(rec, id)
    if not rec or not id then return false end
    if id == rec.abilityId or id == rec.sourceAbilityId then return true end
    -- Proc recommendations may use a different ability id while the action slot still
    -- reports the configured base skill. Treat any known/runtime alias as the same press.
    local base = PROC_BASE_BY_PROC[rec.abilityId]
    if base and id == base then return true end
    return false
end

function SRT:GetEarlyAcceptWindowMs(id)
    local role, priority = self:GetConfiguredRoleForAbility(id)
    if role == "priority" then
        return (priority == 1) and 200 or 350
    elseif role == "spammable" or role == "execute" then
        return 300
    end
    return 0
end

function SRT:IsEarlyAcceptable(id, pressTime)
    local role, priority, skill, sourceId = self:GetConfiguredRoleForAbility(id)
    if not role then return false end
    local window = self:GetEarlyAcceptWindowMs(id)
    if window <= 0 then return false end

    if role == "priority" then
        local remaining = self:GetRemainingMs(sourceId)
        local configuredEarlyMs = zo_clamp(tonumber(skill.earlyMs) or 0, 0, 5000)
        local plannedEarlyMs = configuredEarlyMs
        local dueIn = math.max(0, remaining - plannedEarlyMs)
        return dueIn <= window
    end

    -- Fillers are allowed a little before the next coached beat, but only when the
    -- route actually has a free filler GCD.
    local route = self:BuildRoute(2)
    local first = route and route[1]
    if not first or not self:RecommendationMatchesAbility(first, id) then return false end
    local gcd = math.max(1000, self:GetAdaptiveRhythmMs())
    local elapsed = pressTime - (self.lastActionMs or pressTime)
    local dueIn = math.max(0, gcd - elapsed)
    return dueIn <= window
end

function SRT:GetTargetHpPercent()
    if not DoesUnitExist("reticleover") or not IsUnitAttackable("reticleover") or IsUnitDead("reticleover") then
        return 1
    end
    if AreUnitsCurrentlyAllied and AreUnitsCurrentlyAllied("player", "reticleover") then return 1 end
    local currentHealth, maxHealth = GetUnitPower("reticleover", POWERTYPE_HEALTH)
    if not maxHealth or maxHealth <= 0 then return 1 end
    return currentHealth / maxHealth
end

function SRT:GetManualDurationMs(id)
    id = tonumber(id) or 0
    for i = 1, self.maxPriorities do
        local sk = self.sv.priorities[i]
        if sk and sk.abilityId == id then
            local value = tonumber(sk.manualDurationMs) or 0
            if (not self:IsUltimateLocked()) and value >= 1000 then return value end
        end
    end
    return nil
end

function SRT:GetRotationDurationMs(id)
    id = tonumber(id) or 0
    if id == HEAVY_ATTACK_ID then return HEAVY_ATTACK_CHANNEL_MS end

    -- Manual RECAST always wins. This restores exact per-skill timing control.
    local manual = self:GetManualDurationMs(id)
    if manual then return manual end

    -- Best source for route simulation: a full duration we actually observed from
    -- ESO's own begin/end effect timestamps.  This fixes skills whose tooltip or
    -- slotted ability reports 0/1s while the real effect lasts much longer.
    local observed = self.sv and self.sv.observedDurations and tonumber(self.sv.observedDurations[id])
    if observed and observed > 1000 then return observed end

    -- If the effect is active right now, also use its complete measured duration.
    local live = self.esoEffectTimers and self.esoEffectTimers[id]
    if live and live.beginMs and live.endMs then
        local liveDuration = tonumber(live.endMs) - tonumber(live.beginMs)
        if liveDuration and liveDuration > 1000 then return liveDuration end
    end

    -- Known rotation-specific recast intervals remain a fallback for abilities for
    -- which ESO has not yet exposed a useful effect duration in this session.
    if DURATION_OVERRIDES_MS[id] then return DURATION_OVERRIDES_MS[id] end

    local duration = GetAbilityDuration(id) or 0
    if duration < 0 then duration = 0 end

    -- A priority skill with no readable duration must never be simulated every GCD.
    -- Until ESO gives us a real duration, use a conservative temporary cycle.
    if duration <= 1000 then return 10000 end
    return duration
end

function SRT:SetTimer(id, durationMs, startMs)
    if not id or id == 0 then return end
    durationMs = tonumber(durationMs) or 0
    if durationMs <= 0 then
        self.abilityTimers[id] = 0
        return
    end
    self.abilityTimers[id] = (startMs or now()) + durationMs
end

function SRT:GetConfiguredSourceIdForEffect(abilityId, effectName)
    if abilityId and self:IsConfiguredAbility(abilityId) then
        return abilityId
    end

    -- ESO sometimes reports an effect with a different ability id than the slotted skill.
    -- As a secondary match, use the localized effect/skill name against configured skills.
    if effectName and effectName ~= "" then
        local needle = zo_strlower(effectName)
        for _, skill in ipairs(self:GetAllConfiguredSkills()) do
            local id = skill and skill.abilityId
            if id and id > 0 then
                local name = GetAbilityName(id)
                if name and name ~= "" and zo_strlower(name) == needle then
                    return id
                end
            end
        end
    end
    return nil
end

function SRT:SetEsoEffectTimer(sourceId, effectId, beginTimeSec, endTimeSec, unitTag)
    if not sourceId or not endTimeSec or not beginTimeSec or endTimeSec <= beginTimeSec then return end
    local beginMs = beginTimeSec * 1000
    local endMs = endTimeSec * 1000
    local fullDuration = endMs - beginMs

    self.esoEffectTimers = self.esoEffectTimers or {}
    self.esoEffectTimers[sourceId] = {
        effectId = effectId,
        beginMs = beginMs,
        endMs = endMs,
        unitTag = unitTag,
    }

    -- Persist the real full ESO duration for the 20-skill route simulator.
    -- Smooth small event variations instead of replacing the value abruptly.
    if self.sv and fullDuration > 1000 and fullDuration < 180000 then
        self.sv.observedDurations = self.sv.observedDurations or {}
        local old = tonumber(self.sv.observedDurations[sourceId])
        if old and old > 1000 then
            self.sv.observedDurations[sourceId] = math.floor((old * 3 + fullDuration) / 4 + 0.5)
        else
            self.sv.observedDurations[sourceId] = math.floor(fullDuration + 0.5)
        end
    end
end

function SRT:GetEsoEffectRemainingMs(id)
    local t = self.esoEffectTimers and self.esoEffectTimers[id]
    if not t then return nil end
    local remaining = (tonumber(t.endMs) or 0) - now()
    if remaining <= 0 then
        self.esoEffectTimers[id] = nil
        return 0
    end
    return remaining
end


function SRT:GetConfiguredTimerKey(role, index, abilityId)
    if role == "priority" and index then
        return "priority:" .. tostring(index)
    elseif role then
        return tostring(role)
    end
    return "ability:" .. tostring(abilityId or 0)
end

function SRT:SetConfiguredRecast(role, index, abilityId, endMs)
    self.configuredRecasts = self.configuredRecasts or {}
    local key = self:GetConfiguredTimerKey(role, index, abilityId)
    self.configuredRecasts[key] = tonumber(endMs) or 0
end

function SRT:GetConfiguredRecastRemaining(role, index, abilityId)
    self.configuredRecasts = self.configuredRecasts or {}
    local key = self:GetConfiguredTimerKey(role, index, abilityId)
    local endMs = tonumber(self.configuredRecasts[key]) or 0
    local remain = endMs - now()
    if remain <= 0 then
        return 0
    end
    return remain
end

function SRT:GetRemainingMs(id)
    if self.procReady and self.procReady[id] then return 0 end

    -- Primary source: ESO's own effect begin/end timestamps.
    local esoRemaining = self:GetEsoEffectRemainingMs(id)
    if esoRemaining ~= nil then return esoRemaining end

    -- Fallback only: locally estimated duration from the actual slot use.
    local endMs = self.abilityTimers and self.abilityTimers[id]
    if not endMs or endMs <= 0 then return 0 end
    local remaining = endMs - now()
    if remaining <= 0 then
        self.abilityTimers[id] = 0
        return 0
    end
    return remaining
end

function SRT:SyncConfiguredSkillsToSavedSlots()
    -- Configuration is slot based: if the player changes the skill occupying an
    -- assigned hotbar slot, follow that new skill automatically. Do this only
    -- outside combat so temporary proc replacements can never rewrite settings.
    if self.inCombat then return false end

    local changed = false
    for _, skill in ipairs(self:GetAllConfiguredSkills()) do
        if not isHeavyAttackSkill(skill) and skill and skill.hotbar and skill.slotIndex then
            local liveId = GetSlotBoundId(tonumber(skill.slotIndex), skill.hotbar) or 0
            local oldId = tonumber(skill.abilityId) or 0
            if liveId ~= oldId then
                local isRuntimeProc = false
                if liveId > 0 then
                    isRuntimeProc = (PROC_BASE_BY_PROC[liveId] == oldId)
                        or (self.runtimeProcBaseByProc and self.runtimeProcBaseByProc[liveId] == oldId)
                end
                if not isRuntimeProc then
                    skill.abilityId = liveId
                    changed = true
                end
            end
        end
    end
    return changed
end

function SRT:QueueHotbarRefresh()
    local updateName = self.name .. "_DeferredHotbarRefresh"
    EVENT_MANAGER:UnregisterForUpdate(updateName)
    EVENT_MANAGER:RegisterForUpdate(updateName, 150, function()
        EVENT_MANAGER:UnregisterForUpdate(updateName)
        local changed = self:SyncConfiguredSkillsToSavedSlots()
        self:RefreshBarMap()
        self:RefreshHotbarPicker()
        self:RefreshConfig()
        if changed then
            self:ResetFlow()
        end
    end)
end

function SRT:RefreshBarMap()
    -- Keep a per-bar map. A single abilityId -> bar table cannot represent the
    -- common case where the same skill is slotted on FRONT and BACK at once.
    self.barMap = {}
    self.slotMap = {}
    self.barSlots = { [HOTBAR_PRIMARY] = {}, [HOTBAR_BACKUP] = {} }

    for _, hotbar in ipairs({HOTBAR_PRIMARY, HOTBAR_BACKUP}) do
        for _, slot in ipairs(hotbarSlots()) do
            local id = GetSlotBoundId(slot, hotbar)
            if id and id > 0 then
                self.barSlots[hotbar][id] = slot
                -- Legacy fallback only: never overwrite the first placement.
                if not self.barMap[id] then
                    self.barMap[id] = hotbar
                    self.slotMap[id] = slot
                end
            end
        end
        local ultId = GetSlotBoundId(ULTIMATE_SLOT, hotbar)
        if ultId and ultId > 0 then
            self.barSlots[hotbar][ultId] = ULTIMATE_SLOT
            if not self.barMap[ultId] then
                self.barMap[ultId] = hotbar
                self.slotMap[ultId] = ULTIMATE_SLOT
            end
        end
    end

    -- Proc aliases inherit the placement of their configured base skill.
    local aliases = {}
    for procId, baseId in pairs(PROC_BASE_BY_PROC) do aliases[procId] = baseId end
    for procId, baseId in pairs(aliases) do
        for _, hotbar in ipairs({HOTBAR_PRIMARY, HOTBAR_BACKUP}) do
            local slot = self.barSlots[hotbar][baseId]
            if slot then self.barSlots[hotbar][procId] = slot end
        end
        if self.barMap[baseId] and not self.barMap[procId] then
            self.barMap[procId] = self.barMap[baseId]
            self.slotMap[procId] = self.slotMap[baseId]
        end
    end

    -- Preserve the bar explicitly selected in the configuration whenever that
    -- placement still exists. Only repair it if the skill was actually moved.
    for _, s in ipairs(self:GetAllConfiguredSkills()) do
        if s and s.abilityId and s.abilityId > 0 then
            local savedBar, savedSlot = s.hotbar, s.slotIndex
            local validSaved = savedBar and savedSlot and GetSlotBoundId(savedSlot, savedBar) == s.abilityId
            if not validSaved then
                local foundBar, foundSlot = nil, nil
                if savedBar and self.barSlots[savedBar] and self.barSlots[savedBar][s.abilityId] then
                    foundBar, foundSlot = savedBar, self.barSlots[savedBar][s.abilityId]
                else
                    for _, hb in ipairs({HOTBAR_PRIMARY, HOTBAR_BACKUP}) do
                        if self.barSlots[hb] and self.barSlots[hb][s.abilityId] then
                            foundBar, foundSlot = hb, self.barSlots[hb][s.abilityId]
                            break
                        end
                    end
                end
                if foundBar then s.hotbar, s.slotIndex = foundBar, foundSlot end
            end
        end
    end
end

function SRT:ResolveItemPlacement(item)
    if not item then return nil, nil end
    local skill = item.skill
    local sourceId = item.sourceAbilityId or item.abilityId
    local shownId = item.abilityId or sourceId

    -- The configured role owns its selected bar. This is essential when the same
    -- ability is present on both weapon bars.
    if skill and skill.hotbar and skill.slotIndex then
        local slotted = GetSlotBoundId(skill.slotIndex, skill.hotbar)
        if slotted == sourceId or slotted == shownId then
            return skill.hotbar, skill.slotIndex
        end
        if self.barSlots and self.barSlots[skill.hotbar] then
            local slot = self.barSlots[skill.hotbar][sourceId] or self.barSlots[skill.hotbar][shownId]
            if slot then return skill.hotbar, slot end
        end
    end

    for _, hb in ipairs({HOTBAR_PRIMARY, HOTBAR_BACKUP}) do
        local slots = self.barSlots and self.barSlots[hb]
        local slot = slots and (slots[sourceId] or slots[shownId])
        if slot then return hb, slot end
    end
    return self.barMap[shownId] or self.barMap[sourceId], self.slotMap[shownId] or self.slotMap[sourceId]
end

function SRT:RefreshRuntimeProcAliases()
    self.runtimeProcAliases = self.runtimeProcAliases or {}
    self.runtimeProcBaseByProc = self.runtimeProcBaseByProc or {}
    self.procReady = self.procReady or {}
    self.ultimateLockedUntil = tonumber(self.ultimateLockedUntil) or 0

    -- Some ESO procs replace the action-slot ability itself. Detect that generically.
    -- If the saved base skill occupies this slot but ESO currently reports another id,
    -- treat that id as a temporary proc alias for the base skill.
    for _, sk in ipairs(self:GetAllConfiguredSkills()) do
        if sk and sk.abilityId and sk.slotIndex and sk.hotbar then
            local currentId = GetSlotBoundId(sk.slotIndex, sk.hotbar)
            if currentId and currentId > 0 and currentId ~= sk.abilityId then
                -- Only treat a changed slot id as a runtime proc when the configured
                -- skill is still on its saved bar/slot. A weapon swap must never create
                -- a fake proc/recast reset for the skill on the other bar.
                local active = currentBar()
                if sk.hotbar == active then
                    self.runtimeProcAliases[sk.abilityId] = currentId
                    self.runtimeProcBaseByProc[currentId] = sk.abilityId
                    self.procReady[currentId] = true
                end
            end
        end
    end
end

function SRT:GetReadyProcForBase(baseId)
    if not baseId then return nil end
    for procId, knownBase in pairs(PROC_BASE_BY_PROC) do
        if knownBase == baseId and self.procReady and self.procReady[procId] then return procId end
    end
    return nil
end

function SRT:RefreshProcState()
    self.procReady = self.procReady or {}
    local seen = {}

    local count = GetNumBuffs("player") or 0
    for i = 1, count do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        local rule = PROC_RULES[abilityId]
        if rule and (tonumber(stackCount) or 0) >= (tonumber(rule.minStacks) or 1) then
            seen[rule.procId] = true
            self.procReady[rule.procId] = true
        end
    end

    -- The scan is the steady-state source; EVENT_EFFECT_CHANGED is the fast source.
    -- Clearing here is safe because a missing active player buff means that proc is no
    -- longer available. No slot-id guessing is used, so ordinary morphs/AoEs cannot
    -- become fake procs.
    for _, rule in pairs(PROC_RULES) do
        if rule.procId and not seen[rule.procId] then
            self.procReady[rule.procId] = false
        end
    end
end

function SRT:OnEffectChanged(changeType, effectName, unitTag, beginTimeSec, endTimeSec, abilityId, sourceType)
    if sourceType and COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    -- Proc state is tracked independently from normal duration tracking.  A configured
    -- skill may therefore listen to BOTH its normal cast id and its proc effect id.
    -- Both resolve back to the same base skill in the planner.
    local procRule = PROC_RULES[abilityId]
    if procRule and procRule.procId then
        self.procReady = self.procReady or {}
        if changeType == EFFECT_RESULT_FADED then
            self.procReady[procRule.procId] = false
        else
            self.procReady[procRule.procId] = true
        end
        -- Do not return: some proc effects can also carry useful timing data.
    end

    local sourceId = self:GetConfiguredSourceIdForEffect(abilityId, effectName)
    if not sourceId then
        -- A proc-effect id may not itself be configured, but its base skill can be.
        if procRule and procRule.baseId and self:IsConfiguredAbility(procRule.baseId) then
            sourceId = procRule.baseId
        else
            return
        end
    end

    if changeType == EFFECT_RESULT_FADED then
        -- Effect fade never means the rotation recast is instantly ready. Keep the
        -- authoritative cast/recast timer; only clear the live ESO effect instance.
        if self.esoEffectTimers then self.esoEffectTimers[sourceId] = nil end
        return
    end

    if beginTimeSec and endTimeSec and endTimeSec > beginTimeSec then
        self:SetEsoEffectTimer(sourceId, abilityId, beginTimeSec, endTimeSec, unitTag)
    end
end


function SRT:LockUltimateForTenSeconds()
    local currentMs = tonumber(now()) or tonumber(GetGameTimeMilliseconds and GetGameTimeMilliseconds()) or 0
    local lockMs = tonumber(ULTIMATE_LOCKOUT_MS) or 10000
    self.ultimateLockedUntil = currentMs + lockMs

    -- Remove any already queued/planned ultimate immediately.
    local function purgeUltimateEntries(queue)
        if not queue then return queue end
        local filtered = {}
        for _, entry in ipairs(queue) do
            if entry and entry.type ~= "ultimate" and not entry.isUltimate then
                filtered[#filtered + 1] = entry
            end
        end
        return filtered
    end

    self.lockedQueue = purgeUltimateEntries(self.lockedQueue)
    self.routeQueue = purgeUltimateEntries(self.routeQueue)
    self.dynamicLockQueue = purgeUltimateEntries(self.dynamicLockQueue)

    -- If the currently displayed recommendation is an Ultimate, remove it immediately.
    if self.heldRecommendation and self.heldRecommendation.type == "ultimate" then
        self:ClearHeldRecommendation()
    end
end

function SRT:IsUltimateLocked()
    local currentMs = tonumber(now()) or 0
    return currentMs < (tonumber(self.ultimateLockedUntil) or 0)
end

function SRT:GetUltimateLockRemainingMs()
    local currentMs = tonumber(now()) or 0
    local remain = (tonumber(self.ultimateLockedUntil) or 0) - currentMs
    return remain > 0 and remain or 0
end


function SRT:GetReadyProcRecommendation()
    local function make(skill, priority)
        if not skill or not skill.abilityId or skill.abilityId <= 0 then return nil end
        local procId = self:GetReadyProcForBase(skill.abilityId)
        if not procId then return nil end
        return {
            abilityId = procId,
            sourceAbilityId = skill.abilityId,
            priority = priority or 50,
            type = "proc",
            skill = skill,
            readyProc = true,
        }
    end

    -- Respect configured priority order first.
    for i = 1, self.maxPriorities do
        local rec = make(self.sv.priorities[i], i)
        if rec then return rec end
    end

    -- Also allow a proc whose base skill is configured as a filler.
    local rec = make(self.sv.spammable, 50)
    if rec then return rec end

    rec = make(self.sv.execute, 50)
    if rec then return rec end

    return nil
end

function SRT:GetPriorityState()
    local states = {}
    self:RefreshProcState()
    for i = 1, self.maxPriorities do
        local s = self.sv.priorities[i]
        if validRotationSkill(s) then
            local id = s.abilityId
            -- Class-agnostic proc resolution: if this configured base skill currently
            -- has a ready proc variant, recommend the proc immediately.
            local readyProc = self:GetReadyProcForBase(id)
            if readyProc then id = readyProc end

            local remaining
            if isHeavyAttackSkill(s) then
                -- Heavy Attack is a channel action, not a maintained effect. It is ready
                -- again after its 2.2 s channel completes.
                remaining = self:GetRemainingMs(HEAVY_ATTACK_ID)
            elseif readyProc then
                -- A ready proc is immediately actionable.
                remaining = 0
            else
                -- Recast state belongs to the configured base skill and survives bar swaps.
                remaining = self:GetRemainingMs(s.abilityId)
            end
            local configuredEarlyMs = zo_clamp(tonumber(s.earlyMs) or 0, 0, 5000)
            -- Respect the user-defined early-refresh window for every maintained effect.
            -- 0 ms means wait until the effect actually expires; larger values allow
            -- an intentional early recast without forcing the rotation to cycle buffs.
            local earlyMs = configuredEarlyMs
            states[i] = {
                abilityId = id,
                sourceAbilityId = s.abilityId,
                priority = i,
                earlyMs = earlyMs,
                dueMs = math.max(0, remaining - earlyMs),
                durationMs = self:GetRotationDurationMs(s.abilityId),
                skill = s,
            }
        end
    end
    return states
end

-- Static mode uses the configured Priority 1-10 rows as a deterministic rotation.
-- It deliberately ignores timers/procs/fillers so every cycle is repeatable for practice.
function SRT:GetStaticSequence()
    local seq = {}
    for i = 1, self.maxPriorities do
        local s = self.sv.priorities[i]
        if validRotationSkill(s) then
            table.insert(seq, {
                abilityId = s.abilityId,
                sourceAbilityId = s.abilityId,
                priority = i,
                type = isHeavyAttackSkill(s) and "heavyAttack" or "priority",
                skill = s,
                channelMs = isHeavyAttackSkill(s) and HEAVY_ATTACK_CHANNEL_MS or nil,
            })
        end
    end
    return seq
end

function SRT:BuildStaticRoute(requestedLength)
    local seq = self:GetStaticSequence()
    local count = #seq
    if count == 0 then
        -- If no static priority sequence is configured, keep a usable fallback.
        local filler = self.sv.spammable
        local hp = self:GetTargetHpPercent()
        local threshold = (tonumber(self.sv.executeHp) or 25) / 100
        if self.sv.execute and self.sv.execute.abilityId and hp <= threshold then filler = self.sv.execute end
        if filler and filler.abilityId then
            return {{abilityId=filler.abilityId, sourceAbilityId=filler.abilityId, priority=99,
                     type=(filler==self.sv.execute and "execute" or "spammable"), skill=filler, scheduledMs=0}}
        end
        return {}
    end

    local length = tonumber(requestedLength) or self.routeLength
    local start = zo_clamp(tonumber(self.staticStepIndex) or 1, 1, count)
    local gcd = self:GetAdaptiveRhythmMs()
    local route = {}
    for n = 1, length do
        local idx = ((start - 1 + n - 1) % count) + 1
        local base = seq[idx]
        table.insert(route, {
            abilityId = base.abilityId,
            sourceAbilityId = base.sourceAbilityId,
            priority = base.priority,
            type = base.type or "priority",
            skill = base.skill,
            channelMs = base.channelMs,
            staticSequenceIndex = idx,
            scheduledMs = (n - 1) * gcd,
        })
    end
    return route
end

function SRT:AdvanceStaticStep()
    local seq = self:GetStaticSequence()
    if #seq == 0 then self.staticStepIndex = 1 return end
    local current = zo_clamp(tonumber(self.staticStepIndex) or 1, 1, #seq)
    self.staticStepIndex = (current % #seq) + 1
end

-- Build a future route in GCD-sized steps. Higher priorities reserve a GCD if they will
-- become due before the next action can finish. This keeps Priority 1 active whenever possible.
function SRT:BuildDynamicRouteRaw(requestedLength)
    if self.sv.rotationMode == "static" then
        return self:BuildStaticRoute(requestedLength)
    end

    local gcd = self:GetAdaptiveRhythmMs()
    local route = {}
    local states = self:GetPriorityState()
    local simulatedDue = {}
    for i = 1, self.maxPriorities do
        if states[i] then simulatedDue[i] = states[i].dueMs end
    end

    local hp = self:GetTargetHpPercent()
    local executeThreshold = (tonumber(self.sv.executeHp) or 25) / 100
    local executeConfigured = validRotationSkill(self.sv.execute)
    local spamConfigured = validRotationSkill(self.sv.spammable)
    local executeActive = executeConfigured and hp <= executeThreshold
    local filler = executeActive and self.sv.execute or (spamConfigured and self.sv.spammable or nil)

    -- PROC READY is a special filler override:
    -- Priority skill > ready proc > ultimate > execute > normal spammable.
    -- The existing 3-skill dynamic lock still prevents a new proc from reshuffling
    -- the already locked near-term recommendations.
    local readyProcRecommendation = self:GetReadyProcRecommendation()

    local ultimate = self.sv.ultimate
    local ultimateReady = false
    local ultimatePoints = getUltimatePoints()
    local ultimateCost = 0
    if ultimate and ultimate.abilityId and ultimate.abilityId > 0 then
        ultimateCost = getUltimateCost(ultimate.abilityId, ultimate.hotbar)
        -- Ultimate is never eligible during the hard post-cast lock.
        -- Only after the lock expires do we trust ESO's current Ultimate resource again.
        ultimateReady = (not self:IsUltimateLocked())
            and ultimateCost > 0
            and ultimatePoints >= ultimateCost
    end
    local ultimateUsed = false

    local function choosePriority(virtualMs, lookAheadMs)
        for p = 1, self.maxPriorities do
            local st = states[p]
            local due = simulatedDue[p]
            if st and due ~= nil and due <= virtualMs + lookAheadMs then
                return p, st
            end
        end
        return nil, nil
    end

    local function commitPriority(p, st, scheduledMs)
        local cycle = math.max(gcd * 2, (st.durationMs or 0) - (st.earlyMs or 0))
        simulatedDue[p] = scheduledMs + cycle
        return {
            abilityId = st.abilityId,
            sourceAbilityId = st.sourceAbilityId,
            priority = p,
            scheduledMs = scheduledMs,
            type = isHeavyAttackSkill(st.skill) and "heavyAttack" or "priority",
            skill = st.skill,
            channelMs = isHeavyAttackSkill(st.skill) and HEAVY_ATTACK_CHANNEL_MS or nil,
        }
    end

    local buildLength = tonumber(requestedLength) or self.routeLength
    for routeIndex = 1, buildLength do
        local virtualMs = (routeIndex - 1) * gcd
        local chosen = nil

        -- A priority that is due during the action window always beats fillers.
        local p, st = choosePriority(virtualMs, gcd)
        if p then
            chosen = commitPriority(p, st, virtualMs)
        end

        if not chosen and readyProcRecommendation then
            chosen = {
                abilityId = readyProcRecommendation.abilityId,
                sourceAbilityId = readyProcRecommendation.sourceAbilityId,
                priority = readyProcRecommendation.priority,
                scheduledMs = virtualMs,
                type = "proc",
                skill = readyProcRecommendation.skill,
                readyProc = true,
            }
            -- Only show the same pending proc once in a single predicted route.
            readyProcRecommendation = nil
        end

        if not chosen and ultimateReady and not ultimateUsed then
            -- Ultimate is its own route category. It is inserted only when enough
            -- Ultimate resource is available and no priority skill needs this GCD.
            chosen = {
                abilityId = ultimate.abilityId,
                sourceAbilityId = ultimate.abilityId,
                priority = 90,
                scheduledMs = virtualMs,
                type = "ultimate",
                skill = ultimate,
            }
            ultimateUsed = true
        end

        if not chosen and validRotationSkill(filler) then
            -- Filler is allowed only when a complete GCD is genuinely free.  If a
            -- priority would become due before the filler GCD finishes, cast the
            -- priority early instead.  Priority 1 stays exact through earlyMs=0;
            -- lower priorities already include their early-renew window above.
            local reserveP, reserveSt = choosePriority(virtualMs, gcd)
            if reserveP then
                chosen = commitPriority(reserveP, reserveSt, virtualMs)
            else
                chosen = {
                    abilityId = filler.abilityId,
                    sourceAbilityId = filler.abilityId,
                    priority = 99,
                    scheduledMs = virtualMs,
                    type = isHeavyAttackSkill(filler) and "heavyAttack" or (executeActive and "execute" or "spammable"),
                    skill = filler,
                    channelMs = isHeavyAttackSkill(filler) and HEAVY_ATTACK_CHANNEL_MS or nil,
                }
            end
        end

        -- No filler configured: during live coaching, WAIT until a maintained
        -- priority is genuinely inside its configured refresh window. Do not rotate
        -- through already-active buffs just because one of them is next chronologically.
        -- Long route previews may still show future scheduled casts.
        if not chosen then
            local bestP, bestDue = nil, nil
            for pp = 1, self.maxPriorities do
                if states[pp] and simulatedDue[pp] ~= nil then
                    if not bestDue or simulatedDue[pp] < bestDue or (simulatedDue[pp] == bestDue and pp < bestP) then
                        bestP, bestDue = pp, simulatedDue[pp]
                    end
                end
            end
            if bestP then
                local previewMode = tonumber(requestedLength) and tonumber(requestedLength) > 3
                if previewMode then
                    local bst = states[bestP]
                    chosen = commitPriority(bestP, bst, math.max(virtualMs, bestDue))
                else
                    -- Nothing is due yet. Return the route built so far and let the
                    -- next update pick the skill when its remaining time reaches earlyMs.
                    break
                end
            end
        end

        if chosen then table.insert(route, chosen) end
    end

    return route
end


local function SRT_RecommendationKey(item)
    if not item then return nil end
    return table.concat({
        tostring(item.type or ""),
        tostring(item.priority or 0),
        tostring(item.sourceAbilityId or item.abilityId or 0),
    }, ":")
end

function SRT:ResetDynamicLockQueue()
    self.dynamicLockQueue = {}
end

function SRT:RemoveFromDynamicLockQueueByAbility(abilityId)
    if not abilityId or not self.dynamicLockQueue then return end
    for i = #self.dynamicLockQueue, 1, -1 do
        local item = self.dynamicLockQueue[i]
        if self:RecommendationMatchesAbility(item, abilityId) then
            table.remove(self.dynamicLockQueue, i)
        end
    end
end

function SRT:RefreshDynamicLockQueue()
    self.dynamicLockQueue = self.dynamicLockQueue or {}

    -- Remove entries whose configured skill no longer exists.
    for i = #self.dynamicLockQueue, 1, -1 do
        local item = self.dynamicLockQueue[i]
        local sourceId = item and (item.sourceAbilityId or item.abilityId)
        local staleMaintainedPriority = false
        if item and item.type == "priority" and sourceId and self:IsConfiguredAbility(sourceId) then
            local _, pIndex, pSkill = self:GetConfiguredRoleForAbility(sourceId)
            local remaining = self:GetRemainingMs(sourceId)
            local earlyMs = pSkill and zo_clamp(tonumber(pSkill.earlyMs) or 0, 0, 5000) or 0
            -- If ESO reports the effect as active beyond the user's refresh window,
            -- a previously locked recommendation is stale and must disappear.
            staleMaintainedPriority = remaining > earlyMs
        end
        if not sourceId
            or (item.type == "priority" and not self:IsConfiguredAbility(sourceId))
            or staleMaintainedPriority
            or (item.type == "ultimate" and self:IsUltimateLocked()) then
            table.remove(self.dynamicLockQueue, i)
        end
    end

    if #self.dynamicLockQueue >= 3 then return end

    -- Calculate farther ahead, but append only recommendations that are not already
    -- locked. New timer/proc information can therefore affect position 4+, never the
    -- three actions the player is already preparing to execute.
    local fresh = self:BuildDynamicRouteRaw(10)
    local existing = {}
    for _, item in ipairs(self.dynamicLockQueue) do
        existing[SRT_RecommendationKey(item)] = true
    end

    for _, item in ipairs(fresh or {}) do
        if #self.dynamicLockQueue >= 3 then break end
        local key = SRT_RecommendationKey(item)
        if key and not existing[key] then
            table.insert(self.dynamicLockQueue, item)
            existing[key] = true
        elseif item.type == "spammable" or item.type == "execute" or item.type == "proc" then
            -- Fillers may legitimately repeat, so allow them when needed to complete
            -- the locked three-beat window.
            table.insert(self.dynamicLockQueue, item)
        end
    end
end

function SRT:BuildRoute(requestedLength)
    if self.sv.rotationMode == "static" then
        return self:BuildStaticRoute(requestedLength)
    end

    -- Long previews should remain a simulation, not mutate the combat lock queue.
    if requestedLength and tonumber(requestedLength) and tonumber(requestedLength) > 3 then
        return self:BuildDynamicRouteRaw(requestedLength)
    end

    if not self.inCombat or self.testMode then
        return self:BuildDynamicRouteRaw(requestedLength)
    end

    self:RefreshDynamicLockQueue()
    local wanted = tonumber(requestedLength) or self.routeLength
    local out = {}
    for i = 1, math.min(wanted, #self.dynamicLockQueue) do
        out[i] = self.dynamicLockQueue[i]
    end
    return out
end


function SRT:GetTestPool(hotbar)
    local out, seen = {}, {}
    local function addSkill(s)
        if not s or not s.abilityId or s.abilityId == 0 then return end
        if s.slotIndex == ULTIMATE_SLOT then return end
        local bar = self.barMap[s.abilityId] or s.hotbar
        if bar ~= hotbar then return end
        if seen[s.abilityId] then return end
        seen[s.abilityId] = true
        table.insert(out, {
            abilityId = s.abilityId,
            sourceAbilityId = s.abilityId,
            type = "test",
            skill = {abilityId=s.abilityId, slotIndex=self.slotMap[s.abilityId] or s.slotIndex, hotbar=bar},
        })
    end
    for _, s in ipairs(self:GetAllConfiguredSkills()) do addSkill(s) end
    -- Fallback: use the actual five slotted skills if the rotation did not provide
    -- enough candidates on a bar yet.
    if #out == 0 then
        for _, slot in ipairs(hotbarSlots()) do
            local id = GetSlotBoundId(slot, hotbar)
            if id and id > 0 and not seen[id] then
                seen[id] = true
                table.insert(out, {abilityId=id, sourceAbilityId=id, type="test", skill={abilityId=id, slotIndex=slot, hotbar=hotbar}})
            end
        end
    end
    return out
end

function SRT:BuildRhythmTestSequence()
    self:RefreshBarMap()
    local front = self:GetTestPool(HOTBAR_PRIMARY)
    local back = self:GetTestPool(HOTBAR_BACKUP)
    if #front == 0 or #back == 0 then
        return nil, "The 40-skill test needs at least one usable skill on FRONT and BACK bar."
    end

    -- Six alternating blocks create exactly five required bar swaps.
    local blocks = {7, 7, 7, 7, 6, 6}
    local startBar = currentBar()
    if startBar ~= HOTBAR_PRIMARY and startBar ~= HOTBAR_BACKUP then startBar = HOTBAR_PRIMARY end
    local seq, frontIndex, backIndex = {}, 1, 1
    for blockIndex, count in ipairs(blocks) do
        local bar = ((blockIndex % 2) == 1) and startBar or (startBar == HOTBAR_PRIMARY and HOTBAR_BACKUP or HOTBAR_PRIMARY)
        local pool = (bar == HOTBAR_PRIMARY) and front or back
        for _ = 1, count do
            local idx = (bar == HOTBAR_PRIMARY) and frontIndex or backIndex
            local src = pool[((idx - 1) % #pool) + 1]
            table.insert(seq, {
                abilityId = src.abilityId,
                sourceAbilityId = src.sourceAbilityId,
                type = "test",
                priority = 1,
                skill = {abilityId=src.abilityId, slotIndex=src.skill.slotIndex, hotbar=bar},
            })
            if bar == HOTBAR_PRIMARY then frontIndex = frontIndex + 1 else backIndex = backIndex + 1 end
        end
    end
    return seq
end

function SRT:StartRhythmTest()
    if self.moveMode then self:ExitMoveMode() end
    local seq, err = self:BuildRhythmTestSequence()
    if not seq then msg(err); return end
    self:ResetFlow()
    self.testMode = true
    self.testSequence = seq
    self.testIndex = 1
    self.testIntervals = {}
    self.testLastCorrectPressMs = nil
    self.testStartMs = now()
    self.lastActionMs = self.testStartMs
    if self.main then self.main:SetHidden(false) end
    msg("40-skill rhythm test started: 40 correct skills, exactly 5 planned bar swaps. Follow PRESS until complete.")
end

function SRT:StopRhythmTest(silent)
    self.testMode = false
    self.testSequence = nil
    self.testIndex = nil
    self.testLastCorrectPressMs = nil
    self.testStartMs = nil
    self:ClearHeldRecommendation()
    self:ClearFadeRecommendation()
    if not silent then msg("Rhythm test stopped.") end
end

function SRT:FinishRhythmTest()
    local samples = self.testIntervals or {}
    local total, valid = 0, 0
    for _, delta in ipairs(samples) do
        if delta >= 650 and delta <= 2500 then total = total + delta; valid = valid + 1 end
    end
    local result = valid > 0 and (total / valid) or 1000
    -- Never coach below the 1.00 second ESO GCD.
    result = math.max(1000, math.floor(result + 0.5))

    self.sv.rhythmSamples = {}
    local first = math.max(1, #samples - 19)
    for i = first, #samples do
        local d = tonumber(samples[i])
        if d and d >= 650 and d <= 2500 then table.insert(self.sv.rhythmSamples, d) end
    end
    self.sv.gcdMs = result
    self.sv.adaptiveRhythmMs = result
    self:GetAdaptiveRhythmMs()
    self:StopRhythmTest(true)
    msg("Rhythm test complete: " .. tostring(result) .. " ms average target from " .. tostring(valid) .. " intervals. Minimum is always 1000 ms.")
end

function SRT:HandleTestAbility(id, hotbar, pressTime)
    if not self.testMode or not self.testSequence or not self.testIndex then return false end
    local expected = self.testSequence[self.testIndex]
    if not expected then return false end
    local expectedBar = expected.skill and expected.skill.hotbar
    if id ~= expected.abilityId or (expectedBar and hotbar ~= expectedBar) then
        return true -- ignore wrong skill/bar; test does not advance
    end

    if self.testLastCorrectPressMs then
        local delta = pressTime - self.testLastCorrectPressMs
        if delta >= 650 and delta <= 2500 then table.insert(self.testIntervals, delta) end
    end
    self.testLastCorrectPressMs = pressTime
    self.lastActionMs = pressTime
    self:StartFadeRecommendation(expected, pressTime)
    self:ClearHeldRecommendation()
    self.testIndex = self.testIndex + 1
    if self.testIndex > #self.testSequence then
        self:FinishRhythmTest()
    end
    return true
end

function SRT:MoveMainBy(dx, dy)
    if not self.main then return end
    self.sv.x = math.floor((tonumber(self.sv.x) or defaults.x) + (dx or 0))
    self.sv.y = math.floor((tonumber(self.sv.y) or defaults.y) + (dy or 0))
    self.main:ClearAnchors()
    self.main:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.x, self.sv.y)
end

function SRT:ExitMoveMode()
    if not self.moveMode then return end
    self.moveMode = false
    if self.main and self.main.SetKeyboardEnabled then self.main:SetKeyboardEnabled(false) end
    if SCENE_MANAGER and SCENE_MANAGER.IsInUIMode and SCENE_MANAGER:IsInUIMode() and not WINDOW_MANAGER:IsSecureRenderModeEnabled() then
        SCENE_MANAGER:SetInUIMode(false)
    end
    self:ResetFlow()
    if self.main then self.main:SetHidden(not self.inCombat or not self.sv.enabled) end
    msg("Move mode saved. Position: " .. tostring(self.sv.x) .. ", " .. tostring(self.sv.y))
end

function SRT:EnterMoveMode()
    if self.testMode then self:StopRhythmTest(true) end
    self.moveMode = true
    self:ResetFlow()
    if self.main then
        self.main:SetHidden(false)
        if self.main.SetKeyboardEnabled then self.main:SetKeyboardEnabled(true) end
    end
    if SCENE_MANAGER and not WINDOW_MANAGER:IsSecureRenderModeEnabled() then SCENE_MANAGER:SetInUIMode(true) end
    msg("MOVE MODE: arrow keys / controller D-pad move the metronome. ESC / View(Back) saves and exits.")
end

function SRT:UpdateMoveInput()
    -- Xbox/Gamepad safety: do not poll IsKeyDown(). That API is private from
    -- insecure addon code on console. Movement is handled exclusively by the
    -- main control's OnKeyDown handler while move mode is active.
    return
end

function SRT:CreateMain()
    local w = WM:CreateTopLevelWindow("SRT_Main")
    w:SetDimensions(700, 118)
    w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.x, self.sv.y)
    w:SetScale(self.sv.scale)
    w:SetMouseEnabled(true)
    w:SetMovable(true)
    w:SetClampedToScreen(true)
    w:SetHandler("OnMoveStop", function()
        self.sv.x = w:GetLeft()
        self.sv.y = w:GetTop()
    end)
    if w.SetKeyboardEnabled then w:SetKeyboardEnabled(false) end
    w:SetHandler("OnKeyDown", function(_, key)
        if not self.moveMode then return false end
        if key == KEY_ESCAPE or key == KEY_GAMEPAD_BACK or key == KEY_GAMEPAD_BACK_HOLD then
            self:ExitMoveMode()
            return true
        elseif key == KEY_LEFT or key == KEY_GAMEPAD_DPAD_LEFT then self:MoveMainBy(-8, 0)
        elseif key == KEY_RIGHT or key == KEY_GAMEPAD_DPAD_RIGHT then self:MoveMainBy(8, 0)
        elseif key == KEY_UP or key == KEY_GAMEPAD_DPAD_UP then self:MoveMainBy(0, -8)
        elseif key == KEY_DOWN or key == KEY_GAMEPAD_DPAD_DOWN then self:MoveMainBy(0, 8)
        end
        return true
    end)

    local zone = WM:CreateControl("SRT_HitZone", w, CT_BACKDROP)
    zone:SetDimensions(76, 86)
    zone:SetAnchor(LEFT, w, LEFT, self.sv.hitZoneX - 38, 0)
    zone:SetCenterColor(0.06, 0.06, 0.06, 0.18)
    zone:SetEdgeColor(0.60, 0.60, 0.60, 0.95)
    zone:SetEdgeTexture("", 4, 4, 4)
    self.hitZone = zone

    local ztxt = label(w, "SRT_HitZoneText", self.sv.hitZoneX - 35, 4, 70, 20, FONT_HEADER, "")
    ztxt:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    self.flowIcons = {}
    for i = 1, 3 do
        local holder = WM:CreateControl("SRT_FlowHolder" .. i, w, CT_CONTROL)
        holder:SetDimensions(self.sv.iconSize + 8, 94)
        local frame = WM:CreateControl("SRT_FlowFrame" .. i, holder, CT_BACKDROP)
        frame:SetAnchor(TOPLEFT, holder, TOPLEFT, 0, 0)
        frame:SetDimensions(self.sv.iconSize + 8, self.sv.iconSize + 8)
        frame:SetCenterColor(0, 0, 0, 0.35)
        frame:SetEdgeColor(0.35, 0.35, 0.35, 0.95)
        frame:SetEdgeTexture("", 2, 2, 2)
        local icon = WM:CreateControl("SRT_FlowIcon" .. i, holder, CT_TEXTURE)
        icon:SetAnchor(TOPLEFT, holder, TOPLEFT, 4, 4)
        icon:SetDimensions(self.sv.iconSize, self.sv.iconSize)
        -- Put the action key directly on top of the skill icon.  A larger bold
        -- font makes the number easy to read (and easier for external screen
        -- recognition) while keeping the ability icon visible underneath.
        local slot = label(holder, "SRT_FlowSlot" .. i, 4, 4, self.sv.iconSize, self.sv.iconSize, FONT_FLOW_KEY, "")
        slot:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        slot:SetColor(1, 1, 1, 1)
        holder.frame, holder.icon, holder.slot = frame, icon, slot
        holder:SetHidden(true)
        self.flowIcons[i] = holder
    end

    self.status = label(w, "SRT_Status", 0, 0, 1, 1, FONT_SMALL, "")
    self.status:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.main = w
end

function SRT:UpdateFlow()
    if not self.main then return end

    if self.moveMode then
        self.main:SetHidden(false)
        self:UpdateMoveInput()
        for _, holder in ipairs(self.flowIcons) do holder:SetHidden(true) end
        self.status:SetText("")
        return
    end

    if not self.sv.enabled or (not self.inCombat and not self.testMode) then
        self.main:SetHidden(true)
        if self.SetAhkDataCode then self:SetAhkDataCode(nil, false) end
        return
    end
    self.main:SetHidden(false)

    self:RefreshBarMap()
    local route
    if self.testMode and self.testSequence and self.testIndex then
        route = {}
        local current = self.testSequence[self.testIndex]
        local nxt = self.testSequence[self.testIndex + 1]
        local third = self.testSequence[self.testIndex + 2]
        if current then table.insert(route, current) end
        if nxt then table.insert(route, nxt) end
        if third then table.insert(route, third) end
    else
        -- Request three skills for DISPLAY only. The combat lock queue remains the same;
        -- the third item is used so a pre-planned SWAP can sit between two skills
        -- without hiding the skill that follows it.
        route = self:BuildRoute(3)
    end

    if #route == 0 then
        for _, holder in ipairs(self.flowIcons) do holder:SetHidden(true) end
        self.status:SetText("")
        return
    end

    local activeBar = currentBar()
    local half = (self.sv.iconSize + 8) / 2
    local gcd = math.max(1000, self:GetAdaptiveRhythmMs())
    -- Long two-beat visual runway: NEXT travels through one full beat before it
    -- becomes CURRENT, then CURRENT gets another full beat to reach PRESS.
    -- This makes the motion calmer without changing the coached GCD itself.
    local pressX = self.sv.hitZoneX - half
    local entryX = pressX + 220
    local farRightX = entryX + 220
    local leftX = pressX - 300

    local function setHolder(holder, item, x, green, alpha)
        if not holder or not item then
            if holder then holder:SetHidden(true) end
            return
        end
        holder:ClearAnchors()
        holder:SetAnchor(TOPLEFT, self.main, TOPLEFT, x, 28)
        holder:SetHidden(false)
        holder:SetAlpha(alpha or 1)

        if item.type == "swap" then
            holder.icon:SetHidden(true)
            holder.slot:SetFont(FONT_FLOW_SWAP)
            holder.slot:SetText("SWAP")
            holder.frame:SetCenterColor(green and 0.08 or 0.10, green and 0.08 or 0.18, green and 0.08 or 0.55, green and 0.62 or 0.62)
            holder.frame:SetEdgeColor(green and 0.65 or 0.35, green and 0.65 or 0.65, green and 0.65 or 1.0, 1.0)
            return
        end

        holder.icon:SetHidden(false)
        holder.icon:SetTexture(abilityIcon(item.abilityId))
        holder.slot:SetFont(FONT_FLOW_KEY)
        -- v0.6.28: visible slot labels restored on moving cards.
        -- Proc changes may alter the icon, but the configured stable slot label remains.
        local stableLabel = self:GetStableDisplayLabel(item)
        if item.type == "ultimate" then
            holder.slot:SetText("ULT")
        else
            holder.slot:SetText(stableLabel)
        end
        holder.frame:SetCenterColor(green and 0.08 or 0, green and 0.08 or 0, green and 0.08 or 0, green and 0.48 or 0)
        holder.frame:SetEdgeColor(green and 0.65 or 0.75, green and 0.65 or 0.75, green and 0.65 or 0.75, green and 1 or 0.85)
        holder.icon:SetColor(1, 1, 1, 1)
    end

    if not self.heldRecommendation then
        self.heldRecommendation = route[1]
        self.heldStartMs = self.lastActionMs or now()
        self.heldReachedPress = false

        -- Pre-calculate BAR SWAP exactly once for this held skill. This prevents a
        -- proc/live-slot change from suddenly inserting SWAP in the middle of combat.
        local plannedBar = select(1, self:GetStableDisplayPlacement(self.heldRecommendation))
        local barNow = currentBar()
        if plannedBar and plannedBar ~= barNow then
            self.heldPlannedSwapBar = plannedBar
            self.heldPlannedSwapDone = false
        else
            self.heldPlannedSwapBar = nil
            self.heldPlannedSwapDone = true
        end
    end

    local current = self.heldRecommendation
    local nextIndex = 1
    if current and route[1] and self:RecommendationMatchesAbility(current, route[1].sourceAbilityId or route[1].abilityId) then
        nextIndex = 2
    end
    local nextSkill = route[nextIndex]
    local thirdSkill = route[nextIndex + 1]

    -- v0.6.16: BAR SWAP is part of the visual plan, not a reaction to a changing
    -- live slot/proc state. The current recommendation receives its swap requirement
    -- once when it becomes held. The NEXT preview is also calculated from the frozen
    -- mapped bars so SWAP can already be seen BETWEEN the two skills.
    local visualCurrent = current
    local visualNext = nextSkill
    local visualThird = nil

    local currentBarNeeded = current and select(1, self:GetStableDisplayPlacement(current)) or nil
    local nextBarNeeded = nextSkill and select(1, self:GetStableDisplayPlacement(nextSkill)) or nil

    -- Consume only the swap that was pre-planned for CURRENT. Once completed it can
    -- never reappear for this skill, even if ESO later reports a proc replacement.
    if self.heldPlannedSwapBar and self.heldPlannedSwapDone == false then
        if activeBar == self.heldPlannedSwapBar then
            self.heldPlannedSwapDone = true
            self.visualSwapJustResolved = true
        else
            visualCurrent = {type="swap", targetBar=self.heldPlannedSwapBar, abilityId=0}
            visualNext = current
            visualThird = nextSkill
        end
    end

    -- If CURRENT itself is being shown, pre-calculate the transition to NEXT.
    -- When NEXT lives on the opposite mapped bar, the second moving item is SWAP
    -- immediately; it does not suddenly appear later at PRESS.
    if visualCurrent == current and nextSkill and currentBarNeeded and nextBarNeeded
        and nextBarNeeded ~= currentBarNeeded then
        visualNext = {
            type = "swap",
            targetBar = nextBarNeeded,
            abilityId = 0,
            plannedBetween = true,
        }
        -- Keep the skill AFTER the swap visible as a third moving item.
        visualThird = nextSkill
    end

    -- True frame-by-frame metronome motion. Never snap/clamp CURRENT to PRESS.
    -- Keep a persistent X coordinate and physically move it every update.
    local tNow = now()
    local visualKey
    if visualCurrent and visualCurrent.type == "swap" then
        visualKey = "swap:" .. tostring(visualCurrent.targetBar or 0)
    else
        visualKey = tostring(visualCurrent and (visualCurrent.sourceAbilityId or visualCurrent.abilityId) or 0) .. ":" .. tostring(visualCurrent and visualCurrent.type or "")
    end
    if self.visualHeldKey ~= visualKey or self.currentVisualX == nil then
        self.visualHeldKey = visualKey
        self.visualPressHoldStartMs = nil
        self.visualPressHoldDoneKey = nil
        local skillPxPerMsInit = math.max(0.05, (entryX - pressX) / gcd)
        if self.visualSwapJustResolved then
            -- AFTER controls only the distance to the next skill. Movement speed stays
            -- identical to a normal skill.
            local afterMs = zo_clamp(tonumber(self.sv.swapTrailMs) or 200, 200, 1000)
            self.currentVisualX = pressX + (skillPxPerMsInit * afterMs)
            self.visualSwapJustResolved = nil
        elseif visualCurrent and visualCurrent.type == "swap" then
            -- BEFORE controls where SWAP enters the visible lane. It does NOT make
            -- SWAP move faster; SWAP travels with the exact same metronome speed.
            local beforeMs = zo_clamp(tonumber(self.sv.swapLeadMs) or 250, 200, 1000)
            self.currentVisualX = pressX + (skillPxPerMsInit * beforeMs)
        else
            self.currentVisualX = entryX
        end
        self.lastVisualUpdateMs = tNow
    end

    local dt = math.max(0, math.min(100, tNow - (self.lastVisualUpdateMs or tNow)))
    self.lastVisualUpdateMs = tNow

    -- v0.6.18: SWAP is a true in-between action. It always moves with the SAME
    -- metronome velocity and the SAME PRESS-zone easing as a skill. BEFORE/AFTER
    -- change only the spacing around it, never its movement speed.
    local isSwapCurrent = visualCurrent and visualCurrent.type == "swap"
    local skillPxPerMs = math.max(0.05, (entryX - pressX) / gcd)
    local swapBeforeMs = zo_clamp(tonumber(self.sv.swapLeadMs) or 250, 200, 1000)
    local swapAfterMs = zo_clamp(tonumber(self.sv.swapTrailMs) or 200, 200, 1000)
    local basePxPerMs = skillPxPerMs
    local distToPress = self.currentVisualX - pressX
    local speedFactor = 1.0

    if not (self.sv.fixedFlowSpeed == true) then
        if distToPress > 0 and distToPress <= 90 then
            local n = distToPress / 90
            speedFactor = 0.28 + 0.72 * n
        elseif distToPress <= 0 then
            -- Existing adaptive/missed-action slowdown remains available when FIXED is OFF.
            self.heldReachedPress = true
            local latePx = math.max(0, -distToPress)
            local lateN = zo_clamp(latePx / 150, 0, 1)
            speedFactor = 0.28 - ((0.28 - MISSED_MIN_SPEED) * lateN)
        end
    end

    -- Optional v0.6.20 recognition hold:
    -- When CURRENT first reaches PRESS, keep it pixel-stable exactly on pressX for
    -- 200 ms. This is purely visual: planner/GCD/ability recognition keep running.
    -- The hold happens only once per visual item, then movement resumes normally.
    local pressHoldEnabled = (self.sv.pressVisualHoldEnabled == true)
    local pressHoldMs = zo_clamp(tonumber(self.sv.pressVisualHoldMs) or 200, 50, 500)
    local holdActive = false

    if pressHoldEnabled and self.visualPressHoldStartMs and self.visualPressHoldDoneKey ~= visualKey then
        local holdElapsed = tNow - self.visualPressHoldStartMs
        if holdElapsed < pressHoldMs then
            self.currentVisualX = pressX
            holdActive = true
        else
            self.visualPressHoldStartMs = nil
            self.visualPressHoldDoneKey = visualKey
        end
    end

    if not holdActive then
        local proposedX = self.currentVisualX - (basePxPerMs * speedFactor * dt)

        if pressHoldEnabled
            and self.visualPressHoldDoneKey ~= visualKey
            and self.currentVisualX > pressX
            and proposedX <= pressX then
            self.currentVisualX = pressX
            self.visualPressHoldStartMs = tNow
            holdActive = true
        else
            self.currentVisualX = proposedX
        end
    end

    local currentX = self.currentVisualX
    self.currentHeldX = currentX


    -- NEXT follows continuously behind CURRENT instead of being pinned to a midpoint.
    -- It starts one runway length to the right and inherits the same physical motion.
    local nextX
    local thirdX
    -- v0.6.19: Keep every visible card physically side-by-side. The configured
    -- BEFORE/AFTER values still define the desired timing distance, but if that
    -- distance would make two cards overlap we enforce one card width + a small gap.
    -- Nothing is sped up; this only changes the visual spacing of the previews.
    local holderWidth = self.sv.iconSize + 8
    local minVisualGap = holderWidth + FLOW_ITEM_GAP_PX

    if isSwapCurrent then
        -- SWAP -> skill: compact AFTER spacing, but never overlap.
        nextX = currentX + math.max(skillPxPerMs * swapAfterMs, minVisualGap)
        if visualThird then
            thirdX = nextX + math.max((farRightX - entryX), minVisualGap)
        end
    elseif visualNext and visualNext.type == "swap" then
        -- skill -> SWAP -> skill: three cards remain in one clean row.
        nextX = currentX + math.max(skillPxPerMs * swapBeforeMs, minVisualGap)
        if visualThird then
            thirdX = nextX + math.max(skillPxPerMs * swapAfterMs, minVisualGap)
        end
    else
        nextX = currentX + math.max((farRightX - entryX), minVisualGap)
    end

    local fadeActive = false
    local fadeP = 1
    if self.fadingRecommendation and self.fadeStartMs then
        local elapsedFade = now() - self.fadeStartMs
        local holdMs = tonumber(self.fadeHoldMs) or 200
        if elapsedFade < holdMs then
            fadeP = 0
            fadeActive = true
        else
            fadeP = zo_clamp((elapsedFade - holdMs) / (self.fadeDurationMs or 260), 0, 1)
            if fadeP < 1 then fadeActive = true else self:ClearFadeRecommendation() end
        end
    end

    local h1, h2, h3 = self.flowIcons[1], self.flowIcons[2], self.flowIcons[3]
    if fadeActive then
        local eased = 1 - ((1 - fadeP) * (1 - fadeP))
        local fromX = self.fadeFromX or pressX
        local fx = fromX + (leftX - fromX) * eased
        setHolder(h1, self.fadingRecommendation, fx, false, 1 - fadeP)
        if visualCurrent then
            local leadMs = isSwapCurrent and swapBeforeMs or (tonumber(self.sv.skillDetectLeadMs) or 250)
            local trailMs = isSwapCurrent and zo_clamp(tonumber(self.sv.swapTrailMs) or 200, 200, 1000) or (tonumber(self.sv.skillDetectTrailMs) or 200)
            local leadPx = basePxPerMs * leadMs
            local trailPx = basePxPerMs * trailMs
            local inPressZone = (currentX <= (pressX + leadPx) and currentX >= (pressX - trailPx))
            setHolder(h2, visualCurrent, currentX, inPressZone, 1)
        else
            h2:SetHidden(true)
        end
        if visualThird and thirdX then setHolder(h3, visualThird, thirdX, false, 1) else h3:SetHidden(true) end
    else
        if visualCurrent then
            local leadMs = isSwapCurrent and swapBeforeMs or (tonumber(self.sv.skillDetectLeadMs) or 250)
            local trailMs = isSwapCurrent and zo_clamp(tonumber(self.sv.swapTrailMs) or 200, 200, 1000) or (tonumber(self.sv.skillDetectTrailMs) or 200)
            local leadPx = basePxPerMs * leadMs
            local trailPx = basePxPerMs * trailMs
            local inPressZone = (currentX <= (pressX + leadPx) and currentX >= (pressX - trailPx))
            setHolder(h1, visualCurrent, currentX, inPressZone, 1)
        else
            h1:SetHidden(true)
        end
        if visualNext then setHolder(h2, visualNext, nextX, false, 1) else h2:SetHidden(true) end
        if visualThird and thirdX then setHolder(h3, visualThird, thirdX, false, 1) else h3:SetHidden(true) end
    end

    -- Heavy Attack is a 2.2 s controller channel. Because it is not an action-bar
    -- slot event, advance it by channel time once it reaches PRESS. This keeps the
    -- coach on HOLD RT for the full channel instead of waiting for a keyboard/mouse event.
    if visualCurrent and visualCurrent.type == "heavyAttack" and self.currentVisualX then
        if math.abs(self.currentVisualX - pressX) <= 3 and not self.heavyAttackChannelStartMs then
            self.heavyAttackChannelStartMs = tNow
            self.currentVisualX = pressX
        end
        if self.heavyAttackChannelStartMs then
            self.currentVisualX = pressX
            if (tNow - self.heavyAttackChannelStartMs) >= (tonumber(visualCurrent.channelMs) or HEAVY_ATTACK_CHANNEL_MS) then
                local doneAt = tNow
                self:SetTimer(HEAVY_ATTACK_ID, HEAVY_ATTACK_CHANNEL_MS, doneAt)
                self:RemoveFromDynamicLockQueueByAbility(HEAVY_ATTACK_ID)
                self.lastActionMs = doneAt
                if self.sv.rotationMode == "static" then self:AdvanceStaticStep() end
                self:StartFadeRecommendation(self.heldRecommendation, doneAt)
                self:ClearHeldRecommendation()
                self.heavyAttackChannelStartMs = nil
                return
            end
        end
    else
        self.heavyAttackChannelStartMs = nil
    end

    -- The code is only visible while CURRENT is actually at PRESS.
    -- PRESS HOLD keeps this state pixel-stable long enough for the external reader.
    local codeActive = false
    if visualCurrent and self.currentVisualX then
        codeActive = math.abs(self.currentVisualX - pressX) <= 3
    end

    local codeLabel = nil
    if visualCurrent then
        if visualCurrent.type == "swap" then
            codeLabel = "SWAP"
        else
            codeLabel = self:GetStableDisplayLabel(visualCurrent)
            if visualCurrent.type == "ultimate" then codeLabel = "ULT" end
        end
    end
    -- Legacy 3-bit marker disabled; v0.6.25 uses the white recognition image box.

    self.status:SetText("")
    if self.config and not self.config:IsHidden() and self.ultimateResourceLabel then self:RefreshUltimateDisplay() end
end

function SRT:SelectHotbarSkill(abilityId, slotIndex, hotbar)
    if not abilityId or abilityId == 0 then return end
    self.selectedHotbarSkill = {
        abilityId = abilityId,
        slotIndex = slotIndex,
        hotbar = hotbar,
    }
    if self.selectedSkillLabel then
        self.selectedSkillLabel:SetText("Selected: " .. abilityName(abilityId) .. "  [" .. barText(hotbar) .. " / " .. slotInputLabel(slotIndex) .. "]")
    end
    self:RefreshHotbarPicker()
end

function SRT:SetRoleFromSelected(kind, index)
    local selected = self.selectedHotbarSkill
    if not selected or not selected.abilityId or selected.abilityId == 0 then
        msg("Select a skill from FRONT BAR or BACK BAR first.")
        return
    end

    local s = {
        abilityId = selected.abilityId,
        slotIndex = selected.slotIndex,
        hotbar = selected.hotbar,
    }

    if kind == "spammable" then
        self.sv.spammable = s
    elseif kind == "execute" then
        self.sv.execute = s
    elseif kind == "priority" and index then
        local oldPriority = self.sv.priorities[index]
        s.earlyMs = (oldPriority and oldPriority.earlyMs) or 0
        s.manualDurationMs = (oldPriority and oldPriority.manualDurationMs) or 0
        self.sv.priorities[index] = s
    end

    if kind == "spammable" then
        self.sv.spammable = s
    elseif kind == "execute" then
        self.sv.execute = s
    elseif kind == "ultimate" then
        self.sv.ultimate = s
    elseif kind == "priority" and index then
        local oldPriority = self.sv.priorities[index]
        s.earlyMs = (oldPriority and oldPriority.earlyMs) or 0
        s.manualDurationMs = (oldPriority and oldPriority.manualDurationMs) or 0
        self.sv.priorities[index] = s
    end

    self:RefreshBarMap()
    self:RefreshConfig()
    msg("Assigned " .. abilityName(s.abilityId) .. " to " .. tostring(kind) .. (index and (" #" .. index) or ""))
end

function SRT:RefreshHotbarPicker()
    if not self.hotbarButtons then return end
    for _, hotbar in ipairs({HOTBAR_PRIMARY, HOTBAR_BACKUP}) do
        local group = self.hotbarButtons[hotbar]
        if group then
            for _, slot in ipairs(hotbarSlots()) do
                local entry = group[slot]
                if entry then
                    local id = GetSlotBoundId(slot, hotbar)
                    entry.abilityId = id
                    entry.icon:SetTexture(abilityIcon(id))
                    entry.nameLabel:SetText(id and id > 0 and abilityName(id) or "Empty")
                    local selected = self.selectedHotbarSkill
                    local isSelected = selected and selected.hotbar == hotbar and selected.slotIndex == slot
                    if isSelected then
                        entry.frame:SetCenterColor(0.05, 0.40, 0.08, 0.65)
                        entry.frame:SetEdgeColor(0.2, 1.0, 0.25, 1)
                    else
                        entry.frame:SetCenterColor(0, 0, 0, 0.35)
                        entry.frame:SetEdgeColor(0.45, 0.45, 0.45, 0.95)
                    end
                end
            end
        end
    end
end

function SRT:SetLearn(kind, index)
    self.learnTarget = {kind = kind, index = index}
    msg("Learning " .. tostring(kind) .. (index and (" #" .. index) or "") .. ": press the desired skill now.")
    self:CloseConfig()
end

function SRT:ApplyLearnedSkill(id, slotIndex, hb)
    local t = self.learnTarget
    if not t then return false end
    local s = {abilityId = id, slotIndex = slotIndex, hotbar = hb}
    if t.kind == "spammable" then
        self.sv.spammable = s
    elseif t.kind == "execute" then
        self.sv.execute = s
    elseif t.kind == "ultimate" then
        self.sv.ultimate = s
    elseif t.kind == "priority" and t.index then
        s.earlyMs = (self.sv.priorities[t.index] and self.sv.priorities[t.index].earlyMs) or 0
        self.sv.priorities[t.index] = s
    end
    self.learnTarget = nil
    self:RefreshBarMap()
    self:RefreshConfig()
    msg("Learned: " .. abilityName(id))
    return true
end

function SRT:OnAbilityUsed(slotIndex)
    -- Any actual ultimate cast triggers a hard 10-second planner lock.
    -- ESO can briefly report stale ultimate power immediately after casting.
    if slotIndex == ULTIMATE_SLOT then
        self:LockUltimateForTenSeconds()
    end

    local hb = currentBar()
    -- EVENT_ACTION_SLOT_ABILITY_USED already identifies the physical slot. Resolve
    -- both the live id and the configured skill occupying that exact slot/bar.
    local id = GetSlotBoundId(slotIndex, hb)
    if not id or id == 0 then id = GetSlotBoundId(slotIndex) end
    local slotRole, slotPriority, slotSkill, slotSourceId = self:GetConfiguredRoleForSlot(slotIndex, hb)
    if (not id or id == 0) and slotSourceId then id = slotSourceId end
    if not id or id == 0 then return end

    -- Prevent an accidental double press from restarting the same timer and putting
    -- the skill back into the queue. 650 ms is safely below the 1000 ms coach floor,
    -- so legitimate next-GCD uses (e.g. a spammable) are still accepted.
    self.lastAbilityPressMs = self.lastAbilityPressMs or {}
    local pressNow = now()
    local previousPress = self.lastAbilityPressMs[id]
    if previousPress and (pressNow - previousPress) < 650 then
        return
    end
    self.lastAbilityPressMs[id] = pressNow

    if slotIndex == ULTIMATE_SLOT then
        self.lastUltimateUseMs = now()
        self.lastUltimatePoints = getUltimatePoints()
        if self.heldRecommendation and self.heldRecommendation.type == "ultimate" then
            self:StartFadeRecommendation(self.heldRecommendation, self.lastUltimateUseMs)
            self:ClearHeldRecommendation()
        end
    end

    if self.learnTarget and self:ApplyLearnedSkill(id, slotIndex, hb) then return end

    local pressTime = pressNow
    if self.testMode then
        self:HandleTestAbility(id, hb, pressTime)
        return
    end
    if not self.inCombat then return end

    local cadenceDelta = self:RecordRhythmPress(pressTime)
    -- v0.5.8-style stable recognition:
    -- First resolve by the configured ability id. This keeps a running recast attached
    -- to the same configured priority across weapon swaps. Slot + active bar is only a
    -- fallback for morph/proc cases where ESO reports a different live ability id.
    local role, priority, configuredSkill, sourceId = self:GetConfiguredRoleForAbility(id)
    if not role then
        role, priority, configuredSkill, sourceId = slotRole, slotPriority, slotSkill, slotSourceId
    end

    -- Whatever path recognized the press, always key the timer to the stable configured
    -- skill id rather than the temporary live/proc/slot id.
    if configuredSkill and configuredSkill.abilityId then
        sourceId = configuredSkill.abilityId
    end

    -- DYNAMIC MODE: every real press of a configured ability is authoritative, even
    -- when it was much earlier than the trainer expected. Restart its rotation timer
    -- immediately so BuildRoute pushes that skill back until its next recast window.
    if self.sv.rotationMode ~= "static" and role and sourceId then
        -- A real cast consumes this recommendation even when it was pressed early.
        -- Its new timer is authoritative and the three-skill lock advances by one.
        self:RemoveFromDynamicLockQueueByAbility(sourceId)
        local duration = self:GetRotationDurationMs(sourceId)
        if duration > 0 then
            self:SetTimer(sourceId, duration)
            -- The cast timer is authoritative. A normal configured skill must not remain
            -- "ready" because of a stale proc flag or a live slot-id variation.
            if self.procReady then
                for procId, baseId in pairs(PROC_BASE_BY_PROC) do
                    if baseId == sourceId then self.procReady[procId] = false end
                end
            end
            -- A newly pressed skill supersedes a stale ESO effect end-time from its
            -- previous cast until EVENT_EFFECT_CHANGED supplies the new real timer.
            if self.esoEffectTimers then self.esoEffectTimers[sourceId] = nil end
        end
    end

    local matchedHeld = self.heldRecommendation and self:RecommendationMatchesAbility(self.heldRecommendation, id)
    local earlyAccepted = false
    if self.heldRecommendation and not matchedHeld then
        local heldIsFiller = self.heldRecommendation.type == "spammable" or self.heldRecommendation.type == "execute"
        if heldIsFiller then earlyAccepted = self:IsEarlyAcceptable(id, pressTime) end
    elseif not self.heldRecommendation then
        earlyAccepted = self:IsEarlyAcceptable(id, pressTime)
    end

    if self.heldRecommendation then
        local target = self:GetAdaptiveRhythmMs()
        local timely = cadenceDelta == nil or cadenceDelta <= (target + 180)
        self:RecordPerformanceResult((matchedHeld and timely) or earlyAccepted)
    elseif earlyAccepted then
        self:RecordPerformanceResult(true)
    end

    if matchedHeld then
        self:RemoveFromDynamicLockQueueByAbility(self.heldRecommendation.sourceAbilityId or self.heldRecommendation.abilityId)
        self.lastActionMs = pressTime
        if self.sv.rotationMode == "static" then self:AdvanceStaticStep() end
        self:StartFadeRecommendation(self.heldRecommendation, pressTime)
        self:ClearHeldRecommendation()
    elseif earlyAccepted then
        self.lastActionMs = pressTime
        self:StartFadeRecommendation({
            abilityId = id,
            sourceAbilityId = configuredSkill and configuredSkill.abilityId or id,
            priority = priority or 99,
            type = role,
            skill = configuredSkill,
        }, pressTime)
        self:ClearHeldRecommendation()
    elseif role and self.sv.rotationMode ~= "static" then
        -- Even a very early configured press is recognized. Do not falsely advance a
        -- different held recommendation, but the pressed skill has already been
        -- rescheduled above and will disappear from NEXT until its timer is due again.
        self.lastActionMs = pressTime
    elseif not self.heldRecommendation then
        self.lastActionMs = pressTime
    end

    if self:IsConfiguredAbility(id) or sourceId then
        -- Consuming either a base skill or its proc clears the corresponding ready state.
        local consumedBase = sourceId or PROC_BASE_BY_PROC[id] or id
        for procId, baseId in pairs(PROC_BASE_BY_PROC) do
            if baseId == consumedBase then self.procReady[procId] = false end
        end
    end
end

function SRT:ClearRole(kind, index)
    if kind == "spammable" then
        self.sv.spammable = nil
    elseif kind == "execute" then
        self.sv.execute = nil
    elseif kind == "ultimate" then
        self.sv.ultimate = nil
    elseif kind == "priority" and index then
        self.sv.priorities[index] = nil
    end
    self:RefreshConfig()
end

function SRT:CycleEarly(index)
    local s = self.sv.priorities[index]
    if not s then return end
    local current = tonumber(s.earlyMs) or 0
    if current < 1000 then current = 1000
    elseif current < 2000 then current = 2000
    else current = 0 end
    s.earlyMs = current
    self:RefreshConfig()
end

function SRT:AdjustRecast(index, deltaSeconds)
    local sk = self.sv.priorities[index]
    if not sk then return end
    local current = tonumber(sk.manualDurationMs) or 0
    local delta = (tonumber(deltaSeconds) or 0) * 1000

    if current <= 0 and delta > 0 then
        -- Start from the best timer ESO has learned, rounded to a whole second.
        local learned = self:GetRotationDurationMs(sk.abilityId)
        current = math.max(1000, math.floor((learned + 500) / 1000) * 1000)
    else
        current = current + delta
    end

    if current < 1000 then current = 0 end -- AUTO
    sk.manualDurationMs = zo_clamp(current, 0, 120000)
    self:RefreshConfig()
end

function SRT:ClearManualRecast(index)
    local sk = self.sv.priorities[index]
    if not sk then return end
    sk.manualDurationMs = 0
    self:RefreshConfig()
end

function SRT:AdjustGcd(delta)
    -- Manual GCD adjustment is an immediate coach target, not just a hidden base value.
    -- Keep the hard 1.00 s floor requested for training.
    local current = tonumber(self.sv.adaptiveRhythmMs) or tonumber(self.sv.gcdMs) or 1000
    local value = zo_clamp(current + (tonumber(delta) or 0), 1000, 1500)
    self.sv.gcdMs = value
    self.sv.adaptiveRhythmMs = value
    -- A manual change becomes the new calibrated starting point. Existing 20-sample
    -- history is kept for statistics, while the performance coach may still adjust
    -- slowly from this value later.
    self.sv.rhythmCalibrated = true
    self:RefreshConfig()
end

function SRT:AdjustExecuteHp(delta)
    self.sv.executeHp = zo_clamp((tonumber(self.sv.executeHp) or 25) + delta, 1, 100)
    self:RefreshConfig()
end

function SRT:CreateRoutePreview()
    if self.routePreview then return end

    local w = WM:CreateTopLevelWindow("SRT_RoutePreview")
    w:SetDimensions(1180, 820)
    w:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    w:SetHidden(true)
    w:SetMouseEnabled(true)
    w:SetClampedToScreen(true)

    local bg = WM:CreateControl("SRT_RoutePreviewBG", w, CT_BACKDROP)
    bg:SetAnchorFill(w)
    bg:SetCenterColor(0.02, 0.02, 0.025, 0.97)
    bg:SetEdgeColor(0.2, 0.8, 1, 1)
    bg:SetEdgeTexture("", 2, 2, 2)

    label(w, "SRT_RoutePreviewTitle", 22, 14, 900, 42, FONT_TITLE, "NEXT 20 SKILLS - HOTBAR PLANNER")
    label(w, "SRT_RoutePreviewHint", 22, 58, 1110, 54, FONT_TEXT,
        "Preview of the next 20 planned actions. Use BAR + KEY to arrange skills so frequent transitions need as few bar swaps as possible.")

    self.routePreviewRows = {}
    for i = 1, 20 do
        local col = (i <= 10) and 0 or 1
        local row = (i - 1) % 10
        local x = 24 + col * 565
        local y = 126 + row * 54

        local num = label(w, "SRT_RoutePrevNum" .. i, x, y, 42, 46, FONT_HEADER, tostring(i) .. ".")
        local icon = WM:CreateControl("SRT_RoutePrevIcon" .. i, w, CT_TEXTURE)
        icon:SetAnchor(TOPLEFT, w, TOPLEFT, x + 46, y)
        icon:SetDimensions(44, 44)
        local name = label(w, "SRT_RoutePrevName" .. i, x + 98, y, 300, 44, FONT_TEXT, "-")
        local bar = label(w, "SRT_RoutePrevBar" .. i, x + 400, y, 86, 44, FONT_SMALL, "-")
        local key = label(w, "SRT_RoutePrevKey" .. i, x + 488, y, 68, 44, FONT_HEADER, "-")
        self.routePreviewRows[i] = {num=num, icon=icon, name=name, bar=bar, key=key}
    end

    self.routePreviewFront = label(w, "SRT_RoutePreviewFront", 24, 682, 1110, 34, FONT_TEXT, "FRONT: -")
    self.routePreviewBack = label(w, "SRT_RoutePreviewBack", 24, 720, 1110, 34, FONT_TEXT, "BACK: -")
    self.routePreviewSwap = label(w, "SRT_RoutePreviewSwaps", 24, 758, 800, 34, FONT_HEADER, "Estimated bar swaps: 0")
    button(w, "SRT_RoutePreviewClose", 968, 758, 180, 38, "CLOSE", function() w:SetHidden(true) end)

    self.routePreview = w
end

function SRT:RefreshRoutePreview()
    self:CreateRoutePreview()
    local route = self:BuildRoute(20)
    local front, back = {}, {}
    local seenFront, seenBack = {}, {}
    local swaps = 0
    local lastBar = nil

    for i = 1, 20 do
        local row = self.routePreviewRows[i]
        local item = route[i]
        if item and item.abilityId and item.abilityId > 0 then
            local skill = item.skill or {}
            local hotbar = skill.hotbar or self.abilityBars[item.sourceAbilityId] or self.abilityBars[item.abilityId]
            local slot = skill.slotIndex or self.abilitySlots[item.sourceAbilityId] or self.abilitySlots[item.abilityId]
            row.icon:SetTexture(abilityIcon(item.abilityId))
            row.name:SetText(abilityName(item.abilityId))
            row.bar:SetText(barText(hotbar))
            row.key:SetText(slot and slotInputLabel(slot) or "?")

            if hotbar then
                if lastBar and hotbar ~= lastBar then swaps = swaps + 1 end
                lastBar = hotbar
                local key = tostring(item.sourceAbilityId or item.abilityId)
                if hotbar == HOTBAR_PRIMARY and not seenFront[key] then
                    table.insert(front, abilityName(item.sourceAbilityId or item.abilityId))
                    seenFront[key] = true
                elseif hotbar == HOTBAR_BACKUP and not seenBack[key] then
                    table.insert(back, abilityName(item.sourceAbilityId or item.abilityId))
                    seenBack[key] = true
                end
            end
        else
            row.icon:SetTexture("/esoui/art/icons/icon_missing.dds")
            row.name:SetText("-")
            row.bar:SetText("-")
            row.key:SetText("-")
        end
    end

    self.routePreviewFront:SetText("FRONT used: " .. (#front > 0 and table.concat(front, ", ") or "none"))
    self.routePreviewBack:SetText("BACK used: " .. (#back > 0 and table.concat(back, ", ") or "none"))
    self.routePreviewSwap:SetText("Estimated bar swaps in 20 actions: " .. tostring(swaps))
end

function SRT:OpenRoutePreview()
    self:RefreshBarMap()
    self:RefreshRoutePreview()
    self.routePreview:SetHidden(false)
end

function SRT:ToggleRotationMode()
    if self.sv.rotationMode == "static" then
        self.sv.rotationMode = "dynamic"
        self:ResetDynamicLockQueue()
        msg("Rotation mode: DYNAMIC")
    else
        self.sv.rotationMode = "static"
        self:ResetDynamicLockQueue()
        self.staticStepIndex = 1
        self:ClearHeldRecommendation()
        self:ClearFadeRecommendation()
        msg("Rotation mode: STATIC (Priority 1-10 fixed sequence)")
    end
    self:RefreshConfig()
end


-- v0.6.23: 3-bit machine code in the existing PRESS frame.
-- Four tiny 3x3 blocks are used:
--   sync + bit1 + bit2 + bit3
-- The sync block is a unique muted cyan. Bits are two different gray levels.
-- This is far more robust than reading moving text or ability icons.
local AHK_CODE_SYNC = {0.275, 0.620, 0.745} -- approx #469EBD
local AHK_CODE_ZERO = {0.220, 0.220, 0.220} -- approx #383838
local AHK_CODE_ONE  = {0.620, 0.620, 0.620} -- approx #9E9E9E

local AHK_ACTION_CODE = {
    ["1"]    = 1, -- 001
    ["2"]    = 2, -- 010
    ["3"]    = 3, -- 011
    ["4"]    = 4, -- 100
    ["5"]    = 5, -- 101
    ["SWAP"] = 6, -- 110
    ["ULT"]  = 7, -- 111
}

function SRT:ToggleAhkDataCode()
    self.sv.ahkDataCodeEnabled = not (self.sv.ahkDataCodeEnabled == true)
    msg("AHK data code: " .. ((self.sv.ahkDataCodeEnabled == true) and "ON" or "OFF"))
    if not self.sv.ahkDataCodeEnabled then
        self:SetAhkDataCode(nil, false)
    end
    self:RefreshConfig()
end

function SRT:EnsureAhkDataCode()
    if self.ahkCodeControls then return end
    if not self.hitZone then return end

    self.ahkCodeControls = {}
    for i = 1, 4 do
        local c = WM:CreateControl("SRT_AhkCode" .. tostring(i), self.hitZone, CT_BACKDROP)
        c:SetDimensions(3, 3)
        c:SetAnchor(TOPLEFT, self.hitZone, TOPLEFT, 5 + ((i - 1) * 5), 3)
        c:SetCenterColor(0.22, 0.22, 0.22, 1)
        c:SetEdgeColor(0, 0, 0, 0)
        c:SetHidden(true)
        self.ahkCodeControls[i] = c
    end
end

function SRT:SetAhkDataCode(actionLabel, active)
    self:EnsureAhkDataCode()
    if not self.ahkCodeControls then return end

    if not (self.sv and self.sv.ahkDataCodeEnabled == true) or not active then
        for i = 1, 4 do self.ahkCodeControls[i]:SetHidden(true) end
        return
    end

    local code = AHK_ACTION_CODE[tostring(actionLabel or "")]
    if not code then
        for i = 1, 4 do self.ahkCodeControls[i]:SetHidden(true) end
        return
    end

    local sync = self.ahkCodeControls[1]
    sync:SetCenterColor(AHK_CODE_SYNC[1], AHK_CODE_SYNC[2], AHK_CODE_SYNC[3], 1)
    sync:SetHidden(false)

    -- MSB -> LSB: bit1, bit2, bit3
    local masks = {4, 2, 1}
    for i = 1, 3 do
        local on = (math.floor(code / masks[i]) % 2) == 1
        local col = on and AHK_CODE_ONE or AHK_CODE_ZERO
        local c = self.ahkCodeControls[i + 1]
        c:SetCenterColor(col[1], col[2], col[3], 1)
        c:SetHidden(false)
    end
end



function SRT:ToggleAhkColorMarkers()
    self.sv.ahkColorMarkersEnabled = not (self.sv.ahkColorMarkersEnabled == true)
    msg("AHK color markers: " .. ((self.sv.ahkColorMarkersEnabled == true) and "ON" or "OFF"))
    self:RefreshConfig()
end

function SRT:SetPressFrameStyle(holder)
    if not holder or not holder.frame then return end
    -- v0.6.22: PRESS no longer turns green. A neutral dark frame keeps the
    -- machine-readable RGB text unchanged for AHK PixelSearch.
    holder.frame:SetCenterColor(0.08, 0.08, 0.08, 0.72)
    holder.frame:SetEdgeColor(0.65, 0.65, 0.65, 1)
end

function SRT:SetActionTextColor(labelControl, actionLabel)
    if not labelControl then return end
    if self.sv and self.sv.ahkColorMarkersEnabled == true then
        local c = AHK_ACTION_COLORS[tostring(actionLabel or "")]
        if c then
            labelControl:SetColor(c[1], c[2], c[3], 1)
            return
        end
    end
    labelControl:SetColor(1, 1, 1, 1)
end

function SRT:TogglePressVisualHold()
    self.sv.pressVisualHoldEnabled = not (self.sv.pressVisualHoldEnabled == true)
    -- Reset the current one-shot hold state so the new setting takes effect cleanly.
    self.visualPressHoldStartMs = nil
    self.visualPressHoldDoneKey = nil
    msg("PRESS visual hold: " .. ((self.sv.pressVisualHoldEnabled == true) and "ON (200 ms)" or "OFF"))
    self:RefreshConfig()
end

function SRT:AdjustSwapTiming(which, delta)
    local field = (which == "after") and "swapTrailMs" or "swapLeadMs"
    local current = tonumber(self.sv[field]) or ((field == "swapTrailMs") and 200 or 250)
    self.sv[field] = zo_clamp(current + (tonumber(delta) or 0), 200, 1000)
    self:RefreshConfig()
end

function SRT:CreateConfig()
    local w = WM:CreateTopLevelWindow("SRT_Config")
    w:SetDimensions(1080, 1050)
    w:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    w:SetHidden(true)
    w:SetMouseEnabled(true)
    w:SetMovable(true)
    w:SetClampedToScreen(true)

    local bg = WM:CreateControl("SRT_ConfigBG", w, CT_BACKDROP)
    bg:SetAnchorFill(w)
    bg:SetCenterColor(0.03, 0.03, 0.04, 0.97)
    bg:SetEdgeColor(0.2, 0.7, 1, 1)
    bg:SetEdgeTexture("", 2, 2, 2)

    label(w, "SRT_ConfigTitle", 18, 10, 850, 38, FONT_TITLE, "Rotation Trainer - Route Planner")
    label(w, "SRT_ConfigHint", 18, 48, 930, 30, FONT_TEXT,
        "DYNAMIC = timer planner. STATIC = fixed Priority 1-10 sequence. Select a hotbar skill, then press SET.")

    label(w, "SRT_GcdTitle", 18, 82, 100, 30, FONT_HEADER, "GCD:")
    self.gcdLabel = label(w, "SRT_GcdValue", 112, 82, 110, 30, FONT_HEADER, "")
    button(w, "SRT_GcdMinus", 226, 82, 60, 30, "-50", function() self:AdjustGcd(-50) end)
    button(w, "SRT_GcdPlus", 292, 82, 60, 30, "+50", function() self:AdjustGcd(50) end)

    label(w, "SRT_ExecHpTitle", 400, 82, 150, 30, FONT_HEADER, "Execute HP:")
    self.execHpLabel = label(w, "SRT_ExecHpValue", 545, 82, 90, 30, FONT_HEADER, "")
    button(w, "SRT_ExecHpMinus", 640, 82, 55, 30, "-5", function() self:AdjustExecuteHp(-5) end)
    button(w, "SRT_ExecHpPlus", 700, 82, 55, 30, "+5", function() self:AdjustExecuteHp(5) end)

    label(w, "SRT_ModeTitle", 780, 82, 90, 30, FONT_HEADER, "MODE:")
    self.modeButton = button(w, "SRT_ModeButton", 870, 82, 170, 30, "DYNAMIC", function() self:ToggleRotationMode() end)

    -- BAR SWAP uses normal skill movement; these values control only the compact spacing around it.
    -- skill GCD. Both sides are adjustable from 200 ms to 1000 ms in 50 ms steps.
    label(w, "SRT_SwapTimingTitle", 18, 122, 160, 30, FONT_HEADER, "SWAP TIMING:")
    label(w, "SRT_SwapBeforeTitle", 185, 122, 95, 30, FONT_TEXT, "BEFORE")
    self.swapLeadLabel = label(w, "SRT_SwapBeforeValue", 278, 122, 90, 30, FONT_HEADER, "")
    button(w, "SRT_SwapBeforeMinus", 372, 122, 55, 30, "-50", function() self:AdjustSwapTiming("before", -50) end)
    button(w, "SRT_SwapBeforePlus", 432, 122, 55, 30, "+50", function() self:AdjustSwapTiming("before", 50) end)

    label(w, "SRT_SwapAfterTitle", 530, 122, 80, 30, FONT_TEXT, "AFTER")
    self.swapTrailLabel = label(w, "SRT_SwapAfterValue", 610, 122, 90, 30, FONT_HEADER, "")
    button(w, "SRT_SwapAfterMinus", 704, 122, 55, 30, "-50", function() self:AdjustSwapTiming("after", -50) end)
    button(w, "SRT_SwapAfterPlus", 764, 122, 55, 30, "+50", function() self:AdjustSwapTiming("after", 50) end)
    label(w, "SRT_SwapTimingRange", 835, 122, 205, 30, FONT_SMALL, "200 - 1000 ms")

    label(w, "SRT_PressHoldTitle", 18, 154, 235, 30, FONT_HEADER, "PRESS HOLD (200 ms):")
    self.pressHoldButton = button(w, "SRT_PressHoldButton", 255, 154, 150, 30, "ON", function() self:TogglePressVisualHold() end)
    label(w, "SRT_PressHoldHint", 420, 154, 180, 30, FONT_SMALL, "Pixel-stable at PRESS")

    label(w, "SRT_AhkColorTitle", 610, 154, 145, 30, FONT_HEADER, "AHK COLORS:")
    self.ahkColorButton = button(w, "SRT_AhkColorButton", 755, 154, 120, 30, "ON", function() self:ToggleAhkColorMarkers() end)
    label(w, "SRT_AhkColorHint", 885, 154, 150, 30, FONT_SMALL, "fixed RGB")

    label(w, "SRT_FixedSpeedTitle", 895, 186, 75, 30, FONT_TEXT, "SPEED")
    self.fixedSpeedButton = button(w, "SRT_FixedSpeedButton", 970, 186, 90, 30, "ADAPT", function() self:ToggleFixedFlowSpeed() end)

    self.specialRows = {}
    local function createSpecial(kind, title, y)
        label(w, "SRT_" .. kind .. "Title", 18, y, 150, 34, FONT_HEADER, title)
        local ic = WM:CreateControl("SRT_" .. kind .. "Icon", w, CT_TEXTURE)
        ic:SetAnchor(TOPLEFT, w, TOPLEFT, 175, y)
        ic:SetDimensions(34, 34)
        local nm = label(w, "SRT_" .. kind .. "Name", 218, y, 420, 34, FONT_TEXT, "Empty")
        local br = label(w, "SRT_" .. kind .. "Bar", 642, y, 75, 34, FONT_TEXT, "-")
        button(w, "SRT_" .. kind .. "Learn", 724, y, 92, 34, "SET", function() self:SetRoleFromSelected(kind) end)
        button(w, "SRT_" .. kind .. "Clear", 824, y, 92, 34, "CLEAR", function() self:ClearRole(kind) end)
        self.specialRows[kind] = {icon = ic, label = nm, bar = br}
    end

    createSpecial("spammable", "SPAMMABLE", 238)
    createSpecial("execute", "EXECUTE", 280)

    -- Dedicated Ultimate row. Ultimate is intentionally separate from the normal
    -- skill picker because it has its own resource pool/cost rules.
    label(w, "SRT_UltimateTitle", 18, 322, 150, 34, FONT_HEADER, "ULTIMATE")
    local ultIcon = WM:CreateControl("SRT_UltimateIcon", w, CT_TEXTURE)
    ultIcon:SetAnchor(TOPLEFT, w, TOPLEFT, 175, 322)
    ultIcon:SetDimensions(34, 34)
    local ultName = label(w, "SRT_UltimateName", 218, 322, 330, 34, FONT_TEXT, "Empty")
    local ultBar = label(w, "SRT_UltimateBar", 552, 322, 82, 34, FONT_TEXT, "-")
    self.ultimateResourceLabel = label(w, "SRT_UltimateResource", 638, 322, 180, 34, FONT_TEXT, "ULT 0 / COST ?")
    button(w, "SRT_UltSetFront", 824, 322, 96, 34, "FRONT", function() self:SetUltimateFromBar(HOTBAR_PRIMARY) end)
    button(w, "SRT_UltSetBack", 924, 322, 96, 34, "BACK", function() self:SetUltimateFromBar(HOTBAR_BACKUP) end)
    self.specialRows.ultimate = {icon = ultIcon, label = ultName, bar = ultBar}

    label(w, "SRT_PriorityHeader", 18, 368, 1020, 34, FONT_HEADER,
        "PRIORITY SKILLS                    BAR      MANUAL RECAST       EARLY      ACTION")

    self.rows = {}
    for i = 1, self.maxPriorities do
        local y = 408 + (i - 1) * 48
        label(w, "SRT_Num" .. i, 18, y, 34, 32, FONT_HEADER, tostring(i))
        local ic = WM:CreateControl("SRT_Icon" .. i, w, CT_TEXTURE)
        ic:SetAnchor(TOPLEFT, w, TOPLEFT, 58, y)
        ic:SetDimensions(32, 32)
        local nm = label(w, "SRT_Label" .. i, 100, y, 330, 32, FONT_TEXT, "Empty")
        local br = label(w, "SRT_Bar" .. i, 434, y, 70, 32, FONT_TEXT, "-")
        local recast = button(w, "SRT_Recast" .. i, 508, y, 112, 32, "AUTO", function() self:ClearManualRecast(i) end)
        button(w, "SRT_RecastMinus" .. i, 624, y, 42, 32, "-", function() self:AdjustRecast(i, -1) end)
        button(w, "SRT_RecastPlus" .. i, 670, y, 42, 32, "+", function() self:AdjustRecast(i, 1) end)
        local early = button(w, "SRT_Early" .. i, 716, y, 104, 32, "EARLY 0s", function() self:CycleEarly(i) end)
        button(w, "SRT_Learn" .. i, 824, y, 82, 32, "SET", function() self:SetRoleFromSelected("priority", i) end)
        button(w, "SRT_Del" .. i, 910, y, 90, 32, "CLEAR", function() self:ClearRole("priority", i) end)
        self.rows[i] = {icon = ic, label = nm, bar = br, recast = recast, early = early}
    end

    label(w, "SRT_HotbarHeader", 18, 812, 1020, 30, FONT_HEADER, "ASSIGN NORMAL SKILLS FROM YOUR HOTBARS")
    self.selectedSkillLabel = label(w, "SRT_SelectedSkill", 18, 842, 1020, 28, FONT_TEXT, "Selected: none")

    self.hotbarButtons = {[HOTBAR_PRIMARY] = {}, [HOTBAR_BACKUP] = {}}

    local function createHotbarRow(hotbar, rowId, title, y)
        label(w, "SRT_HotbarTitle" .. tostring(hotbar), 18, y + 8, 125, 26, FONT_HEADER, title)
        local slots = hotbarSlots()
        for pos, slot in ipairs(slots) do
            local x = 150 + (pos - 1) * 145
            local holder = WM:CreateControl("SRT_HotbarHolder_" .. tostring(rowId) .. "_" .. tostring(pos) .. "_" .. tostring(slot), w, CT_BUTTON)
            holder:SetAnchor(TOPLEFT, w, TOPLEFT, x, y)
            holder:SetDimensions(138, 58)
            holder:SetMouseEnabled(true)

            local frame = WM:CreateControl("SRT_HotbarFrame_" .. tostring(hotbar) .. "_" .. tostring(slot), holder, CT_BACKDROP)
            frame:SetAnchorFill(holder)
            frame:SetCenterColor(0, 0, 0, 0.35)
            frame:SetEdgeColor(0.45, 0.45, 0.45, 0.95)
            frame:SetEdgeTexture("", 2, 2, 2)

            local icon = WM:CreateControl("SRT_HotbarIcon_" .. tostring(hotbar) .. "_" .. tostring(slot), holder, CT_TEXTURE)
            icon:SetAnchor(LEFT, holder, LEFT, 4, 0)
            icon:SetDimensions(48, 48)

            local slotLabel = label(holder, "SRT_HotbarSlot_" .. tostring(hotbar) .. "_" .. tostring(slot), 56, 2, 78, 20, FONT_SMALL, slotInputLabel(slot))
            local nameLabel = label(holder, "SRT_HotbarName_" .. tostring(hotbar) .. "_" .. tostring(slot), 56, 22, 78, 32, FONT_SMALL, "")
            nameLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

            holder.frame = frame
            holder.icon = icon
            holder.nameLabel = nameLabel
            holder:SetHandler("OnClicked", function()
                local id = GetSlotBoundId(slot, hotbar)
                if id and id > 0 then self:SelectHotbarSkill(id, slot, hotbar) end
            end)
            self.hotbarButtons[hotbar][slot] = holder
        end
    end

    createHotbarRow(HOTBAR_PRIMARY, "front", "FRONT BAR", 876)
    createHotbarRow(HOTBAR_BACKUP, "back", "BACK BAR", 936)

    button(w, "SRT_RoutePreviewOpen", 720, 12, 180, 34, "20-SKILL PREVIEW", function() self:OpenRoutePreview() end)
    button(w, "SRT_Close", 910, 12, 140, 34, "CLOSE", function() self:CloseConfig() end)
    self.config = w
end

function SRT:SetUltimateFromBar(hotbar)
    local id = GetSlotBoundId(ULTIMATE_SLOT, hotbar)
    if not id or id == 0 then
        msg("No Ultimate found on " .. barText(hotbar) .. " bar.")
        return
    end
    self.sv.ultimate = {abilityId = id, slotIndex = ULTIMATE_SLOT, hotbar = hotbar}
    self:RefreshBarMap()
    self:RefreshConfig()
    msg("Ultimate assigned: " .. abilityName(id) .. " [" .. barText(hotbar) .. "]")
end

function SRT:RefreshUltimateDisplay()
    local row = self.specialRows and self.specialRows.ultimate
    local s = self.sv.ultimate
    if row then self:RefreshSkillRow(row, s) end
    if self.ultimateResourceLabel then
        local points = math.floor(getUltimatePoints() or 0)
        if s and s.abilityId then
            local cost = math.floor(getUltimateCost(s.abilityId, s.hotbar) or 0)
            if cost > 0 then
                self.ultimateResourceLabel:SetText("ULT " .. points .. " / COST " .. cost)
            else
                self.ultimateResourceLabel:SetText("ULT " .. points .. " / COST ?")
            end
        else
            self.ultimateResourceLabel:SetText("ULT " .. points .. " / no skill")
        end
    end
end

function SRT:RefreshSkillRow(row, s)
    if s and s.abilityId then
        row.icon:SetTexture(abilityIcon(s.abilityId))
        row.label:SetText(abilityName(s.abilityId))
        row.bar:SetText(barText(s.hotbar))
    else
        row.icon:SetTexture("/esoui/art/icons/icon_missing.dds")
        row.label:SetText("Empty")
        row.bar:SetText("-")
    end
end

function SRT:RefreshConfig()
    if self.pressHoldButton then
        self.pressHoldButton:SetText((self.sv.pressVisualHoldEnabled == true) and "ON" or "OFF")
    end
    if self.ahkColorButton then
        self.ahkColorButton:SetText((self.sv.ahkColorMarkersEnabled == true) and "ON" or "OFF")
    end
    if self.fixedSpeedButton then
        self.fixedSpeedButton:SetText((self.sv.fixedFlowSpeed == true) and "FIXED" or "ADAPT")
    end
    if self.modeButton then
        self.modeButton:SetText(self.sv.rotationMode == "static" and "STATIC" or "DYNAMIC")
    end
    if self.swapLeadLabel then
        self.swapLeadLabel:SetText(tostring(zo_clamp(tonumber(self.sv.swapLeadMs) or 250, 200, 1000)) .. " ms")
    end
    if self.swapTrailLabel then
        self.swapTrailLabel:SetText(tostring(zo_clamp(tonumber(self.sv.swapTrailMs) or 200, 200, 1000)) .. " ms")
    end
    if self.gcdLabel then
        local hitRate, hitCount = self:GetHitRate()
        self.gcdLabel:SetText(tostring(self:GetAdaptiveRhythmMs()) .. " ms  •  rhythm " .. tostring(#(self.sv.rhythmSamples or {})) .. "/20  •  hits " .. tostring(math.floor(hitRate * 100 + 0.5)) .. "% (" .. tostring(hitCount) .. "/20)")
    end
    self:RefreshHotbarPicker()
    if self.execHpLabel then self.execHpLabel:SetText(tostring(self.sv.executeHp) .. "%") end
    if self.specialRows then
        self:RefreshSkillRow(self.specialRows.spammable, self.sv.spammable)
        self:RefreshSkillRow(self.specialRows.execute, self.sv.execute)
        self:RefreshUltimateDisplay()
    end
    if not self.rows then return end
    for i = 1, self.maxPriorities do
        local s = self.sv.priorities[i]
        local r = self.rows[i]
        self:RefreshSkillRow(r, s)
        local early = s and (tonumber(s.earlyMs) or 0) or 0
        r.early:SetText("EARLY " .. tostring(math.floor(early / 1000)) .. "s")
        if r.recast then
            local manual = s and (tonumber(s.manualDurationMs) or 0) or 0
            if manual >= 1000 then
                r.recast:SetText(string.format("%.1fs", manual / 1000))
            else
                r.recast:SetText("AUTO")
            end
        end
    end
end

function SRT:OpenConfig()
    if not self.config then return end
    self:RefreshBarMap()
    self:RefreshHotbarPicker()
    self:RefreshConfig()
    self.config:SetHidden(false)
end

function SRT:CloseConfig()
    if self.config then self.config:SetHidden(true) end
end

function SRT:RegisterGameMenuPanel()
    -- v0.6.30: settings live in LibAddonMenu. LibGamepad mirrors that LAM panel
    -- into ESO's controller UI, so we intentionally avoid a second native entry.
    if self.RegisterLAMPanel then self:RegisterLAMPanel() end
end

function SRT:Slash(text)
    text = zo_strlower(text or "")
    if text == "" or text == "config" then
        if self.OpenLAMSettings then
            self:OpenLAMSettings()
        elseif self.config:IsHidden() then
            self:OpenConfig()
        else
            self:CloseConfig()
        end
    elseif text == "legacy" then
        if self.config:IsHidden() then self:OpenConfig() else self:CloseConfig() end
    elseif text == "move" then
        if self.moveMode then self:ExitMoveMode() else self:EnterMoveMode() end
    elseif text == "test" then
        if self.testMode then self:StopRhythmTest(false) else self:StartRhythmTest() end
    elseif text == "dynamic" then
        self.sv.rotationMode = "dynamic"
        self.staticStepIndex = 1
        self:ClearHeldRecommendation()
        self:RefreshConfig()
        msg("Rotation mode: DYNAMIC")
    elseif text == "static" then
        self.sv.rotationMode = "static"
        self.staticStepIndex = 1
        self:ClearHeldRecommendation()
        self:RefreshConfig()
        msg("Rotation mode: STATIC")
    elseif text == "on" then
        self.sv.enabled = true
    elseif text == "off" then
        self.sv.enabled = false
    elseif text == "sync" then
        self:ResetFlow()
    elseif text == "reset" then
        self.sv.x, self.sv.y = defaults.x, defaults.y
        self.main:ClearAnchors()
        self.main:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.sv.x, self.sv.y)
    else
        msg("Commands: /srt config, /srt legacy, /srt move, /srt test, /srt dynamic, /srt static, /srt on, /srt off, /srt reset")
    end
end

function SRT:Initialize()
    self.sv = ZO_SavedVars:NewCharacterIdSettings("SatuveRotationTrainerSavedVariables", 4, nil, defaults)
    -- v0.6.2 widened runway: migrate only the untouched old default hit-zone.
    if tonumber(self.sv.hitZoneX) == 78 then self.sv.hitZoneX = 120 end
    if self.sv.rotationMode ~= "static" then self.sv.rotationMode = "dynamic" end
    self.staticStepIndex = 1
    self:MigrateLegacy()
    self.abilityTimers = {}
    self.esoEffectTimers = {}
    self.procReady = {}
    self.runtimeProcAliases = {}
    self.runtimeProcBaseByProc = {}
    self.barMap = {}
    self.slotMap = {}
    self.inCombat = IsUnitInCombat and IsUnitInCombat("player") or false

    self:CreateMain()
    self:CreateConfig()
    self:RegisterGameMenuPanel()
    self:RefreshBarMap()
    self:RefreshConfig()
    self:ResetFlow()
    self:SyncActivePlayerEffects()
    self:RefreshProcState()
    self.lastUltimatePoints = getUltimatePoints()

    SLASH_COMMANDS["/srt"] = function(t) self:Slash(t) end

    EM:RegisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED,
        function(_, slot) self:OnAbilityUsed(slot) end)
    EM:RegisterForEvent(self.name .. "_Hotbar", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED,
        function() self:QueueHotbarRefresh() end)
    if EVENT_ACTION_SLOT_UPDATED then
        EM:RegisterForEvent(self.name .. "_ProcSlots", EVENT_ACTION_SLOT_UPDATED,
            function()
                self:RefreshRuntimeProcAliases()
                self:QueueHotbarRefresh()
            end)
    end
    EM:RegisterForEvent(self.name .. "_Player", EVENT_PLAYER_ACTIVATED,
        function()
            self:RefreshBarMap()
            self:SetCombatState(IsUnitInCombat and IsUnitInCombat("player") or false)
            self:RegisterGameMenuPanel()
        end)
    EM:RegisterForEvent(self.name .. "_Combat", EVENT_PLAYER_COMBAT_STATE,
        function(_, inCombat) self:SetCombatState(inCombat) end)
    if EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
        EM:RegisterForEvent(self.name .. "_InputMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
            function()
                -- ESO can switch preferred input mode while the trainer is open
                -- or during combat. Labels are computed live; force visible config
                -- controls to refresh as well.
                self:RefreshConfig()
            end)
    end
    if EVENT_POWER_UPDATE then
        EM:RegisterForEvent(self.name .. "_UltimatePower", EVENT_POWER_UPDATE,
            function(_, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
                if unitTag ~= "player" or powerType ~= POWERTYPE_ULTIMATE then return end
                local current = tonumber(powerValue) or getUltimatePoints()
                local previous = tonumber(self.lastUltimatePoints)
                self.lastUltimatePoints = current
                -- A sharp drop confirms that an Ultimate was spent, even if ESO did
                -- not expose the used Ultimate through the configured skill mapping.
                if previous and current < previous then
                    self.lastUltimateUseMs = now()
                    -- This is the most reliable console-side confirmation that an
                    -- Ultimate was actually spent. Start the full hard lock here too.
                    self:LockUltimateForTenSeconds()
                    if self.heldRecommendation and self.heldRecommendation.type == "ultimate" then
                        self:ClearHeldRecommendation()
                        self:ClearFadeRecommendation()
                    end
                end
            end)
        if REGISTER_FILTER_UNIT_TAG then
            EM:AddFilterForEvent(self.name .. "_UltimatePower", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        end
        if REGISTER_FILTER_POWER_TYPE then
            EM:AddFilterForEvent(self.name .. "_UltimatePower", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE)
        end
    end
    EM:RegisterForEvent(self.name .. "_Effects", EVENT_EFFECT_CHANGED,
        function(_, changeType, effectSlot, effectName, unitTag, beginTimeSec, endTimeSec,
                 stackCount, iconName, buffType, effectType, abilityType, statusEffectType,
                 unitName, unitId, abilityId, sourceType)
            self:OnEffectChanged(changeType, effectName, unitTag, beginTimeSec, endTimeSec, abilityId, sourceType)
        end)
    EM:RegisterForUpdate(self.name .. "_Update", 33, function() self:UpdateFlow() end)

    msg("Loaded v" .. self.version .. " Route Planner")
end

local function OnLoaded(_, addonName)
    if addonName ~= SRT.name then return end
    EM:UnregisterForEvent(SRT.name, EVENT_ADD_ON_LOADED)
    SRT:Initialize()
end

EM:RegisterForEvent(SRT.name, EVENT_ADD_ON_LOADED, OnLoaded)
