local L = EasyFrameLanguage.language

-- offset for unacknowledged icons
local startOffset = 20

EasyFrameMiniBar = {}
EasyFrameMiniBar.easyFrame = nil
EasyFrameMiniBar.displayButtonTooltip = ""

EasyFrameMiniBar.traceEnabled = false

local function trace(msg)
  if EasyFrameMiniBar.traceEnabled then
    d(GetTimeString()..":"..msg)
  end
end


local function onMiniBarIconClicked(iconBar, control, button)
  trace("onMiniBarIconClicked")
  if iconBar then
      iconBar.easyFrame:ToggleWindow()
  end  
end

--[[
local BORDER_TEXTURE_NORMAL = "EsoUI/Art/Tooltips/UI-Border.dds"
local DIVIDER_TEXTURE_NORMAL = "EsoUI/Art/Miscellaneous/horizontalDivider.dds"
local TOOLTIP_EDGE_WIDTH  = 128
local TOOLTIP_EDGE_HEIGHT = 16

function EasyFrameMiniBar:CreateBurstAnimation()
  
  if self.resultTooltipAnimation then
      return
  end
  d("Creating animation")
  self.resultTooltipAnimation = ANIMATION_MANAGER:CreateTimelineFromVirtual("CraftingResultTooltipAnimation")
  local miniBarControl = self.ui
  
  local textureNormal = miniBarControl:GetNamedChild("BurstTexture")
    
  self.resultTooltipAnimation:GetAnimation(1):SetAnimatedControl(textureNormal)
  self.resultTooltipAnimation:GetAnimation(2):SetAnimatedControl(textureNormal)
  

  local tooltipGlow = miniBarControl:GetNamedChild("Glow")
  self.tooltipGlow = tooltipGlow
  --self.tooltipGlow:SetEdgeTexture("EsoUI/Art/Crafting/crafting_toolTip_glow_edge_blue64.dds", 512, 64)
  --self.tooltipGlow:SetEdgeTexture(BORDER_TEXTURE_NORMAL, TOOLTIP_EDGE_WIDTH, TOOLTIP_EDGE_HEIGHT)
  
  self.resultTooltipAnimation:GetAnimation(3):SetAnimatedControl(tooltipGlow)
  
  local tooltipBurst1 = miniBarControl:GetNamedChild("IconBurst1")
  self.tooltipBurst1 = tooltipBurst1
  self.resultTooltipAnimation:GetAnimation(4):SetAnimatedControl(tooltipBurst1)
  
  local tooltipBurst2 = miniBarControl:GetNamedChild("IconBurst2")
  self.tooltipBurst2 = tooltipBurst2
  self.resultTooltipAnimation:GetAnimation(5):SetAnimatedControl(tooltipBurst2)
  
  self.resultTooltipAnimation:GetAnimationTimeline(1):GetAnimation(1):SetAnimatedControl(tooltipBurst1)
  self.resultTooltipAnimation:GetAnimationTimeline(1):GetAnimation(2):SetAnimatedControl(tooltipBurst2)
  
  local function OnStop(animation)
      tooltipGlow:SetAlpha(0)
      tooltipBurst1:SetAlpha(0)
      tooltipBurst2:SetAlpha(0)
      --self:OnTooltipAnimationStopped()
  end
  
  self.forceStopHandler = function()
      textureNormal:SetAlpha(1)
      OnStop()
  end
  
  self.resultTooltipAnimation:GetAnimation(1):SetHandler("OnStop", OnStop)

end

function EasyFrameMiniBar:PlayHighlightAnimation1()
  self:CreateBurstAnimation()
  
  --self:ForceStop()
  --self.tooltipGlow:SetEdgeTexture("EsoUI/Art/Crafting/crafting_toolTip_glow_edge_blue64.dds", 512, 64)

  self.resultTooltipAnimation:GetAnimation(3):SetDuration(500)
  self.resultTooltipAnimation:GetAnimation(3):SetAlphaValues(0, 1)

  self.tooltipBurst1:SetHidden(false)
  self.tooltipBurst2:SetHidden(false)
  self.resultTooltipAnimation:PlayFromStart()
  --PlaySound(failure and self.tooltipAnimationFailureSound or self.tooltipAnimationSuccessSound)

end
]]--

local function onPulseStop(animation, control)
  trace("onPulseStop")
  
  local iconBar = EasyFrameIconBar:GetIconBar(control)
  local savedVars = iconBar:GetSavedVars()
  if not savedVars.iconAcknowledged then
    zo_callLater(function()
        control.pulseAnimation:PlayFromStart()
      end, 2000)
  end
  --tooltipGlow:SetAlpha(0)
  --tooltipBurst1:SetAlpha(0)
  --tooltipBurst2:SetAlpha(0)
  --self:OnTooltipAnimationStopped()
end


---------------------------------------------------------------------
-- Function: New
--
-- This function is called to create a new minibar
-- As we are using inheritance we create the instances
-- then join them through the CreateClass routine
---------------------------------------------------------------------
function EasyFrameMiniBar:New(easyFrame, hide, miniBarControl, minIconAlpha)
  local iconBar = EasyFrameIconBar:New()
  local miniBar = EasyFrameMiniBar:Create()
  o = EasyFrameUtils.CreateClass(iconBar, miniBar)
  o.easyFrame = easyFrame
  o.OnClickedIcon = onMiniBarIconClicked
  if not miniBarControl then
    miniBarControl = CreateControlFromVirtual(easyFrame.name.."MiniBarUI", nil, "EasyFrameMiniBar")
  end
  miniBarControl:SetHidden(hide)
  o:Initialise(miniBarControl, easyFrame.easyFrameVariables, minIconAlpha) 
  
  o:SetDragTooltip()
  -- this replaces shrink until shrink code is removed
  easyFrame:DisableShrink(true)
  return o  
end

function EasyFrameMiniBar:SetDragTooltip()
  local tooltip = string.format(L[EASYFRAME_TEXTURE_MINIBAR_ICON_DRAG_TOOLTIP], self.easyFrame.name)
  self:SetIconTooltip(tooltip)  
end

function EasyFrameMiniBar:SetNormalTooltip()
  local tooltip = string.format(L[EASYFRAME_TEXTURE_MINIBAR_ICON_TOOLTIP], self.easyFrame.name)
  self:SetIconTooltip(tooltip)  
end
---------------------------------------------------------------------
-- Function: Create
--
-- This function is called to create a new minibar object instance
---------------------------------------------------------------------
function EasyFrameMiniBar:Create()
  o = {}
  setmetatable(o, self)
  self.__index = self
  return o   
end

---------------------------------------------------------------------
-- Function: OnIntialised
--
-- This function is called when the Initialise function is finished
---------------------------------------------------------------------
function EasyFrameMiniBar:OnInitialised(control)
  trace("OnInitialised")
  local savedVars = self:GetSavedVars()
  if not savedVars.iconAcknowledged then
    -- position it in an easy to find location
    local height = GuiRoot:GetHeight()
    local width =  GuiRoot:GetWidth()
    self:SetSavedLeft( (width / 2) - startOffset)
    self:SetSavedTop(height / 4)
    self:RestorePosition()
    startOffset = startOffset - 40
    local textureNormal = control:GetNamedChild("NormalTexture")
    zo_callLater(function()
      EasyFrameUtils:PlayHighlightAnimation(textureNormal, onPulseStop)
      end, 2000)
  end
end

---------------------------------------------------------------------
-- Function: GetMainIcon
--
-- This function gets the main icon
---------------------------------------------------------------------
function EasyFrameMiniBar:GetMainIcon()
  local textureNormal = self.ui:GetNamedChild("NormalTexture")
  return textureNormal
end

---------------------------------------------------------------------
-- Function: OnMouseEnterMainIcon
--
-- This function is called to when the mouse enters the main fade icon
---------------------------------------------------------------------
function EasyFrameMiniBar:OnMouseEnterMainIcon(control)
  trace("OnMouseEnterMainIcon")
  local savedVars = self:GetSavedVars()
  savedVars.iconAcknowledged = true
end

--[[
---------------------------------------------------------------------
-- Function: SetAddonName
--
-- This function is called to set the name for the addon
-- This will affect the tooltips
---------------------------------------------------------------------
function EasyFrameMiniBar:SetAddonName(addonName)
  self.addonName = addonName
  local tooltip = string.format(L[EASYFRAME_TEXTURE_ICON_TOOLTIP], addonName)
  self:SetIconTooltip(tooltip)
end

---------------------------------------------------------------------
-- Function: GetAddonName
--
-- This function is called to get the addon name associated with this
-- mini bar
---------------------------------------------------------------------
function EasyFrameMiniBar:GetAddonName()
  return self.addonName
end


---------------------------------------------------------------------
-- Function: SetDisplayButtonTooltip
--
-- This function is called to set the display button tooltip
---------------------------------------------------------------------
function EasyFrameMiniBar:SetDisplayButtonTooltip(tooltip)
  self.displayButtonTooltip = tooltip
end

---------------------------------------------------------------------
-- Function: GetDisplayButtonTooltip
--
-- This function is called to get the display button tooltip
---------------------------------------------------------------------
function EasyFrameMiniBar:GetDisplayButtonTooltip()
  return self.displayButtonTooltip
end

---------------------------------------------------------------------
-- Function: OnMouseEnterDisplayButton
--
-- This function is called to when the mouse enters the display button
---------------------------------------------------------------------
function EasyFrameMiniBar:OnMouseEnterDisplayButton(control)
  trace("OnMouseEnterDisplayButton")  
  local iconBar = EasyFrameIconBar:GetIconBar(control)  
  if iconBar then
    local barTexture = iconBar.ui:GetNamedChild("BarTexture")
    if barTexture then
      local displayButton = barTexture:GetNamedChild("DisplayButton")
      if displayButton then
        ZO_Tooltips_ShowTextTooltip(control, TOP, iconBar:GetDisplayButtonTooltip())
      end
    end    
  end
end

---------------------------------------------------------------------
-- Function: OnMouseExitDisplayButton
--
-- This function is called to when the mouse exits the display button
---------------------------------------------------------------------
function EasyFrameMiniBar:OnMouseExitDisplayButton(control)
  trace("OnMouseExitDisplayButton")
  ZO_Tooltips_HideTextTooltip() 
end
]]--
--[[
---------------------------------------------------------------------
-- Function: OnClickedDisplayButton
--
-- This function is called to when the display button is clicked
---------------------------------------------------------------------
function EasyFrameMiniBar:OnClickedDisplayButton(control, button)

  trace("OnClickedDisplayButton")
  local iconBar = EasyFrameIconBar:GetIconBar(control)  
  if iconBar and iconBar.OnDisplayAddon then
    iconBar:OnDisplayAddon()
  end 

end
]]--
--[[
---------------------------------------------------------------------
-- Function: OnClickedIcon
--
-- This function is called to when the display button is clicked
---------------------------------------------------------------------
function EasyFrameMiniBar:OnClickedIcon(control, button)
  trace("OnClickedIcon")
  local iconBar = EasyFrameIconBar:GetIconBar(control)  
  if iconBar and iconBar.OnIconClicked then
    iconBar:OnIconClicked()
  end  
end
]]--