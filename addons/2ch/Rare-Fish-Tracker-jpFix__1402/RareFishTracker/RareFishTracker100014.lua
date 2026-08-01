-- Rare Fish Tracker, an ESO plug-in by katkat42
-- This plug-in alerts you when you catch a new rare fish, so you know when this happens
-- even if you have auto-loot turned on. It also displays the rare fish for the zone
-- you are in, and whether you have caught them or not.
-- This is necessary because rare fish don't actually end up in your inventory, so they
-- don't even get caught by auto-loot announcer plug-ins.

-- define some variables
local wm = GetWindowManager()
local em = GetEventManager()

if RFT == nil then RFT = { } end

local RFT = RFT

RFT.fishCat = nil
RFT.fishSubCat = nil
RFT.numFishAch = nil
RFT.progress = {
	[0] =
	{
		-- ["None"] = true
	},
}
RFT.achnames = { }
RFT.fishnames = {
	[0] = { "None" },
}
RFT.settings = { }
RFT.defaults = {
	alpha = 50,
	x = 20,
	y = 20,
	shown = true,
	x_world = 20,
	y_world = 120,
	shown_world = true,
	showtitle = true,
	highlight = "Caught",
	apiVersion = GetAPIVersion(),
	showMunge = false,
	waterTypeAlpha = 0,
	autoShowHide = false,
	useDefaultColors = false,
}
local iconSize = 30
RFT.zone = ""
RFT.zones = { }
RFT.trackedAchievements = { }

-- define some business logic stuff

-- ScanAchievementsById() is run once, at load time, and scans the player's recorded fishing achievements so far.
-- cat is the number of the fishing achievements category, and num is the number of achievements in the category.
function RFT.ScanAchievementsById(id)
	RFT.progress[id] = { }
	RFT.fishnames[id] = { }
	RFT.achnames[id] = GetAchievementInfo(id)
	local numCrit = GetAchievementNumCriteria(id)
	local GetAchievementCriterion, giln, format = GetAchievementCriterion, GetItemLinkName, zo_strformat
	local progress, fishnames, itemLinks = RFT.progress[id], RFT.fishnames[id], RFT.achievementToItem[id]

	local desc, done, needed, itemLink
	for j = 1, numCrit, 1 do
		desc, done, needed = GetAchievementCriterion(id, j)
		if itemLinks then
			itemLink = itemLinks[j]
			if itemLink then
				itemLink = string.format("|H1:item:%i:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h", itemLink)
				desc = giln(itemLink)
			end
		end
		progress[desc] = done
		fishnames[#fishnames + 1] = desc
	end
end

-- RecordProgress() is run each time a fishing achievement is updated. It figures out which
-- fish you caught within that achievement, and records it in the table.
function RFT.RecordProgress(achieveId)
	local function callback(icon, text)
		-- launch an alert
		CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_XP_UPDATE, CSA_EVENT_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_INCREMENT, zo_strformat("<<1>> <<2>>", icon, text))
	end
	local _, _, _, icon = GetAchievementInfo(achieveId)
	local numCrit = GetAchievementNumCriteria(achieveId)

	local itemLinks, giln = RFT.achievementToItem[achieveId], GetItemLinkName
	local format = string.format
	for i = 1, numCrit, 1 do
		local desc, done = GetAchievementCriterion(achieveId, i)
		if itemLinks then
			local itemLink = itemLinks[i]
			if itemLink then
				itemLink = format("|H1:item:%i:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h", itemLink)
				desc = giln(itemLink)
			end
		end
		if RFT.progress[achieveId][desc] ~= done then
			RFT.progress[achieveId][desc] = done
			-- Update: You can catch more than one fish (due to CPs?), even two for achievement.
			callback(zo_iconFormat(icon, iconSize, iconSize), desc)
		end
	end
end

-- define some event callbacks
-- ProcessUpdate() is a callback for EVENT_ACHIEVEMENT_UDPATED, run whenever any achievement is updated.
function RFT.ProcessUpdate(event, achieveId)
	-- is the updated achievement a fishing achievement? If not, ignore.
	if RFT.trackedAchievements[achieveId] then
		-- record the results in our handy-dandy table
		RFT.RecordProgress(achieveId)
		-- update the window
		RFT.RefreshWindow()
	end
end

-- RefreshWindow() is a callback for EVENT_ZONE_CHANGED. It populates the window with data about the new zone.
function RFT.RefreshWindowZoneChanged(eventid, zoneName, subzoneName)
	local zone = GetZoneId(GetUnitZoneIndex('player'))
	if subzoneName and subzoneName ~= "" then
		local subzoneId = RFT.zones[LocalizeString("<<!A:1>>", subzoneName)]
		if subzoneId and zone ~= subzoneId then
			-- Learn subzone/zone relation for all characters and beyond reload UI
			RFT.common.subzoneToZone[subzoneId] = zone
		end
	end
	if RFT.zone == zone then return end
	RFT.isAutoRefresh = true
	RFT.RefreshWindowForZone(zone)
end

function RFT.RefreshWindow()
	RFT.RefreshWindowForZone(WORLD_MAP_SCENE:IsShowing() and RFT.zone or GetZoneId(GetUnitZoneIndex('player')))
end

function RFT.GetAchievementsByZoneIndex(zone)
	local achievement = RFT.zoneToAchievement[zone] or RFT.zoneToAchievement[RFT.common.subzoneToZone[zone]] or 0
	return achievement
end

do
	local identifier = "RareFishTrackerRefresh"
	local function RefreshDelay()
		em:UnregisterForUpdate(identifier, RefreshDelay)
		RFT.numCaught, RFT.numFishes = RFT.PopulateWindow(RFT.zone, RFT.GetAchievementsByZoneIndex(RFT.zone))
		RARE_FISH_TRACKER_FRAGMENT:Refresh(500, 500)
	end
	function RFT.RefreshWindowForZone(zone)
		RFT.zone = zone
		-- Buffer multiple refresh requests and spread cpu load
		em:UnregisterForUpdate(identifier)
		em:RegisterForUpdate(identifier, 133, RefreshDelay)
	end
end

local function ZoneNameToIndex()
	local i = 1
	local zones = RFT.zones
	local zbn, format, GetZoneId = GetZoneNameByIndex, LocalizeString, GetZoneId
	local zone
	while true do
		zone = zbn(i)
		if zone == "" then break end
		zones[format("<<!A:1>>", zone)] = GetZoneId(i)
		i = i + 1
	end
end

-- initialization stuff
function RFT.Init(event, addon)
	if addon ~= "RareFishTracker" then return end
	em:UnregisterForEvent("RareFishInitialize", EVENT_ADD_ON_LOADED)

	-- load our saved variables
	RFT.settings = ZO_SavedVars:New("RareFishTrackerSavedVars", 1, nil, RFT.defaults)
	RFT.common = ZO_SavedVars:New("RareFishTrackerSavedVars", GetAPIVersion(), nil, { subzoneToZone = { } }, "Default", "$Machine", "$UserProfileWide")

	-- Reverse lookup from name to index
	ZoneNameToIndex()

	-- make our options menu
	RFT.MakeMenu()

	local tracked = RFT.trackedAchievements
	for _, achs in pairs(RFT.zoneToAchievement) do
		for _, ach in ipairs(achs) do
			tracked[ach] = true
			RFT.ScanAchievementsById(ach)
		end
	end

	-- and then let us know when those updates happen
	em:RegisterForEvent("RareFishTracker", EVENT_ACHIEVEMENT_UPDATED, function(...) RFT.ProcessUpdate(...) end)
	em:RegisterForEvent("RareFishTrackerZone", EVENT_ZONE_CHANGED, function(...) RFT.RefreshWindowZoneChanged(...) end)

	-- also, do this last, to minimize the chance of problem zone transitions
	em:RegisterForEvent("RareFishStart", EVENT_PLAYER_ACTIVATED, function(...) RFT.RefreshWindowZoneChanged(EVENT_PLAYER_ACTIVATED, nil, nil, false) end)
end

-- register to be initialized when we're ready
em:RegisterForEvent("RareFishInitialize", EVENT_ADD_ON_LOADED, function(...) RFT.Init(...) end)