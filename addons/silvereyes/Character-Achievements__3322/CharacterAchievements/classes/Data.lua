local addon = CharacterAchievements
local class = addon.classes
local debug = false
local LAA = LibAchievementsArchive

local Data = ZO_Object:Subclass()

function Data:New(...)
    return ZO_Object.New(self)
end

function Data:Initialize()
    
    self.esoui = {}
    self.esouiNames = {
        GetCharIdForCompletedAchievement = "GetCharIdForCompletedAchievement",
        GetCriterion = "GetAchievementCriterion",
        GetInfo = "GetAchievementInfo",
        GetLink = "GetAchievementLink",
        GetPersistenceLevel = "GetAchievementPersistenceLevel",
        GetProgress = "GetAchievementProgress",
        GetTimestamp = "GetAchievementTimestamp",
        IsComplete = "IsAchievementComplete",
    }
    
    for handlerName, methodName in pairs(self.esouiNames) do
        local method = _G[methodName]
        if method then
            self.esoui[methodName] = method
            _G[methodName] = self:Closure(handlerName)
        end
    end
end



---------------------------------------
--
--          Public Methods
-- 
---------------------------------------

--[[  ]]
function Data:Closure(functionName)
    return function(...)
        return self[functionName](self, ...)
    end
end

--[[  ]]
function Data:GetCharIdForCompletedAchievement(achievementId)
    if LAA.ArchivedIsAchievementComplete(nil, achievementId) or not GetCharIdForCompletedAchievement then
        return StringToId64(GetCurrentCharacterId())
    end
    return self.esoui.GetCharIdForCompletedAchievement(achievementId)
end

--[[  ]]
function Data:GetCriterion(achievementId, criterionIndex)
    if LAA.ArchivedIsAchievementComplete(nil, achievementId) then
        -- Restore original ESO API for criterion to avoid infinite recursion
        local closure = GetAchievementCriterion
        GetAchievementCriterion = self.esoui.GetAchievementCriterion
        local returns = {LAA.ArchivedGetAchievementCriterion(nil, achievementId, criterionIndex)}
        -- Overwrite the ESO API for criterion again
        GetAchievementCriterion = closure
        return unpack(returns)
    end
    return self.esoui.GetAchievementCriterion(achievementId, criterionIndex)
end

--[[  ]]
function Data:GetInfo(achievementId)
    local name, description, points, icon, completed, date, time = self.esoui.GetAchievementInfo(achievementId)
    if LAA.ArchivedIsAchievementComplete(nil, achievementId) then
        local timestamp = LAA.ArchivedGetAchievementTimestamp(nil, achievementId)
        date, time = FormatAchievementLinkTimestamp(Id64ToString(timestamp))
        completed = true
    end
    return name, description, points, icon, completed, date, time
end

--[[  ]]
function Data:GetLink(achievementId, linkStyle)
    if LAA.ArchivedIsAchievementComplete(nil, achievementId) then
        return LAA.ArchivedGetAchievementLink(nil, achievementId, linkStyle)
    end
    return self.esoui.GetAchievementLink(achievementId, linkStyle)
end

--[[  ]]
function Data:GetPersistenceLevel(achievementId)
    if LAA.ArchivedIsAchievementComplete(nil, achievementId) or not ACHIEVEMENT_PERSISTENCE_CHARACTER then
        return ACHIEVEMENT_PERSISTENCE_CHARACTER
    end
    return self.esoui.GetAchievementPersistenceLevel(achievementId)
end

--[[  ]]
function Data:GetProgress(achievementId)
    if LAA.ArchivedIsAchievementComplete(nil, achievementId) then
        return LAA.ArchivedGetAchievementProgress(nil, achievementId)
    end
    return self.esoui.GetAchievementProgress(achievementId)
end

--[[  ]]
function Data:GetTimestamp(achievementId)
    if LAA.ArchivedIsAchievementComplete(nil, achievementId) then
        return LAA.ArchivedGetAchievementTimestamp(nil, achievementId)
    end
    return self.esoui.GetAchievementTimestamp(achievementId)
end

--[[  ]]
function Data:IsComplete(achievementId)
    if LAA.ArchivedIsAchievementComplete(nil, achievementId) then
        return true
    end
    return self.esoui.IsAchievementComplete(achievementId)
end

---------------------------------------
--
--          Private Members
-- 
---------------------------------------

-- Create singleton
addon.Data = Data:New()
