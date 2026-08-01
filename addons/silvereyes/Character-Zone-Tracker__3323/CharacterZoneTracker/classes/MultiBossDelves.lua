--[[ 
    ============================================
      Tracking for Delves with Multiple Bosses 
    ============================================
  ]]
  
local addon = CharacterZoneTracker
local debug = false
local _
local MULTIBOSS_DELVE_DATA

-- Singleton class
local MultiBossDelves = ZO_Object:Subclass()

function MultiBossDelves:New(...)
    local instance = ZO_Object.New(self)
    self.Initialize(instance, ...)
    return instance
end

function MultiBossDelves:Initialize()
    -- Load localized boss names
    MULTIBOSS_DELVE_DATA = CZT_MULTI_BOSS_DELVE_MONSTERS
    -- Clear the global variable
    CZT_MULTI_BOSS_DELVE_MONSTERS = nil
end

-- /script CharacterZoneTracker.MultiBossDelves:PrintArray()
function MultiBossDelves:PrintArray()
    local zoneIds = {}
    for zoneId, _ in pairs(MULTIBOSS_DELVE_DATA) do
        table.insert(zoneIds, zoneId)
    end
    table.sort(zoneIds)
    for _, zoneId in ipairs(zoneIds) do
        local zoneName = zo_strformat("<<1>>", GetZoneNameById(zoneId))
        local completionZoneId = GetZoneStoryZoneIdForZoneId(zoneId)
        local completionZoneName = zo_strformat("<<1>>", GetZoneNameById(completionZoneId))
        local localizedBossNames = {}
        for _, bossName in ipairs(self:GetBossList(zoneId)) do
            table.insert(localizedBossNames, LocalizeString("<<1>>", bossName))
        end
        d("\n	-- " .. tostring(zoneName) .. ", " .. tostring(completionZoneName))
        d("	[" .. tostring(zoneId) .. "] = {" .. '"' .. table.concat(localizedBossNames, '", "') .. '"' .. "},")
    end
end




---------------------------------------
--
--          Public Methods
-- 
---------------------------------------

function MultiBossDelves:AreAllBossesKilled(zoneId)
    local bossNames = self:GetBossList(zoneId)
    if not bossNames then
        return false
    end
    for bossIndex = 1, #bossNames do
        if not addon.Data:GetIsMultiBossDelveBossKilled(zoneId, bossIndex) then
            return false
        end
    end
    return true
end

function MultiBossDelves:IsZoneMultiBossDelve(zoneId)
    return MULTIBOSS_DELVE_DATA[zoneId] ~= nil
end

function MultiBossDelves:IsZoneMultiBoss(zoneId, targetName)
    return MULTIBOSS_DELVE_DATA[zoneId] and ZO_IsElementInNumericallyIndexedTable(MULTIBOSS_DELVE_DATA[zoneId], targetName) or false
end

function MultiBossDelves:GetBossList(zoneId)
    return MULTIBOSS_DELVE_DATA[zoneId]
end

function MultiBossDelves:GetNumBosses(zoneId)
    if not MULTIBOSS_DELVE_DATA[zoneId] then
        return 0
    end
    return #MULTIBOSS_DELVE_DATA[zoneId]
end

function MultiBossDelves:RegisterBossKill(zoneId, targetName)
    local bossNames = self:GetBossList(zoneId)
    if not bossNames then
        return
    end
    local bossIndex = ZO_IndexOfElementInNumericallyIndexedTable(bossNames, targetName)
    if not bossIndex then
        return
    end
    addon.Data:SetMultiBossDelveBossKilled(zoneId, bossIndex)
end



---------------------------------------
--
--          Private Members
-- 
---------------------------------------



-- Create singleton
addon.MultiBossDelves = MultiBossDelves:New()