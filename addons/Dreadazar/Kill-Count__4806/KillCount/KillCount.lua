-- Kill Count
-- Tracks kills per PvP context and logs the names of players you kill.

local ADDON_NAME = "KillCount"
local SV_VERSION = 1
local DEDUPE_MS  = 1500   -- ignore repeat death events for the same unit within this window

-- ------------------------------------------------------------------ buckets
local BUCKET_LABEL = {
    cyrodiil     = "Cyrodiil",
    imperialCity = "Imperial City",
    battleground = "Battleground",
    duel         = "Duel",
    pve          = "Overworld",
}
local BUCKET_ORDER = { "cyrodiil", "imperialCity", "battleground", "duel", "pve" }

local defaults = {
    counts = {
        cyrodiil     = { players = 0, npcs = 0 },
        imperialCity = { players = 0, npcs = 0 },
        battleground = { players = 0, npcs = 0 },
        duel         = { players = 0, npcs = 0 },
        pve          = { players = 0, npcs = 0 },
    },
    -- players[bucket][name] = times killed
    players = { cyrodiil = {}, imperialCity = {}, battleground = {}, duel = {}, pve = {} },
    duelRecord = { wins = 0, losses = 0 },
    ui = { x = 40, y = 260, hidden = false },
}

local sv                       -- saved variables
local win, label               -- ui controls
local recentDeaths = {}        -- [unitId] = gameTimeMs
local session = {}             -- [bucket] = { players = n, npcs = n }  (not saved)
local inDuel, duelOpponent = false, nil

-- ------------------------------------------------------------------ helpers
local function Msg(text)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage("|cFFD700[KC]|r " .. text)
    elseif d then
        d("[KC] " .. text)
    end
end

local function CleanName(raw)
    if not raw or raw == "" then return nil end
    local ok, formatted = pcall(zo_strformat, SI_UNIT_NAME, raw)
    if ok and formatted and formatted ~= "" then return formatted end
    return raw
end

-- Which bucket are we currently earning kills in?
local function CurrentBucket()
    if inDuel then return "duel" end
    if IsActiveWorldBattleground and IsActiveWorldBattleground() then return "battleground" end
    if IsInImperialCity and IsInImperialCity() then return "imperialCity" end
    if IsInAvAZone and IsInAvAZone() then return "cyrodiil" end
    return "pve"
end

local function SessionFor(bucket)
    session[bucket] = session[bucket] or { players = 0, npcs = 0 }
    return session[bucket]
end

-- ------------------------------------------------------------------ display
local function UpdateDisplay()
    if not label then return end
    local bucket = CurrentBucket()
    local total  = sv.counts[bucket]
    local sess   = SessionFor(bucket)

    local text = string.format(
        "|cFFD700%s|r\n|cFF6060Players|r %d  |c60C0FFNPCs|r %d\n|c808080session  %d / %d|r",
        BUCKET_LABEL[bucket], total.players, total.npcs, sess.players, sess.npcs)

    if bucket == "duel" and duelOpponent then
        text = text .. "\n|c808080vs " .. duelOpponent .. "|r"
    end

    label:SetText(text)
    win:SetHeight(label:GetTextHeight() + 14)
end

local function BuildUI()
    local wm = WINDOW_MANAGER

    win = wm:CreateTopLevelWindow(ADDON_NAME .. "Window")
    win:SetDimensions(210, 74)
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:ClearAnchors()
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.ui.x, sv.ui.y)
    win:SetHidden(sv.ui.hidden)

    local bg = wm:CreateControl(ADDON_NAME .. "Bg", win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0, 0, 0, 0.45)
    bg:SetEdgeColor(0, 0, 0, 0.7)
    bg:SetEdgeTexture("", 8, 1, 1)

    label = wm:CreateControl(ADDON_NAME .. "Label", win, CT_LABEL)
    label:SetAnchor(TOPLEFT, win, TOPLEFT, 10, 7)
    label:SetFont("ZoFontGameBold")
    label:SetColor(1, 1, 1, 1)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)

    win:SetHandler("OnMoveStop", function()
        sv.ui.x, sv.ui.y = win:GetLeft(), win:GetTop()
    end)

    -- hide the counter whenever the HUD itself is hidden (menus, loading, etc.)
    local fragment = ZO_HUDFadeSceneFragment:New(win)
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
end

-- ------------------------------------------------------------------ scoring
local function RecordKill(isPlayer, name)
    local bucket = CurrentBucket()
    local total  = sv.counts[bucket]
    local sess   = SessionFor(bucket)

    if isPlayer then
        total.players = total.players + 1
        sess.players  = sess.players + 1
        if name then
            local list = sv.players[bucket]
            list[name] = (list[name] or 0) + 1
        end
    else
        total.npcs = total.npcs + 1
        sess.npcs  = sess.npcs + 1
    end

    UpdateDisplay()
end

local function OnCombatEvent(_, result, isError, _, _, _,
                             _, sourceType, targetName, targetType,
                             _, _, _, _, _, targetUnitId)
    if isError then return end
    if not targetName or targetName == "" then return end

    -- only kills we (or our pet) landed
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end
    -- COMBAT_UNIT_TYPE_PLAYER as the *target* means we died, not them
    if targetType == COMBAT_UNIT_TYPE_PLAYER then return end

    -- the same death can surface as several results; count it once
    if targetUnitId and targetUnitId ~= 0 then
        local now  = GetGameTimeMilliseconds()
        local last = recentDeaths[targetUnitId]
        if last and (now - last) < DEDUPE_MS then return end
        recentDeaths[targetUnitId] = now
    end

    local isPlayerKill = (result == ACTION_RESULT_KILLING_BLOW)
    RecordKill(isPlayerKill, isPlayerKill and CleanName(targetName) or nil)
end

-- ------------------------------------------------------------------- duels
local function OnDuelStarted()
    inDuel = true
    if GetDuelInfo then
        local ok, _, charName, displayName = pcall(GetDuelInfo)
        if ok then duelOpponent = CleanName(charName) or CleanName(displayName) end
    end
    UpdateDisplay()
end

local function OnDuelFinished(_, won, opponentCharName, opponentDisplayName)
    local name = CleanName(opponentCharName) or CleanName(opponentDisplayName) or duelOpponent
    if won == true then
        sv.duelRecord.wins = sv.duelRecord.wins + 1
        if name then Msg("Duel win vs " .. name) end
    elseif won == false then
        sv.duelRecord.losses = sv.duelRecord.losses + 1
        if name then Msg("Duel loss vs " .. name) end
    end
    inDuel, duelOpponent = false, nil
    UpdateDisplay()
end

-- ---------------------------------------------------------------- commands
local function PrintNames(bucket)
    local list, rows = sv.players[bucket], {}
    for name, n in pairs(list) do rows[#rows + 1] = { name = name, n = n } end
    if #rows == 0 then
        Msg("No player kills recorded in " .. BUCKET_LABEL[bucket] .. ".")
        return
    end
    table.sort(rows, function(a, b) return a.n > b.n end)
    Msg(BUCKET_LABEL[bucket] .. " player kills:")
    for i = 1, math.min(#rows, 25) do
        Msg(string.format("  %d. %s  x%d", i, rows[i].name, rows[i].n))
    end
    if #rows > 25 then Msg(string.format("  ...and %d more", #rows - 25)) end
end

local function PrintTotals()
    Msg("Totals:")
    for _, b in ipairs(BUCKET_ORDER) do
        local c = sv.counts[b]
        if c.players > 0 or c.npcs > 0 then
            Msg(string.format("  %s - players %d, npcs %d", BUCKET_LABEL[b], c.players, c.npcs))
        end
    end
    Msg(string.format("  Duel record - %d W / %d L", sv.duelRecord.wins, sv.duelRecord.losses))
end

local function OnSlash(args)
    args = (args or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    local bucket = CurrentBucket()

    if args == "" then
        sv.ui.hidden = not sv.ui.hidden
        win:SetHidden(sv.ui.hidden)
        Msg(sv.ui.hidden and "Counter hidden." or "Counter shown.")
    elseif args == "totals" or args == "all" then
        PrintTotals()
    elseif args == "names" then
        PrintNames(bucket)
    elseif args == "reset" then
        sv.counts[bucket] = { players = 0, npcs = 0 }
        sv.players[bucket] = {}
        session[bucket] = nil
        Msg("Reset " .. BUCKET_LABEL[bucket] .. ".")
        UpdateDisplay()
    elseif args == "resetall" then
        for _, b in ipairs(BUCKET_ORDER) do
            sv.counts[b] = { players = 0, npcs = 0 }
            sv.players[b] = {}
        end
        sv.duelRecord = { wins = 0, losses = 0 }
        session = {}
        Msg("Reset everything.")
        UpdateDisplay()
    else
        Msg("/kc          show or hide the counter")
        Msg("/kc totals   print every bucket totals")
        Msg("/kc names    list players killed in this zone")
        Msg("/kc reset    reset this zone only")
        Msg("/kc resetall reset everything")
    end
end

-- ------------------------------------------------------------------- setup
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

    BuildUI()

    RegisterKillResult("_KB",  ACTION_RESULT_KILLING_BLOW)
    RegisterKillResult("_D",   ACTION_RESULT_DIED)
    RegisterKillResult("_DXP", ACTION_RESULT_DIED_XP)

    if EVENT_DUEL_STARTED  then EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DS", EVENT_DUEL_STARTED,  OnDuelStarted)  end
    if EVENT_DUEL_FINISHED then EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DF", EVENT_DUEL_FINISHED, OnDuelFinished) end

    -- zone changes flip which bucket we are displaying
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ZONE", EVENT_PLAYER_ACTIVATED, function()
        recentDeaths = {}
        UpdateDisplay()
    end)

    SLASH_COMMANDS["/kc"] = OnSlash
    SLASH_COMMANDS["/killcount"] = OnSlash

    UpdateDisplay()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end)
