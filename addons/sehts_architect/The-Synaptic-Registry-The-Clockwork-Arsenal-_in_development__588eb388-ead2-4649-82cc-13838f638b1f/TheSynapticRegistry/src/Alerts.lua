local Addon = TheSynapticRegistry
local Alerts = {}

local HIDE_NAMESPACE = Addon.EventNamespace .. ".AlertHide"

Alerts.root = nil
Alerts.label = nil
Alerts.backdrop = nil

local function logInfo(...)
    if Addon.Log and Addon.Log.Info then
        Addon.Log.Info(...)
    end
end

local function hasMethod(owner, methodName)
    return owner ~= nil and type(owner[methodName]) == "function"
end

local function cancelScheduledHide()
    if hasMethod(EVENT_MANAGER, "UnregisterForUpdate") then
        EVENT_MANAGER:UnregisterForUpdate(HIDE_NAMESPACE)
    end
end

local function scheduleHide(durationMs)
    if not hasMethod(EVENT_MANAGER, "RegisterForUpdate") then
        return
    end

    cancelScheduledHide()
    EVENT_MANAGER:RegisterForUpdate(HIDE_NAMESPACE, durationMs, function()
        cancelScheduledHide()
        Alerts.Hide()
    end)
end

function Alerts.Initialize(control)
    Alerts.root = control

    if hasMethod(control, "GetNamedChild") then
        Alerts.label = control:GetNamedChild("Text")
        Alerts.backdrop = control:GetNamedChild("Backdrop")
    end

    if hasMethod(control, "SetDrawTier") and DT_HIGH ~= nil then
        control:SetDrawTier(DT_HIGH)
    end

    if hasMethod(control, "SetDrawLayer") and DL_OVERLAY ~= nil then
        control:SetDrawLayer(DL_OVERLAY)
    end

    if hasMethod(control, "SetDrawLevel") then
        control:SetDrawLevel(2000)
    end

    if hasMethod(control, "SetAlpha") then
        control:SetAlpha(1)
    end

    if Alerts.backdrop then
        if hasMethod(Alerts.backdrop, "SetDrawTier") and DT_HIGH ~= nil then
            Alerts.backdrop:SetDrawTier(DT_HIGH)
        end

        if hasMethod(Alerts.backdrop, "SetDrawLayer") and DL_OVERLAY ~= nil then
            Alerts.backdrop:SetDrawLayer(DL_OVERLAY)
        end

        if hasMethod(Alerts.backdrop, "SetDrawLevel") then
            Alerts.backdrop:SetDrawLevel(1999)
        end

        if hasMethod(Alerts.backdrop, "SetAlpha") then
            Alerts.backdrop:SetAlpha(0.72)
        end
    end

    if Alerts.label then
        if hasMethod(Alerts.label, "SetDrawTier") and DT_HIGH ~= nil then
            Alerts.label:SetDrawTier(DT_HIGH)
        end

        if hasMethod(Alerts.label, "SetDrawLayer") and DL_OVERLAY ~= nil then
            Alerts.label:SetDrawLayer(DL_OVERLAY)
        end

        if hasMethod(Alerts.label, "SetDrawLevel") then
            Alerts.label:SetDrawLevel(2001)
        end

        if hasMethod(Alerts.label, "SetAlpha") then
            Alerts.label:SetAlpha(1)
        end
    end
end




function Alerts.Show(text, durationMs, color)
    if Alerts.root and Alerts.label and hasMethod(Alerts.label, "SetText") then
        Alerts.label:SetText(text)

        if type(color) == "table" and hasMethod(Alerts.label, "SetColor") then
            Alerts.label:SetColor(color[1], color[2], color[3], 1)
        end

        if hasMethod(Alerts.root, "SetHidden") then
            Alerts.root:SetHidden(false)
        end

        cancelScheduledHide()

        if type(durationMs) == "number" and durationMs > 0 then
            scheduleHide(durationMs)
        end

        return
    end

    logInfo(text)
end

function Alerts.Hide()
    cancelScheduledHide()

    if Alerts.root and hasMethod(Alerts.root, "SetHidden") then
        Alerts.root:SetHidden(true)
    end
end

Addon.Alerts = Alerts
