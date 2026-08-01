-------------------------------------------------------------------------------
-- Furniture Grouper Mover
-- Datael (@Datael) - 2017
-------------------------------------------------------------------------------

-------------
-- Private --
-------------

local matrix = LibStub("LibMatrix-1.2")
local group = {}
local moving = false
local lastHeldSafeFurnitureID = nil
local oldTransform = nil

-- Helper functions

local function ToSafeFurnitureID(furnitureID)
	return zo_getSafeId64Key(furnitureID)
end

local function ToFurnitureID(safeFurnitureID)
	return group[safeFurnitureID].furnitureID
end

local function GetTransform(furnitureID)
	local x, y, z = HousingEditorGetFurnitureWorldPosition(furnitureID)
	local pitch, yaw, roll = HousingEditorGetFurnitureOrientation(furnitureID)
	return { x = x, y = y, z = z, pitch = pitch, yaw = yaw, roll = roll	}
end

local function TransformsAreEqual(transformA, transformB)
	return transformA.x == transformB.x and
		transformA.y == transformB.y and
		transformA.z == transformB.z and
		transformA.pitch == transformB.pitch and
		transformA.yaw == transformB.yaw and
		transformA.roll == transformB.roll
end

local function HasBeenPutAway(furnitureID)
	local transform = GetTransform(furnitureID)
	return transform.x == 0 and transform.y == 0 and transform.z == 0
end

local function IsInGroup(safeFurnitureID)
	return group[safeFurnitureID] ~= nil
end

-- Transform manipulation

local cos = math.cos
local sin = math.sin

local function GetRollMatrix(roll)
	local sinr, cosr = sin(roll), cos(roll)
	return matrix {
		{ cosr, -sinr, 0 },
		{ sinr, cosr, 0 },
		{ 0, 0, 1 }
	}
end

local function GetPitchMatrix(pitch)
	local sinp, cosp = sin(pitch), cos(pitch)
	return matrix {
		{ cosp, 0, sinp },
		{ 0, 1, 0 },
		{ -sinp, 0, cosp }
	}
end

local function GetYawMatrix(yaw)
	local siny, cosy = sin(yaw), cos(yaw)
	return matrix {
		{ 1, 0, 0 },
		{ 0, cosy, -siny },
		{ 0, siny, cosy }
	}
end

local function GetRotationMatrix(pitch, yaw, roll)
	local pm, ym, rm = GetPitchMatrix(pitch), GetYawMatrix(yaw), GetRollMatrix(roll)
	return matrix.mul(rm, matrix.mul(pm, ym))
end

local function ExtractRotationFromMatrix(mtx)
	local pitch = -math.asin(mtx[3][1])
	local yaw = -math.atan2(-mtx[3][2], mtx[3][3])
	local roll = -math.atan2(-mtx[2][1], mtx[1][1])
	return pitch, yaw, roll
end

local function ApplyTransform(transform, safeFurnitureID)
	local furnitureID = ToFurnitureID(safeFurnitureID)
	HousingEditorRequestChangePositionAndOrientation(furnitureID, transform.x, transform.y, transform.z, transform.pitch, transform.yaw, transform.roll)
	group[safeFurnitureID].currentTransform = GetTransform(furnitureID)
end

-- Movement

local function GraduallyApplyMovement()
	local moved = false
	for safeFurnitureID,data in pairs(group) do
		if data.dirty and lastHeldSafeFurnitureID ~= safeFurnitureID then
			ApplyTransform(data.targetTransform, safeFurnitureID)
			data.dirty = false
			moved = true
			break
		end
	end
	-- Repeat if necessary
	if moved then
		zo_callLater(GraduallyApplyMovement, FurnitureGrouperConstants.GradualMoveDelay)
	else
		moving = false
	end
end

local function RequestGraduallyApplyMovement()
	if moving then return end
	
	GraduallyApplyMovement()
end

local function RegisterMovement(oldTransform, newTransform, parentFurnitureID)
	if TransformsAreEqual(oldTransform, newTransform) then return end

	local dx, dy, dz = newTransform.x - oldTransform.x, newTransform.y - oldTransform.y, newTransform.z - oldTransform.z
	local oldInverseParentTransform = matrix.invert(GetRotationMatrix(oldTransform.pitch, oldTransform.yaw, oldTransform.roll))
	local newParentTransform = GetRotationMatrix(newTransform.pitch, newTransform.yaw, newTransform.roll)

	for safeFurnitureID,data in pairs(group) do
		if safeFurnitureID ~= parentFurnitureID then
			local childTransform = data.targetTransform or data.currentTransform
			-- Position
			local childOffset = matrix { { childTransform.y - oldTransform.y, childTransform.x - oldTransform.x, childTransform.z - oldTransform.z } }
			local newChildOffset = matrix.mul(matrix.mul(childOffset, oldInverseParentTransform), newParentTransform)
			local targetX, targetY, targetZ = newChildOffset[1][2] + newTransform.x, newChildOffset[1][1] + newTransform.y, newChildOffset[1][3] + newTransform.z
			-- Rotation
			local childRotationMatrix = GetRotationMatrix(childTransform.pitch, childTransform.yaw, childTransform.roll)
			local newChildRotationMatrix = matrix.mul(matrix.mul(childRotationMatrix, oldInverseParentTransform), newParentTransform)
			local targetPitch, targetYaw, targetRoll = ExtractRotationFromMatrix(newChildRotationMatrix)
			-- Assign
			data.targetTransform = { x = targetX, y = targetY, z = targetZ, pitch = targetPitch, yaw = targetYaw, roll = targetRoll	}
			data.dirty = true
		else
			local furnitureID = ToFurnitureID(safeFurnitureID)
			data.targetTransform = GetTransform(furnitureID)
		end
	end

	RequestGraduallyApplyMovement()
end

------------
-- Public --
------------

-- Interaction

function FurnitureGrouper_Mover.PickedUp(furnitureID)
	local safeFurnitureID = ToSafeFurnitureID(furnitureID)
	if IsInGroup(safeFurnitureID) then
		oldTransform = GetTransform(furnitureID)
		lastHeldSafeFurnitureID = safeFurnitureID
	else
		oldTransform = nil
		lastHeldSafeFurnitureID = nil
	end
end

function FurnitureGrouper_Mover.Placed()
	if oldTransform ~= nil and lastHeldSafeFurnitureID ~= nil then
		local lastHeldFurnitureID = ToFurnitureID(lastHeldSafeFurnitureID)
		if not HasBeenPutAway(lastHeldFurnitureID) then
			local newTransform = GetTransform(lastHeldFurnitureID)
			-- If dirty then we want to use the target transform and not the current transform
			if group[lastHeldSafeFurnitureID].dirty then
				RegisterMovement(group[lastHeldSafeFurnitureID].targetTransform, newTransform, lastHeldSafeFurnitureID)
			else
				RegisterMovement(oldTransform, newTransform, lastHeldSafeFurnitureID)
			end
		else
			FurnitureGrouper_Mover.RemoveFromGroup(lastHeldSafeFurnitureID)
		end
	end
end

-- Grouping

function FurnitureGrouper_Mover.GroupHasItems()
	return next(group) ~= nil
end

function FurnitureGrouper_Mover.AddToGroup(furnitureID)
	local safeFurnitureID = ToSafeFurnitureID(furnitureID)
	if not IsInGroup(safeFurnitureID) then
		group[safeFurnitureID] = {
			furnitureID = furnitureID,
			dirty = false,
			currentTransform = GetTransform(furnitureID),
			originalTransform = GetTransform(furnitureID)
		}
	end
end

function FurnitureGrouper_Mover.RemoveFromGroup(furnitureID)
	local safeFurnitureID = ToSafeFurnitureID(furnitureID)
	if IsInGroup(safeFurnitureID) then
		group[safeFurnitureID] = nil
	end
end

function FurnitureGrouper_Mover.IsInGroup(furnitureID)
	local safeFurnitureID = ToSafeFurnitureID(furnitureID)
	return IsInGroup(safeFurnitureID)
end

function FurnitureGrouper_Mover.ClearGroup()
	if moving then
		-- Do nothing; clearing while moving will leave the player's furniture split between two or more states
	else
		group = {}
		lastHeldSafeFurnitureID = nil
	end
end

function FurnitureGrouper_Mover.ResetTransforms()
	for safeFurnitureID,data in pairs(group) do
		data.targetTransform = data.originalTransform
		data.dirty = true
	end
	RequestGraduallyApplyMovement()
	-- Force placement of current or most recent furnishing since we pass over it usually
	if lastHeldSafeFurnitureID then
		local safeFurnitureID = lastHeldSafeFurnitureID
		lastHeldSafeFurnitureID = nil
		HousingEditorRequestSelectedPlacement()
		-- There needs to be a delay to allow the initial forced placement request to go through
		zo_callLater(function() ApplyTransform(group[safeFurnitureID].originalTransform, safeFurnitureID) end, FurnitureGrouperConstants.ResetDelayAfterForcedPlacement)
	end
end
