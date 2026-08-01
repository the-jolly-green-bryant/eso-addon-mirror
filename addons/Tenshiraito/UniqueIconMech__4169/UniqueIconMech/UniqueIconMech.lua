UniqueIconMech = UniqueIconMech or {}
local UIM = UniqueIconMech

UIM.EM = GetEventManager()
UIM.WM = GetWindowManager()

local mechanicId = {
  ["siroriaFlare"] = 103531,
  ["SiroriaFlareExecute"] = 110431,
  ["llothisBlast"] = 95545,
  ["bahseiDeathTouch"] = 150078,
  ["oaxiltsoPoison"] = 157860,
  ["Hoarfrost"] = 103695,
  ["HoarfrostExecute"] = 110516,
  ["Voltaic_Overload"] = 103555,
  ["BaneFul_Mark"] = 107082,
  ["Rapid_deluge1"] = 174959,
  ["Rapid_deluge2"] = 174960,
  ["Rapid_deluge3"] = 174961,
}

local defaultData = {
  [mechanicId.siroriaFlare] = {texture = "/esoui/art/icons/ability_u45_dun1_b3_fireorb_syn.dds"},
  [mechanicId.SiroriaFlareExecute] = {texture = "/esoui/art/icons/ability_u45_dun1_b3_fireorb_syn.dds"},
  [mechanicId.Hoarfrost] = {texture = "/esoui/art/icons/ability_u45_dun2_b2_bluewhirlwind.dds"},
  [mechanicId.HoarfrostExecute] = {texture = "/esoui/art/icons/ability_u45_dun2_b2_bluewhirlwind.dds"},
  [mechanicId.Voltaic_Overload] = {texture = "/esoui/art/icons/ability_u46_dominatorschains_burst.dds"},
  [mechanicId.llothisBlast] = {texture = "/esoui/art/icons/ability_death_recap_shock_chainlightning.dds"},
  [mechanicId.oaxiltsoPoison] = {texture = "/esoui/art/icons/death_recap_poison_aoe2.dds"},
  [mechanicId.bahseiDeathTouch] = {texture = "/esoui/art/icons/death_recap_disease_dot_heavy2.dds"},
  [mechanicId.BaneFul_Mark] = {texture = "/esoui/art/icons/u45_ability_dun1_execute.dds"},
  [mechanicId.Rapid_deluge1] = {texture = "/esoui/art/icons/ability_u34_whirlpool.dds"},
  [mechanicId.Rapid_deluge2] = {texture = "/esoui/art/icons/ability_u34_whirlpool.dds"},
  [mechanicId.Rapid_deluge3] = {texture = "/esoui/art/icons/ability_u34_whirlpool.dds"},
}

local function OnAddonLoaded(event, addonName)
  if addonName == UIM.name then
    UIM.Initialize()
	UIM.RegisterMechanicEvents()
	UIM.CreateMenu()
    UIM.EM:UnregisterForEvent( UIM.name, EVENT_ADD_ON_LOADED )
  end
end

UIM.EM:RegisterForEvent( UIM.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

function UIM.Initialize()
   UIM.texture = "OdySupportIcons/icons/arrow.dds"
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
	defaults[id].texture = (defaultData[id] and defaultData[id].texture) or UIM.texture
  end

  UIM.store = ZO_SavedVars:NewAccountWide("UniqueIconMech",2, nil, defaults)

  UIM.countdown = {}

  UIM.group = { tag = {}, id = {} }
  UIM.EM:RegisterForEvent(UIM.name.."IdentifyGroup", EVENT_EFFECT_CHANGED, UIM.OnIdentifyGroupmember)
  UIM.EM:AddFilterForEvent(UIM.name.."IdentifyGroup", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
  UIM.EM:RegisterForEvent(UIM.name.."ResetGroupList", EVENT_PLAYER_ACTIVATED, function() UIM.group = { tag = {}, id = {} } end)

  UIM.EM:RegisterForUpdate(UIM.name.."Update", 100, UIM.OnUpdate)

end

function UIM.OnUpdate()
  for key, data in pairs( UIM.countdown ) do
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

function UIM.GetDisplayName( input )
	if type(input) == "string" then return GetUnitDisplayName( input ) end
	if type(input) == "number" then return GetUnitDisplayName( UIM.group.tag[input] ) end
	return ""
end

function UIM.RemoveIcon( displayName )
	if UIM.countdown[displayName] then
		UIM.countdown[displayName].endTime = nil
	end
	OSI.RemoveMechanicIconForUnit( displayName )
end

function UIM.InitializeCountdownControl( displayName )
	UIM.countdown[displayName] = UIM.countdown[displayName] or {}
	local icon = OSI.GetIconForPlayer( displayName )

	if icon.countdown then
		UIM.countdown[displayName].control = icon.countdown
	else
    local countdown = icon.ctrl:CreateControl( icon.ctrl:GetName().."Countdown", CT_LABEL)
    countdown:ClearAnchors()
    countdown:SetAnchor( TOP, icon.ctrl, TOP, 0, 0)
    countdown:SetFont( "$(BOLD_FONT)|$(KB_36)|outline" )
    countdown:SetColor(1,1,1,1)
    countdown:SetDrawLevel( icon.ctrl:GetDrawLevel() + 1)

    icon.countdown = countdown
    UIM.countdown[displayName].control = countdown
  end
end

function UIM.OnSiroriaFlare(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	local svId = mechanicId.siroriaFlare
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName(targetUnitId)
	local duration = 7000
	UIM.InitializeCountdownControl(displayName)
	OSI.SetMechanicIconForUnit(displayName, texture, nil, nil)
	UIM.countdown[displayName].endTime = GetGameTimeMilliseconds() + duration
	zo_callLater(function() UIM.RemoveIcon(displayName) end, duration)
end

function UIM.OnSiroriaFlareExecute(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	local svId = mechanicId.SiroriaFlareExecute
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName(targetUnitId)
	local duration = 7000
	UIM.InitializeCountdownControl(displayName)
	OSI.SetMechanicIconForUnit(displayName, texture, nil, nil)
	UIM.countdown[displayName].endTime = GetGameTimeMilliseconds() + duration
	zo_callLater(function() UIM.RemoveIcon(displayName) end, duration)
end

function UIM.OnHoarfrost(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	local svId = mechanicId.Hoarfrost
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName( unitTag )
	if changeType == EFFECT_RESULT_GAINED then
		OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
	elseif changeType == EFFECT_RESULT_FADED then
		UIM.RemoveIcon( displayName )
	end
end

function UIM.OnHoarfrostExecute(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	local svId = mechanicId.HoarfrostExecute
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName( unitTag )
	if changeType == EFFECT_RESULT_GAINED then
		OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
	elseif changeType == EFFECT_RESULT_FADED then
		UIM.RemoveIcon( displayName )
	end
end

function UIM.OnVoltaic_Overload(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	local svId = mechanicId.Voltaic_Overload
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName(targetUnitId)
	local duration = 10000
	UIM.InitializeCountdownControl( displayName )
	OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
	UIM.countdown[displayName].endTime = GetGameTimeMilliseconds() + duration
	zo_callLater( function() UIM.RemoveIcon( displayName ) end, duration)
end

function UIM.OnLlothisBlast(event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	local svId = mechanicId.llothisBlast
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	if hitValue ~= 0 then return end --TODO
	local displayName = UIM.GetDisplayName(targetUnitId)
	local duration = 7000
	OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
	zo_callLater( function() UIM.RemoveIcon( displayName ) end, duration)
end

function UIM.OnBahseiDeathTouch(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	local svId = mechanicId.bahseiDeathTouch
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName( unitTag )
	local duration = 9000
	UIM.InitializeCountdownControl( displayName )
	if changeType == EFFECT_RESULT_GAINED then
		OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
		UIM.countdown[displayName].endTime = GetGameTimeMilliseconds() + duration
		zo_callLater( function() UIM.RemoveIcon( displayName ) end, duration)
	elseif changeType == EFFECT_RESULT_FADED then
		UIM.RemoveIcon( displayName )
	end
end

function UIM.OnOaxiltsoPoison(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	local svId = mechanicId.oaxiltsoPoison
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName( unitTag )
	if changeType == EFFECT_RESULT_GAINED then
		OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
	elseif changeType == EFFECT_RESULT_FADED then
		UIM.RemoveIcon( displayName )
	end
end

function UIM.OnBaneFul_Mark(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	local svId = mechanicId.BaneFul_Mark
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName( unitTag )
	if changeType == EFFECT_RESULT_GAINED then
		OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
	elseif changeType == EFFECT_RESULT_FADED then
		UIM.RemoveIcon( displayName )
	end
end

function UIM.OnRapid_deluge1(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	local svId = mechanicId.Rapid_deluge1
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName( unitTag )
	if changeType == EFFECT_RESULT_GAINED then
		OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
	elseif changeType == EFFECT_RESULT_FADED then
		UIM.RemoveIcon( displayName )
	end
end

function UIM.OnRapid_deluge2(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	local svId = mechanicId.Rapid_deluge2
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName( unitTag )
	if changeType == EFFECT_RESULT_GAINED then
		OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
	elseif changeType == EFFECT_RESULT_FADED then
		UIM.RemoveIcon( displayName )
	end
end

function UIM.OnRapid_deluge3(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	local svId = mechanicId.Rapid_deluge3
	if not UIM.store[svId].enabled then return end
	local texture = UIM.store[svId].texture or UIM.texture
	local displayName = UIM.GetDisplayName( unitTag )
	if changeType == EFFECT_RESULT_GAINED then
		OSI.SetMechanicIconForUnit( displayName, texture, nil, nil)
	elseif changeType == EFFECT_RESULT_FADED then
		UIM.RemoveIcon( displayName )
	end
end

function UIM.OnIdentifyGroupmember(event, changeType, _, _, unitTag, _, _, _, _, _, _, _, _, _, unitId)
  if changeType == EFFECT_RESULT_GAINED then
    if unitTag and unitId then
      UIM.group.tag[unitId] = unitTag
      UIM.group.id[unitTag] = unitId
    end
  end
end

function UIM.RegisterMechanicEvents()
	UIM.EM:RegisterForEvent(UIM.name.."SiroriaFlare", EVENT_COMBAT_EVENT, UIM.OnSiroriaFlare)
	UIM.EM:AddFilterForEvent(UIM.name.."SiroriaFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
	UIM.EM:AddFilterForEvent(UIM.name.."SiroriaFlare", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, mechanicId.siroriaFlare)

	UIM.EM:RegisterForEvent(UIM.name.."Hoarfrost", EVENT_EFFECT_CHANGED, UIM.OnHoarfrost)
	UIM.EM:AddFilterForEvent(UIM.name.."Hoarfrost", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.Hoarfrost)
	UIM.EM:AddFilterForEvent(UIM.name.."Hoarfrost", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

	UIM.EM:RegisterForEvent(UIM.name.."Voltaic_Overload", EVENT_COMBAT_EVENT, UIM.OnVoltaic_Overload)
	UIM.EM:AddFilterForEvent(UIM.name.."Voltaic_Overload", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
	UIM.EM:AddFilterForEvent(UIM.name.."Voltaic_Overload", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, mechanicId.Voltaic_Overload)
  
	UIM.EM:RegisterForEvent(UIM.name.."SiroriaFlareExecute", EVENT_COMBAT_EVENT, UIM.OnSiroriaFlareExecute)
	UIM.EM:AddFilterForEvent(UIM.name.."SiroriaFlareExecute", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
	UIM.EM:AddFilterForEvent(UIM.name.."SiroriaFlareExecute", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, mechanicId.SiroriaFlareExecute)
	
	UIM.EM:RegisterForEvent(UIM.name.."HoarfrostExecute", EVENT_EFFECT_CHANGED, UIM.OnHoarfrostExecute)
	UIM.EM:AddFilterForEvent(UIM.name.."HoarfrostExecute", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.HoarfrostExecute)
	UIM.EM:AddFilterForEvent(UIM.name.."HoarfrostExecute", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

	UIM.EM:RegisterForEvent(UIM.name.."LlothisBlast", EVENT_COMBAT_EVENT, UIM.OnLlothisBlast)
	UIM.EM:AddFilterForEvent(UIM.name.."LlothisBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
	UIM.EM:AddFilterForEvent(UIM.name.."LlothisBlast", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, mechanicId.llothisBlast)
	
	UIM.EM:RegisterForEvent(UIM.name.."BahseiDeathTouch", EVENT_EFFECT_CHANGED, UIM.OnBahseiDeathTouch)
	UIM.EM:AddFilterForEvent(UIM.name.."BahseiDeathTouch", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.bahseiDeathTouch)
	UIM.EM:AddFilterForEvent(UIM.name.."BahseiDeathTouch", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

	UIM.EM:RegisterForEvent(UIM.name.."OaxiltsoPoison", EVENT_EFFECT_CHANGED, UIM.OnOaxiltsoPoison)
	UIM.EM:AddFilterForEvent(UIM.name.."OaxiltsoPoison", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.oaxiltsoPoison)
	UIM.EM:AddFilterForEvent(UIM.name.."OaxiltsoPoison", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	
	UIM.EM:RegisterForEvent(UIM.name.."BaneFul_Mark", EVENT_EFFECT_CHANGED, UIM.OnBaneFul_Mark)
	UIM.EM:AddFilterForEvent(UIM.name.."BaneFul_Mark", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.BaneFul_Mark)
	UIM.EM:AddFilterForEvent(UIM.name.."BaneFul_Mark", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
		
	UIM.EM:RegisterForEvent(UIM.name.."Rapid_deluge1", EVENT_EFFECT_CHANGED, UIM.OnRapid_deluge1)
	UIM.EM:AddFilterForEvent(UIM.name.."Rapid_deluge1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.Rapid_deluge1)
	UIM.EM:AddFilterForEvent(UIM.name.."Rapid_deluge1", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
		
	UIM.EM:RegisterForEvent(UIM.name.."Rapid_deluge2", EVENT_EFFECT_CHANGED, UIM.OnRapid_deluge2)
	UIM.EM:AddFilterForEvent(UIM.name.."Rapid_deluge2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.Rapid_deluge2)
	UIM.EM:AddFilterForEvent(UIM.name.."Rapid_deluge2", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
	
	UIM.EM:RegisterForEvent(UIM.name.."Rapid_deluge3", EVENT_EFFECT_CHANGED, UIM.OnRapid_deluge3)
	UIM.EM:AddFilterForEvent(UIM.name.."Rapid_deluge3", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, mechanicId.Rapid_deluge3)
	UIM.EM:AddFilterForEvent(UIM.name.."Rapid_deluge3", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

function UIM.CreateMenu()
  local panelData = {
    type = "panel",
    name = "UniqueIconMechSettings",
    displayName = "UniqueIconMech",
    author = "|c530effT|r|c4a1dffe|r|c422bffn|r|c3a39ffs|r|c3248ffhiraito|r",
    version = "1.0",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local optionsData = {}

  local mechanicCategories = {
    ["Cloudrest"] = {
      mechanicId.siroriaFlare,
      mechanicId.Hoarfrost,
      mechanicId.Voltaic_Overload,
	  mechanicId.BaneFul_Mark,
    },
    ["Asylum Sanctorium"] = {
      mechanicId.llothisBlast,
    },
    ["Rockgrove"] = {
      mechanicId.oaxiltsoPoison,
      mechanicId.bahseiDeathTouch,
    },
	["Dreadsail Reed"] = {
	  mechanicId.Rapid_deluge1,
	  mechanicId.Rapid_deluge2,
	  mechanicId.Rapid_deluge3,
	},
  }

  local function AddIconToString(icon, text)
    if type(icon) == "number" then
      icon = GetAbilityIcon(icon)
    end
    local iconStr = zo_strformat("|t<<2>>:<<2>>:<<1>>|t", icon, 40)
    return zo_strformat("<<1>> <<2>>", iconStr, text)
  end

  local function CreateMechanicOptions(id)
    local abilityName = zo_strformat(SI_ABILITY_NAME, GetAbilityName(id))
    local options = {}

    table.insert(options, {
      type = "header",
      name = AddIconToString(id, abilityName),
    })
    
	table.insert(options, {
        type = "texture",
        image = UIM.store[id].texture or UIM.texture,
        imageWidth = 40,
        imageHeight = 40,
        tooltip = "Current icon used for this mechanic.(Set as 40x40)",
    })

    table.insert(options, {
      type = "checkbox",
      name = "Enabled",
      getFunc = function() return UIM.store[id].enabled end,
      setFunc = function(v) UIM.store[id].enabled = v end,
    })
	return options
  end

  for categoryName, mechanicList in pairs(mechanicCategories) do
    local categoryControls = {}
    for _, id in ipairs(mechanicList) do
      local mechanicOptions = CreateMechanicOptions(id)
      for _, option in ipairs(mechanicOptions) do
        table.insert(categoryControls, option)
      end
    end

    table.insert(optionsData, {
      type = "submenu",
      name = categoryName,
      controls = categoryControls,
    })
  end

  LibAddonMenu2:RegisterAddonPanel("UIM_Menu", panelData)
  LibAddonMenu2:RegisterOptionControls("UIM_Menu", optionsData)
end
