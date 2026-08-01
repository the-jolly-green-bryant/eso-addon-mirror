AUI.FrameMover = {}

local isLoaded = false
local windows = nil
local defaultAnchors = {}
local inputMode = 1
local isPreviewShowing = false

local inputModes = 
{
	["keyboard"] = 1,
	["gamepad"] = 2,
}

local function OnFrameMouseDown(_button, _ctrl, _alt, _shift, _frame)
	if _button == 1 then
		_frame:SetMovable(true)
		_frame:StartMoving()
	end
end

local function OnFrameMouseUp(_button, _ctrl, _alt, _shift, _frame)	
	_frame:SetMovable(false)		
	_, AUI.Settings.FrameMover.anchors[_frame.windowName][inputMode].anchor.point, _, AUI.Settings.FrameMover.anchors[_frame.windowName][inputMode].anchor.relativePoint, AUI.Settings.FrameMover.anchors[_frame.windowName][inputMode].anchor.offsetX, AUI.Settings.FrameMover.anchors[_frame.windowName][inputMode].anchor.offsetY = _frame:GetAnchor()

	AUI.FrameMover.SetWindowPosition(_frame.data)	
end	

local function SetDefaultAnchors()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.FrameMover.SetDefaultAnchors")
	end
	--/DebugMessage--	

	for windowName, windowData in pairs(windows) do
		local data = windowData[inputMode]
		
		if not data.defaultAnchor then
			if data.anchor then
				data.defaultAnchor = data.anchor
			else
				data.defaultAnchor = {}
				_, data.defaultAnchor.point, _, data.defaultAnchor.relativePoint, data.defaultAnchor.offsetX, data.defaultAnchor.offsetY = data.originalControl:GetAnchor()
			end
		end
	end	
end

local function UpdateWindow(_windowData)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.FrameMover.UpdateWindow")
	end
	--/DebugMessage--

	 if _windowData.customFunction and type(_windowData.customFunction) == "function" then
		_windowData.customFunction(_windowData)
	 end

	if not _windowData.width then
		_windowData.mainControl:SetWidth(_windowData.originalControl:GetWidth())
	else
		_windowData.mainControl:SetWidth(_windowData.width)
	end

	if not _windowData.height then
		_windowData.mainControl:SetHeight(_windowData.originalControl:GetHeight())
	else
		_windowData.mainControl:SetHeight(_windowData.height)
	end	

	AUI.FrameMover.SetWindowPosition(_windowData)	
end

function CreateWindows()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.FrameMover.CreateWindows")
	end
	--/DebugMessage--

	windows = {
		["synergy"] = {
			[1] = {
				["originalControl"] = ZO_SynergyTopLevelContainer,
				["text"] = "Synergy",	
				["anchor"] = {
					["point"] = CENTER,
					["relativePoint"] = CENTER,
					["offsetX"] = 0,
					["offsetY"] = 270,
				},					
			},
			[2] = {
				["originalControl"] = ZO_SynergyTopLevelContainer,
				["text"] = "Synergy",
				["anchor"] = {
					["point"] = CENTER,
					["relativePoint"] = CENTER,
					["offsetX"] = 0,
					["offsetY"] = 270,
				},				
			},			
		},
		["compass"] = {
			[1] = {
				["originalControl"] = ZO_CompassFrame,
				["text"] = "Compass",	
				["anchor"] = {
					["point"] = TOP,
					["relativePoint"] = TOP,
					["offsetX"] = 0,
					["offsetY"] = 40,
				},					
			},
			[2] = {
				["originalControl"] = ZO_CompassFrame,
				["text"] = "Compass",
				["anchor"] = {
					["point"] = TOP,
					["relativePoint"] = TOP,
					["offsetX"] = 0,
					["offsetY"] = 58,
				},					
			},		
		},
		["skillbar"] = {
			[1] = {
				["originalControl"] = ZO_ActionBar1,
				["text"] = "Action Bar",	
				["anchor"] = {
					["point"] = BOTTOM,
					["relativePoint"] = BOTTOM,
					["offsetX"] = 0,
					["offsetY"] = 0,
				},					
			},
			[2] = {
				["originalControl"] = ZO_ActionBar1,
				["text"] = "Action Bar",
				["anchor"] = {
					["point"] = BOTTOM,
					["relativePoint"] = BOTTOM,
					["offsetX"] = 0,
					["offsetY"] = -25,
				},					
			},					
		},
		["alert_text"] = {
			[1] = {
				["originalControl"] = ZO_AlertTextNotification,
				["text"] = "Alert Text Notifications",	
				["width"] = 600,
				["height"] = 56,									
			},
			[2] = {
				["originalControl"] = ZO_AlertTextNotificationGamepad,
				["text"] = "Alert Text Notifications",	
				["width"] = 600,
				["height"] = 112,				
			},					
		},
		["player_progress"] = {
			[1] = {
				["originalControl"] = ZO_PlayerProgress,
				["text"] = "Experience Bar",										
			},
			[2] = {
				["originalControl"] = ZO_PlayerProgress,
				["text"] = "Experience Bar",				
			},					
		},	
		["equipment_status"] = {
			[1] = {
				["originalControl"] = ZO_HUDEquipmentStatus,
				["text"] = "Equipment Status",										
			},
			[2] = {
				["originalControl"] = ZO_HUDEquipmentStatus,
				["text"] = "Equipment Status",				
			},					
		},		
		["ptp_area_prompt_container"] = {
			[1] = {
				["originalControl"] = ZO_PlayerToPlayerAreaPromptContainer,
				["text"] = "Player Interaction Prompt",		
				["height"] = 30,		
			},
			[2] = {
				["originalControl"] = ZO_PlayerToPlayerAreaPromptContainer,
				["text"] = "Player Interaction Prompt",	
				["height"] = 30,					
			},					
		},	
		["center_screen_announce"] = {
			[1] = {
				["originalControl"] = ZO_CenterScreenAnnounce,
				["text"] = "On-Screen Notifications",	
				["height"] = 100,				
			},
			[2] = {
				["originalControl"] = ZO_CenterScreenAnnounce,
				["text"] = "On-Screen Notifications",	
				["height"] = 100,				
			},					
		},
		["battle_ground_meter"] = {
		  [1] = {
        ["originalControl"] = ZO_BattlegroundHUDFragmentTopLevel,
        ["text"] = "Battleground alliance meter", 
        ["height"] = 200,       
        ["width"] = 200,
        ["anchor"] = {
          ["point"] = TOPRIGHT,
          ["relativePoint"] = TOPRIGHT,
          ["offsetX"] = 0,
          ["offsetY"] = 200,
        },      
      },
      [2] = {
        ["originalControl"] = ZO_BattlegroundHUDFragmentTopLevel,
        ["text"] = "Battleground alliance meter", 
        ["height"] = 200,       
        ["width"] = 200,
        ["anchor"] = {
          ["point"] = TOPRIGHT,
          ["relativePoint"] = TOPRIGHT,
          ["offsetX"] = 0,
          ["offsetY"] = 200,
        },      
      },    
		},
		["infamy_meter"] = {
			[1] = {
				["originalControl"] = ZO_HUDInfamyMeter,
				["text"] = "Bounty Display",										
			},
			[2] = {
				["originalControl"] = ZO_HUDInfamyMeter,
				["text"] = "Bounty Display",				
			},					
		},	
		["telvar_meter"] = {
			[1] = {
				["originalControl"] = ZO_HUDTelvarMeter,
				["text"] = "Tel Var Display",										
			},
			[2] = {
				["originalControl"] = ZO_HUDTelvarMeter,
				["text"] = "Tel Var Display",				
			},					
		},
		["active_combat_tips_tip"] = {
			[1] = {
				["originalControl"] = ZO_ActiveCombatTipsTip,
				["text"] = "Active Combat Tips",	
				["width"] = 250,
				["height"] = 20,	
				["anchor"] = {
					["point"] = CENTER,
					["relativePoint"] = CENTER,
					["offsetX"] = 0,
					["offsetY"] = 340,
				},						
			},
			[2] = {
				["originalControl"] = ZO_ActiveCombatTipsTip,
				["text"] = "Active Combat Tips",	
				["width"] = 250,
				["height"] = 20,
				["anchor"] = {
					["point"] = CENTER,
					["relativePoint"] = CENTER,
					["offsetX"] = 0,
					["offsetY"] = 340,
				},				
			},					
		},		
		["tutorial_hud_info_tip_keyboard"] = {
			[1] = {
				["originalControl"] = ZO_TutorialHudInfoTipKeyboard,
				["text"] = "Tutorials",										
			},
			[2] = {
				["originalControl"] = ZO_TutorialHudInfoTipGamepad,
				["text"] = "Tutorials",				
			},					
		},	
		["objective_capture_meter"] = {
			[1] = {
				["originalControl"] = ZO_ObjectiveCaptureMeter,
				["text"] = "AvA Capture Meter",	
				["width"] = 128,
				["height"] = 128,					
			},
			[2] = {
				["originalControl"] = ZO_ObjectiveCaptureMeter,
				["text"] = "AvA Capture Meter",		
				["width"] = 128,
				["height"] = 128,					
			},					
		},	
		["loot_history_control_keyboard"] = {
			[1] = {
				["originalControl"] = ZO_LootHistoryControl_Keyboard,
				["text"] = "Loot History",				
				["width"] = 280,
				["height"] = 400,						
			},
			[2] = {
				["originalControl"] = ZO_LootHistoryControl_Keyboard,
				["text"] = "Loot History",	
				["width"] = 280,
				["height"] = 400,				
			},					
		},		
		--["subtitles"] = {
		--	[1] = {
		--		["originalControl"] = ZO_Subtitles,
		--		["text"] = "Subtitles",	
		--		["width"] = 256,
		--		["height"] = 80,					
		--	},
		--	[2] = {
		--		["originalControl"] = ZO_Subtitles,
		--		["text"] = "Subtitles",		
		--		["width"] = 256,
		--		["height"] = 80,					
		--	},					
		--},			
	}
	
	if not AUI.Questtracker.IsEnabled() then
		windows["focusedquesttracker"] = {
			[1] = {
				["originalControl"] = ZO_FocusedQuestTrackerPanel,
				["text"] = "Focused Quest Tracker",
				["height"] = 250,	
				["anchor"] = {
					["point"] = TOPRIGHT,
					["relativePoint"] = TOPRIGHT,
					["offsetX"] = 0,
					["offsetY"] = 100,
				},					
			},
			[2] = {
				["originalControl"] = ZO_FocusedQuestTrackerPanel,
				["text"] = "Focused Quest Tracker",
				["height"] = 250,	
				["anchor"] = {
					["point"] = TOPRIGHT,
					["relativePoint"] = TOPRIGHT,
					["offsetX"] = 0,
					["offsetY"] = 100,
				},					
			},	
		}		
	end
	
	if not AUI.Attributes.Group.IsEnabled() then
		windows["groupframe"] = {
			[1] = {
				["originalControl"] = ZO_SmallGroupAnchorFrame,
				["text"] = "Group Frames",				
			},
			[2] = {
				["originalControl"] = ZO_SmallGroupAnchorFrame,
				["text"] = "Group Frames",				
			},					
		}	

		local offsetXKeyboard = 5
		local offsetXGamepad = 5		
		
		for i = 1, 6 do
			local controlName = "ZO_LargeGroupAnchorFrame" .. i
			local control = _G[controlName]
		
			windows["raidframe" .. i] = {
				[1] = {
					["originalControl"] = control,
					["text"] = "Raid " .. i, 					
				},
				[2] = {
					["originalControl"] = control,
					["text"] = "Raid " .. i, 					
				},								
			}	

			offsetXKeyboard = offsetXKeyboard + 80
			offsetXGamepad = offsetXGamepad + 80
		end			
	end
	
	for windowName, windowData in pairs(windows) do
		for inputModeName, inputModeID in pairs(inputModes) do
			local data = windowData[inputModeID]
		
			local mainControl = CreateControlFromVirtual("AUI_FrameMover_Window_" .. windowName .. inputModeName, AUI_FrameMover, "AUI_FrameMover_Window")
			mainControl:SetHandler("OnMouseDown", function(_eventCode, _button, _ctrl, _alt, shift) OnFrameMouseDown(_button, _ctrl, _alt, _shift, mainControl) end)
			mainControl:SetHandler("OnMouseUp", function(_eventCode, _button, _ctrl, _alt, shift) OnFrameMouseUp(_button, _ctrl, _alt, _shift, mainControl) end)	
			mainControl.windowName = windowName
			
			local text = GetControl(mainControl, "_Text") 
			text:SetFont("$(BOLD_FONT)|" ..  18 .. "|" .. "thick-outline")
			text:SetText(data.text)	
			
			mainControl.data = data	
			data.mainControl = mainControl		
		end					
	end	
end

local function SetInputMode()
	if IsInGamepadPreferredMode() then
		inputMode = 2
	else
		inputMode = 1
	end	
	
	SetDefaultAnchors()
end

function AUI.FrameMover.SetToDefaultPosition()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.FrameMover.SetToDefaultPosition")
	end
	--/DebugMessage--

	for windowName, windowData in pairs(windows) do	
		local data = windowData[inputMode]
		
		AUI.Settings.FrameMover.anchors[windowName][inputMode].anchor = AUI.Table.Copy(data.defaultAnchor)
	end

	AUI.FrameMover.UpdateAll()
end

function AUI.FrameMover.IsLoaded()
	if isLoaded then
		return true
	end
	
	return false
end

function AUI.FrameMover.IsPreviewShowing()
	return isPreviewShowing
end

function AUI.FrameMover.ShowPreview(_show)
	if _show then
		AUI.FrameMover.ShowAllWindows()
	else
		AUI.FrameMover.HideAllWindows()
	end
	
	isPreviewShowing = _show
end

function AUI.FrameMover.ShowAllWindows()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.FrameMover.ShowAllWindows")
	end
	--/DebugMessage--

	for windowName, windowData in pairs(windows) do	
		local data = windowData[inputMode]
	
		data.mainControl:SetHidden(false)
		data.mainControl:SetMouseEnabled(true)
	end
end

function AUI.FrameMover.HideAllWindows()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.FrameMover.HideAllWindows")
	end
	--/DebugMessage--

	for windowName, windowData in pairs(windows) do	
		local data = windowData[inputMode]
	
		data.mainControl:SetHidden(true)
		data.mainControl:SetMouseEnabled(false)
	end
end

function AUI.FrameMover.SetWindowPosition(_windowData)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.FrameMover.SetWindowPosition")
	end
	--/DebugMessage--

	local frame = _windowData.mainControl

	_windowData.mainControl:ClearAnchors()
	_windowData.mainControl:SetAnchor(AUI.Settings.FrameMover.anchors[frame.windowName][inputMode].anchor.point, GuiRoot, AUI.Settings.FrameMover.anchors[frame.windowName][inputMode].anchor.relativePoint, AUI.Settings.FrameMover.anchors[frame.windowName][inputMode].anchor.offsetX, AUI.Settings.FrameMover.anchors[frame.windowName][inputMode].anchor.offsetY)	

	_windowData.originalControl:ClearAnchors()
	_windowData.originalControl:SetAnchor(AUI.Settings.FrameMover.anchors[frame.windowName][inputMode].anchor.point, GuiRoot, AUI.Settings.FrameMover.anchors[frame.windowName][inputMode].anchor.relativePoint, AUI.Settings.FrameMover.anchors[frame.windowName][inputMode].anchor.offsetX, AUI.Settings.FrameMover.anchors[frame.windowName][inputMode].anchor.offsetY)
end

function AUI.FrameMover.UpdateAll()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.FrameMover.UpdateAll")
	end
	--/DebugMessage--
	
	for windowName, windowData in pairs(windows) do
		local data = windowData[inputMode]
	
		if not AUI.Settings.FrameMover.anchors then
			AUI.Settings.FrameMover.anchors = {}
		end		
	
		if not AUI.Settings.FrameMover.anchors[windowName] then
			AUI.Settings.FrameMover.anchors[windowName] = {}
		end		
	
		if not AUI.Settings.FrameMover.anchors[windowName][inputMode] then
			AUI.Settings.FrameMover.anchors[windowName][inputMode] = {}
			AUI.Settings.FrameMover.anchors[windowName][inputMode].anchor = AUI.Table.Copy(data.defaultAnchor)
		end		
	
		UpdateWindow(data)
	end
end

function AUI.FrameMover.OnGamepadPreferredModeChanged(_gamepadPreferred)
	AUI.FrameMover.HideAllWindows()
	SetInputMode()
	AUI.FrameMover.UpdateAll()
	
	if isPreviewShowing then
		AUI.FrameMover.ShowAllWindows()
	end
end

function AUI.FrameMover.OnPlayerActivated()
	if isLoaded then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.FrameMover.OnPlayerActivated")
	end
	--/DebugMessage--	
	
	CreateWindows()
	AUI.FrameMover.SetMenuData()
	SetInputMode()
	AUI.FrameMover.UpdateAll() 
	
	isLoaded = true
end