function SoulBombardmentPatch.RegisterSettingsPanel()
    local HAS = LibHarvensAddonSettings
    if HAS == nil then
        d("Soul Bombardment Patch: LibHarvensAddonSettings not found. Install it to use settings panel.")
        return
    end
    if SoulBombardmentPatch.settingsPanel ~= nil then
        return
    end

    local panel = HAS:AddAddon("Soul Bombardment Patch", {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            SoulBombardmentPatch.SetTrackerEnabled(SoulBombardmentPatch.defaultSettings.trackerEnabled)
            SoulBombardmentPatch.SetIndicatorOffsetX(SoulBombardmentPatch.defaultSettings.indicatorOffsetX)
            SoulBombardmentPatch.SetIndicatorOffsetY(SoulBombardmentPatch.defaultSettings.indicatorOffsetY)
            SoulBombardmentPatch.SetPlayStartSound(SoulBombardmentPatch.defaultSettings.playStartSound)
            SoulBombardmentPatch.SetJoystickRepositioningEnabled(SoulBombardmentPatch.defaultSettings.enableJoystickRepositioning)
        end,
    })
    if panel == nil then
        return
    end

    SoulBombardmentPatch.settingsPanel = panel
    local function hasRightAnalog()
        return SoulBombardmentPatch.CanReadRightStickDirectionalInput()
    end

    local function isJoystickToggleDisabled()
        return (not SoulBombardmentPatch.CanUseJoystickRepositioning()) or (not hasRightAnalog())
    end

    panel:AddSetting({
        type = HAS.ST_SECTION,
        label = "Options",
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Enable Soul Bombardment Tracker",
        tooltip = "Enable the tracker.",
        default = SoulBombardmentPatch.defaultSettings.trackerEnabled,
        getFunction = function()
            return SoulBombardmentPatch.trackerEnabled
        end,
        setFunction = function(value)
            SoulBombardmentPatch.SetTrackerEnabled(value)
        end,
    })
    if SoulBombardmentPatch.IsDevAccount() then
        panel:AddSetting({
            type = HAS.ST_LABEL,
            label = function()
                return "Mode: " .. SoulBombardmentPatch.GetTrackerModeText()
            end,
            tooltip = "Tracks Soul Essence Bombardment from Refracted Soul Essence with fixed filtered abilityId events.",
        })
    end
    panel:AddSetting({
        type = HAS.ST_SECTION,
        label = "Soul Bombardment Timer Position",
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Enable Joystick Repositioning",
        tooltip = function()
            if not hasRightAnalog() then
                return "no right analog detected"
            end
            if not SoulBombardmentPatch.CanUseJoystickRepositioning() then
                return "Switch to gamepad mode to use right analog stick repositioning."
            end
            return "When enabled in gamepad UI, use right analog stick to move the timer. Toggle OFF when done to keep the saved position."
        end,
        default = SoulBombardmentPatch.defaultSettings.enableJoystickRepositioning,
        disable = function()
            return isJoystickToggleDisabled()
        end,
        getFunction = function()
            return SoulBombardmentPatch.joystickRepositioningEnabled
        end,
        setFunction = function(value)
            SoulBombardmentPatch.SetJoystickRepositioningEnabled(value)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_LABEL,
        label = function()
            if not hasRightAnalog() then
                return "Joystick Repositioning: no right analog detected"
            end
            if not SoulBombardmentPatch.CanUseJoystickRepositioning() then
                return "Joystick Repositioning: switch to gamepad mode to enable right analog repositioning."
            end
            return "Joystick Repositioning: Turn ON to move the timer, then turn OFF to finish and keep the saved position."
        end,
    })
    panel:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Horizontal Offset (X)",
        tooltip = "Move the timer left or right. A preview appears while adjusting.",
        min = -1200,
        max = 1200,
        step = 1,
        format = "%d",
        default = SoulBombardmentPatch.defaultSettings.indicatorOffsetX,
        getFunction = function()
            return SoulBombardmentPatch.indicatorOffsetX
        end,
        setFunction = function(value)
            SoulBombardmentPatch.SetIndicatorOffsetX(value)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Vertical Offset (Y)",
        tooltip = "Move the timer up or down. A preview appears while adjusting.",
        min = -800,
        max = 800,
        step = 1,
        format = "%d",
        default = SoulBombardmentPatch.defaultSettings.indicatorOffsetY,
        getFunction = function()
            return SoulBombardmentPatch.indicatorOffsetY
        end,
        setFunction = function(value)
            SoulBombardmentPatch.SetIndicatorOffsetY(value)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_SECTION,
        label = "Audio",
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Play Sound On Start",
        tooltip = "Play a sound when Soul Essence Bombardment starts.",
        default = SoulBombardmentPatch.defaultSettings.playStartSound,
        getFunction = function()
            return SoulBombardmentPatch.playStartSound
        end,
        setFunction = function(value)
            SoulBombardmentPatch.SetPlayStartSound(value)
        end,
    })
end

function SoulBombardmentPatch.RefreshSettingsPanel()
    if SoulBombardmentPatch.settingsPanel ~= nil and SoulBombardmentPatch.settingsPanel.UpdateControls ~= nil then
        SoulBombardmentPatch.settingsPanel:UpdateControls()
    end
end

function SoulBombardmentPatch.OpenSettingsPanel()
    local HAS = LibHarvensAddonSettings
    local panel = SoulBombardmentPatch.settingsPanel
    if HAS == nil or panel == nil then
        d("Soul Bombardment Patch: settings panel unavailable. Use /sbp help for backup slash settings.")
        return
    end

    panel:Select()

    if IsConsoleUI() then
        SoulBombardmentPatch.EnsureJoystickRepositionSceneHook()
        SoulBombardmentPatch.RefreshJoystickRepositionMode()
        local scene = SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene")
        if scene ~= nil then
            SCENE_MANAGER:Push(scene:GetName())
        end
    end
end
