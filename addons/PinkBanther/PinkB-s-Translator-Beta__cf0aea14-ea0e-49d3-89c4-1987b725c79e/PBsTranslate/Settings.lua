-- PBS_TRANSLATE is nil if Main.lua bailed out early (engine missing or already loaded).
if not PBS_TRANSLATE then
	return
end

local addon = PBS_TRANSLATE

-- Translation controls, and the player's own dictionary: two text rows, a part of speech, a
-- register button, and a list of the added words with a remove button. The chat commands
-- (/pbtr add, remove, list) do the same thing.

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

	local function Checkbox(key, label, tooltip)
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(label),
			tooltip = GetString(tooltip),
			default = self.DEFAULTS[key],
			getFunction = function()
				return self.sv[key]
			end,
			setFunction = function(value)
				self.sv[key] = value
			end,
		})
	end

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_LABEL,
		label = GetString(SI_PBSTR_EXPLANATION),
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = GetString(SI_PBSTR_ONLY),
		tooltip = GetString(SI_PBSTR_ONLY_TOOLTIP),
		default = self.DEFAULTS.translationOnly,
		getFunction = function() return self.sv.translationOnly end,
		setFunction = function(value) self:SetTranslationOnly(value) end,
	})

	Checkbox("enabled", SI_PBSTR_ENABLED, SI_PBSTR_ENABLED_TOOLTIP)
	Checkbox("translateOwn", SI_PBSTR_OWN, SI_PBSTR_OWN_TOOLTIP)
	Checkbox("translateOthers", SI_PBSTR_OTHERS, SI_PBSTR_OTHERS_TOOLTIP)
	Checkbox("translateZone", SI_PBSTR_ZONE, SI_PBSTR_ZONE_TOOLTIP)

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_PBSTR_KNOWN),
		tooltip = GetString(SI_PBSTR_KNOWN_TOOLTIP),
		min = 0,
		max = 100,
		step = 5,
		format = "%d",
		unit = "%",
		default = self.DEFAULTS.minKnownPercent,
		getFunction = function()
			return self.sv.minKnownPercent
		end,
		setFunction = function(value)
			self.sv.minKnownPercent = value
		end,
	})

	if LibHarvensAddonSettings.ST_COLOR then
		settings:AddSetting({
			type = LibHarvensAddonSettings.ST_COLOR,
			label = GetString(SI_PBSTR_COLOR),
			tooltip = GetString(SI_PBSTR_COLOR_TOOLTIP),
			default = { self:GetTranslationRGB(self.DEFAULTS.color) },
			getFunction = function() return self:GetTranslationRGB() end,
			setFunction = function(r, g, b) self:SetTranslationRGB(r, g, b) end,
		})
	end

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_SECTION or LibHarvensAddonSettings.ST_LABEL,
		label = GetString(SI_PBSTR_SECTION_WORDS),
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_LABEL,
		label = string.format(GetString(SI_PBSTR_WORDS_NOTE), self.engine.entryCount or 0),
	})

	if LibHarvensAddonSettings.ST_EDIT and LibHarvensAddonSettings.ST_BUTTON and LibHarvensAddonSettings.ST_DROPDOWN then
		self:AddWordRows(settings, LibHarvensAddonSettings)
	end
end

-- The parts of speech offered in the panel, and how each is saved. Verbs and adjectives carry
-- the class the grammar conjugates by; the Japanese is typed in its dictionary form.
local WORD_KINDS = {
	{ name = SI_PBSTR_POS_X, prefix = "x:", suffix = "" },
	{ name = SI_PBSTR_POS_N, prefix = "n:", suffix = "" },
	{ name = SI_PBSTR_POS_GODAN, prefix = "v:", suffix = "/5" },
	{ name = SI_PBSTR_POS_ICHIDAN, prefix = "v:", suffix = "/1" },
	{ name = SI_PBSTR_POS_SURU, prefix = "v:", suffix = "/s" },
	{ name = SI_PBSTR_POS_AI, prefix = "a:", suffix = "/i" },
	{ name = SI_PBSTR_POS_ADJ_NA, prefix = "a:", suffix = "/na" },
}

function addon:AddWordRows(settings, LibHarvensAddonSettings)
	-- What has been typed but not registered yet. Not saved: it only has to last while the
	-- panel is open.
	local draft = { english = "", japanese = "", kind = 1, selected = nil, message = GetString(SI_PBSTR_WORD_HINT) }
	self.wordDraft = draft

	for _, kind in ipairs(WORD_KINDS) do
		kind.label = GetString(kind.name)
	end
	local kindItems = {}
	for index, kind in ipairs(WORD_KINDS) do
		kindItems[index] = { name = kind.label, data = index }
	end

	-- The edit row reports its text on Enter and again when it loses focus, so the setters only
	-- store; nothing happens until the button.
	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_EDIT,
		label = GetString(SI_PBSTR_WORD_ENGLISH),
		tooltip = GetString(SI_PBSTR_WORD_ENGLISH_TOOLTIP),
		maxChars = 80,
		ignoreDefault = true,
		getFunction = function() return draft.english end,
		setFunction = function(value) draft.english = type(value) == "string" and value or "" end,
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_EDIT,
		label = GetString(SI_PBSTR_WORD_JAPANESE),
		tooltip = GetString(SI_PBSTR_WORD_JAPANESE_TOOLTIP),
		maxChars = 80,
		ignoreDefault = true,
		getFunction = function() return draft.japanese end,
		setFunction = function(value) draft.japanese = type(value) == "string" and value or "" end,
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = GetString(SI_PBSTR_WORD_POS),
		tooltip = GetString(SI_PBSTR_WORD_POS_TOOLTIP),
		items = kindItems,
		ignoreDefault = true,
		getFunction = function() return WORD_KINDS[draft.kind].label end,
		setFunction = function(_, _, item)
			draft.kind = item and WORD_KINDS[item.data] and item.data or 1
		end,
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = GetString(SI_PBSTR_WORD_ADD),
		tooltip = GetString(SI_PBSTR_WORD_ADD_TOOLTIP),
		buttonText = GetString(SI_PBSTR_WORD_ADD),
		clickHandler = function()
			self:RegisterDraftWord()
		end,
	})

	-- Chat is hidden behind the menu, so the outcome of the buttons is shown here.
	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_LABEL,
		label = function() return draft.message end,
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = GetString(SI_PBSTR_WORD_LIST),
		tooltip = GetString(SI_PBSTR_WORD_LIST_TOOLTIP),
		-- A function, so the list is rebuilt each time the panel refreshes. No default: the
		-- library's reset indexes items as a table.
		items = function() return self:WordListItems() end,
		ignoreDefault = true,
		getFunction = function()
			local items = self:WordListItems()
			for _, item in ipairs(items) do
				if item.data == draft.selected then return item.name end
			end
			return items[1].name
		end,
		setFunction = function(_, _, item)
			draft.selected = item and item.data or nil
		end,
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = GetString(SI_PBSTR_WORD_REMOVE),
		tooltip = GetString(SI_PBSTR_WORD_REMOVE_TOOLTIP),
		buttonText = GetString(SI_PBSTR_WORD_REMOVE),
		clickHandler = function()
			self:RemoveSelectedWord()
		end,
	})
end

-- Never empty: the library selects an entry by name, so an empty list gets a placeholder.
function addon:WordListItems()
	local items = {}
	for _, english in ipairs(self:SortedUserWords()) do
		local value = self.sv.userWords[english]
		local japanese = value:gsub("^[A-Za-z]+:", ""):gsub("/.*$", "")
		items[#items + 1] = { name = english .. " = " .. japanese, data = english }
	end
	if #items == 0 then
		items[1] = { name = GetString(SI_PBSTR_REPLY_NO_WORDS), data = nil }
	end
	return items
end

function addon:RegisterDraftWord()
	local draft = self.wordDraft
	local japanese = self.engine.Trim(draft.japanese)
	-- / separates the fields of a dictionary line and = the two sides; a typed one would be
	-- read as either.
	if japanese:find("[/=]") then
		draft.message = GetString(SI_PBSTR_ERROR_WORD_CHARS)
	elseif self.engine.Trim(draft.english) == "" or japanese == "" then
		draft.message = GetString(SI_PBSTR_ERROR_WORD_EMPTY)
	else
		local kind = WORD_KINDS[draft.kind] or WORD_KINDS[1]
		local key, err = self:StoreUserWord(draft.english, kind.prefix .. japanese .. kind.suffix)
		if key then
			draft.message = string.format(GetString(SI_PBSTR_REPLY_ADDED), key, japanese)
			draft.english, draft.japanese, draft.kind, draft.selected = "", "", 1, key
		else
			draft.message = err
		end
	end
	self:RefreshPanel()
end

function addon:RemoveSelectedWord()
	local draft = self.wordDraft
	if not draft.selected then
		draft.message = GetString(SI_PBSTR_REPLY_NO_WORDS)
	else
		local key, err = self:DeleteUserWord(draft.selected)
		draft.message = key and string.format(GetString(SI_PBSTR_REPLY_REMOVED), key) or err
		draft.selected = nil
	end
	self:RefreshPanel()
end
