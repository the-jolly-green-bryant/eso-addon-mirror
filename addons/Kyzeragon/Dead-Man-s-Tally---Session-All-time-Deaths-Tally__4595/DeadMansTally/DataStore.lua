local DMT = DeadMansTally

---------------------------------------------------------------------
-- Chunks because strings can get too long for SVs
local function Chunk(str)
    local MAX_LEN = 1800
    if (string.len(str) <= MAX_LEN) then
        return str
    end

    local tab = {}
    local startIndex = 1
    while true do
        local endIndex = math.min(startIndex + MAX_LEN, string.len(str))
        table.insert(tab, string.sub(str, startIndex, endIndex))
        startIndex = endIndex + 1
        if (startIndex > string.len(str)) then
            break
        end
    end
    return tab
end

local function Unchunk(strOrTable)
    if (type(strOrTable) == "string") then
        return strOrTable
    elseif (type(strOrTable) == "table") then
        return table.concat(strOrTable, "")
    else
        return ""
    end
end


---------------------------------------------------------------------
-- Concats table to :; separated string
local function Concat(tab)
    local tempTable = {}
    for name, num in pairs(tab) do
        table.insert(tempTable, name .. ":" .. num)
    end
    return table.concat(tempTable, ";")
end

local function Split(str)
    local tab = {}
    for pair in string.gmatch(str, "([^;]+)") do
        local name, num
        for part in string.gmatch(pair, "([^:]+)") do
            if (not name) then
                name = part
            else
                num = part
            end
        end
        tab[name] = tonumber(num)
    end
    return tab
end
-- DMT.Split = Split


---------------------------------------------------------------------
--[[
["NA Megaserver"] = {
    ["@Kyzeragon"] = {
        show = true,
        x = 100,
        y = 100,
        includeInAll = true,
        foreverDeaths = {
            ungroupedplayer = "",
            group = "",
            companion = "",
            groupcompanion = "",
            playerpet = "",
            boss = "",
        },
        currentDeaths = {
            ungroupedplayer = "",
            group = "",
            playerpet = "",
            boss = "",
            companion = "",
            groupcompanion = "",
        },
    },
},
]]

local function SaveSubtable(from, to)
    for type, tab in pairs(from) do
        to[type] = Chunk(Concat(tab))
    end
end

-- Before logout, convert all tables back to string storage
-- The only data that should've gotten changed is current server + account
local function SaveCurrent()
    local accData = DMT.packedSVs[GetWorldName()][GetUnitDisplayName("player")]
    SaveSubtable(DMT.svs.foreverDeaths, accData.foreverDeaths)
    SaveSubtable(DMT.svs.currentDeaths, accData.currentDeaths)
end

---------------------------------------------------------------------
local function LoadSubtable(tab)
    local result = {}
    for type, str in pairs(tab) do
        result[type] = Split(Unchunk(str))
    end
    return result
end

local function LoadCurrent()
    local result = {}
    local accData = DMT.packedSVs[GetWorldName()][GetUnitDisplayName("player")]
    result.foreverDeaths = LoadSubtable(accData.foreverDeaths)
    result.currentDeaths = LoadSubtable(accData.currentDeaths)
    return result
end

---------------------------------------------------------------------
-- Lazy loading for other servers / accounts
local function LoadOthers()
    if (DMT.othersSVs) then return end

    DMT.othersSVs = {}
    for serverName, serverData in pairs(DMT.packedSVs) do
        DMT.othersSVs[serverName] = {}
        for accName, accData in pairs(serverData) do
            if (accData.includeInAll and (serverName ~= GetWorldName() or accName ~= GetUnitDisplayName("player"))) then -- Do not include current account's data, it's added separately
                DMT.othersSVs[serverName][accName] = {}
                DMT.othersSVs[serverName][accName].foreverDeaths = LoadSubtable(accData.foreverDeaths)
            end
        end
    end
end
DMT.LoadOthers = LoadOthers

function DMT.InitializeDataStore()
    ZO_PreHook("ReloadUI", SaveCurrent)
    ZO_PreHook("Logout", SaveCurrent)
    ZO_PreHook("SetCVar", SaveCurrent)
    ZO_PreHook("Quit", SaveCurrent)

    DMT.svs = LoadCurrent()
end
