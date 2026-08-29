-- CB's Stamp of Manufacture
-- Marks player-crafted food, drink, potions and poisons in the gamepad
-- inventory with a small colored stamp in front of the item name.
--
-- How it works: ESO's item link carries a genuine "Crafted" flag
-- (IsItemLinkCrafted), so this isn't a guess based on item type - it's the
-- same data the game itself uses to know whether an item was player-made.
--
-- Hook point: every inventory row is a ZO_GamepadEntryData built from the
-- item's already-sorted data, then decorated via
-- entryData:InitializeInventoryVisualData(itemData). We wrap that method
-- and, AFTER it runs, prefix entryData.name (the on-screen text) for
-- matching items. We deliberately never touch itemData.name itself, so
-- sorting/search/tooltips - which all read the original field - are
-- untouched. Only the rendered label changes.

local ADDON_NAME = "CBStampOfManufacture"

local defaults = {
    enabled    = true,
    stampText  = "[CB] ",
    color      = "FFD700",  -- gold
    types      = { food = true, drink = true, potion = true, poison = true },
    debug      = false,
}
local sv

local function Dbg(msg) if sv and sv.debug then d("|cFFD700[CB Stamp]|r " .. msg) end end
local function Msg(msg) d("|cFFD700[CB Stamp]|r " .. msg) end

-- ---------------------------------------------------------------------------
-- Matching
-- ---------------------------------------------------------------------------
local TYPE_KEY = {
    [ITEMTYPE_FOOD]   = "food",
    [ITEMTYPE_DRINK]  = "drink",
    [ITEMTYPE_POTION] = "potion",
    [ITEMTYPE_POISON] = "poison",
}

local function ShouldStamp(itemData)
    if not itemData or not itemData.bagId or not itemData.slotIndex then return false end

    local itemLink = GetItemLink(itemData.bagId, itemData.slotIndex)
    if not itemLink or itemLink == "" then return false end

    local itemType = GetItemLinkItemType(itemLink)
    local key = TYPE_KEY[itemType]
    if not key or not sv.types[key] then return false end

    local crafted = IsItemLinkCrafted(itemLink)
    Dbg(string.format("checked %s: type=%s crafted=%s", itemData.name or "?", key, tostring(crafted)))
    return crafted
end

-- ---------------------------------------------------------------------------
-- The stamp itself
-- ---------------------------------------------------------------------------
local function ApplyStamp(entryData, itemData)
    if not sv.enabled then return end
    local ok, matched = pcall(ShouldStamp, itemData)
    if not ok or not matched then return end
    if not entryData or not entryData.name then return end

    -- Avoid double-stamping if this method somehow runs twice on one entry.
    if entryData.cbStamped then return end
    entryData.cbStamped = true

    local color = sv.color or defaults.color
    local r = tonumber(color:sub(1,2),16)/255
    local g = tonumber(color:sub(3,4),16)/255
    local b = tonumber(color:sub(5,6),16)/255

    -- Path A: whole-name markup (what we already had, minus the old prefix-only
    -- approach - now the ENTIRE name is wrapped, matching how quality colors
    -- recolor the whole name rather than adding a separate marker).
    local before = entryData.name
    entryData.name = string.format("|c%s%s|r", color, entryData.name)

    -- Path B: if this entry supports a dedicated name-color override (the same
    -- mechanism the game likely uses for quality-tier coloring, which can take
    -- precedence over embedded markup), set it too. Fully guarded - does
    -- nothing if the method doesn't exist on this client.
    local pathBAvailable = (entryData.SetNameColors ~= nil)
    if pathBAvailable then
        local colorDef = ZO_ColorDef and ZO_ColorDef:New(r, g, b, 1)
        if colorDef then
            local ok2 = pcall(function() entryData:SetNameColors(colorDef, colorDef) end)
            Dbg("Path B (SetNameColors) call " .. (ok2 and "succeeded" or "FAILED"))
        end
    end

    Dbg(string.format("STAMP on %s -> before=[%s] after=[%s] pathB_available=%s",
        itemData.name or "?", tostring(before), tostring(entryData.name), tostring(pathBAvailable)))
end

-- ---------------------------------------------------------------------------
-- Install the hook (once, at load)
-- ---------------------------------------------------------------------------
local hookInstalled = false
local function InstallHook()
    if hookInstalled then return end
    if not ZO_GamepadEntryData or not ZO_GamepadEntryData.InitializeInventoryVisualData then
        Msg("DIAG: ZO_GamepadEntryData.InitializeInventoryVisualData missing on this client - stamping unavailable.")
        return
    end

    local original = ZO_GamepadEntryData.InitializeInventoryVisualData
    ZO_GamepadEntryData.InitializeInventoryVisualData = function(self, itemData, ...)
        original(self, itemData, ...)
        local ok, err = pcall(ApplyStamp, self, itemData)
        if not ok then Dbg("DIAG: ApplyStamp error: " .. tostring(err)) end
    end

    hookInstalled = true
    Dbg("Hook installed on ZO_GamepadEntryData.InitializeInventoryVisualData")
end

-- ---------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------
local function RegisterSlash()
    SLASH_COMMANDS["/cbstamp"] = function(args)
        args = zo_strtrim(args or "")
        local cmd, rest = args:match("^(%S+)%s*(.*)$")
        cmd = cmd and zo_strlower(cmd) or ""

        if cmd == "on" then
            sv.enabled = true; Msg("Enabled. Reopen your inventory to refresh.")
        elseif cmd == "off" then
            sv.enabled = false; Msg("Disabled. Reopen your inventory to refresh.")
        elseif cmd == "text" and rest ~= "" then
            sv.stampText = rest .. " "
            Msg("Stamp text: " .. sv.stampText)
        elseif cmd == "color" and rest:match("^%x%x%x%x%x%x$") then
            sv.color = zo_strupper(rest)
            Msg("Stamp color set. Reopen your inventory to see it.")
        elseif cmd == "type" then
            local t = zo_strlower(rest)
            if sv.types[t] ~= nil then
                sv.types[t] = not sv.types[t]
                Msg(t .. ": " .. (sv.types[t] and "ON" or "OFF"))
            else
                Msg("Usage: /cbstamp type <food|drink|potion|poison>")
            end
        elseif cmd == "debug" then
            sv.debug = not sv.debug
            Msg("debug=" .. tostring(sv.debug))
        else
            Msg("/cbstamp on|off | text <marker> | color <hex> | type <food|drink|potion|poison> | debug")
        end
    end
end

-- ---------------------------------------------------------------------------
-- Optional LAM panel
-- ---------------------------------------------------------------------------
local panelBuilt = false
local function BuildSettingsPanel()
    local LAM = LibAddonMenu2
    if not LAM then return end
    panelBuilt = true

    LAM:RegisterAddonPanel("CBStampPanel", {
        type = "panel", name = "CB's Stamp of Manufacture",
        author = "@Dicen95728", version = "1.2", registerForRefresh = true,
    })
    LAM:RegisterOptionControls("CBStampPanel", {
        { type = "checkbox", name = "Enabled",
          getFunc = function() return sv.enabled end,
          setFunc = function(v) sv.enabled = v end },
        { type = "editbox", name = "Stamp text",
          getFunc = function() return sv.stampText end,
          setFunc = function(v) sv.stampText = (v ~= "" and (v .. " ")) or defaults.stampText end },
        { type = "colorpicker", name = "Stamp color",
          getFunc = function()
              local c = sv.color or defaults.color
              return tonumber(c:sub(1,2),16)/255, tonumber(c:sub(3,4),16)/255, tonumber(c:sub(5,6),16)/255
          end,
          setFunc = function(r,g,b)
              sv.color = string.format("%02X%02X%02X", r*255, g*255, b*255)
          end },
        { type = "checkbox", name = "Food",
          getFunc = function() return sv.types.food end, setFunc = function(v) sv.types.food = v end },
        { type = "checkbox", name = "Drink",
          getFunc = function() return sv.types.drink end, setFunc = function(v) sv.types.drink = v end },
        { type = "checkbox", name = "Potions",
          getFunc = function() return sv.types.potion end, setFunc = function(v) sv.types.potion = v end },
        { type = "checkbox", name = "Poisons",
          getFunc = function() return sv.types.poison end, setFunc = function(v) sv.types.poison = v end },
        { type = "description",
          text = "Changes apply next time you open your inventory." },
    })
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("CBStampSV", 1, nil, defaults)
    if type(sv.types) ~= "table" then sv.types = defaults.types end

    InstallHook()
    RegisterSlash()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
        if not panelBuilt then BuildSettingsPanel() end
        InstallHook() -- retry in case ZO_GamepadEntryData wasn't ready at load
    end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
