local ItemConditionAlert = {}
ItemConditionAlert = _G["ItemConditionAlert"]
ItemConditionAlert.Menu = {}

local panelData = {
  type = "panel",
  name = "Item Condition Alert",
  displayName = "Item Condition Alert",
  author = "tridman",
  version = ItemConditionAlert.Version,
  registerForRefresh = true,
  registerForDefaults = true,
}


local optionsTable = {
--[[
Main Section
]]--  

  [1] = {
    type = "header",
    name = ItemConditionAlert.wordlist.SETTINGS_HDR_SHOW,
  },
  
  [2] = {
    type = "button",
    name = ItemConditionAlert.wordlist.SETTINGS_LBL_SHOW_BTN,
    tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_SHOW_BTN,
    func = function() ItemConditionAlert:Show() end
  },
  
  [3] = {
    type = "button",
    name = ItemConditionAlert.wordlist.SETTINGS_LBL_LOCK_BTN,
    tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_LOCK_BTN,
    func = function()
             if ItemConditionAlert.sv.Movable then
               ItemConditionAlert:DisableMove()
             else
               ItemConditionAlert:EnableMove()
             end
           end,
  },

--[[
General Section
]]--
  [4] = {
    type = "submenu",
    name = ItemConditionAlert.wordlist.SETTINGS_HDR_GENERAL,
    controls = {
    
      [1] = {
        type = "checkbox",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_SHOWPERC_CHK,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_SHOWPERC_CHK,
        getFunc = function() return ItemConditionAlert.sv.Percentage end,
        setFunc = function(value) ItemConditionAlert:TogglePercentage() end,
        default = ItemConditionAlert.SvDefaults.Percentage,
      },
      
      [2] = {
        type = "checkbox",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_THRESHOLD_CHK,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_THRESHOLD_CHK,
        getFunc = function() return ItemConditionAlert.sv.Nothreshold end,
        setFunc = function(value) ItemConditionAlert:ToggleThreshold() end,
        default = ItemConditionAlert.SvDefaults.Nothreshold,
      },
      
      [3] = {
        type = "dropdown",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_LAYOUT_DRP,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_LAYOUT_DRP,
        choices = ItemConditionAlert.layouts,
        getFunc = function() return ItemConditionAlert.sv.Layout end,
        setFunc = function(value) ItemConditionAlert:SetLayout(value) end,
        default = ItemConditionAlert.SvDefaults.Layout,
      },
      
      [4] = {
        type = "slider",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_SCALE_SLD,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_SCALE_SLD,
        min = 10,
        max = 100,
        step = 10,
        getFunc = function() return (ItemConditionAlert.sv.Scale * 100) end,
        setFunc = function(value) ItemConditionAlert:SetScale(value/100) end,
        default = ItemConditionAlert.SvDefaults.Scale * 100,
      },
      
      [5] = {
        type = "slider",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_ALPHA_SLD,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_ALPHA_SLD,
        min = 10,
        max = 100,
        step = 10,
        getFunc = function() return (ItemConditionAlert.sv.Alpha * 100) end,
        setFunc = function(value) ItemConditionAlert.sv.Alpha = value/100 end,
        default = ItemConditionAlert.SvDefaults.Alpha * 100,
      },
      
      [6] = {
        type = "slider",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_FADEALPHA_SLD,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_FADEALPHA_SLD,
        min = 10,
        max = 100,
        step = 10,
        getFunc = function() return (ItemConditionAlert.sv.FadedAlpha * 100) end,
        setFunc = function(value) ItemConditionAlert.sv.FadedAlpha = value/100 end,
        default = ItemConditionAlert.SvDefaults.FadedAlpha * 100,
      },
    },
  },

--[[
Threshold Section
]]--

  [5] = {
    type = "submenu",
    name = ItemConditionAlert.wordlist.SETTINGS_HDR_THRESHOLDS,
    tooltip = ItemConditionAlert.wordlist.SETTINGS_DCSR_THRESHOLDS,
    controls = {
    
      [1] = {
        type = "dropdown",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_VISIBTHESHOLD_DRP,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_VISIBTHRESHOLD_DRP,
        choices = ItemConditionAlert.ItemStates,
        getFunc = function() return ItemConditionAlert.sv.VisibilityThreshold end,
        setFunc = function(value) ItemConditionAlert:SetVisibilityThreshold(value) end,
        default = ItemConditionAlert.SvDefaults.VisibilityThreshold,
      },
      
      [2] = {
        type = "dropdown",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_WEAPONVISIBTHESHOLD_DRP,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_WEAPONVISIBTHRESHOLD_DRP,
        choices = ItemConditionAlert.ItemStates,
        getFunc = function() return ItemConditionAlert.sv.WeaponVisibThreshold end,
        setFunc = function(value) ItemConditionAlert:SetWeaponVisibThreshold(value) end,
        default = ItemConditionAlert.SvDefaults.WeaponVisibThreshold,
      },
      
      [3] = {
        type = "slider",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_OKTHESHOLD_SLD,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_OKTHESHOLD_SLD,
        min = 5,
        max = 95,
        step = 5,
        getFunc = function() return ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[2]][2] end,
        setFunc = function(value)
                    ItemConditionAlert.Menu:SetThreshold(value, ItemConditionAlert.ItemStates[2], false, 0)
                    if not (ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[1]][1] == ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[2]][2]) then
                      ItemConditionAlert.Menu:SetThreshold(value, ItemConditionAlert.ItemStates[1], true, 0)
                    end
                    ItemConditionAlert:Update()
                  end,
        default = ItemConditionAlert.SvDefaults.StateThresholds[ItemConditionAlert.ItemStates[2]][2],
      },
      
      [4] = {
        type = "slider",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_GOODTHESHOLD_SLD,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_GOODTHESHOLD_SLD,
        min = 5,
        max = 95,
        step = 5,
        getFunc = function() return ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[3]][2] end,
        setFunc = function(value)
                    ItemConditionAlert.Menu:SetThreshold(value, ItemConditionAlert.ItemStates[3], false, 0)
                    if not (ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[2]][1] == ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[3]][2]) then
                      ItemConditionAlert.Menu:SetThreshold(value, ItemConditionAlert.ItemStates[2], true, 0)
                    end
                    ItemConditionAlert:Update()
                  end,
        default = ItemConditionAlert.SvDefaults.StateThresholds[ItemConditionAlert.ItemStates[3]][2],
      },
      
      [5] = {
        type = "slider",
        name = ItemConditionAlert.wordlist.SETTINGS_LBL_MODTHESHOLD_SLD,
        tooltip = ItemConditionAlert.wordlist.SETTINGS_DSCR_MODTHESHOLD_SLD,
        min = 5,
        max = 95,
        step = 5,
        getFunc = function() return ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[4]][2] end,
        setFunc = function(value)
                    ItemConditionAlert.Menu:SetThreshold(value, ItemConditionAlert.ItemStates[4], false, 0)
                    if not (ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[3]][1] == ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[4]][2]) then
                      ItemConditionAlert.Menu:SetThreshold(value, ItemConditionAlert.ItemStates[3], true, 0)
                    end
                    ItemConditionAlert:Update()
                  end,
        default = ItemConditionAlert.SvDefaults.StateThresholds[ItemConditionAlert.ItemStates[4]][2],
      },
    },
  },  
}

function ItemConditionAlert.Menu:CreateOptions()

  local LAM = LibStub("LibAddonMenu-2.0")
  LAM:RegisterAddonPanel(ItemConditionAlert.Name .."_OptionsPanel", panelData)
  LAM:RegisterOptionControls(ItemConditionAlert.Name .."_OptionsPanel", optionsTable)

end


function ItemConditionAlert.Menu:SetThreshold(value, threshold, lowerbound, reclevel)
  local itemstate = 0
  local border = 0
  
  if reclevel > 10 then
    d(ItemConditionAlert.Name.. "-ERROR: Recursion Abborted!")
    return true
  end
  
  if lowerbound then border = 1 end
  if (not lowerbound) then border = 2 end
  
  
  if threshold == ItemConditionAlert.ItemStates[1] then itemstate = 1 end
  if threshold == ItemConditionAlert.ItemStates[2] then itemstate = 2 end
  if threshold == ItemConditionAlert.ItemStates[3] then itemstate = 3 end
  if threshold == ItemConditionAlert.ItemStates[4] then itemstate = 4 end
  
  ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[itemstate]][border] = value
  --d(ItemConditionAlert.Name.. ": Threshold " ..threshold .."(" ..itemstate ..") border " ..border .." set to: " ..value)
  
  if ((lowerbound) and (value >= ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[itemstate]][2])) then --upper border must be at least one greater than lower border
    self:SetThreshold(value+1, ItemConditionAlert.ItemStates[itemstate], false, reclevel+1)
  elseif ((not lowerbound) and (value <= ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[itemstate]][1])) then -- lower border must be at least one smaler than upper border
    self:SetThreshold(value-1, ItemConditionAlert.ItemStates[itemstate], true, reclevel+1)
  end
  
  if ((lowerbound) and (not (self:CheckThreshold(value, threshold, lowerbound)))) then -- lower border must be greater or equal to upper border of next lower range
    self:SetThreshold(value, ItemConditionAlert.ItemStates[itemstate+1], false, reclevel+1)
  elseif (not lowerbound) and (not (self:CheckThreshold(value, threshold, lowerbound))) then -- upper border must be smaler or equal to lower border of next higher range
    self:SetThreshold(value, ItemConditionAlert.ItemStates[itemstate-1], true, reclevel+1)
  end
end


function ItemConditionAlert.Menu:CheckThreshold(value, threshold, lowerbound)
  if ((threshold == ItemConditionAlert.ItemStates[1]) and lowerbound) then
    if (value >= ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[2]][2]) then return true
    else return false end
  elseif ((threshold == ItemConditionAlert.ItemStates[2]) and not lowerbound) then
    if (value <= ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[1]][1]) then return true
    else return false end
  elseif ((threshold == ItemConditionAlert.ItemStates[2]) and lowerbound) then
    if (value >= ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[3]][2]) then return true
    else return false end
  elseif ((threshold == ItemConditionAlert.ItemStates[3]) and not lowerbound) then
    if (value <= ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[2]][1]) then return true
    else return false end
  elseif ((threshold == ItemConditionAlert.ItemStates[3]) and lowerbound) then
    if (value >= ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[4]][2]) then return true
    else return false end
  elseif ((threshold == ItemConditionAlert.ItemStates[4]) and not lowerbound) then
    if (value <= ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[3]][1]) then return true
    else return false end
  elseif ((threshold == ItemConditionAlert.ItemStates[4]) and lowerbound) then
    if (value >= 1) then return true
    else return false end
  else
    d(ItemConditionAlert.Name.. "-ERROR: Invalid Threshold!")
    return false
  end
end
