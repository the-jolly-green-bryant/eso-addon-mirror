-- Shissu Guild Tools Addon
-- ShissuRoster
--
-- Version: v2.2.3
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!

local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local green = _globals["green"]
local red = _globals["red"]

local zos = {
  ["History"] = GUILD_HISTORY_GENERAL,
  ["Joined"] = GUILD_EVENT_GUILD_JOIN,
  ["Bank"] = GUILD_HISTORY_BANK,
  ["GoldAdded"] = GUILD_EVENT_BANKGOLD_ADDED,
  ["GoldRemoved"] = GUILD_EVENT_BANKGOLD_REMOVED,
  ["ItemAdded"] = GUILD_EVENT_BANKITEM_ADDED,
  ["ItemRemoved"] = GUILD_EVENT_BANKITEM_REMOVED,
}        

local setPanel = ShissuFramework["setPanel"]
local createZOButton = ShissuFramework["interface"].createZOButton
local checkBoxLabel = ShissuFramework["interface"].checkBoxLabel
local round = ShissuFramework["func"].round

local _addon = {}                                                 
_addon.Name	= "ShissuRoster"
_addon.Version = "2.2.3"
_addon.formattedName	= stdColor .. "Shissu" .. white .. "'s Roster"

_addon.buttons = {}

_addon.userColor1 = white
_addon.userColor2 = white
_addon.userColor3 = white
_addon.userColor4 = white
_addon.userColor5 = white
_addon.userColorW = white

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version)
_addon.controls = {}

local _roster = {}
local _memberChars = {}
local _personalNote = {}

local _filter = {
  gold = 0,
  goldDir = 1;
  Daggerfall = true,
  Ebonheart = true,
  Aldmeri = true,
  offlineSince = 0;
  Offline = true;
  Online = true;
  rang = "";
}

_addon.settings = {
  ["gold"] = _L("TOTAL"),
  ["colGold"] = true,
  ["colChar"] = true,
  ["colNote"] = true,
}

local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter
local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit = ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit
 
function _addon.createSettingMenu()
  local controls = ShissuFramework._settings[_addon.Name].controls

  controls[#controls+1] = {
    type = "title",
    name = _L("COLADD"),
  }
  
  controls[#controls+1] = {
    type = "description",
    name = _L("COLADD2") .. stdColor .. "\n\reloadui",
  }  
                                          
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("COLCHAR"),
    getFunc = shissuRoster["colChar"],
    setFunc = function(_, value)
      shissuRoster["colChar"] = value
    --  Shissu_SuiteManager._bindings.reload()
    end,
  } 
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("COLGOLD"),
    getFunc = shissuRoster["colGold"],
    setFunc = function(_, value)
      shissuRoster["colGold"] = value
   --   Shissu_SuiteManager._bindings.reload()
    end,
  } 
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("COLNOTE"),
    getFunc = shissuRoster["colNote"],
    setFunc = function(_, value)
      shissuRoster["colNote"] = value
   --  Shissu_SuiteManager._bindings.reload()
    end,
  } 
end

-- Sekunden in die Form: XXX Tage XX Stunden umrechnen
function _addon.secsToTime(time, complete)
  local day = math.floor(time / 86400)
  local hours = math.floor(time / 3600) - (day * 24)
  local minutes = math.floor(time / 60) - (day * 1440) - (hours * 60)
  local seconds = time % 60

  if complete then return ("%dd %dh %dmin %ds"):format(day, hours, minutes, seconds) end
  
  -- mehr als 1 Tag
  if(day >= 1) then return ("%dd %dh"):format(day, hours) end
  
  -- Spieler sind weniger als 1d Offline
  if(hours >= 1) then return ("%dh %dmin"):format(hours, minutes) end
  
  -- Spieler sind weniger als 1h Offline
  if(minutes >= 1) then return ("%dmin %ds"):format(minutes, seconds) end
  
  -- Spieler sind weniger als 1m Offline
  return ("%ds"):format(seconds)
end

function _addon.createButton(name, var, offsetX, offsetY, parent) 
  local button = CreateControlFromVirtual(name, ZO_GuildRoster, "ZO_CheckButton")
  button:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetX, offsetY)
  
  checkBoxLabel(button, var)
  
  ZO_CheckButton_SetToggleFunction(button, function(control, checked)
    _filter[var] = checked
    
    _roster.refreshFilters()
  end)

  ZO_Tooltips_HideTextTooltip()
   
  return button
end

function _addon.anchorSet(R_offsetY, S_offsetX, S_offsetY)
  ZO_GuildRoster:SetAnchor(8,GUIROOT,8,0, R_offsetY)   
  ZO_GuildRosterSearch:SetAnchor(TOPRIGHT,ZO_GuildRoster,TOPRIGHT, S_offsetX, S_offsetY)   
end

function _addon.createLabel(name, anchor, text, dimension, offset, hidden, pos, font)
  if(not text) then text = "" end
  if(not dimension) or dimension == 0 then dimension = {100, 30} end
  if(not offset) then offset = {0, 0} end
  if (hidden == nil) then hidden = true end
  if(not pos) then pos = RIGHT end
  if(not font) then font = "ZoFontGame" end
  
  local control = WINDOW_MANAGER:CreateControl(name, anchor, CT_LABEL)
  
  control:SetFont(font)
  control:SetDimensions(dimension[1], dimension[2])
  control:SetAnchor(LEFT, anchor, pos, offset[1], offset[2])
  control:SetText(stdColor .. text)
  control:SetVerticalAlignment(LEFT)
  control:SetHidden(hidden)

  return control
end
          
function _addon.goldFilter()
  ESO_Dialogs["SGT_EDIT"].title = {text = "Gold?",}
  ESO_Dialogs["SGT_EDIT"].mainText = {text = "Gold ?",}  
  ESO_Dialogs["SGT_EDIT"].buttons[1] = {text = "OK",}     
  ESO_Dialogs["SGT_EDIT"].buttons[1].callback = function(dialog) 
    local gold = dialog:GetNamedChild("EditBox"):GetText()
    gold = tonumber(gold)
    local direct = ">"
          
    if (gold ~= nil) then
      if (type(gold) == "number") then
        if (_filter.goldDir == 0) then
          direct = "<"
        end

        SGT_Roster_GoldDeposit:SetText(white .. "Total Gold Paid " .. direct .. stdColor .. " " .. gold)
        _filter.gold = gold
        _roster.refreshFilters()
      end
    end
  end

  ZO_Dialogs_ShowDialog("SGT_EDIT")
end

function _addon.offlineFilter()
  ESO_Dialogs["SGT_EDIT"].title = {text = _L("OFFLINE"),}
  ESO_Dialogs["SGT_EDIT"].mainText = {text = _L("DAYS") .. "?",}  
  ESO_Dialogs["SGT_EDIT"].buttons[1] = {text = "OK",}     
  ESO_Dialogs["SGT_EDIT"].buttons[1].callback = function(dialog) 
    local days = dialog:GetNamedChild("EditBox"):GetText()
    days = tonumber(days)
      
    if (days ~= nil) then
      if (type(days) == "number") then
        SGT_Roster_OfflineSince:SetText(stdColor .. "Offline" .. white .. ": " .. days .. " " .. _L("DAYS"))
        _filter.offlineSince = days
        _roster.refreshFilters()
      end
    end
  end

  ZO_Dialogs_ShowDialog("SGT_EDIT")
end

function _roster.filterScrollList(self)
  local searchTerm = self.searchBox:GetText()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  local masterList = GUILD_ROSTER_MANAGER:GetMasterList()

  local GuildInfo = { 
    Max = 0,
    Choice = 0,
    Aldmeri = 0,
    Daggerfall = 0,
    Ebonheart = 0,                                                         
  }

  ZO_ClearNumericallyIndexedTable(scrollData)

  for i = 1, #masterList do
    local data = masterList[i]  
    local goldDeposit = 0
             
    -- Alle vorhandenen Characternamen, die man gesehen hat hinzufügen + 
    _memberChars[data.displayName] = _memberChars[data.displayName] or {}
    local memberChars = _memberChars[data.displayName]
    
    -- Charaktername weis färben, falls noch nicht geschehen
    if (string.find( data.characterName , "|c" )) == nil then
      data.characterName = white .. data.characterName
    end
    
    -- Nur Charaktername hinzufügen falls noch nicht vorhanden, oder bei einer Änderug
    local saveName = data.characterName
     
    if (string.find( saveName, "|ceeeeee" )) then
      saveName = string.gsub(saveName, "|ceeeeee", "")
    end
    
    if memberChars[saveName] ~= nil then
      if memberChars[saveName]["lvl"] ~= data.level or
        memberChars[saveName]["vet"] ~= data.veteranRank or
        memberChars[saveName]["class"] ~= data.class or
        memberChars[saveName]["alliance"] ~= data.alliance then
        memberChars[saveName] = { ["lvl"] = data.level, ["vet"] = data.veteranRank, ["class"] = data.class, ["alliance"] = data.alliance }  
      end  
    else
      memberChars[saveName] = { ["lvl"] = data.level, ["vet"] = data.veteranRank, ["class"] = data.class, ["alliance"] = data.alliance }  
    end

    -- Filtern der Daten
    local PlayerTime = math.floor(data.secsSinceLogoff / 86400)                                                    
       
    GuildInfo.Max = GuildInfo.Max + 1
      
    if data.alliance == 1 then GuildInfo.Aldmeri = GuildInfo.Aldmeri + 1
    elseif data.alliance == 2 then GuildInfo.Ebonheart = GuildInfo.Ebonheart + 1
    elseif data.alliance == 3 then GuildInfo.Daggerfall = GuildInfo.Daggerfall + 1 end

    if(searchTerm == "" 
      or string.find(string.lower(data.formattedZone), string.lower(searchTerm), 1) 
      or string.find(string.lower(data.note), string.lower(searchTerm), 1) 
      or string.find(string.lower(data.AllianceName), string.lower(searchTerm), 1) 
      or string.find(data.level, searchTerm) 
      or GUILD_ROSTER_MANAGER:IsMatch(searchTerm, data)) then
      
      local guildId = GUILD_SELECTOR.guildId
      local guildName = GetGuildName(guildId)
      
      if shissuHistoryScanner[guildName] ~= nil then
        if shissuHistoryScanner[guildName][data.displayName] ~= nil then
          if shissuHistoryScanner[guildName][data.displayName][zos["GoldAdded"]] ~= nil then
            goldDeposit = shissuHistoryScanner[guildName][data.displayName][zos["GoldAdded"]].total                                
          end
        end
      end 
      
      if goldDeposit >= _filter.gold then
        if _filter.rang == "" or _filter.rang == ( " - " .. _L("ALL") )
        or _filter.rang == GetFinalGuildRankName(guildId, data.rankIndex) then 
          if (_filter.Aldmeri == true and data.alliance == 1) or (_filter.Ebonheart == true and data.alliance == 2) or (_filter.Daggerfall == true and data.alliance == 3) or data.alliance == 0 then                                               
            if _filter.Online and (data.status ==1 or data.status ==2 or data.status ==3) then
              GuildInfo.Choice = GuildInfo.Choice +1
              table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
            elseif _filter.Offline and PlayerTime >= _filter.offlineSince then 
              table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
              GuildInfo.Choice = GuildInfo.Choice +1
            end
          end
        end      
      end   
    end
  end                                        
  
  _roster.setRank(_roster.rank)
  
  -- Anzeige der prozentuallen Verteilungen
  local Proc = {
    Aldmeri = round (GuildInfo.Aldmeri / GuildInfo.Max *100),
    Ebonheart = round(GuildInfo.Ebonheart / GuildInfo.Max *100),
    Daggerfall = round (GuildInfo.Daggerfall / GuildInfo.Max *100),
    Choice = round (GuildInfo.Choice / GuildInfo.Max *100),
  }
  
  SGT_Roster_AldmeriInGuild:SetText( white .. Proc.Aldmeri .. stdColor .. "%" )
  SGT_Roster_EbonheartInGuild:SetText(white .. Proc.Ebonheart .. stdColor .. "%"  )
  SGT_Roster_DaggerfallInGuild:SetText( white .. Proc.Daggerfall .. stdColor .. "%"  )
  SGT_Roster_Choice:SetText (white .. _L("CHOICE") .. ": " .. stdColor .. GuildInfo.Choice .. "/" .. white .. GuildInfo.Max .. white .. " (" .. stdColor .. Proc.Choice .. white .. "%)")
  
  _roster.GoldDeposit:SetText(white .. _L("SUM") .. ": " .. stdColor .. _roster.getTotalGold())
end
   
function _roster.setRank(control)
  local guildId = GUILD_SELECTOR.guildId
  
  if control ~= nil then 
    control:ClearItems()
    control:AddItem(_roster.rank:CreateItemEntry(stdColor .. "-- " .. white .. _L("ALL"), _roster.selectRank))
    
    for rankIndex = 1, GetNumGuildRanks(guildId) do
      control:AddItem(control:CreateItemEntry(GetFinalGuildRankName(guildId, rankIndex), _roster.selectRank))
    end
    
    control:SetSelectedItem(_filter.rang)
    
    if (_filter.rang == "") then
      control:SetSelectedItem(stdColor .. "-- " .. white .. _L("ALL"))
    end
  end
end

function _roster.selectRank(_, statusText)
  _filter.rang = statusText
  
  if (statusText == (stdColor .. "-- " .. white .. _L("ALL"))) then
    _filter.rang = ""
  end
  
  _roster.refreshFilters()
end
   
function _roster.selectGold(_, statusText)
  shissuRoster["gold"] = statusText
  _roster.refreshFilters()
  _roster.GoldDeposit:SetText(white .. _L("SUM") .. ": " .. stdColor .. _roster.getTotalGold())
end
                           
function _addon.buildTooltip(guildName, displayName, tooltip, eventType, titleText)
  local gold = "|t24:24:EsoUI/Art/Guild/guild_tradinghouseaccess.dds|t"
  local timeStamp = GetTimeStamp()
  
  local historyData = _addon.getHistoryData(guildName, displayName, eventType)
      
  local timeLast = historyData[2]
  local lastGold = historyData[3]
  local totalGold = historyData[4]
  local currentNPC = historyData[5]
  local previousNPC = historyData[6]     

  if lastGold ~= 0 or totalGold ~= 0 or currentNPC ~= 0 or previousNPC ~= 0 then       
    if (tooltip ~= stdColor .. displayName .. white .. "\n") then
      tooltip = tooltip .. "\n\n" .. titleText ..  white
    else
      tooltip = tooltip .. "\n" .. titleText .. white
    end
  end  
    
  if currentNPC ~= 0 then  
    tooltip = tooltip .. "\n" .. _L("THISWEEK") .. ": " .. currentNPC .. gold
  end
            
  if previousNPC ~= 0 then  
    tooltip = tooltip .. "\n"  .. _L("LASTWEEK") .. ": " .. previousNPC .. gold 
  end
             
  if lastGold ~= 0 then  
    tooltip = tooltip .. "\n" .. _L("LAST") .. ": " .. lastGold .. gold
              .. " (" .. _L("BEFORE") .. " " .. _addon.secsToTime(timeStamp - timeLast) .. ")" .. "[" .. GetDateStringFromTimestamp(timeLast) .. "]"
  end
            
  if shissuHistoryScanner[guildName] ~= nil then
  --  if shissuHistoryScanner[guildName]["oldestEvent"] ~= nil then
      if totalGold ~= 0 then    
        tooltip = tooltip .. "\n" .. _L("TOTAL") .. ": " .. totalGold .. gold
     --   .. " (in " .. _addon.secsToTime(timeStamp - shissuHistoryScanner[guildName]["oldestEvent"][GUILD_HISTORY_BANK]) .. ")"    
      end
   -- end
  end
    
  return tooltip
end                       

function _addon.currentTime()
  local correction = GetSecondsSinceMidnight() - (GetTimeStamp() % 86400)
  if correction < -12*60*60 then correction = correction + 86400 end

  return GetTimeStamp() + correction
end

function _addon.getDay()
  local hourSeconds = 60 * 60
  local daySeconds = 60 * 60 *24
  
  -- Erste Woche 1970 beginnt Donnerstag -> Verschiebung auf Gebotsende
  local firstWeek = 1 + (5 * daySeconds) + (14 * hourSeconds)

  local currentTime = _addon.currentTime()                                     

  -- Anzahl der Tage seit 01.01.1970
  local day = math.floor(currentTime / daySeconds)
                                 
  -- Beginn des Tages
  local restWeekTime = day * daySeconds

  return restWeekTime
end
        
function _roster.getTotalGold()
  local guildId = GUILD_SELECTOR.guildId
  if guildId == nil then return "" end
  
  local guildName = GetGuildName(guildId)

  local numMember = GetNumGuildMembers(guildId)
  local goldDeposit = 0
    
  for memberId = 1, numMember, 1 do
    local memberData = { GetGuildMemberInfo(guildId, memberId) }
    local displayName = memberData[1]            

    local historyData = _addon.getHistoryData(guildName, displayName, GUILD_EVENT_BANKGOLD_ADDED)
      
    local timeLast = historyData[2]
    local lastGold = historyData[3]
    local totalGold = historyData[4]
    local currentNPC = historyData[5]
    local previousNPC = historyData[6]    

    -- Heute
    if (shissuRoster["gold"] == _L("TODAY")) then           
      if ( timeLast > _addon.getDay()) then
        goldDeposit = goldDeposit + lastGold
      end
    -- Gestern
    elseif (shissuRoster["gold"] == _L("YESTERDAY")) then
      if ( timeLast > (_addon.getDay() - 86400) and timeLast < _addon.getDay()) then
        goldDeposit = goldDeposit + lastGold
      end
    -- Zuletzt            
    elseif (shissuRoster["gold"] == _L("LAST")) then
      goldDeposit = goldDeposit + lastGold
      -- seit Gildenhändler
    elseif (shissuRoster["gold"] == _L("SINCE")) then     
      goldDeposit = goldDeposit + currentNPC      
    -- Letzte Woche
    elseif (shissuRoster["gold"] == _L("LASTWEEK")) then
      goldDeposit = goldDeposit + previousNPC
    -- Gesamt     
    else
      goldDeposit = goldDeposit + totalGold
    end
  end
  
  goldDeposit = ZO_LocalizeDecimalNumber(goldDeposit or 0)
  
  return goldDeposit
end
                   
function _addon.getCharInfoIcon(charInfoVar, text, class)
  if charInfoVar then
    local icon = nil
    
    if class then icon = GetClassIcon(charInfoVar)
    else icon = GetAllianceBannerIcon(charInfoVar) end
    
    if icon then return "|t28:28:" .. icon .. "|t" .. text end
  end
  
  return text
end    
    
function _addon.newCharName(charName, charInfo)
  charName = charName .. white .. " (".. stdColor .. "LvL " .. white .. charInfo.lvl .. ")"
  charName = _addon.getCharInfoIcon(charInfo.class, charName, true)
  charName = _addon.getCharInfoIcon(charInfo.alliance, charName)
 
  return charName 
end

function _addon.createZOButton(name, text, width, offsetX, offsetY, anchor, control)
  local button = CreateControlFromVirtual(name, anchor, "ZO_DefaultTextButton")
  local editbox = ZO_EditNoteDialogNoteEdit
  local buttonlabel = "SGT_GuildColor_Note"

  button:SetText(text)
  button:SetAnchor(TOPLEFT, anchor, TOPLEFT, offsetX, offsetY)
  button:SetWidth(width)
  
  button:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
  button:SetHandler("OnMouseEnter", function() 
    local colorString =  string.gsub(button:GetName(), buttonlabel, "") 
    
    if not colorString == "ANY" then
      ZO_Tooltips_ShowTextTooltip(button, TOPRIGHT,  _addon["userColor" .. colorString] .. _L("YOURTEXT") .. "|r")
    end
  end)
  
  local htmlString
  
  local function ColorPickerCallback(r, g, b, a)
    htmlString = RGBtoHex(r,g,b)                         
  end    
  
  local ZOS_BUTTON = ESO_Dialogs.COLOR_PICKER["buttons"][1].callback
    
  button:SetHandler("OnClicked", function()        
    local colorString =  string.gsub(button:GetName(), buttonlabel, "") 
    local cache = editbox:GetText()
  
    editbox:SetText(cache .. _addon["userColor" .. colorString] .. _L("YOURTEXT") .. "|r") 
  end)
  
  return button
end                 

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function _addon.rosterUI()
  if ( shissuGT ~= nil ) then
    if ( shissuGT["MemberChars"] ~= nil ) then
      shissuRoster["MemberChars"] = deepcopy(shissuGT["MemberChars"])
      shissuGT["MemberChars"] = nil
    end
    
    if ( shissuGT["PersonalNote"] ~= nil ) then
      shissuRoster["PersonalNote"] = deepcopy(shissuGT["PersonalNote"])
      shissuGT["PersonalNote"] = nil
    end    
  end
                           
  _personalNote = shissuRoster["PersonalNote"] or {}  
  _memberChars  = shissuRoster["MemberChars"] or {}   
  
  shissuHistoryScanner = shissuHistoryScanner or {}
 
  -- Fenster formatieren & Objekte erstellen
  local SearchLabel = stdColor .. ZO_GuildRosterSearchLabel:GetText()  
  ZO_GuildRosterSearchLabel:SetText(SearchLabel)  
  ZO_GuildRosterSearch:SetWidth(200)  
  
  _addon.anchorSet(55,-320,7)

  GUILD_ROSTER_KEYBOARD.FilterScrollList = _roster.filterScrollList

  -- Allianzen
  _roster.AllianceLabel = createZOButton("SGT_Roster_AllianceLabel", stdColor .. _L("ALLIANCE"), 150, 180, -2 , ZO_GuildRosterSearchLabel)                                                                          
  _roster.Aldmeri = _addon.createButton("SGT_Roster_Aldmeri","Aldmeri", 50, 30, SGT_Roster_AllianceLabel)  
  _roster.AldmeriInGuild = createZOButton("SGT_Roster_AldmeriInGuild", "", 50, 35, -5, SGT_Roster_Aldmeri)  
  
  _roster.Ebonheart = _addon.createButton("SGT_Roster_Ebonheart","Ebonheart", 90, 0, SGT_Roster_Aldmeri)
  _roster.EbonheartInGuild = createZOButton("SGT_Roster_EbonheartInGuild", "", 50, 35, -5, SGT_Roster_Ebonheart)
  _roster.Daggerfall = _addon.createButton("SGT_Roster_Daggerfall","Daggerfall", 90, 0, SGT_Roster_Ebonheart)  
  _roster.DaggerfallInGuild = createZOButton("SGT_Roster_DaggerfallInGuild", "", 50, 35, -5, SGT_Roster_Daggerfall)

  -- Info Status Label  
  _roster.StatusLabel = createZOButton("SGT_Roster_StatusLabel","Status:", 100, -380 , 50, ZO_GuildRosterSearchLabel)
  _roster.Online = _addon.createButton("SGT_Roster_Online","Online", 100, 5, SGT_Roster_StatusLabel)                        
  _roster.Offline = _addon.createButton("SGT_Roster_Offline","Offline", 50, 0, SGT_Roster_Online) 
  
  -- Button Offline seit...
  _roster.OfflineSince = createZOButton("SGT_Roster_OfflineSince", stdColor .. _L("OFFLINE") .. ": ".. white .. "0 " .. _L("DAYS"), 200, 20, -5, SGT_Roster_Offline)
  _roster.OfflineSince:SetHandler("OnMouseUp", function(self, button) 
    _addon.offlineFilter()
  end)

  _roster.Choice = createZOButton("SGT_Roster_Choice","", 200, 290, 50, ZO_GuildRosterSearchLabel)
  
  -- Rang
  _roster.RankLabel = _addon.createLabel("SGT_Roster_RankLabel", ZO_GuildRoster, _L("RANK") .. ":", {50,30},  {50, -5}, false, BOTTOMLEFT)
  _roster.Rank = WINDOW_MANAGER:CreateControlFromVirtual("SGT_Roster_Rank", SGT_Roster_RankLabel, "ZO_ComboBox")
  _roster.Rank:SetAnchor(RIGHT, SGT_Roster_RankLabel, RIGHT, 150, -5)
  _roster.Rank:SetHidden(false)
  _roster.Rank:SetWidth(140) 
  _roster.Rank.dropdown = ZO_ComboBox_ObjectFromContainer(_roster.Rank)

  _roster.rank = _roster.Rank.dropdown
  _roster.rank:SetSortsItems(false) 
  _roster.setRank(_roster.rank)

  _roster.rank:SetSelectedItem(stdColor .. "-- " .. white .. _L("ALL"))

  -- Zenimax Offline Filter ausblenden
  ZO_GuildRosterHideOffline:SetHidden(true)

  -- Einzahlungen
  _roster.goldLabel = _addon.createLabel("SGT_Roster_GoldLabel", SGT_Roster_RankLabel, _L("DEPOSIT2") .. ":", {110, 30},  {-67, 15}, false, BOTTOMLEFT)

  _roster.Gold = WINDOW_MANAGER:CreateControlFromVirtual("SGT_Roster_Gold", SGT_Roster_GoldLabel, "ZO_ComboBox")
  _roster.Gold:SetAnchor(RIGHT, SGT_Roster_GoldLabel, RIGHT, 158, 0)
  _roster.Gold:SetHidden(true)
  _roster.Gold:SetWidth(140)  
  _roster.Gold.dropdown = ZO_ComboBox_ObjectFromContainer(_roster.Gold)
  
  _roster.gold = _roster.Gold.dropdown
  _roster.gold:SetSortsItems(false) 

  _roster.gold:AddItem(_roster.gold:CreateItemEntry(_L("LAST"), _roster.selectGold))
  _roster.gold:AddItem(_roster.gold:CreateItemEntry(_L("TODAY"), _roster.selectGold))
  _roster.gold:AddItem(_roster.gold:CreateItemEntry(_L("YESTERDAY"), _roster.selectGold))
  _roster.gold:AddItem(_roster.gold:CreateItemEntry(_L("SINCE"), _roster.selectGold)) 
  _roster.gold:AddItem(_roster.gold:CreateItemEntry(_L("LASTWEEK"), _roster.selectGold)) 
  _roster.gold:AddItem(_roster.gold:CreateItemEntry(_L("TOTAL"), _roster.selectGold))
    
  _roster.gold:SetSelectedItem(shissuRoster["gold"])
  
  -- Gold Deposit
  _roster.GoldDeposit = CreateControlFromVirtual("SGT_Roster_GoldDeposit", SGT_Roster_Rank, "ZO_DefaultTextButton")
  _roster.GoldDeposit:SetText(white .. _L("DEPOSIT3") .. " " .. stdColor .. "")
  _roster.GoldDeposit:SetAnchor(LEFT, SGT_Roster_Rank, LEFT, 150, 0)
  _roster.GoldDeposit:SetWidth(200) 
  
  _roster.GoldDeposit:SetHandler("OnMouseUp", function(self, button) 
    if button == 1 then
      _addon.goldFilter()
    else                                                    
      if _filter.goldDir == 0 then 
        _filter.goldDir = 1
        self:SetText(white .. _L("DEPOSIT3") .. " " .. stdColor .. " ")
      else 
        _filter.goldDir = 0 
        self:SetText(white .. _L("DEPOSIT3") .. " " .. stdColor .. " ")
      end
      _roster.refreshFilters() 
    end
  end)
  
  _roster.GoldDeposit = CreateControlFromVirtual("SGT_Roster_GoldTotal", SGT_Roster_Gold, "ZO_DefaultTextButton")
  _roster.GoldDeposit:SetText(white .. _L("SUM") .. " " .. stdColor .. "0")
  _roster.GoldDeposit:SetAnchor(LEFT, SGT_Roster_Gold, LEFT, 150, 0)
  _roster.GoldDeposit:SetWidth(200)
  _roster.GoldDeposit:SetText(white .. _L("SUM") .. " " .. stdColor .. _roster.getTotalGold())

  local CL = _addon.createZOButton
  ZO_EditNoteDialogNote:SetAnchor (3, ZO_EditNoteDialogDisplayName, 3, 0, 60)
  _addon.buttons.NoteStandard1 = CL("SGT_GuildColor_Note1", white .. "[ " .. _addon.userColor1 .. "1" .. white .. " ]", 50, 60, 30, ZO_EditNoteDialogDisplayName, 1)
  _addon.buttons.NoteStandard2 = CL("SGT_GuildColor_Note2", white .. "[ " .. _addon.userColor2 .. "2" .. white .. " ]", 50, 40, 0, SGT_GuildColor_Note1, 1)
  _addon.buttons.NoteStandard3 = CL("SGT_GuildColor_Note3", white .. "[ " .. _addon.userColor3 .. "3" .. white .. " ]", 50, 40, 0, SGT_GuildColor_Note2, 1)
  _addon.buttons.NoteStandard4 = CL("SGT_GuildColor_Note4", white .. "[ " .. _addon.userColor4 .. "4" .. white .. " ]", 50, 40, 0, SGT_GuildColor_Note3, 1)
  _addon.buttons.NoteStandard5 = CL("SGT_GuildColor_Note5", white .. "[ " .. _addon.userColor5 .. "5" .. white .. " ]", 50, 40, 0, SGT_GuildColor_Note4, 1) 
  _addon.buttons.NoteStandardW = CL("SGT_GuildColor_NoteW", white .. "[ " .. white .. "W" .. white .. " ]", 50, 40, 0, SGT_GuildColor_Note5, 1) 
end
            
function _roster.refreshFilters()
  GUILD_ROSTER_MANAGER:RefreshData()
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)
  org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)

  local parent = control:GetParent()
  local data = ZO_ScrollList_GetData(parent)
  local guildName = GetGuildName(GUILD_SELECTOR.guildId)
  local displayName = data.displayName
  local timeStamp = GetTimeStamp()

  local tooltip = data.characterName
  
  -- Mitglied seit?
  if (shissuHistoryScanner[guildName] == nil) then
    -- Account taucht nicht in der Gildenaufzeichnung auf
    tooltip = tooltip .. "\n\n"
    tooltip = tooltip .. _L("MEMBER")
          
    if (shissuHistoryScanner[guildName][displayName] == nil) then
      if (shissuHistoryScanner[guildName]["oldestEvent"] ~= nil) then
        tooltip = tooltip .. " > " .. stdColor .. _addon.secsToTime(timeStamp - shissuHistoryScanner[guildName]["oldestEvent"][GUILD_HISTORY_GENERAL])
      end
    else
      if (shissuHistoryScanner[guildName][displayName].timeJoined ~= nil) then
        local timeData = shissuHistoryScanner[guildName][displayName].timeJoined
        tooltip = tooltip .. " " .. stdColor .. _addon.secsToTime(timeStamp - timeData) .. white .. " (" .. GetDateStringFromTimestamp(timeData) .. ")"
      else
        if (shissuHistoryScanner[guildName]["oldestEvent"] ~= nil) then
          tooltip = tooltip .. " > " .. stdColor .. _addon.secsToTime(timeStamp - shissuHistoryScanner[guildName]["oldestEvent"][GUILD_HISTORY_GENERAL])
        end
      end
    end
  end
      
  InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOPCENTER)
  SetTooltipText(InformationTooltip, tooltip)
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
  ClearTooltip(InformationTooltip)
  org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
end
 
function _addon.standardZO()
  _addon.originalRosterBuildMasterList = GUILD_ROSTER_MANAGER.BuildMasterList
  GUILD_ROSTER_MANAGER.BuildMasterList = SGT_GuildRosterManager.BuildMasterList
end
 
-- NEW ROSTER
function _addon:InitRosterChanges()   
  GUILD_ROSTER_ENTRY_SORT_KEYS["character"] = { tiebreaker = 'displayName' }
  GUILD_ROSTER_ENTRY_SORT_KEYS["goldDeposit"] = { tiebreaker = 'displayName' }

  local additionalWidth = 0

  if (MasterMerchant) then
    local MM_Save = MasterMerchant:ActiveSettings().diplayGuildInfo
    
    if MM_Save == true then
      _addon.originalRosterBuildMasterList = GUILD_ROSTER_KEYBOARD.BuildMasterList
      GUILD_ROSTER_KEYBOARD.BuildMasterList = SGT_GuildRosterManager.BuildMasterList
    else
      _addon.standardZO()
    end
  else
    _addon.standardZO()
  end

  --_addon.originalRosterBuildMasterList = GUILD_ROSTER_MANAGER.BuildMasterList
  --GUILD_ROSTER_MANAGER.BuildMasterList = SGT_GuildRosterManager.BuildMasterList
  
  local headers = ZO_GuildRosterHeaders
  local zoneHeader = headers:GetNamedChild('Zone')
  
  if (shissuRoster["colGold"] or shissuRoster["colChar"] ) then                                 
    
    local headerDisplayName = headers:GetNamedChild('DisplayName') 
    zoneHeader:SetDimensions(220, 32)
    
    -- Spalte Charakter
    if shissuRoster["colChar"] then
      additionalWidth = additionalWidth + 100
      
      local control = headers:GetName() .. _L("CHAR")
      local characterHeader = CreateControlFromVirtual(control, headers, 'ZO_SortHeader')
      ZO_SortHeader_Initialize(characterHeader, _L("CHAR"), 'character', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_LEFT, 'ZoFontGameLargeBold')
                
      characterHeader:SetAnchor(TOPLEFT, headerDisplayName, TOPRIGHT, 0, 0)   
      characterHeader:SetDimensions(200,32)
      characterHeader:SetHidden(false)
      
      GUILD_ROSTER_KEYBOARD.sortHeaderGroup:AddHeader(characterHeader)
      
      -- Spalte Zone                                                                                                                                             
      zoneHeader:ClearAnchors()
      zoneHeader:SetAnchor(TOPLEFT, characterHeader, TOPRIGHT, 0, 0)  
    end

    -- Spalte Einzahlungen
    if shissuRoster["colGold"] then  
      additionalWidth = additionalWidth + 10
      
      if shissuRoster["colChar"] then
        additionalWidth = additionalWidth + 80
      end
      
      controlName = headers:GetName() .. _L("DEPOSIT")
      local goldDepositHeader = CreateControlFromVirtual(controlName, headers, 'ZO_SortHeader')
      ZO_SortHeader_Initialize(goldDepositHeader, _L("DEPOSIT") .. " ", 'goldDeposit', ZO_SORT_ORDER_DOWN, TEXT_ALIGN_CENTER, 'ZoFontGameLargeBold')     

      goldDepositHeader:SetAnchor(TOPLEFT, zoneHeader, TOPRIGHT, 0, 0)
      goldDepositHeader:SetDimensions(120, 32)
      goldDepositHeader:SetHidden(false)  
      
      GUILD_ROSTER_KEYBOARD.sortHeaderGroup:AddHeader(goldDepositHeader)
    
      -- Spalte Klasse
      controlName = headers:GetNamedChild('Class')
      controlName:ClearAnchors()
      controlName:SetAnchor(TOPLEFT, goldDepositHeader, TOPRIGHT, 0, 0)
    end
    
    local origWidth = ZO_GuildRoster:GetWidth()
    ZO_GuildRoster:SetWidth(origWidth + additionalWidth)   
  else
    zoneHeader:SetDimensions(300, 32)
  end  
     
  -- Aktualisieren
  GUILD_ROSTER_MANAGER:RefreshData()  
end                                                     
                                                      

local GUILD_ROSTER_MANAGER_SetupEntry = GUILD_ROSTER_MANAGER.SetupEntry

function GUILD_ROSTER_MANAGER:SetupEntry(control, data, selected)
  GUILD_ROSTER_MANAGER_SetupEntry(self, control, data, selected)
 
  local rowZone = control:GetNamedChild('Zone')
  local rowDisplayName = control:GetNamedChild("DisplayName")
  local class = control:GetNamedChild('ClassIcon')   
  
  -- Spalte Einzahlung
  if shissuRoster["colGold"] then
    local goldDeposit = control:GetNamedChild(_L("DEPOSIT"))
    if(not goldDeposit) then
      controlName = control:GetName() .. _L("DEPOSIT")
      goldDeposit = control:CreateControl(controlName, CT_LABEL)
      goldDeposit:SetAnchor(LEFT, rowZone, RIGHT, 10, 0)
      goldDeposit:SetFont('ZoFontGame')
      goldDeposit:SetWidth(105)
      goldDeposit:SetHidden(false)    
      goldDeposit:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)    
    end  
       
    goldDeposit:SetText(ZO_LocalizeDecimalNumber(data.goldDeposit or 0) .. " |t16:16:/esoui/art/guild/guild_tradinghouseaccess.dds|t")
                                                      
    if (data.goldDepositTT) then
      goldDeposit:SetMouseEnabled(true);
      goldDeposit:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, data.goldDepositTT) end)
    end         

    class:ClearAnchors() 
    class:SetAnchor(TOPLEFT, goldDeposit, TOPRIGHT, 8)   
  else
    local goldDeposit = control:GetNamedChild(_L("DEPOSIT"))
    if (goldDeposit) then
      goldDeposit:SetHidden(true)
      class:ClearAnchors() 
      class:SetAnchor(TOPLEFT, rowZone, TOPRIGHT, 8)   
    end  
  end

  if (shissuRoster["colChar"]) then
    local character = control:GetNamedChild(_L("CHAR"))
    if(not character) then
      local controlName = control:GetName() .. _L("CHAR")
    	character = control:CreateControl(controlName, CT_LABEL)
    	character:SetAnchor(LEFT, rowDisplayName, RIGHT, 0, 0)
    	character:SetFont('ZoFontGame')
      character:SetWidth(195)
      character:SetHidden(false)    
    end  

    local characterName = data.characterName
      
    if string.len(data.characterName) > 28 then
      characterName = string.sub(data.characterName, 0, 28) .. "..." 
    end 

    if (data.online) then
      character:SetText(characterName)
    else
      characterName = string.gsub(characterName, "|ceeeeee", "")
      character:SetText("|cadadad" .. characterName) 
    end
          
    if data.characterNameTT then 
      character:SetMouseEnabled(true);
      character:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, data.characterNameTT) end)
      character:SetHandler("OnMouseExit", function (self) ZO_Tooltips_HideTextTooltip() end)
    end
      
    -- Spalte Zone
    rowZone:ClearAnchors() 
    rowZone:SetAnchor(TOPLEFT, character, TOPRIGHT, 8)   
  else
    local character = control:GetNamedChild(_L("CHAR"))
    if (character) then
      character:SetHidden(true)
      rowZone:ClearAnchors() 
      rowZone:SetAnchor(TOPLEFT, rowDisplayName, TOPRIGHT, 8)   
    end
  end
  
  if shissuRoster["colGold"] or shissuRoster["colChar"] then
    rowZone:SetWidth(210)
  else
    rowZone:SetWidth(320)
  end

  -- Spalte Persönliche Notizen  
  if shissuRoster["colNote"] then                                                                      
    local rowNote = control:GetNamedChild('Note')
    local persNote = control:GetNamedChild('[N]')
      
    if(not persNote) then
      controlName = control:GetName() .. '[N]'
    	persNote = control:CreateControl(controlName, CT_LABEL)
    	persNote:SetAnchor(LEFT, rowNote, LEFT, -15, 0)
      persNote:SetFont('ZoFontGame')
      persNote:SetWidth(40)
      persNote:SetHorizontalAlignment(TEXT_ALIGN_LEFT)    
     end   
      
    if data.sgtNote then 
      persNote:SetMouseEnabled(true);
      persNote:SetHandler("OnMouseEnter", function (self) ZO_Tooltips_ShowTextTooltip(self, TOP, data.sgtNote) end)
      persNote:SetHandler("OnMouseExit", function (self) ZO_Tooltips_HideTextTooltip() end) --org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(self) end) 
      persNote:SetText("|t32:32:/ShissuFramework/textures/notes.dds|t")
      persNote:SetHidden(false)   
    else
      persNote:SetHidden(true)    
    end
  end
end                 

SGT_GuildRosterManager = {} 

function _addon.getHistoryData(guildName, displayName, eventType)
  local timeFirst = 0  
  local timeLast = 0                        
  local total = 0
  local last = 0 
  local currentNPC = 0
  local previousNPC = 0
  
  if shissuHistoryScanner[guildName] then                        
    if shissuHistoryScanner[guildName][displayName] then
      if shissuHistoryScanner[guildName][displayName][eventType] then
        timeFirst = shissuHistoryScanner[guildName][displayName][eventType].timeFirst or 0
        timeLast = shissuHistoryScanner[guildName][displayName][eventType].timeLast or 0                        
        total = shissuHistoryScanner[guildName][displayName][eventType].total or 0
        last = shissuHistoryScanner[guildName][displayName][eventType].last or 0
        currentNPC = shissuHistoryScanner[guildName][displayName][eventType].currentNPC or 0
        previousNPC = shissuHistoryScanner[guildName][displayName][eventType].previousNPC or 0
      end
    end
  end

  return {timeFirst, timeLast, last, total, currentNPC, previousNPC}
end

function SGT_GuildRosterManager:BuildMasterList() 
  --MM Bypass
  if not (self.masterList) then
    self.masterList = GUILD_ROSTER_MANAGER:GetMasterList()
  end

  _addon.originalRosterBuildMasterList(self)
  
  local guildId = GUILD_ROSTER_MANAGER.guildId
  --guildId = GetGuildId(guildId)
      
  for i = 1, #self.masterList do
    local data = self.masterList[i]
    local displayName = data.displayName
    local memberChars = _memberChars[displayName]

    local characterName = data.characterName 
    local characterName2 = string.gsub(characterName, "|ceeeeee", "")

    -- Charaktername Tooltip  
    if shissuRoster["colChar"] then
      if memberChars then
        local firstChar = 1
        local newCharacterNameTT = ""
        
        for charName, charInfo in pairs(memberChars) do       
          if (characterName2) then 
            if ( characterName2 == charName ) then
              charName = green .. charName
            end
          end
        
          if firstChar == 1 then
            newCharacterNameTT = _addon.newCharName(charName, charInfo)
            firstChar = 0
          else
            if (not string.find(newCharacterNameTT, _addon.newCharName(charName, charInfo))) then  
              newCharacterNameTT = newCharacterNameTT .. "\n" .. _addon.newCharName(charName, charInfo)
            end  
          end                      
                                                
        end
        
        data.characterNameTT = stdColor .. displayName .. white .. "\n\n" .. newCharacterNameTT
      end  
    end
    
    -- Spalte: Gold Einzahlung
    local guildName = GetGuildName(guildId)
    local goldDeposit = 0
    local goldTooltip = ""

    -- ID EXISTIERT
    -- GILDENNAME EXISTIERT

    if shissuRoster["colGold"] then
      local historyData = _addon.getHistoryData(guildName, displayName, GUILD_EVENT_BANKGOLD_ADDED)
      
      local timeLast = historyData[2]
      local lastGold = historyData[3]
      local totalGold = historyData[4]
      local currentNPC = historyData[5]
      local previousNPC = historyData[6]   
      
      --d(currentNPC)

      -- Heute
      if (shissuRoster["gold"] == _L("TODAY")) then  
        if ( timeLast > _addon.getDay()) then
          goldDeposit = lastGold
        end
      -- Gestern
      elseif (shissuRoster["gold"] == _L("YESTERDAY")) then
        if (timeLast > (_addon.getDay() - 86400) and timeLast < _addon.getDay()) then
          goldDeposit = lastGold
        end   
      -- Zuletzt            
      elseif (shissuRoster["gold"] == _L("LAST")) then
        goldDeposit = lastGold
      -- seit Gildenhändler
      elseif (shissuRoster["gold"] == _L("SINCE")) then     
        goldDeposit = currentNPC    
      -- Letzte Woche
      elseif (shissuRoster["gold"] == _L("LASTWEEK")) then
        goldDeposit = previousNPC 
      -- Gesamt     
      else
        goldDeposit = totalGold      
      end
            
      goldTooltip = stdColor .. displayName .. white .. "\n"      
      goldTooltip = _addon.buildTooltip(guildName, displayName, goldTooltip, GUILD_EVENT_BANKGOLD_ADDED, green .. "Gold " .. _L("GOLDADD"))
      goldTooltip = _addon.buildTooltip(guildName, displayName, goldTooltip, GUILD_EVENT_BANKGOLD_REMOVED, red .. "Gold " .. _L("GOLDREMOVE"))
      goldTooltip = _addon.buildTooltip(guildName, displayName, goldTooltip, GUILD_EVENT_BANKITEM_ADDED, green .. "Item " .. _L("ITEMADD"))
      goldTooltip = _addon.buildTooltip(guildName, displayName, goldTooltip, GUILD_EVENT_BANKITEM_REMOVED, red .. "Item " .. _L("ITEMREMOVE"))
        
      if(goldTooltip == stdColor .. displayName .. white .. "\n") then
        goldTooltip = stdColor .. displayName .. "\n" .. white .. _L("NODATA")  
      end

      data.goldDeposit = goldDeposit
      data.goldDepositTT = goldTooltip
    end
    
    -- Spalte: Persönliche Notizen  
    if (shissuRoster["colNote"]) then  
      if _personalNote then
        if _personalNote[guildId] then
          if _personalNote[guildId][displayName] then       
            if (string.len(_personalNote[guildId][displayName])) > 1 then
              data.sgtNote = _personalNote[guildId][displayName]
            else
              _personalNote[guildId][displayName] = nil
            end
          end
        end
      end  
    end  
    
    -- Spalte: Zone -> Offline seit?
    if data.status == 4 and data.alliance ~= 0 then
      data.formattedZone = _addon.secsToTime(data.secsSinceLogoff) .. "\n\n" .. data.formattedZone
    end
      
  end 
end

local function RGBtoHex(r,g,b)
  local rgb = {r*255, g*255, b*255}
  local hexstring = ""

  for key, value in pairs(rgb) do
    local hex = ""

    while (value > 0)do
      local index = math.fmod(value, 16) + 1
      value = math.floor(value / 16)
      hex = string.sub("0123456789ABCDEF", index, index) .. hex     
    end

    if(string.len(hex) == 0) then
      hex = "00"
    elseif(string.len(hex) == 1) then
      hex = "0" .. hex
    end

    hexstring = hexstring .. hex
  end

  return hexstring
end


-- * Initialisierung
function _addon.initialized()
  --d(_addon.formattedName .. " " .. _addon.Version)
  
  if (shissuColor ~= nil) then
    for i = 1, 5 do
      if (shissuColor["c" .. i] ~= nil) then
        shissuRoster["c" .. i] = shissuColor["c" .. i]
      end
    end
    
    for number=1, 5 do
      if (shissuColor["c" .. number] ~= nil ) then
        _addon["userColor" .. number] = "|c" .. RGBtoHex(shissuColor["c" .. number][1], shissuColor["c" .. number][2], shissuColor["c" .. number][3])
      --d(_addon["userColor" .. number])
      end
    end
  end
  
  if (shissuRoster["colGold"] == nil) then shissuRoster["colGold"] = true end
  if (shissuRoster["colChar"] == nil) then shissuRoster["colChar"] = true end
  if (shissuRoster["colNote"] == nil) then shissuRoster["colNote"] = true end

  _addon.rosterUI()
  _addon:InitRosterChanges() 
  _addon.createSettingMenu()
end                               

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end

  shissuRoster = shissuRoster or _addon.settings
  
  -- KOPIE / Leeren alter SGT Var
  shissuRoster = shissuRoster or {}
  --if ( shissuGT ~= nil ) then
  --  if ( shissuGT["ShissuRoster"] ~= nil ) then
  --    shissuRoster = deepcopy(shissuGT["ShissuRoster"])
   --   shissuGT["ShissuRoster"] = nil
   -- end
  --end
  
  --if shissuRoster == {} then
  --  shissuRoster = _addon.settings 
 -- end 
  
  --_addon.settings = shissuRoster
  -- KOPIE / Leeren alter SGT Var  

  zo_callLater(function()               
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)