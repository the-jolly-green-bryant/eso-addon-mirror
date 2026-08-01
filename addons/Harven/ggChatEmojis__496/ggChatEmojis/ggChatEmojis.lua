-- Global Initalizations
GGCE = {}
GGCE.addonName = "ggChatEmojis"
GGCE.version   = "1.17"

-- TODO: Update LibChat Versions
local LC = LibStub("libChat-1.0")

function GGCE.Initialize( eventCode, addOnName )
  if ( addOnName ~= GGCE.addonName ) then return end

  -- Setup our chat Interceptor
  LC:registerText(function(chanID, from, text) return GGCE.Emojify(text) end )

  -- Once we've loaded ours, lets unregister the event listener
  EVENT_MANAGER:UnregisterForEvent("GGCE", EVENT_ADD_ON_LOADED)
end

function GGCE.Emojify(text)
  for key, value in pairs(GGCE.emojiGameList) do
    local pattern = "(%A)" .. key .. "(%A)"
	local replacement = "%1" .. string.format("|t%d:%d:%s|t", 18, 18, value) .. "%2" 
    text = string.sub((" " .. text .. " "):gsub(pattern, replacement), 2, -2)
  end
  return text
end

-- Hook Initialization
EVENT_MANAGER:RegisterForEvent("GGCE", EVENT_ADD_ON_LOADED , GGCE.Initialize)


--[[

--- --- --- --- ---
Ideas / Issues
--- --- --- --- ---

~ Chat Cheatsheet (see code below)
~ Add Support for Reversed Smiles (: (;

-- Hook into the chat system, while we type, lets give an autocomplete
function GGCE.ChatAutocomplete()
  ZO_PreHookHandler(ZO_ChatWindowTextEntryEditBox, "On___", function() 
    GGCE.OutgoingChat()
  end)
end

]]