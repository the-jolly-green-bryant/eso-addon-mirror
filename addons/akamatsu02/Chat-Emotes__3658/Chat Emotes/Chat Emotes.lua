APCE = APCE or {
    name = "Chat Emotes",
	emoji_list = {},
	emoji_list_keys_sorted = {},
	buttonList = {},
	recommendButtonList = {},
	pages = {},
	currentPage = 0,
	savedVars = {},
	localization = {}
}

local LAM

local REGEX = ":([a-zA-Z0-9]+):"
local SEARCHREGEX = ":([a-zA-Z0-9]+)$"

local SPACER = 6
local SHIFTX = SPACER / 2
local DELTASIZE = 50
local SHIFTY = DELTASIZE / 2 + DELTASIZE / 10

--Handle incomming messages

function APCE.ChatHandler(channelID, from, text, isCustomerService, fromDisplayName)
    return APCE.Handler(channelID, from, APCE.FormatEmojiMessage(text), isCustomerService, fromDisplayName)
end

function APCE.RegisterMessageFormatter()
    APCE.Handler = CHAT_ROUTER:GetRegisteredMessageFormatters()[EVENT_CHAT_MESSAGE_CHANNEL]
    CHAT_ROUTER:RegisterMessageFormatter(EVENT_CHAT_MESSAGE_CHANNEL, APCE.ChatHandler)
end

function APCE.Register()
	CALLBACK_MANAGER:RegisterCallback("pChat_Initialized_EVENT_CHAT_MESSAGE_CHANNEL", APCE.RegisterMessageFormatter)
    APCE.RegisterMessageFormatter()
	zo_callLater(function () 
		CALLBACK_MANAGER:FireCallbacks("LibEditableChatWindowCanRegisterHandler")
	end, 2500)
end

function APCE.GetIconSize()
	return LibAkaUtils.getOrInit(APCE.savedVars.iconsize, GetChatFontSize() + SPACER)
end

function APCE.FormatEmojiMessage(message)
	local output = string.replace(message, REGEX, APCE.GetEmoji)
	return output
end

function APCE.GetEmoji(name)
	local emote = LibEmote.GetEmoteByName(name)
	if emote.name == "" then 
		return ":"..name..":"
	end
	local iconSize = emote.scale * APCE.GetIconSize()
	if emote.type == LibEmote.TYPE.ANIMATED then
		return LibAkaUtils.TextureMessage(iconSize, name)
	end
	return LibAkaUtils.TextureMessage(iconSize, emote.textures[1])
end

--End Handle incomming messages

--Emoji List

function APCE.SetupUnitRow(control, data)
	control.data = data
	
	control.icon1 = GetControl(control, "Icon1")
	control.icon2 = GetControl(control, "Icon2")
	control.icon3 = GetControl(control, "Icon3")
	control.icon4 = GetControl(control, "Icon4")
	control.icon5 = GetControl(control, "Icon5")
	control.icon6 = GetControl(control, "Icon6")
	
	if data.icon1 == nil then
		control.icon1:SetNormalTexture("")
	else
		control.icon1:SetNormalTexture(data.icon1.textures[1])
	end
	
	if data.icon2 == nil then
		control.icon2:SetNormalTexture("")
	else
		control.icon2:SetNormalTexture(data.icon2.textures[1])
	end
	
	if data.icon3 == nil then
		control.icon3:SetNormalTexture("")
	else
		control.icon3:SetNormalTexture(data.icon3.textures[1])
	end
	
	if data.icon4 == nil then
		control.icon4:SetNormalTexture("")
	else
		control.icon4:SetNormalTexture(data.icon4.textures[1])
	end
	
	if data.icon5 == nil then
		control.icon5:SetNormalTexture("")
	else
		control.icon5:SetNormalTexture(data.icon5.textures[1])
	end
	
	if data.icon6 == nil then
		control.icon6:SetNormalTexture("")
	else
		control.icon6:SetNormalTexture(data.icon6.textures[1])
	end
end

function APCE.InitList()
	ZO_ScrollList_AddDataType(EmojiBodyList, 1, "EmojiUnitRow", 74, APCE.SetupUnitRow)
	APCE.RefreshList(LibEmote.GetLoadedEmotePackNames()[APCE.currentMenu or 1])
	LibChatMenuButton.addChatButton("EmojiChatButton", LibEmote.GetAllEmotes()[1].textures[1], APCE.localization.openmenu, function()
		Emoji:SetHidden(Emoji:IsHidden() == false)
	end)
end

function APCE.RefreshList(search)
	local scrollData = ZO_ScrollList_GetDataList(EmojiBodyList)
	ZO_ScrollList_Clear(EmojiBodyList)
	
	local entries
	if search == nil or search == "" or search == "all" then
		entries = LibEmote.GetAllEmotes()
	else
		entries = LibEmote.SearchEmotesByName(search)
	end
	
	local data = {}
	
	for i=1, #entries, 6 do
		if entries[i] == nil then break end
		data[#data + 1] = {
			icon1 = entries[i],
			icon2 = entries[i+1],
			icon3 = entries[i+2],
			icon4 = entries[i+3],
			icon5 = entries[i+4],
			icon6 = entries[i+5]
		}
	end
	
	for i=1, #data do
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, data[i])
	end
	 
	ZO_ScrollList_Commit(EmojiBodyList)
	APCE.SetMenuNames()
end

--End Emoji List

--UI

function APCE.SetMenuNames()
	if APCE.currentMenu == nil then APCE.currentMenu = 1 end
	local packNames = LibEmote.GetLoadedEmotePackNames()
	
	local previous
	local current = APCE.currentMenu
	local nextx1
	local nextx2
	
	if packNames[APCE.currentMenu - 1] == nil then
		previous = #packNames
	else
		previous = APCE.currentMenu - 1
	end
	if packNames[APCE.currentMenu + 1] == nil then
		nextx2 = 2
		nextx1 = 1
	else
		nextx1 = APCE.currentMenu + 1
		if packNames[APCE.currentMenu + 2] == nil then
			nextx2 = 1
		else
			nextx2 = APCE.currentMenu + 2
		end
	end
	APCE.SetMenuDataAndText(EmojiBodyLeftMenuMenu1, previous, packNames[previous])
	APCE.SetMenuDataAndText(EmojiBodyLeftMenuMenu2, current, packNames[current])
	APCE.SetMenuDataAndText(EmojiBodyLeftMenuMenu3, nextx1, packNames[nextx1])
	APCE.SetMenuDataAndText(EmojiBodyLeftMenuMenu4, nextx2, packNames[nextx2])
end

function APCE.SetMenuDataAndText(control, index, sort, shown)
	if shown == nil then shown = sort end
	control.data = sort
	control.index = index
	control:GetNamedChild("Label"):SetText(string.setFirstLetterUppercase(shown))
end

--End UI

function APCE.AddEmojiInChat(name)
	LibAkaUtils.addToChat(":"..name..":")
end

function APCE.HandleText(text)
	if APCE.savedVars.recommendationsactive == false then return end
	if text == "" then
		EmojiRecommend:SetHidden(true)
		return 
	end
	local data = string.replace(text, REGEX, "")
	local emote = string.getLast(data, SEARCHREGEX)
	local normal = string.replace(text, SEARCHREGEX, "")
	if string.length(emote) < 3 then 
		EmojiRecommend:SetHidden(true)
		return 
	end
	APCE.FindRecommendedEmotes(emote, normal)
end

function APCE.FindRecommendedEmotes(pattern, normal)
	local results = LibEmote.SearchEmotesByName(pattern)
	if #results == 0 then 
		EmojiRecommend:SetHidden(true)
		return 
	end
	APCE.ShowRecommendedEmotes(results, normal)
end

function APCE.ShowRecommendedEmotes(emotes, normal)
	EmojiRecommend:SetHidden(false)
	LibAkaUtils.forLoop(1, APCE.savedVars.recommendations, 1, function(i)
		APCE.ClearButton(i)
	end)
	table.foreachi(emotes, function(index, emote)
		APCE.SetButton(index, emote, normal)
	end)
end

function APCE.ClearButton(i)
	APCE.recommendButtonList[i]:SetNormalTexture(APCE.name.."/empty.dds")
	APCE.recommendButtonList[i]:SetHandler("OnClicked", function() end )
	APCE.recommendButtonList[i]:SetHandler("OnMouseEnter", function() end )
	APCE.recommendButtonList[i]:SetHidden(true)
end

function APCE.SetButton(index, emote, normal)
	local button = APCE.recommendButtonList[index]
	if button == nil then return end
	button:SetNormalTexture(emote.textures[1])
	button:SetHidden(false)
	button:SetHandler("OnClicked", function()
		LibAkaUtils.setChat(normal)
		APCE.AddEmojiInChat(emote.name)
	end)
	button:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(button, RIGHT, ":"..emote.name..":") end )
end

function APCE.CreateRecommendButtons()
	LibAkaUtils.forLoopToEnd(APCE.savedVars.recommendations, function(index)
		APCE.CreateRecommendButton(index)
	end)
end

function APCE.CreateRecommendButton(index)
	if APCE.recommendButtonList[index] ~= nil then return end
	local button = WINDOW_MANAGER:CreateControl("ButtonRecommend_"..index, EmojiRecommend, CT_BUTTON)
	WINDOW_MANAGER:ApplyTemplateToControl(button, "ZO_ButtonBehaviorClickSound") 
	button:SetDimensions(50, 50)
	button:SetAnchor(TOPLEFT, EmojiRecommend, TOPLEFT, index * 55 - 55, 0)
	button:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end )
	button:SetHidden(true)
	APCE.recommendButtonList[index] = button
end

function APCE.CreateOpenMenuButton()
	local button = WINDOW_MANAGER:CreateControl("ButtonRecommendOpen", EmojiRecommend, CT_BUTTON)
	WINDOW_MANAGER:ApplyTemplateToControl(button, "ZO_ButtonBehaviorClickSound") 
	button:SetDimensions(50, 50)
	button:SetAnchor(TOPLEFT, EmojiRecommend, TOPLEFT, -55, 0)
	button:SetNormalTexture("esoui/art/buttons/plus_up.dds")
	button:SetHandler("OnClicked", function() Emoji:SetHidden(false) end )
	button:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(button, RIGHT, APCE.localization.openmenu) end )
	button:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end )
end

function APCE.onAdded()
	APCE.SetMenuNames()
end

function APCE.StorePosition(element)
    APCE.savedVars.position = LibAkaUtils.StorePosition(element)
end

local defaults = {
	["recommendations"] = 6,
	["recommendationsactive"] = true
}

local function OnAddOnLoaded( eventCode, addonName )
	if (addonName ~= APCE.name) then return end
	
	APCE.savedVars = ZO_SavedVars:NewAccountWide("AkapChatExtra_SAVE", 1, nil, defaults)
	
	LAM = LibAddonMenu2
	
	APCE.localize(LibAkaUtils.getLanguage())
	
	LibAkaUtils.SetElementAnchor(Emoji, APCE.savedVars.position, APCE.StorePosition)
	if APCE.savedVars.chatposition ~= nil then
		LibAkaUtils.SetChatWindowAnchor(APCE.chatButton, APCE.savedVars.chatposition, APCE.StoreChatWindowPosition)
	end
	
	APCE.Register()
	
	LibAkaUtils.addCommand("emojis", function ()
		Emoji:SetHidden(false)
	end)
	
	LibAkaUtils.AddChatListener(APCE.name, APCE.HandleText)
	
	APCE.InitList()
	
	APCE.CreateOpenMenuButton()
	APCE.CreateRecommendButtons()
	
	EmojiRecommend:SetDimensions(5 * 55, 50)
	EmojiRecommend:SetAnchor(TOPLEFT, CHAT_SYSTEM:GetEditControl(), TOPLEFT, 0, -60)
	
	APCE.buildMenu()
	
	EVENT_MANAGER:UnregisterForEvent(APCE.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(APCE.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

--localization
function APCE.localize(lang)
	if lang == "de" then
		APCE.localization.openmenu = "Emote-Menü öffnen"
		APCE.localization.iconsize = "Emote-Größe im Chat"
		APCE.localization.recommendationsactive = "Chat Vorschläge anzeigen"
		APCE.localization.recommendations = "Anzahl der Vorschläge"
		Emoji_Title:SetText("Emote auswählen")
	else
		APCE.localization.openmenu = "Open emote menu"
		APCE.localization.iconsize = "emote size in chat"
		APCE.localization.recommendationsactive = "Show chat recommendations"
		APCE.localization.recommendations = "Amount of recommendations"
		Emoji_Title:SetText("Select Emote")
	end
end

function APCE.buildMenu()
	local panelData = {
		type = "panel",
		name = APCE.name,
		displayName = APCE.name,
		author = "@akamatsu02",
		version = "2.1"
	}

	LAM:RegisterAddonPanel("Chat Emotes", panelData)
	
	local options = {
		{
			type = "header",
			name = "Options",
		},
		{
		    type = "editbox",
		    name = APCE.localization.iconsize,
		    getFunc = function() return APCE.GetIconSize() end,
		    setFunc = function(text) APCE.savedVars.iconsize = tonumber(text); end,
		    isMultiline = false,
		    default = 0,
			textType = TEXT_TYPE_NUMERIC,
			maxChars = 2
		},
		{
			type = "checkbox",
			name = APCE.localization.recommendationsactive,
			getFunc = function() return APCE.savedVars.recommendationsactive == true end,
			setFunc = function(value) APCE.savedVars.recommendationsactive = value end
		},
		{
		    type = "editbox",
		    name = APCE.localization.recommendations,
		    getFunc = function() return APCE.savedVars.recommendations end,
		    setFunc = function(text) APCE.savedVars.recommendations = tonumber(text);APCE.CreateRecommendButtons(); end,
		    isMultiline = false,
		    default = 0,
			textType = TEXT_TYPE_NUMERIC,
			maxChars = 2
		},
	}
	LAM:RegisterOptionControls(APCE.name, options)
end