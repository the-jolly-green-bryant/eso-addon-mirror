-- Módulo ChampionPointsLite dentro do OverlandChallenger
OverlandChallenger = OverlandChallenger or {}
OverlandChallenger.CPLite = {}
local CPLite = OverlandChallenger.CPLite

CPLite.name = "ChampionPointsLite"
--CPLite.OverlandChallengerVariables = ChampionPointsLite or {}          -- SavedVariables
--CPLite.savedSnapshot = CPLite.OverlandChallengerVariables.saved or {}

local function dprint(msg)
    d("|c53C8E9ChampionPointsLite:|r " .. tostring(msg))
end

-- ===== /savecp =====
function CPLite:SaveCP()
    local saved = { disciplines = {}, slots = {}, snapshotTime = GetTimeStamp() }
    for dis = 1, GetNumChampionDisciplines() do
        local maxSkills = GetNumChampionDisciplineSkills(dis)
        for si = 1, maxSkills do
            local starId = GetChampionSkillId(dis, si)
            if starId then
                local pts = GetNumPointsSpentOnChampionSkill(starId) or 0
                if pts > 0 then saved.disciplines[starId] = pts end
            end
        end
    end
    local start, nd = GetAssignableChampionBarStartAndEndSlots()
    for slot = start, nd do
        saved.slots[slot] = GetSlotBoundId(slot, HOTBAR_CATEGORY_CHAMPION) or 0
    end
    self.OverlandChallengerVariables.saved = saved
    self.savedSnapshot = saved
    dprint("Champion Points successfully saved.")
end

-- ===== /restorecp =====
function CPLite:RestoreCP()
    if not self.OverlandChallengerVariables or not self.OverlandChallengerVariables.saved then
        dprint("No Champion Points saved. Use /savecp first.")
        return
    end
    local saved = self.OverlandChallengerVariables.saved
    -- calcula pontos necessários (aproximação)
    local totalSavedPoints = 0
    for starId, pts in pairs(saved.disciplines) do totalSavedPoints = totalSavedPoints + (pts or 0) end

    -- soma pontos atualmente gastos só para as starIds salvas
    local totalCurrentSpent = 0
    for starId, _ in pairs(saved.disciplines) do
        totalCurrentSpent = totalCurrentSpent + (GetNumPointsSpentOnChampionSkill(starId) or 0)
    end

    local freePoints = 0
    for dis = 1, GetNumChampionDisciplines() do
    local disId = GetChampionDisciplineId(dis)
    -- Somente azuis/vermelhos (ignora verdes se quiser)
    local disType = GetChampionDisciplineType(disId)
    if disType ~= CHAMPION_DISCIPLINE_TYPE_WORLD then
        freePoints = freePoints + GetNumUnspentChampionPoints(disId)
    end
    end

    local needed = totalSavedPoints - totalCurrentSpent
    if needed < 0 then needed = 0 end

    if freePoints < needed then
        dprint("You do not have enough points to restore (" .. tostring(freePoints) .. " available; You need " .. tostring(needed) .. "). Use /resetcp first.")
        return
    end

    -- Prepara e manda a purchase request
    PrepareChampionPurchaseRequest(false)
    for starId, pts in pairs(saved.disciplines) do AddSkillToChampionPurchaseRequest(starId, pts) end
    for slot, starId in pairs(saved.slots) do
        if slot and starId then AddHotbarSlotToChampionPurchaseRequest(slot, starId) end
    end

    if GetExpectedResultForChampionPurchaseRequest then
        local expected = GetExpectedResultForChampionPurchaseRequest()
        if expected ~= CHAMPION_PURCHASE_SUCCESS then
            dprint("Restore locked: " .. tostring(expected))
            return
        end
    end
    SendChampionPurchaseRequest()
    dprint("CP restoration completed.")
end

-- ===== /resetcp =====
function CPLite:ResetCP()
    local respecCost = 3000
    local myMoney = GetCurrentMoney() or 0
    if myMoney < respecCost then
        dprint("You need 3,000 gold to reset. You have: " .. tostring(math.floor(myMoney)))
        return false
    end

    PrepareChampionPurchaseRequest(true)

    -- Resetar apenas vermelho e azul
    for dis = 1, GetNumChampionDisciplines() do
        local disId = GetChampionDisciplineId(dis)
        local disType = GetChampionDisciplineType(disId)
        if disType ~= CHAMPION_DISCIPLINE_TYPE_WORLD then  -- ignora verde
            local maxSkills = GetNumChampionDisciplineSkills(dis)
            for si = 1, maxSkills do
                local starId = GetChampionSkillId(dis, si)
                if starId then
                    AddSkillToChampionPurchaseRequest(starId, 0)
                end
            end
        end
    end

    -- Helper function to get the discipline type of a skillId
    local function GetDisciplineTypeBySkillId(skillId)
        for dis = 1, GetNumChampionDisciplines() do
            for si = 1, GetNumChampionDisciplineSkills(dis) do
                local sId = GetChampionSkillId(dis, si)
                if sId == skillId then
                    local disId = GetChampionDisciplineId(dis)
                    return GetChampionDisciplineType(disId)
                end
            end
        end
        return nil
    end

    -- Reset slots only if they are not green
    local startSlot, endSlot = GetAssignableChampionBarStartAndEndSlots()
    for slot = startSlot, endSlot do
        local skillId = GetSlotBoundId(slot, HOTBAR_CATEGORY_CHAMPION)
        if skillId then
            local disType = GetDisciplineTypeBySkillId(skillId)
            if disType and disType ~= CHAMPION_DISCIPLINE_TYPE_WORLD then
                AddHotbarSlotToChampionPurchaseRequest(slot, 0)
            end
        end
    end

    SendChampionPurchaseRequest()
    dprint("Red and blue trees respec sent. Green remains intact and slotted preserved.")
    return true
end

-- ===== Inicialização do módulo =====
function CPLite:OnLoaded()
    SLASH_COMMANDS["/savecp"] = function()
        if type(CPLite.SaveCP) ~= "function" then dprint("SaveCP not found.") else CPLite:SaveCP() end
    end
    SLASH_COMMANDS["/restorecp"] = function()
        if type(CPLite.RestoreCP) ~= "function" then dprint("RestoreCP not found.") else CPLite:RestoreCP() end
    end
    SLASH_COMMANDS["/resetcp"] = function()
        if type(CPLite.ResetCP) ~= "function" then dprint("ResetCP not found.") else CPLite:ResetCP() end
    end

    dprint("Module ChampionPointsLite loaded. Commands: /savecp /restorecp /resetcp")
end
