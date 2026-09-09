local TT = TamrielicTongues

TT.SavedVariables = {}

function TT.SavedVariables:Initialize()
    TT.saved = ZO_SavedVars:NewAccountWide(
        TT.SAVED_VARIABLES_NAME,
        TT.SAVED_VARIABLES_VERSION,
        nil,
        TT.Defaults
    )
    TT.characterPreferences = ZO_SavedVars:NewCharacterIdSettings(
        TT.SAVED_VARIABLES_NAME,
        TT.SAVED_VARIABLES_VERSION,
        "Preferences",
        {},
        GetWorldName()
    )
    -- Empty defaults let each character inherit the legacy selection exactly once.
    -- Keep the account value intact for characters that have not migrated yet.
    if TT.characterPreferences and TT.characterPreferences.activeLanguage == nil then
        TT.characterPreferences.activeLanguage = (TT.saved and TT.saved.activeLanguage)
            or TT.Constants.DEFAULT_LANGUAGE_ID or TT.Constants.COMMON_LANGUAGE_ID
    end
    TT.characterSaved = ZO_SavedVars:NewCharacterIdSettings(
        TT.SAVED_VARIABLES_NAME,
        TT.SAVED_VARIABLES_VERSION,
        "Proficiency",
        {},
        GetWorldName()
    )
end

function TT.SavedVariables:InitializeKnowledge()
    local ready, reason = TT.Proficiency:Initialize(TT.characterSaved, GetUnitRaceId("player"))
    local eventName = TT.ADDON_NAME .. "_KnowledgeReady"
    if ready then
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_PLAYER_ACTIVATED)
    elseif reason == "player-not-ready" then
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_PLAYER_ACTIVATED, function()
            TT.SavedVariables:InitializeKnowledge()
        end)
    else
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_PLAYER_ACTIVATED)
        TT:Print(TT.Locale:Get("KNOWLEDGE_UNAVAILABLE"))
    end
end
