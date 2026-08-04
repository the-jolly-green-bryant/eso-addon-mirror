local MCH = MonsterCofferHelper

--------------------------------------------------------------------------------
-- Slash commands
--------------------------------------------------------------------------------

-- Accepts a vendor number, or enough of a quartermaster's name to be unambiguous.
local function ResolveVendor(argument)
    local number = tonumber(argument)
    if number and number >= 1 and number <= #MCH.VENDOR_IDS then
        return number
    end

    for _, vendorId in ipairs(MCH.VENDOR_IDS) do
        local name = zo_strlower(MCH.Model.GetVendorName(vendorId))
        if string.find(name, argument, 1, true) then
            return vendorId
        end
    end
    return nil
end

local function PrintUsage()
    d("|c9FD3FF/coffer|r - verdict for all three quartermasters")
    d("|c9FD3FF/coffer <1-3 or name>|r - full breakdown for one of them")
    d("|c9FD3FF/coffer panel|r - toggle the window")
    d("|c9FD3FF/coffer settings|r - open the settings panel")
    d("|c9FD3FF/coffer scan|r - dump the open vendor's shelf (diagnostics)")
    d("|c9FD3FF/coffer forget|r - discard prices and stock read from vendors")
end

local function HandleSlash(argumentString)
    local argument = zo_strlower(zo_strtrim(argumentString or ""))

    if argument == "" then
        for _, vendorId in ipairs(MCH.VENDOR_IDS) do
            local result = MCH.Advisor.ForVendor(vendorId)
            if result then
                result.vendorId = vendorId
                MCH.Format.PrintToChat(result)
            end
        end
        return
    end

    if argument == "panel" or argument == "show" or argument == "toggle" then
        MCH.UI.Toggle()
        return
    end

    if argument == "settings" or argument == "config" or argument == "options" then
        MCH.Settings.Open()
        return
    end

    if argument == "scan" or argument == "dump" then
        MCH.Store.Dump()
        return
    end

    if argument == "forget" or argument == "reset" then
        MCH.db.learned = {}
        MCH.Model.Invalidate()
        MCH.UI.Refresh()
        d("|c9FD3FF[Coffer]|r Forgot all prices and stock read from vendors.")
        return
    end

    if argument == "help" or argument == "?" then
        PrintUsage()
        return
    end

    local vendorId = ResolveVendor(argument)
    if not vendorId then
        PrintUsage()
        return
    end

    MCH.Format.PrintDetail(MCH.Advisor.ForVendor(vendorId), vendorId)
end

--------------------------------------------------------------------------------
-- Boot
--------------------------------------------------------------------------------

-- Unlocking a shoulder changes every number this addon reports, so the cached
-- pools are dropped and anything on screen is redrawn.
local function OnCollectionChanged()
    MCH.Model.Invalidate()
    MCH.UI.Refresh()
end

local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= MCH.name then return end
    EVENT_MANAGER:UnregisterForEvent(MCH.name, EVENT_ADD_ON_LOADED)

    MCH.db = ZO_SavedVars:NewAccountWide("MonsterCofferHelper_Data", 1, nil, MCH.defaults)

    MCH.UI.Initialize()
    MCH.Settings.Initialize()
    MCH.Store.Initialize()
    MCH.Tooltips.Initialize()

    EVENT_MANAGER:RegisterForEvent(MCH.name, EVENT_ITEM_SET_COLLECTION_UPDATED, OnCollectionChanged)
    EVENT_MANAGER:RegisterForEvent(MCH.name, EVENT_ITEM_SET_COLLECTIONS_UPDATED, OnCollectionChanged)

    SLASH_COMMANDS["/coffer"] = HandleSlash
    SLASH_COMMANDS["/mch"] = HandleSlash
end

EVENT_MANAGER:RegisterForEvent(MCH.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- Keybind target, declared in Bindings.xml.
function MonsterCofferHelper_Toggle()
    MCH.UI.Toggle()
end
