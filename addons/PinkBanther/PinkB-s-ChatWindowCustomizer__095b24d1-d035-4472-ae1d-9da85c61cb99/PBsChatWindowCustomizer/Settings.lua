-- PBS_CHAT_WINDOW_CUSTOMIZER is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_CHAT_WINDOW_CUSTOMIZER then
	return
end

local addon = PBS_CHAT_WINDOW_CUSTOMIZER

-- Position and size move in fives: a d-pad press that moves the window one unit at a time would
-- take a minute to cross the screen, and nobody can see the difference between 212 and 215.
local LAYOUT_STEP = 5

local function AddHeading(settings, LibHarvensAddonSettings, stringId)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SECTION or LibHarvensAddonSettings.ST_LABEL,
			label = GetString(_G[stringId])
		}
	)
end

local function AddLabel(settings, LibHarvensAddonSettings, stringId)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(_G[stringId])
		}
	)
end

-- A slider over one layout value. Every one of them switches the add-on back on when moved:
-- moving a slider and seeing nothing happen because of a switch further up reads as a bug.
local function AddLayoutSlider(self, settings, LibHarvensAddonSettings, key, stringId, tooltipId, min, max)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(_G[stringId]),
			tooltip = GetString(_G[tooltipId]),
			min = min,
			max = max,
			step = LAYOUT_STEP,
			default = self:GameLayout()[key],
			format = "%d",
			unit = "",
			getFunction = function()
				return self:Layout()[key]
			end,
			setFunction = function(value)
				-- The corner is saved with the first value moved, so the distances stay tied to
				-- the corner they were measured from.
				self:SetLayoutValue("corner", self:Layout().corner)
				self:SetLayoutValue(key, addon.Round(value))
				self:Account().enabled = true
				self:Refresh()
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
	self.settingsPanel = settings
	settings.allowDefaults = true
	settings.author = self.author
	settings.version = self.version

	-- The preview follows the panel -- see "Following the settings panel" in Preview.lua for why
	-- this callback alone is not enough on console. Registered on the client's callback manager,
	-- beside everyone else's.
	CALLBACK_MANAGER:RegisterCallback(
		"LibHarvensAddonSettings_AddonSelected",
		function(_, addonSettings)
			if self.preview then
				self.preview:OnAddonSelected(addonSettings)
			end
		end
	)

	-- The sliders' ranges are the screen. GuiRoot is the space the anchor offsets are measured
	-- in, so its size is the furthest any distance or size can usefully go.
	local rootWidth, rootHeight = self:RootSize()
	rootWidth, rootHeight = addon.Round(rootWidth), addon.Round(rootHeight)

	local cornerItems = {}
	local cornerItemByKey = {}
	for _, corner in ipairs(self.corners) do
		local item = { name = GetString(_G[corner.stringId]), data = corner.key }
		cornerItems[#cornerItems + 1] = item
		cornerItemByKey[corner.key] = item
	end

	AddLabel(settings, LibHarvensAddonSettings, "SI_PBSCWC_EXPLANATION")

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCWC_ENABLED),
			tooltip = GetString(SI_PBSCWC_ENABLED_TOOLTIP),
			default = true,
			getFunction = function()
				return self:Account().enabled
			end,
			setFunction = function(value)
				self:Account().enabled = value
				self:Refresh()
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCWC_PREVIEW),
			tooltip = GetString(SI_PBSCWC_PREVIEW_TOOLTIP),
			default = true,
			getFunction = function()
				return self:Account().preview
			end,
			setFunction = function(value)
				self:Account().preview = value
				if self.preview then
					self.preview:SetPanelOpen(true)
				end
			end
		}
	)

	-- ---- Position ------------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, "SI_PBSCWC_SECTION_POSITION")

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSCWC_CORNER),
			tooltip = GetString(SI_PBSCWC_CORNER_TOOLTIP),
			items = cornerItems,
			default = cornerItemByKey[self:GameLayout().corner].name,
			getFunction = function()
				-- Never nil: a dropdown handed nil falls back to showing its first item, which
				-- reads as the setting having reset itself.
				local item = cornerItemByKey[self:Layout().corner] or cornerItemByKey[self.GAME_LAYOUT_FALLBACK.corner]
				return item.name
			end,
			setFunction = function(combobox, name, item)
				self:SetCorner(item.data)
				self:Refresh()
				-- The distances were just re-expressed from the new corner; the sliders have to
				-- be told to re-read them.
				if settings.UpdateControls then
					settings:UpdateControls()
				end
			end
		}
	)

	AddLayoutSlider(self, settings, LibHarvensAddonSettings, "x",
		"SI_PBSCWC_POSITION_X", "SI_PBSCWC_POSITION_X_TOOLTIP", 0, rootWidth)
	AddLayoutSlider(self, settings, LibHarvensAddonSettings, "y",
		"SI_PBSCWC_POSITION_Y", "SI_PBSCWC_POSITION_Y_TOOLTIP", 0, rootHeight)

	-- ---- Size ----------------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, "SI_PBSCWC_SECTION_SIZE")

	AddLayoutSlider(self, settings, LibHarvensAddonSettings, "width",
		"SI_PBSCWC_WIDTH", "SI_PBSCWC_WIDTH_TOOLTIP", self.MIN_WIDTH, rootWidth)
	AddLayoutSlider(self, settings, LibHarvensAddonSettings, "height",
		"SI_PBSCWC_HEIGHT", "SI_PBSCWC_HEIGHT_TOOLTIP", self.MIN_HEIGHT, rootHeight)

	-- ---- Text ----------------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, "SI_PBSCWC_SECTION_TEXT")

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_PBSCWC_FONT_SIZE),
			tooltip = GetString(SI_PBSCWC_FONT_SIZE_TOOLTIP),
			min = self.MIN_FONT_SIZE,
			max = self.MAX_FONT_SIZE,
			step = 1,
			default = self:DefaultFontSize(),
			format = "%d",
			unit = "",
			getFunction = function()
				return self:FontSize()
			end,
			setFunction = function(value)
				self:SetFontSize(value)
				self:Account().enabled = true
				self:Refresh()
			end
		}
	)

	-- ---- Both ----------------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, "SI_PBSCWC_SECTION_GENERAL")

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSCWC_RESET),
			tooltip = GetString(SI_PBSCWC_RESET_TOOLTIP),
			buttonText = GetString(SI_PBSCWC_RESET_BUTTON),
			clickHandler = function()
				self:ResetToDefaults()
				-- The rows were built from the old values, so they have to be told to re-read
				-- them or the panel keeps showing what was just discarded.
				if settings.UpdateControls then
					settings:UpdateControls()
				end
			end
		}
	)

	AddLabel(settings, LibHarvensAddonSettings, "SI_PBSCWC_GAME_SETTINGS_HINT")
end
