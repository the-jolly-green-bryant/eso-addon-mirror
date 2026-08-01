-- Locals
local MT = MudcrabTracker
local clientLang = GetCVar("language.2")
local cumulativeScore = 0
local cumulativeCrabs = 0

local playerRanks = {
	["en"] = {
		{ threshold = 0, rank = "Mudcrab Enthusiast" },
		{ threshold = 10, rank = "Mudcrab Wrangler" },
		{ threshold = 100, rank = "Mudcrab Hunter" },
		{ threshold = 250, rank = "Mudcrab Exterminator" },
		{ threshold = 500, rank = "Mudcrab Slayer" },
		{ threshold = 1000, rank = "Mudcrab Vanquisher" },
		{ threshold = 2500, rank = "Mudcrab Conqueror" },
		{ threshold = 5000, rank = "Mudcrab Champion" },
		{ threshold = 10000, rank = "Mudcrab Legend" },
		{ threshold = 100000, rank = "Mudcrab Lord" },
		{ threshold = 1000000, rank = "Mudcrab Deity" },
	},
	["de"] = {
		{ threshold = 0, rank = "Schlammkrabben-Enthusiast" },
		{ threshold = 10, rank = "Schlammkrabben-Hüter" },
		{ threshold = 100, rank = "Schlammkrabben-Jäger" },
		{ threshold = 250, rank = "Schlammkrabben-Ausrotter" },
		{ threshold = 500, rank = "Schlammkrabben-Schlächter" },
		{ threshold = 1000, rank = "Schlammkrabben-Besieger" },
		{ threshold = 2500, rank = "Schlammkrabben-Eroberer" },
		{ threshold = 5000, rank = "Schlammkrabben-Champion" },
		{ threshold = 10000, rank = "Schlammkrabben-Legende" },
		{ threshold = 100000, rank = "Schlammkrabben-Lord" },
		{ threshold = 1000000, rank = "Schlammkrabben-Gottheit" },
	},
	["ru"] = {
		{ threshold = 0, rank = "Любитель Грязекрабов" },
		{ threshold = 10, rank = "Укротитель Грязекрабов" },
		{ threshold = 100, rank = "Охотник на Грязекрабов" },
		{ threshold = 250, rank = "Истребитель Грязекрабов" },
		{ threshold = 500, rank = "Убийца Грязекрабов" },
		{ threshold = 1000, rank = "Победитель Грязекрабов" },
		{ threshold = 2500, rank = "Завоеватель Грязекрабов" },
		{ threshold = 5000, rank = "Чемпион Грязекрабов" },
		{ threshold = 10000, rank = "Легенда Грязекрабов" },
		{ threshold = 100000, rank = "Властелин Грязекрабов" },
		{ threshold = 1000000, rank = "Грязекрабий Бог" },
	},
}
local ranksOfClientLang = playerRanks[clientLang]
local lastPlayerRank = ""

local localizedStrings = {
	["en"] = {
		MUDCRAB_TRACKER_LABEL = "Crab score: %s",
		MUDCRAB_TRACKER_RANK = "Rank: %s",
		CHAT_MESSAGE_MUDCRAB_KILLED = "You killed |cAAAAFF%s|r. Total crab score: |cAAAAFF%s|r",
		CHAT_MESSAGE_BOSS_KILLED = "At last. The shores are free from this terror you call... |cAAAAFF%s|r. You earned |cAAAAFF%s|r points! Total crab score: |cAAAAFF%s|r",
		CHAT_MESSAGE_TRACKER_TOGGLE_ON = "Mudcrab Tracker is now visible.",
		CHAT_MESSAGE_TRACKER_TOGGLE_OFF = "Mudcrab Tracker is now hidden.",
		CHAT_MESSAGE_CRABSTAT = "Crab score: |cAAAAFF%s|r. You are a |cAAAAFF%s|r!",
		CHAT_MESSAGE_MULTIPLE_CRABS_KILLED = "You killed |cAAAAFF%s|r crabs, good job! Total crab score: |cAAAAFF%s|r",
		CHAT_MESSAGE_CRABS_TO_CHAT = "[MudcrabTracker] My crab score is: %s. I'm a %s!",
		CHAT_MESSAGE_NEW_RANK = "You have attained a new crab rank. You are now |cAAAAFF%s|r!",
		CHAT_MESSAGE_NEXT_RANK = "Crab score needed for next rank: |cAAAAFF%s|r",
	},
	["de"] = {
		MUDCRAB_TRACKER_LABEL = "Krabbenscore: %s",
		MUDCRAB_TRACKER_RANK = "Rang: %s",
		CHAT_MESSAGE_MUDCRAB_KILLED = "Du hast |cAAAAFF%s|r getötet. Krabbenscore: |cAAAAFF%s|r",
		CHAT_MESSAGE_BOSS_KILLED = "Endlich. Die Ufer sind frei von diesen Schrecken, die ihr ... |cAAAAFF%s|r nennt. Du hast |cAAAAFF%s|r Punkte erhalten! Krabbenscore: |cAAAAFF%s|r",
		CHAT_MESSAGE_TRACKER_TOGGLE_ON = "Mudcrab Tracker ist jetzt sichtbar.",
		CHAT_MESSAGE_TRACKER_TOGGLE_OFF = "Mudcrab Tracker ist jetzt versteckt.",
		CHAT_MESSAGE_CRABSTAT = "Krabbenscore: |cAAAAFF%s|r. Du bist ein |cAAAAFF%s|r!",
		CHAT_MESSAGE_MULTIPLE_CRABS_KILLED = "Du hast |cAAAAFF%s|r Krabben getötet, gut gemacht! Krabbenscore: |cAAAAFF%s|r",
		CHAT_MESSAGE_CRABS_TO_CHAT = "[MudcrabTracker] Mein Krabbenscore ist: %s. Ich bin ein %s!",
		CHAT_MESSAGE_NEW_RANK = "Du hast einen neuen Krabbenrang erreicht. Du bist jetzt |cAAAAFF%s|r!",
		CHAT_MESSAGE_NEXT_RANK = "Krabbenscore für den nächsten Rang benötigt: |cAAAAFF%s|r",
	},
	["ru"] = {
		MUDCRAB_TRACKER_LABEL = "Очки крабов: %s",
		MUDCRAB_TRACKER_RANK = "Звание: %s",
		CHAT_MESSAGE_MUDCRAB_KILLED = "|cAAAAFF%s|r убит. Очки крабов: |cAAAAFF%s|r",
		CHAT_MESSAGE_BOSS_KILLED = "Наконец этот берег свободен от напасти, имя которой... |cAAAAFF%s|r. Вы заработали |cAAAAFF%s|r очков! Очки крабов: |cAAAAFF%s|r",
		CHAT_MESSAGE_TRACKER_TOGGLE_ON = "Трекер грязекрабов теперь виден.",
		CHAT_MESSAGE_TRACKER_TOGGLE_OFF = "Трекер грязекрабов теперь скрыт.",
		CHAT_MESSAGE_CRABSTAT = "Очки крабов: |cAAAAFF%s|r. Вы |cAAAAFF%s|r!",
		CHAT_MESSAGE_MULTIPLE_CRABS_KILLED = "Вы убили |cAAAAFF%s|r крабов, хорошая работа! Очки крабов: |cAAAAFF%s|r",
		CHAT_MESSAGE_CRABS_TO_CHAT = "[MudcrabTracker] Мои очки крабов: %s. Я %s!",
		CHAT_MESSAGE_NEW_RANK = "Вы получили новое крабозвание. Вы теперь |cAAAAFF%s|r!",
		CHAT_MESSAGE_NEXT_RANK = "Для следующего крабозвания нужно набрать |cAAAAFF%s|r очков крабов.",
	},
}
local L = localizedStrings[clientLang] or localizedStrings["en"]

local crabNames = {
	-- English
	["en"] = {
		["Mudcrab"] = 1, -- the regular one
		["Coral Crab"] = 1, -- Summerset and High Isle mudcrab
		["Hermit Crab"] = 1, -- High Isle critter
		["Swarming Mudcrab"] = 1, -- Fungal Grotto trash mob
		["Clatterclaw"] = 15, -- Fungal Grotto boss
		["Grotto Mudcrab Swarmer Minions"] = 1, -- Fungal Grotto boss minions
		["Queen of the Reef"] = 15, -- Summerset boss
		["Coral Mudcrab"] = 1, -- Summerset boss minions
		["Mud Crab"] = 1, -- Solstice temple
		["Gravelclaw"] = 1, -- Craglorn
		["Colossal Coral Crab"] = 5, -- Solstice elite
		["Colossal Mudcrab"] = 5, -- Solstice elite
		["Tidespite"] = 15, -- Solstice boss
		["Shellcracker"] = 15, -- Stonefalls boss
		["Blue Sandcrab"] = 1, -- Shallcracker minions
		["Mother Jagged-Claw"] = 5, -- Vvardenfell ashlander daily elite
	},
	-- German
	["de"] = {
		["Schlammkrabbe"] = 1,
		["Korallenkrabbe"] = 1,
		["Einsiedlerkrabbe"] = 1,
		["Schwärmende Schlammkrabbe"] = 1,
		["Klapperschere"] = 15,
		["Schwärmende Schlammkrabben"] = 1,
		["Die Königin des Riffs"] = 15,
		-- ["Korallenkrabbe"] = 1,
		-- ["Schlammkrabbe"] = 1,
		["Schotterkralle"] = 1,
		["Kolossale Korallenkrabbe"] = 5,
		["Kolossale Schlammkrabbe"] = 5,
		["Gezeitentücke"] = 15,
		["Schalenknacker"] = 15,
		["Blaue Sandkrabbe"] = 1,
		["Mutter Zackige-Klaue"] = 5,
	},
	-- Russian
	["ru"] = {
		["Грязевой краб"] = 1,
		["Коралловый краб"] = 1,
		["Краб-отшельник"] = 1,
		["Грязевой краб из стаи"] = 1,
		["Щелкун"] = 15,
		["Помощники из стаи грязевого краба грота"] = 1,
		["Королева Рифа"] = 15,
		["Коралловый грязевой краб"] = 1,
		-- ["Грязевой краб"] = 1,
		["Гравийный краб"] = 1,
		["Огромный коралловый краб"] = 5,
		["Огромный грязекраб"] = 5,
		["Злоба Прилива"] = 15,
		["Крушитель Панцирей"] = 15,
		["Синий песчаный краб"] = 1,
		["Зазубренная Клешня"] = 5,
	},
}
local crabsOfClientLang = crabNames[clientLang]
if crabsOfClientLang == nil then
	-- exit if language is unsupported
	return
end

local DEFAULT_CRABS_LABEL_LEFT = 10
local DEFAULT_CRABS_LABEL_TOP = 30
local defaults = {
	counter = 0,
	killstat = nil,
	crabKillstat = {},
	counterEnabled = false,
	counterPosition = {
		left = DEFAULT_CRABS_LABEL_LEFT,
		top = DEFAULT_CRABS_LABEL_TOP,
	},
	lootedItems = {},
	lootLoggerEnabled = false,
}

-- Functions

MudcrabTracker.print = function(msg)
	CHAT_SYSTEM:AddMessage(msg)
end

local function getPlayerRankForScore(score)
	local rank = ""
	for _, r in ipairs(ranksOfClientLang) do
		if score >= r.threshold then
			rank = r.rank
		else
			break
		end
	end
	return rank
end

local function getRequiredScoreForNextRank(currentScore)
	local requiredScore = nil
	for _, r in ipairs(ranksOfClientLang) do
		if r.threshold > currentScore then
			if requiredScore == nil or r.threshold < requiredScore then
				requiredScore = r.threshold
			end
		end
	end
	return requiredScore
end

local function updateLabel()
	if MT.db == nil then
		return
	end
	if not MudcrabTrackerIndicator or MudcrabTrackerIndicator:IsHidden() then
		return
	end

	MudcrabTrackerIndicatorLabel:SetText(string.format(L.MUDCRAB_TRACKER_LABEL, MT.db.counter))
	MudcrabTrackerIndicatorRankLabel:SetText(
		string.format(L.MUDCRAB_TRACKER_RANK, getPlayerRankForScore(MT.db.counter))
	)
end

local function updateCrabKillstat(targetName)
	if MT.db == nil then
		return
	end
	if MT.db.crabKillstat[targetName] ~= nil then
		MT.db.crabKillstat[targetName] = MT.db.crabKillstat[targetName] + 1
	else
		MT.db.crabKillstat[targetName] = 1
	end
end

local function onCrabKilled(targetName, score)
	updateCrabKillstat(targetName)
	cumulativeScore = cumulativeScore + score
	cumulativeCrabs = cumulativeCrabs + 1

	EVENT_MANAGER:RegisterForUpdate(MudcrabTracker.ADDON_NAME .. "CrabKillDebounce", 5000, function()
		if MT.db == nil then
			return
		end
		EVENT_MANAGER:UnregisterForUpdate(MudcrabTracker.ADDON_NAME .. "CrabKillDebounce")
		local isFirstKill = MT.db.counter == 0
		MT.db.counter = MT.db.counter + cumulativeScore
		if cumulativeCrabs == 1 then
			if cumulativeScore == 1 then
				MudcrabTracker.print(string.format(L.CHAT_MESSAGE_MUDCRAB_KILLED, targetName, tostring(MT.db.counter)))
			else
				MudcrabTracker.print(
					string.format(L.CHAT_MESSAGE_BOSS_KILLED, targetName, tostring(score), tostring(MT.db.counter))
				)
			end
		else
			MudcrabTracker.print(
				string.format(L.CHAT_MESSAGE_MULTIPLE_CRABS_KILLED, tostring(cumulativeCrabs), tostring(MT.db.counter))
			)
		end
		local newPlayerRank = getPlayerRankForScore(MT.db.counter)
		if newPlayerRank ~= lastPlayerRank or isFirstKill then
			lastPlayerRank = newPlayerRank
			MudcrabTracker.print(string.format(L.CHAT_MESSAGE_NEW_RANK, newPlayerRank))
			local nextRankScore = getRequiredScoreForNextRank(MT.db.counter)
			if nextRankScore ~= nil and nextRankScore > MT.db.counter then
				MudcrabTracker.print(string.format(L.CHAT_MESSAGE_NEXT_RANK, tostring(nextRankScore)))
			end
		end
		cumulativeScore = 0
		cumulativeCrabs = 0
		updateLabel()
	end)
end

local function onCombatEvent(
	_eventCode_,
	result,
	_isError_,
	_abilityName_,
	_abilityGraphic_,
	_abilityActionSlotType_,
	_sourceName_,
	_sourceType_,
	targetName,
	_targetType_,
	_hitValue_,
	_powerType_,
	_damageType_,
	_log_,
	_sourceUnitId_,
	_targetUnitId_,
	_abilityId_,
	_overflow_
)
	if not targetName or targetName == "" then
		return
	end

	local trimmedTargetName = ZO_CachedStrFormat("<<C:1>>", targetName)
	local score = crabsOfClientLang[trimmedTargetName]
	if score == nil then
		return
	end

	onCrabKilled(trimmedTargetName, score)
end

local function restoreIndicatorPosition()
	if MT.db == nil then
		return
	end
	if MT.db.counterPosition == nil then
		MT.db.counterPosition = {
			left = MudcrabTracker.DEFAULT_CRABS_LABEL_LEFT,
			top = MudcrabTracker.DEFAULT_CRABS_LABEL_TOP,
		}
	end
	local left = MT.db.counterPosition.left
	local top = MT.db.counterPosition.top

	MudcrabTrackerIndicator:ClearAnchors()
	MudcrabTrackerIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function toggleIndicatorOnSceneChange(currentScene)
	if MT.db == nil then
		return
	end
	if not MT.db.counterEnabled then
		return
	end

	if currentScene == SCENE_SHOWING then
		MudcrabTrackerIndicator:SetHidden(false)
	else
		MudcrabTrackerIndicator:SetHidden(true)
	end
end

local function crabStatToChat()
	if MT.db == nil then
		return
	end
	local statString =
		string.format(L.CHAT_MESSAGE_CRABS_TO_CHAT, tostring(MT.db.counter), getPlayerRankForScore(MT.db.counter))
	CHAT_SYSTEM.textEntry.editControl:InsertText(statString)
end

local function resetCrabScore()
	if MT.db == nil then
		return
	end
	MT.db.counter = 0
	MT.db.crabKillstat = {}
	updateLabel()
end

local function doCrabsDbMigrations(db)
	-- ensure crabKillstat exists
	if db.crabKillstat == nil then
		db.crabKillstat = {}
	end

	-- migrate old killstat to crabKillstat
	if db.killstat ~= nil then
		for k, v in pairs(db.killstat) do
			if crabsOfClientLang[k] ~= nil then
				db.crabKillstat[k] = v
			end
		end
	end
	-- killstat is deprecated, so erase it to not waste space
	db.killstat = nil
end

local function onAddOnLoaded(_, addonName)
	if addonName ~= MudcrabTracker.ADDON_NAME then
		return
	end

	MT.db = ZO_SavedVars:NewAccountWide("MudcrabTracker_db", "0.0.1", nil, defaults)
	if MT.db == nil then
		return
	end

	doCrabsDbMigrations(MT.db)
	lastPlayerRank = getPlayerRankForScore(MT.db.counter)

	updateLabel()
	restoreIndicatorPosition()
	if MT.db.counterEnabled then
		MudcrabTrackerIndicator:SetHidden(false)
	else
		MudcrabTrackerIndicator:SetHidden(true)
	end

	--register for events
	-- skip registering for player and player pet because only registering for companion somehow works even if no companion is unlocked
	EVENT_MANAGER:RegisterForEvent(
		MudcrabTracker.ADDON_NAME .. "_combat_companion_died_xp",
		EVENT_COMBAT_EVENT,
		onCombatEvent
	)
	EVENT_MANAGER:AddFilterForEvent(
		MudcrabTracker.ADDON_NAME .. "_combat_companion_died_xp",
		EVENT_COMBAT_EVENT,
		REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
		COMBAT_UNIT_TYPE_COMPANION,
		REGISTER_FILTER_COMBAT_RESULT,
		ACTION_RESULT_DIED_XP
	)
	EVENT_MANAGER:RegisterForEvent(
		MudcrabTracker.ADDON_NAME .. "_combat_companion_died",
		EVENT_COMBAT_EVENT,
		onCombatEvent
	)
	EVENT_MANAGER:AddFilterForEvent(
		MudcrabTracker.ADDON_NAME .. "_combat_companion_died",
		EVENT_COMBAT_EVENT,
		REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
		COMBAT_UNIT_TYPE_COMPANION,
		REGISTER_FILTER_COMBAT_RESULT,
		ACTION_RESULT_DIED
	)

	MudcrabTracker.LootLogger.init()

	SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", toggleIndicatorOnSceneChange)
	SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", toggleIndicatorOnSceneChange)

	-- Slash Commands
	SLASH_COMMANDS["/crabs"] = function()
		if not MT.db then
			return
		end
		MudcrabTracker.print(
			string.format(L.CHAT_MESSAGE_CRABSTAT, tostring(MT.db.counter), getPlayerRankForScore(MT.db.counter))
		)
	end

	SLASH_COMMANDS["/togglecrabs"] = function()
		if not MT.db then
			return
		end
		if MT.db.counterEnabled then
			MudcrabTrackerIndicator:SetHidden(true)
			MT.db.counterEnabled = false
			MudcrabTracker.print(L.CHAT_MESSAGE_TRACKER_TOGGLE_OFF)
		else
			MudcrabTrackerIndicator:SetHidden(false)
			MT.db.counterEnabled = true
			updateLabel()
			MudcrabTracker.print(L.CHAT_MESSAGE_TRACKER_TOGGLE_ON)
		end
	end

	SLASH_COMMANDS["/crabstochat"] = function()
		crabStatToChat()
	end

	SLASH_COMMANDS["/resetcrabs"] = function()
		resetCrabScore()
	end
end

function MudcrabTracker_OnCounterMoveStop()
	if MT.db == nil then
		return
	end
	MT.db.counterPosition.left = MudcrabTrackerIndicator:GetLeft()
	MT.db.counterPosition.top = MudcrabTrackerIndicator:GetTop()
end

EVENT_MANAGER:RegisterForEvent(MudcrabTracker.ADDON_NAME .. "_start", EVENT_ADD_ON_LOADED, onAddOnLoaded)
