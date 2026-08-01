-- DDPositions_Utils.lua
DDPositions = DDPositions or {}
local DDP = DDPositions

function DDP.msg(text)
    d(string.format("::[DDPositions]:: %s", tostring(text)))
end

function DDP.NormalizeName(name)
    return name and zo_strformat("<<1>>", name) or nil
end

function DDP.PrintName(name)
    return (not name or name == "@Missing") and "@Missing" or name
end

function DDP.GetUnitTagByName(name)
    if not name then return nil end
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) then
            local unitName = zo_strformat("<<1>>", GetUnitDisplayName(unitTag))
            if unitName == name then
                return unitTag
            end
        end
    end
    return nil
end

function DDP.IsUnitDPS(unitTag)
    return GetGroupMemberAssignedRole(unitTag) == LFG_ROLE_DPS
end

function DDP.GetHealersInGroup()
    local healers = {}
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) and GetGroupMemberAssignedRole(unitTag) == LFG_ROLE_HEAL then
            local name = zo_strformat("<<1>>", GetUnitDisplayName(unitTag))
            table.insert(healers, name)
        end
    end
    return healers
end

function DDP.ShuffleTable(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

function DDP.UnignorePlayer(playerName)
    if not playerName or playerName == "" then return end
    local name = DDP.NormalizeName(playerName)
    if IsIgnored(name) then RemoveIgnore(name) else return end
end

SLASH_COMMANDS["/ddzone"] = function()
    if GetUnitDisplayName("player") ~= DDP.autor then return end
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local zoneName = GetZoneNameById(zoneId)
    d("|c88CCFFCurrent Zone:|r " .. zoneName .. " (ID: " .. zoneId .. ")")
end

SLASH_COMMANDS["/ddpmem"] = function()
	if GetUnitDisplayName("player") ~= DDP.autor then return end
    local kb = collectgarbage("count")
    local before = kb
    collectgarbage("collect")
    local after = collectgarbage("count")

    local diff = before - after
    d(string.format("|c88CCFF[DDPositions]|r Memory before GC: |cFFFFFF%.1f KB|r", before))
    d(string.format("|c88CCFF[DDPositions]|r Memory after GC:  |cFFFFFF%.1f KB|r", after))
    d(string.format("|c88CCFF[DDPositions]|r Reclaimed:        |c66FF66%.1f KB|r", diff))
end
