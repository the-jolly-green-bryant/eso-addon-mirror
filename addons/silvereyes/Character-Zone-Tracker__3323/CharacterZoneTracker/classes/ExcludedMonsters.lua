--[[ 
    ===============================================================
      Helps identify difficult monster names that are not bosses.
    ===============================================================
  ]]
  
local addon = CharacterZoneTracker
local debug = false
local _
local EXCLUDED_MONSTER_NAMES

-- Singleton class
local ExcludedMonsters = ZO_Object:Subclass()

function ExcludedMonsters:New(...)
    local instance = ZO_Object.New(self)
    self.Initialize(instance, ...)
    return instance
end

function ExcludedMonsters:Initialize()
    if EXCLUDED_MONSTER_NAMES then
        return
    end
    -- Load localized monster names
    EXCLUDED_MONSTER_NAMES = {}
    for _, monsterName in ipairs(CZT_EXCLUDED_MONSTER_NAMES) do
        EXCLUDED_MONSTER_NAMES[monsterName] = true
    end
    -- Remove global variable scope
    CZT_EXCLUDED_MONSTER_NAMES = nil
end




---------------------------------------
--
--          Public Methods
-- 
---------------------------------------

function ExcludedMonsters:IsExcludedMonster(targetName)
    local monsterNames = EXCLUDED_MONSTER_NAMES
    targetName = zo_strlower(LocalizeString("<<1>>", targetName))
    return monsterNames[targetName] == true
end

function ExcludedMonsters:PrintEscapedArray()
    local monsterNames = EXCLUDED_MONSTER_NAMES
    local _
    for name, _ in pairs(monsterNames) do
        d('	"' .. zo_strlower(LocalizeString("<<1>>", name)) .. '",')
    end
end


---------------------------------------
--
--          Private Members
-- 
---------------------------------------




-- Create singleton
addon.ExcludedMonsters = ExcludedMonsters:New()