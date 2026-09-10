-- PB's MailerExtension -- the kept box
--
-- ---------------------------------------------------------------------------------------
-- WHAT THIS CAN AND CANNOT SAVE
-- ---------------------------------------------------------------------------------------
--
-- Every mail in the inbox expires. GetMailItemInfo returns expiresInDays for exactly that
-- reason, and when the day comes the server deletes the mail. **Nothing an add-on can do
-- changes that.** There is no API to extend a mail, to pin one, or to stop the clock; the
-- inbox is the server's, and an add-on only ever reads it.
--
-- So this box does the one thing that is actually possible: it takes a copy of what the letter
-- SAID -- who sent it, its subject, its body, when it arrived -- and writes that into the
-- saved variables, where nothing expires. That copy survives the mail being deleted, and it is
-- readable from any character.
--
-- What it cannot copy is the things that are not text:
--
--   * ATTACHED ITEMS. They are the server's until you take them. A record of a mail is not a
--     bag, and there is nowhere for an add-on to put an item. Take the attachments before the
--     mail expires; the record notes what they were, so you know what you took.
--   * ATTACHED GOLD, for the same reason.
--
-- That is worth being blunt about, because "keep this mail for ever" sounds like it should
-- keep the parcel as well as the letter, and it cannot.
--
-- ---------------------------------------------------------------------------------------
-- WHERE THE COPY COMES FROM
-- ---------------------------------------------------------------------------------------
--
-- The mail the player is looking at, asked for by id and read straight from the client:
--
--     GetMailItemInfo(mailId)   -> sender, subject, ..., numAttachments, attachedMoney, ...
--     ReadMail(mailId)          -> body, out of the client's own cache
--     GetAttachedItemInfo/Link  -> what was attached
--
-- ReadMail only answers once the client has the body, which it asks for itself when a mail is
-- selected (RequestReadMail). IsReadMailInfoReady is how that is checked here rather than
-- assumed -- a saved letter with an empty body would be worse than a refusal to save it.
--
-- Nothing here calls anything that builds a screen. The two accessors it uses --
-- MAIL_INBOX:GetOpenMailId and ZO_MailInbox_Gamepad:GetActiveMailId -- return a value out of a
-- table each. See FINDINGS §7 and §9 for why that distinction is the whole ballgame.
-- ---------------------------------------------------------------------------------------
--
-- PBS_MAILER_EXTENSION is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_MAILER_EXTENSION then
	return
end

local addon = PBS_MAILER_EXTENSION

local Format = addon.Format

local kept = addon.NewBox({
	key = "kept",
	defaultMax = addon.DEFAULT_MAX_KEPT,
	rolling = false,
	nounId = SI_PBSMX_NOUN_KEPT,
	titleId = SI_PBSMX_TAB_KEPT,
	loadLabelId = SI_PBSMX_KEYBIND_REPLY,
})

addon.kept = kept

-- ---------------------------------------------------------------------------------------
-- Which mail is being looked at
-- ---------------------------------------------------------------------------------------

function kept:ActiveMailId()
	if MAIL_INBOX and MAIL_INBOX.GetOpenMailId then
		local mailId = MAIL_INBOX:GetOpenMailId()
		if mailId then
			return mailId, MAIL_INBOX.isMailFromGuild or false
		end
	end

	if MAIL_GAMEPAD then
		local inbox = MAIL_GAMEPAD.GetInbox and MAIL_GAMEPAD:GetInbox() or MAIL_GAMEPAD.inbox
		if inbox and inbox.GetActiveMailId then
			local mailId = inbox:GetActiveMailId()
			if mailId then
				local fromGuild = inbox.IsActiveMailFromGuild and inbox:IsActiveMailFromGuild() or false
				return mailId, fromGuild
			end
		end
	end

	return nil, false
end

-- ---------------------------------------------------------------------------------------
-- Taking the copy
-- ---------------------------------------------------------------------------------------

local function AttachmentRecord(mailId, numAttachments)
	local list = {}
	for index = 1, numAttachments or 0 do
		local link = GetAttachedItemLink and GetAttachedItemLink(mailId, index, LINK_STYLE_DEFAULT) or ""
		local _, stack = GetAttachedItemInfo(mailId, index)
		local name = ""
		if link and link ~= "" then
			if zo_strformat and SI_TOOLTIP_ITEM_NAME then
				local ok, formatted = pcall(zo_strformat, SI_TOOLTIP_ITEM_NAME, link)
				name = (ok and formatted) or ""
			end
			if name == "" and GetItemLinkName then
				name = GetItemLinkName(link) or ""
			end
		end
		list[#list + 1] = {
			link = link,
			name = name,
			stack = stack or 1,
		}
	end
	return list
end

-- Guild mail ids and ordinary mail ids come out of different systems, so the key says which
-- one it is. Two unrelated letters sharing a number would otherwise look like the same letter.
local function MailKey(mailId, fromGuild)
	local key = zo_getSafeId64Key and zo_getSafeId64Key(mailId) or tostring(mailId)
	return (fromGuild and "guild:" or "mail:") .. key
end

function kept:Holds(mailId, fromGuild)
	local key = MailKey(mailId, fromGuild)
	for index, entry in ipairs(self:All()) do
		if entry.mailKey == key then
			return index
		end
	end
	return nil
end

function kept:SaveFromInbox()
	local mailId, fromGuild = self:ActiveMailId()
	if not mailId then
		return nil, GetString(SI_PBSMX_ERROR_NO_MAIL_OPEN)
	end

	local already = self:Holds(mailId, fromGuild)
	if already then
		return nil, Format(SI_PBSMX_ERROR_ALREADY_KEPT, already)
	end

	if fromGuild then
		return self:AddGuildMail(mailId)
	end

	if IsReadMailInfoReady and not IsReadMailInfoReady(mailId) then
		return nil, GetString(SI_PBSMX_ERROR_MAIL_NOT_READY)
	end

	local senderDisplayName, senderCharacterName, subject, _, _, fromSystem, fromCustomerService,
		returned, numAttachments, attachedMoney, codAmount, expiresInDays = GetMailItemInfo(mailId)

	local body = ReadMail(mailId) or ""

	local entry = {
		-- A letter that arrived. Compose puts back its words and nothing else.
		received = true,

		-- Addressed back to whoever sent it, so putting it on the page is a reply. A letter
		-- from the game itself has nobody to reply to, so it gets no addressee rather than a
		-- name that would fail to send.
		to = (fromSystem or fromCustomerService) and "" or (senderDisplayName or ""),

		from = senderDisplayName or "",
		fromCharacter = senderCharacterName or "",
		fromSystem = fromSystem or false,
		returned = returned or false,

		subject = subject or "",
		body = body,

		-- What the mail HAD. Kept as a note of what arrived, never as something to re-attach.
		attachments = AttachmentRecord(mailId, numAttachments),
		gold = attachedMoney or 0,
		cod = codAmount or 0,

		expiredInDays = expiresInDays,
		mailKey = MailKey(mailId, false),
	}

	return self:Add(entry)
end

-- ---------------------------------------------------------------------------------------
-- Guild mail
--
-- A different system with a different id space, and simpler: GetGuildMailItemInfo hands back
-- the body with the header, so there is no fetch to wait for and no IsReadMailInfoReady to
-- check. Guild mail carries no attachments and no gold at all.
--
--     GetGuildMailItemInfo(id) -> guildId, subject, body, expiresInDays, expiresInSeconds,
--                                 secsSinceReceived, sender
--
-- It is shown as coming from the guild, because that is how the client shows it and how anybody
-- would look for it later, and addressed back to the officer who sent it, because they are the
-- only party a reply could reach.
-- ---------------------------------------------------------------------------------------

function kept:AddGuildMail(guildMailId)
	if not GetGuildMailItemInfo then
		return nil, GetString(SI_PBSMX_ERROR_GUILD_MAIL)
	end

	if IsValidGuildMail and not IsValidGuildMail(guildMailId) then
		return nil, GetString(SI_PBSMX_ERROR_GUILD_MAIL_GONE)
	end

	local guildId, subject, body, expiresInDays, _, _, sender = GetGuildMailItemInfo(guildMailId)

	local guildName = (GetGuildName and guildId and GetGuildName(guildId)) or ""

	local entry = {
		received = true,
		fromGuild = true,

		to = sender or "",
		from = guildName ~= "" and guildName or (sender or ""),
		fromCharacter = sender or "",
		guildName = guildName,

		subject = subject or "",
		body = body or "",

		attachments = {},
		gold = 0,
		cod = 0,

		expiredInDays = expiresInDays,
		mailKey = MailKey(guildMailId, true),
	}

	return self:Add(entry)
end
