Rockgroover = Rockgroover or {}
local ERG = Rockgroover

ERG.bahsei = ERG.bahsei or {}
local Bahsei = ERG.bahsei

local debuffId = {
  ["deathTouch"] = 150078,
  --["bleeding"] = 153179,
  --["scaldingWounds"] = 153177,
}

function Bahsei.GetDebuffIndicatorDefaults()
  local defaults = {}
    defaults[debuffId.deathTouch] = {
    enabled = true,
    left = 600,
    top = 600,
    }

  return defaults
end



function Bahsei.AdaptDebuffIndicatorAccordingToProfile()

end



function Bahsei.OnDebuffIndicatorUpdate()
  local duration = Bahsei.debuffIndicator.duration
  local panel = Bahsei.debuffIndicator.panel

  local id = debuffId.deathTouch
  --if not duration[id] then return end
  local timeRemaining = ERG.GetTimeRemaining( duration[id], true, "" )
  --if duration[id] then
    panel[id].label:SetText( timeRemaining )
  --else
    --panel[id].ctrl:SetHidden(true)
  --end
end



function Bahsei.InitializeDebuffIndicator()
  Bahsei.debuffIndicator = { duration = {}, panel = Bahsei.CreateDebuffIndicator() }
  Bahsei.debuffIndicator.duration[debuffId.deathTouch] = GetGameTimeMilliseconds()
  --Bahsei.debuffIndicator.data.player[ debuffId.deathTouch ] = {}
  --Bahsei.debuffIndicator.data.player[ debuffId.bleeding ] = {}
  --Bahsei.debuffIndicator.data.player[ debuffId.scaldingWounds ] = {}

  --/script Rockgroover.bahsei.debuffIndicator.duration[150078] = GetGameTimeMilliseconds() + 9000
  local function OnDebuff(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if unitTag ~= "player" then return end
    if changeType ~= EFFECT_RESULT_GAINED then return end
    if abilityId ~= debuffId.deathTouch then return end

    Bahsei.debuffIndicator.duration[abilityId] = GetGameTimeMilliseconds() + 9000 --TODO endTime*1000
    --table.insert( Bahsei.debuffIndicator.data.player[abilityId], endTime*1000)
  end

  for debuff, id in pairs(debuffId) do
    local eventName = Bahsei.name.."DebuffIndicator"..debuff
    ERG.EM:RegisterForEvent( eventName, EVENT_EFFECT_CHANGED, OnDebuff )
    ERG.EM:AddFilterForEvent( eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, id)
  end
end

function Bahsei.CreateDebuffIndicator()
  local name = Bahsei.name.."DebuffIndicator"

  local tempSize = 70

  local gui = {}

  local win = ERG.WM:CreateTopLevelWindow( name.."Window" )
  win:ClearAnchors()
  win:SetAnchor(CENTER, GuiRoot, TOPLEFT, ERG.store.bahsei.debuffIndicator[debuffId.deathTouch].left, ERG.store.bahsei.debuffIndicator[debuffId.deathTouch].top)
  win:SetHidden(true)
  win:SetMovable(true)
  win:SetDimensions(tempSize, tempSize)
  win:SetClampedToScreen( true )
  win:SetMouseEnabled( true )
  win:SetHandler( "OnMoveStop", function( )
      ERG.store.bahsei.debuffIndicator[debuffId.deathTouch].left = win:GetLeft()
      ERG.store.bahsei.debuffIndicator[debuffId.deathTouch].top = win:GetTop()
    end)


  local frag = ZO_HUDFadeSceneFragment:New( win )
  table.insert(Bahsei.fragList, {frag = frag, IsEnabled = function() return ERG.store.bahsei.debuffIndicator[debuffId.deathTouch].enabled end} )

  local ctrl = ERG.WM:CreateControl(name.."Control", win, CT_CONTROL)
  ctrl:ClearAnchors()
  ctrl:SetAnchor(CENTER, win, CENTER, 0, 0)

  for debuff, id in pairs( debuffId ) do
    gui[id] = {}
    local debuffCtrl = ERG.WM:CreateControl(name.."Control"..debuff, ctrl, CT_CONTROL)
    debuffCtrl:ClearAnchors()
    debuffCtrl:SetAnchor(CENTER, ctrl, CENTER, 0, 0)

    gui[id].ctrl = debuffCtrl

    local debuffLabel = ERG.WM:CreateControl(name.."Label"..debuff, debuffCtrl, CT_LABEL)
    debuffLabel:ClearAnchors()
    debuffLabel:SetAnchor(CENTER, debuffCtrl, CENTER, 0, 0)
    debuffLabel:SetColor(1,0,0,1)
    debuffLabel:SetFont( ERG.GetFont(50) )
    debuffLabel:SetText("x")
    debuffLabel:SetVerticalAlignment( TEXT_ALIGN_CENTER )
    debuffLabel:SetHorizontalAlignment( TEXT_ALIGN_CENTER  )

    local debuffIcon = ERG.WM:CreateControl(name.."Texture"..debuff, debuffCtrl, CT_TEXTURE)
    debuffIcon:ClearAnchors()
    debuffIcon:SetAnchor(CENTER, debuffCtrl, CENTER, 0, 0)
    debuffIcon:SetTexture( GetAbilityIcon(id) )
    debuffIcon:SetDimensions(tempSize, tempSize)

    gui[id].label = debuffLabel
  end

  gui.win = win
  gui.ctrl = ctrl
  return gui
end

function Bahsei.RebuildDebuffIndicator()

end

function Bahsei.GetDebuffIndicatorMenu()
  local panelMenu = {}
  --local panelMenu = ERG.GetBasicPanelMenu( "bahsei", "debuffIndicator", Bahsei.RebuildDebuffIndicator )
  return {
    type = "submenu",
    name = ERG.AddIconToString(ERG_BAHSEI_DEBUFF_INDICATOR, "esoui/art/icons/ability_scrying_05a.dds" ,32, true),
    controls = panelMenu,
  }
end
