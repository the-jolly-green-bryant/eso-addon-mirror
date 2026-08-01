-- RdK Group Tool Menu
-- By @s0rdrak (PC / EU)

--local LAM = LibStub("LibAddonMenu-2.0")
local LAM = LibAddonMenu2

local RdKGTool = _G['RdKGTool']
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.profile = RdKGTool.profile or {}
local RdKGToolProfile = RdKGTool.profile
RdKGTool.group = RdKGTool.group or {}
local RdKGToolGroup = RdKGTool.group
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGTool.compass = RdKGTool.compass or {}
local RdKGToolCompass = RdKGTool.compass
RdKGTool.toolbox = RdKGTool.toolbox or {}
local RdKGToolToolbox = RdKGTool.toolbox
RdKGTool.classRole = RdKGTool.classRole or {}
local RdKGToolCR = RdKGTool.classRole
RdKGTool.addOnIntegration = RdKGTool.addOnIntegration or {}
local RdKGToolAoi = RdKGTool.addOnIntegration
RdKGToolAoi.mpa = RdKGToolAoi.mpa or {}
local RdKGToolMpa = RdKGToolAoi.mpa
RdKGTool.admin = RdKGTool.admin or {}
local RdKGToolAdmin = RdKGTool.admin
RdKGTool.cfg = RdKGTool.cfg or {}
local RdKGToolConfig = RdKGTool.cfg
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem

local wm = GetWindowManager()

RdKGToolMenu.lam = {}
RdKGToolMenu.lam.panel = nil
RdKGToolMenu.lam.panelData = {}
RdKGToolMenu.lam.panelData.type = "panel"
RdKGToolMenu.lam.panelData.name = "|c4592FFRdK Group Tool|r"
RdKGToolMenu.lam.panelData.displayName = "|c4592FFRdK Group Tool Configuration|r"
RdKGToolMenu.lam.panelData.author = string.format("|cFF8174%s|r\r\nThanks to: |cFF8174%s|r\r\nContributors: |cFF8174%s|r\r\n", RdKGTool.author, RdKGTool.credits, RdKGTool.contributors)
RdKGToolMenu.lam.panelData.version = string.format("|cFF8174%s|r", RdKGTool.versionString)
RdKGToolMenu.lam.panelData.registerForRefresh = true
RdKGToolMenu.lam.panelData.registerForDefaults = false
RdKGToolMenu.constants = RdKGToolMenu.constants or {}
RdKGToolMenu.constants.PREFIX = "Menu"


RdKGToolMenu.state = {}
RdKGToolMenu.state.newProfileName = ""
RdKGToolMenu.state.positionFixedConsumers = {}



--General
function RdKGToolMenu.Initialize()
	--zo_callLater(function()
		RdKGToolMenu.lam.optionsData = RdKGToolMenu.CreateOptionsData()
		RdKGToolMenu.lam.panel = LAM:RegisterAddonPanel(RdKGToolMenu.name, RdKGToolMenu.lam.panelData)
		LAM:RegisterOptionControls(RdKGToolMenu.name, RdKGToolMenu.lam.optionsData)
	--end,1)
end

function RdKGToolMenu.OpenMenu()
	LAM:OpenToPanel(RdKGToolMenu.lam.panel)
end

function RdKGToolMenu.SetErrorMessage(controlName, errorMessage)
	local errorDescription = wm:GetControlByName(controlName)
	--d(errorDescription)
	--d(errorMessage)
	if errorDescription ~= nil and errorDescription.data ~= nil then
		errorDescription.data.text = errorMessage
		errorDescription:UpdateValue()
	end
end

function RdKGToolMenu.UpdateCheckbox(checkbox)
	if checkbox ~= nil and checkbox.data ~= nil then
		checkbox:UpdateValue()
	end
end

function RdKGToolMenu.UpdateControl(control)
	if control ~= nil and control.data ~= nil then
		control:UpdateValue()
	end
end

function RdKGToolMenu.AddMenuEntries(menu, entries)
	if menu ~= nil and entries ~= nil then
		for i = 1, #entries do
			table.insert(menu, entries[i])
		end
	end
end

function RdKGToolMenu.CreateOptionsData()
	local menu = {}
	local tempMenu = {}
	--profile
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolProfile.GetMenu())
	--Fixed Components
	tempMenu = {
		[1] = {
			type = "divider",
			width = "full"
			},
		[2] = {
			type = "button",
			name = RdKGToolMenu.constants.POSITION_FIXED_SET,
			func = RdKGToolMenu.SetPositionFixed,
			width = "full"
		},
		[3] = {
			type = "button",
			name = RdKGToolMenu.constants.POSITION_FIXED_UNSET,
			func = RdKGToolMenu.UnsetPositionFixed,
			width = "full"
		},
		[4] = {
			type = "divider",
			width = "full"
		},
		[5] = {
			type = "button",
			name = RdKGToolMenu.constants.FEEDBACK,
			func = RdKGToolMenu.Feedback,
			width = "full"
		},
		[6] = {
			type = "button",
			name = RdKGToolMenu.constants.DONATE,
			func = RdKGToolMenu.DonateFreeAmount,
			width = "full"
		},
		[7] = {
			type = "button",
			name = RdKGToolMenu.constants.DONATE_5K,
			func = RdKGToolMenu.Donate5k,
			width = "full"
		},
		[8] = {
			type = "button",
			name = RdKGToolMenu.constants.DONATE_50K,
			func = RdKGToolMenu.Donate50k,
			width = "full"
		},
	}
	RdKGToolMenu.AddMenuEntries(menu, tempMenu)
	--group
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolGroup.GetMenu())
	--compass
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolCompass.GetMenu())
	--toolbox
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolToolbox.GetMenu())
	--util
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolUtil.GetMenu())
	--classRole
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolCR.GetMenu())
	--addOnIntegration
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolAoi.GetMenu())
	--Admin
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolAdmin.GetMenu())
	--Config
	RdKGToolMenu.AddMenuEntries(menu, RdKGToolConfig.GetMenu())
	return menu
end

function RdKGToolMenu.GetRGBColor(color)
	return color.r, color.g, color.b
end

function RdKGToolMenu.GetRGBAColor(color)
	return color.r, color.g, color.b, color.a
end

function RdKGToolMenu.GetColorFromRGB(r, g, b)
	return {["r"] = r, ["g"] = g, ["b"] = b}
end

function RdKGToolMenu.GetColorFromRGBA(r, g, b, a)
	return {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
end

function RdKGToolMenu.PositionFixedConsumerExists(consumer)
	for i = 1, #RdKGToolMenu.state.positionFixedConsumers do
		if RdKGToolMenu.state.positionFixedConsumers[i] == consumer then
			return true
		end
	end
	return false
end

function RdKGToolMenu.AddPositionFixedConsumer(consumer)
	if consumer ~= nil and type(consumer) == "function" and RdKGToolMenu.PositionFixedConsumerExists(consumer) == false then
		table.insert(RdKGToolMenu.state.positionFixedConsumers, consumer)
	end
end

function RdKGToolMenu.RemovePositionFixedConsumer(consumer)
	if consumer ~= nil and type(consumer) == "function" and RdKGToolMenu.PositionFixedConsumerExists(consumer) == true then
		for i = 1, #RdKGToolMenu.state.positionFixedConsumers do
			if RdKGToolMenu.state.positionFixedConsumers[i] == consumer then
				table.remove(RdKGToolMenu.state.positionFixedConsumers, i)
				break
			end
		end
	end
end

function RdKGToolMenu.Donate(amount)
	if GetWorldName() == "EU Megaserver" then
		SCENE_MANAGER:Show('mailSend')
		zo_callLater(
			function()
				ZO_MailSendToField:SetText("@s0rdrak")
				ZO_MailSendSubjectField:SetText(RdKGToolMenu.constants.DONATE_MAIL_SUBJECT)
				QueueMoneyAttachment(amount)
				ZO_MailSendBodyField:TakeFocus() 
			end, 
		200)
	else
		CHAT_SYSTEM:Maximize()
		RdKGToolChat.SendChatMessage(RdKGToolMenu.constants.DONATE_SERVER_ERROR, RdKGToolMenu.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING)
	end
end
--menu interaction
function RdKGToolMenu.SetPositionFixed()
	for i = 1, #RdKGToolMenu.state.positionFixedConsumers do
		RdKGToolMenu.state.positionFixedConsumers[i](true)
	end
end

function RdKGToolMenu.UnsetPositionFixed()
	for i = 1, #RdKGToolMenu.state.positionFixedConsumers do
		RdKGToolMenu.state.positionFixedConsumers[i](false)
	end
end

function RdKGToolMenu.Feedback()
	CHAT_SYSTEM:Maximize()
	RdKGToolChat.SendChatMessage(RdKGToolMenu.constants.FEEDBACK_STRING, RdKGToolMenu.constants.PREFIX, RdKGToolChat.constants.messageTypes.MESSAGE_WARNING)
end

function RdKGToolMenu.DonateFreeAmount()
	RdKGToolMenu.Donate(0)
end

function RdKGToolMenu.Donate5k()
	RdKGToolMenu.Donate(5000)
end

function RdKGToolMenu.Donate50k()
	RdKGToolMenu.Donate(50000)
end
--[[

zo_callLater(function()
			ZO_MailSendToField:SetText(p.mailDestination)
			ZO_MailSendSubjectField:SetText(p.parentAddonName)
			QueueMoneyAttachment(self.amount)
			ZO_MailSendBodyField:TakeFocus() end, 200)
			]]