-- PBS_MINIMAP is nil if Main.lua bailed out early (e.g. the add-on was already loaded).
if not PBS_MINIMAP then
	return
end

local addon = PBS_MINIMAP
local async = LibAsync

addon.zoneAlertMode = {
	Always = "ALWAYS",
	MiniMapHidden = "MINIMAPHIDDEN",
	Never = "NEVER"
}
addon.compassMode = {
	Untouched = "UNTOUCHED",
	Hidden = "HIDDEN",
	Shown = "SHOWN"
}
addon.fontFaces = {
	["MEDIUM_FONT"] = {"$(MEDIUM_FONT)", 1},
	["BOLD_FONT"] = {"$(BOLD_FONT)", 1},
	["CHAT_FONT"] = {"$(CHAT_FONT)", 1},
	["GAMEPAD_LIGHT_FONT"] = {"$(GAMEPAD_LIGHT_FONT)", 1.3},
	["GAMEPAD_MEDIUM_FONT"] = {"$(GAMEPAD_MEDIUM_FONT)", 1.3},
	["GAMEPAD_BOLD_FONT"] = {"$(GAMEPAD_BOLD_FONT)", 1.3},
	["ANTIQUE_FONT"] = {"$(ANTIQUE_FONT)", 1},
	["HANDWRITTEN_FONT"] = {"$(HANDWRITTEN_FONT)", 0.95},
	["STONE_TABLET_FONT"] = {"$(STONE_TABLET_FONT)", 0.9}
}

local lookup = {
	frameStyles = {},
	fonts = {},
	fontSizes = {}
}

function addon:GetFontSizeBySizeName(sizeName)
	return lookup.nameToFontSize[sizeName]
end

function addon:GetStyleByName(name)
	return lookup.frameToFile[name]
end

function addon:AddBorderStyle(name, displayText, setupFunction, resetFunction)
	lookup.frameStyles[#lookup.frameStyles + 1] = {
		name = displayText,
		data = {value = name, setup = setupFunction, reset = resetFunction}
	}
end

function addon:AddFont(font, displayText)
	if zo_plainstrfind(font, "/") then
		self.fontFaces[font] = font
	else
		if not self.fontFaces[font] then
			self.fontFaces[font] = string.format("$(%s)", font)
		end
	end
	lookup.fonts[#lookup.fonts + 1] = {name = displayText, data = font}
end

function addon:AddFontSize(fontSize, displayText, offsetY)
	lookup.fontSizes[#lookup.fontSizes + 1] = {name = displayText, data = {size = fontSize, offsetY = offsetY}}
end

function addon:InitMapSettings()
	lookup.frameToFile = {}
	for _, item in pairs(lookup.frameStyles) do
		lookup.frameToFile[item.data.value] = item
	end
	if not lookup.frameToFile[self.account.frameStyle] then
		self.account.frameStyle = "Default"
	end

	lookup.nameToFont = {}
	for _, item in pairs(lookup.fonts) do
		lookup.nameToFont[item.data] = item
	end
	if not lookup.nameToFont[self.account.titleFont] then
		self.account.titleFont = "BOLD_FONT"
	end

	lookup.nameToFontSize = {}
	for _, item in pairs(lookup.fontSizes) do
		lookup.nameToFontSize[item.data.size] = item
	end
	if type(self.account.titleFontSize) == "string" then
		PBSMINIMAP_FONT = CreateFont("PBSMINIMAP_FONT", "$(MEDIUM_FONT)|" .. self.account.titleFontSize)
		local _, fontSize = PBSMINIMAP_FONT:GetFontInfo()
		self.account.titleFontSize = fontSize
	end
	if not lookup.nameToFontSize[self.account.titleFontSize] then
		self.account.titleFontSize = 16
	end
end

function addon:InitSettings()
	local LibHarvensAddonSettings = LibHarvensAddonSettings

	-- Heading is a fixed Lua string with the manifest version appended (see Main.lua).
	local settings = LibHarvensAddonSettings:AddAddon(self.title)
	if not settings then
		return
	end
	self.settingsControls = settings
	settings.allowDefaults = true
	settings.author = self.author
	settings.version = self.version

	-- Credit to the add-on this one is based on, kept out of the author field so that stays
	-- the actual author of this version.
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = "Based on Votan's Minimap by votan"
		}
	)

	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_PBSMINIMAP_WORLD_MAP_TWEAKS),
			tooltip = GetString(SI_PBSMINIMAP_WORLD_MAP_TWEAKS_TOOLTIP),
			default = self.accountDefaults.enableTweaks,
			getFunction = function()
				return self.account.enableTweaks
			end,
			setFunction = function(value)
				self.account.enableTweaks = value
			end,
			disable = ZO_IsConsoleOrGameCoreUI()
		}
	)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = GetString(SI_KEYBINDINGS_CATEGORY_PBSMINIMAP),
			tooltip = GetString(SI_PBSMINIMAP_MINI_MAP_TOOLTIP),
			default = self.accountDefaults.enableMap,
			getFunction = function()
				return self.account.enableMap
			end,
			setFunction = function(value)
				self.account.enableMap = value
			end
		}
	)
	-- Diagnostic bisection switch for the console memory crash. See initLevel in Main.lua.
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "Debug: init level",
			tooltip = "0=off  1=settings  2=+resize hook  3=+all hooks (no visible minimap)  4=+visible minimap (normal). Lower this to find which layer causes the crash. Press Apply after changing.",
			min = 0,
			max = 4,
			step = 1,
			default = self.accountDefaults.initLevel,
			format = "%d",
			unit = "",
			getFunction = function()
				return self.account.initLevel or 4
			end,
			setFunction = function(value)
				self.account.initLevel = value
			end
		}
	)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_SLIDER,
			label = "Debug: minimap part",
			tooltip = "Only used at init level 3+. 0=hooks only  1=+fragment tweaks  2=+texture hook  3=+own map mode (normal). Press Apply after changing.",
			min = 0,
			max = 3,
			step = 1,
			default = self.accountDefaults.miniPart,
			format = "%d",
			unit = "",
			getFunction = function()
				return self.account.miniPart or 3
			end,
			setFunction = function(value)
				self.account.miniPart = value
			end
		}
	)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_CHECKBOX,
			label = "Debug: log to chat",
			tooltip = "Print the add-on memory and map-state trail to chat. Off by default; the trail is recorded either way and shown on the next login when this is on.",
			default = self.accountDefaults.debug,
			getFunction = function()
				return self.account.debug
			end,
			setFunction = function(value)
				self.account.debug = value
			end
		}
	)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_LABEL,
			label = ""
		}
	)
	settings:AddSetting(
		{
			type = LibHarvensAddonSettings.ST_BUTTON,
			label = "",
			tooltip = nil,
			buttonText = GetString(SI_PBSMINIMAP_APPLY_BUTTON),
			clickHandler = function()
				SLASH_COMMANDS["/reloadui"]()
			end
		}
	)

	-- Lite minimap (init level 2): size and position for the game's own map window, applied
	-- directly without any of the InitMiniMap machinery.
	if (self.initLevel or 0) == 2 then
		local function applyLayout()
			if self.ResetLiteLayoutBackoff then
				self:ResetLiteLayoutBackoff()
			end
			self:ApplyLiteMinimapLayout()
			-- The maintenance tick skips a hidden window; refresh so the preview follows too.
			if self.litePreviewAdded then
				WORLD_MAP_FRAGMENT:Refresh()
			end
		end
		local uiWidth, uiHeight = GuiRoot:GetDimensions()

		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_LABEL,
				label = GetString(SI_KEYBINDINGS_CATEGORY_PBSMINIMAP)
			}
		)

		-- Live preview: park the World Map fragment in whatever scene the settings panel is
		-- running in, so size and offset can be judged while they are being adjusted.
		local previewScene
		local function removePreview()
			if not self.litePreviewAdded then
				return
			end
			self.litePreviewAdded = false
			if previewScene then
				previewScene:RemoveFragment(WORLD_MAP_FRAGMENT)
				previewScene = nil
			end
			WORLD_MAP_FRAGMENT:Refresh()
			-- Leaving the preview hands the window back to the HUD, and the game re-anchors it
			-- on the way. Re-assert straight away instead of waiting for the maintenance tick.
			if self.ResetLiteLayoutBackoff then
				self:ResetLiteLayoutBackoff()
			end
			self:ApplyLiteMinimapLayout()
		end
		local function addPreview()
			if self.litePreviewAdded then
				return
			end
			previewScene = SCENE_MANAGER:GetCurrentScene()
			if not previewScene then
				return
			end
			self.litePreviewAdded = true
			previewScene:AddFragment(WORLD_MAP_FRAGMENT)
			WORLD_MAP_FRAGMENT:Refresh()
			applyLayout()
		end
		-- Drop the preview again as soon as another add-on's panel is selected.
		CALLBACK_MANAGER:RegisterCallback(
			"LibHarvensAddonSettings_AddonSelected",
			function(_, addonSettings)
				if addonSettings ~= settings then
					removePreview()
				end
			end
		)

		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_SHOW_IN_SETTINGS),
				tooltip = "Show the map here while adjusting size and position.",
				default = false,
				getFunction = function()
					return self.litePreviewAdded == true
				end,
				setFunction = function(value)
					if value then
						addPreview()
					else
						removePreview()
					end
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = "Width",
				tooltip = "Width of the minimap window.",
				min = 20,
				max = math.floor(uiWidth),
				step = 2,
				default = 304,
				format = "%d",
				unit = "",
				getFunction = function()
					return self.account.width or 304
				end,
				setFunction = function(value)
					self.account.width = value
					applyLayout()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = "Height",
				tooltip = "Height of the minimap window.",
				min = 20,
				max = math.floor(uiHeight),
				step = 2,
				default = 368,
				format = "%d",
				unit = "",
				getFunction = function()
					return self.account.height or 368
				end,
				setFunction = function(value)
					self.account.height = value
					applyLayout()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = "Offset X",
				tooltip = "Horizontal offset from the centre of the screen. Negative moves left.",
				min = -math.floor(uiWidth / 2),
				max = math.floor(uiWidth / 2),
				step = 4,
				default = math.floor(uiWidth / 2 - 304),
				format = "%d",
				unit = "",
				getFunction = function()
					return self.account.x or (uiWidth / 2 - 304)
				end,
				setFunction = function(value)
					self.account.x = value
					applyLayout()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = "Offset Y",
				tooltip = "Vertical offset from the centre of the screen. Negative moves up.",
				min = -math.floor(uiHeight / 2),
				max = math.floor(uiHeight / 2),
				step = 4,
				default = math.floor(uiHeight / 2 - 368),
				format = "%d",
				unit = "",
				getFunction = function()
					return self.account.y or (uiHeight / 2 - 368)
				end,
				setFunction = function(value)
					self.account.y = value
					applyLayout()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = "Follow player",
				tooltip = "Keep the player centred on the minimap and move the map as you travel.",
				default = self.accountDefaults.followPlayer,
				getFunction = function()
					return self.account.followPlayer
				end,
				setFunction = function(value)
					self.account.followPlayer = value
					if self.ResetFollowState then
						self:ResetFollowState()
					end
				end
			}
		)
		-- One zoom per context: indoors the game swaps to a much smaller map, where an
		-- outdoor zoom level is far too close to see anything around the player.
		local function addZoomSetting(label, key, tooltip)
			settings:AddSetting(
				{
					type = LibHarvensAddonSettings.ST_SLIDER,
					label = label,
					tooltip = tooltip,
					min = 0,
					max = 1,
					step = 0.01,
					default = self.accountDefaults[key],
					format = "%.2f",
					unit = "",
					getFunction = function()
						return self.account[key] or self.accountDefaults[key]
					end,
					setFunction = function(value)
						self.account[key] = value
						if self.ResetFollowState then
							self:ResetFollowState()
						end
					end
				}
			)
		end

		addZoomSetting(
			"Zoom: outdoors",
			"liteZoom",
			"Zoom used in the open world. Centring only shows once this is high enough that the map is larger than the window - at 0 the whole zone fits and there is nothing to pan. Applies immediately."
		)
		addZoomSetting(
			"Zoom: buildings & cities",
			"liteZoomSubZone",
			"Zoom used inside buildings, houses and city maps. These maps are much smaller, so a lower value here keeps the area around the player visible."
		)
		addZoomSetting(
			"Zoom: dungeons",
			"liteZoomDungeon",
			"Zoom used inside dungeons and trials."
		)
		addZoomSetting(
			"Zoom: battlegrounds",
			"liteZoomBattleground",
			"Zoom used in battlegrounds."
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_BUTTON,
				label = "",
				tooltip = "Re-apply the size and position now.",
				buttonText = "Re-apply layout",
				clickHandler = applyLayout
			}
		)
	end

	-- The settings below drive functions that only exist once InitMiniMap has run, so they
	-- are hidden at the lower bisection levels rather than erroring when touched.
	if (self.initLevel or 0) >= 3 then
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_LABEL,
				label = GetString(SI_KEYBINDINGS_CATEGORY_PBSMINIMAP)
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(SI_PBSMINIMAP_ZOOM),
				tooltip = GetString(SI_PBSMINIMAP_ZOOM_TOOLTIP),
				min = 0.0,
				max = 2,
				step = 0.05,
				default = self.accountDefaults.zoom,
				format = "%f",
				unit = "",
				getFunction = function()
					return self.account.zoom
				end,
				setFunction = function(value)
					self.account.zoom = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(SI_PBSMINIMAP_SUB_ZONE_ZOOM),
				tooltip = GetString(SI_PBSMINIMAP_SUB_ZONE_ZOOM_TOOLTIP),
				min = 0.0,
				max = 2,
				step = 0.05,
				default = self.accountDefaults.subZoneZoom,
				format = "%f",
				unit = "",
				getFunction = function()
					return self.account.subZoneZoom
				end,
				setFunction = function(value)
					self.account.subZoneZoom = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(SI_PBSMINIMAP_DUNGEON_ZOOM),
				tooltip = GetString(SI_PBSMINIMAP_DUNGEON_ZOOM_TOOLTIP),
				min = 0.0,
				max = 2,
				step = 0.05,
				default = self.accountDefaults.dungeonZoom,
				format = "%f",
				unit = "",
				getFunction = function()
					return self.account.dungeonZoom
				end,
				setFunction = function(value)
					self.account.dungeonZoom = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(SI_PBSMINIMAP_MOUNTED_ZOOM),
				tooltip = GetString(SI_PBSMINIMAP_MOUNTED_ZOOM_TOOLTIP),
				min = 0.0,
				max = 2,
				step = 0.05,
				default = self.accountDefaults.mountedZoom,
				format = "%f",
				unit = "",
				getFunction = function()
					return self.account.mountedZoom
				end,
				setFunction = function(value)
					self.account.mountedZoom = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(SI_PBSMINIMAP_BG_ZOOM),
				tooltip = GetString(SI_PBSMINIMAP_BG_ZOOM_TOOLTIP),
				min = 0.0,
				max = 2,
				step = 0.05,
				default = self.accountDefaults.battlegroundZoom,
				format = "%f",
				unit = "",
				getFunction = function()
					return self.account.battlegroundZoom
				end,
				setFunction = function(value)
					self.account.battlegroundZoom = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(SI_PBSMINIMAP_UNIT_PINS_MINIMUM_SIZE),
				tooltip = GetString(SI_PBSMINIMAP_UNIT_PINS_MINIMUM_SIZE_TOOLTIP),
				min = 0.65,
				max = 1,
				step = 0.01,
				default = self.accountDefaults.unitPinScaleLimit,
				format = "%f",
				unit = "",
				getFunction = function()
					return self.account.unitPinScaleLimit
				end,
				setFunction = function(value)
					self.account.unitPinScaleLimit = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_SHOW_MAP),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_MAP_TOOLTIP),
				default = self.defaults.showMap,
				getFunction = function()
					return self.player.showMap
				end,
				setFunction = function(value)
					self.player.showMap = value
					self:UpdateVisibility()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = " |u12:0::|u" .. GetString(SI_PBSMINIMAP_SHOW_HUD),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_HUD_TOOLTIP),
				default = self.accountDefaults.showHUD,
				getFunction = function()
					return self.account.showHUD
				end,
				setFunction = function(value)
					self.account.showHUD = value
					self:UpdateVisibility()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = " |u12:0::|u" .. GetString(SI_PBSMINIMAP_SHOW_LOOTING),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_LOOTING_TOOLTIP),
				default = self.accountDefaults.showLoot,
				getFunction = function()
					return self.account.showLoot
				end,
				setFunction = function(value)
					self.account.showLoot = value
					self:UpdateVisibility()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = " |u12:0::|u" .. GetString(SI_PBSMINIMAP_SHOW_MOUNTED),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_MOUNTED_TOOLTIP),
				default = self.accountDefaults.showMounted,
				getFunction = function()
					return self.account.showMounted
				end,
				setFunction = function(value)
					self.account.showMounted = value
					self:UpdateVisibility()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = " |u12:0::|u" .. GetString(SI_PBSMINIMAP_SHOW_COMBAT),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_COMBAT_TOOLTIP),
				default = self.accountDefaults.showCombat,
				getFunction = function()
					return self.account.showCombat
				end,
				setFunction = function(value)
					self.account.showCombat = value
					self:UpdateVisibility()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = " |u12:0::|u" .. GetString(SI_PBSMINIMAP_SHOW_SIEGE),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_SIEGE_TOOLTIP),
				default = self.accountDefaults.showSiege,
				getFunction = function()
					return self.account.showSiege
				end,
				setFunction = function(value)
					self.account.showSiege = value
					self:UpdateVisibility()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = " |u12:0::|u" .. GetString(SI_PBSMINIMAP_SHOW_IN_HOUSING),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_IN_HOUSING_TOOLTIP),
				default = self.accountDefaults.showInHousing,
				getFunction = function()
					return self.account.showInHousing
				end,
				setFunction = function(value)
					self.account.showInHousing = value
					self:UpdateVisibility()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_ASYNC_UPDATE),
				tooltip = GetString(SI_PBSMINIMAP_ASYNC_UPDATE_TOOLTIP),
				default = self.accountDefaults.asyncUpdate,
				getFunction = function()
					return self.account.asyncUpdate
				end,
				setFunction = function(value)
					self.account.asyncUpdate = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SECTION,
				label = GetString(SI_PBSMINIMAP_KEYBINDINGS_ZOOM)
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_ZOOM_TO_PLAYER),
				tooltip = GetString(SI_PBSMINIMAP_ZOOM_TO_PLAYER_TOOLTIP),
				default = self.accountDefaults.zoomToPlayer,
				getFunction = function()
					return self.account.zoomToPlayer
				end,
				setFunction = function(value)
					self.account.zoomToPlayer = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(SI_PBSMINIMAP_ZOOM_OUT),
				tooltip = GetString(SI_PBSMINIMAP_ZOOM_OUT_TOOLTIP),
				min = 0.0,
				max = 1,
				step = 0.05,
				default = self.accountDefaults.zoomOut,
				format = "%f",
				unit = "",
				getFunction = function()
					return self.account.zoomOut
				end,
				setFunction = function(value)
					self.account.zoomOut = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(SI_PBSMINIMAP_ZOOM_IN),
				tooltip = GetString(SI_PBSMINIMAP_ZOOM_IN_TOOLTIP),
				min = 1,
				max = 2,
				step = 0.05,
				default = self.accountDefaults.zoomIn,
				format = "%f",
				unit = "",
				getFunction = function()
					return self.account.zoomIn
				end,
				setFunction = function(value)
					self.account.zoomIn = value
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SECTION,
				label = GetString(SI_PBSMINIMAP_APPEARANCE)
			}
		)
		-- Always use the last setting before location settings
		local prevSetting =
			settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_LOCK_POSITION),
				tooltip = GetString(SI_PBSMINIMAP_LOCK_POSITION_TOOLTIP),
				default = self.accountDefaults.lockWindow,
				getFunction = function()
					return self.account.lockWindow
				end,
				setFunction = function(value)
					self.account.lockWindow = value
					self:UpdateBorder()
				end
			}
		)

		local locationSettings
		local function updateLocationSettings()
			local last = prevSetting.control
			for i = 1, #locationSettings do
				---@diagnostic disable-next-line: undefined-field
				last = locationSettings[i]:UpdateControl(last)
			end
			ZO_WorldMap:SetDrawLayer(DL_BACKGROUND)
			ZO_WorldMap:SetDrawLevel(0)
		end
		local scene
		local inUpdate
		local function addMap()
			if self.wasMapAdded then
				return
			end
			scene = SCENE_MANAGER:GetCurrentScene()
			scene:AddFragment(WORLD_MAP_FRAGMENT)
			self.settingsScene = scene
			self.wasMapAdded = true
			WORLD_MAP_FRAGMENT:Refresh()
		end
		local function addonSelected(_, addonSettings)
			if inUpdate then
				return
			end
			local _addMap = addonSettings == settings
			if not _addMap and self.wasMapAdded then
				scene:RemoveFragment(WORLD_MAP_FRAGMENT)
				self.wasMapAdded = false
				self:UpdateBorder()
				if settings.selected then
					updateLocationSettings()
				end
				WORLD_MAP_FRAGMENT:Refresh()
			end
		end
		CALLBACK_MANAGER:RegisterCallback("LibHarvensAddonSettings_AddonSelected", addonSelected)
		CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", addonSelected)

		local function getScreenDimensions()
			if inUpdate then
				return
			end
			local w, h = GuiRoot:GetDimensions()
			w, h = w / 8, h / 8
			local w2, h2 = w * 0.5, h * 0.5
			locationSettings[2].default = math.floor(w2 - locationSettings[3].default / 2)
			locationSettings[2].min = -w2
			locationSettings[2].max = w2
			locationSettings[3].default = math.floor(h2 - locationSettings[4].default / 2)
			locationSettings[3].min = -h2
			locationSettings[3].max = h2
			locationSettings[4].max = w
			locationSettings[5].max = h
			if settings.selected then
				updateLocationSettings()
			end
		end
		EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ALL_GUI_SCREENS_RESIZED, getScreenDimensions)

		locationSettings =
			settings:AddSettings(
			{
				{
					type = LibHarvensAddonSettings.ST_CHECKBOX,
					label = GetString(SI_PBSMINIMAP_SHOW_IN_SETTINGS),
					default = false,
					getFunction = function()
						return self.wasMapAdded
					end,
					setFunction = function(value)
						if value then
							addMap()
						else
							addonSelected()
						end
					end
				},
				{
					type = LibHarvensAddonSettings.ST_SLIDER,
					label = GetString(SI_PBSMINIMAP_GRID_X),
					tooltip = GetString(SI_PBSMINIMAP_GRID_TOOLTIP),
					default = 0,
					min = -100000,
					max = 100000,
					step = 1,
					getFunction = function()
						return math.floor(self.account.x / 8)
					end,
					setFunction = function(value)
						if inUpdate then
							return
						end
						inUpdate = true
						self.account.x = value * 8
						self:RestorePosition()
						updateLocationSettings()
						inUpdate = false
					end
				},
				{
					type = LibHarvensAddonSettings.ST_SLIDER,
					label = GetString(SI_PBSMINIMAP_GRID_Y),
					tooltip = GetString(SI_PBSMINIMAP_GRID_TOOLTIP),
					default = 0,
					min = -100000,
					max = 100000,
					step = 1,
					getFunction = function()
						return math.floor(self.account.y / 8)
					end,
					setFunction = function(value)
						if inUpdate then
							return
						end
						inUpdate = true
						self.account.y = value * 8
						self:RestorePosition()
						updateLocationSettings()
						inUpdate = false
					end
				},
				{
					type = LibHarvensAddonSettings.ST_SLIDER,
					label = GetString(SI_PBSMINIMAP_GRID_W),
					tooltip = GetString(SI_PBSMINIMAP_GRID_TOOLTIP),
					default = 304 / 8,
					min = 14,
					max = 100000,
					step = 1,
					getFunction = function()
						return math.floor(ZO_WorldMapScroll:GetWidth() / 8)
					end,
					setFunction = function(value)
						if inUpdate then
							return
						end
						inUpdate = true
						value = value * 8
						self.account.width = ZO_WorldMap:GetWidth() - ZO_WorldMapScroll:GetWidth() + value
						ZO_WorldMapScroll:SetWidth(value)
						if addon.modeData.keepSquare then
							self.account.height = ZO_WorldMap:GetHeight() - ZO_WorldMapScroll:GetHeight() + value
							ZO_WorldMapScroll:SetHeight(value)
						end
						self:RestorePosition()
						updateLocationSettings()
						inUpdate = false
					end
				},
				{
					type = LibHarvensAddonSettings.ST_SLIDER,
					label = GetString(SI_PBSMINIMAP_GRID_H),
					tooltip = GetString(SI_PBSMINIMAP_GRID_TOOLTIP),
					default = 304 / 8,
					min = 14,
					max = 100000,
					step = 1,
					getFunction = function()
						return math.floor((addon.modeData.keepSquare and ZO_WorldMapScroll:GetWidth() or ZO_WorldMapScroll:GetHeight()) / 8)
					end,
					setFunction = function(value)
						if inUpdate then
							return
						end
						inUpdate = true
						value = value * 8
						self.account.height = ZO_WorldMap:GetHeight() - ZO_WorldMapScroll:GetHeight() + value
						ZO_WorldMapScroll:SetHeight(value)
						if addon.modeData.keepSquare then
							self.account.width = ZO_WorldMap:GetWidth() - ZO_WorldMapScroll:GetWidth() + value
							ZO_WorldMapScroll:SetWidth(value)
						end
						self:RestorePosition()
						updateLocationSettings()
						inUpdate = false
					end
				}
			}
		)
		getScreenDimensions()

		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_DROPDOWN,
				label = GetString(SI_PBSMINIMAP_BORDER_STYLE),
				items = lookup.frameStyles,
				default = lookup.frameToFile[self.accountDefaults.frameStyle].name,
				getFunction = function()
					return lookup.frameToFile[self.account.frameStyle].name
				end,
				setFunction = function(combobox, name, item)
					if self.account.frameStyle ~= item.data.value then
						local style = lookup.frameToFile[self.account.frameStyle]
						if style and style.data.reset then
							style.data.reset(self.account, self.background, ZO_WorldMapMapFrame)
						end
						self.account.frameStyle = item.data.value
						self:UpdateBorder()
					end
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = GetString(SI_PBSMINIMAP_BORDER_OPACITY),
				tooltip = GetString(SI_PBSMINIMAP_BORDER_OPACITY_TOOLTIP),
				min = 0,
				max = 100,
				step = 1,
				default = self.accountDefaults.borderAlpha,
				unit = "%",
				getFunction = function()
					return self.account.borderAlpha
				end,
				setFunction = function(value)
					self.account.borderAlpha = value
					self:UpdateBorder()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_DROPDOWN,
				label = GetString(SI_PBSMINIMAP_TITLE_FONT),
				items = lookup.fonts,
				default = lookup.nameToFont[self.accountDefaults.titleFont].name,
				getFunction = function()
					return lookup.nameToFont[self.account.titleFont].name
				end,
				setFunction = function(combobox, name, item)
					self.account.titleFont = item.data
					self:UpdateBorder()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_DROPDOWN,
				label = GetString(SI_PBSMINIMAP_TITLE_FONT_SIZE),
				items = lookup.fontSizes,
				default = lookup.nameToFontSize[self.accountDefaults.titleFontSize].name,
				getFunction = function()
					return lookup.nameToFontSize[self.account.titleFontSize].name
				end,
				setFunction = function(combobox, name, item)
					self.account.titleFontSize = item.data.size
					self.lastTitleFont = ""
					self:UpdateBorder()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_COLOR,
				label = GetString(SI_PBSMINIMAP_TITLE_COLOR),
				default = self.accountDefaults.titleColor,
				getFunction = function()
					return self.titleColor:UnpackRGB()
				end,
				setFunction = function(newR, newG, newB, newA)
					self.titleColor:SetRGB(newR, newG, newB)
					self.account.titleColor = {self.titleColor:UnpackRGB()}
					self:UpdateBorder()
				end
			}
		)
		do
			local items = {
				{name = "Top", data = true},
				{name = "Bottom", data = false}
			}
			settings:AddSetting(
				{
					type = LibHarvensAddonSettings.ST_DROPDOWN,
					label = GetString(SI_PBSMINIMAP_TITLE_POSITION),
					items = items,
					default = items[self.accountDefaults.titleAtTop and 1 or 2].name,
					getFunction = function()
						return items[self.account.titleAtTop and 1 or 2].name
					end,
					setFunction = function(combobox, name, item)
						self.account.titleAtTop = item.data
						self:UpdateBorder()
					end
				}
			)
		end
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_SHOW_FULL_TITLE),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_FULL_TITLE_TOOLTIP),
				default = self.accountDefaults.showFullTitle,
				getFunction = function()
					return self.account.showFullTitle
				end,
				setFunction = function(value)
					self.account.showFullTitle = value
					ZO_WorldMapTitle:SetText(ZO_WorldMap_GetMapTitle(GetPlayerLocationName(), GetPlayerActiveSubzoneName()))
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_KEEP_SQUARE),
				tooltip = GetString(SI_PBSMINIMAP_KEEP_SQUARE_TOOLTIP),
				default = true,
				getFunction = function()
					return self.modeData.keepSquare
				end,
				setFunction = function(value)
					self.account.keepSquare = value
					self.modeData.keepSquare = value
				end
			}
		)
		do
			local Modes = {
				{name = GetString(SI_PBSMINIMAP_SHOW_CLOCK0), data = {false, false}},
				{name = GetString(SI_PBSMINIMAP_SHOW_CLOCK1), data = {true, false}},
				{name = GetString(SI_PBSMINIMAP_SHOW_CLOCK2), data = {false, true}},
				{name = GetString(SI_PBSMINIMAP_SHOW_CLOCK3), data = {true, true}}
			}
			local ModeToData = {}
			for i = 1, #Modes do
				ModeToData[i] = Modes[i]
			end
			settings:AddSetting(
				{
					type = LibHarvensAddonSettings.ST_DROPDOWN,
					label = GetString(SI_PBSMINIMAP_SHOW_CLOCK),
					tooltip = GetString(SI_PBSMINIMAP_SHOW_CLOCK_TOOLTIP),
					items = Modes,
					default = ModeToData[4].name,
					getFunction = function()
						local mode = 0
						if self.account.showRealTimeClock then
							mode = mode + 1
						end
						if self.account.showInGameClock then
							mode = mode + 2
						end
						return (ModeToData[mode + 1] or ModeToData[4]).name
					end,
					setFunction = function(combobox, name, item)
						local account = self.account
						account.showRealTimeClock = item.data[1]
						account.showInGameClock = item.data[2]
						account.showClock = account.showRealTimeClock or account.showInGameClock
						self:UpdateBorder()
					end
				}
			)
		end
		do
			local Modes = {
				{name = "12h", data = TIME_FORMAT_PRECISION_TWELVE_HOUR},
				{name = "24h", data = TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR}
			}
			local ModeToData = {}
			for i = 1, #Modes do
				ModeToData[Modes[i].data] = Modes[i]
			end
			settings:AddSetting(
				{
					type = LibHarvensAddonSettings.ST_DROPDOWN,
					label = GetString(SI_PBSMINIMAP_TIME_FORMAT),
					items = Modes,
					default = ModeToData[self.accountDefaults.timeFormat].name,
					getFunction = function()
						return (ModeToData[self.account.timeFormat] or ModeToData[self.accountDefaults.timeFormat]).name
					end,
					setFunction = function(combobox, name, item)
						self.account.timeFormat = item.data
					end
				}
			)
		end
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_SHOW_CAMERA_HEADING),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_CAMERA_HEADING_TOOLTIP),
				default = self.accountDefaults.showCameraAngle,
				getFunction = function()
					return self.account.showCameraAngle
				end,
				setFunction = function(value)
					self.account.showCameraAngle = value
					if value then
						self:InitCameraAngle()
					end
					self.cameraAngle = 0
					if self.cameraAngleLeft then
						self.cameraAngleLeft:SetHidden(not value)
						self.cameraAngleRight:SetHidden(not value)
					end
					settings:UpdateControls()
				end
			}
		)
		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_SLIDER,
				label = " |u12:0::|u" .. GetString(SI_PBSMINIMAP_CAMERA_HEADING_ANGLE),
				tooltip = GetString(SI_PBSMINIMAP_CAMERA_HEADING_ANGLE_TOOLTIP),
				min = 20,
				max = 70,
				step = 1,
				default = self.accountDefaults.cameraAngle,
				unit = "°",
				getFunction = function()
					return self.account.cameraAngle
				end,
				setFunction = function(value)
					self.account.cameraAngle = value
					self.cameraAngleRad = value * 0.0174532925199 -- pi/180°
				end,
				disable = function()
					return not self.account.showCameraAngle
				end
			}
		)
		do
			local Modes = {
				{
					name = GetString(SI_PBSMINIMAP_ZONEALERTMODE_ALWAYS),
					data = self.zoneAlertMode.Always
				},
				{
					name = GetString(SI_PBSMINIMAP_ZONEALERTMODE_MAP_HIDDEN),
					data = self.zoneAlertMode.MiniMapHidden
				},
				{
					name = GetString(SI_PBSMINIMAP_ZONEALERTMODE_NEVER),
					data = self.zoneAlertMode.Never
				}
			}
			local ModeToData = {}
			for i = 1, #Modes do
				ModeToData[Modes[i].data] = Modes[i]
			end
			settings:AddSetting(
				{
					type = LibHarvensAddonSettings.ST_DROPDOWN,
					label = GetString(SI_PBSMINIMAP_ZONE_CHANGE_ALERT),
					items = Modes,
					default = ModeToData[self.accountDefaults.zoneAlertMode].name,
					getFunction = function()
						return (ModeToData[self.account.zoneAlertMode] or ModeToData[self.accountDefaults.zoneAlertMode]).name
					end,
					setFunction = function(combobox, name, item)
						self.account.zoneAlertMode = item.data
					end
				}
			)
		end
		do
			local Modes = {
				{name = GetString(SI_PBSMINIMAP_COMPASSMODE_UNTOUCHED), data = self.compassMode.Untouched},
				{name = GetString(SI_PBSMINIMAP_COMPASSMODE_HIDDEN), data = self.compassMode.Hidden},
				{name = GetString(SI_PBSMINIMAP_COMPASSMODE_SHOWN), data = self.compassMode.Shown}
			}
			local ModeToData = {}
			for i = 1, #Modes do
				ModeToData[Modes[i].data] = Modes[i]
			end
			settings:AddSetting(
				{
					type = LibHarvensAddonSettings.ST_DROPDOWN,
					label = GetString(SI_PBSMINIMAP_SHOW_COMPASS),
					tooltip = GetString(SI_PBSMINIMAP_SHOW_COMPASS_TOOLTIP),
					items = Modes,
					default = ModeToData[self.accountDefaults.enableCompass].name,
					getFunction = function()
						return (ModeToData[self.account.enableCompass] or ModeToData[self.accountDefaults.enableCompass]).name
					end,
					setFunction = function(combobox, name, item)
						self.account.enableCompass = item.data
						self:UpdateCompass()
					end
				}
			)
		end

		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_SHOW_ON_TOP),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_ON_TOP_TOOLTIP),
				default = self.accountDefaults.showOnTop,
				getFunction = function()
					return self.account.showOnTop
				end,
				setFunction = function(value)
					self.account.showOnTop = value
					self:UpdateDrawLevel()
				end
			}
		)

		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_SHOW_ALL_TRAVEL_NODES),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_ALL_TRAVEL_NODES_TOOLTIP),
				default = self.accountDefaults.showAllTravelNodes,
				getFunction = function()
					return self.account.showAllTravelNodes
				end,
				setFunction = function(value)
					self.account.showAllTravelNodes = value
				end
			}
		)

		if not ZO_IsConsoleOrGameCoreUI() then
			settings:AddSetting(
				{
					type = LibHarvensAddonSettings.ST_SECTION,
					label = GetString(SI_PBSMINIMAP_FRAMEDROP_DEBUG)
				}
			)
		end

		settings:AddSetting(
			{
				type = LibHarvensAddonSettings.ST_CHECKBOX,
				label = GetString(SI_PBSMINIMAP_SHOW_FREEZE_WARNING),
				tooltip = GetString(SI_PBSMINIMAP_SHOW_FREEZE_WARNING_TOOLTIP),
				default = false,
				getFunction = function()
					return async:GetDebug()
				end,
				setFunction = function(value)
					self.account.debug = value
					async:SetDebug(value)
				end
			}
		)
	end
end
