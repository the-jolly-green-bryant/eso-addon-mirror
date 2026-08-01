FlamechasersTravelSlots = {}
local FTS = FlamechasersTravelSlots
local WM = WINDOW_MANAGER
local ADDON_NAME = "FlamechasersTravelSlots"
local SAVED_VARIABLES_NAME = "FlamechasersTravelSlotsSavedVariables"
-- Keep the wrapper version unchanged so existing data is never reset merely
-- because the active namespace is now server-specific.
local SAVED_VARIABLES_VERSION = 3
local SV

FTS.version = "0.7.5"
FTS.resultRows = {}
FTS.resultOffset = 0

local COLOR = {
    blue = "|c55BFFF",
    white = "|cFFFFFF",
    gray = "|c98A6B8",
    green = "|c72D69A",
    gold = "|cEBCB70",
    red = "|cFF7777",
}

local DEFAULT_ACCENT = { 0.25, 0.72, 1, 0.95 }
local ACCENT_PRESETS = {
    { 0.25, 0.72, 1, 1 },
    { 0.30, 0.86, 0.56, 1 },
    { 0.95, 0.72, 0.26, 1 },
    { 0.95, 0.38, 0.34, 1 },
    { 0.72, 0.42, 0.95, 1 },
    { 0.96, 0.44, 0.72, 1 },
    { 0.30, 0.84, 0.88, 1 },
    { 0.88, 0.91, 0.96, 1 },
}

local function Trim(text)
    return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function Lower(text)
    return zo_strlower(text or "")
end

local function DeepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do
        copy[DeepCopy(key)] = DeepCopy(child)
    end
    return copy
end

local function IsOwnAccount(displayName)
    if not GetDisplayName then return false end
    return Lower(Trim(displayName)) == Lower(Trim(GetDisplayName()))
end

local function CompactDisplayName(destination)
    if destination.customName and Trim(destination.customName) ~= "" then
        return Trim(destination.customName)
    end
    local name = destination.name or "Destination"
    if destination.kind == "primaryHouse" then
        return destination.owner or name
    end
    name = name:gsub("^Trial:%s*", "")
        :gsub("^Dungeon:%s*", "")
        :gsub("^Arena:%s*", "")
        :gsub("%s+[Ww]ayshrine$", "")
        :gsub("%s+[Dd]ungeon$", "")
        :gsub("%s+[Hh]ouse$", "")
    return Trim(name)
end

local function HouseZoneName(houseId)
    if not houseId or not GetHouseFoundInZoneId or not GetZoneNameById then return nil end
    local zoneId = GetHouseFoundInZoneId(houseId)
    local name = zoneId and zoneId > 0 and GetZoneNameById(zoneId)
    return name and name ~= "" and zo_strformat("<<C:1>>", name) or nil
end

local function HouseDisplayName(houseId)
    if GetCollectibleIdForHouse and GetCollectibleName then
        local collectibleId = GetCollectibleIdForHouse(houseId)
        local name = collectibleId and collectibleId > 0 and GetCollectibleName(collectibleId)
        if name and name ~= "" then return zo_strformat("<<C:1>>", name) end
    end
    local fallback = GetHouseName and GetHouseName(houseId)
    if fallback and fallback ~= "" and Lower(fallback) ~= "current" then
        return zo_strformat("<<C:1>>", fallback)
    end
    return HouseZoneName(houseId) or "Player House"
end

local GENERIC_HOUSE_ICON = "EsoUI/Art/MapPins/MapPin_house.dds"
local QUEST_TRAVEL_ICON = "EsoUI/Art/Quest/questJournal_trackedQuest_icon.dds"

local function HouseIcon(houseId)
    if houseId and GetCollectibleIdForHouse then
        local collectibleId = GetCollectibleIdForHouse(houseId)
        if collectibleId and collectibleId > 0 then
            if GetCollectibleIcon then
                local icon = GetCollectibleIcon(collectibleId)
                if icon and icon ~= "" then return icon end
            end
            if GetCollectibleInfo then
                local _, _, icon = GetCollectibleInfo(collectibleId)
                if icon and icon ~= "" then return icon end
            end
        end
    end
    return GENERIC_HOUSE_ICON
end

local function NodeZoneName(nodeIndex, fallback)
    if GetFastTravelNodePOIIndicies and GetZoneNameByIndex then
        local zoneIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        local name = zoneIndex and zoneIndex > 0 and GetZoneNameByIndex(zoneIndex)
        if name and name ~= "" then return zo_strformat("<<C:1>>", name) end
    end
    return fallback
end

local function MakeLabel(parent, name, text, font)
    local c = WM:CreateControl(name, parent, CT_LABEL)
    c:SetFont(font or "ZoFontGame")
    c:SetColor(1, 1, 1, 1)
    c:SetText(text or "")
    return c
end

local function MakeButton(parent, name, text)
    local c = WM:CreateControl(name, parent, CT_BUTTON)
    c:SetFont("ZoFontGame")
    c:SetNormalFontColor(0.9, 0.94, 1, 1)
    c:SetMouseOverFontColor(0.35, 0.75, 1, 1)
    c:SetPressedFontColor(0.25, 0.62, 0.9, 1)
    c:SetText(text or "")
    return c
end

local function MakeBackdrop(parent, name, fill)
    local c = WM:CreateControl(name, parent, CT_BACKDROP)
    if fill then c:SetAnchorFill(parent) end
    c:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    c:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16)
    c:SetInsets(8, 8, -8, -8)
    c:SetCenterColor(0.025, 0.035, 0.055, 0.98)
    c:SetEdgeColor(0.22, 0.48, 0.7, 1)
    return c
end

local function MakeEdit(parent, name, hint, width, maxChars)
    local bg = MakeBackdrop(parent, name .. "Backdrop", false)
    bg:SetDimensions(width or 650, 42)
    local edit = WM:CreateControlFromVirtual(name, bg, "ZO_DefaultEditForBackdrop")
    edit:SetAnchorFill(bg)
    edit:SetMaxInputChars(maxChars or 100)
    edit:SetDefaultText(hint or "")
    return bg, edit
end

local TYPE_NAMES = {}
local function RegisterType(globalName, label)
    local value = _G[globalName]
    if value ~= nil then TYPE_NAMES[value] = label end
end
RegisterType("POI_TYPE_WAYSHRINE", "WAYSHRINE")
RegisterType("POI_TYPE_GROUP_DUNGEON", "DUNGEON")
RegisterType("POI_TYPE_PUBLIC_DUNGEON", "PUBLIC DUNGEON")
RegisterType("POI_TYPE_DUNGEON", "DELVE")
RegisterType("POI_TYPE_RAID_DUNGEON", "TRIAL")
RegisterType("POI_TYPE_ARENA", "ARENA")
RegisterType("POI_TYPE_HOUSE", "HOUSE")
RegisterType("POI_TYPE_ENDLESS_DUNGEON", "INFINITE ARCHIVE")

local function CategoryForNode(poiType, name, icon)
    if TYPE_NAMES[poiType] then return TYPE_NAMES[poiType] end
    return "DESTINATION"
end

function FTS.SetStatus(message, isError)
    if FTS.status and FTS.window and not FTS.window:IsHidden() then
        FTS.status:SetText((isError and COLOR.red or COLOR.gray) .. message .. "|r")
    elseif d then
        d((isError and COLOR.red or COLOR.gray) .. "[Flamechasers] " .. message .. "|r")
    end
end

function FTS.HoldCursorMode()
    if SetGameCameraUIMode then SetGameCameraUIMode(true) end
end

function FTS.Open()
    FTS.CreateWindow()
    FTS.cursorWasActive = IsGameCameraUIModeActive and IsGameCameraUIModeActive() or false
    FTS.window:SetHidden(false)
    FTS.window:BringWindowToTop()
    FTS.HoldCursorMode()
    local maintainCursor = function(_, time)
        if not FTS.nextCursorCheck or time >= FTS.nextCursorCheck then
            FTS.nextCursorCheck = time + 0.1
            FTS.HoldCursorMode()
        end
    end
    FTS.window:SetHandler("OnUpdate", maintainCursor)
    if FTS.picker then FTS.picker:SetHandler("OnUpdate", maintainCursor) end
    if FTS.slotEditor then FTS.slotEditor:SetHandler("OnUpdate", maintainCursor) end
    if FTS.iconPicker then FTS.iconPicker:SetHandler("OnUpdate", maintainCursor) end
end

function FTS.Close(forceCursorOff)
    if not FTS.window then return end
    if FTS.picker then FTS.picker:SetHidden(true) end
    if FTS.slotEditor then FTS.slotEditor:SetHidden(true) end
    if FTS.iconPicker then FTS.iconPicker:SetHidden(true) end
    FTS.window:SetHandler("OnUpdate", nil)
    if FTS.picker then FTS.picker:SetHandler("OnUpdate", nil) end
    if FTS.slotEditor then FTS.slotEditor:SetHandler("OnUpdate", nil) end
    if FTS.iconPicker then FTS.iconPicker:SetHandler("OnUpdate", nil) end
    FTS.window:SetHidden(true)
    if SetGameCameraUIMode and (forceCursorOff or not FTS.cursorWasActive) then
        SetGameCameraUIMode(false)
    end
end

function FTS.LoadAllHouses()
    if FTS.allHouses then return FTS.allHouses end
    local houses, seen = {}, {}
    if ZO_COLLECTIBLE_DATA_MANAGER then
        local function AddCollectible(collectibleData)
            local id = GetCollectibleReferenceId(collectibleData:GetId())
            local name = collectibleData:GetName()
            if id and id > 0 and name and name ~= "" and not seen[id] then
                seen[id] = true
                houses[#houses + 1] = {
                    kind = "houseDefinition",
                    id = id,
                    collectibleId = collectibleData:GetId(),
                    name = zo_strformat("<<C:1>>", name),
                    zone = HouseZoneName(id),
                }
            end
        end
        for _, categoryData in ZO_COLLECTIBLE_DATA_MANAGER:CategoryIterator({}) do
            if categoryData:IsHousingCategory() then
                for _, collectibleData in categoryData:CollectibleIterator({}) do
                    AddCollectible(collectibleData)
                end
                for _, subcategory in categoryData:SubcategoryIterator({}) do
                    for _, collectibleData in subcategory:CollectibleIterator({}) do
                        AddCollectible(collectibleData)
                    end
                end
            end
        end
    elseif GetNumHouses and GetHouseId and GetHouseName then
        for i = 1, GetNumHouses() do
            local id = GetHouseId(i)
            local name = id and GetHouseName(id)
            if name and name ~= "" then
                houses[#houses + 1] = {
                    kind = "houseDefinition", id = id, name = name, zone = HouseZoneName(id)
                }
            end
        end
    end
    table.sort(houses, function(a, b) return a.name < b.name end)
    FTS.allHouses = houses
    return houses
end

function FTS.PrepareCurrentMap()
    if not SetMapToPlayerLocation then return "Current zone" end
    SetMapToPlayerLocation()
    if GetMapType and MapZoomOut then
        local attempts = 0
        while GetMapType() == MAPTYPE_SUBZONE and attempts < 5 do
            MapZoomOut()
            attempts = attempts + 1
        end
    end
    local name = GetMapName and GetMapName() or GetUnitZone("player")
    return zo_strformat("<<C:1>>", name or "Current zone")
end

function FTS.BuildDestinations()
    local currentMapName = FTS.PrepareCurrentMap()
    local destinations = {
        {
            kind = "focusedQuest",
            name = "Focused Quest",
            category = "QUEST",
            known = true,
            current = true,
            priority = 100,
            icon = QUEST_TRAVEL_ICON,
            search = "focused quest active assisted tracked objective questing nearest wayshrine",
        },
        {
            kind = "leader",
            name = "Group Leader",
            category = "PLAYER",
            known = true,
            current = false,
            search = "group leader player",
        },
    }
    if GetNumFastTravelNodes and GetFastTravelNodeInfo then
        for nodeIndex = 1, GetNumFastTravelNodes() do
            local known, name, _, _, icon, _, poiType, shown, collectibleLocked =
                GetFastTravelNodeInfo(nodeIndex)
            if name and name ~= "" then
                local category = CategoryForNode(poiType, name, icon)
                local zone = NodeZoneName(nodeIndex, shown and currentMapName or nil)
                destinations[#destinations + 1] = {
                    kind = "node",
                    id = nodeIndex,
                    name = zo_strformat("<<C:1>>", name),
                    category = category,
                    known = known == true,
                    locked = collectibleLocked == true,
                    current = shown == true,
                    zone = zone,
                    icon = icon,
                    search = Lower(name .. " " .. category .. " " .. (zone or "")),
                }
            end
        end
    end
    table.sort(destinations, function(a, b)
        if (a.priority or 0) ~= (b.priority or 0) then
            return (a.priority or 0) > (b.priority or 0)
        end
        if a.current ~= b.current then return a.current end
        if a.known ~= b.known then return a.known end
        if a.category ~= b.category then return a.category < b.category end
        return a.name < b.name
    end)
    FTS.destinations = destinations
    FTS.currentMapName = currentMapName
end

function FTS.SlotLocation(destination)
    if destination.zone and destination.zone ~= "" then return destination.zone end
    if destination.kind == "node" and destination.id then
        destination.zone = NodeZoneName(destination.id)
    elseif destination.kind == "ownedHouse" or destination.kind == "playerHouse" then
        destination.zone = HouseZoneName(destination.id)
    elseif destination.kind == "primaryHouse" then
        return "Primary residence"
    elseif destination.kind == "leader" then
        return "Group leader's location"
    elseif destination.kind == "focusedQuest" then
        local questIndex = FTS.GetFocusedQuestIndex()
        if questIndex then
            local questName = GetJournalQuestName(questIndex)
            if questName and questName ~= "" then
                return zo_strformat("<<C:1>>", questName)
            end
        end
        return "No focused quest"
    end
    return destination.zone or "Location unavailable"
end

function FTS.RefreshSlots()
    for i = 1, 16 do
        local destination = SV.slots[i]
        if destination then
            local displayName = CompactDisplayName(destination)
            FTS.slotNames[i]:SetFont(#displayName > 23 and "ZoFontGameSmall" or "ZoFontGame")
            FTS.slotNames[i]:SetText(COLOR.white .. displayName .. "|r")
            local note = Trim(destination.note)
            FTS.slotNotes[i]:SetText(note ~= "" and (COLOR.gray .. note .. "|r") or "")
            FTS.slotDetails[i]:SetText("|c707D8C" .. FTS.SlotLocation(destination) .. "|r")
            local icon = destination.customIcon or destination.icon
            if not icon or icon == "" then
                if destination.kind == "leader" then
                    icon = "EsoUI/Art/Contacts/social_status_online.dds"
                elseif destination.kind == "focusedQuest" then
                    icon = QUEST_TRAVEL_ICON
                elseif destination.kind == "ownedHouse"
                    or destination.kind == "playerHouse"
                    or destination.kind == "primaryHouse" then
                    icon = HouseIcon(destination.id)
                    destination.icon = icon
                else
                    icon = GENERIC_HOUSE_ICON
                end
            end
            FTS.slotIcons[i]:SetTexture(icon)
            FTS.slotIcons[i]:SetHidden(false)
            local accent = destination.accentColor or DEFAULT_ACCENT
            FTS.slotAccents[i]:SetColor(accent[1], accent[2], accent[3], accent[4] or 1)
            FTS.slotCards[i]:SetAlpha(1)
        else
            FTS.slotNames[i]:SetFont("ZoFontGame")
            FTS.slotNames[i]:SetText("|c718092+ Set destination|r")
            FTS.slotNotes[i]:SetText("")
            FTS.slotDetails[i]:SetText("|c596879EMPTY SLOT|r")
            FTS.slotIcons[i]:SetTexture("EsoUI/Art/Buttons/plus_up.dds")
            FTS.slotIcons[i]:SetHidden(false)
            FTS.slotAccents[i]:SetColor(0.11, 0.18, 0.25, 0.55)
            FTS.slotCards[i]:SetAlpha(0.58)
        end
    end
end

function FTS.Assign(destination)
    SV.slots[FTS.editingSlot] = destination
    FTS.ClosePicker()
    FTS.RefreshSlots()
    FTS.SetStatus("Slot " .. FTS.editingSlot .. " set to " .. destination.name .. ".")
    FTS.OpenSlotEditor(FTS.editingSlot, true)
end

function FTS.GetFocusedQuestIndex()
    if QUEST_JOURNAL_MANAGER and QUEST_JOURNAL_MANAGER.GetFocusedQuestIndex then
        local questIndex = QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex()
        if questIndex and IsValidQuestIndex(questIndex) then return questIndex end
    end
    if GetNumTracked and GetTrackedByIndex and GetTrackedIsAssisted then
        for trackedIndex = 1, GetNumTracked() do
            local trackType, arg1, arg2 = GetTrackedByIndex(trackedIndex)
            if trackType == TRACK_TYPE_QUEST
                and GetTrackedIsAssisted(trackType, arg1, arg2)
                and IsValidQuestIndex(arg1) then
                return arg1
            end
        end
    end
    return nil
end

function FTS.FindExactQuestNode(questIndex)
    if not (GetJournalQuestLocationInfo and GetFastTravelNodePOIIndicies) then return nil end
    local _, _, questZoneIndex, questPoiIndex = GetJournalQuestLocationInfo(questIndex)
    if not questZoneIndex or not questPoiIndex
        or questZoneIndex <= 0 or questPoiIndex <= 0 then return nil end
    for nodeIndex = 1, GetNumFastTravelNodes() do
        local nodeZoneIndex, nodePoiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        if nodeZoneIndex == questZoneIndex and nodePoiIndex == questPoiIndex then
            local known, name, _, _, icon, _, poiType, _, locked =
                GetFastTravelNodeInfo(nodeIndex)
            local category = CategoryForNode(poiType, name, icon)
            if known and not locked and category ~= "WAYSHRINE" then
                return nodeIndex, name
            end
        end
    end
    return nil
end

function FTS.FindNearestShownWayshrine(targetX, targetY)
    local closestIndex, closestName, closestDistance
    for nodeIndex = 1, GetNumFastTravelNodes() do
        local known, name, x, y, icon, _, poiType, shown, locked =
            GetFastTravelNodeInfo(nodeIndex)
        if known and shown and not locked
            and CategoryForNode(poiType, name, icon) == "WAYSHRINE" then
            local dx, dy = (x or 0) - targetX, (y or 0) - targetY
            local distance = dx * dx + dy * dy
            if not closestDistance or distance < closestDistance then
                closestIndex, closestName, closestDistance = nodeIndex, name, distance
            end
        end
    end
    return closestIndex, closestName
end

function FTS.FindKnownWayshrineInZone(zoneIndex)
    if not zoneIndex or zoneIndex <= 0 then return nil end
    for nodeIndex = 1, GetNumFastTravelNodes() do
        local nodeZoneIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        if nodeZoneIndex == zoneIndex then
            local known, name, _, _, icon, _, poiType, _, locked =
                GetFastTravelNodeInfo(nodeIndex)
            if known and not locked
                and CategoryForNode(poiType, name, icon) == "WAYSHRINE" then
                return nodeIndex, name
            end
        end
    end
    return nil
end

function FTS.CompleteQuestTravel(nodeIndex, nodeName, directKeybind)
    if not nodeIndex then return false end
    FTS.questTravelRequest = nil
    FastTravelToNode(nodeIndex)
    FTS.SetStatus("Travelling near the focused quest via " ..
        zo_strformat("<<C:1>>", nodeName or "wayshrine") .. ".")
    if not directKeybind then FTS.Close(true) end
    return true
end

function FTS.RequestFocusedQuestPosition(request)
    local taskId = RequestJournalQuestConditionAssistance(
        request.questIndex, request.stepIndex, request.conditionIndex)
    if not taskId then return false end
    request.taskId = taskId
    FTS.questTravelRequest = request
    zo_callLater(function()
        local pending = FTS.questTravelRequest
        if not pending or pending.taskId ~= taskId then return end
        if CancelRequestJournalQuestConditionAssistance then
            CancelRequestJournalQuestConditionAssistance(taskId)
        end
        pending.taskId = nil
        local nodeIndex, nodeName = FTS.FindKnownWayshrineInZone(pending.zoneIndex)
        if not FTS.CompleteQuestTravel(nodeIndex, nodeName, pending.directKeybind) then
            FTS.questTravelRequest = nil
            if SetMapToPlayerLocation then SetMapToPlayerLocation() end
            FTS.SetStatus("ESO could not resolve the focused quest objective.", true)
        end
    end, 2500)
    return true
end

function FTS.ResolveFocusedQuestPosition(taskId, targetX, targetY)
    local request = FTS.questTravelRequest
    if not request or request.taskId ~= taskId then return end
    request.taskId = nil

    if targetX and targetY
        and targetX >= 0 and targetX <= 1
        and targetY >= 0 and targetY <= 1 then
        local nodeIndex, nodeName = FTS.FindNearestShownWayshrine(targetX, targetY)
        if FTS.CompleteQuestTravel(nodeIndex, nodeName, request.directKeybind) then return end
    end

    if request.zoomAttempts < 5 and MapZoomOut then
        local previousMapName = GetMapName and GetMapName() or ""
        MapZoomOut()
        local newMapName = GetMapName and GetMapName() or ""
        if newMapName ~= previousMapName then
            request.zoomAttempts = request.zoomAttempts + 1
            if FTS.RequestFocusedQuestPosition(request) then return end
        end
    end

    local nodeIndex, nodeName = FTS.FindKnownWayshrineInZone(request.zoneIndex)
    if FTS.CompleteQuestTravel(nodeIndex, nodeName, request.directKeybind) then return end
    FTS.questTravelRequest = nil
    if SetMapToPlayerLocation then SetMapToPlayerLocation() end
    FTS.SetStatus(
        "ESO did not expose a reachable wayshrine for the focused quest objective.", true)
end

function FTS.TravelToFocusedQuest(directKeybind)
    local questIndex = FTS.GetFocusedQuestIndex()
    if not questIndex then
        FTS.SetStatus("Focus a quest first, then use this slot again.", true)
        return
    end

    if FTS.questTravelRequest and FTS.questTravelRequest.taskId
        and CancelRequestJournalQuestConditionAssistance then
        CancelRequestJournalQuestConditionAssistance(FTS.questTravelRequest.taskId)
    end
    FTS.questTravelRequest = nil

    local exactNodeIndex, exactNodeName = FTS.FindExactQuestNode(questIndex)
    if FTS.CompleteQuestTravel(exactNodeIndex, exactNodeName, directKeybind) then return end

    local _, _, zoneIndex = GetJournalQuestLocationInfo(questIndex)
    local selectedStep, selectedCondition
    for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
        for conditionIndex = 1, GetJournalQuestNumConditions(questIndex, stepIndex) do
            local _, _, isFailCondition, isComplete =
                GetJournalQuestConditionValues(questIndex, stepIndex, conditionIndex)
            if not isFailCondition and not isComplete
                and (not DoesJournalQuestConditionHavePosition
                    or DoesJournalQuestConditionHavePosition(
                        questIndex, stepIndex, conditionIndex)) then
                local result = SetMapToQuestCondition(
                    questIndex, stepIndex, conditionIndex)
                if result ~= SET_MAP_RESULT_FAILED then
                    selectedStep, selectedCondition = stepIndex, conditionIndex
                    break
                end
            end
        end
        if selectedStep then break end
    end

    if not selectedStep then
        for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
            if IsJournalQuestStepEnding(questIndex, stepIndex)
                and SetMapToQuestStepEnding(questIndex, stepIndex)
                    ~= SET_MAP_RESULT_FAILED then
                selectedStep, selectedCondition = stepIndex, 1
                break
            end
        end
    end

    if not selectedStep then
        local nodeIndex, nodeName = FTS.FindKnownWayshrineInZone(zoneIndex)
        if FTS.CompleteQuestTravel(nodeIndex, nodeName, directKeybind) then return end
        if SetMapToPlayerLocation then SetMapToPlayerLocation() end
        FTS.SetStatus(
            "The focused quest has no travel location available at this step.", true)
        return
    end

    local request = {
        questIndex = questIndex,
        stepIndex = selectedStep,
        conditionIndex = selectedCondition,
        zoneIndex = zoneIndex,
        zoomAttempts = 0,
        directKeybind = directKeybind,
    }
    FTS.SetStatus("Finding the closest wayshrine to " ..
        zo_strformat("<<C:1>>", GetJournalQuestName(questIndex)) .. "...")
    if not FTS.RequestFocusedQuestPosition(request) then
        local nodeIndex, nodeName = FTS.FindKnownWayshrineInZone(zoneIndex)
        if not FTS.CompleteQuestTravel(nodeIndex, nodeName, directKeybind) then
            if SetMapToPlayerLocation then SetMapToPlayerLocation() end
            FTS.SetStatus("ESO could not resolve the focused quest objective.", true)
        end
    end
end

function FTS.Travel(index, directKeybind)
    local destination = SV.slots[index]
    if not destination then
        if directKeybind then
            FTS.SetStatus("Travel slot " .. index .. " is empty.", true)
        else
            FTS.OpenPicker(index)
        end
        return
    end
    if IsUnitInCombat("player") then
        FTS.SetStatus("Travel is unavailable during combat.", true)
        return
    end
    if destination.kind == "node" then
        local currentName
        if destination.id then
            local ignored
            ignored, currentName = GetFastTravelNodeInfo(destination.id)
        end
        if not currentName or zo_strformat("<<C:1>>", currentName) ~= destination.name then
            destination.id = nil
            for nodeIndex = 1, GetNumFastTravelNodes() do
                local _, candidateName = GetFastTravelNodeInfo(nodeIndex)
                if candidateName and zo_strformat("<<C:1>>", candidateName) == destination.name then
                    destination.id = nodeIndex
                    break
                end
            end
        end
        if not destination.id then
            FTS.SetStatus(destination.name .. " is no longer present in the travel database.", true)
            return
        end
        local known, name, _, _, _, _, _, _, collectibleLocked = GetFastTravelNodeInfo(destination.id)
        if collectibleLocked then
            FTS.SetStatus(name .. " is locked by unavailable content.", true)
        elseif not known then
            FTS.SetStatus(name .. " has not been discovered on this character.", true)
        else
            FastTravelToNode(destination.id)
            if not directKeybind then FTS.Close(true) end
        end
    elseif destination.kind == "ownedHouse" then
        RequestJumpToHouse(destination.id, false)
        if not directKeybind then FTS.Close(true) end
    elseif destination.kind == "playerHouse" then
        if IsOwnAccount(destination.owner) then
            -- Visiting your own account through JumpToSpecificHouse is treated
            -- as a player jump and ESO rejects it as "cannot jump to self".
            destination.kind = "ownedHouse"
            destination.owner = nil
            RequestJumpToHouse(destination.id, false)
        else
            JumpToSpecificHouse(destination.owner, destination.id)
        end
        if not directKeybind then FTS.Close(true) end
    elseif destination.kind == "primaryHouse" then
        if IsOwnAccount(destination.owner) then
            local houseId = GetHousingPrimaryHouse and GetHousingPrimaryHouse() or 0
            if houseId and houseId > 0 then
                destination.kind = "ownedHouse"
                destination.id = houseId
                destination.name = HouseDisplayName(houseId)
                destination.owner = nil
                destination.zone = HouseZoneName(houseId)
                destination.icon = HouseIcon(houseId)
                RequestJumpToHouse(houseId, false)
                if not directKeybind then FTS.Close(true) end
            else
                FTS.SetStatus("No primary residence is currently set.", true)
            end
        else
            JumpToHouse(destination.owner)
            if not directKeybind then FTS.Close(true) end
        end
    elseif destination.kind == "leader" then
        if IsUnitGrouped("player") then
            JumpToGroupLeader()
            if not directKeybind then FTS.Close(true) end
        else FTS.SetStatus("You are not currently grouped.", true) end
    elseif destination.kind == "focusedQuest" then
        FTS.TravelToFocusedQuest(directKeybind)
    end
end

function FTS.TravelFromKeybind(index)
    index = tonumber(index)
    if not index or index < 1 or index > 16 then return end
    FTS.CreateWindow()
    FTS.Travel(index, true)
end

function FTS.Score(destination, query)
    local name = Lower(destination.name)
    local search = destination.search or name
    if name == query then return 1000 end
    if name:sub(1, #query) == query then return 800 end
    local at = name:find(query, 1, true)
    if at then return 600 - at end
    at = search:find(query, 1, true)
    if at then return 400 - at end
    local cursor = 1
    for char in query:gmatch(".") do
        local found = search:find(char, cursor, true)
        if not found then return nil end
        cursor = found + 1
    end
    return 100
end

function FTS.UpdateResults(resetOffset)
    if resetOffset then FTS.resultOffset = 0 end
    local query = Lower(Trim(FTS.search:GetText()))
    local matches = {}
    for _, destination in ipairs(FTS.destinations or {}) do
        if query == "" then
            if destination.current then matches[#matches + 1] = destination end
        else
            local score = FTS.Score(destination, query)
            if score then
                destination.score = score + (destination.known and 20 or 0) + (destination.current and 10 or 0)
                matches[#matches + 1] = destination
            end
        end
    end
    if query ~= "" then
        table.sort(matches, function(a, b)
            if a.score ~= b.score then return a.score > b.score end
            return a.name < b.name
        end)
    end
    FTS.matches = matches
    local maxOffset = math.max(0, #matches - #FTS.resultRows)
    FTS.resultOffset = zo_clamp(FTS.resultOffset, 0, maxOffset)
    for rowIndex, row in ipairs(FTS.resultRows) do
        local destination = matches[rowIndex + FTS.resultOffset]
        row.destination = destination
        row.root:SetHidden(destination == nil)
        if destination then
            local state = destination.locked and COLOR.red .. "LOCKED"
                or destination.known and COLOR.green .. "AVAILABLE"
                or COLOR.gold .. "UNDISCOVERED"
            row.name:SetText(COLOR.white .. destination.name .. "|r")
            row.detail:SetText(COLOR.blue .. destination.category .. "|r  " .. state .. "|r")
            if destination.icon and destination.icon ~= "" then
                row.icon:SetTexture(destination.icon)
                row.icon:SetHidden(false)
            else
                row.icon:SetHidden(true)
            end
        end
    end
    local label = query == "" and ("Current map: " .. FTS.currentMapName) or
        (#matches .. " matching destinations")
    FTS.resultsTitle:SetText(COLOR.gray .. label .. "|r")
    FTS.scrollHint:SetHidden(#matches <= #FTS.resultRows)
end

function FTS.ShowSearchMode()
    FTS.housePanel:SetHidden(true)
    FTS.searchArea:SetHidden(false)
    FTS.search:SetText("")
    FTS.UpdateResults(true)
end

function FTS.ShowHouseMode()
    FTS.searchArea:SetHidden(true)
    FTS.housePanel:SetHidden(false)
    FTS.ownerEdit:SetText("")
    FTS.BuildOwnerSuggestions()
    FTS.UpdateOwnerSuggestions()
end

function FTS.BuildOwnerSuggestions()
    local names, seen = {}, {}
    local function Add(displayName)
        displayName = Trim(displayName)
        if displayName ~= "" and displayName:sub(1, 1) ~= "@" then
            displayName = "@" .. displayName
        end
        local key = Lower(displayName)
        if displayName ~= "" and not seen[key] and displayName ~= GetDisplayName() then
            seen[key] = true
            names[#names + 1] = displayName
        end
    end

    if GetNumFriends and GetFriendInfo then
        for i = 1, GetNumFriends() do
            Add(GetFriendInfo(i))
        end
    end
    if GetGroupSize and GetUnitDisplayName then
        for i = 1, GetGroupSize() do
            Add(GetUnitDisplayName("group" .. i))
        end
    end
    for _, destination in pairs(SV.slots) do
        if destination and destination.owner then Add(destination.owner) end
    end
    table.sort(names, function(a, b) return Lower(a) < Lower(b) end)
    FTS.ownerSuggestions = names
end

function FTS.UpdateOwnerSuggestions()
    if not FTS.ownerRows or not FTS.noOwnerSuggestions then return end
    local query = Lower(Trim(FTS.ownerEdit:GetText()))
    if query == "@" then query = "" end
    local shown = 0
    for _, displayName in ipairs(FTS.ownerSuggestions or {}) do
        local comparable = Lower(displayName)
        local plain = comparable:gsub("^@", "")
        local wanted = query:gsub("^@", "")
        if wanted == "" or plain:find(wanted, 1, true) then
            shown = shown + 1
            if shown <= #FTS.ownerRows then
                local row = FTS.ownerRows[shown]
                row.displayName = displayName
                row:SetText(displayName)
                row:SetHidden(false)
            end
        end
        if shown >= #FTS.ownerRows then break end
    end
    for i = shown + 1, #FTS.ownerRows do
        FTS.ownerRows[i].displayName = nil
        FTS.ownerRows[i]:SetHidden(true)
    end
    FTS.noOwnerSuggestions:SetHidden(shown > 0)
end

function FTS.UpdateHouseSuggestions()
    local query = Lower(Trim(FTS.houseEdit:GetText()))
    local houses = FTS.LoadAllHouses()
    local shown = 0
    for _, house in ipairs(houses) do
        if query == "" or Lower(house.name):find(query, 1, true) then
            shown = shown + 1
            if shown <= #FTS.houseRows then
                local row = FTS.houseRows[shown]
                row.house = house
                row:SetText(house.name)
                row:SetHidden(false)
            end
        end
        if shown >= #FTS.houseRows then break end
    end
    for i = shown + 1, #FTS.houseRows do
        FTS.houseRows[i].house = nil
        FTS.houseRows[i]:SetHidden(true)
    end
end

function FTS.AssignPlayerHouse(house)
    local owner = Trim(FTS.ownerEdit:GetText())
    if owner == "" then
        FTS.pickerStatus:SetText(COLOR.red .. "Enter the owner's account name first.|r")
        return
    end
    if owner:sub(1, 1) ~= "@" then owner = "@" .. owner end
    local mine = IsOwnAccount(owner)
    FTS.Assign({
        kind = mine and "ownedHouse" or "playerHouse",
        id = house.id,
        name = house.name,
        owner = mine and nil or owner,
        zone = house.zone or HouseZoneName(house.id),
        icon = HouseIcon(house.id),
    })
end

function FTS.AssignPrimaryHouse()
    local owner = Trim(FTS.ownerEdit:GetText())
    if owner == "" then
        FTS.pickerStatus:SetText(COLOR.red .. "Enter the owner's account name first.|r")
        return
    end
    if owner:sub(1, 1) ~= "@" then owner = "@" .. owner end
    if IsOwnAccount(owner) then
        local houseId = GetHousingPrimaryHouse and GetHousingPrimaryHouse() or 0
        if not houseId or houseId == 0 then
            FTS.pickerStatus:SetText(COLOR.red .. "No primary residence is currently set.|r")
            return
        end
        FTS.Assign({
            kind = "ownedHouse",
            id = houseId,
            name = HouseDisplayName(houseId),
            zone = HouseZoneName(houseId),
            icon = HouseIcon(houseId),
        })
        return
    end
    FTS.Assign({
        kind = "primaryHouse",
        name = owner .. "'s Primary Residence",
        owner = owner,
        zone = "Primary residence",
        icon = GENERIC_HOUSE_ICON,
    })
end

function FTS.SaveCurrentHouse()
    local houseId = GetCurrentZoneHouseId and GetCurrentZoneHouseId() or 0
    if not houseId or houseId == 0 then
        FTS.pickerStatus:SetText(COLOR.red .. "You are not currently inside a player house.|r")
        return
    end
    local owner = GetCurrentHouseOwner and GetCurrentHouseOwner() or GetDisplayName()
    local name = HouseDisplayName(houseId)
    local mine = owner == GetDisplayName()
    FTS.Assign({
        kind = mine and "ownedHouse" or "playerHouse",
        id = houseId,
        name = zo_strformat("<<C:1>>", name),
        owner = owner,
        zone = HouseZoneName(houseId),
        icon = HouseIcon(houseId),
    })
end

function FTS.CreateResultRow(parent, index)
    local root = MakeBackdrop(parent, "FTSResult" .. index, false)
    root:SetDimensions(660, 48)
    root:SetAnchor(TOPLEFT, parent, TOPLEFT, 20, 102 + ((index - 1) * 51))
    root:SetCenterColor(0.045, 0.06, 0.085, 0.9)
    local icon = WM:CreateControl("FTSResultIcon" .. index, root, CT_TEXTURE)
    icon:SetDimensions(34, 34)
    icon:SetAnchor(LEFT, root, LEFT, 9, 0)
    local name = MakeLabel(root, "FTSResultName" .. index, "", "ZoFontGame")
    name:SetAnchor(TOPLEFT, root, TOPLEFT, 52, 6)
    name:SetDimensions(590, 21)
    local detail = MakeLabel(root, "FTSResultDetail" .. index, "", "ZoFontGameSmall")
    detail:SetAnchor(TOPLEFT, name, BOTTOMLEFT, 0, -1)
    local hit = MakeButton(root, "FTSResultHit" .. index, "")
    hit:SetAnchorFill(root)
    local row = { root = root, icon = icon, name = name, detail = detail, hit = hit }
    hit:SetHandler("OnClicked", function()
        if row.destination then FTS.Assign(row.destination) end
    end)
    return row
end

function FTS.CreatePicker()
    local p = WM:CreateTopLevelWindow("FlamechasersTravelPicker")
    p:SetDimensions(720, 720)
    p:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    p:SetDrawLayer(DL_OVERLAY)
    p:SetDrawTier(DT_HIGH)
    p:SetDrawLevel(110)
    p:SetMouseEnabled(true)
    p:SetClampedToScreen(true)
    p:SetHidden(true)
    MakeBackdrop(p, "FlamechasersTravelPickerBackdrop", true)
    FTS.picker = p

    local header = WM:CreateControl("FTSPickerHeader", p, CT_BACKDROP)
    header:SetDimensions(704, 82)
    header:SetAnchor(TOP, p, TOP, 0, 8)
    header:SetCenterColor(0.025, 0.095, 0.15, 0.98)
    header:SetEdgeColor(0, 0, 0, 0)
    local headerLine = WM:CreateControl("FTSPickerHeaderLine", header, CT_TEXTURE)
    headerLine:SetDimensions(704, 2)
    headerLine:SetAnchor(BOTTOM, header, BOTTOM, 0, 0)
    headerLine:SetColor(0.25, 0.72, 1, 0.9)

    FTS.pickerTitle = MakeLabel(p, "FTSPickerTitle", "", "ZoFontWinH2")
    FTS.pickerTitle:SetAnchor(TOPLEFT, p, TOPLEFT, 22, 15)
    local close = MakeButton(p, "FTSPickerClose", "CLOSE")
    close:SetDimensions(75, 32)
    close:SetAnchor(TOPRIGHT, p, TOPRIGHT, -18, 13)
    close:SetHandler("OnClicked", function() FTS.ClosePicker() end)

    local searchTab = MakeButton(p, "FTSSearchTab", "DESTINATIONS")
    searchTab:SetDimensions(145, 30)
    searchTab:SetAnchor(TOPLEFT, p, TOPLEFT, 20, 56)
    searchTab:SetHandler("OnClicked", function() FTS.ShowSearchMode() end)
    local houseTab = MakeButton(p, "FTSHouseTab", "PLAYER HOUSE")
    houseTab:SetDimensions(130, 30)
    houseTab:SetAnchor(LEFT, searchTab, RIGHT, 8, 0)
    houseTab:SetHandler("OnClicked", function() FTS.ShowHouseMode() end)
    local saveCurrent = MakeButton(p, "FTSSaveCurrent", "SAVE CURRENT HOUSE")
    saveCurrent:SetDimensions(180, 30)
    saveCurrent:SetAnchor(LEFT, houseTab, RIGHT, 8, 0)
    saveCurrent:SetHandler("OnClicked", function() FTS.SaveCurrentHouse() end)

    local searchArea = WM:CreateControl("FTSSearchArea", p, CT_CONTROL)
    searchArea:SetAnchor(TOPLEFT, p, TOPLEFT, 0, 88)
    searchArea:SetDimensions(720, 610)
    FTS.searchArea = searchArea
    local searchBg, search = MakeEdit(searchArea, "FTSSearchEdit", "Search every permanent destination…")
    searchBg:SetAnchor(TOPLEFT, searchArea, TOPLEFT, 20, 0)
    search:SetHandler("OnTextChanged", function() FTS.UpdateResults(true) end)
    FTS.search = search
    FTS.resultsTitle = MakeLabel(searchArea, "FTSResultsTitle", "", "ZoFontGameSmall")
    FTS.resultsTitle:SetAnchor(TOPLEFT, searchBg, BOTTOMLEFT, 2, 7)
    for i = 1, 10 do FTS.resultRows[i] = FTS.CreateResultRow(searchArea, i) end
    FTS.scrollHint = MakeLabel(searchArea, "FTSScrollHint", "Mouse wheel for more results", "ZoFontGameSmall")
    FTS.scrollHint:SetAnchor(BOTTOMRIGHT, searchArea, BOTTOMRIGHT, -22, -5)
    searchArea:SetHandler("OnMouseWheel", function(_, delta)
        FTS.resultOffset = FTS.resultOffset - delta * 3
        FTS.UpdateResults(false)
    end)

    local hp = WM:CreateControl("FTSHousePanel", p, CT_CONTROL)
    hp:SetAnchor(TOPLEFT, p, TOPLEFT, 0, 94)
    hp:SetDimensions(720, 600)
    hp:SetHidden(true)
    FTS.housePanel = hp
    local ownerLabel = MakeLabel(hp, "FTSOwnerLabel", "Owner account name", "ZoFontGame")
    ownerLabel:SetAnchor(TOPLEFT, hp, TOPLEFT, 22, 2)
    local ownerBg, ownerEdit = MakeEdit(hp, "FTSOwnerEdit", "@username")
    ownerBg:SetAnchor(TOPLEFT, ownerLabel, BOTTOMLEFT, -2, 7)
    FTS.ownerEdit = ownerEdit
    ownerEdit:SetHandler("OnTextChanged", function() FTS.UpdateOwnerSuggestions() end)

    local primary = MakeButton(hp, "FTSPrimaryButton", "SAVE PRIMARY RESIDENCE")
    primary:SetDimensions(260, 38)
    primary:SetAnchor(TOPLEFT, ownerBg, BOTTOMLEFT, 0, 12)
    primary:SetHandler("OnClicked", function() FTS.AssignPrimaryHouse() end)

    local suggestionsLabel = MakeLabel(hp, "FTSOwnerSuggestionsLabel",
        "SUGGESTIONS · FRIENDS, CURRENT GROUP, SAVED OWNERS", "ZoFontGameSmall")
    suggestionsLabel:SetColor(0.45, 0.56, 0.66, 1)
    suggestionsLabel:SetAnchor(TOPLEFT, ownerBg, BOTTOMLEFT, 2, 62)
    FTS.ownerRows = {}
    for i = 1, 6 do
        local row = MakeButton(hp, "FTSOwnerRow" .. i, "")
        row:SetDimensions(630, 34)
        row:SetAnchor(TOPLEFT, suggestionsLabel, BOTTOMLEFT, 4, 7 + ((i - 1) * 37))
        row:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        row:SetHandler("OnClicked", function(control)
            if control.displayName then
                FTS.ownerEdit:SetText(control.displayName)
                FTS.ownerEdit:LoseFocus()
            end
        end)
        FTS.ownerRows[i] = row
    end
    FTS.noOwnerSuggestions = MakeLabel(hp, "FTSNoOwnerSuggestions",
        COLOR.gray .. "No matching friends, group members, or saved owners.|r", "ZoFontGameSmall")
    FTS.noOwnerSuggestions:SetAnchor(TOPLEFT, suggestionsLabel, BOTTOMLEFT, 4, 12)
    FTS.pickerStatus = MakeLabel(p, "FTSPickerStatus",
        COLOR.gray .. "Locked destinations may be saved, but cannot be used until unlocked.|r", "ZoFontGameSmall")
    FTS.pickerStatus:SetAnchor(BOTTOMLEFT, p, BOTTOMLEFT, 20, -14)
end

function FTS.OpenPicker(slot)
    FTS.editingSlot = slot
    FTS.pickerTitle:SetText("Set travel slot " .. slot)
    FTS.BuildDestinations()
    FTS.ShowSearchMode()
    FTS.pickerStatus:SetText(COLOR.gray ..
        "Locked destinations may be saved, but cannot be used until unlocked.|r")
    FTS.window:SetHidden(true)
    FTS.picker:SetHidden(false)
    FTS.HoldCursorMode()
end

function FTS.ClosePicker()
    if FTS.picker then FTS.picker:SetHidden(true) end
    if FTS.window then FTS.window:SetHidden(false) end
    FTS.HoldCursorMode()
end

function FTS.OpenSlotEditor(slot, newlyAssigned)
    local destination = SV.slots[slot]
    if not destination then
        FTS.OpenPicker(slot)
        return
    end
    FTS.editingSlot = slot
    FTS.slotEditorTitle:SetText((newlyAssigned and "Customize new slot " or "Edit travel slot ") .. slot)
    FTS.slotEditorDestination:SetText(
        COLOR.blue .. "DESTINATION  |r" .. COLOR.white .. destination.name .. "|r")
    FTS.slotNameEdit:SetText(destination.customName or "")
    FTS.slotNoteEdit:SetText(destination.note or "")
    local accent = destination.accentColor or DEFAULT_ACCENT
    FTS.editingColor = { accent[1], accent[2], accent[3], accent[4] or 1 }
    FTS.editingIcon = destination.customIcon
    FTS.RefreshAppearancePreview()
    FTS.picker:SetHidden(true)
    FTS.window:SetHidden(true)
    FTS.slotEditor:SetHidden(false)
    FTS.HoldCursorMode()
end

function FTS.CloseSlotEditor()
    if FTS.slotEditor then FTS.slotEditor:SetHidden(true) end
    if FTS.window then FTS.window:SetHidden(false) end
    FTS.HoldCursorMode()
end

function FTS.SaveSlotDetails()
    local destination = SV.slots[FTS.editingSlot]
    if not destination then return end
    local customName = Trim(FTS.slotNameEdit:GetText())
    local note = Trim(FTS.slotNoteEdit:GetText())
    destination.customName = customName ~= "" and customName or nil
    destination.note = note ~= "" and note or nil
    destination.accentColor = {
        FTS.editingColor[1], FTS.editingColor[2], FTS.editingColor[3], FTS.editingColor[4] or 1
    }
    destination.customIcon = FTS.editingIcon
    FTS.RefreshSlots()
    FTS.CloseSlotEditor()
    FTS.SetStatus("Slot " .. FTS.editingSlot .. " details saved.")
end

function FTS.ResolvedEditingIcon()
    local destination = SV.slots[FTS.editingSlot]
    if FTS.editingIcon and FTS.editingIcon ~= "" then return FTS.editingIcon end
    if destination then
        if destination.icon and destination.icon ~= "" then return destination.icon end
        if destination.kind == "ownedHouse" or destination.kind == "playerHouse"
            or destination.kind == "primaryHouse" then
            return HouseIcon(destination.id)
        end
    end
    return "EsoUI/Art/MapPins/MapPin_wayshrine.dds"
end

function FTS.RefreshAppearancePreview()
    if FTS.colorPreview and FTS.editingColor then
        FTS.colorPreview:SetColor(
            FTS.editingColor[1], FTS.editingColor[2], FTS.editingColor[3], FTS.editingColor[4] or 1)
    end
    if FTS.iconPreview then FTS.iconPreview:SetTexture(FTS.ResolvedEditingIcon()) end
end

function FTS.ChooseAccent(r, g, b, a)
    FTS.editingColor = { r, g, b, a or 1 }
    FTS.RefreshAppearancePreview()
end

function FTS.OpenNativeColorPicker()
    local color = FTS.editingColor or DEFAULT_ACCENT
    local callback = function(r, g, b, a)
        FTS.ChooseAccent(r, g, b, a)
        FTS.colorPickerOpen = false
        FTS.slotEditor:SetHidden(false)
        FTS.HoldCursorMode()
    end
    FTS.colorPickerOpen = true
    FTS.slotEditor:SetHidden(true)
    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() and COLOR_PICKER_GAMEPAD then
        COLOR_PICKER_GAMEPAD:Show(callback, color[1], color[2], color[3], color[4] or 1)
    elseif COLOR_PICKER then
        COLOR_PICKER:Show(callback, color[1], color[2], color[3], color[4] or 1)
    else
        FTS.colorPickerOpen = false
        FTS.slotEditor:SetHidden(false)
    end
end

function FTS.BuildIconChoices()
    local destination = SV.slots[FTS.editingSlot]
    local choices, seen = {}, {}
    local defaultPreview = destination and destination.icon
    if not defaultPreview or defaultPreview == "" then
        defaultPreview = destination and HouseIcon(destination.id)
            or "EsoUI/Art/MapPins/MapPin_wayshrine.dds"
    end
    choices[#choices + 1] = {
        label = "Destination default", icon = nil, preview = defaultPreview
    }
    seen[defaultPreview] = true

    local travelLabels = {
        WAYSHRINE = "WAY",
        DUNGEON = "DNG",
        ["PUBLIC DUNGEON"] = "PUB",
        DELVE = "DELVE",
        TRIAL = "TRIAL",
        ARENA = "ARENA",
        HOUSE = "HOUSE",
        ["INFINITE ARCHIVE"] = "ARCHIVE",
        DESTINATION = "TRAVEL",
    }
    local travelOrder = {
        "WAYSHRINE", "DUNGEON", "PUBLIC DUNGEON", "DELVE", "TRIAL",
        "ARENA", "HOUSE", "INFINITE ARCHIVE", "DESTINATION",
    }
    local travelIcons = {}
    if GetNumFastTravelNodes and GetFastTravelNodeInfo then
        for nodeIndex = 1, GetNumFastTravelNodes() do
            local _, name, _, _, icon, _, poiType = GetFastTravelNodeInfo(nodeIndex)
            local category = CategoryForNode(poiType, name, icon)
            if travelLabels[category] and icon and icon ~= "" and not travelIcons[category] then
                travelIcons[category] = icon
            end
        end
    end
    for _, category in ipairs(travelOrder) do
        local icon = travelIcons[category]
        if icon and not seen[icon] then
            seen[icon] = true
            choices[#choices + 1] = {
                label = travelLabels[category], icon = icon, preview = icon
            }
        end
    end
    local groupIcon = "EsoUI/Art/Contacts/social_status_online.dds"
    if not seen[groupIcon] then
        seen[groupIcon] = true
        choices[#choices + 1] = { label = "GROUP", icon = groupIcon, preview = groupIcon }
    end

    local formatter = ZO_ARMORY_BUILD_ICON_TEXTURE_FORMATTER
        or "EsoUI/Art/Armory/BuildIcons/buildIcon_%d.dds"
    local iconCount = ZO_ARMORY_NUM_BUILD_ICONS or 78
    for i = 1, iconCount do
        local icon = string.format(formatter, i)
        if not seen[icon] then
            seen[icon] = true
            choices[#choices + 1] = {
                label = string.format("%02d", i),
                icon = icon,
                preview = icon,
            }
        end
    end
    return choices
end

function FTS.RefreshIconPicker()
    local choices = FTS.iconChoices or {}
    local maxOffset = math.max(0, #choices - #FTS.iconRows)
    FTS.iconOffset = zo_clamp(FTS.iconOffset or 0, 0, maxOffset)
    for i, row in ipairs(FTS.iconRows) do
        local choice = choices[i + FTS.iconOffset]
        row.choice = choice
        row.root:SetHidden(choice == nil)
        if choice then
            row.icon:SetTexture(choice.preview)
            row.label:SetText(choice.icon and choice.label or "DEFAULT")
        end
    end
    local first = #choices == 0 and 0 or FTS.iconOffset + 1
    local last = math.min(#choices, FTS.iconOffset + #FTS.iconRows)
    FTS.iconPickerCounter:SetText(
        COLOR.gray .. string.format("%d–%d of %d · mouse wheel to browse", first, last, #choices) .. "|r")
end

function FTS.OpenIconPicker()
    FTS.iconChoices = FTS.BuildIconChoices()
    FTS.iconOffset = 0
    if FTS.editingIcon then
        for i, choice in ipairs(FTS.iconChoices) do
            if choice.icon == FTS.editingIcon then
                FTS.iconOffset = math.floor((i - 1) / 8) * 8
                break
            end
        end
    end
    FTS.RefreshIconPicker()
    FTS.slotEditor:SetHidden(true)
    FTS.iconPicker:SetHidden(false)
    FTS.HoldCursorMode()
end

function FTS.SelectIconChoice(choice)
    FTS.editingIcon = choice.icon
    FTS.RefreshAppearancePreview()
    FTS.iconPicker:SetHidden(true)
    FTS.slotEditor:SetHidden(false)
    FTS.HoldCursorMode()
end

function FTS.CloseIconPicker()
    FTS.iconPicker:SetHidden(true)
    FTS.slotEditor:SetHidden(false)
    FTS.HoldCursorMode()
end

function FTS.ClearEditedSlot()
    SV.slots[FTS.editingSlot] = nil
    FTS.RefreshSlots()
    FTS.CloseSlotEditor()
    FTS.SetStatus("Slot " .. FTS.editingSlot .. " cleared.")
end

function FTS.CreateSlotEditor()
    local e = WM:CreateTopLevelWindow("FlamechasersTravelSlotEditor")
    e:SetDimensions(580, 610)
    e:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    e:SetDrawLayer(DL_OVERLAY)
    e:SetDrawTier(DT_HIGH)
    e:SetDrawLevel(120)
    e:SetMouseEnabled(true)
    e:SetClampedToScreen(true)
    e:SetHidden(true)
    MakeBackdrop(e, "FlamechasersTravelSlotEditorBackdrop", true)
    FTS.slotEditor = e

    local header = WM:CreateControl("FTSSlotEditorHeader", e, CT_BACKDROP)
    header:SetDimensions(564, 72)
    header:SetAnchor(TOP, e, TOP, 0, 8)
    header:SetCenterColor(0.025, 0.095, 0.15, 0.98)
    header:SetEdgeColor(0, 0, 0, 0)
    local line = WM:CreateControl("FTSSlotEditorHeaderLine", header, CT_TEXTURE)
    line:SetDimensions(564, 2)
    line:SetAnchor(BOTTOM, header, BOTTOM, 0, 0)
    line:SetColor(0.25, 0.72, 1, 0.9)

    FTS.slotEditorTitle = MakeLabel(e, "FTSSlotEditorTitle", "", "ZoFontWinH2")
    FTS.slotEditorTitle:SetAnchor(TOPLEFT, e, TOPLEFT, 22, 18)
    local close = MakeButton(e, "FTSSlotEditorClose", "CLOSE")
    close:SetDimensions(75, 32)
    close:SetAnchor(TOPRIGHT, e, TOPRIGHT, -18, 17)
    close:SetHandler("OnClicked", function() FTS.CloseSlotEditor() end)

    FTS.slotEditorDestination = MakeLabel(e, "FTSSlotEditorDestination", "", "ZoFontGameSmall")
    FTS.slotEditorDestination:SetDimensions(530, 22)
    FTS.slotEditorDestination:SetAnchor(TOPLEFT, e, TOPLEFT, 24, 94)

    local nameLabel = MakeLabel(e, "FTSSlotCustomNameLabel", "Custom slot name", "ZoFontGame")
    nameLabel:SetAnchor(TOPLEFT, e, TOPLEFT, 24, 126)
    local nameBg, nameEdit = MakeEdit(e, "FTSSlotCustomNameEdit",
        "Leave empty to use the destination name", 532, 60)
    nameBg:SetAnchor(TOPLEFT, nameLabel, BOTTOMLEFT, 0, 5)
    FTS.slotNameEdit = nameEdit
    local reset = MakeButton(e, "FTSSlotNameReset", "USE OFFICIAL NAME")
    reset:SetDimensions(170, 28)
    reset:SetAnchor(TOPRIGHT, nameBg, BOTTOMRIGHT, 0, 2)
    reset:SetHandler("OnClicked", function() FTS.slotNameEdit:SetText("") end)

    local noteLabel = MakeLabel(e, "FTSSlotNoteLabel", "Optional note", "ZoFontGame")
    noteLabel:SetAnchor(TOPLEFT, e, TOPLEFT, 24, 220)
    local noteBg, noteEdit = MakeEdit(e, "FTSSlotNoteEdit",
        "Example: Guild hall, crafting room, pledge shortcut…", 532, 90)
    noteBg:SetAnchor(TOPLEFT, noteLabel, BOTTOMLEFT, 0, 5)
    FTS.slotNoteEdit = noteEdit

    local appearanceLabel = MakeLabel(e, "FTSSlotAppearanceLabel", "Slot appearance", "ZoFontGame")
    appearanceLabel:SetAnchor(TOPLEFT, e, TOPLEFT, 24, 312)

    local colorLabel = MakeLabel(e, "FTSSlotColorLabel", "Accent", "ZoFontGameSmall")
    colorLabel:SetAnchor(TOPLEFT, appearanceLabel, BOTTOMLEFT, 0, 9)
    FTS.colorPreview = WM:CreateControl("FTSSlotColorPreview", e, CT_TEXTURE)
    FTS.colorPreview:SetDimensions(34, 34)
    FTS.colorPreview:SetAnchor(LEFT, colorLabel, RIGHT, 12, 0)
    FTS.colorPreview:SetTexture("EsoUI/Art/Miscellaneous/white.dds")
    for i, preset in ipairs(ACCENT_PRESETS) do
        local swatch = WM:CreateControl("FTSAccentPresetTexture" .. i, e, CT_TEXTURE)
        swatch:SetDimensions(24, 24)
        swatch:SetAnchor(LEFT, FTS.colorPreview, RIGHT, 10 + ((i - 1) * 29), 0)
        swatch:SetTexture("EsoUI/Art/Miscellaneous/white.dds")
        swatch:SetColor(preset[1], preset[2], preset[3], 1)
        local swatchHit = MakeButton(e, "FTSAccentPreset" .. i, "")
        swatchHit:SetAnchorFill(swatch)
        swatchHit:SetHandler("OnMouseEnter", function()
            swatch:SetColor(math.min(1, preset[1] + 0.15),
                math.min(1, preset[2] + 0.15), math.min(1, preset[3] + 0.15), 1)
        end)
        swatchHit:SetHandler("OnMouseExit", function()
            swatch:SetColor(preset[1], preset[2], preset[3], 1)
        end)
        swatchHit:SetHandler("OnClicked", function()
            FTS.ChooseAccent(preset[1], preset[2], preset[3], preset[4])
        end)
    end
    local customColor = MakeButton(e, "FTSCustomAccentButton", "CUSTOM COLOR…")
    customColor:SetDimensions(150, 28)
    customColor:SetAnchor(TOPLEFT, colorLabel, BOTTOMLEFT, 0, 12)
    customColor:SetHandler("OnClicked", function() FTS.OpenNativeColorPicker() end)

    local iconLabel = MakeLabel(e, "FTSSlotIconLabel", "Icon", "ZoFontGameSmall")
    iconLabel:SetAnchor(TOPLEFT, appearanceLabel, BOTTOMLEFT, 0, 100)
    FTS.iconPreview = WM:CreateControl("FTSSlotIconPreview", e, CT_TEXTURE)
    FTS.iconPreview:SetDimensions(34, 34)
    FTS.iconPreview:SetAnchor(LEFT, iconLabel, RIGHT, 12, 0)
    FTS.iconPreview:SetColor(0.72, 0.88, 1, 1)
    local chooseIcon = MakeButton(e, "FTSChooseIconButton", "CHOOSE ICON…")
    chooseIcon:SetDimensions(150, 28)
    chooseIcon:SetAnchor(TOPLEFT, iconLabel, BOTTOMLEFT, 0, 12)
    chooseIcon:SetHandler("OnClicked", function() FTS.OpenIconPicker() end)

    local clear = MakeButton(e, "FTSSlotClear", "CLEAR SLOT")
    clear:SetDimensions(120, 38)
    clear:SetAnchor(BOTTOMLEFT, e, BOTTOMLEFT, 24, -22)
    clear:SetNormalFontColor(1, 0.45, 0.45, 1)
    clear:SetMouseOverFontColor(1, 0.7, 0.7, 1)
    clear:SetHandler("OnClicked", function() FTS.ClearEditedSlot() end)

    local change = MakeButton(e, "FTSSlotChangeDestination", "CHANGE DESTINATION")
    change:SetDimensions(190, 38)
    change:SetAnchor(LEFT, clear, RIGHT, 14, 0)
    change:SetHandler("OnClicked", function()
        FTS.slotEditor:SetHidden(true)
        FTS.OpenPicker(FTS.editingSlot)
    end)

    local save = MakeButton(e, "FTSSlotSave", "SAVE")
    save:SetDimensions(110, 38)
    save:SetAnchor(BOTTOMRIGHT, e, BOTTOMRIGHT, -24, -22)
    save:SetNormalFontColor(0.35, 0.8, 1, 1)
    save:SetHandler("OnClicked", function() FTS.SaveSlotDetails() end)
end

function FTS.CreateIconPicker()
    local p = WM:CreateTopLevelWindow("FlamechasersTravelIconPicker")
    p:SetDimensions(680, 500)
    p:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    p:SetDrawLayer(DL_OVERLAY)
    p:SetDrawTier(DT_HIGH)
    p:SetDrawLevel(130)
    p:SetMouseEnabled(true)
    p:SetClampedToScreen(true)
    p:SetHidden(true)
    MakeBackdrop(p, "FlamechasersTravelIconPickerBackdrop", true)
    FTS.iconPicker = p

    local header = WM:CreateControl("FTSIconPickerHeader", p, CT_BACKDROP)
    header:SetDimensions(664, 72)
    header:SetAnchor(TOP, p, TOP, 0, 8)
    header:SetCenterColor(0.025, 0.095, 0.15, 0.98)
    header:SetEdgeColor(0, 0, 0, 0)
    local line = WM:CreateControl("FTSIconPickerHeaderLine", header, CT_TEXTURE)
    line:SetDimensions(664, 2)
    line:SetAnchor(BOTTOM, header, BOTTOM, 0, 0)
    line:SetColor(0.25, 0.72, 1, 0.9)
    local title = MakeLabel(p, "FTSIconPickerTitle", "Choose slot icon", "ZoFontWinH2")
    title:SetAnchor(TOPLEFT, p, TOPLEFT, 22, 18)
    local close = MakeButton(p, "FTSIconPickerClose", "BACK")
    close:SetDimensions(75, 32)
    close:SetAnchor(TOPRIGHT, p, TOPRIGHT, -18, 17)
    close:SetHandler("OnClicked", function() FTS.CloseIconPicker() end)

    FTS.iconRows = {}
    for i = 1, 40 do
        local col = (i - 1) % 8
        local rowIndex = math.floor((i - 1) / 8)
        local root = MakeBackdrop(p, "FTSIconChoice" .. i, false)
        root:SetDimensions(72, 64)
        root:SetAnchor(TOPLEFT, p, TOPLEFT, 24 + col * 79, 96 + rowIndex * 70)
        root:SetCenterColor(0.035, 0.052, 0.075, 0.96)
        root:SetEdgeColor(0.12, 0.25, 0.35, 1)
        local icon = WM:CreateControl("FTSIconChoiceTexture" .. i, root, CT_TEXTURE)
        icon:SetDimensions(46, 46)
        icon:SetAnchor(CENTER, root, CENTER, 0, 0)
        icon:SetColor(0.72, 0.88, 1, 1)
        local label = MakeLabel(root, "FTSIconChoiceLabel" .. i, "", "ZoFontGameSmall")
        label:SetDimensions(62, 18)
        label:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, -4, -2)
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        label:SetColor(0.65, 0.76, 0.86, 0.9)
        local hit = MakeButton(root, "FTSIconChoiceHit" .. i, "")
        hit:SetAnchorFill(root)
        local data = { root = root, icon = icon, label = label }
        hit:SetHandler("OnMouseEnter", function()
            root:SetCenterColor(0.055, 0.095, 0.13, 1)
            root:SetEdgeColor(0.28, 0.67, 0.95, 1)
        end)
        hit:SetHandler("OnMouseExit", function()
            root:SetCenterColor(0.035, 0.052, 0.075, 0.96)
            root:SetEdgeColor(0.12, 0.25, 0.35, 1)
        end)
        hit:SetHandler("OnClicked", function()
            if data.choice then FTS.SelectIconChoice(data.choice) end
        end)
        FTS.iconRows[i] = data
    end
    FTS.iconPickerCounter = MakeLabel(p, "FTSIconPickerCounter", "", "ZoFontGameSmall")
    FTS.iconPickerCounter:SetAnchor(BOTTOMLEFT, p, BOTTOMLEFT, 24, -18)
    p:SetHandler("OnMouseWheel", function(_, delta)
        FTS.iconOffset = (FTS.iconOffset or 0) - delta * 8
        FTS.RefreshIconPicker()
    end)
end

function FTS.CreateWindow()
    if FTS.window then return end
    local w = WM:CreateTopLevelWindow("FlamechasersTravelSlotsWindow")
    w:SetDimensions(820, 680)
    w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SV.left, SV.top)
    w:SetMovable(true)
    w:SetMouseEnabled(true)
    w:SetClampedToScreen(true)
    w:SetHidden(true)
    w:SetDrawLayer(DL_OVERLAY)
    w:SetDrawTier(DT_HIGH)
    w:SetDrawLevel(100)
    w:SetHandler("OnMoveStop", function() SV.left, SV.top = w:GetLeft(), w:GetTop() end)
    MakeBackdrop(w, "FlamechasersTravelSlotsBackdrop", true)
    FTS.window = w

    local shadow = WM:CreateControl("FTSWindowShadow", w, CT_BACKDROP)
    shadow:SetAnchor(TOPLEFT, w, TOPLEFT, 8, 8)
    shadow:SetAnchor(BOTTOMRIGHT, w, BOTTOMRIGHT, -8, -8)
    shadow:SetCenterColor(0, 0, 0, 0)
    shadow:SetEdgeColor(0, 0, 0, 0.75)

    local header = WM:CreateControl("FTSMainHeader", w, CT_BACKDROP)
    header:SetDimensions(804, 94)
    header:SetAnchor(TOP, w, TOP, 0, 8)
    header:SetCenterColor(0.018, 0.075, 0.12, 0.98)
    header:SetEdgeColor(0, 0, 0, 0)
    local headerGlow = WM:CreateControl("FTSHeaderGlow", header, CT_TEXTURE)
    headerGlow:SetDimensions(804, 3)
    headerGlow:SetAnchor(BOTTOM, header, BOTTOM, 0, 0)
    headerGlow:SetColor(0.25, 0.72, 1, 0.95)

    local brandMark = WM:CreateControl("FTSBrandMark", header, CT_TEXTURE)
    brandMark:SetDimensions(52, 52)
    brandMark:SetAnchor(LEFT, header, LEFT, 18, 0)
    brandMark:SetTexture("EsoUI/Art/MapPins/MapPin_wayshrine.dds")
    brandMark:SetColor(0.35, 0.8, 1, 1)

    local title = MakeLabel(w, "FlamechasersTravelTitle", "FLAMECHASERS", "ZoFontWinH1")
    title:SetColor(0.35, 0.75, 1, 1)
    title:SetAnchor(TOPLEFT, w, TOPLEFT, 82, 18)
    local subtitle = MakeLabel(w, "FlamechasersTravelSubtitle", "TRAVEL COMMAND CENTER", "ZoFontWinH3")
    subtitle:SetColor(0.9, 0.94, 1, 1)
    subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 1, -5)
    local tagline = MakeLabel(w, "FlamechasersTravelTagline",
        "Sixteen destinations. One click away.", "ZoFontGameSmall")
    tagline:SetColor(0.52, 0.64, 0.75, 1)
    tagline:SetAnchor(TOPLEFT, subtitle, BOTTOMLEFT, 0, -2)
    local close = MakeButton(w, "FlamechasersTravelClose", "CLOSE")
    close:SetDimensions(80, 34)
    close:SetAnchor(TOPRIGHT, w, TOPRIGHT, -22, 27)
    close:SetHandler("OnClicked", function() FTS.Close() end)

    local sectionTitle = MakeLabel(w, "FTSSlotsSectionTitle", "QUICK DESTINATIONS", "ZoFontGame")
    sectionTitle:SetColor(0.55, 0.72, 0.84, 1)
    sectionTitle:SetAnchor(TOPLEFT, w, TOPLEFT, 24, 116)
    local clickHint = MakeLabel(w, "FTSSlotsClickHint",
        "Left-click travels  ·  Right-click edits", "ZoFontGameSmall")
    clickHint:SetColor(0.38, 0.46, 0.54, 0.9)
    clickHint:SetAnchor(TOPRIGHT, w, TOPRIGHT, -24, 119)
    local sectionRule = WM:CreateControl("FTSSlotsSectionRule", w, CT_TEXTURE)
    sectionRule:SetDimensions(390, 1)
    sectionRule:SetAnchor(LEFT, sectionTitle, RIGHT, 14, 0)
    sectionRule:SetColor(0.15, 0.3, 0.42, 0.9)

    FTS.slotNames, FTS.slotNotes, FTS.slotDetails, FTS.slotIcons, FTS.slotAccents,
        FTS.slotCards = {}, {}, {}, {}, {}, {}
    for i = 1, 16 do
        local col = (i - 1) % 4
        local row = math.floor((i - 1) / 4)
        local card = MakeBackdrop(w, "FTSSlotCard" .. i, false)
        card:SetDimensions(185, 108)
        card:SetAnchor(TOPLEFT, w, TOPLEFT, 24 + col * 195, 148 + row * 117)
        card:SetCenterColor(0.035, 0.052, 0.075, 0.96)
        card:SetEdgeColor(0.12, 0.25, 0.35, 1)

        local accent = WM:CreateControl("FTSSlotAccent" .. i, card, CT_TEXTURE)
        accent:SetDimensions(4, 92)
        accent:SetAnchor(LEFT, card, LEFT, 7, 0)
        local icon = WM:CreateControl("FTSSlotIcon" .. i, card, CT_TEXTURE)
        icon:SetDimensions(30, 30)
        icon:SetAnchor(TOPLEFT, card, TOPLEFT, 17, 14)
        icon:SetColor(0.72, 0.88, 1, 1)
        local number = MakeLabel(card, "FTSSlotNumber" .. i,
            COLOR.blue .. string.format("%02d", i) .. "|r", "ZoFontGameSmall")
        number:SetAnchor(TOPRIGHT, card, TOPRIGHT, -10, 7)
        local name = MakeLabel(card, "FTSSlotName" .. i, "", "ZoFontGame")
        name:SetDimensions(120, 43)
        if name.SetMaxLineCount then name:SetMaxLineCount(2) end
        if name.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
            name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        end
        name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        name:SetAnchor(TOPLEFT, card, TOPLEFT, 52, 12)
        local note = MakeLabel(card, "FTSSlotNote" .. i, "", "ZoFontGameSmall")
        note:SetDimensions(150, 18)
        note:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        note:SetAnchor(BOTTOMLEFT, card, BOTTOMLEFT, 18, -30)
        local detail = MakeLabel(card, "FTSSlotDetail" .. i, "", "ZoFontGameSmall")
        detail:SetDimensions(150, 20)
        detail:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        detail:SetAnchor(BOTTOMLEFT, card, BOTTOMLEFT, 18, -13)
        local hit = MakeButton(card, "FTSSlotHit" .. i, "")
        hit:SetAnchorFill(card)
        hit:SetHandler("OnMouseEnter", function()
            card:SetCenterColor(0.055, 0.095, 0.13, 1)
            card:SetEdgeColor(0.28, 0.67, 0.95, 1)
            icon:SetColor(0.35, 0.8, 1, 1)
            card:SetAlpha(SV.slots[i] and 1 or 0.8)
        end)
        hit:SetHandler("OnMouseExit", function()
            card:SetCenterColor(0.035, 0.052, 0.075, 0.96)
            card:SetEdgeColor(0.12, 0.25, 0.35, 1)
            icon:SetColor(0.72, 0.88, 1, 1)
            card:SetAlpha(SV.slots[i] and 1 or 0.58)
        end)
        hit:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
            if upInside == false then return end
            if mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
                FTS.OpenSlotEditor(i, false)
            elseif mouseButton == MOUSE_BUTTON_INDEX_LEFT then
                FTS.Travel(i)
            end
        end)
        FTS.slotNames[i], FTS.slotNotes[i], FTS.slotDetails[i] = name, note, detail
        FTS.slotIcons[i], FTS.slotAccents[i] = icon, accent
        FTS.slotCards[i] = card
    end
    local footer = WM:CreateControl("FTSFooter", w, CT_BACKDROP)
    footer:SetDimensions(804, 42)
    footer:SetAnchor(BOTTOM, w, BOTTOM, 0, -8)
    footer:SetCenterColor(0.018, 0.04, 0.06, 0.98)
    footer:SetEdgeColor(0, 0, 0, 0)
    FTS.status = MakeLabel(w, "FlamechasersTravelStatus",
        COLOR.gray .. "Left-click travels. Right-click edits name, note, destination, or clears.|r",
        "ZoFontGameSmall")
    FTS.status:SetAnchor(LEFT, footer, LEFT, 15, 0)
    local version = MakeLabel(w, "FTSVersion", "v" .. FTS.version, "ZoFontGameSmall")
    version:SetColor(0.32, 0.46, 0.56, 1)
    version:SetAnchor(RIGHT, footer, RIGHT, -14, 0)
    FTS.CreatePicker()
    FTS.CreateSlotEditor()
    FTS.CreateIconPicker()
    FTS.RefreshSlots()
end

function FTS.CreateMapButton()
    if FTS.mapButton or not ZO_WorldMap then return end

    -- Votan's Minimap intentionally reuses ZO_WorldMap. The scene check below
    -- keeps this control exclusive to ESO's actual full-size world map.
    local button = WM:CreateControl(
        "FlamechasersTravelMapButton", ZO_WorldMap, CT_BUTTON)
    button:SetDimensions(158, 32)
    button:SetAnchor(TOPRIGHT, ZO_WorldMap, TOPRIGHT, -54, 38)
    button:SetDrawLayer(DL_OVERLAY)
    button:SetDrawTier(DT_MEDIUM)
    button:SetDrawLevel(200)

    local shadow = WM:CreateControl(
        "FlamechasersTravelMapButtonShadow", button, CT_BACKDROP)
    shadow:SetAnchor(TOPLEFT, button, TOPLEFT, 2, 3)
    shadow:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, 2, 3)
    shadow:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    shadow:SetCenterColor(0, 0, 0, 0.38)
    shadow:SetEdgeColor(0, 0, 0, 0)

    local background = WM:CreateControl(
        "FlamechasersTravelMapButtonBackground", button, CT_BACKDROP)
    background:SetAnchorFill(button)
    background:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    background:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16)
    background:SetInsets(4, 4, -4, -4)
    background:SetCenterColor(0.035, 0.034, 0.031, 0.90)
    background:SetEdgeColor(0.38, 0.34, 0.27, 0.82)

    local accent = WM:CreateControl(
        "FlamechasersTravelMapButtonAccent", button, CT_TEXTURE)
    accent:SetDimensions(138, 1)
    accent:SetAnchor(BOTTOM, button, BOTTOM, 0, -3)
    accent:SetColor(0.50, 0.39, 0.23, 0.72)

    local icon = WM:CreateControl(
        "FlamechasersTravelMapButtonIcon", button, CT_TEXTURE)
    icon:SetDimensions(18, 18)
    icon:SetAnchor(LEFT, button, LEFT, 10, 0)
    icon:SetDrawLayer(DL_OVERLAY)
    icon:SetDrawTier(DT_HIGH)
    icon:SetDrawLevel(210)
    icon:SetColor(0.68, 0.64, 0.56, 0.90)

    -- Do not hard-code a map-pin filename here. ESO's travel-node API returns
    -- the active client asset path, which is reliable across UI revisions.
    local function RefreshMapButtonIcon()
        if not (GetNumFastTravelNodes and GetFastTravelNodeInfo) then return end
        for nodeIndex = 1, GetNumFastTravelNodes() do
            local _, name, _, _, nodeIcon, _, poiType =
                GetFastTravelNodeInfo(nodeIndex)
            if nodeIcon and nodeIcon ~= ""
                and CategoryForNode(poiType, name, nodeIcon) == "WAYSHRINE" then
                icon:SetTexture(nodeIcon)
                icon:SetHidden(false)
                return
            end
        end
    end
    icon:SetHidden(true)
    RefreshMapButtonIcon()

    local label = MakeLabel(
        button, "FlamechasersTravelMapButtonLabel",
        "TRAVEL SLOTS", "ZoFontGameBold")
    label:SetDimensions(120, 28)
    label:SetAnchor(LEFT, button, LEFT, 30, 0)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetDrawLevel(210)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0.78, 0.74, 0.66, 1)

    button:SetHandler("OnMouseEnter", function()
        background:SetCenterColor(0.055, 0.050, 0.040, 0.96)
        background:SetEdgeColor(0.58, 0.48, 0.31, 0.94)
        accent:SetColor(0.72, 0.54, 0.28, 0.90)
        icon:SetColor(0.84, 0.76, 0.60, 1)
        label:SetColor(0.92, 0.84, 0.68, 1)
    end)
    button:SetHandler("OnMouseExit", function()
        background:SetCenterColor(0.035, 0.034, 0.031, 0.90)
        background:SetEdgeColor(0.38, 0.34, 0.27, 0.82)
        accent:SetColor(0.50, 0.39, 0.23, 0.72)
        icon:SetColor(0.68, 0.64, 0.56, 0.90)
        label:SetColor(0.78, 0.74, 0.66, 1)
    end)
    button:SetHandler("OnClicked", function()
        FTS.Open()
    end)

    local function RefreshMapButtonVisibility()
        local fullWorldMapIsShowing =
            ZO_WorldMap_IsWorldMapShowing and ZO_WorldMap_IsWorldMapShowing()
        button:SetHidden(not fullWorldMapIsShowing)
        if fullWorldMapIsShowing then RefreshMapButtonIcon() end
    end
    RefreshMapButtonVisibility()

    if WORLD_MAP_SCENE and WORLD_MAP_SCENE.RegisterCallback then
        WORLD_MAP_SCENE:RegisterCallback("StateChange", RefreshMapButtonVisibility)
    end
    if GAMEPAD_WORLD_MAP_SCENE and GAMEPAD_WORLD_MAP_SCENE.RegisterCallback then
        GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", RefreshMapButtonVisibility)
    end

    FTS.mapButton = button
end

function FTS.Toggle()
    FTS.CreateWindow()
    if (FTS.picker and not FTS.picker:IsHidden())
        or (FTS.slotEditor and not FTS.slotEditor:IsHidden())
        or (FTS.iconPicker and not FTS.iconPicker:IsHidden())
        or not FTS.window:IsHidden() then
        FTS.Close()
    else
        FTS.Open()
    end
end

local function InitializeSavedVariables()
    -- The pre-0.7.5 data used ZO_SavedVars' "Default" namespace. Read that
    -- already-loaded table directly so it can be copied without creating or
    -- continuing to use a non-server-aware SavedVars wrapper.
    local root = rawget(_G, SAVED_VARIABLES_NAME)
    local defaultNamespace = root and root["Default"]
    local accountName = GetDisplayName and GetDisplayName()
    local accountData = accountName and defaultNamespace and defaultNamespace[accountName]
    local legacy = accountData and accountData["$AccountWide"]
    local defaults = {
        left = 500,
        top = 220,
        slots = {},
        serverDataInitialized = false,
    }
    local worldName = GetWorldName and GetWorldName() or "Default"
    SV = ZO_SavedVars:NewAccountWide(
        SAVED_VARIABLES_NAME, SAVED_VARIABLES_VERSION, worldName, defaults)

    if not SV.serverDataInitialized then
        if legacy then
            SV.left = legacy.left or SV.left
            SV.top = legacy.top or SV.top
            if legacy.slots and next(legacy.slots) then
                SV.slots = DeepCopy(legacy.slots)
            end
        end
        SV.serverDataInitialized = true
    end
end

function FTS.Initialize()
    InitializeSavedVariables()

    ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_CATEGORY", "Flamechasers")
    ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_TRAVEL_TOGGLE", "Open/Close Travel Slots")
    for index = 1, 16 do
        ZO_CreateStringId(
            "SI_BINDING_NAME_FLAMECHASERS_TRAVEL_SLOT_" .. index,
            string.format("Travel to Quick Slot %02d", index)
        )
    end

    SLASH_COMMANDS["/fts"] = function() FTS.Toggle() end
    SLASH_COMMANDS["/ftravel"] = function() FTS.Toggle() end

    FTS.CreateMapButton()
    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "MapButton", EVENT_PLAYER_ACTIVATED,
        function()
            FTS.CreateMapButton()
            if FTS.mapButton then
                EVENT_MANAGER:UnregisterForEvent(
                    ADDON_NAME .. "MapButton", EVENT_PLAYER_ACTIVATED)
            end
        end)
    EVENT_MANAGER:RegisterForEvent(
        ADDON_NAME .. "QuestPosition", EVENT_QUEST_POSITION_REQUEST_COMPLETE,
        function(_, taskId, _, xLoc, yLoc)
            FTS.ResolveFocusedQuestPosition(taskId, xLoc, yLoc)
        end)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    FTS.Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
