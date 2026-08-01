local fontBook = {
    ["ESO_Standard"] = {
        name = "Standard",
        path = nil,
        description = "Default ESO font"
    },
    ["ESO_Bold"] = {
        name = "Bold",
        path = "EsoUI/Common/Fonts/FTN87.slug|30|thick-outline",
        description = "Bold ESO font"
    },
    ["Handwritten"] = {
        name = "Handwritten",
        path = "EsoUI/Common/Fonts/ProseAntiquePSMT.slug|30|soft-shadow-thick",
        description = "Handwritten-style font"
    },

}
function CinematicCam:GetFontChoices()
    local choices = {}
    local choicesValues = {}

    for fontId, fontData in pairs(fontBook) do
        table.insert(choices, fontData.name)
        table.insert(choicesValues, fontId)
    end

    return choices, choicesValues
end

function CinematicCam:GetCurrentFont()
    local fontData = fontBook[self.savedVars.interface.selectedFont]
    if fontData then
        return fontData.path
    end
    return fontBook["ESO_Standard"].path -- fallback
end

function CinematicCam:ParseFontPath(fontPath, newSize)
    if not fontPath or fontPath == "" then
        return nil
    end

    -- Check if the path contains a size (pattern: |number|)
    local hasSize = string.find(fontPath, "|%d+|")

    if hasSize then
        -- Replace existing size with new size
        local newPath = string.gsub(fontPath, "|%d+|", "|" .. newSize .. "|")
        return newPath
    else
        -- No size found, check if it has effects after the font file
        local hasEffects = string.find(fontPath, "|")

        if hasEffects then
            -- Has effects but no size, insert size before effects
            local newPath = string.gsub(fontPath, "|", "|" .. newSize .. "|", 1)
            return newPath
        else
            -- No size, no effects, just add size
            return fontPath .. "|" .. newSize
        end
    end
end

function CinematicCam:BuildUserFontString()
    local selectedFont = self.savedVars.interface.selectedFont
    local fontSize = self.savedVars.interface.customFontSize
    local fontScale = self.savedVars.interface.fontScale
    local finalSize = math.floor(fontSize * fontScale)

    if selectedFont == "ESO_Standard" then
        return "EsoUI/Common/Fonts/FTN57.slug|" .. finalSize .. "|soft-shadow-thick"
    elseif selectedFont == "ESO_Bold" then
        return "EsoUI/Common/Fonts/FTN87.slug|" .. finalSize .. "|soft-shadow-thick"
    elseif selectedFont == "Handwritten" and self.savedVars.interface.cinematicBackgroundMode ~= 'none' then
        return "EsoUI/Common/Fonts/ProseAntiquePSMT.slug|" .. finalSize .. ""
    elseif selectedFont == "Handwritten" and self.savedVars.interface.cinematicBackgroundMode == 'none' then
        return "EsoUI/Common/Fonts/ProseAntiquePSMT.slug|" .. finalSize .. "|soft-shadow-thick"
    end
end

function CinematicCam:OnFontChanged()
    self:UpdateChunkedTextFont()
    self:ApplyFontsToUI()

    local interactionType = GetInteractionType()
    if interactionType ~= INTERACTION_NONE then
        self:ApplyFontsToUI()
    end
end

function CinematicCam:ApplyFontToElement(element, fontSize)
    if not element then
        return
    end

    local fontPath = self:GetCurrentFont()
    local actualSize = fontSize or self.savedVars.interface.customFontSize
    actualSize = math.floor(actualSize * self.savedVars.interface.fontScale)
    if not fontPath then
        local defaultFontString = "EsoUI/Common/Fonts/FTN57.slug|" .. actualSize .. "|soft-shadow-thick"
        element:SetFont(defaultFontString)
        return
    end
    local finalFontString = self:ParseFontPath(fontPath, actualSize)
    if finalFontString then
        element:SetFont(finalFontString)
    end
end

function CinematicCam:ApplyFontsToUI()
    local fontSize = self.savedVars.interface.customFontSize
    if ZO_InteractWindowTargetAreaTitle then
        self:ApplyFontToElement(ZO_InteractWindowTargetAreaTitle, fontSize)
    end
    if ZO_InteractWindow_GamepadTitle then
        self:ApplyFontToElement(ZO_InteractWindow_GamepadTitle, fontSize)
    end
    if ZO_InteractWindowTargetAreaBodyText then
        self:ApplyFontToElement(ZO_InteractWindowTargetAreaBodyText, fontSize)
    end

    if ZO_InteractWindow_GamepadContainerText then
        self:ApplyFontToElement(ZO_InteractWindow_GamepadContainerText, fontSize)
    end
    if ZO_InteractWindowPlayerAreaOptions then
        self:ApplyFontToElement(ZO_InteractWindowPlayerAreaOptions, fontSize)
    end
    if ZO_InteractWindowPlayerAreaHighlight then
        self:ApplyFontToElement(ZO_InteractWindowPlayerAreaHighlight, fontSize)
    end
    for i = 1, 10 do
        local longOptionName = "ZO_InteractWindow_GamepadContainerInteractListScrollZO_ChatterOption_Gamepad" ..
            i .. "Text"
        local option = _G[longOptionName]
        if option then
            self:ApplyFontToElement(option, fontSize)
        end
    end
end
