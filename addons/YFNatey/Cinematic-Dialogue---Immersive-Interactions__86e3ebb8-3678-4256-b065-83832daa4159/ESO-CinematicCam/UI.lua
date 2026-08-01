CinematicCam.uiElementsMap = {} -- table for hiding ui elements, used in HideUI()
-- UI elements to hide
CinematicCam.interactionTypes = {
    INTERACTION_CONVERSATION,
    INTERACTION_QUEST,
    INTERACTION_VENDOR,
    INTERACTION_STORE,
    --NTERACTION_BANK, -- Storage coffers
    INTERACTION_GUILDBANK,
    INTERACTION_TRADINGHOUSE,
    INTERACTION_STABLE,
    INTERACTION_CRAFT,
    INTERACTION_DYE_STATION,
}
CinematicCam.manualUIHidden = false
CinematicCam.uiElements = {
    -- Compass
    "ZO_CompassFrame",
    "ZO_CompassFrameCenter",
    "ZO_CompassFrameLeft",
    "ZO_CompassFrameRight",
    "ZO_CompassContainer",

    -- Action  Bar
    "ZO_PlayerAttributeHealth",
    "ZO_PlayerAttributeMagicka",
    "ZO_PlayerAttributeStamina",
    "ZO_ActionBar1",
    "ZO_ActionBar2",
    "ZO_TargetUnitFrame",
    "ZO_UnitFrames",

    "ZO_MinimapContainer",

    -- Buff bar
    "ZO_PowerBlock",
    "ZO_BuffTracker",

    -- Reticle
    "ZO_ReticleContainerReticle",
    "ZO_ReticleContainerStealthIcon",
    --"ZO_ReticleContainerNoneInteract", --prevents player from interacting with objects when hidden
    -- "ZO_ReticleContainer",

    -- Quest-related UI
    "ZO_QuestJournal",
    "ZO_QuestJournalKeyboard",
    "ZO_QuestTimerFrame",
    "ZO_FocusedQuestTrackerPanel",
    "ZO_QuestTrackerPanelContainer",
    "ZO_QuestLog",
    "ZO_ConversationWindow",

    -- Inventory & Menus
    "ZO_PlayerInventory",
    "ZO_GameMenu_InGame",
    "ZO_MainMenuCategoryBarContainer",

    "ZO_NotificationContainer",
    "ZO_TutorialOverlay",

}

function CinematicCam:InitializeUI()
    if not CinematicCam.savedVars.interface.UiElementsVisible then
        zo_callLater(function()
            for _, elementName in ipairs(CinematicCam.uiElements) do
                local element = _G[elementName]
                if element and not element:IsHidden() then
                    CinematicCam.uiElementsMap[elementName] = true
                    element:SetHidden(true)
                end
            end
            for elementName, shouldHide in pairs(CinematicCam.savedVars.hideUiElements) do
                if shouldHide then
                    local element = _G[elementName]
                    if element and not element:IsHidden() then
                        CinematicCam.uiElementsMap[elementName] = true
                        element:SetHidden(true)
                    end
                end
            end
        end, 1600)
    end
end

function CinematicCam:InitializeUITweaks()
    if self.savedVars.interface.usingModTweaks then
        CinematicCam:UpdateCompassVisibility()
        CinematicCam:UpdateActionBarVisibility()
        CinematicCam:UpdateReticleVisibility()
        CinematicCam:UpdateHealthBarsVisibility()
    end
end

function CinematicCam:IsInAnyInteraction()
    local currentInteractionType = GetInteractionType()

    if currentInteractionType == INTERACTION_NONE then
        return false
    end

    for _, interactionType in ipairs(self.interactionTypes) do
        if currentInteractionType == interactionType then
            return true
        end
    end

    return false
end

---=============================================================================
-- Manage ESO UI Elements
--=============================================================================
function CinematicCam:HideUI()
    if not self.savedVars.interface.UiElementsVisible then
        return
    end

    self.manualUIHidden = true -- Set flag

    for _, elementName in ipairs(CinematicCam.uiElements) do
        local element = _G[elementName]
        if element and not element:IsHidden() then
            CinematicCam.uiElementsMap[elementName] = true
            element:SetHidden(true)
        end
    end

    for elementName, shouldHide in pairs(self.savedVars.hideUiElements) do
        if shouldHide then
            local element = _G[elementName]
            if element and not element:IsHidden() then
                CinematicCam.uiElementsMap[elementName] = true
                element:SetHidden(true)
            end
        end
    end
    self.savedVars.interface.UiElementsVisible = false
end

-- Show UI elements
function CinematicCam:ShowUI()
    if self.savedVars.interface.UiElementsVisible then
        return
    end

    self.manualUIHidden = false -- Clear flag

    for elementName, _ in pairs(CinematicCam.uiElementsMap) do
        local element = _G[elementName]
        if element then
            element:SetHidden(false)
        end
    end
    CinematicCam.uiElementsMap = {}
    self.savedVars.interface.UiElementsVisible = true
end

-- Toggle UI
function CinematicCam:ToggleUI()
    if self.savedVars.interface.UiElementsVisible then
        self:HideUI()
    else
        self:ShowUI()
    end
end

function CinematicCam:MovieMode()
    local uiVisible = self.savedVars.interface.UiElementsVisible
    local barsVisible = self.savedVars.letterbox.letterboxVisible

    -- If is visible, hide everything (enter movie mode)
    if uiVisible or not barsVisible then
        -- Hide UI if it's showing
        if uiVisible then
            self:HideUI()
        end
        -- Show bars if they're not showing
        if not barsVisible then
            self:ShowLetterbox()
        end
    else
        -- Both are already hidden/shown (in movie mode), so exit movie mode
        self:ShowUI()
        self:HideLetterbox()
    end
end

-- UI element groups
CinematicCam.compassElements = {
    "ZO_CompassFrame",
    "ZO_CompassFrameCenter",
    "ZO_CompassFrameLeft",
    "ZO_CompassFrameRight",
    "ZO_CompassContainer",
}

CinematicCam.actionbar = {
    "ZO_PlayerAttributeHealth",
    "ZO_PlayerAttributeMagicka",
    "ZO_PlayerAttributeStamina",
    "ZO_ActionBar1",
    "ZO_ActionBar2",

    "ZO_PowerBlock",
    "ZO_BuffTracker",
}

CinematicCam.healthbars = {
    "ZO_TargetUnitFrame",
    "ZO_UnitFrames",
    "ZO_MinimapContainer",
}
CinematicCam.reticle = {
    "ZO_ReticleContainerReticle",
    "ZO_ReticleContainerStealthIcon",
}
CinematicCam.InteractionReticle = {
    "ZO_ReticleContainerReticle",
    "ZO_ReticleContainer",
    "ZO_ReticleContainerStealthIcon",
    "ZO_ReticleContainerNoneInteract",

}

---=============================================================================
-- UI Element Show/Hide Functions
--=============================================================================
function CinematicCam:ShowCompass()
    for _, elementName in ipairs(CinematicCam.compassElements) do
        local element = _G[elementName]
        if element then
            self:FadeInElement(element, 200)
        end
    end
end

function CinematicCam:HideCompass()
    for _, elementName in ipairs(CinematicCam.compassElements) do
        local element = _G[elementName]
        if element then
            self:FadeOutElement(element, 200)
        end
    end
end

function CinematicCam:ShowActionBar()
    for _, elementName in ipairs(CinematicCam.actionbar) do
        local element = _G[elementName]
        if element then
            self:FadeInElement(element, 200)
        end
    end

    --  mount stamina handled separately
    local mountStamina = _G["ZO_PlayerAttributeMountStamina"]
    if mountStamina and IsMounted() then
        self:FadeInElement(mountStamina, 200)
    end
end

function CinematicCam:HideActionBar()
    for _, elementName in ipairs(CinematicCam.actionbar) do
        local element = _G[elementName]
        if element then
            self:FadeOutElement(element, 200)
        end
    end

    -- mount stamina
    local mountStamina = _G["ZO_PlayerAttributeMountStamina"]
    if mountStamina then
        self:FadeOutElement(mountStamina, 200)
    end
end

function CinematicCam:ShowReticle()
    for _, elementName in ipairs(CinematicCam.reticle) do
        local element = _G[elementName]
        if element then
            self:FadeInElement(element, 200)
        end
    end
end

function CinematicCam:HideReticle()
    for _, elementName in ipairs(CinematicCam.reticle) do
        local element = _G[elementName]
        if element then
            self:FadeOutElement(element, 200)
        end
    end
end

function CinematicCam:ShowHealthBars()
    for _, elementName in ipairs(CinematicCam.healthbars) do
        local element = _G[elementName]
        if element then
            self:FadeInElement(element, 200)
        end
    end
end

function CinematicCam:HideHealthBars()
    for _, elementName in ipairs(CinematicCam.healthbars) do
        local element = _G[elementName]
        if element then
            self:FadeOutElement(element, 200)
        end
    end
end

function CinematicCam:UpdateUIVisibility()
    if not self.savedVars.interface.usingModTweaks then
        return
    end
    CinematicCam:UpdateActionBarVisibility()
    CinematicCam:UpdateCompassVisibility()
    CinematicCam:UpdateReticleVisibility()
    CinematicCam:UpdateHealthBarsVisibility()
end

CinematicCam.weaponsPoll = {
    timer = nil,
    isActive = false,
    subscribers = {}
}


function CinematicCam:StartWeaponsPoll(subscriberName)
    -- Add subscriber
    self.weaponsPoll.subscribers[subscriberName] = true

    -- If already polling, just return
    if self.weaponsPoll.isActive then
        return
    end

    -- Start the poll
    self.weaponsPoll.isActive = true
    self:ExecuteWeaponsPoll()
end

function CinematicCam:StopWeaponsPoll(subscriberName)
    -- Remove subscriber
    if subscriberName then
        self.weaponsPoll.subscribers[subscriberName] = nil
    end

    -- Check if anyone still needs polling
    local hasSubscribers = false
    for _ in pairs(self.weaponsPoll.subscribers) do
        hasSubscribers = true
        break
    end

    -- Only stop if no subscribers
    if not hasSubscribers then
        if self.weaponsPoll.timer then
            zo_removeCallLater(self.weaponsPoll.timer)
            self.weaponsPoll.timer = nil
        end
        self.weaponsPoll.isActive = false
    end
end

function CinematicCam:ExecuteWeaponsPoll()
    if not self.weaponsPoll.isActive then
        return
    end

    local weaponsSheathed = ArePlayerWeaponsSheathed()

    -- Only update if state changed
    if CinematicCam.lastWeaponsState ~= weaponsSheathed then
        CinematicCam.lastWeaponsState = weaponsSheathed

        -- Update all UI elements based on their settings
        local reticleSetting = self.savedVars.interface.hideReticle
        local compassSetting = self.savedVars.interface.hideCompass
        local actionbarSetting = self.savedVars.interface.hideActionBar
        local healthbarsSetting = self.savedVars.interface.hideHealthBars

        if not weaponsSheathed then
            if reticleSetting == "weapons" then
                self:ShowReticle()
            end
            if compassSetting == "weapons" then
                self:ShowCompass()
            end
            if actionbarSetting == "weapons" then
                self:ShowActionBar()
            end
            if healthbarsSetting == "weapons" then
                self:ShowHealthBars()
            end
        else
            if reticleSetting == "weapons" then
                self:HideReticle()
            end
            if compassSetting == "weapons" then
                self:HideCompass()
            end
            if actionbarSetting == "weapons" then
                self:HideActionBar()
            end
            if healthbarsSetting == "weapons" then
                self:HideHealthBars()
            end
        end
    end

    -- Schedule next poll
    self.weaponsPoll.timer = zo_callLater(function()
        self:ExecuteWeaponsPoll()
    end, 1000)
end

function CinematicCam:UpdateCompassVisibility()
    if not self.savedVars.interface.usingModTweaks then
        return
    end
    local setting = self.savedVars.interface.hideCompass
    local inCombat = IsUnitInCombat("player")
    local weaponsSheathed = ArePlayerWeaponsSheathed()
    local showWhenWeaponsUnsheathed = self.savedVars.interface.hideCompassWhenWeaponsSheathed

    if showWhenWeaponsUnsheathed and not weaponsSheathed then
        self:ShowCompass()
        self:StopWeaponsPoll("compass")
        return
    end

    if setting == "never" then
        self:HideCompass()
        self:StopWeaponsPoll("compass")
    elseif setting == "always" then
        self:ShowCompass()
        self:StopWeaponsPoll("compass")
    elseif setting == "combat" then
        if inCombat then
            self:ShowCompass()
        else
            self:HideCompass()
        end
        self:StopWeaponsPoll("compass")
    elseif setting == "weapons" then
        self:StartWeaponsPoll("compass")
    else
        self:StopWeaponsPoll("compass")
    end
end

function CinematicCam:UpdateActionBarVisibility()
    if not self.savedVars.interface.usingModTweaks then
        return
    end
    local setting = self.savedVars.interface.hideActionBar
    local inCombat = IsUnitInCombat("player")
    local weaponsSheathed = ArePlayerWeaponsSheathed()
    local showWhenWeaponsUnsheathed = self.savedVars.interface.hideActionBarWhenWeaponsSheathed
    local inDialogue = CinematicCam.isInteractionModified

    if inDialogue then
        self:StopWeaponsPoll("actionbar")
        return
    end

    if showWhenWeaponsUnsheathed and not weaponsSheathed then
        self:ShowActionBar()
        self:StopWeaponsPoll("actionbar")
        return
    end

    if setting == "never" then
        self:HideActionBar()
        self:StopWeaponsPoll("actionbar")
    elseif setting == "always" then
        self:ShowActionBar()
        self:StopWeaponsPoll("actionbar")
    elseif setting == "combat" then
        if inCombat then
            self:ShowActionBar()
        else
            self:HideActionBar()
        end
        self:StopWeaponsPoll("actionbar")
    elseif setting == "weapons" then
        self:StartWeaponsPoll("actionbar")
    else
        self:StopWeaponsPoll("actionbar")
    end
end

function CinematicCam:UpdateReticleVisibility()
    if not self.savedVars.interface.usingModTweaks then
        return
    end
    local setting = self.savedVars.interface.hideReticle
    local inCombat = IsUnitInCombat("player")
    local weaponsSheathed = ArePlayerWeaponsSheathed()

    if setting == "never" then
        self:HideReticle()
        self:StopWeaponsPoll("reticle")
    elseif setting == "always" then
        self:ShowReticle()
        self:StopWeaponsPoll("reticle")
    elseif setting == "combat" then
        if inCombat then
            self:ShowReticle()
        else
            self:HideReticle()
        end
        self:StopWeaponsPoll("reticle")
    elseif setting == "weapons" then
        self:StartWeaponsPoll("reticle")
    else
        self:StopWeaponsPoll("reticle")
    end
end

function CinematicCam:UpdateHealthBarsVisibility()
    if not self.savedVars.interface.usingModTweaks then
        return
    end
    local setting = self.savedVars.interface.hideHealthBars
    local inCombat = IsUnitInCombat("player")
    local weaponsSheathed = ArePlayerWeaponsSheathed()
    local showWhenWeaponsUnsheathed = self.savedVars.interface.hideHealthBarsWhenWeaponsSheathed

    if showWhenWeaponsUnsheathed and not weaponsSheathed then
        self:ShowHealthBars()
        self:StopWeaponsPoll("healthbars")
        return
    end

    if setting == "never" then
        self:HideHealthBars()
        self:StopWeaponsPoll("healthbars")
    elseif setting == "always" then
        self:ShowHealthBars()
        self:StopWeaponsPoll("healthbars")
    elseif setting == "combat" then
        if inCombat then
            self:ShowHealthBars()
        else
            self:HideHealthBars()
        end
        self:StopWeaponsPoll("healthbars")
    elseif setting == "weapons" then
        self:StartWeaponsPoll("healthbars")
    else
        self:StopWeaponsPoll("healthbars")
    end
end

---=============================================================================
-- Hide Questing Dialoge Panels
--=============================================================================
-- Hides each element of the default UI panels during dialogue interactions
function CinematicCam:HideDialoguePanels()
    -- Main dialogue window elements
    if ZO_InteractWindow_GamepadContainerDivider then ZO_InteractWindow_GamepadContainerDivider:SetHidden(true) end

    -- Gold divider line between subtitles and player options
    if ZO_InteractWindowVerticalSeparator then ZO_InteractWindowVerticalSeparator:SetHidden(true) end

    -- Top and bottom background
    if ZO_InteractWindowTopBG then ZO_InteractWindowTopBG:SetHidden(false) end
    if ZO_InteractWindowBottomBG then ZO_InteractWindowBottomBG:SetHidden(true) end

    -- NPC Name
    if ZO_InteractWindowTargetAreaTitle then ZO_InteractWindowTargetAreaTitle:SetHidden(true) end

    -- Options
    if ZO_InteractWindowPlayerAreaOptions then ZO_InteractWindowPlayerAreaOptions:SetHidden(true) end
    if ZO_InteractWindowPlayerAreaHighlight then ZO_InteractWindowPlayerAreaHighlight:SetHidden(true) end
    if ZO_InteractWindowCollapseContainerRewardArea then ZO_InteractWindowCollapseContainerRewardArea:SetHidden(true) end

    -- Gamepad elements
    if ZO_InteractWindow_GamepadBG then ZO_InteractWindow_GamepadBG:SetHidden(true) end
    if ZO_InteractWindow_GamepadContainerText and self.savedVars.interaction.layoutPreset ~= "cinematic" then
        ZO_InteractWindow_GamepadContainerText:SetHidden(self.savedVars.interaction.subtitles.isHidden)
    end
end

function CinematicCam:ShowDialoguePanels()
    -- Main dialogue window elements
    if ZO_InteractWindow_GamepadContainerDivider then ZO_InteractWindow_GamepadContainerDivider:SetHidden(false) end

    if ZO_InteractWindowDivider then ZO_InteractWindowDivider:SetHidden(false) end

    -- Gold divider line between subtitles and player options
    if ZO_InteractWindowVerticalSeparator then ZO_InteractWindowVerticalSeparator:SetHidden(false) end

    -- Top and bottom background
    if ZO_InteractWindowTopBG then ZO_InteractWindowTopBG:SetHidden(false) end
    if ZO_InteractWindowBottomBG then ZO_InteractWindowBottomBG:SetHidden(false) end

    -- NPC Name
    if ZO_InteractWindowTargetAreaTitle then ZO_InteractWindowTargetAreaTitle:SetHidden(false) end

    -- Only show NPC text if the hideNPCText setting is enabled
    if ZO_InteractWindowTargetAreaBodyText then ZO_InteractWindowTargetAreaBodyText:SetHidden(true) end

    -- Options
    if ZO_InteractWindowPlayerAreaOptions then ZO_InteractWindowPlayerAreaOptions:SetHidden(false) end
    if ZO_InteractWindowPlayerAreaHighlight then ZO_InteractWindowPlayerAreaHighlight:SetHidden(false) end
    if ZO_InteractWindowCollapseContainerRewardArea then ZO_InteractWindowCollapseContainerRewardArea:SetHidden(false) end

    -- Gamepad elements
    if ZO_InteractWindow_GamepadBG then ZO_InteractWindow_GamepadBG:SetHidden(false) end
    if ZO_InteractWindow_GamepadContainerText and self.savedVars.interaction.layoutPreset ~= "cinematic" then
        ZO_InteractWindow_GamepadContainerText:SetHidden(self.savedVars.interaction.subtitles.isHidden)
    end
end

---=============================================================================
-- Reposition UI
--=============================================================================
local npcTextContainer = ZO_InteractWindow_GamepadContainerText
if npcTextContainer then
    local originalWidth, originalHeight = npcTextContainer:GetDimensions()
    local addedWidth = originalWidth + 10
    local addedHeight = originalHeight + 100
end

function CinematicCam:ApplyCinematicPreset()
    ZO_InteractWindow_GamepadContainerText:SetHidden(true)
    if npcTextContainer then
        local originalWidth, originalHeight = npcTextContainer:GetDimensions()
        npcTextContainer:SetWidth(originalWidth)
        npcTextContainer:SetHeight(originalHeight + 100)
    end
    self:ApplySubtitlePosition()
end

function CinematicCam:ApplySubtitlePosition()
    local targetX, targetY = self:ConvertToScreenCoordinates(
        self.savedVars.interaction.subtitles.posX or 0.5,
        self.savedVars.interaction.subtitles.posY or 0.7
    )

    if npcTextContainer then
        npcTextContainer:ClearAnchors()
        npcTextContainer:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
    end

    -- Apply to custom chunked dialogue control
    if CinematicCam.chunkedDialogueData.customControl then
        CinematicCam.chunkedDialogueData.customControl:ClearAnchors()
        CinematicCam.chunkedDialogueData.customControl:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
    end
end

function CinematicCam:ApplyChunkedTextPositioning()
    local control = CinematicCam.chunkedDialogueData.customControl
    local background = CinematicCam.chunkedDialogueData.backgroundControl

    if not control then return end

    local preset = self.savedVars.interaction.layoutPreset
    local safeWidth, safeHeight, screenWidth, screenHeight = self:GetSafeScreenDimensions()

    if preset == "cinematic" then
        local targetX, targetY = self:ConvertToScreenCoordinates(
            self.savedVars.interaction.subtitles.posX or 0.5,
            self.savedVars.interaction.subtitles.posY or 0.7
        )

        control:ClearAnchors()
        control:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
        control:SetDimensions(safeWidth, math.min(safeHeight * 0.3, 200))

        -- Position background to match with dynamic sizing
        if background then
            background:ClearAnchors()
            background:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
            background:SetDimensions(math.min(safeWidth * 1.1, 900), 150)
        end
    else
        -- Default positioning for non-cinematic presets
        -- The width of efault eso subtitles is 683
        local defaultWidth = math.min(screenWidth * 0.35, 683)
        local defaultHeight = math.min(safeHeight * 0.7, 550)

        control:ClearAnchors()
        control:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -50, 100)
        control:SetDimensions(defaultWidth, defaultHeight)

        -- Position background to match
        if background then
            background:ClearAnchors()
            background:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -50, 100)
            background:SetDimensions(defaultWidth + 37, defaultHeight + 30)
        end
    end
end

function CinematicCam:ApplyDefaultPosition()
    ZO_InteractWindow_GamepadContainerText:SetHidden(false)
    zo_callLater(function()
        local rootWindow = _G["ZO_InteractWindow_Gamepad"]
        if rootWindow then
            local screenWidth, screenHeight = GuiRoot:GetDimensions()

            -- Calculate positions
            local centerX = screenWidth * self.savedVars.interface.dialogueHorizontalOffset
            local centerY = 0
            if self.savedVars.interface.dialogueVerticalOffset then
                centerY = (self.savedVars.interface.dialogueVerticalOffset - 0.5) * screenHeight * 0.8
            end

            -- Coordinate with letterbox if active
            if self.savedVars.letterbox.letterboxVisible then
                centerY = centerY + (self.savedVars.letterbox.size * 0.3)
            end

            -- Move root window
            rootWindow:ClearAnchors()
            rootWindow:SetAnchor(CENTER, GuiRoot, CENTER, centerX, 0)
            rootWindow:SetWidth(683)
            rootWindow:SetHeight(2000)

            -- Move the player options elements with same offset
            local playerOptionsElements = {
                "ZO_InteractWindow_GamepadContainerInteract",
                "ZO_InteractWindow_GamepadContainerInteractList",
                "ZO_InteractWindow_GamepadContainerInteractListScroll",
                "ZO_InteractWindow_GamepadContainer",
                "ZO_InteractWindow_GamepadTitle"
            }

            for _, elementName in ipairs(playerOptionsElements) do
                local element = _G[elementName]
                if element then
                    element:ClearAnchors()
                    element:SetAnchor(CENTER, GuiRoot, CENTER, centerX, centerY)
                end
            end
        end
    end)
end

function CinematicCam:OnDialoguelayoutPresetChanged(newPreset)
    if CinematicCam.chunkedDialogueData.isActive and CinematicCam.chunkedDialogueData.customControl then
        self:ApplyChunkedTextPositioning()
    end
end

---=============================================================================
-- Animations
--=============================================================================
-- fade-in for any UI element
function CinematicCam:FadeInElement(element, duration)
    if not element then return end

    if not element:IsHidden() and element:GetAlpha() >= 0.99 then
        return
    end

    element:SetAlpha(0)
    element:SetHidden(false)

    -- Fade-in animation
    local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", element)
    local animation = timeline:GetFirstAnimation()

    if animation then
        animation:SetAlphaValues(0, 1)
        animation:SetDuration(duration or 300)
        animation:SetEasingFunction(ZO_EaseInQuadratic)
    end

    timeline:PlayFromStart()
end

-- fade-out for any UI element
function CinematicCam:FadeOutElement(element, duration)
    if not element then return end

    if element:IsHidden() then
        return
    end

    local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ShowOnMouseOverLabelAnimation", element)
    local animation = timeline:GetFirstAnimation()

    if animation then
        animation:SetAlphaValues(element:GetAlpha(), 0)
        animation:SetDuration(duration or 300)
        animation:SetEasingFunction(ZO_EaseOutQuadratic)
    end

    timeline:SetHandler("OnStop", function()
        element:SetHidden(true)
        element:SetAlpha(1)
    end)

    timeline:PlayFromStart()
end

function CinematicCam:ToggleDepthOfField()
    if self.savedVars.interaction.depthOfField.enabled then
        -- Check if DOF is currently active
        if self.dofActive then
            -- Turn it off
            SetFullscreenEffect(FULLSCREEN_EFFECT_NONE, 0, 0, true)
            self.dofActive = false
        else
            -- Turn it on
            local param1 = self.savedVars.interaction.depthOfField.param1
            local param2 = self.savedVars.interaction.depthOfField.param2
            SetFullscreenEffect(FULLSCREEN_EFFECT_CHARACTER_FRAMING_BLUR, param1, param2, true)
            self.dofActive = true
        end
    end
end

---=============================================================================
-- LibRadialMenu
--=============================================================================
function CinematicCam:InitializeLibRadialMenu()
    -- Check if LibRadialMenu is loaded
    if not LibRadialMenu then
        return
    end

    -- Register our addon
    LibRadialMenu:RegisterAddon("CinematicCam", "Cinematic Dialogue")

    -- Register Toggle UI command
    LibRadialMenu:RegisterEntry(
        "CinematicCam",                               -- addonId
        "Clean UI",                                   -- entryName
        "cinematiccam_toggle_ui",                     -- entryId
        "/esoui/art/chatwindow/chat_addtab_down.dds", -- entryIcon
        function()                                    -- entryCallback
            CinematicCam:ToggleUI()
        end,
        "Toggle visibility of UI elements" -- entryDescription
    )

    -- Register Toggle Letterbox command
    LibRadialMenu:RegisterEntry(
        "CinematicCam",
        "Toggle Black Bars",
        "cinematiccam_toggle_letterbox",
        "/esoui/art/lorelibrary/lorelibrary_dwemerbook.dds",
        function()
            CinematicCam:ToggleLetterbox()
        end,
        "Toggle cinematic letterbox bars"
    )

    -- Register Movie Mode command
    LibRadialMenu:RegisterEntry(
        "CinematicCam",
        "Movie Mode",
        "cinematiccam_movie_mode",

        "/esoui/art/loadingscreens/loadscreen_sunhold_01.dds",
        function()
            CinematicCam:MovieMode()
        end,
        "Toggle UI and letterbox together"
    )

    -- Register Preset 1 (Home)
    LibRadialMenu:RegisterEntry(
        "CinematicCam",
        "Preset: Home",
        "cinematiccam_preset_1",
        "/esoui/art/guild/tabicon_home_up.dds",
        function()
            CinematicCam:LoadFromPresetSlot(1)
            CinematicCam:ShowPresetNotificationUI("Home")
        end,
        "Load Home preset settings"
    )

    -- Register Preset 2 (Overland)
    LibRadialMenu:RegisterEntry(
        "CinematicCam",
        "Preset: Overland",
        "cinematiccam_preset_2",

        "/esoui/art/compass/quest_icon.dds",
        function()
            CinematicCam:LoadFromPresetSlot(2)
            CinematicCam:ShowPresetNotificationUI("Overland")
        end,
        "Load Overland preset settings"
    )

    -- Register Preset 3 (Dungeon/Trials)
    LibRadialMenu:RegisterEntry(
        "CinematicCam",
        "Preset: Dungeons",
        "cinematiccam_preset_3",
        "/esoui/art/icons/achievement_update11_dungeons_019.dds",
        function()
            CinematicCam:LoadFromPresetSlot(3)
            CinematicCam:ShowPresetNotificationUI("Dungeon/Trials")
        end,
        "Load Dungeon/Trials preset settings"
    )
    LibRadialMenu:RegisterEntry(
        "CinematicCam",
        "Toggle Depth of Field",
        "cinematiccam_toggle_dof",
        "/esoui/art/treeicons/achievements_indexicon_summary_up.dds",
        function()
            CinematicCam:ToggleDepthOfField()
        end,
        "Toggle depth of field blur effect"
    )
end
