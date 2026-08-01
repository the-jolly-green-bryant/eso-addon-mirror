BombTimer = {}
BombTimer.name = "BombTimer"

function BombTimer.LoadSettings()
	local LAM = LibAddonMenu2
	local panelName = "BombTimerPanel"

	local panelData = {
		type = "panel",
		name = "BombTimer",
		author = "@Citats",
	}
	local panel = LAM:RegisterAddonPanel(panelName, panelData)
	local optionsData = {
		[1] = {
			type = "dropdown",
			name = "Timer",
			tooltip = "Choose which timer to use.",
			choices = BombTimer.TimerTypeChoices,
			getFunc = function() return BombTimer.SavedVariables.TimerType end,
			setFunc = function(var)
				BombTimer.SavedVariables.TimerType = var
				BombTimer.Timeline = nil
				BombTimer.GroupTrigger = false
				
				for i, activity in ipairs(BombTimer.AWSavedVariables.Activities) do
					if var == activity.name then
						BombTimer.AbilityId = activity.ability
						BombTimer.TimerDurations = activity.durations
						BombTimer.GroupTrigger = activity.group
					end
				end
				
				d("BombTimer Timer changed to \"" .. var .. "\".")
			end,
			width = "full",
			reference = "TimerType1",
		},
		[2] = {
			type = "checkbox",
			name = "Lock",
			tooltip = "Toggle off to move the timer position on screen. Toggle back on to save the new position.",
			getFunc = function() return true end,
			setFunc = function(value)
				if value then
					BombTimer.Locked = true
					BombTimer.TimerBar:SetHidden(true)
					
					local coordX, coordY = BombTimer.TimerBar:GetCenter()
					BombTimer.SavedVariables.OffsetX = coordX - (GuiRoot:GetWidth() / 2)
					BombTimer.SavedVariables.OffsetY = coordY - (GuiRoot:GetHeight() / 2)
					BombTimer.TimerBar:SetMouseEnabled(false)
					BombTimer.TimerBar:SetMovable(false)
					d("BombTimer position saved.")
				else
					BombTimer.Locked = false
					BombTimer.TimerBar:SetHidden(false)
					BombTimer.TimerBar:SetMouseEnabled(true)
					BombTimer.TimerBar:SetMovable(true)
				end
			end,
			width = "full"
		},
		[3] = {
			type = "checkbox",
			name = "Countdown Numbers",
			tooltip = "Whether to display countdown numbers on the timer bar.",
			getFunc = function() return BombTimer.SavedVariables.Countdown end,
			setFunc = function(value)
				if value then
					BombTimer.TimerBar.Container.Front:SetText("")
					BombTimer.SavedVariables.Countdown = true
					d("BombTimer countdown numbers enabled.")
				else
					EVENT_MANAGER:UnregisterForUpdate("BombTimerCountdown")
					BombTimer.TimerBar.Container.Front:SetText("")
					BombTimer.SavedVariables.Countdown = false
					d("BombTimer countdown numbers disabled.")
				end
			end,
			width = "full"
		},
		[4] = {
			type = "checkbox",
			name = "Combine Timer Sequence",
			tooltip = "Combine your timer sequence into a single supertimer.",
			getFunc = function() return BombTimer.SavedVariables.Combine end,
			setFunc = function(value)
				if value then
					BombTimer.SavedVariables.Combine = true
					d("BombTimer will now combine your timer sequence.")
				else
					BombTimer.SavedVariables.Combine = false
					d("BombTimer will now separate your timer sequence.")
				end
			end,
			width = "full"
		},
		[5] = {
			type = "dropdown",
			name = "Countdown Font Style",
			tooltip = "Change the font style of the countdown numbers.",
			choices = {"Small", "Medium", "Large", "Small + Outline", "Medium + Outline", "Large + Outline"},
			getFunc = function() return BombTimer.SavedVariables.FontStyle end,
			setFunc = function(var)
				BombTimer.SavedVariables.FontStyle = var
				BombTimer.TimerBar.Container.Front:SetFont(BombTimer.GetFontStyleString())
				d("BombTimer font style changed to " .. var .. ".")
			end,
			width = "full",
		},
		[6] = {
			type = "slider",
			name = "Width",
			min = 4,
            max = 800,
			tooltip = "Customize the width of the timer bar.",
			getFunc = function() return BombTimer.SavedVariables.Width end,
			setFunc = function(value)
				if value ~= BombTimer.SavedVariables.Width then
					BombTimer.SavedVariables.Width = value
					BombTimer.Timeline = nil
					BombTimer.UpdateTimerBarControl()
					d("BombTimer width changed.")
				end
			end,
			width = "full"
		},
		[7] = {
			type = "slider",
			name = "Height",
			min = 1,
            max = 200,
			tooltip = "Customize the height of the timer bar.",
			getFunc = function() return BombTimer.SavedVariables.Height end,
			setFunc = function(value)
				if value ~= BombTimer.SavedVariables.Height then
					BombTimer.SavedVariables.Height = value
					BombTimer.Timeline = nil
					BombTimer.UpdateTimerBarControl()
					d("BombTimer height changed.")
				end
			end,
			width = "full"
		},
		[8] = {
			type = "slider",
			name = "Group Trigger Sensitivity",
			min = 10,
            max = 2000,
			tooltip = "Customize the sensitivity in milliseconds of the group trigger.",
			getFunc = function() return BombTimer.SavedVariables.GroupTriggerSensitivity end,
			setFunc = function(value)
				if value ~= BombTimer.SavedVariables.GroupTriggerSensitivity then
					BombTimer.SavedVariables.GroupTriggerSensitivity = value
					d("BombTimer group trigger sensitivity changed.")
				end
			end,
			width = "full"
		},
		[9] = {
			type = "button",
			name = "Foreground Color",
			tooltip = "Customize the foreground color of the timer bar.",
			func = function()
				local color = ZO_ColorDef:New(BombTimer.SavedVariables.ColorForegroundR, BombTimer.SavedVariables.ColorForegroundG, BombTimer.SavedVariables.ColorForegroundB)
				COLOR_PICKER:Show(BombTimer.SaveForegroundColor, color:UnpackRGB())
			end,
			width = "full"
		},
		[10] = {
			type = "slider",
			name = "Foreground Color Hue Rotation Offset",
			tooltip = "Customize the foreground color of the next timer bars in your timer sequence in degrees. (Set to 0 for no change in color.)",
			min = -359,
			default = 66,
            max = 359,
			getFunc = function() return BombTimer.SavedVariables.HueRotation end,
			setFunc = function(value)
				if value ~= BombTimer.SavedVariables.HueRotation then
					BombTimer.SavedVariables.HueRotation = value
					BombTimer.Timeline = nil
					BombTimer.UpdateTimerBarControl()
					d("BombTimer color rotation changed.")
				end
			end,
			width = "full"
		},
		[11] = {
			type = "button",
			name = "Background Color",
			tooltip = "Customize the background color of the timer bar.",
			func = function()
				local color = ZO_ColorDef:New(BombTimer.SavedVariables.ColorBackgroundR, BombTimer.SavedVariables.ColorBackgroundG, BombTimer.SavedVariables.ColorBackgroundB)
				COLOR_PICKER:Show(BombTimer.SaveBackgroundColor, color:UnpackRGB())
			end,
			width = "full"
		},
		[12] = {
			type = "button",
			name = "Flash Color",
			tooltip = "Customize the flash color of the timer bar.",
			func = function()
				local color = ZO_ColorDef:New(BombTimer.SavedVariables.ColorFlashR, BombTimer.SavedVariables.ColorFlashG, BombTimer.SavedVariables.ColorFlashB)
				COLOR_PICKER:Show(BombTimer.SaveFlashColor, color:UnpackRGB())
			end,
			width = "full"
		},
		[13] = {
			type = "button",
			name = "Font Color",
			tooltip = "Customize the font color of the countdown on the timer bar.",
			func = function()
				local color = ZO_ColorDef:New(BombTimer.SavedVariables.ColorFontR, BombTimer.SavedVariables.ColorFontG, BombTimer.SavedVariables.ColorFontB)
				COLOR_PICKER:Show(BombTimer.SaveFontColor, color:UnpackRGB())
			end,
			width = "full"
		},
		[14] = {
			type = "submenu",
			name = "Create Timer",
			tooltip = "Creates a custom Timer.",
			controls = {
				{
					type = "editbox",
					name = "Timer Name",
					tooltip = "The name that will be used in the Timer Type dropdown menu.",
					getFunc = function()
						return BombTimer.NewTimer.name
					end,
					setFunc = function(text)
						BombTimer.NewTimer.name = text
					end,
					width = "full",
				},
				{
					type = "editbox",
					name = "Ability ID",
					tooltip = "The ability ID of the ability that should trigger the timer.",
					getFunc = function() return BombTimer.NewTimer.ability end,
					setFunc = function(text)
						local num = tonumber(text)
						BombTimer.NewTimer.ability = num
					end,
					width = "full",
				},
				{
					type = "dropdown",
					name = "Ability Tracking Type",
					tooltip = "Whether the timer triggers on your ability usage or your group's ability usage.",
					choices = {"Self", "Group"},
					getFunc = function()
						if BombTimer.NewTimer.group then
							return "Group"
						else
							return "Self"
						end
					end,
					setFunc = function(text)
						if text == "Self" then
							BombTimer.NewTimer.group = false
						else
							BombTimer.NewTimer.group = true
						end
					end,
					width = "full",
				},
				{
					type = "editbox",
					name = "Timer Durations",
					tooltip = "The durations of each component of the timer sequence (in milliseconds).",
					getFunc = function()
						local str = table.concat(BombTimer.NewTimer.durations, ", ")
						return str
					end,
					setFunc = function(text)
						local parts = {}
						for part in string.gmatch(text, "([^,]+)") do
							local num = tonumber(part)
							table.insert(parts, num)
						end
						BombTimer.NewTimer.durations = parts
					end,
					width = "full",
				},
				{
					type = "button",
					name = "Save",
					tooltip = "Adds this timer to your saved variables.",
					func = function()
						for _, choice in ipairs(BombTimer.TimerTypeChoices) do
							if choice == BombTimer.NewTimer.name then
								CreateTimerStatus.desc:SetText("|cff0000A timer with this name already exists.")
								return
							end
						end
						
						if BombTimer.NewTimer.ability == nil then
							CreateTimerStatus.desc:SetText("|cff0000This ability ID is not a valid number.")
							return
						end
						
						if table.getn(BombTimer.NewTimer.durations) == 0 then
							CreateTimerStatus.desc:SetText("|cff0000This is not a valid duration list.")
							return
						end
						
						table.insert(BombTimer.AWSavedVariables.Activities, BombTimer.NewTimer)
						table.insert(BombTimer.TimerTypeChoices, BombTimer.NewTimer.name)

						local item = TimerType1.dropdown:GetSelectedItem()
						TimerType1:UpdateChoices(BombTimer.TimerTypeChoices)
						TimerType1.dropdown:SetSelectedItem(item)
						
						TimerType2:UpdateChoices(BombTimer.TimerTypeChoices)
						
						TimerType3:UpdateChoices(BombTimer.TimerTypeChoices)
						
						CreateTimerStatus.desc:SetText("|c00ff00New Timer has been saved.")
					end,
					width = "full",
				},
				{
					type = "description",
					text = "",
					reference = "CreateTimerStatus"
				},
			},
			width = "full"
		},
		[15] = {
			type = "submenu",
			name = "Edit Timer",
			tooltip = "Edits a Timer.",
			controls = {
				{
					type = "dropdown",
					name = "Timer",
					tooltip = "Choose which timer to edit.",
					choices = BombTimer.TimerTypeChoices,
					getFunc = function() return "" end,
					setFunc = function(var)						
						for i, activity in ipairs(BombTimer.AWSavedVariables.Activities) do
							if var == activity.name then
								BombTimer.EditTimer.oldName = activity.name
								BombTimer.EditTimer.name = activity.name
								BombTimer.EditTimer.ability = activity.ability
								BombTimer.EditTimer.durations = activity.durations
								BombTimer.EditTimer.group = activity.group
								
								EditName_EditBox.editbox:SetText(activity.name)
								EditAbility_EditBox.editbox:SetText(activity.ability)
								
								local strTrackingType
								if activity.group then
									strTrackingType = "Group"
								else
									strTrackingType = "Self"
								end
								
								EditGroup_Dropdown.dropdown:SetSelectedItem(strTrackingType)
								
								local strDurations = table.concat(activity.durations, ", ")
								
								EditDurations_EditBox.editbox:SetText(strDurations)
							end
						end
						
						d("BombTimer type changed to \"" .. var .. "\".")
					end,
					width = "full",
					reference = "TimerType2",
				},
				{
					type = "editbox",
					name = "Timer Name",
					tooltip = "The name that will be used in the Timer Type dropdown menu.",
					getFunc = function()
						return BombTimer.EditTimer.name
					end,
					setFunc = function(text)
						BombTimer.EditTimer.name = text
					end,
					width = "full",
					reference = "EditName_EditBox",
				},
				{
					type = "editbox",
					name = "Ability ID",
					tooltip = "The ability ID of the ability that should trigger the timer.",
					getFunc = function() return BombTimer.EditTimer.ability end,
					setFunc = function(text)
						local num = tonumber(text)
						BombTimer.EditTimer.ability = num
					end,
					width = "full",
					reference = "EditAbility_EditBox",
				},
				{
					type = "dropdown",
					name = "Ability Tracking Type",
					tooltip = "Whether the timer triggers on your ability usage or your group's ability usage.",
					choices = {"Self", "Group"},
					getFunc = function()
						if BombTimer.EditTimer.group then
							return "Group"
						else
							return "Self"
						end
					end,
					setFunc = function(text)
						if text == "Self" then
							BombTimer.EditTimer.group = false
						else
							BombTimer.EditTimer.group = true
						end
					end,
					width = "full",
					reference = "EditGroup_Dropdown",
				},
				{
					type = "editbox",
					name = "Timer Durations",
					tooltip = "The durations of each component of the timer sequence.",
					getFunc = function()
						local str = table.concat(BombTimer.EditTimer.durations, ", ")
						return str
					end,
					setFunc = function(text)
						local parts = {}
						for part in string.gmatch(text, "([^,]+)") do
							local num = tonumber(part)
							table.insert(parts, num)
						end
						BombTimer.EditTimer.durations = parts
					end,
					width = "full",
					reference = "EditDurations_EditBox",
				},
				{
					type = "button",
					name = "Save",
					tooltip = "Saves the changes to this timer to your saved variables.",
					func = function()
						for _, choice in ipairs(BombTimer.TimerTypeChoices) do
							if choice == BombTimer.EditTimer.name and BombTimer.EditTimer.name ~= BombTimer.EditTimer.oldName then
								EditTimerStatus.desc:SetText("|cff0000A timer with this name already exists.")
								return
							end
						end
						
						if BombTimer.EditTimer.ability == nil then
							EditTimerStatus.desc:SetText("|cff0000This ability ID is not a valid number.")
							return
						end
						
						if table.getn(BombTimer.EditTimer.durations) == 0 then
							EditTimerStatus.desc:SetText("|cff0000This is not a valid duration list.")
							return
						end
						
						local j
						for i, activity in ipairs(BombTimer.AWSavedVariables.Activities) do
							if BombTimer.EditTimer.oldName == activity.name then
								j = i
								activity.name = BombTimer.EditTimer.name
								activity.ability = BombTimer.EditTimer.ability
								activity.durations = BombTimer.EditTimer.durations
								activity.group = BombTimer.EditTimer.group
							end
						end
						
						BombTimer.TimerTypeChoices[j] = BombTimer.EditTimer.name
						local item1 = TimerType1.dropdown:GetSelectedItem()
						TimerType1:UpdateChoices(BombTimer.TimerTypeChoices)
						if item1 == BombTimer.EditTimer.oldName then
							item1 = BombTimer.EditTimer.name
							BombTimer.SavedVariables.TimerType = BombTimer.EditTimer.name
							BombTimer.Timeline = nil
							BombTimer.AbilityId = BombTimer.EditTimer.ability
							BombTimer.TimerDurations = BombTimer.EditTimer.durations
							BombTimer.GroupTrigger = BombTimer.EditTimer.group
						end
						TimerType1.dropdown:SetSelectedItem(item1)
						
						TimerType2:UpdateChoices(BombTimer.TimerTypeChoices)
						TimerType2.dropdown:SetSelectedItem(BombTimer.EditTimer.name)
						
						TimerType3:UpdateChoices(BombTimer.TimerTypeChoices)
						
						EditTimerStatus.desc:SetText("|c00ff00Timer has been edited.")
					end,
					width = "full",
				},
				{
					type = "description",
					text = "",
					reference = "EditTimerStatus"
				},
			},
			width = "full"
		},
		[16] = {
			type = "submenu",
			name = "Delete Timer",
			tooltip = "Deletes a Timer.",
			controls = {
				{
					type = "dropdown",
					name = "Timer",
					tooltip = "Choose which timer to delete.",
					choices = BombTimer.TimerTypeChoices,
					getFunc = function() return "" end,
					setFunc = function(var)						
						BombTimer.DeleteTimer.name = var
					end,
					width = "full",
					reference = "TimerType3",
				},
				{
					type = "button",
					name = "Delete",
					tooltip = "Deletes this timer from your saved variables.",
					func = function()
						local j
						for i, activity in ipairs(BombTimer.AWSavedVariables.Activities) do
							if BombTimer.DeleteTimer.name == activity.name then
								j = i
							end
						end
						
						table.remove(BombTimer.AWSavedVariables.Activities, j)
						table.remove(BombTimer.TimerTypeChoices, j)
						
						local item1 = TimerType1.dropdown:GetSelectedItem()
						TimerType1:UpdateChoices(BombTimer.TimerTypeChoices)
						if item1 == BombTimer.DeleteTimer.name then
							item1 = ""
							BombTimer.SavedVariables.TimerType = ""
							BombTimer.Timeline = nil
							BombTimer.AbilityId = nil
							BombTimer.TimerDurations = {}
							BombTimer.GroupTrigger = false
						end
						TimerType1.dropdown:SetSelectedItem(item1)
						
						TimerType2:UpdateChoices(BombTimer.TimerTypeChoices)

						TimerType3:UpdateChoices(BombTimer.TimerTypeChoices)
						
						DeleteTimerStatus.desc:SetText("|c00ff00Timer has been deleted.")
					end,
					width = "full",
				},
				{
					type = "description",
					text = "",
					reference = "DeleteTimerStatus"
				},
			},
			width = "full"
		},
		[17] = {
			type = "divider",
			width = "full"
		},
		[18] = {
			type = "button",
			name = "Donate Gold",
			tooltip = "To support something.",
			func = function()
				if GetWorldName() == "NA Megaserver" then
					SCENE_MANAGER:Show('mailSend')
					zo_callLater(
						function()
							ZO_MailSendToField:SetText("@Citats")
							ZO_MailSendSubjectField:SetText("Donation")
							QueueMoneyAttachment(1)
							ZO_MailSendBodyField:TakeFocus() 
						end, 
					200)
				else
					CHAT_SYSTEM:Maximize()
					d("Oh noe! We are on different servers.")
				end
			end,
			width = "full",
		},
	}
	LAM:RegisterOptionControls(panelName, optionsData)
end

function BombTimer.OnAddOnLoaded(event, addonName)
	if addonName == BombTimer.name then
		BombTimer.Initialize()
		BombTimer.LoadSettings()

		EVENT_MANAGER:UnregisterForEvent(BombTimer.name, EVENT_ADD_ON_LOADED)
	end
end

function BombTimer.OnPlayerActivated(eventCode, initial)
	if BombTimer.Locked then
		BombTimer.TimerBar:SetHidden(true)
	end
end

function BombTimer.Initialize()
	EVENT_MANAGER:RegisterForEvent(BombTimer.name, EVENT_EFFECT_CHANGED, BombTimer.OnEffectChanged)
	--EVENT_MANAGER:RegisterForEvent(BombTimer.name, EVENT_COMBAT_EVENT, BombTimer.OnCombatEvent)
	local myDefaults = {}
	myDefaults.TimerType = "Shalks Timer - DD"
	myDefaults.OffsetX = 0
	myDefaults.OffsetY = 110
	myDefaults.Width = 100
	myDefaults.Height = 25
	myDefaults.ColorForegroundR = 1
	myDefaults.ColorForegroundG = 0
	myDefaults.ColorForegroundB = 0
	myDefaults.ColorBackgroundR = 0.1
	myDefaults.ColorBackgroundG = 0.1
	myDefaults.ColorBackgroundB = 0.1
	myDefaults.ColorFlashR = 1
	myDefaults.ColorFlashG = 1
	myDefaults.ColorFlashB = 1
	myDefaults.ColorFontR = 1
	myDefaults.ColorFontG = 1
	myDefaults.ColorFontB = 1
	myDefaults.HueRotation = 66
	myDefaults.Countdown = true
	myDefaults.FontStyle = "Medium + Outline"
	myDefaults.CustomTimerDuration = 8750
	myDefaults.CustomAbilityId = 86015
	myDefaults.GroupTriggerSensitivity = 500
	myDefaults.Combine = true
	BombTimer.TimerIsActive = false
	BombTimer.Locked = true
	BombTimer.GroupTrigger = false
	BombTimer.Time1 = -1
	BombTimer.Time2 = -1
	BombTimer.LastRestart = -1
	BombTimer.TimerStep = 0
	BombTimer.NewTimer = {}
	BombTimer.NewTimer.name = "Custom Timer 1"
	BombTimer.NewTimer.ability = 86015
	BombTimer.NewTimer.group = false
	BombTimer.NewTimer.durations = {6350,2150}
	BombTimer.EditTimer = {}
	BombTimer.EditTimer.name = ""
	BombTimer.EditTimer.ability = nil
	BombTimer.EditTimer.group = false
	BombTimer.EditTimer.durations = {}
	BombTimer.DeleteTimer = {}
	BombTimer.DeleteTimer.name = ""
	BombTimer.SavedVariables = ZO_SavedVars:NewCharacterIdSettings("BombTimerSavedVariables", 1.0, nil, myDefaults, GetWorldName())
	BombTimer.AWSavedVariables = ZO_SavedVars:NewAccountWide("BombTimerSavedVariables", 1.0, nil, nil, GetWorldName())
	
	--/script BombTimer.AWSavedVariables.Activities = nil
	if BombTimer.AWSavedVariables.Activities == nil then
		BombTimer.AWSavedVariables.Activities = {}
		BombTimer.AWSavedVariables.Activities[1] = 
			{
				name = "Shalks Timer - DD (DB)",
				ability = 86015,
				group = false,
				durations = {5500, 2850}
			}
		BombTimer.AWSavedVariables.Activities[2] = 
			{
				name = "Shalks Timer - DD (Cres)",
				ability = 86015,
				group = false,
				durations = {5500, 2950}
			}
		BombTimer.AWSavedVariables.Activities[3] = 
			{
				name = "Proxy Timer - Solo",
				ability = 61500,
				group = false,
				durations = {6250}
			}
		BombTimer.AWSavedVariables.Activities[4] = 
			{
				name = "Proxy Timer - Lead",
				ability = 61500,
				group = false,
				durations = {4500, 2500}
			}
		BombTimer.AWSavedVariables.Activities[5] = 
			{
				name = "Group Timer - Lead",
				ability = 86015,
				group = true,
				durations = {5500, 2500}
			}
		BombTimer.AWSavedVariables.Activities[6] = 
			{
				name = "Group Timer - Inner Fire",
				ability = 86015,
				group = true,
				durations = {4000}
			}
		BombTimer.AWSavedVariables.Activities[7] = 
			{
				name = "Group Timer - Runic",
				ability = 86015,
				group = true,
				durations = {6000}
			}
		BombTimer.AWSavedVariables.Activities[8] = 
			{
				name = "Group Timer - Fulminating",
				ability = 86015,
				group = true,
				durations = {7000}
			}
		BombTimer.AWSavedVariables.Activities[9] = 
			{
				name = "Group Timer - DD (DB)",
				ability = 86015,
				group = true,
				durations = {5500, 2850}
			}
		BombTimer.AWSavedVariables.Activities[10] = 
			{
				name = "Potl Timer - Solo",
				ability = 21763,
				group = false,
				durations = {5000}
			}
		BombTimer.AWSavedVariables.Activities[11] = 
			{
				name = "Shalks+Curse Timer - DD (DB)",
				ability = 86015,
				group = false,
				durations = {5250, 3100}
			}
		BombTimer.AWSavedVariables.Activities[12] = 
			{
				name = "Shalks+Inhale Timer - DD (DB)",
				ability = 86015,
				group = false,
				durations = {6350, 2150}
			}
	end
	 
	BombTimer.TimerTypeChoices = {}
	for i, activity in ipairs(BombTimer.AWSavedVariables.Activities) do
		BombTimer.TimerTypeChoices[i] = activity.name
		if BombTimer.SavedVariables.TimerType == activity.name then
			BombTimer.AbilityId = activity.ability
			BombTimer.TimerDurations = activity.durations
			BombTimer.GroupTrigger = activity.group
		end
	end
	
	BombTimer.CreateTimerBarControl()
end

function BombTimer.CreateTimerBarControl()
	local wm = WINDOW_MANAGER
	BombTimer.TLW = wm:CreateTopLevelWindow("BombTimerTLW")
	BombTimer.TimerBar = wm:CreateControl("BombTimerBar", BombTimer.TLW, CT_CONTROL)
	BombTimer.TimerBar:SetHidden(true)
	BombTimer.TimerBar:ClearAnchors()
	BombTimer.TimerBar:SetAnchor(CENTER, GuiRoot, CENTER, BombTimer.SavedVariables.OffsetX, BombTimer.SavedVariables.OffsetY)
	BombTimer.TimerBar:SetDimensions(BombTimer.SavedVariables.Width * 2, BombTimer.SavedVariables.Height * 2)
	
	BombTimer.TimerBar.Container = wm:CreateControl("BombTimerBarContainer", BombTimer.TimerBar, CT_BACKDROP)
	BombTimer.TimerBar.Container:SetAnchor(CENTER, BombTimer.TimerBar, CENTER, 0, 0)
	BombTimer.TimerBar.Container:SetDimensions(BombTimer.SavedVariables.Width * 2, BombTimer.SavedVariables.Height * 2)
	BombTimer.TimerBar.Container:SetCenterColor(BombTimer.SavedVariables.ColorBackgroundR, BombTimer.SavedVariables.ColorBackgroundG, BombTimer.SavedVariables.ColorBackgroundB, 1)
	BombTimer.TimerBar.Container:SetEdgeColor(0, 0, 0, 1.0)
	BombTimer.TimerBar.Container:SetEdgeTexture(nil, 1, 1, 0.1, 0.1)
	
	BombTimer.TimerBar.Container.Left = wm:CreateControl("BombTimerBarContainerLeft", BombTimer.TimerBar.Container, CT_BACKDROP)
	BombTimer.TimerBar.Container.Left:SetAnchor(LEFT, BombTimer.TimerBar.Container, LEFT, 0, 0)
	BombTimer.TimerBar.Container.Left:SetDimensions(0, BombTimer.SavedVariables.Height * 2)
	BombTimer.TimerBar.Container.Left:SetCenterColor(BombTimer.SavedVariables.ColorForegroundR, BombTimer.SavedVariables.ColorForegroundG, BombTimer.SavedVariables.ColorForegroundB, 1)
	BombTimer.TimerBar.Container.Left:SetEdgeColor(0, 0, 0, 1.0)
	BombTimer.TimerBar.Container.Left:SetEdgeTexture(nil, 1, 1, 0.1, 0.1)
	
	BombTimer.TimerBar.Container.Right = wm:CreateControl("BombTimerBarContainerRight", BombTimer.TimerBar.Container, CT_BACKDROP)
	BombTimer.TimerBar.Container.Right:SetAnchor(RIGHT, BombTimer.TimerBar.Container, RIGHT, 0, 0)
	BombTimer.TimerBar.Container.Right:SetDimensions(0, BombTimer.SavedVariables.Height * 2)
	BombTimer.TimerBar.Container.Right:SetCenterColor(BombTimer.SavedVariables.ColorForegroundR, BombTimer.SavedVariables.ColorForegroundG, BombTimer.SavedVariables.ColorForegroundB, 1)
	BombTimer.TimerBar.Container.Right:SetEdgeColor(0, 0, 0, 1.0)
	BombTimer.TimerBar.Container.Right:SetEdgeTexture(nil, 1, 1, 0.1, 0.1)
	
	BombTimer.TimerBar.Container.Front = wm:CreateControl("BombTimerBarContainerFront", BombTimer.TimerBar.Container, CT_LABEL)
	BombTimer.TimerBar.Container.Front:SetAnchor(CENTER, BombTimer.TimerBar.Container, CENTER, 0, 0)
	BombTimer.TimerBar.Container.Front:SetFont(BombTimer.GetFontStyleString())
	BombTimer.TimerBar.Container.Front:SetColor(BombTimer.SavedVariables.ColorFontR, BombTimer.SavedVariables.ColorFontG, BombTimer.SavedVariables.ColorFontB, 1)
	BombTimer.TimerBar.Container.Front:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	BombTimer.TimerBar.Container.Front:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

function BombTimer.UpdateTimerBarControl()
	BombTimer.TimerBar:ClearAnchors()
	BombTimer.TimerBar:SetAnchor(CENTER, GuiRoot, CENTER, BombTimer.SavedVariables.OffsetX, BombTimer.SavedVariables.OffsetY)
	BombTimer.TimerBar:SetDimensions(BombTimer.SavedVariables.Width * 2, BombTimer.SavedVariables.Height*2)
	BombTimer.TimerBar.Container:ClearAnchors()
	BombTimer.TimerBar.Container:SetAnchor(CENTER, BombTimer.TimerBar, CENTER, 0, 0)
	BombTimer.TimerBar.Container:SetDimensions(BombTimer.SavedVariables.Width * 2, BombTimer.SavedVariables.Height*2)
	BombTimer.TimerBar.Container.Left:ClearAnchors()
	BombTimer.TimerBar.Container.Left:SetAnchor(LEFT, BombTimer.TimerBar.Container, LEFT, 0, 0)
	BombTimer.TimerBar.Container.Left:SetDimensions(0, BombTimer.SavedVariables.Height * 2)
	BombTimer.TimerBar.Container.Right:ClearAnchors()
	BombTimer.TimerBar.Container.Right:SetAnchor(RIGHT, BombTimer.TimerBar.Container, RIGHT, 0, 0)
	BombTimer.TimerBar.Container.Right:SetDimensions(0, BombTimer.SavedVariables.Height * 2)
end

function BombTimer.GetFontStyleString()
	local fontStyle = BombTimer.SavedVariables.FontStyle
	if fontStyle == "Small" then
		return "$(MEDIUM_FONT)|$(KB_16)"
	elseif fontStyle == "Medium" then
		return "$(MEDIUM_FONT)|$(KB_32)"
	elseif fontStyle == "Large" then
		return "$(MEDIUM_FONT)|$(KB_48)"
	elseif fontStyle == "Small + Outline" then
		return "$(MEDIUM_FONT)|$(KB_16)|thick-outline"
	elseif fontStyle == "Medium + Outline" then
		return "$(MEDIUM_FONT)|$(KB_32)|thick-outline"
	elseif fontStyle == "Large + Outline" then
		return "$(MEDIUM_FONT)|$(KB_48)|thick-outline"
	else
		return "$(MEDIUM_FONT)|$(KB_32)|thick-outline"
	end
end

function BombTimer.SaveForegroundColor(r, g, b)
	BombTimer.SavedVariables.ColorForegroundR = r
	BombTimer.SavedVariables.ColorForegroundG = g
	BombTimer.SavedVariables.ColorForegroundB = b
	BombTimer.TimerBar.Container.Left:SetCenterColor(r, g, b, 1)
	BombTimer.TimerBar.Container.Right:SetCenterColor(r, g, b, 1)
	d("BombTimer foreground color saved.")
end

function BombTimer.SaveBackgroundColor(r, g, b)
	BombTimer.SavedVariables.ColorBackgroundR = r
	BombTimer.SavedVariables.ColorBackgroundG = g
	BombTimer.SavedVariables.ColorBackgroundB = b
	BombTimer.TimerBar.Container:SetCenterColor(r, g, b, 1)
	d("BombTimer background color saved.")
end

function BombTimer.SaveFlashColor(r, g, b)
	BombTimer.SavedVariables.ColorFlashR = r
	BombTimer.SavedVariables.ColorFlashG = g
	BombTimer.SavedVariables.ColorFlashB = b
	d("BombTimer flash color saved.")
end

function BombTimer.SaveFontColor(r, g, b)
	BombTimer.SavedVariables.ColorFontR = r
	BombTimer.SavedVariables.ColorFontG = g
	BombTimer.SavedVariables.ColorFontB = b
	BombTimer.TimerBar.Container.Front:SetColor(r, g, b, 1)
	d("BombTimer font color saved.")
end

function BombTimer.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if BombTimer.GroupTrigger then
		if abilityId == BombTimer.AbilityId and sourceType == 3 and (changeType == 1 or changeType == 3) and string.find(unitTag, "group") then
			BombTimer.OnGroupShalks(beginTime)
		end
	else
		if sourceType == COMBAT_UNIT_TYPE_PLAYER and abilityId == BombTimer.AbilityId and (changeType == 1 or changeType == 3) then
			BombTimer.RestartTimer(0.0)
		end
	end
end

function BombTimer.OnGroupShalks(beginTime)
	if BombTimer.LastRestart + 2.5 > beginTime then
		return
	end

	BombTimer.Time2 = BombTimer.Time1
	BombTimer.Time1 = beginTime
	
	if BombTimer.Time2 == -1 then
		return
	end
	
	if BombTimer.Time1 - BombTimer.Time2 <= (BombTimer.SavedVariables.GroupTriggerSensitivity/1000.0) then
		BombTimer.RestartTimer((beginTime - BombTimer.Time2)*1000)
		BombTimer.Time2 = -1
		BombTimer.Time1 = -1
		BombTimer.LastRestart = beginTime
	end
end

function BombTimer.RestartTimer(offsetTime)
	BombTimer.TimerIsActive = true
	BombTimer.TimerBar:SetHidden(false)
	BombTimer.TimerStep = 0
	BombTimer.AnimateTimer(offsetTime)
	if BombTimer.SavedVariables.Countdown then
		EVENT_MANAGER:RegisterForUpdate("BombTimerCountdown", 100, BombTimer.CountdownLoop)
	end
end

function BombTimer.AnimateTimer(offsetTime)
	if BombTimer.Timeline ~= nil then
		BombTimer.Timeline:Stop(2)
		BombTimer.Timeline = nil
	end
	
	BombTimer.TimerStep = BombTimer.TimerStep + 1
	
	if BombTimer.HueRotation ~= 0 then
		local h,s,v = rgb2hsv(BombTimer.SavedVariables.ColorForegroundR, BombTimer.SavedVariables.ColorForegroundG, BombTimer.SavedVariables.ColorForegroundB)
		local totalSteps = #BombTimer.TimerDurations
		local newHue = ((h + (totalSteps - BombTimer.TimerStep)*BombTimer.SavedVariables.HueRotation) % 360)/360
		local rotatedR,rotatedG,rotatedB = hsv2rgb(newHue, s, v)
	
		BombTimer.TimerBar.Container.Left:SetCenterColor(rotatedR, rotatedG, rotatedB, 1)
		BombTimer.TimerBar.Container.Right:SetCenterColor(rotatedR, rotatedG, rotatedB, 1)
	else
		BombTimer.TimerBar.Container.Left:SetCenterColor(BombTimer.SavedVariables.ColorForegroundR, BombTimer.SavedVariables.ColorForegroundG, BombTimer.SavedVariables.ColorForegroundB, 1)
		BombTimer.TimerBar.Container.Right:SetCenterColor(BombTimer.SavedVariables.ColorForegroundR, BombTimer.SavedVariables.ColorForegroundG, BombTimer.SavedVariables.ColorForegroundB, 1)
	end
	
	BombTimer.TimerBar.Container.Left:SetDimensions(0, 50)
	BombTimer.TimerBar.Container.Right:SetDimensions(0, 50)
	BombTimer.TimerBar.Container:SetCenterColor(BombTimer.SavedVariables.ColorBackgroundR, BombTimer.SavedVariables.ColorBackgroundG, BombTimer.SavedVariables.ColorBackgroundB, 1)

	BombTimer.Timeline = ANIMATION_MANAGER:CreateTimeline()
	
	local duration = 0
	if BombTimer.SavedVariables.Combine then
		for _, timerDuration in ipairs(BombTimer.TimerDurations) do
			duration = duration + timerDuration
		end
		duration = duration - offsetTime
	else
		duration = BombTimer.TimerDurations[BombTimer.TimerStep] - offsetTime
	end
	
	local animationLeft = BombTimer.Timeline:InsertAnimation(ANIMATION_SIZE, BombTimer.TimerBar.Container.Left, 0)
	animationLeft:SetStartAndEndHeight(BombTimer.SavedVariables.Height*2, BombTimer.SavedVariables.Height*2)
	animationLeft:SetStartAndEndWidth(0, BombTimer.SavedVariables.Width)
	animationLeft:SetDuration(duration)
	
	local animationRight = BombTimer.Timeline:InsertAnimation(ANIMATION_SIZE, BombTimer.TimerBar.Container.Right, 0)	
	animationRight:SetStartAndEndHeight(BombTimer.SavedVariables.Height*2, BombTimer.SavedVariables.Height*2)
	animationRight:SetStartAndEndWidth(0, BombTimer.SavedVariables.Width)
	animationRight:SetDuration(duration)
	
	BombTimer.Timeline:PlayFromStart()

	BombTimer.CurrentTimerEndTime = GetFrameTimeMilliseconds() + duration
	BombTimer.TimerBar.Container.Front:SetText("")
	
	if BombTimer.SavedVariables.Combine then
		local totalDuration = 0
		for i, timerDuration in ipairs(BombTimer.TimerDurations) do
			if i ~= #BombTimer.TimerDurations then
				BombTimer.Timeline:InsertCallback(function() BombTimer.AnimateCombinedTimer() end, totalDuration + timerDuration - offsetTime)
				totalDuration = totalDuration + timerDuration
			end
		end
	end
	
	BombTimer.Timeline:SetHandler('OnStop', function()
		BombTimer.TimerBar.Container.Left:SetDimensions(0, 50)
		BombTimer.TimerBar.Container.Right:SetDimensions(0, 50)
		
		if BombTimer.TimerStep >= #BombTimer.TimerDurations then
			BombTimer.TimerIsActive = false
			BombTimer.TimerBar.Container:SetCenterColor(BombTimer.SavedVariables.ColorFlashR, BombTimer.SavedVariables.ColorFlashG, BombTimer.SavedVariables.ColorFlashB, 1)
			if BombTimer.SavedVariables.Countdown then
				EVENT_MANAGER:UnregisterForUpdate("BombTimerCountdown")
				BombTimer.TimerBar.Container.Front:SetText("")
			end
			zo_callLater(function() BombTimer.DoFlash() end, 50)
		elseif BombTimer.TimerStep ~= 0 then
			BombTimer.AnimateTimer(0.0)
		end
	end)
end

function BombTimer.AnimateCombinedTimer()
	BombTimer.TimerStep = BombTimer.TimerStep + 1

	if BombTimer.HueRotation ~= 0 then 
		local h, s, v = rgb2hsv(BombTimer.SavedVariables.ColorForegroundR, BombTimer.SavedVariables.ColorForegroundG, BombTimer.SavedVariables.ColorForegroundB)
		local totalSteps = #BombTimer.TimerDurations
		local newHue = ((h + (totalSteps - BombTimer.TimerStep)*BombTimer.SavedVariables.HueRotation) % 360)/360
		local rotatedR, rotatedG, rotatedB = hsv2rgb(newHue, s, v)

		BombTimer.TimerBar.Container.Left:SetCenterColor(rotatedR, rotatedG, rotatedB, 1)
		BombTimer.TimerBar.Container.Right:SetCenterColor(rotatedR, rotatedG, rotatedB, 1)
	end
end

function BombTimer.CountdownLoop()
	local now = GetFrameTimeMilliseconds()
	local remaining = BombTimer.CurrentTimerEndTime - now
	if remaining < 0 then
		BombTimer.TimerBar.Container.Front:SetText("")
	else
		local floorRemaining = remaining / 1000
		BombTimer.TimerBar.Container.Front:SetText(string.format("%.1f", floorRemaining))
	end
end

function BombTimer.DoFlash()
	BombTimer.TimerBar.Container:SetCenterColor(BombTimer.SavedVariables.ColorBackgroundR, BombTimer.SavedVariables.ColorBackgroundG, BombTimer.SavedVariables.ColorBackgroundB, 1)
	zo_callLater(function() BombTimer.DoFlash2() end, 50)
end

function BombTimer.DoFlash2()
	BombTimer.TimerBar.Container:SetCenterColor(BombTimer.SavedVariables.ColorFlashR, BombTimer.SavedVariables.ColorFlashG, BombTimer.SavedVariables.ColorFlashB, 1)
	zo_callLater(function() BombTimer.DoFlash3() end, 50)
end

function BombTimer.DoFlash3()
	BombTimer.TimerBar.Container:SetCenterColor(BombTimer.SavedVariables.ColorBackgroundR, BombTimer.SavedVariables.ColorBackgroundG, BombTimer.SavedVariables.ColorBackgroundB, 1)
	zo_callLater(function() BombTimer.DoHide() end, 250)
end

function BombTimer.DoHide()
	if not BombTimer.TimerIsActive and BombTimer.Locked then
		BombTimer.TimerBar:SetHidden(true)
	end
end

function rgb2hsv(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v

    v = max

    local delta = max - min

    if max == 0 then
        s = 0
    else
        s = delta / max
    end

    if delta == 0 then
        h = 0
    else
        if r == max then
            h = (g - b) / delta
        elseif g == max then
            h = (b - r) / delta + 2
        else
            h = (r - g) / delta + 4
        end
        h = h * 60
        if h < 0 then
            h = h + 360
        end
    end

    return h, s, v
end

function hsv2rgb(h, s, v)
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6

    if i == 0 then
        r, g, b = v, t, p
    elseif i == 1 then
        r, g, b = q, v, p
    elseif i == 2 then
        r, g, b = p, v, t
    elseif i == 3 then
        r, g, b = p, q, v
    elseif i == 4 then
        r, g, b = t, p, v
    elseif i == 5 then
        r, g, b = v, p, q
    end

    return r, g, b
end

EVENT_MANAGER:RegisterForEvent(BombTimer.name, EVENT_ADD_ON_LOADED, BombTimer.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(BombTimer.name, EVENT_PLAYER_ACTIVATED, BombTimer.OnPlayerActivated)