-- ============================================================================
-- AetherChat : Main Addon Initialization & Keybindings
-- ============================================================================
AetherChat = AetherChat or {}
AetherChat.name = 'AetherChat'
AetherChat.version = '2.6.0'

-- Keybinding String
ZO_CreateStringId("SI_BINDING_NAME_AETHERCHAT_TOGGLE", "Ouvrir / Masquer AetherChat")

-- Register slash commands immediately
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
    if AetherChat_FloatingIcon then
        local isHidden = AetherChat_FloatingIcon:IsHidden()
        AetherChat_FloatingIcon:SetHidden(not isHidden)
        local status = isHidden and '|c23A55AVisible|r' or '|cF23F43Masquée|r'
        d('|c5865F2[AetherChat]|r Icône HUD : ' .. status)
    end
end

local function OnAddOnLoaded(event, addOnName)
    if addOnName ~= AetherChat.name then return end
    EVENT_MANAGER:UnregisterForEvent(AetherChat.name, EVENT_ADD_ON_LOADED)

    -- Initialize Modules in strict safe order
    AetherChat.Settings.Initialize()
    AetherChat.ChatEngine.Initialize()
    AetherChat.Messenger.Initialize()

    d('|c5865F2[AetherChat Messenger]|r v' .. AetherChat.version .. ' actif ! Appuyez sur votre touche ou tapez |cFFFFFF/aetherc|r pour ouvrir.')
end

EVENT_MANAGER:RegisterForEvent(AetherChat.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
