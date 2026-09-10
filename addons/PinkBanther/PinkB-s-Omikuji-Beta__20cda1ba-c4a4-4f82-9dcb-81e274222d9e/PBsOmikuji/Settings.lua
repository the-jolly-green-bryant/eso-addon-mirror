-- PB's Omikuji -- the settings panel
--
-- Four rows and two buttons. There is deliberately no row that displays the fortune: the
-- library builds its rows once, and a row whose text has to change after that is a row this
-- add-on does not ask for -- the fortune would go stale the moment the day rolled over with
-- the panel still open. The button puts it in chat instead, where it is dated and correct.
--
-- PBS_OMIKUJI is nil if Main.lua bailed out early (e.g. already loaded).
if not PBS_OMIKUJI then
	return
end

local addon = PBS_OMIKUJI

-- LibHarvensAddonSettings takes dropdown items as { name = <shown>, data = <value> } and hands
-- the whole item back to setFunction, so the stored token never has to be recovered from a
-- translated label. Built at panel-build time rather than at load, because every name in here
-- comes out of GetString and the language files decide what that returns.
local lists = {
	scopes = {},
	scopeByToken = {},
}

local function BuildLists()
	for _, scope in ipairs(addon.SCOPES or {}) do
		local entry = { name = GetString(_G[scope.label]), data = scope.token }
		lists.scopes[#lists.scopes + 1] = entry
		lists.scopeByToken[scope.token] = entry
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
			label = GetString(SI_PBSOMI_EXPLANATION)
		}
	)

	-- ---- when ------------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSOMI_SECTION_WHEN))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSOMI_ENABLED),
			tooltip = GetString(SI_PBSOMI_ENABLED_TOOLTIP),
			default = self.DEFAULTS.enabled,
			getFunction = function()
				return self:Enabled()
			end,
			setFunction = function(value)
				self:SetEnabled(value)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSOMI_ONCE),
			tooltip = GetString(SI_PBSOMI_ONCE_TOOLTIP),
			default = self.DEFAULTS.oncePerDay,
			getFunction = function()
				return self:OncePerDay()
			end,
			setFunction = function(value)
				self:SetOncePerDay(value)
			end
		}
	)

	-- ---- what ------------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSOMI_SECTION_WHAT))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_DROPDOWN,
			label = GetString(SI_PBSOMI_SCOPE),
			tooltip = GetString(SI_PBSOMI_SCOPE_TOOLTIP),
			items = lists.scopes,
			default = (lists.scopeByToken[self.DEFAULTS.scope] or {}).name,
			getFunction = function()
				local entry = lists.scopeByToken[self:Scope()]
				return entry and entry.name or (lists.scopeByToken[self.DEFAULTS.scope] or {}).name
			end,
			setFunction = function(combobox, name, item)
				-- Changing this changes who is drawing, and therefore which slip is today's.
				-- Saying so in chat is the only way that is visible from here.
				self:SetScope(item.data)
				self:PrintFortune(true)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSOMI_DATE),
			tooltip = GetString(SI_PBSOMI_DATE_TOOLTIP),
			default = self.DEFAULTS.showDate,
			getFunction = function()
				return self:ShowDate()
			end,
			setFunction = function(value)
				self:SetShowDate(value)
			end
		}
	)

	-- ---- today -----------------------------------------------------------------------
	AddHeading(settings, LibHarvensAddonSettings, GetString(SI_PBSOMI_SECTION_NOW))

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSOMI_DRAW_NOW),
			tooltip = GetString(SI_PBSOMI_DRAW_NOW_TOOLTIP),
			buttonText = GetString(SI_PBSOMI_DRAW_NOW_BUTTON),
			clickHandler = function()
				self:PrintFortune(true)
			end
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = GetString(SI_PBSOMI_RESET),
			tooltip = GetString(SI_PBSOMI_RESET_TOOLTIP),
			buttonText = GetString(SI_PBSOMI_RESET_BUTTON),
			clickHandler = function()
				self:Reset()
				self:RefreshPanel()
			end
		}
	)
end
