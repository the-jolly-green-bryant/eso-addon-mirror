-- WifeyDPSPositions_Core.lua
WifeyDPSPositions = WifeyDPSPositions or {}
local DDP = WifeyDPSPositions

DDP.SV = nil
DDP.savedAssignments = nil

local function buildAssignmentMessage(mechObjects)
    local parts = {}
    for _, obj in ipairs(mechObjects or {}) do
        local position = obj.position or "?"
        local playerName = DDP.PrintName and DDP.PrintName(obj.name or "@Missing") or (obj.name or "@Missing")
        table.insert(parts, string.format("%s: %s", position, playerName))
    end
    return "DPS Positions | " .. table.concat(parts, " | ")
end

local function getCurrentDPS()
    local dpsMap = {}
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) and DDP.IsUnitDPS(unitTag) then
            local name = DDP.NormalizeName(GetUnitDisplayName(unitTag))
            if name then dpsMap[name] = unitTag end
        end
    end
    return dpsMap
end

local function ensureAssignments(zoneId, mechKey, mechPositions)
    DDP.savedAssignments = DDP.savedAssignments or {}
    DDP.savedAssignments[zoneId] = DDP.savedAssignments[zoneId] or {}

    local mechObjects = DDP.savedAssignments[zoneId][mechKey]
    if not mechObjects then
        mechObjects = {}
        for i, pos in ipairs(mechPositions) do
            mechObjects[i] = { name = "@Missing", position = pos, override = false }
        end
        DDP.savedAssignments[zoneId][mechKey] = mechObjects
        return mechObjects
    end

    -- Keep SavedVariables in sync when a mechanic gains/loses slots.
    for i = #mechObjects, #mechPositions + 1, -1 do
        table.remove(mechObjects, i)
    end

    for i, pos in ipairs(mechPositions) do
        if not mechObjects[i] then
            mechObjects[i] = { name = "@Missing", position = pos, override = false }
        else
            mechObjects[i].position = pos
            if not mechObjects[i].name then mechObjects[i].name = "@Missing" end
            if mechObjects[i].override == nil then mechObjects[i].override = false end
        end
    end

    DDP.savedAssignments[zoneId][mechKey] = mechObjects
    return mechObjects
end

function DDP.AssignToPositions(zoneId, mechKey, mechPositions)
    if GetGroupSize() == 0 then return end

    local mechObjects = ensureAssignments(zoneId, mechKey, mechPositions)
    local dpsMap = getCurrentDPS()

    -- Ossein Cage Portal: exactly five DPS plus one healer.
    if zoneId == 1548 and mechKey == "Portal" then
        local dpsNames = {}
        for name in pairs(dpsMap) do table.insert(dpsNames, name) end
        table.sort(dpsNames)
        for i = 1, 5 do
            mechObjects[i].name = dpsNames[i] or "@Missing"
            mechObjects[i].override = false
        end
        local healerName = nil
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) and GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_HEAL then
                healerName = DDP.NormalizeName(GetUnitDisplayName(unitTag))
                if healerName then break end
            end
        end
        mechObjects[6].name = healerName or "@Missing"
        mechObjects[6].override = false
        DDP.savedAssignments[zoneId][mechKey] = mechObjects
        if DDP.SV then DDP.SV.savedAssignments = DDP.savedAssignments end
        return buildAssignmentMessage(mechObjects)
    end

    for _, obj in ipairs(mechObjects) do
        if obj.name ~= "@Missing" then
            local stillInGroup = dpsMap[obj.name]
            if not stillInGroup then
                obj.name = "@Missing"
                obj.override = false
            end
        end
    end

    local unassigned = {}
    for name in pairs(dpsMap) do
        local alreadyAssigned = false
        for _, obj in ipairs(mechObjects) do
            if obj.name == name then
                alreadyAssigned = true
                break
            end
        end
        if not alreadyAssigned then
            table.insert(unassigned, name)
        end
    end

    for _, obj in ipairs(mechObjects) do
        if (obj.name == "@Missing" or obj.name == nil) and (not obj.override) and #unassigned > 0 then
            obj.name = table.remove(unassigned, 1)
        end
    end
	
	local seen = {}
	for _, obj in ipairs(mechObjects) do
		if obj.name ~= "@Missing" then
			if seen[obj.name] then
				DDP.msg("Duplicate found: " .. obj.name .. " (auto-cleared from one slot)")
				obj.name = "@Missing"
				obj.override = false
			else
				seen[obj.name] = true
			end
		end
	end

    DDP.savedAssignments[zoneId] = DDP.savedAssignments[zoneId] or {}
    DDP.savedAssignments[zoneId][mechKey] = mechObjects
    DDP.SV.savedAssignments = DDP.savedAssignments

    return buildAssignmentMessage(mechObjects)
end

function DDP.ShuffleAllAssignments(zoneId, mechKey, mechPositions, keepOverrides)
    if GetGroupSize() == 0 then return end

    local dpsMap = getCurrentDPS()
    local allDPS = {}
    for name in pairs(dpsMap) do table.insert(allDPS, name) end
    DDP.ShuffleTable(allDPS)

    local mechObjects = ensureAssignments(zoneId, mechKey, mechPositions)

    local idx = 1
    for i, pos in ipairs(mechPositions) do
        if keepOverrides and mechObjects[i] and mechObjects[i].override and mechObjects[i].name ~= "@Missing" then
            -- keep as-is
        else
            mechObjects[i] = mechObjects[i] or {}
            mechObjects[i].position = pos
            mechObjects[i].name = allDPS[idx] or "@Missing"
            mechObjects[i].override = false
            idx = idx + 1
        end
    end
	
	local seen = {}
	for _, obj in ipairs(mechObjects) do
		if obj.name ~= "@Missing" then
			if seen[obj.name] then
				DDP.msg("Duplicate found in shuffle: " .. obj.name .. " (auto-cleared)")
				obj.name = "@Missing"
				obj.override = false
			else
				seen[obj.name] = true
			end
		end
	end

    DDP.savedAssignments[zoneId] = DDP.savedAssignments[zoneId] or {}
    DDP.savedAssignments[zoneId][mechKey] = mechObjects
    DDP.SV.savedAssignments = DDP.savedAssignments

    local message = buildAssignmentMessage(mechObjects)

    DDP.PrintCurrentAssignments(zoneId, mechKey)

    return message
end

function DDP.PrintCurrentAssignments(zoneId, mechKey)
    if not zoneId or not mechKey then return end
    local savedZone = DDP.savedAssignments[zoneId]
    if not savedZone or not savedZone[mechKey] then return end

    local mechObjects = savedZone[mechKey]
    StartChatInput(buildAssignmentMessage(mechObjects), CHAT_CHANNEL_PARTY)
end

function DDP.OverrideAssignment(zoneId, mechKey, positionIndex, playerName, makePersistent)
    if not zoneId or not mechKey or not positionIndex or not playerName then
        DDP.msg("Invalid override arguments.")
        return
    end

    local zoneData = DDP.positions[zoneId]
    if not zoneData or not zoneData.mechanics[mechKey] then
        DDP.msg("Mechanic not found for override.")
        return
    end

    local mechObjects = DDP.savedAssignments[zoneId] and DDP.savedAssignments[zoneId][mechKey]
    if not mechObjects then
        mechObjects = {}
        for i, pos in ipairs(zoneData.mechanics[mechKey]) do
            mechObjects[i] = { name = "@Missing", position = pos, override = false }
        end
    end

    local normalizedName = DDP.NormalizeName(playerName)

    local oldIndex = nil
    for i, obj in ipairs(mechObjects) do
        if obj.name == normalizedName then
            oldIndex = i
            break
        end
    end

    local targetSlot = mechObjects[positionIndex]
    local targetPlayer = targetSlot and targetSlot.name or "@Missing"

    if targetPlayer ~= "@Missing" and targetPlayer ~= normalizedName then
        if oldIndex then
            mechObjects[oldIndex].name = targetPlayer
            mechObjects[oldIndex].override = false
        else
            for i, obj in ipairs(mechObjects) do
                if obj.name == "@Missing" then
                    mechObjects[i].name = targetPlayer
                    break
                end
            end
        end
    end

    targetSlot.name = normalizedName
    targetSlot.override = makePersistent and true or false

    local seen = {}
    for i, obj in ipairs(mechObjects) do
        if obj.name ~= "@Missing" then
            if seen[obj.name] and i ~= positionIndex then
                obj.name = "@Missing"
                obj.override = false
            else
                seen[obj.name] = true
            end
        end
    end

    DDP.savedAssignments[zoneId][mechKey] = mechObjects
    DDP.SV.savedAssignments = DDP.savedAssignments

    if DDP.UI and DDP.UI.PopulateMechanicList then
        DDP.UI:PopulateMechanicList()
    end
	
	DDP.PrintCurrentAssignments(zoneId, mechKey)
end


function DDP.ClearOverride(zoneId, mechKey, positionIndex)
    local zoneData = DDP.positions[zoneId]
    if not zoneData or not zoneData.mechanics[mechKey] then return end
    local mechObjects = ensureAssignments(zoneId, mechKey, zoneData.mechanics[mechKey])
    local slot = mechObjects[positionIndex]
    if not slot then return end
    slot.override = false
    DDP.SV.savedAssignments = DDP.savedAssignments
    if DDP.UI and DDP.UI.PopulateMechanicList then
        DDP.UI:PopulateMechanicList()
    end
end


function DDP.SendNativeAssignmentPopup(mechName, message)
    if GetGroupSize() == 0 then
        DDP.msg("Popup requires a group.")
        return
    end

    local popupText = tostring(mechName or "DPS POSITIONS") .. " | " .. tostring(message or "")
    local flags = GROUP_ELECTION_FLAGS_REQUIRE_ALL_VOTES + GROUP_ELECTION_FLAGS_IGNORE_OFFLINE_MEMBERS

    BeginGroupElection(
        GROUP_ELECTION_TYPE_GENERIC_UNANIMOUS,
        popupText,
        nil,
        flags
    )
end

function DDP.AssignSpecificMechanic(zoneId, mechName)
    local zoneData = DDP.positions[zoneId]
    if not zoneData or not zoneData.mechanics[mechName] then
        DDP.msg("Invalid mechanic selection.")
        return
    end
    local msg = DDP.AssignToPositions(zoneId, mechName, zoneData.mechanics[mechName])
    
    DDP.lastMechanicShown = mechName
    DDP.SendNativeAssignmentPopup(mechName, msg)
    StartChatInput(msg, CHAT_CHANNEL_PARTY)

    if DDP.UI and DDP.UI.PopulateMechanicList then
        DDP.UI:PopulateMechanicList()
    end
	
end

function DDP.ForceAssignPlayerToPosition(zoneId, mechKey, positionIndex, playerName)
    if not zoneId or not mechKey or not positionIndex or not playerName then
        DDP.msg("Invalid force-assign arguments.")
        return
    end

    local zoneData = DDP.positions[zoneId]
    if not zoneData or not zoneData.mechanics[mechKey] then
        DDP.msg("Mechanic not found for manual assign.")
        return
    end

    DDP.savedAssignments = DDP.savedAssignments or {}
    DDP.savedAssignments[zoneId] = DDP.savedAssignments[zoneId] or {}

    local mechObjects = DDP.savedAssignments[zoneId][mechKey]
    if not mechObjects then
        mechObjects = {}
        for i, pos in ipairs(zoneData.mechanics[mechKey]) do
            mechObjects[i] = { name = "@Missing", position = pos, override = false }
        end
    end

    local normalizedName = DDP.NormalizeName(playerName)

    mechObjects[positionIndex] = mechObjects[positionIndex] or {}
    mechObjects[positionIndex].name = normalizedName
    mechObjects[positionIndex].position = zoneData.mechanics[mechKey][positionIndex]
    mechObjects[positionIndex].override = true

    DDP.savedAssignments[zoneId][mechKey] = mechObjects
    if DDP.SV then
        DDP.SV.savedAssignments = DDP.savedAssignments
    end

    DDP.msg(string.format("Force-assigned %s -> %s (%s)", normalizedName, zoneData.mechanics[mechKey][positionIndex], mechKey))

    if DDP.UI and DDP.UI.PopulateMechanicList then
        DDP.UI:PopulateMechanicList()
    end
end

function DDP.SetFreeAssignment(zoneId, playerName, mechKey, positionIndex)
    if not zoneId or not playerName or not mechKey or not positionIndex then
        DDP.msg("Invalid FreeAssignment args."); return
    end

    local zoneData = DDP.positions[zoneId]
    if not zoneData or not zoneData.mechanics[mechKey] then
        DDP.msg("Mechanic not found for FreeAssignment."); return
    end

    DDP.freeAssignments = DDP.freeAssignments or {}
    DDP.freeAssignments[zoneId] = DDP.freeAssignments[zoneId] or {}

    local positionLabel = zoneData.mechanics[mechKey][positionIndex]
    DDP.freeAssignments[zoneId][playerName] = {
        mechKey = mechKey,
        positionIndex = positionIndex,
        position = positionLabel,
    }

    if DDP.SV then DDP.SV.freeAssignments = DDP.freeAssignments end

    if DDP.UI and DDP.UI.PopulateFreeAssignments then
        DDP.UI:PopulateFreeAssignments(zoneId)
    end

    DDP.SendFreeAssignmentsToChat(zoneId)
end

function DDP.ClearFreeAssignment(zoneId, playerName)
    if not zoneId or not playerName then return end

    if DDP.freeAssignments and DDP.freeAssignments[zoneId] then
        DDP.freeAssignments[zoneId][playerName] = nil
        if DDP.SV then DDP.SV.freeAssignments = DDP.freeAssignments end
    end

    if DDP.UI and DDP.UI.PopulateFreeAssignments then
        DDP.UI:PopulateFreeAssignments(zoneId)
    end

    DDP.SendFreeAssignmentsToChat(zoneId)
end

function DDP.SendFreeAssignmentsToChat(zoneId)
    if not zoneId then return end
    local zoneData = DDP.positions[zoneId]
    local freeZone = DDP.freeAssignments and DDP.freeAssignments[zoneId]
    if not freeZone or not next(freeZone) then return end

    local parts = {}
    for playerName, data in pairs(freeZone) do
        table.insert(parts, string.format("%s: %s", data.position or "?", playerName or "@Missing"))
    end

    local fullMessage = "DPS Positions | " .. table.concat(parts, " | ")
    StartChatInput(fullMessage, CHAT_CHANNEL_PARTY)
end



-- v1.1 host-console helpers. These actions edit locally until SEND/RESEND.
function DDP.BuildAssignmentMessage(mechObjects)
    return buildAssignmentMessage(mechObjects)
end

function DDP.ShuffleAllAssignments(zoneId, mechKey, mechPositions, keepOverrides)
    if GetGroupSize() == 0 then return end

    -- Ossein Cage Portal always stays five DPS + one healer, including REROLL.
    if zoneId == 1548 and mechKey == "Portal" then
        local mechObjects = ensureAssignments(zoneId, mechKey, mechPositions)
        local dpsMap = getCurrentDPS()
        local dpsNames = {}
        for name in pairs(dpsMap) do table.insert(dpsNames, name) end
        DDP.ShuffleTable(dpsNames)
        for i = 1, 5 do
            mechObjects[i].name = dpsNames[i] or "@Missing"
            mechObjects[i].override = false
        end
        local healers = {}
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if DoesUnitExist(unitTag) and not IsUnitDead(unitTag) and GetGroupMemberSelectedRole(unitTag) == LFG_ROLE_HEAL then
                local name = DDP.NormalizeName(GetUnitDisplayName(unitTag))
                if name then table.insert(healers, name) end
            end
        end
        DDP.ShuffleTable(healers)
        mechObjects[6].name = healers[1] or "@Missing"
        mechObjects[6].override = false
        DDP.savedAssignments[zoneId][mechKey] = mechObjects
        if DDP.SV then DDP.SV.savedAssignments = DDP.savedAssignments end
        return buildAssignmentMessage(mechObjects)
    end

    local dpsMap = getCurrentDPS()
    local mechObjects = ensureAssignments(zoneId, mechKey, mechPositions)
    local reserved = {}
    if keepOverrides then
        for _, obj in ipairs(mechObjects) do
            if obj.override and obj.name and obj.name ~= "@Missing" and dpsMap[obj.name] then
                reserved[obj.name] = true
            end
        end
    end
    local pool = {}
    for name in pairs(dpsMap) do
        if not reserved[name] then table.insert(pool, name) end
    end
    DDP.ShuffleTable(pool)
    local idx = 1
    for i, pos in ipairs(mechPositions) do
        local obj = mechObjects[i] or {position = pos, name = "@Missing", override = false}
        obj.position = pos
        if not (keepOverrides and obj.override and obj.name ~= "@Missing" and dpsMap[obj.name]) then
            obj.name = pool[idx] or "@Missing"
            obj.override = false
            idx = idx + 1
        end
        mechObjects[i] = obj
    end
    DDP.savedAssignments[zoneId][mechKey] = mechObjects
    if DDP.SV then DDP.SV.savedAssignments = DDP.savedAssignments end
    return buildAssignmentMessage(mechObjects)
end

function DDP.SwapAssignments(zoneId, mechKey, firstIndex, secondIndex)
    local zoneData = DDP.positions[zoneId]
    if not zoneData or not zoneData.mechanics[mechKey] then return false end
    local objs = ensureAssignments(zoneId, mechKey, zoneData.mechanics[mechKey])
    if not objs[firstIndex] or not objs[secondIndex] then return false end
    objs[firstIndex].name, objs[secondIndex].name = objs[secondIndex].name, objs[firstIndex].name
    objs[firstIndex].override, objs[secondIndex].override = objs[secondIndex].override, objs[firstIndex].override
    if DDP.SV then DDP.SV.savedAssignments = DDP.savedAssignments end
    return true
end

function DDP.FillEmptyAssignments(zoneId, mechKey, mechPositions)
    return DDP.AssignToPositions(zoneId, mechKey, mechPositions)
end

function DDP.ResetMechanic(zoneId, mechKey, mechPositions)
    DDP.savedAssignments = DDP.savedAssignments or {}
    DDP.savedAssignments[zoneId] = DDP.savedAssignments[zoneId] or {}
    local objs = {}
    for i, pos in ipairs(mechPositions or {}) do
        objs[i] = {name = "@Missing", position = pos, override = false}
    end
    DDP.savedAssignments[zoneId][mechKey] = objs
    if DDP.SV then DDP.SV.savedAssignments = DDP.savedAssignments end
    return objs
end

function DDP.SendAssignments(zoneId, mechKey)
    local savedZone = DDP.savedAssignments and DDP.savedAssignments[zoneId]
    local objs = savedZone and savedZone[mechKey]
    if not objs then
        DDP.msg("Nothing assigned yet.")
        return false
    end
    local message = buildAssignmentMessage(objs)
    DDP.SendNativeAssignmentPopup(mechKey, message)
    StartChatInput(message, CHAT_CHANNEL_PARTY)
    return true
end

-- Manual reassignment is now local; SEND/RESEND controls broadcasting.
function DDP.OverrideAssignment(zoneId, mechKey, positionIndex, playerName, makePersistent)
    if not zoneId or not mechKey or not positionIndex or not playerName then return end
    local zoneData = DDP.positions[zoneId]
    if not zoneData or not zoneData.mechanics[mechKey] then return end
    local objs = ensureAssignments(zoneId, mechKey, zoneData.mechanics[mechKey])
    local normalized = DDP.NormalizeName(playerName)
    local oldIndex
    for i, obj in ipairs(objs) do if obj.name == normalized then oldIndex = i break end end
    local target = objs[positionIndex]
    local displaced = target.name
    if oldIndex and oldIndex ~= positionIndex then
        objs[oldIndex].name = displaced
        objs[oldIndex].override = false
    end
    target.name = normalized
    target.override = makePersistent and true or false
    if DDP.SV then DDP.SV.savedAssignments = DDP.savedAssignments end
    if DDP.UI and DDP.UI.MarkDirty then DDP.UI:MarkDirty() end
    if DDP.UI and DDP.UI.RefreshAssignments then DDP.UI:RefreshAssignments() end
end

-- Selecting a mechanic prepares it locally; it no longer broadcasts immediately.
function DDP.AssignSpecificMechanic(zoneId, mechName)
    local zoneData = DDP.positions[zoneId]
    if not zoneData or not zoneData.mechanics[mechName] then return end
    DDP.AssignToPositions(zoneId, mechName, zoneData.mechanics[mechName])
    DDP.lastMechanicShown = mechName
    if DDP.UI and DDP.UI.MarkDirty then DDP.UI:MarkDirty() end
    if DDP.UI and DDP.UI.Refresh then DDP.UI:Refresh() end
end
