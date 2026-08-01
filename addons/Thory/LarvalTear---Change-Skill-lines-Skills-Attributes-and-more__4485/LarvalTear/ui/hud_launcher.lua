local Addon = LarvalTearMod
local LTM_UI = Addon.UI

local UI_HUD_LAUNCHER_WIDTH = 64
local UI_HUD_LAUNCHER_HEIGHT = 64
local UI_HUD_LAUNCHER_ICON_SIZE = 64
local UI_HUD_LAUNCHER_ICON_INSET = 0
local UI_HUD_LAUNCHER_ICON_TEXTURE = "/LarvalTear/assets/icon128.dds"

local function CreateHudLauncherBackdrop(parent, centerR, centerG, centerB, centerA, edgeR, edgeG, edgeB, edgeA)
    local control = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    control:SetCenterColor(centerR, centerG, centerB, centerA)
    control:SetEdgeColor(edgeR, edgeG, edgeB, edgeA)
    return control
end

local function AnchorHudLauncherToDefaultPosition(control)
    local settings = type(Addon) == "table" and type(Addon.GetHudLauncherSettings) == "function"
        and Addon:GetHudLauncherSettings(false)
        or nil
    if type(settings) == "table" and type(settings.left) == "number" and type(settings.top) == "number" then
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.left, settings.top)
        return
    end

    if ActionButton8
        and type(ActionButton8.GetTop) == "function"
        and type(ActionButton8.GetLeft) == "function"
        and type(ActionButton8.GetWidth) == "function"
    then
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ActionButton8:GetLeft() + ActionButton8:GetWidth() + 2, ActionButton8:GetTop() - 10)
        return
    end

    control:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24, 180)
end

local function GetHudLauncherSettings()
    if type(Addon) == "table" and type(Addon.GetHudLauncherSettings) == "function" then
        return Addon:GetHudLauncherSettings(false)
    end

    return {
        hidden = false,
        locked = false,
        left = nil,
        top = nil,
    }
end

local function SaveHudLauncherPosition(control)
    local settings = type(Addon) == "table" and type(Addon.GetHudLauncherSettings) == "function"
        and Addon:GetHudLauncherSettings(true)
        or nil
    if type(settings) ~= "table" then
        return
    end

    if type(control.GetLeft) == "function" and type(control.GetTop) == "function" then
        settings.left = control:GetLeft()
        settings.top = control:GetTop()
    end
end

local function TriggerHudLauncher()
    if type(Addon) == "table" and type(Addon.HandlePrimaryShortcut) == "function" then
        Addon:HandlePrimaryShortcut()
        return
    end

    if type(LTM_UI) == "table" and type(LTM_UI.ToggleMainWindow) == "function" then
        LTM_UI:ToggleMainWindow()
    end
end

local function CreateHudLauncher(ui)
    local self = ui
    if self.hudLauncher then
        return
    end

    local settings = GetHudLauncherSettings()
    local launcher = WINDOW_MANAGER:CreateTopLevelWindow("LTM_HudLauncher")
    launcher:SetDimensions(UI_HUD_LAUNCHER_WIDTH, UI_HUD_LAUNCHER_HEIGHT)
    if type(launcher.SetClampedToScreen) == "function" then
        launcher:SetClampedToScreen(true)
    end
    launcher:SetMouseEnabled(true)
    if type(launcher.SetMovable) == "function" then
        launcher:SetMovable(not settings.locked)
    end
    if type(launcher.SetDrawTier) == "function" then
        launcher:SetDrawTier(DT_MEDIUM)
    end
    if type(launcher.SetDrawLayer) == "function" then
        launcher:SetDrawLayer(DL_CONTROLS)
    end
    if type(launcher.SetDrawLevel) == "function" then
        launcher:SetDrawLevel(1)
    end
    launcher:SetHidden(true)
    AnchorHudLauncherToDefaultPosition(launcher)
    self.hudLauncher = launcher

    local background = CreateHudLauncherBackdrop(launcher, 0.03, 0.04, 0.05, 0.68, 1.0, 1.0, 1.0, 0.5)
    background:ClearAnchors()
    background:SetAnchorFill(launcher)
    self.hudLauncherBackground = background

    local icon = WINDOW_MANAGER:CreateControl(nil, launcher, CT_TEXTURE)
    icon:ClearAnchors()
    icon:SetAnchor(LEFT, launcher, LEFT, UI_HUD_LAUNCHER_ICON_INSET, 0)
    icon:SetDimensions(UI_HUD_LAUNCHER_ICON_SIZE, UI_HUD_LAUNCHER_ICON_SIZE)
    icon:SetTexture(UI_HUD_LAUNCHER_ICON_TEXTURE)
    icon:SetMouseEnabled(false)
    if type(icon.SetDrawLevel) == "function" then
        icon:SetDrawLevel(2)
    end
    self.hudLauncherIcon = icon

    local iconPlaceholder = WINDOW_MANAGER:CreateControl(nil, launcher, CT_LABEL)
    iconPlaceholder:ClearAnchors()
    iconPlaceholder:SetAnchor(CENTER, icon, CENTER, 0, 0)
    iconPlaceholder:SetFont("ZoFontGameSmall")
    iconPlaceholder:SetColor(0.72, 0.76, 0.80, 1.0)
    iconPlaceholder:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    iconPlaceholder:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    iconPlaceholder:SetText("64x64")
    iconPlaceholder:SetHidden(true)
    self.hudLauncherIconPlaceholder = iconPlaceholder

    launcher:SetHandler("OnMouseEnter", function()
        icon:SetAlpha(0.82)
    end)
    launcher:SetHandler("OnMouseExit", function()
        icon:SetAlpha(1.0)
    end)
    launcher:SetHandler("OnMouseUp", function(selfControl, mouseButton)
        if mouseButton == MOUSE_BUTTON_INDEX_LEFT and MouseIsOver(selfControl, 0, 0, 0, 0) then
            TriggerHudLauncher()
        end
    end)
    launcher:SetHandler("OnMoveStop", function(selfControl)
        SaveHudLauncherPosition(selfControl)
    end)

    local fragment = ZO_SimpleSceneFragment:New(launcher)
    fragment:SetConditional(function()
        local currentSettings = GetHudLauncherSettings()
        if currentSettings.hidden == true then
            return false
        end

        return type(IsUnitDead) ~= "function" or not IsUnitDead("player")
    end)
    self.hudLauncherFragment = fragment

    if HUD_SCENE and type(HUD_SCENE.AddFragment) == "function" then
        HUD_SCENE:AddFragment(fragment)
    end
    if HUD_UI_SCENE and type(HUD_UI_SCENE.AddFragment) == "function" then
        HUD_UI_SCENE:AddFragment(fragment)
    end

    if type(EVENT_MANAGER) == "table" and type(EVENT_MANAGER.RegisterForEvent) == "function" then
        EVENT_MANAGER:RegisterForEvent("LTM_UI_HudLauncherPlayerDead", EVENT_PLAYER_DEAD, function()
            LTM_UI:RefreshHudLauncher()
        end)
        EVENT_MANAGER:RegisterForEvent("LTM_UI_HudLauncherPlayerAlive", EVENT_PLAYER_ALIVE, function()
            LTM_UI:RefreshHudLauncher()
        end)
    end

    zo_callLater(function()
        LTM_UI:RefreshHudLauncher()
    end, 1)
end

function LTM_UI:RefreshHudLauncher()
    if self.hudLauncher == nil and self.initialized == true then
        CreateHudLauncher(self)
    end

    if self.hudLauncher and type(self.hudLauncher.SetMovable) == "function" then
        local settings = GetHudLauncherSettings()
        self.hudLauncher:SetMovable(settings.locked ~= true)
    end

    if self.hudLauncherFragment and type(self.hudLauncherFragment.Refresh) == "function" then
        self.hudLauncherFragment:Refresh()
    end
end
