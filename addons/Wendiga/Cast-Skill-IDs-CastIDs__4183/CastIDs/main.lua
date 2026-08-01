CastIDs = {
    name = "CastIDs",
    version = "1",
}

local idsEnabled = false

local function ShowUsedAbilityId(eventCode, slotNum)
    if not idsEnabled then return end

    local abilityId = GetSlotBoundId(slotNum)
    local abilityName = GetSlotName(slotNum)

    -- Comprobar si la habilidad es de escribanía
    -- Si lo es, convertir craftedAbilityId -> abilityId real
    local realAbilityId = GetAbilityIdForCraftedAbilityId(abilityId)
    if realAbilityId and realAbilityId ~= 0 then
        abilityId = realAbilityId
        abilityName = GetAbilityName(realAbilityId)
    end

    local nameColor = "|c7FDBFF" -- azul celeste
    local idColor = "|c00FF00"   -- verde brillante
    local reset = "|r"

    local message = string.format("|cc939daCast:|r %s%s%s (ID: %s%d%s)",
        nameColor, abilityName, reset, idColor, abilityId, reset)

    d(message)
end

local function ToggleSkillIdLogging()
    idsEnabled = not idsEnabled
    if idsEnabled then
        d("|cc939daCast|r|cf0e114IDs |c55fa00ON|r")
    else
        d("|cc939daCast|r|cf0e114IDs |ce92034OFF|r")
    end
end

SLASH_COMMANDS["/castids"] = ToggleSkillIdLogging

-- Registrar solo una vez
EVENT_MANAGER:RegisterForEvent("SkillIDLogger", EVENT_ACTION_SLOT_ABILITY_USED, ShowUsedAbilityId)
