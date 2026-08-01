
local colors = kpuiConst.Colors	



local hookAchievementsAlready = false
local firstShownMainMenu = false

function KelaSetupAchievements()
	-- настраиваем сцену достижений
	
	
	
	-- SecurePostHook(ACHIEVEMENTS_GAMEPAD, "OnShowing", function()
		-- CHAT_SYSTEM:AddMessage("OnShowing")
		-- KEYBIND_STRIP:UpdateKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)
	-- end)
	-- SecurePostHook(ACHIEVEMENTS_GAMEPAD, "PerformUpdate", function()
		-- CHAT_SYSTEM:AddMessage("PerformUpdate")
		-- KEYBIND_STRIP:UpdateKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)
	-- end)	
	-- SecurePostHook(ACHIEVEMENTS_GAMEPAD, "PopulateAchievements", function(categoryIndex, ...)
		-- CHAT_SYSTEM:AddMessage("PopulateAchievements")
		-- KEYBIND_STRIP:UpdateKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)
	-- end)	



		KelaSetValueIfNil(kpuiSVCharData, "trackedAchievements", {})



		-- проверяем отслеживаемые достижения на предмет зависших
		local mainMenuGamepadScene = SCENE_MANAGER.scenes.mainMenuGamepad
		mainMenuGamepadScene:RegisterCallback("StateChange", function(oldState, newState) 
			-- states: hiding, showing, shown, hidden
			if(newState == "showing") and not firstShownMainMenu then
				-- CHAT_SYSTEM:AddMessage("showing")
				if kpuiSVCharData["trackedAchievements"] ~= nil and next(kpuiSVCharData["trackedAchievements"]) ~= nil then
					for Id, v in pairs(kpuiSVCharData["trackedAchievements"]) do
						local _, _, _, _, completed, _, _= GetAchievementInfo(Id)
						if completed then
							KelaRemoveValueByKey(kpuiSVCharData["trackedAchievements"], Id)
						end
					end
				end	
			firstShownMainMenu = true
			end
		end) 



	
	SecurePostHook(ACHIEVEMENTS_GAMEPAD, "PopulateCategories", function()
		
		-- CHAT_SYSTEM:AddMessage("PopulateCategories")
		
		if not hookAchievementsAlready then
		
		-- kpuiSVCharData["trackedAchievements"] = nil
		-- kpuiSVCharData["trackedAchievements"] = {}	
		
		
		
			-- обрабатываем добавление/удаление в отслеживаемые
			local function toTrack(selectedAchievementId)
				KelaSetValueIfNil(kpuiSVCharData["trackedAchievements"], selectedAchievementId, 1)
				KEYBIND_STRIP:UpdateKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)
			end		
			local function notTrack(selectedAchievementId)
				KelaRemoveValueByKey(kpuiSVCharData["trackedAchievements"], selectedAchievementId)
				ACHIEVEMENTS_GAMEPAD:PerformUpdate()
				KEYBIND_STRIP:UpdateKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)
			end		
			local function isTracked(selectedAchievementId)
				return KelaKeyIsInTbl (kpuiSVCharData["trackedAchievements"], selectedAchievementId)
			end
			
			
			



			local keybind  =
			-- кнопка отслеживания
			{
				alignment = KEYBIND_STRIP_ALIGN_CENTER,	
				name = function()
						local _, selectedAchievementId = ACHIEVEMENTS_GAMEPAD:GetSelectionInformation()
						if isTracked (selectedAchievementId) then
							return GetString(KELA_ACHIEVEMENT_NOT_TRACK)
						else
							return GetString(KELA_ACHIEVEMENT_TRACK)
						end
					end,
				keybind = "UI_SHORTCUT_SECONDARY",
				visible = function()
						local _, selectedAchievementId = ACHIEVEMENTS_GAMEPAD:GetSelectionInformation()
						local completed
						local currentId = type(selectedAchievementId) == "number"
						if currentId then _, _, _, _, completed, _, _= GetAchievementInfo(selectedAchievementId) end
						return KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_ACHIVTRACK) and currentId and (isTracked(selectedAchievementId) or not completed)
					end,
				callback = function()
						local _, selectedAchievementId = ACHIEVEMENTS_GAMEPAD:GetSelectionInformation()
						if isTracked (selectedAchievementId) then
							notTrack(selectedAchievementId)
						else
							toTrack(selectedAchievementId)
						end
					end,
			}
			table.insert(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor, keybind)
				
			ZO_Gamepad_AddListTriggerKeybindDescriptors(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor, ACHIEVEMENTS_GAMEPAD.itemList)
			KEYBIND_STRIP:RemoveKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)
			KEYBIND_STRIP:AddKeybindButtonGroup(ACHIEVEMENTS_GAMEPAD.keybindStripDescriptor)


			-- настройка проверки достижения на соответствие фильтру
			function ZO_ShouldShowAchievement(filterType, id)
				

				if filterType == KELA_ACHIEVEMENT_FILTER_SHOW_TRACKED then

					local chainId = GetFirstAchievementInLine(id)
					local chainIndex = 1
					while chainId ~= 0 do
						if isTracked(chainId) then 
							return true 
						end		
						chainId = GetNextAchievementInLine(chainId)
						chainIndex = chainIndex + 1
					end

					if chainIndex <= 2 then
					-- This achievement is not part of a chain
						-- while id ~= 0 do
							if isTracked(id) then 
								-- CHAT_SYSTEM:AddMessage(tostring(chainId))
								return true 
							end						
							-- id = GetNextAchievementInLine(id)
						-- end
					end
				else
					if filterType == SI_ACHIEVEMENT_FILTER_SHOW_ALL then
						return true
					end
					while id ~= 0 do
						local _, _, _, _, completed, _, _= GetAchievementInfo(id)
						if completed then
							if filterType == SI_ACHIEVEMENT_FILTER_SHOW_EARNED then
								return true
							end
							-- This achievement was completed, but we want to show unearned, so see if there are any unearned achievements in this line
							id = GetNextAchievementInLine(id)
						else -- This achievement wasn't completed
							if filterType == SI_ACHIEVEMENT_FILTER_SHOW_UNEARNED then
								return true
							end
							-- Otherwise we only want to show earned achievements, so find the first completed achievement working backwards from this one
							id = GetPreviousAchievementInLine(id)
						end
					end
				end
				-- Either this achievement wasn't a line, or everything in it was filtered.
				return false
			end

			-- настраиваем диалог
			ZO_Dialogs_RegisterCustomDialog("ACHIEVEMENTS_OPTIONS_GAMEPAD",
			{
				gamepadInfo =
				{
					dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
				},

				title =
				{
					text = SI_GAMEPAD_ACHIEVEMENTS_OPTIONS,
				},

				setup = function(dialog)
					local CHECKED_ICON          = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds"
					local UNCHECKED_ICON = nil
					dialog.info.parametricList = {}
					local function SwitchToFilterMode(entry)
						ACHIEVEMENTS_GAMEPAD:SwitchToFilterMode(entry.filterType)
					end
					local function GetTemplate(newEntry, firstRow)
						if firstRow then		
							return
							{
								template = "ZO_GamepadMenuEntryTemplate",
								header = SI_GAMEPAD_OPTIONS_MENU,
								entryData = newEntry,
							}
						else
							return 
							{
								template = "ZO_GamepadMenuEntryTemplate",
								entryData = newEntry,
							}
						end
					end		
					local function CreateEntry(filterType)
						local newEntry = ZO_GamepadEntryData:New(zo_strformat(filterType), (ACHIEVEMENTS_GAMEPAD.filterType == filterType) and CHECKED_ICON or UNCHECKED_ICON)
						newEntry.setup = ZO_SharedGamepadEntry_OnSetup
						newEntry.filterType = filterType
						newEntry.callback = SwitchToFilterMode
						table.insert(dialog.info.parametricList, GetTemplate(newEntry, (filterType == SI_ACHIEVEMENT_FILTER_SHOW_ALL) and true or false ))
						return newEntry
					end
					local showAllAchievements = CreateEntry(SI_ACHIEVEMENT_FILTER_SHOW_ALL)
					local showEarnedAchievements = CreateEntry(SI_ACHIEVEMENT_FILTER_SHOW_EARNED)
					local showUnearnedAchievements = CreateEntry(SI_ACHIEVEMENT_FILTER_SHOW_UNEARNED)
					if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_MAININFO_ACHIVTRACK) then
						local kelaShowTrackedAchievements = CreateEntry(KELA_ACHIEVEMENT_FILTER_SHOW_TRACKED)
						ACHIEVEMENTS_GAMEPAD.dialogFilterEntries = {showAllAchievements, showEarnedAchievements, showUnearnedAchievements, kelaShowTrackedAchievements}
					else
						ACHIEVEMENTS_GAMEPAD.dialogFilterEntries = {showAllAchievements, showEarnedAchievements, showUnearnedAchievements}				
					end
					dialog:setupFunc()
				end,
				parametricList = {},
				buttons =
				{
					{
						keybind = "DIALOG_PRIMARY",
						text = SI_GAMEPAD_SELECT_OPTION,
						callback =  function(dialog)
							local data = dialog.entryList:GetTargetData()
							if data.callback then
								data.callback(data)
							end
						end,
						clickSound = SOUNDS.DIALOG_ACCEPT,
					},
					{
						keybind = "DIALOG_NEGATIVE",
						text = SI_DIALOG_CANCEL,
					},
				}
			})


			-- Обрабатываем получение награды
			-- local function Update(event, id)
				-- if isTracked(id) then
					-- _, _, _, _, completed, _, _ = GetAchievementInfo(id)
					-- if completed then
						-- notTrack(id)
					-- end
				-- end
			-- end


			-- EVENT_MANAGER:RegisterForEvent("KelaPadUI", EVENT_ACHIEVEMENT_AWARDED, KelaPadUI_OnResearchCompleted)



			hookAchievementsAlready = true
			
			
			
		end
			

		
	end)
end








