local LCCC = LibCodesCommonCode
local Internal = LibCharacterKnowledgeInternal
local Public = LibCharacterKnowledge
local SM = Internal.SettingsManager


--------------------------------------------------------------------------------
-- Settings Panel
--------------------------------------------------------------------------------

function Internal.RegisterSettingsPanel( )
	local LHAS = LibHarvensAddonSettings

	if (LHAS) then
		SM.lhas = true

		local panel = LHAS:AddAddon(Internal.name, {
			allowRefresh = true,
		})

		local divider = {
			type = LHAS.ST_LABEL,
			label = string.format("|c%s%s|r", ZO_NORMAL_TEXT:ToHex(), string.rep("_", 16)),
		}

		local controls = {
			--------------------
			{
				type = LHAS.ST_LABEL,
				label = GetString(SI_LCK_SETTINGS_MAIN_SECTION),
			},
			--------------------
			divider,
			--------------------
			{
				type = LHAS.ST_DROPDOWN,
				label = GetString(SI_LCK_SETTINGS_SERVER),
				items = SM.choicesFuncs.server,
				getFunction = function() return { data = SM.server } end,
				setFunction = function(_, _, entry) SM.ChangeSelector("server", entry.data) end,
			},
			--------------------
			{
				type = LHAS.ST_DROPDOWN,
				label = GetString(SI_LCK_SETTINGS_ACCOUNT),
				items = SM.choicesFuncs.account,
				getFunction = function() return { data = SM.account } end,
				setFunction = function(_, _, entry) SM.ChangeSelector("account", entry.data) end,
				disable = function() return SM.server == 0 end,
			},
			--------------------
			{
				type = LHAS.ST_DROPDOWN,
				label = GetString(SI_LCK_SETTINGS_CHARACTER),
				items = SM.choicesFuncs.character,
				getFunction = function() return { data = SM.charId } end,
				setFunction = function(_, _, entry) SM.ChangeSelector("charId", entry.data) end,
				disable = function() return SM.account == 0 end,
			},
			--------------------
			divider,
			--------------------
			{
				type = LHAS.ST_LABEL,
				label = SM.GetSelectionDescription,
			},
			--------------------
			{
				type = LHAS.ST_DROPDOWN,
				label = GetString(SI_ADDON_MANAGER_ENABLED),
				items = SM.choicesFuncs.enablement,
				getFunction = function() return { data = SM.GetOrSetSetting("enabled") } end,
				setFunction = function(_, _, entry) SM.GetOrSetSetting("enabled", entry.data, true) end,
				disable = function() return SM.account == 0 end,
			},
		}

		for i, category in ipairs(Internal.DataStores) do
			-- Index 1-3 correspond to the "traditional" categories in Internal.IndexedCategories
			local widgetType = (i <= 3) and "trackQuality" or "trackOnOff"
			table.insert(controls, {
				type = LHAS.ST_DROPDOWN,
				label = Internal.CategoryLabels[category],
				items = SM.choicesFuncs[widgetType],
				getFunction = function() return { data = SM.GetOrSetSetting(category) } end,
				setFunction = function(_, _, entry) SM.GetOrSetSetting(category, entry.data) end,
				disable = SM.IsSelectedCharacterDisabled,
			})
		end

		LCCC.ConcatTables(controls, {
			--------------------
			{
				type = LHAS.ST_DROPDOWN,
				label = GetString(SI_LCK_SETTINGS_PRIORITY),
				items = SM.choicesFuncs.priority,
				getFunction = function() return { data = SM.GetOrSetSetting("priority") } end,
				setFunction = function(_, _, entry) SM.GetOrSetSetting("priority", entry.data, true) end,
				disable = SM.IsSelectedCharacterDisabled,
				tooltip = SI_LCK_SETTINGS_PRIORITY_HELP,
			},
			--------------------
			divider,
			--------------------
			{
				type = LHAS.ST_LABEL,
				label = GetString(SI_LCK_SETTINGS_RANKING_PREVIEW),
			},
			--------------------
			{
				type = LHAS.ST_LABEL,
				label = SM.GetRankingsList,
			},
			--------------------
			{
				-- Dummy control to allow users to scroll to the bottom
				type = LHAS.ST_DROPDOWN,
				label = "",
				items = SM.options.empty,
				getFunction = LCCC.NOP,
				setFunction = LCCC.NOP,
				disable = true,
			},
		})

		panel:AddSettings(controls)
	end
end


--------------------------------------------------------------------------------
-- Public Access
--------------------------------------------------------------------------------

Public.OpenSettingsPanel = LCCC.NOP
