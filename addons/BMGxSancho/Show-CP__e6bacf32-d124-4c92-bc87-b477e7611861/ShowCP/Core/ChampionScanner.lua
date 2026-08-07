local SC = ShowCP
SC.Scanner = SC.Scanner or {}
local Scanner = SC.Scanner

local MODULE_BY_DISCIPLINE_TYPE = {
    [CHAMPION_DISCIPLINE_TYPE_COMBAT] = "blue",
    [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = "red",
    [CHAMPION_DISCIPLINE_TYPE_WORLD] = "green",
}

local function FormatChampionName(championSkillId)
    if not championSkillId or championSkillId <= 0 then return nil end
    local name = GetChampionSkillName(championSkillId)
    if not name or name == "" then return nil end
    return zo_strformat("<<C:1>>", name)
end

function Scanner:Initialize()
    local namespace = SC.name .. "_ChampionScanner"

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_PLAYER_ACTIVATED, function()
        SC:QueueRefresh(250)
    end)

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_SLOT_UPDATED, function()
        SC:QueueRefresh(100)
    end)

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function()
        SC:QueueRefresh(100)
    end)

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_CHAMPION_PURCHASE_RESULT, function()
        SC:QueueRefresh(150)
    end)

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function()
        SC:QueueRefresh(300)
    end)
end

function Scanner:Refresh()
    local slotted = {
        blue = {},
        red = {},
        green = {},
    }

    local firstSlot, lastSlot = GetAssignableChampionBarStartAndEndSlots()
    if not firstSlot or not lastSlot then
        firstSlot, lastSlot = 1, 12
    end

    for slotIndex = firstSlot, lastSlot do
        local championSkillId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        local disciplineId = GetRequiredChampionDisciplineIdForSlot(slotIndex, HOTBAR_CATEGORY_CHAMPION)
        local disciplineType = disciplineId and GetChampionDisciplineType(disciplineId)
        local moduleKey = MODULE_BY_DISCIPLINE_TYPE[disciplineType]

        if moduleKey and championSkillId and championSkillId > 0 then
            local name = FormatChampionName(championSkillId)
            if name then
                table.insert(slotted[moduleKey], name)
            end
        end
    end

    for moduleKey in pairs(slotted) do
        while #slotted[moduleKey] > 4 do
            table.remove(slotted[moduleKey])
        end
        SC.Display:SetModuleLines(moduleKey, slotted[moduleKey])
    end

    SC.Display:RefreshVisibility()
end
