-- CanITravelBack.lua – v0.3.10 (Ultimate via API + Event; 500-Threshold; ult debug)
local ADDON        = "CanITravelBack"
local TIME_WINDOW  = 30

-- constants (with safe fallbacks)
local PT_ULT       = rawget(_G, "POWERTYPE_ULTIMATE") or rawget(_G, "COMBAT_MECHANIC_FLAGS_ULTIMATE") or 10

-- feature flags
local ENABLE_ULT_WARNING = true  -- show orange line if <500

-- debug
local debugMode  = false
local function dbg(msg) if debugMode then d(ADDON .. ": " .. tostring(msg)) end end

-- state
local state    = { prev=nil, lastType=nil, lastTime=0 }
local ult     = { cur=0, max=0, eff=0, seeded=false }

-- ===== Ultimate source of truth: API + Event cache =====
local function readUltAPI()
    local c,m,e = GetUnitPower("player", PT_ULT)
    return tonumber(c) or 0, tonumber(m) or 0, tonumber(e) or 0
end

local function onPowerUpdate(_, unitTag, _, powerType, powerValue, powerMax, powerEffectiveMax)
    if unitTag ~= "player" or powerType ~= PT_ULT then return end
    ult.cur = tonumber(powerValue) or 0
    ult.max = tonumber(powerMax) or 0
    ult.eff = tonumber(powerEffectiveMax) or 0
    ult.seeded = true
end

local function registerUltEvents()
    EVENT_MANAGER:RegisterForEvent(ADDON.."_ULT", EVENT_POWER_UPDATE, onPowerUpdate)
    if EVENT_MANAGER.AddFilterForEvent and REGISTER_FILTER_UNIT_TAG and REGISTER_FILTER_POWER_TYPE then
        EVENT_MANAGER:AddFilterForEvent(ADDON.."_ULT", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        EVENT_MANAGER:AddFilterForEvent(ADDON.."_ULT", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, PT_ULT)
    end
end

-- ===== Orange-Green logic (use 500 threshold exactly as requested) =====
local function hasAtLeast500Ult()
    local c = select(1, GetUnitPower("player", PT_ULT)) or 0
    if c == 0 and ult.seeded then c = ult.cur end -- fallback to event cache
    dbg("ULT check (>=500) -> cur="..tostring(c).." seeded="..tostring(ult.seeded))
    return c >= 500
end

-- ===== CSA (30s) =====
local function showCSAAlert()
    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.AVA_GATE_OPENED)
    params:SetLifespanMS(30000)

    local green  = "|c00FF00You can travel back in|r"
    local orange = "|cFFA500But your ultimate ability is not ready.|r"

    if ENABLE_ULT_WARNING and not hasAtLeast500Ult() then
        params:SetText(green, orange)
    else
        params:SetText(green)
    end
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

-- ===== NV <-> VN sequence =====
local function handleChange(changeType)
    local now = GetFrameTimeSeconds()
    if state.lastType and (now - state.lastTime) <= TIME_WINDOW and
       ((state.lastType == "NV" and changeType == "VN") or (state.lastType == "VN" and changeType == "NV")) then
        showCSAAlert()
        state.lastType, state.lastTime = nil, 0
        return
    end
    state.lastType, state.lastTime = changeType, now
end

local function onVeteranDifficultyChanged(_, isVeteran)
    local isVet = (isVeteran == true)
    if state.prev == nil then state.prev = isVet; return end
    if isVet == state.prev then return end
    local change = (not state.prev and isVet) and "NV" or "VN"
    handleChange(change)
    state.prev = isVet
end

local function onGenericDifficulty(_, ...)
    local ok, val = pcall(IsGroupUsingVeteranDifficulty)
    if ok then onVeteranDifficultyChanged(nil, val) end
end

-- Poll to catch changes everywhere (including housing)
local WATCH = ADDON.."_DiffWatch"
local function startWatcher()
    EVENT_MANAGER:RegisterForUpdate(WATCH, 500, function()
        local ok, val = pcall(IsGroupUsingVeteranDifficulty)
        if ok then onVeteranDifficultyChanged(nil, val) end
    end)
end

-- lifecycle
local function onGroupChange(_) state.prev, state.lastType, state.lastTime = nil, nil, 0 end
local function onZoneChanged()  state.prev, state.lastType, state.lastTime = nil, nil, 0 end

local function onPlayerActivated(_)
    ult.cur, ult.max, ult.eff = readUltAPI()
    ult.seeded = (ult.cur ~= nil)
    if EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, onVeteranDifficultyChanged)
    elseif EVENT_GROUP_DIFFICULTY_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_GROUP_DIFFICULTY_CHANGED, onGenericDifficulty)
    end
    registerUltEvents()
    startWatcher()
end

local function onLoaded(_, name)
    if name ~= ADDON then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_GROUP_MEMBER_JOINED, onGroupChange)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_GROUP_MEMBER_LEFT,  onGroupChange)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ZONE_CHANGED,       onZoneChanged)
    if IsPlayerActivated() then onPlayerActivated() end
end

EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, onLoaded)

-- ===== Slash commands =====
local function onSlashCITB(txt)
    local arg = (txt or ""):gsub("^%s*(.-)%s*$", "%1"):lower()
    if arg == "debug" then
        debugMode = not debugMode
        d(ADDON .. ": Debug " .. (debugMode and "enabled" or "disabled"))
        return
    elseif arg == "ultpoints" or arg == "ult" then
        local apiCur, apiMax, apiEff = readUltAPI()
        d(("[%s] Ultimate points -> current=%d  max=%d  effectiveMax=%d  (eventCur=%d seeded=%s)"):format(
            ADDON, apiCur, apiMax, apiEff, ult.cur, tostring(ult.seeded)
        ))
        return
    end
    d(ADDON .. ": Usage -> /citb debug | /citb ultpoints")
end
SLASH_COMMANDS["/citb"] = onSlashCITB
