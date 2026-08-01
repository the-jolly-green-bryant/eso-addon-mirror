
local L = EasyFrameLanguage.language

local FADE_DURATION = 400
local FADE_DURATION_ICON = 400
local FADE_MIN_ALPHA = 0
local FADE_MAX_ALPHA = 1.0

EasyFrameIconBar = {}
EasyFrameIconBar.ui = nil
EasyFrameIconBar.savedVars = nil
EasyFrameIconBar.enableFade = true
EasyFrameIconBar.isExpanded = false
EasyFrameIconBar.iconTooltip = L[EASYFRAME_TEXTURE_ICON_TOOLTIP]
EasyFrameIconBar.addonName = "EasyFrameIconBar"
EasyFrameIconBar.iconAlphaMinDefault = 0.6
EasyFrameIconBar.moveDisabled = false

EasyFrameIconBar.traceEnabled = false

local function trace(msg)
  if EasyFrameIconBar.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end


---------------------------------------------------------------------
-- Function: getIconBar
--
-- This function gets the icon bar object associated with the control
-- tree
---------------------------------------------------------------------
local function getIconBar(control)
  if control then   
    while control do
      if control.iconBar then
        return control.iconBar
      end
      control = control:GetParent()
    end
  end
end

---------------------------------------------------------------------
-- Function: mouseExitHandler
--
-- This function will handle the mouse exit of controls. It will
-- handle fading
---------------------------------------------------------------------
local function mouseExitHandler(control)
  trace("mouseExitHandler-"..control:GetName())
  if control.iconBarMouseExit then
    control.iconBarMouseExit(control)
  end
  
  local iconBar = getIconBar(control)
  if iconBar then
    iconBar:StartFadeOut()
  end   
end


---------------------------------------------------------------------
-- Function: StartFadeOut
--
-- This function is called to start the fade out process
---------------------------------------------------------------------
function EasyFrameIconBar:StartFadeOut()

  if not self.enableFade then
    trace("Fade disabled")
    return
  end

  local ui = self.ui

  local textureOver = ui:GetNamedChild("OverTexture")
  local textureNormal = ui:GetNamedChild("NormalTexture")
  if textureOver and textureNormal then
    textureOver:SetHidden(true)
    textureNormal:SetHidden(false)
  end
  

  local function onFadeOutFinished(control)
    trace("onFadeOutFinished")

    local parent = control:GetParent()
    if parent and parent.iconBar then
      parent.iconBar:Contract()
      -- fade the main icon
      if parent.fadeAnimIcon then
        if not parent.fadeAnimIcon:IsPlaying() then
          parent.fadeAnimIcon:FadeOut(0, FADE_DURATION_ICON, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA)        
        end
      end       
    end
  end

  local function onFadeTimeout()
    trace("onFadeTimeout")
    -- only fade if we are not over the iconbar
    local iconBar = getIconBar(moc())
    if not iconBar then
      local barTexture = ui:GetNamedChild("BarTexture")
      local numChildren = barTexture:GetNumChildren()
      -- a 'munge' overlay is one of the children by default
      if numChildren > 1 then      
        if ui.fadeAnim then
          -- if we are in the process of fading. Stop and then do the new fade
          -- (We could be doing a fadeIn if they move the mouse quickly)
          if ui.fadeAnimIcon then
            ui.fadeAnim:Stop(ZO_ALPHA_ANIMATION_OPTION_PREVENT_CALLBACK)
          end        

          ui.fadeAnim:FadeOut(0, FADE_DURATION, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, onFadeOutFinished)
        end
      else
        onFadeOutFinished(barTexture)
      end
    end
  end
  
  zo_callLater(onFadeTimeout, 100)  
end

---------------------------------------------------------------------
-- Function: SetIconTexture
--
-- This function is called to set the texture of the icon.. if required
---------------------------------------------------------------------
function EasyFrameIconBar:SetIconTexture(filename)
  local iconBarControl = self.ui
  local textureControl = iconBarControl:GetNamedChild("NormalTexture")
  if textureControl then
    textureControl:SetTexture(filename) 
  end
end

---------------------------------------------------------------------
-- Function: StartFadeIn
--
-- This function is called to start the fade in process
---------------------------------------------------------------------
function EasyFrameIconBar:StartFadeIn()
  local iconBarControl = self.ui
  
  local function onFadeInFinished(control)
    trace("onFadeInFinished")

    local parent = control:GetParent()
    local barTexture = parent:GetNamedChild("BarTexture")
    local numChildren = barTexture:GetNumChildren()
    -- a 'munge' overlay is one of the children by default
    if numChildren > 1 then
      trace("Children == "..numChildren)
      local child = barTexture:GetChild(1)
      trace(child:GetName())
      if parent and parent.iconBar then
        
        -- fade in the rest
        if not parent.fadeAnim then
            parent.fadeAnim = ZO_AlphaAnimation:New(barTexture)
            parent.fadeAnim:SetMinMaxAlpha(FADE_MIN_ALPHA, FADE_MAX_ALPHA)
        end
        if not parent.fadeAnim:IsPlaying() then  
          parent.fadeAnim:FadeIn(0, FADE_DURATION)      
        end
        -- change size
        parent.iconBar:Expand(parent)      
      end
    end
  end
  
  -- if we are in the process of fading. Stop and then do the new fade
  -- (We could be doing a fadeOut if they move the mouse quickly)
  if iconBarControl.fadeAnimIcon then
    iconBarControl.fadeAnimIcon:Stop(ZO_ALPHA_ANIMATION_OPTION_PREVENT_CALLBACK)
  end

  iconBarControl.fadeAnimIcon:FadeIn(0, FADE_DURATION_ICON, ZO_ALPHA_ANIMATION_OPTION_USE_CURRENT_ALPHA, onFadeInFinished)        
end
---------------------------------------------------------------------
-- Function: New
--
-- This function is called to create a new iconbar
---------------------------------------------------------------------
function EasyFrameIconBar:New()
  o = {}
  setmetatable(o, self)
  self.__index = self
  return o  
end

---------------------------------------------------------------------
-- Function: PushPosition
--
-- This function temporarily moves the icon bar
---------------------------------------------------------------------
function EasyFrameIconBar:PushPosition(left, top)
  if self.restoreLeft ~= nil then
    trace("Already pushed")
    return
  end  
  
  self.restoreLeft = self:GetSavedLeft()
  self.restoreTop = self:GetSavedTop()
  
  self:SetSavedLeft(left)
  self:SetSavedTop(top)
  self:RestorePosition()
end

---------------------------------------------------------------------
-- Function: PopPosition
--
-- This function restores original position
---------------------------------------------------------------------
function EasyFrameIconBar:PopPosition()
  if not self.restoreLeft then
    trace("Already Popped")
    return
  end
  
  self:SetSavedLeft(self.restoreLeft)
  self:SetSavedTop(self.restoreTop)
  self:RestorePosition()
  
  self.restoreLeft = nil
  self.restoreTop = nil
end

---------------------------------------------------------------------
-- Function: SetHidden
--
-- This function shows or hides the iconbar
---------------------------------------------------------------------
function EasyFrameIconBar:SetHidden(hide)
  self.ui:SetHidden(hide)
end

---------------------------------------------------------------------
-- Function: IsHidden
--
-- This function returns the visible state of the iconbar
---------------------------------------------------------------------
function EasyFrameIconBar:IsHidden()
  return self.ui:IsHidden()
end

---------------------------------------------------------------------
-- Function: Disable
--
-- This function shows or hides the iconbar
---------------------------------------------------------------------
function EasyFrameIconBar:Disable(disable)
  self.savedVars.disabled = disable
  self:SetHidden(disable)
end

---------------------------------------------------------------------
-- Function: IsDisabled
--
-- This function gets the disabled state
---------------------------------------------------------------------
function EasyFrameIconBar:IsDisabled()
  return self.savedVars.disabled
end

---------------------------------------------------------------------
-- Function: DisableMove
--
-- This function disables / enables moving
---------------------------------------------------------------------
function EasyFrameIconBar:DisableMove(disable)
  self.moveDisabled = disable
  local textureNormal = self.ui:GetNamedChild("NormalTexture")
  textureNormal:SetMovable(not disable)
end

---------------------------------------------------------------------
-- Function: IsMoveDisabled
--
-- This function gets the move disabled state
---------------------------------------------------------------------
function EasyFrameIconBar:IsMoveDisabled()
  return self.moveDisabled
end

---------------------------------------------------------------------
-- Function: GetIconBar
--
-- This function gets the icon bar object associated with the control
-- tree
---------------------------------------------------------------------
function EasyFrameIconBar:GetIconBar(control)
  return getIconBar(control)
end


---------------------------------------------------------------------
-- Function: GetIconAlphaMin
--
-- This function is called to get the min alpha for the main icon
---------------------------------------------------------------------
function EasyFrameIconBar:GetIconAlphaMin()
  if not self.savedVars.iconAlphaMin then
    return self.iconAlphaMinDefault
  end
  return self.savedVars.iconAlphaMin
end

---------------------------------------------------------------------
-- Function: SetIconAlphaMin
--
-- This function is called to set the min alpha for the main icon
---------------------------------------------------------------------
function EasyFrameIconBar:SetIconAlphaMin(min)
  self.savedVars.iconAlphaMin = min 
  if self.ui.fadeAnimIcon then
    self.ui.fadeAnimIcon:SetMinMaxAlpha(min, FADE_MAX_ALPHA)
  end
end

---------------------------------------------------------------------
-- Function: SetIconTooltip
--
-- This function is called to set the main icon tooltip
---------------------------------------------------------------------
function EasyFrameIconBar:SetIconTooltip(tooltip)
  self.iconTooltip = tooltip
end

---------------------------------------------------------------------
-- Function: GetIconTooltip
--
-- This function is called to get the main icon tooltip
---------------------------------------------------------------------
function EasyFrameIconBar:GetIconTooltip()
  return self.iconTooltip
end


---------------------------------------------------------------------
-- Function: GetSavedLeft
--
-- This function is called to get the saved left position of the icon bar
---------------------------------------------------------------------
function EasyFrameIconBar:GetSavedLeft()
  if not self.savedVars.left then
    return 100
  else
    return self.savedVars.left
  end
end

---------------------------------------------------------------------
-- Function: SetSavedLeft
--
-- This function is called to save the left position of the icon bar
---------------------------------------------------------------------
function EasyFrameIconBar:SetSavedLeft(left)
  if left == nil then
    left = self.ui:GetLeft()
  end
  self.savedVars.left = left
  trace("SetSavedLeft["..left.."]")    
end

---------------------------------------------------------------------
-- Function: GetSavedTop
--
-- This function is called to get the saved top position of the icon bar
---------------------------------------------------------------------
function EasyFrameIconBar:GetSavedTop()
  if not self.savedVars.top then
    return 100
  else
    return self.savedVars.top
  end
end

---------------------------------------------------------------------
-- Function: SetSavedTop
--
-- This function is called to save the top position of the icon bar
---------------------------------------------------------------------
function EasyFrameIconBar:SetSavedTop(top)
  if top == nil then
    top = self.ui:GetTop()
  end
  self.savedVars.top = top
  trace("SetSavedTop["..top.."]")  
end

---------------------------------------------------------------------
-- Function: OnMoveStop
--
-- This function is called when the icon bar is moved
---------------------------------------------------------------------
local function onMoveStop(control)
  trace("OnMoveStop")
  local iconBar = getIconBar(control)
  if iconBar then
    local left = control:GetLeft() - 5
    local top = control:GetTop() - 5
    iconBar:SetSavedLeft(left)
    iconBar:SetSavedTop(top)
    iconBar:RestorePosition()
    -- the dragged control needs to be reanchored as it appears
    -- to lose this when dragging
    control:ClearAnchors()
    control:SetSimpleAnchor(iconBar.ui, 5, 5)
  end    
end

---------------------------------------------------------------------
-- Function: RestorePosition
--
-- This function is called to restore the bar to the saved postions
---------------------------------------------------------------------
function EasyFrameIconBar:RestorePosition()
  local left = self:GetSavedLeft()
  local top = self:GetSavedTop()
  local control = self.ui

  control:SetSimpleAnchorParent(left, top)
end

---------------------------------------------------------------------
-- Function: OnMouseEnter
--
-- This function is called by the instanced class
---------------------------------------------------------------------
function EasyFrameIconBar:Initialise(control, savedVars, minIconAlpha)
  trace("Initialise")
  self.ui = control
  local name = control:GetName()
  if not savedVars[name] then
    savedVars[name] = {}
  end
  self.savedVars = savedVars[name] 
  
  if minIconAlpha == nil then
    self:SetIconAlphaMin(minIconAlpha)
  end
  
  if control then
    control.iconBar = self
    control:SetDrawLevel(0)
    
    local textureNormal = control:GetNamedChild("NormalTexture")
    if textureNormal then
      control.fadeAnimIcon = ZO_AlphaAnimation:New(textureNormal)
      local alphaIconMin = self:GetIconAlphaMin()
      control.fadeAnimIcon:SetMinMaxAlpha(alphaIconMin, FADE_MAX_ALPHA)
      textureNormal:SetAlpha(alphaIconMin)
      textureNormal:SetHandler("OnMoveStop", onMoveStop) 
      textureNormal:SetDrawLevel(1)
    end    

    self:RestorePosition()
    
    --control:SetHandler("OnMoveStop", onMoveStop)
    if self:IsDisabled() then
      self:SetHidden(true)
    end
    
    -- hook
    self:HookMouseExitTree(control)
    self:Contract()
    
    if self.OnInitialised then
      self:OnInitialised(control)
    end
  end
end

---------------------------------------------------------------------
-- Function: GetSavedVars
--
-- This function returns the saved vars
---------------------------------------------------------------------
function EasyFrameIconBar:GetSavedVars()
  return self.savedVars
end

---------------------------------------------------------------------
-- Function: OnMouseEnterIcon
--
-- This function is the mouse enter event for the main icon
---------------------------------------------------------------------
function EasyFrameIconBar:OnMouseEnterIcon(control)
  trace("OnMouseIconEnter")
  local parent = control:GetParent()
  if parent and parent.iconBar then
    local iconBar = parent.iconBar
    if iconBar.OnMouseEnterMainIcon then
      iconBar:OnMouseEnterMainIcon(control)
    end
    ZO_Tooltips_ShowTextTooltip(control, TOP, iconBar:GetIconTooltip())
    iconBar:StartFadeIn()
  end
end

---------------------------------------------------------------------
-- Function: OnMouseExit
--
-- This function is the mouse exit event for the main icon
---------------------------------------------------------------------
function EasyFrameIconBar:OnMouseExitIcon(control)
  trace("OnMouseIconExit")
  ZO_Tooltips_HideTextTooltip() 
end
          

---------------------------------------------------------------------
-- Function: OnMouseDownIcon
--
-- This function is the mouse down event for the main icon
---------------------------------------------------------------------
function EasyFrameIconBar:OnMouseDownIcon(control, button)
  trace("OnMouseDownIcon")  
  local parent = control:GetParent()
  if parent and parent.iconBar then
    local mouseDownData = parent.iconBar.mouseDownData
    if not mouseDownData then
      mouseDownData = {}
      parent.iconBar.mouseDownData = mouseDownData
    end
    mouseDownData.left = control:GetLeft()
    mouseDownData.top = control:GetTop()
    parent.iconBar:EnableFade(false)
  end  
end

---------------------------------------------------------------------
-- Function: OnMouseUpIcon
--
-- This function is the mouse down event for the main icon
---------------------------------------------------------------------
function EasyFrameIconBar:OnMouseUpIcon(control, button)
  trace("OnMouseUpIcon")
  local parent = control:GetParent()
  if parent and parent.iconBar then
    local mouseDownData = parent.iconBar.mouseDownData
    --trace("mdLeft["..mouseDownData.left.."], mdTop["..mouseDownData.top.."]")
    local left = control:GetLeft()
    local top = control:GetTop()
    --trace("left["..left.."], top["..top.."]")    
    if mouseDownData.left == left and mouseDownData.top == top then
      -- a click happened
      if parent.iconBar.OnClickedIcon then
        parent.iconBar:OnClickedIcon(control, button)
      end
    end
    
    parent.iconBar:EnableFade(true)
  end    
end          


---------------------------------------------------------------------
-- Function: HookMouseExitTree
--
-- This function will hook the mouseexit event in the controls in the tree
---------------------------------------------------------------------
function EasyFrameIconBar:HookMouseExitTree(control)
  
  if not control.iconBarMouseExit then  
    control.iconBarMouseExit = control:GetHandler("OnMouseExit")
    control:SetHandler("OnMouseExit", mouseExitHandler)      
  end
    
  local numChildren = control:GetNumChildren() 
  for i = 1, numChildren do
    local child = control:GetChild(i)
    self:HookMouseExitTree(child)
  end  

end

---------------------------------------------------------------------
-- Function: EnableFade
--
-- This function enables or disables fading
---------------------------------------------------------------------
function EasyFrameIconBar:EnableFade(fade)
  self.enableFade = fade
end

---------------------------------------------------------------------
-- Function: Expand
--
-- This function expands the icon bar
---------------------------------------------------------------------
function EasyFrameIconBar:Expand(iconBarControl)
  trace("Expand") 
  if self.isExpanded then
    trace("Already Expanded")
    return
  end

  self.isExpanded = true
  self:HideButtons(false)  
  local barTexture = iconBarControl:GetNamedChild("BarTexture")
  if barTexture then
    local min = 10000000
    local max = 0
    
    local numChildren = barTexture:GetNumChildren() 
    for i = 1, numChildren do
      local child = barTexture:GetChild(i)
      local left = child:GetLeft()
      if left < min then
        min = left
      end
      local right = child:GetRight()
      
      if right > max then
        max = right
      end     
    end
    
    trace("Min["..min.."], max["..max.."]")
    iconBarControl:SetDimensions(max - min + 30, 40)

  else
    iconBarControl:SetDimensions(100, 40)  
  end

end

---------------------------------------------------------------------
-- Function: Contract
--
-- This function contracts the icon bar. Control is the toplevelwindow
---------------------------------------------------------------------
function EasyFrameIconBar:Contract()
  trace("Contract")  
  self.isExpanded = false
  self.ui:SetDimensions(40, 40)
  self:HideButtons(true)
end

---------------------------------------------------------------------
-- Function: HideButtons
--
-- This function contracts hides the buttons in the bar
---------------------------------------------------------------------
function EasyFrameIconBar:HideButtons(hide)
  local iconBarControl = self.ui
  local barTexture = iconBarControl:GetNamedChild("BarTexture")
  if barTexture then
    local children = barTexture:GetNumChildren() 
    for i = 1, children do
      local child = barTexture:GetChild(i)
      child:SetHidden(hide)
    end    
  end
 
end


