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
