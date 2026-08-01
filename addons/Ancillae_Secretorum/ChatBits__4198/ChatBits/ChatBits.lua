CHATBITS = CHATBITS or {
	name = "ChatBits",
	displayName = "Chat Bits",
	author = "Ancillae_Secretorum",
	version = "0.1",
	variableVersion = 6,
	defaults = {
		window = {
			x = 200,
			y = 200,
			hidden = false
		},
		data = {}
	}
}

-- Creates Main Game Menu > Settings > Addons > ChatBits
function CHATBITS.CreateSettingsPanel()
	local panelData = {
		type = "panel",
		name = CHATBITS.name,
		displayName = CHATBITS.displayName,
		author = CHATBITS.author,
		version = CHATBITS.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LibAddonMenu2:RegisterAddonPanel(CHATBITS.name, panelData)
	local strings = CHATBITS.localization.settings
	local titles = { strings.editNew }
	for i, v in ipairs(CHATBITS.savedVariables.data) do
		table.insert(titles, v.title)
	end
	local optionsData = {
		[1] = {
			type = "divider"
		},
		[2] = {
			type = "description",
			text = strings.description
		},
		[3] = {
			type = "divider"
		},
		[4] = {
			type = "dropdown",
			name = strings.edit,
			tooltip = strings.editTooltip,
			choices = titles,
			default = strings.editNew,
			getFunc = function()
				return CHATBITS.customMessageEditValue
			end,
			setFunc = function(text)
				ChatBitsTitle.data.setFunc("")
				ChatBitsCustomMessage.data.setFunc("")
				ChatBitsChatChannel.data.setFunc("")
				for i, v in ipairs(CHATBITS.savedVariables.data) do
					if v.title == text then
						CHATBITS.editIndex = i
						ChatBitsTitle.data.setFunc(v.title)
						ChatBitsCustomMessage.data.setFunc(v.message)
						choices = { [CHAT_CHANNEL_PARTY] = strings.party, [CHAT_CHANNEL_SAY] = strings.say, [CHAT_CHANNEL_ZONE] = strings.zone }
						ChatBitsChatChannel.data.setFunc(choices[v.channel])
					end
				end
			end
		},
		[5] = {
			type = "editbox",
			name = strings.title,
			tooltip = strings.titleTooltip,
			getFunc = function()
				return CHATBITS.customMessageTitleValue
			end,
			setFunc = function(text)
				CHATBITS.customMessageTitleValue = text
			end,
			width = "full",
			reference = "ChatBitsTitle"
		},
		[6] = {
			type = "editbox",
			name = strings.customMessage,
			tooltip = strings.customMessageTooltip,
			isMultiline = true,
			getFunc = function()
				return CHATBITS.customMessageValue
			end,
			setFunc = function(text)
				CHATBITS.customMessageValue = text
			end,
			width = "full",
			reference = "ChatBitsCustomMessage"
		},
		[7] = {
			type = "dropdown",
			name = strings.chatChannel,
			tooltip = strings.chatChannelTooltip,
			choices = { strings.party, strings.say, strings.zone },
			getFunc = function()
				return CHATBITS.customMessageChannelValue
			end,
			setFunc = function(text)
				CHATBITS.customMessageChannelValue = text
			end,
			reference = "ChatBitsChatChannel"
		},
		[8] = {
			type = "dropdown",
			name = strings.event,
			tooltip = strings.eventTooltip,
			choices = { strings.onEnterDungeon, strings.onExitDungeon },
			getFunc = function()
				return CHATBITS.customMessageEventValue
			end,
			setFunc = function(text)
				CHATBITS.customMessageEventValue = text
			end,
			reference = "ChatBitsEvent"
		},
		[9] = {
			type = "button",
			name = strings.deleteMessage,
			tooltip = strings.deleteMessageTooltip,
			func = function()
				table.remove(CHATBITS.savedVariables.data, CHATBITS.editIndex)
				CHATBITS.editIndex = nil
			end
		},
		[10] = {
			type = "button",
			name = strings.saveNewMessage,
			tooltip = strings.saveNewMessageTooltip,
			func = function()
				if CHATBITS.customMessageTitleValue == '' or CHATBITS.customMessageTitleValue == nil then
					CHATBITS.customMessageTitleValue = string.sub(CHATBITS.customMessageValue, 1, 10)
				end
				choices = { [strings.party] = CHAT_CHANNEL_PARTY, [strings.say] = CHAT_CHANNEL_SAY, [strings.zone] = CHAT_CHANNEL_ZONE }
				CHATBITS.customMessageChannelValue = choices[CHATBITS.customMessageChannelValue]
				if CHATBITS.editIndex == nil then
					table.insert(CHATBITS.savedVariables.data, { title = CHATBITS.customMessageTitleValue, CHATBITS.editIndex, message = CHATBITS.customMessageValue, channel = CHATBITS.customMessageChannelValue })
				else
					CHATBITS.savedVariables.data[CHATBITS.editIndex] = { title = CHATBITS.customMessageTitleValue, CHATBITS.editIndex, message = CHATBITS.customMessageValue, channel = CHATBITS.customMessageChannelValue }
				end
				CHATBITS.customMessageTitleValue = nil
				CHATBITS.customMessageValue = nil
				CHATBITS.customMessageChannelValue = nil
				CHATBITS.editIndex = nil
				CHATBITS.PopulateWindow()
			end
		},
		[11] = {
			type = "checkbox",
			name = strings.toggleWindow,
			tooltip = strings.toggleWindowTooltip,
			default = true,
			getFunc = function() 
				return CHATBITS.savedVariables.window.hidden
			end,
			setFunc = function(on) 
				CHATBITS.savedVariables.window.hidden = not CHATBITS.savedVariables.window.hidden
				CHATBITS.RestoreWindow()
			end
		}
	}
	LibAddonMenu2:RegisterOptionControls(CHATBITS.name, optionsData)
end

-- Create this addon's controls in Main Game Menu > Controls
function CHATBITS.CreateControls()
	for i = 1, 9 do
		ZO_CreateStringId("SI_BINDING_NAME_CHATBIT_KEYBIND_" .. i, CHATBITS.localization.controls.shortcut .. i)
	end
end

function CHATBITS.PostMessage(i)
	if CHATBITS.savedVariables.data[i] then			-- there could be a keybind, but no message
		CHAT_SYSTEM:StartTextEntry(CHATBITS.savedVariables.data[i].message, CHATBITS.savedVariables.data[i].channel)
	end
end

function CHATBITS.OnKeybind(i)
	CHATBITS.PostMessage(i)
end

-- Creating the buttons in the addon's window
function CHATBITS.PopulateWindow()
	for i, v in ipairs(CHATBITS.savedVariables.data) do
		local index = i									-- i is not defined inside the loop, postmessage would post the wrong message
		local b
		if not _G["ChatBitsShortcut" .. i] then
			b = CreateControlFromVirtual("ChatBitsShortcut", ChatBitsWindow, "ChatBitsVirtualButton", i)
		else
			b = WINDOW_MANAGER:GetControlByName("ChatBitsShortcut", i)
		end
		b:SetSimpleAnchorParent(5, (i - 1) * 20 + 5)
		b:SetText(v.title)
		b:SetHandler("OnMouseDown", function(self, mouseButton, upInside, shift, ctrl, alt, command)
			CHATBITS.PostMessage(index)
		end, CHATBITS.name)
		b:SetHandler("OnMouseEnter", function(self, mouseButton, upInside, shift, ctrl, alt, command)
			-- TODO : tooltip
		end, CHATBITS.name)
	end
end

-- Restore the addon's window position from saved variables when loading the addon
-- except on first launch
function CHATBITS.RestoreWindow()
	if CHATBITS.savedVariables.window then
		ChatBitsWindow:ClearAnchors()
		ChatBitsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CHATBITS.savedVariables.window.x, CHATBITS.savedVariables.window.y)
		ChatBitsWindow:SetHidden(CHATBITS.savedVariables.window.hidden)
	else
		CHATBITS.SaveWindowPosition()
	end
end

-- Save the addon's window position
function CHATBITS.SaveWindowPosition()
	local x, y = ChatBitsWindow:GetScreenRect()
	CHATBITS.savedVariables.window.x = x
	CHATBITS.savedVariables.window.y = y
end

-- Called by the framework when the user stops moving the addon's window
-- We save its position
function ChatBitsOnMoveStop()
	CHATBITS.SaveWindowPosition()
end

-- Initializating the addon
function CHATBITS.OnAddOnLoaded(event, addonName)
	if addonName == CHATBITS.name then
		CHATBITS.savedVariables = ZO_SavedVars:NewAccountWide("ChatBitsSavedVariables", CHATBITS.variableVersion, nil, CHATBITS.defaults)
		CHATBITS.RestoreWindow()
		CHATBITS.clientLanguage = GetCVar("language.2") or ""
		CHATBITS.CreateControls()
		CHATBITS.CreateSettingsPanel()
		CHATBITS.PopulateWindow()
    	EVENT_MANAGER:UnregisterForEvent(CHATBITS.name, EVENT_ADD_ON_LOADED)
		EVENT_MANAGER:RegisterForEvent(CHATBITS.name, EVENT_ACTIVITY_COMPLETE, CHATBITS.OnACtivityComplete)
		EVENT_MANAGER:RegisterForEvent(CHATBITS.name, EVENT_ZONE_CHANNEL_CHANGED, CHATBITS.OnZoneChannelChanged)
	end
end

-- TODO : harcoded. add a dropdown to choose the event / channel combo.
-- Send a message when a dungeon is finished
function CHATBITS.OnACtivityComplete(event, addonName)
	d("activity")
	if IsUnitInDungeon("player") then
		CHATBITS.PostMessage(2)
	end
end

-- TODO : harcoded. add a dropdown to choose the event / channel combo.
-- Send a message when a dungeon is begun
function CHATBITS.OnZoneChannelChanged(event, addonName)
	d("zone")
	if IsUnitInDungeon("player") then
		CHATBITS.PostMessage(1)
	end
end

EVENT_MANAGER:RegisterForEvent(CHATBITS.name, EVENT_ADD_ON_LOADED, CHATBITS.OnAddOnLoaded)