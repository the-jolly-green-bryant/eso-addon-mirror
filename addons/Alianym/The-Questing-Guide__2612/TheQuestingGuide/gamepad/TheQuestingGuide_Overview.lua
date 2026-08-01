local TQG_OverviewManager_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()

function TQG_OverviewManager_Gamepad:New(...)
	return ZO_Gamepad_ParametricList_Screen.New(self, ...)
end

--/script SCENE_MANAGER:Show("QuestGuideOverview_Gamepad")
function TQG_OverviewManager_Gamepad:Initialize(control)
	--self.sceneName = "QuestGuideOverview_Gamepad"

	TQG_GAMEPAD_OVERVIEW_FRAGMENT = ZO_SimpleSceneFragment:New(TQG_Gamepad_Overview)

	TQG_OVERVIEW_GAMEPAD_SCENE = ZO_Scene:New("QuestGuideOverview_Gamepad", SCENE_MANAGER)
	TQG_OVERVIEW_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	TQG_OVERVIEW_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
	TQG_OVERVIEW_GAMEPAD_SCENE:AddFragment(TQG_GAMEPAD_OVERVIEW_FRAGMENT)
	TQG_OVERVIEW_GAMEPAD_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	TQG_OVERVIEW_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	TQG_OVERVIEW_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT)
	TQG_OVERVIEW_GAMEPAD_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	TQG_OVERVIEW_GAMEPAD_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)

	ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, nil, TQG_OVERVIEW_GAMEPAD_SCENE)
	self.itemList = self:GetMainList()

	self.headerData = {
		titleText = GetString(TQG_OVERVIEW_TAB),
	}
	ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
end

function TQG_OverviewManager_Gamepad:OnDeferredInitialize()
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

function TQG_OverviewManager_Gamepad:InitializeKeybindStripDescriptors()
	self.keybindStripDescriptor =
	{
		alignment = KEYBIND_STRIP_ALIGN_LEFT,

		-- Back
		KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor(),
	}
	ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybindStripDescriptor, self:GetMainList())
end

function TQG_OverviewManager_Gamepad:OnShowing()
	self:PerformUpdate()
end

function TQG_OverviewManager_Gamepad:OnHide(...)
	ZO_Gamepad_ParametricList_Screen.OnHide(self, ...)
	CUSTOM_GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
	CUSTOM_GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)
end

function TQG_OverviewManager_Gamepad:PerformUpdate()
	self.itemList:Clear()

	for progressionLevel = 1, #TQG.TopLevelOverview do 
		local zones = {}
		for zoneIndex = 1, #TQG.ZoneLevelOverview[progressionLevel] do
			local zoneName, zoneDescription, zoneOrder = TQGGamepadShared.GetOverviewZoneInfo(progressionLevel, zoneIndex)
			local numObjectives = TQGGamepadShared.GetNumObjectivesForProgressionLevelAndZone(progressionLevel, zoneIndex, TQG.ObjectiveLevelOverview)
			local numCompletedObjectives = 0

			for objectiveIndex = 1, numObjectives do
				local completed = select(6, TQGGamepadShared.GetZoneObjectiveInfo(progressionLevel, zoneIndex, _, objectiveIndex, TQG_ALMANAC_OVERVIEW))
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
				entryData:SetHeader(GetString(TQG_OVERVIEW_TAB))
				template = "ZO_GamepadMenuEntryTemplateWithHeader"
			else
				template = "ZO_GamepadMenuEntryTemplate"
			end

			self.itemList:AddEntry(template, entryData)
		end
	end

	self.itemList:Commit()
end

function TQG_OverviewManager_Gamepad:OnSelectionChanged(list, selectedData, oldSelectedData)
	self:RefreshEntryHeaderDescriptionAndObjectives()
end

function TQG_OverviewManager_Gamepad:RefreshEntryHeaderDescriptionAndObjectives()
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

	local zoneName, zoneDescription = TQGGamepadShared.GetOverviewZoneInfo(progressionLevel, zoneIndex)
	self.entryBody:SetText(zo_strformat(SI_CADWELL_ZONE_DESC_FORMAT, zoneDescription))
	
	self.entryHeaderData.titleText = zo_strformat(SI_CADWELL_ZONE_NAME_FORMAT, zoneName)

	ZO_GamepadGenericHeader_Refresh(self.entryHeader, self.entryHeaderData)

	CUSTOM_GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
	CUSTOM_GAMEPAD_TOOLTIPS:LayoutTheQuestingGuides(GAMEPAD_RIGHT_TOOLTIP, progressionLevel, zoneIndex, TQG_ALMANAC_OVERVIEW)
end

function TQG_Overview_Gamepad_OnInitialize(control)
	TQG_OVERVIEW_GAMEPAD = TQG_OverviewManager_Gamepad:New(control)
end

----------
----------

local CHECKED_ICON = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds"
local UNCHECKED_ICON = "EsoUI/Art/Miscellaneous/Gamepad/gp_bullet_ochre.dds"

function ZO_Tooltip:LayoutTheQuestingGuides(progressionLevel, zoneIndex, almanacInstance)
	local mainSection = self:AcquireSection(self:GetStyle("cadwellSection"), self:GetStyle("tooltip"))

	local titleSection = self:AcquireSection(self:GetStyle("cadwellObjectiveTitleSection"))
	titleSection:AddLine(GetString(SI_CADWELL_OBJECTIVES), self:GetStyle("cadwellObjectiveTitle"))
	mainSection:AddSection(titleSection)

	local objectives = {}

	if almanacInstance == TQG_ALMANAC_OVERVIEW then
		for objectiveIndex = 1, TQGGamepadShared.GetNumObjectivesForProgressionLevelAndZone(progressionLevel, zoneIndex, TQG.ObjectiveLevelOverview) do
			local name, openingText, closingText, objectiveOrder, discovered, completed = TQGGamepadShared.GetZoneObjectiveInfo(progressionLevel, zoneIndex, _, objectiveIndex, almanacInstance)
			table.insert(objectives, {name=name, openingText=openingText, closingText=closingText, order=objectiveOrder, discovered=discovered, completed=completed})
		end
	else
		local zoneCompleted = true
		local countCompleted

		local _, _, _, zoneId = TQGGamepadShared.GetZoneInfo(progressionLevel, zoneIndex, almanacInstance)
		local incrementCounter, numObjectives, hasBlockString, blockStringId = TQGGamepadShared.GetIncrementCounterAndNumObjectives(progressionLevel, zoneId, zoneIndex, almanacInstance)

		for objectiveIndex = incrementCounter, numObjectives do
			local name, openingText, closingText, objectiveOrder, discovered, completed, countCompl = TQGGamepadShared.GetZoneObjectiveInfo(progressionLevel, zoneIndex, numObjectives, objectiveIndex, almanacInstance, hasBlockString, blockStringId)
			countCompleted = countCompl

			table.insert(objectives, {name = name, openingText = openingText, closingText = closingText, order = objectiveOrder, discovered = discovered, completed = completed})
		end
	end

	table.sort(objectives, ZO_CadwellSort)

	local objectivesSection = mainSection:AcquireSection(self:GetStyle("cadwellObjectivesSection"))

	for i=1, #objectives do
		local objectiveInfo = objectives[i]
		local name = objectiveInfo.name
		local openingText = objectiveInfo.openingText
		local closingText = objectiveInfo.closingText
		local discovered = objectiveInfo.discovered
		local completed = objectiveInfo.completed

		-- Extract the actual information we want to display based on the state of the objective.
		local icon
		local text
		local style
		if discovered and completed then
			icon = CHECKED_ICON
			text = closingText
			style = "cadwellObjectiveComplete"
		elseif discovered and (not completed) then
			icon = UNCHECKED_ICON
			text = openingText
			style = "cadwellObjectiveActive"
		else
			icon = UNCHECKED_ICON
			text = openingText
			style = "cadwellObjectiveInactive"
		end

		local objectiveContainerSection = objectivesSection:AcquireSection(self:GetStyle("cadwellObjectiveContainerSection"))

		-- Add the bullet icon to the tooltip.
		local textureContainerSection = objectiveContainerSection:AcquireSection(self:GetStyle("cadwellTextureContainer"))
		textureContainerSection:AddTexture(icon, self:GetStyle("achievementCriteriaCheck"))
		objectiveContainerSection:AddSection(textureContainerSection)

		-- Add the information to the tooltip.
		local objectiveSection = objectiveContainerSection:AcquireSection(self:GetStyle("cadwellObjectiveSection"))
		objectiveSection:AddLine(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, name, text), self:GetStyle(style))
		objectiveContainerSection:AddSection(objectiveSection)

		objectivesSection:AddSection(objectiveContainerSection)
	end

	mainSection:AddSection(objectivesSection)
	self:AddSection(mainSection)
end

function TQG_GamepadTooltip_OnInitialized(control, dialogControl)
    CUSTOM_GAMEPAD_TOOLTIPS = ZO_GamepadTooltip:New(control, dialogControl)
end