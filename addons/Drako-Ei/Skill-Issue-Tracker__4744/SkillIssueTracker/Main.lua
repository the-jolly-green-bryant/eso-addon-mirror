SkillIssueTracker = {
    name = "SkillIssueTracker",
    version = "1.0.0",
    author = "@Drako-Ei",
    command = "/skillissuetracker",
    description = "Automatically mark enemies in battlegrounds",
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
        version = "1.0.0",
        enabled = true,
        markerType = 8,
    }
}

local LAM = LibAddonMenu2
local SIT = SkillIssueTracker
local internal = SIT.internal



--  if GetUnitTargetMarkerType("reticleover") AssignTargetMarkerToReticleTarget(TargetMarkerType)	
-- IsActiveWorldBattleground()
-- GetCurrentBattlegroundRoundIndex() 1, 2, 3, 4




internal.initialize = function()
    SIT.savedVars = ZO_SavedVars:NewAccountWide(SIT.storageName, 1, nil, SIT.defaultVars)
    internal.focusing = false
end