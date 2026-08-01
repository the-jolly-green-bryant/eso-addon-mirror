
GuildBankTwiddlerAutoHide = {}
GuildBankTwiddlerAutoHide.parentControl = nil
GuildBankTwiddlerAutoHide.autoHideControls = {}

GuildBankTwiddlerAutoHide.traceEnabled = false

local function trace(msg)
  if GuildBankTwiddlerAutoHide.traceEnabled then
    GuildBankTwiddlerUtils:Trace(msg)
  end
end

---------------------------------------------------------------------
-- Function: New
--
-- This function is called to create an instance of an
-- auto hide object
---------------------------------------------------------------------
function GuildBankTwiddlerAutoHide:New()
  o = {}

  setmetatable(o, self)
  self.__index = self
  return o  
end

GuildBankTwiddlerAutoHide.timerStarted = false

function GuildBankTwiddlerAutoHide:StartTimer()
  if self.timerStarted then
    return
  end
   
  local function callLater()
    trace("called later")
    local over = false

    local control = moc()
    if control then   
      while control do
        if control.autoHideParent then
          over = true
          break
        end
        control = control:GetParent()
      end
    end
    if over then
      self.timerStarted = true
      zo_callLater(callLater, 150)   
    else
      self.timerStarted = false
    end
    self:HideControls(not over)
  end
  
  callLater()
end


local function OnMouseEnter(control)
  trace("OnMouseEnter")
  local self = control.autoHideParent
  if not self then
    local parent = control:GetParent()    
    while parent do
      self = parent.autoHideParent
      if self then
        break
      end
      parent = parent:GetParent()
    end
  end
  
  if not self then
    d("Problem getting autoHideParent!")
    return
  end
  
  self:StartTimer()
      
  if control.oldOnMouseEnter then
    control.oldOnMouseEnter(control)
  end 
end

local function OnMouseExit(control)
  trace("OnMouseExit")
  if control.oldOnMouseExit then
    control.oldOnMouseExit(control)
  end   
end

---------------------------------------------------------------------
-- Function: SetParent
--
-- This function is called to set the parent. It will hide the auto
-- hide controls
---------------------------------------------------------------------
function GuildBankTwiddlerAutoHide:SetParent(parentControl)
  trace("SetParent")
  if self.parentControl then
    self.parentControl.autoHideParent = nil    
  end
  
  parentControl.autoHideParent = self  
  self.parentControl = parentControl
  
  self:HideControls(true)
  
  -- get rid of the previous list of controls
  self.autoHideControls = {}
  
  self:SetOverControl(parentControl)
end

---------------------------------------------------------------------
-- Function: EnableAutoHide
--
-- Called to enabled auto hide ability
---------------------------------------------------------------------
function GuildBankTwiddlerAutoHide:EnableAutoHide(enable)
  trace("GuildBankTwiddlerAutoHide:EnableAutoHide")
  self.autohideEnabled = enable
  self:HideControls(enable)
end

---------------------------------------------------------------------
-- Function: IsAutoHideEnabled
--
-- Called to get state of auto hide
---------------------------------------------------------------------
function GuildBankTwiddlerAutoHide:IsAutoHideEnabled()
  trace("GuildBankTwiddlerAutoHide:IsAutoHideEnabled")
  return self.autohideEnabled
end

---------------------------------------------------------------------
-- Function: SetParent
--
-- This function is called to set the parent. It will hide the auto
-- hide controls
---------------------------------------------------------------------
function GuildBankTwiddlerAutoHide:SetParent(parentControl)
  trace("SetParent")
  if self.parentControl then
    self.parentControl.autoHideParent = nil    
  end
  
  parentControl.autoHideParent = self  
  self.parentControl = parentControl
  
  self:HideControls(true)
  
  -- get rid of the previous list of controls
  self.autoHideControls = {}
  
  self:SetOverControl(parentControl)
end

---------------------------------------------------------------------
-- Function: SetOverControl
--
-- This function is called to add a control to start the detection
-- process
---------------------------------------------------------------------
function GuildBankTwiddlerAutoHide:SetOverControl(control)
  -- setup handler only if not done before
  if control.oldOnMouseEnter then
    return
  end
  
  control.oldOnMouseEnter = control:GetHandler("OnMouseEnter")
  control:SetHandler("OnMouseEnter", OnMouseEnter)
 
  control.oldOnMouseExit = control:GetHandler("OnMouseExit") 
  control:SetHandler("OnMouseExit", OnMouseExit)  
end

---------------------------------------------------------------------
-- Function: HideControls
--
-- This function is called to show or hide the autohide controls
---------------------------------------------------------------------
function GuildBankTwiddlerAutoHide:HideControls(hide)
  if self.autohideEnabled ~= true then
    hide = false
  end
  for i = 1, #self.autoHideControls do
    local autoHideControl = self.autoHideControls[i]
    autoHideControl:SetHidden(hide)
  end  
end

---------------------------------------------------------------------
-- Function: AddAutoHideControl
--
-- This function is called to add a control to auto hide
---------------------------------------------------------------------
function GuildBankTwiddlerAutoHide:AddAutoHideControl(control)
  self.autoHideControls[#self.autoHideControls + 1] = control   
end