-- PB's LuaMemoryMonitor -- settings panel
--
-- Everything here can also be done from /pbmem; the panel needs LibHarvensAddonSettings, which
-- is only an optional dependency. The window lives on the HUD, so nothing set here can be seen
-- while the menu is open: each change is applied at once and shows on return to the game.

local addon = PBS_LUA_MEMORY_MONITOR
if not addon then
	return
end

-- Position moves in fives: a d-pad press that moves the window one unit at a time would take
-- a minute to cross the screen.
local POSITION_STEP = 5
local OPACITY_STEP = 5
local AUTO_SCAN_CHOICES = { 0, 30, 60, 300 }
-- A full collection stalls the game for a moment, so nothing shorter than a minute is offered.
local COLLECT_CHOICES = { 0, 60, 300, 600 }

local function AddSection(settings, LibHarvensAddonSettings, stringId)
	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_SECTION or LibHarvensAddonSettings.ST_LABEL,
		label = GetString(stringId),
	})
end

local function AddLabel(settings, LibHarvensAddonSettings, stringId)
	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_LABEL,
		label = GetString(stringId),
	})
end

local function AddButton(settings, LibHarvensAddonSettings, labelId, tooltipId, buttonId, handler)
	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_BUTTON,
		label = GetString(labelId),
		tooltip = GetString(tooltipId),
		buttonText = GetString(buttonId),
		clickHandler = handler,
	})
end

-- A dropdown over a list of { name, data } items. Its getFunction never returns nil: a
-- dropdown handed nil falls back to its first item, which reads as the setting having reset.
local function AddDropdown(settings, LibHarvensAddonSettings, labelId, tooltipId, items, default, read, write)
	local byData = {}
	for _, item in ipairs(items) do
		byData[item.data] = item
	end
	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_DROPDOWN,
		label = GetString(labelId),
		tooltip = GetString(tooltipId),
		items = items,
		default = byData[default].name,
		getFunction = function()
			return (byData[read()] or byData[default]).name
		end,
		setFunction = function(_, _, item)
			write(item.data)
		end,
	})
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
	settings.author = "PinkBanther"
	settings.version = self.version

	local function UpdateControls()
		if settings.UpdateControls then
			settings:UpdateControls()
		end
	end

	AddLabel(settings, LibHarvensAddonSettings, SI_PBSLMM_SETTINGS_EXPLANATION)

	-- ---- Window --------------------------------------------------------------------------
	AddSection(settings, LibHarvensAddonSettings, SI_PBSLMM_SECTION_WINDOW)

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = GetString(SI_PBSLMM_SHOW),
		tooltip = GetString(SI_PBSLMM_SHOW_TOOLTIP),
		default = false,
		getFunction = function()
			return self.sv.visible == true
		end,
		setFunction = function(value)
			if value then
				self:ShowWindow()
			else
				self:HideWindow()
			end
		end,
	})

	local sortItems = {}
	for _, key in ipairs(self.SORT_ORDER) do
		sortItems[#sortItems + 1] = { name = GetString(self.SORT_TITLES[key]), data = key }
	end
	AddDropdown(settings, LibHarvensAddonSettings, SI_PBSLMM_SORT, SI_PBSLMM_SORT_TOOLTIP, sortItems, "held",
		function() return self.sv.sort end,
		function(key) self:SetSort(key) end)

	local autoItems = {}
	for _, seconds in ipairs(AUTO_SCAN_CHOICES) do
		autoItems[#autoItems + 1] = { name = self:AutoScanLabel(seconds), data = seconds }
	end
	AddDropdown(settings, LibHarvensAddonSettings, SI_PBSLMM_AUTO_SCAN, SI_PBSLMM_AUTO_SCAN_TOOLTIP, autoItems, 60,
		function() return self.sv.autoScan end,
		function(seconds) self:SetAutoScanSeconds(seconds) end)

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = GetString(SI_PBSLMM_BANNER),
		tooltip = GetString(SI_PBSLMM_BANNER_TOOLTIP),
		default = true,
		getFunction = function()
			return self.sv.banner ~= false
		end,
		setFunction = function(value)
			self.sv.banner = value
		end,
	})

	-- ---- Position and look ---------------------------------------------------------------
	AddSection(settings, LibHarvensAddonSettings, SI_PBSLMM_SECTION_LOOK)

	-- The sliders' ranges keep the whole window on the screen.
	local rootWidth, rootHeight = self:RootSize()
	local windowWidth, windowHeight = self:WindowSize()
	local defaultX, defaultY = self:DefaultPosition()

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_PBSLMM_POSITION_X),
		tooltip = GetString(SI_PBSLMM_POSITION_X_TOOLTIP),
		min = 0,
		max = math.max(0, math.floor(rootWidth - windowWidth)),
		step = POSITION_STEP,
		default = defaultX,
		format = "%d",
		unit = "",
		getFunction = function()
			return (self:Position())
		end,
		setFunction = function(value)
			self.sv.x = math.floor(value + 0.5)
			self:ApplyLayout()
		end,
	})

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_PBSLMM_POSITION_Y),
		tooltip = GetString(SI_PBSLMM_POSITION_Y_TOOLTIP),
		min = 0,
		max = math.max(0, math.floor(rootHeight - windowHeight)),
		step = POSITION_STEP,
		default = defaultY,
		format = "%d",
		unit = "",
		getFunction = function()
			local _, y = self:Position()
			return y
		end,
		setFunction = function(value)
			self.sv.y = math.floor(value + 0.5)
			self:ApplyLayout()
		end,
	})

	AddButton(settings, LibHarvensAddonSettings, SI_PBSLMM_RESET_POSITION, SI_PBSLMM_RESET_POSITION_TOOLTIP,
		SI_PBSLMM_RESET_POSITION_BUTTON, function()
			self.sv.x, self.sv.y = nil, nil
			self:ApplyLayout()
			-- The sliders were built from the old values; tell them to read the new ones.
			UpdateControls()
		end)

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_SLIDER,
		label = GetString(SI_PBSLMM_BG_ALPHA),
		tooltip = GetString(SI_PBSLMM_BG_ALPHA_TOOLTIP),
		min = 0,
		max = 100,
		step = OPACITY_STEP,
		default = 78,
		format = "%d",
		unit = "%",
		getFunction = function()
			return tonumber(self.sv.bgAlpha) or 78
		end,
		setFunction = function(value)
			self.sv.bgAlpha = math.floor(value + 0.5)
			self:ApplyLayout()
		end,
	})

	-- ---- Freeing memory ------------------------------------------------------------------
	AddSection(settings, LibHarvensAddonSettings, SI_PBSLMM_SECTION_COLLECT)

	local collectItems = {}
	for _, seconds in ipairs(COLLECT_CHOICES) do
		collectItems[#collectItems + 1] = { name = self:AutoScanLabel(seconds), data = seconds }
	end
	AddDropdown(settings, LibHarvensAddonSettings, SI_PBSLMM_COLLECT_EVERY, SI_PBSLMM_COLLECT_EVERY_TOOLTIP,
		collectItems, 0,
		function() return self.sv.collectEvery end,
		function(seconds) self:SetCollectEvery(seconds) end)

	settings:AddSetting({
		type = LibHarvensAddonSettings.ST_CHECKBOX,
		label = GetString(SI_PBSLMM_COLLECT_IN_COMBAT),
		tooltip = GetString(SI_PBSLMM_COLLECT_IN_COMBAT_TOOLTIP),
		default = false,
		getFunction = function()
			return self.sv.collectInCombat == true
		end,
		setFunction = function(value)
			self.sv.collectInCombat = value
		end,
	})

	AddButton(settings, LibHarvensAddonSettings, SI_PBSLMM_COLLECT_NOW, SI_PBSLMM_COLLECT_NOW_TOOLTIP,
		SI_PBSLMM_COLLECT_NOW_BUTTON, function()
			self:CollectNow(true)
		end)

	-- ---- Actions -------------------------------------------------------------------------
	AddSection(settings, LibHarvensAddonSettings, SI_PBSLMM_SECTION_ACTIONS)

	AddButton(settings, LibHarvensAddonSettings, SI_PBSLMM_SCAN_NOW, SI_PBSLMM_SCAN_NOW_TOOLTIP,
		SI_PBSLMM_SCAN_NOW_BUTTON, function()
			self:StartScan()
		end)

	AddButton(settings, LibHarvensAddonSettings, SI_PBSLMM_NEXT_PAGE, SI_PBSLMM_NEXT_PAGE_TOOLTIP,
		SI_PBSLMM_NEXT_PAGE_BUTTON, function()
			self:NextPage()
		end)

	AddLabel(settings, LibHarvensAddonSettings, SI_PBSLMM_COMMANDS_HINT)
end
