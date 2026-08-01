DebuffTracker =
{
    name = "DebuffTracker",
    affectedUnits = {},
    debuffData = {},
    uiUnlocked = false,
    highlightedRows = {},
    needsSort = {},
    enemyDifficultyCache = {},
    currentZoneId = 0,
    effectFingerprintLookup = {},
    endTimeLookup = {},
    inCombat = false,
    rowPool = ZO_ControlPool:New("DebuffTracker_Row_Template", GuiRoot, "DebuffTracker_Row"),
    savedVars = {},
    Uptime = {}
}

GroupSetTracker = {}
