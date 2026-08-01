local LCCC = LibCodesCommonCode
local Internal = LibMultiAccountAchievementsInternal


--------------------------------------------------------------------------------
-- Settings Panel
--------------------------------------------------------------------------------

function Internal.RegisterSettingsPanel( )
	local LAM = LCCC.GetLibAddonMenu()

	if (LAM) then
		local panelId = "LMAASettings"

		Internal.settingsPanel = LAM:RegisterAddonPanel(panelId, {
			type = "panel",
			name = Internal.name,
			version = LCCC.FormatVersion(LCCC.GetAddOnVersion(Internal.name)),
			author = "@code65536",
			website = "https://www.esoui.com/downloads/info3925.html",
			donation = "https://www.esoui.com/downloads/info3925.html#donate",
			registerForRefresh = true,
		})

		LAM:RegisterOptionControls(panelId, {
			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_LMAA_SETTINGS_RESET_SECTION,
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
					LibMultiAccountAchievementsData = { }
					ReloadUI()
				end,
				tooltip = SI_LMAA_SETTINGS_RESET_WARNING,
				width = "half",
				isDangerous = true,
				warning = SI_LMAA_SETTINGS_RESET_WARNING,
			},

			--------------------------------------------------------------------
			{
				type = "header",
				name = SI_LMAA_SETTINGS_NOSAVE_SECTION,
			},
			--------------------
			{
				type = "editbox",
				name = SI_LMAA_SETTINGS_NOSAVE_CAPTION,
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
