
CookeryWizAutoHide = {}
CookeryWizAutoHide.parentControl = nil
CookeryWizAutoHide.autoHideControls = {}

CookeryWizAutoHide.traceEnabled = true

local function trace(msg)
  if CookeryWizAutoHide.traceEnabled then
    CookeryWizUtils:Trace(msg)
  end
end

---------------------------------------------------------------------
-- Function: New
--
-- This function is called to create an instance of an
-- auto hide object
---------------------------------------------------------------------
function CookeryWizAutoHide:New(parentControl)
  o = {}

  setmetatable(o, self)
  self.__index = self
  return o  
end

local function OnMouseEnter(control)
  trace("OnMouseEnter")
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
function CookeryWizAutoHide:SetParent(parentControl)
  trace("SetParent")
  if self.parentControl then
    self.parentControl.autoHideParent = nil    
  end
  
  parentControl.autoHideParent = self  
  self.parentControl = parentControl
  
  self:HideControls(true)
  
  -- get rid of the previous list of controls
  self.autoHideControls = {}
  
  -- setup handler only if not done before
  if parentControl.oldOnMouseEnter then
    return
  end
  
  parentControl.oldOnMouseEnter = parentControl:GetHandler("OnMouseEnter")
  parentControl:SetHandler("OnMouseEnter", OnMouseEnter)
 
  parentControl.oldOnMouseExit = parentControl:GetHandler("OnMouseExit") 
  parentControl:SetHandler("OnMouseExit", OnMouseExit)

end
  
  ---------------------------------------------------------------------
-- Function: HideControls
--
-- This function is called to show or hide the autohide controls
---------------------------------------------------------------------
function CookeryWizAutoHide:HideControls(hide)
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
function CookeryWizAutoHide:AddAutoHideControl(control)
  self.autoHideControls[#self.autoHideControls + 1] = control
   
end