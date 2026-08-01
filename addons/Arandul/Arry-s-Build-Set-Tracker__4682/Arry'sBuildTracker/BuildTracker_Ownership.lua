-- BuildTracker_Ownership.lua
--
-- Answers "do I still need to go find this?" for a build's slots using
-- BuildTracker.Collections (ESO's Set Item Collection / Sticker Book)
-- instead of scanning bag/bank/craft bag contents. The collection is a
-- permanent unlock, so it stays accurate even after items are
-- deconstructed, sold, or traded - unlike a bag scan, which only reflects
-- what you happen to be holding right now.

BuildTracker = BuildTracker or {}
BuildTracker.Ownership = {}

local Ownership = BuildTracker.Ownership

-- Returns a table keyed by equipSlotId -> true/false/nil for every slot
-- assigned in the build, plus a collected count and total count (nil/
-- unknown slots count toward neither). nil specifically means "couldn't
-- determine" - most often a crafted set, which has no Collections entry
-- at all since it was never collected from the world.
function Ownership.GetBuildOwnershipStatus(buildId)
    local build = BuildTracker.Data.GetBuild(buildId)
    if not build then return {}, 0, 0 end

    local status = {}
    local collectedCount, totalCount = 0, 0

    for equipSlotId, slotData in pairs(build.slots) do
        totalCount = totalCount + 1
        local isCollected = BuildTracker.Collections.IsItemCollected(slotData.setId, slotData.itemId)
        status[equipSlotId] = isCollected
        if isCollected then
            collectedCount = collectedCount + 1
        end
    end

    return status, collectedCount, totalCount
end
