FCOCTB = FCOCTB or {}
local FCOCTB = FCOCTB

--Localized texts etc.
function FCOCTB.Localization()
    --d("[FCOCTB] Localization - Start, keybindings: " .. tostring(FCOCTB.preventerVars.KeyBindingTexts) ..", useClientLang: " .. tostring(FCOCTB.settingsVars.settings.alwaysUseClientLanguage))
    --Was localization already done during keybindings? Then abort here
    if FCOCTB.preventerVars.KeyBindingTexts == true and FCOCTB.preventerVars.gLocalizationDone == true then return end
    --Fallback to english variable
    local fallbackToEnglish = false
    local settingsVars = FCOCTB.settingsVars
    --Always use the client's language?
    if not settingsVars.settings.alwaysUseClientLanguage then
        --Was a language chosen already?
        if not settingsVars.settings.languageChosen then
            --d("[FCOCTB] Localization: Fallback to english. Keybindings: " .. tostring(FCOCTB.preventerVars.KeyBindingTexts) .. ", language chosen: " .. tostring(settingsVars.settings.languageChosen) .. ", defaultLanguage: " .. tostring(settingsVars.defaultSettings.language))
            if settingsVars.defaultSettings.language == nil then
                --d("[FCOCTB] Localization: defaultSettings.language is NIL -> Fallback to english now")
                fallbackToEnglish = true
            else
                --Is the languages array filled and the language is not valid (not in the language array with the value "true")?
                local languages = FCOCTB.langVars.languages
                if languages ~= nil and #languages > 0 and not languages[settingsVars.defaultSettings.language] then
                    fallbackToEnglish = true
                    --d("[FCOCTB] Localization: defaultSettings.language is ~= " .. i .. ", and this language # is not valid -> Fallback to english now")
                end
            end
        end
    end
    --d("[FCOCTB] localization, fallBackToEnglish: " .. tostring(fallbackToEnglish))
    --Fallback to english language now
    if (fallbackToEnglish) then settingsVars.defaultSettings.language = 1 end
    --Is the standard language english set?
    if settingsVars.settings.alwaysUseClientLanguage or (FCOCTB.preventerVars.KeyBindingTexts or (settingsVars.defaultSettings.language == 1 and not settingsVars.settings.languageChosen)) then
        --d("[FCOCTB] localization: Language chosen is false or always use client language is true!")
        local lang = GetCVar("language.2")
        --Check for supported languages
        if(lang == "de") then
            settingsVars.defaultSettings.language = 2
        elseif (lang == "en") then
            settingsVars.defaultSettings.language = 1
        elseif (lang == "fr") then
            settingsVars.defaultSettings.language = 3
        elseif (lang == "es") then
            settingsVars.defaultSettings.language = 4
        elseif (lang == "it") then
            settingsVars.defaultSettings.language = 5
        elseif (lang == "jp") then
            settingsVars.defaultSettings.language = 6
        elseif (lang == "ru") then
            settingsVars.defaultSettings.language = 7
        else
            settingsVars.defaultSettings.language = 1
        end
    end
    --d("[FCOCTB] localization: default settings, language: " .. tostring(settingsVars.defaultSettings.language))
    --Get the localized texts from the localization file
    FCOCTB.localizationVars.fco_ctb_loc = FCOCTB.localizationVars.localizationAll[settingsVars.defaultSettings.language]
    --Set the flag that the localization was donw
    FCOCTB.preventerVars.gLocalizationDone = true
end

--Global function to get text for the keybindings etc.
function FCOCTB.GetCTBLocText(textName, isKeybindingText)
    --d("[FCOCTB.GetCTBLocText] textName: " .. tostring(textName))
    isKeybindingText = isKeybindingText or false

    FCOCTB.preventerVars.KeyBindingTexts = isKeybindingText

    --Do the localization now
    FCOCTB.Localization()

    if textName == nil or FCOCTB.localizationVars.fco_ctb_loc == nil or FCOCTB.localizationVars.fco_ctb_loc[textName] == nil then return "" end
    return FCOCTB.localizationVars.fco_ctb_loc[textName]
end
