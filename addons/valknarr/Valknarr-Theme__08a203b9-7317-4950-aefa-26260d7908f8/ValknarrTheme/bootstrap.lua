ValknarrTheme = ValknarrTheme or {}

local Theme = ValknarrTheme
local Log = ValknarrThemeLog
local Store = ValknarrThemeStore
local Format = ValknarrThemeFormat
local Resources = ValknarrThemeResources
local Werewolf = ValknarrThemeWerewolf
local Settings = ValknarrThemeSettings

local ADDON_NAME = "ValknarrTheme"

function Theme:LibPresent(name)
    local lib = _G[name]
    return type(lib) == "table"
end

function Theme:DescribeEnv()
    local Safe = ValknarrThemeSafe
    local gamepad
    local console
    if Safe and Safe.Global then
        gamepad = Safe.Global("IsInGamepadPreferredMode")
        console = Safe.Global("ZO_IsConsoleOrGameCoreUI")
        if console == nil then
            console = Safe.Global("IsConsoleUI")
        end
    end
    return {
        version = ValknarrThemeVersion,
        theme = Store:ThemeId(),
        wolf = Store:WolfId(),
        debug = Log and Log.enabled and true or false,
        gamepad = gamepad and true or false,
        console = console and true or false,
        LAM = self:LibPresent("LibAddonMenu2") or self:LibPresent("LibAddonMenu"),
        Harvens = self:LibPresent("LibHarvensAddonSettings"),
        LibValknarrUIE = self:LibPresent("LibValknarrUIE"),
        LibDebugLogger = self:LibPresent("LibDebugLogger"),
        LibChatMessage = self:LibPresent("LibChatMessage"),
        LibGamepad = self:LibPresent("LibGamepad") or self:LibPresent("LibGamepadLAM"),
        LibRadialMenu = self:LibPresent("LibRadialMenu"),
        hudScene = Format and Format.CurrentSceneName and Format.CurrentSceneName() or nil,
        hudVisible = Format and Format.HudSceneVisible and Format.HudSceneVisible() or nil,
        barText = Store:GetSetting("showBarText"),
        preview = Store:GetSetting("previewInSettings"),
    }
end

function Theme:Diagnose()
    if not Log or not Log.Always then
        return
    end
    Log:Always("diag " .. Log:FormatPairs(self:DescribeEnv()))
    if Resources and Resources.Describe then
        local bars = Resources:Describe()
        for index = 1, #bars do
            Log:Always("bar " .. Log:FormatPairs(bars[index]))
        end
    end
    if Werewolf and Werewolf.Describe then
        Log:Always("wolf " .. Log:FormatPairs(Werewolf:Describe()))
    end
    Log:Always("Paste every [Theme] line from chat. After /reloadui they are also in SavedVariables/ValknarrTheme_SavedVariables.lua debugLog (not the engine Logs folder).")
end

function Theme:SyncHudVisibility()
    local hud = Format and Format.HudSceneVisible and Format.HudSceneVisible()
    if hud == nil then
        hud = true
    end
    if Resources and Resources.SyncHudVisibility then
        Resources:SyncHudVisibility()
    end
    if Werewolf and Werewolf.SyncHudVisibility then
        Werewolf:SyncHudVisibility(hud)
    end
end

local function HookHudState(target)
    if not target or type(target.RegisterCallback) ~= "function" or target.ValknarrThemeHudHook then
        return
    end
    target.ValknarrThemeHudHook = true
    pcall(target.RegisterCallback, target, "StateChange", function()
        Theme:SyncHudVisibility()
    end)
end

function Theme:RegisterHudScene()
    HookHudState(_G.PLAYER_ATTRIBUTE_BARS_FRAGMENT)
    HookHudState(_G.HUD_FRAGMENT)
    HookHudState(_G.HUD_UI_FRAGMENT)
    HookHudState(_G.HUD_SCENE)
    HookHudState(_G.HUD_UI_SCENE)
end

function Theme:Apply()
    if Log then
        Log:Debug("apply hud=" .. tostring(Store:ThemeId()) .. " wolf=" .. tostring(Store:WolfId()))
    end
    if Resources and Resources.Apply then
        Resources:Apply()
    end
    if Werewolf and Werewolf.Refresh then
        Werewolf:Refresh()
    end
end

function Theme:Initialize()
    if self.initialized then
        return
    end
    Store:Initialize()
    if Log and Log.SetPersistSink then
        Log:SetPersistSink(function(line)
            Store:AppendDebugLog(line)
        end)
    end
    if Log and Log.ApplyFromStore then
        Log:ApplyFromStore(true)
    end
    if Werewolf and Werewolf.Ensure then
        Werewolf:Ensure()
    end
    if Resources and Resources.RegisterHost then
        Resources:RegisterHost()
    end
    if Werewolf and Werewolf.RegisterHost then
        Werewolf:RegisterHost()
    end
    if Resources and Resources.RegisterEvents then
        Resources:RegisterEvents()
    end
    if Werewolf and Werewolf.RegisterEvents then
        Werewolf:RegisterEvents()
    end
    self:RegisterHudScene()
    if EVENT_MANAGER and EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Activated", EVENT_PLAYER_ACTIVATED, function()
            Theme:Apply()
        end)
    end
    if Settings and Settings.RegisterLibraries then
        Settings:RegisterLibraries()
    end
    SLASH_COMMANDS = SLASH_COMMANDS or {}
    SLASH_COMMANDS["/vtheme"] = function(args)
        Settings:HandleSlash(args)
    end
    SLASH_COMMANDS["/valknarrtheme"] = SLASH_COMMANDS["/vtheme"]
    self.initialized = true
    self:Apply()
    if Log then
        Log:Always("Valknarr Theme v" .. tostring(ValknarrThemeVersion or "?") .. " loaded")
        Log:Debug("hud=" .. Store:ThemeId() .. " wolf=" .. Store:WolfId())
    end
end

local function OnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForEvent) == "function" then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
    Theme:Initialize()
end

if EVENT_MANAGER and EVENT_ADD_ON_LOADED then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)
end

return Theme
