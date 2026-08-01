-- DDPositions_Core.lua
DDPositions = DDPositions or {}
local DDP = DDPositions

DDP.SV = nil
DDP.savedAssignments = nil

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

    local message = "DDAssignment(s): "
    for _, obj in ipairs(mechObjects) do
        message = message .. string.format("::[%s -> %s]:: ", DDP.PrintName(obj.name), obj.position)
    end
    return message
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

    local message = "DDAssignment(s): "
    for _, obj in ipairs(mechObjects) do
        message = message .. string.format("::[%s -> %s]:: ", DDP.PrintName(obj.name), obj.position)
    end
	
	DDP.PrintCurrentAssignments(zoneId, mechKey)
	
    return message
end

function DDP.PrintCurrentAssignments(zoneId, mechKey)
    if not zoneId or not mechKey then return end
    local savedZone = DDP.savedAssignments[zoneId]
    if not savedZone or not savedZone[mechKey] then return end

    local mechObjects = savedZone[mechKey]
    local message = "DDAssignment(s): "
    for _, obj in ipairs(mechObjects) do
        message = message .. string.format("::[%s -> %s]:: ", obj.name or "@Missing", obj.position or "?")
    end

    StartChatInput(message, CHAT_CHANNEL_PARTY)
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

function DDP.AssignSpecificMechanic(zoneId, mechName)
    local zoneData = DDP.positions[zoneId]
    if not zoneData or not zoneData.mechanics[mechName] then
        DDP.msg("Invalid mechanic selection.")
        return
    end
    local msg = DDP.AssignToPositions(zoneId, mechName, zoneData.mechanics[mechName])
    
    DDP.lastMechanicShown = mechName
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
        table.insert(parts, string.format("::[%s -> %s]::", playerName, data.position))
    end

    local fullMessage = "DDAssignment(s): " .. table.concat(parts, " ")
    StartChatInput(fullMessage, CHAT_CHANNEL_PARTY)
end


