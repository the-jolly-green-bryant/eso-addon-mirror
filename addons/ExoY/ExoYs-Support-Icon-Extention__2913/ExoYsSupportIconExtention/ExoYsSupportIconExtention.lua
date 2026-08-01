SupportIconExtention = SupportIconExtention or {}
local ESIE = SupportIconExtention

ESIE.name = "ExoYsSupportIconExtention"
ESIE.displayName = "|c00FF00ExoY|rs Support Icon Extention"
ESIE.version = "2.1.1"
ESIE.author = "@|c00FF00ExoY|r94 (PC/EU)"
ESIE.EM = GetEventManager()
ESIE.WM = GetWindowManager()



local mechanicId = {
  ["siroriaFlare"] = 103531,
  ["llothisBlast"] = 95545,
  ["bahseiDeathTouch"] = 150078,
  ["oaxiltsoPoison"] = 157860,
}

local defaultData = {
  [mechanicId.siroriaFlare] = {color = {1,0,0,1} },
  [mechanicId.llothisBlast] = {color = {0,1,0,1} },
  [mechanicId.oaxiltsoPoison] = {color = {0,1,0,1} },
  [mechanicId.bahseiDeathTouch] = {color = {0,1,1,1} },

}

local function OnAddonLoaded(event, addonName)
  if addonName == ESIE.name then
    ESIE.Initialize()
    ESIE.EM:UnregisterForEvent( ESIE.name, EVENT_ADD_ON_LOADED )
  end
end

ESIE.EM:RegisterForEvent( ESIE.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)


function ESIE.Initialize()
  local defaults = {
    --iconSize = OSI.GetOption( "iconsize" ),
    --iconOffset = 0,
    --countdownSize = 5,
    --countdownOffset = 5,
  }
  for _, id in pairs( mechanicId ) do
    defaults[id] = {}
    defaults[id].enabled = true
    --defaults[id].countdown = false
    defaults[id].color = defaultData[id].color
  end

  ESIE.store = ZO_SavedVars:NewAccountWide("ESIESV",2, nil, defaults)

  ESIE.texture = "OdySupportIcons/icons/arrow.dds"

  ESIE.countdown = {}

  ESIE.group = { tag = {}, id = {} }
  ESIE.EM:RegisterForEvent(ESIE.name.."IdentifyGroup", EVENT_EFFECT_CHANGED, ESIE.OnIdentifyGroupmember)
  ESIE.EM:AddFilterForEvent(ESIE.name.."IdentifyGroup", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
  ESIE.EM:RegisterForEvent(ESIE.name.."ResetGroupList", EVENT_PLAYER_ACTIVATED, function() ESIE.group = { tag = {}, id = {} } end)

  ESIE.EM:RegisterForUpdate(ESIE.name.."Update", 100, ESIE.OnUpdate)

  ESIE.RegisterMechanicEvents()

  ESIE.CreateMenu()
end

function ESIE.OnIdentifyGroupmember(event, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
  if changeType == EFFECT_RESULT_GAINED then
    if unitTag and unitId then
      ESIE.group.tag[unitId] = unitTag
      ESIE.group.id[unitTag] = unitId
    end
  end
end

function ESIE.RegisterMechanicEvents()
  ESIE.EM:RegisterForEvent(ESIE.name.."SiroriaFlare", EVENT_COMBAT_EVENT, ESIE.OnSiroriaFlare)
  ESIE.EM:AddFilterForEvent(ESIE.name.."SiroriaFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
  ESIE.EM:AddFilterForEvent(ESIE.name.."SiroriaFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, mechanicId.siroriaFlare)

  ESIE.EM:RegisterForEvent(ESIE.name.."SiroriaFlareExecute", EVENT_COMBAT_EVENT, ESIE.OnSiroriaFlare)
  ESIE.EM:AddFilterForEvent(ESIE.name.."SiroriaFlareExecute", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
  ESIE.EM:AddFilterForEvent(ESIE.name.."SiroriaFlareExecute", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 110431)

  ESIE.EM:RegisterForEvent(ESIE.name.."LlothisBlast", EVENT_COMBAT_EVENT, ESIE.OnLlothisBlast)
  ESIE.EM:AddFilterForEvent(ESIE.name.."LlothisBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
  ESIE.EM:AddFilterForEvent(ESIE.name.."LlothisBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, mechanicId.llothisBlast)

  ESIE.EM:RegisterForEvent(ESIE.name.."BahseiDeathTouch", EVENT_EFFECT_CHANGED, ESIE.OnBahseiDeathTouch)
  ESIE.EM:AddFilterForEvent(ESIE.name.."BahseiDeathTouch", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.bahseiDeathTouch)
  ESIE.EM:AddFilterForEvent(ESIE.name.."BahseiDeathTouch", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

  ESIE.EM:RegisterForEvent(ESIE.name.."OaxiltsoPoison", EVENT_EFFECT_CHANGED, ESIE.OnOaxiltsoPoison)
  ESIE.EM:AddFilterForEvent(ESIE.name.."OaxiltsoPoison", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.oaxiltsoPoison)
  ESIE.EM:AddFilterForEvent(ESIE.name.."OaxiltsoPoison", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end



------------
-- Update --
------------

function ESIE.OnUpdate()
  for key, data in pairs( ESIE.countdown ) do
    if data.control then
      if data.endTime then
        local timeRemaining = zo_max(data.endTime - GetGameTimeMilliseconds(), 0)
        if timeRemaining < 10000 and timeRemaining > 0 then
          data.control:SetText( string.format( "%.0f", math.ceil(timeRemaining/1000) ) )
          data.control:SetHidden(false)
        else
          data.control:SetHidden(true)
        end
      else
        data.control:SetHidden(true)
      end
    end
  end
end

---------------
-- Utilities --
---------------

function ESIE.GetDisplayName( input )
  if type(input) == "string" then return GetUnitDisplayName( input ) end
  if type(input) == "number" then return GetUnitDisplayName( ESIE.group.tag[input] ) end
  return ""
end

function ESIE.RemoveIcon( displayName )
  if ESIE.countdown[displayName] then
    ESIE.countdown[displayName].endTime = nil
  end
  OSI.RemoveMechanicIconForUnit( displayName )
end

function ESIE.InitializeCountdownControl( displayName )
  ESIE.countdown[displayName] = ESIE.countdown[displayName] or {}

  local icon = OSI.GetIconForPlayer( displayName )

  if icon.countdown then
    ESIE.countdown[displayName].control = icon.countdown
  else
    local countdown = icon.ctrl:CreateControl( icon.ctrl:GetName().."Countdown", CT_LABEL)
    countdown:ClearAnchors()
    countdown:SetAnchor( TOP, icon.ctrl, TOP, 0, 0)
    countdown:SetFont( "$(BOLD_FONT)|$(KB_54)|outline" )
    countdown:SetColor(0,0,0,1)
    countdown:SetDrawLevel( icon.ctrl:GetDrawLevel() + 1)

    icon.countdown = countdown
    ESIE.countdown[displayName].control = countdown
  end
end

------------------------
-- Mechanic Callbacks --
------------------------

function ESIE.OnSiroriaFlare(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  local svId = mechanicId.siroriaFlare
  if not ESIE.store[svId].enabled then return end
  local displayName = ESIE.GetDisplayName(targetUnitId)
  local duration = 7000
  ESIE.InitializeCountdownControl( displayName )
  OSI.SetMechanicIconForUnit( displayName, ESIE.texture, nil, ESIE.store[svId].color )
  ESIE.countdown[displayName].endTime = GetGameTimeMilliseconds() + duration
  zo_callLater( function() ESIE.RemoveIcon( displayName ) end, duration)
end

function ESIE.OnLlothisBlast(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  local svId = mechanicId.llothisBlast
  if not ESIE.store[svId].enabled then return end
  if hitValue ~= 0 then return end --TODO
  local displayName = ESIE.GetDisplayName(targetUnitId)
  local duration = 7000
  OSI.SetMechanicIconForUnit( displayName, ESIE.texture, nil, ESIE.store[svId].color )
  zo_callLater( function() ESIE.RemoveIcon( displayName ) end, duration)
end

function ESIE.OnBahseiDeathTouch(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
  local svId = mechanicId.bahseiDeathTouch
  if not ESIE.store[svId].enabled then return end
  local displayName = ESIE.GetDisplayName( unitTag )
  local duration = 9000
  ESIE.InitializeCountdownControl( displayName )
  if changeType == EFFECT_RESULT_GAINED then
    OSI.SetMechanicIconForUnit( displayName, ESIE.texture, nil, ESIE.store[svId].color )
    ESIE.countdown[displayName].endTime = GetGameTimeMilliseconds() + duration
    zo_callLater( function() ESIE.RemoveIcon( displayName ) end, duration)
  elseif changeType == EFFECT_RESULT_FADED then
    ESIE.RemoveIcon( displayName )
  end
end

function ESIE.OnOaxiltsoPoison(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  local svId = mechanicId.oaxiltsoPoison
  if not ESIE.store[svId].enabled then return end
  local displayName = ESIE.GetDisplayName( unitTag )
  if changeType == EFFECT_RESULT_GAINED then
    OSI.SetMechanicIconForUnit( displayName, ESIE.texture, nil, ESIE.store[svId].color )
  elseif changeType == EFFECT_RESULT_FADED then
    ESIE.RemoveIcon( displayName )
  end
end

----------
-- Menu --
----------

local function AddIconToString(icon, string)
  if type(icon) == "number" then
    icon = GetAbilityIcon(icon)
  end
  local iconStr = zo_strformat("|t<<2>>:<<2>>:<<1>>|t", icon, 32)
  return zo_strformat("<<1>> <<2>>", iconStr, string)
end

function ESIE.CreateMenu()
  local panelData = {
    type = "panel",
    name = ESIE.name,
    displayName = ESIE.displayName,
    author = ESIE.author,
    version = ESIE.version,
    registerForRefresh = true,
    --registerForDefaults = true,
  }
  local optionsData = {}
  local submenu = {}

  local function CreateMenuEntry(submenu, id)
    local abilityName = zo_strformat( SI_ABILITY_NAME, GetAbilityName(id) )
    table.insert(submenu, {
      type = "header",
      name = AddIconToString(id, abilityName),
    })
    table.insert(submenu, {
      type = "checkbox",
      name = "Enabled",
      getFunc = function() return ESIE.store[id].enabled end,
      setFunc = function(bool) ESIE.store[id].enabled = bool end,
    })
    table.insert(submenu, {
      type = "colorpicker",
      name = "Color",
      getFunc = function() return unpack( ESIE.store[id].color ) end,
      setFunc = function(r,g,b) ESIE.store[id].color = {r,g,b,1} end,
    })
    return submenu
  end

  submenu = CreateMenuEntry(submenu, mechanicId.llothisBlast)
  table.insert(optionsData, {type = "submenu", name = "Asylum Sanctorium", controls = submenu})

  -- Cloudrest
  submenu = {}
  -- Siroria
  submenu = CreateMenuEntry(submenu, mechanicId.siroriaFlare)
  table.insert(optionsData, {type = "submenu", name = "Cloudrest", controls = submenu})

  -- Rockgrove
  submenu = {}
  -- oaxiltso
  submenu = CreateMenuEntry(submenu, mechanicId.oaxiltsoPoison)
  -- bahsei
  submenu = CreateMenuEntry(submenu, mechanicId.bahseiDeathTouch)
  table.insert(optionsData, {type = "submenu", name = "Rockgrove", controls = submenu})

  --general: size, offset for icon and countdown

  --countdown
  LibAddonMenu2:RegisterAddonPanel("ESIE_Menu", panelData)
  LibAddonMenu2:RegisterOptionControls("ESIE_Menu", optionsData)
end
