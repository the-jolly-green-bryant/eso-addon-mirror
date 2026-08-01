CF = {
    Name = "CompanionFrame",
    VariableVersion = 1,
    Defaults = {
        ButtonLockPosition = false,
        FrameExperienceColour = {0, 1, 1},
        FrameFont = "ESO Bold",
        FrameFontColour = {1, 1, 1, 0.6},
        FrameFontSize = 18,
        FrameHealthColour = {133 / 255, 18 / 255, 13 / 255},
        FrameHeight = 180,
        FrameWidth = 350,
        HideWhenGrouped = false,
        LockPosition = false,
        RapportLikeColour = {114 / 255, 35 / 255, 35 / 255},
        RapportModerateColour = {157 / 255, 132 / 255, 13 / 255},
        RapportDislikeColour = {0, 153 / 255, 102 / 255},
        Resummon = false,
        ShowButtons = false,
        ShowDismiss = true,
        ShowExperience = true,
        ShowLevel = true,
        ShowName = true,
        ShowRapport = true,
        ShowRapportIcon = true,
        Summoning = true,
        SummoningColour = {157 / 255, 132 / 255, 13 / 255, 1}
    },
    Core = {}
}

function CF.Core.DisplayNumber(number, decimalPlaces)
    -- Determine thousands and decimal format
    local thousands = CF.Language == "en" and "," or "."
    local decimal = CF.Language == "en" and "." or ","

    decimalPlaces = decimalPlaces or 0
    local output

    if (number < 1000) then
        -- Greater than 1000 with decimals
        output = string.format("%." .. decimalPlaces .. "f", number)
        output = string.gsub(output, "%.", decimal)
    elseif (number >= 1000 and decimalPlaces > 0) then
        output = string.format("%." .. decimalPlaces .. "f", number)
        local left, right = zo_strsplit("%.", output)
        left = FormatIntegerWithDigitGrouping(left, thousands)
        output = left .. decimal .. right
    else
        output = FormatIntegerWithDigitGrouping(number, thousands)
    end

    -- Return the output
    return output
end

function CF.HideDefaultCompanionFrame()
    if (not IsUnitGrouped("player") and UNIT_FRAMES:GetFrame("companion") ~= nil) then
        UNIT_FRAMES:GetFrame("companion"):SetHiddenForReason("disabled", true)
    end
end

function CF.SlashCommand()
    CF.LAM:OpenToPanel(_G.CompanionFrameOptionsPanel)
end

function CF.IsCompanionUsable(companionId)
    if (IsCollectibleBlocked(companionId)) then
        return false
    end
    if (IsCollectibleUsable(companionId)) then
        return true
    end
    return false
end
