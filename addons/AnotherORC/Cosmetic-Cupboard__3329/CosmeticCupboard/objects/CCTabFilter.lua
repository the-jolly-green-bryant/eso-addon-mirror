
--[[
  CC Tab Button
]]--

local CCTabButton = ZO_Object:Subclass()

function CCTabButton:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function CCTabButton:Initialize(button)
  self.m_button = button
  self.m_image = button:GetNamedChild("Image")
  self.m_state = BSTATE_DISABLED
  self.m_image:SetDimensions(32, 32) -- start out at some default size...
end

function CCTabButton:UpdateTexturesFromState()

  local state = self.m_state
  local buttonData = self.m_buttonData
  local texture

  if state == BSTATE_NORMAL then
    texture = buttonData.normal
  elseif state == BSTATE_PRESSED then
    texture = buttonData.pressed
  end

  self.m_image:SetTexture(texture)
end

local legalStates =
{
    [BSTATE_NORMAL] = true,
    [BSTATE_PRESSED] = true,
    [BSTATE_DISABLED] = true,
}

function CCTabButton:GetState()
    return self.m_state
end

function CCTabButton:SetState(state)
  -- The button state has been changed
  if legalStates[state] and state ~= self.m_state then

    self.m_state = state
    self:UpdateTexturesFromState()

    local normalSize, downSize = self:GetAnimationData()

    if state == BSTATE_PRESSED then
      self.m_image:SetDimensions(downSize, downSize)
    else
      self.m_image:SetDimensions(normalSize, normalSize)
    end
  end
end

function CCTabButton:SetData(owner, buttonData)
    self.m_buttonData = buttonData
    self.m_menuBar = owner
    self:SetState(BSTATE_NORMAL)
end

function CCTabButton:Release(upInside)
  if upInside then

    self.m_menuBar:SetClickedButton(self)

    local buttonData = self.m_buttonData

    if buttonData.callback then
        buttonData:callback()
    end

    local clickSound = buttonData.clickSound or self.m_menuBar:GetClickSound()

    if clickSound then
        PlaySound(clickSound)
    end
  else
    self:UnPress()
  end
end

function CCTabButton:MouseEnter()
  local name = ( self.m_buttonData and self.m_buttonData.activeTabText ) or "No Name"
  ZO_Tooltips_ShowTextTooltip(self:GetControl(), TOP, name)
end

function CCTabButton:Press()
  self:SetState(BSTATE_PRESSED)
end

function CCTabButton:UnPress()
  self:SetState(BSTATE_NORMAL)
end

function CCTabButton:MouseExit()
  ZO_Tooltips_HideTextTooltip()
end

function CCTabButton:GetDescriptor()
  return self.m_buttonData and self.m_buttonData.descriptor
end

function CCTabButton:GetControl()
  return self.m_button
end

function CCTabButton:GetAnimationData()
  local normalSize, downSize = self.m_menuBar:GetAnimationData()
  normalSize = self.m_buttonData.overrideNormalSize or normalSize
  downSize   = self.m_buttonData.overrideDownSize or downSize
  return normalSize, downSize
end

--[[
  CC Tab Filter
]]--

local INDEX_BUTTON = 1
local INDEX_DESCRIPTOR = 3

local CCTabFilter = ZO_Object:Subclass()

function CCTabFilter:New(...)
    local object = ZO_Object.New(self)
    object:Initialize(...)
    return object
end

function CCTabFilter:Initialize(control)
  self.m_buttons = {}
  self.m_control = control

  self.m_point = LEFT
  self.m_relativePoint = RIGHT
  self.m_buttonPadding = 0

  self.m_clickSound = SOUNDS.MENU_BAR_CLICK
end

function CCTabFilter:GetClickSound()
    return self.m_clickSound
end

function CCTabFilter:SetData(filterData)

  -- We can reinitalize the filter
  if self.m_pool ~= nil then return end

  if filterData.initialButtonAnchorPoint and filterData.initialButtonAnchorPoint == RIGHT then
    self.m_point = RIGHT
    self.m_relativePoint = LEFT
  else
    self.m_point = LEFT
    self.m_relativePoint = RIGHT
  end

  self.m_pool = ZO_ControlPool:New(filterData.buttonTemplate or "CC_TabFilterButton", self.m_control, "Button")

  self.m_buttonPadding = filterData.buttonPadding or 0
  self.m_normalSize    = filterData.normalSize or 32
  self.m_downSize      = filterData.downSize or 50
end

function CCTabFilter:ButtonObjectForDescriptor(descriptor)
    for _, data in ipairs(self.m_buttons) do
        if data[INDEX_DESCRIPTOR] == descriptor then
            return data[INDEX_BUTTON].m_object
        end
    end
end

function CCTabFilter:SelectDescriptor(descriptor, reselectIfSelected)

  local buttonObject = self:ButtonObjectForDescriptor(descriptor)

  if buttonObject then
    if (self.m_clickedButton and (self.m_clickedButton.m_buttonData == buttonObject.m_buttonData)) and not reselectIfSelected then
      return
    end

    self:SetClickedButton(nil) -- reset
    buttonObject:Release(true)

    return true
  end

  return false
end


function CCTabFilter:UpdateButtons()

  local lastVisibleButton

  for i, button in ipairs(self.m_buttons) do
    local buttonControl = button[INDEX_BUTTON]
    local buttonData = buttonControl.m_object.m_buttonData
    buttonControl:ClearAnchors()

    buttonControl:SetHidden(false)
    self:SetDescriptorEnabled(buttonData.descriptor, true)

    if lastVisibleButton then
      local previousButtonExtraPadding = buttonData.previousButtonExtraPadding or 0
      buttonControl:SetAnchor(self.m_point, lastVisibleButton, self.m_relativePoint, self.m_buttonPadding + previousButtonExtraPadding)
    else
      buttonControl:SetAnchor(self.m_point, nil, self.m_point, 0, 0)
    end

    -- Display!
    buttonControl.m_object:UpdateTexturesFromState()
    lastVisibleButton = buttonControl
  end
end

function CCTabFilter:AddButton(buttonData)
  local button, key = self.m_pool:AcquireObject()
  button.m_object:SetData(self, buttonData)
  table.insert(self.m_buttons, { button, key, buttonData.descriptor }) -- update constants if order changes!
  self:UpdateButtons()
  return button
end

function CCTabFilter:SetClickedButton(buttonObject, skipAnimation)
  if self.m_clickedButton then
    self.m_clickedButton:UnPress(skipAnimation)
    self.m_lastClickedButton = self.m_clickedButton
    self.m_clickedButton = nil
  end

  if buttonObject then
    self.m_clickedButton = buttonObject
    self.m_clickedButton:Press(skipAnimation)
  end
end

function CCTabFilter:SetDescriptorEnabled(descriptor, enabled)
    local buttonObject = self:ButtonObjectForDescriptor(descriptor)
    if(buttonObject) then
        local currentState = buttonObject:GetState()
        if(enabled and currentState == BSTATE_DISABLED) then
            buttonObject:SetState(BSTATE_NORMAL)
        elseif(not enabled) then
            buttonObject:SetState(BSTATE_DISABLED)
        end
    end
end


function CCTabFilter:GetAnimationData()
  return self.m_normalSize, self.m_downSize
end

--[[
  Setup methods
]]--
-- Buttons
do
  function CC_TabFilterButtonTemplate_OnInitialized(self)
    self.m_object = CCTabButton:New(self)
  end

  function CC_TabFilterButtonTemplate_OnMouseEnter(self)
    self.m_object:MouseEnter()
  end

  function CC_TabFilterButtonTemplate_OnMouseExit(self)
    self.m_object:MouseExit()
  end

  function CC_TabFilterButtonTemplate_OnPress(self, button)
      if button == MOUSE_BUTTON_INDEX_LEFT then
          self.m_object:Press()
      end
  end

  function CC_TabFilterButtonTemplate_OnMouseUp(self, button, upInside)
    if button == MOUSE_BUTTON_INDEX_LEFT then
        self.m_object:Release(upInside)
    end
  end
end

-- Filter
do
  function CC_TabFilter_OnInitialized(self)
    self.m_object = CCTabFilter:New(self)
  end

  function CC_TabFilter_SetData(self, data)
    self.m_object:SetData(data)
  end

  function CC_TabFilter_AddButton(self, buttonData)
    return self.m_object:AddButton(buttonData)
  end

  function CC_TabFilter_SelectDescriptor(self, descriptor)
    return self.m_object:SelectDescriptor(descriptor, true)
  end

  function CC_TabFilter_UpdateButtons(self)
    self.m_object:UpdateButtons()
  end

end
