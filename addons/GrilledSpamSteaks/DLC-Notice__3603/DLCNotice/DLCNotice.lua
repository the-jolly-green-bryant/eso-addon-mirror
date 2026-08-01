-- ESO DLC Notice
-- This Add-on pops up a notice that the person you're looking at will launch a DLC mission
-- API Reference: https://www.esoui.com/downloads/info1213-ESOUI-TheElderScrollsOnlinesourcecode.html
-- note: Ingame testing: make changes then type /reloadui in chat
-- 1.5 Checked API calls are still valid
----------------------------------------------------------------------------------------------------------------------------------------
DLCNotice = {
  name = "DLC Notice",
  version = "1.6",
  author = "GrilledSpamSteaks"
}
function DLCNotice.Initialize()
  -- ...but we don't have anything to initialize yet. We'll come back to this.
end
--color definitions
--	[1]:float
--		red color
--	[2]:float
--		green color
--	[2]:float
--		blue color
local blue={r=0,g=0.25,b=1}
local cyan={r=0,g=1,b=1}
local gray={r=0.5,g=0.5,b=0.5}
local green={r=0,g=0.7,b=0}
local pink={r=1,g=0.7,b=0.8}
local purple={r=1,g=0,b=1}
local red={r=1,g=0,b=0}
local white={r=1,g=1, b=1}
local yellow={r=1,g=1,b=0}

-- chosen color
local CHOSEN_COLOR = green

--DLCID
-- index: string
--		name of the NPC or object that gives the quest
--	value: int
--		arbirary ID number 
local DLCID= {
	["Amelie Crowe"]						=	1,
	["Alessio Guillon"]						=	2,
	["Anais Davaux"]						=	3,
	["Concordia Mercius"]					=	4,
	["Gwendis"]								=	5,
	["Hinzuur"]								=	6,
	["Jakarn"]								=	7,
	["Order of the Eye Dispatch"]			=	8,
	["Quen"]								=	9,
	["Rhea Opacarius"]						= 	10,
	["Rogatina Cinna"]						=	11,
	["Rogatus Cinna"]						=	12,
	["Scout Gunthe"]						=	13,
	["Star-Gazer Herald"]					=	14,
	["Stuga"]								=	15,
	["Vanus Galerion"]						=	16,
	["Sorinne Gaerard"]						=	17,
	["Brahgas"]								=	18,
	["Lyris Titanborn"]						=	19,
	["House Ravenwatch Contract"]			=	20,
	["Cyrodilic Collections Needs You!"]	=	21,
	["Druid Laurel"]						=	22,
	["Eldrasea Deras"]						=	23,
	["Lilatha"]								=	24,
	["Verita Numida"]						=	25,
	["Abnur Tharn"]							=	26,
	["Leramil the Wise"]					=	27,
}

--DLCQuestInfo
-- index:int
--			id # from https://en.uesp.net/wiki/
--			ex :https://en.uesp.net/wiki/Online:The_Ravenwatch_Inquiry
--	value: table
--			[1]: string
--				Quest Name
--			[2]: string
--				DLC name
--			[3]: string or nil
--				Additional Information
-- DLC Quest confirmation source:
-- https://en.uesp.net/wiki/Online:Prologue_Quests
local DLCQuestInfo = 
{
	[5538]	=	{"Voices in the Dark", "Dark Brotherhood", nil},
	[5935]	=	{"The Missing Prophecy", "Morrowind", "Alessio directs you to Rhea Opacarius"},
	[6299]	=	{"The Demon Weapon", "Elsweyr", "While active, this quest can interrupt the main quest. It must be completed or abandoned to fix the issue."},
	[6226]	= 	{"Ruthless Competition", "Murkmire", "Ruthless Competition & The Cursed Skull will unlock the Cyrodilic Collections dailies.\nZone: Shadowfen"},
	[4903]	=	{"Dream-Walk Into Darkness", "Markarth" ,nil},
	[6395]	=	{"The Dragonguard's Legacy", "Dragonhold", nil},
	[6751]	=	{"Ascending Doubt", "High Isle", nil},
	[6023]	=	{"Of Knives and Long Shadows", "Mournhold",nil},
	[5531]	=	{"Partners in Crime", "Thieves Guild", nil},
	[6701]	=	{"An Apocalyptic Situation", "Deadlands",nil},
	[6612]	=	{"A Mortal's Touch", "Blackwood", nil},
	[6454]	=	{"The Coven Conspiracy", "Greymore", "Zone: Eastmarch"},
	[5033]	=	{"The Star-Gazers", "Craglorn", "Zone: Craglorn"},
	[5450]	=	{"Invitation to Orsinium", "Orsinium", "Zone: Wrothgar"},
	[6097]	=	{"Through a Veil Darkly", "Summerset", nil},
	[6799]	=	{"Tales of Tribute", "High Isle", "Introduction to the Tales of Tribute card game", nil},
	[6549]	=	{"The Ravenwatch Inquiry", "Markath", "The contract directs you to Gwendis."},
	[6843]	=	{"Sojourn of the Druid King", "Firesong", nil},
	[6761]	=	{"A King's Retreat", "High Isle", nil},
	[6050]	=	{"To the Clockwork City", "The Clockwork City", nil},
	[6514]	=	{"The Antiquarian Circle", "Western Skyrim", "Scrying skill line & Excavation skill line"},
	[1]		=	{"Eye of Fate", "Necrom", nil}, -- 1 is a placeholder till the actual ID gets put on the eso site
}
--DLCFolkComplete
--	type: table
--		index: int
--			NPC ID
--		value: int
--			Quest ID
-- union table matching NPC with Quest ID
local DLCFolkComplete = {
	[1]		=	5538,
	[2]		=	5935,
	[3]		=	6299,
	[4]		=	6226,
	[5]		=	4903,
	[6]		=	6395,
	[7]		=	6751,
	[8]		=	6023,
	[9]		=	5531,
	[10]	= 	5935,
	[11]	= 	6701,
	[12]	= 	6612,
	[13]	= 	6454,
	[14]	=	5033,
	[15]	=	5450,
	[16]	=	6097,
	[17]	=	6799,
	[18]	=	6799,
	[19]	=	6454,
	[20]	=	6549,
	[21]	=	6226,
	[22]	=	6843,
	[23]	=	6050,
	[24]	= 	6050,
	[25]	=	6514,
	[26]	=	6299,
	[27]	=	1,
}


--test_location
--	type: table
--		index:int
--			NPC ID
--		value: table
--			index: int
--				zone ID
--				[1]: int
--					NPC rounded X cooridinates
--				[2]: int
--					NPC rounded Y cooridinates
--				[3]: int
--						NPC rounded Z cooridinates
-- Better way than referenceing a map.
-- makes use of GetUnitRawWorldPosition('player')
-- which returns zone,x,y,z 
local DLCNotice_test_location =
{
	[7] =  --Jakarn
	{
		[383] =
		{
			-- Elden Root, Aldmeri Dominion, just inside Atlmer Embassy NE gate
			['x'] = 236000,
			['y'] = 12800,
			['z'] = 21800,
		},
		[19] =
		{
			-- Wayrest, Daggerall Covenant, SE of wayshrine in town
			['x'] = 247000,
			['y'] = 14000,
			['z'] = 244000,
		},
		[57] =
		{
			-- Mournhold, Ebonheart Pact, outside of the SE gate
			['x'] = 233000,
			['y'] = 12000,
			['z'] = 251000,
		},
	}, -- end Jakarn
	[19] = --Lyris Titanborn
	{
		[381] = --Vulkhel Guard Fighters Guild, Aldmeri Dominion
		{
			['x'] = 207000,
			['y'] = 3000,
			['z'] = 411000,
		},
		[3] = --Daggerfall Fighters Guild, Daggerall Covenant
		{
			['x'] = 106000,
			['y'] = 8000,
			['z'] = 307000,
		},
		[41] = --Davons Watch Fighters Guild Bottom floor, Ebonheart Pact
		{
			['x'] = 375000,
			['y'] = 10300,
			['z'] = 174000,
		},
	},	-- end Lyris Titanborn
	[26] = --Abnur Tharn
	{
		[381] = -- Vulkhel Guard Treasury, Aldmeri Dominion
		{
			['x'] = 229000,
			['y'] = 5000,
			['z'] = 394000,
		},
		[3] = -- Daggerfall Castle, Daggerall Covenant
		{
			['x'] = 88000,
			['y'] = 2000,
			['z'] = 319000,
		},
		[41] = -- Davon's Watch Mage Guild, Ebonheart Pact
		{
			['x'] = 356000,
			['y'] = 5000,
			['z'] = 170000,
		},
	},-- end Abnur Tharn
	[16] =  -- Vanus Galerion is a part of the quest "Messages Across Tamriel"
	{
		[381] = --Vulkhel Guard, Mages Guild main floor
		{
			['x'] = 214000,
			['y'] = 4000,
			['z'] = 404000,
		},
		[383] = --Elden Root main floor, Aldmeri Dominion
		{
			['x'] = 337000,
			['y'] = 12000,
			['z'] = 218000,
		},
		[3] = -- Daggerfall Castle, Daggerall Covenant
		{
			['x'] = 101000,
			['y'] = 9000,
			['z'] = 312000,
		},
		[41] = -- Davon's Watch Mages Guild top floor, Ebonheart Pact
		{
			['x'] = 356000,
			['y'] = 5000,
			['z'] = 166000,
		},
	}
}
----------------------------------------------------------------------------------------------------------------------
-- CheckIfNPCIsReused(_id)
-- parameters
-- _id : int
--		NPC ID
-- returns:
--	bool
--   Determines if this NPC is one we're tracking 
--   that appears in multiple locations apart from
--   the point they give the DLC quest
function DLCNotice.CheckIfNPCIsResused(_id)
	--make sure the passed value exists and is the expected type
	if _id == nil or type(_id) ~= 'number' then return false end
	-- check to see if the npc is one we're tracking
	if DLCNotice_test_location[_id] ~= nil then
		--get the players position
		local t_zone, t_x, t_y, t_z = GetUnitRawWorldPosition('player')
		--check if we're in the right zone 
		if DLCNotice_test_location[_id][t_zone] ~= nil then
			--make sure test_location[_id][t_zone] is a populated array
			if #DLCNotice_test_location == 0 then return end
			-- make sure we're withing 10000 units of the NPC
			local check_x = math.abs(t_x - DLCNotice_test_location[_id][t_zone]['x']) or 4000
			local check_y = math.abs(t_y - DLCNotice_test_location[_id][t_zone]['y']) or 4000
			local check_z = math.abs(t_z - DLCNotice_test_location[_id][t_zone]['z']) or 4000
			-- emperical tests imply the reticle doesn't trigger when individual coords 
			-- are greater than 1000 units so the total value will be less than 3000
			local total_check = check_x + check_y + check_z
			if total_check < 3000 then
				return true
			end  --end if total_check < 3000 then
		end -- end if test_location[_id][t_zone] ~= nil then
	end --end if test_location[_id] ~= nil then
	return false
end
----------------------------------------------------------------------------------------------------------------------
--DLCNotice_HideControl(nil)
-- parameters
--	none
-- returns:
--	nothing
--	Local function to hide the XML Defined control for this addon
function DLCNotice.HideControl()
	-- since there's more than one control now, 
	-- a loop improves functionality and readability
	-- Define the array with the control names as the values
	local control_names = {"DLCNoticeControlName", "DLCNoticeControlNameAI"}
	-- loop
	for i = 1, #control_names,1
	do 
		-- get the indexed control name
		local label = GetControl(control_names[i]) or nil
		--if it isn't nil then party on
		if label ~= nil then
			--hide the control
			label:SetHidden(true)
			-- clear the text
			label:SetText("")
		end
	end
end
----------------------------------------------------------------------------------------------------------------------
--DLCNotice_ShowControl(text, additional_text)
--parameters
-- text: string
-- 		the text to put in the label
--	additional_text
--	type: string
--		if there are additional notes, pass them to the second label
-- return:
--	nothing
function DLCNotice.ShowControl(text, additional_text)
	-- get the control by name.  Control Names is defined in the XML. If you 
	-- use $(parent)X then the name concantenates the child name to the parent name.
	-- havent tried to explicitly define a control name (name = NAME).
	-- Example: TopLevelControl name = DLCNoticeControl, first defined control name = $(parent)Name
	-- control name = DLCNoticeControlName
	
	local font ={nil, "EsoUI/Common/Fonts/Univers57.otf|24|soft-shadow-thin"}
	local control_names = {"DLCNoticeControlName", "DLCNoticeControlNameAI"}
	local _text = {text, additional_text}
	-- loop
	for i = 1, #control_names,1
	do 
		-- get the indexed control name
		local label = GetControl(control_names[i]) or nil
		--if it isn't nil then party on
		if label ~= nil then
			label:SetColor(CHOSEN_COLOR["r"],CHOSEN_COLOR["g"],CHOSEN_COLOR["b"])
			if font[i] ~= nil then label:SetFont(_font) end
			label:SetText(_text[i])
			label:SetHidden(false)
		end
	end
end--local function DLCNotice_ShowControl(text, additional_text)

----------------------------------------------------------------------------------------------------------------------
--CheckQuestIsInJournal(_quest_name)
--parameters
-- _quest_name: string
-- 		Name of the quest
-- return:
--	bool
-- compares quest name to journal quest list
function DLCNotice.CheckQuestIsInJournal(_quest_name)
	--https://wiki.esoui.com/Category:API_functions
	-- GetNumJournalQuests()
	--  Returns:_ *integer* _numQuests_
	local count = GetNumJournalQuests()
	if count > 0 then
		for i = 1, count
		do
			--GetJournalQuestName(*luaindex* _journalQuestIndex_)
			--	Returns:_ *string* _questName_
			local name = GetJournalQuestName(i)
			if name == _quest_name then return true end
		end -- end for loop
	end --if count > 0 then
	return false
end-- CheckQuestIsInJournal(_quest_name)
----------------------------------------------------------------------------------------------------------------------
--ReticleOnUpdate(name)
--parameters
-- name
--   type: string
-- 		NPC Name passed from GetGameCameraInteractableActionInfo
--		GetGameCameraInteractableActionInfo https://wiki.esoui.com/API/GetGameCameraInteractableActionInfo
-- return:
--	nothing
function DLCNotice.ReticleOnUpdate(name)
	--hide the labels
	DLCNotice.HideControl()
	-- make sure there is actually a name in the reticle.
	name = name or ""
	if string.len(name) == 0 then return end
	--id is used to reference the character in the reticle in the above arrays
	-- surely there has to be a way to pull the ID from the system vs hardcoding an array but 
	-- I dont know it and the API readme isn't exactly user friendly.
	-- "or nil" sets a default to nil if the array value is missing
	local id = DLCID[name] or nil
	--make sure it's there
	if id == nil then return end
	--get the quest ID associated with this NPC
	local quest_id = DLCFolkComplete[id] or nil
	--make sure it's there
	if quest_id == nil then return end
	
	-- determine if this is an NPC that appears
	-- seperate from the quest giver role
	-- test_location[id] ~= nil checks if the table index exists
	-- CheckIfNPCIsResused checks if the location is correct
	if (DLCNotice_test_location[id] ~= nil) then
		if DLCNotice.CheckIfNPCIsResused(id) == false then return end
		-- if its Vanus AND we're on the quest "Messages Across Tamiel" then we need 
		-- to just exit because he's a part of that quest and is in the same locations as 
		-- the version that gives the DLC prologue
		if DLCNotice.CheckQuestIsInJournal("Messages Across Tamriel") then return end
	end 
	--set up some readable references
	local QUEST_TITLE = 1
	local QUEST_LOCATION = 2
	local  ADDITIONAL_NOTES = 3
	--set up the message to be displayed
	local s_message = ""
	
	--get the quest information by the quest ID index
	-- or nil here sets a default in case there's an index error
	local daPlaneBoss = DLCQuestInfo[quest_id] or nil
	if daPlaneBoss == nil then return end
	
	--define local variables that can be changed in function
	--vs changing the array data'
	-- using "or nil" to set defaults in case the arrays are not 
	-- formed using all 3 indexes
	local quest_title = daPlaneBoss[QUEST_TITLE] or nil
	local dlc_location = daPlaneBoss[QUEST_LOCATION] or nil
	local dlc_additional_info = daPlaneBoss[ADDITIONAL_NOTES] or nil

	--make sure the 2 portions that need to be there are there.
	if quest_title == nil or string.len(quest_title) == 0 then return end
	if dlc_location == nil or string.len(dlc_location) == 0 then return end
	
	--set the potential message to be displayed
	s_message = name .. " gives " .. daPlaneBoss[QUEST_TITLE] .. " and launches the " .. dlc_location .. " DLC"	
	
	-- check if the quest id is in the completed list or the current quest list
	--https://wiki.esoui.com/Category:Quest_functions
	--GetCompletedQuestInfo(questId)
	-- _Returns:_ *string* _name_, *[QuestType|#QuestType]* _questType_
	-- Have we already completed this quest?
	-- defining multiple variables inline is the same as assigning the array value at the index of the variable.
	-- local x, y, z is the same as x=ary[1], y = ary[2], z = ary[3] where _ is used to ignore the value at that index
	local completed_quest_name,_ = GetCompletedQuestInfo(quest_id)
	-- if there is a return value, the quest has already been completed so exit
	if string.len(completed_quest_name) > 0 then return end
	
	if DLCNotice.CheckQuestIsInJournal(daPlaneBoss[QUEST_TITLE]) then
		s_message = ""
		dlc_additional_info = daPlaneBoss[QUEST_TITLE] ..  " is in your journal"
	end 
	
	if dlc_additional_info ~= nil and string.len(dlc_additional_info) > 0 then 
		DLCNotice.ShowControl(s_message, dlc_additional_info)
	else
		DLCNotice.ShowControl(s_message)
	end
	return
end -- end function ReticleOnUpdate(v_self, v_time)

----------------------------------------------------------------------------------------------------------------------
function DLCNotice.OnAddOnLoaded(event, addonName)
	-- ZO_ReticleContainerInteract comes from the XML file esoui-8.3.5\esoui\ingame\reticle
	-- find it via <TopLevelControl name="ZO_ReticleContainer" hidden="true" tier="LOW" layer="BACKGROUND">
	-- GetGameCameraInteractableActionInfo https://wiki.esoui.com/API/GetGameCameraInteractableActionInfo
	-- Returns:_ *string:nilable* _action_, *string:nilable* _name_, *bool* _interactBlocked_, *bool* _isOwned_, *integer* _additionalInfo_, *integer:nilable* _contextualInfo_, *string:nilable* _contextualLink_, *bool* _isCriminalInteract_
	-- SetHandler: https://wiki.esoui.com/SetHandler
	--"On" handler options exposed by the API: https://wiki.esoui.com/UI_XML#OnAddGameData
	-- There was also a LOT of digging around in https://esoapi.uesp.net/current/src/, but that's
	-- only good after you know the parent class
	
	-- setup trigger to show text
	ZO_ReticleContainerInteract:SetHandler("OnShow", function()
		local action,interactableName,isBlocked = GetGameCameraInteractableActionInfo()
		if isBlocked then return end
		DLCNotice.ReticleOnUpdate(interactableName)
   end)
   --set up trigger to hide the window when the reticle fades
	ZO_ReticleContainerInteract:SetHandler(
		"OnHide",function()
		DLCNotice.HideControl()
		end)
	if addonName == DLCNotice.name then
		EVENT_MANAGER:UnregisterForEvent(DLCNotice.name, EVENT_ADD_ON_LOADED)
	end
end -- function DLCNotice.OnAddOnLoaded(event, addonName)
----------------------------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(DLCNotice.name, EVENT_ADD_ON_LOADED, DLCNotice.OnAddOnLoaded)
