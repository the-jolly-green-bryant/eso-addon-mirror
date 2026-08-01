local LCCC = LibCodesCommonCode
local Internal = LibCharacterKnowledgeInternal
local Public = LibCharacterKnowledge


--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

Internal.SettingsManager = {
	server = 0,
	account = 0,
	charId = 0,
	options = { empty = { } },
}
local SM = Internal.SettingsManager

function SM.ChangeSelector( selectorName, newValue )
	SM[selectorName] = newValue
	if (selectorName == "server") then
		SM.account = 0
		SM.charId = 0
	elseif (selectorName == "account") then
		SM.charId = 0
	end
end

function SM.GetOrSetSetting( settingName, newValue, invalidateCharacterList )
	local default = 0
	if (settingName == "enabled" and SM.charId == 0) then
		default = 1
	end

	local base, key
	local canMinimize = true
	if (SM.server == 0) then
		base = Internal.vars
		key = "defaults"
		canMinimize = false
	elseif (SM.charId ~= 0) then
		base = Internal.characters[SM.server][SM.charId]
		key = "settings"
	else
		base = Internal.accounts[SM.server]
		if (SM.account ~= 0) then
			key = SM.account
		else
			key = "defaults"
		end
	end

	if (newValue == nil) then
		-- Get setting
		return base[key] and base[key][settingName] or default
	else
		-- Set setting
		if (not base[key]) then
			base[key] = { }
		end
		base[key][settingName] = (newValue ~= default or not canMinimize) and newValue or nil
		if (canMinimize and next(base[key]) == nil) then
			base[key] = nil
		end
		Internal.NotifyRefresh(invalidateCharacterList)
	end
end

function SM.IsSelectedCharacterDisabled( )
	return SM.server ~= 0 and SM.charId ~= 0 and not Internal.IsCharacterEnabled(SM.server, SM.charId)
end

function SM.IsIndividualCharacterSelected( )
	return SM.charId ~= 0
end

function SM.GetSelectionDescription( )
	if (SM.server == 0) then
		return GetString(SI_LCK_SETTINGS_SYSTEM_DEFAULTS)
	elseif (SM.account == 0) then
		return zo_strformat(SI_LCK_SETTINGS_SERVER_DEFAULTS, SM.server)
	elseif (SM.charId == 0) then
		return zo_strformat(SI_LCK_SETTINGS_ACCOUNT_DEFAULTS, SM.account, SM.server)
	else
		return zo_strformat(SI_LCK_SETTINGS_CHAR_SPECIFC, Public.GetCharacterNameAndAccount(SM.server, SM.charId) or "", SM.server)
	end
end

function SM.GetRankingsList( )
	if (SM.server == 0) then return "" end

	local characters = Public.GetCharacterList(SM.server)
	local result

	if (#characters == 0) then
		result = GetString(SI_ANTIQUITY_EMPTY_LIST)
	else
		local results = { }
		for _, character in ipairs(characters) do
			if (SM.charId == character.id or (SM.charId == 0 and SM.account == character.account)) then
				table.insert(results, string.format("|cFFFF00%s|r", character.name))
			else
				table.insert(results, character.name)
			end
		end
		result = table.concat(results, ", ")
	end

	return result
end


--------------------------------------------------------------------------------
-- Choices functions
-- The "combined" tables are non-nil only if using LHAS on console
--------------------------------------------------------------------------------

SM.choicesFuncs = {
	enablement = function( )
		local o = SM.options
		if (SM.server == 0 or SM.account == 0) then
			return o.empty, o.empty
		elseif (SM.charId == 0) then
			return o.combinedE_ND or o.labelsE_ND, o.valuesE_ND
		else
			return o.combinedE or o.labelsE, o.valuesE
		end
	end,
	trackQuality = function( )
		local o = SM.options
		if (SM.server == 0) then
			return o.combined4_ND or o.labels4_ND, o.values4_ND
		else
			return o.combined4 or o.labels4, o.values4
		end
	end,
	trackOnOff = function( )
		local o = SM.options
		if (SM.server == 0) then
			return o.combined2_ND or o.labels2_ND, o.values2_ND
		else
			return o.combined2 or o.labels2, o.values2
		end
	end,
	priority = function( )
		local o = SM.options
		if (SM.server == 0) then
			return o.combinedP_ND or o.labelsP_ND, o.valuesP_ND
		else
			return o.combinedP or o.labelsP, o.valuesP
		end
	end,
}


--------------------------------------------------------------------------------
-- Choices for server/account/character selectors
--------------------------------------------------------------------------------

do
	local Cache = { }

	local CacheCheck = {
		account = function() return Cache.account.server ~= SM.server end,
		character = function() return Cache.character.server ~= SM.server or Cache.character.account ~= SM.account end,
	}

	local Generators = {
		server = function( )
			local labels = { GetString(SI_LCK_SETTINGS_SYSTEM_DEFLABEL) }
			local values = { 0 }
			local servers = Public.GetServerList()
			return LCCC.ConcatTables(labels, servers), LCCC.ConcatTables(values, servers)
		end,
		account = function( )
			local characters = Internal.characters[SM.server]
			if (characters) then
				local labels = { GetString(SI_LCK_SETTINGS_SERVER_DEFLABEL) }
				local values = { 0 }
				local seen = { }
				for _, data in pairs(characters) do
					if (not seen[data.account]) then
						seen[data.account] = true
					end
				end
				local accounts = LCCC.GetSortedKeys(seen, Internal.userId)
				return LCCC.ConcatTables(labels, accounts), LCCC.ConcatTables(values, accounts)
			end
		end,
		character = function( )
			local characters = Internal.characters[SM.server]
			if (characters and SM.account ~= 0) then
				local labels = { GetString(SI_LCK_SETTINGS_ACCOUNT_DEFLABEL) }
				local values = { 0 }
				local charIds = { }
				for charId, data in pairs(characters) do
					if (data.account == SM.account) then
						table.insert(charIds, charId)
					end
				end
				Internal.Sort(SM.server, charIds)
				for _, charId in ipairs(charIds) do
					table.insert(labels, characters[charId].name)
				end
				return labels, LCCC.ConcatTables(values, charIds)
			end
		end,
	}

	local function GetChoicesFunc( selectorName )
		return function( )
			if (not Cache[selectorName] or (CacheCheck[selectorName] and CacheCheck[selectorName]())) then
				local labels, values = Generators[selectorName]()
				Cache[selectorName] = {
					labels = labels or SM.options.empty,
					values = values or SM.options.empty,
					server = SM.server,
					account = SM.account,
				}
				if (SM.lhas) then
					local combined = { }
					for i, label in ipairs(Cache[selectorName].labels) do
						table.insert(combined, {
							name = label,
							data = Cache[selectorName].values[i],
						})
					end
					Cache[selectorName].combined = combined
				end
			end
			return Cache[selectorName].combined or Cache[selectorName].labels, Cache[selectorName].values
		end
	end

	setmetatable(SM.choicesFuncs, { __index = function( tbl, key )
		if (Generators[key]) then
			tbl[key] = GetChoicesFunc(key)
		end
		return rawget(tbl, key)
	end })
end


--------------------------------------------------------------------------------
-- Choices for other dropdown options
--------------------------------------------------------------------------------

do
	local initialized = false

	local function InitializeOptionsLists( )
		local SettingsBuildOptionsList = function( min, max, labelFunc )
			local labels = { GetString(SI_LCK_SETTINGS_USE_DEFAULT) }
			local values = { 0 }
			local labelsND = { }
			local valuesND = { }

			for i = min, max do
				table.insert(labelsND, labelFunc(i, min, max))
				table.insert(valuesND, i)
			end

			local combined, combinedND
			if (SM.lhas) then
				combined = { { name = labels[1], data = values[1] } }
				combinedND = { }
				for i, label in ipairs(labelsND) do
					local entry = {
						name = label,
						data = i,
					}
					table.insert(combined, entry)
					table.insert(combinedND, entry)
				end
			end

			return LCCC.ConcatTables(labels, labelsND), LCCC.ConcatTables(values, valuesND), labelsND, valuesND, combined, combinedND
		end
		local o = SM.options
		o.labels4, o.values4, o.labels4_ND, o.values4_ND, o.combined4, o.combined4_ND = SettingsBuildOptionsList(1, 4, function(idx) return GetString("SI_LCK_SETTINGS_TRACKING", idx) end)
		o.labels2, o.values2, o.labels2_ND, o.values2_ND, o.combined2, o.combined2_ND = SettingsBuildOptionsList(1, 2, function(idx) return GetString(idx == 1 and SI_NO or SI_YES) end)
		o.labelsE, o.valuesE, o.labelsE_ND, o.valuesE_ND, o.combinedE, o.combinedE_ND = SettingsBuildOptionsList(1, 2, function(idx) return GetString(idx == 1 and SI_YES or SI_NO) end)
		o.labelsP, o.valuesP, o.labelsP_ND, o.valuesP_ND, o.combinedP, o.combinedP_ND = SettingsBuildOptionsList(1, Internal.PRIORITY_RANKS, function( idx, min, max )
			local captions = {
				[min] = SI_SUBSAMPLINGMODE2, -- formerly SI_HIGH
				[max] = SI_SUBSAMPLINGMODE0, -- formerly SI_LOW
			}
			if (captions[idx]) then
				return string.format("%d (%s)", idx, GetString(captions[idx]))
			else
				return tostring(idx)
			end
		end)
	end

	setmetatable(SM.options, { __index = function( ... )
		if (not initialized) then
			initialized = true
			InitializeOptionsLists()
		end
		return rawget(...)
	end })
end
