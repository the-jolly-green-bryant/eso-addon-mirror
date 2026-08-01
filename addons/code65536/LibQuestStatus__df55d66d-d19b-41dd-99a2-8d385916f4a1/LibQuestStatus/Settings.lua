local LCCC = LibCodesCommonCode
local Internal = LibQuestStatusInternal
local Public = LibQuestStatus


--------------------------------------------------------------------------------
-- Settings Panel
--------------------------------------------------------------------------------

function Internal.RegisterSettingsPanel( )
	local LAM = LCCC.GetLibAddonMenu()

	if (LAM and IsKeyboardUISupported()) then
		local panelId = "LQSSettings"

		Internal.settingsPanel = LAM:RegisterAddonPanel(panelId, {
			type = "panel",
			name = Internal.name,
			version = LCCC.FormatVersion(LCCC.GetAddOnVersion(Internal.name)),
			author = "@code65536",
			website = "https://www.esoui.com/downloads/info4573.html",
			donation = "https://www.esoui.com/downloads/info4573.html#donate",
			slashCommand = "/lqs",
			registerForRefresh = true,
		})

		Internal.shareText = ""

		LAM:RegisterOptionControls(panelId, {
			--------------------------------------------------------------------
			{
				type = "description",
				text = SI_LQS_SETTINGS_CHATCOMMAND,
			},

			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_LQS_SETTINGS_SHARE_SECTION,
			},
			--------------------
			{
				type = "editbox",
				name = SI_LQS_SETTINGS_SHARE_CAPTION,
				getFunc = function() return Internal.shareText end,
				setFunc = function(text) Internal.shareText = text end,
				isMultiline = true,
				isExtraWide = true,
				maxChars = 0xFFFF,
				textType = TEXT_TYPE_ALL,
				reference = "LQS_ExportBox",
			},
			--------------------
			{
				type = "button",
				name = SI_LQS_SETTINGS_SHARE_EXPORTC,
				func = Internal.ExportCurrent,
				tooltip = SI_LQS_SETTINGS_SHARE_EXPORTCT,
				width = "half",
			},
			--------------------
			{
				type = "button",
				name = SI_LQS_SETTINGS_SHARE_IMPORT,
				func = Internal.Import,
				width = "half",
			},
			--------------------
			{
				type = "button",
				name = SI_LQS_SETTINGS_SHARE_EXPORTA,
				func = Internal.ExportAll,
				tooltip = SI_LQS_SETTINGS_SHARE_EXPORTAT,
				width = "half",
			},
			--------------------
			{
				type = "button",
				name = SI_LQS_SETTINGS_SHARE_CLEAR,
				func = function() Internal.shareText = "" end,
				width = "half",
			},

			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_LQS_SETTINGS_RESET_SECTION,
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
					LibQuestStatusData = { }
					ReloadUI()
				end,
				tooltip = SI_LQS_SETTINGS_RESET_WARNING,
				width = "half",
				isDangerous = true,
				warning = SI_LQS_SETTINGS_RESET_WARNING,
			},

			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_LQS_SETTINGS_NOSAVE_SECTION,
			},
			--------------------
			{
				type = "editbox",
				name = SI_LQS_SETTINGS_NOSAVE_CAPTION,
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
	end
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
local SHARE_TAG = "Q"
local SHARE_VERSION = 1 -- Version of the current export/import format
local SHARE_VERSION_COMPATIBILITY = {
	[SHARE_VERSION] = true,
}

local KEY_ENCODE = { ["completion"] = "C", ["active"] = "A", [1] = "1", [7] = "7" }
local KEY_DECODE = { ["C"] = "completion", ["A"] = "active", ["1"] = 1, ["7"] = 7 }

function Internal.ExportSelectText( )
	if (LQS_ExportBox and LQS_ExportBox.editbox) then
		zo_callLater(function( )
			LQS_ExportBox:UpdateValue()
			LQS_ExportBox.editbox:SelectAll()
			LQS_ExportBox.editbox:TakeFocus()
		end, 100)
	end
end

function Internal.CreateExportEntry( server, charId )
	if (Internal.DoesCharacterExist(server, charId)) then
		local data = Internal.data[server][charId]
		local payloads = { }

		Internal.PruneCooldowns(server, data, GetTimeStamp())

		for key in pairs(data) do
			local encodedKey = KEY_ENCODE[key]
			if (not encodedKey and type(key) == "number") then
				encodedKey = LCCC.Encode(key)
			end
			if (encodedKey) then
				table.insert(payloads, string.format("%s:%s", encodedKey, LCCC.Implode(LCCC.Unchunk(data[key]))))
			end
		end

		if (#payloads > 0) then
			return LDEI.Wrap(SHARE_TAG, SHARE_VERSION, {
				server,
				UndecorateDisplayName(data.account),
				data.name,
				charId,
				LCCC.Encode(data.timestamp),
				table.concat(payloads, ";"),
			}), { server = server, identifier = data.name, timestamp = data.timestamp }
		end
	end

	return "", { timestamp = 0 }
end

function Internal.ExportCurrent( )
	Internal.shareText = Internal.CreateExportEntry(Internal.server, Internal.charId) .. " "
	Internal.ExportSelectText()
end

function Internal.ExportAll( )
	local entries = { }

	for server, serverData in pairs(Internal.data) do
		for charId in pairs(serverData) do
			table.insert(entries, { Internal.CreateExportEntry(server, charId) })
		end
	end

	Internal.shareText = LDEI.ExportMultiple(entries, function(...) Internal.Msg(zo_strformat(SI_LQS_SHARE_EXPORT_LIMIT, ...)) end) .. " "
	Internal.ExportSelectText()
end

function Internal.Import( )
	if (not LDEI.Import(Internal.shareText, SHARE_TAG)) then
		Internal.Msg(GetString(SI_LQS_SHARE_IMPORT_INVALID))
	end
end

function Internal.ProcessImportData( dataset )
	local imported = 0

	for _, data in ipairs(dataset) do
		if (not SHARE_VERSION_COMPATIBILITY[data.version]) then
			return imported, SI_LQS_SHARE_IMPORT_BADVERSION
		else
			local server, account, charName, charId, timestamp, payloads = zo_strsplit(",", data.payload)
			local existingTimestamp = Internal.GetCharacterField(server, charId, "timestamp")
			timestamp = LCCC.Decode(timestamp)

			if (existingTimestamp and existingTimestamp >= timestamp) then
				Internal.Msg(zo_strformat(SI_LQS_SHARE_IMPORT_STALE, server, charName))
			else
				Internal.SetCharacterField(server, charId, "account", DecorateDisplayName(account))
				Internal.SetCharacterField(server, charId, "name", charName)
				Internal.SetCharacterField(server, charId, "timestamp", timestamp)

				for _, packed in ipairs({ zo_strsplit(";", payloads) }) do
					local encodedKey, value = zo_strsplit(":", packed)
					Internal.SetCharacterField(server, charId, KEY_DECODE[encodedKey] or LCCC.Decode(encodedKey), LCCC.Chunk(LCCC.Explode(value), COMPLETION_LINE_BYTES))
				end

				Internal.PruneCooldowns(server, charId, GetTimeStamp())

				imported = imported + 1

				Internal.Msg(zo_strformat(SI_LQS_SHARE_IMPORT_DONE, server, charName, os.date("%Y/%m/%d %H:%M", timestamp)))
			end
		end
	end

	return imported, nil
end

LCCC.RunAfterInitialLoadscreen(function( )
	LDEI.RegisterProcessor(SHARE_TAG, function( ... )
		local importedCount, stringId = Internal.ProcessImportData(...)

		if (importedCount > 0) then
			Internal.FireCallbacks(Public.EVENT_QUEST_STATUS_UPDATED, newAccount)
		end

		if (stringId) then
			Internal.Msg(GetString(stringId))
		end

		Internal.Msg(zo_strformat(SI_LQS_SHARE_IMPORT_TALLY, importedCount))
		Internal.shareText = ""
	end)
end)
