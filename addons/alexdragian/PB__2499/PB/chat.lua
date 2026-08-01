local PCHATLC = LibStub("libChat-1.0")

local function showCustomerService(isCustomerService)

	if(isCustomerService) then
		return "|t16:16:EsoUI/Art/ChatWindow/csIcon.dds|t"
	end
	
	return ""
	
end

function PB.FormatMessage(channelID, from, text, isCS, fromDisplayName, originalFrom, originalText, DDSBeforeAll, TextBeforeAll, DDSBeforeSender, TextBeforeSender, TextAfterSender, DDSAfterSender, DDSBeforeText, TextBeforeText, TextAfterText, DDSAfterText)

  if existingFormatter then
    return existingFormatter(channelID, from, text, isCS, fromDisplayName, originalFrom, originalText, DDSBeforeAll, TextBeforeAll, DDSBeforeSender, TextBeforeSender, TextAfterSender, DDSAfterSender, DDSBeforeText, TextBeforeText, TextAfterText, DDSAfterText)
  else
    -- Create channel link
    local ChanInfoArray = ZO_ChatSystem_GetChannelInfo()
	  local info = ChanInfoArray[channelID]
		local channelLink
		if info.channelLinkable then
			local channelName = GetChannelName(info.id)
			channelLink = ZO_LinkHandler_CreateChannelLink(channelName)
    end
		
		-- Create player link
		local playerLink
		if info.playerLinkable and not from:find("%[") then
			playerLink = DDSBeforeSender .. TextBeforeSender .. ZO_LinkHandler_CreatePlayerLink((from)) .. TextAfterSender .. DDSAfterSender
		else
			playerLink = DDSBeforeSender .. TextBeforeSender .. from .. TextAfterSender .. DDSAfterSender
		end
		
		text = DDSBeforeText .. TextBeforeText .. text .. TextAfterText .. DDSAfterText
		
		-- Create default formatting
		if channelLink then
			message = DDSBeforeAll .. TextBeforeAll .. zo_strformat(info.format, channelLink, playerLink, text)
		else
			message = DDSBeforeAll .. TextBeforeAll .. zo_strformat(info.format, playerLink, text, showCustomerService(isCustomerService))
		end
    
    return message, info.saveTarget
  end
end


function PB.OnPlayerActivated()
  existingRegister = PCHATLC.registerFormat
  function PCHATLC:registerFormat(func, ...)
    existingFormatter = func
  end
  zo_callLater(function()
    PCHATLC.registerFormat = existingRegister
    PCHATLC:registerFormat(PB.FormatMessage, "PB")
  end, 500)
end

EVENT_MANAGER:RegisterForEvent("1" .. PB.addon, EVENT_PLAYER_ACTIVATED, PB.OnPlayerActivated)