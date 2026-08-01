-- The handlers for chat related invites

local LGM = LGM or {}
local ChatFilter = LGM.ChatFilter

function LGM.HandlePlus(text)
   -- strip away leading plus only if it is not a singleton, to add support for singleton
   -- pluses while still preserving the original LGM behavior of ignoring leading pluses
   return select(3, text:find("^%+(.+)$")) or text
end

local function ShouldScanInvite(text, pattern)
   -- possibly gmatch
   if type(pattern) == "string" then
      for word in string.gmatch(string.lower(text), "([%w%+]+)") do
         if LGM.HandlePlus(word) == pattern then
            return true
         end
      end
   elseif type(pattern) == "table" then
      for word in string.gmatch(string.lower(text), "([%w%+]+)") do
         if pattern[LGM.HandlePlus(word)] then
            return true
         end
      end
   end
   return false
end
--EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED (integer GuildID,string PlayerName,luaindex prevStatus,luaindex curStatus)


-- function LGM.OnInviteReply(eventCode, inviteeName, response, inviteeDisplayName)
--    df("Received Reply: %s -> %s", inviteeDisplayName, responseMap[response])
-- end



function LGM.ChatUpdate(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
   if GetUnitDisplayName('player') ~= fromDisplayName and ShouldScanInvite(text, ChatFilter[channelType]) then
      LGM.inviteList:InviteRaidMember(fromDisplayName)
   end
end
--[[
GroupLeave()
GroupKickByName(string characterOrDisplayName)
GroupDisband()
--]]--
