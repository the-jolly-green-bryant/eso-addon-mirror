-- PB's MailerExtension -- the page you write on
--
-- This is the only file that knows there are two mail interfaces. Everything above it asks
-- for "what is on the page" and "put this on the page"; whether that page is
-- ZO_MailSendToField or a ZO_MailView_Gamepad control is settled here and nowhere else.
--
-- The two are genuinely different objects -- different files, different classes, no shared
-- base -- but only for the text:
--
--   keyboard   MAIL_SEND.to / .subject / .body          edit controls, GetText / SetText
--   gamepad    MAIL_GAMEPAD:GetSend().mailView          ZO_MailView_*_Gamepad(control, ...)
--
-- The attachments, the gold and the C.O.D. are NOT per-interface. They are one queue held by
-- the client -- GetQueuedItemAttachmentInfo, GetQueuedMoneyAttachment, GetQueuedCOD -- and
-- both interfaces are drawing the same numbers. So all of that is written once, below the
-- split, and it is the reason a draft saved in one interface restores in the other.
--
-- PBS_MAILER_EXTENSION is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_MAILER_EXTENSION then
	return
end

local addon = PBS_MAILER_EXTENSION
local compose = addon.compose

local Format = addon.Format

compose.KEYBOARD = "keyboard"
compose.GAMEPAD = "gamepad"

-- ---------------------------------------------------------------------------------------
-- Which page, if any, is open
--
-- Asked before every read and every write, never cached: the answer changes with a tab.
--
-- The keyboard test is the client's own (inventoryslot.lua asks MAIL_SEND:IsHidden() to
-- decide whether "Attach to mail" belongs in a right-click menu). The gamepad test is not:
-- the client asks GetSend():IsAttachingItems() there, which is true only while the inventory
-- side is up, and we want the whole Send tab.
-- ---------------------------------------------------------------------------------------

-- The gamepad mail view, or nil. GetSend() is the client's accessor; the field is read
-- directly as a fallback because an accessor is a smaller promise than a field.
local function GamepadView()
	if not MAIL_GAMEPAD then
		return nil
	end
	local send = MAIL_GAMEPAD.GetSend and MAIL_GAMEPAD:GetSend() or MAIL_GAMEPAD.send
	return send and send.mailView or nil
end

function compose:Mode()
	if MAIL_SEND and MAIL_SEND.IsHidden and not MAIL_SEND:IsHidden() then
		return self.KEYBOARD
	end

	if MAIL_GAMEPAD and GAMEPAD_MAIL_SEND_FRAGMENT and SCENE_FRAGMENT_SHOWN then
		if GAMEPAD_MAIL_SEND_FRAGMENT:GetState() == SCENE_FRAGMENT_SHOWN then
			return self.GAMEPAD
		end
	end

	return nil
end

function compose:IsOpen()
	return self:Mode() ~= nil
end

-- ---------------------------------------------------------------------------------------
-- Which page to WRITE to, which is not the same question as which one is open
--
-- The compose controls exist from the moment the mail window has been opened once, whether or
-- not the Send page is the tab being looked at, and so does the queue of attachments -- it is
-- one queue in the client, not a thing the screen owns. So a letter can be put on the page
-- while somebody is standing on the drafts tab, and it is still there when they walk over to
-- the Send tab.
--
-- That is not a convenience. It is the whole reason this add-on no longer switches tabs by
-- itself -- see FINDINGS §9. Writing here and letting the player make the tab change means the
-- client rebuilds its own screen from its own frame, with nothing of ours underneath it.
-- ---------------------------------------------------------------------------------------

function compose:Surface()
	local open = self:Mode()
	if open then
		return open
	end

	local gamepadPreferred = IsInGamepadPreferredMode and IsInGamepadPreferredMode()
	if gamepadPreferred and GamepadView() then
		return self.GAMEPAD
	end
	if MAIL_SEND and MAIL_SEND.to then
		return self.KEYBOARD
	end
	if GamepadView() then
		return self.GAMEPAD
	end
	return nil
end

function compose:CanWrite()
	return self:Surface() ~= nil
end

function compose:Describe()
	local mode = self:Mode()
	if mode == self.KEYBOARD then
		return GetString(SI_PBSMX_WHERE_KEYBOARD)
	elseif mode == self.GAMEPAD then
		return GetString(SI_PBSMX_WHERE_GAMEPAD)
	end
	return GetString(SI_PBSMX_WHERE_CLOSED)
end

-- ---------------------------------------------------------------------------------------
-- The text
-- ---------------------------------------------------------------------------------------

function compose:ReadText()
	local mode = self:Mode()

	if mode == self.KEYBOARD then
		return MAIL_SEND.to:GetText() or "", MAIL_SEND.subject:GetText() or "", MAIL_SEND.body:GetText() or ""
	end

	if mode == self.GAMEPAD then
		local view = GamepadView()
		if view then
			return ZO_MailView_GetAddress_Gamepad(view) or "",
				ZO_MailView_GetSubject_Gamepad(view) or "",
				ZO_MailView_GetBody_Gamepad(view) or ""
		end
	end

	return nil
end

function compose:WriteText(to, subject, body)
	local mode = self:Surface()

	if mode == self.KEYBOARD then
		MAIL_SEND.to:SetText(to or "")
		MAIL_SEND.subject:SetText(subject or "")
		MAIL_SEND.body:SetText(body or "")
		return true
	end

	if mode == self.GAMEPAD then
		local view = GamepadView()
		if view then
			-- nil for the two money arguments on purpose: passing numbers there redraws the
			-- gold/C.O.D. block from them, and the real numbers arrive a moment later from
			-- the queue events our own money calls fire.
			ZO_MailView_Display_Gamepad(view, nil, nil, to or "", subject or "", body or "")
			return true
		end
	end

	return false
end

-- ---------------------------------------------------------------------------------------
-- The attachments
--
-- What is stored about an attached item is what is needed to find it again, in the order it
-- is tried:
--
--   bagId + slotIndex   where it was. Right almost always, and free.
--   itemInstanceId      this exact stack, wherever it has moved to in the backpack. This is
--                       the client's own test in ZO_MailSend_Shared.RestorePendingMail.
--   link                the last resort: the same KIND of item. A draft written a week ago
--                       is far more likely to mean "the alchemy reagents" than "that stack".
--
-- Only BAG_BACKPACK is searched, because only the backpack can be attached to a mail.
-- ---------------------------------------------------------------------------------------

local function AttachmentSlots()
	return MAIL_MAX_ATTACHED_ITEMS or 6
end

-- What to call an item in a line the player reads. GetItemLinkName gives the raw name, which
-- in several languages still carries the client's grammar markup ("^n" and friends);
-- zo_strformat(SI_TOOLTIP_ITEM_NAME, ...) is what the client itself puts through, so that is
-- tried first and the plainer calls are the fallback.
local function ItemName(link, bagId, slotIndex)
	if link and link ~= "" then
		if zo_strformat and SI_TOOLTIP_ITEM_NAME then
			local ok, name = pcall(zo_strformat, SI_TOOLTIP_ITEM_NAME, link)
			if ok and name and name ~= "" then
				return name
			end
		end
		if GetItemLinkName then
			local name = GetItemLinkName(link)
			if name and name ~= "" then
				return name
			end
		end
	end
	if bagId and GetItemName then
		return GetItemName(bagId, slotIndex) or ""
	end
	return ""
end

function compose:ReadAttachments()
	local list = {}
	for slot = 1, AttachmentSlots() do
		local bagId, slotIndex, _, stack = GetQueuedItemAttachmentInfo(slot)
		if bagId and bagId ~= 0 and stack and stack > 0 then
			local link = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
			list[#list + 1] = {
				bagId = bagId,
				slotIndex = slotIndex,
				itemInstanceId = GetItemInstanceId(bagId, slotIndex),
				stack = stack,
				link = link,
				name = ItemName(link, bagId, slotIndex),
			}
		end
	end
	return list
end

-- Whether a slot still holds what the draft was written about. "Same stack" is instance id;
-- "same kind" is the link. The stack SIZE is deliberately not part of either test -- a stack
-- that grew from 40 to 60 reagents is still the reagents the draft meant.
local function SlotMatches(entry, bagId, slotIndex, byKind)
	if byKind then
		return entry.link and entry.link ~= "" and GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT) == entry.link
	end
	return entry.itemInstanceId ~= nil and GetItemInstanceId(bagId, slotIndex) == entry.itemInstanceId
end

local function FindItem(entry, taken)
	local function free(bagId, slotIndex)
		return not taken[bagId .. ":" .. slotIndex]
	end

	if entry.bagId and entry.slotIndex and free(entry.bagId, entry.slotIndex) and SlotMatches(entry, entry.bagId, entry.slotIndex) then
		return entry.bagId, entry.slotIndex
	end

	local size = GetBagSize(BAG_BACKPACK) or 0
	for byKind = 0, 1 do
		for slotIndex = 0, size - 1 do
			if free(BAG_BACKPACK, slotIndex) and SlotMatches(entry, BAG_BACKPACK, slotIndex, byKind == 1) then
				return BAG_BACKPACK, slotIndex
			end
		end
	end

	return nil
end

-- The client's own words for why an item would not attach, rather than ours: these are the
-- same sentences the game shows when the attach is refused from the inventory.
local function AttachProblem(result, name)
	local reason
	if result == MAIL_ATTACHMENT_RESULT_ALREADY_ATTACHED then
		reason = GetString(SI_MAIL_ALREADY_ATTACHED)
	elseif result == MAIL_ATTACHMENT_RESULT_BOUND then
		reason = GetString(SI_MAIL_BOUND)
	elseif result == MAIL_ATTACHMENT_RESULT_ITEM_NOT_FOUND then
		reason = GetString(SI_MAIL_ITEM_NOT_FOUND)
	elseif result == MAIL_ATTACHMENT_RESULT_LOCKED or result == MAIL_ATTACHMENT_RESULT_PLAYER_LOCKED then
		reason = GetString(SI_MAIL_LOCKED)
	elseif result == MAIL_ATTACHMENT_RESULT_STOLEN then
		reason = GetString(SI_STOLEN_ITEM_CANNOT_MAIL_MESSAGE)
	else
		reason = tostring(result)
	end
	return Format(SI_PBSMX_NOTE_NOT_ATTACHED, name, reason)
end

-- Returns a list of notes -- one line per item that could not be put back. An empty list is
-- the good case, and the caller says nothing.
function compose:WriteAttachments(list)
	local notes = {}

	for slot = 1, AttachmentSlots() do
		RemoveQueuedItemAttachment(slot)
	end

	local taken = {}
	local nextSlot = 1

	for _, entry in ipairs(list or {}) do
		local name = entry.name
		if not name or name == "" then
			name = ItemName(entry.link)
		end
		if name == "" then
			name = GetString(SI_PBSMX_NOTE_UNNAMED_ITEM)
		end

		if nextSlot > AttachmentSlots() then
			notes[#notes + 1] = Format(SI_PBSMX_NOTE_NOT_ATTACHED, name, GetString(SI_MAIL_ATTACHMENTS_FULL))
		else
			local bagId, slotIndex = FindItem(entry, taken)
			if not bagId then
				notes[#notes + 1] = Format(SI_PBSMX_NOTE_ITEM_GONE, name)
			elseif CanQueueItemAttachment and not CanQueueItemAttachment(bagId, slotIndex, nextSlot) then
				notes[#notes + 1] = Format(SI_PBSMX_NOTE_ITEM_GONE, name)
			else
				local result = QueueItemAttachment(bagId, slotIndex, nextSlot)
				if result == MAIL_ATTACHMENT_RESULT_SUCCESS then
					taken[bagId .. ":" .. slotIndex] = true
					nextSlot = nextSlot + 1
				else
					notes[#notes + 1] = AttachProblem(result, name)
				end
			end
		end
	end

	return notes
end

-- ---------------------------------------------------------------------------------------
-- The money
--
-- Gold and C.O.D. are one field on screen with a radio button deciding which of the two it
-- means, and that radio button is interface-specific state we would have to reach into to
-- change honestly. So: gold is restored, and a C.O.D. is reported instead of being set.
--
-- That is a deliberate refusal, not an omission. Putting a number into the queue while the
-- page still says "attach gold" would show the wrong word next to somebody's money on the
-- screen where they press Send. A C.O.D. is rare, it is one number, and being told to type
-- it back in is a far smaller cost than being shown it in the wrong place.
-- ---------------------------------------------------------------------------------------

function compose:ReadMoney()
	return GetQueuedMoneyAttachment() or 0, GetQueuedCOD() or 0
end

function compose:WriteMoney(gold, cod)
	local notes = {}
	local currentCod = GetQueuedCOD() or 0

	if (cod or 0) > 0 then
		notes[#notes + 1] = Format(SI_PBSMX_NOTE_COD, cod)
	end

	if currentCod == 0 then
		QueueMoneyAttachment(gold or 0)
	elseif (gold or 0) > 0 then
		notes[#notes + 1] = Format(SI_PBSMX_NOTE_GOLD_NOT_SET, gold)
	end

	return notes
end

-- ---------------------------------------------------------------------------------------
-- The whole page
-- ---------------------------------------------------------------------------------------

function compose:Read()
	local to, subject, body = self:ReadText()
	if not to then
		return nil, GetString(SI_PBSMX_ERROR_NOT_OPEN)
	end

	local gold, cod = self:ReadMoney()

	return {
		to = to,
		subject = subject,
		body = body,
		gold = gold,
		cod = cod,
		attachments = self:ReadAttachments(),
	}
end

function compose:Write(draft)
	if not self:WriteText(draft.to, draft.subject, draft.body) then
		return false, GetString(SI_PBSMX_ERROR_NOT_OPEN)
	end

	local notes = self:WriteAttachments(draft.attachments)
	for _, note in ipairs(self:WriteMoney(draft.gold, draft.cod)) do
		notes[#notes + 1] = note
	end

	return true, notes
end
