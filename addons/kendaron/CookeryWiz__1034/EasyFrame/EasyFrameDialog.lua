
EasyFrameDialog = EasyFrame:new()

EasyFrameDialog.name = "EasyFrameDialog"

EasyFrameDialog.dialogControl = nil
EasyFrameDialog.contentControl = nil

---------------------------------------------------------------------
-- Overrides
---------------------------------------------------------------------


function EasyFrameDialog:GetWindow()
  return self.contentControl
end

---------------------------------------------------------------------
-- General
---------------------------------------------------------------------


function EasyFrameDialog:ShowDialog(parent)
  local contentOverflow = 40
  
  if not self.dialogControl then
    d("No dialog control set")
    return
  end
  self.parent = parent
  local parentWindow = parent:GetWindow()

  -- we need to size and place the content control, not the parent
  local contentControl = self.contentControl
  local dialogControl = self.dialogControl
  self:HideWindow(false)

--[[
  -- Set the size of this top level window to be the size of the parent window
  dialogControl:ClearAnchors()
  dialogControl:SetAnchor(TOPLEFT, parentWindow, TOPLEFT, -1 * contentOverflow, -1 * contentOverflow)   
  dialogControl:SetAnchor(BOTTOMRIGHT, parentWindow, BOTTOMRIGHT, contentOverflow, contentOverflow)  
  --d("L["..dialogControl:GetLeft().."],T["..dialogControl:GetTop().."],W["..dialogControl:GetWidth().."],H["..dialogControl:GetHeight().."]")    
    
  self:CenterControl(dialogControl, contentControl)
  ]]--
  
  CookeryWizUtils:CenterDialog(parentWindow, dialogControl)
  dialogControl:SetAlpha(1)
  --self.dialogControl:SetTopmost(true) 
  --CookeryWizUtils:SetTopmost(self.dialogControl, true)
  self.dialogControl:BringWindowToTop()
  
  if false then
    local chatEdgeEnabled = parent:IsChatEdgeEnabled()
    self:EnableChatEdge(chatEdgeEnabled)
    if chatEdgeEnabled then    
      self:AdjustChatTheme(32, 0.8, 16, 16)
    end
    self.textureDefaultControl:SetHidden(chatEdgeEnabled)
    self.textureChatEdgeControl:SetHidden(not chatEdgeEnabled)
  end
  
end

function EasyFrameDialog:GetParent()
  return self.parent
end

function EasyFrameDialog:InitializeEasyFrameDialog(title, dialogControl)
  self.dialogControl = dialogControl
  self.contentControl = dialogControl:GetNamedChild("Content")
    
  self.easyFrameVariables.width = self.contentControl:GetWidth()
  self.easyFrameVariables.height = self.contentControl:GetHeight()
  self.easyFrameVariables.widthMin = self.easyFrameVariables.width
  self.easyFrameVariables.heightMin = self.easyFrameVariables.height
  
  self.ui = dialogControl
  
  if not self.ui then
      d("No TopLevelControl passed")
      return
  end 
  
  -- Find and initialise the controls
  self:InitialiseControls(self.contentControl, title)  

  -- Always start a dialog off hidden
  self:HideWindow(true)
end