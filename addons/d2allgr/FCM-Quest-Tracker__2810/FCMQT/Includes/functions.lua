
--[[

	GLOBALES FUNCTIONS

]]--
FCMQT = FCMQT or {}

-- General Buffer made by Wykkyd : http://wiki.esoui.com/Event_%26_Update_Buffering
-- Version : 1.5.5.25

-- *********************************************************************************************
-- * General Functions                                                                         *
-- *********************************************************************************************

local BufferTable = {}
local function BufferReached(key, buffer)
if key == nil then return end
	if BufferTable[key] == nil then BufferTable[key] = {} end
	BufferTable[key].buffer = buffer or 3
	BufferTable[key].now = GetFrameTimeSeconds()
	if BufferTable[key].last == nil then BufferTable[key].last = BufferTable[key].now end
	BufferTable[key].diff = BufferTable[key].now - BufferTable[key].last
	BufferTable[key].eval = BufferTable[key].diff >= BufferTable[key].buffer
	if BufferTable[key].eval then BufferTable[key].last = BufferTable[key].now end
	return BufferTable[key].eval
end

-- Convert a colour from "|cABCDEFG" form to [0,1] RGB form.
function ConvertHexToRGBA(colourString)
	local r=tonumber(string.sub(colourString, 3, 4), 16) or 255
	local g=tonumber(string.sub(colourString, 5, 6), 16) or 255
	local b=tonumber(string.sub(colourString, 7, 8), 16) or 255
	local a=tonumber(string.sub(colourString, 9, 10), 16) or 255
	return r/255, g/255, b/255, 1
end

-- Convert decimal number to Hex Equivalend (255 = FF)
function ConvertDecimalToHex(i)
	local deci = i*255
	local str = string.format("%x",deci)
	if deci == nil then str = "00" end
	if deci < 16 and not nil then str = "0"..str end
	return str
end
-- Apply colors to a string
function ApplyStringColorRGB(text, r,g,b)
	local string = ""
	local hexstring = ConvertDecimalToHex(r)..ConvertDecimalToHex(g)..ConvertDecimalToHex(b)
	string = "|c" .. hexstring .. text.. "|r"
	d(hexstring)
	return string
end

-- Print to Chat function, grabs as many argument pairs sent text, color, applies the color to the text with ApplyStringColorRGB, applies them to a string with same number of argument pairs (if you send two pairs then template needs <<x>> for both).
function PrintToChat(template, ...)
    local arg = {...}

    local textStrings = {}
    for _,x in pairs(arg) do
		table.insert(textStrings, ApplyChatColor(x.text, x.color))
    end
    local msg = zo_strformat(template, unpack(textStrings))
    --if(TI.GetShowTimestamp()) then
    --    chatString = string.format("[%s] ",GetTimeString()) .. chatString
    --end
    CHAT_SYSTEM:AddMessage(chatString)
end

-- Standard message
--function FCMQT.Msg(header,msg)
--	if FCMQT.Chat_AddonMessages == true then
--		if header == nil or msg == nil then
--			PrintToChat("

-- *********************************************************************************************
-- * FCMQT Specific Functions                                                                  *
-- *********************************************************************************************

-- Check menu witch are opened
function CheckMode()

	if FCMQT.main then
		local InteractiveMenuIsHidden = ZO_KeybindStripControl:IsHidden()
		local GameMenuIsHidden = ZO_GameMenu_InGame:IsHidden()
		local DialogueIsHidden = ZO_InteractWindow:IsHidden()
		local JournalIsHidden = ZO_QuestJournal:IsHidden()
		local HideInCombat = true
		
		--checks for craft store
		ZO_FocusedQuestTrackerPanel:SetHidden(true)
		--FCMQT.main:SetHidden(false) end

		if CS then
			local CSRune_isHidden = true
			local CSCook_isHidden = true
			--d("CraftStore loaded.")
			CSRune_isHidden = CraftStoreFixed_Rune:IsHidden()
			CSCook_isHidden = CraftStoreFixed_Cook:IsHidden()
			
			if CSRune_isHidden == false or CSCook_isHidden == false then
				--FCMQT.bg:ToggleHidden()
				-- test cs is still working
				FCMQT.main:SetHidden(true)
			else
				--FCMQT.main:SetHidden(false)
				if InteractiveMenuIsHidden == true and GameMenuIsHidden == true and DialogueIsHidden == true then
					FCMQT.main:SetHidden(false)
					if IsUnitInCombat('player') and FCMQT.SavedVars.HideInCombatOption then FCMQT.main:SetHidden(true) else FCMQT.main:SetHidden(false) end
				elseif InteractiveMenuIsHidden == false or GameMenuIsHidden == false or DialogueIsHidden == false then
					FCMQT.main:SetHidden(true)
				end
			end
		else
			if InteractiveMenuIsHidden == true and GameMenuIsHidden == true and DialogueIsHidden == true then
				FCMQT.main:SetHidden(false)
				if IsUnitInCombat('player') and FCMQT.SavedVars.HideInCombatOption then FCMQT.main:SetHidden(true) else FCMQT.main:SetHidden(false) end
			elseif InteractiveMenuIsHidden == false or GameMenuIsHidden == false or DialogueIsHidden == false then
				FCMQT.main:SetHidden(true)
			end
		end
	end
end


function FCMQT.CombatState()
	local FCMQT_isHidden = FCMQT.main:IsHidden()
	
	if FCMQT_isHidden == false then
		if IsUnitInCombat('player') then
			FCMQT.main:SetHidden(true)
		else
			FCMQT.main:SetHidden(false)
		end
	end
end


function FindMyZone(dzone, dtype)
	--if dzone = nil or dzone = "" then zone = "Miscellaneous" else 
	zone = dzone
	--if FCMQT.QuestsHybridOption == true and FCMQT.QuestsAreaOption == true then
	if FCMQT.QuestsHybridOption == true then
		pzone = " - "..zone
		if dtype == QUEST_TYPE_AVA or dtype == QUEST_TYPE_AVA_GRAND or dtype == QUEST_TYPE_AVA_GROUP then
			zone = zone.." (AvA)"
		elseif dtype == QUEST_TYPE_GUILD then
			zone = FCMQT.mylanguage.lang_tracker_type_guild
		elseif dtype == QUEST_TYPE_MAIN_STORY then
			zone = FCMQT.mylanguage.lang_tracker_type_mainstory
		elseif dtype == QUEST_TYPE_CLASS and FCMQT.SavedVars.QuestsCategoryClassOption == true then
			zone = FCMQT.mylanguage.lang_tracker_type_class..pzone
		elseif dtype == QUEST_TYPE_CLASS and FCMQT.SavedVars.QuestsCategoryClassOption == false then
			zone = FCMQT.mylanguage.lang_tracker_type_class
		elseif dtype == QUEST_TYPE_CRAFTING then
			zone = FCMQT.mylanguage.lang_tracker_type_craft
		elseif dtype == QUEST_TYPE_GROUP and FCMQT.SavedVars.QuestsCategoryGroupOption == true then
			zone = FCMQT.mylanguage.lang_tracker_type_group..pzone
		elseif dtype == QUEST_TYPE_GROUP and FCMQT.SavedVars.QuestsCategoryGroupOption == false then
			zone = FCMQT.mylanguage.lang_tracker_type_group
		elseif dtype == QUEST_TYPE_DUNGEON and FCMQT.SavedVars.QuestsCategoryDungeonOption == true then
			zone = FCMQT.mylanguage.lang_tracker_type_dungeon..pzone
		elseif dtype == QUEST_TYPE_DUNGEON and FCMQT.SavedVars.QuestsCategoryDungeonOption == false then
			zone = FCMQT.mylanguage.lang_tracker_type_dungeon
		elseif dtype == QUEST_TYPE_RAID and FCMQT.SavedVars.QuestsCategoryRaidOption == true then
			zone = FCMQT.mylanguage.lang_tracker_type_raid..pzone
		elseif dtype == QUEST_TYPE_RAID and FCMQT.SavedVars.QuestsCategoryRaidOption == false then
			zone = FCMQT.mylanguage.lang_tracker_type_raid..pzone
		elseif dtype == QUEST_TYPE_BATTLEGROUND then
			zone = FCMQT.mylanguage.lang_tracker_type_bg..pzone
		elseif dtype == QUEST_TYPE_HOLIDAY_EVENT then
			zone = FCMQT.mylanguage.lang_tracker_type_holiday_event..pzone
		elseif dtype == QUEST_TYPE_QA_TEST then
			zone = zone.." (TEST)"
		end
		--d("dzone "..dzone.."    zone "..zone)
	end
	if dzone == "" and zone == "" then zone = FCMQT.mylanguage.lang_Miscellaneous end
	return zone
end

function FocusedQuestInfo()
	-- find the current focused quest
	for i=1,MAX_JOURNAL_QUESTS do
		local valQindex = GetTrackedIsAssisted(1,i,0)
		if valQindex == true then
			local fname, fbackgroundText, factiveStepText, factiveStepType, factiveStepTrackerOverrideText, fcompleted, ftracked, fqlevel, fpushed, fqtype = GetJournalQuestInfo(i)
			local fzone, fobjective, fzoneidx, fpoiIndex = GetJournalQuestLocationInfo(i)
			FCMQT.FocusedQIndex = i
			FCMQT.FocusedZone = fzone
			FCMQT.FocusedQName = fname
			FCMQT.FocusedZoneIdx = fzoneidx
			FCMQT.FocusedZonePoiIndx = fpoiIndex
			FCMQT.FocusedQType = fqtype
			FCMQT.FocusedMyZone = FindMyZone(fzone,fqtype)
			if FCMQT.FocusedMyZone == "" then d("FCMQT PROBLEM FocusedMyZone is empty") end
			if FCMQT.debug == 1 then
				d("*FOCUSED QUEST INFO******************************************")
				d("*    FocusedQIndex = "..FCMQT.FocusedQIndex)
				d("*    FocusedZone = "..FCMQT.FocusedZone)
				d("*    FocusedZoneIdx = "..FCMQT.FocusedZoneIdx)
				d("*    FocusedZonePoiIndx	= "..FCMQT.FocusedZonePoiIndx)
				d("*    FocusedQType = "..FCMQT.FocusedQType)
				d("*    FocusedMyZone = "..FCMQT.FocusedMyZone)
				d("********************************************")
			end
			break;
		end
	end
end


function CheckFocusedQuest()
	-- Check Focused Quest (check if an ESO element modified the current focused quest)
	local RecordedFocusedQuest = GetTrackedIsAssisted(1,FCMQT.currenticon,0)
	if RecordedFocusedQuest == false then
		for j=1, MAX_JOURNAL_QUESTS do
			if IsValidQuestIndex(j) then
				local CurrentFocusedQuest = GetTrackedIsAssisted(1,j,0)
				if CurrentFocusedQuest == true then
					if j ~= FCMQT.currenticon then
						FCMQT.currenticon = j
						FCMQT.QuestsListUpdate(1)
					end
				end
			end
		end
	end
end

function FCMQT.SetFocusedQuest(qindex)
	-- Update the focused quest if quest is added or updated
	local check = 0
	if qindex ~= nil then
		for i=1,MAX_JOURNAL_QUESTS do
			local valQindex = GetTrackedIsAssisted(1,i,0)
			if valQindex == true then
				if i == qindex then
					check = 1
				--***100022 REmove for 100023 START
				else
					SetTrackedIsAssisted(1,false,i,0)
				--***100022 REmove for 100023 END
				end
				break;
			end
		end
		if check == 0 then
			--***100023 - For 10023 START
			FOCUSED_QUEST_TRACKER:ForceAssist(qindex)
			FOCUSED_QUEST_TRACKER:InitialTrackingUpdate()
			FCMQT.currenticon = qindex
			FocusedQuestInfo()
			--d(" Focused "..FCMQT.FocusedQName)
			-- Check to see if Bandit UI is loaded, if so skip update.
			local noUpdate = false
			if BUI then noUpdate = true end
			if noUpdate == false then
				ZO_WorldMap_UpdateMap()
			end
		end
		-- Refresh Quests
		if FCMQT.QuestsHideZoneOption == true then
			AutoFilterZone()
		else
			FCMQT.QuestsListUpdate(1)
		end
	end
end

function ForcedFocusedQuest(qindex)
	-- Do a forced update to quest indicated.
	-- a 0 indicates to do a focusedquestinfo and force update what should be focused quest.
	local check = 0
	if qindex ~= nil then
		if qindex == 0 then
			FocusedQuestInfo()
			qindex = FCMQT.FocusedQIndex
		end
		if FCMQT.DEBUG == 4 then d("Forced Quest") end
		FOCUSED_QUEST_TRACKER:ForceAssist(qindex)
		FOCUSED_QUEST_TRACKER:InitialTrackingUpdate()
		FCMQT.currenticon = qindex
		FocusedQuestInfo()
		local noUpdate = false
		if BUI then noUpdate = true end
		if noUpdate == false then
			ZO_WorldMap_UpdateMap()
		end
		-- Refresh Quests
		--if FCMQT.QuestsHideZoneOption == true then
		--	AutoFilterZone()
		--else
		--	FCMQT.QuestsListUpdate(1)
		--end
	end
end



function FCMQT.CheckQuestsToHidden(qindex, qname, qtype, qzoneidx, valcheck)
	local QuestTracked = GetIsTracked(1,qindex,0)
	--[[if FCMQT.SavedVars.QuestsUntrackHiddenOption == true then
		--if((FCMQT.SavedVars.QuestsZoneGuildOption == false and qtype == 3) or (FCMQT.SavedVars.QuestsZoneMainOption == false and qtype == 2) or (FCMQT.SavedVars.QuestsZoneCyrodiilOption == false and qzoneidx == FCMQT.CyrodiilNumZoneIndex)) then
				-- Untrack Hidden Quests
				if QuestTracked == true then
					valcheck = 1
					SetTracked(1,false,qindex,0)
				end
		else
			if QuestTracked == false then
				valcheck = 1
				SetTracked(1,true,qindex,0)
			end			
		end
	else]]
		-- Track all others
		if QuestTracked == false then
			valcheck = 1
			SetTracked(1,true,qindex,0)
		end
	--end
	return valcheck
end

-- Quest to chat, need to improve output
function QuestToChat(i)
	local qname, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, qlevel, pushed, qtype = GetJournalQuestInfo(i)
	
	d("Selected Quest:  "..qname)
	d("Background:  "..backgroundText)
	d("Active Step:  "..activeStepText)
end

-- *********************************************************************************
-- * FilterZone Functions                                                          *
-- *********************************************************************************

-- Updates the quest/zone filter
function UpdateFilterZone(qzone)
	FocusedQuestInfo()
	--d("qzone "..qzone.."   FocusedMyZone "..FCMQT.FocusedMyZone)
	if not FCMQT.filterzone then FCMQT.filterzone = {} end
	local tmpfilterzone = {}
	local tmp = 0
	if FCMQT.filterzone[1] then
		local i=1
		while FCMQT.filterzone[i] do
			--if FCMQT.filterzone[i] == qzone or FCMQT.FocusedMyZone == qzone then
			if FCMQT.filterzone[i] == qzone then
				tmp = 1
			else
				table.insert(tmpfilterzone, FCMQT.filterzone[i])
			end
			i = i+1
		end
		--if tmp ~= 1 and FCMQT.FocusedMyZone ~= qzone then
		if tmp ~= 1 then
			table.insert(tmpfilterzone, qzone)
		end
	else
		--if FCMQT.FocusedMyZone ~= qzone then 
			table.insert(tmpfilterzone, qzone)
		--end
	end
	FCMQT.filterzone = tmpfilterzone
	FCMQT.SavedVars.QuestsFilter = tmpfilterzone
	--if FCMQT.FocusedMyZone == qzone then d("FCMQT Message: Cannot filter/collapse zone with focused quest.") end
end

-- FilterZone Clean - Removing the fucused zone from list
function CleanFilterZone()
	FocusedQuestInfo()
	if not FCMQT.filterzone then FCMQT.filterzone = {} end
	if FCMQT.filterzone[1] then
		local tmpfilterzone = {}
		local tmp = 0
		local i=1
		while FCMQT.filterzone[i] do
			if FCMQT.filterzone[i] == FCMQT.FocusedMyZone then
				tmp = 1
				--d("Removed Filter Zone : "..FCMQT.filterzone[i])
			else
				table.insert(tmpfilterzone, FCMQT.filterzone[i])
			end
			i = i+1
		end
		FCMQT.filterzone = tmpfilterzone
		FCMQT.SavedVars.QuestsFilter = tmpfilterzone
	end
end

-- function to remove filterzone, clear it compeltely output
function RemoveFilterZone()
	FCMQT.filterzone = {}
	--d(FCMQT.filterzone[1])
	FCMQT.SavedVars.QuestsFilter = FCMQT.filterzone
	FCMQT.QuestsListUpdate(1)
end

-- Filterzone Auto - Adds all zones excelpt filtered
function AutoFilterZone()
	-- Grab Focused Quest Information, will skip zone for focused Qeust
	FocusedQuestInfo()
	-- Set vars, clearing filter zone
	FCMQT.filterzone = {}
	local tmpfilterzone = {}
	local i = 1
	local myzone = ""
	local x=1
	local done = 0
	local tmp = 0
	-- Run through quests in Journal, need quest type, zone to get myzone
	-- quest loop for x
	for x=1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(x) then
			-- gather quest info need qzone and qtype
			local qname, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, qlevel, pushed, qtype = GetJournalQuestInfo(x)
			local qzone, qobjective, qzoneidx, poiIndex = GetJournalQuestLocationInfo(x)
			-- find my zone
			myzone = FindMyZone(qzone,qtype)
			--d("qname "..qname.."----myzone ".. myzone.."----qzone "..qzone.."----qtype "..qtype)
			-- Set Vars for loop
			i = 1
			tmp = 0
			-- loop thorugh filterzone{} first check to see if first record is there
			if FCMQT.filterzone[i] then
				-- if first record exists, then loops through filterzone{}
				while FCMQT.filterzone[i] do
					-- checks if myzone is in filterzone{} or is focusedzone... if so set tmp =1
					if FCMQT.filterzone[i] == myzone or myzone == FCMQT.FocusedMyZone then
						tmp = 1
					end
					-- While loop increment
					i = i+1
				end
				-- if tmp still 0 then add to table tmpfilterzone{}
				if tmp ~= 1 then
					table.insert(tmpfilterzone, myzone)
				end
			else
				-- if first record does not exist, then check to see if it focused and if not add it
				if FCMQT.FocusedMyZone ~= myzone then
					table.insert(tmpfilterzone, myzone)
				end
			end
		-- quest loop for x end/loop
		end
	-- End for x loop
	-- save tmpfilterzone{} to filerzone{} and SavedVars
		FCMQT.filterzone = tmpfilterzone
		FCMQT.SavedVars.QuestsFilter = tmpfilterzone
	end
	-- save tmpfilterzone{} to filerzone{} and SavedVars MOved up to where it was....was working then....

	-- if filterzone{} is not empty then do a questlistupdate to update the tracker
	if FCMQT.filterzone[1] then
		--d("AutoFilterZone doing QuestUpdate")
		FCMQT.QuestsListUpdate(1)
	end
-- end function
end

--Switch Display Mode
function FCMQT.SwitchDisplayMode()
	FCMQT.SavedVars.QuestsZoneOption = not FCMQT.SavedVars.QuestsZoneOption
	FCMQT.QuestsListUpdate(1)
end

-- Remove Quest Message Box
function FCMQT.CheckRemoveQuestBox(qindex, qname)
	if not FCMQT.PlayerRemoveQuestBox then
		local WM = WINDOW_MANAGER
		local LMP = LibMediaProvider
		FCMQT.MainRemoveQuestBox = WM:CreateTopLevelWindow(nil)
		FCMQT.MainRemoveQuestBox:SetAnchor(CENTER,GuiRoot,CENTER,0,-100)
		FCMQT.MainRemoveQuestBox:SetDimensions(400,100)
		FCMQT.MainRemoveQuestBox:SetMovable(false)
		FCMQT.MainRemoveQuestBox:SetDrawLayer(2)
		
		FCMQT.PlayerRemoveQuestBox = WM:CreateControl(nil, FCMQT.MainRemoveQuestBox, CT_STATUSBAR)
		FCMQT.PlayerRemoveQuestBox:SetAnchorFill()
		FCMQT.PlayerRemoveQuestBox:SetDrawLayer(2)
		FCMQT.PlayerRemoveQuestBox:SetColor(0,0,0,0.4)
		
		FCMQT.PlayerRemoveLabelQuestBox = WM:CreateControl(nil, FCMQT.PlayerRemoveQuestBox, CT_LABEL)
		FCMQT.PlayerRemoveLabelQuestBox:SetAnchor(CENTER, FCMQT.MainRemoveQuestBox, CENTER, 0, -25)
		FCMQT.PlayerRemoveLabelQuestBox:SetDrawLayer(3)
		FCMQT.PlayerRemoveLabelQuestBox:SetFont(("%s|%s|%s"):format(LMP:Fetch('font', FCMQT.SavedVars.QuestsAreaFont), 18, FCMQT.SavedVars.QuestsAreaStyle))
		FCMQT.PlayerRemoveLabelQuestBox:SetColor(FCMQT.SavedVars.QuestsAreaColor.r, FCMQT.SavedVars.QuestsAreaColor.g, FCMQT.SavedVars.QuestsAreaColor.b, FCMQT.SavedVars.QuestsAreaColor.a)
		FCMQT.PlayerRemoveLabelQuestBox:SetText("Do you really want to remove this quest ?")
		
		FCMQT.PlayerRemoveLabelQuestBox2 = WM:CreateControl(nil, FCMQT.PlayerRemoveQuestBox, CT_LABEL)
		FCMQT.PlayerRemoveLabelQuestBox2:SetAnchor(CENTER, FCMQT.MainRemoveQuestBox, CENTER, 0, 10)
		FCMQT.PlayerRemoveLabelQuestBox2:SetDrawLayer(3)
		FCMQT.PlayerRemoveLabelQuestBox2:SetFont(("%s|%s|%s"):format(LMP:Fetch('font', FCMQT.SavedVars.QuestsAreaFont), 18, FCMQT.SavedVars.QuestsAreaStyle))
		FCMQT.PlayerRemoveLabelQuestBox2:SetColor(FCMQT.SavedVars.QuestsAreaColor.r, FCMQT.SavedVars.QuestsAreaColor.g, FCMQT.SavedVars.QuestsAreaColor.b, FCMQT.SavedVars.QuestsAreaColor.a)

		FCMQT.RemoveQuestBoxYes = WM:CreateControl(nil, FCMQT.PlayerRemoveQuestBox, CT_LABEL)
		FCMQT.RemoveQuestBoxYes:SetAnchor(TOPLEFT, FCMQT.MainRemoveQuestBox, BOTTOMLEFT, 10, 0)
		FCMQT.RemoveQuestBoxYes:SetDrawLayer(3)
		FCMQT.RemoveQuestBoxYes:SetFont(("%s|%s|%s"):format(LMP:Fetch('font', FCMQT.SavedVars.QuestsAreaFont), FCMQT.SavedVars.QuestsAreaSize, FCMQT.SavedVars.QuestsAreaStyle))
		FCMQT.RemoveQuestBoxYes:SetText("Yes")
		FCMQT.RemoveQuestBoxYes:SetColor(FCMQT.SavedVars.QuestsAreaColor.r, FCMQT.SavedVars.QuestsAreaColor.g, FCMQT.SavedVars.QuestsAreaColor.b, FCMQT.SavedVars.QuestsAreaColor.a)
		FCMQT.RemoveQuestBoxYes:SetMouseEnabled(true)
		FCMQT.RemoveQuestBoxYes:SetHandler("OnMouseEnter", function(self) self:SetColor(1,1,1,1)	end)
		FCMQT.RemoveQuestBoxYes:SetHandler("OnMouseExit", function(self) self:SetColor(FCMQT.SavedVars.QuestsAreaColor.r, FCMQT.SavedVars.QuestsAreaColor.g, FCMQT.SavedVars.QuestsAreaColor.b, FCMQT.SavedVars.QuestsAreaColor.a) end)
		
		FCMQT.RemoveQuestBoxNo = WM:CreateControl(nil, FCMQT.PlayerRemoveQuestBox, CT_LABEL)
		FCMQT.RemoveQuestBoxNo:SetAnchor(TOPRIGHT, FCMQT.MainRemoveQuestBox, BOTTOMRIGHT, -10, 0)
		FCMQT.RemoveQuestBoxNo:SetDrawLayer(3)
		FCMQT.RemoveQuestBoxNo:SetFont(("%s|%s|%s"):format(LMP:Fetch('font', FCMQT.SavedVars.QuestsAreaFont), FCMQT.SavedVars.QuestsAreaSize, FCMQT.SavedVars.QuestsAreaStyle))
		FCMQT.RemoveQuestBoxNo:SetText("No")
		FCMQT.RemoveQuestBoxNo:SetColor(FCMQT.SavedVars.QuestsAreaColor.r, FCMQT.SavedVars.QuestsAreaColor.g, FCMQT.SavedVars.QuestsAreaColor.b, FCMQT.SavedVars.QuestsAreaColor.a)
		FCMQT.RemoveQuestBoxNo:SetMouseEnabled(true)
		FCMQT.RemoveQuestBoxNo:SetHandler("OnMouseEnter", function(self) self:SetColor(1,1,1,1) end)
		FCMQT.RemoveQuestBoxNo:SetHandler("OnMouseExit", function(self) self:SetColor(FCMQT.SavedVars.QuestsAreaColor.r, FCMQT.SavedVars.QuestsAreaColor.g, FCMQT.SavedVars.QuestsAreaColor.b, FCMQT.SavedVars.QuestsAreaColor.a) end)
		FCMQT.RemoveQuestBoxNo:SetHandler("OnMouseDown", function(self) FCMQT.MainRemoveQuestBox:SetHidden(true) end)
	else
		FCMQT.MainRemoveQuestBox:SetHidden(false)
	end
	FCMQT.PlayerRemoveLabelQuestBox2:SetText(qname)
	FCMQT.RemoveQuestBoxYes:SetHandler("OnMouseDown", function()
			AbandonQuest(qindex)
			d(FCMQT.mylanguage.lang_console_abandon.." : "..qname)
			FCMQT.MainRemoveQuestBox:SetHidden(true)			
	end)
	
end


function FCMQT.ClearBoxs(clearid)
	local clearidx = clearid
	while FCMQT.textbox[clearidx] do
		FCMQT.textbox[clearidx]:SetText("")
		FCMQT.textbox[clearidx]:SetHandler("OnMouseDown", nil)
		FCMQT.textbox[clearidx]:SetMouseEnabled(false)
		FCMQT.icon[clearidx]:SetHidden(true)
		clearidx = clearidx + 1
	end
end

function FCMQT.ClearQTimer(isVisible)
	FCMQT.boxqtimer:SetText("")
	FCMQT.boxqtimer:SetHandler("OnMouseDown", nil)
	FCMQT.boxqtimer:SetMouseEnabled(false)
	FCMQT.boxqtimer:SetHidden(isVisible)
end

--*********************************************************************************
--* Keybinds/Toggles                                                              *
--*********************************************************************************

-- For Toggle tracker is hidden
function FCMQT.ToggleHidden()
	FCMQT.bg:ToggleHidden()
end

--zone/area enabled
function FCMQT.ToggleZones()
	if FCMQT.QuestsAreaOption == true then 
		FCMQT.QuestsAreaOption = false
		local mesg = "FCMQT Message - Not displaying Zone/Category names."
		local r = 10/255
		local g = 255/255
		local b = 150/255
		local a = 255/255
		
		mesg = ApplyStringColorRGBA(mesg,r,g,b)
		
		d(mesg)
	else
		FCMQT.QuestsAreaOption =  true
		d("FCMQT Message - Displaying Zone/Category names.")
	end
	FCMQT.QuestsListUpdate(1)
end

--zone/area hybrid/pure zone
function FCMQT.ToggleHybrid()
	if FCMQT.QuestsHybridOption == true then 
		FCMQT.QuestsHybridOption = false
		d("FCMQT Message - View is set to Zone View.")
	else
		FCMQT.QuestsHybridOption = true
		d("FCMQT Message - View is set to Category View.")
	end
	FCMQT.QuestsListUpdate(1)
	if FCMQT.QuestsHideZoneOption == true then AutoFilterZone() else FCMQT.QuestsListUpdate(1) end
	end

--enable auto hide zone
function FCMQT.ToggleAutoHideZones()
	if FCMQT.QuestsHideZoneOption == true then 
		FCMQT.QuestsHideZoneOption = false
		RemoveFilterZone()
		local mesg = "FCMQT Message - Auto Hide Zones turned off, Zone/Category Filter removed."
		--local r = 10/255
		--local g = 255/255
		--local b = 150/255
		--local a = 255/255
		
		--mesg = ApplyStringColorRGBA(mesg,r,g,b,a)
		
		d(mesg)
	else
		FCMQT.QuestsHideZoneOption = true
		d("FCMQT Message - Auto Hide Zones turned on.")
		AutoFilterZone()
	end
end

-- Toggle Set Hide Object/Hints EXCEPT when focused
function FCMQT.SetToggleHideObjExceptFocused(newOpt)
	FCMQT.HideObjOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

--Hide Object/Hints EXCEPT when focused
function FCMQT.ToggleHideObjExceptFocused()
	if FCMQT.HideObjOption == "Disabled" then
		FCMQT.HideObjOption = "Focused Quest"
		d("FCMQT Message - Toggled Objectives/Hints to show only for Focused Quest")
	elseif FCMQT.HideObjOption == "Focused Quest" then
		FCMQT.HideObjOption = "Focused Zone"
		d("FCMQT Message - Toggled Objectives/Hints to show only for Focused Zone/Category")
	elseif FCMQT.HideObjOption == "Focused Zone" then
		FCMQT.HideObjOption = "Disabled"
		d("FCMQT Message - Toggled Objectives/Hints to show for all quests.")
	end
	FCMQT.QuestsListUpdate(1)
end



--Enable Transparency for Not Focused Quests
function FCMQT.ToggleQuestsNoFocusOption()
	if FCMQT.QuestsNoFocusOption == true then 
		FCMQT.QuestsNoFocusOption = false
		d("FCMQT Message - Disabled Transparency for Not Focused Quests.")
	else
		FCMQT.QuestsNoFocusOption = true
		d("FCMQT Message - Enabled Transparency for Not Focused Quests.")
	end
	FCMQT.QuestsListUpdate(1)
end

	--Focused Quest Zone Not Transparent
function FCMQT.ToggleFocusedQuestAreaNoTrans()
	if FCMQT.FocusedQuestAreaNoTrans == true then 
		FCMQT.FocusedQuestAreaNoTrans = false
		d("FCMQT Message - Disabled Transparency for Focused Zone.")
	else
		FCMQT.FocusedQuestAreaNoTrans = true
		d("FCMQT Message - Enabled Transparency for Focused Zone.")
	end
	FCMQT.QuestsListUpdate(1)
end

--Hide Optional/Hidden Quest Info/Hints ALL
function FCMQT.ToggleHideInfoHintsOption()
	if FCMQT.HideInfoHintsOption == true then 
		FCMQT.HideInfoHintsOption = false
		d("FCMQT Message - Disabled Hints and Hidden information.")
	else
		FCMQT.HideInfoHintsOption = true
		d("FCMQT Message - Enabled Hints and Hidden information.")
	end
	FCMQT.QuestsListUpdate(1)
end

--*********************************************************************************
--* Console/Slash Command                                                         *
--*********************************************************************************

function FCMQT.CMD_DEBUG1()
	if FCMQT.DEBUG ~= 1 then
		d("FCMQT Debug1 : On")
		FCMQT.DEBUG = 1
	else
		d("FCMQT Debug : Off")
		FCMQT.DEBUG = 0
	end
end
function FCMQT.CMD_DEBUG2()
	if FCMQT.DEBUG ~= 2 then
		d("FCMQT Debug2 : On")
		FCMQT.DEBUG = 2
	else
		d("FCMQT Debug : Off")
		FCMQT.DEBUG = 0
	end
end
function FCMQT.CMD_DEBUG3()
	if FCMQT.DEBUG ~= 3 then
		d("FCMQT Debug3 : On")
		FCMQT.DEBUG = 3
	else
		d("FCMQT Debug : Off")
		FCMQT.DEBUG = 0
	end
end
function FCMQT.CMD_DEBUG4()
	if FCMQT.DEBUG ~= 4 then
		d("FCMQT Debug4 : On")
		FCMQT.DEBUG = 4
	else
		d("FCMQT Debug : Off")
		FCMQT.DEBUG = 0
	end
end

function FCMQT.CMD_Position()
	FCMQT.SetPositionLockOption (false)
	FCMQT.main:ClearAnchors()
	FCMQT.main:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200, 200)
	d("FCMQT Tracker reset to be visible!  Tracker is unlocked, position and be sure to lock otherwise you will not be able to select quests with mouse!")
end

function FCMQT.CMD_ToggleLock()
	if FCMQT.SavedVars.PositionLockOption == true then
	FCMQT.SetPositionLockOption(false)
	d("Tracker Position Unlocked")
else
	FCMQT.SetPositionLockOption(true)
	d("Tracker Position Locked")
end
end

--*********************************************************************************
--* Get/Set Commands                                                              *
--*********************************************************************************

-- Get/Set Language
function FCMQT.GetLanguage()
	return FCMQT.SavedVars.Language
end

function FCMQT.SetLanguage(newLang)
	FCMQT.SavedVars.Language = newLang
	ReloadUI()
end


--Get/Set Preset
function FCMQT.GetPreset()
	return FCMQT.SavedVars.Preset
	
end

function FCMQT.SetPreset(newPreset)
	FCMQT.SavedVars.Preset = newPreset
	local tmpPositionLock = FCMQT.GetPositionLockOption()
	if newPreset == "Default" then
					FCMQT.SavedVars.AutoAcceptSharedQuests = FCMQT.defaults.AutoAcceptSharedQuests
					FCMQT.SavedVars.AutoRefuseSharedQuests = FCMQT.defaults.AutoRefuseSharedQuests
					FCMQT.SavedVars.AutoShare = FCMQT.defaults.AutoShare
					FCMQT.SavedVars.BgAlpha = FCMQT.defaults.BgAlpha
					FCMQT.SavedVars.BgColor = FCMQT.defaults.BgColor
					FCMQT.SavedVars.BgOption = FCMQT.defaults.BgOption
					FCMQT.SavedVars.BgWidth = FCMQT.defaults.BgWidth
					FCMQT.SavedVars.BufferRefreshTime = FCMQT.defaults.BufferRefreshTime
					FCMQT.SavedVars.Button1 = FCMQT.defaults.Button1
					FCMQT.SavedVars.Button2 = FCMQT.defaults.Button2
					FCMQT.SavedVars.Button3 = FCMQT.defaults.Button3
					FCMQT.SavedVars.Button4 = FCMQT.defaults.Button4
					FCMQT.SavedVars.Button5 = FCMQT.defaults.Button5
					FCMQT.SavedVars.Chat_AddonMessage_HeaderColor = FCMQT.defaults.Chat_AddonMessage_HeaderColor
					FCMQT.SavedVars.Chat_AddonMessage_MsgColor = FCMQT.defaults.Chat_AddonMessage_MsgColor
					FCMQT.SavedVars.Chat_AddonMessages = FCMQT.defaults.Chat_AddonMessages
					FCMQT.SavedVars.Chat_QuestInfo = FCMQT.defaults.Chat_QuestInfo
					FCMQT.SavedVars.Chat_QuestInfo_HeaderColor = FCMQT.defaults.Chat_QuestInfo_HeaderColor
					FCMQT.SavedVars.Chat_QuestInfo_MsgColor = FCMQT.defaults.Chat_QuestInfo_MsgColor
					FCMQT.SavedVars.DirectionBox = FCMQT.defaults.DirectionBox
					FCMQT.SavedVars.FocusedQuestAreaNoTrans = FCMQT.defaults.FocusedQuestAreaNoTrans
					FCMQT.SavedVars.HideCompleteObjHints = FCMQT.defaults.HideCompleteObjHints
					FCMQT.SavedVars.HideHiddenOptions = FCMQT.defaults.HideHiddenOptions
					FCMQT.SavedVars.HideHintsOption = FCMQT.defaults.HideHintsOption
					FCMQT.SavedVars.HideInCombatOption = FCMQT.defaults.HideInCombatOption
					FCMQT.SavedVars.HideInfoHintsOption = FCMQT.defaults.HideInfoHintsOption
					FCMQT.SavedVars.HideObjOption = FCMQT.defaults.HideObjOption
					FCMQT.SavedVars.HideOptionalInfo = FCMQT.defaults.HideOptionalInfo
					FCMQT.SavedVars.HideOptObjective = FCMQT.defaults.HideOptObjective
					FCMQT.SavedVars.HintColor = FCMQT.defaults.HintColor
					FCMQT.SavedVars.HintCompleteColor = FCMQT.defaults.HintCompleteColor
					FCMQT.SavedVars.Language = FCMQT.defaults.Language
					FCMQT.SavedVars.NbQuests = FCMQT.defaults.NbQuests
					FCMQT.SavedVars.position = FCMQT.defaults.position
					FCMQT.SavedVars.PositionLockOption = FCMQT.defaults.PositionLockOption
					FCMQT.SavedVars.Preset = FCMQT.defaults.Preset
					FCMQT.SavedVars.QuestIcon = FCMQT.defaults.QuestIcon
					FCMQT.SavedVars.QuestIconColor = FCMQT.defaults.QuestIconColor
					FCMQT.SavedVars.QuestIconOption = FCMQT.defaults.QuestIconOption
					FCMQT.SavedVars.QuestIconSize = FCMQT.defaults.QuestIconSize
					FCMQT.SavedVars.QuestObjIcon = FCMQT.defaults.QuestObjIcon
					FCMQT.SavedVars.QuestsAreaColor = FCMQT.defaults.QuestsAreaColor
					FCMQT.SavedVars.QuestsAreaFont = FCMQT.defaults.QuestsAreaFont
					FCMQT.SavedVars.QuestsAreaOption = FCMQT.defaults.QuestsAreaOption
					FCMQT.SavedVars.QuestsAreaPadding = FCMQT.defaults.QuestsAreaPadding
					FCMQT.SavedVars.QuestsAreaSize = FCMQT.defaults.QuestsAreaSize
					FCMQT.SavedVars.QuestsAreaStyle = FCMQT.defaults.QuestsAreaStyle
					FCMQT.SavedVars.QuestsCategoryClassOption = FCMQT.defaults.QuestsCategoryClassOption
					FCMQT.SavedVars.QuestsCategoryCraftOption = FCMQT.defaults.QuestsCategoryCraftOption
					FCMQT.SavedVars.QuestsCategoryDungeonOption = FCMQT.defaults.QuestsCategoryDungeonOption
					FCMQT.SavedVars.QuestsCategoryGroupOption = FCMQT.defaults.QuestsCategoryGroupOption
					FCMQT.SavedVars.QuestsCategoryRaidOption = FCMQT.defaults.QuestsCategoryRaidOption
					FCMQT.SavedVars.QuestsFilter = FCMQT.defaults.QuestsFilter
					FCMQT.SavedVars.QuestsHideZoneOption = FCMQT.defaults.QuestsHideZoneOption
					FCMQT.SavedVars.QuestsHybridOption = FCMQT.defaults.QuestsHybridOption
					FCMQT.SavedVars.QuestsNoFocusOption = FCMQT.defaults.QuestsNoFocusOption
					FCMQT.SavedVars.QuestsNoFocusTransparency = FCMQT.defaults.QuestsNoFocusTransparency
					FCMQT.SavedVars.QuestsShowTimerOption = FCMQT.defaults.QuestsShowTimerOption
					FCMQT.SavedVars.QuestsUntrackHiddenOption = FCMQT.defaults.QuestsUntrackHiddenOption
					FCMQT.SavedVars.QuestsZoneAVAOption = FCMQT.defaults.QuestsZoneAVAOption
					FCMQT.SavedVars.QuestsZoneBGOption = FCMQT.defaults.QuestsZoneBGOption
					FCMQT.SavedVars.QuestsZoneClassOption = FCMQT.defaults.QuestsZoneClassOption
					FCMQT.SavedVars.QuestsZoneCraftingOption = FCMQT.defaults.QuestsZoneCraftingOption
					FCMQT.SavedVars.QuestsZoneCyrodiilOption = FCMQT.defaults.QuestsZoneCyrodiilOption
					FCMQT.SavedVars.QuestsZoneDungeonOption = FCMQT.defaults.QuestsZoneDungeonOption
					FCMQT.SavedVars.QuestsZoneEventOption = FCMQT.defaults.QuestsZoneEventOption
					FCMQT.SavedVars.QuestsZoneGroupOption = FCMQT.defaults.QuestsZoneGroupOption
					FCMQT.SavedVars.QuestsZoneGuildOption = FCMQT.defaults.QuestsZoneGuildOption
					FCMQT.SavedVars.QuestsZoneMainOption = FCMQT.defaults.QuestsZoneMainOption
					FCMQT.SavedVars.QuestsZoneOption = FCMQT.defaults.QuestsZoneOption
					FCMQT.SavedVars.QuestsZoneRaidOption = FCMQT.defaults.QuestsZoneRaidOption
					FCMQT.SavedVars.ShowJournalInfosColor = FCMQT.defaults.ShowJournalInfosColor
					FCMQT.SavedVars.ShowJournalInfosFont = FCMQT.defaults.ShowJournalInfosFont
					FCMQT.SavedVars.ShowJournalInfosOption = FCMQT.defaults.ShowJournalInfosOption
					FCMQT.SavedVars.ShowJournalInfosSize = FCMQT.defaults.ShowJournalInfosSize
					FCMQT.SavedVars.ShowJournalInfosStyle = FCMQT.defaults.ShowJournalInfosStyle
					FCMQT.SavedVars.SortOrder = FCMQT.defaults.SortOrder
					FCMQT.SavedVars.TextColor = FCMQT.defaults.TextColor
					FCMQT.SavedVars.TextCompleteColor = FCMQT.defaults.TextCompleteColor
					FCMQT.SavedVars.TextFont = FCMQT.defaults.TextFont
					FCMQT.SavedVars.TextOptionalColor = FCMQT.defaults.TextOptionalColor
					FCMQT.SavedVars.TextOptionalCompleteColor = FCMQT.defaults.TextOptionalCompleteColor
					FCMQT.SavedVars.TextPadding = FCMQT.defaults.TextPadding
					FCMQT.SavedVars.TextSize = FCMQT.defaults.TextSize
					FCMQT.SavedVars.TextStyle = FCMQT.defaults.TextStyle
					FCMQT.SavedVars.TimerTitleColor = FCMQT.defaults.TimerTitleColor
					FCMQT.SavedVars.TimerTitleFont = FCMQT.defaults.TimerTitleFont
					FCMQT.SavedVars.TimerTitleSize = FCMQT.defaults.TimerTitleSize
					FCMQT.SavedVars.TimerTitleStyle = FCMQT.defaults.TimerTitleStyle
					FCMQT.SavedVars.TitleColor = FCMQT.defaults.TitleColor
					FCMQT.SavedVars.TitleFont = FCMQT.defaults.TitleFont
					FCMQT.SavedVars.TitlePadding = FCMQT.defaults.TitlePadding
					FCMQT.SavedVars.TitleSize = FCMQT.defaults.TitleSize
					FCMQT.SavedVars.TitleStyle = FCMQT.defaults.TitleStyle
	elseif newPreset == "Preset2" then
					FCMQT.SavedVars.AutoAcceptSharedQuests = FCMQT.Preset2.AutoAcceptSharedQuests
					FCMQT.SavedVars.AutoRefuseSharedQuests = FCMQT.Preset2.AutoRefuseSharedQuests
					FCMQT.SavedVars.AutoShare = FCMQT.Preset2.AutoShare
					FCMQT.SavedVars.BgAlpha = FCMQT.Preset2.BgAlpha
					FCMQT.SavedVars.BgColor = FCMQT.Preset2.BgColor
					FCMQT.SavedVars.BgOption = FCMQT.Preset2.BgOption
					FCMQT.SavedVars.BgWidth = FCMQT.Preset2.BgWidth
					FCMQT.SavedVars.BufferRefreshTime = FCMQT.Preset2.BufferRefreshTime
					FCMQT.SavedVars.Button1 = FCMQT.Preset2.Button1
					FCMQT.SavedVars.Button2 = FCMQT.Preset2.Button2
					FCMQT.SavedVars.Button3 = FCMQT.Preset2.Button3
					FCMQT.SavedVars.Button4 = FCMQT.Preset2.Button4
					FCMQT.SavedVars.Button5 = FCMQT.Preset2.Button5
					FCMQT.SavedVars.Chat_AddonMessage_HeaderColor = FCMQT.Preset2.Chat_AddonMessage_HeaderColor
					FCMQT.SavedVars.Chat_AddonMessage_MsgColor = FCMQT.Preset2.Chat_AddonMessage_MsgColor
					FCMQT.SavedVars.Chat_AddonMessages = FCMQT.Preset2.Chat_AddonMessages
					FCMQT.SavedVars.Chat_QuestInfo = FCMQT.Preset2.Chat_QuestInfo
					FCMQT.SavedVars.Chat_QuestInfo_HeaderColor = FCMQT.Preset2.Chat_QuestInfo_HeaderColor
					FCMQT.SavedVars.Chat_QuestInfo_MsgColor = FCMQT.Preset2.Chat_QuestInfo_MsgColor
					FCMQT.SavedVars.ChatSetup = FCMQT.Preset2.ChatSetup
					FCMQT.SavedVars.ClueColor = FCMQT.Preset2.ClueColor
					FCMQT.SavedVars.DirectionBox = FCMQT.Preset2.DirectionBox
					FCMQT.SavedVars.FocusedQuestAreaNoTrans = FCMQT.Preset2.FocusedQuestAreaNoTrans
					FCMQT.SavedVars.GetFocusedQuestAreaNoTrans = FCMQT.Preset2.GetFocusedQuestAreaNoTrans
					FCMQT.SavedVars.HideCompleteObjHints = FCMQT.Preset2.HideCompleteObjHints
					FCMQT.SavedVars.HideHiddenOptions = FCMQT.Preset2.HideHiddenOptions
					FCMQT.SavedVars.HideHintsOption = FCMQT.Preset2.HideHintsOption
					FCMQT.SavedVars.HideInCombatOption = FCMQT.Preset2.HideInCombatOption
					FCMQT.SavedVars.HideInfoHintsOption = FCMQT.Preset2.HideInfoHintsOption
					FCMQT.SavedVars.HideObjHintsNotFocused = FCMQT.Preset2.HideObjHintsNotFocused
					FCMQT.SavedVars.HideObjOption = FCMQT.Preset2.HideObjOption
					FCMQT.SavedVars.HideOptionalInfo = FCMQT.Preset2.HideOptionalInfo
					FCMQT.SavedVars.HideOptObjective = FCMQT.Preset2.HideOptObjective
					FCMQT.SavedVars.HintColor = FCMQT.Preset2.HintColor
					FCMQT.SavedVars.HintCompleteColor = FCMQT.Preset2.HintCompleteColor
					FCMQT.SavedVars.Language = FCMQT.Preset2.Language
					FCMQT.SavedVars.NbQuests = FCMQT.Preset2.NbQuests
					FCMQT.SavedVars.position = FCMQT.Preset2.position
					FCMQT.SavedVars.PositionLockOption = FCMQT.Preset2.PositionLockOption
					FCMQT.SavedVars.Preset = FCMQT.Preset2.Preset
					FCMQT.SavedVars.QuestIcon = FCMQT.Preset2.QuestIcon
					FCMQT.SavedVars.QuestIconColor = FCMQT.Preset2.QuestIconColor
					FCMQT.SavedVars.QuestIconOption = FCMQT.Preset2.QuestIconOption
					FCMQT.SavedVars.QuestIconSize = FCMQT.Preset2.QuestIconSize
					FCMQT.SavedVars.QuestObjIcon = FCMQT.Preset2.QuestObjIcon
					FCMQT.SavedVars.QuestsAreaColor = FCMQT.Preset2.QuestsAreaColor
					FCMQT.SavedVars.QuestsAreaFont = FCMQT.Preset2.QuestsAreaFont
					FCMQT.SavedVars.QuestsAreaOption = FCMQT.Preset2.QuestsAreaOption
					FCMQT.SavedVars.QuestsAreaPadding = FCMQT.Preset2.QuestsAreaPadding
					FCMQT.SavedVars.QuestsAreaSize = FCMQT.Preset2.QuestsAreaSize
					FCMQT.SavedVars.QuestsAreaStyle = FCMQT.Preset2.QuestsAreaStyle
					FCMQT.SavedVars.QuestsCategoryClassOption = FCMQT.Preset2.QuestsCategoryClassOption
					FCMQT.SavedVars.QuestsCategoryCraftOption = FCMQT.Preset2.QuestsCategoryCraftOption
					FCMQT.SavedVars.QuestsCategoryDungeonOption = FCMQT.Preset2.QuestsCategoryDungeonOption
					FCMQT.SavedVars.QuestsCategoryGroupOption = FCMQT.Preset2.QuestsCategoryGroupOption
					FCMQT.SavedVars.QuestsCategoryRaidOption = FCMQT.Preset2.QuestsCategoryRaidOption
					FCMQT.SavedVars.QuestsFilter = FCMQT.Preset2.QuestsFilter
					FCMQT.SavedVars.QuestsHideZoneOption = FCMQT.Preset2.QuestsHideZoneOption
					FCMQT.SavedVars.QuestsHybridOption = FCMQT.Preset2.QuestsHybridOption
					FCMQT.SavedVars.QuestsLevelOption = FCMQT.Preset2.QuestsLevelOption
					FCMQT.SavedVars.QuestsNoFocusOption = FCMQT.Preset2.QuestsNoFocusOption
					FCMQT.SavedVars.QuestsNoFocusTransparency = FCMQT.Preset2.QuestsNoFocusTransparency
					FCMQT.SavedVars.QuestsShowTimerOption = FCMQT.Preset2.QuestsShowTimerOption
					FCMQT.SavedVars.QuestsUntrackHiddenOption = FCMQT.Preset2.QuestsUntrackHiddenOption
					FCMQT.SavedVars.QuestsZoneAVAOption = FCMQT.Preset2.QuestsZoneAVAOption
					FCMQT.SavedVars.QuestsZoneBGOption = FCMQT.Preset2.QuestsZoneBGOption
					FCMQT.SavedVars.QuestsZoneClassOption = FCMQT.Preset2.QuestsZoneClassOption
					FCMQT.SavedVars.QuestsZoneCraftingOption = FCMQT.Preset2.QuestsZoneCraftingOption
					FCMQT.SavedVars.QuestsZoneCyrodiilOption = FCMQT.Preset2.QuestsZoneCyrodiilOption
					FCMQT.SavedVars.QuestsZoneDungeonOption = FCMQT.Preset2.QuestsZoneDungeonOption
					FCMQT.SavedVars.QuestsZoneEventOption = FCMQT.Preset2.QuestsZoneEventOption
					FCMQT.SavedVars.QuestsZoneGroupOption = FCMQT.Preset2.QuestsZoneGroupOption
					FCMQT.SavedVars.QuestsZoneGuildOption = FCMQT.Preset2.QuestsZoneGuildOption
					FCMQT.SavedVars.QuestsZoneMainOption = FCMQT.Preset2.QuestsZoneMainOption
					FCMQT.SavedVars.QuestsZoneOption = FCMQT.Preset2.QuestsZoneOption
					FCMQT.SavedVars.QuestsZoneRaidOption = FCMQT.Preset2.QuestsZoneRaidOption
					FCMQT.SavedVars.ShowJournalInfosColor = FCMQT.Preset2.ShowJournalInfosColor
					FCMQT.SavedVars.ShowJournalInfosFont = FCMQT.Preset2.ShowJournalInfosFont
					FCMQT.SavedVars.ShowJournalInfosOption = FCMQT.Preset2.ShowJournalInfosOption
					FCMQT.SavedVars.ShowJournalInfosSize = FCMQT.Preset2.ShowJournalInfosSize
					FCMQT.SavedVars.ShowJournalInfosStyle = FCMQT.Preset2.ShowJournalInfosStyle
					FCMQT.SavedVars.SortOrder = FCMQT.Preset2.SortOrder
					FCMQT.SavedVars.TextColor = FCMQT.Preset2.TextColor
					FCMQT.SavedVars.TextCompleteColor = FCMQT.Preset2.TextCompleteColor
					FCMQT.SavedVars.TextFont = FCMQT.Preset2.TextFont
					FCMQT.SavedVars.TextOptionalColor = FCMQT.Preset2.TextOptionalColor
					FCMQT.SavedVars.TextOptionalCompleteColor = FCMQT.Preset2.TextOptionalCompleteColor
					FCMQT.SavedVars.TextPadding = FCMQT.Preset2.TextPadding
					FCMQT.SavedVars.TextSize = FCMQT.Preset2.TextSize
					FCMQT.SavedVars.TextStyle = FCMQT.Preset2.TextStyle
					FCMQT.SavedVars.TimerTitleColor = FCMQT.Preset2.TimerTitleColor
					FCMQT.SavedVars.TimerTitleFont = FCMQT.Preset2.TimerTitleFont
					FCMQT.SavedVars.TimerTitleSize = FCMQT.Preset2.TimerTitleSize
					FCMQT.SavedVars.TimerTitleStyle = FCMQT.Preset2.TimerTitleStyle
					FCMQT.SavedVars.TitleColor = FCMQT.Preset2.TitleColor
	elseif newPreset == "Preset3" then
					FCMQT.SavedVars.AutoAcceptSharedQuests = FCMQT.Preset3.AutoAcceptSharedQuests
					FCMQT.SavedVars.AutoRefuseSharedQuests = FCMQT.Preset3.AutoRefuseSharedQuests
					FCMQT.SavedVars.AutoShare = FCMQT.Preset3.AutoShare
					FCMQT.SavedVars.BgAlpha = FCMQT.Preset3.BgAlpha
					FCMQT.SavedVars.BgColor = FCMQT.Preset3.BgColor
					FCMQT.SavedVars.BgOption = FCMQT.Preset3.BgOption
					FCMQT.SavedVars.BgWidth = FCMQT.Preset3.BgWidth
					FCMQT.SavedVars.BufferRefreshTime = FCMQT.Preset3.BufferRefreshTime
					FCMQT.SavedVars.Button1 = FCMQT.Preset3.Button1
					FCMQT.SavedVars.Button2 = FCMQT.Preset3.Button2
					FCMQT.SavedVars.Button3 = FCMQT.Preset3.Button3
					FCMQT.SavedVars.Button4 = FCMQT.Preset3.Button4
					FCMQT.SavedVars.Button5 = FCMQT.Preset3.Button5
					FCMQT.SavedVars.Chat_AddonMessage_HeaderColor = FCMQT.Preset3.Chat_AddonMessage_HeaderColor
					FCMQT.SavedVars.Chat_AddonMessage_MsgColor = FCMQT.Preset3.Chat_AddonMessage_MsgColor
					FCMQT.SavedVars.Chat_AddonMessages = FCMQT.Preset3.Chat_AddonMessages
					FCMQT.SavedVars.Chat_QuestInfo = FCMQT.Preset3.Chat_QuestInfo
					FCMQT.SavedVars.Chat_QuestInfo_HeaderColor = FCMQT.Preset3.Chat_QuestInfo_HeaderColor
					FCMQT.SavedVars.Chat_QuestInfo_MsgColor = FCMQT.Preset3.Chat_QuestInfo_MsgColor
					FCMQT.SavedVars.ChatSetup = FCMQT.Preset3.ChatSetup
					FCMQT.SavedVars.ClueColor = FCMQT.Preset3.ClueColor
					FCMQT.SavedVars.DirectionBox = FCMQT.Preset3.DirectionBox
					FCMQT.SavedVars.FocusedQuestAreaNoTrans = FCMQT.Preset3.FocusedQuestAreaNoTrans
					FCMQT.SavedVars.GetFocusedQuestAreaNoTrans = FCMQT.Preset3.GetFocusedQuestAreaNoTrans
					FCMQT.SavedVars.HideCompleteObjHints = FCMQT.Preset3.HideCompleteObjHints
					FCMQT.SavedVars.HideHiddenOptions = FCMQT.Preset3.HideHiddenOptions
					FCMQT.SavedVars.HideHintsOption = FCMQT.Preset3.HideHintsOption
					FCMQT.SavedVars.HideInCombatOption = FCMQT.Preset3.HideInCombatOption
					FCMQT.SavedVars.HideInfoHintsOption = FCMQT.Preset3.HideInfoHintsOption
					FCMQT.SavedVars.HideObjHintsNotFocused = FCMQT.Preset3.HideObjHintsNotFocused
					FCMQT.SavedVars.HideObjOption = FCMQT.Preset3.HideObjOption
					FCMQT.SavedVars.HideOptionalInfo = FCMQT.Preset3.HideOptionalInfo
					FCMQT.SavedVars.HideOptObjective = FCMQT.Preset3.HideOptObjective
					FCMQT.SavedVars.HintColor = FCMQT.Preset3.HintColor
					FCMQT.SavedVars.HintCompleteColor = FCMQT.Preset3.HintCompleteColor
					FCMQT.SavedVars.Language = FCMQT.Preset3.Language
					FCMQT.SavedVars.NbQuests = FCMQT.Preset3.NbQuests
					FCMQT.SavedVars.position = FCMQT.Preset3.position
					FCMQT.SavedVars.PositionLockOption = FCMQT.Preset3.PositionLockOption
					FCMQT.SavedVars.Preset = FCMQT.Preset3.Preset
					FCMQT.SavedVars.QuestIcon = FCMQT.Preset3.QuestIcon
					FCMQT.SavedVars.QuestIconColor = FCMQT.Preset3.QuestIconColor
					FCMQT.SavedVars.QuestIconOption = FCMQT.Preset3.QuestIconOption
					FCMQT.SavedVars.QuestIconSize = FCMQT.Preset3.QuestIconSize
					FCMQT.SavedVars.QuestObjIcon = FCMQT.Preset3.QuestObjIcon
					FCMQT.SavedVars.QuestsAreaColor = FCMQT.Preset3.QuestsAreaColor
					FCMQT.SavedVars.QuestsAreaFont = FCMQT.Preset3.QuestsAreaFont
					FCMQT.SavedVars.QuestsAreaOption = FCMQT.Preset3.QuestsAreaOption
					FCMQT.SavedVars.QuestsAreaPadding = FCMQT.Preset3.QuestsAreaPadding
					FCMQT.SavedVars.QuestsAreaSize = FCMQT.Preset3.QuestsAreaSize
					FCMQT.SavedVars.QuestsAreaStyle = FCMQT.Preset3.QuestsAreaStyle
					FCMQT.SavedVars.QuestsCategoryClassOption = FCMQT.Preset3.QuestsCategoryClassOption
					FCMQT.SavedVars.QuestsCategoryCraftOption = FCMQT.Preset3.QuestsCategoryCraftOption
					FCMQT.SavedVars.QuestsCategoryDungeonOption = FCMQT.Preset3.QuestsCategoryDungeonOption
					FCMQT.SavedVars.QuestsCategoryGroupOption = FCMQT.Preset3.QuestsCategoryGroupOption
					FCMQT.SavedVars.QuestsCategoryRaidOption = FCMQT.Preset3.QuestsCategoryRaidOption
					FCMQT.SavedVars.QuestsFilter = FCMQT.Preset3.QuestsFilter
					FCMQT.SavedVars.QuestsHideZoneOption = FCMQT.Preset3.QuestsHideZoneOption
					FCMQT.SavedVars.QuestsHybridOption = FCMQT.Preset3.QuestsHybridOption
					FCMQT.SavedVars.QuestsLevelOption = FCMQT.Preset3.QuestsLevelOption
					FCMQT.SavedVars.QuestsNoFocusOption = FCMQT.Preset3.QuestsNoFocusOption
					FCMQT.SavedVars.QuestsNoFocusTransparency = FCMQT.Preset3.QuestsNoFocusTransparency
					FCMQT.SavedVars.QuestsShowTimerOption = FCMQT.Preset3.QuestsShowTimerOption
					FCMQT.SavedVars.QuestsUntrackHiddenOption = FCMQT.Preset3.QuestsUntrackHiddenOption
					FCMQT.SavedVars.QuestsZoneAVAOption = FCMQT.Preset3.QuestsZoneAVAOption
					FCMQT.SavedVars.QuestsZoneBGOption = FCMQT.Preset3.QuestsZoneBGOption
					FCMQT.SavedVars.QuestsZoneClassOption = FCMQT.Preset3.QuestsZoneClassOption
					FCMQT.SavedVars.QuestsZoneCraftingOption = FCMQT.Preset3.QuestsZoneCraftingOption
					FCMQT.SavedVars.QuestsZoneCyrodiilOption = FCMQT.Preset3.QuestsZoneCyrodiilOption
					FCMQT.SavedVars.QuestsZoneDungeonOption = FCMQT.Preset3.QuestsZoneDungeonOption
					FCMQT.SavedVars.QuestsZoneEventOption = FCMQT.Preset3.QuestsZoneEventOption
					FCMQT.SavedVars.QuestsZoneGroupOption = FCMQT.Preset3.QuestsZoneGroupOption
					FCMQT.SavedVars.QuestsZoneGuildOption = FCMQT.Preset3.QuestsZoneGuildOption
					FCMQT.SavedVars.QuestsZoneMainOption = FCMQT.Preset3.QuestsZoneMainOption
					FCMQT.SavedVars.QuestsZoneOption = FCMQT.Preset3.QuestsZoneOption
					FCMQT.SavedVars.QuestsZoneRaidOption = FCMQT.Preset3.QuestsZoneRaidOption
					FCMQT.SavedVars.ShowJournalInfosColor = FCMQT.Preset3.ShowJournalInfosColor
					FCMQT.SavedVars.ShowJournalInfosFont = FCMQT.Preset3.ShowJournalInfosFont
					FCMQT.SavedVars.ShowJournalInfosOption = FCMQT.Preset3.ShowJournalInfosOption
					FCMQT.SavedVars.ShowJournalInfosSize = FCMQT.Preset3.ShowJournalInfosSize
					FCMQT.SavedVars.ShowJournalInfosStyle = FCMQT.Preset3.ShowJournalInfosStyle
					FCMQT.SavedVars.SortOrder = FCMQT.Preset3.SortOrder
					FCMQT.SavedVars.TextColor = FCMQT.Preset3.TextColor
					FCMQT.SavedVars.TextCompleteColor = FCMQT.Preset3.TextCompleteColor
					FCMQT.SavedVars.TextFont = FCMQT.Preset3.TextFont
					FCMQT.SavedVars.TextOptionalColor = FCMQT.Preset3.TextOptionalColor
					FCMQT.SavedVars.TextOptionalCompleteColor = FCMQT.Preset3.TextOptionalCompleteColor
					FCMQT.SavedVars.TextPadding = FCMQT.Preset3.TextPadding
					FCMQT.SavedVars.TextSize = FCMQT.Preset3.TextSize
					FCMQT.SavedVars.TextStyle = FCMQT.Preset3.TextStyle
					FCMQT.SavedVars.TimerTitleColor = FCMQT.Preset3.TimerTitleColor
					FCMQT.SavedVars.TimerTitleFont = FCMQT.Preset3.TimerTitleFont
					FCMQT.SavedVars.TimerTitleSize = FCMQT.Preset3.TimerTitleSize
					FCMQT.SavedVars.TimerTitleStyle = FCMQT.Preset3.TimerTitleStyle
					FCMQT.SavedVars.TitleColor = FCMQT.Preset3.TitleColor

	else
		-- nothing
	end
	if newPreset ~= "Custom" then
		ReloadUI()
	end
end


-- Get/Set Hide in combat
function FCMQT.GetHideInCombatOption()
	return FCMQT.SavedVars.HideInCombatOption
end

function FCMQT.SetHideInCombatOption(newOpt)
	FCMQT.SavedVars.HideInCombatOption = newOpt
	FCMQT.QuestsListUpdate(1)
end


-- Get/Set Background Transparency
function FCMQT.GetBgAlpha()
	return FCMQT.SavedVars.BgAlpha
end

function FCMQT.SetBgAlpha(newAlpha)
	FCMQT.SavedVars.BgAlpha = newAlpha
	FCMQT.main:SetAlpha(newAlpha/100)
	FCMQT.SavedVars.Preset = "Custom"
end


-- Get/Set BGWidth
function FCMQT.GetBgWidth()
	return FCMQT.SavedVars.BgWidth
end
function FCMQT.SetBgWidth(newWidth)
	FCMQT.SavedVars.BgWidth = newWidth
	FCMQT.bg:SetDimensionConstraints(newWidth,-1,newWidth,-1)
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end



-- Position
function FCMQT.GetPositionLockOption()
	return FCMQT.SavedVars.PositionLockOption
end
function FCMQT.SetPositionLockOption(newOpt)
	FCMQT.SavedVars.PositionLockOption = newOpt
	if newOpt == true then
		FCMQT.main:SetMouseEnabled(false)
		FCMQT.main:SetMovable(false)
	else
		FCMQT.main:SetMouseEnabled(true)
		FCMQT.main:SetMovable(true)
	end
	FCMQT.QuestsListUpdate(1)
end

-- JournalInfos
function FCMQT.GetShowJournalInfosOption()
	return FCMQT.SavedVars.ShowJournalInfosOption
end
function FCMQT.SetShowJournalInfosOption(newOpt)
	FCMQT.SavedVars.ShowJournalInfosOption = newOpt
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetShowJournalInfosFont()
	return FCMQT.SavedVars.ShowJournalInfosFont
end
function FCMQT.SetShowJournalInfosFont(newFont)
	FCMQT.SavedVars.ShowJournalInfosFont = newFont
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetShowJournalInfosStyle()
	return FCMQT.SavedVars.ShowJournalInfosStyle
end
function FCMQT.SetShowJournalInfosStyle(newStyle)
	FCMQT.SavedVars.ShowJournalInfosStyle = newStyle
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetShowJournalInfosSize()
	return FCMQT.SavedVars.ShowJournalInfosSize
end
function FCMQT.SetShowJournalInfosSize(newSize)
	FCMQT.SavedVars.ShowJournalInfosSize = newSize
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetShowJournalInfosColor()
	return FCMQT.SavedVars.ShowJournalInfosColor.r, FCMQT.SavedVars.ShowJournalInfosColor.g, FCMQT.SavedVars.ShowJournalInfosColor.b, FCMQT.SavedVars.ShowJournalInfosColor.a
end
function FCMQT.SetShowJournalInfosColor(r,g,b,a)
	FCMQT.SavedVars.ShowJournalInfosColor.r = r
	FCMQT.SavedVars.ShowJournalInfosColor.g = g
	FCMQT.SavedVars.ShowJournalInfosColor.b = b
	FCMQT.SavedVars.ShowJournalInfosColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end


-- Color
function FCMQT.GetBgOption()
	return FCMQT.SavedVars.BgOption
end
function FCMQT.SetBgOption(newOpt)
	FCMQT.SavedVars.BgOption = newOpt
	if newOpt == true then
		FCMQT.bg:SetColor(FCMQT.SavedVars.BgColor.r,FCMQT.SavedVars.BgColor.g,FCMQT.SavedVars.BgColor.b,FCMQT.SavedVars.BgColor.a)
	--elseif FCMQT.SavedVars.BgGradientOption == true then
		-- FCMQT.bg:SetGradientColors(FCMQT.SavedVars.BgColor.r,FCMQT.SavedVars.BgColor.g,FCMQT.SavedVars.BgColor.b,FCMQT.SavedVars.BgColor.a,0,0,0,0)
	else
		FCMQT.bg:SetColor(0,0,0,0)
	end
	FCMQT.SavedVars.Preset = "Custom"
end

function FCMQT.GetBgColor()
	return FCMQT.SavedVars.BgColor.r, FCMQT.SavedVars.BgColor.g, FCMQT.SavedVars.BgColor.b, FCMQT.SavedVars.BgColor.a
end
function FCMQT.SetBgColor(r,g,b,a)
	FCMQT.SavedVars.BgColor.r = r
	FCMQT.SavedVars.BgColor.g = g
	FCMQT.SavedVars.BgColor.b = b
	FCMQT.SavedVars.BgColor.a = a
	FCMQT.bg:SetColor(r,g,b,a)
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetDirectionBox()
	return FCMQT.SavedVars.DirectionBox
end
function FCMQT.SetDirectionBox(newDirection)
	FCMQT.SavedVars.DirectionBox = newDirection
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

-- Quests
function FCMQT.GetSortQuests()
	return FCMQT.SavedVars.SortOrder
end
function FCMQT.SetSortQuests(newOrder)
	FCMQT.SavedVars.SortOrder = newOrder
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetNbQuests() 
	return FCMQT.SavedVars.NbQuests
end
function FCMQT.SetNbQuests(newNbQuests)
	FCMQT.SavedVars.NbQuests = newNbQuests
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetAutoShareOption()
	return FCMQT.SavedVars.AutoShare
end
function FCMQT.SetAutoShareOption(newOpt)
	FCMQT.SavedVars.AutoShare = newOpt
end

function FCMQT.GetAutoAcceptSharedQuestsOption()
	return FCMQT.SavedVars.AutoAcceptSharedQuests
end
function FCMQT.SetAutoAcceptSharedQuestsOption(newOpt)
	FCMQT.SavedVars.AutoAcceptSharedQuests = newOpt
end

function FCMQT.GetAutoRefuseSharedQuestsOption()
	return FCMQT.SavedVars.AutoRefuseSharedQuests
end
function FCMQT.SetAutoRefuseSharedQuestsOption(newOpt)
	FCMQT.SavedVars.AutoRefuseSharedQuests = newOpt
end

--AcceptOfferedQuest()
--AcceptSharedQuest()
--DeclineSharedQuest()

function FCMQT.GetBufferRefreshTime()
	return FCMQT.SavedVars.BufferRefreshTime
end
function FCMQT.SetBufferRefreshTime(newTimer)
	FCMQT.SavedVars.BufferRefreshTime = newTimer
end

function FCMQT.GetQuestIconOption()
	return FCMQT.SavedVars.QuestIconOption
end
function FCMQT.SetQuestIconOption(newOpt)
	FCMQT.SavedVars.QuestIconOption = newOpt
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestIcon()
	return FCMQT.SavedVars.QuestIcon
end
function FCMQT.SetQuestIcon(newFont)
	FCMQT.SavedVars.QuestIcon = newFont
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestIconSize()
	return FCMQT.SavedVars.QuestIconSize
end
function FCMQT.SetQuestIconSize(newSize)
	FCMQT.SavedVars.QuestIconSize = newSize
	local marker = 1
	while FCMQT.icon[marker] do
		FCMQT.icon[marker]:SetDimensions(newSize, newSize)
		marker = marker + 1
	end
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestIconColor()
	return FCMQT.SavedVars.QuestIconColor.r, FCMQT.SavedVars.QuestIconColor.g, FCMQT.SavedVars.QuestIconColor.b, FCMQT.SavedVars.QuestIconColor.a
end


function FCMQT.SetQuestIconColor(r,g,b,a)
	FCMQT.SavedVars.QuestIconColor.r = r
	FCMQT.SavedVars.QuestIconColor.g = g
	FCMQT.SavedVars.QuestIconColor.b = b
	FCMQT.SavedVars.QuestIconColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end


function FCMQT.GetHintColor()
	return FCMQT.SavedVars.HintColor.r, FCMQT.SavedVars.HintColor.g, FCMQT.SavedVars.HintColor.b, FCMQT.SavedVars.HintColor.a
end

function FCMQT.SetHintColor(r,g,b,a)
	FCMQT.SavedVars.HintColor.r = r
	FCMQT.SavedVars.HintColor.g = g
	FCMQT.SavedVars.HintColor.b = b
	FCMQT.SavedVars.HintColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetHintCompleteColor()
	return FCMQT.SavedVars.HintCompleteColor.r, FCMQT.SavedVars.HintCompleteColor.g, FCMQT.SavedVars.HintCompleteColor.b, FCMQT.SavedVars.HintCompleteColor.a
end

function FCMQT.SetHintCompleteColor(r,g,b,a)
	FCMQT.SavedVars.HintCompleteColor.r = r
	FCMQT.SavedVars.HintCompleteColor.g = g
	FCMQT.SavedVars.HintCompleteColor.b = b
	FCMQT.SavedVars.HintCompleteColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

--zone/area enabled
function FCMQT.GetQuestsAreaOption()
	return FCMQT.SavedVars.QuestsAreaOption
end

--zone/area enabled
function FCMQT.SetQuestsAreaOption(newOpt)
	FCMQT.SavedVars.QuestsAreaOption = newOpt
	FCMQT.QuestsAreaOption = newOpt
	FCMQT.SavedVars.QuestsFilter = {}
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsAreaFont()
	return FCMQT.SavedVars.QuestsAreaFont
end
function FCMQT.SetQuestsAreaFont(newFont)
	FCMQT.SavedVars.QuestsAreaFont = newFont
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsAreaStyle()
	return FCMQT.SavedVars.QuestsAreaStyle
end

function FCMQT.SetQuestsAreaStyle(newStyle)
	FCMQT.SavedVars.QuestsAreaStyle = newStyle
	FCMQT.QuestsListUpdate(1)
end


function FCMQT.GetQuestsAreaSize()
	return FCMQT.SavedVars.QuestsAreaSize
end
function FCMQT.SetQuestsAreaSize(newSize)
	FCMQT.SavedVars.QuestsAreaSize = newSize
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsAreaPadding()
	return FCMQT.SavedVars.QuestsAreaPadding
end
function FCMQT.SetQuestsAreaPadding(newSize)
	FCMQT.SavedVars.QuestsAreaPadding = newSize
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsAreaColor()
	return FCMQT.SavedVars.QuestsAreaColor.r, FCMQT.SavedVars.QuestsAreaColor.g, FCMQT.SavedVars.QuestsAreaColor.b, FCMQT.SavedVars.QuestsAreaColor.a
end
function FCMQT.SetQuestsAreaColor(r,g,b,a)
	FCMQT.SavedVars.QuestsAreaColor.r = r
	FCMQT.SavedVars.QuestsAreaColor.g = g
	FCMQT.SavedVars.QuestsAreaColor.b = b
	FCMQT.SavedVars.QuestsAreaColor.a = a
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsShowTimerOption()
	return FCMQT.SavedVars.QuestsShowTimerOption
end
function FCMQT.SetQuestsShowTimerOption(newOpt)
	FCMQT.SavedVars.QuestsShowTimerOption = newOpt
	FCMQT.QuestsListUpdate(1)
end


function FCMQT.GetHideOptObjective()
	return FCMQT.SavedVars.HideOptObjective
end

function FCMQT.SetHideOptObjective(newOpt)
	FCMQT.SavedVars.HideOptObjective = newOpt
	FCMQT.QuestsListUpdate(1)
end



function FCMQT.GetHideOptionalInfo()
	return FCMQT.SavedVars.HideOptionalInfo
end

function FCMQT.SetHideOptionalInfo(newOpt)
	FCMQT.SavedVars.HideOptionalInfo = newOpt
	FCMQT.QuestsListUpdate(1)
end



function FCMQT.GetHideHintsOption()
	return FCMQT.SavedVars.HideHintsOption
end

function FCMQT.SetHideHintsOption(newOpt)
	FCMQT.SavedVars.HideHintsOption = newOpt
	FCMQT.QuestsListUpdate(1)
end



function FCMQT.GetHideHiddenOptions()
	return FCMQT.SavedVars.HideHiddenOptions
end

function FCMQT.SetHideHiddenOptions(newOpt)
	FCMQT.SavedVars.HideHiddenOptions = newOpt
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsCategoryClassOption()
	return FCMQT.SavedVars.QuestsCategoryClassOption
end
function FCMQT.SetQuestsCategoryClassOption(newOpt)
	FCMQT.SavedVars.QuestsCategoryClassOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsCategoryCraftOption()
	return FCMQT.SavedVars.QuestsCategoryCraftOption
end
function FCMQT.SetQuestsCategoryCraftOption (newOpt)
	FCMQT.SavedVars.QuestsCategoryCraftOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsCategoryGroupOption()
	return FCMQT.SavedVars.QuestsCategoryGroupOption
end
function FCMQT.SetQuestsCategoryGroupOption(newOpt)
	FCMQT.SavedVars.QuestsCategoryGroupOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsCategoryDungeonOption()
	return FCMQT.SavedVars.QuestsCategoryDungeonOption
end
function FCMQT.SetQuestsCategoryDungeonOption(newOpt)
	FCMQT.SavedVars.QuestsCategoryDungeonOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsCategoryRaidOption()
	return FCMQT.SavedVars.QuestsCategoryRaidOption
end
function FCMQT.SetQuestsCategoryRaidOption(newOpt)
	FCMQT.SavedVars.QuestsCategoryRaidOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

-- QuestObjIcon - Quest Objective Icon
--Get QuestObjIcon
function FCMQT.GetQuestObjIcon()
	return FCMQT.SavedVars.QuestObjIcon
end

--SEt QuestObjIcon
function FCMQT.SetQuestObjIcon(newOpt)
	FCMQT.SavedVars.QuestObjIcon = newOpt
	FCMQT.QuestsListUpdate(1)
end
--hideoptional
function FCMQT.GetHideCompleteObjHints()
	return FCMQT.SavedVars.HideCompleteObjHints
end
function FCMQT.SetHideCompleteObjHints(newOpt)
	FCMQT.SavedVars.HideCompleteObjHints = newOpt
	FCMQT.QuestsListUpdate(1)
end

--Focused Quest Zone Not Transparent
function FCMQT.GetFocusedQuestAreaNoTrans()
	return FCMQT.SavedVars.FocusedQuestAreaNoTrans
end

--Focused Quest Zone Not Transparent
function FCMQT.SetFocusedQuestAreaNoTrans(newOpt)
	FCMQT.SavedVars.FocusedQuestAreaNoTrans = newOpt
	FCMQT.FocusedQuestAreaNoTrans = newOpt
	FCMQT.QuestsListUpdate(1)
end

--enable auto hide zone
function FCMQT.GetQuestsHideZoneOption()
	return FCMQT.SavedVars.QuestsHideZoneOption
end

--enable auto hide zone
function FCMQT.SetQuestsHideZoneOption(newOpt)
	FCMQT.SavedVars.QuestsHideZoneOption = newOpt
	FCMQT.QuestsHideZoneOption = newOpt
	if newOpt == true then 
		AutoFilterZone()
	else
		RemoveFilterZone()
	end
	
end

function FCMQT.GetQuestsZoneOption()
	return FCMQT.SavedVars.QuestsZoneOption
end
function FCMQT.SetQuestsZoneOption(newOpt)
	FCMQT.SavedVars.QuestsZoneOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsZoneGuildOption()
	return FCMQT.SavedVars.QuestsZoneGuildOption
end
function FCMQT.SetQuestsZoneGuildOption(newOpt)
	FCMQT.SavedVars.QuestsZoneGuildOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

--zone/area hybrid/pure zone
function FCMQT.GetQuestsHybridOption()
	return FCMQT.SavedVars.QuestsHybridOption
end

--zone/area hybrid/pure zone
function FCMQT.SetQuestsHybridOption(newOpt)
	FCMQT.SavedVars.QuestsHybridOption = newOpt
	FCMQT.QuestsHybridOption = newOpt
	if FCMQT.SavedVars.QuestsHideZoneOption == true then AutoFilterZone() else FCMQT.QuestsListUpdate(1) end
end	

function FCMQT.GetQuestsZoneMainOption()
	return FCMQT.SavedVars.QuestsZoneMainOption
end
function FCMQT.SetQuestsZoneMainOption(newOpt)
	FCMQT.SavedVars.QuestsZoneMainOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsZoneCyrodiilOption()
	return FCMQT.SavedVars.QuestsZoneCyrodiilOption
end
function FCMQT.SetQuestsZoneCyrodiilOption(newOpt)
	FCMQT.SavedVars.QuestsZoneCyrodiilOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsZoneClassOption()
	return FCMQT.SavedVars.QuestsZoneClassOption
end
function FCMQT.SetQuestsZoneClassOption(newOpt)
	FCMQT.SavedVars.QuestsZoneClassOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsZoneCraftingOption()
	return FCMQT.SavedVars.QuestsZoneCraftingOption
end
function FCMQT.SetQuestsZoneCraftingOption(newOpt)
	FCMQT.SavedVars.QuestsZoneCraftingOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsZoneGroupOption()
	return FCMQT.SavedVars.QuestsZoneGroupOption
end
function FCMQT.SetQuestsZoneGroupOption(newOpt)
	FCMQT.SavedVars.QuestsZoneGroupOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsZoneDungeonOption()
	return FCMQT.SavedVars.QuestsZoneDungeonOption
end
function FCMQT.SetQuestsZoneDungeonOption(newOpt)
	FCMQT.SavedVars.QuestsZoneDungeonOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsZoneRaidOption()
	return FCMQT.SavedVars.QuestsZoneRaidOption
end
function FCMQT.SetQuestsZoneRaidOption(newOpt)
	FCMQT.SavedVars.QuestsZoneRaidOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsZoneAVAOption()
	return FCMQT.SavedVars.QuestsZoneAVAOption
end
function FCMQT.SetQuestsZoneAVAOption(newOpt)
	FCMQT.SavedVars.QuestsZoneAVAOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsZoneEventOption()
	return FCMQT.SavedVars.QuestsZoneEventOption
end
function FCMQT.SetQuestsZoneEventOption(newOpt)
	FCMQT.SavedVars.QuestsZoneEventOption = newOpt
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetQuestsZoneBGOption()
	return FCMQT.SavedVars.QuestsZoneBGOption
end
function FCMQT.SetQuestsZoneBGOption(newOpt)
	FCMQT.SavedVars.QuestsZoneBGOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

--Hide Optional/Hidden Quest Info/Hints ALL
function FCMQT.GetHideInfoHintsOption()
	return FCMQT.SavedVars.HideInfoHintsOption
end

--Hide Optional/Hidden Quest Info/Hints ALL
function FCMQT.SetHideInfoHintsOption(newOpt)
	FCMQT.SavedVars.HideInfoHintsOption = newOpt
	FCMQT.HideInfoHintsOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

--[[function FCMQT.GetQuestsUntrackHiddenOption()
	return FCMQT.SavedVars.QuestsUntrackHiddenOption
end
function FCMQT.SetQuestsUntrackHiddenOption(newOpt)
	FCMQT.SavedVars.QuestsUntrackHiddenOption = newOpt
	FCMQT.QuestsListUpdate(1)
end]]

--Enable Transparency for Not Focused Quests
function FCMQT.GetQuestsNoFocusOption()
	return FCMQT.SavedVars.QuestsNoFocusOption
end

--Enable Transparency for Not Focused Quests
function FCMQT.SetQuestsNoFocusOption(newOpt)
	FCMQT.SavedVars.QuestsNoFocusOption = newOpt
	FCMQT.QuestsNoFocusOption = newOpt
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetQuestsNoFocusTransparency()
	return FCMQT.SavedVars.QuestsNoFocusTransparency
end
function FCMQT.SetQuestsNoFocusTransparency(newAlpha)
	FCMQT.SavedVars.QuestsNoFocusTransparency = newAlpha
	FCMQT.QuestsListUpdate(1)
end

-- Title Custom
function FCMQT.GetTitleFont()
	return FCMQT.SavedVars.TitleFont
end
function FCMQT.SetTitleFont(newFont)
	FCMQT.SavedVars.TitleFont = newFont
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTitleStyle()
	return FCMQT.SavedVars.TitleStyle
end
function FCMQT.SetTitleStyle(newStyle)
	FCMQT.SavedVars.TitleStyle = newStyle
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTitleSize()
	return FCMQT.SavedVars.TitleSize
end
function FCMQT.SetTitleSize(newSize)
	FCMQT.SavedVars.TitleSize = newSize
	FCMQT.SavedVars.Preset = "Custom"	
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTitlePadding()
	return FCMQT.SavedVars.TitlePadding
end
function FCMQT.SetTitlePadding(newSize)
	FCMQT.SavedVars.TitlePadding = newSize
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

-- TimerTitle Custom
function FCMQT.GetTimerTitleFont()
	return FCMQT.SavedVars.TimerTitleFont
end
function FCMQT.SetTimerTitleFont(newFont)
	FCMQT.SavedVars.TimerTitleFont = newFont
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTimerTitleStyle()
	return FCMQT.SavedVars.TimerTitleStyle
end
function FCMQT.SetTimerTitleStyle(newStyle)
	FCMQT.SavedVars.TimerTitleStyle = newStyle
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTimerTitleSize()
	return FCMQT.SavedVars.TimerTitleSize
end
function FCMQT.SetTimerTitleSize(newSize)
	FCMQT.SavedVars.TimerTitleSize = newSize
	FCMQT.SavedVars.Preset = "Custom"	
	FCMQT.QuestsListUpdate(1)
end

-- Default TimerTitle color
function FCMQT.GetTimerTitleColor()
	return FCMQT.SavedVars.TimerTitleColor.r, FCMQT.SavedVars.TimerTitleColor.g, FCMQT.SavedVars.TimerTitleColor.b, FCMQT.SavedVars.TimerTitleColor.a
end
function FCMQT.SetTimerTitleColor(r,g,b,a)
	FCMQT.SavedVars.TimerTitleColor.r = r
	FCMQT.SavedVars.TimerTitleColor.g = g
	FCMQT.SavedVars.TimerTitleColor.b = b
	FCMQT.SavedVars.TimerTitleColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

-- Default Title color
function FCMQT.GetTitleColor()
	return FCMQT.SavedVars.TitleColor.r, FCMQT.SavedVars.TitleColor.g, FCMQT.SavedVars.TitleColor.b, FCMQT.SavedVars.TitleColor.a
end
function FCMQT.SetTitleColor(r,g,b,a)
	FCMQT.SavedVars.TitleColor.r = r
	FCMQT.SavedVars.TitleColor.g = g
	FCMQT.SavedVars.TitleColor.b = b
	FCMQT.SavedVars.TitleColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

-- Custom color level
function FCMQT.GetTitleOption()
	return FCMQT.SavedVars.TitleOption
end
function FCMQT.SetTitleOption(newOpt)
	FCMQT.SavedVars.TitleOption = newOpt
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end
--b5-Hide Object/Hints EXCEPT when ?? HideObjHintsSelect --

-- Objectives Custom
function FCMQT.GetTextFont()
	return FCMQT.SavedVars.TextFont
end
function FCMQT.SetTextFont(newFont)
	FCMQT.SavedVars.TextFont = newFont
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTextStyle()
	return FCMQT.SavedVars.TextStyle
end
function FCMQT.SetTextStyle(newStyle)
	FCMQT.SavedVars.TextStyle = newStyle
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTextSize()
	return FCMQT.SavedVars.TextSize
end
function FCMQT.SetTextSize(newSize)
	FCMQT.SavedVars.TextSize = newSize
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTextPadding()
	return FCMQT.SavedVars.TextPadding
end
function FCMQT.SetTextPadding(newSize)
	FCMQT.SavedVars.TextPadding = newSize
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTextColor()
	return FCMQT.SavedVars.TextColor.r, FCMQT.SavedVars.TextColor.g, FCMQT.SavedVars.TextColor.b, FCMQT.SavedVars.TextColor.a
end
function FCMQT.SetTextColor(r,g,b,a)
	FCMQT.SavedVars.TextColor.r = r
	FCMQT.SavedVars.TextColor.g = g
	FCMQT.SavedVars.TextColor.b = b
	FCMQT.SavedVars.TextColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTextCompleteColor()
	return 	FCMQT.SavedVars.TextCompleteColor.r, FCMQT.SavedVars.TextCompleteColor.g, FCMQT.SavedVars.TextCompleteColor.b, FCMQT.SavedVars.TextCompleteColor.a
end
function FCMQT.SetTextCompleteColor(r,g,b,a)
	FCMQT.SavedVars.TextCompleteColor.r = r
	FCMQT.SavedVars.TextCompleteColor.g = g
	FCMQT.SavedVars.TextCompleteColor.b = b
	FCMQT.SavedVars.TextCompleteColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTextOptionalColor()
	return FCMQT.SavedVars.TextOptionalColor.r, FCMQT.SavedVars.TextOptionalColor.g, FCMQT.SavedVars.TextOptionalColor.b, FCMQT.SavedVars.TextOptionalColor.a
end
function FCMQT.SetTextOptionalColor(r,g,b,a)
	FCMQT.SavedVars.TextOptionalColor.r = r
	FCMQT.SavedVars.TextOptionalColor.g = g
	FCMQT.SavedVars.TextOptionalColor.b = b
	FCMQT.SavedVars.TextOptionalColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

function FCMQT.GetTextOptionalCompleteColor()
	return 	FCMQT.SavedVars.TextOptionalCompleteColor.r, FCMQT.SavedVars.TextOptionalCompleteColor.g, FCMQT.SavedVars.TextOptionalCompleteColor.b, FCMQT.SavedVars.TextOptionalCompleteColor.a
end
function FCMQT.SetTextOptionalCompleteColor(r,g,b,a)
	FCMQT.SavedVars.TextOptionalCompleteColor.r = r
	FCMQT.SavedVars.TextOptionalCompleteColor.g = g
	FCMQT.SavedVars.TextOptionalCompleteColor.b = b
	FCMQT.SavedVars.TextOptionalCompleteColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end
function FCMQT.GetHideObjOption()
	return FCMQT.SavedVars.HideObjOption
end
function FCMQT.SetHideObjOption(NewVal)
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.SavedVars.HideObjOption = NewVal
	FCMQT.HideObjOption = NewVal
	FCMQT.QuestsListUpdate(1)
end
-- Mouse Controls
function FCMQT.GetButton1()
	return FCMQT.SavedVars.Button1
end
function FCMQT.SetButton1(NewVal)
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.SavedVars.Button1 = NewVal
end

function FCMQT.GetButton2()
	return FCMQT.SavedVars.Button2
end
function FCMQT.SetButton2(NewVal)
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.SavedVars.Button2 = NewVal
end

function FCMQT.GetButton3()
	return FCMQT.SavedVars.Button3
end
function FCMQT.SetButton3(NewVal)
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.SavedVars.Button3 = NewVal
end

function FCMQT.GetButton4()
	return FCMQT.SavedVars.Button4
end
function FCMQT.SetButton4(NewVal)
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.SavedVars.Button4 = NewVal
end

function FCMQT.GetButton5()
	return FCMQT.SavedVars.Button5
end
function FCMQT.SetButton5(NewVal)
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.SavedVars.Button5 = NewVal
end

-- Chat Settings

--Get/Set Chat_AddonMessages
function FCMQT.GetChat_AddonMessages()
	return FCMQT.SavedVars.Chat_AddonMessages
end

function FCMQT.SetChat_AddonMessages(newOpt)
	FCMQT.SavedVars.Chat_AddonMessages = newOpt
	FCMQT.QuestsListUpdate(1)
end

-- GEt/Set Chat Questinfo
function FCMQT.GetChat_QuestInfo()
	return FCMQT.SavedVars.Chat_QuestInfo
end

function FCMQT.SetChat_QuestInfo(newOpt)
	FCMQT.SavedVars.Chat_QuestInfo = newOpt
	FCMQT.QuestsListUpdate(1)
end

-- Get/Set Chat_AddonMessage_HeaderColor
function FCMQT.GetChat_AddonMessage_HeaderColor()
	return 	FCMQT.SavedVars.Chat_AddonMessage_HeaderColor.r, FCMQT.SavedVars.Chat_AddonMessage_HeaderColor.g, FCMQT.SavedVars.Chat_AddonMessage_HeaderColor.b, FCMQT.SavedVars.Chat_AddonMessage_HeaderColor.a
end
function FCMQT.SetChat_AddonMessage_HeaderColor(r,g,b,a)
	FCMQT.SavedVars.Chat_AddonMessage_HeaderColor.r = r
	FCMQT.SavedVars.Chat_AddonMessage_HeaderColor.g = g
	FCMQT.SavedVars.Chat_AddonMessage_HeaderColor.b = b
	FCMQT.SavedVars.Chat_AddonMessage_HeaderColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

-- Get/Set Chat_AddonMessage_MsgColor
function FCMQT.GetChat_AddonMessage_MsgColor()
	return 	FCMQT.SavedVars.Chat_AddonMessage_MsgColor.r, FCMQT.SavedVars.Chat_AddonMessage_MsgColor.g, FCMQT.SavedVars.Chat_AddonMessage_MsgColor.b, FCMQT.SavedVars.Chat_AddonMessage_MsgColor.a
end
function FCMQT.SetChat_AddonMessage_MsgColor(r,g,b,a)
	FCMQT.SavedVars.Chat_AddonMessage_MsgColor.r = r
	FCMQT.SavedVars.Chat_AddonMessage_MsgColor.g = g
	FCMQT.SavedVars.Chat_AddonMessage_MsgColor.b = b
	FCMQT.SavedVars.Chat_AddonMessage_MsgColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

-- Get/Set Chat_QuestInfo_HeaderColor
function FCMQT.GetChat_QuestInfo_HeaderColor()
	return 	FCMQT.SavedVars.Chat_QuestInfo_HeaderColor.r, FCMQT.SavedVars.Chat_QuestInfo_HeaderColor.g, FCMQT.SavedVars.Chat_QuestInfo_HeaderColor.b, FCMQT.SavedVars.Chat_QuestInfo_HeaderColor.a
end
function FCMQT.SetChat_QuestInfo_HeaderColor(r,g,b,a)
	FCMQT.SavedVars.Chat_QuestInfo_HeaderColor.r = r
	FCMQT.SavedVars.Chat_QuestInfo_HeaderColor.g = g
	FCMQT.SavedVars.Chat_QuestInfo_HeaderColor.b = b
	FCMQT.SavedVars.Chat_QuestInfo_HeaderColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end

-- Get/Set Chat_QuestInfo_MsgColor
function FCMQT.GetChat_QuestInfo_MsgColor()
	return 	FCMQT.SavedVars.Chat_QuestInfo_MsgColor.r, FCMQT.SavedVars.Chat_QuestInfo_MsgColor.g, FCMQT.SavedVars.Chat_QuestInfo_MsgColor.b, FCMQT.SavedVars.Chat_QuestInfo_MsgColor.a
end
function FCMQT.SetChat_QuestInfo_MsgColor(r,g,b,a)
	FCMQT.SavedVars.Chat_QuestInfo_MsgColor.r = r
	FCMQT.SavedVars.Chat_QuestInfo_MsgColor.g = g
	FCMQT.SavedVars.Chat_QuestInfo_MsgColor.b = b
	FCMQT.SavedVars.Chat_QuestInfo_MsgColor.a = a
	FCMQT.SavedVars.Preset = "Custom"
	FCMQT.QuestsListUpdate(1)
end


--*********************************************************************************
--* Mouse Functions                                                               *
--*********************************************************************************

function FCMQT.MouseTitleController(button, qzone)
	if button == 1 then
		UpdateFilterZone(qzone)
		FCMQT.QuestsListUpdate(1)
	end
	if button == 2 then
		local strAutoHide = ""
		--local strCatView = ""
		local strNotFocusedTrans = ""
		local strHintsHidden = ""
		if FCMQT.QuestsHideZoneOption then strAutoHide = FCMQT.mylanguage.lang_Toggle_AutoHide_off else strAutoHide = FCMQT.mylanguage.lang_Toggle_AutoHide_on end
		if FCMQT.QuestsHybridOption == true then strCatView = FCMQT.mylanguage.lang_Toggle_Category_off else strCatView = FCMQT.mylanguage.lang_Toggle_Category_on end
		if FCMQT.FocusedQuestAreaNoTrans then strNotFocusedTrans = FCMQT.mylanguage.lang_Toggle_NotFocusTrans_off else strNotFocusedTrans = FCMQT.mylanguage.lang_Toggle_NotFocusTrans_on end
		if FCMQT.HideInfoHintsOption then strHintsHidden = FCMQT.mylanguage.lang_Toggle_HintsHidden_on else strHintsHidden = FCMQT.mylanguage.lang_Toggle_HintsHidden_off end
		ClearMenu()
		AddCustomMenuItem(FCMQT.mylanguage.lang_Collaspe_All_Zones, function() AutoFilterZone() end)
		AddCustomMenuItem(FCMQT.mylanguage.lang_Expand_All_Zones, function() RemoveFilterZone() end)
		AddCustomMenuItem("-", function () return end)
		AddCustomMenuItem(strAutoHide, function() FCMQT.ToggleAutoHideZones() end)
		AddCustomMenuItem(strCatView,function() FCMQT.ToggleHybrid() end)
		AddCustomMenuItem(strHintsHidden, function() FCMQT.ToggleHideInfoHintsOption() end)
		AddCustomMenuItem(strNotFocusedTrans, function() FCMQT.ToggleQuestsNoFocusOption() end)
		AddCustomMenuItem(FCMQT.mylanguage.lang_Toggle_HideObjOption_Disabled, function () FCMQT.SetToggleHideObjExceptFocused("Disabled") end)
		AddCustomMenuItem(FCMQT.mylanguage.lang_Toggle_HideObjOption_FocusedQuest, function () FCMQT.SetToggleHideObjExceptFocused("Focused Quest") end)
		AddCustomMenuItem(FCMQT.mylanguage.lang_Toggle_HideObjOption_FocusedZone, function () FCMQT.SetToggleHideObjExceptFocused("Focused Zone") end)
		ShowMenu()
	end
end


function FCMQT.MouseController(button, qindex, qname)
	local valaction = "None"
	if button == 1 then
		valaction = FCMQT.GetButton1()
	elseif button == 2 then
		valaction = FCMQT.GetButton2()
	elseif button == 3 then
		valaction = FCMQT.GetButton3()
	elseif button == 4 then
		valaction = FCMQT.GetButton4()
	elseif button == 5 then
		valaction = FCMQT.GetButton5()
	end
	if (valaction == "Change Assisted Quest") then
		FCMQT.SetFocusedQuest(qindex)
	elseif valaction == "Share a Quest" then
		if GetIsQuestSharable(qindex) then
			ShareQuest(qindex)
			d(FCMQT.mylanguage.lang_console_share.." : "..qname)
		else
			d(FCMQT.mylanguage.lang_console_noshare.." : "..qname)
		end
	elseif valaction == "Filter by Current Zone" then
		FCMQT.SwitchDisplayMode()
	elseif valaction == "Remove a Quest" then
		FCMQT.CheckRemoveQuestBox(qindex, qname)
	elseif valaction == "Show on Map" then
		ZO_WorldMap_ShowQuestOnMap(qindex)
	elseif valaction == "Quest Info to Chat" then
		QuestToChat(qindex)
	elseif valaction == "Quest Options Menu" then
		ClearMenu()
		AddCustomMenuItem("Change Assisted Quest", function() FCMQT.SetFocusedQuest(qindex) end)
		--AddCustomMenuItem("Quest to Chat",function() QuestToChat(qindex) end)
		AddCustomMenuItem("Remove Quest", function() FCMQT.CheckRemoveQuestBox(qindex, qname) end)
		AddCustomMenuItem("Share Quest", function() 
											if GetIsQuestSharable(qindex) then
												ShareQuest(qindex)
												d(FCMQT.mylanguage.lang_console_share.." : "..qname)
											else
												d(FCMQT.mylanguage.lang_console_noshare.." : "..qname)
											end
										end)
		AddCustomMenuItem("Show On Map", function() ZO_WorldMap_ShowQuestOnMap(qindex) end)
		ShowMenu()
	end	
end

function FCMQT.LoadKeybindInfo()
	--zone/area enabled
	FCMQT.QuestsAreaOption = FCMQT.SavedVars.QuestsAreaOption
	--if FCMQT.QuestsAreaOption == true then d("Area On") else d("Area Off") end
	--zone/area hybrid/pure zone
	FCMQT.QuestsHybridOption = FCMQT.SavedVars.QuestsHybridOption
	--if FCMQT.QuestsHybridOption == true then d("Category On") else d("Categpry Off") end
	--enable auto hide zone
	FCMQT.QuestsHideZoneOption = FCMQT.SavedVars.QuestsHideZoneOption
	--if FCMQT.QuestsHideZoneOption == true then d("enable auto hide zone On") else d("enable auto hide zone Off") end
	--Enable Transparency for Not Focused Quests
	FCMQT.QuestsNoFocusOption = FCMQT.SavedVars.QuestsNoFocusOption
	--if FCMQT.QuestsNoFocusOption == true then d("Transparcncey for not focused On") else d("Transparency for not focused is Off") end
	--Focused Quest Zone Not Transparent
	FCMQT.FocusedQuestAreaNoTrans = FCMQT.SavedVars.FocusedQuestAreaNoTrans
	--if FCMQT.FocusedQuestAreaNoTrans == true then d("Focused Quest Zone Not Transparent On") else d("Focused Quest Zone Not Transparent Off") end
	--Hide Optional/Hidden Quest Info/Hints ALL
	FCMQT.HideInfoHintsOption = FCMQT.SavedVars.HideInfoHintsOption
	--if FCMQT.HideInfoHintsOption == true then d("Hide Optional/Hidden Quest Info/Hints ALL On") else d("Hide Optional/Hidden Quest Info/Hints ALL Off") end
	--HideObjOption
	FCMQT.HideObjOption = FCMQT.SavedVars.HideObjOption
	--d("HideObjOption is set to "..FCMQT.HideObjOption)
end

function FCMQT.LoadIcons()
	-- objectiveIcon - gold quest icon
	FCMQT.objectiveIcon = zo_iconFormat("FCMQT/art/Icons/quest_icon1.dds",FCMQT.SavedVars.TextSize * 1.34,FCMQT.SavedVars.TextSize * 1.34)
	-- orobjective + sign
	FCMQT.orObjectiveIcon = zo_iconFormat("FCMQT/art/Icons/orObjective_icon1.dds",FCMQT.SavedVars.TextSize * 1.34,FCMQT.SavedVars.TextSize * 1.34)
	FCMQT.hintIcon = zo_iconFormat("FCMQT/art/Icons/quest_icon1.dds",FCMQT.SavedVars.TextSize * 1.34,FCMQT.SavedVars.TextSize * 1.34)
	--optional white quest icon
	FCMQT.optionalIcon = zo_iconFormat("FCMQT/art/Icons/quest_icon.dds",FCMQT.SavedVars.TextSize * 1.34,FCMQT.SavedVars.TextSize * 1.34)
	-- 
	FCMQT.hiddenIcon = zo_iconFormat("FCMQT/art/Icons/hidden_quest_icon2.dds",FCMQT.SavedVars.TextSize * 1.34,FCMQT.SavedVars.TextSize * 1.34)
end

-- Tests Only
function FCMQT.CheckEvent(eventCode)
	d(eventCode)
end


function CSTest()
    if CS then
        d("CraftStore loaded.")
		if FCMQT.main:isHidden() then
			d("Window No Open Open")
		else
			d("Window No Open Closed")
		end
    else
        d("CraftStore not loaded.")
    end 
end
