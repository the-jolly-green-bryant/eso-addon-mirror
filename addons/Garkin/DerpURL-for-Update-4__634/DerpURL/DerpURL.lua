local urlPattern = {
	"([ \"%(%)<>;\\%]%|])%[*(%a+://[_A-Za-z0-9%./%&!?=#%%+-]+)%]*",
	"([ \"%(%)<>;\\%]%|])%[*([A-Za-z0-9]*%a+[_A-Za-z0-9-%.]*%a%.%a%a+[_A-Za-z0-9/%&:#!?=%%+-]*)%]*",
	"([ \"%(%)<>;\\%]%|])%[*([_A-Za-z0-9%.-]+@[_A-Za-z0-9%.-]*%.[A-Za-z0-9]+)%]*",
	"([ \"%(%)<>;\\%]%|])%[*([12]?%d?%d%.[12]?%d?%d%.[12]?%d?%d%.[12]?%d?%d:?%d*)]*",
}

local announceMsg = "LINK HAS BEEN COPIED TO CLIPBOARD";
local urlLink = "%1|c1888FF|H1:derpurl|h[%2]|h|r"  
local strsub = string.sub
local pauseTime = 3000
local announce

local function initAddMessage()
	local forward = ZO_ChatSystem_GetEventHandlers()[EVENT_CHAT_MESSAGE_CHANNEL]
	local rawEventUpdate = ZO_ChatSystem_AddEventHandler
	local urlPatternSize = #urlPattern
	local gsub = string.gsub
	
	rawEventUpdate(EVENT_CHAT_MESSAGE_CHANNEL, function(messageType, fromName, text, ...)
      text = "[DPuR1_]"..text
		for i = 1, urlPatternSize do
			text = gsub(text, urlPattern[i], urlLink)
		end
      text = gsub(text, "%[DPuR1_%]", "", 1)
      
		return forward(messageType, fromName, text, ...)
	end)
	
	ZO_ChatSystem_AddEventHandler = function(event, func)
		if event == EVENT_CHAT_MESSAGE_CHANNEL then
			forward = func
		else
			rawEventUpdate(event, func)
		end
	end
end

local initLinkParser = function()
	local editbox = ZO_ChatWindowTextEntryEditBox
	
	local copyLink = function(link, button)
		local old = editbox:GetText()
		if button == 1 then
			editbox:SetText(link)
			editbox:CopyAllTextToClipboard()
			editbox:SetText(old)
			announce(link)
		else
			editbox:SetText(old..link)
		end
	end

	local function HandleClicks(link, button, text, linkStyle, linkType)
		if linkType == "derpurl" then
			copyLink((text):match("%[(.+)%]"), button)
			return true
		end
	end

	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, HandleClicks)
	LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, HandleClicks)
end

do
	local limit = string.len(announceMsg)
	local offset, buff, neg, tiks

	local top = WINDOW_MANAGER:CreateTopLevelWindow("DerpURL")
	top:SetHeight(30)
	top:SetWidth(30)
	top:SetAnchor(BOTTOMLEFT, GuiRoot, CENTER, 26, -4)
	top:SetHidden(true)

	local lb = WINDOW_MANAGER:CreateControl("DerpURL_MSG", top, CT_LABEL)
	lb:SetFont("ZoFontHeader")
	lb:SetHeight(40)
	lb:SetAnchor(LEFT, top, LEFT, 0, 0)
	
	local postUpdate = function()
		neg = not neg
		top:SetHidden(neg)
		tiks = tiks + 1
		
		if tiks > 7 then
			top:SetHidden(true)
			EVENT_MANAGER:UnregisterForUpdate("DerpURL")
		end
	end
	
	local pause = function()
		tiks, neg = 0, false
		EVENT_MANAGER:UnregisterForUpdate("DerpURL")
		EVENT_MANAGER:RegisterForUpdate("DerpURL", 45, postUpdate)
	end
	
	local update = function()
		buff = buff..strsub(announceMsg, offset, offset)
		lb:SetText(buff)
		offset = offset + 1
		
		if offset > limit then
			EVENT_MANAGER:UnregisterForUpdate("DerpURL")
			EVENT_MANAGER:RegisterForUpdate("DerpURL", pauseTime, pause)
		end
	end
	
	announce = function()
		offset, buff = 1, ""
		lb:SetText("")
		top:SetHidden(false)
		EVENT_MANAGER:UnregisterForUpdate("DerpURL")
		EVENT_MANAGER:RegisterForUpdate("DerpURL", 10, update)
	end
end

EVENT_MANAGER:RegisterForEvent("DerpURL", EVENT_PLAYER_ACTIVATED, function()
	EVENT_MANAGER:UnregisterForEvent("DerpURL", EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:RegisterForUpdate("DerpURL", 1000, function()
		EVENT_MANAGER:UnregisterForUpdate("DerpURL")
		initLinkParser()
		initAddMessage()
	end)
end)
