-----------------------------------------------------------
-- DarkScrollsUI - DS_Menu.lua
-- Settings panel via LibAddonMenu-2.0.
-----------------------------------------------------------

function DarkScrollsUI.BuildAddonSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local function UpdateBarVisualColor(idBarra, r, g, b)
        local control = _G[idBarra]
        if not control then return end
        local dark   = {r * 0.3, g * 0.3, b * 0.3, 1}
        local bright = {r, g, b, 1}
        control.colorMain  = dark
        control.colorLight = bright
        if control.fillBottom then control.fillBottom:SetCenterColor(unpack(dark))   end
        if control.fillTop    then control.fillTop:SetCenterColor(unpack(bright))    end
    end

    local function UpdateBarVisualAlpha(idBarra, alpha)
        local control = _G[idBarra]
        if control then control:SetAlpha(alpha) end
    end

    local function UpdateIconVisualAlpha(idOrType, alpha)
        if type(idOrType) == "number" then
            local actionSlotNames = {
                [3] = "DarkScrollsUI_ActionButtonSlotThree",
                [4] = "DarkScrollsUI_ActionButtonSlotFour",
                [5] = "DarkScrollsUI_ActionButtonSlotFive",
                [6] = "DarkScrollsUI_ActionButtonSlotSix",
                [7] = "DarkScrollsUI_ActionButtonSlotSeven",
                [8] = "DarkScrollsUI_UltimateAbilitySlot",
            }
            local name = actionSlotNames[idOrType]
            DarkScrollsUI.SavedVariables[name].a = alpha
            local ctrl = _G[name]
            if ctrl then DarkScrollsUI.UpdateSkillIconVisualStatus(ctrl, idOrType) end
        else
            DarkScrollsUI.SavedVariables["DarkScrollsUI_QuickslotItemSlot"].a = alpha
            local ctrl = _G["DarkScrollsUI_QuickslotItemSlot"]
            if ctrl then DarkScrollsUI.UpdateQuickslotIconVisualStatus(ctrl) end
        end
    end

    local function CreateColorOption(displayName, barId)
        return {
            type    = "colorpicker",
            name    = "Color: " .. displayName,
            getFunc = function()
                local c = DarkScrollsUI.SavedVariables[barId].color or DarkScrollsUI.GetDefaultProfileSettings()[barId].color
                return c.r, c.g, c.b
            end,
            setFunc = function(r, g, b)
                DarkScrollsUI.MasterSavedVariables.profiles[DarkScrollsUI.MasterSavedVariables.currentProfile][barId].color = {r=r, g=g, b=b}
                DarkScrollsUI.SavedVariables[barId].color = {r=r, g=g, b=b}
                UpdateBarVisualColor(barId, r, g, b)
            end,
        }
    end

    local function CreateAlphaOption(displayName, barId)
        return {
            type    = "slider",
            name    = "Opacity: " .. displayName,
            min     = 0, max = 100, step = 1,
            default = 100,
            getFunc = function() return (DarkScrollsUI.SavedVariables[barId].a or 1) * 100 end,
            setFunc = function(value)
                local alpha = value / 100
                DarkScrollsUI.SavedVariables[barId].a = alpha
                UpdateBarVisualAlpha(barId, alpha)
            end,
        }
    end

    local panelData = {
        type               = "panel",
        name               = "DarkScrollsUI",
        displayName        = "|c00aaffDarkScrollsUI|r",
        author             = "Beholder",
        version            = "0.1.3",
        registerForRefresh = true,
    }

    local optionsData = {
        { type = "header", name = "Profile Manager" },
        {
            type    = "dropdown",
            name    = "Active Profile",
            choices = {"1", "2", "3", "4", "5"},
            getFunc = function() return tostring(DarkScrollsUI.MasterSavedVariables.currentProfile) end,
            setFunc = function(value)
                local num = tonumber(value)
                if DarkScrollsUI.MasterSavedVariables.currentProfile ~= num then
                    SLASH_COMMANDS["/ds"..num]()
                end
            end,
        },
        {
            type    = "button",
            name    = "Reset Current Profile",
            func    = function() SLASH_COMMANDS["/dsreset"]() end,
            warning = "This will erase all settings for the current profile!",
        },
    }

    table.insert(optionsData, { type = "header", name = "Edit Modes" })
    table.insert(optionsData, {
        type = "button",
        name = "Edit Individual",
        func = function() SLASH_COMMANDS["/ds"]() end,
    })
    table.insert(optionsData, {
        type = "button",
        name = "Move Group",
        func = function() SLASH_COMMANDS["/dsall"]() end,
    })

    table.insert(optionsData, { type = "header", name = "Bar Configuration" })

    local bars = {
        {n = "Health",        id = "DarkScrollsUI_PlayerHealthBar"},
        {n = "Magicka",       id = "DarkScrollsUI_PlayerMagickaBar"},
        {n = "Stamina",       id = "DarkScrollsUI_PlayerStaminaBar"},
        {n = "Shield",        id = "DarkScrollsUI_PlayerShieldBar"},
        {n = "Mount Stamina", id = "DarkScrollsUI_PlayerMountStaminaBar"},
    }
    for _, bar in ipairs(bars) do
        table.insert(optionsData, CreateColorOption(bar.n, bar.id))
        table.insert(optionsData, CreateAlphaOption(bar.n, bar.id))
    end

    table.insert(optionsData, { type = "header", name = "Icon Opacity" })
    table.insert(optionsData, {
        type    = "slider",
        name    = "Normal Skills (Slots 3-7)",
        tooltip = "Controls the base opacity of all 5 normal skill slots.",
        min     = 0, max = 100, step = 1,
        getFunc = function() return (DarkScrollsUI.SavedVariables["DarkScrollsUI_ActionButtonSlotThree"].a or 1) * 100 end,
        setFunc = function(value)
            local alpha = value / 100
            for i = 3, 7 do UpdateIconVisualAlpha(i, alpha) end
        end,
    })
    table.insert(optionsData, {
        type    = "slider",
        name    = "Ultimate",
        min     = 0, max = 100, step = 1,
        getFunc = function() return (DarkScrollsUI.SavedVariables["DarkScrollsUI_UltimateAbilitySlot"].a or 1) * 100 end,
        setFunc = function(value) UpdateIconVisualAlpha(8, value / 100) end,
    })
    table.insert(optionsData, {
        type    = "slider",
        name    = "Quickslot Item",
        min     = 0, max = 100, step = 1,
        getFunc = function() return (DarkScrollsUI.SavedVariables["DarkScrollsUI_QuickslotItemSlot"].a or 1) * 100 end,
        setFunc = function(value) UpdateIconVisualAlpha("Quickslot", value / 100) end,
    })

    table.insert(optionsData, { type = "header", name = DarkScrollsUI.LocalizationStrings.GraySkillsLabel })
    table.insert(optionsData, {
        type     = "checkbox",
        name     = DarkScrollsUI.LocalizationStrings.EnabledLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.GraySkillsTooltip,
        getFunc  = function() return DarkScrollsUI.SavedVariables.graySkillsEnabled end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.graySkillsEnabled = value end,
        default  = true,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.GraySatLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.GraySatTooltip,
        min      = 0, max = 100, step = 1,
        default  = 15,
        getFunc  = function() return math.floor((DarkScrollsUI.SavedVariables.graySaturation or 0.15) * 100 + 0.5) end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.graySaturation = value / 100 end,
        disabled = function() return not DarkScrollsUI.SavedVariables.graySkillsEnabled end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.GrayUltSatLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.GrayUltSatTooltip,
        min      = 0, max = 100, step = 1,
        default  = 90,
        getFunc  = function() return math.floor((DarkScrollsUI.SavedVariables.grayUltSaturation or 0.90) * 100 + 0.5) end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.grayUltSaturation = value / 100 end,
        disabled = function() return not DarkScrollsUI.SavedVariables.graySkillsEnabled end,
    })

    -----------------------------------------------------------
    -- DAMAGE FLASH SECTION
    -----------------------------------------------------------
    table.insert(optionsData, { type = "header", name = "|cff0000" .. DarkScrollsUI.LocalizationStrings.DamageFlashLabel .. "|r" })
    table.insert(optionsData, {
        type    = "checkbox",
        name    = DarkScrollsUI.LocalizationStrings.EnabledLabel,
        tooltip = DarkScrollsUI.LocalizationStrings.DamageFlashTooltip,
        getFunc = function()
            return DarkScrollsUI.SavedVariables.damageFlashEnabled
        end,
        setFunc = function(value)
            DarkScrollsUI.SavedVariables.damageFlashEnabled = value
        end,
        default = true,
    })
    -- Threshold that separates light from heavy hits
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashThresholdLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashThresholdTooltip,
        min      = 1, max = 50, step = 1,
        default  = 10,
        getFunc  = function() return math.floor((DarkScrollsUI.SavedVariables.damageFlashHeavyThreshold or 0.10) * 100 + 0.5) end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashHeavyThreshold = value / 100 end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })

    -- ── LIGHT HIT ───────────────────────────────────────────
    table.insert(optionsData, { type = "header", name = "" .. DarkScrollsUI.LocalizationStrings.DamageFlashLightHeader })
    table.insert(optionsData, {
        type    = "button",
        name    = "Test Light Hit",
        tooltip = "Triggers the light-hit once for preview. Camera effect don't work while in menu. Better test in real combat.",
        func    = function() DarkScrollsUI.TestDamageFlashLightEffect() end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashShakeLightLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashShakeLightTooltip,
        min      = 0, max = 100, step = 1,
        default  = 3,
        getFunc  = function() return math.floor((DarkScrollsUI.SavedVariables.damageFlashLightShakeIntensity or 0.03) * 1000 + 0.5) end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashLightShakeIntensity = value / 1000 end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashAlphaLightLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashAlphaLightTooltip,
        min      = 0, max = 100, step = 1,
        default  = 35,
        getFunc  = function() return math.floor((DarkScrollsUI.SavedVariables.damageFlashLightAlphaPeak or 0.35) * 100 + 0.5) end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashLightAlphaPeak = value / 100 end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashDurLightLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashDurLightTooltip,
        min      = 50, max = 1000, step = 50,
        default  = 150,
        getFunc  = function() return DarkScrollsUI.SavedVariables.damageFlashLightDuration or 150 end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashLightDuration = value end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashZoomDistLightLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashZoomDistLightTooltip,
        min      = 0, max = 50, step = 1,
        default  = 4,
        getFunc  = function() return math.floor((DarkScrollsUI.SavedVariables.damageFlashLightZoomDistance or 0.4) * 10 + 0.5) end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashLightZoomDistance = value / 10 end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashZoomRetLightLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashZoomRetLightTooltip,
        min      = 50, max = 3000, step = 50,
        default  = 600,
        getFunc  = function() return DarkScrollsUI.SavedVariables.damageFlashLightZoomReturn or 600 end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashLightZoomReturn = value end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })

    -- ── HEAVY HIT ───────────────────────────────────────────
    table.insert(optionsData, { type = "header", name = "" .. DarkScrollsUI.LocalizationStrings.DamageFlashHeavyHeader })
    table.insert(optionsData, {
        type    = "button",
        name    = "Test Heavy Hit",
        tooltip = "Triggers the heavy-hit once for preview. Camera effect don't work while in menu. Better test in real combat.",
        func    = function() DarkScrollsUI.TestDamageFlashHeavyEffect() end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashShakeHeavyLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashShakeHeavyTooltip,
        min      = 0, max = 100, step = 1,
        default  = 9,
        getFunc  = function() return math.floor((DarkScrollsUI.SavedVariables.damageFlashHeavyShakeIntensity or 0.09) * 1000 + 0.5) end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashHeavyShakeIntensity = value / 1000 end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashAlphaHeavyLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashAlphaHeavyTooltip,
        min      = 0, max = 100, step = 1,
        default  = 70,
        getFunc  = function() return math.floor((DarkScrollsUI.SavedVariables.damageFlashHeavyAlphaPeak or 0.70) * 100 + 0.5) end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashHeavyAlphaPeak = value / 100 end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashDurHeavyLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashDurHeavyTooltip,
        min      = 50, max = 1000, step = 50,
        default  = 350,
        getFunc  = function() return DarkScrollsUI.SavedVariables.damageFlashHeavyDuration or 350 end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashHeavyDuration = value end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashZoomDistHeavyLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashZoomDistHeavyTooltip,
        min      = 0, max = 50, step = 1,
        default  = 10,
        getFunc  = function() return math.floor((DarkScrollsUI.SavedVariables.damageFlashHeavyZoomDistance or 1.0) * 10 + 0.5) end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashHeavyZoomDistance = value / 10 end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })
    table.insert(optionsData, {
        type     = "slider",
        name     = DarkScrollsUI.LocalizationStrings.DamageFlashZoomRetHeavyLabel,
        tooltip  = DarkScrollsUI.LocalizationStrings.DamageFlashZoomRetHeavyTooltip,
        min      = 50, max = 3000, step = 50,
        default  = 1000,
        getFunc  = function() return DarkScrollsUI.SavedVariables.damageFlashHeavyZoomReturn or 1000 end,
        setFunc  = function(value) DarkScrollsUI.SavedVariables.damageFlashHeavyZoomReturn = value end,
        disabled = function() return not DarkScrollsUI.SavedVariables.damageFlashEnabled end,
    })

    -----------------------------------------------------------
    -- QUEST TRACKER SECTION
    -----------------------------------------------------------
    table.insert(optionsData, { type = "header", name = "|cffff00" .. DarkScrollsUI.LocalizationStrings.QuestTrackerLabel .. "|r" })
    table.insert(optionsData, {
        type    = "checkbox",
        name    = DarkScrollsUI.LocalizationStrings.EnabledLabel,
        tooltip = DarkScrollsUI.LocalizationStrings.QuestTrackerTooltip,
        getFunc = function()
            return DarkScrollsUI.SavedVariables.customQuestTrackerEnabled
        end,
        setFunc = function(value)
            DarkScrollsUI.SavedVariables.customQuestTrackerEnabled = value
            -- Apply immediately without requiring a reload
            DarkScrollsUI.ApplyQuestTrackerDisplaySetting()
        end,
        default = true,
    })

    local myPanel = LAM:RegisterAddonPanel("DarkScrollsUIOptions", panelData)
    LAM:RegisterOptionControls("DarkScrollsUIOptions", optionsData)

    DarkScrollsUI.isSettingsMenuOpen = false

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel == myPanel then DarkScrollsUI.isSettingsMenuOpen = true end
    end)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == myPanel then DarkScrollsUI.isSettingsMenuOpen = false end
    end)
end
