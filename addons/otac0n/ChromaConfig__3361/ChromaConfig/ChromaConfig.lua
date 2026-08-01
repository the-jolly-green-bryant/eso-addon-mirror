EVENT_MANAGER:RegisterForEvent(ChromaConfig.ADDON_NAME, EVENT_ADD_ON_LOADED, function (eventCode, name)
  if name ~= ChromaConfig.ADDON_NAME then return end
  ChromaConfig:Initialize()
  EVENT_MANAGER:UnregisterForEvent(ChromaConfig.ADDON_NAME, EVENT_ADD_ON_LOADED)
end)

function ChromaConfig:Initialize()
  ChromaConfig.active = IsChromaSystemAvailable()
  ChromaConfig:InitializeSettings()
  ChromaConfig:ResetAllianceEffects(nil, nil)
  ChromaConfig:ResetDeathEffects()
  ChromaConfig:ResetKeybindActionEffects()
  ChromaConfig.settingsMenu = ChromaConfigSettingsMenu:New()
end

function ChromaConfig:GetAllainceColor(alliance, inBattleground)
  local hex = ChromaConfig.backgroundVars.BackgroundColor
  if hex and (not inBattleground or ChromaConfig.backgroundVars.UseCustomColorDuringBattlegrounds) then
    return ZO_ColorDef:New(hex)
  end

  local allianceSettings, getColorFallback
  if inBattleground then
    allianceSettings = ChromaConfig.allianceVars.Teams[alliance]
    getColorFallback = GetBattlegroundAllianceColor
  else
    allianceSettings = ChromaConfig.allianceVars.Alliances[alliance]
    getColorFallback = GetAllianceColor
  end

  if allianceSettings.UseCustomColor then
    return ZO_ColorDef:New(allianceSettings.Color)
  else
    return getColorFallback(alliance)
  end
end

function ChromaConfig:ResetAllianceEffects(alliance, inBattleground)
  if not ChromaConfig.active then return end
  if inBattleground == nil then
    self:ResetAllianceEffects(alliance, false)
    self:ResetAllianceEffects(alliance, true)
    return
  end
  if alliance == nil then
    if inBattleground then
      for alliance = BATTLEGROUND_ALLIANCE_ITERATION_BEGIN, BATTLEGROUND_ALLIANCE_ITERATION_END do
        self:ResetAllianceEffects(alliance, inBattleground)
      end
    else
      for alliance = ALLIANCE_ITERATION_BEGIN, ALLIANCE_ITERATION_END do
        self:ResetAllianceEffects(alliance, inBattleground)
      end
    end
    return
  end

  local recreate = ZO_RZCHROMA_EFFECTS.activeAlliance == alliance and ZO_RZCHROMA_EFFECTS.inBattleground == inBattleground

  local oldEffects = ZO_RZCHROMA_EFFECTS:GetAllianceEffects(alliance, inBattleground)
  local newEffects = self:CreateAllianceEffects(alliance, inBattleground)

  for deviceType, newEffect in pairs(newEffects) do
    local oldEffect = oldEffects[deviceType]
    oldEffects[deviceType] = newEffect
    if recreate then
      ZO_RZCHROMA_MANAGER:RemoveEffect(oldEffect)
      ZO_RZCHROMA_MANAGER:AddEffect(newEffect)
    end
  end
end

function ChromaConfig:CreateAllianceEffects(alliance, inBattleground)
  local allianceColor = self:GetAllainceColor(alliance, inBattleground)
  allianceColor = allianceColor:Clone()
  allianceColor:SetAlpha(ZO_CHROMA_UNDERLAY_ALPHA)
  local r, g, b = allianceColor:UnpackRGB()
  local NO_ANIMATION_TIMER = nil
  return {
    [CHROMA_DEVICE_TYPE_KEYBOARD] = ZO_ChromaCStyleCustomSingleColorEffect:New(CHROMA_DEVICE_TYPE_KEYBOARD, ZO_CHROMA_EFFECT_DRAW_LEVEL.FALLBACK, CHROMA_CUSTOM_EFFECT_GRID_STYLE_FULL, NO_ANIMATION_TIMER, allianceColor, CHROMA_BLEND_MODE_NORMAL),
    [CHROMA_DEVICE_TYPE_KEYPAD] = ZO_ChromaCStyleCustomSingleColorEffect:New(CHROMA_DEVICE_TYPE_KEYPAD, ZO_CHROMA_EFFECT_DRAW_LEVEL.FALLBACK, CHROMA_CUSTOM_EFFECT_GRID_STYLE_FULL, NO_ANIMATION_TIMER, allianceColor, CHROMA_BLEND_MODE_NORMAL),
    [CHROMA_DEVICE_TYPE_MOUSE] = ZO_ChromaCStyleCustomSingleColorEffect:New(CHROMA_DEVICE_TYPE_MOUSE, ZO_CHROMA_EFFECT_DRAW_LEVEL.FALLBACK, CHROMA_CUSTOM_EFFECT_GRID_STYLE_FULL, NO_ANIMATION_TIMER, allianceColor, CHROMA_BLEND_MODE_NORMAL),
    [CHROMA_DEVICE_TYPE_MOUSEPAD] = ZO_ChromaCStyleCustomSingleColorEffect:New(CHROMA_DEVICE_TYPE_MOUSEPAD, ZO_CHROMA_EFFECT_DRAW_LEVEL.FALLBACK, CHROMA_CUSTOM_EFFECT_GRID_STYLE_FULL, NO_ANIMATION_TIMER, allianceColor, CHROMA_BLEND_MODE_NORMAL),
    [CHROMA_DEVICE_TYPE_HEADSET] = ZO_ChromaPredefinedEffect:New(CHROMA_DEVICE_TYPE_HEADSET, ZO_CHROMA_EFFECT_DRAW_LEVEL.FALLBACK, ChromaCreateHeadsetStaticEffect, r, g, b),
  }
end

function ChromaConfig:GetDeathEffectColor()
  local hex = ChromaConfig.notificationVars.DeathEffectColor
  if hex then
    return ZO_ColorDef:New(hex)
  end

  return ZO_ColorDef:New(1, 0, 0, 1)
end

function ChromaConfig:ResetDeathEffects()
  if not ChromaConfig.active then return end
  local recreate = IsUnitDead("player")

  local oldEffects = ZO_RZCHROMA_EFFECTS.deathEffects
  local newEffects = self:CreateDeathEffects()

  for deviceType, newEffect in pairs(newEffects) do
    local oldEffect = oldEffects[deviceType]
    oldEffects[deviceType] = newEffect
    if recreate then
      ZO_RZCHROMA_MANAGER:RemoveEffect(oldEffect)
      ZO_RZCHROMA_MANAGER:AddEffect(newEffect)
    end
  end
end

function ChromaConfig:CreateDeathEffects()
  local deathEffectColor = self:GetDeathEffectColor()
  local r, g, b = deathEffectColor:UnpackRGB()
  return {
    [CHROMA_DEVICE_TYPE_KEYBOARD] = ZO_ChromaCStyleCustomSingleColorFadingEffect:New(CHROMA_DEVICE_TYPE_KEYBOARD, ZO_CHROMA_EFFECT_DRAW_LEVEL.DEATH, CHROMA_CUSTOM_EFFECT_GRID_STYLE_FULL, ZO_CHROMA_ANIMATION_TIMER_DATA.DEATH_PULSATE, deathEffectColor, CHROMA_BLEND_MODE_NORMAL),
    [CHROMA_DEVICE_TYPE_KEYPAD] = ZO_ChromaCStyleCustomSingleColorFadingEffect:New(CHROMA_DEVICE_TYPE_KEYPAD, ZO_CHROMA_EFFECT_DRAW_LEVEL.DEATH, CHROMA_CUSTOM_EFFECT_GRID_STYLE_FULL, ZO_CHROMA_ANIMATION_TIMER_DATA.DEATH_PULSATE, deathEffectColor, CHROMA_BLEND_MODE_NORMAL),
    [CHROMA_DEVICE_TYPE_MOUSE] = ZO_ChromaCStyleCustomSingleColorFadingEffect:New(CHROMA_DEVICE_TYPE_MOUSE, ZO_CHROMA_EFFECT_DRAW_LEVEL.DEATH, CHROMA_CUSTOM_EFFECT_GRID_STYLE_FULL, ZO_CHROMA_ANIMATION_TIMER_DATA.DEATH_PULSATE, deathEffectColor, CHROMA_BLEND_MODE_NORMAL),
    [CHROMA_DEVICE_TYPE_MOUSEPAD] = ZO_ChromaCStyleCustomSingleColorFadingEffect:New(CHROMA_DEVICE_TYPE_MOUSEPAD, ZO_CHROMA_EFFECT_DRAW_LEVEL.DEATH, CHROMA_CUSTOM_EFFECT_GRID_STYLE_FULL, ZO_CHROMA_ANIMATION_TIMER_DATA.DEATH_PULSATE, deathEffectColor, CHROMA_BLEND_MODE_NORMAL),
    [CHROMA_DEVICE_TYPE_HEADSET] = ZO_ChromaPredefinedEffect:New(CHROMA_DEVICE_TYPE_HEADSET, ZO_CHROMA_EFFECT_DRAW_LEVEL.DEATH, ChromaCreateHeadsetBreathingEffect, r, g, b),
  }
end

function ChromaConfig:GetKeybindColor(actionName)
  local hex = ChromaConfig.notificationVars.Keybinds[actionName].Color
  if not hex and actionName:find("^DEATH_") ~= nil then
    hex = ChromaConfig.notificationVars.DeathKeybindColor
  end

  if hex then
    return ZO_ColorDef:New(hex)
  end

  return ZO_ColorDef:New(self.StaticData.Keybinds[actionName].DefaultColor)
end

function ChromaConfig:ResetKeybindActionEffects(actionName)
  if not ChromaConfig.active then return end
  if actionName == nil then
    for k,v in pairs(self.StaticData.Keybinds) do
      self:ResetKeybindActionEffects(k)
    end
    return
  end

  local quickslotReadyColor = self:GetKeybindColor(actionName)
  local existingVisualData = ZO_RZCHROMA_EFFECTS.keybindActionVisualData[actionName]

  ZO_RZCHROMA_EFFECTS:SetVisualDataForKeybindAction(actionName, existingVisualData.animationTimerData, quickslotReadyColor, existingVisualData.blendMode, existingVisualData.level)
  if ZO_RZCHROMA_EFFECTS.keybindActionEffects[actionName] then
    ZO_RZCHROMA_EFFECTS:RemoveKeybindActionEffect(actionName)
    ZO_RZCHROMA_EFFECTS:AddKeybindActionEffect(actionName)
  end
end
