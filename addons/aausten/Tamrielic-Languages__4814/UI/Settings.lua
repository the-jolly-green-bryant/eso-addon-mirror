local TT = TamrielicTongues

TT.Settings = {}

function TT.Settings:SetActiveLanguage(languageId)
    local resolved = TT.Registry:ResolveId(languageId)
    if not resolved or not TT.characterPreferences then
        return false
    end
    TT.characterPreferences.activeLanguage = resolved
    return true
end

function TT.Settings:GetActiveLanguage()
    return TT.characterPreferences and TT.characterPreferences.activeLanguage or TT.Constants.COMMON_LANGUAGE_ID
end

function TT.Settings:SetTranslationsEnabled(enabled)
    TT.saved.showTranslations = enabled and true or false
end

function TT.Settings:Refresh(force)
    if not self.panelOpen then return end

    -- Compare only visible values/readiness, not XP or mutable saved-state tables.
    local values = { self:GetActiveLanguage() }
    for _, id in ipairs(self.languageIds) do
        values[#values + 1] = tostring(TT.Proficiency:IsSupported(id))
        values[#values + 1] = tostring(TT.Proficiency:GetOverall(id))
        values[#values + 1] = tostring(TT.Proficiency:GetProgressEnabled(id))
    end
    local snapshot = table.concat(values, ":")
    if force or snapshot ~= self.snapshot then
        self.snapshot = snapshot
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", self.panel)
    end
end

function TT.Settings:Initialize()
    if self.panel then return true end
    local LAM = LibAddonMenu2
    if not LAM then return false end

    local panelName = TT.ADDON_NAME .. "Settings"
    local choices = { TT.Locale:Get("COMMON_NAME") }
    local choicesValues = { TT.Constants.COMMON_LANGUAGE_ID }
    self.languageIds = {}
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        choices[#choices + 1] = TT.Locale:LanguageName(profile)
        choicesValues[#choicesValues + 1] = profile.id
        self.languageIds[#self.languageIds + 1] = profile.id
    end

    local options = {
        { type = "description", text = TT.Locale:Get("SETTINGS_SCOPE") },
        {
            type = "dropdown",
            name = TT.Locale:Get("SETTINGS_SPEAKING"),
            tooltip = TT.Locale:Get("SETTINGS_SPEAKING_TOOLTIP"),
            choices = choices,
            choicesValues = choicesValues,
            getFunc = function() return self:GetActiveLanguage() end,
            setFunc = function(id) self:SetActiveLanguage(id) end,
        },
        { type = "description", text = TT.Locale:Get("SETTINGS_KNOWLEDGE_DESCRIPTION") },
    }
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        local id = profile.id
        local function disabled() return not TT.Proficiency:IsSupported(id) end
        local function warning()
            if disabled() then return TT.Locale:Get("SETTINGS_KNOWLEDGE_UNAVAILABLE") end
        end
        options[#options + 1] = { type = "header", name = TT.Locale:LanguageName(profile) }
        options[#options + 1] = {
            type = "slider",
            name = TT.Locale:Get("SETTINGS_OVERALL"),
            tooltip = TT.Locale:Get("SETTINGS_OVERALL_TOOLTIP"),
            min = 0, max = 100, step = 1, decimals = 0, clampInput = true,
            disabled = disabled,
            warning = warning,
            getFunc = function() return TT.Proficiency:GetOverall(id) or 0 end,
            setFunc = function(value)
                if not disabled() then TT.Proficiency:SetOverall(id, value) end
            end,
        }
        options[#options + 1] = {
            type = "checkbox",
            name = TT.Locale:Get("SETTINGS_PROGRESS"),
            tooltip = TT.Locale:Get("SETTINGS_PROGRESS_TOOLTIP"),
            disabled = disabled,
            warning = warning,
            getFunc = function() return TT.Proficiency:GetProgressEnabled(id) == true end,
            setFunc = function(value)
                if not disabled() then TT.Proficiency:SetProgressEnabled(id, value) end
            end,
        }
    end

    self.panel = LAM:RegisterAddonPanel(panelName, {
        type = "panel", name = TT.DISPLAY_NAME, displayName = TT.DISPLAY_NAME,
        version = TT.VERSION, registerForRefresh = true,
    })
    LAM:RegisterOptionControls(panelName, options)

    -- LAM opens only after lazy control creation, and closes on panel/scene exit.
    local updateName = panelName .. "Refresh"
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        if panel ~= self.panel or self.panelOpen then return end
        self.panelOpen = true
        self:Refresh(true)
        EVENT_MANAGER:RegisterForUpdate(updateName, 500, function() self:Refresh() end)
    end)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel ~= self.panel then return end
        self.panelOpen = false
        self.snapshot = nil
        EVENT_MANAGER:UnregisterForUpdate(updateName)
    end)
    return true
end

function TT.Settings:Open()
    if not self:Initialize() then
        TT:Print(TT.Locale:Get("SETTINGS_MISSING_LIBRARY"))
        return false
    end
    LibAddonMenu2:OpenToPanel(self.panel)
    return true
end
