-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Slash Commands --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Killz = Killz or {}

local LCLSTR = Killz.Localization

local function slashCmdHelp()
	Killz.Msg(" ")
	Killz.Msg(LCLSTR.SLASH_CMD_KZREPORT)
	Killz.Msg(LCLSTR.SLASH_CMD_KZREPORT2)
	Killz.Msg(LCLSTR.SLASH_CMD_KZREPORT3)
	Killz.Msg(" ")
	Killz.Msg(LCLSTR.SLASH_CMD_SHOW)
	Killz.Msg(LCLSTR.SLASH_CMD_HIDE)
	Killz.Msg(LCLSTR.SLASH_CMD_IMPORT)
	Killz.Msg(LCLSTR.SLASH_CMD_RESET)
	Killz.Msg(LCLSTR.SLASH_CMD_PREFS)
	Killz.Msg(" ")
	Killz.Msg(LCLSTR.SLASH_CMD_KZLAST)
	Killz.Msg(LCLSTR.SLASH_CMD_KZLAST2)
	Killz.Msg(LCLSTR.SLASH_CMD_KZLAST3)
	Killz.Msg(" ")
	Killz.Msg("/killz dbackup")
	Killz.Msg("/killz drestore")

end

local function getReportString()

	Killz.settings.sessionStats = Killz.settings.sessionStats or copyDeep(defaultStats)
	local killsPerDeath = Killz.settings.sessionStats["kills"]
  	if Killz.settings.sessionStats["kills"] > 0 and Killz.settings.sessionStats.deaths > 0 then 
		killsPerDeath = Killz.settings.sessionStats["kills"] / Killz.settings.sessionStats.deaths
	end
  
	local str =  LCLSTR.SLASH_CMD_STATS

	str = string.format(str, Killz.settings.sessionStats["kills"], Killz.settings.sessionStats.deaths, 
						Killz.settings.sessionStats.killStreak, killsPerDeath, 
						Killz.settings.sessionStats.killingBlows, Killz.settings.sessionStats.alliancePoints)
    return str
end

local function slashCmdReport(params)

	Killz.settings.sessionStats = Killz.settings.sessionStats or copyDeep(defaultStats)
	local killsPerDeath = Killz.settings.sessionStats["kills"]
  	if Killz.settings.sessionStats["kills"] > 0 and Killz.settings.sessionStats.deaths > 0 then 
		killsPerDeath = Killz.settings.sessionStats["kills"] / Killz.settings.sessionStats.deaths
	end
  
	local str = getReportString()

	-- Session time based stats
	if Killz.settings.startTimeSecs and Killz.settings.reportTimeBasedStats == true then 
		local endTime = Killz.settings.endTimeSecs or 0
		if endTime == 0 then endTime = GetGameTimeSeconds() end

		local sessionSecs = endTime - Killz.settings.startTimeSecs
		local days, hrs, mins, secs = ConvertSecstoTime(sessionSecs)
		local timeStr = LCLSTR.SLASH_CMD_TIME_STATS_SESSION
	
		if days >= 1 then timeStr = timeStr..string.format(LCLSTR.SLASH_CMD_TIME_STATS_SESSION_DAYS, days) end
		if hrs >= 1 then timeStr = timeStr..string.format(LCLSTR.SLASH_CMD_TIME_STATS_SESSION_HRS, hrs) end
		if mins >= 1 then timeStr = timeStr..string.format(LCLSTR.SLASH_CMD_TIME_STATS_SESSION_MINS, mins) end
		timeStr = timeStr..string.format(LCLSTR.SLASH_CMD_TIME_STATS_SESSION_SECS, secs)

		local sessionHrs = (sessionSecs/60)/60
		if sessionHrs < 1 then sessionHrs = 1 end
		timeStr = timeStr..string.format(LCLSTR.SLASH_CMD_TIME_STATS, Killz.settings.sessionStats.kills/sessionHrs, Killz.settings.sessionStats.deaths/sessionHrs, Killz.settings.sessionStats.killingBlows/sessionHrs)
		str = str..timeStr
	end

	local channels = {
	
		["g1"] = CHAT_CHANNEL_GUILD_1,
		["g2"] = CHAT_CHANNEL_GUILD_2,
		["g3"] = CHAT_CHANNEL_GUILD_3,
		["g4"] = CHAT_CHANNEL_GUILD_4,
		["g5"] = CHAT_CHANNEL_GUILD_5,
		["o1"] = CHAT_CHANNEL_OFFICER_1,
		["o2"] = CHAT_CHANNEL_OFFICER_2,
		["o3"] = CHAT_CHANNEL_OFFICER_3,
		["o4"] = CHAT_CHANNEL_OFFICER_4,
		["o5"] = CHAT_CHANNEL_OFFICER_5,
		["g"] = CHAT_CHANNEL_PARTY,
		["s"] = CHAT_CHANNEL_SAY,
		["w"] = CHAT_CHANNEL_WHISPER,
		["y"] = CHAT_CHANNEL_YELL,
		["z"] = CHAT_CHANNEL_ZONE
	}

	local channelName = params[1] -- string in list above for ESOUI MsgChannelType
	local wNameIndx = 2
	if channelName == LCLSTR.SLASH_PARAM_REPORT then 
		channelName = params[2] -- They can either type /kzreport [channel] or /killz report [channel]
		wNameIndx = 3
	end 

	local channel = channels[channelName]
	if channel == nil then channel = CHAT_CHANNEL_PARTY end
	
	local recipient = nil
	
	if channel == CHAT_CHANNEL_WHISPER then 
		-- If it's a whisper then they must specify to whom to send the whisper
		-- Player names can have spaces so combine
		recipient = combineStrings(params, wNameIndx, " ") 
		if recipient == nil or recipient == "" then 
			CHAT_SYSTEM:ReplyToLastTarget(channel)
		end
	end

	CHAT_SYSTEM:StartTextEntry(str, channel, recipient)
end

local function slashCmdDebug()
	Killz.debug = not Killz.debug
	Killz.Msg(string.format("Killz: debug = %s", tostring(Killz.debug)), false)
end

local function slashCmdShow()
	Killz.ScoreWindow_Show()
end

local function slashCmdHide()
	Killz.ScoreWindow_Hide()
end

local function slashCmdImport()
	Killz.CheckImportKC_G()
end

local function slashCmdReset()
    Killz.ShowScoreResetDialog()
end

local function whoIsThis(inAccount, inOpponents, inStart, inDoLabel)

	if string.sub(inAccount, 1, 1) ~= "@" then inAccount = "@"..inAccount end -- prepend at sign if it doesn't exist

	local theCount = 0

	inOpponents = inOpponents or Killz.settings.opponents
	inStart = inStart or 0
	inDoLabel = inDoLabel or true

	for name, opponent in pairs(inOpponents) do

		if opponent.targetInfo and opponent.targetInfo.account then
		
			-- if opponent.targetInfo.account ~= "" then Killz.Msg(string.format("account= '%s'", opponent.targetInfo.account)) end
			
			if opponent.targetInfo.account == inAccount then

				-- This toon's account matches 
				if theCount == 0 and inDoLabel == true then Killz.Msg(string.format("Known PvP opponents for %s:", inAccount)) end
				theCount = theCount + 1 

				-- Get level
				local lvl = tostring(opponent.targetInfo.CP)
				if opponent.targetInfo.level < 50 then lvl = "lvl"..tostring(opponent.targetInfo.level) end
				if not lvl then lvl = "" end

				-- Get class & rank icons
				local classIcon = GetClassIcon(opponent.targetInfo.classID)
				if classIcon then classIcon = zo_iconFormatInheritColor(classIcon, 26, 26) end
			
				local rankIcon = ""
				local rank = opponent.targetInfo.rank
				if rank == "?" then rank = nil end
				if rank then 
					rankIcon = GetAvARankIcon(rank)
					if rankIcon then rankIcon = zo_iconFormatInheritColor(rankIcon, 26, 26) end
				end

				-- If player has never put reticle on them, for some reason they show up as Level 50, CP 16, so remove this
				if classIcon == nil and opponent.targetInfo.level == 50 and opponent.targetInfo.CP == 16 then lvl = "" end
				
				lvl = lvl or ""
				classIcon = classIcon or ""
				name = name or ""
				rankIcon = rankIcon or ""

				local countStr = Colorz.textDefault:Colorize(string.format("%d.", theCount+inStart))
				local toonInfo = Colorz.GetAllianceColor(opponent.targetInfo.alliance):Colorize(string.format(" %s%s %s%s", lvl, classIcon, name, rankIcon))
				Killz.Msg(countStr..toonInfo)

			end
		end
	end	
	
	return theCount

end

local function slashCmdWho(params)
	whoIsThis(params[2]) -- account to look up is params[2]
end

function Killz.WhoIsThisByName(inToonName)

	local theCount = 0

	local opponent = Killz.settings.opponents[inToonName]
	if opponent and opponent.targetInfo and opponent.targetInfo.account ~= "" then 
		theCount = whoIsThis(opponent.targetInfo.account, Killz.settings.opponents) 
	end

	if theCount == 0 then
		opponent = Killz.targets[inToonName]
		if opponent and opponent.targetInfo and opponent.targetInfo.account ~= "" then 
			local targetCount = whoIsThis(opponent.targetInfo.account, Killz.targets, theCount, (theCount == 0))
			theCount = theCount + targetCount
		end
	end

	if theCount == 0 then Killz.Msg(string.format("No more information available for '%s'.", inToonName)) end
	
end

local function restoreSpaces(paramStr)
	-- will replace all underscores with spaces in the given string
	return string.gsub(paramStr, "_", " ")
end

local function slashCmdLastKB(params)
	
	local channels = {
	
		["g1"] = CHAT_CHANNEL_GUILD_1,
		["g2"] = CHAT_CHANNEL_GUILD_2,
		["g3"] = CHAT_CHANNEL_GUILD_3,
		["g4"] = CHAT_CHANNEL_GUILD_4,
		["g5"] = CHAT_CHANNEL_GUILD_5,
		["o1"] = CHAT_CHANNEL_OFFICER_1,
		["o2"] = CHAT_CHANNEL_OFFICER_2,
		["o3"] = CHAT_CHANNEL_OFFICER_3,
		["o4"] = CHAT_CHANNEL_OFFICER_4,
		["o5"] = CHAT_CHANNEL_OFFICER_5,
		["g"] = CHAT_CHANNEL_PARTY,
		["s"] = CHAT_CHANNEL_SAY,
		["w"] = CHAT_CHANNEL_WHISPER,
		["y"] = CHAT_CHANNEL_YELL,
		["z"] = CHAT_CHANNEL_ZONE
	}

	local channelName = params[1] or "g" -- string in list above for ESOUI MsgChannelType
	local wNameIndx = 2

	local channel = channels[channelName]
	if channel == nil then channel = CHAT_CHANNEL_PARTY end
	
	local recipient = nil
	local str = Killz.lastKBStr or "Killz: No Last KB"
	
	if channel == CHAT_CHANNEL_WHISPER then 
		-- If it's a whisper then they must specify to whom to send the whisper
		-- Player names can have spaces so combine
		recipient = combineStrings(params, wNameIndx, " ") 
		if recipient == nil or recipient == "" then 
			CHAT_SYSTEM:ReplyToLastTarget(channel)
		end
	end

	CHAT_SYSTEM:StartTextEntry(str, channel, recipient)
end

local function cmd_Test()
	
	local itemLink = GetItemLink( BAG_WORN, EQUIP_SLOT_FEET, LINK_STYLE_DEFAULT )
	local itemName = GetItemLinkName(itemLink)
	local itemId = GetItemLinkItemId(itemLink)
	local _, setName, _, _, _, setId, _ = GetItemLinkSetInfo(itemLink, true)

	d(string.format("Slot %d: %s (%s)", EQUIP_SLOT_FEET, itemName, tostring(itemId)))
	d(string.format("ItemLink = '%s'", string.gsub(itemLink, "|", "/")))
	d(string.format("SetName = '%s', SetID = %s", setName or "no set name", tostring(setId or -1)))
end

function Killz.LastKB2Chat()
	slashCmdLastKB({"g"})
end

function Killz.initSlashCommands()
  
	SLASH_COMMANDS[LCLSTR.SLASH_KB] = function(extra)
	
		local params = {"g"}
		if extra then 
			params = splitString(extra)
			for i, v in pairs(params) do v = string.lower(v) end -- all lower case please
		end

		slashCmdLastKB(params)
		
	end
  
	SLASH_COMMANDS[LCLSTR.SLASH_KZL] = SLASH_COMMANDS[LCLSTR.SLASH_KB]

	SLASH_COMMANDS[LCLSTR.SLASH_KZREPORT] = function(extra)
	
		local params = {}
		if extra then 
			params = splitString(extra)
			for i, v in pairs(params) do v = string.lower(v) end -- all lower case please
		end
		slashCmdReport(params)
		
	end

	if not KC_G then -- Put in kill counter slash command if that addon isn't loaded
		SLASH_COMMANDS["/kcreport"] = SLASH_COMMANDS[LCLSTR.SLASH_KZREPORT]
	end

	SLASH_COMMANDS[LCLSTR.SLASH_KILLZ] = function(extra)

		local params = {}
		if extra then 
			params = splitString(extra)
			for i, v in pairs(params) do v = string.lower(v) end -- all lower case please
		end		
		local cmd = params[1] or ""
		
		if cmd == "" or cmd == LCLSTR.SLASH_PARAM_HELP then 
			slashCmdHelp()
		end
		
		if cmd == LCLSTR.SLASH_PARAM_REPORT then slashCmdReport(params)
		elseif cmd == "debug" then slashCmdDebug()
		elseif cmd == LCLSTR.SLASH_PARAM_SHOW then slashCmdShow()
		elseif cmd == LCLSTR.SLASH_PARAM_HIDE then slashCmdHide()
		elseif cmd == LCLSTR.SLASH_PARAM_IMPORT then slashCmdImport()
		elseif cmd == LCLSTR.SLASH_PARAM_RESET then slashCmdReset(params)
		elseif cmd == LCLSTR.SLASH_PARAM_LAST then slashCmdLastKB(params)
		elseif cmd == LCLSTR.SLASH_PARAM_WHO then slashCmdWho(params)
		elseif cmd == "test" then cmd_Test()
		end
	end
end