
Verdant = Verdant or {}
Verdant.zenimax = Verdant.zenimax or {}
local Verdant = Verdant

Verdant.zenimax.ui = {}
local M = Verdant.zenimax.ui

M.WINDOW_MANAGER          = WINDOW_MANAGER
M.ZO_ObjectPool           = ZO_ObjectPool
M.CreateControlFromVirtual = CreateControlFromVirtual

local zos_PlaySound = PlaySound
M.PlaySound = function(id)
  local sv = Verdant.SavedVars
  if sv and sv.settings and sv.settings.sounds == false then return end
  return zos_PlaySound(id)
end

function M.tooltip(control, string_id, side)
  control:SetHandler("OnMouseEnter", function(self)
    ZO_Tooltips_ShowTextTooltip(self, side or BOTTOM, GetString(string_id))
  end)
  control:SetHandler("OnMouseExit", function()
    ZO_Tooltips_HideTextTooltip()
  end)
end
