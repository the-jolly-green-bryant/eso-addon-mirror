-- RdK Group Tool Chat System
-- By @s0rdrak (PC / EU)

RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.chatSystem = RdKGToolUtil.chatSystem or {}
local RdKGToolChat = RdKGToolUtil.chatSystem
RdKGToolUtil.math = RdKGToolUtil.math or {}
local RdKGToolMath = RdKGToolUtil.math
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu

RdKGToolChat.callbackName = RdKGTool.addonName .. "ChatSystem"

RdKGToolChat.constants = {}
RdKGToolChat.constants.RDK_PREFIX_WITHOUT_MODULE = "|c%s[RdK]: %s"
RdKGToolChat.constants.RDK_PREFIX_WITH_MODULE = "|c%s[RdK %s]: %s"
RdKGToolChat.constants.PREFIX_WITH_MODULE = "|c%s[%s]: %s"
RdKGToolChat.constants.messageTypes = {}
RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL = 1
RdKGToolChat.constants.messageTypes.MESSAGE_WARNING = 2
RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG = 3
RdKGToolChat.constants.references = RdKGToolChat.constants.references or {}
RdKGToolChat.constants.references.CHAT_DROPDOWN_SELECTED_TAB = "CHAT_DROPDOWN_SELECTED_TAB"

RdKGToolChat.state = {}
RdKGToolChat.state.prefixColor = "FFFFFF"
RdKGToolChat.state.bodyColor = "FFFFFF"

function RdKGToolChat.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolChat.callbackName, RdKGToolChat.OnProfileChanged)
	RdKGToolChat.AdjustColors()
end

function RdKGToolChat.GetDefaults()
	local defaults = {}
	defaults.enabled = true
	defaults.tab = 1
	defaults.prefixEnabled = true
	defaults.rdkPrefixEnabled = true
	defaults.showWarnings = true
	defaults.showDebug = false
	defaults.showNormal = true
	defaults.addTimestamp = false
	defaults.hideSeconds = true
	defaults.colors = {}
	defaults.colors.prefix = {}
	defaults.colors.prefix.r = 0.5
	defaults.colors.prefix.g = 1
	defaults.colors.prefix.b = 0.5
	defaults.colors.body = {}
	defaults.colors.body.r = 1
	defaults.colors.body.g = 1
	defaults.colors.body.b = 1
	defaults.colors.warning = {}
	defaults.colors.warning.r = 1
	defaults.colors.warning.g = 0
	defaults.colors.warning.b = 0
	defaults.colors.debug = {}
	defaults.colors.debug.r = 0.5
	defaults.colors.debug.g = 1
	defaults.colors.debug.b = 1
	defaults.colors.player = {}
	defaults.colors.player.r = 0
	defaults.colors.player.g = 0.59765625
	defaults.colors.player.b = 0.6640625
	defaults.colors.timestamp = {}
	defaults.colors.timestamp.r = 0.42578125
	defaults.colors.timestamp.g = 0.42578125
	defaults.colors.timestamp.b = 0.42578125
	return defaults
end

function RdKGToolChat.SendChatMessage(message, prefix, messageType, sendMessage)
	if messageType == nil then
		messageType = RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL 
	end
	if RdKGToolChat.csVars.enabled == true and (sendMessage == nil or sendMessage == true) and 
	  (((RdKGToolChat.csVars.showWarnings == true and messageType == RdKGToolChat.constants.messageTypes.MESSAGE_WARNING)) or
	  ((RdKGToolChat.csVars.showDebug == true and messageType == RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG)) or
	  ((RdKGToolChat.csVars.showNormal == true and messageType == RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL))) then
		local messageColor = RdKGToolChat.state.bodyColor
		local color = RdKGToolChat.csVars.colors.body
		if messageType == nil or messageType == RdKGToolChat.constants.messageTypes.MESSAGE_NORMAL then
			messageColor = RdKGToolChat.state.bodyColor
			color = RdKGToolChat.csVars.colors.body
		elseif messageType == RdKGToolChat.constants.messageTypes.MESSAGE_WARNING then
			messageColor = RdKGToolChat.state.warningColor
			color = RdKGToolChat.csVars.colors.warning
		elseif messageType == RdKGToolChat.constants.messageTypes.MESSAGE_DEBUG then
			messageColor = RdKGToolChat.state.debugColor
			color = RdKGToolChat.csVars.colors.debug
		end
		message = string.format("|c%s%s", messageColor, message)
		if RdKGToolChat.csVars.prefixEnabled == true then
			if RdKGToolChat.csVars.rdkPrefixEnabled == true then
				if prefix ~= nil then
					message = string.format(RdKGToolChat.constants.RDK_PREFIX_WITH_MODULE, RdKGToolChat.state.prefixColor, prefix, message)
				else
					message = string.format(RdKGToolChat.constants.RDK_PREFIX_WITHOUT_MODULE, RdKGToolChat.state.prefixColor, message)
				end
			else
				if prefix ~= nil then
					message = string.format(RdKGToolChat.constants.PREFIX_WITH_MODULE, RdKGToolChat.state.prefixColor, prefix, message)
				end
			end
		end
		if RdKGToolChat.csVars.addTimestamp == true then
			local timestamp = GetTimeString()
			if RdKGToolChat.csVars.hideSeconds == true then
				local split = {zo_strsplit(":",timestamp)}
				timestamp = string.format("%s:%s", split[1], split[2])
			end
			message = string.format("|c%s[%s]|r%s", RdKGToolChat.state.timestampColor, timestamp, message)
		end
		if CHAT_SYSTEM ~= nil then
			if CHAT_SYSTEM.containers[1] ~= nil and CHAT_SYSTEM.containers[1].windows[RdKGToolChat.csVars.tab] ~= nil and CHAT_SYSTEM.containers[1].windows[RdKGToolChat.csVars.tab].buffer ~= nil then
				CHAT_SYSTEM.containers[1].windows[RdKGToolChat.csVars.tab].buffer:AddMessage(message, color.r, color.g, color.b)
			else
				CHAT_SYSTEM:AddMessage(message)
			end
		else
			d(message)
		end
	end
end

function RdKGToolChat.AdjustColors()
	RdKGToolChat.state.prefixColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.prefix.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.prefix.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.prefix.b))
	RdKGToolChat.state.bodyColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.body.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.body.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.body.b))
	RdKGToolChat.state.warningColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.warning.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.warning.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.warning.b))
	RdKGToolChat.state.debugColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.debug.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.debug.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.debug.b))
	RdKGToolChat.state.playerColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.player.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.player.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.player.b))
	RdKGToolChat.state.timestampColor = RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.timestamp.r)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.timestamp.g)) .. RdKGToolMath.ByteToHex(RdKGToolMath.FloatingPointToByte(RdKGToolChat.csVars.colors.timestamp.b))
end

function RdKGToolChat.GetPrefixColor()
	return RdKGToolChat.csVars.colors.prefix
end

function RdKGToolChat.GetBodyPrefixHex()
	return RdKGToolChat.state.prefixColor
end

function RdKGToolChat.GetBodyColor()
	return RdKGToolChat.csVars.colors.body
end

function RdKGToolChat.GetBodyColorHex()
	return RdKGToolChat.state.bodyColor
end

function RdKGToolChat.GetWarningColor()
	return RdKGToolChat.csVars.colors.warning
end

function RdKGToolChat.GetWarningColorHex()
	return RdKGToolChat.state.warningColor
end

function RdKGToolChat.GetDebugColor()
	return RdKGToolChat.csVars.colors.debug
end

function RdKGToolChat.GetDebugColorHex()
	return RdKGToolChat.state.debugColor
end

function RdKGToolChat.GetPlayerColor()
	return RdKGToolChat.csVars.colors.player
end

function RdKGToolChat.GetPlayerColorHex()
	return RdKGToolChat.state.playerColor
end

--callbacks
function RdKGToolChat.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		RdKGToolChat.csVars = currentProfile.util.chatSystem
		RdKGToolChat.AdjustColors()
	end
end

function RdKGToolChat.RefreshMenu()
	RdKGToolChat.UpdateChatTabs(RdKGToolChat.GetChatAvailableTabs(), RdKGToolChat.GetChatAvailableTabValues())
end

--menu interaction
function RdKGToolChat.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.CHAT_HEADER,
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CHAT_ENABLED,
					getFunc = RdKGToolChat.GetChatEnabled,
					setFunc = RdKGToolChat.SetChatEnabled
				},
				[2] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.CHAT_SELECTED_TAB,
					choices = RdKGToolChat.GetChatAvailableTabs(),
					choicesValues = RdKGToolChat.GetChatAvailableTabValues(),
					getFunc = RdKGToolChat.GetChatSelectedTab,
					setFunc = RdKGToolChat.SetChatSelectedTab,
					reference = RdKGToolChat.constants.references.CHAT_DROPDOWN_SELECTED_TAB
				},
				[3] = {
					type = "button",
					name = RdKGToolMenu.constants.CHAT_REFRESH,
					func = RdKGToolChat.RefreshMenu,
					width = "full"
				},
				[4] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CHAT_WARNINGS_ONLY,
					getFunc = RdKGToolChat.GetChatWarningsOnly,
					setFunc = RdKGToolChat.SetChatWarningsOnly
				},
				[5] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CHAT_DEBUG_ONLY,
					getFunc = RdKGToolChat.GetChatDebugOnly,
					setFunc = RdKGToolChat.SetChatDebugOnly
				},
				[6] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CHAT_NORMAL_ONLY,
					getFunc = RdKGToolChat.GetChatNormalOnly,
					setFunc = RdKGToolChat.SetChatNormalOnly
				},
				[7] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CHAT_PREFIX_ENABLED,
					getFunc = RdKGToolChat.GetChatPrefixEnabled,
					setFunc = RdKGToolChat.SetChatPrefixEnabled
				},
				[8] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CHAT_RDK_PREFIX_ENABLED,
					getFunc = RdKGToolChat.GetChatRdKPrefixEnabled,
					setFunc = RdKGToolChat.SetChatRdKPrefixEnabled
				},
				[9] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CHAT_COLOR_PREFIX,
					getFunc = RdKGToolChat.GetChatPrefixColor,
					setFunc = RdKGToolChat.SetChatPrefixColor,
					width = "full"
				},
				[10] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CHAT_COLOR_BODY,
					getFunc = RdKGToolChat.GetChatBodyColor,
					setFunc = RdKGToolChat.SetChatBodyColor,
					width = "full"
				},
				[11] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CHAT_COLOR_WARNING,
					getFunc = RdKGToolChat.GetChatWarningColor,
					setFunc = RdKGToolChat.SetChatWarningColor,
					width = "full"
				},
				[12] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CHAT_COLOR_DEBUG,
					getFunc = RdKGToolChat.GetChatDebugColor,
					setFunc = RdKGToolChat.SetChatDebugColor,
					width = "full"
				},
				[13] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CHAT_COLOR_PLAYER,
					getFunc = RdKGToolChat.GetChatPlayerColor,
					setFunc = RdKGToolChat.SetChatPlayerColor,
					width = "full"
				},
				[14] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CHAT_ADD_TIMESTAMP,
					getFunc = RdKGToolChat.GetChatAddTimestamp,
					setFunc = RdKGToolChat.SetChatAddTimestamp
				},
				[15] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.CHAT_HIDE_SECONDS,
					getFunc = RdKGToolChat.GetChatHideSeconds,
					setFunc = RdKGToolChat.SetChatHideSeconds
				},
				[16] = {
					type = "colorpicker",
					name = RdKGToolMenu.constants.CHAT_COLOR_TIMESTAMP,
					getFunc = RdKGToolChat.GetChatTimestampColor,
					setFunc = RdKGToolChat.SetChatTimestampColor,
					width = "full"
				},
			}
		},
	}
	return menu
end

function RdKGToolChat.GetChatEnabled()
	return RdKGToolChat.csVars.enabled
end

function RdKGToolChat.SetChatEnabled(value)
	RdKGToolChat.csVars.enabled = value
end

function RdKGToolChat.GetChatAvailableTabs()
	local tabNames = {}
	if CHAT_SYSTEM ~= nil and CHAT_SYSTEM.containers ~= nil and CHAT_SYSTEM.containers[1] ~= nil and CHAT_SYSTEM.containers[1].windows ~= nil then
		for i = 1, #CHAT_SYSTEM.containers[1].windows do
			table.insert(tabNames, CHAT_SYSTEM.containers[1]:GetTabName(i))
		end
	end
	return tabNames
end

function RdKGToolChat.GetChatAvailableTabValues()
	local tabIndexes = {}
	if CHAT_SYSTEM ~= nil and CHAT_SYSTEM.containers ~= nil and CHAT_SYSTEM.containers[1] ~= nil and CHAT_SYSTEM.containers[1].windows ~= nil then
		for i = 1, #CHAT_SYSTEM.containers[1].windows do
			table.insert(tabIndexes, i)
		end
	end
	return tabIndexes
end

function RdKGToolChat.GetChatSelectedTab()
	if CHAT_SYSTEM ~= nil and CHAT_SYSTEM.containers ~= nil and CHAT_SYSTEM.containers[1] ~= nil and CHAT_SYSTEM.containers[1].windows ~= nil then
		return RdKGToolChat.csVars.tab
	else
		return nil
	end
end

function RdKGToolChat.SetChatSelectedTab(value)
	if value ~= nil then
		RdKGToolChat.csVars.tab = value
	end
end

function RdKGToolChat.GetChatWarningsOnly()
	return RdKGToolChat.csVars.showWarnings
end

function RdKGToolChat.SetChatWarningsOnly(value)
	RdKGToolChat.csVars.showWarnings = value
end

function RdKGToolChat.GetChatDebugOnly()
	return RdKGToolChat.csVars.showDebug
end

function RdKGToolChat.SetChatDebugOnly(value)
	RdKGToolChat.csVars.showDebug = value
end

function RdKGToolChat.GetChatNormalOnly()
	return RdKGToolChat.csVars.showNormal
end

function RdKGToolChat.SetChatNormalOnly(value)
	RdKGToolChat.csVars.showNormal = value
end

function RdKGToolChat.GetChatPrefixEnabled()
	return RdKGToolChat.csVars.prefixEnabled
end

function RdKGToolChat.SetChatPrefixEnabled(value)
	RdKGToolChat.csVars.prefixEnabled = value
end

function RdKGToolChat.GetChatRdKPrefixEnabled()
	return RdKGToolChat.csVars.rdkPrefixEnabled
end

function RdKGToolChat.SetChatRdKPrefixEnabled(value)
	RdKGToolChat.csVars.rdkPrefixEnabled = value
end

function RdKGToolChat.GetChatPrefixColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolChat.csVars.colors.prefix)
end

function RdKGToolChat.SetChatPrefixColor(r, g, b)
	RdKGToolChat.csVars.colors.prefix = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolChat.AdjustColors()
end

function RdKGToolChat.GetChatBodyColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolChat.csVars.colors.body)
end

function RdKGToolChat.SetChatBodyColor(r, g, b)
	RdKGToolChat.csVars.colors.body = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolChat.AdjustColors()
end

function RdKGToolChat.GetChatWarningColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolChat.csVars.colors.warning)
end

function RdKGToolChat.SetChatWarningColor(r, g, b)
	RdKGToolChat.csVars.colors.warning = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolChat.AdjustColors()
end

function RdKGToolChat.GetChatDebugColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolChat.csVars.colors.debug)
end

function RdKGToolChat.SetChatDebugColor(r, g, b)
	RdKGToolChat.csVars.colors.debug = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolChat.AdjustColors()
end

function RdKGToolChat.GetChatPlayerColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolChat.csVars.colors.player)
end

function RdKGToolChat.SetChatPlayerColor(r, g, b)
	RdKGToolChat.csVars.colors.player = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolChat.AdjustColors()
end

function RdKGToolChat.GetChatAddTimestamp()
	return RdKGToolChat.csVars.addTimestamp
end

function RdKGToolChat.SetChatAddTimestamp(value)
	RdKGToolChat.csVars.addTimestamp = value
end

function RdKGToolChat.GetChatHideSeconds()
	return RdKGToolChat.csVars.hideSeconds
end

function RdKGToolChat.SetChatHideSeconds(value)
	RdKGToolChat.csVars.hideSeconds = value
end

function RdKGToolChat.GetChatTimestampColor()
	return RdKGToolMenu.GetRGBColor(RdKGToolChat.csVars.colors.timestamp)
end

function RdKGToolChat.SetChatTimestampColor(r, g, b)
	RdKGToolChat.csVars.colors.timestamp = RdKGToolMenu.GetColorFromRGB(r, g, b)
	RdKGToolChat.AdjustColors()
end

function RdKGToolChat.UpdateChatTabs(chatNames, chatIndexes)
	local control = GetWindowManager():GetControlByName(RdKGToolChat.constants.references.CHAT_DROPDOWN_SELECTED_TAB)
	if control ~= nil and #chatNames == #chatIndexes then
		--control.value = chatNames
		--control.valueChoises = chatIndexes
		--control.choises = {}
		--for i = 1, #chatNames do
		--	control.choises[chatIndexes[i]] = chatNames[i]
		--end
		control:UpdateChoices(chatNames, chatIndexes)
	end
end