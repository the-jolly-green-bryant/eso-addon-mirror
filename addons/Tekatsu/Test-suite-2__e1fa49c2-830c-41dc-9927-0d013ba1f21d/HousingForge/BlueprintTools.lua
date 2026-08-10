HF = HF or {}
HF.BlueprintTools = HF.BlueprintTools or {}

local BlueprintTools = HF.BlueprintTools

-- API 101050 assumptions:
-- * Housing world positions are signed integer centimeters and Y is vertical.
-- * Placed furnishing IDs are persisted and matched as strings via Id64ToString.
-- * Position/orientation requests retain existing furniture parents; this module never relinks.
-- * Transform requests return HousingRequestResult immediately, so they can be paced with zo_callLater.

local MAX_QUEUE_REQUESTS = 1000
local MAX_FURNITURE_SCAN = 2000
local MIN_REQUEST_DELAY_MS = 10
local MAX_REQUEST_DELAY_MS = 1500
local MAX_WORLD_COORDINATE = 2147483647
local TWO_PI = math.pi * 2
local TRANSFORM_EPSILON = 0.000001
local READBACK_POSITION_EPSILON_CM = 0
local READBACK_ORIENTATION_EPSILON = TRANSFORM_EPSILON
local MIN_CONFIRMATION_TIMEOUT_MS = 750
local MAX_CONFIRMATION_TIMEOUT_MS = 4000
local CONFIRMATION_TIMEOUT_DELAY_MULTIPLIER = 4
local MOVE_EVENT_NAMESPACE = (HF.name or "HousingForge") .. "_BlueprintTools_MoveAck"

BlueprintTools.MAX_QUEUE_REQUESTS = MAX_QUEUE_REQUESTS
BlueprintTools.selection = BlueprintTools.selection or {
    houseId = nil,
    order = {},
    byId = {},
}
BlueprintTools.activeQueue = nil
BlueprintTools.lastQueueResult = nil
BlueprintTools.queueSerial = BlueprintTools.queueSerial or 0
BlueprintTools.pendingSerial = BlueprintTools.pendingSerial or 0

local function Chat(message)
    if HF.Chat then
        HF.Chat(message)
    elseif d then
        d("|cAAFFAA[HousingForge]|r " .. tostring(message))
    end
end

local function Trim(value)
    if type(value) ~= "string" then return "" end
    return value:match("^%s*(.-)%s*$") or ""
end

local function IsFiniteNumber(value)
    return type(value) == "number"
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
end

local function ParseFiniteNumber(value)
    if type(value) == "string" then
        value = tonumber(Trim(value))
    end
    if not IsFiniteNumber(value) then return nil end
    return value
end

local function ParseOffset(value)
    if value == nil or value == "" or (type(value) == "string" and Trim(value) == "") then return 0 end
    return ParseFiniteNumber(value)
end

local function Round(value)
    if value >= 0 then
        return math.floor(value + 0.5)
    end
    return math.ceil(value - 0.5)
end

local function NormalizeAngle(radians)
    radians = radians % TWO_PI
    if radians > math.pi then radians = radians - TWO_PI end
    return radians
end

local function IsValidCoordinate(value)
    return IsFiniteNumber(value)
        and value >= -MAX_WORLD_COORDINATE
        and value <= MAX_WORLD_COORDINATE
end

local function IdToKey(furnitureId)
    if furnitureId == nil then return nil end

    local key = nil
    if Id64ToString then
        local ok, value = pcall(Id64ToString, furnitureId)
        if ok then key = value end
    else
        key = tostring(furnitureId)
    end

    if type(key) ~= "string" or key == "" or key == "0" then return nil end
    return key
end

local function GetCurrentHouse(requireOwnership)
    if not GetCurrentZoneHouseId then
        return nil, "The housing API is unavailable."
    end

    local houseId = GetCurrentZoneHouseId()
    if not houseId or houseId == 0 then
        return nil, "You must be inside a house."
    end

    if requireOwnership and (not IsOwnerOfCurrentHouse or not IsOwnerOfCurrentHouse()) then
        return nil, "You must be inside a house you own."
    end

    return houseId
end

local function EnsureSavedStorage()
    if type(HF.savedVars) ~= "table" then
        return nil, "HousingForge has not finished loading its saved data."
    end
    if type(HF.savedVars.blueprintGroups) ~= "table" then
        HF.savedVars.blueprintGroups = {}
    end
    return HF.savedVars.blueprintGroups
end

local function GetHouseGroupTable(houseId, create)
    local groups, reason = EnsureSavedStorage()
    if not groups then return nil, reason end

    local houseKey = tostring(houseId)
    if create and type(groups[houseKey]) ~= "table" then
        groups[houseKey] = {}
    end
    if type(groups[houseKey]) ~= "table" then return {} end
    return groups[houseKey]
end

local function NormalizeGroupName(name)
    name = Trim(name)
    if name == "" then return nil end
    if #name > 80 then name = name:sub(1, 80) end
    return name, string.lower(name)
end

local function ResetSelection(houseId)
    BlueprintTools.selection = {
        houseId = houseId,
        order = {},
        byId = {},
    }
    return BlueprintTools.selection
end

local function EnsureSelection(houseId)
    local selection = BlueprintTools.selection
    if type(selection) ~= "table"
        or type(selection.order) ~= "table"
        or type(selection.byId) ~= "table" then
        return ResetSelection(houseId)
    end

    if houseId and selection.houseId ~= houseId then
        return ResetSelection(houseId)
    end
    return selection
end

local function BuildPlacedFurnitureIndex()
    if not GetNextPlacedHousingFurnitureId then
        return nil, nil, "Placed-furniture enumeration is unavailable."
    end

    local byId = {}
    local order = {}
    local lastFurnitureId = nil

    for _ = 1, MAX_FURNITURE_SCAN do
        local ok, furnitureId = pcall(GetNextPlacedHousingFurnitureId, lastFurnitureId)
        if not ok then
            return nil, nil, "ESO could not enumerate placed furniture."
        end
        if furnitureId == nil then
            return byId, order
        end

        local key = IdToKey(furnitureId)
        if not key then
            return nil, nil, "ESO returned an invalid placed furnishing ID."
        end
        if byId[key] then
            return nil, nil, "Placed-furniture enumeration repeated an ID."
        end

        byId[key] = furnitureId
        order[#order + 1] = key
        lastFurnitureId = furnitureId
    end

    return nil, nil, string.format("Furniture scan stopped at the safety limit of %d items.", MAX_FURNITURE_SCAN)
end

local function GetFurnitureName(furnitureId)
    if not GetPlacedHousingFurnitureInfo then return "Furnishing" end
    local ok, name = pcall(GetPlacedHousingFurnitureInfo, furnitureId)
    if ok and type(name) == "string" and name ~= "" then return name end
    return "Furnishing"
end

local function RemoveSelectionKey(selection, key)
    if not selection.byId[key] then return false end
    selection.byId[key] = nil
    for index, selectedKey in ipairs(selection.order) do
        if selectedKey == key then
            table.remove(selection.order, index)
            break
        end
    end
    return true
end

local function AddSelectionId(selection, furnitureId, key)
    key = key or IdToKey(furnitureId)
    if not key or selection.byId[key] then return false end
    selection.byId[key] = {
        id = furnitureId,
        key = key,
        name = GetFurnitureName(furnitureId),
    }
    selection.order[#selection.order + 1] = key
    return true
end

local function PruneSelection(selection, placedById)
    local stale = 0
    for index = #selection.order, 1, -1 do
        local key = selection.order[index]
        local currentId = placedById[key]
        if not currentId then
            selection.byId[key] = nil
            table.remove(selection.order, index)
            stale = stale + 1
        else
            local entry = selection.byId[key]
            if type(entry) ~= "table" then
                entry = { key = key, name = GetFurnitureName(currentId) }
                selection.byId[key] = entry
            end
            entry.id = currentId
            entry.key = key
        end
    end
    return stale
end

local function ResolveSelectedFurniture(placedById)
    if not HousingEditorGetSelectedFurnitureId then return nil end
    local ok, furnitureId = pcall(HousingEditorGetSelectedFurnitureId)
    if not ok then return nil end
    local key = IdToKey(furnitureId)
    return key and placedById[key] or nil
end

local function ResolveTargetedFurniture(placedById)
    if not HousingEditorGetTargetInfo then return nil end
    local ok, furnitureId = pcall(HousingEditorGetTargetInfo)
    if not ok then return nil end
    local key = IdToKey(furnitureId)
    return key and placedById[key] or nil
end

local function ResolveTargetOrSelected(placedById)
    return ResolveTargetedFurniture(placedById) or ResolveSelectedFurniture(placedById)
end

local function SelectResolvedFurniture(resolver, toggle)
    local houseId, reason = GetCurrentHouse(true)
    if not houseId then Chat(reason) return false end

    local placedById, _, scanReason = BuildPlacedFurnitureIndex()
    if not placedById then Chat(scanReason) return false end

    local furnitureId = resolver(placedById)
    if not furnitureId then
        Chat("No placed furnishing is targeted or selected.")
        return false
    end

    local selection = EnsureSelection(houseId)
    PruneSelection(selection, placedById)
    local key = IdToKey(furnitureId)
    if toggle and selection.byId[key] then
        local name = selection.byId[key].name or "Furnishing"
        RemoveSelectionKey(selection, key)
        Chat(string.format("Removed %s from the blueprint selection (%d selected).", name, #selection.order))
        return true
    end

    if selection.byId[key] then
        Chat(string.format("%s is already selected (%d selected).", selection.byId[key].name or "Furnishing", #selection.order))
        return true
    end

    AddSelectionId(selection, furnitureId, key)
    Chat(string.format("Selected %s (%d selected).", selection.byId[key].name or "Furnishing", #selection.order))
    return true
end

function BlueprintTools.SelectTargeted()
    return SelectResolvedFurniture(ResolveTargetedFurniture, false)
end

function BlueprintTools.SelectSelected()
    return SelectResolvedFurniture(ResolveSelectedFurniture, false)
end

function BlueprintTools.SelectTargetedOrSelected()
    return SelectResolvedFurniture(ResolveTargetOrSelected, false)
end

function BlueprintTools.ToggleTargeted()
    return SelectResolvedFurniture(ResolveTargetedFurniture, true)
end

function BlueprintTools.ToggleSelected()
    return SelectResolvedFurniture(ResolveSelectedFurniture, true)
end

function BlueprintTools.ToggleTargetedOrSelected()
    return SelectResolvedFurniture(ResolveTargetOrSelected, true)
end

BlueprintTools.Select = BlueprintTools.SelectTargetedOrSelected
BlueprintTools.Toggle = BlueprintTools.ToggleTargetedOrSelected

function BlueprintTools.ClearSelection()
    local selection = EnsureSelection(nil)
    local count = #selection.order
    ResetSelection(nil)
    Chat(string.format("Blueprint selection cleared (%d removed).", count))
    return count
end

BlueprintTools.Clear = BlueprintTools.ClearSelection

function BlueprintTools.SelectAll()
    local houseId, reason = GetCurrentHouse(true)
    if not houseId then Chat(reason) return 0 end

    local placedById, placedOrder, scanReason = BuildPlacedFurnitureIndex()
    if not placedById then Chat(scanReason) return 0 end
    if #placedOrder > MAX_QUEUE_REQUESTS then
        Chat(string.format("This house has %d furnishings; the precision safety limit is %d.", #placedOrder, MAX_QUEUE_REQUESTS))
        return 0
    end

    local selection = ResetSelection(houseId)
    for _, key in ipairs(placedOrder) do
        AddSelectionId(selection, placedById[key], key)
    end
    Chat(string.format("Selected all %d placed furnishings.", #selection.order))
    return #selection.order
end

function BlueprintTools.GetSelectionCount()
    local houseId = GetCurrentZoneHouseId and GetCurrentZoneHouseId() or nil
    if houseId == 0 then houseId = nil end
    local selection = EnsureSelection(houseId)
    return #selection.order
end

function BlueprintTools.GetSelection()
    local houseId = GetCurrentZoneHouseId and GetCurrentZoneHouseId() or nil
    if houseId == 0 then houseId = nil end
    local selection = EnsureSelection(houseId)
    local result = {}
    for _, key in ipairs(selection.order) do
        local entry = selection.byId[key]
        if entry then
            result[#result + 1] = {
                furnitureId = key,
                name = entry.name,
            }
        end
    end
    return result
end

function BlueprintTools.SaveGroup(name)
    local houseId, reason = GetCurrentHouse(true)
    if not houseId then Chat(reason) return false end

    local displayName, groupKey = NormalizeGroupName(name)
    if not displayName then
        Chat("Give the blueprint group a name.")
        return false
    end

    local placedById, _, scanReason = BuildPlacedFurnitureIndex()
    if not placedById then Chat(scanReason) return false end
    local selection = EnsureSelection(houseId)
    local stale = PruneSelection(selection, placedById)
    if #selection.order == 0 then
        Chat("Select at least one placed furnishing before saving a group.")
        return false
    end

    local houseGroups, storageReason = GetHouseGroupTable(houseId, true)
    if not houseGroups then Chat(storageReason) return false end
    local existed = houseGroups[groupKey] ~= nil
    local ids = {}
    for _, key in ipairs(selection.order) do ids[#ids + 1] = key end

    houseGroups[groupKey] = {
        name = displayName,
        houseId = houseId,
        savedAt = GetTimeStamp and GetTimeStamp() or 0,
        ids = ids,
    }

    Chat(string.format("%s blueprint group '%s' with %d furnishing%s%s.",
        existed and "Updated" or "Saved",
        displayName,
        #ids,
        #ids == 1 and "" or "s",
        stale > 0 and string.format(" (%d stale selection removed)", stale) or ""))
    return true, houseGroups[groupKey]
end

function BlueprintTools.LoadGroup(name, append)
    local houseId, reason = GetCurrentHouse(true)
    if not houseId then Chat(reason) return 0 end

    local _, groupKey = NormalizeGroupName(name)
    if not groupKey then Chat("Give the blueprint group name to load.") return 0 end
    local houseGroups, storageReason = GetHouseGroupTable(houseId, false)
    if not houseGroups then Chat(storageReason) return 0 end

    local group = houseGroups[groupKey]
    if type(group) ~= "table" or type(group.ids) ~= "table" then
        Chat("No blueprint group named '" .. Trim(name) .. "' exists in this house.")
        return 0
    end
    if group.houseId and group.houseId ~= houseId then
        Chat("That blueprint group belongs to a different house.")
        return 0
    end

    local placedById, _, scanReason = BuildPlacedFurnitureIndex()
    if not placedById then Chat(scanReason) return 0 end
    local selection = append and EnsureSelection(houseId) or ResetSelection(houseId)
    PruneSelection(selection, placedById)

    local added = 0
    local stale = 0
    for _, savedId in ipairs(group.ids) do
        local key = type(savedId) == "string" and savedId or IdToKey(savedId)
        local furnitureId = key and placedById[key] or nil
        if furnitureId then
            if AddSelectionId(selection, furnitureId, key) then added = added + 1 end
        else
            stale = stale + 1
        end
    end

    Chat(string.format("Loaded blueprint group '%s': %d selected%s%s.",
        group.name or Trim(name),
        #selection.order,
        append and string.format(" (%d added)", added) or "",
        stale > 0 and string.format(", %d no longer placed", stale) or ""))
    return #selection.order, stale
end

function BlueprintTools.DeleteGroup(name)
    local houseId, reason = GetCurrentHouse(true)
    if not houseId then Chat(reason) return false end
    local _, groupKey = NormalizeGroupName(name)
    if not groupKey then Chat("Give the blueprint group name to delete.") return false end

    local houseGroups, storageReason = GetHouseGroupTable(houseId, false)
    if not houseGroups then Chat(storageReason) return false end
    local group = houseGroups[groupKey]
    if type(group) ~= "table" then
        Chat("No blueprint group named '" .. Trim(name) .. "' exists in this house.")
        return false
    end

    houseGroups[groupKey] = nil
    Chat("Deleted blueprint group '" .. (group.name or Trim(name)) .. "'.")
    return true
end

function BlueprintTools.ListGroups()
    local houseId, reason = GetCurrentHouse(false)
    if not houseId then Chat(reason) return {} end
    local houseGroups, storageReason = GetHouseGroupTable(houseId, false)
    if not houseGroups then Chat(storageReason) return {} end

    local list = {}
    for _, group in pairs(houseGroups) do
        if type(group) == "table" and type(group.ids) == "table" then
            list[#list + 1] = {
                name = group.name or "Unnamed Group",
                count = #group.ids,
                savedAt = group.savedAt or 0,
            }
        end
    end
    table.sort(list, function(left, right)
        return string.lower(left.name) < string.lower(right.name)
    end)

    if #list == 0 then
        Chat("No blueprint groups are saved for this house.")
    else
        Chat(string.format("Blueprint groups for this house (%d):", #list))
        for _, group in ipairs(list) do
            Chat(string.format("- %s (%d furnishing%s)", group.name, group.count, group.count == 1 and "" or "s"))
        end
    end
    return list
end

local function ReadFurnitureTransform(furnitureId, key, selectionIndex)
    if not HousingEditorGetFurnitureWorldPosition or not HousingEditorGetFurnitureOrientation then
        return nil, "Housing transform reads are unavailable."
    end

    local positionOk, worldX, worldY, worldZ = pcall(HousingEditorGetFurnitureWorldPosition, furnitureId)
    if not positionOk or not IsValidCoordinate(worldX) or not IsValidCoordinate(worldY) or not IsValidCoordinate(worldZ) then
        return nil, "invalid position"
    end
    local orientationOk, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, furnitureId)
    if not orientationOk or not IsFiniteNumber(pitch) or not IsFiniteNumber(yaw) or not IsFiniteNumber(roll) then
        return nil, "invalid orientation"
    end

    local parentId = nil
    if GetPlacedFurnitureParent then
        local parentOk, parentFurnitureId = pcall(GetPlacedFurnitureParent, furnitureId)
        if parentOk then parentId = IdToKey(parentFurnitureId) end
    end

    return {
        id = furnitureId,
        furnitureId = key or IdToKey(furnitureId),
        name = GetFurnitureName(furnitureId),
        x = worldX,
        y = worldY,
        z = worldZ,
        pitch = pitch,
        yaw = yaw,
        roll = roll,
        parentId = parentId,
        selectionIndex = selectionIndex or 0,
    }
end

local function CopyTransform(transform)
    return {
        id = transform.id,
        furnitureId = transform.furnitureId,
        name = transform.name,
        x = transform.x,
        y = transform.y,
        z = transform.z,
        pitch = transform.pitch,
        yaw = transform.yaw,
        roll = transform.roll,
        parentId = transform.parentId,
        selectionIndex = transform.selectionIndex,
    }
end

local function GetSelectedTransforms(minimumCount)
    local houseId, reason = GetCurrentHouse(true)
    if not houseId then Chat(reason) return nil, nil end

    local placedById, _, scanReason = BuildPlacedFurnitureIndex()
    if not placedById then Chat(scanReason) return nil, nil end
    local selection = EnsureSelection(houseId)
    local stale = PruneSelection(selection, placedById)
    if stale > 0 then Chat(string.format("Removed %d stale furnishing%s from the selection.", stale, stale == 1 and "" or "s")) end
    if #selection.order < (minimumCount or 1) then
        Chat(string.format("Select at least %d placed furnishing%s first.", minimumCount or 1, (minimumCount or 1) == 1 and "" or "s"))
        return nil, nil
    end
    if #selection.order > MAX_QUEUE_REQUESTS then
        Chat(string.format("The selection exceeds the %d-request precision safety limit.", MAX_QUEUE_REQUESTS))
        return nil, nil
    end

    local transforms = {}
    local failures = 0
    for index, key in ipairs(selection.order) do
        local transform = ReadFurnitureTransform(placedById[key], key, index)
        if transform then
            transforms[#transforms + 1] = transform
        else
            failures = failures + 1
        end
    end
    if failures > 0 then
        Chat(string.format("Could not read %d selected furnishing transform%s.", failures, failures == 1 and "" or "s"))
        return nil, nil
    end
    return houseId, transforms
end

local function MakeSavedSnapshot(houseId, action, transforms)
    local snapshot = {
        houseId = houseId,
        action = action or "Manual capture",
        capturedAt = GetTimeStamp and GetTimeStamp() or 0,
        items = {},
    }
    for _, transform in ipairs(transforms) do
        snapshot.items[#snapshot.items + 1] = {
            furnitureId = transform.furnitureId,
            name = transform.name,
            x = transform.x,
            y = transform.y,
            z = transform.z,
            pitch = transform.pitch,
            yaw = transform.yaw,
            roll = transform.roll,
            parentId = transform.parentId,
            selectionIndex = transform.selectionIndex,
        }
    end
    return snapshot
end

function BlueprintTools.CaptureTransforms()
    local houseId, transforms = GetSelectedTransforms(1)
    if not transforms then return nil end
    local snapshot = MakeSavedSnapshot(houseId, "Transform capture", transforms)
    Chat(string.format("Captured %d furnishing transform%s.", #snapshot.items, #snapshot.items == 1 and "" or "s"))
    return snapshot
end

function BlueprintTools.CaptureRecoverySnapshot(label)
    if BlueprintTools.activeQueue then
        Chat("Wait for the current blueprint precision operation to finish before replacing its recovery snapshot.")
        return nil
    end
    local houseId, transforms = GetSelectedTransforms(1)
    if not transforms then return nil end
    if type(HF.savedVars) ~= "table" then
        Chat("HousingForge has not finished loading its saved data.")
        return nil
    end
    HF.savedVars.blueprintRecovery = MakeSavedSnapshot(houseId, Trim(label) ~= "" and Trim(label) or "Manual recovery", transforms)
    Chat(string.format("Saved one-level recovery for %d furnishing%s.", #transforms, #transforms == 1 and "" or "s"))
    return HF.savedVars.blueprintRecovery
end

BlueprintTools.CaptureRecovery = BlueprintTools.CaptureRecoverySnapshot

function BlueprintTools.GetRequestDelayMs()
    local value = BlueprintTools.requestDelayMs
    if type(HF.savedVars) == "table" and type(HF.savedVars.settings) == "table" then
        value = HF.savedVars.settings.blueprintRequestDelayMs or value
    end
    if not IsFiniteNumber(value) and HF.GetHousingRequestDelayMs then
        value = HF.GetHousingRequestDelayMs()
    end
    if not IsFiniteNumber(value) then value = 350 end
    return math.max(MIN_REQUEST_DELAY_MS, math.min(MAX_REQUEST_DELAY_MS, Round(value)))
end

function BlueprintTools.SetRequestDelayMs(value)
    value = ParseFiniteNumber(value)
    if not value then
        Chat(string.format("Give a request delay between %d and %d milliseconds.", MIN_REQUEST_DELAY_MS, MAX_REQUEST_DELAY_MS))
        return false
    end
    value = math.max(MIN_REQUEST_DELAY_MS, math.min(MAX_REQUEST_DELAY_MS, Round(value)))
    BlueprintTools.requestDelayMs = value
    if type(HF.savedVars) == "table" then
        if type(HF.savedVars.settings) ~= "table" then HF.savedVars.settings = {} end
        HF.savedVars.settings.blueprintRequestDelayMs = value
    end
    Chat(string.format("Blueprint request delay set to %dms.", value))
    return true
end

local function TransformChanged(original, target)
    return original.x ~= target.x
        or original.y ~= target.y
        or original.z ~= target.z
        or math.abs(original.pitch - target.pitch) > TRANSFORM_EPSILON
        or math.abs(NormalizeAngle(original.yaw - target.yaw)) > TRANSFORM_EPSILON
        or math.abs(original.roll - target.roll) > TRANSFORM_EPSILON
end

local function ValidateTarget(target)
    return target
        and IdToKey(target.id)
        and IsValidCoordinate(target.x)
        and IsValidCoordinate(target.y)
        and IsValidCoordinate(target.z)
        and IsFiniteNumber(target.pitch)
        and IsFiniteNumber(target.yaw)
        and IsFiniteNumber(target.roll)
end

local function SortParentsBeforeChildren(targets)
    local byKey = {}
    for _, target in ipairs(targets) do byKey[target.furnitureId] = target end

    local depthCache = {}
    local function GetDepth(target, visiting)
        if depthCache[target.furnitureId] then return depthCache[target.furnitureId] end
        local parent = target.parentId and byKey[target.parentId] or nil
        if not parent then depthCache[target.furnitureId] = 0 return 0 end
        visiting = visiting or {}
        if visiting[target.furnitureId] then return 0 end
        visiting[target.furnitureId] = true
        local depth = 1 + GetDepth(parent, visiting)
        visiting[target.furnitureId] = nil
        depthCache[target.furnitureId] = depth
        return depth
    end

    table.sort(targets, function(left, right)
        local leftDepth = GetDepth(left)
        local rightDepth = GetDepth(right)
        if leftDepth ~= rightDepth then return leftDepth < rightDepth end
        return (left.selectionIndex or 0) < (right.selectionIndex or 0)
    end)
end

local ProcessQueueStep
local OnFurnitureMoved

local function UnregisterMoveEvent(queue)
    if not queue or not queue.moveEventRegistered then return end
    if EVENT_MANAGER and EVENT_HOUSING_FURNITURE_MOVED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(MOVE_EVENT_NAMESPACE, EVENT_HOUSING_FURNITURE_MOVED)
    end
    queue.moveEventRegistered = false
end

local function ClearActiveQueue(queue)
    UnregisterMoveEvent(queue)
    if queue then queue.pending = nil end
    if BlueprintTools.activeQueue == queue then BlueprintTools.activeQueue = nil end
    if HF.runtime and HF.runtime.blueprintQueue == queue then HF.runtime.blueprintQueue = nil end
end

local function BuildQueueResult(queue)
    return {
        action = queue.action,
        total = #queue.items,
        succeeded = queue.succeeded,
        failed = queue.failed,
        canceled = queue.canceled or false,
        aborted = queue.aborted or false,
        failures = queue.failures,
    }
end

local function FinishQueue(queue)
    ClearActiveQueue(queue)
    local result = BuildQueueResult(queue)
    BlueprintTools.lastQueueResult = result

    if queue.isUndo and queue.failed == 0 and not queue.aborted and type(HF.savedVars) == "table" then
        HF.savedVars.blueprintRecovery = nil
    end

    Chat(string.format("%s complete: %d confirmed, %d failed.", queue.action, queue.succeeded, queue.failed))
    if HF.RefreshUI then HF.RefreshUI() end
    if PlaySound then
        PlaySound(queue.failed == 0 and SOUNDS.OBJECTIVE_COMPLETED or SOUNDS.GENERAL_ALERT_ERROR)
    end
    if queue.callback then queue.callback(result) end
end

local function FinishCanceledQueue(queue, pendingResolution)
    if BlueprintTools.activeQueue ~= queue then return end
    queue.canceled = true
    queue.canceling = false
    ClearActiveQueue(queue)
    BlueprintTools.lastQueueResult = BuildQueueResult(queue)
    Chat(string.format("%s canceled after %d of %d confirmations%s. Use Undo to restore changed furnishings.",
        queue.action,
        queue.index - 1,
        #queue.items,
        pendingResolution and ("; " .. pendingResolution) or ""))
    if HF.RefreshUI then HF.RefreshUI() end
end

local function AbortQueueForHouseChange(queue)
    if BlueprintTools.activeQueue ~= queue then return end
    queue.aborted = true
    queue.failed = queue.failed + math.max(0, #queue.items - queue.index + 1)
    ClearActiveQueue(queue)
    BlueprintTools.lastQueueResult = BuildQueueResult(queue)
    Chat(queue.action .. " stopped because the owned house context changed. The recovery snapshot was kept.")
    if HF.RefreshUI then HF.RefreshUI() end
end

local function IsQueueContextCurrent(queue)
    local currentHouseId = GetCurrentHouse(true)
    if currentHouseId == queue.houseId then return true end
    AbortQueueForHouseChange(queue)
    return false
end

local function ReadbackMatchesTarget(target)
    if not HousingEditorGetFurnitureWorldPosition or not HousingEditorGetFurnitureOrientation then
        return false, "transform readback unavailable"
    end

    local positionOk, worldX, worldY, worldZ = pcall(HousingEditorGetFurnitureWorldPosition, target.id)
    if not positionOk or not IsFiniteNumber(worldX) or not IsFiniteNumber(worldY) or not IsFiniteNumber(worldZ) then
        return false, "position readback unavailable"
    end
    if math.abs(worldX - target.x) > READBACK_POSITION_EPSILON_CM
        or math.abs(worldY - target.y) > READBACK_POSITION_EPSILON_CM
        or math.abs(worldZ - target.z) > READBACK_POSITION_EPSILON_CM then
        return false, "position did not reach the requested transform"
    end

    local orientationOk, pitch, yaw, roll = pcall(HousingEditorGetFurnitureOrientation, target.id)
    if not orientationOk or not IsFiniteNumber(pitch) or not IsFiniteNumber(yaw) or not IsFiniteNumber(roll) then
        return false, "orientation readback unavailable"
    end
    if math.abs(NormalizeAngle(pitch - target.pitch)) > READBACK_ORIENTATION_EPSILON
        or math.abs(NormalizeAngle(yaw - target.yaw)) > READBACK_ORIENTATION_EPSILON
        or math.abs(NormalizeAngle(roll - target.roll)) > READBACK_ORIENTATION_EPSILON then
        return false, "orientation did not reach the requested transform"
    end

    return true
end

local function ScheduleQueueStep(queue, delayMs)
    if BlueprintTools.activeQueue ~= queue then return end
    local queueToken = queue.token
    if zo_callLater then
        zo_callLater(function()
            local activeQueue = BlueprintTools.activeQueue
            if activeQueue ~= queue or activeQueue.token ~= queueToken then return end
            ProcessQueueStep()
        end, delayMs or queue.delayMs)
    else
        ProcessQueueStep()
    end
end

local function CompletePendingTarget(queue, pending, success, result)
    if BlueprintTools.activeQueue ~= queue
        or queue.token ~= pending.queueToken
        or queue.pending ~= pending then
        return false
    end

    queue.pending = nil
    if success then
        queue.succeeded = queue.succeeded + 1
    else
        queue.failed = queue.failed + 1
        queue.failures[#queue.failures + 1] = {
            furnitureId = pending.target.furnitureId,
            name = pending.target.name,
            result = tostring(result or "move was not confirmed"),
        }
    end
    queue.index = queue.index + 1
    if HF.RefreshUI then HF.RefreshUI() end

    if queue.canceling then
        FinishCanceledQueue(queue, success and "the accepted request was confirmed" or "the accepted request could not be confirmed")
        return true
    end

    if queue.index > #queue.items then
        FinishQueue(queue)
    else
        ScheduleQueueStep(queue, queue.delayMs)
    end
    return true
end

local function CheckPendingTimeout(queueToken, pendingToken)
    local queue = BlueprintTools.activeQueue
    if not queue or queue.token ~= queueToken then return end
    local pending = queue.pending
    if not pending or pending.token ~= pendingToken or pending.queueToken ~= queueToken then return end
    if not IsQueueContextCurrent(queue) then return end

    local matches, readbackReason = ReadbackMatchesTarget(pending.target)
    if matches then
        CompletePendingTarget(queue, pending, true, pending.eventSeen and "move event and readback" or "timeout readback")
    else
        local reason = pending.eventSeen
            and ("move event arrived but " .. tostring(readbackReason))
            or ("confirmation timed out; " .. tostring(readbackReason))
        CompletePendingTarget(queue, pending, false, reason)
    end
end

OnFurnitureMoved = function(_, furnitureId)
    local queue = BlueprintTools.activeQueue
    local pending = queue and queue.pending or nil
    if not pending then return end
    if IdToKey(furnitureId) ~= pending.target.furnitureId then return end
    if not IsQueueContextCurrent(queue) then return end

    pending.eventSeen = true
    local matches, readbackReason = ReadbackMatchesTarget(pending.target)
    if matches then
        CompletePendingTarget(queue, pending, true, "move event and readback")
    else
        pending.lastReadbackReason = readbackReason
    end
end

local function RegisterMoveEvent(queue)
    if not EVENT_MANAGER or EVENT_HOUSING_FURNITURE_MOVED == nil then return false end
    EVENT_MANAGER:UnregisterForEvent(MOVE_EVENT_NAMESPACE, EVENT_HOUSING_FURNITURE_MOVED)
    EVENT_MANAGER:RegisterForEvent(MOVE_EVENT_NAMESPACE, EVENT_HOUSING_FURNITURE_MOVED, OnFurnitureMoved)
    queue.moveEventRegistered = true
    return true
end

ProcessQueueStep = function()
    local queue = BlueprintTools.activeQueue
    if not queue or queue.pending then return end
    if queue.canceled then
        FinishCanceledQueue(queue)
        return
    end
    if not IsQueueContextCurrent(queue) then return end

    local target = queue.items[queue.index]
    if not target then
        FinishQueue(queue)
        return
    end

    BlueprintTools.pendingSerial = BlueprintTools.pendingSerial + 1
    local pending = {
        token = BlueprintTools.pendingSerial,
        queueToken = queue.token,
        target = target,
        eventSeen = false,
    }
    queue.pending = pending

    -- A selected child may already have reached its requested world transform when
    -- its selected parent moved. Readback confirmation avoids sending a redundant request.
    local alreadyMatches = ReadbackMatchesTarget(target)
    if alreadyMatches then
        CompletePendingTarget(queue, pending, true, "pre-request readback")
        return
    end

    local ok, requestResult = pcall(
        HousingEditorRequestChangePositionAndOrientation,
        target.id,
        Round(target.x),
        Round(target.y),
        Round(target.z),
        NormalizeAngle(target.pitch),
        NormalizeAngle(target.yaw),
        NormalizeAngle(target.roll)
    )

    -- A synchronous moved event can confirm and clear this pending object from inside
    -- the request call. In that case its completion path has already advanced the queue.
    if BlueprintTools.activeQueue ~= queue or queue.pending ~= pending then return end
    if not ok or requestResult ~= HOUSING_REQUEST_RESULT_SUCCESS then
        CompletePendingTarget(queue, pending, false, ok and requestResult or requestResult)
        return
    end

    pending.requestAccepted = true
    if zo_callLater then
        zo_callLater(function()
            CheckPendingTimeout(pending.queueToken, pending.token)
        end, queue.confirmationTimeoutMs)
    else
        CheckPendingTimeout(pending.queueToken, pending.token)
    end
end

local function StartTransformQueue(action, originals, targets, options)
    options = options or {}
    if BlueprintTools.activeQueue then
        Chat("A blueprint precision operation is already running.")
        return false
    end
    if HF.runtime and HF.runtime.applyQueue then
        Chat("A HousingForge apply or clean queue is already running.")
        return false
    end
    if not HousingEditorRequestChangePositionAndOrientation then
        Chat("Housing transform requests are unavailable.")
        return false
    end

    local houseId, reason = GetCurrentHouse(true)
    if not houseId then Chat(reason) return false end
    if #targets == 0 then Chat("There are no furnishing transforms to apply.") return false end
    if #targets > MAX_QUEUE_REQUESTS then
        Chat(string.format("The operation exceeds the %d-request precision safety limit.", MAX_QUEUE_REQUESTS))
        return false
    end

    local originalById = {}
    for _, original in ipairs(originals) do originalById[original.furnitureId] = original end
    local changedTargets = {}
    local changedOriginals = {}
    for _, target in ipairs(targets) do
        local original = originalById[target.furnitureId]
        if not original or not ValidateTarget(target) then
            Chat("The operation produced an invalid furnishing transform and was not started.")
            return false
        end
        target.x = Round(target.x)
        target.y = Round(target.y)
        target.z = Round(target.z)
        target.pitch = NormalizeAngle(target.pitch)
        target.yaw = NormalizeAngle(target.yaw)
        target.roll = NormalizeAngle(target.roll)
        if TransformChanged(original, target) then
            changedTargets[#changedTargets + 1] = target
            changedOriginals[#changedOriginals + 1] = original
        end
    end

    if #changedTargets == 0 then
        if options.isUndo and type(HF.savedVars) == "table" then HF.savedVars.blueprintRecovery = nil end
        Chat(action .. " made no changes.")
        return true
    end

    if not options.isUndo then
        if type(HF.savedVars) ~= "table" then
            Chat("HousingForge has not finished loading its saved data.")
            return false
        end
        HF.savedVars.blueprintRecovery = MakeSavedSnapshot(houseId, action, changedOriginals)
    end

    SortParentsBeforeChildren(changedTargets)
    BlueprintTools.queueSerial = BlueprintTools.queueSerial + 1
    local delayMs = BlueprintTools.GetRequestDelayMs()
    local queue = {
        token = BlueprintTools.queueSerial,
        action = action,
        houseId = houseId,
        items = changedTargets,
        index = 1,
        succeeded = 0,
        failed = 0,
        failures = {},
        canceled = false,
        canceling = false,
        aborted = false,
        isUndo = options.isUndo or false,
        callback = options.callback,
        delayMs = delayMs,
        confirmationTimeoutMs = math.max(
            MIN_CONFIRMATION_TIMEOUT_MS,
            math.min(MAX_CONFIRMATION_TIMEOUT_MS, delayMs * CONFIRMATION_TIMEOUT_DELAY_MULTIPLIER)
        ),
        pending = nil,
        moveEventRegistered = false,
    }
    BlueprintTools.activeQueue = queue
    if HF.runtime then HF.runtime.blueprintQueue = queue end
    local eventRegistered = RegisterMoveEvent(queue)
    Chat(string.format("%s started: %d request%s at %dms; confirmation timeout %dms%s.",
        action,
        #changedTargets,
        #changedTargets == 1 and "" or "s",
        queue.delayMs,
        queue.confirmationTimeoutMs,
        eventRegistered and "" or " (readback fallback only)"))
    if HF.RefreshUI then HF.RefreshUI() end
    ScheduleQueueStep(queue, 0)
    return true
end

function BlueprintTools.IsBusy()
    return BlueprintTools.activeQueue ~= nil
end

function BlueprintTools.GetQueueStatus()
    local queue = BlueprintTools.activeQueue
    if not queue then return nil end
    return {
        action = queue.action,
        total = #queue.items,
        processed = queue.index - 1,
        succeeded = queue.succeeded,
        failed = queue.failed,
        delayMs = queue.delayMs,
        awaitingConfirmation = queue.pending ~= nil,
        pendingFurnitureId = queue.pending and queue.pending.target.furnitureId or nil,
        canceling = queue.canceling or false,
    }
end

function BlueprintTools.CancelOperation()
    local queue = BlueprintTools.activeQueue
    if not queue then Chat("No blueprint precision operation is running.") return false end
    if queue.canceling then
        Chat("Blueprint cancellation is already waiting for the accepted furnishing request to settle.")
        return true
    end

    queue.canceled = true
    local hadPendingRequest = queue.pending and queue.pending.requestAccepted or false
    if hadPendingRequest then
        queue.canceling = true
        Chat(string.format("Canceling %s: waiting up to %dms for the accepted furnishing request to settle.", queue.action, queue.confirmationTimeoutMs))
        if HF.RefreshUI then HF.RefreshUI() end
    else
        FinishCanceledQueue(queue)
    end
    return true
end

BlueprintTools.Cancel = BlueprintTools.CancelOperation

local function ParseAxis(axis, allowY)
    axis = type(axis) == "string" and string.lower(Trim(axis)) or ""
    if axis == "x" or axis == "z" or (allowY and axis == "y") then return axis end
    return nil
end

function BlueprintTools.Align(axis, mode)
    axis = ParseAxis(axis, true)
    mode = type(mode) == "string" and string.lower(Trim(mode)) or ""
    if not axis or (mode ~= "min" and mode ~= "center" and mode ~= "max" and mode ~= "first") then
        Chat("Usage: align <x|y|z> <min|center|max|first>.")
        return false
    end

    local _, originals = GetSelectedTransforms(2)
    if not originals then return false end
    local minimum = originals[1][axis]
    local maximum = minimum
    for index = 2, #originals do
        minimum = math.min(minimum, originals[index][axis])
        maximum = math.max(maximum, originals[index][axis])
    end

    local targetValue = minimum
    if mode == "max" then
        targetValue = maximum
    elseif mode == "center" then
        targetValue = (minimum + maximum) / 2
    elseif mode == "first" then
        targetValue = originals[1][axis]
    end

    local targets = {}
    for _, original in ipairs(originals) do
        local target = CopyTransform(original)
        target[axis] = targetValue
        targets[#targets + 1] = target
    end
    return StartTransformQueue(string.format("Align %s %s", string.upper(axis), mode), originals, targets)
end

function BlueprintTools.Distribute(axis)
    axis = ParseAxis(axis, true)
    if not axis then Chat("Usage: distribute <x|y|z>.") return false end
    local _, originals = GetSelectedTransforms(3)
    if not originals then return false end

    local targets = {}
    for _, original in ipairs(originals) do targets[#targets + 1] = CopyTransform(original) end
    table.sort(targets, function(left, right)
        if left[axis] ~= right[axis] then return left[axis] < right[axis] end
        return (left.selectionIndex or 0) < (right.selectionIndex or 0)
    end)

    local minimum = targets[1][axis]
    local maximum = targets[#targets][axis]
    if minimum == maximum then
        Chat("The selected furnishing pivots occupy the same " .. string.upper(axis) .. " position; there is no span to distribute.")
        return false
    end

    local step = (maximum - minimum) / (#targets - 1)
    for index, target in ipairs(targets) do
        target[axis] = minimum + ((index - 1) * step)
    end
    return StartTransformQueue("Distribute " .. string.upper(axis), originals, targets)
end

local function GetHorizontalSelectionCenter(transforms)
    local minX, maxX = transforms[1].x, transforms[1].x
    local minZ, maxZ = transforms[1].z, transforms[1].z
    for index = 2, #transforms do
        local transform = transforms[index]
        minX = math.min(minX, transform.x)
        maxX = math.max(maxX, transform.x)
        minZ = math.min(minZ, transform.z)
        maxZ = math.max(maxZ, transform.z)
    end
    return (minX + maxX) / 2, (minZ + maxZ) / 2
end

function BlueprintTools.Mirror(axis)
    axis = ParseAxis(axis, false)
    if not axis then Chat("Usage: mirror <x|z>.") return false end
    local _, originals = GetSelectedTransforms(1)
    if not originals then return false end
    local centerX, centerZ = GetHorizontalSelectionCenter(originals)

    local targets = {}
    for _, original in ipairs(originals) do
        local target = CopyTransform(original)
        if axis == "x" then
            target.x = (2 * centerX) - original.x
            target.yaw = -original.yaw
        else
            target.z = (2 * centerZ) - original.z
            target.yaw = math.pi - original.yaw
        end
        targets[#targets + 1] = target
    end
    return StartTransformQueue("Mirror around " .. string.upper(axis), originals, targets)
end

function BlueprintTools.Move(dx, dy, dz)
    dx, dy, dz = ParseOffset(dx), ParseOffset(dy), ParseOffset(dz)
    if dx == nil or dy == nil or dz == nil then
        Chat("Usage: move <dx> <dy> <dz>, in housing world centimeters.")
        return false
    end
    local _, originals = GetSelectedTransforms(1)
    if not originals then return false end

    local targets = {}
    for _, original in ipairs(originals) do
        local target = CopyTransform(original)
        target.x = original.x + dx
        target.y = original.y + dy
        target.z = original.z + dz
        targets[#targets + 1] = target
    end
    return StartTransformQueue(string.format("Move group (%g, %g, %g)", dx, dy, dz), originals, targets)
end

function BlueprintTools.Rotate(yawDegrees)
    yawDegrees = ParseFiniteNumber(yawDegrees)
    if not yawDegrees then
        Chat("Usage: rotate <yaw degrees>.")
        return false
    end
    local _, originals = GetSelectedTransforms(1)
    if not originals then return false end

    yawDegrees = yawDegrees % 360
    if yawDegrees > 180 then yawDegrees = yawDegrees - 360 end
    local radians = yawDegrees * math.pi / 180
    local sine = math.sin(radians)
    local cosine = math.cos(radians)
    local centerX, centerZ = GetHorizontalSelectionCenter(originals)
    local targets = {}
    for _, original in ipairs(originals) do
        local offsetX = original.x - centerX
        local offsetZ = original.z - centerZ
        local target = CopyTransform(original)
        -- ESO's horizontal facing convention is x = sin(yaw), z = cos(yaw).
        target.x = centerX + (offsetX * cosine) + (offsetZ * sine)
        target.z = centerZ - (offsetX * sine) + (offsetZ * cosine)
        target.yaw = original.yaw + radians
        targets[#targets + 1] = target
    end
    return StartTransformQueue(string.format("Rotate group %g degrees", yawDegrees), originals, targets)
end

BlueprintTools.RotateYaw = BlueprintTools.Rotate

function BlueprintTools.Undo()
    if BlueprintTools.activeQueue then
        Chat("Wait for the current blueprint precision operation to finish or cancel it first.")
        return false
    end
    if type(HF.savedVars) ~= "table" or type(HF.savedVars.blueprintRecovery) ~= "table" then
        Chat("No blueprint precision operation is available to undo.")
        return false
    end

    local recovery = HF.savedVars.blueprintRecovery
    local houseId, reason = GetCurrentHouse(true)
    if not houseId then Chat(reason) return false end
    if recovery.houseId ~= houseId then
        Chat("The recovery snapshot belongs to a different house.")
        return false
    end
    if type(recovery.items) ~= "table" or #recovery.items == 0 then
        Chat("The recovery snapshot is empty.")
        return false
    end

    local placedById, _, scanReason = BuildPlacedFurnitureIndex()
    if not placedById then Chat(scanReason) return false end
    local originals = {}
    local targets = {}
    local stale = 0
    for index, saved in ipairs(recovery.items) do
        local key = type(saved.furnitureId) == "string" and saved.furnitureId or IdToKey(saved.furnitureId)
        local furnitureId = key and placedById[key] or nil
        if furnitureId then
            local current = ReadFurnitureTransform(furnitureId, key, saved.selectionIndex or index)
            local target = {
                id = furnitureId,
                furnitureId = key,
                name = saved.name or (current and current.name),
                x = saved.x,
                y = saved.y,
                z = saved.z,
                pitch = saved.pitch,
                yaw = saved.yaw,
                roll = saved.roll,
                parentId = saved.parentId,
                selectionIndex = saved.selectionIndex or index,
            }
            if current and ValidateTarget(target) then
                originals[#originals + 1] = current
                targets[#targets + 1] = target
            else
                stale = stale + 1
            end
        else
            stale = stale + 1
        end
    end

    if #targets == 0 then
        Chat("None of the furnishings in the recovery snapshot are still placed in this house.")
        return false
    end
    if stale > 0 then
        Chat(string.format("Undo will skip %d missing or invalid furnishing%s.", stale, stale == 1 and "" or "s"))
    end
    return StartTransformQueue("Undo " .. (recovery.action or "precision operation"), originals, targets, { isUndo = true })
end

BlueprintTools.UndoLast = BlueprintTools.Undo
