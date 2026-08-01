local ADDON_NAME			= "MyDung"
local ADDON_AUTHOR			= "@AwfulDead"
--===============================================================================================--

MyDung = {
  defaults = {
    autoCollapseNormalDungeonList = true
  }
}
local QT={ }
local apiVersion = GetAPIVersion()
local requiredLibVersions = {
    [101045] = 270,
}

local function getFallbackVersion(mapping)
    local maxAPI = nil
    for key, _ in pairs(mapping) do
        if not maxAPI or key > maxAPI then
            maxAPI = key
        end
    end
    return mapping[maxAPI]
end

local requiredVersion = requiredLibVersions[apiVersion] or getFallbackVersion(requiredLibVersions)

local IsOldVersionLibQuestData = false
if LibQuestData and requiredVersion then
    local currentLibVersion = tonumber(LibQuestData.libVersion)
    IsOldVersionLibQuestData = currentLibVersion < requiredVersion
end

local function LabelFunc(name, parent, dims, anchor, font, color, align, text, hidden, anchorTo)
	parent=(parent==nil) and GuiRoot or parent
	if (#anchor~=4 and #anchor~=5) then return end
	font	=(font==nil) and "ZoFontGame" or font
	color	=(color~=nil and #color==4) and color or {1,1,1,1}
	align	=(align~=nil and #align==2) and align or {0,0}
	hidden=(hidden==nil) and false or hidden
	local label=_G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)

	if dims then label:SetDimensions(dims[1], dims[2]) end
	label:ClearAnchors()
	if anchorTo then
		local width = anchorTo:GetWidth()
		label:ClearAnchors()
		label:SetAnchor(anchor[1], parent, anchor[2], width, anchor[4])
	else
		-- If no anchorTo is provided, use the specified anchor
		if #anchor == 5 then
			label:SetAnchor(anchor[1], anchor[5], anchor[2], anchor[3], anchor[4])
		else
			label:SetAnchor(anchor[1], parent, anchor[2], anchor[3], anchor[4])
		end
	end
	label:SetFont(font)
	label:SetColor(unpack(color))
	label:SetHorizontalAlignment(align[1])
	label:SetVerticalAlignment(align[2])
	label:SetText(text)
	label:SetHidden(hidden)
	return label
end

local function Button(name, parent, dims, anchor, state, font, align, normal, pressed, mouseover, hidden)
	--Validate arguments
	if (name==nil or name=="") then return end
	parent=(parent==nil) and GuiRoot or parent
	if (dims=="inherit" or #dims~=2) then dims={parent:GetWidth(), parent:GetHeight()} end
	if (#anchor~=4 and #anchor~=5) then return end
	state=(state~=nil) and state or BSTATE_NORMAL
	font=(font==nil) and "ZoFontGame" or font
	align=(align~=nil and #align==2) and align or {1, 1}
	normal=(normal~=nil and #normal==4) and normal or {1, 1, 1, 1}
	pressed=(pressed~=nil and #pressed==4) and pressed or {1, 1, 1, 1}
	mouseover=(mouseover~=nil and #mouseover==4) and mouseover or {1, 1, 1, 1}
	hidden=(hidden==nil) and false or hidden

	--Create the button
	local button=_G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)

	--Apply properties
		button:SetDimensions(dims[1], dims[2])
		button:ClearAnchors()
		button:SetAnchor(anchor[1], #anchor==5 and anchor[5] or parent, anchor[2], anchor[3], anchor[4])
		button:SetState(state)
		button:SetFont(font)
		button:SetNormalFontColor(normal[1], normal[2], normal[3], normal[4])
		button:SetPressedFontColor(pressed[1], pressed[2], pressed[3], pressed[4])
		button:SetMouseOverFontColor(mouseover[1], mouseover[2], mouseover[3], mouseover[4])
		button:SetHorizontalAlignment(align[1])
		button:SetVerticalAlignment(align[2])
		button:SetHidden(hidden)
	return button
end


local function createQTbase()
    QT = {}
    local id
    for i=0, 10000 do
        id = GetNextCompletedQuestId(i)
        if id == nil then break end
        QT[id] = true
    end
end

local function GetGoalPledges()
	local Pledges,haveQuest={},false
	for i=1,MAX_JOURNAL_QUESTS do
		local name,_,_,stepType,_,completed,_,_,_,questType=GetJournalQuestInfo(i)
		if questType == QUEST_TYPE_UNDAUNTED_PLEDGE and completed == false then
			local text=string.format("%s",name:gsub(".*:%s*",""):gsub(" "," "):gsub("%s+"," "):lower():gsub("the ",""))
			if text == MyDung.SI.PledgeDC2 then text = MyDung.SI.DarkshadeCaverns2:lower() end
			Pledges[text]=stepType~=QUEST_STEP_TYPE_AND
			if stepType==QUEST_STEP_TYPE_AND then haveQuest=true end
		end
	end
	return Pledges,haveQuest
end

local function ToggleNormalDungeonsCollapse()
  local function getTextLength()
    local buttonText
    if MyDung.vars.autoCollapseNormalDungeonList then
        buttonText = " |cC8C896 "..MyDung.SI.AutoCollapse..":|r "..MyDung.SI.AutoCollapse_ON
    else
        buttonText = " |cC8C896 "..MyDung.SI.AutoCollapse..":|r "..MyDung.SI.AutoCollapse_OFF
    end

    local tempLabel = WINDOW_MANAGER:CreateControl(nil, GuiRoot, CT_LABEL)
    tempLabel:SetFont("$(MEDIUM_FONT)|18")
    tempLabel:SetText(buttonText)

    local textWidth = tempLabel:GetTextWidth()

    tempLabel:SetHidden(true)
    tempLabel:ClearAnchors()
    tempLabel:SetParent(nil)
    tempLabel:SetFont("", 0)
    tempLabel:SetText("")
    return textWidth
  end

  local function updateControl(control)
    if MyDung.vars.autoCollapseNormalDungeonList then
        control:SetText(" |cC8C896 "..MyDung.SI.AutoCollapse..":|r "..MyDung.SI.AutoCollapse_ON)
        control:SetNormalFontColor(1, 0.843, 0, 1)
    else
        control:SetText(" |cC8C896 "..MyDung.SI.AutoCollapse..":|r "..MyDung.SI.AutoCollapse_OFF)
        control:SetNormalFontColor(.7,.7,.5,1)
    end
    control:SetDimensions(getTextLength(state), 20)
  end

  local normalControl = _G["ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationHeader_Keyboard1"]
  if normalControl then
    local btn = Button("NormalDungeonAutoCollapse",	normalControl, {250, 20},	{RIGHT, LEFT, 600, -2},	BSTATE_NORMAL, "$(MEDIUM_FONT)|18", {TEXT_ALIGN_RIGHT, 1}, {.7,.7,.5,1})
    updateControl(btn, isOn)
    btn:SetHandler("OnClicked", function(self)
		PlaySound("Click") 
      	MyDung.vars.autoCollapseNormalDungeonList = not MyDung.vars.autoCollapseNormalDungeonList
      	updateControl(self)
    end)
  end
end

local function UndauntedPledges()
	local Pledges,haveQuest={},false
	local offset = GetCVar("LastRealm") == "NA Megaserver" and 1517479200 or 1517454000
	local upi = {}
	local qci = {}
	local dai = {}
	local day=math.floor(GetDiffBetweenTimeStamps(GetTimeStamp(),offset)/86400)
	local function MarkPledge()
		local isVeteran=GetUnitEffectiveChampionPoints('player')>=160 and 3 or 2
		if isVeteran == 3 then
		  ToggleNormalDungeonsCollapse()
    end
		for c=2,3 do
			local parent=_G["ZO_DungeonFinder_KeyboardListSectionScrollChildContainer"..c]
			if parent then
				upi[c] = upi[c] or {}
				qci[c] = qci[c] or {}
				dai[c] = dai[c] or {}
				for i=1,parent:GetNumChildren() do
					local obj=parent:GetChild(i)
					if obj then
						--Achievement
						local id=obj.node.data.id
						if MyDung.DungeonIndex[id] then
							local qtcompl = ""
							if((LibQuestData and not IsOldVersionLibQuestData and not LibQuestData.completed_quests[MyDung.DungeonIndex[id].qt]) or (((LibQuestData and IsOldVersionLibQuestData) or not LibQuestData) and not QT[MyDung.DungeonIndex[id].qt])) then
							qtcompl=MyDung.DungeonIndex[id].qt and "|t20:20:/esoui/art/compass/quest_icon_assisted.dds|t" or ""
							end
							local text=IsAchievementComplete(MyDung.DungeonIndex[id].id) and "|t16:16:/esoui/art/cadwell/check.dds|t" or ""
							text=text..((MyDung.DungeonIndex[id].hm and IsAchievementComplete(MyDung.DungeonIndex[id].hm)) and "|t20:20:/esoui/art/unitframes/target_veteranrank_icon.dds|t" or "")
							text=text..((MyDung.DungeonIndex[id].tt and IsAchievementComplete(MyDung.DungeonIndex[id].tt)) and "|t20:20:/esoui/art/ava/overview_icon_underdog_score.dds|t" or "")
							text=text..((MyDung.DungeonIndex[id].nd and IsAchievementComplete(MyDung.DungeonIndex[id].nd)) and "|t20:20:/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds|t" or "")
							qci[c][i] = qci[c][i] or LabelFunc("QuestInfo"..c..i, obj, {20,20}, {LEFT,LEFT,400,0}, "ZoFontGameLarge", nil, {0,1}, qtcompl)
							qci[c][i]:SetText(qtcompl)
							dai[c][i] = dai[c][i] or LabelFunc("DungeonInfo"..c..i, obj, {80,20}, {LEFT,LEFT,465,0}, "ZoFontGameLarge", nil, {0,1}, text)
							dai[c][i]:SetText(text)
							--Quest
							local orig=obj.text:GetText()
							local text=orig:lower() text=text:gsub("the ",""):gsub(" "," ")
							local undauntedInfo = ""
							if c==3 then
								local _start,_end=string.find(text,"s|t")
								if _start then text=string.sub(text,_end+2) end
							end
							--Daily pledges
							local daily=""
							for npc=1,3 do
								local dp=MyDung.DailyPledge[npc]
								local n=1+(day+dp.shift)%#dp
								local name=dp[n]
								if name then

									name=name:lower()
									if text==name then
										daily=" (" .. MyDung.SI.Daily .. ")"
										undauntedInfo = " |c3388EE"..daily.."|r"
								  end
								end
							end
							--Current pledges
							local completed=Pledges[text]
							obj.pledge=completed==false
							if completed==false then
								undauntedInfo = " |c3388EE- "..MyDung.SI.Quest..daily.."|r"
							elseif completed==true then
								undauntedInfo = " |c33EE33- "..MyDung.SI.Done..daily.."|r"
							end

							upi[c][i] = upi[c][i] or LabelFunc("UndauntedInfo"..c..i, obj, nil, {LEFT,LEFT,0,0}, "$(BOLD_FONT)|20", nil, {0,1}, undauntedInfo, false, obj)
							upi[c][i]:SetText(undauntedInfo)
						end
					end
				end
			end

			local header=_G["ZO_DungeonFinder_KeyboardListSectionScrollChildZO_ActivityFinderTemplateNavigationHeader_Keyboard"..c-1]
			if header then
				local state=header.text:GetColor()
				if (isVeteran==c)~=(state==1) and MyDung.vars.autoCollapseNormalDungeonList then header:OnMouseUp(true) end
			end
		end
	end

	ZO_PreHookHandler(ZO_DungeonFinder_KeyboardListSection,'OnEffectivelyShown',function() Pledges,haveQuest=GetGoalPledges() zo_callLater(function() MarkPledge() end, 200) end)
	ZO_PreHookHandler(ZO_DungeonFinder_KeyboardListSection,'OnEffectivelyHidden',function() Pledges={} end)
end

local function OnQuestComplete(eventCode, journalIndex, questName, zoneIndex, poiId, poiName, questType, instanceDisplayType)
	if questType == QUEST_TYPE_DUNGEON then
		if ((LibQuestData and IsOldVersionLibQuestData) or not LibQuestData) then
			createQTbase()
		end
	end
end

local function OnAddonLoaded(eventType, addonName)
	if addonName == ADDON_NAME then

    MyDung.vars = ZO_SavedVars:NewAccountWide("MyDungSV", 1, nil, MyDung.defaults)
		if ((LibQuestData and IsOldVersionLibQuestData) or not LibQuestData) then
			createQTbase()
		end
		UndauntedPledges()
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_COMPLETE, OnQuestComplete)
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
