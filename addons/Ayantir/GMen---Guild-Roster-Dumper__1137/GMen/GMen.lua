--[[
Author: Ayantir
Filename: GMen.lua
Version: 0.1
]]--

GMen = GMen or {}
GMen.name = "GMen"
GMen.author = "Ayantir"
GMen.version = "0.1"

local LAM = LibStub('LibAddonMenu-2.0')

local defaults = {
	settings = {
		sortBy1 = 1,
		sortBy2 = 2,
		bbCode = true,
		showClass = true,
		showLevel = true,
		showAlliance = false,
		shortenAlliance = true,
		format = "%userid% %character% %class% %alliance% %level%",
		bbCodeTags = {
			rankName = "[size=14pt][b]%s :[/b][/size]",
			account = "[color=red][i]%s[/i][/color]",
			character = "[color=blue][b]%s[/b][/color]",
			className = "[i][color=purple]%s[/color][/i]",
			alliance = "%s",
			level = "[i]%s[/i]",
			veteranRank = "[i]%s[/i]",
		}
	}
}



local function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
	 
end

function GMen.dumpCharInfo(data, bbCode)

	local account = data.account
	if bbCode then account = string.format(GMen.opts.settings.bbCodeTags.account, account) end

	local character = data.character
	if bbCode then character = string.format(GMen.opts.settings.bbCodeTags.character, character) end
	
	local class
	if GMen.opts.settings.showClass then
		class = zo_strformat(SI_CLASS_NAME, GetClassName(data.gender, data.class))
		if bbCode then class = string.format(GMen.opts.settings.bbCodeTags.className, class) end
	else
		class = ""
	end
	
	local alliance
	if GMen.opts.settings.showAlliance then
		if GMen.opts.settings.shortenAlliance then
			if data.alliance == 1 then
				alliance = "[AD]"
			elseif data.alliance == 2 then
				alliance = "[EP]"
			else
				alliance = "[DC]"
			end
		else
			alliance	= zo_strformat(SI_ALLIANCE_NAME, GetAllianceName(data.alliance))
		end
		if bbCode then alliance = string.format(GMen.opts.settings.bbCodeTags.alliance, alliance) end
	else
		alliance = ""
	end
	
	local level
	if GMen.opts.settings.showLevel then
		level = data.level
		if level >= 50 then
			level = "V" .. (level - 49)
			if bbCode then level = string.format(GMen.opts.settings.bbCodeTags.veteranRank, level) end
		else
			level = "lvl " .. level
			if bbCode then
				level = string.format(GMen.opts.settings.bbCodeTags.level, level)
			end
		end
	else
		level = ""
	end
	
	local line = GMen.opts.settings.format
	line = string.gsub(line, "%%userid%%", account)
	line = string.gsub(line, "%%character%%", character)
	line = string.gsub(line, "%%class%%", class)
	line = string.gsub(line, "%%alliance%%", alliance)
	line = string.gsub(line, "%%level%%", level)
	line = string.gsub(line, "%s%s%s%s", "%s")
	line = string.gsub(line, "%s%s%s", "%s")
	line = string.gsub(line, "%s%s", "%s")
	
	return line
	
end

function GMen.getKeyName(keyNameInSettings)

	if GMen.opts.settings[keyNameInSettings] == 1 then
		return "rankIndex"
	elseif GMen.opts.settings[keyNameInSettings] == 2 then
		return "level"
	elseif GMen.opts.settings[keyNameInSettings] == 3 then
		return "account"
	end
	
end

function GMen.dump()

	local guildNameToDump = GMen.opts.settings.guildToDump
	local guildToDump
	local result
	
	for guild = 1, GetNumGuilds() do
		
		-- Guildname
		local guildId = GetGuildId(guild)
		local guildName = GetGuildName(guildId)
		
		if guildNameToDump == guildName then
			guildToDump = guildId
		end
	
	end
	
	if guildToDump then
		result = GMen.dumpGuild(guildToDump)
	end
	
	if result then
		CHAT_SYSTEM:AddMessage(result)
		CHAT_SYSTEM:Maximize()
	else
		CHAT_SYSTEM:AddMessage(nothingStr)
	end
	
end

function GMen.dumpGuild(guildId)

	local guildName = GetGuildName(guildId)
	GMen.db = {}
	
	if guildName then
	
		-- Iterate over each guild member
		for member = 1, GetNumGuildMembers(guildId) do
			
			local account, _, rankIndex, playerStatus = GetGuildMemberInfo(guildId, member)
			local hasChar, rawCharacterName, zoneName, classType, alliance, level, veteranRank = GetGuildMemberCharacterInfo(guildId, member)
			local rankName = GetGuildRankCustomName(guildId, rankIndex)
			if rankName == "" then rankName = GetFinalGuildRankName(guildId, rankIndex) end
			if level == 50 then level = 49 + veteranRank end
			
			if hasChar and rawCharacterName then
				
				-- Remove extra characters.
				character = zo_strformat(SI_UNIT_NAME, rawCharacterName)
				GMen.db[account] = {
					account = account,
					character = character,
					rankIndex = rankIndex,
					rankName = rankName,
					status = playerStatus,
					class = classType,
					alliance = alliance,
					level = level,
					gender = GetGenderFromNameDescriptor(rawCharacterName),
				}
				
			end
		end
		
		local firstOrderKey = GMen.getKeyName("sortBy1")
		local secondOrderKey = GMen.getKeyName("sortBy2")

		local bbCode
		if GMen.opts.settings.bbCode then
			bbCode = true
		end
		
		local categorizeByRank, actualRank
		if firstOrderKey == "rankIndex" then
			categorizeByRank = true
		end
		
		GMen.opts.dump = {}
		
		for k, v in spairs(GMen.db, function(t, a, b)
			if t[b][firstOrderKey] > t[a][firstOrderKey] then
				return t[b][firstOrderKey] > t[a][firstOrderKey]
			elseif t[b][firstOrderKey] == t[a][firstOrderKey] then
				if t[b][secondOrderKey] > t[a][secondOrderKey] then
					return t[b][secondOrderKey] > t[a][secondOrderKey]
				end
			end
		end) do
			
			local data
			
			if categorizeByRank and actualRank ~= v.rankIndex then
				data = v.rankName
				if bbCode then data = string.format(GMen.opts.settings.bbCodeTags.rankName, data) end
				actualRank = v.rankIndex
				
				table.insert(GMen.opts.dump, "")
				table.insert(GMen.opts.dump, "")
				table.insert(GMen.opts.dump, data)
				table.insert(GMen.opts.dump, " ")
				
			end
			
			table.insert(GMen.opts.dump, GMen.dumpCharInfo(v, bbCode))
			
		end
		
		return GMen.lang.dumpDone
		
	end
	
end

-- Load Addon into Memory
function GMen.onAddonLoaded(_, addonName)
	
	-- Protect
	if addonName ~= GMen.name then return end
	
	-- Fetch the saved variables
	GMen.opts = ZO_SavedVars:NewAccountWide('GMEN', 1, nil, defaults)
	
	-- Create control panel
	local panelData = {
		type = "panel",
		name = GMen.name,
		displayName = ZO_HIGHLIGHT_TEXT:Colorize(GMen.name),
		author = GMen.author,
		version = GMen.version,
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = "/gmen",
	}
	
	LAM:RegisterAddonPanel("GMenOptions", panelData)
	
	-- Build Menu, if reorganization trigger, it can display corrects values if LAM wasn't loaded before
	GMen.buildMenu()
	
	-- Unregisters
	EVENT_MANAGER:UnregisterForEvent(GMen.name, EVENT_ADD_ON_LOADED)
	
end

-- Build LAM Menu
function GMen.buildMenu()
	
	-- Start adding elements to control panel
	local optionsTable = {}
	
	local guildChoices = {}
	for guild = 1, GetNumGuilds() do
		
		-- Guildname
		local guildId = GetGuildId(guild)
		local guildName = GetGuildName(guildId)
		
		-- Occurs sometimes
		if(not guildName or (guildName):len() < 1) then
			guildName = "Guild " .. guildId
		end
		
		table.insert(guildChoices, guildName)
	
	end
	
	local guildindex = 0
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "dropdown",
		name = GMen.lang.guildToDump,
		tooltip = GMen.lang.guildToDumpTT,
		choices = guildChoices,
		getFunc = function() return GMen.opts.settings.guildToDump end,
		setFunc = function(choice)	GMen.opts.settings.guildToDump = choice end,
		width = "full",
		default = guildChoices[1],
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "header",
		name = GMen.lang.OptionsH,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "dropdown",
		name = GMen.lang.sortBy1,
		tooltip = GMen.lang.sortBy1,
		choices = {GMen.lang.sortByO1, GMen.lang.sortByO2, GMen.lang.sortByO3},
		getFunc = function()
			if GMen.opts.settings.sortBy1 == 1 then
				return GMen.lang.sortByO1
			elseif GMen.opts.settings.sortBy1 == 2 then
				return GMen.lang.sortByO2
			elseif GMen.opts.settings.sortBy1 == 3 then
				return GMen.lang.sortByO3
			else
				return GMen.lang.sortByO1
			end
		end,
		setFunc = function(choice)
			if choice == GMen.lang.sortByO1 then
				GMen.opts.settings.sortBy1 = 1
			elseif choice == GMen.lang.sortByO2 then
				GMen.opts.settings.sortBy1 = 2
			elseif choice == GMen.lang.sortByO3 then
				GMen.opts.settings.sortBy1 = 3
			else
				GMen.opts.settings.sortBy1 = 1
			end			
		end,
		width = "full",
		default = defaults.settings.sortBy1,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "dropdown",
		name = GMen.lang.sortBy2,
		tooltip = GMen.lang.sortBy2,
		choices = {GMen.lang.sortByO1, GMen.lang.sortByO2, GMen.lang.sortByO3},
		getFunc = function()
			if GMen.opts.settings.sortBy2 == 1 then
				return GMen.lang.sortByO1
			elseif GMen.opts.settings.sortBy2 == 2 then
				return GMen.lang.sortByO2
			elseif GMen.opts.settings.sortBy2 == 3 then
				return GMen.lang.sortByO3
			else
				return GMen.lang.sortByO3
			end
		end,
		setFunc = function(choice)
			if choice == GMen.lang.sortByO1 then
				GMen.opts.settings.sortBy2 = 1
			elseif choice == GMen.lang.sortByO2 then
				GMen.opts.settings.sortBy2 = 2
			elseif choice == GMen.lang.sortByO3 then
				GMen.opts.settings.sortBy2 = 3
			else
				GMen.opts.settings.sortBy2 = 3
			end			
		end,
		width = "full",
		default = defaults.settings.sortBy2,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "editbox",
		name = GMen.lang.format,
		tooltip = GMen.lang.formatTT,
		getFunc = function() return GMen.opts.settings.format end,
		setFunc = function(newValue) GMen.opts.settings.format = newValue end,
		width = "full",
		default = defaults.settings.format,
	}

	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "checkbox",
		name = GMen.lang.showClass,
		tooltip = GMen.lang.showClassTT,
		getFunc = function() return GMen.opts.settings.showClass end,
		setFunc = function(newValue) GMen.opts.settings.showClass = newValue end,
		width = "full",
		default = defaults.settings.showClass,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "checkbox",
		name = GMen.lang.showLevel,
		tooltip = GMen.lang.showLevelTT,
		getFunc = function() return GMen.opts.settings.showLevel end,
		setFunc = function(newValue) GMen.opts.settings.showLevel = newValue end,
		width = "full",
		default = defaults.settings.showLevel,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "checkbox",
		name = GMen.lang.showAlliance,
		tooltip = GMen.lang.showAllianceTT,
		getFunc = function() return GMen.opts.settings.showAlliance end,
		setFunc = function(newValue) GMen.opts.settings.showAlliance = newValue end,
		width = "full",
		default = defaults.settings.showAlliance,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "checkbox",
		name = GMen.lang.shortenAlliance,
		tooltip = GMen.lang.shortenAllianceTT,
		getFunc = function() return GMen.opts.settings.shortenAlliance end,
		setFunc = function(newValue) GMen.opts.settings.shortenAlliance = newValue end,
		width = "full",
		default = defaults.settings.shortenAlliance,
		disabled = function() return not GMen.opts.settings.showAlliance end,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "header",
		name = GMen.lang.bbCodeH,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "checkbox",
		name = GMen.lang.bbCode,
		tooltip = GMen.lang.bbCode,
		getFunc = function() return GMen.opts.settings.bbCode end,
		setFunc = function(newValue) GMen.opts.settings.bbCode = newValue end,
		width = "full",
		default = defaults.settings.bbCode,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "editbox",
		name = GMen.lang.rankName,
		tooltip = GMen.lang.rankNameTT,
		getFunc = function() return GMen.opts.settings.bbCodeTags.rankName end,
		setFunc = function(newValue) GMen.opts.settings.bbCodeTags.rankName = newValue end,
		width = "full",
		default = defaults.settings.bbCodeTags.rankName,
		disabled = function() return not GMen.opts.settings.bbCode end,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "editbox",
		name = GMen.lang.account,
		tooltip = GMen.lang.accountTT,
		getFunc = function() return GMen.opts.settings.bbCodeTags.account end,
		setFunc = function(newValue) GMen.opts.settings.bbCodeTags.account = newValue end,
		width = "full",
		default = defaults.settings.bbCodeTags.account,
		disabled = function() return not GMen.opts.settings.bbCode end,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "editbox",
		name = GMen.lang.character,
		tooltip = GMen.lang.characterTT,
		getFunc = function() return GMen.opts.settings.bbCodeTags.character end,
		setFunc = function(newValue) GMen.opts.settings.bbCodeTags.character = newValue end,
		width = "full",
		default = defaults.settings.bbCodeTags.character,
		disabled = function() return not GMen.opts.settings.bbCode end,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "editbox",
		name = GMen.lang.className,
		tooltip = GMen.lang.classNameTT,
		getFunc = function() return GMen.opts.settings.bbCodeTags.className end,
		setFunc = function(newValue) GMen.opts.settings.bbCodeTags.className = newValue end,
		width = "full",
		default = defaults.settings.bbCodeTags.className,
		disabled = function() return not GMen.opts.settings.bbCode end,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "editbox",
		name = GMen.lang.alliance,
		tooltip = GMen.lang.allianceTT,
		getFunc = function() return GMen.opts.settings.bbCodeTags.alliance end,
		setFunc = function(newValue) GMen.opts.settings.bbCodeTags.alliance = newValue end,
		width = "full",
		default = defaults.settings.bbCodeTags.alliance,
		disabled = function() return not GMen.opts.settings.bbCode end,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "editbox",
		name = GMen.lang.level,
		tooltip = GMen.lang.levelTT,
		getFunc = function() return GMen.opts.settings.bbCodeTags.level end,
		setFunc = function(newValue) GMen.opts.settings.bbCodeTags.level = newValue end,
		width = "full",
		default = defaults.settings.bbCodeTags.level,
		disabled = function() return not GMen.opts.settings.bbCode end,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "editbox",
		name = GMen.lang.veteranRank,
		tooltip = GMen.lang.veteranRankTT,
		getFunc = function() return GMen.opts.settings.bbCodeTags.veteranRank end,
		setFunc = function(newValue) GMen.opts.settings.bbCodeTags.veteranRank = newValue end,
		width = "full",
		default = defaults.settings.bbCodeTags.veteranRank,
		disabled = function() return not GMen.opts.settings.bbCode end,
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		title = GMen.lang.description,
		text = GMen.lang.descriptionTX,
		width = "full",
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		text = "",
		width = "full",
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		text = "",
		width = "full",
	}

	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		text = "",
		width = "full",
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		text = "",
		width = "full",
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		text = "",
		width = "full",
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		text = "",
		width = "full",
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		text = "",
		width = "full",
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		text = "",
		width = "full",
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "description",
		text = "",
		width = "full",
	}
	
	guildindex = guildindex + 1
	optionsTable[guildindex] = {
		type = "button",
		name = GMen.lang.dumpGuild,
		tooltip = GMen.lang.dumpGuild,
		func = GMen.dump,
		width = "full",
	}
	
	LAM:RegisterOptionControls("GMenOptions", optionsTable)
	
end

-- Register events
EVENT_MANAGER:RegisterForEvent(GMen.name, EVENT_ADD_ON_LOADED, GMen.onAddonLoaded)