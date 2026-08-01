CinematicCam.emoteMenuVisible = false
local AUTO_EMOTE_CHANCES = {
    frequent = 85,   -- 85% chance
    normal = 50,
    infrequent = 30, -- 30% chance
    minimal = 10     -- 15% chance
}
function CinematicCam:GetDialogueData()
    local npcText = ""
    local npcName = ""
    local playerOptions = ""

    -- Get NPC dialogue text
    local dialogueText, _ = self:GetDialogueText()
    if dialogueText and string.len(dialogueText) > 0 then
        npcText = dialogueText
    end

    -- Get NPC name
    local npcNameText, _ = self:GetNPCName()
    if npcNameText and string.len(npcNameText) > 0 then
        npcName = npcNameText
    end

    -- Get player options
    local optionsTable = {}

    -- Check both long and short option element names
    for i = 1, 10 do
        local longOptionName = "ZO_InteractWindow_GamepadContainerInteractListScrollZO_ChatterOption_Gamepad" .. i
        local shortOptionName = "ZO_ChatterOption_Gamepad" .. i

        -- Try long name first
        local option = _G[longOptionName]
        if not option then
            -- Try short name
            option = _G[shortOptionName]
        end

        if option then
            local textElement = self:FindPlayerOptionTextElement(option)
            if textElement then
                local optionText = textElement:GetText() or ""
                if optionText ~= "" then
                    table.insert(optionsTable, optionText)
                end
            end
        end
    end

    -- Join all options with comma separator
    if #optionsTable > 0 then
        playerOptions = table.concat(optionsTable, ", ")
    end

    return npcText, npcName, playerOptions
end

function CinematicCam:determineAutoEmote(dialogType)
    local npcText, npcName, playerOptions = CinematicCam:GetDialogueData()
    if not self:ShouldPlayAutoEmote() then return end

    -- If player Options contains ">" it is an action, don't play an emote
    if playerOptions and string.find(playerOptions, ">") then
        return nil
    end

    -- If npc Name contains ">" it is an inanimate object
    if npcName and string.find(npcName, ">") then
        return nil
    end

    if dialogType == "ChatterBegin" then
        -- Crafting Writs
        if npcName == "Consumables Crafting Writs" or npcName == "Equipment Crafting Writs" then
            return CinematicCam:GetEmotePack("reading")
        end

        -- Store detection
        if playerOptions and string.find(playerOptions, "(Store)") then
            return CinematicCam:GetEmotePack("vendor")
        end

        -- Greeting based on type
        if self.savedVars.interaction.GreetingType == "friendly" then
            return self:GetEmotePack("greeting")
        elseif self.savedVars.interaction.GreetingType == "hostile" then
            return self:GetEmotePack("hostile")
        elseif self.savedVars.interaction.GreetingType == "idle" then
            return self:GetEmotePack("idle")
        end
    end

    if dialogType == "ConversationUpdate" then
        -- Crafting Writs
        if npcName == "Consumables Crafting Writs" or npcName == "Equipment Crafting Writs" then
            return CinematicCam:GetEmotePack("reading")
        end

        if playerOptions then
            -- Priority 1: Question detected
            if not self:ShouldPlayAutoEmote() then return end

            if string.find(playerOptions, "?") then
                return CinematicCam:GetEmotePack("confused")
            end

            -- Priority 2: "You" detected
            if string.find(playerOptions, "%f[%a]You%f[%A]") or
                string.find(playerOptions, "%f[%a]you%f[%A]") then
                return CinematicCam:GetEmotePack("pointing")
            end

            -- Priority 3: Fallback to ChatType setting
            if self.savedVars.interaction.ChatType == "friendly" then
                return self:GetEmotePack("chatty")
            elseif self.savedVars.interaction.ChatType == "hostile" then
                return self:GetEmotePack("frustrated")
            end
        end

        -- Use the last used emote slot as fallback
        if not playerOptions or playerOptions == "" then
            local lastUsedSlot = self.savedVars.emoteWheel.lastUsedSlot or 1
            return self:GetEmoteForSlot(lastUsedSlot)
        end
    end

    if dialogType == "QuestCompleteDialog" then
        return CinematicCam:GetEmotePack("reward")
    end

    -- No specific emote determined
    return nil
end

function CinematicCam:ShouldPlayAutoEmote()
    if not self.savedVars.interaction.autoEmotes then
        return false
    end
    if CinematicCam.isMounted then return false end
    local frequency = self.savedVars.interaction.autoEmoteFrequency or "infrequent"
    local chance = AUTO_EMOTE_CHANCES[frequency] or 40

    -- Generate random number between 1-100
    local roll = math.random(1, 100)

    return roll <= chance
end

-- Initialize the emote wheel system
function CinematicCam:InitializeEmoteWheel()
    self.emoteWheelVisible = false
    self.emotePadVisible = false

    -- Set platform-specific trigger icon
    self:SetPlatformTriggerIcon()

    -- Start hidden
    self:HideEmoteWheel()
    self:HideEmotePad()
end

-- Set the correct trigger icon based on platform
-- Set the correct trigger icon based on platform
function CinematicCam:SetPlatformTriggerIcon()
    local xboxLT = _G["CinematicCam_XboxLT"]
    local ps4LT = _G["CinematicCam_PS4LT"]
    local xboxLS_Slide = _G["CinematicCam_XboxLS_Slide"]
    local xboxLS_Scroll = _G["CinematicCam_XboxLS_Scroll"]
    local ps4LS = _G["CinematicCam_PS4LS"]

    if not xboxLT or not ps4LT then
        return
    end

    local worldName = GetWorldName()

    -- Default to Xbox, switch to PS if on PlayStation
    if worldName == "PS4live" or worldName == "PS4live-eu" or worldName == "NA Megaserver" then
        -- Show PlayStation icons
        xboxLT:SetTexture("/esoui/art/buttons/gamepad/ps5/nav_ps5_l2.dds")


        if xboxLS_Slide then xboxLS_Slide:SetTexture("/esoui/art/buttons/gamepad/ps5/nav_ps5_rs_scroll.dds") end
        if xboxLS_Scroll then xboxLS_Scroll:SetTexture("/esoui/art/buttons/gamepad/ps5/nav_ps5_rs_slide.dds") end
        if ps4LS then ps4LS:SetHidden(false) end
    else
        -- Show Xbox icons (includes PC, NA Megaserver, EU Megaserver, XB1live, XB1live-eu)
        xboxLT:SetHidden(false)
        ps4LT:SetHidden(true)

        if xboxLS_Slide then xboxLS_Slide:SetHidden(false) end
        if xboxLS_Scroll then xboxLS_Scroll:SetHidden(false) end
        if ps4LS then ps4LS:SetHidden(true) end
    end
end

-- Show the emote wheel indicator
function CinematicCam:ShowEmoteWheel()
    local control = _G["CinematicCam_EmoteWheel"]
    if not control then return end

    -- Set platform-specific icon BEFORE showing
    self:SetPlatformTriggerIcon()

    control:SetHidden(false)
    control:SetAlpha(0)

    -- Fade in animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local animation = timeline:InsertAnimation(ANIMATION_ALPHA, control)
    animation:SetAlphaValues(0, 1)
    animation:SetDuration(200)
    animation:SetEasingFunction(ZO_EaseOutQuadratic)
    timeline:PlayFromStart()

    self.emoteWheelVisible = true
end

-- Hide the emote wheel indicator
function CinematicCam:HideEmoteWheel()
    local control = _G["CinematicCam_EmoteWheel"]
    if not control then return end

    -- Fade out animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local animation = timeline:InsertAnimation(ANIMATION_ALPHA, control)
    animation:SetAlphaValues(control:GetAlpha(), 0)
    animation:SetDuration(200)
    animation:SetEasingFunction(ZO_EaseOutQuadratic)

    timeline:SetHandler("OnStop", function()
        control:SetHidden(true)
    end)

    timeline:PlayFromStart()

    self.emoteWheelVisible = false
end

-- Show the emote directional pad
function CinematicCam:ShowEmotePad()
    local control = _G["CinematicCam_EmotePad"]
    if not control then return end

    -- Update labels before showing
    self:UpdateEmotePadLabels()

    control:SetHidden(false)
    control:SetAlpha(0)

    -- Fade in animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local animation = timeline:InsertAnimation(ANIMATION_ALPHA, control)
    animation:SetAlphaValues(0, 1)
    animation:SetDuration(150)
    animation:SetEasingFunction(ZO_EaseOutQuadratic)
    timeline:PlayFromStart()

    self.emotePadVisible = true
end

-- Hide the emote directional pad
function CinematicCam:HideEmotePad()
    local control = _G["CinematicCam_EmotePad"]
    if not control then return end

    -- Fade out animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local animation = timeline:InsertAnimation(ANIMATION_ALPHA, control)
    animation:SetAlphaValues(control:GetAlpha(), 0)
    animation:SetDuration(150)
    animation:SetEasingFunction(ZO_EaseOutQuadratic)

    timeline:SetHandler("OnStop", function()
        control:SetHidden(true)
    end)

    timeline:PlayFromStart()

    self.emotePadVisible = false
end

-- Highlight active direction
function CinematicCam:HighlightEmoteDirection(direction)
    local directions = { "Top", "Right", "Bottom", "Left" }

    for _, dir in ipairs(directions) do
        local texture = _G["CinematicCam_EmotePad_" .. dir]
        if texture then
            if dir == direction then
                texture:SetColor(0.3, 0.3, 0.3, 0.95) -- Lighter gray for selected
            else
                texture:SetColor(0, 0, 0, 0.85)       -- Dark for unselected
            end
        end
    end
end

-- Reset all direction highlights
function CinematicCam:ResetEmoteHighlights()
    local directions = { "Top", "Right", "Bottom", "Left" }

    for _, dir in ipairs(directions) do
        local texture = _G["CinematicCam_EmotePad_" .. dir]
        if texture then
            texture:SetColor(0, 0, 0, 0.85)
        end
    end
end

function CinematicCam:GetEmoteForSlot(slotNumber)
    local slotKey = "slot" .. slotNumber
    local packName = self.savedVars.emoteWheel[slotKey]

    if not packName or not CinematicCam.categorizedEmotes[packName] then
        return nil
    end

    local emotePack = CinematicCam.categorizedEmotes[packName]
    local randomIndex = math.random(1, #emotePack)
    return emotePack[randomIndex]
end

function CinematicCam:GetEmotePack(packName)
    if not packName or not CinematicCam.categorizedEmotes[packName] then
        return nil
    end
    local emotePack = CinematicCam.categorizedEmotes[packName]
    local randomIndex = math.random(1, #emotePack)
    return emotePack[randomIndex]
end

function CinematicCam:GetEmotePackDisplayName(packKey)
    local displayNames = {
        respectful = "Respectful",
        friendly = "Friendly",
        greeting = "Greeting",
        flirty = "Flirty",
        hostile = "Hostile",
        frustrated = "Frustrated",
        sad = "Sad",
        scared = "Scared",
        confused = "Confused",
        celebratory = "Celebratory",
        disgusted = "Disgusted",
        eating = "Eating/Drinking",
        entertainment = "Entertainment/Dance",
        idle = "Idle Poses",
        sitting = "Sitting/Resting",
        pointing = "Pointing/Directing",
        physical = "Physical Actions",
        exercise = "Exercise",
        working = "Working/Tools",
        tired = "Tired/Sick",
        agreement = "Agreement",
        disagreement = "Disagreement",
        playful = "Playful",
        attention = "Get Attention",
        misc = "Miscellaneous"
    }
    return displayNames[packKey] or packKey
end

-- Function to update emote pad labels when pack changes
function CinematicCam:UpdateEmotePadLabels()
    local slotMap = {
        [1] = "Top",
        [2] = "Right",
        [3] = "Bottom",
        [4] = "Left"
    }

    for slotNum, direction in pairs(slotMap) do
        local slotKey = "slot" .. slotNum
        local packName = self.savedVars.emoteWheel[slotKey]
        local label = _G["CinematicCam_EmotePad_" .. direction .. "Text"]

        if label and packName then
            label:SetText(self:GetEmotePackDisplayName(packName))
        end
    end
end
