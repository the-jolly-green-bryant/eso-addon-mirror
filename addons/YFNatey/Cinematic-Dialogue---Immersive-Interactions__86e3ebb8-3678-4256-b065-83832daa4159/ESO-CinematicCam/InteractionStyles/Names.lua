---=============================================================================
-- STATE AND DATA STRUCTURES
--=============================================================================
-- NPC Name tables
CinematicCam.npcNameData = {
    originalName = "",
    customNameControl = nil,
    currentPreset = "default"
}

---=============================================================================
-- APPLY NPC NAME USER SETTINGS
--=============================================================================
function CinematicCam:ApplyNPCNamePreset(preset)
    preset = preset or self.savedVars.npcNamePreset or "default"
    CinematicCam.npcNameData.currentPreset = preset

    local npcName, originalElement = self:GetNPCName()

    if preset == "default" then
        -- Show original ESO name element
        if originalElement then
            originalElement:SetHidden(false)
        end
        -- Hide custom name control
        if CinematicCam.npcNameData.customNameControl then
            CinematicCam.npcNameData.customNameControl:SetHidden(true)
        end
    elseif preset == "prepended" then
        -- Hide original name element
        if originalElement then
            originalElement:SetHidden(true)
            originalElement:SetText("")
            if self.savedVars.usePlayerName then
                originalElement:SetHidden(false)
                originalElement:SetText(GetUnitName("player"))
                originalElement:SetColor(self.savedVars.playerNameColor.r, self.savedVars.playerNameColor.g,
                    self.savedVars.playerNameColor.b, self.savedVars.playerNameColor.a)
            else
                originalElement:SetColor(self.savedVars.npcNameColor.r, self.savedVars.npcNameColor.g,
                    self.savedVars.npcNameColor.b, self.savedVars.npcNameColor.a)
            end
        end
        -- Hide custom name control (name will be in dialogue text)
        if CinematicCam.npcNameData.customNameControl then
            CinematicCam.npcNameData.customNameControl:SetHidden(true)
        end
    elseif preset == "above" then
        -- Hide original name element
        if originalElement then
            originalElement:SetHidden(true)
        end

        -- Show custom name control
        if not CinematicCam.npcNameData.customNameControl then
            self:CreateNPCNameControl()
        end

        local control = CinematicCam.npcNameData.customNameControl
        if control and npcName then
            control:SetText(npcName)

            control:SetHidden(false)
        end
    end

    -- Save NPC Name for references
    CinematicCam.npcNameData.originalName = npcName or ""
end

---=============================================================================
-- UTILITY FUNCTIONS
--=============================================================================
function CinematicCam:GetNPCName()
    local sources = {
        ZO_InteractWindow_GamepadTitle,
        ZO_InteractWindowTargetAreaTitle
    }

    for _, element in ipairs(sources) do
        if element then
            local name = element.text or element:GetText() or ""
            if string.len(name) > 0 then
                return name, element
            end
        end
    end
    return nil, nil
end

function CinematicCam:CreateNPCNameControl()
    if CinematicCam.npcNameData.customNameControl then
        return CinematicCam.npcNameData.customNameControl
    end

    -- Create custom label control for NPC name
    local control = CreateControl("CinematicCam_NPCName", GuiRoot, CT_LABEL)

    -- Set text properties
    control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Apply NPC name color
    local color = self.savedVars.npcNameColor or namePresetDefaults.npcNameColor
    control:SetColor(color.r, color.g, color.b, color.a)

    -- Apply font
    local fontSize = self.savedVars.npcNameFontSize or namePresetDefaults.npcNameFontSize
    self:ApplyFontToElement(control, fontSize)

    -- Set draw properties
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDrawLevel(7)

    -- Initially hidden
    control:SetHidden(true)
    control:SetText("")

    CinematicCam.npcNameData.customNameControl = control
    return control
end

function CinematicCam:HandleNPCName(dialogueText, npcName, preset)
    if not npcName or npcName == "" then
        return dialogueText
    end
    preset = preset or self.savedVars.npcNamePreset or "default"
    if preset == "prepended" then
        -- Check if this is a companion with a custom color
        local color = self.savedVars.npcNameColor -- Default to NPC color

        if self.savedVars.companionColors then
            local companionKey = npcName:lower()
            if self.savedVars.companionColors[companionKey] then
                color = self.savedVars.companionColors[companionKey]
            end
        end

        local hexColor = self:RGBToHexString(color.r, color.g, color.b)
        local coloredName = "|c" .. hexColor .. npcName .. ": |r"
        return coloredName .. dialogueText
    elseif preset == "above" then
        return dialogueText
    else
        return dialogueText
    end
end

function CinematicCam:UpdateNPCNameFont()
    local control = CinematicCam.npcNameData.customNameControl
    if control then
        local fontSize = self.savedVars.npcNameFontSize
        self:ApplyFontToElement(control, fontSize)
    end
end

-- Update Color
function CinematicCam:UpdateNPCNameColor()
    local control = CinematicCam.npcNameData.customNameControl
    if control then
        local npcName = CinematicCam.npcNameData.currentNPCName
        local color = self.savedVars.npcNameColor

        -- Check if this is a companion with a custom color
        if npcName and self.savedVars.companionColors then
            local companionKey = npcName:lower()
            if self.savedVars.companionColors[companionKey] then
                color = self.savedVars.companionColors[companionKey]
            end
        end

        control:SetColor(color.r, color.g, color.b, color.a or 1)
    end
end

function CinematicCam:RGBToHexString(r, g, b)
    -- Convert 0-1 float values to 0-255 integer values
    local red = math.floor(r * 255)
    local green = math.floor(g * 255)
    local blue = math.floor(b * 255)
    -- Convert to hex
    return string.format("%02X%02X%02X", red, green, blue)
end
