----------------------------------------
--[[ ESOA ]]-- 
----------------------------------------
-- INTERNAL Implementation API
-- Data Legacy 
-- Load/Save Data from ESOA saved variables (not Datastore)
----------------------------------------


------------------------------
-- 
local SLOT_TYPE_REV = {
  EQUIP_SLOT_HEAD      = "Head",
  EQUIP_SLOT_NECK      = "Neck",
  EQUIP_SLOT_SHOULDERS = "Shoulders",
  EQUIP_SLOT_CHEST     = "Chest",
  EQUIP_SLOT_WAIST     = "Waist",
  EQUIP_SLOT_WRIST     = "Wrist",
  EQUIP_SLOT_FEET      = "Feet", --9
  EQUIP_SLOT_HAND      = "Hand",
  EQUIP_SLOT_LEGS      = "Legs",
  
  EQUIP_SLOT_BACKUP_MAIN   = "ScndMain",
  EQUIP_SLOT_BACKUP_OFF    = "ScndOff",
  EQUIP_SLOT_BACKUP_POISON = "ScndPoison",
  EQUIP_SLOT_OFF_HAND      = "OffHand",
  EQUIP_SLOT_POISON        = "MainPoison",
  EQUIP_SLOT_MAIN_HAND     = "MainHand",
  EQUIP_SLOT_RANGED        = "Ranged",
  
  EQUIP_SLOT_CLASS1  = "Class1",
  EQUIP_SLOT_CLASS2  = "Class2",
  EQUIP_SLOT_CLASS3  = "Class3",
  EQUIP_SLOT_COSTUME = "Costume",
  
  EQUIP_SLOT_RING1 = "Ring1",
  EQUIP_SLOT_RING2 = "Ring2",
  
  EQUIP_SLOT_NONE = "None",
}

------------------------------
-- MAIN call that calls other functions ot populate PLAYER Data
-- When not fully converted to Datastore!
--Load missing data into: ElderScrollsOfAlts.view.playerLines
function ElderScrollsOfAlts:SetupGuiPlayerLinesDSpre()
	--
	local accountname = GetDisplayName()
	local skipLegacyLoad = false
	if( ElderScrollsOfAlts.view.selectedAccount ~= nil ) then
		if( accountname~=ElderScrollsOfAlts.view.selectedAccount ) then
			skipLegacyLoad = true
			ElderScrollsOfAlts.outputMsg("Info: Can't Load Legacy characters from a different account, skipping them.")
			--return
		end
	end
	--TODO bankspaces ?
	--
	local pCount = 0
	-- Load from ESOA if not alrady in VIEW (via datastore)
	for k, v in pairs(ElderScrollsOfAlts.altData.players) do
		if k == nil then return end
		if(skipLegacyLoad) then
			ElderScrollsOfAlts.outputMsg("Info: --Skipping Load of Legacy character: ",tostring(k) )
		else
			ElderScrollsOfAlts.debugMsg("SetupLinePre: Checking player: '" , k , "'")
			pCount = pCount+1
			--
			if( ElderScrollsOfAlts.view.playerLines[k] == nil )  then
				ElderScrollsOfAlts.debugMsg("SetupLinePre: player: '" , k , "'")
				ElderScrollsOfAlts.view.playerLines[k] = {}
				ElderScrollsOfAlts:SetupGuiPlayerLinesForK( ElderScrollsOfAlts.view.playerLines,k )
			else
				--TODO destroy ESOA data????
				ElderScrollsOfAlts.altData.players[k] = nil
			end
		end
		-- CHECK Data
	end --for pairs(ElderScrollsOfAlts.altData.players)
	ElderScrollsOfAlts.view.legacyLoadCount = pCount
	-- PlayerLines to table
end

------------------------------
-- MAIN call that calls other functions ot populate PLAYER Data
function ElderScrollsOfAlts:SetupGuiPlayerLines()
	ElderScrollsOfAlts.debugMsg("SetupGuiPlayerLines: Called Legacy")
	--local timeTotalStart = GetFrameTimeSeconds()
	--ElderScrollsOfAlts.debugMsg("timeTotalStart: " .. tostring(timeTotalStart) )
	--
	ElderScrollsOfAlts.view.accountData = {}
	ElderScrollsOfAlts.view.accountData.secondsplayed = 0
	--TODO bankspaces
	--
	local playerLines =  {}
	--table.insert(playerLines, "Select")
	local pCount = 0
	for k, v in pairs(ElderScrollsOfAlts.altData.players) do
		if k == nil then return end
		ElderScrollsOfAlts.debugMsg(" players " .. k)
		ElderScrollsOfAlts:SetupGuiPlayerLinesForK(playerLines,k)
		--
		pCount = pCount+1
	end--for k, v in pairs(ElderScrollsOfAlts.altData.players) do
	--
	-- PlayerLines to table
	table.sort(playerLines)  
	ElderScrollsOfAlts.view.maxPlayerLineCount = pCount
	--local timeTotalEnd = GetFrameTimeSeconds()
	--local timeTotalDiff = GetDiffBetweenTimeStamps(timeTotalStart, timeTotalEnd)
	--ElderScrollsOfAlts.debugMsg("timeTotalStart: " .. tostring(timeTotalStart) .. " timeTotalEnd:" .. tostring(timeTotalEnd) )
	--ElderScrollsOfAlts.debugMsg("ESOA.SAVE timeTotalDiff=".. tostring(timeTotalDiff) )
	return playerLines
end

------------------------------
-- Companions
function ElderScrollsOfAlts:CollectCompanionDataInitLegacy(playerKey, companionId, cname)
  if ElderScrollsOfAlts.altData.players == nil then
		ElderScrollsOfAlts.altData.players = {}
	end
  if( ElderScrollsOfAlts.altData.players[playerKey] == nil ) then
    ElderScrollsOfAlts.altData.players[playerKey] = {}
  end
  ElderScrollsOfAlts.debugMsg("companion save data: companionId: '", companionId, "' as '", cname, "'" )
  ----Section: Save section
  if( ElderScrollsOfAlts.altData.players[playerKey].companions == nil ) then
    ElderScrollsOfAlts.altData.players[playerKey].companions = {}
    ElderScrollsOfAlts.altData.players[playerKey].companions.ids  = {}
    ElderScrollsOfAlts.altData.players[playerKey].companions.data = {}
  end
  if( ElderScrollsOfAlts.altData.players[playerKey].companions.ids[companionId] == nil ) then
    ElderScrollsOfAlts.altData.players[playerKey].companions.ids[companionId] = companionId
  end
  if( ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId] == nil ) then
    ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId] = {}
  end
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].id      = companionId
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].name    = zo_strformat("<<X:1>>", cname )
  
  ElderScrollsOfAlts.debugMsg("companion save data: companionId: '", companionId, "' fixed as '", zo_strformat("<<X:1>>", cname ), "'" )
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataLevelLegacy(companionId, cname, level, currentExperience, experienceForLevel)
  ElderScrollsOfAlts.debugMsg("CollectCompanionDataLevel: called")
  ----Section: Statup section
  --local pID       = GetCurrentCharacterId()
  --local pServer   = GetWorldName()
  --local playerKey = pID.."_".. pServer:gsub(" ","_")
  local playerKey = ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
  --
  ElderScrollsOfAlts:CollectCompanionDataInitLegacy(playerKey, companionId, cname)
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].level             = level
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].currentExperience = currentExperience
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].experienceForLevel = experienceForLevel
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataSkillRankLegacy(companionId, cname, skillLineId, slName, rank )
  ElderScrollsOfAlts.debugMsg("CollectCompanionDataSkillRank: called")
  ----Section: Statup section
  --local pID       = GetCurrentCharacterId()
  --local pServer   = GetWorldName()
  --local playerKey = pID.."_".. pServer:gsub(" ","_")
  local playerKey = ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
  --
  ElderScrollsOfAlts:CollectCompanionDataInitLegacy(playerKey, companionId, cname)
  ElderScrollsOfAlts:CollectCompanionDataSkillLine(companionId, cname, skillLineId, slName )
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].skillline[skillLineId].rank = rank
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataSkillLineLegacy(companionId, cname, skillLineId, slName )
  ElderScrollsOfAlts.debugMsg("CollectCompanionDataSkillLine: called")
  ----Section: Statup section
  --local pID       = GetCurrentCharacterId()
  --local pServer   = GetWorldName()
  --local playerKey = pID.."_".. pServer:gsub(" ","_")
  local playerKey = ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
  --
  ElderScrollsOfAlts:CollectCompanionDataInitLegacy(playerKey, companionId, cname)
  if( ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].skillline == nil) then
    ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].skillline = {}
  end
  if( ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].skillline[skillLineId] == nil ) then
      ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].skillline[skillLineId] = {}
  end
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].skillline[skillLineId].id   = skillLineId
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].skillline[skillLineId].name = slName
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataRapportLegacy(companionId, cname, currentRapport)
  ElderScrollsOfAlts.debugMsg("CollectCompanionDataRapport: called")
  ----Section: Statup section
  --local pID       = GetCurrentCharacterId()
  --local pServer   = GetWorldName()
  --local playerKey = pID.."_".. pServer:gsub(" ","_")
  local playerKey = ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
  --
  ElderScrollsOfAlts:CollectCompanionDataInitLegacy(playerKey, companionId, cname)
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].id      = companionId
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].name    = cname
  ElderScrollsOfAlts.altData.players[playerKey].companions.data[companionId].rapport = currentRapport
end


------------------------------
-- 
function ElderScrollsOfAlts.SavePlayerDataLegacy( playerLineKey, keyName, elementData )	
	if(ElderScrollsOfAlts.altData.players==nil) then
		return
	end
	if( ElderScrollsOfAlts.altData.players[playerLineKey] ~= nil ) then
		ElderScrollsOfAlts.altData.players[playerLineKey][keyName] = elementData
		ElderScrollsOfAlts.debugMsg("SavePlayerData: player=",playerLineKey," keyName=",keyName," as ", elementData) 
	end
end

------------------------------
-- 
function ElderScrollsOfAlts:InitTrackingDataLegacy(trackingType,trackingName)
   ----Section: Statup section
  --local pID       = GetCurrentCharacterId()
  --local pServer   = GetWorldName()
  --local playerKey =  zo_strformat("<<1>>_<<2>>", pID, pServer:gsub(" ","_") )
  local playerKey = ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
  ----Section: Save section
	if ElderScrollsOfAlts.altData.players == nil then
		ElderScrollsOfAlts.altData.players = {}
	end
  if( ElderScrollsOfAlts.altData.players[playerKey] == nil ) then
    ElderScrollsOfAlts.altData.players[playerKey] = {}
  end
  if( ElderScrollsOfAlts.altData.players[playerKey].tracking == nil ) then
    ElderScrollsOfAlts.altData.players[playerKey].tracking = {}
  end
  if( ElderScrollsOfAlts.altData.players[playerKey].tracking[trackingType] == nil ) then
    ElderScrollsOfAlts.altData.players[playerKey].tracking[trackingType] = {}
  end
  if( ElderScrollsOfAlts.altData.players[playerKey].tracking[trackingType][trackingName] == nil ) then
    ElderScrollsOfAlts.altData.players[playerKey].tracking[trackingType][trackingName] = {}
  end
  return ElderScrollsOfAlts.altData.players[playerKey].tracking[trackingType][trackingName]
end

--
function ElderScrollsOfAlts:CollectCPLegacy()
  ElderScrollsOfAlts.debugMsg("CollectCP: called")
  ----Section: Statup section
  --local pID       = GetCurrentCharacterId()
  --local pServer   = GetWorldName()
  --local playerKey = pID.."_".. pServer:gsub(" ","_")
  local playerKey = ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
  --local timeTotalStart = GetFrameTimeSeconds()
  --ElderScrollsOfAlts.debugMsg("timeTotalStart: " .. tostring(timeTotalStart) )
  
  --debugMsg("pName='"..tostring(pName).."'" )
  if ElderScrollsOfAlts.altData.players == nil then
		ElderScrollsOfAlts.altData.players = {}
  end
  if( ElderScrollsOfAlts.altData.players[playerKey] == nil ) then
    ElderScrollsOfAlts.altData.players[playerKey] = {}
  end
  
  ----Section: Collect section
  --if( ElderScrollsOfAlts.altData.players[playerKey] ~= nil ) then
  --end  
  
  ----Section: Save section
  if( ElderScrollsOfAlts.altData.players[playerKey] ~= nil ) then
    ElderScrollsOfAlts.altData.players[playerKey].championpointsactive = {}
    
    --d("[start] TestCP...")
    local CP = CHAMPION_PERKS
    local championBar = CHAMPION_PERKS:GetChampionBar() 
    local CPData = CHAMPION_DATA_MANAGER
    
    local start, nd = GetAssignableChampionBarStartAndEndSlots() -- 1 and 12.
    for i=start, nd do -- loop all 12 slots.
	local starId = GetSlotBoundId(i, HOTBAR_CATEGORY_CHAMPION)
	local req = GetRequiredChampionDisciplineIdForSlot(i, HOTBAR_CATEGORY_CHAMPION)
	local disType = GetChampionDisciplineType(req)
	
	if starId ~= 0 then
		local pointsSpent = GetNumPointsSpentOnChampionSkill(starId)
		local name = GetChampionSkillName(starId)
		ElderScrollsOfAlts.altData.players[playerKey].championpointsactive[i] = {}
		ElderScrollsOfAlts.altData.players[playerKey].championpointsactive[i].id = starId
		ElderScrollsOfAlts.altData.players[playerKey].championpointsactive[i].name = name
		ElderScrollsOfAlts.altData.players[playerKey].championpointsactive[i].disciplineid = req
		ElderScrollsOfAlts.altData.players[playerKey].championpointsactive[i].disciplinetype = disType
		ElderScrollsOfAlts.altData.players[playerKey].championpointsactive[i].numspentpoints = pointsSpent
	end
    end
    
    --xxx
    ElderScrollsOfAlts.altData.players[playerKey].championpoints = {}
    local numDisciplines = GetNumChampionDisciplines()
    --d("numDisciplines: " .. tostring(numDisciplines) )
    for disciplineIndex = 1, numDisciplines do
      ElderScrollsOfAlts.altData.players[playerKey].championpoints[disciplineIndex] = {}
      ElderScrollsOfAlts.altData.players[playerKey].championpoints[disciplineIndex].name = GetChampionDisciplineName(disciplineIndex)
      --ElderScrollsOfAlts.altData.players[playerKey].championpoints[disciplineIndex].id = disciplineIndex
      for championSkillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
        local championSkillId = GetChampionSkillId(disciplineIndex, championSkillIndex)
        --local numPendingPoints =  GetNumPendingChampionPoints(disciplineIndex, championSkillIndex)
        local ptsspent  = GetNumPointsSpentOnChampionSkill(championSkillId)
        if(ptsspent>0) then
          local championSkillType = GetChampionSkillType(championSkillId)
          local isSlottable       = ElderScrollsOfAlts:CheckIfCpTypeIsSlottable( championSkillType )
          if(isSlottable) then
            local name      = GetChampionSkillName(championSkillId)
            local abilityId = GetChampionAbilityId(championSkillId)
            ElderScrollsOfAlts.altData.players[playerKey].championpoints[disciplineIndex][championSkillId] = {}
            --ElderScrollsOfAlts.altData.players[playerKey].championpoints[disciplineIndex][championSkillId].pts = numPendingPoints
            ElderScrollsOfAlts.altData.players[playerKey].championpoints[disciplineIndex][championSkillId].name      = name
            ElderScrollsOfAlts.altData.players[playerKey].championpoints[disciplineIndex][championSkillId].ptsspent  = ptsspent
            ElderScrollsOfAlts.altData.players[playerKey].championpoints[disciplineIndex][championSkillId].abilityId = abilityId
            
            --d("championSkillId: " .. tostring(championSkillId) )
            --local championSkillData = ZO_ChampionSkillData:New(self, skillIndex)
            --d("championSkillData: " .. tostring(championSkillData) )
            --if championSkillData:IsClusterRoot() then
            --   table.insert(self.championClusterDatas, ZO_ChampionClusterData:New(championSkillData))
            --end
            --self.championSkillDatas[skillIndex] = championSkillData
          end
        end--spent points
      end
    end
    --d("TestCP...[end]")
  end -- if player line exists
  ElderScrollsOfAlts.debugMsg("CollectCP: done")
end
--CollectCP()


--loadPlayerEquipment
function ElderScrollsOfAlts:SavaDataPlayerEquipment(playerKey)
  --local pName = GetUnitName("player")
  ElderScrollsOfAlts.altData.players[playerKey].items = {}
  ElderScrollsOfAlts.altData.players[playerKey].equip = {}
    
  ElderScrollsOfAlts.altData.players[playerKey].equip.slots = {}
  local elemH = ElderScrollsOfAlts.altData.players[playerKey].equip.slots
  for slotId = 0, GetBagSize(BAG_WORN) do    
  	local itemName = GetItemName(BAG_WORN, slotId)
    --quality is numeric
    local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(BAG_WORN, slotId)
    local itemId = GetItemInstanceId(BAG_WORN, slotId)
    local itemLink = GetItemLink(BAG_WORN, slotId)--, number LinkStyle linkStyle) 
	local itemLevel = GetItemLevel(BAG_WORN, slotId)
    if( equipType ~= nil and equipType > EQUIP_TYPE_MIN_VALUE ) then
      --TODO check itemname not nil, and EquipType > 0
      elemH[slotId] = {}
      elemH[slotId].itemId   = itemId
      elemH[slotId].itemName = itemName
      elemH[slotId].itemLink = itemLink
      elemH[slotId].icon = icon
      elemH[slotId].quality = quality
      elemH[slotId].itemStyleId = itemStyleId
      elemH[slotId].slotId    = slotId
      elemH[slotId].equipType = equipType
      elemH[slotId].equipLoc  = SLOT_TYPE_REV[slotId]
	  elemH[slotId].itemLevel = itemLevel
      --equipslot
      
      local itemType, specializedItemType = GetItemLinkItemType(itemLink)
      --Returns: number ItemType itemType, number SpecializedItemType specializedItemType 
      elemH[slotId].itemType = itemType
      elemH[slotId].specializedItemType = specializedItemType
      elemH[slotId].armorType = nil
      elemH[slotId].weaponType = nil

      if( itemType == ITEMTYPE_ARMOR ) then
        local armorType = GetItemLinkArmorType(itemLink)
        --Returns: number ArmorType armorType 
        elemH[slotId].armorType = armorType
      end
      if( itemType == ITEMTYPE_WEAPON ) then
        local weaponType = GetItemLinkWeaponType(itemLink)
        --Returns: number WeaponType weaponType 
        elemH[slotId].weaponType = weaponType
      end
    end
	end
end

--collectResearchData
function ElderScrollsOfAlts:SaveDataPlayerResearchData(tradeSkillType, keyProfName, dataResearchElem)
  dataResearchElem[keyProfName] = {}
  local researchMaxSimulSlots = GetMaxSimultaneousSmithingResearch(tradeSkillType)
  local researchNumlines      = GetNumSmithingResearchLines(tradeSkillType)
  dataResearchElem[keyProfName].ongoing = {}
  dataResearchElem[keyProfName].lines = {}
  dataResearchElem[keyProfName].researchNumlinesDone = 0
  dataResearchElem[keyProfName].researchNumlines      = researchNumlines
  dataResearchElem[keyProfName].researchMS            = researchMaxSimulSlots
  dataResearchElem[keyProfName].researchMaxSimulSlots = researchMaxSimulSlots
  dataResearchElem[keyProfName].researchNumlines      = researchNumlines
  --
  for researchLineIndex = 1, researchNumlines do
    local name, icon, numTraits, timeRequiredForNextResearchSecs = GetSmithingResearchLineInfo(tradeSkillType, researchLineIndex)
    --
    dataResearchElem[keyProfName].lines[name] = {}
    dataResearchElem[keyProfName].lines[name].name           = name
    dataResearchElem[keyProfName].lines[name].numTraits      = numTraits
    dataResearchElem[keyProfName].lines[name].numTraitsKnown = 0
    dataResearchElem[keyProfName].lines[name].researchLineIndex = researchLineIndex    
    dataResearchElem[keyProfName].lines[name].timeRequiredForNextResearchSecs = timeRequiredForNextResearchSecs    
    -- 
    for traitIndex = 1, numTraits do
      --local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(tradeSkillType, researchLineIndex, traitIndex)
      local durationSecs, timeRemainingSecs    = GetSmithingResearchLineTraitTimes(tradeSkillType, researchLineIndex, traitIndex)
      local traitType, traitDescription, known = GetSmithingResearchLineTraitInfo(tradeSkillType,  researchLineIndex, traitIndex)
      if(durationSecs~=nil) then
        local timeTillReady = GetTimeStamp() + timeRemainingSecs
        dataResearchElem[keyProfName].ongoing[name] = {}
        dataResearchElem[keyProfName].ongoing[name].name              = name
        dataResearchElem[keyProfName].ongoing[name].durationSecs      = durationSecs
        dataResearchElem[keyProfName].ongoing[name].timeRemainingSecs = timeRemainingSecs
        dataResearchElem[keyProfName].ongoing[name].timeTillReady     = timeTillReady
        dataResearchElem[keyProfName].ongoing[name].traitIndex        = traitIndex
        dataResearchElem[keyProfName].ongoing[name].researchLineIndex = researchLineIndex
        dataResearchElem[keyProfName].ongoing[name].traitType         = traitType
        dataResearchElem[keyProfName].ongoing[name].traitDescription  = traitDescription
        dataResearchElem[keyProfName].ongoing[name].known             = known
      end
      if(known) then
        dataResearchElem[keyProfName].lines[name].numTraitsKnown = dataResearchElem[keyProfName].lines[name].numTraitsKnown + 1
      end
    end
    if( numTraits == dataResearchElem[keyProfName].lines[name].numTraitsKnown ) then
      dataResearchElem[keyProfName].researchNumlinesDone = dataResearchElem[keyProfName].researchNumlinesDone + 1
    end
  end -- research
  --[[ TODO: get num traints known?
  for i = 1, GetMaxTraits() do
    local known, name = GetItemLinkReagentTraitInfo(itemLink, i)
    if known then
      d(zo_strformat("Trait <<1>> is known; it's <<2>>.", i, name))
    end
     boolean known = IsSmithingTraitKnownForResult(number patternIndex, number materialIndex, number materialQuantity, number itemStyleId, number traitIndex)
  end
  number numTraitItems = GetNumSmithingTraitItems()
  Returns: number:nilable ItemTraitType traitType, string itemName, textureName icon, number sellPrice, boolean meetsUsageRequirement, number itemStyleId, number ItemQuality quality
  GetSmithingTraitItemInfo(number traitItemIndex)
Returns: string link = GetSmithingTraitItemLink(number traitItemIndex, number LinkStyle linkStyle)
  --]]
end

------------------------------
-- 
----------------------------------------
 --[[ ESOA Data Legacy ]]-- 
----------------------------------------