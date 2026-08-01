---=============================================================================
-- STATE AND DATA STRUCTURES
--=============================================================================
local dialogueChangeCheckTimer = nil

CinematicCam.chunkedDialogueData = {
    originalText = "",
    chunks = {},           -- Short chunks for timing
    displayChunks = {},    -- Long chunks for display
    currentChunkIndex = 0, -- Index for timing chunks
    currentDisplayChunkIndex = 0,
    isActive = false,
    customControl = nil,
    displayTimer = nil,
    backgroundControl = nil,
    playerOptionsBackgroundControl = nil,
    sourceElement = nil,
    rawDialogueText = "",
    playerOptionsHidden = false,
    originalPlayerOptionsVisibility = {}
}

function CinematicCam:InitializeChunkedTextControl()
    local control = _G["CinematicCam_ChunkedText"] -- XML element

    if not control then
        control = CreateControl("CinematicCam_ChunkedDialogue", GuiRoot, CT_LABEL)

        if not control then
            return nil
        end
    end

    CinematicCam:InitializeChunkedTextBG()

    -- visibility settings
    local color = self.savedVars.interaction.subtitles.textColor or { r = 0.9, g = 0.9, b = 0.8, a = 1.0 }
    control:SetColor(color.r, color.g, color.b, color.a)
    if self.savedVars.interaction.subtitles.isHidden == true then
        control:SetAlpha(0)
    elseif self.savedVars.interaction.subtitles.isHidden == false then
        control:SetAlpha(1.0)
    end


    -- Text properties
    control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    control:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- DIRECT FONT SETTING
    local fontString = CinematicCam:BuildUserFontString()
    control:SetFont(fontString)

    -- Start hidden
    control:SetHidden(true)
    control:SetText("")

    -- Store reference
    CinematicCam.chunkedDialogueData.customControl = control
    CinematicCam:InitializeChunkedTextBG()

    -- Set the correct active background
    CinematicCam:SetActiveBackgroundControl()
    return control
end

---=============================================================================
-- MAIN DIALOGUE INTERCEPTION AND PROCESSING
--=============================================================================

function CinematicCam:InterceptDialogueForChunking(dialogType)
    local dialogTypeForEmote = dialogType
    if self.savedVars.interaction.autoEmotes then
        local emote = self:determineAutoEmote(dialogTypeForEmote)

        if emote then
            zo_callLater(function()
                DoCommand(emote)
            end, 300)
        end
    end


    local originalText, sourceElement = self:GetDialogueText()


    -- Check voice over status
    local voStatus = self:CheckVoiceOverStatus()

    -- Show player options immediately if VO can be replayed
    if voStatus.shouldShowOptionsImmediately or

        self:CheckPlayerOptionsForVendorText() or
        self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk == false then
        CinematicCam.PlayerOptionsAlways = true
        CinematicCam:OnPlayerOptionsSettingChanged(false, true)
    else
        CinematicCam.PlayerOptionsAlways = false
        CinematicCam:OnPlayerOptionsSettingChanged(true, false)
    end
    if not originalText or string.len(originalText) == 0 then
        return false
    end

    -- Apply NPC name preset
    self:ApplyNPCNamePreset()

    -- Prepare text versions
    local textForTiming = originalText
    local processedTextForDisplay = originalText

    -- Store dialogue data
    CinematicCam.chunkedDialogueData.originalText = processedTextForDisplay
    CinematicCam.chunkedDialogueData.sourceElement = sourceElement
    CinematicCam.chunkedDialogueData.rawDialogueText = originalText

    -- Process and display if chunked dialogue is enabled
    if self.savedVars.interaction.subtitles.useChunkedDialogue or
        self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk then
        return self:ProcessAndDisplayChunkedDialogue(textForTiming, processedTextForDisplay)
    end
    return false
end

function CinematicCam:ProcessAndDisplayChunkedDialogue(textForTiming, processedTextForDisplay)
    -- Process text into chunks
    CinematicCam.chunkedDialogueData.chunks = self:ProcessTextIntoChunks(textForTiming)
    CinematicCam.chunkedDialogueData.displayChunks = self:ProcessTextIntoDisplayChunks(processedTextForDisplay)

    if #CinematicCam.chunkedDialogueData.chunks >= 1 then
        self:StartDialogueChangeMonitoring()

        if self.savedVars.interaction.layoutPreset == "default" then
            return self:InitializeHiddenChunkedDisplay()
        else
            return self:InitializeChunkedDisplay()
        end
    else
        -- Fallback to single chunk
        CinematicCam.chunkedDialogueData.chunks = { textForTiming }
        CinematicCam.chunkedDialogueData.displayChunks = { processedTextForDisplay }
        self:StartDialogueChangeMonitoring()
        if self.savedVars.interaction.layoutPreset == "default" then
            return self:InitializeHiddenCompleteTextDisplay()
        else
            return self:InitializeCompleteTextDisplay()
        end
    end
end

function CinematicCam:UpdateDisplayChunkIndex()
    local timingChunks = CinematicCam.chunkedDialogueData.chunks
    local displayChunks = CinematicCam.chunkedDialogueData.displayChunks
    local currentTimingIndex = CinematicCam.chunkedDialogueData.currentChunkIndex

    if not timingChunks or not displayChunks or #displayChunks == 0 then
        return
    end

    -- If we only have one display chunk, always show it
    if #displayChunks == 1 then
        CinematicCam.chunkedDialogueData.currentDisplayChunkIndex = 1
        return
    end

    -- Calculate which display chunk should be shown based on timing progress
    -- This maps the timing chunk index to the appropriate display chunk
    local timingProgress = currentTimingIndex / #timingChunks
    local displayChunkIndex = math.ceil(timingProgress * #displayChunks)

    -- Clamp to valid range
    displayChunkIndex = math.max(1, math.min(displayChunkIndex, #displayChunks))

    CinematicCam.chunkedDialogueData.currentDisplayChunkIndex = displayChunkIndex
end

function CinematicCam:InitializeHiddenChunkedDisplay()
    if #CinematicCam.chunkedDialogueData.chunks == 0 then
        return false
    end

    if self:ShouldHidePlayerOptionsForInteraction() and
        #CinematicCam.chunkedDialogueData.chunks > 1 and
        CinematicCam.PlayerOptionsAlways == false then
        self:HidePlayerOptionsUntilLastChunk()
    end

    CinematicCam.chunkedDialogueData.currentChunkIndex = 1
    CinematicCam.chunkedDialogueData.currentDisplayChunkIndex = 1 -- Initialize display index
    CinematicCam.chunkedDialogueData.isActive = true

    if #CinematicCam.chunkedDialogueData.chunks > 1 then
        self:ScheduleNextChunk()
    else
        if CinematicCam.chunkedDialogueData.playerOptionsHidden then
            self:ShowPlayerOptionsOnLastChunk()
        end
    end

    return true
end

function CinematicCam:InitializeHiddenCompleteTextDisplay()
    if CinematicCam.chunkedDialogueData.playerOptionsHidden then
        self:ShowPlayerOptionsOnLastChunk()
    end

    CinematicCam.chunkedDialogueData.currentChunkIndex = 1
    CinematicCam.chunkedDialogueData.isActive = true

    return true
end

---=============================================================================
-- TEXT PROCESSING AND CHUNKING
--=============================================================================
function CinematicCam:ProcessTextIntoChunks(fullText)
    if not fullText or fullText == "" then
        return {}
    end

    local chunks = {}
    local delimiters = self.savedVars.chunkedDialog.chunkDelimiters
    local minLength = self.savedVars.chunkedDialog.chunkMinLength
    local maxLength = self.savedVars.chunkedDialog.chunkMaxLength

    local processedText = self:PreprocessTextForChunking(fullText)

    -- Keep short chunks for timing (player options timing)
    chunks = self:SplitTextIntoChunks(processedText, delimiters, minLength, maxLength)


    return chunks
end

function CinematicCam:ProcessTextIntoDisplayChunks(fullText)
    if not fullText or fullText == "" then
        return {}
    end

    local delimiters = self.savedVars.chunkedDialog.chunkDelimiters
    local minLength = self.savedVars.chunkedDialog.chunkMinLength
    local maxLength = self.savedVars.chunkedDialog.chunkMaxLength

    local processedText = self:PreprocessTextForChunking(fullText)
    local chunks = self:SplitTextIntoChunks(processedText, delimiters, minLength, maxLength)

    -- Combine into longer chunks for display (multi-sentence display)
    return self:CombineShortChunks(chunks, minLength)
end

function CinematicCam:CombineShortChunks(chunks, minLength)
    if not chunks or #chunks == 0 then
        return {}
    end

    local combined = {}
    local currentCombined = ""
    local sentenceCount = 0
    local minSentences = 1              -- Minimum sentences per chunk
    local idealLength = minLength * 2.5 -- Target length for combined chunks

    for i, chunk in ipairs(chunks) do
        local trimmedChunk = self:TrimString(chunk)

        if currentCombined == "" then
            currentCombined = trimmedChunk
            sentenceCount = 1
        else
            -- Add space between sentences
            currentCombined = currentCombined .. " " .. trimmedChunk
            sentenceCount = sentenceCount + 1
        end

        local isLastChunk = (i == #chunks)
        local hasMinSentences = sentenceCount >= minSentences
        local isLongEnough = string.len(currentCombined) >= idealLength
        local wouldBeTooLong = false

        -- Check if adding the next chunk would exceed maxLength
        if not isLastChunk and i < #chunks then
            local nextChunk = self:TrimString(chunks[i + 1])
            local potentialLength = string.len(currentCombined) + string.len(nextChunk) + 1
            wouldBeTooLong = potentialLength > self.savedVars.chunkedDialog.chunkMaxLength
        end

        -- Decide whether to finalize this chunk
        local shouldFinalize = false

        if isLastChunk then
            -- Always add the last chunk
            shouldFinalize = true
        elseif hasMinSentences and (isLongEnough or wouldBeTooLong) then
            -- We have enough sentences and either reached ideal length or next would be too long
            shouldFinalize = true
        end

        if shouldFinalize then
            table.insert(combined, currentCombined)
            currentCombined = ""
            sentenceCount = 0
        end
    end

    -- Add any remaining text (shouldn't normally happen, but safety check)
    if currentCombined ~= "" then
        table.insert(combined, currentCombined)
    end

    return combined
end

function CinematicCam:SplitTextIntoChunks(processedText, delimiters, minLength, maxLength)
    local chunks = {}
    local currentChunk = ""
    local i = 1

    while i <= #processedText do
        local char = processedText:sub(i, i)
        currentChunk = currentChunk .. char

        local foundDelimiter = false
        for _, delimiter in ipairs(delimiters) do
            if char == delimiter then
                if self:IsValidChunkBoundary(processedText, i, currentChunk, minLength) then
                    local trimmedChunk = self:TrimString(currentChunk)
                    if string.len(trimmedChunk) >= minLength then
                        table.insert(chunks, trimmedChunk)
                        currentChunk = ""
                        foundDelimiter = true
                        break
                    end
                end
            end
        end

        if not foundDelimiter and string.len(currentChunk) >= maxLength then
            local breakPoint = self:FindWordBoundary(currentChunk, maxLength)
            if breakPoint > minLength then
                table.insert(chunks, self:TrimString(currentChunk:sub(1, breakPoint)))
                currentChunk = currentChunk:sub(breakPoint + 1)
            end
        end

        i = i + 1
    end

    -- Add final chunk if any text remains
    local finalChunk = self:TrimString(currentChunk)
    if string.len(finalChunk) > 0 then
        table.insert(chunks, finalChunk)
    end

    return chunks
end

function CinematicCam:PreprocessTextForChunking(text)
    local abbreviations = {
        "Mr%.", "Mrs%.", "Ms%.", "Dr%.", "Prof%.",
        "U%.S%.A%.", "etc%.", "vs%.", "e%.g%.", "i%.e%."
    }

    local processed = text
    for _, abbrev in ipairs(abbreviations) do
        processed = string.gsub(processed, abbrev, function(match)
            return string.gsub(match, "%.", "§ABBREV§")
        end)
    end

    return processed
end

---=============================================================================
-- DISPLAY AND RENDERING
--=============================================================================

function CinematicCam:DisplayCurrentChunk()
    local control = CinematicCam.chunkedDialogueData.customControl
    local background = CinematicCam.chunkedDialogueData.backgroundControl
    local displayChunkIndex = CinematicCam.chunkedDialogueData.currentDisplayChunkIndex

    if self.savedVars.interaction.layoutPreset == "default" then
        -- Just handle the timing logic, no visual display
        return
    end

    if not control then
        return
    end

    -- Check if we have display chunks
    local displayChunks = CinematicCam.chunkedDialogueData.displayChunks
    if not displayChunks or #displayChunks == 0 then
        return
    end

    -- Make sure we have a valid display chunk index
    if displayChunkIndex < 1 or displayChunkIndex > #displayChunks then
        return
    end

    -- Get chunk text from display chunks
    local chunkText = displayChunks[displayChunkIndex]

    if not chunkText then
        return
    end

    -- Process text and apply formatting
    chunkText = string.gsub(chunkText, "§ABBREV§", ".")

    -- Add NPC name to each chunk if using prepended preset
    chunkText = self:HandleNPCName(chunkText, CinematicCam.npcNameData.originalName, self.savedVars.npcNamePreset)

    local fontString = self:BuildUserFontString()
    local color = self.savedVars.interaction.subtitles.textColor or { r = 0.9, g = 0.9, b = 0.8, a = 1.0 }
    control:SetColor(color.r, color.g, color.b, color.a)
    control:SetFont(fontString)
    control:SetText(chunkText)

    -- Check if we should display based on interaction type
    if self:ShouldHideForInteractionType() then
        self:HideChunkDisplay(control, background)
        return
    end

    -- Show text control
    control:SetHidden(false)

    -- Handle background
    self:UpdateChunkBackground(control, background)

    -- Update overall visibility
    self:UpdateChunkedTextVisibility()
end

function CinematicCam:ShouldHidePlayerOptionsForInteraction()
    if not self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk then
        return false
    end

    local interactionType = GetInteractionType()

    return interactionType == INTERACTION_CONVERSATION or interactionType == INTERACTION_QUEST
end

function CinematicCam:ShouldHideForInteractionType()
    local interactionType = GetInteractionType()
    local hideTypes = {
        INTERACTION_DYE_STATION,
        INTERACTION_CRAFT,
        INTERACTION_NONE,
        INTERACTION_LOCKPICK,
        INTERACTION_BOOK
    }

    for _, hideType in ipairs(hideTypes) do
        if interactionType == hideType then
            return true
        end
    end

    return false
end

function CinematicCam:HideChunkDisplay(control, background)
    control:SetText("")
    control:SetHidden(true)
    if background then
        background:SetHidden(true)
    end
end

function CinematicCam:UpdateChunkBackground(control, background)
    if background and self:ShouldShowSubtitleBackground() then
        -- Apply color based on current mode EVERY TIME the background is shown
        local backgroundMode = self.savedVars.interface.cinematicBackgroundMode or "subtitles"
        if backgroundMode == "dark" then
            background:SetTexture("/esoui/art/miscellaneous/listitem_divider.dds")
            background:SetColor(0, 0, 0, .6)
        elseif backgroundMode == "kingdom" then
            background:SetColor(1, 1, 1, 1.0) -- Normal appearance
            background:SetTexture("/esoui/art/tribute/tributecardnamebanner.dds")
        elseif backgroundMode == "redemption_banner" then
            background:SetTexture("/esoui/art/miscellaneous/listitem_divider.dds")

            background:SetColor(0, 0, 0, .6)
        end

        -- Calculate dynamic dimensions
        local textWidth = control:GetTextWidth()
        local textHeight = control:GetTextHeight()

        local padding = 16
        local backgroundWidth = textWidth + (padding)
        local backgroundHeight = textHeight + (padding)

        -- Apply size constraints
        local minWidth, maxWidth = 100, 2000
        local minHeight, maxHeight = 60, 550

        backgroundWidth = math.max(minWidth, math.min(maxWidth, backgroundWidth))
        backgroundHeight = math.max(minHeight, math.min(maxHeight, backgroundHeight))

        local backgroundMode = self.savedVars.interface.cinematicBackgroundMode or "subtitles"
        if backgroundMode == "kingdom" then
            backgroundHeight = math.max(100, backgroundHeight) -- Minimum height for banner
            backgroundWidth = math.max(100, backgroundWidth)   -- Minimum width for banner to display properly
            backgroundWidth = backgroundWidth + 280
            backgroundHeight = backgroundHeight + 40
        elseif backgroundMode == "redemption_banner" then
            backgroundHeight = math.max(100, backgroundHeight) -- Minimum height for banner
            backgroundWidth = math.max(100, backgroundWidth)   -- Minimum width for banner to display properly
            backgroundWidth = backgroundWidth + 400
            backgroundHeight = backgroundHeight + 350
        end

        -- Position and show background
        background:SetDimensions(backgroundWidth, backgroundHeight)

        local targetX, targetY = self:ConvertToScreenCoordinates(
            self.savedVars.interaction.subtitles.posX or 0.5,
            self.savedVars.interaction.subtitles.posY or 0.7
        )

        -- Move backgrounds down a few pixels
        if backgroundMode == "kingdom" then
            targetY = targetY + 38
        elseif backgroundMode == "redemption_banner" then
            targetY = targetY + 100
        end

        background:ClearAnchors()
        background:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
        background:SetHidden(false)
    elseif background then
        background:SetHidden(true)
    end
end

function CinematicCam:ApplySubtitleTextColor()
    local control = CinematicCam.chunkedDialogueData.customControl
    if control then
        local color = self.savedVars.interaction.subtitles.textColor or { r = 0.9, g = 0.9, b = 0.8, a = 1.0 }
        control:SetColor(color.r, color.g, color.b, color.a)
    end
end

---=============================================================================
-- HIDE PLAYER OPTIONS
--=============================================================================
function CinematicCam:OnPlayerOptionsSettingChanged(newValue, isVendor)
    if isVendor then
        return
    end
    -- "hide until dialogue finishes" setting is ON
    if CinematicCam.chunkedDialogueData.isActive then
        if newValue then
            local currentChunk = CinematicCam.chunkedDialogueData.currentChunkIndex
            local totalChunks = #CinematicCam.chunkedDialogueData.chunks

            if totalChunks > 1 and currentChunk < totalChunks then
                self:HidePlayerOptionsUntilLastChunk()
            end
        else
            -- show player options
            if CinematicCam.chunkedDialogueData.playerOptionsHidden then
                self:ShowPlayerOptionsOnLastChunk()
            end
        end
    end
end

function CinematicCam:HidePlayerOptionsUntilLastChunk()
    if CinematicCam.chunkedDialogueData.playerOptionsHidden then
        return
    end

    local playerOptionElements = {
        "ZO_InteractWindowPlayerAreaOptions",
        "ZO_InteractWindow_GamepadContainerInteractList",
        "ZO_InteractWindow_GamepadContainerInteract",
        "ZO_InteractWindowPlayerAreaHighlight"
    }

    -- Store original visibility and hide elements
    for _, elementName in ipairs(playerOptionElements) do
        local element = _G[elementName]
        if element then
            -- Store original visibility state in chunkedDialogueData table
            CinematicCam.chunkedDialogueData.originalPlayerOptionsVisibility[elementName] = not element:IsHidden()
            element:SetHidden(true)
        end
    end

    CinematicCam.chunkedDialogueData.playerOptionsHidden = true
end

function CinematicCam:ShowPlayerOptionsOnLastChunk()
    if not CinematicCam.chunkedDialogueData.playerOptionsHidden then
        return
    end

    -- Show player options
    for elementName, wasVisible in pairs(CinematicCam.chunkedDialogueData.originalPlayerOptionsVisibility) do
        local element = _G[elementName]
        if element and wasVisible then
            element:SetAlpha(0)
            element:SetHidden(false)

            -- fade-in animation
            local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", element)
            local animation = timeline:GetFirstAnimation()

            if animation then
                animation:SetAlphaValues(0, 1)
                animation:SetDuration(400) -- 400ms fade-in
                animation:SetEasingFunction(ZO_EaseInQuadratic)
            end

            timeline:PlayFromStart()
        end
    end

    CinematicCam.chunkedDialogueData.playerOptionsHidden = false
    CinematicCam.chunkedDialogueData.originalPlayerOptionsVisibility = {}
end

---=============================================================================
-- POSITIONING AND LAYOUT
--=============================================================================

function CinematicCam:PositionChunkedTextControl(control)
    local preset = self.savedVars.interaction.layoutPreset

    if preset == "default" then
        self:PositionForDefaultPreset(control)
    elseif preset == "cinematic" then
        self:PositionForCinematicPreset(control)
    end
end

function CinematicCam:PositionForDefaultPreset(control)
    if CinematicCam.chunkedDialogueData.sourceElement then
        control:ClearAnchors()
        control:SetAnchor(CENTER, CinematicCam.chunkedDialogueData.sourceElement, CENTER, 0, -100)
        control:SetDimensions(CinematicCam.chunkedDialogueData.sourceElement:GetDimensions())
    end
end

function CinematicCam:PositionForCinematicPreset(control)
    local safeWidth, safeHeight, screenWidth, screenHeight = self:GetSafeScreenDimensions()

    local targetX, targetY = self:ConvertToScreenCoordinates(
        self.savedVars.interaction.subtitles.posX or 0.5,
        self.savedVars.interaction.subtitles.posY or 0.7
    )

    control:ClearAnchors()
    control:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
    control:SetDimensions(safeWidth, math.min(safeHeight * 0.3, 200))
end

---=============================================================================
-- TIMING AND SCHEDULING
--=============================================================================
function CinematicCam:CleanTextForTiming(text)
    if not text then return "" end

    -- Remove abbreviation markers
    local cleaned = string.gsub(text, "§ABBREV§", ".")

    -- Remove extra whitespace
    cleaned = string.gsub(cleaned, "%s+", " ")
    cleaned = self:TrimString(cleaned)

    return cleaned
end

function CinematicCam:TrimString(str)
    if not str or type(str) ~= "string" then
        return ""
    end
    local trimmed = string.gsub(str, "^%s*", "")
    trimmed = string.gsub(trimmed, "%s*$", "")
    return trimmed
end

function CinematicCam:IsValidChunkBoundary(text, position, currentChunk, minLength)
    if string.len(currentChunk) < minLength then
        return false
    end

    local nextChar = text:sub(position + 1, position + 1)
    if nextChar == " " or nextChar == "\n" or nextChar == "\t" or nextChar == "" then
        return true
    end

    if string.match(nextChar, "%w") then
        return false
    end

    return true
end

function CinematicCam:FindWordBoundary(text, maxPosition)
    for i = maxPosition, 1, -1 do
        if text:sub(i, i) == " " then
            return i - 1
        end
    end
    return maxPosition
end

function CinematicCam:ScheduleNextChunk()
    if CinematicCam.chunkedDialogueData.displayTimer then
        zo_removeCallLater(CinematicCam.chunkedDialogueData.displayTimer)
    end

    -- Calculate timing for current DISPLAY chunk
    local displayTime = self:CalculateDisplayChunkTiming()

    -- Convert to milliseconds and schedule
    local displayTimeMs = displayTime * 1000

    CinematicCam.chunkedDialogueData.displayTimer = zo_callLater(function()
        self:AdvanceToNextChunk()
    end, displayTimeMs)
end

function CinematicCam:CalculateDisplayChunkTiming()
    local displayChunks = CinematicCam.chunkedDialogueData.displayChunks
    local currentDisplayIndex = CinematicCam.chunkedDialogueData.currentDisplayChunkIndex

    if not displayChunks or #displayChunks == 0 then
        return self.savedVars.chunkedDialog.baseDisplayTime or 3.0
    end

    -- Get the current display chunk text
    local displayChunk = displayChunks[currentDisplayIndex]
    if not displayChunk then
        return self.savedVars.chunkedDialog.baseDisplayTime or 3.0
    end

    -- Calculate timing
    local cleanText = self:CleanTextForTiming(displayChunk)
    local textLength = string.len(cleanText)

    -- Base calculation
    local baseTime = 0.4
    local timePerChar = 0.06
    local displayTime = baseTime + (textLength * timePerChar)

    -- Add punctuation timing if enabled
    if self.savedVars.chunkedDialog.timingMode ~= "fixed" and self.savedVars.chunkedDialog.usePunctuationTiming then
        local punctuationTime = self:CalculatePunctuationTime(cleanText)
        displayTime = displayTime + punctuationTime
    end

    -- Apply min/max constraints
    if self.savedVars.chunkedDialog.timingMode ~= "fixed" then
        local minTime = self.savedVars.chunkedDialog.minDisplayTime or 1.5
        local maxTime = self.savedVars.chunkedDialog.maxDisplayTime or 8.0
        displayTime = math.max(minTime, displayTime)
        displayTime = math.min(maxTime, displayTime)
    end

    return displayTime
end

function CinematicCam:AdvanceToNextChunk()
    -- Advance to next chunk
    CinematicCam.chunkedDialogueData.currentDisplayChunkIndex = CinematicCam.chunkedDialogueData
        .currentDisplayChunkIndex + 1

    -- Update timing chunk index to the END of this display chunk
    self:UpdateTimingChunkIndex()

    local displayChunks = CinematicCam.chunkedDialogueData.displayChunks
    local timingChunks = CinematicCam.chunkedDialogueData.chunks

    -- Check if finished
    local allTimingChunksComplete = CinematicCam.chunkedDialogueData.currentChunkIndex >= #timingChunks

    -- Show player options when ALL timing chunks are done
    if allTimingChunksComplete and CinematicCam.chunkedDialogueData.playerOptionsHidden then
        self:ShowPlayerOptionsOnLastChunk()
    end

    if CinematicCam.chunkedDialogueData.currentDisplayChunkIndex <= #displayChunks then
        -- Display the current display chunk
        self:DisplayCurrentChunk()

        -- Schedule next chunk if applicable
        local hasMoreDisplayChunks = CinematicCam.chunkedDialogueData.currentDisplayChunkIndex < #displayChunks

        if self.savedVars.interaction.subtitles.useChunkedDialogue and
            #displayChunks > 1 and
            hasMoreDisplayChunks then
            self:ScheduleNextChunk()
        end
    end
end

function CinematicCam:UpdateTimingChunkIndex()
    local timingChunks = CinematicCam.chunkedDialogueData.chunks
    local displayChunks = CinematicCam.chunkedDialogueData.displayChunks
    local currentDisplayIndex = CinematicCam.chunkedDialogueData.currentDisplayChunkIndex

    if not timingChunks or not displayChunks or #displayChunks == 0 then
        return
    end

    -- If we're on the last display chunk, set timing to the last timing chunk
    if currentDisplayIndex >= #displayChunks then
        CinematicCam.chunkedDialogueData.currentChunkIndex = #timingChunks
        return
    end

    -- Calculate which timing chunk we should be at based on display progress
    -- This represents how many timing chunks have been "consumed" by display chunks shown
    local displayProgress = currentDisplayIndex / #displayChunks
    local timingChunkIndex = math.ceil(displayProgress * #timingChunks)

    -- Clamp to valid range
    timingChunkIndex = math.max(1, math.min(timingChunkIndex, #timingChunks))

    CinematicCam.chunkedDialogueData.currentChunkIndex = timingChunkIndex
end

function CinematicCam:CalculatePunctuationTime(text)
    if not text or not self.savedVars.chunkedDialog.usePunctuationTiming then
        return 0
    end

    local totalPunctuationTime = 0
    local punctuationCounts = {
        ["-"] = 0,
        ["—"] = 0,
        ["–"] = 0,
        [","] = 0,
        [";"] = 0,
        [":"] = 0,
        ["."] = 0
    }

    -- Count punctuation marks
    for i = 1, #text do
        local char = text:sub(i, i)
        if punctuationCounts[char] ~= nil then
            punctuationCounts[char] = punctuationCounts[char] + 1
        end
    end

    -- Count ellipsis
    local ellipsisCount = 0
    ellipsisCount = ellipsisCount + select(2, string.gsub(text, "%.%.%.", "")) -- Three dots
    ellipsisCount = ellipsisCount + select(2, string.gsub(text, "…", "")) -- Unicode ellipsis

    -- Calculate timing
    totalPunctuationTime = totalPunctuationTime + (punctuationCounts["-"] * 0.3)
    totalPunctuationTime = totalPunctuationTime + (punctuationCounts["—"] * 0.4)
    totalPunctuationTime = totalPunctuationTime + (punctuationCounts["–"] * 0.4)
    totalPunctuationTime = totalPunctuationTime + (punctuationCounts[","] * 0.7)
    totalPunctuationTime = totalPunctuationTime + (punctuationCounts[";"] * 0.25)
    totalPunctuationTime = totalPunctuationTime + (punctuationCounts[":"] * 0.3)
    totalPunctuationTime = totalPunctuationTime + (punctuationCounts["."] * 0.3)
    totalPunctuationTime = totalPunctuationTime +
        (ellipsisCount * (self.savedVars.chunkedDialog.ellipsisPauseTime or 0.5))

    return totalPunctuationTime
end

---=============================================================================
-- MONITORING AND CLEANUP
--=============================================================================

function CinematicCam:StartDialogueChangeMonitoring()
    -- Cancel any existing monitoring
    if dialogueChangeCheckTimer then
        zo_removeCallLater(dialogueChangeCheckTimer)
        dialogueChangeCheckTimer = nil
    end

    local function checkForDialogueChange()
        if not CinematicCam.chunkedDialogueData.isActive then
            dialogueChangeCheckTimer = nil
            return
        end

        -- Check Voice Over status and show options if VO finished
        local voStatus = self:CheckVoiceOverStatus()

        if voStatus.canReplay and not voStatus.isPlaying and CinematicCam.chunkedDialogueData.playerOptionsHidden then
            self:ShowPlayerOptionsOnLastChunk()
        end

        local currentRawText, _ = self:GetDialogueText()
        if currentRawText and currentRawText ~= CinematicCam.chunkedDialogueData.rawDialogueText then
            if string.len(currentRawText) > 10 then
                self:InterceptDialogueForChunking("ConversationUpdate")
            end
        end

        -- Check for interaction end
        local interactionType = GetInteractionType()
        if interactionType == INTERACTION_ANTIQUITY_DIG_SPOT or interactionType == INTERACTION_NONE then
            self:CleanupChunkedDialogue()
            return
        end



        -- Polling function to check for dialogue changes
        dialogueChangeCheckTimer = zo_callLater(function()
            checkForDialogueChange()
        end, 2000)
    end
    checkForDialogueChange()
end

function CinematicCam:CleanupChunkedDialogue()
    -- Cancel timers
    if CinematicCam.chunkedDialogueData.displayTimer then
        zo_removeCallLater(CinematicCam.chunkedDialogueData.displayTimer)
        CinematicCam.chunkedDialogueData.displayTimer = nil
    end

    if dialogueChangeCheckTimer then
        zo_removeCallLater(dialogueChangeCheckTimer)
        dialogueChangeCheckTimer = nil
    end

    -- Restore player options if they were hidden
    if CinematicCam.chunkedDialogueData.playerOptionsHidden then
        self:ShowPlayerOptionsOnLastChunk()
    end

    -- Hide all controls
    self:HideAllChunkedControls()

    -- Reset state
    self:ResetChunkedDialogueState()
end

--[[ESO Update 47 introduced new API functions for tracking voice over completion
and replaying dialogue. The previous timing system could sometimes cause player response options to
appear long after the NPC finished speaking.

This implementation hooks into the new voice completion tracking to ensure
player responses display at the latest when the voice over
ends or slightly early if the internal timing system triggers first.]]
function CinematicCam:CheckVoiceOverStatus()
    local canReplay = CanReplayLastInteractVO()
    local isPlaying = IsInteractVOPlaying()


    return {
        canReplay = canReplay,
        isPlaying = isPlaying,
        shouldShowOptionsImmediately = canReplay and not isPlaying
    }
end

function CinematicCam:HideAllChunkedControls()
    if CinematicCam.chunkedDialogueData.customControl then
        CinematicCam.chunkedDialogueData.customControl:SetHidden(true)
        CinematicCam.chunkedDialogueData.customControl:SetText("")
    end

    if CinematicCam.chunkedDialogueData.backgroundControl then
        CinematicCam.chunkedDialogueData.backgroundControl:SetHidden(true)
    end

    if CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl then
        CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl:SetHidden(true)
    end

    if CinematicCam.npcNameData.customNameControl then
        CinematicCam.npcNameData.customNameControl:SetHidden(true)
        CinematicCam.npcNameData.customNameControl:SetText("")
    end
end

function CinematicCam:ResetChunkedDialogueState()
    -- Restore player options
    if CinematicCam.chunkedDialogueData.playerOptionsHidden then
        self:ShowPlayerOptionsOnLastChunk()
    end

    -- Cancel any active timers
    if CinematicCam.chunkedDialogueData.displayTimer then
        zo_removeCallLater(CinematicCam.chunkedDialogueData.displayTimer)
    end

    if dialogueChangeCheckTimer then
        zo_removeCallLater(dialogueChangeCheckTimer)
        dialogueChangeCheckTimer = nil
    end

    -- Hide all controls
    self:HideAllChunkedControls()

    -- Preserve control references
    local backgroundControl = CinematicCam.chunkedDialogueData.backgroundControl
    local playerOptionsBackgroundControl = CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl
    local customControl = CinematicCam.chunkedDialogueData.customControl

    -- Reset state variables
    CinematicCam.chunkedDialogueData = {
        originalText = "",
        chunks = {},
        displayChunks = {},
        currentChunkIndex = 0,
        currentDisplayChunkIndex = 0,
        isActive = false,
        customControl = customControl,
        backgroundControl = backgroundControl,
        playerOptionsBackgroundControl = playerOptionsBackgroundControl,
        displayTimer = nil,
        sourceElement = nil,
        rawDialogueText = "",
        playerOptionsHidden = false,
        originalPlayerOptionsVisibility = {}
    }

    -- Reset additional related state
    if CinematicCam.npcNameData then
        CinematicCam.npcNameData.originalName = ""
        CinematicCam.npcNameData.currentPreset = "default"
    end

    -- Reset any vendor-related flags
    CinematicCam.PlayerOptionsAlways = false
end

---=============================================================================
-- INITIALIZATION AND SETUP
--=============================================================================

function CinematicCam:CreateChunkedTextControl()
    if CinematicCam.chunkedDialogueData.customControl then
        return CinematicCam.chunkedDialogueData.customControl
    end

    local control = CreateControl("CinematicCam_ChunkedDialogue", GuiRoot, CT_LABEL)

    -- Apply font styling
    self:ApplyFontToElement(control, self.savedVars.interface.customFontSize)

    -- Text properties
    control:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    control:SetVerticalAlignment(TEXT_ALIGN_TOP)
    control:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    -- Apply user-defined color instead of hardcoded color
    local color = self.savedVars.interaction.subtitles.textColor or { r = 0.9, g = 0.9, b = 0.8, a = 1.0 }
    control:SetColor(color.r, color.g, color.b, color.a)

    -- Initial state
    control:SetHidden(true)

    -- Position the control
    self:PositionChunkedTextControl(control)

    -- Store reference
    CinematicCam.chunkedDialogueData.customControl = control

    -- Initialize background
    self:InitializeChunkedTextBG()

    return control
end

function CinematicCam:InitializeChunkedDisplay()
    if #CinematicCam.chunkedDialogueData.chunks == 0 then
        return false
    end

    -- Hide source element
    if CinematicCam.chunkedDialogueData.sourceElement then
        CinematicCam.chunkedDialogueData.sourceElement:SetHidden(true)
    end

    -- Hide player options ONLY for dialogue interactions and if we have multiple chunks
    if self:ShouldHidePlayerOptionsForInteraction() and
        #CinematicCam.chunkedDialogueData.chunks > 1 and
        CinematicCam.PlayerOptionsAlways == false then
        self:HidePlayerOptionsUntilLastChunk()
    end

    -- Ensure control exists
    if not CinematicCam.chunkedDialogueData.customControl then
        self:InitializeChunkedTextControl()
    end

    local control = CinematicCam.chunkedDialogueData.customControl
    if not control then
        return false
    end

    -- Setup display
    self:ApplyChunkedTextPositioning()

    CinematicCam.chunkedDialogueData.currentChunkIndex = 1
    CinematicCam.chunkedDialogueData.currentDisplayChunkIndex = 1 -- Initialize display index
    CinematicCam.chunkedDialogueData.isActive = true

    -- Display first chunk
    self:DisplayCurrentChunk()

    -- Schedule next chunk if multiple chunks exist
    if #CinematicCam.chunkedDialogueData.chunks > 1 then
        self:ScheduleNextChunk()
    end

    return true
end

function CinematicCam:InitializeChunkedTextBG()
    local backgroundNormal = _G["CinematicCam_ChunkedTextBackground"]
    local backgroundKingdom = _G["CinematicCam_ChunkedTextBackground_Kingdom"]

    -- Configure kingdom background
    if backgroundKingdom then
        backgroundKingdom:SetHidden(true)
        backgroundKingdom:ClearAnchors()
        backgroundKingdom:SetTexture("/esoui/art/tribute/tributecardnamebanner.dds")
        backgroundKingdom:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)

        backgroundKingdom:SetDimensions(1, 1)
    end

    self:SetActiveBackgroundControl()
end

function CinematicCam:ConfigurePlayerOptionsBackground()
    local background = _G["CinematicCam_PlayerOptionsBackground"]
    if background then
        -- Background properties
        background:SetColor(0.2, 0.2, 0.2, 0.7)

        background:SetHidden(true)

        -- Store reference
        CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl = background

        -- Initialize position
        background:ClearAnchors()
        background:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        background:SetDimensions(1, 1)
    end
end

---=============================================================================
-- Player Response Options
--=============================================================================
function CinematicCam:ShowPlayerResponse()
    local playerOptionElements = {
        "ZO_InteractWindowPlayerAreaOptions",
        "ZO_InteractWindow_GamepadContainerInteractList",
        "ZO_InteractWindow_GamepadContainerInteract",
        "ZO_InteractWindowPlayerAreaHighlight"
    }

    for _, elementName in ipairs(playerOptionElements) do
        local element = _G[elementName]
        if element then
            element:SetHidden(false)
        end
    end
end

function CinematicCam:FindPlayerOptionTextElement(option)
    if option.text and option.text.GetText then
        return option.text
    elseif option.label and option.label.GetText then
        return option.label
    elseif option.optionText and option.optionText.GetText then
        return option.optionText
    elseif option.GetText then
        return option
    else
        -- Search through children for text elements
        for j = 1, option:GetNumChildren() do
            local child = option:GetChild(j)
            if child and child.GetText then
                local childText = child:GetText()
                if childText and childText ~= "" then
                    return child
                end
            end
        end
    end
    return nil
end

function CinematicCam:IsVendorInteraction()
    local vendorPatterns = { "^[Ss]tore", "^[Bb]uy", "^[Ss]ell", "^[Tt]rade", "Guild Store", "Bank" }

    for i = 1, 10 do
        local longOptionName = "ZO_InteractWindow_GamepadContainerInteractListScrollZO_ChatterOption_Gamepad" .. i
        local option = _G[longOptionName]
        if option then
            local textElement = self:FindPlayerOptionTextElement(option)
            if textElement then
                local optionText = textElement:GetText() or ""
                for _, pattern in ipairs(vendorPatterns) do
                    if optionText and string.find(optionText, pattern) then
                        return true
                    end
                end
            end
        end

        local shortOptionName = "ZO_ChatterOption_Gamepad" .. i
        local option2 = _G[shortOptionName]
        if option2 then
            local textElement = self:FindPlayerOptionTextElement(option2)
            if textElement then
                local optionText = textElement:GetText() or ""
                for _, pattern in ipairs(vendorPatterns) do
                    if optionText and string.find(optionText, pattern) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function CinematicCam:CheckPlayerOptionsForVendorText()
    local vendorPatterns = { "^[Ss]tore", "^[Bb]uy", "^[Ss]ell", "^[Tt]rade", "Bank", "<", "Complete Quest", "Skills:",
        "Morphs:", "Skill Lines", "Companion Menu" }
    local vendorOnly = { "^[Ss]tore", "^[Bb]uy" }
    -- Check individual option elements
    for i = 1, 10 do
        local longOptionName = "ZO_InteractWindow_GamepadContainerInteractListScrollZO_ChatterOption_Gamepad" .. i
        local option = _G[longOptionName]
        if option then
            local textElement = self:FindPlayerOptionTextElement(option)
            if textElement then
                local optionText = textElement:GetText() or ""
                if optionText ~= "" then
                    -- Check if first option is "Goodbye."
                    if i == 1 and optionText == "Goodbye." then
                        return true
                    end
                    for _, pattern in ipairs(vendorPatterns) do
                        if optionText and pattern and string.find(optionText, pattern) then
                            return true
                        end
                    end
                end
            end
        end
        local shortOptionName = "ZO_ChatterOption_Gamepad" .. i
        local option2 = _G[shortOptionName]
        if option2 then
            local textElement = self:FindPlayerOptionTextElement(option2)
            if textElement then
                local optionText = textElement:GetText() or ""
                if optionText ~= "" then
                    -- Check if first option is "Goodbye."
                    -- Show immediately so player can exit whenever they want
                    if i == 1 and optionText == "Goodbye." then
                        return true
                    end
                    for _, pattern in ipairs(vendorPatterns) do
                        if string.find(optionText, pattern) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

---=============================================================================
-- UTILITY FUNCTIONS
--=============================================================================

function CinematicCam:UpdateChunkedTextFont()
    local control = CinematicCam.chunkedDialogueData.customControl
    if control then
        self:ApplyFontToElement(control, self.savedVars.interface.customFontSize)
    end
end

function CinematicCam:UpdateChunkedTextVisibility()
    local control = CinematicCam.chunkedDialogueData.customControl
    local background = CinematicCam.chunkedDialogueData.backgroundControl

    if control then
        if self.savedVars.interaction.subtitles.isHidden then
            control:SetAlpha(0)
            if background then background:SetHidden(true) end
        else
            control:SetAlpha(1.0)
            if background and self.savedVars.interface and self.savedVars.interface.useSubtitleBackground then
                background:SetHidden(false)
            end
        end
    end
end

function CinematicCam:HideChunkedTextBackground()
    if CinematicCam.chunkedDialogueData.backgroundControl then
        CinematicCam.chunkedDialogueData.backgroundControl:SetHidden(true)
    end
end

function CinematicCam:OnChunkedDialogueComplete()
    zo_callLater(function()
        if CinematicCam.chunkedDialogueData.customControl then
            CinematicCam.chunkedDialogueData.customControl:SetHidden(true)
            CinematicCam.chunkedDialogueData.customControl:SetText("")
        end

        if CinematicCam.chunkedDialogueData.sourceElement then
            CinematicCam.chunkedDialogueData.sourceElement:SetHidden(self.savedVars.interaction.subtitles.isHidden)
        end
    end, 2000)
end

---=============================================================================
-- Utility Functions
--=============================================================================

function CinematicCam:ApplyDialogueRepositioning()
    local preset = self.savedVars.interaction.layoutPreset
    if preset and preset.applyFunction then
        preset.applyFunction(self)
    end
end

function CinematicCam:GetDialogueText()
    local sources = {
        ZO_InteractWindow_GamepadContainerText,
        ZO_InteractWindowTargetAreaBodyText
    }
    for _, element in ipairs(sources) do
        if element then
            local text = element.text or element:GetText() or ""
            if string.len(text) > 0 then
                return text, element
            end
        end
    end
    return nil, nil
end

function CinematicCam:GetSafeScreenDimensions()
    local screenWidth, screenHeight = GuiRoot:GetDimensions()

    -- Account for letterbox if active
    local availableHeight = screenHeight
    if self.savedVars.letterbox.letterboxVisible then
        availableHeight = screenHeight - (self.savedVars.letterbox.size * 2)
    end

    -- Leave margins for safety (10% on each side)
    local safeWidth = screenWidth * 0.8
    local safeHeight = availableHeight * 0.8

    return safeWidth, safeHeight, screenWidth, screenHeight
end
