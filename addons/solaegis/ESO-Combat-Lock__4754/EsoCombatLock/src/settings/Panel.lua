-- EsoCombatLock - LibAddonMenu-2.0 settings panel

local ECL = EsoCombatLock
local Slots = ECL.Slots

local PANEL_NAME = "EsoCombatLockPanel"
local substituteDropdown = nil
local lamPanel = nil

local function refreshSubstituteDropdown()
    local choices, values, tooltips = Slots.BuildSubstituteChoices()
    if substituteDropdown and substituteDropdown.UpdateChoices then
        substituteDropdown:UpdateChoices(choices, values, tooltips)
    end
    return choices, values, tooltips
end

function ECL.OpenSettings()
    if LibAddonMenu2 and LibAddonMenu2.OpenToPanel and lamPanel then
        LibAddonMenu2:OpenToPanel(lamPanel)
    else
        ECL.Chat("Open Settings > Addons > ESO Combat Lock")
    end
end

function ECL.RegisterSettingsPanel()
    if not LibAddonMenu2 then
        ECL.Chat("LibAddonMenu-2.0 not found — use /ecl for status; settings UI unavailable")
        return
    end

    local LAM = LibAddonMenu2
    local choices, values, tooltips = Slots.BuildSubstituteChoices()

    local panelData = {
        type = "panel",
        name = "ESO Combat Lock",
        displayName = "ESO Combat Lock",
        author = ECL.AUTHOR,
        version = ECL.VERSION,
        slashCommand = "/eclsettings",
        registerForRefresh = true,
        registerForDefaults = true,
        website = ECL.WEBSITE_URL,
        feedback = ECL.FEEDBACK_URL,
        donation = ECL.OpenGoldDonationMail,
    }

    local function getSubstituteKey()
        local sub = ECL.GetSubstitute()
        if not sub then
            return ECL.NONE_KEY
        end
        return Slots.MakeKey(sub.actionType, sub.actionId)
    end

    local function setSubstituteKey(key)
        if not key or key == ECL.NONE_KEY then
            ECL.SetSubstitute(nil, nil, nil)
            ECL.Chat("Combat substitute cleared (revert to last safe slot)")
            return
        end
        local actionType, actionId = Slots.ParseKey(key)
        if not actionType then
            return
        end
        local slot = Slots.FindSlotForResource(actionType, actionId)
        local name = slot and Slots.GetName(slot) or key
        ECL.SetSubstitute(actionType, actionId, name)
        ECL.Chat("Combat substitute set to: " .. tostring(name))
    end

    local optionsTable = {
        {
            type = "header",
            name = "Combat Guard",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable combat guard",
            tooltip = "While in combat with a companion out, block quickslot selection of companions, assistants, and (optionally) vanity pets.",
            getFunc = function()
                return ECL.IsGuardEnabled()
            end,
            setFunc = function(value)
                ECL.db.guardEnabled = value
            end,
            default = ECL.defaults.guardEnabled,
        },
        {
            type = "checkbox",
            name = "Treat vanity pets as risky",
            tooltip = "Also block non-combat vanity pet collectibles on the quickslot wheel during combat.",
            getFunc = function()
                return ECL.IncludeVanityPets()
            end,
            setFunc = function(value)
                ECL.db.includeVanityPets = value
            end,
            default = ECL.defaults.includeVanityPets,
        },
        {
            type = "header",
            name = "Combat Substitute Resource",
            width = "full",
        },
        {
            type = "description",
            text = function()
                local key = ECL.GetQuickslotKeyLabel()
                return string.format(
                    "Choose what %s should activate instead of your companion during combat. "
                        .. "Default is None: risky slots are still blocked, and selection reverts to your last safe quickslot. "
                        .. "If you pick a resource that later runs out or is unslotted, the guard parks on a memento (if slotted) or an empty quickslot so %s does nothing.",
                    key,
                    key
                )
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Substitute resource",
            tooltip = "Built from your currently slotted, non-risky quickslot entries. Persists by resource identity, not wheel position.",
            choices = choices,
            choicesValues = values,
            choicesTooltips = tooltips,
            getFunc = getSubstituteKey,
            setFunc = setSubstituteKey,
            default = ECL.NONE_KEY,
            width = "full",
            scrollable = true,
            reference = "ECL_SubstituteDropdown",
        },
        {
            type = "button",
            name = "Refresh resource list",
            tooltip = "Rebuild the dropdown from your current quickslot wheel contents.",
            func = function()
                local c = refreshSubstituteDropdown()
                ECL.Chat("Substitute resource list refreshed (" .. tostring(#c - 1) .. " options)")
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Prefer detectable no-op (memento)",
            tooltip = "When the guard needs a no-op park, prefer a slotted memento over an empty slot. "
                .. "Mementos are blocked in combat, so pressing the quickslot key can be announced without consuming anything. "
                .. "Falls back to an empty slot if no memento is on the wheel.",
            getFunc = function()
                return ECL.PreferDetectableNoOp()
            end,
            setFunc = function(value)
                ECL.db.preferDetectableNoOp = value
            end,
            default = ECL.defaults.preferDetectableNoOp,
            width = "full",
        },
        {
            type = "header",
            name = "Lock Indicator",
            width = "full",
        },
        {
            type = "description",
            text = "Companion portrait with a lock overlay while in combat. "
                .. "Choose whether the icon stays on screen at all times or only during combat with a companion out. "
                .. "Use /ecl move for a temporary out-of-combat reposition, or uncheck Lock indicator position.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Always show indicator",
            tooltip = "When checked, the companion icon stays visible at all times (lock overlay still appears only in combat). "
                .. "When unchecked, the icon is shown only while you are in combat with an active companion.",
            getFunc = function()
                return ECL.db.indicatorAlwaysVisible == true
            end,
            setFunc = function(value)
                ECL.db.indicatorAlwaysVisible = value
                ECL.Indicator.Refresh()
            end,
            default = ECL.defaults.indicatorAlwaysVisible,
        },
        {
            type = "checkbox",
            name = "Lock indicator position",
            tooltip = "When checked, the indicator is pinned and click-through. Uncheck to drag it when visible. "
                .. "/ecl move temporarily turns Always show indicator on and unlocks for reposition, "
                .. "then restores your prior Always show setting when reposition ends.",
            getFunc = function()
                return ECL.IsIndicatorLocked()
            end,
            setFunc = function(value)
                ECL.db.indicatorLocked = value
                ECL.Indicator.Refresh()
            end,
            default = ECL.defaults.indicatorLocked,
        },
        {
            type = "slider",
            name = "Indicator size",
            tooltip = "Pixel size of the on-screen lock indicator.",
            min = 32,
            max = 128,
            step = 4,
            getFunc = function()
                return ECL.db.indicatorSize or ECL.defaults.indicatorSize
            end,
            setFunc = function(value)
                ECL.db.indicatorSize = value
                ECL.Indicator.Initialize()
            end,
            default = ECL.defaults.indicatorSize,
            width = "half",
        },
        {
            type = "button",
            name = "Reset indicator location",
            tooltip = "Move the indicator back to the default screen position if it was dragged off-screen or lost.",
            func = function()
                ECL.Indicator.ResetPosition()
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = "Combat halo",
            tooltip = "Pulsing additive glow around the lock indicator while in combat. "
                .. "/ecl testglow forces the halo on for diagnostics even when this is off.",
            getFunc = function()
                return ECL.db.haloEnabled ~= false
            end,
            setFunc = function(value)
                ECL.db.haloEnabled = value
                ECL.Indicator.Refresh()
            end,
            default = ECL.defaults.haloEnabled,
        },
        {
            type = "colorpicker",
            name = "Halo color",
            tooltip = "Tint of the combat halo ring. The inner glow is a lighter blend of this color.",
            getFunc = function()
                return ECL.db.haloColorR or ECL.defaults.haloColorR,
                    ECL.db.haloColorG or ECL.defaults.haloColorG,
                    ECL.db.haloColorB or ECL.defaults.haloColorB
            end,
            setFunc = function(r, g, b)
                ECL.db.haloColorR = r
                ECL.db.haloColorG = g
                ECL.db.haloColorB = b
                ECL.Indicator.Refresh()
            end,
            default = {
                r = ECL.defaults.haloColorR,
                g = ECL.defaults.haloColorG,
                b = ECL.defaults.haloColorB,
            },
            disabled = function()
                return ECL.db.haloEnabled == false
            end,
        },
        {
            type = "slider",
            name = "Halo intensity",
            tooltip = "Brightness of the combat halo pulse (25% dimmer to 150% brighter). "
                .. "Peak brightness is clamped so the additive glow does not wash out into a solid disc.",
            min = 25,
            max = 150,
            step = 5,
            getFunc = function()
                return ECL.db.haloIntensity or ECL.defaults.haloIntensity
            end,
            setFunc = function(value)
                ECL.db.haloIntensity = value
                ECL.Indicator.Refresh()
            end,
            default = ECL.defaults.haloIntensity,
            width = "half",
            disabled = function()
                return ECL.db.haloEnabled == false
            end,
        },
        {
            type = "header",
            name = "Post-Combat Recovery",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto-resummon companion after combat",
            tooltip = "If your companion was dismissed during the fight, retry summoning once combat ends (subject to cooldown / zone blocks).",
            getFunc = function()
                return ECL.IsResummonEnabled()
            end,
            setFunc = function(value)
                ECL.db.resummonEnabled = value
            end,
            default = ECL.defaults.resummonEnabled,
        },
        {
            type = "header",
            name = "Alerts",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Alert on quickslot activity in combat",
            tooltip = function()
                return string.format(
                    "Announces in chat when you press %s during combat and a quickslot use is detectable "
                        .. "(resource used, memento no-op, or blocked collectible). "
                        .. "Does not announce when the guard silently parks at combat start or when you spin the wheel. "
                        .. "ESO does not expose raw key presses, so a press on an empty no-op slot cannot be announced.",
                    ECL.GetQuickslotKeyLabel()
                )
            end,
            getFunc = function()
                return ECL.IsPressAlertsEnabled()
            end,
            setFunc = function(value)
                ECL.db.pressAlertsEnabled = value
            end,
            default = ECL.defaults.pressAlertsEnabled,
        },
        {
            type = "header",
            name = "Diagnostics",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug logging",
            tooltip = "Extra chat spam for diagnosing quickslot index / guard behavior. Also available via /ecl debug.",
            getFunc = function()
                return ECL.db.debug == true
            end,
            setFunc = function(value)
                ECL.db.debug = value
            end,
            default = ECL.defaults.debug,
        },
    }

    table.insert(optionsTable, {
        type = "button",
        name = "Reset All Settings",
        tooltip = "Restore every setting to its default value, including indicator position and combat substitute.",
        warning = "This cannot be undone.",
        isDangerous = true,
        func = function()
            ECL.ResetSettings()
            if ECL.Indicator and ECL.Indicator.Initialize then
                ECL.Indicator.Initialize()
            end
            refreshSubstituteDropdown()
            if lamPanel and lamPanel.RefreshPanel then
                lamPanel:RefreshPanel()
            end
            ECL.Chat("All settings reset to defaults")
        end,
        width = "full",
    })

    ECL.AppendSupportFooter(optionsTable)

    lamPanel = LAM:RegisterAddonPanel(PANEL_NAME, panelData)
    LAM:RegisterOptionControls(PANEL_NAME, optionsTable)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
        if panel and panel.data and panel.data.name == panelData.name then
            substituteDropdown = _G["ECL_SubstituteDropdown"]
            refreshSubstituteDropdown()
        end
    end)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel and panel.data and panel.data.name == panelData.name then
            ECL.RefreshQuickslotKeyLabel()
            substituteDropdown = substituteDropdown or _G["ECL_SubstituteDropdown"]
            refreshSubstituteDropdown()
            if panel.RefreshPanel then
                panel:RefreshPanel()
            end
        end
    end)
end
