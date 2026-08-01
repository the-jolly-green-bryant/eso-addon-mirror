local CAE = CrutchAlertsExtensions
local Crutch = CrutchAlerts


---------------------------------------------------------------------
local graveyard

local function RemoveGrave(graveKey)
    Draw.activeIcons[graveKey] = nil
    Draw.MaybeStopPolling()

    local realKey = tonumber(string.sub(graveKey, 6))
    graveyard:ReleaseObject(realKey)
end

-- returns key
local function CreateGrave(text)
    if (not graveyard) then
        graveyard = ZO_ControlPool:New("CrutchAlertsExtensionsGrave", CrutchAlertsSpace)
        graveyard:SetResetFunction(function(control)
            control:SetHidden(true)
        end)
    end

    local control, key = graveyard:AcquireObject()
    control:SetTransformNormalizedOriginPoint(0.5, 0.5)
    control:SetHidden(false)
    control:SetTransformScale(0.01)
    control:SetAnchor(CENTER, GuiRoot, CENTER)

    -- To not clash with normal keys when put in Draw.activeIcons together
    local graveKey = "Grave" .. key

    local _, x, y, z = GetUnitRawWorldPosition("player")
    text = text or "YOUR AD HERE"

    local label = control:GetNamedChild("Label")
    label:SetText(text)
    control:SetDimensions(2000, 2000)
    control:SetWidth(math.max(label:GetTextWidth() + 50, 300))
    local height = math.max(label:GetTextHeight() + 30, 60)
    control:SetHeight(height)

    local function UpdateFunc(icon)
        local _, x, y, z = GetUnitRawWorldPosition("player")
        icon:SetPosition(x, y, z)
    end

    Crutch.Drawing.CreateControlCommon(
        true, -- isSpace
        control,
        graveKey,
        "CrutchAlerts/assets/jetplane.dds", -- texture
        x, y, z,
        false, -- faceCamera
        pitch, yaw, roll,
        UpdateFunc,
        Crutch.Drawing.SetPosition,
        Crutch.Drawing.SetOrientation)

    return graveKey
end
CAE.CreateGrave = CreateGrave
-- /script CrutchAlertsExtensions.CreateGrave("asdf")
