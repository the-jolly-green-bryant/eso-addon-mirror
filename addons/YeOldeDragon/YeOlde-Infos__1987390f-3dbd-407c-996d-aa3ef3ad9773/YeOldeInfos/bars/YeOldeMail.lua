---
--- Created by YeOldeDragon.
--- DateTime: 2022-02-05
---

------------------------------------
---- constants
local ICON = "/esoui/art/menubar/gamepad/gp_playermenu_icon_mail.dds" -- "/esoui/art/menubar/menubar_mail_over.dds"
local DEFAULT_TEXT = GetString(SI_MAIL_NO_UNREAD_MAIL)

local COLOR_MAIL_NEW = ZO_WHITE --ZO_CURRENCY_HIGHLIGHT_TEXT
local COLOR_MAIL_DISABLED = YeOldeInfos.Colors.DISABLED

------------------------------------
--  YeOldeMail Class
YeOldeMail = YeOldeInfoBar_Base:Subclass()

function YeOldeMail:GetName()
	return "YeOldeMail"
end

function YeOldeMail:InitializeControls()
	self.hideForNow = false
	self.uiMail = self.uiBar:AddContentBloc("MAIL", ICON, DEFAULT_TEXT)
	self.uiMail:SetMouseEnabled(true)
	self.uiMail:SetHandler("OnMouseDown", function(_, button)
		SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_MAIL)
	end)
	self.uiBar:SetIconSize(28, 28)
end

-- SOLID-1: utilise GetExtraHideCondition() au lieu d'override SetbarVisibility
function YeOldeMail:GetExtraHideCondition()
	return self.hideForNow or false
end

function YeOldeMail:OnActivate(value)
	if value then
		self:Update()

		local function OnEventMailNumUnreadChanged(_, _)
			self:Update()
		end
		EVENT_MANAGER:RegisterForEvent(self.eventNamespace, EVENT_MAIL_NUM_UNREAD_CHANGED, OnEventMailNumUnreadChanged)
	else
		EVENT_MANAGER:UnregisterForEvent(self.eventNamespace, EVENT_MAIL_NUM_UNREAD_CHANGED)
	end
end

function YeOldeMail:Update()
	-- if self.isMaxed then
	--     self.uiBar:SetbarVisibility(true, true)
	--     EVENT_MANAGER:UnregisterForUpdate(self.eventNamespace)
	-- end
	local text = DEFAULT_TEXT
	local unreadMails = GetNumUnreadMail()

	if unreadMails == nil or unreadMails == 0 then
		self.uiMail:SetIconColor(COLOR_MAIL_DISABLED:UnpackRGB())
		self.uiMail:SetTextColor(COLOR_MAIL_DISABLED:UnpackRGB())
		unreadMails = 0
		text = DEFAULT_TEXT
	else
		self.uiMail:SetIconColor(COLOR_MAIL_NEW:UnpackRGB())
		self.uiMail:SetTextColor(COLOR_MAIL_NEW:UnpackRGB())
		text = zo_strformat(SI_MAIL_UNREAD_MAIL, unreadMails)
	end

	if self.SV.HideText then
		text = ""
	end
	self.uiMail:SetText(text)

	self.hideForNow = self.SV.HideIfNoMail and (unreadMails == 0)
	self:RefreshVisibility()
end

function YeOldeMail:InitializeSavedVars()
	if self.SV.HideIfNoMail == nil then
		self.SV.HideIfNoMail = false
	end
	if self.SV.HideText == nil then
		self.SV.HideText = false
	end
end

function YeOldeMail:InitializeSettingsMenu(controls)
	controls[#controls + 1] = {
		type = "checkbox",
		name = GetString(SI_YEOLDEINFOS_MAIL_HIDE_IF_NO_MAIL),
		tooltip = GetString(SI_YEOLDEINFOS_TT_MAIL_HIDE),
		getFunc = function()
			return self.SV.HideIfNoMail
		end,
		setFunc = function(value)
			self.SV.HideIfNoMail = value
			self:Update()
		end,
	}
	controls[#controls + 1] = {
		type = "checkbox",
		name = GetString(SI_YEOLDEINFOS_MAIL_HIDE_TEXT),
		tooltip = GetString(SI_YEOLDEINFOS_TT_MAIL_HIDE_TEXT),
		getFunc = function()
			return self.SV.HideText
		end,
		setFunc = function(value)
			self.SV.HideText = value
			self:Update()
		end,
	}

	local options = {
		type = "submenu",
		name = GetString(SI_MAIN_MENU_MAIL),
		controls = controls,
	}
	return options
end
