function CinematicCam:InitializeLetterbox()
    -- Hide background on startup to prevent permanent display
    zo_callLater(function()
        CinematicCam:HideChunkedTextBackground()
    end, 100)

    if CinematicCam.savedVars.letterbox.letterboxVisible then
        CinematicCam_Container:SetHidden(false)
        CinematicCam_LetterboxTop:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT)
        CinematicCam_LetterboxTop:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT)
        CinematicCam_LetterboxTop:SetHeight(CinematicCam.savedVars.letterbox.size)
        CinematicCam_LetterboxTop:SetColor(0, 0, 0, CinematicCam.savedVars.letterboxOpacity)

        CinematicCam_LetterboxTop:SetHidden(false)

        CinematicCam_LetterboxBottom:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT)
        CinematicCam_LetterboxBottom:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT)
        CinematicCam_LetterboxBottom:SetHeight(CinematicCam.savedVars.letterbox.size)
        CinematicCam_LetterboxBottom:SetColor(0, 0, 0, CinematicCam.savedVars.letterboxOpacity)

        CinematicCam_LetterboxBottom:SetHidden(false)
    else
        CinematicCam_Container:SetHidden(false)
        CinematicCam_LetterboxTop:SetHidden(true)
        CinematicCam_LetterboxBottom:SetHidden(true)
    end
    zo_callLater(function()
        if CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl then
            CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl:SetHidden(true)
        end
    end, 100)
end

---=============================================================================
-- Manage Letterbox Bars
--=============================================================================
local mountLetterbox = false
function CinematicCam:AutoShowLetterbox(interactionType)
    local interactionTypeMap = (
        interactionType == INTERACTION_CONVERSATION or
        interactionType == INTERACTION_QUEST
    )
    return interactionTypeMap and self.savedVars.interaction.auto.autoLetterboxDialogue
end

function CinematicCam:ShowLetterbox()
    if self.savedVars.letterbox.letterboxVisible or CinematicCam:CheckPlayerOptionsForVendorText() then
        return
    end
    self.savedVars.letterbox.letterboxVisible = true

    -- Don't need to set CinematicCam_Container visibility anymore since letterboxes are separate
    local barHeight = self.savedVars.letterbox.size

    CinematicCam_LetterboxTop:ClearAnchors()
    CinematicCam_LetterboxTop:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, -barHeight)
    CinematicCam_LetterboxTop:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, -barHeight)
    CinematicCam_LetterboxTop:SetHeight(barHeight)

    CinematicCam_LetterboxBottom:ClearAnchors()
    CinematicCam_LetterboxBottom:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 0, barHeight)
    CinematicCam_LetterboxBottom:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, barHeight)
    CinematicCam_LetterboxBottom:SetHeight(barHeight)

    -- Set color and draw properties - REMOVED the SetDrawLayer/SetDrawTier/SetDrawLevel calls
    CinematicCam_LetterboxTop:SetColor(0, 0, 0, self.savedVars.letterbox.opacity)
    CinematicCam_LetterboxBottom:SetColor(0, 0, 0, self.savedVars.letterbox.opacity)

    -- Show bars
    CinematicCam_LetterboxTop:SetHidden(false)
    CinematicCam_LetterboxBottom:SetHidden(false)

    -- Create timeline for animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()

    -- Animate top bar sliding down
    local topAnimation = timeline:InsertAnimation(ANIMATION_TRANSLATE, CinematicCam_LetterboxTop)
    topAnimation:SetTranslateOffsets(0, -barHeight, 0, 0)
    topAnimation:SetDuration(2600)

    -- Animate bottom bar sliding up
    local bottomAnimation = timeline:InsertAnimation(ANIMATION_TRANSLATE, CinematicCam_LetterboxBottom)
    bottomAnimation:SetTranslateOffsets(0, barHeight, 0, 0)
    bottomAnimation:SetDuration(2600)

    timeline:PlayFromStart()


    local interactionType = GetInteractionType()
end

-- Hide letterbox bars
function CinematicCam:HideLetterbox()
    local barHeight = self.savedVars.letterbox.size

    local timeline = ANIMATION_MANAGER:CreateTimeline()

    -- Top bar
    local topAnimation = timeline:InsertAnimation(ANIMATION_TRANSLATE, CinematicCam_LetterboxTop)
    topAnimation:SetTranslateOffsets(0, 0, 0, -barHeight)
    topAnimation:SetDuration(3300)
    topAnimation:SetEasingFunction(ZO_EaseOutCubic)
    -- Bottom bar
    local bottomAnimation = timeline:InsertAnimation(ANIMATION_TRANSLATE, CinematicCam_LetterboxBottom)
    bottomAnimation:SetTranslateOffsets(0, 0, 0, barHeight)
    bottomAnimation:SetDuration(3300)
    bottomAnimation:SetEasingFunction(ZO_EaseOutCubic)

    timeline:SetHandler('OnStop', function()
        CinematicCam_LetterboxTop:SetHidden(true)
        CinematicCam_LetterboxBottom:SetHidden(true)
        CinematicCam_LetterboxTop:ClearAnchors()
        CinematicCam_LetterboxTop:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT)
        CinematicCam_LetterboxTop:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT)
        CinematicCam_LetterboxBottom:ClearAnchors()
        CinematicCam_LetterboxBottom:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT)
        CinematicCam_LetterboxBottom:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT)
        self.savedVars.letterbox.letterboxVisible = false
    end)
    timeline:PlayFromStart()
end

function CinematicCam:ToggleLetterbox()
    if self.savedVars.letterbox.letterboxVisible then
        self.savedVars.letterbox.perma = false
        self:HideLetterbox()
    else
        self.savedVars.letterbox.letterboxVisible = false
        self.savedVars.letterbox.perma = true
        self:ShowLetterbox()
    end
end

---=============================================================================
-- Cinematic Mounting
--=============================================================================
function CinematicCam:OnMountUp()
    if not self.savedVars or not self.savedVars.letterbox then
        return
    end

    if self.savedVars.letterbox.autoLetterboxMount then
        if not self.savedVars.letterbox.letterboxVisible then
            mountLetterbox = true
            -- Apply delay
            local delayMs = self.savedVars.letterbox.mountLetterboxDelay * 1000
            if delayMs > 0 then
                mountLetterboxTimer = zo_callLater(function()
                    if IsMounted() and mountLetterbox then
                        self:ShowLetterbox()
                    else
                        mountLetterbox = false
                    end
                    mountLetterboxTimer = nil
                end, delayMs)
            else
                self:ShowLetterbox()
            end
        else
            mountLetterbox = false
        end
    end
end

function CinematicCam:OnMountDown()
    if not self.savedVars or not self.savedVars.letterbox then
        return
    end

    if self.savedVars.letterbox.autoLetterboxMount then
        if mountLetterbox and self.savedVars.letterbox.letterboxVisible then
            self:HideLetterbox()
        end
        mountLetterbox = false
    end
end
