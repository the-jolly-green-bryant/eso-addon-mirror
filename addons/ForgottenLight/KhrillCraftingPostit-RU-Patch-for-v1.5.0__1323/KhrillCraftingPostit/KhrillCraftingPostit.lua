------------------------------------------
--           Crafting Post-it           --
--               by Khrill              --
--                                      --
--                v 1.5.0               --
------------------------------------------
-- v1.5.0 : update for Eso 2.4+
-- v1.4.3 : added RU font and options for font size
-- v1.4.2 : added option for font's choice
-- v1.4.1 : encoded the files in UTF-8 (sans BOM) for multilanguage compatibility
-- v1.4.0 : update for Eso 2.3+

local KCP = {}
KCP.name  = "KhrillCraftingPostit"
KCP.version = "1.5.0" 				-- 
KCP_versioncheck = 150 				-- global needed for Handlers definitions

local COLOR_KHRILLSELECT = "FF6A00" -- orange ^^
local COLOR_DISABLED = "A0A0A0" -- gray
local COLOR_CONDITION = "FFFACDFF" --white

KCP.BGTexturesLabel = {"No texture", "Scroll", "Note", "Letter", "Stone tablet", "Skin book", "Paper book", "Rubbing book"}
KCP.BGTextures = {
	[1] = "/esoui/art/buttons/swatchframe_down.dds", 
	[2] = "/esoui/art/lorelibrary/lorelibrary_scroll.dds", 
	[3] = "/esoui/art/lorelibrary/lorelibrary_note.dds",
	[4] = "/esoui/art/lorelibrary/lorelibrary_letter.dds",
	[5] = "/esoui/art/lorelibrary/lorelibrary_stonetablet.dds",
	[6] = "/esoui/art/lorelibrary/lorelibrary_skinbook.dds",
	[7] = "/esoui/art/lorelibrary/lorelibrary_paperbook.dds",
	[8] = "/esoui/art/lorelibrary/lorelibrary_rubbingbook.dds",
}
KCP.BGTexturesCoord = { -- left, right, top, bottom
	[2] = {.20,.80,.05,.93},
	[3] = {.19,.80,.07,.91},
	[4] = {.19,.80,.07,.91},
	[5] = {.05,.95,.06,.96},
	[6] = {.03,.97,.14,.84},
	[7] = {.03,.96,.14,.85},
	[8] = {.03,.98,.14,.86},
}

KCP.FontsLabel = {"Default", "Antique", "Handwritten", "Stone", "Gamepad", "Ru"}
KCP.defaultFontsQuest = {
	[1] = "$(BOLD_FONT)|20|soft-shadow-thick",
	[2] = "$(ANTIQUE_FONT)|20|soft-shadow-thick",
	[3] = "$(HANDWRITTEN_FONT)|20|soft-shadow-thick",
	[4] = "$(STONE_TABLET_FONT)|18|soft-shadow-thick",
	[5] = "$(GAMEPAD_BOLD_FONT)|24|soft-shadow-thick",	
	[6] = "RuEso/fonts/univers57.otf|24|soft-shadow-thin", 
}
KCP.defaultFontsCondition = {
	[1] = "$(BOLD_FONT)|16|soft-shadow-thin",
	[2] = "$(ANTIQUE_FONT)|16|soft-shadow-thin",
	[3] = "$(HANDWRITTEN_FONT)|14|soft-shadow-thin",
	[4] = "$(STONE_TABLET_FONT)|12|soft-shadow-thin",
	[5] = "$(GAMEPAD_BOLD_FONT)|18|soft-shadow-thin",
	[6] = "RuEso/fonts/univers57.otf|20|soft-shadow-thin",
}
KCP.FontsQuest = {}
KCP.FontsCondition = {}

KCP.defaults = {
	Enable	= true,
	anchor	= {TOPRIGHT, TOPRIGHT, -210, 0},
	scale	= .95,
	alpha	= .7,
	BG		= 2,
	BGColor	= "FFFFA0",
	Font 	= 1,
	FontColor = COLOR_KHRILLSELECT,
	FontStyle = true,
	FontSize = false,
	FontSizeQ = 20,
	FontSizeC = 16,
	autohide = false,
	bankmode = false,
	enableButton = true,
	charButton = true,
	sysmessage = false,
}
KCP.defaultColor = nil

KCP.settings = KCP.defaults

KCP.activeAddon = {
	AdvancedFilters = false,
}
KCP.isDebug = false
KCP.langString = nil
KCP.craftSkill = nil

KCP.activeChar = nil
KCP.selectedChar = nil
KCP.characterList = {}
KCP.Quests = nil
--	KCP.Quests[craftType] = {
--		index = questIndex,
--		name = questName,
--		level = questLevel,
--		conditions = {
--			[conditionIndex] = {name=conditionText, complete=isComplete}
--		}
--	}
KCP.GlobalQuests = {}
--	KCP.GlobalQuests[<character>] = {
--		classId = ,
--		Quests = KCP.Quests
--	}


local TEXTURE_ICON = {
	[CRAFTING_TYPE_ALCHEMY] = "/esoui/art/progression/icon_alchemist.dds",
	[CRAFTING_TYPE_BLACKSMITHING] = "/esoui/art/progression/icon_armorsmith.dds",
	[CRAFTING_TYPE_CLOTHIER] = "/esoui/art/characterwindow/gearslot_tabard.dds", --"/esoui/art/characterwindow/gearslot_chest.dds",
	[CRAFTING_TYPE_ENCHANTING] = "/esoui/art/crafting/enchantment_tabicon_essence_down.dds",
	[CRAFTING_TYPE_PROVISIONING] = "/esoui/art/crafting/provisioner_indexicon_meat_down.dds",
	[CRAFTING_TYPE_WOODWORKING] = "/esoui/art/worldmap/map_ava_tabicon_woodmill_down.dds", --"/esoui/art/progression/icon_bows.dds",
--	["LEFT"] = "/esoui/art/bossbar/bossbar_bracket_left.dds",
--	["RIGHT"] = "/esoui/art/bossbar/bossbar_bracket_right.dds",
}
local TEXTURE_CLASS = {
	[0] = "/esoui/art/miscellaneous/help_icon.dds",
	[1] = "/esoui/art/contacts/social_classicon_dragonknight.dds",
	[2] = "/esoui/art/contacts/social_classicon_sorcerer.dds",
	[3] = "/esoui/art/contacts/social_classicon_nightblade.dds",
	[6] = "/esoui/art/contacts/social_classicon_templar.dds"
}

local CraftTable = {
	[CRAFTING_TYPE_ALCHEMY] = "Alchemy",
	[CRAFTING_TYPE_BLACKSMITHING] = "Blacksmithing",
	[CRAFTING_TYPE_CLOTHIER] = "Clothier",
	[CRAFTING_TYPE_ENCHANTING] = "Enchanting",
	[CRAFTING_TYPE_PROVISIONING] = "Provisioning",
	[CRAFTING_TYPE_WOODWORKING] = "Woodworking",
}

local function HexToRGBA( hex )
	if string.len(hex) == 6 then hex = hex.."FF" end
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end
local function RGBAToHex( r, g, b, a )
	if a == nil then a = 1 end
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x%02x", r * 255, g * 255, b * 255, a * 255)
end
local function getKeyByValue(t, value)
	for k,v in pairs(t) do
		if v==value then return k end
	end
	return nil
end

local function getPrevNext(baseSkill)
	local myprevious = nil
	local mynext = nil
	local first = nil
	local current = nil
	local getnext = false
--d("getPrevNext "..tostring(baseSkill))
	-- loop into table to find base and get previous & next item
	-- verify when autohide activated to keep only valide quests
	for k,v in pairs(CraftTable) do
--d(k..","..v.." ("..tostring(baseSkill)..")")
		if first == nil and KCP.Quests[v] ~= nil then
			first = k
			if baseSkill == nil then baseSkill = k end
		end
		if getnext and KCP.Quests[v] ~= nil then
			mynext = k
			getnext = false
		end
		if k == baseSkill then
			myprevious = current
			getnext = true
		end
		if KCP.Quests[v] ~= nil then current = k end
--d("first="..tostring(first)..",current="..tostring(current)..",myprevious="..tostring(myprevious)..",mynext="..tostring(mynext))
	end
	if myprevious == nil then myprevious = current end -- previous of 1st item = last item
	if mynext == nil then mynext = first end -- next of last item = first item
	KCP.craftSkill = baseSkill

	return myprevious, mynext
end

local function addButton(parent, name, callbackFunction, text, font, tooltipText, tooltipAlign, textureNormal, textureMouseOver, textureClicked, width, height, left, top, alignValue, alignControl, alignControlValue, hideButton)
	--Add a button to an existing parent control
--	d("addButton "..name)
	--Abort needed?
	if  (parent == nil or name == nil or callbackFunction == nil
		or width <= 0 or height <= 0 )
		and (textureNormal == nil or text == nil) then
			return nil
	end
	local button
    --Does the button already exist?
    button = WINDOW_MANAGER:GetControlByName(name, "")
    if button == nil then
        --Button does not exist yet and it should be hidden? Abort here!
        if hideButton == true then return nil end
        --Create the button control at the parent
        button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    end
    --Button was created?
    if button ~= nil then
        --Button should be hidden?
        if hideButton == false then
			local highlightColor = nil
			local isColorInitiated = false
            --Set the button's size
            button:SetDimensions(width, height)
            --Align the button
            if alignControl == nil then
                alignControl = parent
            end
            --SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
			if alignValue == nil then alignValue = TOPLEFT end
			if alignControlValue == nil then alignControlValue = TOPLEFT end
			button:ClearAnchors()
            button:SetAnchor(alignValue, alignControl, alignControlValue, left, top)
            --Texture or text?
            if (text ~= nil) then
                --Text
				highlightColor = COLOR_KHRILLSELECT
                --Set the button's font
                if font == nil then
                    button:SetFont("ZoFontGameSmall")
                else
                    button:SetFont(font)
                end
                --Set the button's text
                button:SetText(text)
            else
                --Texture
                local texture
 
                --Check if texture exists
                texture = WINDOW_MANAGER:GetControlByName(name .. "Texture", "")
                if texture == nil then
                    --Create the texture for the button to hold the image
                    texture = WINDOW_MANAGER:CreateControl(name .. "Texture", button, CT_TEXTURE)
                end
                texture:SetAnchorFill()
                --Set the texture for normale state now
                texture:SetTexture(textureNormal)
                --Do we have seperate textures for the button states?
				if textureMouseOver == nil and textureClicked == nil then
					highlightColor = COLOR_KHRILLSELECT
					isColorInitiated = (texture:GetColor() == HexToRGBA(highlightColor))
				end
                button.upTexture      	= textureNormal
                button.downTexture    	= textureMouseOver or textureNormal
                button.clickedTexture 	= textureClicked or textureNormal
				button.highlightColor	= highlightColor
				button.isColorInitiated = isColorInitiated
            end
            if tooltipAlign == nil then tooltipAlign = TOP end
            --Set a tooltip?
            if tooltipText ~= nil then
                if button:GetHandler("OnMouseEnter") == nil or (GetControl("Wandalize_PaintItBlack") and not WandalizeKCP_Checkversion) then button:SetHandler("OnMouseEnter", function(self)
						self:GetChild(1):SetTexture(self.downTexture)
						if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA(self.highlightColor)) end
						ZO_Tooltips_ShowTextTooltip(button, tooltipAlign, tooltipText)
					end)
				end
                if button:GetHandler("OnMouseExit") == nil or (GetControl("Wandalize_PaintItBlack") and not WandalizeKCP_Checkversion) then button:SetHandler("OnMouseExit", function(self)
						self:GetChild(1):SetTexture(self.upTexture)
						if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA("FFFFFF00")) end
						ZO_Tooltips_HideTextTooltip()
					end)
				end
            else
                if button:GetHandler("OnMouseEnter") == nil or (GetControl("Wandalize_PaintItBlack") and not WandalizeKCP_Checkversion) then button:SetHandler("OnMouseEnter", function(self)
						self:GetChild(1):SetTexture(self.downTexture)
						if self.highlightColor ~= nil then self:GetChild(1):SetColor(self.highlightColor) end
				   end)
			   end
                if button:GetHandler("OnMouseExit") == nil or (GetControl("Wandalize_PaintItBlack") and not WandalizeKCP_Checkversion) then button:SetHandler("OnMouseExit", function(self)
						self:GetChild(1):SetTexture(self.upTexture)
						if self.highlightColor ~= nil then self:GetChild(1):SetColor(HexToRGBA("FFFFFF00")) end
				   end)
				end
            end
            --Set the callback function of the button
            if button:GetHandler("OnClicked") == nil or (GetControl("Wandalize_PaintItBlack") and not WandalizeKCP_Checkversion) then button:SetHandler("OnClicked", callbackFunction) end
			if button:GetHandler("OnMouseDown") == nil or (GetControl("Wandalize_PaintItBlack") and not WandalizeKCP_Checkversion) then button:SetHandler("OnMouseDown", function(butn, ctrl, alt, shift, command)
					butn:GetChild(1):SetTexture(butn.clickedTexture)
				end)
			end
			--Show the button and make it react on mouse input
			button:SetHidden(false)
			button:SetMouseEnabled(true)
			--Return the button control
			return button
		else
			--Hide the button and make it not reacting on mouse input
			button:SetHidden(true)
			button:SetMouseEnabled(false)
		end
	else
		return nil
	end
end

-- // **********
-- //  Quest
-- // **********
--[[QuestType 
## QUEST_TYPE_AVA 
## QUEST_TYPE_AVA_GRAND 
## QUEST_TYPE_AVA_GROUP 
## QUEST_TYPE_CLASS 
## QUEST_TYPE_CRAFTING 
## QUEST_TYPE_DUNGEON 
## QUEST_TYPE_GROUP 
## QUEST_TYPE_GUILD 
## QUEST_TYPE_MAIN_STORY 
## QUEST_TYPE_NONE 
## QUEST_TYPE_RAID 
]]
function KCP:getCraftName(craftString, pos)
	if pos == nil then pos = 1 end
	return string.upper(KCP.langString.CraftName[craftString][pos])
end
function KCP:isGoodCraftQuest(questName)
	-- find selected craft in questName with language keys name? 
	local found = nil --false
	for k,v in pairs(CraftTable) do
		for i=1, #KCP.langString.CraftName[v] do
			if string.find(string.lower(questName), string.lower(KCP:getCraftName(v,i))) ~= nil then found = k end
			--d(string.lower(questName)..", "..string.lower(KCP:getCraftName(v,i)).." => "..tostring(found))
		end
	end
	return (found)
end

function KCP:ScanQuest()
	-- Scan quest journal and find crafting quests
	local found = 0
	local numSteps, numConditions
	local selCraft
	KCP:msg("--scan quests="..GetNumJournalQuests(), false)
	KCP.Quests = {} --reinit
	for questIndex=1, MAX_JOURNAL_QUESTS  do --GetNumJournalQuests() do
		local questType = GetJournalQuestType(questIndex) 
		if questType == QUEST_TYPE_CRAFTING or questType == QUEST_TYPE_NONE then
			--GetJournalQuestInfo(questIndex)
			--Returns: string questName, string backgroundText, string activeStepText, integer activeStepType, string activeStepTrackerOverrideText, bool completed, bool tracked, integer questLevel, bool pushed, integer questType			
			local questName, _, _, _, activeStepTrackerOverrideText, completed, _, questLevel, _, _ = GetJournalQuestInfo(questIndex)
	KCP:msg(questName.." ("..tostring(questLevel).."): completed="..tostring(completed), false)
			selCraft = KCP:isGoodCraftQuest(questName)
			if selCraft ~= nil then
				KCP.Quests[CraftTable[selCraft]] = { index=questIndex, name=questName, level = questLevel, conditions = {} }
				numSteps = GetJournalQuestNumSteps(questIndex)
				local stepIndex = 1 -- quest objectives are on first step (others are "hints")
				numConditions = GetJournalQuestNumConditions(questIndex, stepIndex) 
	KCP:msg("-> step "..stepIndex.."/"..numSteps..":"..numConditions, false)
	
				if numConditions == 0 then --if no condition, get string from step
					KCP.Quests[CraftTable[selCraft]].conditions[1]={name=activeStepTrackerOverrideText, complete=false}
				else
					for conditionIndex=1,numConditions do
						--GetJournalQuestConditionInfo(luaindex journalQuestIndex, luaindex stepIndex, luaindex conditionIndex)
						--Returns: string conditionText, integer current, integer max, bool isFailCondition, bool isComplete, bool isCreditShared 
						local conditionText, current, maximum, isFailCondition, isComplete, _ = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex)
	KCP:msg("* "..conditionIndex..":".. tostring(conditionText) .."; completed="..tostring((current == maximum) or isComplete), false)
						if conditionText ~= nil and conditionText ~= "" then
							KCP.Quests[CraftTable[selCraft]].conditions[conditionIndex]={name=conditionText, complete=((current == maximum) or isComplete)}
						end
					end
				end
				if selCraft == KCP.craftSkill or KCP.Debug then found = found +1 end
			end
		end
	end
	KCP:msg("--end scan", false)
	KCP:msg("activeChar: "..tostring(KCP.activeChar))
	if KCP.settings.sysmessage and KCP.craftSkill ~= nil then CHAT_SYSTEM:AddMessage("|c"..COLOR_KHRILLSELECT.."["..KCP.name.."]|r : "..zo_iconFormat(TEXTURE_ICON[KCP.craftSkill], 16, 16).." ".. KCP:getCraftName(CraftTable[KCP.craftSkill]) .." => "..found.." "..KCP.langString.MESSAGE_foundQuest) end
	-- save quest into DB
	KCP.settings.Quests = {}
	KCP.settings.Quests = KCP.Quests
	if KCP.GlobalQuests[KCP.activeChar] == nil then
		KCP.GlobalQuests[KCP.activeChar] = {}
		KCP.GlobalQuests[KCP.activeChar].classId = GetUnitClassId("player")
		table.insert(KCP.characterList, KCP.activeChar)
	end
	KCP.GlobalQuests[KCP.activeChar].Quests = {}
	KCP.GlobalQuests[KCP.activeChar].Quests = KCP.Quests
	-- if previous selected char then restore KCP.Quests
	if KCP.selectedChar ~= nil and KCP.selectedChar ~= KCP.activeChar then KCP.Quests = KCP.GlobalQuests[KCP.selectedChar].Quests end
end
function KCP:UpdateQuest(selectedCraft, questIndex)
	-- update quest conditions
	KCP:msg("UpdateQuest:"..selectedCraft..","..questIndex)
	KCP.Quests[selectedCraft].conditions = {}
	local numSteps = GetJournalQuestNumSteps(questIndex)
	local stepIndex = 1 -- quest objectives are on first step (others are "hints")
	local numConditions = GetJournalQuestNumConditions(questIndex, stepIndex) 
--	d("-> step "..stepIndex.."/"..numSteps..":"..numConditions)
	if numConditions == 0 then --if no condition, get string from step
		local _, _, _, _, activeStepTrackerOverrideText, _, _, _, _, _ = GetJournalQuestInfo(questIndex)
		KCP.Quests[selectedCraft].conditions[1]={name=activeStepTrackerOverrideText, complete=false}
	else
		for conditionIndex=1,numConditions do
			local conditionText, current, maximum, isFailCondition, isComplete, _ = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex)
--	d("* "..conditionIndex..":".. tostring(conditionText) .."; completed="..tostring((current == maximum) or isComplete))
			if conditionText ~= nil and conditionText ~= "" then
				KCP.Quests[selectedCraft].conditions[conditionIndex]={name=conditionText, complete=((current == maximum) or isComplete)}
			end
		end
	end
	-- save quest into DB
	KCP.settings.Quests = KCP.Quests
	KCP.GlobalQuests[KCP.activeChar].Quests = KCP.Quests
	-- refresh UI
	KCP:addQuestPanel(selectedCraft)
	KCP:RefreshUI()
	KCP:addCharButton()
end

function KCP_GetQuests()
	return KCP.Quests
end


-- // **********
-- //  Events
-- // **********
--[[TradeskillType 
## CRAFTING_TYPE_ALCHEMY 
## CRAFTING_TYPE_BLACKSMITHING 
## CRAFTING_TYPE_CLOTHIER 
## CRAFTING_TYPE_ENCHANTING 
## CRAFTING_TYPE_INVALID 
## CRAFTING_TYPE_PROVISIONING 
## CRAFTING_TYPE_WOODWORKING 
]]
function KCP:OnCraftingStationInteract(eventCode, craftSkill, sameStation)
	-- // active craft station
	if KCP.settings.Enable then 
		KCP:msg("--OnCrafting: "..craftSkill, false)
		if craftSkill == CRAFTING_TYPE_ALCHEMY or craftSkill == CRAFTING_TYPE_BLACKSMITHING or craftSkill == CRAFTING_TYPE_CLOTHIER or craftSkill == CRAFTING_TYPE_ENCHANTING or craftSkill == CRAFTING_TYPE_PROVISIONING or craftSkill == CRAFTING_TYPE_WOODWORKING then
			KCP.craftSkill = craftSkill
		else
			KCP.craftSkill = nil
		end
		-- valide craft station -> open UI
		if KCP.craftSkill ~= nil then
			KCP:OpenUI()
		end
	end
end
function KCP:OnEndCraftingStation(eventCode)
	KCP:CloseUI()
end

function KCP:OnCraftCompleted(eventCode, craftSkill) -- not needed...
	-- when craft completed, check if crafting quest is updated
end
function KCP:OnQuestConditionCounterChanged(eventCode, journalIndex, questName, conditionText, conditionType, currConditionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isComplete, isConditionComplete, isStepHidden)
--EVENT_QUEST_CONDITION_COUNTER_CHANGED (integer eventCode, integer journalIndex, string questName, string conditionText, integer conditionType, integer currConditionVal, integer newConditionVal, integer conditionMax, bool isFailCondition, string stepOverrideText, bool isPushed, bool isComplete, bool isConditionComplete, bool isStepHidden)
	if KCP.selectedChar ~= KCP.activeChar then
		KCP:msg("change: "..KCP.selectedChar.." => "..KCP.activeChar)
		KCP.selectedChar = KCP.activeChar
		KCP.Quests = KCP.GlobalQuests[KCP.activeChar].Quests
	end
	if  KCP.Quests ~= nil then
		KCP:msg("OnQuestConditionCounterChanged: "..journalIndex.."="..questName.."("..tostring(isComplete)..")", false)
		KCP:msg("-> "..stepOverrideText.."="..newConditionVal.."/"..conditionMax, false)
		local selCraft = KCP:isGoodCraftQuest(questName)
--d("selcraft="..tostring(selcraft))
		if selCraft ~= nil and CraftTable[selCraft]~=nil then
			KCP.craftSkill = selCraft
			if KCP.Quests[CraftTable[selCraft]] ~= nil and KCP.Quests[CraftTable[selCraft]].index == journalIndex then
				-- new condition then refresh quest
				KCP:UpdateQuest(CraftTable[selCraft], journalIndex)
			end
		end
		-- if KCP.Quests[CraftTable[KCP.craftSkill]] ~= nil and KCP.Quests[CraftTable[KCP.craftSkill]].index == journalIndex then
			-- -- new condition then refresh quest
			-- KCP:UpdateQuest(CraftTable[KCP.craftSkill], journalIndex)
		-- end
	end
end
function KCP:OnQuestAdvanced(eventCode, journalIndex, questName, isPushed, isComplete, mainStepChanged)
--EVENT_QUEST_ADVANCED (integer eventCode, integer journalIndex, string questName, bool isPushed, bool isComplete, bool mainStepChanged)
	if KCP.selectedChar ~= KCP.activeChar then
		KCP.selectedChar = KCP.activeChar
		KCP.Quests = KCP.GlobalQuests[KCP.activeChar].Quests
	end
	if  KCP.Quests ~= nil then
		KCP:msg("OnQuestAdvanced: "..journalIndex.."="..questName.."("..tostring(isComplete)..")")
		local selCraft = KCP:isGoodCraftQuest(questName)
		if selCraft ~= nil and CraftTable[selCraft]~=nil then
			KCP.craftSkill = selCraft
			if KCP.Quests[CraftTable[selCraft]] ~= nil and KCP.Quests[CraftTable[selCraft]].index == journalIndex then
		--		if mainStepChanged then
					-- new step then refresh quest
					KCP:UpdateQuest(CraftTable[selCraft], journalIndex)
		--		end
			end
		end
		-- if KCP.Quests[CraftTable[KCP.craftSkill]] ~= nil and KCP.Quests[CraftTable[KCP.craftSkill]].index == journalIndex then
	-- --		if mainStepChanged then
				-- -- new step then refresh quest
				-- KCP:UpdateQuest(CraftTable[KCP.craftSkill], journalIndex)
	-- --		end
		-- end
	end
end

function KCP:OnQuestAdded(eventCode, journalIndex, questName, objectiveName)
--EVENT_QUEST_ADDED (integer eventCode, integer journalIndex, string questName, string objectiveName) 
	KCP:msg("OnQuestAdded: "..questName)
	KCP:ScanQuest() --update global quests
	if not KCPUI:IsHidden()then KCP:RefreshUI() end
end
function KCP:OnQuestComplete(eventCode, questName, level, previousExperience, currentExperience, rank, previousPoints, currentPoints)
--EVENT_QUEST_COMPLETE (integer eventCode, string questName, integer level, integer previousExperience, integer currentExperience, integer rank, integer previousPoints, integer currentPoints)
	KCP:msg("OnQuestComplete: "..questName.."("..tostring(level)..")")
	KCP:ScanQuest() --update global quests
	if not KCPUI:IsHidden()then KCP:RefreshUI() end
end
function KCP:OnQuestRemoved(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex)
--EVENT_QUEST_REMOVED (integer eventCode, bool isCompleted, integer journalIndex, string questName, integer zoneIndex, integer poiIndex)
	KCP:msg("OnQuestRemoved: "..questName)
	KCP:ScanQuest() --update global quests
	if not KCPUI:IsHidden()then KCP:RefreshUI() end
end

function KCP:OnOpenBank(eventCode)
--EVENT_OPEN_BANK (integer eventCode)
--EVENT_OPEN_GUILD_BANK (integer eventCode)
	-- // active craft station
	KCP:msg("--OnOpenBank:"..tostring(KCP.settings.bankmode), false)
	if KCP.settings.Enable then
		if KCP.settings.bankmode then 
			KCP:OpenUI()
			KCP:RefreshUI()
		else
			KCP:CheckEnabledBtn()
		end
	end
end
function KCP:OnCloseBank(eventCode)
--EVENT_CLOSE_BANK (integer eventCode)
--EVENT_CLOSE_GUILD_BANK (integer eventCode)
	KCP:CloseUI()
end

function KCP_navButtonClick(button)
--d(button.skill)
	KCP.craftSkill = button.skill
--	KCP:updateNavButtons(KCP.craftSkill)
	KCP:RefreshUI()
end

function KCP_SetPanel(craftSkill)
	--show choosen writs
	if KCP.Quests == nil then KCP:OpenUI() end
--	if craftSkill ~= nil and CraftTable[craftSkill] ~= nil then
		KCP.craftSkill = craftSkill
		KCP:RefreshUI()
--	end
end

function KCP_SaveAnchor()
	-- Save the new position of windows
--d("--SaveAnchor")
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = KCPUI:GetAnchor()
	if isValidAnchor then
		KCP.settings.anchor = { point, relativePoint, offsetX, offsetY }
	end
end

function KCP_ToggleByKey()
	-- show/hide by keybind
	SetGameCameraUIMode(KCPUI:IsHidden())
	if KCPUI:IsHidden() then
		KCP:OpenUI()
--		KCP:updateNavButtons(KCP.craftSkill)
		KCP:RefreshUI(true)
	else
		KCP:CloseUI()
	end
end

function KCP_ToggleChar(name)
	-- button for change selectedChar and so Quests
	KCP:msg("--KCP_ToggleChar: "..name)
	KCP.selectedChar = name
	KCP.Quests = KCP.GlobalQuests[KCP.selectedChar].Quests
	KCP:RefreshUI()
	KCP:addCharButton()
end

-- // **********
-- //  UI PANEL
-- // **********
function KCP:addQuestPanel(selectedCraft)
	if selectedCraft == nil then selectedCraft = 0 end
	-- display panel on screen for quest type
	KCP:msg("--addQuestPanel:"..selectedCraft)
	-- reset UI
	KCP:CleanUI()
	local panelControl = GetControl("KCP_QuestPanel_"..tostring(selectedCraft))
	if panelControl == nil then
		panelControl = CreateControlFromVirtual("KCP_QuestPanel_", KCPUI, "KCP_QuestPanel", tostring(selectedCraft))
	end
	-- replace panel in function of scale
	local delta = tonumber((1 - KCP.settings.scale)*60)
	panelControl:ClearAnchors()
	panelControl:SetAnchor(TOPLEFT, KCPUI, TOPLEFT, 50 -delta, 50 -delta)
	
	-- place quest name
	local labelControl = GetControl("KCP_QuestPanel_"..tostring(selectedCraft).."Label")
	KCP:ChangeFont(labelControl, KCP.FontsQuest[KCP.settings.Font])
	if KCP.Quests[selectedCraft] == nil then
		labelControl:SetText(KCP.langString.MESSAGE_noQuest)
	else
		labelControl:SetText("|c"..COLOR_DISABLED.."["..KCP.Quests[selectedCraft].level.."]|r "..KCP.Quests[selectedCraft].name)
		local _, _, _, _, offsetX, offsetY = labelControl:GetAnchor()
	
		-- and all conditions
		local count = 0
		local precControl = nil
		for conditionId, conditionValue in pairs(KCP.Quests[selectedCraft].conditions) do
--	d("--addcondition:"..conditionId.."="..conditionValue.name..","..tostring(conditionValue.complete))

			local conditionControl = GetControl("KCP_ConditionPanel_"..tostring(conditionId))
			if conditionControl == nil then
				conditionControl = CreateControlFromVirtual("KCP_ConditionPanel_", KCPUI, "KCP_ConditionPanel", tostring(conditionId))
			end
			local delta = 0
			if precControl ~= nil then
				_, _, _, _, _, delta = precControl:GetAnchor()
				delta = delta + precControl:GetHeight() +5
			end
			conditionControl:ClearAnchors()
			conditionControl:SetAnchor(TOPLEFT, labelControl, BOTTOMLEFT, offsetX, delta +offsetY)
--			conditionControl:SetAnchor(TOPLEFT, labelControl, BOTTOMLEFT, offsetX, count*25 +offsetY +5)
			count = count +1

			local iconControl = GetControl("KCP_ConditionPanel_"..tostring(conditionId).."Check")
			iconControl:SetColor(HexToRGBA(COLOR_KHRILLSELECT)) 
			iconControl:SetHidden(not conditionValue.complete) -- visible if complete
			local textControl = GetControl("KCP_ConditionPanel_"..tostring(conditionId).."Label")
			KCP:ChangeFont(textControl, KCP.FontsCondition[KCP.settings.Font])
			textControl:SetText(conditionValue.name)
			if conditionValue.complete then
				textControl:SetColor(HexToRGBA(COLOR_DISABLED)) 
			else
				textControl:SetColor(HexToRGBA(KCP.settings.FontColor))
			end
			if KCP.settings.FontStyle then
				textControl:SetStyleColor(0,0,0,1)
			else
				textControl:SetStyleColor(0,0,0,0)
			end
--			if textControl:DidLineWrap() then
			conditionControl:SetDimensions(conditionControl:GetWidth(),textControl:GetTextHeight())
--			end
			conditionControl:SetHidden(false)
			precControl = conditionControl
		end
	end
--	KCP:ChangeFontSize()
	panelControl:SetHidden(false)
end
function KCP:removePanel(selectedCraft)
--d("--removePanel:"..selectedCraft)
	local panelControl = GetControl("KCP_QuestPanel_"..tostring(selectedCraft))
	if panelControl ~= nil and not panelControl:IsControlHidden() then
		 panelControl:SetHidden(true)
	end
end
function KCP:updateNavButtons(baseSkill)
--d("--updateNavButtons:"..tostring(baseSkill))
	local prevSkill, nextSkill = getPrevNext(baseSkill)
--d("prev="..tostring(prevSkill)..", next="..tostring(nextSkill))
	if prevSkill == nil and nextSkill == nil then
		KCPUILeftIcon:SetHidden(true)
		KCPUIRightIcon:SetHidden(true)
		KCPUILeftButton:SetHidden(true)
		KCPUIRightButton:SetHidden(true)	
	else
		KCPUILeftIcon:SetTexture(TEXTURE_ICON[prevSkill])
		KCPUIRightIcon:SetTexture(TEXTURE_ICON[nextSkill])
		KCPUILeftButton.skill = prevSkill
		KCPUIRightButton.skill = nextSkill

		KCPUILeftIcon:SetHidden(false)
		KCPUIRightIcon:SetHidden(false)
		KCPUILeftButton:SetHidden(false)
		KCPUIRightButton:SetHidden(false)	
	end
end
function KCP:CheckEnabledBtn()
    --Create and add the button with textures, tooltip and callback function
	--parent, name, callbackFunction, text, font, tooltipText, tooltipAlign, textureNormal, textureMouseOver, textureClicked, width, height, left, top, alignValue, alignControl, alignControlValue, hideButton
	local textureNb = KCP.settings.BG
	if KCP.settings.BG == 1 then textureNb = 2 end

	--other addons compatibility
--	KCP.activeAddon.AdvancedFilters = (AF_Strings ~= nil)
	KCP.activeAddon.AdvancedFilters = false
	if ZO_PlayerBankSearchBox:GetTop() < ZO_PlayerBankMenuDivider:GetTop() then KCP.activeAddon.AdvancedFilters = true end
	if KCP.activeAddon.AdvancedFilters and ZO_PlayerBankSearchBox ~= nil and not ZO_PlayerBankSearchBox:IsControlHidden() then --check for Adv.Filter addon
		addButton(ZO_PlayerBankMenu, "ZO_PlayerBankMenuButtonShowKCP", KCP_ToggleByKey, nil, nil, "|c"..COLOR_KHRILLSELECT..KCP.langString.SI_BINDING_NAME_KCPTOGGLE.."|r", TOP, KCP.BGTextures[textureNb], nil, nil, 50, 25, 0, 0, TOPRIGHT, ZO_PlayerBankSearchBox, TOPLEFT, not KCP.settings.enableButton)
	else
		addButton(ZO_PlayerBankMenu, "ZO_PlayerBankMenuButtonShowKCP", KCP_ToggleByKey, nil, nil, "|c"..COLOR_KHRILLSELECT..KCP.langString.SI_BINDING_NAME_KCPTOGGLE.."|r", TOP, KCP.BGTextures[textureNb], nil, nil, 50, 25, 50, 12, TOPLEFT, ZO_PlayerBankMenu, TOPLEFT, not KCP.settings.enableButton)
	end
	if KCP.activeAddon.AdvancedFilters and ZO_GuildBankSearchBox ~= nil and not ZO_GuildBankSearchBox:IsControlHidden() then --check for Adv.Filter addon
		addButton(ZO_GuildBankMenu, "ZO_GuildBankMenuButtonShowKCP", KCP_ToggleByKey, nil, nil, "|c"..COLOR_KHRILLSELECT..KCP.langString.SI_BINDING_NAME_KCPTOGGLE.."|r", TOP, KCP.BGTextures[textureNb], nil, nil, 50, 25, 0, 0, TOPRIGHT, ZO_GuildBankSearchBox, TOPLEFT, not KCP.settings.enableButton)
	else
		addButton(ZO_GuildBankMenu, "ZO_GuildBankMenuButtonShowKCP", KCP_ToggleByKey, nil, nil, "|c"..COLOR_KHRILLSELECT..KCP.langString.SI_BINDING_NAME_KCPTOGGLE.."|r", TOP, KCP.BGTextures[textureNb], nil, nil, 50, 25, 50, 12, TOPLEFT, ZO_GuildBankMenu, TOPLEFT, not KCP.settings.enableButton)
	end
end
function KCP:CleanUI()
	-- delete all quest panel with Hidden in main Window
--	d("--CleanUI ")
	for i=1,KCPUI:GetNumChildren() do
		local controlName = KCPUI:GetChild(i):GetName()
		if string.find(controlName, "KCP_") ~= nil then
			KCPUI:GetChild(i):SetHidden(true)
		end
	end
end
function KCP:RefreshUI(force)
	KCP:msg("--RefreshUI : "..tostring(KCP.craftSkill))
	--left & right buttons
	KCP:updateNavButtons(KCP.craftSkill)		
	if KCP.craftSkill ~= nil then
		--intialize UI (icon & label for craft)
		KCPUIIcon:SetTexture(TEXTURE_ICON[KCP.craftSkill])
		KCPUILabel:SetText(KCP:getCraftName(CraftTable[KCP.craftSkill]))
		KCP:addQuestPanel(CraftTable[KCP.craftSkill])
		-- if quest available...
		if KCP.Quests[CraftTable[KCP.craftSkill]] ~= nil then
			-- show it
			KCPUI:SetHidden(false)
		else
			KCPUI:SetHidden(KCP.settings.autohide and KCP.selectedChar == KCP.activeChar) --autohide only on main char
		end
	else
		KCPUILabel:SetText(KCP.langString.MESSAGE_noCraft)
		KCP:addQuestPanel(nil)
		KCPUI:SetHidden(KCP.settings.autohide and force ~= true)
	end
end
function KCP:OpenUI()
	--activate events
	KCP:registerEvents(true)
		
	--get quests
	KCP.selectedChar = KCP.activeChar
	KCP:ScanQuest()

	--show UI
	KCP:addCharButton()
	KCP:CheckEnabledBtn()
	KCPUILeftIcon:SetHidden(true)
	KCPUIRightIcon:SetHidden(true)
	KCPUILeftButton:SetHidden(true)
	KCPUIRightButton:SetHidden(true)
	KCP:RefreshUI()
end
function KCP:CloseUI()
	KCPUI:SetHidden(true)
	KCP:CleanUI()
	KCP:registerEvents(false)
end

function KCP:addCharButton()
	-- add a button for each character who have crafting quests
	local cpt = 0
	local supportControl = GetControl("KCPUICharPanel")
	local nameControl = GetControl("KCPUICharName")
	local name, data
	for i=1, #KCP.characterList do
		name = KCP.characterList[i]
		data = KCP.GlobalQuests[name]
	--for name, data in pairs(KCP.GlobalQuests) do
		if name == KCP.selectedChar then
			nameControl:SetText(name)
			if name == KCP.activeChar then --active character in orange
				nameControl:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
				nameControl:SetStyleColor(HexToRGBA("000000FF"))
			else
				nameControl:SetColor(HexToRGBA("FFFFFF00"))
				nameControl:SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
			end
		end
		if data.Quests ~= nil then --and name ~= KCP.selectedChar then
			addButton(supportControl, "KCPUICharPanelButton"..name, function(...) KCP_ToggleChar(KCP.characterList[i]) end, nil, nil, "|c"..COLOR_KHRILLSELECT..name.."|r", BOTTOM, TEXTURE_CLASS[data.classId], nil, nil, 24, 24, 25*cpt, 0, LEFT, supportControl, LEFT, false)
			if name == KCP.selectedChar then --highlight orange
				GetControl("KCPUICharPanelButton"..name.."Texture"):SetColor(HexToRGBA(COLOR_KHRILLSELECT))
			else
				GetControl("KCPUICharPanelButton"..name.."Texture"):SetColor(HexToRGBA("FFFFFF00"))
			end
			cpt = cpt +1
		end
	end
	KCPUICharPanel:SetHidden(not KCP.settings.charButton)
end
function KCP_getSelectedChar()
	return KCP.selectedChar
end


-- // **********
-- //  Init
-- // **********
function KCP:GetLanguage()
	local lang = GetCVar("language.2")
--	lang = "en" --for testing
	
	--supported languages
	if(lang == "fr") then return lang end
	if(lang == "de") then return lang end
	if(lang == "es") then return lang end
	if(lang == "ru") then return lang end

	--return english if not supported
	return "en"
end
function KCP:initGlobalQuests()
	-- init KCP.GlobalQuests structure with data from account's characters
	local characterList = {}
	for account, accountData in pairs(KhrillCraftingPostit_settings.Default) do
		if account == GetDisplayName() then
			for player, data in pairs (accountData) do
				if data.Quests ~= nil then table.insert(characterList, player) end
			end
			table.sort(characterList)
			KCP.characterList = characterList
			
			for i=1, #characterList do
				local player = characterList[i]
				if accountData[player] then
					local data = accountData[player]
					KCP.GlobalQuests[player] = {}
					if data ~= nil then
						if data.classId ~= nil then KCP.GlobalQuests[player].classId = data.classId end
						if data.Quests ~= nil then KCP.GlobalQuests[player].Quests = data.Quests end
					end
				end
			end
		end
	end
end
function KCP:OnInit(eventCode, addOnName)
	-- check addons compatibility is active?
	if ( addOnName == "AdvancedFilters") then KCP.activeAddon.AdvancedFilters = true end

    if ( addOnName ~= KCP.name) then return end
	
	--language
	KCP.langString = KCP_Lang[KCP:GetLanguage()]
	if KCP.langString == "ru" then KCP.defaults.Font = 6 end --ru font by default
	--bindings
	ZO_CreateStringId("SI_BINDING_NAME_KCPTOGGLE", KCP.langString.SI_BINDING_NAME_KCPTOGGLE)
	--settings
	local rd,gd,bd = HexToRGBA(KCP.defaults.FontColor)
	KCP.defaultColor = {r=rd, g=gd, b=bd, a=1}
	
	KCP.activeChar = zo_strformat(SI_UNIT_NAME, GetRawUnitName("player"))
	KCP.selectedChar = KCP.activeChar
	KCP.settings = ZO_SavedVars:New(KCP.name .. "_settings", 1, nil, KCP.defaults)
--	KCP.settings = KCP.defaults --reinit for test
--	KCP.GlobalQuests = ZO_SavedVars:NewAccountWide(KCP.name.."_DB", 1, nil, nil)
	KCP.settings.classId = GetUnitClassId("player")
	KCP.FontsQuest = ZO_DeepTableCopy(KCP.defaultFontsQuest)
	KCP.FontsCondition = ZO_DeepTableCopy(KCP.defaultFontsCondition)
	KCP:initGlobalQuests()
	KCP:CommandOptionPanel()

	-- UI init
	KCP:ChangeBG()
	KCPUILabel:SetText(KCP.langString.MESSAGE_noCraft)
	KCP:ChangeFontSize()

	-- position
	KCPUI:AllowBringToTop(false)
	KCPUI:ClearAnchors()
	KCPUI:SetAnchor(KCP.settings.anchor[1], KCPUI:GetParent(), KCP.settings.anchor[2], KCP.settings.anchor[3], KCP.settings.anchor[4])
	
	-- Register starting events
	EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_CRAFTING_STATION_INTERACT, function(...) KCP:OnCraftingStationInteract(...) end)
	EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_OPEN_BANK, function(...) KCP:OnOpenBank(...) end)
	EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_OPEN_GUILD_BANK, function(...) KCP:OnOpenBank(...) end)
	EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_QUEST_ADDED , function(...) KCP:OnQuestAdded(...) end)
	EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_QUEST_COMPLETE , function(...) KCP:OnQuestComplete(...) end)
	EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_QUEST_REMOVED , function(...) KCP:OnQuestRemoved(...) end)
--	EVENT_MANAGER:UnregisterForEvent(KCP.name, EVENT_ADD_ON_LOADED)
end
function KCP:registerEvents(state)
	if state then
		EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_END_CRAFTING_STATION_INTERACT, function(...) KCP:OnEndCraftingStation(...) end)
--		EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_CRAFT_COMPLETED, function(...) KCP:OnCraftCompleted(...) end)

		EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED, function(...) KCP:OnQuestConditionCounterChanged(...) end)
		EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_QUEST_ADVANCED, function(...) KCP:OnQuestAdvanced(...) end)
		
		EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_CLOSE_BANK, function(...) KCP:OnCloseBank(...) end)
		EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_CLOSE_GUILD_BANK, function(...) KCP:OnCloseBank(...) end)
	else
		EVENT_MANAGER:UnregisterForEvent(KCP.name, EVENT_END_CRAFTING_STATION_INTERACT)
--		EVENT_MANAGER:UnregisterForEvent(KCP.name, EVENT_CRAFT_COMPLETED)

		EVENT_MANAGER:UnregisterForEvent(KCP.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED)
		EVENT_MANAGER:UnregisterForEvent(KCP.name, EVENT_QUEST_ADVANCED)

		EVENT_MANAGER:UnregisterForEvent(KCP.name, EVENT_CLOSE_BANK)
		EVENT_MANAGER:UnregisterForEvent(KCP.name, EVENT_CLOSE_GUILD_BANK)
	end
end

EVENT_MANAGER:RegisterForEvent(KCP.name, EVENT_ADD_ON_LOADED , function(_event, _name) KCP:OnInit(_event, _name) end)


-- // **********
-- //  Settings
-- // **********
function KCP:ToggleEnable(value)
	KCP.settings.Enable = value
	KCP:registerEvents(KCP.settings.Enable)	
end
function KCP:TogglePositionning(value)
	KCP.positionning = value
	-- enable/disabled
	KCPUI:SetHidden(not KCP.positionning)
end
function KCP:ToggleEnableBtn(value)
	KCP.settings.enableButton = value
	KCP:CheckEnabledBtn()
end

function KCP:ChangeFontSize()
	-- change font size (for quest name & conditions)
	if KCP.settings.FontSize then
		local selectedFontQ = KCP.FontsQuest[KCP.settings.Font]
		local newFontQ = string.gsub(selectedFontQ,"|(%w+)|", "|"..KCP.settings.FontSizeQ.."|")
		KCP.FontsQuest[KCP.settings.Font] = newFontQ
		local selectedFontC = KCP.FontsCondition[KCP.settings.Font]
		local newFontC = string.gsub(selectedFontC,"|(%w+)|", "|"..KCP.settings.FontSizeC.."|")
		KCP.FontsCondition[KCP.settings.Font] = newFontC
	end
	if KCP.craftSkill ~= nil then
		-- update Quest title
		local labelControl = GetControl("KCP_QuestPanel_"..CraftTable[KCP.craftSkill].."Label")
		KCP:ChangeFont(labelControl, newFontQ)
		if KCP.Quests[CraftTable[KCP.craftSkill]] ~= nil then
			-- update Conditions texts
			for conditionId, _ in pairs(KCP.Quests[CraftTable[KCP.craftSkill]].conditions) do
				local textControl = GetControl("KCP_ConditionPanel_"..tostring(conditionId).."Label")
				KCP:ChangeFont(textControl, newFontC)
			end
		end
	end
end
function KCP:ChangeFont(control, font)
	-- change font (for quest name & conditions)
	if control == nil then return end
	control:SetFont(font)
end
function KCP:ChangeBG()
	-- change BG texture or color mode
	KCPUI:SetScale(KCP.settings.scale)
	
	GetControl("KCPUIBG"):SetAlpha(KCP.settings.alpha)
	GetControl("KCPUIBGColor"):SetAlpha(KCP.settings.alpha)

	GetControl("KCPUIBG"):SetHidden(KCP.settings.BG == 1)	
	GetControl("KCPUIBGColor"):SetHidden(KCP.settings.BG ~= 1)	
	
	if KCP.settings.BG == 1 then
		-- No texture, colored BG
		GetControl("KCPUIBGColor"):SetCenterColor(HexToRGBA(KCP.settings.BGColor))
	else
		GetControl("KCPUIBG"):SetTexture(KCP.BGTextures[KCP.settings.BG])	
		GetControl("KCPUIBG"):SetTextureCoords(KCP.BGTexturesCoord[KCP.settings.BG][1],KCP.BGTexturesCoord[KCP.settings.BG][2],KCP.BGTexturesCoord[KCP.settings.BG][3],KCP.BGTexturesCoord[KCP.settings.BG][4])
	end
end

function KCP:CommandOptionPanel()
	--// Settings panel LAM2
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if ( not LAM2 ) then return end
	
	local ADDON_NAME="Crafting Post-it"
	local ADDON_VERSION="v"..KCP.version
	local panelData = {
			type = "panel",
			name = ADDON_NAME,
			displayName = "|c"..COLOR_KHRILLSELECT.. ADDON_NAME .."|r (" .. KCP.langString.LOCALE .. ")",
			author = "|c"..COLOR_KHRILLSELECT.."Khrill|r",
			version = ADDON_VERSION,
			slashCommand = "/kcp",
			registerForRefresh = true,
			registerForDefaults = true,
	}
	local settingsPanel = LAM2:RegisterAddonPanel(ADDON_NAME, panelData)

	local optionsTable = {
		------------SETTINGS--------------
		{	-- enable
			type = "checkbox",
			name = KCP.langString.Settings_enable,
			tooltip = KCP.langString.Settings_enable,
			getFunc = function() return KCP.settings.Enable end,
			setFunc = function(value) KCP:ToggleEnable(value) end,
			width = "full",
			default = KCP.defaults.Enable,
		},
		{
			type = "description",
			text = KCP.langString.Settings_keybindText,
			width = "full",
		},
		{
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..KCP.langString.Settings_control.."|r",
			width = "full",
		},
		{	-- auto hide
			type = "checkbox",
			name = KCP.langString.Settings_autohide,
			tooltip = KCP.langString.Settings_enable,
			getFunc = function() return KCP.settings.autohide end,
			setFunc = function(value) KCP.settings.autohide = value end,
			width = "full",
			default = KCP.defaults.autohide,
		},
		{	-- bank mode
			type = "checkbox",
			name = KCP.langString.Settings_bankmode,
			tooltip = KCP.langString.Settings_enable,
			getFunc = function() return KCP.settings.bankmode end,
			setFunc = function(value) KCP.settings.bankmode = value end,
			width = "full",
			default = KCP.defaults.bankmode,
		},
		{	-- Enable button in bank
			type = "checkbox",
			name = KCP.langString.Settings_enableBtn,
			tooltip = KCP.langString.Settings_enableBtn,
			getFunc = function() return KCP.settings.enableButton end,
			setFunc = function(value) KCP:ToggleEnableBtn(value) end,
			width = "full",
--			disabled = function() return not KCP.settings.bankmode end,
			default = KCP.defaults.enableButton,
		},
		{	-- characters buttons
			type = "checkbox",
			name = KCP.langString.Settings_charBtn,
			tooltip = KCP.langString.Settings_charBtn,
			getFunc = function() return KCP.settings.charButton end,
			setFunc = function(value)
				KCP.settings.charButton = value
				KCPUICharPanel:SetHidden(not KCP.settings.charButton)
			end,
			width = "full",
			default = KCP.defaults.charButton,
		},
		{	-- sysmessage
			type = "checkbox",
			name = KCP.langString.Settings_sysmessage,
			tooltip = KCP.langString.Settings_enable,
			getFunc = function() return KCP.settings.sysmessage end,
			setFunc = function(value) KCP.settings.sysmessage = value end,
			width = "full",
			default = KCP.defaults.sysmessage,
		},
		
		------------INTERFACE--------------
		{
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..KCP.langString.Settings_interface.."|r",
			width = "full",
		},
		{	-- size (scale)
			type = "slider",
			name = KCP.langString.Settings_scale,
			min = 70,
			max = 100,
			step = 5,
			getFunc = function() return KCP.settings.scale * 100 end,
			setFunc = function(value)
				KCP.settings.scale = value / 100
				KCPUI:SetScale(KCP.settings.scale)
			end,
			width = "half",
			default = KCP.defaults.scale * 100,
		},
		{	-- transparency (alpha)
			type = "slider",
			name = KCP.langString.Settings_alpha,
			min = 30,
			max = 100,
			step = 10,
			getFunc = function() return KCP.settings.alpha * 100 end,
			setFunc = function(value)
				KCP.settings.alpha = value / 100
				KCPUIBG:SetAlpha(KCP.settings.alpha)
				KCPUIBGColor:SetAlpha(KCP.settings.alpha)
			end,
			width = "half",
			default = KCP.defaults.alpha * 100,
		},
		{	-- Font
			type = "dropdown",
			name = KCP.langString.Settings_Font,
			tooltip = KCP.langString.Settings_choose,
			choices = KCP.FontsLabel,
			getFunc = function() return KCP.FontsLabel[KCP.settings.Font] end,
			setFunc = function(value)
						KCP.settings.Font = getKeyByValue(KCP.FontsLabel, value)
						if KCP.settings.FontSize then KCP:ChangeFontSize() end
						if not KCPUI:IsHidden() then KCP:RefreshUI() end
			end,
			width = "full",
			default = KCP.FontsLabel[KCP.defaults.Font],
		},
		{	-- Font Sizing
			type = "checkbox",
			name = KCP.langString.Settings_FontSize,
			tooltip = KCP.langString.Settings_enable,
			getFunc = function() return KCP.settings.FontSize end,
			setFunc = function(value)
						KCP.settings.FontSize = value
						if not KCP.settings.FontSize then --reinit
							KCP.FontsQuest = ZO_DeepTableCopy(KCP.defaultFontsQuest)
							KCP.FontsCondition = ZO_DeepTableCopy(KCP.defaultFontsCondition)
						end
						KCP:ChangeFontSize()
						if not KCPUI:IsHidden() then KCP:RefreshUI() end
			end,
			width = "full",
			default = KCP.defaults.FontSize,
		},
		{	-- font size (Quest)
			type = "slider",
			name = KCP.langString.Settings_FontSizeQ,
			min = 10,
			max = 30,
			step = 1,
			getFunc = function() return KCP.settings.FontSizeQ end,
			setFunc = function(value)
				KCP.settings.FontSizeQ = value
				KCP:ChangeFontSize()
			end,
			disabled = function() return not(KCP.settings.FontSize) end,
			width = "half",
			default = KCP.defaults.FontSizeQ,
		},
		{	-- font size (Conditions)
			type = "slider",
			name = KCP.langString.Settings_FontSizeC,
			min = 10,
			max = 30,
			step = 1,
			getFunc = function() return KCP.settings.FontSizeC end,
			setFunc = function(value)
				KCP.settings.FontSizeC = value
				KCP:ChangeFontSize()
			end,
			disabled = function() return not(KCP.settings.FontSize) end,
			width = "half",
			default = KCP.defaults.FontSizeC,
		},
		{	-- Font style
			type = "checkbox",
			name = KCP.langString.Settings_FontStyle,
			tooltip = KCP.langString.Settings_enable,
			getFunc = function() return KCP.settings.FontStyle end,
			setFunc = function(value)
						KCP.settings.FontStyle = value
						if not KCPUI:IsHidden() then KCP:RefreshUI() end
			end,
			width = "full",
			default = KCP.defaults.FontStyle,
		},
		{	-- Font color
			type = "colorpicker",
			name = KCP.langString.Settings_FontColor,
			tooltip = KCP.langString.Settings_choose,
			getFunc = function()
						local r, g, b, a = HexToRGBA(KCP.settings.FontColor)
						return r, g, b
			end,
			setFunc = function(r, g, b)
						KCP.settings.FontColor = RGBAToHex(r, g, b, 1)
						if not KCPUI:IsHidden() then KCP:RefreshUI() end
			end,
			width = "full",
			default = KCP.defaultColor,
		},
		{	-- BG texture (with preview)
			type = "dropdown",
			name = KCP.langString.Settings_BG,
			tooltip = KCP.langString.Settings_choose,
			choices = KCP.BGTexturesLabel,
			getFunc = function() return KCP.BGTexturesLabel[KCP.settings.BG] end,
			setFunc = function(value)
						KCP.settings.BG = getKeyByValue(KCP.BGTexturesLabel, value)
						if KCP.BGTextures[KCP.settings.BG] ~= nil then GetControl("KCP_BGPreview"):SetTexture(KCP.BGTextures[KCP.settings.BG]) end
--						GetControl("KCP_BGPreview"):SetHidden(KCP.settings.BG == 1)
						KCP:ChangeBG()
			end,
			width = "full",
			default = KCP.BGTexturesLabel[KCP.defaults.BG],
			reference = "KCP_BGPreview_Dropdown"
		},
		{	-- BG color
			type = "colorpicker",
			name = KCP.langString.Settings_BGColor,
			tooltip = KCP.langString.Settings_choose,
			getFunc = function()
						local r, g, b, a = HexToRGBA(KCP.settings.BGColor)
						return r, g, b
			end,
			setFunc = function(r, g, b)
						KCP.settings.BGColor = RGBAToHex(r, g, b, 1)
						GetControl("KCPUIBGColor"):SetCenterColor(r,g,b,1)
			end,
			disabled = function() return (KCP.settings.BG ~= 1) end,
			width = "full",
--			default = function() return HexToRGBA(KCP.defaults.FontColor) end --function() KCP.settings.BGColor = KCP.defaults.BGColor end,
		},

		------------POSITIONNING--------------
		{
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..KCP.langString.Settings_positionning.."|r",
			width = "full",
		},
		{
			type = "description",
			text = KCP.langString.Settings_positionningText,
			width = "full",
		},
		{
			type = "checkbox",
			name = KCP.langString.Settings_enable,
			tooltip = KCP.langString.Settings_enable,
			getFunc = function() return false end,
			setFunc = function(value) KCP:TogglePositionning(value) end,
			width = "full",
			default = false,
		},
	}

	LAM2:RegisterOptionControls(ADDON_NAME, optionsTable)

	--For preview anim picture
	local preview, previewIcon
    previewIcon = function(panel)
        if panel == settingsPanel then
			local controlPos = 18 --count control position for BG texture
            preview = WINDOW_MANAGER:CreateControl("KCP_BGPreview", panel.controlsToRefresh[controlPos], CT_TEXTURE)
			preview:SetParent(KCP_BGPreview_Dropdown)
			preview:SetHidden(false)
			preview:SetDimensions(96, 48)
            preview:SetAnchor(RIGHT, panel.controlsToRefresh[controlPos].dropdown:GetControl(), LEFT, -10, 0)
			preview:SetMouseEnabled(true)
			if KCP.BGTextures[KCP.settings.BG] ~= nil then preview:SetTexture(KCP.BGTextures[KCP.settings.BG]) end

            CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", previewIcon)
        end
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", previewIcon)
end

-- // **********
-- //  Debug
-- // **********
function KCP:msg(texte, extend)
	if KCP.isDebug then
		d(texte)
		if extend ~= false and KCP.craftSkill ~= nil then
			d("selectedCraft="..tostring(CraftTable[KCP.craftSkill]).."/"..KCP:getCraftName(CraftTable[KCP.craftSkill]))
			d("craftSkill="..tostring(KCP.craftSkill))
			if KCP.Quests[CraftTable[KCP.craftSkill]] ~= nil then
				d("Quests=")
				d(KCP.Quests[CraftTable[KCP.craftSkill]])
			end
			d("-------")
		end
	end
end

SLASH_COMMANDS["/kcpdebug"] = function()
	KCP.isDebug = not KCP.isDebug
	KCP:msg("-- KCP Debug -- "..tostring(KCP.isDebug))
end
