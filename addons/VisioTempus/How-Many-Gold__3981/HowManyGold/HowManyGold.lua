local LAM = LibAddonMenu2

local HMG = {
  name = "HowManyGold",
  settingsPanelName = "How Many Gold",
  version = "1.0.1",
  author = "VisioTempus",
  total_gold = 0,
  last_reset = "-",
  loss_matter = true,
  guild_bank_matter = true,
  savedVariables = {},
}

function HMG.RestorePosition()
  local left = HMG.savedVariables.left
  local top = HMG.savedVariables.top
 
  HowManyGoldControl:ClearAnchors()
  HowManyGoldControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function HMG.InitSettings()

  if HMG.savedVariables.settings == nil then HMG.savedVariables.settings = {} end

  if HMG.savedVariables.settings.tooltipPosition == nil then
    HMG.savedVariables.settings.tooltipPosition = GetString(HOWMANYGOLD_TOOLTIP_POS_TOP)
  end
  
  if HMG.savedVariables.settings.guildBankCashFlowEnabled == nil then
    HMG.savedVariables.settings.guildBankCashFlowEnabled = true
  end
  
end

function HMG.Initialize()

  HMG.total_gold = 0

  --Register for Money Update event
  --Anytime the gold amount changes, update it
  EVENT_MANAGER:RegisterForEvent(HMG.name, EVENT_MONEY_UPDATE, HMG.updateGold)

  HMG.savedVariables = ZO_SavedVars:NewAccountWide("HMGSavedVariables", 1, nil, {})
  
  HowManyGoldControlReset:SetHandler("OnClicked", HMG.ResetGoldAmount)

  HowManyGoldControl:SetHandler("OnMoveStop", function(control)
    HMG.savedVariables.left = HowManyGoldControl:GetLeft()
    HMG.savedVariables.top = HowManyGoldControl:GetTop()
  end)
  
  if HMG.savedVariables.amount then
    HMG.total_gold = HMG.savedVariables.amount
    HowManyGoldControlLabel:SetText(string.format(GetString(HOWMANYGOLD_GOLD_EARNED), HMG.getTotalGoldString()))
  end
  
  if HMG.savedVariables.last_reset then
    HMG.last_reset = HMG.savedVariables.last_reset
  end
  
  HMG.InitSettings()

  -- Visibility = Hide : 0, Visible : 1
  HowManyGoldControl:SetHidden(HMG.savedVariables.visibility == 1)
 
  HMG.RestorePosition()
  HMG.ChangeSettingsTooltipPosition()
  
  -- Visibility = Hide : 0, Visible : 1
  local lsc = LibSlashCommander
  if lsc then
    local cmd = lsc:Register("/hmg"
    , function() HowManyGoldControl:SetHidden(not HowManyGoldControl:IsHidden()) end
    , "Temporarly show/hide window")

    local sub_hide = cmd:RegisterSubCommand()
    sub_hide:AddAlias("hide")
    sub_hide:SetCallback(function() 
      HowManyGoldControl:SetHidden(true)
      HMG.savedVariables.visibility = 0
    end)
    sub_hide:SetDescription("Hide window")
    
    local sub_show = cmd:RegisterSubCommand()
    sub_show:AddAlias("show")
    sub_show:SetCallback(function() 
      HowManyGoldControl:SetHidden(false)
      HMG.savedVariables.visibility = 1
    end)
    sub_show:SetDescription("Show window")

    local sub_reset = cmd:RegisterSubCommand()
    sub_reset:AddAlias("reset")
    sub_reset:SetCallback(function()
      HMG.ResetGoldAmount()
    end)
    sub_reset:SetDescription("Reset gold session to 0")
  else
  
    SLASH_COMMANDS["/hmg"] = function(input)
      local cmd = input:match("(.-)$")
      if(cmd and cmd ~= "") then
        if cmd == "show" then
          HowManyGoldControl:SetHidden(false)
          HMG.savedVariables.visibility = 1
        elseif cmd == "hide" then
          HowManyGoldControl:SetHidden(true)
          HMG.savedVariables.visibility = 0
        elseif cmd == "reset" then
          HMG.ResetGoldAmount()
        end
      else
        HowManyGoldControl:SetHidden(not HowManyGoldControl:IsHidden())
      end
    end
	  
  end
  
  -- Settings panel
  local panelData = { type = "panel", name = HMG.settingsPanelName }
  
  local optionsData = {
    [1] = {
      type = "dropdown",
      name = GetString(HOWMANYGOLD_MENU_TOOLTIP_POS_NAME),
      tooltip = GetString(HOWMANYGOLD_MENU_TOOLTIP_POS_TOOLTIP),
      choices = {
        GetString(HOWMANYGOLD_TOOLTIP_POS_TOP),
        GetString(HOWMANYGOLD_TOOLTIP_POS_BOTTOM),
        GetString(HOWMANYGOLD_TOOLTIP_POS_LEFT),
        GetString(HOWMANYGOLD_TOOLTIP_POS_RIGHT)
      },
      getFunc = function() return HMG.savedVariables.settings.tooltipPosition end,
      setFunc = function(var) 
        HMG.savedVariables.settings.tooltipPosition = var
        HMG.ChangeSettingsTooltipPosition()
      end,
    },
    [2] = {
      type = "checkbox",
      name = GetString(HOWMANYGOLD_MENU_GUILD_BANK_FLOW_NAME),
      tooltip = GetString(HOWMANYGOLD_MENU_GUILD_BANK_FLOW_TOOLTIP),
      getFunc = function() return HMG.savedVariables.settings.guildBankCashFlowEnabled end,
      setFunc = function(var)
        HMG.savedVariables.settings.guildBankCashFlowEnabled = var
      end,
    }
  }
  
  LAM:RegisterAddonPanel(HMG.settingsPanelName, panelData)
  LAM:RegisterOptionControls(HMG.settingsPanelName, optionsData)

end

function HMG.getTotalGoldString()

  local amout_formatted = HMG.total_gold
  local k
  while true do  
    amout_formatted, k = string.gsub(amout_formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end

  if HMG.total_gold < 0 then
    return string.format("|cFF0000%s|r", amout_formatted)
  else
    return string.format("%s", amout_formatted)
  end

end

function HMG.updateGold(eventCode, newGold, oldGold, reason)

  local diff = 0
  local loss = false

  if (newGold == nil or oldGold == nil or reason == nil) then
    return
  end
  
  -- If reason is putting/retrieving money from bank don't do anything.
  if (reason == 42 or reason == 43) then
    return
  end
  
  -- If reason is putting/retrieving money from guild bank don't do anything if settings is set to false.
  if HMG.savedVariables.settings.guildBankCashFlowEnabled == false and (reason == 51 or reason == 52) then
    return
  end
  
  if newGold > oldGold then
    diff = newGold - oldGold
    loss = false
  elseif newGold < oldGold then
    diff = oldGold - newGold 
    loss = true
  else
    return
  end

  if (loss == true and HMG.loss_matter == true) then
    HMG.total_gold = HMG.total_gold - diff
  else
    HMG.total_gold = HMG.total_gold + diff
  end

  HMG.savedVariables.amount = HMG.total_gold
  HowManyGoldControlLabel:SetText(string.format(GetString(HOWMANYGOLD_GOLD_EARNED), HMG.getTotalGoldString()))

end

function HMG.ResetGoldAmount()
  HMG.total_gold = 0
  HowManyGoldControlLabel:SetText(string.format(GetString(HOWMANYGOLD_GOLD_EARNED), HMG.getTotalGoldString()))
  HMG.savedVariables.amount = 0
  
  HMG.last_reset = os.date("%Y-%m-%d %H:%M")
  HMG.savedVariables.last_reset = os.date("%Y-%m-%d %H:%M")
end

function HMG.ChangeSettingsTooltipPosition()

  if HMG.savedVariables.settings == nil then settingTooltipPosition = TOP end

  local settingTooltipPosition
  if HMG.savedVariables.settings.tooltipPosition == GetString(HOWMANYGOLD_TOOLTIP_POS_TOP) then
    settingTooltipPosition = TOP
  elseif HMG.savedVariables.settings.tooltipPosition == GetString(HOWMANYGOLD_TOOLTIP_POS_BOTTOM) then
    settingTooltipPosition = BOTTOM
  elseif HMG.savedVariables.settings.tooltipPosition == GetString(HOWMANYGOLD_TOOLTIP_POS_RIGHT) then
    settingTooltipPosition = RIGHT
  elseif HMG.savedVariables.settings.tooltipPosition == GetString(HOWMANYGOLD_TOOLTIP_POS_LEFT) then
    settingTooltipPosition = LEFT
  end
  
  HowManyGoldControl:SetHandler("OnMouseEnter", 
    function(HowManyGoldControlHowManyGoldControl) 
      ZO_Tooltips_ShowTextTooltip(HowManyGoldControl, settingTooltipPosition, GetString(HOWMANYGOLD_LAST_RESET) .. HMG.last_reset) 
    end)
  HowManyGoldControl:SetHandler("OnMouseExit", function(HowManyGoldControl) ZO_Tooltips_HideTextTooltip() end )
  
end

 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function HMG.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == HMG.name then
    HMG.Initialize()
    --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
    EVENT_MANAGER:UnregisterForEvent(HMG.name, EVENT_ADD_ON_LOADED)    
  end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
-->This event EVENT_ADD_ON_LOADED will be called for EACH of the addns/libraries enabled, this is why there needs to be a check against the addon name within your callback function! Else the very first addon loaded would run your code + all following addons too.
EVENT_MANAGER:RegisterForEvent(HMG.name, EVENT_ADD_ON_LOADED, HMG.OnAddOnLoaded)