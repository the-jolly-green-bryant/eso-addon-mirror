function OsseinAssist.RegisterSettingsPanel()
    local HAS = LibHarvensAddonSettings
    if HAS == nil then
        d("Ossein Assist: LibHarvensAddonSettings not found. Install it to use settings panel.")
        return
    end
    if OsseinAssist.settingsPanel ~= nil then
        return
    end

    local function BuildHeavySettingTooltip(text)
        local tooltipFn = function(_, control)
            if control == nil then
                OsseinAssist.PokeHeavySettingsPreview()
                return text
            end
            OsseinAssist.StartHeavySettingsPreview()
            InitializeTooltip(InformationTooltip, control or GuiRoot, BOTTOMLEFT, 0, 0, TOPLEFT)
            SetTooltipText(InformationTooltip, text, ZO_TOOLTIP_INSTRUCTIONAL_COLOR)
            return function()
                OsseinAssist.StopHeavySettingsPreview()
                ClearTooltip(InformationTooltip)
            end
        end
        OsseinAssist.heavyTooltipFunctionLookup[tooltipFn] = true
        return tooltipFn
    end

    local function BuildHealthSettingTooltip(text, includeSearing)
        local tooltipFn = function(_, control)
            if control == nil then
                OsseinAssist.PokeHealthPanelPositionPreview(includeSearing)
                return text
            end
            OsseinAssist.StartHealthPanelPositionPreview(includeSearing)
            InitializeTooltip(InformationTooltip, control or GuiRoot, BOTTOMLEFT, 0, 0, TOPLEFT)
            SetTooltipText(InformationTooltip, text, ZO_TOOLTIP_INSTRUCTIONAL_COLOR)
            return function()
                OsseinAssist.StopHealthPanelPositionPreview()
                ClearTooltip(InformationTooltip)
            end
        end
        OsseinAssist.healthTooltipFunctionLookup[tooltipFn] = true
        return tooltipFn
    end

    local panel = HAS:AddAddon("Ossein Assist", {
        allowDefaults = true,
        allowRefresh = true,
        defaultsFunction = function()
            OsseinAssist.SetHealthPanelEnabled(OsseinAssist.defaultSettings.healthPanelEnabled)
            OsseinAssist.SetHealthPanelShowTitleEnabled(OsseinAssist.defaultSettings.healthPanelShowTitle)
            OsseinAssist.SetHealthPanelShowBossHealthEnabled(OsseinAssist.defaultSettings.healthPanelShowBossHealth)
            OsseinAssist.SetHealthPanelShowDragonHealthEnabled(OsseinAssist.defaultSettings.healthPanelShowDragonHealth)
            OsseinAssist.SetTitanHealthLoggingEnabled(OsseinAssist.defaultSettings.titanHealthLoggingEnabled)
            OsseinAssist.SetTitanHealthFakeDataEnabled(OsseinAssist.defaultSettings.titanHealthFakeDataEnabled)
            OsseinAssist.SetSearingCastLoggingEnabled(OsseinAssist.defaultSettings.searingCastLoggingEnabled)
            OsseinAssist.SetShowSearingAssignmentOnPanel(OsseinAssist.defaultSettings.showSearingAssignmentOnPanel)
            OsseinAssist.SetSearingAssignment(OsseinAssist.defaultSettings.searingAssignment)
            OsseinAssist.SetIncludeFirstSearingCurse(OsseinAssist.defaultSettings.includeFirstSearingCurse)
            OsseinAssist.SetHealthPanelOffsetX(OsseinAssist.defaultSettings.healthPanelOffsetX)
            OsseinAssist.SetHealthPanelOffsetY(OsseinAssist.defaultSettings.healthPanelOffsetY)
            OsseinAssist.SetHealthPanelTextSize(OsseinAssist.defaultSettings.healthPanelTextSize)
            OsseinAssist.SetBossHealthChatLoggingEnabled(OsseinAssist.defaultSettings.bossHealthChatLoggingEnabled)
            OsseinAssist.SetTitanHealthChatLoggingEnabled(OsseinAssist.defaultSettings.titanHealthChatLoggingEnabled)
            OsseinAssist.SetAspectHeavyChatLoggingEnabled(OsseinAssist.defaultSettings.aspectHeavyChatLoggingEnabled)
            OsseinAssist.SetSearingMechanicChatLoggingEnabled(OsseinAssist.defaultSettings.searingMechanicChatLoggingEnabled)
            OsseinAssist.SetHeavyIndicatorOffsetX(OsseinAssist.defaultSettings.heavyIndicatorOffsetX)
            OsseinAssist.SetHeavyIndicatorOffsetY(OsseinAssist.defaultSettings.heavyIndicatorOffsetY)
            OsseinAssist.SetBashVisualsEnabled(OsseinAssist.defaultSettings.enableBashVisuals)
            OsseinAssist.SetHeavyStartSoundEnabled(OsseinAssist.defaultSettings.playHeavyStartSound)
            OsseinAssist.SetStartupBarTestEnabled(OsseinAssist.defaultSettings.runStartupBarTest)
        end,
    })
    if panel == nil then
        return
    end
    OsseinAssist.settingsPanel = panel

    panel:AddSetting({
        type = HAS.ST_SECTION,
        label = "UI",
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Enable Health Tracker",
        tooltip = "Show the Bosses/Titans health.",
        default = OsseinAssist.defaultSettings.healthPanelEnabled,
        getFunction = function()
            return OsseinAssist.healthPanelEnabled
        end,
        setFunction = function(value)
            OsseinAssist.SetHealthPanelEnabled(value)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Enable Title",
        tooltip = BuildHealthSettingTooltip("Show/hide the UI title row.", true),
        default = OsseinAssist.defaultSettings.healthPanelShowTitle,
        getFunction = function()
            return OsseinAssist.healthPanelShowTitle
        end,
        setFunction = function(value)
            OsseinAssist.SetHealthPanelShowTitleEnabled(value)
            OsseinAssist.StartHealthPanelPositionPreview(true)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Enable Boss Health",
        tooltip = BuildHealthSettingTooltip("Show/hide the boss health row.", true),
        default = OsseinAssist.defaultSettings.healthPanelShowBossHealth,
        getFunction = function()
            return OsseinAssist.healthPanelShowBossHealth
        end,
        setFunction = function(value)
            OsseinAssist.SetHealthPanelShowBossHealthEnabled(value)
            OsseinAssist.StartHealthPanelPositionPreview(true)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Enable Dragon Health",
        tooltip = BuildHealthSettingTooltip("Show/hide the dragon (titan) health row.", true),
        default = OsseinAssist.defaultSettings.healthPanelShowDragonHealth,
        getFunction = function()
            return OsseinAssist.healthPanelShowDragonHealth
        end,
        setFunction = function(value)
            OsseinAssist.SetHealthPanelShowDragonHealthEnabled(value)
            OsseinAssist.StartHealthPanelPositionPreview(true)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Show Dynamic Searing Assignment",
        tooltip = BuildHealthSettingTooltip("Show your assigned searing color (and number) as it changes throughout the fight.", true),
        default = OsseinAssist.defaultSettings.showSearingAssignmentOnPanel,
        getFunction = function()
            return OsseinAssist.showSearingAssignmentOnPanel
        end,
        setFunction = function(value)
            OsseinAssist.SetShowSearingAssignmentOnPanel(value)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_DROPDOWN,
        label = "Searing Assignment",
        tooltip = BuildHealthSettingTooltip("Choose your assigned slot. Not Assigned disables this feature.", true),
        items = OsseinAssist.searingAssignmentDropdownItems,
        default = OsseinAssist.defaultSettings.searingAssignment,
        getFunction = function()
            return OsseinAssist.searingAssignment
        end,
        setFunction = function(control, name, itemData)
            local selected = name
            local extra = itemData
            if selected == nil then
                selected = control
                extra = name
            end
            OsseinAssist.SetSearingAssignment(selected, extra)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Include first curse",
        tooltip = BuildHealthSettingTooltip("If enabled, first searing curse flips your assignment color. Default is off.", true),
        default = OsseinAssist.defaultSettings.includeFirstSearingCurse,
        getFunction = function()
            return OsseinAssist.includeFirstSearingCurse
        end,
        setFunction = function(value)
            OsseinAssist.SetIncludeFirstSearingCurse(value)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Health Panel X",
        tooltip = BuildHealthSettingTooltip("Horizontal offset from screen top-center.", true),
        min = -3000,
        max = 3000,
        step = 1,
        format = "%d",
        unit = " px",
        default = OsseinAssist.defaultSettings.healthPanelOffsetX,
        getFunction = function()
            return OsseinAssist.healthPanelOffsetX
        end,
        setFunction = function(value)
            OsseinAssist.SetHealthPanelOffsetX(value)
            OsseinAssist.StartHealthPanelPositionPreview(true)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Health Panel Y",
        tooltip = BuildHealthSettingTooltip("Vertical offset from screen top-center.", true),
        min = -3000,
        max = 3000,
        step = 1,
        format = "%d",
        unit = " px",
        default = OsseinAssist.defaultSettings.healthPanelOffsetY,
        getFunction = function()
            return OsseinAssist.healthPanelOffsetY
        end,
        setFunction = function(value)
            OsseinAssist.SetHealthPanelOffsetY(value)
            OsseinAssist.StartHealthPanelPositionPreview(true)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Health Text Size",
        tooltip = BuildHealthSettingTooltip("Shared text size for Bosses, Titans, and Searing rows.", true),
        min = 20,
        max = 60,
        step = 1,
        format = "%d",
        unit = " px",
        default = OsseinAssist.defaultSettings.healthPanelTextSize,
        getFunction = function()
            return OsseinAssist.healthPanelTextSize
        end,
        setFunction = function(value)
            OsseinAssist.SetHealthPanelTextSize(value)
            OsseinAssist.StartHealthPanelPositionPreview(true)
        end,
    })

    panel:AddSetting({
        type = HAS.ST_SECTION,
        label = "Aspect Heavy Tracker",
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Enable Heavy Timer",
        tooltip = "Show heavy timer for Aspects in portal.",
        default = OsseinAssist.defaultSettings.enableBashVisuals,
        getFunction = function()
            return OsseinAssist.enableBashVisuals
        end,
        setFunction = function(value)
            OsseinAssist.SetBashVisualsEnabled(value)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Play Sound On Aspect Heavy Start",
        tooltip = BuildHeavySettingTooltip("Play a sound when Aspect heavy cast begins."),
        default = OsseinAssist.defaultSettings.playHeavyStartSound,
        getFunction = function()
            return OsseinAssist.playHeavyStartSound
        end,
        setFunction = function(value)
            OsseinAssist.SetHeavyStartSoundEnabled(value)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Heavy Timer X",
        tooltip = BuildHeavySettingTooltip("Horizontal offset for heavy timer indicator."),
        min = -3000,
        max = 3000,
        step = 1,
        format = "%d",
        unit = " px",
        default = OsseinAssist.defaultSettings.heavyIndicatorOffsetX,
        getFunction = function()
            return OsseinAssist.heavyIndicatorOffsetX
        end,
        setFunction = function(value)
            OsseinAssist.SetHeavyIndicatorOffsetX(value)
            OsseinAssist.StartHeavySettingsPreview()
        end,
    })
    panel:AddSetting({
        type = HAS.ST_SLIDER,
        label = "Heavy Timer Y",
        tooltip = BuildHeavySettingTooltip("Vertical offset for heavy timer indicator."),
        min = -3000,
        max = 3000,
        step = 1,
        format = "%d",
        unit = " px",
        default = OsseinAssist.defaultSettings.heavyIndicatorOffsetY,
        getFunction = function()
            return OsseinAssist.heavyIndicatorOffsetY
        end,
        setFunction = function(value)
            OsseinAssist.SetHeavyIndicatorOffsetY(value)
            OsseinAssist.StartHeavySettingsPreview()
        end,
    })
    if OsseinAssist.IsDevUser() then
        panel:AddSetting({
            type = HAS.ST_SECTION,
            label = "Developer",
        })
        panel:AddSetting({
            type = HAS.ST_CHECKBOX,
            label = "Preview Settings as Non-Dev",
            tooltip = "Hide dev-only settings in this menu for testing. Reload UI after changing.",
            default = OsseinAssist.defaultSettings.devSettingsPreviewAsNonDev,
            getFunction = function()
                return OsseinAssist.devSettingsPreviewAsNonDev
            end,
            setFunction = function(value)
                OsseinAssist.devSettingsPreviewAsNonDev = value
                if OsseinAssist.savedVariables ~= nil then
                    OsseinAssist.savedVariables.devSettingsPreviewAsNonDev = value
                end
                d("Ossein Assist: dev settings preview updated. Reloading UI to rebuild the settings list.")
                if type(ReloadUI) == "function" then
                    ReloadUI()
                end
            end,
        })
        if OsseinAssist.ShouldShowDevOnlySettings() then
            panel:AddSetting({
                type = HAS.ST_CHECKBOX,
                label = "Use Fake Titan Damage Data",
                tooltip = "Use sample titan damage report/fight logs for display testing.",
                default = OsseinAssist.defaultSettings.titanHealthFakeDataEnabled,
                getFunction = function()
                    return OsseinAssist.titanHealthFakeDataEnabled
                end,
                setFunction = function(value)
                    OsseinAssist.SetTitanHealthFakeDataEnabled(value)
                end,
            })
            panel:AddSetting({
                type = HAS.ST_CHECKBOX,
                label = "Log Boss Health Chat",
                tooltip = "Dev-only chat logs for boss health tracking/debug.",
                default = OsseinAssist.defaultSettings.bossHealthChatLoggingEnabled,
                getFunction = function()
                    return OsseinAssist.bossHealthChatLoggingEnabled
                end,
                setFunction = function(value)
                    OsseinAssist.SetBossHealthChatLoggingEnabled(value)
                end,
            })
            panel:AddSetting({
                type = HAS.ST_CHECKBOX,
                label = "Log Titan Health Chat",
                tooltip = "Dev-only chat logs for titan health tracking/debug.",
                default = OsseinAssist.defaultSettings.titanHealthChatLoggingEnabled,
                getFunction = function()
                    return OsseinAssist.titanHealthChatLoggingEnabled
                end,
                setFunction = function(value)
                    OsseinAssist.SetTitanHealthChatLoggingEnabled(value)
                end,
            })
            panel:AddSetting({
                type = HAS.ST_CHECKBOX,
                label = "Log Aspect Heavy Chat",
                tooltip = "Dev-only chat logs for Aspect heavy tracking events.",
                default = OsseinAssist.defaultSettings.aspectHeavyChatLoggingEnabled,
                getFunction = function()
                    return OsseinAssist.aspectHeavyChatLoggingEnabled
                end,
                setFunction = function(value)
                    OsseinAssist.SetAspectHeavyChatLoggingEnabled(value)
                end,
            })
            panel:AddSetting({
                type = HAS.ST_CHECKBOX,
                label = "Log Searing Cast Mechanics",
                tooltip = "Dev-only chat log for cast starts: Jynorah Searing Sparks and Skorkhif Searing Blaze.",
                default = OsseinAssist.defaultSettings.searingCastLoggingEnabled,
                getFunction = function()
                    return OsseinAssist.searingCastLoggingEnabled
                end,
                setFunction = function(value)
                    OsseinAssist.SetSearingCastLoggingEnabled(value)
                end,
            })
            panel:AddSetting({
                type = HAS.ST_CHECKBOX,
                label = "Log Searing Mechanic Chat",
                tooltip = "Dev-only chat logs for searing mechanic events and pairing.",
                default = OsseinAssist.defaultSettings.searingMechanicChatLoggingEnabled,
                getFunction = function()
                    return OsseinAssist.searingMechanicChatLoggingEnabled
                end,
                setFunction = function(value)
                    OsseinAssist.SetSearingMechanicChatLoggingEnabled(value)
                end,
            })
            panel:AddSetting({
                type = HAS.ST_BUTTON,
                label = "Trigger Searing Mechanic Test",
                buttonText = "Trigger",
                tooltip = "Dev-only: simulate one searing mechanic fire to test assignment/color flipping.",
                clickHandler = function()
                    OsseinAssist.RunSearingMechanicTest()
                end,
            })
            panel:AddSetting({
                type = HAS.ST_CHECKBOX,
                label = "Run Startup Bar Test",
                tooltip = BuildHeavySettingTooltip("Play the startup bar animation when the addon initializes."),
                default = OsseinAssist.defaultSettings.runStartupBarTest,
                getFunction = function()
                    return OsseinAssist.runStartupBarTest
                end,
                setFunction = function(value)
                    OsseinAssist.SetStartupBarTestEnabled(value)
                end,
            })
        end
    end

    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Enable Titan Damage Logging",
        tooltip = "Track titan damage from:\nBlazing Heat Ray\nSparking Heat Ray\nTitanic Clash\nSeeking Spark Surge\nSpark Surge Inferno\nSeeking Forge Fire\nForge Fire Inferno",
        default = OsseinAssist.defaultSettings.titanHealthLoggingEnabled,
        getFunction = function()
            return OsseinAssist.titanHealthLoggingEnabled
        end,
        setFunction = function(value)
            OsseinAssist.SetTitanHealthLoggingEnabled(value)
        end,
    })
    panel:AddSetting({
        type = HAS.ST_SECTION,
        label = "Titan Damage Fight Logs (Latest 20)",
    })
    panel:AddSetting({
        type = HAS.ST_BUTTON,
        label = "Clear Logs",
        buttonText = "Clear",
        tooltip = "Clear log rows below.",
        clickHandler = function()
            OsseinAssist.RefreshSettingsPanel()
        end,
    })
    for index = 1, OsseinAssist.maxTitanFightLogs do
        panel:AddSetting({
            type = HAS.ST_LABEL,
            label = function()
                return OsseinAssist.GetTitanFightLogTitle(index)
            end,
            tooltip = function()
                return OsseinAssist.GetTitanFightLogDescription(index)
            end,
        })
    end
end

function OsseinAssist.RefreshSettingsPanel()
    if OsseinAssist.settingsPanel ~= nil and OsseinAssist.settingsPanel.UpdateControls ~= nil then
        OsseinAssist.settingsPanel:UpdateControls()
    end
end

function OsseinAssist.OpenSettingsPanel()
    local HAS = LibHarvensAddonSettings
    local panel = OsseinAssist.settingsPanel
    if HAS == nil or panel == nil then
        d("Ossein Assist: settings panel unavailable (LibHarvensAddonSettings missing).")
        return
    end

    panel:Select()

    if IsConsoleUI() then
        local scene = SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene")
        if scene ~= nil then
            SCENE_MANAGER:Push(scene:GetName())
        end
    end
end
