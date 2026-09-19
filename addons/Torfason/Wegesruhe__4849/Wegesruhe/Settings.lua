local WR = Wegesruhe

local function SetCustomAndRefresh(setter)
    return function(value)
        setter(value)
        WR:MarkCustom()
        WR:RefreshAll()
    end
end

local function SetQuestFilterAndRefresh(setter)
    return function(value)
        setter(value)
        WR:MarkCustom()
        -- QuestType filtering is per individual pin. Force one quest-pin rebuild
        -- so map and compass immediately ask for the new texture state.
        WR:RefreshAll(true)
    end
end

local function SetAllQuestFilters(WR, definitions, targetTable, value)
    for _, definition in ipairs(definitions or {}) do
        targetTable[definition.key] = value
    end
    WR:MarkCustom()
    WR:RefreshAll(true)
end

local function BuildQuestTypeControls(WR, L)
    local controls = {
        { type = "description", text = L.QUEST_TYPES_DESCRIPTION },
        {
            type = "button",
            name = L.ALL_ENABLE,
            tooltip = L.ALL_ENABLE_QUEST_TYPES_TOOLTIP,
            func = function()
                SetAllQuestFilters(WR, WR.questTypeDefinitions, WR.settings.questTypes, true)
            end,
            width = "half",
        },
        {
            type = "button",
            name = L.ALL_DISABLE,
            tooltip = L.ALL_DISABLE_QUEST_TYPES_TOOLTIP,
            func = function()
                SetAllQuestFilters(WR, WR.questTypeDefinitions, WR.settings.questTypes, false)
            end,
            width = "half",
        },
    }
    for _, definition in ipairs(WR.questTypeDefinitions or {}) do
        local key = definition.key
        controls[#controls + 1] = {
            type = "checkbox",
            name = L[definition.label] or definition.constant,
            tooltip = L.QUEST_FILTER_TOOLTIP,
            getFunc = function() return WR.settings.questTypes[key] ~= false end,
            setFunc = SetQuestFilterAndRefresh(function(value) WR.settings.questTypes[key] = value end),
            width = "full",
        }
    end
    return controls
end

local function BuildRepeatTypeControls(WR, L)
    local controls = {
        { type = "description", text = L.REPEAT_TYPES_DESCRIPTION },
        {
            type = "button",
            name = L.ALL_ENABLE,
            tooltip = L.ALL_ENABLE_REPEAT_TYPES_TOOLTIP,
            func = function()
                SetAllQuestFilters(WR, WR.repeatTypeDefinitions, WR.settings.repeatTypes, true)
            end,
            width = "half",
        },
        {
            type = "button",
            name = L.ALL_DISABLE,
            tooltip = L.ALL_DISABLE_REPEAT_TYPES_TOOLTIP,
            func = function()
                SetAllQuestFilters(WR, WR.repeatTypeDefinitions, WR.settings.repeatTypes, false)
            end,
            width = "half",
        },
    }
    for _, definition in ipairs(WR.repeatTypeDefinitions or {}) do
        local key = definition.key
        controls[#controls + 1] = {
            type = "checkbox",
            name = L[definition.label] or definition.constant,
            tooltip = L.QUEST_FILTER_TOOLTIP,
            getFunc = function() return WR.settings.repeatTypes[key] ~= false end,
            setFunc = SetQuestFilterAndRefresh(function(value) WR.settings.repeatTypes[key] = value end),
            width = "full",
        }
    end
    return controls
end

function WR:InitializeSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local L = self.L
    local panelData = {
        type = "panel",
        name = L.ADDON_NAME,
        displayName = "|c7FC7FF" .. L.ADDON_NAME .. "|r",
        author = "Atlas",
        version = self.version,
        slashCommand = "/wr",
        registerForRefresh = true,
        registerForDefaults = false,
    }
    LAM:RegisterAddonPanel("WegesruheOptions", panelData)

    local presetChoices = {
        L.PRESET_NORMAL,
        L.PRESET_GENTLE,
        L.PRESET_EXPLORER,
        L.PRESET_HARDCORE,
        L.PRESET_CUSTOM,
    }
    local presetValues = { "normal", "gentle", "explorer", "hardcore", "custom" }
    local pvpChoices = { L.PRESET_OFF, L.PRESET_NORMAL, L.PRESET_GENTLE, L.PRESET_EXPLORER, L.PRESET_HARDCORE }
    local pvpValues = { "off", "normal", "gentle", "explorer", "hardcore" }

    local options = {
        {
            type = "description",
            text = L.PANEL_DESCRIPTION,
        },
        { type = "header", name = L.SETTINGS_SCOPE_HEADER },
        {
            type = "dropdown",
            name = L.SETTINGS_SCOPE,
            tooltip = L.SETTINGS_SCOPE_TOOLTIP,
            choices = { L.SETTINGS_SCOPE_ACCOUNT, L.SETTINGS_SCOPE_CHARACTER },
            choicesValues = { "account", "character" },
            getFunc = function() return self:GetSettingsScope() end,
            setFunc = function(value) self:SetSettingsScope(value) end,
            width = "full",
        },
        {
            type = "description",
            text = L.SETTINGS_SCOPE_INFO,
        },
        {
            type = "checkbox",
            name = L.ENABLED,
            tooltip = L.ENABLED_TOOLTIP,
            getFunc = function() return self.settings.enabled end,
            setFunc = function(value)
                self:SetEnabled(value, false)
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = L.PRESET,
            tooltip = L.PRESET_TOOLTIP,
            choices = presetChoices,
            choicesValues = presetValues,
            getFunc = function() return self.settings.preset end,
            setFunc = function(value)
                if value ~= "custom" then
                    self:ApplyPreset(value)
                else
                    self.settings.preset = "custom"
                end
            end,
            width = "full",
        },
        { type = "header", name = L.MAP_HEADER },
        {
            type = "checkbox",
            name = L.MAP_QUESTS,
            tooltip = L.MAP_QUESTS_TOOLTIP,
            getFunc = function() return self.settings.mapQuestPins end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.mapQuestPins = value end),
            width = "full",
        },
        { type = "header", name = L.QUEST_FILTERS_HEADER },
        {
            type = "description",
            text = L.QUEST_FILTERS_DESCRIPTION,
        },
        {
            type = "submenu",
            name = L.QUEST_TYPES_HEADER,
            controls = BuildQuestTypeControls(self, L),
        },
        {
            type = "submenu",
            name = L.REPEAT_TYPES_HEADER,
            controls = BuildRepeatTypeControls(self, L),
        },
        { type = "header", name = L.COMPASS_HEADER },
        {
            type = "checkbox",
            name = L.COMPASS_QUEST_OFFERS,
            tooltip = L.COMPASS_GENERIC_TOOLTIP,
            getFunc = function() return self.settings.compass.questOffers end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.compass.questOffers = value end),
        },
        {
            type = "checkbox",
            name = L.COMPASS_ASSISTED,
            tooltip = L.COMPASS_GENERIC_TOOLTIP,
            getFunc = function() return self.settings.compass.assistedObjectives end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.compass.assistedObjectives = value end),
        },
        {
            type = "checkbox",
            name = L.COMPASS_SECONDARY,
            tooltip = L.COMPASS_GENERIC_TOOLTIP,
            getFunc = function() return self.settings.compass.secondaryObjectives end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.compass.secondaryObjectives = value end),
        },
        {
            type = "checkbox",
            name = L.COMPASS_POI_SEEN,
            tooltip = L.COMPASS_GENERIC_TOOLTIP,
            getFunc = function() return self.settings.compass.poiSeen end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.compass.poiSeen = value end),
        },
        {
            type = "checkbox",
            name = L.COMPASS_POI_COMPLETE,
            tooltip = L.COMPASS_GENERIC_TOOLTIP,
            getFunc = function() return self.settings.compass.poiComplete end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.compass.poiComplete = value end),
        },
        {
            type = "checkbox",
            name = L.COMPASS_AREAS,
            tooltip = L.COMPASS_AREAS_TOOLTIP,
            getFunc = function() return self.settings.compass.questAreas end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.compass.questAreas = value end),
            width = "full",
        },
        { type = "header", name = L.WORLD_HEADER },
        {
            type = "description",
            text = L.WORLD_SAFETY_INFO,
        },
        {
            type = "checkbox",
            name = L.WORLD_QUEST_OFFERS,
            tooltip = L.WORLD_GENERIC_TOOLTIP,
            getFunc = function() return self.settings.world.questOffers end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.world.questOffers = value end),
        },
        {
            type = "checkbox",
            name = L.WORLD_ASSISTED,
            tooltip = L.WORLD_GENERIC_TOOLTIP,
            getFunc = function() return self.settings.world.assistedObjectives end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.world.assistedObjectives = value end),
        },
        {
            type = "checkbox",
            name = L.WORLD_SECONDARY,
            tooltip = L.WORLD_GENERIC_TOOLTIP,
            getFunc = function() return self.settings.world.secondaryObjectives end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.world.secondaryObjectives = value end),
        },
        {
            type = "checkbox",
            name = L.WORLD_BREADCRUMBS,
            tooltip = L.WORLD_BREADCRUMBS_TOOLTIP,
            getFunc = function() return self.settings.world.breadcrumbs end,
            setFunc = SetCustomAndRefresh(function(value) self.settings.world.breadcrumbs = value end),
            width = "full",
        },
        { type = "header", name = L.PVP_HEADER },
        {
            type = "checkbox",
            name = L.PVP_OVERRIDE,
            tooltip = L.PVP_OVERRIDE_TOOLTIP,
            getFunc = function() return self.settings.pvpOverride end,
            setFunc = function(value)
                self.settings.pvpOverride = value
                self:RefreshAll()
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = L.PVP_PRESET,
            tooltip = L.PVP_PRESET_TOOLTIP,
            choices = pvpChoices,
            choicesValues = pvpValues,
            getFunc = function() return self.settings.pvpPreset end,
            setFunc = function(value)
                self.settings.pvpPreset = value
                self:RefreshAll()
            end,
            disabled = function() return not self.settings.pvpOverride end,
            width = "full",
        },
        { type = "header", name = L.KEYBIND_HEADER },
        {
            type = "description",
            text = L.KEYBIND_INFO,
        },
        { type = "header", name = L.RESET_HEADER },
        {
            type = "button",
            name = L.RESET_BUTTON,
            tooltip = L.RESET_BUTTON_TOOLTIP,
            func = function() self:ResetDefaults() end,
            width = "full",
            warning = "",
        },
    }

    LAM:RegisterOptionControls("WegesruheOptions", options)
end
