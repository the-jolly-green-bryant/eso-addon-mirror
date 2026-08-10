HF.LayoutRecorder = {}

local function FurnitureIdToString(furnitureId)
    if not furnitureId then return nil end
    if Id64ToString then
        local ok, value = pcall(Id64ToString, furnitureId)
        if ok and value and value ~= "" then return value end
    end
    return tostring(furnitureId)
end

local function ExtractCollectibleId(collectibleLink)
    if not collectibleLink or collectibleLink == "" then return 0 end
    local collectibleId = string.match(collectibleLink, "|H.-:collectible:(%d+)")
    return tonumber(collectibleId) or 0
end

local function BuildFurnitureEntry(furnitureId)
    local itemName, icon, furnitureDataId = GetPlacedHousingFurnitureInfo(furnitureId)
    local itemLink, collectibleLink = GetPlacedFurnitureLink(furnitureId, LINK_STYLE_DEFAULT)
    local worldX, worldY, worldZ = HousingEditorGetFurnitureWorldPosition(furnitureId)
    local pitch, yaw, roll = HousingEditorGetFurnitureOrientation(furnitureId)
    local stateIndex = 0
    if GetPlacedHousingFurnitureCurrentObjectStateIndex then
        stateIndex = GetPlacedHousingFurnitureCurrentObjectStateIndex(furnitureId) or 0
    end

    local parentFurnitureId = nil
    if GetPlacedFurnitureParent then
        parentFurnitureId = GetPlacedFurnitureParent(furnitureId)
    end

    local path = nil
    if HousingEditorGetNumPathNodesForFurniture then
        local numPathNodes = HousingEditorGetNumPathNodesForFurniture(furnitureId) or 0
        if numPathNodes > 0 then
            path = {
                state = HousingEditorGetFurniturePathState and HousingEditorGetFurniturePathState(furnitureId) or nil,
                followType = HousingEditorGetFurniturePathFollowType and HousingEditorGetFurniturePathFollowType(furnitureId) or nil,
                startingNodeIndex = HousingEditorGetStartingNodeIndexForPath and HousingEditorGetStartingNodeIndexForPath(furnitureId) or 1,
                nodes = {},
            }
            for pathIndex = 1, numPathNodes do
                local pathX, pathY, pathZ = HousingEditorGetPathNodeWorldPosition(furnitureId, pathIndex)
                local pathPitch, pathYaw, pathRoll = HousingEditorGetPathNodeOrientation(furnitureId, pathIndex)
                table.insert(path.nodes, {
                    worldX = pathX or 0,
                    worldY = pathY or 0,
                    worldZ = pathZ or 0,
                    pitch = pathPitch or 0,
                    yaw = pathYaw or 0,
                    roll = pathRoll or 0,
                    speed = HousingEditorPathNodeSpeed and HousingEditorPathNodeSpeed(furnitureId, pathIndex) or nil,
                    delayMs = HousingEditorPathNodeDelayTime and HousingEditorPathNodeDelayTime(furnitureId, pathIndex) or 0,
                })
            end
        end
    end

    local itemId = 0
    if itemLink and itemLink ~= "" and GetItemLinkItemId then
        itemId = GetItemLinkItemId(itemLink) or 0
    end

    local collectibleId = ExtractCollectibleId(collectibleLink)
    local name = HF.GetSafeLinkName(itemLink, itemName)
    if (not name or name == "Unknown Furniture") and collectibleId ~= 0 and GetCollectibleName then
        local collectibleName = GetCollectibleName(collectibleId)
        if collectibleName and collectibleName ~= "" then name = collectibleName end
    end

    return {
        sourceFurnitureId = FurnitureIdToString(furnitureId),
        parentSourceFurnitureId = FurnitureIdToString(parentFurnitureId),
        furnitureDataId = furnitureDataId or 0,
        itemName = name or itemName or "Unknown Furniture",
        icon = icon or "",
        itemLink = itemLink or "",
        collectibleLink = collectibleLink or "",
        itemId = itemId or 0,
        collectibleId = collectibleId or 0,
        worldX = worldX or 0,
        worldY = worldY or 0,
        worldZ = worldZ or 0,
        pitch = pitch or 0,
        yaw = yaw or 0,
        roll = roll or 0,
        stateIndex = stateIndex or 0,
        path = path,
    }
end

function HF.LayoutRecorder.CanRecord()
    if not GetCurrentZoneHouseId or GetCurrentZoneHouseId() == 0 then
        return false, "You must be inside a house."
    end
    if not IsOwnerOfCurrentHouse or not IsOwnerOfCurrentHouse() then
        return false, "You must be inside a house you own."
    end
    return true
end

local function CanScanHouse(requireOwnership)
    if not GetCurrentZoneHouseId or GetCurrentZoneHouseId() == 0 then
        return false, "You must be inside a house."
    end
    if requireOwnership and (not IsOwnerOfCurrentHouse or not IsOwnerOfCurrentHouse()) then
        return false, "You must be inside a house you own."
    end
    return true
end

local function GetCurrentHouseOwnerName()
    if GetCurrentHouseOwner then
        local owner = GetCurrentHouseOwner()
        if owner and owner ~= "" then return owner end
    end
    if GetCurrentHouseTourListingOwnerDisplayName then
        local owner = GetCurrentHouseTourListingOwnerDisplayName()
        if owner and owner ~= "" then return owner end
    end
    return ""
end

local function RecordHouseInternal(nameOverride, options)
    options = options or {}
    local canRecord, reason = CanScanHouse(options.requireOwnership)
    if not canRecord then
        HF.Chat(reason)
        return nil, reason
    end

    local isOwner = IsOwnerOfCurrentHouse and IsOwnerOfCurrentHouse() or false
    local source = options.source or (isOwner and "owned" or "visited")
    local houseName = HF.GetCurrentHouseName()
    local ownerName = GetCurrentHouseOwnerName()
    if type(nameOverride) == "string" then
        nameOverride = string.match(nameOverride, "^%s*(.-)%s*$") or ""
        if nameOverride == "" then nameOverride = nil end
        if nameOverride and #nameOverride > 64 then nameOverride = string.sub(nameOverride, 1, 64) end
    else
        nameOverride = nil
    end
    local layout = {
        id = HF.MakeLayoutId(),
        name = nameOverride or (source == "visited" and ("Copy of " .. houseName) or (houseName .. " Layout")),
        author = GetDisplayName and GetDisplayName() or "",
        houseId = GetCurrentZoneHouseId(),
        houseName = houseName,
        ownerName = ownerName,
        source = source,
        copied = source == "visited",
        canApplyInCurrentHouse = isOwner,
        timestamp = GetTimeStamp(),
        snapshotVersion = 2,
        coordinateSpace = "world",
        furnitureCount = 0,
        items = {},
    }

    local furnitureIds = options.furnitureIds or HF.LayoutRecorder.GetAllPlacedFurnitureIds()
    for _, furnitureId in ipairs(furnitureIds) do
        local ok, entry = pcall(BuildFurnitureEntry, furnitureId)
        if ok and entry then
            table.insert(layout.items, entry)
        else
            HF.Debug("Failed to capture furniture: " .. tostring(entry))
            if options.strict then
                local failure = string.format("Safety snapshot stopped: furnishing %s could not be captured (%s).", FurnitureIdToString(furnitureId) or "unknown", tostring(entry))
                HF.Chat(failure)
                return nil, failure
            end
        end
    end

    if options.strict and #layout.items ~= #furnitureIds then
        local failure = string.format("Safety snapshot stopped: captured %d of %d furnishings.", #layout.items, #furnitureIds)
        HF.Chat(failure)
        return nil, failure
    end

    layout.furnitureCount = #layout.items
    HF.savedVars.layouts[layout.id] = layout
    HF.savedVars.lastSelectedLayoutId = layout.id
    if source == "visited" then
        HF.Chat(string.format("Copied %d furniture items from %s%s.", layout.furnitureCount, layout.houseName or "current house", ownerName ~= "" and (" by " .. ownerName) or ""))
    else
        HF.Chat(string.format("Recorded %d furniture items from %s.", layout.furnitureCount, layout.houseName or "current house"))
    end
    if PlaySound then PlaySound(SOUNDS.OBJECTIVE_COMPLETED) end
    return layout
end

function HF.LayoutRecorder.RecordCurrentHouse(nameOverride)
    return RecordHouseInternal(nameOverride, { requireOwnership = true, source = "owned" })
end

function HF.LayoutRecorder.CopyCurrentHouse(nameOverride)
    return RecordHouseInternal(nameOverride, { requireOwnership = false, source = "visited" })
end

local function PruneRecoveryLayouts(houseId)
    if not HF.savedVars or type(HF.savedVars.layouts) ~= "table" then return end
    local maxRecovery = HF.savedVars.settings and HF.savedVars.settings.maxRecoverySnapshots or 5
    maxRecovery = math.max(1, math.min(20, tonumber(maxRecovery) or 5))
    local recoveries = {}
    for id, layout in pairs(HF.savedVars.layouts) do
        if layout and layout.isRecovery and layout.houseId == houseId then
            table.insert(recoveries, { id = id, timestamp = layout.timestamp or 0 })
        end
    end
    table.sort(recoveries, function(a, b) return a.timestamp > b.timestamp end)
    for index = maxRecovery + 1, #recoveries do
        HF.savedVars.layouts[recoveries[index].id] = nil
    end
end

function HF.LayoutRecorder.RecordRecoverySnapshot(reason, expectedFurnitureIds)
    local houseName = HF.GetCurrentHouseName()
    local timestamp = GetTimeStamp()
    local readableTime = os.date and os.date("%m/%d/%y %H:%M:%S", timestamp) or HF.FormatTimestamp(timestamp)
    local name = string.format("Recovery - %s - %s", houseName, readableTime)
    local layout, captureReason = RecordHouseInternal(name, {
        requireOwnership = true,
        source = "recovery",
        strict = true,
        furnitureIds = expectedFurnitureIds,
    })
    if layout then
        layout.isRecovery = true
        layout.recoveryReason = tostring(reason or "destructive housing operation")
        PruneRecoveryLayouts(layout.houseId)
        HF.Chat("Safety snapshot saved before changing the house.")
    end
    return layout, captureReason
end

function HF.LayoutRecorder.GetAllPlacedFurnitureIds()
    local ids = {}
    local furnitureId = nil
    while true do
        furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
        if not furnitureId then break end
        table.insert(ids, furnitureId)
    end
    return ids
end
