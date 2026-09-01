local FSC = FlamechasersSpellcheck

FSC.name = "FlamechasersSpellcheck"
FSC.displayName = "Flamechasers Spellcheck & Autocomplete"
FSC.shortDisplayName = "Spellcheck"
FSC.version = "0.7.6"

ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_SPELLCHECK_ACCEPT_SUGGESTION", "Accept suggested word")
ZO_CreateStringId("SI_BINDING_NAME_FLAMECHASERS_SPELLCHECK_NAVIGATE_SUGGESTIONS", "Navigate suggestions")

local defaults = FSC.SAVED_DEFAULTS

local function Print(message)
    d(string.format("|cD6A7FF%s|r: %s", FSC.shortDisplayName or FSC.displayName, tostring(message)))
end

local function HookChatInput()
    -- v0.2.1: UI.lua owns the native/backend bridge. Keeping this function as an
    -- initialization marker avoids old pChat handler wrapping and duplicate hooks.
    FSC.chatHooked = true
end

local function LearnESOClientNames()
    if not FSC:IsDictionaryEnabled("eso") then return end
    FSC.ESO.BuildStaticRuntimeLexicon()
    FSC.ESO.LearnCurrentMap()
end

local function InitializeAfterPlayerActivated()
    HookChatInput()
    LearnESOClientNames()
    FSC:InitializeUI()
    FSC:RegisterChatCogSettingsEntry()
    FSC:ScheduleRefresh()
end

local function HandleSlash(text)
    text = text or ""
    local command, rest = text:match("^(%S+)%s*(.-)%s*$")
    command = string.lower(command or "")

    if command == "add" and rest ~= "" then
        FSC:AddUserWord(rest)
        Print("Added \"" .. rest .. "\" to your dictionary.")
    elseif command == "remove" and rest ~= "" then
        local normalized = FSC:NormalizeWord(rest)
        FSC.saved.userWords[normalized] = nil
        FSC:InvalidateAutocompleteCaches()
        FSC:InvalidateInputLayoutCaches()
        FSC:ScheduleRefresh()
        Print("Removed \"" .. rest .. "\" from your dictionary.")
    elseif command == "status" then
        local pchatState = pChat and "detected" or "not detected"
        local overlayState = FSC.overlayState or "custom editor waiting"
        Print("v" .. FSC.version .. " | pChat " .. pchatState .. " | " .. overlayState)
    else
        Print("Right-click a marked word for corrections. Commands: /fspell add <word>, /fspell remove <word>, /fspell status")
    end
end

local function OnChatMessage(_, _, fromName, text, _, fromDisplayName)
    if not text or text == "" then return end

    local ownDisplayName = GetDisplayName()
    local isOwnMessage = ownDisplayName and fromDisplayName == ownDisplayName
    if not isOwnMessage then
        local ownCharacterName = GetRawUnitName("player")
        isOwnMessage = ownCharacterName and fromName == ownCharacterName
    end

    -- Super mode may use recent player chat as a temporary recency/context cache.
    -- Nothing from other players is written to SavedVariables: ObserveAutocompleteSessionText
    -- is deliberately session-only. Normal mode does no extra work here.
    if FSC:IsSuperSuggestionsEnabled() then
        local canObserve = isOwnMessage or FSC:IsSuperConversationContextEnabled()
        if canObserve and (isOwnMessage or fromDisplayName or (fromName and fromName ~= "")) then
            FSC:ObserveAutocompleteSessionText(text, isOwnMessage == true)
        end
    end

    -- Long-term personalization remains restricted to messages ESO confirms were sent
    -- by this account, preserving the existing privacy and behavior contract.
    if isOwnMessage and FSC:IsPersonalizationEnabled() then
        FSC:LearnAutocompleteText(text)
    end
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent(FSC.name .. "Player", EVENT_PLAYER_ACTIVATED)
    InitializeAfterPlayerActivated()

    -- Re-learn current-map names on subsequent activations/zone loads.
    EVENT_MANAGER:RegisterForEvent(FSC.name .. "ZoneLearn", EVENT_PLAYER_ACTIVATED, function()
        local runtimeChanged = 0
        if FSC:IsDictionaryEnabled("eso") then
            -- Static client lexicon builders are idempotent. Re-running them here
            -- lets collectors that had to wait for game data (notably skills) retry
            -- after later player activations without adding steady-state overhead.
            local _, staticChanged = FSC.ESO.BuildStaticRuntimeLexicon()
            runtimeChanged = runtimeChanged + (tonumber(staticChanged) or 0)
            local _, mapChanged = FSC.ESO.LearnCurrentMap()
            runtimeChanged = runtimeChanged + (tonumber(mapChanged) or 0)
        end
        if runtimeChanged > 0 then
            FSC:InvalidateDictionaryCaches()
        else
            FSC:ScheduleRefresh()
        end
    end)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= FSC.name then return end
    EVENT_MANAGER:UnregisterForEvent(FSC.name, EVENT_ADD_ON_LOADED)

    -- Preferences, personal words, and the writing model are intentionally shared
    -- across megaservers because they contain no server-specific game state.
    FSC.saved = ZO_SavedVars:NewAccountWide("FlamechasersSpellcheckSavedVars", 1, nil, defaults)
    FSC.sessionIgnored = {}
    FSC.suggestionCache = {}
    FSC.suggestionCacheCount = 0

    FSC:RegisterSettings()

    SLASH_COMMANDS["/fspell"] = HandleSlash

    -- Learn only from messages that ESO confirms were actually sent by this account.
    -- This avoids touching the protected submission path and keeps personalization local.
    EVENT_MANAGER:RegisterForEvent(FSC.name .. "AutocompleteLearn", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)

    -- Waiting until PLAYER_ACTIVATED guarantees pChat and other chat addons have
    -- finished installing their handlers before Spellcheck adds its non-destructive hooks.
    EVENT_MANAGER:RegisterForEvent(FSC.name .. "Player", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(FSC.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
