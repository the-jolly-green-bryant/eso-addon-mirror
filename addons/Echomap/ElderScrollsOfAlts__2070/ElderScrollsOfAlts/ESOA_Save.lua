----------------------------------------
--[[ ESOA UI ]]-- 
----------------------------------------
-- Save Player Data to Saved Variables
------------------------------------------ 


------------------------------
-- M1 : Solvent Proficiency, Metalworking, Tailoring, (Aspect Improvement, Potency Improvement), Recipe Quality, Recipe Improvement, Woodworking
ElderScrollsOfAlts.view.matchNameList1 = {GetString(ESOA_FULL_SUB_SOLV),  GetString(ESOA_FULL_SUB_METAL),  GetString(ESOA_FULL_SUB_TAIL),  GetString(ESOA_FULL_SUB_ASPIMP),  GetString(ESOA_FULL_SUB_RECQUA),  GetString(ESOA_FULL_SUB_WOOD),  GetString(ESOA_FULL_SUB_ENGRAV) }
-- M2 : Provisioning
ElderScrollsOfAlts.view.matchNameList2 = {GetString(ESOA_FULL_SUB_POTIMPR), GetString(ESOA_FULL_SUB_RECIMPR) }


------------------------------
-- 
-- Read all data from the game Player Object into this Addon
function ElderScrollsOfAlts.DataSaveLivePlayer2(loadtype)
  ElderScrollsOfAlts.debugMsg("DataSaveLivePlayer2: loadtype='"..tostring(loadtype).."'") 
  --ElderScrollsOfAlts.debugMsg( GetString(ESOA_MSG_ACTIVE)  )
  --
  ----Section: Statup section
  local pName     = GetUnitName("player")
  local rName     = GetRawUnitName("player")   
  local pID       = GetCurrentCharacterId()
  local pServer   = GetWorldName()
  local playerKey = pID.."_".. pServer:gsub(" ","_")
  ElderScrollsOfAlts.view.whoiamplayerKey = tostring(playerKey)
  ElderScrollsOfAlts.debugMsg("Set WhoamI: playerKey=",playerKey)
  --local timeTotalStart = GetFrameTimeSeconds()
  --ElderScrollsOfAlts.debugMsg("timeTotalStart: " .. tostring(timeTotalStart) )
  local pNow = GetTimeStamp()
  
  --debugMsg("pName='"..tostring(pName).."'" )
	if ElderScrollsOfAlts.altData.players == nil then
		ElderScrollsOfAlts.altData.players = {}
	end
  
  --[[ not callable here?
  ElderScrollsOfAlts.view.playersexisting = {}
  local numchars = ZO_AddOnManager:GetNumCharacters()
  for characterIndex = 1, numchars do
    --local name, _, _, _, _, _, characterId = GetCharacterInfo(i)
    local name, gender, level, championPoints, class, race, alliance, id, locationId, order, needsRename = GetCharacterInfo(characterIndex)
    ElderScrollsOfAlts.view.playersexisting[name] = {}
    ElderScrollsOfAlts.view.playersexisting[name].order = order
    ElderScrollsOfAlts.debugMsg("ESOA, playersexisting: '", ElderScrollsOfAlts.view.playersexisting[name] , "'")
  end
  --]]
  local dataToProtect = {
    "category", "championpointsactive", "championpoints", "tracking", "note", "companions", "playerscreenorder",
  }
  ElderScrollsOfAlts.view.tempsave = {}

  ----Section: Protect section
  --Protect data not loaded from player data API
  if( ElderScrollsOfAlts.altData.players[playerKey] ~= nil ) then
    ElderScrollsOfAlts.debugMsg("Checking preexisting data to preserve")
    --Protect note data if not saved to disk in this session
    --[[if( ElderScrollsOfAlts.altData.players[playerKey].note ~= nil  ) then
      ElderScrollsOfAlts.view.currentnote = ElderScrollsOfAlts.altData.players[playerKey].note
      ElderScrollsOfAlts.debugMsg("ESOA, saved current note, as '", tostring(ElderScrollsOfAlts.altData.players[playerKey].note) , "'")
    end--]]
    if( ElderScrollsOfAlts.altData.players[playerKey].playersorder ~= nil  ) then
      ElderScrollsOfAlts.view.currentorder = ElderScrollsOfAlts.altData.players[playerKey].playersorder
      ElderScrollsOfAlts.debugMsg("ESOA, saved current order, as '", tostring(ElderScrollsOfAlts.altData.players[playerKey].playersorder) , "'")
    else
      ElderScrollsOfAlts.altData.playersorderlast                = ElderScrollsOfAlts.altData.playersorderlast + 1
      ElderScrollsOfAlts.altData.players[playerKey].playersorder = ElderScrollsOfAlts.altData.playersorderlast
      ElderScrollsOfAlts.view.currentorder = ElderScrollsOfAlts.altData.players[playerKey].playersorder
      ElderScrollsOfAlts.debugMsg("ESOA, saved current order, as '", tostring(ElderScrollsOfAlts.altData.players[playerKey].playersorder) , "'")
    end
    --    
    for key,value in pairs(dataToProtect) do
      if( ElderScrollsOfAlts.altData.players[playerKey][value]~=nil ) then
        ElderScrollsOfAlts.view.tempsave[value] = ElderScrollsOfAlts.altData.players[playerKey][value]
        ElderScrollsOfAlts.debugMsg("ESOA, saved current '" .. value.."', as '", tostring(ElderScrollsOfAlts.altData.players[playerKey][value]) , "'") 
      end
    end
	if(ElderScrollsOfAlts.altData.players[playerKey].alliancewar~=nil) then -- TODO why this check as is new?
		ElderScrollsOfAlts.view.tempsave["AssignedCampaignRewardEarnedTier"]       = ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignRewardEarnedTier 
		ElderScrollsOfAlts.view.tempsave["AssignedCampaignRewardNextProgressTier"] = ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignRewardNextProgressTier
		ElderScrollsOfAlts.view.tempsave["AssignedCampaignRewardNextTotalTier"]    = ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignRewardNextTotalTier
		ElderScrollsOfAlts.view.tempsave["guestCampaignRewardEarnedTier"]          = ElderScrollsOfAlts.altData.players[playerKey].alliancewar.guestCampaignRewardEarnedTier
	end
  else
    ElderScrollsOfAlts.debugMsg("No preexisting data to preserve")
  end
  
  --
  ElderScrollsOfAlts.view.previousversion = nil
  if(ElderScrollsOfAlts.altData.players[playerKey] ~= nil and ElderScrollsOfAlts.altData.players[playerKey].version~=nil)then
    ElderScrollsOfAlts.view.previousversion = ElderScrollsOfAlts.altData.players[playerKey].version
  end
  
  --- Reset Old Data Format infavor of new format
  ElderScrollsOfAlts.altData.players[pName] = nil
  
  --- Initialize New Data Format (to reset all my data to current data)
  ElderScrollsOfAlts.altData.players[playerKey] = {}
  ElderScrollsOfAlts.altData.players[playerKey].category = "A"  
  ElderScrollsOfAlts.altData.players[playerKey].version = ElderScrollsOfAlts.version
  ElderScrollsOfAlts.altData.players[playerKey].previousversion = ElderScrollsOfAlts.view.previousversion

  ----Section: BIO section
	if ElderScrollsOfAlts.altData.players[playerKey].bio == nil then
		ElderScrollsOfAlts.altData.players[playerKey].bio = {}
	end  
  ElderScrollsOfAlts.altData.players[playerKey].bio.server  = pServer
  ElderScrollsOfAlts.altData.players[playerKey].bio.id      = pID
  ElderScrollsOfAlts.altData.players[playerKey].bio.name    = pName
  ElderScrollsOfAlts.altData.players[playerKey].bio.rawname = rName  
	local pGender = GetUnitGender("player")
	ElderScrollsOfAlts.altData.players[playerKey].bio.gender = pGender
	local pLvl = GetUnitLevel("player")
	ElderScrollsOfAlts.altData.players[playerKey].bio.level = pLvl
  local canChampPts = CanUnitGainChampionPoints("player")
  ElderScrollsOfAlts.altData.players[playerKey].bio.canchamppts = canChampPts  
  ElderScrollsOfAlts.altData.players[playerKey].bio.champion = nil
  if canChampPts then
    --TODO Not sure what effective level means
    --ElderScrollsOfAlts.altData.players[playerKey].bio.level    = GetUnitEffectiveLevel("player") 
    ElderScrollsOfAlts.altData.players[playerKey].bio.champion = GetUnitChampionPoints("player")   
  end
  local xpleft    = GetNumExperiencePointsInLevel(pLvl)
  if not xpleft then
    --d("You can't level up any further.")
  else
    ElderScrollsOfAlts.altData.players[playerKey].bio.xpleft = xpleft
    --d("It takes " .. xpleft .. " XP to get from the start of this level to the next level.")
  end
  ElderScrollsOfAlts.altData.players[playerKey].bio.unitxp    = GetUnitXP("player")
  ElderScrollsOfAlts.altData.players[playerKey].bio.unitxpmax = GetUnitXPMax("player")
	local pRace = GetUnitRace("player")
	ElderScrollsOfAlts.altData.players[playerKey].bio.race = pRace
	--GetUnitRaceId(string unitTag)
	local pClass = GetUnitClass("player")
	ElderScrollsOfAlts.altData.players[playerKey].bio.class = pClass
	local pClassId = GetUnitClassId("player")
	ElderScrollsOfAlts.altData.players[playerKey].bio.classId = pClassId
  local pAlliance = GetUnitAlliance("player")
  ElderScrollsOfAlts.altData.players[playerKey].bio.alliance = pAlliance

	--local value = GetPlayerStat(self.statType, STAT_BONUS_OPTION_APPLY_BONUS)
	if ElderScrollsOfAlts.altData.players[playerKey].stats == nil then
		ElderScrollsOfAlts.altData.players[playerKey].stats = {}
	end
  --Werewolf or Vampire
  ElderScrollsOfAlts.altData.players[playerKey].bio.Werewolf = false
  ElderScrollsOfAlts.altData.players[playerKey].bio.Vampire  = false

	local current, max, effectiveMax = GetUnitPower("player", POWERTYPE_STAMINA)
	ElderScrollsOfAlts.altData.players[playerKey].stats["stamina"] = max
	current, max, effectiveMax = GetUnitPower("player", POWERTYPE_HEALTH)
	ElderScrollsOfAlts.altData.players[playerKey].stats["health"] = max
	current, max, effectiveMax = GetUnitPower("player", POWERTYPE_MAGICKA)
	ElderScrollsOfAlts.altData.players[playerKey].stats["magicka"] = max
	current, max, effectiveMax = GetUnitPower("player", POWERTYPE_POWER)
	ElderScrollsOfAlts.altData.players[playerKey].stats["power"] = max
	--POWERTYPE_WEREWOLF
	--POWERTYPE_FERVOR
	--POWERTYPE_COMBO
	--POWERTYPE_CHARGES
	--POWERTYPE_MOUNT_STAMINA

  ----Section: Abilities/Skills section
	if ElderScrollsOfAlts.altData.players[playerKey].skills == nil then
		ElderScrollsOfAlts.altData.players[playerKey].skills = {}
	end
  local baseElem = nil
  local outputUndiscovered = false
  --
  skillType = SKILL_TYPE_ARMOR 
  outputUndiscovered = true
	ElderScrollsOfAlts.altData.players[playerKey].skills.armor = {}
	ElderScrollsOfAlts.altData.players[playerKey].skills.armor.typelist = {}
  baseElem = ElderScrollsOfAlts.altData.players[playerKey].skills.armor.typelist
  ElderScrollsOfAlts:SaveDataSkillData(skillType,baseElem,outputUndiscovered)
  --
  skillType = SKILL_TYPE_WORLD 
  outputUndiscovered = false
	ElderScrollsOfAlts.altData.players[playerKey].skills.world = {}
	ElderScrollsOfAlts.altData.players[playerKey].skills.world.typelist = {}
  baseElem = ElderScrollsOfAlts.altData.players[playerKey].skills.world.typelist
  ElderScrollsOfAlts:SaveDataSkillData(skillType,baseElem)
  --
  skillType = SKILL_TYPE_CLASS 
  outputUndiscovered = false
	ElderScrollsOfAlts.altData.players[playerKey].skills.class = {}
	ElderScrollsOfAlts.altData.players[playerKey].skills.class.typelist = {}
  baseElem = ElderScrollsOfAlts.altData.players[playerKey].skills.class.typelist
  ElderScrollsOfAlts:SaveDataSkillData(skillType,baseElem)
  --
  skillType = SKILL_TYPE_GUILD  
  outputUndiscovered = false
	ElderScrollsOfAlts.altData.players[playerKey].skills.guild = {}
	ElderScrollsOfAlts.altData.players[playerKey].skills.guild.typelist = {}
  baseElem = ElderScrollsOfAlts.altData.players[playerKey].skills.guild.typelist
  ElderScrollsOfAlts:SaveDataSkillData(skillType,baseElem)
  --
  skillType = SKILL_TYPE_RACIAL  
  outputUndiscovered = false
	ElderScrollsOfAlts.altData.players[playerKey].skills.racial = {}
	ElderScrollsOfAlts.altData.players[playerKey].skills.racial.typelist = {}
  baseElem = ElderScrollsOfAlts.altData.players[playerKey].skills.racial.typelist
  ElderScrollsOfAlts:SaveDataSkillData(skillType,baseElem)
  --
  skillType = SKILL_TYPE_WEAPON  
  outputUndiscovered = false
	ElderScrollsOfAlts.altData.players[playerKey].skills.weapon = {}
	ElderScrollsOfAlts.altData.players[playerKey].skills.weapon.typelist = {}
  baseElem = ElderScrollsOfAlts.altData.players[playerKey].skills.weapon.typelist
  ElderScrollsOfAlts:SaveDataSkillData(skillType,baseElem)
  --
  skillType = SKILL_TYPE_AVA  
  outputUndiscovered = false
	ElderScrollsOfAlts.altData.players[playerKey].skills.ava = {}
	ElderScrollsOfAlts.altData.players[playerKey].skills.ava.typelist = {}
  baseElem = ElderScrollsOfAlts.altData.players[playerKey].skills.ava.typelist
  ElderScrollsOfAlts:SaveDataSkillData(skillType,baseElem)
    
  --SKILL_TYPE_NONE TODO ?

  --
  skillType = SKILL_TYPE_TRADESKILL 
  outputUndiscovered = true
	ElderScrollsOfAlts.altData.players[playerKey].skills.trade = {}
	local baseTableElem = ElderScrollsOfAlts.altData.players[playerKey].skills.trade
	baseTableElem.typelist = {}
  baseTableElem.skills   = {}
  numSkillLines = GetNumSkillLines(skillType)
  for ii = 1, numSkillLines do
    --name, number rank, boolean discovered, number skillLineId, boolean advised, unlockText
		local name, rank, discovered, skillLineId, advised, unlockText = GetSkillLineInfo(skillType,ii)
		if name == nil then
			name = ii;
		end
    name = zo_strformat( "<<1>>", name ) -- get rid of links and junk?
		baseTableElem.typelist[name]	= {}
		local selElemTable = baseTableElem.typelist[name]
		local numAbilities = GetNumSkillAbilities(skillType, ii)
		selElemTable.name = name
		selElemTable.idx  = ii	
		selElemTable.rank = rank
    selElemTable.numAbilities = numAbilities
		selElemTable.skillLineId = skillLineId
    
    local lastRankXP, nextRankXP, currentXP  = GetSkillLineXPInfo( skillType, ii )
    selElemTable.lastRankXP = lastRankXP
    selElemTable.nextRankXP = nextRankXP
    selElemTable.currentXP  = currentXP
    
		ElderScrollsOfAlts.SaveDataPlayerTradeDetails( name, baseTableElem, selElemTable, skillType, ii, numAbilities )
	end
  --Check Specific Skilllines
  --ElderScrollsOfAlts.altData.players[playerKey].skills.world.typelist = {}
  --Werewolf or Vampire
  for key,value in pairs(ElderScrollsOfAlts.altData.players[playerKey].skills.world.typelist) do
    --print(key,value)
    if key == "Werewolf" then
      ElderScrollsOfAlts.altData.players[playerKey].bio.Werewolf = true
    elseif key == "Vampire" then
      ElderScrollsOfAlts.altData.players[playerKey].bio.Vampire = true
    end
  end  
  
 ----Section: Misc section
  if(ElderScrollsOfAlts.altData.players[playerKey].misc==nil) then
    ElderScrollsOfAlts.altData.players[playerKey].misc = {}
  end
  
  ElderScrollsOfAlts.altData.players[playerKey].misc.now = pNow --ZO_FormatClockTime()
  
  --Riding
  local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus =   GetRidingStats()
  ElderScrollsOfAlts.altData.players[playerKey].misc.riding = {}
  ElderScrollsOfAlts.altData.players[playerKey].misc.riding.inventory = inventoryBonus
  ElderScrollsOfAlts.altData.players[playerKey].misc.riding.stamina   = staminaBonus
  ElderScrollsOfAlts.altData.players[playerKey].misc.riding.speed     = speedBonus
  local canTrainRiding = false
  if(speedBonus < maxSpeedBonus)then
    canTrainRiding = true
  elseif (staminaBonus < maxStaminaBonus) then
    canTrainRiding = true
  elseif(inventoryBonus < maxInventoryBonus) then
    canTrainRiding = true
  end
  ElderScrollsOfAlts.altData.players[playerKey].misc.riding.cantrain = canTrainRiding   
  local timeMs, totalDurationMs = GetTimeUntilCanBeTrained()
  ElderScrollsOfAlts.altData.players[playerKey].misc.riding.timeMs          = timeMs
  ElderScrollsOfAlts.altData.players[playerKey].misc.riding.totalDurationMs = totalDurationMs
  ElderScrollsOfAlts.altData.players[playerKey].misc.riding.timeDataTaken   = pNow--secconds
  if(timeMs<1)then
    ElderScrollsOfAlts.altData.players[playerKey].misc.riding.trainingReadyAt  = 0
  else
    --ElderScrollsOfAlts.debugMsg("timeMs="..tostring(timeMs) )
    local expiresAt = pNow + ( timeMs/1000 )
    --local expiresAt = pNow + timeMs
    ElderScrollsOfAlts.altData.players[playerKey].misc.riding.trainingReadyAt  = expiresAt
  end
 
  -- Bags
  local bagSize = GetBagSize(BAG_BACKPACK) 
  local bagUsed = GetNumBagUsedSlots(BAG_BACKPACK)
  ElderScrollsOfAlts.altData.players[playerKey].misc.backpackSize = bagSize
  ElderScrollsOfAlts.altData.players[playerKey].misc.backpackUsed = bagUsed
  ElderScrollsOfAlts.altData.players[playerKey].misc.backpackFree = tonumber( bagSize-bagUsed )
  --
  ElderScrollsOfAlts.altData.players[playerKey].misc.skillpoints     = GetAvailableSkillPoints() 
  ElderScrollsOfAlts.altData.players[playerKey].misc.skillpointsfree = GetAvailableSkillPoints() 
  --ElderScrollsOfAlts.altData.players[playerKey].misc.skillpointstotal = GetAvailableSkillPoints() 
  ElderScrollsOfAlts.altData.players[playerKey].misc.secondsPlayed = GetSecondsPlayed()
  --GetUnitZone("player")
  local earnedAchievePts = GetEarnedAchievementPoints()
  ElderScrollsOfAlts.altData.players[playerKey].misc.achieve = {}
  ElderScrollsOfAlts.altData.players[playerKey].misc.achieve.earned = earnedAchievePts
  
  ----Section: Currency section
  if(ElderScrollsOfAlts.altData.players[playerKey].currency==nil) then
    ElderScrollsOfAlts.altData.players[playerKey].currency = {}
  end  
  local currType = {CURT_ALLIANCE_POINTS, CURT_CHAOTIC_CREATIA,CURT_CROWNS,CURT_CROWN_GEMS,CURT_MONEY,CURT_NONE,CURT_STYLE_STONES,CURT_TELVAR_STONES,CURT_WRIT_VOUCHERS}
  local cLoc = CURRENCY_LOCATION_CHARACTER
  for ctIdx = 1, #currType do
    local cType = currType[ctIdx]
    local amount = GetCurrencyAmount( cType, cLoc )
    local IS_PLURAL = false
    if(amount and amount>1) then IS_PLURAL = true end
    local currencyName = GetCurrencyName(cType, IS_PLURAL, false)
    ElderScrollsOfAlts.altData.players[playerKey].currency[cType] = {}
    ElderScrollsOfAlts.altData.players[playerKey].currency[cType].currencyName = currencyName
    ElderScrollsOfAlts.altData.players[playerKey].currency[cType].amount       = amount
  end
  
  ----Section: PVP section
  --PVP Ava Campaign Cyrodil PVP (TODO) --
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar = {}
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.inCampaign = IsInCampaign()
  
  local currentCampaignId  = GetCurrentCampaignId()--this not the best one?
  local guestCampaignId    = GetGuestCampaignId()
  local assignedCampaignId = GetAssignedCampaignId()
  local isInCampaign       = currentCampaignId ~= 0
  if(not isInCampaign) then
    isInCampaign       = assignedCampaignId ~= 0
  end
  --GetPreferredCampaign()  ??
 
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.guestCampaignId    = guestCampaignId
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.currentCampaignId  = currentCampaignId
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.assignedCampaignId = assignedCampaignId
  
  --ElderScrollsOfAlts.debugMsg("currentCampaignId="..tostring(currentCampaignId) )
  --ElderScrollsOfAlts.debugMsg("guestCampaignId="..tostring(guestCampaignId) )
  --d("(" .. ElderScrollsOfAlts.name .. ") " .. "guestCampaignId: "..guestCampaignId )
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.guestCampaignName    = GetCampaignName(guestCampaignId)
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.currentCampaignName  = GetCampaignName(currentCampaignId)
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.assignedCampaignName = GetCampaignName(assignedCampaignId)
  --ElderScrollsOfAlts.outputMsg("save.currentCampaignId="..tostring(currentCampaignId) )  
  --ElderScrollsOfAlts.outputMsg("save.currentCampaignName="..tostring( GetCampaignName(currentCampaignId) ) )  

  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.isInCampaign         = isInCampaign
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.unitAlliance         = pAlliance
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.allianceName         = GetAllianceName(pAlliance)
  
  local avaRank = GetUnitAvARank("player")
  local unitAvARankPoints = GetUnitAvARankPoints("player") 
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.unitAvARank       = avaRank  
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.unitAvARankPoints = unitAvARankPoints
  -- number subRankStartsAt, number nextSubRankAt, number rankStartsAt, number nextRankAt 
  local subRankStartsAt, nextSubRankAt, rankStartsAt, nextRankAt = GetAvARankProgress(unitAvARankPoints)
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AvaSubRankStart   = subRankStartsAt
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AvaNextSubRank    = nextSubRankAt
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AvaRankStarts     = rankStartsAt
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AvaNextRank       = nextRankAt
  
  local avaRankName = GetAvARankName( GetUnitGender("player"), avaRank )
  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.avaRankName = avaRankName
  
  --Returns: number earnedTier, number nextTierProgress, number nextTierTotal
  local readyState = LEADERBOARD_DATA_RESPONSE_PENDING
  readyState = QueryCampaignLeaderboardData(ALLIANCE_NONE) --pAlliance)
  if(readyState == LEADERBOARD_DATA_READY) then
	  local earnedTier, nextTierProgress, nextTierTotal = GetPlayerCampaignRewardTierInfo(assignedCampaignId)
	  ElderScrollsOfAlts.debugMsg( 
		  "earnedTier: '",         earnedTier,
		  "' nextTierProgress: '", nextTierProgress,
		  "' nextTierTotal: '",    nextTierTotal,"'" )
	  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignLastloaded = pNow
	  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignRewardEarnedTier       = tonumber(earnedTier)
	  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignRewardNextProgressTier = tonumber(nextTierProgress)
	  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignRewardNextTotalTier    = tonumber(nextTierTotal)
	  --ElderScrollsOfAlts.altData.players[playerKey].alliancewar.currentCampaignRewardEarnedTier = earnedTier  
	  earnedTier, nextTierProgress, nextTierTotal = GetPlayerCampaignRewardTierInfo(guestCampaignId)
	  ElderScrollsOfAlts.altData.players[playerKey].alliancewar.guestCampaignRewardEarnedTier = tonumber(earnedTier)
	  if(ElderScrollsOfAlts.view.alliancenotsaved) then
		ElderScrollsOfAlts.view.alliancenotsaved = false
		if(loadtype==nil or loadtype==ElderScrollsOfAlts.manualload or loadtype==ElderScrollsOfAlts.startupload ) then
			if( ElderScrollsOfAlts.CtrlIsShowPvpWarnings() ) then
				ElderScrollsOfAlts.outputMsg( GetString(ESOA_ALLIANCE_READY) )  
			end
		end
	  end
  else
    -- Put back old data
  	ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignRewardEarnedTier       = ElderScrollsOfAlts.view.tempsave["AssignedCampaignRewardEarnedTier"]       
	ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignRewardNextProgressTier = ElderScrollsOfAlts.view.tempsave["AssignedCampaignRewardNextProgressTier"]
	ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignRewardNextTotalTier    = ElderScrollsOfAlts.view.tempsave["AssignedCampaignRewardNextTotalTier"]    
	ElderScrollsOfAlts.altData.players[playerKey].alliancewar.guestCampaignRewardEarnedTier          = ElderScrollsOfAlts.view.tempsave["guestCampaignRewardEarnedTier"]          	
    -- show message if, alliance data wasn't saved before, and was a manual or startup call
	if(ElderScrollsOfAlts.view.alliancenotsaved==nil or ElderScrollsOfAlts.view.alliancenotsaved==true) then
		if(loadtype==nil or loadtype==ElderScrollsOfAlts.manualload or loadtype==ElderScrollsOfAlts.startupload ) then
			if( ElderScrollsOfAlts.CtrlIsShowPvpWarnings() ) then
				ElderScrollsOfAlts.outputMsg( GetString(ESOA_ALLIANCE_NOTREADY) )
			end
		end
	end
    ElderScrollsOfAlts.view.alliancenotsaved = true
  end
  --
  local avaAEnd = GetSecondsUntilCampaignEnd(assignedCampaignId)
  ElderScrollsOfAlts.debugMsg("avaAEnd: '", avaAEnd, "'")
  if(avaAEnd~=nil and avaAEnd<0) then
    ElderScrollsOfAlts.debugMsg("avaAEnded???: '", avaAEnd, "'")  
  elseif(avaAEnd~=nil and avaAEnd~=0) then
    ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignEndsSeconds = GetSecondsUntilCampaignEnd(assignedCampaignId)
    local AC_expiresAt = GetTimeStamp() + ( ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignEndsSeconds )
    ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignEndsAt = AC_expiresAt
    if(ElderScrollsOfAlts.altData.ava==nil) then
      ElderScrollsOfAlts.altData.ava = {}
      ElderScrollsOfAlts.altData.ava.campaigns = {}
    end
    ElderScrollsOfAlts.altData.ava.campaigns[assignedCampaignId] = {}
    ElderScrollsOfAlts.altData.ava.campaigns[assignedCampaignId].campaignEndsAt = AC_expiresAt
    ElderScrollsOfAlts.altData.ava.campaigns[assignedCampaignId].campaignId     = assignedCampaignId
    ElderScrollsOfAlts.debugMsg("avaAEnd saved to cache '", AC_expiresAt, "'")
  else
    if(ElderScrollsOfAlts.altData.ava~=nil and ElderScrollsOfAlts.altData.ava.campaigns ~= nil and  ElderScrollsOfAlts.altData.ava.campaigns[assignedCampaignId]~=nil and ElderScrollsOfAlts.altData.ava.campaigns[assignedCampaignId].campaignEndsAt~=nil) then
      ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignEndsAt = ElderScrollsOfAlts.altData.ava.campaigns[assignedCampaignId].campaignEndsAt
      ElderScrollsOfAlts.debugMsg("avaAEnd loaded from cache '", ElderScrollsOfAlts.altData.players[playerKey].alliancewar.AssignedCampaignEndsAt, "'")
    end
  end


  --GetLargeAvARankIcon(rank))
  --GetAllianceColor(alliance):UnpackRGBA())
  
  if not (isInCampaign or assignedCampaignId) then
    --no campaign
  else
    --TODO
    --local campaignName = GetCampaignName(campaignId)    
  end
    
  ----Section: Infamy/Bounty section
  --infamy = GetInfamy()
  --heat, bounty GetPlayerInfamyData()
  --infamyThresholdType = getInfamyLevel( infamy )
  -- INFMAY_THRESHHOLD_DISREPUTABLE, FUGITIVE, NOTOFIOUS, UPSTANDING  
  ElderScrollsOfAlts.altData.players[playerKey].infamy = {}
  local infamy = GetInfamy()
  local bounty = GetBounty()
  ElderScrollsOfAlts.debugMsg("infamy="..tostring(infamy) )
  local fullBountyPayoffAmount    = GetFullBountyPayoffAmount()
  local reducedBountyPayoffAmount = GetReducedBountyPayoffAmount()
  local infamyLevel     = GetInfamyLevel(infamy)
  local infamyLevelText = ElderScrollsOfAlts.getInfamyLevelText(infamyLevel)
  
  ElderScrollsOfAlts.altData.players[playerKey].infamy.displayText = infamyLevelText
  ElderScrollsOfAlts.altData.players[playerKey].infamy.infamy = infamy
  ElderScrollsOfAlts.altData.players[playerKey].infamy.bounty = bounty
  ElderScrollsOfAlts.altData.players[playerKey].infamy.fullBounty    = fullBountyPayoffAmount
  ElderScrollsOfAlts.altData.players[playerKey].infamy.reducedBounty = reducedBountyPayoffAmount

  local sBountyDecayZero = GetSecondsUntilBountyDecaysToZero()
  local sHeatDecayZero   = GetSecondsUntilHeatDecaysToZero()
  local now = GetTimeStamp() 
  
  --local timeTillReady = GetTimeStamp() + sBountyDecayZero
  ElderScrollsOfAlts.altData.players[playerKey].infamy.bountytozero = now + sBountyDecayZero
  ElderScrollsOfAlts.altData.players[playerKey].infamy.heattozero   = now + sHeatDecayZero

  --local thresholdType = getInfamyLevel( infamy )
  --local heat, bounty = GetPlayerInfamyData()
  --ElderScrollsOfAlts.altData.players[playerKey].infamy.payoffAmount  = payoffAmount  
  --ElderScrollsOfAlts.altData.players[playerKey].infamy.heat   = heat
  --ElderScrollsOfAlts.altData.players[playerKey].infamy.bounty = bounty  
  --ElderScrollsOfAlts.altData.players[playerKey].infamy.thresholdType = thresholdType  
  
  ----Section: Location section  
  ElderScrollsOfAlts.altData.players[playerKey].location = {}
  local subzoneNamePL = zo_strformat("<<1>>", GetPlayerActiveSubzoneName() )
  local zoneNamePL    = zo_strformat("<<1>>", GetPlayerActiveZoneName() )
  local zoneIndex     = GetUnitZoneIndex("player")
  local zoneId, worldX, worldY, worldZ   = GetUnitWorldPosition("player")  
  --local zDescription  =  GetZoneDescription(zoneIndex)
  --local zoneId        = GetZoneId(zoneIndex)
  ElderScrollsOfAlts.altData.players[playerKey].location.subzoneName = subzoneNamePL
  ElderScrollsOfAlts.altData.players[playerKey].location.zoneName    = zoneNamePL
  ElderScrollsOfAlts.altData.players[playerKey].location.zoneId      = zoneId
  
  --[[
  --local currLoc = {CURRENCY_LOCATION_ACCOUNT,CURRENCY_LOCATION_BANK,CURRENCY_LOCATION_CHARACTER,CURRENCY_LOCATION_GUILD_BANK}
  for clIdx = 1, #currLoc do 
    local cL = currLoc[clIdx]
    ElderScrollsOfAlts.altData.players[playerKey].currency[cL] = {}
    for ctIdx = 1, #currType do
      local cT = currType[ctIdx]
      local amount = GetCurrencyAmount( cT, cL )
      ElderScrollsOfAlts.altData.players[playerKey].currency[cL][cL] = amount
    end
  end 
  --]]

  ----Section: Equipment section
  ElderScrollsOfAlts:SavaDataPlayerEquipment(playerKey)
  
  --Research
  ElderScrollsOfAlts.altData.players[playerKey].research = {}  
  ElderScrollsOfAlts.altData.players[playerKey].research.now = GetTimeStamp()
  ElderScrollsOfAlts:SaveDataPlayerResearchData(CRAFTING_TYPE_BLACKSMITHING,   "blacksmithing",
        ElderScrollsOfAlts.altData.players[playerKey].research)
  ElderScrollsOfAlts:SaveDataPlayerResearchData(CRAFTING_TYPE_CLOTHIER,        "clothier", 
        ElderScrollsOfAlts.altData.players[playerKey].research)
  ElderScrollsOfAlts:SaveDataPlayerResearchData(CRAFTING_TYPE_WOODWORKING,     "woodworking",
        ElderScrollsOfAlts.altData.players[playerKey].research)
  ElderScrollsOfAlts:SaveDataPlayerResearchData(CRAFTING_TYPE_JEWELRYCRAFTING, "jewelcrafting",
        ElderScrollsOfAlts.altData.players[playerKey].research)
  
  ----Section: Bags/Bank section
  ElderScrollsOfAlts.altData.data = {}
  ElderScrollsOfAlts.altData.data.server = {}
  ElderScrollsOfAlts.altData.data.server[pServer] = {}
  
  local bagSizeB = GetBagSize(BAG_BACKPACK) 
  local bagUsedB = GetNumBagUsedSlots(BAG_BACKPACK)
  ElderScrollsOfAlts.altData.data.server[pServer].bankSize = bagSizeB
  ElderScrollsOfAlts.altData.data.server[pServer].bankUsed = bagUsedB
  ElderScrollsOfAlts.altData.data.server[pServer].bankFree = tonumber( bagSizeB-bagUsedB )
  
  ----Section: Protect section
  --Protect data not loaded from player data API
  --"category", "championpointsactive", "championpoints", "tracking", "note"
  for key,value in pairs(dataToProtect) do
    if( ElderScrollsOfAlts.view.tempsave[value] ~= nil ) then
      ElderScrollsOfAlts.altData.players[playerKey][value] = ElderScrollsOfAlts.view.tempsave[value]
      ElderScrollsOfAlts.debugMsg("ESOA, restored current '"..value.."', as '", tostring(ElderScrollsOfAlts.altData.players[playerKey][value]) ,"'")
    end
  end
  if( ElderScrollsOfAlts.view.currentorder ~= nil) then    
    ElderScrollsOfAlts.altData.players[playerKey].playersorder = ElderScrollsOfAlts.view.currentorder
    ElderScrollsOfAlts.debugMsg("ESOA, restored current order, as '", tostring(ElderScrollsOfAlts.altData.players[playerKey].playersorder) ,"'")
  end
  --[[
  if( ElderScrollsOfAlts.view.currentnote ~= nil) then    
    ElderScrollsOfAlts.altData.players[playerKey].note = ElderScrollsOfAlts.view.currentnote
    ElderScrollsOfAlts.debugMsg("ESOA, restored current note, as '", tostring(ElderScrollsOfAlts.altData.players[playerKey].note) ,"'")
  end
  if( ElderScrollsOfAlts.view.currentcategory ~= nil) then    
    ElderScrollsOfAlts.altData.players[playerKey].category = ElderScrollsOfAlts.view.currentcategory
    ElderScrollsOfAlts.debugMsg("ESOA, restored current category, as '", tostring(ElderScrollsOfAlts.altData.players[playerKey].category) ,"'")
  end
  if( ElderScrollsOfAlts.view.championpointsactive ~= nil) then    
    ElderScrollsOfAlts.altData.players[playerKey].championpointsactive = ElderScrollsOfAlts.view.championpointsactive
    ElderScrollsOfAlts.debugMsg("ESOA, restored current cp active, as '", tostring(ElderScrollsOfAlts.altData.players[playerKey].championpointsactive) ,"'")
  end
  if( ElderScrollsOfAlts.view.championpoints ~= nil) then    
    ElderScrollsOfAlts.altData.players[playerKey].championpoints = ElderScrollsOfAlts.view.championpoints
    ElderScrollsOfAlts.debugMsg("ESOA, restored current cp, as '", tostring(ElderScrollsOfAlts.altData.players[playerKey].championpoints) ,"'")
  end
  if( ElderScrollsOfAlts.view.tracking ~= nil) then    
    ElderScrollsOfAlts.altData.players[playerKey].tracking = ElderScrollsOfAlts.view.tracking
    ElderScrollsOfAlts.debugMsg("ESOA, restored current tracking, as '", tostring(ElderScrollsOfAlts.altData.players[playerKey].tracking) ,"'")
  end  
  --]]
  
  ----Section: Buffs section
  --BUFFS
  ElderScrollsOfAlts.altData.players[playerKey].buffs = {}  
  local numBuffs = GetNumBuffs("player") 
  for buffIndex = 1, numBuffs do
    --string buffName, number timeStarted, number timeEnding, number buffSlot, number stackCount, textureName iconFilename, string buffType, number BuffEffectType effectType, number AbilityType abilityType, number StatusEffectType statusEffectType, number abilityId, boolean canClickOff, boolean castByPlayer
    local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", buffIndex)
    ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName] = {}
    ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].timeStarted  = timeStarted 
    ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].timeEnding   = timeEnding
    ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].abilityId    = abilityId
    ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].iconFilename = iconFilename
    local duration = timeEnding - timeStarted
    ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].duration     = duration
    
    if(duration > 0) then
        local timeLeftS = (timeEnding) - GetFrameTimeSeconds() -- time end - time in frame is time left
        --data:SetCooldown(timeLeft, duration * 1000.0)
        ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].expiresAt = GetTimeStamp() + (timeLeftS)
    else
      ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].expiresAt = 0
    end
    --[[TODO TESTING
    if(ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].expiresAt~=0) then
      --Time in seconds left till expires
      local timeDiff = GetDiffBetweenTimeStamps( ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].expiresAt, GetTimeStamp() )
      ElderScrollsOfAlts.debugMsg("Buff Data: name: '".. buffName .. "' expires="..tostring(ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].expiresAt) .. " timeDiff=".. tostring(timeDiff) )
    end--]]
    --ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName].expiresAt = GetTimeStamp() + ( timeEnding-timeStarted )
    --[[
    if(buffName=="Major Protection")then
      d("Has Major Protection!****")
    elseif(buffName=="Minor Protection")then
      d("Has Minor Protection!****")
    else
      d("Has buff "..tostring(buffName))
    end
    --]]
  end--for buffs
  
  --STATS
  --ElderScrollsOfAlts:SaveDataPlayerStatsData(ElderScrollsOfAlts.altData.players[playerKey])

  ----Section: Special section
  if( ElderScrollsOfAlts.altData.players[playerKey].bio.Vampire == true) then
    ElderScrollsOfAlts.altData.players[playerKey].bio.specialdata = {}
    ElderScrollsOfAlts:SaveDataVampire( playerKey, ElderScrollsOfAlts.altData.players[playerKey].bio.specialdata )
  end
  if( ElderScrollsOfAlts.altData.players[playerKey].bio.Werewolf == true) then
    ElderScrollsOfAlts.altData.players[playerKey].bio.specialdata = {}
    ElderScrollsOfAlts:SaveDataWerewolf( playerKey, ElderScrollsOfAlts.altData.players[playerKey].bio.specialdata )
  end

  --local timeTotalEnd = GetFrameTimeSeconds()
  --local timeTotalDiff = GetDiffBetweenTimeStamps(timeTotalStart, timeTotalEnd)
  --ElderScrollsOfAlts.debugMsg("timeTotalStart: " .. tostring(timeTotalStart) .. " timeTotalEnd:" .. tostring(timeTotalEnd) )
  --ElderScrollsOfAlts.debugMsg("ESOA.SAVE timeTotalDiff=".. tostring(timeTotalDiff) )
	-- Fetch the saved variables
  
  --Test TRAITS
  if(ElderScrollsOfAlts.altData.players[playerKey].researchtraits == nil) then
    ElderScrollsOfAlts.altData.players[playerKey].researchtraits = {}
    ElderScrollsOfAlts.altData.players[playerKey].researchtraits.unknown         = {}
    ElderScrollsOfAlts.altData.players[playerKey].researchtraits.blacksmithing   = {}
    ElderScrollsOfAlts.altData.players[playerKey].researchtraits.clother         = {}
    ElderScrollsOfAlts.altData.players[playerKey].researchtraits.woodworking     = {}
    ElderScrollsOfAlts.altData.players[playerKey].researchtraits.jewelrycrafting = {}
  end
  local baseRTElem = ElderScrollsOfAlts.altData.players[playerKey].researchtraits
  for patternIndex = 1, GetNumSmithingPatterns() do
    local patternName, baseName, _, numMaterials, numTraitsRequired, numTraitsKnown, resultingItemFilterType = GetSmithingPatternInfo(patternIndex)
    local craftingType = GetCraftingInteractionType()-- ONLY valid when crafting table OPEN!
    ElderScrollsOfAlts.debugMsg("DataSaveLivePlayer: Trait: patternName: ", patternName , " numMaterials: " , numMaterials, " numTraitsKnown: ", numTraitsKnown, " TYPE=", craftingType )  
    ElderScrollsOfAlts.debugMsg("DataSaveLivePlayer: TYPElIST: BLACKSMITHING: ", CRAFTING_TYPE_BLACKSMITHING , " CLOTHIER: " , CRAFTING_TYPE_CLOTHIER, " WOODWORKING: ", CRAFTING_TYPE_WOODWORKING)
    local baseTTElem = baseRTElem.unknown
    if craftingType == CRAFTING_TYPE_BLACKSMITHING then
      baseTTElem = baseRTElem.blacksmithing
    elseif craftingType == CRAFTING_TYPE_CLOTHIER then
      baseTTElem = baseRTElem.clother
    elseif craftingType == CRAFTING_TYPE_WOODWORKING then
      baseTTElem = baseRTElem.woodworking
    elseif craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
      baseTTElem = baseRTElem.jewelrycrafting
    end
    if(baseTTElem[patternName]==nil) then
      baseTTElem[patternName] = {}
    end
    baseTTElem[patternName].numTraitsKnown = numTraitsKnown    
  end
  --Test TRAITS
  
  --COMPANIONS
  -- Cant get list of companions? have to use only active one?
  -- done in events.
  --COMPANION END
  
  ElderScrollsOfAlts.debugMsg("DataSaveLivePlayer: done")
end

function ElderScrollsOfAlts:SaveDataSpecialBiteLegacy(playerKey, baseElem,skillineName,specialSkillName,abilityname,buffcooldown)
  ElderScrollsOfAlts.debugMsg("SaveDataSpecialBite: playerKey= " .. tostring(playerKey) )
  --Has to have this ability to be able to BITE!
  local foundItem = ElderScrollsOfAlts:FindAbility( ElderScrollsOfAlts.altData.players[playerKey], skillineName, specialSkillName, abilityname)
  ElderScrollsOfAlts.debugMsg("SaveDataSpecialBite: foundItem= " .. tostring(foundItem) )
  if(foundItem==nil) then
    return
  end
  baseElem.biteability = abilityname
  
  local buffName = buffcooldown
  local fedBuff  = ElderScrollsOfAlts.altData.players[playerKey].buffs[buffName]
  ElderScrollsOfAlts.debugMsg("SaveDataSpecialBite: fedBuff= " .. tostring(fedBuff) )
 
  baseElem.buffName  = buffName
  baseElem.fedBuff   = fedBuff
  baseElem.expiresAt = nil
  if(fedBuff==nil) then
    return
  end
  
  local expiresAt   = fedBuff.expiresAt
  ElderScrollsOfAlts.debugMsg("SaveDataSpecialBite: expiresAt= " .. tostring(expiresAt) )
  baseElem.expiresAt = expiresAt
  
  --Time in seconds left till expires
  --local timeDiff = GetDiffBetweenTimeStamps( expiresAt, GetTimeStamp() )
  --ElderScrollsOfAlts.debugMsg("Buff timeDiff=".. tostring(timeDiff) )
  --local timeTillReady = GetTimeStamp() + timeRemainingSecs
  --UUU
end

--ElderScrollsOfAlts.altData.players[playerKey].bio.specialdata
function ElderScrollsOfAlts:SaveDataVampire(playerKey, baseElem)
  ElderScrollsOfAlts.debugMsg("SaveDataVampire: playerKey= " .. tostring(playerKey) )
  baseElem.vampire = true
  --
  ElderScrollsOfAlts:SaveDataSpecialBiteLegacy(playerKey, baseElem, "world","Vampire",ElderScrollsOfAlts.BITE_VAMP_ABILITY,ElderScrollsOfAlts.BITE_VAMP_COOLDOWN)
  --
end

--ElderScrollsOfAlts.altData.players[playerKey].bio.specialdata
function ElderScrollsOfAlts:SaveDataWerewolf(playerKey, baseElem)
  ElderScrollsOfAlts.debugMsg("SaveDataWerewolf: playerKey= " .. tostring(playerKey) )
  baseElem.werewolf = true
  --
  ElderScrollsOfAlts:SaveDataSpecialBiteLegacy(playerKey, baseElem, "world","Werewolf",ElderScrollsOfAlts.BITE_WERE_ABILITY,ElderScrollsOfAlts.BITE_WERE_COOLDOWN)
  --
end


--loadPlayerDataPart
function ElderScrollsOfAlts:SaveDataSkillData(skillType,baseElem,outputUndiscovered)
	if skillType == nil then
		ElderScrollsOfAlts.outputMsg("Warning: SaveDataSkillData: skillType is NIL")
		return
	end
	--ElderScrollsOfAlts.debugMsg("loadPlayerDataPart: skillType="..skillType..".")
	local numSkillLines = GetNumSkillLines(skillType)
	for ii = 1, numSkillLines do
		local name, rank, discovered, skillLineId, advised, unlockText = GetSkillLineInfo(skillType,ii)
		--name, number rank, boolean discovered, number skillLineId, boolean advised, unlockText
		if name == nil then
			name = ii;
		end
		name = zo_strformat( "<<1>>", name ) -- get rid of links and junk?
		if discovered or outputUndiscovered then
			--ElderScrollsOfAlts.debugMsg("loadPlayerDataPart: unlockText="..unlockText..".")
			baseElem[name]	= {}
			local baseElemTable = baseElem[name]
			local numAbilities = GetNumSkillAbilities(skillType, ii)
			baseElemTable.name = name
			baseElemTable.idx  = ii
			baseElemTable.rank = rank
			baseElemTable.numAbilities = numAbilities
			baseElemTable.skillLineId  = skillLineId

			local lastRankXP, nextRankXP, currentXP  = GetSkillLineXPInfo( skillType, ii )
			baseElemTable.lastRankXP = lastRankXP
			baseElemTable.nextRankXP = nextRankXP
			baseElemTable.currentXP  = currentXP
			ElderScrollsOfAlts.debugMsg("SKILL:",name," last:",lastRankXP, " next:", nextRankXP, " curr:", currentXP )

			--ElderScrollsOfAlts.loadPlayerDataPartDetails(skillType,skillLineId,ii,name,pName)
			--string name, textureName texture, number earnedRank, boolean passive, boolean ultimate, boolean purchased, number:nilable progressionIndex, number:nilable rankIndex 
			--GetSkillAbilityInfo(number SkillType skillType, number skillIndex, number abilityIndex)
			baseElemTable.abilities = {}
			local baseAbilityElem = baseElemTable.abilities
			for abilityIndex = 1, numAbilities do
				local ABname, ABtextureName, ABearnedRank, ABpassive, ABultimate, ABpurchased, ABprogressionIndex, ABrankIndex = GetSkillAbilityInfo(skillType, ii, abilityIndex)
				ABname = zo_strformat( "<<1>>", ABname ) -- get rid of links and junk?
				baseAbilityElem[ABname] = {}
				baseAbilityElem[ABname].name        = ABname
				baseAbilityElem[ABname].textureName = ABtextureName
				baseAbilityElem[ABname].earnedRank  = ABearnedRank
				baseAbilityElem[ABname].passive     = ABpassive
				baseAbilityElem[ABname].ultimate    = ABultimate
				baseAbilityElem[ABname].purchased   = ABpurchased
				baseAbilityElem[ABname].progressionIndex = ABprogressionIndex
				baseAbilityElem[ABname].rankIndex   = ABrankIndex
				--TODO MAX
			end
    else 
      --debugMsg("loadPlayerDataPart: skillType="..skillType..". name=" ..name)
    end      
	end
end

--
function ElderScrollsOfAlts.SaveDataPlayerTradeDetails(parentName, parentTableElem, tradeTableElem, skillType, ii, numAbilities )
    --ElderScrollsOfAlts.debugMsg("parentName='",parentName,"'")
    parentTableElem.skills[parentName]	= {}
    local selElemSubTable = parentTableElem.skills[parentName]
    local skillIndex = ii
    selElemSubTable.sunk     = 0
    selElemSubTable.sinkmax  = 0
    selElemSubTable.sunk2    = 0
    selElemSubTable.sinkmax2 = 0
    for aj = 1, numAbilities do
        local name, icon, earnedRank, passive, ultimate, purchased, progressionIndex = GetSkillAbilityInfo(skillType, ii, aj)
        --ElderScrollsOfAlts.debugMsg("TradeSkill Ability: name="..name.. " purchased="..tostring(purchased))
        local currentUpgradeLevel, maxUpgradeLevel = GetSkillAbilityUpgradeInfo(skillType, skillIndex, aj)
        --name, textureName texture, number:nilable earnedRank
        local _, _, nextUpgradeEarnedRank = GetSkillAbilityNextUpgradeInfo(skillType, skillIndex, aj)
        local plainName = zo_strformat(SI_ABILITY_NAME, name)
        name = ZO_Skills_GenerateAbilityName(SI_ABILITY_NAME_AND_UPGRADE_LEVELS, name, currentUpgradeLevel, maxUpgradeLevel, progressionIndex)
        --local name, rank, discovered, skillLineId, advised, unlockText = GetSkillLineInfo(skillType,ii)
        --if not (currentUpgradeLevel and maxUpgradeLevel) and progressionIndex then
        --    self.displayedAbilityProgressions[progressionIndex] = true
        --end
        --local isActive = (not passive and not ultimate)
        --local isUltimate = (not passive and ultimate)
        --ElderScrollsOfAlts.debugMsg("TradeSkill Ability: passive="..tostring(passive))
        
        if purchased then          
          selElemSubTable[plainName] = {}
          local selL = selElemSubTable[plainName]
          selL.plainName  = plainName
          selL.name       = name
          selL.earnedRank = earnedRank
          selL.currentUpgradeLevel   = currentUpgradeLevel
          selL.maxUpgradeLevel       = maxUpgradeLevel
          selL.nextUpgradeEarnedRank = nextUpgradeEarnedRank
          local match1 = ElderScrollsOfAlts:matchStringList(plainName,ElderScrollsOfAlts.view.matchNameList1)
          if match1 then
            selElemSubTable.sunk    = selElemSubTable.sunk    + (currentUpgradeLevel - 1)
            selElemSubTable.sinkmax = selElemSubTable.sinkmax + (maxUpgradeLevel - 1)
            tradeTableElem.sunk     = selElemSubTable.sunk
            tradeTableElem.sinkmax  = selElemSubTable.sinkmax
          end
          local match2 = ElderScrollsOfAlts:matchStringList(plainName,ElderScrollsOfAlts.view.matchNameList2)
          if match2 then
            selElemSubTable.sunk2    = selElemSubTable.sunk2    + (currentUpgradeLevel - 1)
            selElemSubTable.sinkmax2 = selElemSubTable.sinkmax2 + (maxUpgradeLevel - 1)
            tradeTableElem.sunk2     = selElemSubTable.sunk2
            tradeTableElem.sinkmax2  = selElemSubTable.sinkmax2
            --ElderScrollsOfAlts.debugMsg("loadPlayerTradeDetails: plainName="..plainName.." sunk2="..selElemSubTable.sunk2)
          end
        end
    end
end


--
function ElderScrollsOfAlts:SaveDataPlayerStatsData(playerElem)
  if(playerElem.stats==nil) then
    playerElem.stats = {}
  end
  if(playerElem.stats.derivedStats==nil) then
    playerElem.stats.derivedStats = {}
  end
  --[[
  local numStats = GetNumStats()
  for ii = 1, numStats do
    local value = GetPlayerStat(number DerivedStats derivedStat, number StatBonusOption statBonusOption)
  end
  -]]
  --DerivedStats/StatBonusOption
  --ElderScrollsOfAlts:SaveDataPlayerStatsDataSub( playerElem.stats,STAT_ARMOR_RATING,    "STAT_ARMOR_RATING" )
  --ElderScrollsOfAlts:SaveDataPlayerStatsDataSub( playerElem.stats,STAT_ATTACK_POWER,    "STAT_ATTACK_POWER" )
  --ElderScrollsOfAlts:SaveDataPlayerStatsDataSub( playerElem.stats,STAT_BLOCK,           "STAT_BLOCK" )
  --ElderScrollsOfAlts:SaveDataPlayerStatsDataSub( playerElem.stats,STAT_CRITICAL_RESISTANCE, "STAT_CRITICAL_RESISTANCE" )
  --ElderScrollsOfAlts:SaveDataPlayerStatsDataSub( playerElem.stats,STAT_CRITICAL_STRIKE, "STAT_CRITICAL_STRIKE" )
  --[[
STAT_DAMAGE_RESIST_COLD
STAT_DAMAGE_RESIST_DISEASE
STAT_DAMAGE_RESIST_DROWN
STAT_DAMAGE_RESIST_EARTH
STAT_DAMAGE_RESIST_FIRE
STAT_DAMAGE_RESIST_GENERIC
STAT_DAMAGE_RESIST_MAGIC
STAT_DAMAGE_RESIST_OBLIVION
STAT_DAMAGE_RESIST_PHYSICAL
STAT_DAMAGE_RESIST_POISON
STAT_DAMAGE_RESIST_SHOCK
STAT_DAMAGE_RESIST_START
STAT_DODGE
STAT_HEALING_DONE
STAT_HEALING_TAKEN
  ElderScrollsOfAlts:SaveDataPlayerStatsDataSub( playerElem.stats,STAT_HEALTH_MAX, "STAT_HEALTH_MAX" )
STAT_HEALTH_REGEN_COMBAT
STAT_HEALTH_REGEN_IDLE
STAT_MAGICKA_MAX
STAT_MAGICKA_REGEN_COMBAT
STAT_MAGICKA_REGEN_IDLE
STAT_MISS
ElderScrollsOfAlts:SaveDataPlayerStatsDataSub( playerElem.stats,STAT_MITIGATION, "STAT_MITIGATION" )
STAT_MOUNT_STAMINA_MAX
STAT_MOUNT_STAMINA_REGEN_COMBAT
STAT_MOUNT_STAMINA_REGEN_MOVING
STAT_NONE
STAT_PHYSICAL_PENETRATION
STAT_PHYSICAL_RESIST
STAT_POWER
STAT_SPELL_CRITICAL
STAT_SPELL_MITIGATION
STAT_SPELL_PENETRATION
STAT_SPELL_POWER
STAT_SPELL_RESIST
STAT_STAMINA_MAX
STAT_STAMINA_REGEN_COMBAT
STAT_STAMINA_REGEN_IDLE
STAT_WEAPON_AND_SPELL_DAMAGE
  -]]
  --
end

------------------------------
--
function ElderScrollsOfAlts:SaveDataPlayerStatsDataSub(playerElemS,derivedStat,derivedStatName)
  local value1 = GetPlayerStat(derivedStat, STAT_BONUS_OPTION_APPLY_BONUS     )
  local value2 = GetPlayerStat(derivedStat, STAT_BONUS_OPTION_DONT_APPLY_BONUS)
  playerElemS[derivedStat] = {}
  playerElemS[derivedStat].derivedStatName   = derivedStatName
  playerElemS[derivedStat].valueWithBonus    = value1
  playerElemS[derivedStat].valueWithOutBonus = value2
end


------------------------------
--EOF
