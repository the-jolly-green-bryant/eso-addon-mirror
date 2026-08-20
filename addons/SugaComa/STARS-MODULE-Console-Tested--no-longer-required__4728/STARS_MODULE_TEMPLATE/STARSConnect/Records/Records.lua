local Bootstrap = STARSModuleBootstrap
local Project = Bootstrap and Bootstrap.current
if not Project then error("STARSConnect: config.lua must load before Records.lua") end

Project.Records = Project.Records or {}
local Records = Project.Records

local function Store()
    if not Project.sv then return nil end
    Project.sv.data = Project.sv.data or {}
    Project.sv.data.records = Project.sv.data.records or {}
    return Project.sv.data.records
end

function Records:Add(record)
    if type(record) ~= "table" then return false end
    local records = Store()
    if not records then return false end

    table.insert(records, 1, record)

    local limit = tonumber(Project.Config.records and Project.Config.records.historyLimit) or 25
    while #records > math.max(1, limit) do
        table.remove(records)
    end

    Project:NotifyChanged()
    return true
end

function Records:GetAll()
    return Store() or {}
end

function Records:GetLatest()
    local records = Store()
    return records and records[1] or nil
end

function Records:Clear()
    local records = Store()
    if not records then return false end
    for index = #records, 1, -1 do records[index] = nil end
    Project:NotifyChanged()
    return true
end
