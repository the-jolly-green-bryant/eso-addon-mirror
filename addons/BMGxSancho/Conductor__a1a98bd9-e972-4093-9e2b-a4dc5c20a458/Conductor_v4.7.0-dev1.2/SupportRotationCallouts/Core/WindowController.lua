local C = Conductor
local SRC = SupportRotationCallouts
C.WindowController = C.WindowController or {}
local Windows = C.WindowController

function Windows:Register(key, control, options)
    if not key or not control then return false end
    self.windows = self.windows or {}
    options = options or {}
    self.windows[key] = { control=control, options=options }
    local unlocked = not (SRC.saved and SRC.saved.windowsLocked == true)
    control:SetMouseEnabled(unlocked)
    control:SetMovable(unlocked)
    control:SetClampedToScreen(true)
    control:SetHandler("OnMoveStop", function(window)
        if not SRC.saved then return end
        local cx, cy = (GuiRoot:GetWidth() or 1920)/2, (GuiRoot:GetHeight() or 1080)/2
        SRC.saved.windowPositions = SRC.saved.windowPositions or {}
        SRC.saved.windowPositions[key] = {
            x = window:GetLeft() + (window:GetWidth() * (window:GetScale() or 1) / 2) - cx,
            y = window:GetTop() + (window:GetHeight() * (window:GetScale() or 1) / 2) - cy,
        }
    end)
    return true
end

function Windows:SetLocked(locked)
    SRC.saved.windowsLocked = locked == true
    for _, entry in pairs(self.windows or {}) do
        entry.control:SetMovable(not SRC.saved.windowsLocked)
        entry.control:SetMouseEnabled(not SRC.saved.windowsLocked)
    end
    if C.EventBus then C.EventBus:Publish("WINDOW_LOCK_CHANGED", { locked=SRC.saved.windowsLocked }) end
end
function Windows:IsLocked() return SRC.saved and SRC.saved.windowsLocked == true end
function Windows:Initialize() self.windows = self.windows or {}; self.initialized = true end
