--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

--[[
Acknowledgments

I'd like to thank the following addons:
- English POI and Keep Names by Garkin
]]

-- Initialized the addon names
Cyrotivity = {}
Cyrotivity.name = "Cyrotivity"
Cyrotivity.version = 11.0

Cyrotivity.playerInPvP = false
Cyrotivity.campaignId = 0
Cyrotivity.currentSession = {}

Cyrotivity.keeps = {
    [3] = "Fort Warden",
    [4] = "Fort Rayles",
    [5] = "Fort Glademist",
    [6] = "Fort Ash",
    [7] = "Fort Aleswell",
    [8] = "Fort Dragonclaw",
    [9] = "Chalman Keep",
    [10] = "Arrius Keep",
    [11] = "Kingscrest Keep",
    [12] = "Farragut Keep",
    [13] = "Blue Road Keep",
    [14] = "Drakelowe Keep",
    [15] = "Castle Alessia",
    [16] = "Castle Faregyl",
    [17] = "Castle Roebeck",
    [18] = "Castle Brindle",
    [19] = "Castle Black Boot",
    [20] = "Castle Bloodmayne",
    [22] = "Castle Bloodmayne Farm",
    [23] = "Castle Bloodmayne Mine",
    [24] = "Castle Bloodmayne Lumbermill",
    [34] = "Castle Black Boot Lumbermill",
    [35] = "Castle Black Boot Mine",
    [36] = "Castle Black Boot Farm",
    [37] = "Farragut Keep Lumbermill",
    [38] = "Farragut Keep Mine",
    [39] = "Farragut Keep Farm",
    [40] = "Fort Warden Farm",
    [41] = "Fort Warden Lumbermill",
    [42] = "Fort Warden Mine",
    [43] = "Castle Faregyl Farm",
    [44] = "Castle Faregyl Lumbermill",
    [45] = "Castle Faregyl Mine",
    [46] = "Arrius Keep Farm",
    [47] = "Arrius Keep Lumbermill",
    [48] = "Arrius Keep Mine",
    [49] = "Fort Glademist Farm",
    [50] = "Fort Glademist Lumbermill",
    [51] = "Fort Glademist Mine",
    [52] = "Kingscrest Keep Farm",
    [53] = "Kingscrest Keep Lumbermill",
    [54] = "Kingscrest Keep Mine",
    [55] = "Fort Rayles Farm",
    [56] = "Fort Rayles Lumbermill",
    [57] = "Fort Rayles Mine",
    [61] = "Fort Ash Farm",
    [62] = "Fort Ash Lumbermill",
    [63] = "Fort Ash Mine",
    [64] = "Fort Aleswell Mine",
    [65] = "Fort Aleswell Lumbermill",
    [66] = "Fort Aleswell Farm",
    [67] = "Fort Dragonclaw Mine",
    [68] = "Fort Dragonclaw Lumbermill",
    [69] = "Fort Dragonclaw Farm",
    [70] = "Chalman Keep Mine",
    [71] = "Chalman Keep Lumbermill",
    [72] = "Chalman Keep Farm",
    [73] = "Blue Road Keep Mine",
    [74] = "Blue Road Keep Lumbermill",
    [75] = "Blue Road Keep Farm",
    [76] = "Drakelowe Keep Mine",
    [77] = "Drakelowe Keep Lumbermill",
    [78] = "Drakelowe Keep Farm",
    [79] = "Castle Alessia Mine",
    [80] = "Castle Alessia Lumbermill",
    [81] = "Castle Alessia Farm",
    [82] = "Castle Roebeck Mine",
    [83] = "Castle Roebeck Lumbermill",
    [84] = "Castle Roebeck Farm",
    [85] = "Castle Brindle Mine",
    [86] = "Castle Brindle Lumbermill",
    [87] = "Castle Brindle Farm",
    [132] = "Nikel Outpost",
    [133] = "Sejanus Outpost",
    [134] = "Bleaker's Outpost",
    [149] = "Vlastarus",
    [151] = "Bruma",
    [152] = "Cropsford",
	[154] = 'Alessia Bridge',
	[155] = 'Ash Milegate',
	[156] = 'Niben River Bridge',
	[157] = 'Bay Bridge',
	[158] = 'Priory Milegate',
	[159] = 'Chorrol Milegate',
	[160] = 'Kingscrest Milegate',
	[161] = 'Horunn Milegate',
	[162] = 'Chalman Milegate',
	[163] = "Winter's Peak Outpost",
	[164] = 'Carmala Outpost',
	[165] = "Harlun's Outpost"
}

-- Loads the addon; only hit once
function Cyrotivity.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= Cyrotivity.name then
		return
	end

	EVENT_MANAGER:UnregisterForEvent(Cyrotivity.name, EVENT_ADD_ON_LOADED)

	Cyrotivity:HookKeepTooltips()
	Cyrotivity:Initialize()
end

function Cyrotivity:Initialize()
	Cyrotivity:OnOff()

	EVENT_MANAGER:RegisterForEvent(Cyrotivity.name, EVENT_PLAYER_ACTIVATED, Cyrotivity.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(Cyrotivity.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, Cyrotivity.keepUnderAttack)
end

function Cyrotivity.OnPlayerActivated(eventCode, initial)
	Cyrotivity:OnOff()
end

function Cyrotivity:OnOff()
	Cyrotivity.playerInPvP = IsPlayerInAvAWorld()
	Cyrotivity.campaignId = GetCurrentCampaignId() 

	Cyrotivity.InitializeCampaign()

	if Cyrotivity.playerInPvP == true then
		EVENT_MANAGER:RegisterForEvent(Cyrotivity.name, EVENT_KEEP_UNDER_ATTACK_CHANGED, Cyrotivity.keepUnderAttack)
	else
		EVENT_MANAGER:UnregisterForEvent(Cyrotivity.name, EVENT_KEEP_UNDER_ATTACK_CHANGED)
	end
end

function Cyrotivity.keepUnderAttack(_, keepID, battlegroundContext, underAttack)
    if GetKeepType(keepID) == KEEPTYPE_IMPERIAL_CITY_DISTRICT then
        return
    end

    if underAttack then
		table.insert(Cyrotivity.currentSession[Cyrotivity.campaignId], keepID, os.time())
    end
end

function Cyrotivity.InitializeCampaign()
	if Cyrotivity.currentSession[Cyrotivity.campaignId] == nil then
		Cyrotivity.currentSession[Cyrotivity.campaignId] = {}
	end
end

function Cyrotivity:HookKeepTooltips()
	local function AnchorTo(control, anchorTo)
		local isValid, point, _, relPoint, offsetX, offsetY = control:GetAnchor(0)

		if isValid then
			control:ClearAnchors()
			control:SetAnchor(point, anchorTo, relPoint, offsetX, offsetY)
		end
	end

	local function ModifyKeepTooltip(self, keepId)
		if Cyrotivity.keeps[keepId] == nil then
			return
		end

		local nameLabel = self:GetNamedChild("Name")
		local allianceLabel, guildLabel, activityLabel, lineHeight

		if self.lastLine and nameLabel then
			local lastLine = self.lastLine
			local previousLine

			while lastLine or lastLine ~= nameLabel do
				local anchoredTo = select(3,lastLine:GetAnchor(0))

				if anchoredTo == nameLabel then
					allianceLabel = lastLine
					guildLabel = previousLine
					break
				end

				previousLine = lastLine
				lastLine = anchoredTo
			end
		end

		local defaultColor = {0.46274510025978, 0.73725491762161, 0.76470589637756, 1}

		activityLabel = self.linePool:AcquireObject()
		activityLabel:SetHidden(false)
		activityLabel:SetText(Cyrotivity.getLatestActivity(keepId))
		activityLabel:SetColor(unpack(defaultColor))
		activityLabel:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, 3)
		lineHeight = activityLabel:GetHeight()
		AnchorTo(allianceLabel, activityLabel)
		self.height = self.height + lineHeight + 3

		local width = activityLabel:GetTextWidth() + 16

		if width > self.width then
			self.width = width
		end

		self:SetDimensions(self.width, self.height)
	end

	local SetKeep = ZO_KeepTooltip.SetKeep

	ZO_KeepTooltip.SetKeep = function(self, keepId, ...)
		SetKeep(self, keepId, ...)
		ModifyKeepTooltip(self, keepId)
	end

	local RefreshKeep = ZO_KeepTooltip.RefreshKeepInfo

	ZO_KeepTooltip.RefreshKeepInfo = function(self, ...)
		RefreshKeep(self, ...)

		if(self.keepId and self.battlegroundContext and self.historyPercent) then
			ModifyKeepTooltip(self, self.keepId)
		end
	end
end

function Cyrotivity.getLatestActivity(keepID)
	local activityName = 'Latest Activity: '

	if Cyrotivity.isKeepUA(keepID) then
		activityName = activityName .. 'NOW'
		table.insert(Cyrotivity.currentSession[Cyrotivity.campaignId], keepID, os.time())
	elseif Cyrotivity.currentSession[Cyrotivity.campaignId] == nil then
		activityName = activityName .. 'Unknown'
	elseif Cyrotivity.currentSession[Cyrotivity.campaignId][keepID] == nil then
		activityName = activityName .. 'Unknown'
	else
		local lastUnderAttack = Cyrotivity.currentSession[Cyrotivity.campaignId][keepID]
		local difference = -(os.difftime(lastUnderAttack, os.time()))

		activityName = activityName .. Cyrotivity.SecondsToClock(difference)
	end

	return activityName
end

function Cyrotivity.isKeepUA(keepId)
	return GetKeepUnderAttack(keepId, BGQUERY_LOCAL)
end

function Cyrotivity.SecondsToClock(seconds)
	local seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00:00"
	else
		hours = string.format("%02.f", math.floor(seconds/3600))
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60))

		return hours..":"..mins..":"..secs
	end
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(Cyrotivity.name, EVENT_ADD_ON_LOADED, Cyrotivity.OnAddOnLoaded)
