--[[
  * Wykkyd [ Mail Box ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
  * Reply feature with help from "awesomebilly" ~ Send him some gold as a thanks ;)
  * Last update by:  Ravalox Darkshire
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 3
_addon._v.daily 	= 4
_addon._v.minor 	= 10
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsMailBox"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Mailbox"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = nil

_addon.Sender = ""
_addon.EmailTitle = ""
_addon.InboxVisible = false
_addon.selectedMailID = nil

_addon.displayKeyBinds = function()
    if _addon.InboxVisible then
         if SCENE_MANAGER.currentScene.name == 'mailInbox' then
             return true
		 else
			KEYBIND_STRIP:RemoveKeybindButton(_addon.ReplyKeyBind)
			return false
         end
    end
    return false
end

local replyCallback = function() _addon.SendMail() end
local deleteCallback = function(a,b,c,d,e,f,g,h,i)
		if _addon.selectedMailID ~= nil and _addon.selectedMailID ~= 0 then
			local _,_,_,_,_,_,_,_,numAttachments,attachedMoney,_,_,_ = GetMailItemInfo(_addon.selectedMailID)
			 if numAttachments == nil or numAttachments == 0 then
				if attachedMoney == nil or attachedMoney == 0 then
					DeleteMail( _addon.selectedMailID, true )
				end
			end
		end
	end

_addon.ReplyKeyBind = {
	name       = "Reply",
	keybind    = "UI_SHORTCUT_SECONDARY",
	visible    = _addon.displayKeyBinds(),
	callback   = replyCallback,
	alignment  = KEYBIND_STRIP_ALIGN_RIGHT,
}

_addon.LoadSavedVariables = function( self )
	if self.Settings.Enabled == nil then self.Settings.Enabled = true end
end

_addon.LoadSettingsMenu = function( self )
	local panelData = self:MakeStandardSettingsPanel( "Exodus Code Group", "|cFF2222" )
	local optionsTable = {
		[1] = {
			type = "description",
			text = "Adds a Reply feature to any mail that doesn't have an attachment. It will also auto-return mail from others if that mail contains at least 1 attachment and starts with the subject RETURN, BOUNCE or RTS.",
		},
		[2] = {
			type = "checkbox",
			name = "Enable Mail Return Bot",
			tooltip = "Enables the bouncing of RETURN and BOUNCE mails from others",
			getFunc = function() return self.Settings.Enabled end,
			setFunc = function( val ) self.Settings.Enabled = val end,
		},
		[3] = {
			type = "checkbox",
			name = "Disable DELETE Confirmation",
			tooltip = "Avoids the ZOS confirmation when deleting empty mail.",
			getFunc = function() return self:GetOrDefault( true, self.Settings[ "delete_confirm_byebye" ] ) end,
			setFunc = function( val ) self.Settings[ "delete_confirm_byebye" ] = val end,
		},
	}
	optionsTable = self:InjectAdvancedSettings( optionsTable, 1 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
    self:RegisterEvent(EVENT_MAIL_READABLE, _addon.ReadMail, false)
    self:RegisterEvent(EVENT_MAIL_SEND_SUCCESS, _addon.ClearMailbox, false)
    self:RegisterEvent(EVENT_MAIL_CLOSE_MAILBOX, _addon.MailBoxClosed, false)
    self:RegisterEvent(EVENT_MAIL_OPEN_MAILBOX, _addon.SetupMailbox, false)

	self:OnUpdateCallback( "MailBox", self.CheckMail, .5 )
end

if wykkydsMailBoxGlobal == nil then wykkydsMailBoxGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsMailBoxGlobal", true
)

_addon.ReturnedMail = {}

_addon.CheckMail = function()
	if not _addon.Settings.Enabled then return end
	local numMail = GetNumMailItems()
	local lastId = nil

	for m = 1, numMail, 1 do
		lastId = GetNextMailId( lastId )
		local SenderAccount, SenderName, Subject, Icon, systemBool1, systemBool2, bool3, returnedMail, numAttachments, num2, num3, daysLeft, someNumber = GetMailItemInfo( lastId )
		if string.find(SenderAccount, "@") then
			if SenderName ~= "" and Subject ~= "" then
				if numAttachments > 0 and not returnedMail and not systemBool1 and not systemBool2 then
					if string.upper(string.sub(Subject,1,6)) == "RETURN"
					or string.upper(string.sub(Subject,1,6)) == "BOUNCE"
					or string.upper(string.sub(Subject,1,4)) == "RTS "
					or string.upper(Subject) == "RTS"
					then
						if _addon.ReturnedMail[lastId] == nil then
							ReturnMail( lastId );
							_addon:Print("|c610B0B[MailBox]"..LWF4_DEFAULT_CHAT_COLOR.." Returning '|r"..Subject..LWF4_DEFAULT_CHAT_COLOR.."' from|r "..SenderName)
							_addon.ReturnedMail[lastId] = lastId
							return
						end
					end
				end
			end
		end
	end
end

local b = function( bool )
	if bool then return "true" else return "false" end
end

_addon.ParseMail = function()
	if not _addon.Settings.Enabled then return end
	local numMail = GetNumMailItems()
	local lastId = nil
	for m = 1, numMail, 1 do
		lastId = GetNextMailId( lastId )
		local SenderAccount, SenderName, Subject, Icon, bool1, bool2, bool3, bool4, numAttachments, num2, num3, daysLeft, someNumber = GetMailItemInfo( lastId )
		_addon:Print("Mail: "..lastId)
		_addon:Print(SenderAccount.." - "..SenderName.." - "..Subject.." - "..Icon.." - "..
			b(bool1).." - "..b(bool2).." - "..b(bool3).." - "..b(bool4).." - "..
			numAttachments.." - "..num2.." - "..num3.." - "..daysLeft.." - "..someNumber)
    end
end

_addon.ReadMail = function( eventCode, mailId )
	if type(MailR) == "table" then return end
	if _addon:GetOrDefault( true, _addon.Settings[ "delete_confirm_byebye" ] ) then
		if KEYBIND_STRIP.keybinds then
			if KEYBIND_STRIP.keybinds["UI_SHORTCUT_NEGATIVE"] then
				if KEYBIND_STRIP.keybinds["UI_SHORTCUT_NEGATIVE"]["keybindButtonDescriptor"] then
					KEYBIND_STRIP.keybinds["UI_SHORTCUT_NEGATIVE"]["keybindButtonDescriptor"]["name"] = "Force Delete"
					KEYBIND_STRIP.keybinds["UI_SHORTCUT_NEGATIVE"]["keybindButtonDescriptor"].callback = function(...) deleteCallback(...) end
				end
			end
		end
	end
    _addon.InboxVisible = false
	_addon.selectedMailID = mailId
    local mail = {}
    mail.senderDisplayName, mail.senderCharacterName, mail.subject, mail.icon, mail.unread, mail.fromSystem, mail.fromCustomerService,
    mail.returned, mail.numAttachments, mail.attachedMoney, mail.codAmount, mail.expiresInDays, mail.secsSinceReceived = GetMailItemInfo(mailId)
    if not mail.fromSystem and (not mail.numAttachments or mail.numAttachments <= 0) and not mail.fromCustomerService then
		_addon.InboxVisible       	= true
		KEYBIND_STRIP:UpdateKeybindButton(_addon.ReplyKeyBind)
        _addon.Sender             	= GetMailSender(mailId)
        _addon.EmailTitle        	= (mail.subject)
        _addon.CurrentMessageBody 	= (ZO_MailInboxMessageBody:GetText())
    end
	_addon.InboxVisible = false
end

_addon.SendMail = function()
    _addon.InboxVisible = false
	KEYBIND_STRIP:RemoveKeybindButton(_addon.ReplyKeyBind)   -- work around 5/12 to prevent reply button from crashing addon
    ZO_MainMenuSceneGroupBarButton2.m_object.m_buttonData:callback()
    ZO_MailSendToField:SetText( _addon.Sender )
	local checkSubject
	checkSubject = string.sub(_addon.EmailTitle, 1,3)
    if checkSubject ~= "RE:" then
		ZO_MailSendSubjectField:SetText( "RE: " .. _addon.EmailTitle)
	else
		ZO_MailSendSubjectField:SetText(_addon.EmailTitle)
	end
    ZO_MailSendBodyField:SetText("")
    ZO_MailSendBodyField:TakeFocus()
end

_addon.ClearMailbox= function()
    QueueMoneyAttachment(0) -- bug fix from ESO (just for regressions)
    ZO_MailSendToField:SetText( "" )
    ZO_MailSendSubjectField:SetText( "" )
    ZO_MailSendBodyField:SetText("")
end

_addon.MailBoxClosed= function()
    _addon.ClearMailbox()
    -- KEYBIND_STRIP:RemoveKeybindButton(_addon.DeleteKeyBind)
    KEYBIND_STRIP:RemoveKeybindButton(_addon.ReplyKeyBind)
end

WYK_MailBox = _addon
