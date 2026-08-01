local HARDCORE = HARDCORE

local ID = "UnseenWhispers"
local NS = "HARDCORE_UnseenWhispers"

local MIN_INTERVAL_MS = 10 * 60 * 1000
local MAX_INTERVAL_MS = 20 * 60 * 1000
local TICK_MS = 5000

local SOUND_POOL

local Rule = {
    id = ID,
    title = "Unseen Whispers: something stirs beyond the road",
    icon = "/esoui/art/treeicons/antiquities_indexicon_scryable_up.dds",
    defaultEnabled = false
}

Rule.active = false
Rule._nextSoundMs = 0

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function GetRandomIntervalMs()
    return MIN_INTERVAL_MS + math.random(0, MAX_INTERVAL_MS - MIN_INTERVAL_MS)
end

local function ScheduleNextSound(nowMs)
    Rule._nextSoundMs = (nowMs or GetFrameTimeMilliseconds()) + GetRandomIntervalMs()
end

local function GetSoundPool()
    if SOUND_POOL then
        return SOUND_POOL
    end

    local pool = {}
    local seen = {}
    for _, sound in pairs(SOUNDS or {}) do
        if type(sound) == "string" and sound ~= "No_Sound" and not seen[sound] then
            pool[#pool + 1] = sound
            seen[sound] = true
        end
    end

    SOUND_POOL = pool
    return SOUND_POOL
end

local function PlayRandomSound()
    local pool = GetSoundPool()
    if not pool or #pool == 0 then
        return
    end

    local sound = pool[math.random(1, #pool)]
    if sound then
        PlaySound(sound)
    end
end

local function UpdateWhispers()
    if not (Rule.active and IsHardcoreActive()) then
        return
    end

    local nowMs = GetFrameTimeMilliseconds()
    if Rule._nextSoundMs <= 0 then
        ScheduleNextSound(nowMs)
        return
    end

    if nowMs >= Rule._nextSoundMs then
        PlayRandomSound()
        ScheduleNextSound(nowMs)
    end
end

local function RegisterUpdate()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
    if Rule.active then
        EVENT_MANAGER:RegisterForUpdate(NS .. "_TICK", TICK_MS, UpdateWhispers)
    end
end

local function UnregisterUpdate()
    EVENT_MANAGER:UnregisterForUpdate(NS .. "_TICK")
end

function Rule:OnEnable()
    self.active = true
    ScheduleNextSound(GetFrameTimeMilliseconds())
    RegisterUpdate()
end

function Rule:OnDisable()
    self.active = false
    self._nextSoundMs = 0
    UnregisterUpdate()
end

function HARDCORE.DebugUnseenWhispersStatus()
    local nowMs = GetFrameTimeMilliseconds()
    local remainingMs = math.max(0, (Rule._nextSoundMs or 0) - nowMs)
    d("Unseen Whispers: active=" .. tostring(Rule.active) ..
        " nextSoundIn=" .. tostring(math.floor(remainingMs / 1000)) .. "s" ..
        " soundPool=" .. tostring(#GetSoundPool()))
end

function HARDCORE.DebugUnseenWhispersCommand(action)
    action = string.lower(action or "help")
    if action == "help" then
        d("Unseen Whispers debug:")
        d("/hc debug whispers status")
        d("/hc debug whispers play")
        return
    end

    if action == "status" then
        HARDCORE.DebugUnseenWhispersStatus()
        return
    end

    if action == "play" or action == "sound" then
        PlayRandomSound()
        HARDCORE.DebugUnseenWhispersStatus()
        return
    end

    d("Unknown Unseen Whispers debug action: " .. tostring(action))
end

HARDCORE.RuleManager:RegisterRule(Rule)
