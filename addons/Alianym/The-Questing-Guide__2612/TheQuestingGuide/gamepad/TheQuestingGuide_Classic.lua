local TQG_ClassicManager_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()

function TQG_ClassicManager_Gamepad:New(...)
	return ZO_Gamepad_ParametricList_Screen.New(self, ...)
end

--/script SCENE_MANAGER:Show("QuestGuideClassic_Gamepad")
function TQG_ClassicManager_Gamepad:Initialize(control)
	--self.sceneName = "QuestGuideClassic_Gamepad"

	TQG_GAMEPAD_CLASSIC_FRAGMENT = ZO_SimpleSceneFragment:New(TQG_Gamepad_Classic)

	TQG_CLASSIC_GAMEPAD_SCENE = ZO_Scene:New("QuestGuideClassic_Gamepad", SCENE_MANAGER)
	TQG_CLASSIC_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	TQG_CLASSIC_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
	TQG_CLASSIC_GAMEPAD_SCENE:AddFragment(TQG_GAMEPAD_CLASSIC_FRAGMENT)
	TQG_CLASSIC_GAMEPAD_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	TQG_CLASSIC_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	TQG_CLASSIC_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT)
	TQG_CLASSIC_GAMEPAD_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	TQG_CLASSIC_GAMEPAD_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)

	ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, nil, TQG_CLASSIC_GAMEPAD_SCENE)
	self.itemList = self:GetMainList()

	self.headerData = {
		titleText = GetString(TQG_CLASSIC_TAB),
	}
	ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
end

function TQG_ClassicManager_Gamepad:OnDeferredInitialize()
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

function TQG_ClassicManager_Gamepad:GetPlayStoryButtonTextGamepad()
	if not self.itemList then return "" end

	local targetData = self.itemList:GetTargetData()
	if not targetData then return "" end

	local zoneInfo = targetData.zoneInfo
	local progressionLevel, zoneIndex = zoneInfo.progressionLevel, zoneInfo.index
	local _, _, _, zoneId = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_CLASSIC)

	return TQG:GetPlayStoryButtonText(zoneId)
end

function TQG_ClassicManager_Gamepad:InitializeKeybindStripDescriptors()
	self.keybindStripDescriptor =
	{
		alignment = KEYBIND_STRIP_ALIGN_LEFT,

		-- Back
		KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor(),

		-- Zone Story
		{
			name = "Show Zone Story",
			keybind = "UI_SHORTCUT_PRIMARY",
			visible = function()
				local value = self:GetPlayStoryButtonTextGamepad()
				if value and value ~= "" then return true end
			end,
			callback = function()
				TQG_ALMANAC_CLASSIC:PlayStory_OnClick()
			end,
		},
	}
	ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybindStripDescriptor, self:GetMainList())
end

function TQG_ClassicManager_Gamepad:OnShowing()
	self:PerformUpdate()
end

function TQG_ClassicManager_Gamepad:OnHide(...)
	ZO_Gamepad_ParametricList_Screen.OnHide(self, ...)
	CUSTOM_GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
	CUSTOM_GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)
end

function TQG_ClassicManager_Gamepad:PerformUpdate()
	self.itemList:Clear()

	for progressionLevel = 1, #TQG.TopLevelClassic do
		local zones = {}
		for zoneIndex = 1, #TQG.ZoneLevelClassic[progressionLevel] do
            local zoneName, zoneDescription, zoneOrder = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_CLASSIC)
            local numObjectives = TQGGamepadShared.GetNumObjectivesForProgressionLevelAndZone(progressionLevel, zoneIndex, TQG.ObjectiveLevelClassic)
            local numCompletedObjectives = 0

            local _, _, _, zoneId = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_CLASSIC)
            local _, numObjectives = TQGGamepadShared.GetIncrementCounterAndNumObjectives(progressionLevel, zoneId, zoneIndex, TQG_ALMANAC_CLASSIC)
            for objectiveIndex = 1, numObjectives do
                local completed = select(6, TQGGamepadShared.GetZoneObjectiveInfo(progressionLevel, zoneIndex, numObjectives,  objectiveIndex, TQG_ALMANAC_CLASSIC))
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
				entryData:SetHeader(TQG.TopLevelClassic[progressionLevel])
				template = "ZO_GamepadMenuEntryTemplateWithHeader"
			else
				template = "ZO_GamepadMenuEntryTemplate"
			end

			self.itemList:AddEntry(template, entryData)
		end
	end

	self.itemList:Commit()
end

function TQG_ClassicManager_Gamepad:OnSelectionChanged(list, selectedData, oldSelectedData)
	self:RefreshEntryHeaderDescriptionAndObjectives()

	if not selectedData or not selectedData.zoneInfo then return end
	
	local zoneInfo = selectedData.zoneInfo
	local progressionLevel, zoneIndex = zoneInfo.progressionLevel, zoneInfo.index
	local _, _, _, zoneId = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_CLASSIC)
	TQG.selectedClassicZoneId = zoneId
end

function TQG_ClassicManager_Gamepad:RefreshEntryHeaderDescriptionAndObjectives()
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

	local zoneName, zoneDescription = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, TQG_ALMANAC_CLASSIC)
	self.entryBody:SetText(zo_strformat(SI_CADWELL_ZONE_DESC_FORMAT, zoneDescription))
	
	self.entryHeaderData.titleText = zo_strformat(SI_CADWELL_ZONE_NAME_FORMAT, zoneName)

	ZO_GamepadGenericHeader_Refresh(self.entryHeader, self.entryHeaderData)

	CUSTOM_GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
	CUSTOM_GAMEPAD_TOOLTIPS:LayoutTheQuestingGuides(GAMEPAD_RIGHT_TOOLTIP, progressionLevel, zoneIndex, TQG_ALMANAC_CLASSIC)
end

function TQG_Classic_Gamepad_OnInitialize(control)
	TQG_CLASSIC_GAMEPAD = TQG_ClassicManager_Gamepad:New(control)
end