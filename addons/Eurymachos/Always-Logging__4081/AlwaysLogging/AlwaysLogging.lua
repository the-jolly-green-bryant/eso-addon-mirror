local function enable_logging()
    if not IsEncounterLogEnabled() then
        SetEncounterLogEnabled(true)
        CHAT_ROUTER:AddSystemMessage('Encounter logging enabled by addon.')
    end
end

EVENT_MANAGER:RegisterForEvent('Always Logging', EVENT_PLAYER_ACTIVATED, enable_logging)
EVENT_MANAGER:RegisterForEvent('Always Logging', EVENT_PLAYER_COMBAT_STATE, enable_logging)
