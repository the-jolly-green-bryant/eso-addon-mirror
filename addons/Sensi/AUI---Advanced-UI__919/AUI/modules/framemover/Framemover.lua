AUI.FrameMover = {}
 
local g_isInit = false
local g_windows = nil
local g_isPreviewShowing = false
local g_currentInputMode = 1
 
local function OnFrameMouseDown(_button, _ctrl, _alt, _shift, _frame)
    if _button == MOUSE_BUTTON_INDEX_LEFT then
        _frame:SetMovable(true)
        _frame:StartMoving()
    end
end
 
local function OnFrameMouseUp(_button, _ctrl, _alt, _shift, _frame)
    _frame:SetMovable(false)
    _, AUI.Settings.FrameMover.anchors[_frame.windowName][g_currentInputMode].point, _, AUI.Settings.FrameMover.anchors[_frame.windowName][g_currentInputMode].relativePoint, AUI.Settings.FrameMover.anchors[_frame.windowName][g_currentInputMode].offsetX, AUI.Settings.FrameMover.anchors[_frame.windowName][g_currentInputMode].offsetY = _frame:GetAnchor()
    AUI.Settings.FrameMover.anchors[_frame.windowName][g_currentInputMode].anchorTo = nil
	
    AUI.FrameMover.SetWindowPosition(_frame.windowData, GuiRoot)
end
 
local function CreateWindows()
    local windows = {
        ["synergy"] = {
            [1] = {
                ["originalControl"] = ZO_SynergyTopLevelContainer,
                ["text"] = "Synergy",
                ["default_anchor"] = {
                    ["point"] = CENTER,
                    ["relativePoint"] = CENTER,
                    ["offsetX"] = 0,
                    ["offsetY"] = 250,
                },
            },
            [2] = {
                ["originalControl"] = ZO_SynergyTopLevelContainer,
                ["text"] = "Synergy",
                ["default_anchor"] = {
                    ["point"] = CENTER,
                    ["relativePoint"] = CENTER,
                    ["offsetX"] = 0,
                    ["offsetY"] = 250,
                },
            },
        },
        ["compass"] = {
            [1] = {
                ["originalControl"] = ZO_CompassFrame,
                ["text"] = "Compass",
            },
            [2] = {
                ["originalControl"] = ZO_CompassFrame,
                ["text"] = "Compass",
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
                ["default_anchor"] = {
                    ["point"] = LEFT,
                    ["anchorTo"] = "ZO_ActionBar1",
                    ["relativePoint"] = RIGHT,
                    ["offsetX"] = 54,
                    ["offsetY"] = -8,
                },
            },
            [2] = {
                ["originalControl"] = ZO_HUDEquipmentStatus,
                ["text"] = "Equipment Status",
                ["default_anchor"] = {
                    ["point"] = LEFT,
                    ["anchorTo"] = "ZO_ActionBar1",
                    ["relativePoint"] = RIGHT,
                    ["offsetX"] = 200,
                    ["offsetY"] = 0,
                },
            },
        },
        ["ptp_area_prompt_container"] = {
            [1] = {
                ["originalControl"] = ZO_PlayerToPlayerAreaPromptContainer,
                ["text"] = "Player Interaction Prompt",
                ["height"] = 30,
                ["default_anchor"] = {
                    ["point"] = CENTER,
                    ["relativePoint"] = CENTER,
                    ["offsetX"] = 0,
                    ["offsetY"] = 200,
                },
            },
            [2] = {
                ["originalControl"] = ZO_PlayerToPlayerAreaPromptContainer,
                ["text"] = "Player Interaction Prompt",
                ["height"] = 30,
                ["default_anchor"] = {
                    ["point"] = CENTER,
                    ["relativePoint"] = CENTER,
                    ["offsetX"] = 0,
                    ["offsetY"] = 200,
                },
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
            },
            [2] = {
                ["originalControl"] = ZO_ActiveCombatTipsTip,
                ["text"] = "Active Combat Tips",
                ["width"] = 250,
                ["height"] = 20,
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
    }

    if AUI.Actionbar.IsEnabled() then
        windows["skillbar"] = {
            [1] = {
                ["originalControl"] = ZO_ActionBar1,
                ["text"] = "Action Bar",
            },
            [2] = {
                ["originalControl"] = ZO_ActionBar1,
                ["text"] = "Action Bar",
            },
        }
    end
 
    if not AUI.Questtracker.IsEnabled() then
        windows["focusedquesttracker"] = {
            [1] = {
                ["originalControl"] = ZO_FocusedQuestTrackerPanel,
                ["text"] = "Focused Quest Tracker",
                ["height"] = 250,
                ["default_anchor"] = {
                    ["point"] = TOPRIGHT,
                    ["anchorTo"] = "ZO_EndDunHUDTracker",
                    ["relativePoint"] = BOTTOMRIGHT,
                    ["offsetX"] = 0,
                    ["offsetY"] = 0,
                },
            },
            [2] = {
                ["originalControl"] = ZO_FocusedQuestTrackerPanel,
                ["text"] = "Focused Quest Tracker",
                ["height"] = 250,
                ["default_anchor"] = {
                    ["point"] = TOPRIGHT,
                    ["anchorTo"] = "ZO_EndDunHUDTracker",
                    ["relativePoint"] = BOTTOMRIGHT,
                    ["offsetX"] = 0,
                    ["offsetY"] = 0,
                },
            },
        }
    end
 
    if not AUI.UnitFrames.Group.IsEnabled() then
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
 
        local num_subGroups = GROUP_SIZE_MAX / SMALL_GROUP_SIZE_THRESHOLD
        for i = 1, num_subGroups do
            local anchorTo = "ZO_LargeGroupAnchorFrame" .. i
            local control = _G[anchorTo]
            if control then
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
            end
        end
    end
 
    return windows
end
 
function AUI.FrameMover.SetToDefaultPosition()
    for windowName, inputData in pairs(g_windows) do
        local windowData = inputData[g_currentInputMode]
        if windowData then
            AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode] = AUI.Table.Copy(windowData.default_anchor)
        end
    end
 
    AUI.FrameMover.UpdateAll()
end
 
function AUI.FrameMover.SetWindowPosition(_windowData, anchorTo)
    local mainControl = _windowData.mainControl
    local originalControl = _windowData.originalControl
    local windowName = mainControl.windowName
 
    if mainControl and originalControl and windowName then
        local anchorToControlStr = AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode].anchorTo
 
        if anchorToControlStr and anchorToControlStr ~= "" then
            anchorTo = _G[anchorToControlStr]
        end
 
        mainControl:ClearAnchors()
        mainControl:SetAnchor(AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode].point, anchorTo, AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode].relativePoint, AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode].offsetX, AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode].offsetY)
 
        originalControl:ClearAnchors()
        originalControl:SetAnchor(AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode].point, anchorTo, AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode].relativePoint, AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode].offsetX, AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode].offsetY)
    end
end
 
function AUI.FrameMover.IsLoaded()
    if g_isInit then
        return true
    end
 
    return false
end
 
function AUI.FrameMover.IsPreviewShowing()
    return g_isPreviewShowing
end
 
function AUI.FrameMover.ShowPreview(_show)
    if _show then
        AUI.FrameMover.ShowAllWindows()
    else
        AUI.FrameMover.HideAllWindows()
    end
 
    g_isPreviewShowing = _show
end
 
function AUI.FrameMover.ShowAllWindows()
    for _, inputData in pairs(g_windows) do
        local windowData = inputData[g_currentInputMode]
        if windowData then
            windowData.mainControl:SetHidden(false)
            windowData.mainControl:SetMouseEnabled(true)
        end
    end
end
 
function AUI.FrameMover.HideAllWindows()
    for _, inputData in pairs(g_windows) do
        local windowData = inputData[g_currentInputMode]
        if windowData then
            windowData.mainControl:SetHidden(true)
            windowData.mainControl:SetMouseEnabled(false)
        end
    end
end
 
function AUI.FrameMover.UpdateAll()
    if IsInGamepadPreferredMode() then
        g_currentInputMode = 2
    else
        g_currentInputMode = 1
    end
 
    for windowName, inputData in pairs(g_windows) do
        local anchorTo = GuiRoot
        if not AUI.Settings.FrameMover.anchors then
            AUI.Settings.FrameMover.anchors = {}
        end
 
        if not AUI.Settings.FrameMover.anchors[windowName] then
            AUI.Settings.FrameMover.anchors[windowName] = {}
        end
 
        local windowData = inputData[g_currentInputMode]
        if windowData then
            if not windowData.default_anchor then
                windowData.default_anchor = {}
                _, windowData.default_anchor.point, anchorTo, windowData.default_anchor.relativePoint, windowData.default_anchor.offsetX, windowData.default_anchor.offsetY = windowData.originalControl:GetAnchor()
            end
 
            if not AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode] then
                AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode] = {}
                AUI.Settings.FrameMover.anchors[windowName][g_currentInputMode] = AUI.Table.Copy(windowData.default_anchor)
            end
 
            if not windowData.mainControl then
                local mainControl = CreateControlFromVirtual("AUI_FrameMover_Window_" .. windowName .. g_currentInputMode, AUI_FrameMover, "AUI_FrameMover_Window")
                mainControl:SetHandler("OnMouseDown", function(control, _button, _ctrl, _alt, _shift) OnFrameMouseDown(_button, _ctrl, _alt, _shift, mainControl) end)
                mainControl:SetHandler("OnMouseUp", function(control, _button, _ctrl, _alt, _shift) OnFrameMouseUp(_button, _ctrl, _alt, _shift, mainControl) end)				
                mainControl.windowName = windowName
 
                local text = GetControl(mainControl, "_Text")
                text:SetFont("$(BOLD_FONT)|" ..  18 .. "|" .. "thick-outline")
                text:SetText(windowData.text)
 
                mainControl.windowData = windowData
                windowData.mainControl = mainControl
            end
 
            if not windowData.width then
                windowData.mainControl:SetWidth(windowData.originalControl:GetWidth())
            else
                windowData.mainControl:SetWidth(windowData.width)
            end
 
            if not windowData.height then
                windowData.mainControl:SetHeight(windowData.originalControl:GetHeight())
            else
                windowData.mainControl:SetHeight(windowData.height)
            end
 
            AUI.FrameMover.SetWindowPosition(windowData, anchorTo)
        end
    end
 
    if g_isPreviewShowing then
        AUI.FrameMover.ShowAllWindows()
    end
end
 
function AUI.FrameMover.OnGamepadPreferredModeChanged(_gamepadPreferred)
    AUI.FrameMover.HideAllWindows()
    AUI.FrameMover.UpdateAll()
end
 
function AUI.FrameMover.OnPlayerActivated()
    AUI.FrameMover.UpdateAll()
end
 
function AUI.FrameMover.Load()
    if g_isInit then
        return
    end
 
    g_isInit = true
 
    AUI.FrameMover.LoadSettings()
    g_windows = CreateWindows()
    AUI.FrameMover.UpdateAll()
end