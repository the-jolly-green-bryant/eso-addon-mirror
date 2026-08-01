-- Copyright (c) 2016 User Calia1120 from ESOUI.com

TI.History.kioskSecsSinceEvent = 0

TI.ZO = {
  History = GUILD_HISTORY,
  GuildEvent = {},
}

-- LOCALS
local TI_History = {}

TI_History.Category = nil

TI_History.UI = {}
TI_History.Filter = {
  Gold = true,
  Item = true,
  Kiosk = false,
}

function TI.History.Toogle()
  TI_History.Filter = {
    Gold = true,
    Item = true,
    Kiosk = false,
  }
  
  if TI.Settings.History == true then TI_History.Toogle(false)       
  else TI_History.Toogle(true) end  
  
  TI.ZO.History:RefreshFilters()  
end

function TI_History.Toogle(bool)
  local TI = TI_History.UI
  
  TI.SearchLabel:SetHidden(bool)                                                                         
  TI.FilterLabel:SetHidden(bool)    
  TI.Gold:SetHidden(bool)    
  TI.Item:SetHidden(bool)    
  TI.ChoiceLabel:SetHidden(bool)  
  TI.MemberChoice:SetHidden(bool)    
  TI.SearchBoxBackDrop:SetHidden(bool)         
  TI.SearchBox:SetHidden(bool)       
  
  TI_History.SalesToogle(bool) 
  TI_History.BankToogle(bool) 
  TI_History.OptionToogle(bool)
end

function TI_History.BankToogle(bool)
  if TI_History.UI.goldAdded == nil then return false end

  TI_History.UI.goldAdded:SetHidden(bool)
  TI_History.UI.goldAddedLabel:SetHidden(bool)
  TI_History.UI.goldAddedCount:SetHidden(bool)
  TI_History.UI.goldRemoved:SetHidden(bool)
  TI_History.UI.goldRemovedLabel:SetHidden(bool)  
  TI_History.UI.ItemLabel:SetHidden(bool)
  TI_History.UI.itemAddedLabel:SetHidden(bool)
  TI_History.UI.itemAdded:SetHidden(bool)
  TI_History.UI.itemRemovedLabel:SetHidden(bool)
  TI_History.UI.itemRemoved:SetHidden(bool)
  TI_History.UI.goldLabel:SetHidden(bool)
end

function TI_History.SalesToogle(bool)
  if TI_History.UI.salesIntern == nil then return false end

  TI_History.UI.salesIntern:SetHidden(bool)
  TI_History.UI.turnover:SetHidden(bool)
  TI_History.UI.tax:SetHidden(bool)
  TI_History.UI.salesInternLabel:SetHidden(bool)
  TI_History.UI.turnoverLabel:SetHidden(bool)
  TI_History.UI.taxLabel:SetHidden(bool)
  TI_History.UI.salesLabel:SetHidden(bool)
end

function TI_History.OptionToogle(bool)
  if TI_History.UI.optionLabel == nil then return false end
  
  TI_History.UI.optionLabel:SetHidden(bool)
  TI_History.UI.optionKiosk:SetHidden(bool)
end

function TI_History.FilterScrollList(self)
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  local playerSearch = string.lower(TI_History.UI.SearchBox:GetText())
  local filterCount = 0
  local guildId = GUILD_SELECTOR.guildId
  local goldAdded = 0
  local goldAddedCount = 0
  local goldRemoved = 0    
  local itemAdded = 0
  local itemRemoved = 0
  local salesInternCount = 0     
  local turnover = 0 
  local tax = 0     
  local kioskCheckBox = false
  
  local currentTime = GetTimeStamp()
  local lastKioskTime = currentTime + TI.Lib.GetNextKioskTime() - (7* 86400)

  ZO_ClearNumericallyIndexedTable(scrollData)
  
  -- Controls nur verstecken, falls vorhanden
  TI_History.BankToogle(true)
  TI_History.SalesToogle(true)
  
  if TI_History.UI.optionLabel ~= nil then kioskCheckBox = ZO_CheckButton_IsChecked(TI_History.UI.optionKiosk) end
    
  for i = 1, #self.masterList do
    local data = self.masterList[i]
    
    if data.eventType ~= TI_History.Category then
      TI_History.Category = data.eventType 
    end
    
    -- ACCOUNTLINK
    if data.param1 ~= nil and not string.find(data.param1, "|H1") then
      data.param1 = string.format("|H1:display:%s|h%s|h", data.param1, data.param1)
    end

    -- Filter
    if(self.selectedSubcategory == nil or self.selectedSubcategory == data.subcategoryId) then
      if (not TI.Lib.IsStringEmpty(data.param1) and string.find(string.lower(data.param1), playerSearch, 1)) or 
        (not TI.Lib.IsStringEmpty(data.param2) and string.find(string.lower(data.param2), playerSearch, 1)) or
        (not TI.Lib.IsStringEmpty(data.param3) and string.find(string.lower(data.param3), playerSearch, 1)) or
        (not TI.Lib.IsStringEmpty(data.param4) and string.find(string.lower(data.param4), playerSearch, 1)) then         
                
        -- BANK
        if (not TI.Lib.IsStringEmpty(data.param2)) then
          if data.eventType == GUILD_EVENT_BANKGOLD_ADDED then 
          
            if lastKioskTime ~= 0 and kioskCheckBox then
              if currentTime - data.secsSinceEvent >= lastKioskTime then
                goldAdded = goldAdded + data.param2
                goldAddedCount = goldAddedCount + 1
              end
            else
              goldAdded = goldAdded + data.param2
              goldAddedCount = goldAddedCount + 1
            end
          end
          
          if data.eventType == GUILD_EVENT_BANKGOLD_REMOVED then 
            if lastKioskTime ~= 0 and kioskCheckBox then
              if currentTime - data.secsSinceEvent >= lastKioskTime then goldRemoved = goldRemoved + data.param2 end
            else goldRemoved = goldRemoved + data.param2 end      
          end
        end
        
        -- VERKAUF
        -- Accountname: data.param2, Steuern: data.param6, Gold durch Verkauf: data.param5      
        if data.eventType == GUILD_EVENT_ITEM_SOLD then
          if (not TI.Lib.IsStringEmpty(data.param1)) then
            for y=1, GetNumGuildMembers(guildId), 1 do
              local accInfo = {GetGuildMemberInfo(guildId, y)}
        
              if accInfo[1] == data.param2 then
                if lastKioskTime ~= 0 and kioskCheckBox then
                  if currentTime - data.secsSinceEvent >= lastKioskTime then salesInternCount = salesInternCount + 1 end
                else salesInternCount = salesInternCount + 1 end
                break 
              end
            end   
          end
              
          if lastKioskTime ~= 0 and kioskCheckBox then
            if currentTime - data.secsSinceEvent >= lastKioskTime then
              if (not TI.Lib.IsStringEmpty(data.param5)) then turnover = turnover + data.param5 end
              if (not TI.Lib.IsStringEmpty(data.param6)) then tax = tax + data.param6 end
            end
          else
            if (not TI.Lib.IsStringEmpty(data.param5)) then turnover = turnover + data.param5 end
            if (not TI.Lib.IsStringEmpty(data.param6)) then tax = tax + data.param6 end
          end            
        end     
                
        if (data.eventType == GUILD_EVENT_BANKITEM_ADDED) then
          if currentTime - data.secsSinceEvent >= lastKioskTime then itemAdded = itemAdded + 1
          else itemAdded = itemAdded + 1 end
        end       
        
        if (data.eventType == GUILD_EVENT_BANKITEM_REMOVED) then
          if currentTime - data.secsSinceEvent >= lastKioskTime then itemRemoved = itemRemoved + 1
          else itemRemoved = itemRemoved + 1 end
        end       

        -- FILTER Buttons
        if (TI_History.Filter.Gold == false and (data.eventType == GUILD_EVENT_BANKGOLD_ADDED or
          data.eventType == GUILD_EVENT_BANKGOLD_ADDED or
          data.eventType == GUILD_EVENT_BANKGOLD_GUILD_STORE_TAX or
          data.eventType == GUILD_EVENT_BANKGOLD_KIOSK_BID or
          data.eventType == GUILD_EVENT_BANKGOLD_KIOSK_BID_REFUND or
          data.eventType == GUILD_EVENT_BANKGOLD_PURCHASE_HERALDRY or
          data.eventType == GUILD_EVENT_BANKGOLD_REMOVED)) then       
        elseif (TI_History.Filter.Item == false and (data.eventType == GUILD_EVENT_BANKITEM_ADDED or
          data.eventType == GUILD_EVENT_BANKITEM_REMOVED)) then  
        else
          table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
          filterCount = filterCount + 1
        end    
      end
      
    end 
  end
    
  TI_History.UI.MemberChoice:SetText( TI.Color[6] .. filterCount .. TI.Color[5] .. "/" .. #self.masterList) 
  
  -- Kategorie: Bank  
  if goldAdded > 0 or itemAdded > 0 then
    if TI_History.UI.goldAdded == nil then TI_History.BankControls() end
    
    TI_History.UI.goldAdded:SetText(TI.Color[5] .. goldAdded .. TI.WhiteGold)
    TI_History.UI.goldAddedCount:SetText("(".. TI.Color[6] ..  goldAddedCount .. TI.Color[5] .. " Spieler)")
    TI_History.UI.goldRemoved:SetText(TI.Color[5] .. goldRemoved .. TI.WhiteGold)
    
    TI_History.UI.itemAdded:SetText(TI.Color[5] .. itemAdded)
    TI_History.UI.itemRemoved:SetText(TI.Color[5] .. itemRemoved)    
    
    TI_History.BankToogle(false)
  end

  -- Kategorie: Verkauf
  if salesInternCount > 0 or tax > 0 or turnover >0 then
    if TI_History.UI.salesIntern == nil then TI_History.SalesControls() end
    
    TI_History.UI.salesIntern:SetText(TI.Color[5] .. TI.Lib.Round(salesInternCount/#self.masterList*100) .. TI.Color[6] .. "%" )
    TI_History.UI.turnover:SetText(TI.Color[5] .. turnover .. TI.WhiteGold)
    TI_History.UI.tax:SetText(TI.Color[5] .. tax .. TI.WhiteGold) 
    TI_History.SalesToogle(false)
  end   
end               

function TI_History.EditBox()
  TI_History.UI.SearchBoxBackDrop = CreateControlFromVirtual("TI_History_SearchBoxBackground", ZO_GuildHistory, "ZO_EditBackdrop")
  TI_History.UI.SearchBoxBackDrop:SetDimensions(200, 25)
  TI_History.UI.SearchBoxBackDrop:SetAnchor(TOPLEFT, ZO_GuildHistory, TOPLEFT, 400, 30)

  TI_History.UI.SearchBox = CreateControlFromVirtual("TI_History_SearchBox", TI_History.UI.SearchBoxBackDrop, "ZO_DefaultEditForBackdrop")
  TI_History.UI.SearchBox:SetHandler("OnTextChanged", function()
  TI.ZO.History:RefreshFilters()
  end)
end

function TI_History.CreateButton(name, var, offsetX, offsetY) 
  local button = CreateControlFromVirtual(name, ZO_GuildHistory, "ZO_CheckButton")
  button:SetAnchor(TOPLEFT, ZO_GuildHistory, TOPLEFT, offsetX, offsetY)
  
  TI.Lib.CheckBox(button, var)
  
  ZO_CheckButton_SetToggleFunction(button, function(control, checked)
    TI_History.Filter[var] = checked
    TI.ZO.History:RefreshFilters()
  end)
  
  TI.Lib.SetToolTip(button, "History", var)
  TI.Lib.HideToolTip(button)
  
  return button
end

function TI_History.BankControls()
  -- GOLD
  TI_History.UI.goldLabel = TI.Lib.CreateLabel("TI_HistoryGoldLabel", ZO_GuildHistoryCategories, TI.Color[5] .. "GOLD", nil, {30, 250}, nil, nil, "ZoFontGameBold")
  
  -- Einzahlung
  TI_History.UI.goldAddedLabel = TI.Lib.CreateLabel("TI_HistoryGoldAddedLabel", TI_HistoryGoldLabel, TI.i18n.History.GoldAdded, nil, {-100, 30})
  TI_History.UI.goldAdded = TI.Lib.CreateLabel("TI_HistoryGoldAdded", TI_HistoryGoldAddedLabel)
  TI_History.UI.goldAddedCount = TI.Lib.CreateLabel("TI_HistoryGoldAddedCount", TI_HistoryGoldAdded, nil, nil, {-100, 30})

  -- Auszahlung
  TI_History.UI.goldRemovedLabel = TI.Lib.CreateLabel("TI_HistoryGoldRemovedLabel", TI_HistoryGoldAddedLabel, TI.Lib.ReplaceCharacter(TI.i18n.History.GoldRemoved), nil, {-100, 60})
  TI_History.UI.goldRemoved = TI.Lib.CreateLabel("TI_HistoryGoldRemoved", TI_HistoryGoldRemovedLabel)
  
  -- ITEMS
  TI_History.UI.ItemLabel = TI.Lib.CreateLabel("TI_HistoryItemLabel", TI_HistoryGoldRemovedLabel, TI.Color[5] .. "ITEMS", nil, {-100, 30}, nil, nil, "ZoFontGameBold")
  
  -- Eingelagert
  TI_History.UI.itemAddedLabel = TI.Lib.CreateLabel("TI_HistoryItemAddedLabel", TI_HistoryItemLabel, TI.i18n.History.ItemAdded, nil, {-100, 30})
  TI_History.UI.itemAdded = TI.Lib.CreateLabel("TI_HistoryItemAdded", TI_HistoryItemAddedLabel)
  
  -- Entnommen
  TI_History.UI.itemRemovedLabel = TI.Lib.CreateLabel("TI_HistoryItemRemovedLabel", TI_HistoryItemAddedLabel, TI.Lib.ReplaceCharacter(TI.i18n.History.ItemRemoved), nil, {-100, 30})
  TI_History.UI.itemRemoved = TI.Lib.CreateLabel("TI_HistoryItemRemoved", TI_HistoryItemRemovedLabel)
end

function TI_History.SalesControls()
  -- VERKÄUFE
  TI_History.UI.salesLabel = TI.Lib.CreateLabel("TI_HistorySalesLabel", ZO_GuildHistoryCategories, TI.Color[5] .. TI.Lib.ReplaceCharacter(TI.i18n.History.Sells), nil, {30, 250}, nil, nil, "ZoFontGameBold")
  
  -- Intern 
  TI_History.UI.salesInternLabel = TI.Lib.CreateLabel("TI_HistorySalesInternLabel", TI_HistorySalesLabel, TI.i18n.History.Intern, nil, {-100, 30})
  TI_History.UI.salesIntern = TI.Lib.CreateLabel("TI_SalesIntern", TI_HistorySalesInternLabel)
  
  -- Umsatz
  TI_History.UI.turnoverLabel = TI.Lib.CreateLabel("TI_HistoryTurnoverLabel", TI_HistorySalesInternLabel, TI.Lib.ReplaceCharacter(TI.i18n.History.Sales), nil, {-100, 30})
  TI_History.UI.turnover = TI.Lib.CreateLabel("TI_HistoryTurnover", TI_HistoryTurnoverLabel)

  -- Steuern
  TI_History.UI.taxLabel = TI.Lib.CreateLabel("TI_HistoryTaxLabel", TI_HistoryTurnoverLabel, TI.Lib.ReplaceCharacter(TI.i18n.History.Tax), nil, {-100, 30})
  TI_History.UI.tax = TI.Lib.CreateLabel("TI_HistoryTax", TI_HistoryTaxLabel)
end

TI_History.AllPages = false

function TI_History.OptionControls()
  -- seit Gildenhändler
  TI_History.UI.optionLabel = TI.Lib.CreateLabel("TI_HistoryOptionLabel", ZO_GuildHistoryCategories, "OPTIONEN", nil, {30, 470}, nil, nil, "ZoFontGameBold")
  TI_History.UI.optionKiosk = CreateControlFromVirtual("TI_HistoryOptionKiosk", TI_HistoryOptionLabel, "ZO_CheckButton")
  TI_History.UI.optionKiosk:SetAnchor(LEFT, TI_HistoryOptionKioskLabel, LEFT, 0, 30)
  TI_History.UI.optionKiosk:SetHidden(false)
  ZO_CheckButton_SetLabelText(TI_History.UI.optionKiosk, TI.Color[5] .. TI.Lib.ReplaceCharacter(TI.i18n.History.Trader))
  ZO_CheckButton_SetToggleFunction(TI_History.UI.optionKiosk, function() TI.ZO.History:RefreshFilters() end)   
  
  -- Alles Öffnen
  TI_History.UI.optionAllPages = CreateControlFromVirtual("TI_HistoryAllPages", TI_HistoryOptionKiosk, "ZO_CheckButton")
  TI_History.UI.optionAllPages:SetAnchor(LEFT, TI_HistoryOptionKiosk, LEFT, -0, 30)
  TI_History.UI.optionAllPages:SetHidden(false)
  ZO_CheckButton_SetLabelText(TI_History.UI.optionAllPages, TI.Color[5] .. TI.Lib.ReplaceCharacter(TI.i18n.History.AllPage))
  
  TI_History.UI.optionAllPages:SetHandler("OnMouseEnter", function(self) TI.Lib.ToolTip(self, TI.Lib.ReplaceCharacter(TI.i18n.History.AllPageInfo)) end)
  TI_History.UI.optionAllPages:SetHandler("OnMouseExit", function(self) ZO_Tooltips_HideTextTooltip() end)
  
  ZO_CheckButton_SetToggleFunction(TI_History.UI.optionAllPages, function() 
    if TI_History.AllPages == false then 
      TI.Misc.OpenAllPages() 
      TI_History.AllPages = true
    else
      EVENT_MANAGER:UnregisterForUpdate("TI_HistoryPage") 
      TI_History.AllPages = false
    end
  end)    
  
  TI_HistoryOptionLabel:SetHidden(false)
end

function TI.History.Initialize()
  local CL = TI.Lib.CreateZOButton
  TI.History.Active = true
  TI.ZO.History.FilterScrollList = TI_History.FilterScrollList
  
  TI_History.EditBox()
  TI_History.UI.SearchLabel = TI.Lib.CreateLabel("TI_HistorySearchLabel", TI_History_SearchBoxBackground, TI.i18n.History.FilterBox, nil, {0, -20}, false, LEFT)
 
  -- FILTER
  TI_History.UI.FilterLabel = TI.Lib.CreateLabel("TI_HistoryFilterLabel", TI_HistorySearchLabel, TI.i18n.History.OnOff, {150, 30}, {135, 0}, false)
  TI_History.UI.Gold = TI_History.CreateButton("TI_History_Gold","Gold", 640, 35)
  TI_History.UI.Item = TI_History.CreateButton("TI_History_Item","Item", 700, 35)  
  TI_History.UI.ChoiceLabel = TI.Lib.CreateLabel("TI_HistoryChoiceLabel", TI_HistoryFilterLabel, TI.i18n.History.Choice2, {150, 30}, {8, 0}, false)
  TI_History.UI.MemberChoice = CL("TI_History_MemberChoice","/", 150, 750, 30, ZO_GuildHistory)    
  
  TI.Lib.SetToolTip(TI_History.UI.SearchBox, "History", "Filter")
  TI.Lib.HideToolTip(TI_History.UI.SearchBox)
  TI.Lib.SetToolTip(TI_History.UI.MemberChoice, "History", "Choice")
  TI.Lib.HideToolTip(TI_History.UI.MemberChoice)    
  
  TI_History.OptionControls()   
end

function TI.Misc.OpenAllPages()
  EVENT_MANAGER:UnregisterForUpdate("TI_HistoryPage") 
  
  EVENT_MANAGER:RegisterForUpdate("TI_HistoryPage", 1500, function()
    local count = table.getn(GUILD_HISTORY.masterList)
    TI.ZO.History:RequestOlder()
    
    zo_callLater(function()  
      local count2 = table.getn(GUILD_HISTORY.masterList)
    
      if (count == count2) then
        EVENT_MANAGER:UnregisterForUpdate("TI_HistoryPage")  
      end
  end, 500); 
  end)
end