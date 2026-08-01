toxicIRCAddon = {}
toxicIRCAddon.name = 'toxicIRC'
toxicIRCAddon.version = "0.9"
local username = string.sub(GetDisplayName(), 2)
local character = GetUnitName("player")

function toxicIRCAddon:checkName(msg)
    local match = nil
    local patterns = {
        "("..username..")",
        "("..string.lower(username)..")",
        "("..character..")",
        "("..string.lower(character)..")"
    }

    for k, v in pairs(patterns) do
        if patterns[k] then
            match = string.match(msg, v)
            if type(match) == "string" then
                return match
            end
        end
    end
    return nil
end

function toxicIRCAddon:IRCStyle(text)
    local forward = ZO_ChatSystem_GetEventHandlers()[EVENT_CHAT_MESSAGE_CHANNEL];
    local rawEventUpdate = ZO_ChatSystem_AddEventHandler;

    rawEventUpdate(EVENT_CHAT_MESSAGE_CHANNEL, function(arg1, arg2, msg, ...)
        if not msg then
            return forward(arg1, arg2, msg, ...);
        end
        match = toxicIRCAddon:checkName(msg)
        if match then
            msg = string.gsub(msg, match, "|cffff00"..match.."|r")
        end
        return forward(arg1, arg2, msg, ...);
    end);

    ZO_ChatSystem_AddEventHandler = function(event, func)
        if event == EVENT_CHAT_MESSAGE_CHANNEL then
            forward = func;
        else
            rawEventUpdate(event, func);
        end
    end
end

function toxicIRCAddon:Initialize()
    EVENT_MANAGER:RegisterForEvent("toxicIRC", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent("toxicIRC", EVENT_PLAYER_ACTIVATED)
        EVENT_MANAGER:RegisterForUpdate("toxicIRC", 1000, function()
            EVENT_MANAGER:UnregisterForUpdate"toxicIRC"
            toxicIRCAddon:IRCStyle()
        end)
    end)
end

function toxicIRCAddon.OnAddOnLoaded(event, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == toxicIRCAddon.name then
        toxicIRCAddon:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(toxicIRCAddon.name, EVENT_ADD_ON_LOADED, toxicIRCAddon.OnAddOnLoaded)