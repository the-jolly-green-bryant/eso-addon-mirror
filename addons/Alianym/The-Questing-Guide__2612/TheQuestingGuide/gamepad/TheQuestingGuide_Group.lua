local TQG_GroupManager_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()

function TQG_GroupManager_Gamepad:New(...)
	return ZO_Gamepad_ParametricList_Screen.New(self, ...)
end

--/script SCENE_MANAGER:Show("QuestGuideGroup_Gamepad")
function TQG_GroupManager_Gamepad:Initialize(control)
	--self.sceneName = "QuestGuideGroup_Gamepad"

	TQG_GAMEPAD_GROUP_FRAGMENT = ZO_SimpleSceneFragment:New(TQG_Gamepad_Group)

	TQG_GROUP_GAMEPAD_SCENE = ZO_Scene:New("QuestGuideGroup_Gamepad", SCENE_MANAGER)
	TQG_GROUP_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	TQG_GROUP_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
	TQG_GROUP_GAMEPAD_SCENE:AddFragment(TQG_GAMEPAD_GROUP_FRAGMENT)
	TQG_GROUP_GAMEPAD_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	TQG_GROUP_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	TQG_GROUP_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT)
	TQG_GROUP_GAMEPAD_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	TQG_GROUP_GAMEPAD_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)

	ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, nil, TQG_GROUP_GAMEPAD_SCENE)
	self.itemList = self:GetMainList()

	self.headerData = {
		titleText = GetString(TQG_GROUP_TAB),
	}
	ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
end

function TQG_GroupManager_Gamepad:OnDeferredInitialize()
	ZO_Gamepad_ParametricList_Screen.OnDeferredInitialize(self)

	local middleSection = self.control:GetNamedChild("Middle")
	self.entryHeader = middleSection:GetNamedChild("HeaderContainer"):GetNamedChild("Header")
	ZO_GamepadGenericHeader_Initialize(self.entryHeader, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE)
	self.entryBody = middleSection:GetNamedChild("ListBody")

	self.entryHeaderData = {
		titleText = "",
	}

	local function OnQuestCompleted()
		self:Update()
	end

	self.control:RegisterForEvent(EVENT_QUEST_COMPLETE, OnQuestCompleted)
end

function TQG_GroupManager_Gamepad:GetPlayStoryButtonTextGamepad()
	if not self.itemList then return "" end

	local targetData = self.itemList:GetTargetData()
	if not targetData then return "" end

	local zoneInfo = targetData.zoneInfo
	local progressionLevel, zoneIndex = zoneInfo.progressionLevel, zoneInfo.index
	local _, _, _, zoneId = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_GROUP)

	return TQG:GetPlayStoryButtonText(zoneId)
end

function TQG_GroupManager_Gamepad:InitializeKeybindStripDescriptors()
	self.keybindStripDescriptor =
	{
		alignment = KEYBIND_STRIP_ALIGN_LEFT,

		-- Back
		KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor(),

		-- Zone Story
		{
			name = "Show Quest",
			keybind = "UI_SHORTCUT_PRIMARY",
			visible = function()
				local value = self:GetPlayStoryButtonTextGamepad()
				if value and value ~= "" then return true end
			end,
			callback = function()
				TQG_ALMANAC_GROUP:PlayStory_OnClick()
			end,
		},
	}
	ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybindStripDescriptor, self:GetMainList())
end

function TQG_GroupManager_Gamepad:OnShowing()
	self:PerformUpdate()
end

function TQG_GroupManager_Gamepad:OnHide(...)
	ZO_Gamepad_ParametricList_Screen.OnHide(self, ...)
	CUSTOM_GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
	CUSTOM_GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)
end

function TQG_GroupManager_Gamepad:PerformUpdate()
	self.itemList:Clear()

	for progressionLevel = 1, #TQG.TopLevelGroup do
		local zones = {}
		for zoneIndex = 1, #TQG.ZoneLevelGroup[progressionLevel] do
            local zoneName, zoneDescription, zoneOrder = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_GROUP)
            local numObjectives = TQGGamepadShared.GetNumObjectivesForProgressionLevelAndZone(progressionLevel, zoneIndex, TQG.ObjectiveLevelGroup)
            local numCompletedObjectives = 0

            local _, _, _, zoneId = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_GROUP)
            local _, numObjectives = TQGGamepadShared.GetIncrementCounterAndNumObjectives(progressionLevel, zoneId, zoneIndex, TQG_ALMANAC_GROUP)
            for objectiveIndex = 1, numObjectives do
                local completed = select(6, TQGGamepadShared.GetZoneObjectiveInfo(progressionLevel, zoneIndex, numObjectives,  objectiveIndex, TQG_ALMANAC_GROUP))
                if completed then
                    numCompletedObjectives = numCompletedObjectives + 1
                end
            end

			table.insert(zones, {progressionLevel = progressionLevel, name = zoneName, description = zoneDescription, order = zoneOrder, numObjectives = numObjectives, numCompletedObjectives = numCompletedObjectives, index = zoneIndex})
		end

		table.sort(zones, ZO_CadwellSort)

		for zoneIndex = 1, #zones do
			local zoneInfo = zones[zoneIndex]
			
			local entryData = ZO_GamepadEntryData:New(zo_strformat(SI_CADWELL_ZONE_NAME_FORMAT, zoneInfo.name))
			entryData.zoneInfo = zoneInfo

			local template
			if zoneIndex == 1 then
				entryData:SetHeader(TQG.TopLevelGroup[progressionLevel])
				template = "ZO_GamepadMenuEntryTemplateWithHeader"
			else
				template = "ZO_GamepadMenuEntryTemplate"
			end

			self.itemList:AddEntry(template, entryData)
		end
	end

	self.itemList:Commit()
end

function TQG_GroupManager_Gamepad:OnSelectionChanged(list, selectedData, oldSelectedData)
	self:RefreshEntryHeaderDescriptionAndObjectives()

	if not selectedData or not selectedData.zoneInfo then return end
	
	local zoneInfo = selectedData.zoneInfo
	local progressionLevel, zoneIndex = zoneInfo.progressionLevel, zoneInfo.index
	local _, _, _, zoneId = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_GROUP)
	TQG.selectedGroupZoneId = zoneId

	for i=1, #TQG.ObjectiveLevelGroup[progressionLevel][zoneIndex] do
		local questId = TQG.ObjectiveLevelGroup[progressionLevel][zoneIndex][i].internalId

		if GetCompletedQuestInfo(questId) ~= "" and GetCompletedQuestInfo(questId) ~= nil then
			TQG.trackedGroupObjectiveIndex = i
		else 
			TQG.trackedGroupObjectiveIndex = i
			break
		end
	end
end

function TQG_GroupManager_Gamepad:RefreshEntryHeaderDescriptionAndObjectives()
	local targetData = self.itemList:GetTargetData()

	if not targetData then
		self.entryName:SetText("")
		return
	end

	local zoneInfo = targetData.zoneInfo

	local progressionLevel = zoneInfo.progressionLevel
	local zoneIndex = zoneInfo.index
	local numObjectives = zoneInfo.numObjectives
	local numCompletedObjectives = zoneInfo.numCompletedObjectives

	local zoneName, zoneDescription = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_GROUP)
	self.entryBody:SetText(zo_strformat(SI_CADWELL_ZONE_DESC_FORMAT, zoneDescription))
	
	self.entryHeaderData.titleText = zo_strformat(SI_CADWELL_ZONE_NAME_FORMAT, zoneName)

	ZO_GamepadGenericHeader_Refresh(self.entryHeader, self.entryHeaderData)

	CUSTOM_GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
	CUSTOM_GAMEPAD_TOOLTIPS:LayoutTheQuestingGuides(GAMEPAD_RIGHT_TOOLTIP, progressionLevel, zoneIndex, TQG_ALMANAC_GROUP)
end

function TQG_Group_Gamepad_OnInitialize(control)
	TQG_GROUP_GAMEPAD = TQG_GroupManager_Gamepad:New(control)
end