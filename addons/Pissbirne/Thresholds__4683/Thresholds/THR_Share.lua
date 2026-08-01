---------------------------------------------------------------------------
-- Thresholds - export/import serialization and zone copy
--
-- The PURE section (everything up to the "ESO-FACING" divider) makes no
-- ESO API calls, so it runs in the offline test harness via
--     Thresholds = {}; dofile("Thresholds/THR_Share.lua")
-- Keep it that way: ESO globals only below the divider, and only inside
-- function bodies.
--
-- THR1 format (line-based, newline separated, CRLF tolerant):
--     THR1:<SCOPE>:<addonVersion>      SCOPE = GLOBAL|ZONE|BOSS|ALL
--     G:                               global list follows
--     Z:<zoneId>:<enc(zoneName)>       zone; its own thresholds follow
--     B:<enc(bossName)>                boss list inside the current zone
--     A:<k>=<v>[ <k>=<v>]...           one alert entry (sparse fields)
--     E:<count of A: lines>            footer; detects truncated pastes
-- enc() escapes %, space, '=', ':' and control bytes as %XX (uppercase).
---------------------------------------------------------------------------

local THR = Thresholds
THR.Share = {}
local Share = THR.Share

local FORMAT_TAG = "THR1"
local EXPORT_VERSION = 140

---------------------------------------------------------------------------
-- LIST HELPERS (shared with THR_Menu.lua)
---------------------------------------------------------------------------
function Share.EntryPct(entry)
    return type(entry) == "table" and entry.pct or entry
end

-- Collapse an entry table that carries nothing but the percent back to a
-- bare number, so unstyled entries are stored in the compact legacy shape.
function Share.CompactEntry(entry)
    if type(entry) ~= "table" then return entry end
    for key in pairs(entry) do
        if key ~= "pct" then return entry end
    end
    return entry.pct
end

function Share.DeepCopyEntry(entry)
    if type(entry) ~= "table" then return entry end
    local copy = {}
    for key, value in pairs(entry) do
        if key == "color" then
            copy.color = { value[1], value[2], value[3] }
        else
            copy[key] = value
        end
    end
    return copy
end

function Share.DeepCopyList(list)
    local out = {}
    for i = 1, #list do
        out[i] = Share.DeepCopyEntry(list[i])
    end
    return out
end

-- Merge by percent: existing entries keep their slot, imported entries
-- (deep-copied) win same-percent collisions. Sorted descending.
function Share.MergeLists(existing, imported)
    local byPct, order = {}, {}
    local function put(entry, overwrite)
        local pct = Share.EntryPct(entry)
        if byPct[pct] == nil then
            order[#order + 1] = pct
            byPct[pct] = entry
        elseif overwrite then
            byPct[pct] = entry
        end
    end
    if existing then
        for i = 1, #existing do
            put(existing[i], false)
        end
    end
    for i = 1, #imported do
        put(Share.DeepCopyEntry(imported[i]), true)
    end
    table.sort(order, function(a, b) return a > b end)
    local out = {}
    for i = 1, #order do
        out[i] = byPct[order[i]]
    end
    return out
end

---------------------------------------------------------------------------
-- ESCAPING
---------------------------------------------------------------------------
function Share.Encode(s)
    return (string.gsub(s, "[%%=: %c]", function(ch)
        return string.format("%%%02X", string.byte(ch))
    end))
end

-- Strict: returns nil when a % is not followed by two hex digits.
function Share.Decode(s)
    local out, i, n = {}, 1, #s
    while i <= n do
        local ch = string.sub(s, i, i)
        if ch == "%" then
            local hex = string.sub(s, i + 1, i + 2)
            if not string.match(hex, "^%x%x$") then return nil end
            out[#out + 1] = string.char(tonumber(hex, 16))
            i = i + 3
        else
            out[#out + 1] = ch
            i = i + 1
        end
    end
    return table.concat(out)
end

-- Pure clone of THR.FormatPercentValue (THR_Alerts.lua is not loaded in
-- the offline harness).
function Share.FormatPct(value)
    if value % 1 == 0 then
        return tostring(math.floor(value))
    end
    return string.format("%.1f", value)
end

---------------------------------------------------------------------------
-- ENTRY SERIALIZATION
---------------------------------------------------------------------------
function Share.SerializeEntry(stored)
    local parts = { "p=" .. Share.FormatPct(Share.EntryPct(stored)) }
    if type(stored) == "table" then
        if stored.text then
            parts[#parts + 1] = "t=" .. Share.Encode(stored.text)
        end
        if stored.color then
            parts[#parts + 1] = string.format("c=%02x%02x%02x",
                math.floor(stored.color[1] * 255 + 0.5),
                math.floor(stored.color[2] * 255 + 0.5),
                math.floor(stored.color[3] * 255 + 0.5))
        end
        if stored.sound then parts[#parts + 1] = "s=" .. stored.sound end
        if stored.soundRepeat then parts[#parts + 1] = "r=" .. stored.soundRepeat end
        if stored.fontSize then parts[#parts + 1] = "f=" .. stored.fontSize end
        if stored.duration then parts[#parts + 1] = "d=" .. stored.duration end
        if stored.x then parts[#parts + 1] = "x=" .. stored.x end
        if stored.y then parts[#parts + 1] = "y=" .. stored.y end
        if stored.noText then parts[#parts + 1] = "nt=1" end
        if stored.noSound then parts[#parts + 1] = "ns=1" end
    end
    return table.concat(parts, " ")
end

-- Returns a stored-shape entry (number or sparse table), or nil plus
-- "skip" (invalid percent - entry dropped, counted) or "malformed"
-- (structural problem - whole import rejected). Invalid optional fields
-- are dropped; unknown keys are ignored for forward compatibility.
function Share.ParseEntryBody(body, validSounds)
    local entry = {}
    local sawPct = false
    for pair in string.gmatch(body, "%S+") do
        local key, value = string.match(pair, "^(%l+)=(.*)$")
        if not key then return nil, "malformed" end
        if key == "p" then
            local pct = tonumber(value)
            if not pct or pct <= 0 or pct >= 100 then return nil, "skip" end
            entry.pct = math.floor(pct * 10 + 0.5) / 10
            sawPct = true
        elseif key == "t" then
            local text = Share.Decode(value)
            if text == nil then return nil, "malformed" end
            if text ~= "" then entry.text = text end
        elseif key == "c" then
            local r, g, b = string.match(value, "^(%x%x)(%x%x)(%x%x)$")
            if r then
                entry.color = {
                    tonumber(r, 16) / 255,
                    tonumber(g, 16) / 255,
                    tonumber(b, 16) / 255,
                }
            end
        elseif key == "s" then
            if string.match(value, "^[A-Z0-9_]+$")
                    and (not validSounds or validSounds[value]) then
                entry.sound = value
            end
        elseif key == "r" then
            local n = tonumber(value)
            if n == 2 or n == 3 then entry.soundRepeat = n end
        elseif key == "f" then
            local n = tonumber(value)
            if n and n == math.floor(n) and n >= 24 and n <= 48 then
                entry.fontSize = n
            end
        elseif key == "d" then
            local n = tonumber(value)
            if n and n == math.floor(n) and n >= 1 and n <= 10 then
                entry.duration = n
            end
        elseif key == "x" or key == "y" then
            local n = tonumber(value)
            if n and n == math.floor(n) then entry[key] = n end
        elseif key == "nt" then
            if value == "1" then entry.noText = true end
        elseif key == "ns" then
            if value == "1" then entry.noSound = true end
        end
    end
    if not sawPct then return nil, "malformed" end
    if (entry.x and not entry.y) or (entry.y and not entry.x) then
        entry.x, entry.y = nil, nil
    end
    return Share.CompactEntry(entry)
end

---------------------------------------------------------------------------
-- PAYLOAD SERIALIZATION
---------------------------------------------------------------------------
-- payload = {
--     scope = "GLOBAL"|"ZONE"|"BOSS"|"ALL",
--     version = number,
--     global = <list>|nil,
--     zones = { { id, name, thresholds = <list>|nil, hasZoneList = bool,
--                 bosses = { { name, list = <list> }, ... } }, ... },
-- }
function Share.Serialize(payload)
    local lines = {
        FORMAT_TAG .. ":" .. payload.scope .. ":" .. (payload.version or EXPORT_VERSION),
    }
    local count = 0
    local function emitList(list)
        for i = 1, #list do
            lines[#lines + 1] = "A:" .. Share.SerializeEntry(list[i])
            count = count + 1
        end
    end
    if payload.global then
        lines[#lines + 1] = "G:"
        emitList(payload.global)
    end
    local zones = payload.zones or {}
    for z = 1, #zones do
        local zone = zones[z]
        lines[#lines + 1] = "Z:" .. zone.id .. ":" .. Share.Encode(zone.name or "")
        if zone.hasZoneList then
            emitList(zone.thresholds or {})
        end
        local bosses = zone.bosses or {}
        for b = 1, #bosses do
            lines[#lines + 1] = "B:" .. Share.Encode(bosses[b].name)
            emitList(bosses[b].list)
        end
    end
    lines[#lines + 1] = "E:" .. count
    return table.concat(lines, "\n")
end

local VALID_SCOPES = { GLOBAL = true, ZONE = true, BOSS = true, ALL = true }

-- Returns payload, nil, stats on success or nil, errorMessage on failure.
-- opts.validSounds: set of allowed sound keys (nil = accept any wellformed).
function Share.Deserialize(text, opts)
    opts = opts or {}
    if type(text) ~= "string" then return nil, "no import string." end

    local payload = { zones = {} }
    local stats = { entries = 0, skipped = 0, zoneCount = 0, bossCount = 0 }
    local currentZone = nil
    local currentList = nil
    local seenZoneIds = {}
    local footerCount = nil
    local lineNo = 0

    for rawLine in string.gmatch(text .. "\n", "([^\n]*)\n") do
        lineNo = lineNo + 1
        local line = string.match(rawLine, "^%s*(.-)%s*$")
        if line ~= "" then
            if footerCount then
                return nil, "unexpected content after the end marker (line " .. lineNo .. ")."
            end
            if not payload.scope then
                local scope, version = string.match(line,
                    "^" .. FORMAT_TAG .. ":(%u+):(%d+)$")
                if not scope or not VALID_SCOPES[scope] then
                    return nil, "not a Thresholds export string (or made by a newer version)."
                end
                payload.scope = scope
                payload.version = tonumber(version)
            else
                local scope = payload.scope
                local prefix, rest = string.match(line, "^(%u+):(.*)$")
                if prefix == "G" and rest == "" then
                    if scope ~= "GLOBAL" and scope ~= "ALL" then
                        return nil, "unexpected global section for scope " .. scope .. " (line " .. lineNo .. ")."
                    end
                    if payload.global then
                        return nil, "duplicate global section (line " .. lineNo .. ")."
                    end
                    payload.global = {}
                    currentZone = nil
                    currentList = payload.global
                elseif prefix == "Z" then
                    if scope == "GLOBAL" then
                        return nil, "unexpected zone section for scope GLOBAL (line " .. lineNo .. ")."
                    end
                    local idStr, encName = string.match(rest, "^(%d+):(.*)$")
                    local id = idStr and tonumber(idStr)
                    local name = encName and Share.Decode(encName)
                    if not id or id <= 0 or not name then
                        return nil, "malformed zone line (line " .. lineNo .. ")."
                    end
                    if seenZoneIds[id] then
                        return nil, "duplicate zone " .. id .. " (line " .. lineNo .. ")."
                    end
                    seenZoneIds[id] = true
                    currentZone = {
                        id = id,
                        name = name,
                        hasZoneList = scope ~= "BOSS",
                        bosses = {},
                        seenBossNames = {},
                    }
                    if currentZone.hasZoneList then
                        currentZone.thresholds = {}
                        currentList = currentZone.thresholds
                    else
                        currentList = nil
                    end
                    payload.zones[#payload.zones + 1] = currentZone
                    stats.zoneCount = stats.zoneCount + 1
                elseif prefix == "B" then
                    if not currentZone then
                        return nil, "boss section outside of a zone (line " .. lineNo .. ")."
                    end
                    local name = Share.Decode(rest)
                    if not name or name == "" then
                        return nil, "malformed boss line (line " .. lineNo .. ")."
                    end
                    if currentZone.seenBossNames[name] then
                        return nil, "duplicate boss \"" .. name .. "\" (line " .. lineNo .. ")."
                    end
                    currentZone.seenBossNames[name] = true
                    local boss = { name = name, list = {} }
                    currentZone.bosses[#currentZone.bosses + 1] = boss
                    currentList = boss.list
                    stats.bossCount = stats.bossCount + 1
                elseif prefix == "A" then
                    if not currentList then
                        return nil, "alert entry outside of a section (line " .. lineNo .. ")."
                    end
                    local entry, err = Share.ParseEntryBody(rest, opts.validSounds)
                    if entry == nil then
                        if err == "skip" then
                            stats.skipped = stats.skipped + 1
                        else
                            return nil, "malformed alert entry (line " .. lineNo .. ")."
                        end
                    else
                        -- duplicate percents within one list: keep the first
                        local pct = Share.EntryPct(entry)
                        local duplicate = false
                        for i = 1, #currentList do
                            if Share.EntryPct(currentList[i]) == pct then
                                duplicate = true
                                break
                            end
                        end
                        if duplicate then
                            stats.skipped = stats.skipped + 1
                        else
                            currentList[#currentList + 1] = entry
                            stats.entries = stats.entries + 1
                        end
                    end
                elseif prefix == "E" then
                    footerCount = tonumber(rest)
                    if not footerCount then
                        return nil, "malformed end marker (line " .. lineNo .. ")."
                    end
                else
                    return nil, "unrecognized line " .. lineNo .. "."
                end
            end
        end
    end

    if not payload.scope then
        return nil, "not a Thresholds export string."
    end
    if not footerCount or footerCount ~= stats.entries + stats.skipped then
        return nil, "string incomplete - the paste was probably cut off."
    end

    -- structural validation per scope
    local scope = payload.scope
    if scope == "GLOBAL" and (not payload.global or #payload.zones > 0) then
        return nil, "invalid GLOBAL payload."
    end
    if (scope == "ZONE" or scope == "BOSS") and (payload.global or #payload.zones ~= 1) then
        return nil, "invalid " .. scope .. " payload."
    end
    if scope == "BOSS" and #payload.zones[1].bosses ~= 1 then
        return nil, "invalid BOSS payload."
    end

    for z = 1, #payload.zones do
        payload.zones[z].seenBossNames = nil
    end
    return payload, nil, stats
end

---------------------------------------------------------------------------
-- ESO-FACING (everything below may touch ESO API and other THR modules)
---------------------------------------------------------------------------
local validSoundsSet

function Share.GetValidSounds()
    if not validSoundsSet then
        validSoundsSet = {}
        for i = 1, #THR.SOUND_CHOICES do
            validSoundsSet[THR.SOUND_CHOICES[i]] = true
        end
    end
    return validSoundsSet
end

local function ResolveZoneName(zoneId, fallback)
    local name = THR.GetCleanName(GetZoneNameById(zoneId) or "")
    if name ~= "" then return name end
    return fallback or ""
end

local function BuildZoneSection(zoneId, zone)
    local section = {
        id = zoneId,
        name = zone.name or "",
        thresholds = zone.thresholds or {},
        hasZoneList = true,
        bosses = {},
    }
    if zone.bosses then
        local names = {}
        for name in pairs(zone.bosses) do
            names[#names + 1] = name
        end
        table.sort(names)
        for i = 1, #names do
            section.bosses[i] = { name = names[i], list = zone.bosses[names[i]] }
        end
    end
    return section
end

function Share.ExportGlobal()
    return Share.Serialize({
        scope = "GLOBAL",
        version = EXPORT_VERSION,
        global = THR.SV.globalThresholds,
        zones = {},
    })
end

function Share.ExportZone(zoneId)
    local zone = THR.SV.zones[zoneId]
    if not zone or (not zone.thresholds and not zone.bosses) then
        return nil, "the current zone has no Thresholds configuration to export."
    end
    return Share.Serialize({
        scope = "ZONE",
        version = EXPORT_VERSION,
        zones = { BuildZoneSection(zoneId, zone) },
    })
end

function Share.ExportBoss(zoneId, bossName)
    local zone = THR.SV.zones[zoneId]
    local override = zone and zone.bosses and zone.bosses[bossName]
    if not override then
        return nil, "no per-boss override stored for \"" .. bossName .. "\" in this zone."
    end
    return Share.Serialize({
        scope = "BOSS",
        version = EXPORT_VERSION,
        zones = {
            {
                id = zoneId,
                name = zone.name or "",
                hasZoneList = false,
                bosses = { { name = bossName, list = override } },
            },
        },
    })
end

function Share.ExportAll()
    local zones = {}
    local ids = {}
    for zoneId in pairs(THR.SV.zones) do
        ids[#ids + 1] = zoneId
    end
    table.sort(ids)
    for i = 1, #ids do
        zones[#zones + 1] = BuildZoneSection(ids[i], THR.SV.zones[ids[i]])
    end
    return Share.Serialize({
        scope = "ALL",
        version = EXPORT_VERSION,
        global = THR.SV.globalThresholds,
        zones = zones,
    })
end

local SCOPE_LABELS = {
    GLOBAL = "Global defaults",
    ZONE = "Zone configuration",
    BOSS = "Single boss override",
    ALL = "Full profile",
}

-- Dialog body: names and counts only, never raw alert texts.
function Share.DescribePayload(payload, stats)
    local lines = { "Scope: " .. (SCOPE_LABELS[payload.scope] or payload.scope) }
    if payload.scope == "GLOBAL" or payload.scope == "ALL" then
        lines[#lines + 1] = string.format("Global alerts: %d", payload.global and #payload.global or 0)
    end
    if payload.scope == "ZONE" or payload.scope == "BOSS" then
        local zone = payload.zones[1]
        lines[#lines + 1] = string.format("Target zone: %s (id %d) - %s", zone.name, zone.id,
            zone.id == THR.currentZoneId and "your current zone" or "NOT your current zone")
        if payload.scope == "ZONE" then
            lines[#lines + 1] = string.format("Zone thresholds: %d", #(zone.thresholds or {}))
            if #zone.bosses > 0 then
                local parts = {}
                for b = 1, #zone.bosses do
                    parts[b] = string.format("%s (%d)", zone.bosses[b].name, #zone.bosses[b].list)
                end
                lines[#lines + 1] = "Boss overrides: " .. table.concat(parts, ", ")
            end
        else
            local boss = payload.zones[1].bosses[1]
            lines[#lines + 1] = string.format("Boss: %s (%d alerts)", boss.name, #boss.list)
        end
    elseif payload.scope == "ALL" then
        lines[#lines + 1] = string.format("Zones: %d, boss overrides: %d, alerts total: %d",
            stats.zoneCount, stats.bossCount, stats.entries)
    end
    if stats.skipped > 0 then
        lines[#lines + 1] = string.format("%d entries were skipped (invalid or duplicate percent).", stats.skipped)
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Replace overwrites the listed configuration. Merge combines by percent"
        .. " (the imported alert wins when both define the same percent). ESC cancels."
    return table.concat(lines, "\n")
end

-- Writes the payload into the saved variables ("replace" or "merge").
-- SV only - the caller handles ReapplyThresholds and UI refreshes. Every
-- write is deep-copied so SV never aliases the payload.
function Share.Apply(payload, mode)
    local SV = THR.SV
    local replace = mode == "replace"
    local summary = { lists = 0, entries = 0 }
    local function count(list)
        summary.lists = summary.lists + 1
        summary.entries = summary.entries + #list
    end

    if payload.global then
        if replace then
            SV.globalThresholds = Share.DeepCopyList(payload.global)
            count(payload.global)
        elseif #payload.global > 0 then
            SV.globalThresholds = Share.MergeLists(SV.globalThresholds, payload.global)
            count(payload.global)
        end
    end

    for z = 1, #payload.zones do
        local pz = payload.zones[z]
        local resolvedName = ResolveZoneName(pz.id, pz.name)
        if replace and pz.hasZoneList then
            -- Mirror the sender's zone wholesale (stale boss overrides go).
            local zone = { name = resolvedName }
            if #(pz.thresholds or {}) > 0 then
                zone.thresholds = Share.DeepCopyList(pz.thresholds)
            end
            if #pz.bosses > 0 then
                zone.bosses = {}
                for b = 1, #pz.bosses do
                    zone.bosses[pz.bosses[b].name] = Share.DeepCopyList(pz.bosses[b].list)
                end
            end
            SV.zones[pz.id] = zone
            THR.PruneZoneConfig(pz.id)
            count(pz.thresholds or {})
            for b = 1, #pz.bosses do
                count(pz.bosses[b].list)
            end
        else
            -- BOSS-scope replace and every merge touch only what they carry.
            local function ensureZone()
                local zone = THR.GetZoneConfig(pz.id, true)
                if not zone.name or zone.name == "" then
                    zone.name = resolvedName
                end
                return zone
            end
            if pz.hasZoneList and #(pz.thresholds or {}) > 0 then
                local zone = ensureZone()
                zone.thresholds = Share.MergeLists(zone.thresholds, pz.thresholds)
                count(pz.thresholds)
            end
            for b = 1, #pz.bosses do
                local pb = pz.bosses[b]
                if #pb.list == 0 then
                    if replace then
                        local zone = SV.zones[pz.id]
                        if zone and zone.bosses then
                            zone.bosses[pb.name] = nil
                            if next(zone.bosses) == nil then zone.bosses = nil end
                        end
                        count(pb.list)
                    end
                else
                    local zone = ensureZone()
                    zone.bosses = zone.bosses or {}
                    if replace then
                        zone.bosses[pb.name] = Share.DeepCopyList(pb.list)
                    else
                        zone.bosses[pb.name] = Share.MergeLists(zone.bosses[pb.name], pb.list)
                    end
                    count(pb.list)
                end
            end
            THR.PruneZoneConfig(pz.id)
        end
    end
    return summary
end

-- Copies only zone.thresholds (styled entries deep-copied); boss overrides
-- stay behind - their names would not match another zone's bosses.
function Share.CopyZoneThresholds(fromZoneId, toZoneId)
    local source = THR.SV.zones[fromZoneId]
    if not source or not source.thresholds then
        d("|c66CCFFThresholds:|r the selected source zone no longer has zone thresholds.")
        return false
    end
    if fromZoneId == toZoneId then
        return false
    end
    THR.GetZoneConfig(toZoneId, true).thresholds = Share.DeepCopyList(source.thresholds)
    d(string.format("|c66CCFFThresholds:|r copied %d zone thresholds from %s.",
        #source.thresholds, source.name or tostring(fromZoneId)))
    return true
end
