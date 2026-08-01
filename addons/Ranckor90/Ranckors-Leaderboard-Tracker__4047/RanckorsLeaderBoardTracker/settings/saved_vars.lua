RanckorsSavedVars = {}

local function GetDefaults()
    return {
        window = {
            x = 100,
            y = 100,
            w = 375,
            h = 220,
        },
    }
end

local function MigrateDefaultProfileToWorldForCurrentCharacter(savedVarsTableName, worldName)
    local svRoot = _G[savedVarsTableName]
    if type(svRoot) ~= "table" then return end

    local displayName = GetDisplayName()
    local characterName = GetUnitName("player")

    local defaultBucket = svRoot["Default"]
    if type(defaultBucket) ~= "table" then return end
    if type(defaultBucket[displayName]) ~= "table" then return end
    if type(defaultBucket[displayName][characterName]) ~= "table" then return end

    svRoot[worldName] = svRoot[worldName] or {}
    svRoot[worldName][displayName] = svRoot[worldName][displayName] or {}

    if type(svRoot[worldName][displayName][characterName]) ~= "table" then
        svRoot[worldName][displayName][characterName] = defaultBucket[displayName][characterName]
        defaultBucket[displayName][characterName] = nil
    end
end

function RanckorsSavedVars.Initialize()
    local worldName = GetWorldName()
    local defaults = GetDefaults()

    -- Move old data for THIS character out of ["Default"] into ["EU Megaserver"/"NA Megaserver"/"PTS"]
    MigrateDefaultProfileToWorldForCurrentCharacter("RanckorsLeaderBoardTrackerSavedVariables", worldName)

    RanckorsLeaderBoardTracker.savedVars = ZO_SavedVars:New(
        "RanckorsLeaderBoardTrackerSavedVariables",
        1,
        nil,
        defaults,
        worldName
    )

    d("|c00FF00Saved variables initialized (" .. worldName .. ").|r")
end