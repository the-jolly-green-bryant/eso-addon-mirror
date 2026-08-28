QDRH = QDRH or {}
local QDRH = QDRH

function QDRH.IdentifyUnit(unitTag, unitName, unitId)
  if (not QDRH.units[unitId] and 
    (string.sub(unitTag, 1, 5) == "group" or string.sub(unitTag, 1, 6) == "player" or string.sub(unitTag, 1, 4) == "boss")) then
    QDRH.units[unitId] = {
      tag = unitTag,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
    QDRH.unitsTag[unitTag] = {
      id = unitId,
      name = GetUnitDisplayName(unitTag) or unitName,
    }
  end
end

function QDRH.GetTagForId(targetUnitId)
  if QDRH.units == nil or QDRH.units[targetUnitId] == nil then
    return ""
  end
  return QDRH.units[targetUnitId].tag
end

function QDRH.GetTagForId(targetUnitId)
  if QDRH.units == nil or QDRH.units[targetUnitId] == nil then
    return ""
  end
  return QDRH.units[targetUnitId].tag
end

function QDRH.GetNameForId(targetUnitId)
  if QDRH.units == nil or QDRH.units[targetUnitId] == nil then
    return ""
  end
  return QDRH.units[targetUnitId].name
end

function QDRH.GetDist(x1, y1, z1, x2, y2, z2)
  if x1 == nil or y1 == nil or z1 == nil or x2 == nil or y2 == nil or z2 == nil then
    return 1000000000
  end
  local dx = x1 - x2
  local dy = y1 - y2
  local dz = z1 - z2
  return dx*dx + dy*dy + dz*dz
end

function QDRH.GetDistMeters(x1, y1, z1, x2, y2, z2)
  return math.sqrt(QDRH.GetDist(x1, y1, z1, x2, y2, z2))/100
end

function QDRH.GetPlayerDist(unitTag1, unitTag2)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag1)
  local tworld, tx, ty, tz = GetUnitWorldPosition(unitTag2)
  return QDRH.GetDist(px, py, pz, tx, ty, tz)
end

function QDRH.GetUnitToPlaceDist(unitTag, x, y, z)
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  return QDRH.GetDist(px, py, pz, x, y, z)
end

function QDRH.GetPlayerToPlaceDist(x, y, z)
  return QDRH.GetUnitToPlaceDist("player", x, y, z)
end

function QDRH.GetUnitHealthPercent(unitTag)
  if unitTag == nil or GetUnitPower == nil then
    return nil, nil, nil, nil, nil
  end

  local fallbackCurrentHP = nil
  local fallbackMaxHP = nil
  local fallbackEffectiveMaxHP = nil
  local fallbackSource = nil

  local function readPower(powerType, source)
    if powerType == nil then
      return nil, nil, nil, nil, nil
    end

    local currentHP, maxHP, effectiveMaxHP = GetUnitPower(unitTag, powerType)
    if fallbackSource == nil then
      fallbackCurrentHP = currentHP
      fallbackMaxHP = maxHP
      fallbackEffectiveMaxHP = effectiveMaxHP
      fallbackSource = source
    end

    if currentHP ~= nil and maxHP ~= nil and maxHP > 0 then
      return currentHP / maxHP, currentHP, maxHP, source, effectiveMaxHP
    end

    return nil, currentHP, maxHP, source, effectiveMaxHP
  end

  local percent, currentHP, maxHP, source, effectiveMaxHP =
    readPower(COMBAT_MECHANIC_FLAGS_HEALTH, "combat")
  if percent ~= nil then
    return percent, currentHP, maxHP, source, effectiveMaxHP
  end

  if POWERTYPE_HEALTH ~= COMBAT_MECHANIC_FLAGS_HEALTH then
    percent, currentHP, maxHP, source, effectiveMaxHP =
      readPower(POWERTYPE_HEALTH, "power")
    if percent ~= nil then
      return percent, currentHP, maxHP, source, effectiveMaxHP
    end
  end

  if QDRH.bossHealthCache ~= nil and QDRH.bossHealthCache[unitTag] ~= nil then
    local cached = QDRH.bossHealthCache[unitTag]
    if cached.current ~= nil and cached.max ~= nil and cached.max > 0 then
      return cached.current / cached.max, cached.current, cached.max, "event", cached.effectiveMax
    end
  end

  return nil, fallbackCurrentHP, fallbackMaxHP, fallbackSource, fallbackEffectiveMaxHP
end

function QDRH.GetBossHealthPercentByName(namePart)
  local lowerNamePart = nil
  if namePart ~= nil and namePart ~= "" then
    lowerNamePart = string.lower(namePart)
  end

  local fallbackPercent = nil
  local fallbackMaxHP = 0
  local fallbackUnitTag = nil
  local fallbackUnitName = nil

  local function nameMatches(unitName)
    if lowerNamePart == nil then
      return true
    end
    if unitName == nil or unitName == "" then
      return false
    end

    local lowerUnitName = string.lower(unitName)
    return string.find(lowerUnitName, lowerNamePart, 1, true) ~= nil or
      string.find(lowerNamePart, lowerUnitName, 1, true) ~= nil
  end

  local function checkUnit(unitTag)
    if unitTag == nil then
      return nil
    end

    if IsUnitDead ~= nil and IsUnitDead(unitTag) then
      return nil
    end
    if IsUnitPlayer ~= nil and IsUnitPlayer(unitTag) then
      return nil
    end

    local percent, currentHP, maxHP, source, effectiveMaxHP = QDRH.GetUnitHealthPercent(unitTag)
    if percent == nil then
      return nil
    end

    local unitName = GetUnitName(unitTag)
    if (unitName == nil or unitName == "") and
      QDRH.bossHealthCache ~= nil and QDRH.bossHealthCache[unitTag] ~= nil then
      unitName = QDRH.bossHealthCache[unitTag].name
    end
    if nameMatches(unitName) then
      return percent, unitTag, unitName, currentHP, maxHP, source, effectiveMaxHP
    end

    if maxHP > fallbackMaxHP then
      fallbackPercent = percent
      fallbackMaxHP = maxHP
      fallbackUnitTag = unitTag
      fallbackUnitName = unitName
    end
  end

  for i = 1, (BOSS_RANK_ITERATION_END or MAX_BOSSES or 6) do
    local percent, unitTag, unitName, currentHP, maxHP, source, effectiveMaxHP = checkUnit("boss" .. tostring(i))
    if percent ~= nil then
      return percent, unitTag, unitName, currentHP, maxHP, source, effectiveMaxHP
    end
  end

  if fallbackPercent ~= nil then
    local currentHP = nil
    local maxHP = nil
    local source = nil
    local effectiveMaxHP = nil
    if fallbackUnitTag ~= nil then
      _, currentHP, maxHP, source, effectiveMaxHP = QDRH.GetUnitHealthPercent(fallbackUnitTag)
    end
    return fallbackPercent, fallbackUnitTag, fallbackUnitName, currentHP, maxHP, source, effectiveMaxHP
  end

  return nil, nil, nil, nil, nil, nil, nil
end

function QDRH.GetClosestGroupDist(x, y, z)
  local closest = 1000000000
  -- TODO: Check if I can detect group size, for the very niche case of smaller groups.
  -- TODO: Check if it works out of group.
  for i = 1, 12 do
    local tag = "group" .. tostring(i)
    local d = QDRH.GetUnitToPlaceDist(tag, x, y, z)
    if d < closest then
      closest = d
    end
  end
  return closest
end

function QDRH.IsPlayerInBox(xmin, xmax, zmin, zmax)
  local pworld, px, py, pz = GetUnitWorldPosition("player")
  return xmin < px and px < xmax and zmin < pz and pz < zmax
end

function QDRH.hasOSI()
  if QDRH.savedVariables then
    if QDRH.savedVariables.enableOSIcons ~= true then
      return false
    end
  elseif QDRH.disableOSIconsByDefault then
    return false
  end

  return OSI ~= nil
    and OSI.CreatePositionIcon ~= nil
    and OSI.DiscardPositionIcon ~= nil
    and OSI.GetIconSize ~= nil
    and OSI.SetMechanicIconForUnit ~= nil
    and OSI.RemoveMechanicIconForUnit ~= nil
end

function QDRH.IconFallback(message, durationMillisec, sound)
  if QDRH.hasOSI() or message == nil or message == "" then
    return
  end
  if QDRH.savedVariables and QDRH.savedVariables.showConsoleIconFallbacks == false then
    return
  end

  QDRH.iconFallbackLast = QDRH.iconFallbackLast or {}
  local now = GetGameTimeSeconds()
  if QDRH.iconFallbackLast[message] ~= nil and now - QDRH.iconFallbackLast[message] < 1 then
    return
  end
  QDRH.iconFallbackLast[message] = now

  if CombatAlerts and CombatAlerts.Alert then
    CombatAlerts.Alert("", message, 0xFFD666FF, sound, durationMillisec or 3000)
  elseif d then
    d("[QDRH] " .. tostring(message))
  end
end

function QDRH.hasM0RMarkers()
  return M0RMarkers ~= nil
    and M0RMarkers.createTemporaryGroupIcon ~= nil
    and M0RMarkers.tempMarkers ~= nil
end

function QDRH.ShouldShowConsoleHeadMarkers()
  return not QDRH.hasOSI()
    and QDRH.hasM0RMarkers()
    and QDRH.savedVariables ~= nil
    and QDRH.savedVariables.showConsoleIconFallbacks ~= false
end

function QDRH.ShouldShowRuneHeadIcons()
  return (QDRH.savedVariables ~= nil and QDRH.savedVariables.showRuneIcons == true)
    or QDRH.ShouldShowConsoleHeadMarkers()
end

function QDRH.GetUnitTagForDisplayName(displayName)
  if displayName == nil or displayName == "" then
    return ""
  end

  for i = 1, 12 do
    local unitTag = "group" .. tostring(i)
    if GetUnitDisplayName(unitTag) == displayName then
      return unitTag
    end
  end

  if GetUnitDisplayName("player") == displayName then
    return "player"
  end

  return ""
end

function QDRH.GetPlayerM0RUnitTag()
  local displayName = GetUnitDisplayName("player")
  local groupTag = QDRH.GetUnitTagForDisplayName(displayName)
  if groupTag ~= "" then
    return groupTag
  end

  return "player"
end

function QDRH.GetM0RHeadMarkerTexture(texture)
  if texture == nil then
    return nil
  end

  if texture == "QcellDreadsailReefHelper/icons/fire-pin.dds" or
    texture == "QcellDreadsailReefHelper/icons/firepin_console_v2.dds" or
    texture == "QcellDreadsailReefHelper/icons/firepin_console_v3.dds" or
    texture == "QcellDreadsailReefHelper/icons/firepin_console_v4.dds" or
    texture == "QcellDreadsailReefHelper/icons/firepin_console_v5.dds" then
    return "QcellDreadsailReefHelper/icons/firepin_console_v5.dds"
  end

  if texture == "QcellDreadsailReefHelper/icons/ice-pin.dds" or
    texture == "QcellDreadsailReefHelper/icons/icepin_console_v2.dds" or
    texture == "QcellDreadsailReefHelper/icons/icepin_console_v3.dds" or
    texture == "QcellDreadsailReefHelper/icons/icepin_console_v4.dds" or
    texture == "QcellDreadsailReefHelper/icons/icepin_console_v5.dds" then
    return "QcellDreadsailReefHelper/icons/icepin_console_v5.dds"
  end

  return nil
end

function QDRH.WarmupConsoleMarkerTextures()
  local controls = {
    {
      control = QDRHConsoleTextureLoadV4FirePin,
      texture = "QcellDreadsailReefHelper/icons/firepin_console_v5.dds",
    },
    {
      control = QDRHConsoleTextureLoadV4IcePin,
      texture = "QcellDreadsailReefHelper/icons/icepin_console_v5.dds",
    },
  }

  if QDRHConsoleTextureLoadV4 then
    QDRHConsoleTextureLoadV4:SetHidden(false)
    QDRHConsoleTextureLoadV4:SetAlpha(0)
  end

  for _, item in ipairs(controls) do
    local control = item.control
    if control ~= nil then
      control:SetHidden(false)
      control:SetAlpha(0)
      if control.SetDimensions then
        control:SetDimensions(2, 2)
      end
      control:SetTexture(item.texture)
      if control.GetTextureFileDimensions then
        control:GetTextureFileDimensions()
      end
    end
  end
end

function QDRH.GetM0RTextureFallback(texture)
  if texture == "QcellDreadsailReefHelper/icons/firepin_console_v5.dds" then
    return "M0RMarkers/textures/diamond.dds", {1, 0.25, 0.05, 1}
  end

  if texture == "QcellDreadsailReefHelper/icons/icepin_console_v5.dds" then
    return "M0RMarkers/textures/diamond.dds", {0.35, 0.8, 1, 1}
  end

  return nil, nil
end

function QDRH.ApplyM0RMarkerVisual(marker, texture, colour, size, text, textScale)
  if marker == nil then
    return
  end

  marker.bgTexture = texture
  marker.colour = colour or {1, 1, 1, 1}
  marker.size = size or marker.size or 0.9
  marker.text = text or marker.text or ""
  marker.textScale = textScale or marker.textScale

  if marker.control == nil then
    return
  end

  marker.control:SetHidden(false)
  marker.control:SetTransformScale(marker.size * ((M0RMarkers.vars and M0RMarkers.vars.globalMult) or 1))

  if marker.control.bgLayer then
    marker.control.bgLayer:SetHidden(false)
    marker.control.bgLayer:SetTexture(texture)

    local textureWidth = 1
    if marker.control.bgLayer.GetTextureFileDimensions then
      textureWidth = marker.control.bgLayer:GetTextureFileDimensions() or 1
    end

    if textureWidth == nil or textureWidth <= 1 then
      local fallbackTexture, fallbackColour = QDRH.GetM0RTextureFallback(texture)
      if fallbackTexture ~= nil then
        texture = fallbackTexture
        marker.bgTexture = fallbackTexture
        marker.colour = fallbackColour or marker.colour
        marker.control.bgLayer:SetTexture(fallbackTexture)
        if marker.control.bgLayer.GetTextureFileDimensions then
          textureWidth = marker.control.bgLayer:GetTextureFileDimensions() or 1
        end
      end
    end

    if textureWidth == nil or textureWidth <= 0 then
      textureWidth = 1
    end

    local layerScale = 100 * textureWidth
    marker.control.bgLayer:SetScale(layerScale)
    marker.control.bgLayer:SetTransformScale(1 / layerScale)
    marker.control.bgLayer:SetColor(marker.colour[1], marker.colour[2], marker.colour[3], marker.colour[4])
  end

  if marker.control.textLayer then
    marker.control.textLayer:SetText(marker.text)
    marker.control.textLayer:SetHidden(false)
    if marker.textScale ~= nil then
      marker.control.textLayer:SetScale(marker.textScale * ((M0RMarkers.vars and M0RMarkers.vars.fontScale) or 1))
    end
  end
end

function QDRH.SetM0RRenderSpace()
  if Set3DRenderSpaceToCurrentCamera ~= nil and M0RMarkersCameraToplevel ~= nil then
    Set3DRenderSpaceToCurrentCamera("M0RMarkersCameraToplevel")
  end
end

local M0R_RAID_HEAD_MARKER_SIZE = 1.6
local M0R_TEST_HEAD_MARKER_SIZE = 1.6

function QDRH.RefreshM0RTempMarker(markerKey, x, y, z, texture, colour, size, text, textScale)
  if markerKey == nil or M0RMarkers == nil or M0RMarkers.tempMarkers == nil then
    return false
  end

  if WorldPositionToGuiRender3DPosition == nil then
    return false
  end

  QDRH.SetM0RRenderSpace()
  local marker = M0RMarkers.tempMarkers[markerKey]
  if marker == nil then
    return false
  end

  QDRH.ApplyM0RMarkerVisual(marker, texture, colour, size, text, textScale)

  if marker.control == nil then
    M0RMarkers.createTemporaryGroupIcon(markerKey, x, y, z)
    marker = M0RMarkers.tempMarkers[markerKey]
    QDRH.ApplyM0RMarkerVisual(marker, texture, colour, size, text, textScale)
    return true
  end

  local gx, gy, gz = WorldPositionToGuiRender3DPosition(x, y, z)
  if gx == nil then
    return false
  end

  marker.control:SetTransformOffset(gx, gy, gz)
  if os ~= nil and os.rawclock ~= nil then
    marker.startTime = os.rawclock()
  end
  QDRH.ApplyM0RMarkerVisual(marker, texture, colour, size, text, textScale)
  return true
end

function QDRH.AddM0RHeadMarkerForDuration(unitTag, texture, durationMillisec)
  if not QDRH.ShouldShowConsoleHeadMarkers() then
    return false
  end

  if unitTag == nil or unitTag == "" or GetUnitRawWorldPosition == nil then
    return false
  end

  local markerTexture = QDRH.GetM0RHeadMarkerTexture(texture)
  if markerTexture == nil then
    return false
  end

  local markerKey = QDRH.name .. "M0RHeadMarker" .. unitTag

  M0RMarkers.tempMarkers[markerKey] = M0RMarkers.tempMarkers[markerKey] or {
    x = 0,
    y = 0,
    z = 0,
    bgTexture = markerTexture,
    colour = {1, 1, 1, 1},
    text = "",
    size = M0R_RAID_HEAD_MARKER_SIZE,
    textScale = 2,
  }

  local function getMarkerPosition()
    local _, px, py, pz = GetUnitRawWorldPosition(unitTag)
    if px == nil or py == nil or pz == nil then
      return nil, nil, nil
    end

    return px, py + 300, pz
  end

  local function updateMarker()
    local px, py, pz = getMarkerPosition()
    if px == nil then
      return false
    end

    return QDRH.RefreshM0RTempMarker(
      markerKey,
      px,
      py,
      pz,
      markerTexture,
      {1, 1, 1, 1},
      M0R_RAID_HEAD_MARKER_SIZE,
      tostring(GetUnitDisplayName(unitTag)) .. "\n\n",
      2)
  end

  local updateName = QDRH.name .. "M0RHeadMarkerUpdate" .. unitTag
  EVENT_MANAGER:UnregisterForUpdate(updateName)
  if not updateMarker() then
    return false
  end

  local endTime = GetGameTimeSeconds() + ((durationMillisec or 5000) / 1000)
  EVENT_MANAGER:RegisterForUpdate(updateName, 33, function()
    if GetGameTimeSeconds() >= endTime then
      EVENT_MANAGER:UnregisterForUpdate(updateName)
      local marker = M0RMarkers.tempMarkers[markerKey]
      if marker ~= nil and marker.startTime ~= nil and os ~= nil and os.rawclock ~= nil then
        marker.startTime = os.rawclock() - 5000
      end
      return
    end

    updateMarker()
  end)

  return true
end

function QDRH.AddM0RHeadMarkerForDurationDisplayName(displayName, texture, durationMillisec)
  local unitTag = QDRH.GetUnitTagForDisplayName(displayName)
  if unitTag == "" then
    return false
  end

  return QDRH.AddM0RHeadMarkerForDuration(unitTag, texture, durationMillisec)
end

function QDRH.RefreshM0RMarkerAtPosition(markerKey, x, y, z, texture, text, size, colour)
  if not QDRH.ShouldShowConsoleHeadMarkers() then
    return false
  end

  if markerKey == nil or x == nil or y == nil or z == nil then
    return false
  end

  if WorldPositionToGuiRender3DPosition == nil then
    return false
  end

  texture = texture or "M0RMarkers/textures/blank.dds"
  colour = colour or {1, 1, 1, 1}
  size = size or 0.8
  text = text or ""

  M0RMarkers.tempMarkers[markerKey] = M0RMarkers.tempMarkers[markerKey] or {
    x = 0,
    y = 0,
    z = 0,
    bgTexture = texture,
    colour = colour,
    text = text,
    size = size,
  }

  QDRH.SetM0RRenderSpace()
  local marker = M0RMarkers.tempMarkers[markerKey]
  QDRH.ApplyM0RMarkerVisual(marker, texture, colour, size, text)

  if marker.control == nil then
    M0RMarkers.createTemporaryGroupIcon(markerKey, x, y, z)
  else
    local gx, gy, gz = WorldPositionToGuiRender3DPosition(x, y, z)
    marker.control:SetTransformOffset(gx, gy, gz)
    if os ~= nil and os.rawclock ~= nil then
      marker.startTime = os.rawclock()
    end
  end

  marker = M0RMarkers.tempMarkers[markerKey]
  QDRH.ApplyM0RMarkerVisual(marker, texture, colour, size, text)
  return true
end

function QDRH.AddM0RMarkerAtPositionForDuration(markerKey, x, y, z, texture, text, durationMillisec, size, colour)
  if not QDRH.RefreshM0RMarkerAtPosition(markerKey, x, y, z, texture, text, size, colour) then
    return false
  end

  local updateName = QDRH.name .. "M0RWorldMarker" .. markerKey
  EVENT_MANAGER:UnregisterForUpdate(updateName)

  local endTime = GetGameTimeSeconds() + ((durationMillisec or 5000) / 1000)
  EVENT_MANAGER:RegisterForUpdate(updateName, 1000, function()
    if GetGameTimeSeconds() >= endTime then
      QDRH.HideM0RMarker(markerKey)
      return
    end

    QDRH.RefreshM0RMarkerAtPosition(markerKey, x, y, z, texture, text, size, colour)
  end)

  return true
end

function QDRH.HideM0RMarker(markerKey)
  EVENT_MANAGER:UnregisterForUpdate(QDRH.name .. "M0RWorldMarker" .. tostring(markerKey))

  if not QDRH.hasM0RMarkers() or markerKey == nil then
    return
  end

  local marker = M0RMarkers.tempMarkers[markerKey]
  if marker == nil then
    return
  end

  marker.startTime = nil
  marker.text = ""

  if marker.control then
    marker.control:SetHidden(true)
    if marker.control.bgLayer then
      marker.control.bgLayer:SetHidden(true)
    end
    if marker.control.textLayer then
      marker.control.textLayer:SetText("")
      marker.control.textLayer:SetHidden(true)
    end
  end
end

function QDRH.TestM0RMarker(markerType)
  if not QDRH.hasM0RMarkers() then
    d("[QDRH] M0RMarkers wurde nicht gefunden oder ist nicht geladen.")
    return
  end

  if GetUnitRawWorldPosition == nil then
    d("[QDRH] GetUnitRawWorldPosition ist nicht verfuegbar.")
    return
  end

  local _, x, y, z = GetUnitRawWorldPosition("player")
  if x == nil or y == nil or z == nil then
    d("[QDRH] Konnte deine Spielerposition nicht lesen.")
    return
  end

  local texture = "QcellDreadsailReefHelper/icons/firepin_console_v5.dds"
  local colour = {1, 1, 1, 1}
  if markerType == "ice" then
    texture = "QcellDreadsailReefHelper/icons/icepin_console_v5.dds"
    colour = {1, 1, 1, 1}
  elseif markerType == "chevron" then
    texture = "M0RMarkers/textures/chevron.dds"
    colour = {1, 1, 1, 1}
  end

  local markerKey = QDRH.name .. "M0RMarkerTest"

  M0RMarkers.tempMarkers[markerKey] = M0RMarkers.tempMarkers[markerKey] or {
    x = 0,
    y = 0,
    z = 0,
    bgTexture = texture,
    colour = colour,
    text = "",
    size = M0R_TEST_HEAD_MARKER_SIZE,
    textScale = 2,
  }

  local marker = M0RMarkers.tempMarkers[markerKey]
  QDRH.ApplyM0RMarkerVisual(
    marker,
    texture,
    colour,
    M0R_TEST_HEAD_MARKER_SIZE,
    tostring(GetUnitDisplayName("player")) .. "\n\n",
    2)

  local function getPlayerMarkerPosition()
    local _, px, py, pz = GetUnitRawWorldPosition("player")
    if px == nil or py == nil or pz == nil then
      return nil, nil, nil
    end

    return px, py + 300, pz
  end

  local function updateMarkerPosition()
    local px, py, pz = getPlayerMarkerPosition()
    if px == nil then
      return false
    end

    return QDRH.RefreshM0RTempMarker(
      markerKey,
      px,
      py,
      pz,
      texture,
      colour,
      M0R_TEST_HEAD_MARKER_SIZE,
      tostring(GetUnitDisplayName("player")) .. "\n\n",
      2)
  end

  local updateName = QDRH.name .. "M0RMarkerTestUpdate"
  EVENT_MANAGER:UnregisterForUpdate(updateName)
  local px, py, pz = getPlayerMarkerPosition()
  if px == nil then
    d("[QDRH] Konnte deine Spielerposition nicht lesen.")
    return
  end

  updateMarkerPosition()

  local endTime = GetGameTimeSeconds() + 5
  EVENT_MANAGER:RegisterForUpdate(updateName, 33, function()
    if GetGameTimeSeconds() >= endTime then
      EVENT_MANAGER:UnregisterForUpdate(updateName)
      if marker.startTime ~= nil and os ~= nil and os.rawclock ~= nil then
        marker.startTime = os.rawclock() - 5000
      end
      return
    end

    updateMarkerPosition()
  end)

  d("[QDRH] M0R " .. markerType .. " marker test auf " .. markerKey .. ": klebt 5s ueber deinem Kopf.")
end

function QDRH.AddIcon(unitTag, texture)
  QDRH.AddIconDisplayName(GetUnitDisplayName(unitTag), texture)
end

function QDRH.AddIconDisplayName(displayName, texture)
  if QDRH.hasOSI() and displayName ~= nil and displayName ~= "" then
    OSI.SetMechanicIconForUnit(string.lower(displayName), texture, 2 * OSI.GetIconSize())
  elseif displayName ~= nil and displayName ~= "" then
    QDRH.IconFallback("Marker: " .. displayName, 3000, SOUNDS.CHAMPION_POINTS_COMMITTED)
  end
end

function QDRH.AddIconForDuration(unitTag, texture, durationMillisec)
  if not QDRH.hasOSI() then
    if QDRH.AddM0RHeadMarkerForDuration(unitTag, texture, durationMillisec) then
      return
    end
    if unitTag ~= nil and unitTag ~= "" then
      QDRH.AddIcon(unitTag, texture)
    end
    return
  end
  QDRH.AddIcon(unitTag, texture)
  local name = QDRH.name .. "AddIconForDuration" .. unitTag
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    QDRH.RemoveIcon(unitTag)
    end )
end

function QDRH.AddGroundIconOnPlayerForDuration(unitTag, texture, durationMillisec)
  if not QDRH.hasOSI() then
    local displayName = GetUnitDisplayName(unitTag)
    if displayName ~= nil and displayName ~= "" then
      QDRH.IconFallback("Ground marker: " .. displayName, 3000, SOUNDS.CHAMPION_POINTS_COMMITTED)
    end
    return
  end
  local pworld, px, py, pz = GetUnitWorldPosition(unitTag)
  local name = QDRH.name .. "AddGroundIconOnPlayerForDuration" .. unitTag

  local icon = QDRH.AddGroundCustomIcon(px, py, pz, texture)
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    QDRH.DiscardPositionIconList({icon})
    end )
end

function QDRH.AddIconForDurationDisplayName(displayName, texture, durationMillisec)
  if not QDRH.hasOSI() or displayName == nil or displayName == "" then
    if QDRH.AddM0RHeadMarkerForDurationDisplayName(displayName, texture, durationMillisec) then
      return
    end
    if displayName ~= nil and displayName ~= "" then
      QDRH.IconFallback("Marker: " .. displayName, 3000, SOUNDS.CHAMPION_POINTS_COMMITTED)
    end
    return
  end
  QDRH.AddIconDisplayName(displayName, texture)
  local name = QDRH.name .. "AddIconForDurationDisplayName" .. displayName
  EVENT_MANAGER:RegisterForUpdate(name, durationMillisec, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    QDRH.RemoveIconDisplayName(displayName)
    end )
end

function QDRH.RemoveIcon(unitTag)
  QDRH.RemoveIconDisplayName(GetUnitDisplayName(unitTag))
end

function QDRH.RemoveIconDisplayName(displayName)
  if QDRH.hasOSI() and displayName ~= nil and displayName ~= "" then
    OSI.RemoveMechanicIconForUnit(string.lower(displayName))
  end
end

function QDRH.AddGroundIcon(x, y, z)
  if QDRH.hasOSI() then
      return OSI.CreatePositionIcon(x, y, z,
        "OdySupportIcons/icons/green_arrow.dds",
        2 * OSI.GetIconSize())
  end
  return nil
end

function QDRH.AddGroundCustomIcon(x, y, z, filePath)
  if QDRH.hasOSI() then
      return OSI.CreatePositionIcon(
        x, y, z,
        filePath,
        2 * OSI.GetIconSize())
  end
  return nil
end

function QDRH.DiscardPositionIconList(iconList)
  if iconList == nil or not QDRH.hasOSI() then
    return
  end
  for k, v in pairs(iconList) do
    if v ~= nil then
      OSI.DiscardPositionIcon(v)
    end
  end
  -- NOTE THIS WILL NOT UPDATE BY REFERENCE THE PASSED LIST.
  iconList = {}
end

function QDRH.ResetAllPlayerIcons()
  if QDRH.hasOSI() then
    OSI.ResetMechanicIcons()
  end
end

function QDRH.trimName(name)
  local NAME_TRIM_LENGTH = 20
  if name ~= nil then
    if string.len(name) > NAME_TRIM_LENGTH then
      return string.sub(name, 1, NAME_TRIM_LENGTH)
    else
      return name
    end
  end
  return ""
end

function QDRH.GetSecondsString(seconds)
  return string.format("%.0f", seconds) .. "s "
end

function QDRH.PlayLoudSound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
  PlaySound(sound)
end

function QDRH.ObnoxiousSound(sound, count)
  if count <= 0 or count == nil or count > 10 then
    return
  end
  QDRH.PlayLoudSound(sound)
  -- only one ObnoxiousSound at a time, thus unique name.
  local name = QDRH.name .. "ObnoxiousSound"
  EVENT_MANAGER:RegisterForUpdate(name, 1000, function() 
    EVENT_MANAGER:UnregisterForUpdate(name)
    QDRH.ObnoxiousSound(sound, count - 1)
    end )
end
