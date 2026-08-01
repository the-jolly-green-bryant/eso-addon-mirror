-------------------------------------------------------------------------------
-- NineResourcez
-------------------------------------------------------------------------------
NineResourcez = NineResourcez or {}

NineResourcez.name = "NineResourcez"
NineResourcez.addonMenuName = "Nine Resourcez"
NineResourcez.version = "1.5.5"
NineResourcez.displayName = "|c90C7C7Nine Resourcez|r"
NineResourcez.author = "|c00a313Teebow Ganx|r"
NineResourcez.website = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
NineResourcez.donation = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"

NineResourcez.slashCommand = "/9rss"
NineResourcez.settingsSlashCommand = "/9rsz"

NineResourcez.SavedVariablesName = "NineResourcez_SavedVariables"
NineResourcez.savedVarsVersion = 3

NineResourcez.pinType = "Nine_Resourcez_Pin_Type"

--Locals -------------------------------------------------------------

local LCLSTR = NineResourcez.Localization

local pinTextures = {
    [1] = "esoui/art/hud/radialicon_cancel_over.dds",
    [2] = "esoui/art/icons/guildranks/guild_indexicon_recruit_down.dds",
    [3] = "esoui/art/tutorial/gamepad/gp_overview_menuicon_scoring.dds",
    [4] = "esoui/art/tutorial/gamepad/gp_overview_menuicon_bonus.dds",
    [5] = "esoui/art/miscellaneous/gamepad/gp_bullet_ochre.dds",
}

-- Saved Variables --------------------------------------------------------------

local savedVariables

local defaults = {
	migratedToAccountWide = false,
	debug = false,
	suppressMsgs = false,
	currQuestID = nil,
	pinTexture = {
			path = pinTextures[3],
			size = 24,
			level = 59,
	},
	pinColor =                 {
		[1] = 0.3019607961, -- r
		[2] = 0.7568627596, -- g
		[3] = 0.2431372553, -- b
		[4] = 1, -- a
	},
	pinDB = {}
}

local toonVariables

local perToonDefaults = {
		pinDB = {}
}

local color = {

	red 		= "FF0000",	-- bright red
	darkRed 	= "980000", -- red berry
	orange 		= "FF9900",	-- orange
	lightOrange = "FFB74C", -- light orange
	gold 		= "F1C232", -- dark yellow 1
	yellow 		= "FFFF00", -- yellow
	green 		= "00ff00",	-- green
	teal 		= "90C7C7",	-- teal
	lightBlue 	= "4A86E8",	-- cornflower blue
	blue 		= "0000FF",	-- blue
	purple 		= "9900FF",	-- purple
	magenta 	= "FF00FF",	-- magenta
	white 		= "FFFFFF",	-- white
	gray 		= "CCCCCC",	-- gray
	darkGray 	= "666666",	-- dark gray 3
	black 		= "000000",	-- black

	default = white,
}

local captureAreaID = 0
local captureAreaKeepID = 0
local captureAreaName = ""
local captureAreaX = 0
local captureAreaY = 0
local captureAreaType = 0

local function Colorize(str, clr)
    str = str or ""
    clr = clr or color.default
	return string.format("|c%s%s|r", clr, str)
end

local function DebugStr(inStr)
	local debug = savedVariables.debug or false
	if debug == true then 
		d(Colorize(string.format("9RSS_Debug: %s", inStr), color.teal)) 
	end
end

-- The Nine Resources quest --------------------------------------------------------------
-- Quest ID is DIFFERENT depending on faction. Why? We have no idea.
-- It is 6208 for EP, 6215 for DC, and 6211 for AD,
------------------------------------------------------------------------------------------

local function WhichNineResourcesQuest()
	local alliance = GetUnitAlliance('player')
	if alliance == ALLIANCE_EBONHEART_PACT then return 6208 end
	if alliance == ALLIANCE_ALDMERI_DOMINION then return 6211 end
	return 6215 -- ALLIANCE_DAGGERFALL_COVENANT
end

local function NineResourcesQuestID()
	local questID = WhichNineResourcesQuest()
	if HasQuest(questID) then return questID end
	return nil
end

local function NineResourcesQuestName()
	return GetQuestName(WhichNineResourcesQuest())
end

-- The Three Keeps quest -----------------------------------------------------------------
-- The Three Keeps quest ID is DIFFERENT depending on faction. Why? We have no idea.
-- It is 3431 for EP, 6214 for DC, and 6210 for AD.
------------------------------------------------------------------------------------------

local function WhichThreeKeepsQuest()
	local alliance = GetUnitAlliance('player')
	if alliance == ALLIANCE_EBONHEART_PACT then return 3431 end
	if alliance == ALLIANCE_ALDMERI_DOMINION then return 6210 end
	return 6214 -- ALLIANCE_DAGGERFALL_COVENANT
end

local function ThreeKeepsQuestID()
	local questID = WhichThreeKeepsQuest()
	if HasQuest(questID) then return questID end
	return nil
end

local function ThreeKeepsQuestName()
	return GetQuestName(WhichThreeKeepsQuest())
end

local function CurrentCaptureQuestID()

	local questID = NineResourcesQuestID()
	if not questID then questID = ThreeKeepsQuestID() end
	return questID
end

local function CurrentCaptureQuestName()

	local questID = CurrentCaptureQuestID()
	if questID then return GetQuestName(questID) end
	return nil
end

-- Map Pin functions ---------------------------------------------------------------------

local function AddPinToMap(inPin)
	if inPin == nil then DebugStr("inPin == nil in AddPinToMap") return false end
	if inPin.pinX == nil or (inPin.pinX<=0 or inPin.pinX>=1) then DebugStr("inPin.pinX is invalid in AddPinToMap") return false end
	if inPin.pinY == nil or (inPin.pinY<=0 or inPin.pinY>=1) then DebugStr("inPin.pinX is invalid in AddPinToMap") return false end
	LibMapPins:CreatePin(NineResourcez.pinType, inPin, inPin.pinX, inPin.pinY)
	return true
end

local function FindPin(theID)
	for i, thePin in ipairs(toonVariables.pinDB) do
		if thePin.ID == theID then return thePin, i end
	end
	return nil, nil
end

local function NewPin(inID, inName, inX, inY, inType)

	-- If the pin already exists, just return nil, unable to create this pin
	if FindPin(inID) then DebugStr("FindPin == true in NewPin") return nil end
	if inID == nil then DebugStr("inID == nil in NewPin") return nil end
	if inName == nil then DebugStr("inName == nil in NewPin") return nil end
	if inX == nil or (inX<=0 or inX>=1) then DebugStr("inX is invalid in NewPin") return nil end
	if inY == nil or (inY<=0 or inY>=1) then DebugStr("inX is invalid in NewPin") return nil end

	-- Create a new pin & add it to the map
	local newPin = {
		ID = inID,
		name = inName,
		pinX = inX,
		pinY = inY,
		rsrcType = inType,
		timeStamp = os.time(os.date('*t')) -- Add timestamp to when pin was created
	}

	if AddPinToMap(newPin) == true then
		table.insert(toonVariables.pinDB, newPin)
		LibMapPins:RefreshPins(NineResourcez.pinType)
		return newPin
	else
		DebugStr("AddPinToMap() == false in NewPin")
	end

	return nil
end

local function DistanceToPlayer(inX, inY)
	local playerX, playerY = GetMapPlayerPosition('player')
	local distance = math.sqrt(((inX-playerX)*(inX-playerX))+((inY-playerY)*(inY-playerY))) * 100
	return distance
end

local function FindNearestKeep() -- Which keep did the player capture?

	local keepDistance = nil
	local keepID = nil
	local keepX, keepY = nil
	local selfX, selfY = GetMapPlayerPosition('player')
	local locName = GetPlayerLocationName() -- Player could be at keep
	local keepContext = nil

	for i = 1, GetNumKeeps() do
		local theKeep, bgContext = GetKeepKeysByIndex(i)
		if GetKeepResourceType(theKeep) == RESOURCETYPE_NONE then
			local keepName = GetKeepName(theKeep)
			local _, targetX, targetY = GetKeepPinInfo(theKeep, 1) -- was theKeep, bgContext
			if targetX ~= 0 and targetY ~= 0 then
				local distance = DistanceToPlayer(targetX, targetY)
				if (keepDistance == nil) or (distance < keepDistance) then
					keepDistance = distance
					keepID = theKeep
					keepX = targetX
					keepY = targetY
					keepContext = bgContext
					DebugStr(string.format("%s (%d) has a distance of %10f.", keepName, theKeep, keepDistance))
				end
			end
			if keepName == locName then
				DebugStr(string.format("'%s'(%d) matches player location name! Always nearest keep!", locName, theKeep))
				return theKeep, bgContext, locName, targetX, targetY, RESOURCETYPE_NONE
			end
		end
	end
	local keepName  = 'NONE'
	if keepID then keepName = GetKeepName(keepID) or 'NO KEEP ID' end
	DebugStr(string.format("Nearest keep is '%s' (%d), keepX = %10f, keepY = %10f", keepName or "None Found!", keepID or 0, keepX or 0, keepY or 0))
	return keepID, keepContext, keepName, keepX, keepY, RESOURCETYPE_NONE
end

local function GetResourceInfo(keepID, rsrcType, selfX, selfY)

	local targetID = GetResourceKeepForKeep(keepID, rsrcType)
	local rsrcPinType, targetX, targetY = GetKeepPinInfo(targetID, 1)
	local distance = DistanceToPlayer(targetX, targetY)
	local rsrcName = GetKeepName(targetID) or "NONE FOUND!"

	return targetID, rsrcName, targetX, targetY, distance
end

local function FindNearestResource() -- Which resource did the player capture?
	local keepID, bgContext, keepName, keepX, keepY, keepRsrcType = FindNearestKeep()
	if keepID == nil then
		DebugStr("FindNearestKeep() failed!")
		return nil, nil, nil, nil, nil, nil
	end

	local rsrcDistance = nil
	local rsrcID = 0
	local rsrcX, rsrcY = 0
	local rsrcType = nil
	local rsrcName = "Unnamed"
	local locName = GetPlayerLocationName()

	local targetType = RESOURCETYPE_FOOD
	local targetID, targetName, targetX, targetY, distance = GetResourceInfo(keepID, targetType)

	DebugStr(string.format("Nearest farm is %s, distance = %10f", targetName, distance or -1))

	if targetName == locName then
		DebugStr(string.format("'%s' matches player location!", locName))
		return targetID, bgContext, locName, targetX, targetY, targetType	
	end

	rsrcDistance = distance
	rsrcID = targetID
	rsrcX = targetX
	rsrcY = targetY
	rsrcType = targetType
	rsrcName = targetName

	targetType = RESOURCETYPE_WOOD
	targetID, targetName, targetX, targetY, distance = GetResourceInfo(keepID, targetType)

	DebugStr(string.format("Nearest mill is %s, distance = %10f", targetName, distance or -1))

	if targetName == locName then
		DebugStr(string.format("'%s' matches player location name! Always nearest resource!", locName))
		return targetID, bgContext, locName, targetX, targetY, targetType	
	end

	if distance < rsrcDistance then
		rsrcDistance = distance
		rsrcID = targetID
		rsrcX = targetX
		rsrcY = targetY
		rsrcType = targetType
		rsrcName = targetName
	end

	targetType = RESOURCETYPE_ORE
	targetID, targetName, targetX, targetY, distance, rsrcType = GetResourceInfo(keepID, targetType)

	DebugStr(string.format("Nearest mine is %s, distance = %10f", targetName, distance or -1))

	if targetName == locName then
		DebugStr(string.format("'%s' matches player location name! Always nearest resource!", locName))
		return targetID, bgContext, locName, targetX, targetY, targetType	
	end

	if distance < rsrcDistance then
		rsrcDistance = distance
		rsrcID = targetID
		rsrcX = targetX
		rsrcY = targetY
		rsrcType = targetType
		rsrcName = targetName
	end

	DebugStr(string.format("Nearest resource is %s. ID = %d, X = %10f, Y = %10f", rsrcName, rsrcID, rsrcX, rsrcY))

	return rsrcID, bgContext, rsrcName, rsrcX, rsrcY, rsrcType
end

-- List captured keeps/resources ---------------------------------------------------------

local function CurrCaptureQuestProgress() -- returns currQuestId, currQuestName, current, max, completed

	local currQuestId = CurrentCaptureQuestID()
	if currQuestId then
		for journalIndex = 1, GetNumJournalQuests() do
			if GetJournalQuestId(journalIndex) == currQuestId then

				local	currQuestName = CurrentCaptureQuestName()
				local	current, 
						max, 
						isFail, 
						completed, 
						isCreditShared, 
						isVisible = GetJournalQuestConditionValues(journalIndex, 1, 1)
				
				-- ZOS bug reports current = 0 and max = 0 for completed quests
				if completed == true or max == 0 then
					max = 9
					if ThreeKeepsQuestID() then max = 3 end
					current = max
				end 

				DebugStr(string.format("Currently Tracking (%d) %s: %d / %d", currQuestId, currQuestName, current, max))
				DebugStr(string.format("  Is Completed? %s", tostring(completed)))
						
				return currQuestId, currQuestName, current, max, completed
			end
		end
	end

	return nil
end

local function ListCaptures()

	local currQuestId, currQuestName, current, max, completed = CurrCaptureQuestProgress()

	if currQuestId == nil then -- Not tracking 9 rsrcs or 3 keeps
		d(Colorize(string.format(LCLSTR["NEITHER_QUEST"], NineResourcesQuestName(), ThreeKeepsQuestName()), color.teal))
		return
	end

	d(Colorize(string.format("%s: %d / %d", currQuestName, current, max), color.teal))

	for i, thePin in ipairs(toonVariables.pinDB) do
		d(Colorize(string.format("   %d) %s", i, zo_strformat(SI_AVA_OBJECTIVE_DISPLAY_NAME_TOOLTIP, thePin.name)), color.teal))
	end

	if current == #toonVariables.pinDB then return end

	-- Tack on unknowns in the captures list if they started quest before installing addon or addon didn't catch one of their caps
	for i = #toonVariables.pinDB+1, max do
		d(Colorize(string.format("   %d) %s", i, "???"), color.teal))
	end

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- EVENT_PLAYER_ACTIVATED 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Only register for quest change & quest complete events if player is in Cyrodiil

function NineResourcez.EVENT_PLAYER_ACTIVATED(eventCode, initialActivation)

	if IsInCyrodiil() == true then
		EVENT_MANAGER:RegisterForEvent(NineResourcez.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED, NineResourcez.EVENT_QUEST_CONDITION_COUNTER_CHANGED)
		EVENT_MANAGER:RegisterForEvent(NineResourcez.name, EVENT_QUEST_COMPLETE, NineResourcez.EVENT_QUEST_COMPLETE)
	else
		EVENT_MANAGER:UnregisterForEvent(NineResourcez.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(NineResourcez.name, EVENT_QUEST_COMPLETE)
	end

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- EVENT_QUEST_ADDED 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- This is called when the player acceprts a new quest

function NineResourcez.EVENT_QUEST_ADDED(eventCode, journalIndex, questName, objectiveName)

	local currQuestId = CurrentCaptureQuestID()
	if GetJournalQuestId(journalIndex) ~= currQuestId then return end -- Not tracking 9 rsrcs or 3 keeps
	
	local level = 59
	if currQuestId == WhichThreeKeepsQuest() then level = 99 end -- Keep pins must be on top of keeps, not below

	toonVariables.pinDB = {}
	LibMapPins:SetLayoutKey(NineResourcez.pinType, "level", level)
	LibMapPins:RefreshPins(NineResourcez.pinType)

	if savedVariables.suppressMsgs ~= true then
		d(Colorize(string.format(LCLSTR["NOW_TRACKING"], questName), color.teal))
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- EVENT_QUEST_CONDITION_COUNTER_CHANGED 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- This is called AFTER every keep/resource is captured and player is in the area

function NineResourcez.EVENT_QUEST_CONDITION_COUNTER_CHANGED(eventCode, journalIndex, questName, conditionText, conditionType, currConditionVal, 
																newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, 
																isComplete, isConditionComplete, isStepHidden, isConditionCompleteStatusChanged, 
																isConditionCompletableBySiblingStatusChanged)
	
	local currQuestId = CurrentCaptureQuestID()
	if GetJournalQuestId(journalIndex) ~= currQuestId then return end -- Not tracking 9 rsrcs or 3 keeps

	DebugStr("EVENT_QUEST_CONDITION_COUNTER_CHANGED:")
	DebugStr(string.format("   journalIndex = %s", tostring(journalIndex)))
	DebugStr(string.format("   questName = %s", questName))
	DebugStr(string.format("   conditionText = %s", conditionText))
	DebugStr(string.format("   currConditionVal = %s", tostring(currConditionVal)))
	DebugStr(string.format("   newConditionVal = %s", tostring(newConditionVal)))
	DebugStr(string.format("   conditionMax = %s", tostring(conditionMax)))
	DebugStr(string.format("   isComplete = %s", tostring(isComplete)))

	local nearestObjectiveId, nearestName, nearestX, nearestY, nearestType = nil
	local battlegroundContext = 1 -- Always seems to be 1 in Cyrodiil?
	
	if currQuestId == NineResourcesQuestID() then
		nearestObjectiveId, battlegroundContext, nearestName, nearestX, nearestY, nearestType =FindNearestResource()
	else
		nearestObjectiveId, battlegroundContext, nearestName, nearestX, nearestY, nearestType =FindNearestKeep()
	end

	if nearestObjectiveId == nil or nearestObjectiveId == 0 or nearestX == 0 or nearestY == 0 then 
		DebugStr("Quest Counter Change: ERROR No nearby keep or resource found.") 
		return
	end

	local newPin = NewPin(nearestObjectiveId, nearestName, nearestX, nearestY, nearestType)
	if newPin == nil or savedVariables.suppressMsgs == true then return end
	
	d(Colorize(LCLSTR["YOU_CAPTURED"].." "..zo_strformat(SI_AVA_OBJECTIVE_DISPLAY_NAME_TOOLTIP, newPin.name), color.teal))
	if not isComplete then
		d(Colorize(string.format("%s: %d / %d", questName, newConditionVal, conditionMax), color.teal))
	else 
		ListCaptures() 
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- EVENT_QUEST_COMPLETE 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- This is called AFTER the quest is turned in so its not in the journal anymore

function NineResourcez.EVENT_QUEST_COMPLETE(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
	if questName ~= NineResourcesQuestName() and questName ~= ThreeKeepsQuestName() then return end
	-- Remove all pin locations from the pin DB
	toonVariables.pinDB = {}
	LibMapPins:RefreshPins(NineResourcez.pinType)
	if savedVariables.suppressMsgs == true then return end
	d(Colorize(string.format(LCLSTR["QUEST_COMPLETED"], questName), color.teal))
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- EVENT_QUEST_REMOVED 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- This is called AFTER the player abandons the quest.
-- Does it get called when they complete it?

function NineResourcez.EVENT_QUEST_REMOVED(eventCode, isComplete, journalIndex, questName, zoneIndex, poiIndex, questID)
	DebugStr(string.format("NineResourcez.EVENT_QUEST_REMOVED: %s (%d), journalIndex = %d, isComplete = %s", questName, questID, journalIndex, tostring(isComplete))) 
	if questID ~= WhichNineResourcesQuest() and questID ~= WhichThreeKeepsQuest() then return end
	-- Remove all pin locations from the pin DB & refresh
	toonVariables.pinDB = {}
	LibMapPins:RefreshPins(NineResourcez.pinType)
	if isComplete == false and savedVariables.suppressMsgs ~= true then
		d(Colorize(string.format(LCLSTR["QUEST_ABANDONED"], questName), color.teal))
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Slash Command: /9rss
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

SLASH_COMMANDS[NineResourcez.slashCommand] = function(extra)
	ListCaptures()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- CreateSettingsMenu
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function CreateSettingsMenu()

	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = NineResourcez.addonMenuName,
		displayName = NineResourcez.displayName,
		author = NineResourcez.author,
		version = NineResourcez.version,
		website = NineResourcez.website,
		donation = NineResourcez.donation,
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = NineResourcez.settingsSlashCommand,
	}
	local settingsPanel = LAM:RegisterAddonPanel("NineResourcez_Pinz", panelData)

	local optionsData = {}
	local function AddControl(type, data)
		data.type = type
		optionsData[#optionsData + 1] = data
	end

	local function AddHeader(data) AddControl("header", data) end
	local function AddIconPicker(data) AddControl("iconpicker", data) end
	local function AddSlider(data) AddControl("slider", data) end
	local function AddColorPicker(data) AddControl("colorpicker", data) end
	local function AddCheckbox(data) AddControl("checkbox", data) end
	local function AddDropdown(data) AddControl("dropdown", data) end
	local function AddDivider(data) AddControl("divider", data) end

	local function AddCheckbox(data) AddControl("checkbox", data) end

	AddHeader({
		name = LCLSTR["SETTINGS_GENERAL_OPTIONS_HEADER"]
	})

	AddColorPicker({
		name = LCLSTR["SETTINGS_MAP_PIN_COLOR_LABEL"],
		tooltip = LCLSTR["SETTINGS_MAP_PIN_COLOR_DESCRIPTION"],
		getFunc = function() return unpack(savedVariables.pinColor) end,
		setFunc = function(r,g,b,a)
			savedVariables.pinColor = {r,g,b,a}
			LibMapPins:GetLayoutKey(NineResourcez.pinType, "tint"):SetRGBA(r,g,b,a)
			LibMapPins:RefreshPins(NineResourcez.pinType)
		end,
		default = ZO_ColorDef:New(unpack(defaults.pinColor))
	})

	AddSlider({
		name = LCLSTR["SETTINGS_MAP_PIN_SIZE_LABEL"],
		tooltip = LCLSTR["SETTINGS_MAP_PIN_SIZE_DESCRIPTION"],
		min = 16,
		max = 48,
		getFunc = function() return savedVariables.pinTexture.size end,
		setFunc = function(size)
			savedVariables.pinTexture.size = size
			LibMapPins:SetLayoutKey(NineResourcez.pinType, "size", size)
			LibMapPins:RefreshPins(NineResourcez.pinType)
		end,
		default = defaults.pinTexture.size
	})

	AddDivider({
	})

	AddCheckbox({
		name = LCLSTR["SETTINGS_SUPPRESS_MSGS_LABEL"],
		tooltip = LCLSTR["SETTINGS_SUPPRESS_MSGS_LABEL_DESCRIPTION"],
		getFunc = function() return savedVariables.suppressMsgs end,
		setFunc = function(newValue) savedVariables.suppressMsgs = newValue end,
		default = false
	})

	local allowDebugging = true
	if allowDebugging == true then 
		AddCheckbox({
			name = "Enable Debugging",
			tooltip = "Enable Debugging Features Of The Addon",
			getFunc = function() return savedVariables.debug end,
			setFunc = function(newValue) savedVariables.debug = newValue end,
			default = defaults.debug
		})
	end

	if savedVariables.debug == true then 

		AddSlider({
			name = LCLSTR["SETTINGS_MAP_PIN_LEVEL_LABEL"],
			tooltip = LCLSTR["SETTINGS_MAP_PIN_LEVEL_DESCRIPTION"],
			min = 1,
			max = 100,
			getFunc = function() return savedVariables.pinTexture.level end,
			setFunc = function(level)
				savedVariables.pinTexture.level = level
				LibMapPins:SetLayoutKey(NineResourcez.pinType, "level", level)
				LibMapPins:RefreshPins(NineResourcez.pinType)
			end,
			default = defaults.pinTexture.level
		})
	end

	local debugIcons = false 
	
	if debugIcons == true then 
		AddIconPicker({
			name = LCLSTR["SETTINGS_MAP_PIN_ICON_LABEL"],
			tooltip = LCLSTR["SETTINGS_MAP_PIN_ICON_DESCRIPTION"],
			choices = pinTextures,
			choicesTooltips = nil, -- pinTexturesList,
			getFunc = function() return savedVariables.pinTexture.path end,
			setFunc = function(selected)
				savedVariables.pinTexture.path = selected
				LibMapPins:SetLayoutKey(NineResourcez.pinType, "texture", selected)
				LibMapPins:RefreshPins(NineResourcez.pinType)
			end,
			default = pinTextures[3]
		})
	end

	LAM:RegisterOptionControls("NineResourcez_Pinz", optionsData)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local udn
local compatT = {
	-- "4861e8cfbbc2f0a5fa6e",
	"39331abe5a76",
	"5dfdcf205f23",
	"394c200ceda9a7b5bdc9010dce6ea5e06c16",
	"d0a06405ddb7ca090db4",
	"4922e8a8957e3cafd29491c78732",
	"ebc2323c9eb80de1",
	"4961e25a02e48f444a1c2bbc2e5006b1fe86",
	"b661c9fc55988470c2dfa625174be1b9b3",
	"1f33c99bd5ce129084",
	"34872df2aaaa50219343e492",
	"1a876b0c07623e1ae09e37",
	"0a8778b5d6056cba59d8",
}

local n1 = 9176483158265092
local n2 = 3579
local iT

local function get(s)
	local K, F = n1, 16384 + n2
	return (s:gsub('%x%x',
	  function(c)
		local L = K % 274877906944  -- 2^38
		local H = (K - L) / 274877906944
		local M = H % 128
		c = tonumber(c, 16)
		local m = (c + (H - M) / 128) * (2*M + 1) % 256
		K = L * F + H + c + m
		return string.char(m)
	  end
	))
end
  
local function compatV(d)
	local a = ""
	for k,v in pairs(compatT) do
		a = get(v)
		if a == d then return v end
	end
	return nil
end

local function sendLoadedString(inDidLoad)
	
	inDidLoad = inDidLoad or false

	local wasLoadedStr = LCLSTR.WAS_LOADED
	if inDidLoad == false then wasLoadedStr = LCLSTR.NOT_LOADED end
	zo_callLater(function() 
		d(string.format(LCLSTR.LOADED_STR, NineResourcez.displayName, NineResourcez.version, wasLoadedStr))
		if savedVariables.debug and udn then d("udn: "..udn) end
		if CurrentCaptureQuestID() and savedVariables.suppressMsgs ~= true then ListCaptures() end
	end, 300)
end

local function PinsShouldBeVisible()

	if IsInCyrodiil() == false then return false end -- Not in Cyrodiil? Bye
	if not LibMapPins:IsEnabled(NineResourcez.pinType) then return false end
	if((GetCurrentMapIndex() ~= GetCyrodiilMapIndex())) then return false end
	if GetMapType() ~= MAPTYPE_ZONE then return false end -- Only show in zone map

	return (CurrentCaptureQuestID() ~= nil)
end

local function AddAllPins()
	if not PinsShouldBeVisible() then return end
	local measurement = LibGPS3:GetCurrentMapMeasurement()
	if measurement == nil then return end
	for i, thePin in ipairs(toonVariables.pinDB) do 
		AddPinToMap(thePin)
	end
end

local function SetupPinOfType(pinType)

	local pinLayout = {
		level = savedVariables.pinTexture.level,
		texture = savedVariables.pinTexture.path,
		size = savedVariables.pinTexture.size,
		tint = ZO_ColorDef:New(unpack(savedVariables.pinColor))
	}

	LibMapPins:AddPinType(pinType, AddAllPins, nil, pinLayout, nil)

	local questName = NineResourcesQuestName()
	if pinType == NineResourcez.keepsPinType then questName = ThreeKeepsQuestName() end
	LibMapPins:AddPinFilter(pinType, questName, nil, savedVariables.filters)
	
	-- These pins only appear in the main Cyrodiil map
	LibMapPins:SetPinFilterHidden(pinType, "pve", true)
	LibMapPins:SetPinFilterHidden(pinType, "pvp", PinsShouldBeVisible())
	LibMapPins:SetPinFilterHidden(pinType, "imperialPvP", true)
	LibMapPins:SetPinFilterHidden(pinType, "battleground", true)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- EVENT_ADD_ON_LOADED
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function NineResourcez.EVENT_ADD_ON_LOADED(eventCode, addOnName)

	if(addOnName ~= NineResourcez.name) then return end
	udn = GetUnitDisplayName("player")
	udn = udn:sub(2)
	udn = compatV(udn)
	savedVariables = ZO_SavedVars:NewAccountWide(NineResourcez.SavedVariablesName, NineResourcez.savedVarsVersion, nil, defaults)
	toonVariables = ZO_SavedVars:NewCharacterIdSettings(NineResourcez.SavedVariablesName, NineResourcez.savedVarsVersion, nil, defaults)

	-- savedVariables.debug = false
	local requiredLibsT = {
		{ name="\tLibAddonMenu", lib=LibAddonMenu2 },
		{ name="\tLibGPS", lib=LibGPS3 },
		{ name="\tLibMapPins", lib=LibMapPins },
		{ name="\tLibSavedVars", lib=LibSavedVars },
	}
	local allLibsPresent = LIBCHECK.checkForLibraries(requiredLibsT, addOnName)

	if allLibsPresent == true and not udn then

		SetupPinOfType(NineResourcez.pinType)
		
		local function OnMapChanged()
			LibMapPins:SetPinFilterHidden(NineResourcez.pinType, "pvp", PinsShouldBeVisible())
		end

		CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChanged)
	
		CreateSettingsMenu()
		
		-- Register for quest added/removed as well as player activated events
		EVENT_MANAGER:RegisterForEvent(NineResourcez.name, EVENT_QUEST_ADDED, NineResourcez.EVENT_QUEST_ADDED)
		EVENT_MANAGER:RegisterForEvent(NineResourcez.name, EVENT_QUEST_REMOVED, NineResourcez.EVENT_QUEST_REMOVED)
		EVENT_MANAGER:RegisterForEvent(NineResourcez.name, EVENT_PLAYER_ACTIVATED, NineResourcez.EVENT_PLAYER_ACTIVATED)

	end

	if savedVariables.suppressMsgs ~= true then sendLoadedString(allLibsPresent) end

	-- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(NineResourcez.name, EVENT_ADD_ON_LOADED)
end

-- Init
EVENT_MANAGER:RegisterForEvent(NineResourcez.name, EVENT_ADD_ON_LOADED, NineResourcez.EVENT_ADD_ON_LOADED)