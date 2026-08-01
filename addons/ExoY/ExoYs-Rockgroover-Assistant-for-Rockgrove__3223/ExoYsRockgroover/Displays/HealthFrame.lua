Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.healthFrame = ERG.healthFrame or {}
local HealthFrame = ERG.healthFrame


function HealthFrame.Initialize()
  HealthFrame.name = ERG.name.."HealthFrame"
  HealthFrame.updateRunning = false
  HealthFrame.data = {}
  HealthFrame.gui = HealthFrame.Create()
end


function HealthFrame.Create()
  local name = HealthFrame.name.."Gui"

  local win = ERG.WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors()
  win:SetAnchor(TOP, GuiRoot, TOP, 0, 230)
  win:SetMovable( true )
  win:SetClampedToScreen( true )
  win:SetMouseEnabled( true )
  win:SetHidden( true )
  win:SetDimensions(250, 40)

  HealthFrame.frag = ZO_HUDFadeSceneFragment:New( win )

  local ctrl = ERG.WM:CreateControl( name.."Control", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
  ctrl:SetDimensions(250, 40)

  local back = ERG.WM:CreateControl( name.."Background", ctrl, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0,0)
  back:SetDimensions(250,40)
  back:SetCenterColor(0,0,0,0.7)
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil, 2, 2, 2)

  local bar = ERG.WM:CreateControl( name.."Bar", ctrl, CT_STATUSBAR)
  bar:ClearAnchors()
  bar:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 0, 0)
  bar:SetDimensions( 250, 40)
  bar:SetColor(0.65,0,0,1)
  --bar:SetTexture("/ExoYsUserInterface/textures/UnitFrameTexture.dds") --WARNING

  local hpInd = ERG.WM:CreateControl( name.."HP-Indicator", ctrl, CT_LABEL)
  hpInd:ClearAnchors()
  hpInd:SetAnchor(CENTER, ctrl, CENTER, 0, 0)
  hpInd:SetFont( ERG.GetFont(30) )
  hpInd:SetColor(1,1,1,1)

  local warning = ERG.WM:CreateControl( name.."Warning", ctrl, CT_LABEL)
  warning:ClearAnchors()
  warning:SetAnchor(TOP, ctrl, BOTTOM, 0, 0)
  warning:SetFont( ERG.GetFont(30) )
  warning:SetColor(1,1,1,1)

  return {bar = bar, hpInd = hpInd, warning = warning}
end

------------
-- Control --
-------------

function HealthFrame.OnCombatEnd()
  HealthFrame.Hide()
end

function HealthFrame.SetTrackedUnit(unitId)
  HealthFrame.data.unitId = unitId
end

function HealthFrame.RegisterTrackedUnit( ) --ForXalvakka

end

function HealthFrame.UnregisterTrackedUnit() --For Xalvakka

end


function HealthFrame.Show( maxValue, warning, shield)

  HUD_UI_SCENE:AddFragment( HealthFrame.frag )
  HUD_SCENE:AddFragment( HealthFrame.frag )

  HealthFrame.data.maxValue = maxValue
  HealthFrame.data.shield = shield
  HealthFrame.data.warning = warning or function() return "" end
  HealthFrame.gui.bar:SetMinMax( 0, maxValue)

  HealthFrame.StartUpdate()
end

function HealthFrame.Hide()
  HUD_UI_SCENE:RemoveFragment( HealthFrame.frag )
  HUD_SCENE:RemoveFragment( HealthFrame.frag )
  HealthFrame.StopUpdate()
  HealthFrame.data = {}
end

------------
-- Update --
------------

function HealthFrame.StartUpdate()
  if HealthFrame.updateRunning then return end
  ERG.EM:RegisterForUpdate(HealthFrame.name.."Update", 10, HealthFrame.Update)
  HealthFrame.updateRunning = true
end

function HealthFrame.StopUpdate()
  if not HealthFrame.updateRunning then return end
  ERG.EM:UnregisterForUpdate(HealthFrame.name.."Update")
  HealthFrame.updateRunning = false
end


local function ConvertCurrentHp(currentHp)
  local hpStr = ""
  if currentHp > 1000000 then
    hpStr = string.format("%.1fm", currentHp/1000000)
  else
    hpStr = string.format("%.1fk", currentHp/1000)
  end
  return hpStr
  --local percentStr = string.format("%.0f" ,currentHp*100/HealthFrame.data.maxHp )
  --return zo_strformat("<<1>>   <<2>>%", hpStr, percentStr)
end

function HealthFrame.Update()
  local damageType = HealthFrame.data.shield and "shield" or "damage"
  local damageTaken = ERG.units[damageType][ HealthFrame.data.unitId ] or 0
  local currentHp = HealthFrame.data.maxValue - damageTaken

  HealthFrame.gui.bar:SetValue( currentHp )
  HealthFrame.gui.hpInd:SetText( ConvertCurrentHp(currentHp) )
  HealthFrame.gui.warning:SetText( HealthFrame.data.warning() )
end



-----------------
-- Alterations --
-----------------

function HealthFrame.AdaptAccordingToEncounter()

end

function HealthFrame.AdaptAccordingToProfile()

end

function HealthFrame.AdaptAccordingToSize()

end
