local SlashCommandHelper = ZO_Object:Subclass()
local DungeonTravel = DungeonTravel

function SlashCommandHelper:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function SlashCommandHelper:Initialize()
    self.resultList = {}    
    self.zoneLookup = {}    
    self.dirty = true

    local LSC = LibSlashCommander
    local this = self

    local DungeonTravelAutoCompleteProvider = LSC.AutoCompleteProvider:Subclass()
    function DungeonTravelAutoCompleteProvider:New()
        return LSC.AutoCompleteProvider.New(self)
    end

    function DungeonTravelAutoCompleteProvider:GetResultList()
        return this:AutoCompleteResultProvider()
    end

    function DungeonTravelAutoCompleteProvider:GetResultFromLabel(label)
        return this:AutoCompleteResultLookup(label)
    end

    local function SlashCommandCallback(input)
        return self:SlashCommandCallback(input)
    end
    self.autocompleteResultProvider = DungeonTravelAutoCompleteProvider

    self.command = LSC:Register({"/dungeon", "/dt"}, SlashCommandCallback, "Travel to the specified dungeon")
    self.command:SetAutoComplete(DungeonTravelAutoCompleteProvider:New())
end

function SlashCommandHelper:SlashCommandCallback(input, isTopResult)
    local zone = DungeonTravel:GetZoneFromPartialName(input)    
    if( zone ~= nil) then
        DungeonTravel:JumpTo(zone)
        return    
    elseif(not isTopResult) then
        local results = self.autocompleteResultProvider:GetResultList()
        local matches = GetTopMatchesByLevenshteinSubStringScore(results, input, 1, 1, true)

        if(#matches > 0) then
            local target = self.autocompleteResultProvider:GetResultFromLabel(matches[1])
            return self:SlashCommandCallback(target, true)
        end
    end

    d("Target cannot be reached via jump")
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
end

function SlashCommandHelper:GetZoneResults()
    local zoneList = {}
    local zones = DungeonTravel:GetZoneList()
    ZO_ClearTable(self.zoneLookup)

    for zoneName, zone in pairs(zones) do
        --local zoneIdx, poiIdx = GetFastTravelNodePOIIndicies(zone.id)
        --local zoneId = GetZoneId(zoneIdx)
        --local zoneMapName = GetZoneNameById(zoneId)        
        local count = 1
        local label = zo_strformat("<<1>>", zoneName, count)
        zoneList[zo_strlower(zoneName)] = label
        self.zoneLookup[label] = zoneName
    end

    return zoneList
end

function SlashCommandHelper:AutoCompleteResultProvider()
    if(self.dirty) then
        ZO_ClearTable(self.resultList)
        ZO_ShallowTableCopy(self:GetZoneResults(), self.resultList)   
        self.dirty = false
    end
    return self.resultList
end

function SlashCommandHelper:AutoCompleteResultLookup(label)
    return self.zoneLookup[label] or label
end

DungeonTravel.SlashCommandHelper = SlashCommandHelper:New()