local LCCC = LibCodesCommonCode
local Internal = LibCharacterKnowledgeInternal
local Public = LibCharacterKnowledge
local SM = Internal.SettingsManager


--------------------------------------------------------------------------------
-- Settings Panel
--------------------------------------------------------------------------------

function Internal.RegisterSettingsPanel( )
	local LAM = LCCC.GetLibAddonMenu()

	if (LAM) then
		local panelId = "LCKSettings"

		Internal.settingsPanel = LAM:RegisterAddonPanel(panelId, {
			type = "panel",
			name = Internal.name,
			version = LCCC.FormatVersion(LCCC.GetAddOnVersion(Internal.name)),
			author = "@code65536",
			website = "https://www.esoui.com/downloads/info3317.html",
			donation = "https://www.esoui.com/downloads/info3317.html#donate",
			slashCommand = "/lck",
			registerForRefresh = true,
		})

		Internal.shareText = ""

		local controls = {
			--------------------------------------------------------------------
			{
				type = "description",
				text = SI_LCK_SETTINGS_CHATCOMMAND,
			},
			--------------------
			unpack(Internal.SettingsBuildMainSection())
		}

		LCCC.ConcatTables(controls, {
			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_LCK_SETTINGS_SHARE_SECTION,
			},
			--------------------
			{
				type = "editbox",
				name = SI_LCK_SETTINGS_SHARE_CAPTION,
				getFunc = function() return Internal.shareText end,
				setFunc = function(text) Internal.shareText = text end,
				isMultiline = true,
				isExtraWide = true,
				maxChars = 0xFFFF,
				textType = TEXT_TYPE_ALL,
				reference = "LCK_ExportBox",
			},
			--------------------
			{
				type = "button",
				name = SI_LCK_SETTINGS_SHARE_EXPORTC,
				func = Internal.ExportCurrent,
				tooltip = SI_LCK_SETTINGS_SHARE_EXPORTCT,
				width = "half",
			},
			--------------------
			{
				type = "button",
				name = SI_LCK_SETTINGS_SHARE_IMPORT,
				func = Internal.Import,
				width = "half",
			},
			--------------------
			{
				type = "button",
				name = SI_LCK_SETTINGS_SHARE_EXPORTA,
				func = function() Internal.ExportMultiple(true) end,
				tooltip = SI_LCK_SETTINGS_SHARE_EXPORTAT,
				width = "half",
			},
			--------------------
			{
				type = "button",
				name = SI_LCK_SETTINGS_SHARE_CLEAR,
				func = function() Internal.shareText = "" end,
				width = "half",
			},
			--------------------
			{
				type = "button",
				name = Internal.GetExportSelectedText,
				func = function() Internal.ExportMultiple(false) end,
				tooltip = SI_LCK_SETTINGS_SHARE_EXPORTST,
				width = "half",
				disabled = function() return Internal.CountExportSelection() == 0 end,
				reference = "LCK_ExportSelected",
			},

			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_LCK_SETTINGS_RESET_SECTION,
			},
			--------------------
			{
				type = "custom",
				width = "half",
			},
			--------------------
			{
				type = "button",
				name = SI_OPTIONS_RESET,
				func = function( )
					LibCharacterKnowledgeData = { }
					ReloadUI()
				end,
				tooltip = SI_LCK_SETTINGS_RESET_WARNING,
				width = "half",
				isDangerous = true,
				warning = SI_LCK_SETTINGS_RESET_WARNING,
			},

			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_LCK_SETTINGS_NOSAVE_SECTION,
			},
			--------------------
			{
				type = "editbox",
				name = SI_LCK_SETTINGS_NOSAVE_CAPTION,
				getFunc = function( )
					local accounts = { }
					if (Internal.vars.noSave) then
						for account in pairs(Internal.vars.noSave) do
							table.insert(accounts, account)
						end
						table.sort(accounts)
					end
					return table.concat(accounts, ", ")
				end,
				setFunc = function( text )
					local accounts = { zo_strsplit(", ", zo_strlower(text)) }
					if (#accounts > 0) then
						Internal.vars.noSave = { }
						for _, account in ipairs(accounts) do
							Internal.vars.noSave[DecorateDisplayName(account)] = true
						end
					else
						Internal.vars.noSave = nil
					end
				end,
				isMultiline = true,
				isExtraWide = true,
				maxChars = 0xFFF,
				textType = TEXT_TYPE_ALL,
			},
		})

		LAM:RegisterOptionControls(panelId, controls)
	end
end


--------------------------------------------------------------------------------
-- DropdownWidget
--------------------------------------------------------------------------------

local NextWidgetId = 1
local DropdownWidget = ZO_Object:Subclass()

function DropdownWidget:New( ... )
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function DropdownWidget:Initialize( widgetType, widget )
	self.id = "LCK_DropdownWidget" .. NextWidgetId
	NextWidgetId = NextWidgetId + 1
	self.updateFunc = SM.choicesFuncs[widgetType]
	self.widget = widget
	widget.reference = self.id
	widget.type = "dropdown"
	if (widget.disabled) then
		local disabled = widget.disabled
		widget.disabled = function() return disabled() or not next(widget.choices) end
	else
		widget.disabled = function() return not next(widget.choices) end
	end
end

function DropdownWidget:UpdateChoices( )
	self.widget.choices, self.widget.choicesValues = self.updateFunc()
	local control = _G[self.id]
	if (control) then
		control:UpdateChoices()
		control:UpdateValue()
	end
end

function DropdownWidget:Get( )
	return self.widget
end


--------------------------------------------------------------------------------
-- Tracking and Priority
--------------------------------------------------------------------------------

function Internal.SettingsBuildMainSection( )
	local dropdowns

	local refreshDropdowns = function( startIndex )
		for i = startIndex, #dropdowns do
			dropdowns[i]:UpdateChoices()
		end
	end

	dropdowns = {
		DropdownWidget:New("server", {
			name = SI_LCK_SETTINGS_SERVER,
			getFunc = function() return SM.server end,
			setFunc = function( newValue )
				SM.ChangeSelector("server", newValue)
				refreshDropdowns(2)
			end,
		}),
		DropdownWidget:New("account", {
			name = SI_LCK_SETTINGS_ACCOUNT,
			getFunc = function() return SM.account end,
			setFunc = function( newValue )
				SM.ChangeSelector("account", newValue)
				refreshDropdowns(3)
			end,
		}),
		DropdownWidget:New("character", {
			name = SI_LCK_SETTINGS_CHARACTER,
			getFunc = function() return SM.charId end,
			setFunc = function( newValue )
				SM.ChangeSelector("charId", newValue)
				refreshDropdowns(4)
			end,
		}),
		DropdownWidget:New("enablement", {
			name = SI_ADDON_MANAGER_ENABLED,
			getFunc = function() return SM.GetOrSetSetting("enabled") end,
			setFunc = function(newValue) SM.GetOrSetSetting("enabled", newValue, true) end,
		}),
	}

	for i, category in ipairs(Internal.DataStores) do
		-- Index 1-3 correspond to the "traditional" categories in Internal.IndexedCategories
		local widgetType = (i <= 3) and "trackQuality" or "trackOnOff"
		table.insert(dropdowns, DropdownWidget:New(widgetType, {
			name = Internal.CategoryLabels[category],
			getFunc = function() return SM.GetOrSetSetting(category) end,
			setFunc = function(newValue) SM.GetOrSetSetting(category, newValue) end,
			disabled = SM.IsSelectedCharacterDisabled,
		}))
	end

	table.insert(dropdowns, DropdownWidget:New("priority", {
		name = SI_LCK_SETTINGS_PRIORITY,
		getFunc = function() return SM.GetOrSetSetting("priority") end,
		setFunc = function(newValue) SM.GetOrSetSetting("priority", newValue, true) end,
		disabled = SM.IsSelectedCharacterDisabled,
		tooltip = SI_LCK_SETTINGS_PRIORITY_HELP,
	}))

	SM.LAMInit = function( panel )
		if (panel == Internal.settingsPanel) then
			CALLBACK_MANAGER:UnregisterCallback("LAM-BeforePanelControlsCreated", SM.LAMInit)
			refreshDropdowns(1)
		end
	end
	CALLBACK_MANAGER:RegisterCallback("LAM-BeforePanelControlsCreated", SM.LAMInit)

	local controls = {
		{
			type = "header",
			name = SI_LCK_SETTINGS_MAIN_SECTION,
		}
	}

	for _, widget in ipairs(dropdowns) do
		table.insert(controls, widget:Get())
	end

	table.insert(controls, 5,
		{
			type = "divider",
		}
	)

	table.insert(controls, 6,
		{
			type = "description",
			title = SM.GetSelectionDescription,
		}
	)

	table.insert(controls,
		{
			type = "checkbox",
			name = SI_LCK_SETTINGS_EXPORT,
			getFunc = function() return SM.charId ~= 0 and Internal.characters[SM.server][SM.charId].export == true end,
			setFunc = function( enabled )
				Internal.characters[SM.server][SM.charId].export = (enabled == true) or nil
				if (LCK_ExportSelected and LCK_ExportSelected.button) then
					LCK_ExportSelected.button:SetText(Internal.GetExportSelectedText())
				end
			end,
			disabled = function() return SM.charId == 0 or SM.IsSelectedCharacterDisabled() end,
		}
	)

	table.insert(controls,
		{
			type = "submenu",
			name = SI_LCK_SETTINGS_RANKING_PREVIEW,
			controls = {
				{
					type = "description",
					text = SM.GetRankingsList,
				},
			},
			disabled = function() return SM.server == 0 end,
		}
	)

	return controls
end


--------------------------------------------------------------------------------
-- Public Access
--------------------------------------------------------------------------------

function Public.OpenSettingsPanel( )
	if (Internal.settingsPanel) then
		LibAddonMenu2:OpenToPanel(Internal.settingsPanel)
	end
end


--------------------------------------------------------------------------------
-- Export/Import
--------------------------------------------------------------------------------

local LDEI = LibDataExportImport
local SHARE_TAG = "K"
local SHARE_VERSION = 4 -- Version of the current export/import format
local SHARE_VERSION_COMPATIBILITY = {
	[SHARE_VERSION] = true,
}

function Internal.CountExportSelection( )
	local count = 0
	for _, server in ipairs(Public.GetServerList()) do
		for _, character in ipairs(Public.GetCharacterList(server)) do
			if (Internal.characters[server][character.id].export) then
				count = count + 1
			end
		end
	end
	return count
end

function Internal.GetExportSelectedText( )
	return string.format(GetString(SI_LCK_SETTINGS_SHARE_EXPORTS), Internal.CountExportSelection())
end

function Internal.ExportSelectText( )
	if (LCK_ExportBox and LCK_ExportBox.editbox) then
		zo_callLater(function( )
			LCK_ExportBox:UpdateValue()
			LCK_ExportBox.editbox:SelectAll()
			LCK_ExportBox.editbox:TakeFocus()
		end, 100)
	end
end

function Internal.CreateExportEntry( server, charId, ignoreExportFlag )
	local data = Internal.characters[server][charId]

	if (data and (ignoreExportFlag or data.export)) then
		local knowledge = { }
		for _, category in ipairs(Internal.DataStores) do
			if (data[category]) then
				table.insert(knowledge, string.format("%s:%s", category, LCCC.Implode(LCCC.Unchunk(data[category]))))
			end
		end

		if (#knowledge > 0) then
			return LDEI.Wrap(SHARE_TAG, SHARE_VERSION, {
				server,
				UndecorateDisplayName(data.account),
				data.name,
				charId,
				LCCC.Encode(GetAPIVersion(), 1),
				LCCC.Encode(data.timestamp or 0, 1),
				table.concat(knowledge, ";"),
			}), { server = server, identifier = data.name, timestamp = data.timestamp }
		end
	end

	return "", { timestamp = 0 }
end

function Internal.ExportCurrent( )
	Internal.shareText = Internal.CreateExportEntry(Internal.server, Internal.charId, true) .. " "
	Internal.ExportSelectText()
end

function Internal.ExportMultiple( exportAll )
	local entries = { }

	for _, server in ipairs(Public.GetServerList()) do
		for _, character in ipairs(Public.GetCharacterList(server)) do
			table.insert(entries, { Internal.CreateExportEntry(server, character.id, exportAll) })
		end
	end

	Internal.shareText = LDEI.ExportMultiple(entries, function(...) Internal.Msg(zo_strformat(SI_LCK_SHARE_EXPORT_LIMIT, ...)) end) .. " "
	Internal.ExportSelectText()
end

function Internal.Import( )
	if (not LDEI.Import(Internal.shareText, SHARE_TAG)) then
		Internal.Msg(GetString(SI_LCK_SHARE_IMPORT_INVALID))
	end
end

function Internal.ProcessImportData( dataset )
	local newCharacter = false
	local imported = 0

	for _, data in ipairs(dataset) do
		if (not SHARE_VERSION_COMPATIBILITY[data.version]) then
			return imported, SI_LCK_SHARE_IMPORT_BADVERSION, newCharacter
		else
			local server, account, charName, charId, apiVersion, timestamp, knowledge = zo_strsplit(",", data.payload)
			if (LCCC.Decode(apiVersion) == GetAPIVersion()) then
				timestamp = LCCC.Decode(timestamp)

				-- Prepare the destination data tables
				if (not Internal.accounts[server]) then Internal.accounts[server] = { } end
				if (not Internal.characters[server]) then Internal.characters[server] = { } end
				if (not Internal.characters[server][charId]) then
					Internal.characters[server][charId] = { }
					newCharacter = true
				end
				local char = Internal.characters[server][charId]

				if (char.timestamp and char.timestamp >= timestamp) then
					Internal.Msg(zo_strformat(SI_LCK_SHARE_IMPORT_STALE, server, charName))
				else
					char.account = DecorateDisplayName(account)
					char.name = charName
					char.timestamp = timestamp

					for _, packed in ipairs({ zo_strsplit(";", knowledge) }) do
						local category, data, data2 = zo_strsplit(":", packed)
						if (data2) then
							data = string.format("%s:%s", data, data2)
						end
						char[category] = Internal.Chunk(LCCC.Explode(data))
					end

					imported = imported + 1

					Internal.Msg(zo_strformat(SI_LCK_SHARE_IMPORT_DONE, server, charName, os.date("%Y/%m/%d %H:%M", timestamp)))
				end
			else
				Internal.Msg(zo_strformat(SI_LCK_SHARE_IMPORT_API, server, charName))
			end
		end
	end

	return imported, nil, newCharacter
end

LCCC.RunAfterInitialLoadscreen(function( )
	LDEI.RegisterProcessor(SHARE_TAG, function( ... )
		local importedCount, stringId, newCharacter = Internal.ProcessImportData(...)

		if (importedCount > 0) then
			Internal.caches = { }
			Internal.NotifyRefresh(newCharacter)
		end

		if (stringId) then
			Internal.Msg(GetString(stringId))
		end

		if (newCharacter) then
			Internal.Msg(GetString(SI_LCK_SHARE_IMPORT_NEWCHARACTER))
		end

		Internal.Msg(zo_strformat(SI_LCK_SHARE_IMPORT_TALLY, importedCount))
		Internal.shareText = ""
	end)
end)
