CCMG = {
	name = "CarosCollectionMailGroup",
}

local LMAS = LibMultiAccountSets
local GS = GetString
local ccmgSubject = "CCMG-Mail"
local notccmgSubject = "CCMG - LibMultiAccountSets"
local useLMAS = false
local ccmgRecipient = false

local mailInProgress = false
local lastSentItems = {}
local ccmgdebug = false


local mailsToRead = {}
local mailsToLoot = {}
local bindList = {}
local lootedMails = {}
local bankCount = 0
local sumAttachments = 0

local function ccmgYesNoFunctionDiag(myTitle, myText, myFunc, myArgs, myFunc2, myArgs2)
	myArgs = myArgs or {}
	myArgs2 = myArgs2 or {}
	myFunc2 = myFunc2 or function() end
	ESO_Dialogs["ccmgYesNoFunction"] = {
		canQueue = true,
		uniqueIdentifier = "ccmgYesNoFunction",
		title = {text = myTitle},
		mainText = {text = myText},
		buttons = {
			[1] = {
				text = SI_DIALOG_YES,
				callback = function() myFunc(unpack(myArgs)) end,
			},
			[2] = {
				text = SI_DIALOG_NO,
				callback = function() myFunc2(unpack(myArgs2)) end,
			},
		},
		setup = function() end,
	}
	-- , options, textParams
	ZO_Dialogs_ShowDialog("ccmgYesNoFunction")
end

local function itemSetParam(myLink)
	local mySetPiece = GetItemLinkEquipType(myLink)
	local myWeaponType = GetItemLinkWeaponType(myLink)
	if myWeaponType ~= WEAPONTYPE_NONE then mySetPiece = myWeaponType + 42 end
	local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(myLink) 
	setId = hasSet and setId or false
	return mySetPiece, setId
end

local readTries = 0
local function tryToReadNext(first)
	if #mailsToRead > 0 then
		if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r trying to read next") end
		if IsReadMailInfoReady(mailsToRead[1]) then
			if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r already ready to read") end 
			CCMG.readMail(nil, mailsToRead[1])
		else
			local currentMail = mailsToRead[1]
			if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r Request readmail") end 
			if RequestReadMail(currentMail) == REQUEST_READ_MAIL_RESULT_NO_SUCH_MAIL then 
				if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r No such mail - removing from queue") end 
				table.remove(mailsToRead, 1)
				currentMail = mailsToRead[1]
				tryToReadNext()
			else
				readTries = readTries + 1
				local myName = "CCMG_ReadTry"..readTries
				EVENT_MANAGER:RegisterForUpdate(myName, 100,
					function()
					EVENT_MANAGER:UnregisterForUpdate(myName)
					if currentMail ==  mailsToRead[1] and not IsReadMailInfoReady(currentMail) then
						if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r trying again to request readmail (not ready yet)") end 
						RequestReadMail( currentMail)
					end 
					
				end)
				--zo_callLater(function()
				--	if currentMail ==  mailsToRead[1] and not IsReadMailInfoReady(currentMail) then
				--		if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r trying again to request readmail (not ready yet)") end 
				--		RequestReadMail( currentMail)
				--	end 
				--end, 100)
			end	
		end
		return true
	else	
		if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r nothing more to read") end
		return false
	end
end

function CCMG.OnSendSuccess()
	for i, v in pairs( lastSentItems) do
		if GetItemLink(BAG_BACKPACK, i) == v then 
			CCMG.OnSendFail(1, 424242)
			return
		end
	end
	for i, v in pairs(lastSentItems) do
		CCMG.sV.counter1 = CCMG.sV.counter1 + 1
		if useLMAS then
			CCMG.sV.accountSentItems[recipient] = CCMG.sV.accountSentItems[recipient] or {}
			local mySetPiece, setId = itemSetParam(v)
			CCMG.sV.accountSentItems[recipient][setId] = CCMG.sV.accountSentItems[recipient][setId] or {}
			CCMG.sV.accountSentItems[recipient][setId][mySetPiece] = true
		else
			CCMG.sV.sentItems[v] = true
		end
	end
	d(string.format(GS(CCMG_MailSuccess), CCMG.sV.recipient, UndecorateDisplayName(CCMG.sV.recipient)))
	EVENT_MANAGER:UnregisterForEvent(CCMG.name.."SendFail", EVENT_MAIL_SEND_FAILED)
	EVENT_MANAGER:UnregisterForEvent(CCMG.name.."SendSuccess", EVENT_MAIL_SEND_SUCCESS)
	if CCMG.sV.sendAll then 
		CCMG.sendItems() 
	elseif bankCount > 0 then 
		d(zo_strformat(GS(CCMG_BankMsg), bankCount))
	end
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend")  then CloseMailbox() end
end

function CCMG.OnSendFail(_, SendMailResult)
	if SendMailResult == 424242 then
		d(GS(CCMG_MailSpecialFail))
	else
		d(GS(CCMG_MailFail)..GS("SI_SENDMAILRESULT", SendMailResult))
	end
	for i=1, MAIL_MAX_ATTACHED_ITEMS do
		RemoveQueuedItemAttachment(i)
	end
	EVENT_MANAGER:UnregisterForEvent(CCMG.name.."SendFail", EVENT_MAIL_SEND_FAILED)
	EVENT_MANAGER:UnregisterForEvent(CCMG.name.."SendSuccess", EVENT_MAIL_SEND_SUCCESS)
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend")  then CloseMailbox() end
end

local function checkItem(bagId, slotId, canQueue)
	local myLink = ""
	myLink = GetItemLink(bagId, slotId)
	local itemType, specialItemType = GetItemLinkItemType(myLink)
	local putOnList = false
	local isProtectedAgainstMail = FCOIS and FCOIS.IsMailLocked(bagId, slotId) or false
	local canQueueThis = canQueue or CanQueueItemAttachment(bagId, slotId)
	if not IsItemPlayerLocked(bagId, slotId) and not IsItemLinkStolen(myLink) and not isProtectedAgainstMail and canQueueThis and GetItemBindType(bagId, slotId) ~= BIND_TYPE_ON_PICKUP then
		if (not IsItemBound(bagId, slotId)) then
			if IsItemLinkSetCollectionPiece(myLink) then
				if IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(myLink)) then
					if GetItemLinkQuality(myLink) < 5 then 
						local mySetPiece, setId = itemSetParam(myLink)
						if setId and not (not useLMAS and CCMG.sV.ignoredItems[setId] and CCMG.sV.ignoredItems[setId][mySetPiece]) 
							and not (useLMAS and (LibMultiAccountSets.IsItemSetCollectionItemLinkUnlockedForAccount(recipient, myLink) or 
							CCMG.sV.accountSentItems and CCMG.sV.accountSentItems[recipient] and CCMG.sV.accountSentItems[recipient][setId] and CCMG.sV.accountSentItems[recipient][setId][mySetPiece])) then 
							return myLink
						end
					end
				end
			end
		end
	end
	return 
end

CCMG.checkItem = checkItem

local function takeBankItems()
	local myPosition = 1
	local myCount = 0
	local theBank = BAG_BANK
	
	local function transferItem(sourceSlot)
		local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
		if not destSlot then return false end
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", theBank, sourceSlot, BAG_BACKPACK, destSlot, 1)
		else
			RequestMoveItem(theBank, sourceSlot, BAG_BACKPACK, destSlot, 1)
		end
		return true
	end
	for slotIt=0, GetBagSize(BAG_BANK) do
		if checkItem(BAG_BANK, slotIt, true) then myCount = myCount + 1 end
	end
	for slotIt=0, GetBagSize(BAG_SUBSCRIBER_BANK) do
		if checkItem(BAG_SUBSCRIBER_BANK, slotIt, true) then myCount = myCount + 1 end
	end
	local  function transferNext()
		for slotIt=0, GetBagSize(theBank) do
			local myLink = checkItem(theBank, slotIt, true)
			if myLink then
				d(string.format(GS(CCMG_XoutofY), myPosition, myCount, myLink))
				myPosition = myPosition + 1
				if not transferItem(slotIt) then 
					d(GS(CCMG_NotEnoughSpace)) 
				else
					local myTries = 1
					local function checkSlot(myTries)
						myTries = myTries + 1
						zo_callLater(function()
							if GetItemId(theBank, slotIt) ~= 0 then
								if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
									checkSlot(myTries) 
								else
									d(GS(CCMG_TransferFail))
								end
							else
								transferNext()
							end
						end, 50)
					end
					checkSlot(myTries)
				end
				return
			end
		end
		-- EVENT_MANAGER:UnregisterForEvent(CCMG.name.."InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		if theBank == BAG_BANK then theBank = BAG_SUBSCRIBER_BANK transferNext() end
	end
	if myCount == 0 then 
		d(GS(CCMG_NoTransfer))
		return 
	end
	d(GS(CCMG_Transferring))
	transferNext()
	
end

function CCMG.sendItems(arg)
	if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r Starting the progress")  end
	if GetInteractionType() == INTERACTION_BANK then takeBankItems() return end
	if IsUnitInCombat("player") then
		d(GS(CCMG_InCombat))
		return
	end
	useLMAS = arg == "useLMAS"
	if not useLMAS then recipient = CCMG.sV.recipient or "" end
	if recipient == "" then 
		d(GS(CCMG_NoRecipient))
		return 
	end
	local myList = {}
	local textList = {}
	local bagItems = GetBagSize(BAG_BACKPACK)
	local bagId = BAG_BACKPACK
	for slotId=0, bagItems do
		local myLink = checkItem(bagId, slotId)
		if myLink then
			table.insert(myList, slotId)
			table.insert(textList, myLink)
		end
		if #myList == MAIL_MAX_ATTACHED_ITEMS then break end
	end
	
	bankCount = 0
	for slotId=0, GetBagSize(BAG_BANK) do
		if checkItem(BAG_BANK, slotId, true) then bankCount = bankCount + 1 end
	end
	for slotId=0, GetBagSize(BAG_SUBSCRIBER_BANK) do
		if checkItem(BAG_SUBSCRIBER_BANK, slotId, true) then bankCount = bankCount + 1 end
	end
	
	if #myList == 0 then 
		if bankCount > 0 then 
			d(zo_strformat(GS(CCMG_BankMsg), bankCount))
		end
		d(GS(CCMG_NothingToSend))
		return 
	end
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend") then CloseMailbox() end
	RequestOpenMailbox()
	lastSentItems = {}
	for i,v in pairs(myList) do
		QueueItemAttachment(bagId, v, i)
		lastSentItems[v] = GetItemLink(bagId, v)
	end

	d(table.concat(textList, ","))
	local myText = os.date()
	
	EVENT_MANAGER:RegisterForEvent(CCMG.name.."SendFail", EVENT_MAIL_SEND_FAILED, CCMG.OnSendFail)
	EVENT_MANAGER:RegisterForEvent(CCMG.name.."SendSuccess", EVENT_MAIL_SEND_SUCCESS, CCMG.OnSendSuccess)
	SendMail(recipient, ccmgSubject, myText)
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend")  then CloseMailbox() end
	
end


function CCMG.OnAddonLoaded(event, addonName)
	if addonName == CCMG.name then
		CCMG:Initialize()
	end
end



function CCMG.bindLootedItems()
	d(GS(CCMG_BindingItems))
	local boundSetItems = {}
	local bindIt = {}
	for i, v in pairs(bindList) do
		local mySetPiece, setId = itemSetParam(v)
		boundSetItems[setId] = boundSetItems[setId] or {}
		if boundSetItems[setId][mySetPiece] then
			bindList[i] = nil
		else
			bindIt[v] = true
			boundSetItems[setId][mySetPiece] = true
		end
	end
	local bagItems = GetBagSize(BAG_BACKPACK)
	local bagId = BAG_BACKPACK
	for slotId=0, bagItems do
		local myLink = ""
		myLink = GetItemLink(bagId, slotId)
		if not IsItemPlayerLocked(bagId, slotId) and not IsItemLinkStolen(myLink) and not isProtectedAgainstMail and CanQueueItemAttachment(bagId, slotId) then
			if bindIt[myLink] then
				BindItem(bagId, slotId)
				CCMG.sV.counter2 = CCMG.sV.counter2 + 1
				d(" - "..myLink)
				bindIt[myLink] = false
			end
		end	
	end
end

local function nothingMoreToLoot()
	if tryToReadNext() then return end
	if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r nothing more to loot, nothing more to read") end
	local lootedMailList = {}
	for i, v in pairs(lootedMails) do
		table.insert(lootedMailList, string.format("|H0:character:%s|h%s|h (%sx)", i, UndecorateDisplayName(i), v))
	end
	lootedMailList = table.concat(lootedMailList, ", ")
	lootedMails = {}
	d(string.format(GS(CCMG_FinishedLooting), lootedMailList))
	mailInProgress = false
	if #bindList > 0 then 
		EVENT_MANAGER:RegisterForUpdate("CCMG_BIND_LOOTED_ITEMS", 250,
			function()
				EVENT_MANAGER:UnregisterForUpdate("CCMG_BIND_LOOTED_ITEMS")
				CCMG.bindLootedItems()
			end)
		--zo_callLater(CCMG.bindLootedItems(), 250) end
	end
	EVENT_MANAGER:UnregisterForEvent(CCMG.name.."OnAttachement", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS) 
	EVENT_MANAGER:UnregisterForEvent(CCMG.name.."OnReadable", EVENT_MAIL_READABLE)
	return true
end

function CCMG.attachmentTaken(_, mailId)
	if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r attachment taken") end
	if #mailsToLoot == 0 and nothingMoreToLoot() then return end-- Just in case. Actual if statement at the end of this function.
	local thisMail = false
	for i, v in pairs(mailsToLoot) do
		if v == mailId then
			thisMail = true
			table.remove(mailsToLoot, i)
			break
		end
	end
	if not thisMail then if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r attachments from mail not in list") end return end
	local senderDisplayName, _, subject, _, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount = GetMailItemInfo(mailId)
	if subject == ccmgSubject and numAttachments == 0 and attachedMoney == 0 then
		DeleteMail(mailId, true)
	end
	if #mailsToLoot == 0 and nothingMoreToLoot() then return end
end

function CCMG.readMail(_, mailId)
	if #mailsToRead == 0 then  -- just in case
		EVENT_MANAGER:UnregisterForEvent(CCMG.name.."OnReadable", EVENT_MAIL_READABLE)
		mailInProgress = false
		return 
	end
	local thisMail = false
	for i, v in pairs( mailsToRead) do
		if v == mailId then
			table.remove(mailsToRead, i)
			thisMail = true
			break
		end
	end
	if not thisMail then if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r mail ready to read but not in list") end return end
	local senderDisplayName, _, subject, _, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount = GetMailItemInfo(mailId)
	lootedMails[senderDisplayName] = lootedMails[senderDisplayName] or 0
	lootedMails[senderDisplayName] = lootedMails[senderDisplayName] + 1
	for i=1, numAttachments do 
		local myLink = GetAttachedItemLink(mailId, i)
		if IsItemLinkSetCollectionPiece(myLink) then
			if not IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(myLink)) then
				table.insert(bindList, myLink)
			elseif CCMG.sV.sentItems[myLink] then
				d(GS(CCMG_Ignore)..myLink)
				local mySetPiece, setId = itemSetParam(myLink)
				if setId then
					CCMG.sV.ignoredItems[setId] = CCMG.sV.ignoredItems[setId] or {}
					CCMG.sV.ignoredItems[setId][mySetPiece] = true
				end
			end
		end
	end
	if CCMG.sV.autoLoot then
		if GetNumBagFreeSlots(BAG_BACKPACK) < sumAttachments + numAttachments then
			local lootedMailList = {}
			
			for i, v in pairs(lootedMails) do
				table.insert(lootedMailList, string.format("%s (%sx)", i, v))
			end
			lootedMailList = table.concat(lootedMailList, ", ")
			lootedMails = {}
			d(GS(CCMG_InventoryFull))
			mailInProgress = false
			if #bindList > 0 then CCMG.bindLootedItems() end
			EVENT_MANAGER:UnregisterForEvent(CCMG.name.."OnAttachement", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS) 
			EVENT_MANAGER:UnregisterForEvent(CCMG.name.."OnReadable", EVENT_MAIL_READABLE)
		else
			EVENT_MANAGER:RegisterForEvent(CCMG.name.."OnAttachement", EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, CCMG.attachmentTaken) 
			sumAttachments = sumAttachments + numAttachments
			table.insert(mailsToLoot, mailId)
			ZO_MailInboxShared_TakeAll(mailId)
		end
	end
	
	if #mailsToRead == 0 then 
		EVENT_MANAGER:UnregisterForEvent(CCMG.name.."OnReadable", EVENT_MAIL_READABLE)
	end
end

function CCMG.OnInboxUpdate(force)
	if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r inboxUpdate") end 
	if force == "force" then 
		if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r inboxUpdate forced") end 
		mailInProgress = false 
	else
		if not CCMG.sV.autoRead then return end
		if GetCurrentZoneDungeonDifficulty() ~= 0 and CCMG.sV.pauseInDungeons then 
			if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r in dungeon/trial") end 
			return 
		end
		if mailInProgress then if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r mail in progress") end  return end
	end
	if IsUnitInCombat("player") then if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r in combat") end return end
	mailInProgress = true
	bindList = {}
	mailsToLoot = {}
	mailsToRead = {}
	lootedMails = {}
	sumAttachments = 0
	--IsReadMailInfoReady
	local mailId = GetNextMailId()
	while mailId do
		local _, _, subject, _, _, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount = GetMailItemInfo(mailId)
		-- string senderDisplayName, string senderCharacterName, string subject, textureName icon, boolean unread, boolean fromSystem, boolean fromCustomerService, boolean returned, number numAttachments, number attachedMoney, number codAmount, number expiresInDays, number secsSinceReceived 
		-- "or returned" in the next line ?
		if subject == ccmgSubject and not (fromSystem or fromCustomerService or numAttachments < 1 or attachedMoney > 0 or codAmount > 0 or returned) then
			table.insert(mailsToRead, mailId)
		end
		mailId = GetNextMailId(mailId)
	end
	if #mailsToRead > 0 then 
		EVENT_MANAGER:RegisterForEvent(CCMG.name.."OnReadable", EVENT_MAIL_READABLE, CCMG.readMail)
		tryToReadNext(true)
	else
		if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r nothing to read ") end 
		mailInProgress = false
	end
end

local function CCMGInboxListener(value)
	CCMG.sV.autoRead = value
	if value then
		if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r registered for mailbox ") end 
		EVENT_MANAGER:RegisterForEvent(CCMG.name.."OnInboxUpdate", EVENT_MAIL_INBOX_UPDATE, CCMG.OnInboxUpdate)
	else
		if ccmgdebug then d("|c9e0911[CCMG-DEBUG]|r unregistered for mailbox-event! ") end  
		EVENT_MANAGER:UnregisterForEvent(CCMG.name.."OnInboxUpdate", EVENT_MAIL_INBOX_UPDATE)
	end
end

function CCMG.OnActivated()
	CCMGInboxListener(CCMG.sV.autoRead)
	EVENT_MANAGER:UnregisterForEvent(CCMG.name.."OnActivated", EVENT_PLAYER_ACTIVATED)
end

local function sendDirectly(playerName, ignoreGroup, ignoreNoLMAS)
	if playerName == CCMG.sV.recipient and not ignoreGroup then
		ccmgYesNoFunctionDiag(GS(CCMG_SendDirectly), string.format(GS(CCMG_SendDirectlyIsRecipient), playerName), sendDirectly, {playerName, true})
		return
	end
	
	
	if not ignoreNoLMAS and (not LibMultiAccountSets or not LibMultiAccountSets.GetLastScanTime(playerName) or LibMultiAccountSets.GetLastScanTime(playerName) == 0) then 
		ccmgYesNoFunctionDiag(GS(CCMG_SendDirectly), zo_strformat(GS(CCMG_SendDirectlyNoLMAS), playerName), sendDirectly, {playerName, ignoreGroup, true})
		return
	end
	d(playerName)
	
	recipient = playerName
	CCMG.sendItems("useLMAS")
end

function CCMG:Initialize()
	local serverName = GetWorldName()
	CCMG.sV = ZO_SavedVars:NewAccountWide("CCMGSavedVariables", 1, nil, {}, serverName) -- account wide
	CCMG.sV.sentItems = CCMG.sV.sentItems or {}
	CCMG.sV.ignoredItems = CCMG.sV.ignoredItems or {}
	CCMG.sV.accountSentItems = CCMG.sV.accountSentItems or {}
	CCMG.sV.counter1 = CCMG.sV.counter1 or 0
	CCMG.sV.counter2 = CCMG.sV.counter2 or 0
	CCMG.sV.counterStart = CCMG.sV.counterStart or os.time()
	CCMG.sV.theChar = CCMG.sV.theChar or 0	
	if LibCustomMenu then
		LibCustomMenu:RegisterPlayerContextMenu(function(playerName) 
			if CCMG.sV.contextMenu then
				AddCustomSubMenuItem("CCMG", {
					{ label = GS(CCMG_ContextSet), callback = function() CCMG.sV.recipient = playerName d(string.format(GS(CCMG_NewRecipient), playerName, UndecorateDisplayName(playerName))) end },
					{ label = GS(CCMG_ContextSetSend), callback = function() sendDirectly(playerName) end},	
				})
			end
		end, LibCustomMenu.CATEGORY_LATE)
		LibCustomMenu:RegisterGuildRosterContextMenu(function(rowData) 
			if CCMG.sV.contextMenuGuild then
				AddCustomSubMenuItem("CCMG", {
					{ label = GS(CCMG_ContextSet), callback = function() CCMG.sV.recipient = rowData.displayName d(string.format(GS(CCMG_NewRecipient), rowData.displayName, UndecorateDisplayName(rowData.displayName))) end },
					{ label = GS(CCMG_ContextSetSend), callback = function() sendDirectly(rowData.displayName) end},	
				})
			end
		end, LibCustomMenu.CATEGORY_LATE)
	end
	local charList = {GS(CCMG_AllChars)}
	local idList = {0}
	local allMyChars = {}
	for i=1, GetNumCharacters() do
		local theName, _, _, _, _, _, charId = GetCharacterInfo(i)
		theName = zo_strformat("<<C:1>>", theName)
		table.insert(charList, theName)
		table.insert(idList, charId)
		allMyChars[charId] = theName
	end
	

	
	
	local panelData = {
		type = "panel",
		name = "|c9e0911Caro|r's Collection Mail Group",
		author = "|c1d6dadIrniben|r",
		registerForRefresh = true,
    }
	local optionsData = {
		{
			type = "editbox",
			name = GS(CCMG_Recipient),
			width = "full",
			isMultiline = false,
			isExtraWide = true,
			default = 0,
			getFunc = function() return CCMG.sV.recipient end,
			setFunc = function(value) CCMG.sV.recipient = value end,
		},
		{
			type = "checkbox",
			name = GS(CCMG_SendAll),
			width = "full",
			default = 0,
			getFunc = function() return CCMG.sV.sendAll or false end,
			setFunc = function(value) CCMG.sV.sendAll = value end,
		},
		{
			type = "header",
			name = GS(CCMG_InboxHandler),
			width = "full",
		},
		{
			type = "checkbox",
			name = GS(CCMG_AutoRead),
			width = "full",
			default = 0,
			getFunc = function() return CCMG.sV.autoRead or false end,
			setFunc = CCMGInboxListener,
		},
		{
			type = "checkbox",
			name = GS(CCMG_AutoLoot),
			width = "full",
			default = 0,
			getFunc = function() return CCMG.sV.autoLoot or false end,
			setFunc = function(value) CCMG.sV.autoLoot = value  end,
			disabled = function() return not (CCMG.sV.autoRead or false) end,
		},
		{
			type = "dropdown",
			name = GS(CCMG_OnlyOnChar),
			width = "full",
			choices = charList,
			choicesValues = idList,
			sort = "name-up",
			default = false,
			getFunc = function() return CCMG.sV.theChar end,
			setFunc = function(value) CCMG.sV.theChar = value end,
			disabled = function() return not (CCMG.sV.autoRead or false) end,
		},
		{
			type = "checkbox",
			name = GS(CCMG_PauseInDungeons),
			width = "full",
			default = 0,
			getFunc = function() return CCMG.sV.pauseInDungeons or false end,
			setFunc = function(value) CCMG.sV.pauseInDungeons = value  end,
			disabled = function() return not (CCMG.sV.autoRead or false) end,
		},
		{
			type = "divider",
			width = "full",
		},
		{
			type = "button",
			name = GS(CCMG_Reset),
			tooltip = GS(CCMG_Reset_Tooltip),
			width = "full",
			default = 0,
			func = function() 
				ccmgYesNoFunctionDiag(GS(CCMG_Reset), GS(CCMG_DiagReset), 
					function() 
						CCMG.sV.sentItems = {} 
						CCMG.sV.ignoredItems = {}
						d(GS(CCMG_Resetted)) 
					end)
				ccmgYesNoFunctionDiag(GS(CCMG_Reset), GS(CCMG_DiagReset2), 
					function() 
						CCMG.sV.accountSentItems = {} 
						d(GS(CCMG_Resetted)) 
					end)
			end,
		},
    }
	if LibCustomMenu then
		table.insert(optionsData, 8, 
		{
			type = "checkbox",
			name = GS(CCMG_Context),
			width = "full",
			default = 0,
			getFunc = function() return CCMG.sV.contextMenu or false end,
			setFunc = function(value) CCMG.sV.contextMenu = value  end,
		})
		table.insert(optionsData, 9,
		{
			type = "checkbox",
			name = GS(CCMG_ContextGuild),
			width = "full",
			default = 0,
			getFunc = function() return CCMG.sV.contextMenuGuild or false end,
			setFunc = function(value) CCMG.sV.contextMenuGuild = value  end,
		})
		
	end
	
	local LAM = LibAddonMenu2
    LAM:RegisterAddonPanel("CCMGOptions", panelData)
	LAM:RegisterOptionControls("CCMGOptions", optionsData)
	
	if CCMG.sV.theChar and (CCMG.sV.theChar == 0 or  GetCurrentCharacterId() == CCMG.sV.theChar) then
		EVENT_MANAGER:RegisterForEvent(CCMG.name.."OnActivated", EVENT_PLAYER_ACTIVATED, CCMG.OnActivated)
	end
	
	EVENT_MANAGER:UnregisterForEvent(CCMG.name.."OnLoad", EVENT_ADD_ON_LOADED)
end

function CCMG.showLists(arg)
	arg = tonumber(arg)
	if not arg or arg == 1 then 
		local auxList = {}
		d(GS(CCMG_SentItems))
		for i, v in pairs(CCMG.sV.sentItems) do
			table.insert(auxList, i)
			if #auxList == 14 then
				d(table.concat(auxList, ", "))
				auxList = {}
			end
		end
		if #auxList > 0 then
			d(table.concat(auxList, ", "))
		end
	end
	if not arg or arg == 2 then 
		local setItemNames = {
			[EQUIP_TYPE_CHEST] = zo_strformat("<<C:1>>", GS(SI_ITEMSTYLECHAPTER5)),
			[EQUIP_TYPE_FEET] = zo_strformat("<<C:1>>", GS(SI_ITEMSTYLECHAPTER3)),
			[EQUIP_TYPE_HAND] = zo_strformat("<<C:1>>", GS(SI_ITEMSTYLECHAPTER2)),
			[EQUIP_TYPE_HEAD] = zo_strformat("<<C:1>>", GS(SI_ITEMSTYLECHAPTER1)),
			[EQUIP_TYPE_LEGS] = zo_strformat("<<C:1>>", GS(SI_ITEMSTYLECHAPTER4)),
			[EQUIP_TYPE_NECK] = zo_strformat("<<C:1>>", GS(SI_GAMEPADITEMCATEGORY1)),
			[EQUIP_TYPE_RING] = zo_strformat("<<C:1>>", GS(SI_EQUIPTYPE12)),
			[EQUIP_TYPE_SHOULDERS] = zo_strformat("<<C:1>>", GS(SI_ITEMSTYLECHAPTER7)),
			[EQUIP_TYPE_WAIST] = zo_strformat("<<C:1>>", GS(SI_ITEMSTYLECHAPTER6)),
			[WEAPONTYPE_AXE + 42] = zo_strformat("<<C:1>> (<<c:2>>)", GS(SI_WEAPONTYPE1), GS(SI_EQUIPTYPE5)),
			[WEAPONTYPE_BOW + 42] = zo_strformat("<<C:1>>", GS(SI_WEAPONTYPE8)),
			[WEAPONTYPE_DAGGER + 42] = zo_strformat("<<C:1>>", GS(SI_WEAPONTYPE11)),
			[WEAPONTYPE_FIRE_STAFF + 42] = zo_strformat("<<C:1>>", GS(SI_WEAPONTYPE12)),
			[WEAPONTYPE_FROST_STAFF + 42] = zo_strformat("<<C:1>>", GS(SI_WEAPONTYPE13)),
			[WEAPONTYPE_HAMMER + 42] = zo_strformat("<<C:1>> (<<c:2>>)", GS(SI_WEAPONTYPE2), GS(SI_EQUIPTYPE5)),
			[WEAPONTYPE_HEALING_STAFF + 42] = zo_strformat("<<C:1>>", GS(SI_WEAPONTYPE9)),
			[WEAPONTYPE_LIGHTNING_STAFF	+ 42] = zo_strformat("<<C:1>>", GS(SI_WEAPONTYPE15)),
			-- WEAPONTYPE_RUNE	10 -- SI_WEAPONTYPE10
			[WEAPONTYPE_SHIELD + 42] = zo_strformat("<<C:1>>", GS(SI_WEAPONTYPE14)),
			[WEAPONTYPE_SWORD + 42] = zo_strformat("<<C:1>> (<<c:2>>)", GS(SI_WEAPONTYPE3), GS(SI_EQUIPTYPE5)),
			[WEAPONTYPE_TWO_HANDED_AXE + 42] = zo_strformat("<<C:1>> (<<c:2>>)", GS(SI_WEAPONTYPE1), GS(SI_EQUIPTYPE6)),
			[WEAPONTYPE_TWO_HANDED_HAMMER + 42] = zo_strformat("<<C:1>> (<<c:2>>)", GS(SI_WEAPONTYPE2), GS(SI_EQUIPTYPE6)),
			[WEAPONTYPE_TWO_HANDED_SWORD + 42] = zo_strformat("<<C:1>> (<<c:2>>)", GS(SI_WEAPONTYPE3), GS(SI_EQUIPTYPE6)),
		}

		local auxList = {}
		for i, v in pairs(CCMG.sV.ignoredItems) do
			for j, w in pairs(v) do
				table.insert(auxList, zo_strformat("<<C:1>>-<<2>>", GetItemSetName(i), setItemNames[j]))
			end
		end
		d(GS(CCMG_IgnoredItems)..table.concat(auxList, ",")) 
	end
end

function CCMG.lootItems()
	CCMG.OnInboxUpdate("force")
end

function CCMG.debug()
	-- ccmgdebug = not ccmgdebug
	if ccmgdebug then
		d("|c9e0911[CCMG-DEBUG]|r debugging is on") 
		if mailInProgress then d("|c9e0911[CCMG-DEBUG]|r mail in progress")  end
	else
		if mailInProgress then d("|c9e0911[CCMG-DEBUG]|r mail in progress")  end
		d("|c9e0911[CCMG-DEBUG]|r debugging is off") 
	end
end

SLASH_COMMANDS["/ccmg"] = CCMG.sendItems
SLASH_COMMANDS["/ccmgread"] = CCMG.lootItems
SLASH_COMMANDS["/ccmgshowlists"] = CCMG.showLists

EVENT_MANAGER:RegisterForEvent(CCMG.name.."OnLoad", EVENT_ADD_ON_LOADED, CCMG.OnAddonLoaded)