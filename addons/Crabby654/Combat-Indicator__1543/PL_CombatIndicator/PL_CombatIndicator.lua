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
local S = PL_CombatIndicator.Settings

function PL_CombatIndicator.OnAddOnLoaded()
  S.vars = ZO_SavedVars:New(PL_CombatIndicator.name .. "Settings", PL_CombatIndicator.settingsVersion, nil, S.defaults, nil)
  setmetatable(S, { __index = S.vars })
  PL_CombatIndicator.InitAddonMenu()
end

function PL_CombatIndicator.OnPlayerActivated()
  PL_CombatIndicator.SetCombat(false)
end

function PL_CombatIndicator.OnPlayerCombatState(_, inCombat)
  if (not S.enabled) then return end
  PL_CombatIndicator.SetCombat(inCombat) 
end

function PL_CombatIndicator.OnPlayerDisguiseState(_, unitTag, disguiseState)
  if (unitTag ~= "player") then return end
  PL_CombatIndicator.UpdateForCurrentStatus()
end

function PL_CombatIndicator.OnPlayerDead()
  if (not S.enabled) then return end
  PL_CombatIndicator.SetCombat(false)
end

-- Update the bar based on the current combat and disguise state
function PL_CombatIndicator.UpdateForCurrentStatus()
  if S.enabled then 
    local inCombat = IsUnitInCombat("player")
    local disguiseState = S.enableDisguiseDanger and GetUnitDisguiseState("player") or DISGUISE_STATE_NONE
    PL_CombatIndicator.SetCombat(inCombat, disguiseState)
  end
end

function PL_CombatIndicator.SetCombat(inCombat, disguiseState)
  if not disguiseState then disguiseState = DISGUISE_STATE_NONE end
  local color = PL_CombatIndicator.GetColourForState(inCombat, disguiseState)
  PL_CombatIndicator.SetCompassColor(color)
  -- We can make some small optimisations to the inCombat indicator so it is clear at small UI sizes
  local alpha = PL_CombatIndicator.GetUIMungeAlphaForState(inCombat, disguiseState)
  ZO_CompassFrameCenterBottomMungeOverlay:SetAlpha(alpha)    
  ZO_CompassFrameCenterTopMungeOverlay:SetAlpha(alpha)    
  local desaturation = PL_CombatIndicator.GetUIMungeDesaturationForState(inCombat, disguiseState)
  ZO_CompassFrameCenter:SetDesaturation(desaturation)
  ZO_CompassFrameLeft:SetDesaturation(desaturation)
  ZO_CompassFrameRight:SetDesaturation(desaturation)
end

function PL_CombatIndicator.SetCompassColor(col)
  if not col then return end
  ZO_CompassFrameLeft:SetColor(col[1], col[2], col[3], col[4])
  ZO_CompassFrameCenter:SetColor(col[1], col[2], col[3], col[4])
  ZO_CompassFrameRight:SetColor(col[1], col[2], col[3], col[4])
  -- Also change the color of area indicators (normally green/blue)
  for i = 1,_G["ZO_CompassContainer"]:GetNumChildren() do
    local areaTexture = _G["ZO_CompassAreaTexture" .. i]
    if areaTexture then
      areaTexture.left:SetColor(col[1], col[2], col[3], col[4])
      areaTexture.center:SetColor(col[1], col[2], col[3], col[4])    
      areaTexture.right:SetColor(col[1], col[2], col[3], col[4])  
    end
  end
end

-- Get the color to use for a given combat/disguise pair
function PL_CombatIndicator.GetColourForState(inCombat, disguiseState)
  if inCombat then 
    return S.colorCombat 
  else
    return disguiseState == DISGUISE_STATE_DANGER and S.colorDisguiseDanger or S.colorNormal
  end
end

-- Get the alpha to use for small UI tweaks for a given combat/disguise pair
function PL_CombatIndicator.GetUIMungeAlphaForState(inCombat, disguiseState)
  if inCombat or disguiseState == DISGUISE_STATE_DANGER then return 0.4 else return 1 end
end

-- Get the desaturation to use for small UI tweaks for a given combat/disguise pair
function PL_CombatIndicator.GetUIMungeDesaturationForState(inCombat, disguiseState)
  if inCombat or disguiseState == DISGUISE_STATE_DANGER then 
    if S.enableSmallUiTweaks then 
      return -0.8 
    else 
      return -0.2
    end
  else
    return 0
  end
end

EVENT_MANAGER:RegisterForEvent(PL_CombatIndicator.name .. "OnPlayerActivated", EVENT_PLAYER_ACTIVATED, PL_CombatIndicator.OnPlayerActivated)
local id = PL_CombatIndicator.name .. "OnAddOnLoaded"
EVENT_MANAGER:RegisterForEvent(id, EVENT_ADD_ON_LOADED, function(_, name)
  if (name ~= PL_CombatIndicator.name) then return end 
  EVENT_MANAGER:UnregisterForEvent(id, EVENT_ADD_ON_LOADED)
  PL_CombatIndicator.OnAddOnLoaded()
end)
EVENT_MANAGER:RegisterForEvent(PL_CombatIndicator.name .. "OnPlayerCombatState", EVENT_PLAYER_COMBAT_STATE, PL_CombatIndicator.OnPlayerCombatState)
EVENT_MANAGER:RegisterForEvent(PL_CombatIndicator.name .. "OnPlayerCombatState", EVENT_PLAYER_DEAD, PL_CombatIndicator.OnPlayerDead)
EVENT_MANAGER:RegisterForEvent(PL_CombatIndicator.name .. "OnPlayerDisguiseState", EVENT_DISGUISE_STATE_CHANGED, PL_CombatIndicator.OnPlayerDisguiseState)
