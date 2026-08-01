Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.anticipation = ERG.anticipation or {}
local Anticipation = ERG.anticipation




function Anticipation.GetDefaults( mechanicData )
  local defaults = {
    enabled = true,
    left = 600,
    top = 600,
    size = 4,
    back = { enabled = true, opacity = 0.7 },
    mirror = false,
  }
  for id, data in pairs(mechanicData) do
    if data.cooldown then
      defaults[id] = {}
      defaults[id].enabled = true
      defaults[id].minor = false
      defaults[id].text = data.name or ERG.GetFormattedAbilityName(id)
      defaults[id].color = data.color
      defaults[id].showIcon = true
      defaults[id].priorWarning = false
      defaults[id].warningAdvance = 3
    end
  end
  return defaults
end

---

function Anticipation.SetActiveState(encounter, id, state)
  ERG[encounter].anticipation.isActive[id] = state
  Anticipation.RebuildPanel( encounter )
end

function Anticipation.GetActiveState(encounter, id)
  return ERG[encounter].anticipation.isActive[id]
end

--/script Rockgroover.anticipation.OnCast("oaxiltso", 149648, 10000)
function Anticipation.OnCast(encounter, id, cooldown)
  local millisecondsRemaining = ERG.GetRemainingMilliseconds(ERG[encounter].anticipation.nextCast[id])
  ERG[encounter].anticipation.nextCast[id] = GetGameTimeMilliseconds() + cooldown

  local store = ERG.store[encounter].anticipation[id]
  -- Handle Warning here via callLater
  local function ExecuteWarning()
    local major = zo_strformat("<<1>> in <<2>>s", store.text, store.warningAdvance)
    major = ERG.notifications.AddIconToAlert(encounter, id, major)
    local minor = ERG.notifications.GetMinorText(id, store.text)
    CombatAlerts.Alert(minor, major, ERG.GetCombatAlertsColor(store.color), nil, 1500)
  end
  if store.priorWarning then
    local warningId = zo_callLater( function() ExecuteWarning() end, cooldown - store.warningAdvance*1000 - 1000)
    table.insert(ERG.notifications.warningList, warningId)
  end
end


function Anticipation.OnUpdate(encounter, data )
  local panel = data.panel
  local store = ERG.store[encounter].anticipation

  for id, nextCast in pairs(data.nextCast) do
    if store[id].enabled and ERG.combat.state and Anticipation.GetActiveState(encounter, id) then
      local nextCastString = ERG.GetTimeRemaining( nextCast, false, "Soon" )
      panel.labels[id].timer:SetText( nextCastString )
    else
      panel.labels[id].timer:SetText("")
    end
  end

end


-----------------
-- Alterations --
-----------------

function Anticipation.OnProfileChange(encounter)
  local panel = ERG[encounter].anticipation.panel
  local store = ERG.store[encounter].anticipation

  panel.win:ClearAnchors()
  panel.win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, store.left, store.top)

  panel.back:SetHidden(not store.back.enabled)
  panel.back:SetCenterColor(0,0,0, store.back.opacity)

  Anticipation.RebuildPanel(encounter)
end


function Anticipation.RebuildPanel( encounter )
  local anticipation = ERG[encounter].anticipation
  local panel = anticipation.panel
  local store = ERG.store[encounter].anticipation
  local size = store.size
  local mechanicData = ERG[encounter].GetMechanicData()

  local majorList = {}
  local minorList = {}
  local highestWidth = 0

  for id, _ in pairs(ERG[encounter].anticipation.nextCast) do
    if store[id].enabled and anticipation.isActive[id] then
      if store[id].minor then
        table.insert(minorList, id)
      else
        table.insert(majorList, id)
      end
      local fontScale = store[id].minor and 4 or 8
      for _, control in pairs( {"timer", "text"} ) do
        panel.labels[id][control]:ClearAnchors()
        panel.labels[id][control]:SetFont( ERG.GetFont(size*fontScale) )
      end
      panel.labels[id].timer:ClearAnchors()
      panel.labels[id].timer:SetFont( ERG.GetFont(size*fontScale) )
      panel.labels[id].timer:SetColor( unpack(store[id].color) )

      panel.labels[id].text:ClearAnchors()
      panel.labels[id].text:SetFont( ERG.GetFont(size*fontScale) )
      panel.labels[id].text:SetText( store[id].showIcon and ERG.AddIconToString(store[id].text, mechanicData[id].icon or id, fontScale*size, true) or store[id].text )
      panel.labels[id].text:SetColor( unpack(store[id].color) )
      if panel.labels[id].text:GetWidth() > highestWidth then
        highestWidth = panel.labels[id].text:GetWidth()
      end
    else
      panel.labels[id].text:SetText( "" )
    end
  end

  for num, id in pairs(majorList) do
    panel.labels[id].timer:SetAnchor( TOPRIGHT, ctr, TOPLEFT, size*19, 8*size*(num-1) )
    panel.labels[id].text:SetAnchor( TOPLEFT, ctr, TOPLEFT, size*21, 8*size*(num-1) )
  end

  for num, id in pairs(minorList) do
    panel.labels[id].timer:SetAnchor( TOPRIGHT, ctr, TOPLEFT, size*19, 5*size*(num-1) + 8.5*#majorList*size )
    panel.labels[id].text:SetAnchor( TOPLEFT, ctr, TOPLEFT, size*21, 5*size*(num-1) + 8.5*#majorList*size )
  end

  panel.win:SetDimensions( highestWidth + size*25, 5*(#majorList*2+#minorList*1)*size )
  panel.back:SetDimensions( highestWidth + size*25, 5*(#majorList*2+#minorList*1)*size )
end

----------------
-- Initialize --
----------------

function Anticipation.Initialize(encounter, mechanicData)
  local nextCast = {}
  local isActive = {}
  for id, data in pairs(mechanicData) do
    if data.cooldown then
      isActive[id] = true
      nextCast[id] = GetGameTimeMilliseconds()
    end
    if data.result then
    --register needed events
    local eventName = string.format("%s%s%s%s", ERG.name, encounter, "Anticipation", id)
    ERG.EM:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function() Anticipation.OnCast(encounter, id, data.cooldown) end)
    ERG.EM:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
    ERG.EM:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, data.result)
    end
  end

  ERG[encounter].anticipation = {
    nextCast = nextCast,
    panel = Anticipation.CreatePanel(encounter, mechanicData),
    isActive = isActive,
  }
  Anticipation.OnProfileChange(encounter)
end

function Anticipation.CreatePanel(encounter, mechanicData)
  local name = ERG.name.."AnticipationPanel"..encounter

  local win = ERG.WM:CreateTopLevelWindow( name.."Window" )
  win:SetHidden( true )
  win:SetMovable( true )
  win:SetClampedToScreen( true )
  win:SetMouseEnabled( true )
  win:SetHandler( "OnMoveStop", function( )
      ERG.store[encounter].anticipation.left = win:GetLeft()
      ERG.store[encounter].anticipation.top = win:GetTop()
    end)

  local frag = ZO_HUDFadeSceneFragment:New( win )
  table.insert(ERG[encounter].fragList, {frag = frag, IsEnabled = function() return ERG.store[encounter].anticipation.enabled end} )

  local back = ERG.WM:CreateControl(name.."Background", win, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(TOPLEFT, win, TOPLEFT, 0,0)
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil, 2, 2, 2)

  local edge = ERG.WM:CreateControl(name.."Edge", win, CT_BACKDROP)--TODO
  edge:ClearAnchors()
  edge:SetAnchor( TOPLEFT, win, TOPLEFT, -60, -60)
  edge:SetDimensions(614,256)
  edge:SetHidden(true)
  edge:SetCenterColor(0,0,0,0)
  edge:SetEdgeColor(1,0,0,1)
  edge:SetEdgeTexture("EsoUI/Art/crafting/crafting_tooltip_glow_edge_red64.dds", 4096, 128)

  local ctrl = ERG.WM:CreateControl(name.."Control", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor( TOPLEFT, win, TOPLEFT, 0, 0)

  local labels = {}
  for id, data in pairs(mechanicData) do
    if data.cooldown then
      labels[id] = {}
      local text = ERG.WM:CreateControl(name.."Text"..tostring(id), ctrl, CT_LABEL)
      text:SetVerticalAlignment( TEXT_ALIGN_CENTER )
      text:SetHorizontalAlignment( TEXT_ALIGN_LEFT  )
      labels[id].text = text
      local timer = ERG.WM:CreateControl(name.."Timer"..tostring(id), ctrl, CT_LABEL)
      timer:SetVerticalAlignment( TEXT_ALIGN_CENTER )
      timer:SetHorizontalAlignment( TEXT_ALIGN_RIGHT  )
      labels[id].timer = timer
    end
  end

  return {win = win, back = back, edge = edge, ctrl = ctrl, labels = labels}
end

function Anticipation.GetMenu(encounter, mechanicData)
  local panel = ERG[encounter].anticipation.panel

  local panelMenu = ERG.GetBasicPanelMenu( encounter, "anticipation", ERG[encounter].RebuildAnticipationPanel )

  table.insert(panelMenu, {type = "divider"} )
  --[[table.insert(panelMenu, { --TODO
      type = "checkbox",
      name = ERG_ANTICIPATION_MIRROR,
      tooltip = ERG_ANTICIPATION_MIRROR_TT,
      getFunc = function() return ERG.store[encounter].anticipation.mirror end,
      setFunc = function(bool)
        ERG.store[encounter].anticipation.mirror = bool
      end,
    } ) ]]
  if encounter == "oaxiltso" then
    table.insert(panelMenu, {
      type = "checkbox",
      name = ERG_OAXILTSO_INDICATE_ENRAGE,
      tooltip = ERG_OAXILTSO_INDICATE_ENRAGE_TT,
      getFunc = function() return ERG.store.oaxiltso.anticipation.enrage end,
      setFunc = function(bool)
        ERG.store.oaxiltso.anticipation.enrage = bool
      end,
    } )
  end
  table.insert(panelMenu, {type = "divider"} )
  for id, data in pairs(mechanicData) do
    if data.cooldown then
      table.insert(panelMenu, {
        type = "checkbox",
        name = ERG.GetMenuAbilityName(id, ERG[encounter].GetMechanicData() ),
        getFunc = function() return ERG.store[encounter].anticipation[id].enabled end,
        setFunc = function(bool)
          ERG.store[encounter].anticipation[id].enabled = bool
          Anticipation.RebuildPanel(encounter)
        end,
        tooltip = ERG.GetTooltip(id),
      } )
    end
  end

  local advancedSettings = {}
  for id, data in pairs(mechanicData) do
    if data.cooldown then
      table.insert(advancedSettings, {type="header", name= ERG.GetMenuAbilityName(id, mechanicData)})
      table.insert(advancedSettings, {
        disabled = function() return not ERG.store[encounter].anticipation[id].enabled end,
        type = "checkbox",
        name = ERG_ANTICIPATION_MINOR,
        getFunc = function() return ERG.store[encounter].anticipation[id].minor end,
        setFunc = function(bool)
          ERG.store[encounter].anticipation[id].minor = bool
          Anticipation.RebuildPanel(encounter)
         end,
       width = "half",
      })
      table.insert(advancedSettings, {
        disabled = function() return not ERG.store[encounter].anticipation[id].enabled end,
        type = "editbox",
        name = ERG_TEXT,
        getFunc = function() return ERG.store[encounter].anticipation[id].text end,
        setFunc = function(text)
          ERG.store[encounter].anticipation[id].text = text
          Anticipation.RebuildPanel(encounter)
         end,
        isMultiline = false,
        width = "half"
      })
      table.insert(advancedSettings, {
        disabled = function() return not ERG.store[encounter].anticipation[id].enabled end,
        type = "checkbox",
        name = ERG_ANTICIPATION_SHOW_ICONS,
        tooltip = ERG_ANTICIPATION_SHOW_ICONS_TT,
        getFunc = function() return ERG.store[encounter].anticipation[id].showIcon end,
        setFunc = function(bool)
          ERG.store[encounter].anticipation[id].showIcon = bool
          Anticipation.RebuildPanel(encounter)
        end,
        width = "half",
      } )
      table.insert(advancedSettings, {
        disabled = function() return not ERG.store[encounter].anticipation[id].enabled end,
        type = "colorpicker",
        name = ERG_COLOR,
        getFunc = function() return unpack(ERG.store[encounter].anticipation[id].color) end,
        setFunc = function(r,g,b)
          ERG.store[encounter].anticipation[id].color = {r,g,b,1}
          Anticipation.RebuildPanel(encounter)
        end,
        width = "half",
      })
      table.insert(advancedSettings, {
        type = "checkbox",
        name = "Warning", --TODO language
        getFunc = function() return ERG.store[encounter].anticipation[id].priorWarning end,
        setFunc = function(bool)
          ERG.store[encounter].anticipation[id].priorWarning = bool
        end,
        width = "half",
      })
      table.insert(advancedSettings, {
        disabled = function() return not ERG.store[encounter].anticipation[id].priorWarning end,
        type = "slider",
        name = "warning time (Seconds)",
        min = 1,
        max = 5,
        step = 1,
        getFunc = function() return ERG.store[encounter].anticipation[id].warningAdvance end,
        setFunc = function(value)
          ERG.store[encounter].anticipation[id].warningAdvance = value
        end,
        width = "half",
      })
    end
  end
  table.insert(panelMenu, {type = "submenu", name = ERG_ADVANCED_SETTINGS, controls = advancedSettings})

  return {
    type = "submenu",
    name = ERG.AddIconToString(ERG_ANTICIPATION, "esoui/art/icons/ability_scrying_05d.dds" ,32, true),
    controls = panelMenu
  }
end
