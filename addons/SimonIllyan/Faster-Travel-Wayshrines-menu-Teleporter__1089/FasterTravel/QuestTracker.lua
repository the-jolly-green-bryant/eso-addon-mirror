local QuestTracker = FasterTravel.class()

FasterTravel.QuestTracker = QuestTracker

local Location = FasterTravel.Location
local Wayshrine = FasterTravel.Wayshrine
local Transitus = FasterTravel.Transitus
local Campaign = FasterTravel.Campaign
local Quest = FasterTravel.Quest
local WorldMap = FasterTravel.WorldMap
local Utils = FasterTravel.Utils

local GetPinTypeIconPath = WorldMap.GetPinTypeIconPath
local GetQuestIconPath = WorldMap.GetQuestIconPath
local ConvertQuestPinType = WorldMap.ConvertQuestPinType
local GetPinTexture = WorldMap.GetPinTexture

local _questIcon = {
    size = { width = 27, height = 26 },
    offset = { x = -6, y = -4 }
}

local _keepIcon = {
    size = { width = 38, height = 38 },
    offset = { x = -10, y = -8 }
}

local _campaignIcon = {
    size = { width = 30, height = 30 },
    offset = { x = -6, y = -4 }
}

local _keepAttackIcon = {
    size = { width = 30, height = 30 },
    offset = { x = -6, y = -4 }
}

local _categoryIcon = {
    size = { width = 29, height = 29 },
    offset = { x = -6, y = -4 }
}


local function ClearRowIcons(row)
    if row == nil then return end
    if type(row) == "table" then
        local data = row.data
        if data ~= nil then
            data.icon = nil
            data.quests = nil
        end
    end
end

local function ClearNodeIndexIcons(nodeIndex, lookups)
    for i, lookup in ipairs(lookups) do
        ClearRowIcons(lookup[nodeIndex])
    end
end

local function ClearIcons(lookup, ...)
    if lookup == nil then return end -- no args :/

    local count = select('#', ...)

    local lookups = count > 0 and { ... }

    for nodeIndex, row in pairs(lookup) do

        ClearRowIcons(row)

        if lookups ~= nil then
            ClearNodeIndexIcons(nodeIndex, lookups)
        end
    end
end

local function AddQuest(data, result, iconWidth, iconHeight)

    local questIndex, stepIndex, conditionIndex, assisted, zoneIndex = result.questIndex, result.stepIndex, result.conditionIndex, result.assisted, result.zoneIndex

    if data.quests == nil then
        data.quests = {}
    end

    local questInfo = data.quests[questIndex]

    if questInfo == nil then
        local name = GetJournalQuestInfo(questIndex)
        name = Utils.FormatStringCurrentLanguage(name)
        questInfo = {
            index = questIndex,
            steps = {},
            name = name,
            assisted = assisted,
            zoneIndex = zoneIndex,
            setAssisted = function(self, value)
                self.path = nil
                self.assisted = value
                for stepIndex, step in pairs(self.steps) do
                    for conditionIndex, condition in pairs(step.conditions) do
                        condition:setAssisted(value)
                        if self.path == nil then
                            self.path = condition.path
                        end
                    end
                end
            end
        }
        data.quests[questIndex] = questInfo
    end

    local stepInfo = questInfo.steps[stepIndex]

    if stepInfo == nil then
        stepInfo = { index = stepIndex, conditions = {} }
        questInfo.steps[stepIndex] = stepInfo
    end

    if stepInfo.conditions[conditionIndex] == nil then

        local text = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex)
        if text then
            -- Safe add of condition info to avoid npe issue for quests without condition info.
            local iconPath, pinType, textures = GetQuestIconPath(result)

            local condition = {
                text = "",
                setAssisted = function(self, assisted)
                    local path = GetPinTypeIconPath(textures, ConvertQuestPinType(pinType, assisted))
                    if path == nil then 
                        -- d(string.format("WARN: Icon path empty for quest pin type [%d] and assisted [%s] with text:\n%s", pinType, tostring(assisted), text))
						path = GetPinTypeIconPath(textures, MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION)
					end
					self.path = path
                    self.text = zo_iconTextFormat(path, iconWidth, iconHeight, text)
                end
            }
            condition:setAssisted(result.assisted)
            stepInfo.conditions[conditionIndex] = condition
        end
    end
end

local function SetIcon(data, path, args)
    if data == nil then return false end

    args = args or {}

    local icon = data.icon

    if icon == nil then
        icon = {}
        data.icon = icon
    end

    local hidden = args.hidden or (path == nil or path == "")

    icon.path = path

    icon.hidden = hidden

    Utils.extend(args, icon)

    return true, icon
end

local function SetQuestIcon(data, closest, result)

    if data == nil or closest == nil or result == nil then return false end

    if (data.icon == nil or data.icon.hidden == true) or result.assisted == true then

        local iconPath, pinType, textures = GetQuestIconPath(result)

        data.setAssisted = data.setAssisted or function(self, questIndex)
            if self.quests == nil then return end

            for idx, q in pairs(self.quests) do
                if q.setAssisted ~= nil then
                    q:setAssisted(idx == questIndex)
                end
            end

            if self.icon ~= nil then
                local quest = self.quests[questIndex]

                if data.underAttack == true then return false end -- ensure underAttack takes precedence

                if quest ~= nil then
                    self.icon.path = quest.path
                else
                    self.icon.path = GetPinTypeIconPath(textures, ConvertQuestPinType(pinType, false))
                end
            end
        end

        return SetIcon(data, iconPath, _questIcon)
    end

    return false
end

local function SetKeepIcon(data)
    if data.isTransitus ~= true or data.pinType == nil then return end
    local iconPath = GetPinTexture(data.pinType)
    local icon = _keepIcon

    if data.underAttack == true then
        icon = _keepAttackIcon
    end

    return SetIcon(data, iconPath, icon)
end

local function UpdateLookups(nodeIndex, func, ...)

    local count = select('#', ...)
    local set = false
    local lookup

    local row, data

    for i = 1, count do
        lookup = select(i, ...)
		if lookup ~= nil then
			row = lookup[nodeIndex]

			if row ~= nil then

				data = row.data

				set = func(data) or set
			end
		end
    end
    return set
end

local function IsValidResult(result)
    if result == nil then return false end
    return result.hasPosition == true and result.insideBounds == true
end

local function RefreshCategories(categories, locations, locationsLookup, quests, categoriesTable)
	if categories == nil or locations == nil or locationsLookup == nil or quests == nil or categoriesTable == nil then return end

    local counts = {}

    local data, path

    local zIdx

    -- recent icon
    SetIcon(categoriesTable[1], "/esoui/art/icons/poi/poi_wayshrine_complete.dds", _categoryIcon)
    -- favourites icon
    SetIcon(categoriesTable[2], "/esoui/art/icons/poi/poi_wayshrine_complete.dds", _categoryIcon)
     -- ALL icon
    SetIcon(categoriesTable[4], "/esoui/art/icons/poi/poi_wayshrine_complete.dds", _categoryIcon)
	-- Dungeons icon
    SetIcon(categoriesTable[5], "/esoui/art/icons/poi/poi_wayshrine_complete.dds", _categoryIcon)
   
	-- set icons
    for i, entry in pairs(categoriesTable) do
        zIdx = entry.zoneIndex or entry.curZoneIndex
        if zIdx ~= nil then
            path = Location.Data.GetZoneFactionIcon(locationsLookup[zIdx])
            SetIcon(entry, path, _categoryIcon)
        end
    end

    -- reset names
    for i, loc in pairs(locations) do
        data = categories[loc.zoneIndex]
        if data ~= nil then
            data.name = loc.name
        end
    end

    -- count quests
    for i, quest in pairs(quests) do
        counts[quest.zoneIndex] = (counts[quest.zoneIndex] or 0) + 1
    end

    -- append counts
    local c, l
    for zoneIndex, count in pairs(counts) do
        c = categories[zoneIndex]
        if c ~= nil then
            l = locationsLookup[zoneIndex]
            if l ~= nil then -- really shouldn't ever be nil
                c.name = string.format("%s (%s)", l.name, count)
--[[                c.name = FasterTravel.settings.verbosity < 3 and
                    string.format("%s (%s)", l.name, count) or
                    string.format("%s (%s) |cffff00%s|r", l.name, count, #c.data)) 
]]--
            end
        end
    end
end

local function ClearQuestIcons(currentZoneIndex, loc, curLookup, zoneLookup, recLookup, faveLookup)

    if currentZoneIndex == nil or loc == nil or curLookup == nil or zoneLookup == nil then return end

    if loc.zoneIndex == currentZoneIndex then
        ClearIcons(curLookup, recLookup, faveLookup)
    end

    local lookup = zoneLookup[loc.zoneIndex]

    if lookup == nil then return end

    ClearIcons(lookup, recLookup, faveLookup)
end

local function IsQuestValidForZone(quest, loc)
    local zoneIndex, questType = quest.zoneIndex, quest.questType
    return zoneIndex == loc.zoneIndex or (questType == QUEST_TYPE_MAIN_STORY or questType == QUEST_TYPE_CRAFTING)
end

local function RefreshQuests(loc, tab, curLookup, zoneLookup, quests, wayshrines, recLookup, faveLookup)

    if loc == nil or tab == nil or curLookup == nil or zoneLookup == nil or quests == nil or wayshrines == nil then return end

    for i, quest in ipairs(quests) do
        -- always request where zoneIndex is nil
        if IsQuestValidForZone(quest, loc, zoneLookup) == true then
            Quest.GetQuestLocations(quest.index, function(result)

                if IsValidResult(result) == true then

                    local closest

                    if result.insideCurrentMapWorld == true then
                        closest = Location.GetClosestLocation(result.normalizedX, result.normalizedY, wayshrines)
                    end

                    if closest ~= nil then

                        result.zoneIndex = result.zoneIndex or closest.zoneIndex

                        local updateFunc = function(data)
                            AddQuest(data, result, _questIcon.size.width, _questIcon.size.height)
                            return SetQuestIcon(data, closest, result)
                        end

                        if UpdateLookups(closest.nodeIndex, updateFunc, curLookup, zoneLookup[closest.zoneIndex], recLookup, faveLookup) == true then
                            tab:RefreshControl()
                        end
                    end
                end
            end)
        end
    end
end

local function ShowQuestMenu(owner, data, func)
    ClearMenu()

    if data == nil or data.quests == nil or data.quests.table == nil then return end

    local name
    local quest

    local quests = data.quests.table

    local count = #quests

    if count == 1 then
        func(quests[1])
    elseif count > 1 then

        for i, quest in ipairs(quests) do
            name = quest.name

            if quest.assisted == false then
                AddMenuItem(name, function()
                    func(quest)
                    ClearMenu()
                end)
            end
        end

        ShowMenu(owner)
    end
end

local function SetAssistedInLookup(questIndex, lookup)
    for k, row in pairs(lookup) do
        if type(row) == "table" then
            if row.data ~= nil and row.data.setAssisted ~= nil then
                row.data:setAssisted(questIndex)
            end
        end
    end
end

local function SetAssisted(questIndex, curLookup, recLookup, zoneLookup)
    QUEST_TRACKER:ForceAssist(questIndex)
    SetAssistedInLookup(questIndex, curLookup)
    SetAssistedInLookup(questIndex, recLookup)
    if zoneLookup ~= nil then
        for zoneIndex, lookup in pairs(zoneLookup) do
            SetAssistedInLookup(questIndex, lookup)
        end
    end
end

local function RefreshKeepIcons(wayshrines, ...)

    for i, node in ipairs(wayshrines) do

        UpdateLookups(node.nodeIndex, SetKeepIcon, ...)
    end
end

local function SetCampaignIcon(data)
    if data.isCampaign ~= true then return end

    local id = data.nodeIndex

    if Campaign.IsPlayerQueued(id) == true then

        if Campaign.IsQueueState(id, CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING) == true then
            return SetIcon(data, Campaign.GetIcon(Campaign.ICON_ID_READY), _campaignIcon)
        else
            return SetIcon(data, Campaign.GetIcon(Campaign.ICON_ID_JOINING), _campaignIcon)
        end

    elseif data.home == true then
        return SetIcon(data, Campaign.GetIcon(Campaign.ICON_ID_HOME), _campaignIcon)
    elseif data.guest == true then
        return SetIcon(data, Campaign.GetIcon(Campaign.ICON_ID_GUEST), _campaignIcon)
    end

    return false
end

local function RefreshCampaignIcons(wayshrines, ...)

    for i, node in ipairs(wayshrines) do

        UpdateLookups(node.nodeIndex, SetCampaignIcon, ...)
    end
end

local CALLBACK_ID_ON_WORLDMAP_CHANGED = "OnWorldMapChanged"

local addCallback = FasterTravel.addCallback
local removeCallback = FasterTravel.removeCallback

function QuestTracker:init(locations, locationsLookup, tab)

    local _locations = locations
    local _locationsLookup = locationsLookup
    local _tab = tab

    local _refreshing = false

    local _isDirty = true

    local wayshrineTooltip = FasterTravel.WayshrineTooltip(tab, InformationTooltip, WorldMap.GetKeepTooltip())

    local function GetWayshrinesData(isRecall, isKeep, inCyrodiil, loc)
        if loc == nil then return {} end

        local zoneIndex = loc.zoneIndex

        local locIsCyrodiil = Location.Data.IsCyrodiil(loc)

        if inCyrodiil == true and (isRecall == true or isKeep == true) and locIsCyrodiil == true then
            return Transitus.GetKnownNodes(), 1
        elseif inCyrodiil == false and locIsCyrodiil == false then
            return Utils.toTable(Wayshrine.GetKnownWayshrinesByZoneIndex(zoneIndex)), false
        elseif inCyrodiil == false and locIsCyrodiil == true then
            return Campaign.GetPlayerCampaigns(), 2
        else
            return {}
        end

        return wayshrines
    end

    self.SetDirty = function(self)
        _isDirty = true
    end

    self.Refresh = function(self)
        if _refreshing == true then return end

        local lookups = _tab:GetRowLookups()

        local currentZoneIndex = _tab:GetCurrentZoneMapIndexes()

        local loc = Location.Data.GetZoneLocation(_locationsLookup)

        local curLookup, zoneLookup, recLookup, faveLookup = lookups.current, lookups.zone, lookups.recent, lookups.favourites

        self:HideToolTip()

        ClearQuestIcons(currentZoneIndex, loc, curLookup, zoneLookup, recLookup, faveLookup)

        local quests = Quest.GetQuests()

        RefreshCategories(lookups.categories, _locations, _locationsLookup, quests, lookups.categoriesTable)

        _tab:RefreshControl(lookups.categoriesTable)

        local wayshrines, dataType = GetWayshrinesData(_tab:IsRecall(), _tab:IsKeep(), _tab:InCyrodiil(), loc)

        if dataType ~= 2 then -- don't refresh quests for campaigns
        RefreshQuests(loc, _tab, curLookup, zoneLookup, quests, wayshrines, recLookup, faveLookup)
        end

        if dataType ~= false then

            if dataType == 1 then
                RefreshKeepIcons(wayshrines, curLookup, zoneLookup[loc.zoneIndex])
            elseif dataType == 2 then
                RefreshCampaignIcons(wayshrines, curLookup, zoneLookup[loc.zoneIndex])
            end

            _tab:RefreshControl()
        end
        _refreshing = false
    end

    self.RefreshIfRequired = function(self, ...)
        if _refreshing == true or _isDirty == false then return end
        self:Refresh(...)
        _isDirty = false
    end

    self.HideToolTip = function(self)

        wayshrineTooltip:Hide()
    end

    tab.IconMouseEnter = FasterTravel.hook(tab.IconMouseEnter, function(base, control, icon, data)

        base(control, icon, data)

        wayshrineTooltip:Show(icon, data)
    end)

    tab.IconMouseExit = FasterTravel.hook(tab.IconMouseExit, function(base, control, icon, data)

        base(control, icon, data)

        wayshrineTooltip:Hide()
    end)

    tab.IconMouseClicked = FasterTravel.hook(tab.IconMouseClicked, function(base, control, icon, data)
        base(control, icon, data)
        ShowQuestMenu(control, data, function(quest)

            local loc = _locationsLookup[data.zoneIndex]

            if loc == nil then
                loc = _locationsLookup[quest.zoneIndex]
            end

            local mapIndex = loc.mapIndex

            local questIndex = quest.index
            local lookups = _tab:GetRowLookups()

            local curLookup, zoneLookup, recLookup = lookups.current, lookups.zone, lookups.recent

            _refreshing = true

            SetAssisted(questIndex, curLookup, recLookup, zoneLookup)

            data:setAssisted(questIndex)

            _tab:RefreshControl()

            _refreshing = false

            if mapIndex ~= GetCurrentMapIndex() then
                ZO_WorldMap_SetMapByIndex(mapIndex)
            end
        end)
    end)

    tab.RowMouseEnter = FasterTravel.hook(tab.RowMouseEnter, function(base, control, row, label, data)
        base(control, row, label, data)

        wayshrineTooltip:Show(row.icon, data)
    end)

    tab.RowMouseExit = FasterTravel.hook(tab.RowMouseExit, function(base, control, row, label, data)
        base(control, row, label, data)

        self:HideToolTip()
    end)

    tab.RowMouseClicked = FasterTravel.hook(tab.RowMouseClicked, function(base, control, row, data)
        base(control, row, data)

        local nodeIndex = data.nodeIndex
        local isTransitus = data.isTransitus
        if nodeIndex == nil then return end

        local loc = _locationsLookup[data.zoneIndex]

        if loc ~= nil then
            WorldMap.PanToPoint(loc.mapIndex, function()
                local x, y
                if isTransitus == true then
                    local pinType
                    pinType, x, y = GetKeepPinInfo(nodeIndex, BGQUERY_LOCAL)
                else
                    local known, name
                    known, name, x, y = Wayshrine.Data.GetNodeInfo(nodeIndex)
                end
                return x, y
            end)
        end
    end)
end
