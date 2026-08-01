
HomesteadItemMover = {}

local selectedFurnitureId = nil

-- new variables by CD

local moveMagnitude=1
local stoneBlockLength=225 -- length of a stone block, a special length to move items

local rotateMagnitude=0.0
local rotateMagnitudes= {1,5,15,22.5,30,45,60,90}
local numberOfRotationSteps=8 -- Bloody Lua doe not automagicaly know how large a table is
local currentRotationMgnitude=1.0
local rotationMagnitudeRad=0 -- rotation magnitude in radians
local actionMode=0 --0=move 1= rotate
local viewSelectedItemGUI = nil

-- used for copy-pasta
local copyX
local copyY
local copyZ
local copyPitch
local copyYaw
local copyRoll


-- Addon constants
local ADDON_NAME = "HomesteadItemMover"

function HomesteadItemMover:Initialize()
	-- Apply language strings
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_PRECISE_SELECT", "Precise select furniture")

	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_NUDGE_X_POSITIVE", "Move east / Pitch up")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_NUDGE_X_NEGATIVE", "Move west / Pitch down")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_NUDGE_Z_POSITIVE", "Move north / rotate left")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_NUDGE_Z_NEGATIVE", "Move south / rotate right")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_NUDGE_Y_POSITIVE", "Move up / yaw left")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_NUDGE_Y_NEGATIVE", "Move down / yaw right")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_NUDGE_MAGNITUDE_UP", "Bigger movement")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_NUDGE_MAGNITUDE_DOWN", "Smaller movement")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_CHANGE_MODE", "Change mode")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_RESET_ROTATION", "Reset rotation")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_COPY", "Copy values")
	ZO_CreateStringId("SI_BINDING_NAME_HOMESTEAD_LOC_ROT_PASTE", "Paste values")
end


-- you don't need THAT much precision, nerd
function HomesteadItemMover:Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function HomesteadItemMover:Select(newSelectedFurnitureId)
	selectedFurnitureId = newSelectedFurnitureId
	--HomesteadItemMover:ShowSelectedItemGUI()
	HomesteadItemMoverUI:SetHidden(false)
end

function HomesteadItemMover:Unselect()
	selectedFurnitureId = nil
	HomesteadItemMoverUI:SetHidden(true)
	if (viewSelectedItemGUI ~= nil) then
		--viewSelectedItemGUI.window:SetHidden(true)

	end
end

function HomesteadItemMover_PreciseSelect()
	-- Only allow selection in housing editor browse mode
	local editorMode = GetHousingEditorMode()
	if (editorMode ~= HOUSING_EDITOR_MODE_SELECTION) then
		return
	end

	-- Unselect if not looking at valid target
	if (not HousingEditorCanSelectTargettedFurniture()) then
		HomesteadItemMover:Unselect()
		return
	end

	-- Get the furniture ID by picking the object up, reading it's ID, then putting it back down immediately.
	-- Stupid hack - I don't think there is a way to get the ID without picking it up.
	-- Can't even "unselect" it.
	local selectAttemptResult = HousingEditorSelectTargettedFurniture()
	local newSelectedFurnitureId = HousingEditorGetSelectedFurnitureId()

	-- table.insert(bob, newSelectedFurnitureId)

	-- Requires a small delay to work.
	zo_callLater(function()
		-- HousingEditorRequestSelectedPlacement()
		HousingEditorRequestModeChange(2) -- Deselect without changes.

		if (newSelectedFurnitureId == nil) then
			HomesteadItemMover:Unselect()
		else
			HomesteadItemMover:Select(newSelectedFurnitureId)
		end
	end, 10)
end

-- Started making changes here -Chibidragon
function HomesteadItemMover_NudgeXPositive()
	if (actionMode==0) then
		local newX, newY, newZ = HousingEditorGetFurnitureWorldPosition(selectedFurnitureId)
		newX=newX+moveMagnitude
		HousingEditorRequestChangePosition(selectedFurnitureId, newX, newY, newZ)
	end
	if (actionMode==1) then
		local newPitch, newYaw, newRoll= HousingEditorGetFurnitureOrientation(selectedFurnitureId)
		newPitch=newPitch+rotationMagnitudeRad
		HousingEditorRequestChangeOrientation(selectedFurnitureId, newPitch, newYaw, newRoll)
	end
end

function HomesteadItemMover_NudgeXNegative()
	if (actionMode==0) then
		local newX, newY, newZ = HousingEditorGetFurnitureWorldPosition(selectedFurnitureId)
		newX=newX-moveMagnitude
		HousingEditorRequestChangePosition(selectedFurnitureId, newX, newY, newZ)
	end
	if (actionMode==1) then
		local newPitch, newYaw, newRoll= HousingEditorGetFurnitureOrientation(selectedFurnitureId)
		newPitch=newPitch-rotationMagnitudeRad
		HousingEditorRequestChangeOrientation(selectedFurnitureId, newPitch, newYaw, newRoll)
	end
end

function HomesteadItemMover_NudgeYPositive()
	if (actionMode==0) then
		local newX, newY, newZ = HousingEditorGetFurnitureWorldPosition(selectedFurnitureId)
		newY=newY+moveMagnitude
		HousingEditorRequestChangePosition(selectedFurnitureId, newX, newY, newZ)
	end
	if (actionMode==1) then
		local newPitch, newYaw, newRoll= HousingEditorGetFurnitureOrientation(selectedFurnitureId)
		newRoll=newRoll+rotationMagnitudeRad
		HousingEditorRequestChangeOrientation(selectedFurnitureId, newPitch, newYaw, newRoll)
	end
end

function HomesteadItemMover_NudgeYNegative()
	if (actionMode==0) then
		local newX, newY, newZ = HousingEditorGetFurnitureWorldPosition(selectedFurnitureId)
		newY=newY-moveMagnitude
		HousingEditorRequestChangePosition(selectedFurnitureId, newX, newY, newZ)
	end
	if (actionMode==1) then
		local newPitch, newYaw, newRoll= HousingEditorGetFurnitureOrientation(selectedFurnitureId)
		newRoll=newRoll-rotationMagnitudeRad
		HousingEditorRequestChangeOrientation(selectedFurnitureId, newPitch, newYaw, newRoll)
	end
end

function HomesteadItemMover_NudgeZPositive()
	if (actionMode==0) then
		local newX, newY, newZ = HousingEditorGetFurnitureWorldPosition(selectedFurnitureId)
		newZ=newZ+moveMagnitude
		HousingEditorRequestChangePosition(selectedFurnitureId, newX, newY, newZ)
	end
	if (actionMode==1) then
		local newPitch, newYaw, newRoll= HousingEditorGetFurnitureOrientation(selectedFurnitureId)
		newYaw=newYaw+rotationMagnitudeRad
		HousingEditorRequestChangeOrientation(selectedFurnitureId, newPitch, newYaw, newRoll)
	end
end

function HomesteadItemMover_NudgeZNegative()
	if (actionMode==0) then
		local newX, newY, newZ = HousingEditorGetFurnitureWorldPosition(selectedFurnitureId)
		newZ=newZ-moveMagnitude
		HousingEditorRequestChangePosition(selectedFurnitureId, newX, newY, newZ)
	end
	if (actionMode==1) then
		local newPitch, newYaw, newRoll= HousingEditorGetFurnitureOrientation(selectedFurnitureId)
		newYaw=newYaw-rotationMagnitudeRad
		HousingEditorRequestChangeOrientation(selectedFurnitureId, newPitch, newYaw, newRoll)
	end
end

function HomesteadItemMover_NudgeMagnitudeUp()
	if (actionMode==0) then
		if (moveMagnitude<1025 and moveMagnitude~=128 and moveMagnitude~=stoneBlockLength) then
			moveMagnitude=moveMagnitude*2
		elseif (moveMagnitude==128) then
			moveMagnitude=stoneBlockLength
		elseif (moveMagnitude==stoneBlockLength) then
			moveMagnitude=256
		end
	end
	if (actionMode==1) then
		currentRotationMgnitude=currentRotationMgnitude+1
		if (currentRotationMgnitude>numberOfRotationSteps) then
			currentRotationMgnitude=1
		end
		rotateMagnitude=rotateMagnitudes[currentRotationMgnitude]
		rotationMagnitudeRad=math.rad(rotateMagnitude)
	end
end

function HomesteadItemMover_NudgeMagnitudeDown()
	if (actionMode==0) then
		if (moveMagnitude>1 and moveMagnitude~=256 and moveMagnitude~=stoneBlockLength) then
			moveMagnitude=moveMagnitude/2
		elseif (moveMagnitude==256)  then
			moveMagnitude=stoneBlockLength
		elseif (moveMagnitude==stoneBlockLength) then
			moveMagnitude=128
		end
	end
	if (actionMode==1) then
		currentRotationMgnitude=currentRotationMgnitude-1
		if (currentRotationMgnitude==0) then
			currentRotationMgnitude=numberOfRotationSteps
		end
		rotateMagnitude=rotateMagnitudes[currentRotationMgnitude]
		rotationMagnitudeRad=math.rad(rotateMagnitude)
	end
end

function HomesteadItemMover_ChangeMode()
	actionMode=actionMode+1
	if (actionMode==2) then
		actionMode=0
	end
end

function HomesteadItemMover.OnAddOnLoaded(event, addonName)
	if (addonName == ADDON_NAME) then
		HomesteadItemMover:Initialize()
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
	end
end

function HomesteadItemMover_ResetRotation()
	HousingEditorRequestChangeOrientation(selectedFurnitureId, 0, 0, 0)
end

function HomesteadItemMoverUpdate()
	local warning=""
	if (selectedFurnitureId~=nil) then
		if (actionMode==0) then
			local newX, newY, newZ = HousingEditorGetFurnitureWorldPosition(selectedFurnitureId)
			HomesteadItemMoverUIObjectInfo:SetText(string.format('Object mover\nX: %d\nY: %d\nZ: %d\nMove step: %d',newX, newY, newZ , moveMagnitude))
		end
		if (actionMode==1) then
			local pitchRad, yawRad, rollRad= HousingEditorGetFurnitureOrientation(selectedFurnitureId)
			local newPitch=HomesteadItemMover:Round(math.deg(pitchRad), 2)
			local newYaw=HomesteadItemMover:Round(math.deg(yawRad), 2)
			local newRoll=HomesteadItemMover:Round(math.deg(rollRad), 2)
			-- check gimbal lock (Pitch>90 degrees)
			if (newPitch+rotateMagnitude > 89 or newPitch-rotateMagnitude<-89) then
				warning="Approaching gimbal lock!"
			end

			if (newPitch > 89 or newPitch<-89) then
				warning="Gimbal lock!"
			end

			HomesteadItemMoverUIObjectInfo:SetText(string.format('Object rotator\nPitch:  %d deg.\nYaw:    %d deg.\nRotation: %d deg.\nRotation step: %d deg.\n%s',newPitch, newYaw, newRoll , rotateMagnitude, warning))
		end

	end
	-- check if we are on housing editor move, and if not close the window
	local editorMode = GetHousingEditorMode()
	if (editorMode == HOUSING_EDITOR_MODE_DISABLED) then
		HomesteadItemMoverUI:SetHidden(true)
	end

end

function HomesteadItemMoverCopy()
	if (actionMode==0) then
		copyX, copyY, copyZ = HousingEditorGetFurnitureWorldPosition(selectedFurnitureId)
	end
	if (actionMode==1) then
		copyPitch, copyYaw, copyRoll = HousingEditorGetFurnitureOrientation(selectedFurnitureId)
	end
end

function HomesteadItemMoverPaste()
		if (actionMode==0) then
		HousingEditorRequestChangePosition(selectedFurnitureId, copyX, copyY, copyZ)
	end
	if (actionMode==1) then
		HousingEditorRequestChangeOrientation(selectedFurnitureId, copyPitch, copyYaw, copyRoll)
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, HomesteadItemMover.OnAddOnLoaded)