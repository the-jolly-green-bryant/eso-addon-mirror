OgersMailIntricates = {
	name = "OgersMailIntricates",
}

local GS = GetString
local craftFilter = 0
local glyphFilter = 0
local recipient = ""
local lastSentItems = {}
local OgersMailIntricatesSubject = "Oger's Mail Intricates"

function OgersMailIntricates.OnMailFail(_, result)
	if SendMailResult == 424242 then
		d(GS(OgersMailSpecialFail))
		else
		d(GS(OgersMailIntricates_MailFail)..GS("SI_SENDMAILRESULT", result))
	end
	EVENT_MANAGER:UnregisterForEvent(OgersMailIntricates.name.."SendFail", EVENT_MAIL_SEND_FAILED)
	EVENT_MANAGER:UnregisterForEvent(OgersMailIntricates.name.."SendSuccess", EVENT_MAIL_SEND_SUCCESS)
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend")  then CloseMailbox() end
end

function OgersMailIntricates.OnMailSuccess()
	for i, v in pairs( lastSentItems) do
		if GetItemLink(BAG_BACKPACK, i) == v then 
			OgersMailIntricates.OnMailFail(1, 424242)
			return
		end
	end
	EVENT_MANAGER:UnregisterForEvent(OgersMailIntricates.name.."SendFail", EVENT_MAIL_SEND_FAILED)
	EVENT_MANAGER:UnregisterForEvent(OgersMailIntricates.name.."SendSuccess", EVENT_MAIL_SEND_SUCCESS)
	d(string.format(GS(OgersMailIntricates_MailSuccess), recipient, UndecorateDisplayName(recipient)))
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend")  then CloseMailbox() end
	zo_callLater(function() OgersMailIntricates.sendItems() end, 100)
end

local function checkItem(bagId, slotId)
	local myLink = ""
	myLink = GetItemLink(bagId, slotId)
	local itemType, specialItemType = GetItemLinkItemType(myLink)
	local isProtectedAgainstMail = FCOIS and FCOIS.IsMailLocked(bagId, slotId) or false
	if IsItemPlayerLocked(bagId, slotId) or IsItemLinkStolen(myLink) or isProtectedAgainstMail then return false end
	if IsItemBound(bagId, slotId) then return false end
	if craftFilter == 42 and (itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON) then
		if glyphFilter == 0 then return false end
		local itemId = GetItemLinkItemId(myLink)
		if itemId == 68343 or itemId == 68344 then return false end --Hakeijo
		if itemId == 166046 or itemId == 166047 then return false end --Indeko
		if glyphFilter >= GetItemLinkQuality(myLink) then return myLink	end
	end
	if itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_WEAPON and GetItemLinkQuality(myLink) > 2 then return false end
	local hasSet = GetItemLinkSetInfo(myLink) 
	if hasSet then return false end
	local myTrait = GetItemTrait(bagId, slotId)
	if myTrait ~= ITEM_TRAIT_TYPE_ARMOR_INTRICATE and 
		myTrait ~= ITEM_TRAIT_TYPE_JEWELRY_INTRICATE and 
			myTrait ~= ITEM_TRAIT_TYPE_WEAPON_INTRICATE then 
			return false
	end
	
	local thisType = GetRearchLineInfoFromRetraitItem(bagId, slotId)
	if craftFilter == 0 or
		craftFilter == 1 and thisType == CRAFTING_TYPE_CLOTHIER or
		craftFilter == 2 and thisType == CRAFTING_TYPE_BLACKSMITHING or
		craftFilter == 3 and thisType == CRAFTING_TYPE_WOODWORKING or
		craftFilter == 4 and thisType == CRAFTING_TYPE_JEWELRYCRAFTING then
		return myLink
	end
end
	

local function takeBankItems()
	d(GS(OgersMailIntricates_Transferring))
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
		if checkItem(BAG_BANK, slotIt) then myCount = myCount + 1 end
	end
	for slotIt=0, GetBagSize(BAG_SUBSCRIBER_BANK) do
		if checkItem(BAG_SUBSCRIBER_BANK, slotIt) then myCount = myCount + 1 end
	end
	local  function transferNext()
		for slotIt=0, GetBagSize(theBank) do
			local myLink = checkItem(theBank, slotIt)
			if myLink then
				d(string.format(GS(OgersMailIntricates_XoutofY), myPosition, myCount, myLink))
				myPosition = myPosition + 1
				if not transferItem(slotIt) then 
					d(GS(OgersMailIntricates_NotEnoughSpace)) 
				else
					local myTries = 1
					local function checkSlot(myTries)
						myTries = myTries + 1
						zo_callLater(function()
							if GetItemId(theBank, slotIt) ~= 0 then
								if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
									checkSlot(myTries) 
								else
									d(GS(OgersMailIntricates_TransferFail))
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
		-- EVENT_MANAGER:UnregisterForEvent(OgersMailIntricates.name.."InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		if theBank == BAG_BANK then theBank = BAG_SUBSCRIBER_BANK transferNext() end
	end
	transferNext()
	
end

function OgersMailIntricates.sendItems()
	if IsUnitInCombat("player") then
		d(GS(OgersMailIntricates_InCombat))
		return
	end
	if not recipient or recipient == "" then 
		d(GS(OgersMailIntricates_NoRecipient))
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
			d(zo_strformat(GS(OgersMailIntricates_BankMsg), bankCount))
		end
		return 
	end
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend") then CloseMailbox() end
	RequestOpenMailbox()
	lastSentItems = {}	
	for i,v in pairs(myList) do
		QueueItemAttachment(bagId, v, i)
		lastSentItems[v] = GetItemLink(bagId, v)
	end
	d(string.format(GS(OgersMailIntricates_Sending), recipient, UndecorateDisplayName(recipient), table.concat(textList, ",")))
	local myText = os.date()
	
	EVENT_MANAGER:RegisterForEvent(OgersMailIntricates.name.."SendFail", EVENT_MAIL_SEND_FAILED, OgersMailIntricates.OnMailFail)
	EVENT_MANAGER:RegisterForEvent(OgersMailIntricates.name.."SendSuccess", EVENT_MAIL_SEND_SUCCESS, OgersMailIntricates.OnMailSuccess)
	SendMail(recipient, OgersMailIntricatesSubject, myText)
	if not SCENE_MANAGER:IsShowing("mailInbox") and not SCENE_MANAGER:IsShowing("mailSend")  then CloseMailbox() end
	
end




function OgersMailIntricates.oaa(args)
	if GetInteractionType() == INTERACTION_BANK then takeBankItems() return end
	if not args or args == "" then 
		d(GS(OgersMailIntricates_NoArgs))
		return 
	end
	args = {SplitString(" ", args)}
	if #args == 0 then return end
	recipient = DecorateDisplayName(args[1])
	craftFilter = tonumber(args[2]) or 0
	OgersMailIntricates.sendItems()
end
	
function OgersMailIntricates.OnAddonLoaded(event, addonName)
	if addonName == OgersMailIntricates.name then
		OgersMailIntricates:Initialize()
	end
end

d(GetItemLinkQuality("|H1:item:45884:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))

function OgersMailIntricates:Initialize()
	-- OgersMailIntricates.sV = ZO_SavedVars:NewAccountWide("OgersMailIntricatesSavedVariables", 1, nil, {}, serverName) -- account wide
	if LibCustomMenu then
		local function addOAASubMenuEntry(displayName)
			local entries = {
				{
					label = GS(SI_ITEMFILTERTYPE0), -- All
					callback = function() recipient = displayName craftFilter = 0 glyphFilter = 0 ZO_GuildRosterSearchBox:LoseFocus() OgersMailIntricates.sendItems() end,
				},
				{
					label = GS(SI_ITEMFILTERTYPE14), -- Clothing
					callback = function() recipient = displayName craftFilter = 1 glyphFilter = 0 ZO_GuildRosterSearchBox:LoseFocus() OgersMailIntricates.sendItems() end,
				},
				{
					label = GS(SI_ITEMFILTERTYPE13), -- Blacksmith
					callback = function() recipient = displayName craftFilter = 2 glyphFilter = 0 ZO_GuildRosterSearchBox:LoseFocus() OgersMailIntricates.sendItems() end,
				},
				{
					label = GS(SI_ITEMFILTERTYPE15), -- Woodworking
					callback = function() recipient = displayName craftFilter = 3 glyphFilter = 0 ZO_GuildRosterSearchBox:LoseFocus() OgersMailIntricates.sendItems() end,
				},
				{
					label = GS(SI_ITEMFILTERTYPE24), -- Jewelry
					callback = function() recipient = displayName craftFilter = 4 glyphFilter = 0 ZO_GuildRosterSearchBox:LoseFocus() OgersMailIntricates.sendItems() end,
				},
				{
					label = "-",
					callback = function() end,
				},
				{
					label = string.format("%s <= %s", GS(SI_ITEMTYPEDISPLAYCATEGORY30), GS(SI_ITEMQUALITY1)), -- Glpyhs 
					callback = function() recipient = displayName craftFilter = 42 glyphFilter = 1 ZO_GuildRosterSearchBox:LoseFocus() OgersMailIntricates.sendItems() end,
				},
				{
					label = string.format("%s <= %s", GS(SI_ITEMTYPEDISPLAYCATEGORY30), GS(SI_ITEMQUALITY2)), -- Glpyhs 
					callback = function() recipient = displayName craftFilter = 42 glyphFilter = 2 ZO_GuildRosterSearchBox:LoseFocus() OgersMailIntricates.sendItems() end,
				},
				{
					label = string.format("%s <= %s", GS(SI_ITEMTYPEDISPLAYCATEGORY30), GS(SI_ITEMQUALITY3)), -- Glpyhs 
					callback = function() recipient = displayName craftFilter = 42 glyphFilter = 3 ZO_GuildRosterSearchBox:LoseFocus() OgersMailIntricates.sendItems() end,
				},
				{
					label = string.format("%s <= %s", GS(SI_ITEMTYPEDISPLAYCATEGORY30), GS(SI_ITEMQUALITY4)), -- Glpyhs 
					callback = function() recipient = displayName craftFilter = 42 glyphFilter = 4 ZO_GuildRosterSearchBox:LoseFocus() OgersMailIntricates.sendItems() end,
				},
			}
			AddCustomSubMenuItem(GS(OgersMailIntricates_MenuSend), entries)
		end
		
		LibCustomMenu:RegisterGuildRosterContextMenu(function(rowData) addOAASubMenuEntry(rowData.displayName) end, LibCustomMenu.CATEGORY_LATE)
		LibCustomMenu:RegisterPlayerContextMenu(addOAASubMenuEntry, LibCustomMenu.CATEGORY_LATE)
	end
	EVENT_MANAGER:UnregisterForEvent(OgersMailIntricates.name.."OnLoad", EVENT_ADD_ON_LOADED)
end

SLASH_COMMANDS["/omi"] = OgersMailIntricates.oaa

EVENT_MANAGER:RegisterForEvent(OgersMailIntricates.name.."OnLoad", EVENT_ADD_ON_LOADED, OgersMailIntricates.OnAddonLoaded)