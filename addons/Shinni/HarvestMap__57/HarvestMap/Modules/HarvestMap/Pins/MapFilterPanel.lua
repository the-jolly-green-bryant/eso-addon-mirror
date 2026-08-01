
local CallbackManager = Harvest.callbackManager
local Events = Harvest.events

local MapFilterPanel = {}
Harvest:RegisterModule("mapFilterPanel", MapFilterPanel)

function MapFilterPanel:Initialize()
	
	self.filterProfile = Harvest.filterProfiles:GetMapProfile()
	
	self.consoleCheckboxes = {}
	self.consolePanels = {
		GAMEPAD_WORLD_MAP_FILTERS.pvePanel,
		GAMEPAD_WORLD_MAP_FILTERS.pvpPanel,
		GAMEPAD_WORLD_MAP_FILTERS.imperialPvPPanel}
		
	for _, panel in pairs(self.consolePanels) do
		ZO_PreHook(panel, "PostBuildControls", function()
			if not Harvest.mapPins.mapCache then 
				self:Warn("no mapCache for mapPins? maybe respective module is disabled")
				return 
			end
			
			local mapCache = Harvest.mapPins.mapCache
			
			for _, pinTypeId in pairs(Harvest.mapPins.resourcePinTypeIds) do
				local shouldIncludeFilter = true
				if Harvest.FILTER_ONLY_IF_NODE_EXISTS[pinTypeId] then
					shouldIncludeFilter = mapCache:HasAnyNodesOfPinType(pinTypeId)
				end
				if shouldIncludeFilter then
					self:AddConsoleResourceCheckbox(panel, pinTypeId)
				end
			end
		end)
	end
	
	self.checkboxes = {}
	self.panels = {
		WORLD_MAP_FILTERS.pvePanel,
		WORLD_MAP_FILTERS.pvpPanel,
		WORLD_MAP_FILTERS.imperialPvPPanel}
	
	for _, pinTypeId in ipairs(Harvest.PINTYPES) do
		-- only register the resource pins, not hidden resources like psijic portals
		if not Harvest.HIDDEN_PINTYPES[pinTypeId] then
			for _, panel in pairs(self.panels) do 
				self:AddResourceCheckbox(panel, pinTypeId)
			end
		end
	end
	
	
	CallbackManager:RegisterForEvent(Events.SETTING_CHANGED, function(event, setting, pinTypeId)
		if setting == "mapFilterProfile" then
			self.filterProfile = Harvest.filterProfiles:GetMapProfile()
			
			-- refresh console checkboxes
			for pinTypeId, checkbox in pairs(self.consoleCheckboxes) do
				checkbox.currentValue = self.filterProfile[pinTypeId]
			end
			for _ , panel in pairs(self.consolePanels) do
				panel:BuildControls()
			end
			
			-- refresh pc checkboxes
			for pinTypeId, checkboxes in pairs(self.checkboxes) do
				for _, checkbox in pairs(checkboxes) do
					ZO_CheckButton_SetCheckState(checkbox, self.filterProfile[pinTypeId])
				end
			end
		elseif setting == "mapPinTexture" then
			self:RefreshButtonsForPinTypeId(pinTypeId)
		elseif setting == "pinTypeColor" then
			self:RefreshButtonsForPinTypeId(pinTypeId)
		end
	end)
	
	CallbackManager:RegisterForEvent(Events.FILTER_PROFILE_CHANGED, function(event, profile, pinTypeId, visible)
		if profile == self.filterProfile then
			self:RefreshButtonsForPinTypeId(pinTypeId)
		end
	end)
	
	CallbackManager:RegisterForEvent(Events.MAP_CHANGE, function(event)
		self:RefreshPinTypeFilters()
	end)
	CallbackManager:RegisterForEvent(Events.FIRST_OF_PINTYPE, function(event, mapCache, pinTypeId)
		self:RefreshPinTypeFilters()
	end)
	
	-- additional filter checkboxes
	self:AddHeatMapCheckbox()
	self:AddDeletePinCheckbox()
	self:EnableScrollableFilters()
end

function MapFilterPanel:RefreshButtonsForPinTypeId(pinTypeId)
	-- refresh console checkbox
	local checkbox = self.consoleCheckboxes[pinTypeId]
	if checkbox then
		checkbox.currentValue = self.filterProfile[pinTypeId]
		for _ , panel in pairs(self.consolePanels) do
			panel:BuildControls()
		end
	end
	-- refresh pc checkbox
	local checkboxes = self.checkboxes[pinTypeId]
	if checkboxes then
		for _, checkbox in pairs(checkboxes) do
			ZO_CheckButton_SetCheckState(checkbox, self.filterProfile[pinTypeId])
			ZO_CheckButtonLabel_ColorText(checkbox.label, false)
		end
	end
end

function MapFilterPanel:AddHeatMapCheckbox()
	local updateHeatmapStatus = function(button, state)
		Harvest.SetHeatmapActive(state)
	end
	
	for _, panel in pairs(self.panels) do
		local checkbox = self:AddCheckbox(panel, Harvest.GetLocalization( "filterheatmap" ))
		ZO_CheckButton_SetToggleFunction(checkbox, updateHeatmapStatus)
		ZO_CheckButton_SetCheckState(checkbox, Harvest.IsHeatmapActive())
	end
end

function MapFilterPanel:AddDeletePinCheckbox()
	local updateDeletionStatus = function(button, state)
		Harvest.SetPinDeletionEnabled(state)
	end
	
	for _, panel in pairs(self.panels) do
		local checkbox = self:AddCheckbox(panel, Harvest.GetLocalization( "deletepinfilter" ))
		ZO_CheckButton_SetToggleFunction(checkbox, updateDeletionStatus)
		ZO_CheckButton_SetCheckState(checkbox, Harvest.IsPinDeletionEnabled())
	end
end

local function OnConsoleButtonToggled(pinTypeId)
	local filterProfile = Harvest.mapFilterPanel.filterProfile
	filterProfile[pinTypeId] = not filterProfile[pinTypeId]
	CallbackManager:FireCallbacks(Events.FILTER_PROFILE_CHANGED, filterProfile, pinTypeId, filterProfile[pinTypeId])
end

function MapFilterPanel:AddConsoleCheckbox(panel, text, onToggle)
	local function ToggleFunction(data)
		onToggle()
        panel:BuildControls()
        SCREEN_NARRATION_MANAGER:QueueParametricListEntry(panel.list)
    end
	
	local info = 
    {
        name = text,
        onSelect = ToggleFunction,
        showSelectButton = true,
        narrationText = function(entryData, entryControl)
            return ZO_FormatToggleNarrationText(entryData.text, entryData.currentValue)
        end,
    }
	
	local checkBox = ZO_GamepadEntryData:New(info.name)
    checkBox:SetDataSource(info)

    table.insert(panel.pinFilterCheckBoxes, checkBox)

    panel.list:AddEntry("ZO_GamepadWorldMapFilterCheckboxOptionTemplate", checkBox)
	
	return checkBox
end

local function colorizeText(text, r,g,b,a)
	return string.format("|c%.2x%.2x%.2x%s|r", zo_round(r * 255), zo_round(g * 255), zo_round(b * 255), text)
end

function MapFilterPanel:AddConsoleResourceCheckbox(panel, pinTypeId)
	local text = Harvest.GetLocalization( "pintype" .. pinTypeId )
	local onToggle = function(...) OnConsoleButtonToggled(pinTypeId, ...) end
	
	local layout = Harvest.GetMapPinLayout(pinTypeId)
	local newText = layout.tint:Colorize(zo_iconFormatInheritColor(layout.texture, 40, 40))
	text = newText .. text
	
	local checkbox = self:AddConsoleCheckbox(panel, text, onToggle)
	self.consoleCheckboxes[pinTypeId] = checkbox
	checkbox.currentValue = self.filterProfile[pinTypeId]
	
	return checkbox
end

local function OnButtonToggled(pinTypeId, button, visible)
	local filterProfile = Harvest.mapPins.filterProfile
	filterProfile[pinTypeId] = visible
	CallbackManager:FireCallbacks(Events.FILTER_PROFILE_CHANGED, filterProfile, pinTypeId, visible)
end

function MapFilterPanel:RefreshPinTypeFilters()
	
	if not Harvest.mapPins.mapCache then 
		return 
	end
	
	local mapCache = Harvest.mapPins.mapCache
	
	for pinTypeId in pairs(Harvest.FILTER_ONLY_IF_NODE_EXISTS) do
		local shouldIncludeFilter = mapCache:HasAnyNodesOfPinType(pinTypeId)
		for _, checkbox in pairs(self.checkboxes[pinTypeId]) do
			if shouldIncludeFilter then
				checkbox:SetHidden(false)
				checkbox.next:SetAnchor(TOPLEFT, checkbox, BOTTOMLEFT, 0, 8)
			else
				checkbox:SetHidden(true)
				checkbox.next:SetAnchor(TOPLEFT, checkbox, TOPLEFT, 0, 0)
			end
		end
	end
end

-- code based on LibMapPin, see https://esoui.com/downloads/info563-LibMapPins.html for credits
local prev = {}
function MapFilterPanel:AddCheckbox(panel, text)
	local checkbox = panel.checkBoxPool:AcquireObject()
	ZO_CheckButton_SetLabelText(checkbox, text)
	panel:AnchorControl(checkbox)
	prev[panel] = prev[panel] or {}
	checkbox.prev = prev[panel]
	if prev[panel] then
		prev[panel].next = checkbox
	end
	prev[panel] = checkbox
	return checkbox
end

local function NewSetColor(self, r, g, b, a, ...)
	local layout = Harvest.GetMapPinLayout(self.pinTypeId)
	local newText = layout.tint:Colorize(zo_iconFormatInheritColor(layout.texture, 20, 20))
	newText = newText .. colorizeText(self.text, r,g,b,a)
	self:SetText(newText)
end

function MapFilterPanel:AddResourceCheckbox(panel, pinTypeId)
	local text = Harvest.GetLocalization( "pintype" .. pinTypeId )
	local checkbox = self:AddCheckbox(panel, text)
	self.checkboxes[pinTypeId] = self.checkboxes[pinTypeId] or {}
	table.insert(self.checkboxes[pinTypeId], checkbox)
	-- on mouse over the color is switched to "highlight"
	-- this removed the color of the texture, so we have to change the setColor behaviour
	local label = checkbox.label
	label.text = text
	label.SetColor = NewSetColor
	label.pinTypeId = pinTypeId
	
	ZO_CheckButton_SetLabelText(checkbox, text)
	ZO_CheckButton_SetCheckState(checkbox, self.filterProfile[pinTypeId])
	ZO_CheckButton_SetToggleFunction(checkbox, function(...) OnButtonToggled(pinTypeId, ...) end)
	ZO_CheckButtonLabel_ColorText(label, false)
	
	return checkbox
end

function MapFilterPanel:EnableScrollableFilters()
	-- The following code is from LibMapPins
	
	-------------------------------------------------------------------------------
	-- LibMapPins-1.0
	-------------------------------------------------------------------------------
	--
	-- Copyright (c) 2014, 2015 Ales Machat (Garkin)
	--
	-- Permission is hereby granted, free of charge, to any person
	-- obtaining a copy of this software and associated documentation
	-- files (the "Software"), to deal in the Software without
	-- restriction, including without limitation the rights to use,
	-- copy, modify, merge, publish, distribute, sublicense, and/or sell
	-- copies of the Software, and to permit persons to whom the
	-- Software is furnished to do so, subject to the following
	-- conditions:
	--
	-- The above copyright notice and this permission notice shall be
	-- included in all copies or substantial portions of the Software.
	--
	-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	-- OTHER DEALINGS IN THE SOFTWARE.
	--
	-------------------------------------------------------------------------------
	if WORLD_MAP_FILTERS.pvePanel.checkBoxPool then
        WORLD_MAP_FILTERS.pvePanel.checkBoxPool.parent = ZO_WorldMapFiltersPvEContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersPvEContainer", ZO_WorldMapFiltersPvE, "ZO_ScrollContainer"):GetNamedChild("ScrollChild")
        for i, control in pairs(WORLD_MAP_FILTERS.pvePanel.checkBoxPool.m_Active) do
            control:SetParent(WORLD_MAP_FILTERS.pvePanel.checkBoxPool.parent)
        end
        if ZO_WorldMapFiltersPvECheckBox1 then
            local valid, point, control, relPoint, x, y = ZO_WorldMapFiltersPvECheckBox1:GetAnchor(0)
            if control == WORLD_MAP_FILTERS.pvePanel.control then
                ZO_WorldMapFiltersPvECheckBox1:SetAnchor(point, ZO_WorldMapFiltersPvEContainerScrollChild, relPoint, x, y)
            end
        end
    end
    if WORLD_MAP_FILTERS.pvePanel.comboBoxPool then
        WORLD_MAP_FILTERS.pvePanel.comboBoxPool.parent = ZO_WorldMapFiltersPvEContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersPvEContainer", ZO_WorldMapFiltersPvE, "ZO_ScrollContainer"):GetNamedChild("ScrollChild")
        for i, control in pairs(WORLD_MAP_FILTERS.pvePanel.comboBoxPool.m_Active) do
            control:SetParent(WORLD_MAP_FILTERS.pvePanel.comboBoxPool.parent)
        end
        if ZO_WorldMapFiltersPvEComboBox1 then
            local valid, point, control, relPoint, x, y = ZO_WorldMapFiltersPvEComboBox1:GetAnchor(0)
            if control == WORLD_MAP_FILTERS.pvePanel.control then
                ZO_WorldMapFiltersPvEComboBox1:SetAnchor(point, ZO_WorldMapFiltersPvEContainerScrollChild, relPoint, x, y)
            end
        end
    end
    if ZO_WorldMapFiltersPvEContainer then
        ZO_WorldMapFiltersPvEContainer:SetAnchorFill()
    end

    if WORLD_MAP_FILTERS.pvpPanel.checkBoxPool then
        WORLD_MAP_FILTERS.pvpPanel.checkBoxPool.parent = ZO_WorldMapFiltersPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersPvPContainer", ZO_WorldMapFiltersPvP, "ZO_ScrollContainer"):GetNamedChild("ScrollChild")
        for i, control in pairs(WORLD_MAP_FILTERS.pvpPanel.checkBoxPool.m_Active) do
            control:SetParent(WORLD_MAP_FILTERS.pvpPanel.checkBoxPool.parent)
        end
        if ZO_WorldMapFiltersPvPCheckBox1 then
            local valid, point, control, relPoint, x, y = ZO_WorldMapFiltersPvPCheckBox1:GetAnchor(0)
            if control == WORLD_MAP_FILTERS.pvpPanel.control then
                ZO_WorldMapFiltersPvPCheckBox1:SetAnchor(point, ZO_WorldMapFiltersPvPContainerScrollChild, relPoint, x, y)
            end
        end
    end
    if WORLD_MAP_FILTERS.pvpPanel.comboBoxPool then
        WORLD_MAP_FILTERS.pvpPanel.comboBoxPool.parent = ZO_WorldMapFiltersPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersPvPContainer", ZO_WorldMapFiltersPvP, "ZO_ScrollContainer"):GetNamedChild("ScrollChild")
        for i, control in pairs(WORLD_MAP_FILTERS.pvpPanel.comboBoxPool.m_Active) do
            control:SetParent(WORLD_MAP_FILTERS.pvpPanel.comboBoxPool.parent)
        end
        if ZO_WorldMapFiltersPvPComboBox1 then
            local valid, point, control, relPoint, x, y = ZO_WorldMapFiltersPvPComboBox1:GetAnchor(0)
            if control == WORLD_MAP_FILTERS.pvpPanel.control then
                ZO_WorldMapFiltersPvPComboBox1:SetAnchor(point, ZO_WorldMapFiltersPvPContainerScrollChild, relPoint, x, y)
            end
        end
    end
    if ZO_WorldMapFiltersPvPContainer then
        ZO_WorldMapFiltersPvPContainer:SetAnchorFill()
    end

    if WORLD_MAP_FILTERS.imperialPvPPanel.checkBoxPool then
        WORLD_MAP_FILTERS.imperialPvPPanel.checkBoxPool.parent = ZO_WorldMapFiltersImperialPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersImperialPvPContainer", ZO_WorldMapFiltersImperialPvP, "ZO_ScrollContainer"):GetNamedChild("ScrollChild")
        for i, control in pairs(WORLD_MAP_FILTERS.imperialPvPPanel.checkBoxPool.m_Active) do
            control:SetParent(WORLD_MAP_FILTERS.imperialPvPPanel.checkBoxPool.parent)
        end
        if ZO_WorldMapFiltersImperialPvPCheckBox1 then
            local valid, point, control, relPoint, x, y = ZO_WorldMapFiltersImperialPvPCheckBox1:GetAnchor(0)
            if control == WORLD_MAP_FILTERS.imperialPvPPanel.control then
                ZO_WorldMapFiltersImperialPvPCheckBox1:SetAnchor(point, ZO_WorldMapFiltersImperialPvPContainerScrollChild, relPoint, x, y)
            end
        end
    end
    if WORLD_MAP_FILTERS.imperialPvPPanel.comboBoxPool then
        WORLD_MAP_FILTERS.imperialPvPPanel.comboBoxPool.parent = ZO_WorldMapFiltersImperialPvPContainerScrollChild or WINDOW_MANAGER:CreateControlFromVirtual("ZO_WorldMapFiltersImperialPvPContainer", ZO_WorldMapFiltersImperialPvP, "ZO_ScrollContainer"):GetNamedChild("ScrollChild")
        for i, control in pairs(WORLD_MAP_FILTERS.imperialPvPPanel.comboBoxPool.m_Active) do
            control:SetParent(WORLD_MAP_FILTERS.imperialPvPPanel.comboBoxPool.parent)
        end
        if ZO_WorldMapFiltersImperialPvPComboBox1 then
            local valid, point, control, relPoint, x, y = ZO_WorldMapFiltersImperialPvPComboBox1:GetAnchor(0)
            if control == WORLD_MAP_FILTERS.imperialPvPPanel.control then
                ZO_WorldMapFiltersPvPComboBox1:SetAnchor(point, ZO_WorldMapFiltersImperialPvPContainerScrollChild, relPoint, x, y)
            end
        end
    end
    if ZO_WorldMapFiltersImperialPvPContainer then
        ZO_WorldMapFiltersImperialPvPContainer:SetAnchorFill()
    end
	
	--[[
	
	End of LibMapPins code
	
	]]--
end
