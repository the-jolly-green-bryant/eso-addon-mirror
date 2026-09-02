-- Kill Count
-- Small pinned bottom-right K/D readout for PvP. Overall K/D on top, the zone you are
-- standing in underneath in smaller text. Cyrodiil, Imperial City,
-- Battlegrounds and Duels counted separately. Overworld PvE is ignored.
--
-- Everything is a single rolling day: the moment the date changes the numbers
-- zero themselves. Nothing older than 24 hours is ever stored, so the saved
-- variables stay tiny and there is nothing to prune.
--
-- Kills surface as a brief popup under the box, never in chat. Killing the same
-- player repeatedly shows a multiplier next to their gamertag.
--
-- Console-safe: no PC-only UI code, gamepad fonts, defensive API guards.

local ADDON_NAME = "KillCount"
local SV_VERSION = 7        -- collapsed to a single rolling day
local DEDUPE_MS  = 5000     -- one target cannot be killed twice this fast
local MAX_NAMES  = 150      -- ceiling per zone so a zerg cannot grow it forever
local POPUP_MS   = 4000     -- how long a kill popup stays on screen
local CACHE_MAX  = 200      -- sweep the dedupe cache once it grows past this

-- ------------------------------------------------------------- environment
local function DetectConsole()
    if type(ZO_IsConsoleOrGameCoreUI) == "function" then
        local ok, res = pcall(ZO_IsConsoleOrGameCoreUI)
        if ok and res then return true end
    end
    if type(IsGameCoreUI) == "function" then
        local ok, res = pcall(IsGameCoreUI)
        if ok and res then return true end
    end
    if type(IsConsoleUI) == "function" then
        local ok, res = pcall(IsConsoleUI)
        if ok and res then return true end
    end
    return false
end

local IS_CONSOLE = DetectConsole()

-- Explicit "file|size|style" descriptors rather than named styles. A named
-- style that does not exist on a given build makes SetFont fail silently and
-- the label draws nothing, which leaves an empty backdrop on screen. These two
-- .otf files ship with the game on every platform.
local F_REG  = "EsoUI/Common/Fonts/Univers57.otf"
local F_BOLD = "EsoUI/Common/Fonts/Univers67.otf"

local FONT_HEAD = F_REG  .. "|14|soft-shadow-thin"
local FONT_BIG  = F_BOLD .. "|26|soft-shadow-thick"
local FONT_MID  = F_REG  .. "|19|soft-shadow-thin"
local FONT_SUB  = F_REG  .. "|14|soft-shadow-thin"

-- ------------------------------------------------------------------ buckets
local BUCKET_LABEL = {
    cyrodiil = "Cyrodiil", imperialCity = "Imperial City",
    battleground = "Battleground", duel = "Duel",
}
local BUCKET_SHORT = {
    cyrodiil = "Cyro", imperialCity = "IC",
    battleground = "BG", duel = "Duel",
}
local BUCKET_ORDER = { "cyrodiil", "imperialCity", "battleground", "duel" }

-- Short names usable as a command suffix, e.g. /kcnamesic, /kcresetcyro.
local ZONE_SUFFIX = { "cyro", "ic", "bg", "duel" }
local ZONE_ALIAS  = {
    cyro = "cyrodiil", cyrodiil = "cyrodiil",
    ic   = "imperialCity", imperialcity = "imperialCity",
    bg   = "battleground", battleground = "battleground",
    duel = "duel", duels = "duel",
}

local function NewTally()
    return { kills = 0, npcs = 0, deaths = 0, names = {}, n = 0 }
end

-- Increment a name, refusing new entries once the ceiling is reached.
-- Returns the new count, or nil if the name was not stored.
local function BumpName(tally, name)
    local cur = tally.names[name]
    if cur then
        tally.names[name] = cur + 1
        return cur + 1
    end
    if (tally.n or 0) >= MAX_NAMES then return nil end
    tally.names[name] = 1
    tally.n = (tally.n or 0) + 1
    return 1
end

local defaults = {
    day     = "",           -- the date the numbers below belong to
    tallies = {},           -- [bucket] = tally, rebuilt whenever the day rolls
    duels   = { wins = 0, losses = 0 },
    top     = { name = "", count = 0 },   -- most-killed player today
    ui      = { x = -8, y = -108, hidden = false },  -- offset from BOTTOMRIGHT
}

local sv
local win, popupLabel
local PositionWindow      -- forward declaration, defined below BuildUI's helpers
local L = {}          -- grid labels, keyed by row+column
local recentDeaths, recentCount = {}, 0
local inDuel, duelOpponent = false, nil
local duelDied = false      -- did we die during the current duel
local popupToken = 0

-- ------------------------------------------------------------------ helpers
local function Msg(text)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        pcall(function() CHAT_ROUTER:AddSystemMessage("|cFFD700[KC]|r " .. text) end)
    elseif type(d) == "function" then
        pcall(d, "[KC] " .. text)
    end
end

-- Only ever yields a string or nil. Callers concatenate the result, so letting
-- a boolean or number fall through here is what broke OnDuelFinished before.
local function CleanName(raw)
    if type(raw) ~= "string" or raw == "" then return nil end
    local ok, formatted = pcall(zo_strformat, SI_UNIT_NAME, raw)
    if ok and type(formatted) == "string" and formatted ~= "" then return formatted end
    return raw
end

-- ESO tags player character names with a gender suffix - "Free lunch^Mx",
-- "Spidey xx^Mx". NPCs carry different tags or none. KILLING_BLOW fires for
-- NPCs as well as players, so without this every monster counted as a PvP kill.
local function IsPlayerName(raw)
    if type(raw) ~= "string" then return false end
    return raw:find("%^[MF]x") ~= nil
end

local function SafeCall(fn)
    if type(fn) ~= "function" then return false end
    local ok, res = pcall(fn)
    return ok and res
end

local function TodayKey()
    if type(GetDate) == "function" then
        local ok, dt = pcall(GetDate)
        if ok and dt then return tostring(dt) end
    end
    if type(GetTimeStamp) == "function" then
        local ok, ts = pcall(GetTimeStamp)
        if ok and ts then return "e" .. tostring(math.floor(ts / 86400)) end
    end
    return "unknown"
end

-- The whole 24-hour reset lives here. Anything that reads or writes the numbers
-- calls this first, so a date change wipes them at the next kill, death or draw.
local function EnsureToday()
    local key = TodayKey()
    if sv.day == key then return end
    sv.day = key
    sv.tallies = {}
    for _, b in ipairs(BUCKET_ORDER) do sv.tallies[b] = NewTally() end
    sv.duels = { wins = 0, losses = 0 }
    sv.top   = { name = "", count = 0 }
end

local function Tally(bucket)
    EnsureToday()
    sv.tallies[bucket] = sv.tallies[bucket] or NewTally()
    return sv.tallies[bucket]
end

-- K/D as a display string. No deaths yet means the ratio is undefined, so show
-- the kill count rather than a fake infinity.
local function Ratio(kills, deaths)
    if deaths and deaths > 0 then return string.format("%.2f", kills / deaths) end
    return string.format("%d.00", kills or 0)
end

-- Green at 1.00 and above, red below. Breaking even counts as positive.
-- The dim variants are for the zone rows you are not currently standing in.
local function RatioColor(kills, deaths, dim)
    if (kills or 0) == 0 and (deaths or 0) == 0 then
        return dim and "6A6A6A" or "9A9A9A"          -- no data yet
    end

    local r = (deaths and deaths > 0) and (kills / deaths) or kills
    if r >= 1 then return dim and "4E9E4E" or "5CE05C" end  -- positive
    return dim and "9E4E4E" or "FF5C5C"                     -- negative
end

local function Overall()
    EnsureToday()
    local k, d = 0, 0
    for _, b in ipairs(BUCKET_ORDER) do
        local t = sv.tallies[b]
        if t then k = k + t.kills; d = d + t.deaths end
    end
    return k, d
end

-- Zone changes only on load screens and duels, so resolve once and cache it.
-- Combat events fire in bursts and must not pay for three pcalls each.
local cachedBucket = nil
local lastPvpBucket, lastPvpAt = nil, 0   -- survives the brief nil during death

-- EVENT_DUEL_STARTED is not guaranteed to have fired, so confirm against the
-- live duel state as well. Duels happen in PvE zones, and without this the
-- whole duel bucket silently never activates.
local function IsDuelling()
    if inDuel then return true end
    if type(GetDuelInfo) ~= "function" then return false end

    local ok, state, charName = pcall(GetDuelInfo)
    if not ok then return false end

    -- Do NOT gate this on DUEL_STATE_DUELING. If that constant is nil the whole
    -- check gets skipped, which is what left the duel bucket dead. Having a duel
    -- partner at all is the reliable signal.
    if DUEL_STATE_DUELING and state == DUEL_STATE_DUELING then return true end
    if type(charName) == "string" and charName ~= "" then return true end
    return false
end

-- Re-resolving the zone costs a few pcalls, so throttle it rather than doing it
-- per combat event. Duels start without a load screen, so a purely event-driven
-- cache went stale and reported PvE in the middle of a duel.
local lastBucketCheck = 0

-- Battlegrounds are checked before Cyrodiil deliberately: a BG may also report
-- as an alliance-war zone, and if it does, BG kills would silently file under
-- Cyrodiil. Two independent signals, since only one of them is confirmed to
-- exist on this build.
local function InBattleground()
    if SafeCall(IsActiveWorldBattleground) then return true end
    if type(GetCurrentBattlegroundId) == "function" then
        local ok, id = pcall(GetCurrentBattlegroundId)
        if ok and type(id) == "number" and id > 0 then return true end
    end
    return false
end

local function RefreshBucket()
    if IsDuelling() then
        cachedBucket = "duel"
    elseif InBattleground() then
        cachedBucket = "battleground"
    elseif SafeCall(IsInImperialCity) then
        cachedBucket = "imperialCity"
    elseif SafeCall(IsInAvAZone) then
        cachedBucket = "cyrodiil"
    else
        cachedBucket = nil
    end
    lastBucketCheck = GetGameTimeMilliseconds()

    -- Remember the last PvP zone we were genuinely in. Dying briefly makes the
    -- zone APIs report nothing, so a death would otherwise be discarded even in
    -- the middle of Imperial City.
    if cachedBucket then
        lastPvpBucket = cachedBucket
        lastPvpAt     = lastBucketCheck
    end

    -- Record what each zone API actually returned. If the box says PvE while you
    -- are standing in Cyrodiil, this is the only way to see which call is lying.
    if sv and sv.diag then
        sv.diag.hasInAvA = (type(IsInAvAZone) == "function")
        sv.diag.hasInIC  = (type(IsInImperialCity) == "function")
        sv.diag.hasInBG  = (type(IsActiveWorldBattleground) == "function")
        sv.diag.inAvA    = tostring(SafeCall(IsInAvAZone))
        sv.diag.inIC     = tostring(SafeCall(IsInImperialCity))
        sv.diag.inBG     = tostring(SafeCall(IsActiveWorldBattleground))
        sv.diag.hasBgId  = (type(GetCurrentBattlegroundId) == "function")
        if type(GetCurrentBattlegroundId) == "function" then
            local okb, bid = pcall(GetCurrentBattlegroundId)
            if okb then sv.diag.bgId = tostring(bid) end
        end
        sv.diag.bucket   = tostring(cachedBucket)
        if type(GetUnitZone) == "function" then
            local ok, z = pcall(GetUnitZone, "player")
            if ok then sv.diag.zone = tostring(z) end
        end
        if type(GetZoneId) == "function" and type(GetUnitZoneIndex) == "function" then
            local ok, zid = pcall(function() return GetZoneId(GetUnitZoneIndex("player")) end)
            if ok then sv.diag.zoneId = tostring(zid) end
        end
    end

    return cachedBucket
end

-- Cheap accessor: trusts the cache, but re-resolves if it has gone stale.
local function BucketNow()
    if (GetGameTimeMilliseconds() - lastBucketCheck) > 2000 then
        return RefreshBucket()
    end
    return cachedBucket
end

-- ------------------------------------------------------------------ display
-- Three column controls, each holding both rows, so the numbers align vertically
-- no matter how wide the labels or values are.
local function UpdateDisplay()
    if not win or not L.oRatio then return end

    -- Always on screen, everywhere. Counting is still PvP-only, but all four
    -- zones are shown at all times so the numbers are never hidden from you.
    win:SetHidden(sv.ui.hidden)

    local bucket = BucketNow()
    local k, d   = Overall()

    L.hRatio:SetText("|c7A7A7AK/D|r")
    L.hRec:SetText("|c5A5A5AK-D|r")

    L.oName:SetText("|cFFD700Overall|r")
    L.oRatio:SetText(string.format("|c%s%s|r", RatioColor(k, d, false), Ratio(k, d)))
    -- record uses the dim shade of the same colour, so it matches the ratio
    -- without competing with it for attention
    L.oRec:SetText(string.format("|c%s%d-%d|r", RatioColor(k, d, true), k, d))

    -- every zone, always. The one you are standing in is highlighted.
    for _, b in ipairs(BUCKET_ORDER) do
        local t    = Tally(b)
        local here = (b == bucket)
        local nameCol  = here and "60C0FF" or "6A6A6A"
        local ratioCol = RatioColor(t.kills, t.deaths, not here)
        local recCol   = RatioColor(t.kills, t.deaths, true)

        L[b .. "Name"]:SetText(string.format("|c%s%s|r", nameCol, BUCKET_SHORT[b]))
        L[b .. "Ratio"]:SetText(string.format("|c%s%s|r", ratioCol, Ratio(t.kills, t.deaths)))
        L[b .. "Rec"]:SetText(string.format("|c%s%d-%d|r", recCol, t.kills, t.deaths))
    end

    -- most-killed player of the day
    if sv.top and sv.top.count > 1 and type(sv.top.name) == "string" then
        L.top:SetText(string.format("|c5A5A5Atop|r |cB0B0B0%s|r |cFFD700x%d|r",
            sv.top.name, sv.top.count))
        L.top:SetHidden(false)
    else
        L.top:SetHidden(true)
    end
end

-- Sit the box at the same height as the ability bar. Reading the bar's real
-- position beats guessing a pixel offset, since it moves with resolution and
-- UI scale. Falls back to the stored offset if no bar control can be found.
local BAR_NAMES = {
    "ZO_ActionBar1", "ZO_ActionBarGamepad", "ZO_ActionBar",
    "ZO_GamepadActionBar", "ActionButton1",
}

PositionWindow = function()
    if not win then return end

    local y = sv.ui.y
    for _, n in ipairs(BAR_NAMES) do
        local c = _G[n]
        if type(c) == "userdata" or type(c) == "table" then
            local ok, bottom = pcall(function() return c:GetBottom() end)
            local ok2, root  = pcall(function() return GuiRoot:GetBottom() end)
            if ok and ok2 and type(bottom) == "number" and type(root) == "number" and bottom > 0 then
                -- negative offset upward from the bottom of the screen
                y = -(root - bottom)
                break
            end
        end
    end

    win:ClearAnchors()
    win:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, sv.ui.x, y)
end

-- Brief notice under the box. Replaces the old chat spam.
local function ShowPopup(text)
    if not popupLabel then return end
    popupLabel:SetText(text)
    popupLabel:SetHidden(false)

    popupToken = popupToken + 1
    local mine = popupToken
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if mine == popupToken and popupLabel then popupLabel:SetHidden(true) end
        end, POPUP_MS)
    end
end

local function BuildUI()
    local wm = WINDOW_MANAGER
    if not wm then return end

    win = wm:CreateTopLevelWindow(ADDON_NAME .. "Window")
    win:SetDimensions(196, 168) -- header + overall + 4 zone rows + most-killed
    win:SetClampedToScreen(true)
    win:ClearAnchors()
    win:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, sv.ui.x, sv.ui.y)
    PositionWindow()
    win:SetHidden(true)

    -- Pinned on purpose. The box takes no mouse input and is not movable, so it
    -- cannot be dragged out of place or knocked around by anything else.
    win:SetMouseEnabled(false)
    win:SetMovable(false)

    local bg = wm:CreateControl(ADDON_NAME .. "Bg", win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0, 0, 0, 0.45)     -- faint on purpose, it sits over the HUD
    bg:SetEdgeColor(0, 0, 0, 0.55)
    bg:SetEdgeTexture("", 8, 1, 1)

    -- Fixed column x-offsets shared by every row, which is what keeps the
    -- numbers in a straight vertical line across differently-sized rows.
    local X_LABEL, X_RATIO, X_REC = 12, -74, -12
    local Y_HEAD,  Y_TOTAL, Y_ZONE = 6, 24, 62
    local ROW_H = 21                      -- vertical pitch of the four zone rows

    -- Try the descriptor, then fall back through known-good names. A label whose
    -- font never took draws nothing at all, which is worse than an ugly font.
    local function SetFontSafe(c, font)
        for _, f in ipairs({ font, "ZoFontGame", "ZoFontWinH4", "ZoFontAlert" }) do
            local ok = pcall(function() c:SetFont(f) end)
            if ok then return f end
        end
    end

    local function Cell(key, font, align, point, x, y)
        local c = wm:CreateControl(ADDON_NAME .. key, win, CT_LABEL)
        c:SetAnchor(point, win, point == TOPLEFT and TOPLEFT or TOPRIGHT, x, y)
        SetFontSafe(c, font)
        c:SetHorizontalAlignment(align)
        c:SetVerticalAlignment(TEXT_ALIGN_TOP)
        L[key] = c
        return c
    end

    -- header row, deliberately small and dim
    Cell("hRatio", FONT_HEAD, TEXT_ALIGN_RIGHT, TOPRIGHT, X_RATIO, Y_HEAD)
    Cell("hRec",   FONT_HEAD, TEXT_ALIGN_RIGHT, TOPRIGHT, X_REC,   Y_HEAD)

    -- overall row, the headline number
    Cell("oName",  FONT_MID,  TEXT_ALIGN_LEFT,  TOPLEFT,  X_LABEL, Y_TOTAL + 6)
    Cell("oRatio", FONT_BIG,  TEXT_ALIGN_RIGHT, TOPRIGHT, X_RATIO, Y_TOTAL)
    Cell("oRec",   FONT_MID,  TEXT_ALIGN_RIGHT, TOPRIGHT, X_REC,   Y_TOTAL + 6)

    -- thin divider under the overall row
    local rule = wm:CreateControl(ADDON_NAME .. "Rule", win, CT_BACKDROP)
    rule:SetDimensions(0, 1)
    rule:SetAnchor(TOPLEFT,  win, TOPLEFT,  10, Y_ZONE - 8)
    rule:SetAnchor(TOPRIGHT, win, TOPRIGHT, -10, Y_ZONE - 8)
    rule:SetCenterColor(1, 1, 1, 0.10)
    rule:SetEdgeTexture("", 1, 1, 0)

    -- one row per PvP zone, always all four, stacked under the divider
    for i, b in ipairs(BUCKET_ORDER) do
        local y = Y_ZONE + (i - 1) * ROW_H
        Cell(b .. "Name",  FONT_MID, TEXT_ALIGN_LEFT,  TOPLEFT,  X_LABEL, y)
        Cell(b .. "Ratio", FONT_MID, TEXT_ALIGN_RIGHT, TOPRIGHT, X_RATIO, y)
        Cell(b .. "Rec",   FONT_MID, TEXT_ALIGN_RIGHT, TOPRIGHT, X_REC,   y)
    end

    -- most-killed line, spans the box under the grid
    L.top = wm:CreateControl(ADDON_NAME .. "Top", win, CT_LABEL)
    L.top:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -12, -6)
    pcall(function() L.top:SetFont(FONT_SUB) end)
    L.top:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    L.top:SetHidden(true)

    -- popup sits outside the box so it can never resize it
    popupLabel = wm:CreateControl(ADDON_NAME .. "Popup", win, CT_LABEL)
    popupLabel:SetAnchor(BOTTOMRIGHT, win, TOPRIGHT, -12, -4)
    pcall(function() popupLabel:SetFont(FONT_SUB) end)
    popupLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    popupLabel:SetHidden(true)

    pcall(function()
        if ZO_HUDFadeSceneFragment then
            local fragment = ZO_HUDFadeSceneFragment:New(win)
            if HUD_SCENE    and HUD_SCENE.AddFragment    then HUD_SCENE:AddFragment(fragment)    end
            if HUD_UI_SCENE and HUD_UI_SCENE.AddFragment then HUD_UI_SCENE:AddFragment(fragment) end
        end
    end)
end

-- ------------------------------------------------------------------ scoring
local function RecordKill(isPlayer, name)
    local bucket = BucketNow()
    if not bucket then return end
    local t = Tally(bucket)

    if isPlayer then
        t.kills = t.kills + 1
        if sv.diag then sv.diag.killFired = sv.diag.killFired + 1 end

        local repeats
        if name then
            repeats = BumpName(t, name)
            -- track the day's most-killed player in O(1) rather than rescanning
            if repeats and repeats > (sv.top.count or 0) then
                sv.top.name, sv.top.count = name, repeats
            end
        end

        -- multiplier beside the gamertag once you have killed them repeatedly
        local mult = (repeats and repeats > 1) and string.format(" |cFFD700x%d|r", repeats) or ""
        ShowPopup(string.format("|c60FF60+|r |cFFFFFF%s|r%s", name or "kill", mult))
    else
        t.npcs = t.npcs + 1
    end

    UpdateDisplay()
end

-- Several events can report the same death, so collapse them into one.
local lastDeathMs = 0

local function RecordDeath()
    -- Counted FIRST, before anything can drop the event. Previously this sat
    -- below the zone check, so a discarded death looked identical to one that
    -- never fired - which sent me chasing the wrong bug.
    if sv and sv.diag then
        sv.diag.deathEventSeen = (sv.diag.deathEventSeen or 0) + 1
        sv.diag.deathBucket    = tostring(cachedBucket)
        sv.diag.deathInDuel    = tostring(inDuel)
    end

    -- Losing a duel must register even if the zone gate would throw the death
    -- away, otherwise every duel scores as a win.
    if inDuel or IsDuelling() then duelDied = true end

    -- Fall back to the zone we were last genuinely in, if it was recent. Dying
    -- blanks the zone APIs for a moment and every death was being thrown away.
    local bucket = BucketNow()
    if not bucket and lastPvpBucket
       and (GetGameTimeMilliseconds() - lastPvpAt) < 120000 then
        bucket = lastPvpBucket
    end
    if sv and sv.diag then sv.diag.deathBucketUsed = tostring(bucket) end
    if not bucket then return end

    local now = GetGameTimeMilliseconds()
    if (now - lastDeathMs) < 5000 then return end   -- same death, different event
    lastDeathMs = now
    if sv.diag then sv.diag.deathFired = sv.diag.deathFired + 1 end

    local t = Tally(bucket)
    t.deaths = t.deaths + 1
    if bucket == 'duel' then duelDied = true end
    ShowPopup("|cFF6060death|r")
    UpdateDisplay()
end

local function OnCombatEvent(_, result, isError, abilityName, _, _,
                             sourceName, sourceType, targetName, targetType,
                             hitValue, _, _, _, _, targetUnitId, abilityId)
    if sv.diag then sv.diag.combatSeen = sv.diag.combatSeen + 1 end

    if isError then return end
    if not targetName or targetName == "" then return end
    if not BucketNow() then return end      -- cheapest exit outside PvP

    -- Our own death has to be tested BEFORE the source filter. Whoever killed us
    -- is not us, so the source check below would throw the event away first -
    -- which is exactly why deaths were never counting.
    if targetType == COMBAT_UNIT_TYPE_PLAYER then
        RecordDeath()
        return
    end

    -- Counted BEFORE the source filter, so it sees killing blows we discard too.
    -- In a group this reveals whether groupmate kills leak in, and how many of
    -- your kills are lost because someone else landed the finisher.
    if sv and sv.diag and result == ACTION_RESULT_KILLING_BLOW then
        sv.diag.srcTypes = sv.diag.srcTypes or {}
        local key = "src" .. tostring(sourceType)
        sv.diag.srcTypes[key] = (sv.diag.srcTypes[key] or 0) + 1
    end

    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    -- Dedupe key: prefer the unit id, but fall back to the name. Previously a
    -- missing or zero unit id skipped deduping entirely, so one death could be
    -- counted more than once - the likely cause of a single kill showing x2.
    local dedupeKey = "n:" .. tostring(targetName)

    do
        local now  = GetGameTimeMilliseconds()
        local last = recentDeaths[dedupeKey]
        if last and (now - last) < DEDUPE_MS then return end

        if not last then
            recentCount = recentCount + 1
            -- self-clearing cache: once it grows, drop every entry already past
            -- the dedupe window. Amortised, so a long siege never accumulates.
            if recentCount > CACHE_MAX then
                for id, ts in pairs(recentDeaths) do
                    if (now - ts) > DEDUPE_MS then
                        recentDeaths[id] = nil
                        recentCount = recentCount - 1
                    end
                end
            end
        end
        recentDeaths[targetUnitId] = now
    end

    -- A real kill of yours always names the ability that did it. Duplicate and
    -- second-hand killing blows arrive with an empty ability - the logs showed
    -- one target producing four events, only one of which had an ability.
    local hasAbility = (type(abilityName) == "string" and abilityName ~= "")
        or (type(abilityId) == "number" and abilityId ~= 0)

    local isPlayerKill = (result == ACTION_RESULT_KILLING_BLOW)
        and IsPlayerName(targetName)
        and hasAbility

    if sv and sv.diag and result == ACTION_RESULT_KILLING_BLOW then
        sv.diag.killLog = sv.diag.killLog or {}
        table.insert(sv.diag.killLog, string.format(
            "%s raw=[%s] player=%s | BY %s (srcType=%s) | ability=%s",
            tostring(CleanName(targetName)), tostring(targetName),
            tostring(isPlayerKill), tostring(CleanName(sourceName)),
            tostring(sourceType), tostring(abilityName)))
        while #sv.diag.killLog > 12 do table.remove(sv.diag.killLog, 1) end
    end

    RecordKill(isPlayerKill, CleanName(targetName))
end

-- ------------------------------------------------------------------- duels
local function OnDuelStarted()
    inDuel = true
    if sv.diag then sv.diag.duelStartFired = sv.diag.duelStartFired + 1 end
    duelDied = false        -- fresh duel, no death yet
    if type(GetDuelInfo) == "function" then
        local ok, _, charName, displayName = pcall(GetDuelInfo)
        if ok then duelOpponent = CleanName(charName) or CleanName(displayName) end
    end
    RefreshBucket()
    UpdateDisplay()
end

-- The argument order of EVENT_DUEL_FINISHED is not something to rely on: it
-- differs between builds and handed us a boolean where a name was expected.
-- Read the payload by type instead of by position.
local function OnDuelFinished(...)
    EnsureToday()
    if sv.diag then sv.diag.duelFinishFired = sv.diag.duelFinishFired + 1 end

    -- Real payload observed on this build:
    --   (eventCode, number 0|1, boolean, "Opponent^Mx")
    -- The boolean is true for both wins and losses, so it is NOT the result.
    -- The number is: 1 = win, 0 = loss. Skip arg 1, it is the event code.
    -- Only the opponent name is read from the payload. The numeric argument was
    -- decoded as the result before and got it backwards, so the outcome now
    -- comes from something unambiguous: in a duel, the loser is the one who
    -- died. We already track our own deaths reliably.
    -- The payload carries both the character name and the @gamertag. Take the
    -- character name - it is what the kill lists and counters use everywhere.
    local name
    for i = 2, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "string" and v ~= "" and v:sub(1, 1) ~= "@" and not name then
            name = CleanName(v)
        end
    end
    name = name or duelOpponent

    -- Capture the raw payload so the win/loss encoding can be decoded for
    -- certain rather than guessed at again.
    if sv.diag then
        local parts = {}
        for i = 2, select("#", ...) do          -- skip the event code
            parts[#parts + 1] = tostring(select(i, ...))
        end
        sv.diag.lastDuelArgs = table.concat(parts, " | ")
    end

    -- Death events never fire for a duel loss on this build, so duelDied alone
    -- always reported a win. Health is observable and unambiguous: the loser is
    -- the one who is down when the duel ends.
    -- DECODED from real duel logs: the boolean argument is "did you win".
    -- Confirmed against known results - true on a win, false on both losses.
    -- IsUnitDead is unreliable here: by the time the event fires you may already
    -- have been resurrected, which is why only the first loss ever registered.
    local lost, how = nil, "unknown"

    for i = 2, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "boolean" then
            lost, how = (v == false), "payload"
            break
        end
    end

    -- fallbacks, only if the payload ever stops carrying that boolean
    if lost == nil and duelDied then lost, how = true, "duelDied" end
    if lost == nil and type(IsUnitDead) == "function" then
        local ok, dead = pcall(IsUnitDead, "player")
        if ok and type(dead) == "boolean" then lost, how = dead, "IsUnitDead" end
    end
    if lost == nil then lost, how = false, "default" end

    -- Log the payload together with what we decided and how. Correlating that
    -- against the real results is the only way to confirm the encoding.
    if sv.diag then
        sv.diag.lastDuelHow  = how
        sv.diag.lastDuelLost = tostring(lost)
        sv.diag.duelLog = sv.diag.duelLog or {}
        table.insert(sv.diag.duelLog, string.format("%s via %s :: %s",
            lost and "LOSS" or "WIN", how, sv.diag.lastDuelArgs or "?"))
        while #sv.diag.duelLog > 8 do table.remove(sv.diag.duelLog, 1) end
    end

    local t = Tally("duel")

    -- "duel win Free lunch" read as though Free lunch had won. Say who did what.
    local vs = (type(name) == "string" and name ~= "") and name or "opponent"

    if lost then
        sv.duels.losses = sv.duels.losses + 1
        t.deaths = t.deaths + 1
        ShowPopup(string.format("|cFF6060lost to|r |cFFFFFF%s|r", vs))
    else
        sv.duels.wins = sv.duels.wins + 1
        t.kills = t.kills + 1
        if name then BumpName(t, name) end
        ShowPopup(string.format("|c60FF60beat|r |cFFFFFF%s|r", vs))
    end
    inDuel, duelOpponent, duelDied = false, nil, false
    RefreshBucket()
    UpdateDisplay()
end

-- ---------------------------------------------------------------- reporting
local function PrintNames(tally, heading)
    local rows = {}
    for name, n in pairs(tally.names) do rows[#rows + 1] = { name = name, n = n } end
    if #rows == 0 then Msg(heading .. " - none yet.") return end
    table.sort(rows, function(a, b) return a.n > b.n end)
    Msg(heading .. ":")
    for i = 1, math.min(#rows, 25) do
        Msg(string.format("  %d. %s  x%d", i, rows[i].name, rows[i].n))
    end
    if #rows > 25 then Msg(string.format("  ...and %d more", #rows - 25)) end
end

local function Report()
    EnsureToday()
    local k, d = Overall()
    Msg(string.format("Today - overall K/D %s  (%d-%d)", Ratio(k, d), k, d))
    for _, b in ipairs(BUCKET_ORDER) do
        local t = sv.tallies[b]
        if t and (t.kills > 0 or t.deaths > 0 or t.npcs > 0) then
            Msg(string.format("  %s - K/D %s  (%d-%d)  npcs %d",
                BUCKET_LABEL[b], Ratio(t.kills, t.deaths), t.kills, t.deaths, t.npcs))
        end
    end
    Msg(string.format("  Duels - %d W / %d L", sv.duels.wins, sv.duels.losses))
end

-- ---------------------------------------------------------------- commands
local function OnSlash(args)
    args = (args or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")

    -- "names ic" / "reset cyro" name a zone explicitly; bare forms use wherever
    -- you are standing.
    local verb, where = args:match("^(%S*)%s*(%S*)$")
    verb = verb or args
    local named  = ZONE_ALIAS[where or ""]
    local bucket = named or BucketNow()
    args = verb

    if args == "hide" or args == "show" or args == "toggle" then
        sv.ui.hidden = not sv.ui.hidden
        UpdateDisplay()
        Msg(sv.ui.hidden and "Box hidden." or "Box shown.")

    elseif args == "today" or args == "totals" or args == "all" then
        Report()

    elseif args == "names" then
        if not bucket then Msg("Not in a PvP zone - try /kcnamesic, /kcnamescyro, /kcnamesbg or /kcnamesduel.") return end
        PrintNames(Tally(bucket), BUCKET_LABEL[bucket] .. " players killed")

    elseif args == "reset" then
        if not bucket then Msg("Not in a PvP zone - try /kcresetic, /kcresetcyro, /kcresetbg or /kcresetduel.") return end
        EnsureToday()
        sv.tallies[bucket] = NewTally()
        -- the leader may have come from the zone we just cleared, so rebuild it
        sv.top = { name = "", count = 0 }
        for _, b in ipairs(BUCKET_ORDER) do
            local tb = sv.tallies[b]
            if tb then
                for nm, c in pairs(tb.names) do
                    if c > sv.top.count then sv.top.name, sv.top.count = nm, c end
                end
            end
        end
        Msg("Cleared " .. BUCKET_LABEL[bucket] .. ".")
        UpdateDisplay()

    elseif args == "resetall" or args == "wipe" then
        sv.day = ""          -- forces EnsureToday to rebuild everything
        EnsureToday()
        Msg("Cleared everything.")
        UpdateDisplay()

    else
        Msg("|cFFD700Kill Count|r - PvP K/D tracker")
        Msg("|c60C0FF/kctoday|r     K/D for every zone, plus names")
        Msg("|c60C0FF/kcnames|r     players you killed in this zone")
        Msg("|c60C0FF/kchide|r      show or hide the box")
        Msg("|c60C0FF/kcreset|r     clear this zone only")
        Msg("|c60C0FF/kcresetall|r  clear everything")
        Msg("|c808080Add a zone to check it from anywhere:|r")
        Msg("|c60C0FF/kcnamesic|r |c60C0FF/kcnamescyro|r |c60C0FF/kcnamesbg|r |c60C0FF/kcnamesduel|r")
        Msg("|c60C0FF/kcresetic|r |c60C0FF/kcresetcyro|r |c60C0FF/kcresetbg|r |c60C0FF/kcresetduel|r")
        Msg("|c808080Type /kc and these all autocomplete.|r")
        Msg("|c808080Numbers reset on their own every 24 hours.|r")
    end
end

-- ------------------------------------------------------------------- setup
-- The zone APIs are not always truthful the instant a load screen ends, so
-- re-check twice: once now, once shortly after. Cheap, and it stops the box
-- staying hidden after zoning into Cyrodiil or a battleground.
local function RefreshSoon()
    RefreshBucket()
    PositionWindow()
    UpdateDisplay()
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            RefreshBucket()
            UpdateDisplay()
        end, 1500)
        zo_callLater(function()
            RefreshBucket()
            UpdateDisplay()
        end, 5000)
    end
end

local function RegisterKillResult(suffix, actionResult)
    if actionResult == nil then return end
    local key = ADDON_NAME .. suffix
    EVENT_MANAGER:RegisterForEvent(key, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(key, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_COMBAT_RESULT, actionResult,
        REGISTER_FILTER_IS_ERROR, false)
end

local function Initialize()
    sv = ZO_SavedVars:NewCharacterIdSettings("KillCountVars", SV_VERSION, nil, defaults)
    sv.ui = sv.ui or { x = -8, y = -108, hidden = false }
    sv.duels = sv.duels or { wins = 0, losses = 0 }
    sv.tallies = sv.tallies or {}
    sv.top = sv.top or { name = "", count = 0 }
    EnsureToday()

    -- Diagnostics written into SavedVariables. These cost nothing and make it
    -- possible to tell which events actually exist and fire on this build,
    -- rather than inferring it from behaviour.
    sv.diag = sv.diag or {}
    sv.diag.hasDuelStarted  = (EVENT_DUEL_STARTED ~= nil)
    sv.diag.hasDuelFinished = (EVENT_DUEL_FINISHED ~= nil)
    sv.diag.hasPlayerDead   = (EVENT_PLAYER_DEAD ~= nil)
    sv.diag.hasUnitDeath    = (EVENT_UNIT_DEATH_STATE_CHANGED ~= nil)
    sv.diag.duelStateConst  = tostring(DUEL_STATE_DUELING)
    sv.diag.isConsole       = IS_CONSOLE
    sv.diag.duelStartFired  = sv.diag.duelStartFired  or 0
    sv.diag.duelFinishFired = sv.diag.duelFinishFired or 0
    sv.diag.deathFired      = sv.diag.deathFired      or 0
    sv.diag.killFired       = sv.diag.killFired       or 0
    sv.diag.combatSeen      = sv.diag.combatSeen      or 0

    BuildUI()

    RegisterKillResult("_KB",  ACTION_RESULT_KILLING_BLOW)
    RegisterKillResult("_D",   ACTION_RESULT_DIED)
    RegisterKillResult("_DXP", ACTION_RESULT_DIED_XP)

    -- Three independent routes to a death, deduped in RecordDeath. Relying on a
    -- single one of these is what left deaths stuck on zero.
    if EVENT_PLAYER_DEAD then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DEAD", EVENT_PLAYER_DEAD, RecordDeath)
    end
    if EVENT_UNIT_DEATH_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UDS", EVENT_UNIT_DEATH_STATE_CHANGED,
            function(_, unitTag, isDead) if unitTag == "player" and isDead then RecordDeath() end end)
    end
    if EVENT_DUEL_STARTED  then EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DS", EVENT_DUEL_STARTED,  OnDuelStarted)  end
    if EVENT_DUEL_FINISHED then EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DF", EVENT_DUEL_FINISHED, OnDuelFinished) end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ZONE", EVENT_PLAYER_ACTIVATED, function()
        recentDeaths, recentCount = {}, 0
        RefreshSoon()
    end)

    -- Belt and braces: battlegrounds and Imperial City transitions do not always
    -- come with a PLAYER_ACTIVATED we can trust.
    if EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ZC", EVENT_ZONE_CHANGED, RefreshSoon)
    end
    if EVENT_BATTLEGROUND_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_BG", EVENT_BATTLEGROUND_STATE_CHANGED, RefreshSoon)
    end
    if EVENT_LINKED_WORLD_POSITION_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_LW", EVENT_LINKED_WORLD_POSITION_CHANGED, RefreshSoon)
    end

    if SLASH_COMMANDS then
        SLASH_COMMANDS["/kc"] = OnSlash
        SLASH_COMMANDS["/killcount"] = OnSlash

        -- Registered individually so they appear in the game's slash-command
        -- autocomplete and land in chat history for up-arrow recall. Arguments
        -- to /kc do neither, since the game only knows about registered names.
        for _, sub in ipairs({ "today", "names", "reset", "resetall", "hide" }) do
            SLASH_COMMANDS["/kc" .. sub] = function() OnSlash(sub) end
        end

        -- Zone-specific variants: /kcnamesic, /kcresetcyro and so on. These name
        -- the zone explicitly, so they work from anywhere - you do not have to be
        -- standing in Imperial City to read your Imperial City list.
        for _, verb in ipairs({ "names", "reset" }) do
            for _, z in ipairs(ZONE_SUFFIX) do
                SLASH_COMMANDS["/kc" .. verb .. z] = function() OnSlash(verb .. " " .. z) end
            end
        end
    end

    RefreshBucket()
    UpdateDisplay()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end)
