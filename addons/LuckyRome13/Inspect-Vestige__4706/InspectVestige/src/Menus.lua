-- Inspect Vestige by LuckyRome13
-- Menus.lua -- the two requested entry points into an inspect:
--   1. Right-click on friend / guild / group list rows  (LibCustomMenu -- solid).
--   2. The hold-interact radial wheel in the world       (ZO_PlayerToPlayer -- fragile).
-- The keybind (Bindings.xml -> InspectVestige.OnReticleKeybind, defined in Main.lua)
-- is the guaranteed in-world path if the wheel hook can't attach.

local IV = InspectVestige
IV.Menus = IV.Menus or {}
local Menus = IV.Menus

local function dbg(msg)
    if IV.sv and IV.sv.debug then d("|cFFD700[IV]|r " .. tostring(msg)) end
end

--------------------------------------------------------------------------------
-- Resolve the target from whatever LibCustomMenu hands the callback. Signatures
-- differ across lists/versions, so we scan the args defensively.
--------------------------------------------------------------------------------
local function extractAccount(...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "string" and v:sub(1, 1) == "@" then
            return v
        elseif type(v) == "table" then
            local d = v.displayName or v.characterName
            if type(d) == "string" and d:sub(1, 1) == "@" then return d end
        end
    end
    return nil
end

local function extractGroupUnitTag(...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if type(v) == "string" and v:find("^group%d") then
            return v
        elseif type(v) == "table" and type(v.unitTag) == "string" and v.unitTag:find("^group%d") then
            return v.unitTag
        end
    end
    return nil
end

--------------------------------------------------------------------------------
-- List context menus (LibCustomMenu)
--------------------------------------------------------------------------------
local function registerListMenus()
    local lcm = _G.LibCustomMenu
    if not lcm then
        dbg("LibCustomMenu not present -- list right-click menus disabled")
        return false
    end
    -- Sort our entry to the BOTTOM of the context menu rather than competing with the game's own
    -- actions (Whisper / Invite / ...). LibCustomMenu orders by category: EARLY=1 .. LATE=6, higher
    -- is later, and LATE is also the lib's own default for an unspecified category.
    local category = lcm.CATEGORY_LATE or lcm.CATEGORY_SECONDARY

    local function addEntry(inspectFn)
        AddCustomMenuItem(IV.L.MENU_INSPECT, inspectFn)
    end

    if lcm.RegisterFriendsListContextMenu then
        lcm:RegisterFriendsListContextMenu(function(...)
            local acc = extractAccount(...)
            addEntry(function() IV.InspectByAccount(acc) end)
        end, category)
    end

    if lcm.RegisterGuildRosterContextMenu then
        lcm:RegisterGuildRosterContextMenu(function(...)
            local acc = extractAccount(...)
            addEntry(function() IV.InspectByAccount(acc) end)
        end, category)
    end

    if lcm.RegisterGroupListContextMenu then
        lcm:RegisterGroupListContextMenu(function(...)
            local tag = extractGroupUnitTag(...)
            local acc = extractAccount(...)
            addEntry(function()
                if tag then IV.InspectUnitTag(tag) else IV.InspectByAccount(acc) end
            end)
        end, category)
    end

    dbg("list context menus registered")
    return true
end

--------------------------------------------------------------------------------
-- Interact wheel injection (fragile -- uses internal ZO_PlayerToPlayer).
-- VERIFY against current esoui source; the keybind fallback covers breakage.
--------------------------------------------------------------------------------
-- The hold-interact wheel on a player is a ZO_RadialMenu owned by ZO_PlayerToPlayer.
-- StartInteraction() clears it, adds the game's entries (Whisper/Group/Trade/...) and a
-- Cancel (X) entry LAST, then shows it. ZO_RadialMenu maps entry order -> angle, so the
-- last entry lands at bottom-centre (the Cancel's spot). We pre-hook the menu's Show to
-- append our entry, then swap the last two entries so whatever the game put last (the
-- Cancel) stays last -- keeping the X at bottom-centre and our entry among the actions.
-- Reset on Clear()/ResetData() so we add exactly once per interaction. All guarded; the
-- keybind is the guaranteed fallback if internals change.
local P2P_UNIT_TAG = "reticleoverplayer"
local WHEEL_ICON   = "/esoui/art/menubar/menubar_character_up.dds"

local function tryHookWheel()
    if IV.sv and IV.sv.wheelInject == false then
        dbg("wheel injection disabled in settings")
        return false
    end
    local p2p = _G.PLAYER_TO_PLAYER
    if not p2p or type(p2p.GetRadialMenu) ~= "function" then
        dbg("wheel: PLAYER_TO_PLAYER.GetRadialMenu unavailable -- keybind only")
        return false
    end

    local menu = p2p:GetRadialMenu()
    if not menu or type(menu.AddEntry) ~= "function" or type(menu.Show) ~= "function" then
        dbg("wheel: radial menu / AddEntry unavailable -- keybind only")
        return false
    end

    local added = false
    local function resetAdded() added = false end
    if type(menu.Clear) == "function" then SecurePostHook(menu, "Clear", resetAdded) end
    if type(menu.ResetData) == "function" then SecurePostHook(menu, "ResetData", resetAdded) end

    local ok = pcall(function()
        ZO_PreHook(menu, "Show", function(self)
            if not added and IV.sv and IV.sv.wheelInject and DoesUnitExist(P2P_UNIT_TAG) then
                added = true
                pcall(function()
                    self:AddEntry(IV.L.MENU_INSPECT, WHEEL_ICON, WHEEL_ICON, function()
                        IV.InspectUnitTag(P2P_UNIT_TAG)
                    end)
                    -- Keep the game's last entry (Cancel/X) at the bottom: swap it back
                    -- past our just-appended entry.
                    local e = self.entries
                    local n = e and #e or 0
                    if n >= 2 then
                        e[n], e[n - 1] = e[n - 1], e[n]
                    end
                end)
            end
            -- return nil so the original Show proceeds and renders our entry
        end)
    end)

    if ok then
        dbg("wheel injection hooked (pre-hook on radial menu Show)")
        return true
    end
    dbg("wheel: failed to hook radial menu Show -- keybind only")
    return false
end

--------------------------------------------------------------------------------
function Menus.Init()
    Menus.listMenusReady = registerListMenus()
    Menus.wheelReady     = tryHookWheel()
end
