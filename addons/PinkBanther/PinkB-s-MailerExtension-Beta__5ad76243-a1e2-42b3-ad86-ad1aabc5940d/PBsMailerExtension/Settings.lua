-- PB's MailerExtension -- the settings panel
--
-- Two numbers, and both of them are also on /pbmail max. The panel is the comfortable way to
-- move them; the command is the exact way, and on a client without the settings library it is
-- the only way -- which is why nothing here is required for anything to work.
--
-- Neither slider deletes anything. See Box:SetMax for why: a panel that acted on every step of
-- a drag would trim the sent box at 90, 80, 70 on the way down to 10, and one notch too far
-- would be letters gone for good. A lowered limit takes effect the next time the box takes a
-- letter.
--
-- PBS_MAILER_EXTENSION is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_MAILER_EXTENSION then
	return
end

local addon = PBS_MAILER_EXTENSION

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

local function AddLimitSlider(settings, LibHarvensAddonSettings, box, label, tooltip, default)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = label,
			tooltip = tooltip,
			min = addon.LIMIT_STEP,
			max = addon.LIMIT_CEILING,
			step = addon.LIMIT_STEP,
			default = default,
			format = "%d",
			getFunction = function()
				return box:Max()
			end,
			setFunction = function(value)
				box:SetMax(value)
			end
		}
	)
end

function addon:InitSettings()
	local LibHarvensAddonSettings = LibHarvensAddonSettings
	if not LibHarvensAddonSettings then
		return false
	end

	local settings = LibHarvensAddonSettings:AddAddon(self.title)
	if not settings then
		return false
	end

	self.settingsControls = settings
	settings.allowDefaults = true
	settings.author = self.author
	settings.version = self.version

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(SI_PBSMX_EXPLANATION)
		}
	)

	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSMX_SECTION_LIMITS))

	AddLimitSlider(settings, LibHarvensAddonSettings, self.drafts,
		GetString(SI_PBSMX_LIMIT_DRAFTS), GetString(SI_PBSMX_LIMIT_DRAFTS_TOOLTIP),
		self.DEFAULT_MAX_DRAFTS)

	AddLimitSlider(settings, LibHarvensAddonSettings, self.sent,
		GetString(SI_PBSMX_LIMIT_SENT), GetString(SI_PBSMX_LIMIT_SENT_TOOLTIP),
		self.DEFAULT_MAX_SENT)

	return true
end
