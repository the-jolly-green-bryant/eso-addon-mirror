local CAE = CrutchAlertsExtensions
local Crutch = CrutchAlerts


---------------------------------------------------------------------
-- Profile data
---------------------------------------------------------------------
function CAE.AddLineToProfile(player1, player2, color, showDistance)
    local profile = CAE.profiles[CAE.csvs.currentProfile]

    local index = CAE.FindFreeId(profile.lines)
    profile.lines[index] = {
        player1 = player1,
        player2 = player2,
        color = color,
        showDistance = showDistance,
    }

    CAE.msg(zo_strformat("Added line between <<1>> and <<2>> to profile <<3>>", player1, player2, profile.profileName))

    return index
end

function CAE.RemoveLineFromProfile(index)
    local profile = CAE.profiles[CAE.csvs.currentProfile]
    CAE.msg(zo_strformat("Removing circle of radius <<1>> from profile <<2>>", profile.circles[index].radius, profile.profileName))
    profile.circles[index] = nil
end


---------------------------------------------------------------------
-- Loading / Drawing
---------------------------------------------------------------------
local activeLines = {}

-- Gets the unit tag for account name in group, or player if name is nil
local function GetUnitTagForName(name)
    if (name == nil or name == "") then return "player" end

    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if (tag and IsUnitOnline(tag) and GetUnitDisplayName(tag) == name) then
            return tag
        end
    end

    return nil
end

local function UpdateLines()
    local profile = CAE.profiles[CAE.csvs.currentProfile]

    for id, lineData in pairs(profile.lines) do
        local tag1 = GetUnitTagForName(lineData.player1)
        local tag2 = GetUnitTagForName(lineData.player2)
        if (tag1 and tag2 and tag1 ~= tag2 and GetUnitZoneIndex(tag1) == GetUnitZoneIndex(tag2)) then
            local lineNum = "CAELine" .. id
            local color = lineData.color
            Crutch.DrawLineBetweenPlayers(tag1, tag2, nil, lineNum)
            Crutch.SetLineColor(color[1], color[2], color[3], color[4], color[4], lineData.showDistance, lineNum)
            table.insert(activeLines, lineNum)
        end
    end
end

local function CleanLines()
    for _, lineNum in ipairs(activeLines) do
        Crutch.RemoveLine(lineNum)
    end
    ZO_ClearTable(activeLines)
end

local function LoadCurrentLines()
    CleanLines()
    UpdateLines()
end
CAE.LoadCurrentLines = LoadCurrentLines


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local function RefreshGroupTimeout()
    EVENT_MANAGER:RegisterForUpdate(CAE.name .. "LinesGroupRefreshTimeout", 1000, function()
        EVENT_MANAGER:UnregisterForUpdate(CAE.name .. "LinesGroupRefreshTimeout")
        LoadCurrentLines()
    end)
end


function CAE.InitializeLines()
    LoadCurrentLines()

    EVENT_MANAGER:RegisterForEvent(CAE.name .. "LinesPlayerActivated", EVENT_PLAYER_ACTIVATED, RefreshGroupTimeout)

    -- Group changes
    EVENT_MANAGER:RegisterForEvent(CAE.name .. "LinesGroupJoined", EVENT_GROUP_MEMBER_JOINED, RefreshGroupTimeout)
    EVENT_MANAGER:RegisterForEvent(CAE.name .. "LinesGroupLeft", EVENT_GROUP_MEMBER_LEFT, RefreshGroupTimeout)
    EVENT_MANAGER:RegisterForEvent(CAE.name .. "LinesGroupUpdate", EVENT_GROUP_UPDATE, RefreshGroupTimeout)
    EVENT_MANAGER:RegisterForEvent(CAE.name .. "LinesGroupConnectedStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS, RefreshGroupTimeout)
end
