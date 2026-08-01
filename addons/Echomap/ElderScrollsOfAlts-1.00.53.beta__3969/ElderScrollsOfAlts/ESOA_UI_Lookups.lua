--[[ ESOA GUI Lookups ]]-- 
 
----------------------------------------
-- Used by the UI to go from player data to column data
-- i.e. filling inthe chart from the in memory data
----------------------------------------


------------------------------
-- View Lookup, show data
function ElderScrollsOfAlts.GuiCharLineLookupPopulateData(viewname,viewKey,eline,playerLine)
  ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: 1viewKey: '" , tostring(viewKey), "'" )
  if(eline==nil) then return end
  eline.viewKey = viewKey
  if(viewKey=="Special") then
    local werewolf = playerLine["Werewolf"]
    local vampire  = playerLine["Vampire"] 
    eline.special = 0
	local nHint = "Double LEFT Click to select row for " .. playerLine["name"]
    if werewolf then
      eline.special = 1
	  --eline:GetChild(1):SetResizeToFitFile(false) 
      eline:GetChild(1):SetTexture("/esoui/art/icons/store_werewolfbite_01.dds")
      eline.tooltip = playerLine.name .. " is a ".."Werewolf (" .. tostring(playerLine.special_bitetimerDisplay) ..")" .. string.char(10) .. string.char(10) .. nHint
    elseif vampire then
      eline:GetChild(1):SetTexture("/esoui/art/icons/store_vampirebite_01.dds")
      eline.special = 2
	  --eline:GetChild(1):SetResizeToFitFile(false) 
      eline.tooltip = playerLine.name .. " is a ".."Vampire (" .. tostring(playerLine.special_bitetimerDisplay) ..")".. string.char(10) .. string.char(10) .. nHint
	else
		eline.tooltip = nHint
    end
	eline:SetHandler("OnMouseDoubleClick", function(...) ElderScrollsOfAlts:GUILineDoubleClick(...) end )
    --TODO timers
  elseif(viewKey=="SpecialBiteTimer") then    
    eline:SetText( playerLine.special_bitetimerDisplay )
    eline.value = playerLine.special_bitetimerDisplay
    if( playerLine.Werewolf == true or playerLine.Vampire == true) then
      local canBite = ""
      if( playerLine.special_bitetimer~=nil and playerLine.special_bitetimer==0)then
        canBite = "Bite" --localize
        eline:SetText( canBite )
      end
      eline.tooltip = "("..tostring(playerLine.special_bitetimerDisplay) ..")"..canBite
      --TODO eline.tooltip = playerLine.name .. " is a ".."Vampire (" .. tostring(playerLine.special_bitetimerDisplay) ..")"
    end
  elseif(viewKey=="Note" or viewKey=="note") then
    eline.tooltipHdr = "Note: " .. playerLine["name"]
    local nHint = "Double LEFT Click to select row, OR, Double RIGHT Click to set a Note"
    if( playerLine["note"]==nil or playerLine["note"]=="") then --TODO string.len (s)?
	  eline:GetChild(1):SetTexture("/esoui/art/icons/heraldrybg_onion_01.dds")
      eline.tooltip = nHint
    else
      --art\store\pc_crwn_crown_1x1.dds
      eline:GetChild(1):SetTexture("/esoui/art/icons/quest_letter_001.dds")      
      eline.tooltip = playerLine["note"] .. string.char(10) .. string.char(10) .. nHint
    end
	--not a functionlocal nTexture = eline:GetTexture()
	--eline:SetMouseEnabled(true)
    eline:SetHandler("OnMouseDoubleClick", function(...) ElderScrollsOfAlts:GUILineDoubleClick(...) end )
	--eline:SetHandler('OnMouseEnter',function(self) ElderScrollsOfAlts:TooltipEnter(self, viewKey ) end)
	--eline:SetHandler('OnMouseExit',function(self) ElderScrollsOfAlts:TooltipExit(self) end)  
	--d("(" .. ElderScrollsOfAlts.name .. ") IsMouseEnabled=" ..  tostring(eline:IsMouseEnabled())  )
    --eline:SetHandler('OnMouseDoubleClick',function(control, button)
    --    ElderScrollsOfAlts:GUILineDoubleClick(control, button)
    --end)
  elseif(viewKey=="Alliance") then
    local pAlliance  = playerLine["alliance"]
	local psAlliance = GetAllianceName(nAliance)
    eline.alliance = pAlliance
    if pAlliance ~= nil then
      local pAllIcon = ElderScrollsOfAlts:GetAllianceIcon(pAlliance);
      eline:GetChild(1):SetTexture(pAllIcon)  
      eline.tooltip = zo_strformat("<<1>> is in the <<2>>", playerLine.name,  psAlliance )
	  --eline:SetHandler('OnMouseEnter',function(self)
		--  ElderScrollsOfAlts:TooltipEnterStub(self, self.entry)
	  --end)
	  --eline:SetHandler('OnMouseExit',function(self)
		--	ElderScrollsOfAlts:TooltipExitStub(self)
	 -- end) 
    end
  elseif(viewKey=="Alliance Name" or viewKey=="alliance name") then
    local pAlliance = playerLine["alliance"]
	--local psAlliance = GetAllianceName(nAliance)
    eline.allianceid = pAlliance
    --TODO alliance name
    eline.alliance = GetAllianceName(pAlliance) 
    eline.tooltip = zo_strformat("<<1>> is in the <<2>>", playerLine.name,  pAlliance )
  elseif(viewKey=="Class" or viewKey=="class") then
    eline:SetText( ElderScrollsOfAlts:GetClassText(playerLine["class"]) )
    eline.tooltip = playerLine.name .. " is a ".. ElderScrollsOfAlts:GetClassText(playerLine["class"])
  elseif(viewKey=="Level" or viewKey=="level") then
    eline.tooltip = playerLine.name .. " is level ".. playerLine["level"]
    eline:SetText( playerLine["level"] )
    eline.value = playerLine["level"]
    if playerLine["champion"] == nil or playerLine["champion"] < 0 then
      --eline.tooltip = playerLine.name .. " is level ".. playerLine["level"]    
      local uxm = playerLine["unitxpmax"]
      local ux  = playerLine["unitxp"]
      local uxP = 0
      if( ux~=nil and uxm~=nil ) then
        uxP = ( ux / uxm ) * 100 
      end
      if ( ux~=nil and ux > 1 and uxm~=nil and uxm>0) then
        eline.tooltip = zo_strformat("<<1>> is level <<2>> <<3>> (<<4>>/<<5>> <<6>>%)", playerLine.name, playerLine["level"], string.char(10), ZO_CommaDelimitNumber(ux), ZO_CommaDelimitNumber(uxm), uxP )
      end
    else
      --eline:SetText( playerLine["level"] .."("..playerLine["champion"]..")" )
      eline.tooltip = playerLine.name .. " is level ".. playerLine["level"] .." ("..playerLine["champion"].."cp)"
    end
  elseif(viewKey=="Race" or viewKey=="race") then
    eline:SetText( ElderScrollsOfAlts:GetRaceText1(playerLine["race"]) )
    eline.tooltip = playerLine.name .. " is a ".. playerLine["race"] 
  elseif(viewKey=="Gender") then
    local genderText = ElderScrollsOfAlts:GetGenderText(playerLine["gender"])
    eline:SetText( genderText )
    eline.tooltip = playerLine.name .. " is a ".. ElderScrollsOfAlts:GetGenderFullText(playerLine["gender"])
  elseif(viewKey=="Level") then    
    eline:SetText( playerLine["level"] )
    eline.tooltip = playerLine.name .. " is level ".. playerLine["level"]
    if (playerLine["unitxp"]~=nil and playerLine["unitxp"]>0) then
      eline.tooltip = zo_strformat("<<1>> (<<2>>/<<3>>)",eline.tooltip, playerLine["unitxp"], playerLine["unitxpmax"] )
    end
  --
  elseif(viewKey=="Assault" or viewKey=="Support" or viewKey=="Legerdemain" or viewKey=="Soul Magic" or viewKey=="Werewolf" or viewKey=="Vampire" or viewKey=="Fighters Guild" or viewKey=="Mages Guild" or viewKey=="Undaunted" or viewKey=="Thieves Guild" or viewKey=="Dark Brotherhood" or viewKey=="Psijic Order" or viewKey=="Scrying" or viewKey=="Excavation" and playerLine[viewKey.."_Rank"] ~= nil ) then
    local viewXlate = viewKey
    if(ElderScrollsOfAlts.view.viewkeyXlate~=nil) then
      viewXlate = ElderScrollsOfAlts.view.viewkeyXlate[viewKey]
    end
    eline.value = playerLine[viewXlate.."_Rank"] 
    eline.sort_data = eline.value
    eline.sort_numeric =  true
    local skillMax = ElderScrollsOfAlts.SkillsLevelMaximum[viewXlate]
    
    --
    if( (eline.value == nil or eline.value == 0) and ElderScrollsOfAlts.savedVariables.colors.colorTimerNone~=nil ) then      
      eline:SetText( ElderScrollsOfAlts.ColorText( ElderScrollsOfAlts.savedVariables.colors.colorTimerNone, eline.value  ) )
    else
      eline:SetText( eline.value  )
    end
   
    local rankStr = nil
    if(skillMax~=nil)then
      rankStr = playerLine[viewXlate.."_Rank"] .. "/"..skillMax
    else
      rankStr = playerLine[viewXlate.."_Rank"]
    end
    eline.tooltip = zo_strformat("<<1>> has <<2>> skill of <<3>>",
            playerLine.name, viewKey, rankStr )
    --
    if( playerLine[viewXlate.."_XPCode"]~=nil )then
      if( playerLine[viewXlate.."_XPCode"]==0 )then
        local sHint = zo_strformat("<<1>> has <<2>> skill of <<3>> <<4>>",
            playerLine.name, viewKey, rankStr, "(MAX)" )
        eline.tooltip = sHint        
      elseif( playerLine[viewKey.."_Percentage"]~=nil and playerLine[viewXlate.."_Percentage"]>0) then
        local sHint = zo_strformat("<<1>> <<2>> skill of <<3>> (<<4>>/<<5>>) <<6>>%",
            playerLine.name, viewKey, rankStr, playerLine[viewKey.."_CurrentXP"], playerLine[viewKey.."_NextRankXP"], playerLine[viewKey.."_Percentage"])
        eline.tooltip = sHint    
      end
    end
    --EchoBuffs.Colorize(EchoExperience.author, "AAF0BB"),
    
  --
  elseif(viewKey=="Alchemy") then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(string.lower(viewKey),eline,playerLine,string.lower(GetString(ESOA_FULL_ALC)) ) --"alchemy")--,"alchemy_sunk","alchemy_sunk2")    
  elseif(viewKey=="Smithing" or viewKey=="Blacksmithing") then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(string.lower(viewKey),eline,playerLine,string.lower(GetString(ESOA_FULL_SMTH)) ) --"blacksmithing")
  elseif(viewKey=="Clothing") then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(string.lower(viewKey),eline,playerLine,string.lower(GetString(ESOA_FULL_CLTH)) ) --"clothing")
  elseif(viewKey=="Enchanting") then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(string.lower(viewKey),eline,playerLine,string.lower(GetString(ESOA_FULL_ENCH)) ) --"enchanting")
  elseif(viewKey=="JC") then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(string.lower(viewKey) ,eline,playerLine,string.lower(GetString(ESOA_FULL_JC)) ) --"jewelry")
  elseif(viewKey=="Jewelry") then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(string.lower(viewKey), eline,playerLine, string.lower(GetString(ESOA_FULL_JC)) ) --"jewelry")
 elseif(viewKey=="Provisioning") then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(string.lower(viewKey),eline,playerLine,string.lower(GetString(ESOA_FULL_PROV)) ) --"provisioning")
  elseif(viewKey=="Woodworking") then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(string.lower(viewKey),eline,playerLine,string.lower(GetString(ESOA_FULL_WOOD)) ) --"woodworking")
    
    --xxxxx
  --elseif(viewKey==GetString(ESOA_FULL_JC) ) then
    --ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData("jewelry",eline,playerLine, string.lower(viewKey) )
    --ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(viewKey  ,eline,playerLine, string.lower(viewKey) )
  --
  elseif(viewKey=="Clothier Research 1") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"clothier",1)
  elseif(viewKey=="Clothier Research 2") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"clothier",2)
  elseif(viewKey=="Clothier Research 3") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"clothier",3)
  elseif(viewKey=="Blacksmithing Research 1") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"blacksmithing",1)
  elseif(viewKey=="Blacksmithing Research 2") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"blacksmithing",2)
  elseif(viewKey=="Blacksmithing Research 3") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"blacksmithing",3)
  elseif(viewKey=="Woodworking Research 1") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"woodworking",1)
  elseif(viewKey=="Woodworking Research 2") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"woodworking",2)
  elseif(viewKey=="Woodworking Research 3") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"woodworking",3)
  elseif(viewKey=="Jewelcrafting Research 1") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"jewelcrafting",1)
  elseif(viewKey=="Jewelcrafting Research 2") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"jewelcrafting",2)
  elseif(viewKey=="Jewelcrafting Research 3") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,"jewelcrafting",3)
  -- 
  elseif(viewKey=="Heavy" or viewKey=="Medium" or viewKey=="Light") then    
    ElderScrollsOfAlts:GuiCharLineLookupPopulateEquipData(viewKey,eline,playerLine, viewKey:lower())
  --  
  elseif(viewKey=="Head" or viewKey=="Shoulders" or viewKey=="Chest" or viewKey=="Waist" or viewKey=="Legs" or viewKey=="Hands" or viewKey=="Feet" ) then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateEquipData(viewKey,eline,playerLine, viewKey )
  elseif(viewKey=="Neck" or viewKey=="Ring1" or viewKey=="Ring2" ) then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateEquipData(viewKey,eline,playerLine, viewKey )
  elseif(viewKey=="M1" or viewKey=="M2" or viewKey=="Mp" or viewKey=="O1" or viewKey=="O2" or viewKey=="Op" ) then
    ElderScrollsOfAlts:GuiCharLineLookupPopulateEquipData(viewKey,eline,playerLine, viewKey )
  --
  --
  --elseif(viewKey=="UnitAvARank" or viewKey=="HomeCampaignId" or viewKey=="AssignedCampaignId" or viewKey == "GuestCampaignId" or viewKey=="AssignedCampaignRewardEarnedTier" or viewKey=="CurrentCampaignRewardEarnedTier" or viewKey=="GuestCampaignRewardEarnedTier" ) then
  --elseif(viewKey=="AssignedCampaignRewardEarnedTier" ) then
  --  eline.value = playerLine[viewKey]
  elseif( viewKey=="AssignedCampaignRewardEarnedTier" or viewKey == "assignedcampaignrewardearnedtier" ) then
    if(playerLine["assignedcampaignrewardprogress"]~=nil) then
      eline.tooltip = zo_strformat("<<1>> has <<2>> of <<3>> (<<4>>/<<5>>)", playerLine.name, viewKey, playerLine[viewKey], playerLine["assignedcampaignrewardprogress"],playerLine["assignedcampaignrewardtotal"])
    else
      eline.tooltip = zo_strformat("<<1>> has <<2>> of <<3>>", playerLine.name, viewKey, playerLine[viewKey], playerLine["assignedcampaignrewardprogress"],playerLine["assignedcampaignrewardtotal"])
    end
    eline:SetText( playerLine[viewKey] )
    eline.value = playerLine[viewKey]
  --
  --
  elseif(viewKey=="BagSpace") then
    local bu = playerLine["backpackused"] 
    local bs = playerLine["backpacksize"]
    local bf = playerLine["backpackfree"]
    if bs == nil then bs = "---" end
    local bagText = string.format("%3d/%3d",bu, bs)
    eline:SetText(bagText)
    if(bf~=nil) then
      eline.tooltip = playerLine.name .. " has a ".. bf .. " free bag slots"
    end
  elseif(viewKey=="BagSpaceFree" or viewKey=="bagspacefree") then
    local bu = playerLine["backpackused"] 
    local bs = playerLine["backpacksize"]
    local bf = playerLine["backpackfree"]
    if bs == nil then bs = "---" end
    if( bf==nil or bf=="" ) then bf = tonumber(bs-bu) end    
    eline.tooltip = playerLine.name .. " has a ".. bf .. " free bag slots"
    --
    local noneColor = nil
    if(bf==nil or bf==0 ) then
      noneColor = ElderScrollsOfAlts.savedVariables.colors.colorTimerDone
    elseif(bf<5) then
      noneColor = ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer
    elseif(bf<10) then
      noneColor = ElderScrollsOfAlts.savedVariables.colors.colorTimerNear
    end    
    --eline:SetText(bf)
    eline:SetText( ElderScrollsOfAlts.ColorText( noneColor, bf ) )
    --
    
  elseif(viewKey=="Skillpoints") then
    eline:SetText(playerLine["skillpoints"])
    eline.tooltip = zo_strformat("<<1>> has <<2>> free skillpoints", playerLine.name,playerLine["skillpoints"])
    --eline.sortKey
  --
  --
  elseif(viewKey=="Riding Speed" or viewKey=="Riding Stamina" or viewKey=="Riding Inventory") then        
    local newKey = string.lower(viewKey)
    newKey = newKey:gsub(" ","_")
    if( playerLine[ newKey ] ~=nil ) then
      eline.value = playerLine[newKey]
      eline.key   = newKey
      eline:SetText( playerLine[newKey] )
      eline.maxvalue = ElderScrollsOfAlts.SkillsLevelMaximum[viewKey]
      --eline.tooltip = zo_strformat("<<1>> has <<2>> in '<<3>>'", playerLine.name,  playerLine[newKey], viewKey, eline.maxvalue )      
    else
      eline:SetText(playerLine[viewKey])
      eline.value = playerLine[viewKey]
      eline.key   = viewKey
      eline.maxvalue = ElderScrollsOfAlts.SkillsLevelMaximum[viewKey]
      --eline.tooltip = zo_strformat("<<1>> has <<2>> in '<<3>>'", playerLine.name,  eline.value, eline.key, eline.maxvalue )
    end
    if(eline.maxvalue~=nil) then
      eline.tooltip = zo_strformat("<<1>> has <<2>>/<<4>> in '<<3>>'", playerLine.name,  eline.value, viewKey, eline.maxvalue )
    else
      eline.tooltip = zo_strformat("<<1>> has <<2>> in '<<3>>'", playerLine.name,  eline.value, viewKey, eline.maxvalue )
    end
  elseif(viewKey=="Riding Timer") then
    local timeMS     = playerLine["riding_timems"]
    local expireTime = playerLine["riding_trainingready"]  
    local nowTime    = GetTimeStamp()
    local timeDiff   = nil
    local rtType = -1
    eline.sort_data    = timeMS
    eline.sort_numeric =  true
    eline.value        = timeMS
    eline.maxvalue = ElderScrollsOfAlts.SkillsLevelMaximum[viewKey]
      
    if(playerLine["riding_maxed"]) then
        eline.tooltip = "Riding Skills Maxed"
        eline:SetText("Max")
        eline.sort_data = -1
        eline.value = -1
        rtType = 2
    else
      if(expireTime~=nil)then
        --timeDiff = expireTime - nowTime
        timeDiff = GetDiffBetweenTimeStamps(expireTime , nowTime)
      end
      eline.timeMS = timeMS
      if( timeDiff ~= nil )then
        if( timeDiff <= 0 ) then
          eline.tooltip = "Now"
          eline:SetText("Now")
          eline.sort_data = 0
          eline.value = 0
          rtType = 1
        else
          local timeD = ElderScrollsOfAlts:timeToDisplay( (timeDiff*1000),false,true)
          eline.tooltip = timeD
          eline:SetText(timeD)      
          rtType = 0
        end      
      else
        eline.tooltip = "--"
        eline:SetText("--")  
      end
    end--max check

    eline.tooltip = zo_strformat("<<1>> has '<<2>>' as <<3>>",
        playerLine.name, viewKey, eline.tooltip )
    
    --Riding Timer
    local noneColor = ElderScrollsOfAlts.savedVariables.colors.colorTimerDone
    if(rtType==2)then
      noneColor = ElderScrollsOfAlts.savedVariables.colors.colorTimerDone
    elseif(rtType==1)then
      noneColor = ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer
    elseif(rtType==0)then
      noneColor = ElderScrollsOfAlts.savedVariables.colors.colorTimerNear
    else
      noneColor = ElderScrollsOfAlts.savedVariables.colors.colorTimerNone
    end
    eline:SetText( ElderScrollsOfAlts.ColorText( noneColor, eline:GetText() ) )
  -- Riding ^^
  --elseif( string.lower(viewKey)==("zonename") )then
  --  eline:SetText( playerLine["zoneName"]  )
  --elseif( string.lower(viewKey)==("subzonename") )then
  --  eline:SetText( playerLine["subzoneName"]  )
  elseif(viewKey=="SecondsPlayed" or viewKey=="TimePlayed")then
    eline:SetText( playerLine[string.lower(viewKey)]  )
    eline.tooltip = zo_strformat("<<1>> has played for <<2>> (account total=<<3>>s)",
        playerLine.name, playerLine[string.lower(viewKey)], 
        ElderScrollsOfAlts:timeToDisplay( (ElderScrollsOfAlts.view.accountData.secondsplayed*1000) ,true,false),
        ElderScrollsOfAlts.view.accountData.secondsplayed
      )
  --
  elseif( ElderScrollsOfAlts.starts_with(viewKey, "currency_") or  ElderScrollsOfAlts.starts_with(viewKey, "Currency_") ) then
    local viewKey2 = viewKey
    local pos = string.find(viewKey, "_")
    viewKey2 = string.sub(viewKey,pos+1)
    eline:SetText( playerLine[string.lower(viewKey)]  )
    eline.tooltip = zo_strformat("<<1>> has <<2>> <<3>>",
        playerLine.name, playerLine[string.lower(viewKey)], viewKey2
      )
  --"tracking_writs_Jewelry Crafting Writ"
  elseif( ElderScrollsOfAlts.ends_with(viewKey, " Writ") or ElderScrollsOfAlts.ends_with(viewKey, " writ")  ) then
    --d("<viewKey: " .. tostring(viewKey) )
    local tempn = string.format("tracking_writs_%s",viewKey)
    tempn = string.lower(tempn)
    --d("<tempn: " .. tostring(tempn) )
    local comp = playerLine[ tempn .. "_done" ]
    if(comp) then
      local time = playerLine[ tempn .. "_time" ]    
      local timestring = GetDateStringFromTimestamp(time)
      local now       = GetTimeStamp()
      local timediff  = GetDiffBetweenTimeStamps(now,time)
      local fieldText = "0"
      local ago = ElderScrollsOfAlts:timeToDisplay( (timediff*1000) ,true,false)
      local extratooltiptext = ""
      
      local resetTime = playerLine[ tempn .. "_reset" ]
      --d(" Now: " ..now.. " resetTime: " .. tostring(resetTime) )
      if(resetTime) then
        local timediffReset = GetDiffBetweenTimeStamps(resetTime,now)
        --d(" timediffReset(): " .. tostring(timediffReset)  )
        if(timediffReset>0) then
          fieldText = ElderScrollsOfAlts:timeToDisplay( (timediffReset*1000) , false,true)
          extratooltiptext = zo_strformat("<<1>> done at <<2>>, was <<3>> ago, will reset in <<4>>.", viewKey, timestring, ago, fieldText )
          fieldText = ElderScrollsOfAlts.ColorText( ElderScrollsOfAlts.savedVariables.colors.colorTimerDone, fieldText )
        else
          fieldText = "Prev"
          extratooltiptext = zo_strformat("<<1>> should be reset and able to be done again.", viewKey, timestring, ago, fieldText )
          fieldText = ElderScrollsOfAlts.ColorText( ElderScrollsOfAlts.savedVariables.colors.colorTimerNone, fieldText )
        end
      else
        local hour, minute = ElderScrollsOfAlts:dailyReset()
        local timeToReset = hour*3600 + minute*60
        --
        fieldText = ago
        extratooltiptext = zo_strformat("<<1>> done at <<2>>, was <<3>> ago.", viewKey, timestring, ago )
      end      
      --local hour, minute = ElderScrollsOfAlts:dailyReset()
      --local timeToWarning = hour*3600 + minute*60 -- - warnTime*60
      --d("<hour: " .. tostring(hour) .. " minute: " ..tostring(minute) )-- .. " timeToWarning: " .. tostring(timeToWarning) )
      --d("<comp: " .. tostring(comp) .. " time: " ..tostring(time) )
      eline:SetText( fieldText )
      eline.tooltip = extratooltiptext
    else
      eline:SetText( "0" )
    end
    
    --playerLines[k][tempn.."_time"] = rtKV2.completedtime
    --playerLines[k][tempn.."_done"] = rtKV2.completed
    --d("timestring: " .. GetDateStringFromTimestamp(rtKV2.completedtime) )
    --d("timediff: " .. GetDiffBetweenTimeStamps(GetTimeStamp(),rtKV2.completedtime) )
    --if diff is negative, it was previous
    -- so what time to compare to to get if it was done today?
    --[15:32] [15:32] >tempn: "tracking_writs_Jewelry Crafting Writ"
  --
  elseif( ElderScrollsOfAlts.starts_with(viewKey, "cp_") ) then
    local newKey = string.lower(viewKey)
    local newVal = playerLine[newKey]    
    ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: entered CP case for viewKey='", newKey, "' ='", tostring(newVal),"'")
    if(newVal==nil) then
      newVal = -1
    end
    eline:SetText( newVal )
    eline.tooltip = zo_strformat("<<1>> has <<2>> of <<3>>",
        playerLine.name, viewKey, newVal )
    eline.value = playerLine[ viewKey ] 
  elseif( ElderScrollsOfAlts.starts_with(viewKey, "Companion_") or  ElderScrollsOfAlts.starts_with(viewKey, "companion_") ) then
    local num = viewKey:sub( #"Companion_"+1, #"Companion_"+1 )
    --d("num: "..tostring(num) )
    local cName   = playerLine["companion_"..num.."_name"]
	local level   = playerLine["companion_"..num.."_level"]
	local rapport = playerLine["companion_"..num.."_rapport"]
    local cExp    = playerLine["companion_"..num.."_currentexperience"]
    local mExp    = playerLine["companion_"..num.."_experienceforlevel"]
    eline.tooltip = zo_strformat("<<1>>'s has no companion in this slot",
				playerLine.name)
    if( ElderScrollsOfAlts.ends_with(viewKey, "level") ) then
      eline:SetText(level)
	  if(level~=nil and level>-1) then
        eline.tooltip = zo_strformat("<<1>>'s companion <<2>> is level <<3>> with <<4>>/<<5>>xp.",
				playerLine.name, cName, level, cExp, mExp )
	  end
    elseif( ElderScrollsOfAlts.ends_with(viewKey, "rapport") ) then
      eline:SetText( rapport )
      if(level~=nil and level>-1) then
        eline.tooltip = zo_strformat("<<1>>'s companion <<2>> has rapport of <<3>>.",
			playerLine.name, cName, rapport  )
	  end
    else
      eline:SetText(  playerLine[string.lower(viewKey)] )
	  if(level~=nil and level>-1) then
        eline.tooltip = zo_strformat("<<1>>'s companion <<2>> is level <<3>> with <<4>>/<<5>>xp and rapport of <<6>>.", 
			playerLine.name, cName, level, cExp, mExp, rapport)
	  end
    end
  elseif( ElderScrollsOfAlts.starts_with(viewKey, "Buff_") or  ElderScrollsOfAlts.starts_with(viewKey, "buff_") ) then
    local viewKey2 = viewKey
    local pos = string.find(viewKey, "_")
    viewKey2 = string.sub(viewKey,pos+1)
    eline:SetText( playerLine[string.lower(viewKey)]  )
    eline.tooltip = zo_strformat("<<1>> has <<2>> <<3>>",
        playerLine.name, playerLine[string.lower(viewKey)], viewKey2
      )    
  --
  --
  else
    ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: entered else case for viewKey='", viewKey, "'")
    if( playerLine[viewKey.."_Rank"] ~= nil ) then
      ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: entered rank case check for viewKey='", viewKey, "'")
      eline.value = playerLine[viewKey.."_Rank"]
      --if( (eline.value == nil or eline.value == 0) and ElderScrollsOfAlts.savedVariables.colors.colorTimerNone~=nil ) then      
      --  eline:SetText( ElderScrollsOfAlts.ColorText( ElderScrollsOfAlts.savedVariables.colors.colorTimerNone, eline.value  ) )
      --else
      eline:SetText( eline.value  )
      --end
      --return
    elseif( playerLine[ viewKey ] ~= nil ) then
      ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: entered normal case check for viewKey='", viewKey, "'")
      eline:SetText( playerLine[viewKey]  )
      eline.tooltip = zo_strformat("<<1>> has <<2>> of <<3>>",
        playerLine.name, viewKey, playerLine[(viewKey)] )
      --eline.tooltip = viewKey .. " is " .. playerLine[string.lower(viewKey) ]
      eline.value = playerLine[ viewKey ] 
      --return
    else
        
      local newKey = string.lower(viewKey)
      newKey = newKey:gsub(" ","_")
      --debugMsg("Newkey='"..newKey.."'")
      if( playerLine[ newKey ] ~=nil ) then
        ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: entered lower case check for newKey='", newKey, "'")
        eline:SetText( playerLine[newKey]  )
        eline.tooltip = zo_strformat("<<1>> has <<2>> of <<3>>",
          playerLine.name, viewKey, playerLine[string.lower(viewKey)] )
        --eline.tooltip = viewKey .. " is " .. playerLine[string.lower(viewKey) ]
        eline.value = playerLine[ newKey ] 
        --return
      end
        
      if( playerLine[string.lower(viewKey)] ~= nil) then
        ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: entered last check1 for viewKey='", viewKey, "'")
        eline:SetText( playerLine[string.lower(viewKey)]  )
        eline.tooltip = zo_strformat("<<1>> has <<2>> of <<3>>",
          playerLine.name, viewKey, playerLine[string.lower(viewKey)] )
        --eline.tooltip = viewKey .. " is " .. playerLine[string.lower(viewKey)]
        eline.value = playerLine[string.lower(viewKey)]
      elseif( playerLine[(viewKey)] ~=nil ) then
        ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: entered last check2 for viewKey='", viewKey, "'")
        eline:SetText( tostring(playerLine[(viewKey)])  )
        eline.tooltip = zo_strformat("<<1>> has <<2>> of <<3>>",
          playerLine.name, viewKey, playerLine[viewKey] )
        --eline.tooltip = viewKey .. " is " .. tostring(playerLine[(viewKey)])
        eline.value = playerLine[(viewKey)]
      end
      
    end
    --
  end
  -- FOR ALL
  --
  if( eline.value == nil ) then
    eline.value = tonumber(playerLine[viewKey])
    ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: setval:   viewKey: '" , tostring(viewKey), "' to value: '", eline.value, "'" )
  else
    ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: nosetval: viewKey: '" , tostring(viewKey), "' is value: '", eline.value, "'" )
  end
 
  local vcP = ElderScrollsOfAlts.GuiCharLineLookupPercentCheck(eline)
  local vc = ElderScrollsOfAlts.GuiCharLineLookupMaxValueCheck(eline,viewKey,playerLine)
  if( vc==1 ) then
    ElderScrollsOfAlts.GuiCharLineLookupMaxValueSetup(eline)
  elseif( vc==2 ) then
    ElderScrollsOfAlts.GuiCharLineLookupNearMaxValueSetup(eline)
  end
  
  --
  local sstext  = playerLine[viewKey.."_subskills"]
  local sstext1 = playerLine[string.lower(viewKey).."_subskills"]
  local tttext  = playerLine[viewKey.."_tooltip"] 
  local tttext1 = playerLine[string.lower(viewKey).."_tooltip"]
  if( tttext1 ~= nil ) then
    ElderScrollsOfAlts.debugMsg("GuiCharLineLookupPopulateData: tttext1: '" , tostring(tttext1), "' key: '", (viewKey), "'" )     
  end
  --
  local newTTtext = nil  
  if(sstext~=nil ) then
    newTTtext = sstext
  elseif(sstext1~=nil ) then    
    newTTtext = sstext1    
  elseif(tttext~=nil ) then
    newTTtext = tttext     
  elseif(tttext1~=nil ) then
    newTTtext = tttext1     
  end
  --d("newTTtext:"..tostring(newTTtext) )
  if(newTTtext~=nil) then  
    if(eline.tooltip~=nil)then
      eline.tooltip = eline.tooltip .. " " .. newTTtext
    else
      eline.tooltip = newTTtext
    end
  end
  --TODO colors? _subskillsA _subskillsP
  --data_subskills
end

------------------------------
-- View Lookup, Percents, ??
function ElderScrollsOfAlts.GuiCharLineLookupPercentCheck(eline)
  if( eline.value==nil) then
    return 0
  end
  local viewKey = eline.viewKey
  if(viewKey=="Level" or viewKey=="level") then
    local vcP = ElderScrollsOfAlts.LookupPercentCheck(eline.value,50,80) 
    ElderScrollsOfAlts.debugMsg("MaxValueCheck:" .. tostring(vcP) )
  end
end

------------------------------
-- View Lookup, Percents, ??
function ElderScrollsOfAlts.LookupPercentCheck(valIn,maxVal,perc)
  if( valIn==nil) then
    return 0
  end
  --local viewKey = eline.viewKey
  if(valIn == maxVal ) then
    return 1
  end
  local pVal = ( (valIn/maxVal) *100)
  if(pVal>100) then
    return 1
  elseif(pVal>perc) then
    return 2
  end
  return 0
end

------------------------------
-- View Lookup, CHECK if value is max of field
-- Returns true if this value is MAX
-- Returns 0 if not at max, 1 if at MAX, and 2 if near max
function ElderScrollsOfAlts.GuiCharLineLookupMaxValueCheck(eline, viewKey2, playerLine2)
  ElderScrollsOfAlts.debugMsg("maxcheck: viewKey='",eline.viewKey,"' viewKey2='",viewKey2,"'")
  if( eline.value==nil) then
    return 0
  end
  local viewKey  = eline.viewKey
  local lviewKey = viewKey:lower()
  --Use chart values to determine if max or near max
  local amaxSL = ElderScrollsOfAlts.SkillsLevelMaximum[viewKey]
  local nmaxSL = ElderScrollsOfAlts.SkillsLevelNearMaximum[viewKey]
  local retv = nil  
  local type1 = type(eline.value)
  local type2 = type(nmaxSL)
  ElderScrollsOfAlts.debugMsg("maxcheck: type: type1='",type1,"' type2='",type2,"'")  
  if(type1 == 'string') then
    return 0
  end
  --eline.value = tonumber(eline.value)
  --
  if(nmaxSL~=nil and eline.value~=nil) then
    --ElderScrollsOfAlts.debugMsg("maxcheck: value='",eline.value,"' nmaxSL='",nmaxSL,"'")  
    if( eline.value >= nmaxSL) then
      retv = 2
    end
  end
  if(amaxSL~=nil) then
    if( eline.value >= amaxSL) then
      retv = 1
    end
  end
  if(retv~=nil) then
    return retv
  end
  --Use specific logic to determine if max or near max
  if( viewKey=="Alchemy" ) then
    if( eline.value == 50  and eline.data_sunk == 7 ) then
      return 1
    elseif( eline.value == 50  ) then
      return 2
    end
  elseif( viewKey=="Jewelry" ) then
    if( eline.value == 50  and eline.data_sunk == 4 ) then
      return 1
    elseif( eline.value == 50  ) then
      return 2
    end
  elseif( lviewKey=="blacksmithing" or lviewKey == "smithing" or viewKey=="Clothing" or viewKey=="Woodworking") then
    if( eline.value == 50  and eline.data_sunk == 9 ) then
      return 1
    elseif( eline.value == 50  ) then
      return 2
    end
  elseif( viewKey=="Enchanting") then
    if( eline.value == 50  and eline.data_sunk == 3 and eline.data_sunk2 == 9 ) then
      return 1
    elseif( eline.value == 50  ) then
      return 2
    end
  elseif( viewKey=="Provisioning") then
    if( eline.value == 50  and eline.data_sunk == 3 and eline.data_sunk2 == 5 ) then
      return 1
    elseif( eline.value == 50  ) then
      return 2
    end
  end
  return 0
end

------------------------------
-- View Lookup, CHECK if data value is Max Value
function ElderScrollsOfAlts.GuiCharLineLookupMaxValueSetup(eline)
  if(ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax~=nil)then
    local cText = ElderScrollsOfAlts.ColorText(ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax, eline:GetText() )
    eline:SetText( cText )  
  end
end

------------------------------
-- View Lookup, CHECK if data value is NEAR Max Value
function ElderScrollsOfAlts.GuiCharLineLookupNearMaxValueSetup(eline)
  if(ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax~=nil)then
    local cText = ElderScrollsOfAlts.ColorText(ElderScrollsOfAlts.savedVariables.colors.colorSkillsNearMax, eline:GetText() )
    eline:SetText( cText )  
  end
end

------------------------------
-- View Lookup, Show Data 
function ElderScrollsOfAlts:GuiCharLineLookupPopulateEquipData(viewKey,eline,playerLine,equipName)
  local mKye1 = string.format("%s%s", equipName,"_Link")
  eline:SetText( playerLine[equipName] )
  eline.itemlink = playerLine[mKye1]
  eline.datatype = "Equip"
  --[[
  --eline:SetMouseEnabled(true) --TODO check that works in default tooltip, then remove these 2
  eline:SetHandler('OnMouseEnter',function(self)
    ElderScrollsOfAlts:EquipTipEnter(self, viewKey )
  end)
  eline:SetHandler('OnMouseExit',function(self)
    ElderScrollsOfAlts:EquipTipExit(self)
  end)   
  --]]
  eline:SetHandler('OnMouseUp',function(self)
    ElderScrollsOfAlts:EquipShowTip(self)
  end)  
end

------------------------------
-- View Lookup, Show Data 
-- rclothier2time
function ElderScrollsOfAlts:GuiCharLineLookupPopulateResearchData(viewKey,eline,playerLine,tradeName,numkey)
  --local vkey = "r"..tradeName.."time"
  local mKyeS  = string.format("%s%s%s%s","r",tradeName,numkey,"S")
  local mKyeC  = string.format("%s%s%s%s","r",tradeName,numkey,"code")
  local mKye1  = string.format("%s%s%s%s","r",tradeName,numkey,"time") --display time
  local mKyeN  = string.format("%s%s%s%s","r",tradeName,numkey,"name")
  local mKyeMS = string.format("%s%s%s%s","r",tradeName,numkey,"researchMS")
  local mKyeTT = string.format("%s%s%s%s","r",tradeName,numkey,"TraitType")
  local mKyeTD = string.format("%s%s%s%s","r",tradeName,numkey,"TraitDesc")  
  local mKyeTK = string.format("%s%s%s%s","r",tradeName,numkey,"Traitknown")           
  --local mKye1 = zo_strformat("<<1>><<2>><<3>><<4>>", "r",tradeName,numkey,"time")
  local mTooltip = string.format("%s%s%s%s","r",tradeName,numkey,"tooltip")           
  
  eline.data_val = playerLine[mKye1]
  eline.sort_data = playerLine[mKyeMS]
  eline:SetText( playerLine[mKye1] )
  eline:SetMaxLineCount( eline:GetWidth() )
  eline.name       = playerLine[mKyeN] 
  eline.traitType  = playerLine[mKyeTT]
  eline.traitDesc  = playerLine[mKyeTD]
  eline.traitKnown = playerLine[mKyeTK]
  eline.tooltip    = playerLine[mTooltip]
  
  --https://en.wikipedia.org/wiki/Web_colors
  --red  |cFF0000 |r
  --blue |c0000FF |r?
  -- 	FF4500 40E0D0
  local tradeTimeS = playerLine[mKyeS]  
  local codeS = playerLine[mKyeC]   --  > 0 ok
  if(codeS==3) then
    --eline:SetText( "[Refresh]" )   
    eline.traitDesc = "Old data! Refresh asap!!"
  elseif( (codeS <= -2) and ElderScrollsOfAlts.savedVariables.colors.colorTimerNone~=nil) then  
    eline:SetText( ElderScrollsOfAlts.ColorText( ElderScrollsOfAlts.savedVariables.colors.colorTimerNone, playerLine[mKye1]) )
  elseif( (tradeTimeS==nil or codeS < 1) and ElderScrollsOfAlts.savedVariables.colors.colorTimerDone~=nil) then
    eline:SetText( ElderScrollsOfAlts.ColorText( ElderScrollsOfAlts.savedVariables.colors.colorTimerDone, playerLine[mKye1]) )
  elseif( codeS == 1 and ElderScrollsOfAlts.savedVariables.colors.colorTimerDone~=nil ) then
    eline:SetText( ElderScrollsOfAlts.ColorText(ElderScrollsOfAlts.savedVariables.colors.colorTimerDone,playerLine[mKye1]) )
  elseif( tradeTimeS < 43200 and ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer~=nil ) then
    eline:SetText( ElderScrollsOfAlts.ColorText(ElderScrollsOfAlts.savedVariables.colors.colorTimerNearer,playerLine[mKye1]) )
  elseif( tradeTimeS < 86400 or codeS == 1 and ElderScrollsOfAlts.savedVariables.colors.colorTimerNear~=nil) then
    eline:SetText( ElderScrollsOfAlts.ColorText(ElderScrollsOfAlts.savedVariables.colors.colorTimerNear, playerLine[mKye1]) )
  end
  
  --if(eline.data_val == GetString(ESOA_RESEARCH_AVAIL) ) then
    --local cText = ElderScrollsOfAlts.ColorText( ElderScrollsOfAlts.savedVariables.colors.colorSkillsMax, eline.data_val )
    --eline:SetText( cText )    
  --end
  
  eline.datatype = "Research"
  --eline:SetMouseEnabled(true)
  eline:SetHandler('OnMouseEnter',function(self)
    ElderScrollsOfAlts:ResearchTipEnter(self, viewKey )
  end)
  eline:SetHandler('OnMouseExit',function(self)
    ElderScrollsOfAlts:ResearchTipExit(self)
  end)  
  --eline:SetFont(ZoFontGame)
end

------------------------------
-- View Lookup, Show Data 
function ElderScrollsOfAlts:GuiCharLineLookupPopulateTradeData(viewKey,eline,playerLine,tradeName)  
  eline.data_val    = playerLine[tradeName]
  eline.data_sunk   = playerLine[tradeName.."_sunk"] 
  eline.data_sunk2  = playerLine[tradeName.."_sunk2"]
  ElderScrollsOfAlts.debugMsg("POP Trade Data: tradeName='", tradeName, "' viewKey='", viewKey, "' data_val='", eline.data_val, "' data_sunk='", eline.data_sunk, "'")
  if( eline.data_sunk == nil ) then
    eline.data_sunk   = playerLine[viewKey.."_sunk"] 
    eline.data_sunk2  = playerLine[viewKey.."_sunk2"]
  end
  
  if eline.data_sunk ~=nil and eline.data_sunk > 0 and eline.data_val~=nil then
    eline:SetText(eline.data_val.."("..eline.data_sunk..")" )      
  elseif( eline.data_val==nil) then
    ElderScrollsOfAlts.debugMsg("POP error Key='"..tostring(viewKey), "' tradeName='", tradeName, "' playerLine=" , playerLine  )
    eline:SetText(" ")
  else
    eline:SetText(eline.data_val .. "  ")
  end
  eline.data_subskills= playerLine[tradeName.."_subskills"]
  --eline:SetMouseEnabled(true)
  --local craftName = ElderScrollsOfAlts.view.viewkeyXlate[viewKey]
  ElderScrollsOfAlts.debugMsg("POP Trade Data: tradeName='", tradeName, "' viewKey='", viewKey, "'")  

  eline:SetHandler('OnMouseEnter',function(self)
    ElderScrollsOfAlts:CraftTipEnter(self, tradeName, playerLine )
  end)
  eline:SetHandler('OnMouseExit',function(self)
    ElderScrollsOfAlts:CraftTipExit(self)
  end)
  eline.datatype = "Trade"
  eline.value    = playerLine[tradeName]
end

------------------------------
-- View Lookup, Show Data  ??
function ElderScrollsOfAlts.GuiCharLineLookupDisplayType(view,viewKey,lineName,parent)
  local line = nil
  if(viewKey=="Special" or viewKey=="Alliance" or viewKey=="Note") then
    line = parent:GetNamedChild('_'..viewKey)
    if(line==nil)then
      line = WINDOW_MANAGER:CreateControlFromVirtual(lineName.."_"..viewKey, parent, "ESOA_RowTemplate_Texture")
    end
  else
    line = parent:GetNamedChild('_'..viewKey )
    if(line==nil)then
      line = WINDOW_MANAGER:CreateControlFromVirtual(lineName.."_"..viewKey, parent, "ESOA_RowTemplate_Label")      
    end
    line:SetText( ElderScrollsOfAlts.GuiSortBarLookupDisplayText(viewKey) )
  end
  return line
end

------------------------------
-- View Lookup, return sort lookup values
function ElderScrollsOfAlts.GuiSortBarLookupSortText(viewKey)
  if(viewKey==nil) then return nil end
  --viewKey = viewKey:lower()
  
  if(viewKey:lower()=="smithing" or viewKey:lower()=="blacksmithing") then
    return "blacksmithing"
  elseif(viewKey=="Clothier Research 1") then
    return "rclothier1S"
  elseif(viewKey=="Clothier Research 2") then
    return "rclothier2S"
  elseif(viewKey=="Clothier Research 3") then
    return "rclothier3S"
  elseif(viewKey=="Blacksmithing Research 1") then
    return "rblacksmithing1S"
  elseif(viewKey=="Blacksmithing Research 2") then
    return "rblacksmithing2S"
  elseif(viewKey=="Blacksmithing Research 3") then
    return "rblacksmithing3S"
  elseif(viewKey=="Woodworking Research 1") then
    return "rwoodworking1S"
  elseif(viewKey=="Woodworking Research 2") then
    return "rwoodworking2S"
  elseif(viewKey=="Woodworking Research 3") then
    return "rwoodworking3S"
  elseif(viewKey=="Jewelcrafting Research 1") then
    return "rjewelcrafting1S"
  elseif(viewKey=="Jewelcrafting Research 2") then
    return "rjewelcrafting2S"
  elseif(viewKey=="Jewelcrafting Research 3") then
    return "rjewelcrafting3S"
  elseif(viewKey=="bagspaceFree" or viewKey=="bagspacefree" or viewKey=="BagSpaceFree" or viewKey=="backpackfree") then
    return "backpackfree"
  elseif(viewKey=="bagspace" or viewKey=="BagSpace") then
    return "backpacksize"
  elseif(viewKey=="Head" or viewKey=="Shoulders" or viewKey=="Chest" or viewKey=="Waist" or viewKey=="Legs" or viewKey=="Hands" or viewKey=="Feet" ) then
    return viewKey
  elseif(viewKey=="Neck" or viewKey=="Ring1" or viewKey=="Ring2" ) then
    return viewKey
  elseif(viewKey=="M1" or viewKey=="M2" or viewKey=="Mp" or viewKey=="O1" or viewKey=="O2" or viewKey=="Op" ) then
    return viewKey
  elseif(viewKey=="Riding Speed" or viewKey=="Riding Stamina" or viewKey=="Riding Inventory") then
    return viewKey:gsub(" ","_"):lower()
  elseif( viewKey=="Riding Timer" or viewKey=="riding_timems") then  
    return "riding_timems"
  elseif( viewKey=="Vampire" or viewKey=="Werewolf") then  
    return viewKey
  elseif( viewKey=="specialbitetimer" or viewKey=="SpecialBiteTimer" ) then
    return "special_bitetimer"
  elseif(viewKey=="Assault" or viewKey=="Support" or viewKey=="Legerdemain" or viewKey=="Soul Magic" or viewKey=="Werewolf" or viewKey=="Vampire" or viewKey=="Fighters Guild" or viewKey=="Mages Guild" or viewKey=="Undaunted" or viewKey=="Thieves Guild" or viewKey=="Dark Brotherhood" or viewKey=="Psijic Order" or viewKey=="Scrying" or viewKey=="Excavation") then
    return viewKey.."_Rank"
  elseif( viewKey=="achieveearned") then  
    return "achieveearnedraw"
  elseif( viewKey=="lastlogin") then  
    return "lastloginraw"
  elseif( viewKey=="lastlogindiff") then  
    return "lastloginraw"
  elseif( viewKey=="AssignedCampaignEndsAt") then  
    return "AssignedCampaignEndsSeconds"
  elseif(viewKey=="Jewelry") then
    return "jewelry crafting"
  elseif(viewKey=="Jewelry Crafting") then
    return "jewelry crafting"
    
  --elseif( viewKey=="assignedcampaignrewardearnedtier") then  
  --return "assignedcampaignrewardearnedtier " 
  end
  return viewKey:lower()
end

------------------------------
-- View Lookup, Return WIDTH
function ElderScrollsOfAlts.GuiSortBarLookupDisplayWidth(viewKey)
  local lviewKey = viewKey:lower()
  if(viewKey=="Name") then
    return ElderScrollsOfAlts.altData.fieldWidthForName
  elseif(viewKey=="Special") then
    return 24
  elseif(viewKey=="SpecialBiteTimer") then
    return 70
  elseif(viewKey=="SecondsPlayed" or viewKey=="TimePlayed" or viewKey=="achieveearned" ) then  
    return 60
  elseif(viewKey=="Alliance") then
    return 28
  elseif(viewKey=="Alliance Name") then
    return 50
  elseif(viewKey=="Note") then
    return 35
  elseif(viewKey=="Class") then
    return 52
  elseif(viewKey=="Level") then
    return 40
  elseif(viewKey=="Race") then
    return 75
  elseif(viewKey=="Gender") then
    return 25
  elseif(viewKey=="ReducedBounty") then
    return 50    
  elseif(viewKey=="Alchemy" or lviewKey=="blacksmithing" or lviewKey == "smithing" or viewKey=="Clothing" or viewKey=="Enchanting" or viewKey=="JC" or viewKey=="Jewelry" or viewKey=="Woodworking" or viewKey=="Provisioning") then
    return 45
  --
  elseif(viewKey=="BagSpace") then
    return 60
  elseif(viewKey=="BagSpaceFree" or viewKey=="BackpackUsed" or viewKey=="BackpackSize" or viewKey=="BackpackFree") then
    return 45
  --
  elseif( viewKey=="lastlogin" ) then
    return 75
  elseif(viewKey=="lastlogindiff") then
    return 75
  elseif(viewKey=="Skillpoints") then
    return 45
  elseif(viewKey=="Assault" or viewKey=="Support" or viewKey=="Legerdemain" or viewKey=="Soul Magic" or viewKey=="Werewolf" or viewKey=="Vampire" or viewKey=="Fighters Guild" or viewKey=="Mages Guild" or viewKey=="Undaunted" or viewKey=="Thieves Guild" or viewKey=="Dark Brotherhood" or viewKey=="Psijic Order" or viewKey=="Scrying" or viewKey=="Excavation") then
    return 45
  elseif(viewKey=="Riding Speed" or viewKey=="Riding Stamina" or viewKey=="Riding Inventory") then
    return 35
  elseif(viewKey=="Riding Timer") then
    return 60
  elseif(viewKey=="Clothier Research 1" or viewKey=="Clothier Research 2" or viewKey=="Clothier Research 3") then
    return 65
  elseif(viewKey=="Blacksmithing Research 1" or viewKey=="Blacksmithing Research 2" or viewKey=="Blacksmithing Research 3") then
    return 65
  elseif(viewKey=="Alliance Name" or viewKey=="AllianceName" or viewKey == "HomeCampaignName" or viewKey=="AssignedCampaignName" ) then
    return 120
  elseif(viewKey=="UnitAvARankName" or viewKey=="AvARankName" or viewKey=="AvaRankName" ) then
    return 165
  elseif(viewKey=="UnitAvARank" or viewKey=="HomeCampaignId" or viewKey=="AssignedCampaignId" or viewKey == "GuestCampaignId" or viewKey=="AssignedCampaignRewardEarnedTier" or viewKey=="CurrentCampaignRewardEarnedTier" or viewKey=="GuestCampaignRewardEarnedTier" ) then
    return 45
  elseif( viewKey=="AssignedCampaignEndsAt") then  
    return 60
  elseif(viewKey=="Woodworking Research 1" or viewKey=="Woodworking Research 2" or viewKey=="Woodworking Research 3") then
    return 65
  elseif(viewKey=="Jewelcrafting Research 1" or viewKey=="Jewelcrafting Research 2" or viewKey=="Jewelcrafting Research 3") then
    return 65
  elseif(viewKey=="Heavy" or viewKey=="Medium" or viewKey=="Light") then        
    return 30
  elseif(viewKey=="Head" or viewKey=="Shoulders" or viewKey=="Chest" or viewKey=="Waist" or viewKey=="Legs" or viewKey=="Hands" or viewKey=="Feet" ) then
    return 35
  elseif(viewKey=="Neck" or viewKey=="Ring1" or viewKey=="Ring2" ) then
    return 30
  elseif(viewKey=="M1" or viewKey=="M2" or viewKey=="Mp" or viewKey=="O1" or viewKey=="O2" or viewKey=="Op" ) then
    return 35
  --
  elseif( ElderScrollsOfAlts.starts_with(viewKey, "currency_") or  ElderScrollsOfAlts.starts_with(viewKey, "Currency_") ) then    
    return 65        
  elseif( ElderScrollsOfAlts.starts_with(viewKey, "Buff_") or  ElderScrollsOfAlts.starts_with(viewKey, "buff_") ) then
    return 45
  --
  elseif( ElderScrollsOfAlts.starts_with(viewKey, "Companion_") or  ElderScrollsOfAlts.starts_with(viewKey, "companion_") ) then
    if( ElderScrollsOfAlts.ends_with(viewKey, "level") ) then
      return 35
    elseif( ElderScrollsOfAlts.ends_with(viewKey, "level") ) then
      return 35
    elseif( ElderScrollsOfAlts.ends_with(viewKey, "rapport") ) then
      return 35
    else
      return 110
    end
	--	
  --
  else
    return 45
  end
end

------------------------------
-- View Lookup, Return Column Header TEXT
function ElderScrollsOfAlts.GuiSortBarLookupDisplayText(viewKey)
  --ElderScrollsOfAlts.debugMsg("LookupDisplay Key="..tostring(viewKey) )
  if(viewKey=="Special") then
    return "Spc"    
  elseif(viewKey=="SpecialBiteTimer") then
    return "Bite"
  elseif(viewKey=="SecondsPlayed" ) then
    return "STime"    
  elseif(viewKey=="TimePlayed" ) then
    return "PTime"    
  elseif(viewKey=="Alliance") then
    return "Aly"
  elseif(viewKey=="Alliance Name") then
    return "Alliance"
  elseif(viewKey=="Note") then
    return "Note"
  elseif(viewKey=="Class") then
    return "Class"
  elseif(viewKey=="Level") then
    return "Lvl"
  elseif(viewKey=="Gender") then
    return "G"
  elseif(viewKey=="Alchemy") then
    return "Alc"
  elseif(viewKey:lower()=="smithing" or viewKey:lower()=="blacksmithing") then
    return "Smth"
  elseif(viewKey=="Clothing") then
    return "Clth"
  elseif(viewKey=="JC" or viewKey=="Jewelry") then
    return "JC"
  elseif(viewKey=="Provisioning") then
    return "Prov"
  elseif(viewKey=="Woodworking") then
    return "Wood"
  elseif(viewKey=="Enchanting") then
    return "Ench"    
  elseif(viewKey=="BagSpace" or viewKey=="BackpackSize") then
    return "Bags"
  elseif(viewKey=="BagSpaceFree" or viewKey=="BackpackFree") then
    return "B.Free"
  elseif(viewKey=="BackpackUsed" or viewKey=="BackpackUsed") then
      return "B.Used"
  elseif(viewKey=="Skillpoints") then
    return "SkPt"
  --
  elseif(viewKey=="Assault") then
    return "Asslt"
  elseif(viewKey=="Support") then
    return "Spprt"
  elseif(viewKey=="Legerdemain") then
    return "Lege"
  elseif(viewKey=="Soul Magic") then
    return "Soul"
  elseif(viewKey=="Werewolf") then
    return "Were"
  elseif(viewKey=="Vampire") then
    return "Vamp"
  elseif(viewKey=="Fighters Guild") then
    return "Fight"
  elseif(viewKey=="Mages Guild") then
    return "Mage"
  elseif(viewKey=="Undaunted") then
    return "Unda"
  elseif(viewKey=="Scrying") then
    return "Scry"
  elseif(viewKey=="Excavation") then
    return "Exca"
  elseif(viewKey=="Thieves Guild") then
    return "Thief"
  elseif(viewKey=="Dark Brotherhood") then
    return "Dark"
  elseif(viewKey=="Psijic Order") then
    return "Psij"
  elseif(viewKey=="Riding Speed") then
    return "Spee"
  elseif(viewKey=="Riding Stamina") then
    return "RStam"
  elseif(viewKey=="Riding Inventory") then
    return "RInve"
  elseif(viewKey=="Riding Timer") then
    return "RTime"
  elseif(viewKey=="Clothier Research 1") then
    return "Cloth1"
  elseif(viewKey=="Clothier Research 2") then
    return "Cloth2"
  elseif(viewKey=="Clothier Research 3") then
    return "Cloth3"
  elseif(viewKey=="Blacksmithing Research 1") then
    return "Smith1"
  elseif(viewKey=="Blacksmithing Research 2") then
    return "Smith2"
  elseif(viewKey=="Blacksmithing Research 3") then
    return "Smith3"
  elseif(viewKey=="Woodworking Research 1") then
    return "Wood1"
  elseif(viewKey=="Woodworking Research 2") then
    return "Wood2"
  elseif(viewKey=="Woodworking Research 3") then
    return "Wood3"
  elseif(viewKey=="Jewelcrafting Research 1") then
    return "JC1"
  elseif(viewKey=="Jewelcrafting Research 2") then
    return "JC2"
  elseif(viewKey=="Jewelcrafting Research 3") then
    return "JC3"
    
  elseif(viewKey=="AssignedCampaignId") then
    return "AvA(A)ID"
  elseif(viewKey=="GuestCampaignId") then
    return "GuestId"
  elseif(viewKey=="HomeCampaignId") then
    return "HomeId"
  elseif(viewKey=="GuestCampaignName") then
    return "Guest Campaign"
  elseif(viewKey=="HomeCampaignName") then
    return "Home Campaign"
  elseif(viewKey=="AssignedCampaignName") then
    return "AvA(A)Name"
  elseif(viewKey=="UnitAvARank") then
    return "AvARank"
  elseif(viewKey=="UnitAvARankPoints") then
    return "AvARankPts"
  elseif(viewKey=="HomeCampaignRewardEarnedTier") then
    return "HomeRewardTier"
  elseif(viewKey=="GuestCampaignRewardEarnedTier") then
    return "GuestRewardTier"
  elseif(viewKey=="AssignedCampaignRewardEarnedTier" or viewKey=="assignedcampaignrewardearnedtier") then
    return "AvA(A)IDRewardTier"
  elseif(viewKey=="currency_alliance point" or viewKey=="Currency_Alliance Point") then
    return "AP"
  elseif(viewKey=="currency_tel var stone" or viewKey=="Currency_Tel Var Stone") then
    return "TelVar"
    elseif(viewKey=="achieveearned") then
    return "AchievePts"
  elseif( ElderScrollsOfAlts.starts_with(viewKey, "currency_") or  ElderScrollsOfAlts.starts_with(viewKey, "Currency_") ) then
    local viewKey2 = viewKey
    local pos = string.find(viewKey, "_")
    viewKey2 = string.sub(viewKey,pos+1)
    return viewKey2
  elseif( ElderScrollsOfAlts.starts_with(viewKey, "Buff_") or  ElderScrollsOfAlts.starts_with(viewKey, "buff_") ) then
    local viewKey2 = viewKey
    local pos = string.find(viewKey, "_")
    viewKey2 = string.sub(viewKey,pos+1)
    return viewKey2
  elseif(viewKey=="ReducedBounty") then
    return "Bounty"
 elseif(viewKey=="zoneName") then
    return "Zone"
  elseif(viewKey=="subzoneName") then
    return "SubZone"
  elseif(string.lower(viewKey)=="lastlogin") then
    return "Login"
  elseif(viewKey=="lastlogindiff" or viewKey=="Lastlogindiff") then
    return "LastLogin"
  elseif(viewKey=="playersorder") then
    return "CustomOrder"
  elseif(viewKey=="playerscreenorder") then
    return "Order"

  elseif(viewKey=="Companion_1_name") then
    return "C1Name"
  elseif(viewKey=="Companion_1_level") then
    return "C1Lvl"
  elseif(viewKey=="Companion_1_rapport") then
    return "C1Rap"
  elseif(viewKey=="Companion_2_name") then
    return "C2Name"
  elseif(viewKey=="Companion_2_level") then
    return "C2Lvl"
  elseif(viewKey=="Companion_2_rapport") then
    return "C2Rap"
  elseif(viewKey=="Companion_3_name") then
    return "C3Name"
  elseif(viewKey=="Companion_3_level") then
    return "C3Lvl"
  elseif(viewKey=="Companion_3_rapport") then
    return "C3Rap"
  elseif(viewKey=="Companion_4_name") then
    return "C4Name"
  elseif(viewKey=="Companion_4_level") then
    return "C4Lvl"
  elseif(viewKey=="Companion_4_rapport") then
    return "C4Rap"
  elseif(viewKey=="Companion_5_name") then
    return "C5Name"
  elseif(viewKey=="Companion_5_level") then
    return "C5Lvl"
  elseif(viewKey=="Companion_5_rapport") then
    return "C5Rap"
  --
  --
  else
    if(string.len(viewKey) > 10) then
      return string.sub(viewKey,1,10)
    else
      return viewKey
    end
  end
end


function ElderScrollsOfAlts:TooltipEnterStub(mySelf,tooltipName,revdir)  
	ElderScrollsOfAlts:TooltipEnter(mySelf,tooltipName,revdir) 
end
function ElderScrollsOfAlts:TooltipExitStub(myLabel,craftName)  
	ElderScrollsOfAlts:TooltipExit(myLabel,craftName)  
end

------------------------------
-- EOF