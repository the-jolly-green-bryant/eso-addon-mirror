---=============================================================================
-- Settings
--=============================================================================

function ShouldIUlt:CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = "Buffy",
        displayName = "Buffy",
        author = "YFNatey",
        version = ShouldIUlt.version,
        slashCommand = "/shouldiult",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "header",
            width = "full",
            name = "Buff Tracking",
        },

        {
            type = "checkbox",
            name = "Show Tracker",
            getFunc = function() return ShouldIUlt.savedVars.uiVisible end,
            setFunc = function(value)
                ShouldIUlt.savedVars.uiVisible = value
                BuffTrackerContainer:SetHidden(not value)
                if value then
                    ShouldIUlt:UpdateUI()
                end
            end,
            default = true,
        },

        {
            type = "checkbox",
            name = "Hide Permanent Buffs",
            getFunc = function() return ShouldIUlt.savedVars.hidePermanentBuffs end,
            setFunc = function(value)
                ShouldIUlt.savedVars.hidePermanentBuffs = value
                ShouldIUlt:UpdateUI()
            end,
        },
        {
            type = "header",
            name = "Enemy Debuffs",
        },
        ShouldIUlt:CreateBuffToggleOption("vulnerability", "Vulnerability",
            "|t48:48:/esoui/art/icons/ability_debuff_major_vulnerability.dds|t",
            "|t48:48:/esoui/art/icons/ability_debuff_minor_vulnerability.dds|t"),

        ShouldIUlt:CreateBuffToggleOption("offBalance", "Off-Balance",
            "|t48:48:/esoui/art/icons/ability_debuff_offbalance.dds|t",
            "|t48:48:/esoui/art/icons/ability_debuff_offbalance.dds|t"),

        ShouldIUlt:CreateBuffToggleOption("brittle", "Brittle",
            "|t48:48:/esoui/art/icons/ability_debuff_major_brittle.dds|t",
            "|t48:48:/esoui/art/icons/ability_debuff_minor_brittle.dds|t"),

        {
            type = "header",
            name = "Player Damage Buffs",
        },

        ShouldIUlt:CreateBuffToggleOption("slayer", "Slayer",
            "|t48:48:/esoui/art/icons/ability_buff_major_slayer.dds|t",
            "|t48:48:/esoui/art/icons/ability_buff_minor_slayer.dds|t"),

        ShouldIUlt:CreateBuffToggleOption("berserk", "Berserk",
            "|t48:48:/esoui/art/icons/ability_buff_major_berserk.dds|t",
            "|t48:48:/esoui/art/icons/ability_buff_minor_berserk.dds|t"),

        ShouldIUlt:CreateBuffToggleOption("force", "Force",
            "|t48:48:/esoui/art/icons/ability_buff_major_force.dds|t",
            "|t48:48:/esoui/art/icons/ability_buff_minor_force.dds|t"),

        ShouldIUlt:CreateBuffToggleOption("PowerfulAssault", "Powerful Assault",
            "|t48:48:/esoui/art/icons/ability_healer_019.dds|t",
            "|t48:48:/esoui/art/icons/ability_healer_019.dds|t"),

        ShouldIUlt:CreateBuffToggleOption("courage", "Courage",
            "|t48:48:/esoui/art/icons/ability_buff_major_courage.dds|t",
            "|t48:48:/esoui/art/icons/ability_buff_minor_courage.dds|t"),
        ShouldIUlt:CreateBuffToggleOption("feedingFrenzy", "Feeding Frenzy",
            "|t48:48:/esoui/art/icons/ability_werewolf_005_b.dds|t",
            "|t48:48:/esoui/art/icons/ability_werewolf_005_b.dds|t"),
        ShouldIUlt:CreateCombinedBuffToggleOption("trackWeaponSpellDamage", "Weapon & Spell Damage",
            "",
            { "Major Brutality", "Major Sorcery" },
            { "Minor Brutality", "Minor Sorcery" }),

        ShouldIUlt:CreateCombinedBuffToggleOption("trackWeaponSpellCrit", "Weapon & Spell Critical",
            "",
            { "Major Savagery", "Major Prophecy" },
            { "Minor Savagery", "Minor Prophecy" }),

        {
            type = "header",
            name = "Other Buffs",
        },

        ShouldIUlt:CreateBuffToggleOption("heroism", "Heroism",
            "|t48:48:/esoui/art/icons/ability_buff_major_heroism.dds|t",
            "|t48:48:/esoui/art/icons/ability_buff_minor_heroism.dds|t"),

        ShouldIUlt:CreateBuffToggleOption("resolve", "Resolve",
            "|t48:48:/esoui/art/icons/ability_buff_major_resolve.dds|t",
            "|t48:48:/esoui/art/icons/ability_buff_minor_resolve.dds|t"),

        ShouldIUlt:CreateBuffToggleOption("protection", "Protection",
            "",
            "|t48:48:/esoui/art/icons/ability_buff_minor_protection.dds|t")
        ,


        {
            type = "submenu",
            name = "Display Settings",
            controls = {
                {
                    type = "checkbox",
                    name = "Test Display",
                    tooltip = "For testing layout",
                    getFunc = function() return ShouldIUlt.savedVars.simulationMode end,
                    setFunc = function(value)
                        ShouldIUlt:SetSimulationMode(value)
                    end,
                },
                {
                    type = "slider",
                    name = "Number of Columns",
                    min = 1,
                    max = 14,
                    step = 1,
                    getFunc = function() return ShouldIUlt.savedVars.maxIconsPerRow or 7 end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.maxIconsPerRow = value
                        ShouldIUlt:UpdateUI()
                    end,
                    width = "half",
                    disabled = function() return ShouldIUlt.savedVars.layoutDirection == "vertical" end,
                },
                {
                    type = "slider",
                    name = "Horizontal Position",
                    min = -1960,
                    max = 1960,
                    step = 20,
                    getFunc = function() return ShouldIUlt.savedVars.positionX end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.positionX = value
                        ShouldIUlt:UpdateUIPosition()
                    end,
                    width = "half",
                },
                {
                    type = "slider",
                    name = "Vertical Position",
                    min = -1540,
                    max = 1540,
                    step = 20,
                    getFunc = function() return ShouldIUlt.savedVars.positionY end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.positionY = value
                        ShouldIUlt:UpdateUIPosition()
                    end,
                    width = "half",
                },
                {
                    type = "slider",
                    name = "Icon Size",

                    min = 30,
                    max = 70,
                    step = 10,
                    getFunc = function() return ShouldIUlt.savedVars.iconSize end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.iconSize = value
                        ShouldIUlt:UpdateUI()
                    end,
                    width = "half",
                },
                {
                    type = "checkbox",
                    name = "Timers",
                    getFunc = function() return ShouldIUlt.savedVars.showTimer end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.showTimer = value
                        ShouldIUlt:UpdateUI()
                    end,
                },
                {
                    type = "slider",
                    name = "Decimal Threshold",
                    min = 1.0,
                    max = 30.0,
                    step = 0.5,
                    getFunc = function() return ShouldIUlt.savedVars.timerThreshold or 10.0 end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.timerThreshold = value
                        ShouldIUlt:UpdateUI()
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.showTimer end,

                },

            },


        },

        --[[{
            type = "divider"
        },
        {
            type = "checkbox",
            name = "Static Display Mode",
            tooltip =
            "Show transparent icons for all tracked buffs. Active buffs become fully visible.",
            getFunc = function() return ShouldIUlt.savedVars.staticContainer end,
            setFunc = function(value)
                ShouldIUlt.savedVars.staticContainer = value
                if value then
                    ShouldIUlt.savedVars.hidePermanentBuffs = false
                end
                ShouldIUlt:UpdateUI()
            end,
        },
        {
            type = "slider",
            name = "Inactive Buff Opacity",
            tooltip =
            "How transparent inactive buffs appear in static display mode",
            min = 0.1,
            max = 1.0,
            step = 0.1,
            getFunc = function() return ShouldIUlt.savedVars.inactiveBuffOpacity or 0.3 end,
            setFunc = function(value)
                ShouldIUlt.savedVars.inactiveBuffOpacity = value
                ShouldIUlt:UpdateUI()
            end,
            disabled = function() return not ShouldIUlt.savedVars.staticContainer end,
        },]]
        {
            type = "submenu",
            name = "Should I Ult?",
            controls = {
                {
                    type = "description",
                    text =
                    " This is a helpful tool for damage dealers to maximize your DPS. It will train you to use your ultimate when key buffs are active.",
                },
                {
                    type = "checkbox",
                    name = "Enable",
                    getFunc = function() return ShouldIUlt.savedVars.enableUltCheck end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.enableUltCheck = value
                        ShouldIUlt:UpdateUI()
                    end,
                },
                {
                    type = "dropdown",
                    name = "Ult Check Mode",
                    tooltip =
                    "ANY = Show ult message when any required buff is active\nALL = Show ult message only when ALL required buffs are active",
                    choices = { "Any Required Buff", "All Required Buffs" },
                    choicesValues = { "any", "all" },
                    getFunc = function()
                        return ShouldIUlt.savedVars.ultCheckMode == "any" and "Any Required Buff" or "All Required Buffs"
                    end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultCheckMode = (value == "Any Required Buff") and "any" or "all"
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },
                {
                    type = "slider",
                    name = "Message Size",
                    tooltip = "Size of the ULT NOW message",
                    min = 1,
                    max = 4,
                    step = 0.5,
                    getFunc = function() return ShouldIUlt.savedVars.ultMessageSize end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultMessageSize = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },

                {
                    type = "checkbox",
                    name = "Play Sound",
                    tooltip = "Play a sound when ult conditions are met",
                    getFunc = function() return ShouldIUlt.savedVars.ultMessageSound end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultMessageSound = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },


                -- DAMAGE DEBUFFS SECTION

                {
                    type = "checkbox",
                    name = "Major Vulnerability",
                    getFunc = function() return ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorVulnerability end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorVulnerability = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },
                {
                    type = "checkbox",
                    name = "Minor Vulnerability",
                    getFunc = function() return ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorVulnerability end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorVulnerability = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },
                {
                    type = "checkbox",
                    name = "Minor Brittle",
                    getFunc = function() return ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorBrittle end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorBrittle = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },
                {
                    type = "checkbox",
                    name = "Off-Balance",
                    getFunc = function() return ShouldIUlt.savedVars.ultRequiredBuffs.trackOffBalance end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultRequiredBuffs.trackOffBalance = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },

                {
                    type = "checkbox",
                    name = "Major Slayer",
                    getFunc = function() return ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorSlayer end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorSlayer = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },
                {
                    type = "checkbox",
                    name = "Major Force",
                    getFunc = function() return ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorForce end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorForce = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },
                {
                    type = "checkbox",
                    name = "Major Berserk",
                    getFunc = function() return ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorBerserk end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultRequiredBuffs.trackMajorBerserk = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },
                {
                    type = "checkbox",
                    name = "Minor Berserk",
                    getFunc = function() return ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorBerserk end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultRequiredBuffs.trackMinorBerserk = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },
                {
                    type = "checkbox",
                    name = "Powerful Assault",
                    getFunc = function() return ShouldIUlt.savedVars.ultRequiredBuffs.trackPowerfulAssault end,
                    setFunc = function(value)
                        ShouldIUlt.savedVars.ultRequiredBuffs.trackPowerfulAssault = value
                    end,
                    disabled = function() return not ShouldIUlt.savedVars.enableUltCheck end,
                },
            },
        }





    }
    LAM:RegisterAddonPanel("ShouldIUltPanel", panelData)
    LAM:RegisterOptionControls("ShouldIUltPanel", optionsData)
end

function ShouldIUlt:CreateBuffToggleOption(buffType, displayName, majorIcon, minorIcon)
    local data = self.buffTypeMap[buffType]
    if not data then return nil end

    local tooltip = "\n\n\n\n\n\n\n"

    -- Add major buff info if it exists
    if data.major then
        tooltip = tooltip .. majorIcon .. "|cFFFFFF• " .. data.major .. "|r"
    end

    -- Add minor buff info if it exists
    if data.minor then
        -- Add a newline separator if we already have major buff text
        if tooltip ~= "" then
            tooltip = tooltip .. "\n"
        end
        tooltip = tooltip .. minorIcon .. "|cFFFFFF• " .. data.minor .. "|r"
    end

    return {
        type = "checkbox",
        name = displayName,
        tooltip = tooltip,
        getFunc = function() return ShouldIUlt.savedVars[data.setting] end,
        setFunc = function(value)
            ShouldIUlt.savedVars[data.setting] = value
            ShouldIUlt:ScanCurrentBuffs()
            self.staticSlotsCache = nil
            self.lastStaticSettingsHash = nil
            self:UpdateUI()
        end,
    }
end

function ShouldIUlt:CreateCombinedBuffToggleOption(settingName, displayName, description, majorBuffs, minorBuffs)
    local tooltip = "\n\n\n\n" .. description .. "\n"

    -- Add major buffs to tooltip with icons
    if majorBuffs and #majorBuffs > 0 then
        tooltip = tooltip .. "\n|cFFD700Major:|r"
        for _, buffName in ipairs(majorBuffs) do
            local iconPath = self:GetBuffIcon(buffName)
            local iconTag = string.format("|t48:48:%s|t", iconPath)
            tooltip = tooltip .. "\n" .. iconTag .. "|cFFFFFF• " .. buffName .. "|r"
        end
    end

    -- Add minor buffs to tooltip with icons
    if minorBuffs and #minorBuffs > 0 then
        tooltip = tooltip .. "\n|c87CEEBMinor:|r"
        for _, buffName in ipairs(minorBuffs) do
            local iconPath = self:GetBuffIcon(buffName)
            local iconTag = string.format("|t48:48:%s|t", iconPath)
            tooltip = tooltip .. "\n" .. iconTag .. "|cFFFFFF• " .. buffName .. "|r"
        end
    end

    -- Add bottom spacing for balance
    tooltip = tooltip .. "\n\n\n\n"

    return {
        type = "checkbox",
        name = displayName,
        tooltip = tooltip,
        getFunc = function() return ShouldIUlt.savedVars[settingName] end,
        setFunc = function(value)
            ShouldIUlt.savedVars[settingName] = value
            ShouldIUlt:SyncCombinedSettings()
            ShouldIUlt:ScanCurrentBuffs()
            self.staticSlotsCache = nil
            self.lastStaticSettingsHash = nil
            self:UpdateUI()
        end,
    }
end

function ShouldIUlt:CreateBuffLegendTooltip()
    local legendText = "BUFF LEGEND\n\n"

    -- Major Buffs Column
    legendText = legendText .. "|cFFFFFF=== MAJOR BUFFS ===|r\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_debuff_major_vulnerability.dds|t Major Vulnerability\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_major_slayer.dds|t Major Slayer\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_major_brutality.dds|t Major Brutality\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_major_sorcery.dds|t Major Sorcery\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_major_prophecy.dds|t Major Prophecy\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_major_savagery.dds|t Major Savagery\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_major_resolve.dds|t Major Resolve\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_debuff_major_brittle.dds|t Major Brittle\n"

    -- ADD: New Major buffs to the legend
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_major_force.dds|t Major Force\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_major_berserk.dds|t Major Berserk\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_major_heroism.dds|t Major Heroism\n"

    legendText = legendText .. "\n|cFFFFFF=== MINOR BUFFS ===|r\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_debuff_minor_vulnerability.dds|t Minor Vulnerability\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_slayer.dds|t Minor Slayer\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_brutality.dds|t Minor Brutality\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_sorcery.dds|t Minor Sorcery\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_prophecy.dds|t Minor Prophecy\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_savagery.dds|t Minor Savagery\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_resolve.dds|t Minor Resolve\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_debuff_minor_brittle.dds|t Minor Brittle\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_berserk.dds|t Minor Berserk\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_debuff_minor_breach.dds|t Minor Breach\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_courage.dds|t Minor Courage\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_evasion.dds|t Minor Evasion\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_force.dds|t Minor Force\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_fortitude.dds|t Minor Fortitude\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_heroism.dds|t Minor Heroism\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_buff_minor_protection.dds|t Minor Protection\n"

    legendText = legendText .. "\n|cFFFFFF=== OTHER BUFFS ===|r\n"
    legendText = legendText .. "|t24:24:/esoui/art/icons/ability_healer_019.dds|t Powerful Assault\n"
    legendText = legendText .. "|c008FB3|t24:24:/esoui/art/icons/ability_debuff_offbalance.dds|t Off-Balance|r\n"
    legendText = legendText ..
        "|cFF0500|t24:24:/esoui/art/icons/ability_debuff_offbalance.dds|t Off-Balance Immunity|r\n"
    return legendText
end

function ShouldIUlt:SyncCombinedSettings()
    -- Sync weapon/spell damage buffs
    ShouldIUlt.savedVars.trackBrutality = ShouldIUlt.savedVars.trackWeaponSpellDamage
    ShouldIUlt.savedVars.trackSorcery = ShouldIUlt.savedVars.trackWeaponSpellDamage

    -- Sync weapon/spell crit buffs
    ShouldIUlt.savedVars.trackProphecy = ShouldIUlt.savedVars.trackWeaponSpellCrit
    ShouldIUlt.savedVars.trackSavagery = ShouldIUlt.savedVars.trackWeaponSpellCrit
end
