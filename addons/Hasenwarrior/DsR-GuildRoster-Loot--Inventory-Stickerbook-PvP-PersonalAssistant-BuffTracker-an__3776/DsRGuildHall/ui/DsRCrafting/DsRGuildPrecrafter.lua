DsRGuildPrecrafter         = ZO_Object:Subclass()
DsRGuildPrecrafter.name    = "DsRGuildPrecrafter"

local QUEUE_SIZE = 37 -- Mindestzahl an Platz im Inventar. Entspricht 1 Rotation!!

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrecrafter.OnAddOnLoaded(event, addonName)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildPrecrafter.name, EVENT_ADD_ON_LOADED)
    DsRGuildPrecrafterQueue:New()
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrecrafter:SetCraftingQueue(multiplier)
    local queue = {}
    for profession, enabled in pairs(DsRGuildPrecrafter:GetSettings().PreCraftProfessions) do
        if enabled then table.insert(queue, profession) end
    end
    if #queue == 0 then
        echo(zo_strformat(GetString(DsRGuildCrafting_PrecraftNoProfessions)))
        return 
    end
    for k, v in pairs(queue) do
        DsRGuildPrecrafterQueue:AddProfession(v, multiplier)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrecrafter:GetMultiplierAndQueue(args, bagSpace, force)
    local multiplier
    if args == "" then
        if multiplier == 0 and not force then d(GetString(DsRGuildCrafting_PrecraftNoInvSpace)) return end
        multiplier = math.floor(bagSpace / QUEUE_SIZE)
    else
        multiplier = tonumber(args) or 1
    end
    if multiplier == 0 then DsRGuildPrecrafterQueue:Clear() d(GetString(DsRGuildCrafting_PrecraftNoZero)) return end
    local multiplierMessage = "|cFF0000" .. (multiplier * 3) .. "|r" .. GetString(DsRGuildCrafting_PrecraftOneRot)
    d("|c9fb6cd[DsR-Precrafter]|r " .. GetString(DsRGuildCrafting_PrecraftQueue) .. multiplierMessage .. "|c808080 (" .. multiplier * QUEUE_SIZE .. GetString(DsRGuildCrafting_PrecraftItems) .. ")|r")
    DsRGuildPrecrafter:SetCraftingQueue(multiplier)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPrecrafter:GetSettings()
    return DsRGuildLoot.sV
end
