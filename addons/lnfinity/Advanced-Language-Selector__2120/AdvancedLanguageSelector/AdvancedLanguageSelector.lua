AdvancedLanguageSelector = {}
AdvancedLanguageSelector.name = "AdvancedLanguageSelector"

function AdvancedLanguageSelector:Initialize()
    EVENT_MANAGER:RegisterForEvent(AdvancedLanguageSelector.name, EVENT_PLAYER_ACTIVATED, AdvancedLanguageSelector.OnPlayerActivated)
end

function AdvancedLanguageSelector.OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(AdvancedLanguageSelector.name, EVENT_PLAYER_ACTIVATED)
    SetCVar("language.2","en")
end

function AdvancedLanguageSelector.OnAddOnLoaded(event, addonName)
    if addonName == AdvancedLanguageSelector.name then
        AdvancedLanguageSelector:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(AdvancedLanguageSelector.name, EVENT_ADD_ON_LOADED, AdvancedLanguageSelector.OnAddOnLoaded)