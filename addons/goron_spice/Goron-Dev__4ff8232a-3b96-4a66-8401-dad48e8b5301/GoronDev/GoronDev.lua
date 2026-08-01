local function normalizeAccount(name)
    return (string.lower(tostring(name or "")):gsub("^@", ""))
end

local DEV_ACCOUNTS = {
    ohmygoron = true,
    goron_spice = true,
}

local FRIEND_ACCOUNTS = {
    autumnmcbottom = true,
    designnerd_ = true,
    treenerd__ = true,
    shibnibblies = true,
    tineybean = true,
    tinmeril = true,
    bleachbrunette = true,
}
local FRIEND_ACCESS_ENABLED = true

local FRIEND_LIST_LABEL = table.concat({
    "@autumnmcbottom",
    "@designnerd_",
    "@treenerd__",
    "@shibnibblies",
    "@tineybean",
    "@Tinmeril",
    "@bleachbrunette",
}, ", ")

local CURRENT_ACCOUNT = normalizeAccount(GetDisplayName and GetDisplayName() or "")
local IS_DEV_ACCOUNT = DEV_ACCOUNTS[CURRENT_ACCOUNT] == true
local IS_FRIEND_ACCOUNT = FRIEND_ACCOUNTS[CURRENT_ACCOUNT] == true

GoronDev = GoronDev or {}
GoronDev.name = "GoronDev"
GoronDev.version = "dev-harness"

local defaults = {
    enableRezBotDev = true,
}
local defaultsNamespace = "GoronDev"
local rezbotDevNamespace = "RezBotDev"

local baseSavedVars = ZO_SavedVars:NewAccountWide("GoronDevSV", 1, nil, {})
GoronDev.__svRoot = baseSavedVars

GoronDev.saved = baseSavedVars[defaultsNamespace] or {}
baseSavedVars[defaultsNamespace] = GoronDev.saved

for k, v in pairs(defaults) do
    if GoronDev.saved[k] == nil then
        GoronDev.saved[k] = v
    end
end

GoronDev.savedRezbot = baseSavedVars[rezbotDevNamespace] or {}
baseSavedVars[rezbotDevNamespace] = GoronDev.savedRezbot

GoronDev.__isDevAccount = IS_DEV_ACCOUNT
GoronDev.__isFriendAccount = IS_FRIEND_ACCOUNT
GoronDev.__friendAccounts = FRIEND_ACCOUNTS
GoronDev.__friendAccessEnabled = FRIEND_ACCESS_ENABLED
GoronDev.__allowRezBotDev = nil
GoronDev.__currentAccount = CURRENT_ACCOUNT

local function ensureSettingsPanel()
    local HAS = LibHarvensAddonSettings
    if not HAS then return end

    local panel = HAS:AddAddon(GoronDev.name, {
        allowDefaults = true,
        defaultsFunction = function()
            for k, v in pairs(defaults) do
                GoronDev.saved[k] = v
            end
        end,
    })
    if not panel then return end

    panel:AddSetting({ type = HAS.ST_HEADER, label = "RezBot Dev Build" })
    panel:AddSetting({
        type = HAS.ST_CHECKBOX,
        label = "Enable RezBot (Dev)",
        tooltip = "Loads the GoronDev RezBot build. Requires reload to take effect.",
        default = defaults.enableRezBotDev,
        getFunction = function() return GoronDev.saved.enableRezBotDev ~= false end,
        setFunction = function(val)
            GoronDev.saved.enableRezBotDev = val
            d(string.format("|cFFFF66GoronDev|r: RezBot dev %s (reload UI to apply).", val and "enabled" or "disabled"))
        end,
    })

    panel:AddSetting({ type = HAS.ST_HEADER, label = "Friend Access" })
    panel:AddSetting({ type = HAS.ST_LABEL, label = "Friends auto-enabled: " .. FRIEND_LIST_LABEL })
end

local function onLoaded(_, addon)
    if addon ~= GoronDev.name then return end
    EVENT_MANAGER:UnregisterForEvent(GoronDev.name .. "_Load", EVENT_ADD_ON_LOADED)

    ensureSettingsPanel()

    if not (GoronDev.saved and GoronDev.saved.enableRezBotDev) then
        GoronDev.__allowRezBotDev = false
        d("|cFFFF66GoronDev|r: RezBot dev build disabled in settings.")
        return
    end

    if not IS_DEV_ACCOUNT then
        local friendsAllowed = FRIEND_ACCESS_ENABLED and IS_FRIEND_ACCOUNT
        if friendsAllowed then
            GoronDev.__allowRezBotDev = true
        else
            GoronDev.__allowRezBotDev = false
            if not IS_FRIEND_ACCOUNT then
                d("|cFFFF66GoronDev|r: GoronDev restricted to authorized accounts.")
            end
            return
        end
    end

    GoronDev.__allowRezBotDev = true

    if RezBot and RezBot.__source and RezBot.__source ~= "GoronDev" then
        GoronDev.__allowRezBotDev = false
        d("|cFFFF66GoronDev|r: Production RezBot already loaded; skipping dev build.")
        return
    end

    d(string.format("|cFFFF66GoronDev|r harness active (RezBot dev %s).", tostring(GoronDev.version)))
end

EVENT_MANAGER:RegisterForEvent(GoronDev.name .. "_Load", EVENT_ADD_ON_LOADED, onLoaded)
