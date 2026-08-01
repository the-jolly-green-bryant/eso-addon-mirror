
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
		self.consoleCheckboxes[panel] = {}
		panel.list:AddDataTemplate("HarvestMapGamepadWorldMapFilterCheckboxTemplate", ZO_GamepadCheckboxOptionTemplate_Setup, ZO_GamepadMenuEntryTemplateParametricListFunction)
		ZO_PreHook(panel, "PostBuildControls", function(panel)
			if not Harvest.mapPins.mapCache then 
				self:Warn("no mapCache for mapPins? maybe respective module is disabled")
				return 
			end
			local mapMetaData = Harvest.mapPins.mapCache.mapMetaData
			local map = mapMetaData.map
			local zoneId = mapMetaData.zoneId
			
			local submodule = Harvest.submoduleManager:GetSubmoduleForMap(map)
			if not submodule then
				return
			end
			local downloadedVars = submodule.downloadedVars
			local savedVars = submodule.savedVars
			for _, pinTypeId in pairs(Harvest.mapPins.resourcePinTypeIds) do
				local shouldIncludeFilter = true
				if Harvest.FILTER_ONLY_IF_NODE_EXISTS[pinTypeId] then
					shouldIncludeFilter = false
					if downloadedVars[zoneId] and downloadedVars[zoneId][map] and downloadedVars[zoneId][map][pinTypeId] then
						shouldIncludeFilter = true
					end
					if savedVars[zoneId] and savedVars[zoneId][map] and savedVars[zoneId][map][pinTypeId] then
						shouldIncludeFilter = true
					end
				end
				if shouldIncludeFilter then
					--self:AddConsoleResourceCheckbox(panel, pinTypeId)
					local checkBox = self.consoleCheckboxes[panel][pinTypeId]
					checkBox.currentValue = self.filterProfile[pinTypeId]
					
					local text = Harvest.GetLocalization( "pintype" .. pinTypeId )
					local layout = Harvest.GetMapPinLayout(pinTypeId)
					local newText = layout.tint:Colorize(zo_iconFormatInheritColor(layout.texture, 40, 40))
					text = newText .. text
					checkBox:SetText(text)
					
					panel.list:AddEntry("HarvestMapGamepadWorldMapFilterCheckboxTemplate", checkBox)
				end
			end
		end)
		
		for _, pinTypeId in ipairs(Harvest.PINTYPES) do
			-- only register the resource pins, not hidden resources like psijic portals
			if not Harvest.HIDDEN_PINTYPES[pinTypeId] then
				self:AddConsoleResourceCheckbox(panel, pinTypeId)
			end
		end
	end
	
end

function MapFilterPanel:AddConsoleResourceCheckbox(panel, pinTypeId)
	local text = Harvest.GetLocalization( "pintype" .. pinTypeId )
	local checkBox = ZO_GamepadEntryData:New(text)
	
	local function ToggleFunction(data)
		self.filterProfile[pinTypeId] = not self.filterProfile[pinTypeId]
		CallbackManager:FireCallbacks(Events.FILTER_PROFILE_CHANGED, 
			self.filterProfile, pinTypeId, self.filterProfile[pinTypeId])
		
        --d("build")
		--panel:BuildControls()
		checkBox.currentValue = self.filterProfile[pinTypeId]
		panel.list:Commit()
        --SCREEN_NARRATION_MANAGER:QueueParametricListEntry(panel.list)
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
	
    checkBox:SetDataSource(info)
	
	self.consoleCheckboxes[panel][pinTypeId] = checkBox
	
end

