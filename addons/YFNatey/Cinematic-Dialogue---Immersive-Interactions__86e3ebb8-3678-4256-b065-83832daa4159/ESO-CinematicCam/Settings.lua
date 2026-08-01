---=============================================================================
-- Settings Menu
--=============================================================================
-- Helper function to create option names with update indicators
function CinematicCam:GetOptionName(baseName, isNewFeature)
    if isNewFeature and not self.savedVars.hasReloadedSinceUpdate then
        return "|c00FF00●|r" .. baseName
    end
    return baseName
end

function CinematicCam:CreateSettingsMenu()
    local LAM = LibAddonMenu2

    if not LAM then
        return
    end
    local choices, choicesValues = self:GetFontChoices()

    local panelName = "CinematicCamOptions"

    local panelData = {
        type = "panel",
        name = self:CC_L("SETTINGS_TITLE"),
        displayName = self:CC_L("SETTINGS_TITLE"),
        author = "YFNatey",
        version = "1.0",
        slashCommand = self:CC_L("SETTINGS_SLASH"),
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local emotePackChoices = {
        "Respectful", "Friendly", "Greeting", "Hostile", "Frustrated",
        "Sad", "Scared", "Confused", "Disgusted", "Eating/Drinking",
        "Entertainment/Dance", "Idle Poses", "Pointing/Directing",
        "Physical Actions", "Agreement",
        "Disagreement", "Playful"
    }

    local emotePackValues = {
        "respectful", "friendly", "greeting", "hostile", "frustrated",
        "sad", "scared", "confused", "disgusted", "eating",
        "entertainment", "idle", "pointing", "physical",
        "agreement", "disagreement",
        "playful"
    }
    local optionsData = {



        {
            type = "checkbox",
            name = self:CC_L("SUBTITLES"),
            tooltip = self:CC_L("SUBTITLES_TOOLTIP"),
            getFunc = function() return not self.savedVars.interaction.subtitles.isHidden end,
            setFunc = function(value)
                self.savedVars.interaction.subtitles.isHidden = not value
                self:UpdateChunkedTextVisibility()
                self.presetPending = true
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = self:CC_L("SUBTITLE_STYLE"),
            tooltip = self:CC_L("SUBTITLE_STYLE_TOOLTIP"),
            choices = { self:CC_L("STYLE_DEFAULT"), self:CC_L("STYLE_CINEMATIC") },
            choicesValues = { "default", "cinematic" },
            getFunc = function() return self.savedVars.interaction.layoutPreset end,
            setFunc = function(value)
                self.savedVars.interaction.layoutPreset = value
                currentRepositionPreset = value

                -- Set NPC name location based on style
                if value == "cinematic" then
                    self.savedVars.npcNamePreset = "prepended"
                    self.savedVars.interaction.ui.hidePanelsESO = true
                    self.savedVars.interaction.subtitles.useChunkedDialogue = true
                    self.savedVars.interface.hideKeybindStrip = true
                    self.presetPending = false
                elseif value == "default" then
                    self.savedVars.npcNamePreset = "default"
                    self.savedVars.interaction.ui.hidePanelsESO = false
                    self.presetPending = true
                end



                -- Apply immediately if in dialogue
                local interactionType = GetInteractionType()
                if interactionType ~= INTERACTION_NONE then
                    self:ApplyNPCNamePreset(self.savedVars.npcNamePreset)
                    zo_callLater(function()
                        self:ApplyDialogueRepositioning()
                    end, 50)
                end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = self:CC_L("HIDE_BOTTOM_PANEL"),
            tooltip = self:CC_L("HIDE_BOTTOM_PANEL_TOOLTIP"),
            getFunc = function() return self.savedVars.interface.hideKeybindStrip end,
            setFunc = function(value)
                self.savedVars.interface.hideKeybindStrip = value

                self.pendingUIRefresh = true
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = self:CC_L("HIDE_CHOICES"),
            tooltip = self:CC_L("HIDE_CHOICES_TOOLTIP"),
            getFunc = function() return self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk end,
            setFunc = function(value)
                self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk = value
            end,
            width = "full",
            disabled = function()
                return self.savedVars.interaction.layoutPreset ~= "cinematic"
            end,
        },


        {
            type = "checkbox",
            name = self:CC_L("SHOW_INTERACTION_BUTTONS"),
            tooltip = function()
                -- Show the icon control
                local iconControl = _G["CinematicCam_EmoteIconTooltip"]
                if iconControl then
                    -- Set platform-specific icons
                    local isPlayStation = GetPlatformServiceType() == PLATFORM_SERVICE_TYPE_PSN

                    local xboxLT = _G["CinematicCam_EmoteIconTooltip_XboxLT"]
                    local ps4LT = _G["CinematicCam_EmoteIconTooltip_PS4LT"]
                    local xboxSlide = _G["CinematicCam_EmoteIconTooltip_LeftStick_Slide"]
                    local xboxScroll = _G["CinematicCam_EmoteIconTooltip_LeftStick_Scroll"]
                    local ps4LS = _G["CinematicCam_EmoteIconTooltip_LeftStick_PS4"]

                    if isPlayStation then
                        if ps4LT then ps4LT:SetHidden(false) end
                        if ps4LS then ps4LS:SetHidden(false) end
                        if xboxLT then xboxLT:SetHidden(true) end
                        if xboxSlide then xboxSlide:SetHidden(true) end
                        if xboxScroll then xboxScroll:SetHidden(true) end
                    else
                        if xboxLT then xboxLT:SetHidden(false) end
                        if xboxSlide then xboxSlide:SetHidden(false) end
                        if xboxScroll then xboxScroll:SetHidden(false) end
                        if ps4LT then ps4LT:SetHidden(true) end
                        if ps4LS then ps4LS:SetHidden(true) end
                    end

                    -- Anchor to LAM tooltip and show
                    iconControl:ClearAnchors()
                    iconControl:SetAnchor(TOP, LibAddonMenu2.tooltip, BOTTOM, 0, 10)
                    iconControl:SetHidden(false)

                    -- Hide when tooltip closes
                    zo_callLater(function()
                        if LibAddonMenu2.tooltip and LibAddonMenu2.tooltip:IsHidden() then
                            iconControl:SetHidden(true)
                        end
                    end, 100)
                end

                -- Return the text tooltip
                return self:CC_L("SHOW_INTERACTION_BUTTONS_TOOLTIP")
            end,
            getFunc = function()
                return CinematicCam.savedVars.interaction.ButtonsVisible
            end,
            setFunc = function(value)
                CinematicCam.savedVars.interaction.ButtonsVisible = value
            end,
        },

        {
            type = "checkbox",
            name = self:CC_L("VANILLA_MERCHANTS_BANKERS"),
            tooltip = self:CC_L("VANILLA_MERCHANTS_BANKERS_TOOLTIP"),
            getFunc = function()
                return CinematicCam.savedVars.interaction.forceThirdPersonOccupationalNPC or false
            end,
            setFunc = function(value)
                CinematicCam.savedVars.interaction.forceThirdPersonOccupationalNPC = value
            end,
            width = "full",
        },
        {
            type = "submenu",
            name = self:CC_L("PRESETS"),
            controls = {
                {
                    type = "dropdown",
                    name = self:CC_L("CUSTOM_PRESETS"),
                    tooltip = function()
                        local slot = self.selectedPresetSlot or 1
                        return self:GetPresetTooltip(slot)
                    end,
                    choices = {
                        self:GetSlotDisplayName(1),
                        self:GetSlotDisplayName(2),
                        self:GetSlotDisplayName(3)
                    },
                    choicesValues = { 1, 2, 3 },
                    choicesTooltips = {
                        function() return self:GetPresetTooltip(1) end,
                        function() return self:GetPresetTooltip(2) end,
                        function() return self:GetPresetTooltip(3) end
                    },
                    getFunc = function()
                        return self.selectedPresetSlot
                    end,
                    setFunc = function(value)
                        self.selectedPresetSlot = value

                        zo_callLater(function()
                            local tooltip = LibAddonMenu2 and LibAddonMenu2.tooltip
                            if tooltip and not tooltip:IsHidden() then
                                tooltip:ClearLines()

                                tooltip:AddLine(self:GetPresetTooltip(value), "",
                                    ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
                            end
                        end, 10)
                    end,
                    width = "full",
                },
                {

                },
                {
                    type = "button",
                    name = function()
                        local slot = self.selectedPresetSlot or 1
                        local slotName = self:GetSlotDisplayName(slot)
                        return self:CC_L("APPLY_PRESET", { preset = slotName })
                    end,
                    tooltip = self:CC_L("PRESET_APPLY_TOOLTIP"),
                    func = function()
                        local slot = self.selectedPresetSlot or 1
                        local slotName = self:GetSlotDisplayName(slot)
                        self:LoadFromPresetSlot(slot)
                        CinematicCam:ShowPresetNotificationUI(slotName)
                    end,
                    width = "half",
                    disabled = function()
                        local slot = self.selectedPresetSlot or 1
                        local slotKey = "slot" .. slot
                        local presetSlot = self.savedVars.customPresets and self.savedVars.customPresets[slotKey]
                        return not (presetSlot and presetSlot.settings)
                    end,
                },
                {
                    type = "button",
                    name = function()
                        local slot = self.selectedPresetSlot or 1
                        local slotName = self:GetSlotDisplayName(slot)
                        return self:CC_L("SAVE_PRESET", { preset = slotName })
                    end,
                    tooltip = self:CC_L("PRESET_SAVE_TOOLTIP"),
                    func = function()
                        local slot = self.selectedPresetSlot or 1
                        self:SaveToPresetSlot(slot)
                    end,
                    width = "half",
                },
                {
                    type = "button",
                    name = function()
                        local slot = self.selectedPresetSlot or 1
                        local slotName = self:GetSlotDisplayName(slot)
                        return self:CC_L("DELETE_PRESET", { preset = slotName })
                    end,
                    tooltip = self:CC_L("PRESET_DELETE_TOOLTIP"),
                    func = function()
                        local slot = self.selectedPresetSlot or 1
                        self:ClearPresetSlot(slot)
                        local slotName = self:GetSlotDisplayName(slot)

                        local notification = _G["CinematicCam_UpdateNotification"]
                        local notificationText = _G["CinematicCam_UpdateNotificationText"]
                        if not notification then
                            return
                        end

                        notification:SetHidden(false)
                        notification:SetAlpha(0)
                        notificationText:SetText(self:CC_L("PRESET_DELETED_NOTIFICATION", { preset = slotName }))

                        -- Start fade in animation
                        self:AnimateUpdateNotification(notification, true)

                        -- Auto-hide after 5 seconds
                        zo_callLater(function()
                            self:HideUpdateNotification()
                        end, 4000)
                    end,
                    width = "half",
                    disabled = function()
                        local slot = self.selectedPresetSlot or 1
                        local slotKey = "slot" .. slot
                        local presetSlot = self.savedVars.customPresets and self.savedVars.customPresets[slotKey]
                        return not (presetSlot and presetSlot.settings)
                    end,
                },
                {
                    type = "checkbox",
                    name = self:CC_L("AUTO_PRESETS"),
                    tooltip = self:CC_L("AUTO_PRESETS_TOOLTIP"),
                    getFunc = function() return self.savedVars.autoSwapPresets end,
                    setFunc = function(value)
                        self.savedVars.autoSwapPresets = value
                    end,
                    width = "full",
                },
            },
        },




        {
            type = "submenu",
            name = self:CC_L("SUBTITLE_APPEARANCE"),
            controls = {
                {
                    type = "dropdown",
                    name = self:CC_L("FONT"),
                    tooltip = self:CC_L("FONT_TOOLTIP"),
                    choices = choices,
                    choicesValues = choicesValues,
                    getFunc = function() return self.savedVars.interface.selectedFont end,
                    setFunc = function(value)
                        self.savedVars.interface.selectedFont = value
                        self:OnFontChanged()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = self:CC_L("TEXT_SIZE"),
                    min = 10,
                    max = 64,
                    step = 1,
                    getFunc = function() return self.savedVars.interface.customFontSize end,
                    setFunc = function(value)
                        self.savedVars.interface.customFontSize = value
                        self:OnFontChanged()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = self:CC_L("TEXT_COLOR"),
                    tooltip = self:CC_L("TEXT_COLOR_TOOLTIP"),
                    getFunc = function()
                        local color = self.savedVars.interaction.subtitles.textColor or
                            { r = 0.9, g = 0.9, b = 0.8, a = 1.0 }
                        return color.r, color.g, color.b, color.a
                    end,
                    setFunc = function(r, g, b, a)
                        self.savedVars.interaction.subtitles.textColor = { r = r, g = g, b = b, a = a }

                        -- Apply immediately if in dialogue
                        local control = CinematicCam.chunkedDialogueData.customControl
                        if control then
                            control:SetColor(r, g, b, a)
                        end
                    end,
                    disabled = function()
                        return self.savedVars.interaction.layoutPreset ~= "cinematic"
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = self:CC_L("TEXT_BACKGROUND"),
                    tooltip = self:CC_L("TEXT_BACKGROUND_TOOLTIP"),
                    choices = { self:CC_L("BG_DEFAULT"), self:CC_L("BG_LIGHT"), self:CC_L("BG_NONE") },
                    choicesValues = { "default", "light", "none" },
                    getFunc = function()
                        local currentLayout = self.savedVars.interaction.layoutPreset
                        if currentLayout == "default" then
                            local bgMode = self.savedVars.interface.defaultBackgroundMode or "esoDefault"
                            if bgMode == "esoDefault" then
                                return "default"
                            elseif bgMode == "none" then
                                return "none"
                            else
                                return "light"
                            end
                        else -- cinematic layout
                            local bgMode = self.savedVars.interface.cinematicBackgroundMode or "redemption_banner"
                            if bgMode == "redemption_banner" then
                                return "default"
                            elseif bgMode == "kingdom" then
                                return "light"
                            else
                                return "none"
                            end
                        end
                    end,
                    setFunc = function(value)
                        local currentLayout = self.savedVars.interaction.layoutPreset
                        if currentLayout == "default" then
                            -- Map unified values to default layout values
                            local defaultValue
                            if value == "default" then
                                defaultValue = "esoDefault"
                            elseif value == "light" then
                                defaultValue =
                                "esoDefault" -- Default layout doesn't support light mode, default to esoDefault
                            else
                                defaultValue = "none"
                            end
                            self.savedVars.interface.defaultBackgroundMode = defaultValue
                            self:ApplyDefaultBackgroundSettings(defaultValue)
                            local interactionType = GetInteractionType()
                            if interactionType ~= INTERACTION_NONE then
                                zo_callLater(function()
                                    self:ApplyDialogueRepositioning()
                                end, 50)
                            end
                        else -- cinematic
                            -- Map unified values to cinematic layout values
                            local cinematicValue
                            if value == "default" then
                                cinematicValue = "redemption_banner"
                            elseif value == "light" then
                                cinematicValue = "kingdom"
                            else -- "none"
                                cinematicValue = "none"
                            end
                            self.savedVars.interface.cinematicBackgroundMode = cinematicValue
                            self:ApplyCinematicBackgroundSettings(cinematicValue)
                            local interactionType = GetInteractionType()
                            if interactionType ~= INTERACTION_NONE then
                                zo_callLater(function()
                                    self:RefreshDialogueBackgrounds()
                                end, 50)
                            end
                        end
                    end,
                    width = "full",
                },


                {
                    type = "slider",
                    name = self:CC_L("POSITION"),
                    tooltip = self:CC_L("POSITION_TOOLTIP"),
                    min = 0,
                    max = 100,
                    step = 1,
                    getFunc = function()
                        local normalizedPos = self.savedVars.interaction.subtitles.posY or 0.7
                        return math.floor(normalizedPos * 100)
                    end,
                    setFunc = function(value)
                        local normalizedY = value / 100
                        self.savedVars.interaction.subtitles.posY = normalizedY
                        CinematicCam:OnSubtitlePositionChanged(nil, normalizedY)
                        -- Show preview when slider changes
                        CinematicCam:ShowSubtitlePreview(nil, value)
                    end,
                    disabled = function()
                        return self.savedVars.interaction.layoutPreset ~= "cinematic"
                    end,
                    width = "full",
                },

                {
                    type = "dropdown",
                    name = self:CC_L("SELECT_COMPANION"),
                    tooltip = self:CC_L("SELECT_COMPANION_TOOLTIP"),
                    choices = {
                        self:CC_L("COMPANION_BASTIAN"),
                        self:CC_L("COMPANION_MIRRI"),
                        self:CC_L("COMPANION_EMBER"),
                        self:CC_L("COMPANION_ISOBEL"),
                        self:CC_L("COMPANION_AZANDAR"),
                        self:CC_L("COMPANION_SHARP"),
                        self:CC_L("COMPANION_TANLORIN"),
                        self:CC_L("COMPANION_ZERITH")
                    },
                    choicesValues = {
                        "bastian hallix",
                        "mirri elendis",
                        "ember",
                        "isobel veloise",
                        "azandar",
                        "sharp-as-night",
                        "tanlorin",
                        "zerith-var"
                    },
                    getFunc = function()
                        return self.savedVars.selectedCompanion or "ember"
                    end,
                    setFunc = function(value)
                        self.savedVars.selectedCompanion = value
                        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", controlPanel)
                    end,
                    disabled = function()
                        return self.savedVars.interaction.layoutPreset ~= "cinematic"
                    end,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    name = function()
                        local companionName = self.savedVars.selectedCompanion or "ember"
                        -- Capitalize first letter of each word
                        local displayName = companionName:gsub("(%a)([%w_']*)", function(first, rest)
                            return first:upper() .. rest
                        end)
                        return self:CC_L("COMPANION_COLOR", { companion = displayName })
                    end,
                    tooltip = self:CC_L("COMPANION_COLOR_TOOLTIP"),
                    getFunc = function()
                        local companionName = self.savedVars.selectedCompanion or "ember"
                        if not self.savedVars.companionColors then
                            self.savedVars.companionColors = {}
                        end
                        if not self.savedVars.companionColors[companionName] then
                            -- Default to white for all companions
                            self.savedVars.companionColors[companionName] = { r = 1.0, g = 1.0, b = 1.0, a = 1.0 }
                        end
                        local color = self.savedVars.companionColors[companionName]
                        return color.r, color.g, color.b, color.a
                    end,
                    setFunc = function(r, g, b, a)
                        local companionName = self.savedVars.selectedCompanion or "ember"
                        if not self.savedVars.companionColors then
                            self.savedVars.companionColors = {}
                        end
                        self.savedVars.companionColors[companionName] = { r = r, g = g, b = b, a = a }

                        -- Apply immediately if in dialogue with this companion
                        if self.savedVars.npcNamePreset == "prepended" then
                            local interactionType = GetInteractionType()
                            if interactionType ~= INTERACTION_NONE then
                                self:UpdateNPCNameColor()
                            end
                        end
                    end,
                    disabled = function()
                        return self.savedVars.interaction.layoutPreset ~= "cinematic"
                    end,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    name = self:CC_L("DEFAULT_NPC_COLOR"),
                    tooltip = self:CC_L("DEFAULT_NPC_COLOR_TOOLTIP"),
                    getFunc = function()
                        local color = self.savedVars.npcNameColor
                        return color.r, color.g, color.b, color.a
                    end,
                    setFunc = function(r, g, b, a)
                        self.savedVars.npcNameColor = { r = r, g = g, b = b, a = a }
                        self:UpdateNPCNameColor()
                    end,
                    disabled = function()
                        return self.savedVars.npcNamePreset == "default"
                    end,
                    width = "full",

                },

            },
        },



        {
            type = "submenu",
            name = self:CC_L("EMOTES"),
            controls = {
                {
                    type = "checkbox",
                    name = self:CC_L("ENABLE_EMOTES_MENU"),
                    tooltip = self:CC_L("ENABLE_EMOTES_MENU_TOOLTIP"),
                    getFunc = function()
                        return CinematicCam.savedVars.interaction.allowImmersionControls
                    end,
                    setFunc = function(value)
                        CinematicCam.savedVars.interaction.allowImmersionControls = value
                    end,
                },
                {
                    type = "checkbox",
                    name = self:CC_L("ENABLE_AUTO_EMOTES"),
                    tooltip = self:CC_L("ENABLE_AUTO_EMOTES_TOOLTIP"),
                    getFunc = function()
                        return CinematicCam.savedVars.interaction.autoEmotes
                    end,
                    setFunc = function(value)
                        CinematicCam.savedVars.interaction.autoEmotes = value
                    end,
                },
                {
                    type = "dropdown",
                    name = self:CC_L("AUTO_EMOTES_FREQUENCY"),
                    tooltip = self:CC_L("AUTO_EMOTES_FREQUENCY_TOOLTIP"),
                    choices = {
                        self:CC_L("FREQUENCY_HIGH"),
                        self:CC_L("FREQUENCY_NORMAL"),
                        self:CC_L("FREQUENCY_LOW"),
                        self:CC_L("FREQUENCY_RARE")
                    },
                    choicesValues = { "frequent", "normal", "infrequent", "minimal" },
                    getFunc = function()
                        return self.savedVars.interaction.autoEmoteFrequency or "infrequent"
                    end,
                    setFunc = function(value)
                        self.savedVars.interaction.autoEmoteFrequency = value
                    end,
                    width = "full",
                    disabled = function()
                        return not self.savedVars.interaction.allowImmersionControls
                    end,
                },
                {
                    type = "dropdown",
                    name = self:CC_L("GREETINGS"),
                    tooltip = self:CC_L("GREETINGS_TOOLTIP"),
                    choices = {
                        self:CC_L("GREETING_FRIENDLY"),
                        self:CC_L("GREETING_HOSTILE"),
                        self:CC_L("GREETING_CASUAL"),
                        self:CC_L("GREETING_NONE")
                    },
                    choicesValues = { "friendly", "hostile", "idle", "none" },
                    getFunc = function()
                        return self.savedVars.interaction.GreetingType
                    end,
                    setFunc = function(value)
                        self.savedVars.interaction.GreetingType = value
                    end,
                    width = "full",
                    disabled = function()
                        return not self.savedVars.interaction.allowImmersionControls
                    end,
                },
                {
                    type = "dropdown",
                    name = self:CC_L("RESPONSES"),
                    tooltip = self:CC_L("RESPONSES_TOOLTIP"),
                    choices = {
                        self:CC_L("RESPONSE_FRIENDLY"),
                        self:CC_L("RESPONSE_HOSTILE"),
                        self:CC_L("RESPONSE_NONE")
                    },
                    choicesValues = { "friendly", "frustrated", "none" },
                    getFunc = function()
                        return self.savedVars.interaction.ChatType
                    end,
                    setFunc = function(value)
                        self.savedVars.interaction.ChatType = value
                    end,
                    width = "full",
                    disabled = function()
                        return not self.savedVars.interaction.allowImmersionControls
                    end,
                },
                {
                    type = "description",
                    text = self:CC_L("EMOTE_PAD_DESC"),
                },
                {
                    type = "dropdown",
                    name = self:CC_L("EMOTE_SLOT_1"),
                    tooltip = self:CC_L("EMOTE_SLOT_TOOLTIP"),
                    choices = emotePackChoices,
                    choicesValues = emotePackValues,
                    getFunc = function()
                        return self.savedVars.emoteWheel.slot1 or "entertainment"
                    end,
                    setFunc = function(value)
                        self.savedVars.emoteWheel.slot1 = value
                        self:UpdateEmotePadLabels()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = self:CC_L("EMOTE_SLOT_2"),
                    tooltip = self:CC_L("EMOTE_SLOT_TOOLTIP"),
                    choices = emotePackChoices,
                    choicesValues = emotePackValues,
                    getFunc = function()
                        return self.savedVars.emoteWheel.slot2 or "friendly"
                    end,
                    setFunc = function(value)
                        self.savedVars.emoteWheel.slot2 = value
                        self:UpdateEmotePadLabels()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = self:CC_L("EMOTE_SLOT_3"),
                    tooltip = self:CC_L("EMOTE_SLOT_TOOLTIP"),
                    choices = emotePackChoices,
                    choicesValues = emotePackValues,
                    getFunc = function()
                        return self.savedVars.emoteWheel.slot3 or "greeting"
                    end,
                    setFunc = function(value)
                        self.savedVars.emoteWheel.slot3 = value
                        self:UpdateEmotePadLabels()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = self:CC_L("EMOTE_SLOT_4"),
                    tooltip = self:CC_L("EMOTE_SLOT_TOOLTIP"),
                    choices = emotePackChoices,
                    choicesValues = emotePackValues,
                    getFunc = function()
                        return self.savedVars.emoteWheel.slot4 or "respectful"
                    end,
                    setFunc = function(value)
                        self.savedVars.emoteWheel.slot4 = value
                        self:UpdateEmotePadLabels()
                    end,
                    width = "full",
                },
            },
        },


        --- CAMERA SETTINGS

        {
            type = "submenu",
            name = self:CC_L("CAMERA_SETTINGS"),
            controls = {
                {
                    type = "checkbox",
                    name = self:CC_L("ENABLE_UI_SETTINGS"),
                    tooltip = self:CC_L("ENABLE_UI_SETTINGS_TOOLTIP"),
                    getFunc = function()
                        return CinematicCam.savedVars.interface.usingModTweaks
                    end,
                    setFunc = function(value)
                        CinematicCam.savedVars.interface.usingModTweaks = value
                        if value == true then
                            CinematicCam:UpdateUIVisibility()
                        else
                            CinematicCam.reloadUI = true
                        end
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = self:CC_L("SHOW_COMPASS"),

                    choices = {
                        self:CC_L("ALWAYS"),
                        self:CC_L("NEVER"),
                        self:CC_L("COMBAT_ONLY"),
                        self:CC_L("WEAPONS_DRAWN")
                    },
                    choicesValues = { "always", "never", "combat", "weapons" },
                    getFunc = function() return self.savedVars.interface.hideCompass end,
                    setFunc = function(value)
                        self.savedVars.interface.hideCompass = value
                        CinematicCam:UpdateCompassVisibility()
                        self.pendingUIRefresh = true
                    end,
                    disabled = function() return not CinematicCam.savedVars.interface.usingModTweaks end,
                },
                {
                    type = "dropdown",
                    name = self:CC_L("SHOW_SKILL_BAR"),

                    choices = {
                        self:CC_L("ALWAYS"),
                        self:CC_L("NEVER"),
                        self:CC_L("COMBAT_ONLY"),
                        self:CC_L("WEAPONS_DRAWN")
                    },
                    choicesValues = { "always", "never", "combat", "weapons" },
                    getFunc = function() return self.savedVars.interface.hideActionBar end,
                    setFunc = function(value)
                        self.savedVars.interface.hideActionBar = value
                        CinematicCam:UpdateActionBarVisibility()
                        self.pendingUIRefresh = true
                    end,
                    disabled = function() return not CinematicCam.savedVars.interface.usingModTweaks end,
                },
                {
                    type = "dropdown",
                    name = self:CC_L("SHOW_RETICLE"),

                    choices = {
                        self:CC_L("ALWAYS"),
                        self:CC_L("NEVER"),
                        self:CC_L("COMBAT_ONLY"),
                        self:CC_L("WEAPONS_DRAWN")
                    },
                    choicesValues = { "always", "never", "combat", "weapons" },
                    getFunc = function() return self.savedVars.interface.hideReticle end,
                    setFunc = function(value)
                        self.savedVars.interface.hideReticle = value
                        CinematicCam:UpdateReticleVisibility()
                        self.pendingUIRefresh = true
                    end,
                    disabled = function() return not CinematicCam.savedVars.interface.usingModTweaks end,
                },
                {
                    type = "dropdown",
                    name = self:CC_L("SHOW_HEALTH_BARS"),

                    choices = {
                        self:CC_L("ALWAYS"),
                        self:CC_L("NEVER"),
                        self:CC_L("COMBAT_ONLY"),
                        self:CC_L("WEAPONS_DRAWN")
                    },
                    choicesValues = { "always", "never", "combat", "weapons" },
                    getFunc = function() return self.savedVars.interface.hideHealthBars end,
                    setFunc = function(value)
                        self.savedVars.interface.hideHealthBars = value
                        CinematicCam:UpdateHealthBarsVisibility()
                        self.pendingUIRefresh = true
                    end,
                    disabled = function() return not CinematicCam.savedVars.interface.usingModTweaks end,
                },
            },
        },

        {

            type = "submenu",
            name = self:CC_L("BLACK_BARS"),
            controls = {
                {
                    type = "button",
                    name = self:CC_L("TOGGLE_BLACK_BARS"),
                    tooltip = self:CC_L("TOGGLE_BLACK_BARS_TOOLTIP"),
                    func = function()
                        self:ToggleLetterbox()
                    end,
                    width = "half",
                },
                {
                    type = "checkbox",
                    name = self:CC_L("AUTO_BLACK_BARS_DIALOGUE"),
                    tooltip = self:CC_L("AUTO_BLACK_BARS_DIALOGUE_TOOLTIP"),
                    getFunc = function() return self.savedVars.interaction.auto.autoLetterboxDialogue end,
                    setFunc = function(value)
                        self.savedVars.interaction.auto.autoLetterboxDialogue = value
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = self:CC_L("AUTO_BLACK_BARS_MOUNT"),
                    tooltip = self:CC_L("AUTO_BLACK_BARS_MOUNT_TOOLTIP"),
                    getFunc = function() return CinematicCam.savedVars.letterbox.autoLetterboxMount end,
                    setFunc = function(value) CinematicCam.savedVars.letterbox.autoLetterboxMount = value end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = self:CC_L("MOUNT_BLACK_BARS_DELAY"),
                    tooltip = self:CC_L("MOUNT_BLACK_BARS_DELAY_TOOLTIP"),
                    min = 0,
                    max = 60,
                    step = 20,
                    getFunc = function() return CinematicCam.savedVars.letterbox.mountLetterboxDelay end,
                    setFunc = function(value)
                        CinematicCam.savedVars.letterbox.mountLetterboxDelay = value
                    end,
                    disabled = function() return not CinematicCam.savedVars.letterbox.autoLetterboxMount end,
                    width = "full",
                },

                {
                    type = "slider",
                    name = self:CC_L("BLACK_BARS_SIZE"),
                    tooltip = self:CC_L("BLACK_BARS_SIZE_TOOLTIP"),
                    min = 10,
                    max = 300,
                    step = 5,
                    getFunc = function() return self.savedVars.letterbox.size end,
                    setFunc = function(value)
                        self.savedVars.letterbox.size = value
                        if not CinematicCam_LetterboxTop:IsHidden() then
                            CinematicCam_LetterboxTop:SetHeight(value)
                            CinematicCam_LetterboxBottom:SetHeight(value)
                        end
                    end,
                    width = "full",
                },
            },
        },


        {
            type = "submenu",
            name = self:CC_L("DEPTH_OF_FIELD"), -- Line 653
            controls = {
                {
                    type = "checkbox",
                    name = self:CC_L("AUTO_DEPTH_OF_FIELD"),
                    tooltip = self:CC_L("AUTO_DEPTH_OF_FIELD_TOOLTIP"),
                    getFunc = function() return self.savedVars.interaction.depthOfField.enabled end,
                    setFunc = function(value)
                        self.savedVars.interaction.depthOfField.enabled = value
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = self:CC_L("FOCAL_POINT"),
                    tooltip = self:CC_L("FOCAL_POINT_TOOLTIP"),
                    min = 0,
                    max = 5,
                    step = 0.1,
                    getFunc = function() return self.savedVars.interaction.depthOfField.param1 end,
                    setFunc = function(value)
                        self.savedVars.interaction.depthOfField.param1 = value

                        -- Apply effect immediately for preview
                        local param2 = self.savedVars.interaction.depthOfField.param2
                        SetFullscreenEffect(FULLSCREEN_EFFECT_CHARACTER_FRAMING_BLUR, value, param2, true)

                        -- Clear any existing timer
                        if self.dofPreviewTimer then
                            zo_removeCallLater(self.dofPreviewTimer)
                        end

                        -- Set new timer to clear effect after delay
                        self.dofPreviewTimer = zo_callLater(function()
                            SetFullscreenEffect(FULLSCREEN_EFFECT_NONE, 0, 0, true)
                            self.dofPreviewTimer = nil
                        end, 2000)
                    end,
                    disabled = function() return not self.savedVars.interaction.depthOfField.enabled end,
                    width = "full",
                },

            },
        },




        {
            type = "description",
            text = self:CC_L("SLASH_COMMANDS"),
            width = "full"
        },


        {
            type = "submenu",
            name = self:CC_L("DONATIONS"),
            controls = {
                {
                    type = "description",
                    text = self:CC_L("AUTHOR"),
                    width = "full"
                },
                {
                    type = "description",
                    text = self:CC_L("SUPPORT_TEXT"),
                    width = "full"
                },
                {
                    type = "button",
                    name = self:CC_L("PAYPAL"),
                    tooltip = self:CC_L("PAYPAL_TOOLTIP"),
                    func = function() RequestOpenUnsafeURL("https://paypal.me/yfnatey") end,
                    width = "half"
                },
            },
        },

    }

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsData)
end

---=============================================================================

function CinematicCam:ConvertFromScreenCoordinates(pixelY)
    -- Convert absolute pixels back to normalized range
    local screenHeight = GuiRoot:GetHeight()
    return pixelY / screenHeight
end

---
-- Converts normalized (0-1) X and Y coordinates to actual screen coordinates.
-- Used for positioning UI elements relative to the screen size and user settings.
-- @param normalizedX number: X position as a value between 0 and 1
-- @param normalizedY number: Y position as a value between 0 and 1
-- @return number, number: The calculated screen X and Y positions
function CinematicCam:ConvertToScreenCoordinates(normalizedX, normalizedY)
    local screenWidth = GuiRoot:GetWidth()
    local screenHeight = GuiRoot:GetHeight()

    local targetX = 0 -- Default to center for X
    local targetY = 0 -- Default to center for Y

    if normalizedX then
        -- Convert 0-1 range to actual screen position
        -- 0.5 (50%) should be center (0 offset)
        -- 0.0 (0%) should be left, 1.0 (100%) should be right
        targetX = (normalizedX - 0.5) * screenWidth * 0.8 -- 0.8 to keep within reasonable bounds
    end

    if normalizedY then
        -- Cinematic uses a fixed offset from center
        if self.savedVars.interaction.layoutPreset == "cinematic" then
            targetY = (normalizedY - 0.5) * screenHeight * 0.8
        else
            -- For default preset, match your existing logic
            targetY = (normalizedY * screenHeight) - (screenHeight / 2)
        end
    end

    return targetX, targetY
end

function CinematicCam:OnSubtitlePositionChanged(newX, newY)
    -- Update saved variables
    if newX then
        self.savedVars.interaction.subtitles.posX = newX
    end
    if newY then
        self.savedVars.interaction.subtitles.posY = newY
    end


    local interactionType = GetInteractionType()
    if interactionType ~= INTERACTION_NONE then
        self:ApplySubtitlePosition()
        if CinematicCam.chunkedDialogueData.isActive then
            self:ApplyChunkedTextPositioning()
        end
    end
end

local previewTimer = nil
local isPreviewActive = false

---=============================================================================
-- Subtitle Preview
--=============================================================================
-- Initialize preview system
function CinematicCam:InitializePreviewSystem()
    -- Ensure preview containers start hidden
    if CinematicCam_PreviewContainer then
        CinematicCam_PreviewContainer:SetHidden(true)
    end

    if CinematicCam_PlayerOptionsPreviewContainer then
        CinematicCam_PlayerOptionsPreviewContainer:SetHidden(true)
    end

    -- Register for scene changes to hide preview when settings close
    local function hidePreviewOnSceneChange()
        self:HideSubtitlePreview()
    end

    -- Hook into various scene changes that might close settings
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
        if newState == SCENE_HIDING or newState == SCENE_HIDDEN then
            hidePreviewOnSceneChange()
        end
    end)
end

function CinematicCam:ShowSubtitlePreview(xPosition, yPosition)
    if not CinematicCam_PreviewContainer or not CinematicCam_PreviewText or not CinematicCam_PreviewBackground then
        return
    end

    isPreviewActive = true

    -- Convert percentage to screen coordinates
    local normalizedX = xPosition and (xPosition / 100) or (self.savedVars.interaction.subtitles.posX or 0.5)
    local normalizedY = yPosition and (yPosition / 100) or (self.savedVars.interaction.subtitles.posY or 0.7)

    local targetX, targetY = self:ConvertToScreenCoordinates(normalizedX, normalizedY)

    -- Position the background box
    CinematicCam_PreviewBackground:ClearAnchors()
    CinematicCam_PreviewBackground:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)

    -- Set background properties with the texture
    CinematicCam_PreviewBackground:SetColor(1, 1, 1, 0.8)
    CinematicCam_PreviewBackground:SetDrawLayer(DL_CONTROLS)
    CinematicCam_PreviewBackground:SetDrawLevel(5)

    -- Position the preview text
    CinematicCam_PreviewText:ClearAnchors()
    CinematicCam_PreviewText:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)

    -- Set preview text properties
    CinematicCam_PreviewText:SetColor(1, 1, 1, 1) -- White text
    CinematicCam_PreviewText:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    CinematicCam_PreviewText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    CinematicCam_PreviewText:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    CinematicCam_PreviewText:SetText("Preview")

    -- Apply current font settings to preview
    local fontString = self:BuildUserFontString()
    CinematicCam_PreviewText:SetFont(fontString)

    -- Show the preview container
    CinematicCam_PreviewContainer:SetHidden(false)
    CinematicCam_PreviewBackground:SetHidden(false)
    CinematicCam_PreviewText:SetHidden(false)

    -- Clear any existing timer
    if previewTimer then
        zo_removeCallLater(previewTimer)
    end

    -- Auto-hide preview after 3 seconds
    previewTimer = zo_callLater(function()
        self:HideSubtitlePreview()
    end, 3000)
end

function CinematicCam:HideSubtitlePreview()
    if not isPreviewActive then
        return
    end

    isPreviewActive = false

    -- Clear timer
    if previewTimer then
        zo_removeCallLater(previewTimer)
        previewTimer = nil
    end

    -- Hide preview elements
    if CinematicCam_PreviewContainer then
        CinematicCam_PreviewContainer:SetHidden(true)
    end
    if CinematicCam_PreviewBackground then
        CinematicCam_PreviewBackground:SetHidden(true)
    end
    if CinematicCam_PreviewText then
        CinematicCam_PreviewText:SetHidden(true)
    end
end

function CinematicCam:UpdatePreviewPosition(xPosition, yPosition)
    if isPreviewActive then
        -- Update position in real-time while slider is being moved
        local normalizedX = xPosition and (xPosition / 100) or (self.savedVars.interaction.subtitles.posX or 0.5)
        local normalizedY = yPosition and (yPosition / 100) or (self.savedVars.interaction.subtitles.posY or 0.7)

        local targetX, targetY = self:ConvertToScreenCoordinates(normalizedX, normalizedY)

        if CinematicCam_PreviewBackground then
            CinematicCam_PreviewBackground:ClearAnchors()
            CinematicCam_PreviewBackground:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
        end

        if CinematicCam_PreviewText then
            CinematicCam_PreviewText:ClearAnchors()
            CinematicCam_PreviewText:SetAnchor(CENTER, GuiRoot, CENTER, targetX, targetY)
        end

        -- Reset the auto-hide timer
        if previewTimer then
            zo_removeCallLater(previewTimer)
        end
        previewTimer = zo_callLater(function()
            self:HideSubtitlePreview()
        end, 3000)
    end
end

---=============================================================================
-- Backgrounds
--=============================================================================
function CinematicCam:ApplyDefaultBackgroundSettings(backgroundMode)
    if backgroundMode == "esoDefault" then
        self.savedVars.interaction.ui.hidePanelsESO = false
        self:ShowDialoguePanels()
    elseif backgroundMode == "none" then
        self.savedVars.interaction.ui.hidePanelsESO = true
        self:HideDialoguePanels()
    end
end

function CinematicCam:ApplyCinematicBackgroundSettings(backgroundMode)
    self.savedVars.interface.useSubtitleBackground = (backgroundMode == "subtitles" or backgroundMode == "kingdom")
    self.savedVars.interface.usePlayerOptionsBackground = false -- Removed player options background for simplicity

    -- Update the active background control
    self:SetActiveBackgroundControl()
end

function CinematicCam:GetCurrentBackgroundMode()
    local layoutPreset = self.savedVars.interaction.layoutPreset

    if layoutPreset == "default" then
        return self.savedVars.interface.defaultBackgroundMode or "esoDefault"
    else
        return self.savedVars.interface.cinematicBackgroundMode or "all"
    end
end

function CinematicCam:ShouldShowSubtitleBackground()
    local layoutPreset = self.savedVars.interaction.layoutPreset

    -- Only show alternate backgrounds in cinematic mode
    if layoutPreset ~= "cinematic" then
        return false
    end

    local backgroundMode = self.savedVars.interface.cinematicBackgroundMode or "subtitles"
    return backgroundMode == "subtitles" or backgroundMode == "kingdom" or backgroundMode == "redemption_banner"
end

function CinematicCam:ShouldShowPlayerOptionsBackground()
    local layoutPreset = self.savedVars.interaction.layoutPreset

    -- Only show alternate backgrounds in cinematic mode
    if layoutPreset ~= "cinematic" then
        return false
    end

    local backgroundMode = self.savedVars.interface.cinematicBackgroundMode or "all"
    return backgroundMode == "all" or backgroundMode == "playerOptions"
end

function CinematicCam:RefreshDialogueBackgrounds()
    -- Update subtitle background
    local subtitleBackground = CinematicCam.chunkedDialogueData.backgroundControl
    if subtitleBackground then
        if self:ShouldShowSubtitleBackground() and CinematicCam.chunkedDialogueData.isActive then
            subtitleBackground:SetHidden(false)
            self:ResizeBackgroundToText()
        else
            subtitleBackground:SetHidden(true)
        end
    end

    -- Update player options background
    local playerOptionsBackground = CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl
    if playerOptionsBackground then
        if self:ShouldShowPlayerOptionsBackground() then
            self:ShowPlayerOptionsBackground()
            self:UpdatePlayerOptionsBackgroundSize()
        else
            self:HidePlayerOptionsBackground()
        end
    end
end

function CinematicCam:ShowPlayerOptionsBackground()
    local background = CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl
    if background and self:ShouldShowPlayerOptionsBackground() then
        background:SetHidden(false)
        self:UpdatePlayerOptionsBackgroundSize()
    end
end

function CinematicCam:HidePlayerOptionsBackground()
    local background = CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl
    if background then
        background:SetHidden(true)
    end
end

function CinematicCam:UpdatePlayerOptionsBackgroundSize()
    local background = CinematicCam.chunkedDialogueData.playerOptionsBackgroundControl
    if not background or not self:ShouldShowPlayerOptionsBackground() then
        return
    end

    -- Find player options container to size background appropriately
    local playerOptionsContainer = _G["ZO_InteractWindow_GamepadContainerInteract"]
    if playerOptionsContainer and not playerOptionsContainer:IsHidden() then
        local width, height = playerOptionsContainer:GetDimensions()
        local padding = 30

        background:ClearAnchors()
        background:SetAnchor(CENTER, playerOptionsContainer, CENTER, 0, 0)
        background:SetDimensions(width + padding, height + padding)
        background:SetHidden(false)
    end
end

function CinematicCam:OnLayoutPresetChanged(newPreset)
    local currentBackgroundMode = self.savedVars.interface.backgroundMode

    if newPreset == "default" then
        if currentBackgroundMode ~= "esoDefault" and currentBackgroundMode ~= "none" then
            self.savedVars.interface.backgroundMode = "esoDefault"
        end
    elseif newPreset == "cinematic" then
        if currentBackgroundMode == "esoDefault" then
            self.savedVars.interface.backgroundMode = "all"
        end
    end

    self:ApplyBackgroundSettings()
    local interactionType = GetInteractionType()
    if interactionType ~= INTERACTION_NONE then
        zo_callLater(function()
            self:RefreshDialogueBackgrounds()
        end, 50)
    end
end

function CinematicCam:SetActiveBackgroundControl()
    local backgroundMode = self.savedVars.interface.cinematicBackgroundMode or "subtitles"
    local backgroundNormal = _G["CinematicCam_ChunkedTextBackground"]
    local backgroundKingdom = _G["CinematicCam_ChunkedTextBackground_Kingdom"]

    -- Hide both backgrounds first
    if backgroundNormal then backgroundNormal:SetHidden(true) end
    if backgroundKingdom then backgroundKingdom:SetHidden(true) end

    -- Set the active background control
    if backgroundMode == "kingdom" or backgroundMode == "redemption_banner" then
        CinematicCam.chunkedDialogueData.backgroundControl = backgroundKingdom
    else
        CinematicCam.chunkedDialogueData.backgroundControl = backgroundNormal
    end
end

---=============================================================================
-- Emote Wheel Tooltip for Settings
---=============================================================================

function CinematicCam:InitializeEmoteTooltip()
    self.emoteTooltipControl = _G["CinematicCam_Settings_EmoteTooltip"]

    if not self.emoteTooltipControl then
        return
    end

    -- Cache child controls
    self.emoteTooltipControls = {
        xboxLT = _G["CinematicCam_Settings_EmoteTooltip_IconContainer_XboxLT"],
        ps4LT = _G["CinematicCam_Settings_EmoteTooltip_IconContainer_PS4LT"],
        xboxLS = _G["CinematicCam_Settings_EmoteTooltip_IconContainer_LeftStickContainer_Slide"],
        xboxLSScroll = _G["CinematicCam_Settings_EmoteTooltip_IconContainer_LeftStickContainer_Scroll"],
        ps4LS = _G["CinematicCam_Settings_EmoteTooltip_IconContainer_LeftStickContainer_PS4"],
        label = _G["CinematicCam_Settings_EmoteTooltip_Label"]
    }

    -- Set platform-specific icons
    self:UpdateEmoteTooltipPlatform()
end

function CinematicCam:UpdateEmoteTooltipPlatform()
    if not self.emoteTooltipControls then return end

    local isPlayStation = GetPlatformServiceType() == PLATFORM_SERVICE_TYPE_PSN

    if isPlayStation then
        -- Show PlayStation icons
        self.emoteTooltipControls.ps4LT:SetHidden(false)
        self.emoteTooltipControls.ps4LS:SetHidden(false)
        self.emoteTooltipControls.xboxLT:SetHidden(true)
        self.emoteTooltipControls.xboxLS:SetHidden(true)
        self.emoteTooltipControls.xboxLSScroll:SetHidden(true)
    else
        -- Show Xbox icons
        self.emoteTooltipControls.xboxLT:SetHidden(false)
        self.emoteTooltipControls.xboxLS:SetHidden(false)
        self.emoteTooltipControls.xboxLSScroll:SetHidden(false)
        self.emoteTooltipControls.ps4LT:SetHidden(true)
        self.emoteTooltipControls.ps4LS:SetHidden(true)
    end
end

function CinematicCam:GetEmoteWheelTooltipText()
    -- Build descriptive text for each slot
    local slot1 = self:CC_L("EMOTE_" .. string.upper(self.savedVars.emoteWheel.slot1))
    local slot2 = self:CC_L("EMOTE_" .. string.upper(self.savedVars.emoteWheel.slot2))
    local slot3 = self:CC_L("EMOTE_" .. string.upper(self.savedVars.emoteWheel.slot3))
    local slot4 = self:CC_L("EMOTE_" .. string.upper(self.savedVars.emoteWheel.slot4))

    return string.format(
        "%s\n\n%s: %s\n%s: %s\n%s: %s\n%s: %s",
        self:CC_L("EMOTE_WHEEL_DESC"),
        self:CC_L("SLOT_TOP"),
        slot1,
        self:CC_L("SLOT_RIGHT"),
        slot2,
        self:CC_L("SLOT_BOTTOM"),
        slot3,
        self:CC_L("SLOT_LEFT"),
        slot4
    )
end

function CinematicCam:ShowEmoteTooltip(anchorControl)
    if not self.emoteTooltipControl then
        self:InitializeEmoteTooltip()
    end

    if not self.emoteTooltipControl then
        return
    end

    -- Position tooltip relative to the setting control if provided
    self.emoteTooltipControl:ClearAnchors()
    if anchorControl then
        self.emoteTooltipControl:SetAnchor(TOPLEFT, anchorControl, BOTTOMLEFT, 0, 5)
    else
        -- Default center position
        self.emoteTooltipControl:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end

    -- Update platform-specific icons
    self:UpdateEmoteTooltipPlatform()

    -- Show the tooltip
    self.emoteTooltipControl:SetHidden(false)
end

function CinematicCam:HideEmoteTooltip()
    if self.emoteTooltipControl then
        self.emoteTooltipControl:SetHidden(true)
    end
end
