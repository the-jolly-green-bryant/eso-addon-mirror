-- ESO Adventurer Suite
-- v0.29.557 - safe recursive localization for LibAddonMenu settings.
-- The original i18n hook only localized the top-level organizedOptions table,
-- while nearly every Suite setting lives inside submenu.controls. It also wrote
-- a non-array marker key onto the options array, which could confuse LAM's entry
-- accounting. This layer keeps the existing hook but replaces the two methods it
-- calls with recursive, array-safe implementations.

local EPC = ESOProgressionCoach
if not EPC or not EPC.I18N then return end
local I = EPC.I18N

local function localizeOptionRecursive(option)
    if type(option) ~= "table" then return option end

    for _, field in ipairs({ "name", "title", "text", "tooltip", "warning", "buttonText" }) do
        local value = option[field]
        if type(value) == "string" then
            option[field] = I:Localize(value)
        elseif type(value) == "function" then
            local marker = "_easI18NRecursive_" .. field
            if option[marker] ~= true then
                local base = value
                option[field] = function(...)
                    local result = base(...)
                    if type(result) == "string" then return I:Localize(result) end
                    return result
                end
                option[marker] = true
            end
        end
    end

    if type(option.choices) == "table" then
        for index = 1, #option.choices do
            if type(option.choices[index]) == "string" then
                option.choices[index] = I:Localize(option.choices[index])
            end
        end
    end

    if type(option.controls) == "table" then
        for index = 1, #option.controls do
            localizeOptionRecursive(option.controls[index])
        end
    end

    return option
end

function I:LocalizeOption(option)
    return localizeOptionRecursive(option)
end

function I:LocalizeOptions(options)
    if type(options) ~= "table" then return options end
    for index = 1, #options do
        localizeOptionRecursive(options[index])
    end
    return options
end

-- Inject exactly one localization submenu without adding bookkeeping keys to the
-- numeric LAM options array. A language change reloads the UI once so every Suite
-- module reconstructs its labels/tooltips using the newly selected locale.
function I:InjectSettings(options)
    if type(options) ~= "table" then return options end

    -- Avoid duplicate injection if Settings is initialized more than once.
    for index = 1, #options do
        local entry = options[index]
        if type(entry) == "table" and entry._easLanguageMenu029557 == true then
            return options
        end
    end

    local languageChoices = {
        self:T("AUTO_ESO_LANGUAGE"),
        "English", "Deutsch", "Français", "Русский", "Español", "简体中文", "日本語",
    }
    local languageValues = { "AUTO", "en", "de", "fr", "ru", "es", "zh", "ja" }

    local languageMenu = {
        type = "submenu",
        name = self:T("LANGUAGE"),
        tooltip = self:T("INTERFACE_LANGUAGE"),
        _easLanguageMenu029557 = true,
        controls = {
            {
                type = "dropdown",
                name = self:T("INTERFACE_LANGUAGE"),
                tooltip = self:T("RELOAD_LANGUAGE"),
                choices = languageChoices,
                choicesValues = languageValues,
                getFunc = function()
                    return EPC.saved and (EPC.saved.i18nLanguage029552 or "AUTO") or "AUTO"
                end,
                setFunc = function(value)
                    I:SetLanguage(value)
                    -- LAM controls are constructed from registration data. A clean
                    -- reload guarantees the entire 500+ control panel and every
                    -- other Suite surface rebuild in the selected language instead
                    -- of leaving old labels cached in existing controls.
                    if type(ReloadUI) == "function" then
                        ReloadUI()
                    elseif type(EPC.Print) == "function" then
                        EPC:Print(I:T("RELOAD_LANGUAGE"))
                    end
                end,
                default = "AUTO",
                width = "full",
            },
        },
    }

    -- Keep the explanatory Settings description first, then localization.
    local insertAt = (#options > 0 and type(options[1]) == "table" and options[1].type == "description") and 2 or 1
    table.insert(options, insertAt, languageMenu)
    return options
end

I.settingsRegistrationFix029557 = true
