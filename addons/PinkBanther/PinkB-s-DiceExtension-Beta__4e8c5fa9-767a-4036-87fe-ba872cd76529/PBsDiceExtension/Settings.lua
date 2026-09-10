-- PB's DiceExtension -- the settings panel
--
-- Two sliders, three checkboxes and two buttons, in the order somebody actually thinks in:
-- what am I rolling, what do I want to see, and who else sees it.
--
-- There is deliberately no row that displays the last roll. The library builds its rows once
-- and a label cannot be rewritten afterwards, so such a row would show one roll for ever. The
-- Roll button puts the result in chat instead, where it is timestamped by the chat log and
-- sits next to every other roll.
--
-- PBS_DICE is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_DICE then
	return
end

local addon = PBS_DICE

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
			label = GetString(SI_PBSDICE_EXPLANATION)
		}
	)

	-- ---- the dice --------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSDICE_SECTION_DICE))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_PBSDICE_COUNT),
			tooltip = GetString(SI_PBSDICE_COUNT_TOOLTIP),
			min = self.LIMITS.minCount,
			max = self.LIMITS.maxCount,
			step = 1,
			default = self.DEFAULTS.count,
			format = "%d",
			getFunction = function()
				return self:Count()
			end,
			setFunction = function(value)
				self:SetCount(value)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_PBSDICE_SIDES),
			tooltip = GetString(SI_PBSDICE_SIDES_TOOLTIP),
			min = self.LIMITS.minSides,
			max = self.LIMITS.maxSides,
			-- One-sided steps over a thousand values is a long way on a stick, but a d20 has
			-- to be reachable and so does a d999, and a slider that skips is a slider that
			-- cannot land on 20. /pbdice sides 20 is there for anyone who would rather type it.
			step = 1,
			default = self.DEFAULTS.sides,
			format = "%d",
			getFunction = function()
				return self:Sides()
			end,
			setFunction = function(value)
				self:SetSides(value)
			end
		}
	)

	-- ---- how you roll them -----------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSDICE_SECTION_HOW))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSDICE_KEYBIND),
			tooltip = GetString(SI_PBSDICE_KEYBIND_TOOLTIP),
			default = self.DEFAULTS.chatKeybind,
			getFunction = function()
				return self:ChatKeybind()
			end,
			setFunction = function(value)
				-- Nothing to register or unregister: the row is in the chat screen's keybind
				-- descriptor for good, and the strip asks this same question every time it
				-- draws the button. Off hides it, and a hidden button's keybind does nothing.
				self:SetChatKeybind(value)
			end
		}
	)

	-- ---- what is shown ---------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSDICE_SECTION_OUTPUT))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSDICE_EACH),
			tooltip = GetString(SI_PBSDICE_EACH_TOOLTIP),
			default = self.DEFAULTS.showEach,
			getFunction = function()
				return self:ShowEach()
			end,
			setFunction = function(value)
				self:SetShowEach(value)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSDICE_TAG),
			tooltip = GetString(SI_PBSDICE_TAG_TOOLTIP),
			default = self.DEFAULTS.showLocalTag,
			getFunction = function()
				return self:ShowLocalTag()
			end,
			setFunction = function(value)
				self:SetShowLocalTag(value)
			end
		}
	)

	-- ---- the real thing --------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSDICE_SECTION_REAL))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSDICE_PREFILL),
			tooltip = GetString(SI_PBSDICE_PREFILL_TOOLTIP),
			default = self.DEFAULTS.prefill,
			getFunction = function()
				return self:Prefill()
			end,
			setFunction = function(value)
				self:SetPrefill(value)
				-- Turning it on has no visible effect until the chat screen is next opened, so
				-- the command it will put there is said now instead of being a surprise later.
				if value then
					self.Print(addon.Format(SI_PBSDICE_REPLY_PREFILL_HINT,
						(self.dice:CommandText(self:Count(), self:Sides()))))
				end
			end
		}
	)

	-- ---- now -------------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSDICE_SECTION_NOW))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSDICE_ROLL_NOW),
			tooltip = GetString(SI_PBSDICE_ROLL_NOW_TOOLTIP),
			buttonText = GetString(SI_PBSDICE_ROLL_NOW_BUTTON),
			clickHandler = function()
				self:RollAndPrint()
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSDICE_RESET),
			tooltip = GetString(SI_PBSDICE_RESET_TOOLTIP),
			buttonText = GetString(SI_PBSDICE_RESET_BUTTON),
			clickHandler = function()
				self:Reset()
				self:RefreshPanel()
			end
		}
	)
end
