Breadcrumbs = Breadcrumbs or {}

local lineStorage = {}
local oldPos = {nil, nil, nil}
Breadcrumbs.recording = false

local function ArePositionsEqual(pos1, pos2)
    if not pos1 or not pos2 then return false end
    return pos1[1] == pos2[1] and pos1[2] == pos2[2] and pos1[3] == pos2[3]
end

local function TakePositionSnapshot()
    local _, x, y, z = GetUnitRawWorldPosition("player")
    if not ArePositionsEqual(oldPos, {nil, nil, nil}) and not ArePositionsEqual(oldPos, {x, y, z}) then
        local line = Breadcrumbs.AddLineToPool(oldPos[1], oldPos[2], oldPos[3], x, y, z)
        table.insert(lineStorage, line)
    end
    oldPos = {x, y, z}
end

function Breadcrumbs.StartRecording() -- /script Breadcrumbs.StartRecording()
    Breadcrumbs.RefreshLines()
    lineStorage = {}
    oldPos = {nil, nil, nil}
    Breadcrumbs.recording = true
    EVENT_MANAGER:UnregisterForUpdate( Breadcrumbs.name .. "Record")
    EVENT_MANAGER:RegisterForUpdate( Breadcrumbs.name .. "Record", Breadcrumbs.sV.recording, TakePositionSnapshot )
end

function Breadcrumbs.StopRecording() -- /script Breadcrumbs.StopRecording()
    EVENT_MANAGER:UnregisterForUpdate( Breadcrumbs.name .. "Record")
    Breadcrumbs.recording = false
end

function Breadcrumbs.ToggleRecording()
    if Breadcrumbs.recording == true then 
        Breadcrumbs.StopRecording()
    else
        Breadcrumbs.StartRecording()
    end
end

function Breadcrumbs.SetRecordingSpeed(value)
    if value then
        Breadcrumbs.sV.recording = value
    end
end

function Breadcrumbs.DrawRecording() 
    if Breadcrumbs.recording == true then Breadcrumbs.StopRecording() end
    Breadcrumbs.InitialiseZone()
    local zoneId = Breadcrumbs.GetZoneId()
    for _, line in pairs(lineStorage) do
        if line then
            table.insert(Breadcrumbs.sV.savedLines[zoneId], line)
        end
    end
    Breadcrumbs.RefreshLines()
end