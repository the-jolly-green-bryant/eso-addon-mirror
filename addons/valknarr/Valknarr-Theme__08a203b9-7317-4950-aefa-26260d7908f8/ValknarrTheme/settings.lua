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
    local panelOk = pcall(lam.RegisterAddonPanel, lam, PANEL_ID, {
        type = "panel",
        name = "Valknarr Theme",
        displayName = "Valknarr Theme",
        author = "valknarr",
        version = ValknarrThemeVersion or "0.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    })
    if not panelOk then
        return false
    end
    local options = {
        {
            type = "dropdown",
            name = "Health / Magicka / Stamina",
            tooltip = "Clean is numbers on a solid bar. Metal stitches three painted tiles and draws the fill in the joined hole.",
            choices = { "Default (vanilla)", "Clean", "Metal" },
            choicesValues = { Format.THEME_DEFAULT, Format.THEME_CLEAN, Format.THEME_METAL },
            getFunc = function()
                return Store:ThemeId()
            end,
            setFunc = function(value)
                Store:SetThemeId(value)
                ApplyLive()
            end,
            default = Format.THEME_CLEAN,
        },
        {
            type = "dropdown",
            name = "Werewolf meter",
            tooltip = "Wolf 1 Nordic, 2 snarling + spikes, 3 steel, 4 snarling + Nordic ring.",
            choices = { "Vanilla", "Clean", "Wolf 1 (Nordic)", "Wolf 2 (snarl)", "Wolf 3 (steel)", "Wolf 4 (snarl+Nordic)" },
            choicesValues = { Format.WOLF_VANILLA, Format.WOLF_CLEAN, Format.WOLF_1, Format.WOLF_2, Format.WOLF_3, Format.WOLF_4 },
            getFunc = function()
                return Store:WolfId()
            end,
            setFunc = function(value)
                Store:SetWolfId(value)
                ApplyLive()
            end,
            default = Format.WOLF_CLEAN,
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
            Log:Always("Theme: /vtheme hud clean|metal|default   /vtheme wolf clean|wolf1-4|vanilla")
        end
    end
end

function Settings:HandleSlash(args)
    local text = zo_strtrim and zo_strtrim(args or "") or tostring(args or "")
    text = string.lower(text)
    if text == "" or text == "status" then
        if Log then
            Log:Always("hud=" .. Store:ThemeId() .. "  wolf=" .. Store:WolfId() .. "  (/vtheme help)")
        end
        return
    end
    if text == "help" then
        if Log then
            Log:Always("/vtheme                show hud + wolf skins")
            Log:Always("/vtheme hud default    native H/M/S")
            Log:Always("/vtheme hud clean      readable Valknarr bars")
            Log:Always("/vtheme hud metal      three tiles stitched, fill in the hole")
            Log:Always("/vtheme wolf vanilla   native werewolf bar")
            Log:Always("/vtheme wolf clean     current Valknarr widget")
            Log:Always("/vtheme wolf wolf1     Nordic medallion")
            Log:Always("/vtheme wolf wolf2     snarling wolf + spiked ring")
            Log:Always("/vtheme wolf wolf3     steel medallion")
            Log:Always("/vtheme wolf wolf4     snarling wolf + Nordic ring")
            Log:Always("/vtheme default        hud default (alias)")
            Log:Always("/vtheme clean          hud clean (alias: valknarr)")
            Log:Always("/vtheme metal          hud metal")
            Log:Always("/vtheme toggle         hud default <-> clean")
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
    if text == "metal" or text == "metal1" or text == "metal2" or text == "metal3" or text == "metal4" then
        Store:SetThemeId(text)
        ApplyLive()
        return
    end
    if Log then
        Log:Warn("Unknown /vtheme args. Try /vtheme help")
    end
end

return Settings
