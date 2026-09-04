-- Flamechasers Dungeon Codex
-- Main namespace + lifecycle + chat helpers.

DungeonMechsCodex = DungeonMechsCodex or {}
local DMC = DungeonMechsCodex

DMC.name = "DungeonMechsCodex"
DMC.displayName = "Flamechasers Dungeon, Trial & Arena Codex"
DMC.version = "0.7.2"
DMC.chatPrefix = "|c66ccffFDC|r "

-- Bindings.xml is loaded after this file. Register these labels now so the
-- shared category already exists when ESO parses the binding definitions.
if _G["SI_BINDING_NAME_FLAMECHASERS_CATEGORY"] == nil then
    ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_CATEGORY", "Flamechasers")
end
ZO_CreateStringId("SI_BINDING_NAME_DMC_TOGGLE_WINDOW", "Open/Close Flamechasers Dungeon Codex")
ZO_CreateStringId("SI_BINDING_NAME_DMC_PASTE_SELECTED", "Paste Selected Mechanic")

DMC.defaultSavedVars = {
    window = { x = 0, y = 0 },
    mode = "hm", -- supported datasets: veteran without Hard Mode (vet), and Hard Mode (hm)
    bossNotes = {}, -- account-wide personal notes, keyed by difficulty + stable activity/boss IDs
}

-- Session-only UI memory. This table lives only until the UI reloads/game closes;
-- it is intentionally not backed by SavedVars so selected dungeon/boss/mode do not
-- persist into the next play session.
DMC.sessionState = DMC.sessionState or {
    selectedDungeonId = nil,
    selectedBossId = nil,
    activityType = "dungeon",
    roleFilter = "all", -- internal "all" displays as Full; other modes: quick, tank, healer, dps
}

function DMC.NormalizeDifficultyMode(mode)
    return mode == "vet" and "vet" or "hm"
end

function DMC.GetDifficultyMode(mode)
    if mode ~= nil then return DMC.NormalizeDifficultyMode(mode) end
    if DMC.ui and DMC.ui.mode then return DMC.NormalizeDifficultyMode(DMC.ui.mode) end
    if DMC.sv and DMC.sv.mode then return DMC.NormalizeDifficultyMode(DMC.sv.mode) end
    return "hm"
end

function DMC.IsVisibleForMode(value, mode)
    mode = DMC.GetDifficultyMode(mode)
    return not (mode == "vet" and value and value.vet == false)
end

function DMC.GetModeValue(value, field, mode)
    if not value then return nil end
    mode = DMC.GetDifficultyMode(mode)
    if mode == "vet" then
        if value.vet == false then return nil end
        if type(value.vet) == "table" and value.vet[field] ~= nil then
            if value.vet[field] == false then return nil end
            return value.vet[field]
        end
    end
    return value[field]
end

function DMC.GetModeText(value, fields, mode)
    if not DMC.IsVisibleForMode(value, mode) then return "" end
    for _, field in ipairs(fields or {}) do
        local text = DMC.GetModeValue(value, field, mode)
        if text ~= nil and text ~= "" then return text end
    end
    return ""
end

local function normalizeText(value)
    if value == nil then return "" end
    value = tostring(value):lower()
    value = value:gsub("’", "'")
    value = value:gsub("[^%w%s']", " ")
    value = value:gsub("%s+", " ")
    return zo_strtrim(value)
end
DMC.NormalizeText = normalizeText

function DMC.Print(message)
    d(DMC.chatPrefix .. tostring(message))
end

-- Chat length policy. Player-sent chat does not reliably preserve ESO pipe color tags,
-- so paste-ready lines are plain text with compact [TAG] markers.
-- Do not force /group: StartChatInput() only prefills text so the player can pick/send any channel.
DMC.chatInputCommand = ""
DMC.maxChatInputChars = 320
DMC.maxChatPayloadChars = DMC.maxChatInputChars
DMC.defaultPlainChatBudget = 220

function DMC.GetChatPayloadBudget()
    return (DMC.maxChatPayloadChars or 313)
end

local function trimPlainText(text, maxLen)
    text = zo_strtrim(tostring(text or ""))
    maxLen = tonumber(maxLen) or DMC.defaultPlainChatBudget
    if maxLen < 12 then maxLen = 12 end
    if #text <= maxLen then return text end

    local cut = maxLen - 3
    for i = cut, math.max(1, cut - 60), -1 do
        local ch = text:sub(i, i)
        if ch == "." or ch == ";" or ch == "," then
            cut = i
            break
        end
        if ch == " " then cut = i end
    end
    return zo_strtrim(text:sub(1, cut)) .. "..."
end
DMC.TrimPlainText = trimPlainText

function DMC.StripChatFormatting(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    return text
end

function DMC.TrimForChat(text)
    -- Final safety net for already-formatted payloads. If something exceeds the
    -- budget, drop formatting first rather than slicing through a color tag.
    text = tostring(text or "")
    local maxLen = DMC.GetChatPayloadBudget()
    if #text <= maxLen then return text end

    local plain = DMC.StripChatFormatting(text)
    if #plain <= maxLen then return plain end
    return trimPlainText(plain, maxLen)
end

local function utf8PrefixByteEnd(text, maxCharacters)
    text = tostring(text or "")
    maxCharacters = math.max(0, tonumber(maxCharacters) or 0)
    local byteIndex = 1
    local characterCount = 0
    local byteEnd = 0

    while byteIndex <= #text and characterCount < maxCharacters do
        local firstByte = text:byte(byteIndex)
        local characterBytes = 1
        if firstByte >= 240 then
            characterBytes = 4
        elseif firstByte >= 224 then
            characterBytes = 3
        elseif firstByte >= 192 then
            characterBytes = 2
        end
        byteEnd = math.min(#text, byteIndex + characterBytes - 1)
        byteIndex = byteEnd + 1
        characterCount = characterCount + 1
    end

    return byteEnd
end

function DMC.TruncateUTF8(text, maxCharacters)
    text = tostring(text or "")
    maxCharacters = math.max(0, tonumber(maxCharacters) or 0)
    if ZoUTF8StringLength(text) <= maxCharacters then return text end
    return text:sub(1, utf8PrefixByteEnd(text, maxCharacters))
end

-- ESO UI labels support pipe color tags like |cRRGGBBtext|r, but player chat
-- sanitizes/breaks them after sending. UI can stay colored; pasted chat must be plain.
DMC.colors = {
    prefix = "66CCFF",
    dungeon = "D9A441",
    boss = "CC66FF",
    mechanic = "FFF000",
    danger = "FF5555",
    warning = "FFB84D",
    tank = "66CCFF",
    healer = "66FF99",
    dps = "FFB84D",
    hm = "B266FF",
    secret = "D9A441",
    neutral = "DDDDDD",
}

function DMC.Color(hex, text)
    return "|c" .. tostring(hex or "FFFFFF") .. tostring(text or "") .. "|r"
end

local function hasTag(tags, wanted)
    if not tags then return false end
    local wantedNorm = normalizeText(wanted)
    for _, tag in ipairs(tags) do
        if normalizeText(tag) == wantedNorm then return true end
    end
    return false
end
DMC.HasTag = hasTag

function DMC.GetDungeonCode(dungeon)
    if not dungeon then return "DUN" end
    if dungeon.aliases and dungeon.aliases[1] and dungeon.aliases[1] ~= "" then
        return dungeon.aliases[1]
    end
    local code = ""
    for word in tostring(dungeon.name or "Dungeon"):gmatch("%a+") do
        code = code .. word:sub(1,1):upper()
    end
    if code == "" or #code > 5 then code = tostring(dungeon.name or "DUN"):sub(1, 5) end
    return code
end

function DMC.GetRoleMarker(role, plain)
    local text
    if role == "tank" then text = "[TANK]"
    elseif role == "healer" then text = "[HEALER]"
    elseif role == "dps" then text = "[DPS]"
    else return nil end

    if plain then return text end
    if role == "tank" then return DMC.Color(DMC.colors.tank, text) end
    if role == "healer" then return DMC.Color(DMC.colors.healer, text) end
    if role == "dps" then return DMC.Color(DMC.colors.dps, text) end
    return text
end

function DMC.GetImportantMarker(tags, plain)
    -- Full mode (internal all) gets ONE high-signal tag only. No role tags here.
    local text
    local color
    if hasTag(tags, "Wipe") or hasTag(tags, "One-shot") then
        text, color = "[!]", DMC.colors.danger
    elseif hasTag(tags, "Interrupt") then
        text, color = "[INT]", DMC.colors.warning
    elseif hasTag(tags, "Add") or hasTag(tags, "Priority") then
        text, color = "[ADD]", DMC.colors.warning
    elseif hasTag(tags, "Secret") then
        text, color = "[SECRET]", DMC.colors.secret
    else
        return nil
    end

    if plain then return text end
    return DMC.Color(color, text)
end

function DMC.GetShortChatLabel(label)
    label = zo_strtrim(tostring(label or ""))
    if label == "" then return "Mech" end

    -- Data modules can set shortName for perfect labels. This fallback keeps
    -- chat readable without spending 35+ characters on long mechanic names.
    local cut = label:find(" / ", 1, true) or label:find(" + ", 1, true)
    if cut and cut > 5 then label = zo_strtrim(label:sub(1, cut - 1)) end
    if #label <= 42 then return label end

    local short = label:sub(1, 42)
    for i = 42, math.max(1, 42 - 12), -1 do
        if short:sub(i, i) == " " then
            short = short:sub(1, i - 1)
            break
        end
    end
    return zo_strtrim(short)
end

function DMC.GetCompactTagText(tags, role)
    -- UI-only colored tag. Pasted chat uses BuildChatPrefix(), which is plain.
    if role and role ~= "all" then
        return DMC.GetRoleMarker(role, false) or ""
    end
    return DMC.GetImportantMarker(tags, false) or ""
end


function DMC.JoinLabels(labels, separator)
    if not labels then return "" end
    local out = {}
    if type(labels) == "table" then
        for _, value in ipairs(labels) do
            value = zo_strtrim(tostring(value or ""))
            if value ~= "" then table.insert(out, value) end
        end
    else
        local value = zo_strtrim(tostring(labels or ""))
        if value ~= "" then table.insert(out, value) end
    end
    return table.concat(out, separator or " / ")
end

function DMC.GetMechanicLabel(mech, mode)
    if not mech then return "Mechanic" end
    local casts = DMC.JoinLabels(
        DMC.GetModeValue(mech, "casts", mode)
            or DMC.GetModeValue(mech, "moveNames", mode)
            or DMC.GetModeValue(mech, "abilityNames", mode),
        " / ")
    if casts ~= "" then return casts end
    local short = zo_strtrim(tostring(DMC.GetModeValue(mech, "shortName", mode) or ""))
    if short ~= "" then return short end
    local name = zo_strtrim(tostring(DMC.GetModeValue(mech, "name", mode) or ""))
    if name ~= "" then return name end
    return "Mechanic"
end

function DMC.BuildChatPrefix(opts)
    opts = opts or {}
    local parts = {}

    if opts.kind == "dungeon" then
        -- No global DMC/dungeon-code prefix: every character should carry useful mechanic info.
    elseif opts.kind == "boss" then
        -- Boss paste uses the same summary text shown in the UI; no extra prefix.
    elseif opts.kind == "mechanic" then
        local roleMarker = DMC.GetRoleMarker(opts.role, true)
        if roleMarker then
            table.insert(parts, roleMarker)
        else
            local important = DMC.GetImportantMarker(opts.tags, true)
            if important then table.insert(parts, important) end
        end

        if opts.label and opts.label ~= "" then
            local label = DMC.GetShortChatLabel(opts.shortLabel or opts.label)
            table.insert(parts, label .. ":")
        end
    end

    return table.concat(parts, " ")
end

function DMC.GetPlainTextBudget(opts)
    local prefix = DMC.BuildChatPrefix(opts)
    local payloadBudget = DMC.GetChatPayloadBudget()
    local available = payloadBudget - #prefix - 1
    local preferred = DMC.defaultPlainChatBudget or 220
    if available > preferred then available = preferred end
    if available < 80 then available = 80 end
    return available
end

function DMC.FormatChatLine(text, opts)
    opts = opts or {}
    local prefix = DMC.BuildChatPrefix(opts)
    local available = DMC.GetChatPayloadBudget() - #prefix - 1
    local body = trimPlainText(text, available)
    local line = prefix ~= "" and (prefix .. " " .. body) or body
    if #line > DMC.GetChatPayloadBudget() then
        body = trimPlainText(body, DMC.GetChatPayloadBudget() - #prefix - 4)
        line = prefix ~= "" and (prefix .. " " .. body) or body
    end
    return line
end

function DMC.SplitLongText(text, maxRaw)
    text = zo_strtrim(tostring(text or ""))
    maxRaw = maxRaw or DMC.defaultPlainChatBudget
    if maxRaw < 80 then maxRaw = 80 end
    if text == "" then return {} end
    if #text <= maxRaw then return { text } end

    local lines = {}
    while #text > maxRaw do
        local cut = maxRaw
        local foundPunctuation = false
        for i = maxRaw, math.max(1, maxRaw - 80), -1 do
            local ch = text:sub(i, i)
            if ch == "." or ch == ";" or ch == "," then
                cut = i
                foundPunctuation = true
                break
            end
        end
        if not foundPunctuation then
            for i = maxRaw, math.max(1, maxRaw - 80), -1 do
                if text:sub(i, i) == " " then
                    cut = i
                    break
                end
            end
        end

        local line = zo_strtrim(text:sub(1, cut))
        if line ~= "" then table.insert(lines, line) end
        text = zo_strtrim(text:sub(cut + 1))
    end
    if text ~= "" then table.insert(lines, text) end
    return lines
end

function DMC.SplitUTF8LongText(text, maxCharacters)
    text = zo_strtrim(tostring(text or ""))
    maxCharacters = maxCharacters or DMC.defaultPlainChatBudget
    if maxCharacters < 80 then maxCharacters = 80 end
    if text == "" then return {} end
    if ZoUTF8StringLength(text) <= maxCharacters then return { text } end

    local lines = {}
    while ZoUTF8StringLength(text) > maxCharacters do
        local prefixEnd = utf8PrefixByteEnd(text, maxCharacters)
        local searchStart = utf8PrefixByteEnd(text, math.max(1, maxCharacters - 80))
        local cut = prefixEnd
        local lastPunctuation
        local lastSpace
        for i = math.max(1, searchStart), prefixEnd do
            local ch = text:sub(i, i)
            if ch == "." or ch == ";" or ch == "," then
                lastPunctuation = i
            elseif ch == " " then
                lastSpace = i
            end
        end
        cut = lastPunctuation or lastSpace or prefixEnd

        local line = zo_strtrim(text:sub(1, cut))
        if line ~= "" then table.insert(lines, line) end
        text = zo_strtrim(text:sub(cut + 1))
    end
    if text ~= "" then table.insert(lines, text) end
    return lines
end

local function appendFormattedLines(out, rawText, opts)
    opts = opts or {}
    local maxRaw = DMC.GetPlainTextBudget(opts)
    local chunks = DMC.SplitLongText(rawText, maxRaw)
    for i, chunk in ipairs(chunks) do
        if opts.prefixFirstOnly and i > 1 then
            table.insert(out, DMC.TrimForChat(chunk))
        else
            table.insert(out, DMC.FormatChatLine(chunk, opts))
        end
    end
end

function DMC.BuildDungeonChatLines(dungeon, mode)
    local out = {}
    if dungeon and dungeon.summary then
        local opts = { kind = "dungeon", dungeon = dungeon, prefixFirstOnly = true }
        local text = DMC.GetModeText(dungeon.summary, {"ui", "full"}, mode)
        if text and text ~= "" then
            appendFormattedLines(out, text, opts)
        else
            local chat = DMC.GetModeValue(dungeon.summary, "chat", mode)
            for _, raw in ipairs(chat or {}) do
                appendFormattedLines(out, raw, opts)
            end
        end
    end
    return out
end

function DMC.BuildBossChatLines(dungeon, boss, mode)
    local out = {}
    if boss then
        local opts = { kind = "boss", dungeon = dungeon, boss = boss, label = boss.shortName or boss.name, prefixFirstOnly = true }
        local text = DMC.GetModeText(boss, {"ui", "summary"}, mode)
        if text and text ~= "" then
            appendFormattedLines(out, text, opts)
        else
            local chat = DMC.GetModeValue(boss, "chat", mode)
            for _, raw in ipairs(chat or {}) do
                appendFormattedLines(out, raw, opts)
            end
        end
    end
    return out
end

function DMC.BuildMechanicChatLines(dungeon, boss, mech, role, mode)
    local out = {}
    if not mech or not DMC.IsVisibleForMode(mech, mode) then return out end
    local rawLines = {}

    if role == "quick" then
        -- Quick tab is still group-facing, not a role tab. It should preserve
        -- the real decision players need to make, just with less teaching text.
        local quick = DMC.GetModeValue(mech, "quick", mode)
        local quickChat = DMC.GetModeValue(mech, "quickChat", mode)
        if quick and quick ~= "" then
            table.insert(rawLines, quick)
        elseif quickChat and #quickChat > 0 then
            for _, raw in ipairs(quickChat) do table.insert(rawLines, raw) end
        end
    elseif role and role ~= "all" then
        -- Role tabs intentionally paste specific coaching. They are for when a
        -- tank/healer/DPS asks or keeps failing a role-specific mechanic.
        local roleText = DMC.GetModeValue(mech, role, mode)
        local general = DMC.GetModeValue(mech, "general", mode)
        if roleText and roleText ~= "" then
            table.insert(rawLines, roleText)
        elseif general and general ~= "" then
            table.insert(rawLines, general)
        end
    else
        -- Full tab is the default PUG explanation. It should explain the whole
        -- mechanic generally, mentioning roles in the sentence when relevant.
        local all = DMC.GetModeValue(mech, "all", mode)
        local general = DMC.GetModeValue(mech, "general", mode)
        local chat = DMC.GetModeValue(mech, "chat", mode)
        if all and all ~= "" then
            table.insert(rawLines, all)
        elseif general and general ~= "" then
            table.insert(rawLines, general)
        elseif chat and #chat > 0 then
            for _, raw in ipairs(chat) do table.insert(rawLines, raw) end
        end
    end

    local opts = {
        kind = "mechanic",
        dungeon = dungeon,
        boss = boss,
        tags = DMC.GetModeValue(mech, "tags", mode),
        -- Quick is group-facing, so keep the normal [!]/[INT]/[ADD] tag logic.
        role = (role ~= "all" and role ~= "quick") and role or nil,
        label = DMC.GetMechanicLabel(mech, mode),
        shortLabel = DMC.GetMechanicLabel(mech, mode),
    }

    opts.prefixFirstOnly = true
    for _, raw in ipairs(rawLines) do
        appendFormattedLines(out, raw, opts)
    end
    return out
end

function DMC.PasteToChatInput(text)
    if not text or text == "" then
        DMC.Print("No chat line selected.")
        return
    end
    local safe = DMC.TrimForChat(text)
    -- Prefills chat input only; player still manually chooses/sends the chat channel.
    StartChatInput(safe)
end

-- Backward-compatible alias used by older UI/keybind code.
function DMC.PasteToGroup(text)
    DMC.PasteToChatInput(text)
end

DMC.personalNoteMaxChars = 900
DMC.personalNoteChatChunkChars = 300

local function getLegacyBossNoteKey(dungeonId, bossId)
    if not dungeonId or not bossId then return nil end
    return tostring(dungeonId) .. "::" .. tostring(bossId)
end

local function getBossNoteKey(dungeonId, bossId, mode)
    local legacyKey = getLegacyBossNoteKey(dungeonId, bossId)
    if not legacyKey then return nil end
    return DMC.GetDifficultyMode(mode) .. "::" .. legacyKey
end

local function migrateLegacyBossNotes()
    local notes = DMC.sv and DMC.sv.bossNotes
    if type(notes) ~= "table" then return end

    local legacyEntries = {}
    for key, value in pairs(notes) do
        if type(key) == "string"
            and key:sub(1, 5) ~= "vet::"
            and key:sub(1, 4) ~= "hm::"
            and key:find("::", 1, true) then
            legacyEntries[#legacyEntries + 1] = { key = key, value = value }
        end
    end

    for _, entry in ipairs(legacyEntries) do
        local hmKey = "hm::" .. entry.key
        if notes[hmKey] == nil then notes[hmKey] = entry.value end
        notes[entry.key] = nil
    end
end

function DMC.GetBossNote(dungeonId, bossId, mode)
    local key = getBossNoteKey(dungeonId, bossId, mode)
    local notes = DMC.sv and DMC.sv.bossNotes
    if not key or type(notes) ~= "table" then return "" end
    return tostring(notes[key] or "")
end

function DMC.SetBossNote(dungeonId, bossId, text, mode)
    local key = getBossNoteKey(dungeonId, bossId, mode)
    if not key or not DMC.sv then return "" end

    if type(DMC.sv.bossNotes) ~= "table" then DMC.sv.bossNotes = {} end
    text = tostring(text or ""):gsub("\r\n", "\n")
    text = zo_strtrim(text)
    text = DMC.TruncateUTF8(text, DMC.personalNoteMaxChars)
    if text == "" then
        DMC.sv.bossNotes[key] = nil
    else
        DMC.sv.bossNotes[key] = text
    end
    return text
end

function DMC.PrepareBossNoteForChat(text)
    text = tostring(text or ""):gsub("\r\n", "\n")
    text = text:gsub("%s+", " ")
    return zo_strtrim(text)
end

function DMC.BuildBossNoteChatLines(text)
    local safe = DMC.PrepareBossNoteForChat(text)
    if safe == "" then return {} end
    safe = DMC.TruncateUTF8(safe, DMC.personalNoteMaxChars)
    return DMC.SplitUTF8LongText(safe, DMC.personalNoteChatChunkChars)
end

function DMC.PasteBossNoteToChat(text)
    local safe = DMC.PrepareBossNoteForChat(text)
    if safe == "" then
        DMC.Print("No personal note saved for this boss.")
        return false
    end
    -- Note chunks are generated below ESO's chat-input limit; this function
    -- inserts the chosen chunk without mechanic-specific truncation.
    safe = DMC.TruncateUTF8(safe, DMC.personalNoteChatChunkChars)
    StartChatInput(safe)
    return true
end

function DMC.GetCurrentZoneName()
    local zoneName = GetUnitZone("player")
    if zoneName ~= "" then return zoneName end
    local loc = GetPlayerLocationName()
    if loc ~= "" then return loc end
    return ""
end

function DMC.GetCurrentZoneId()
    local zoneIndex = GetUnitZoneIndex("player")
    if not zoneIndex or zoneIndex <= 0 then return nil end
    local zoneId = GetZoneId(zoneIndex)
    if zoneId > 0 then return zoneId end
    return nil
end

local function dungeonMatchesCurrentLocation(dungeon, zoneId, normalizedZoneName)
    if not dungeon then return false end

    if zoneId and dungeon.zoneIds then
        for _, id in ipairs(dungeon.zoneIds) do
            if id == zoneId then return true end
        end
    end

    if normalizedZoneName == "" then return false end

    if normalizeText(dungeon.name) == normalizedZoneName then return true end
    if dungeon.aliases then
        for _, alias in ipairs(dungeon.aliases) do
            if normalizeText(alias) == normalizedZoneName then return true end
        end
    end
    return false
end

function DMC.IsCurrentDungeon(dungeon)
    return dungeonMatchesCurrentLocation(
        dungeon,
        DMC.GetCurrentZoneId(),
        normalizeText(DMC.GetCurrentZoneName()))
end

function DMC.GetCurrentDungeon()
    local zoneId = DMC.GetCurrentZoneId()
    local normalizedZoneName = normalizeText(DMC.GetCurrentZoneName())
    for _, dungeon in ipairs(DMC.data and DMC.data.dungeons or {}) do
        if dungeonMatchesCurrentLocation(dungeon, zoneId, normalizedZoneName) then
            return dungeon
        end
    end
    return nil
end

DMC.GetCurrentActivity = DMC.GetCurrentDungeon

function DMC.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= DMC.name then return end
    EVENT_MANAGER:UnregisterForEvent(DMC.name, EVENT_ADD_ON_LOADED)

    -- Window preferences and personal reference notes are intentionally
    -- account-wide: neither depends on a character, server, quest, or unlock.
    DMC.sv = ZO_SavedVars:NewAccountWide(
        "DungeonMechsCodex_SavedVars", 1, nil, DMC.defaultSavedVars)
    if type(DMC.sv.bossNotes) ~= "table" then DMC.sv.bossNotes = {} end
    migrateLegacyBossNotes()

    DMC.InitializeUI()

    SLASH_COMMANDS["/dmc"] = function(arg)
        DMC.ToggleWindow()
    end
    SLASH_COMMANDS["/dmech"] = function(arg)
        DMC.ToggleWindow()
    end
    SLASH_COMMANDS["/dungeonmechs"] = function(arg)
        DMC.ToggleWindow()
    end
    SLASH_COMMANDS["/flamecodex"] = function(arg)
        DMC.ToggleWindow()
    end

    EVENT_MANAGER:RegisterForEvent(DMC.name, EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            if DMC.HandlePlayerActivated then DMC.HandlePlayerActivated() end
        end, 200)
    end)

    DMC.Print("loaded. Use /dmc, /dmech, /dungeonmechs, or /flamecodex.")
end

EVENT_MANAGER:RegisterForEvent(DMC.name, EVENT_ADD_ON_LOADED, DMC.OnAddOnLoaded)
