local LAM = LibAddonMenu2
local LMP = LibMediaProvider
local OriginalSetupPendingPost

function TTCCompanion:GetMeetsRequirements(itemLink)
  if (not WritWorthy) then return false end
  local hasKnowledge = true
  local hasMaterials = true
  local parser = WritWorthy.CreateParser(itemLink)
  if (not parser or not parser:ParseItemLink(itemLink) or not parser.ToKnowList) then
    return false
  end
  local knowList = parser:ToKnowList()
  if (knowList) then
    for _, know in ipairs(knowList) do
      if (not know.is_known) then
        hasKnowledge = false
      end
    end
  end

  local matList = parser:ToMatList()
  if (matList) then
    for _, mat in ipairs(matList) do
      if (WritWorthy.Util.MatHaveCt(mat.link) < mat.ct) then
        hasMaterials = false
      end
    end
  end

  return hasKnowledge, hasMaterials
end

function TTCCompanion:ToggleWritMarkerBrowseResults(rowControl, slot)
  local markerControl = rowControl:GetNamedChild(TTCCompanion.name .. "Writ")
  local rData = rowControl.dataEntry and rowControl.dataEntry.data or nil
  local itemLink = rData and rData.itemLink or nil
  local hasKnowledge, hasMaterials = TTCCompanion:GetMeetsRequirements(itemLink)

  if (not markerControl) then
    if not hasKnowledge then return end
    markerControl = WINDOW_MANAGER:CreateControl(rowControl:GetName() .. TTCCompanion.name .. "Writ", rowControl, CT_TEXTURE)
    markerControl:SetDimensions(22, 22)
    markerControl:SetInheritScale(false)
    markerControl:SetAnchor(LEFT, rowControl, LEFT)
    markerControl:SetDrawTier(DT_HIGH)
  end

  if hasKnowledge and hasMaterials then
    markerControl:SetTexture("TamrielTradeCentreCompanion/img/does_meet.dds")
    markerControl:SetColor(0.17, 0.93, 0.17, 1)
    markerControl:SetHidden(false)
  elseif hasKnowledge and not hasMaterials then
    markerControl:SetTexture("esoui/art/miscellaneous/help_icon.dds")
    markerControl:SetColor(1, 0.99, 0, 1)
    markerControl:SetHidden(false)
  else markerControl:SetHidden(true) end
end

function TTCCompanion:ToggleWritMarkerInventoryList(rowControl, slot)
  local markerControl = rowControl:GetNamedChild(TTCCompanion.name .. "Writ")
  local relativeToPoint = rowControl:GetNamedChild("Button")
  local bagId = rowControl.dataEntry.data.bagId
  local slotIndex = rowControl.dataEntry.data.slotIndex
  local itemLink = GetItemLink(bagId, slotIndex)
  local hasKnowledge, hasMaterials = TTCCompanion:GetMeetsRequirements(itemLink)

  if (not markerControl) then
    if not hasKnowledge then return end
    markerControl = WINDOW_MANAGER:CreateControl(rowControl:GetName() .. TTCCompanion.name .. "Writ", rowControl, CT_TEXTURE)
    markerControl:SetDimensions(22, 22)
    markerControl:SetInheritScale(false)
    markerControl:SetAnchor(LEFT, relativeToPoint, LEFT)
    markerControl:SetDrawTier(DT_HIGH)
  end

  if hasKnowledge and hasMaterials and TTCCompanion.tradingHouseOpened then
    markerControl:SetTexture("TamrielTradeCentreCompanion/img/does_meet.dds")
    markerControl:SetColor(0.17, 0.93, 0.17, 1)
    markerControl:SetHidden(false)
  elseif hasKnowledge and not hasMaterials and TTCCompanion.tradingHouseOpened then
    markerControl:SetTexture("esoui/art/miscellaneous/help_icon.dds")
    markerControl:SetColor(1, 0.99, 0, 1)
    markerControl:SetHidden(false)
  else markerControl:SetHidden(true) end
end

function TTCCompanion:ToggleVendorMarker(rowControl, slot)
  local markerControl = rowControl:GetNamedChild(TTCCompanion.name .. "Warn")
  local relativeToPoint = rowControl:GetNamedChild("SellPrice")
  local showVendorWarning = false
  local vendorWarningPricing = nil
  local rData = rowControl.dataEntry and rowControl.dataEntry.data or nil
  local itemLink = rData and rData.itemLink or nil
  if not itemLink and rowControl.slotIndex then
    itemLink = GetItemLink(rowControl.bagId, rowControl.slotIndex)
  end
  local purchasePrice = rData and rData.purchasePrice or nil
  local stackCount = rData and rData.stackCount or nil
  local itemType = GetItemLinkItemType(itemLink)
  local itemId = GetItemLinkItemId(itemLink)

  if TTCCompanion["vendor_price_table"][itemType] then
    if TTCCompanion["vendor_price_table"][itemType][itemId] then vendorWarningPricing = TTCCompanion["vendor_price_table"][itemType][itemId] end
  end
  if purchasePrice and stackCount and vendorWarningPricing then
    local storeItemUnitPrice = purchasePrice / stackCount
    if storeItemUnitPrice > vendorWarningPricing then showVendorWarning = true end
  end

  if (not markerControl) then
    if not showVendorWarning then return end
    markerControl = WINDOW_MANAGER:CreateControl(rowControl:GetName() .. TTCCompanion.name .. "Warn", rowControl, CT_TEXTURE)
    markerControl:SetDimensions(22, 22)
    markerControl:SetInheritScale(false)
    markerControl:SetAnchor(LEFT, relativeToPoint, LEFT)
    markerControl:SetDrawTier(DT_HIGH)
  end

  if (showVendorWarning) then
    markerControl:SetTexture("/esoui/art/inventory/newitem_icon.dds")
    markerControl:SetColor(0.9, 0.3, 0.2, 1)
    markerControl:SetHidden(false)
  else
    markerControl:SetHidden(true)
  end
end

-- ZO_TradingHouseBrowseItemsRightPaneSearchResults
-- ZO_TradingHouseBrowseItemsRightPaneSearchResultsContents
-- ZO_TradingHousePostedItemsListContents
-- ZO_TradingHouseBrowseItemsLeftPane (Relative To)
function TTCCompanion:InitializeHooks()
  if (not TTCCompanion.tradingHouseBrowseMarkerHooked) then
    SecurePostHook(TRADING_HOUSE, "OpenTradingHouse", function()
      local oldCallback = ZO_TradingHouseBrowseItemsRightPaneSearchResults.dataTypes[1].setupCallback
      ZO_TradingHouseBrowseItemsRightPaneSearchResults.dataTypes[1].setupCallback = function(rowControl, slot)
        oldCallback(rowControl, slot)
        TTCCompanion:ToggleVendorMarker(rowControl, slot)
        if TTCCompanion.wwDetected and not TTCCompanion.mwimDetected then
          TTCCompanion:ToggleWritMarkerBrowseResults(rowControl, slot)
        end
      end
    end)
  end
  if (not TTCCompanion.inventoryMarkersHooked) then
    local originalCall = ZO_PlayerInventoryList.dataTypes[1].setupCallback
    SecurePostHook(ZO_PlayerInventoryList.dataTypes[1], "setupCallback", function(rowControl, slot)
      originalCall(rowControl, slot)
      if TTCCompanion.wwDetected and not TTCCompanion.mwimDetected then
        TTCCompanion:ToggleWritMarkerInventoryList(rowControl, slot)
      end
    end)
  end
  TTCCompanion.tradingHouseBrowseMarkerHooked = true
  TTCCompanion.inventoryMarkersHooked = false
end

function TTCCompanion:RemoveItemTooltip()
  -- TTCCompanion:dm("Debug", "RemoveItemTooltip")
  if ItemTooltip.tooltipTextPool then
    ItemTooltip.tooltipTextPool:ReleaseAllObjects()
  end
  ItemTooltip.warnText = nil
  ItemTooltip.vendorWarnText = nil
  ItemTooltip.mmMatText = nil
  TTCCompanion.tippingControl = nil
end

function TTCCompanion:RemovePopupTooltip(Popup)
  -- TTCCompanion:dm("Debug", "RemovePopupTooltip")
  if Popup.tooltipTextPool then
    Popup.tooltipTextPool:ReleaseAllObjects()
  end

  Popup.warnText = nil
  Popup.vendorWarnText = nil
  Popup.mmMatText = nil
  Popup.ttccActiveTip = nil
end

function TTCCompanion:GenerateTooltip(tooltip, itemLink, purchasePrice, stackCount)
  if not TTCCompanion.isInitialized then return end
  -- TTCCompanion:dm("Debug", "GenerateTooltip")

  local function GetVendorPricing(itemType, itemId)
    if TTCCompanion["vendor_price_table"][itemType] then
      if TTCCompanion["vendor_price_table"][itemType][itemId] then return TTCCompanion["vendor_price_table"][itemType][itemId] end
    end
    return nil
  end

  local itemType = GetItemLinkItemType(itemLink)
  local itemId = GetItemLinkItemId(itemLink)
  local materialCostLine = nil
  local removedWarningTipline = nil
  local vendorWarningTipline = nil
  local vendorWarningPricing = GetVendorPricing(itemType, itemId)
  -- the removedItemIdTable table has only true values, no function needed
  local showRemovedWarning = TTCCompanion.removedItemIdTable[itemId]
  local showVendorWarning = false

  if purchasePrice and stackCount and vendorWarningPricing then
    local storeItemUnitPrice = purchasePrice / stackCount
    if storeItemUnitPrice > vendorWarningPricing then showVendorWarning = true end
  end
  if showVendorWarning then
    vendorWarningTipline = string.format(GetString(TTCC_VENDOR_ITEM_WARN), vendorWarningPricing) .. TTCCompanion.coinIcon
  end
  if showRemovedWarning ~= nil then
    removedWarningTipline = GetString(TTCC_REMOVED_ITEM_WARN)
  end
  if itemType == ITEMTYPE_MASTER_WRIT then
    materialCostLine = TTCCompanion:MaterialCostPriceTip(itemLink, purchasePrice)
  end

  if not tooltip.tooltipTextPool then
    tooltip.tooltipTextPool = ZO_ControlPool:New("TTCCTooltipText", tooltip, "TTCCTooltipLine")
  end

  local hasTiplineOrGraph = vendorWarningTipline or removedWarningTipline or materialCostLine
  local hasTiplineControls = tooltip.vendorWarnText or tooltip.warnText or tooltip.mmMatText

  if hasTiplineOrGraph and not hasTiplineControls then
    tooltip:AddVerticalPadding(2)
    ZO_Tooltip_AddDivider(tooltip)
  end

  if removedWarningTipline then
    if not tooltip.warnText then
      tooltip:AddVerticalPadding(2)
      tooltip.warnText = tooltip.tooltipTextPool:AcquireObject()
      tooltip:AddControl(tooltip.warnText)
      tooltip.warnText:SetAnchor(CENTER)
    end

    if tooltip.warnText then
      tooltip.warnText:SetText(removedWarningTipline)
      tooltip.warnText:SetColor(0.87, 0.11, 0.14, 1)
    end

  end

  if vendorWarningTipline then
    if not tooltip.vendorWarnText then
      tooltip:AddVerticalPadding(2)
      tooltip.vendorWarnText = tooltip.tooltipTextPool:AcquireObject()
      tooltip:AddControl(tooltip.vendorWarnText)
      tooltip.vendorWarnText:SetAnchor(CENTER)
    end

    if tooltip.vendorWarnText then
      tooltip.vendorWarnText:SetText(vendorWarningTipline)
    end

  end

  if materialCostLine and TTCCompanion.savedVariables.showMaterialCost then

    if not tooltip.mmMatText then
      tooltip:AddVerticalPadding(2)
      tooltip.mmMatText = tooltip.tooltipTextPool:AcquireObject()
      tooltip:AddControl(tooltip.mmMatText)
      tooltip.mmMatText:SetAnchor(CENTER)
    end

    if tooltip.mmMatText then
      tooltip.mmMatText:SetText(materialCostLine)
      tooltip.mmMatText:SetColor(1, 1, 1, 1)
    end

  end

end

function TTCCompanion:GeneratePopupTooltip(Popup)
  local showTooltipInformation = (TTCCompanion.savedVariables.showMaterialCost)

  if Popup == ZO_ProvisionerTopLevelTooltip then
    local recipeListIndex, recipeIndex = PROVISIONER:GetSelectedRecipeListIndex(), PROVISIONER:GetSelectedRecipeIndex()
    Popup.lastLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)
  end

  --Make sure Info Tooltip and Context Menu is on top of the popup
  --InformationTooltip:GetOwningWindow():BringWindowToTop()
  --[[TODO: Is this needed for TTCC? ]]--
  Popup:GetOwningWindow():SetDrawTier(ZO_Menus:GetDrawTier() - 1)

  -- Make sure we don't double-add stats (or double-calculate them if they bring
  -- up the same link twice) since we have to call this on Update rather than Show
  if not showTooltipInformation or Popup.lastLink == nil or (Popup.ttccActiveTip and Popup.ttccActiveTip == Popup.lastLink) then
    -- thanks Garkin
    return
  end

  if Popup.ttccActiveTip ~= Popup.lastLink then
    if Popup.tooltipTextPool then
      Popup.tooltipTextPool:ReleaseAllObjects()
    end
    Popup.warnText = nil
    Popup.vendorWarnText = nil
    Popup.mmMatText = nil
  end
  Popup.ttccActiveTip = Popup.lastLink

  TTCCompanion:GenerateTooltip(Popup, Popup.ttccActiveTip)
end

local FurnishingOverrides = {
  [118327] = { subtype_base = 118 }, -- Provisioning Station
  [118328] = { subtype_base = 118 }, -- Alchemy Station
  [118329] = { subtype_base = 118 }, -- Dye Station
  [118330] = { subtype_base = 118 }, -- Enchanting Station
  [119707] = { subtype_base = 118 }, -- Clothing Station
  [119744] = { subtype_base = 118 }, -- Woodworking Station
  [119781] = { subtype_base = 118 }, -- Blacksmithing Station
  [133576] = { subtype_base = 118 }, -- Transmute Station
  [137870] = { subtype_base = 118 }, -- Jewelry Crafting Station
  [134675] = { subtype_base = 118 }, -- Outfit Station
}

local IDX = {
  TEXT          = 1,  -- (returned but we don't use)
  LINK_STYLE    = 2,
  TYPE          = 3,  -- ITEM_LINK_TYPE = "item", COLLECTIBLE_LINK_TYPE = "collectible"
  ITEM_ID       = 4,  -- wiki 1
  SUBTYPE       = 5,  -- wiki 2
  INTERNAL_LVL  = 6,  -- wiki 3
  ENCHANT_ID    = 7,  -- wiki 4
  ENCHANT_SUB   = 8,  -- wiki 5
  ENCHANT_LVL   = 9,  -- wiki 6
  WRIT1_OR_TRANS= 10, -- wiki 7
  WRIT2         = 11, -- wiki 8
  WRIT3         = 12, -- wiki 9
  WRIT4         = 13, -- wiki 10
  WRIT5         = 14, -- wiki 11
  WRIT6         = 15, -- wiki 12
  UNUSED_13     = 16, -- wiki 13
  UNUSED_14     = 17, -- wiki 14
  FLAGS         = 18, -- wiki 15
  ITEM_STYLE    = 19, -- wiki 16
  CRAFTED       = 20, -- wiki 17
  BOUND         = 21, -- wiki 18
  STOLEN        = 22, -- wiki 19
  CHARGES       = 23, -- wiki 20
  POTION_OR_RWR = 24, -- wiki 21 (PotionEffect or WritReward)
}

-- Convenience aliases & bounds
IDX.FIRST = IDX.ITEM_ID
IDX.LAST  = IDX.POTION_OR_RWR
IDX.LEVEL = IDX.INTERNAL_LVL     -- readability alias

local function ParseFields(itemLink)
  local f = { ZO_LinkHandler_ParseLink(itemLink) }
  return f
end

local function EnsureString(v)
  if v == nil then return "0" end
  if type(v) == "number" then return tostring(v) end
  if v == "" then return "0" end
  return v
end

local function BuildItemLinkFromFields(f)
  local out = {}
  for i = IDX.FIRST, IDX.LAST do
    out[#out+1] = EnsureString(f[i])
  end
  return ("|H1:item:%s|h|h"):format(table.concat(out, ":"))
end

function TTCCompanion:SetCrafted(itemLink)
  local f = ParseFields(itemLink)
  f[IDX.CRAFTED] = "1"
  return BuildItemLinkFromFields(f)
end

function TTCCompanion:SetLinkStyle(itemLink, style)
  local f = ParseFields(itemLink)
  f[IDX.LINK_STYLE] = EnsureString(style or LINK_STYLE_DEFAULT)
  return BuildItemLinkFromFields(f)
end

function TTCCompanion:SetLevelAndSubType(itemLink)
  local f = ParseFields(itemLink)
  if not f then return itemLink end

  local q = tonumber(GetItemLinkDisplayQuality(itemLink)) or 0
  local l = tonumber(GetItemLinkRequiredLevel(itemLink)) or 0

  local itemId = tonumber(f[IDX.ITEM_ID])
  local ov = itemId and FurnishingOverrides and FurnishingOverrides[itemId]

  if ov and ov.subtype_base then
    -- Use furnishing override: subtype = base + quality + level
    f[IDX.SUBTYPE] = tostring(ov.subtype_base + q + l)
  else
    -- Default behavior
    f[IDX.SUBTYPE] = tostring(q + l)
  end

  f[IDX.LEVEL] = l
  return BuildItemLinkFromFields(f)
end

function TTCCompanion:CheckLevelAndSubType(itemLink)
  local f = ParseFields(itemLink)
  local hasNoLevel   = tonumber(f[IDX.LEVEL])   == nil or tonumber(f[IDX.LEVEL])   == 0
  local hasNoSubType = tonumber(f[IDX.SUBTYPE]) == nil or tonumber(f[IDX.SUBTYPE]) == 0

  if hasNoLevel and hasNoSubType then
    return self:SetLevelAndSubType(itemLink)
  end
  return itemLink
end
function TTCCompanion:GenerateItemTooltip()
  if not TTCCompanion.isInitialized then return end
  -- TTCCompanion:dm("Debug", "GenerateItemTooltip")
  local showTooltipInformation = (TTCCompanion.savedVariables.showMaterialCost)
  -- local skMoc = moc()
  local mouseOverControl = moc()
  -- Make sure we don't double-add stats or try to add them to nothing
  -- Since we call this on Update rather than Show it gets called a lot
  -- even after the tip appears
  if not showTooltipInformation or (not mouseOverControl or not mouseOverControl:GetParent()) or (mouseOverControl == TTCCompanion.tippingControl) then
    return
  end

  local itemLink = nil
  local purchasePrice = nil
  local stackCount = nil
  local mouseOverControlParent
  local mouseOverControlGrandparent
  local mocOwner

  if mouseOverControl.GetParent then mouseOverControlParent = mouseOverControl:GetParent() end
  if mouseOverControlParent and mouseOverControlParent.GetParent then mouseOverControlGrandparent = mouseOverControlParent:GetParent() end
  if mouseOverControl and mouseOverControl.GetOwningWindow then mocOwner = mouseOverControl:GetOwningWindow() end

  local mocName = mouseOverControl:GetName()
  local mocParentName
  local mocGPName
  local mocOwnerName

  if mouseOverControlParent then mocParentName = mouseOverControlParent:GetName() end
  if mouseOverControlGrandparent then mocGPName = mouseOverControlGrandparent:GetName() end
  if mocOwner then mocOwnerName = mocOwner:GetName() end

  local hasDataEntryData = mouseOverControl and mouseOverControl.dataEntry and mouseOverControl.dataEntry.data
  local hasParentData = mouseOverControlParent and mouseOverControlParent.data
  local hasMocData = mouseOverControl and mouseOverControl.data

  if mocParentName == 'ZO_CraftBagListContents' or
    mocParentName == 'ZO_PlayerInventoryListContents' or
    mocParentName == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
    mocParentName == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
    mocParentName == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
    mocParentName == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
    mocParentName == 'ZO_QuickSlot_Keyboard_TopLevelListContents' or
    mocParentName == 'ZO_PlayerBankBackpackContents' or
    mocParentName == 'ZO_GuildBankBackpackContents' or
    mocParentName == 'ZO_HouseBankBackpackContents' or
    mocParentName == 'ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpackContents' or
    mocParentName == 'ZO_CompanionEquipment_Panel_KeyboardListContents' then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    itemLink = GetItemLink(rowData.bagId, rowData.slotIndex, LINK_STYLE_DEFAULT)

  elseif mocParentName == "ZO_FurnitureVaultListContents" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    local rowItemLink = GetItemLink(rowData.bagId, rowData.slotIndex, LINK_STYLE_DEFAULT)
    itemLink = TTCCompanion:CheckLevelAndSubType(rowItemLink)

  elseif mocOwnerName == "ZO_HousingFurniturePlacementPanel_KeyboardTopLevel" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    if rowData and rowData.bagId and rowData.slotIndex then
      itemLink = GetItemLink(rowData.bagId, rowData.slotIndex, LINK_STYLE_DEFAULT)
    end

  elseif mocParentName == "ZO_Character" then
    -- is worn item
    itemLink = GetItemLink(mouseOverControl.bagId, mouseOverControl.slotIndex, LINK_STYLE_DEFAULT)

  elseif mocParentName == "ZO_CompanionCharacterWindow_Keyboard_TopLevel" then
    -- is worn item
    itemLink = GetItemLink(mouseOverControl.bagId, mouseOverControl.slotIndex, LINK_STYLE_DEFAULT)

  elseif mocParentName == "ZO_LootAlphaContainerListContents" then
    -- is loot item
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    itemLink = GetLootItemLink(rowData.lootId, LINK_STYLE_DEFAULT)

  elseif mocParentName == "ZO_BuyBackListContents" then
    -- is buyback item
    itemLink = GetBuybackItemLink(mouseOverControl.index, LINK_STYLE_DEFAULT)

  elseif mocParentName == "ZO_StoreWindowListContents" then
    -- is store item
    local collectibleId = GetStoreCollectibleInfo(mouseOverControl.index)
    local isCollectible = collectibleId and collectibleId > 0
    if isCollectible then return end
    itemLink = GetStoreItemLink(mouseOverControl.index, LINK_STYLE_DEFAULT)

  elseif mocParentName == 'ZO_MailInboxMessageAttachments' then
    -- MAIL_INBOX:GetOpenMailId() is the id64 of the mail
    itemLink = GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), mouseOverControl.id, LINK_STYLE_DEFAULT)

  elseif mocParentName == 'ZO_MailSendAttachments' then
    itemLink = GetMailQueuedAttachmentLink(mouseOverControl.id, LINK_STYLE_DEFAULT)

    -- following 4 if's derived directly from MasterMerchant
  elseif mocOwnerName == 'MasterMerchantWindow' or
    mocOwnerName == 'MasterMerchantGuildWindow' or
    mocOwnerName == 'MasterMerchantPurchaseWindow' or
    mocOwnerName == 'MasterMerchantListingWindow' or
    mocOwnerName == 'MasterMerchantFilterByNameWindow' or
    mocOwnerName == 'MasterMerchantReportsWindow' then
    if mouseOverControl.GetText then
      itemLink = mouseOverControl:GetText()
    end

  elseif mocParentName == "IIFA_GUI_ListHolder" then
    if mouseOverControl.itemLink then
      itemLink = mouseOverControl.itemLink
    end

  elseif mocParentName == "FurCGui_ListHolder" then
    if mouseOverControl.itemLink then
      itemLink = TTCCompanion:CheckLevelAndSubType(mouseOverControl.itemLink)
    end

  elseif mocParentName == "ZO_TradingHouseBrowseItemsRightPaneSearchResultsContents" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    if not rowData or rowData.timeRemaining == 0 then return end
    purchasePrice = rowData.purchasePrice
    stackCount = rowData.stackCount
    itemLink = GetTradingHouseSearchResultItemLink(rowData.slotIndex, LINK_STYLE_DEFAULT)

  elseif mocParentName == "ZO_TradingHousePostedItemsListContents" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    if not rowData or rowData.timeRemaining == 0 then return end
    purchasePrice = rowData.purchasePrice
    stackCount = rowData.stackCount
    itemLink = GetTradingHouseListingItemLink(rowData.slotIndex, LINK_STYLE_DEFAULT)

  elseif mocParentName == 'DolgubonSetCrafterWindowMaterialListListContents' then
    if not hasMocData then return end
    local rowData = mouseOverControl.data[1]
    if not rowData then return end
    itemLink = rowData.Name

  elseif mocGPName == "CraftingQueueScrollListContents" then
    if not hasParentData then return end
    local rowData = mouseOverControlParent.data[1]
    local rowDataLink = rowData.Link
    if not rowDataLink then return end
    itemLink = TTCCompanion:SetCrafted(rowDataLink)

  elseif mocParentName == "ZO_InteractWindowRewardArea" then
    -- is reward item
    itemLink = GetQuestRewardItemLink(mouseOverControl.index, LINK_STYLE_DEFAULT)

  elseif mocOwnerName == 'CraftStoreFixed_Cook' or
    mocOwnerName == 'CraftStoreFixed_Rune' or
    mocOwnerName == 'CraftStoreFixed_Blueprint_Window' then
    if not hasMocData then return end
    local rowData = mouseOverControl.data
    itemLink = rowData.link

  elseif mocOwnerName == 'ZO_ClaimLevelUpRewardsScreen_Keyboard' then
    if not hasMocData then return end
    local rowData = mouseOverControl.data
    itemLink = rowData.itemLink
  end

  if itemLink then
    if TTCCompanion.tippingControl ~= mouseOverControl then
      if ItemTooltip.tooltipTextPool then
        ItemTooltip.tooltipTextPool:ReleaseAllObjects()
      end

      ItemTooltip.warnText = nil
      ItemTooltip.vendorWarnText = nil
      ItemTooltip.mmMatText = nil
    end

    TTCCompanion.tippingControl = mouseOverControl
    TTCCompanion:GenerateTooltip(ItemTooltip, itemLink, purchasePrice, stackCount)
  end

end

function TTCCompanion:initSellingAdvice()
  if TTCCompanion.originalSellingSetupCallback then return end

  if TRADING_HOUSE and TRADING_HOUSE.postedItemsList then

    local dataType = TRADING_HOUSE.postedItemsList.dataTypes[2]

    TTCCompanion.originalSellingSetupCallback = dataType.setupCallback
    if TTCCompanion.originalSellingSetupCallback then
      dataType.setupCallback = function(...)
        local row, data = ...
        TTCCompanion.originalSellingSetupCallback(...)
        zo_callLater(function() TTCCompanion.AddSellingAdvice(row, data) end, 1)
      end
    else
      TTCCompanion:dm("Warn", GetString(TTCC_ADVICE_ERROR))
    end
  end

  if TRADING_HOUSE_GAMEPAD then
  end
end

function TTCCompanion.AddSellingAdvice(rowControl, result)
  if not TTCCompanion.isInitialized then return end
  local sellingAdvice = rowControl:GetNamedChild('SellingAdvice')
  if (not sellingAdvice) then
    local controlName = rowControl:GetName() .. 'SellingAdvice'
    sellingAdvice = rowControl:CreateControl(controlName, CT_LABEL)

    local anchorControl = rowControl:GetNamedChild('TimeRemaining')
    local _, point, relTo, relPoint, offsX, offsY = anchorControl:GetAnchor(0)
    anchorControl:ClearAnchors()
    anchorControl:SetAnchor(point, relTo, relPoint, offsX, offsY - 10)

    sellingAdvice:SetAnchor(TOPLEFT, anchorControl, BOTTOMLEFT, 0, 0)
    local fontString = LMP:Fetch('font', "Univers 67")
    sellingAdvice:SetFont(fontString .. '|14|soft-shadow-thin')
  end

  --[[TODO make sure that the itemLink is not an empty string by mistake
  ]]--
  local itemLink = GetTradingHouseListingItemLink(result.slotIndex)
  if itemLink and itemLink ~= "" then
    local dealValue, margin, profit = TTCCompanion.GetDealInformation(itemLink, result.purchasePrice, result.stackCount)
    if dealValue then
      if dealValue > TTCC_DEAL_VALUE_DONT_SHOW then
        if TTCCompanion.savedVariables.showProfitMargin then
          sellingAdvice:SetText(TTCCompanion.LocalizedNumber(profit) .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')
        else
          sellingAdvice:SetText(string.format('%.2f', margin) .. '%')
        end
        -- TODO I think this colors the number in the guild store
        --[[
        ZO_Currency_FormatPlatform(CURT_MONEY, tonumber(stringPrice), ZO_CURRENCY_FORMAT_AMOUNT_ICON, {color: someColorDef})
        ]]--
        local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, dealValue)
        if dealValue == TTCC_DEAL_VALUE_OVERPRICED then
          r = 0.98;
          g = 0.01;
          b = 0.01;
        end
        sellingAdvice:SetColor(r, g, b, 1)
        sellingAdvice:SetHidden(false)
      else
        sellingAdvice:SetHidden(true)
      end
    else
      sellingAdvice:SetHidden(true)
    end
  end
  sellingAdvice = nil
end

function TTCCompanion:initBuyingAdvice()
  --[[Keyboard Mode has a TRADING_HOUSE.searchResultsList
  that is set to
  ZO_TradingHouseBrowseItemsRightPaneSearchResults and
  then from there, there is a
  dataTypes[1].dataType.setupCallback.

  This does not exist in GamepadMode
  ]]--
  if TTCCompanion.originalSetupCallback then return end
  if TRADING_HOUSE and TRADING_HOUSE.searchResultsList then

    local dataType = TRADING_HOUSE.searchResultsList.dataTypes[1]

    TTCCompanion.originalSetupCallback = dataType.setupCallback
    if TTCCompanion.originalSetupCallback then
      dataType.setupCallback = function(...)
        local row, data = ...
        TTCCompanion.originalSetupCallback(...)
        zo_callLater(function() TTCCompanion.AddBuyingAdvice(row, data) end, 1)
      end
    else
      TTCCompanion:dm("Warn", GetString(TTCC_ADVICE_ERROR))
    end
  end

  if TRADING_HOUSE_GAMEPAD then
  end
end

--[[ TODO update this for the colors and the value so that when there
isn't any buying advice then it is blank or 0
]]--
function TTCCompanion.AddBuyingAdvice(rowControl, result)
  if not TTCCompanion.isInitialized then return end
  local buyingAdvice = rowControl:GetNamedChild('BuyingAdvice')
  if (not buyingAdvice) then
    local controlName = rowControl:GetName() .. 'BuyingAdvice'
    buyingAdvice = rowControl:CreateControl(controlName, CT_LABEL)

    if (not AwesomeGuildStore) then
      local anchorControl = rowControl:GetNamedChild('SellPricePerUnit')
      local _, point, relTo, relPoint, offsX, offsY = anchorControl:GetAnchor(0)
      anchorControl:ClearAnchors()
      anchorControl:SetAnchor(point, relTo, relPoint, offsX, offsY + 10)
    end

    local anchorControl = rowControl:GetNamedChild('TimeRemaining')
    local _, point, relTo, relPoint, offsX, offsY = anchorControl:GetAnchor(0)
    anchorControl:ClearAnchors()
    anchorControl:SetAnchor(point, relTo, relPoint, offsX, offsY - 10)
    buyingAdvice:SetAnchor(TOPLEFT, anchorControl, BOTTOMLEFT, 0, 0)
    local fontString = LMP:Fetch('font', "Univers 67")
    buyingAdvice:SetFont(fontString .. '|14|soft-shadow-thin')
  end

  local index = result.slotIndex
  if (AwesomeGuildStore) then index = result.itemUniqueId end
  local itemLink = GetTradingHouseSearchResultItemLink(index)
  local dealValue, margin, profit = TTCCompanion.GetDealInformation(itemLink, result.purchasePrice, result.stackCount)
  if dealValue then
    if dealValue > TTCC_DEAL_VALUE_DONT_SHOW then
      if TTCCompanion.savedVariables.showProfitMargin then
        buyingAdvice:SetText(TTCCompanion.LocalizedNumber(profit) .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')
      else
        buyingAdvice:SetText(string.format('%.2f', margin) .. '%')
      end
      -- TODO I think this colors the number in the guild store
      local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, dealValue)
      if dealValue == TTCC_DEAL_VALUE_OVERPRICED then
        r = 0.98;
        g = 0.01;
        b = 0.01;
      end
      buyingAdvice:SetColor(r, g, b, 1)
      buyingAdvice:SetHidden(false)
    else
      buyingAdvice:SetHidden(true)
    end
  else
    buyingAdvice:SetHidden(true)
  end
  buyingAdvice = nil
end

function TTCCompanion.LocalizedNumber(amount)
  local function comma_value(amount)
    local formatted = amount
    local count
    while true do
      formatted, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1' .. GetString(TTCC_THOUSANDS_SEP) .. '%2')
      if (count == 0) then
        break
      end
    end
    return formatted
  end

  if not amount then
    return tostring(0)
  end

  -- Round to two decimal values
  return comma_value(zo_roundToNearest(amount, .01))
end

function TTCCompanion:GetTamrielTradeCentrePriceToUse(itemLink)
  local priceStats = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
  local ttcPrice
  if TTCCompanion.savedVariables.dealCalcToUse == TTCCompanion.USE_TTC_SUGGESTED then
    if priceStats and priceStats.SuggestedPrice then ttcPrice = priceStats.SuggestedPrice end
    if ttcPrice and TTCCompanion.savedVariables.modifiedSuggestedPriceDealCalc then
      ttcPrice = ttcPrice * 1.25
    end
  elseif TTCCompanion.savedVariables.dealCalcToUse == TTCCompanion.USE_TTC_AVERAGE then
    if priceStats and priceStats.Avg then ttcPrice = priceStats.Avg end
  elseif TTCCompanion.savedVariables.dealCalcToUse == TTCCompanion.USE_TTC_SALES then
    if priceStats and priceStats.SaleAvg then ttcPrice = priceStats.SaleAvg end
  end
  return ttcPrice
end

TTCCompanion.dealCalcChoices = {
  GetString(TTCC_DEAL_CALC_TTC_SUGGESTED),
  GetString(TTCC_DEAL_CALC_TTC_AVERAGE),
  GetString(TTCC_DEAL_CALC_TTC_SALES),
}
TTCCompanion.dealCalcValues = {
  TTCCompanion.USE_TTC_SUGGESTED,
  TTCCompanion.USE_TTC_AVERAGE,
  TTCCompanion.USE_TTC_SALES,
}
TTCCompanion.agsPercentSortChoices = {
  GetString(AGS_PERCENT_ORDER_ASCENDING),
  GetString(AGS_PERCENT_ORDER_DESCENDING),
}
TTCCompanion.agsPercentSortValues = {
  TTCCompanion.AGS_PERCENT_ASCENDING,
  TTCCompanion.AGS_PERCENT_DESCENDING,
}

local function CheckDealCalcValue()
  if TTCCompanion.savedVariables.dealCalcToUse ~= TTCCompanion.USE_TTC_SUGGESTED then
    TTCCompanion.savedVariables.modifiedSuggestedPriceDealCalc = false
  end
end

local function CheckInventoryValue()
  if TTCCompanion.savedVariables.replacementTypeToUse ~= TTCCompanion.USE_TTC_SUGGESTED then
    TTCCompanion.savedVariables.modifiedSuggestedPriceInventory = false
  end
end

-- LibAddon init code
function TTCCompanion:LibAddonInit()
  TTCCompanion:dm("Debug", "TTCCompanion LibAddonInit")
  local panelData = {
    type = 'panel',
    name = 'TTCCompanion',
    displayName = "Tamriel Trade Centre Companion",
    author = "|cFF9B15Sharlikran|r",
    version = TTCCompanion.version,
    website = "https://www.esoui.com/downloads/info3509-TamrielTradeCentreCompanion.html",
    feedback = "https://www.esoui.com/downloads/info3509-TamrielTradeCentreCompanion.html",
    donation = "https://sharlikran.github.io/",
    registerForRefresh = true,
    registerForDefaults = true,
  }
  LAM:RegisterAddonPanel('TTCCompanionOptions', panelData)

  local optionsData = {}
  -- Custom Deal Calc
  optionsData[#optionsData + 1] = {
    type = 'submenu',
    name = GetString(TTCC_DEALCALC_OPTIONS_NAME),
    tooltip = GetString(TTCC_DEALCALC_OPTIONS_TIP),
    controls = {
      -- Enable DealCalc
      [1] = {
        type = 'checkbox',
        name = GetString(TTCC_DEALCALC_ENABLE_NAME),
        tooltip = GetString(TTCC_DEALCALC_ENABLE_TIP),
        getFunc = function() return TTCCompanion.savedVariables.customDealCalc end,
        setFunc = function(value) TTCCompanion.savedVariables.customDealCalc = value end,
        default = TTCCompanion.systemDefault.customDealCalc,
      },
      -- custom customDealBuyIt
      [2] = {
        type = 'slider',
        name = GetString(TTCC_DEALCALC_BUYIT_NAME),
        tooltip = GetString(TTCC_DEALCALC_BUYIT_TIP),
        min = 0,
        max = 100,
        getFunc = function() return TTCCompanion.savedVariables.customDealBuyIt end,
        setFunc = function(value) TTCCompanion.savedVariables.customDealBuyIt = value end,
        default = TTCCompanion.systemDefault.customDealBuyIt,
        disabled = function() return not TTCCompanion.savedVariables.customDealCalc end,
      },
      -- customDealSeventyFive
      [3] = {
        type = 'slider',
        name = GetString(TTCC_DEALCALC_SEVENTYFIVE_NAME),
        tooltip = GetString(TTCC_DEALCALC_SEVENTYFIVE_TIP),
        min = 0,
        max = 100,
        getFunc = function() return TTCCompanion.savedVariables.customDealSeventyFive end,
        setFunc = function(value) TTCCompanion.savedVariables.customDealSeventyFive = value end,
        default = TTCCompanion.systemDefault.customDealSeventyFive,
        disabled = function() return not TTCCompanion.savedVariables.customDealCalc end,
      },
      -- customDealFifty
      [4] = {
        type = 'slider',
        name = GetString(TTCC_DEALCALC_FIFTY_NAME),
        tooltip = GetString(TTCC_DEALCALC_FIFTY_TIP),
        min = 0,
        max = 100,
        getFunc = function() return TTCCompanion.savedVariables.customDealFifty end,
        setFunc = function(value) TTCCompanion.savedVariables.customDealFifty = value end,
        default = TTCCompanion.systemDefault.customDealFifty,
        disabled = function() return not TTCCompanion.savedVariables.customDealCalc end,
      },
      -- customDealTwentyFive
      [5] = {
        type = 'slider',
        name = GetString(TTCC_DEALCALC_TWENTYFIVE_NAME),
        tooltip = GetString(TTCC_DEALCALC_TWENTYFIVE_TIP),
        min = 0,
        max = 100,
        getFunc = function() return TTCCompanion.savedVariables.customDealTwentyFive end,
        setFunc = function(value) TTCCompanion.savedVariables.customDealTwentyFive = value end,
        default = TTCCompanion.systemDefault.customDealTwentyFive,
        disabled = function() return not TTCCompanion.savedVariables.customDealCalc end,
      },
      -- customDealZero
      [6] = {
        type = 'slider',
        name = GetString(TTCC_DEALCALC_ZERO_NAME),
        tooltip = GetString(TTCC_DEALCALC_ZERO_TIP),
        min = 0,
        max = 100,
        getFunc = function() return TTCCompanion.savedVariables.customDealZero end,
        setFunc = function(value) TTCCompanion.savedVariables.customDealZero = value end,
        default = TTCCompanion.systemDefault.customDealZero,
        disabled = function() return not TTCCompanion.savedVariables.customDealCalc end,
      },
      [7] = {
        type = "description",
        text = GetString(TTCC_DEALCALC_OKAY_TEXT),
      },
    },
  }
  -- Deal Filter Price
  optionsData[#optionsData + 1] = {
    type = 'dropdown',
    name = GetString(TTCC_DEAL_CALC_TYPE_NAME),
    tooltip = GetString(TTCC_DEAL_CALC_TYPE_TIP),
    choices = TTCCompanion.dealCalcChoices,
    choicesValues = TTCCompanion.dealCalcValues,
    getFunc = function() return TTCCompanion.savedVariables.dealCalcToUse end,
    setFunc = function(value)
      TTCCompanion.savedVariables.dealCalcToUse = value
      ZO_ClearTable(TTCCompanion.dealInfoCache)
      CheckDealCalcValue()
    end,
    default = TTCCompanion.systemDefault.dealCalcToUse,
  }
  optionsData[#optionsData + 1] = {
    type = 'checkbox',
    name = GetString(TTCC_DEALCALC_MODIFIEDTTC_NAME),
    tooltip = GetString(TTCC_DEALCALC_MODIFIEDTTC_TIP),
    getFunc = function() return TTCCompanion.savedVariables.modifiedSuggestedPriceDealCalc end,
    setFunc = function(value) TTCCompanion.savedVariables.modifiedSuggestedPriceDealCalc = value end,
    default = TTCCompanion.systemDefault.modifiedSuggestedPriceDealCalc,
    disabled = function() return not (TTCCompanion.savedVariables.dealCalcToUse == TTCCompanion.USE_TTC_SUGGESTED) end,
  }
  -- ascending vs descending sort order with AGS
  optionsData[#optionsData + 1] = {
    type = 'dropdown',
    name = GetString(AGS_PERCENT_ORDER_NAME),
    tooltip = GetString(AGS_PERCENT_ORDER_DESC),
    choices = TTCCompanion.agsPercentSortChoices,
    choicesValues = TTCCompanion.agsPercentSortValues,
    getFunc = function() return TTCCompanion.savedVariables.agsPercentSortOrderToUse end,
    setFunc = function(value) TTCCompanion.savedVariables.agsPercentSortOrderToUse = value end,
    default = TTCCompanion.savedVariables.agsPercentSortOrderToUse,
    disabled = function() return not TTCCompanion.AwesomeGuildStoreDetected end,
  }
  -- Whether or not to show the material cost data in tooltips
  optionsData[#optionsData + 1] = {
    type = 'checkbox',
    name = GetString(TTCC_SHOW_MATERIAL_COST_NAME),
    tooltip = GetString(TTCC_SHOW_MATERIAL_COST_TIP),
    getFunc = function() return TTCCompanion.savedVariables.showMaterialCost end,
    setFunc = function(value) TTCCompanion.savedVariables.showMaterialCost = value end,
    default = TTCCompanion.systemDefault.showMaterialCost,
  }
  -- Should we show the stack price calculator in the Vanilla UI?
  optionsData[#optionsData + 1] = {
    type = 'checkbox',
    name = GetString(TTCC_CALC_NAME),
    tooltip = GetString(TTCC_CALC_TIP),
    getFunc = function() return TTCCompanion.savedVariables.showCalc end,
    setFunc = function(value) TTCCompanion.savedVariables.showCalc = value end,
    default = TTCCompanion.savedVariables.showCalc,
    disabled = function() return TTCCompanion.AwesomeGuildStoreDetected end,
  }
  -- Section: Inventory Options
  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(TTCC_INVENTORY_OPTIONS),
    width = "full",
  }
  -- should we replace inventory values?
  optionsData[#optionsData + 1] = {
    type = 'checkbox',
    name = GetString(TTCC_REPLACE_INVENTORY_VALUES_NAME),
    tooltip = GetString(TTCC_REPLACE_INVENTORY_VALUES_TIP),
    getFunc = function() return TTCCompanion.savedVariables.replaceInventoryValues end,
    setFunc = function(value) TTCCompanion.savedVariables.replaceInventoryValues = value end,
    default = TTCCompanion.systemDefault.replaceInventoryValues,
  }
  optionsData[#optionsData + 1] = {
    type = 'checkbox',
    name = GetString(TTCC_REPLACE_INVENTORY_SHOW_UNITPRICE_NAME),
    tooltip = GetString(TTCC_REPLACE_INVENTORY_SHOW_UNITPRICE_TIP),
    getFunc = function() return TTCCompanion.savedVariables.showUnitPrice end,
    setFunc = function(value) TTCCompanion.savedVariables.showUnitPrice = value end,
    default = TTCCompanion.systemDefault.showUnitPrice,
    disabled = function() return not TTCCompanion.savedVariables.replaceInventoryValues end,
  }
  -- replace inventory value type
  optionsData[#optionsData + 1] = {
    type = 'dropdown',
    name = GetString(TTCC_REPLACE_INVENTORY_VALUE_TYPE_NAME),
    tooltip = GetString(TTCC_REPLACE_INVENTORY_VALUE_TYPE_TIP),
    choices = TTCCompanion.dealCalcChoices,
    choicesValues = TTCCompanion.dealCalcValues,
    getFunc = function() return TTCCompanion.savedVariables.replacementTypeToUse end,
    setFunc = function(value)
      TTCCompanion.savedVariables.replacementTypeToUse = value
      CheckInventoryValue()
    end,
    default = TTCCompanion.systemDefault.replacementTypeToUse,
    disabled = function() return not TTCCompanion.savedVariables.replaceInventoryValues end,
  }
  optionsData[#optionsData + 1] = {
    type = 'checkbox',
    name = GetString(TTCC_REPLACE_INVENTORY_MODIFIEDTTC_NAME),
    tooltip = GetString(TTCC_REPLACE_INVENTORY_MODIFIEDTTC_TIP),
    getFunc = function() return TTCCompanion.savedVariables.modifiedSuggestedPriceInventory end,
    setFunc = function(value) TTCCompanion.savedVariables.modifiedSuggestedPriceInventory = value end,
    default = TTCCompanion.systemDefault.modifiedSuggestedPriceInventory,
    disabled = function() return (not TTCCompanion.savedVariables.replaceInventoryValues) or (TTCCompanion.savedVariables.replacementTypeToUse ~= TTCCompanion.USE_TTC_SUGGESTED) end,
  }

  -- And make the options panel
  LAM:RegisterOptionControls('TTCCompanionOptions', optionsData)
end

function TTCCompanion.GetPricingData(itemLink)
  local theIID = GetItemLinkItemId(itemLink)
  local itemIndex = TTCCompanion.GetOrCreateIndexFromLink(itemLink)
  local selectedGuildId = GetSelectedTradingHouseGuildId()
  local pricingData = TTCCompanion.savedVariables[TTCCompanion.pricingNamespace] and TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][selectedGuildId] and TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][selectedGuildId][theIID] and TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][selectedGuildId][theIID][itemIndex] or nil
  return pricingData
end

function TTCCompanion.SetupPendingPost(self)
  OriginalSetupPendingPost(self)

  if (self.pendingItemSlot) then
    local itemLink = GetItemLink(BAG_BACKPACK, self.pendingItemSlot)
    local _, stackCount, _ = GetItemInfo(BAG_BACKPACK, self.pendingItemSlot)
    local pricingData = TTCCompanion.GetPricingData(itemLink)

    if pricingData then
      self:SetPendingPostPrice(math.floor(pricingData * stackCount))
    else
      local ttcPrice = TTCCompanion:GetTamrielTradeCentrePriceToUse(itemLink)
      if ttcPrice then
        self:SetPendingPostPrice(math.floor(ttcPrice * stackCount))
      end
    end
  end
end

function TTCCompanion.PostPendingItem(self)
  if self.pendingItemSlot and self.pendingSaleIsValid then
    local itemLink = GetItemLink(BAG_BACKPACK, self.pendingItemSlot)
    local _, stackCount, _ = GetItemInfo(BAG_BACKPACK, self.pendingItemSlot)

    local theIID = GetItemLinkItemId(itemLink)
    local itemIndex = TTCCompanion.GetOrCreateIndexFromLink(itemLink)
    local guildId, _ = GetCurrentTradingHouseGuildDetails()

    TTCCompanion.savedVariables[TTCCompanion.pricingNamespace] = TTCCompanion.savedVariables[TTCCompanion.pricingNamespace] or {}
    TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][guildId] = TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][guildId] or {}
    TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][guildId][theIID] = TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][guildId][theIID] or {}
    TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][guildId][theIID][itemIndex] = self.invoiceSellPrice.sellPrice / stackCount

  end
end

function TTCCompanion:updateCalc()
  local stackSize = zo_strmatch(TTCCompanionPriceCalculatorStack:GetText(), 'x (%d+)')
  local unitPrice = TTCCompanionPriceCalculatorUnitCostAmount:GetText()
  if not stackSize or tonumber(stackSize) < 1 then
    TTCCompanion:dm("Info", string.format("%s is not a valid stack size", stackSize))
    return
  end
  if not unitPrice or tonumber(unitPrice) < 0.01 then
    TTCCompanion:dm("Info", string.format("%s is not a valid unit price", unitPrice))
    return
  end
  local totalPrice = math.floor(tonumber(unitPrice) * tonumber(stackSize))
  TTCCompanionPriceCalculatorTotal:SetText(GetString(TTCC_TOTAL_TITLE) .. TTCCompanion.LocalizedNumber(totalPrice) .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')
  TRADING_HOUSE:SetPendingPostPrice(totalPrice)
end

function TTCCompanion:SetupPriceCalculator()
  TTCCompanion:dm("Debug", "SetupPriceCalculator")
  local ttccCalc = CreateControlFromVirtual('TTCCompanionPriceCalculator', ZO_TradingHousePostItemPane, 'TTCCompanionPriceCalc')
  ttccCalc:SetAnchor(BOTTOM, ZO_TradingHouseBrowseItemsLeftPane, BOTTOM, 0, -4)
end

local function SetNamespace()
  TTCCompanion:dm("Debug", "SetNamespace")
  if GetWorldName() == 'NA Megaserver' then
    TTCCompanion.pricingNamespace = TTCCompanion.NA_PRICING_NAMESPACE
  else
    TTCCompanion.pricingNamespace = TTCCompanion.EU_PRICING_NAMESPACE
  end
end

function TTCCompanion:Initialize()
  TTCCompanion:dm("Debug", "TTCCompanion Initialize")
  local systemDefault = {
    dealCalcToUse = TTCCompanion.USE_TTC_AVERAGE,
    agsPercentSortOrderToUse = TTCCompanion.AGS_PERCENT_ASCENDING,
    customDealCalc = false,
    customDealBuyIt = 90,
    customDealSeventyFive = 75,
    customDealFifty = 50,
    customDealTwentyFive = 25,
    customDealZero = 0,
    modifiedSuggestedPriceDealCalc = false,
    showMaterialCost = true,
    showCraftCost = false,
    showProfitMargin = false,
    showCalc = false,
    pricingData = {},
    pricingdatana = {},
    pricingdataeu = {},
    replaceInventoryValues = false,
    replacementTypeToUse = TTCCompanion.USE_TTC_SUGGESTED,
    modifiedSuggestedPriceInventory = false,
    showUnitPrice = false,
  }
  TTCCompanion.systemDefault = systemDefault

  TTCCompanion.savedVariables = ZO_SavedVars:NewAccountWide('TTCCompanion_SavedVars', 1, nil, systemDefault, nil)

  TRADING_HOUSE_SCENE:RegisterCallback("StateChange", function(oldState, newState)
    --TTCCompanion:dm("Debug", "On StateChange")
    if newState == SCENE_SHOWING then
      TTCCompanion.tradingHouseOpened = true
    elseif newState == SCENE_HIDDEN then
      TTCCompanion.tradingHouseOpened = false
    end
  end)

  SetNamespace()
  TTCCompanion:SetupPriceCalculator()
  TTCCompanion:BuildRemovedItemIdTable()
  TTCCompanion:LibAddonInit()
  TTCCompanion:InitializeHooks()

  --Watch inventory listings
  ZO_SharedInventoryManager.CreateOrUpdateSlotData = TTCCompanion.CreateOrUpdateSlotData
  for _, i in pairs(PLAYER_INVENTORY.inventories) do
    local listView = i.listView
    if listView and listView.dataTypes and listView.dataTypes[1] then
      local originalCall = listView.dataTypes[1].setupCallback

      listView.dataTypes[1].setupCallback = function(rowControl, slot)
        originalCall(rowControl, slot)
        TTCCompanion:SetInventorySellPriceText(rowControl, slot)
      end
    end
  end

  -- Watch Decon lists
  local backpacks = {
    ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
    ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack,
  }
  for i = 1, #backpacks do
    local oldCallback = backpacks[i].dataTypes[1].setupCallback

    backpacks[i].dataTypes[1].setupCallback = function(rowControl, slot)
      oldCallback(rowControl, slot)
      TTCCompanion:SetInventorySellPriceText(rowControl, slot)
    end
  end

  if not AwesomeGuildStore then
    EVENT_MANAGER:RegisterForEvent(TTCCompanion.name, EVENT_TRADING_HOUSE_PENDING_ITEM_UPDATE,
      function(eventCode, slotId, isPending)
        if TTCCompanion.savedVariables.showCalc and isPending and GetSlotStackSize(BAG_BACKPACK, slotId) > 1 then
          local theLink = GetItemLink(BAG_BACKPACK, slotId, LINK_STYLE_DEFAULT)
          local priceData = nil
          priceData = TTCCompanion.GetPricingData(theLink)
          if not priceData then
            priceData = TTCCompanion:GetTamrielTradeCentrePriceToUse(theLink)
          end
          local floorPrice = 0
          if priceData then floorPrice = string.format('%.2f', priceData) end

          TTCCompanionPriceCalculatorStack:SetText(GetString(TTCC_APP_TEXT_TIMES) .. GetSlotStackSize(1, slotId))
          TTCCompanionPriceCalculatorUnitCostAmount:SetText(floorPrice)
          TTCCompanionPriceCalculatorTotal:SetText(GetString(TTCC_TOTAL_TITLE) .. TTCCompanion.LocalizedNumber(math.floor(floorPrice * GetSlotStackSize(1, slotId))) .. ' |t16:16:EsoUI/Art/currency/currency_gold.dds|t')
          TTCCompanionPriceCalculator:SetHidden(false)
        else TTCCompanionPriceCalculator:SetHidden(true) end
      end)
  end

  if AwesomeGuildStore then
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.GUILD_SELECTION_CHANGED,
      function(guildData)
        local selectedGuildId = GetSelectedTradingHouseGuildId()
        TTCCompanion.savedVariables.pricingData = TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][selectedGuildId] or {}
      end)
  end

  EVENT_MANAGER:RegisterForEvent(TTCCompanion.name, EVENT_CLOSE_TRADING_HOUSE, function()
    ZO_ClearTable(TTCCompanion.dealInfoCache)
  end)

  EVENT_MANAGER:RegisterForEvent(TTCCompanion.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, function(_, responseType, result)
    if responseType == TRADING_HOUSE_RESULT_POST_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS then TTCCompanionPriceCalculator:SetHidden(true) end
    -- Set up guild store buying advice
    TTCCompanion:initBuyingAdvice()
    TTCCompanion:initSellingAdvice()
  end)

  -- We'll add stats to tooltips for items we have data for, if desired
  ZO_PreHookHandler(PopupTooltip, 'OnUpdate', function() TTCCompanion:GeneratePopupTooltip(PopupTooltip) end)
  ZO_PreHookHandler(PopupTooltip, 'OnHide', function() TTCCompanion:RemovePopupTooltip(PopupTooltip) end)
  ZO_PreHookHandler(ItemTooltip, 'OnUpdate', function() TTCCompanion:GenerateItemTooltip() end)
  ZO_PreHookHandler(ItemTooltip, 'OnHide', function() TTCCompanion:RemoveItemTooltip() end)

  --[[ This is to save the sale price however AGS has its own routines and uses
  its value first so this is usually not seen, although it does save NA and EU
  separately
  ]]--
  if AwesomeGuildStore then
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.ITEM_POSTED,
      function(guildId, itemLink, price, stackCount)
        local theIID = GetItemLinkItemId(itemLink)
        local itemIndex = TTCCompanion.GetOrCreateIndexFromLink(itemLink)
        local selectedGuildId = GetSelectedTradingHouseGuildId()

        TTCCompanion.savedVariables[TTCCompanion.pricingNamespace] = TTCCompanion.savedVariables[TTCCompanion.pricingNamespace] or {}
        TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][selectedGuildId] = TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][selectedGuildId] or {}
        TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][selectedGuildId][theIID] = TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][selectedGuildId][theIID] or {}
        TTCCompanion.savedVariables[TTCCompanion.pricingNamespace][selectedGuildId][theIID][itemIndex] = price / stackCount

      end)
  else
    if TRADING_HOUSE then
      OriginalSetupPendingPost = TRADING_HOUSE.SetupPendingPost
      TRADING_HOUSE.SetupPendingPost = TTCCompanion.SetupPendingPost
      ZO_PreHook(TRADING_HOUSE, 'PostPendingItem', TTCCompanion.PostPendingItem)
    end
  end

  TTCCompanion.isInitialized = true
end

local function OnAddOnLoaded(eventCode, addOnName)
  if addOnName:find('^ZO_') then return end
  if addOnName == "MasterMerchant" then
    TTCCompanion:dm("Info", "MasterMerchant detected")
    return
  end
  if addOnName == TTCCompanion.addonName and addOnName ~= "MasterMerchant" then
    TTCCompanion:dm("Debug", "TTCCompanion Loaded")
    TTCCompanion:Initialize()
  elseif addOnName == "AwesomeGuildStore" and addOnName ~= "MasterMerchant" then
    -- Set up AGS integration, if it's installed
    TTCCompanion:initAGSIntegration()
  elseif addOnName == "WritWorthy" and addOnName ~= "MasterMerchant" then
    if WritWorthy and WritWorthy.CreateParser then TTCCompanion.wwDetected = true end
  elseif addOnName == "MasterWritInventoryMarker" and addOnName ~= "MasterMerchant" then
    if MWIM_SavedVariables then TTCCompanion.mwimDetected = true end
  end

end
EVENT_MANAGER:RegisterForEvent(TTCCompanion.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

