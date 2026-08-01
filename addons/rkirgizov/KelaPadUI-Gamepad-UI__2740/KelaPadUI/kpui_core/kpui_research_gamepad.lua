local Kela_Research = ZO_Gamepad_ParametricList_Screen:Subclass()
local colors = kpuiConst.Colors	
local smithingTypes = kpuiConst.SmithingTypes
kelaAvailableTraitsIcons = ""




local selectedIndex = 1
local templateEntryBlacksmithing
local templateEntryClothier
local templateEntryWoodworking
local templateEntryJewelrycrafting

TRAIT_RESEARCHABLE = 0
TRAIT_KNOWN = 1
TRAIT_RESEARCH_IN_PROGRESS = 2

-- переменные главной панели исследований
ResearchPanelIsInitialize = false
indexResearchPanel = 1
Research = {}
focusResearchPanelMain = {}

function Kela_Research:GetCurrentResearchFocusControl()
	if not Research.Panel1:IsHidden() then 
		return Research.Focus1
	elseif not Research.Panel2:IsHidden() then 
		return Research.Focus2
	elseif not Research.Panel3:IsHidden() then 
		return Research.Focus3
	elseif not Research.Panel4:IsHidden() then 
		return Research.Focus4
	elseif not Research.Panel5:IsHidden() then 
		return Research.Focus5
	elseif not Research.Panel6:IsHidden() then 
		return Research.Focus6
	elseif not Research.Panel7:IsHidden() then 
		return Research.Focus7
	end
end
function Kela_Research:RemoveResearchPanelFocus()
	local currentFocusControl = Kela_Research:GetCurrentResearchFocusControl()
	if currentFocusControl then 
		if currentFocusControl:IsActive() then 
			currentFocusControl:SetActive(false, false) 
			KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_MAIN_TOOLTIP)				
			KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
		end				
	end
end
function Kela_Research:SetResearchPanelFocus()
	local currentFocusControl = Kela_Research:GetCurrentResearchFocusControl()
	if currentFocusControl then 
		if currentFocusControl then 				
			currentFocusControl:SetActive(true, false)
			KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
		end		
	end
end
function Kela_Research:ResearchPanelFocusIsActive()
	local currentFocusControl = Kela_Research:GetCurrentResearchFocusControl()
	if currentFocusControl then 
		if currentFocusControl:IsActive() then return true end
	end
	return false
end


local KELA_RESEARCH_DISPLAY_MODE = 
{
    TOTAL = 0,
	BLACKSMITHING = CRAFTING_TYPE_BLACKSMITHING,
    CLOTHIER = CRAFTING_TYPE_CLOTHIER,
    WOODWORKING = CRAFTING_TYPE_WOODWORKING,
    JEWELRY = CRAFTING_TYPE_JEWELRYCRAFTING,
}

function Kela_Research:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function Kela_Research:Initialize(control)
    KELA_RESEARCH_SCENE = ZO_Scene:New("kelaResearch", SCENE_MANAGER)
	
    ZO_Gamepad_ParametricList_Screen.Initialize(self, control, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, nil, KELA_RESEARCH_SCENE)
    local kelaResearchFragment = ZO_FadeSceneFragment:New(control)
    KELA_RESEARCH_SCENE:AddFragment(kelaResearchFragment)
    self.headerData = {
        titleText = GetString(KELA_MAINMENU_RESEARCHING),
    }
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)

	-- уровень в ремеслах
    self.skillInfoBar = Kela_GamepadSmithingTopLevelSkillInfo
    local skillLineXPBarFragment = ZO_FadeSceneFragment:New(self.skillInfoBar)
    KELA_RESEARCH_SCENE:AddFragment(skillLineXPBarFragment)

    local list = self:GetMainList()
    list:SetHandleDynamicViewProperties(true)
end

function Kela_Research:InitializeKeybindStripDescriptors()
	

    self.keybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = GetString(SI_GAMEPAD_SELECT_OPTION),
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
				local currentFocusControl = Kela_Research:GetCurrentResearchFocusControl()
				if currentFocusControl then 				
					currentFocusControl:SetActive(true, false)
					KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
				end
            end,
        },
        {
		
			name = GetString(SI_GAMEPAD_BACK_OPTION),
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
				if Kela_Research:ResearchPanelFocusIsActive() then				
					Kela_Research:RemoveResearchPanelFocus()
					KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_MAIN_TOOLTIP)				
					KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
				else
					SCENE_MANAGER:HideCurrentScene()
				end
				
            end,
        },
		{
			keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
			callback = function()
				local list = self:GetMainList()			
				local targetData = list:GetTargetData()
				local oldIndexResearchPanel = indexResearchPanel
				if targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.BLACKSMITHING then
					indexResearchPanel = 2
				elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.CLOTHIER then
					indexResearchPanel = 4
				elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.WOODWORKING then
					indexResearchPanel = 6
				elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.JEWELRY then
					indexResearchPanel = 7
				end
				if oldIndexResearchPanel ~= indexResearchPanel then 
					local focusIsActive = Kela_Research:ResearchPanelFocusIsActive()
					Kela_Research:RemoveResearchPanelFocus()
					kelaRefreshResearchPanel(targetData.displayMode)
					if focusIsActive then Kela_Research:SetResearchPanelFocus() end
				end
			end,
			ethereal = true,
			sound = SOUNDS.GAMEPAD_MENU_FORWARD,
		},
		{
			keybind = "UI_SHORTCUT_LEFT_SHOULDER",
			callback = function()
				local list = self:GetMainList()			
				local targetData = list:GetTargetData()
				local oldIndexResearchPanel = indexResearchPanel
				if targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.BLACKSMITHING then
					indexResearchPanel = 1
				elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.CLOTHIER then
					indexResearchPanel = 3
				elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.WOODWORKING then
					indexResearchPanel = 5
				elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.JEWELRY then
					indexResearchPanel = 7
				end			
				if oldIndexResearchPanel ~= indexResearchPanel then  
					local focusIsActive = Kela_Research:ResearchPanelFocusIsActive()
					Kela_Research:RemoveResearchPanelFocus()
					kelaRefreshResearchPanel(targetData.displayMode)
					if focusIsActive then Kela_Research:SetResearchPanelFocus() end
				end
			end,
			ethereal = true,
			sound = SOUNDS.GAMEPAD_MENU_FORWARD,
		},
		{
			keybind = "UI_SHORTCUT_INPUT_RIGHT",
			callback = function()
				local currentFocusControl = Kela_Research:GetCurrentResearchFocusControl()
				if currentFocusControl then 				
					if currentFocusControl:IsActive() then 
						local oldIndex = currentFocusControl:GetFocus(false)
						local newIndex = oldIndex + 9
						local data = currentFocusControl:GetItem(newIndex)
						if data then
							currentFocusControl:SetFocusByIndex(newIndex, false)
						end					
					end
				end
			end,
			ethereal = true,
			sound = SOUNDS.GAMEPAD_MENU_UP,
		},
		{
			keybind = "UI_SHORTCUT_INPUT_LEFT",
			callback = function()
				local currentFocusControl = Kela_Research:GetCurrentResearchFocusControl()
				if currentFocusControl then 				
					if currentFocusControl:IsActive() then 
						local newIndex = currentFocusControl:GetFocus(false) - 9
						local data = currentFocusControl:GetItem(newIndex)
						if data then
							currentFocusControl:SetFocusByIndex(newIndex, false)
						end				
					end
				end
			end,
			ethereal = true,
			sound = SOUNDS.GAMEPAD_MENU_UP,
		},
    }

end

do
    local function AddEntry(list, name, header, icon, displayMode, index)
		local researchLines, count, maxResearchable = KelaGetCurrentResearchLines(displayMode)
		local templateEntry = "Kela_ResearchLinesEntryTemplate0"
		if count > 0 then templateEntry = "Kela_ResearchLinesEntryTemplate"..tostring(index)..tostring(count) end
		if displayMode == CRAFTING_TYPE_BLACKSMITHING then
			templateEntryBlacksmithing = templateEntry
		elseif displayMode == CRAFTING_TYPE_CLOTHIER then
			templateEntryClothier = templateEntry
		elseif displayMode == CRAFTING_TYPE_WOODWORKING then
			templateEntryWoodworking = templateEntry
		elseif displayMode == CRAFTING_TYPE_JEWELRYCRAFTING then
			templateEntryJewelrycrafting = templateEntry
		end
		local postPadding = 22 * count
		local data
		if maxResearchable > 0 then 
			data = ZO_GamepadEntryData:New(GetString(name).." "..researchLines, icon)
		else
			data = ZO_GamepadEntryData:New(GetString(name), icon)
			postPadding = postPadding * 6
		end
        data:SetIconTintOnSelection(true)
		data.displayMode = displayMode
        if header then
			data.header = GetString(header)
			list:AddEntryWithHeader(templateEntry, data, 0, postPadding)
		else
			list:AddEntry(templateEntry, data, 0, postPadding)
		end
    end

    local function ResearchLinesEntrySetup0(control, data, selected, reselectingDuringRebuild, enabled, active)
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
    end
    local function ResearchLinesEntrySetup1(control, data, selected, reselectingDuringRebuild, enabled, active)
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
		local ResearchLineLabel1 = control:GetNamedChild("ResearchLine1")
    end
    local function ResearchLinesEntrySetup2(control, data, selected, reselectingDuringRebuild, enabled, active)
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
        local ResearchLineLabel1 = control:GetNamedChild("ResearchLine1")
		local ResearchLineLabel2 = control:GetNamedChild("ResearchLine2")
    end
    local function ResearchLinesEntrySetup3(control, data, selected, reselectingDuringRebuild, enabled, active)
        ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
        local ResearchLineLabel1 = control:GetNamedChild("ResearchLine1")
        local ResearchLineLabel2 = control:GetNamedChild("ResearchLine2")
        local ResearchLineLabel3 = control:GetNamedChild("ResearchLine3")
    end

    function Kela_Research:SetupList(list)
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate0", ResearchLinesEntrySetup0, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate0", ResearchLinesEntrySetup0, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate11", ResearchLinesEntrySetup1, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate11", ResearchLinesEntrySetup1, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate12", ResearchLinesEntrySetup2, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate12", ResearchLinesEntrySetup2, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate13", ResearchLinesEntrySetup3, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate13", ResearchLinesEntrySetup3, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate21", ResearchLinesEntrySetup1, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate21", ResearchLinesEntrySetup1, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate22", ResearchLinesEntrySetup2, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate22", ResearchLinesEntrySetup2, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate23", ResearchLinesEntrySetup3, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate23", ResearchLinesEntrySetup3, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate31", ResearchLinesEntrySetup1, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate31", ResearchLinesEntrySetup1, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate32", ResearchLinesEntrySetup2, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate32", ResearchLinesEntrySetup2, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate33", ResearchLinesEntrySetup3, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate33", ResearchLinesEntrySetup3, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
        list:AddDataTemplate("Kela_ResearchLinesEntryTemplate41", ResearchLinesEntrySetup1, ZO_GamepadMenuEntryTemplateParametricListFunction)
        list:AddDataTemplateWithHeader("Kela_ResearchLinesEntryTemplate41", ResearchLinesEntrySetup1, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Kela_ResearchLinesEntryHeaderTemplate")
    end

    function Kela_Research:PopulateList()
		local list = self:GetMainList()
        list:Clear()		
		AddEntry(list, KELA_MAINMENU_RESEARCHING_TOTAL, nil, nil, KELA_RESEARCH_DISPLAY_MODE.TOTAL, 0)
		AddEntry(list, KELA_MAINMENU_RESEARCHING_BLACKSMITHING, nil, "EsoUI/art/icons/servicemappins/servicepin_smithy.dds", KELA_RESEARCH_DISPLAY_MODE.BLACKSMITHING, 1)
        AddEntry(list, KELA_MAINMENU_RESEARCHING_CLOTHIER, nil, "EsoUI/art/icons/servicemappins/servicepin_clothier.dds", KELA_RESEARCH_DISPLAY_MODE.CLOTHIER, 2)
        AddEntry(list, KELA_MAINMENU_RESEARCHING_WOODWORKING, nil, "EsoUI/art/icons/servicemappins/servicepin_woodworking.dds", KELA_RESEARCH_DISPLAY_MODE.WOODWORKING, 3)
		AddEntry(list, KELA_MAINMENU_RESEARCHING_JEWELRY, nil, "EsoUI/art/icons/servicemappins/servicepin_jewelrycrafting.dds", KELA_RESEARCH_DISPLAY_MODE.JEWELRY, 4)
		local countBars = 0
		for s=1,#smithingTypes do
			local count = 0
			for researchLineIndex=1, GetNumSmithingResearchLines(smithingTypes[s]) do
				local stringTrait1
				local styleColor1
				local tname, icon, numTraits = GetSmithingResearchLineInfo(smithingTypes[s], researchLineIndex)
				for t=1, numTraits do
					local traitType, _, known = GetSmithingResearchLineTraitInfo(smithingTypes[s], researchLineIndex, t)
					local dur, remaining = GetSmithingResearchLineTraitTimes(smithingTypes[s], researchLineIndex, t)
					if dur and remaining then
						--KelaPostMsg(tostring(dur).." "..tostring(remaining))
						count = count + 1
						stringTrait1 = colors.COLOR_WHITE:Colorize(GetString("SI_ITEMTRAITTYPE", traitType)).." ("..tname..")"
						local templateEntry
						if smithingTypes[s] == CRAFTING_TYPE_BLACKSMITHING then
							templateEntry = templateEntryBlacksmithing
						elseif smithingTypes[s] == CRAFTING_TYPE_CLOTHIER then
							templateEntry = templateEntryClothier
						elseif smithingTypes[s] == CRAFTING_TYPE_WOODWORKING then
							templateEntry = templateEntryWoodworking
						elseif smithingTypes[s] == CRAFTING_TYPE_JEWELRYCRAFTING then
							templateEntry = templateEntryJewelrycrafting
						end	
						local controlPreName = list.scrollControl:GetName()..templateEntry.."1"
						local ResearchLine = GetControl(controlPreName.."ResearchLine"..count)	 
						if ResearchLine ~= nil then	
							--KelaPostMsg("ResearchLine "..tostring(ResearchLine))
							ResearchLine:SetText(tostring(stringTrait1)) 
							if countBars < 10 then
								countBars = countBars + 1
								local TimerBar = ZO_TimerBar:New(self.control:GetNamedChild("TimerBar"..countBars))
								TimerBar:SetDirection(TIMER_BAR_COUNTS_DOWN)
								TimerBar:SetTimeFormatParameters(TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR_NO_SECONDS)
								local now = GetFrameTimeSeconds()
								local timeElapsed = dur - remaining
								TimerBar:Start(now - timeElapsed, now + remaining) 
								local kelatimerControl = TimerBar.control
								kelatimerControl:SetParent(ResearchLine)
								kelatimerControl:ClearAnchors()
								local newAnchor = ZO_Anchor:New(TOPLEFT, ResearchLine, TOPLEFT, -2, 7)
								newAnchor:AddToControl(kelatimerControl)
							end
						end	
					end
				end
			end	
		end		
		list:Commit()
    end
end

function Kela_Research:UpdateScreenVisibility(list)
    local targetData = list:GetTargetData()
	if targetData then
		if targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.TOTAL then
			indexResearchPanel = 0
			Kela_Research:SetEnableSkillBar(self.skillInfoBar, false)
		elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.BLACKSMITHING then
			indexResearchPanel = 1
			Kela_Research:SetEnableSkillBar(self.skillInfoBar, true, targetData.displayMode)
		elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.CLOTHIER then
			indexResearchPanel = 3
			Kela_Research:SetEnableSkillBar(self.skillInfoBar, true, targetData.displayMode)
		elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.WOODWORKING then
			indexResearchPanel = 5
			Kela_Research:SetEnableSkillBar(self.skillInfoBar, true, targetData.displayMode)
		elseif targetData.displayMode == KELA_RESEARCH_DISPLAY_MODE.JEWELRY then
			indexResearchPanel = 7
			Kela_Research:SetEnableSkillBar(self.skillInfoBar, true, targetData.displayMode)
		end			
		
		Kela_Research:RemoveResearchPanelFocus()
		KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_MAIN_TOOLTIP)				
		KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)		
		kelaRefreshResearchPanel (targetData.displayMode)
		
	end
end
function Kela_Research:SetEnableSkillBar(skillInfoBar, enable, craftingType)
    
    if enable then
		skillInfoBar.xpBar:SetHidden(false)
		skillInfoBar.name:SetHidden(false)
		skillInfoBar.rank:SetHidden(false)
        ZO_Skills_TieSkillInfoHeaderToCraftingSkill(skillInfoBar, craftingType)
    else
		skillInfoBar.xpBar:SetHidden(true)
		skillInfoBar.name:SetHidden(true)
		skillInfoBar.rank:SetHidden(true)
	end		

end

function Kela_Research:PerformUpdate()
    self:PopulateList()
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    self.headerData.titleText = GetString(KELA_MAINMENU_RESEARCHING)
    ZO_GamepadGenericHeader_Refresh(self.header, self.headerData)
    self.dirty = false
end

function Kela_Research:OnSelectionChanged(list, selectedData, oldSelectedData)
	if oldSelectedData and selectedData ~= oldSelectedData then
		self:UpdateScreenVisibility(list)
	end
	KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

function Kela_Research:OnShowing()
    ZO_Gamepad_ParametricList_Screen.OnShowing(self)
	self:GetMainList():SetSelectedIndex(1)
	self:PopulateList()
	self:GetMainList():SetSelectedIndex(selectedIndex)
    self:UpdateScreenVisibility(self:GetMainList())
    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
end

function Kela_Research:OnHiding()
	selectedIndex = self:GetMainList():GetSelectedIndex()
	Kela_Research:RemoveResearchPanelFocus()	
	KPUI_GAMEPAD_TOOLTIPS:ClearContentHeader(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)
end



function Kela_Research:InitializeResearchPanel(craftingSkillType)

	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)
	
	
	local CoreResearchPanelOld = GetControl(tooltipInfo:GetName().."ResearchPanel".."1")
	if CoreResearchPanelOld then
		CoreResearchPanel = GetControl(tooltipInfo:GetName().."ResearchPanel".."1")
	else
		CoreResearchPanel  = KPUI_GamepadTooltip:CreateResearchPanel(tooltipInfo, nil, 1)		
	end
	
	local function fillResearchPanel(index)
	
		local craftingType, indexStart, researchPanel, stringLabel, indexFinish, offsetX

		if index then indexResearchPanel = index end
		
		if indexResearchPanel == 1 then
			craftingType = CRAFTING_TYPE_BLACKSMITHING
			indexStart = 1
			indexFinish = 7
			offsetX = 197
			researchPanel = CoreResearchPanel.panelResearch1
		elseif indexResearchPanel == 2 then
			craftingType = CRAFTING_TYPE_BLACKSMITHING
			indexStart = 8
			indexFinish = 14
			offsetX = 197
			researchPanel = CoreResearchPanel.panelResearch2	
		elseif indexResearchPanel == 3 then
			craftingType = CRAFTING_TYPE_CLOTHIER
			indexStart = 1
			indexFinish = 7
			offsetX = 197
			researchPanel = CoreResearchPanel.panelResearch3	
		elseif indexResearchPanel == 4 then
			craftingType = CRAFTING_TYPE_CLOTHIER
			indexStart = 8	
			indexFinish = 14
			offsetX = 197
			researchPanel = CoreResearchPanel.panelResearch4	
		elseif indexResearchPanel == 5 then
			craftingType = CRAFTING_TYPE_WOODWORKING
			indexStart = 1
			indexFinish = 5	
			offsetX = 258
			researchPanel = CoreResearchPanel.panelResearch5	
		elseif indexResearchPanel == 6 then
			craftingType = CRAFTING_TYPE_WOODWORKING
			indexStart = 6
			indexFinish = 6	
			offsetX = 380
			researchPanel = CoreResearchPanel.panelResearch6	
		elseif indexResearchPanel == 7 then
			craftingType = CRAFTING_TYPE_JEWELRYCRAFTING
			indexStart = 1	
			indexFinish = 2
			offsetX = 350
			researchPanel = CoreResearchPanel.panelResearch7	
		end

		researchPanel.focusResearchPanel = ZO_GamepadFocus:New(researchPanel, nil, MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)		
		
		
		local KNOWN_ICON = "ESOUI/art/crafting/smithing_tabicon_research_down.dds"
		local UNKNOWN_ICON = "ESOUI/art/crafting/smithing_tabicon_research_disabled.dds"
		local INPROGRESS_ICON = "ESOUI/art/crafting/smithing_tabicon_research_over.dds"
		local iconResearchLine
		local iconTraitKnowledge
		for researchLineIndex = indexStart, indexFinish do --GetNumSmithingResearchLines(craftingType) do 
			local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingType, researchLineIndex) 
			local iconResearchLineOld = GetControl(tooltipInfo:GetName().."ResearchLine"..indexResearchPanel..researchLineIndex)
			if iconResearchLineOld then
				iconResearchLine = GetControl(tooltipInfo:GetName().."ResearchLine"..indexResearchPanel..researchLineIndex)
				iconResearchLine.icon:ClearIcons()
			else
				
				if researchLineIndex == indexStart then
					iconResearchLine = KPUI_GamepadTooltip:CreateResearchLineSlot(tooltipInfo, CoreResearchPanel.DividerPipped, indexResearchPanel..researchLineIndex, offsetX, 120)				
				else
					iconResearchLine = KPUI_GamepadTooltip:CreateResearchLineSlot(tooltipInfo, iconResearchLine, indexResearchPanel..researchLineIndex)				
				end

			end
			iconResearchLine:SetParent(researchPanel)
			iconResearchLine.icon:AddIcon(icon)
			iconResearchLine.icon:Show()

			local countKnown = 0
			for traitIndex=1, numTraits do
				local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, traitIndex)
			
				local function kelaGetTraitIcon()
					for traitItemIndex = 1, GetNumSmithingTraitItems() do
						local traitTypeConfirm, _, icon, _, _, _, _ = GetSmithingTraitItemInfo(traitItemIndex) --itemStyle is zero
						if traitTypeConfirm and traitTypeConfirm == traitType then
							return icon
						end
					end	
				end			
				
				local traitIcon = kelaGetTraitIcon()
				local traitDescription, traitResearchSourceDescription, traitMaterialSourceDescription = GetSmithingResearchLineTraitDescriptions(craftingType, researchLineIndex, traitIndex)
				local traitName = GetString("SI_ITEMTRAITTYPE", traitType)
				local iconTraitKnowledgeOld = GetControl(tooltipInfo:GetName().."Trait"..indexResearchPanel..researchLineIndex..traitIndex)
				
				-- KelaPostMsg(tostring(traitIndex))			
				if iconTraitKnowledgeOld then
					iconTraitKnowledge = GetControl(tooltipInfo:GetName().."Trait"..indexResearchPanel..researchLineIndex..traitIndex)
					iconTraitKnowledge.icon:ClearIcons()
				else
					if traitIndex == 1 then 
						iconTraitKnowledge = KPUI_GamepadTooltip:CreateTraitSlot(tooltipInfo, iconResearchLine, indexResearchPanel..researchLineIndex..traitIndex)
					else	
						iconTraitKnowledge = KPUI_GamepadTooltip:CreateTraitSlot(tooltipInfo, iconTraitKnowledge, indexResearchPanel..researchLineIndex..traitIndex)
					end				
				end

				local iconTraitKnowledgeHighlight
				
				local iconTraitKnowledgeHighlightOld = GetControl(tooltipInfo:GetName().."iconTraitKnowledgeHighlight"..indexResearchPanel..researchLineIndex..traitIndex)
				if iconTraitKnowledgeHighlightOld then
					iconTraitKnowledgeHighlight = GetControl(tooltipInfo:GetName().."iconTraitKnowledgeHighlight"..indexResearchPanel..researchLineIndex..traitIndex)
				else
					iconTraitKnowledgeHighlight = CreateControlFromVirtual("$(parent)iconTraitKnowledgeHighlight", tooltipInfo, "KPUI_TraitLabelHighlight", indexResearchPanel..researchLineIndex..traitIndex)
					iconTraitKnowledgeHighlight:SetParent(researchPanel)

				end					

				local intKnowledge
				local itemCraftType
				if known then
					intKnowledge = 0
				else
					local dur, remainig = GetSmithingResearchLineTraitTimes(craftingType, researchLineIndex, traitIndex)
					local traitResearchStatus = KELA_RESEARCH:GetTraitTypeResearchStatus(traitType, craftingType, researchLineIndex)

					if traitResearchStatus == 0 then 
						itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[craftingType][researchLineIndex] 
						local tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree = KELA_RESEARCH:GetTableResearchableItemsByTrait(craftingType, itemCraftType, researchLineIndex, traitType)				
						if tblResearchableItemsWorned or tblResearchableItemsLocked or tblResearchableItemsFree then
							traitResearchStatus = 1
						end
					end
					
					if traitResearchStatus == 0 then 
						intKnowledge = 1
					elseif dur and remainig then
						intKnowledge = 2
					else
						intKnowledge = 3
					end
				end
				
				local iconTraitKnowledgeFocusData = 
				{
					highlight = iconTraitKnowledgeHighlight,
					control = iconTraitKnowledge,
					data = {
						traitCraftingType = craftingType,
						traitItemCraftType = itemCraftType,
						traitResearchLineIndex = researchLineIndex,
						traitResearchLineName = name,
						traitType = traitType,
						traitName = traitName,
						traitKnowledge = intKnowledge,
						traitItemLink = kpuiConst.ItemLinkForTraitType[traitType],
						traitIcon = traitIcon,
						traitDescription = traitDescription,
						traitResearchSourceDescription = traitResearchSourceDescription,
						traitMaterialSourceDescription = traitMaterialSourceDescription,
					},
					activate = function(control, data)
						-- KelaPostMsg("traitType - "..traitIcon.." "..zo_iconFormat(traitIcon, 24, 24).." "..tostring(kpuiConst.ItemLinkForTraitType[traitType]))
						KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_MAIN_TOOLTIP)
						KPUI_GAMEPAD_TOOLTIPS:LayoutResearchSmithingItem(KPUI_GAMEPAD_MAIN_TOOLTIP, data.traitName, data.traitDescription, data.traitResearchSourceDescription, data.traitMaterialSourceDescription)
						kelaAddMoreInfo(KPUI_GAMEPAD_TOOLTIPS:GetTooltip(KPUI_GAMEPAD_MAIN_TOOLTIP), data.traitCraftingType, data.traitItemCraftType, data.traitResearchLineIndex, data.traitResearchLineName, data.traitType, kpuiConst.ItemLinkForTraitType[data.traitType], data.traitName, data.traitKnowledge, data.traitIcon)
					end,
					deactivate = function() 
					end,
					-- canFocus = function() if indexResearchPanel == 1 end,
				}
		
				researchPanel.focusResearchPanel:AddEntry(iconTraitKnowledgeFocusData)

				local labelTrait, labelTraitRight, labelTraitRightHighlight
				if indexResearchPanel == 6 then -- щиты, один столбец
					local labelTraitOld = GetControl(tooltipInfo:GetName().."labelTrait"..indexResearchPanel..researchLineIndex..traitIndex)
					if labelTraitOld then
						labelTrait = GetControl(tooltipInfo:GetName().."labelTrait"..indexResearchPanel..researchLineIndex..traitIndex)
					else
						labelTrait = CreateControlFromVirtual("$(parent)labelTrait", tooltipInfo, "KPUI_TraitLabel", indexResearchPanel..researchLineIndex..traitIndex)
						labelTrait:SetParent(researchPanel)
					end
					labelTrait:SetText(traitName)
					local labelTraitRightOld = GetControl(tooltipInfo:GetName().."labelTraitRight"..indexResearchPanel..researchLineIndex..traitIndex)
					if labelTraitRightOld then
						labelTraitRight = GetControl(tooltipInfo:GetName().."labelTraitRight"..indexResearchPanel..researchLineIndex..traitIndex)
					else
						labelTraitRight = CreateControlFromVirtual("$(parent)labelTraitRight", tooltipInfo, "KPUI_TraitLabel", indexResearchPanel..researchLineIndex..traitIndex)
						labelTraitRight:SetParent(researchPanel)
					end
					labelTraitRight:SetText(traitName)
				elseif researchLineIndex == indexStart then -- первый столбец
					local labelTraitOld = GetControl(tooltipInfo:GetName().."labelTrait"..indexResearchPanel..researchLineIndex..traitIndex)
					if labelTraitOld then
						labelTrait = GetControl(tooltipInfo:GetName().."labelTrait"..indexResearchPanel..researchLineIndex..traitIndex)
					else
						labelTrait = CreateControlFromVirtual("$(parent)labelTrait", tooltipInfo, "KPUI_TraitLabel", indexResearchPanel..researchLineIndex..traitIndex)
						labelTrait:SetParent(researchPanel)
					end
					labelTrait:SetText(traitName)
				elseif researchLineIndex == indexFinish or indexStart == indexFinish then 
					local labelTraitRightOld = GetControl(tooltipInfo:GetName().."labelTraitRight"..indexResearchPanel..researchLineIndex..traitIndex)
					if labelTraitRightOld then
						labelTraitRight = GetControl(tooltipInfo:GetName().."labelTraitRight"..indexResearchPanel..researchLineIndex..traitIndex)
					else
						labelTraitRight = CreateControlFromVirtual("$(parent)labelTraitRight", tooltipInfo, "KPUI_TraitLabel", indexResearchPanel..researchLineIndex..traitIndex)
						labelTraitRight:SetParent(researchPanel)
					end

					labelTraitRight:SetText(traitName)
				end

				if traitIndex == 9 then
					local countColor
					if countKnown >= 8 then
						countColor = colors.COLOR_NEARLY
					elseif countKnown >= 5 then
						countColor = colors.COLOR_SOON
					elseif countKnown >= 3 then 
						countColor = colors.COLOR_NOTSOON
					else
						countColor = colors.COLOR_RED
					end
					local labelTraitBottomOld = GetControl(tooltipInfo:GetName().."labelTraitBottom"..indexResearchPanel..researchLineIndex..traitIndex)
					if labelTraitBottomOld then
						labelTraitBottom = GetControl(tooltipInfo:GetName().."labelTraitBottom"..indexResearchPanel..researchLineIndex..traitIndex)
					else
						labelTraitBottom = CreateControlFromVirtual("$(parent)labelTraitBottom", tooltipInfo, "KPUI_TraitLabel", indexResearchPanel..researchLineIndex..traitIndex)
						labelTraitBottom:SetParent(researchPanel)
					end
					labelTraitBottom:SetText(countColor:Colorize(tostring(countKnown)))						
				end				
				iconTraitKnowledge:SetParent(researchPanel)
				iconTraitKnowledge.icon:Show()
			end	
			if indexResearchPanel == 1 then
				Research.Panel1 = researchPanel
				Research.Focus1 = researchPanel.focusResearchPanel
			end
			if indexResearchPanel == 2 then
				Research.Panel2 = researchPanel
				Research.Focus2 = researchPanel.focusResearchPanel
			end
			if indexResearchPanel == 3 then
				Research.Panel3 = researchPanel
				Research.Focus3 = researchPanel.focusResearchPanel
			end
			if indexResearchPanel == 4 then
				Research.Panel4 = researchPanel
				Research.Focus4 = researchPanel.focusResearchPanel
			end
			if indexResearchPanel == 5 then
				Research.Panel5 = researchPanel
				Research.Focus5 = researchPanel.focusResearchPanel
			end
			if indexResearchPanel == 6 then
				Research.Panel6 = researchPanel
				Research.Focus6 = researchPanel.focusResearchPanel
			end
			if indexResearchPanel == 7 then
				Research.Panel7 = researchPanel
				Research.Focus7 = researchPanel.focusResearchPanel
			end
		end
	end	
	
	if not ResearchPanelIsInitialize then
		for index = 1, 7 do
			fillResearchPanel(index)
		end
		ResearchPanelIsInitialize = true
		indexResearchPanel = 1
	elseif craftingSkillType then
		if craftingSkillType == CRAFTING_TYPE_BLACKSMITHING then
			for index = 1, 2 do
				fillResearchPanel(index)
			end
		elseif craftingSkillType == CRAFTING_TYPE_CLOTHIER then
			for index = 3, 4 do
				fillResearchPanel(index)
			end
		elseif craftingSkillType == CRAFTING_TYPE_WOODWORKING then
			for index = 5, 6 do
				fillResearchPanel(index)
			end
		elseif craftingSkillType == CRAFTING_TYPE_JEWELRYCRAFTING then
			for index = 7, 7 do
				fillResearchPanel(index)
			end
		end
	else
		fillResearchPanel()
	end
end

function kelaRefreshResearchPanel (craftingType)

	KPUI_GAMEPAD_TOOLTIPS:Reset(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP))
	SCENE_MANAGER:AddFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP))	
	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltipTop(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)

	local CoreResearchPanel = GetControl(tooltipInfo:GetName().."ResearchPanel".."1")


	if indexResearchPanel == 0 then
		CoreResearchPanel:SetHidden(true)
		kelaRefreshTotalPanel()
	else
		CoreResearchPanel:SetHidden(false)

		local indexStart, indexFinish, researchPanel

		if indexResearchPanel == 1 then
			indexStart = 1
			indexFinish = 7
			researchPanel = CoreResearchPanel.panelResearch1
		elseif indexResearchPanel == 2 then
			indexStart = 8
			indexFinish = 14
			researchPanel = CoreResearchPanel.panelResearch2	
		elseif indexResearchPanel == 3 then
			indexStart = 1
			indexFinish = 7
			researchPanel = CoreResearchPanel.panelResearch3	
		elseif indexResearchPanel == 4 then
			indexStart = 8	
			indexFinish = 14
			researchPanel = CoreResearchPanel.panelResearch4	
		elseif indexResearchPanel == 5 then
			indexStart = 1
			indexFinish = 5	
			researchPanel = CoreResearchPanel.panelResearch5	
		elseif indexResearchPanel == 6 then
			indexStart = 6
			indexFinish = 6	
			researchPanel = CoreResearchPanel.panelResearch6	
		elseif indexResearchPanel == 7 then
			indexStart = 1	
			indexFinish = 2
			researchPanel = CoreResearchPanel.panelResearch7	
		end

		local title = GetString("KELA_RESEARCH_TYPE", indexResearchPanel)
		local dataHeaderText = ""
		local dataText = ""
		KPUI_GAMEPAD_TOOLTIPS:ClearContentHeader(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)
		KPUI_GAMEPAD_TOOLTIPS:RefreshContentHeader(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP, title, dataHeaderText, dataText)
		
		-- переключатель
		local PIP_WIDTH = 32 
		local activePipIndex = indexResearchPanel
		local s = 1
		local e = 7
		-- очищаем
		for i = s, e do
			local pip 
			local pipOld = GetControl(tooltipInfo:GetName().."ResearchTabBarPip"..i)
			if pipOld then
				pip = GetControl(tooltipInfo:GetName().."ResearchTabBarPip"..i)
				pip:GetNamedChild("Active"):SetHidden(true)
				pip:GetNamedChild("Inactive"):SetHidden(true)		
			end
		end
		if craftingType == KELA_RESEARCH_DISPLAY_MODE.BLACKSMITHING then
			s = 1
			e = 2
		elseif craftingType == KELA_RESEARCH_DISPLAY_MODE.CLOTHIER then
			s = 3
			e = 4
		elseif craftingType == KELA_RESEARCH_DISPLAY_MODE.WOODWORKING then
			s = 5
			e = 6
		elseif craftingType == KELA_RESEARCH_DISPLAY_MODE.JEWELRY then
			s = 7
			e = 7
		end
		for i = s, e do
			local pip 
			local pipOld = GetControl(tooltipInfo:GetName().."ResearchTabBarPip"..i)
			if pipOld then
				pip = GetControl(tooltipInfo:GetName().."ResearchTabBarPip"..i)
			else
				pip = CreateControlFromVirtual("$(parent)ResearchTabBarPip", tooltipInfo, "ZO_GamepadTabBarPip", i)
			end
			local active = (activePipIndex == i)
			pip:GetNamedChild("Active"):SetHidden(not active)
			pip:GetNamedChild("Inactive"):SetHidden(active)
			local centerPip
			if s == e then
				centerPip = 0
			else
				local c
				if i == 1 or i == 3 or i == 5 then 
					c = 1
				else
					c = 2
				end
				centerPip = (c - 1 - (2 - 1) / 2) * PIP_WIDTH
			end
			pip:SetParent(CoreResearchPanel.pipsControl)
			pip:SetAnchor(CENTER, CoreResearchPanel.pipsControl, CENTER, centerPip, 0)		
		end

		CoreResearchPanel.panelResearch1:SetHidden(indexResearchPanel ~= 1)
		CoreResearchPanel.panelResearch2:SetHidden(indexResearchPanel ~= 2)
		CoreResearchPanel.panelResearch3:SetHidden(indexResearchPanel ~= 3)
		CoreResearchPanel.panelResearch4:SetHidden(indexResearchPanel ~= 4)
		CoreResearchPanel.panelResearch5:SetHidden(indexResearchPanel ~= 5)
		CoreResearchPanel.panelResearch6:SetHidden(indexResearchPanel ~= 6)
		CoreResearchPanel.panelResearch7:SetHidden(indexResearchPanel ~= 7)
		
		local KNOWN_ICON = "ESOUI/art/crafting/smithing_tabicon_research_down.dds"
		local UNKNOWN_ICON = "ESOUI/art/crafting/smithing_tabicon_research_up.dds"
		local INPROGRESS_ICON = "ESOUI/art/crafting/smithing_tabicon_research_over.dds"
		local iconResearchLine
		local iconTraitKnowledge
		for researchLineIndex = indexStart, indexFinish do 
			
			local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(craftingType, researchLineIndex) 
			local iconResearchLine = GetControl(tooltipInfo:GetName().."ResearchLine"..indexResearchPanel..researchLineIndex)
			iconResearchLine.icon:ClearIcons()
			iconResearchLine.icon:AddIcon(icon)
			iconResearchLine.icon:Show()

			local countKnown = 0
			for traitIndex=1, numTraits do
				local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, traitIndex)
				
				local function kelaGetTraitIcon()
					for traitItemIndex = 1, GetNumSmithingTraitItems() do
						local traitTypeConfirm, _, icon, _, _, _, _ = GetSmithingTraitItemInfo(traitItemIndex) --itemStyle is zero
						if traitTypeConfirm and traitTypeConfirm == traitType then
							return icon
						end
					end	
				end			
				
				local traitIcon = kelaGetTraitIcon()
				local traitDescription, traitResearchSourceDescription, traitMaterialSourceDescription = GetSmithingResearchLineTraitDescriptions(craftingType, researchLineIndex, traitIndex)
				local traitName = GetString("SI_ITEMTRAITTYPE", traitType)
				local iconTraitKnowledge = GetControl(tooltipInfo:GetName().."Trait"..indexResearchPanel..researchLineIndex..traitIndex)

				iconTraitKnowledge.icon:ClearIcons()

				local iconTraitKnowledgeHighlight = GetControl(tooltipInfo:GetName().."iconTraitKnowledgeHighlight"..indexResearchPanel..researchLineIndex..traitIndex)
				iconTraitKnowledgeHighlight:SetAnchor(TOPLEFT, iconTraitKnowledge, TOPLEFT, -3, -3)
				iconTraitKnowledgeHighlight:SetAnchor(BOTTOMRIGHT, iconTraitKnowledge, BOTTOMRIGHT, 3, 3)

				local labelTrait, labelTraitRight
				if indexResearchPanel == 6 then -- щиты, один столбец
					labelTrait = GetControl(tooltipInfo:GetName().."labelTrait"..indexResearchPanel..researchLineIndex..traitIndex)
					labelTrait:SetAnchor(TOPRIGHT, iconTraitKnowledge, TOPLEFT, -10, 17)
					labelTrait:SetText(traitName)
					labelTraitRight = GetControl(tooltipInfo:GetName().."labelTraitRight"..indexResearchPanel..researchLineIndex..traitIndex)
					labelTraitRight:SetAnchor(TOPLEFT, iconTraitKnowledge, TOPRIGHT, 10, 17)
					labelTraitRight:SetText(traitName)
				elseif researchLineIndex == indexStart then -- первый столбец
					labelTrait = GetControl(tooltipInfo:GetName().."labelTrait"..indexResearchPanel..researchLineIndex..traitIndex)
					labelTrait:SetAnchor(TOPRIGHT, iconTraitKnowledge, TOPLEFT, -10, 17)
					labelTrait:SetText(traitName)
				elseif researchLineIndex == indexFinish or indexStart == indexFinish then 
					labelTraitRight = GetControl(tooltipInfo:GetName().."labelTraitRight"..indexResearchPanel..researchLineIndex..traitIndex)
					labelTraitRight:SetAnchor(TOPLEFT, iconTraitKnowledge, TOPRIGHT, 10, 17)
					labelTraitRight:SetText(traitName)
				end

				if known then
					iconTraitKnowledge.icon:AddIcon(KNOWN_ICON)
					iconTraitKnowledge.icon:SetDimensions(45, 45)
					countKnown = countKnown + 1
				else
					local dur, remainig = GetSmithingResearchLineTraitTimes(craftingType, researchLineIndex, traitIndex)
					local traitResearchStatus = KELA_RESEARCH:GetTraitTypeResearchStatus(traitType, craftingType, researchLineIndex)
					if traitResearchStatus == 0 then 
						local itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[craftingType][researchLineIndex] 
						local tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree = KELA_RESEARCH:GetTableResearchableItemsByTrait(craftingType, itemCraftType, researchLineIndex, traitType)				
						if tblResearchableItemsWorned or tblResearchableItemsLocked or tblResearchableItemsFree then
							traitResearchStatus = 1
						end
					end
					if traitResearchStatus == 0 then 
						
					elseif dur and remainig then
						iconTraitKnowledge.icon:AddIcon(INPROGRESS_ICON)
						iconTraitKnowledge.icon:SetDimensions(45, 45)
					else
						iconTraitKnowledge.icon:AddIcon(UNKNOWN_ICON)
						iconTraitKnowledge.icon:SetDimensions(35, 35)
					end
				end
				if traitIndex == 9 then
					local countColor
					if countKnown >= 8 then
						countColor = colors.COLOR_NEARLY
					elseif countKnown >= 5 then
						countColor = colors.COLOR_SOON
					elseif countKnown >= 3 then 
						countColor = colors.COLOR_NOTSOON
					else
						countColor = colors.COLOR_RED
					end
					local labelTraitBottom = GetControl(tooltipInfo:GetName().."labelTraitBottom"..indexResearchPanel..researchLineIndex..traitIndex)
					labelTraitBottom:SetAnchor(TOPLEFT, iconTraitKnowledge, BOTTOMLEFT, 24, 7)
					labelTraitBottom:SetText(countColor:Colorize(tostring(countKnown)))						
				end				
				iconTraitKnowledge.icon:Show()
			end	
		end
	end
		
end

function kelaRefreshTotalPanel()

	local tooltipInfo = KPUI_GAMEPAD_TOOLTIPS:GetTooltip(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP)

	-- имя и аккаунт
	local kelaPlayerName = GetUnitName('player')
	local kelaPlayerAccountName = GetUnitDisplayName('player')
	kelaPlayerName = kelaPlayerName..colors.COLOR_BROWN:Colorize(" ("..string.lower(kelaPlayerAccountName)..")")

	local ICON_BLACKSMITHING = "EsoUI/art/icons/servicemappins/servicepin_smithy.dds"
	local ICON_CLOTHIER = "EsoUI/art/icons/servicemappins/servicepin_clothier.dds"
	local ICON_WOODWORKING = "EsoUI/art/icons/servicemappins/servicepin_woodworking.dds"
	local ICON_JEWELRYCRAFTING = "EsoUI/art/icons/servicemappins/servicepin_jewelrycrafting.dds"

	KPUI_GAMEPAD_TOOLTIPS:SetStatusLabelText(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP, kelaPlayerName, "", GetString(KELA_RESEARCHINGSCENE_TOTAL_HEADER))

	local function fillTooltip(index)
		local indexStart, indexFinish
		local intType
		local iconCraftingType
		local headerResearches
		local headerResearchLines
		local infoResearched
		local infoAvalable
		local strInfoResearched	
		local strInfoAvailable
		local countKnown = 0
		local countTraits = 0	
		
		if index == 1 then
			craftingType = CRAFTING_TYPE_BLACKSMITHING
			iconCraftingType = zo_iconFormat(ICON_BLACKSMITHING, 32, 32).." "
			intType = WEAPONTYPE_BLACKSMITHING
			headerResearches = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipTitleWide"))	
			indexStart = 1
			indexFinish = 7
		elseif index == 2 then
			craftingType = CRAFTING_TYPE_BLACKSMITHING
			intType = ARMORTYPE_HEAVY
			indexStart = 8
			indexFinish = 14
		elseif index == 3 then
			craftingType = CRAFTING_TYPE_CLOTHIER
			iconCraftingType = zo_iconFormat(ICON_CLOTHIER, 32, 32).." "
			intType = ARMORTYPE_LIGHT
			headerResearches = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipTitleWide"))	
			indexStart = 1
			indexFinish = 7	
		elseif index == 4 then
			craftingType = CRAFTING_TYPE_CLOTHIER
			intType = ARMORTYPE_MEDIUM
			indexStart = 8	
			indexFinish = 14
		elseif index == 5 then
			craftingType = CRAFTING_TYPE_WOODWORKING
			iconCraftingType = zo_iconFormat(ICON_WOODWORKING, 32, 32).." "
			intType = KELA_WEAPONTYPE_BOW
			headerResearches = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipTitleWide"))
			indexStart = 1
			indexFinish = 5		
		elseif index == 6 then
			craftingType = CRAFTING_TYPE_WOODWORKING
			intType = WEAPONTYPE_SHIELD
			indexStart = 6
			indexFinish = 6		
		elseif index == 7 then
			craftingType = CRAFTING_TYPE_JEWELRYCRAFTING
			iconCraftingType = zo_iconFormat(ICON_JEWELRYCRAFTING, 32, 32).." "
			intType = JEWELRYTYPE_RING_NECK
			headerResearches = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipTitleWide"))	
			indexStart = 1	
			indexFinish = 2	
		end
		
		for researchLineIndex = indexStart, indexFinish do
			local tname, _, numTraits = GetSmithingResearchLineInfo(craftingType, researchLineIndex)
			countTraits = countTraits + numTraits
			for t=1, numTraits do
				local traitType, _, known = GetSmithingResearchLineTraitInfo(craftingType, researchLineIndex, t)
				local dur, remaining = GetSmithingResearchLineTraitTimes(craftingType, researchLineIndex, t)
				if known then
					countKnown = countKnown + 1
				end	
			end
		end	
		
		local color
		if countKnown/countTraits > 2/3 then
			color = colors.COLOR_NEARLY
		elseif countKnown/countTraits > 1/2 then
			color = colors.COLOR_SOON 
		elseif countKnown/countTraits > 1/3 then
			color = colors.COLOR_NOTSOON
		else 
			color = colors.COLOR_RED
		end
		
		if headerResearches then
			headerResearches:AddLine(iconCraftingType..colors.COLOR_POISON:Colorize(string.upper(getCraftingType (craftingType, false, false))), {customSpacing = 30, fontFace = "$(GAMEPAD_MEDIUM_FONT)"})
			tooltipInfo:AddSection(headerResearches)
		end
		
		headerResearchLines = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipTitleWide"))
		headerResearchLines:AddLine(string.upper(GetString("KELA_RESEARCH_TYPE", index)).." - "..color:Colorize(countKnown.."/"..countTraits), {fontSize = KELA_TOOLTIPS_FONT_MEDIUM, customSpacing = 10})
		tooltipInfo:AddSection(headerResearchLines)
		
		local tableResearchableItems = KELA_RESEARCH:GetTableResearchableItems(craftingType)
		for k,v in pairs(tableResearchableItems) do
			for k1,v1 in pairs(v) do
				if k1 == intType or k1 == WEAPONTYPE_STAFF then 
					strInfoAvailable = GetString(KELA_RESEARCHINGSCENE_AVAILABLE)
					local countLines = 1
					for k2,v2 in pairs(v1) do
						local separateLines = ", "
						if countLines == 1 then separateLines = "" end
						countLines = countLines + 1					
						strInfoAvailable = strInfoAvailable..separateLines..GetSmithingResearchLineInfo(k, k2).." ("
						
						local countLinesTraits = 1
						for k3,v3 in pairs(v2) do
							local separateTraits = ", "
							if countLinesTraits == 1 then separateTraits = "" end
							countLinesTraits = countLinesTraits + 1
							strInfoAvailable = strInfoAvailable..separateTraits..colors.COLOR_WHITE:Colorize(GetString("SI_ITEMTRAITTYPE", k3))
						end
						
						strInfoAvailable = strInfoAvailable..")"
					end
				end
				
			end
		end

		if strInfoAvailable then 
			infoAvailable = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDescWide"))
			infoAvailable:AddLine(strInfoAvailable, {customSpacing = 5})
			tooltipInfo:AddSection(infoAvailable)	
		end

	end

	for index = 1, 7 do
		fillTooltip(index)
	end
	
end

function kelaAddMoreInfo(control, craftingType, itemCraftType, researchLineIndex, researchLineName, traitType, itemLink, name, knowledge, icon)
		
	local stackCount = 0
	local bagCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
	stackCount = bagCount + bankCount + craftBagCount
	
	local kelaPadSection = control:AcquireSection(control:GetStyle("headerTooltipInfo")) 
	kelaPadSection:AddLine(" ")			
	control:AddSection(kelaPadSection)
	
	local kelaTitleSection = control:AcquireSection(control:GetStyle("InfoTooltipDesc"))
	local kelaTitleStatValue = control:AcquireStatValuePair(control:GetStyle("InfoTooltipStatValuePair"))
	kelaTitleStatValue:SetStat(tostring(itemLink), control:GetStyle("InfoTooltipStatValuePairStatHeaderMedium"), {customSpacing=30})
	kelaTitleStatValue:SetValue(zo_iconFormat(icon, 40, 40), control:GetStyle("InfoTooltipStatValuePairValueHeader"))
	kelaTitleSection:AddStatValuePair(kelaTitleStatValue)
	control:AddSection(kelaTitleSection)		

	local kelaTraitNameSection = control:AcquireSection(control:GetStyle("headerTooltipInfo")) 
	kelaTraitNameSection:AddLine(GetString(KELA_STAT_GAMEPAD_RESEARCH_TRAIT_MATERIAL), {horizontalAlignment = TEXT_ALIGN_LEFT, fontSize = KELA_TOOLTIPS_FONT_SMALL})			
	control:AddSection(kelaTraitNameSection)
	
	local kelaTraitStockSection = control:AcquireSection(control:GetStyle("headerTooltipInfo")) 
	kelaTraitStockSection:AddLine(GetString(KELA_STAT_GAMEPAD_RESEARCH_TRAIT_MATERIAL_IN_STOCK).." - "..colors.COLOR_WHITE:Colorize(stackCount), {horizontalAlignment = TEXT_ALIGN_LEFT, childSpacing = 15, fontSize = KELA_TOOLTIPS_FONT_SMALL})			
	control:AddSection(kelaTraitStockSection)

	local kelaPadSection1 = control:AcquireSection(control:GetStyle("headerTooltipInfo")) 
	kelaPadSection1:AddLine(" ")			
	control:AddSection(kelaPadSection1)

	local kelaresearchLineNameSection = control:AcquireSection(control:GetStyle("headerTooltipInfo")) 
	kelaresearchLineNameSection:AddLine(colors.COLOR_WHITE:Colorize(tostring(researchLineName)), {horizontalAlignment = TEXT_ALIGN_LEFT, fontFace = "$(GAMEPAD_MEDIUM_FONT)"})			
	control:AddSection(kelaresearchLineNameSection)

	local stringResearch = ""
	
	if knowledge == 0 then
		stringResearch = colors.COLOR_NEARLY:Colorize(GetString(KELA_RESEARCHINGTOOLTIP_RESEARCHED))
	elseif knowledge == 1 then
		stringResearch = colors.COLOR_ORANGE:Colorize(GetString(KELA_RESEARCHINGTOOLTIP_AVAILABLE_NOT))
	elseif knowledge == 2 then
		stringResearch = colors.COLOR_NOTSOON:Colorize(GetString(KELA_RESEARCHINGTOOLTIP_INPROGRESS))
	elseif knowledge == 3 then
		stringResearch = colors.COLOR_SOON:Colorize(GetString(KELA_RESEARCHINGTOOLTIP_AVAILABLE))
	end

	local kelaTraitResearchSection = control:AcquireSection(control:GetStyle("headerTooltipInfo")) 
	kelaTraitResearchSection:AddLine(stringResearch, {horizontalAlignment = TEXT_ALIGN_LEFT, fontFace = "$(GAMEPAD_MEDIUM_FONT)"})			
	control:AddSection(kelaTraitResearchSection)
	
	if knowledge == 3 then
		
		local tableResearchableItems = KELA_RESEARCH:GetTableResearchableItems(craftingType)
		-- KelaPostMsg("craftingType "..tostring(craftingType))
		for k,v in pairs(tableResearchableItems) do
	-- KelaPostMsg ("k - "..tostring(k)..", v - "..tostring(v))
			
			
			
			for k1,v1 in pairs(v) do
	-- KelaPostMsg ("k1 - "..tostring(k1)..", v1 - "..tostring(v1))
	
				-- KelaPostMsg(tostring(itemCraftType))
	
				if itemCraftType == k1 then

					for k2,v2 in pairs(v1) do
		-- KelaPostMsg ("k2 - "..tostring(k2)..", v2 - "..tostring(v2))
						
						if researchLineIndex == k2 then 		
							for k3,v3 in pairs(v2) do
			-- KelaPostMsg ("k3 - "..tostring(k3)..", v3 - "..tostring(v3))
								if traitType == k3 then 

									for k4,v4 in pairs(v3) do
				-- KelaPostMsg ("k4 - "..tostring(k4)..", v4 - "..tostring(v4))
										local iconBag, _, iconLocked = KelaGetBagInfo(v4, 24)
										local statItemTypeSection = control:AcquireSection(control:GetStyle("InfoTooltipDesc"), {customSpacing = 0, childSpacing = 0})
										local statItemType = control:AcquireStatValuePair(control:GetStyle("InfoTooltipStatValuePair"), {customSpacing = 0, childSpacing = 0})
										statItemType:SetStat(tostring(v4), control:GetStyle("InfoTooltipStatValuePairStatLowercase"))
										statItemType:SetValue(iconLocked.." "..iconBag, control:GetStyle("InfoTooltipStatValuePairValue"))
										statItemTypeSection:AddStatValuePair(statItemType)
										control:AddSection(statItemTypeSection)
									end
								end
							end
						end
					end
				end
			end
		end
	end

end

function kelaAddInfoTooltipResearchStation(craftingType, researchLineIndex, itemCraftType)

	GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
	GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP, false)
	SCENE_MANAGER:AddFragment(GAMEPAD_TOOLTIPS:GetTooltipFragment(GAMEPAD_LEFT_TOOLTIP))
	SCENE_MANAGER:AddFragment(GAMEPAD_TOOLTIPS:GetTooltipBgFragment(GAMEPAD_LEFT_TOOLTIP))	
	local tooltipInfo = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)	
	
	-- крафтовые исследования
	local stringTrait1 = ""
	local stringResearch1 = ""
	local styleColor1
	local stringTrait2 = ""
	local stringResearch2 = ""
	local styleColor2
	local stringTrait3 = ""
	local stringResearch3 = ""
	local styleColor3
	local numCurrentlyResearching = 0
	local maxResearchable
	local countBank, countBackpack, countWorn
	local availableTraitText
	-- local researchColor, traitText 

	for index=1, GetNumSmithingResearchLines(craftingType) do
		local name, icon, numTraits = GetSmithingResearchLineInfo(craftingType, index)
		for t=1, numTraits do
			local itraitType, _, known = GetSmithingResearchLineTraitInfo(craftingType, index, t)
			local dur, remaining = GetSmithingResearchLineTraitTimes(craftingType, index, t)
			if dur and remaining then
				local styleColor
				if remaining < ZO_ONE_DAY_IN_SECONDS then
					styleColor = colors.COLOR_NEARLY
				elseif remaining >= ZO_ONE_DAY_IN_SECONDS and remaining < 5 * ZO_ONE_DAY_IN_SECONDS then
					styleColor = colors.COLOR_SOON
				else
					styleColor = colors.COLOR_NOTSOON
				end
				numCurrentlyResearching = numCurrentlyResearching + 1
				completeDate, completeTime = getDateTime(remaining, "seconds")
				if stringTrait1 == "" then
					styleColor1 = styleColor
					stringTrait1 = colors.COLOR_WHITE:Colorize(string.upper(GetString("SI_ITEMTRAITTYPE", itraitType))).." ("..string.lower(name)..")"
					stringResearch1 = completeTime.." "..completeDate
				elseif stringTrait2 == "" then 
					styleColor2 = styleColor
					stringTrait2 = colors.COLOR_WHITE:Colorize(string.upper(GetString("SI_ITEMTRAITTYPE", itraitType))).." ("..string.lower(name)..")"
					stringResearch2 = completeTime.." "..completeDate
				elseif stringTrait3 == "" then
					styleColor3 = styleColor
					stringTrait3 = colors.COLOR_WHITE:Colorize(string.upper(GetString("SI_ITEMTRAITTYPE", itraitType))).." ("..string.lower(name)..")"
					stringResearch3 = completeTime.." "..completeDate
				end
			end
		end
	end

	maxResearchable = GetMaxSimultaneousSmithingResearch(craftingType)
	
	local headerTraitResearchText = ""
	
	local headerTraitResearch = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))

	local statTraitResearch = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
	statTraitResearch:SetStat(headerTraitResearchText, tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
	statTraitResearch:SetValue(kelaAvailableTraitsIcons, tooltipInfo:GetStyle("InfoTooltipStatValuePairValue"))
	headerTraitResearch:AddStatValuePair(statTraitResearch)
	tooltipInfo:AddSection(headerTraitResearch)
	
	
	local kelaPadSection2 = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("headerTooltipInfo")) 
	kelaPadSection2:AddLine(" ")			
	tooltipInfo:AddSection(kelaPadSection2)	
	
	
	local statSectionTraitResearch = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
	if stringTrait1 ~= "" then
		local statTraitResearch1 = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
		statTraitResearch1:SetStat(stringTrait1, tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
		statTraitResearch1:SetValue(styleColor1:Colorize(stringResearch1), tooltipInfo:GetStyle("InfoTooltipStatValuePairValue"))
		statSectionTraitResearch:AddStatValuePair(statTraitResearch1)
	end
	if stringTrait2 ~= "" then 
		local statTraitResearch2 = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
		statTraitResearch2:SetStat(stringTrait2, tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
		statTraitResearch2:SetValue(styleColor2:Colorize(stringResearch2), tooltipInfo:GetStyle("InfoTooltipStatValuePairValue"))
		statSectionTraitResearch:AddStatValuePair(statTraitResearch2)
	end
	if stringTrait3 ~= "" then
		local statTraitResearch3 = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
		statTraitResearch3:SetStat(stringTrait3, tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
		statTraitResearch3:SetValue(styleColor3:Colorize(stringResearch3), tooltipInfo:GetStyle("InfoTooltipStatValuePairValue"))
		statSectionTraitResearch:AddStatValuePair(statTraitResearch3)
	end
	tooltipInfo:AddSection(statSectionTraitResearch)
	
	local kelaPadSection1 = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("headerTooltipInfo")) 
	kelaPadSection1:AddLine(" ")			
	tooltipInfo:AddSection(kelaPadSection1)

	local kelaTraitResearchSection
	
	local tableResearchableItems = KELA_RESEARCH:GetTableResearchableItems(craftingType)
	for k,v in pairs(tableResearchableItems) do
		for k1,v1 in pairs(v) do
			if itemCraftType == k1 then
				for k2,v2 in pairs(v1) do
					if researchLineIndex == k2 then 
					
						kelaTraitResearchSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("headerTooltipInfo")) 
						kelaTraitResearchSection:AddLine(colors.COLOR_SOON:Colorize(GetString(KELA_RESEARCHINGSCENE_AVAILABLE)), {horizontalAlignment = TEXT_ALIGN_LEFT, fontFace = "$(GAMEPAD_MEDIUM_FONT)"})			
						tooltipInfo:AddSection(kelaTraitResearchSection)
	
						for k3,v3 in pairs(v2) do
							local headerTraitType = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
							headerTraitType:AddLine("  "..colors.COLOR_WHITE:Colorize(GetString("SI_ITEMTRAITTYPE", k3)), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatHeader"))
							tooltipInfo:AddSection(headerTraitType)	
							for k4,v4 in pairs(v3) do
								local iconBag, _, iconLocked = KelaGetBagInfo(v4, 24)
								local statItemTypeSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"), {customSpacing = 0, childSpacing = 0})
								local statItemType = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"), {customSpacing = 0, childSpacing = 0})
								statItemType:SetStat("    "..tostring(v4), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
								statItemType:SetValue(iconLocked.." "..iconBag, tooltipInfo:GetStyle("InfoTooltipStatValuePairValue"))
								statItemTypeSection:AddStatValuePair(statItemType)
								tooltipInfo:AddSection(statItemTypeSection)
							end
						end
					
					else

					
					end
				end
			end
		end
	end
	
	if not kelaTraitResearchSection then 
		kelaTraitResearchSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("headerTooltipInfo")) 
		kelaTraitResearchSection:AddLine(colors.COLOR_ORANGE:Colorize(GetString(KELA_RESEARCHINGSCENE_AVAILABLE_NOT)), {horizontalAlignment = TEXT_ALIGN_LEFT, fontFace = "$(GAMEPAD_MEDIUM_FONT)"})			
		tooltipInfo:AddSection(kelaTraitResearchSection)
	end
	
end

function Kela_Research:InitializeResearchModul()
	



	KELA_RESEARCH:InitializeResearchCharacterData()
	KELA_RESEARCH:InitializeResearchPanel()
	KELA_RESEARCH:InitializeResearchableItems()
	KELA_RESEARCH:InitializeTraitItems()
	KELA_RESEARCH:InitializeDialogs()

	-- обрабатываем получение и потерю предметов
	local OldZO_SharedInventoryManagerHandleSlotCreationOrUpdate = ZO_SharedInventoryManager.HandleSlotCreationOrUpdate
	ZO_SharedInventoryManager.HandleSlotCreationOrUpdate = function(control, bagCache, bagId, slotIndex, isNewItem) 
		local SHARED_INVENTORY_SLOT_RESULT_REMOVED = 1
		local SHARED_INVENTORY_SLOT_RESULT_ADDED = 2
		local SHARED_INVENTORY_SLOT_RESULT_UPDATED = 3
		local SHARED_INVENTORY_SLOT_RESULT_NO_CHANGE = 4
		local SHARED_INVENTORY_SLOT_RESULT_REMOVE_AND_ADD = 5		
		local existingSlotData = bagCache[slotIndex]
		local slotData, result = control:CreateOrUpdateSlotData(existingSlotData, bagId, slotIndex, isNewItem)
		if result == SHARED_INVENTORY_SLOT_RESULT_REMOVED then
			KELA_RESEARCH:RemoveResearchableItem(existingSlotData.uniqueId, existingSlotData.name)
		elseif result == SHARED_INVENTORY_SLOT_RESULT_ADDED then
			local itemLink = GetItemLink(slotData.bagId, slotData.slotIndex)
			if KELA_RESEARCH:GetItemLinkResearchStatus(itemLink) == TRAIT_RESEARCHABLE then
				KELA_RESEARCH:AddResearchableItem(slotData.bagId, slotData.slotIndex)
			end
		elseif result == SHARED_INVENTORY_SLOT_RESULT_UPDATED then
		elseif result == SHARED_INVENTORY_SLOT_RESULT_REMOVE_AND_ADD then
			KELA_RESEARCH:RemoveResearchableItem(existingSlotData.uniqueId, existingSlotData.name)
			KELA_RESEARCH:AddResearchableItem(slotData.bagId, slotData.slotIndex)			
		end
		local ret = OldZO_SharedInventoryManagerHandleSlotCreationOrUpdate(control, bagCache, bagId, slotIndex, isNewItem) 	
		--return ret	
	end

	-- собираем строку иконок доступных исследований
	local gamepad_smithing_research_Scene = SCENE_MANAGER.scenes.gamepad_smithing_research
	gamepad_smithing_research_Scene:RegisterCallback("StateChange", function(oldState, newState) 
		-- states: hiding, showing, shown, hidden
		

		if(newState == "shown") then


			
		elseif(newState == "showing") then
			local craftingType = GetCraftingInteractionType()
			kelaSetAvailableTraitsIcons(craftingType)
		elseif(newState == "hiding") then
		
			kelaAvailableTraitsIcons = ""
		
		elseif(newState == "hidden") then
		end
	end) 	



	-- перемещение по спискам на станции
	local OldZO_GamepadSmithingResearchRefreshFocusItems = ZO_GamepadSmithingResearch.RefreshFocusItems
	ZO_GamepadSmithingResearch.RefreshFocusItems = function(selfcontrol, focusIndex, ...)
		local function AddEntry(control, highlight, activate, deactivate)
			selfcontrol.focus:AddEntry(
			{
				control = control,
				highlight = highlight,
				activate = activate,
				deactivate = deactivate,
			})
		end

		local ACTIVE = true

		local function UpdateBorderHighlight(focusedControl, active)
			focusedControl.inactiveBG:SetHidden(active)
			focusedControl.activeBG:SetHidden(not active)
		end

		local function ListActivate(control, data)
			control:Activate()
			UpdateBorderHighlight(control:GetControl():GetParent(), ACTIVE)
			
			-- KelaPostMsg("selfcontrol.craftingType "..tostring(selfcontrol.craftingType))
			if kelaAvailableTraitsIcons == "" then 
				local craftingType = GetCraftingInteractionType()
				kelaSetAvailableTraitsIcons(craftingType)
			end
			
			local itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[selfcontrol.craftingType][selfcontrol.researchLineIndex]
			
			kelaAddInfoTooltipResearchStation(selfcontrol.craftingType, selfcontrol.researchLineIndex, itemCraftType)
		end

		local function ListDeactivate(control, data)
			control:Deactivate()
			UpdateBorderHighlight(control:GetControl():GetParent(), not ACTIVE)
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
			SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(KPUI_GAMEPAD_RIGHT_TOOLTIP))
		end

		AddEntry(selfcontrol.researchLineList, selfcontrol.control:GetNamedChild("ResearchLineList").focusTexture, ListActivate, ListDeactivate)

		local function Activate(control)
			selfcontrol:OnResearchRowActivate(control)
		end

		local function Deactivate(control)
			selfcontrol:OnResearchRowDeactivate(control)
		end

		local entries = selfcontrol.slotPool:GetActiveObjects()
		for _, v in pairs(entries) do
			AddEntry(v, v:GetNamedChild("Highlight"), Activate, Deactivate)
		end

		if focusIndex then
			selfcontrol.focus:SetFocusByIndex(focusIndex)
		else
			selfcontrol.focus:SetFocusByIndex(1)
		end

		-- local ret = OldZO_GamepadSmithingResearchRefreshFocusItems(control, focusIndex, ...)
		-- return ret	

	end

	-- hook trait list on crafting station for add icons blocked or worned items
	local OldZO_GamepadSmithingResearchSetupTraitDisplay = ZO_GamepadSmithingResearch.SetupTraitDisplay
	ZO_GamepadSmithingResearch.SetupTraitDisplay = function(control, slotControl, researchLine, known, duration, traitIndex, ...)
		
		local tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree
		if not known and not duration then
			if slotControl.craftingType then
				local itemCraftType
				if slotControl.researchLineIndex then 
					itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[slotControl.craftingType][slotControl.researchLineIndex] 
					tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree = KELA_RESEARCH:GetTableResearchableItemsByTrait(slotControl.craftingType, itemCraftType, slotControl.researchLineIndex, slotControl.traitType)
				end
			end			
		end		
		
		local iconControl = GetControl(slotControl, "Icon")
		
		if known then
			slotControl.nameLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
			slotControl.statusLabel:SetText("")
			slotControl.timerIcon:SetHidden(true)
			iconControl:SetDesaturation(0)
			iconControl:SetAlpha(1)
		elseif duration then
			slotControl.nameLabel:SetColor(ZO_SECOND_CONTRAST_TEXT:UnpackRGBA())
			slotControl.statusLabel:SetText(GetString(SI_SMITHING_RESEARCH_IN_PROGRESS))
			slotControl.statusLabel:SetColor(ZO_SECOND_CONTRAST_TEXT:UnpackRGBA())
			slotControl.timerIcon:SetHidden(false)
			slotControl.timerIcon:SetColor(ZO_SECOND_CONTRAST_TEXT:UnpackRGBA())
			iconControl:SetDesaturation(0)
			iconControl:SetAlpha(.3)
		elseif researchLine.itemTraitCounts and researchLine.itemTraitCounts[traitIndex] then
			slotControl.nameLabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
			if tblResearchableItemsFree and (tblResearchableItemsWorned or tblResearchableItemsLocked) then
				slotControl.statusLabel:SetText(colors.COLOR_WHITE:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_AVAIL))..colors.COLOR_ORANGE:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_ABLE)))
			elseif tblResearchableItemsFree then
				slotControl.statusLabel:SetText(GetString(SI_SMITHING_RESEARCH_RESEARCHABLE))
			else
				slotControl.statusLabel:SetText(colors.COLOR_ORANGE:Colorize(GetString(SI_SMITHING_RESEARCH_RESEARCHABLE)))
			end
			slotControl.statusLabel:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
			slotControl.timerIcon:SetHidden(true)
			iconControl:SetDesaturation(0)
			iconControl:SetAlpha(1)
			slotControl.researchable = true
		else
			slotControl.nameLabel:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
			slotControl.statusLabel:SetText(GetString(SI_SMITHING_RESEARCH_UNKNOWN))
			slotControl.statusLabel:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
			slotControl.timerIcon:SetHidden(true)
			iconControl:SetDesaturation(1)
			iconControl:SetAlpha(1)
			slotControl.researchable = false			
		end
		-- local ret = OldZO_GamepadSmithingResearchSetupTraitDisplay(control, slotControl, researchLine, known, duration, traitIndex, ...)
		-- return ret					
	end	
	
	-- hook trait tooltip on crafting station for adding available items info
	local OldZO_GamepadSmithingResearchSetupTooltip = ZO_GamepadSmithingResearch.SetupTooltip
	ZO_GamepadSmithingResearch.SetupTooltip = function(control, row, ...) 
		--KelaPostMsg ("ZO_GamepadSmithingResearch.SetupTooltip")
		GAMEPAD_TOOLTIPS:LayoutResearchSmithingItem(GAMEPAD_LEFT_TOOLTIP, GetString("SI_ITEMTRAITTYPE", row.traitType), row.traitDescription, row.traitResearchSourceDescription, row.traitMaterialSourceDescription)
		local traitResearchStatus = KELA_RESEARCH:GetTraitTypeResearchStatus(row.traitType, control.craftingType, control.researchLineIndex)
		if traitResearchStatus == 0 then
			-- local tableResearchableItems = KELA_RESEARCH:GetTableResearchableItems(control.craftingType)
			if control.craftingType then
				local itemCraftType
				if control.researchLineIndex then 
					itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[control.craftingType][control.researchLineIndex] 
					local tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree = KELA_RESEARCH:GetTableResearchableItemsByTrait(control.craftingType, itemCraftType, control.researchLineIndex, row.traitType)
					if tblResearchableItemsWorned then
						local tooltipInfo = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)	
						local headerItemsAvailabled = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
						headerItemsAvailabled:AddLine(colors.COLOR_RED:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_WORNED)), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatHeader"), {customSpacing = 15})
						tooltipInfo:AddSection(headerItemsAvailabled)	
						for k1,v1 in pairs(tblResearchableItemsWorned[control.craftingType][itemCraftType][control.researchLineIndex][row.traitType]) do
							local iconBag, _, iconLocked = KelaGetBagInfo(v1, 24)
							local statItemTypeSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
							local statItemType = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
							statItemType:SetStat(tostring(v1), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
							statItemType:SetValue(iconLocked.." "..iconBag, tooltipInfo:GetStyle("InfoTooltipStatValuePairValue")) 
							statItemTypeSection:AddStatValuePair(statItemType)
							tooltipInfo:AddSection(statItemTypeSection)							
						end		
					end	
					if tblResearchableItemsLocked then
						local tooltipInfo = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)	
						local headerItemsAvailabled = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
						headerItemsAvailabled:AddLine(colors.COLOR_ORANGE:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_LOCKED)), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatHeader"), {customSpacing = 15})
						tooltipInfo:AddSection(headerItemsAvailabled)	
						for k1,v1 in pairs(tblResearchableItemsLocked[control.craftingType][itemCraftType][control.researchLineIndex][row.traitType]) do
							local iconBag, _, iconLocked = KelaGetBagInfo(v1, 24)
							local statItemTypeSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
							local statItemType = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
							statItemType:SetStat(tostring(v1), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
							statItemType:SetValue(iconLocked.." "..iconBag, tooltipInfo:GetStyle("InfoTooltipStatValuePairValue")) 
							statItemTypeSection:AddStatValuePair(statItemType)
							tooltipInfo:AddSection(statItemTypeSection)							
						end		
					end	
					if tblResearchableItemsFree then
						local tooltipInfo = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)	
						local headerItemsAvailabled = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
						headerItemsAvailabled:AddLine(colors.COLOR_WHITE:Colorize(GetString(KELA_TOOLTIP_CRAFTING_STATION_FREE)), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatHeader"), {customSpacing = 15})
						tooltipInfo:AddSection(headerItemsAvailabled)	
						for k1,v1 in pairs(tblResearchableItemsFree[control.craftingType][itemCraftType][control.researchLineIndex][row.traitType]) do
							local iconBag, _, iconLocked = KelaGetBagInfo(v1, 24)
							local statItemTypeSection = tooltipInfo:AcquireSection(tooltipInfo:GetStyle("InfoTooltipDesc"))
							local statItemType = tooltipInfo:AcquireStatValuePair(tooltipInfo:GetStyle("InfoTooltipStatValuePair"))
							statItemType:SetStat(tostring(v1), tooltipInfo:GetStyle("InfoTooltipStatValuePairStatLowercase"))
							statItemType:SetValue(iconLocked.." "..iconBag, tooltipInfo:GetStyle("InfoTooltipStatValuePairValue")) 
							statItemTypeSection:AddStatValuePair(statItemType)
							tooltipInfo:AddSection(statItemTypeSection)							
						end		
					end						
				end
			end
		end
	-- local ret = OldZO_GamepadSmithingResearchSetupTooltip(control, row, ...)
	-- return ret					
	end

	-- диалог отмены исследования
	local OldZO_GamepadSmithingResearchInitializeConfirmDestroyDialog = ZO_GamepadSmithingResearch.InitializeConfirmDestroyDialog
	ZO_GamepadSmithingResearch.InitializeConfirmDestroyDialog = function(control, ...) 
		local function ReleaseDialog()
			ZO_Dialogs_ReleaseDialogOnButtonPress(ZO_GAMEPAD_CONFIRM_CANCEL_RESEARCH_DIALOG)
		end

		ZO_Dialogs_RegisterCustomDialog(ZO_GAMEPAD_CONFIRM_CANCEL_RESEARCH_DIALOG,
		{
			blockDialogReleaseOnPress = true,
			canQueue = true,

			gamepadInfo = 
			{
				dialogType = GAMEPAD_DIALOGS.BASIC,
				allowRightStickPassThrough = true,
			},

			setup = function(dialog)
				control.destroyConfirmText = nil
				dialog:setupFunc()
			end,

			title =
			{
				text = SI_CRAFTING_CONFIRM_CANCEL_RESEARCH_TITLE,
			},

			mainText = 
			{
				text = SI_GAMEPAD_CRAFTING_CONFIRM_CANCEL_RESEARCH_DESCRIPTION,
			},
		  
			buttons =
			{
				{
					onShowCooldown = 2000,
					keybind = "DIALOG_PRIMARY",
					text = GetString(SI_YES),
					callback = function(dialog)
						-- KelaPostMsg("ZO_GAMEPAD_CONFIRM_CANCEL_RESEARCH_DIALOG")
						local data = dialog.data
						CancelSmithingTraitResearch(data.craftingType, data.researchLineIndex, data.traitIndex)
						KelaPadUI_OnResearchCanseled(EVENT_SMITHING_TRAIT_RESEARCH_CANCELED, data.craftingType, data.researchLineIndex, data.traitIndex)
						ReleaseDialog()
					end,
				},
				{
					keybind = "DIALOG_NEGATIVE",
					text = GetString(SI_NO),
					callback = function()
						ReleaseDialog()
					end,
				},
			}
		})
		
		-- local ret = OldZO_GamepadSmithingResearchInitializeConfirmDestroyDialog(control, ...) 	
		-- return ret	
	end

	-- настройка диалогового окна для заблокированного предмета
	local OldZO_GamepadSmithingResearchInitializeKeybindStripDescriptors = ZO_GamepadSmithingResearch.InitializeKeybindStripDescriptors
	ZO_GamepadSmithingResearch.InitializeKeybindStripDescriptors = function(control, ...) 
		control.keybindStripDescriptor =
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			-- Perform research
			{
				keybind = "UI_SHORTCUT_PRIMARY",
				name = function()
					return GetString(SI_ITEM_ACTION_RESEARCH)
				end,
				callback = function()
					control:Research()
				end,
				enabled = function()
					if not ZO_CraftingUtils_IsPerformingCraftProcess() then
						return control:IsResearchable()
					end
				end
			},
			-- Cancel research
			{
				keybind = "UI_SHORTCUT_SECONDARY",
				name = function()
					return GetString(SI_CRAFTING_CANCEL_RESEARCH)
				end,
				callback = function()
					control:CancelResearch()
				end,
				visible = function()
					if not ZO_CraftingUtils_IsPerformingCraftProcess() then
						return control:CanCancelResearch()
					end
				end
			},
		}
		
		ZO_Gamepad_AddBackNavigationKeybindDescriptors(control.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
		ZO_CraftingUtils_ConnectKeybindButtonGroupToCraftingProcess(control.keybindStripDescriptor)
		
		local function ConfirmResearch()
			local targetData = control.confirmList:GetTargetData()
			if targetData then
				local bagId = targetData.bagId
				local slotIndex = targetData.slotIndex
				local _, _, _, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(control.confirmCraftingType, control.confirmResearchLineIndex)
				local formattedTime = ZO_FormatTime(timeRequiredForNextResearchSecs, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
				if IsItemPlayerLocked(bagId, slotIndex)	and GetItemTraitInformation(bagId, slotIndex) ~= ITEM_TRAIT_INFORMATION_RETRAITED then
					ZO_Dialogs_ShowGamepadDialog("KPUI_GAMEPAD_CONFIRM_RESEARCH_BLOCKED_ITEM", { bagId = targetData.bagId, slotIndex = targetData.slotIndex, owner = control }, { mainTextParams = { formattedTime }})
				else
					ZO_Dialogs_ShowGamepadDialog("GAMEPAD_CONFIRM_RESEARCH_ITEM", { bagId = targetData.bagId, slotIndex = targetData.slotIndex, owner = control }, { mainTextParams = { formattedTime }})
				end
			end
		end
		
		-- Confirm research keybind descriptor.
		control.confirmKeybindStripDescriptor =
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			{
				keybind = "UI_SHORTCUT_PRIMARY",
				name = GetString(SI_SMITHING_RESEARCH_DIALOG_CONFIRM),
				callback = ConfirmResearch,
				sound = SOUNDS.SMITHING_START_RESEARCH,
			},
		}
		ZO_Gamepad_AddBackNavigationKeybindDescriptors(control.confirmKeybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON)
		-- local ret = OldZO_GamepadSmithingResearchInitializeKeybindStripDescriptors(control, ...) 	
		-- return ret	 		
	end

	-- add locked icon in confirm research list
	local OldZO_GamepadSmithingResearchInitializeConfirmList = ZO_GamepadSmithingResearch.InitializeConfirmList
	ZO_GamepadSmithingResearch.InitializeConfirmList = function(control, ...) 
		local CONFIRM_TEMPLATE_NAME = "ZO_GamepadSubMenuEntryTemplate"
		control.confirmList = ZO_GamepadVerticalItemParametricScrollList:New(control.panelContent:GetNamedChild("Confirm"):GetNamedChild("List"))
		control.confirmList:SetAlignToScreenCenter(true)
		control.confirmList:AddDataTemplate(CONFIRM_TEMPLATE_NAME, ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "Entry")

		-- add locked icon		
		local function kelaOnTargetDataChanged(list, selectedData)
			local numData = #list.dataList
			for i = 1, numData do
				local dataTypes = ZO_ScrollList_GetDataTypeTable(list, CONFIRM_TEMPLATE_NAME)
				-- KelaPostMsg("dataTypes  "..tostring(dataTypes))					
				if dataTypes then
					local original = dataTypes.setupFunction
					dataTypes.setupFunction = function(control, data, ...)
						original(control, data, ...)
						local c = control:GetNamedChild("kpuiEntryIconV")
						if c then
							c:SetHidden(true)
						end
						if c == nil then
							local label = control:GetNamedChild("Label")
							c = CreateControlFromVirtual("$(parent)kpuiEntryIconV", control, "kpuiEntryIcon")
							c:SetDimensions(32, 32)	
							local w = label:GetWidth()
							--label:SetWidth(w-40)
							c:ClearAnchors() 
							c:SetAnchor(RIGHT, label, LEFT, -71, 0) 
						end
						if c then 
							c:SetHidden(false)
							local tex_locked = c:GetNamedChild("Locked")
							tex_locked:SetHidden(true)
							if IsItemPlayerLocked(data.bagId, data.slotIndex) then
								tex_locked:SetHidden(false)
								tex_locked:SetColor(255, 255, 255)								
							else
								c:SetHidden(true)
							end
						end
					end
				end					
			end	
		end
		
		local function OnEntryChanged(list, selectedData)
			if selectedData then
				GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, selectedData.bagId, selectedData.slotIndex)
				if selectedData.isEquippedInCurrentCategory or selectedData.isEquippedInAnotherCategory then
					GAMEPAD_TOOLTIPS:SetStatusLabelText(GAMEPAD_LEFT_TOOLTIP, GetString(SI_GAMEPAD_EQUIPPED_ITEM_HEADER))
					control:UpdateTooltipEquippedIndicatorText(control.selectedEquippedIndicator, selectedData.slotIndex)
				else
					GAMEPAD_TOOLTIPS:ClearStatusLabel(GAMEPAD_LEFT_TOOLTIP)
				end
			else
				GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_LEFT_TOOLTIP)
			end
		end
		
		control.confirmList:SetOnTargetDataChangedCallback(kelaOnTargetDataChanged)		
		control.confirmList:SetOnSelectedDataChangedCallback(OnEntryChanged)

		ZO_Gamepad_AddListTriggerKeybindDescriptors(control.confirmKeybindStripDescriptor, control.confirmList)
		-- local ret = OldZO_GamepadSmithingResearchInitializeConfirmList(control, ...)  	
		-- return ret	 
	end

	-- разрешаем разбирать заблокированные предметы 
	local OldZO_SharedSmithingResearchIsResearchableItem = ZO_SharedSmithingResearch.IsResearchableItem
	ZO_SharedSmithingResearch.IsResearchableItem = function(bagId, slotIndex, craftingType, researchLineIndex, traitIndex) 
		return CanItemBeSmithingTraitResearched(bagId, slotIndex, craftingType, researchLineIndex, traitIndex) and GetItemTraitInformation(bagId, slotIndex) ~= ITEM_TRAIT_INFORMATION_RETRAITED
		-- local ret = OldZO_SharedSmithingResearchIsResearchableItem(bagId, slotIndex, craftingType, researchLineIndex, traitIndex) 	
		-- return ret	 
    end

	-- подсчитывает количество доступных для исследования особеностей в линии исследования
	local OldZO_SharedSmithingResearchGenerateResearchTraitCounts = ZO_SharedSmithingResearch.GenerateResearchTraitCounts
	ZO_SharedSmithingResearch.GenerateResearchTraitCounts = function(control, virtualInventoryList, craftingType, researchLineIndex, numTraits, ...) 
		local counts
		local tableTraitIndexes = KELA_RESEARCH:GetTableTraitIndexResearchableItems(craftingType, researchLineIndex)
		if tableTraitIndexes then 
			for k, v in pairs(tableTraitIndexes[craftingType][researchLineIndex]) do
				counts = counts or {}
				counts[k] = (counts[k] or 0) + 1
			end
		end
		return counts
		-- local ret = OldZO_GamepadInventoryRefreshItemList(control, ...) 	
		-- return ret	
	end

end


-- собираем таблицу всех предметов с особенностями в рюкзаках
function Kela_Research:InitializeTraitItems(OnAddonLoaded)

	kpuiSVCharData["traitItems"] = nil
	kpuiSVCharData["traitItems"]  = {}	

		for _,bagId in ipairs(kpuiConst.Bags["ALL_CRAFTING_INVENTORY_BACKPACK_AND_WORN"]) do
			for slotIndex = 0, GetBagSize(bagId) do
				local itemLink = GetItemLink(bagId, slotIndex)
				local traitType = GetItemLinkTraitInfo(itemLink)
				local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
				local equipType = GetItemLinkEquipType(itemLink)	
				if otherEquipType == equipType and not kpuiConst.UnknowableTraitTypes[traitType] then	
					local uniqueId = GetItemUniqueId(bagId, slotIndex)
					local name = GetItemLinkName(itemLink)
					local smithingType = KelaGetSmithingType(bagId, slotIndex)
					local craftItemType = KelaGetitemCraftType(itemLink)
					local researchLineIndex = KelaItemToResearchLineIndex(itemLink)
					KelaSetValueIfNil(kpuiSVCharData["traitItems"] , uniqueId, {})
					kpuiSVCharData["traitItems"] [uniqueId] = {
						["itemSmithingType"] = smithingType, 
						["itemCraftType"] = craftItemType, 
						["itemResearchLineIndex"] = researchLineIndex, 
						["itemTraitType"] = traitType,
						["itembagId"] = bagId,
						["itemSlotIndex"] = slotIndex,
						["itemItemLink"] = itemLink,
						["itemName"] = name,
						}
				end	
			end		
		end	
		
end	





-- собираем таблицу предметов, возможных к разбору и изучению 
function Kela_Research:InitializeResearchCharacterData()

	local characterData = 
	{
		["researches"] = {
			[CRAFTING_TYPE_BLACKSMITHING] = {},
			[CRAFTING_TYPE_WOODWORKING] = {},
			[CRAFTING_TYPE_CLOTHIER] = {},
			[CRAFTING_TYPE_JEWELRYCRAFTING] = {},
			},    
		["researchableItems"] = {},    
		["traitItems"] = {},    
	}

	kpuiSVCharData = ZO_SavedVars:NewCharacterIdSettings('kpuiSavedVariables', 1, nil, characterData)	

	for k,v in pairs(kpuiSVCharData["researches"]) do
		for i=1, GetNumSmithingResearchLines(k) do
			local _,_, numTraits = GetSmithingResearchLineInfo(k, i)
			for t=1, numTraits do
				local traitType, _, known = GetSmithingResearchLineTraitInfo(k, i, t)
				KelaSetValueIfNil(kpuiSVCharData["researches"][k], i, {})
				if known then
					kpuiSVCharData["researches"][k][i][traitType] = TRAIT_KNOWN
				else
					local dur, remainig = GetSmithingResearchLineTraitTimes(k, i, t)
					if dur and remainig then
						kpuiSVCharData["researches"][k][i][traitType] = TRAIT_RESEARCH_IN_PROGRESS
					else
						kpuiSVCharData["researches"][k][i][traitType] = TRAIT_RESEARCHABLE
					end
				end
			end
		end
	end
end




-- собираем таблицу предметов, возможных к разбору и изучению 
function Kela_Research:InitializeResearchableItems()

	kpuiSVCharData["researchableItems"] = nil
	kpuiSVCharData["researchableItems"] = {}	

		for _,bagId in ipairs(kpuiConst.Bags["ALL_CRAFTING_INVENTORY_BAGS_AND_WORN"]) do
			for slotIndex = 0, GetBagSize(bagId) do
				local itemLink = GetItemLink(bagId, slotIndex)
				if KELA_RESEARCH:GetItemLinkResearchStatus(itemLink) == TRAIT_RESEARCHABLE then
					local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
					local equipType = GetItemLinkEquipType(itemLink)	
					if otherEquipType == equipType then	
						local uniqueId = GetItemUniqueId(bagId, slotIndex)
						local name = GetItemLinkName(itemLink)
						local smithingType = KelaGetSmithingType(bagId, slotIndex)
						local craftItemType = KelaGetitemCraftType(itemLink)
						local researchLineIndex = KelaItemToResearchLineIndex(itemLink)
						local traitType = GetItemLinkTraitInfo(itemLink)
						KelaSetValueIfNil(kpuiSVCharData["researchableItems"], uniqueId, {})
						kpuiSVCharData["researchableItems"][uniqueId] = {
							["itemSmithingType"] = smithingType, 
							["itemCraftType"] = craftItemType, 
							["itemResearchLineIndex"] = researchLineIndex, 
							["itemTraitType"] = traitType,
							["itembagId"] = bagId,
							["itemSlotIndex"] = slotIndex,
							["itemItemLink"] = itemLink,
							["itemName"] = name,
							}
					end	
				end
			end		
		end	

end		

-- получаем ступенчатую таблицу
function Kela_Research:GetTableResearchableItems(smithingType)
	--KelaPostMsg ("KELA_RESEARCH:GetTableResearchableItems, smithingType - "..tostring(smithingType))
	local tblResearchableItems = {}
	for _, uniqueId in pairs(kpuiSVCharData["researchableItems"]) do
		--KelaPostMsg ("uniqueId - "..tostring(uniqueId)..", [uniqueId[itemSmithingType]] - "..tostring(uniqueId["itemSmithingType"]))
		if uniqueId["itemSmithingType"] == smithingType or smithingType == nil then
			KelaSetValueIfNil(tblResearchableItems, uniqueId["itemSmithingType"], {})
			KelaSetValueIfNil(tblResearchableItems[uniqueId["itemSmithingType"]], uniqueId["itemCraftType"], {})
			KelaSetValueIfNil(tblResearchableItems[uniqueId["itemSmithingType"]][uniqueId["itemCraftType"]], uniqueId["itemResearchLineIndex"], {})
			KelaSetValueIfNil(tblResearchableItems[uniqueId["itemSmithingType"]][uniqueId["itemCraftType"]][uniqueId["itemResearchLineIndex"]], uniqueId["itemTraitType"], {})
			table.insert(tblResearchableItems[uniqueId["itemSmithingType"]][uniqueId["itemCraftType"]][uniqueId["itemResearchLineIndex"]][uniqueId["itemTraitType"]], uniqueId["itemItemLink"])
		end
	end	
	return tblResearchableItems	
end

-- получаем ступенчатую таблицу с индексами особенностей
function Kela_Research:GetTableTraitIndexResearchableItems(smithingType, researchLineIndex)
	if smithingType and researchLineIndex then
		local tblTraitIndex = {}
		KelaSetValueIfNil(tblTraitIndex, smithingType, {})
		KelaSetValueIfNil(tblTraitIndex[smithingType], researchLineIndex, {})
		local count = 0
		for _, uniqueId in pairs(kpuiSVCharData["researchableItems"]) do
			if uniqueId["itemSmithingType"] == smithingType and uniqueId["itemResearchLineIndex"] == researchLineIndex then
				KelaSetValueIfNil(tblTraitIndex[smithingType][researchLineIndex], KelaItemToTraitIndex(uniqueId["itemTraitType"]), {})
				count = count + 1
			end
		end
		if count == 0 then tblTraitIndex = nil end
		return tblTraitIndex
	end
	return nil, nil, nil	
end

-- получаем ступенчатую таблицу по сумкам
function Kela_Research:GetTableResearchableItemsByTrait(smithingType, itemCraftType, researchLineIndex, traitType)
	--KelaPostMsg ("Kela_Research:GetTableResearchableItems, smithingType - "..tostring(smithingType))
	if smithingType and itemCraftType and researchLineIndex and traitType then
		local tblResearchableItemsWorned = {}
		KelaSetValueIfNil(tblResearchableItemsWorned, smithingType, {})
		KelaSetValueIfNil(tblResearchableItemsWorned[smithingType], itemCraftType, {})
		KelaSetValueIfNil(tblResearchableItemsWorned[smithingType][itemCraftType], researchLineIndex, {})
		KelaSetValueIfNil(tblResearchableItemsWorned[smithingType][itemCraftType][researchLineIndex], traitType, {})
		local tblResearchableItemsLocked = {}
		KelaSetValueIfNil(tblResearchableItemsLocked, smithingType, {})
		KelaSetValueIfNil(tblResearchableItemsLocked[smithingType], itemCraftType, {})
		KelaSetValueIfNil(tblResearchableItemsLocked[smithingType][itemCraftType], researchLineIndex, {})
		KelaSetValueIfNil(tblResearchableItemsLocked[smithingType][itemCraftType][researchLineIndex], traitType, {})
		local tblResearchableItemsFree = {}
		KelaSetValueIfNil(tblResearchableItemsFree, smithingType, {})
		KelaSetValueIfNil(tblResearchableItemsFree[smithingType], itemCraftType, {})
		KelaSetValueIfNil(tblResearchableItemsFree[smithingType][itemCraftType], researchLineIndex, {})
		KelaSetValueIfNil(tblResearchableItemsFree[smithingType][itemCraftType][researchLineIndex], traitType, {})
		local countWorned = 0
		local countLocked = 0
		local countFree = 0
		for _, uniqueId in pairs(kpuiSVCharData["researchableItems"]) do
			if uniqueId["itemSmithingType"] == smithingType and uniqueId["itemCraftType"] == itemCraftType and uniqueId["itemResearchLineIndex"] == researchLineIndex and uniqueId["itemTraitType"] == traitType then
				if uniqueId["itembagId"] == BAG_WORN then
					table.insert(tblResearchableItemsWorned[smithingType][itemCraftType][researchLineIndex][traitType], uniqueId["itemItemLink"])
					countWorned = countWorned + 1
				elseif IsItemPlayerLocked(uniqueId["itembagId"], uniqueId["itemSlotIndex"]) then
					table.insert(tblResearchableItemsLocked[smithingType][itemCraftType][researchLineIndex][traitType], uniqueId["itemItemLink"])
					countLocked = countLocked + 1
				else
					table.insert(tblResearchableItemsFree[smithingType][itemCraftType][researchLineIndex][traitType], uniqueId["itemItemLink"])
					countFree = countFree + 1
				end
			end
		end
		if countWorned == 0 then tblResearchableItemsWorned = nil end
		if countLocked == 0 then tblResearchableItemsLocked = nil end
		if countFree == 0 then tblResearchableItemsFree = nil end
		return tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree	
	end
	return nil, nil, nil	
end

-- обрабатываем добавление
function Kela_Research:AddResearchableItem(bagId, slotIndex)
	--KelaPostMsg ("AddResearchableItems - "..tostring(GetItemLink(bagId, slotIndex)))
	local itemLink = GetItemLink(bagId, slotIndex)
	local _,_,_,_,_, otherEquipType = GetItemInfo(bagId, slotIndex)
	local equipType = GetItemLinkEquipType(itemLink)	
	if otherEquipType == equipType then	
		local uniqueId = GetItemUniqueId(bagId, slotIndex)
		local name = GetItemLinkName(itemLink)
		local smithingType = KelaGetSmithingType(bagId, slotIndex)
		local craftItemType = KelaGetitemCraftType(itemLink)
		local researchLineIndex = KelaItemToResearchLineIndex(itemLink)
		local traitType = GetItemLinkTraitInfo(itemLink)
		KelaSetValueIfNil(kpuiSVCharData["researchableItems"], uniqueId, {})
		kpuiSVCharData["researchableItems"][uniqueId] = {
			["itemSmithingType"] = smithingType, 
			["itemCraftType"] = craftItemType, 
			["itemResearchLineIndex"] = researchLineIndex, 
			["itemTraitType"] = traitType,
			["itembagId"] = bagId,
			["itemSlotIndex"] = slotIndex,
			["itemItemLink"] = itemLink,
			["itemName"] = name,
			}
		-- KelaPostMsg ("Added - "..tostring(uniqueId).." - "..tostring(name))
	end	
end		

-- обрабатываем удаление
function Kela_Research:RemoveResearchableItem(uniqueId, name)
	for k,v in pairs(kpuiSVCharData["researchableItems"]) do
		if uniqueId == k then
			kpuiSVCharData["researchableItems"][uniqueId] = nil
			--KelaPostMsg ("Deleted - "..tostring(uniqueId).." - "..tostring(name))
			break
		end
	end
end	


-- -- тестовая, ищем трейты в сумках
-- function Kela_Research:InitializeTrackedSets()
	-- kpuiSV["ItemsInBackpack"] = nil
	-- kpuiSV["ItemsInBackpack"] = {}	
	-- for _,bagId in ipairs(kpuiConst.Bags["ALL_CRAFTING_INVENTORY_BAGS_AND_WORN"]) do
		-- for slotIndex = 0, GetBagSize(bagId) do
			-- local itemLink = GetItemLink(bagId, slotIndex)
			-- local uniqueId = GetItemUniqueId(bagId, slotIndex)
			-- local name = GetItemLinkName(itemLink)
			-- -- local smithingType = KelaGetSmithingType(bagId, slotIndex)
			-- -- local craftItemType = KelaGetitemCraftType(itemLink)
			-- -- local researchLineIndex = KelaItemToResearchLineIndex(itemLink)
			-- -- local traitType = GetItemLinkTraitInfo(itemLink)
			-- if uniqueId then
				-- KelaSetValueIfNil(kpuiSV["ItemsInBackpack"], uniqueId, {})
				-- kpuiSV["ItemsInBackpack"][uniqueId] = {
					-- -- ["itemSmithingType"] = smithingType, 
					-- -- ["itemCraftType"] = craftItemType, 
					-- -- ["itemResearchLineIndex"] = researchLineIndex, 
					-- -- ["itemTraitType"] = traitType,
					-- -- ["itembagId"] = bagId,
					-- -- ["itemSlotIndex"] = slotIndex,
					-- ["itemItemLink"] = itemLink,
					-- ["itemName"] = name,
				-- }
			-- end	
		-- end
	-- end		
-- end	


function Kela_Research:GetTraitTypeResearchStatus(traitType, tradeSkill, resIndex)

	if kpuiConst.UnknowableTraitTypes[traitType] then
		return nil
	end
			
	if not tradeSkill or not resIndex then
		return nil
	end

	-- KelaPadUI.altsResearchStatus = {
		-- [TRAIT_RESEARCHABLE] = {},
		-- [TRAIT_KNOWN] = {},
		-- [TRAIT_RESEARCH_IN_PROGRESS] = {}
	-- }
	
	-- for k,v in pairs(kpuiSV.researches) do
		-- if k ~= KelaPadUI.unitName and ( kpuiSVCharData["researches"][k] == nil or kpuiSV[KelaPadUI.unitName][k] == true ) and kpuiSV.researches[k][tradeSkill] ~= nil then
			-- table.insert(KelaPadUI.altsResearchStatus[kpuiSV.researches[k][tradeSkill][resIndex][traitType]], k)
		-- end
	-- end

	if not (kpuiSVCharData["researches"][tradeSkill] and resIndex) then
		return nil
	end
	
	return kpuiSVCharData["researches"][tradeSkill][resIndex][traitType]
end
function Kela_Research:GetItemLinkResearchStatus(link)
	local traitType = GetItemLinkTraitInfo(link)
	if kpuiConst.UnknowableTraitTypes[traitType] then
		return nil
	end

	local itemType = GetItemLinkItemType(link)
	
	local tradeSkill
	local resIndex
	if itemType == ITEMTYPE_ARMOR then
		local armorType = GetItemLinkArmorType(link)
		local equipType = GetItemLinkEquipType(link)
		local resLines = kpuiConst.ArmorTypeAndEquipTypeToResearchLineIndex[armorType]
		tradeSkill = kpuiConst.TradeskillForArmorType[armorType]
		resIndex = resLines and resLines[equipType]
	elseif itemType == ITEMTYPE_WEAPON then
		local weaponType = GetItemLinkWeaponType(link)
		tradeSkill = kpuiConst.TradeskillForWeaponType[weaponType]
		resIndex = kpuiConst.WeaponTypeToResearchLineIndex[weaponType]
	end

			
	if not tradeSkill or not resIndex then
		return nil
	end

	-- KelaPadUI.altsResearchStatus = {
		-- [TRAIT_RESEARCHABLE] = {},
		-- [TRAIT_KNOWN] = {},
		-- [TRAIT_RESEARCH_IN_PROGRESS] = {}
	-- }
	
	-- for k,v in pairs(kpuiSV.researches) do
		-- if k ~= KelaPadUI.unitName and ( kpuiSV[KelaPadUI.unitName][k] == nil or kpuiSV[KelaPadUI.unitName][k] == true ) and kpuiSV.researches[k][tradeSkill] ~= nil then
			-- table.insert(KelaPadUI.altsResearchStatus[kpuiSV.researches[k][tradeSkill][resIndex][traitType]], k)
		-- end
	-- end

	if not (kpuiSVCharData["researches"][tradeSkill] and resIndex) then
		return nil
	end
	
	return kpuiSVCharData["researches"][tradeSkill][resIndex][traitType]
end

function Kela_Research:InitializeDialogs ()
	-- диалог для заблокированных вещей при изучении на станции
	ESO_Dialogs["KPUI_GAMEPAD_CONFIRM_RESEARCH_BLOCKED_ITEM"] = {
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title = 
		{
			text = KELA_GAMEPAD_SMITHING_RESEARCH_CONFIRM_BLOCKED_DIALOG_TITLE,
		},
		mainText = 
		{
			text = KELA_GAMEPAD_SMITHING_RESEARCH_CONFIRM_BLOCKED_DIALOG_TEXT,
		},
		buttons =
		{
			[1] =
			{
				onShowCooldown = 2000,
				text = KELA_GAMEPAD_SMITHING_RESEARCH_CONFIRM_BLOCKED_DIALOG_ACCEPT,
				callback = function(dialog)
					dialog.data.itemUnlock = true
					SCENE_MANAGER:HideCurrentScene()
				end,
			},
			[2] =
			{
				text = SI_DIALOG_CANCEL
			},
		},
		finishedCallback = function(dialog)
			if dialog.data.itemUnlock then
				ResearchSmithingTrait(dialog.data.bagId, dialog.data.slotIndex)
			else
				SetItemIsPlayerLocked(dialog.data.bagId, dialog.data.slotIndex, true)
			end
		end,
		updateFn = function(dialog)
			if IsItemPlayerLocked(dialog.data.bagId, dialog.data.slotIndex) then 
				SetItemIsPlayerLocked(dialog.data.bagId, dialog.data.slotIndex, false)
			end
		end,
	}
end

--event handlers обрабатывают изменения в исследованиях
function KelaPadUI_OnResearchCompleted(eventType, craftingSkillType, researchLineIndex, traitIndex)
	if not kpuiSVCharData["researches"][craftingSkillType] then
		return
	end
	local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	kpuiSVCharData["researches"][craftingSkillType][researchLineIndex][traitType] = TRAIT_KNOWN
	-- KelaPostMsg("KelaPadUI_OnResearchCompleted")
	KELA_RESEARCH:InitializeResearchableItems()
	KELA_RESEARCH:InitializeResearchPanel(craftingSkillType)
end
function KelaPadUI_OnResearchStarted(eventType, craftingSkillType, researchLineIndex, traitIndex)
	if not kpuiSVCharData["researches"][craftingSkillType] then
		return
	end
	local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	kpuiSVCharData["researches"][craftingSkillType][researchLineIndex][traitType] = TRAIT_RESEARCH_IN_PROGRESS
	-- KelaPostMsg("KelaPadUI_OnResearchStarted")
	KELA_RESEARCH:InitializeResearchableItems()
	KELA_RESEARCH:InitializeResearchPanel(craftingSkillType)
end
function KelaPadUI_OnResearchCanceled(eventType, craftingSkillType, researchLineIndex, traitIndex)
	if not kpuiSVCharData["researches"][craftingSkillType] then
		return
	end
	local traitType = GetSmithingResearchLineTraitInfo(craftingSkillType, researchLineIndex, traitIndex)
	kpuiSVCharData["researches"][craftingSkillType][researchLineIndex][traitType] = TRAIT_RESEARCHABLE
	-- KelaPostMsg("KelaPadUI_OnResearchCanceled")
	KELA_RESEARCH:InitializeResearchableItems()
	KELA_RESEARCH:InitializeResearchPanel(craftingSkillType)
end

-- XML Functions
function Kela_Research_OnInitialize(control)
    KELA_RESEARCH = Kela_Research:New(control)
	-- SYSTEMS:RegisterGamepadObject(KELA_RESEARCH, self)
	
    SYSTEMS:RegisterGamepadObject("kelaResearch", KELA_RESEARCH)
	
end