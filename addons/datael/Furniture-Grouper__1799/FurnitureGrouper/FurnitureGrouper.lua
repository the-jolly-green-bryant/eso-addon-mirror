-------------------------------------------------------------------------------
-- Furniture Grouper
-- Datael (@Datael) - 2017
-------------------------------------------------------------------------------

local keybindStripLeftGroup = nil
local keybindStripRightGroup = nil
local sceneInfo = {}

-------------
-- Private --
-------------

local function GroupHasItems()
	return FurnitureGrouper_Mover.GroupHasItems()
end

local function InteractionAllowed()
	return (sceneInfo.mode == HOUSING_EDITOR_MODE_SELECTION or sceneInfo.mode == nil) and (sceneInfo.state ~= SCENE_HIDDEN)
end

local function UpdateKeybindStripButtons()
	if InteractionAllowed() then
		KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripLeftGroup)
		KEYBIND_STRIP:AddKeybindButtonGroup(keybindStripRightGroup)
	else
		KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripLeftGroup)
		KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindStripRightGroup)
	end
	KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindStripLeftGroup)
	KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindStripRightGroup)
end

local function GetCurrentTargetFurnitureId()
	if not InteractionAllowed() then return end
	if not HousingEditorCanSelectTargettedFurniture() then return end
	
	-- According to HomesteadOCD this is the only way to get the furniture ID. I don't plan on investigating any more for now since this works...
	local result = HousingEditorSelectTargettedFurniture()
	if result == HOUSING_REQUEST_RESULT_SUCCESS then
		local targetId = HousingEditorGetSelectedFurnitureId()
		HousingEditorRequestSelectedPlacement()
		return targetId
	else
		return nil
	end	
end

------------
-- Public --
------------

function FurnitureGrouper.AddToGroup()
	if not InteractionAllowed() then return end
	local target = GetCurrentTargetFurnitureId()
	if target then
		FurnitureGrouper_Mover.AddToGroup(target)
	end
	UpdateKeybindStripButtons()
end

function FurnitureGrouper.RemoveFromGroup()
	if not InteractionAllowed() then return end
	local target = GetCurrentTargetFurnitureId()
	FurnitureGrouper_Mover.RemoveFromGroup(target)
	UpdateKeybindStripButtons()
end

function FurnitureGrouper.ConfirmClearGroup()
	if not InteractionAllowed() then return end
	if not GroupHasItems() then return end
	HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)
	ZO_Dialogs_ShowDialog(FurnitureGrouperConstants.Dialogs.ClearGroupConfirm)
end

function FurnitureGrouper.ClearGroup()
	FurnitureGrouper_Mover.ClearGroup()
	UpdateKeybindStripButtons()
end

function FurnitureGrouper.ConfirmResetPositions()
	if not InteractionAllowed() then return end
	if not GroupHasItems() then return end
	HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_DISABLED)
	ZO_Dialogs_ShowDialog(FurnitureGrouperConstants.Dialogs.ResetPositionsConfirm)
end

function FurnitureGrouper.ResetPositions()
	FurnitureGrouper_Mover.ResetTransforms()
end

----------
-- Init --
----------

local function InitKeybindStrip()
	keybindStripLeftGroup = {
		{
			name = GetString(SI_FURNITURE_GROUPER_ADD_TO_GROUP_STRIP_LABEL),
			keybind = "FURNITURE_GROUPER_ADD_TO_GROUP",
		},
		{
			name = GetString(SI_FURNITURE_GROUPER_REMOVE_FROM_GROUP_STRIP_LABEL),
			keybind = "FURNITURE_GROUPER_REMOVE_FROM_GROUP",
		},
		alignment = KEYBIND_STRIP_ALIGN_LEFT
	}
	keybindStripRightGroup = {
		{
			name = GetString(SI_FURNITURE_GROUPER_RESET_GROUP_STRIP_LABEL),
			keybind = "FURNITURE_GROUPER_RESET_POSITIONS",
			enabled = function() return GroupHasItems() end,
		},
		{
			name = GetString(SI_FURNITURE_GROUPER_CLEAR_GROUP_STRIP_LABEL),
			keybind = "FURNITURE_GROUPER_CLEAR_GROUP",
			enabled = function() return GroupHasItems() end,
		},
		alignment = KEYBIND_STRIP_ALIGN_RIGHT
	}
end

local function InitDialogs()
	ESO_Dialogs[FurnitureGrouperConstants.Dialogs.ClearGroupConfirm] = {
		title = {
			text = SI_FURNITURE_GROUPER_CLEAR_GROUP_DIALOG_TITLE,
		},
		mainText = {
			text = SI_FURNITURE_GROUPER_CLEAR_GROUP_DIALOG_BODY,
		},
		buttons = {
			[1] = {
				text = SI_DIALOG_CONFIRM,
				callback = function(...)
					FurnitureGrouper.ClearGroup()
					HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
				end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
				callback = function(...)
					HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
				end,
			}
		}
	}

	ESO_Dialogs[FurnitureGrouperConstants.Dialogs.ResetPositionsConfirm] = {
		title = {
			text = SI_FURNITURE_GROUPER_RESET_POSITIONS_DIALOG_TITLE,
		},
		mainText = {
			text = SI_FURNITURE_GROUPER_RESET_POSITIONS_DIALOG_BODY,
		},
		buttons = {
			[1] = {
				text = SI_DIALOG_CONFIRM,
				callback = function(...)
					FurnitureGrouper.ResetPositions()
					HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
				end,
			},
			[2] = {
				text = SI_DIALOG_CANCEL,
				callback = function(...)
					HousingEditorRequestModeChange(HOUSING_EDITOR_MODE_SELECTION)
				end,
			}
		}
	}
end

--------------------
-- Event Handling --
--------------------

local function AddOnLoaded(event, addOnName)
	if addOnName ~= FurnitureGrouper.name then return end

	EVENT_MANAGER:UnregisterForEvent(FurnitureGrouper.name, EVENT_ADD_ON_LOADED)
	InitKeybindStrip()
	InitDialogs()
end

-- This doesn't get flagged as true when placing a new item
local wasPickingUp = false

local function HousingEditorModeChanged(eventCode, oldMode, newMode)
	-- Keybind Strip
	sceneInfo.mode = newMode
	UpdateKeybindStripButtons()
	-- picking up
	if oldMode == HOUSING_EDITOR_MODE_SELECTION and newMode == HOUSING_EDITOR_MODE_PLACEMENT then
		local furnitureID = HousingEditorGetSelectedFurnitureId()
		FurnitureGrouper_Mover.PickedUp(furnitureID)
		wasPickingUp = true
	end
	-- placing
	if oldMode == HOUSING_EDITOR_MODE_PLACEMENT and newMode == HOUSING_EDITOR_MODE_SELECTION then
		if wasPickingUp then
			FurnitureGrouper_Mover.Placed()
		end
		wasPickingUp = false
	end
end

local function HousingEditorHUDSceneStateChanged(oldState, newState)
	sceneInfo.state = newState
	UpdateKeybindStripButtons()
end

EVENT_MANAGER:RegisterForEvent(FurnitureGrouper.name, EVENT_ADD_ON_LOADED, AddOnLoaded)
EVENT_MANAGER:RegisterForEvent(FurnitureGrouper.name, EVENT_HOUSING_EDITOR_MODE_CHANGED, HousingEditorModeChanged)
HOUSING_EDITOR_HUD_SCENE:RegisterCallback("StateChange", HousingEditorHUDSceneStateChanged)
