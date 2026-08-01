Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.bahsei = ERG.bahsei or {}
local Bahsei = ERG.bahsei

----------------------------
-- Defaults and Variables --
----------------------------

function Bahsei.GetAddTrackerDefaults()
  return {
    enabled = true,
    left = 600,
    top = 600,
    size = 4,
    back = {enabled = true, opacity = 0.5},
  }
end

local abominationHealth = {
--  [0] = 100, --WARNING test
  [1] = 2414184,    -- normal
  [2] = 4268600,    -- veteran --4741332
  [3] = 7044070,    -- hardmode --7826749
}

-------------
-- Updates --
-------------

function Bahsei.OnAddTrackerUpdate()
  local panel = Bahsei.addTracker.panel
  local Abomination = Bahsei.addTracker.abomination

  --[[
  local output = ""
  for id, nextAoe in pairs( Bahsei.addTracker.abo) do
    local timeRemaining = ERG.GetTimeRemaining(nextAoe, false, "Soon")
    local maxHealth = abominationHealth[ERG.GetCustomDifficulty()]
    local dmgTaken = ERG.units.damage[id] or 0
    local currentHealth = maxHealth - dmgTaken
    local healthPerc = math.ceil(100*currentHealth / maxHealth)
    local healthStr = string.format("%.0f", healthPerc)
    output = zo_strformat("<<1>><<2>>% - Aoe <<3>> \n", output, healthStr, timeRemaining)
  end
  panel.label:SetText(output)
  ]]

  local output = ""
  for number, id in pairs (Abomination.unitList.id) do
    local nextAoe = Abomination.aoeCountdown[id]
    local timeRemaining = ERG.GetTimeRemaining(nextAoe, false, "Soon")
    local maxHealth = abominationHealth[ERG.GetCustomDifficulty()]
    local dmgTaken = ERG.units.damage[id] or 0
    local currentHealth = maxHealth - dmgTaken
    local healthPerc = math.ceil(100*currentHealth / maxHealth)
    local healthStr = string.format("%.0f", healthPerc)
    local aboStr = " Abo "..tostring(number)
    output = zo_strformat("<<1>><<2>> - <<3>>% - Aoe <<4>> \n", output, aboStr ,healthStr, timeRemaining)
  end
  panel.label:SetText(output)
end

-----------------
-- Alterations --
-----------------

function Bahsei.AdaptAddTrackerAccordingToProfile()
  local panel = Bahsei.addTracker.panel
  local store = ERG.store.bahsei.addTracker

  panel.win:ClearAnchors()
  panel.win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, store.left, store.top)

  panel.back:SetHidden(not store.back.enabled)
  panel.back:SetCenterColor(0,0,0, store.back.opacity)

  Bahsei.AdaptAddTrackerAccordingToSize()
end

function Bahsei.AdaptAddTrackerAccordingToSize()
  local size = ERG.store.bahsei.addTracker.size
  local panel = Bahsei.addTracker.panel

  panel.win:SetDimensions(size*83,size*30)
  panel.back:SetDimensions(size*83,size*30)

  panel.label:SetFont( ERG.GetFont(size*8) )
end
----------------
-- Initialize --
----------------


function Bahsei.InitializeAddTracker()
  Bahsei.addTracker = { abomination = { counter = 0, unitList = { number = {}, id = {}} , aoeCountdown = {} } }
  Bahsei.addTracker.panel = Bahsei.CreateAddTracker()
  Bahsei.AdaptAddTrackerAccordingToProfile()

  local function OnAbominationKill(id)
    ERG.units.damage[id] = nil
    local Abomination = Bahsei.addTracker.abomination
    local abominationNumber = Abomination.unitList.number[id] or 0
    --d("ERG abominationNumber: "..tostring(abominationNumber) )
    --if abominationNumber == 0 then
    --  d("UnitList: ")
    --  d(Abomination.unitList)
    --  d("-----")
    --end

    Abomination.aoeCountdown[id] = nil
    Abomination.unitList.id[abominationNumber] = nil
    Abomination.unitList.number[id] = nil
  end

  local function OnAbominationStatus(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local Abomination = Bahsei.addTracker.abomination

    if result == ACTION_RESULT_EFFECT_GAINED then
      --d("ERG AboSpawn Id: "..tostring(targetUnitId))
      Abomination.counter = Abomination.counter + 1
      Abomination.unitList.number[targetUnitId] = Abomination.counter
      Abomination.unitList.id[Abomination.counter] = targetUnitId
      Abomination.aoeCountdown[targetUnitId] = GetGameTimeMilliseconds()
      ERG.units.damage[targetUnitId] = 0
      --ERG.units.enemy[targetUnitId] = OnAbominationKill
    elseif result == ACTION_RESULT_EFFECT_FADED then
      --d("ERG AboKill Id: "..tostring(targetUnitId))
      OnAbominationKill(targetUnitId)
      --ERG.units.enemy[targetUnitId] = nil
    end
  end
  ERG.EM:RegisterForEvent(Bahsei.name.."AbominationStatus", EVENT_COMBAT_EVENT, OnAbominationStatus)
  ERG.EM:AddFilterForEvent(Bahsei.name.."AbominationStatus", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 150030)
  --ERG.EM:AddFilterForEvent(Bahsei.name.."AbominationSpawn", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

  local function OnRancidHammer(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if Bahsei.addTracker.abomination.aoeCountdown[targetUnitId] then
      Bahsei.addTracker.abomination.aoeCountdown[targetUnitId] = GetGameTimeMilliseconds() + 20000
    end
  end
  ERG.EM:RegisterForEvent(Bahsei.name.."RancidHammer", EVENT_COMBAT_EVENT, OnRancidHammer)
  ERG.EM:AddFilterForEvent(Bahsei.name.."RancidHammer", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 149922)
  ERG.EM:AddFilterForEvent(Bahsei.name.."RancidHammer", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)

  --[[SLASH_COMMANDS["/ergtest"] = function()
    local id = Bahsei.addTracker.abomination.counter + 100
    OnAbominationStatus(event, 2240, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, id, abilityId, overflow)
    OnRancidHammer(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, id, abilityId, overflow)
  end
  SLASH_COMMANDS["/ergtest2"] = function()
    OnAbominationKill(101)
  end]]
end

function Bahsei.CreateAddTracker()
  local name = Bahsei.name.."AddTracker"

  local win = ERG.WM:CreateTopLevelWindow( name.."Window" )
  win:SetHidden( true )
  win:SetMovable( true )
  win:SetClampedToScreen( true )
  win:SetMouseEnabled( true )
  win:SetHandler( "OnMoveStop", function( )
      ERG.store.bahsei.addTracker.left = win:GetLeft()
      ERG.store.bahsei.addTracker.top = win:GetTop()
    end)

  local frag = ZO_HUDFadeSceneFragment:New( win )
  table.insert(Bahsei.fragList, {frag = frag, IsEnabled = function() return ERG.store.bahsei.addTracker.enabled end} )

  local back = ERG.WM:CreateControl(name.."Background", win, CT_BACKDROP)
  back:ClearAnchors()
  back:SetAnchor(TOPLEFT, win, TOPLEFT, 0,0)
  back:SetEdgeColor(0,0,0,1)
  back:SetEdgeTexture(nil, 2, 2, 2)

  local label =ERG.WM:CreateControl(name.."Label", win, CT_LABEL)
  label:ClearAnchors()
  label:SetAnchor(TOPLEFT, win, TOPLEFT, 0,0 )
  label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
  label:SetHorizontalAlignment( TEXT_ALIGN_LEFT  )
  label:SetColor( 1,1,1,1 )
  label:SetFont( ERG.GetFont(20) )

  return {
    win = win,
    back = back,
    label = label,
  }
end

----------
-- Menu --
----------

function Bahsei.GetAddTrackerMenu()
  local panel = ERG.bahsei.addTracker.panel

  local panelMenu = ERG.GetBasicPanelMenu( "bahsei", "addTracker", Bahsei.AdaptAddTrackerAccordingToSize )

  return {
    type = "submenu",
    name = ERG.AddIconToString(ERG_BAHSEI_ADDTRACKER, "esoui/art/icons/ability_scrying_05b.dds", 32, true),
    controls = panelMenu,
  }
end
