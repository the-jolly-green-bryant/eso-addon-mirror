SkillIssueTracker = {
    name = "SkillIssueTracker",
    version = "1.0.3",
    author = "@Drako-Ei",
    command = "/skillissuetracker",
    description = "Identifies the weakest link in the enemy team in a battleground and marks them",
    internal = {},
    events = {},
    utils = {},
    target = {},
    selector = {},
    menu = {},
    storageName = "SkillIssueTrackerStorage",
    menuName = "SkillIssueTracker Settings",
    savedVars = {},
    defaultVars = {
        version = "1.0.3",
        enabled = true,
        markerType = 8,
        presets = {
            default = {
                lowLevel = 800,
                lowCP = 800,
                damageDone = 10,
                healingDone = 8,
                kills = 20,
                assists = 10,
                deaths = 100,
                almostDied = 200,
                permablockerPenalty = 80,
                shieldSpammerPenalty = 60,
                tankedDamagePenalty = 10,
                maxHealthPenalty = 100,
                ignoreIfUnseenFor = 30,
            }
        },
        usingPreset = "default"
    }
}

local LAM = LibAddonMenu2
local SIT = SkillIssueTracker
local internal = SIT.internal

internal.initialize = function()
    SIT.savedVars = ZO_SavedVars:NewAccountWide(SIT.storageName, 1, GetWorldName(), SIT.defaultVars)
    internal.focusing = false
end