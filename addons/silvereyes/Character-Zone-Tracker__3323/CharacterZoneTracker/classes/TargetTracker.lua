--[[ 
    ===================================
        Target Id and Name Tracking
    ===================================
    This class provides a buffer to remember monster target names for a given targetUnitId for a short duration, since
    sometimes during a kill event, the target name shows up as empty.
    I think this happens when someone else does the killing.
    Whenever a damage event occurs where we know the target name, the target name and id are added to this class, and the timestamp is recorded.
    A bit over half a minute after the monster stops receiving damage, it is removed from the tracker entirely.
    If it's not dead, it's either abandoned, or it can be tracked again the next time it gets damaged.
  ]]
  
local addon = CharacterZoneTracker
local debug = false
-- Note, this needs to be long enough for all dots to expire, 
-- but short enough to make sure we free up RAM frequently during large mob fights.
local CACHE_LIFETIME_MS = 37000 
local PURGE_OLD_TARGETS_NAME = addon.name .. "_TargetTracker_PurgeOldTargets"

-- Singleton class
local TargetTracker = ZO_Object:Subclass()

function TargetTracker:New()
    return ZO_Object.New(self)
end

function TargetTracker:Initialize()
    self.targetUnitNames = {}
    -- Tracks the last time a target was registered.
    self.targetsLastSeen = {}
    -- Register background task to keep old targets from filling up self.targetUnitNames indefinitely.
    EVENT_MANAGER:RegisterForUpdate(
        PURGE_OLD_TARGETS_NAME,
        CACHE_LIFETIME_MS,
        self:Closure("PurgeOldTargets")
    )
end




---------------------------------------
--
--          Public Methods
-- 
---------------------------------------

function TargetTracker:Closure(functionName)
    return function(...)
        return self[functionName](self, ...)
    end
end

function TargetTracker:GetTargetName(targetUnitId)
    if not targetUnitId or targetUnitId == 0 then
        return
    end
    return self.targetUnitNames[targetUnitId]
end

--[[
  Called on an interval to clear out old targets from the list of tracked targets.
]] -- 
function TargetTracker:PurgeOldTargets()
    local threshold = os.rawclock() - CACHE_LIFETIME_MS
    for targetUnitId, lastSeen in pairs(self.targetsLastSeen) do
        if lastSeen < threshold then
            self.targetUnitNames[targetUnitId] = nil
            self.targetsLastSeen[targetUnitId] = nil
        end
    end
end

function TargetTracker:RegisterTarget(targetUnitId, targetName)
    if not targetName or targetName == "" then
        -- Reset the clock on known target units, even when someone else damages them.
        if self.targetUnitNames[targetUnitId] then
            self.targetsLastSeen[targetUnitId] = os.rawclock()
        end
        return
    end
    targetName = zo_strformat("<<1>>", targetName)
    self.targetUnitNames[targetUnitId] = targetName
    self.targetsLastSeen[targetUnitId] = os.rawclock()
end

function TargetTracker:Reset()
    ZO_ClearTable(self.targetUnitNames)
    ZO_ClearTable(self.targetsLastSeen)
end

---------------------------------------
--
--          Private Methods
-- 
---------------------------------------




-- Create singleton
addon.TargetTracker = TargetTracker:New()