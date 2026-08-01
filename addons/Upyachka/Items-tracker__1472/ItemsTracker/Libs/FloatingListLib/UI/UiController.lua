--Register with LibStub
local MAJOR, MINOR = "Up_UiController", 2
local LIB, _ = LibStub:NewLibrary(MAJOR, MINOR)
if not LIB then return end -- avoid double loading.

--- Used to initialize UI for ThiefHelper.

local UiTools = LibStub:GetLibrary("Up_UiTools")
local UiFactory = LibStub:GetLibrary("Up_UiFactory")

-- Creates instance of controller.
function LIB:new(settings, root)
    return ZO_Object.MultiSubclass({ Settings = settings, Root = root }, self)
end

-- Check that compass visible and follows by its state. Only if Info enabled.
function LIB:checkWindowVisibility()
    local visible
    if ZO_CompassFrame then
        visible = self.Settings.UI.Window.Enabled and not ZO_CompassFrame:IsHidden()
    else
        visible = self.Settings.UI.Window.Enabled
    end
    self.Root.UI.Window.Root:SetHidden(not visible)
    return visible
end

-- Creates UI and configures it with settings. Requires loaded settings.
function LIB:initializeUI()
    self.Root.UI = {}
    self.Root.UI.Window = {}
    local windowPadding = self.Settings.UI.Window.Padding
    self.Root.UI.Window = UiFactory.createPaddingWindow(self.Root.name .. "_Window", windowPadding, self.Settings.UI.Window.Background.Enabled)
    local windowRoot = self.Root.UI.Window.Root
    local position = self.Settings.UI.Window.Position
    windowRoot:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, position.OffsetX, position.OffsetY)
    UiTools.configureAsFloat(windowRoot, position)
    self.Settings.UI.Window.Enabled = true
    -- Sets widget to switch visibility depends on compass visibility.
    EVENT_MANAGER:RegisterForUpdate(windowRoot:GetName() .. "_VisibilityHandler", 100, function() self:checkWindowVisibility() end)
end

-- Toggles visibility of Info window.
function LIB:toggleWindow()
    self.Settings.UI.Window.Enabled = not self.Settings.UI.Window.Enabled;
    self:checkWindowVisibility()
end
