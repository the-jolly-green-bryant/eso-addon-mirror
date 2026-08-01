local deglib = {
  name = "tooltip",
  version = 1,
  initialized = false,
}

function deglib:initialize()
    if self.initialized then return self end
  
    self.initialized = true
    
    return self
end

function deglib:new(fnTooltip)
  local tt = {
    vars = {
      [ItemTooltip] = {link = nil, linkIsNew = nil},
      [PopupTooltip] = {link = nil, linkIsNew = nil},
      [ComparativeTooltip1] = {link = nil, linkIsNew = nil},
      [ComparativeTooltip2] = {link = nil, linkIsNew = nil},
    },
    onUPDATE_TOOLTIP = function(self,Tooltip, mouseOverControl)
      local itemLink, degIndex
      
      if mouseOverControl then
        if mouseOverControl.bagId and mouseOverControl.slotIndex then
          itemLink = GetItemLink(mouseOverControl.bagId, mouseOverControl.slotIndex, LINK_STYLE_DEFAULT)
        elseif mouseOverControl.bagId and mouseOverControl.itemIndex then
          itemLink = GetItemLink(mouseOverControl.bagId, mouseOverControl.itemIndex)
        elseif mouseOverControl.dataEntry and mouseOverControl.dataEntry.data and mouseOverControl.dataEntry.data.bagId and mouseOverControl.dataEntry.data.slotIndex then  
          itemLink = GetItemLink(mouseOverControl.dataEntry.data.bagId, mouseOverControl.dataEntry.data.slotIndex, LINK_STYLE_DEFAULT)
        end
      end
    
      if self.vars[Tooltip].link then
      if not itemLink or itemLink == "" then
        if not self.vars[Tooltip].linkIsNew then return end
        itemLink = self.vars[Tooltip].link
        self.vars[Tooltip].linkIsNew = false  
      else
        if itemLink == self.vars[Tooltip].link then
          if not self.vars[Tooltip].linkIsNew then return end
          --itemLink = self.vars[Tooltip].link
          self.vars[Tooltip].linkIsNew = false      
        else
          self.vars[Tooltip].link = itemLink
          self.vars[Tooltip].linkIsNew = false
        end
      end
      end
            
      if not itemLink or itemLink == "" then return end
      
      self.vars[Tooltip].link = itemLink
    
      self:paintTooltip(Tooltip, itemLink)    
    end,
    onHIDE_TOOLTIP = function(self,Tooltip)
      self.vars[Tooltip].link = nil
      self.vars[Tooltip].linkIsNew = nil      
    end,
    onADD_GAME_DATA = function(self,Tooltip, gameDataType, ...)
      if gameDataType == TOOLTIP_GAME_DATA_EQUIPPED_INFO then
        local GetWornItemLink = function(equipSlot)
          return GetItemLink(BAG_WORN, equipSlot)
        end    
        local itemLink = GetWornItemLink(...)
        self.vars[Tooltip].link = itemLink
        self.vars[Tooltip].linkIsNew = true
      elseif gameDataType == TOOLTIP_GAME_DATA_STOLEN then
    
      end
    end,
    paintTooltip = function(self,Tooltip, itemLink)
      if (type(fnTooltip)=='function') then
        fnTooltip(Tooltip, itemLink)
      end
    end,
    initToolTipHandlers = function(self)
      local fnPopupTooltipSetLink = PopupTooltip.SetLink
      PopupTooltip.SetLink=function(control,itemLink,...)
        self.vars[PopupTooltip].link = itemLink
        self.vars[PopupTooltip].linkIsNew = true    
        fnPopupTooltipSetLink(control,itemLink,...)
      end
    
      local fnItemTooltipSetLink = ItemTooltip.SetLink
      ItemTooltip.SetLink=function(control,itemLink,...)
        self.vars[ItemTooltip].link = itemLink
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetLink(control,itemLink,...)
      end
      
      local fnItemTooltipSetBagItem = ItemTooltip.SetBagItem
      ItemTooltip.SetBagItem=function(control, bagId, slotIndex, ...)
        local itemLink = GetItemLink(bagId, slotIndex)
        self.vars[ItemTooltip].link = itemLink
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetBagItem(control, bagId, slotIndex, ...)
      end
      
      local fnItemTooltipSetWornItem = ItemTooltip.SetWornItem
      ItemTooltip.SetWornItem=function(control, equipSlot, ...)
        local itemLink = GetItemLink(BAG_WORN, equipSlot)
        self.vars[ItemTooltip].link = itemLink
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetWornItem(control, equipSlot, ...)
      end  
      
      local fnItemTooltipSetWornItem = ComparativeTooltip1.SetWornItem
      ComparativeTooltip1.SetWornItem=function(control, equipSlot, ...)
        local itemLink = GetItemLink(BAG_WORN, equipSlot)
        self.vars[ItemTooltip].link = itemLink
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetWornItem(control, equipSlot, ...)
      end
      
      local fnItemTooltipSetWornItem = ComparativeTooltip2.SetWornItem
      ComparativeTooltip2.SetWornItem=function(control, equipSlot, ...)
        local itemLink = GetItemLink(BAG_WORN, equipSlot)
        self.vars[ItemTooltip].link = itemLink
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetWornItem(control, equipSlot, ...)
      end    
      
      local fnItemTooltipSetLootItem = ItemTooltip.SetLootItem
      ItemTooltip.SetLootItem=function(control, lootId, ...)
        local itemLink = GetLootItemLink(lootId)
        self.vars[ItemTooltip].link = itemLink
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetLootItem(control, lootId, ...)
      end  
          
      local fnItemTooltipSetAttachedMailItem = ItemTooltip.SetAttachedMailItem
      ItemTooltip.SetAttachedMailItem=function(control,openMailId,attachmentIndex,...)
        self.vars[ItemTooltip].link = GetAttachedItemLink(openMailId,attachmentIndex)
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetAttachedMailItem(control,openMailId,attachmentIndex,...)
      end
      
      local fnItemTooltipSetBuybackItem = ItemTooltip.SetBuybackItem
      ItemTooltip.SetBuybackItem=function(control,index,...)
        self.vars[ItemTooltip].link = GetBuybackItemLink(index)
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetBuybackItem(control,index,...)
      end  
      
      local fnItemTooltipSetTradingHouseItem = ItemTooltip.SetTradingHouseItem
      ItemTooltip.SetTradingHouseItem=function(control,tradingHouseIndex,...)
        self.vars[ItemTooltip].link = GetTradingHouseSearchResultItemLink(tradingHouseIndex)
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetTradingHouseItem(control,tradingHouseIndex,...)
      end  
      
      local fnItemTooltipSetTradingHouseListing= ItemTooltip.SetTradingHouseListing
      ItemTooltip.SetTradingHouseListing=function(control,tradingHouseListingIndex,...)
        self.vars[ItemTooltip].link = GetTradingHouseListingItemLink(tradingHouseListingIndex)
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetTradingHouseListing(control,tradingHouseListingIndex,...)
      end
      
      local fnItemTooltipSetTradeItem= ItemTooltip.SetTradeItem
      ItemTooltip.SetTradeItem=function(control,tradeWho,slotIndex,...)
        self.vars[ItemTooltip].link = GetTradeItemLink(slotIndex)
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetTradeItem(control,tradeWho,slotIndex,...)
      end  
      
      local fnItemTooltipSetQuestReward= ItemTooltip.SetQuestReward
      ItemTooltip.SetQuestReward=function(control,rewardIndex,...)
        self.vars[ItemTooltip].link = GetQuestRewardItemLink(rewardIndex)
        self.vars[ItemTooltip].linkIsNew = true
        fnItemTooltipSetQuestReward(control,rewardIndex,...)
      end
    end,
  }
    
  
  ZO_PreHookHandler(ItemTooltip, "OnUpdate", function(Tooltip) tt:onUPDATE_TOOLTIP(Tooltip, moc()) end)
  ZO_PreHookHandler(ItemTooltip, "OnHide", function(Tooltip) tt:onHIDE_TOOLTIP(Tooltip) end)

  ZO_PreHookHandler(PopupTooltip, "OnUpdate", function(Tooltip) tt:onUPDATE_TOOLTIP(Tooltip) end)
  ZO_PreHookHandler(PopupTooltip, "OnHide", function(Tooltip) tt:onHIDE_TOOLTIP(Tooltip) end)
  
  ZO_PreHookHandler(ComparativeTooltip1, "OnUpdate", function(Tooltip) tt:onUPDATE_TOOLTIP(Tooltip) end)
  ZO_PreHookHandler(ComparativeTooltip1, "OnHide", function(Tooltip) tt:onHIDE_TOOLTIP(Tooltip) end)  
  
  ZO_PreHookHandler(ComparativeTooltip2, "OnUpdate", function(Tooltip) tt:onUPDATE_TOOLTIP(Tooltip) end)
  ZO_PreHookHandler(ComparativeTooltip2, "OnHide", function(Tooltip) tt:onHIDE_TOOLTIP(Tooltip) end)  
  
  ZO_PreHookHandler(ComparativeTooltip1, "OnAddGameData", function(...) tt:onADD_GAME_DATA(...) end)
  ZO_PreHookHandler(ComparativeTooltip2, "OnAddGameData", function(...) tt:onADD_GAME_DATA(...) end)
  
  tt:initToolTipHandlers()  
  
  return tt
end

degLibRegisterLib(deglib.name, deglib.version, deglib)