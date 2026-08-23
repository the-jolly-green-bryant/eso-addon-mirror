ValknarrUIERadial = ValknarrUIERadial or {}

local Radial = ValknarrUIERadial
local Log = ValknarrUIELog
local ADDON_ID = "ValknarrUIE"
local ENTRY_ID = "uiedit"
-- Vanilla texture; no custom art (PS5 texture-load risk from ShogrinUI notes).
local ENTRY_ICON = "/esoui/art/icons/mapkey/mapkey_grouparea.dds"

function Radial:TryRegister(openCallback)
    local lib = _G.LibRadialMenu
    if type(lib) ~= "table" then
        if Log then
            Log:Debug("LibRadialMenu not installed — /uiedit remains the opener")
        end
        return false
    end
    if type(openCallback) ~= "function" then
        return false
    end

    local function Call(method, ...)
        if type(lib[method]) ~= "function" then
            return false, "missing " .. method
        end
        return pcall(lib[method], lib, ...)
    end

    local ok, err = Call("RegisterAddon", ADDON_ID, "Valknarr UI")
    if not ok then
        if Log then
            Log:Warn("LibRadialMenu RegisterAddon failed: " .. tostring(err))
        end
        return false
    end

    ok, err = Call(
        "RegisterEntry",
        ADDON_ID,
        "Open editor",
        ENTRY_ID,
        ENTRY_ICON,
        openCallback,
        "Open the Valknarr UI HUD grid editor"
    )
    if not ok then
        if Log then
            Log:Warn("LibRadialMenu RegisterEntry failed: " .. tostring(err))
        end
        return false
    end

    if Log then
        Log:Info("LibRadialMenu: Open editor registered (assign it on the utility wheel)")
    end
    return true
end

return Radial
