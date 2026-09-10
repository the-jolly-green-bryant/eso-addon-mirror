-- PBS_CHAT_ASSISTANT is nil if Main.lua bailed out early (the add-on was already loaded).
if not PBS_CHAT_ASSISTANT then
	return
end

local addon = PBS_CHAT_ASSISTANT

-- The wait, and nothing else.
--
-- It is the only setting a player has any reason to reach for. Everything else -- arming Enter,
-- releasing the keyboard again, the arrow keys, the focus watcher, the log -- is either on
-- because it should be, or a diagnostic, and a panel of switches that are already right is just
-- somewhere to make a mistake. The slash commands still reach all of them.
--
-- The wait is different because the right value is a property of the machine rather than of the
-- add-on. Too short and the chat box opens without the console's input screen following, which
-- is the one failure that looks like the add-on is broken rather than mistuned.
function addon:InitSettings()
	local LibHarvensAddonSettings = LibHarvensAddonSettings
	if not LibHarvensAddonSettings then
		return
	end

	local settings = LibHarvensAddonSettings:AddAddon(self.title)
	if not settings then
		return
	end

	self.settingsControls = settings
	settings.allowDefaults = true
	settings.author = self.author
	settings.version = self.version

	-- L2+L3 on the HUD. Reaches the same setting as /pbchat hudchannel.
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCHATASSISTANT_HUDCHANNEL),
			tooltip = GetString(SI_PBSCHATASSISTANT_HUDCHANNEL_TOOLTIP),
			default = true,
			getFunction = function()
				return self.sv.hudChannelEnabled
			end,
			setFunction = function(value)
				self.sv.hudChannelEnabled = value
			end
		}
	)

	-- Which channel a session starts on.
	--
	-- The item list is rebuilt whenever this panel is opened rather than fixed when the add-on
	-- loads. At load the player may not be in a guild yet as far as the client is concerned, and a
	-- guild channel is exactly what someone wants to default to; built then, the list would offer
	-- slash commands instead of guild names, or miss the channels entirely.
	local channelItems = {}
	local NO_DEFAULT = GetString(SI_PBSCHATASSISTANT_DEFAULT_CHANNEL_NONE)

	local function DefaultChannelName()
		local wanted = self.sv.defaultChannel or 0
		if wanted == 0 then
			return NO_DEFAULT
		end
		return self:GetChannelDisplayName(wanted)
	end

	local function RebuildChannelItems()
		ZO_ClearNumericallyIndexedTable(channelItems)
		channelItems[1] = { name = NO_DEFAULT, data = { value = 0 } }
		for _, channel in ipairs(self:GetSelectableChannels()) do
			channelItems[#channelItems + 1] = {
				name = self:GetChannelDisplayName(channel.id),
				data = { value = channel.id },
			}
		end
	end

	RebuildChannelItems()

	CALLBACK_MANAGER:RegisterCallback(
		"LibHarvensAddonSettings_AddonSelected",
		function(_, addonSettings)
			if addonSettings == settings then
				RebuildChannelItems()
			end
		end
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSCHATASSISTANT_DEFAULT_CHANNEL),
			tooltip = GetString(SI_PBSCHATASSISTANT_DEFAULT_CHANNEL_TOOLTIP),
			items = channelItems,
			default = NO_DEFAULT,
			getFunction = DefaultChannelName,
			setFunction = function(combobox, name, item)
				self.sv.defaultChannel = item.data.value
				-- Applied at once as well as at login, so choosing it does something visible
				-- rather than only mattering next time.
				self:ApplyDefaultChannel()
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_PBSCHATASSISTANT_DELAY),
			tooltip = GetString(SI_PBSCHATASSISTANT_DELAY_TOOLTIP),
			min = 0,
			max = 2000,
			step = 50,
			default = 100,
			format = "%d",
			unit = "ms",
			getFunction = function()
				return self.sv.delayMs
			end,
			setFunction = function(value)
				self.sv.delayMs = value
			end
		}
	)
end
