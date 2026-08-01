local SRC = SupportRotationCallouts
SRC.EffectUtilities = SRC.EffectUtilities or {}
local U = SRC.EffectUtilities

function U:Now()
    return GetGameTimeSeconds()
end

function U:NormalizeKey(value)
    if value == nil then return nil end
    local key = tostring(value)
    if key == "" then return nil end
    return zo_strupper(key)
end

function U:NormalizeUnitId(unitId)
    if unitId == nil or unitId == 0 or unitId == "" then return "global" end
    return tostring(unitId)
end

function U:CopyTable(source)
    local copy = {}
    for key, value in pairs(source or {}) do copy[key] = value end
    return copy
end

function U:IsExpired(data, now)
    if not data or not data.endTime or data.endTime <= 0 then return false end
    return (now or self:Now()) > data.endTime + 0.25
end


function U:GetGroupAccounts()
    local accounts = {}
    local seen = {}
    local groupSize = tonumber(GetGroupSize()) or 0

    if groupSize > 0 then
        for index = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(index)
            if unitTag and unitTag ~= "" and DoesUnitExist(unitTag) then
                local account = SRC:NormalizeAccountName(GetUnitDisplayName(unitTag) or "")
                if account ~= "" and not seen[account] then
                    seen[account] = true
                    accounts[#accounts + 1] = account
                end
            end
        end
    else
        local account = SRC:NormalizeAccountName(GetDisplayName() or "")
        if account ~= "" then accounts[1] = account end
    end

    table.sort(accounts)
    return accounts
end

function U:GetCoverageSnapshot(activeEntries, now)
    now = now or self:Now()
    local groupAccounts = self:GetGroupAccounts()
    local target = math.max(1, tonumber(GetGroupSize()) or 0, #groupAccounts)
    local activeAccounts = {}
    local covered = 0
    local maxEnd = 0
    local maxDuration = 0

    for key, data in pairs(activeEntries or {}) do
        local endTime = type(data) == "table" and tonumber(data.endTime) or tonumber(data)
        if endTime and endTime > now then
            covered = covered + 1
            if endTime > maxEnd then
                maxEnd = endTime
                if type(data) == "table" then maxDuration = tonumber(data.duration) or 0 end
            end
            local account = type(data) == "table" and data.account or nil
            account = SRC:NormalizeAccountName(account or (type(key) == "string" and string.sub(key, 1, 1) == "@" and key or ""))
            if account ~= "" then activeAccounts[account] = true end
        end
    end

    covered = math.min(covered, target)
    local missing = {}
    for _, account in ipairs(groupAccounts) do
        if not activeAccounts[account] then missing[#missing + 1] = account end
    end

    local expectedMissing = math.max(0, target - covered)
    while #missing > expectedMissing do table.remove(missing) end

    return {
        covered = covered,
        target = target,
        missingPlayers = missing,
        maxEnd = maxEnd,
        maxDuration = maxDuration,
        remaining = math.max(0, maxEnd - now),
    }
end
