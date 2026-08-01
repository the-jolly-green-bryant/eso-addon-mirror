local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2


--------------------------------------------------------------------------------
-- Defaults
--------------------------------------------------------------------------------

local DEFAULTS = {
	disabledModules = { },
	suppressModuleMessages = false,
	disableAnnoyingMessages = true,
	bypassPurgeSlotCheck = false,
	nearby = 0,
}


--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function CA2.LoadSettings( )
	CA2.sv = ZO_SavedVars:NewAccountWide("CombatAlertsSettings", 1, nil, DEFAULTS, nil, "$InstallationWide")

	-- Import settings from legacy
	if (not CA2.sv.statusPanel and not CA1.vars.panelMigrated) then
		CA1.vars.panelMigrated = true
		CA2.sv.statusPanel = { left = CA1.vars.panelLeft, top = CA1.vars.panelTop }
	end
	if (not CA2.sv.nearbyPos and CA1.vars.nearbyLeft and CA1.vars.nearbyTop) then
		CA2.sv.nearbyPos = { left = CA1.vars.nearbyLeft, top = CA1.vars.nearbyTop }
		CA2.sv.nearby = CA1.vars.nearbyEnabled and 2 or 0
		CA1.vars.nearbyTop = nil
		CA1.vars.nearbyLeft = nil
		CA1.vars.nearbyEnabled = nil
	end
end


--------------------------------------------------------------------------------
-- Settings Panel
--------------------------------------------------------------------------------

function CA2.RegisterSettingsPanel( )
	local LAM = LCA.GetLibAddonMenu()

	if (LAM) then
		local panelId = "CombatAlertsSettingsPanel"

		CA2.settingsPanel = LAM:RegisterAddonPanel(panelId, {
			type = "panel",
			name = GetString(SI_CA_TITLE),
			version = LCA.FormatVersion(LCA.GetAddOnVersion(CA2.NAME)),
			author = "@code65536",
			website = CA2.URL,
			donation = CA2.URL .. "#donate",
			registerForRefresh = true,
		})

		local controls = {
			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_KEYBINDINGS_CATEGORY_GENERAL,
			},
			--------------------
			{
				type = "checkbox",
				name = SI_CA_SETTINGS_SUPPRESS,
				getFunc = function() return CA2.sv.suppressModuleMessages end,
				setFunc = function(enabled) CA2.sv.suppressModuleMessages = enabled end,
			},
			--------------------
			{
				type = "checkbox",
				name = SI_CA_SETTINGS_DISABLE_ANNOYING,
				tooltip = table.concat(CA2.GetAnnoyingMessages(), "\n"),
				getFunc = function() return CA2.sv.disableAnnoyingMessages end,
				setFunc = function(enabled) CA2.sv.disableAnnoyingMessages = enabled end,
			},
			--------------------
			{
				type = "checkbox",
				name = SI_CA_SETTINGS_BYPASS_PURGE_CHECK,
				tooltip = SI_CA_SETTINGS_BYPASS_PURGE_CHECK_TT,
				getFunc = function() return CA2.sv.bypassPurgeSlotCheck end,
				setFunc = function(enabled) CA2.sv.bypassPurgeSlotCheck = enabled end,
			},
			--------------------
			{
				type = "slider",
				name = SI_CA_SETTINGS_NEARBY,
				min = 0,
				max = 4,
				step = 1,
				clampInput = true,
				getFunc = function() return CA2.sv.nearby end,
				setFunc = function( value )
					CA2.sv.nearby = value
					CA2.NearbyToggle(value > 0)
				end,
			},

			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_CA_SETTINGS_REPOSITION,
			},
		}

		if (not ZO_IsConsoleOrGameCoreUI()) then
			LCA.ConcatTables(controls, {
				--------------------
				{
					type = "button",
					name = SI_CA_SETTINGS_MOVE_ELEMENTS,
					tooltip = SI_CA_SETTINGS_MOVE_ELEMENTS_TT,
					func = CA2.ShowPlaceholders,
					width = "half",
				},
				--------------------
				{
					type = "button",
					name = SI_CA_SETTINGS_RESET_ELEMENTS,
					func = CA2.ResetPositions,
					width = "half",
				},
			})
		else
			local elements, ids = CA2.GetRawPlaceholders()
			local names = { }
			local selected = ids[1]

			for _, id in ipairs(ids) do
				table.insert(names, GetString(elements[id].label))
			end

			LCA.ConcatTables(controls, {
				--------------------
				{
					type = "dropdown",
					name = SI_CA_SETTINGS_MOVE_ELEMENTS,
					choices = names,
					choicesValues = ids,
					getFunc = function() return selected end,
					setFunc = function(id) selected = id end,
				},
				--------------------
				{
					type = "button",
					name = SI_CA_SETTINGS_GAMEPAD_MOVE,
					tooltip = zo_strformat(SI_CA_SETTINGS_GAMEPAD_MOVE_TT, zo_iconFormat(GetGamepadRightStickScrollIcon(), "100%", "100%")),
					func = function() CA2.StartPlaceholderGamepadMove(selected) end,
				},
				--------------------
				{
					type = "button",
					name = SI_CA_SETTINGS_RESET_ELEMENTS,
					func = CA2.ResetPositions,
				},
			})
		end

		LAM:RegisterOptionControls(panelId, LCA.ConcatTables(controls, CA2.BuildModulesSettings()))
	end
end

function CA2.BuildModulesSettings( )
	local controls = {
		{
			type = "header",
			name = SI_CA_SETTINGS_MODULES,
		},
	}

	for _, moduleId in ipairs(LCA.GetSortedKeys(CA2.registeredModules)) do
		local module = CA2.registeredModules[moduleId]

		local zoneNames = { }
		for _, zoneId in ipairs(module.ZONES) do
			table.insert(zoneNames, LCA.GetZoneName(zoneId, true))
		end

		local settingsControls = module:GetSettingsControls()
		if (#settingsControls > 0 and not ZO_IsConsoleOrGameCoreUI()) then
			table.insert(settingsControls, 1, { type = "header", name = SI_GAME_MENU_SETTINGS })
		end

		table.insert(controls, {
			type = "submenu",
			name = CA2.registeredModules[moduleId].NAME,
			controls = {
				----------------------------------------------------------------
				{
					type = "description",
					text = zo_strformat(SI_CA_SETTINGS_MODULE_INFO, table.concat(zoneNames, ", "), module.AUTHOR)
				},
				--------------------
				{
					type = "checkbox",
					name = SI_ADDON_MANAGER_ENABLED,
					getFunc = function() return not CA2.sv.disabledModules[moduleId] end,
					setFunc = function( enabled )
						if (enabled) then
							CA2.sv.disabledModules[moduleId] = nil
							CA2.LoadModulesForCurrentZone()
						else
							CA2.sv.disabledModules[moduleId] = true
							module:Unload()
						end
					end,
				},
				--------------------
				unpack(settingsControls)
			},
		})
	end

	return controls
end


--------------------------------------------------------------------------------
-- Movement Placeholders
--------------------------------------------------------------------------------

do
	local GuiRoot = GuiRoot
	local TIMER_INITIAL = 20000
	local TIMER_REFRESH = ZO_IsConsoleOrGameCoreUI() and 2000 or 10000
	local ELEMENTS = {
		Status = {
			label = SI_CA_MOVE_STATUS,
			width = 300,
			height = 200,
			checkVisible = CA2.StatusGetOwnerId,
			setPosition = CA2.StatusSetPosition,
			getDefault = LCA.StatusPanel.GetDefaultPosition,
			svName = "statusPanel",
		},
		GroupPanel = {
			label = SI_CA_MOVE_GROUP_PANEL,
			width = 320,
			height = 168,
			checkVisible = CA2.GroupPanelIsEnabled,
			setPosition = CA2.GroupPanelSetPosition,
			getDefault = LCA.GroupPanel.GetDefaultPosition,
			svName = "groupPanel",
		},
		Nearby = {
			label = SI_CA_MOVE_NEARBY,
			width = 160,
			height = 48,
			checkVisible = CA2.NearbyEnabled,
			setPosition = CA2.NearbySetPosition,
			getDefault = CA2.NearbyGetDefaultPosition,
			svName = "nearbyPos",
		},
	}
	local ELEMENT_IDS = { "Status", "GroupPanel", "Nearby" }

	local MP = {
		name = "CA_Placeholder",
		enabled = false,
	}

	function MP.GetPlaceholders( )
		if (not MP.placeholders) then
			MP.placeholders = { }
			for id, data in pairs(ELEMENTS) do
				local control = WINDOW_MANAGER:CreateControlFromVirtual(MP.name .. id, GuiRoot, "CA_MovementPlaceholder")
				control:GetNamedChild("Background"):SetEdgeColor(0, 0, 0, 0)
				control:GetNamedChild("Background"):SetCenterColor(0, 0, 0.2, 0.6)
				control:GetNamedChild("Label"):SetText(GetString(data.label))
				control:SetWidth(data.width)
				control:SetHeight(data.height)

				local handler = LCA.MoveableControl:New(control)
				handler:RegisterCallback(MP.name, LCA.EVENT_CONTROL_MOVE_START, MP.ToggleTimer)
				handler:RegisterCallback(MP.name, LCA.EVENT_CONTROL_MOVE_STOP, function( pos )
					CA2.sv[data.svName] = pos
					data.setPosition(pos)
					MP.ToggleTimer(TIMER_REFRESH)
				end)

				MP.placeholders[id] = {
					control = control,
					handler = handler,
					checkVisible = data.checkVisible,
					getDefault = data.getDefault,
					svName = data.svName,
				}
			end
		end
		return MP.placeholders
	end

	function MP.ToggleTimer( duration )
		EVENT_MANAGER:UnregisterForUpdate(MP.name)
		if (duration) then
			EVENT_MANAGER:RegisterForUpdate(MP.name, duration, CA2.HidePlaceholders, true)
		end
	end

	function CA2.ShowPlaceholders( )
		MP.enabled = true
		for _, placeholder in pairs(MP.GetPlaceholders()) do
			if (not placeholder.checkVisible() or ZO_IsConsoleOrGameCoreUI()) then
				placeholder.handler:UpdatePosition(CA2.sv[placeholder.svName] or placeholder.getDefault())
				placeholder.control:SetHidden(false)
			end
		end
		MP.ToggleTimer(TIMER_INITIAL)
	end

	function CA2.HidePlaceholders( )
		MP.enabled = false
		for _, placeholder in pairs(MP.GetPlaceholders()) do
			placeholder.control:SetHidden(true)
		end
	end

	function CA2.ResetPositions( )
		for id, data in pairs(ELEMENTS) do
			CA2.sv[data.svName] = nil
			data.setPosition()
			if (MP.enabled) then
				local placeholder = MP.GetPlaceholders()[id]
				placeholder.handler:UpdatePosition(data.getDefault())
			end
		end
	end

	-- Console support

	function CA2.GetRawPlaceholders( )
		return ELEMENTS, ELEMENT_IDS
	end

	function CA2.StartPlaceholderGamepadMove( id )
		if (not MP.enabled) then
			CA2.ShowPlaceholders()
		end
		MP.GetPlaceholders()[id].handler:ToggleGamepadMove(true)
	end
end
