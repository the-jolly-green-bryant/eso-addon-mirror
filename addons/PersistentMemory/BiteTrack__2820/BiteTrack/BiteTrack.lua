BiteTrack = {}

BiteTrack.name="BiteTrack"

-- some data for LAM

BiteTrack.defaults = {
	[1] = {
		characterName = "",
		timesFed = 0,
		bladeOfWoe = 0,
	}
}

-- 135402 -- vampire stage 4
-- 135400 -- vampire stage 3
-- 135399 -- vampire stage 2
-- 135397 -- vampire stage 1

local vampireStages = {135402, 135400, 135399, 135397}

function BiteTrack.OnAddOnLoaded(event, addOnName)
	if addOnName == BiteTrack.name then
		BiteTrack:Initialize()
	end
end

function BiteTrack:Initialize() 
  -- register events
  EVENT_MANAGER:UnregisterForEvent(BiteTrack.name, EVENT_ADD_ON_LOADED)
  EVENT_MANAGER:RegisterForEvent(BiteTrack.name, EVENT_EFFECT_CHANGED, BiteTrack.OnEffectChanged )
  EVENT_MANAGER:AddFilterForEvent(BiteTrack.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
  EVENT_MANAGER:RegisterForEvent(BiteTrack.name, EVENT_PLAYER_COMBAT_STATE, BiteTrack.OnPlayerCombatState)
  EVENT_MANAGER:RegisterForEvent(NAME, EVENT_COMBAT_EVENT, BiteTrack.CombatEvent)
  
  -- initialize some options
  BiteTrack.savedVariables = ZO_SavedVars:NewAccountWide("BiteTrackSavedVariables", 1, "BiteTrack")
  -- initialize LAM if it exists
  
  
  -- initialize some local defaults
  BiteTrack.inCombat = inCombat
  BiteTrack.lastVampStage = 0
  BiteTrack.characterName = GetUnitName("player")
  BiteTrack.characterId = GetCurrentCharacterId();
  if BiteTrack.savedVariables ~= nil then
	if BiteTrack.savedVariables[BiteTrack.characterId] ~= nil then
		  if BiteTrack.savedVariables[BiteTrack.characterId].isVampire ~= nil then
			BiteTrack.isVampire = BiteTrack.savedVariables[BiteTrack.characterId].isVampire
		  else
			BiteTrack.isVampire = false
		  end
	end
  end
  
  -- search for this character id in the list of character ids, and if not found, add it
  if BiteTrack.savedVariables["characters"] ~= nil then
	local foundChar = false
	for index = 1, #BiteTrack.savedVariables["characters"], 1 do
		if BiteTrack.savedVariables["characters"][index] == BiteTrack.characterId then 
			foundChar = true
		end
	end
	if not foundChar then
			table.insert(BiteTrack.savedVariables["characters"], BiteTrack.characterId)
    end
  else
	-- if we haven't created the character id array at all, create it and add this character
	BiteTrack.savedVariables["characters"] = { BiteTrack.characterId }
  end
  
  
  -- this list is just so that they can get stats for all their characters at once
  
  if BiteTrack.savedVariables[BiteTrack.characterId] == nil then
  -- if the characterId isn't in our savedvars we will create it
	BiteTrack.savedVariables[BiteTrack.characterId] = {characterName = BiteTrack.characterName, timesFed = 0, bladeOfWoe = 0, isVampire = false}
  end
    
  BiteTrack.timesFed = BiteTrack.savedVariables[BiteTrack.characterId].timesFed 
  TimesFedIndicatorLabel:SetText(BiteTrack.timesFed)
  
  BiteTrack.bladeOfWoe = BiteTrack.savedVariables[BiteTrack.characterId].bladeOfWoe 
  BladeOfWoeIndicatorLabel:SetText(math.floor(BiteTrack.bladeOfWoe))
  
  -- check to see that we ARE a vampire
  -- we do this each time in case they cure vampirism
  local numBuffs = GetNumBuffs("player")
  for i = 0, numBuffs, 1 do
	local buffName,timeStarted,timeEnding,buffSlot,stackCount,textureName,buffType,effectType,abilityType,statusEffectType,abilityIdOfPlayerBuff,_ = GetUnitBuffInfo("player", i)
	--CHAT_SYSTEM:AddMessage("abilityIdOfPlayerBuff: " .. abilityIdOfPlayerBuff .. " buffName: " .. buffName)
	for index, value in ipairs(vampireStages) do
		if value == abilityIdOfPlayerBuff then
			-- we are a vampire
			BiteTrack.isVampire = true
			BiteTrack.savedVariables[BiteTrack.characterId].isVampire = true
			-- and we don't really care about any other buffs so
			break
		end
	end
  end

  
  -- if we are a vampire, show the tracker
  if BiteTrack.isVampire then
	--CHAT_SYSTEM:AddMessage("we are a vampire")
	TimesFedIndicator:SetHidden(false)
  else
	--CHAT_SYSTEM:AddMessage("we are not a vampire")
	TimesFedIndicator:SetHidden(true)
  end
  
  BladeOfWoeIndicator:SetHidden(false)
  
  -- all this checking may cause the indicator to not show the first time you load (when a character isn't a vampire) but should show subsequently
  
  -- set up the label positions for Bites
  if BiteTrack.savedVariables.tflabelleft == nil then
	BiteTrack.savedVariables.tflabelleft = TimesFedIndicatorSezLabel:GetLeft()
  end
  
  if BiteTrack.savedVariables.tflabeltop == nil then
	BiteTrack.savedVariables.tflabeltop = TimesFedIndicatorSezLabel:GetTop()
  end
  
  if BiteTrack.savedVariables.tfnumberleft == nil then
	BiteTrack.savedVariables.tfnumberleft = TimesFedIndicatorLabel:GetLeft()
  end
  
  if BiteTrack.savedVariables.tfnumbertop == nil then
	BiteTrack.savedVariables.tfnumbertop = TimesFedIndicatorLabel:GetTop()
  end
  
  -- set up the label positions Blades of Woe
  if BiteTrack.savedVariables.bwlabelleft == nil then
	BiteTrack.savedVariables.bwlabelleft = BladeOfWoeIndicatorSezLabel:GetLeft()
  end
  
  if BiteTrack.savedVariables.bwlabeltop == nil then
	BiteTrack.savedVariables.bwlabeltop = BladeOfWoeIndicatorSezLabel:GetTop()
  end
  
  if BiteTrack.savedVariables.bwnumberleft == nil then
	BiteTrack.savedVariables.bwnumberleft = BladeOfWoeIndicatorLabel:GetLeft()
  end
  
  if BiteTrack.savedVariables.bwnumbertop == nil then
	BiteTrack.savedVariables.bwnumbertop = BladeOfWoeIndicatorLabel:GetTop()
  end
  
  -- times fed thing
  TimesFedIndicatorSezLabel:ClearAnchors()
  TimesFedIndicatorSezLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BiteTrack.savedVariables.tflabelleft, BiteTrack.savedVariables.tflabeltop)	
  
  TimesFedIndicatorLabel:ClearAnchors()
  TimesFedIndicatorLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BiteTrack.savedVariables.tfnumberleft, BiteTrack.savedVariables.tfnumbertop)
  
  -- blade of woe thing
  BladeOfWoeIndicatorSezLabel:ClearAnchors()
  BladeOfWoeIndicatorSezLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BiteTrack.savedVariables.bwlabelleft, BiteTrack.savedVariables.bwlabeltop)	
  
  BladeOfWoeIndicatorLabel:ClearAnchors()
  BladeOfWoeIndicatorLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BiteTrack.savedVariables.bwnumberleft, BiteTrack.savedVariables.bwnumbertop)
	
  -- initialize slash commandsss
  SLASH_COMMANDS["/btstats"] = BiteTrack.btstats
  
end

function BiteTrack.onActionSlotAbilityUsed(eventCode,slotNum)
	local abilityId = GetSlotBoundId(slotNum)
end

function BiteTrack.CombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,log,sourceUnitId,targetUnitId,abilityId,overflow)
	--CHAT_SYSTEM:AddMessage("abilityName: " .. abilityName)
	if abilityName == "Blade of Woe" then
		--CHAT_SYSTEM:AddMessage("abilityName: " .. abilityName .. " sourceName: " .. sourceName .. "eventCode: " .. eventCode)
		if not BiteTrack.bladeOfWoe then
			BiteTrack.bladeOfWoe = 0
		end
		BiteTrack.bladeOfWoe = BiteTrack.bladeOfWoe + 0.2
		BiteTrack.savedVariables[BiteTrack.characterId].bladeOfWoe = BiteTrack.bladeOfWoe
		BladeOfWoeIndicatorLabel:SetText(math.floor(BiteTrack.bladeOfWoe))
		--BladeOfWoeIndicator:SetHidden(false)
	end
end

function BiteTrack.OnEffectChanged(eventCode,changeType,effectSlot,effectName,unitTag,beginTimeSec,endTimeSec,stackCount,iconName,buffType,
  effectType,abilityType,statusEffectType,unitName,unitId,abilityId,sourceType)
 
 if changeType == EFFECT_RESULT_GAINED then
	local zoneX
	local zoneY
	zoneX, zoneY = GetMapPlayerPosition("player")
	--CHAT_SYSTEM:AddMessage("X: " .. zoneX .. " Y:" .. zoneY)
	--CHAT_SYSTEM:AddMessage("abilityId: " .. abilityId .. " effectName:" .. effectName)
	for index, value in ipairs(vampireStages) do
		if value == vampireStages[index] and value == abilityId then
			-- if we gained it as a result of a zone change we'll ignore it, but clear that we changed zones
			if BiteTrack.savedVariables.zoneChanged ~= nil and BiteTrack.savedVariables.zoneChanged then
				BiteTrack.savedVariables.zoneChanged = false
				return
			end 
			-- if we gained it as a result of a Corrupting Bloody Mara, ignore that
			if effectName == "Corrupting Bloody Mara" then
				return
			end
		-- we gained a vampire stage (or refreshed stage 4, same thing)
			--CHAT_SYSTEM:AddMessage("last effect id "  .. BiteTrack.lastVampStage)
			if BiteTrack.lastVampStage ~= 0 and abilityId >= BiteTrack.lastVampStage then
				-- we only count it as a feed if the effect increases or maintains the vampire stage
				-- we luck out that the abilityIds for the vampire stages are in ascending order
				BiteTrack.timesFed = BiteTrack.timesFed + 1
				BiteTrack.savedVariables[BiteTrack.characterId].timesFed = BiteTrack.timesFed
				TimesFedIndicatorLabel:SetText(BiteTrack.timesFed)
				-- this is kind of a hack to prevent zone changes from increasing the feed count
				-- since from my testing the effect fade always happens before the effect gain, this should work
				BiteTrack.lastVampStage = 0
			end
		end
	end
  end
  if changeType == EFFECT_RESULT_FADED then
	--CHAT_SYSTEM:AddMessage("effect ended: " .. abilityId .. " " .. effectName)	
	for index, value in ipairs(vampireStages) do
		if value == vampireStages[index] and value == abilityId then
		-- we lost a vampire stage - this could be due to timing out, basin of loss, or advancing to the next stage
			BiteTrack.lastVampStage = abilityId
			--CHAT_SYSTEM:AddMessage("(faded) last effect id "  .. BiteTrack.lastVampStage)
		end
	end
  end
end

function BiteTrack.OnPlayerCombatState(event, combat)
	if combat then
		BiteTrack.inCombat = true
		return
	else
		BiteTrack.inCombat = false
	end
end

function BiteTrack.OnIndicatorMoveStop(indicator)
	--CHAT_SYSTEM:AddMessage("indicator " .. indicator)
	if indicator == "timesFedLabel" then
		BiteTrack.savedVariables.tflabelleft = TimesFedIndicatorSezLabel:GetLeft()
		BiteTrack.savedVariables.tflabeltop = TimesFedIndicatorSezLabel:GetTop()
	elseif indicator == "timesFedNumber" then
		BiteTrack.savedVariables.tfnumberleft = TimesFedIndicatorLabel:GetLeft()
		BiteTrack.savedVariables.tfnumbertop = TimesFedIndicatorLabel:GetTop()
	elseif indicator == "bladeOfWoeLabel" then
		BiteTrack.savedVariables.bwlabelleft = BladeOfWoeIndicatorSezLabel:GetLeft()
		BiteTrack.savedVariables.bwlabeltop = BladeOfWoeIndicatorSezLabel:GetTop()
	elseif indicator == "bladeOfWoeNumber" then
		BiteTrack.savedVariables.bwnumberleft = BladeOfWoeIndicatorLabel:GetLeft()
		BiteTrack.savedVariables.bwnumbertop = BladeOfWoeIndicatorLabel:GetTop()
	end
end

function BiteTrack.btstats(extra)
	local options = {}
    local searchResult = { string.match(extra,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	--CHAT_SYSTEM:AddMessage("string: " .. extra .. " :options #" .. #options)
	
	if #options == 0 then
		CHAT_SYSTEM:AddMessage("Times Fed: " .. BiteTrack.timesFed)
		CHAT_SYSTEM:AddMessage("Blades of Woe: " .. BiteTrack.bladeOfWoe)
	elseif options[1] == "reset" and options[2] == "all" then
		-- reset all character stats
		
		-- bites
		BiteTrack.timesFed = 0
		BiteTrack.savedVariables[BiteTrack.characterId].timesFed = 0
		TimesFedIndicatorLabel:SetText(BiteTrack.timesFed)
		
		--blade of woe
		BiteTrack.bladeOfWoe = 0
		BiteTrack.savedVariables[BiteTrack.characterId].bladeOfWoe = 0
		BladeOfWoeIndicatorLabel:SetText(math.floor(BiteTrack.bladeOfWoe))
	elseif options[1] == "reset" and options[2] == "bow" then
		--blade of woe
		BiteTrack.bladeOfWoe = 0
		BiteTrack.savedVariables[BiteTrack.characterId].bladeOfWoe = 0
		BladeOfWoeIndicatorLabel:SetText(math.floor(BiteTrack.bladeOfWoe))
	elseif options[1] == "reset" and options[2] == "bite" then
		BiteTrack.timesFed = 0
		BiteTrack.savedVariables[BiteTrack.characterId].timesFed = 0
		TimesFedIndicatorLabel:SetText(BiteTrack.timesFed)
	elseif options[1] == "add" and options[2] == "bite" then
		BiteTrack.timesFed = BiteTrack.timesFed + 1
		BiteTrack.savedVariables[BiteTrack.characterId].timesFed = BiteTrack.timesFed
		TimesFedIndicatorLabel:SetText(BiteTrack.timesFed)
	elseif options[1] == "subtract" and options[2] == "bite" then
		BiteTrack.timesFed = BiteTrack.timesFed - 1
		BiteTrack.savedVariables[BiteTrack.characterId].timesFed = BiteTrack.timesFed
		TimesFedIndicatorLabel:SetText(BiteTrack.timesFed)
	elseif options[1] == "add" and options[2] == "bow" then
		BiteTrack.bladeOfWoe = BiteTrack.bladeOfWoe+ 1
		BiteTrack.savedVariables[BiteTrack.characterId].bladeOfWoe = BiteTrack.bladeOfWoe
		BladeOfWoeIndicatorLabel:SetText(math.floor(BiteTrack.bladeOfWoe))
	elseif options[1] == "subtract" and options[2] == "bow" then
		BiteTrack.bladeOfWoe = BiteTrack.bladeOfWoe - 1
		BiteTrack.savedVariables[BiteTrack.characterId].bladeOfWoe = BiteTrack.bladeOfWoe
		BladeOfWoeIndicatorLabel:SetText(math.floor(BiteTrack.bladeOfWoe))
	elseif options[1] == "hide" and options[2] == "bite" then
		TimesFedIndicator:SetHidden(true)
	elseif options[1] == "hide" and options[2] == "bow" then
		BladeOfWoeIndicator:SetHidden(true)
	elseif options[1] == "show" and options[2] == "bite" then
		TimesFedIndicator:SetHidden(false)
	elseif options[1] == "show" and options[2] == "bow" then
		BladeOfWoeIndicator:SetHidden(false)
	elseif options[1] == "recheck" then
		local numBuffs = GetNumBuffs("player")
		for i = 0, numBuffs, 1 do
			local buffName,timeStarted,timeEnding,buffSlot,stackCount,textureName,buffType,effectType,abilityType,statusEffectType,abilityIdOfPlayerBuff,_ = GetUnitBuffInfo("player", i)
			CHAT_SYSTEM:AddMessage("abilityIdOfPlayerBuff: " .. abilityIdOfPlayerBuff .. " buffName: " .. buffName)
			for index, value in ipairs(vampireStages) do
				if value == abilityIdOfPlayerBuff then
					-- we are a vampire
					BiteTrack.isVampire = true
					CHAT_SYSTEM:AddMessage("we are a vampire")
					BiteTrack.savedVariables[BiteTrack.characterId].isVampire = true
					-- and we don't really care about any other buffs so
					break
				end
			end
		end
	end
end

EVENT_MANAGER:RegisterForEvent(BiteTrack.name, EVENT_ADD_ON_LOADED, BiteTrack.OnAddOnLoaded)