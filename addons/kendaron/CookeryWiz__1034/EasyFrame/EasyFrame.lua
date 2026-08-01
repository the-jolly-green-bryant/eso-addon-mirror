
local SHOW_HIDE = 1
local SHOW_SHRUNK = 2
local SHOW_NORMAL = 3


-- The EasyFrame class
EasyFrame = {}
EasyFrame.name = "EasyFrame"

EasyFrame.ui = nil
EasyFrame.buttonShrink = nil

EasyFrame.textureShrink = nil

EasyFrame.expandTooltip = "Expand"
EasyFrame.shrinkTooltip = "Shrink"
EasyFrame.shrinkButtonTooltip = EasyFrame.shrinkTooltip

EasyFrame.closeTooltip = "Close"
EasyFrame.reloadTooltip = "Reload"
EasyFrame.reloadButton = nil
EasyFrame.closeButton = nil
EasyFrame.shrinkButton = nil
EasyFrame.titleLabel = nil
EasyFrame.parentWindow = nil

EasyFrame.textureChatEdgeControl = nil
EasyFrame.textureDefaultControl = nil
  
EasyFrame.resizeHandleSize = 5
EasyFrame.insets = 48

-- Dimension Constraints
EasyFrame.minWidthNormal = nil
EasyFrame.minHeightNormal = nil
EasyFrame.maxWidthNormal = nil
EasyFrame.maxHeightNormal = nil

EasyFrame.isChatEdgeEnabled = false

EasyFrame.miniBar = nil
EasyFrame.alreadyUIMode = false

EasyFrame.traceEnabled = false

local easyFrameVariables = {
      leftShrunk = 100,
      topShrunk = 100,
      leftNormal = 100,
      topNormal = 100,
      width = 400,
      height = 400,
      heightMin = 400,
      widthMin = 400,
      isShrunk = false,
      isHidden = false,
      disableShrink = false,
      viewState = SHOW_NORMAL
}

EasyFrame.easyFrameVariables = nil

local eventRegistrations = {

}


EasyFrame.uis = {
  
}

function EasyFrame:EnableTrace(enable)
  self.traceEnabled = enable
end

function EasyFrame:Trace(msg)
  if self.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end

---------------------------------------------------------------------
-- virtual functions
---------------------------------------------------------------------
function EasyFrame:OnPreShrink(isShrunk)
end

function EasyFrame:OnShrink(isShrunk)
end

function EasyFrame:OnEasyFrameResize()
end

function EasyFrame:OnRestorePosition()
end

function EasyFrame:OnReload()
end

function EasyFrame:OnMoveStop()
end

function EasyFrame:OnHideWindow(isHidden)
end

function EasyFrame:OnPlayerDeactivated(eventCode)
end

function EasyFrame:OnPlayerActivated(eventCode)
end
---------------------------------------------------------------------
-- Dynamic Event registrations
---------------------------------------------------------------------

function EasyFrame:AddDynamicRegistration(event, callback)
  local registration = {}
  
  registration.isRegistered = false
  registration.event = event
  registration.callback = callback
  
  eventRegistrations[#eventRegistrations + 1] = registration
  
end

function EasyFrame:HandleDynamicRegistration(isHidden)
  local isShrunk = self:IsShrunk()
  for i = 1, #eventRegistrations do
    local registration = eventRegistrations[i]
    --d(registration)
    if not isHidden then
      if not isShrunk then
        if not registration.isRegistered then
          self:Trace(string.format("Registering %s Status", registration.event))
          EVENT_MANAGER:RegisterForEvent(BeamMeUp.name,  registration.event, registration.callback)
          registration.isRegistered = true
        end
      else
        -- shrunk then unregister
        if registration.isRegistered then
          self:Trace(string.format("Unregistering %s Status", registration.event))
          EVENT_MANAGER:UnregisterForEvent(BeamMeUp.name,  registration.event)
          registration.isRegistered = false
        end      
      end
    else
      if registration.isRegistered then
        self:Trace(string.format("Registering %s Status", registration.event))
        EVENT_MANAGER:UnregisterForEvent(BeamMeUp.name,  registration.event)
        registration.isRegistered = false
      end
    end  
  end
end

---------------------------------------------------------------------
-- General functions
---------------------------------------------------------------------

EasyFrame.isSceneIntegrationEnabled = false

function EasyFrame:EnableSceneIntegration(enable)
  self.isSceneIntegrationEnabled = enable
  
  if enable then
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_HIDDEN_UPDATE, 
      function(...)
        self:OnReticleHidden(...)
      end)
  else
    EVENT_MANAGER:UnregisterForEvent(self.name,  EVENT_RETICLE_HIDDEN_UPDATE)
  end  
end

function EasyFrame:TakeFocus(editControl)
  editControl:SelectAll() 
  if SCENE_MANAGER:IsInUIMode() then
    editControl:TakeFocus()
  end
    --[[
  local scene = SCENE_MANAGER:GetCurrentScene()
  if scene then
    if scene:GetName() ~= "hud" then
      editControl:TakeFocus()
    end
  end 
  ]]--
end

function EasyFrame:HideTitle(hide)
  if not self.titleLabel then
    d("No Title Control")
    return
  end
  self.titleLabel:SetHidden(hide)
end

function EasyFrame:SetTitle(text)
  if not self.titleLabel then
    d("No Title Control")
    return
  end
  self.titleLabel:SetText(text)
end
function EasyFrame:DisableShrink(disable)
  self.easyFrameVariables.disableShrink = disable
  self.shrinkButton:SetHidden(disable)
end

function EasyFrame:GetEasyFrameVars()
  return self.easyFrameVariables
end

function EasyFrame:IsShrinkDisabled()
  return self.easyFrameVariables.disableShrink
end

function EasyFrame:DisableMiniIcon(disable)
  if self.miniBar then
    self.miniBar:Disable(disable)
  end
end

function EasyFrame:IsMiniIconDisabled()
  if self.miniBar then
    return self.miniBar:IsDisabled()
  end
  return true
end

function EasyFrame:GetMiniBar()
  return self.miniBar
end

function EasyFrame:GetParentWindow()
  return self.parentWindow
end
  
function EasyFrame:CenterControl(parentWindow, control)

  if parentWindow and control then
    --d("Centring to parent")
    local dialogWidth = control:GetWidth()
    local dialogHeight = control:GetHeight()
    local parentWidth = parentWindow:GetWidth()
    local parentHeight = parentWindow:GetHeight()
    
    --d("Width:["..dialogWidth.."], Height:["..dialogHeight.."], "..self.parentWindow:GetName())
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, parentWindow, TOPLEFT, (parentWidth/2)-(dialogWidth/2), (parentHeight/2)-(dialogHeight/2)) 
  else
    --d("Not Centering to parent null")
  end  
end

function EasyFrame:CenterToParent()
  local ui = self:GetTopWindow()
  self:CenterControl(self.parentWindow, ui)
end

function EasyFrame:OnShow()
  --d("EasyFrame:OnShow")
end

function EasyFrame:EnableUIMode(enable)
  self:Trace("EnableUIMode:("..tostring(true)..")")
  if enable then
    if not SCENE_MANAGER:IsInUIMode() then
      SCENE_MANAGER:SetInUIMode(true)
      self.alreadyUIMode = false
    else
      self.alreadyUIMode = true        
    end
  else
    if SCENE_MANAGER:IsInUIMode() then
      if self.alreadyUIMode then
      else
        SCENE_MANAGER:SetInUIMode(false)
      end
      self.alreadyUIMode = false
    end      
  end
end

function EasyFrame:ToggleWindow()
  
  if self.OnToggleWindow then
    if self:OnToggleWindow() == false then
      return
    end
  end
  
  local ui = self:GetTopWindow()
  local isHidden = ui:IsHidden()
  
 
  local isShrinkDisabled = self:IsShrinkDisabled()

  if not isShrinkDisabled then
  
    if isHidden then
      -- next stage is to show normal
      self.easyFrameVariables.isShrunk = false
      self:Shrink() 
      isHidden = false
    else
      if not self.easyFrameVariables.isShrunk then
        -- shrink ourselves
        self.easyFrameVariables.isShrunk = true
        self:Shrink() 
        isHidden = false
      else
        self.easyFrameVariables.isShrunk = false
        self:Shrink() 
        isHidden = true
      end
      
      --[[
      if self.easyFrameVariables.isShrunk then
        --d("shrink button is hidden")
        isHidden = true
      elseif self.shrinkButton:IsHidden() then
        isHidden = true
      else
        self.easyFrameVariables.isShrunk = true
        self:Shrink()
        isHidden = false
      end
      ]]--
    end
  else
    isHidden = not isHidden
  end
  
  local scene = SCENE_MANAGER:GetCurrentScene()
  if scene then
    self:Trace(scene:GetName())
  else
    self:Trace("No Scene")
  end  
  self:Trace("EasyFrame:ToggleWindow Calling HideWindow")
  self:HideWindow(isHidden)
end


function EasyFrame:OnEasyFrameResizeStop(control)
  --d("resize")
  if not self then
    d("OnEasyFrameResizeStop called without :")
    return
  end
  
  self.easyFrameVariables.width = control:GetWidth()
  self.easyFrameVariables.height = control:GetHeight()  
  self:OnEasyFrameResize()
end

function EasyFrame:IsShrunk()
  if self.easyFrameVariables then
    return self.easyFrameVariables.isShrunk
  end
end


function EasyFrame:SetIsShrunk(isShrunk)
  self.easyFrameVariables.isShrunk = isShrunk
end


function EasyFrame:Shrink()
  local ui = self:GetTopWindow()
  local vars = self.easyFrameVariables
  
  local isShrunk = vars.isShrunk
  local width = vars.width
  local height = vars.height
  local heightMin = vars.heightMin
  local widthMin = vars.widthMin


  local texture
  
  self:OnPreShrink(isShrunk)
  
  ui:ClearAnchors()
  
  if isShrunk then
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, vars.leftShrunk, vars.topShrunk)
    ui:SetDimensionConstraints(10, 10) 
    local wantedWidth, wantedHeight = self.titleLabel:GetDimensions()

    --d("Wanted size is "..wantedWidth..","..wantedHeight)
    local offsetX = 5
    local reloadButtonWidth = 0
    if not self.reloadButton:IsHidden() then
      -- to also take into account the offsetZ is 5
      reloadButtonWidth = self.reloadButton:GetWidth() + offsetX
    end

    local closeButtonWidth = 0
    if not self.closeButton:IsHidden() then
      closeButtonWidth = self.closeButton:GetWidth() + offsetX
    end
    
    local shrinkButtonWidth = 0
    if not self.shrinkButton:IsHidden() then
      shrinkButtonWidth = self.shrinkButton:GetWidth() + offsetX
    end
    
    ui:SetWidth(wantedWidth + 2 * offsetX + closeButtonWidth + shrinkButtonWidth + reloadButtonWidth )
    ui:SetHeight(wantedHeight)
    texture = "/esoui/art/minimap/minimap_maximize_up.dds"
    self.shrinkButtonTooltip = self.expandTooltip
    ui:SetResizeHandleSize(0)    
  else
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, vars.leftNormal, vars.topNormal)
    ui:SetDimensionConstraints(self.minWidthNormal, self.minHeightNormal)
    if widthMin > self.minWidthNormal then
      widthMin = self.minWidthNormal
    end
    if width < widthMin then
      width = widthMin
    end

    ui:SetWidth(width)
    --d("Setting width("..width..")")
    if heightMin > self.minHeightNormal then
      heightMin = self.minHeightNormal
    end    
    if height < heightMin then
      height = heightMin
    end    
    ui:SetHeight(height)
    --d("Setting height("..height..")")    
    texture = "/esoui/art/minimap/minimap_minimize_up.dds"
    --texture = "EsoUI/Art/Buttons/cancel_up.dds"
    self.shrinkButtonTooltip = self.shrinkTooltip
    ui:SetResizeHandleSize(self.resizeHandleSize)
  end
  if self.textureShrink then    
    self:SetShrinkButtonTexture(true)
    --self.textureShrink:SetTexture(isShrunk)
  end

  self:OnShrink(isShrunk)
end


function EasyFrame:RestorePosition()
  local ui = self:GetTopWindow()
  local vars = self.easyFrameVariables

  ui:ClearAnchors()
  if self:IsShrunk() then
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, vars.leftShrunk, vars.topShrunk)
  else    
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, vars.leftNormal, vars.topNormal)
  end

  self:OnRestorePosition()
  
  self:Shrink()
    
end

---------------------------------------------------------------------
-- Initialisation and click functions
---------------------------------------------------------------------

function EasyFrame:SetupTooltip(control, text)
  local easyFrame = self
  
  control:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(self, TOP, text)
      
    end)
  control:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip() 
    end)
end
--
-- Shrink button initialisation. Sets up tooltips and click events
--

function EasyFrame:SetShrinkButtonTexture(normal)
  if normal then
    if self.easyFrameVariables.isShrunk then
      self.textureShrink:SetTexture("esoui/art/chatwindow/maximize_up.dds")
    else
      self.textureShrink:SetTexture("esoui/art/chatwindow/minimize_up.dds")
    end  
  else
    if self.easyFrameVariables.isShrunk then
      self.textureShrink:SetTexture("esoui/art/chatwindow/maximize_over.dds")
    else
      self.textureShrink:SetTexture("esoui/art/chatwindow/minimize_over.dds")
    end     
  end
end


function EasyFrame:OnShrinkButtonInitialized(control)
  local easyFrame = self
  
  control:SetHandler("OnMouseEnter", function(self)
      easyFrame:SetShrinkButtonTexture(false)
      ZO_Tooltips_ShowTextTooltip(self, TOP, easyFrame.shrinkButtonTooltip)
      
    end)
  control:SetHandler("OnMouseExit", function(self)
      easyFrame:SetShrinkButtonTexture(true)
        ZO_Tooltips_HideTextTooltip()
      
    end)
  control:SetHandler("OnClicked", function(self)
        easyFrame:OnShrinkButtonClicked()
    end)
end

function EasyFrame:OnShrinkButtonClicked(control) 
  self.easyFrameVariables.isShrunk = not self.easyFrameVariables.isShrunk
  self:Shrink()
end


--
-- Close button initialisation. Sets up tooltips and click events
--

function EasyFrame:OnCloseButtonInitialized(control)
  local easyFrame = self
  
  control:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(self, TOP, easyFrame.closeTooltip)
  end)
  control:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
  end)
  
  control:SetHandler("OnClicked", function(self)
        easyFrame:OnCloseButtonClicked()
    end) 
end

function EasyFrame:IsHidden()
  local ui = self:GetTopWindow()
  if ui then
    return ui:IsHidden()
  else
    return true
  end
end


EasyFrame.ignoreUIMode = false

function EasyFrame:HideWindow(isHidden, ignoreUIMode)
  local ui = self:GetTopWindow()
  local isVisible = not isHidden
  
  if ui then
    self:Trace("Calling SetHidden("..tostring(isHidden)..") on "..self.ui:GetName())
    self.ignoreUIMode = ignoreUIMode
    ui:SetHidden(isHidden)
  end
  self:HandleDynamicRegistration(isHidden)

  if self.isSceneIntegrationEnabled and not ignoreUIMode then
    self:Trace("Scene Integration Enabled")

    if isVisible then
      if self:IsShrunk() and not self.easyFrameVariables.isHidden then
        self:EnableUIMode(false)
      else
        -- we want to be able to click on items
        self:EnableUIMode(true)
      end
    else
      if not self:IsShrunk() then
        self:EnableUIMode(false)
      end
    end 
  end
  
  self.easyFrameVariables.isHidden = isHidden
  self:Trace("EasyFrame:HideWindow Calling OnHideWindow("..tostring(isHidden)..")")
  self:OnHideWindow(isHidden)
end

function EasyFrame:OnCloseButtonClicked()
  self:HideWindow(true)
end

--
-- Reload button initialisation. Sets up tooltips and click events
--

function EasyFrame:OnReloadButtonInitialized(control)
  local easyFrame = self
  
  control:SetHandler("OnMouseEnter", function(self)
      ZO_Tooltips_ShowTextTooltip(self, TOP, easyFrame.reloadTooltip)
  end)
  control:SetHandler("OnMouseExit", function(self)
      ZO_Tooltips_HideTextTooltip()
  end)

  control:SetHandler("OnClicked", function(self)
        easyFrame:OnReloadButtonClicked()
    end)
end

function EasyFrame:OnReloadButtonClicked()
  self:OnReload()
end

--
-- Texture. Nothing really
--
function EasyFrame:OnTextureShrinkInitialized(control)
  
end
----------------------------


function EasyFrame:CreateColor(r, g, b, a)
  local color = { red = r, green = g, blue = b, alpha = a }
  color.GetParams = function()
    return r, g, b, a
  end
  return color
end

---------------------------

function EasyFrame:new ()

    local o = {}
    setmetatable(o, self)
    self.__index = self
    -- clone the easyFrameVariables, ready for changes
    o.easyFrameVariables = ZO_ShallowTableCopy(easyFrameVariables)
    return o
end

function EasyFrame:EasyFrameValidate()
  d("EasyFrameValidate")
  
  if not self then
    d("You have called EasyFrame:Validate without :")
    return
  end
  
  local res = true
  local ui = self:GetWindow()
  if not ui then
      d("No TopLevelControl")
      res = false
  end 
  if not self.reloadButton then
      d("No reloadButton")
      res = false
  end 
  if not self.shrinkButton then
      d("No shrinkButton")
      res = false
  end
  if not self.closeButton then
      d("No closeButton")
      res = false
  end
  if not self.textureShrink then
      d("No textureShrink")
      res = false
  end
  
  if not self.titleLabel then
      d("No titleLabel")
      res = false
  end  
  return res
end

function EasyFrame:OnEasyFrameMoveStop(control)
  --d("OnEasyFrameMoveStop")
  --local ui = self:GetWindow()
  local vars = self.easyFrameVariables

  if self:IsShrunk() then
    vars.leftShrunk = control:GetLeft()
    vars.topShrunk = control:GetTop()
  else
    vars.leftNormal = control:GetLeft()
    vars.topNormal = control:GetTop()
  end  
  self:OnMoveStop()
end

function EasyFrame:IsChatEdgeEnabled()
  return self.easyFrameVariables.isChatEdgeEnabled
end

function EasyFrame:EnableChatEdge(enable)
  self.easyFrameVariables.isChatEdgeEnabled = enable
  
  self.textureDefaultControl:SetHidden(enable)
  self.textureChatEdgeControl:SetHidden(not enable)
end


function EasyFrame:SetChatInsets(insets)
  local textureChatEdgeControl = self.textureChatEdgeControl
  textureChatEdgeControl:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, insets, 0)
  textureChatEdgeControl:SetInsets(insets,insets,-1 * insets, -1 * insets )
  textureChatEdgeControl:ClearAnchors()
  textureChatEdgeControl:SetAnchor(TOPLEFT, ui, TOPLEFT, -1 * insets, -1 * insets)
  textureChatEdgeControl:SetAnchor(BOTTOMRIGHT, ui, BOTTOMRIGHT, insets , insets)
  self.insets = insets
end

function EasyFrame:GetChatInsets()
  return self.insets
end

function EasyFrame:AdjustChatTheme(insets, alpha, offsetX, offsetY)

  local ui = self:GetWindow()
  local textureChatEdgeControl = self.textureChatEdgeControl

  self:SetChatInsets(insets)

  local r, g, b, a = textureChatEdgeControl:GetCenterColor() 
  --d("R["..r.."],G["..g.."],B["..b.."],A["..a.."]")
  --textureChatEdgeControl:SetEdgeColor(1, 1, 1, 1) 
  textureChatEdgeControl:SetCenterColor(0, 0, 0, 1) 

  
  textureChatEdgeControl:SetCenterTexture() 
end

function EasyFrame:GetTopWindow()
  return self.ui
end

function EasyFrame:GetWindow()
  return self.ui
end

function EasyFrame:OnEasyFramePlayerActivated(eventCode)
  local cleanShutdownSeconds = 20
  local easyVars = self.easyFrameVariables
  local secondsPlayed = GetSecondsPlayed() 
  -- did we shut down cleanly?
  if not easyVars.onPlayerDeactivated or (secondsPlayed - easyVars.onPlayerDeactivated) < cleanShutdownSeconds then
    easyVars.isCleanShutdown = true
  else
    easyVars.isCleanShutdown = false
  end
  easyVars.onPlayerActivated = secondsPlayed
  
  
  if self.easyFrameVariables.isHidden then
    self:HideWindow(true, true)
  else
    self:HideWindow(false, true)    
  end
  self:OnPlayerActivated(eventCode)
end

function EasyFrame:OnEasyFramePlayerDeactivated(eventCode)
  self.easyFrameVariables.onPlayerDeactivated = GetSecondsPlayed() 
  self:OnPlayerDeactivated(eventCode)
end

function EasyFrame:InitialiseControls(parent, title)
  local easyFrame = self
    
  -- add event handlers
  self.reloadButton = parent:GetNamedChild("ReloadButton")
  if not self.reloadButton then
      d("No reloadButton")
      return
  end
  
  self.shrinkButton = parent:GetNamedChild("ShrinkButton")
  if not self.shrinkButton then
      d("No shrinkButton")
      return
  end
  
  self.closeButton = parent:GetNamedChild("CloseButton")
  if not self.closeButton then
      d("No closeButton")
      return
  end  
  
  self.titleLabel = parent:GetNamedChild("TitleLabel")
  if not self.titleLabel then
      d("No titleLabel")
      return
  end
  
  self.textureShrink = self.shrinkButton:GetNamedChild("TextureShrink")
  if not self.textureShrink then
      d("No textureShrink")
      return
  end
  
  -- Set title
  self.titleLabel:SetText(title)
   
  -- Initialise these controls
  self:OnReloadButtonInitialized(self.reloadButton)
  self:OnShrinkButtonInitialized(self.shrinkButton)
  
  self:OnCloseButtonInitialized(self.closeButton)
  self.OnTextureShrinkInitialized(self.textureShrink)

  -- Handle MoveStop  
  parent:SetHandler("OnMoveStop", function(self)
        --d("OnMoveStop")
        easyFrame:OnEasyFrameMoveStop(self)
    end)
  
  -- Handle Resize
  parent:SetHandler("OnResizeStop", function(self)
        --d("OnResizeStop")
        easyFrame:OnEasyFrameResizeStop(self)
    end)
  
  -- Get any size constraints that are in place
  self.minWidthNormal, self.minHeightNormal, self.maxWidthNormal, self.maxHeightNormal = parent:GetDimensionConstraints()    
  self:DisableShrink(true)
  if self:IsShrunk() then
    self:SetIsShrunk(false)
    self:Shrink()
  end
  self:RestorePosition()

  self.textureChatEdgeControl = parent:GetNamedChild("ChatEdgeBG")
  self.textureDefaultControl = parent:GetNamedChild("DefaultBG")
  self:EnableChatEdge(self:IsChatEdgeEnabled())  
  

end

function EasyFrame:OnReticleHidden(eventCode, hidden)
  if not self.initComplete then
    return
  end
  --local isVisible = not hidden
  
  
  if (hidden) then
    self:Trace("Reticle Hidden")
  else
    self:Trace("Reticle Not Hidden.")
    if not self:IsHidden() then
      self:Trace("Hiding easyframe")
      if self.ignoreUIMode then
        self.ignoreUIMode = false
      elseif self:IsShrinkDisabled() then
        self:HideWindow(true)
      else
        self:SetIsShrunk(true)
        self:Shrink()
      end
    end
  end 

end

function EasyFrame:CreateMiniBar(hide, miniBarControl, minIconAlpha)  
  local miniBar = EasyFrameMiniBar:New(self, hide, miniBarControl, minIconAlpha)
  self.miniBar = miniBar
end

-- The main TopLevelControl
function EasyFrame:InitializeEasyFrame(title, ui, parentUI)

  self.ui = ui
  self.parentWindow = parentUI
  
  if not self.ui then
      d("No TopLevelControl passed")
      return
  end


  -- we want to know if we were cleanly shutdown
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEACTIVATED, function (eventCode)
        self:OnEasyFramePlayerDeactivated(eventCode)
      end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function (eventCode)
        self:OnEasyFramePlayerActivated(eventCode)
      end)   
    
  -- I want it to always start shrunk
  if not self:IsShrinkDisabled() then
    self.easyFrameVariables.isShrunk = true
    --self.easyFrameVariables.isHidden = false
  end
 
  -- Find and initialise the controls
  self:InitialiseControls(ui, title)
  self:SetChatInsets(self.insets)
    
end


