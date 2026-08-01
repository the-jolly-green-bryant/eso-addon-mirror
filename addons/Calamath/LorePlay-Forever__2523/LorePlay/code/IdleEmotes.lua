local LorePlay = LorePlay or {}

-- --- definitions : local event codes for LibEventHandler
local EVENT_ACTIVE_EMOTE = "EVENT_ACTIVE_EMOTE"
local EVENT_ON_IDLE_EMOTE = "EVENT_ON_IDLE_EMOTE"
-- --- definitions : LPUtilities.lua
local LPUtilities = LorePlay.LPUtilities

-- ------------------------------------------------------------

-- === IdleEmotes.lua ===

local IdleEmotes = LorePlay

local isPlayerStealthed
local currentPlayerX, currentPlayerY
local emoteFromEvent
local defaultIdleTable
local eventIdleTable
local didIdleEmote = false
local isActiveEmoting = false
local isFastTraveling = false

-- idle emotes table definitions
local idleEmotesTable = {}
idleEmotesTable["Zone"] = {
    99,     -- /sit                     Sit ground
    119,    -- /sit2                    Sit ground 2
    120,    -- /sit3                    Sit ground 3
    121,    -- /sit4                    Sit ground 4
    123,    -- /sit6                    Sit ground 6
    102,    -- /kneel                   Kneel
    200,    -- /drink3                  Drinking from bottle
    15,     -- /armscrossed             Arms crossed
    10,     -- /read                    Read book
    38,     -- /handsonhips             Hands on hips
    190,    -- /idle2                   Idle royalty
}
idleEmotesTable["City"] = {
    201,    -- /eat4                    Eat from bowl
    107,    -- /prov                    Stir Bowl
    194,    -- /juggleflame             Juggle flame
    8,      -- /drink                   Drinking from flagon
    173,    -- /drink2                  Drinking from chalice
    100,    -- /sitchair                Sit chair
    38,     -- /handsonhips             Hands on hips
    168,    -- /eat                     Eat turkey
    9,      -- /eat2                    Eat bread quickly
    190,    -- /idle2                   Idle royalty
    198,    -- /idle5                   Idle heroic
}
idleEmotesTable["Dungeon"] = {
    194,    -- /juggleflame             Juggle flame
    1,      -- /torch                   Set fire with torch
    153,    -- /impatient               Impatient
    1,      -- /torch                   Set fire with torch
    1,      -- /torch                   Set fire with torch
    122,    -- /sit5                    Sit ground 5
    101,    -- /crouch                  Crouch
}
idleEmotesTable["Housing"] = {
    10,     -- /read                    Read book
    10,     -- /read                    Read book
    99,     -- /sit                     Sit ground
    119,    -- /sit2                    Sit ground 2
    191,    -- /rake                    Rake
    191,    -- /rake                    Rake
    192,    -- /sweep                   Sweeping
    192,    -- /sweep                   Sweeping
    9,      -- /eat2                    Eat bread quickly
    177,    -- /eat3                    Eat apple
    207,    -- /pie                     Eat pie
    208,    -- /soupbowl                Eat soup
    125,    -- /write                   Write
    125,    -- /write                   Write
    118,    -- /sleep2                  Sleep back
    116,    -- /sleep                   Sleep side
}

idleEmotesTable["Drunk"] = {
    8,      -- /drink                   Drinking from flagon
    8,      -- /drink                   Drinking from flagon
    139,    -- /drunk                   Drunk
    139,    -- /drunk                   Drunk
    162,    -- /faint                   Faint
    162,    -- /faint                   Faint
    79,     -- /dancedrunk              Dance drunk
    79,     -- /dancedrunk              Dance drunk
    115,    -- /playdead                Play dead
    153,    -- /impatient               Impatient
}
idleEmotesTable["Worship"] = {
    104,    -- /kneelpray               Kneel praying
    52,     -- /pray                    Pray
    171,    -- /blessing                Blessing
}
idleEmotesTable["Exercise"] = {
    84,     -- /jumpingjacks            Jumping jacks
    85,     -- /pushups                 Push-ups strong
    113,    -- /situps                  Situps
}
idleEmotesTable["Dance"] = {
    72,     -- /dance                   Dance
    189,    -- /danceredguard           Dance Redguard
    181,    -- /dancealtmer             Dance Altmer
    182,    -- /danceargonian           Dance Argonian
    183,    -- /dancebosmer             Dance Bosmer
    180,    -- /dancebreton             Dance Breton
    206,    -- /dancedarkelf            Dance Dark Elf
    185,    -- /danceimperial           Dance Imperial
    186,    -- /dancekhajiit            Dance Khajiit
    187,    -- /dancenord               Dance Nord
    188,    -- /danceorc                Dance Orc
}
idleEmotesTable["Instruments"] = {
    5,      -- /lute                    Play lute
    6,      -- /flute                   Play flute
    7,      -- /drum                    Play drum
}
LPEmotesTable.idleEmotesTable = idleEmotesTable



function IdleEmotes.CreateEventIdleEmotesTable()
	eventIdleTable = {
		["isEnabled"] = false,
		[EVENT_TRADE_INVITE_ACCEPTED] = {
			[1] = 76,
			[2] = 35,
			[3] = 19,
			[4] = 36,
			[5] = 50,
			[6] = 41,
			[7] = 152,
			[8] = 15,
			[9] = 153,
		}
	}
end

function IdleEmotes.CreateDefaultIdleEmotesTable()
	defaultIdleTable = {}
	defaultIdleTable["Zone"] = ZO_ShallowNumericallyIndexedTableCopy(idleEmotesTable["Zone"])
	defaultIdleTable["City"] = ZO_ShallowNumericallyIndexedTableCopy(idleEmotesTable["City"])
	defaultIdleTable["Dungeon"] = ZO_ShallowNumericallyIndexedTableCopy(idleEmotesTable["Dungeon"])
	defaultIdleTable["Housing"] = ZO_ShallowNumericallyIndexedTableCopy(idleEmotesTable["Housing"])

	if LorePlay.db.canPlayInstrumentsInCities then
		ZO_CombineNumericallyIndexedTables(defaultIdleTable["City"], idleEmotesTable["Instruments"])	-- AddInstrumentsToCities()
	end
	if LorePlay.db.canDanceInCities then
		ZO_CombineNumericallyIndexedTables(defaultIdleTable["City"], idleEmotesTable["Dance"])	-- AddDancesToCities()
	end
	if LorePlay.db.canExerciseInZone then
		ZO_CombineNumericallyIndexedTables(defaultIdleTable["Zone"], idleEmotesTable["Exercise"])	-- AddExercisesToZone()
	end
	if LorePlay.db.canWorship then
		ZO_CombineNumericallyIndexedTables(defaultIdleTable["Zone"], idleEmotesTable["Worship"])	-- AddWorshipToZone()
		ZO_CombineNumericallyIndexedTables(defaultIdleTable["City"], idleEmotesTable["Worship"])	-- AddWorshipToCities()
		ZO_CombineNumericallyIndexedTables(defaultIdleTable["Dungeon"], idleEmotesTable["Worship"])	-- AddWorshipToDungeons()
	end
	if LorePlay.db.canBeDrunkInCities then
		ZO_CombineNumericallyIndexedTables(defaultIdleTable["City"], idleEmotesTable["Drunk"])	-- AddDrunkToCities()
	end
end


function IdleEmotes.GetLocation()
	if LorePlay.IsPlayerInHouse() then
		return "Housing"
	elseif LorePlay.IsPlayerInDungeon() then
		return "Dungeon"
	elseif LorePlay.IsPlayerInDolmen() then
		return "Dungeon"		-- use dungeon table for dolmen
	elseif LorePlay.IsPlayerInAbyssalGeyser() then
		return "Dungeon"		-- use dungeon table for AbyssalGeyser
	elseif LorePlay.IsPlayerInHarrowstormRitualSite() then
		return "Dungeon"		-- use dungeon table for HarrowstormRitualSite
	elseif LorePlay.IsPlayerInMirrormoorMosaic() then
		return "Dungeon"		-- use dungeon table for MirrormoorMosaic
	elseif LorePlay.IsPlayerInCity() then
		return "City"
	elseif LorePlay.IsPlayerInParentZone() then
		return "Zone"
	else
		return "Dungeon"		-- unregistered region case
	end
end


function IdleEmotes.PerformIdleEmote()
	if IsPlayerMoving() then return end
	local randomEmote
	local currIdleEmote
	if eventIdleTable["isEnabled"] then
		randomEmote = math.random(#emoteFromEvent)
		currIdleEmote = emoteFromEvent[randomEmote]
	else
		local location = IdleEmotes.GetLocation()
		randomEmote = math.random(#defaultIdleTable[location])
		currIdleEmote = defaultIdleTable[location][randomEmote]
	end
	LPEventHandler:FireEvent(EVENT_ON_IDLE_EMOTE, false, true, currIdleEmote)
	PlayEmoteByIndex(currIdleEmote)
	didIdleEmote = true
	EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.db.timeBetweenIdleEmotes, IdleEmotes.CheckToPerformIdleEmote)
end


function IdleEmotes.UpdateEmoteFromEvent(eventCode)
	emoteFromEvent = eventIdleTable[eventCode]
	if not eventIdleTable["isEnabled"] then
		eventIdleTable["isEnabled"] = true
	end
end


function IdleEmotes.UpdateStealthState(eventCode, unitTag, stealthState)
	if unitTag ~= "player" then return end
	if stealthState ~= STEALTH_STATE_NONE then
		isPlayerStealthed = true
	else
		isPlayerStealthed = false
	end
end


function IdleEmotes.IsCharacterIdle()
	if IsMounted() or isFastTraveling or IsUnitSwimming("player") or IsBlockActive() or not ArePlayerWeaponsSheathed() or IsUnitDeadOrReincarnating("player") then return end
	if not isActiveEmoting then
		local didMove = IdleEmotes.UpdateIfMoved() 
		if not didMove then
			if isPlayerStealthed == nil then
				IdleEmotes.UpdateStealthState(EVENT_STEALTH_STATE_CHANGED, "player", GetUnitStealthState("player"))
			end
			if not isPlayerStealthed then
				local interactionType = GetInteractionType()
  				if interactionType == INTERACTION_NONE then
					return true
				end
			end
		end
	end
	return false
end


local housingEditorScenes = {
	housingEditorHud = true, 
	housingEditorHudUI = true, 
}
function IdleEmotes.IsBlacklistedScene()
	local currentScene = SCENE_MANAGER:GetCurrentScene()
	if currentScene == nil then
--		LorePlay.LDL:Debug("[SCENE]IdleEmoteNG : currentScene = nil (not initialized yet)"
		return true
	end
	local currentSceneName = currentScene:GetName()
	if not LorePlay.adb.ieAllowedInHousingEditor and housingEditorScenes[currentSceneName] then
--		LorePlay.LDL:Debug("[SCENE]IdleEmoteNG : currentScene = %s", currentSceneName)
		return true
	end
	if currentScene:HasFragment(FRAME_PLAYER_FRAGMENT) then
--		LorePlay.LDL:Debug("[SCENE]IdleEmoteNG : detect FRAME_PLAYER_FRAGMENT")
		return true
	end
	return false
end

function IdleEmotes.CheckToPerformIdleEmote()
	if IdleEmotes.IsCharacterIdle() and not IdleEmotes.IsBlacklistedScene() then
		IdleEmotes.PerformIdleEmote()
	end
end


-- Used to check if player has moved in between IdleEmotes to allow for faster detection
function IdleEmotes.UpdateIfMoved()
	local x, y, didMove = LPUtilities.DidPlayerMove(currentPlayerX, currentPlayerY)
	if didMove then
		currentPlayerX = x
		currentPlayerY = y
		if didIdleEmote then
			didIdleEmote = false
		end
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
		EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime , IdleEmotes.CheckToPerformIdleEmote)
	end
	return didMove
end


function IdleEmotes.OnTradeEvent_For_EVENT_TRADE_INVITE_ACCEPTED(eventCode)
	if eventCode ~= EVENT_TRADE_INVITE_ACCEPTED then return end
	IdleEmotes.UpdateEmoteFromEvent(eventCode)
end


function IdleEmotes.OnTradeEvent_For_TRADE_CESSATION(eventCode)
	if emoteFromEvent == eventIdleTable[EVENT_TRADE_INVITE_ACCEPTED] then
		eventIdleTable["isEnabled"] = false
	end
end


function IdleEmotes.OnPlayerCombatStateEvent(eventCode, inCombat)
	if not inCombat then
		if LorePlay.db.isIdleEmotesOn then
			EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
		end
	else
		if LorePlay.db.isIdleEmotesOn then
			EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
		end
	end
end


function IdleEmotes.OnMountedEvent(eventCode, mounted)
	if not mounted then
		if LorePlay.db.isIdleEmotesOn then
			EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
		end
	else
		if LorePlay.db.isIdleEmotesOn then
			EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
		end
	end
end


function IdleEmotes.OnChatterEvent(eventCode)
	if eventCode == EVENT_CHATTER_BEGIN then
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	else
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
		EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
	end
end


local function OnActiveEmote(eventCode, isEmotingNow)
	if eventCode ~= EVENT_ACTIVE_EMOTE then return end
	if isEmotingNow then
		isActiveEmoting = true
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	else
		isActiveEmoting = false
		if not IsMounted() then
			EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
		end
	end
end


local function OnFastTravelInteraction(eventCode)
	if eventCode == EVENT_START_FAST_TRAVEL_INTERACTION then
		isFastTraveling = true
	else
		isFastTraveling = false
	end
end


function IdleEmotes.OnCraftingStationInteract(eventCode)
	if eventCode == EVENT_CRAFTING_STATION_INTERACT then
		EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	elseif eventCode == EVENT_END_CRAFTING_STATION_INTERACT then
		EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
	end
end


local function OnHousingEditorModeChanged(eventCode, oldMode, newMode)
	if oldMode == HOUSING_EDITOR_MODE_DISABLED then
		if not LorePlay.adb.ieAllowedInHousingEditor then
			if didIdleEmote then
				-- Stop performing the IdleEmotes.
				PlayEmoteByIndex(GetEmoteIndex(267))	-- "/idle"
			end
		end
	end
end


function IdleEmotes.UnregisterIdleEvents()
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_MOUNTED_STATE_CHANGED, IdleEmotes.OnMountedEvent)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_PLAYER_COMBAT_STATE, IdleEmotes.OnPlayerCombatStateEvent)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_STEALTH_STATE_CHANGED, IdleEmotes.UpdateStealthState)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_CHATTER_BEGIN, IdleEmotes.OnChatterEvent)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_CHATTER_END, IdleEmotes.OnChatterEvent)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_TRADE_INVITE_ACCEPTED, IdleEmotes.OnTradeEvent_For_EVENT_TRADE_INVITE_ACCEPTED)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_TRADE_SUCCEEDED, IdleEmotes.OnTradeEvent_For_TRADE_CESSATION)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_TRADE_CANCELED, IdleEmotes.OnTradeEvent_For_TRADE_CESSATION)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_CRAFTING_STATION_INTERACT, IdleEmotes.OnCraftingStationInteract)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_END_CRAFTING_STATION_INTERACT, IdleEmotes.OnCraftingStationInteract)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_END_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_START_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)
	LPEventHandler:UnregisterForEvent(LorePlay.name, EVENT_HOUSING_EDITOR_MODE_CHANGED, OnHousingEditorModeChanged)
	LPEventHandler:UnregisterForLocalEvent(EVENT_ACTIVE_EMOTE, OnActiveEmote)
	EVENT_MANAGER:UnregisterForUpdate("IdleEmotes")
	EVENT_MANAGER:UnregisterForUpdate("IdleEmotesMoveTimer")
end


function IdleEmotes.RegisterIdleEvents()
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_MOUNTED_STATE_CHANGED, IdleEmotes.OnMountedEvent)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_PLAYER_COMBAT_STATE, IdleEmotes.OnPlayerCombatStateEvent)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_STEALTH_STATE_CHANGED, IdleEmotes.UpdateStealthState)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_CHATTER_BEGIN, IdleEmotes.OnChatterEvent)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_CHATTER_END, IdleEmotes.OnChatterEvent)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_TRADE_INVITE_ACCEPTED, IdleEmotes.OnTradeEvent_For_EVENT_TRADE_INVITE_ACCEPTED)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_TRADE_SUCCEEDED, IdleEmotes.OnTradeEvent_For_TRADE_CESSATION)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_TRADE_CANCELED, IdleEmotes.OnTradeEvent_For_TRADE_CESSATION)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_CRAFTING_STATION_INTERACT, IdleEmotes.OnCraftingStationInteract)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_END_CRAFTING_STATION_INTERACT, IdleEmotes.OnCraftingStationInteract)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_END_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_START_FAST_TRAVEL_INTERACTION, OnFastTravelInteraction)
	LPEventHandler:RegisterForEvent(LorePlay.name, EVENT_HOUSING_EDITOR_MODE_CHANGED, OnHousingEditorModeChanged)
	LPEventHandler:RegisterForLocalEvent(EVENT_ACTIVE_EMOTE, OnActiveEmote)
	EVENT_MANAGER:RegisterForUpdate("IdleEmotes", LorePlay.adb.ieIdleTime, IdleEmotes.CheckToPerformIdleEmote)
	EVENT_MANAGER:RegisterForUpdate("IdleEmotesMoveTimer", 10000, IdleEmotes.UpdateIfMoved)
end


function IdleEmotes.InitializeIdle()
	if not LorePlay.db.isIdleEmotesOn then return end
	IdleEmotes.CreateDefaultIdleEmotesTable()
	IdleEmotes.CreateEventIdleEmotesTable()
	currentPlayerX, currentPlayerY = GetMapPlayerPosition("player")
	IdleEmotes.RegisterIdleEvents()
end
