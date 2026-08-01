ALT_HERO_SYSTEM = {}
local systemName = "Alt Hero System"

function ALT_HERO_SYSTEM.GetName() return systemName end

function ALT_HERO_SYSTEM.Initialize()
    --Add Initialization tasks here
    if MAIN.accountVariables.altHero == nil then
        MAIN.accountVariables.altHero = {}
        d("Performing first-time setup for Alt Hero System. Please use /altupdatename to add alt hero before using the Alt Hero System.")
    end

    EVENT_MANAGER:RegisterForEvent(systemName, EVENT_TRADE_INVITE_CONSIDERING, function(eventCode, inviteeCharacterName, inviteeDisplayName)
        if inviteeDisplayName == MAIN.accountVariables.altHero.name then
            TradeInviteAccept()
        end
    end)
end

MAIN.AddToInitializeSystemsList(ALT_HERO_SYSTEM)

function UpdateAltHeroName(newName)
    MAIN.accountVariables.altHero.name = newName
end

function CheckIfAltHeroExists()
    if MAIN.accountVariables.altHero.name == nil then
        d("No alt hero found - please use /altupdatename to add alt hero before using the Alt Hero System.")
        return false
    else return true
    end
end

function InviteAltHeroToGroup()
    if CheckIfAltHeroExists() == true then GroupInviteByName(MAIN.accountVariables.altHero.name) end
end

function WhisperAltHero(message)
    if CheckIfAltHeroExists() == true then CHAT_SYSTEM:StartTextEntry("/w "..MAIN.accountVariables.altHero.name.." "..message) end
end

SLASH_COMMANDS["/altupdatename"] = function(newName) UpdateAltHeroName(newName) end
SLASH_COMMANDS["/altinvite"] = function()
    InviteAltHeroToGroup()
    WhisperAltHero("come")
end
SLASH_COMMANDS["/altcome"] = function() WhisperAltHero("come") end
SLASH_COMMANDS["/altswitch"] = function() WhisperAltHero("switch") end
SLASH_COMMANDS["/altvisit"] = function() if CheckIfAltHeroExists() == true then JumpToFriend(MAIN.accountVariables.altHero.name) end end
SLASH_COMMANDS["/altsharedailies"] = function(zoneName)
    if zoneName == nil or zoneName == "" then d("Enter a zone name.")
    else WhisperAltHero(zoneName)
    end
end
SLASH_COMMANDS["/alttrade"] = function() TradeInviteByName(MAIN.accountVariables.altHero.name) end