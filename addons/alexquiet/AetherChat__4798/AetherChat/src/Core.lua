-- ============================================================================
-- AetherChat : Main Addon Initialization & Keybindings
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

AetherChat.name = 'AetherChat'
AetherChat.version = '1.1'

-- Keybinding Strings (Must be created before Bindings.xml is loaded by C++ engine)
local L = AetherChat.L or function(k) return k end
ZO_CreateStringId("SI_BINDINGS_CATEGORY_AETHERCHAT", "AetherChat")
ZO_CreateStringId("SI_BINDING_NAME_AETHERCHAT_TOGGLE", L('BINDING_NAME'))

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
    if AetherChat.History and AetherChat.History.CleanAllDuplicates then
        AetherChat.History.CleanAllDuplicates()
    end
    AetherChat.ChatEngine.Initialize()
    AetherChat.Messenger.Initialize()

    local loadedMsg = AetherChat.L('CHAT_LOADED_MSG', AetherChat.version)
    d(loadedMsg)
end

EVENT_MANAGER:RegisterForEvent(AetherChat.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
