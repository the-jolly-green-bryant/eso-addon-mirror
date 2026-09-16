-- Common Works -- combat alerts: off balance, low health, PVP focused
-- alerts, the Blastbones rhythm tones and the generalized GCD alerts.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI
local EM = EVENT_MANAGER

-- Off Balance reticle text
-- Matched by name: several ability ids apply Off Balance and all share the name.
local OFF_BALANCE_NAME = GetAbilityName(62988)
local OFF_BALANCE_EVENT = CW.name .. "OffBalance"
local offBalanceTracking = false

-- Return game-time start/end stamps for off balance, or nil if absent.
-- Missing stamps mean "no timer" to the underline UI.
local function ReticleTargetOffBalance()
    if not (DoesUnitExist("reticleover") and IsUnitAttackable("reticleover")) then return false end

    for i = 1, GetNumBuffs("reticleover") do
        local name, timeStarted, timeEnding = GetUnitBuffInfo("reticleover", i)
        if name == OFF_BALANCE_NAME then return true, timeStarted, timeEnding end
    end
    return false
end

function CW.UpdateOffBalanceTracker()
    if not CW.SavedVars.showOffBalanceTracker then
        CW.UI.SetOffBalanceTrackerActive(false)
        return
    end
    CW.UI.SetOffBalanceTrackerActive(ReticleTargetOffBalance())
end

local function OnOffBalanceEffectChanged(_, _changeType, _slot, effectName)
    if effectName == OFF_BALANCE_NAME then CW.UpdateOffBalanceTracker() end
end

function CW.UpdateOffBalanceTracking()
    local enabled = CW.SavedVars.showOffBalanceTracker

    if enabled and not offBalanceTracking then
        EM:RegisterForEvent(OFF_BALANCE_EVENT, EVENT_RETICLE_TARGET_CHANGED, CW.UpdateOffBalanceTracker)
        EM:RegisterForEvent(OFF_BALANCE_EVENT, EVENT_EFFECT_CHANGED, OnOffBalanceEffectChanged)
        EM:AddFilterForEvent(OFF_BALANCE_EVENT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
        offBalanceTracking = true
    elseif not enabled and offBalanceTracking then
        EM:UnregisterForEvent(OFF_BALANCE_EVENT, EVENT_RETICLE_TARGET_CHANGED)
        EM:UnregisterForEvent(OFF_BALANCE_EVENT, EVENT_EFFECT_CHANGED)
        offBalanceTracking = false
    end

    CW.UpdateOffBalanceTracker()
end

-- Low health alert
-- Use a separate namespace: mount stamina already registers and unregisters
-- EVENT_POWER_UPDATE under CW.name.
local HEALTH_ALERT_EVENT = CW.name .. "HealthAlert"
local healthAlertTracking = false
local lastHealthAlertMs = nil

-- Suppress revive health ticks through the resurrection animation.
local HEALTH_ALERT_REVIVE_GRACE_MS = 3000
local healthAlertReviveUntilMs = nil

-- Shared { SOUNDS key, label } list, sorted by dropdown label.
-- Removed as inaudible in combat: Map Ping, Volume Ding, Ability Not Ready, Skill Gained.
local SOUND_LIST = {
    { "ABILITY_RANK_UP",                   "Ability Rank Up" },
    { "ABILITY_SLOTTED",                   "Ability Slotted" },
    { "ACHIEVEMENT_AWARDED",               "Achievement" },
    { "GENERAL_ALERT_ERROR",               "Alert Error" },
    { "DISPLAY_ANNOUNCEMENT",              "Announcement" },
    { "ABILITY_FAILED_IN_COMBAT",          "Blocked in Combat" },
    { "BOOK_ACQUIRED",                     "Book Acquired" },
    { "BOOK_COLLECTION_COMPLETED",         "Book Collection" },
    { "OVERLAND_BOSS_KILL",                "Boss Kill" },
    { "SKILL_XP_BOSS_KILLED",              "Boss XP" },
    { "CHAMPION_POINTS_COMMITTED",         "Champion Commit" },
    { "CHAMPION_POINT_GAINED",             "Champion Point" },
    { "CHAMPION_STAR_SLOTTED",             "Champion Star" },
    { "CODE_REDEMPTION_SUCCESS",           "Code Redeemed" },
    { "COLLECTIBLE_UNLOCKED",              "Collectible Unlocked" },
    { "COUNTDOWN_TICK",                    "Countdown Tick" },
    { "DEFER_NOTIFICATION",                "Defer Blip" },
    { "DUEL_ACCEPTED",                     "Duel Accepted" },
    { "DUEL_BOUNDARY_WARNING",             "Duel Boundary Warning" },
    { "DUEL_START",                        "Duel Start" },
    { "ENLIGHTENED_STATE_GAINED",          "Enlightened" },
    { "GROUP_ELECTION_REQUESTED",          "Group Election" },
    { "BATTLEGROUND_INACTIVITY_WARNING",   "Inactivity Warning" },
    { "INVENTORY_ITEM_REPAIR",             "Item Repair" },
    { "DEATH_RECAP_KILLING_BLOW_SHOWN",    "Killing Blow" },
    { "LEVEL_UP",                          "Level Up" },
    { "LOCKPICKING_UNLOCKED",              "Lock Opened" },
    { "LOCKPICKING_CHAMBER_START",         "Lockpick Chamber" },
    { "DAILY_LOGIN_REWARDS_CLAIM_FANFARE", "Login Fanfare" },
    { "MENU_BAR_CLICK",                    "Menu Click" },
    { "ABILITY_MORPH_AVAILABLE",           "Morph Available" },
    { "ACTIVE_SKILL_MORPH_CHOSEN",         "Morph Chosen" },
    { "NEGATIVE_CLICK",                    "Negative Click" },
    { "LOCKPICKING_NO_LOCKPICKS",          "No Lockpicks" },
    { "JUSTICE_NO_LONGER_KOS",             "No Longer Wanted" },
    { "NEW_NOTIFICATION",                  "Notification" },
    { "JUSTICE_NOW_KOS",                   "Now Wanted" },
    { "QUEST_OBJECTIVE_COMPLETE",          "Objective Complete" },
    { "OBJECTIVE_DISCOVERED",              "Objective Discovered" },
    { "OBJECTIVE_COMPLETED",               "Objective Done" },
    { "QUEST_OBJECTIVE_STARTED",           "Objective Start" },
    { "QUEST_OBJECTIVE_INCREMENT",         "Objective Tick" },
    { "ABILITY_NOT_ENOUGH_MAGICKA",        "Out of Magicka" },
    { "ABILITY_NOT_ENOUGH_STAMINA",        "Out of Stamina" },
    { "ABILITY_NOT_ENOUGH_ULTIMATE",       "Out of Ultimate" },
    { "TAMRIEL_TOMES_PAGE_FLIPPED",        "Page Flip" },
    { "PASSIVE_SKILL_RANK_INCREASED",      "Passive Rank Up" },
    { "QUEST_ABANDONED",                   "Quest Abandoned" },
    { "QUEST_COMPLETED",                   "Quest Completed" },
    { "QUEST_SHARE_ACCEPTED",              "Quest Share" },
    { "LFG_SEARCH_FINISHED",               "Queue Ready" },
    { "QUICKSLOT_CLEAR",                   "Quickslot Clear" },
    { "RIDING_SKILL_IMPROVEMENT",          "Riding Skill" },
    { "GUILD_ROSTER_ADDED",                "Roster Add" },
    { "SCRYING_PROGRESS_ADDED",            "Scrying Progress" },
    { "SKILL_LINE_ADDED",                  "Skill Line Added" },
    { "SKILL_LINE_LEVELED_UP",             "Skill Line Up" },
    { "SKILL_PURCHASED",                   "Skill Purchased" },
    { "SKYSHARD_GAINED",                   "Skyshard" },
    { "STATS_PURCHASE",                    "Stat Purchase" },
    { "STEALTH_DETECTED",                  "Stealth Detected" },
    { "STEALTH_HIDDEN",                    "Stealth Hidden" },
    { "ABILITY_SYNERGY_READY",             "Synergy Ready" },
    { "TELVAR_MULTIPLIERUP",               "Tel Var Up" },
    { "RAID_TRIAL_COMPLETED",              "Trial Completed" },
    { "RAID_TRIAL_COUNTER_UPDATE",         "Trial Counter" },
    { "RAID_TRIAL_FAILED",                 "Trial Failed" },
    { "RAID_TRIAL_NEW_BEST",               "Trial New Best" },
    { "RAID_TRIAL_SCORE_ADDED_HIGH",       "Trial Score High" },
    { "RAID_TRIAL_SCORE_ADDED_LOW",        "Trial Score Low" },
    { "RAID_TRIAL_SCORE_ADDED_NORMAL",     "Trial Score Mid" },
    { "RAID_TRIAL_SCORE_ADDED_VERY_HIGH",  "Trial Score Very High" },
    { "RAID_TRIAL_SCORE_ADDED_VERY_LOW",   "Trial Score Very Low" },
    { "RAID_TRIAL_STARTED",                "Trial Started" },
    { "ABILITY_ULTIMATE_READY",            "Ultimate Ready" },
    { "GROUP_ELECTION_RESULT_LOST",        "Vote Failed" },
    { "MAP_WAYSHRINE_TELEPORT",            "Wayshrine Teleport" },
    { "ABILITY_WEAPON_SWAP_FAIL",          "Weapon Swap Fail" },
    -- ESO exposes no combat impact audio or SOUNDS.MELEE_HIT;
    -- these weapon sounds come from outfit-station style selection.
    { "OUTFIT_WEAPON_TYPE_AXE",            "Weapon: Axe" },
    { "OUTFIT_WEAPON_TYPE_BOW",            "Weapon: Bow" },
    { "OUTFIT_WEAPON_TYPE_DAGGER",         "Weapon: Dagger" },
    { "OUTFIT_WEAPON_TYPE_MACE",           "Weapon: Mace" },
    { "OUTFIT_WEAPON_TYPE_RUNE",           "Weapon: Rune" },
    { "OUTFIT_WEAPON_TYPE_SHIELD",         "Weapon: Shield" },
    { "OUTFIT_WEAPON_TYPE_STAFF",          "Weapon: Staff" },
    { "OUTFIT_WEAPON_TYPE_SWORD",          "Weapon: Sword" },
    -- PlayItemSound takes weapon categories, so saved keys use an "item:" prefix.
    -- Equip foley distinguishes one- and two-handed weapons.
    { "item:ONE_HAND_AX",                  "Weapon Draw: Axe (1H)" },
    { "item:TWO_HAND_AX",                  "Weapon Draw: Axe (2H)" },
    { "item:BOW",                          "Weapon Draw: Bow" },
    { "item:DAGGER",                       "Weapon Draw: Dagger" },
    { "item:ONE_HAND_HAMMER",              "Weapon Draw: Hammer (1H)" },
    { "item:TWO_HAND_HAMMER",              "Weapon Draw: Hammer (2H)" },
    { "item:SHIELD",                       "Weapon Draw: Shield" },
    { "item:STAFF",                        "Weapon Draw: Staff" },
    { "item:ONE_HAND_SWORD",               "Weapon Draw: Sword (1H)" },
    { "item:TWO_HAND_SWORD",               "Weapon Draw: Sword (2H)" },
}

-- LAM requires equal-length label/key lists; omit keys the client no longer provides.
local ITEM_SOUND_CATEGORIES = {}

CW.SOUND_NAMES = {}
CW.SOUND_KEYS = {}
for _, entry in ipairs(SOUND_LIST) do
    local key = entry[1]
    local name = key:match("^item:(.+)")
    local category = name and _G["ITEM_SOUND_CATEGORY_" .. name]
    if category then ITEM_SOUND_CATEGORIES[key] = category end
    if SOUNDS[key] or category then
        local i = #CW.SOUND_KEYS + 1
        CW.SOUND_KEYS[i]  = key
        CW.SOUND_NAMES[i] = entry[2]
    end
end

local HEALTH_POWER = COMBAT_MECHANIC_FLAGS_HEALTH

-- Playing the same sample several times in one frame stacks it and reads as louder,
-- which is how the volume sliders work (0 = silent).
local function PlaySoundRepeated(soundKey, repeats)
    if repeats < 1 then return end
    local category = ITEM_SOUND_CATEGORIES[soundKey]
    local sound = SOUNDS[soundKey]
    if not category and not sound then return end
    for _ = 1, repeats do
        if category then
            PlayItemSound(category, ITEM_SOUND_ACTION_EQUIP)
        else
            PlaySound(sound)
        end
    end
end

-- Shared with the feature modules that live in their own files (chat pop-up).
CW.PlaySoundRepeated = PlaySoundRepeated

-- Also the settings panel's audition path, so what you hear there is what a
-- real alert plays.
function CW.PlayHealthAlertSound()
    PlaySoundRepeated(CW.SavedVars.healthAlertSound, CW.SavedVars.healthAlertVolume)
end

function CW.FireHealthAlert()
    CW.PlayHealthAlertSound()
    CW.UI.ShowHealthAlert()
end

-- The engine filters this to the player's health.
local function OnHealthAlertPowerUpdate(_, _, _, _, powerValue, powerMax)
    if powerMax <= 0 then return end
    -- Dead: no alert, and no throttle left behind to swallow the next dip.
    if powerValue <= 0 then
        lastHealthAlertMs = nil
        return
    end

    local now = GetGameTimeMilliseconds()

    -- A soul gem revive's low health looks like a dip. Suppress through death and
    -- the revive grace period; clear the throttle so the first real dip alerts.
    if IsUnitDeadOrReincarnating("player") then
        lastHealthAlertMs = nil
        return
    end
    if healthAlertReviveUntilMs then
        if now < healthAlertReviveUntilMs then
            lastHealthAlertMs = nil
            return
        end
        healthAlertReviveUntilMs = nil
    end

    local sv = CW.SavedVars
    if powerValue / powerMax * 100 > sv.healthAlertThreshold then
        -- Back to safety: re-arm so the next dip alerts immediately.
        lastHealthAlertMs = nil
        return
    end

    if lastHealthAlertMs and (now - lastHealthAlertMs) < sv.healthAlertCooldown then return end
    lastHealthAlertMs = now

    CW.FireHealthAlert()
end

function CW.UpdateHealthAlertTracking()
    local enabled = CW.SavedVars.healthAlertEnabled

    if enabled and not healthAlertTracking then
        EM:RegisterForEvent(HEALTH_ALERT_EVENT, EVENT_POWER_UPDATE, OnHealthAlertPowerUpdate)
        EM:AddFilterForEvent(HEALTH_ALERT_EVENT, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        EM:AddFilterForEvent(HEALTH_ALERT_EVENT, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, HEALTH_POWER)
        -- Covers a power update racing ahead of IsUnitDeadOrReincarnating clearing.
        EM:RegisterForEvent(HEALTH_ALERT_EVENT, EVENT_PLAYER_DEAD, function()
            lastHealthAlertMs = nil
            healthAlertReviveUntilMs = nil
        end)
        EM:RegisterForEvent(HEALTH_ALERT_EVENT, EVENT_PLAYER_ALIVE, function()
            local now = GetGameTimeMilliseconds()
            healthAlertReviveUntilMs = now + HEALTH_ALERT_REVIVE_GRACE_MS
            lastHealthAlertMs = nil
        end)
        healthAlertTracking = true
    elseif not enabled and healthAlertTracking then
        EM:UnregisterForEvent(HEALTH_ALERT_EVENT, EVENT_POWER_UPDATE)
        EM:UnregisterForEvent(HEALTH_ALERT_EVENT, EVENT_PLAYER_DEAD)
        EM:UnregisterForEvent(HEALTH_ALERT_EVENT, EVENT_PLAYER_ALIVE)
        healthAlertTracking = false
        lastHealthAlertMs = nil
        healthAlertReviveUntilMs = nil
        CW.UI.HideHealthAlert()
    end
end

function CW.ResetHealthAlertThrottle()
    lastHealthAlertMs = nil
end

-- Incoming damage alerts (PvP only)
-- Ability groups share a checkbox, label and window refreshed by each hit;
-- groups include morphs and elemental ultimate variants. The latest hit wins.
--
-- Use landed damage: ACTION_RESULT_BEGIN reaches only the caster's primary target,
-- so it misses sideways hits from cones such as Fatecarver.
--
-- Ids checked against CrutchAlerts' channel list.
-- Exclude reveal/CC-immunity auras 55131 and 87321; they are not damage.
local INCOMING_WINDOW_MS = 2500   -- channels and fields tick under a second

local INCOMING_ALERTS = {
    { key = "Corrosive",   name = "Corrosive Armor",     window = 3000, ids = { 17879 } },
    -- One hit, nothing to refresh from, so it carries its own window.
    { key = "Onslaught",   name = "Onslaught",           window = 8000, ids = { 83229 } },
    { key = "Radiant",     name = "Radiant Destruction",
      ids = { 63029, 63044, 63046, 63952, 63956, 63961 } },
    { key = "RapidFire",   name = "Rapid Fire",
      ids = { 83465, 86563, 85257, 85260, 85261, 85451, 85458, 85462 } },
    { key = "SoulAssault", name = "Soul Assault",
      ids = { 40420, 39270, 40414, 40416 } },
    { key = "Fatecarver",  name = "Fatecarver",
      ids = { 185805, 193331, 183122, 193397, 186366, 193398, 189533 } },
    { key = "ArcanistUlt", name = "The Unblinking Eye",
      ids = { 189793, 189869, 191889, 189837, 189839, 191367 } },
    { key = "DestroUlt",   name = "Elemental Storm",
      ids = { 83619, 83625, 83628, 83630, 83626, 83629, 83631,
              83642, 83682, 83684, 83686, 83683, 83685, 83687,
              84434, 85126, 85128, 85130, 85127, 85129, 85131 } },
}
CW.INCOMING_ALERTS = INCOMING_ALERTS

for _, entry in ipairs(INCOMING_ALERTS) do
    entry.sv = "incomingAlert" .. entry.key
    entry.window = entry.window or INCOMING_WINDOW_MS
end

local INCOMING_ALERT_EVENT = CW.name .. "IncomingAlert"
local INCOMING_ALERT_TIMER = CW.name .. "IncomingAlertTimer"

-- Tick only while visible; unregister when the window expires.
local INCOMING_ALERT_TICK_MS = 200

local INCOMING_RESULTS = {
    ACTION_RESULT_DAMAGE, ACTION_RESULT_CRITICAL_DAMAGE,
    ACTION_RESULT_DOT_TICK, ACTION_RESULT_DOT_TICK_CRITICAL,
}

local incomingAlertTracking = false
-- Rebuild enabled ids on toggles to keep disabled abilities out of the hot path.
local incomingById = {}
-- { entry = <INCOMING_ALERTS entry>, endMs = <ms> }, or nil.
local incomingAlert = nil

-- Name the actual morph that hit; cache per id for repeated hits.
local incomingLabels = {}
local function IncomingLabel(abilityId)
    local label = incomingLabels[abilityId]
    if not label then
        label = zo_strformat("<<1>>", GetAbilityName(abilityId)):upper()
        incomingLabels[abilityId] = label
    end
    return label
end

-- The placement stand-in, so there is something to drag when nothing is hitting you.
function CW.IncomingAlertPreview()
    local id = INCOMING_ALERTS[1].ids[1]
    return IncomingLabel(id), GetAbilityIcon(id)
end

-- Poll timers
-- Three alerts tick only while live. The flag prevents re-registering a namespace,
-- which replaces the pending call and restarts the cycle.
local ticking = {}

local function StartTick(ns, ms, fn)
    if ticking[ns] then return end
    ticking[ns] = true
    EM:RegisterForUpdate(ns, ms, fn)
end

local function StopTick(ns)
    if not ticking[ns] then return end
    ticking[ns] = nil
    EM:UnregisterForUpdate(ns)
end

local function IncomingAlertTick()
    if incomingAlert and incomingAlert.endMs > GetFrameTimeMilliseconds() then return end
    incomingAlert = nil
    StopTick(INCOMING_ALERT_TIMER)
    CW.UI.UpdateIncomingAlert(nil, nil)
end

function CW.PlayIncomingAlertSound()
    PlaySoundRepeated(CW.SavedVars.incomingAlertSound, CW.SavedVars.incomingAlertVolume)
end

-- Engine filters match result, target and error; only the watched ability check remains.
local function OnIncomingDamage(_, _result, _isError, _abilityName, _abilityGraphic,
                                _abilitySlotType, _sourceName, _sourceType, _targetName,
                                _targetType, hitValue, _powerType, _damageType, _log,
                                _sourceUnitId, _targetUnitId, abilityId)
    local entry = incomingById[abilityId]
    if not entry or hitValue <= 0 then return end

    local now = GetFrameTimeMilliseconds()
    -- The 200ms tick can leave an expired window here; that is replacement, not overlap.
    local live = incomingAlert ~= nil and incomingAlert.endMs > now and incomingAlert or nil

    -- Repeated hits refresh without sound or relabeling; alternating watched abilities re-announce.
    if live ~= nil and live.entry == entry then
        live.endMs = now + entry.window
    else
        -- Send the displaced warning to chat; the newcomer takes the screen.
        if live and CW.SavedVars.incomingAlertChat == true then
            CHAT_ROUTER:AddSystemMessage(zo_iconFormat(live.icon, "100%", "100%") .. " " .. live.label)
        end
        local label, icon = IncomingLabel(abilityId), GetAbilityIcon(abilityId)
        incomingAlert = { entry = entry, endMs = now + entry.window, label = label, icon = icon }
        CW.UI.UpdateIncomingAlert(label, icon)
        CW.PlayIncomingAlertSound()
    end

    StartTick(INCOMING_ALERT_TIMER, INCOMING_ALERT_TICK_MS, IncomingAlertTick)
end

-- Also the "switched off mid-fight" path.
function CW.ClearIncomingAlert()
    incomingAlert = nil
    StopTick(INCOMING_ALERT_TIMER)
    CW.UI.UpdateIncomingAlert(nil, nil)
end

-- Called on load, on every EVENT_PLAYER_ACTIVATED (a zone change), and from the
-- settings toggles. Nothing is registered while every ability is switched off.
function CW.UpdateIncomingAlertTracking()
    local sv = CW.SavedVars
    ZO_ClearTable(incomingById)
    if sv.incomingAlertEnabled and CW.IsPvpZone() then
        for _, entry in ipairs(INCOMING_ALERTS) do
            if sv[entry.sv] then
                for _, id in ipairs(entry.ids) do incomingById[id] = entry end
            end
        end
    end
    local wanted = next(incomingById) ~= nil

    if wanted and not incomingAlertTracking then
        -- One namespace per result: REGISTER_FILTER_COMBAT_RESULT accepts one value.
        -- Engine filtering keeps unrelated damage out of Lua.
        for i, result in ipairs(INCOMING_RESULTS) do
            local ns = INCOMING_ALERT_EVENT .. i
            EM:RegisterForEvent(ns, EVENT_COMBAT_EVENT, OnIncomingDamage)
            EM:AddFilterForEvent(ns, EVENT_COMBAT_EVENT,
                REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
                REGISTER_FILTER_COMBAT_RESULT, result,
                REGISTER_FILTER_IS_ERROR, false)
        end
        incomingAlertTracking = true
    elseif not wanted and incomingAlertTracking then
        for i = 1, #INCOMING_RESULTS do
            EM:UnregisterForEvent(INCOMING_ALERT_EVENT .. i, EVENT_COMBAT_EVENT)
        end
        incomingAlertTracking = false
        CW.ClearIncomingAlert()
    end
end

-- CC immunity bar
-- Hard CC and soft CC (roots/snares) use separate tracks. Hard outranks soft; while both
-- run, soft keeps its own bar underneath.

local CC_IMMUNITY_EVENT = CW.name .. "CcImmunity"
local CC_IMMUNITY_TIMER = CW.name .. "CcImmunityTimer"
local CC_IMMUNITY_TICK_MS = 100

-- Matched by name: potion variants and skill morphs share one, not an id. true is hard CC,
-- false roots and snares only. Potions never reach EVENT_EFFECT_CHANGED.
local CC_IMMUNITY_IDS = {
    [45239]  = true,    -- Unstoppable: every immovability potion and elixir, heavy armor morph
    [39197]  = true,    -- Immovable
    [28301]  = true,    -- Crowd Control Immunity: break free, Berserker Rage
    [29721]  = false,   -- Immobilize Immunity, after a roll
    [122260] = false,   -- Race Against Time
    [177288] = false,   -- Falcon's Swiftness
    [177289] = false,   -- Deceptive Predator
    [177290] = false,   -- Bird of Prey
    [125314] = false,   -- Phantasmal Escape
}

local ccImmunityTracking = false
local ccNames
local ccHardBegin, ccHardEnd = 0, 0
local ccSoftBegin, ccSoftEnd = 0, 0

local function CcImmunityTick()
    local now = GetGameTimeSeconds()
    local hard, soft = ccHardEnd - now, ccSoftEnd - now
    local softProgress = soft > 0 and soft / (ccSoftEnd - ccSoftBegin) or 0
    if hard > 0 then
        CW.UI.UpdateCcImmunity(hard / (ccHardEnd - ccHardBegin), hard, true, softProgress)
    elseif soft > 0 then
        CW.UI.UpdateCcImmunity(softProgress, soft, false, 0)
    else
        StopTick(CC_IMMUNITY_TIMER)
        CW.UI.UpdateCcImmunity(0, 0, false, 0)
    end
end

-- Only extend windows so overlapping dodge rolls cannot end the bar early.
local function ExtendCcImmunity(hard, beginAt, endAt)
    if hard then
        if endAt <= ccHardEnd then return end
        ccHardBegin, ccHardEnd = beginAt, endAt
    else
        if endAt <= ccSoftEnd then return end
        ccSoftBegin, ccSoftEnd = beginAt, endAt
    end
    StartTick(CC_IMMUNITY_TIMER, CC_IMMUNITY_TICK_MS, CcImmunityTick)
    CcImmunityTick()
end

-- Gains only: the roll that faded is not the roll still running.
local function OnCcImmunityGained(_, _result, _isError, name, _graphic, _slotType,
                                  _sourceName, _sourceType, _targetName, _targetType, durationMs)
    local hard = ccNames[name]
    if hard == nil then return end
    local now = GetGameTimeSeconds()
    ExtendCcImmunity(hard, now, now + durationMs / 1000)
end

function CW.ClearCcImmunity()
    ccHardEnd, ccSoftEnd = 0, 0
    StopTick(CC_IMMUNITY_TIMER)
    CW.UI.UpdateCcImmunity(0, 0, false, 0)
end

-- Not zone-gated: an immunity window is worth seeing in a dungeon too.
function CW.UpdateCcImmunityTracking()
    local wanted = CW.SavedVars.ccImmunityEnabled

    if wanted and not ccImmunityTracking then
        if not ccNames then
            ccNames = {}
            for id, hard in pairs(CC_IMMUNITY_IDS) do ccNames[GetAbilityName(id)] = hard end
            ccNames[""] = nil   -- an id the client no longer knows resolves to ""
        end
        EM:RegisterForEvent(CC_IMMUNITY_EVENT, EVENT_COMBAT_EVENT, OnCcImmunityGained)
        EM:AddFilterForEvent(CC_IMMUNITY_EVENT, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION,
            REGISTER_FILTER_IS_ERROR, false)
        ccImmunityTracking = true
    elseif not wanted and ccImmunityTracking then
        EM:UnregisterForEvent(CC_IMMUNITY_EVENT, EVENT_COMBAT_EVENT)
        ccImmunityTracking = false
        CW.ClearCcImmunity()
    end
end

-- Negate warning
-- PvP only; field effect ids differ from cast ids, so match the three cast names
-- and cache matches per effect id.

local NEGATE_EVENT = CW.name .. "NegateAlert"
local NEGATE_IDS = { 27706, 28341, 28348 }   -- Negate Magic, Suppression / Absorption Field

local negateAlertTracking = false
local negateNames, negateIds

local function IsNegate(abilityId, effectName)
    local known = negateIds[abilityId]
    if known == nil then
        known = negateNames[effectName] == true
        negateIds[abilityId] = known
    end
    return known
end

local function OnNegateEffect(_, changeType, _slot, effectName, _unitTag, _beginTime, _endTime,
                              _stack, _icon, _deprecated, _effectType, _abilityType,
                              _statusEffectType, _unitName, _unitId, abilityId)
    if not IsNegate(abilityId, effectName) then return end
    if changeType == EFFECT_RESULT_FADED then
        CW.UI.HideNegateAlert()
    elseif CW.UI.ShowNegateAlert() then
        CW.PlayNegateAlertSound()
    end
end

-- Also the settings preview, so picking a sound plays what a real Negate plays.
function CW.PlayNegateAlertSound()
    PlaySoundRepeated(CW.SavedVars.negateAlertSound, CW.SavedVars.negateAlertVolume)
end

function CW.UpdateNegateAlertTracking()
    local wanted = CW.SavedVars.negateAlertEnabled and CW.IsPvpZone()

    if wanted and not negateAlertTracking then
        if not negateNames then
            negateNames, negateIds = {}, {}
            for _, id in ipairs(NEGATE_IDS) do negateNames[GetAbilityName(id)] = true end
        end
        EM:RegisterForEvent(NEGATE_EVENT, EVENT_EFFECT_CHANGED, OnNegateEffect)
        EM:AddFilterForEvent(NEGATE_EVENT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        negateAlertTracking = true
    elseif not wanted and negateAlertTracking then
        EM:UnregisterForEvent(NEGATE_EVENT, EVENT_EFFECT_CHANGED)
        negateAlertTracking = false
        CW.UI.HideNegateAlert()
    end
end

-- Blighted Blastbones returns after three globals; two quiet tones pace the recast.
-- Sound only, no HUD widget.

local BLASTBONES_EVENT = CW.name .. "Blastbones"

-- Player aura for a successful summon, not the cast id; covers ranks 117690 / 117693.
local BLASTBONES_EFFECT_ID = 117691    -- the Blighted morph only, per design

local blastbonesTracking = false
local blastbonesToken = 0              -- bumped to void tones still pending


-- Tone 0 marks the press, so it has no delay.
local function BlastbonesTone(n)
    local sv = CW.SavedVars
    return sv["blastbonesSound" .. n], sv["blastbonesVolume" .. n], sv["blastbonesDelay" .. n] or 0
end

local function PlayBlastbonesTone(n)
    local sound, volume = BlastbonesTone(n)
    PlaySoundRepeated(sound, volume)
end

-- Let the settings panel audition one tone at its configured volume.
function CW.PreviewBlastbonesTone(n)
    PlayBlastbonesTone(n)
end

-- Also Settings' "Test tones". PlaySoundRepeated drops a volume under 1, so muted
-- tones need no check.
function CW.FireBlastbonesTones()
    blastbonesToken = blastbonesToken + 1
    local token = blastbonesToken
    PlayBlastbonesTone(0)
    for n = 1, 2 do
        local _, _, delay = BlastbonesTone(n)
        zo_callLater(function()
            if token == blastbonesToken then PlayBlastbonesTone(n) end
        end, delay)
    end
end

-- One GAINED per skeleton, so no press debounce: a second GAINED *is* a second cast.
local function OnBlastbonesGained(_, changeType)
    if changeType == EFFECT_RESULT_GAINED then CW.FireBlastbonesTones() end
end

function CW.UpdateBlastbonesTracking()
    local enabled = CW.SavedVars.blastbonesEnabled
    if enabled == blastbonesTracking then return end
    blastbonesTracking = enabled

    if enabled then
        EM:RegisterForEvent(BLASTBONES_EVENT, EVENT_EFFECT_CHANGED, OnBlastbonesGained)
        EM:AddFilterForEvent(BLASTBONES_EVENT, EVENT_EFFECT_CHANGED,
            REGISTER_FILTER_UNIT_TAG, "player",
            REGISTER_FILTER_ABILITY_ID, BLASTBONES_EFFECT_ID)
    else
        EM:UnregisterForEvent(BLASTBONES_EVENT, EVENT_EFFECT_CHANGED)
        blastbonesToken = blastbonesToken + 1   -- void anything still pending
    end
end

-- GCD-ready alerts
-- Read the client's cooldown and fire when the bar is free.
-- Each watched ability has enable/text/sound/volume/duration settings;
-- font, color and position are shared by the HUD widget.

CW.MAX_GCD_ALERTS = 12

local GCD_ALERT_EVENT   = CW.name .. "GcdAlert"
local GCD_ALERT_TIMER   = CW.name .. "GcdAlertTimer"

-- Within a frame or two of the cooldown ending. Only registered while a cast is
-- pending, and the tick unregisters itself.
local GCD_ALERT_TICK_MS = 50

-- Cooldown may not read as running on the keypress frame; allow grace before
-- treating an inactive GCD as finished.
local GCD_ALERT_ARM_GRACE_MS = 250

-- EVENT_ACTION_SLOT_ABILITY_USED fires per accepted input, so a press queued in the GCD
-- tail, or the ability slotted on both bars, can arrive twice.
local GCD_ALERT_RECAST_MIN_MS = 400

local gcdAlertTracking = false
-- One watch at a time: a second cast supersedes whatever was pending.
-- { index = <gcdAlerts index>, startedMs = <ms>, armed = <bool> }
local pendingGcdAlert = nil
local lastGcdCastMs = {}   -- gcdAlerts index -> ms of the last accepted cast

-- Slots 3-7 are the ability slots. 8 (ultimate) is excluded: it reports its own long
-- cooldown and effectively never the global.
local GCD_PROBE_SLOTS = { 3, 4, 5, 6, 7 }

-- GetSlotCooldownInfo's third return identifies the global cooldown.
-- Probe all five slots: a longer personal cooldown reports global=false.
-- If all five have personal cooldowns, the max-wait timeout drops the watch.
local function IsGlobalCooldownActive()
    local hotbar = GetActiveHotbarCategory()
    for _, slot in ipairs(GCD_PROBE_SLOTS) do
        local remain, _duration, global = GetSlotCooldownInfo(slot, hotbar)
        if remain > 0 and global then
            return true
        end
    end
    return false
end

-- Scribed skills slot the crafted-ability id, so the bound id has to be unwrapped or
-- it never matches what the settings dropdown offered.
local function SlotAbilityId(slotNum, hotbarCategory)
    hotbarCategory = hotbarCategory or GetActiveHotbarCategory()
    local id = GetSlotBoundId(slotNum, hotbarCategory)
    if id == 0 then return nil end
    if GetSlotType(slotNum, hotbarCategory) == ACTION_TYPE_CRAFTED_ABILITY then
        id = GetAbilityIdForCraftedAbilityId(id)
    end
    return id
end
CW.SlotAbilityId = SlotAbilityId

local function GcdAlertStore()
    return CW.SavedVars.gcdAlerts
end
CW.GcdAlertStore = GcdAlertStore

local function FindGcdAlert(abilityId)
    for i, entry in ipairs(GcdAlertStore()) do
        if entry.id == abilityId then return i, entry end
    end
    return nil
end

-- Cached per id, so the name fallback below costs nothing after the first cast.
-- "" means the client could not name it; do not retry.
local gcdAlertNames = {}
local function GcdAbilityName(abilityId)
    local cached = gcdAlertNames[abilityId]
    if cached ~= nil then return cached end
    local name = GetAbilityName(abilityId)
    if name ~= "" then name = zo_strformat("<<1>>", name) end
    gcdAlertNames[abilityId] = name
    return name
end
CW.GcdAbilityName = GcdAbilityName

-- Exact id first, then the display name, so a rank variant or a shifted id still
-- matches.
local function GcdAlertEntryMatches(entry, abilityId)
    if entry.id == abilityId then return true end
    local want = GcdAbilityName(entry.id)
    if want == "" then return false end
    return GcdAbilityName(abilityId) == want
end

-- Toggle abilities (ON / OFF suffix)
-- ESO has no single toggle-state API. "bar" treats a non-front/back bar as ON;
-- "buff" checks a persistent player effect. Cast and effect ids can differ
-- (Blood Frenzy: 132141 -> 172418), hence the map and per-entry override.

-- Werewolf uses a special hotbar; Overload has no category, so track its effect.
CW.GCD_TOGGLE_BARS = {
    [32455] = true,   -- Werewolf Transformation
    [39075] = true,   -- Pack Leader
    [39076] = true,   -- Werewolf Berserker
}

-- Cast id -> the effect id up on the player while it is ON.
CW.GCD_TOGGLE_BUFFS = {
    [24785]  = 24785,    -- Overload
    [24806]  = 24806,    -- Energy Overload
    [24804]  = 24804,    -- Power Overload
    [32986]  = 106208,   -- Mist Form
    [38963]  = 106209,   -- Elusive Mist
    [38965]  = 49268,    -- Blood Mist
    [132141] = 172418,   -- Blood Frenzy
    [134160] = 134166,   -- Simmering Frenzy
    [135841] = 172648,   -- Sated Fury
    [103543] = 103543,   -- Mend Wounds
    [103747] = 103747,   -- Mend Spirit
    [103755] = 103755,   -- Symbiosis
}

CW.GCD_TOGGLE_MODES      = { "none", "auto", "bar", "buff" }
CW.GCD_TOGGLE_MODE_NAMES = { "No suffix", "Automatic", "Action bar swap", "Buff on me" }

-- Known toggles default to auto; other abilities get no suffix.
-- Match morph names too, since slotted ids may be absent from these tables.
local function LookupToggleTable(tbl, abilityId)
    local hit = tbl[abilityId]
    if hit ~= nil then return hit end
    local want = GcdAbilityName(abilityId)
    if want == "" then return nil end
    for id, value in pairs(tbl) do
        if GcdAbilityName(id) == want then return value end
    end
    return nil
end

local function DefaultToggleMode(abilityId)
    if LookupToggleTable(CW.GCD_TOGGLE_BARS, abilityId)
        or LookupToggleTable(CW.GCD_TOGGLE_BUFFS, abilityId) then
        return "auto"
    end
    return "none"
end

-- true = a special bar is up, false = front/back bar, nil = cannot tell.
local function SpecialHotbarActive()
    -- Werewolf has a direct predicate, preferred: the hotbar category can lag the
    -- transformation animation.
    if IsWerewolf() then return true end
    local cat = GetActiveHotbarCategory()
    return cat ~= HOTBAR_CATEGORY_PRIMARY and cat ~= HOTBAR_CATEGORY_BACKUP
end

-- Exact effect id first, then display name, so a rank variant still reads ON.
local function PlayerHasEffect(effectId)
    local want = GcdAbilityName(effectId)
    local n = GetNumBuffs("player")
    for i = 1, n do
        -- 11th return is the abilityId.
        local _, _, _, _, _, _, _, _, _, _, id = GetUnitBuffInfo("player", i)
        if id == effectId then return true end
        if want ~= "" and GcdAbilityName(id) == want then return true end
    end
    return false
end

local function GcdToggleBuffId(entry)
    local effectId = entry.toggleEffectId
    if effectId then return effectId end
    return LookupToggleTable(CW.GCD_TOGGLE_BUFFS, entry.id) or entry.id
end

-- true = ON, false = OFF, nil = no suffix. Sample after the GCD so bar/effect changes settle.
local function GcdToggleState(entry)
    local mode = entry.toggle
    if mode == "none" then return nil end

    if mode == "auto" then
        -- A special bar proves ON; otherwise check the buff. This avoids a permanent
        -- OFF from a misclassified ability, though a false ON is still possible.
        if SpecialHotbarActive() == true then return true end
        return PlayerHasEffect(GcdToggleBuffId(entry)) or false
    end

    if mode == "bar"  then return SpecialHotbarActive() end
    if mode == "buff" then return PlayerHasEffect(GcdToggleBuffId(entry)) end
    return nil
end

-- Append true/false toggle state as ON/OFF; nil adds no suffix.
-- Empty text means sound only. Seed the ability name on add, so clearing it persists.
local function GcdAlertText(entry, toggleState)
    local text = entry.text
    if text == "" then return "" end
    if toggleState == true  then return text .. " ON"  end
    if toggleState == false then return text .. " OFF" end
    return text
end
CW.GcdAlertText = GcdAlertText

-- Color distinguishes ON/OFF at a glance; non-toggles use the plain color.
function CW.GcdAlertColor(entry, toggleState)
    if toggleState == true  then return entry.colorOn  end
    if toggleState == false then return entry.colorOff end
    return entry.color
end

-- List management (called from the settings panel)

-- Returns index, or nil plus a reason string the settings panel prints.
function CW.AddGcdAlert(abilityId)
    if type(abilityId) ~= "number" or abilityId <= 0 or abilityId ~= math.floor(abilityId) then
        return nil, "not a valid ability id"
    end
    local store = GcdAlertStore()
    local existing = FindGcdAlert(abilityId)
    if existing then return existing, "already watched" end
    if #store >= CW.MAX_GCD_ALERTS then
        return nil, string.format("list is full (%d max)", CW.MAX_GCD_ALERTS)
    end
    store[#store + 1] = {
        id       = abilityId,
        enabled  = true,
        text     = GcdAbilityName(abilityId),   -- editable; cleared = no label
        sound    = CW.defaults.healthAlertSound,
        volume   = 3,
        duration = 800,
        toggle   = DefaultToggleMode(abilityId),
        color    = ZO_ShallowTableCopy(CW.defaults.gcdAlertColor),
        colorOn  = ZO_ShallowTableCopy(CW.defaults.gcdAlertColorOn),
        colorOff = ZO_ShallowTableCopy(CW.defaults.gcdAlertColorOff),
    }
    CW.UpdateGcdAlertTracking()
    return #store
end

function CW.RemoveGcdAlert(index)
    local store = GcdAlertStore()
    if not store[index] then return false end
    table.remove(store, index)
    -- Removal shifts indices; drop everything keyed by them.
    lastGcdCastMs = {}
    if pendingGcdAlert then CW.ClearGcdAlert() end
    CW.ClearExpireReminder()
    if CW.gcdAlertEditIndex and CW.gcdAlertEditIndex > #store then
        CW.gcdAlertEditIndex = #store > 0 and #store or nil
    end
    CW.UpdateGcdAlertTracking()
    return true
end

-- LAM captures a choices table by reference, so both are refilled in place and never
-- reassigned.
CW.GCD_BAR_CHOICE_NAMES = {}
CW.GCD_BAR_CHOICE_IDS   = {}
CW.GCD_ENTRY_CHOICE_NAMES = {}
CW.GCD_ENTRY_CHOICE_INDEXES = {}

-- Both bars, ultimates included. Ids resolve live rather than stored, so a bar change
-- is picked up by reopening the panel.
function CW.RefreshGcdBarChoices()
    ZO_ClearNumericallyIndexedTable(CW.GCD_BAR_CHOICE_NAMES)
    ZO_ClearNumericallyIndexedTable(CW.GCD_BAR_CHOICE_IDS)

    local bars = {
        { HOTBAR_CATEGORY_PRIMARY, "front" },
        { HOTBAR_CATEGORY_BACKUP,  "back"  },
    }
    local seen = {}
    for _, bar in ipairs(bars) do
        local category, label = bar[1], bar[2]
        for slot = 3, 8 do
            local id = SlotAbilityId(slot, category)
            if id and not seen[id] then
                seen[id] = true
                local name = GcdAbilityName(id)
                if name == "" then name = "Ability " .. id end
                local i = #CW.GCD_BAR_CHOICE_IDS + 1
                CW.GCD_BAR_CHOICE_IDS[i]   = id
                CW.GCD_BAR_CHOICE_NAMES[i] = string.format("%s  (%s %d)", name, label, slot)
            end
        end
    end
end

-- Values are indexes into gcdAlerts, so this rebuilds after every add or remove.
function CW.RefreshGcdEntryChoices()
    ZO_ClearNumericallyIndexedTable(CW.GCD_ENTRY_CHOICE_NAMES)
    ZO_ClearNumericallyIndexedTable(CW.GCD_ENTRY_CHOICE_INDEXES)
    for i, entry in ipairs(GcdAlertStore()) do
        local name = GcdAbilityName(entry.id)
        if name == "" then name = "Ability" end
        CW.GCD_ENTRY_CHOICE_INDEXES[i] = i
        CW.GCD_ENTRY_CHOICE_NAMES[i] = string.format("%s (%d)%s%s", name, entry.id,
            (entry.kind or "gcd") == "expire" and "  [expire]" or "",
            entry.enabled == false and "  [off]" or "")
    end
    local count = #CW.GCD_ENTRY_CHOICE_INDEXES
    if count == 0 then
        CW.gcdAlertEditIndex = nil
    elseif CW.gcdAlertEditIndex == nil or CW.gcdAlertEditIndex > count then
        CW.gcdAlertEditIndex = 1
    end
end

-- nil with an empty list. Widgets stay nil-safe rather than disabled-only: LAM reads
-- getFunc on refresh even for a disabled control.
function CW.CurrentGcdAlert()
    return GcdAlertStore()[CW.gcdAlertEditIndex or 0]
end

-- Audition sound only; the settings panel covers the label.
function CW.PlayGcdAlertSound(index)
    local entry = GcdAlertStore()[index]
    if not entry then return end
    PlaySoundRepeated(entry.sound, entry.volume)
end

-- Also the settings panel's "Test alert", so an audition is exactly a real cast.
function CW.FireGcdAlert(index)
    local entry = GcdAlertStore()[index]
    if not entry then return end
    CW.PlayGcdAlertSound(index)
    local state = GcdToggleState(entry)
    CW.UI.ShowGcdAlert(GcdAlertText(entry, state), entry.duration,
        CW.GcdAlertColor(entry, state))
end

-- The watch itself

-- Also the "switched off mid-fight" and "player died" path.
function CW.ClearGcdAlert()
    pendingGcdAlert = nil
    StopTick(GCD_ALERT_TIMER)
    CW.UI.HideGcdAlert()
end

local function GcdAlertTick()
    local pending = pendingGcdAlert
    if not pending then
        StopTick(GCD_ALERT_TIMER)
        return
    end

    local elapsed = GetFrameTimeMilliseconds() - pending.startedMs

    -- Drop interrupted, blocked, dead, bar-swapped or overlong casts without a late alert.
    if elapsed > CW.SavedVars.gcdAlertMaxWaitMs then
        pendingGcdAlert = nil
        StopTick(GCD_ALERT_TIMER)
        return
    end

    local active = IsGlobalCooldownActive()

    if not pending.armed then
        -- Arm once cooldown runs or grace expires; grace covers off-global abilities
        -- and cooldowns that ended before the event was handled.
        if active or elapsed >= GCD_ALERT_ARM_GRACE_MS then
            pending.armed = true
        else
            return
        end
    end

    if not active then
        local index = pending.index
        pendingGcdAlert = nil
        StopTick(GCD_ALERT_TIMER)
        CW.FireGcdAlert(index)
    end
end

local function StartGcdAlertWatch(index)
    pendingGcdAlert = { index = index, startedMs = GetFrameTimeMilliseconds(), armed = false }
    StartTick(GCD_ALERT_TIMER, GCD_ALERT_TICK_MS, GcdAlertTick)
end

local function OnGcdSlotUsed(_, slotNum)
    local abilityId = SlotAbilityId(slotNum)
    if not abilityId then return end

    for index, entry in ipairs(GcdAlertStore()) do
        if entry.enabled ~= false and (entry.kind or "gcd") == "gcd"
           and GcdAlertEntryMatches(entry, abilityId) then
            local now = GetFrameTimeMilliseconds()
            local last = lastGcdCastMs[index]
            if last and (now - last) < GCD_ALERT_RECAST_MIN_MS then return end
            lastGcdCastMs[index] = now
            StartGcdAlertWatch(index)
            return
        end
    end
end

-- kind nil counts either; "gcd"/"expire" restricts to that type.
local function AnyGcdAlertEnabled(kind)
    for _, entry in ipairs(GcdAlertStore()) do
        if entry.enabled ~= false and (kind == nil or (entry.kind or "gcd") == kind) then
            return true
        end
    end
    return false
end

-- Called on load, from the settings toggles, and whenever the watch list changes.
-- Nothing is registered while the list is empty or every entry is off.
function CW.UpdateGcdAlertTracking()
    local wanted = CW.SavedVars.gcdAlertEnabled and AnyGcdAlertEnabled("gcd")

    if wanted and not gcdAlertTracking then
        EM:RegisterForEvent(GCD_ALERT_EVENT, EVENT_ACTION_SLOT_ABILITY_USED, OnGcdSlotUsed)
        -- Clear the watch on death: the cooldown reads free while dead.
        EM:RegisterForEvent(GCD_ALERT_EVENT, EVENT_PLAYER_DEAD, function() CW.ClearGcdAlert() end)
        EM:RegisterForEvent(GCD_ALERT_EVENT, EVENT_PLAYER_DEACTIVATED, function() CW.ClearGcdAlert() end)
        gcdAlertTracking = true
    elseif not wanted and gcdAlertTracking then
        EM:UnregisterForEvent(GCD_ALERT_EVENT, EVENT_ACTION_SLOT_ABILITY_USED)
        EM:UnregisterForEvent(GCD_ALERT_EVENT, EVENT_PLAYER_DEAD)
        EM:UnregisterForEvent(GCD_ALERT_EVENT, EVENT_PLAYER_DEACTIVATED)
        gcdAlertTracking = false
        lastGcdCastMs = {}
        CW.ClearGcdAlert()
    end

    CW.UpdateExpireReminderTracking()
    CW.UpdateAbilityGlow()   -- the usable-glow set rides on the same list
end

-- Expire reminders
-- kind == "expire" entries watch effect expiry instead of the cast beat.
-- Buff windows come from EVENT_EFFECT_CHANGED, as in the CC immunity tracker.

local EXPIRE_EVENT = CW.name .. "Expire"
local EXPIRE_TIMER = CW.name .. "ExpireTimer"
local EXPIRE_TICK_MS = 100

local expireTracking = false
-- gcdAlerts index -> { endTime = seconds, fired = bool, nagging = bool }.
-- fired prevents the 100ms tick from repeating the sound.
local activeExpire = {}

-- 0 means "warn at expiry": no countdown, just the blip.
local function ExpireLead(entry)
    return zo_clamp(entry.leadSeconds or 3, 0, 5)
end

local function ExpireScale(entry)
    return zo_clamp(entry.iconScale or 1, 0.5, 2.5)
end

-- How long the icon stays up after the buff drops.
local function ExpireHold(entry)
    return zo_clamp(entry.holdSeconds or 1, 1, 3)
end

local function ExpireReminderTick()
    local now = GetGameTimeSeconds()
    local store = GcdAlertStore()
    local items = {}

    for index, win in pairs(activeExpire) do
        local entry = store[index]
        if not entry or entry.kind ~= "expire" or (entry.enabled == false and not win.test) then
            activeExpire[index] = nil
        else
            local remaining = win.endTime - now
            local lead = ExpireLead(entry)
            if remaining <= lead and not win.fired then
                win.fired = true
                PlaySoundRepeated(entry.sound, entry.volume)
            end
            -- After hold, nagging reminders persist in combat until recast or combat ends.
            if remaining < -ExpireHold(entry) then
                win.nagging = entry.annoying == true and not win.test and CW.inCombat == true
                if not win.nagging then activeExpire[index] = nil end
            end
            if activeExpire[index] and (remaining <= lead or win.nagging) then
                local expired = remaining <= 0
                items[#items + 1] = {
                    index = index,
                    -- The icon owns the moment it drops, whether or not a countdown ran first.
                    icon = (expired or entry.showIcon ~= false) and GetAbilityIcon(entry.id) or nil,
                    remaining = (not expired and entry.showTimer ~= false) and remaining or nil,
                    scale = ExpireScale(entry),
                    dim = win.nagging and now % 1 >= 0.5,
                }
            end
        end
    end

    table.sort(items, function(a, b) return a.index < b.index end)
    CW.UI.ShowExpireReminders(items)
    if not next(activeExpire) then StopTick(EXPIRE_TIMER) end
end

-- Early cancellations (dispel, purge, target death) still alert at the original end;
-- there is no report for targets outside the reticle.
-- Only extend live windows: name matching also catches short pulses
-- (Solar Barrage buff 22095, pulses 100218 / 100223) that would cause premature warnings.
local function ArmExpire(abilityId, endTime)
    for index, entry in ipairs(GcdAlertStore()) do
        if entry.enabled ~= false and (entry.kind or "gcd") == "expire"
           and GcdAlertEntryMatches(entry, abilityId) then
            local live = activeExpire[index]
            if not live or endTime > live.endTime then
                activeExpire[index] = { endTime = endTime, fired = false }
                StartTick(EXPIRE_TIMER, EXPIRE_TICK_MS, ExpireReminderTick)
            end
        end
    end
end

-- Combat events report applications to any enemy; effect events cover only player
-- and reticle target. Misses and interrupted channels do not arm a window.
-- hitValue is the applied duration in ms; track the longest live application.
local function OnExpireApplied(_, _result, _isError, _abilityName, _graphic, _slotType,
                               _sourceName, _sourceType, _targetName, _targetType, hitValue,
                               _powerType, _damageType, _log, _sourceUnitId, _targetUnitId,
                               abilityId)
    if hitValue > 0 then ArmExpire(abilityId, GetGameTimeSeconds() + hitValue / 1000) end
end

-- Effect events give self-buffs an exact endTime and catch ids differing from the cast.
-- GAINED only: FADED also fires just before a recast's GAINED, so handling it
-- would alert on refresh and cancel the window being renewed. The unit filter lets in
-- another player's copy landing on us, which is not ours to recast.
local function OnExpireEffect(_, changeType, _slot, _name, _unitTag, _beginTime, endTime,
                              _stack, _icon, _deprecated, _effectType, _abilityType,
                              _statusEffectType, _unitName, _unitId, abilityId, sourceType)
    if changeType == EFFECT_RESULT_GAINED and sourceType == COMBAT_UNIT_TYPE_PLAYER then
        ArmExpire(abilityId, endTime)
    end
end

function CW.ClearExpireReminder()
    activeExpire = {}
    StopTick(EXPIRE_TIMER)
    CW.UI.ShowExpireReminders({})
end

-- Preview an expired window with the entry's icon, scale and hold time.
-- Never nag: there is nothing to recast in a preview.
function CW.TestExpireReminder(index)
    local entry = GcdAlertStore()[index]
    if not entry then return end
    PlaySoundRepeated(entry.sound, entry.volume)
    activeExpire[index] = { endTime = GetGameTimeSeconds(), fired = true, test = true }
    StartTick(EXPIRE_TIMER, EXPIRE_TICK_MS, ExpireReminderTick)
end

function CW.UpdateExpireReminderTracking()
    local wanted = CW.SavedVars.gcdAlertEnabled and AnyGcdAlertEnabled("expire")

    if wanted and not expireTracking then
        EM:RegisterForEvent(EXPIRE_EVENT, EVENT_EFFECT_CHANGED, OnExpireEffect)
        EM:AddFilterForEvent(EXPIRE_EVENT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        EM:RegisterForEvent(EXPIRE_EVENT, EVENT_COMBAT_EVENT, OnExpireApplied)
        -- Engine-filtered to the player's applications with a duration.
        EM:AddFilterForEvent(EXPIRE_EVENT, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION,
            REGISTER_FILTER_IS_ERROR, false)
        EM:RegisterForEvent(EXPIRE_EVENT, EVENT_PLAYER_DEAD, CW.ClearExpireReminder)
        EM:RegisterForEvent(EXPIRE_EVENT, EVENT_PLAYER_DEACTIVATED, CW.ClearExpireReminder)
        expireTracking = true
    elseif not wanted and expireTracking then
        EM:UnregisterForEvent(EXPIRE_EVENT, EVENT_EFFECT_CHANGED)
        EM:UnregisterForEvent(EXPIRE_EVENT, EVENT_COMBAT_EVENT)
        EM:UnregisterForEvent(EXPIRE_EVENT, EVENT_PLAYER_DEAD)
        EM:UnregisterForEvent(EXPIRE_EVENT, EVENT_PLAYER_DEACTIVATED)
        expireTracking = false
        CW.ClearExpireReminder()
    end
end
