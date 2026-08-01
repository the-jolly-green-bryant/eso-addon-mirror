--[[
    AchievementInfo
    @author Asto, @Astarax
]]



-- Do the magic
function AchievementInfo.onAchievementUpdated(_, achId)
    local output            = ""

    -- addOn enabled?
    if AchievementInfo.settingGet("genEnabled") == false then
        if AchievementInfo.settingGet("devDebug") == false then
            return
        else
            output = output .. "DEBUG (AddOn Disabled): "
        end
    end
    --

    local categoryId = AchievementInfo.getCorrectAchievementCategoryId(achId)

    -- ignore unwanted achievements ...
    if categoryId == false then
        if AchievementInfo.settingGet("devDebug") == false then
            return
        else
            output = output .. "DEBUG (Not Next): "
        end
    end
    --

    -- achievement category enabled?
    if categoryId ~= false and AchievementInfo.settingGet("cat"..categoryId) == false then
        if AchievementInfo.settingGet("devDebug") == false then
            return
        else
            output = output .. "DEBUG (Category Off): "
        end
    end
    --

    -- okay continue with the message
    local detailOutput          = {}
    local detailOutputCount     = 1
    local percentageCmpSum      = 0
    local percentageReqSum      = 0
    local percentageStep        = false
    local percentageStepSize    = AchievementInfo.settingGet("genShowUpdateSteps")

    local link = GetAchievementLink(achId, LINK_STYLE_BRACKETS)
    local catName = "/"

    if categoryId ~= false then
        catName = GetAchievementCategoryInfo(categoryId)
    end

    output = output .. "" .. link .. " (" .. catName .. ")"

    local numCriteria = GetAchievementNumCriteria(achId)
    for i = 1, numCriteria, 1 do
        local description, numCompleted, numRequired = GetAchievementCriterion(achId, i)
        local tmpOutput = ""

        if i > 1 and AchievementInfo.settingGet("genOnePerLine") == false then
            tmpOutput = tmpOutput .. ", "
        end

        tmpOutput = tmpOutput .. zo_strformat("<<1>>", description) .. " "
        tmpOutput = tmpOutput .. AchievementInfo.calcCriteriaColor(numCompleted, numRequired) .. numCompleted .. "|r"
        tmpOutput = tmpOutput .. AchievementInfo.clrDefault .. "/" .. "|r"
        tmpOutput = tmpOutput .. AchievementInfo.clrCriteriaComplete .. numRequired .. "|r"
        tmpOutput = tmpOutput .. AchievementInfo.clrDefault

        if AchievementInfo.settingGet("genShowOpenDetailsOnly") == true then
            if numCompleted ~= numRequired then
                detailOutput[detailOutputCount] = tmpOutput
                detailOutputCount = detailOutputCount + 1
            end
        else
            detailOutput[detailOutputCount] = tmpOutput
            detailOutputCount = detailOutputCount + 1
        end

        -- show the achievement on every special achievement because it's a rare event
        if numRequired == 1 and numCompleted == 1 then
            percentageStep = true
        -- collect the numbers to calculate the correct percentage
        else
            percentageReqSum = percentageReqSum + numRequired
            percentageCmpSum = percentageCmpSum + numCompleted
        end
    end

    if percentageStep == false then
        -- show at percent value
        local percentage = 100 / percentageReqSum * percentageCmpSum
        local percentageNext = 100 / percentageReqSum * (percentageCmpSum + 1)

        -- if percentage of percentageStepSize is hit or the value is next to it and the next value will be higher
        if --[[percentage > 0 and]] percentage % percentageStepSize == 0 or (percentage % percentageStepSize > percentageNext % percentageStepSize and percentageNext % percentageStepSize ~= 0) then
            percentageStep = true
        -- show if this is the first numCompleted value
        elseif percentageCmpSum == 1 then
            percentageStep = true
        end
    end

    -- show details?
    local detailsCount = AchievementInfo.tableLength(detailOutput)
    if AchievementInfo.settingGet("genShowDetails") == true and detailsCount > 0 and AchievementInfo.settingGet("genOnePerLine") == false then
        output = output .. " - "

        for i = 1, detailsCount, 1 do
            output = output .. detailOutput[i]
        end
    else
        output = output .. "."
    end
    --

    -- output on every step OR when its a defined percentage step
    if AchievementInfo.settingGet("genShowEveryUpdate") == false and percentageStep == false then
        if AchievementInfo.settingGet("devDebug") == false then
            return
        else
            output = "DEBUG (" .. AchievementInfo.settingGet("genShowUpdateSteps") .. "% Rule): " .. output
        end
    end
    --

    --
    if percentageReqSum == percentageCmpSum then
        output = LANG.Completed .. ": " .. output
    else
        output = LANG.Updated .. ": " .. output
    end
    --

    AchievementInfo.echo(output)

    -- output the details line by line - start @2 because the normal output happend before (achievement name)
    if AchievementInfo.settingGet("genShowDetails") == true and AchievementInfo.settingGet("genOnePerLine") == true then
        for i = 1, AchievementInfo.tableLength(detailOutput), 1 do
            AchievementInfo.echo(detailOutput[i])
        end
    end
end



-- Check if the category of an achievement is valid (reverse check)
function AchievementInfo.checkForValidCategory(achId)
    local categoryTopLevelIndex, categoryIndex, achievementIndex = GetCategoryInfoFromAchievementId(achId)
    local reverseAchievementId = GetAchievementId(categoryTopLevelIndex, categoryIndex, achievementIndex)

    if achId == reverseAchievementId then
        return true
    end

    return false
end



-- Get the correct achievement category
function AchievementInfo.getCorrectAchievementCategoryId(achId)
    local previousAchievementId = GetPreviousAchievementInLine(achId)

    if AchievementInfo.checkForValidCategory(achId) == false and previousAchievementId ~= 0 then
        return AchievementInfo.getCorrectAchievementCategoryId(previousAchievementId)
    elseif AchievementInfo.checkForValidCategory(achId) then
        return GetCategoryInfoFromAchievementId(achId)
    else
        return false
    end
end



-- Calculates the percentage of the achievement completition to define the color
function AchievementInfo.calcCriteriaColor(completed, required)
    local percentage = 100 / required * completed

    if completed == required then
        return AchievementInfo.clrCriteriaComplete
    elseif percentage <= 33 then
        return AchievementInfo.clrCriteriaFar
    elseif percentage <= 66 then
        return AchievementInfo.clrCriteriaMedi
    else
        return AchievementInfo.clrCriteriaClose
    end
end
