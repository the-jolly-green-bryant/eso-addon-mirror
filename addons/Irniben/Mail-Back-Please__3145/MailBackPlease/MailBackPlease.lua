MailBackPlease = {
	name = "MailBackPlease",
}

local GS = GetString
local lastSentItems = {}

function MailBackPlease.OnSendSuccess()
	local noItemsSent = true
	for i, v in pairs(lastSentItems) do
		noItemsSent = false
		if GetItemLink(BAG_BACKPACK, i) == v then 
			MailBackPlease.OnSendFail(1, 424242)
			return
		end
	end
	lastSentItems = {}	
	EVENT_MANAGER:UnregisterForEvent(MailBackPlease.name.."SendFail", EVENT_MAIL_SEND_FAILED)
	EVENT_MANAGER:UnregisterForEvent(MailBackPlease.name.."SendSuccess", EVENT_MAIL_SEND_SUCCESS)
	if noItemsSent then 
		return
	end
	d(string.format(GS(MAILBACKPLEASE_MailSuccess), MailBackPlease.sV.recipient, UndecorateDisplayName(MailBackPlease.sV.recipient)))
	if MailBackPlease.sV.sendAll then MailBackPlease.mbp() end
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend")  then CloseMailbox() end
end

function MailBackPlease.OnSendFail(_, SendMailResult)
	if SendMailResult == 424242 then
		d(GS(MAILBACKPLEASE_MailSpecialFail))
	else
		d(GS(MAILBACKPLEASE_MailFail)..GS("SI_SENDMAILRESULT", SendMailResult))
	end
	for i=1, MAIL_MAX_ATTACHED_ITEMS do
		RemoveQueuedItemAttachment(i)
	end
	EVENT_MANAGER:UnregisterForEvent(MailBackPlease.name.."SendFail", EVENT_MAIL_SEND_FAILED)
	EVENT_MANAGER:UnregisterForEvent(MailBackPlease.name.."SendSuccess", EVENT_MAIL_SEND_SUCCESS)
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend")  then 
		CloseMailbox() 
	end
end


function MailBackPlease.mbp()
	if not MailBackPlease.sV.recipient or MailBackPlease.sV.recipient == "" then 
		d(GS(MAILBACKPLEASE_NoRecipient))
		return 
	end
	local bagID = BAG_BACKPACK
	local myList = {}
	local textList = {""}
	lastSentItems = {}
	local options = MailBackPlease.sV
	
	local invalidBindTypes = {
		[BIND_TYPE_ON_PICKUP] = true,
		[BIND_TYPE_ON_PICKUP_BACKPACK] = true,
	}
	
	for slotId=0, GetBagSize(bagID) do
		local myLink = ""
		myLink = GetItemLink(bagID, slotId)
		local itemType, specialItemType = GetItemLinkItemType(myLink)
		local putOnList = false
		local isProtectedAgainstMail = FCOIS and FCOIS.IsMailLocked(bagId, slotId) or false
		if not IsItemPlayerLocked(bagID, slotId) and not IsItemLinkStolen(myLink) and not isProtectedAgainstMail then
			if (not IsItemBound(bagID, slotId)) then
				if itemType == ITEMTYPE_MASTER_WRIT and options.writs then
					putOnList = true
				elseif itemType == ITEMTYPE_RECIPE then
					if IsItemLinkFurnitureRecipe(myLink) then 
						if options.furnitureplans then putOnList = true end
					elseif options.recipes then
						putOnList = true
					end
				elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and options.motifs then
					putOnList = true
				elseif options.glyphs and (itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON) and GetItemLinkQuality(myLink) < 5 then
					putOnList = true
				elseif options.simpleEquipment and (itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON) and GetItemLinkQuality(myLink) < 4 then 
					if options.craftedEquipment or not IsItemLinkCrafted(myLink) then
						local hasSet = GetItemLinkSetInfo(myLink) 
						if not hasSet then 
							putOnList = true
						elseif options.setItems and not invalidBindTypes[GetItemLinkBindType(myLink)] then
							if (not CCMG or not CCMG.checkItem or not CCMG.checkItem(bagID, slotId, true)) and
								(options.includeUncollected or IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(myLink))) then 
									putOnList = true 
							end
						end
					end
				end
			end
		end
		if putOnList then
			table.insert(myList, slotId)
			table.insert(textList, myLink)
			lastSentItems[slotId] = myLink
		end
		if #myList == MAIL_MAX_ATTACHED_ITEMS then break end
	end
	if #myList == 0 then return end
	if not SCENE_MANAGER:IsShowing("mailInbox") and not  SCENE_MANAGER:IsShowing("mailSend")  then CloseMailbox() end
	RequestOpenMailbox()
	for i,v in pairs(myList) do
		QueueItemAttachment(bagID,  v, i) 
	end
	local myText = MailBackPlease.sV.useQuote and MailBackPlease.quotes[math.random(1, #MailBackPlease.quotes)] or ""
	
	
	EVENT_MANAGER:RegisterForEvent(MailBackPlease.name.."SendFail", EVENT_MAIL_SEND_FAILED, MailBackPlease.OnSendFail)
	EVENT_MANAGER:RegisterForEvent(MailBackPlease.name.."SendSuccess", EVENT_MAIL_SEND_SUCCESS, MailBackPlease.OnSendSuccess)
	
	SendMail(MailBackPlease.sV.recipient, MailBackPlease.sV.subject, myText)
	if not SCENE_MANAGER:IsShowing("mailInbox") and not  SCENE_MANAGER:IsShowing("mailSend")  then CloseMailbox() end
	if MailBackPlease.sV.completeList then
		d(string.format(GS(MAILBACKPLEASE_ItemNumberSent), MailBackPlease.sV.recipient, table.concat(textList, "\n")))
	else
		d(string.format(GS(MAILBACKPLEASE_ItemNumberSent), MailBackPlease.sV.recipient, #myList))
	end
end
	
function MailBackPlease.OnAddonLoaded(event, addonName)
	if addonName == MailBackPlease.name then
		MailBackPlease:Initialize()
	end
end

local function GetFriendsList()
	local myFriendsList = {}
	for i=1,GetNumFriends() do
		local displayName = GetFriendInfo(i)
		table.insert(myFriendsList, displayName)
	end
	return myFriendsList
end

function MailBackPlease.OnInboxUpdate()
	EVENT_MANAGER:UnregisterForEvent(MailBackPlease.name.."OnInboxUpdate", EVENT_MAIL_INBOX_UPDATE)
	local isExpiring
	local warnBefore = MailBackPlease.sV.alertDays
	local mailId = GetNextMailId()
	local expSystem = 42
	local expPlayer = 42
	while mailId do
		local _, _, _, _, _, fromSystem, _, _, _, _, _, expiresInDays = GetMailItemInfo(mailId)
		-- string senderDisplayName, string senderCharacterName, string subject, textureName icon, boolean unread, boolean fromSystem, boolean fromCustomerService, boolean returned, number numAttachments, number attachedMoney, number codAmount, number expiresInDays, number secsSinceReceived 
		if expiresInDays then
			if expiresInDays <= warnBefore then isExpiring = true end
			if fromSystem then
				if expiresInDays <= expSystem then expSystem = expiresInDays end
			elseif expiresInDays <= expPlayer then 
				expPlayer = expiresInDays 
			end
		end
		mailId = GetNextMailId(mailId)
	end
	if not isExpiring then return end
	local myMessage = {}
	if expPlayer <= warnBefore then table.insert(myMessage, zo_strformat(GS(MAILBACKPLEASE_AlertPlayer), expPlayer)) end
	if expSystem <= warnBefore then table.insert(myMessage, zo_strformat(GS(MAILBACKPLEASE_AlertSystem), expSystem)) end
	myMessage = table.concat(myMessage, "\n")
	if MailBackPlease.sV.alertOnScreen then 
		 CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.COLLECTIBLE_UNLOCKED, GS(MAILBACKPLEASE_AlertTxtHead), myMessage, "esoui/art/mail/mail_tabicon_inbox_up.dds", nil, nil, nil, 5000)
	end
	if MailBackPlease.sV.alertInChat then
		d(myMessage)
	end
end

function MailBackPlease.OnActivated()
	EVENT_MANAGER:RegisterForEvent(MailBackPlease.name.."OnInboxUpdate", EVENT_MAIL_INBOX_UPDATE, MailBackPlease.OnInboxUpdate)
	EVENT_MANAGER:UnregisterForEvent(MailBackPlease.name.."OnActivated", EVENT_PLAYER_ACTIVATED)
end	

function MailBackPlease:Initialize()
	local serverName = GetWorldName()
	if MailBackPleaseSavedVariables and MailBackPleaseSavedVariables["Default"] and not MailBackPleaseSavedVariables[serverName] then
		MailBackPleaseSavedVariables[serverName] = {}
		ZO_ShallowTableCopy(MailBackPleaseSavedVariables["Default"], MailBackPleaseSavedVariables[serverName])
		MailBackPleaseSavedVariables["Default"] = nil
		MailBackPlease.migrated = true
	end
	MailBackPlease.sV = ZO_SavedVars:NewAccountWide("MailBackPleaseSavedVariables", 1, nil, {}, serverName) -- account wide
   
	local panelData = {
		type = "panel",
		name = "Mail Back Please",
    }
	MailBackPlease.sV.alertDays = MailBackPlease.sV.alertDays or 4
	MailBackPlease.sV.subject = MailBackPlease.sV.subject or "RETURN: Mail Back Please"
	local optionsData = {
		{
			type = "dropdown",
			name = GS(MAILBACKPLEASE_Recipient),
			tooltip = GS(MAILBACKPLEASE_Recipient_TT),
			choices = GetFriendsList(),
			sort = "name-up",
			scrollable = true,
			default = 0,
			getFunc = function() return MailBackPlease.sV.recipient end,
			setFunc = function(value) MailBackPlease.sV.recipient = value end,
		},
		{
			type = "editbox",
			name = GS(MAILBACKPLEASE_Subject),
			width = "full",
			isMultiline = false,
			isExtraWide = true,
			default = 0,
			getFunc = function() return MailBackPlease.sV.subject end,
			setFunc = function(value) MailBackPlease.sV.subject = value end,
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_Shakespeare),
			tooltip = GS(MAILBACKPLEASE_Shakespeare_TT),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.useQuote end,
			setFunc = function(value) MailBackPlease.sV.useQuote = value end,
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_OptionList),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.completeList end,
			setFunc = function(value) MailBackPlease.sV.completeList = value end,
		},	
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_OptionAuto),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.sendAll end,
			setFunc = function(value) MailBackPlease.sV.sendAll = value end,
		},			
		{
			type = "divider",
			width = "full",
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_MasterWrit),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.writs end,
			setFunc = function(value) MailBackPlease.sV.writs = value end,
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_Motifs),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.motifs end,
			setFunc = function(value) MailBackPlease.sV.motifs = value end,
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_Recipes),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.recipes end,
			setFunc = function(value) MailBackPlease.sV.recipes = value end,
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_FurniturePlans),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.furnitureplans end,
			setFunc = function(value) MailBackPlease.sV.furnitureplans = value end,
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_Glyphs),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.glyphs end,
			setFunc = function(value) MailBackPlease.sV.glyphs = value end,
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_SimpleEquipment),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.simpleEquipment end,
			setFunc = function(value) MailBackPlease.sV.simpleEquipment = value end,
		},
		{
			type = "checkbox",
			name = GS(SI_ITEM_FORMAT_STR_CRAFTED),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.craftedEquipment end,
			setFunc = function(value) MailBackPlease.sV.craftedEquipment = value end,
			disabeld = function() return not MailBackPlease.sV.simpleEquipment end,
		},
		{
			type = "checkbox",
			name = GS(SI_ITEM_SETS_BOOK_TITLE),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.setItems end,
			setFunc = function(value) MailBackPlease.sV.setItems = value end,
			disabeld = function() return not MailBackPlease.sV.simpleEquipment end,
		},
		{
			type = "checkbox",
			name = GS(SI_ITEM_FORMAT_STR_SET_COLLECTION_PIECE_LOCKED),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.includeUncollected end,
			setFunc = function(value) MailBackPlease.sV.includeUncollected = value end,
			disabeld = function() return not MailBackPlease.sV.simpleEquipment or not MailBackPlease.sV.setItems end,
		},
		{
			type = "header",
			name = GS(MAILBACKPLEASE_AlertHead),
			width = "full",
		},
		{
			type = "slider",
			name = GS(MAILBACKPLEASE_AlertNumber),
			tooltip = GS(MAILBACKPLEASE_AlertNumberTooltip),
			min = 1,
			max = 10,
			step = 1, --(optional)
			clampInput = true, 
			clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
			decimals = 0, 
			autoSelect = true,
			width = "full",
			default = 4,
			getFunc = function() return MailBackPlease.sV.alertDays end,
			setFunc = function(value) MailBackPlease.sV.alertDays = value end,
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_AlertOnScreen),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.alertOnScreen end,
			setFunc = function(value) MailBackPlease.sV.alertOnScreen = value end,
		},
		{
			type = "checkbox",
			name = GS(MAILBACKPLEASE_AlertInChat),
			width = "full",
			default = 0,
			getFunc = function() return MailBackPlease.sV.alertInChat end,
			setFunc = function(value) MailBackPlease.sV.alertInChat = value end,
		},
    }
	
	local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel("MailBackPleaseOptions", panelData)
	LAM:RegisterOptionControls("MailBackPleaseOptions", optionsData)
		
	if MailBackPlease.sV.alertOnScreen or MailBackPlease.sV.alertInChat then
		EVENT_MANAGER:RegisterForEvent(MailBackPlease.name.."OnActivated", EVENT_PLAYER_ACTIVATED, MailBackPlease.OnActivated)
	end
	
	EVENT_MANAGER:UnregisterForEvent(MailBackPlease.name.."OnLoad", EVENT_ADD_ON_LOADED)
end

SLASH_COMMANDS["/mbp"] = MailBackPlease.mbp

EVENT_MANAGER:RegisterForEvent(MailBackPlease.name.."OnLoad", EVENT_ADD_ON_LOADED, MailBackPlease.OnAddonLoaded)