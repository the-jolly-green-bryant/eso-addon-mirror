-- PBS_QUEST_TRACKER_FONT_CHANGER is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_QUEST_TRACKER_FONT_CHANGER then
	return
end

local addon = PBS_QUEST_TRACKER_FONT_CHANGER

local lookup = {
	faces = {},
	faceByAlias = {},
	styles = {},
	styleByToken = {},
}

-- Builds the two dropdown lists.
--
-- Both sections offer the same faces and outlines, so the lists are built once and shared;
-- only the stored value differs per section. Faces are aliases, never resolved paths, so the
-- client can pick a face that draws the current language. Styles are descriptor tokens
-- ("thick-outline"), not FONT_STYLE_* numbers: a LabelControl's SetFont parses the style out
-- of the descriptor string.
local function BuildLookups()
	for _, face in ipairs(addon.faces) do
		local entry = { name = GetString(_G[face.stringId]), data = face.alias }
		lookup.faces[#lookup.faces + 1] = entry
		lookup.faceByAlias[face.alias] = entry
	end

	for _, style in ipairs(addon.styles) do
		local entry = { name = GetString(_G[style.stringId]), data = style.token }
		lookup.styles[#lookup.styles + 1] = entry
		lookup.styleByToken[style.token] = entry
	end
end

-- The two trackers are different pieces of UI that happen to sit one above the other, so the
-- panel says so rather than running eleven rows together. ST_SECTION draws a real divider
-- with a heading; older copies of the library only have ST_LABEL, and the heading text reads
-- as a heading either way.
local function AddHeading(settings, LibHarvensAddonSettings, stringId)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SECTION or LibHarvensAddonSettings.ST_LABEL,
			label = GetString(_G[stringId])
		}
	)
end

-- Every section gets the same shape: what it is, a switch, one size slider per font the game
-- uses there, then the typeface and outline that apply to all of them.
local function AddSection(self, settings, LibHarvensAddonSettings, section)
	AddHeading(settings, LibHarvensAddonSettings, section.headingId)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(_G[section.noteId])
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(_G[section.enabledId]),
			tooltip = GetString(_G[section.enabledTooltipId]),
			default = self.sectionDefaults.enabled,
			getFunction = function()
				return self:Settings(section.key).enabled
			end,
			setFunction = function(value)
				self:Settings(section.key).enabled = value
				self:Refresh(section.key)
			end
		}
	)

	-- One slider per font the game actually uses in this tracker.
	--
	-- The quest tracker gives its three kinds of text three different sizes -- 27 / 22 / 34 in
	-- gamepad mode -- and the house tracker gives the house name one size and everything under
	-- it another. A single slider per tracker would flatten a hierarchy that is there on
	-- purpose. Each slider starts at the size the game itself draws that part at, measured off
	-- a real label, so leaving them all alone leaves the tracker exactly as it was.
	for _, role in ipairs(section.roles) do
		local roleKey = role.key
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(_G[role.stringId]),
				tooltip = GetString(_G[role.tooltipId]),
				min = self.MIN_SIZE,
				max = self.MAX_SIZE,
				step = 1,
				default = self:DefaultSize(roleKey),
				format = "%d",
				unit = "",
				getFunction = function()
					return self:SizeFor(roleKey)
				end,
				setFunction = function(value)
					self:SetSizeFor(roleKey, value)
					self:Settings(section.key).enabled = true
					self:Refresh(section.key)
				end
			}
		)
	end

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(_G[section.faceId]),
			tooltip = GetString(_G[section.faceTooltipId]),
			items = lookup.faces,
			default = lookup.faceByAlias[""].name,
			getFunction = function()
				local entry = lookup.faceByAlias[self:Settings(section.key).face or ""]
				return entry and entry.name or lookup.faceByAlias[""].name
			end,
			setFunction = function(combobox, name, item)
				local sectionSettings = self:Settings(section.key)
				sectionSettings.face = item.data
				sectionSettings.enabled = true
				self:Refresh(section.key)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(_G[section.styleId]),
			tooltip = GetString(_G[section.styleTooltipId]),
			items = lookup.styles,
			default = lookup.styleByToken[addon.STYLE_INHERIT].name,
			getFunction = function()
				-- Never returns nil: a dropdown handed nil has nothing to select and falls
				-- back to showing its first item, which reads as the setting having reset
				-- itself.
				local entry = lookup.styleByToken[self:Settings(section.key).style or addon.STYLE_INHERIT]
					or lookup.styleByToken[addon.STYLE_INHERIT]
				return entry and entry.name
			end,
			setFunction = function(combobox, name, item)
				local sectionSettings = self:Settings(section.key)
				sectionSettings.style = item.data
				sectionSettings.enabled = true
				self:Refresh(section.key)
			end
		}
	)
end

function addon:InitSettings()
	local LibHarvensAddonSettings = LibHarvensAddonSettings
	if not LibHarvensAddonSettings then
		return
	end

	BuildLookups()

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
			label = GetString(SI_PBSQTFC_EXPLANATION)
		}
	)

	for _, section in ipairs(self.sections) do
		AddSection(self, settings, LibHarvensAddonSettings, section)
	end

	AddHeading(settings, LibHarvensAddonSettings, "SI_PBSQTFC_SECTION_GENERAL")

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSQTFC_RESET),
			tooltip = GetString(SI_PBSQTFC_RESET_TOOLTIP),
			buttonText = GetString(SI_PBSQTFC_RESET_BUTTON),
			clickHandler = function()
				self:ResetToDefaults()
				-- The rows were built from the old values, so they have to be told to
				-- re-read them or the panel keeps showing what was just discarded.
				if settings.UpdateControls then
					settings:UpdateControls()
				end
			end
		}
	)

	-- Whether either tracker is on screen at all is the game's own setting. An add-on can read
	-- those but the panel is the right place to change them.
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(SI_PBSQTFC_GAME_SETTINGS_HINT)
		}
	)
end
