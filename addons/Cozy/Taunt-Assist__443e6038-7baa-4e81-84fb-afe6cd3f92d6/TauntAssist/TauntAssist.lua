-- TauntAssist: console-safe — per-target timers + reticle badge (TAUNT ONLY)
local ADDON_NAME = "TauntAssist"

-- UI controls
local tlwCenter, banner
local listWin, rows = nil, {}
local retBadgeWin, retNameLbl, retTimeLbl

-- state
local inCombat = false
local TA_endAtByKey = {}
local TA_nameByKey = {}
local TA_keys = {}

----------------------------------------------------------
-- Config
----------------------------------------------------------
local DURATION_SEC = 14.0
local UPDATE_MS   = 100
local ROW_HEIGHT  = 52
local ROW_GAP     = 0
local LIST_SCALE  = 5.0
local LIST_OFF_X  = 520
local LIST_OFF_Y  = 0
local BADGE_SCALE = 5.0
local BADGE_Y_OFF = 180

local GOLD        = {1.0, 0.85, 0.20, 1}
local NAME_COLOR  = {0.85, 0.95, 1.0, 1}

local TAUNT_NAME_PATTERNS = {
    "taunt","puncture","pierce armor","ransack",
    "inner fire","inner rage","inner beast",
    "frost clench","frost reach",
}

----------------------------------------------------------
-- Small utils
----------------------------------------------------------
local function ensureKeyOrder(k)
    for _, v in ipairs(TA_keys) do if v == k then return end end
    table.insert(TA_keys, k)
end

local function removeKey(k)
    TA_endAtByKey[k] = nil
    TA_nameByKey[k] = nil
    local out = {}
    for _, v in ipairs(TA_keys) do if v ~= k then table.insert(out, v) end end
    TA_keys = out
end

local function ci_find(s, pat)
    if not s then return false end
    return string.find(string.lower(s), string.lower(pat), 1, true) ~= nil
end

local function isTauntByName(abilityName)
    if not abilityName or abilityName == "" then return false end
    for _, pat in ipairs(TAUNT_NAME_PATTERNS) do
        if ci_find(abilityName, pat) then return true end
    end
    return false
end

local function sanitize(name)
    if not name then return nil end
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    if name == "" then return nil end
    return name
end

local function keyForUnitName(name)
    name = sanitize(name)
    if not name then return nil end
    return "name:" .. string.lower(name)
end

----------------------------------------------------------
-- Center banner (status / debugging)
----------------------------------------------------------
local function CreateCenterUI()
    if not tlwCenter then
        tlwCenter = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "_TLW")
        tlwCenter:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
        tlwCenter:SetDimensions(2000, 600)
        tlwCenter:SetScale(3.0)
    end
    if not banner then
        banner = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_Banner", tlwCenter, CT_LABEL)
        banner:SetAnchor(CENTER, tlwCenter, CENTER, 0, 0)
        banner:SetFont("ZoFontWinH1")
        banner:SetColor(1, 0.4, 0.1, 1)
        banner:SetScale(3.0)
        banner:SetHidden(true)
    end
end

local function Show(text)
    if banner then
        banner:SetText(tostring(text))
        banner:SetHidden(false)
    end
end

----------------------------------------------------------
-- Reticle badge UI
----------------------------------------------------------
local function CreateReticleBadgeUI()
    if retBadgeWin then return end
    retBadgeWin = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "_RetBadge")
    retBadgeWin:SetAnchor(CENTER, GuiRoot, CENTER, 0, BADGE_Y_OFF)
    retBadgeWin:SetDimensions(1600, 200)
    retBadgeWin:SetScale(BADGE_SCALE)
    retBadgeWin:SetHidden(true)

    retNameLbl = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_RetName", retBadgeWin, CT_LABEL)
    retNameLbl:SetAnchor(LEFT, retBadgeWin, LEFT, 0, 0)
    retNameLbl:SetFont("ZoFontWinH1")
    retNameLbl:SetColor(unpack(NAME_COLOR))
    retNameLbl:SetText("")

    retTimeLbl = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_RetTime", retBadgeWin, CT_LABEL)
    retTimeLbl:SetAnchor(RIGHT, retBadgeWin, RIGHT, 0, 0)
    retTimeLbl:SetFont("ZoFontWinH1")
    retTimeLbl:SetColor(unpack(GOLD))
    retTimeLbl:SetText("")
end

local function setReticleBadge(name, remain)
    if not retBadgeWin then return end
    if not name or not remain or remain <= 0 then
        retBadgeWin:SetHidden(true)
        return
    end
    retNameLbl:SetText(name)
    retTimeLbl:SetText(string.format("%.1fs", remain))
    retBadgeWin:SetHidden(false)
end

----------------------------------------------------------
-- Center-right list UI
----------------------------------------------------------
local function CreateListUI()
    if listWin then return end
    listWin = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "_List")
    listWin:SetAnchor(CENTER, GuiRoot, CENTER, LIST_OFF_X, LIST_OFF_Y)
    listWin:SetDimensions(820, 900)
    listWin:SetMouseEnabled(false)
    listWin:SetMovable(false)
    listWin:SetHidden(true)
    listWin:SetScale(LIST_SCALE)
end

local function getOrCreateRow(i)
    if rows[i] then return rows[i] end
    local row = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_Row" .. i, listWin, CT_CONTROL)
    row:SetDimensions(800, ROW_HEIGHT)
    if i == 1 then
        row:SetAnchor(TOPRIGHT, listWin, TOPRIGHT, 0, 0)
    else
        row:SetAnchor(TOPRIGHT, rows[i-1], BOTTOMRIGHT, 0, ROW_GAP)
    end
    local nameLbl = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_Row" .. i .. "_Name", row, CT_LABEL)
    nameLbl:SetAnchor(LEFT, row, LEFT, 0, 0)
    nameLbl:SetFont("ZoFontWinH1")
    nameLbl:SetColor(unpack(NAME_COLOR))
    local timeLbl = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "_Row" .. i .. "_Time", row, CT_LABEL)
    timeLbl:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    timeLbl:SetFont("ZoFontWinH1")
    timeLbl:SetColor(unpack(GOLD))
    row.nameLbl, row.timeLbl = nameLbl, timeLbl
    rows[i] = row
    return row
end

local function refreshListUI()
    if not listWin then return end
    if #TA_keys == 0 then listWin:SetHidden(true) return end
    listWin:SetHidden(false)
    local now = GetFrameTimeSeconds()
    for i, k in ipairs(TA_keys) do
        local row = getOrCreateRow(i)
        local name = TA_nameByKey[k] or "Target"
        local remain = math.max(0, (TA_endAtByKey[k] or 0) - now)
        row.nameLbl:SetText(name)
        row.timeLbl:SetText(string.format("%.1fs", remain))
        row:SetHidden(false)
    end
    for j = #TA_keys + 1, #rows do if rows[j] then rows[j]:SetHidden(true) end end
end

----------------------------------------------------------
-- Combat polling (for your COMBAT ON/OFF debug)
----------------------------------------------------------
local function PollCombatState()
    local current = IsUnitInCombat("player")
    if current ~= inCombat then
        inCombat = current
        if inCombat then
            Show("COMBAT ON")
        else
            Show("COMBAT OFF")
            zo_callLater(function() if banner then banner:SetHidden(true) end end, 2000)
            TA_endAtByKey, TA_nameByKey, TA_keys = {}, {}, {}
            refreshListUI()
            setReticleBadge(nil, nil)
        end
    end
    zo_callLater(PollCombatState, 250)
end

----------------------------------------------------------
-- Countdown loop
----------------------------------------------------------
local function UpdateAllCountdowns()
    if #TA_keys == 0 then
        refreshListUI()
        setReticleBadge(nil, nil)
        return
    end
    local now = GetFrameTimeSeconds()
    local expired = {}
    for _, k in ipairs(TA_keys) do
        local ends = TA_endAtByKey[k]
        if not ends or ends <= now then table.insert(expired, k) end
    end
    for _, k in ipairs(expired) do removeKey(k) end
    refreshListUI()
    local retName = GetUnitName("reticleover")
    local retKey  = keyForUnitName(retName)
    if retKey and TA_endAtByKey[retKey] then
        local remain = math.max(0, TA_endAtByKey[retKey] - now)
        setReticleBadge(retName, remain)
    else
        setReticleBadge(nil, nil)
    end
    if #TA_keys > 0 then zo_callLater(UpdateAllCountdowns, UPDATE_MS) end
end

local function StartOrRefresh(key, displayName, durationSec)
    TA_endAtByKey[key] = GetFrameTimeSeconds() + (durationSec or DURATION_SEC)
    TA_nameByKey[key]  = displayName or "Target"
    ensureKeyOrder(key)
    refreshListUI()
    zo_callLater(UpdateAllCountdowns, UPDATE_MS)
end

----------------------------------------------------------
-- Event handling: TAUNT-ONLY (no combat gate; prefer event targetName)
----------------------------------------------------------
local function OnCombatEvent(_, result, isError, abilityName, _, _, sourceName, sourceType, targetName, targetType)
    if isError then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if not abilityName or abilityName == "" then return end
    if not isTauntByName(abilityName) then return end

    -- Prefer the event's targetName; fallback to reticleover if needed
    local name = sanitize(targetName) or sanitize(GetUnitName("reticleover"))
    if not name then return end
    local key = keyForUnitName(name)
    if not key then return end

    -- Debug so you can see it fire
    d(string.format("[TauntAssist] TAUNT -> %s (ability=%s)", name, abilityName))

    StartOrRefresh(key, name, DURATION_SEC)
end

local function ArmHook()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
end

----------------------------------------------------------
-- Initialization
----------------------------------------------------------
local function Initialize()
    CreateCenterUI()
    CreateReticleBadgeUI()
    CreateListUI()
    Show("HELLO FROM LUA — ADDON LOADED")
    zo_callLater(function() if banner then banner:SetHidden(true) end end, 90000)
    zo_callLater(PollCombatState, 250)
    zo_callLater(ArmHook, 1500)
end

local function OnAddOnLoaded(_, addonName)
    if addonName == ADDON_NAME then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
-- add a blank line at end if your uploader truncates files.
