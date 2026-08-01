if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Localization and languages
------------------------------------------------------------------------------------------------------------
function FCOSS.Localization()
    --d("[FCOStarveStop] Localization - Start, keybindings: " .. tostring(FCOSS.preventerVars.KeyBindingTexts) ..", useClientLang: " .. tostring(FCOSS.settingsVars.settings.alwaysUseClientLanguage))
    --Was localization already done during keybindings? Then abort here
    if FCOSS.preventerVars.KeyBindingTexts == true and FCOSS.preventerVars.gLocalizationDone == true then return end
    --Fallback to english variable
    local fallbackToEnglish = false
    --Always use the client's language?
    if not FCOSS.settingsVars.settings.alwaysUseClientLanguage then
        --Was a language chosen already?
        if not FCOSS.settingsVars.settings.languageChosen then
            --d("[FCOStarveStop] Localization: Fallback to english. Keybindings: " .. tostring(FCOSS.preventerVars.KeyBindingTexts) .. ", language chosen: " .. tostring(FCOSS.settingsVars.settings.languageChosen) .. ", defaultLanguage: " .. tostring(FCOSS.settingsVars.defaultSettings.language))
            if FCOSS.settingsVars.defaultSettings.language == nil then
                --d("[FCOStarveStop] Localization: defaultSettings.language is NIL -> Fallback to english now")
                fallbackToEnglish = true
            else
                --Is the languages array filled and the language is not valid (not in the language array with the value "true")?
                if FCOSS.langVars.languages ~= nil and #FCOSS.langVars.languages > 0 and not FCOSS.langVars.languages[FCOSS.settingsVars.defaultSettings.language] then
                    fallbackToEnglish = true
                    --d("[FCOStarveStop] Localization: defaultSettings.language is ~= " .. i .. ", and this language # is not valid -> Fallback to english now")
                end
            end
        end
    end
    --d("[FCOStarveStop] localization, fallBackToEnglish: " .. tostring(fallbackToEnglish))
    --Fallback to english language now
    if (fallbackToEnglish) then FCOSS.settingsVars.defaultSettings.language = 1 end
    --Is the standard language english set?
    if FCOSS.settingsVars.settings.alwaysUseClientLanguage or (FCOSS.preventerVars.KeyBindingTexts or (FCOSS.settingsVars.defaultSettings.language == 1 and not FCOSS.settingsVars.settings.languageChosen)) then
        --d("[FCOStarveStop] localization: Language chosen is false or always use client language is true!")
        local lang = GetCVar("language.2")
        --Check for supported languages
        if(lang == "de") then
            FCOSS.settingsVars.defaultSettings.language = 2
        elseif (lang == "en") then
            FCOSS.settingsVars.defaultSettings.language = 1
        elseif (lang == "fr") then
            FCOSS.settingsVars.defaultSettings.language = 3
        elseif (lang == "es") then
            FCOSS.settingsVars.defaultSettings.language = 4
        elseif (lang == "it") then
            FCOSS.settingsVars.defaultSettings.language = 5
        elseif (lang == "jp") then
            FCOSS.settingsVars.defaultSettings.language = 6
        elseif (lang == "ru") then
            FCOSS.settingsVars.defaultSettings.language = 7
        else
            FCOSS.settingsVars.defaultSettings.language = 1
        end
    end
    --d("[FCOStarveStop] localization: default settings, language: " .. tostring(FCOSS.settingsVars.defaultSettings.language))
    --Get the localized texts from the localization file
    FCOSS.localizationVars.fco_ss_loc = FCOSS.localizationVars.localizationAll[FCOSS.settingsVars.defaultSettings.language]

    FCOSS.preventerVars.gLocalizationDone = true
end

--Global function to get text for the keybindings etc.
function FCOSS.GetLocText(textName, isKeybindingText)
    isKeybindingText = isKeybindingText or false

    FCOSS.preventerVars.KeyBindingTexts = isKeybindingText

    --Do the localization now
    FCOSS.Localization()

    if textName == nil or FCOSS.localizationVars.fco_ss_loc == nil or FCOSS.localizationVars.fco_ss_loc[textName] == nil then return "" end
    return FCOSS.localizationVars.fco_ss_loc[textName]
end
