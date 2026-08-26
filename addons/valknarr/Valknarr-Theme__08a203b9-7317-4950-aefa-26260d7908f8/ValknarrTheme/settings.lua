ValknarrThemeSettings = ValknarrThemeSettings or {}

local Settings = ValknarrThemeSettings
local Store = ValknarrThemeStore
local Format = ValknarrThemeFormat
local Log = ValknarrThemeLog
local PANEL_ID = "ValknarrThemeSettings"

local function ApplyLive()
    if ValknarrTheme and ValknarrTheme.Apply then
        ValknarrTheme:Apply()
    end
end

function Settings:TryLibAddonMenu()
    local lam = _G.LibAddonMenu2 or _G.LibAddonMenu
    if type(lam) ~= "table" then
        return false
    end
    if type(lam.RegisterAddonPanel) ~= "function" or type(lam.RegisterOptionControls) ~= "function" then
        return false
    end
    local function SetSettingsOpen(open)
        if open then
            _G.ValknarrThemeSettingsOpen = true
        else
            _G.ValknarrThemeSettingsOpen = nil
        end
        if ValknarrTheme and ValknarrTheme.SyncHudVisibility then
            ValknarrTheme:SyncHudVisibility()
        end
    end
    local panelOk = pcall(lam.RegisterAddonPanel, lam, PANEL_ID, {
        type = "panel",
        name = "Valknarr Theme",
        displayName = "Valknarr Theme",
        author = "valknarr",
        version = ValknarrThemeVersion or "0.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
        opened = function()
            SetSettingsOpen(true)
        end,
        closed = function()
            SetSettingsOpen(false)
        end,
    })
    if not panelOk then
        return false
    end
    local options = {
        {
            type = "dropdown",
            name = "Health / Magicka / Stamina",
            tooltip = "Clean is numbers on a solid bar. Nordic / Steel / Bronze stitch three tiles; fill shows through the transparent hole.",
            choices = { "Default (vanilla)", "Clean", "Nordic knot", "Steel bevel", "Bronze bevel" },
            choicesValues = { Format.THEME_DEFAULT, Format.THEME_CLEAN, Format.THEME_NORDIC, Format.THEME_STEEL, Format.THEME_BRONZE },
            getFunc = function()
                return Store:ThemeId()
            end,
            setFunc = function(value)
                Store:SetThemeId(value)
                _G.ValknarrThemeSettingsOpen = true
                ApplyLive()
            end,
            default = Format.THEME_CLEAN,
        },
        {
            type = "dropdown",
            name = "Werewolf meter",
            tooltip = "Named skins are one inverted-L plate: Ult in the bar, Fury as a dark-red fill behind the wolf.",
            choices = { "Vanilla", "Clean", "Nordic knot", "Steel bevel", "Bronze bevel" },
            choicesValues = { Format.WOLF_VANILLA, Format.WOLF_CLEAN, Format.WOLF_NORDIC, Format.WOLF_STEEL, Format.WOLF_BRONZE },
            getFunc = function()
                return Store:WolfId()
            end,
            setFunc = function(value)
                Store:SetWolfId(value)
                _G.ValknarrThemeSettingsOpen = true
                ApplyLive()
            end,
            default = Format.WOLF_CLEAN,
        },
        {
            type = "checkbox",
            name = "Show numbers on bars",
            tooltip = "Off hides H/M/S and Ult / Fury text. The fills still move.",
            getFunc = function()
                return Store:GetSetting("showBarText")
            end,
            setFunc = function(value)
                Store:SetSetting("showBarText", value)
                _G.ValknarrThemeSettingsOpen = true
                ApplyLive()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Preview HUD in this menu",
            tooltip = "Show Health / Magicka / Stamina here so you can judge skins and text. The map still hides them.",
            getFunc = function()
                return Store:GetSetting("previewInSettings")
            end,
            setFunc = function(value)
                Store:SetSetting("previewInSettings", value)
                if value then
                    _G.ValknarrThemeSettingsOpen = true
                end
                ApplyLive()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Show debug logs",
            tooltip = "Verbose [Theme] DBG lines in chat. /vtheme diag always prints a snapshot you can paste.",
            getFunc = function()
                return Store:GetSetting("showDebugLog")
            end,
            setFunc = function(value)
                Store:SetSetting("showDebugLog", value)
                if Log and Log.ApplyFromStore then
                    Log:ApplyFromStore(false)
                end
            end,
            default = false,
        },
    }
    local ok = pcall(lam.RegisterOptionControls, lam, PANEL_ID, options)
    return ok
end

function Settings:RegisterLibraries()
    local lam = self:TryLibAddonMenu()
    if Log then
        if lam then
            Log:Always("Theme also in Add-On Settings (LibAddonMenu)")
        else
            Log:Always("Theme: /vtheme hud clean|nordic|steel|bronze|default   /vtheme wolf clean|nordic|steel|bronze|vanilla")
        end
    end
end

function Settings:HandleSlash(args)
    local text = zo_strtrim and zo_strtrim(args or "") or tostring(args or "")
    text = string.lower(text)
    if text == "" or text == "status" then
        if Log then
            Log:Always(
                "hud=" .. Store:ThemeId()
                .. "  wolf=" .. Store:WolfId()
                .. "  text=" .. (Store:GetSetting("showBarText") and "on" or "off")
                .. "  preview=" .. (Store:GetSetting("previewInSettings") and "on" or "off")
                .. "  (/vtheme help)"
            )
        end
        return
    end
    if text == "help" then
        if Log then
            Log:Always("/vtheme                show hud + wolf skins")
            Log:Always("/vtheme hud default    native H/M/S")
            Log:Always("/vtheme hud clean      readable Valknarr bars")
            Log:Always("/vtheme hud nordic     Nordic knot frame")
            Log:Always("/vtheme hud steel      Steel bevel frame")
            Log:Always("/vtheme hud bronze     Bronze bevel frame")
            Log:Always("/vtheme wolf vanilla   native werewolf bar")
            Log:Always("/vtheme wolf clean     current Valknarr widget")
            Log:Always("/vtheme wolf nordic    Nordic knot plate")
            Log:Always("/vtheme wolf steel     Steel bevel plate")
            Log:Always("/vtheme wolf bronze    Bronze bevel plate")
            Log:Always("/vtheme default        hud default (alias)")
            Log:Always("/vtheme clean          hud clean (alias: valknarr)")
            Log:Always("/vtheme nordic|steel|bronze   hud shortcuts")
            Log:Always("/vtheme toggle         hud default <-> clean")
            Log:Always("/vtheme text on|off    show or hide numbers on the bars")
            Log:Always("/vtheme preview on|off show H/M/S while Theme settings are open")
            Log:Always("/vtheme diag           snapshot for bug reports (always prints)")
            Log:Always("/vtheme probe          bind wolf / square tile / 256x64 strip (twice)")
            Log:Always("/vtheme log on|off     verbose chat logging (saved)")
        end
        return
    end
    if text == "diag" then
        if ValknarrTheme and ValknarrTheme.Diagnose then
            ValknarrTheme:Diagnose()
        end
        return
    end
    if text == "probe" then
        if ValknarrThemeSkins and ValknarrThemeSkins.Probe then
            ValknarrThemeSkins.Probe()
        elseif Log then
            Log:Always("probe FAIL skins missing")
        end
        return
    end
    if text == "log on" or text == "logon" or text == "debug on" then
        Store:SetSetting("showDebugLog", true)
        if Log and Log.ApplyFromStore then
            Log:ApplyFromStore(false)
        end
        return
    end
    if text == "log off" or text == "logoff" or text == "debug off" then
        Store:SetSetting("showDebugLog", false)
        if Log and Log.ApplyFromStore then
            Log:ApplyFromStore(false)
        end
        return
    end
    if text == "toggle" then
        Store:Toggle()
        ApplyLive()
        return
    end
    if text == "text" or text == "numbers" or text == "text status" then
        if Log then
            Log:Always("bar text = " .. (Store:GetSetting("showBarText") and "on" or "off"))
        end
        return
    end
    if text == "text on" or text == "texton" or text == "numbers on" then
        Store:SetSetting("showBarText", true)
        ApplyLive()
        return
    end
    if text == "text off" or text == "textoff" or text == "numbers off" then
        Store:SetSetting("showBarText", false)
        ApplyLive()
        return
    end
    if text == "preview" or text == "preview status" then
        if Log then
            Log:Always("settings preview = " .. (Store:GetSetting("previewInSettings") and "on" or "off"))
        end
        return
    end
    if text == "preview on" or text == "previewon" then
        Store:SetSetting("previewInSettings", true)
        _G.ValknarrThemeSettingsOpen = true
        ApplyLive()
        return
    end
    if text == "preview off" or text == "previewoff" then
        Store:SetSetting("previewInSettings", false)
        ApplyLive()
        return
    end
    local hudSkin = string.match(text, "^hud%s+(%S+)$")
    if hudSkin then
        if hudSkin == "vanilla" or hudSkin == "native" or hudSkin == "off" then
            hudSkin = Format.THEME_DEFAULT
        end
        if hudSkin == "valknarr" then
            hudSkin = Format.THEME_CLEAN
        end
        Store:SetThemeId(hudSkin)
        ApplyLive()
        return
    end
    local wolfSkin = string.match(text, "^wolf%s+(%S+)$")
    if wolfSkin then
        if wolfSkin == "native" or wolfSkin == "off" or wolfSkin == "default" then
            wolfSkin = Format.WOLF_VANILLA
        end
        if wolfSkin == "valknarr" then
            wolfSkin = Format.WOLF_CLEAN
        end
        Store:SetWolfId(wolfSkin)
        ApplyLive()
        return
    end
    if text == "default" or text == "native" or text == "off" then
        Store:SetThemeId(Format.THEME_DEFAULT)
        ApplyLive()
        return
    end
    if text == "clean" or text == "valknarr" or text == "on" or text == "ours" then
        Store:SetThemeId(Format.THEME_CLEAN)
        ApplyLive()
        return
    end
    if text == "nordic" or text == "steel" or text == "bronze"
        or text == "metal" or text == "metal1" or text == "metal2" or text == "metal3" or text == "metal4"
        or text == "a" or text == "b" or text == "c" then
        Store:SetThemeId(text)
        ApplyLive()
        return
    end
    if Log then
        Log:Warn("Unknown /vtheme args. Try /vtheme help")
    end
end

return Settings
