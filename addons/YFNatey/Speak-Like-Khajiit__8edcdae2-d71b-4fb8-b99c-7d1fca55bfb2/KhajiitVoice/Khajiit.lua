local originalSetText = {}
local function getStableRandom(text, min, max)
    -- Create a stable seed based on the text content
    local seed = 0
    for i = 1, #text do
        seed = seed + string.byte(text, i)
    end

    -- Use the seed to get a deterministic "random" number
    math.randomseed(seed)
    local result = math.random(min, max)

    -- Reset random seed for other uses
    math.randomseed(os.time())
    return result
end
function KhajiitVoice:StartDialogueSession()
    self.currentDialogueReplacements = {}
    self.firstAppearanceCache = {}


    self.dialogueSessionStarted = true
    self.hookedElements = self.hookedElements or {}
    self:HookDialogueElements()
end

function KhajiitVoice:HookDialogueElements()
    local function hookElement(element)
        if not element or not element.SetText then
            return
        end

        local elementId = tostring(element)
        if self.hookedElements[elementId] then
            return
        end

        originalSetText[elementId] = element.SetText
        element.SetText = function(self, text)
            local processedText = KhajiitVoice:InterceptAndProcessText(text, element)
            return originalSetText[elementId](self, processedText)
        end

        self.hookedElements[elementId] = true
    end
    self:GetPlayerChoices(hookElement)
    self:StartElementMonitoring(hookElement)
end

function KhajiitVoice:GetPlayerChoices(hookFunction)
    local gamepadScrollContainer = ZO_InteractWindow_GamepadContainerInteractListScroll
    if gamepadScrollContainer then
        local numChildren = gamepadScrollContainer:GetNumChildren()
        for i = 1, numChildren do
            local option = gamepadScrollContainer:GetChild(i)
            if option then
                local textElement = self:FindTextElement(option)
                if textElement then
                    hookFunction(textElement)
                end
            end
        end
    end
    for i = 1, 10 do
        local longOptionName = "ZO_InteractWindow_GamepadContainerInteractListScrollZO_ChatterOption_Gamepad" .. i
        local option = _G[longOptionName]
        if option then
            local textElement = self:FindTextElement(option)
            if textElement then
                hookFunction(textElement)
            end
        end

        local shortOptionName = "ZO_ChatterOption_Gamepad" .. i
        local option2 = _G[shortOptionName]
        if option2 then
            local textElement = self:FindTextElement(option2)
            if textElement then
                hookFunction(textElement)
            end
        end
    end
end

function KhajiitVoice:StartElementMonitoring(hookFunction)
    self.elementMonitoringActive = true

    local function monitorElements()
        if not self.elementMonitoringActive then
            return
        end

        -- Check for new elements to hook
        self:GetPlayerChoices(hookFunction)

        -- Check again in 1 second (very infrequent)
        zo_callLater(monitorElements, 10000)
    end

    monitorElements()
end

function KhajiitVoice:InterceptAndProcessText(text, element)
    if not text or text == "" then
        return text
    end

    if not KhajiitVoice.savedVars or not KhajiitVoice.savedVars.enabled then
        return text
    end

    -- Check cache first for instant results
    if self.currentDialogueReplacements[text] then
        return self.currentDialogueReplacements[text]
    end

    -- Process the text
    local processedText = self:ProcessDialogue(text)

    -- Cache the result
    self.currentDialogueReplacements[text] = processedText

    return processedText
end

function KhajiitVoice:ProcessDialogue(originalText)
    if not KhajiitVoice.savedVars.enabled or not KhajiitVoice.savedVars.permKhajiit then
        return originalText
    end

    -- Check if we already have a complete replacement for this exact text
    if self.currentDialogueReplacements[originalText] then
        return self.currentDialogueReplacements[originalText]
    end

    -- Check if we should use Cyrodiilic tone (Imperial speech) instead of Khajiit speech
    local cyrodiilicTone = KhajiitVoice.savedVars.personalityTraits.cyrodiilicTone or 0

    -- Random chance to skip Khajiit speech processing based on Cyrodiilic tone
    if cyrodiilicTone > 0 and getStableRandom(originalText, 1, 100, "cyrodiilic") <= cyrodiilicTone then
        self.currentDialogueReplacements[originalText] = originalText
        return originalText
    end

    local processedText = originalText
    processedText = self:ReplaceCharacterNameReferences(processedText)
    -- STEP 1: Handle player name cases first, before any other processing
    processedText = self:HandlePlayerNameCases(processedText)

    -- STEP 2: Get self-reference (this will force "this one" if name detected)
    local selfRef = self:GetSelfReference(originalText) -- Remove the duplicate line

    -- STEP 3: Replace pronouns
    processedText = self:ReplacePronouns(processedText, selfRef)


    -- STEP 4: Conjugate verbs AFTER pronoun replacement
    processedText = self:ConjugateVerbs(processedText, selfRef)

    -- STEP 5: Handle questions
    processedText = self:HandleQuestions(processedText, originalText)

    -- STEP 6: Apply personality traits
    processedText = self:ApplyPersonalityTraits(processedText, originalText)
    -- STEP 7: Ensure punctuation
    processedText = self:EnsurePunctuation(processedText)
    -- STEP 8: Convert second pronoun
    processedText = self:ConvertSecondPronounToGenderedSimple(processedText)
    -- STEP 9: Edge Cases
    processedText = self:FixEdgeCases(processedText, selfRef)

    -- Store the complete transformation for this dialogue session
    self.currentDialogueReplacements[originalText] = processedText

    return processedText
end

function KhajiitVoice:OnDialogueEnd()
    self.elementMonitoringActive = false -- Stop element monitoring
    self:UnhookSetTextMethods()
    self.dialogueSessionStarted = false  -- Reset session flags

    -- Clear caches
    self.currentDialogueReplacements = {}
    self.firstAppearanceCache = {}
end

-- Restore original SetText methods when dialogue ends
function KhajiitVoice:UnhookSetTextMethods()
    if not self.hookedElements then
        return
    end

    for elementId, _ in pairs(self.hookedElements) do
        -- Find the element by scanning for matching IDs
        -- This is a bit hacky but necessary since we only have the string ID
        local found = false

        -- Check gamepad elements
        local gamepadScrollContainer = ZO_InteractWindow_GamepadContainerInteractListScroll
        if gamepadScrollContainer and not found then
            local numChildren = gamepadScrollContainer:GetNumChildren()
            for i = 1, numChildren do
                local option = gamepadScrollContainer:GetChild(i)
                if option then
                    local textElement = self:FindTextElement(option)
                    if textElement and tostring(textElement) == elementId then
                        if originalSetText[elementId] then
                            textElement.SetText = originalSetText[elementId]
                            originalSetText[elementId] = nil
                        end
                        found = true
                        break
                    end
                end
            end
        end

        -- Check named dialogue options if not found
        if not found then
            for i = 1, 10 do
                local longOptionName = "ZO_InteractWindow_GamepadContainerInteractListScrollZO_ChatterOption_Gamepad" ..
                    i
                local option = _G[longOptionName]
                if option then
                    local textElement = self:FindTextElement(option)
                    if textElement and tostring(textElement) == elementId then
                        if originalSetText[elementId] then
                            textElement.SetText = originalSetText[elementId]
                            originalSetText[elementId] = nil
                        end
                        found = true
                        break
                    end
                end

                local shortOptionName = "ZO_ChatterOption_Gamepad" .. i
                local option2 = _G[shortOptionName]
                if option2 then
                    local textElement = self:FindTextElement(option2)
                    if textElement and tostring(textElement) == elementId then
                        if originalSetText[elementId] then
                            textElement.SetText = originalSetText[elementId]
                            originalSetText[elementId] = nil
                        end
                        found = true
                        break
                    end
                end
            end
        end
    end

    self.hookedElements = {}
end

-- Function to restore original dialogue hooks
function KhajiitVoice:RestoreDialogueHooks()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_CHATTER_END)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_GAME_CAMERA_DEACTIVATED)
end
