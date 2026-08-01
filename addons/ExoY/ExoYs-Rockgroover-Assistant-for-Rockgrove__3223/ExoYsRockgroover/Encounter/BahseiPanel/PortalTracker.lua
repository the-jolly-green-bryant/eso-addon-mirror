Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.bahsei = ERG.bahsei or {}
local Bahsei = ERG.bahsei

local featureList = {
  ["timer"] = "",
  ["number"] = "",
  ["inside"] = "",
}

function Bahsei.GetPortalTrackerDefaults()
  local defaults = {
    enabled = true,
    left = 600,
    top = 600,
    size = 4,
    back = {enabled = true, opacity = 0.6 },
    mirror = false,
  }
  for feature, _ in pairs(featureList) do
    defaults[feature] = {}
    defaults[feature].enabled = true
    defaults[feature].minor = false
    --defaults[feature].showIcon = true
  end

  return defaults
end

-------------
-- Updates --
-------------

function Bahsei.OnPortalTrackerUpdate()
  local panel = Bahsei.portalTracker.panel
  local data = Bahsei.portalTracker.data

  if not data.isPortal then
    panel.labels["timer"].text:SetText("Next")
    panel.labels["timer"].ind:SetText( ERG.GetTimeRemaining(data.nextPortal , false, "Soon") )
  elseif data.isHope then
    panel.labels["timer"].text:SetText("Hope")
    panel.labels["timer"].ind:SetText( ERG.GetTimeRemaining(data.hopeEnd , false, "Soon") )
  else
    if data.direction == 153517 then
      panel.labels["timer"].text:SetText( "CW" )
      panel.labels["timer"].ind:SetText( ERG.AddIconToString("", "/esoui/art/housing/rotation_arrow_reverse.dds", ERG.store.bahsei.portalTracker.size*7) )
    elseif data.direction == 153518 then
      panel.labels["timer"].text:SetText( "CCW" )
      panel.labels["timer"].ind:SetText( ERG.AddIconToString("", "/esoui/art/housing/rotation_arrow.dds", ERG.store.bahsei.portalTracker.size*7) )
    else
      panel.labels["timer"].text:SetText( "" )
      panel.labels["timer"].ind:SetText( "" )
    end
  end
end

function Bahsei.UpdatePortalTrackerStaticLabels()
  local panel = Bahsei.portalTracker.panel
  local data = Bahsei.portalTracker.data

  panel.labels["number"].ind:SetText( "#"..tostring((data.portalNumber%2)+1) )
  panel.labels["inside"].ind:SetText( #data.playerInside )
end

-----------------
-- Alterations --
-----------------

function Bahsei.AdaptPortalTrackerAccordingToProfile()
  local panel = ERG.bahsei.portalTracker.panel
  local store = ERG.store.bahsei.portalTracker

  panel.win:ClearAnchors()
  panel.win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, store.left, store.top)

  panel.back:SetHidden(not store.back.enabled)
  panel.back:SetCenterColor(0,0,0, store.back.opacity)

  Bahsei.RebuildPortalTracker()
end


function Bahsei.RebuildPortalTracker()
  local panel = ERG.bahsei.portalTracker.panel
  local store = ERG.store.bahsei.portalTracker
  local size = store.size

  local majorList = {}
  local minorList = {}
  local highestWidth = 0

  for feature, _ in pairs(featureList) do
    if store[feature].enabled then
      if store[feature].minor then
        table.insert(minorList, feature)
      else
        table.insert(majorList, feature)
      end
      local fontScale = store[feature].minor and 4 or 8
      for _, control in pairs( {"ind", "text"} ) do
        panel.labels[feature][control]:ClearAnchors()
        panel.labels[feature][control]:SetFont( ERG.GetFont(size*fontScale) )
      end
      panel.labels[feature].ind:ClearAnchors()
      panel.labels[feature].ind:SetFont( ERG.GetFont(size*fontScale) )

      panel.labels[feature].text:ClearAnchors()
      panel.labels[feature].text:SetFont( ERG.GetFont(size*fontScale) )
      --panel.labels[feature].text:SetText( feature )
      if panel.labels[feature].text:GetWidth() > highestWidth then
        highestWidth = panel.labels[feature].text:GetWidth()
      end
    else
      panel.labels[feature].text:SetText( "" )
    end
  end

  for num, feature in pairs(majorList) do
    panel.labels[feature].ind:SetAnchor( TOPRIGHT, ctr, TOPLEFT, size*19, 8*size*(num-1) )
    panel.labels[feature].text:SetAnchor( TOPLEFT, ctr, TOPLEFT, size*21, 8*size*(num-1) )
  end

  for num, feature in pairs(minorList) do
    panel.labels[feature].ind:SetAnchor( TOPRIGHT, ctr, TOPLEFT, size*19, 5*size*(num-1) + 8.5*#majorList*size )
    panel.labels[feature].text:SetAnchor( TOPLEFT, ctr, TOPLEFT, size*21, 5*size*(num-1) + 8.5*#majorList*size )
  end

  panel.win:SetDimensions( highestWidth + size*25, 5*(#majorList*2+#minorList*1)*size )
  panel.back:SetDimensions( highestWidth + size*25, 5*(#majorList*2+#minorList*1)*size )
end


----------------
-- Initialize --
----------------

function Bahsei.InitializePortalTracker()
  Bahsei.portalTracker = {}
  Bahsei.portalTracker.panel = Bahsei.CreatePortalTracker()
  Bahsei.portalTracker.data = {isHope = false, isPortal = false, nextPortal = GetGameTimeMilliseconds(), hopeEnd = GetGameTimeMilliseconds(), playerInside = {}, portalNumber = 1 }
  Bahsei.AdaptPortalTrackerAccordingToProfile()

  local function OnEyeExplode()
    Bahsei.portalTracker.data.nextPortal = GetGameTimeMilliseconds() + 50000
    Bahsei.portalTracker.data.isPortal = false
    Bahsei.portalTracker.data.direction = nil
    Bahsei.portalTracker.data.playerInside = {}
    Bahsei.portalTracker.data.portalNumber = Bahsei.portalTracker.data.portalNumber + 1
    Bahsei.UpdatePortalTrackerStaticLabels()
  end
  ERG.EM:RegisterForEvent(Bahsei.name.."EyeExplode", EVENT_COMBAT_EVENT, OnEyeExplode)
  ERG.EM:AddFilterForEvent(Bahsei.name.."EyeExplode", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153662 )
  ERG.EM:AddFilterForEvent(Bahsei.name.."EyeExplode", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED )

  local function OnRayOfHope(_, result)
    if result == ACTION_RESULT_EFFECT_GAINED then
      Bahsei.portalTracker.data.hopeEnd = GetGameTimeMilliseconds() + 9000
      Bahsei.portalTracker.data.isHope = true
    elseif result == ACTION_RESULT_EFFECT_FADED then
      Bahsei.portalTracker.data.isHope = false
    end
  end
  ERG.EM:RegisterForEvent(Bahsei.name.."RayOfHope", EVENT_COMBAT_EVENT, OnRayOfHope)
  ERG.EM:AddFilterForEvent(Bahsei.name.."RayOfHope", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153561 )

  local function OnPlayerEnterPortal(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    table.insert(Bahsei.portalTracker.data.playerInside, ERG.units.group.tag[targetUnitId] )
    Bahsei.UpdatePortalTrackerStaticLabels()
  end
  ERG.EM:RegisterForEvent(Bahsei.name.."PlayerEntersPortal", EVENT_COMBAT_EVENT, OnPlayerEnterPortal)
  ERG.EM:AddFilterForEvent(Bahsei.name.."PlayerEntersPortal", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 153403 ) -- 153117, 153403
  ERG.EM:AddFilterForEvent(Bahsei.name.."PlayerEntersPortal", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED )

  local function OnDeathInsidePortal(_, unitTag, isDead)
    if not isDead then return end
    for key, tag in ipairs(Bahsei.portalTracker.data.playerInside) do
      if tag == unitTag then
        table.remove(Bahsei.portalTracker.data.playerInside, key)
        Bahsei.UpdatePortalTrackerStaticLabels()
      end
    end
  end
  ERG.EM:RegisterForEvent(Bahsei.name.."DeathInsidePortal", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathInsidePortal)
  ERG.EM:AddFilterForEvent(Bahsei.name.."DeathInsidePortal", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end


function Bahsei.CreatePortalTracker()
  local name = Bahsei.name.."PortalTracker"

  local win = ERG.WM:CreateTopLevelWindow( name.."Window" )
  win:SetHidden( true )
  win:SetMovable( true )
  win:SetClampedToScreen( true )
  win:SetMouseEnabled( true )
  win:SetHandler( "OnMoveStop", function( )
      ERG.store.bahsei.portalTracker.left = win:GetLeft()
      ERG.store.bahsei.portalTracker.top = win:GetTop()
    end)

  Bahsei.portalTracker.frag = ZO_HUDFadeSceneFragment:New( win )

  local back = ERG.WM:CreateControl(name.."Background", win, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(TOPLEFT, win, TOPLEFT, 0,0)
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil, 2, 2, 2)

  local ctrl = ERG.WM:CreateControl(name.."Control", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 0)

  local labels = {}
  for feature, _ in pairs(featureList) do
    labels[feature] = {}
    local text = ERG.WM:CreateControl(name.."Text"..feature, ctrl, CT_LABEL)
    text:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    text:SetHorizontalAlignment( TEXT_ALIGN_LEFT  )
    text:SetColor(1,1,1,1)
    labels[feature].text = text
    local ind = ERG.WM:CreateControl(name.."Indicator"..feature, ctrl, CT_LABEL)
    ind:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    ind:SetHorizontalAlignment( TEXT_ALIGN_RIGHT  )
    ind:SetColor(1,1,1,1)
    labels[feature].ind = ind
  end

  labels["number"].text:SetText("Portal Number")
  labels["inside"].text:SetText("Player Inside")

  return {win = win, back = back, labels = labels, }
end
----------
-- Menu --
----------

function Bahsei.GetPortalTrackerMenu()
  local panel = ERG.bahsei.portalTracker.panel
  local panelMenu = ERG.GetBasicPanelMenu( "bahsei", "portalTracker", Bahsei.RebuildPortalTracker )
  table.insert( panelMenu, {type = "divider"} )

  for feature, icon in pairs(featureList) do
      table.insert(panelMenu, {
        type = "checkbox",
        name = feature,
        getFunc = function() return ERG.store.bahsei.portalTracker[feature].enabled end,
        setFunc = function(bool)
          ERG.store.bahsei.portalTracker[feature].enabled = bool
          Bahsei.RebuildPortalTracker()
        end,
      } )
  end

  local advancedSettings = {}
  for feature, icon in pairs(featureList) do
    table.insert(advancedSettings, {type="header", name= feature})
    table.insert(advancedSettings, {
      type = "checkbox",
      name = ERG_ANTICIPATION_MINOR,
      getFunc = function() return ERG.store.bahsei.portalTracker[feature].minor end,
      setFunc = function(bool)
        ERG.store.bahsei.portalTracker[feature].minor = bool
        Bahsei.RebuildPortalTracker()
      end,
    } )
    table.insert(advancedSettings, {
      type = "checkbox",
      name = ERG_ANTICIPATION_SHOW_ICONS,
      tooltip = ERG_ANTICIPATION_SHOW_ICONS_TT,
      getFunc = function() return ERG.store.bahsei.portalTracker[feature].showIcon end,
      setFunc = function(bool)
        ERG.store.bahsei.portalTracker[feature].showIcon = bool
        Bahsei.RebuildPortalTracker()
      end,
    } )
  end

  table.insert(panelMenu, {type = "submenu", name = ERG_ADVANCED_SETTINGS, controls = advancedSettings})

  return {
    type = "submenu",
    name = ERG.AddIconToString(ERG_PORTALTRACKER, "esoui/art/icons/ability_scrying_05c.dds" , 32, true),
    controls = panelMenu,
  }
end
