local addon = CharacterZoneTracker
local debug = false
local _

local SubzoneMap = ZO_Object:Subclass()

function SubzoneMap:New(...)
    return ZO_Object.New(self)
end

function SubzoneMap:Initialize()
    self.subzoneIds = {}
    self.subzoneIdsByMapCompletionZoneId = {}
    for zoneIndex = 1, 10000000 do
        local zoneId = GetZoneId(zoneIndex)
        if zoneId == 0 then
            return
        end
        local mapCompletionZoneId = GetZoneStoryZoneIdForZoneId(zoneId)
        if mapCompletionZoneId > 0 and mapCompletionZoneId ~= zoneId then
            self.subzoneIds[zoneId] = true
            if not self.subzoneIdsByMapCompletionZoneId[mapCompletionZoneId] then
                self.subzoneIdsByMapCompletionZoneId[mapCompletionZoneId] = {}
            end
            table.insert(self.subzoneIdsByMapCompletionZoneId[mapCompletionZoneId], zoneId)
        end
    end
end



---------------------------------------
--
--          Public Methods
-- 
---------------------------------------

--[[  ]]--
function SubzoneMap:FindBestSubzoneNameMatch(zoneId, name)
    local subzoneIds = self.subzoneIdsByMapCompletionZoneId[zoneId]
    if not subzoneIds or not name or name == "" then
        return
    end
    local nameLower = zo_strlower(name)
    local halfSearchStringLength = math.ceil(ZoUTF8StringLength(nameLower)/2)
    local maxEditDistance = math.min(addon.ZoneGuideTracker:GetMaxEditDistance(), halfSearchStringLength)
    local lowestEditDistance = maxEditDistance + 1
    local match
    for _, subzoneId in ipairs(subzoneIds) do
        local subzoneNameLower = zo_strlower(zo_strformat("<<1>>", GetZoneNameById(subzoneId)))
        local editDistance = addon.Utility.EditDistance(subzoneNameLower, nameLower, lowestEditDistance)
        if editDistance < lowestEditDistance then
            match = subzoneId
            lowestEditDistance = editDistance
        end
    end
    return match, lowestEditDistance
end

--[[  ]]--
function SubzoneMap:GetSubzoneIds(zoneId)
    return self.subzoneIdsByMapCompletionZoneId[zoneId]
end

--[[  ]]--
function SubzoneMap:IsSubzone(zoneId)
    return self.subzoneIds[zoneId]
end

---------------------------------------
--
--          Private Members
-- 
---------------------------------------




-- Create singleton
addon.SubzoneMap = SubzoneMap:New()