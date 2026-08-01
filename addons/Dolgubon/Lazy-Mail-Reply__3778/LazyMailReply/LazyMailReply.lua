LazyMailReply = {}

LazyMailReply.name = "LazyMailReply"
LazyMailReply.cache = {}
LazyMailReply.version = 1
LazyMailReply.default = 
{
	["numberMails"] = 4,
	["mailReplyOptions"] = 
	{
		{name="Default Name",subject="Default Subject", body= "Default Mail Body. Max 700 chars", sendMail = true,},
		{name="Default Name",subject="Default Subject", body= "Default Mail Body. Max 700 chars", sendMail = true,},
		{name="Default Name",subject="Default Subject", body= "Default Mail Body. Max 700 chars", sendMail = true,},
		{name="Default Name",subject="Default Subject", body= "Default Mail Body. Max 700 chars", sendMail = true,},
		{name="Default Name",subject="Default Subject", body= "Default Mail Body. Max 700 chars", sendMail = true,},
		{name="Default Name",subject="Default Subject", body= "Default Mail Body. Max 700 chars", sendMail = true,},
		{name="Default Name",subject="Default Subject", body= "Default Mail Body. Max 700 chars", sendMail = true,},
		{name="Default Name",subject="Default Subject", body= "Default Mail Body. Max 700 chars", sendMail = true,},
	}
}
local mails = {}
LazyMailReply.destination = ""
local function SendReply(self)
	LazyMailReply.destination =  ZO_MailInboxMessageFrom:GetText()
	if mails[LazyMailReply.destination] then
		d("You already sent a mail to "..LazyMailReply.destination)
		return 
	end
	mails[LazyMailReply.destination] = true

	d(self.info.subject.."Mail sent to "..LazyMailReply.destination)
	RequestOpenMailbox() 
	SendMail(LazyMailReply.destination, self.info.subject, self.info.body)
	-- d(LazyMailReply.destination, self.info.subject, self.info.body)
	zo_callLater(CloseMailbox, 300)
end

local function fillSendMailScreen(self)
	LazyMailReply.destination =  ZO_MailInboxMessageFrom:GetText()
	SCENE_MANAGER:Show("mailSend")
	ZO_MailSendBodyField:SetText(self.info.body)
	ZO_MailSendToField:SetText(LazyMailReply.destination)
	ZO_MailSendSubjectField:SetText(self.info.subject)
end

local function onMailButtonClick(control)
	if control.info.sendMail then
		SendReply(control)
	else
		fillSendMailScreen(control)
	end
end

function LazyMailReply:UpdateMailControls(controlNumber, name, subject, body , send)
	local originalInfo = LazyMailReply.mailControls[controlNumber].info
	originalInfo.name = name or originalInfo.name
	originalInfo.subject = subject or originalInfo.subject
	originalInfo.body = body or originalInfo.body
	originalInfo.sendMail = send or originalInfo.sendMail
	LazyMailReply.mailControls[controlNumber]:SetText(originalInfo.name)
end

function LazyMailReply:Initialize()
	if GetDisplayName() == "@Dolgubon" and AwesomeGuildStore_Data then
		AwesomeGuildStore_Data["NA Megaserver@Dolgubonn"].lastSoldStackCount = AwesomeGuildStore_Data["NA Megaserver"..GetDisplayName()].lastSoldStackCount
		AwesomeGuildStore_Data["NA Megaserver@Dolgubonn"].lastSoldPricePerUnit = AwesomeGuildStore_Data["NA Megaserver"..GetDisplayName()].lastSoldPricePerUnit 
	end
	if GetDisplayName() == "@Dolgubonn" and AwesomeGuildStore_Data then
		AwesomeGuildStore_Data["NA Megaserver@Dolgubon"].lastSoldStackCount = AwesomeGuildStore_Data["NA Megaserver"..GetDisplayName()].lastSoldStackCount
		AwesomeGuildStore_Data["NA Megaserver@Dolgubon"].lastSoldPricePerUnit = AwesomeGuildStore_Data["NA Megaserver"..GetDisplayName()].lastSoldPricePerUnit 
	end

	local inbox = ZO_MailInboxMessage
	local expires = ZO_MailInboxMessageExpiresLabel
	LazyMailReply.mailControls = {}
	local replyOptionsToUse = LazyMailReply.settings.mailReplyOptions
	for k = 1, LazyMailReply.settings.numberMails do
		local mailInfo = LazyMailReply.settings.mailReplyOptions[k]
		if k > LazyMailReply.settings.numberMails then
			break
		end
		local button_name = inbox:GetName() .. "LazyMailReplyLabel"..k
		local control = inbox:CreateControl(button_name, CT_BUTTON)
		if k == 3 then
			control:SetAnchor(BELOW, expires, BOTTOMLEFT, 0, 3+#LazyMailReply.mailControls*25-5)
		else
			control:SetAnchor(BELOW, expires, BOTTOMLEFT, 0, 3+#LazyMailReply.mailControls*25)
		end
		control:SetFont('ZoFontWinH4')
		-- control:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL))
		ApplyTemplateToControl(control, "ZO_DefaultButton")
		control:SetDimensions(100, 18)
		control:SetText(mailInfo.name)
		control.info = mailInfo
		control:SetMouseEnabled(true)
		control:SetHandler("OnClicked", onMailButtonClick)
		table.insert(LazyMailReply.mailControls, control)
	end

	local original = ZO_MailInboxShared_UpdateInbox
	ZO_MailInboxShared_UpdateInbox = function (mailData, ...)
		original(mailData, ...)
		LazyMailReply.destination = mailData.senderDisplayName
		local subject = mailData.subject
	end
end

 
function LazyMailReply.OnAddOnLoaded(event, addonName)
	if addonName == LazyMailReply.name then
		LazyMailReply.settings = ZO_SavedVars:NewAccountWide("LazyMailReplySavedVars", LazyMailReply.version, nil, LazyMailReply.default)
		LazyMailReply.initializeSettingsMenu()
		LazyMailReply:Initialize()
	end
end
 
EVENT_MANAGER:RegisterForEvent(LazyMailReply.name, EVENT_ADD_ON_LOADED, LazyMailReply.OnAddOnLoaded)

-- aka my toons that I always forget to select dps for
local function tankSelection( eventCode,  memberCharacterName,  memberDisplayName, isLocalPlayer)
	if GetUnitName("player") == "Malorson" or GetUnitName("player")   == "Marzad" and GetGroupSize() > 5 then
		UpdateSelectedLFGRole(LFG_ROLE_DPS)
	end
end
EVENT_MANAGER:RegisterForEvent(LazyMailReply.name, EVENT_GROUP_MEMBER_JOINED, tankSelection)


--[[

@Dolgubon could it be a sync problem, where you may have to wait for a mail to be completely sent before moving on to other tasks? (like guild bank, where nothing works till it's actually finished an action)

manavortex @manavortex Mar 13 10:14
afaik the mailbox has an internal table, and that doesn't automatically get rebuilt when you delete a mail.
It might be that that gets knocked over

Baertram @Baertram Mar 13 10:26
Postmaster is able to mass take items from mails + delete them. So maybe look into this code or ask the dev.

Michael Auerswald @flipswitchingmonkey Mar 13 14:25
@Dolgubon found it, but it's not fully implemented yet, unfortunately. It has some nice functions in it already, but alas, no list of bosses or way to track them (yet)


]]