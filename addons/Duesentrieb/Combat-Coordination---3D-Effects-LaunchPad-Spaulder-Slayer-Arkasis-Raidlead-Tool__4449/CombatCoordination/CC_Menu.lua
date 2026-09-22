local CC = CombatCoordination
local LAM2 = LibAddonMenu2

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
CC.Menu = {
    PanelName = "",
    Previews = {},
    stringLGB = "|c00FF00[LGB]|r",

    Default = {},
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- SUBMENU TITLE
----------------------------------------------------------------------------------------------------
function CC.GetSubmenuHeader(ModuleObject)
    if not ModuleObject then return "" end

    local path = ModuleObject.iconPath
    local iconString = ""
    if path and path ~= "" then
        iconString = string.format("|t%d:%d:%s|t ", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, path)
    end

    local stringLGB = (ModuleObject.Broadcast ~= nil) and (" " .. CC.ColorString("[LGB]", "GN")) or ""
    local titleText = ModuleObject.menuName or ModuleObject.name or "Unknown Module"

    return string.format("%s%s%s", iconString, CC.ColorString(titleText, "tier2"), stringLGB)
end

----------------------------------------------------------------------------------------------------
-- MENU BLOCKS
----------------------------------------------------------------------------------------------------
function CC.CreateModuleSettings(self, menuName, iconPath)
    local ModuleControls = {}

    local hasDrawGroup = (self.Default.enableDrawGroup ~= nil)
    local stringLGB = (self.Broadcast ~= nil) and (" " .. CC.ColorString("[LGB]", "GN")) or ""

    -- FORMAT ICON
    local path = iconPath or self.iconPath
    local iconString = ""
    if path and path ~= "" then
        iconString = string.format("|t%d:%d:%s|t ", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, path)
    end

    -- ENABLE MODULE
    if self.Default.enableModule ~= nil then
        table.insert(ModuleControls, { type = "header", name = CC.ColorString("ENABLE / DISABLE MODULE", "tier3") })
        table.insert(ModuleControls, {
            type = "checkbox",
            name = CC.ColorString("Enable Module", "GN"),
            getFunc = function() return self.SV.enableModule end,
            setFunc = function(value)
                self.SV.enableModule = value
                if value then
                    if self.CustomEnable then self:CustomEnable() end
                else
                    if self.CustomDisable then self:CustomDisable() end
                end
            end,
            default = self.Default.enableModule,
            disabled = function() return not CC.SV.enableAddon end,
            requiresReload = true,
        })
        table.insert(ModuleControls, { type = "divider" })
    end

    table.insert(ModuleControls, {
        type = "description",
        text = "Timers, visuals and the skillblocker operate independently.\nNone of them require the others to function.",
        width = "full",
    })

    -- TIMER
    if self.Default.timerModeSelf ~= nil then
        table.insert(ModuleControls, { type = "header", name = CC.ColorString("TIMER", "tier3") })
        table.insert(ModuleControls, {
            type = "dropdown",
            name = hasDrawGroup and "Show Timer (Your Cast)" or "Show Timer (Duration)",
            choices = CC.TIMER_CHOICES,
            choicesValues = CC.TIMER_VALUES,
            getFunc = function() return self.SV.timerModeSelf end,
            setFunc = function(value) self.SV.timerModeSelf = value end,
            default = self.Default.timerModeSelf,
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
        })
    end

    if hasDrawGroup and self.Default.timerModeGroup ~= nil then
        table.insert(ModuleControls, {
            type = "dropdown",
            name = "Show Timer (Group Member Cast)",
            choices = CC.TIMER_CHOICES,
            choicesValues = CC.TIMER_VALUES,
            getFunc = function() return self.SV.timerModeGroup end,
            setFunc = function(value) self.SV.timerModeGroup = value end,
            default = self.Default.timerModeGroup,
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
        })
    end

    -- VISUALS CHECKBOX
    table.insert(ModuleControls, { type = "header", name = CC.ColorString("VISUALS", "tier3") })
    if self.Default.enableDrawSelf ~= nil then
        table.insert(ModuleControls, {
            type = "checkbox",
            name = hasDrawGroup and "Enable Visuals for Your Cast" or "Enable Visuals",
            getFunc = function() return self.SV.enableDrawSelf end,
            setFunc = function(value) self.SV.enableDrawSelf = value end,
            default = self.Default.enableDrawSelf,
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
        })
    end

    if hasDrawGroup then
        table.insert(ModuleControls, {
            type = "checkbox",
            name = "Enable Visuals for Group Member Cast",
            getFunc = function() return self.SV.enableDrawGroup end,
            setFunc = function(value) self.SV.enableDrawGroup = value end,
            default = self.Default.enableDrawGroup,
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
        })
    end

    table.insert(ModuleControls, { type = "divider" })

    table.insert(ModuleControls, {
        type = "description",
        text = CC.ColorString("Parameter:", "tier2") .. " Use " .. CC.ColorString("[Colorwheel Alpha]", "tier3") .. " to adjust transparency.\n" .. CC.ColorString("System Note:", "tier2") .. " Game AOE Color supersedes this setting.",
        width = "full",
    })

    -- COLOR(S)
    if self.Default.enableGameAoeFriendlyColor ~= nil then
        table.insert(ModuleControls, {
            type = "checkbox",
            name = "Enable Game AOE Color",
            getFunc = function() return self.SV.enableGameAoeFriendlyColor end,
            setFunc = function(value) self.SV.enableGameAoeFriendlyColor = value end,
            default = self.Default.enableGameAoeFriendlyColor,
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule or not self.SV.enableDrawSelf and (not hasDrawGroup or not self.SV.enableDrawGroup) end,
        })
    end

    if self.Default.ColorSelf ~= nil then
        table.insert(ModuleControls, {
            type = "colorpicker",
            name = hasDrawGroup and "Color (Your Cast)" or "Color",
            getFunc = function()
                return unpack(self.SV.ColorSelf)
            end,
            setFunc = function(r, g, b, a)
                self.SV.ColorSelf = {r, g, b, a}
                local Preview = CC.Menu.Previews[self.name]
                if Preview then
                    Preview:SetColor(r, g, b, a)
                end
            end,
            default = CC.GetRgbaFromArray(self.Default.ColorSelf),
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule or self.SV.enableGameAoeFriendlyColor or (not self.SV.enableDrawSelf and (not hasDrawGroup or not self.SV.enableDrawGroup)) end,
        })
    end

    if hasDrawGroup and self.Default.ColorGroup ~= nil then
        table.insert(ModuleControls, {
            type = "colorpicker",
            name = "Color (Group Member)",
            getFunc = function() return unpack(self.SV.ColorGroup) end,
            setFunc = function(r, g, b, a) self.SV.ColorGroup = {r, g, b, a} end,
            default = CC.GetRgbaFromArray(self.Default.ColorGroup),
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule or self.SV.enableGameAoeFriendlyColor or (not self.SV.enableDrawSelf and (not hasDrawGroup or not self.SV.enableDrawGroup)) end,
        })
    end

    table.insert(ModuleControls, { type = "divider" })

    -- DROPDOWN TEXTURE
    if self.Default.texture ~= nil then
        local currentChoices = self.TextureChoices or CC.CIRCLE_CHOICES
        local currentValues  = self.TextureValues or CC.CIRCLE_VALUES

        table.insert(ModuleControls, {
            type = "dropdown",
            name = "Texture",
            choices = currentChoices,
            choicesValues = currentValues,
            getFunc = function() return self.SV.texture end,
            setFunc = function(value)
                self.SV.texture = value
                if self.Skills then
                    for _, AbilityList in pairs(self.Skills) do
                        for _, abilityId in ipairs(AbilityList) do
                            CC.DisplayEffect:UpdateActiveTextures(abilityId, value)
                        end
                    end
                end
                local Preview = CC.Menu.Previews[self.name]
                if Preview then
                    Preview:SetTexture(CC.NAME .. value)
                end
            end,
            default = self.Default.texture,
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule or not self.SV.enableDrawSelf and (not hasDrawGroup or not self.SV.enableDrawGroup) end,
        })
    end

    -- PREVIEW
    table.insert(ModuleControls, {
        type = "custom",
        createFunc = function(CustomControl)
            CustomControl:SetHeight(128)
            local texture = WINDOW_MANAGER:CreateControl(nil, CustomControl, CT_TEXTURE)
            texture:SetAnchor(CENTER, CustomControl, CENTER)
            texture:SetDimensions(128, 128)
            texture:SetTexture(CC.NAME .. (self.SV.texture or ""))

            local Color = self.SV.ColorSelf or {1, 1, 1, 1}
            texture:SetColor(unpack(Color))

            CC.Menu.Previews[self.name] = texture
        end,
        width = "full",
    })

    -- SPACE AFTER TEXTURE
    table.insert(ModuleControls, { type = "description", text = "", width = "full", })

    -- NOTIFICATION / SOUND
    if self.Default.enableNotification ~= nil then
        table.insert(ModuleControls, { type = "header", name = CC.ColorString("NOTIFICATION & SOUND", "tier3") })

        table.insert(ModuleControls, {
            type = "checkbox",
            name = "Enable Center Screen Notification",
            getFunc = function() return self.SV.enableNotification end,
            setFunc = function(value) self.SV.enableNotification = value end,
            default = self.Default.enableNotification,
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
        })

        if self.Default.soundNotification ~= nil then
            table.insert(ModuleControls, {
                type = "dropdown",
                name = "Notification Sound",
                choices = CC.NOTIFICATION_SOUNDS_CHOICES,
                choicesValues = CC.NOTIFICATION_SOUNDS_VALUES,
                getFunc = function() return self.SV.soundNotification end,
                setFunc = function(value)
                    self.SV.soundNotification = value
                    if self.SV.volumeNotification and self.SV.volumeNotification > 0 then
                        CC.PlaySound(value, self.SV.volumeNotification)
                    end
                end,
                default = self.Default.soundNotification,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            })
        end

        if self.Default.volumeNotification ~= nil then
            table.insert(ModuleControls, {
                type = "slider",
                name = "Volume Notification 0 = OFF",
                min = 0, max = 10, step = 1,
                getFunc = function() return self.SV.volumeNotification end,
                setFunc = function(value)
                    self.SV.volumeNotification = value
                        if value > 0 and self.SV.soundNotification then
                            CC.PlaySound(self.SV.soundNotification, value)
                    end
                end,
                default = self.Default.volumeNotification,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            })
        end

        table.insert(ModuleControls, { type = "description", text = "", width = "full", })
    end

    -- CAST PROTECTION CHECKBOX
    if self.Default.enableSkillBlocker ~= nil then
        table.insert(ModuleControls, { type = "header", name = CC.ColorString("PREVENT OVERLAPPING CASTS / BUFFS", "tier3") })
        table.insert(ModuleControls, { type = "description", text = CC.ColorString("Override:", "tier2") .. " Casting 3x within 1.5 second bypasses this protocol.", width = "full", })

        table.insert(ModuleControls, {
            type = "checkbox",
            name = "Enable Skill Blocker",
            tooltip = "Blocks you from casting [" .. menuName .. "] while a previous cast is still active.\n\nThis also applies to group member casts received via LibGroupBroadcast (LGB).",
            warning = "For educational purposes and testing only.",
            getFunc = function() return self.SV.enableSkillBlocker end,
            setFunc = function(value)
                self.SV.enableSkillBlocker = value
                CC.SkillBlocker:UpdateEquippedSkills()
            end,
            default = self.Default.enableSkillBlocker,
            disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
        })
    end

    return {
        type = "submenu",
        -- name als Funktion berechnet das [OFF] zur Laufzeit dynamisch neu
        name = function()
            local stringEnable = self.SV.enableModule and "" or CC.ColorString("[OFF] ", "RD")
            return string.format("%s%s%s%s", iconString, stringEnable, CC.ColorString(menuName, "tier2"), stringLGB)
        end,
        controls = ModuleControls,
    }
end

----------------------------------------------------------------------------------------------------
-- CREATE SETTINGS MENU
----------------------------------------------------------------------------------------------------
function CC.CreateSettings()
    if not LAM2 then return end

    local panelIcon = string.format("|t%d:%d:%s/icons/logo_cc.dds|t", CC.SIZE_ICON_LAM_PANEL, CC.SIZE_ICON_LAM_PANEL, CC.NAME)
    local settingsIcon = string.format("|t%d:%d:esoui/art/icons/ability_scrying_05a.dds|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM)
    local panelName = "Combat Coordination " .. panelIcon
    if GetUnitDisplayName("player") == CC.AUTHOR then panelName = "[Dev] " .. panelName end

    local PanelData = {
        type = "panel",
        name = panelName,
        displayName = CC.ColorString("Combat", "tier1") .. " " .. CC.ColorString("Coordination", "WH") .. string.format(" |t%d:%d:%s/icons/logo_cc.dds|t", CC.SIZE_ICON_LAM_PANEL, CC.SIZE_ICON_LAM_PANEL, CC.NAME),
        author = CC.ColorString(CC.AUTHOR, "tier1") .. " " .. CC.ColorString("[PC/EU]", "WH"),
        version = string.format("%s-%04d",CC.VERSION, CC.ADDONVERSION),
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local OptionsData = {
        ----------------------------------------------------------------------------------------------------
        -- MASTERSWITCH
        ----------------------------------------------------------------------------------------------------
        {
            type = "checkbox",
            name = CC.ColorString("MASTERSWITCH", "tier1") .. " (Turns the entire addon ON/OFF)",
            getFunc = function() return CC.SV.enableAddon end,
            setFunc = function(value)
                CC.SV.enableAddon = value
                if value then
                    CC.Enable()
                    CC.DisplayPanel:Show()
                    CC.DisplayStatus:Show()
                else
                    CC.Disable()
                end
            end,
            default = CC.Default.enableAddon,
        },

        { type = "divider" },

        {
            type = "description",
            text = "Modules tagged with " .. CC.ColorString("[LGB]", "GN") .. " share data via LibGroupBroadcast.",
            width = "full"
        },

        {
            type = "submenu",
            name = settingsIcon .. " " .. CC.ColorString("GENERAL & GRAPHICS SETTINGS", "tier2"),
            controls = {
                {
                    type = "checkbox",
                    name = CC.ColorString("Enable Preview", "GN") .. " (Enable EVERYTHING)",
                    getFunc = function() return CC.enablePreview end,
                    setFunc = function(value) CC.enablePreview = value end,
                    default = false,
                    disabled = function() return not CC.SV.enableAddon end,
                },

                ----------------------------------------------------------------------------------------------------
                -- NOTIFICATION DISPLAY
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("NOTIFICATIONS", "tier3") },
                {
                    type = "slider",
                    name = "Font Size",
                    tooltip = "Configure notification font size.",
                    min = 25, max = 75, step = 1,
                    getFunc = function() return CC.DisplayNotification.SV.fontSize end,
                    setFunc = function(value)
                        CC.DisplayNotification.SV.fontSize = value
                        if CC.DisplayNotification.LabelLine1 then
                            CC.DisplayNotification:UpdateDimensions()
                            CC.DisplayNotification:TriggerCustom(1.5, "Notification", "Preview")
                        end
                    end,
                    default = CC.DisplayNotification.Default.fontSize,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "dropdown",
                    name = "Font Style",
                    tooltip = "Configure notification font style.",
                    choices = CC.FONT_STYLE_CHOICES,
                    choicesValues = CC.FONT_STYLE_VALUES,
                    getFunc = function() return CC.DisplayNotification.SV.fontStyle end,
                    setFunc = function(value)
                        CC.DisplayNotification.SV.fontStyle = value
                        if CC.DisplayNotification.LabelLine1 then
                            CC.DisplayNotification:UpdateDimensions()
                            CC.DisplayNotification:TriggerCustom(1.5, "Notification", "Preview")
                        end
                    end,
                    default = CC.DisplayNotification.Default.fontStyle,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "dropdown",
                    name = "Font Weight",
                    tooltip = "Configure notification outline.",
                    choices = CC.FONT_WEIGHT_CHOICES,
                    choicesValues = CC.FONT_WEIGHT_VALUES,
                    getFunc = function() return CC.DisplayNotification.SV.fontWeight end,
                    setFunc = function(value)
                        CC.DisplayNotification.SV.fontWeight = value
                        if CC.DisplayNotification.LabelLine1 then
                            CC.DisplayNotification:UpdateDimensions()
                            CC.DisplayNotification:TriggerCustom(1.5, "Notification", "Preview")
                        end
                    end,
                    default = CC.DisplayNotification.Default.fontWeight,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "colorpicker",
                    name = "Default Font Color",
                    tooltip = "Configure base color. Note: Slayer Assistant, Break Timer etc. settings override this parameter.",
                    getFunc = function() return unpack(CC.DisplayNotification.SV.ColorLine1) end,
                    setFunc = function(r, g, b, a)
                        CC.DisplayNotification.SV.ColorLine1 = {r, g, b, a}
                        CC.DisplayNotification.SV.ColorLine2 = {r, g, b, a}
                        if CC.DisplayNotification.LabelLine1 then
                            CC.DisplayNotification:TriggerCustom(1.5, "Notification", "Preview")
                        end
                    end,
                    default = CC.GetRgbaFromArray(CC.DisplayNotification.Default.ColorLine1),
                    disabled = function() return not CC.SV.enableAddon end,
                },

                ----------------------------------------------------------------------------------------------------
                -- PANEL WINDOW
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("PANEL WINDOW", "tier3") },
                {
                    type = "dropdown",
                    name = "Panel Font Style",
                    choices = CC.FONT_STYLE_CHOICES,
                    choicesValues = CC.FONT_STYLE_VALUES,
                    getFunc = function() return CC.DisplayPanel.SV.fontStyle end,
                    setFunc = function(value)
                        CC.DisplayPanel.SV.fontStyle = value
                        CC.DisplayPanel:ApplyFonts()
                    end,
                    default = CC.DisplayPanel.Default.fontStyle,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "dropdown",
                    name = "Panel Font Weight",
                    choices = CC.FONT_WEIGHT_CHOICES,
                    choicesValues = CC.FONT_WEIGHT_VALUES,
                    getFunc = function() return CC.DisplayPanel.SV.fontWeight end,
                    setFunc = function(value)
                        CC.DisplayPanel.SV.fontWeight = value
                        CC.DisplayPanel:ApplyFonts()
                    end,
                    default = CC.DisplayPanel.Default.fontWeight,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Panel Scale [%]",
                    tooltip = "Overall size of the panel.",
                    min = 75, max = 125, step = 1,
                    getFunc = function() return (CC.DisplayPanel.SV.panelScale) * 100 end,
                    setFunc = function(value)
                        local newScale = value / 100
                        CC.DisplayPanel.SV.panelScale = newScale
                        if CC.DisplayPanel.Parent then
                            CC.DisplayPanel.Parent:SetScale(newScale)
                            CC.DisplayPanel:Show()
                        end
                    end,
                    default = 100,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Panel Alpha",
                    min = 0.5, max = 1.0, step = 0.05, decimals = 2,
                    getFunc = function() return CC.DisplayPanel.SV.colorA end,
                    setFunc = function(value)
                        CC.DisplayPanel.SV.colorA = value
                        CC.DisplayPanel:UpdateDimensions()
                    end,
                    default = CC.DisplayPanel.Default.colorA,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "dropdown",
                    name = "Anchor Point",
                    tooltip = "Submenu expansion direction.",
                    choices = { "TOP", "CENTER", "BOTTOM" },
                    choicesValues = { 1, 2, 3 },
                    getFunc = function() return CC.DisplayPanel.SV.anchorMode or 1 end,
                    setFunc = function(value)
                        if CC.DisplayPanel.Parent then
                            local control = CC.DisplayPanel.Parent
                            if value == 1 then
                                CC.DisplayPanel.SV.offsetY = control:GetTop()
                            elseif value == 2 then
                                CC.DisplayPanel.SV.offsetY = control:GetTop() + (control:GetHeight() / 2)
                            elseif value == 3 then
                                CC.DisplayPanel.SV.offsetY = control:GetBottom()
                            end
                        end
                        CC.DisplayPanel.SV.anchorMode = value
                        CC.DisplayPanel:ApplyAnchor()
                    end,
                    default = CC.DisplayPanel.Default.anchorMode or 1,
                    disabled = function() return not CC.SV.enableAddon end,
                },

                {
                    type = "description",
                    text = CC.ColorString("Command:", "tier2") .. " Use " .. CC.ColorString("[/cc_panel]", "tier3") .. " or click on status icon to toggle.",
                    width = "full",
                },
                {
                    type = "button",
                    name = "RESET POSITION",
                    tooltip = "Reset panel position to default.",
                    func = function()
                        CC.DisplayPanel:ResetPosition()
                        CC.DisplayPanel:Show()
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "button",
                    name = "SHOW PANEL",
                    func = function()
                        CC.DisplayPanel:Show()
                    end,
                    width = "half"
                },

                ----------------------------------------------------------------------------------------------------
                -- STATUS ICON
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("STATUS ICON", "tier3") },
                {
                    type = "checkbox",
                    name = "Enable Status Display",
                    tooltip = "Show small CC status icon.",
                    getFunc = function() return CC.DisplayStatus.SV.enableStatus end,
                    setFunc = function(value)
                        CC.DisplayStatus.SV.enableStatus = value
                        if value then
                            CC.DisplayStatus:CustomEnable()
                            CC.DisplayStatus:Show()
                        else
                            CC.DisplayStatus:CustomDisable()
                        end
                    end,
                    default = CC.DisplayStatus.Default.enableStatus,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "slider",
                    name = "Status Display Scale [%]",
                    min = 75, max = 125, step = 1,
                    getFunc = function() return (CC.DisplayStatus.SV.statusScale) * 100 end,
                    setFunc = function(value)
                        local newScale = value / 100
                        CC.DisplayStatus.SV.statusScale = newScale
                        if CC.DisplayStatus.Parent then
                            CC.DisplayStatus.Parent:SetScale(newScale)
                            CC.DisplayStatus:Show()
                        end
                    end,
                    default = 100,
                    disabled = function() return not CC.SV.enableAddon or not CC.DisplayStatus.SV.enableStatus end,
                },
                {
                    type = "button",
                    name = "RESET POSITION",
                    tooltip = "Reset status icon position to default.",
                    func = function()
                        CC.DisplayStatus:ResetPosition()
                        CC.DisplayStatus:Show()
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.DisplayStatus.SV.enableStatus end,
                },
                {
                    type = "button",
                    name = "SHOW ICON",
                    func = function()
                        CC.DisplayStatus:Show()
                        CC.DisplayStatus:PlayAnimation(2.0)
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.DisplayStatus.SV.enableStatus end,
                },

                ----------------------------------------------------------------------------------------------------
                -- GROUP LEADER AUTO-PROMOTE
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("AUTO RETURN CROWN", "tier3") },
                {
                    type = "description",
                    text = "Returns group leader crown to the previous leader upon reconnecting..\n" .. CC.ColorString("Note:", "tier2") .. " Active timeout is 10 minutes.",
                    -- https://www.esoui.com/downloads/info4320
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Auto Return Crown",
                    getFunc = function() return CC.Events.SV.enableAutoPromote end,
                    setFunc = function(value) CC.Events.SV.enableAutoPromote = value end,
                    default = CC.Events.Default.enableAutoPromote,
                    disabled = true, --function() return not CC.SV.enableAddon end,
                },
            },
        },
    }

    local function AddModuleMenu(ModuleMenu)
        if type(ModuleMenu) == "table" and ModuleMenu.type == "submenu" and ModuleMenu.controls then
            table.insert(OptionsData, ModuleMenu)
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- START MODULES
    ----------------------------------------------------------------------------------------------------
    local LayerHeaders = {
        [0] = "MAIN",
        [1] = "GROUP & UTILITY",
        [2] = "SHAPES & POINTER",
        [3] = "SKILLS & BUFFS",
    }

    for i = 0, 3 do
        local layerModules = {}

        -- COLLECT
        for _, Module in ipairs(CC.Modules) do
            local layer = Module.menuLayer or 0
            if layer == i and Module.GetMenuOptions then
                table.insert(layerModules, Module)
            end
        end

        -- HEADER.. INSERT MODULES
        if #layerModules > 0 then

            if i > 0 then
                table.insert(OptionsData, { type = "description", text = "", width = "full" })
                table.insert(OptionsData, { type = "header", name = CC.ColorString(LayerHeaders[i], "tier1") })
            end

            for _, Module in ipairs(layerModules) do
                AddModuleMenu(Module:GetMenuOptions())
            end
        end
    end

    table.insert(OptionsData, { type = "divider" })
    table.insert(OptionsData, { type = "submenu",
        name = CC.ColorString("DEBUG SETTINGS", "tier2"),
        controls = {
            {
                type = "checkbox",
                name = "Enable: Miscellaneous [/cc_debug]",
                getFunc = function() return CC.SV.enableDebug end,
                setFunc = function(value) CC.SV.enableDebug = value end,
                default = CC.Default.enableDebug,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "divider",
            },
            {
                type = "checkbox",
                name = "Enable: Used Abilities [/cc_debug_ability]",
                getFunc = function() return CC.Events.SV.enableDebugOnActionSlotAbilityUsed end,
                setFunc = function(value) CC.Events.SV.enableDebugOnActionSlotAbilityUsed = value end,
                default = CC.Events.Default.enableDebugOnActionSlotAbilityUsed,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "checkbox",
                name = "Enable: Data Received [/cc_debug_ondata]",
                getFunc = function() return CC.Broadcast.SV.enableDebugOnData end,
                setFunc = function(value) CC.Broadcast.SV.enableDebugOnData = value end,
                default = CC.Broadcast.Default.enableDebugOnData,
                disabled = function() return not CC.SV.enableAddon end,
            },
        },
    })

    table.insert(OptionsData, { type = "description",
        text = "If you enjoy " .. CC.ColorString("Combat Coordination", "tier1") .. ", consider sharing your feedback or supporting its development. Your input and contributions are greatly appreciated!",
        width = "full"
    })

    table.insert(OptionsData, { type = "button",
        name = "REQUEST MODULE",
        tooltip = "Opens a mail to send a request to the author.",
        func = function()
            if IsConsoleUI() then
                d(string.format("%s |cFFFFFFRequests via Mail are currently only supported on PC.|r", CC.CHAT))
                return
            end
            SCENE_MANAGER:Show('mailSend')
            zo_callLater(function()
                ZO_MailSendToField:SetText(CC.AUTHOR)
                ZO_MailSendSubjectField:SetText("Combat Coordination Request")
                ZO_MailSendBodyField:TakeFocus()
            end, 250)
        end,
        width = "half"
    })

    table.insert(OptionsData, { type = "button",
        name = "FEEDBACK / DONATE",
        tooltip = "Opens a mail to send feedback or donate to the author. <3",
        func = function()
            if IsConsoleUI() then
                d(string.format("%s |cFFFFFFFeedback via Mail is currently only supported on PC.|r", CC.CHAT))
                return
            end
            SCENE_MANAGER:Show('mailSend')
            zo_callLater(function()
                ZO_MailSendToField:SetText(CC.AUTHOR)
                ZO_MailSendSubjectField:SetText("Combat Coordination Feedback")
                ZO_MailSendBodyField:TakeFocus()
            end, 250)
        end,
        width = "half"
    })

    CC.Menu.PanelName = LAM2:RegisterAddonPanel(CC.NAME .. "Menu", PanelData)
    LAM2:RegisterOptionControls(CC.NAME .. "Menu", OptionsData)
end