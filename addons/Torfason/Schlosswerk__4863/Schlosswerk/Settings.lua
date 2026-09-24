local SW = Schlosswerk


function SW:GetModeChoices()
    return {
        self:L("MODE_FIXED"),
        self:L("MODE_RANDOM"),
    }, {
        "fixed",
        "random",
    }
end

function SW:RefreshLocalizedDropdowns()
    local modeControl = _G and _G.SchlosswerkModeDropdown
    if modeControl and modeControl.UpdateChoices then
        local names, values = self:GetModeChoices()
        modeControl:UpdateChoices(names, values)
        modeControl:UpdateValue()
    end

    local styleControl = _G and _G.SchlosswerkFixedStyleDropdown
    if styleControl and styleControl.UpdateChoices then
        local names, values = self:GetStyleChoices()
        styleControl:UpdateChoices(names, values)
        styleControl:UpdateValue()
    end
end

function SW:RefreshSettingsPanel()
    if not LibAddonMenu2 or not self.settingsPanel then
        return
    end

    self:RefreshLocalizedDropdowns()
    LibAddonMenu2:RefreshPanel(self.settingsPanel)
end

function SW:RegisterSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "Atlas",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.settingsPanel = LAM:RegisterAddonPanel("SchlosswerkSettingsPanel", panelData)

    local options = {
        {
            type = "description",
            text = function() return SW:L("PANEL_DESCRIPTION") end,
            width = "full",
        },
        {
            type = "header",
            name = function() return SW:L("HEADER_GENERAL") end,
        },
        {
            type = "dropdown",
            reference = "SchlosswerkModeDropdown",
            name = function() return SW:L("MODE") end,
            tooltip = function() return SW:L("MODE_TT") end,
            choices = ({ self:GetModeChoices() })[1],
            choicesValues = ({ self:GetModeChoices() })[2],
            getFunc = function() return SW.db.selectionMode end,
            setFunc = function(value) SW.db.selectionMode = value end,
            default = self.defaultSettings.selectionMode,
            width = "full",
        },
        {
            type = "dropdown",
            reference = "SchlosswerkFixedStyleDropdown",
            name = function() return SW:L("FIXED_STYLE") end,
            tooltip = function() return SW:L("FIXED_STYLE_TT") end,
            choices = ({ self:GetStyleChoices() })[1],
            choicesValues = ({ self:GetStyleChoices() })[2],
            getFunc = function() return SW.db.fixedStyle end,
            setFunc = function(value) SW.db.fixedStyle = value end,
            disabled = function() return SW.db.selectionMode ~= "fixed" end,
            default = self.defaultSettings.fixedStyle,
            width = "full",
        },
        {
            type = "description",
            text = function() return SW:L("ORIGINAL_NOTE") end,
            width = "full",
        },
        {
            type = "header",
            name = function() return SW:L("HEADER_APPEARANCE") end,
        },
        {
            type = "checkbox",
            name = function() return SW:L("PIN_LIGHTS") end,
            tooltip = function() return SW:L("PIN_LIGHTS_TT") end,
            getFunc = function() return SW.db.pinLights end,
            setFunc = function(value) SW.db.pinLights = value end,
            default = self.defaultSettings.pinLights,
            width = "full",
        },
        {
            type = "description",
            text = function() return SW:L("CHANGES_NEXT_ATTEMPT") end,
            width = "full",
        },
        {
            type = "header",
            name = function() return SW:L("HEADER_RANDOM") end,
        },
        {
            type = "checkbox",
            name = function() return SW:L("AVOID_REPEAT") end,
            tooltip = function() return SW:L("AVOID_REPEAT_TT") end,
            getFunc = function() return SW.db.avoidImmediateRepeat end,
            setFunc = function(value) SW.db.avoidImmediateRepeat = value end,
            disabled = function() return SW.db.selectionMode ~= "random" end,
            default = self.defaultSettings.avoidImmediateRepeat,
            width = "full",
        },
        {
            type = "description",
            text = function() return SW:L("RANDOM_POOL_TT") end,
            width = "full",
        },
    }

    for _, styleIdValue in ipairs(self.styleOrder) do
        local styleId = styleIdValue
        options[#options + 1] = {
            type = "checkbox",
            name = function() return SW:GetStyleName(styleId) end,
            getFunc = function() return SW.db.randomPool[styleId] end,
            setFunc = function(value) SW.db.randomPool[styleId] = value end,
            disabled = function() return SW.db.selectionMode ~= "random" end,
            default = self.defaultSettings.randomPool[styleId] == true,
            width = "half",
        }
    end

    LAM:RegisterOptionControls("SchlosswerkSettingsPanel", options)
end

function SW:OpenSettings()
    if self:IsLockpickSceneShowing() then
        self:Print(self:L("CHAT_BLOCKED"))
        return
    end

    if LibAddonMenu2 and self.settingsPanel then
        LibAddonMenu2:OpenToPanel(self.settingsPanel)
    end
end
