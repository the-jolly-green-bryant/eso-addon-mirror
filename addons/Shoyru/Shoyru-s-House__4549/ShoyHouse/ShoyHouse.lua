-- ShoyHouse
-- /shoyhouse           → teleport to the owner's configured home
-- /shoyhouse setup     → auto-detect your primary house and print shareable config
-- /shoyhouse here      → use the house you are currently standing in
-- /shoyhouse info      → show what is currently configured
--
-- HOW TO SHARE WITH FRIENDS:
--   1. Run /shoyhouse setup (or /shoyhouse here while inside your chosen house)
--   2. Copy the two lines it prints and paste them into this file below
--   3. Hand the whole ShoyHouse folder to your friends
--   4. Make sure your house access is set to Public or Friends in the Housing Editor

ShoyHouse = {}
ShoyHouse.name = "ShoyHouse"

-- ─── Owner config ─────────────────────────────────────────────────────────────
-- After running /shoyhouse setup, paste the output here so friends who install
-- this file will automatically have the right destination.

ShoyHouse.OWNER_NAME     = "@NotShoyru"
ShoyHouse.OWNER_HOUSE_ID = 90

-- ──────────────────────────────────────────────────────────────────────────────

local ADDON_NAME = ShoyHouse.name

local function Print(msg)
    d("|c88CCFF[ShoyHouse]|r " .. tostring(msg))
end

local function Teleport()
    local name = ShoyHouse.OWNER_NAME
    local id   = ShoyHouse.OWNER_HOUSE_ID

    if name == "" or id == 0 then
        Print("Not configured yet. Run |cFFFFFF/shoyhouse setup|r first.")
        return
    end

    if GetDisplayName() == name then
        -- ESO does not expose an API for warping to your own house.
        -- Direct players to use the game's built-in method instead.
        Print("You are the owner — ESO doesn't allow addons to warp you to your own house.")
        Print("Use |cFFFFFF/house|r (primary house) or open |cFFFFFFCollections > Housing|r to enter.")
    else
        Print(string.format("Porting to |cFFFFFF%s|r's house... (if nothing happens, the house may be private)", name))
        JumpToSpecificHouse(name, id)
    end
end

local function ApplyConfig(name, id)
    ShoyHouse.OWNER_NAME     = "@NotShoyru"
    ShoyHouse.OWNER_HOUSE_ID = 90
    if ShoyHouse.sv then
        ShoyHouse.sv.ownerName    = name
        ShoyHouse.sv.ownerHouseId = id
    end
end

local function PrintShareInstructions(name, id)
    Print(string.format("Configured!  Owner: |cFFFFFF%s|r   House ID: |cFFFFFF%d|r", name, id))
    Print("To share with friends, replace the two config lines in ShoyHouse.lua with:")
    d(string.format(
        "|cFFFFFFShoyHouse.OWNER_NAME     = \"%s\"\nShoyHouse.OWNER_HOUSE_ID = %d|r",
        name, id))
end

local function SetupFromPrimaryHouse()
    local name = GetDisplayName()
    local id   = GetHousingPrimaryHouse()

    if not id or id == 0 then
        Print("No primary house found. Go to the Housing Editor and set a primary house, " ..
              "OR stand inside your chosen house and run |cFFFFFF/shoyhouse here|r instead.")
        return
    end

    ApplyConfig(name, id)
    PrintShareInstructions(name, id)
end

local function SetupFromCurrentHouse()
    -- GetCurrentHouseId returns the house ID of the zone you are in, 0 if not in a house
    local id = GetCurrentHouseId()

    if not id or id == 0 then
        Print("You are not currently inside a house. Walk into your home first, then run this command.")
        return
    end

    local name = GetDisplayName()
    ApplyConfig(name, id)
    PrintShareInstructions(name, id)
end

local function ShowInfo()
    local name = ShoyHouse.OWNER_NAME
    local id   = ShoyHouse.OWNER_HOUSE_ID

    if name == "" or id == 0 then
        Print("Not configured. Run |cFFFFFF/shoyhouse setup|r or |cFFFFFF/shoyhouse here|r.")
    else
        Print(string.format("Owner: |cFFFFFF%s|r   House ID: |cFFFFFF%d|r", name, id))
        Print("Use |cFFFFFF/shoyhouse|r to teleport there.")
    end
end

local function ShowHelp()
    d("|c88CCFF[ShoyHouse] Commands:|r")
    d("  |cFFFFFF/shoyhouse|r              – teleport to configured home")
    d("  |cFFFFFF/shoyhouse setup|r        – auto-detect from your primary house")
    d("  |cFFFFFF/shoyhouse here|r         – use the house you are standing in")
    d("  |cFFFFFF/shoyhouse info|r         – show current config")
    d("  |cFFFFFF/shoyhouse help|r         – show this list")
end

local defaults = {
    ownerName    = "",
    ownerHouseId = 0,
}

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    ShoyHouse.sv = ZO_SavedVars:NewAccountWide("ShoyHouseSV", 1, nil, defaults)

    -- Hardcoded values in the Lua file take priority over saved variables.
    -- This lets a distributed copy work immediately without any setup on the friend's end.
    if ShoyHouse.OWNER_NAME ~= "" then
        -- Baked-in config: save it locally too so /shoyhouse info shows it
        ShoyHouse.sv.ownerName    = ShoyHouse.OWNER_NAME
        ShoyHouse.sv.ownerHouseId = ShoyHouse.OWNER_HOUSE_ID
    elseif ShoyHouse.sv.ownerName ~= "" then
        -- No hardcoded values: load from last saved setup
        ShoyHouse.OWNER_NAME     = ShoyHouse.sv.ownerName
        ShoyHouse.OWNER_HOUSE_ID = ShoyHouse.sv.ownerHouseId
    end

    SLASH_COMMANDS["/shoyhouse"] = function(args)
        local arg = (args or ""):match("^%s*(.-)%s*$")
        if arg == "" then
            Teleport()
        elseif arg == "setup" then
            SetupFromPrimaryHouse()
        elseif arg == "here" then
            SetupFromCurrentHouse()
        elseif arg == "info" then
            ShowInfo()
        else
            ShowHelp()
        end
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
