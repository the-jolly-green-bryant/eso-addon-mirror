AbilityIDToolkit = AbilityIDToolkit or {}
local AIT = AbilityIDToolkit

local function Lower(s)
    return zo_strlower(tostring(s or ""))
end

function AIT:InitializeDatabase()
    self.sv.known = self.sv.known or {}
    self.sv.sessions = self.sv.sessions or {}
end

function AIT:AddDiscovery(abilityId, data)
    if not abilityId or abilityId == 0 then return end
    local key = tostring(abilityId)
    local entry = self.sv.known[key] or { abilityId = abilityId, firstSeen = GetTimeStamp(), seen = 0 }
    entry.name = data.name or entry.name or (GetAbilityName and GetAbilityName(abilityId)) or ""
    entry.icon = data.icon or entry.icon or (GetAbilityIcon and GetAbilityIcon(abilityId)) or ""
    entry.category = data.category or entry.category or "DISCOVERED"
    entry.notes = data.notes or entry.notes or ""
    entry.lastSeen = GetTimeStamp()
    entry.seen = (entry.seen or 0) + 1
    entry.lastEvent = data.eventType or entry.lastEvent
    entry.lastDuration = data.duration or entry.lastDuration
    entry.lastSource = data.sourceName or entry.lastSource
    entry.lastTarget = data.targetName or entry.lastTarget
    self.sv.known[key] = entry
end

function AIT:GetKnownEntry(abilityId)
    abilityId = tonumber(abilityId)
    if not abilityId then return nil end
    local builtin = self.KnownIDs and self.KnownIDs[abilityId]
    local learned = self.sv and self.sv.known and self.sv.known[tostring(abilityId)]
    if not builtin and not learned then return nil end
    local out = {}
    if builtin then for k,v in pairs(builtin) do out[k] = v end end
    if learned then for k,v in pairs(learned) do out[k] = v end end
    out.abilityId = abilityId
    return out
end

function AIT:SearchKnown(query)
    query = tostring(query or "")
    local numeric = tonumber(query)
    local results = {}
    local seen = {}

    local function add(id, entry, origin)
        if seen[id] then return end
        seen[id] = true
        results[#results + 1] = {
            abilityId = id,
            name = entry.name or ((GetAbilityName and GetAbilityName(id)) or ""),
            category = entry.category or origin,
            notes = entry.notes or "",
            icon = entry.icon or ((GetAbilityIcon and GetAbilityIcon(id)) or ""),
            origin = origin,
            lastDuration = entry.lastDuration,
            lastSource = entry.lastSource,
            lastTarget = entry.lastTarget,
        }
    end

    if numeric then
        local e = self:GetKnownEntry(numeric)
        if e then add(numeric, e, self.KnownIDs[numeric] and "BUILT-IN" or "DISCOVERED") end
        if #results == 0 and GetAbilityName then
            local name = GetAbilityName(numeric)
            if name and name ~= "" then
                add(numeric, {name=name, category="ESO ABILITY", notes="Resolved directly through GetAbilityName()."}, "ESO")
            end
        end
        return results
    end

    local q = Lower(query)
    for id, entry in pairs(self.KnownIDs or {}) do
        if q == "" or string.find(Lower(entry.name), q, 1, true) or string.find(Lower(entry.notes), q, 1, true) then
            add(id, entry, "BUILT-IN")
        end
    end
    for key, entry in pairs((self.sv and self.sv.known) or {}) do
        local id = tonumber(key)
        if id and (q == "" or string.find(Lower(entry.name), q, 1, true) or string.find(Lower(entry.notes), q, 1, true)) then
            add(id, entry, "DISCOVERED")
        end
    end
    table.sort(results, function(a,b) return (a.abilityId or 0) < (b.abilityId or 0) end)
    return results
end
