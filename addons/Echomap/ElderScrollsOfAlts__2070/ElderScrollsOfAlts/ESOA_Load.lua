--[[ ESOA Load ]]-- 
----------------------------------------
-- Load Player Data from Saved Variables to GUI friendly data
-- LEGACY
------------------------------


------------------------------
--
function ElderScrollsOfAlts:SetupGuiPlayerBaseLines(playerLines,k)
	ElderScrollsOfAlts.debugMsg("SetupGuiPlayerBaseLines: k='"..tostring(k).."'")
	playerLines[k].name = k -- overwritten by bio later
	playerLines[k].rawname = k
	--
	playerLines[k].gender = -1
	playerLines[k].level = -1
	playerLines[k].xpleft = -1
	playerLines[k].race = "Unk"
	playerLines[k].class = "Unk"
	playerLines[k].server = "Unk"
	playerLines[k].Werewolf = false
	playerLines[k].Vampire = false
	playerLines[k].special    = 0    
	playerLines[k].special_biteicon  = nil
	playerLines[k].special_bitetimer = -1
	--playerLines[k].special_bitetimer2 = "n/a"
	playerLines[k].special_bitetimerDisplay = "[n/a]"
	--
end

------------------------------
-- MAIN call that calls other functions ot populate PLAYER Data
--
function ElderScrollsOfAlts:SetupGuiPlayerLinesForK(playerLines,k)
	ElderScrollsOfAlts.debugMsg("SetupGuiPlayerLinesForK: Start w/k='"..tostring(k).."'")
	--
	playerLines[k] = {}
	playerLines[k].source  = "Legacy"
	playerLines[k].source2 = "ES"
	playerLines[k].charKey = k
	--
	ElderScrollsOfAlts:SetupGuiPlayerBaseLines(playerLines,k)	-- contains only defaults
	--
	ElderScrollsOfAlts:SetupGuiPlayerBaseLines2Legacy(playerLines,k)	--contains local stuff
	--
	ElderScrollsOfAlts:SetupGuiPlayerBioLines(playerLines,k)
	-- CHECK Data
	if playerLines[k].level == nil or playerLines[k].level < 1 then
		ElderScrollsOfAlts.altData.players[k]  = nil --TODO this working as intended?
		return
	end
	--
	ElderScrollsOfAlts:SetupGuiPlayerMiscLines(playerLines,k)   
	ElderScrollsOfAlts:SetupGuiPlayerInfamyLines(playerLines,k)
	ElderScrollsOfAlts:SetupGuiPlayerStatsLines(playerLines,k)    
	ElderScrollsOfAlts:SetupGuiPlayerLocLines(playerLines,k) 
	ElderScrollsOfAlts:SetupGuiPlayerTradeLines(playerLines,k)
	ElderScrollsOfAlts:SetupGuiPlayerSkillsLines(playerLines,k)      
	ElderScrollsOfAlts:SetupGuiPlayerEquipLines(playerLines,k)      
	ElderScrollsOfAlts:SetupGuiResearchPlayerLines(playerLines,k)
	ElderScrollsOfAlts:SetupAllianceWarPlayerLines(playerLines,k)
	ElderScrollsOfAlts:SetupPlayerLinesCurrency(playerLines,k)
	ElderScrollsOfAlts:SetupPlayerLinesTracking(playerLines,k)
	ElderScrollsOfAlts:SetupPlayerLinesCompanions(playerLines,k)
	ElderScrollsOfAlts:SetupPlayerLinesBuffs(playerLines,k)
	ElderScrollsOfAlts:SetupPlayerLinesCP(playerLines,k)
	--
	ElderScrollsOfAlts.debugMsg("SetupGuiPlayerLinesForK: Done w/k='"..tostring(k).."'")
end

--
function ElderScrollsOfAlts:SetupGuiPlayerBaseLines2Legacy(playerLines,k)
	--ElderScrollsOfAlts.outputMsg("SetupGuiPlayerBaseLines2Legacy: k='"..tostring(k).."'")
	--
	playerLines[k].category = ElderScrollsOfAlts.altData.players[k].category
	if(playerLines[k].category==nil)then
	  playerLines[k].category = "A"
	end
	--
	playerLines[k].note = ElderScrollsOfAlts.altData.players[k].note
	if(playerLines[k].note ==nil)then playerLines[k].note  = "" end
	playerLines[k].order = ElderScrollsOfAlts.altData.players[k].order	
	--
	playerLines[k].playersorder      = ElderScrollsOfAlts.altData.players[k].playersorder
	playerLines[k].playerscreenorder = ElderScrollsOfAlts.altData.players[k].playerscreenorder
	if(playerLines[k].playersorder == nil) then 
		playerLines[k].playersorder = -1
	end
	if(playerLines[k].playerscreenorder == nil) then 
		playerLines[k].playerscreenorder = -1
	end
	--
end

--
function ElderScrollsOfAlts:SetupGuiPlayerLocLines(playerLines,k)  
  local locationInfo = ElderScrollsOfAlts.altData.players[k].location
  if( locationInfo ~= nil ) then
    playerLines[k].subzonename = locationInfo.subzoneName
    playerLines[k].zonename    = locationInfo.zoneName
  else
    playerLines[k].subzonename = ""
    playerLines[k].zonename    = ""
  end
end

--
function ElderScrollsOfAlts:SetupGuiPlayerMiscLines(playerLines,k)
  local misc = ElderScrollsOfAlts.altData.players[k].misc
  -- DEFAULTS
  playerLines[k].backpacksize  = 0
  playerLines[k].backpackused  = 0
  playerLines[k].backpackfree  = 0
  playerLines[k].skillpoints   = 0
  playerLines[k].secondsplayed = 0
  playerLines[k].timeplayed    = "---"
  --SETUP
  if misc ~=nil then
    playerLines[k].backpacksize  = misc.backpackSize
    playerLines[k].backpackused  = misc.backpackUsed
    playerLines[k].backpackfree  = misc.backpackFree
    playerLines[k].skillpoints   = misc.skillpoints
    playerLines[k].secondsplayed = misc.secondsPlayed
  end
  if(playerLines[k].skillpoints==nil)then
    playerLines[k].skillpoints = 0 --per recent version
  end
  if(playerLines[k].secondsplayed==nil)then
    playerLines[k].secondsplayed = 0 --per recent version
  else
    ElderScrollsOfAlts.view.accountData.secondsplayed = ElderScrollsOfAlts.view.accountData.secondsplayed+playerLines[k].secondsplayed
    playerLines[k].timeplayed = ElderScrollsOfAlts:timeToDisplay( (playerLines[k].secondsplayed*1000) ,true,false)
  end
  playerLines[k].achieveearned = "-1"
  if( misc.achieve~=nil and misc.achieve.earned~=nil ) then
    playerLines[k].achieveearned    = ZO_CommaDelimitNumber(misc.achieve.earned)
    playerLines[k].achieveearnedraw = misc.achieve.earned
  end
  -- TIME
  playerLines[k].lastlogin = ZO_FormatTime(misc.now, TIME_FORMAT_STYLE_RELATIVE_TIMESTAMP, 
      TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  playerLines[k].lastloginraw = misc.now
  -- TIME
  local lastlogindiff = GetDiffBetweenTimeStamps(GetTimeStamp(), misc.now)
  playerLines[k].lastlogindiff = ZO_FormatTime(lastlogindiff, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, 
        TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  
  -- RIDING
  playerLines[k].riding_inventory = -1
  playerLines[k].riding_speed     = -1
  playerLines[k].riding_stamina   = -1
  playerLines[k].riding_timems    = -1
  playerLines[k].riding_totalDurationMs = -1
  playerLines[k].riding_trainingready   = nil   
  playerLines[k].riding_maxed           = false
  playerLines[k].riding_trainer_ready   = false
  --playerLines[k].riding_cantrain        = false
  --playerLines[k].riding_timedisplay     = "--"
    
  if(misc~=nil)then
    local riding = misc.riding
    if(riding~=nil)then
      playerLines[k].riding_inventory = riding.inventory
      playerLines[k].riding_speed     = riding.speed
      playerLines[k].riding_stamina   = riding.stamina
      playerLines[k].riding_timems          = riding.timeMs
      playerLines[k].riding_totalDurationMs = riding.totalDurationMs
      playerLines[k].riding_trainingready   = riding.trainingReadyAt
      
      if( riding.inventory==60 and riding.speed==60 and riding.stamina==60 ) then
        playerLines[k].riding_maxed = true
        playerLines[k].riding_timems = 99999999;
      else
        local timeDiff = GetDiffBetweenTimeStamps(playerLines[k].riding_trainingready , GetTimeStamp())
        if( timeDiff ~= nil and timeDiff <= 0 ) then
          playerLines[k].riding_trainer_ready = true
          playerLines[k].riding_timems = 0;
        end
      end
      --if(riding.timeMs~=nil and riding.timeMs>-1)then
        --playerLines[k].riding_timedisplay = ElderScrollsOfAlts:timeToDisplay( riding.timeMs, riding.timeDataTaken )
      --end
    end--riding element
  end  --misc element
  --
end

--
function ElderScrollsOfAlts:SetupGuiPlayerInfamyLines(playerLines,k)
	local infamy = ElderScrollsOfAlts.altData.players[k].infamy
	playerLines[k].reducedbounty      = 0
	playerLines[k].ReducedBounty_Rank = 0
	--
	output.LaundersUsed		= 0
	output.LaundersTotal	= 0
	output.SellsUsed		= 0
	output.SellsTotal		= 0
	--
	if( infamy ~= nil ) then
		playerLines[k].ReducedBounty_Rank = infamy.reducedBounty
		playerLines[k].reducedbounty = ZO_CommaDelimitNumber(infamy.reducedBounty)
		playerLines[k].reducedbounty_displaytext = infamy.displayText
		playerLines[k].reducedbounty_bountytozero = infamy.bountytozero
		--d("infamy.displayText='"..tostring(infamy.displayText).."'")
		playerLines[k].reducedbounty_tooltip = infamy.displayText
		local timeDiff = GetDiffBetweenTimeStamps( infamy.bountytozero, GetTimeStamp() )
		if(infamy.reducedBounty>0) then
			if(timeDiff>0) then
				playerLines[k].reducedbounty_timeleft = timeDiff
				playerLines[k].reducedbounty_tooltip  =  playerLines[k].reducedbounty_tooltip.. " and should expire in: " ..ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,true,false)
			else
				playerLines[k].reducedbounty_tooltip  =  playerLines[k].reducedbounty_tooltip.. " and should be expired"
			end
			--ElderScrollsOfAlts.outputMsg("reducedbounty_tooltip='"..tostring(playerLines[k].reducedbounty_tooltip).."'")
		end
		ElderScrollsOfAlts.debugMsg("reducedbounty_tooltip='"..tostring(playerLines[k].reducedbounty_tooltip).."'")
	end
	--
end

--
function ElderScrollsOfAlts:SetupGuiPlayerBioLines(playerLines,k)   
  local bio = ElderScrollsOfAlts.altData.players[k].bio 
  if bio == nil then
    return
  end
  --  
  playerLines[k].gender   = bio.gender
  playerLines[k].level    = tonumber(bio.level)
  playerLines[k].xpleft   = bio.xpleft
  playerLines[k].unitxp   = bio.unitxp
  playerLines[k].unitxpmax= bio.unitxpmax      
  playerLines[k].race     = bio.race
  playerLines[k].class    = bio.class
  playerLines[k].alliance = tonumber(bio.alliance)
  playerLines[k].name     = bio.name --rewrite name
  playerLines[k].id       = bio.id      
  playerLines[k].server   = bio.server
  --
  if bio.Werewolf then
    playerLines[k].Werewolf = true
    playerLines[k].special    = 1
    playerLines[k].special_bitetimerDisplay = "[No Skill]"
    playerLines[k].special_bitetimer = -1
    
    local foundItem = ElderScrollsOfAlts:FindAbility(ElderScrollsOfAlts.altData.players[k], "world", "Werewolf", ElderScrollsOfAlts.BITE_WERE_ABILITY)
    if(foundItem~=nil and foundItem.purchased ) then
      playerLines[k].special_bitetimerDisplay = "[Unk]"
      playerLines[k].special_icon = foundItem["textureName"]
      
      ----ElderScrollsOfAlts.altData.players[playerKey].bio.specialdata
      if(ElderScrollsOfAlts.altData.players[k].bio.specialdata~=nil)then
        local expiresAt = ElderScrollsOfAlts.altData.players[k].bio.specialdata.expiresAt
        if(expiresAt~=nil)then
          --Time in seconds left till expires
          local timeDiff = GetDiffBetweenTimeStamps( expiresAt, GetTimeStamp() )
          --ElderScrollsOfAlts.debugMsg("Buff timeDiff=".. tostring(timeDiff) )
          if(timeDiff<0) then
            playerLines[k].special_bitetimer = 0
            playerLines[k].special_bitetimerDisplay = "[v.v]"
          else
            playerLines[k].special_bitetimer        = timeDiff
            playerLines[k].special_bitetimerDisplay = ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,true,false)
          end
        else
          playerLines[k].special_bitetimer = 0
          playerLines[k].special_bitetimerDisplay = "[v.v]"
        end
      end--has special data
    end--foundItem
  end--ww
  --
  if bio.Vampire then
    playerLines[k].Vampire = true
    playerLines[k].special    = 1
    playerLines[k].special_bitetimerDisplay = "[Not Skilled]"
    playerLines[k].special_bitetimer = -1
    
    local foundItem = ElderScrollsOfAlts:FindAbility(ElderScrollsOfAlts.altData.players[k], "world", "Vampire", ElderScrollsOfAlts.BITE_VAMP_ABILITY)
    if(foundItem~=nil and foundItem.purchased ) then          
      playerLines[k].special_bitetimerDisplay = "[Unk]"
      playerLines[k].special_icon = foundItem["textureName"]
      
      ----ElderScrollsOfAlts.altData.players[playerKey].bio.specialdata
      if(ElderScrollsOfAlts.altData.players[k].bio.specialdata~=nil)then
        local expiresAt = ElderScrollsOfAlts.altData.players[k].bio.specialdata.expiresAt
        if(expiresAt~=nil)then
          --Time in seconds left till expires
          local timeDiff = GetDiffBetweenTimeStamps( expiresAt, GetTimeStamp() )
          --ElderScrollsOfAlts.debugMsg("Buff timeDiff=".. tostring(timeDiff) )
          if(timeDiff<0) then
            playerLines[k].special_bitetimer = 0
            playerLines[k].special_bitetimerDisplay = "[v.v]"
          else
            playerLines[k].special_bitetimer        = timeDiff
            playerLines[k].special_bitetimerDisplay = ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,true,false)
          end
        else
          playerLines[k].special_bitetimer = 0
          playerLines[k].special_bitetimerDisplay = "[v.v]"
        end
      end--has special data
    end--foundItem
  end--vamp

  --
  if bio.canchamppts then
    playerLines[k].champion = bio.champion
  else 
    playerLines[k].champion = -1
  end
end

--
function ElderScrollsOfAlts:SetupGuiPlayerStatsLines(playerLines,k)    
  local iInfo = ElderScrollsOfAlts.altData.players[k].stats
  if( iInfo ~= nil ) then
    playerLines[k].stamina = iInfo.stamina
    playerLines[k].magicka = iInfo.magicka
    playerLines[k].health  = iInfo.health
    playerLines[k].power   = iInfo.power
  else
    playerLines[k].stamina = -1
    playerLines[k].magicka = -1
    playerLines[k].health  = -1
    playerLines[k].power   = -1
  end
end

--
function ElderScrollsOfAlts:SetupGuiPlayerEquipLines(playerLines,k)    
  --Set Defaults
  playerLines[k].heavy  = 0
  playerLines[k].medium = 0
  playerLines[k].light  = 0
  local EMPTYLINE = ""
  playerLines[k].Head       = EMPTYLINE
  --playerLines[k].Head_Link  = ev.itemLink     
  playerLines[k].Head_Type  = EMPTYLINE     
  playerLines[k].Chest  = EMPTYLINE
  --playerLines[k].Chest_Link  = ev.itemLink
  playerLines[k].Chest_Type  = EMPTYLINE     
  playerLines[k].Feet  = EMPTYLINE
  --playerLines[k].Feet_Link  = ev.itemLink          
  playerLines[k].Feet_Type  = EMPTYLINE     
  playerLines[k].Hands  = EMPTYLINE
  --playerLines[k].Hands_Link  = ev.itemLink          
  playerLines[k].Hands_Type  = EMPTYLINE
  playerLines[k].Legs  = EMPTYLINE
  --playerLines[k].Legs_Link  = ev.itemLink          
  playerLines[k].Legs_Type  = EMPTYLINE
  playerLines[k].Shoulders  = EMPTYLINE
  --playerLines[k].Shoulders_Link  = ev.itemLink
  playerLines[k].Shoulders_Type  = EMPTYLINE
  playerLines[k].Waist  = EMPTYLINE
 -- playerLines[k].Waist_Link  = ev.itemLink          
  playerLines[k].Waist_Type  = EMPTYLINE
  playerLines[k].Neck  = EMPTYLINE
  --playerLines[k].Neck_Link    = ev.itemLink          
  --playerLines[k].Neck_Quality = ev.quality
  playerLines[k].Ring2  = EMPTYLINE
  --playerLines[k].Ring2_Link    = ev.itemLink  
  --playerLines[k].Ring2_Quality = ev.quality
  playerLines[k].Ring1  = EMPTYLINE
  --playerLines[k].Ring1_Link    = ev.itemLink  
  --playerLines[k].Ring1_Quality = ev.quality
  playerLines[k].O1  = EMPTYLINE
  --playerLines[k].O1_Link  = ev.itemLink  
  --playerLines[k].O1_WeaponType  = ev.weaponType  
  playerLines[k].M1  = EMPTYLINE
  --playerLines[k].M1_Link  = ev.itemLink  
  --playerLines[k].M1_WeaponType  = ev.weaponType  
  playerLines[k].M2  = EMPTYLINE
  --playerLines[k].M2_Link  = ev.itemLink              
 -- playerLines[k].M2_WeaponType  = ev.weaponType  
  playerLines[k].O2  = EMPTYLINE
  --playerLines[k].O2_Link  = ev.itemLink  
  --playerLines[k].O2_WeaponType  = ev.weaponType  
  playerLines[k].M2  = EMPTYLINE
  --playerLines[k].M2_Link  = ev.itemLink  
  --playerLines[k].M2_WeaponType  = ev.weaponType  
  playerLines[k].Op  = EMPTYLINE
  --playerLines[k].Op_Link  = ev.itemLink
  playerLines[k].Mp  = EMPTYLINE
  --playerLines[k].Mp_Link  = ev.itemLink  
      
  --
  local elemT = ElderScrollsOfAlts.altData.players[k].equip
  if elemT == nil then
    return
  end

  if elemT.slots == nil then
    return
  end

  local equip = elemT.slots
  for ek, ev in pairs(equip) do
    if ek == nil then return end
    --ElderScrollsOfAlts.debugMsg(" equip " .. ek)
    local tarmortype = 0
    local lLine = ""
    --Armor Types
    if ev.armorType ~=nil then
      playerLines[k].armortype = 0
      if( ev.armorType == ARMORTYPE_HEAVY ) then
        lLine = "H"
        playerLines[k].heavy = playerLines[k].heavy +1
        tarmortype = 1
      elseif( ev.armorType == ARMORTYPE_MEDIUM ) then
        playerLines[k].medium = playerLines[k].medium +1
        lLine = "M"
        tarmortype = 2
      elseif( ev.armorType == ARMORTYPE_LIGHT ) then
        playerLines[k].light = playerLines[k].light +1
        lLine = "L"
        tarmortype = 3
      end
    end
    
    --Armor Types/Slots
    if ev.equipType == EQUIP_TYPE_HEAD then
      playerLines[k].Head       = lLine
      playerLines[k].Head_Link  = ev.itemLink     
      playerLines[k].Head_Type  = tarmortype     
    elseif ev.equipType == EQUIP_TYPE_CHEST then
      playerLines[k].Chest  = lLine
      playerLines[k].Chest_Link  = ev.itemLink
      playerLines[k].Chest_Type  = tarmortype     
    elseif ev.equipType == EQUIP_TYPE_FEET then --10
      playerLines[k].Feet  = lLine
      playerLines[k].Feet_Link  = ev.itemLink          
      playerLines[k].Feet_Type  = tarmortype     
    elseif ev.equipType == EQUIP_TYPE_HAND then
      playerLines[k].Hands  = lLine
      playerLines[k].Hands_Link  = ev.itemLink          
      playerLines[k].Hands_Type  = tarmortype
    elseif ev.equipType == EQUIP_TYPE_LEGS then
      playerLines[k].Legs  = lLine
      playerLines[k].Legs_Link  = ev.itemLink          
      playerLines[k].Legs_Type  = tarmortype
    elseif ev.equipType == EQUIP_TYPE_SHOULDERS then
      playerLines[k].Shoulders  = lLine
      playerLines[k].Shoulders_Link  = ev.itemLink
      playerLines[k].Shoulders_Type  = tarmortype
    elseif ev.equipType == EQUIP_TYPE_WAIST then
      playerLines[k].Waist  = lLine
      playerLines[k].Waist_Link  = ev.itemLink          
      playerLines[k].Waist_Type  = tarmortype
    elseif ev.equipType == EQUIP_TYPE_NECK then
      playerLines[k].Neck  = "O"
      playerLines[k].Neck_Link    = ev.itemLink          
      playerLines[k].Neck_Quality = ev.quality
    elseif ev.equipType == EQUIP_TYPE_RING then
      if( ev.slotId == EQUIP_SLOT_RING1) then
        playerLines[k].Ring2  = "O"
        playerLines[k].Ring2_Link    = ev.itemLink  
        playerLines[k].Ring2_Quality = ev.quality
      elseif( ev.slotId == EQUIP_SLOT_RING2) then
        playerLines[k].Ring1  = "O"
        playerLines[k].Ring1_Link    = ev.itemLink  
        playerLines[k].Ring1_Quality = ev.quality
      end
      
    -- Weapon Types/Slots
    --sword:eq=5(EQUIP_TYPE_ONE_HAND),slot=4(EQUIP_SLOT_MAIN_HAND)
    --shield:eq=7(EQUIP_TYPE_OFF_HAND),slot=5(EQUIP_SLOT_OFF_HAND)
    --staff2/h:eq=6(EQUIP_TYPE_TWO_HAND),slot=20(EQUIP_SLOT_BACKUP_MAIN)
    --staff2/h:eq=6(EQUIP_TYPE_TWO_HAND),slot=4 (EQUIP_SLOT_MAIN_HAND)  
    elseif ev.equipType == EQUIP_TYPE_ONE_HAND then --5
      --debugMsg("1h1 itemLink: "..ev.itemLink .." slotid="..tostring(ev.slotId) )
      if( ev.slotId == EQUIP_SLOT_BACKUP_MAIN) then --20
        --debugMsg("Set O1 to "..ev.itemName)
        playerLines[k].O1  = "O"
        playerLines[k].O1_Link  = ev.itemLink  
        playerLines[k].O1_WeaponType  = ev.weaponType  
      elseif( ev.slotId == EQUIP_SLOT_MAIN_HAND) then --4
        playerLines[k].M1  = "O"
        playerLines[k].M1_Link  = ev.itemLink  
        playerLines[k].M1_WeaponType  = ev.weaponType  
      elseif( ev.slotId == EQUIP_SLOT_OFF_HAND) then --5
        playerLines[k].M2  = "O"
        playerLines[k].M2_Link  = ev.itemLink              
        playerLines[k].M2_WeaponType  = ev.weaponType  
      end
    elseif ev.equipType == EQUIP_TYPE_OFF_HAND then --7
      --debugMsg("1h2 itemLink: "..ev.itemLink .." slotid="..tostring(ev.slotId) )
      if( ev.slotId == EQUIP_SLOT_BACKUP_OFF) then --21
        --debugMsg("Set O2 to "..ev.itemName)
        playerLines[k].O2  = "O2"
        playerLines[k].O2_Link  = ev.itemLink  
        playerLines[k].O2_WeaponType  = ev.weaponType  
      elseif( ev.slotId == EQUIP_SLOT_OFF_HAND) then --5
        playerLines[k].M2  = "O"
        playerLines[k].M2_Link  = ev.itemLink  
        playerLines[k].M2_WeaponType  = ev.weaponType  
      end 
    elseif ev.equipType == EQUIP_TYPE_TWO_HAND then 
      --debugMsg("2h itemLink: "..ev.itemLink .." slotid="..tostring(ev.slotId) )
      if( ev.slotId == EQUIP_SLOT_BACKUP_MAIN) then
        --debugMsg("Set O1(b) to "..ev.itemName)
        playerLines[k].O1  = "O"
        playerLines[k].O1_Link  = ev.itemLink  
        playerLines[k].O1_WeaponType  = ev.weaponType  
      elseif( ev.slotId == EQUIP_SLOT_MAIN_HAND) then
        playerLines[k].M1  = "O"
        playerLines[k].M1_Link  = ev.itemLink  
        playerLines[k].M1_WeaponType  = ev.weaponType  
      end
    elseif ev.equipType == EQUIP_TYPE_POISON then
      if( ev.slotId == EQUIP_SLOT_BACKUP_POISON) then
        playerLines[k].Op  = "O"
        playerLines[k].Op_Link  = ev.itemLink
      elseif( ev.slotId == EQUIP_SLOT_POISON) then
        playerLines[k].Mp  = "O"
        playerLines[k].Mp_Link  = ev.itemLink  
      end
    end
  end --pairs(equip)
end

--
function ElderScrollsOfAlts:SetupGuiPlayerSkillsLines(playerLines,k)
  --Set Defaults
  --HACK! TODO fix
  local aTypes = {"Assault_Rank","Support_Rank","Legerdemain_Rank","Soul Magic_Rank","Werewolf_Rank","Vampire_Rank","Fighters Guild_Rank","Mages Guild_Rank","Undaunted_Rank","Thieves Guild_Rank","Dark Brotherhood_Rank","Psijic Order_Rank","Scrying_Rank","Excavation_Rank"}
  for rtK,rtV in pairs(aTypes) do
    --debugMsg("skills All "..k.." as="..rtK.." rtVT='"..tostring(rtV).."'")
    playerLines[k][rtV] = 0
  end
  --HACK! TODO fix
      
  -- Check if player even has skills
  local rTypes = {"ava","guild","world"}
  local skills = ElderScrollsOfAlts.altData.players[k].skills

  if(skills~=nil) then
    for rtK,rtV in pairs(rTypes) do
      --debugMsg("skills for "..k.." as="..rtK.." rtV="..tostring(rtV))
      if(skills[rtV]~=nil)then
        local skillO = skills[rtV]
        if(skillO~=nil)then  
          local skillL = skillO.typelist
          if(skillL~=nil)then
            for rtKT,rtVT in pairs(skillL) do
			  --ElderScrollsOfAlts.debugMsg("setup subskills: rtKT ", tostring(rtKT)," rtVT=",tostring(rtVT))
              playerLines[k][rtKT.."_Rank"] = rtVT.rank
              playerLines[k][rtKT.."_Name"] = rtVT.name
              playerLines[k][string.lower(rtKT).."_rank"] = rtVT.rank
              playerLines[k][rtKT.."_SortKey"] = rtKT.."_Rank"
              playerLines[k][rtKT.."_SortNumericType"] = true
              playerLines[k][rtKT.."_LastRankXP"] = rtVT.lastRankXP
              playerLines[k][rtKT.."_NextRankXP"] = rtVT.nextRankXP
              playerLines[k][rtKT.."_CurrentXP"]  = rtVT.currentXP
              playerLines[k][rtKT.."_XPCode"]     = -1
              if( rtVT.nextRankXP == 0 )then
                 playerLines[k][rtKT.."_XPCode"] = 0
              elseif( rtVT.nextRankXP==nil or rtVT.currentXP==nil) then
                playerLines[k][rtKT.."_XPCode"] = -1
                playerLines[k][rtKT.."_Percentage"] = -1
              elseif( rtVT.nextRankXP > rtVT.currentXP )then
                playerLines[k][rtKT.."_XPCode"] = 1				
				local nCurr = rtVT.currentXP - rtVT.lastRankXP
				local nNext = rtVT.nextRankXP - rtVT.lastRankXP
                playerLines[k][rtKT.."_Percentage"] =  math.floor(  (nCurr/nNext)*100  )
				local das = nCurr / nNext
				if(das~=nil and das~=0) then
					das = das*100
					playerLines[k][rtKT.."_Perc"] = math.floor( das )
					--ElderScrollsOfAlts.outputMsg("setupgui: das ",das, " name=", rtVT.name)
				end
              end
              --debugMsg("skills DD ["..rtKT.."_Rank]" .." as="..tostring(rtVT.rank))
              -- subskills in tooltip
              local abilities = rtVT.abilities
              local sstext  = ""
              local sstextA = ""
              local sstextP = ""
              if( abilities ~=nil and ElderScrollsOfAlts:istable(abilities) ) then
                for ak, av in pairs( abilities ) do
                  --d("ak:" .. tostring(ak)  .. " av:" .. tostring(av) ) 
                  if( ElderScrollsOfAlts:istable(av) and av.purchased ) then
                    sstext = sstext .."  /".. tostring(ak) .. "=".. av.rankIndex
                    if(passive)then
                      sstextP = sstextP .."  /".. tostring(ak) .. "=".. av.rankIndex
                    else
                      sstextA = sstextA .."  /".. tostring(ak) .. "=".. av.rankIndex
                    end
                  end
                end
                --d("ak:" .. tostring(ak)  .. " sstext:" .. tostring(sstext) ) 
                playerLines[k][rtKT.."_subskills"]  = sstext
                playerLines[k][rtKT.."_subskillsA"] = sstextA
                playerLines[k][rtKT.."_subskillsP"] = sstextP
                --d("sstext:" .. sstext)
              end
              -- subskills in tooltip
            end
          end
        end
      end
    end
  end
  --
  playerLines[k]["skillline1"] = "---"
  playerLines[k]["skillline2"] = "---"
  playerLines[k]["skillline3"] = "---"
--xxx
end

--
--tradeKeyName uppercase (Woodworking)
--destTradeName lowercase (woodworking)
function ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeElem, tradeSkillElem, tplayerLine, destTradeName, tradeKeyName)
  ElderScrollsOfAlts.debugMsg("Trade2: ", " tradeKeyName=", tradeKeyName, " destTradeName=", destTradeName )
  if tradeElem ~=nil and tplayerLine[destTradeName.."_setup"]==nil and tradeElem.rank > 0 then
    tplayerLine[destTradeName]               = tradeElem.rank
    tplayerLine[destTradeName.."_sunk"]      = tradeElem.sunk
    tplayerLine[destTradeName.."_sunk2"]     = tradeElem.sunk2
    tplayerLine[destTradeName.."_sinkmax"]   = tradeElem.sinkmax    
    tplayerLine[destTradeName.."_sinkmax2"]  = tradeElem.sinkmax2
    tplayerLine[destTradeName.."_subskills"] = nil
    tplayerLine[destTradeName.."_setup"]     = true
    ElderScrollsOfAlts.debugMsg("Trade2: ", " VALUE=", tplayerLine[destTradeName], " SUNK=", tplayerLine[destTradeName.."_sunk"] )  
    -- tradeElem subskills in tooltip
    local sstext = ""
    if( tradeSkillElem~=nil and ElderScrollsOfAlts:istable(tradeSkillElem) ) then
      for k, v in pairs( tradeSkillElem ) do
        --d("k:" .. tostring(k)  .. " v:" .. tostring(v) ) 
        if( ElderScrollsOfAlts:istable(v) ) then
          sstext = sstext .." /".. tostring(v.name)
        end
      end
      tplayerLine[destTradeName.."_subskills"] = sstext
      --d("sstext:" .. sstext)
    end
  else
    destTradeElem           = 0
    destTradeElem_sunk      = 0
    destTradeElem_sinkmax   = 0
    destTradeElem_sinkmax2  = 0
    destTradeElem_subskills = nil
  end
end

--
function ElderScrollsOfAlts:SetupGuiPlayerTradeLines(playerLines,k)
  --Setup Defaults
  local dEFvAL = 0
  playerLines[k].alchemy         = dEFvAL
  playerLines[k].alchemy_sunk    = dEFvAL
  playerLines[k].alchemy_sinkmax = dEFvAL
  playerLines[k].blacksmithing         = dEFvAL
  playerLines[k].blacksmithing_sunk    = dEFvAL
  playerLines[k].blacksmithing_sinkmax = dEFvAL   
  playerLines[k].smithing         = dEFvAL
  playerLines[k].smithing_sunk    = dEFvAL
  playerLines[k].smithing_sinkmax = dEFvAL     
  playerLines[k].clothing         = dEFvAL
  playerLines[k].clothing_sunk    = dEFvAL
  playerLines[k].clothing_sinkmax = dEFvAL   
  playerLines[k].enchanting          = dEFvAL
  playerLines[k].enchanting_sunk     = dEFvAL
  playerLines[k].enchanting_sinkmax  = dEFvAL 
  playerLines[k].enchanting_sunk2    = dEFvAL
  playerLines[k].enchanting_sinkmax2 = dEFvAL             
  playerLines[k].jewelry         = dEFvAL
  playerLines[k].jewelry_sunk    = dEFvAL
  playerLines[k].jewelry_sinkmax = dEFvAL 
  playerLines[k].provisioning          = dEFvAL
  playerLines[k].provisioning_sunk     = dEFvAL
  playerLines[k].provisioning_sinkmax  = dEFvAL              
  playerLines[k].provisioning_sunk2    = dEFvAL
  playerLines[k].provisioning_sinkmax2 = dEFvAL              
  playerLines[k].woodworking         = dEFvAL
  playerLines[k].woodworking_sunk    = dEFvAL
  playerLines[k].woodworking_sinkmax = dEFvAL              

  --
  if( ElderScrollsOfAlts.altData.players[k].skills == nil ) then
    return
  end
  --
  local trade = ElderScrollsOfAlts.altData.players[k].skills.trade
  if trade == nil then
    return
  end

  local tradeL = ElderScrollsOfAlts.altData.players[k].skills.trade.typelist
  if tradeL == nil then
    return
  end
  local tradeS = ElderScrollsOfAlts.altData.players[k].skills.trade.skills
  if tradeL == nil then
    return
  end
  
  -- Dynamic Names?
  --function ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeElem, tradeSkillElem, tplayerLine, destTradeName, tradeKeyName)
  for iName, dbItem in pairs(tradeL) do
    local ffirst = iName:find(" ")
    if(ffirst~=nil and ffirst>0) then
      ElderScrollsOfAlts.debugMsg("Load: trade as: iName="..iName)
      ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL[iName],tradeS[iName],playerLines[k],string.lower(iName),iName)  
      iName = string.sub(iName,1,ffirst)      
      ElderScrollsOfAlts.debugMsg("Load: trade as: iName="..iName)
      ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL[iName],tradeS[iName],playerLines[k],string.lower(iName),iName)  
    else
      ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL[iName],tradeS[iName],playerLines[k],string.lower(iName),iName)  
    end
  end
  --yyyy ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL["Jewelry Crafting"],tradeS["Jewelry Crafting"],playerLines[k],"jewelry","Jewelry Crafting")  
  --[[
  ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL["Alchemy"],tradeS["Alchemy"] ,playerLines[k],"alchemy","Alchemy")
  ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL["Blacksmithing"],tradeS["Blacksmithing"],playerLines[k],"blacksmithing","Blacksmithing")
  ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL["Blacksmithing"],tradeS["Blacksmithing"],playerLines[k],"smithing","smithing")
  ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL["Clothing"],tradeS["Clothing"],playerLines[k],"clothing","Clothing")  
  
  ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL["Enchanting"],tradeS["Enchanting"],playerLines[k],"enchanting","Enchanting")  
  ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL["Jewelry Crafting"],tradeS["Jewelry Crafting"],playerLines[k],"jewelry","Jewelry Crafting")  
  
    ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL["Provisioning"],tradeS["Provisioning"],playerLines[k],"provisioning","Provisioning")  
    ElderScrollsOfAlts:SetupGuiPlayerTradeLines2(tradeL["Woodworking"],tradeS["Woodworking"],playerLines[k],"woodworking","Woodworking")  --]]
end

--RESEARCH
function ElderScrollsOfAlts:SetupGuiResearchPlayerLines(playerLines,k)
  if k == nil then return end
  
  local research = ElderScrollsOfAlts.altData.players[k].research
  local pName    = ElderScrollsOfAlts.altData.players[k].bio.name
  local rTypes = {"clothier","woodworking","blacksmithing","jewelcrafting"}
  -- Check if player even has this research slot
  --if( research ~= nil ) then 
  --rclothier1time,rclothier2time
  for rtK,rtV in pairs(rTypes) do
    ElderScrollsOfAlts.debugMsg("research for "..k.." as="..rtK.." rtV="..tostring(rtV))    
    --Defaults
    playerLines[k]["r"..rtV.."1time"] = "--------"
    playerLines[k]["r"..rtV.."2time"] = "--------"
    playerLines[k]["r"..rtV.."3time"] = "--------"
    playerLines[k]["r"..rtV.."code"] = -1
    playerLines[k]["r"..rtV.."1s"] = -5
    playerLines[k]["r"..rtV.."2s"] = -5
    playerLines[k]["r"..rtV.."3s"] = -5
    --
    local rrLinesMax  = research[rtV].researchNumlines
    local rrLinesDone = research[rtV].researchNumlinesDone
    local rrLinesMatch = false
    if(rrLinesMax == rrLinesDone) then
      rrLinesMatch = true
    end
    --Code = -1 is n/a, 0 is unk, 1 is READY, 
    if(research==nil or research[rtV]==nil)then
    else
      --Number of Slots = researchMS
      local researchMS = research[rtV].researchMS
      for kkiT = 1, 3 do
        local mKye = "r"..rtV..kkiT
        --debugMsg("ESOA: setup ResearchItem: playerLines[k][mKye.."S"] = timeS="
        if(researchMS==nil) then
          playerLines[k][mKye.."time"] = ""
          playerLines[k][mKye.."code"] = 0
          playerLines[k][mKye.."s"] = -4
        elseif(kkiT<=researchMS) then
          playerLines[k][mKye.."time"] = GetString(ESOA_RESEARCH_AVAIL) --"[avail]"
          playerLines[k][mKye.."code"] = 1
          playerLines[k][mKye.."s"] = 0
          if(rrLinesMatch) then
            playerLines[k][mKye.."time"] = "[xxxxx]"-- GetString(ESOA_RESEARCH_AVAIL) --"[avail]"
            playerLines[k][mKye.."tooltip"] = string.format("%s%s%s%s",pName," knows all traits in ",rtV,"!")
            playerLines[k][mKye.."code"] = -3
            playerLines[k][mKye.."s"] = -3
          end
        else
          playerLines[k][mKye.."time"] = "--------"
          playerLines[k][mKye.."code"] = 0
          playerLines[k][mKye.."s"] = -2
        end
      end
    end
  end
    
  -- Colate data for this research slot
  if(research~=nil)then
    for rtK,rtV in pairs(rTypes) do
      if(research[rtV]~=nil) then
        local kki = 1
        for kk, vv in pairs( research[rtV].ongoing ) do
          if kk == nil then return end
          ElderScrollsOfAlts.debugMsg("research kk=" .. kk.. " v="..tostring(vv) )
          --Get/Fix Time
          local nowDiff = GetDiffBetweenTimeStamps( GetTimeStamp() , ElderScrollsOfAlts.altData.players[k].research.now ) --secconds
          if(ElderScrollsOfAlts.altData.players[k].version==nil) then
            nowDiff = GetFrameTimeSeconds() - ElderScrollsOfAlts.altData.players[k].research.now
            --nowDiff = GetTimeStamp() - vv.timeTillReady
          end
          local timeS = vv.timeRemainingSecs - nowDiff          
          --if(ElderScrollsOfAlts.altData.players[k].version~=ElderScrollsOfAlts.version) then
            --timeS = vv.timeTillReady - GetTimeStamp()
          --end
          local timeM = math.floor(timeS/60)
          local timeH = math.floor(timeM/60)
          local timeD = math.floor(timeH/24)
          if(timeH>0) then
            timeM = timeM - (timeH*60)
          elseif(timeH<0) then
            timeH = 0
          end
          if(timeD>0) then
            timeH = timeH - (timeD*24)
          end          
          local mKye = "r"..rtV..kki
          local timeDisp2Str = ""
          if(timeS<=0) then
            timeDisp2Str = GetString(ESOA_RESEARCH_AVAIL) --"[avail]"
            playerLines[k][mKye.."code"] = 1
          elseif(timeD>0) then
            timeDisp2Str = "<<1>>d<<2>>h<<3>>m"
          else
            timeDisp2Str = "<<2>>h<<3>>m"
          end
          if(timeS>0) then
            playerLines[k][mKye.."code"] = 2
          end
          local timeDisp2 = zo_strformat(timeDisp2Str, timeD,timeH,timeM )
          local timeDisp = timeD.."d" ..timeH.."h" ..timeM.."m"
          if(ElderScrollsOfAlts.altData.players[k].version==nil) then
            playerLines[k][mKye.."code"] = 3
            timeDisp2 = "*"..timeDisp2
          end          
          playerLines[k][mKye.."name"] = vv.name
          playerLines[k][mKye.."time"] = timeDisp2
          playerLines[k][mKye.."D"] = timeD
          playerLines[k][mKye.."H"] = timeH
          playerLines[k][mKye.."S"] = timeS
          playerLines[k][mKye.."s"] = timeS
          --TODO timeTillReady
          --debugMsg("research for "..k.." mKye="..mKye.. " research: " .. vv.name .. " D="..timeD .." H="..timeH .." M="..timeM)
          playerLines[k][mKye.."TraitType"] = vv.traitType
          playerLines[k][mKye.."TraitDesc"] = vv.traitDescription
          playerLines[k][mKye.."Traitknown"] = vv.known
          playerLines[k][mKye.."NumTraitsKnown"] = vv.numTraitsKnown
          --        
          kki = kki+1
        end 
      end
    end
  end
end

--
function ElderScrollsOfAlts:SetupAllianceWarPlayerLines(playerLines,k)
  if k == nil then return end
  local alliancewar = ElderScrollsOfAlts.altData.players[k].alliancewar
  if alliancewar == nil then return end
  --Setup
  playerLines[k].InCampaign           = ElderScrollsOfAlts:getValueOrDefault( alliancewar.inCampaign          ,"")
  playerLines[k].GuestCampaignId      = ElderScrollsOfAlts:getValueOrDefault( alliancewar.guestCampaignId     ,"")
  --
  playerLines[k].CurrentCampaignId       = ElderScrollsOfAlts:getValueOrDefault( alliancewar.currentCampaignId      ,"")
  playerLines[k].CurrentCampaignAssigned = ElderScrollsOfAlts:getValueOrDefault( alliancewar.currentCampaignAssigned,"") 
  playerLines[k].CurrentCampaignEndsAt   = ElderScrollsOfAlts:getValueOrDefault( alliancewar.CurrentCampaignEndsAt,"") 
  --
  playerLines[k].AssignedCampaignId          = ElderScrollsOfAlts:getValueOrDefault( alliancewar.assignedCampaignId  ,"") 
  playerLines[k].AssignedCampaignEndsSeconds = ElderScrollsOfAlts:getValueOrDefault( alliancewar.AssignedCampaignEndsSeconds,0) 
  playerLines[k].AssignedCampaignEndsAt      = ElderScrollsOfAlts:getValueOrDefault( alliancewar.AssignedCampaignEndsAt,"") 
  playerLines[k].AssignedCampaignLastloaded  = ElderScrollsOfAlts:getValueOrDefault( alliancewar.AssignedCampaignLastloaded,"") 
  --
  playerLines[k].AssignedCampaignEndsAt_value = playerLines[k].AssignedCampaignEndsSeconds
  
  --
  if(alliancewar.AssignedCampaignEndsAt~=nil and alliancewar.AssignedCampaignEndsAt~="") then
    local timeDiff  = GetDiffBetweenTimeStamps( playerLines[k].AssignedCampaignEndsAt,    GetTimeStamp() )
    --local timeDiff2 = GetDiffBetweenTimeStamps( playerLines[k].AssignedCampaignIdSeconds, GetTimeStamp() )
    --playerLines[k].AssignedCampaignEndsAt = timeDiff -- playerLines[k].AssignedCampaignEndsAt - GetTimeStamp() 
    playerLines[k].AssignedCampaignEndsAt = ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,true,false)
    ElderScrollsOfAlts.debugMsg("AssignedCampaignEndsAt=", playerLines[k].AssignedCampaignEndsAt )
    playerLines[k].AssignedCampaignEndsAt_tooltip = playerLines[k].AssignedCampaignEndsAt
    if(timeDiff<1) then
      playerLines[k].AssignedCampaignEndsAtOver = true
    else
      playerLines[k].AssignedCampaignEndsAtOver = false
    end
    ElderScrollsOfAlts.debugMsg("name:", playerLines[k].name, " AssignedCampaignEndsAtOver=", playerLines[k].AssignedCampaignEndsAtOver )
    --playerLines[k].AssignedCampaignEndsAt = ZO_FormatTime( alliancewar.AssignedCampaignEndsAt, TIME_FORMAT_STYLE_RELATIVE_TIMESTAMP, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  end
  
  playerLines[k].GuestCampaignName    = ElderScrollsOfAlts:getValueOrDefault( alliancewar.guestCampaignName    ,"")
  playerLines[k].CurrentCampaignName  = ElderScrollsOfAlts:getValueOrDefault( alliancewar.currentCampaignName     ,"")
  playerLines[k].AssignedCampaignName = ElderScrollsOfAlts:getValueOrDefault( alliancewar.assignedCampaignName ,"")
  playerLines[k].guestcampaignname    = ElderScrollsOfAlts:getValueOrDefault( alliancewar.guestCampaignName    ,"")
  playerLines[k].currentcampaignname  = ElderScrollsOfAlts:getValueOrDefault( alliancewar.currentCampaignName     ,"")
  playerLines[k].assignedcampaignname = ElderScrollsOfAlts:getValueOrDefault( alliancewar.assignedCampaignName ,"")
  
  playerLines[k].IsInCampaign         = ElderScrollsOfAlts:getValueOrDefault( alliancewar.isInCampaign        ,"")  
  playerLines[k].UnitAlliance         = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAlliance        ,"")
  playerLines[k].AllianceName         = ElderScrollsOfAlts:getValueOrDefault( alliancewar.allianceName        ,"")
  playerLines[k].UnitAvARank          = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAvARank         ,"")
  playerLines[k].UnitAvARankPoints    = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAvARankPoints   ,"")
  playerLines[k].unitavarank          = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAvARank         ,"")
  playerLines[k].unitavarankpoints    = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAvARankPoints   ,"")
  playerLines[k].AvaSubRankStarts      = ElderScrollsOfAlts:getValueOrDefault( alliancewar.subRankStartsAt     ,"")
  playerLines[k].AvaNextSubRank        = ElderScrollsOfAlts:getValueOrDefault( alliancewar.nextSubRankAt       ,"")
  playerLines[k].AvaRankStarts         = ElderScrollsOfAlts:getValueOrDefault( alliancewar.rankStartsAt        ,"")
  playerLines[k].AvaNextRank           = ElderScrollsOfAlts:getValueOrDefault( alliancewar.nextRankAt          ,"")
  playerLines[k].AvaRankName          = ElderScrollsOfAlts:getValueOrDefault( alliancewar.avaRankName         ,"")
  --
  playerLines[k].AssignedCampaignRewardEarnedTier = ElderScrollsOfAlts:getValueOrDefault( alliancewar.AssignedCampaignRewardEarnedTier, 0 )
  playerLines[k].CurrentCampaignRewardEarnedTier = ElderScrollsOfAlts:getValueOrDefault( alliancewar.CurrentCampaignRewardEarnedTier, 0 )
  playerLines[k].GuestCampaignRewardEarnedTier = ElderScrollsOfAlts:getValueOrDefault( alliancewar.guestCampaignRewardEarnedTier, 0 )
  --
  playerLines[k].assignedcampaignrewardearnedtier = playerLines[k].AssignedCampaignRewardEarnedTier
  playerLines[k].currentCampaignrewardearnedTier  = playerLines[k].CurrentCampaignRewardEarnedTier
  playerLines[k].guestCampaignrewardearnedTier    = playerLines[k].GuestCampaignRewardEarnedTier
  --
  playerLines[k].assignedcampaignrewardprogress = alliancewar.AssignedCampaignRewardNextProgressTier
  playerLines[k].assignedcampaignrewardtotal    = alliancewar.AssignedCampaignRewardNextTotalTier
  --
  if( ElderScrollsOfAlts.altData.showpercents and playerLines[k].assignedcampaignrewardprogress~=nil and playerLines[k].assignedcampaignrewardtotal~=nil ) then
	local das = playerLines[k].assignedcampaignrewardprogress / playerLines[k].assignedcampaignrewardtotal
	if(das~=nil and das~=0) then
		das = das*100
		playerLines[k].assignedcampaignrewardearnedtierperc = math.floor( das )
	end
  end 
  --
  if(playerLines[k].AssignedCampaignEndsAtOver) then
    --playerLines[k].assignedcampaignrewardearnedtier = "("..playerLines[k].assignedcampaignrewardearnedtier..")"
    --playerLines[k].currentCampaignrewardearnedTier  = "("..playerLines[k].currentCampaignrewardearnedTier..")"
    --playerLines[k].guestCampaignrewardearnedTier    = "("..playerLines[k].guestCampaignrewardearnedTier..")"
  end
  --
  --playerLines[k].assignedcampaignrewardearnedtier_rank = playerLines[k].AssignedCampaignRewardEarnedTier
  --playerLines[k].currentCampaignrewardearnedTier_rank  = playerLines[k].CurrentCampaignRewardEarnedTier
  --playerLines[k].guestCampaignrewardearnedTier_rank    = playerLines[k].GuestCampaignRewardEarnedTier
end

--
function ElderScrollsOfAlts:SetupPlayerLinesCurrency(playerLines,k)
  local currency = ElderScrollsOfAlts.altData.players[k].currency
  if k == nil then return end
  if currency == nil then return end
  
  --Setup
  --ElderScrollsOfAlts.altData.players[playerKey].currency[cType] = {}
  --ElderScrollsOfAlts.altData.players[playerKey].currency[cType].currencyName = currencyName
  --ElderScrollsOfAlts.altData.players[playerKey].currency[cType].amount       = amount
  
  --Defaults
  playerLines[k]["currency_gold"] = 0
  playerLines[k]["currency_alliance point"] = 0
  playerLines[k]["currency_tel var stone"] = 0
  playerLines[k]["currency_writ vouchers"] = 0
  playerLines[k]["currency_transmute crystals"] = 0
  playerLines[k]["currency_crown gems"] = 0
  playerLines[k]["currency_crowns"] = 0
  playerLines[k]["currency_outfit change tokens"] = 0

  --Values
  for rtK, rtKV in pairs(currency) do
    ElderScrollsOfAlts.debugMsg("currency "..rtK.." as="..tostring(rtKV))    
    ElderScrollsOfAlts.debugMsg("currency "..tostring(rtKV.currencyName).." as="..tostring(rtKV.amount) )
    playerLines[k]["currency_"..string.lower(rtKV.currencyName)] = ZO_CommaDelimitNumber(rtKV.amount)
  end  
end

--
function ElderScrollsOfAlts:SetupPlayerLinesCP(playerLines,k)
  if k == nil then return end
  local linedata = ElderScrollsOfAlts.altData.players[k].championpoints
  if linedata == nil then return end
  --
  for rtKd, rtKVd in pairs(linedata) do  --numDisciplines
    --ElderScrollsOfAlts.outputMsg("cp discp ".. k.. " as '"..rtKd )
    for rtKs, rtKVs in pairs(rtKVd) do   --skill ids
      if(rtKVs.name~=nil) then
        local tempn1 = string.format("cp_%s",rtKVs.name)
        local tempn3 = string.lower(tempn1)
        playerLines[k][tempn1] = rtKVs.ptsspent
        playerLines[k][tempn3] = rtKVs.ptsspent
        --(ElderScrollsOfAlts) cp set as 'cp_Meticulous Disassembly'=50
        --(ElderScrollsOfAlts) *******cp set as 'cp_meticulous disassembly'=50
        --entered CP case for viewKey='cp_meticulous disassembly' ='
        ElderScrollsOfAlts.debugMsg("cp set as '"..tempn3.."'="..tostring(rtKVs.ptsspent))
        --if( tempn3 == "cp_meticulous disassembly" or tempn3 == "meticulous disassembly" ) then
          --ElderScrollsOfAlts.outputMsg("*******cp set as '"..tempn3.."'="..tostring(rtKVs.ptsspent))  
        --end
        --local tempn2 = tempn1.."_tooltip"
        --playerLines[k][tempn1] = "[n.a]"
        --playerLines[k][tempn2] = "[n.a]"
      end
    end
  end
end

--
function ElderScrollsOfAlts:SetupPlayerLinesBuffs(playerLines,k)
  if k == nil then return end
  local linedata = ElderScrollsOfAlts.altData.players[k].buffs
  if linedata == nil then return end
  for rtK, rtKV in pairs(linedata) do
    local tempn1 = string.format("buff_%s",rtK)
    local tempn3 = string.lower(tempn1)
    local tempn2 = tempn1.."_tooltip"
    playerLines[k][tempn1.."_expiresAt"]    = rtKV.expiresAt
    --Time in seconds left till expires
    local timeDiff = GetDiffBetweenTimeStamps( rtKV.expiresAt, GetTimeStamp() )
    if(timeDiff<0) then
      playerLines[k][tempn1] = "[n.a]"
      playerLines[k][tempn2] = "[n.a]"
    else
      playerLines[k][tempn1] = ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,false,true ) --timeMS,incDay,incSec)
      playerLines[k][tempn2] = playerLines[k][tempn1]
      playerLines[k][tempn3] = playerLines[k][tempn1]
    end
    --
    ElderScrollsOfAlts.debugMsg("setup  buff data for rtK: '", rtK, "' expires '", rtKV.expiresAt, "'" )
  end
end

--
function ElderScrollsOfAlts:SetupPlayerLinesCompanions(playerLines,k)
	local linedata = ElderScrollsOfAlts.altData.players[k].companions
	if k == nil then return end	
	--Default data
	for ii = 1, ElderScrollsOfAlts.maxCompanions do
	local tempn0 = string.format("companion_%s",ii)
		playerLines[k][tempn0.."_name"]    = "-none-"
		playerLines[k][tempn0.."_level"]   = -1
		playerLines[k][tempn0.."_rapport"] = -1
		playerLines[k][tempn0.."_currentexperience"] = -1
		playerLines[k][tempn0.."_experienceforlevel"] = -1
	end

	if linedata == nil then return end  
	local cnt = ElderScrollsOfAlts:tablelength(linedata.ids)
	if cnt == nil then return end
	ElderScrollsOfAlts.debugMsg("companion data: cnt: '", cnt, "'" )

	-- KEYS -- sorted by release of companion
	local keyset={}
	for rtK1, rtKV1 in pairs(linedata.data) do
		keyset[rtK1]=rtK1
	end	
	table.sort(keyset)
	--TESTING
	--ElderScrollsOfAlts.outputMsg( "TestCompanions:",">>>")
	--for k, v in pairs(keyset) do
	--	print(k, v)
	--	ElderScrollsOfAlts.outputMsg( "TestCompanions:", "K=[", tostring(k), "] V=[", tostring(v), "]" )
	--end
	--ElderScrollsOfAlts.outputMsg( "TestCompanions:","<<<")
	--TESTING
	--
	--Output Real Data, aligned to the first entry
	ElderScrollsOfAlts.debugMsg( "TestCompanions:",">>>")		
	local cInc = 1
	for kk, vv in pairs(keyset) do
		local ldata = linedata.data[kk]
		if(ldata~=nil) then
			ElderScrollsOfAlts.debugMsg( "TestCompanions:","kk=",kk," ldata=", tostring(ldata),".")	
			local tempn = string.format("companion_%s",cInc)
			playerLines[k][tempn.."_name"]    = ldata.name
			playerLines[k][tempn.."_level"]   = ldata.level
			playerLines[k][tempn.."_rapport"] = ldata.rapport
			playerLines[k][tempn.."_currentexperience"]  = ldata.currentExperience
			playerLines[k][tempn.."_experienceforlevel"] = ldata.experienceForLevel
			ElderScrollsOfAlts.debugMsg("companion data: tempn: '", tempn, "' set '", tempn.."_name", "' as '", ldata.name, "'" )
			cInc = cInc +1
		end
	end
	ElderScrollsOfAlts.debugMsg( "TestCompanions:","<<<")
  --Real data
  --[[
  local cInc = 1
  for rtK, rtKV in pairs(linedata.data) do
    local tempn = string.format("companion_%s",cInc)
    playerLines[k][tempn.."_name"]    = rtKV.name
    playerLines[k][tempn.."_level"]   = rtKV.level
    playerLines[k][tempn.."_rapport"] = rtKV.rapport
    playerLines[k][tempn.."_currentexperience"] = rtKV.currentExperience
    playerLines[k][tempn.."_experienceforlevel"] = rtKV.experienceForLevel
    ElderScrollsOfAlts.debugMsg("companion data: tempn: '", tempn, "' set '", tempn.."_name", "' as '", rtKV.name, "'" )
	cInc = cInc +1
  end
  --]]
  --SetupPlayerLinesCompanions
end

--
function ElderScrollsOfAlts:SetupPlayerLinesTracking(playerLines,k)
  local tracking = ElderScrollsOfAlts.altData.players[k].tracking
  if k == nil then return end
  if tracking == nil then return end
  
  --Defaults
  --Values
  for rtK, rtKV in pairs(tracking) do
    ElderScrollsOfAlts.debugMsg("tracking "..rtK.." as="..tostring(rtKV) )    
    ElderScrollsOfAlts.debugMsg("tracking "..tostring(rtKV.currencyName).." as="..tostring(rtKV.amount) )
    for rtK2, rtKV2 in pairs(rtKV) do
      if(rtKV2~=nil) then
        local tempn = string.format("tracking_%s_%s",rtK, rtK2)
        tempn = string.lower(tempn)
        --d(">tempn: " .. tostring(tempn) .. " comp: " .. tostring(rtKV2.completed) )
        playerLines[k][tempn.."_time"]  = rtKV2.completedtime
        playerLines[k][tempn.."_done"]  = rtKV2.completed
        playerLines[k][tempn.."_reset"] = rtKV2.resettime
        --d("timestring: " .. GetDateStringFromTimestamp(rtKV2.completedtime) )
        --d("timediff: " .. GetDiffBetweenTimeStamps(GetTimeStamp(),rtKV2.completedtime) )
        --if diff is negative, it was previous
        -- so what time to compare to to get if it was done today?
        --[15:32] [15:32] >tempn: "tracking_writs_Jewelry Crafting Writ"
      end
    end
  end  
end

--EOF