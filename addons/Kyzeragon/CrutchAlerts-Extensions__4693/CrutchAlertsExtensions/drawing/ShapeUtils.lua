local CAE = CrutchAlertsExtensions
local Crutch = CrutchAlerts


local function CreateArc(angle, radius)
    angle = angle or math.pi / 3
    radius = radius or 7

    local composite = WINDOW_MANAGER:CreateControl("CAEArcTest", CrutchAlertsContainer, CT_TEXTURECOMPOSITE)
    composite:SetTexture("CrutchAlerts/assets/floor/circle.dds")
    local surface = composite:AddSurface(0, 1, 0, 1)
    -- SetInsets(*luaindex* _surfaceIndex_, *number* _left_, *number* _right_, *number* _top_, *number* _bottom_)
end
CAE.CreateArc = CreateArc
