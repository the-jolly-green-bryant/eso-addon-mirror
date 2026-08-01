local LAM2 = LibAddonMenu2

UseUltimateReminder = {
  name = "UseUltimateReminder",
  version = 5.3,

  default = {
    color = {0,1,1,1},
    text = "Ultimate ready",
    offsetX = 0,
    offsetY = -20,
    bar = "both",
    group = false,
    icon = true,
    fontSize = 30,
    iconSize = 30,
  },

  sv = nil,
  svVersion = 1,
  svName = "UseUltimateReminderVars",

  ultValue = 0,
  isMovable = false,
}

function UseUltimateReminder:Initialize()
  UseUltimateReminderIndicator:SetHidden(true)

  SLASH_COMMANDS["/ult"] = UseUltimateReminder.SlashCommand

  UseUltimateReminder.sv = ZO_SavedVars:NewAccountWide(UseUltimateReminder.svName, UseUltimateReminder.svVersion, nil, UseUltimateReminder.default)

  UseUltimateReminderIndicatorLabel:SetText(UseUltimateReminder.sv.text)
  UseUltimateReminderIndicatorLabel:SetColor(unpack(UseUltimateReminder.sv.color))
  UseUltimateReminder.SetFontSize(UseUltimateReminderIndicator, UseUltimateReminderIndicatorLabel, UseUltimateReminder.sv.fontSize)

  if UseUltimateReminder.sv.offsetX ~= 0 and UseUltimateReminder.sv.offsetY ~= -20 then
    UseUltimateReminderIndicator:ClearAnchors()
    UseUltimateReminderIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, UseUltimateReminder.sv.offsetX, UseUltimateReminder.sv.offsetY)
  end

  UseUltimateReminderIndicatorIcon:SetHidden(not UseUltimateReminder.sv.icon)
  UseUltimateReminderIndicatorIcon:SetDimensions(UseUltimateReminder.sv.iconSize, UseUltimateReminder.sv.iconSize)

  -- Default icon
  if UseUltimateReminder.sv.bar == "front" then
    UseUltimateReminderIndicatorIcon:SetTexture(GetAbilityIcon(GetSlotBoundId(8, nil, HOTBAR_CATEGORY_PRIMARY)))
  elseif UseUltimateReminder.sv.bar == "back" then
    UseUltimateReminderIndicatorIcon:SetTexture(GetAbilityIcon(GetSlotBoundId(8, nil, HOTBAR_CATEGORY_BACKUP)))
  else
    local activeWeaponPair = GetActiveWeaponPairInfo()
    if activeWeaponPair == 1 then
      UseUltimateReminderIndicatorIcon:SetTexture(GetAbilityIcon(GetSlotBoundId(8, nil, HOTBAR_CATEGORY_PRIMARY)))
    elseif activeWeaponPair == 2 then
      UseUltimateReminderIndicatorIcon:SetTexture(GetAbilityIcon(GetSlotBoundId(8, nil, HOTBAR_CATEGORY_BACKUP)))
    end
  end

  UseUltimateReminderIndicatorBackdrop:SetHidden(true)


  EVENT_MANAGER:RegisterForEvent(UseUltimateReminder.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, UseUltimateReminder.BarSwap)
  EVENT_MANAGER:RegisterForEvent(UseUltimateReminder.name, EVENT_PLAYER_COMBAT_STATE, UseUltimateReminder.OnCombatStateChange)

  UseUltimateReminder.CreateSettingsWindow()
end

function UseUltimateReminder.OnAddOnLoaded(_, name)
  if name == UseUltimateReminder.name then
    UseUltimateReminder:Initialize()
    EVENT_MANAGER:UnregisterForEvent(UseUltimateReminder.name, EVENT_ADD_ON_LOADED)
  end
end
EVENT_MANAGER:RegisterForEvent(UseUltimateReminder.name, EVENT_ADD_ON_LOADED, UseUltimateReminder.OnAddOnLoaded)

function UseUltimateReminder.SetFontSize(control, label, size)
  label:SetFont("$(BOLD_FONT)|" .. size .. "|soft-shadow-thick")
  --control:SetDimensions(label:GetStringWidth(label:GetText()), label:GetTextHeight())
  UseUltimateReminder.SetDimensions()
end

function UseUltimateReminder.SetDimensions()
  local stringWidth = UseUltimateReminderIndicatorLabel:GetStringWidth(UseUltimateReminderIndicatorLabel:GetText())
  local textWidth = UseUltimateReminderIndicatorLabel:GetTextWidth()
  UseUltimateReminderIndicator:SetDimensions(math.max(stringWidth, textWidth), UseUltimateReminderIndicatorLabel:GetTextHeight())
end

function UseUltimateReminder.CheckUltimate()
  if (UseUltimateReminder.sv.group and not IsUnitGrouped("player")) or (GetSlotAbilityCost(8) == 0 and UseUltimateReminder.sv.bar == "both") then
    UseUltimateReminderIndicator:SetHidden(true)
    return
  end

  current, max, effectiveMax = GetUnitPower("player", POWERTYPE_ULTIMATE)

  if UseUltimateReminder.ultValue ~= 0 then
    UseUltimateReminderIndicator:SetHidden(current <= UseUltimateReminder.ultValue)
  else
    UseUltimateReminderIndicator:SetHidden(current <= GetSlotAbilityCost(8))
  end
end

function UseUltimateReminder.BarSwap()
  local activeWeaponPair = GetActiveWeaponPairInfo()
  if activeWeaponPair == 1 and UseUltimateReminder.sv.bar == "front" then
    UseUltimateReminder.ultValue = GetSlotAbilityCost(8)
    UseUltimateReminderIndicatorIcon:SetTexture(GetAbilityIcon(GetSlotBoundId(8, nil, HOTBAR_CATEGORY_PRIMARY)))
  elseif activeWeaponPair == 2 and UseUltimateReminder.sv.bar == "back" then
    UseUltimateReminder.ultValue = GetSlotAbilityCost(8)
    UseUltimateReminderIndicatorIcon:SetTexture(GetAbilityIcon(GetSlotBoundId(8, nil, HOTBAR_CATEGORY_BACKUP)))
  elseif UseUltimateReminder.sv.bar == "both" then
    if activeWeaponPair == 1 then
      UseUltimateReminderIndicatorIcon:SetTexture(GetAbilityIcon(GetSlotBoundId(8, nil, HOTBAR_CATEGORY_PRIMARY)))
    elseif activeWeaponPair == 2 then
      UseUltimateReminderIndicatorIcon:SetTexture(GetAbilityIcon(GetSlotBoundId(8, nil, HOTBAR_CATEGORY_BACKUP)))
    end
  end
end

function UseUltimateReminder.OnCombatStateChange()
  inCombat = IsUnitInCombat('player')
  if inCombat then
    EVENT_MANAGER:RegisterForEvent("UseUltimateReminder", EVENT_POWER_UPDATE, UseUltimateReminder.CheckUltimate)
  else
    EVENT_MANAGER:UnregisterForEvent("UseUltimateReminder", EVENT_POWER_UPDATE)
    UseUltimateReminderIndicator:SetHidden(true)
  end
end

function UseUltimateReminder.SlashCommand(txt)
  if txt == "on" then
    EVENT_MANAGER:RegisterForEvent("UseUltimateReminder", EVENT_PLAYER_COMBAT_STATE, UseUltimateReminder.OnCombatStateChange)
    EVENT_MANAGER:RegisterForEvent("UseUltimateReminder", EVENT_POWER_UPDATE, UseUltimateReminder.CheckUltimate)
  else
    EVENT_MANAGER:UnregisterForEvent("UseUltimateReminder", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent("UseUltimateReminder", EVENT_POWER_UPDATE)
    UseUltimateReminderIndicator:SetHidden(true)
  end
end

function UseUltimateReminder.SaveLoc()
  UseUltimateReminder.sv.offsetX = UseUltimateReminderIndicator:GetLeft()
  UseUltimateReminder.sv.offsetY = UseUltimateReminderIndicator:GetTop()
end

-- Menu
function UseUltimateReminder.CreateSettingsWindow()
  local panelData = {
    type = "panel",
    name = "Use Ultimate Reminder",
    displayName = "Use Ultimate Reminder",
    author = "|c57fffcEymix|r",
    version = "|c57fffc5.3|r",
    slashCommand = "/ultmenu",
  }


  local optionsData = {
    {
      type = "header",
      name = "|c57fffcU|rse |c57fffcU|rltimate |c57fffcR|reminder |c57fffcS|rettings",
    },
    {
      type = "description",
      text = "Some settings to tweak the addon how you like it the most",
    },
    {
      type = "header",
      name = "|c57fffcMove the UI|r",
    },
    {
      type = "button",
      name = "Unlock",
      func = function(value)
        UseUltimateReminder.isMovable = not UseUltimateReminder.isMovable
        UseUltimateReminderIndicator:SetMovable(UseUltimateReminder.isMovable)
        if UseUltimateReminder.isMovable then
          UseUltimateReminderIndicatorBackdrop:SetHidden(false)
          UseUltimateReminderIndicator:SetHidden(false)
          value:SetText("Lock")
        else
          UseUltimateReminderIndicatorBackdrop:SetHidden(true)
          UseUltimateReminderIndicator:SetHidden(true)
          value:SetText("Unlock")
        end
      end,
      width = "full",
    },
    {
      type = "header",
      name = "|c57fffcDisplay|r",
    },
    {
      type = "description",
      title = nil,
      text = "|c57fffcT|rEXT |c57fffcO|rPTIONS",
      width = "full",
    },
    {
      type = "colorpicker",
      name = "Color of display",
      getFunc = function() return unpack(UseUltimateReminder.sv.color) end,
      setFunc = function(r,g,b,a)
        UseUltimateReminder.sv.color = {r, g, b, a}
        UseUltimateReminderIndicatorLabel:SetColor(r,g,b,a)
      end,
      width = "full",
    },
    {
      type = "slider",
      name = "Text size",
      getFunc = function() return UseUltimateReminder.sv.fontSize end,
      setFunc = function(value)
        UseUltimateReminder.sv.fontSize = value
        UseUltimateReminder.SetFontSize(UseUltimateReminderIndicator, UseUltimateReminderIndicatorLabel, value)
      end,
      min = 30,
      max = 72,
      step = 2,
      default = 30,
      width = "full",
    },
    {
      type = "editbox",
      name = "Text to display",
      getFunc = function() return UseUltimateReminder.sv.text end,
      setFunc = function(text)
        UseUltimateReminder.sv.text = text
        UseUltimateReminderIndicatorLabel:SetText(text)
        UseUltimateReminder.SetDimensions()
        --UseUltimateReminderIndicator:SetDimensions(UseUltimateReminderIndicatorLabel:GetStringWidth(UseUltimateReminderIndicatorLabel:GetText()), UseUltimateReminderIndicatorLabel:GetTextHeight())
      end,
      isMultiline = false,
      width = "full",
    },
    {
      type = "description",
      title = nil,
      text = "|c57fffcI|rCON  |c57fffcO|rPTIONS",
      width = "full",
    },
    {
      type = "checkbox",
      name = "Show icon",
      tooltip = "Check this to display the icon",
      getFunc = function() return UseUltimateReminder.sv.icon end,
      setFunc = function(value)
        UseUltimateReminder.sv.icon = value
        UseUltimateReminderIndicatorIcon:SetHidden(not value)
      end,
      width = "full",
    },
    {
      type = "slider",
      name = "Icon size",
      getFunc = function() return UseUltimateReminder.sv.iconSize end,
      setFunc = function(value)
        UseUltimateReminder.sv.iconSize = value
        UseUltimateReminderIndicatorIcon:SetDimensions(value, value)
      end,
      min = 30,
      max = 72,
      step = 2,
      default = 30,
      width = "full",
    },
    {
      type = "header",
      name = "|c57fffcOptions|r",
    },
    {
      type = "dropdown",
      name = "Bar to track the value of",
      choices = {"both", "front", "back"},
      getFunc = function() return UseUltimateReminder.sv.bar end,
      setFunc = function(value)
        UseUltimateReminder.sv.bar = value
      end,
      width = "full",
      warning = "Will MAYBE need to reload the UI and to barswap at least twice to work properly.",
    },
    {
      type = "checkbox",
      name = "Show only in group",
      tooltip = "Check this to only display the text when grouped",
      getFunc = function() return UseUltimateReminder.sv.group end,
      setFunc = function(value)
        UseUltimateReminder.sv.group = value
      end,
      width = "full",
    },
  }

  LAM2:RegisterAddonPanel("UseUltimateReminder" .. "Menu", panelData)
  LAM2:RegisterOptionControls("UseUltimateReminder" .. "Menu", optionsData)
end
