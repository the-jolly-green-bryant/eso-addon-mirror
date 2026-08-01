--[[ 
    ============================================
      Tracking for boss fights
    ============================================
  ]]
  
local addon = CharacterZoneTracker
local debug = false

-- Singleton class
local BossFight = ZO_Object:Subclass()

function BossFight:New(...)
    local instance = ZO_Object.New(self)
    self.Initialize(instance, ...)
    return instance
end

function BossFight:Initialize()
    self.bossesKilled = {}
    self.bossUnitTags = {}
end




---------------------------------------
--
--          Public Methods
-- 
---------------------------------------

function BossFight:AreAllBossesKilled()
    local unitTag = next(self.bossUnitTags)
    if not unitTag then
        return false
    end
    repeat
        if not self.bossesKilled[unitTag] then
            return false
        end
        unitTag = next(self.bossUnitTags, unitTag)
    until not unitTag 
    addon.Utility.Debug("All bosses in fight are killed!", debug)
    return true
end

function BossFight:IsActive()
    local unitTag = next(self.bossUnitTags)
    return unitTag and true or false
end

function BossFight:RegisterKill(unitTag)
    if not self.bossUnitTags[unitTag] then
        return
    end
    self.bossesKilled[unitTag] = true
    return true
end

function BossFight:Reset()
    ZO_ClearTable(self.bossesKilled)
    ZO_ClearTable(self.bossUnitTags)
    addon.Utility.Debug("Reset boss fight.", debug)
end

function BossFight:UpdateBossList()
    local newBossUnitTags = {}
    local reset
    local bossUnitTagArray = {}
    for bossIndex = 1, MAX_BOSSES do
        local unitTag = "boss" .. tostring(bossIndex)
        local unitType = GetUnitType(unitTag)
        if unitType ~= COMBAT_UNIT_TYPE_NONE then
            bossUnitTagArray[bossIndex] = unitTag
            newBossUnitTags[unitTag] = true
            if not self.bossUnitTags[unitTag] then
                addon.Utility.Debug("Did not find boss unit " .. tostring(unitTag) .. " in boss unit tags list.", debug)
                reset = true
            end
        elseif self.bossUnitTags[unitTag] and not self.bossesKilled[unitTag] then
            addon.Utility.Debug("Boss unit " .. tostring(unitTag) .. " disappeared without dying.", debug)
            reset = true
        end
    end
    if reset then
        self:Reset()
        addon.Utility.Debug("New bosses set: " .. table.concat(bossUnitTagArray, ", "), debug)
        self.bossUnitTags = newBossUnitTags
    end
    return reset
end


---------------------------------------
--
--          Private Members
-- 
---------------------------------------



-- Create singleton
addon.BossFight = BossFight:New()