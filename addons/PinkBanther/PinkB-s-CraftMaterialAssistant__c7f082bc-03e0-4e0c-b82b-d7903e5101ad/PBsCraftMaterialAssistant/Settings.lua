-- PB's CraftMaterialAssistant -- the settings panel
--
-- PBS_CRAFT_MATERIAL_ASSISTANT is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_CRAFT_MATERIAL_ASSISTANT then
	return
end

local addon = PBS_CRAFT_MATERIAL_ASSISTANT

-- The dropdown lists. LibHarvensAddonSettings takes items as { name = <shown>, data = <value> }
-- and hands the whole item back to setFunction, so the stored value never has to be recovered
-- from the label -- which matters here, where the labels are translated and the values are
-- font aliases and tokens.
--
-- Built at panel-build time rather than at load, for two reasons: every name in them comes out
-- of GetString and the language files are what decide what that returns, and the category list
-- comes out of the client's own recipe lists, which are not necessarily populated before the
-- world is.
local lists = {
	faces = {}, faceByAlias = {},
	styles = {}, styleByToken = {},
	positions = {}, positionByToken = {},
	draws = {}, drawByToken = {},
	scopes = {}, scopeByToken = {},
	categories = {}, categoryByIndex = {},
}

local function BuildLists()
	for _, face in ipairs(addon.FACES or {}) do
		local entry = { name = GetString(_G[face.label]), data = face.alias }
		lists.faces[#lists.faces + 1] = entry
		lists.faceByAlias[face.alias] = entry
	end
	for _, style in ipairs(addon.STYLES or {}) do
		local entry = { name = GetString(_G[style.label]), data = style.token }
		lists.styles[#lists.styles + 1] = entry
		lists.styleByToken[style.token] = entry
	end
	for _, position in ipairs(addon.POSITIONS or {}) do
		local entry = { name = GetString(_G[position.label]), data = position.token }
		lists.positions[#lists.positions + 1] = entry
		lists.positionByToken[position.token] = entry
	end
	for _, draw in ipairs(addon.DRAW_ORDERS or {}) do
		local entry = { name = GetString(_G[draw.label]), data = draw.token }
		lists.draws[#lists.draws + 1] = entry
		lists.drawByToken[draw.token] = entry
	end
	for _, scope in ipairs(addon.SCOPES or {}) do
		local entry = { name = GetString(_G[scope.label]), data = scope.token }
		lists.scopes[#lists.scopes + 1] = entry
		lists.scopeByToken[scope.token] = entry
	end

	-- The categories are the client's own recipe lists, already translated. "All" is index 0
	-- and is first because it is what somebody searching by name wants.
	local all = { name = GetString(SI_PBSCMA_CATEGORY_ALL), data = 0 }
	lists.categories[1] = all
	lists.categoryByIndex[0] = all
	for _, category in ipairs(addon.recipes:Categories()) do
		local entry = { name = category.name, data = category.index }
		lists.categories[#lists.categories + 1] = entry
		lists.categoryByIndex[category.index] = entry
	end
end

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

-- ---------------------------------------------------------------------------------------
-- The panel
--
-- Three sections, in the order the work is done in: choose the thing, say how many, then the
-- window it is drawn in.
--
-- Nothing in the choosing section draws a list. The candidates are in the add-on's own window
-- -- see the comment at the top of Main.lua for why -- and these rows only move a marker
-- around in it. Every label here is a fixed string, which is what makes that safe: the library
-- builds its rows once, and a row whose text has to change after that is a row this add-on
-- does not ask for.
-- ---------------------------------------------------------------------------------------

function addon:InitSettings()
	local LibHarvensAddonSettings = LibHarvensAddonSettings
	if not LibHarvensAddonSettings then
		return
	end

	BuildLists()

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
			label = GetString(SI_PBSCMA_EXPLANATION)
		}
	)

	-- The master switch, first and outside every section. The window is meant to be put up
	-- while a batch is being planned and taken down again, so the row that does that is the
	-- one row that must never need scrolling to.
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCMA_ENABLED),
			tooltip = GetString(SI_PBSCMA_ENABLED_TOOLTIP),
			default = self.DEFAULTS.enabled,
			getFunction = function()
				return self:Enabled()
			end,
			setFunction = function(value)
				self:SetEnabled(value)
			end
		}
	)

	-- ---- choosing --------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSCMA_SECTION_PICK))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCMA_BROWSE_SHOWING),
			tooltip = GetString(SI_PBSCMA_BROWSE_SHOWING_TOOLTIP),
			default = self.DEFAULTS.browse.showing,
			getFunction = function()
				return self:Showing()
			end,
			setFunction = function(value)
				self:SetShowing(value)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSCMA_CATEGORY),
			tooltip = GetString(SI_PBSCMA_CATEGORY_TOOLTIP),
			items = lists.categories,
			default = (lists.categoryByIndex[0] or {}).name,
			getFunction = function()
				local entry = lists.categoryByIndex[self:Category()]
				return entry and entry.name or (lists.categoryByIndex[0] or {}).name
			end,
			setFunction = function(combobox, name, item)
				self:SetCategory(item.data)
				-- The list behind the window just changed under the page number, so the
				-- window has to be looked at again -- and it is the only place the result is
				-- visible.
				self:SetShowing(true)
				self:RefreshPanel()
			end
		}
	)

	-- A text row, only if this copy of the library has one. Everything below works without it;
	-- /pbcraft find is the route that is known to work on a console, and this is the
	-- convenience for the clients where the panel can take text directly.
	--
	-- pcall around AddSetting rather than a version check: the shape an ST_EDIT row wants is
	-- not something this add-on can verify from here, and a panel that fails to build is worse
	-- than a panel without a search box.
	if LibHarvensAddonSettings.ST_EDIT then
		pcall(function()
			settings:AddSetting(
				{
					type = LibHarvensAddonSettings.ST_EDIT,
					label = GetString(SI_PBSCMA_SEARCH),
					tooltip = GetString(SI_PBSCMA_SEARCH_TOOLTIP),
					default = "",
					getFunction = function()
						return self.sv.browse.text or ""
					end,
					setFunction = function(value)
						self:Search(value)
						self:SetShowing(true)
						self:RefreshPanel()
					end
				}
			)
		end)
	end

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSCMA_REBUILD),
			tooltip = GetString(SI_PBSCMA_REBUILD_TOOLTIP),
			buttonText = GetString(SI_PBSCMA_REBUILD_BUTTON),
			clickHandler = function()
				self:Search(self.sv.browse.text or "")
				self:SetShowing(true)
				self:RefreshPanel()
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSCMA_KNOWN_ONLY),
			tooltip = GetString(SI_PBSCMA_KNOWN_ONLY_TOOLTIP),
			default = self.DEFAULTS.knownOnly,
			getFunction = function()
				return self.sv.knownOnly ~= false
			end,
			setFunction = function(value)
				self.sv.knownOnly = value and true or false
				self:Search(self.sv.browse.text or "")
				self:SetShowing(true)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_PBSCMA_PAGE),
			tooltip = GetString(SI_PBSCMA_PAGE_TOOLTIP),
			min = 1,
			max = self.MAX_PAGES,
			step = 1,
			default = 1,
			format = "%d",
			getFunction = function()
				return self:Page()
			end,
			setFunction = function(value)
				-- Clamped to the pages that exist, so a slider dragged past the end of a
				-- short result set lands on the last page rather than on an empty one.
				self:SetPage(value)
				self:SetShowing(true)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_PBSCMA_CURSOR),
			tooltip = GetString(SI_PBSCMA_CURSOR_TOOLTIP),
			min = 1,
			max = self.PAGE_SIZE,
			step = 1,
			default = 1,
			format = "%d",
			getFunction = function()
				return self:Cursor()
			end,
			setFunction = function(value)
				-- Moves the marker in the window as the stick moves. This is the choosing.
				self:SetCursor(value)
				self:SetShowing(true)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSCMA_TAKE),
			tooltip = GetString(SI_PBSCMA_TAKE_TOOLTIP),
			buttonText = GetString(SI_PBSCMA_TAKE_BUTTON),
			clickHandler = function()
				local entry = self:EntryAt(self:Cursor())
				if not entry then
					-- Nothing said, and nothing done: the window stays on the candidate list,
					-- which is what "the marker is not on anything" looks like.
					return
				end
				-- Selecting turns the browse list off, so the window goes straight back to
				-- the material table for what was just chosen. That change IS the
				-- confirmation; a line in chat saying the same thing is a line in chat.
				self:Select(entry)
				self:RefreshPanel()
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSCMA_CLEAR),
			tooltip = GetString(SI_PBSCMA_CLEAR_TOOLTIP),
			buttonText = GetString(SI_PBSCMA_CLEAR_BUTTON),
			clickHandler = function()
				self:ClearTarget()
				self:RefreshPanel()
			end
		}
	)

	-- ---- how many --------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSCMA_SECTION_AMOUNT))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = GetString(SI_PBSCMA_QUANTITY),
			tooltip = GetString(SI_PBSCMA_QUANTITY_TOOLTIP),
			min = self.MIN_QUANTITY,
			max = self.MAX_QUANTITY,
			step = 1,
			default = self.DEFAULTS.target.quantity,
			format = "%d",
			getFunction = function()
				return self:Quantity()
			end,
			setFunction = function(value)
				-- The table is recomputed as the slider moves, so the shortfall column counts
				-- up under your thumb.
				self:SetQuantity(value)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSCMA_SCOPE),
			tooltip = GetString(SI_PBSCMA_SCOPE_TOOLTIP),
			items = lists.scopes,
			default = (lists.scopeByToken[self.DEFAULTS.scope] or {}).name,
			getFunction = function()
				local entry = lists.scopeByToken[self:Scope()]
				return entry and entry.name
			end,
			setFunction = function(combobox, name, item)
				self:SetScope(item.data)
			end
		}
	)

	-- ---- the window ------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSCMA_SECTION_WINDOW))

	local function AddWindowSlider(labelId, tooltipId, key, min, max, step, unitId)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(_G[labelId]),
				tooltip = GetString(_G[tooltipId]),
				min = min,
				max = max,
				step = step,
				default = self.DEFAULTS.window[key],
				format = "%d",
				unit = unitId and GetString(_G[unitId]) or nil,
				getFunction = function()
					return self.sv.window[key]
				end,
				setFunction = function(value)
					self.sv.window[key] = value
					-- Applied while the slider moves, so the window is the preview.
					self.hud:Refresh()
				end
			}
		)
	end

	AddWindowSlider("SI_PBSCMA_WIDTH", "SI_PBSCMA_WIDTH_TOOLTIP", "width",
		self.MIN_WIDTH, self.MAX_WIDTH, 10)
	AddWindowSlider("SI_PBSCMA_HEIGHT", "SI_PBSCMA_HEIGHT_TOOLTIP", "height",
		self.MIN_HEIGHT, self.MAX_HEIGHT, 10)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSCMA_POSITION),
			tooltip = GetString(SI_PBSCMA_POSITION_TOOLTIP),
			items = lists.positions,
			default = (lists.positionByToken[self.DEFAULTS.window.position] or {}).name,
			getFunction = function()
				local entry = lists.positionByToken[self.hud:Position()]
				return entry and entry.name
			end,
			setFunction = function(combobox, name, item)
				self.sv.window.position = item.data
				self.hud:Refresh()
			end
		}
	)

	AddWindowSlider("SI_PBSCMA_OFFSET_X", "SI_PBSCMA_OFFSET_TOOLTIP", "offsetX",
		-self.MAX_OFFSET_X, self.MAX_OFFSET_X, 10)
	AddWindowSlider("SI_PBSCMA_OFFSET_Y", "SI_PBSCMA_OFFSET_TOOLTIP", "offsetY",
		-self.MAX_OFFSET_Y, self.MAX_OFFSET_Y, 10)
	AddWindowSlider("SI_PBSCMA_FONT_SIZE", "SI_PBSCMA_FONT_SIZE_TOOLTIP", "size",
		self.MIN_FONT_SIZE, self.MAX_FONT_SIZE, 1)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSCMA_FACE),
			tooltip = GetString(SI_PBSCMA_FACE_TOOLTIP),
			items = lists.faces,
			default = (lists.faceByAlias[self.DEFAULTS.window.face] or {}).name,
			getFunction = function()
				local entry = lists.faceByAlias[self.hud:Face()]
				return entry and entry.name
			end,
			setFunction = function(combobox, name, item)
				self.sv.window.face = item.data
				self.hud:Refresh()
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSCMA_STYLE),
			tooltip = GetString(SI_PBSCMA_STYLE_TOOLTIP),
			items = lists.styles,
			default = (lists.styleByToken[self.DEFAULTS.window.style] or {}).name,
			getFunction = function()
				local entry = lists.styleByToken[self.hud:Style()]
				return entry and entry.name
			end,
			setFunction = function(combobox, name, item)
				self.sv.window.style = item.data
				self.hud:Refresh()
			end
		}
	)

	AddWindowSlider("SI_PBSCMA_OPACITY", "SI_PBSCMA_OPACITY_TOOLTIP", "opacity", 0, 100, 5)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSCMA_DRAW),
			tooltip = GetString(SI_PBSCMA_DRAW_TOOLTIP),
			items = lists.draws,
			default = (lists.drawByToken[self.DEFAULTS.window.draw] or {}).name,
			getFunction = function()
				local entry = lists.drawByToken[self.hud:Draw()]
				return entry and entry.name
			end,
			setFunction = function(combobox, name, item)
				self.sv.window.draw = item.data
				self.hud:Refresh()
				-- SetDrawLayer is one of the calls the API dump marks and the client has
				-- disagreed with before. A refusal is recorded on the window and reported by
				-- /pbcraft; the panel does not talk to the chat window.
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSCMA_RESET),
			tooltip = GetString(SI_PBSCMA_RESET_TOOLTIP),
			buttonText = GetString(SI_PBSCMA_RESET_BUTTON),
			clickHandler = function()
				self:Reset()
				self:RefreshPanel()
			end
		}
	)
end
