CinematicCam.presetPending = false
CinematicCam.vanillaPending = false
function CinematicCam:ApplyPresetSettings()
    -- Apply letterbox changes
    if self.savedVars.letterbox.letterboxVisible then
        self:ShowLetterbox()
    else
        self:HideLetterbox()
    end

    -- Apply font changes
    self:OnFontChanged()

    -- Apply layout changes
    local interactionType = GetInteractionType()
    if interactionType ~= INTERACTION_NONE then
        zo_callLater(function()
            self:ApplyDialogueRepositioning()
        end, 50)
    end

    -- Apply UI panel settings
    if self.savedVars.interaction.ui.hidePanelsESO then
        self:HideDialoguePanels()
    else
        self:ShowDialoguePanels()
    end

    -- Apply background settings
    self:SetActiveBackgroundControl()

    -- Update text colors for active dialogue if present
    if CinematicCam.chunkedDialogueData.isActive then
        self:ApplySubtitleTextColor()
    end

    -- Apply NPC name preset
    if interactionType ~= INTERACTION_NONE then
        self:ApplyNPCNamePreset()
    end

    -- Update visibility settings
    self:UpdateChunkedTextVisibility()
end

---=============================================================================
-- Custom Preset Slots - Simple 3-slot system
---=============================================================================

function CinematicCam:InitializeCustomPresets()
    if not self.savedVars.customPresets then
        self.savedVars.customPresets = {
            slot1 = { name = "Home", settings = nil },
            slot2 = { name = "Overland", settings = nil },
            slot3 = { name = "Dungeons/Trials", settings = nil }
        }
    end

    -- Ensure structure exists for old saves
    for i = 1, 3 do
        local slotKey = "slot" .. i
        if not self.savedVars.customPresets[slotKey] then
            self.savedVars.customPresets[slotKey] = {
                name = "Custom " .. i,
                settings = nil
            }
        end
    end
end

function CinematicCam:SaveToPresetSlot(slotNumber)
    local notification = _G["CinematicCam_UpdateNotification"]
    local notificationText = _G["CinematicCam_UpdateNotificationText"]
    if not notification then
        return
    end

    notification:SetHidden(false)
    notification:SetAlpha(0)
    notificationText:SetText("Cinematic Dialogue: Saved")

    -- Start fade in animation
    self:AnimateUpdateNotification(notification, true)

    -- Auto-hide wafter 5 seconds
    zo_callLater(function()
        self:HideUpdateNotification()
    end, 4000)
    local slotKey = "slot" .. slotNumber
    local slot = self.savedVars.customPresets[slotKey]

    if not slot then
        return false
    end

    -- Save all current settings
    slot.settings = {
        forceThirdPersonDialogue = self.savedVars.interaction.forceThirdPersonDialogue,
        forceThirdPersonVendor = self.savedVars.interaction.forceThirdPersonVendor,
        forceThirdPersonBank = self.savedVars.interaction.forceThirdPersonBank,
        forceThirdPersonCrafting = self.savedVars.interaction.forceThirdPersonCrafting,
        layoutPreset = self.savedVars.interaction.layoutPreset,
        defaultBackgroundMode = self.savedVars.interface.defaultBackgroundMode,
        cinematicBackgroundMode = self.savedVars.interface.cinematicBackgroundMode,
        letterboxVisible = self.savedVars.letterbox.letterboxVisible,
        letterboxSize = self.savedVars.letterbox.size,
        letterboxOpacity = self.savedVars.letterbox.opacity,
        autoLetterboxDialogue = self.savedVars.interaction.auto.autoLetterboxDialogue,
        autoLetterboxMount = self.savedVars.letterbox.autoLetterboxMount,
        mountLetterboxDelay = self.savedVars.letterbox.mountLetterboxDelay,
        selectedFont = self.savedVars.interface.selectedFont,
        customFontSize = self.savedVars.interface.customFontSize,
        subtitlesHidden = self.savedVars.interaction.subtitles.isHidden,
        useChunkedDialogue = self.savedVars.interaction.subtitles.useChunkedDialogue,
        hidePlayerOptionsUntilLastChunk = self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk,
        textColor = self.savedVars.interaction.subtitles.textColor,
        posX = self.savedVars.interaction.subtitles.posX,
        posY = self.savedVars.interaction.subtitles.posY,
        npcNamePreset = self.savedVars.npcNamePreset,
        npcNameColor = self.savedVars.npcNameColor,
        hidePanelsESO = self.savedVars.interaction.ui.hidePanelsESO,
        hideCompass = self.savedVars.interface.hideCompass,
        hideActionBar = self.savedVars.interface.hideActionBar,
        hideReticle = self.savedVars.interface.hideReticle,
        hideHealthBar = self.savedVars.interface.hideHealthBar,
        hideCompassWhenWeaponsSheathed = self.savedVars.interface.hideCompassWhenWeaponsSheathed,
        hideActionBarWhenWeaponsSheathed = self.savedVars.interface.hideActionBarWhenWeaponsSheathed,
        hideReticleWhenWeaponsSheathed = self.savedVars.interface.hideReticleWhenWeaponsSheathed,
        hideHealthBarWhenWeaponsSheathed = self.savedVars.interface.hideHealthBarWhenWeaponsSheathed
    }


    return true
end

function CinematicCam:LoadFromPresetSlot(slotNumber)
    local slotKey = "slot" .. slotNumber
    local slot = self.savedVars.customPresets[slotKey]

    if not slot or not slot.settings then
        return false
    end

    local preset = slot.settings

    -- Apply all saved settings
    self.savedVars.interaction.forceThirdPersonDialogue = preset.forceThirdPersonDialogue
    self.savedVars.letterbox.letterboxVisible = preset.letterboxVisible
    self.savedVars.letterbox.size = preset.letterboxSize
    self.savedVars.letterbox.opacity = preset.letterboxOpacity
    self.savedVars.interaction.forceThirdPersonVendor = preset.forceThirdPersonVendor
    self.savedVars.interaction.forceThirdPersonBank = preset.forceThirdPersonBank
    self.savedVars.interaction.forceThirdPersonCrafting = preset.forceThirdPersonCrafting
    self.savedVars.interaction.layoutPreset = preset.layoutPreset
    self.savedVars.interface.defaultBackgroundMode = preset.defaultBackgroundMode
    self.savedVars.interaction.auto.autoLetterboxDialogue = preset.autoLetterboxDialogue
    self.savedVars.letterbox.autoLetterboxMount = preset.autoLetterboxMount
    self.savedVars.letterbox.mountLetterboxDelay = preset.mountLetterboxDelay

    self.savedVars.interaction.subtitles.isHidden = preset.subtitlesHidden
    self.savedVars.interaction.subtitles.useChunkedDialogue = preset.useChunkedDialogue
    self.savedVars.interaction.subtitles.hidePlayerOptionsUntilLastChunk = preset.hidePlayerOptionsUntilLastChunk

    self.savedVars.interaction.subtitles.posX = preset.posX
    self.savedVars.interaction.subtitles.posY = preset.posY
    self.savedVars.npcNamePreset = preset.npcNamePreset

    self.savedVars.interaction.ui.hidePanelsESO = preset.hidePanelsESO
    self.savedVars.interface.hideCompass = preset.hideCompass
    self.savedVars.interface.hideActionBar = preset.hideActionBar
    self.savedVars.interface.hideReticle = preset.hideReticle

    -- Load weapon sheathing settings (with fallbacks for older presets)
    if preset.hideCompassWhenWeaponsSheathed ~= nil then
        self.savedVars.interface.hideCompassWhenWeaponsSheathed = preset.hideCompassWhenWeaponsSheathed
    end
    if preset.hideActionBarWhenWeaponsSheathed ~= nil then
        self.savedVars.interface.hideActionBarWhenWeaponsSheathed = preset.hideActionBarWhenWeaponsSheathed
    end
    if preset.hideReticleWhenWeaponsSheathed ~= nil then
        self.savedVars.interface.hideReticleWhenWeaponsSheathed = preset.hideReticleWhenWeaponsSheathed
    end

    -- Apply the preset
    self.savedVars.interface.currentPreset = "custom:slot" .. slotNumber
    self:ApplyNPCNamePreset(preset.npcNamePreset)

    if preset.letterboxVisible then
        self:ShowLetterbox()
    else
        self:HideLetterbox()
    end

    CinematicCam:UpdateCompassVisibility()
    CinematicCam:UpdateActionBarVisibility()
    CinematicCam:UpdateReticleVisibility()

    if preset.hidePanelsESO then
        self:HideDialoguePanels()
    else
        self:ShowDialoguePanels()
    end

    zo_callLater(function()
        self:ApplyDialogueRepositioning()
        self:InitializeInteractionSettings()
        self:OnFontChanged()
    end, 50)

    CinematicCam.presetPending = true

    return true
end

function CinematicCam:ClearPresetSlot(slotNumber)
    local slotKey = "slot" .. slotNumber
    local slot = self.savedVars.customPresets[slotKey]

    if slot then
        slot.settings = nil

        return true
    end
    return false
end

function CinematicCam:RenamePresetSlot(slotNumber, newName)
    local slotKey = "slot" .. slotNumber
    local slot = self.savedVars.customPresets[slotKey]
    if slotNumber == 1 then newName = "Home" end
    if slotNumber == 2 then newName = "Overland" end
    if slotNumber == 3 then newName = "Dungeons/Trials" end
    if not slot then
        return false
    end

    slot.name = newName
    return true
end

function CinematicCam:GetSlotDisplayName(slotNumber)
    -- Safety check
    if not self.savedVars or not self.savedVars.customPresets then
        return "○ Custom " .. slotNumber
    end

    local slotKey = "slot" .. slotNumber
    local slot = self.savedVars.customPresets[slotKey]

    -- Another safety check
    if not slot then
        return "○ Custom " .. slotNumber
    end

    local hasData = slot.settings ~= nil

    return slot.name
end

function CinematicCam:GetPresetTooltip(slotNumber)
    local slotKey = "slot" .. slotNumber
    local slot = self.savedVars.customPresets[slotKey]

    if not slot or not slot.settings then
        return "No settings saved for this preset"
    end

    local settings = slot.settings
    local tooltip = {}

    -- Header
    table.insert(tooltip,
        "|cFFD700" .. slot.name .. " Settings\n(You can also type /p" .. slotNumber .. " into chat)|r")
    table.insert(tooltip, "")


    -- Style settings
    table.insert(tooltip, "|cFFFFFF• Style:|r")
    local styleName = settings.layoutPreset == "cinematic" and "Cinematic" or "Default"
    table.insert(tooltip, "  - " .. styleName)

    table.insert(tooltip, "")

    -- Subtitle settings
    table.insert(tooltip, "|cFFFFFF• Subtitles:|r")
    if settings.subtitlesHidden then
        table.insert(tooltip, "  - |cF5F5F5Hidden|r")
    else
        table.insert(tooltip, "  - |c5A7D5AVisible|r")
        if settings.hidePlayerOptionsUntilLastChunk then
            table.insert(tooltip, "  - Hide choices until finished")
        end
    end

    table.insert(tooltip, "")

    local readableName = ""
    if settings.selectedFont == "ESO_Standard" then
        readableName = "Standard"
    elseif settings.selectedFont == "ESO_Bold" then
        readableName = "Bold"
    else
        readableName = "Handwritten"
    end
    -- Font settings
    table.insert(tooltip, "|cFFFFFF• Font:|r")
    table.insert(tooltip, "  - " .. readableName .. " (" .. settings.customFontSize .. ")")

    table.insert(tooltip, "")

    -- Cinematic UI settings
    table.insert(tooltip, "|cFFFFFF• UI Visibility:|r")

    local compassText = settings.hideCompass
    if compassText == "never" then
        table.insert(tooltip, "  - Compass: |cF5F5F5Never|r")
    elseif compassText == "combat" then
        table.insert(tooltip, "  - Compass: Combat Only")
    else
        table.insert(tooltip, "  - Compass: |c5A7D5AAlways|r")
    end

    local actionBarText = settings.hideActionBar
    if actionBarText == "never" then
        table.insert(tooltip, "  - Skill Bar: |cF5F5F5Never|r")
    elseif actionBarText == "combat" then
        table.insert(tooltip, "  - Skill Bar: Combat Only")
    else
        table.insert(tooltip, "  - Skill Bar: |c5A7D5AAlways|r")
    end

    local reticleText = settings.hideReticle
    if reticleText == "never" then
        table.insert(tooltip, "  - Reticle: |cF5F5F5Never|r")
    elseif reticleText == "combat" then
        table.insert(tooltip, "  - Reticle: Combat Only")
    else
        table.insert(tooltip, "  - Reticle: |c5A7D5AAlways|r")
    end

    -- Weapon unsheathed overrides
    if settings.hideCompassWhenWeaponsSheathed or settings.hideActionBarWhenWeaponsSheathed or settings.hideReticleWhenWeaponsSheathed then
        table.insert(tooltip, "")
        table.insert(tooltip, "|cFFFFFF• Show When Weapons Unsheathed:|r")
        if settings.hideCompassWhenWeaponsSheathed then
            table.insert(tooltip, "  - Compass: |c5A7D5AEnabled|r")
        end
        if settings.hideActionBarWhenWeaponsSheathed then
            table.insert(tooltip, "  - Skill Bar: |c5A7D5AEnabled|r")
        end
        if settings.hideReticleWhenWeaponsSheathed then
            table.insert(tooltip, "  - Reticle: |c5A7D5AEnabled|r")
        end
    end

    -- Letterbox settings
    table.insert(tooltip, "|cFFFFFF• Black Bars:|r")
    if settings.letterboxVisible then
        table.insert(tooltip, "  - |c5A7D5AEnabled|r ")
    else
        table.insert(tooltip, "  - |cF5F5F5Disabled|r")
    end

    if settings.autoLetterboxDialogue then
        table.insert(tooltip, "  - Auto during dialogue")
    end

    if settings.autoLetterboxMount then
        table.insert(tooltip, "  - Auto on mount (" .. settings.mountLetterboxDelay .. "s delay)")
    end

    table.insert(tooltip, "")



    -- Apply To settings
    table.insert(tooltip, "|cFFFFFF• Apply To:|r")
    if settings.forceThirdPersonDialogue then
        table.insert(tooltip, "  - Citizens: |c5A7D5AEnabled|r")
    else
        table.insert(tooltip, "  - Citizens: |cF5F5F5Disabled|r")
    end

    if settings.forceThirdPersonVendor and settings.forceThirdPersonBank then
        table.insert(tooltip, "  - Merchants & Bankers: |c5A7D5AEnabled|r")
    else
        table.insert(tooltip, "  - Merchants & Bankers: |cF5F5F5Disabled|r")
    end

    if settings.forceThirdPersonCrafting then
        table.insert(tooltip, "  - Crafting Stations: |c5A7D5AEnabled|r")
    else
        table.insert(tooltip, "  - Crafting Stations: |cF5F5F5Disabled|r")
    end

    table.insert(tooltip, "")

    return table.concat(tooltip, "\n")
end
