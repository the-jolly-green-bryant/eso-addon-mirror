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

    table.insert(ModuleControls, {
        type = "description",
        text = "Timers, visuals and the skillblocker operate independently.\nNone of them require the others to function.",
        width = "full",
    })

    -- TIMER
    if self.Default.timer ~= nil then
        table.insert(ModuleControls, { type = "header", name = CC.ColorString("TIMER", "tier3") })
        table.insert(ModuleControls, {
            type = "dropdown",
            name = "Show Timer / Countdown (Duration)",
            choices = CC.TIMER_CHOICES,
            choicesValues = CC.TIMER_VALUES,
            getFunc = function() return self.SV.timer end,
            setFunc = function(value) self.SV.timer = value end,
            default = self.Default.timer,
            disabled = function() return not CC.SV.enableAddon end,
        })
    end

    -- VISUALS CHECKBOX
    table.insert(ModuleControls, { type = "header", name = CC.ColorString("VISUALS", "tier3") })
    if self.Default.enableDrawSelf ~= nil then
        table.insert(ModuleControls, {
            type = "checkbox",
            name = hasDrawGroup and "Enable Visuals For Your Casts" or "Enable Visuals",
            getFunc = function() return self.SV.enableDrawSelf end,
            setFunc = function(value) self.SV.enableDrawSelf = value end,
            default = self.Default.enableDrawSelf,
            disabled = function() return not CC.SV.enableAddon end,
        })
    end

    if hasDrawGroup then
        table.insert(ModuleControls, {
            type = "checkbox",
            name = "Enable Visuals For Group Member Casts",
            getFunc = function() return self.SV.enableDrawGroup end,
            setFunc = function(value) self.SV.enableDrawGroup = value end,
            default = self.Default.enableDrawGroup,
            disabled = function() return not CC.SV.enableAddon end,
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
            disabled = function() return not self.SV.enableDrawSelf and (not hasDrawGroup or not self.SV.enableDrawGroup) end,
        })
    end

    if self.Default.ColorSelf ~= nil then
        table.insert(ModuleControls, {
            type = "colorpicker",
            name = hasDrawGroup and "Color (Your Cast)" or "Color",
            getFunc = function()
                local Color = self.SV.ColorSelf
                zo_callLater(function()
                    local Preview = CC.Menu.Previews[self.name]
                    if Preview then
                        Preview:SetColor(unpack(Color))
                    end
                end, 100)
                return unpack(Color)
            end,
            setFunc = function(r, g, b, a)
                self.SV.ColorSelf = {r, g, b, a}
                local Preview = CC.Menu.Previews[self.name]
                if Preview then
                    Preview:SetColor(r, g, b, a)
                end
            end,
            default = CC.GetRgbaFromArray(self.Default.ColorSelf),
            disabled = function() return self.SV.enableGameAoeFriendlyColor end,
        })
    end

    if hasDrawGroup and self.Default.ColorGroup ~= nil then
        table.insert(ModuleControls, {
            type = "colorpicker",
            name = "Color (Group Member)",
            getFunc = function() return unpack(self.SV.ColorGroup) end,
            setFunc = function(r, g, b, a) self.SV.ColorGroup = {r, g, b, a} end,
            default = CC.GetRgbaFromArray(self.Default.ColorGroup),
            disabled = function() return self.SV.enableGameAoeFriendlyColor end,
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
            disabled = function() return not self.SV.enableDrawSelf and (not hasDrawGroup or not self.SV.enableDrawGroup) end,
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
            disabled = function() return not CC.SV.enableAddon end,
        })

        table.insert(ModuleControls, {
            type = "slider",
            name = "Volume Notification 0 = OFF",
            min = 0, max = 10, step = 1,
            getFunc = function() return self.SV.volumeNotification end,
            setFunc = function(value)
                self.SV.volumeNotification = value
                if value > 0 then
                    -- TODO: THIS IS THE SOUND FOR OLORIME.. NEED TO MAKE THAT MODULE SPECIFIC
                    CC.PlaySound(SOUNDS.ABILITY_ULTIMATE_READY, value)
                end
            end,
            default = self.Default.volumeNotification,
            disabled = function() return not self.SV.enableNotification or not CC.SV.enableAddon end,
        })

        table.insert(ModuleControls, { type = "description", text = "", width = "full", })
    end

    -- CAST PROTECTION CHECKBOX
    if self.Default.enableSkillBlocker ~= nil then
        table.insert(ModuleControls, { type = "header", name = CC.ColorString("PREVENT OVERLAPPING CASTS / BUFFS", "tier3") })
        if not LibSkillBlocker then
            table.insert(ModuleControls, { type = "description", text = CC.ColorString("Status:", "tier1") .. CC.ColorString(" LibSkillBlocker missing. Feature disabled.", "RD"), width = "full", })
        else
            table.insert(ModuleControls, { type = "description", text = CC.ColorString("Override:", "tier2") .. " Casting 3x within 1.5 second bypasses this protocol.", width = "full", })
        end
        table.insert(ModuleControls, {
            type = "checkbox",
            name = "Enable Skill Blocker",
            tooltip = "Blocks you from casting [" .. menuName .. "] while a previous cast is still active.\n\nThis also applies to group member casts received via LibGroupBroadcast (LGB).\n\nRequires: LibSkillBlocker",
            warning = "For educational purposes and testing only.",
            getFunc = function() return self.SV.enableSkillBlocker end,
            setFunc = function(value)
                self.SV.enableSkillBlocker = value
                CC.SkillBlocker:UpdateEquippedSkills()
            end,
            default = self.Default.enableSkillBlocker,
            disabled = function() return (not CC.SV.enableAddon or not LibSkillBlocker) end,
        })
    end

    return {
        type = "submenu",
        name = string.format("%s%s%s", iconString, CC.ColorString(menuName, "tier2"), stringLGB),
        controls = ModuleControls,
    }
end

----------------------------------------------------------------------------------------------------
-- CREATE SETTINGS MENU
----------------------------------------------------------------------------------------------------
function CC.CreateSettings()
    if not LAM2 then return end

    --"/icons/combatcoordination.dds"
    local panelIcon = string.format("|t%d:%d:%s/icons/combatcoordination.dds|t", CC.SIZE_ICON_LAM_PANEL, CC.SIZE_ICON_LAM_PANEL, CC.NAME)
    local settingsIcon = string.format("|t%d:%d:esoui/art/icons/ability_scrying_05a.dds|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM)
    local raidleadIcon = string.format("|t%d:%d:/esoui/art/icons/ability_dragonknight_032.dds|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM)
    local panelName = "Combat Coordination " .. panelIcon
    if GetUnitDisplayName("player") == CC.AUTHOR then panelName = "[Dev] " .. panelName end

    local PanelData = {
        type = "panel",
        name = panelName,
        displayName = CC.ColorString("Combat", "tier1") .. " " .. CC.ColorString("Coordination", "WH") .. string.format(" |t%d:%d:%s/icons/combatcoordination.dds|t", CC.SIZE_ICON_LAM_PANEL, CC.SIZE_ICON_LAM_PANEL, CC.NAME),
        author = CC.ColorString(CC.AUTHOR, "tier1") .. " " .. CC.ColorString("[PC/EU]", "WH"),
        version = CC.VERSION,
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
                if value then CC.Enable() else CC.Disable() end
            end,
            default = CC.Default.enableAddon,
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
                            CC.DisplayNotification:TriggerCustom(1.5, "Notification", "Preview", false)
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
                            CC.DisplayNotification:TriggerCustom(1.5, "Notification", "Preview", false)
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
                            CC.DisplayNotification:TriggerCustom(1.5, "Notification", "Preview", false)
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
                            CC.DisplayNotification:TriggerCustom(1.5, "Notification", "Preview", false)
                        end
                    end,
                    default = CC.GetRgbaFromArray(CC.DisplayNotification.Default.ColorLine1),
                    disabled = function() return not CC.SV.enableAddon end,
                },

                {
                    type = "checkbox",
                    name = "Enable Sound for Notification",
                    getFunc = function() return CC.DisplayNotification.SV.enableSound end,
                    setFunc = function(value) CC.DisplayNotification.SV.enableSound = value end,
                    default = CC.DisplayNotification.Default.enableSound,
                    disabled = function() return not CC.SV.enableAddon end,
                },

                ----------------------------------------------------------------------------------------------------
                -- PANEL WINDOW
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("PANEL WINDOW", "tier3") },
                {
                    type = "slider",
                    name = "Panel Scale [%]",
                    tooltip = "Overall size of the panel.",
                    min = 75, max = 125, step = 1,
                    getFunc = function() return (CC.DisplayPanel.SV.panelScale) * 100 end,
                    setFunc = function(value)
                        local newScale = value / 100
                        CC.DisplayPanel.SV.panelScale = newScale
                        if CC.DisplayPanel.Parent then CC.DisplayPanel.Parent:SetScale(newScale) end
                        if CC.DisplayStatus.Parent then CC.DisplayStatus.Parent:SetScale(newScale) end
                    end,
                    default = 100,
                    disabled = function() return not CC.SV.enableAddon end,
                },
                -- {
                --     type = "slider",
                --     name = "Panel Width",
                --     min = 275, max = 325, step = 1,
                --     getFunc = function() return CC.DisplayPanel.SV.panelWidth end,
                --     setFunc = function(value)
                --         CC.DisplayPanel.SV.panelWidth = value
                --         CC.DisplayPanel:UpdateDimensions()
                --     end,
                --     default = CC.DisplayPanel.Default.panelWidth,
                --     disabled = function() return not CC.SV.enableAddon end,
                -- },
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
                    choices = { "TOP LEFT", "CENTER LEFT", "BOT LEFT" },
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
                    text = CC.ColorString("Command:", "tier2") .. " Use " .. CC.ColorString("[/cc_panel]", "tier3") .. " or status icon to toggle UI.",
                    width = "full",
                },
                {
                    type = "button",
                    name = "RESET POSITION",
                    tooltip = "Reset panel position to default.",
                    func = function()
                        CC.DisplayPanel:ResetPosition()
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "button",
                    name = "TOGGLE PANEL",
                    tooltip = "Toggle panel window.",
                    func = function()
                        CC.DisplayPanel:Toggle()
                    end,
                    width = "half"
                },

                ----------------------------------------------------------------------------------------------------
                -- STATUS ICON
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("STATUS ICON", "tier3") },
                {
                    type = "button",
                    name = "RESET POSITION",
                    tooltip = "Reset status icon position to default.",
                    func = function()
                        CC.DisplayStatus:ResetPosition()
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon end,
                },
            },
        },

        ----------------------------------------------------------------------------------------------------
        -- RAIDLEAD SWITCH
        ----------------------------------------------------------------------------------------------------
        {
            type = "submenu",
            name = raidleadIcon .. " " .. CC.ColorString("RAIDLEAD ASSIGNMENT & TOOLS", "tier2"),
            controls = {
                ----------------------------------------------------------------------------------------------------
                -- RAIDLEAD ASSIGNMENT
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("ENABLE RAIDLEAD TOOLS", "GN") },
                {
                    type = "description",
                    text = CC.ColorString("Unlocks timers, tools and assignment protocols.", "GN"),
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "[Step 1/2] Enable Raidlead",
                    getFunc = function() return CC.SV.isRaidleadIntent end,
                    setFunc = function(value)
                        CC.SV.isRaidleadIntent = value
                        if not value then
                            CC.SV.isRaidlead = false
                            if CC.DisplayPanel.SV.isVisible then
                                CC.DisplayPanel:UpdateDimensions()
                            end
                        end
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon end,
                },
                {
                    type = "checkbox",
                    name = "[Step 2/2] Confirm Raidlead",
                    warning = "Activation grants permission to broadcast targeted assignments and control group timers.",
                    getFunc = function() return CC.SV.isRaidlead end,
                    setFunc = function(value)
                        CC.SV.isRaidlead = value
                        if CC.DisplayPanel.SV.isVisible then
                            CC.DisplayPanel:UpdateDimensions()
                        end
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.isRaidleadIntent or not CC.SV.enableAddon end,
                },

                ----------------------------------------------------------------------------------------------------
                -- BREAK TIMER
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("BREAK TIMER", "tier3") },
                {
                    type = "slider",
                    name = "Break Duration [Minutes]",
                    min = 1, max = 30, step = 1,
                    getFunc = function() return CC.RaidleadTools.SV.breakMinutes end,
                    setFunc = function(value) CC.RaidleadTools.SV.breakMinutes = value end,
                    default = CC.RaidleadTools.Default.breakMinutes,
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                {
                    type = "button",
                    name = "START BREAK",
                    func = function()
                        CC.RaidleadTools:RequestBreak(CC.RaidleadTools.SV.breakMinutes)
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                {
                    type = "button",
                    name = "STOP BREAK",
                    func = function()
                        CC.RaidleadTools:RequestBreak(0)
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                ----------------------------------------------------------------------------------------------------
                -- PULL TIMER
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("PULL TIMER", "tier3") },
                {
                    type = "slider",
                    name = "Pull Duration [Seconds]",
                    min = 1, max = 15, step = 1,
                    getFunc = function() return CC.RaidleadTools.SV.pullSeconds end,
                    setFunc = function(value) CC.RaidleadTools.SV.pullSeconds = value end,
                    default = CC.RaidleadTools.Default.pullSeconds,
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                {
                    type = "button",
                    name = "START PULL",
                    func = function()
                        CC.RaidleadTools:RequestPull(CC.RaidleadTools.SV.pullSeconds)
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                {
                    type = "button",
                    name = "STOP PULL",
                    func = function()
                        CC.RaidleadTools:RequestPull(0)
                    end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                ----------------------------------------------------------------------------------------------------
                -- TOOLS & ASSIGNMENTS
                ----------------------------------------------------------------------------------------------------
                { type = "header", name = CC.ColorString("TOOLS & ASSIGNMENTS", "tier3") },
                {
                    type = "button",
                    name = "WIPE PLEASE",
                    tooltip = "Broadcasts wipe request to group members.",
                    func = function() CC.RaidleadTools:RequestWipe() end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                {
                    type = "button",
                    name = "GROUP P-T-E",
                    tooltip = "Broadcasts exit instance request to group members.",
                    func = function() CC.RaidleadTools:RequestExitInstance() end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                {
                    type = "button",
                    name = "PORT IN PLEASE",
                    tooltip = "Broadcasts port-in request to group members.",
                    func = function() CC.RaidleadTools:RequestPortIn() end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                {
                    type = "button",
                    name = "PORT TO LEAD",
                    tooltip = "Broadcasts leader port request to group members.",
                    func = function() CC.RaidleadTools:RequestPortToLeader() end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                {
                    type = "button",
                    name = "READYCHECK",
                    tooltip = "Initiates a group ready check.",
                    func = function() SLASH_COMMANDS["/readycheck"]() end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
                {
                    type = "button",
                    name = "START VOTE",
                    tooltip = "Initiates a group vote.",
                    func = function() CC.RaidleadTools:StartVote() end,
                    width = "half",
                    disabled = function() return not CC.SV.enableAddon or not CC.IsRaidlead() end,
                },
            },
        },

        {
			type = "header", name = CC.ColorString("ADDON MODULES", "tier1")
		},
        {
            type = "description",
            text = "Modules tagged with " .. CC.ColorString("[LGB]", "GN") .. " share data via LibGroupBroadcast.",
            width = "full"
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
    for i = 0, 2 do
        local layerHasModules = false
        for _, Module in ipairs(CC.Modules) do
            local layer = Module.menuLayer or 1

            if layer == i and Module.GetMenuOptions then
                AddModuleMenu(Module:GetMenuOptions())
                layerHasModules = true
            end
        end
        if layerHasModules and i < 2 then
            table.insert(OptionsData, { type = "divider" })
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
                name = "Enable: Combat Event [/cc_debug_combatevent]",
                getFunc = function() return CC.Events.SV.enableDebugOnCombatEvent end,
                setFunc = function(value) CC.Events.SV.enableDebugOnCombatEvent = value end,
                default = CC.Events.Default.enableDebugOnCombatEvent,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "checkbox",
                name = "Enable: Cache UnitNames [/cc_debug_cache]",
                getFunc = function() return CC.Events.SV.enableDebugCacheUnitNames end,
                setFunc = function(value) CC.Events.SV.enableDebugCacheUnitNames = value end,
                default = CC.Events.Default.enableDebugCacheUnitNames,
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