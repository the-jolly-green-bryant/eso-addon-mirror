EPT = EPT or {}
local EPT = EPT

function EPT:GetFont(fontNo)
  local fonts= {
    [1] = "EsoUI/Common/Fonts/Univers57.otf",
    [2] = "EsoUI/Common/Fonts/Univers67.otf",
    [3] = "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
    [4] = "EsoUI/Common/Fonts/Handwritten_Bold.otf",
    [5] = "EsoUI/Common/Fonts/TrajanPro-Regular.otf",
  }
  return fonts[fontNo]
end

local function GetEdgeLine(iconSize)
  if iconSize > 100 then return 4
  else return 2 end
end

function EPT:GetGuiData(setId)
  local design = self.store.design
  local setInfo =  self.procSets[setId]
  return {
    name = tostring(setId),
    iconSize = design.iconSize,
    edgeSize = design.edge.size,
    edgeLine = GetEdgeLine(design.iconSize),
    primaryIndicatorSize = math.floor(design.iconSize * design.indicator.size / 10 ),
    nameOffSet = design.edge.size - GetEdgeLine(design.iconSize),
    design = self.store.design,
  }
end

function EPT:GetDesignGuiData(setId)
  local design = self.store.design
  return {
    iconSize = design.iconSize,
    edgeSize = design.edge.size,
    edgeLine = GetEdgeLine(design.iconSize),
    primaryIndicatorSize = math.floor(design.iconSize * design.indicator.size / 10 ),
    nameOffSet = design.edge.size - GetEdgeLine(design.iconSize),
    design = design
  }
end



function EPT:UpdateColor(gui,status)
  local design = self.store.design
  if gui.edge then
    if design.edge.changeColor then
      gui.edge:SetCenterColor(unpack(design.color[status]))
    else
      gui.edge:SetCenterColor(0,0,0, 0.3)
    end
  end
  if design.indicator.changeColor then
    gui.label:SetColor(unpack(design.color[status]))
  else
    gui.label:SetColor(1,1,1,1)
  end
end

function EPT:CreateGui(setId)
  local name = tostring(setId)
  local gui = {}

  gui.win = self.window:CreateTopLevelWindow(name)
  gui.win:SetClampedToScreen(true)
  gui.win:SetMouseEnabled(true)
  gui.win:SetMovable(true)
  gui.win:ClearAnchors()
  gui.win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, self.store[setId].left, self.store[setId].top )
  gui.win:SetHidden(true)
  gui.win:SetHandler( "OnMoveStop", function( )
      self.store[setId].left = gui.win:GetLeft()
      self.store[setId].top = gui.win:GetTop()
    end)
  --win:SetHandler( "OnMouseEnter", function() self.guiList[setId].nameDisplay.ctrl:SetHidden(false) end )
  --win:SetHandler( "OnMouseExit", function() self.guiList[setId].nameDisplay.ctrl:SetHidden(not design.nameDisplay.mouseMode) end )

  --PrimaryIndicator
  gui.primaryInd = {}
  gui.primaryInd.ctrl = self.window:CreateControl(name.."PrimaryControl", gui.win, CT_CONTROL )
  gui.primaryInd.edge = self.window:CreateControl(name.."PrimaryEdge", gui.primaryInd.ctrl, CT_BACKDROP )
  gui.primaryInd.back = self.window:CreateControl(name.."PrimaryBackground", gui.primaryInd.ctrl, CT_BACKDROP )
  gui.primaryInd.icon = self.window:CreateControl(name.."PrimaryIcon", gui.primaryInd.ctrl, CT_TEXTURE )
  gui.primaryInd.label = self.window:CreateControl(name.."PrimaryIndicator", gui.primaryInd.ctrl, CT_LABEL )

  --NameDisplay
  gui.nameDisplay = {}
  gui.nameDisplay.ctrl = self.window:CreateControl(name.."NameControl", gui.win, CT_CONTROL )
  gui.nameDisplay.back = self.window:CreateControl(name.."NameBackground", gui.nameDisplay.ctrl, CT_BACKDROP )
  gui.nameDisplay.label = self.window:CreateControl(name.."NameLabel", gui.nameDisplay.ctrl, CT_LABEL )

  gui.frag = ZO_HUDFadeSceneFragment:New( gui.win )
  self:SetDesign(setId, gui)

  if setId ~= "demo" then
    if self.procSets[setId].type == "special" then
      gui.secondaryInd = self:GetSecondaryIndicator(setId, gui.win)
      gui.tertiaryInd = self:GetTertiaryIndicator(setId, gui.win)
	elseif self.procSets[setId].type == "stackself" or self.procSets[setId].type == "stacktarget" then
      gui.secondaryInd = self:GetSecondaryIndicator(setId, gui.win)
    end
  end
  return gui
end

function EPT:UpdateDesign()
  for setId, gui in pairs(self.guiList) do
      self:SetDesign(setId, gui)
  end
  self:SetDesign("demo", self.demo.set)
end

function EPT:SetDesign(setId, gui)
  --local data = self:GetDesignGuiData()
  local setInfo
  if setId ~= "demo" then setInfo = self.procSets[setId]
  else
    setInfo = {
      ["abilityId"] = 97855,
      ["icon"] = GetAbilityIcon(97855),
      ["setName"] = "Example Set",
    }
  end
  local name = tostring(setId)

  local design = self.store.design
  local iconSize = design.iconSize
  local edgeSize = design.edge.size
  local edgeLine = ( iconSize > 100 ) and 4 or 2
  local texture = ( LUIE or not setInfo.icon ) and GetAbilityIcon( setInfo.abilityId ) or setInfo.icon
  local nameOffSet = edgeSize - edgeLine


  --local primaryIndicatorSize =

  gui.win:SetDimensions( iconSize , iconSize )

  --Primary Indicator
  local primary = gui.primaryInd
  gui.primaryInd.ctrl:ClearAnchors()
  primary.ctrl:SetAnchor( CENTER, gui.win, CENTER, 0, 0 )
  primary.ctrl:SetDimensions( iconSize , iconSize )

  primary.edge:ClearAnchors()
  primary.edge:SetAnchor( CENTER, primary.ctrl, CENTER, 0, 0 )
  primary.edge:SetDimensions( iconSize + 2*( edgeSize + edgeLine ) , iconSize + 2*( edgeSize + edgeLine ) )
  primary.edge:SetEdgeColor( 0, 0, 0, 1 )
  primary.edge:SetCenterColor( 0, 0, 0, 0.3 )
  primary.edge:SetEdgeTexture( nil , edgeLine , edgeLine , edgeLine)
  primary.edge:SetHidden( not design.edge.show )

  primary.back:ClearAnchors()
  primary.back:SetAnchor( CENTER, primary.ctrl, CENTER, 0, 0 )
  primary.back:SetDimensions( iconSize , iconSize)
  primary.back:SetEdgeColor( 0, 0, 0, 1)
  primary.back:SetCenterColor(0, 0, 0, 1)
  primary.back:SetEdgeTexture( nil , edgeLine , edgeLine , edgeLine )

  primary.icon:ClearAnchors()
  primary.icon:SetAnchor( CENTER, primary.ctrl, CENTER, 0, 0 )
  primary.icon:SetDimensions( iconSize - 2*edgeLine , iconSize - 2*edgeLine )
  primary.icon:SetTexture( texture )
  primary.icon:SetAlpha(1)

  primary.label:ClearAnchors()
  primary.label:SetAnchor( CENTER, primary.ctrl, CENTER, design.indicator.offSetX, design.indicator.offSetY )
  primary.label:SetDimensions( iconSize , iconSize )
  primary.label:SetColor( 1, 1, 1, 1 )
  primary.label:SetFont( self:GetFont(design.indicator.font).. "|" .. math.floor( design.iconSize * design.indicator.size / 10 ) .. "|soft-shadow-thick" )
  primary.label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  primary.label:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
  primary.label:SetText("")

  --SetName Display
  local nameDisp = gui.nameDisplay

  nameDisp.ctrl:ClearAnchors()
  if design.nameDisplay.position == "above" then
    nameDisp.ctrl:SetAnchor(BOTTOM, gui.win, TOP, 0, -nameOffSet ) -- minus hoch
  elseif design.nameDisplay.position == "below" then
    nameDisp.ctrl:SetAnchor(TOP, gui.win, BOTTOM, 0, nameOffSet ) -- plus runter
  end
  nameDisp.ctrl:SetHidden(not design.nameDisplay.gameMode)

  nameDisp.back:ClearAnchors()
  nameDisp.back:SetAnchor( CENTER, nameDisp.ctrl, CENTER, 0, 0 )
  nameDisp.back:SetEdgeColor( 0, 0, 0, 1)
  nameDisp.back:SetCenterColor(0, 0, 0, 0.3)
  nameDisp.back:SetEdgeTexture( nil , edgeLine, edgeLine, edgeLine)
  nameDisp.back:SetHidden(not design.nameDisplay.showBackground)

  nameDisp.label:ClearAnchors()
  nameDisp.label:SetAnchor(CENTER, nameDisp.ctrl, CENTER, 4, 0 )
  nameDisp.label:SetColor( 1, 1, 1, 0.7 )
  nameDisp.label:SetFont( self:GetFont(design.font).."|"..design.nameDisplay.size.."|soft-shadow-thick")
  nameDisp.label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  nameDisp.label:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
  nameDisp.label:SetText(setInfo.setName)

  local width = nameDisp.label:GetTextWidth()
  local height = nameDisp.label:GetTextHeight()

  nameDisp.ctrl:SetDimensions( width+20, height+12 )
  nameDisp.back:SetDimensions( width+15, height+7 )
  nameDisp.label:SetDimensions( width+15, height+7)

  --color
    local status
    if primary.type == "timer" then status = "standby" end
    if primary.type == "value" then status = "low" end
    --self:UpdateColor(primary, status)
    --font

    --Handle Demo
    if setId == "demo" then
      gui.nameDisplay.ctrl:SetHidden(false)
      primary.label:SetColor(1,1,1,1)
    end
end
