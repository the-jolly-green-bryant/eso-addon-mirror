-- ============================================================================
-- AetherChat : Main Addon Initialization & Keybindings
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

AetherChat.name = 'AetherChat'
AetherChat.version = '1.3.0'

-- Keybinding Strings (Must be created before Bindings.xml is loaded by C++ engine)
local L = AetherChat.L or function(k) return k end
ZO_CreateStringId("SI_BINDINGS_CATEGORY_AETHERCHAT", "AetherChat")
ZO_CreateStringId("SI_BINDING_NAME_AETHERCHAT_TOGGLE", L('BINDING_NAME'))
ZO_CreateStringId("SI_BINDING_NAME_AETHERCHAT_TOGGLE_MODE", L('BINDING_TOGGLE_MODE'))
ZO_CreateStringId("SI_BINDING_NAME_AETHERCHAT_NEXT_TAB", L('BINDING_NEXT_TAB'))
ZO_CreateStringId("SI_BINDING_NAME_AETHERCHAT_PREV_TAB", L('BINDING_PREV_TAB'))
ZO_CreateStringId("SI_BINDING_NAME_AETHERCHAT_NEXT_GUILD", L('BINDING_NEXT_GUILD'))
ZO_CreateStringId("SI_BINDING_NAME_AETHERCHAT_FOCUS_CHAT", L('BINDING_FOCUS_CHAT'))

-- Register Slash Commands
SLASH_COMMANDS['/aetherc'] = function()
    if AetherChat.Messenger and AetherChat.Messenger.Toggle then
        AetherChat.Messenger.Toggle()
    end
end

SLASH_COMMANDS['/aether'] = function()
    if AetherChat.Messenger and AetherChat.Messenger.Toggle then
        AetherChat.Messenger.Toggle()
    end
end

SLASH_COMMANDS['/aethermode'] = function()
    if AetherChat.Messenger and AetherChat.Messenger.ToggleInterfaceMode then
        AetherChat.Messenger.ToggleInterfaceMode()
    end
end
SLASH_COMMANDS['/acmode'] = SLASH_COMMANDS['/aethermode']

SLASH_COMMANDS['/chathead'] = function()
    if AetherChat.Messenger and AetherChat.Messenger.TestWhisper then
        AetherChat.Messenger.TestWhisper()
    end
end

SLASH_COMMANDS['/aethertest'] = function()
    if AetherChat.Messenger and AetherChat.Messenger.TestWhisper then
        AetherChat.Messenger.TestWhisper()
    end
end

-- Debug: test keyword detection (/aetherkw WTT)
SLASH_COMMANDS['/aetherkw'] = function(args)
    local testWord = args and args ~= '' and args or 'test'
    -- Simulate a message FROM another player containing the test word
    local fakeMsg = 'WTS Motif vSS ' .. testWord .. ' LFG Tank'
    if AetherChat.Messenger and AetherChat.Messenger.OnMessageReceived then
        AetherChat.Messenger.OnMessageReceived('zone', '@TestPlayer', fakeMsg, false, false, 'global')
    end
    -- Also force rebuild the keyword table first
    if AetherChat.ChatEngine and AetherChat.ChatEngine.RebuildKeywordTable then
        AetherChat.ChatEngine.RebuildKeywordTable()
        d('|c5865F2[AetherChat]|r Keywords: ' .. tostring(#(AetherChat.ChatEngine.keywordTable or {})))
    end
end

SLASH_COMMANDS['/aethericon'] = function()
    if AetherChat.Messenger and AetherChat.Messenger.minBar then
        local isHidden = AetherChat.Messenger.minBar:IsHidden()
        AetherChat.Messenger.minBar:SetHidden(not isHidden)
        local status = isHidden and '|c23A55AVisible|r' or '|cF23F43Hidden|r'
        d('|c5865F2[AetherChat]|r MinBar : ' .. status)
    end
end

local function OnAddOnLoaded(event, addOnName)
    if addOnName ~= AetherChat.name then return end
    EVENT_MANAGER:UnregisterForEvent(AetherChat.name, EVENT_ADD_ON_LOADED)

    -- Initialize Modules in strict safe order
    AetherChat.Settings.Initialize()
    if AetherChat.CustomTabs and AetherChat.CustomTabs.Initialize then
        AetherChat.CustomTabs.Initialize()
    end
    if AetherChat.History and AetherChat.History.CleanAllDuplicates then
        AetherChat.History.CleanAllDuplicates()
    end
    AetherChat.ChatEngine.Initialize()
    AetherChat.Messenger.Initialize()

    local loadedMsg = AetherChat.L('CHAT_LOADED_MSG', AetherChat.version)
    d(loadedMsg)
end

EVENT_MANAGER:RegisterForEvent(AetherChat.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
