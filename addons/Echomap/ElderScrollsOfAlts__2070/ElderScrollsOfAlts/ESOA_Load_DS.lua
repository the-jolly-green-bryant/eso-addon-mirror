----------------------------------------
--[[ ESOA ]]-- 
----------------------------------------
-- INTERNAL Implementation API
-- Load/Save Data from Datastore
----------------------------------------


------------------------------
-- Get from Datastore without any legacy calls
function ElderScrollsOfAlts:SetupGuiPlayerLinesDS()
	--
	local accountname = GetDisplayName()
	if( ElderScrollsOfAlts.view.selectedAccount ~=nil ) then
		accountname = ElderScrollsOfAlts.view.selectedAccount		
		ElderScrollsOfAlts.debugMsg("SetupDSPlayer: switched to account: [",accountname,"]" )
	end
	ElderScrollsOfAlts.debugMsg("SetupDSPlayer: for account: [",accountname,"]" )
	--
	ElderScrollsOfAlts.view.accountData = {} --todo needed? 
	ElderScrollsOfAlts.view.accountData.secondsplayed = 0 --todo needed? 
	--TODO bankspaces
	--
	local playerLines =  {}
	local pCount = 0
	--
	local charData = ESOADatastore.getDataForCharacters(accountname)
	--
	if(charData~=nil) then
		for index, tvalue in pairs(charData) do			
			if tvalue == nil then return end
			ElderScrollsOfAlts.debugMsg("Character DS Loaded for index=",index )
			--if tvalue.id == nil then return end
			local k = index
			playerLines[k] = {}
			pCount = pCount+1
			--
			ElderScrollsOfAlts:SetupGuiPlayerBaseLines(playerLines,k)	-- contains only defaults
			playerLines[k].accountname = accountname
			playerLines[k].charkey = k
			ElderScrollsOfAlts.debugMsg("playerLines charkey set to=", tostring(charkey) )
			--tvalue.charkey = k
			--tvalue.accountname = accountname
			ElderScrollsOfAlts.debugMsg("Player: set charkey=".. tostring(k) ) 
			--ElderScrollsOfAlts:SetupGuiPlayerBaseLines2(playerLines,k)	--contains local stuff
			--ElderScrollsOfAlts:SetupGuiPlayerBaseLinesDS2(playerLines,k)	--TODO since contains local stuff
			-- Check Data
			if( tvalue==nil or tvalue.bio==nil or tvalue.bio.name==nil) then
				ElderScrollsOfAlts.outputMsg("Error with data loaded for='", tostring(k) ,",")
				playerLines[k] = nil
				pCount = pCount-1
			else
				-- Flatten chardata for ESOA
				local chardataF = ElderScrollsOfAlts:SetupGuiPlayerLinesDSFlatten(tvalue)
				ElderScrollsOfAlts.debugMsg("Player: name=".. tostring(chardataF.name) , " id=" , tostring(chardataF.id) , " account=" , tostring(chardataF.account ), " (chardataF)" )
				ElderScrollsOfAlts:SetupGuiPlayerBaseLines2DS(chardataF,k)	--contains local stuff
				playerLines[k] = chardataF
			end
		end
	else
		ElderScrollsOfAlts.outputMsg("No players listed in datastsore")
	end	
	-- PlayerLines to table
	table.sort(playerLines)  
	ElderScrollsOfAlts.view.maxPlayerLineCount = pCount
	return playerLines
end


------------------------------
-- Translate from DataStore format to ESOA format
-- 
function ElderScrollsOfAlts:SetupGuiPlayerLinesDSFlatten(chardata)
	--ElderScrollsOfAlts:dumpPrintTable(chardata)
	if(chardata~=nil and chardata.bio~=nil and chardata.bio.name~=nil) then
		ElderScrollsOfAlts.debugMsg("FlattenChar: in='", tostring(chardata.bio.name) ,",")
	else
		ElderScrollsOfAlts.outputMsg("FlattenChar: in=<BIO NAME BROKEN?>")
	end
	local chardataO = {}
	chardataO.account = chardata.accountname
	ElderScrollsOfAlts.debugMsg("playerLinesB charkey set to=", tostring(chardataO.playerkey) )
	chardataO.playerkey = chardata.charkey
	chardataO.playerKey = chardata.charkey
	chardataO.charkey = chardata.charkey
	chardataO.charKey = chardata.charkey
	chardataO.rawname = chardata.charkey
	chardataO.source  = "DataStore"
	chardataO.source2 = "DS"
	ElderScrollsOfAlts.debugMsg("FlattenChar: out: account=",tostring(chardataO.account) ," charkey=",tostring(chardataO.charkey), " playerKey=",tostring(chardataO.playerKey), " charKey=",tostring(chardataO.charkey) )
	--
	ElderScrollsOfAlts:SetupGuiPlayerBioLinesDS(chardataO,chardata) -- includes special logic
	-- CHECK Data TODO
	ElderScrollsOfAlts.debugMsg("FlattenChar: out='", tostring(chardataO.name) ,",")
	ElderScrollsOfAlts.debugMsg("FlattenChar: lvl=", tostring(chardataO.level) )
	-- Server/Account/Custom Data
	local dName 	= chardataO.account -- chardata["server"]
	local charKey 	= chardata.charkey
	if(dName~=nil) then 
		chardataO.account = dName
	end
	--if( EchoESOADatastore.svListDataAW[dName]~=nil and EchoESOADatastore.svListDataAW[dName].players~=nil and EchoESOADatastore.svListDataAW[dName].players[charKey]~=nil ) then
	if( chardataO.custom~=nil and chardataO.custom.category~=nil )  then
		chardataO.category 		= chardataO.custom.category
	else 
		chardataO.category 		= "A"
	end
	if( chardataO.custom~=nil and chardataO.custom.playersorder~=nil )  then
		chardataO.playersorder 		= chardataO.custom.playersorder
	else 
		chardataO.playersorder 		= -1
	end
	--TODO custom order
	-- Flatten Sub Tables appropriately
	ElderScrollsOfAlts:SetupGuiPlayerMiscLinesDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupGuiPlayerInfamyLinesDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupGuiPlayerSkillsLinesDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupPlayerLinesBuffsDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupGuiPlayerLocLinesDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupGuiPlayerTradeLinesDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupGuiPlayerStatsLinesDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupAllianceWarPlayerLinesDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupPlayerLinesCurrencyDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupGuiResearchPlayerLinesDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupPlayerLinesCustomDS(chardataO,chardata)
	ElderScrollsOfAlts:SetupPlayerLinesCompanionsDS(chardataO,chardata,dName)
	ElderScrollsOfAlts:SetupPlayerLinesTrackingDS(chardataO,chardata)
	--
	ElderScrollsOfAlts:SetupGuiPlayerEquipLinesDS(chardataO,chardata)   
	ElderScrollsOfAlts:SetupPlayerLinesCPDS(chardataO,chardata)
	--
	chardataO.account = chardata.accountname
	chardataO.charkey = chardata.charkey
	chardataO.rawname = chardata.charkey
	--ElderScrollsOfAlts.debugMsg("FlattenChar2: out: account=",tostring(chardataO.account) ," charkey=",tostring(chardataO.charkey), " name=",tostring(chardataO.name), " rawname=",tostring(chardataO.rawname), " playerKey=",tostring(chardataO.playerKey) )
	return chardataO
end


-- Called from Datastore POST Flatten
function ElderScrollsOfAlts:SetupGuiPlayerBaseLines2DS(playerLine,k)
	--ElderScrollsOfAlts.debugMsg("SetupGuiPlayerBaseLines2DS: k='"..tostring(k).."'")
	--
	if( ElderScrollsOfAlts.altData.players~=nil and ElderScrollsOfAlts.altData.players[k]~=nil ) then
		if(playerLine.category==nil) then
			playerLine.category = ElderScrollsOfAlts.altData.players[k].category
		end
		if(playerLine.note==nil) then
			playerLine.note = ElderScrollsOfAlts.altData.players[k].note
		end
		if(playerLine.order==nil) then
			playerLine.order = ElderScrollsOfAlts.altData.players[k].order
		end
		if(playerLine.playersorder==nil) then
			playerLine.playersorder = ElderScrollsOfAlts.altData.players[k].playersorder
		end
		if(playerLine.playerscreenorder==nil) then
			playerLine.playerscreenorder = ElderScrollsOfAlts.altData.players[k].playerscreenorder
		end
	end
	--
	if(playerLine.category==nil)then
	  playerLine.category = "A"
	end
	if(playerLine.playersorder == nil) then 
		playerLine.playersorder = -1
	end
	if(playerLine.playerscreenorder == nil) then 
		playerLine.playerscreenorder = -1
	end
	--
end

------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupGuiPlayerBioLinesDS(output,input)   
  local bio = input.bio 
  if bio == nil then
	ElderScrollsOfAlts.outputMsg("SetupBio: Error with bio for character=", tostring(input.name) )
	return
  end
  --  
  output.gender   = bio.gender
  output.level    = tonumber(bio.level)
  output.xpleft   = bio.xpleft
  output.unitxp   = bio.unitxp
  output.unitxpmax= bio.unitxpmax      
  output.race     = bio.race
  output.class    = bio.class
  output.alliance = tonumber(bio.alliance)
  output.name     = bio.name --rewrite name
  output.id       = bio.id      
  output.server   = bio.server
  --
  if bio.Werewolf then
    output.Werewolf = true
    output.special    = 1
    output.special_bitetimerDisplay = "[No Skill]"
    output.special_bitetimer = -1
    
    local foundItem = ElderScrollsOfAlts:FindAbility(input, "world", "Werewolf", ElderScrollsOfAlts.BITE_WERE_ABILITY)
    if(foundItem~=nil and foundItem.purchased ) then
      output.special_bitetimerDisplay = "[Unk]"
      output.special_icon = foundItem["textureName"]
      
      --specialdata -> special (in ds)
      if(input.special~=nil)then
        local expiresAt = input.special.expiresAt
        if(expiresAt~=nil)then
          --Time in seconds left till expires
          local timeDiff = GetDiffBetweenTimeStamps( expiresAt, GetTimeStamp() )
          --ElderScrollsOfAlts.debugMsg("Buff timeDiff=".. tostring(timeDiff) )
          if(timeDiff<0) then
            output.special_bitetimer = 0
            output.special_bitetimerDisplay = "[v.v] (now!)"
          else
            output.special_bitetimer        = timeDiff
            output.special_bitetimerDisplay = ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,true,false)
          end
        else
          output.special_bitetimer = 0
          output.special_bitetimerDisplay = "[v.v] (now!)"
        end
      end--has special data
    end--foundItem
  end--ww
  --
  if bio.Vampire then
    output.Vampire = true
    output.special    = 1
    output.special_bitetimerDisplay = "[Not Skilled]"
    output.special_bitetimer = -1
    
    local foundItem = ElderScrollsOfAlts:FindAbility(input, "world", "Vampire", ElderScrollsOfAlts.BITE_VAMP_ABILITY)
    if(foundItem~=nil and foundItem.purchased ) then          
      output.special_bitetimerDisplay = "[Unk]"
      output.special_icon = foundItem["textureName"]
      
      --specialdata -> special (in ds)
      if(input.special~=nil)then
        local expiresAt = input.special.expiresAt
        if(expiresAt~=nil)then
          --Time in seconds left till expires
          local timeDiff = GetDiffBetweenTimeStamps( expiresAt, GetTimeStamp() )
          --ElderScrollsOfAlts.debugMsg("Buff timeDiff=".. tostring(timeDiff) )
          if(timeDiff<0) then
            output.special_bitetimer = 0
            output.special_bitetimerDisplay = "[v.v] (now!)"
          else
            output.special_bitetimer        = timeDiff
            output.special_bitetimerDisplay = ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,true,false)
          end
        else
          output.special_bitetimer = 0
          output.special_bitetimerDisplay = "[v.v] (now!)"
        end
      end--has special data
    end--foundItem
  end--vamp
  --
  if bio.canchamppts then
    output.champion = bio.champion
  else 
    output.champion = -1
  end
end

------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupGuiPlayerMiscLinesDS(output,input)   
  local bio			= input.bio
  local bags 		= input.bags
  local skillpoints = input.skillpoints
  local achieve 	= input.achieve
  local location 	= input.location
  local riding 		= input.riding
  -- DEFAULTS
  output.backpacksize  = 0
  output.backpackused  = 0
  output.backpackfree  = 0
  output.skillpoints   = 0
  output.secondsplayed = 0
  output.timeplayed    = "---"
  output.achieveearned = "-1"
  --SETUP
  output.secondsplayed = bio.secondsPlayed
  if bags ~= nil then
    output.backpacksize  = bags.backpackSize
    output.backpackused  = bags.backpackUsed
    output.backpackfree  = bags.backpackFree
  end
  --ElderScrollsOfAlts.debugMsg("bags0: bu=", output.backpackused, " bs=", output.backpacksize, " bf=", output.backpackfree)
  if skillpoints ~=nil then
    output.skillpoints   = skillpoints.skillpoints
  end
  --
  if(output.skillpoints==nil)then
    output.skillpoints = 0 --per recent version
  end
  if(output.secondsplayed==nil)then
    output.secondsplayed = 0 --per recent version
  else
    ElderScrollsOfAlts.view.accountData.secondsplayed = ElderScrollsOfAlts.view.accountData.secondsplayed+output.secondsplayed
    output.timeplayed = ElderScrollsOfAlts:timeToDisplay( (output.secondsplayed*1000) ,true,false)
  end
  --  
  --
  if( achieve~=nil and achieve.earned~=nil ) then
    output.achieveearned    = ZO_CommaDelimitNumber(achieve.earned)
    output.achieveearnedraw = achieve.earned
  end
  -- TIME
  local lastLogin = location.lastlogin
  output.lastlogin = ZO_FormatTime(lastLogin, TIME_FORMAT_STYLE_RELATIVE_TIMESTAMP, 
      TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  output.lastloginraw = lastLogin
  -- TIME
  local lastlogindiff = GetDiffBetweenTimeStamps(GetTimeStamp(), lastLogin)
  output.lastlogindiff = ZO_FormatTime(lastlogindiff, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, 
        TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  --
  -- RIDING
  output.riding_inventory = -1
  output.riding_speed     = -1
  output.riding_stamina   = -1
  output.riding_timems    = -1
  output.riding_totalDurationMs = -1
  output.riding_trainingready   = nil   
  output.riding_maxed           = false
  output.riding_trainer_ready   = false
  --output.riding_cantrain        = false
  --output.riding_timedisplay     = "--"
    
  if(riding~=nil)then
    if(riding~=nil)then
      output.riding_inventory = riding.inventory
      output.riding_speed     = riding.speed
      output.riding_stamina   = riding.stamina
      output.riding_timems          = riding.timeMs
      output.riding_totalDurationMs = riding.totalDurationMs
      output.riding_trainingready   = riding.trainingReadyAt
      
      if( riding.inventory==60 and riding.speed==60 and riding.stamina==60 ) then
        output.riding_maxed = true
        output.riding_timems = 99999999;
      else
        local timeDiff = GetDiffBetweenTimeStamps(output.riding_trainingready , GetTimeStamp())
        if( timeDiff ~= nil and timeDiff <= 0 ) then
          output.riding_trainer_ready = true
          output.riding_timems = 0;
        end
      end
      --if(riding.timeMs~=nil and riding.timeMs>-1)then
        --output.riding_timedisplay = ElderScrollsOfAlts:timeToDisplay( riding.timeMs, riding.timeDataTaken )
      --end
    end--riding element
  end  --misc element
  --
end


------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupGuiPlayerInfamyLinesDS(output,input)
	local infamy = input.infamy
	output.reducedbounty      = 0
	output.ReducedBounty_Rank = 0
	--
	output.LaundersUsed		= 0
	output.LaundersTotal	= 0
	output.SellsUsed		= 0
	output.SellsTotal		= 0
	--
	if( infamy ~= nil ) then
		output.ReducedBounty_Rank 		= infamy.reducedBounty
		output.reducedbounty 			= ZO_CommaDelimitNumber(infamy.reducedBounty)
		output.reducedbounty_displaytext  = infamy.displayText
		output.reducedbounty_bountytozero = infamy.bountytozero
		--
		output.LaundersUsed		= ElderScrollsOfAlts:getValueOrDefault(infamy.LaundersUsed,0)
		output.LaundersTotal	= ElderScrollsOfAlts:getValueOrDefault(infamy.LaundersTotal,0)
		output.SellsUsed		= ElderScrollsOfAlts:getValueOrDefault(infamy.SellsUsed,0)
		output.SellsTotal		= ElderScrollsOfAlts:getValueOrDefault(infamy.SellsTotal,0)
		output.LaunderReset 	= ElderScrollsOfAlts:getValueOrDefault(infamy.LaunderReset,0)
		--
		--[[
		output.reducedbounty_tooltip = infamy.displayText
		local timeDiff = GetDiffBetweenTimeStamps( infamy.bountytozero, GetTimeStamp() )
		if(infamy.reducedBounty>0) then
		if(timeDiff>0) then
		output.reducedbounty_timeleft = timeDiff
		output.reducedbounty_tooltip  =  infamy.displayText .. " and should expire in: " ..ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,true,false)
		else
		output.reducedbounty_tooltip  =  output.infamy.displayText .. " and should be expired"
		end
		--ElderScrollsOfAlts.debugMsg("reducedbounty_tooltip='"..tostring(output.reducedbounty_tooltip).."'")
		else
		output.reducedbounty_tooltip  =  output.infamy.displayText
		end
		ElderScrollsOfAlts.debugMsg("reducedbounty_tooltip='"..tostring(output.reducedbounty_tooltip).."'")
		]]--
	end
end


------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupGuiPlayerSkillsLinesDS(output,input)
  --Set Defaults
  --HACK! TODO fix? or not... ->
  local aTypes = {"Assault_Rank","Support_Rank","Legerdemain_Rank","Soul Magic_Rank","Werewolf_Rank","Vampire_Rank","Fighters Guild_Rank","Mages Guild_Rank","Undaunted_Rank","Thieves Guild_Rank","Dark Brotherhood_Rank","Psijic Order_Rank","Scrying_Rank","Excavation_Rank"}
  for rtK,rtV in pairs(aTypes) do
    --debugMsg("skills All "..k.." as="..rtK.." rtVT='"..tostring(rtV).."'")
    output[rtV] = 0
  end
  -- <- HACK! TODO fix
      
  -- Check if player even has skills
  local rTypes = {"ava","guild","world"}
  local skills = input.skills
  if(skills~=nil) then
    for rtK,rtV in pairs(rTypes) do
      --debugMsg("skills for "..k.." as="..rtK.." rtV="..tostring(rtV))
	  ElderScrollsOfAlts.debugMsg("SetSkills2: ", " rtV=", rtV )
      if(skills[rtV]~=nil)then
        local skillO = skills[rtV]
        if(skillO~=nil)then  
          local skillL = skillO
          if(skillL~=nil)then
            for rtKT,rtVT in pairs(skillL) do
              ElderScrollsOfAlts.debugMsg("skills rtKT=",tostring(rtKT)," rtVT=",tostring(rtVT))
              output[rtKT.."_Rank"] = rtVT.rank
              output[rtKT.."_Name"] = rtVT.name
              output[string.lower(rtKT).."_rank"] = rtVT.rank
              output[rtKT.."_SortKey"] = rtKT.."_Rank"
              output[rtKT.."_SortNumericType"] = true
              output[rtKT.."_LastRankXP"] = rtVT.lastRankXP
              output[rtKT.."_NextRankXP"] = rtVT.nextRankXP
              output[rtKT.."_CurrentXP"]  = rtVT.currentXP
              output[rtKT.."_XPCode"]     = -1
			  --
			  output[rtKT.."_isAccountSkill"]     = rtVT.isAccountSkill
			  output[rtKT.."_isClassMastery"]     = rtVT.isClassMastery
			  --
              if( rtVT.nextRankXP == 0 )then
                 output[rtKT.."_XPCode"] = 0
              elseif( rtVT.nextRankXP==nil or rtVT.currentXP==nil) then
                output[rtKT.."_XPCode"] = -1
                output[rtKT.."_Percentage"] = -1
              elseif( rtVT.nextRankXP > rtVT.currentXP )then
				--ie: lastRankXP:758000 nextRankXP:1158000 currentXP:758978  978/400000
                output[rtKT.."_XPCode"] = 1
				local nCurr = rtVT.currentXP  - rtVT.lastRankXP
				local nNext = rtVT.nextRankXP - rtVT.lastRankXP
                output[rtKT.."_Percentage"] =  math.floor(  (nCurr/nNext)*100  )
				local das = nCurr / nNext
				if(das~=nil and das~=0) then
					das = das*100
					output[rtKT.."_Perc"] = math.floor( das )
					--ElderScrollsOfAlts.debugMsg("setupgui: das ",das, " name=", rtVT.name)
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
                output[rtKT.."_subskills"] = sstext
                output[rtKT.."_subskillsA"] = sstextA
                output[rtKT.."_subskillsP"] = sstextP
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
  -- Output Class Skills
  if(skills~=nil) then
    local skillsC = skills.class
	if(skillsC~=nil)then  
		local idx = 1
		for rtK2,rtV2 in pairs(skillsC) do
			ElderScrollsOfAlts.debugMsg("skills rtKT2=",tostring(rtK2)," rtVT2=",tostring(rtV2))
			local rtKK = nil
			if(rtV2.isClassMastery==true ) then
			elseif(idx==1) then
				rtKK = "skillline1"
			elseif(idx==2) then
				rtKK = "skillline2"
			elseif(idx==3) then
				rtKK = "skillline3"
			end
			if(rtKK~=nil)then
				output[rtKK] = rtV2.name
				--output[rtKK.."_Name"] = rtV2.name
				output[rtKK.."_rank2"] = rtV2.rank
				--output[rtKK.."_baseline"] = rtK2
				output[rtKK.."_isAccountSkill"] = rtV2.isAccountSkill
				output[rtKK.."_isClassMastery"] = rtV2.isClassMastery
				idx = idx+1
			end
		end --for loop
	end -- skillsC~=nil
  end -- skills
  --
end


------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupPlayerLinesBuffsDS(output,input)
  local linedata = input.buffs
  if linedata == nil then return end
  for rtK, rtKV in pairs(linedata) do
    local tempn1 = string.format("buff_%s",rtK)
    local tempn3 = string.lower(tempn1)
    local tempn2 = tempn1.."_tooltip"
    output[tempn1.."_expiresAt"]    = rtKV.expiresAt
    --Time in seconds left till expires
    local timeDiff = GetDiffBetweenTimeStamps( rtKV.expiresAt, GetTimeStamp() )
    if(timeDiff<0) then
      output[tempn1] = "[n.a]"
      output[tempn2] = "[n.a]"
    else
      output[tempn1] = ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,false,true ) --timeMS,incDay,incSec)
      output[tempn2] = output[tempn1]
      output[tempn3] = output[tempn1]
    end
    --
    ElderScrollsOfAlts.debugMsg("setup  buff data for rtK: '", rtK, "' expires '", rtKV.expiresAt, "'" )
  end
end


------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupGuiPlayerLocLinesDS(output,input)
  local locationInfo = input.location
  if( locationInfo ~= nil ) then
    output.subzonename = locationInfo.subzoneName
    output.zonename    = locationInfo.zoneName
  else
    output.subzonename = ""
    output.zonename    = ""
  end
end


------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupGuiPlayerTradeLinesDS(output,input)
	ElderScrollsOfAlts.debugMsg("SetTrade2: Called" )
	--Setup Defaults
	local dEFvAL = 0
	output.alchemy         = dEFvAL
	output.alchemy_sunk    = dEFvAL
	output.alchemy_sinkmax = dEFvAL
	output.blacksmithing         = dEFvAL
	output.blacksmithing_sunk    = dEFvAL
	output.blacksmithing_sinkmax = dEFvAL   
	output.smithing         = dEFvAL
	output.smithing_sunk    = dEFvAL
	output.smithing_sinkmax = dEFvAL     
	output.clothing         = dEFvAL
	output.clothing_sunk    = dEFvAL
	output.clothing_sinkmax = dEFvAL   
	output.enchanting          = dEFvAL
	output.enchanting_sunk     = dEFvAL
	output.enchanting_sinkmax  = dEFvAL 
	output.enchanting_sunk2    = dEFvAL
	output.enchanting_sinkmax2 = dEFvAL             
	output.jewelry         = dEFvAL
	output.jewelry_sunk    = dEFvAL
	output.jewelry_sinkmax = dEFvAL 
	output.provisioning          = dEFvAL
	output.provisioning_sunk     = dEFvAL
	output.provisioning_sinkmax  = dEFvAL              
	output.provisioning_sunk2    = dEFvAL
	output.provisioning_sinkmax2 = dEFvAL              
	output.woodworking         = dEFvAL
	output.woodworking_sunk    = dEFvAL
	output.woodworking_sinkmax = dEFvAL              
	--
	--
	if( input.tradeskills == nil ) then
		return
	end
	local tradeskills = input.tradeskills
	--baseranks / [name].info / [name].subskills
	--
	-- Dynamic Names?
	--function ElderScrollsOfAlts:SetupGuiPlayerTradeLines2DS(tradeElem, tradeSkillElem, tplayerLine, destTradeName, tradeKeyName)
	for iName, dbItem in pairs(tradeskills) do
		local ffirst = iName:find(" ")
		ElderScrollsOfAlts.debugMsg("Trade2a: ", " iName='", iName, "' ffirst='", tostring(ffirst) , "'" )
		local info 		= tradeskills[iName].info
		local subskills = tradeskills[iName].subskills
		if(ffirst~=nil and ffirst>0) then
			ElderScrollsOfAlts.debugMsg("Load: trade as: iName=" , iName)
			ElderScrollsOfAlts:SetupGuiPlayerTradeLines2DS(info,subskills ,output,string.lower(iName),iName)  
			iName = string.sub(iName,1,ffirst)      
			ElderScrollsOfAlts.debugMsg("Load: trade as: iName=" , iName)
			ElderScrollsOfAlts:SetupGuiPlayerTradeLines2DS(info,subskills ,output,string.lower(iName),iName)  
		else
			ElderScrollsOfAlts.debugMsg("Load: trade as: iName=" , iName)
			--ElderScrollsOfAlts.debugMsg("Trade2a: ", " tradeL[iName]='", tostring(tradeL[iName]), "' tradeS[iName]='", tostring(tradeS[iName]) )
			--ElderScrollsOfAlts.debugMsg("Trade2a: ", " output='", tostring(output), "' iName='", tostring(iName) )
			ElderScrollsOfAlts:SetupGuiPlayerTradeLines2DS(info,subskills ,output, string.lower(iName), iName)  
		end
	end
end

--tradeKeyName uppercase (Woodworking)
--destTradeName lowercase (woodworking)
function ElderScrollsOfAlts:SetupGuiPlayerTradeLines2DS(tradeElem, tradeSkillElem, tplayerLine, destTradeName, tradeKeyName)
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


------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupGuiPlayerStatsLinesDS(output,input)
	local iInfo = input.stats
	if( iInfo ~= nil ) then
		output.stamina = iInfo.stamina
		output.magicka = iInfo.magicka
		output.health  = iInfo.health
		output.power   = iInfo.power
	else
		output.stamina = -1
		output.magicka = -1
		output.health  = -1
		output.power   = -1
	end
end


------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupAllianceWarPlayerLinesDS(output,input)  
  local alliancewar = input.ava
  if alliancewar == nil then return end
  ElderScrollsOfAlts.debugMsg("SetAva2: ", " currentCampaignId=", alliancewar.currentCampaignId, " guestCampaignId=", alliancewar.guestCampaignId )
  --Setup
  output.InCampaign           = ElderScrollsOfAlts:getValueOrDefault( alliancewar.inCampaign          ,"")
  output.GuestCampaignId      = ElderScrollsOfAlts:getValueOrDefault( alliancewar.guestCampaignId     ,"")
  --
  output.CurrentCampaignId   	 = ElderScrollsOfAlts:getValueOrDefault( alliancewar.currentCampaignId      ,"")
  output.CurrentCampaignAssigned = ElderScrollsOfAlts:getValueOrDefault( alliancewar.currentCampaignAssigned,"") 
  output.CurrentCampaignEndsAt   = ElderScrollsOfAlts:getValueOrDefault( alliancewar.CurrentCampaignEndsAt,"") 
  --
  output.AssignedCampaignId   		 = ElderScrollsOfAlts:getValueOrDefault( alliancewar.assignedCampaignId  ,"") 
  output.AssignedCampaignEndsSeconds = ElderScrollsOfAlts:getValueOrDefault( alliancewar.AssignedCampaignEndsSeconds,0) 
  output.AssignedCampaignEndsAt      = ElderScrollsOfAlts:getValueOrDefault( alliancewar.AssignedCampaignEndsAt,"") 
  output.assignedcampaignendsat      = output.AssignedCampaignEndsAt
  --
  output.AssignedCampaignEndsAt_value = output.AssignedCampaignEndsSeconds
  
  --
  if(alliancewar.AssignedCampaignEndsAt~=nil and alliancewar.AssignedCampaignEndsAt~="") then
    local timeDiff  = GetDiffBetweenTimeStamps( output.AssignedCampaignEndsAt,    GetTimeStamp() )
    --local timeDiff2 = GetDiffBetweenTimeStamps( output.AssignedCampaignIdSeconds, GetTimeStamp() )
    --output.AssignedCampaignEndsAt = timeDiff -- output.AssignedCampaignEndsAt - GetTimeStamp() 
    output.AssignedCampaignEndsAt = ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000) ,true,false)
    ElderScrollsOfAlts.debugMsg("AssignedCampaignEndsAt=", output.AssignedCampaignEndsAt )
    output.AssignedCampaignEndsAt_tooltip = output.AssignedCampaignEndsAt
    if(timeDiff<1) then
      output.AssignedCampaignEndsAtOver = true
    else
      output.AssignedCampaignEndsAtOver = false
    end
    ElderScrollsOfAlts.debugMsg("name:", output.name, " AssignedCampaignEndsAtOver=", output.AssignedCampaignEndsAtOver )
    --output.AssignedCampaignEndsAt = ZO_FormatTime( alliancewar.AssignedCampaignEndsAt, TIME_FORMAT_STYLE_RELATIVE_TIMESTAMP, TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  end
  
  output.GuestCampaignName    = ElderScrollsOfAlts:getValueOrDefault( alliancewar.guestCampaignName    ,"")  
  output.CurrentCampaignName  = ElderScrollsOfAlts:getValueOrDefault( alliancewar.currentCampaignName     ,"")
  output.AssignedCampaignName = ElderScrollsOfAlts:getValueOrDefault( alliancewar.assignedCampaignName ,"")  
  output.guestcampaignname    = ElderScrollsOfAlts:getValueOrDefault( alliancewar.guestCampaignName    ,"")
  output.currentcampaignname  = ElderScrollsOfAlts:getValueOrDefault( alliancewar.currentCampaignName     ,"")
  --
  output.assignedcampaignname = ElderScrollsOfAlts:getValueOrDefault( alliancewar.assignedCampaignName ,"")
  --
  local assignedCampaignLastloaded  = alliancewar.AssignedCampaignLastloaded
  if(assignedCampaignLastloaded~=nil) then
	-- TIME
	local lastAVAdiff = GetDiffBetweenTimeStamps(GetTimeStamp(), assignedCampaignLastloaded)
	output.assignedcampaignlastloadeddiff = ZO_FormatTime(lastAVAdiff, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, 
		TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
	output.AssignedCampaignLastloadedraw = assignedCampaignLastloaded
	output.AssignedCampaignLastloaded = ZO_FormatTime(assignedCampaignLastloaded, TIME_FORMAT_STYLE_RELATIVE_TIMESTAMP, 
		TIME_FORMAT_PRECISION_SECONDS, TIME_FORMAT_DIRECTION_DESCENDING)
  else
	output.AssignedCampaignLastloaded = "-"	
  end
  output.assignedcampaignlastloaded = output.AssignedCampaignLastloaded
  --
  output.IsInCampaign         = ElderScrollsOfAlts:getValueOrDefault( alliancewar.isInCampaign        ,"")  
  output.UnitAlliance         = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAlliance        ,"")
  output.AllianceName         = ElderScrollsOfAlts:getValueOrDefault( alliancewar.allianceName        ,"")
  output.UnitAvARank          = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAvARank         ,"")
  output.UnitAvARankPoints    = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAvARankPoints   ,"")
  output.unitavarank          = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAvARank         ,"")
  output.unitavarankpoints    = ElderScrollsOfAlts:getValueOrDefault( alliancewar.unitAvARankPoints   ,"")
  output.AvaSubRankStarts      = ElderScrollsOfAlts:getValueOrDefault( alliancewar.subRankStartsAt     ,"")
  output.AvaNextSubRank        = ElderScrollsOfAlts:getValueOrDefault( alliancewar.nextSubRankAt       ,"")
  output.AvaRankStarts         = ElderScrollsOfAlts:getValueOrDefault( alliancewar.rankStartsAt        ,"")
  output.AvaNextRank           = ElderScrollsOfAlts:getValueOrDefault( alliancewar.nextRankAt          ,"")
  output.AvaRankName          = ElderScrollsOfAlts:getValueOrDefault( alliancewar.avaRankName         ,"")
  --
  output.AssignedCampaignRewardEarnedTier = ElderScrollsOfAlts:getValueOrDefault( alliancewar.AssignedCampaignRewardEarnedTier, 0 )
  output.CurrentCampaignRewardEarnedTier = ElderScrollsOfAlts:getValueOrDefault( alliancewar.CurrentCampaignRewardEarnedTier, 0 )
  output.GuestCampaignRewardEarnedTier = ElderScrollsOfAlts:getValueOrDefault( alliancewar.guestCampaignRewardEarnedTier, 0 )
  --
  output.assignedcampaignrewardearnedtier = output.AssignedCampaignRewardEarnedTier
  output.currentCampaignrewardearnedTier  = output.CurrentCampaignRewardEarnedTier
  output.guestCampaignrewardearnedTier    = output.GuestCampaignRewardEarnedTier
  --
  output.assignedcampaignrewardprogress = alliancewar.AssignedCampaignRewardNextProgressTier
  output.assignedcampaignrewardtotal    = alliancewar.AssignedCampaignRewardNextTotalTier
  --
  if( ElderScrollsOfAlts.altData.showpercents and output.assignedcampaignrewardprogress~=nil and output.assignedcampaignrewardtotal~=nil ) then
	local das = output.assignedcampaignrewardprogress / output.assignedcampaignrewardtotal
	if(das~=nil and das~=0) then
		das = das*100
		output.assignedcampaignrewardearnedtierperc = math.floor( das )
	end
  end 
  --
  if(output.AssignedCampaignEndsAtOver) then
    --output.assignedcampaignrewardearnedtier = "("..output.assignedcampaignrewardearnedtier..")"
    --output.currentCampaignrewardearnedTier  = "("..output.currentCampaignrewardearnedTier..")"
    --output.guestCampaignrewardearnedTier    = "("..output.guestCampaignrewardearnedTier..")"
  end
  --
  --output.assignedcampaignrewardearnedtier_rank = output.AssignedCampaignRewardEarnedTier
  --output.currentCampaignrewardearnedTier_rank  = output.CurrentCampaignRewardEarnedTier
  --output.guestCampaignrewardearnedTier_rank    = output.GuestCampaignRewardEarnedTier
end


------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupPlayerLinesCurrencyDS(output,input)
  local currency = input.currency
  if currency == nil then return end 
  --Setup
  --Defaults
  output["currency_gold"] = 0
  output["currency_alliance point"] = 0
  output["currency_tel var stone"] = 0
  output["currency_writ vouchers"] = 0
  output["currency_transmute crystals"] = 0
  output["currency_crown gems"] = 0
  output["currency_crowns"] = 0
  output["currency_outfit change tokens"] = 0
  --Values
  for rtK, rtKV in pairs(currency) do
    ElderScrollsOfAlts.debugMsg("currency "..rtK.." as="..tostring(rtKV))    
    ElderScrollsOfAlts.debugMsg("currency "..tostring(rtKV.currencyName).." as="..tostring(rtKV.amount) )
    output["currency_"..string.lower(rtKV.currencyName)] = ZO_CommaDelimitNumber(rtKV.amount)
  end  
end


------------------------------
-- Translate from DataStore format to ESOA format
--
function ElderScrollsOfAlts:SetupGuiResearchPlayerLinesDS(output,input)
  local research = input.research
  local pName    = input.bio.name
  local rTypes = {"clothier","woodworking","blacksmithing","jewelcrafting"}
  -- Check if player even has this research slot
  --if( research ~= nil ) then 
  --rclothier1time,rclothier2time
  for rtK,rtV in pairs(rTypes) do
    ElderScrollsOfAlts.debugMsg("research for ",pName," as=",rtK," rtV=",tostring(rtV))    
    --Defaults
    output["r"..rtV.."1time"] = "--------"
    output["r"..rtV.."2time"] = "--------"
    output["r"..rtV.."3time"] = "--------"
    output["r"..rtV.."code"] = -1
    output["r"..rtV.."1s"] = -5
    output["r"..rtV.."2s"] = -5
    output["r"..rtV.."3s"] = -5
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
        --debugMsg("ESOA: setup ResearchItem: output[mKye.."S"] = timeS="
        if(researchMS==nil) then
          output[mKye.."time"] = ""
          output[mKye.."code"] = 0
          output[mKye.."s"] = -4
        elseif(kkiT<=researchMS) then
          output[mKye.."time"] = GetString(ESOA_RESEARCH_AVAIL) --"[avail]"
          output[mKye.."code"] = 1
          output[mKye.."s"] = 0
          if(rrLinesMatch) then
            output[mKye.."time"] = "[xxxxx]"-- GetString(ESOA_RESEARCH_AVAIL) --"[avail]"
            output[mKye.."tooltip"] = string.format("%s%s%s%s",pName," knows all traits in ",rtV,"!")
            output[mKye.."code"] = -3
            output[mKye.."s"] = -3
          end
        else
          output[mKye.."time"] = "--------"
          output[mKye.."code"] = 0
          output[mKye.."s"] = -2
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
          local nowDiff = GetDiffBetweenTimeStamps( GetTimeStamp() , input.research.now ) --secconds
          --if(input.version==nil) then
          --  nowDiff = GetFrameTimeSeconds() - input.research.now
          --  --nowDiff = GetTimeStamp() - vv.timeTillReady
          --end
          local timeS = vv.timeRemainingSecs - nowDiff          
          --if(input.version~=ElderScrollsOfAlts.version) then
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
            output[mKye.."code"] = 1
          elseif(timeD>0) then
            timeDisp2Str = "<<1>>d<<2>>h<<3>>m"
          else
            timeDisp2Str = "<<2>>h<<3>>m"
          end
          if(timeS>0) then
            output[mKye.."code"] = 2
          end
          local timeDisp2 = zo_strformat(timeDisp2Str, timeD,timeH,timeM )
          local timeDisp = timeD.."d" ..timeH.."h" ..timeM.."m"
          --if(input.version==nil) then -- Whats this for self? a bad version needed this? or good?
          --  output[mKye.."code"] = 3
          --  timeDisp2 = "*"..timeDisp2
          --end          
          output[mKye.."name"] = vv.name
          output[mKye.."time"] = timeDisp2
          output[mKye.."D"] = timeD
          output[mKye.."H"] = timeH
          output[mKye.."S"] = timeS
          output[mKye.."s"] = timeS
          --TODO timeTillReady
          --debugMsg("research for "..k.." mKye="..mKye.. " research: " .. vv.name .. " D="..timeD .." H="..timeH .." M="..timeM)
          output[mKye.."TraitType"] = vv.traitType
          output[mKye.."TraitDesc"] = vv.traitDescription
          output[mKye.."Traitknown"] = vv.known
          output[mKye.."NumTraitsKnown"] = vv.numTraitsKnown
          --        
          kki = kki+1
        end 
      end
    end
  end
end

------------------------------
-- Translate from DataStore format to ESOA 
--output,input)
function ElderScrollsOfAlts:SetupPlayerLinesCustomDS(output, input)
	--local cvalues = ESOADatastore.getCurrentCharcterCustomData(playerLineKey, keyName)
	local custom = input.custom
	if( custom ~= nil ) then
		output.note			= custom.note
		output.category		= custom.category
		output.playersorder	= custom.playersorder
	end
end

--
function ElderScrollsOfAlts:SetupPlayerLinesCompanionsDS(output, input, dName)
	ElderScrollsOfAlts.debugMsg("FlattenCompanion: Called for:'", input.charkey,"'" )
	-- Defaults
	for ii = 1, ElderScrollsOfAlts.maxCompanions do
		local tempn0 = string.format("companion_%s",ii)
		output[tempn0.."_name"]    = "-none-"
		output[tempn0.."_level"]   = -1
		output[tempn0.."_rapport"] = -1
		output[tempn0.."_currentexperience"] = -1
		output[tempn0.."_experienceforlevel"] = -1
	end
	-- Real Data
	local linedata = input.companions
	--ElderScrollsOfAlts.debugMsg("FlattenCompanion: linedata:" , tostring(linedata) )
	if linedata == nil then
		ElderScrollsOfAlts.debugMsg("FlattenCompanion: no lineata --DONE" )
		return
	end  
	local cnt = ElderScrollsOfAlts:tablelength(linedata.ids)
	ElderScrollsOfAlts.debugMsg("FlattenCompanion: cnt:" , cnt )
	if cnt == nil then
		ElderScrollsOfAlts.debugMsg("FlattenCompanion: no cnt --DONE" )
		return
	end
	-- KEYS -- sorted by release of companion -- table(index, companion#)
	local ordered_keys={}
	if(linedata.data~=nil) then
		for k in pairs(linedata.data) do
			table.insert(ordered_keys, k)
		end
	end
	table.sort(ordered_keys)
	--[[
	for i = 1, #ordered_keys do
		local k, v = ordered_keys[i], linedata.data[ ordered_keys[i] ]
		ElderScrollsOfAlts.outputMsg("FlattenCompanion: keyset: k:" , k, " v:",tostring(v) )
	end
	]]
	-- Fill in Output with Real Data -- aligned to the first entry
	local cInc = 1
	for i = 1, #ordered_keys do
		local k, ldata = ordered_keys[i], linedata.data[ ordered_keys[i] ]
		local companionId = k
		if(ldata~=nil) then
			--ElderScrollsOfAlts.debugMsg( "FlattenCompanion:"," kk=",kk," vv=",vv," ldata=", tostring(ldata),".")	
			local tempn = string.format("companion_%s",cInc)
			output[tempn.."_name"]    = ldata.name
			output[tempn.."_rapport"] = ldata.rapport
			--
			local accountElem  = EchoESOADatastore.svESOADataAW[dName].companions
			local cMaxLevel = false
			if(accountElem~=nil and accountElem[companionId]~=nil) then
				--ElderScrollsOfAlts.debugMsg( "FlattenCompanion: using account lvl for dName=",dName," companionId=" ,companionId)
				output[tempn.."_level"]  			 = accountElem[companionId].level
				output[tempn.."_currentexperience"]  = accountElem[companionId].currentExperience
				output[tempn.."_experienceforlevel"] = accountElem[companionId].experienceForLevel
				if(accountElem[companionId].level==ElderScrollsOfAlts.maxCompanionLevel) then
					cMaxLevel = true
				end
			end
			--if there is local companion data check it, and not at max level in account data...
			if(ldata.level~=nil and not cMaxLevel ) then
				if( ldata.level >= output[tempn.."_level"] ) then
					output[tempn.."_level"]   			 = ldata.level
					output[tempn.."_currentexperience"]  = ldata.currentExperience
					output[tempn.."_experienceforlevel"] = ldata.experienceForLevel			
				end
			end
			--
			ElderScrollsOfAlts.debugMsg("companion data: tempn: '", tempn, "' set '", tempn.."_name", "' as '", ldata.name, "'" )
			cInc = cInc +1
		end
	end
	ElderScrollsOfAlts.debugMsg( "FlattenCompanion: done")
  --SetupPlayerLinesCompanions
end

------------------------------
-- Translate from DataStore format to ESOA format
--output,input)
function ElderScrollsOfAlts:SetupPlayerLinesTrackingDS(output, input)
  local tracking = input.tracking
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
        output[tempn.."_time"]  = rtKV2.completedtime
        output[tempn.."_done"]  = rtKV2.completed
        output[tempn.."_reset"] = rtKV2.resettime
        --d("timestring: " .. GetDateStringFromTimestamp(rtKV2.completedtime) )
        --d("timediff: " .. GetDiffBetweenTimeStamps(GetTimeStamp(),rtKV2.completedtime) )
        --if diff is negative, it was previous
        -- so what time to compare to to get if it was done today?
        --[15:32] [15:32] >tempn: "tracking_writs_Jewelry Crafting Writ"
      end
    end
  end  
end

------------------------------
-- Translate from DataStore format to ESOA format
--output,input)
function ElderScrollsOfAlts:SetupGuiPlayerEquipLinesDS(output, input)
	local equipment = input.equipment
	--Defaults
	output.heavy  = 0
	output.medium = 0
	output.light  = 0
	local EMPTYLINE = ""
	output.Head       = EMPTYLINE
	--output.Head_Link  = ev.itemLink     
	output.Head_Type  = EMPTYLINE     
	output.Chest  = EMPTYLINE
	--output.Chest_Link  = ev.itemLink
	output.Chest_Type  = EMPTYLINE     
	output.Feet  = EMPTYLINE
	--output.Feet_Link  = ev.itemLink          
	output.Feet_Type  = EMPTYLINE     
	output.Hands  = EMPTYLINE
	--output.Hands_Link  = ev.itemLink          
	output.Hands_Type  = EMPTYLINE
	output.Legs  = EMPTYLINE
	--output.Legs_Link  = ev.itemLink          
	output.Legs_Type  = EMPTYLINE
	output.Shoulders  = EMPTYLINE
	--output.Shoulders_Link  = ev.itemLink
	output.Shoulders_Type  = EMPTYLINE
	output.Waist  = EMPTYLINE
	-- output.Waist_Link  = ev.itemLink          
	output.Waist_Type  = EMPTYLINE
	output.Neck  = EMPTYLINE
	--output.Neck_Link    = ev.itemLink          
	--output.Neck_Quality = ev.quality
	output.Ring2  = EMPTYLINE
	--output.Ring2_Link    = ev.itemLink  
	--output.Ring2_Quality = ev.quality
	output.Ring1  = EMPTYLINE
	--output.Ring1_Link    = ev.itemLink  
	--output.Ring1_Quality = ev.quality
	output.O1  = EMPTYLINE
	--output.O1_Link  = ev.itemLink  
	--output.O1_WeaponType  = ev.weaponType  
	output.M1  = EMPTYLINE
	--output.M1_Link  = ev.itemLink  
	--output.M1_WeaponType  = ev.weaponType  
	output.M2  = EMPTYLINE
	--output.M2_Link  = ev.itemLink              
	-- output.M2_WeaponType  = ev.weaponType  
	output.O2  = EMPTYLINE
	--output.O2_Link  = ev.itemLink  
	--output.O2_WeaponType  = ev.weaponType  
	output.M2  = EMPTYLINE
	--output.M2_Link  = ev.itemLink  
	--output.M2_WeaponType  = ev.weaponType  
	output.Op  = EMPTYLINE
	--output.Op_Link  = ev.itemLink
	output.Mp  = EMPTYLINE
	--output.Mp_Link  = ev.itemLink  
	--
	if equipment == nil then 
		--ElderScrollsOfAlts.debugMsg("SetupGuiPlayerEquipLinesDS: no equipment section for : [",input.name,"]" )
		return
	end
	if equipment.slots == nil then
		--ElderScrollsOfAlts.debugMsg("SetupGuiPlayerEquipLinesDS: no equipment slots section for : [",input.name,"]" )
		return
	end
	--
	local equip = equipment.slots
	for ek, ev in pairs(equip) do
		if ek == nil then return end
		--ElderScrollsOfAlts.debugMsg(" equip " .. ek)
		local tarmortype = 0
		local lLine = ""
		--Armor Types
		if ev.armorType ~=nil then
			output.armortype = 0
			if( ev.armorType == ARMORTYPE_HEAVY ) then
				lLine = "H"
				output.heavy = output.heavy +1
				tarmortype = 1
			elseif( ev.armorType == ARMORTYPE_MEDIUM ) then
				output.medium = output.medium +1
				lLine = "M"
				tarmortype = 2
			elseif( ev.armorType == ARMORTYPE_LIGHT ) then
				output.light = output.light +1
				lLine = "L"
				tarmortype = 3
			end
		end
		--Armor Types/Slots
		if ev.equipType == EQUIP_TYPE_HEAD then
			output.Head       = lLine
			output.Head_Link  = ev.itemLink     
			output.Head_Type  = tarmortype     
		elseif ev.equipType == EQUIP_TYPE_CHEST then
			output.Chest  = lLine
			output.Chest_Link  = ev.itemLink
			output.Chest_Type  = tarmortype     
		elseif ev.equipType == EQUIP_TYPE_FEET then --10
			output.Feet  = lLine
			output.Feet_Link  = ev.itemLink          
			output.Feet_Type  = tarmortype     
		elseif ev.equipType == EQUIP_TYPE_HAND then
			output.Hands  = lLine
			output.Hands_Link  = ev.itemLink          
			output.Hands_Type  = tarmortype
		elseif ev.equipType == EQUIP_TYPE_LEGS then
			output.Legs  = lLine
			output.Legs_Link  = ev.itemLink          
			output.Legs_Type  = tarmortype
		elseif ev.equipType == EQUIP_TYPE_SHOULDERS then
			output.Shoulders  = lLine
			output.Shoulders_Link  = ev.itemLink
			output.Shoulders_Type  = tarmortype
		elseif ev.equipType == EQUIP_TYPE_WAIST then
			output.Waist  = lLine
			output.Waist_Link  = ev.itemLink          
			output.Waist_Type  = tarmortype
		elseif ev.equipType == EQUIP_TYPE_NECK then
			output.Neck  = "O"
			output.Neck_Link    = ev.itemLink          
			output.Neck_Quality = ev.quality
		elseif ev.equipType == EQUIP_TYPE_RING then
			if( ev.slotId == EQUIP_SLOT_RING1) then
				output.Ring2  = "O"
				output.Ring2_Link    = ev.itemLink  
				output.Ring2_Quality = ev.quality
			elseif( ev.slotId == EQUIP_SLOT_RING2) then
				output.Ring1  = "O"
				output.Ring1_Link    = ev.itemLink  
				output.Ring1_Quality = ev.quality
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
				output.O1  = "O"
				output.O1_Link  = ev.itemLink  
				output.O1_WeaponType  = ev.weaponType  
			elseif( ev.slotId == EQUIP_SLOT_MAIN_HAND) then --4
				output.M1  = "O"
				output.M1_Link  = ev.itemLink  
				output.M1_WeaponType  = ev.weaponType  
			elseif( ev.slotId == EQUIP_SLOT_OFF_HAND) then --5
				output.M2  = "O"
				output.M2_Link  = ev.itemLink              
				output.M2_WeaponType  = ev.weaponType  
			end
		elseif ev.equipType == EQUIP_TYPE_OFF_HAND then --7
			--debugMsg("1h2 itemLink: "..ev.itemLink .." slotid="..tostring(ev.slotId) )
			if( ev.slotId == EQUIP_SLOT_BACKUP_OFF) then --21
				--debugMsg("Set O2 to "..ev.itemName)
				output.O2  = "O2"
				output.O2_Link  = ev.itemLink  
				output.O2_WeaponType  = ev.weaponType  
			elseif( ev.slotId == EQUIP_SLOT_OFF_HAND) then --5
				output.M2  = "O"
				output.M2_Link  = ev.itemLink  
				output.M2_WeaponType  = ev.weaponType  
			end 
		elseif ev.equipType == EQUIP_TYPE_TWO_HAND then 
			--debugMsg("2h itemLink: "..ev.itemLink .." slotid="..tostring(ev.slotId) )
			if( ev.slotId == EQUIP_SLOT_BACKUP_MAIN) then
				--debugMsg("Set O1(b) to "..ev.itemName)
				output.O1  = "O"
				output.O1_Link  = ev.itemLink  
				output.O1_WeaponType  = ev.weaponType  
			elseif( ev.slotId == EQUIP_SLOT_MAIN_HAND) then
				output.M1  = "O"
				output.M1_Link  = ev.itemLink  
				output.M1_WeaponType  = ev.weaponType  
			end
		elseif ev.equipType == EQUIP_TYPE_POISON then
			if( ev.slotId == EQUIP_SLOT_BACKUP_POISON) then
				output.Op  = "O"
				output.Op_Link  = ev.itemLink
			elseif( ev.slotId == EQUIP_SLOT_POISON) then
				output.Mp  = "O"
				output.Mp_Link  = ev.itemLink  
			end
		end
	end --pairs(equip)
end

------------------------------
-- Translate from DataStore format to ESOA format
--output,input)
function ElderScrollsOfAlts:SetupPlayerLinesCPDS(output, input)

end

------------------------------
-- Translate from DataStore format to ESOA format
--output,input)
------------------------------


------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataLevelDS(companionId, cname, level, currentExperience, experienceForLevel)
	local playerKey = ElderScrollsOfAlts.view.currentplayerkey 
	ESOADatastore.saveCompanionDataLevel(playerKey, companionId, cname, level, currentExperience, experienceForLevel)
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataSkillRankDS(companionId, cname, skillLineId, slName, rank )
	ElderScrollsOfAlts.debugMsg("CollectCompanionDataSkillRankDS: Called")
	local playerKey = ElderScrollsOfAlts.view.currentplayerkey 
	ESOADatastore.saveCompanionDataSkillRank(playerKey, companionId, cname, skillLineId, slName, rank )
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataSkillLineDS(companionId, cname, skillLineId, slName )
	ElderScrollsOfAlts.debugMsg("CollectCompanionDataSkillLineDS: Called")
	local playerKey = ElderScrollsOfAlts.view.currentplayerkey 
	ESOADatastore.saveCompanionDataSkillLine(playerKey, companionId, cname, skillLineId, slName )
end

------------------------------
--Companions
function ElderScrollsOfAlts:CollectCompanionDataRapportDS(companionId, cname, currentRapport)
	ElderScrollsOfAlts.debugMsg("CollectCompanionDataRapportDS: Called[",companionId,"] cname=",cname, " rapp=", tostring(currentRapport) )
	local playerKey = ElderScrollsOfAlts.view.currentplayerkey 
	ESOADatastore.saveCompanionDataRapport(playerKey, companionId, cname, currentRapport )
end

------------------------------
-- 
function ElderScrollsOfAlts.SavePlayerDataDS( playerLineKey, keyName, elementData )
	ElderScrollsOfAlts.debugMsg("SavePlayerDataDS: playerKey=",playerLineKey," keyName=",keyName," as ", elementData) 
	ESOADatastore.saveCharcterCustomData(playerLineKey, keyName, elementData)
end


------------------------------
-- 
function ElderScrollsOfAlts:SaveTrackingDataDS( trackingType,trackingName,isCompleted,completedTimeStamp,timeToReset )
   ----Section: Statup section
  --local pID       = GetCurrentCharacterId()
  --local pServer   = GetWorldName()
  --local playerKey =  zo_strformat("<<1>>_<<2>>", pID, pServer:gsub(" ","_") )  
  local playerKey = ElderScrollsOfAlts.GeneratePlayerKeyForCurrentCharacter()
  ----Section: Save section
  ESOADatastore.saveCharcterTrackingData(playerKey, trackingType,trackingName,isCompleted,completedTimeStamp,timeToReset )
end

------------------------------
-- 
----------------------------------------
 --[[ ESOA Data Legacy ]]-- 
----------------------------------------