local wtb = WTBConduits
local EM = EVENT_MANAGER

local function GetNormalizedAngle(angle)
     return angle - 2 * math.pi * math.floor((angle + math.pi) / 2 * math.pi)
end

local function GetRotationAngle(targetUnitTag)
     local pX, pY = GetMapPlayerPosition("player")
     local tX, tY = GetMapPlayerPosition(targetUnitTag)
     return GetNormalizedAngle(-1 * (GetNormalizedAngle(GetPlayerCameraHeading()) - math.atan2(pX - tX, pY - tY)))
end

function wtb:InitializeArrow()
     wtbArrow = WINDOW_MANAGER:CreateControl(wtb.name .. "Arrow", RETICLE.control, CT_TEXTURE)
     wtbArrow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
     wtbArrow:SetDrawLayer(1)
     wtbArrow:SetDimensions(192, 192)
     wtbArrow:SetAlpha(1)
     wtbArrow:SetHidden(true)
end

function wtb:StyleArrow(texture, color, scale)
     wtbArrow:SetTexture(texture)
     wtbArrow:SetColor(unpack(color))
     wtbArrow:SetScale(scale)
end

function wtb:ShowArrow(targetUnitTag)
     if targetUnitTag then
          wtb:StyleArrow(wtb.name .. "/texture/arrow.dds", wtb.sv.arrowColor, wtb.sv.arrowScale)
          wtbArrow:SetHidden(false)
          EM:UnregisterForUpdate(wtb.name .. "ArrowUpdate")
          EM:RegisterForUpdate(wtb.name .. "ArrowUpdate", 30, function() wtbArrow:SetTextureRotation(GetRotationAngle(targetUnitTag)) end)
     else
          wtb.dbg("Group Member not found. Hiding Arrow")
     end
end

function wtb:HideArrow()
     EM:UnregisterForUpdate(wtb.name .. "ArrowUpdate")
     wtbArrow:SetHidden(true)
end
