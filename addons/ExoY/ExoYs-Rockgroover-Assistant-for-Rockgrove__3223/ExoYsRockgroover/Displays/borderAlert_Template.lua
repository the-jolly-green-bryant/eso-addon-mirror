Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.notificationGui = ERG.notificationGui or {}
local Gui = ERG.notificationGui

function Gui.Initialize()
  Gui.name = ERG.name.."NotificationGui"
  Gui.borderAlert = Gui.CreateBorderAlert()
end


------------------
-- Border Alert --
------------------

function Gui.CreateBorderAlert()
  local name = Gui.name.."BorderAlert"
  local win = ERG.WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors()
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0,0)
  win:SetDimensions( GuiRoot:GetDimensions() )
  win:SetMouseEnabled(false)
  win:SetMovable(false)
  win:SetHidden(true)

  local edge = ERG.WM:CreateControl(name.."Edge", win, CT_BACKDROP)
  edge:ClearAnchors()
  edge:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0,0)
  edge:SetDimensions( GuiRoot:GetDimensions() )
  edge:SetCenterTexture("EsoUI/Art/HUD/UITelvarOverlayCenter.dds")
  edge:SetCenterColor(0,0,0,0)
  edge:SetInsets(256, 256, -256, -256)

  return {win = win, edge = edge}
end

function Gui.ShowBorderAlert(color, size , duration)
  local gui = ERG.borderAlert
  local height = {
    [1] = 128,
    [2] = 256,
    [3] = 512,
  }
  local edgeHeight = height[size] or 128
  gui.win:SetHidden(false)
  gui.edge:SetEdgeColor( unpack(color) )
  gui.edge:SetEdgeTexture("EsoUI/Art/HUD/UITelvarOverlayEdge.dds", 2048, edgeHeight)

  if duration then
    zo_callLater( function() ERG.CancelBorderAlert() end, duration)
  end
end

function Gui.CancelBorderAlert()
  ERG.borderAlert.win:SetHidden(true)
end
