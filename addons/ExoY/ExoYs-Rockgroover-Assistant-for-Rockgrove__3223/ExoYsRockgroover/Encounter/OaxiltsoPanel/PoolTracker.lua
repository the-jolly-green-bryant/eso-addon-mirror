Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.oaxiltso = ERG.oaxiltso or {}
local Oaxiltso = ERG.oaxiltso

--------------
-- Defaults --
--------------

function Oaxiltso.GetPoolTrackerDefaults()
 return {
   enabled = true,
   left = 600,
   top = 600,
   size = 4,
   back = { enabled = true, opacity = 0.7 },
   autoRotate = true,
   enrage = true,
   arrow = true,
   bannerPoolPosition = 1,
 }
end

-------------
-- Updates --
-------------

function Oaxiltso.OnPoolTrackerUpdate()
  if not ERG.store.oaxiltso.poolTracker.enabled then return end
  local PoolTracker = Oaxiltso.poolTracker
  for i = 1,4 do
    if not PoolTracker.magma[i] then
      local timeRemaining = ERG.GetTimeRemaining( PoolTracker.cleanse[i], true )
      if timeRemaining == "0" then
        PoolTracker.panel.ind[i]:SetColor(0,0,1,1)
      else
        PoolTracker.panel.ind[i]:SetColor(0,1,0,1)
      end
      PoolTracker.panel.ind[i]:SetText( timeRemaining )
    else
      PoolTracker.panel.ind[i]:SetColor(1,0,0,1)
      PoolTracker.panel.ind[i]:SetText("X")
    end
  end
end

function Oaxiltso.OnAutoRotateHeading()
  Oaxiltso.RotatePoolTracker( GetPlayerCameraHeading() + math.pi )
end

-----------------
-- Alterations --
-----------------

function Oaxiltso.AdaptPoolTrackerAccordingToProfile()
  local panel = Oaxiltso.poolTracker.panel
  local store = ERG.store.oaxiltso.poolTracker

  panel.win:ClearAnchors()
  panel.win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, store.left, store.top)

  panel.back:SetHidden(not store.back.enabled)
  panel.back:SetCenterColor(0,0,0, store.back.opacity)

  Oaxiltso.AdaptPoolTrackerAccordingToSize()
end


function Oaxiltso.SetFixedPoolTrackerHeading()
  Oaxiltso.RotatePoolTracker( -math.pi*(ERG.store.oaxiltso.poolTracker.bannerPoolPosition-1)/2 )
end

function Oaxiltso.RotatePoolTracker( direction )
  local panel = Oaxiltso.poolTracker.panel

  panel.ctrl:SetTransformRotationZ( -direction )
  for i = 1,4 do
    panel.ind[i]:SetTransformRotationZ( direction )
  end
end

function Oaxiltso.AdaptPoolTrackerAccordingToSize()

  local size = ERG.store.oaxiltso.poolTracker.size
  local panel = ERG.oaxiltso.poolTracker.panel

  panel.win:SetDimensions( size*26, size*26)
  panel.back:SetDimensions( size*26, size*26 )
  panel.ctrl:SetDimensions( size*26, size*26 )
  panel.edge:SetDimensions( size*26, size*26 )

  panel.arrow:SetDimensions( size*8, size*5)

  for i = 1,4 do
    local topFactor = i-1%4 < 2 and 1 or -1
    local leftFactor = i%4 > 1 and 1 or -1
    local left = leftFactor*size*6
    local top = topFactor*size*6
    panel.ind[i]:ClearAnchors()
    panel.ind[i]:SetAnchor(CENTER, panel.ctrl, CENTER, left, top)
    panel.ind[i]:SetFont( ERG.GetFont(size*8) )
  end
end

----------------
-- Initialize --
----------------

function Oaxiltso.InitializePoolTracker()
  Oaxiltso.poolTracker = { cleanse = {}, magma = {}, }
  Oaxiltso.poolTracker.panel = Oaxiltso.CreatePoolTracker()
  Oaxiltso.AdaptPoolTrackerAccordingToProfile()

  if ERG.store.oaxiltso.poolTracker.autoRotate then
    ERG.EM:RegisterForUpdate(Oaxiltso.name.."RotatePoolTracker", 10, Oaxiltso.OnAutoRotateHeading)
  else
    Oaxiltso.SetFixedPoolTrackerHeading()
  end

  --[[ (x,z)
  %%%%%%%%% | %%%%%%%%%
  % 91,81 % | % 89,81 %
  %%%%%%%%% | %%%%%%%%%
  ----------+----------
  %%%%%%%%% | %%%%%%%%%
  % 91,79 % | % 89,79 %
  %%%%%%%%% | %%%%%%%%%
  ]]

  local function OnPoisonFaded(_, changeType, _, _, unitTag)
    if changeType ~= EFFECT_RESULT_FADED then return end
    if IsUnitDead( unitTag ) then return end
    local zone, wX, wY, wZ = GetUnitRawWorldPosition( unitTag )
    local sign = 1
    local value = 0
    if wZ < 80000 then
      value = value + 1
      sign = -1
    end
    if wX > 90000 then
      value = value + 1
    end
    Oaxiltso.poolTracker.cleanse[3+(sign*value)] = GetGameTimeMilliseconds() + 25000
  end

  ERG.EM:RegisterForEvent( Oaxiltso.name.."PoisonFaded", EVENT_EFFECT_CHANGED, OnPoisonFaded)
  ERG.EM:AddFilterForEvent( Oaxiltso.name.."PoisonFaded", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, Oaxiltso.GetMechanicIds()["poisoned"])
  ERG.EM:AddFilterForEvent( Oaxiltso.name.."PoisonFaded", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

function Oaxiltso.CreatePoolTracker()
  local name = Oaxiltso.name.."PoolTracker"

  local win = ERG.WM:CreateTopLevelWindow( name.."Window" )
  win:SetHidden( true )
  win:SetMovable( true )
  win:SetClampedToScreen( true )
  win:SetMouseEnabled( true )
  win:SetHandler( "OnMoveStop", function( )
      ERG.store.oaxiltso.poolTracker.left = win:GetLeft()
      ERG.store.oaxiltso.poolTracker.top = win:GetTop()
    end)

  local frag = ZO_HUDFadeSceneFragment:New( win )
  table.insert(Oaxiltso.fragList, {frag = frag, IsEnabled = function() return ERG.store.oaxiltso.poolTracker.enabled end} )

  local back = ERG.WM:CreateControl(name.."Background", win, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(TOPLEFT, win, TOPLEFT, 0,0)
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil, 2, 2, 2)

  local edge = ERG.WM:CreateControl(name.."Edge", win, CT_BACKDROP)--TODO
  edge:ClearAnchors()
  edge:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 0)
  edge:SetHidden(true) --WARNING
	edge:SetCenterColor(0,0,0,0)
  edge:SetEdgeColor(1,0,0,1)
  edge:SetEdgeTexture("EsoUI/Art/crafting/crafting_tooltip_glow_edge_red64.dds", 1024, 16, 100, 0)

  local ctrl = ERG.WM:CreateControl(name.."Control", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor( CENTER, win, CENTER, 0, 0)

  local arrow = ERG.WM:CreateControl(name.."Arrow", ctrl, CT_TEXTURE)
  arrow:ClearAnchors()
  arrow:SetAnchor(CENTER, ctrl, CENTER, 0 , 0 )
  arrow:SetTexture("/esoui/art/inventory/collectible_evolution_arrow.dds")
  arrow:SetTextureRotation( math.pi/2 )

  local ind = {}
  for i = 1,4 do
    local label = ERG.WM:CreateControl(name.."Indicator"..tostring(i), ctrl, CT_LABEL)
    label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    label:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )
    table.insert(ind, label)
  end

  return { win = win, back = back, edge = edge, ctrl = ctrl, arrow = arrow, ind = ind }
end


----------
-- Menu --
----------

local positionOptions = {
  [1] = ERG_BOTTOM_LEFT,
  [2] = ERG_BOTTOM_RIGHT,
  [3] = ERG_TOP_RIGHT,
  [4] = ERG_TOP_LEFT,
}

function Oaxiltso.GetPoolTrackerMenu()
  local panel = ERG.oaxiltso.poolTracker.panel

  local panelMenu = ERG.GetBasicPanelMenu( "oaxiltso", "poolTracker", Oaxiltso.AdaptPoolTrackerAccordingToSize )

  table.insert(panelMenu, {type = "divider"} )

  table.insert(panelMenu, {
    type = "checkbox",
    name = ERG_OAXILTSO_INDICATE_ENRAGE,
    tooltip = ERG_OAXILTSO_INDICATE_ENRAGE_TT,
    getFunc = function() return ERG.store.oaxiltso.poolTracker.enrage end,
    setFunc = function(bool)
      ERG.store.oaxiltso.poolTracker.enrage = bool
    end,
  } )

  table.insert(panelMenu, {
    type = "checkbox",
    name = ERG_OAXILTSO_POOLTRACKER_ARROW,
    tooltip = ERG_OAXILTSO_POOLTRACKER_ARROW_TT,
    getFunc = function() return ERG.store.oaxiltso.poolTracker.arrow end,
    setFunc = function(bool)
      ERG.store.oaxiltso.poolTracker.arrow = bool
      panel.arrow:SetHidden( not bool )
    end,
  } )

  table.insert(panelMenu, {type = "divider"} )

  table.insert(panelMenu, {
    type = "checkbox",
    name = ERG_OAXILTSO_POOLTRACKER_AUTO_ROTATE,
    tooltip = ERG_OAXILTSO_POOLTRACKER_AUTO_ROTATE_TT,
    getFunc = function() return ERG.store.oaxiltso.poolTracker.autoRotate end,
    setFunc = function(bool)
      ERG.store.oaxiltso.poolTracker.autoRotate = bool
      if bool then
        ERG.EM:RegisterForUpdate(Oaxiltso.name.."RotatePoolTracker", 10, Oaxiltso.OnAutoRotateHeading)
      else
        ERG.EM:UnregisterForUpdate(Oaxiltso.name.."RotatePoolTracker")
        Oaxiltso.SetFixedPoolTrackerHeading()
      end
    end,
  } )

  table.insert(panelMenu, {
    type = "dropdown",
    disabled = function() return ERG.store.oaxiltso.poolTracker.autoRotate end,
    name = ERG_OAXILTSO_POOLTRACKER_HM_POOL_POSITION,
    tooltip = ERG_OAXILTSO_POOLTRACKER_HM_POOL_POSITION_TT,
    choices = positionOptions,
    getFunc = function() return positionOptions[ERG.store.oaxiltso.poolTracker.bannerPoolPosition] end,
    setFunc = function(select)
      for key, position in ipairs(positionOptions) do
        if position == select then
          ERG.store.oaxiltso.poolTracker.bannerPoolPosition = key
          Oaxiltso.SetFixedPoolTrackerHeading()
          break
        end
      end
    end,
  } )

  return {
    type = "submenu",
    name = ERG.AddIconToString(ERG_OAXILTSO_POOLTRACKER, "esoui/art/icons/ability_scrying_05b.dds" ,32, true),
    controls = panelMenu,
  }
end
