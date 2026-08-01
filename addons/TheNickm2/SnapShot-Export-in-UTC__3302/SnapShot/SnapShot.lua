-- =========================================================================================================
-- SnapShot Working Code. See SnapShotInit.lua for field initialization
-- =========================================================================================================

local Check = OT_IsButtonPressed  

function OT_IsLabelChecked(label) return string.match(label:GetText(),"√") ~= nil end

-- =========================================================================================================

function SnapShot:AchievementsGetList()                                                        -- 2021/10/12
	self.Lines = {}
	self.Header = {"ID","Achievement","Points","Comp","Parts"}
	for ix=1,MAX_ACHIEVEMENTS do
		local t = GetAchievementName(ix)
		local tname,_,tpts,_,tcomp,tdate,ttime = GetAchievementInfo(ix)
		local tcrit = GetAchievementNumCriteria(ix)
		if #tname>0 then
			local iLine = {
				ix,
				tname,
				tpts,
				tcomp and "Y" or "N",
--				tdate,
--				ttime,
				tcrit
			}
			table.insert(self.Lines,table.concat(iLine,OTSnap:GetDelimiter()))
		end
--		if #t > 0 then table.insert(self.Lines,string.format("%s: %s [%s]",ix,t,tc)) end
	end
	d(string.format("Achievements: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

function SnapShot:AntiquitiesGetList()                                                         -- 2021/10/11
	self.Lines = {}
	self.ReportName="Antiquities"
	self.Header = {"Antiquity","Id","Zone","Diff","Reward","Status"}
	local antId = GetNextAntiquityId()
	while antId do
		local rewardId = GetAntiquityRewardId(antId)
		local rewardLink = GetItemRewardItemLink(rewardId,1)
		local iLine = {GetAntiquityName(antId),antId,
			GetZoneNameById(GetAntiquityZoneId(antId)),
			GetAntiquityDifficulty(antId),
			OT_GetItemTypeName(GetItemLinkItemType(rewardLink)),
			CanScryForAntiquity(antId)
		}
		table.insert(self.Lines,table.concat(iLine,OTSnap:GetDelimiter()))
		antId = GetNextAntiquityId(antId)
	end
	if #self.Lines > 1 then table.sort(self.Lines) end
	d(string.format("Antiquities: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

function SnapShot:EsoStringsGetList()                                                          -- 2021/10/12
	self.Lines = {}
	self.Header = {"Number","String"}
	for k,v in pairs(EsoStrings) do
		if v ~= "" then table.insert(self.Lines,string.format("%s: %s",k,v)) end
	end
	d(string.format("Strings: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

function SnapShot:LootGetList()                                                                -- 2021/10/12
	self.Lines = {}
	self.ReportName="New Items"
	self.Header = {"Item","Qty","Type","Qual","Status","Price","MM","TTC","When"}
	for ix = 1,#self.Loots do
		local iLine = {}
		local iLink = OT_Hash2Link(self.Loots[ix].hash)
		local iStatus = "-"
		if IsItemLinkBound(iLink) then iStatus = "B" end
		if IsItemLinkStolen(iLink) then iStatus = "S" end
		iLine = {
			self.Loots[ix].name,
			self.Loots[ix].quantity,
			GetItemLinkItemType(iLink),
			GetItemLinkDisplayQuality(iLink),
			iStatus,
			GetItemLinkValue(iLink,false),
			OT_GetPriceMM(iLink),
			OT_GetPriceTTC(iLink,"Sugg"),
			self.Loots[ix].when
		}
		if GetItemLinkItemType(iLink) == 60 then
      local vouchers = math.floor(((string.match(itemLink,"(%d+)|") or 0)+5000)/10000)
			iLine[1] = string.format("%s (%s)",iLine[1],vouchers)
		end
		local isOkay = true
		if Check(OTSnap_P5G1B1) and not IsItemLinkBound(iLink)     then isOkay=false end
		if Check(OTSnap_P5G1B2) and not IsItemLinkStolen(iLink)    then isOkay=false end
		if Check(OTSnap_P5G1B3) and not IsItemLinkContainer(iLink) then isOkay=false end
		if isOkay then
			table.insert(self.Lines,table.concat(iLine,OTSnap:GetDelimiter()))
		end
	end
	d(string.format("Loot: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

function SnapShot:MasterWritGetDetails(bagId,slotIndex)                                        -- 2021/10/12
	local AlchFX = {
		"Rest Health","Rav Health","Rest Magicka","Rav Magicka","Rest Stamina","Rav Stamina",
		"Incr Spell Resist","Breach","Incr Armor","Fracture","Incr Spell Power","Cowardice",
		"Incr Weapon Power","Maim","Spell Critical","Uncertainty","Weapon Critical","Enervation",
		"Unstoppable","Entrapment","Detection","Invisible","Speed","Hindrance","Protection",
		"Vulnerability","Lingering Health","Gradual Rav Health","Vitality","Defile"
		}
	local EqName = {
		nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,             -- 01-17
		"Necklace",nil,nil,nil,nil,nil,"Ring",nil,                                       -- 18-25
		"Hat",nil,"Robe","Epaulets","Sash","Breeches","Shoes",nil,"Gloves",              -- 26-34
		"Helmet",nil,"Jack","Arm Cops","Belt","Guards","Boots",nil,"Bracers",            -- 35-43
		"Helm",nil,"Cuirass","Pauldron","Girdle","Greaves","Sabatons",nil,"Gauntlets",   -- 44-52
		"Axe",nil,nil,"Mace",nil,nil,"Sword",nil,nil,"Dagger",nil,nil,"Shield",nil,      -- 53-66
		"Greatsword","Battle Axe","Maul",                                                -- 67-69
		"Bow","Restoration Staff","Inferno Staff","Ice Staff","Lightning Staff"          -- 70-74
		}
	local iData = {}
	local iLink = GetItemLink(bagId,slotIndex,LINK_STYLE_BRACKETS)                  -- Item Link
	local tLink = {}                                          -- table of entries from Item Link
		for s in string.gmatch(string.sub(iLink,5),"%d+") do table.insert(tLink,s) end
		for ix=1,#tLink do tLink[ix]=tLink[ix]+0 end
	local iText = GenerateMasterWritBaseText(iLink)
	iData[1] = "--"
	iData[2] = zo_strformat(SI_TOOLTIP_ITEM_NAME,GetItemLinkName(iLink))
	iData[3] = math.floor((tLink[21]+5000)/10000)                               -- Voucher Count
	for ix=4,8 do iData[ix]="-" end
	if tLink[8]==188 or tLink[8]==190 or tLink[8]==192 or tLink[8]==194 or tLink[8]==255 then
		iData[4] = EqName[tLink[7]] or string.format("[%s]",tLink[7])                -- Equipment
		iData[5] = string.sub(string.sub(iText,string.find(iText,"Quality: [^;]*")),10)
		iData[6] = string.sub(string.sub(iText,string.find(iText,"Trait: [^;]*")),8)
		iData[7] = string.sub(string.sub(iText,string.find(iText,"Set: [^;]*")),6)
		if tLink[8] ~= 255
			then iData[8] = string.sub(string.sub(iText,string.find(iText,"Style: [^;]*")),8)
		end
	elseif tLink[7]==199 or tLink[7]==239 then                                        -- Alchemy
		if tLink[7]==199 then iData[4] = "Potion" else iData[4] = "Poison" end
		iData[6] = AlchFX[tLink[8]] or "??"
		iData[7] = AlchFX[tLink[9]] or "??"
		iData[8] = AlchFX[tLink[10]] or "??"
	elseif tLink[8]==207 or tLink[8]==225 then                                     -- Enchanting
		iData[4] = "Glyph"
		iData[5] = string.sub(string.sub(iText,string.find(iText,"Quality: [^;]*")),10)
		iData[6] = string.sub(string.sub(iText,string.find(iText,"Craft a [^G]*")),9,-2)
		iData[7] = string.sub(string.sub(iText,string.find(iText,"Glyph of [^;]*")),10)
	elseif tLink[1]==119693 or tLink[1]==156731 or tLink[1]==145545 or tLink[1]==153482 then
		iData[4] = "-"                   -- Provisioning, Deep Winter, New Life, Witches Festival
		iText = string.sub(iText,string.find(iText,"Craft .*")+6)
		if string.sub(iText,1,2) == "a " then iText = string.sub(iText,3) end
		if string.sub(iText,1,3) == "an " then iText = string.sub(iText,4) end
		iData[7] = iText
	end
	return iData
end

function SnapShot:MasterWritsGetList()                                                         -- 2021/10/12
	self.Header = {"Where","Master Writ","Vouchers","Item","Quality","Trait","Set","Style"}
	self.Lines = {}
	self.ReportName="Master Writs"
	local dt,ix
	if Check(OTSnap_P6G1B1) then
		local gInv = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK)           -- Carried
		for ix,dt in pairs(gInv) do
			if GetItemType(dt.bagId,dt.slotIndex)==60 then
				gList = SnapShot:MasterWritGetDetails(dt.bagId,dt.slotIndex)
				gList[1] = "Pers"
				self.Lines[#self.Lines+1] = gList
			end
		end
	end
	if Check(OTSnap_P6G1B2) then
		local gInv = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BANK)                 -- Bank1
		for ix,dt in pairs(gInv) do
			if GetItemType(dt.bagId,dt.slotIndex)==60 then
				gList = SnapShot:MasterWritGetDetails(dt.bagId,dt.slotIndex)
				gList[1] = "Bank"
				self.Lines[#self.Lines+1] = gList
			end
		end
		local gInv = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_SUBSCRIBER_BANK)      -- Bank2
		for ix,dt in pairs(gInv) do
			if GetItemType(dt.bagId,dt.slotIndex)==60 then
				gList = SnapShot:MasterWritGetDetails(dt.bagId,dt.slotIndex)
				gList[1] = "Bank"
				self.Lines[#self.Lines+1] = gList
			end
		end
	end
	if IsGuildBankOpen() and Check(OTSnap_P6G1B3) then
		local gInv = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_GUILDBANK)       -- Guild Bank
		for ix,dt in pairs(gInv) do if GetItemType(dt.bagId,dt.slotIndex)==60 then
			gList = SnapShot:MasterWritGetDetails(dt.bagId,dt.slotIndex)
			gList[1] = "Guild"
			self.Lines[#self.Lines+1] = gList
		end end
	end
	for ix = 1,#self.Lines do
		self.Lines[ix] = table.concat(self.Lines[ix],OTSnap:GetDelimiter())
	end
	if #self.Lines > 1 then table.sort(self.Lines) end
	d(string.format("Master Writs: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

function SnapShot:StylesGetList()                                                              -- 2021/10/11
	local flagKnown   = not Check(OTSnap_P7G1B2)
	local flagUnknown = not Check(OTSnap_P7G1B1)
	local iLine
	self.Header = {"Motif #","Style Name","StyleId","Style Mat","Known"}
	self.ReportName="Styles"
	SnapShot.Lines = {}
	for ix=1,#OT_Styles do
		local cat,coll,book = OT_GetStyleBookIndex(ix,0)
		local _,_,isKnown,_ = GetLoreBookInfo(cat,coll,book)
		if OT_Styles[ix].loreChapter > 0 and not isKnown then
			cat,coll,book = OT_GetStyleBookIndex(ix,1)
			for jx=1,14 do
				local cTitle,_,isKnown,_ = GetLoreBookInfo(cat,coll,jx)
				iLine= { OT_Styles[ix].motifId,
					string.match(cTitle,": (.+)"),
					ix,
					OT_GetLinkName(GetItemStyleMaterialLink(ix,0)),
					(isKnown and "Known" or "Unknown")
				}
				local okay = false
				if flagKnown and isKnown then okay = true end
				if flagUnknown and not isKnown then okay = true end
				if (tonumber(iLine[1]) or 0) > 0 and okay then
					table.insert(self.Lines,table.concat(iLine,OTSnap:GetDelimiter()))
				end
			end
		else
			iLine= { OT_Styles[ix].motifId,
				OT_Styles[ix].name,
				ix,
				OT_GetLinkName(GetItemStyleMaterialLink(ix,0)),
				(isKnown and "Known" or "Unknown")
			}
			local okay = false
			if flagKnown and isKnown then okay = true end
			if flagUnknown and not isKnown then okay = true end
			if (tonumber(iLine[1]) or 0) > 0 and okay then
				table.insert(self.Lines,table.concat(iLine,OTSnap:GetDelimiter()))
			end
		end
	end
	if #self.Lines > 1 then table.sort(self.Lines) end
	d(string.format("Styles: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

function SnapShot:TraitsGetList()                                                              -- 2021/10/12
	self.Lines = {}
	self.Header = {"Id","Trait Name"}
	self.ReportName="Trait List"
	for ix = ITEM_TRAIT_TYPE_MIN_VALUE,ITEM_TRAIT_TYPE_MAX_VALUE do
		local iLine = { ix,GetString("SI_ITEMTRAITTYPE",ix),OT_GetSmithingTraitItemName(ix) }
		table.insert(self.Lines,table.concat(iLine,OTSnap:GetDelimiter()))
	end
	d(string.format("Traits: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

function SnapShot:GetEsoItems(startAt)
	startAt = startAt or 1
	self.Lines = {}
	self.Header = {"Id","Item Name"}
	for ix=startAt,startAt+4999 do
		local ii = string.format("|H1:item:%s:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",ix)
		if #OT_GetLinkName(ii) > 0 then
			local iLine = {ix,OT_GetLinkName(ii)}
			table.insert(self.Lines,table.concat(iLine,OTSnap:GetDelimiter()))
		end
	end
	d(string.format("Items: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

-- =========================================================================================================

function SnapShot:HistoryGetReport() -- Guild History Report
	local sformat = string.format
	local smatch  = string.match
	local ssub    = string.sub
	local tinsert = table.insert
	self.Header = {OT_GetGuildNameFromIndex(self.saved.Guild),"Person","Action","Qty","What","Who","Value","Tax","EventId" }
  if OT_UIText(OTSnap_P2G2B6X) == "[Include]" then self.Header[9] = "EventId" end
	if OT_UIText(OTSnap_P2G2B6X) == "[Sort By]" then self.Header[9] = "When" end
	if OT_UIText(OTSnap_P2G2B6X) == "[Exclude]" then self.Header[9] = nil end
	if Check(OTSnap_P2G3B1) or Check(OTSnap_P2G3B2) or Check(OTSnap_P2G3B3) then
		tinsert(self.Header,"Raffle")
	end
	self.ReportName="Guild History"
	self.Lines = {}

  local guildId = GetGuildId(self.saved.Guild)
  local timeFormat = { D = "!%Y-%m-%d"; H = "!%Y-%m-%d %Hh"; M = "!%Y-%m-%d %H:%M"; S = "!%Y-%m-%d %H:%M:%S" }
  local dtf = timeFormat[ssub(OT_UIText(OTSnap_P2G2B1X),2,2)]
  local eLine = {}
  local etx = (OT_UIText(OTSnap_P2G2B3X) == "[Text]")

  local GHC_ROSTER = GUILD_HISTORY_EVENT_CATEGORY_ROSTER
  local GHC_BITEMS = GUILD_HISTORY_EVENT_CATEGORY_BANKED_ITEM
  local GHC_BMONEY = GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY
  local GHC_TRADER = GUILD_HISTORY_EVENT_CATEGORY_TRADER
  local GHC_MILES  = GUILD_HISTORY_EVENT_CATEGORY_MILESTONE
  local GHC_CUSTOM = GUILD_HISTORY_EVENT_CATEGORY_ACTIVITY
  local GHC_AVA    = GUILD_HISTORY_EVENT_CATEGORY_AVA_ACTIVITY

  local okay = {}
  for ix=1,#OTSnap.P2G1List do
    if OTSnap.P2G1List[ix].fid=="AWar" and OTSnap.P2G1List[ix].checked then okay[GHC_AVA]    = true okay["AWar"] = true end
    if OTSnap.P2G1List[ix].fid=="Cust" and OTSnap.P2G1List[ix].checked then okay[GHC_CUSTOM] = true end
    if OTSnap.P2G1List[ix].fid=="GDep" and OTSnap.P2G1List[ix].checked then okay[GHC_BMONEY] = true okay["GDep"] = true end
    if OTSnap.P2G1List[ix].fid=="GTra" and OTSnap.P2G1List[ix].checked then okay[GHC_BMONEY] = true okay["GTra"] = true end
    if OTSnap.P2G1List[ix].fid=="GWdr" and OTSnap.P2G1List[ix].checked then okay[GHC_BMONEY] = true okay["GWdr"] = true end
    if OTSnap.P2G1List[ix].fid=="IDep" and OTSnap.P2G1List[ix].checked then okay[GHC_BITEMS] = true okay["IDep"] = true end
    if OTSnap.P2G1List[ix].fid=="IWdr" and OTSnap.P2G1List[ix].checked then okay[GHC_BITEMS] = true okay["IWdr"] = true end
    if OTSnap.P2G1List[ix].fid=="Lock" and OTSnap.P2G1List[ix].checked then okay[GHC_MILES]  = true okay["Lock"] = true end
    if OTSnap.P2G1List[ix].fid=="RApp" and OTSnap.P2G1List[ix].checked then okay[GHC_ROSTER] = true okay["RApp"] = true end
    if OTSnap.P2G1List[ix].fid=="RBlk" and OTSnap.P2G1List[ix].checked then okay[GHC_ROSTER] = true okay["RBlk"] = true end
    if OTSnap.P2G1List[ix].fid=="RMem" and OTSnap.P2G1List[ix].checked then okay[GHC_ROSTER] = true okay["RMem"] = true end
    if OTSnap.P2G1List[ix].fid=="RPro" and OTSnap.P2G1List[ix].checked then okay[GHC_ROSTER] = true okay["RPro"] = true end
    if OTSnap.P2G1List[ix].fid=="Sale" and OTSnap.P2G1List[ix].checked then okay[GHC_TRADER] = true okay["Sale"] = true end
  end

  if okay[GHC_CUSTOM] then
    for ix=1,GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_ACTIVITY) do
      local eid,when,_,etype,who = GetGuildHistoryActivityEventInfo(guildId,ix)
      if OTSnap:DateInRange(when) then
        eLine = { os.date(dtf,when),who,etype,0,"-","-",0,0,eid }
        if etype == GUILD_HISTORY_ACTIVITY_EVENT_ABOUT_US_EDITED      then eLine[3]="Edit"   eLine[5]="About"  end
        if etype == GUILD_HISTORY_ACTIVITY_EVENT_MOTD_EDITED           then eLine[3]="Edit"   eLine[5]="MOTD"   end
        if etype == GUILD_HISTORY_ACTIVITY_EVENT_RECRUITMENT_LISTED    then eLine[3]="List"   eLine[5]="Finder" end
        if etype == GUILD_HISTORY_ACTIVITY_EVENT_RECRUITMENT_UNLISTED  then eLine[3]="Unlist" eLine[5]="Finder" end
        if OT_UIText(OTSnap_P2G2B6X) == "[Sort By]" then eLine[1],eLine[9] = eLine[9],eLine[1] end
        if OT_UIText(OTSnap_P2G2B6X) == "[Exclude]"  then eLine[9] = nil end
        if not Check(OTSnap_P2G3B4) then
          tinsert(self.Lines, table.concat(eLine,OTSnap:GetDelimiter()))
        end
      end
    end
  end

  if okay[GHC_ROSTER] then
    for ix=1,GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_ROSTER) do
      local eid,when,_,etype,who,whom,rank = GetGuildHistoryRosterEventInfo(guildId,ix)
      if OTSnap:DateInRange(when) then
        local eLine = { os.date(dtf,when),who,etype,0,"-",whom,0,0,eid }
        local doLine = false
        rank = GetGuildRankCustomName(guildId,rank)
        if etype == GUILD_HISTORY_ROSTER_EVENT_INVITE                    and okay["RMem"] then eLine[3]="Invited"     doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_JOIN                      and okay["RMem"] then eLine[3]="Joined"      doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_KICKED                    and okay["RMem"] then eLine[3]="Kicked"      doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_LEAVE                     and okay["RMem"] then eLine[3]="Left"        doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_PROMOTE                   and okay["RPro"] then eLine[3]="Promoted"    eLine[5]=rank doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_DEMOTE                    and okay["RPro"] then eLine[3]="Demoted"     eLine[5]=rank doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_APPLICATION_ACCEPTED      and okay["RApp"] then eLine[3]="Accepted"    doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_APPLICATION_DECLINED      and okay["RApp"] then eLine[3]="Declined"    doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_ADDED_TO_BLACKLIST        and okay["RBlk"] then eLine[3]="B/L Added"   doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_EDIT_BLACKLIST_NOTE       and okay["RBlk"] then eLine[3]="B/L Edited"  doLine=true end
        if etype == GUILD_HISTORY_ROSTER_EVENT_REMOVED_FROM_BLACKLIST    and okay["RBlk"] then eLine[3]="B/L Removed" doLine=true end
        if doLine and not Check(OTSnap_P2G3B4) then
          if OT_UIText(OTSnap_P2G2B6X) == "[Sort By]" then eLine[1],eLine[9] = eLine[9],eLine[1] end
          if OT_UIText(OTSnap_P2G2B6X) == "[Exclude]"  then eLine[9] = nil end
          tinsert(self.Lines, table.concat(eLine,OTSnap:GetDelimiter()))
        end
      end
    end
  end

  if okay[GHC_BITEMS] then
    for ix=1,GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_ITEM) do
      local eid,when,_,etype,who,itemlink,amount = GetGuildHistoryBankedItemEventInfo(guildId,ix)
      if OTSnap:DateInRange(when) then
        local value = GetItemLinkValue(itemlink,false)
        if OT_UIText(OTSnap_P2G2B4X) == "[ATT]"     then value = OT_GetPriceATT(itemlink) end
        if OT_UIText(OTSnap_P2G2B4X) == "[MM]"       then value = OT_GetPriceMM(itemlink) end
        if OT_UIText(OTSnap_P2G2B4X) == "[TTC/Sug]"  then value = OT_GetPriceTTC(itemlink,"Sugg") end
        if OT_UIText(OTSnap_P2G2B4X) == "[TTC/Avg]"  then value = OT_GetPriceTTC(itemlink,"Avg") end
        local eLine = { os.date(dtf,when),who,etype,amount,OT_GetLinkName(itemlink),"-",0,value*amount,eid }
        local doLine = false
        if etype == GUILD_HISTORY_BANKED_ITEM_EVENT_ADDED and okay["IDep"] then
          eLine[3]="Deposited" doLine=true
          if Check(OTSnap_P2G3B1) then -- Raffle tickets
            local tickets = 0
            local tValue = eLine[8]
            local tCost = string.match(OT_UIText(OTSnap_P2G3B1T),"%d+")
            if tCost and tonumber(tCost) > 0 then tCost = tonumber(tCost) else tCost = 1 end
            if OT_UIText(OTSnap_P2G3B1X) == "[if over]"
              then tickets = (tValue >= tCost) and 1 or 0
              else tickets = math.floor(tValue / tCost)
            end
            if tickets > 0 then table.insert(eLine,tickets) end
          end
        end
        if etype == GUILD_HISTORY_BANKED_ITEM_EVENT_REMOVED and okay["IWdr"] then eLine[3]="Withdrew" eLine[8]=-eLine[8] doLine=true end
        if Check(OTSnap_P2G3B4) and #eLine < 10 then doLine=false end
        if doLine then
          if OT_UIText(OTSnap_P2G2B6X) == "[Sort By]" then eLine[1],eLine[9] = eLine[9],eLine[1] end
          if OT_UIText(OTSnap_P2G2B6X) == "[Exclude]"  then eLine[9] = nil end
          tinsert(self.Lines, table.concat(eLine,OTSnap:GetDelimiter()))
        end
      end
    end
  end

  if okay[GHC_BMONEY] then
    for ix=1,GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY) do
      local eid,when,_,etype,who,currtype,amount,kiosk = GetGuildHistoryBankedCurrencyEventInfo(guildId,ix)
      if OTSnap:DateInRange(when) then
        local eLine = { os.date(dtf,when),who,etype,1,"-","-",0,0,eid }
        local doLine = false
        if etype == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED and okay["GDep"] then
          eLine[3]="Deposited" eLine[4]=amount eLine[5]="Gold" eLine[8]=amount doLine=true
          if Check(OTSnap_P2G3B2) then -- Raffle Tickets
            local tickets = 0
            local tValue = eLine[8]
            local tCost = string.match(OT_UIText(OTSnap_P2G3B2T),"%d+")
            if tCost and tonumber(tCost) > 0 then tCost = tonumber(tCost) else tCost = 1 end
            if OT_UIText(OTSnap_P2G3B2X) == "[if over]"
              then tickets = (tValue >= tCost) and 1 or 0
              else tickets = math.floor(tValue / tCost)
            end
            if OT_UIText(OTSnap_P2G3B2X) == "[per exact]" and math.fmod(tValue,tCost) > 0 then
              tickets = 0
            end
            if tickets > 0 then table.insert(eLine,tickets) end
          end
        end
        if etype == GUILD_HISTORY_BANKED_CURRENCY_EVENT_WITHDRAWN and okay["GWdr"] then
          eLine[3]="Withdrew" eLine[4]=amount eLine[5]="Gold" eLine[8]=-amount doLine=true
        end
        if etype == GUILD_HISTORY_BANKED_CURRENCY_EVENT_HERALDRY_EDITED and okay["GWdr"] then
          eLine[3]="Heraldry" eLine[4]=amount eLine[5]="Gold" eLine[8]=-amount doLine=true
        end
        if etype == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_BID and okay["GTra"] then
          eLine[3]="Bid" eLine[5]=kiosk eLine[8]=-amount doLine=true
        end
        if etype == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_BID_REFUND and okay["GTra"] then
          eLine[3]="Lost" eLine[5]=kiosk eLine[8]=amount doLine=true
        end
        if etype == GUILD_HISTORY_BANKED_CURRENCY_EVENT_KIOSK_PURCHASED and okay["GTra"] then
          eLine[3]="Hired" eLine[5]=kiosk eLine[8]=-amount doLine=true
        end
        if Check(OTSnap_P2G3B4) and #eLine < 10 then doLine=false end
        if doLine then
          if OT_UIText(OTSnap_P2G2B6X) == "[Sort By]" then eLine[1],eLine[9] = eLine[9],eLine[1] end
          if OT_UIText(OTSnap_P2G2B6X) == "[Exclude]"  then eLine[9] = nil end
          tinsert(self.Lines, table.concat(eLine,OTSnap:GetDelimiter()))
        end
      end
    end
  end

  if okay[GHC_TRADER] then
    for ix=1,GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER) do
      local eid,when,_,etype,who,whom,itemlink,amount,price,tax = GetGuildHistoryTraderEventInfo(guildId,ix)
      if OTSnap:DateInRange(when) then
        local eLine = { os.date(dtf,when),who,"Sold",amount,OT_GetLinkName(itemlink),whom,price,tax,eid }
        if Check(OTSnap_P2G3B3) then -- Raffle
          local tickets = 0
          local tValue = eLine[7]
          if OT_UIText(OTSnap_P2G3B3Y) == "[Tax]" then tValue = eLine[8] end
          local tCost = string.match(OT_UIText(OTSnap_P2G3B3T),"%d+")
          if tCost and tonumber(tCost) > 0 then tCost = tonumber(tCost) else tCost = 1 end
          if OT_UIText(OTSnap_P2G3B3X) == "[if over]"
            then tickets = (tValue >= tCost) and 1 or 0
            else tickets = math.floor(tValue / tCost)
          end
          if OT_UIText(OTSnap_P2G3B3Y) == "[Sale]" then tickets = 1 end
          if tickets > 0 then table.insert(eLine,tickets) end
        end
        if OT_UIText(OTSnap_P2G2B6X) == "[Sort By]" then eLine[1],eLine[9] = eLine[9],eLine[1] end
        if OT_UIText(OTSnap_P2G2B6X) == "[Exclude]"  then eLine[9] = nil end
        if Check(OTSnap_P2G3B4) then
          if #eLine > 9 then tinsert(self.Lines, table.concat(eLine,OTSnap:GetDelimiter())) end
        else
          tinsert(self.Lines, table.concat(eLine,OTSnap:GetDelimiter()))
        end
      end
    end
  end

  if okay[GHC_MILES] then
    for ix=1,GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_MILESTONE) do
      local eid,when,_,etype = GetGuildHistoryMilestoneEventInfo(guildId,ix)
      if OTSnap:DateInRange(when) then
        local eLine = { os.date(dtf,when),"-",etype,0,"-","-",0,0,eid }
        if etype == GUILD_HISTORY_MILESTONE_EVENT_BANK_LOCKED    then eLine[3]="Lock"   eLine[5]="Guild Bank"  end
        if etype == GUILD_HISTORY_MILESTONE_EVENT_BANK_UNLOCKED  then eLine[3]="Unlock" eLine[5]="Guild Bank"  end
        if etype == GUILD_HISTORY_MILESTONE_EVENT_KIOSK_LOCKED   then eLine[3]="Lock"   eLine[5]="Trader"      end
        if etype == GUILD_HISTORY_MILESTONE_EVENT_KIOSK_UNLOCKED then eLine[3]="Unlock" eLine[5]="Trader"      end
        if etype == GUILD_HISTORY_MILESTONE_EVENT_STORE_LOCKED   then eLine[3]="Lock"   eLine[5]="Guild Store" end
        if etype == GUILD_HISTORY_MILESTONE_EVENT_STORE_UNLOCKED then eLine[3]="Unlock" eLine[5]="Guild Store" end
        if etype == GUILD_HISTORY_MILESTONE_EVENT_TABARD_LOCKED  then eLine[3]="Lock"   eLine[5]="Tabard"      end
        if etype == GUILD_HISTORY_MILESTONE_EVENT_TABARD_UNLOCKED then eLine[3]="Unlock" eLine[5]="Tabard"     end
        if OT_UIText(OTSnap_P2G2B6X) == "[Sort By]" then eLine[1],eLine[9] = eLine[9],eLine[1] end
        if OT_UIText(OTSnap_P2G2B6X) == "[Exclude]"  then eLine[9] = nil end
        if not Check(OTSnap_P2G3B4) then
          tinsert(self.Lines, table.concat(eLine,OTSnap:GetDelimiter()))
        end
      end
    end
  end

  if okay[GHC_AVA] then
    for ix=1,GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_AVA_ACTIVITY) do
      local eid,when,_,etype,who,keep,camp = GetGuildHistoryAvAActivityEventInfo(guildId,ix)
      if OTSnap:DateInRange(when) then
        eLine = { os.date(dtf,when),who,etype,1,GetKeepName(keep),GetCampaignName(camp),0,0,eid }
        if etype == GUILD_HISTORY_AVA_ACTIVITY_EVENT_KEEP_CLAIMED   then eLine[3]="Claimed"  end
        if etype == GUILD_HISTORY_AVA_ACTIVITY_EVENT_KEEP_LOST      then eLine[3]="Lost"     end
        if etype == GUILD_HISTORY_AVA_ACTIVITY_EVENT_KEEP_RELEASED  then eLine[3]="Released" end
        if OT_UIText(OTSnap_P2G2B6X) == "[Sort By]" then eLine[1],eLine[9] = eLine[9],eLine[1] end
        if OT_UIText(OTSnap_P2G2B6X) == "[Exclude]"  then eLine[9] = nil end
        if not Check(OTSnap_P2G3B4) then
          tinsert(self.Lines, table.concat(eLine,OTSnap:GetDelimiter()))
        end
      end
    end
  end

	if #self.Lines > 1 then table.sort(self.Lines) end
	d(sformat("Guild Events: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()

end

-- =========================================================================================================

function SnapShot:RecipeGetReport()                                                            -- 2021/10/01
	if #OT_Recipes == 0 then OT_MakeRecipeList(self.saved.Items) end
	local catLines = 0
	local itemTemplate = "|H1:item:%s:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
	local tradeSkills = {"Smth","Clth","Ench","Alch","Prov","Wood","Jewl"}

	local getKnown = Check(OTSnap_P4G3B1)
	local getUnknown = Check(OTSnap_P4G3B2)
	if not (getKnown or getUnknown) then
		getKnown = true
		getUnknown = true
	end

	self.Header = {"Recipe"}
	if Check(OTSnap_P4G2B1) then table.insert(self.Header,"Qual") end
	if Check(OTSnap_P4G2B2) then table.insert(self.Header,"Cat") end
	if Check(OTSnap_P4G2B3) then table.insert(self.Header,"Station") end
	if Check(OTSnap_P4G2B4) then table.insert(self.Header,"Res Val") end
	if Check(OTSnap_P4G2B5) then table.insert(self.Header,"Materials") end
	if Check(OTSnap_P4G2B6) then table.insert(self.Header,"Mat Cost") end

	self.Lines = {}
	self.ReportName="Recipes"

	for rl=1,GetNumRecipeLists() do
		if Check(_G[string.format("OTSnap_P4G1B%s",rl)]) then
			local rList,rNum = GetRecipeListInfo(rl)
			for ix=1,rNum do
				local ikr,rName,ing,_,_,_,rStation,_ = GetRecipeInfo(rl,ix)
				local rLink = string.format(itemTemplate,OT_Recipes[rl][ix])
				local iLink = GetItemLinkRecipeResultItemLink(rLink,1)
				if (getKnown and ikr) or (getUnknown and not ikr) and #rName > 0 then
					rName = zo_strformat(SI_TOOLTIP_ITEM_NAME,rName)
					local iLine = {rName}
					if Check(OTSnap_P4G2B1) then 
						local rQual = GetItemLinkDisplayQuality(iLink)
						if OT_UIText(OTSnap_P4G2B1X) == "[Text]" then rQual = GetString("SI_ITEMQUALITY",rQual) end
						table.insert(iLine,rQual)
					end
					if Check(OTSnap_P4G2B2) then
						if OT_UIText(OTSnap_P4G2B2X) == "[Text]"
							then table.insert(iLine,rList)
							else table.insert(iLine,rl)
						end
						table.insert(iLine,rCat)
					end
					if Check(OTSnap_P4G2B3) then
						if OT_UIText(OTSnap_P4G2B3X) == "[Text]"
							then table.insert(iLine,GetCraftingSkillName(rStation))
							else table.insert(iLine,rStation)
						end
					end
					if Check(OTSnap_P4G2B4) then
						if     OT_UIText(OTSnap_P4G2B4X) == "[ATT]" then
							table.insert(iLine,OT_GetPriceATT(iLink))
						elseif OT_UIText(OTSnap_P4G2B4X) == "[MM]" then
							table.insert(iLine,OT_GetPriceMM(iLink))
						elseif OT_UIText(OTSnap_P4G2B4X) == "[TTC/Sug]" then
							table.insert(iLine,OT_GetPriceTTC(iLink,"Sugg"))
						elseif OT_UIText(OTSnap_P4G2B4X) == "[TTC/Avg]" then
							table.insert(iLine,OT_GetPriceTTC(iLink,"Avg"))
						else
							table.insert(iLine,GetItemLinkValue(iLink,false))
						end
					end
					if Check(OTSnap_P4G2B5) or Check(OTSnap_P4G2B6) then
						local ingList,matValue,partial = {},0,false
						for jx=1,ing do
							local ingName,_,ingQty = GetItemLinkRecipeIngredientInfo(rLink,jx)
							local ingLink = GetItemLinkRecipeIngredientItemLink(rLink,jx,0)
							ingName = zo_strformat(SI_TOOLTIP_ITEM_NAME,ingName)
							local v = 0
							if     OT_UIText(OTSnap_P4G2B6X) == "[ATT]" then v = OT_GetPriceATT(ingLink)
							elseif OT_UIText(OTSnap_P4G2B6X) == "[MM]" then  v = OT_GetPriceMM(ingLink)
							elseif OT_UIText(OTSnap_P4G2B6X) == "[TTC/Sug]" then v = OT_GetPriceTTC(ingLink,"Sugg")
							elseif OT_UIText(OTSnap_P4G2B6X) == "[TTC/Avg]" then v = OT_GetPriceTTC(ingLink,"Avg")
							else v = GetItemLinkValue(ingLink,false)
							end
							if v == 0 then partial = true end
							matValue = matValue + v * ingQty
							table.insert(ingList,string.format("%s-%s",ingName,ingQty))
						end
						if Check(OTSnap_P4G2B5) then
							if #ingList > 1 then table.sort(ingList) end
							table.insert(iLine,table.concat(ingList," "))
						end
						if Check(OTSnap_P4G2B6) then
							matValue = OT_TrimDecimals(matValue)
							if partial then matValue = string.format("%s*",matValue) end
							table.insert(iLine,matValue)
						end
					end
					table.insert(self.Lines,table.concat(iLine,OTSnap:GetDelimiter()))
				end
			end
		end
	end
	if #self.Lines > 0 then table.sort(self.Lines) end
	d(string.format("Recipes: |c40FF80%s|r entries.",#self.Lines))
	OTSnap:ShowReport()
end

-- =========================================================================================================

function SnapShot:RosterGetBlacklist(guild)
	if GetNumGuildBlacklistEntries(guild) == 0 then return end
	for ix = 1,GetNumGuildBlacklistEntries(guild) do
		local who,note = GetGuildBlacklistInfoAt(guild,ix)
		local rank,stat,away = -2,0,0
		local eData = { string.sub(who,2) }
		if OT_UIText(OTSnap_P3G3B2X) == "[Text]" then rank="Blacklist" end
		if OT_UIText(OTSnap_P3G3B3X) == "[Text]" then stat="-" end
		if Check(OTSnap_P3G3B2) then table.insert(eData,rank) end
		if Check(OTSnap_P3G3B3) then table.insert(eData,stat) end
		if Check(OTSnap_P3G3B4) then table.insert(eData,away) end
		if Check(OTSnap_P3G3B5) then table.insert(eData,note) end
		table.insert(self.Lines, eData)
	end
end

function SnapShot:RosterGetInvitees(guild)
	if GetNumGuildInvitees(guild) == 0 then return end
	for ix = 1,GetNumGuildInvitees(guild) do
		local who,_ = GetGuildInviteeInfo(guild,ix)
		local note,rank,stat,away = "",-1,0,0
		local eData = { string.sub(who,2) }
		if OT_UIText(OTSnap_P3G3B2X) == "[Text]" then rank="Invitee" end
		if OT_UIText(OTSnap_P3G3B3X) == "[Text]" then stat="-" end
		if Check(OTSnap_P3G3B2) then table.insert(eData,rank) end
		if Check(OTSnap_P3G3B3) then table.insert(eData,stat) end
		if Check(OTSnap_P3G3B4) then table.insert(eData,away) end
		if Check(OTSnap_P3G3B5) then table.insert(eData,"") end
		table.insert(self.Lines, eData)
	end
end

function SnapShot:RosterGetMembers(guild)
	local now = GetTimeStamp()
	for ix=1,GetNumGuildMembers(guild) do
		local who,note,rank,stat,away = GetGuildMemberInfo(guild,ix)
		note = note:gsub("\n"," ")
		if away > 0 then
			if OT_UIText(OTSnap_P3G3B4X) == "[Date]"
				then away = os.date("%Y-%m-%d",now-away)
				else away = string.format("%s",math.floor(away/86400))
			end
		end
		local isOkay = false
		if Check(OTSnap_P3G2B1) and stat == 1  then isOkay = true end  -- Online
		if Check(OTSnap_P3G2B2) and stat == 2  then isOkay = true end  -- Away
		if Check(OTSnap_P3G2B3) and stat == 3  then isOkay = true end  -- Do not disturb
		if Check(OTSnap_P3G2B4) and stat == 4  then isOkay = true end  -- Offline
		if Check(OTSnap_P3G4B1) and #note == 0 then isOkay = false end -- Notes
		if Check(OTSnap_P3G4B2) and #note > 0  then isOkay = false end -- No Notes
		if isOkay then
			local eData = { string.sub(who,2) }
			if OT_UIText(OTSnap_P3G3B2X) == "[Text]" then
				rank=GetGuildRankCustomName(guild,rank)
			end
			if OT_UIText(OTSnap_P3G3B3X) == "[Text]" then stat=GetString("SI_PLAYERSTATUS",stat) end
			if Check(OTSnap_P3G3B2) then table.insert(eData,rank) end
			if Check(OTSnap_P3G3B3) then table.insert(eData,stat) end
			if Check(OTSnap_P3G3B4) then table.insert(eData,away) end
			if Check(OTSnap_P3G3B5) then table.insert(eData,note) end
			table.insert(self.Lines, eData)
		end
	end
end

function SnapShot:RosterGetReport()
	if self.saved.Guild < 1 then return end
	self.Header = { "Account Name" }
	if Check(OTSnap_P3G3B1) then table.insert(self.Header,"Guild") end
	if Check(OTSnap_P3G3B2) then table.insert(self.Header,"Rank") end
	if Check(OTSnap_P3G3B3) then table.insert(self.Header,"Status") end
	if Check(OTSnap_P3G3B4) then table.insert(self.Header,"Time Away") end
	if Check(OTSnap_P3G3B5) then table.insert(self.Header,"Note") end
	self.Lines = {}
	self.ReportName="Roster"

	local gid = GetGuildId(ctrlNum)

	if OTSnap_P3G5:IsHidden() then
		if Check(OTSnap_P3G1B1) then self:RosterGetMembers(gid) end
		if Check(OTSnap_P3G1B2) then self:RosterGetBlacklist(gid) end
		if Check(OTSnap_P3G1B3) then self:RosterGetInvitees(gid) end
	else
		for gx = 1,GetNumGuilds() do
			if Check(_G[string.format("OTSnap_P3G5B%s",gx)]) then
				gid = GetGuildId(gx)
				if Check(OTSnap_P3G1B1) then self:RosterGetMembers(gid) end
				if Check(OTSnap_P3G1B2) then self:RosterGetBlacklist(gid) end
				if Check(OTSnap_P3G1B3) then self:RosterGetInvitees(gid) end
			end
		end
	end
	for ix = 1,#self.Lines do
		self.Lines[ix] = table.concat(self.Lines[ix],OTSnap:GetDelimiter())
	end
	if #self.Lines > 1 then table.sort(self.Lines) end
	if OT_UIText(OTSnap_B220X) == "[Yes]" and #self.Lines > 1 then 
		for ix = 1,#self.Lines do
			self.Lines[ix] = string.format("%s. %s",ix,self.Lines[ix])
		end
	end
	d(string.format("Guild Roster: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

-- =========================================================================================================

function SnapShot:StuffGetCurrency(currBag) -- General fetch for currency lists
	bagId = 0
	if currBag == CURRENCY_LOCATION_ACCOUNT    then bagId = BAG_BANK end
	if currBag == CURRENCY_LOCATION_BANK       then bagId = BAG_BANK end
	if currBag == CURRENCY_LOCATION_CHARACTER  then bagId = BAG_BACKPACK end
	if currBag == CURRENCY_LOCATION_GUILD_BANK then bagId = BAG_GUILDBANK end
	for ix=1,10 do
		local iLink = string.format("|H1:currency:%s|h|h",ix)
		local iKey = string.format("%s;%s",bagId,OT_Link2Hash(iLink))
		local iAmt = GetCurrencyAmount(ix,currBag)
		if iAmt > 0 then
			self.Stuff[iKey] = iAmt
		end
	end
end

function SnapShot:StuffGetFurniture(position) -- General fetch for placed furniture
	local fCount = 0
	local fBegin = HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_BEGIN
	local fEnd   = HOUSING_FURNISHING_LIMIT_TYPE_ITERATION_END
	local keyBag = BAG_PLAYER_HOUSE + GetCurrentZoneHouseId()
	for ix=fBegin,fEnd do
		fCount = fCount + GetNumHouseFurnishingsPlaced(ix)
	end
	local fId,fSpecial = nil,0
	for ix=1,fCount do
		fId = GetNextPlacedHousingFurnitureId(fId)
		local fName,_,_ = GetPlacedHousingFurnitureInfo(fId)
		local iLink,cLink = GetPlacedFurnitureLink(fId,0)
		if string.len(iLink)==0 then iLink = cLink end
		local xp,yp,zp = HousingEditorGetFurnitureWorldPosition(fId)
		local pt,ya,ro = HousingEditorGetFurnitureOrientation(fId)
			pt = math.floor(pt*18000/math.pi+0.5)/100
			ya = math.floor(ya*18000/math.pi+0.5)/100
			ro = math.floor(ro*18000/math.pi+0.5)/100
		if position then
			local iKey = string.format("%s:%s;%s",keyBag,ix,OT_Link2Hash(iLink))
			self.Stuff[iKey] = 1
			self.StuffXT[iKey] = { xp,yp,zp,pt,ya,ro }
		else
			local iKey = string.format("%s:%s;%s",keyBag,ix,OT_Link2Hash(iLink))
			if self.Stuff[iKey]
				then self.Stuff[iKey] = self.Stuff[iKey]+1
				else self.Stuff[iKey] = 1
			end
		end
	end
end

function SnapShot:StuffGetItemDetails(itemLink) -- Fetch item details by ItemLink
	local dispatch,_ = GetItemLinkItemType(itemLink)
	if dispatch == 1 or dispatch == 2 then -- Weapon/Apparel
		local iLevel = GetItemLinkRequiredLevel(itemLink)
		if iLevel == 50 then iLevel = -GetItemLinkRequiredChampionPoints(itemLink) end
		local iTrait = GetString("SI_ITEMTRAITTYPE",GetItemLinkTraitType(itemLink))
		if iLevel > 0
			then return string.format("L%s %s",iLevel,iTrait)
			else return string.format("C%s %s",-iLevel,iTrait)
		end
	elseif dispatch == 4 or dispatch == 7 or dispatch == 12 then
		local iLevel = GetItemLinkRequiredLevel(itemLink)
		if iLevel == 50 then iLevel = -GetItemLinkRequiredChampionPoints(itemLink) end
		if iLevel > 0
			then return string.format("L%s",iLevel)
			else return string.format("C%s",-iLevel)
		end
	end
	return "--"
end

function SnapShot:StuffGetItems(bagId) -- General fetch for inventory lists
	local gInv = SHARED_INVENTORY:GenerateFullSlotData(nil,bagId)
	local keyBag = bagId
	if keyBag == BAG_SUBSCRIBER_BANK then keyBag = BAG_BANK end
	for ix,dt in pairs(gInv) do
		local iLink = GetItemLink(bagId,dt.slotIndex,LINK_STYLE_BRACKETS)
		if iLink and #iLink > 0 then
			local iKey = string.format("%s;%s",keyBag,OT_Link2Hash(iLink))
			local _,iAmt = GetItemInfo(bagId,dt.slotIndex)
			if self.Stuff[iKey]
				then self.Stuff[iKey] = self.Stuff[iKey]+iAmt
				else self.Stuff[iKey] = iAmt
			end
		end
	end
end

function SnapShot:StuffGetMail(isCurrency) -- General fetch for mail attachments
	local iKey,iLink,mId
	local mIndex = BAG_MAIL + 1
	repeat
		mId = GetNextMailId(mId)
		local mSender,_,mSubject,_,_,_,_,_,mAtts,mGold,_,_,mWhen = GetMailItemInfo(mId)
		if string.sub(mSender,1,1) == "@" then mSender = string.sub(mSender,2) end
		mWhen = os.date("%Y-%m-%d %H:%M",GetTimeStamp()-mWhen)
		if not isCurrency then
			for ix=1,mAtts do
				iLink = GetAttachedItemLink(mId,ix,LINK_STYLE_BRACKETS)
				iKey = string.format("%s;%s",mIndex,OT_Link2Hash(iLink))
				_,iAmt = GetAttachedItemInfo(mId,ix)
				if #iLink > 0 then 
					if self.Stuff[iKey]
						then self.Stuff[iKey] = self.Stuff[iKey]+iAmt
						else self.Stuff[iKey] = iAmt
					end
					self.StuffXT[iKey] = {mWhen,mSender,mSubject}
				end
			end
		end
		if isCurrency and mGold>0 then
			iLink = string.format("|H1:currency:%s|h|h",CURT_MONEY)
			iKey = string.format("%s;%s",mIndex,OT_Link2Hash(iLink))
			self.Stuff[iKey] = mGold
			self.StuffXT[iKey] = {mWhen,mSender,mSubject}
		end
		mIndex = mIndex + 1
	until mId == nil
end

function SnapShot:StuffGetReport()                                                             -- 2021/10/27
	local tInsert = table.insert
	self.Stuff,self.StuffXT = {},{}

	if OT_IsLabelChecked(OTSnap_P1CashAcct)   then
		self:StuffGetCurrency(CURRENCY_LOCATION_ACCOUNT)
		self:StuffGetCurrency(CURRENCY_LOCATION_BANK)
	end
	if OT_IsLabelChecked(OTSnap_P1CashChar)   then self:StuffGetCurrency(CURRENCY_LOCATION_CHARACTER) end
	if OT_IsLabelChecked(OTSnap_P1CashMail)   then self:StuffGetMail(true) end
	if OT_IsLabelChecked(OTSnap_P1ItemsBank)  then
		self:StuffGetItems(BAG_BANK)
		self:StuffGetItems(BAG_SUBSCRIBER_BANK)
  end
	if OT_IsLabelChecked(OTSnap_P1ItemsComp)  then self:StuffGetItems(BAG_COMPANION_WORN) end
	if OT_IsLabelChecked(OTSnap_P1ItemsCraft) then self:StuffGetItems(BAG_VIRTUAL) end
	if OT_IsLabelChecked(OTSnap_P1ItemsMail)  then self:StuffGetMail(false) end
	if OT_IsLabelChecked(OTSnap_P1ItemsPack)  then self:StuffGetItems(BAG_BACKPACK) end
	if OT_IsLabelChecked(OTSnap_P1ItemsWorn)  then self:StuffGetItems(BAG_WORN) end
  if IsGuildBankOpen() then
		local gid = GetSelectedGuildBankId()
		for ix=1,GetNumGuilds() do
			if GetGuildId(ix) == gid then
				self.saved.Guild = ix
				OTSnap_GuildName:SetText(OT_GetGuildNameFromIndex(self.saved.Guild))
			end
		end
    if OT_IsLabelChecked(OTSnap_P1ItemsGuild) then self:StuffGetItems(BAG_GUILDBANK) end
    if OT_IsLabelChecked(OTSnap_P1CashGuild)  then self:StuffGetCurrency(CURRENCY_LOCATION_GUILD_BANK) end
  end
	if GetCurrentZoneHouseId() > 0 then
		if OT_IsLabelChecked(OTSnap_P1ItemsHouse) then self:StuffGetFurniture(true) end
		if OT_IsLabelChecked(OTSnap_P1ItemsChest) then
      for bagId=BAG_HOUSE_BANK_ONE,BAG_HOUSE_BANK_TEN do self:StuffGetItems(bagId) end
		end
	end

	self.Header = {}
	self.Lines = {}
	self.ReportName="Inventory"

  for ix=1,#OTSnap.P1Fields do
    if OTSnap.P1Fields[ix].checked then
      tInsert(self.Header,OTSnap.P1Fields[ix].head)
    end
  end

	OTSnap_P1G3B1T:SetText(OT_CleanNumberList(OT_UIText(OTSnap_P1G3B1T)))
	local itemFilters = {}
	for t in string.gmatch(OT_UIText(OTSnap_P1G3B1T),"%d+") do itemFilters[tonumber(t)] = true end

	for key,amt in pairs(self.Stuff) do
		local iBag = tonumber(string.match(key,"^%d+"))
    if iBag >= BAG_MAIL and iBag < BAG_PLAYER_HOUSE then iBag = BAG_MAIL end
    if iBag >= BAG_PLAYER_HOUSE then iBag,iHouse = BAG_PLAYER_HOUSE,iBag-BAG_PLAYER_HOUSE end

		local iHash = string.match(key,";(.*)")
		local iLink = OT_Hash2Link(iHash,LINK_STYLE_BRACKETS)
		local iLine = {}

		local isOkay = true
		if Check(OTSnap_P1G3B1) and isOkay then -- ItemTypes
			if OT_UIText(OTSnap_P1G3B1X) == "[Exclude]"
				then isOkay = isOkay and not itemFilters[GetItemLinkItemType(iLink)]
				else isOkay = isOkay and itemFilters[GetItemLinkItemType(iLink)]
			end
		end
		if Check(OTSnap_P1G3B2) and isOkay then -- Bound
			if OT_UIText(OTSnap_P1G3B2X) == "[Exclude]"
				then isOkay = isOkay and not IsItemLinkBound(iLink)
				else isOkay = isOkay and IsItemLinkBound(iLink)
			end
		end
		if Check(OTSnap_P1G3B3) and isOkay then -- Containers
			if OT_UIText(OTSnap_P1G3B3X) == "[Exclude]"
				then isOkay = isOkay and not IsItemLinkContainer(iLink)
				else isOkay = isOkay and IsItemLinkContainer(iLink)
			end
		end
		if Check(OTSnap_P1G3B4) and isOkay then -- Stolen
			if OT_UIText(OTSnap_P1G3B4X) == "[Exclude]"
				then isOkay = isOkay and not IsItemLinkStolen(iLink)
				else isOkay = isOkay and IsItemLinkStolen(iLink)
			end
		end
		if Check(OTSnap_P1G3B5) and isOkay then -- Companion
			if OT_UIText(OTSnap_P1G3B5X) == "[Exclude]"
				then isOkay = isOkay and string.sub(GetItemLinkName(iLink),1,9) ~= "Companion"
				else isOkay = isOkay and string.sub(GetItemLinkName(iLink),1,9) == "Companion"
			end
		end

		if isOkay then
      iLine = {}
      for ix=1,#OTSnap.P1Fields do
        local fid = OTSnap.P1Fields[ix].fid
        if OTSnap.P1Fields[ix].checked then
          if     fid=="Nom" then tInsert(iLine,zo_strformat(SI_TOOLTIP_ITEM_NAME,GetItemLinkName(iLink)))
          elseif fid=="Id#" then tInsert(iLine,GetItemLinkItemId(iLink))
          elseif fid=="Amt" then tInsert(iLine,amt)
          elseif fid=="Det" then tInsert(iLine,self:StuffGetItemDetails(iLink))
          elseif fid=="Loc" then tInsert(iLine,OT_GetBagName(iBag))
          elseif fid=="Bag" then tInsert(iLine,iBag)
          elseif fid=="ITx" then local c=GetItemLinkItemType(iLink) tInsert(iLine,GetString("SI_ITEMTYPE",c))
          elseif fid=="IT#" then local c=GetItemLinkItemType(iLink) tInsert(iLine,c)
          elseif fid=="STx" then local _,c=GetItemLinkItemType(iLink) tInsert(iLine,GetString("SI_SPECIALIZEDITEMTYPE",c))
          elseif fid=="ST#" then local _,c=GetItemLinkItemType(iLink) tInsert(iLine,c)
          elseif fid=="DQx" then tInsert(iLine,GetString("SI_ITEMDISPLAYQUALITY",GetItemLinkDisplayQuality(iLink)))
          elseif fid=="DQ#" then tInsert(iLine,GetItemLinkDisplayQuality(iLink))
          elseif fid=="FQx" then tInsert(iLine,GetString("SI_ITEMQUALITY",GetItemLinkFunctionalQuality(iLink)))
          elseif fid=="FQ#" then tInsert(iLine,GetItemLinkFunctionalQuality(iLink))
          elseif fid=="PVn" then tInsert(iLine,GetItemLinkValue(iLink,false))
          elseif fid=="PAt" then tInsert(iLine,OT_GetPriceATT(iLink))
          elseif fid=="PMm" then tInsert(iLine,OT_GetPriceMM(iLink))
          elseif fid=="TTS" then tInsert(iLine,OT_GetPriceTTC(iLink,"Sugg"))
          elseif fid=="TTA" then tInsert(iLine,OT_GetPriceTTC(iLink,"Avg"))
          elseif fid=="TTL" then tInsert(iLine,OT_GetPriceTTC(iLink,"Sale"))
          elseif fid=="Bnd" then tInsert(iLine,IsItemLinkBound(iLink) and "Y" or "-")
          elseif fid=="Sto" then tInsert(iLine,IsItemLinkStolen(iLink) and "Y" or "-")
          elseif fid=="Crw" then tInsert(iLine,IsItemLinkFromCrownStore(iLink) and "Y" or "-")
          elseif fid=="CrC" then tInsert(iLine,IsItemLinkFromCrownCrate(iLink) and "Y" or "-")
          elseif fid=="MaR" then if iBag == BAG_MAIL then tInsert(iLine,self.StuffXT[key][1]) else tInsert(iLine,"") end
          elseif fid=="MaF" then if iBag == BAG_MAIL then tInsert(iLine,self.StuffXT[key][2]) else tInsert(iLine,"") end
          elseif fid=="MaS" then if iBag == BAG_MAIL then tInsert(iLine,self.StuffXT[key][3]) else tInsert(iLine,"") end
          elseif fid=="FuH" then
            if iBag == BAG_PLAYER_HOUSE
              then tInsert(iLine,GetZoneNameById(GetHouseZoneId(iHouse)))
              else tInsert(iLine,"")
            end
          elseif fid=="FuL" then
            if iBag == BAG_PLAYER_HOUSE
              then tInsert(iLine,self.StuffXT[key][1]) tInsert(iLine,self.StuffXT[key][2]) tInsert(iLine,self.StuffXT[key][3])
              else tInsert(iLine,"") tInsert(iLine,"") tInsert(iLine,"")
            end
          elseif fid=="FuR" then
            if iBag == BAG_PLAYER_HOUSE
              then tInsert(iLine,self.StuffXT[key][4]) tInsert(iLine,self.StuffXT[key][5]) tInsert(iLine,self.StuffXT[key][6])
              else tInsert(iLine,"") tInsert(iLine,"") tInsert(iLine,"")
            end
          end
        end
      end
			tInsert(self.Lines,table.concat(iLine,OTSnap:GetDelimiter()))
		end
	end

	if #self.Lines > 1 then table.sort(self.Lines) end
	d(string.format("Inventory: |c40FF80%s|r entries.",#SnapShot.Lines))
	OTSnap:ShowReport()
end

-- =========================================================================================================

function SnapShot:HistoryGetEvents(historyCategory)                                            -- 2021/10/03
	self.History[self.saved.Guild][historyCategory] = {}
end

function SnapShot:Initialize()
  self.saved = ZO_SavedVars:NewAccountWide("Settings",1,nil,{})
    self.saved.Items = self.saved.Items or OT_ITEM_ID_MAX -- Maximum Item Number

    local winLeft        = self.saved.winLeft  or 8
    local winTop         = self.saved.winTop   or 8
    self.saved.Buttons   = self.saved.Buttons  or {}
    self.saved.Guild     = self.saved.Guild    or 1
    self.saved.Texts     = self.saved.Texts    or {}
    self.saved.P1Fields  = self.saved.P1Fields or {}
    self.saved.P2G1List  = self.saved.P2G1List or {}

  if self.saved.Texts["OTSnap_P2G2B6X"] == "[Date]" then
    self.saved.Texts["OTSnap_P2G2B6X"] = "[Include]"
    OTSnap_P2G2B6X:SetText("[Include]")
  end
  if self.saved.Texts["OTSnap_P2G2B6X"] == "[Event]" then
    self.saved.Texts["OTSnap_P2G2B6X"] = "[Sort By]"
    OTSnap_P2G2B6X:SetText("[Sort By]")
  end

  if self.saved.Guild > GetNumGuilds() then self.saved.Guild = 1 end
  for ix = 1,#OTSnap.P1Fields do
    OTSnap.P1Fields[ix].checked = self.saved.P1Fields[OTSnap.P1Fields[ix].fid] or OTSnap.P1Fields[ix].checked
  end
  ZO_ScrollList_Commit(OTSnap_P1FieldList)
  for ix = 1,#OTSnap.P2G1List do
    OTSnap.P2G1List[ix].checked = self.saved.P2G1List[OTSnap.P2G1List[ix].fid] or OTSnap.P2G1List[ix].checked
  end
  ZO_ScrollList_Commit(OTSnap_P2G1List)
  local isXpand = true
  while isXpand do
    isXpand = false
    local ssi = self.saved.Items
    for ix=1,2000 do
      local ii = string.format("|H1:item:%s:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",ssi+ix)
      if #OT_GetLinkName(ii) > 0 then
        self.saved.Items = ssi + ix
        isXpand = true
      end
    end
  end
	OT_MakeStyleList()
	OTSnap:WindowInitialize(winTop,winLeft)

	SLASH_COMMANDS["/snap"] = function() OTSnap:SetHidden(not OTSnap:IsHidden()) end
	
	EVENT_MANAGER:RegisterForEvent(self.name,EVENT_GUILD_SELF_JOINED_GUILD,self.GuildJoined)
	EVENT_MANAGER:RegisterForEvent(self.name,EVENT_GUILD_SELF_LEFT_GUILD,self.GuildLeft)
	EVENT_MANAGER:RegisterForEvent(self.name,EVENT_INVENTORY_SINGLE_SLOT_UPDATE,self.LootTake)
end

-- =========================================================================================================

function SnapShot.GuildJoined(event,serverId,characterName,guildId)                            -- 2021/10/04
	OTSnap:GuildMakeList()
	self.saved.Guild = GetNumGuilds()
	local guildName = "(no guild)"
	if self.saved.Guild > 0 then guildName = OT_GetGuildNameFromIndex(self.saved.Guild) end
	OTSnap_GuildName:SetText(guildName)
end

function SnapShot.GuildLeft(event,serverId,characterName,guildId)                              -- 2021/10/04
	OTSnap:GuildMakeList()
	if GetNumGuilds() < self.saved.Guild then self.saved.Guild = GetNumGuilds() end
	local guildName = "(no guild)"
	if self.saved.Guild > 0 then guildName = OT_GetGuildNameFromIndex(self.saved.Guild) end
	OTSnap_GuildName:SetText(guildName)
end

function SnapShot.LootTake(event,bag,slot,isNew,sound,reason,howMany,byChar,byName)            -- 2021/10/04
	if isNew and howMany > 0 then
		table.insert(SnapShot.Loots,{
			["hash"]     = OT_Link2Hash(GetItemLink(bag,slot)),
			["itemId"]   = GetItemId(bag,slot),
			["name"]     = zo_strformat(SI_TOOLTIP_ITEM_NAME,GetItemName(bag,slot)),
			["quantity"] = howMany,
			["when"]     = os.date("%Y-%m-%d %H:%M:%S",GetTimeStamp())
		})
	end
	while #SnapShot.Loots > SnapShot.MAX_LOOTS do table.remove(SnapShot.Loots,1) end
end

function SnapShot.OnLoaded(event,addonName)                                                    -- 2021/10/03
	if addonName ~= SnapShot.name then return end
	EVENT_MANAGER:UnregisterForEvent(SnapShot.name,EVENT_ADD_ON_LOADED)
	SnapShot:Initialize()
end

OTSnap.startDate = ""
OTSnap.endDate   = ""

local function OTSnap_ParseDate(s)  -- Converts date strings to UTC Unix timestamp to match ESO's GetTimeStamp()
  if not s or s == "" then return nil end
  s = s:match("^%s*(.-)%s*$")  -- trim whitespace

  local yr,mo,dy,hr,mi,sc

  -- Format: M/D/YYYY H:MM:SS  (e.g. 3/2/2026 3:03:35)
  mo,dy,yr,hr,mi,sc = s:match("^(%d+)/(%d+)/(%d%d%d%d)%s+(%d+):(%d+):(%d+)$")

  -- Format: M/D/YYYY  (date only)
  if not yr then
    mo,dy,yr = s:match("^(%d+)/(%d+)/(%d%d%d%d)$")
  end

  -- Format: YYYY-MM-DD
  if not yr then
    yr,mo,dy = s:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
  end

  if not yr then return nil end

  yr,mo,dy = tonumber(yr),tonumber(mo),tonumber(dy)
  hr,mi,sc = tonumber(hr) or 0, tonumber(mi) or 0, tonumber(sc) or 0

  -- Compute UTC Unix timestamp using the same algorithm ESO uses (no os.time to avoid timezone issues)
  -- Days since Unix epoch (1970-01-01) using proleptic Gregorian calendar
  local function isLeap(y) return (y%4==0 and y%100~=0) or y%400==0 end
  local monthDays = {31,28,31,30,31,30,31,31,30,31,30,31}
  local days = 0
  for y = 1970, yr-1 do days = days + (isLeap(y) and 366 or 365) end
  if isLeap(yr) then monthDays[2] = 29 end
  for m = 1, mo-1 do days = days + monthDays[m] end
  days = days + (dy - 1)
  return days * 86400 + hr * 3600 + mi * 60 + sc
end

function OTSnap:UpdateStartDate(newDate)
  OTSnap.startDate = newDate
end

function OTSnap:UpdateEndDate(newDate)
  OTSnap.endDate = newDate
end

function OTSnap:DateInRange(when)  -- Returns true if the timestamp passes the active date filter
  local s = OTSnap_ParseDate(OTSnap.startDate)
  local e = OTSnap_ParseDate(OTSnap.endDate)
  if s and when < s then return false end
  if e and when > (e + 86399) then return false end  -- include the full end day
  return true
end


-- =========================================================================================================
EVENT_MANAGER:RegisterForEvent(SnapShot.name,EVENT_ADD_ON_LOADED,SnapShot.OnLoaded)
-- =========================================================================================================