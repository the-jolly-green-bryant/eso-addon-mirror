TetsuArcanistCrux = TetsuArcanistCrux or {}
local T = TetsuArcanistCrux

local ADDON = "TetsuArcanistCruxTrack"
local SCAN_MS = 2000
local CRUX_ID = 184220

local stacks = 0
local lastSoundStacks = 0
local previewKind = nil
local previewUntil = 0
local previewStepAt = 0
local previewStep = 0
local cruxIcon = "/esoui/art/icons/ability_arcanist_002.dds"
local knownCrux = { [CRUX_ID] = true }
local ticking = false

local SOUND_KEYS = {
    duel     = { key = "DUEL_START",                      fb = "Duel_Start" },
    alert    = { key = "GENERAL_ALERT_ERROR",             fb = "General_Alert_Error" },
    notify   = { key = "NEW_NOTIFICATION",                fb = "New_Notification" },
    discover = { key = "OBJECTIVE_DISCOVERED",            fb = "Objective_Discovered" },
    kill     = { key = "DEATH_RECAP_KILLING_BLOW_SHOWN",  fb = "Death_Recap_Killing_Blow_Shown" },
    rune     = { key = "ENCHANTING_POTENCY_RUNE_PLACED",  fb = "Enchanting_Potency_Rune_Placed" },
    glyph    = { key = "ENCHANTING_WEAPON_GLYPH_REMOVED", fb = "Enchanting_Weapon_Glyph_Removed" },
    mail     = { key = "NEW_MAIL",                        fb = "New_Mail" },
    lock     = { key = "LOCKPICKING_SUCCESS",             fb = "Lockpicking_Success" },
    tick     = { key = "COUNTDOWN_TICK",                  fb = "Countdown_Tick" },
    bgmin    = { key = "BATTLEGROUND_ONE_MINUTE_WARNING", fb = "Battleground_One_Minute_Warning" },
    bggo     = { key = "BATTLEGROUND_COUNTDOWN_FINISH",   fb = "Battleground_Countdown_Finish" },
    trialok  = { key = "RAID_TRIAL_COMPLETED",            fb = "Raid_Trial_Completed" },
    trialno  = { key = "RAID_TRIAL_FAILED",               fb = "Raid_Trial_Failed" },
    achieve  = { key = "ACHIEVEMENT_AWARDED",             fb = "Achievement_Awarded" },
    qdone    = { key = "QUEST_COMPLETED",                 fb = "Quest_Completed" },
    qacc     = { key = "QUEST_ACCEPTED",                  fb = "Quest_Accepted" },
    champ    = { key = "CHAMPION_POINTS_COMMITTED",       fb = "Champion_Points_Committed" },
    coll     = { key = "COLLECTIBLE_UNLOCKED",            fb = "Collectible_Unlocked" },
    book     = { key = "BOOK_ACQUIRED",                   fb = "Book_Acquired" },
    ess      = { key = "ENCHANTING_ESSENCE_RUNE_PLACED",  fb = "Enchanting_Essence_Rune_Placed" },
    asp      = { key = "ENCHANTING_ASPECT_RUNE_PLACED",   fb = "Enchanting_Aspect_Rune_Placed" },
    alc      = { key = "ALCHEMY_SOLVENT_PLACED",          fb = "Alchemy_Solvent_Placed" },
    friend   = { key = "FRIEND_INVITE_RECEIVED",          fb = "Friend_Invite_Received" },
    gjoin    = { key = "GROUP_JOIN",                      fb = "Group_Join" },
    kos      = { key = "JUSTICE_NOW_KOS",                 fb = "Justice_Now_KOS" },
    lbreak   = { key = "LOCKPICKING_BREAK",               fb = "Lockpicking_Break" },
    fanfare  = { key = "LEVEL_UP_REWARD_FANFARE",         fb = "Level_Up_Reward_Fanfare" },
    medal    = { key = "BATTLEGROUND_MEDAL_RECEIVED",     fb = "Battleground_Medal_Received" },
    spt      = { key = "SKILL_POINT_GAINED",              fb = "Skill_Point_Gained" },
}

local CRUX_NEEDLE = {
    "crux", "крукс", "クルックス", "クルクス", "征兆", "星芒", "크룩스",
}

local function Vars()
    return T.savedVars
end

local function Now()
    if GetGameTimeMilliseconds then return GetGameTimeMilliseconds() end
    return GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
end

local function Lower(s)
    if type(s) ~= "string" then return "" end
    if zo_strlower then return zo_strlower(s) end
    return string.lower(s)
end

local function NameLooksLikeCrux(name)
    local n = Lower(name)
    if n == "" then return false end
    for i = 1, #CRUX_NEEDLE do
        if n:find(CRUX_NEEDLE[i], 1, true) then
            return true
        end
    end
    return n == "crux"
end

local function RememberIcon(tex)
    if type(tex) == "string" and tex ~= "" then
        cruxIcon = tex
    end
end

local function PlayCue()
    local v = Vars()
    if not v or v.soundEnabled == false then return end
    local vol = tonumber(v.soundVolume) or 2
    if vol < 1 then return end
    if vol > 5 then vol = 5 end
    local spec = SOUND_KEYS[v.soundId] or SOUND_KEYS.kill
    local payload = nil
    if SOUNDS and spec.key and SOUNDS[spec.key] then
        payload = SOUNDS[spec.key]
    elseif spec.fb then
        payload = spec.fb
    end
    if not payload or not PlaySound then return end
    for _ = 1, vol do
        pcall(PlaySound, payload)
    end
end
T.PlayCue = PlayCue

local function ApplyStacks(count, fromLive)
    if count < 0 then count = 0 end
    if count > 3 then count = 3 end
    local prev = stacks
    stacks = count
    if fromLive and count == 3 and prev < 3 then
        PlayCue()
    end
    if fromLive then
        lastSoundStacks = count
    end
    if T.UIRefresh then T.UIRefresh() end
end

local function ScanBuffs()
    local best = 0
    local n = 0
    if GetNumBuffs then
        local ok, num = pcall(GetNumBuffs, "player")
        if ok then n = tonumber(num) or 0 end
    end
    if n < 1 or not GetUnitBuffInfo then
        return best
    end
    for i = 1, n do
        local name, _, _, _, stackCount, icon, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        local id = tonumber(abilityId) or 0
        local st = tonumber(stackCount) or 0
        local hit = knownCrux[id] or NameLooksLikeCrux(name)
        if hit then
            if id > 0 then knownCrux[id] = true end
            RememberIcon(icon)
            if st < 1 then st = 1 end
            if st > best then best = st end
        end
    end
    if best > 3 then best = 3 end
    return best
end

local function LiveStacks()
    return ScanBuffs()
end

local function PreviewActive()
    return previewKind ~= nil and Now() < previewUntil
end

function T.GetDisplayStacks()
    if PreviewActive() then
        return stacks
    end
    return LiveStacks()
end

function T.GetCruxIcon()
    if GetAbilityIcon then
        local ok, tex = pcall(GetAbilityIcon, CRUX_ID)
        if ok and type(tex) == "string" and tex ~= "" then
            cruxIcon = tex
        end
    end
    return cruxIcon
end

function T.PlayTestSound()
    PlayCue()
end

function T.ClearPreview()
    previewKind = nil
    previewUntil = 0
    previewStep = 0
    stacks = LiveStacks()
    if T.UIRefresh then T.UIRefresh() end
end

function T.IsPreviewing(kind)
    if not PreviewActive() then return false end
    if kind == nil or previewKind == "all" then return true end
    return previewKind == kind
end

function T.Preview(kind)
    kind = kind or "all"
    previewKind = kind
    previewUntil = Now() + 6500
    previewStep = 0
    previewStepAt = Now()
    stacks = 0
    if kind == "all" or kind == "sound" then
        -- sound fires when the cycle hits 3
    end
    if T.EnsureVisible then T.EnsureVisible() end
    if T.UIRefresh then T.UIRefresh() end
    if not ticking then
        EVENT_MANAGER:RegisterForUpdate(ADDON .. "Tick", 80, T.TrackerTick)
        ticking = true
    end
end

function T.TrackerTick()
    local t = Now()
    if PreviewActive() then
        local elapsed = t - previewStepAt
        local step = math.floor(elapsed / 1100)
        if step > 3 then step = 3 end
        if step ~= previewStep then
            previewStep = step
            stacks = step
            if step == 3 and (previewKind == "all" or previewKind == "sound") then
                PlayCue()
            end
            if T.UIRefresh then T.UIRefresh() end
        end
        return
    elseif previewKind then
        T.ClearPreview()
    end

    local live = LiveStacks()
    if live ~= stacks then
        ApplyStacks(live, true)
    elseif T.UIPulse then
        T.UIPulse()
    end
end

local function OnEffectChanged(_, changeType, _, effectName, unitTag, _, _, stackCount, icon, _, _, _, _, _, _, abilityId)
    if unitTag ~= "player" then return end
    local id = tonumber(abilityId) or 0
    local hit = knownCrux[id] or NameLooksLikeCrux(effectName)
    if not hit then return end
    if id > 0 then knownCrux[id] = true end
    RememberIcon(icon)
    if changeType == EFFECT_RESULT_FADED then
        ApplyStacks(LiveStacks(), true)
        return
    end
    local st = tonumber(stackCount) or 0
    if st < 1 then st = 1 end
    ApplyStacks(st, true)
end

local function OnActivated()
    ApplyStacks(LiveStacks(), false)
    if T.UIRefresh then T.UIRefresh() end
end

function T.TrackerStart()
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(ADDON, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, OnActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_COMBAT_STATE, function()
        ApplyStacks(LiveStacks(), true)
    end)
    EVENT_MANAGER:RegisterForUpdate(ADDON .. "Scan", SCAN_MS, function()
        if PreviewActive() then return end
        ApplyStacks(LiveStacks(), true)
    end)
    if not ticking then
        EVENT_MANAGER:RegisterForUpdate(ADDON .. "Tick", 80, T.TrackerTick)
        ticking = true
    end
    T.GetCruxIcon()
    ApplyStacks(LiveStacks(), false)
end
