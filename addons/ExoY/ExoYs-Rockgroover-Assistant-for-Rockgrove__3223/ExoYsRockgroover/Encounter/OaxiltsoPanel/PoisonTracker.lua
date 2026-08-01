Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.oaxiltso = ERG.oaxiltso or {}
local Oaxiltso = ERG.oaxiltso

--------------
-- Defaults --
--------------

function Oaxiltso.GetPoisonTrackerDefaults()
 return {
   enabled = true,
   left = 600,
   top = 600,
   size = 4,
   back = { enabled = true, opacity = 0.5 },
   enrage = true,
   counter = true,
   note = "",
 }
end

-------------
-- Updates --
-------------

local rollTextureList = {
  [0] = "", --invalid
  [1] = "", --dps
  [2] = "tank", --tank
  [4] = "healer", --heal
}

function Oaxiltso.OnPoisonTrackerUpdate()
  if not ERG.store.oaxiltso.poisonTracker.enabled then return end
  local PoisonTracker = Oaxiltso.poisonTracker
  local timeStr = ""
  for _, entry in ipairs( Oaxiltso.poisonTracker.list ) do
    local min, sec = ERG.ConvertDurationToClock( GetGameTimeMilliseconds() - entry.time, true )
    local nextTime = ""
    if min == 0 then
      nextTime = tostring(sec)
    else
      nextTime = zo_strformat("<<1>>:<<2>>", min, string.format("%02d", sec))
    end
    timeStr = timeStr..nextTime.."\n"
  end
  Oaxiltso.poisonTracker.panel.times:SetText( timeStr )
end


function Oaxiltso.UpdatePoisonTrackerStaticLabels() --TODO OSI unique icons
  local function CreateIconString(tag)
    local texture = ""
    texture = zo_strformat("esoui/art/lfg/gamepad/lfg_roleicon_<<1>>.dds", rollTextureList[GetGroupMemberSelectedRole(tag)] )
    return ERG.AddIconToString("", texture, ERG.store.oaxiltso.poisonTracker.size*6)
  end

  local nameStr = ""
  local iconStr = ""
  for _, entry in ipairs( Oaxiltso.poisonTracker.list ) do
    iconStr = iconStr..CreateIconString( entry.tag ).."\n"
    nameStr = nameStr..entry.displayName.."\n"
  end
  Oaxiltso.poisonTracker.panel.names:SetText( nameStr )
  Oaxiltso.poisonTracker.panel.icons:SetText( iconStr )
  Oaxiltso.UpdatePoisonTrackerDimensions()
end


function Oaxiltso.UpdatePoisonTrackerDimensions()
  local size = ERG.store.oaxiltso.poisonTracker.size
  local panel = ERG.oaxiltso.poisonTracker.panel
  local numLines = #Oaxiltso.poisonTracker.list
  if numLines < 2 then numLines = 2 end

  if ERG.arena.hm then numLines = numLines + 1 + size*0.5 end

  --TODO height needs to be adjusted, shorten string according to width
  panel.win:SetDimensions( size*60, numLines*size*9 )
  panel.back:SetDimensions( size*60, numLines*size*9 )
end


function Oaxiltso.UpdatePoisonCounter()
  local counter = ERG.oaxiltso.poisonTracker.panel.counter
  if Oaxiltso.numMeteorCrash < 3 then
    counter:SetText("")
    return
  end
  if Oaxiltso.countPoisons then
    Oaxiltso.poisonTracker.number = Oaxiltso.poisonTracker.number + 1
  else
    Oaxiltso.countPoisons = true
  end
  if ERG.store.oaxiltso.poisonTracker.note == "" then
    counter:SetText( zo_strformat("next #<<1>>", Oaxiltso.poisonTracker.number) )
  else
    counter:SetText( zo_strformat("next #<<1>> (<<2>>)", Oaxiltso.poisonTracker.number, ERG.store.oaxiltso.poisonTracker.note) )
  end
  --TODO add check, if first poison can be cleansed two times to get back to first poison in counter
end

-----------------
-- Alterations --
-----------------

function Oaxiltso.AdaptPoisonTrackerAccordingToHardmode( isHm )
  local panel = Oaxiltso.poisonTracker.panel
  local store = ERG.store.oaxiltso.poisonTracker

  local useHeader = false
  if isHm and store.counter then useHeader = true end

  panel.ctrl:ClearAnchors()
  panel.ctrl:SetAnchor(TOPLEFT, panel.win, TOPLEFT, 0, useHeader and store.size*13 or 0)

  panel.counter:SetHidden( not useHeader )
  panel.divider:SetHidden( not useHeader )

  Oaxiltso.UpdatePoisonTrackerDimensions()
end

function Oaxiltso.AdaptPoisonTrackerAccordingToProfile()
  local panel = Oaxiltso.poisonTracker.panel
  local store = ERG.store.oaxiltso.poisonTracker

  panel.win:ClearAnchors()
  panel.win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, store.left, store.top)

  panel.back:SetHidden(not store.back.enabled)
  panel.back:SetCenterColor(0,0,0, store.back.opacity)

  Oaxiltso.AdaptPoisonTrackerAccordingToSize()
end


function Oaxiltso.AdaptPoisonTrackerAccordingToSize() --TODO
  local size = ERG.store.oaxiltso.poisonTracker.size
  local panel = ERG.oaxiltso.poisonTracker.panel

  panel.divider:ClearAnchors()
  panel.divider:SetAnchor(TOPLEFT, panel.win, TOPLEFT, 0, size*10)
  panel.divider:SetDimensions(size*60, 15)
  panel.times:ClearAnchors()
  panel.times:SetAnchor( TOPRIGHT, panel.ctrl, TOPLEFT, size*15, 0)   --panel.times:SetWidth( size*12 )
  panel.icons:ClearAnchors()
  panel.icons:SetAnchor( TOP, panel.ctrl, TOPLEFT, size*(20), 0)
  panel.names:ClearAnchors()
  panel.names:SetAnchor( TOPLEFT, panel.ctrl, TOPLEFT, size*(25), 0)
  for _, control in pairs( {"times", "icons", "names", "counter"} ) do
    panel[control]:SetFont( ERG.GetFont(size*8) )
    panel[control]:SetLineSpacing(-size*2)
  end
  Oaxiltso.UpdatePoisonTrackerDimensions()
  Oaxiltso.UpdatePoisonTrackerStaticLabels()
end


----------------
-- Initialize --
----------------

function Oaxiltso.InitializePoisonTracker()
  Oaxiltso.poisonTracker = { list = {} }
  Oaxiltso.poisonTracker.panel = Oaxiltso.CreatePoisonTracker()
  Oaxiltso.AdaptPoisonTrackerAccordingToProfile()

  local function OnPoison(_, changeType, _, _, unitTag)
    if changeType == EFFECT_RESULT_GAINED then
      local displayName = ERG.ShortenString( GetUnitDisplayName(unitTag), 9, nil, 2 )
      table.insert( Oaxiltso.poisonTracker.list, { time = GetGameTimeMilliseconds(), tag = unitTag, displayName = displayName} )
      Oaxiltso.UpdatePoisonTrackerStaticLabels()
    end
    if changeType == EFFECT_RESULT_FADED then
      for key, entry in pairs( Oaxiltso.poisonTracker.list ) do
        if entry.tag == unitTag then
          table.remove( Oaxiltso.poisonTracker.list, key)
          Oaxiltso.UpdatePoisonTrackerStaticLabels()
          break
        end
      end
    end
  end

  ERG.EM:RegisterForEvent(Oaxiltso.name.."Poison", EVENT_EFFECT_CHANGED, OnPoison)
  ERG.EM:AddFilterForEvent(Oaxiltso.name.."Poison", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 157860)
  ERG.EM:AddFilterForEvent(Oaxiltso.name.."Poison", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

function Oaxiltso.CreatePoisonTracker() --TODO
  local name = Oaxiltso.name.."PoisonTracker"

  local win = ERG.WM:CreateTopLevelWindow( name.."Window" )
  win:SetHidden( true )
  win:SetMovable( true )
  win:SetClampedToScreen( true )
  win:SetMouseEnabled( true )
  win:SetHandler( "OnMoveStop", function( )
      ERG.store.oaxiltso.poisonTracker.left = win:GetLeft()
      ERG.store.oaxiltso.poisonTracker.top = win:GetTop()
    end)

  local frag = ZO_HUDFadeSceneFragment:New( win )
  table.insert(Oaxiltso.fragList, {frag = frag, IsEnabled = function() return ERG.store.oaxiltso.poisonTracker.enabled end} )

  local back = ERG.WM:CreateControl(name.."Background", win, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(TOPLEFT, win, TOPLEFT, 0,0)
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil, 2, 2, 2)

  local edge = ERG.WM:CreateControl(name.."Edge", win, CT_BACKDROP)--TODO
  edge:ClearAnchors()
  edge:SetAnchor( TOPLEFT, win, TOPLEFT, -60, -60)
  edge:SetHidden(true) --WARNING
  edge:SetDimensions(614,256)
  edge:SetCenterColor(0,0,0,0)
  edge:SetEdgeColor(1,0,0,1)
  edge:SetEdgeTexture("EsoUI/Art/crafting/crafting_tooltip_glow_edge_red64.dds", 4096, 128)

  local counter = ERG.WM:CreateControl(name.."Counter", win, CT_LABEL)
  counter:ClearAnchors()
  counter:SetAnchor(TOPLEFT, win, TOPLEFT, 5, 0)
  counter:SetHidden(true)
  counter:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  counter:SetHorizontalAlignment( TEXT_ALIGN_LEFT  )
  counter:SetColor( 1,1,1,1 )

  local divider = ERG.WM:CreateControl(name.."Divider", win, CT_TEXTURE) --TODO
  divider:SetHidden(true)
  divider:SetTexture("esoui/art/interaction/conversation_divider.dds")

  local ctrl = ERG.WM:CreateControl(name.."Control", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 0)

  local times = ERG.WM:CreateControl(name.."Times", ctrl, CT_LABEL) --TODO
  times:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  times:SetHorizontalAlignment( TEXT_ALIGN_RIGHT  )
  times:SetColor( 1,1,1,1 )

  local icons = ERG.WM:CreateControl(name.."Icons", ctrl, CT_LABEL) --TODO
  icons:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  icons:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )
  icons:SetColor( 1,1,1,1 )

  local names = ERG.WM:CreateControl(name.."Names", ctrl, CT_LABEL) --TODO
  names:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  names:SetHorizontalAlignment( TEXT_ALIGN_LEFT  )
  names:SetColor( 1,1,1,1 )

  return { win = win, back = back, edge = edge, counter = counter, divider = divider, ctrl = ctrl, names = names, icons = icons, times = times}
end


----------
-- Menu --
----------

function Oaxiltso.GetPoisonTrackerMenu()
  local panel = ERG.oaxiltso.poisonTracker.panel

  local panelMenu = ERG.GetBasicPanelMenu( "oaxiltso", "poisonTracker", Oaxiltso.AdaptPoisonTrackerAccordingToSize )

  table.insert(panelMenu, {type = "divider"} )

  table.insert(panelMenu, {
    type = "checkbox",
    name = ERG_OAXILTSO_INDICATE_ENRAGE,
    tooltip = ERG_OAXILTSO_INDICATE_ENRAGE_TT,
    getFunc = function() return ERG.store.oaxiltso.poisonTracker.enrage end,
    setFunc = function(bool)
      ERG.store.oaxiltso.poisonTracker.enrage = bool
    end,
  } )

  table.insert(panelMenu, {
    type = "checkbox",
    name = ERG_OAXILTSO_POISON_COUNTER,
    tooltip = ERG_OAXILTSO_POISON_COUNTER_TT,
    getFunc = function() return ERG.store.oaxiltso.poisonTracker.counter end,
    setFunc = function(bool)
      ERG.store.oaxiltso.poisonTracker.counter = bool
    end,
    width = "half",
  } )

  table.insert(panelMenu, {
    disabled = function() return not ERG.store.oaxiltso.poisonTracker.counter end,
    type = "editbox",
    name = ERG_OAXILTSO_NOTE,
    tooltip = ERG_OAXILTSO_POISON_NOTE_TT,
    getFunc = function() return ERG.store.oaxiltso.poisonTracker.note end,
    setFunc = function(text)
      ERG.store.oaxiltso.poisonTracker.note = text
    end,
    width = "half",
  } )

  return {
    type = "submenu",
    name = ERG.AddIconToString(ERG_OAXILTSO_POISONTRACKER, "esoui/art/icons/ability_scrying_05a.dds" ,32, true),
    controls = panelMenu,
  }
end
