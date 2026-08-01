
local FilterMenu = {}
TrueExplor = TrueExplor or {}
TrueExplor.filterMenu = FilterMenu

function FilterMenu:Initialize()
	local lang = TrueExplor.lang
	
	TrueExplor:AddCustomDialog("CLEAR_EXPLORATION", {
			gamepadInfo = {dialogType = GAMEPAD_DIALOGS.BASIC},
			title = {text = lang.clearTitle},
			mainText = {text = lang.clearBody},
			buttons = {
				{
					text = GetString(SI_DIALOG_CONFIRM),
					callback = function(dialog)
						ZO_Dialogs_ShowPlatformDialog("FILLED_EXPLORATION", {})
					end,
				},
				{
					text = GetString(SI_DIALOG_CANCEL),
				},
			},
		})
	
	TrueExplor:AddCustomDialog("FILLED_EXPLORATION", {
			canQueue = true,
			gamepadInfo = {dialogType = GAMEPAD_DIALOGS.BASIC},
			title = {text = lang.newMapTitle},
			mainText = {text = lang.newMapBody},
			buttons = {
				{
					text = lang.empty,
					callback = function(dialog)
						local empty = true
						TrueExplor:ClearDataForCurrentMap(empty)
					end,
				},
				{
					text = lang.filled,
					callback = function(dialog)
						local notEmpty = false
						TrueExplor:ClearDataForCurrentMap(notEmpty)
					end,
				},
			},
		})
	
	
	local consolePanels = {
		GAMEPAD_WORLD_MAP_FILTERS.pvePanel,
		GAMEPAD_WORLD_MAP_FILTERS.pvpPanel,
		GAMEPAD_WORLD_MAP_FILTERS.imperialPvPPanel}
	
	local function ToggleDebugFunction(data)
		TrueExplor:SetDebugEnabled(data.currentValue)
	end
	
	local function ClearFunction(data)
		--if not data.currentValue then return end
		ZO_Dialogs_ShowPlatformDialog("CLEAR_EXPLORATION", {})
	end
	
	local function NarrationText(entryData, entryControl)
		return ZO_FormatToggleNarrationText(entryData.text, entryData.currentValue)
	end
	
	for _, panel in pairs(consolePanels) do
		ZO_PreHook(panel, "PostBuildControls", function(panel)
			local text = lang.discoverMap
			local checkBox = ZO_GamepadEntryData:New(text)
			local info = 
			{
				name = text,
				onSelect = function()
					TrueExplor:SetCompletelyDiscoverForCurrentMap(not checkBox.currentValue)
					checkBox.currentValue = not checkBox.currentValue
					panel.list:Commit()
				end,
				showSelectButton = true,
				narrationText = NarrationText,
			}
			checkBox:SetDataSource(info)
			local mapId = GetCurrentMapId()
			local discoveryData = TrueExplor:GetDiscoveryDataForMapId(mapId)
			checkBox.currentValue = discoveryData:IsCompletelyDiscovered()
			panel.list:AddEntry("ZO_GamepadWorldMapFilterCheckboxOptionTemplate", checkBox)
			
			
			local text = lang.clearMap
			local checkBox = ZO_GamepadEntryData:New(text)
			local info = 
			{
				name = text,
				onSelect = ClearFunction,
				showSelectButton = true,
				narrationText = NarrationText,
				selectedNameColor = ZO_ERROR_COLOR,
			}
			checkBox:SetDataSource(info)
			checkBox.currentValue = false
			panel.list:AddEntry("ZO_GamepadWorldMapFilterCheckboxOptionTemplate", checkBox)
			--[[
			local text = lang.debugCheckbox
			local checkBox = ZO_GamepadEntryData:New(text)
			local info = 
			{
				name = text,
				onSelect = ToggleDebugFunction,
				showSelectButton = true,
				narrationText = NarrationText,
			}
			checkBox:SetDataSource(info)
			local mapId = GetCurrentMapId()
			checkBox.currentValue = TrueExplor:IsDebugEnabled()
			panel.list:AddEntry("ZO_GamepadWorldMapFilterCheckboxOptionTemplate", checkBox)]]--
		end)
	end
	
end
