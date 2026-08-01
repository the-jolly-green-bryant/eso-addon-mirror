local TQG_MENU_ENTRIES = {}

local TQG_MAIN_MENU_ENTRIES =
{
	TQG_MENU		= 1,
}

local TQG_SUB_ENTRIES =
{
	OVERVIEW        = 1,
	CLASSIC         = 2,
	DLC             = 3,
	GROUP			= 4,
}

local function IsAnySubMenuNewCallback(entryData)
	for entryIndex, entry in ipairs(entryData.subMenu) do
		if entry:IsNew() then
			return true
		end
	end
	return false
end

local TQG_MENU_ENTRY_DATA =
{
	[TQG_MAIN_MENU_ENTRIES.TQG_MENU] =
	{
		customTemplate = "ZO_GamepadMenuEntryTemplateWithArrow",
		name = "The Questing Guide",
		icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_journal.dds",
		isNewCallback = IsAnySubMenuNewCallback,
		subMenu =
		{
			[TQG_SUB_ENTRIES.OVERVIEW] =
			{
				scene = "QuestGuideOverview_Gamepad",
				name = GetString(TQG_OVERVIEW_TAB),
				icon = "esoui/art/progression/progression_indexicon_world_up.dds",
				--header = GetString(SI_MAIN_MENU_JOURNAL),
				--isVisibleCallback = function()
				--	return true
				--end,
			},
			[TQG_SUB_ENTRIES.CLASSIC] =
			{
				scene = "QuestGuideClassic_Gamepad",
				name = GetString(TQG_CLASSIC_TAB),
				icon = "esoui/art/campaign/campaignbrowser_indexicon_specialevents_up.dds",
			},
			[TQG_SUB_ENTRIES.DLC] =
			{
				scene = "QuestGuideDLC_Gamepad",
				name = GetString(TQG_DLC_TAB),
				icon = "esoui/art/treeicons/store_indexicon_dlc_up.dds",
			},
			[TQG_SUB_ENTRIES.GROUP] =
			{
				scene = "QuestGuideGroup_Gamepad",
				name = GetString(TQG_GROUP_TAB),
				icon = "esoui/art/treeicons/store_indexicon_dlc_up.dds",
			},
		},
	},
}

local CATEGORY_TO_ENTRY_DATA =
{
	[1]	= TQG_MENU_ENTRY_DATA[TQG_MAIN_MENU_ENTRIES.TQG_MENU],
}

local function CreateEntry(data)
	local name = data.name
	if type(name) == "function" then
		name = "" --will be updated whenever the list is generated
	end

	local entry = ZO_GamepadEntryData:New(name, data.icon, nil, nil, data.isNewCallback)
	entry:SetIconTintOnSelection(true)
	entry:SetIconDisabledTintOnSelection(true)

	local header = data.header
	if header then
		entry:SetHeader(header)
	end

	entry.canLevel = data.canLevel

	entry.data = data
	return entry
end

for menuEntryId, data in ipairs(TQG_MENU_ENTRY_DATA) do
	local newEntry = CreateEntry(data)

	newEntry.id = menuEntryId
	if data.subMenu then
		newEntry.subMenu = {}
		for submenuEntryId, subMenuData in ipairs(data.subMenu) do
			local newSubMenuEntry = CreateEntry(subMenuData)
			newSubMenuEntry.id = submenuEntryId
			table.insert(newEntry.subMenu, newSubMenuEntry)
		end
	end

	table.insert(TQG_MENU_ENTRIES, newEntry)
end

local MODE_MAIN_LIST = 1
local MODE_SUBLIST = 2
--
--[[ TQG_MainMenuManager_Gamepad ]]--
--
local TQG_MainMenuManager_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()

function TQG_MainMenuManager_Gamepad:New(control)
	return ZO_Gamepad_ParametricList_Screen.New(self, control)
end

function TQG_MainMenuManager_Gamepad:Initialize(control)
	TQG_MENU_FRAGMENT = ZO_SimpleSceneFragment:New(control)
	TQG_MENU_FRAGMENT:SetHideOnSceneHidden(true)

	TQG_MENU_GAMEPAD_SCENE = ZO_Scene:New("tqgMenuGamepad", SCENE_MANAGER)
	TQG_MENU_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	TQG_MENU_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
	TQG_MENU_GAMEPAD_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
	TQG_MENU_GAMEPAD_SCENE:AddFragment(TQG_MENU_FRAGMENT)
	TQG_MENU_GAMEPAD_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	TQG_MENU_GAMEPAD_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	TQG_MENU_GAMEPAD_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)

	TQG_SUBMENU_SCENE = ZO_Scene:New("tqgSubmenu", SCENE_MANAGER)
	TQG_SUBMENU_SCENE:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
	TQG_SUBMENU_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
	TQG_SUBMENU_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_GAMEPAD_CURRENT)
	TQG_SUBMENU_SCENE:AddFragment(TQG_MENU_FRAGMENT)
	TQG_SUBMENU_SCENE:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
	TQG_SUBMENU_SCENE:AddFragment(MINIMIZE_CHAT_FRAGMENT)
	TQG_SUBMENU_SCENE:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)

	local DONT_ACTIVATE_ON_SHOW = false
	ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, DONT_ACTIVATE_ON_SHOW, TQG_MENU_GAMEPAD_SCENE)
	control.header:SetHidden(true)

	self.mainList = self:GetMainList()
	self.subList = self:AddList("Submenu")
	self.lastList = self.mainList
	self:ReanchorListsOverHeader()
	self.mode = MODE_MAIN_LIST

	self:SetListsUseTriggerKeybinds(true)

	TQG_SUBMENU_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			self.mode = MODE_SUBLIST
		end
		ZO_Gamepad_ParametricList_Screen.OnStateChanged(self, oldState, newState)
	end)
	MAIN_MENU_MANAGER:RegisterCallback("OnPlayerStateUpdate", function() self:UpdateEntryEnabledStates() end)

	local function OnBlockingSceneCleared(nextSceneData, showBaseScene)
		if IsInGamepadPreferredMode() then
			if showBaseScene then
				SCENE_MANAGER:ShowBaseScene()
			elseif nextSceneData then
				if nextSceneData.sceneName then
					self:ToggleScene(nextSceneData.sceneName)
				elseif nextSceneData.category then
					self:ToggleCategory(nextSceneData.category)
				end
			end
		end
	end

	MAIN_MENU_MANAGER:RegisterCallback("OnBlockingSceneCleared", OnBlockingSceneCleared)
end

function TQG_MainMenuManager_Gamepad:OnShowing()
	self:RefreshLists()
	-- Both TQG_MENU_GAMEPAD_SCENE and TQG_SUBMENU_SCENE use OnShowing to set the active list, which also adds the appropriate list fragment to the scene
	-- Two separate scenes are needed for this to properly control the direction the fragments conveyor in and out.
	self:SetCurrentList(self.mode == MODE_SUBLIST and self.subList or self.mainList)
end

function TQG_MainMenuManager_Gamepad:OnHiding()
	self.mode = MODE_MAIN_LIST
	self:DeactivateHelperPanel()
end

do
	local function ReanchorList(list)
		local control = list:GetControl()
		local container = control:GetParent()
		control:ClearAnchors()
		control:SetAnchorFill(container)
	end

	function TQG_MainMenuManager_Gamepad:ReanchorListsOverHeader()
		ReanchorList(self.mainList)
		ReanchorList(self.subList)
	end
end

do
	local function AnimatingLabelEntrySetup(control, data, selected, reselectingDuringRebuild, enabled, active)
		ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
		local totalSpendablePoints = GetAttributeUnspentPoints()
	
		if totalSpendablePoints ~= nil then
			local shouldAnimate = totalSpendablePoints > 0
			local animatingControl = control.label
			local animatingControlTimeline = animatingControl.animationTimeline
			local isAnimating = animatingControlTimeline:IsPlaying()
			if(shouldAnimate ~= isAnimating) then
				animatingControl:SetText(animatingControl.text[1])
				if(shouldAnimate) then
					animatingControl.textIndex = 1
					animatingControlTimeline:PlayFromStart()
				else
					animatingControlTimeline:Stop()
					animatingControl:SetAlpha(1)
				end
			end
		end
	end

	local function EntryWithSubMenuSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
		ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)

		local color = data:GetNameColor(selected)
		if type(color) == "function" then
			color = color(data)
		end
		control:GetNamedChild("Arrow"):SetColor(color:UnpackRGBA())
	end

	function TQG_MainMenuManager_Gamepad:SetupList(list)
		list:AddDataTemplate("ZO_GamepadNewMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
		list:AddDataTemplateWithHeader("ZO_GamepadNewMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "ZO_GamepadMenuEntryHeaderTemplate")

		list:AddDataTemplate("ZO_GamepadMenuEntryTemplateWithArrow", EntryWithSubMenuSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
		list:AddDataTemplateWithHeader("ZO_GamepadMenuEntryTemplateWithArrow", EntryWithSubMenuSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "ZO_GamepadMenuEntryHeaderTemplate")

		list:AddDataTemplate("ZO_GamepadNewAnimatingMenuEntryTemplate", AnimatingLabelEntrySetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
	end
end

local function ShouldDisableEntry(entryData)
	--[[if entryData.disableWhenDead and MAIN_MENU_MANAGER:IsPlayerDead() then
		return true
	elseif entryData.disableWhenInCombat and MAIN_MENU_MANAGER:IsPlayerInCombat() then
		return true
	elseif entryData.disableWhenReviving and MAIN_MENU_MANAGER:IsPlayerReviving() then
		return true
	elseif entryData.disableWhenSwimming and MAIN_MENU_MANAGER:IsPlayerSwimming() then
		return true
	elseif entryData.disableWhenWerewolf and MAIN_MENU_MANAGER:IsPlayerWerewolf() then
		return true
	elseif entryData.disableWhenPassenger and MAIN_MENU_MANAGER:IsPlayerPassenger() then
		return true
	elseif entryData.shouldDisableFunction and entryData.shouldDisableFunction() then
		return true
	end]]

	return false
end

function TQG_MainMenuManager_Gamepad:UpdateEntryEnabledStates()
	local function UpdateState(entry)
		if ShouldDisableEntry(entry.data) then
			entry:SetEnabled(false)

			if self:IsEntrySceneShowing(entry.data) then
				SCENE_MANAGER:ShowBaseScene()
			end
		else
			entry:SetEnabled(true)
		end
	end

	for _, entry in ipairs(TQG_MENU_ENTRIES) do
		UpdateState(entry)
		if entry.subMenu then
			for _, subMenuEntry in ipairs(entry.subMenu) do
				UpdateState(subMenuEntry)
			end
		end
	end

	self:RefreshLists()
end

function TQG_MainMenuManager_Gamepad:RefreshLists()
	if self.mode == MODE_MAIN_LIST then
		self:RefreshMainList()
	else
		local entry = self.mainList:GetTargetData()
		self:RefreshSubList(entry)
	end
end

function TQG_MainMenuManager_Gamepad:OnDeferredInitialize()
	local function MarkNewnessDirty()
		self:MarkNewnessDirty()
	end

	self.exitHelperPanelFunction = function()
		self:DeactivateHelperPanel()
	end

	self:UpdateEntryEnabledStates()
end

function TQG_MainMenuManager_Gamepad:InitializeKeybindStripDescriptors()
	self.keybindStripDescriptor = {
		alignment = KEYBIND_STRIP_ALIGN_LEFT,
		{
			name = GetString(SI_GAMEPAD_TEXT_CHAT),
			keybind = "UI_SHORTCUT_SECONDARY",
			callback = function() SCENE_MANAGER:Push("gamepadChatMenu") end,
			visible = IsChatSystemAvailableForCurrentPlatform,
		}
	}

	local  function IsForwardNavigationEnabled()
		local currentList = self:GetCurrentList() 
		local entry = currentList and currentList:GetTargetData()
		return entry and entry:IsEnabled()
	end

	ZO_Gamepad_AddForwardNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function() self:SwitchToSelectedScene(self:GetCurrentList()) end, nil, nil, IsForwardNavigationEnabled)
	ZO_Gamepad_AddBackNavigationKeybindDescriptors(self.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, function()
		if self:IsCurrentList(self.mainList) then
			self:Exit()
		else
			SCENE_MANAGER:HideCurrentScene()
		end
	end)
end

function TQG_MainMenuManager_Gamepad:SwitchToSelectedScene(list)
	local entry = list:GetTargetData()
	
	if entry.enabled then
		local entryData = entry.data
		local scene = entryData.scene
		local activatedCallback = entryData.activatedCallback

		if scene then
			list:SetActive(false)
			SCENE_MANAGER:Push(scene)
		elseif entryData.subMenu then
			list:SetActive(false)
			SCENE_MANAGER:Push("tqgSubmenu")
		elseif activatedCallback then
			activatedCallback(self)
		end

	else
		PlaySound(SOUNDS.PLAYER_MENU_ENTRY_DISABLED)
	end
end

function TQG_MainMenuManager_Gamepad:Exit()
	SCENE_MANAGER:Hide("tqgMenuGamepad")
end

do
	local function AddEntryToList(list, entry, menuEntryToEntryIndex)
		local entryData = entry.data

		if not entryData.isVisibleCallback or entryData.isVisibleCallback() then
			local customTemplate = entryData.customTemplate
			local postPadding = entryData.postPadding or 0
			local entryTemplate = customTemplate and customTemplate or "ZO_GamepadNewMenuEntryTemplate"
	   
			local showHeader = entryData.showHeader
			local useHeader = entry.header
			if type(showHeader) == "function" then
				useHeader = showHeader()
			elseif type(showHeader) == "boolean" then
				useHeader = showHeader
			end

			local name = entryData.name
			if type(name) == "function" then
				entry:SetText(name())
			end

			if useHeader then
				list:AddEntryWithHeader(entryTemplate, entry, 0, postPadding)
			else
				list:AddEntry(entryTemplate, entry, 0, postPadding)
			end
			menuEntryToEntryIndex[entry.id] = list:GetNumEntries()

			return true
		end
		return false
	end

	function TQG_MainMenuManager_Gamepad:RefreshMainList()
		self.mainList:Clear()

		self.mainMenuEntryToListIndex = {}
		-- if we haven't yet initialized, set the default selection
		-- we only need to default the first time the Menu is shown
		-- so as soon as we init, we don't need to update this any more
		if self.initialized then
			for _, entry in ipairs(TQG_MENU_ENTRIES) do
				AddEntryToList(self.mainList, entry, self.mainMenuEntryToListIndex)
			end
		else
			--The entry we want to start on may not be at the top, and its index can be variable since entries are contextually visible
			local currentMenuIndex = 0
			local defaultEntryIndex = 1
			for _, entry in ipairs(TQG_MENU_ENTRIES) do
				if AddEntryToList(self.mainList, entry, self.mainMenuEntryToListIndex) then
					currentMenuIndex = currentMenuIndex + 1
					if entry.data.scene == DEFAULT_MENU_ENTRY_SCENE_NAME then
						defaultEntryIndex = currentMenuIndex
					end
				end
			end

			self.mainList:SetDefaultSelectedIndex(defaultEntryIndex)
		end

		self.mainList:Commit()
	end

	function TQG_MainMenuManager_Gamepad:RefreshSubList(mainListEntry)
		self.subList:Clear()
		self.subMenuEntryToListIndex = {}

		if mainListEntry and mainListEntry.subMenu then
			for _, entry in ipairs(mainListEntry.subMenu) do
				AddEntryToList(self.subList, entry, self.subMenuEntryToListIndex)
			end
		end

		self.subList:Commit()
	end
end

function TQG_MainMenuManager_Gamepad:OnSelectionChanged(list, selectedData, oldSelectedData)
	if list == self.subList then
		if oldSelectedData and oldSelectedData.data.fragmentGroupCallback then
			local fragmentGroup = oldSelectedData.data.fragmentGroupCallback()
			SCENE_MANAGER:RemoveFragmentGroup(fragmentGroup)
		end

		if selectedData and selectedData.data.fragmentGroupCallback then
			local fragmentGroup = selectedData.data.fragmentGroupCallback()
			SCENE_MANAGER:AddFragmentGroup(fragmentGroup)
		end
	end
end

function TQG_MainMenuManager_Gamepad:ActivateHelperPanel(panel)
	self:DeactivateCurrentList()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
	self.activeHelperPanel = panel
	panel:RegisterCallback("PanelSelectionEnd", self.exitHelperPanelFunction)
	panel:Activate()
end

function TQG_MainMenuManager_Gamepad:DeactivateHelperPanel()
	if self.activeHelperPanel then
		self.activeHelperPanel:Deactivate()
		if self:IsShowing() then
			self:ActivateCurrentList()
			KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
		end
		self.activeHelperPanel:UnregisterCallback("PanelSelectionEnd", self.exitHelperPanelFunction)
		self.activeHelperPanel = nil
	end
end

function TQG_MainMenuManager_Gamepad:IsShowing()
	return SCENE_MANAGER:IsShowing("tqgMenuGamepad") or SCENE_MANAGER:IsShowing("tqgSubmenu")
end

function TQG_MainMenuManager_Gamepad:ShowLastCategory()
	SCENE_MANAGER:Show("tqgMenuGamepad")
end

function TQG_MainMenuManager_Gamepad:MarkNewnessDirty()
	if self:IsShowing() then
		self:RefreshLists()
	end
end

function TQG_MainMenuManager_Gamepad:OnNumNotificationsChanged(numNotifications)
	self:MarkNewnessDirty()
end

function TQG_MainMenuManager_Gamepad:IsEntrySceneShowing(entryData)
	if entryData.sceneGroup then
		if SCENE_MANAGER:IsSceneGroupShowing(entryData.sceneGroup) then
			return true
		end
	end

	if entryData.additionalScenes then
		for _, scene in ipairs(entryData.additionalScenes) do
			if SCENE_MANAGER:IsShowing(scene) then
				return true
			end
		end
	end

	return SCENE_MANAGER:IsShowing(entryData.scene)
end

function TQG_MainMenuManager_Gamepad:ToggleCategory(category)
	local entryData = CATEGORY_TO_ENTRY_DATA[category]

	if self:IsEntrySceneShowing(entryData) then
		SCENE_MANAGER:ShowBaseScene()
	else
		if entryData.isVisibleCallback and not entryData.isVisibleCallback() then
			return
		end

		if ShouldDisableEntry(entryData) then
			return
		end

		self:ToggleScene(entryData.scene)
	end
end

function TQG_MainMenuManager_Gamepad:ShowCategory(category)
	self:ShowScene(CATEGORY_TO_ENTRY_DATA[category].scene)
end

function TQG_MainMenuManager_Gamepad:ShowScene(sceneName)
	if MAIN_MENU_MANAGER:HasBlockingScene() then
		local sceneData = {
			sceneName = sceneName,
		}
		MAIN_MENU_MANAGER:ActivatedBlockingScene_Scene(sceneData)
	else
		SCENE_MANAGER:Show(sceneName)
	end
end

function TQG_MainMenuManager_Gamepad:ToggleScene(sceneName)
	if MAIN_MENU_MANAGER:HasBlockingScene() then
		local sceneData = {
			sceneName = sceneName,
		}
		MAIN_MENU_MANAGER:ActivatedBlockingScene_Scene(sceneData)
	else
		SCENE_MANAGER:Toggle(sceneName)
	end
end

function TQG_MainMenuManager_Gamepad:AttemptShowBaseScene()
	if MAIN_MENU_MANAGER:HasBlockingScene() then
		MAIN_MENU_MANAGER:ActivatedBlockingScene_BaseScene()
	else
		SCENE_MANAGER:ShowBaseScene()
	end
end

function TQG_MainMenuManager_Gamepad:SelectMenuEntry(menuEntry)
	self.mainList:SetSelectedIndexWithoutAnimation(self.mainMenuEntryToListIndex[menuEntry])
end

function TQG_MainMenuManager_Gamepad:SelectMenuEntryAndSubEntry(menuEntry, menuSubEntry, sceneName)
	self:SelectMenuEntry(menuEntry)
	local entry = self.mainList:GetTargetData()
	self:RefreshSubList(entry)
	self.subList:SetSelectedIndexWithoutAnimation(self.subMenuEntryToListIndex[menuSubEntry])
	if sceneName then
		SCENE_MANAGER:CreateStackFromScratch("tqgMenuGamepad", "tqgSubmenu", sceneName)
	else
		SCENE_MANAGER:CreateStackFromScratch("tqgMenuGamepad", "tqgSubmenu")
	end
end

function TQG_MainMenu_Gamepad_OnInitialized(self)
	TQG_MENU_GAMEPAD = TQG_MainMenuManager_Gamepad:New(self)
	SYSTEMS:RegisterGamepadObject("tqgMenu", TQG_MENU_GAMEPAD)
end