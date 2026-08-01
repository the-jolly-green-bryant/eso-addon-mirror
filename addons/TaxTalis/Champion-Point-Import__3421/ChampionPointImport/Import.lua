-----------------------------------------------------------------------------------
-- Addon Name: Champion Point Import
-- Creator: TaxTalis
-- Addon Ideal: Import Champion Points from text
-- Addon Creation Date: 2022-06-20
--
-- File Name: Import.lua
-- File Description: This file contains the class definition
-- Load Order Requirements: After Main
--
-----------------------------------------------------------------------------------
local CPI = ChampionPointImport
local CDM = CPI.Import(CHAMPION_DATA_MANAGER)
local CP = CPI.Import(CHAMPION_PERKS)
local ImportManager = {}
CPI.ImportManager = ImportManager

local function strip(String)
    return String:gsub('’', ''):gsub('[^%w%s%c]+', ''):lower()
end
local function trim(s)
    return s:match '^()%s*$' and '' or s:match '^%s*(.*%S)'
end

local function GetJumpPointForPoints(jumpPoints, points)
    local pointsJumpPoint
    for _, jumpPoint in ipairs(jumpPoints) do
        if (jumpPoint > points) then
            pointsJumpPoint = pointsJumpPoint or 0
            break
        end
        pointsJumpPoint = jumpPoint
    end
    return pointsJumpPoint or points
end
function ImportManager.Import(skillsByName, input)
    local import = {}
    local textStripped = strip(input)
    for line in textStripped:gmatch("%C*%d+%C*") do
        line = trim(line)
        local matchedSkillName
        for skillName in pairs(skillsByName) do
            if((not matchedSkillName or #matchedSkillName < #skillName)
                    and line:find(skillName)) then
                matchedSkillName = skillName
            end
        end
        if (matchedSkillName) then
            local skill = skillsByName[matchedSkillName]
            local pointsAndSlotted = line:gsub(matchedSkillName, "")
            local slotted = skill.isSlottable and pointsAndSlotted:find("slot") ~= nil
            for stringPoints in pointsAndSlotted:gmatch("%d+") do
                local pointsDesired = tonumber(stringPoints)
                if (not pointsDesired) then
                    d(skill.name .. ": Could not convert I" .. stringPoints .. "I to a number.")
                else
                    local disciplineImport = import[skill.disciplineId] or {}
                    disciplineImport[#disciplineImport + 1] = { skillId = skill.skillId, pointsDesired = pointsDesired, slotted = slotted }
                    import[skill.disciplineId] = disciplineImport
                end
            end
        else
            d("######### UNRECOGNIZED SKILL #########")
            d(line)
            d("#######################################")
        end
    end

    return import
end
function ImportManager.Calculate(disciplines, import)
    local outcome = {}
    outcome.disciplines = {}
    for disciplineId, discipline in pairs(disciplines) do
        local championDiscipline = CDM:FindChampionDisciplineDataById(disciplineId)
        local pointsAvailable = championDiscipline:GetNumSavedPointsTotal()
        local outcomeSkills = {}
        local outcomeBar = {}
        for slotIndex in pairs(discipline.bar) do
            outcomeBar[#outcomeBar + 1] = { slotIndex = slotIndex }
        end

        for _, skill in pairs(discipline.skills) do
            outcomeSkills[skill.skillId] = { points = 0, pointsReached = { 0 }, pointsDesired = {}, slot = nil }
        end
        for _, importSkill in ipairs(import[disciplineId] or {}) do
            local skillId = importSkill.skillId
            local pointsDesired = importSkill.pointsDesired
            local slotted = importSkill.slotted
            local outcomeSkill = outcomeSkills[skillId]
            local pointsCurrentlyCalculated = outcomeSkill.points
            local pointsSkillMax = GetChampionSkillMaxPoints(skillId)
            local pointsDesiredCapped = math.min(pointsDesired, pointsSkillMax)
            local jumpPoints = { GetChampionSkillJumpPoints(skillId) }
            local pointsDesiredJumpPointCapped = GetJumpPointForPoints(jumpPoints, pointsDesiredCapped)
            local pointsDifference = pointsDesiredJumpPointCapped - pointsCurrentlyCalculated
            if (pointsDifference ~= 0) then
                local pointsDifferenceCapped = math.min(pointsDifference, pointsAvailable)
                local pointsPossibleJumpPointCapped = GetJumpPointForPoints(jumpPoints, pointsCurrentlyCalculated + pointsDifferenceCapped)

                if (pointsPossibleJumpPointCapped < pointsDesiredJumpPointCapped) then
                    local idx = #outcomeSkill.pointsDesired
                    if (outcomeSkill.pointsDesired[idx] ~= pointsDesiredCapped) then
                        outcomeSkill.pointsDesired[idx + 1] = pointsDesiredCapped
                    end
                end
                local idx = #outcomeSkill.pointsReached
                if (outcomeSkill.pointsReached[idx] ~= pointsPossibleJumpPointCapped) then
                    outcomeSkill.pointsReached[idx + 1] = pointsPossibleJumpPointCapped
                end
                outcomeSkill.points = pointsPossibleJumpPointCapped

                pointsAvailable = pointsAvailable - (pointsPossibleJumpPointCapped - pointsCurrentlyCalculated)
            end

            local wouldBeUnlocked = WouldChampionSkillNodeBeUnlocked(skillId, outcomeSkill.points)
            if (slotted and wouldBeUnlocked) then
                if (not outcomeSkill.slot) then
                    for _, slot in pairs(outcomeBar) do
                        if (not slot.skillId) then
                            slot.skillId = skillId
                            outcomeSkill.slot = slot
                            break
                        end
                    end
                end
            elseif (outcomeSkill.slot) then
                outcomeSkill.slot.skillId = nil
                outcomeSkill.slot = nil
            end
        end
        outcome.disciplines[disciplineId] = { bar = outcomeBar, skills = outcomeSkills }
    end
    return outcome
end
function ImportManager.Redistribute(outcome, allowRespec)
    if (not outcome) then
        return
    end
    allowRespec = allowRespec or false

    local isRespecNeeded = ImportManager.IsRespecNeeded(outcome)
    if (not isRespecNeeded or allowRespec) then
        PrepareChampionPurchaseRequest(isRespecNeeded)
        for _, discipline in pairs(outcome.disciplines) do
            for skillId, skill in pairs(discipline.skills) do
                local points = skill.points
                AddSkillToChampionPurchaseRequest(skillId, points)
            end
            for _, slot in pairs(discipline.bar) do
                local slotIndex = slot.slotIndex
                local skillId = slot.skillId
                AddHotbarSlotToChampionPurchaseRequest(slotIndex, skillId)
            end
        end
        SendChampionPurchaseRequest()
    end
end
function ImportManager.IsEqualToCurrent(outcome)
    local isEqualToCurrent = true
    if (outcome) then
        for _, discipline in pairs(outcome.disciplines) do
            for skillId, skill in pairs(discipline.skills) do
                local points = skill.points
                local pointsSpent = GetNumPointsSpentOnChampionSkill(skillId)
                if (points ~= pointsSpent) then
                    isEqualToCurrent = false
                    break
                end
                if(skill.slot) then
                    local championSkillData = CDM:GetChampionSkillData(skillId)
                    if(not CP:IsChampionSkillDataSlotted(championSkillData)) then
                        isEqualToCurrent = false
                        break
                    end
                end
            end
        end
    end
    return isEqualToCurrent
end
function ImportManager.IsRespecNeeded(outcome)
    local isRespecNeeded = false
    if (outcome) then
        for _, discipline in pairs(outcome.disciplines) do
            for skillId, skill in pairs(discipline.skills) do
                local points = skill.points
                local pointsSpent = GetNumPointsSpentOnChampionSkill(skillId)
                if (points < pointsSpent) then
                    isRespecNeeded = true
                    break
                end
            end
        end
    end
    return isRespecNeeded
end
function ImportManager.GetOutcomeForSkill(outcome, disciplineId, skillId)
    local result = {}
    if(outcome
            and outcome.disciplines
            and outcome.disciplines[disciplineId]
            and outcome.disciplines[disciplineId].skills
            and outcome.disciplines[disciplineId].skills[skillId]) then
        result = outcome.disciplines[disciplineId].skills[skillId]
    end
    return result
end


-------------------------------------------
--- INITIALIZE ----------------------------
-------------------------------------------
local function initialize()
end
CPI.addInitialize(initialize)