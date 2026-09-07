-- PBS_CHAT_FILTER is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_CHAT_FILTER then
	return
end

local addon = PBS_CHAT_FILTER

-- The panel is a switchboard: one section per guild, two switches in it. There is nothing to
-- tune and nothing to type, which is the point -- on a console the chat command exists for
-- the cases the panel cannot cover (a guild joined since login), not the other way round.
--
-- InitSettings is called from EVENT_PLAYER_ACTIVATED rather than at load, because these rows
-- carry fixed labels and the labels are guild names. See OnPlayerActivated in Main.lua.

local function AddHeading(settings, LibHarvensAddonSettings, label)
	settings:AddSetting(
		{
			-- ST_SECTION draws a real divider with a heading; older copies of the library only
			-- have ST_LABEL, and the heading text reads as a heading either way.
			type = LibHarvensAddonSettings.ST_SECTION or LibHarvensAddonSettings.ST_LABEL,
			label = label
		}
	)
end

-- One guild. guildId is captured, not the index: the switches have to keep meaning the same
-- guild for the life of the panel even if the guild list reorders under it.
local function AddGuild(self, settings, LibHarvensAddonSettings, guild)
	AddHeading(settings, LibHarvensAddonSettings,
		string.format(GetString(SI_PBSCF_GUILD_HEADING), guild.guildIndex, guild.name))

	local guildId = guild.guildId

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCF_ROW_GUILD),
			tooltip = GetString(SI_PBSCF_ROW_GUILD_TOOLTIP),
			default = true,
			getFunction = function()
				return self:IsChannelShown(guildId, false)
			end,
			setFunction = function(value)
				self:SetChannelShown(guildId, false, value)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCF_ROW_OFFICER),
			tooltip = GetString(SI_PBSCF_ROW_OFFICER_TOOLTIP),
			default = true,
			getFunction = function()
				return self:IsChannelShown(guildId, true)
			end,
			setFunction = function(value)
				self:SetChannelShown(guildId, true, value)
			end
		}
	)
end

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

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(SI_PBSCF_EXPLANATION)
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCF_ENABLED),
			tooltip = GetString(SI_PBSCF_ENABLED_TOOLTIP),
			default = self.DEFAULTS.enabled,
			getFunction = function()
				return self.sv.enabled
			end,
			setFunction = function(value)
				self.sv.enabled = value
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCF_KEEP_OWN),
			tooltip = GetString(SI_PBSCF_KEEP_OWN_TOOLTIP),
			default = self.DEFAULTS.keepOwn,
			getFunction = function()
				return self.sv.keepOwn
			end,
			setFunction = function(value)
				self.sv.keepOwn = value
			end
		}
	)

	-- No "Your guilds" heading over the guild list: each guild already opens with its own
	-- heading, so that one would be a section with nothing under it -- an empty collapsible
	-- row in the panel. The heading is only worth having in the branch that has something to
	-- put under it, which is the one where there are no guilds to head.
	local guilds = self:GuildList()
	if #guilds == 0 then
		AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSCF_SECTION_GUILDS))
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_LABEL,
				label = GetString(SI_PBSCF_NO_GUILDS_NOTE)
			}
		)
	else
		for _, guild in ipairs(guilds) do
			AddGuild(self, settings, LibHarvensAddonSettings, guild)
		end
	end

	-- Recruitment sits after the guild list because it is about the channels the guild list
	-- does not cover, and reads better once you have seen what the guild switches are.
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSCF_SECTION_RECRUIT))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(SI_PBSCF_SECTION_RECRUIT_NOTE)
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCF_RECRUIT),
			tooltip = GetString(SI_PBSCF_RECRUIT_TOOLTIP),
			default = self.DEFAULTS.recruit,
			getFunction = function()
				return self.sv.recruit
			end,
			setFunction = function(value)
				self.sv.recruit = value
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCF_RECRUIT_WHISPER),
			tooltip = GetString(SI_PBSCF_RECRUIT_WHISPER_TOOLTIP),
			default = self.DEFAULTS.recruitWhisper,
			getFunction = function()
				return self.sv.recruitWhisper
			end,
			setFunction = function(value)
				self.sv.recruitWhisper = value
			end
		}
	)

	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSCF_SECTION_GENERAL))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSCF_RESET),
			tooltip = GetString(SI_PBSCF_RESET_TOOLTIP),
			buttonText = GetString(SI_PBSCF_RESET_BUTTON),
			clickHandler = function()
				self:ResetSettings()
				-- The rows were built from the old values, so they have to be told to re-read
				-- them or the panel keeps showing what was just discarded.
				self:RefreshPanel()
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(SI_PBSCF_RELOAD_HINT)
		}
	)
end
