BSCCompainionInfo = BSCCompainionInfo or {}
local BSCCOIN = BSCCompainionInfo

local RapportUpIco	= [[/BSCs-CompainionInfo/icon/rapport_up.dds]]
local RapportDownIco = [[/BSCs-CompainionInfo/icon/rapport_down.dds]]

local bDebug = false

-- Milliseconds of the last Rapport Update
local RAPPORT_GAIN_TIME = 0

-- Types To Define Cooldown of the rapport
local RAPPORT_TYPE_BOOK = 0				-- 15 Mins (Bati)			Rapport: 1
local RAPPORT_TYPE_COOKING = 1			-- 5 Mins					Rapport: 1
local RAPPORT_TYPE_ANTIQUITY_SCRY = 2	-- Only Bastion (5 Mins)	Rapport: 5
local RAPPORT_TYPE_ANTIQUITY_DIGG = 3	-- Only Mirri	(5 Mins)	Rapport: 5
local RAPPORT_TYPE_QUEST = 4			-- 5 Mins 					Rapport: 125
local RAPPORT_TYPE_PSYJIK_PORTAL = 5	-- 5 Mins 					Rapport: 5
local RAPPORT_TYPE_ZONE_PORTING = 6		-- 20 Hours					Rapport: 10		(Mirri Deadric dungeon 30 mins)
local RAPPORT_TYPE_STEALING = 7

-- RAPPORT_TIME_INFO[CompanionID][RAPPORT_TYPE] = time
local RAPPORT_TIME_INFO = { }
-- Bastion
RAPPORT_TIME_INFO[1] = { }

-- Mirri
RAPPORT_TIME_INFO[1] = { }

-- Quest ID's
local DARK_ANCHROS = { } 
-- Warrior Guild
DARK_ANCHROS[5784] = true
DARK_ANCHROS[5785] = true
DARK_ANCHROS[5786] = true
DARK_ANCHROS[5787] = true
DARK_ANCHROS[5788] = true
DARK_ANCHROS[5789] = true
DARK_ANCHROS[5790] = true
DARK_ANCHROS[5791] = true
DARK_ANCHROS[5792] = true
DARK_ANCHROS[5793] = true
DARK_ANCHROS[5794] = true
DARK_ANCHROS[5795] = true
DARK_ANCHROS[5796] = true
DARK_ANCHROS[5797] = true
DARK_ANCHROS[5833] = true

local MADNESS = { } 
-- Mage Guild
MADNESS[5814] = true
MADNESS[5816] = true
MADNESS[5818] = true
MADNESS[5819] = true
MADNESS[5820] = true
MADNESS[5822] = true
MADNESS[5823] = true
MADNESS[5824] = true
MADNESS[5825] = true
MADNESS[5826] = true
MADNESS[5827] = true
MADNESS[5828] = true
MADNESS[5829] = true
MADNESS[5830] = true
MADNESS[5831] = true

-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
local function CompareTimersForRapport(CompareTime, RapportType)	
	local timediff = -1
	if RAPPORT_GAIN_TIME > CompareTime then
		timediff = RAPPORT_GAIN_TIME - CompareTime
	end	
	if CompareTime > RAPPORT_GAIN_TIME then
		timediff = CompareTime - RAPPORT_GAIN_TIME
	end	
	if timediff ~= -1 and timediff < 250 then -- 100ms should be enough to check
		d(zo_strformat('Rapport Gain from Type[<<1>>] TimeDiff[<<2>>]', RapportType, timediff))
	end
end

-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
--/script d(zo_strformat("RapportInfo: [<<1>>] Current[<<4>>] (<<2>>/<<3>>)", GetCompanionName(GetActiveCompanionDefId()), GetMinimumRapport(), GetMaximumRapport(), GetActiveCompanionRapport()))
local function OnRapportUpdate(event, companionId, previousRapport, currentRapport)
	if not HasActiveCompanion() then return end	
	
	if BSCCOIN.SV.PRINT_RAPPORT_CHAT then
		local gain = currentRapport - previousRapport
		local rdIcon = (currentRapport > previousRapport) and RapportUpIco or RapportDownIco
		local CompainionName = zo_strformat('# <<1>>: ', GetCompanionName(companionId)).."|t18:18:"..rdIcon.."|t"
		local RappGain = ""
		if (currentRapport > previousRapport) then
			RappGain = zo_strformat('+<<1>> ', gain)
		else
			RappGain = zo_strformat('<<1>> ', gain)
		end
		local RapportNumber = zo_strformat(' (<<1>>/<<2>>)', BSCCOIN:FormatNumer(currentRapport), BSCCOIN:FormatNumer(BSCCOIN.RAPPORT_MAX))
		
		d(CompainionName..RappGain..RapportNumber)
		if BSCCOIN.RAPPOER_LEVEL ~= GetActiveCompanionRapportLevel() then
			BSCCOIN.RAPPOER_LEVEL = GetActiveCompanionRapportLevel()
			d(zo_strformat('RapportInfo: <<1>> is level (<<2>>/<<3>>) [<<4>>]', GetCompanionName(companionId), BSCCOIN.RAPPOER_LEVEL, 7, GetActiveCompanionRapportLevelDescription(BSCCOIN.RAPPOER_LEVEL)))
		end
	end
	
	if bDebug then d("Rapport Info MS["..GetGameTimeMilliseconds().."]") end
	RAPPORT_GAIN_TIME = GetGameTimeMilliseconds()	
end

-------------------------------------------------------------------------------------------------
-- Digging Gives Miri 5 Points
-------------------------------------------------------------------------------------------------
local function AntiquityDGO(_, gameOverFlags)
	if gameOverFlags == ANTIQUITY_DIGGING_GAME_OVER_FLAGS_VICTORY then
		local timeNow = GetGameTimeMilliseconds()
		if bDebug then d("ANTIQUITY_DIGGING_GAME_OVER_FLAGS_VICTORY MS["..timeNow.."]") end		
		zo_callLater(function() CompareTimersForRapport(timeNow, RAPPORT_TYPE_ANTIQUITY_DIGG) end, 100)
	end
end
-------------------------------------------------------------------------------------------------
-- Scrying Gives Bastion 5 Points
-------------------------------------------------------------------------------------------------
local function AntiquitySR(_, result)
	if result == ANTIQUITY_SCRYING_RESULT_SUCCESS and not IsScryingInProgress() then
		local timeNow = GetGameTimeMilliseconds()
		if bDebug then d("ANTIQUITY_SCRYING_RESULT_SUCCESS MS["..timeNow.."]") end
		zo_callLater(function() CompareTimersForRapport(timeNow, RAPPORT_TYPE_ANTIQUITY_SCRY) end, 100)
	end
end
-------------------------------------------------------------------------------------------------
-- Book don know anything else from there
-------------------------------------------------------------------------------------------------
local function InteractionEnded(_, interactType, cancelContext)
	if interactType == INTERACTION_BOOK then
		local timeNow = GetGameTimeMilliseconds()
		zo_callLater(function() CompareTimersForRapport(timeNow, RAPPORT_TYPE_BOOK) end, 100)
	else
		--d("EVENT_INTERACTION_ENDED ["..interactType.."] ["..cancelContext.."]")
	end	
end

-------------------------------------------------------------------------------------------------
--  EVENT_ZONE_CHANGED (*string* _zoneName_, *string* _subZoneName_, *bool* _newSubzone_, *integer* _zoneId_, *integer* _subZoneId_)
-------------------------------------------------------------------------------------------------
local function OnZoneChanged(_, zoneName, subZoneName, newSubzone, zoneId, subZoneId)	
	if newSubzone then	
		d(zo_strformat('zoneName[<<1>>] subZoneName[<<2>>] zoneId[<<3>>] subZoneId[<<4>>]', zoneName, subZoneName, zoneId, subZoneId))
	end
end
local function OnPlayerActivated()
	local zoneId  = GetUnitWorldPosition("player") 
	d(zo_strformat('zoneName[<<1>>] zoneId[<<2>>]', GetZoneNameById(zoneId), zoneId))	
	-- [11:16:55] zoneName[die Klingenohrgrotte] zoneId[409] (Mirri) 
	-- [12:22:43] zoneId[409] # Mirri Elendis: +10  (4.219/5.500)
	-- [17:15:59] zoneId[291] # Mirri Elendis: +10  (4.244/5.500)
end

-------------------------------------------------------------------------------------------------
-- EVENT_QUEST_COMPLETE (*string* _questName_, *integer* _level_, *integer* _previousExperience_, *integer* _currentExperience_, *integer* _championPoints_, *[QuestType|#QuestType]* _questType_, *[InstanceDisplayType|#InstanceDisplayType]* _instanceDisplayType_)
-------------------------------------------------------------------------------------------------
local function OnQuestCompleted(_, questName)
	local CompletedQuestName = zo_strformat(SI_QUEST_JOURNAL_QUEST_NAME_FORMAT, questName)
	local countQ = 0
	-- loop all completed quests from character
	local questId = GetNextCompletedQuestId()	
	while questId ~= nil do
		local qName = GetCompletedQuestInfo(questId)
		--
		countQ = countQ + 1	
	
		if CompletedQuestName == zo_strformat(SI_QUEST_JOURNAL_QUEST_NAME_FORMAT, qName) then			
			--lastquestID = questId			
			if DARK_ANCHROS[questId] ~= nil then
				d(questId)
			end
			if MADNESS[questId] ~= nil then
				d(questId)
			end			
		end		
		--
		questId = GetNextCompletedQuestId(questId)
	end
end

-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------
function BSCCOIN:InitRapport()

	local Name = BSCCOIN.Name.."RAPPORT"
	EVENT_MANAGER:RegisterForEvent(Name, EVENT_COMPANION_RAPPORT_UPDATE, OnRapportUpdate)
	
	if not bDebug then return end
	
	-- Antiquity
	EVENT_MANAGER:RegisterForEvent(Name, EVENT_ANTIQUITY_DIGGING_GAME_OVER, AntiquityDGO)
	EVENT_MANAGER:RegisterForEvent(Name, EVENT_ANTIQUITY_SCRYING_RESULT, AntiquitySR)
	-- InterActionEdnded (Book)
	EVENT_MANAGER:RegisterForEvent(Name, EVENT_INTERACTION_ENDED, InteractionEnded)
	-- Porting to other zone or subzone 
	EVENT_MANAGER:RegisterForEvent(Name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(Name, EVENT_ZONE_CHANGED, OnZoneChanged)
	-- Quest
	EVENT_MANAGER:RegisterForEvent(Name, EVENT_QUEST_COMPLETE, OnQuestCompleted)
		
	-- ProgressReason
	
	-- MsgInteractType
	
	--EVENT_CONFIRM_INTERACT (*string* _dialogTitle_, *string* _dialogBody_, *string* _acceptText_, *string* _cancelText_)
	--EVENT_MANAGER:RegisterForEvent(Name, EVENT_CONFIRM_INTERACT, 
	--function(_, dialogTitle, dialogBody, acceptText, cancelText) 
	--	d("EVENT_CONFIRM_INTERACT ["..dialogTitle.."] ["..dialogBody.."] ["..acceptText.."] ["..cancelText.."]") 
	--end)
	
	local lastLootTargetName = ""
	EVENT_MANAGER:RegisterForEvent(Name, EVENT_LOOT_UPDATED, 
	function(...) 		
        local name, targetType, actionName, isOwned = GetLootTargetInfo()		
		if name == "" then return end
		-- Bugs and stealing on start
		
		lastLootTargetName = name
		d(zo_strformat('EVENT_LOOT_UPDATED name[<<1>>] targetType[<<2>>] actionName[<<3>>] isOwned[<<4>>]', name, targetType, actionName, isOwned))
	end)
	
	EVENT_MANAGER:RegisterForEvent(Name, EVENT_LOOT_CLOSED, 
	function(...)
		-- Psijik is on the end
		
		lastLootTargetName = "" -- Clear target Name again
	end)
	
end

-- INTERACTION_ANTIQUITY_DIG_SPOT
-- INTERACTION_ANTIQUITY_SCRYING
-- INTERACTION_ATTRIBUTE_RESPEC
-- INTERACTION_AVA_HOOK_POINT
-- INTERACTION_BANK
-- INTERACTION_BOOK
-- INTERACTION_BUY_BAG_SPACE
-- INTERACTION_COMPANION_MENU
-- INTERACTION_CONVERSATION
-- INTERACTION_CRAFT
-- INTERACTION_DYE_STATION
-- INTERACTION_FAST_TRAVEL
-- INTERACTION_FAST_TRAVEL_KEEP
-- INTERACTION_FISH
-- INTERACTION_FURNITURE
-- INTERACTION_GUILDBANK
-- INTERACTION_GUILDKIOSK_BID
-- INTERACTION_GUILDKIOSK_PURCHASE
-- INTERACTION_HARVEST
-- INTERACTION_HIDEYHOLE
-- INTERACTION_KEEP_GUILD_CLAIM
-- INTERACTION_KEEP_GUILD_RELEASE
-- INTERACTION_KEEP_INSPECT
-- INTERACTION_KEEP_PIECE
-- INTERACTION_LOCKPICK
-- INTERACTION_LOOT
-- INTERACTION_MAIL
-- INTERACTION_NONE
-- INTERACTION_PAY_BOUNTY
-- INTERACTION_PICKPOCKET
-- INTERACTION_QUEST
-- INTERACTION_RETRAIT
-- INTERACTION_SIEGE
-- INTERACTION_SKILL_RESPEC
-- INTERACTION_STABLE
-- INTERACTION_STONE_MASON
-- INTERACTION_STORE
-- INTERACTION_TRADINGHOUSE
-- INTERACTION_TREASURE_MAP
-- INTERACTION_VENDOR

