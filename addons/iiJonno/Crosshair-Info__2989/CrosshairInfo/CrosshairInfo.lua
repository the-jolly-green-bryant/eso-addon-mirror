CrosshairInfo = {
  name = "CrosshairInfo",
  version = "1.2",
  author = "|cff9beaJonno|r",
  color = "CFF9BEA",

  default = {
    showCPIcon = true,
    showRankIcon = true,
    showClassIcon = true,
    showRace = true,
    showCharacterName = true,
    showTitle = true,
    lowHp = 20000,
    highHp = 30000,
    nameColors = {
      ["low"] = "42f56c", --"42f56c",
      ["medium"] = "42C5F5", --"42C5F5",
      ["high"] = "F54293", --"F54293",006B04
    },
  },

  icons = {
    [1] = "/esoui/art/icons/class/class_dragonknight.dds",
    [2] = "/esoui/art/icons/class/class_sorcerer.dds",
    [3] = "/esoui/art/icons/class/class_nightblade.dds",
    [4] = "/esoui/art/icons/class/class_warden.dds",
    [5] = "/esoui/art/icons/class/class_necromancer.dds",
    [6] = "/esoui/art/icons/class/class_templar.dds",
    [117] = "/esoui/art/icons/class/class_arcanist.dds",
  },

  sv = nil,
  svVersion = 1,
  svName = "CrosshairInfoVars",
}

function CrosshairInfo.Colorize(text, color)
  if not color then color = CrosshairInfo.color end
  text = string.format('|c%s%s|r', color, text)
  return text
end

function CrosshairInfo.RgbToHex(rgb)
  local hexadecimal = ''

  for key, value in pairs(rgb) do
    local hex = ''
    while(value > 0)do
      local index = math.fmod(value, 16) + 1
      value = math.floor(value / 16)
      hex = string.sub('0123456789ABCDEF', index, index) .. hex
    end
    if(string.len(hex) == 0)then
      hex = '00'
    elseif(string.len(hex) == 1)then
      hex = '0' .. hex
    end
    hexadecimal = hexadecimal .. hex
  end

  return hexadecimal
end

function CrosshairInfo.HexToRgb(hex)
  return tonumber("0X"..hex:sub(1,2)), tonumber("0X"..hex:sub(3,4)), tonumber("0X"..hex:sub(5,6))
end

function CrosshairInfo:Initialize()
  EVENT_MANAGER:RegisterForEvent(CrosshairInfo.name, EVENT_RETICLE_TARGET_CHANGED, CrosshairInfo.TargetChange)
  EVENT_MANAGER:RegisterForEvent(CrosshairInfo.name, EVENT_PLAYER_ACTIVATED, CrosshairInfo.GetInfo)

  CrosshairInfo.sv = ZO_SavedVars:NewAccountWide(CrosshairInfo.svName, CrosshairInfo.svVersion, nil, CrosshairInfo.default)

  CrosshairInfo.CreateMenu()
end

function CrosshairInfo.OnAddOnLoaded(event, name)
  if name ~= CrosshairInfo.name then return end
  CrosshairInfo:Initialize()

  EVENT_MANAGER:UnregisterForEvent(CrosshairInfo.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(CrosshairInfo.name, EVENT_ADD_ON_LOADED, CrosshairInfo.OnAddOnLoaded)

function CrosshairInfo.CreateClassIcon()
  if (CrosshairInfo.ClassIcon) then
    CrosshairInfo.ClassIcon:SetHidden(true)
    return
  end

  CrosshairInfo.ClassIcon = WINDOW_MANAGER:CreateControl("CrosshairInfo_ClassIcon", ZO_TargetUnitFramereticleover, CT_TEXTURE)
  CrosshairInfo.ClassIcon:SetDimensions(32,32)
  CrosshairInfo.ClassIcon:SetAnchor(LEFT, ZO_TargetUnitFramereticleoverBgContainerBgLeft, CENTER, -48, 3)
  CrosshairInfo.ClassIcon:SetHidden(true)
end

function CrosshairInfo.GetColor(hp)
  if hp < CrosshairInfo.sv.lowHp then
    return CrosshairInfo.sv.nameColors["low"]
  elseif CrosshairInfo.sv.lowHp < hp and hp < CrosshairInfo.sv.highHp then
    return CrosshairInfo.sv.nameColors["medium"]
  else
    return CrosshairInfo.sv.nameColors["high"]
  end
end

function CrosshairInfo.TargetChange()
  if (not DoesUnitExist('reticleover')) then
    CrosshairInfo.ClassIcon:SetHidden(true)
    return
  end

  if (IsUnitPlayer('reticleover')) then
    -- Is champion level or not
    champion = GetUnitLevel('reticleover') == 50

    -- CP
    if champion then
      ZO_TargetUnitFramereticleoverChampionIcon:SetHidden(not CrosshairInfo.sv.showCPIcon)
    else
      ZO_TargetUnitFramereticleoverChampionIcon:SetHidden(true)
    end

    -- Race  Title  Charname
    ZO_TargetUnitFramereticleoverCaption:SetText(
    (CrosshairInfo.sv.showCharacterName and GetUnitName('reticleover') or "") ..
    ((CrosshairInfo.sv.showCharacterName and (CrosshairInfo.sv.showRace or (CrosshairInfo.sv.showTitle and GetUnitTitle('reticleover') ~= ""))) and " - " or "") ..
    (CrosshairInfo.sv.showRace and GetUnitRace('reticleover') or "") ..
    (CrosshairInfo.sv.showRace and (CrosshairInfo.sv.showTitle and GetUnitTitle('reticleover') ~= "") and  " - " or "") ..
    (CrosshairInfo.sv.showTitle and GetUnitTitle('reticleover') or ""))

    -- Rank
    ZO_TargetUnitFramereticleoverRankIcon:SetHidden(not CrosshairInfo.sv.showRankIcon)
    ZO_TargetUnitFramereticleoverRankIcon:ClearAnchors()
    ZO_TargetUnitFramereticleoverRankIcon:SetDimensions(32,32)
    ZO_TargetUnitFramereticleoverRankIcon:SetAnchor(RIGHT, ZO_TargetUnitFramereticleoverBgContainerBgRight, CENTER, 47, 3)

    -- Class
    CrosshairInfo.ClassIcon:SetHidden(not CrosshairInfo.sv.showClassIcon)
    CrosshairInfo.ClassIcon:SetTexture(CrosshairInfo.icons[GetUnitClassId('reticleover')])

    -- Name color
    if IsUnitAttackable('reticleover') then
      local hp, hpMax, effectiveMax = GetUnitPower('reticleover', POWERTYPE_HEALTH)
      local color = CrosshairInfo.GetColor(hpMax)
      ZO_TargetUnitFramereticleoverName:SetText(CrosshairInfo.Colorize(GetUnitDisplayName('reticleover'), color))
      ZO_TargetUnitFramereticleoverCaption:SetText(CrosshairInfo.Colorize(ZO_TargetUnitFramereticleoverCaption:GetText(),color))
      if champion then
        ZO_TargetUnitFramereticleoverLevel:SetText(CrosshairInfo.Colorize(GetUnitChampionPoints('reticleover'), color))
      else
        ZO_TargetUnitFramereticleoverLevel:SetText(CrosshairInfo.Colorize(GetUnitLevel('reticleover'), color))
      end
    end
  else
    if CrosshairInfo ~= nil and CrosshairInfo.ClassIcon ~= nil then CrosshairInfo.ClassIcon:SetHidden(true) end
  end
end

function CrosshairInfo.GetInfo()
  CrosshairInfo.CreateClassIcon()
  EVENT_MANAGER:UnregisterForEvent(CrosshairInfo.name, EVENT_PLAYER_ACTIVATED)
end

function CrosshairInfo.CreateMenu()
  local LAM2 = LibAddonMenu2

  local panelData = {
    type = "panel",
    name = CrosshairInfo.name,
    displayName = CrosshairInfo.name,
    author = CrosshairInfo.author,
    version = CrosshairInfo.version,
    slashCommand = "/" .. CrosshairInfo.name,
  }

  LAM2:RegisterAddonPanel(CrosshairInfo.name .. "Menu", panelData)

  local optionsTable = {
    {
      type = "header",
      name = "|cff9beaG|reneral",
    },
    {
      type = "description",
      title = nil,
      text = "Toggle what UI element you want to show",
      width = "full",
    },
    {
      type = "checkbox",
      name = "Show CP icon",
      tooltip = "Activate the CP icon",
      getFunc = function() return CrosshairInfo.sv.showCPIcon end,
      setFunc = function(value)
        CrosshairInfo.sv.showCPIcon = value
        ZO_TargetUnitFramereticleoverChampionIcon:SetHidden(value)
      end,
      width = "half",
    },
    {
      type = "checkbox",
      name = "Show rank icon",
      tooltip = "Activate the rank icon",
      getFunc = function() return CrosshairInfo.sv.showRankIcon end,
      setFunc = function(value)
        CrosshairInfo.sv.showRankIcon = value
        ZO_TargetUnitFramereticleoverRankIcon:SetHidden(value)
      end,
      width = "half",
    },
    {
      type = "checkbox",
      name = "Show class icon",
      tooltip = "Activate the class icon",
      getFunc = function() return CrosshairInfo.sv.showClassIcon end,
      setFunc = function(value)
        CrosshairInfo.sv.showClassIcon = value
        CrosshairInfo.ClassIcon:SetHidden(value)
      end,
      width = "half",
    },
    {
      type = "checkbox",
      name = "Show Race",
      tooltip = "Activate the Race Text",
      getFunc = function() return CrosshairInfo.sv.showRace end,
      setFunc = function(value)
        CrosshairInfo.sv.showRace = value
      end,
      width = "half",
    },
    {
      type = "checkbox",
      name = "Character Name",
      tooltip = "Activate the Character Name Text",
      getFunc = function() return CrosshairInfo.sv.showCharacterName end,
      setFunc = function(value)
        CrosshairInfo.sv.showCharacterName = value
      end,
      width = "half",
    },
    {
      type = "checkbox",
      name = "Show Title",
      tooltip = "Activate the Title Text",
      getFunc = function() return CrosshairInfo.sv.showTitle end,
      setFunc = function(value)
        CrosshairInfo.sv.showTitle = value
      end,
      width = "half",
    },
    {
      type = "header",
      name = "|cff9beaH|realth |cff9beaT|rhresholds",
    },
    {
      type = "description",
      title = nil,
      text = "Change the values used to color names",
      width = "full",
    },
    {
      type = "editbox",
      name = "Low HP",
      tooltip = "When someone is considered a chips",
      getFunc = function() return CrosshairInfo.sv.lowHp end,
      setFunc = function(value)
        if value ~= nil then CrosshairInfo.sv.lowHp = tonumber(value) end
      end,
      isMultiline = false,
      width = "full",
    },
    {
      type = "description",
      title = nil,
      text = "Medium is anywhere between low and high values",
      width = "full",
    },
    {
      type = "editbox",
      name = "High hp",
      tooltip = "When someone is considered a tank",
      getFunc = function() return CrosshairInfo.sv.highHp end,
      setFunc = function(value)
        if value ~= nil then CrosshairInfo.sv.highHp = tonumber(value) end
      end,
      isMultiline = false,
      width = "full",
    },
    {
      type = "header",
      name = "|cff9beaC|rolors",
    },
    {
      type = "description",
      title = nil,
      text = "Change the color of names",
      width = "full",
    },
    {
      type = "colorpicker",
      name = "Low HP Color",
      getFunc = function()
        r,g,b = CrosshairInfo.HexToRgb(CrosshairInfo.sv.nameColors["low"])
        return unpack({r/255,g/255,b/255,1})
      end,
      setFunc = function(r,g,b,a)
        CrosshairInfo.sv.nameColors["low"] = CrosshairInfo.RgbToHex({r*255,g*255,b*255})
      end,
      width = "full",
    },
    {
      type = "colorpicker",
      name = "Medium HP Color",
      getFunc = function()
        r,g,b = CrosshairInfo.HexToRgb(CrosshairInfo.sv.nameColors["medium"])
        return unpack({r/255,g/255,b/255,1})
      end,
      setFunc = function(r,g,b,a)
        CrosshairInfo.sv.nameColors["medium"] = CrosshairInfo.RgbToHex({r*255,g*255,b*255})
      end,
      width = "full",
    },
    {
      type = "colorpicker",
      name = "High HP Color",
      getFunc = function()
        r,g,b = CrosshairInfo.HexToRgb(CrosshairInfo.sv.nameColors["high"])
        return unpack({r/255,g/255,b/255,1})
      end,
      setFunc = function(r,g,b,a)
        CrosshairInfo.sv.nameColors["high"] = CrosshairInfo.RgbToHex({r*255,g*255,b*255})
      end,
      width = "full",
    },
  }

  LAM2:RegisterOptionControls(CrosshairInfo.name .. "Menu", optionsTable)
end
