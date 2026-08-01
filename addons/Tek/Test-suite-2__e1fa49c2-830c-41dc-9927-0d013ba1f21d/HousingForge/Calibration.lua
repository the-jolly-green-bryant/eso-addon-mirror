HF.Calibration = {}

local MARKER_ROLES = {
    { key = "floor", label = "Floor Center", itemName = "Common Crate, Sealed" },
    { key = "ceiling", label = "Ceiling Center", itemName = "Common Campfire, Outdoor" },
    { key = "corner1", label = "Corner 1", itemName = "Common Basket, Closed" },
    { key = "corner2", label = "Corner 2", itemName = "Common Basket, Lid" },
    { key = "corner3", label = "Corner 3", itemName = "Common Basket, Open" },
    { key = "corner4", label = "Corner 4", itemName = "Common Basket, Tall" },
    { key = "door_left", label = "Door Left", itemName = "Common Bowl, Serving" },
    { key = "door_right", label = "Door Right", itemName = "Common Firepit, Outdoor" },
    { key = "door_top", label = "Door Top", itemName = "Noble's Chalice" },
}

local ROLE_LABELS = {}
for _, role in ipairs(MARKER_ROLES) do
    ROLE_LABELS[role.key] = role.label
end

local function NormalizeName(value)
    value = string.lower(tostring(value or ""))
    value = string.gsub(value, "|c%x%x%x%x%x%x", "")
    value = string.gsub(value, "|r", "")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

local function GetRecipeText()
    local lines = {}
    for _, role in ipairs(MARKER_ROLES) do
        table.insert(lines, string.format("%s = %s", role.label, role.itemName))
    end
    return table.concat(lines, "\n")
end

local function EnsureCalibration()
    if type(HF.savedVars.calibration) ~= "table" then
        HF.savedVars.calibration = ZO_DeepTableCopy(HF.defaults.calibration)
    end
    if type(HF.savedVars.calibration.markerFurnitureDataIds) ~= "table" then
        HF.savedVars.calibration.markerFurnitureDataIds = {}
    end
    if type(HF.savedVars.calibration.rooms) ~= "table" then
        HF.savedVars.calibration.rooms = {}
    end
    return HF.savedVars.calibration
end

local function GetSelectedOrTargetedFurnitureId()
    local furnitureId = nil
    if HousingEditorGetSelectedFurnitureId then
        furnitureId = HousingEditorGetSelectedFurnitureId()
    end
    if furnitureId then return furnitureId end

    if HousingEditorCanSelectTargettedFurniture and HousingEditorCanSelectTargettedFurniture() and HousingEditorSelectTargettedFurniture then
        HousingEditorSelectTargettedFurniture()
        if HousingEditorGetSelectedFurnitureId then
            furnitureId = HousingEditorGetSelectedFurnitureId()
        end
    end
    return furnitureId
end

local function GetPlacedEntry(furnitureId)
    local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
    local worldX, worldY, worldZ = HousingEditorGetFurnitureWorldPosition(furnitureId)
    local pitch, yaw, roll = HousingEditorGetFurnitureOrientation(furnitureId)
    return {
        furnitureId = furnitureId,
        furnitureDataId = furnitureDataId or 0,
        itemName = itemName or "Unknown Marker",
        icon = icon or "",
        worldX = worldX or 0,
        worldY = worldY or 0,
        worldZ = worldZ or 0,
        pitch = pitch or 0,
        yaw = yaw or 0,
        roll = roll or 0,
    }
end

local function FindMarkers()
    local calibration = EnsureCalibration()
    local found = {}
    local furnitureId = nil
    local recipeByName = {}

    for _, role in ipairs(MARKER_ROLES) do
        recipeByName[NormalizeName(role.itemName)] = role.key
    end

    while true do
        furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
        if not furnitureId then break end

        local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
        local recipeRole = recipeByName[NormalizeName(itemName)]
        if recipeRole and not found[recipeRole] then
            found[recipeRole] = GetPlacedEntry(furnitureId)
            found[recipeRole].itemName = itemName or found[recipeRole].itemName
            found[recipeRole].icon = icon or found[recipeRole].icon
        end

        for role, markerFurnitureDataId in pairs(calibration.markerFurnitureDataIds) do
            if markerFurnitureDataId ~= 0 and markerFurnitureDataId == furnitureDataId then
                found[role] = GetPlacedEntry(furnitureId)
                found[role].itemName = itemName or found[role].itemName
                found[role].icon = icon or found[role].icon
            end
        end
    end

    return found
end

function HF.Calibration.ShowHelp()
    HF.Chat("Calibration recipe: place the 9 listed items, then run /hf scanroom Room Name")
    HF.Chat("Addons cannot add items to inventory; buy/craft/place these markers yourself.")
    HF.Calibration.ShowMarkerChecklist()
end

function HF.Calibration.ShowMarkerChecklist()
    local calibration = EnsureCalibration()
    HF.Chat("Calibration marker recipe:")
    for _, role in ipairs(MARKER_ROLES) do
        local marker = calibration.markerFurnitureDataIds[role.key]
        local override = marker and (" override id " .. tostring(marker)) or ""
        HF.Chat(string.format("%s: %s%s", role.label, role.itemName, override))
    end
end

function HF.Calibration.GetRecipeText()
    return GetRecipeText()
end

function HF.Calibration.GetRecipeRole(index)
    return MARKER_ROLES[index]
end

function HF.Calibration.RegisterSelectedMarker(role)
    role = role and string.lower(string.match(role, "^%s*(%S+)") or "") or ""
    if not ROLE_LABELS[role] then
        HF.Chat("Usage: /hf calmark floor|ceiling|corner1|corner2|corner3|corner4|door_left|door_right|door_top")
        return false
    end

    local furnitureId = GetSelectedOrTargetedFurnitureId()
    if not furnitureId then
        HF.Chat("Select or aim at a placed furniture marker in housing editor first.")
        return false
    end

    local itemName, _, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
    if not furnitureDataId or furnitureDataId == 0 then
        HF.Chat("Could not read furnitureDataId from selected marker.")
        return false
    end

    local calibration = EnsureCalibration()
    calibration.markerFurnitureDataIds[role] = furnitureDataId
    HF.Chat(string.format("Registered %s marker: %s (%d)", ROLE_LABELS[role], itemName or "Unknown", furnitureDataId))
    return true
end

function HF.Calibration.ScanRoom(roomName)
    if not GetCurrentZoneHouseId or GetCurrentZoneHouseId() == 0 then
        HF.Chat("You must be inside a house to scan calibration markers.")
        return nil
    end

    roomName = roomName and string.match(roomName, "^%s*(.-)%s*$") or ""
    if roomName == "" then
        roomName = "Room " .. tostring(#EnsureCalibration().rooms + 1)
    end

    local found = FindMarkers()
    local missing = {}
    for _, role in ipairs(MARKER_ROLES) do
        if not found[role.key] then
            table.insert(missing, role.key)
        end
    end

    if #missing > 0 then
        HF.Chat("Missing calibration markers: " .. table.concat(missing, ", "))
        HF.Chat("Use /hf calmarkers to check registered marker IDs.")
        return nil
    end

    local calibration = EnsureCalibration()
    local room = {
        name = roomName,
        houseId = GetCurrentZoneHouseId(),
        houseName = HF.GetCurrentHouseName(),
        timestamp = GetTimeStamp(),
        floor = found.floor,
        ceiling = found.ceiling,
        corners = { found.corner1, found.corner2, found.corner3, found.corner4 },
        doors = {
            {
                left = found.door_left,
                right = found.door_right,
                top = found.door_top,
            },
        },
    }

    table.insert(calibration.rooms, room)
    HF.Chat(string.format("Saved calibration for %s with 4 corners and 1 doorway.", roomName))
    if PlaySound then PlaySound(SOUNDS.OBJECTIVE_COMPLETED) end
    return room
end
