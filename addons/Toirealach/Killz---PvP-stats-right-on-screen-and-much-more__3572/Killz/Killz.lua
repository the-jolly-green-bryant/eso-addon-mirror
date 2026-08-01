-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Top level namespace
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Killz = Killz or {}

Killz.name = "Killz"
Killz.version = "1.10.7"
Killz.displayName = "|cEE4332Killz|r"
Killz.author = "|c00a313Teebow Ganx|r"
Killz.website = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"
Killz.donation = "https://www.youtube.com/channel/UCqE9Vi36WzTJBBbo9-G40bg"

Killz.SavedVariablesName = "KillzSavedVars"
Killz.savedVarsVersion = 1
Killz.settings = nil
Killz.debug = false		-- Do NOT turn debug on unless you know what you're doing
Killz.queuedCampaignID = nil -- campaignID of pvp campaign we are currently queued for, or nil
Killz.queueState = nil -- Our queue state has changed when this changes
Killz.queuePosition = nil -- Our position in queue, if queued, or nil
Killz.lastKBStr = nil

local LCLSTR = Killz.Localization
local theChatTab = nil
local ZO_ShowPlayerContextMenu = nil -- store the function for the original player context menu 
local importDialogSetup = false
local dpsTable = {}
local annStr1 = nil
local annStr2 = nil
local annStr3 = nil
local annStr4 = nil
local isRegistered = false
local isCombatRegistered = false
local playerName = nil
local playerUnitId = nil
local campTimerPeriodic = TBO_Periodic:New()
local killFeedDupeTracker = ZO_RecurrenceTracker:New(10000, 0)
local latestDeathBlow = nil
local playerIsInCombat = false
local currChat = nil
local currPlayerName = nil
local currRawName = nil

local defaultStats = {
	
	kills = 0,			-- Total number of kills in which player has been involved
	killingBlows = 0, 	-- Total number of killing blows player has dealt
	avengeKills = 0,	-- Number of avenge kills we have
	revengeKills = 0,	-- Number of revenge kills we have
	deaths = 0, 		-- Total number of times player has died in PvP

	killStreak = 0, 	-- Longest streak of kills with no death
	kbStreak = 0, 		-- Longest streak of killing blows in a row.
	deathStreak = 0, 	-- Longest streak of deaths in a row with no kills

	rankPoints = 0, 	-- Points towards next PvP rank
	alliancePoints = 0 	-- AP gained
}

local defaults = {

	accountWide = true,
	playAnnounceSounds = true,
	scoreWindowScale = 0,	
	statsBarLocked = false,
	hideInCombat = false,
	hideInPvE = true,
	pvpDeathsOnly = true,
	announceKBs = true,
	kbColor = Colorz.red:ToHex(),
	announceDeaths = true,
	deathColor = Colorz.orange:ToHex(),
	announceKills = false,
	killColor = Colorz.lightRed:ToHex(),
	announceMilestones = true,
	addAcctToAnn = true,
	killzChatTab = true,
	doCombatLog = false,
	addPvPKillFeed = true,
	addPvPKillFeedToMain = false,
	showAPGained = true,
	showTelvarGained = true,
	showMobKills = false,
	autoConfirmJoin = true,
	killCounterImported = false,
	resetOnlyOnLogOrQuit = false,
	reportTimeBasedStats = true,

	lifetimeStats = copyDeep(defaultStats),
	sessionStats = copyDeep(defaultStats),
	kbAbilities = {},
	opponents = {},
	sessionOpponents = {},
	sessionKBAbilities = {},
}

function Killz.ToggleChatTab()
	if Killz.settings.killzChatTab == true then
		theChatTab = theChatTab or TBO_ChatTab:New(Killz.name)
	else
		if theChatTab then
			theChatTab:Remove()
			theChatTab = nil
		else
			local cc, window = TBO_ChatTab.Find(Killz.name)
			if window then
				cc:RemoveWindow(window.key)
			end
		end
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Targets Table
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- We track enemy PvP targets we see.
-- But we only save those targets the player kills or who kills the player

Killz.targets = {} -- Always start with am empty targets table

-- This table is the structure of a Targets table element and contains all of the
-- defaults for a new element in the targets table.
-- The index for each element in the Targets table is the name of the toon which
-- is obtained by calling GetUnitName() when the player targets another player.

local targetInfo = {
	account = "",			
	alliance = "?",
	class = "?",
	classID = "?",
	race = "?",
	raceID = "?",
	level = "?",
	CP = "?",
	rank = "?"
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Stats Tables
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- Two sets of PvP stats are kept by the addon, session and all time. 
-- Session stats reset back to zero each time the user enters a PvP area from a PvE area.
-- All time stats are cumulative.

local recentKBs = { count = 0 } 

-- Used as the default values of the stats tables

function Killz.IncrementStat(key, name) 

	-- Update the session and lifetime stats
	Killz.settings.sessionStats[key] = Killz.settings.sessionStats[key] + 1
	Killz.settings.lifetimeStats[key] = Killz.settings.lifetimeStats[key] + 1

	if not name then return end

	-- The stat is also kept for the named opponent
	local opponent = Killz.GetOpponent(name, true)
	if opponent then 
		opponent[key] = opponent[key] + 1 
		
		if key == "kills" then 
			opponent.latestKill = os.time() 
			if opponent.firstKill == 0 then opponent.firstKill = opponent.latestKill end
		end
		
		if key == "killingBlows" then 
			opponent.latestKB = os.time() 
			if opponent.firstKB == 0 then opponent.firstKB = opponent.latestKB end
		end
		
		if key == "deaths" then 
			opponent.latestDeath = os.time() 
			if opponent.firstDeath == 0 then opponent.firstDeath = opponent.latestDeath end
		end
		
		local sessionOpponent = Killz.settings.sessionOpponents[name]
		if sessionOpponent then sessionOpponent[key] = sessionOpponent[key] + 1 end

		if Killz.StatsWindowList then Killz.StatsWindowList:UpdateOpponentsList() end
	end
	
end

function Killz.resetSessionStats()
	Killz.settings.sessionOpponents = {}
	Killz.settings.sessionKBAbilities = {}
	Killz.settings.sessionStats = copyDeep(defaultStats)
	if Killz.StatsWindowList then Killz.StatsWindowList:UpdateCurrentList() end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Opponents Table
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- 
-- The opponents table is a table of all the opponents they player has ever faced.
-- If they target a toon, score the killing blow on another toon, or if the player 
-- hits a toon which later is killed to someone else's killing blow, the opponent
-- is added to the opponents table. This allows us to keep a running total of every
-- kill, killing blow and death involving other toons.
-- 
-- Note, we only learn an opponents class, alliance, level and CP points if we
-- target another toon. When we do, we update those statistics as necessary for
-- any toon we've faced previously.

-- This table is the structure of an Opponents table element and contains all of the
-- defaults for a new element in the Opponents table.
-- The index for each element in the Opponents table is the name of the opposing
-- player's toon.

local opponentDefaults = {

	-- Stats we save on every opponent we face.
	-- These are the default values for a new opponent object.

	name = "",				-- Toon name (e.g. "MyOPSorc")
	
	kills = 0,				-- Number of kills we have on this toon (includes group kills)
	killingBlows = 0,		-- Number of times we've scored the killing blow on this toon
	avengeKills = 0,		-- Number of avenge kills we have on this toon
	revengeKills = 0,		-- Number of revenge kills we have on this toon
	deaths = 0,				-- Number of times this toon killed us
	
	firstKill = 0,			-- date/time of the first time we killed this toon
	latestKill = 0,			-- date/time of most recent kill of this toon
	killLog = {},			-- Log of all kills of this toon

	firstKB = 0,			-- date/time of the first time we killed this toon
	latestKB = 0,			-- date/time of most recent kill of this toon
	killingBlowLog = {},	-- Log of all killing blows scored on this toon

	firstDeath = 0,			-- date/time of the first time this toon killed us
	latestDeath = 0,		-- date/time of most recent time this toon killed us
	deathLog = 0,			-- Log of all times this toon killed us
	
	targetInfo = copyDeep(targetInfo) -- See the Targets table below for this structure
}

-- Each record in a the kill log of an opponent 
Killz.killLogTable = {
	dateTime = 0,		-- Date & Time of the Kill
	kbAbility = ""		-- Ability Name of the killing Blow, IF WE SCORED IT	
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Opponents Table Functions
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.OpponentCountFor(account)

	local theCount = 0

	-- iterate over all opponents
	for name, opponent in pairs(Killz.settings.opponents) do
		if opponent.targetInfo.account == account then theCount = theCount + 1 end
	end	
	
	return theCount
end

-- Find a opponent by name or create it if it doesn't exist
function Killz.GetOpponent(name, create)
		
		create = create or true	-- default
				
		if Killz.settings.opponents[name] == nil and create == true then
			Killz.settings.opponents[name] = copyDeep(opponentDefaults)
	    	Killz.settings.opponents[name].name = name
		end
		
		-- Get target info from targets if it exists
		if Killz.targets[name] and Killz.settings.opponents[name] then 
			Killz.settings.opponents[name].targetInfo = copyDeep(Killz.targets[name].targetInfo)
		end

		local opponent = Killz.settings.opponents[name]

		-- If in lifetime opponents table but not in session opponents table, add to session table
		if opponent ~= nil and create == true and Killz.settings.sessionOpponents[name] == nil then
			Killz.settings.sessionOpponents[name] = copyDeep(opponentDefaults)
	    	Killz.settings.sessionOpponents[name].name = name
			Killz.settings.sessionOpponents[name].targetInfo = copyDeep(opponent.targetInfo)
		end

    return opponent
end

function Killz.GetAllOpponentsFor(inAccount, inOnlyLifetime)

	local outOpponents = {}

	-- Walk though lifetime first
	for name, opponent in pairs(Killz.settings.opponents) do
		if opponent.targetInfo.account == inAccount then 
			outOpponents[name] = opponent
		end
	end	

	if inOnlyLifetime ~= true then
		-- Walk though lifetime first
		for name, opponent in pairs(Killz.settings.sessionOpponents) do
			if opponent.targetInfo.account == inAccount and not outOpponents[name] then 
				outOpponents[name] = opponent
			end
		end
	end

	return outOpponents
end

-- FUNCTION: deleteOpponent()
function Killz.deleteOpponent(opponentName) 
    if Killz.settings.opponents[opponentName] == nil then return nil end
	  Killz.settings.opponents[opponentName] = nil
    return opponentName	-- So the caller knows no error occurred
end

-- FUNCTION: deleteOpponentsFor()
-- Find All opponents for a given account and delete them.

function Killz.deleteOpponentsFor(account) 

	local opponentNames = {}
	local theCount = 0
	local deleted = 0
	
	-- iterate over all opponents
	for name, opponent in pairs(Killz.settings.opponents) do
		local itsAccount = opponent.targetInfo.account
		if itsAccount and itsAccount == account then
			-- We have a match
			theCount = theCount + 1
			opponentNames[theCount] = name
		end
	end
	
	if theCount > 0 then
		for i, opponentName in pairs(opponentNames) do
			if Killz.deleteOpponent(opponentName) ~= nil then deleted = deleted + 1 end
		end
	end
	
	return deleted -- Return the number of opponent records deleted.
end

function Killz.GetTableSize(inTable)
	local count = 0
	for _ in pairs(inTable) do count = count + 1 end
	return count
end

function Killz.GetOpponentCount()
	return Killz.GetTableSize(Killz.settings.opponents)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Ability Stats Table
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- We keep stats on every ability that was used to either score a killing blow 
-- or was the killing blow that killed us. This is the default table element.

local abilityDefaults = {

	name = "",			-- The name of the ability that scored the killing blow
	ID = 0,				-- The ability ID of the ability
	kills = 0,			-- # times player has used this to score a killing blow
	firstKill = 0,		-- date/time of first killing blow using this ability
	latestKill = 0,		-- date/time of most recent killing blow using this ability
	deaths = 0,			-- # times we've died to this ability as the killing blow
	firstDeath = 0,		-- date/time of first death from this ability
	latestDeath = 0,	-- date/time of most recent death from this ability
}

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Find a Ability stat by name or create it if it doesn't exist
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.GetAbility(name, create)
		
	create = create or true	-- default
	
	local ability = Killz.settings.kbAbilities[name]
	
	if ability == nil and create == true then
		Killz.settings.kbAbilities[name] = copyDeep(abilityDefaults)
		Killz.settings.kbAbilities[name].name = name
		ability = Killz.settings.kbAbilities[name]
	end
	
	-- If in lifetime opponents table but not in session opponents table, add to session table
	if ability ~= nil and create == true and Killz.settings.sessionKBAbilities[name] == nil then
		Killz.settings.sessionKBAbilities[name] = copyDeep(abilityDefaults)
		Killz.settings.sessionKBAbilities[name].name = name
	end

	return ability
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.IncrementAbilityStat(inKey, inName)

	if inKey ~= "kills" and inKey ~= "deaths" then return end -- only 2 possible ability stats

	local ability = Killz.GetAbility(inName, true)

	if not ability then return end

	ability[inKey] = ability[inKey] + 1 
	local firstKey = "firstKill"
	local latestKey = "latestKill"
	if inKey == "deaths" then
		firstKey = "firstDeath"
		latestKey = "latestDeath"
	end
	
	ability[latestKey] = os.time()
	if ability[firstKey] == 0 then ability[firstKey] = ability[latestKey] end
	
	local sessionAbility = Killz.settings.sessionKBAbilities[inName]
	if sessionAbility then 
		sessionAbility[inKey] = sessionAbility[inKey] + 1
		sessionAbility[latestKey] = os.time()
		if sessionAbility[firstKey] == 0 then sessionAbility[firstKey] = sessionAbility[latestKey] end
	end

	if Killz.StatsWindowList then Killz.StatsWindowList:UpdateAbilitiesList() end
end

--- KC_G Import --------------------------------------------------------------------

function Killz.CheckImportKC_G(data, textParams)

	if not KC_G then return end -- KC_G not running
	if not KC_G.savedVars then return end -- KC_G not running

	if Killz.settings.killCounterImported == true then return end

	-- Ask to import KC_G stats

	if not importDialogSetup then 

		ZO_Dialogs_RegisterCustomDialog("CONFIRM_KILLZ_PVP_STATS_RESET",
		{
			gamepadInfo =
			{
				dialogType = GAMEPAD_DIALOGS.BASIC,
			},
			title =
			{
				text = "Import KillCounter PvP Stats?",
			},
			mainText =
			{
				text = "Would you like to import all of your opponents, kills, deaths, killing blows, streaks and other stats from KillCounter? If you say yes all your historical PvP data will be transferred to Killz.",
			},
			buttons =
			{
				{
					text = "Yes",
					callback = function(dialog)
						Killz.ImportKC_G()
					end,
				},
				{
					text = "No",
					callback = function(dialog)
						Killz.settings.killCounterImported = true
					end,
				}
			}
		})
	
		importDialogSetup = true
	end

    ZO_Dialogs_ShowPlatformDialog("CONFIRM_KILLZ_PVP_STATS_RESET", data, textParams)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.ImportKC_G()
	
	if not KC_G then 
		d("Killz: Kill Counter is not running! Cannot Import Cancelled.")
		d(" ")
		return 
	end -- KC_G not running
	if not KC_G.savedVars then 
		d("Killz: No Kill Counter data found! Cannot Import Cancelled.")
		d(" ")
		return 
	end -- KC_G not running
	
	-- Import Lifetime stats

	d(" ")
	d("Killz: Importing Kill Counter lifetime stats...")

	Killz.settings.lifetimeStats.kills = KC_G.savedVars.totalKills
	Killz.settings.lifetimeStats.deaths = KC_G.savedVars.totalDeaths

	-- You would think that KC_G.savedVars.totalKillingBlows contains total KBs but you'd be wrong 
	-- It's always zero.  So it'll need to be calculated manually below. 

	Killz.settings.lifetimeStats.killingBlows = KC_G.savedVars.totalKillingBlows

	-- Killz.settings.lifetimeStats.avengeKills & Killz.settings.lifetimeStats.revengeKills
	-- must be calculated when importing the per player stats from KC_G because
	-- these stats are only kept per player not as a total.

	Killz.settings.lifetimeStats.killStreak = KC_G.savedVars.longestStreak
	Killz.settings.lifetimeStats.deathStreak = KC_G.savedVars.longestDeathStreak
	Killz.settings.lifetimeStats.kbStreak = KC_G.savedVars.longestKBStreak

	Killz.settings.lifetimeStats.rankPoints = KC_G.savedVars.rankPointsGained
	-- Killz.settings.lifetimeStats.alliancePoints might also need to be calculated 

	-- Import abilities but remember that KC_G only keeps stats for abilities
	-- that the player uses to score the KB on an opponent, whereas we also
	-- keep stats for every ability to which the player dies.

	-- KC_G uses a table called 'kbSpell', indexed by the ability name and the
	-- value for that key is the number of KBs the player has gotten with it.
	-- So loop throguh the table and set the kill count for each matching ability
	-- in our kbAbilities table to that found in KC_G

	d("Killz: Importing Kill Counter ability KBs stats...")

	local ttl = 0
	local ttlNew = 0
	local ttlChanged = 0

	for name, count in pairs(KC_G.savedVars.kbSpells) do
		if not Killz.settings.kbAbilities[name] then
			Killz.settings.kbAbilities[name] = copyDeep(abilityDefaults)
			Killz.settings.kbAbilities[name].name = name
			ttlNew = ttlNew + 1
		end
		if count > Killz.settings.kbAbilities[name].kills then 
			Killz.settings.kbAbilities[name].kills = count 
			ttlChanged = ttlChanged + 1
		end
		ttl = ttl + 1
	end
	d(string.format("Killz: Ability stats processed: %d", ttl))
	d(string.format("Killz: New Ability stats created: %d", ttlNew))
	d(string.format("Killz: Total Ability stats Updated: %d", ttlChanged))

	-- Now we have to import opponents, which KC_G calls players which are indexed by 
	-- their name and whose table contains the following elements

	local KILLS_INDX = 1
	local KB_INDX = 2
	local AVENGE_KILL_INDX = 3
	local REVENGE_KILL_INDX = 4
	local ALLIANCE_INDX = 5
	local CP_INDX = 6
	local NAME_INDX = 7
	local LEVEL_INDX = 8
	local CLASS_INDX = 9
	local DEATHS_INDX = 10

	d("Killz: Importing Kill Counter opponent stats...")
	
	ttl = 0
	ttlNew = 0
	ttlChanged = 0
	local opponentChanged = false

	for name, player in pairs(KC_G.savedVars.players) do

		ttl = ttl + 1

		if not Killz.settings.opponents[name] then

			ttlNew = ttlNew + 1

			Killz.settings.opponents[name] = copyDeep(opponentDefaults)
			Killz.settings.opponents[name].name = name

			-- Pull in targetInfo for players we don't already have in our table
			if player[CLASS_INDX] > 0 then Killz.settings.opponents[name].targetInfo.classID = player[CLASS_INDX] end
			if player[LEVEL_INDX] > 0 then Killz.settings.opponents[name].targetInfo.level = player[LEVEL_INDX] end
			if player[ALLIANCE_INDX] > 0 then Killz.settings.opponents[name].targetInfo.alliance = player[ALLIANCE_INDX] end
			if player[CP_INDX] > 0 then Killz.settings.opponents[name].targetInfo.CP = player[CP_INDX] end
		end

		if not Killz.settings.opponents[name].targetInfo.classID and player[CLASS_INDX] > 0 then Killz.settings.opponents[name].targetInfo.classID = player[CLASS_INDX] opponentChanged = true end
		if not Killz.settings.opponents[name].targetInfo.level and player[LEVEL_INDX] > 0 then Killz.settings.opponents[name].targetInfo.level = player[LEVEL_INDX] opponentChanged = true end
		if not Killz.settings.opponents[name].targetInfo.alliance and player[ALLIANCE_INDX] > 0 then Killz.settings.opponents[name].targetInfo.alliance = player[ALLIANCE_INDX] opponentChanged = true end
		if not Killz.settings.opponents[name].targetInfo.CP and player[CP_INDX] > 0 then Killz.settings.opponents[name].targetInfo.CP = player[CP_INDX] opponentChanged = true end
		
		if player[KILLS_INDX] and (player[KILLS_INDX] > Killz.settings.opponents[name].kills) then Killz.settings.opponents[name].kills = player[KILLS_INDX] opponentChanged = true end
		if player[KB_INDX] and (player[KB_INDX] > Killz.settings.opponents[name].killingBlows) then Killz.settings.opponents[name].killingBlows = player[KB_INDX] opponentChanged = true end
		if player[DEATHS_INDX] and (player[DEATHS_INDX] > Killz.settings.opponents[name].deaths) then Killz.settings.opponents[name].deaths = player[DEATHS_INDX] opponentChanged = true end
		if player[AVENGE_KILL_INDX] and (player[AVENGE_KILL_INDX] > Killz.settings.opponents[name].avengeKills) then 
			Killz.settings.opponents[name].avengeKills = player[AVENGE_KILL_INDX] opponentChanged = true end
		if player[REVENGE_KILL_INDX] and (player[REVENGE_KILL_INDX] > Killz.settings.opponents[name].avengeKills) then 
			Killz.settings.opponents[name].avengeKills = player[REVENGE_KILL_INDX] opponentChanged = true end
		
		if opponentChanged == true then ttlChanged = ttlChanged + 1 end
		opponentChanged = false
	end

	d("...Complete!")
	d(string.format("Killz: Total opponents from Kill Counter processed: %d", ttl))
	d(string.format("Killz: New opponents created from Kill Counter: %d", ttlNew))
	d(string.format("Killz: Existing opponents changed: %d", ttlChanged))

	-- Now total all KBs, avenge and revenge kills

	local ttlKBs = 0
	local ttlAvenge = 0
	local ttlRevenge = 0

	for name, opponent in pairs(Killz.settings.opponents) do
		if opponent.killingBlows > 0 then ttlKBs = ttlKBs + opponent.killingBlows end
		if opponent.avengeKills > 0 then ttlAvenge = ttlAvenge + opponent.avengeKills end
		if opponent.revengeKills > 0 then ttlRevenge = ttlRevenge + opponent.revengeKills end
	end

	if ttlKBs > Killz.settings.lifetimeStats.killingBlows then Killz.settings.lifetimeStats.killingBlows = ttlKBs end
	if ttlAvenge > Killz.settings.lifetimeStats.avengeKills then Killz.settings.lifetimeStats.avengeKills = ttlAvenge end
	if ttlRevenge > Killz.settings.lifetimeStats.revengeKills then Killz.settings.lifetimeStats.revengeKills = ttlRevenge end

	d(string.format("Killz: Kill Counter Import Complete.", ttl))
	d(" ")

	Killz.settings.killCounterImported = true
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.GetMilestone(key, n)
	local milestoneStr = LCLSTR.MILESTONE[key][n]
	if milestoneStr == nil then return nil, nil end
	local numStr = LCLSTR[key]
	if numStr then numStr = string.format(numStr, n) end
	return milestoneStr, numStr
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local function addKillzTabMsg(inMsg, inDelay)

	if not theChatTab then return end
	
	inMsg = inMsg or ""
	local timeStr, secondsUntilNextUpdate = ZO_FormatTime(GetSecondsSinceMidnight(), TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)
	inMsg = Colorz.textDefault:Colorize(string.format("[%s]", timeStr)).." "..inMsg

	if not inDelay or inDelay == 0 then theChatTab:AddMsg(inMsg)
	else zo_callLater(function() theChatTab:AddMsg(inMsg) end, inDelay) end
end

function Killz.Msg(inMsg, inDelay)
	d(inMsg)
	addKillzTabMsg(inMsg, inDelay)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local function calculateDPSFor(targetUnitId)

	if dpsTable[targetUnitId] == nil then return 0 end
	
	local elapsed = dpsTable[targetUnitId].endMS - dpsTable[targetUnitId].startMS

	if elapsed < 1000 then elapsed = 1000 end --If melted in under 1 second, then round up to 1 second

	elapsed = elapsed/1000
	elapsed = math.floor(elapsed*100)/100 -- round to 2 decimal places

	local dps = math.floor(((dpsTable[targetUnitId].dmg/elapsed)*100))/100 -- round to 2 decimal places

	return dps, elapsed
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local function makeDPSStr(targetUnitId)

	local dps, elapsed = calculateDPSFor(targetUnitId)

	if dps == 0 then return nil end

	local hitsStr = string.format("%d hit", dpsTable[targetUnitId].hits)
	if dpsTable[targetUnitId].hits > 1 then hitsStr = hitsStr.."s" end -- pluralise

	local secStr = "second"
	if elapsed > 1 then secStr = secStr.."s" end -- pluralise

	local dpsStr = string.format("Average DPS: %s for %s over %s %s", tostring(ZO_LocalizeDecimalNumber(dps)), hitsStr, tostring(ZO_LocalizeDecimalNumber(elapsed)), secStr)

	return dpsStr
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- We do a zo_callLater with these strings so we need them to have a scope which lasts
	
function Killz.Announce(key, name, isPlayer, abilityName, abilityIcon, tgtID) 

	if key == "WAS_KILLING_BLOW" and dpsTable[tgtID] ~= nil and dpsTable[tgtID].recurse == nil then

		dpsTable[tgtID].recurse = true

		zo_callLater( function() 
			Killz.Announce(key, name, isPlayer, abilityName, abilityIcon, tgtID)
		end, 1000) -- delay because ZOS sometimes sends combat events out of order & we want accurate DPS

		return
	end

	local announce = false
	local color = Colorz.textDefault
	local iconTextBig = ""
	local iconTextSmall = ""

	if abilityName and abilityIcon then
		iconTextBig = " "..zo_iconTextFormat(abilityIcon, 26, 26, " ")
		iconTextSmall = " "..zo_iconTextFormat(abilityIcon, 20, 20, " ")
	end

	if key == "WAS_KILL" then 
		color = Killz.killColor
		announce = Killz.settings.announceKills 
	elseif key == "WAS_KILLING_BLOW" then 
		color = Killz.kbColor
		announce = Killz.settings.announceKBs
	elseif key == "WAS_DEATH" then 
		color = Killz.deathColor
		announce = Killz.settings.announceDeaths 
	end

	local s = color:Colorize(LCLSTR[key])
	local console = s
	local announcement = s

	if not name then name = "" end
	if name ~= "" then announcement = announcement..color:Colorize(name)  end

	local rawKBStr = nil
	if key == "WAS_KILLING_BLOW" then rawKBStr = LCLSTR[key]..name end

	local link = name

	if isPlayer then 

		link = Colorz.unitIntract:Colorize(ZO_LinkHandler_CreatePlayerLink(name, LINK_STYLE_DEFAULT)) 

		if Killz.settings.addAcctToAnn then
			local opponent = Killz.settings.opponents[name]
			if opponent then 
				local targetInfo = opponent.targetInfo
				if targetInfo ~= nil then 
					local account = targetInfo.account
					if account and account ~= "" then			
						account = string.format("(%s)", account)
						if key == "WAS_KILLING_BLOW" then rawKBStr = rawKBStr.." "..account end
						link = link.." "..color:Colorize(account)
					end
				end
			end
		end
	end

	if link ~="" then 
		console = console..link
	end

	if abilityName ~= nil then 
		local s1 = "" 
		if link ~= "" then s1 = s1..LCLSTR.USING end -- Have name, so name+using+ability
		
		s1 = s1..abilityName
		if key == "WAS_KILLING_BLOW" then rawKBStr = rawKBStr..s1 end
		console = console..color:Colorize(s1..iconTextSmall)
		announcement = announcement..color:Colorize(s1..iconTextBig)
	end 
	
	if key == "WAS_KILLING_BLOW" then
	
		if tgtID ~= nil then -- add the DPS to the string if we can

			local dpsStr = makeDPSStr(tgtID)

			if dpsStr ~= nil then
				rawKBStr = rawKBStr.."\n"..dpsStr
				console = console.."\n"..color:Colorize(dpsStr)
			end

			if dpsTable[tgtID] ~= nil then dpsTable[tgtID] = nil end -- remove from table
		
		end

		Killz.lastKBStr = rawKBStr
	end
	
	local sound = nil
	if Killz.settings.playAnnounceSounds == true then
		if key == "WAS_KILL" or key == "WAS_KILLING_BLOW" then 
			local killSound = SOUNDS.BATTLEGROUND_CAPTURE_AREA_CAPTURED_OWN_TEAM
			if key == "WAS_KILLING_BLOW" then killSound = SOUNDS.SKILL_XP_DARK_ANCHOR_CLOSED end
			PlaySound(killSound)
			PlaySound(SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION)
			PlaySound(SOUNDS.LOCKPICKING_UNLOCKED)
		elseif key == "WAS_DEATH" then PlaySound(SOUNDS.RAID_TRIAL_FAILED) end
	else sound = -1 end -- Setting to -1 means don't play any CSAnnounce sound

	Killz.Msg(console, 350) -- Delay b/c ZOS sends combat events out of order
	if announce then CSAnnounce.Major(announcement, nil, 3000, sound) end

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.CheckMilestones(key, name, isPlayer, abilityName, abilityIcon, tgtID)


	local console = ""
	local color = Colorz.textDefault

	if key == "WAS_KILL" then 
		color = Killz.killColor
	elseif key == "WAS_KILLING_BLOW" then 
		color = Killz.kbColor
	elseif key == "WAS_DEATH" then 
		color = Killz.deathColor
	end

	local numStr = nil
	local milestone = nil
	local milestoneDelay = 4500
	local allTime = nil
	local allTimeDelay = 4500
	
	if key == "WAS_KILLING_BLOW" then 
		
		-- Check for any killing blow count milestones	
		milestone, numStr = Killz.GetMilestone("NUMBER_OF_KILLING_BLOWS", Killz.settings.sessionStats.killingBlows)	
		if milestone ~= nil then allTimeDelay = allTimeDelay + 3000 end

		-- If the session killing blow streak is greater than lifetime, update lifetime	
		if recentKBs.count > Killz.settings.sessionStats.kbStreak then 
			Killz.settings.sessionStats.kbStreak = recentKBs.count
			if Killz.settings.sessionStats.kbStreak > Killz.settings.lifetimeStats.kbStreak then
				Killz.settings.lifetimeStats.kbStreak = Killz.settings.sessionStats.kbStreak
				if Killz.settings.announceMilestones then allTime = string.format(LCLSTR.ALL_TIME_KB_STREAK, Killz.settings.lifetimeStats.kbStreak) end
			end
		end
	end

	if key == "WAS_DEATH" then -- Check for any death streak milestones

		milestone, numStr = Killz.GetMilestone("NUMBER_OF_DEATHS", Killz.settings.sessionStats.deathStreak)	

		-- If the session death streak is greater than lifetime, update lifetime	
		if Killz.settings.sessionStats.deathStreak > Killz.settings.lifetimeStats.deathStreak then
			Killz.settings.lifetimeStats.deathStreak = Killz.settings.sessionStats.deathStreak
		end
			
		-- Any killing streak just ended
		if Killz.settings.sessionStats.killStreak > 0 then
			-- Lament kill streak ended
			local streakEndStr = Killz.killColor:Colorize(string.format(LCLSTR.KILLCLSTREAK_ENDED, Killz.settings.sessionStats.killStreak))
			Killz.Msg(streakEndStr)
		end
		
		Killz.settings.sessionStats.longKillStreak = Killz.settings.sessionStats.longKillStreak or 0
		if Killz.settings.sessionStats.killStreak > Killz.settings.sessionStats.longKillStreak then
			Killz.settings.sessionStats.longKillStreak = Killz.settings.sessionStats.killStreak
		end
		Killz.settings.sessionStats.killStreak = 0	

	end

	if milestone then 
		console = milestone
		if numStr then console = milestone.." "..numStr end -- with a space in the chat tab
		console = color:Colorize(console)
		Killz.Msg(console)

		if Killz.settings.announceMilestones then 
			if numStr then milestone = milestone.."\n"..numStr end -- 2 lines on screen
			milestone = color:Colorize(milestone)
			annStr1 = milestone
			zo_callLater(function()  CSAnnounce.Major(annStr1, nil, 3000, SOUNDS.ELDER_SCROLL_CAPTURED_BY_EBONHEART) end, milestoneDelay)
		end
	end

	if allTime then
		allTime = color:Colorize(allTime)
		Killz.Msg(allTime)
		if Killz.settings.announceMilestones then 
			annStr2 = allTime
			zo_callLater(function() CSAnnounce.Major(annStr2, nil, 3000, SOUNDS.EMPEROR_CORONATED_EBONHEART) end, allTimeDelay)
		end
	end

	if key == "WAS_DEATH" then return end

	-- KBs can spur two streak announcements and two all time announcements

	if milestone or allTime then 
		milestoneDelay = milestoneDelay + allTimeDelay
		allTimeDelay = milestoneDelay
	end

	allTime = nil
	milestone = nil

	milestone, numStr = Killz.GetMilestone("NUMBER_OF_KILLS", Killz.settings.sessionStats.killStreak)	
	if numStr then numStr = color:Colorize(numStr) end
	if milestone ~= nil then allTimeDelay = allTimeDelay + 3000 end

	-- If the session kill streak is greater than lifetime, update lifetime	
	if Killz.settings.sessionStats.killStreak > Killz.settings.lifetimeStats.killStreak then
		Killz.settings.lifetimeStats.killStreak = Killz.settings.sessionStats.killStreak
		if Killz.settings.announceMilestones then 
			allTime = LCLSTR.ALL_TIME_KILLCLSTREAK
			if allTime then allTime = string.format(allTime, Killz.settings.lifetimeStats.killStreak) end
		end
	end			

	if milestone then 
		console = milestone
		if numStr then console = milestone.." "..numStr end -- with a space in the chat tab
		console = color:Colorize(console)
		Killz.Msg(console)

		if Killz.settings.announceMilestones then 
			if numStr then milestone = milestone.."\n"..numStr end -- 2 lines on screen
			milestone = color:Colorize(milestone)
			annStr3 = milestone
			zo_callLater(function() CSAnnounce.Major(annStr3, nil, 3000, SOUNDS.ELDER_SCROLL_CAPTURED_BY_EBONHEART) end, milestoneDelay)
		end
	end

	if allTime then
		allTime = color:Colorize(allTime)
		Killz.Msg(allTime)
		if Killz.settings.announceMilestones then 
			annStr4 = allTime
			zo_callLater(function() CSAnnounce.Major(annStr4, nil, 3000, SOUNDS.EMPEROR_CORONATED_EBONHEART) end, allTimeDelay)
		end
	end

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local function killingBlowStreakEnded()

	if Killz.settings.sessionStats.kbStreak > 1 then
		-- Lament killing blow streak ended
		Killz.Msg(Killz.kbColor:Colorize(string.format(LCLSTR.KB_STREAK_ENDED, Killz.settings.sessionStats.kbStreak)))
	end

	Killz.settings.sessionStats.longKBStreak = Killz.settings.sessionStats.longKBStreak or 0
	if Killz.settings.sessionStats.kbStreak > Killz.settings.sessionStats.longKBStreak then
		Killz.settings.sessionStats.longKBStreak = Killz.settings.sessionStats.kbStreak
	end

	Killz.settings.sessionStats.kbStreak = 0
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- --  E V E N T   H A N D L I N G  -- -- -- -- -- -- -- -- -- 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- All ESO Addons are event driven. Events happen in game and the addon registers
-- to receive notices of those events and responds to them. 
-- This addon registers for events related to combat, killing blows & player death.
-- But every ESO Addon must first respond to being loaded, which happens every time
-- the game UI is loaded.

local function registerForCombatEvents()
	if isCombatRegistered == true then return end
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_PLAYER_COMBAT_STATE, Killz.EVENT_CombatState)
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_COMBAT_EVENT, Killz.EVENT_CombatEvent)
	isCombatRegistered = true
end

local function unregisterForCombatEvents()
	if isCombatRegistered == false then return end
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_PLAYER_COMBAT_STATE)
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_COMBAT_EVENT)
	isCombatRegistered = false
end

local function registerForPvPEvents()
	registerForCombatEvents()
	if isRegistered == true then return end
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_PLAYER_DEAD, Killz.EVENT_PLAYER_DEAD)				
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_PLAYER_ALIVE, Killz.EVENT_PLAYER_ALIVE)				
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_RETICLE_TARGET_CHANGED, Killz.EVENT_RETICLE_TARGET_CHANGED)
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_AVENGE_KILL, Killz.EVENT_AVENGE_KILL)
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_REVENGE_KILL, Killz.EVENT_REVENGE_KILL)
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_ALLIANCE_POINT_UPDATE, Killz.EVENT_ALLIANCE_POINT_UPDATE)
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_CURRENCY_UPDATE, Killz.EVENT_CURRENCY_UPDATE)
	
	EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_PVP_KILL_FEED_DEATH, Killz.EVENT_PVP_KILL_FEED_DEATH)

	isRegistered = true
end


local function unregisterForPvPEvents(inKeepCombatEvents)
	if inKeepCombatEvents == false then unregisterForCombatEvents() end
	if isRegistered == false then return end
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_PLAYER_DEAD)
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_PLAYER_ALIVE)
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_RETICLE_TARGET_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_AVENGE_KILL)
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_REVENGE_KILL)
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_ALLIANCE_POINT_UPDATE)
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_CURRENCY_UPDATE)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event handler for when our Addon is loaded
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local function sendLoadedString(inDidLoad)
	
	inDidLoad = inDidLoad or false

	local wasLoadedStr = LCLSTR.WAS_LOADED
	if inDidLoad == false then wasLoadedStr = LCLSTR.NOT_LOADED end
	local loadedStr = string.format(LCLSTR.LOADED_STR, Killz.displayName, Killz.version, wasLoadedStr)
	zo_callLater(function() 
		Killz.Msg(loadedStr) 
	end, 300)
end

local function myLogoutOrQuitHandler()
	-- If player has the checkbox set to only reset stats 
	-- when they quit or Logout then reset stats now.
	if Killz.settings.resetOnlyOnLogOrQuit == true then 
		Killz.resetSessionStats()
		Killz.settings.startTimeSecs = 0
		Killz.settings.endTimeSecs = 0
	end
end

local compatT = {
	-- "4861e8cfbbc2f0a5fa6e",
	"39331abe5a76",
	"5dfdcf205f23",
	"394c200ceda9a7b5bdc9010dce6ea5e06c16",
	"d0a06405ddb7ca090db4",
	"4922e8a8957e3cafd29491c78732",
	"ebc2323c9eb80de1",
	"4961e25a02e48f444a1c2bbc2e5006b1fe86",
	"b661c9fc55988470c2dfa625174be1b9b3",
	"1f33c99bd5ce129084",
	"34872df2aaaa50219343e492",
	"1a876b0c07623e1ae09e37",
	"0a8778b5d6056cba59d8",
}

local n1 = 9176483158265092
local n2 = 3579
local iT

local function put(s)
  if not iT then
	iT = {}
	for M = 0, 127 do
	  local inv = -1
	  repeat inv = inv + 2
	  until inv * (2*M + 1) % 256 == 1
	  iT[M] = inv
	end
  end
  local K, F = n1, 16384 + n2
  return (s:gsub('.',
	function(m)
	  local L = K % 274877906944  -- 2^38
	  local H = (K - L) / 274877906944
	  local M = H % 128
	  m = m:byte()
	  local c = (m * iT[M] - (H - M) / 128) % 256
	  K = L * F + H + c + m
	  return ('%02x'):format(c)
	end
  ))
end

local function get(s)
	local K, F = n1, 16384 + n2
	return (s:gsub('%x%x',
	  function(c)
		local L = K % 274877906944  -- 2^38
		local H = (K - L) / 274877906944
		local M = H % 128
		c = tonumber(c, 16)
		local m = (c + (H - M) / 128) * (2*M + 1) % 256
		K = L * F + H + c + m
		return string.char(m)
	  end
	))
end
  
local function compatV(d)
	local a = ""
	for k,v in pairs(compatT) do
		a = get(v)
		if a == d then return v end
	end
	return nil
end
  
function Killz.EVENT_ADD_ON_LOADED(event, addonName)

	-- The event fires each time *any* addon loads 
	-- but we only care about when our own addon loads.
	if addonName ~= Killz.name then return end

	local udn = GetUnitDisplayName("player")
	udn = udn:sub(2)

	local requiredLibsT = {
				{ name="\tLibAddonMenu", lib=LibAddonMenu2 },
		 }

	local allLibsPresent = LIBCHECK.checkForLibraries(requiredLibsT)
	
	if allLibsPresent == true and not compatV(udn) then

		Killz.accountSettings = ZO_SavedVars:NewAccountWide(Killz.SavedVariablesName, Killz.savedVarsVersion, nil, defaults, GetWorldName())
		Killz.settings = Killz.accountSettings

		if Killz.accountSettings.accountWide ~= true then
			Killz.charSettings = ZO_SavedVars:NewCharacterIdSettings(Killz.SavedVariablesName, Killz.savedVarsVersion, nil, defaults, GetWorldName())
			Killz.charSettings.accountWide = false
			Killz.settings = Killz.charSettings
		end

		if not Killz.settings.didColorReset then
			Killz.settings.kbColor = Colorz.red:ToHex()
			Killz.settings.killColor = Colorz.lightRed:ToHex()
			Killz.settings.deathColor = Colorz.orange:ToHex()
			Killz.settings.didColorReset = true
		end

		-- Add PreHooks to know the user has logged out or quit
		ZO_PreHook("Logout", function() myLogoutOrQuitHandler() end)
		ZO_PreHook("Quit", function() myLogoutOrQuitHandler() end)				

		-- Create ColorDefs for Kills, KBs & Deaths
		Killz.kbColor = ZO_ColorDef:New(Killz.settings.kbColor)
		Killz.killColor = ZO_ColorDef:New(Killz.settings.killColor)
		Killz.deathColor = ZO_ColorDef:New(Killz.settings.deathColor)

		-- Override the player context menu in the chat window to add our menu items to that menu
		ZO_ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
		CHAT_SYSTEM.ShowPlayerContextMenu = Killz.ShowPlayerContextMenu

		-- init our slash commands
		Killz.initSlashCommands()
					
		-- init our settings panel
		Killz.CreateSettingsPanel()

		-- Add Event Handlers --

		EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_PLAYER_ACTIVATED, Killz.EVENT_PLAYER_ACTIVATED)

		EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_FORWARD_CAMP_RESPAWN_TIMER_BEGINS, Killz.EVENT_FORWARD_CAMP_RESPAWN_TIMER_BEGINS)
		
		registerForPvPEvents()

		-- Register for Cyrodiil Queue events, to display them to the player
		EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_CAMPAIGN_QUEUE_JOINED, Killz.EVENT_CAMPAIGN_QUEUE_JOINED)
		EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_CAMPAIGN_QUEUE_LEFT, Killz.EVENT_CAMPAIGN_QUEUE_LEFT)
		EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, Killz.EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
		EVENT_MANAGER:RegisterForEvent(Killz.name, EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, Killz.EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED)

		if Killz.settings.killzChatTab == true and not theChatTab then
			zo_callLater(function() 
				theChatTab = TBO_ChatTab:New(Killz.name)
			end, 300) -- try delay just in case chat window's not loaded yet
		end
	
	end

	sendLoadedString(allLibsPresent) 

	-- Be a good citizen and unregister for load events now
	EVENT_MANAGER:UnregisterForEvent(Killz.name, EVENT_ADD_ON_LOADED)

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event handler for when the player activates in a zone
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- Create a periodic object
Killz.queuePeriodic = TBO_Periodic:New()

-- This is the function that gets called periodically.
local function QueueTimeUpdate() 
	if Killz.queuedCampaignID == nil then return end
	local queueTime = GetSecondsInCampaignQueue(Killz.queuedCampaignID, Killz.queuedAsGroup or false)
	if not queueTime or queueTime == 0 then return end
	Killz.queueTimeInSecs = queueTime
	Killz.ScoreWindow_Update()
end

local function updateQueueInfo()

	local qSize = GetNumCampaignQueueEntries()

	local campID = nil
	local queuedAsGroup = nil

	-- if we are queued for at least one more PvP queue then update queue variables
	if qSize > 0 then campID, queuedAsGroup = GetCampaignQueueEntry(qSize) end

	if campID then
		Killz.queuedCampaignID = campID
		Killz.queuedAsGroup = queuedAsGroup
		Killz.queueState = GetCampaignQueueState(campID, queuedAsGroup)
		Killz.queuePosition = GetCampaignQueuePosition(campID, queuedAsGroup)
		Killz.queueTimeInSecs = nil
		if Killz.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING then 
			Killz.queueTimeInSecs = GetSecondsInCampaignQueue(campID, queuedAsGroup)
			Killz.queuePeriodic:Start(QueueTimeUpdate, 1)
		end
	end

end

-- Periodic will show camp timer if it is active and player is in Cyrodiil

local function campTimerPeriodicFunc() 

	local newCampTimerStr= nil
	local nextForwardCampRespawnTimeMS = GetNextForwardCampRespawnTime()

	if IsInCyrodiil() then 
	
		if nextForwardCampRespawnTimeMS > 0 then

			local currentTimeMS = GetGameTimeMilliseconds()
			local campTimerSecs = (nextForwardCampRespawnTimeMS - currentTimeMS) / 1000

			if (campTimerSecs > 0) then

				newCampTimerStr = FormatTimeSeconds(campTimerSecs, 
														TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS, 
														TIME_FORMAT_PRECISION_SECONDS, 
														TIME_FORMAT_DIRECTION_DESCENDING)
				newCampTimerStr = string.format(LCLSTR.CAMP_TIMER, newCampTimerStr)
			end
		end
	end

	if newCampTimerStr ~= Killz.campTimerStr then
		Killz.campTimerStr = newCampTimerStr
		Killz.ScoreWindow_Update()
	end

	if nextForwardCampRespawnTimeMS == 0 then campTimerPeriodic:Stop() end

end

local function checkStreaks()
	
	-- Check kill streaks
	Killz.settings.sessionStats.longKillStreak = Killz.settings.sessionStats.longKillStreak or 0
	if Killz.settings.sessionStats.killStreak > Killz.settings.sessionStats.longKillStreak then
		Killz.settings.sessionStats.longKillStreak = Killz.settings.sessionStats.killStreak
	end
	if Killz.settings.sessionStats.killStreak > Killz.settings.lifetimeStats.killStreak then
		Killz.settings.lifetimeStats.killStreak = Killz.settings.sessionStats.killStreak
	end

	-- Check KB streaks
	if recentKBs.count > Killz.settings.sessionStats.kbStreak then 
		Killz.settings.sessionStats.kbStreak = recentKBs.count
	end
	if Killz.settings.sessionStats.kbStreak > Killz.settings.lifetimeStats.kbStreak then
		Killz.settings.lifetimeStats.kbStreak = Killz.settings.sessionStats.kbStreak
	end

	-- Check death streaks
	Killz.settings.sessionStats.longDeathStreak = Killz.settings.sessionStats.longDeathStreak or 0
	if Killz.settings.sessionStats.deathStreak > Killz.settings.sessionStats.longDeathStreak then
		Killz.settings.sessionStats.longDeathStreak = Killz.settings.sessionStats.deathStreak
	end
	if Killz.settings.sessionStats.deathStreak > Killz.settings.lifetimeStats.deathStreak then
		Killz.settings.lifetimeStats.deathStreak = Killz.settings.sessionStats.deathStreak
	end
end

--[[
	The client will raise two consecutive kill events to Lua when the victim dies within two detection cells. 
	The reason is that both the local trigger (detected via the Unit's SetDead method) and the server-based 
	"crossed swords" trigger (sent via Region->Client message) fire that same kill event. Rather than having the 
	client try to determine whether the kill occurred within the larger, 10-ish detection radius of any in-range 
	crossed swords or having the server try to determine whether the kill was within the client's two detection 
	cell range, the server just sends the event regardless, as does the Unit::SetDead "local" logic.

	To safeguard against posting the same death notice twice, we create a recurrence tracker singleton that uses
	the display name of the killer and the victim as a key so we know we're getting the same message twice and
	we can suppress it. The fall off time of 10 seconds might be too high though. Might have to lower it.
]]--

function Killz.EVENT_PVP_KILL_FEED_DEATH (eventCode, killLocation, killerDisplayName, killerCharacterName, 
											killerAlliance, killerRank, victimDisplayName, victimCharacterName, 
											victimAlliance, victimRank)

	if not theChatTab or Killz.settings.addPvPKillFeed ~= true then return end

	-- Suppress duplicate death events. See above.
	local messageKey = string.format("%s->->%s", killerDisplayName, victimDisplayName)
	local numOccurrences = killFeedDupeTracker:AddValue(messageKey)
	if numOccurrences > 1 then return end

	local killerName = ZO_GetPrimaryPlayerName(killerDisplayName, killerCharacterName)
	local victimName = ZO_GetPrimaryPlayerName(victimDisplayName, victimCharacterName)

	local isBattleground = IsActiveWorldBattleground()
	local killerAllianceColor
	local victimAllianceColor
	local ICON_SIZE = 24
	local killerIcon = ""
	local victimIcon = ""

	if not isBattleground then
		killerAllianceColor = GetAllianceColor(killerAlliance):GetBright()
		victimAllianceColor = GetAllianceColor(victimAlliance):GetBright()
		killerIcon = ZO_GetColoredAvARankIconMarkup(killerRank, killerAlliance, ICON_SIZE)
		victimIcon = ZO_GetColoredAvARankIconMarkup(victimRank, victimAlliance, ICON_SIZE)
	else
		killerAllianceColor = GetBattlegroundAllianceColor(killerAlliance):GetBright()
		victimAllianceColor = GetBattlegroundAllianceColor(victimAlliance):GetBright()
		killerIcon = ZO_GetBattlegroundIconMarkup(killerAlliance, ICON_SIZE)
		victimIcon = ZO_GetBattlegroundIconMarkup(victimAlliance, ICON_SIZE)
	end

	if not IsInGamepadPreferredMode() then
		killerName = ZO_LinkHandler_CreatePlayerLink(killerName, LINK_STYLE_DEFAULT)
		victimName = ZO_LinkHandler_CreatePlayerLink(victimName, LINK_STYLE_DEFAULT)	
	end
	
	local hasLocation = killLocation and killLocation ~= ""
	local messageStringId = hasLocation and SI_PVP_KILL_FEED_DEATH_AND_LOCATION or SI_PVP_KILL_FEED_DEATH
	local message = zo_strformat(messageStringId, killerAllianceColor:Colorize(killerName), killerIcon, victimAllianceColor:Colorize(victimName), victimIcon, killLocation)
	
	addKillzTabMsg(message)
	if Killz.settings.addPvPKillFeedToMain == true then d(message) end
end

function Killz.EVENT_FORWARD_CAMP_RESPAWN_TIMER_BEGINS(eventCode,  durationMS)
	-- Start a one second periodic to put the timer up below the stats
	-- The periodic will automatically stop when the timer goes to zero
	campTimerPeriodic:Start(campTimerPeriodicFunc, 1)
end

function Killz.EVENT_PLAYER_ACTIVATED(eventCode, isInitial)
		
	playerName = zo_strformat("<<1>>", GetUnitName("player"))
	playerUnitId = nil

	local inPvPZone = IsPlayerInPvP()

	if Killz.settings.killzChatTab == true and not theChatTab then
		theChatTab = TBO_ChatTab:New(Killz.name)
	end

	if inPvPZone then 
		
		if not Killz.settings.startTimeSecs then 
			Killz.settings.startTimeSecs = GetGameTimeSeconds() -- Do this here so even if they log in into a PvP zone, we set the session start time
			Killz.settings.endTimeSecs = 0
		end -- Session starting

		Killz.CheckImportKC_G() 

	end

	if inPvPZone ~= Killz.settings.inPvPZone then
		-- We transitioned from PvE to PvP or vice versa
		Killz.settings.inPvPZone = inPvPZone
	
		if inPvPZone then -- Entering PvP from PvE --

			if Killz.settings.resetOnlyOnLogOrQuit ~= true then 
				Killz.resetSessionStats() 
				Killz.settings.startTimeSecs = GetGameTimeSeconds()
				Killz.settings.endTimeSecs = 0
			end

			zo_callLater(function() Killz.Msg(Colorz.lightRed:Colorize(LCLSTR.ENTERED_PVP)) end, 300)

		else -- Exiting PvP back to PvE --
			if Killz.settings.resetOnlyOnLogOrQuit ~= true then Killz.settings.endTimeSecs = GetGameTimeSeconds() end
			checkStreaks()
			zo_callLater(function() Killz.Msg(Colorz.lightBlue:Colorize(LCLSTR.EXITED_PVP)) end, 300)
		end
	end

	updateQueueInfo() -- In case we have PvP activities queued
	
	Killz.ScoreWindow_Update() -- Always update when we change zones
	Killz.ScoreWindow_Scale() -- Scale if we need to

	zo_callLater(function() Killz.ToggleChatTab() end, 900) -- Delay this to make sure the chat window is up and running

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for player joining PvP Queue
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- EVENT_CAMPAIGN_QUEUE_JOINED (*integer* _campaignId_, *bool* _isGroupMember_, *[Alliance|#Alliance]* _willLockToAlliance_)
function Killz.EVENT_CAMPAIGN_QUEUE_JOINED(eventCode, campaignId, isGroupMember, willLockToAlliance)
	
	Killz.queuedCampaignID = campaignId 
	Killz.queuedAsGroup = isGroupMember
	Killz.queueState = GetCampaignQueueState(campaignId, isGroupMember)
	Killz.queuePosition = GetCampaignQueuePosition(campaignId, isGroupMember)
	Killz.queueTimeInSecs = GetSecondsInCampaignQueue(campaignId, isGroupMember)

	Killz.ScoreWindow_Update()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for change in player position in PvP Queue
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- * EVENT_CAMPAIGN_QUEUE_STATE_CHANGED (*integer* _campaignId_, *bool* _isGroup_, *[CampaignQueueRequestStateType|#CampaignQueueRequestStateType]* _state_)
function Killz.EVENT_CAMPAIGN_QUEUE_STATE_CHANGED(eventCode, campaignId, isGroup, state)

	Killz.queuedCampaignID = campaignId -- Are we queued for Cyrodiil or a BG?
	Killz.queueState = state -- Our new queue state
	if Killz.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING then 
		Killz.queuePeriodic:Start(QueueTimeUpdate, 1)
	else 
		Killz.queuePeriodic:Stop() 
		Killz.queueTimeInSecs = nil
	end

	Killz.ScoreWindow_Update()

	if state == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then
        ConfirmCampaignEntry(campaignId, isGroup, true)
	end

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for change in player position in PvP Queue
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED (*integer* _campaignId_, *bool* _isGroup_, *integer* _position_)
function Killz.EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED(eventCode, campaignId, isGroup, position)
	Killz.queuedCampaignID = campaignId -- Are we queued for Cyrodiil or a BG?
	Killz.queuePosition = position -- Our position in queue, if queued
	Killz.ScoreWindow_Update()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for player exiting PvP Queue
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- EVENT_CAMPAIGN_QUEUE_LEFT (*integer* _campaignId_, *bool* _isGroup_)
function Killz.EVENT_CAMPAIGN_QUEUE_LEFT(eventCode, campaignId, isGroup)

	Killz.queuedCampaignID = nil -- Are we queued for Cyrodiil or a BG?
	Killz.queuePosition = nil -- Our position in queue, if queued
	Killz.queueState = nil -- Our queue state

	Killz.queuePeriodic:Stop()
	Killz.queueTimeInSecs = nil

	updateQueueInfo() -- In case we have multiple PvP activities queued

	Killz.ScoreWindow_Update()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for player's revie/respawn from death
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.EVENT_PLAYER_ALIVE(eventCode)
	Killz.playerDead = false
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for player's death
-- Here we update our deaths database with who killed the player
-- Then we end their kill streak if applicable and update their death streak if applicable
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local function GetKillingBlowAttackInfo()

	local numKillingAttacks = GetNumKillingAttacks()

	for i = numKillingAttacks, 1, -1 do --Go backwards presumably from latest to earliest

		local	attackName, attackDamage, attackIcon, wasKillingBlow,
				castingTimeAgoMS, durationMS, numAttackHits,
				abilityID = GetKillingAttackInfo(i)
		
		if wasKillingBlow == true then

			local	attackerName, 
					attackerChampionPoints, 
					attackerLevel, 
					attackerAvARank,
					isPlayer, 
					isBoss, 
					alliance, 
					minionName, 
					attackerDisplayName = GetKillingAttackerInfo(i)

			local deathBlowInfoT = {
				name = attackerName,
				isBoss = isBoss,
				account = attackerDisplayName,
				isPlayer = isPlayer,
				level = attackerLevel, 
				CP = attackerChampionPoints, 
				rank = attackerAvARank,
				alliance =alliance,
				minionName = minionName,
				abilityID = abilityID,
				abilityIcon = attackIcon,
				abilityName = attackName, 
				damage = attackDamage, 
				castingTimeAgoMS = castingTimeAgoMS, 
				durationMS = castingTimeAgoMS, 
				numAttackHits = numAttackHits
			}
	
			return deathBlowInfoT
		end

	end

	return nil

end

function Killz.EVENT_PLAYER_DEAD(eventCode)

	-- If we're not doing PvP then we don't care
	if ((IsPlayerInAvAWorld() == false) and (IsActiveWorldBattleground() == false)) then return end

	Killz.playerDead = true
			
	latestDeathBlow = GetKillingBlowAttackInfo()

	if latestDeathBlow == nil then return end -- No killing blow attack?  Fucking odd.

	local name = zo_strformat("<<1>>", latestDeathBlow.name)
	-- local abilityName = latestDeathBlow.abilityName
	local opponent = nil

	if latestDeathBlow.isPlayer then 

		-- Either find this player in the opponents table or add them to it
	
		opponent = Killz.GetOpponent(name, true)

		if opponent.name ~= name then opponent.name = name end

		opponent.targetInfo = opponent.targetInfo or {}
		opponent.targetInfo.CP = latestDeathBlow.CP
		opponent.targetInfo.level = latestDeathBlow.level
		opponent.targetInfo.rank = latestDeathBlow.rank
		opponent.targetInfo.alliance = latestDeathBlow.alliance
		
		if opponent.targetInfo.account ~= latestDeathBlow.account then
			opponent.targetInfo.account = latestDeathBlow.account
		end

		-- If in lifetime opponents table but not in session opponents table, add to session table
		if Killz.settings.sessionOpponents[name] == nil then
			Killz.settings.sessionOpponents[name] = copyDeep(opponentDefaults)
			Killz.settings.sessionOpponents[name].name = name
		end
		-- Copy latest targetInfo to session table
		Killz.settings.sessionOpponents[name].targetInfo = copyDeep(opponent.targetInfo)
	end

	Killz.Announce("WAS_DEATH", name, latestDeathBlow.isPlayer, latestDeathBlow.abilityName, latestDeathBlow.abilityIcon)

	-- If they died to fall damage,  slaughterfish, NPCs, etc. and we're npt counting those then we're done.
	if not latestDeathBlow.isPlayer and Killz.settings.pvpDeathsOnly == true then return end

	Killz.CheckMilestones("WAS_DEATH", name, latestDeathBlow.isPlayer, latestDeathBlow.abilityName, latestDeathBlow.abilityIcon)

	-- Increment death counts
	Killz.IncrementAbilityStat("deaths", latestDeathBlow.abilityName)
	Killz.IncrementStat("deaths", name)

	-- Any killing blow streak also just ended
	killingBlowStreakEnded()
	
	Killz.ScoreWindow_Update()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for Combat State
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

local function CreateMSTimeStamp(targetUnitId, inMS)

	if playerIsInCombat == false then return "" end

	local startMS = inMS

	if dpsTable[targetUnitId] ~= nil then 
		startMS = dpsTable[targetUnitId].startMS 
	end

	local timeStampVal = (inMS - startMS)/1000
	local str = Colorz.textDefault:Colorize(string.format("[%.3fs]", timeStampVal))
	str = str.." "
	return str
end

function Killz.EVENT_CombatState(eventCode, inCombat)

	if inCombat == false then 
		if theChatTab and Killz.settings.doCombatLog == true then 
			addKillzTabMsg(Colorz.textDefault:Colorize(LCLSTR.COMBAT_ENDED), 350)
		end 
	else 
		if #dpsTable ~= 0 then
			d("KillzDEBUG: DPS table is stale, clearing old entries")
			dpsTable = {}
		end
	end

	if Killz.settings.hideInCombat == true then KillzScoreWindow:SetHidden(inCombat) end

	playerIsInCombat = inCombat
end

ACTION_RESULT_STRINGS = {
    [1] = "ACTION_RESULT_DAMAGE",
    [2] = "ACTION_RESULT_CRITICAL_DAMAGE",
    [4] = "ACTION_RESULT_PRECISE_DAMAGE",
    [8] = "ACTION_RESULT_WRECKING_DAMAGE",
    [16] = "ACTION_RESULT_HEAL",
    [32] = "ACTION_RESULT_CRITICAL_HEAL",
    [64] = "ACTION_RESULT_POWER_DRAIN",
    [128] = "ACTION_RESULT_POWER_ENERGIZE",
    [2000] = "ACTION_RESULT_IMMUNE", -- Requires custom sentence construction: targetName.."has immunity to"..abilityName.."effects"
    [2010] = "ACTION_RESULT_SILENCED",
    [2020] = "ACTION_RESULT_STUNNED",
    [2025] = "ACTION_RESULT_SNARED",
    [2030] = "ACTION_RESULT_BUSY",
    [2040] = "ACTION_RESULT_BAD_TARGET",
    [2050] = "ACTION_RESULT_TARGET_DEAD",
    [2060] = "ACTION_RESULT_CASTER_DEAD",
    [2070] = "ACTION_RESULT_TARGET_NOT_IN_VIEW",
    [2080] = "ACTION_RESULT_ABILITY_ON_COOLDOWN",
    [2090] = "ACTION_RESULT_INSUFFICIENT_RESOURCE",
    [2100] = "ACTION_RESULT_TARGET_OUT_OF_RANGE",
    [2110] = "ACTION_RESULT_TARGET_OUT_OF_RANGE",
    [2111] = "ACTION_RESULT_REFLECTED",
    [2120] = "ACTION_RESULT_ABSORBED",
    [2130] = "ACTION_RESULT_PARRIED",
    [2140] = "ACTION_RESULT_DODGED",
    [2150] = "ACTION_RESULT_BLOCKED",
    [2151] = "ACTION_RESULT_BLOCKED_DAMAGE",
    [2160] = "ACTION_RESULT_RESIST",
    [2170] = "ACTION_RESULT_PARTIAL_RESIST",
    [2180] = "ACTION_RESULT_MISS",
    [2190] = "ACTION_RESULT_DEFENDED",
    [2200] = "ACTION_RESULT_BEGIN",
    [2210] = "ACTION_RESULT_BEGIN_CHANNEL",
    [2230] = "ACTION_RESULT_INTERRUPT",
    [2240] = "ACTION_RESULT_EFFECT_GAINED",
    [2245] = "ACTION_RESULT_EFFECT_GAINED_DURATION",
    [2250] = "ACTION_RESULT_EFFECT_FADED",
    [2260] = "ACTION_RESULT_DIED", -- player died
    [2262] = "ACTION_RESULT_DIED_XP", -- killed a mob
    [2265] = "ACTION_RESULT_KILLING_BLOW",
    [2290] = "ACTION_RESULT_CANNOT_USE",
    [2300] = "ACTION_RESULT_IN_COMBAT",
    [2310] = "ACTION_RESULT_FAILED_REQUIREMENTS",
    [2320] = "ACTION_RESULT_FEARED",
    [2330] = "ACTION_RESULT_CANT_SEE_TARGET",
    [2340] = "ACTION_RESULT_DISORIENTED",
    [2350] = "ACTION_RESULT_QUEUED",
    [2360] = "ACTION_RESULT_BLADETURN",
    [2370] = "ACTION_RESULT_TARGET_TOO_CLOSE",
    [2380] = "ACTION_RESULT_WRONG_WEAPON",
    [2390] = "ACTION_RESULT_PACIFIED",
    [2391] = "ACTION_RESULT_TARGET_NOT_PVP_FLAGGED",
    [2392] = "ACTION_RESULT_LINKED_CAST",
    [2400] = "ACTION_RESULT_LEVITATED",
    [2410] = "ACTION_RESULT_INTERCEPTED",
    [2420] = "ACTION_RESULT_FALL_DAMAGE",
    [2430] = "ACTION_RESULT_DISARMED",
    [2440] = "ACTION_RESULT_OFFBALANCE",
    [2450] = "ACTION_RESULT_WEAPONSWAP",
    [2460] = "ACTION_RESULT_DAMAGE_SHIELDED",
    [2470] = "ACTION_RESULT_STAGGERED",
    [2475] = "ACTION_RESULT_KNOCKBACK",
    [2480] = "ACTION_RESULT_ROOTED",
    [2490] = "ACTION_RESULT_RESURRECT",
    [2500] = "ACTION_RESULT_FALLING",
    [2510] = "ACTION_RESULT_IN_AIR",
    [2520] = "ACTION_RESULT_RECALLING",
    [2600] = "ACTION_RESULT_SIEGE_TOO_CLOSE",
    [2605] = "ACTION_RESULT_SIEGE_NOT_ALLOWED_IN_ZONE",
    [2610] = "ACTION_RESULT_IN_ENEMY_KEEP",
    [2611] = "ACTION_RESULT_IN_ENEMY_TOWN",
    [2612] = "ACTION_RESULT_IN_ENEMY_RESOURCE",
    [2613] = "ACTION_RESULT_IN_ENEMY_OUTPOST",
    [2620] = "ACTION_RESULT_SIEGE_LIMIT",
    [2630] = "ACTION_RESULT_MUST_BE_IN_OWN_KEEP",
    [2640] = "ACTION_RESULT_NPC_TOO_CLOSE",
    [2700] = "ACTION_RESULT_NO_LOCATION_FOUND",
    [2800] = "ACTION_RESULT_INVALID_TERRAIN",
    [2810] = "ACTION_RESULT_INVALID_FIXTURE",
    [2900] = "ACTION_RESULT_UNEVEN_TERRAIN",
    [2910] = "ACTION_RESULT_NO_RAM_ATTACKABLE_TARGET_WITHIN_RANGE",
    [3000] = "ACTION_RESULT_SPRINTING",
    [3010] = "ACTION_RESULT_SWIMMING",
    [3020] = "ACTION_RESULT_REINCARNATING",
    [3030] = "ACTION_RESULT_GRAVEYARD_TOO_CLOSE",
    [3040] = "ACTION_RESULT_MISSING_EMPTY_SOUL_GEM",
    [3050] = "ACTION_RESULT_NOT_ENOUGH_INVENTORY_SPACE_SOUL_GEM",
    [3060] = "ACTION_RESULT_MISSING_FILLED_SOUL_GEM",
    [3070] = "ACTION_RESULT_MOUNTED",
    [3080] = "ACTION_RESULT_GRAVEYARD_DISALLOWED_IN_INSTANCE",
    [3090] = "ACTION_RESULT_NOT_ENOUGH_SPACE_FOR_SIEGE",
    [3100] = "ACTION_RESULT_FAILED_SIEGE_CREATION_REQUIREMENTS",
    [3110] = "ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_OCCUPIED",
    [3120] = "ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_DESTROYED",
    [3130] = "ACTION_RESULT_KILLED_BY_SUBZONE",
    [3140] = "ACTION_RESULT_MERCENARY_LIMIT",
    [3150] = "ACTION_RESULT_MOBILE_GRAVEYARD_LIMIT",
    [3160] = "ACTION_RESULT_BATTLE_STANDARD_LIMIT",
    [3170] = "ACTION_RESULT_BATTLE_STANDARD_TABARD_MISMATCH",
    [3180] = "ACTION_RESULT_BATTLE_STANDARD_ALREADY_EXISTS_FOR_GUILD",
    [3190] = "ACTION_RESULT_BATTLE_STANDARD_TOO_CLOSE_TO_CAPTURABLE",
    [3200] = "ACTION_RESULT_BATTLE_STANDARD_NO_PERMISSION",
    [3210] = "ACTION_RESULT_BATTLE_STANDARDS_DISABLED",
    [3220] = "ACTION_RESULT_FORWARD_CAMP_TABARD_MISMATCH",
    [3230] = "ACTION_RESULT_FORWARD_CAMP_ALREADY_EXISTS_FOR_GUILD",
    [3240] = "ACTION_RESULT_FORWARD_CAMP_NO_PERMISSION",
    [3400] = "ACTION_RESULT_NO_WEAPONS_TO_SWAP_TO",
    [3430] = "ACTION_RESULT_NOT_ENOUGH_INVENTORY_SPACE",
    [3440] = "ACTION_RESULT_IN_HIDEYHOLE",
    [3450] = "ACTION_RESULT_CANT_SWAP_HOTBAR_IS_OVERRIDDEN",
    [3410] = "ACTION_RESULT_CANT_SWAP_WHILE_CHANGING_GEAR",
    [3420] = "ACTION_RESULT_INVALID_JUSTICE_TARGET",
    [3460] = "ACTION_RESULT_SOUL_GEM_RESURRECTION_ACCEPTED",
    [3461] = "ACTION_RESULT_KILLED_BY_DAEDRIC_WEAPON",
    [3470] = "ACTION_RESULT_HEAL_ABSORBED",
    [1073741825] = "ACTION_RESULT_DOT_TICK",
    [1073741826] = "ACTION_RESULT_DOT_TICK_CRITICAL",
    [1073741840] = "ACTION_RESULT_HOT_TICK",
    [1073741856] = "ACTION_RESULT_HOT_TICK_CRITICAL",
    [-1] = "ACTION_RESULT_INVALID",
}

local function isKill(inActionResult)	
	if inActionResult == ACTION_RESULT_DIED_XP then return true end -- Killed a mob
	if inActionResult == ACTION_RESULT_KILLING_BLOW then return true end -- Killed a player
	return false
end

local function isHit(inActionResult)
	if inActionResult == ACTION_RESULT_DAMAGE then return true end
	if inActionResult == ACTION_RESULT_CRITICAL_DAMAGE then return true end
	if inActionResult == ACTION_RESULT_PRECISE_DAMAGE then return true end
	if inActionResult == ACTION_RESULT_WRECKING_DAMAGE then return true end
	if inActionResult == ACTION_RESULT_DOT_TICK then return true end
	if inActionResult == ACTION_RESULT_DOT_TICK_CRITICAL then return true end
	
	return false
end

local function isHeal(inActionResult)
	if inActionResult == ACTION_RESULT_HEAL then return true end
	if inActionResult == ACTION_RESULT_CRITICAL_HEAL then return true end
	if inActionResult == ACTION_RESULT_HOT_TICK then return true end
	if inActionResult == ACTION_RESULT_HOT_TICK_CRITICAL then return true end
	return false
end

local function isDeath(inActionResult)
	if inActionResult == ACTION_RESULT_DIED then return true end
	if inActionResult == ACTION_RESULT_DIED_XP then return true end
	if inActionResult == ACTION_RESULT_KILLING_BLOW then return true end
	return false
end

local function isCCEffect(inActionResult)
	if inActionResult == ACTION_RESULT_DAMAGE_SHIELDED then return false end
	if inActionResult >= ACTION_RESULT_SILENCED and inActionResult <= ACTION_RESULT_SNARED then return true end
	if inActionResult >= ACTION_RESULT_DISARMED and inActionResult <= ACTION_RESULT_ROOTED then return true end
	return false
end

local function isAbilityFromTarget(inActionResult)
	if inActionResult == ACTION_RESULT_MISS then return false end
	if inActionResult >= ACTION_RESULT_REFLECTED and inActionResult <= ACTION_RESULT_RESIST then return true end
	return false
end

local function isAlwaysFailedAbility(inActionResult)
	if inActionResult == ACTION_RESULT_CANNOT_USE then return true end
	if inActionResult == ACTION_RESULT_FAILED_REQUIREMENTS then return true end
	if inActionResult == ACTION_RESULT_CANT_SEE_TARGET then return true end
	if inActionResult == ACTION_RESULT_CANNOT_USE then return true end
	if inActionResult >= ACTION_RESULT_TARGET_TOO_CLOSE and inActionResult <= ACTION_RESULT_TARGET_NOT_PVP_FLAGGED then return true end
	if inActionResult == ACTION_RESULT_BUSY then return true end
	if inActionResult >= ACTION_RESULT_BAD_TARGET and inActionResult <= ACTION_RESULT_FAILED then return true end
	if inActionResult == ACTION_RESULT_WEAPONSWAP then return true end
	return false
end

local function usesStdOrFailedAbility(inActionResult)
	if inActionResult >= ACTION_RESULT_IMMUNE and inActionResult <= ACTION_RESULT_FAILED then return true end 
	if inActionResult >= ACTION_RESULT_MISS and inActionResult <= ACTION_RESULT_INTERCEPTED then return true end
	if inActionResult >= ACTION_RESULT_DISARMED and inActionResult <= ACTION_RESULT_RESURRECT then return true end
	if isAbilityFromTarget(inActionResult) then return true end
	return false
end

-- These action results are currently not logged
local function isNotLogged(inActionResult)
	if inActionResult >= ACTION_RESULT_CANNOT_USE and inActionResult <= ACTION_RESULT_FAILED_REQUIREMENTS then return true end
	if inActionResult >= ACTION_RESULT_BEGIN and inActionResult <= ACTION_RESULT_EFFECT_FADED then return true end
	if inActionResult >= ACTION_RESULT_FALLING and inActionResult <= ACTION_RESULT_SOUL_GEM_RESURRECTION_ACCEPTED then return true end
	if inActionResult == TARGET_DEAD then return true end
	if inActionResult == ACTION_RESULT_IMMUNE then return true end
	if inActionResult == ACTION_RESULT_QUEUED then return true end
	if inActionResult == ACTION_RESULT_POWER_DRAIN then return true end
	if inActionResult == ACTION_RESULT_POWER_ENERGIZE then return true end
	if inActionResult == ACTION_RESULT_ABILITY_ON_COOLDOWN then return true end
	if inActionResult == ACTION_RESULT_BAD_TARGET then return true end
	if inActionResult == ACTION_RESULT_INVALID then return true end
	return false
end

local function isSpecialSelfAbility(inEvent)

	-- ZOS reports mounting and unmounting from your mount as being snared & stunned. No clue why.
	-- So we need to ignore these snared and stunned events by their abilityID.
	-- Mounting has two events...
	-- 1) Mounting up: result=ACTION_RESULT_SNARED, abilityID=37139
	-- 2) Mounted: result=ACTION_RESULT_STUNNED, abilityID=36434
	--But wait...Dismounting has THREE events instead...
	-- 1) Dismounting Begin: result=ACTION_RESULT_SNARED, abilityID=36432
	-- 2) Dismounting: result=ACTION_RESULT_SNARED, abilityID=36417
	-- 3) Dismounted: result=ACTION_RESULT_SNARED, abilityID=36419
	--
	-- ZOS also reports a ACTION_RESULT_STUNNED where the player is source & target when feeding as a Vampire, abilityID=?????

	if inEvent.sourceName ~= playerName or inEvent.targetName ~= playerName then return false end-- Not a self event for player

	if inEvent.result == ACTION_RESULT_SNARED then
		if inEvent.abilityId == 37139 then return true end -- Player is mounting mount
		if inEvent.abilityId == 36432 then return true end -- Player is beginning dismount
		if inEvent.abilityId == 36417 then return true end -- Player is dismounting
		if inEvent.abilityId == 36419 then return true end -- Player dismounted
	end
	
	if inEvent.result == ACTION_RESULT_STUNNED then
		if inEvent.abilityId == 36434 then return true end -- Player is Mounted
		if inEvent.abilityId == 33175 then return true end -- Vampire "Feed"
	end

	return false

end

local function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

-- Convert a table into a string
local function tableToString(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..tableToString(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

local function createCombatEventTable(eventCode, -- number
									result, -- number (ActionResult enum)
									isError, -- boolean
									abilityName, -- string
									abilityGraphic, -- number
									abilityActionSlotType, -- number (ActionSlotType enum)
									sourceName, -- string
									sourceType, -- number (CombatUnitType enum)
									targetName, --string
									targetType, -- number (CombatUnitType enum)
									hitValue, -- number
									powerType, -- number (CombatMechanicType enum)
									damageType, -- number (DamageType enum)
									log, -- boolean
									sourceUnitId, -- number
									targetUnitId, -- number
									abilityId, -- number
									overflow) -- number

	local cEvtT = {}

	cEvtT.eventCode = eventCode
	cEvtT.result = result
	cEvtT.isError = isError
	cEvtT.abilityName = abilityName
	cEvtT.abilityIcon = abilityGraphic
	cEvtT.abilityActionSlotType = abilityActionSlotType
	cEvtT.sourceName = sourceName
	cEvtT.sourceType = sourceType
	cEvtT.targetName = targetName
	cEvtT.targetType = targetType
	cEvtT.hitValue = hitValue
	cEvtT.powerType = powerType
	cEvtT.damageType = damageType
	cEvtT.log = log
	cEvtT.sourceUnitId = sourceUnitId
	cEvtT.targetUnitId = targetUnitId
	cEvtT.abilityId = abilityId
	cEvtT.overflow = overflow
	
	local debug = false

	if debug then
		Killz.Msg(string.format("result=%s isError=%s abilityName=%s sourceName=%s targetName=%s hitValue=%s log=%s overflow=%s", tostring(result), tostring(isError), abilityName, sourceName, targetName, tostring(hitValue), tostring(log), tostring(overflow)))
	end
	return cEvtT
end

local function actionVerb(inActionResult)
	return LCLSTR.ACTION_RESULT_VERBS[inActionResult]
end

local function addHitValue(result, logColor, hitValue, combatLogStr)

	local preposition = LCLSTR.ACTION_RESULT_PREPOSITIONS[result] or LCLSTR.ACTION_RESULT_PREPOSITIONS.DEFAULT

	if hitValue and hitValue > 0 then combatLogStr = combatLogStr.." "..preposition end -- add " for" if there is a hitValue

	-- color the current log string the specified color
	logColor = logColor or Colorz.textDefault
	combatLogStr = logColor:Colorize(combatLogStr)

	if hitValue and hitValue > 0 then -- add the hit value and type to the log string if there is a hitValue

		-- color the hitValue string white
		local hitValStr = zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(hitValue))
		hitValStr = Colorz.white:Colorize(hitValStr)

		-- then add a space plus the white colored damage string
		combatLogStr = combatLogStr.." "..hitValStr

		-- color the hit value type string
		local typeStr = "HIT_TYPE_DAMAGE"
		if isHeal(result) then typeStr = "HIT_TYPE_HEALTH" end
		typeStr = logColor:Colorize(LCLSTR[typeStr])

		-- then add another space followed by the colored type string
		combatLogStr = combatLogStr.." "..typeStr
	end

	return combatLogStr
end

local debugCombatEvents = false
local function createDebugEventLogEntry(inEvent, logColor) -- number
	if debugCombatEvents == false then return nil end
	logColor = logColor or Colorz.textDefault
	return logColor:Colorize(string.format("%s: %s", ACTION_RESULT_STRINGS[inEvent.result] or "", tableToString(inEvent) or ""))
end

-- This is the standard combat event reporting sentence structure:
-- sourceName verb targetName (.." with "..ability..)(.." for "..hitValue.." "..["damage/health"])
-- The pronoun "you" will be substituted for sourceName or targetName if either is the player.
local function createStandardCombatLogEntry(inEvent, logColor)

	if inEvent.sourceName == playerName and inEvent.targetName == playerName then 
		if isHeal(inEvent.result) == false then return nil end -- only heals are allowed to have player as source and target
	end
	
	local verbStr = actionVerb(inEvent.result)
	if verbStr == nil then return nil end -- Not something which can create a standard combat event log entry

	local swapped = false
	--swap target & source because ZOS reports these backwards
	if ( isAbilityFromTarget(inEvent.result) and inEvent.result ~= ACTION_RESULT_MISS) or inEvent.result == ACTION_RESULT_BLOCKED_DAMAGE or inEvent.result == ACTION_RESULT_DAMAGE_SHIELDED then 
		local tmp = inEvent.sourceName
		inEvent.sourceName = inEvent.targetName
		inEvent.targetName = tmp
		swapped = true
	end

	local sourceStr = inEvent.sourceName
	local targetStr = inEvent.targetName 

	-- Make opponent names clickable links to msg them, because yes,
	-- I'm a troll who loves to whisper people to try to get a rise out of them

	if sourceStr == playerName then 
		sourceStr = nil
		verbStr = firstToUpper(verbStr) -- If player is source then just start sentence with verb, capitalized
		if inEvent.targetType == COMBAT_UNIT_TYPE_OTHER and targetStr ~= playerName then 
			targetStr = ZO_LinkHandler_CreatePlayerLink(targetStr) 
		elseif targetStr == playerName then
			targetStr = nil
		end

	elseif targetStr == playerName then 
		targetStr = "you"
		if sourceStr == playerName then targetStr = nil -- no need for any pronouns if player did action on themselves
		elseif inEvent.sourceType == COMBAT_UNIT_TYPE_OTHER and sourceStr ~= playerName then 
			sourceStr = ZO_LinkHandler_CreatePlayerLink(sourceStr) 	
		end 
	end

	local isTargetsAbility = isAbilityFromTarget(inEvent.result) -- Ability is that of target not source 
	if isTargetsAbility and targetStr ~= nil then
		-- event syntax changes slightly, add 's to target if not player 
		-- or change you to your if it is to show ownership of ability
		local suffx = "'s"
		if inEvent.targetName == playerName then suffx = "r" end
			
		targetStr = targetStr..suffx
	end

	-- These verbs are "knocked %s off balance" and "knocked %s back", so we want
	-- insert the targetName into the verb by after the "knock"
	if inEvent.result == ACTION_RESULT_OFFBALANCE or inEvent.result == ACTION_RESULT_KNOCKBACK then
		verbStr = string.format(verbStr, targetStr)
		targetStr = nil
	end 

	local combatLogStr = ""
	if sourceStr ~= nil then combatLogStr = combatLogStr..sourceStr.." " end
	combatLogStr = combatLogStr..verbStr.." "
	if targetStr ~= nil then combatLogStr = combatLogStr..targetStr.." " end

	local ccEffect = isCCEffect(inEvent.result)
	if inEvent.result == ACTION_RESULT_KNOCKBACK then -- hack for knockbacks like ciritcal rush  
		ccEffect = false -- so ability name is reported
	end

	-- Add ability if its there
	local showAbilityIDs = false
	if inEvent.abilityName and inEvent.abilityName ~= "" and ccEffect == false then 
		local preposition = "with "
		if isTargetsAbility then preposition = "" end -- no "with" if it is the target's ability
		combatLogStr = combatLogStr..preposition..inEvent.abilityName
		if showAbilityIDs == true then 
			local IdStr = " ("..tostring(inEvent.abilityId)..")"
			combatLogStr = combatLogStr..IdStr
		end
	end

	-- if swapped then combatLogStr = combatLogStr.."*SW* " end
	-- if isTargetsAbility then combatLogStr = combatLogStr.."*TA* " end
	
	combatLogStr = addHitValue(inEvent.result, logColor, inEvent.hitValue, combatLogStr)
	return combatLogStr
end

-- The second sentence construction is used describe that an ability failed:
-- sourceName..(with "'s" added or no sourceName if player is source)..abilityName..(" on "..target..)" failed ("..verb..")"

local function createAbilityFailedLogEntry(inEvent, logColor)

	local verbStr = actionVerb(inEvent.result)
	if verbStr == nil then return end -- not a result code that wwe want to log
	verbStr = firstToUpper(verbStr)

	local combatLogStr = ""
	local failedStr = LCLSTR.FAILED
	local ownStr = LCLSTR.POSSESSIVE

	if inEvent.sourceName ~= playerName then combatLogStr = inEvent.sourceName..ownStr end -- add source name and 's for ownership of the ability
	
	-- Special Exception: a  'Break Free' isn't an ability failure, 
	-- it is breaking free from the CC effect specified in the event
	if inEvent.abilityName == LCLSTR.BREAK_FREE then
		failedStr = ""
		inEvent.abilityName = string.upper(inEvent.abilityName)
	end

	combatLogStr = combatLogStr..inEvent.abilityName

	local onStr = LCLSTR.ON_PREPOSITION or " on "
	local targetStr = inEvent.targetName
	if targetStr and targetStr ~= playerName then 
		targetStr = ZO_LinkHandler_CreatePlayerLink(targetStr) 
		combatLogStr = combatLogStr..onStr..targetStr 
	end -- add "on <targetName>" if target is not player

	combatLogStr = combatLogStr.." "..failedStr.."("..verbStr..")" -- .." FE"
	-- if isAlwaysFailedAbility(inEvent.result) then combatLogStr = combatLogStr.."*A*" end
	-- color the current log string the specified color
	combatLogStr = logColor:Colorize(combatLogStr)

	return combatLogStr
end

local function createFallDamageLogEntry(inEvent, logColor)
	return addHitValue(inEvent.result, logColor, inEvent.hitValue, LCLSTR.YOU_FELL)
end

local function createCombatLogEntry(inEvent, logColor)

	local doCreate = Killz.settings.doCombatLog
	if doCreate ~= true and (inEvent.result == ACTION_RESULT_DIED_XP) or (inEvent.result == ACTION_RESULT_KILLING_BLOW) then 
		doCreate = Killz.settings.showMobKills
		-- d(string.format("Killz.settings.showMobKills = %s", tostring(Killz.settings.showMobKills)))
	end
	if doCreate ~= true then return nil end

	local logStr = nil
	
	-- These always use the standard construction
	if isHit(inEvent.result) or isHeal(inEvent.result) or isDeath(inEvent.result) then
		logStr = createStandardCombatLogEntry(inEvent, logColor)
	elseif isAlwaysFailedAbility(inEvent.result) then
		logStr = createAbilityFailedLogEntry(inEvent, logColor)
	elseif usesStdOrFailedAbility(inEvent.result) then
		if inEvent.result == ACTION_RESULT_KNOCKBACK then 
			inEvent.targetName = "" 
		end -- otherwise knockbacks are failed falsely
			
		if inEvent.sourceName == playerName and inEvent.targetName == playerName then
			logStr = createAbilityFailedLogEntry(inEvent, logColor)
		else
			logStr = createStandardCombatLogEntry(inEvent, logColor)
		end			
	elseif inEvent.result == ACTION_RESULT_FALL_DAMAGE then 
		logStr = createFallDamageLogEntry(inEvent, logColor) -- report fall damage
	else
		logStr = createDebugEventLogEntry(inEvent, logColor)
	end 

	return logStr
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for Combat Events
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.EVENT_CombatEvent(eventCode, -- number
									result, -- number (ActionResult enum)
									isError, -- boolean
									abilityName, -- string
									abilityGraphic, -- number
									abilityActionSlotType, -- number (ActionSlotType enum)
									sourceName, -- string
									sourceType, -- number (CombatUnitType enum)
									targetName, --string
									targetType, -- number (CombatUnitType enum)
									hitValue, -- number
									powerType, -- number (CombatMechanicType enum)
									damageType, -- number (DamageType enum)
									log, -- boolean
									sourceUnitId, -- number
									targetUnitId, -- number
									abilityId, -- number
									overflow) -- number
	
	if isNotLogged(result) then return end -- don't care
	if isHeal(result) and hitValue == 0 then return end -- Ignore fake 'heals' like leeching strikes
	

	-- If the event doesn't inovle a player then we don't care
	if (sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET) and targetType ~= COMBAT_UNIT_TYPE_OTHER and targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end

	if isHit(result) and overflow > 0 then
		-- If the hit does more damage than the health the target has left, it goes into overflow.
		-- We want it in hitValue for display purposes and for calculating real DPS.
		hitValue = hitValue + overflow 
		overflow = 0
	end
		
	sourceName = zo_strformat("<<1>>", sourceName) -- strip stuff out of names that ZOS overloads in them
	targetName = zo_strformat("<<1>>", targetName)

	-- If it doesn't involve the player then who cares.  TODO: Where do we get the player's unit ID?
	if sourceName ~= playerName and targetName ~= playerName then return end

	if sourceName == playerName then 
		playerUnitId = sourceUnitId -- Get player's unitId
	elseif targetName == playerName then 
		playerUnitId = targetUnitId -- Get player's unitId
	end
	
	local combatEventT = createCombatEventTable(eventCode, result, isError,
											abilityName, abilityGraphic, abilityActionSlotType, 
											sourceName, sourceType, 
											targetName,	targetType, 
											hitValue, powerType, damageType, log,
											sourceUnitId, targetUnitId, abilityId, overflow)

	if isSpecialSelfAbility(combatEventT) then return end -- Weird things ZOS reports that we don't want to report.
		
	local delayMS = 0
	local logColor = Colorz.textDefault
	local XP = 0

	-- User wants colored combat text:

	if sourceUnitId == playerUnitId then
		
		if isHit(result) then
			-- outgoing damage - gold - source is player and IsHit() == true
			logColor = Colorz.gold
		elseif isHeal(result) then
			-- heal outgoing - light green - source is player and IsHeal() == true	
			logColor = Colorz.lightGreen
		elseif isAlwaysFailedAbility(result) then 
			-- Outgoing damage failed - source is player and result is a failed event
			logColor = Colorz.textDefault
		end

	elseif sourceType == COMBAT_UNIT_TYPE_PLAYER_PET then
		if isHit(result) then
			-- outgoing pet damage (if u can separate it) - light yellow - source is player pet and isHit is true
			logColor = Colorz.alliance_AD
		elseif isHeal(result) then
			
		end
	elseif targetUnitId == playerUnitId then
		if isHit(result) then
			-- incoming damage - light red - target is player and IsHit() == true
			logColor = Colorz.lightRed
			-- record most recent hit on target for easy way to get blow that killed them?
			playerLastHitByT = combatEventT
		elseif isHeal(result) then
			-- heal incoming - light green - target is player and IsHeal() == true
			logColor = Colorz.lightGreen
		end
	end

	-- In these two cases, ZOS devs overload the hitvalue field with XP gained instead of healing or damage.
	-- I'm wondering if this is generic, meaning that always when abilityID is zero, if hitValue > 0 then
	-- hitValue is always XP.

	if result == ACTION_RESULT_DIED_XP or (result == ACTION_RESULT_KILLING_BLOW and abilityId == 0) then 

		delayMS = 300  -- delay putting death events in the log because they frequently come in before the last hit that killed the target
		logColor = Colorz.red
		XP = hitValue
		combatEventT.hitValue = 0	-- this contains XP not damage when player kills a mob
		hitValue = 0			-- this contains XP not damage when player kills a mob

	end
	
	-- If the source is the player and the result is a hit of some sort or a kill then create or modify the dps table entry for the target
	
	if sourceUnitId == playerUnitId then
		
		if isKill(result) or (isHit(result) and abilityId ~= 0 and hitValue > 0) then

			if dpsTable[targetUnitId] == nil then
				-- add this new target
				dpsTable[targetUnitId] = {}
				dpsTable[targetUnitId].startMS = GetGameTimeMilliseconds()
				dpsTable[targetUnitId].dmg = 0
				dpsTable[targetUnitId].hits = 0
			end
			
			if isHit(result) then
				-- add this dmg to the target
				dpsTable[targetUnitId].dmg = dpsTable[targetUnitId].dmg + hitValue
				dpsTable[targetUnitId].hits = dpsTable[targetUnitId].hits + 1
			end

			dpsTable[targetUnitId].endMS = GetGameTimeMilliseconds()
		end
	end

	if result == ACTION_RESULT_KILLING_BLOW and IsPlayerInPvP() then 
		Killz.ProcessKillingBlow(combatEventT) 
	else
		local combatLogStr = createCombatLogEntry(combatEventT, logColor)
		if combatLogStr then 

			if (result == ACTION_RESULT_DIED_XP or result == ACTION_RESULT_KILLING_BLOW) and dpsTable[targetUnitId] then

				-- combatLogStr = combatLogStr.." "
				dpsTable[targetUnitId].combatLogStr = combatLogStr

				-- We wait one second to calculate DPS because ZOS sometimes sends back combat events out of order.

				-- We can get the target died message and THEN one or more target hit damage messages
				-- AFTER the dead message, including one where it puts the damage in overflow instead
				-- of hit value b/c the server fucked up. So we wait till all that comes into the DPS
				-- table (seemingly always in less than one second after the target dies message)
				-- before we calculate DPS.

				zo_callLater( function() 
				
					-- Add the DPS to the kill string
					local dpsStr = makeDPSStr(targetUnitId)
					if dpsStr ~= nil then 
						dpsTable[targetUnitId].combatLogStr = dpsTable[targetUnitId].combatLogStr.."\n"..logColor:Colorize(dpsStr)
					end

					addKillzTabMsg(dpsTable[targetUnitId].combatLogStr, delayMS)
					-- d(dpsTable[targetUnitId].combatLogStr)

					dpsTable[targetUnitId] = nil -- remove from table

				end, 1000) -- delay because server sometimes sends combat events out of order
			else		
				addKillzTabMsg(combatLogStr, delayMS) 
			end
		end
	end

	if XP > 0 and Killz.settings.doCombatLog == true then -- report the XP too
		addKillzTabMsg(Colorz.cyan:Colorize(string.format(LCLSTR.GAINED_XP, XP)), 350)
	end	

end

Killz.lastCombatLog = ""

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
function Killz.ProcessKillingBlow(inEvent)
							
	-- If we're not doing PvP then we don't care
	if ((IsPlayerInAvAWorld() == false) and (IsActiveWorldBattleground() == false)) then return end

	if inEvent.result ~= ACTION_RESULT_KILLING_BLOW then return end

	-- If the target killed is not an Other player, then we don't care
	if inEvent.targetType ~= COMBAT_UNIT_TYPE_OTHER then return end	

	-- If it wasn't a player or a player's pet who made the kill, then we don't care.
	if ((inEvent.sourceType ~= COMBAT_UNIT_TYPE_PLAYER) and (inEvent.sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET)) then return end

	-- Record & announce kill or killing blow

	-- Grab the opponent or create it from the name
	local opponent = Killz.GetOpponent(inEvent.targetName, true)

	if opponent.name ~= inEvent.targetName then opponent.name = inEvent.targetName end
	
	if inEvent.abilityName == "" then inEvent.abilityName = nil end
	
	-- If we had a death streak going, it has ended
	Killz.settings.sessionStats.longDeathStreak = Killz.settings.sessionStats.longDeathStreak or 0
	if Killz.settings.sessionStats.deathStreak > Killz.settings.sessionStats.longDeathStreak then
		Killz.settings.sessionStats.longDeathStreak = Killz.settings.sessionStats.deathStreak
	end
	Killz.settings.sessionStats.deathStreak = 0

	-- Assume it's a kill not a killing blow
	local key = "WAS_KILL"
	
	if inEvent.abilityName == nil then 

		-- We got a kill event without an ability, so an opponent released after dying
		--
		-- They could either be a KB we already counted or an opponent that we damaged but
		-- another group member killed.
		--
		-- If they are in our KB table already then we remove them to not double count the kill.
		
		if recentKBs[opponent.name] ~= nil then
			recentKBs[opponent.name] = nil
			return -- done, so we don't double count the kill
		end

		-- They are NOT in our KB table, so they are an opponent we did damage to but
		-- didn't get the actual killing blow on, so any killing blow streak has ended.
		
		recentKBs.count = 0
		killingBlowStreakEnded() 

	else 
	
		-- The player actually got the killing blow on an opponent, 
		-- so count it as a KB and a kill both so we don't need to send
		-- two notices to the console.
	
		key = "WAS_KILLING_BLOW"

		-- Add the KB to the KB table we keep.
		recentKBs.count = recentKBs.count + 1
		recentKBs[opponent.name] = inEvent.abilityName
		
		-- It was a killing blow, so increment killing blow counts
		Killz.IncrementStat("killingBlows", opponent.name)
		
		-- Also Increment the kills count for the named ability
		Killz.IncrementAbilityStat("kills", inEvent.abilityName)

	end
	
	-- Increment kills count
	Killz.IncrementStat("kills", opponent.name)

	-- Increment our session kill streak
	Killz.settings.sessionStats.killStreak = Killz.settings.sessionStats.killStreak + 1

	-- Announce kill or KB
	inEvent.abilityIcon = GetAbilityIcon(inEvent.abilityId)
	local killStr = Killz.Announce(key, opponent.name, true, inEvent.abilityName, inEvent.abilityIcon, inEvent.targetUnitId)
	
	Killz.CheckMilestones(key, opponent.name, true, inEvent.abilityName, inEvent.abilityIcon, inEvent.targetUnitId)

	Killz.ScoreWindow_Update()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for the fact player's target changed
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.EVENT_RETICLE_TARGET_CHANGED(eventCode, unitTag)

	local unitTagReticle = 'reticleover'
	
	-- If nothing is being targeted, we don't care
	local unitExists = DoesUnitExist(unitTagReticle)
	if unitExists == false then return nil end	
	
	-- We only care if the target is another player's toon
	local reticleOnPlayer = IsUnitPlayer(unitTagReticle)
	if reticleOnPlayer == false then return nil end

	-- This is the name we care about

	local unitName = GetUnitName(unitTagReticle)

	local targetName = zo_strformat("<<1>>", unitName)
		
	local account = GetUnitDisplayName(unitTagReticle)
	
	local targetAlliance = GetUnitAlliance(unitTagReticle) 

	local playerAlliance = GetUnitAlliance('player') 

	-- If they are in the same alliance, were they an opponent?
	
	if targetAlliance == playerAlliance and Killz.settings.opponents[targetName] == nil then return end -- not a former opponent, so we're done
	
	-- Either they are from another alliance coming over to the player's
	-- or else they belong to another alliance. 

	local target = Killz.targets[targetName]
	if target == nil then -- create if doesn't exist
		target = {}
		target.name = targetName
		target.targetInfo = copyDeep(targetInfo)
	end
	
	-- Populate target record
	target.name = targetName
	target.targetInfo = target.targetInfo or {}
	target.targetInfo.account = account or ""
	target.targetInfo.alliance = GetUnitAlliance(unitTagReticle) or 0
	target.targetInfo.class = GetUnitClass(unitTagReticle) or ""
	target.targetInfo.classID = GetUnitClassId(unitTagReticle) or 0
	target.targetInfo.race = GetUnitRace(unitTagReticle) or ""
	target.targetInfo.raceID = GetUnitRaceId(unitTagReticle) or 0
	target.targetInfo.gender = GetUnitGender(unitTagReticle) or 0
	target.targetInfo.level = GetUnitLevel(unitTagReticle) or 0
	target.targetInfo.CP = GetUnitChampionPoints(unitTagReticle) or 0
	target.targetInfo.rank = GetUnitAvARank(unitTagReticle) or 0

	Killz.targets[targetName] = target

	-- Only if this target is an existing opponent
	local opponent = Killz.settings.opponents[targetName]
	
	if opponent ~= nil then 
		opponent.targetInfo = copyDeep(target.targetInfo) 
	end
	
	opponent = Killz.settings.sessionOpponents[targetName]

	if opponent ~= nil then 
		opponent.targetInfo = copyDeep(target.targetInfo) 
	end

end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for event: Avenge Kill
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
  
function Killz.EVENT_AVENGE_KILL(eventCode, avengedCharacterName, killedCharacterName, avengedAccountName, killedAccountName)

	local avengedLink = "%s"
	local killedLink = "%s"
	local killed = zo_strformat("<<1>>", killedCharacterName)

	avengedLink = Colorz.unitIntract:Colorize(avengedLink)
	avengedLink = string.format(avengedLink, ZO_LinkHandler_CreatePlayerLink(zo_strformat("<<1>>", avengedCharacterName)))
	
	killedLink = Colorz.unitIntract:Colorize(killedLink)
	killedLink = string.format(killedLink, ZO_LinkHandler_CreatePlayerLink(killed))
	
	local avengeStr = LCLSTR.AVENGED1
	local avengeStr2 = LCLSTR.AVENGED2
	local avengeStr3 = LCLSTR.AVENGED3

	avengeStr = string.format(Colorz.tangerine:Colorize(avengeStr), avengedLink)
	avengeStr2 = string.format(Colorz.tangerine:Colorize(avengeStr2), avengedAccountName, killedLink)
	avengeStr3 = string.format(Colorz.tangerine:Colorize(avengeStr3), killedAccountName)
	avengeStr = avengeStr..avengeStr2..avengeStr3
	Killz.Msg(avengeStr)

	Killz.IncrementStat("avengeKills", killed) 
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for event: Revenge Kill
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.EVENT_REVENGE_KILL(eventCode, killedCharacterName, killedAccountName)

	local killedLink = "%s"
	local killed = zo_strformat("<<1>>", killedCharacterName)
	 	
	killedLink = Colorz.unitIntract:Colorize(killedLink)
	killedLink = string.format(killedLink, ZO_LinkHandler_CreatePlayerLink(killed))
	
	local revengeStr = LCLSTR.REVENGE1
	local revengeStr2 = LCLSTR.REVENGE2

	revengeStr = string.format(Colorz.tangerine:Colorize(revengeStr), killedLink)
	revengeStr2 = string.format(Colorz.tangerine:Colorize(revengeStr2), killedAccountName)
	revengeStr = revengeStr..revengeStr2
	Killz.Msg(revengeStr)

	Killz.IncrementStat("revengeKills", killed)
end

local function Q_Now(inQ4IC, inWaitInQueue)
	
	local PvPCampaignIDT = {
		CP_ImperialCity = 95,
		NoCP_ImperialCity = 96,
		Blackreach = 101,
		GrayHost = 102,
		RavenWatch = 103,
	}

	local currentCamp = GetCurrentCampaignId()

	inQ4IC = inQ4IC or false
	inWaitInQueue = inWaitInQueue or false

	local function GetCampQWaitTime(inCampaignID)
		if not inCampaignID then inCampaignID = GetAssignedCampaignId() or 0 end
		for campaignIndex = 1, GetNumSelectionCampaigns() do 
			if inCampaignID == GetSelectionCampaignId(campaignIndex) then 
				local waitTime = GetSelectionCampaignQueueWaitTime(campaignIndex)
				-- d(string.format("GetCampQWaitTime found index & wait time for campaignID = %d: waitTime = %d", inCampaignID, waitTime))
				return waitTime
			end
		end
		-- d(string.format("GetCampQWaitTime found no index for campaignID = %d", inCampaignID))
		return 9999
	end

	local function GetLowestQueueWaitTimeCampID(inQ4IC)
		local currentCamp = GetCurrentCampaignId()
		local lowCampID = 0
		local lowCampQTime = 999999
		inQ4IC = inQ4IC or false
		for campaignIndex = 1, GetNumSelectionCampaigns() do 
			local campID = GetSelectionCampaignId(campaignIndex)
			if campID ~= currentCamp then
				local qTime = GetSelectionCampaignQueueWaitTime(campaignIndex)
				if IsImperialCityCampaign(campID) == inQ4IC and DoesPlayerMeetCampaignRequirements(campID) == true then
					if qTime <= 5 then return campID end -- No queue, go there
					if qTime < lowCampQTime then
						lowCampID = campID
						lowCampQTime = qTime
					end
				end
			end
		end

		return lowCampID
	end

	-- Pick a campaign to where we will bitch port. 
	-- Go to their home campaign unless there is a wait time.
	-- If the home camp has a wait, go to camp with lowest or no wait time.

	local campaignID = GetAssignedCampaignId() or PvPCampaignIDT.RavenWatch -- Homed campaign or No Proc No CP b/c it rarely has a queue

	-- if inQ4IC == false then
		if inWaitInQueue == false then
			local waitTimeSecs = GetCampQWaitTime(campaignID)
			if waitTimeSecs > 3 then campaignID = GetLowestQueueWaitTimeCampID(inQ4IC) end
		end
	-- else 
	-- 	campaignID = PvPCampaignIDT.CP_ImperialCity 
	-- end -- Queue for CP IC by default if going into IC

	local queueAsGroup = false
	if GetExpectedGroupQueueResult() == QUEUE_FOR_CAMPAIGN_RESULT_SUCCESS then
		Killz.settings.telvarSaverQAsGroup = Killz.settings.telvarSaverQAsGroup or false
		queueAsGroup = Killz.settings.telvarSaverQAsGroup
	end
	
	if IsQueuedForCampaign(campaignID, queueAsGroup) then return end
	Killz.Msg(string.format("Killz: Queueing for %s.", GetCampaignName(campaignID)))
	QueueForCampaign(campaignID, queueAsGroup) 
	
end

function Killz.Q4ICOrCyro()
	local q4IC = false
	if IsInCyrodiil() == false then q4IC = true end
	Q_Now(q4IC, false)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for event: Telvar Update
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- Returns alliance of Imperial City base that player is standing in, or ALLIANCE_NONE if not inside a base
local function PlayerIsInWhichICBase()

	-- The only way to figure this out was to use raw world position coordinates
	-- and figure out a rough rule of thumb for each base. This should work
	-- 99% of the time. It may not be right if the player is right up against
	-- the outside of the top door on the platform just outside the base.

	local zoneId, worldX, worldY, worldZ = GetUnitRawWorldPosition('player')

	if zoneId == 643 and worldX >= 163000 and worldX <= 180000 and worldY > 11000 then 
		-- d("Player is INSIDE the EP base!")
		return ALLIANCE_EBONHEART_PACT
	end
	if zoneId == 643 and worldX >= 259000 and worldY >= 12660 then 
		-- d("Player is INSIDE the AD base!") 
		return ALLIANCE_ALDMERI_DOMINION
	end
	if zoneId == 643 and worldX <= 10970 and worldY >= 13189 then 
		-- d("Player is INSIDE the DC base!")
		return ALLIANCE_DAGGERFALL_COVENANT
	end

	return ALLIANCE_NONE
end

function Killz.EVENT_CURRENCY_UPDATE(eventCode, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)

	-- All we care about is if the player gains or loses telvar stones from a kill, loot or death in IC
	
	-- We only care about currency events inside Imperial City
	if not IsInImperialCity() then return end 

	-- If inside an IC base, we don't care about this currency event
	if PlayerIsInWhichICBase() ~= ALLIANCE_NONE then return end 

	-- If the currency event isn't for telvar gained or lost by
	-- the player through combat or looting a mob, we don't care
	-- about the currency event.
	if currencyType ~= CURT_TELVAR_STONES then return end
	if currencyLocation ~= CURRENCY_LOCATION_CHARACTER then return end
	if reason ~= CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER and reason ~= CURRENCY_CHANGE_REASON_LOOT then return end

	-- Did the player gain or lose telvar?
	local str = LCLSTR.GAINED_TELVAR
	local amount = newAmount - oldAmount
	if amount < 0 then
		str = LCLSTR.LOST_TELVAR
		amount = amount * -1
	end

	-- Put the gain or loss because of a kill or death into the combat log
	if reason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER and Killz.settings.showTelvarGained == true then 
		str = Colorz.telvar:Colorize(string.format(str, amount))
		Killz.Msg(str, 550)
	end

	-- Killz.settings.telvarSaver == 0 means never bitch port
	if not Killz.settings.telvarSaver or Killz.settings.telvarSaver < 1 then return end 
	-- Check to see if we are at the bitch port cap
	if newAmount < Killz.settings.telvarSaver then return end 
	-- We are at or above the bitch port amount, so queue out like a little bitch
	Q_Now() 
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Event Handler for event: AP Update
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.EVENT_ALLIANCE_POINT_UPDATE(eventCode, -- number
											alliancePoints, -- number
											playSound, -- boolean
											difference, -- number
											reason)	-- CurrencyChangeReason
	
	-- There are messages we get that we need to ignore
	if reason == CURRENCY_CHANGE_REASON_BANK_DEPOSIT then return
	elseif reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL then return
	elseif reason == CURRENCY_CHANGE_REASON_VENDOR then return end

	-- if difference < 0 then ignore, in case we missed some message we need to ignore.

	if difference < 0 then return end

  -- Update the session and lifetime AP
	Killz.settings.sessionStats.alliancePoints = Killz.settings.sessionStats.alliancePoints or 0
	Killz.settings.sessionStats.alliancePoints = Killz.settings.sessionStats.alliancePoints + difference

	Killz.settings.lifetimeStats.alliancePoints = Killz.settings.lifetimeStats.alliancePoints or 0
	Killz.settings.lifetimeStats.alliancePoints = Killz.settings.lifetimeStats.alliancePoints + difference
	
	-- Update the status window with the new AP value
	Killz.ScoreWindow_Update()

	if Killz.settings.showAPGained == true then -- This can be spammy, so only add it to the Killz chat tab
		addKillzTabMsg(Colorz.alliancePts:Colorize(string.format(LCLSTR.GAINED_AP, difference)), 550)
	end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
	-- Player Menu
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.pvpStatsFor(inPlayerName, inSessionOnly)

	local opponent = nil
	local statsStr = nil

	if inSessionOnly == true then 
		statsStr = LCLSTR.SESSION_STATS
		opponent = Killz.settings.sessionOpponents[inPlayerName]
	else 
		statsStr = LCLSTR.LIFETIME_STATS
		opponent = Killz.settings.opponents[inPlayerName] 
	end

	if not opponent then 
		return string.format("No %s available for '%s'", statsStr, inPlayerName), opponent
	end

	return string.format("%s '%s': Kills: %d Deaths: %d Killing Blows: %d", statsStr, inPlayerName, opponent.kills, opponent.deaths, opponent.killingBlows), opponent
end

function Killz.pvpStatsForAccount(inAccountName, inSessionOnly)

	local opponent = nil
	local statsStr = nil

	if inSessionOnly == true then 
		statsStr = LCLSTR.SESSION_STATS
		opponent = Killz.settings.sessionOpponents[inPlayerName]
	else 
		statsStr = LCLSTR.LIFETIME_STATS
		opponent = Killz.settings.opponents[inPlayerName] 
	end

	if not opponent then 
		return string.format("No %s available for '%s'", statsStr, inPlayerName), opponent
	end

	return string.format("%s '%s': Kills: %d Deaths: %d Killing Blows: %d", statsStr, inPlayerName, opponent.kills, opponent.deaths, opponent.killingBlows), opponent
end

function Killz.ShowPlayerContextMenu(...)

	currChat, currPlayerName, currRawName = ...

	-- We call through the original player context menu function so it populates the menu
	local returnVal = ZO_ShowPlayerContextMenu(...)

	local entries = {
		{
			label = LCLSTR.SESSION_STATS,
			callback = function() 
				local statsStr, opponent = Killz.pvpStatsFor(currPlayerName, true)
				if opponent then
					CHAT_SYSTEM.textEntry:Open(statsStr)
					ZO_ChatWindowTextEntryEditBox:SelectAll()
				else
					Killz.Msg(statsStr) 
				end
			end,
		},
		{
			label = LCLSTR.LIFETIME_STATS,
			callback = function() 
				local statsStr, opponent = Killz.pvpStatsFor(currPlayerName)
				if opponent then
					CHAT_SYSTEM.textEntry:Open(statsStr)
					ZO_ChatWindowTextEntryEditBox:SelectAll()
				else
					Killz.Msg(statsStr)
				end
			end,
			-- disabled = function(rootMenu, childControl) return true end,
		},
		{
			label = LCLSTR.ALL_TOONS_FOR_ACCOUNT,
			callback = function() Killz.WhoIsThisByName(currPlayerName) end,
		},
	}

	AddCustomSubMenuItem(Killz.name, entries)
	ShowMenu(currChat)
	return returnVal
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Settings Panel
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function Killz.CreateSettingsPanel()

	local panelData = {
		type = "panel",
		slashCommand = "/kzprefs",
		name = Killz.name,
		displayName = Killz.displayName,
		author = Killz.author,
		version = Killz.version,
		website = Killz.website,
		donation = Killz.donation,
		registerForRefresh = true
	}

	local LAM2 = LibAddonMenu2

	local optionsData = {}

	local function AddControl(type, data)
		data.type = type
		optionsData[#optionsData + 1] = data
	end

	local function AddHeader(data) AddControl("header", data) end
	local function AddIconPicker(data) AddControl("iconpicker", data) end
	local function AddSlider(data) AddControl("slider", data) end
	local function AddColorPicker(data) AddControl("colorpicker", data) end
	local function AddCheckbox(data) AddControl("checkbox", data) end
	local function AddDescription(data) AddControl("description", data) end
	local function AddDropdown(data) AddControl("dropdown", data) end
	local function AddDivider(data) AddControl("divider", data) end
	local function AddListBox(data) AddControl("orderlistbox", data) end

	AddDivider({ name = "", })

	AddCheckbox({
		name = LCLSTR.ACCTWIDE_NAME,
		tooltip = LCLSTR.ACCTWIDE_TOOLTIP,
		-- warning = LCLSTR.WARNING_RELOADUI,
		-- requiresReload = true, 
		default = true,
		getFunc = function() return Killz.settings.accountWide end,
		setFunc = function(newValue) 
			Killz.accountSettings.accountWide = newValue
			if newValue == true then
				Killz.settings = Killz.accountSettings
			else
				Killz.charSettings = ZO_SavedVars:NewCharacterIdSettings(Killz.SavedVariablesName, Killz.savedVarsVersion, nil, defaults, GetWorldName())
				Killz.charSettings.accountWide = false
				-- LibSavedVars:DeepSavedVarsCopy(Killz.accountSettings, Killz.charSettings)
				Killz.settings = Killz.charSettings
			end
		end,
	})
	
	AddHeader({ name = LCLSTR.STATS_BAR_HEADER })
	AddSlider({
		name = LCLSTR.SCALE_SLIDER_NAME,
		tooltip = LCLSTR.SCALE_SLIDER_TOOLTIP,
		min = -40,
		max = 40,
		default = 0,
		getFunc = function() 
			return Killz.settings.scoreWindowScale
		end,
		setFunc = function(value)
			Killz.settings.scoreWindowScale = value
			Killz.ScoreWindow_Scale()
		end,
	})
	AddCheckbox({
		name = LCLSTR.LOCK_CHECKBOX_NAME,
		tooltip = LCLSTR.LOCK_CHECKBOX_TOOLTIP,
		default = false,
		getFunc = function() return Killz.settings.statsBarLocked end,
		setFunc = function(newValue) 
			Killz.settings.statsBarLocked = newValue
			KillzScoreWindow:SetMovable(not(Killz.settings.statsBarLocked))
		end,
	})
	AddCheckbox({
		name = LCLSTR.HIDE_IN_COMBAT_CHECKBOX_NAME,
		tooltip = LCLSTR.HIDE_IN_COMBAT_CHECKBOX_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.hideInCombat end,
		setFunc = function(newValue) Killz.settings.hideInCombat = newValue end,
	})
	AddCheckbox({
		name = LCLSTR.HIDE_IN_PVE_CHECKBOX_NAME,
		tooltip = LCLSTR.HIDE_IN_PVE_CHECKBOX_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.hideInPvE end,
		setFunc = function(newValue) 
			Killz.settings.hideInPvE = newValue 
			Killz.ScoreWindow_Update()
		end,
	})
	AddCheckbox({
		name = LCLSTR.COUNT_PVP_DEATHS_ONLY_NAME,
		tooltip = LCLSTR.COUNT_PVP_DEATHS_ONLY_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.pvpDeathsOnly end,
		setFunc = function(newValue) Killz.settings.pvpDeathsOnly = newValue end,
	})
	AddCheckbox({
		name = LCLSTR.RESET_ONLY_ON_LOG_OR_QUIT_NAME,
		tooltip = LCLSTR.RESET_ONLY_ON_LOG_OR_QUIT_TOOLTIP,
		default = false,
		getFunc = function() return Killz.settings.resetOnlyOnLogOrQuit or false end,
		setFunc = function(newValue) Killz.settings.resetOnlyOnLogOrQuit = newValue end,
	})
	AddCheckbox({
		name = LCLSTR.SHOW_SESSION_TIME_NAME,
		tooltip = LCLSTR.SHOW_SESSION_TIME_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.reportTimeBasedStats end,
		setFunc = 	function(newValue) 
			Killz.settings.reportTimeBasedStats = newValue
		end,
		width = "full",	--or "half" (optional)
	})

	AddHeader({ name = LCLSTR.ANNOUNCEMENTS_HEADER })
	AddCheckbox({
		name = LCLSTR.ANNOUNCE_KILLING_BLOWS_NAME,
		tooltip = LCLSTR.ANNOUNCE_KILLING_BLOWS_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.announceKBs end,
		setFunc = function(newValue) Killz.settings.announceKBs = newValue end,
    width = "half",	--or "full" (optional)
	})
	AddColorPicker({
		name = " ",
		tooltip = LCLSTR.ANNOUNCE_KILLING_BLOWS_COLORPICKERTIP,
		getFunc = function() return Killz.kbColor:UnpackRGBA() end,
		setFunc = function(...)
			Killz.kbColor:SetRGBA(...)
			Killz.settings.kbColor = Killz.kbColor:ToHex()
		end,
		width = "half",	--or "full" (optional)
	})
	AddCheckbox({
		name = LCLSTR.ANNOUNCE_DEATHS_NAME,
		tooltip = LCLSTR.ANNOUNCE_DEATHS_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.announceDeaths end,
		setFunc = function(newValue) Killz.settings.announceDeaths = newValue end,
		width = "half",	--or "full" (optional)
	})
	AddColorPicker({
		name = " ",
		tooltip = LCLSTR.ANNOUNCE_DEATHS_COLORPICKERTIP,
		getFunc = function() return Killz.deathColor:UnpackRGBA() end,
		setFunc = function(...)
			Killz.deathColor:SetRGBA(...)
			Killz.settings.deathColor = Killz.deathColor:ToHex()
		end,
		width = "half",	--or "full" (optional)
	})
	AddCheckbox({
		name = LCLSTR.ANNOUNCE_KILLS_NAME,
		tooltip = LCLSTR.ANNOUNCE_KILLS_TOOLTIP,
		default = false,
		getFunc = function() return Killz.settings.announceKills end,
		setFunc = function(newValue) Killz.settings.announceKills = newValue end,
		width = "half",	--or "full" (optional)
	})
	AddColorPicker({
		name = " ",
		tooltip = LCLSTR.ANNOUNCE_KILLS_COLORPICKERTIP,
		getFunc = function() return Killz.killColor:UnpackRGBA() end,
		setFunc = function(...)
			Killz.killColor:SetRGBA(...)
			Killz.settings.killColor = Killz.killColor:ToHex()
		end,
		width = "half",	--or "full" (optional)
	})
	AddDescription({
		title = nil,	--(optional)
		text = " ",
		width = "full",	--or "half" (optional)
	})
	AddCheckbox({
		name = LCLSTR.ANNOUNCE_MILESTONES_NAME,
		tooltip = LCLSTR.ANNOUNCE_MILESTONES_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.announceMilestones end,
		setFunc = function(newValue) Killz.settings.announceMilestones = newValue end,
		width = "full",	--or "half" (optional)
	})
	AddCheckbox({
		name = LCLSTR.ADD_ACCOUNT_NAME,
		tooltip = LCLSTR.ADD_ACCOUNT_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.addAcctToAnn end,
		setFunc = function(newValue) Killz.settings.addAcctToAnn = newValue end,
		width = "full",	--or "half" (optional)
	})
	AddCheckbox({
		name = LCLSTR.PLAY_ANNOUNCE_SOUNDS_NAME,
		tooltip = LCLSTR.PLAY_ANNOUNCE_SOUNDS_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.playAnnounceSounds end,
		setFunc = function(newValue) Killz.settings.playAnnounceSounds = newValue end,
    width = "full",	--or "half" (optional)
	})

	AddHeader({ name = LCLSTR.KILLZ_TAB_HEADER })
	AddCheckbox({
		name = LCLSTR.ADD_KILLZ_TAB_NAME,
		tooltip = LCLSTR.ADD_KILLZ_TAB_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.killzChatTab end,
		setFunc = 	function(newValue) 
			Killz.settings.killzChatTab = newValue
			Killz.ToggleChatTab()
		end,
		width = "full",	--or "half" (optional)
	})

	AddCheckbox({
		name = LCLSTR.ADD_PVP_KILL_FEED_TO_LOG_NAME,
		tooltip = LCLSTR.ADD_PVP_KILL_FEED_TO_LOG_TOOLTIP,
		default = true,
		getFunc = function() return Killz.settings.addPvPKillFeed end,
		setFunc = 	function(newValue) Killz.settings.addPvPKillFeed = newValue end,
		width = "full",	--or "half" (optional)
		disabled = function() return (not Killz.settings.killzChatTab) end,
	})
	AddCheckbox({
		name = LCLSTR.ADD_PVP_KILL_FEED_TO_MAIN_NAME,
		tooltip = LCLSTR.ADD_PVP_KILL_FEED_TO_MAIN_TOOLTIP,
		default = false,
		getFunc = function() return Killz.settings.addPvPKillFeedToMain end,
		setFunc = 	function(newValue) Killz.settings.addPvPKillFeedToMain = newValue end,
		width = "full",	--or "half" (optional)
		disabled = function() return (not Killz.settings.killzChatTab or not Killz.settings.addPvPKillFeed) end,
	})
	AddCheckbox({
		name = LCLSTR.SHOW_AP_GAINED_NAME,
		tooltip = LCLSTR.SHOW_AP_GAINED_TOOLTIP,
		default = false,
		getFunc = function() return Killz.settings.showAPGained end,
		setFunc = function(newValue) Killz.settings.showAPGained = newValue end,
		width = "full",	--or "half" (optional)
		disabled = function() return (not Killz.settings.killzChatTab) end,

	})
	AddCheckbox({
		name = LCLSTR.SHOW_TELVAR_GAINED_NAME,
		tooltip = LCLSTR.SHOW_TELVAR_GAINED_TOOLTIP,
		default = false,
		getFunc = function() return Killz.settings.showTelvarGained end,
		setFunc = function(newValue) Killz.settings.showTelvarGained = newValue end,
		width = "full",	--or "half" (optional)
		disabled = function() return (not Killz.settings.killzChatTab) end,

	})
	AddCheckbox({
		name = LCLSTR.SHOW_MOB_KILLS_NAME,
		tooltip = LCLSTR.SHOW_MOB_KILLS_TOOLTIP,
		default = false,
		getFunc = function() return Killz.settings.showMobKills end,
		setFunc = function(newValue) Killz.settings.showMobKills = newValue end,
		width = "full",	--or "half" (optional)
		disabled = function() return (not Killz.settings.killzChatTab) end,
	})
	AddCheckbox({
		name = LCLSTR.SHOW_COMBAT_LOG_NAME,
		tooltip = LCLSTR.SHOW_COMBAT_LOG_TOOLTIP,
		default = false,
		getFunc = function() return Killz.settings.doCombatLog end,
		setFunc = function(newValue) Killz.settings.doCombatLog = newValue end,
		width = "full",	--or "half" (optional)
		disabled = function() return (not Killz.settings.killzChatTab) end,

	})
	AddHeader({ name = LCLSTR.TELVAR_HEADER })

	AddSlider({
		min = 0,
		max = 250000,
		default = 0,
		name = LCLSTR.TELVAR_SAVER_NAME,
		tooltip = LCLSTR.TELVAR_SAVER_TOOLTIP,
		getFunc = function() return Killz.settings.telvarSaver end,
		setFunc = function(newValue) Killz.settings.telvarSaver = newValue end,
	})

	AddCheckbox({
		name = LCLSTR.TELVAR_SAVER_GROUPQ_NAME,
		tooltip = LCLSTR.TELVAR_SAVER_GROUPQ_TOOLTIP,
		default = false,
		getFunc = function() return Killz.settings.telvarSaverQAsGroup end,
		setFunc = function(newValue) Killz.settings.telvarSaverQAsGroup = newValue end,
		width = "full",	--or "half" (optional)
		disabled = function() return (not Killz.settings.telvarSaver or Killz.settings.telvarSaver == 0) end,
	})

	Killz.panel = LAM2:RegisterAddonPanel("Killz_Settings_Panel", panelData)
	LAM2:RegisterOptionControls("Killz_Settings_Panel", optionsData)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- A D D O N   E N T R Y   P O I N T
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- It all starts here actually, by registering our event handler to load our Addon
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

EVENT_MANAGER:RegisterForEvent(	Killz.name, EVENT_ADD_ON_LOADED, Killz.EVENT_ADD_ON_LOADED)