local legalStates =
{
  [CSTATE_NORMAL]   = true,
  [CSTATE_STARED]   = true,
  [CSTATE_CHECKED]  = true,
  [CSTATE_DISABLED] = true,
  [CSTATE_BOTH]     = true,
}

local CCCollectionEmote = ZO_Object:Subclass()

function CCCollectionEmote:New(...)
  local object = ZO_Object.New(self)
  object:Initialize(...)
  return object
end

function CCCollectionEmote:Initialize(control)
  self.m_control = control


  self.m_highlight = control:GetNamedChild("Highlight")
  self.m_image     = control:GetNamedChild("Image")
  self.m_check     = control:GetNamedChild("Check")
  self.m_star      = control:GetNamedChild("Star")
  self.m_label      = control:GetNamedChild("Title")

  self.m_isChecked = false
  self.m_isStared = false

  self.m_state = CSTATE_DISABLED
end

function CCCollectionEmote:GetItemDimensions()

  local xSize = (self.m_emoteData and self.m_emoteData.width)
  local ySize = (self.m_emoteData and self.m_emoteData.width)

  local rSizeX, rSizeY = self.m_owner:GetItemDimensions()

  if xSize == nil then
    xSize = rSizeX
  end

  if ySize == nil then
    ySize = rSizeY
  end

  return xSize, ySize
end

function CCCollectionEmote:GetIsChecked()
  return self.m_isChecked
end

function CCCollectionEmote:GetIsStared()
  return self.m_isStared
end

function CCCollectionEmote:UpdateTexturesFromState()
  local state = self.m_state
  local emoteData = self.m_emoteData

  if state == CSTATE_NORMAL then
    self.m_check:SetHidden(true)
    self.m_star:SetHidden(true)
  elseif state == CSTATE_STARED then
    self.m_check:SetHidden(true)
    self.m_star:SetHidden(false)
  elseif state == CSTATE_CHECKED then
    self.m_check:SetHidden(false)
    self.m_star:SetHidden(true)
  end

  local width, height = self:GetItemDimensions()
  self.m_image:SetDimensions(height-20, height-20)
  self.m_image:SetTexture(self.m_texture)

  local fontSize = self.m_titleSize
  local fontStyle = "MEDIUM_FONT"         -- or "BOLD_FONT"
  local fontWeight = "soft-shadow-thin"   -- or "soft-shadow-thick", or... see below
  local fontStyle = string.format("$(%s)|$(KB_%s)|%s", fontStyle, fontSize, fontWeight) -- or

  self.m_label:SetText(self.m_title)
  self.m_label:SetFont(fontStyle)
  self.m_label:SetColor(self.m_titleColor[1], self.m_titleColor[2], self.m_titleColor[3], self.m_titleColor[4])
end

function CCCollectionEmote:SetState(state)

  -- We only change things if we need to update
  if legalStates[state] and state ~= self.m_state then
    self.m_state = state
    self:UpdateTexturesFromState()
  end
end

function CCCollectionEmote:SetData(owner, emoteData)
  self.m_emoteData = emoteData
  self.m_owner = owner
  self.m_texture = emoteData.texture or "eosui/art/quickslots/quickslot_emptySlot.dds"

  self.m_title      = emoteData.title or "Empty"
  self.m_titleSize  = emoteData.titleSize or 30
  self.m_titleColor = emoteData.titleColor or { 1, 1, 1, 1 }

  self:SetState(CSTATE_NORMAL)
end

function CCCollectionEmote:Reset()
  self:SetState(CSTATE_DISABLED)
  self.m_control:SetHidden(true)
end

function CCCollectionEmote:MouseEnter()
  self.m_highlight:SetHidden(false)
end

function CCCollectionEmote:MouseExit()
  self.m_highlight:SetHidden(true)
end

function CCCollectionEmote:OnMouseDrag()
  local emoteData = self.m_emoteData
  if emoteData.onDragCallback then
    emoteData:onDragCallback()
  end
end

--[[
  Collection Item
]]--
local CCCollectionItem = ZO_Object:Subclass()

function CCCollectionItem:New(...)
  local object = ZO_Object.New(self)
  object:Initialize(...)
  return object
end

function CCCollectionItem:Initialize(control)
  self.m_control = control

  self.m_BG        = control:GetNamedChild("BG")
  self.m_highlight = control:GetNamedChild("Highlight")
  self.m_image     = control:GetNamedChild("Image")
  self.m_check     = control:GetNamedChild("Check")
  self.m_star      = control:GetNamedChild("Star")
  self.m_divider   = control:GetNamedChild("Divider")

  self.m_isChecked = false
  self.m_isStared = false

  self.m_state = {
    [CSTATE_DISABLED] = true,
    [CSTATE_NORMAL]   = true,
    [CSTATE_STARED]   = false,
    [CSTATE_CHECKED]  = false,
  }
end

function CCCollectionItem:GetItemDimensions()
  local xSize = (self.m_emoteData and self.m_emoteData.width)
  local ySize = (self.m_emoteData and self.m_emoteData.width)

  local rSizeX, rSizeY = self.m_owner:GetItemDimensions()

  if xSize == nil then
    xSize = rSizeX
  end

  if ySize == nil then
    ySize = rSizeY
  end

  return xSize, ySize
end

function CCCollectionItem:GetIsChecked()
  return self.m_isChecked
end

function CCCollectionItem:GetIsStared()
  return self.m_isStared
end

function CCCollectionItem:UpdateTexturesFromState()
  local state = self.m_state
  local itemData = self.m_itemData

  if self.m_state[CSTATE_NORMAL] == true then
    self.m_check:SetHidden(true)
    self.m_star:SetHidden(true)
  end

  if self.m_state[CSTATE_STARED] == true then
    self.m_star:SetHidden(false)
  end

  if self.m_state[CSTATE_CHECKED] == true then
    self.m_check:SetHidden(false)
  end

  local width, height = self:GetItemDimensions()
  self.m_image:SetDimensions(width, height)

  -- Set the default texture
  self.m_image:SetTexture(self.m_texture)
end

function CCCollectionItem:SetState(state, enabled)

  -- We only change things if we need to update
  if legalStates[state] then
    self.m_state[state] = enabled
    self:UpdateTexturesFromState()
  end
end

function CCCollectionItem:SetData(owner, itemData)
  self.m_itemData = itemData
  self.m_owner = owner
  self.m_texture = itemData.texture or "eosui/art/quickslots/quickslot_emptySlot.dds"

  self.m_clickedCallback     = itemData.clickedCallback
  self.m_doubleClickCallback = itemData.doubleClickCallback
  self.m_rightClickCallback  = itemData.rightClickCallback

  self:SetState(CSTATE_NORMAL,  true)
  self:SetState(CSTATE_STARED,  false)
  self:SetState(CSTATE_CHECKED, false)
end

function CCCollectionItem:Reset()
  self:SetState(CSTATE_DISABLED, true)
  self.m_control:SetHidden(true)
end

function CCCollectionItem:MouseEnter()
  if self.m_itemData.itemLink ~= nil then
    CC_UI.ShowToolTip(self.m_control, self.m_itemData.itemLink)
  end
  self.m_highlight:SetHidden(false)
end

function CCCollectionItem:MouseExit()
  CC_UI.HideToolTip()
  self.m_highlight:SetHidden(true)
end

function CCCollectionItem:MouseUp()
  if self.m_clickedCallback then
    self.m_clickedCallback()
  end
end

function CCCollectionItem:MouseRightClick()
  if self.m_rightClickCallback ~= nil then
    self.m_rightClickCallback()
  end
end

function CCCollectionItem:MouseDoubleClick()
  if self.m_doubleClickCallback then
    self.m_doubleClickCallback()
  end
end

function CCCollectionItem:OnMouseDrag()
  local itemData = self.m_itemData
  if itemData.onDragCallback then
    itemData:onDragCallback()
  end
end

--[[
  Collecton Grid
]]--

local INDEX_BUTTON = 1
local INDEX_DESCRIPTOR = 3

local CCCollectionList = ZO_Object:Subclass()

function CCCollectionList:New(...)
  local object = ZO_Object.New(self)
  object:Initialize(...)
  return object
end

function CCCollectionList:Initialize(control)
  self.m_control = control

  self.m_title   = self.m_control:GetNamedChild("Title")
  self.m_grid    = self.m_control:GetNamedChild("Grid")
  self.m_bullet  = self.m_control:GetNamedChild("Bullet")
  self.m_divider = self.m_control:GetNamedChild("Divider")
  self.m_empty   = self.m_control:GetNamedChild("Empty")

  self.m_gridItems = {}

  self.m_isVisable = true
end

function CCCollectionList:GetItemDimensions()
  return self.m_itemWidth, self.m_itemHeight
end

function CCCollectionList:GetItemFromDescriptor(descriptor)
  for _, item in ipairs(self.m_gridItems) do
   if item[3] == descriptor then
    return item[1].m_object
   end
  end
  return nil
end

function CCCollectionList:SetTitle(title)
  self.m_titleText = title
  self:UpdateLayout()
end

function CCCollectionList:SetData(listData)

  -- Only initate the once
  if self.m_pool ~= nil then return end

  self.m_pool = ZO_ControlPool:New(listData.buttonTemplate or "CC_CollectionItem", self.m_control, "Button")
  self.m_pool:SetCustomResetBehavior(function(control)
        control.m_object:Reset()
    end)

  self.m_titleText     = listData.title or "Empty"
  self.m_bulletTexture = listData.bullet or "/esoui/art/buttons/leftarrow_up.dds"

  if listData.isGrid ~= nil then
    self.m_isGrid = listData.isGrid
  end

  if listData.isRadial ~= nil then
    self.m_isRadial = listData.isRadial
  end

  if listData.showBullet ~= nil then
    self.m_showBullet = listData.showBullet
  else
    self.m_showBullet = true
  end

  self.m_maxWidth     = listData.width      or 200
  self.m_maxHeight    = listData.height     or 200

  self.m_gridWidth    = listData.gridWidth  or self.m_maxWidth
  self.m_gridHeight   = listData.gridHeight or self.m_maxHeight

  self.m_itemWidth    = listData.itemWidth  or 50
  self.m_itemHeight   = listData.itemHeight or 50

  self.m_itemPaddingX = listData.paddingX   or 10
  self.m_itemPaddingY = listData.paddingY   or 10
end

function CCCollectionList:AddItem(itemData)
  local item, key = self.m_pool:AcquireObject()
  item.m_object:SetData(self, itemData)
  table.insert(self.m_gridItems, {item, key, itemData.descriptor })
  self:UpdateGrid()
  return item
end

function CCCollectionList:UpdateLayout()

  self.m_title:SetText(self.m_titleText)

  -- Devider should be the same size.
  self.m_divider:SetDimensions(self.m_maxWidth, 3)
  self.m_control:SetDimensions(self.m_maxWidth, self.m_maxHeight)
  self.m_grid:SetDimensions(self.m_gridWidth, self.m_gridHeight)

  if self.m_showBullet == true  then

    self.m_title:SetHidden(false)

    self.m_bullet:SetHidden(false)
    self.m_divider:SetHidden(false)
    self.m_bullet:SetTexture(self.m_bulletTexture)
  else
    self.m_title:SetHidden(true)
    self.m_divider:SetHidden(true)
    self.m_bullet:SetHidden(true)
  end
end

local INITIAL_ROTATION = 0
function CCCollectionList:UpdateGrid()

  if self.m_isGrid then
    local numColums = math.floor(self.m_maxWidth / self.m_itemWidth)

    local j = 0
    for _, button in ipairs(self.m_gridItems) do
      local itemControl = button[INDEX_BUTTON]

      itemControl:ClearAnchors()

      itemControl:SetHidden(false)
      itemControl:SetDimensions(self.m_itemWidth, self.m_itemWidth)

      local itemWidth = (2 * ZO_DEFAULT_BACKDROP_ANCHOR_OFFSET) + self.m_itemWidth

      local posX = self.m_itemPaddingX + ((j % numColums) * itemWidth)
      local posY = self.m_itemPaddingY + ((math.floor(j / numColums)) * itemWidth)

      itemControl:SetAnchor(TOPLEFT, self.m_control, TOPLEFT, posX, posY) -- creates grid

      j = j + 1
    end
  elseif self.m_isRadial then

    local width, height = self.m_grid:GetDimensions()
    local scale = self.m_grid:GetScale()

    local halfWidth, halfHeight = width * scale * 0.5, height * scale * 0.5
    local numSlots = #self.m_gridItems

    local j = 1
    for _, button in ipairs(self.m_gridItems) do
      local itemControl = button[INDEX_BUTTON]
      itemControl:ClearAnchors()
      itemControl:SetHidden(false)
      itemControl:SetDimensions(self.m_itemWidth, self.m_itemWidth)

      local centerAngle = INITIAL_ROTATION + j / numSlots * ZO_TWO_PI
      local x = math.sin(centerAngle)
      local y = math.cos(centerAngle)

      if math.abs(x) < 0.01 then
          x = 0
      end

      itemControl:SetAnchor(CENTER, nil, CENTER, (x * halfWidth) +  self.m_itemPaddingX, (y * halfHeight) + self.m_itemPaddingY)
      itemControl:SetHidden(false)

      j = j + 1
    end

  else
    local j = 0
    for _, button in ipairs(self.m_gridItems) do

      local itemControl = button[INDEX_BUTTON]
      local itemData    = itemControl.m_object.m_itemData

      itemControl:ClearAnchors()

      itemControl:SetHidden(false)
      itemControl:SetDimensions(self.m_itemWidth, self.m_itemHeight)

      local posX = self.m_itemPaddingX
      local posY = self.m_itemPaddingY + (j * self.m_itemHeight)

      itemControl:SetAnchor(TOPLEFT, self.m_control, TOPLEFT, posX, posY) -- creates list

      j = j + 1
    end
  end

end

function CCCollectionList:Reset()
  self.m_pool:ReleaseAllObjects()
  self.m_gridItems = {}
end

function CCCollectionList:ToggleGlow(descriptor)
  local item = self:GetItemFromDescriptor(descriptor)

  if item ~= nil then
    item:ToggleGlow()
  end
end

function CCCollectionList:SetState(descriptor, state, enabled)
  local item = self:GetItemFromDescriptor(descriptor)

  if item ~= nil then
    item:SetState(state, enabled)
  end
end

--[[
  Collection Emote
]]--
function CC_CollectionEmoteTemplate_OnInitialized(self)
  self.m_object = CCCollectionEmote:New(self)
end

function CC_CollectionEmoteTemplate_SetDate(self, itemData)
  self.m_object:SetData(itemData)
end

function CC_CollectionEmoteTemplate_OnMouseEnter(self)
  self.m_object:MouseEnter()
end

function CC_CollectionEmoteTemplate_OnMouseExit(self)
  self.m_object:MouseExit()
end

function CC_CollectionEmoteTemplate_OnMouseDrag(self)
  self.m_object:OnMouseDrag()
end

--[[
  Collection Icon
]]--
function CC_CollectionItemTemplate_OnInitialized(self)
  self.m_object = CCCollectionItem:New(self)
end

function CC_CollectionItemTemplate_SetDate(self, itemData)
  self.m_object:SetData(itemData)
end

function CC_CollectionItemTemplate_OnMouseEnter(self)
  self.m_object:MouseEnter()
end

function CC_CollectionItemTemplate_OnMouseExit(self)
  self.m_object:MouseExit()
end

function CC_CollectionItemTemplate_OnMouseUp(self)
  self.m_object:MouseUp()
end

function CC_CollectionItemTemplate_OnMouseRightClick(self)
  self.m_object:MouseRightClick()
end

function CC_CollectionItemTemplate_OnMouseDoubleClick(self)
  self.m_object:MouseDoubleClick()
end

function CC_CollectionItemTemplate_OnDragStart(self)
  self.m_object:OnMouseDrag()
end

--[[
  OTHER
]]--
function CC_CollectionListTemplate_OnInitialized(self)
  self.m_object = CCCollectionList:New(self)
end

function CC_CollectionListTemplate_SetData(self, listData)
  self.m_object:SetData(listData)
end

function CC_CollectionListTemplate_AddItem(self, itemData)
  return self.m_object:AddItem(itemData)
end

function CC_CollectionListTemplate_Reset(self)
  self.m_object:Reset()
end

function CC_CollectionListTemplate_SetTitle(self, title)
  self.m_object:SetTitle(title)
end

function CC_CollectionListTemplate_SetState(self, descriptor, state, enabled)
  self.m_object:SetState(descriptor, state, enabled)
end

function CC_CollectionListTemplate_ToggleGlow(self, descriptor)
  self.m_object:ToggleGlow(descriptor)
end

function CC_CollectionListTemplate_UpdateLayout(self)
  self.m_object:UpdateLayout()
end
