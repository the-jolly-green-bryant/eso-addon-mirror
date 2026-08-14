ValknarrUIESettingsMenu = ValknarrUIESettingsMenu or {}

local Menu = ValknarrUIESettingsMenu
local Log = ValknarrUIELog
local Store = ValknarrUIELayoutStore
local Platform = ValknarrUIEPlatform
local PANEL_ID = "ValknarrUIESettings"

local OPTIONS = {
    {
        key = "openEditor",
        label = "Open editor",
        kind = "action",
        tip = "Same as typing /uiedit in chat",
    },
    {
        key = "invertStickY",
        label = "Invert stick up / down",
        tip = "Swap vertical stick direction while moving or resizing HUD elements",
    },
    {
        key = "invertStickX",
        label = "Invert stick left / right",
        tip = "Swap horizontal stick direction while moving or resizing HUD elements",
    },
    {
        key = "showDebugLog",
        label = "Show debug logs",
        tip = "Show verbose [UIE] DBG lines in chat and on the on-screen log panel. Off by default.",
    },
}

local function FlagLabel(on)
    if on then
        return "ON"
    end
    return "OFF"
end

function Menu:Create()
    if self.root or not WINDOW_MANAGER or not GuiRoot then
        return self.root ~= nil
    end

    local root = WINDOW_MANAGER:CreateControl("ValknarrUIESettingsRoot", GuiRoot, CT_CONTROL)
    if not root then
        return false
    end
    self.root = root
    pcall(root.SetAnchor, root, CENTER, GuiRoot, CENTER, 0, 0)
    pcall(root.SetDimensions, root, 720, 380)
    pcall(root.SetMouseEnabled, root, false)
    if Platform and Platform.NeverMovable then
        Platform:NeverMovable(root)
    end
    root:SetHidden(true)
    pcall(root.SetDrawLayer, root, DL_OVERLAY)
    pcall(root.SetDrawTier, root, DT_HIGH)

    local panel = WINDOW_MANAGER:CreateControl("ValknarrUIESettingsPanel", root, CT_BACKDROP)
    panel:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
    panel:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 0, 0)
    panel:SetCenterColor(0, 0, 0, 0.86)
    panel:SetEdgeColor(1, 0.75, 0.15, 1)
    panel:SetEdgeTexture(nil, 2, 2, 2, 0)
    panel:SetMouseEnabled(false)
    self.panel = panel

    local title = WINDOW_MANAGER:CreateControl("ValknarrUIESettingsTitle", panel, CT_LABEL)
    title:SetAnchor(TOP, panel, TOP, 0, 12)
    if Platform and Platform.SetPreferredFont then
        Platform:SetPreferredFont(title, "ZoFontGamepad34")
    else
        title:SetFont("ZoFontGamepad34")
    end
    title:SetColor(1, 0.85, 0.25, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetText("Valknarr UI")
    self.title = title

    local subtitle = WINDOW_MANAGER:CreateControl("ValknarrUIESettingsSub", panel, CT_LABEL)
    subtitle:SetAnchor(TOP, title, BOTTOM, 0, 4)
    subtitle:SetDimensions(680, 28)
    if Platform and Platform.SetPreferredFont then
        Platform:SetPreferredFont(subtitle, "ZoFontGamepad27")
    else
        subtitle:SetFont("ZoFontGamepad27")
    end
    subtitle:SetColor(0.82, 0.82, 0.82, 1)
    subtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    subtitle:SetText("A opens the editor or toggles a flag. B closes.")
    self.subtitle = subtitle

    self.rows = {}
    for index = 1, #OPTIONS do
        local row = WINDOW_MANAGER:CreateControl("ValknarrUIESettingsRow" .. index, panel, CT_LABEL)
        row:SetAnchor(TOPLEFT, panel, TOPLEFT, 28, 88 + ((index - 1) * 44))
        row:SetDimensions(664, 40)
        if Platform and Platform.SetPreferredFont then
            Platform:SetPreferredFont(row, "ZoFontGamepad27")
        else
            row:SetFont("ZoFontGamepad27")
        end
        self.rows[index] = row
    end

    local help = WINDOW_MANAGER:CreateControl("ValknarrUIESettingsHelp", panel, CT_LABEL)
    help:SetAnchor(BOTTOM, panel, BOTTOM, 0, -16)
    help:SetDimensions(680, 28)
    if Platform and Platform.SetPreferredFont then
        Platform:SetPreferredFont(help, "ZoFontGamepad27")
    else
        help:SetFont("ZoFontGamepad27")
    end
    help:SetColor(0.78, 0.78, 0.78, 1)
    help:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    help:SetText("If LibHarvens / LibAddonMenu is installed, these also appear in Add-On Settings")
    self.help = help
    return true
end

function Menu:Refresh()
    if not self.rows then
        return
    end
    for index = 1, #OPTIONS do
        local option = OPTIONS[index]
        local row = self.rows[index]
        local on = Store and Store.GetSetting and Store:GetSetting(option.key)
        local marker = (index == self.selected) and "> " or "  "
        if option.kind == "action" then
            row:SetText(marker .. option.label .. "     A")
        else
            row:SetText(marker .. option.label .. "     " .. FlagLabel(on))
        end
        if index == self.selected then
            row:SetColor(1, 0.85, 0.25, 1)
        elseif option.kind == "action" then
            row:SetColor(0.88, 0.88, 0.88, 1)
        elseif on then
            row:SetColor(0.45, 0.92, 0.45, 1)
        else
            row:SetColor(0.88, 0.88, 0.88, 1)
        end
    end
end

function Menu:MoveSelection(delta)
    local count = #OPTIONS
    self.selected = ((self.selected - 1 + delta) % count) + 1
    self:Refresh()
end

function Menu:RequestOpenEditor()
    self:Hide()
    local Editor = ValknarrUIEEditor
    if not Editor or type(Editor.Begin) ~= "function" then
        return
    end
    local function start()
        if Editor.active then
            return
        end
        Editor:Begin()
    end
    if SCENE_MANAGER and type(SCENE_MANAGER.Show) == "function" then
        pcall(SCENE_MANAGER.Show, SCENE_MANAGER, "hud")
    end
    if type(zo_callLater) == "function" then
        zo_callLater(start, 200)
    else
        start()
    end
end

function Menu:ToggleSelected()
    local option = OPTIONS[self.selected]
    if not option then
        return
    end
    if option.kind == "action" then
        if option.key == "openEditor" then
            self:RequestOpenEditor()
        end
        return
    end
    if not Store or not Store.ToggleSetting then
        return
    end
    local on = Store:ToggleSetting(option.key)
    if option.key == "showDebugLog" and Log and Log.ApplyFromStore then
        Log:ApplyFromStore(false)
    elseif Log then
        Log:Always(option.label .. " = " .. FlagLabel(on) .. " (applies immediately)")
    end
    self:Refresh()
end

function Menu:InstallKeybinds()
    if self.keybinds or not KEYBIND_STRIP or type(KEYBIND_STRIP.AddKeybindButtonGroup) ~= "function" then
        return
    end
    local function active()
        return Menu.active
    end
    self.keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER or KEYBIND_STRIP_ALIGN_LEFT or 1,
        {
            name = "Toggle",
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                Menu:ToggleSelected()
            end,
            enabled = active,
            order = 100,
        },
        {
            name = "Close",
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
                Menu:Hide()
            end,
            enabled = active,
            order = 101,
        },
        {
            name = "Up",
            keybind = "UI_SHORTCUT_UP",
            callback = function()
                Menu:MoveSelection(-1)
            end,
            enabled = active,
            order = 200,
        },
        {
            name = "Down",
            keybind = "UI_SHORTCUT_DOWN",
            callback = function()
                Menu:MoveSelection(1)
            end,
            enabled = active,
            order = 201,
        },
    }
    local ok, err = pcall(KEYBIND_STRIP.AddKeybindButtonGroup, KEYBIND_STRIP, self.keybinds)
    if not ok then
        self.keybinds = nil
        if Log then
            Log:Warn("Settings keybinds failed: " .. tostring(err))
        end
    elseif type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
        pcall(KEYBIND_STRIP.UpdateKeybindButtonGroup, KEYBIND_STRIP, self.keybinds)
    end
end

function Menu:RemoveKeybinds()
    if self.keybinds and KEYBIND_STRIP and type(KEYBIND_STRIP.RemoveKeybindButtonGroup) == "function" then
        pcall(KEYBIND_STRIP.RemoveKeybindButtonGroup, KEYBIND_STRIP, self.keybinds)
    end
    self.keybinds = nil
end

function Menu:Show()
    if self.active then
        self:Hide()
        return
    end
    if not self:Create() then
        if Log then
            Log:Warn("Could not create settings panel — use /uiedit invert")
        end
        return
    end
    self.selected = 1
    self.active = true
    local Editor = ValknarrUIEEditor
    if Editor and Editor.active and Editor.SuspendInput then
        Editor:SuspendInput()
        self.suspendedEditor = true
    end
    self.root:SetHidden(false)
    self:Refresh()
    self:InstallKeybinds()
    if Log then
        Log:Always("Settings: D-pad select, A toggle, B close. Stick invert applies immediately.")
    end
end

function Menu:Hide()
    if not self.active then
        return
    end
    self:RemoveKeybinds()
    if self.root then
        self.root:SetHidden(true)
    end
    self.active = false
    local Editor = ValknarrUIEEditor
    if self.suspendedEditor and Editor and Editor.active and Editor.ResumeInput then
        Editor:ResumeInput()
    end
    self.suspendedEditor = false
end

local function CheckboxSetting(option)
    return {
        key = option.key,
        label = option.label,
        tooltip = option.tip,
        get = function()
            return Store:GetSetting(option.key)
        end,
        set = function(value)
            Store:SetSetting(option.key, value)
            if option.key == "showDebugLog" and Log and Log.ApplyFromStore then
                Log:ApplyFromStore(false)
            end
            if Menu.active then
                Menu:Refresh()
            end
            if Log and option.key ~= "showDebugLog" then
                Log:Always(option.label .. " = " .. FlagLabel(value))
            end
        end,
    }
end

function Menu:TryLibHarvens()
    local lib = _G.LibHarvensAddonSettings or _G.LibVotansAddonSettings
    if type(lib) ~= "table" or type(lib.AddAddon) ~= "function" then
        return false
    end
    local ok, addon = pcall(lib.AddAddon, lib, "Valknarr UI")
    if not ok or not addon or type(addon.AddSetting) ~= "function" then
        if Log then
            Log:Debug("LibHarvens AddAddon failed: " .. tostring(addon))
        end
        return false
    end
    local checkboxType = lib.ST_CHECKBOX or lib.ST_CHECK or "checkbox"
    local buttonType = lib.ST_BUTTON or lib.ST_CLICK or "button"
    for index = 1, #OPTIONS do
        local option = OPTIONS[index]
        if option.kind == "action" then
            pcall(addon.AddSetting, addon, {
                type = buttonType,
                label = option.label,
                tooltip = option.tip,
                clickHandler = function()
                    Menu:RequestOpenEditor()
                end,
                callback = function()
                    Menu:RequestOpenEditor()
                end,
            })
        else
            local setting = CheckboxSetting(option)
            pcall(addon.AddSetting, addon, {
                type = checkboxType,
                label = setting.label,
                tooltip = setting.tooltip,
                getFunction = setting.get,
                setFunction = setting.set,
            })
        end
    end
    if Log then
        Log:Info("Registered settings with LibHarvensAddonSettings")
    end
    return true
end

function Menu:TryLibAddonMenu()
    local lam = _G.LibAddonMenu2 or _G.LibAddonMenu
    if type(lam) ~= "table" then
        return false
    end
    if type(lam.RegisterAddonPanel) ~= "function" or type(lam.RegisterOptionControls) ~= "function" then
        return false
    end
    local panelOk = pcall(lam.RegisterAddonPanel, lam, PANEL_ID, {
        type = "panel",
        name = "Valknarr UI",
        displayName = "Valknarr UI",
        author = "valknarr",
        version = ValknarrUIEVersion or "0.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    })
    if not panelOk then
        return false
    end
    -- One "Open editor" control only (no extra description that repeats it).
    local options = {
        {
            type = "button",
            name = "Open editor",
            tooltip = "Same as typing /uiedit. Closes Add-On Settings first.",
            func = function()
                Menu:RequestOpenEditor()
            end,
            width = "full",
        },
        {
            type = "header",
            name = "Stick",
        },
        {
            type = "description",
            text = "Controller flags for moving and resizing HUD pieces. Changes apply immediately.",
        },
    }
    for index = 1, #OPTIONS do
        local option = OPTIONS[index]
        if option.kind ~= "action" then
            local setting = CheckboxSetting(option)
            options[#options + 1] = {
                type = "checkbox",
                name = setting.label,
                tooltip = setting.tooltip,
                getFunc = setting.get,
                setFunc = setting.set,
                default = option.key == "invertStickY",
            }
        end
    end
    local ok = pcall(lam.RegisterOptionControls, lam, PANEL_ID, options)
    if ok and Log then
        Log:Info("Registered settings with LibAddonMenu")
    end
    return ok
end

function Menu:RegisterLibraries()
    local lam = self:TryLibAddonMenu()
    -- Prefer LibAddonMenu for Add-On Settings. Skip Harvens registration when
    -- LAM worked so "Open editor" is not listed twice.
    local harvens = false
    if not lam then
        harvens = self:TryLibHarvens()
    end
    if Log then
        if lam then
            Log:Always("Settings also in Add-On Settings (LibAddonMenu)")
        else
            Log:Warn("LibAddonMenu-2.0 missing — required by ## DependsOn (add-on should not load without it). Built-in: /uiedit settings.")
        end
        if harvens then
            Log:Info("Settings also registered with LibHarvensAddonSettings")
        end
    end
end

return Menu
