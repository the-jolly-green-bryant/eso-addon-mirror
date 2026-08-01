SummonAlly = {
	name = "SummonAlly",
	menuName = "Summon Ally",
	author = "TheMikrobe",
	version = "2.0.0",
	variableVersion = 200,
}

----------------------------------------
-- collectible ids at update 39 (scribes of fate dlc) https://esoitem.uesp.net/viewCollectibles.php?category=Allies
--- companions: Bastian Hallix, 9245; Mirri Elendis, 9353; Ember, 9911; Isobel Veloise, 9912; Sharp-as-Night, 11113; Azandar al-Cybiades, 11114
--- bankers: Tythis Andromo, the Banker, 267; Cassus Andronicus the Mercenary, 397; Ezabi the Banker, 6376; Baron Jangleplume, the Banker, 8994; Factotum Property Steward, 9743; Pyroclast, Infernace Conservator, 11097
--- merchants: Nuzhimeh the Merchant, 301; Allaria Erwen the Exporter, 396; Fezez the Merchant, 6378; Peddler of Prizes, the Merchant, 8995; Factotum Commerce Delegate, 9744; Hoarfrost, Takubar Trader, 11059
--- fences: Pirharri the Smuggler, 300
--- armory assistants: Ghrasharog, Armory Assistant, 9745; Zuqoth, Armory Advisor, 10618
--- deconstruction assistants: Giladil the Ragpicker, 10184; Aderene, Fargrave Dregs Dealer, 10617
----------------------------------------
--to keep up to date:
---new assistants should be detected and added as soon as an account unlocks them; the 'description:find' search terms may need revising if ZOS introduce more inconsistency in collectible descriptions
---new companions should be detected and available for summon functions as soon as a character gains access to them
---to customise settings for new companions they need three variables ([name]Reactions, [name]Passenger, [name]Ultimate), new lines in 'SummonAlly.CompanionSettings()' below, and new table.insert entries in settings
----------------------------------------


SummonAlly.savedVars = {
	accountWide = false,

	alliesTable = {},

	companionIdLastUsed = 0,
	companionPreferred,

	autoCompanionReactions = false,
	bastianReactions = GetString(SI_COMPANIONREACTIONFREQUENCYRATE3),
	mirriReactions = GetString(SI_COMPANIONREACTIONFREQUENCYRATE1),
	emberReactions = GetString(SI_COMPANIONREACTIONFREQUENCYRATE1),
	isobelReactions = GetString(SI_COMPANIONREACTIONFREQUENCYRATE0),
	sharpReactions = GetString(SI_COMPANIONREACTIONFREQUENCYRATE1),
	azandarReactions = GetString(SI_COMPANIONREACTIONFREQUENCYRATE1),

	autoCompanionPassenger = false,
	bastianPassenger = GetString(SI_COMPANIONPASSENGERPREFERENCE0),
	mirriPassenger = GetString(SI_COMPANIONPASSENGERPREFERENCE0),
	emberPassenger = GetString(SI_COMPANIONPASSENGERPREFERENCE0),
	isobelPassenger = GetString(SI_COMPANIONPASSENGERPREFERENCE0),
	sharpPassenger = GetString(SI_COMPANIONPASSENGERPREFERENCE0),
	azandarPassenger = GetString(SI_COMPANIONPASSENGERPREFERENCE0),

	autoCompanionUltimate = false,
	bastianUltimate = true,
	mirriUltimate = true,
	emberUltimate = true,
	isobelUltimate = true,
	sharpUltimate = true,
	azandarUltimate = true,

--	assistantIdLastUsed = 0,
	bankerPreferred,
	merchantPreferred,
	fencePreferred,
	armoryPreferred,
	deconPreferred,
}

--------------------
--custom companion settings
--------------------
function SummonAlly.CompanionSettings()
	local companionReactions
	local companionPassenger
	local companionUltimate

	if (SummonAlly.savedVars.companionIdLastUsed == 9245) then
		companionReactions = SummonAlly.savedVars.bastianReactions
		companionPassenger = SummonAlly.savedVars.bastianPassenger
		companionUltimate = SummonAlly.savedVars.bastianUltimate
	elseif (SummonAlly.savedVars.companionIdLastUsed == 9353) then
		companionReactions = SummonAlly.savedVars.mirriReactions
		companionPassenger = SummonAlly.savedVars.mirriPassenger
		companionUltimate = SummonAlly.savedVars.mirriUltimate
	elseif (SummonAlly.savedVars.companionIdLastUsed == 9911) then
		companionReactions = SummonAlly.savedVars.emberReactions
		companionPassenger = SummonAlly.savedVars.emberPassenger
		companionUltimate = SummonAlly.savedVars.emberUltimate
	elseif (SummonAlly.savedVars.companionIdLastUsed == 9912) then
		companionReactions = SummonAlly.savedVars.isobelReactions
		companionPassenger = SummonAlly.savedVars.isobelPassenger
		companionUltimate = SummonAlly.savedVars.isobelUltimate
	elseif (SummonAlly.savedVars.companionIdLastUsed == 11113) then
		companionReactions = SummonAlly.savedVars.sharpReactions
		companionPassenger = SummonAlly.savedVars.sharpPassenger
		companionUltimate = SummonAlly.savedVars.sharpUltimate
	elseif (SummonAlly.savedVars.companionIdLastUsed == 11114) then
		companionReactions = SummonAlly.savedVars.azandarReactions
		companionPassenger = SummonAlly.savedVars.azandarPassenger
		companionUltimate = SummonAlly.savedVars.azandarUltimate
	end

	if SummonAlly.savedVars.autoCompanionReactions then
		if (companionReactions == GetString(SI_COMPANIONREACTIONFREQUENCYRATE3)) then
			SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_COMPANION_REACTION_FREQUENCY, COMPANION_REACTION_FREQUENCY_RATE_VERY_LOW)
		elseif (companionReactions == GetString(SI_COMPANIONREACTIONFREQUENCYRATE0)) then
			SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_COMPANION_REACTION_FREQUENCY, COMPANION_REACTION_FREQUENCY_RATE_LOW)
		elseif (companionReactions == GetString(SI_COMPANIONREACTIONFREQUENCYRATE1)) then
			SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_COMPANION_REACTION_FREQUENCY, COMPANION_REACTION_FREQUENCY_RATE_NORMAL)
		elseif (companionReactions == GetString(SI_COMPANIONREACTIONFREQUENCYRATE2)) then
			SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_COMPANION_REACTION_FREQUENCY, COMPANION_REACTION_FREQUENCY_RATE_HIGH)
		end
	end

	if SummonAlly.savedVars.autoCompanionPassenger then
		if (companionPassenger == GetString(SI_COMPANIONPASSENGERPREFERENCE0)) then
			SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_COMPANION_PASSENGER_PREFERENCE, COMPANION_PASSENGER_PREFERENCE_ALWAYS)
		elseif (companionPassenger == GetString(SI_COMPANIONPASSENGERPREFERENCE1)) then
			SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_COMPANION_PASSENGER_PREFERENCE, COMPANION_PASSENGER_PREFERENCE_NEVER)
		elseif (companionPassenger == GetString(SI_COMPANIONPASSENGERPREFERENCE2)) then
			SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_COMPANION_PASSENGER_PREFERENCE, COMPANION_PASSENGER_PREFERENCE_WHEN_PLAYER_NOT_GROUPED)
		end
	end

	if SummonAlly.savedVars.autoCompanionUltimate then
		if companionUltimate then
			SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ALLOW_COMPANION_AUTO_ULTIMATE, 1)
		else
			SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_ALLOW_COMPANION_AUTO_ULTIMATE, 0)
		end
	end
end

--------------------
--on activation/deactivation of companion
--------------------
function SummonAlly.CompanionActivated(event, companionId)
	SummonAlly.savedVars.companionIdLastUsed = GetCompanionCollectibleId(companionId)
	SummonAlly.CompanionSettings()
end

--------------------
--summon companion
--------------------
function SummonAlly.SummonCompanionPref()
	companionRevTable = {}
	for i,v in pairs(SummonAlly.savedVars.alliesTable.companionTable) do
		companionRevTable[v] = i
	end
	UseCollectible(companionRevTable[SummonAlly.savedVars.companionPreferred])
end

function SummonAlly.SummonCompanionLastUsed()
	if (SummonAlly.savedVars.companionIdLastUsed > 0) then
		UseCollectible(SummonAlly.savedVars.companionIdLastUsed)
	end	
end

--------------------
--on creation/destruction of assistant
--------------------
--[[	--this function detects if the 'playerpet' unit that was created is an assistant or a combat pet
function SummonAlly.AssistantCreated(event, unitTag)
	local unitReaction = GetUnitReaction(unitTag)				--assistants, 3; combat pets, 5
	if (unitReaction == 3) then
		SummonAlly.savedVars.assistantIdLastUsed = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT)
	end
end
--]]

--[[	--this function detects if the 'playerpet' unit that was destroyed was an assistant or a combat pet
function SummonAlly.AssistantDestroyed(event, unitTag)
--the unitTag data from the EVENT is inconsistent depending on what happened (zone changes, log outs, presence of combat pets, etc.), so check all playerpet units to see if an assistant still exists
	if (SummonAlly.savedVars.assistantIdLastUsed > 0) then			--only do it if an assistant was active before the EVENT triggered
		local assistantSeen = false
		for i = 1, 10 do						--max possible playerpet units is 9 (?) (skeleton, blastbones, ghost, colossus, 3 from sets, undaunted spider, assistant); global MAX_PET_UNIT_TAGS = 7
			if (GetUnitReaction(string.format("%s%s", "playerpet", i)) == 3) then
				assistantSeen = true
				break
			end
		end
		if assistantSeen then
			--assistant still active, therefore it was a pet that was destroyed
			return
		else
			--no assistant active, therefore it was the assistant that was destroyed
			SummonAlly.savedVars.assistantIdLastUsed = 0
			return
		end
	end
end
--]]

--------------------
--summon assistants
--------------------
function SummonAlly.SummonBanker()
	bankerRevTable = {}
	for i,v in pairs(SummonAlly.savedVars.alliesTable.bankerTable) do
		bankerRevTable[v] = i
	end
	UseCollectible(bankerRevTable[SummonAlly.savedVars.bankerPreferred])
end

function SummonAlly.SummonMerchant()
	merchantRevTable = {}
	for i,v in pairs(SummonAlly.savedVars.alliesTable.merchantTable) do
		merchantRevTable[v] = i
	end
	UseCollectible(merchantRevTable[SummonAlly.savedVars.merchantPreferred])
end

function SummonAlly.SummonFence()
	fenceRevTable = {}
	for i,v in pairs(SummonAlly.savedVars.alliesTable.fenceTable) do
		fenceRevTable[v] = i
	end
	UseCollectible(fenceRevTable[SummonAlly.savedVars.fencePreferred])
end

function SummonAlly.SummonArmory()
	armoryRevTable = {}
	for i,v in pairs(SummonAlly.savedVars.alliesTable.armoryTable) do
		armoryRevTable[v] = i
	end
	UseCollectible(armoryRevTable[SummonAlly.savedVars.armoryPreferred])
end

function SummonAlly.SummonDecon()
	deconRevTable = {}
	for i,v in pairs(SummonAlly.savedVars.alliesTable.deconTable) do
		deconRevTable[v] = i
	end
	UseCollectible(deconRevTable[SummonAlly.savedVars.deconPreferred])
end

--------------------
--out of loadscreens
--------------------
function SummonAlly.Activated(event)
	if HasActiveCompanion() then
		SummonAlly.savedVars.companionIdLastUsed = GetCompanionCollectibleId(GetActiveCompanionDefId())
		SummonAlly.CompanionSettings()
	end
end

--detect available allies for settings menu
function SummonAlly.AlliesSetup()
	SummonAlly.savedVars.alliesTable = {
		companionTable = {},
		bankerTable = {},
		merchantTable = {},
		fenceTable = {},
		armoryTable = {},
		deconTable = {},
	}

	local _, numCollectiblesC = GetCollectibleSubCategoryInfo(8, 2)
	for i = 1, numCollectiblesC do
		local collectibleId = GetCollectibleId(8, 2, i)
		local name = GetCollectibleInfo(collectibleId)
		local questState = GetCollectibleAssociatedQuestState(collectibleId)
		if questState == 3 then
			SummonAlly.savedVars.alliesTable.companionTable[collectibleId] = name
			SummonAlly.savedVars.companionPreferred = SummonAlly.savedVars.companionPreferred or name
		end
	end

	local _, numCollectiblesA = GetCollectibleSubCategoryInfo(8, 1)
	for i = 1, numCollectiblesA do
		local collectibleId = GetCollectibleId(8, 1, i)
		local name, description, _, _, unlocked = GetCollectibleInfo(collectibleId)
		if unlocked then
			if description:find(GetString(SUMMONALLY_SEARCH_BANKER1)) or description:find(GetString(SUMMONALLY_SEARCH_BANKER2)) or description:find(GetString(SUMMONALLY_SEARCH_BANKER3)) then
				SummonAlly.savedVars.alliesTable.bankerTable[collectibleId] = name
				SummonAlly.savedVars.bankerPreferred = SummonAlly.savedVars.bankerPreferred or name
			elseif description:find(GetString(SUMMONALLY_SEARCH_MERCHANT1)) or description:find(GetString(SUMMONALLY_SEARCH_MERCHANT2)) or description:find(GetString(SUMMONALLY_SEARCH_MERCHANT3)) then
				SummonAlly.savedVars.alliesTable.merchantTable[collectibleId] = name
				SummonAlly.savedVars.merchantPreferred = SummonAlly.savedVars.merchantPreferred or name
			elseif description:find(GetString(SUMMONALLY_SEARCH_FENCE1)) then
				SummonAlly.savedVars.alliesTable.fenceTable[collectibleId] = name
				SummonAlly.savedVars.fencePreferred = SummonAlly.savedVars.fencePreferred or name
			elseif description:find(GetString(SUMMONALLY_SEARCH_ARMORY1)) then
				SummonAlly.savedVars.alliesTable.armoryTable[collectibleId] = name
				SummonAlly.savedVars.armoryPreferred = SummonAlly.savedVars.armoryPreferred or name
			elseif description:find(GetString(SUMMONALLY_SEARCH_DECON1)) then
				SummonAlly.savedVars.alliesTable.deconTable[collectibleId] = name
				SummonAlly.savedVars.deconPreferred = SummonAlly.savedVars.deconPreferred or name
			end
		end
	end
end

function SummonAlly.OnAddOnLoaded(event, addonName)
	if addonName == SummonAlly.name then
		SummonAlly.characterSavedVars = ZO_SavedVars:New("SummonAllySavedVariables", SummonAlly.variableVersion, nil, SummonAlly.savedVars, GetWorldName())
		SummonAlly.accountSavedVars = ZO_SavedVars:NewAccountWide("SummonAllySavedVariables", SummonAlly.variableVersion, nil, SummonAlly.savedVars, GetWorldName())
		if not SummonAlly.characterSavedVars.accountWide then
			SummonAlly.savedVars = SummonAlly.characterSavedVars
		else
			SummonAlly.savedVars = SummonAlly.accountSavedVars
		end
	else
		return
	end

	SummonAlly.AlliesSetup()
	SummonAlly.LoadSettings()

	EVENT_MANAGER:UnregisterForEvent(SummonAlly.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(SummonAlly.name, EVENT_PLAYER_ACTIVATED, SummonAlly.Activated)
	EVENT_MANAGER:RegisterForEvent(SummonAlly.name, EVENT_COMPANION_ACTIVATED, SummonAlly.CompanionActivated)
--	EVENT_MANAGER:RegisterForEvent(SummonAlly.name, EVENT_UNIT_CREATED, SummonAlly.AssistantCreated)
--	EVENT_MANAGER:AddFilterForEvent(SummonAlly.name, EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX , "playerpet")
--	EVENT_MANAGER:RegisterForEvent(SummonAlly.name, EVENT_UNIT_DESTROYED, SummonAlly.AssistantDestroyed)
--	EVENT_MANAGER:AddFilterForEvent(SummonAlly.name, EVENT_UNIT_DESTROYED, REGISTER_FILTER_UNIT_TAG_PREFIX , "playerpet")

	ZO_CreateStringId("SI_BINDING_NAME_SUMMON_ALLY_COMPANION_PREF", GetString(SUMMONALLY_SUMMON_COMPANION))
	ZO_CreateStringId("SI_BINDING_NAME_SUMMON_ALLY_COMPANION_LASTUSED", GetString(SUMMONALLY_SUMMON_COMPANION_LASTUSED))
	ZO_CreateStringId("SI_BINDING_NAME_SUMMON_ALLY_BANKER", GetString(SUMMONALLY_SUMMON_BANKER))
	ZO_CreateStringId("SI_BINDING_NAME_SUMMON_ALLY_MERCHANT", GetString(SUMMONALLY_SUMMON_MERCHANT))
	ZO_CreateStringId("SI_BINDING_NAME_SUMMON_ALLY_FENCE", GetString(SUMMONALLY_SUMMON_FENCE))
	ZO_CreateStringId("SI_BINDING_NAME_SUMMON_ALLY_ARMORY", GetString(SUMMONALLY_SUMMON_ARMORY))
	ZO_CreateStringId("SI_BINDING_NAME_SUMMON_ALLY_DECON", GetString(SUMMONALLY_SUMMON_DECON))
end

EVENT_MANAGER:RegisterForEvent(SummonAlly.name, EVENT_ADD_ON_LOADED, SummonAlly.OnAddOnLoaded)

SLASH_COMMANDS["/summoncompanion"] = SummonAlly.SummonCompanionPref
SLASH_COMMANDS["/summoncompanionlastused"] = SummonAlly.SummonCompanionLastUsed
SLASH_COMMANDS["/summonbanker"] = SummonAlly.SummonBanker
SLASH_COMMANDS["/summonmerchant"] = SummonAlly.SummonMerchant
SLASH_COMMANDS["/summonfence"] = SummonAlly.SummonFence
SLASH_COMMANDS["/summonarmory"] = SummonAlly.SummonArmory
SLASH_COMMANDS["/summondecon"] = SummonAlly.SummonDecon