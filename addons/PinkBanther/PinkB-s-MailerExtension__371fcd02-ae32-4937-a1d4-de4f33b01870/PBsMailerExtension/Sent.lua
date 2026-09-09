-- PB's MailerExtension -- the sent box
--
-- ---------------------------------------------------------------------------------------
-- WHY THIS IS A COPY MADE BEFOREHAND AND NOT A LOOKUP
-- ---------------------------------------------------------------------------------------
--
-- There is no such thing as a sent mail in the API. Every mail read the client offers --
-- GetMailIdByIndex, GetMailItemInfo, ReadMail, GetAttachedItemInfo -- reads the inbox, and
-- there is no MailCategory for something you sent, because the server does not keep one.
--
-- So a sent box can only be a copy this add-on made itself, and the only moment worth copying
-- is before the letter goes. EVENT_MAIL_SEND_SUCCESS is too late: the client's own handler
-- for that event clears the page (MailSend:OnMailSendSuccess -> ClearFields, and the gamepad
-- one -> Clear), and the client registered its handler when the UI loaded, which is before
-- any add-on exists. By the time we are called there is nothing left to read.
--
-- Hooking the send is not an option either, and not only because of FINDINGS §7: wrapping
-- MailSend:Send would leave our frame on the callstack while the client called SendMail, and
-- if SendMail turns out to be restricted that breaks sending itself. Nothing in this add-on
-- is worth that.
--
-- So: while the Send page is open, the add-on keeps a copy of what is on it, refreshed a few
-- times a second. When the client says the letter went, that copy -- the last one that had
-- anything on it -- becomes the record, with the addressee taken from the event rather than
-- from the copy, because the event's name is the one the server accepted.
--
-- The copy is a read of values the client already holds -- three edit boxes and the queued
-- attachment slots. It asks the server for nothing, it runs only while the page is open, and
-- it stops the moment the page closes.
-- ---------------------------------------------------------------------------------------
--
-- PBS_MAILER_EXTENSION is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_MAILER_EXTENSION then
	return
end

local addon = PBS_MAILER_EXTENSION
local compose = addon.compose

local em = EVENT_MANAGER

local sent = addon.NewBox({
	key = "sent",
	defaultMax = addon.DEFAULT_MAX_SENT,
	rolling = true,
	nounId = SI_PBSMX_NOUN_SENT,
	titleId = SI_PBSMX_TAB_SENT,
})

addon.sent = sent

-- Ten times a second. Fast enough that the copy is what was on the page when Send was pressed
-- -- on a controller you must leave the edit box before you can reach Send at all, so the text
-- has been settled for several frames by then -- and cheap enough not to matter: it is three
-- GetText calls and a walk of six attachment slots, all of them values already in memory.
local POLL_MS = 100
local WATCH_NAME = "PBsMailerExtensionOutgoing"

function sent:Watch()
	if not compose:IsOpen() then
		return
	end

	local page = compose:Read()
	-- The last copy that had anything on it, not simply the last copy. The client blanks the
	-- page as part of sending, and a blank copy would overwrite the one we are about to need.
	if page and not self:IsBlank(page) then
		self.outgoing = page
	end
end

function sent:StartWatching()
	if self.watching then
		return
	end
	self.watching = true
	em:RegisterForUpdate(WATCH_NAME, POLL_MS, function()
		self:Watch()
	end)
	-- One immediately, so a page that is opened and sent from without changing anything --
	-- a draft put back and sent -- is still recorded.
	self:Watch()
end

function sent:StopWatching()
	if not self.watching then
		return
	end
	self.watching = false
	em:UnregisterForUpdate(WATCH_NAME)
end

-- ---------------------------------------------------------------------------------------
-- Recording
-- ---------------------------------------------------------------------------------------

function sent:Record(recipient)
	local page = self.outgoing
	self.outgoing = nil

	if not page then
		return nil
	end

	-- The event's name over ours: it is the one the server accepted, and it is already in the
	-- form the address field would have been turned into.
	if recipient and recipient ~= "" then
		page.to = recipient
	end

	-- What was attached is gone from the backpack now, so what is kept is a description of it
	-- rather than a way back to it. The slot and the stack id are dropped for that reason:
	-- keeping them would let a later "put this back on the page" grab whatever unrelated item
	-- has since moved into that slot. The link stays, so the same KIND of item can be found.
	for _, item in ipairs(page.attachments or {}) do
		item.bagId = nil
		item.slotIndex = nil
		item.itemInstanceId = nil
	end

	local entry = self:Add(page)
	return entry
end

function sent:Initialize()
	em:RegisterForEvent(addon.name .. "Sent", EVENT_MAIL_SEND_SUCCESS, function(_, recipient)
		self:Record(recipient)
	end)

	return true
end
