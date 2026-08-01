-- CharacterMarkdown - Armory Builds Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectArmoryBuildsData()
    -- Use API layer granular functions (composition at collector level)
    local unlocked = CM.api.armoryBuilds.GetNumUnlocked()

    local data = {}

    -- Transform API data to expected format (backward compatibility)
    data.unlocked = unlocked or 0
    data.builds = {}

    if data.unlocked > 0 then
        for buildIndex = 1, data.unlocked do
            local buildInfo = CM.api.armoryBuilds.GetBuildInfo(buildIndex)
            if buildInfo then
                table.insert(data.builds, buildInfo)
            end
        end

        -- Sort builds by name
        table.sort(data.builds, function(a, b)
            return (a.name or "") < (b.name or "")
        end)
    end

    -- Add computed summary
    data.summary = {
        totalBuilds = data.unlocked,
        maxBuilds = 10, -- Standard armory slot limit
        utilizationPercent = math.floor((data.unlocked / 10) * 100),
    }

    return data
end

CM.collectors.CollectArmoryBuildsData = CollectArmoryBuildsData

CM.DebugPrint("COLLECTOR", "ArmoryBuilds collector module loaded")
