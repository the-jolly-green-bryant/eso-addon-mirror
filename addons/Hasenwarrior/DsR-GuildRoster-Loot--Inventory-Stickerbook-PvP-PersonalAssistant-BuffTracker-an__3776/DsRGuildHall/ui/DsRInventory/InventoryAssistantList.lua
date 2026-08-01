-----------------------------------------------------------------------------------------------------------------------------------
-- CONSTANTS
-----------------------------------------------------------------------------------------------------------------------------------
local IA_GENERIC_ROW = 1
local IA_HEADER_ROW  = 2
local IA_ITEM_ROW    = 3
-----------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY ASSISTANT SCROLLING ITEM LIST
-----------------------------------------------------------------------------------------------------------------------------------
IA_InventoryAssistantList = ZO_SortFilterList:Subclass ( )
-----------------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:New ( frame, control )
	local inventoryAssistantList = ZO_SortFilterList.New ( self, control )
	inventoryAssistantList:Setup ( frame, control )
	return inventoryAssistantList
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:Setup ( frame, control )
  self.frame = frame
	ZO_ScrollList_AddDataType ( self.list, IA_GENERIC_ROW, "IA_GenericRow", 30, function ( control, data ) self:SetupGenericRow ( control, data ) end )
	ZO_ScrollList_AddDataType ( self.list, IA_HEADER_ROW, "IA_HeaderRow", 40, function ( control, data ) self:SetupHeaderRow ( control, data ) end )
	ZO_ScrollList_AddDataType ( self.list, IA_ITEM_ROW, "IA_ItemRow", 30, function ( control, data ) self:SetupItemRow ( control, data ) end )
	ZO_ScrollList_EnableHighlight ( self.list, "ZO_ThinListHighlight" )
	self:SetAlternateRowBackgrounds ( true )
  self:Reset ( )
  self:RefreshData ( )
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:SetupGenericRow ( control, data )
  control.list = self
	control.data = data
	control:GetNamedChild ( "Name" ).normalColor = ZO_DEFAULT_TEXT
  control:GetNamedChild ( "Name" ):SetText ( data.text )
	ZO_SortFilterList.SetupRow ( self, control, data )
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:SetupHeaderRow ( control, data )
  control.list = self
	control.data = data
	control:GetNamedChild ( "Name" ).normalColor = data.header.color 
  if data.header.itemCount == data.header.showCount then 
    control:GetNamedChild ( "Name" ):SetText ( string.format ( data.header.text1, data.header.name, data.header.itemCount ) )
  else
    control:GetNamedChild ( "Name" ):SetText ( string.format ( data.header.text2, data.header.name, data.header.showCount, data.header.itemCount ) )
  end
  if data.icon then
    control:GetNamedChild ( "Icon" ):SetTexture( data.icon )
    control:GetNamedChild ( "Icon" ):SetHidden( false )
  else
    control:GetNamedChild ( "Icon" ):SetHidden( true )
    control:GetNamedChild ( "Icon" ):SetTexture( nil )
  end
	ZO_SortFilterList.SetupRow ( self, control, data )

end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:SetupItemRow ( control, data )
  control.list = self
	control.data = data
	control:GetNamedChild ( "Name" ).nonRecolorable = true
	control:GetNamedChild ( "Name" ):SetText ( data.name )

  control:GetNamedChild ( "Bag" ).nonRecolorable = true
	control:GetNamedChild ( "Bag" ):SetText( data.bagName )
  control:GetNamedChild ( "Bag" ):SetDimensionConstraints ( 0, 0, IA_InventoryAssistant.settings.bagNameWidth, 0 )
    
  control:GetNamedChild ( "Level" ).nonRecolorable = true
--	control:GetNamedChild ( "Level" ):SetText ( data.level )

  control:GetNamedChild ( "Marker" ).nonRecolorable = true
  control:GetNamedChild ( "Marker" ):SetHidden ( true )
  control:GetNamedChild ( "Marker" ):ClearIcons ( ) 
  data.item.markers = IA_INVENTORY_ASSISTANT:GetItemMarkers ( data.item.itemId, data.item.uniqueId, data.item.bagId, data.item.stolen )
  if data.item.markers and #data.item.markers > 0 then
    for _, v in ipairs ( data.item.markers ) do
      control:GetNamedChild ( "Marker" ):AddIcon ( v )
    end
    control:GetNamedChild ( "Marker" ):SetHidden ( false )
  end
  if data.icon then
    control:GetNamedChild ( "Icon" ):SetTexture ( data.icon )
    control:GetNamedChild ( "Icon" ):SetHidden ( false )
  else
    control:GetNamedChild ( "Icon" ):SetHidden ( true )
    control:GetNamedChild ( "Icon" ):SetTexture ( nil )
  end
  if data.item.bopTimeEnds and data.item.bopTimeEnds > GetTimeStamp ( ) then
    control:GetNamedChild ( "Tradeable" ):SetHidden ( false )
  else
    control:GetNamedChild ( "Tradeable" ):SetHidden ( true )
  end
  if data.item.locked then
    control:GetNamedChild ( "Marker" ):SetHidden ( true )
    if IA_InventoryAssistant.settings.actionQueue.unlock [ data.item.uniqueId ] then
      control:GetNamedChild ( "Marker" ):AddIcon ( { icon = ZO_KEYBOARD_LOCKED_ICON, color = { r=0.33, g=0.33, b=0.33, a=1 } } )
    else
      control:GetNamedChild ( "Marker" ):AddIcon ( { icon = ZO_KEYBOARD_LOCKED_ICON, color = { r=1, g=1, b=1, a=1 } } )
    end
    control:GetNamedChild ( "Marker" ):SetHidden ( false )
  elseif IA_InventoryAssistant.settings.actionQueue.lock [ data.item.uniqueId ] then 
    control:GetNamedChild ( "Marker" ):SetHidden ( true )
    control:GetNamedChild ( "Marker" ):AddIcon ( { icon = ZO_KEYBOARD_LOCKED_ICON, color = { r=0.33, g=0.33, b=0.33, a=1 } } )
    control:GetNamedChild ( "Marker" ):SetHidden ( false )
  end
	ZO_SortFilterList.SetupRow ( self, control, data )
end
-----------------------------------------------------------------------------------------------------------------------------------
-- LIST MANIPULATION
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:Reset ( )
	local scrollData = ZO_ScrollList_GetDataList ( self.list )
	ZO_ClearNumericallyIndexedTable ( scrollData )
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:AddText ( data )
	local scrollData = ZO_ScrollList_GetDataList ( self.list )
	table.insert ( scrollData, ZO_ScrollList_CreateDataEntry ( IA_GENERIC_ROW, data ) )
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:AddHeader ( header, icon, equipSlots )
	local scrollData = ZO_ScrollList_GetDataList ( self.list )
	data = { header = header, icon = icon, equipSlots = equipSlots }
	table.insert ( scrollData, ZO_ScrollList_CreateDataEntry ( IA_HEADER_ROW, data ) )
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:AddData ( text, item, icon, itemLink, level, bagName, itemId, uniqueId )
	local scrollData = ZO_ScrollList_GetDataList ( self.list )
	data = { item = item, name = text, icon = icon, itemLink = itemLink, level = level, bagName = bagName, itemId = itemId, uniqueId = uniqueId }
	table.insert ( scrollData, ZO_ScrollList_CreateDataEntry ( IA_ITEM_ROW, data ) )
end
-----------------------------------------------------------------------------------------------------------------------------------
-- FILTERING
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:DisableFilters ( )
  self.isFilteringEnabled = false
  self:RefreshFilters ( )
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:EnableFilters ( )
  self.isFilteringEnabled = true
  self:RefreshFilters ( )
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList:FilterScrollList ( )
  if self.isFilteringEnabled then 
    d( "FilterScrollList called" )
  end
end
-----------------------------------------------------------------------------------------------------------------------------------
-- EVENT HANDLERS
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList_OnMouseEnter ( control )
	control.list:Row_OnMouseEnter ( control )
  if control.data.itemLink then 
    InitializeTooltip ( ItemTooltip, control.list.frame, TOPLEFT, 0, 0, TOPRIGHT )
    ItemTooltip:SetLink_IA ( control.data.itemLink )
    if TamrielTradeCentrePrice then 
      if TamrielTradeCentrePrice:GetPriceInfo ( control.data.itemLink )  then
        TamrielTradeCentrePrice:AppendPriceInfo ( ItemTooltip, control.data.itemLink )
      end
    end
    if MasterMerchant then 
      MasterMerchant:addStatsAndGraph ( ItemTooltip, control.data.itemLink, false )
    end

  elseif control.data.equipSlots then
    InitializeTooltip ( IA_CharacterTooltip, control.list.frame, TOPLEFT, 0, 0, TOPRIGHT )
    
    IA_CharacterTooltipSilhuette:SetTexture ( GetUnitSilhouetteTexture ( "player" ) )
    IA_CharacterTooltipSilhuette:SetAlpha ( 0.5 )
    
    IA_CharacterTooltipHead:SetTexture ( control.data.equipSlots.headIcon )
    if control.data.equipSlots.head > 0 then
      IA_CharacterTooltipHead:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipHead:SetAlpha ( 1 )
    else
      IA_CharacterTooltipHead:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipHead:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipHeadCount:SetText ( control.data.equipSlots.head > 1 and control.data.equipSlots.head or "" )
    
    IA_CharacterTooltipShoulders:SetTexture ( control.data.equipSlots.shouldersIcon )
    if control.data.equipSlots.shoulders > 0 then
      IA_CharacterTooltipShoulders:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipShoulders:SetAlpha ( 1 )
    else
      IA_CharacterTooltipShoulders:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipShoulders:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipShouldersCount:SetText ( control.data.equipSlots.shoulders > 1 and control.data.equipSlots.shoulders or "" )
    
    IA_CharacterTooltipHands:SetTexture ( control.data.equipSlots.handsIcon )
    if control.data.equipSlots.hands > 0 then
      IA_CharacterTooltipHands:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipHands:SetAlpha ( 1 )
    else
      IA_CharacterTooltipHands:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipHands:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipHandsCount:SetText ( control.data.equipSlots.hands > 1 and control.data.equipSlots.hands or "" )
    
    IA_CharacterTooltipLegs:SetTexture ( control.data.equipSlots.legsIcon )
    if control.data.equipSlots.legs > 0 then
      IA_CharacterTooltipLegs:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipLegs:SetAlpha ( 1 )
    else
      IA_CharacterTooltipLegs:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipLegs:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipLegsCount:SetText ( control.data.equipSlots.legs > 1 and control.data.equipSlots.legs or "" )
    
    IA_CharacterTooltipChest:SetTexture ( control.data.equipSlots.chestIcon )
    if control.data.equipSlots.chest > 0 then
      IA_CharacterTooltipChest:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipChest:SetAlpha ( 1 )
    else
      IA_CharacterTooltipChest:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipChest:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipChestCount:SetText ( control.data.equipSlots.chest > 1 and control.data.equipSlots.chest or "" )
    
    IA_CharacterTooltipBelt:SetTexture ( control.data.equipSlots.beltIcon )
    if control.data.equipSlots.belt > 0 then
      IA_CharacterTooltipBelt:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipBelt:SetAlpha ( 1 )
    else
      IA_CharacterTooltipBelt:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipBelt:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipBeltCount:SetText ( control.data.equipSlots.belt > 1 and control.data.equipSlots.belt or "" )
    
    IA_CharacterTooltipFeet:SetTexture ( control.data.equipSlots.feetIcon )
    if control.data.equipSlots.feet > 0 then
      IA_CharacterTooltipFeet:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipFeet:SetAlpha ( 1 )
    else
      IA_CharacterTooltipFeet:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipFeet:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipFeetCount:SetText ( control.data.equipSlots.feet > 1 and control.data.equipSlots.feet or "" )
    
    IA_CharacterTooltipNeck:SetTexture ( control.data.equipSlots.neckIcon )
    if control.data.equipSlots.neck > 0 then
      IA_CharacterTooltipNeck:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipNeck:SetAlpha ( 1 )
    else
      IA_CharacterTooltipNeck:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipNeck:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipNeckCount:SetText ( control.data.equipSlots.neck > 1 and control.data.equipSlots.neck or "" )
    
    IA_CharacterTooltipRing:SetTexture ( control.data.equipSlots.ringIcon )
    if control.data.equipSlots.ring > 0 then
      IA_CharacterTooltipRing:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipRing:SetAlpha ( 1 )
    else
      IA_CharacterTooltipRing:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipRing:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipRingCount:SetText ( control.data.equipSlots.ring > 1 and control.data.equipSlots.ring or "" )
    
    IA_CharacterTooltipMainHand:SetTexture ( control.data.equipSlots.mainHandIcon )
    if control.data.equipSlots.mainHand > 0 then
      IA_CharacterTooltipMainHand:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipMainHand:SetAlpha ( 1 )
    else
      IA_CharacterTooltipMainHand:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipMainHand:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipMainHandCount:SetText ( control.data.equipSlots.mainHand > 1 and control.data.equipSlots.mainHand or "" )
    
    IA_CharacterTooltipOffHand:SetTexture ( control.data.equipSlots.offHandIcon )
    if control.data.equipSlots.offHand > 0 then
      IA_CharacterTooltipOffHand:SetColor ( 1, 1, 1, 1 )
      IA_CharacterTooltipOffHand:SetAlpha ( 1 )
    else
      IA_CharacterTooltipOffHand:SetColor ( 1, 0.25, 0.25, 1 )
      IA_CharacterTooltipOffHand:SetAlpha ( 0.75 )
    end
    IA_CharacterTooltipOffHandCount:SetText ( control.data.equipSlots.offHand > 1 and control.data.equipSlots.offHand or "" )
  end
end
-----------------------------------------------------------------------------------------------------------------------------------
function IA_InventoryAssistantList_OnMouseExit ( control )
	control.list:Row_OnMouseExit ( control )
  if MasterMerchant then 
    MasterMerchant:remStatsItemTooltip ( ) 
  end
	ClearTooltip ( ItemTooltip )
  ClearTooltip ( IA_CharacterTooltip )
end
-----------------------------------------------------------------------------------------------------------------------------------
