-- Settings menu.
function MMOMB.LoadSettings()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = MMOMB.menuName,
        displayName = MMOMB.menuName,
        author = MMOMB.author,
        version = MMOMB.version,
        slashCommand = "/mmomb",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LAM:RegisterAddonPanel(MMOMB.menuName, panelData)

    local optionsTable = {
        [1] = {
            type = "header",
            name = "General Settings",
        },
        [2] = {
            type = "checkbox",
            name = "Account Wide",
            tooltip = "Use the same settings throughout the entire account - instead of per character.",
            getFunc = function() return MMOMB.savedVars.accountWide end,
            setFunc = function(newValue)
                MMOMB.characterSavedVars.accountWide = newValue
                MMOMB.accountSavedVars.accountWide = newValue
            end,
            width = "full", --or "half",
            requiresReload = true,
        },
        [3] = {
            type = "header",
            name = "Actionbar Settings",
        },
        [4] = {
            type = "checkbox",
            name = "Unlock",
            tooltip = "Allows dragging the buttons to new positions on the screen.",
            default = false,
            getFunc = function() return MMOMB.savedVars.unlock end,
            setFunc = function(newValue)

                MMOMB.ButtonUnLockAll(newValue)
            end,
        },
        [5] = {
            type = "checkbox",
            name = "Show Keybind Labels",
            tooltip = "Shows the action button keybind labels like Q, R, 1, 2 etc.",
            default = true,
            getFunc = function() return MMOMB.savedVars.showButtonText end,
            setFunc = function(newValue)

                MMOMB.ShowButtonTextAll(newValue)
            end,
        },
        [6] = {
            type = "checkbox",
            name = "Show Actionbar Background",
            tooltip = "Shows the black background of the actionbar.",
            default = true,
            getFunc = function() return MMOMB.savedVars.showActionBarBackground end,
            setFunc = function(newValue)

                MMOMB.ShowActionBarBackground(newValue)
            end,
        },
        [7] = {
            type = "divider",
            width = "full",
        },
        [8] = {
            type = "dropdown",
            name = "Preset",
            tooltip = "Choose a pre-configured button layout.",
            default = "Custom",
            choices = { "Custom", "Preset 1" },
            warning = "This will overwrite the current button positions.",
            getFunc = function() return MMOMB.savedVars.preset end,
            setFunc = function(newValue)
                MMOMB.savedVars.preset = newValue

                if (newValue == "Preset 1") then
                    MMOMB.ButtonUnLockAll(false)
                    MMOMB.preset1(MMOMB.savedVars.presetXoffset, MMOMB.savedVars.presetYoffset)
                end
            end,
            width = "half", --or "half" (optional)
        },
        [9] = {
            type = "checkbox",
            name = "Toggle Visibility",
            tooltip = "Toggle the actionbar visibility to preview from here.",
            default = false,
            getFunc = function() return not (ZO_ActionBar1:IsHidden()) end,
            setFunc = function(newValue)

                ZO_ActionBar1:SetHidden(not newValue)
            end,
            width = "half", --or "half" (optional)
        },
        [10] = {
            type = "slider",
            name = "X-Offset",
            tooltip = "Control the X offset for the selected preset.",
            default = 0, --(optional)
            disabled = function() return MMOMB.savedVars.preset == "Custom" end,
            min = -MMOMB.GetGuiRootWidth(),
            max = MMOMB.GetGuiRootWidth(),
            inputLocation = "right",
            autoSelect = true,
            getFunc = function() return MMOMB.savedVars.presetXoffset end,
            setFunc = function(newValue)
                MMOMB.preset1(newValue, MMOMB.savedVars.presetYoffset)
            end,
            width = "half", --or "half" (optional)
        },
        [11] = {
            type = "slider",
            name = "Y-Offset",
            tooltip = "Control the Y offset for the selected preset.",
            disabled = function() return MMOMB.savedVars.preset == "Custom" end,
            default = math.floor(MMOMB.GetGuiRootHeight() * 0.88), --(optional)
            min = -MMOMB.GetGuiRootHeight(),
            max = MMOMB.GetGuiRootHeight(),
            inputLocation = "right",
            autoSelect = true,
            getFunc = function() return MMOMB.savedVars.presetYoffset end,
            setFunc = function(newValue)
                MMOMB.preset1(MMOMB.savedVars.presetXoffset, newValue)
            end,
            width = "half", --or "half" (optional)
        },
    }

    LAM:RegisterOptionControls(MMOMB.menuName, optionsTable)
end