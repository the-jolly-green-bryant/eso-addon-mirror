local Kela_Research = ZO_Gamepad_ParametricList_Screen:Subclass()
local colors = kpuiConst.Colors	
local smithingTypes = kpuiConst.SmithingTypes

local selectedIndex = 1
local templateEntryBlacksmithing
local templateEntryClothier
local templateEntryWoodworking
local templateEntryJewelrycrafting

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
		local researchLines, count, maxResearchable = KelaPadUI:GetCurrentResearchLines(displayMode)
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
	KPUI_GAMEPAD_TOOLTIPS:ClearContentHeader(KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP)
end



function kelaInitializeResearchPanel()

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
					local traitResearchStatus = KelaPadUI:GetTraitTypeResearchStatus(traitType, craftingType, researchLineIndex)

					if traitResearchStatus == 0 then 
						itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[craftingType][researchLineIndex] 
						local tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree = KelaPadUI:GetTableResearchableItemsByTrait(craftingType, itemCraftType, researchLineIndex, traitType)				
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
					local traitResearchStatus = KelaPadUI:GetTraitTypeResearchStatus(traitType, craftingType, researchLineIndex)
					if traitResearchStatus == 0 then 
						local itemCraftType = kpuiConst.SmithingTypeResearchLineTraitTypeToItemCraftType[craftingType][researchLineIndex] 
						local tblResearchableItemsWorned, tblResearchableItemsLocked, tblResearchableItemsFree = KelaPadUI:GetTableResearchableItemsByTrait(craftingType, itemCraftType, researchLineIndex, traitType)				
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
		
		local tableResearchableItems = KelaPadUI:GetTableResearchableItems(craftingType)
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
		
		local tableResearchableItems = KelaPadUI:GetTableResearchableItems(craftingType)
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
										local iconBag, _, iconLocked = KelaPadUI:GetBagInfo(v4, 24)
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
	
	local tableResearchableItems = KelaPadUI:GetTableResearchableItems(craftingType)
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
								local iconBag, _, iconLocked = KelaPadUI:GetBagInfo(v4, 24)
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



-- XML Functions
function Kela_Research_OnInitialize(control)
    KELA_RESEARCH = Kela_Research:New(control)
	SYSTEMS:RegisterGamepadObject(KELA_RESEARCH, self)
end