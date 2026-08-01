--[[
Combat Indicator. See the LICENSE file for details

This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]--

if not PL_CombatIndicator then return end
local LAM = LibAddonMenu2
local L = PL_CombatIndicator.Strings

PL_CombatIndicator.Settings = {}
local S = PL_CombatIndicator.Settings
S.defaults = {
  ["enabled"] = true,
  ["enableDisguiseDanger"] = true,
  ["enableSmallUiTweaks"] = false,
  ["colorCombat"] =  { 0.8, 0, 0, 1 },
  ["colorNormal"] = { 1, 1, 1, 1 },
  ["colorDisguiseDanger"] = { 0.85, 0.72, 0, 1 }
}

-- AddOn settings panel data
local panelData = {
  type = "panel",
  name = L.settingsTitle,
  version = PL_CombatIndicator.version,
  author = "Crabby654",
  registerForRefresh = true,
}

-- AddOn settings option (controls) data
local optionData = {
  [1] = {
    type = "checkbox",
    name = L.settingCheckboxEnabled,
    tooltip = L.settingTooltipCheckboxEnabled,
    getFunc = function() return S.vars.enabled end,
    setFunc = function(value) 
      S.vars.enabled = value 
      if value then 
        PL_CombatIndicator.UpdateForCurrentStatus()
      else
        PL_CombatIndicator.SetCompassColor({1, 1, 1, 1})
      end
    end,
  },
  [2] = {
    type = "checkbox",
    name = L.settingCheckboxDisguiseEnabled,
    tooltip = L.settingTooltipCheckboxDisguiseEnabled,
    getFunc = function() return S.vars.enableDisguiseDanger end,
    setFunc = function(value) 
      S.vars.enableDisguiseDanger = value 
      PL_CombatIndicator.UpdateForCurrentStatus()
    end,
  },
  [3] = {
    type = "colorpicker",
    name = L.settingColorNormal,
    tooltip = L.settingTooltipColorNormal,
    getFunc = function() return unpack(S.vars.colorNormal) end,
    setFunc = function(r, g, b, a) 
      S.vars.colorNormal = {r, g, b, a} 
      PL_CombatIndicator.UpdateForCurrentStatus()
    end
  },
  [4] = {
    type = "colorpicker",
    name = L.settingColorCombat,
    tooltip = L.settingTooltipColorCombat,
    getFunc = function() return unpack(S.vars.colorCombat) end,
    setFunc = function(r, g, b, a)
      S.vars.colorCombat = {r, g, b, a}
      PL_CombatIndicator.UpdateForCurrentStatus()
    end
  },
  [5] = {
    type = "colorpicker",
    name = L.settingColorDisguiseDanger,
    tooltip = L.settingTooltipColorDisguiseDanger,
    getFunc = function() return unpack(S.vars.colorDisguiseDanger) end,
    setFunc = function(r, g, b, a)
      S.vars.colorDisguiseDanger = {r, g, b, a}
      PL_CombatIndicator.UpdateForCurrentStatus()
    end
  },
  [6] = {
    type = "checkbox",
    name = L.settingCheckboxOptimiseForSmallUI,
    tooltip = L.settingTooltipCheckboxOptimiseForSmallUI,
    getFunc = function() return S.vars.enableSmallUiTweaks end,
    setFunc = function(value) 
      S.vars.enableSmallUiTweaks = value 
      PL_CombatIndicator.UpdateForCurrentStatus()
    end,
  },
}

function PL_CombatIndicator.InitAddonMenu()
  LAM:RegisterAddonPanel("PL_CombatIndicatorPanel", panelData)  
  LAM:RegisterOptionControls("PL_CombatIndicatorPanel", optionData)
end
