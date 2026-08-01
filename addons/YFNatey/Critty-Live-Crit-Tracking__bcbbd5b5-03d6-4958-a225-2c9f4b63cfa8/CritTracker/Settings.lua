--=============================================================================
-- Settings Menu
--=============================================================================
function CritTracker:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    local panelName = "CritTrackerSettings"

    local panelData = {
        type = "panel",
        name = "Critty",
        author = "YFNatey",
        version = "1.1",
        registerForRefresh = true,
        registerForDefaults = true
    }

    local fontChoices, fontChoicesValues = self:GetFontChoices()
    local optionsTable = {
        {
            type = "checkbox",
            name = "Show Tracker",
            getFunc = function() return self.savedVars.uiVisible end,
            setFunc = function(value)
                self.savedVars.uiVisible = value
                local labels = self:GetLabels()
                for i, label in ipairs(labels) do
                    if label then
                        label:SetHidden(not value)
                    end
                end
                if value then
                    self:UpdateDisplay()
                end
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Show Only In Dungeons/Trials/Arenas",
            getFunc = function() return self.savedVars.showOnlyInDungeon end,
            setFunc = function(value)
                self.savedVars.showOnlyInDungeon = value
                self:UpdateTrackerVisibility()
            end,
            default = false,
            disabled = function() return not self.savedVars.uiVisible end,
        },
        {
            type = "button",
            name = "Reset Stats",
            func = function()
                -- Reset overall stats
                self.critCount = 0
                self.normalCount = 0
                self.totalCritDamage = 0
                self.totalNormalDamage = 0
                self.critDamagePercent = 0
                self.critMultiplier = 0

                -- Reset light attack overall tracking
                self.lightAttackCritCount = 0
                self.lightAttackNormalCount = 0
                self.lightAttackTotalCritDamage = 0
                self.lightAttackTotalNormalDamage = 0

                -- Reset ability/heavy overall tracking
                self.abilityAndHeavyCritCount = 0
                self.abilityAndHeavyNormalCount = 0
                self.abilityAndHeavyTotalCritDamage = 0
                self.abilityAndHeavyTotalNormalDamage = 0

                self:UpdateDisplay()
                self:DebugPrint("Crit stats reset")
            end
        },


        {
            type = "submenu",
            name = "Style: Line of Text",
            controls = {
                --[[{
                    type = "checkbox",
                    name = "Use Text-Based Style",
                    tooltip = "Simple line of text showing crit stats",
                    --TODO add getFunc and setFunc
                    default = false,
                },
                --]]
                {
                    type = "checkbox",
                    name = "Show Text Lines",
                    getFunc = function() return self.savedVars.showTextLines end,
                    setFunc = function(value)
                        self.savedVars.showTextLines = value
                        self:UpdateDisplay()
                    end,
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Simple Display Mode",
                    tooltip = "Compact single-line display vs detailed multi-line view",
                    getFunc = function() return self.savedVars.simpleMode end,
                    setFunc = function(value)
                        self.savedVars.simpleMode = value
                        self:UpdateDisplay()
                    end,
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Show Average Crit Damage",
                    tooltip =
                    "Shows your crit damage percentage based on your damage in combat, not set bonuses or buffs/debuffs to bosses. Averages the total crit damage done vs normal damage.",
                    getFunc = function() return self.savedVars.showCritDmg end,
                    setFunc = function(value)
                        self.savedVars.showCritDmg = value
                        self:UpdateDisplay()
                    end,
                    default = false,
                },
                {
                    type = "slider",
                    name = "Size",
                    min = 10,
                    max = 48,
                    step = 1,
                    getFunc = function() return self.savedVars.fontSize end,
                    setFunc = function(value)
                        self.savedVars.fontSize = value
                        self:UpdateLabelSettings()
                    end,
                    default = 24,
                },
                {
                    type = "slider",
                    name = "Horizontal",
                    min = 0,
                    max = GuiRoot:GetWidth(),
                    step = 20,
                    getFunc = function() return self.savedVars.labelPosX end,
                    setFunc = function(value)
                        self.savedVars.labelPosX = value
                        self:UpdateLabelSettings()
                    end,
                    default = 560,
                },
                {
                    type = "slider",
                    name = "Vertical",
                    min = 0,
                    max = GuiRoot:GetHeight(),
                    step = 20,
                    getFunc = function() return self.savedVars.labelPosY end,
                    setFunc = function(value)
                        self.savedVars.labelPosY = value
                        self:UpdateLabelSettings()
                    end,
                    default = 60,
                },
                {
                    type = "colorpicker",
                    name = "Crit Rate Color",
                    getFunc = function()
                        local color = self.savedVars.critRateColor
                        return color[1], color[2], color[3], color[4]
                    end,
                    setFunc = function(r, g, b, a)
                        self.savedVars.critRateColor = { r, g, b, a }
                        self:ApplyColorsToLabels()
                    end,
                    default = { 1.0, 1.0, 1.0, 1.0 },
                },
                {
                    type = "colorpicker",
                    name = "Crit Damage Color",
                    getFunc = function()
                        local color = self.savedVars.critDamageColor
                        return color[1], color[2], color[3], color[4]
                    end,
                    setFunc = function(r, g, b, a)
                        self.savedVars.critDamageColor = { r, g, b, a }
                        self:ApplyColorsToLabels()
                    end,
                    default = { 1.0, 1.0, 1.0, 1.0 },
                },
                {
                    type = "colorpicker",
                    name = "Text Color",
                    tooltip = "Color for regular text in custom format",
                    getFunc = function()
                        local color = self.savedVars.textColor
                        return color[1], color[2], color[3], color[4]
                    end,
                    setFunc = function(r, g, b, a)
                        self.savedVars.textColor = { r, g, b, a }
                        self:UpdateDisplay()
                    end,
                    default = { 1.0, 1.0, 1.0, 1.0 },
                    disabled = function() return not self.savedVars.useCustomFormat end,
                },
                {
                    type = "checkbox",
                    name = "Use Custom Format",
                    tooltip =
                    "Create your own tracker by editing the text fields below.\nUse <c> for crit rate\nUse <d> for crit damage",
                    getFunc = function() return self.savedVars.useCustomFormat end,
                    setFunc = function(value)
                        self.savedVars.useCustomFormat = value
                        if value then
                            self.savedVars.simpleMode = true
                        end
                        self:UpdateDisplay()
                    end,
                    default = false,
                },
                {
                    type = "editbox",
                    name = "In-Combat Format",
                    tooltip =
                    "\nUse <c> for crit rate\nUse <d> for crit damage. You do not need to add a % sign.",
                    getFunc = function() return self.savedVars.customFormatString end,
                    setFunc = function(value)
                        self.savedVars.customFormatString = value
                        self:UpdateDisplay()
                    end,
                    default = "<c> • Dmg: <d>",
                    disabled = function() return not self.savedVars.useCustomFormat end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable",
                    tooltip = "Track lucky crits when boss health drops below the threshold",
                    getFunc = function() return self.savedVars.enableExecuteTracking end,
                    setFunc = function(value)
                        self.savedVars.enableExecuteTracking = value
                        self:UpdateDisplay()
                    end,
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Execute Focus",
                    tooltip =
                    "Hide the main crit rate and damage lines when in execute phase, showing only execute stats",
                    getFunc = function() return self.savedVars.hideMainLinesInExecute end,
                    setFunc = function(value)
                        self.savedVars.hideMainLinesInExecute = value
                        self:UpdateDisplay()
                    end,
                    default = false,
                    disabled = function() return not self.savedVars.enableExecuteTracking end,
                },
                {
                    type = "checkbox",
                    name = "hide until threshold",
                    tooltip = "Hide tracker until execute phase",
                    getFunc = function() return self.savedVars.showExecutePhaseOnly end,
                    setFunc = function(value)
                        self.savedVars.showExecutePhaseOnly = value
                        self:UpdateDisplay()
                    end,
                    default = false,
                    disabled = function() return not self.savedVars.enableExecuteTracking end,
                },
                {
                    type = "slider",
                    name = "Threshold (%)",
                    tooltip = "Boss health percentage threshold for execute phase tracking",
                    min = 10,
                    max = 50,
                    step = 1,
                    getFunc = function() return self.savedVars.executeThreshold end,
                    setFunc = function(value)
                        self.savedVars.executeThreshold = value
                        self:UpdateDisplay()
                    end,
                    default = 30,
                    disabled = function() return not self.savedVars.enableExecuteTracking end,
                },
                {
                    type = "colorpicker",
                    name = "Color",
                    tooltip = "Color used when displaying execute phase statistics",
                    getFunc = function()
                        local color = self.savedVars.executePhaseColor
                        return color[1], color[2], color[3], color[4]
                    end,
                    setFunc = function(r, g, b, a)
                        self.savedVars.executePhaseColor = { r, g, b, a }
                        self:UpdateDisplay()
                    end,
                    default = { 1.0, 0.2, 0.2, 1.0 },
                    disabled = function() return not self.savedVars.enableExecuteTracking end,
                },
            },
        },
        {
            type = "submenu",
            name = "Style: Dials",
            controls = {

                -- if multiSelect is true the setFunc's var must be a table
                {
                    type = "checkbox",
                    name = "Enable Dials",
                    getFunc = function()
                        if self.dialContainer then
                            self.dialContainer:SetHidden(false)
                            self.dialContainer:SetAlpha(1)
                        end


                        return self.savedVars.showDials
                    end,
                    setFunc = function(value)
                        self.savedVars.showDials = value
                        self:UpdateDialVisibility()
                        if value then
                            -- Force show dials immediately, even if in menu
                            if self.dialContainer then
                                self.dialContainer:SetHidden(false)
                                self.dialContainer:SetAlpha(1)
                            end
                            self:UpdateDialsDisplay()
                        end
                    end,
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Above and Beyond Passive",
                    tooltip = "Raises the crit rate cap from 125% to 155%",
                    getFunc = function() return self.savedVars.aboveAndBeyond end,
                    setFunc = function(value)
                        self.savedVars.aboveAndBeyond = value
                        self:UpdateDialsDisplay()
                    end,
                    default = false,
                    disabled = function() return not self.savedVars.showDials end,
                },


                {
                    type = "dropdown",
                    name = "Dial 1",
                    choices = { "Hidden", "Crit Rate", "Crit Damage", "Execute Crit Rate", "Execute Crit Damage" },
                    choicesValues = { "hidden", "critRate", "critDamage", "executeCritRate", "executeCritDamage" },
                    getFunc = function() return self.savedVars.dial1Type end,
                    setFunc = function(value)
                        self.savedVars.dial1Type = value
                        self:UpdateDialVisibility()
                        self:UpdateDialsDisplay()
                    end,
                    default = "critRate",
                    disabled = function() return not self.savedVars.showDials end,
                },
                {
                    type = "dropdown",
                    name = "Dial 2",
                    choices = { "Hidden", "Crit Rate", "Crit Damage", "Execute Crit Rate", "Execute Crit Damage" },
                    choicesValues = { "hidden", "critRate", "critDamage", "executeCritRate", "executeCritDamage" },
                    getFunc = function() return self.savedVars.dial2Type end,
                    setFunc = function(value)
                        self.savedVars.dial2Type = value
                        self:UpdateDialVisibility()
                        self:UpdateDialsDisplay()
                    end,
                    default = "critDamage",
                    disabled = function() return not self.savedVars.showDials end,
                },



                {
                    type = "slider",
                    name = "Size",
                    min = 0.5,
                    max = 3.0,
                    step = 0.1,
                    getFunc = function() return self.savedVars.dialScale end,
                    setFunc = function(value)
                        self.savedVars.dialScale = value
                        self:UpdateDialScale()
                    end,
                    default = 1.0,
                    disabled = function() return not self.savedVars.showDials end,
                },
                {
                    type = "slider",
                    name = "Horizontal Position",
                    min = -GuiRoot:GetWidth(),
                    max = GuiRoot:GetWidth(),
                    step = 10,
                    getFunc = function() return self.savedVars.dialPosX end,
                    setFunc = function(value)
                        self.savedVars.dialPosX = value
                        self:UpdateDialPositions()
                    end,
                    default = 0,
                    disabled = function() return not self.savedVars.showDials end,
                },
                {
                    type = "slider",
                    name = "Vertical Position",
                    min = 0,
                    max = GuiRoot:GetHeight(),
                    step = 10,
                    getFunc = function() return self.savedVars.dialPosY end,
                    setFunc = function(value)
                        self.savedVars.dialPosY = value
                        self:UpdateDialPositions()
                    end,
                    default = 100,
                    disabled = function() return not self.savedVars.showDials end,
                },
                {
                    type = "colorpicker",
                    name = "Text Color",
                    getFunc = function()
                        local color = self.savedVars.dialColor
                        return color[1], color[2], color[3], color[4]
                    end,
                    setFunc = function(r, g, b, a)
                        self.savedVars.dialColor = { r, g, b, a }
                        self:UpdateDialsDisplay()
                    end,
                    default = { 1, 1, 1, 1 },
                    disabled = function() return not self.savedVars.showDials or self.savedVars.dialUseGradient end,
                },
                {
                    type = "checkbox",
                    name = "Use Dynamic Colors",
                    tooltip = "Color changes from red to yellow to green based on live crit chance and damage",
                    getFunc = function() return self.savedVars.dialUseGradient end,
                    setFunc = function(value)
                        self.savedVars.dialUseGradient = value
                        self:UpdateDialsDisplay()
                    end,
                    default = false,
                    disabled = function() return not self.savedVars.showDials end,
                },
                {
                    type = "checkbox",
                    name = "Title Lables",
                    getFunc = function() return self.savedVars.dial1ShowLabel end,
                    setFunc = function(value)
                        self.savedVars.dial1ShowLabel = value
                        self.savedVars.dial2ShowLabel = value
                        self:UpdateDialsDisplay()
                    end,
                    default = true,
                    disabled = function() return not self.savedVars.showDials or self.savedVars.dial1Type == "hidden" end,
                },
                --[[{
                    type = "slider",
                    name = "Title Size",
                    min = 8,
                    max = 36,
                    step = 1,
                    getFunc = function() return self.savedVars.dialLabelFontSize end,
                    setFunc = function(value)
                        self.savedVars.dialLabelFontSize = value
                        self:ApplyFontsToLabels()
                    end,
                    default = 14,
                    disabled = function() return not self.savedVars.showDials end,
                },
                {
                    type = "slider",
                    name = "Value Size",
                    min = 8,
                    max = 48,
                    step = 1,
                    getFunc = function() return self.savedVars.dialValueFontSize end,
                    setFunc = function(value)
                        self.savedVars.dialValueFontSize = value
                        self:ApplyFontsToLabels()
                    end,
                    default = 24,
                    disabled = function() return not self.savedVars.showDials end,
                },]]
            },
        },




        --TODO: make an "extra appearnce options tab for adusting fonts universally."

        {
            type = "submenu",
            name = "Extra Appeance Options",
            controls = {
                {
                    type = "dropdown",
                    name = "Font",
                    choices = fontChoices,
                    choicesValues = fontChoicesValues,
                    getFunc = function() return self.savedVars.selectedFont end,
                    setFunc = function(value)
                        self.savedVars.selectedFont = value
                        self:ApplyFontsToLabels()
                        self:UpdateDialsDisplay()
                    end,
                    default = "ESO_Standard",
                },
            },
        },


        {
            type = "submenu",
            name = "Logging",
            controls = {
                {
                    type = "checkbox",
                    name = "Show Combat Stats",
                    tooltip = [[Display fight summary in chat after each combat encounter
==Combat Summary==
Total Hits: 156 (89 crits, 67 normal)
Crit Rate: 57.1% (Max: 63.2%)
Avg Crit DMG: 8429 crit, 3891 normal (+116% / 2.17x)
Execute Phase: 73.2% crit (19/26 hits)
Execute Crit DMG: 9156 crit, 4102 normal (+123% / 2.23x)]],
                    getFunc = function() return self.savedVars.showNotifications end,
                    setFunc = function(value) self.savedVars.showNotifications = value end,
                    default = false
                },
            },
        },

        {
            type = "submenu",
            name = "Support",
            controls = {
                {
                    type = "description",
                    text = "Author: YFNatey, Xbox NA",
                    width = "full"
                },
                {
                    type = "description",
                    text = "If you find this addon useful, consider supporting its development!",
                    width = "full"
                },
                {
                    type = "button",
                    name = "Paypal",
                    tooltip = "paypal.me/yfnatey",
                    func = function() RequestOpenUnsafeURL("https://paypal.me/yfnatey") end,
                    width = "half"
                },
            },
        },
    }
    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end
