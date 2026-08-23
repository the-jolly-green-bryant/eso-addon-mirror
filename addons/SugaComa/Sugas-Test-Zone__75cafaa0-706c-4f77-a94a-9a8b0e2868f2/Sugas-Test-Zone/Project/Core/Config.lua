SugasTestZoneProject = SugasTestZoneProject or {}
local Project = SugasTestZoneProject

Project.Config = {
    hostAddonName = "Sugas-Test-Zone",
    displayName = "Winter's Harvest",
    version = "0.3.3-test11",
    hostVersion = "0.3.2-test1",
    savedVariablesName = "SugasTestZoneProject_SV",
    savedVariablesVersion = 1,
    moduleId = "winters_harvest",

    countdownSeconds = 5,

    -- Foundation timing model.
    startingSeconds = 600,
    maxHarvestSeconds = 1200,
    gatherWindowSeconds = 45,
    missedGatherPenaltySeconds = 30,

    -- Fourth roulette balance pass. Every gathered node still rolls exactly one
    -- outcome. Direct +TIME is now exactly one roll in five (20%), matching the
    -- five farmable resource-node families used by the game concept. The removed
    -- 8% is moved to NOTHING so penalty/timed-effect frequencies stay unchanged.
    roulette = {
        addTimeWeight = 20,
        removeTimeWeight = 18,
        freezeWeight = 14,
        slowWeight = 14,
        speedWeight = 14,
        nothingWeight = 20,

        addTimeSeconds = { 30, 45 },
        removeTimeSeconds = { 10, 20, 30 },
        freezeSeconds = { 10, 15, 20 },
        slowSeconds = { 15, 20, 30 },
        speedSeconds = { 10, 15, 20 },
        slowRate = 0.5,
        speedRate = 2.0,
    },

    -- Tick is active only while a run/countdown is active. All timers are based
    -- on elapsed milliseconds, so the tick frequency affects display latency,
    -- not the actual amount of time gained or lost.
    updateIntervalMs = 250,

    -- A single resource node can generate several loot/inventory events. This
    -- window collapses them into one gathered node so later roulette logic gets
    -- exactly one spin per node.
    nodeDedupWindowMs = 900,
    harvestInteractionGraceMs = 2500,
    lootCorrelationWindowMs = 1800,
    duplicateInventoryWindowMs = 500,
}

Project.Defaults = {
    loaded = 0,
    settings = {
        diagnostics = false,
    },
    projectData = {
        gamesPlayed = 0,
        bestTimeMs = 0,
        totalNodes = 0,
        totalGatherPenalties = 0,
        -- Legacy counters are retained so existing test data is not destroyed.
        totalFlowers = 0,
        totalFungi = 0,
        lastRun = nil,
    },
}

function Project:NotifyChanged()
    if LibSTARSConnect and type(LibSTARSConnect.NotifyDataChanged) == "function" then
        LibSTARSConnect:NotifyDataChanged(self.Config.moduleId)
    end
end
