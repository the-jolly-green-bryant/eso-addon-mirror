-- CommandCodex.lua : every slash command in one list, favorites (in sets),
-- recent commands, notes and aliases. Open with /codex (or /cmds, or a keybind).
-- All text comes from CommandCodex_Strings.lua via S.L().

local ADDON_NAME = "CommandCodex"
CommandCodex = CommandCodex or {}
local S = CommandCodex
local L = S.L

local DEFAULT_SET = "Default"
local MAX_RECENT = 30

local defaults = {
    language = "auto",    -- "auto" (game language), "en", "de", "fr" or "es"
    aliases = {},         -- ["/rl"] = "/reloadui"
    notes = {},           -- ["/cmd"] = "what it does"
    recent = {},          -- { { name = "/cmd", t = timestamp }, ... } newest first
    -- Favorite sets: each has its own favorites, slot order (quick buttons,
    -- keys 1-5) and button positions.
    sets = {},            -- [setName] = { favorites = {}, order = {}, pos = {} }
    characterSet = {},    -- [characterId] = setName
    zoneSet = {},         -- { pvp = setName, house = setName } automatic switching
    view = "all",         -- "all", "favorites", "recent", "addons", "aliases", "game" or "emotes"
    addon = nil,          -- addon folder when one addon is picked under Addons
    addonsOpen = true,    -- Addons category expanded in the tree
    x = nil, y = nil,     -- window position once dragged away from the button
    docked = true,        -- window sits under the button
    launcherX = 16, launcherY = 52,   -- just under the CPBIS button
    launcherHidden = false,
    hideLibraries = true, -- hide commands that come from libraries
    quickBarShown = true,
    quickLocked = false,  -- quick buttons can't be dragged while locked
}

local MAX_ALIAS_DEPTH = 5   -- stops aliases that call each other in a loop

-- Keybinding names (in the game's language for now; updated once the setting is read).
ZO_CreateStringId("SI_BINDING_NAME_COMMANDCODEX_TOGGLE", L("BIND_TOGGLE"))
ZO_CreateStringId("SI_BINDING_NAME_COMMANDCODEX_TOGGLE_FAVS", L("BIND_TOGGLE_FAVS"))
for slot = 1, 5 do
    ZO_CreateStringId("SI_BINDING_NAME_COMMANDCODEX_FAV" .. slot, L("BIND_FAV", slot))
end

local function ApplyLanguageToBindings()
    SafeAddString(SI_BINDING_NAME_COMMANDCODEX_TOGGLE, L("BIND_TOGGLE"), 1)
    SafeAddString(SI_BINDING_NAME_COMMANDCODEX_TOGGLE_FAVS, L("BIND_TOGGLE_FAVS"), 1)
    for slot = 1, 5 do
        SafeAddString(_G["SI_BINDING_NAME_COMMANDCODEX_FAV" .. slot], L("BIND_FAV", slot), 1)
    end
end

function S.Print(text)
    d("|c7FB2E5" .. L("PREFIX") .. "|r " .. text)
end

-- ---------------------------------------------------------------------------
-- Which addon added a command
--
-- The game does not record this, so three methods are tried, best first:
--   "file": the Lua file the command's function lives in (debug.getinfo)
--   "load": the file that registered the command, seen while addons load
--           (debug.traceback); only catches addons that load after this one
--   "name": the command looks like an installed addon's name (/aui -> AUI)
-- ---------------------------------------------------------------------------
S.tracedSource = {}   -- ["/cmd"] = addon folder, or false for game code

local function FolderFromPath(path)
    return path and path:match("[Aa]dd[Oo]ns/([^/]+)/")
end

-- Watch new commands from now on and remember which file registered them.
do
    local mt = getmetatable(SLASH_COMMANDS)
    if mt == nil then
        mt = {}
        setmetatable(SLASH_COMMANDS, mt)
    end
    if mt.__newindex == nil and debug and debug.traceback then
        mt.__newindex = function(t, key, value)
            rawset(t, key, value)
            if type(key) ~= "string" or S.tracedSource[key] ~= nil then return end
            local ok, trace = pcall(debug.traceback)
            if not ok or type(trace) ~= "string" then return end
            -- The deepest addon in the call stack is the one that started it;
            -- libraries (e.g. LibAddonMenu) often register commands for the addon
            -- that called them, so skip "Lib..." folders when a real addon is there.
            local owner, library = false, nil
            for folder in trace:gmatch("[Aa]dd[Oo]ns/([^/]+)/") do
                if folder ~= ADDON_NAME then
                    if folder:find("^[Ll]ib") then
                        library = folder
                    else
                        owner = folder
                    end
                end
            end
            S.tracedSource[key] = owner or library or false
        end
    end
end

local function SourceFromFunction(fn)
    if not (debug and debug.getinfo) or type(fn) ~= "function" then return nil end
    local ok, info = pcall(debug.getinfo, fn, "S")
    if not ok or type(info) ~= "table" or type(info.source) ~= "string" then return nil end
    local folder = FolderFromPath(info.source)
    if folder then return folder end
    if zo_strlower(info.source):find("esoui/", 1, true) then return false end
    return nil
end

local function StripColors(text)
    return (text or ""):gsub("|[cC]%x%x%x%x%x%x", ""):gsub("|[rR]", "")
end

local function Squash(text)
    return (zo_strlower(text or ""):gsub("[^%w]", ""))
end

-- folder -> readable title, for every installed addon.
function S.GetAddonTitles()
    if S.addonTitles then return S.addonTitles end
    local titles, libraries = {}, {}
    local manager = GetAddOnManager()
    for i = 1, manager:GetNumAddOns() do
        local folder, title, _, _, _, _, _, isLibrary = manager:GetAddOnInfo(i)
        if folder then
            libraries[folder] = isLibrary == true
            -- "Advanced UI | Version: 3.992" -> "Advanced UI"
            title = StripColors(title):gsub("|[tT].-|[tT]", ""):gsub("%s*|.*$", ""):gsub("%s+[Vv]ersion.*$", "")
            title = zo_strtrim(title)
            titles[folder] = title ~= "" and title or folder
        end
    end
    S.addonTitles = titles
    S.addonIsLibrary = libraries
    return titles
end

-- Library addons: marked as library in their manifest, or named "Lib...".
function S.IsLibrary(folder)
    S.GetAddonTitles()
    return S.addonIsLibrary[folder] == true or folder:find("^[Ll]ib") ~= nil
end

local function GuessOwnerByName(command)
    local word = Squash(command)
    if #word < 2 then return nil end
    local prefixMatch
    for folder, title in pairs(S.GetAddonTitles()) do
        local f, t = Squash(folder), Squash(title)
        if word == f or word == t then return folder end
        -- /aui -> AdvancedUI's short name, or /auibuffs -> starts with "aui"
        local startsEither = (#word >= 3 and (f:sub(1, #word) == word or t:sub(1, #word) == word))
            or (#f >= 3 and word:sub(1, #f) == f)
        if startsEither then
            prefixMatch = prefixMatch or folder
        end
    end
    return prefixMatch
end

-- The game's own commands: every game text that is a single "/word" (the
-- game's slash commands and chat channel switches live in its text table),
-- so this works in every client language. Going through _G instead is not
-- allowed: it touches private game functions and raises an error.
function S.GetGameCommands()
    if S.gameCommands then return S.gameCommands end
    local set = {}
    local ok = pcall(function()
        if type(EsoStrings) ~= "table" then return end
        for _, text in pairs(EsoStrings) do
            if type(text) == "string" and text:sub(1, 1) == "/" then
                text = zo_strlower(zo_strtrim(text))
                if not text:find("%s") then set[text] = true end
            end
        end
    end)
    if not ok then set = {} end
    S.gameCommands = set
    return set
end

-- owner folder (or nil) and how it was found: "self", "file", "load", "name",
-- "game", "alias" or "unknown".
function S.GetCommandOwner(name)
    if S.registeredAliases[name] then return nil, "alias" end
    if name == "/codex" or (name == "/cmds" and S.ownsCmds) then return ADDON_NAME, "self" end

    local fromFile = SourceFromFunction(SLASH_COMMANDS[name])
    if fromFile == false then return nil, "game" end
    if fromFile then return fromFile, "file" end

    local traced = S.tracedSource[name]
    if traced and traced:find("^[Ll]ib") then
        -- Only a library was seen registering it; the command's name may still
        -- point to the real addon (/auibuffs -> AUI).
        local guess = GuessOwnerByName(name)
        if guess and not guess:find("^[Ll]ib") then return guess, "name" end
    end
    if traced then return traced, "load" end
    if traced == false then return nil, "game" end
    if S.GetGameCommands()[zo_strlower(name)] then return nil, "game" end

    local guess = GuessOwnerByName(name)
    if guess then return guess, "name" end
    return nil, "unknown"
end

-- "rl", "/RL " -> "/rl". nil when empty or more than one word.
function S.NormalizeCommand(name)
    name = zo_strlower(zo_strtrim(name or ""))
    if name == "" or name:find("%s") then return nil end
    if name:sub(1, 1) ~= "/" then name = "/" .. name end
    return name
end

-- ---------------------------------------------------------------------------
-- Recently used: commands run from the window, favorites, keys or aliases.
-- ---------------------------------------------------------------------------
function S.RecordRecent(name)
    local recent = S.sv.recent
    for i = #recent, 1, -1 do
        if recent[i].name == name then table.remove(recent, i) end
    end
    table.insert(recent, 1, { name = name, t = GetTimeStamp() })
    while #recent > MAX_RECENT do table.remove(recent) end
end

-- name -> { time, rank } for every recent command (rank 1 = most recent).
function S.GetRecentMap()
    local map = {}
    for i, entry in ipairs(S.sv.recent) do
        map[entry.name] = { time = entry.t, rank = i }
    end
    return map
end

-- "5 min ago", "2 h ago", ...
function S.FormatAgo(timestamp)
    local seconds = GetDiffBetweenTimeStamps(GetTimeStamp(), timestamp)
    if seconds < 60 then return L("AGO_NOW") end
    if seconds < 3600 then return L("AGO_MIN", zo_floor(seconds / 60)) end
    if seconds < 86400 then return L("AGO_HOUR", zo_floor(seconds / 3600)) end
    return L("AGO_DAY", zo_floor(seconds / 86400))
end

-- ---------------------------------------------------------------------------
-- Notes: the player's own description of a command.
-- ---------------------------------------------------------------------------
function S.GetNote(name)
    return S.sv.notes[name]
end

function S.SetNote(name, text)
    text = zo_strtrim(text or "")
    S.sv.notes[name] = text ~= "" and text or nil
end

-- ---------------------------------------------------------------------------
-- Running commands
-- ---------------------------------------------------------------------------
local depth = 0

-- Runs "/cmd args". Several commands can be chained with ";".
-- extraArgs (what was typed after an alias) is added to the last command.
function S.RunCommandText(text, extraArgs)
    local parts = {}
    for part in string.gmatch(text or "", "[^;]+") do
        part = zo_strtrim(part)
        if part ~= "" then parts[#parts + 1] = part end
    end
    if #parts == 0 then return false end

    if depth >= MAX_ALIAS_DEPTH then
        S.Print(L("ALIAS_LOOP"))
        return false
    end
    depth = depth + 1

    local success = true
    for i, part in ipairs(parts) do
        local cmd, args = part:match("^(%S+)%s*(.*)$")
        cmd = S.NormalizeCommand(cmd)
        local fn = cmd and SLASH_COMMANDS[cmd]
        if type(fn) ~= "function" then
            S.Print(L("UNKNOWN_COMMAND", tostring(cmd)))
            success = false
            break
        end
        if i == #parts and extraArgs and extraArgs ~= "" then
            args = args ~= "" and (args .. " " .. extraArgs) or extraArgs
        end
        local ok, err = pcall(fn, args)
        if not ok then
            S.Print(L("ERROR_IN", cmd, tostring(err)))
            success = false
            break
        end
    end

    depth = depth - 1
    return success
end

-- Run a command the player picked (window, favorite, key) and remember it as recent.
function S.RunAndRecord(name)
    S.RecordRecent(name)
    return S.RunCommandText(name)
end

-- ---------------------------------------------------------------------------
-- Aliases
-- ---------------------------------------------------------------------------
S.registeredAliases = {}   -- aliases this addon put into SLASH_COMMANDS

local function RegisterAlias(alias)
    SLASH_COMMANDS[alias] = function(args)
        S.RecordRecent(alias)
        S.RunCommandText(S.sv.aliases[alias], args)
    end
    S.registeredAliases[alias] = true
end

-- Returns true, or false plus a reason.
function S.AddAlias(alias, target)
    alias = S.NormalizeCommand(alias)
    if not alias then return false, L("ALIAS_ONE_WORD") end
    target = zo_strtrim(target or "")
    if target == "" then return false, L("ALIAS_NEED_TARGET") end
    if target:sub(1, 1) ~= "/" then target = "/" .. target end

    if SLASH_COMMANDS[alias] and not S.registeredAliases[alias] then
        return false, L("ALIAS_EXISTS", alias)
    end
    for part in string.gmatch(target, "[^;]+") do
        if S.NormalizeCommand(part:match("^%s*(%S+)")) == alias then
            return false, L("ALIAS_SELF")
        end
    end

    S.sv.aliases[alias] = target
    RegisterAlias(alias)
    return true
end

function S.RemoveAlias(alias)
    if not S.sv.aliases[alias] then return false end
    S.sv.aliases[alias] = nil
    if S.registeredAliases[alias] then
        SLASH_COMMANDS[alias] = nil
        S.registeredAliases[alias] = nil
    end
    return true
end

-- After all addons loaded, so an alias never replaces another addon's command.
local function RegisterSavedAliases()
    for alias in pairs(S.sv.aliases) do
        if SLASH_COMMANDS[alias] and not S.registeredAliases[alias] then
            S.Print(L("ALIAS_INACTIVE", alias))
        else
            RegisterAlias(alias)
        end
    end
end

-- ---------------------------------------------------------------------------
-- Favorite sets
-- ---------------------------------------------------------------------------
local function NewSet()
    return { favorites = {}, order = {}, pos = {} }
end

-- Readable name of a set ("Default" is shown in the chosen language).
function S.SetDisplayName(name)
    return name == DEFAULT_SET and L("SET_DEFAULT") or name
end

-- All set names: Default first, then A-Z.
function S.GetSetNames()
    local names = {}
    for name in pairs(S.sv.sets) do
        if name ~= DEFAULT_SET then names[#names + 1] = name end
    end
    table.sort(names, function(a, b) return zo_strlower(a) < zo_strlower(b) end)
    table.insert(names, 1, DEFAULT_SET)
    return names
end

local function InPvP()
    return (IsPlayerInAvAWorld and IsPlayerInAvAWorld()) or (IsActiveWorldBattleground and IsActiveWorldBattleground())
end

local function InHouse()
    return GetCurrentZoneHouseId and GetCurrentZoneHouseId() ~= 0
end

-- Which set applies right now: PvP / house rule, then this character's set, then Default.
local function ResolveActiveSet()
    local sv = S.sv
    local name
    if sv.zoneSet.pvp and InPvP() then
        name = sv.zoneSet.pvp
    elseif sv.zoneSet.house and InHouse() then
        name = sv.zoneSet.house
    else
        name = sv.characterSet[GetCurrentCharacterId()]
    end
    if not name or not sv.sets[name] then name = DEFAULT_SET end
    return name
end

-- The active set's data: favorites, order, pos.
function S.Set()
    return S.sv.sets[S.activeSet or DEFAULT_SET]
end

function S.GetActiveSetName()
    return S.activeSet or DEFAULT_SET
end

-- Recheck which set applies (after a zone change or a settings change).
function S.UpdateActiveSet(announce)
    local name = ResolveActiveSet()
    if name == S.activeSet then return end
    S.activeSet = name
    if announce and #S.GetSetNames() > 1 then
        S.Print(L("SET_SWITCHED", S.SetDisplayName(name)))
    end
    if S.RefreshQuickBar then S.RefreshQuickBar() end
    if S.RefreshAll then S.RefreshAll() end
end

-- Use this set on this character from now on.
function S.UseSetForCharacter(name)
    S.sv.characterSet[GetCurrentCharacterId()] = name ~= DEFAULT_SET and name or nil
    S.UpdateActiveSet(true)
end

-- Returns true, or false plus a reason.
function S.CreateSet(name)
    name = zo_strtrim(name or "")
    if name == "" then return false, L("SET_NAME_EMPTY") end
    for existing in pairs(S.sv.sets) do
        if zo_strlower(existing) == zo_strlower(name) or zo_strlower(S.SetDisplayName(existing)) == zo_strlower(name) then
            return false, L("SET_EXISTS", name)
        end
    end
    S.sv.sets[name] = NewSet()
    return true
end

function S.DeleteSet(name)
    if name == DEFAULT_SET or not S.sv.sets[name] then return false end
    S.sv.sets[name] = nil
    for id, setName in pairs(S.sv.characterSet) do
        if setName == name then S.sv.characterSet[id] = nil end
    end
    for rule, setName in pairs(S.sv.zoneSet) do
        if setName == name then S.sv.zoneSet[rule] = nil end
    end
    S.UpdateActiveSet(true)
    return true
end

-- Old saves kept one list of favorites; it becomes the Default set.
local function MigrateFavorites(sv)
    if not sv.sets[DEFAULT_SET] then
        local set = NewSet()
        set.favorites = sv.favorites or set.favorites
        set.order = sv.favoriteOrder or set.order
        set.pos = sv.quickPos or set.pos
        sv.sets[DEFAULT_SET] = set
    end
    sv.favorites, sv.favoriteOrder, sv.quickPos = nil, nil, nil
end

-- ---------------------------------------------------------------------------
-- Command list
-- ---------------------------------------------------------------------------
function S.GetEmoteCommands()
    if S.emoteCommands then return S.emoteCommands end
    local set = {}
    if GetNumEmotes and GetEmoteSlashNameByIndex then
        for i = 1, GetNumEmotes() do
            local slash = GetEmoteSlashNameByIndex(i)
            if slash and slash ~= "" then set[zo_strlower(slash)] = true end
        end
    end
    S.emoteCommands = set
    return set
end

function S.GetCommands()
    local emotes = S.GetEmoteCommands()
    local titles = S.GetAddonTitles()
    local favorites = S.Set().favorites
    local recent = S.GetRecentMap()
    local list = {}
    for name, fn in pairs(SLASH_COMMANDS) do
        if type(name) == "string" and type(fn) == "function" then
            local owner, method = S.GetCommandOwner(name)
            local lastRun = recent[name]
            list[#list + 1] = {
                name = name,
                isEmote = emotes[zo_strlower(name)] == true,
                alias = S.sv.aliases[name],
                note = S.sv.notes[name],
                favorite = favorites[name] == true,
                recentTime = lastRun and lastRun.time,
                recentRank = lastRun and lastRun.rank,
                owner = owner,
                ownerTitle = owner and (titles[owner] or owner) or nil,
                ownerMethod = method,
                isLibrary = owner ~= nil and S.IsLibrary(owner),
            }
        end
    end
    return list
end

-- ---------------------------------------------------------------------------
-- Favorites keep a fixed order within their set: slot 1 is the first one you
-- starred, and so on. The on-screen buttons and "Run favorite 1-5" use these slots.
-- ---------------------------------------------------------------------------
function S.GetFavoriteOrder()
    local set = S.Set()
    local order, seen = {}, {}
    for _, name in ipairs(set.order) do
        if set.favorites[name] and not seen[name] then
            order[#order + 1] = name
            seen[name] = true
        end
    end
    -- Favorites without a slot yet go at the end, A-Z.
    local missing = {}
    for name in pairs(set.favorites) do
        if not seen[name] then missing[#missing + 1] = name end
    end
    table.sort(missing)
    for _, name in ipairs(missing) do order[#order + 1] = name end
    set.order = order
    return order
end

function S.ToggleFavorite(name)
    local favorites = S.Set().favorites
    favorites[name] = not favorites[name] or nil
    S.GetFavoriteOrder()
    if S.RefreshQuickBar then S.RefreshQuickBar() end
end

-- Called by the "Run favorite 1-5" keybinds (Bindings.xml).
function S.RunFavorite(slot)
    local name = S.GetFavoriteOrder()[slot]
    if not name then
        S.Print(L("FAV_SLOT_EMPTY", slot))
        return
    end
    S.RunAndRecord(name)
end

-- ---------------------------------------------------------------------------
-- Slash commands + init
-- ---------------------------------------------------------------------------
local function OnSlash(args)
    args = zo_strtrim(args or "")
    local sub, rest = args:match("^(%S*)%s*(.*)$")
    sub = zo_strlower(sub or "")

    if sub == "" then
        S.ToggleWindow()
    elseif sub == "help" then
        for _, line in ipairs(L("HELP")) do S.Print(line) end
    elseif sub == "bar" then
        S.SetQuickBarShown(not S.sv.quickBarShown)
        S.Print(S.sv.quickBarShown and L("FAVS_SHOWN") or L("FAVS_HIDDEN"))
    elseif sub == "reset" then
        S.ResetFavoritePositions()
        S.Print(L("FAVS_RESET"))
    elseif sub == "lock" then
        S.SetQuickLocked(not S.sv.quickLocked)
        S.Print(S.sv.quickLocked and L("FAVS_LOCKED") or L("FAVS_UNLOCKED"))
    elseif sub == "alias" then
        local alias, target = rest:match("^(%S+)%s+(.+)$")
        local ok, reason = S.AddAlias(alias, target)
        if ok then
            local name = S.NormalizeCommand(alias)
            S.Print(L("ALIAS_RUNS_CHAT", name, S.sv.aliases[name]))
            if S.RefreshList then S.RefreshList() end
        else
            S.Print(reason or L("ALIAS_USAGE"))
        end
    elseif sub == "unalias" then
        local alias = S.NormalizeCommand(rest)
        if alias and S.RemoveAlias(alias) then
            S.Print(L("ALIAS_DELETED", alias))
            if S.RefreshList then S.RefreshList() end
        else
            S.Print(L("ALIAS_NOT_FOUND", tostring(rest)))
        end
    elseif sub == "sources" then
        -- Debug: how each command's addon was found.
        local counts = {}
        for _, data in ipairs(S.GetCommands()) do
            if not data.isEmote then counts[data.ownerMethod] = (counts[data.ownerMethod] or 0) + 1 end
        end
        S.Print(string.format("debug.getinfo: %s   debug.traceback: %s",
            tostring(debug ~= nil and debug.getinfo ~= nil), tostring(debug ~= nil and debug.traceback ~= nil)))
        for method, count in pairs(counts) do
            S.Print(string.format("%s: %d", method, count))
        end
    elseif sub == "unknown" then
        -- Debug: commands no method could place.
        local names = {}
        for _, data in ipairs(S.GetCommands()) do
            if data.ownerMethod == "unknown" and not data.isEmote then names[#names + 1] = data.name end
        end
        table.sort(names)
        S.Print(#names == 0 and "-" or table.concat(names, "  "))
    elseif sub == "aliases" then
        if next(S.sv.aliases) == nil then
            S.Print(L("NO_ALIASES"))
        end
        for alias, target in pairs(S.sv.aliases) do
            S.Print(string.format("%s -> %s", alias, target))
        end
    else
        -- Anything else is a search: /codex aui opens the window searching for "aui".
        S.OpenWithSearch(args)
    end
end

local function OnPlayerActivated()
    if not S.activated then
        S.activated = true
        RegisterSavedAliases()
        -- /cmds as a second way to open the window, unless another addon has it.
        if not SLASH_COMMANDS["/cmds"] then
            SLASH_COMMANDS["/cmds"] = function() S.ToggleWindow() end
            S.ownsCmds = true
        end
    end
    -- Every zone change: PvP / house rules may pick another favorite set.
    S.UpdateActiveSet(true)
end

local function OnAddOnLoaded(_, name)
    if name ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    S.sv = ZO_SavedVars:NewAccountWide("CommandCodex_SV", 1, nil, defaults)
    S.SetLanguage(S.sv.language)
    ApplyLanguageToBindings()
    MigrateFavorites(S.sv)
    S.activeSet = ResolveActiveSet()

    SLASH_COMMANDS["/codex"] = OnSlash
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    S.InitUI()
    if S.InitSettings then S.InitSettings() end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
