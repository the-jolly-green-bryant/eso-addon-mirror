-- Shissu Guild Tools Addon
-- ShissuHistory
--
-- Version: v1.5.0
-- Last Update: 24.05.2019
-- Written by Christian Flory (@Shissu) - esoui@flory.one
-- Distribution without license is prohibited!
  
-- *** GLOBALS, VARS
--------------------  
local _globals = ShissuFramework["globals"]
local stdColor = _globals["stdColor"]
local white = _globals["white"]
local red = _globals["red"]
local green = _globals["green"]
local yellow = _globals["yellow"]
local orange = _globals["orange"]
local whiteGold = _globals["goldSymbol"]      

local setPanel = ShissuFramework["setPanel"]

local round = ShissuFramework["func"].round
local currentTimeC = ShissuFramework["func"].currentTime
local getKioskTime = ShissuFramework["func"].getKioskTime
local isStringEmpty = ShissuFramework["func"].isStringEmpty
local checkBoxLabel = ShissuFramework["interface"].checkBoxLabel
local createLabel = ShissuFramework["interface"].createLabel
local createZOButton = ShissuFramework["interface"].createZOButton

local SetupGuildEvent_Orig = GUILD_HISTORY.SetupGuildEvent
                                        
local _addon = {}
_addon.Name	= "ShissuHistory"
_addon.Version = "1.5.0"
_addon.formattedName = stdColor .. "Shissu" .. white .. "'s History"
 
local _cache = {}           
local _ui = {}

local _L = ShissuFramework["func"]._L(_addon.Name)

_addon.panel = setPanel(_L("TITLE"), _addon.formattedName, _addon.Version)
_addon.controls = {}

_addon.settings = {
  ["sales"] = true,
  ["bank"] = true,
}

function _addon.createSettingMenu()
  local controls = ShissuFramework._settings[_addon.Name].controls

  controls[#controls+1] = {
    type = "title",
    name = _L("INFO"),
  }
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("SET1"),
    getFunc = shissuHistory["bank"],
    setFunc = function(_, value)
      shissuHistory["bank"] = value 
    end,
  }   
  controls[#controls+1] = {
    type = "checkbox",
    name = _L("SET2"),
    getFunc = shissuHistory["sales"],
    setFunc = function(_, value)
      shissuHistory["sales"] = value 
    end,
  } 
end


function _addon.createButton(name, var, offsetX, offsetY) 
  local button = CreateControlFromVirtual(name, ZO_GuildHistory, "ZO_CheckButton")
  button:SetAnchor(TOPLEFT, ZO_GuildHistory, TOPLEFT, offsetX, offsetY)
  
  checkBoxLabel(button, var)
  
  ZO_CheckButton_SetToggleFunction(button, function(control, checked)
    _cache[var] = checked
    _addon.refresh()
  end)

  return button
end

function _addon.createAccountLink(displayName, color)
  if displayName ~= nil and not string.find(displayName, "|H1") then
    return color .. string.format("|H1:display:%s|h%s|h", displayName, displayName)
  end

  return displayName
end

-- Original GuildHistoryManager:FilterScrollList(); guildhistory_keyboard.lua; last update: 06.10.2016
function _addon.filterScrollList(self)
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  local filterText = string.lower(_ui.searchBox:GetText())
  
  local filterCount = 0
  
  local guildId = GUILD_SELECTOR.guildId
  local guildName = GetGuildName(guildId)
  
  local goldAdded = 0
  local goldAddedCount = 0
  local goldRemoved = 0    
  local itemAdded = 0
  local itemRemoved = 0
  
  local salesInternCount = 0     
  local turnover = 0 
  local tax = 0     

  local currentTime = currentTimeC()
  local nextKiosk = currentTime + getKioskTime()
  local lastKiosk = nextKiosk - 604800
  local previousKiosk = lastKiosk - 604800
  
--  d("1: " .. GetDateStringFromTimestamp(lastKioskTime) .. " - " .. ZO_FormatTime((lastKioskTime) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR))
 -- d("2: " .. GetDateStringFromTimestamp(lastKioskTime2) .. " - " .. ZO_FormatTime((lastKioskTime2) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR))  
  
  local kioskCheckBox = false  
  local kioskCheckBox = ZO_CheckButton_IsChecked(_ui.optionKiosk) 
  
  local kioskCheckBox2 = false  
  local kioskCheckBox2 = ZO_CheckButton_IsChecked(_ui.optionKiosk2) 

  ZO_ClearNumericallyIndexedTable(scrollData)
        
  for i = 1, #self.masterList do
    local data = self.masterList[i]

    -- EINLADUNGEN HERVORHEBEN
    if ((data.eventType == GUILD_EVENT_GUILD_INVITE or data.eventType == GUILD_EVENT_GUILD_JOIN) and data.param2 ~= nil and data.param1 ~= nil) then
      data.param1 = _addon.createAccountLink(data.param1, green)
      data.param2 = _addon.createAccountLink(data.param2, green)
    end

    -- VERLASSEN
    if (data.eventType == GUILD_EVENT_GUILD_LEAVE and data.param1 ~= nil) then
      data.param1 = _addon.createAccountLink(data.param1, red)
    end

    -- GEKICKT
    if (data.eventType == GUILD_EVENT_GUILD_KICKED and data.param1 ~= nil and data.param2 ~= nil) then
      data.param1 = _addon.createAccountLink(data.param1, red)
      data.param2 = _addon.createAccountLink(data.param2, red)
    end

    -- BEFÖRDERN
    if (data.eventType == GUILD_EVENT_GUILD_PROMOTE and data.param1 ~= nil and data.param2 ~= nil and data.param3 ~= nil) then
      data.param1 = _addon.createAccountLink(data.param1, yellow)
      data.param2 = _addon.createAccountLink(data.param2, yellow)
      data.param3 = _addon.createAccountLink(data.param3, yellow)
    end

    -- DEGRADIEREN
    if (data.eventType == GUILD_EVENT_GUILD_DEMOTE and data.param1 ~= nil and data.param2 ~= nil and data.param3 ~= nil) then
      data.param1 = _addon.createAccountLink(data.param1, orange)
      data.param2 = _addon.createAccountLink(data.param2, orange)
      data.param3 = _addon.createAccountLink(data.param3, orange)
    end

    -- GOLD, GEGENSTAND eingelagert
    if ((data.eventType == GUILD_EVENT_BANKITEM_ADDED or data.eventType == GUILD_EVENT_BANKGOLD_ADDED) and data.param1 ~= nil) then
      data.param1 = _addon.createAccountLink(data.param1, green)
    end

    -- GOLD, GEGENSTAND entnommen
    if ((data.eventType == GUILD_EVENT_BANKITEM_REMOVED or data.eventType == GUILD_EVENT_BANKGOLD_REMOVED) and data.param1 ~= nil) then
      data.param1 = _addon.createAccountLink(data.param1, red)
    end

    if(self.selectedSubcategory == nil or self.selectedSubcategory == data.subcategoryId) then
      if (not isStringEmpty(data.param1) and string.find(string.lower(data.param1), filterText, 1)) or 
        (not isStringEmpty(data.param2) and string.find(string.lower(data.param2), filterText, 1)) or
        (not isStringEmpty(data.param3) and string.find(string.lower(data.param3), filterText, 1)) or
        (not isStringEmpty(data.description) and string.find(string.lower(data.description), filterText, 1)) or
        (not isStringEmpty(data.param4) and string.find(string.lower(data.param4), filterText, 1)) then      
      
        -- BANK: GOLD
        if (shissuHistory["bank"]) then
          if (not isStringEmpty(data.param2)) then
            if data.eventType == GUILD_EVENT_BANKGOLD_ADDED then 
            
              if kioskCheckBox then
                --d("1: " .. GetDateStringFromTimestamp(lastKioskTime) .. " - " .. ZO_FormatTime((lastKioskTime) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR))
                --d("2: " .. GetDateStringFromTimestamp(currentTime - data.secsSinceEvent) .. " - " .. ZO_FormatTime((lastKioskTime2) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR))  
                --d("--")
                
                if (currentTime - data.secsSinceEvent) >= lastKiosk then 
                  goldAdded = goldAdded + data.param2
                  goldAddedCount = goldAddedCount + 1
                end
              elseif kioskCheckBox2 then
                if (currentTime - data.secsSinceEvent >= previousKiosk and currentTime - data.secsSinceEvent <= lastKiosk) then 
                  goldAdded = goldAdded + data.param2
                  goldAddedCount = goldAddedCount + 1
                end            
              else
                goldAdded = goldAdded + data.param2
                goldAddedCount = goldAddedCount + 1
              end
            end
            
            if data.eventType == GUILD_EVENT_BANKGOLD_REMOVED then 
              if kioskCheckBox then
                if currentTime - data.secsSinceEvent >= lastKiosk then 
                  goldRemoved = goldRemoved + data.param2 
                end 
              elseif kioskCheckBox2 then
                if (currentTime - data.secsSinceEvent >= previousKiosk and currentTime - data.secsSinceEvent <= lastKiosk) then 
                  goldRemoved = goldRemoved + data.param2 
                end  
              else 
                goldRemoved = goldRemoved + data.param2 
              end      
            end
          end
                                                             
          -- BANK: ITEMS
          if (data.eventType == GUILD_EVENT_BANKITEM_ADDED) then
            if kioskCheckBox and currentTime - data.secsSinceEvent >= lastKiosk then 
              itemAdded = itemAdded + 1
            elseif kioskCheckBox2 then
              if (currentTime - data.secsSinceEvent >= previousKiosk and currentTime - data.secsSinceEvent <= lastKiosk) then
                itemAdded = itemAdded + 1     
              end        
            else 
              itemAdded = itemAdded + 1 
            end
          end       
 
          if (data.eventType == GUILD_EVENT_BANKITEM_REMOVED) then
            if kioskCheckBox and currentTime - data.secsSinceEvent >= lastKiosk then 
              itemRemoved = itemRemoved + 1
            elseif kioskCheckBox2 then
              if (currentTime - data.secsSinceEvent >= previousKiosk and currentTime - data.secsSinceEvent <= lastKiosk) then
                itemRemoved = itemRemoved + 1  
              end              
            else 
              itemRemoved = itemRemoved + 1 
            end
          end   
        end
        
        -- VERKAUF
        -- Accountname: data.param2, Steuern: data.param6, Gold durch Verkauf: data.param5    
        if (shissuHistory["sales"]) then
          if data.eventType == GUILD_EVENT_ITEM_SOLD then
            if (not isStringEmpty(data.param1)) then
              --d(data.param2)
              if _SGTguildMemberList[data.param2] ~= nil then
                local guilds = _SGTguildMemberList[data.param2]["guilds"]
  
                for i = 1, #guilds do
                  if (guilds[i][1] == guildName) then
                    if kioskCheckBox and currentTime - data.secsSinceEvent >= lastKiosk then 
                      salesInternCount = salesInternCount + 1 
                    elseif (currentTime - data.secsSinceEvent >= previousKiosk and currentTime - data.secsSinceEvent <= lastKiosk) then 
                      salesInternCount = salesInternCount + 1 
                    else 
                      salesInternCount = salesInternCount + 1 
                    end
                  end
  
                  break
                end
              end                                            
            end
                
            if kioskCheckBox then
              if (currentTime - data.secsSinceEvent >= lastKiosk) then
                if (not isStringEmpty(data.param5)) then turnover = turnover + data.param5 end
                if (not isStringEmpty(data.param6)) then tax = tax + data.param6 end
              end
            elseif kioskCheckBox2 then
              if (currentTime - data.secsSinceEvent >= previousKiosk and currentTime - data.secsSinceEvent <= lastKiosk) then
                if (not isStringEmpty(data.param5)) then turnover = turnover + data.param5 end
                if (not isStringEmpty(data.param6)) then tax = tax + data.param6 end
              end            
            else
              if (not isStringEmpty(data.param5)) then turnover = turnover + data.param5 end
              if (not isStringEmpty(data.param6)) then tax = tax + data.param6 end
            end            
          end  
        end
                    
        -- FILTER: BUTTONS
        if (_cache.Gold == false and (data.eventType == GUILD_EVENT_BANKGOLD_ADDED or
          data.eventType == GUILD_EVENT_BANKGOLD_ADDED or
          data.eventType == GUILD_EVENT_BANKGOLD_GUILD_STORE_TAX or
          data.eventType == GUILD_EVENT_BANKGOLD_KIOSK_BID or
          data.eventType == GUILD_EVENT_BANKGOLD_KIOSK_BID_REFUND or
          data.eventType == GUILD_EVENT_BANKGOLD_PURCHASE_HERALDRY or
          data.eventType == GUILD_EVENT_BANKGOLD_REMOVED)) then       
        elseif (_cache.Item == false and (data.eventType == GUILD_EVENT_BANKITEM_ADDED or
          data.eventType == GUILD_EVENT_BANKITEM_REMOVED)) then  
        else
          table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
          --table.insert(scrollData, ZO_ScrollList_CreateDataEntry(GUILD_EVENT_DATA, data))
          filterCount = filterCount + 1  
        end         
      end
    end
  end
  
  _addon.bankToogle(true)
  _addon.salesToogle(true)
    
    -- Kategorie: Bank  
  if goldAdded > 0 or itemAdded > 0 then
    if _ui.goldAdded == nil then _addon.bankControls() end
    
    _ui.goldAdded:SetText(white .. ZO_LocalizeDecimalNumber(goldAdded or 0) .. whiteGold)
    _ui.goldAddedCount:SetText("(".. white ..  goldAddedCount  .. white .. " " .. _L("PLAYER") ..")")
    _ui.goldRemoved:SetText(white .. ZO_LocalizeDecimalNumber(goldRemoved or 0) .. whiteGold)
    
    _ui.itemAdded:SetText(white .. itemAdded)
    _ui.itemRemoved:SetText(white .. itemRemoved)    
              
    _addon.bankToogle(false)
  elseif tax > 0 or turnover >0 then
    if _ui.salesIntern == nil then _addon.salesControls() end
    
    _ui.salesIntern:SetText(white .. round(100-(salesInternCount/#self.masterList*100)) .. "%" )
    _ui.turnover:SetText(white .. ZO_LocalizeDecimalNumber(turnover or 0) .. whiteGold)
    _ui.tax:SetText(white .. ZO_LocalizeDecimalNumber(tax or 0) .. whiteGold) 
    
    _addon.salesToogle(false)
  end
  
  _ui.count:SetText( stdColor .. filterCount .. white .. "/" .. #self.masterList)
end

function _addon.bankToogle(bool)
  if _ui.goldAdded == nil then return false end

  _ui.goldAdded:SetHidden(bool)
  _ui.goldAddedLabel:SetHidden(bool)
  _ui.goldAddedCount:SetHidden(bool)
  _ui.goldRemoved:SetHidden(bool)
  _ui.goldRemovedLabel:SetHidden(bool)  
  _ui.ItemLabel:SetHidden(bool)
  _ui.itemAddedLabel:SetHidden(bool)
  _ui.itemAdded:SetHidden(bool)
  _ui.itemRemovedLabel:SetHidden(bool)
  _ui.itemRemoved:SetHidden(bool)
  _ui.goldLabel:SetHidden(bool)
  
  SGT_HistoryOptionKiosk:SetHidden(bool)
  SGT_HistoryOptionLabel:SetHidden(bool)
end

function _addon.salesToogle(bool)
  if _ui.salesIntern == nil then return false end

  _ui.salesIntern:SetHidden(bool)
  _ui.turnover:SetHidden(bool)                                                                            
  _ui.tax:SetHidden(bool)
  _ui.salesInternLabel:SetHidden(bool)
  _ui.turnoverLabel:SetHidden(bool)
  _ui.taxLabel:SetHidden(bool)
  _ui.salesLabel:SetHidden(bool)
  
  SGT_HistoryOptionKiosk:SetHidden(bool)
  SGT_HistoryOptionLabel:SetHidden(bool)
end

-- Oberfläche
function _addon.bankControls()
  -- GOLD
  _ui.goldLabel = createLabel("SGT_HistoryGoldLabel", ZO_GuildHistoryCategories, white .. "GOLD", nil, {-190, 280}, nil, nil, "ZoFontGameBold")
  
  -- Einzahlung
  _ui.goldAddedLabel = createLabel("SGT_HistoryGoldAddedLabel", SGT_HistoryGoldLabel, _L("GOLDADDED"), nil, {-100, 30})
  _ui.goldAdded = createLabel("SGT_HistoryGoldAdded", SGT_HistoryGoldAddedLabel)
  _ui.goldAddedCount = createLabel("SGT_HistoryGoldAddedCount", SGT_HistoryGoldAdded, nil, nil, {-100, 30})

  -- Auszahlung
  _ui.goldRemovedLabel = createLabel("SGT_HistoryGoldRemovedLabel", SGT_HistoryGoldAddedLabel, _L("GOLDREMOVED"), nil, {-100, 60})
  _ui.goldRemoved = createLabel("SGT_HistoryGoldRemoved", SGT_HistoryGoldRemovedLabel)
  
  -- ITEMS
  _ui.ItemLabel = createLabel("SGT_HistoryItemLabel", SGT_HistoryGoldRemovedLabel, white .. "ITEMS", nil, {-100, 30}, nil, nil, "ZoFontGameBold")
  
  -- Eingelagert
  _ui.itemAddedLabel = createLabel("SGT_HistoryItemAddedLabel", SGT_HistoryItemLabel, _L("ITEMADDED"), nil, {-100, 30})
  _ui.itemAdded = createLabel("SGT_HistoryItemAdded", SGT_HistoryItemAddedLabel)
  
  -- Entnommen
  _ui.itemRemovedLabel = createLabel("SGT_HistoryItemRemovedLabel", SGT_HistoryItemAddedLabel, _L("ITEMREMOVED"), nil, {-100, 30})
  _ui.itemRemoved = createLabel("SGT_HistoryItemRemoved", SGT_HistoryItemRemovedLabel)
end

function _addon.salesControls()
  -- VERKÄUFE
  _ui.salesLabel = createLabel("SGT_HistorySalesLabel", ZO_GuildHistoryCategories, stdColor .. _L("SALES"), nil, {-190, 280}, nil, nil, "ZoFontGameBold")
   
  -- Intern 
  _ui.salesInternLabel = createLabel("SGT_HistorySalesInternLabel", SGT_HistorySalesLabel, _L("EXTERN"), nil, {-100, 30})
  _ui.salesIntern = createLabel("SGT_SalesIntern", SGT_HistorySalesInternLabel)
  
  -- Umsatz
  _ui.turnoverLabel = createLabel("SGT_HistoryTurnoverLabel", SGT_HistorySalesInternLabel, _L("TURNOVER"), nil, {-100, 30})
  _ui.turnover = createLabel("SGT_HistoryTurnover", SGT_HistoryTurnoverLabel)

  -- Steuern
  _ui.taxLabel = createLabel("SGT_HistoryTaxLabel", SGT_HistoryTurnoverLabel, _L("TAX"), nil, {-100, 30})
  _ui.tax = createLabel("SGT_HistoryTax", SGT_HistoryTaxLabel)
end

function _addon.editBox()
  _ui.searchBoxBackDrop = CreateControlFromVirtual("SGT_History_SearchBoxBackground", ZO_GuildHistory, "ZO_EditBackdrop")
  _ui.searchBoxBackDrop:SetDimensions(200, 25)
  _ui.searchBoxBackDrop:SetAnchor(TOPLEFT, ZO_GuildHistory, TOPLEFT, 400, 30)

  _ui.searchBox = CreateControlFromVirtual("SGT_History_SearchBox", _ui.searchBoxBackDrop, "ZO_DefaultEditForBackdrop")
  _ui.searchBox:SetHandler("OnTextChanged", function()
    _addon.refresh() 
  end)
  
  _ui.searchLabel = createLabel("SGT_HistorySearchLabel", SGT_History_SearchBoxBackground, _L("FILTER"), nil, {0, -20}, false, LEFT)
end

function _addon.pageFilter()
  _ui.filterLabel = createLabel("SGT_HistoryFilterLabel", SGT_HistorySearchLabel, _L("STATUS"), {150, 30}, {135, 0}, false)                                                                                         
  
  _ui.gold = _addon.createButton("SGT_History_Gold", "Gold", 640, 35)
  _ui.item = _addon.createButton("SGT_History_Item", "Item", 700, 35) 
   
  _ui.countLabel = createLabel("SGT_HistoryCountLabel", SGT_HistoryFilterLabel, _L("CHOICE"), {150, 30}, {8, 0}, false)
  _ui.count = createZOButton("SGT_History_Count","", 150, 750, 30, ZO_GuildHistory)    
end




--function GUILD_HISTORY:SetupGuildEvent(control, data, ...)
--  SetupGuildEvent_Orig(self, control, data, ...)
--  local oldTime = control:GetNamedChild("Time"):GetText()

--  local correction = GetSecondsSinceMidnight() - (GetTimeStamp() % 86400)
--  if correction < -12*60*60 then correction = correction + 86400 end

--  local timestamp = GetTimeStamp() - data.secsSinceEvent - (GetFrameTimeSeconds() - data.timeStamp)
--  local datestring = GetDateStringFromTimestamp(timestamp)
--  local timestring = ZO_FormatTime((timestamp + correction) % 86400, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR)

--  control:GetNamedChild("Time"):SetText(datestring .. " " .. timestring)
--end




function SGTOpenAllPages()
  EVENT_MANAGER:UnregisterForUpdate("ShissuGT_HistoryPage") 
  
  EVENT_MANAGER:RegisterForUpdate("ShissuGT_HistoryPage", 700, function()
    local count = table.getn(GUILD_HISTORY.masterList)
    RequestMoreGuildHistoryEvents()
                             
    zo_callLater(function()  
      local count2 = table.getn(GUILD_HISTORY.masterList)
    
      if (count == count2) then
        EVENT_MANAGER:UnregisterForUpdate("ShissuGT_HistoryPage")  
      end
    end, 1000)
  end)
end
           
function _addon.optionControls()
  _ui.optionLabel = createLabel("SGT_HistoryOptionLabel", ZO_GuildHistoryCategories, _L("OPT"), nil, {-190, 485}, nil, nil, "ZoFontGameBold")
  _ui.optionKiosk = CreateControlFromVirtual("SGT_HistoryOptionKiosk", SGT_HistoryOptionLabel, "ZO_CheckButton")
  _ui.optionKiosk:SetAnchor(LEFT, SGT_HistoryOptionKioskLabel, LEFT, 0, 30)
  _ui.optionKiosk:SetHidden(false)
  
  -- seit Gildenhändler
  ZO_CheckButton_SetLabelText(_ui.optionKiosk, white .. _L("TRADER"))
  ZO_CheckButton_SetToggleFunction(_ui.optionKiosk, function() _addon.refresh() end)

  _ui.optionKiosk2 = CreateControlFromVirtual("SGT_HistoryOptionKiosk2", SGT_HistoryOptionKiosk, "ZO_CheckButton")
  _ui.optionKiosk2:SetAnchor(LEFT, SGT_HistoryOptionKiosk, LEFT, 0, 30)
  _ui.optionKiosk2:SetHidden(false)
    
  -- seit vorletzten Gildenhändler
  ZO_CheckButton_SetLabelText(_ui.optionKiosk2, white .. _L("LAST"))
  ZO_CheckButton_SetToggleFunction(_ui.optionKiosk2, function() _addon.refresh() end)      
  
  -- Alles Öffnen
--  _ui.optionAllPages = CreateControlFromVirtual("SGT_HistoryAllPages", SGT_HistoryOptionKiosk2, "ZO_CheckButton")
--  _ui.optionAllPages:SetAnchor(LEFT, SGT_HistoryOptionKiosk2, LEFT, 0, 30)
--  _ui.optionAllPages:SetHidden(false)

--  ZO_CheckButton_SetLabelText(_ui.optionAllPages, white .. _L("PAGES"))
--  ZO_CheckButton_SetToggleFunction(_ui.optionAllPages, SGTOpenAllPages)    
  
  _ui.optionLabel:SetHidden(false)
end           

function _addon.refresh()
   GUILD_HISTORY:RefreshFilters() 
end
                                                                    
-- Initialisierung
function _addon.initialized()
  if (shissuHistory["sales"] == nil) then shissuHistory["sales"] = true end
  if (shissuHistory["bank"] == nil) then shissuHistory["bank"] = true end

  _cache.filterScrollList = GUILD_HISTORY.FilterScrollList
  GUILD_HISTORY.FilterScrollList = _addon.filterScrollList
  --GUILD_HISTORY.requestCount = 100
  
 _addon.createSettingMenu() 
 _addon.editBox()
 _addon.pageFilter()
 _addon.optionControls()  
 _addon.refresh() 

 zo_callLater(function() RequestMoreGuildHistoryEvents() end, 2000)
end                               

function _addon.EVENT_ADD_ON_LOADED(_, addOnName)
  if addOnName ~= _addon.Name then return end
  shissuHistory = shissuHistory or {}
    
  if shissuHistory == {} then
    shissuHistory = _addon.settings
  end                          

  zo_callLater(function()              
    ShissuFramework._settings[_addon.Name] = {}
    ShissuFramework._settings[_addon.Name].panel = _addon.panel                                       
    ShissuFramework._settings[_addon.Name].controls = _addon.controls  

    ShissuFramework.initAddon(_addon.Name, _addon.initialized)
  end, 150) 
                                 
  EVENT_MANAGER:UnregisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED)
end
     
EVENT_MANAGER:RegisterForEvent(_addon.Name, EVENT_ADD_ON_LOADED, _addon.EVENT_ADD_ON_LOADED)