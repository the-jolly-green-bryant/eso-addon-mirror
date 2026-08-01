local EM = EVENT_MANAGER
local name = JackOfAllTrades.name

local chat
if (LibChatMessage) then
	chat = LibChatMessage("JackOfAllTrades", "JoAT")
end
local BLACKROSE_ZONE_INDEX = 678

local skillData = {
	professionalUpkeep = {
		id = 1,
		index = 4,
	},
	meticulousDisassembly = {
		id = 83,
		index = 4,
	},
	masterGatherer = {
		id = 78,
		index = 4,
	},
	plentifulHarvest = {
		id = 81,
		index = 3,
	},
	treasureHunter = {
		id = 79,
		index = 4,
	},
	homemaker = {
		id = 91,
		index = 3,
	},
	reelTechnique = {
		id = 88,
		index = 4,
	},
	anglersInstinct = {
		id = 89,
		index = 3,
	},
	cutpursesArt = {
		id = 90,
		index = 4,
	},
	infamous = {
		id = 77,
		index = 4,
	},
	rationer = {
		id = 85,
		index = 4,
	},
	liquidEfficiency = {
		id = 86,
		index = 3,
	},
	giftedRider = {
		id = 92,
		index = 4,
	},
	warMount = {
		id = 82,
		index = 3,
	},
	sustainingShadows = {
		id = 65,
		index = 3,
	}
}

local professionalUpkeep = skillData.professionalUpkeep
local meticulousDisassembly = skillData.meticulousDisassembly
local masterGatherer = skillData.masterGatherer
local plentifulHarvest = skillData.plentifulHarvest
local treasureHunter = skillData.treasureHunter
local homemaker = skillData.homemaker
local reelTechnique = skillData.reelTechnique
local anglersInstinct = skillData.anglersInstinct
local cutpursesArt = skillData.cutpursesArt
local infamous = skillData.infamous
local rationer = skillData.rationer
local liquidEfficiency = skillData.liquidEfficiency
local giftedRider = skillData.giftedRider
local warMount = skillData.warMount
local sustainingShadows = skillData.sustainingShadows

local CPTexture = {
	craft = "|t24:24:esoui/art/champion/champion_points_stamina_icon-hud-32.dds|t",
	warfare = "|t24:24:esoui/art/champion/champion_points_magicka_icon-hud-32|t",
	fitness = "|t24:24:esoui/art/champion/champion_points_health_icon-hud-32|t",
}

function JackOfAllTrades.GetSkillId(rawSkillName)
	if skillData[rawSkillName] then 
		return skillData[rawSkillName].id
	end
end

local skillNotificationMessageQueue = {
	professionalUpkeep = false,
	meticulousDisassembly = false,
	masterGatherer = false,
	plentifulHarvest = false,
 	treasureHunter = false,
	homemaker = false,
 	reelTechnique = false,
 	anglersInstinct = false,
 	cutpursesArt = false,
 	infamous = false,
 	rationer = false,
 	liquidEfficiency = false,
 	giftedRider = false,
 	warMount = false,
	sustainingShadows = false
}

local cooldownOverMsgQueued = false

local function PrintMessage(message)
	if (chat) then
		chat:Printf(message)
	else
		CHAT_SYSTEM:AddMessage(message)
	end
end

function JackOfAllTrades.sendCooldownOverMessage()
	local texture = CPTexture.craft
	PrintMessage(JackOfAllTrades.savedVariables.colour.notifications .. texture .. GetString(SI_JACK_OF_ALL_TRADES_COOLDOWN_OVER) .. ".") 
end

local function SendNotification(variableSkillName)
	local alertNotification = JackOfAllTrades.savedVariables.alertNotification
	if JackOfAllTrades.savedVariables.notification[variableSkillName] then 
		local texture = ''
		if JackOfAllTrades.savedVariables.textureNotification then texture = CPTexture.craft end
		if JackOfAllTrades.GetCurrentCooldown() == 30 or JackOfAllTrades.GetCurrentCooldown() == 0 then
			if alertNotification then ZO_Alert(ERROR, nil, (JackOfAllTrades.savedVariables.colour.notifications .. texture .. ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, GetChampionSkillName(skillData[variableSkillName].id)) .. " " .. GetString(SI_JACK_OF_ALL_TRADES_SLOTTED) .. ".")) return end
			PrintMessage(JackOfAllTrades.savedVariables.colour.notifications .. texture .. ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, GetChampionSkillName(skillData[variableSkillName].id)) .. " " .. GetString(SI_JACK_OF_ALL_TRADES_SLOTTED) .. ".") 
			return
		else
			if JackOfAllTrades.savedVariables.slotSkillsAfterCooldownEnds then
				if alertNotification then 
					ZO_Alert(ERROR, nil, JackOfAllTrades.savedVariables.colour.notifications .. texture .. ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, GetChampionSkillName(skillData[variableSkillName].id)) .. " " .. zo_strformat(SI_JACK_OF_ALL_TRADES_DELAYED_SLOTTED, JackOfAllTrades.GetCurrentCooldown()) .. ".") 
				else
					PrintMessage(JackOfAllTrades.savedVariables.colour.notifications .. texture .. ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, GetChampionSkillName(skillData[variableSkillName].id)) .. " " .. zo_strformat(SI_JACK_OF_ALL_TRADES_DELAYED_SLOTTED, JackOfAllTrades.GetCurrentCooldown()) .. ".") 
				end
				if skillNotificationMessageQueue[variableSkillName] then return end
				skillNotificationMessageQueue[variableSkillName] = true
				return
			else
				if alertNotification then ZO_Alert(ERROR, nil, JackOfAllTrades.savedVariables.colour.notifications .. texture .. ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, GetChampionSkillName(skillData[variableSkillName].id)) .. " " .. zo_strformat(SI_JACK_OF_ALL_TRADES_COOLDOWN_DISABLED, JackOfAllTrades.GetCurrentCooldown()) .. ".")
				else PrintMessage(JackOfAllTrades.savedVariables.colour.notifications .. texture .. ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, GetChampionSkillName(skillData[variableSkillName].id)) .. " " .. zo_strformat(SI_JACK_OF_ALL_TRADES_COOLDOWN_DISABLED, JackOfAllTrades.GetCurrentCooldown()) .. ".")  end
				if JackOfAllTrades.savedVariables.altertedAfterCooldownOver and not cooldownOverMsgQueued then 
					cooldownOverMsgQueued = true
					zo_callLater(function() 
						cooldownOverMsgQueued = false 
						PrintMessage(JackOfAllTrades.savedVariables.colour.notifications .. texture .. GetString(SI_JACK_OF_ALL_TRADES_COOLDOWN_OVER) .. ".")  end, JackOfAllTrades.GetCurrentCooldown()*1000) 
				end 
				JackOfAllTrades.resetSkillQueue() -- If we don't want to slot the skill after the cooldown ends then we don't want anything in the skill queue.
				return
			end
		end
	end
end

local skillNamesQueue = {}
local function SendWarning(variableSkillName)
	if not DoesCurrentCampaignRulesetAllowChampionPoints() then return false end

	local championSkill = skillData[variableSkillName]
	local isSlottable = CanChampionSkillTypeBeSlotted(GetChampionSkillType(championSkill.id))
	
	-- Try allocating points then slot it
	if JackOfAllTrades.AttemptToAllocatePointsIntoCP(championSkill.id) then
		if (isSlottable) then
			zo_callLater(function ()
				local skillId = championSkill.id
				local skillIndex = championSkill.index
				local result = JackOfAllTrades.AddCPNodeToQueue(skillId, skillIndex)
				skillNamesQueue[#skillNamesQueue+1] = variableSkillName
				zo_callLater(function ()
					if result then
						local slotResult = JackOfAllTrades.SlotAllStarsInQueue()
						if slotResult ~= false then
							for i, name in ipairs(skillNamesQueue) do
								SendNotification(name)
							end
							skillNamesQueue = {}
						end
					end
				end, 200)
			end, 200)
		end
	else
	
		if JackOfAllTrades.savedVariables.warnings[variableSkillName] then
			local texture = CPTexture.craft
			local textFormat = isSlottable and SI_JACK_OF_ALL_TRADES_NOT_ENOUGH_POINTS_WARNING or SI_JACK_OF_ALL_TRADES_NOT_MAX_POINTS_WARNING
			local warningText = JackOfAllTrades.savedVariables.colour.warnings .. texture .. zo_strformat(textFormat, ZO_CachedStrFormat(SI_CHAMPION_STAR_NAME, GetChampionSkillName(championSkill.id)))

			if JackOfAllTrades.savedVariables.alertWarning then
				ZO_Alert(ERROR, nil, warningText)
			else
				PrintMessage(warningText)
			end
		end
		
	end
end

local function resetSkillNotificationMessageQueue()
	skillNotificationMessageQueue = {
		professionalUpkeep = false,
		meticulousDisassembly = false,
		masterGatherer = false,
		plentifulHarvest = false,
	 	treasureHunter = false,
		homemaker = false,
	 	reelTechnique = false,
	 	anglersInstinct = false,
	 	cutpursesArt = false,
	 	infamous = false,
	 	rationer = false,
	 	liquidEfficiency = false,
	 	giftedRider = false,
 		warMount = false,
		sustainingShadows = false
	}
end	

function JackOfAllTrades.SendQueuedNotifcations()
	for skill, value in pairs(skillNotificationMessageQueue) do
		if value then
			SendNotification(skill)
		end
	end
	resetSkillNotificationMessageQueue()
end

local function GetDesiredSlot(skillId, pairedSkillId, desiredSlot)
	if GetSlotBoundId(desiredSlot, HOTBAR_CATEGORY_CHAMPION) == pairedSkillId then
		if desiredSlot == 3 then 
			if JackOfAllTrades.savedVariables.debug then d("Paired skill already slotted in slot " .. desiredSlot) end
			return 4 
		elseif desiredSlot == 4 then 
			if JackOfAllTrades.savedVariables.debug then d("Paired skill already slotted in slot " .. desiredSlot) end
			return 3 
		else 
			if JackOfAllTrades.savedVariables.debug then d("GetDesiredSlot got a slot that is not 3 or 4") end
			return false 
		end
	end
	return desiredSlot
end

local function OpenStore(e)
	if not CanStoreRepair() then return false end
	if GetRepairAllCost() == 0 then return false end
	if not JackOfAllTrades.savedVariables.warnings.professionalUpkeep then return false end
	local result = JackOfAllTrades.AddCPNodeToQueue(professionalUpkeep.id, professionalUpkeep.index)
	if result == nil then
		SendWarning("professionalUpkeep")
	end
end

local function StartGathering()
	if not JackOfAllTrades.savedVariables.enable.masterGatherer and not JackOfAllTrades.savedVariables.enable.plentifulHarvest then return end

	local masterGathererResult = false
	local plentifulHarvestResult = false
	
	if JackOfAllTrades.savedVariables.enable.masterGatherer then 
		masterGathererResult = JackOfAllTrades.AddCPNodeToQueue(masterGatherer.id, GetDesiredSlot(masterGatherer.id, plentifulHarvest.id, masterGatherer.index))
	end

	if JackOfAllTrades.savedVariables.warnings.plentifulHarvest then
		plentifulHarvestResult = JackOfAllTrades.AddCPNodeToQueue(plentifulHarvest.id, GetDesiredSlot(plentifulHarvest.id, masterGatherer.id, plentifulHarvest.index))
	end
	
	if masterGathererResult or plentifulHarvestResult then
		local slotResult = JackOfAllTrades.SlotAllStarsInQueue()
		if slotResult ~= false then
			if masterGathererResult then SendNotification("masterGatherer") end
		end
	end

	if masterGathererResult == nil then SendWarning("masterGatherer") end
	if plentifulHarvestResult == nil then SendWarning("plentifulHarvest") end
end

local function StartLooting()
	if not JackOfAllTrades.savedVariables.warnings.homemaker then return false end
	local result = JackOfAllTrades.AddCPNodeToQueue(homemaker.id, homemaker.index)
	if result == nil then
		SendWarning("homemaker")
	end
end

local function StartOpeningChest()
	if not JackOfAllTrades.savedVariables.warnings.treasureHunter then return false end
	local result = JackOfAllTrades.AddCPNodeToQueue(treasureHunter.id, treasureHunter.index)
	if result == nil then
		SendWarning("treasureHunter")
	end
end

local function StartPickpocketing()
	if not JackOfAllTrades.savedVariables.warnings.cutpursesArt then return false end
	local result = JackOfAllTrades.AddCPNodeToQueue(cutpursesArt.id, cutpursesArt.index)
	if result == nil then
		SendWarning("cutpursesArt")
	end
end

local function OpenFence()
	if not JackOfAllTrades.savedVariables.warnings.infamous then return false end
	local result = JackOfAllTrades.AddCPNodeToQueue(infamous.id, infamous.index)
	if result == nil then
		SendWarning("infamous")
	end
end

local function DoesPlayerHaveAWritQuest()
	for quest=1, GetNumJournalQuests() do
		if GetJournalQuestType(quest) == QUEST_TYPE_CRAFTING then return true end
	end
	return false
end

local function OpenCraftingStation(e, craft_skill, craft_type)
	-- Check the crafting table supports MD
	if craft_skill ~= 0 and craft_skill ~= 1 and craft_skill ~= 2 and craft_skill ~= 6 and craft_skill ~= 7 then return end

	if not JackOfAllTrades.savedVariables.warnings.meticulousDisassembly then return false end

	if not JackOfAllTrades.savedVariables.slotMdWhilstDoingWrits then 
		if DoesPlayerHaveAWritQuest() then
			return false 
		end
	end

	local result = JackOfAllTrades.AddCPNodeToQueue(meticulousDisassembly.id, meticulousDisassembly.index)
	
	if result == nil then
		SendWarning("meticulousDisassembly")
	end
end

-------------------------------------------------------------------------------------------------
-- Fishing --
-------------------------------------------------------------------------------------------------
local delay = 2000 -- Delay so we don't have to check if we need to change CP 200 times a second

local function StartFishing()
	if not JackOfAllTrades.savedVariables.enable.reelTechnique and not JackOfAllTrades.savedVariables.enable.anglersInstinct then return end
	local reelTechniqueResult = false
	local anglersInstinctResult = false
	if JackOfAllTrades.savedVariables.enable.reelTechnique then 
		reelTechniqueResult = JackOfAllTrades.AddCPNodeToQueue(reelTechnique.id, GetDesiredSlot(reelTechnique.id, anglersInstinct.id, reelTechnique.index))
	end
	if JackOfAllTrades.savedVariables.enable.anglersInstinct then 
		anglersInstinctResult = JackOfAllTrades.AddCPNodeToQueue(anglersInstinct.id, GetDesiredSlot(anglersInstinct.id, reelTechnique.id, anglersInstinct.index))
	end
	if reelTechniqueResult or anglersInstinctResult then
		local slotResult = JackOfAllTrades.SlotAllStarsInQueue()
		if slotResult ~= false then
			if reelTechniqueResult then SendNotification("reelTechnique") end
			if anglersInstinctResult then SendNotification("anglersInstinct") end
		end
	end
	if reelTechniqueResult == nil then SendWarning("reelTechnique") end
	if anglersInstinctResult == nil then SendWarning("anglersInstinct") end
end

local trashPots = {
	'|H0:item:27038:307:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h',
	'|H0:item:27037:307:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h',
	'|H0:item:27036:307:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h'
}

local function isTrashPotion(itemLink)
	for _, link in pairs(trashPots) do
		if link == itemLink then return true end
	end
	return false
end

local function QuickSlotChanged(e, slot)
	local itemLink = GetSlotItemLink(slot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)

	-- Trash pot check
	if not JackOfAllTrades.savedVariables.slotLeTrashPots and isTrashPotion(itemLink) then return false end

	local consumableType, _ = GetItemLinkItemType(itemLink)
	-- Check if we need to do anything
	if consumableType ~= ITEMTYPE_FOOD and consumableType ~= ITEMTYPE_DRINK and consumableType ~= ITEMTYPE_POTION and consumableType ~= ITEMTYPE_POTION_BASE then return false end
	if not JackOfAllTrades.savedVariables.warnings.rationer and not JackOfAllTrades.savedVariables.warnings.liquidEfficiency then return end

	local rationerResult = false
	local liquidEfficiencyResult = false

	if JackOfAllTrades.savedVariables.warnings.rationer and (consumableType == ITEMTYPE_FOOD or consumableType == ITEMTYPE_DRINK) then
		rationerResult = JackOfAllTrades.AddCPNodeToQueue(rationer.id, rationer.index)
	end

	if JackOfAllTrades.savedVariables.warnings.liquidEfficiency and (consumableType == ITEMTYPE_POTION or consumableType == ITEMTYPE_POTION_BASE) then
		liquidEfficiencyResult = JackOfAllTrades.AddCPNodeToQueue(liquidEfficiency.id, liquidEfficiency.index)
	end

	if rationerResult == nil then SendWarning("rationer") end
	if liquidEfficiencyResult == nil then SendWarning("liquidEfficiency") end
end


local function MountStateChanged(e, mounted)
	if not mounted then return end

	if not JackOfAllTrades.savedVariables.enable.giftedRider and not JackOfAllTrades.savedVariables.enable.warMount then return end

	local giftedRiderResult = false
	local warMountResult = false

	if JackOfAllTrades.savedVariables.enable.giftedRider then
		giftedRiderResult = JackOfAllTrades.AddCPNodeToQueue(giftedRider.id, giftedRider.index)
	end

	if JackOfAllTrades.savedVariables.enable.warMount then
		warMountResult = JackOfAllTrades.AddCPNodeToQueue(warMount.id, warMount.index)
	end 

	if giftedRiderResult or warMountResult then
		local slotResult = JackOfAllTrades.SlotAllStarsInQueue()
		if slotResult ~= false then
			if giftedRiderResult then SendNotification("giftedRider") end
			if warMountResult then SendNotification("warMount") end
		end
	end

	if giftedRiderResult == nil then SendWarning("giftedRider") end
	if warMountResult == nil then SendWarning("warMount") end
end

local function IsHomemakerBenefical(text)
	local homemakerSlottables = {
		SI_JACK_OF_ALL_TRADES_HM_BACKPACK,
		SI_JACK_OF_ALL_TRADES_HM_BARREL,
		SI_JACK_OF_ALL_TRADES_HM_BARRELS,
		SI_JACK_OF_ALL_TRADES_HM_BASKET,
		SI_JACK_OF_ALL_TRADES_HM_CHEST,
		SI_JACK_OF_ALL_TRADES_HM_CRATE,
		SI_JACK_OF_ALL_TRADES_HM_CRATES,
		SI_JACK_OF_ALL_TRADES_HM_CUPBOARD,
		SI_JACK_OF_ALL_TRADES_HM_DRAWERS,
		SI_JACK_OF_ALL_TRADES_HM_NIGHTSTAND,
		SI_JACK_OF_ALL_TRADES_HM_URN,
		SI_JACK_OF_ALL_TRADES_HM_WARDROBE,
		SI_JACK_OF_ALL_TRADES_HM_DRESSER,
		SI_JACK_OF_ALL_TRADES_HM_DESK,
		SI_JACK_OF_ALL_TRADES_HM_TRUNK,
		SI_JACK_OF_ALL_TRADES_HM_CABINET,
		SI_JACK_OF_ALL_TRADES_HM_D_JUG,
		SI_JACK_OF_ALL_TRADES_HM_D_JUG_L,
		SI_JACK_OF_ALL_TRADES_HM_D_POT,
		SI_JACK_OF_ALL_TRADES_HM_THIEVES_T,
		SI_JACK_OF_ALL_TRADES_HM_SAFEBOX,
		SI_JACK_OF_ALL_TRADES_HM_COFFER
	}

	for _, item in pairs(homemakerSlottables) do
		if text == GetString(item) then return true end
	end
end

function JackOfAllTrades.getHomemakerLootables()
	local homemakerSlottables = {
		SI_JACK_OF_ALL_TRADES_HM_BACKPACK,
		SI_JACK_OF_ALL_TRADES_HM_BARREL,
		SI_JACK_OF_ALL_TRADES_HM_BARRELS,
		SI_JACK_OF_ALL_TRADES_HM_BASKET,
		SI_JACK_OF_ALL_TRADES_HM_CHEST,
		SI_JACK_OF_ALL_TRADES_HM_CRATE,
		SI_JACK_OF_ALL_TRADES_HM_CRATES,
		SI_JACK_OF_ALL_TRADES_HM_CUPBOARD,
		SI_JACK_OF_ALL_TRADES_HM_DRAWERS,
		SI_JACK_OF_ALL_TRADES_HM_NIGHTSTAND,
		SI_JACK_OF_ALL_TRADES_HM_URN,
		SI_JACK_OF_ALL_TRADES_HM_WARDROBE,
		SI_JACK_OF_ALL_TRADES_HM_DRESSER,
		SI_JACK_OF_ALL_TRADES_HM_DESK,
		SI_JACK_OF_ALL_TRADES_HM_TRUNK,
		SI_JACK_OF_ALL_TRADES_HM_CABINET,
		SI_JACK_OF_ALL_TRADES_HM_D_JUG,
		SI_JACK_OF_ALL_TRADES_HM_D_JUG_L,
		SI_JACK_OF_ALL_TRADES_HM_D_POT,
		SI_JACK_OF_ALL_TRADES_HM_THIEVES_T,
		SI_JACK_OF_ALL_TRADES_HM_SAFEBOX,
		SI_JACK_OF_ALL_TRADES_HM_COFFER
	}
	local output = ''
	for _, text in pairs(homemakerSlottables) do
		output = output .. '\n' .. GetString(text)
	end
	return output
end

-------------------------------------------------------------------------------------------------
-- When the player looks at something they can interact with, i.e. A crafting/ fishing node --
-------------------------------------------------------------------------------------------------
local isActionHarvest = {
	[GetString(SI_GAMECAMERAACTIONTYPE3)] = true,
	[GetString(SI_JACK_OF_ALL_TRADES_INTERACT_COLLECT)] = true,
	[GetString(SI_JACK_OF_ALL_TRADES_INTERACT_CUT)] = true,
	[GetString(SI_JACK_OF_ALL_TRADES_INTERACT_MINE)] = true,
	[GetString(SI_JACK_OF_ALL_TRADES_INTERACT_HARVEST)] = true
}
local isActionChest = {
	[GetString(SI_GAMECAMERAACTIONTYPE12)] = true,
	[GetString(SI_GAMECAMERAACTIONTYPE5)] = true,
	[GetString(SI_JACK_OF_ALL_TRADES_INTERACT_CHEST_HIDDEN)] = true,
}
local isActionLoot = {
	[GetString(SI_GAMECAMERAACTIONTYPE1)] = true,
	[GetString(SI_GAMECAMERAACTIONTYPE20)] = true,
}
 
local STR_PICKPOCKET = GetString(SI_GAMECAMERAACTIONTYPE21)
 
-- Pre Hook for whenever the player presses the interact key
local function OnInteractKeyPressed() 
 
	local zoneId, _, _, _ =  GetUnitWorldPosition('player')
 
	local interactText, mainText, looted, isOwned, additionalInfo, _, _, _ = GetGameCameraInteractableActionInfo()
	-- FISHING
	if additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE then StartFishing() return end
	-- GATHERING
	if isActionHarvest[interactText] then 
		if zoneId == 1197 then return false end -- Check if we are in Stone Garden, if we are we don't want to slot gathering passives.
		StartGathering() 
	-- TREASURE HUNTER
	elseif interactText == GetString(SI_JACK_OF_ALL_TRADES_INTERACT_UNLOCK) or ((mainText == GetString(SI_JACK_OF_ALL_TRADES_INTERACT_CHEST) or mainText == GetString(SI_JACK_OF_ALL_TRADES_INTERACT_CHEST_HIDDEN)) and interactText == GetString(SI_JACK_OF_ALL_TRADES_INTERACT_USE)) then 
		if not isOwned then -- This is to stop it slotting on doors.
			StartOpeningChest()
		end
	-- PICKPOCKETTING
	elseif interactText == STR_PICKPOCKET then 
		StartPickpocketing()
	-- LOOTING
	else
		-- I put (not looted) first since it seems like the deal-breaker. Why "bookshelf". Isn't it's action "Read" not "Search"? Also, only English?
		if not looted and isActionLoot[interactText] and mainText ~= "Bookshelf" then
			if JackOfAllTrades.savedVariables.homemakerCorpses then
				StartLooting()
			else
				if IsHomemakerBenefical(mainText) then
					StartLooting()
				end
			end
		end
	end
end

local function SlotRationer()
	local result = JackOfAllTrades.AddCPNodeToQueue(rationer.id, rationer.index)
	if result == nil then
		SendWarning("rationer")
	end
end

local function PlayerEnteredDungeon()
	-- If we are in nBRP and we want to slot rationer, then we don't care about slotting treasure hunter as you don't loot any chests.
	if GetUnitZoneIndex('player') == BLACKROSE_ZONE_INDEX and GetCurrentZoneDungeonDifficulty() == 1 and JackOfAllTrades.savedVariables.slotRationerInGrindSpot then 
		-- We slot rationer because we want the buff for XP pots.
		SlotRationer()
		return false
	end
	if JackOfAllTrades.savedVariables.slotThInDungeon then
		if JackOfAllTrades.savedVariables.thHmPair then SlotThHmPair() return false end
		if not JackOfAllTrades.savedVariables.enable.treasureHunter then return false end
		local result = JackOfAllTrades.AddCPNodeToQueue(treasureHunter.id, treasureHunter.index)
		if result == nil then
			SendWarning("treasureHunter")
		end
	end
end

local function OnSneakStateChanged(_, unitTag, hidden)
	if unitTag ~= 'player' then return end
	if hidden ~= 3 then return end

	if not JackOfAllTrades.savedVariables.enable.sustainingShadows then return end

	local result = JackOfAllTrades.AddCPNodeToQueue(sustainingShadows.id, sustainingShadows.index)

	if result then
		local slotResult = JackOfAllTrades.SlotAllStarsInQueue()
		if slotResult ~= false then
			SendNotification("sustainingShadows")
		end
	elseif result == nil then
		SendWarning("sustainingShadows")
	end
end

-- TODO: Fix this global shit
function JackOfAllTrades.EventOnPlayerActivated()
	if IsUnitInDungeon('player') then PlayerEnteredDungeon() end
end 

local function LoadInSavedVariables()
	for star, index in pairs(JackOfAllTrades.savedVariables.slotIndex) do
		if skillData[star] then skillData[star].index = index end
	end
	professionalUpkeep = skillData.professionalUpkeep
	meticulousDisassembly = skillData.meticulousDisassembly
	masterGatherer = skillData.masterGatherer
	plentifulHarvest = skillData.plentifulHarvest
	treasureHunter = skillData.treasureHunter
	homemaker = skillData.homemaker
	reelTechnique = skillData.reelTechnique
	anglersInstinct = skillData.anglersInstinct
	cutpursesArt = skillData.cutpursesArt
	infamous = skillData.infamous
	rationer = skillData.rationer
	liquidEfficiency = skillData.liquidEfficiency
	giftedRider = skillData.giftedRider
	warMount = skillData.warMount
	sustainingShadows = skillData.sustainingShadows
end

function JackOfAllTrades.UpdateSkillSlots()
	LoadInSavedVariables()
end

-------------------------------------------------------------------------------------------------
-- Register for events, we only want to do so if the API version is high enough  --
-------------------------------------------------------------------------------------------------
function JackOfAllTrades.InitEvents()
	LoadInSavedVariables()

	EM:RegisterForEvent(name, EVENT_OPEN_STORE, OpenStore)
	EM:RegisterForEvent(name, EVENT_CRAFTING_STATION_INTERACT, OpenCraftingStation)
	EM:RegisterForEvent(name, EVENT_OPEN_FENCE, OpenFence)
	EM:RegisterForEvent(name, EVENT_ACTIVE_QUICKSLOT_CHANGED, QuickSlotChanged)

	EM:RegisterForEvent(name, EVENT_MOUNTED_STATE_CHANGED, MountStateChanged)

	-- Is called whenever you press 'E'
	-- For fishing, treasureHunter, gathering nodes etc.
	ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, "StartInteraction", OnInteractKeyPressed)

	-- To check when the player crouches in order to slot sustaining shadows
	EM:RegisterForEvent(name, EVENT_STEALTH_STATE_CHANGED, OnSneakStateChanged)
end
