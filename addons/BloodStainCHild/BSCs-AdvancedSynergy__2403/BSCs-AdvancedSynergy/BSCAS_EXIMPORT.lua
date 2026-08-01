BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

local function _escape_str(s)
    -- einfache Escapes für Lua-Stringliteral
    s = tostring(s or "")
    s = s:gsub("\\", "\\\\"):gsub("\"", "\\\"")
    return s
end

local function _val_lit(v)
  local t = type(v)
  if t == "boolean" or t == "number" then return tostring(v) end
  if t == "string" then return "\"" .. _escape_str(v) .. "\"" end
  return "nil"
end

local function _spairs(t)
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end
  table.sort(keys)
  local i = 0
  return function()
    i = i + 1
    local k = keys[i]
    if k ~= nil then return k, t[k] end
  end
end


------------------------------------------------------------
-- Base64 (ESO-kompatibel, ohne Bitoperatoren)
------------------------------------------------------------
local function base64enc(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s = {}
    local len = #data
    local i = 1
    while i <= len do
        local a = string.byte(data, i) or 0
        local b1 = string.byte(data, i + 1) or 0
        local c = string.byte(data, i + 2) or 0
        local n = a * 65536 + b1 * 256 + c

        local n1 = math.floor(n / 262144) % 64 + 1
        local n2 = math.floor(n / 4096) % 64 + 1
        local n3 = math.floor(n / 64) % 64 + 1
        local n4 = (n % 64) + 1

        table.insert(s, b:sub(n1, n1) .. b:sub(n2, n2) .. b:sub(n3, n3) .. b:sub(n4, n4))
        i = i + 3
    end

    local r = len % 3
    if r == 1 then
        s[#s] = s[#s]:sub(1, 2) .. "=="
    elseif r == 2 then
        s[#s] = s[#s]:sub(1, 3) .. "="
    end
    return table.concat(s)
end

local function base64dec(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local clean = data:gsub("[^" .. b .. "=]", "")
    local t = {}
    local i = 1

    while i <= #clean do
        local c1 = clean:sub(i, i)
        local c2 = clean:sub(i + 1, i + 1)
        local c3 = clean:sub(i + 2, i + 2)
        local c4 = clean:sub(i + 3, i + 3)

        local n1 = (b:find(c1, 1, true) or 1) - 1
        local n2 = (b:find(c2, 1, true) or 1) - 1
        local n3 = c3 == "=" and 0 or ((b:find(c3, 1, true) or 1) - 1)
        local n4 = c4 == "=" and 0 or ((b:find(c4, 1, true) or 1) - 1)

        local n = n1 * 262144 + n2 * 4096 + n3 * 64 + n4
        local a = math.floor(n / 65536)
        local b2 = math.floor((n % 65536) / 256)
        local c = n % 256

        table.insert(t, string.char(a))
        if c3 ~= "=" then table.insert(t, string.char(b2)) end
        if c4 ~= "=" then table.insert(t, string.char(c)) end

        i = i + 4
    end

    return table.concat(t)
end

-- Blocking
-- Strenges Deserialisieren eines Settings-Objekts
local function _deserialize_settings_from_lua_table(luaText)
  local chunk, err = zo_loadstring("return " .. luaText)
  if not chunk then return nil, "load:"..tostring(err) end
  local ok, tbl = pcall(chunk)
  if not ok or type(tbl) ~= "table" then return nil, "pcall" end
  if tbl.version ~= 2 or type(tbl.settings) ~= "table" then return nil, "bad_hdr" end
  return tbl
end

-- Baut eine "Whitelist + erwartete Typen" aus dem aktuellen Preset
local function _build_schema_from_dest(dest)
  local schema = {}
  for k, v in pairs(dest) do schema[k] = type(v) end
  return schema
end

-- Neuer Export -------------------------------------------------------
-- Neuer Export: sortiert, Base64 eines Lua-Tabellenliterals
function BSCAS:ExportBlocked()
  local presetName = self.SV.SELECTED_PRESET
  local dest = self.SV_acc and self.SV_acc.SETTING and self.SV_acc.SETTING[presetName]
  if not dest then
    CHAT_ROUTER:AddSystemMessage("|cFF0000[AdvancedSynergy]|r Preset not found.")
    return
  end

  local buf = {}
  buf[#buf+1] = "{version=2,preset=\"" .. _escape_str(presetName) .. "\",settings={"
  local first = true
  for k, v in _spairs(dest) do
    if not first then buf[#buf+1] = "," end
    first = false
    buf[#buf+1] = k .. "=" .. _val_lit(v)
  end
  buf[#buf+1] = "}}"

  return base64enc(table.concat(buf))
end

-- Neuer Import: v2 bevorzugt, altes /key=value/ als Fallback
function BSCAS:ImportBlocked(text)
  if not text or text == "" then
    CHAT_ROUTER:AddSystemMessage("|cFF0000[AdvancedSynergy]|r Empty import.")
    return false
  end

  local presetName = self.SV.SELECTED_PRESET
  local dest = self.SV_acc and self.SV_acc.SETTING and self.SV_acc.SETTING[presetName]
  if not dest then
    CHAT_ROUTER:AddSystemMessage("|cFF0000[AdvancedSynergy]|r Preset not found.")
    return false
  end
  local schema = _build_schema_from_dest(dest)

  -- 1) Neuer Container (Base64 + Lua-Table)
  do
    local decoded = base64dec(text or "")
    if decoded and decoded ~= "" then
      local data = _deserialize_settings_from_lua_table(decoded)
      if data and data.settings then
        for k, v in pairs(data.settings) do
          local expected = schema[k]
          if expected then
            local vt = type(v)
            if vt == expected then
              dest[k] = v
            elseif expected == "number" and (vt == "string" and tonumber(v)) then
              dest[k] = tonumber(v)
            elseif expected == "boolean" then
              if vt == "string" then
                local s = v:lower()
                if s == "true" or s == "1" then dest[k] = true
                elseif s == "false" or s == "0" then dest[k] = false end
              elseif vt == "number" then
                dest[k] = (v ~= 0)
              end
            elseif expected == "string" then
              dest[k] = tostring(v)
            end
          end -- unbekannte Keys werden ignoriert
        end
        self.UpdateSetting()
        CHAT_ROUTER:AddSystemMessage("|c00FF00[AdvancedSynergy]|r Settings imported (v2).")
        return true
      end
    end
  end

  -- 2) Legacy-Format: /key=value/
  local matched = false
  for key, value in string.gmatch(text, "/(.-)=(.-)/") do
    matched = true
    local expected = schema[key]
    if expected then
      if expected == "boolean" then
        local s = tostring(value):lower()
        dest[key] = (s == "true" or s == "1")
      elseif expected == "number" then
        dest[key] = tonumber(value) or dest[key]
      else
        dest[key] = value
      end
    end
  end
  if matched then
    self.UpdateSetting()
    CHAT_ROUTER:AddSystemMessage("|c00FF00[AdvancedSynergy]|r Settings imported (legacy).")
    return true
  end

  CHAT_ROUTER:AddSystemMessage("|cFF0000[AdvancedSynergy]|r Invalid import string.")
  return false
end

-- Priority System
------------------------------------------------------------
-- Hilfsfunktionen: Escape & (De-)Serialisierung als Lua-Table
------------------------------------------------------------
-- Baut ein Lua-Tabellenliteral (als String) aus einem Preset
local function _serialize_preset_to_lua_table(presetName, preset)
    local out = {}
    table.insert(out, "{version=1,name=\"" .. _escape_str(presetName) .. "\",groups={")

    local groups = preset.groups or {}
    for gi, g in ipairs(groups) do
        local gname = g.name or ("Group " .. gi)
        local guid  = tonumber(g.uid or 0) or 0
        table.insert(out, "{uid=" .. tostring(guid) .. ",name=\"" .. _escape_str(gname) .. "\",synergies={")
        local syn = g.synergies or {}
        for si, id in ipairs(syn) do
            table.insert(out, tostring(tonumber(id) or 0))
            if si < #syn then table.insert(out, ",") end
        end
        table.insert(out, "}}")
        if gi < #groups then table.insert(out, ",") end
    end

    table.insert(out, "}}")
    return table.concat(out)
end

-- Parst das Lua-Tabellenliteral sicher zurück in ein Table
local function _deserialize_preset_from_lua_table(luaText)
    -- Sicherheit: nur return <table>
    local chunk, err = zo_loadstring("return " .. luaText)
    if not chunk then
        return nil, "load:" .. tostring(err)
    end
    local ok, tbl = pcall(chunk)
    if not ok then
        return nil, "pcall:" .. tostring(tbl)
    end
    if type(tbl) ~= "table" then
        return nil, "not_a_table"
    end
    -- Minimal-Validierung
    if tbl.version ~= 1 then
        return nil, "bad_version"
    end
    if type(tbl.name) ~= "string" then
        return nil, "bad_name"
    end
    if type(tbl.groups) ~= "table" then
        return nil, "bad_groups"
    end
    -- Feldformen der Gruppen prüfen
    for i, g in ipairs(tbl.groups) do
        if type(g) ~= "table" then
            return nil, "group_not_table@" .. i
        end
        if type(g.name) ~= "string" then
            return nil, "group_bad_name@" .. i
        end
        if g.uid ~= nil and type(g.uid) ~= "number" then
            return nil, "group_bad_uid@" .. i
        end
        if type(g.synergies or {}) ~= "table" then
            return nil, "group_bad_synergies@" .. i
        end
        -- alle Synergy-IDs numerisch machen
        if g.synergies then
            for si, v in ipairs(g.synergies) do
                local n = tonumber(v)
                if not n then
                    return nil, "group_synergy_non_number@" .. i .. "/" .. si
                end
                g.synergies[si] = n
            end
        else
            g.synergies = {}
        end
    end
    return tbl
end

------------------------------------------------------------
-- Export: nutzt _serialize_preset_to_lua_table + base64enc
------------------------------------------------------------
function BSCAS:ExportPrioPreset(presetName)
    local preset = self.SV_acc and self.SV_acc.PRIO_PRESETS and self.SV_acc.PRIO_PRESETS[presetName]
    if not preset then
        CHAT_ROUTER:AddSystemMessage("|cFF0000Preset not found.|r")
        return
    end
    local luaLiteral = _serialize_preset_to_lua_table(presetName, preset)
    local encoded = base64enc(luaLiteral)
    return encoded
end

------------------------------------------------------------
-- Import: base64dec + _deserialize_preset_from_lua_table
-- Überschreibt das aktuell gewählte PRIO-Preset
------------------------------------------------------------
function BSCAS:ImportPrioPreset(encodedText)
    if not encodedText or encodedText == "" then
        CHAT_ROUTER:AddSystemMessage("|cFF0000[AdvancedSynergy]|r Invalid data.")
        return false
    end

    local decoded = base64dec(encodedText)
    if not decoded or decoded == "" then
        CHAT_ROUTER:AddSystemMessage("|cFF0000[AdvancedSynergy]|r Decode error.")
        return false
    end

    local data, perr = _deserialize_preset_from_lua_table(decoded)
    if not data then
        CHAT_ROUTER:AddSystemMessage("|cFF0000[AdvancedSynergy]|r Invalid preset data.")
        if perr then d("|c999999Decode error: " .. tostring(perr)) end
        return false
    end

    -- Ziel: aktuell ausgewähltes Preset überschreiben
    self.SV_acc = self.SV_acc or {}
    self.SV_acc.PRIO_PRESETS = self.SV_acc.PRIO_PRESETS or {}

    local targetName = self.SV and self.SV.SELECTED_PRIO_PRESET
    if not targetName or targetName == "" then
        -- Fallback: Name aus Import oder generierter Name
        targetName = data.name or ("Imported_" .. tostring(GetTimeStamp() % 1000000))
    end

    -- Nur die erwartete Struktur übernehmen (vollständiges Überschreiben)
    local imported = { groups = {} }
    for i, g in ipairs(data.groups or {}) do
        imported.groups[i] = {
            name = g.name or ("Group " .. i),
            uid = tonumber(g.uid or 0) or 0,
            synergies = ZO_DeepTableCopy(g.synergies or {}),
        }
    end

    -- Überschreiben
    self.SV_acc.PRIO_PRESETS[targetName] = imported
    -- UI aktualisieren & angewählte Auswahl beibehalten
    self:PrioUpdateCombobox()
    self:ApplyPrioPreset(targetName)

    CHAT_ROUTER:AddSystemMessage(zo_strformat("|c00FF00[AdvancedSynergy]|r Preset '<<1>>' was overwritten by imported data.", targetName))
    return true
end
