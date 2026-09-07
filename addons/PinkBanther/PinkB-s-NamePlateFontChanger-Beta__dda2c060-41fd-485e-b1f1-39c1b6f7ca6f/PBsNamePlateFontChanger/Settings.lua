-- PBS_NAMEPLATE_CHANGER is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_NAMEPLATE_CHANGER then
	return
end

local addon = PBS_NAMEPLATE_CHANGER

local lookup = {
	faces = {},
	faceByAlias = {},
	faceByName = {},
	styles = {},
	styleByValue = {},
	styleByName = {},
}

-- Builds the two dropdown lists.
--
-- Faces are aliases, never resolved paths, so the client can pick a face that draws the
-- current language. Styles are looked up in _G rather than hardcoded: ESOUIDocumentation
-- lists FontStyle alphabetically, not by value, so the numbers are only trustworthy when
-- read from the client itself. Anything missing from this client is dropped from the list
-- rather than offered and then failing.
local function BuildLookups()
	for _, face in ipairs(addon.faces) do
		local entry = { name = GetString(_G[face.stringId]), data = face.alias }
		lookup.faces[#lookup.faces + 1] = entry
		lookup.faceByAlias[face.alias] = entry
		lookup.faceByName[entry.name] = entry
	end

	for _, style in ipairs(addon.styles) do
		-- The default entry carries the sentinel, not nil, so every item in this list has a
		-- value that can be stored and looked back up.
		local value = style.constant and _G[style.constant] or addon.STYLE_INHERIT
		if style.constant == nil or type(value) == "number" then
			local entry = { name = GetString(_G[style.stringId]), data = value }
			lookup.styles[#lookup.styles + 1] = entry
			lookup.styleByName[entry.name] = entry
			lookup.styleByValue[value] = entry
			if value == addon.STYLE_INHERIT then
				lookup.defaultStyleEntry = entry
			end
		end
	end
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

	-- Said in the panel, not just in the readme: the layout of the nametag is not something
	-- this add-on declined to do, it is something the game does not expose. Anyone who
	-- installs this expecting three centred lines should find that out here.
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(SI_PBSNPC_EXPLANATION)
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSNPC_ENABLED),
			tooltip = GetString(SI_PBSNPC_ENABLED_TOOLTIP),
			default = self.accountDefaults.enabled,
			getFunction = function()
				return self.account.enabled
			end,
			setFunction = function(value)
				self.account.enabled = value
				if value then
					self:Apply()
				else
					self:RestoreOriginals()
				end
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_PBSNPC_SIZE),
			tooltip = GetString(SI_PBSNPC_SIZE_TOOLTIP),
			min = self.MIN_SIZE,
			max = self.MAX_SIZE,
			step = 1,
			default = self.accountDefaults.size,
			format = "%d",
			unit = "",
			getFunction = function()
				return self.account.size or self.DEFAULT_SIZE
			end,
			setFunction = function(value)
				self.account.size = value
				self.account.enabled = true
				self:Apply()
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSNPC_FACE),
			tooltip = GetString(SI_PBSNPC_FACE_TOOLTIP),
			items = lookup.faces,
			default = lookup.faceByAlias[""].name,
			getFunction = function()
				local entry = lookup.faceByAlias[self.account.face or ""]
				return entry and entry.name or lookup.faceByAlias[""].name
			end,
			setFunction = function(combobox, name, item)
				self.account.face = item.data
				self.account.enabled = true
				self:Apply()
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSNPC_STYLE),
			tooltip = GetString(SI_PBSNPC_STYLE_TOOLTIP),
			items = lookup.styles,
			default = lookup.defaultStyleEntry and lookup.defaultStyleEntry.name,
			getFunction = function()
				-- Never returns nil: a dropdown handed nil has nothing to select and falls
				-- back to showing its first item, which is what made this setting look like
				-- it had reset itself.
				local entry = lookup.styleByValue[self.account.style] or lookup.defaultStyleEntry
				return entry and entry.name
			end,
			setFunction = function(combobox, name, item)
				self.account.style = item.data
				self.account.enabled = true
				self:Apply()
			end
		}
	)

	-- Opt-in to the behaviour that was measured to kill the add-on on console.
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSNPC_REAPPLY_FACE),
			tooltip = GetString(SI_PBSNPC_REAPPLY_FACE_TOOLTIP),
			default = self.accountDefaults.reapplyFace,
			getFunction = function()
				return self.account.reapplyFace
			end,
			setFunction = function(value)
				self.account.reapplyFace = value
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSNPC_RESET),
			tooltip = GetString(SI_PBSNPC_RESET_TOOLTIP),
			buttonText = GetString(SI_PBSNPC_RESET_BUTTON),
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

	-- The game's own Nameplates settings decide whether the title line and the guild line
	-- appear at all. SetSetting is private, so this add-on can read them but never change
	-- them -- the panel points at where they live instead.
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = GetString(SI_PBSNPC_GAME_SETTINGS_HINT)
		}
	)
end
