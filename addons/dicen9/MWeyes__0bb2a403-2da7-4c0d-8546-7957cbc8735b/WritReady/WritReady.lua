-- Writ Ready v2 - self-contained (no WritWorthy dependency; it isn't
-- available on console).
--
-- Scans unconsumed Master Writs in your inventory and reports whether you
-- can craft each one right now, and if not, why.
--
-- How a master writ's requirement is decoded:
-- The writ's item link encodes its request as six hidden numeric fields
-- (not normal item properties). ZO_LinkHandler_ParseLink splits any item
-- link into its raw pipe-delimited fields; for a writ, positions 10-15 are:
--   writ1 = item slot number (which weapon/armor/jewelry piece)
--   writ2 = material tier
--   writ3 = quality
--   writ4 = set id
--   writ5 = trait required (the raw ITEM_TRAIT_TYPE_* constant)
--   writ6 = motif/style required (0 = none)
--
-- writ1 is looked up in ITEM_TABLE below to get which crafting skill line
-- and which "research line" (weapon/armor slot) it belongs to. writ5 is
-- looked up in TRAIT_INDEX to get the 1-9 position GetSmithingResearchLine-
-- TraitInfo expects. That function then tells us, directly from the base
-- game, whether the trait is researched - no third-party data needed there.
--
-- v2 scope: trait-research checking only. Style/motif checking is left for
-- a future version - see the caveat printed when a motif is required.

local ADDON_NAME = "WritReady"

local defaults = {
    enabled  = true,
    debug    = false,
}
local sv

local function Dbg(msg) if sv and sv.debug then d("|c88DDFF[Writ Ready]|r " .. msg) end end
local function Msg(msg) d("|c88DDFF[Writ Ready]|r " .. msg) end

-- ---------------------------------------------------------------------------
-- Crafting skill types (school) and their research-line index tables.
-- Adapted from the standard, stable ESO crafting research-line ordering.
-- ---------------------------------------------------------------------------
local HVY = { skill = CRAFTING_TYPE_BLACKSMITHING, motif = true, lines = {
    H1_AXE=1, H1_MACE=2, H1_SWORD=3, H2_BATTLE_AXE=4, H2_MAUL=5, H2_GREATSWORD=6,
    DAGGER=7, CHEST=8, FEET=9, HANDS=10, HEAD=11, LEGS=12, SHOULDERS=13, WAIST=14 } }
local MED = { skill = CRAFTING_TYPE_CLOTHIER, motif = true, lines = {
    CHEST=8, FEET=9, HANDS=10, HEAD=11, LEGS=12, SHOULDERS=13, WAIST=14 } }
local LGT = { skill = CRAFTING_TYPE_CLOTHIER, motif = true, lines = {
    CHEST=1, FEET=2, HANDS=3, HEAD=4, LEGS=5, SHOULDERS=6, WAIST=7 } }
local WW  = { skill = CRAFTING_TYPE_WOODWORKING, motif = true, lines = {
    BOW=1, FLAME_STAFF=2, ICE_STAFF=3, LIGHTNING_STAFF=4, RESTO_STAFF=5, SHIELD=6 } }
local JW  = { skill = CRAFTING_TYPE_JEWELRYCRAFTING or 7, motif = false, lines = {
    NECKLACE=1, RING=2 } }

-- item slot number (writ1) -> { school, line, name }
-- 4th element is the motif/style "page" (chapter) that covers this item
-- type, needed by LibCharacterKnowledge to check style knowledge. These are
-- real ESO globals (ITEM_STYLE_CHAPTER_*), not hardcoded numbers.
local ITEM_TABLE = {
    [53] = { HVY, HVY.lines.H1_AXE,         "Axe",             ITEM_STYLE_CHAPTER_AXES },
    [56] = { HVY, HVY.lines.H1_MACE,        "Mace",            ITEM_STYLE_CHAPTER_MACES },
    [59] = { HVY, HVY.lines.H1_SWORD,       "Sword",           ITEM_STYLE_CHAPTER_SWORDS },
    [68] = { HVY, HVY.lines.H2_BATTLE_AXE,  "Battle Axe",      ITEM_STYLE_CHAPTER_AXES },
    [67] = { HVY, HVY.lines.H2_GREATSWORD,  "Greatsword",      ITEM_STYLE_CHAPTER_SWORDS },
    [69] = { HVY, HVY.lines.H2_MAUL,        "Maul",            ITEM_STYLE_CHAPTER_MACES },
    [62] = { HVY, HVY.lines.DAGGER,         "Dagger",          ITEM_STYLE_CHAPTER_DAGGERS },
    [46] = { HVY, HVY.lines.CHEST,          "Heavy Cuirass",   ITEM_STYLE_CHAPTER_CHESTS },
    [50] = { HVY, HVY.lines.FEET,           "Heavy Sabatons",  ITEM_STYLE_CHAPTER_BOOTS },
    [52] = { HVY, HVY.lines.HANDS,          "Heavy Gauntlets", ITEM_STYLE_CHAPTER_GLOVES },
    [44] = { HVY, HVY.lines.HEAD,           "Heavy Helm",      ITEM_STYLE_CHAPTER_HELMETS },
    [49] = { HVY, HVY.lines.LEGS,           "Heavy Greaves",   ITEM_STYLE_CHAPTER_LEGS },
    [47] = { HVY, HVY.lines.SHOULDERS,      "Heavy Pauldron",  ITEM_STYLE_CHAPTER_SHOULDERS },
    [48] = { HVY, HVY.lines.WAIST,          "Heavy Girdle",    ITEM_STYLE_CHAPTER_BELTS },

    [28] = { LGT, LGT.lines.CHEST,          "Light Robe",      ITEM_STYLE_CHAPTER_CHESTS },
    [75] = { LGT, LGT.lines.CHEST,          "Light Jerkin",    ITEM_STYLE_CHAPTER_CHESTS },
    [32] = { LGT, LGT.lines.FEET,           "Light Shoes",     ITEM_STYLE_CHAPTER_BOOTS },
    [34] = { LGT, LGT.lines.HANDS,          "Light Gloves",    ITEM_STYLE_CHAPTER_GLOVES },
    [26] = { LGT, LGT.lines.HEAD,           "Light Hat",       ITEM_STYLE_CHAPTER_HELMETS },
    [31] = { LGT, LGT.lines.LEGS,           "Light Breeches",  ITEM_STYLE_CHAPTER_LEGS },
    [29] = { LGT, LGT.lines.SHOULDERS,      "Light Epaulets",  ITEM_STYLE_CHAPTER_SHOULDERS },
    [30] = { LGT, LGT.lines.WAIST,          "Light Sash",      ITEM_STYLE_CHAPTER_BELTS },

    [37] = { MED, MED.lines.CHEST,          "Medium Jack",     ITEM_STYLE_CHAPTER_CHESTS },
    [41] = { MED, MED.lines.FEET,           "Medium Boots",    ITEM_STYLE_CHAPTER_BOOTS },
    [43] = { MED, MED.lines.HANDS,          "Medium Bracers",  ITEM_STYLE_CHAPTER_GLOVES },
    [35] = { MED, MED.lines.HEAD,           "Medium Helmet",   ITEM_STYLE_CHAPTER_HELMETS },
    [40] = { MED, MED.lines.LEGS,           "Medium Guards",   ITEM_STYLE_CHAPTER_LEGS },
    [38] = { MED, MED.lines.SHOULDERS,      "Medium Arm Cops", ITEM_STYLE_CHAPTER_SHOULDERS },
    [39] = { MED, MED.lines.WAIST,          "Medium Belt",     ITEM_STYLE_CHAPTER_BELTS },

    [70] = { WW,  WW.lines.BOW,             "Bow",             ITEM_STYLE_CHAPTER_BOWS },
    [72] = { WW,  WW.lines.FLAME_STAFF,     "Inferno Staff",   ITEM_STYLE_CHAPTER_STAVES },
    [73] = { WW,  WW.lines.ICE_STAFF,       "Frost Staff",     ITEM_STYLE_CHAPTER_STAVES },
    [74] = { WW,  WW.lines.LIGHTNING_STAFF, "Lightning Staff", ITEM_STYLE_CHAPTER_STAVES },
    [71] = { WW,  WW.lines.RESTO_STAFF,     "Healing Staff",   ITEM_STYLE_CHAPTER_STAVES },
    [65] = { WW,  WW.lines.SHIELD,          "Shield",          ITEM_STYLE_CHAPTER_SHIELDS },

    [24] = { JW,  JW.lines.RING,            "Ring",            nil },
    [18] = { JW,  JW.lines.NECKLACE,        "Necklace",        nil },
}

-- Raw ITEM_TRAIT_TYPE_* constant (as found in writ5) -> 1-9 research index.
-- This ordering is fixed and shared by every item within its category.
local TRAIT_INDEX = {
    [ITEM_TRAIT_TYPE_WEAPON_POWERED]       = 1, [ITEM_TRAIT_TYPE_WEAPON_CHARGED]    = 2,
    [ITEM_TRAIT_TYPE_WEAPON_PRECISE]       = 3, [ITEM_TRAIT_TYPE_WEAPON_INFUSED]    = 4,
    [ITEM_TRAIT_TYPE_WEAPON_DEFENDING]     = 5, [ITEM_TRAIT_TYPE_WEAPON_TRAINING]   = 6,
    [ITEM_TRAIT_TYPE_WEAPON_SHARPENED]     = 7, [ITEM_TRAIT_TYPE_WEAPON_DECISIVE]   = 8,
    [ITEM_TRAIT_TYPE_WEAPON_NIRNHONED]     = 9,

    [ITEM_TRAIT_TYPE_ARMOR_STURDY]         = 1, [ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE]= 2,
    [ITEM_TRAIT_TYPE_ARMOR_REINFORCED]     = 3, [ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = 4,
    [ITEM_TRAIT_TYPE_ARMOR_TRAINING]       = 5, [ITEM_TRAIT_TYPE_ARMOR_INFUSED]     = 6,
    [ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS]     = 7, [ITEM_TRAIT_TYPE_ARMOR_DIVINES]     = 8,
    [ITEM_TRAIT_TYPE_ARMOR_NIRNHONED]      = 9,

    [ITEM_TRAIT_TYPE_JEWELRY_ARCANE]       = 1, [ITEM_TRAIT_TYPE_JEWELRY_HEALTHY]   = 2,
    [ITEM_TRAIT_TYPE_JEWELRY_ROBUST]       = 3, [ITEM_TRAIT_TYPE_JEWELRY_TRIUNE]    = 4,
    [ITEM_TRAIT_TYPE_JEWELRY_INFUSED]      = 5, [ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE]= 6,
    [ITEM_TRAIT_TYPE_JEWELRY_SWIFT]        = 7, [ITEM_TRAIT_TYPE_JEWELRY_HARMONY]   = 8,
    [ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = 9,
}

-- ---------------------------------------------------------------------------
-- Detection + decoding
-- ---------------------------------------------------------------------------
local function LooksLikeMasterWrit(name)
    if not name then return false end
    local n = zo_strlower(name)
    -- Broadened: real names may be "Sealed Woodworking Writ" etc, not
    -- literally containing "master". Match "sealed" + "writ", or "master
    -- writ" as a fallback for any other naming pattern.
    if n:find("sealed") and n:find("writ") then return true end
    if n:find("master writ") then return true end
    return false
end

-- Decode a writ item link's hidden fields via the base-game link parser.
local function DecodeWritLink(itemLink)
    local parts = { ZO_LinkHandler_ParseLink(itemLink) }
    return {
        writ1 = tonumber(parts[10]),  -- item slot
        writ5 = tonumber(parts[14]),  -- trait
        writ6 = tonumber(parts[15]),  -- motif
    }
end

-- ---------------------------------------------------------------------------
-- The actual check
-- ---------------------------------------------------------------------------
-- Returns: status ("ready" | "not_ready" | "unknown"), itemName, traitName, reasons[]
local function CheckWrit(itemLink)
    local fields = DecodeWritLink(itemLink)
    if not fields.writ1 or not fields.writ5 then
        Dbg("Link didn't decode into writ fields - not a recognized writ format")
        return "unknown"
    end

    local entry = ITEM_TABLE[fields.writ1]
    if not entry then
        Dbg("Unknown item slot number: " .. tostring(fields.writ1))
        return "unknown"
    end
    local school, researchLine, itemName, motifPage = entry[1], entry[2], entry[3], entry[4]

    local traitIndex = TRAIT_INDEX[fields.writ5]
    if not traitIndex then
        Dbg("Unknown trait constant: " .. tostring(fields.writ5))
        return "unknown"
    end
    local traitName = GetString("SI_ITEMTRAITTYPE", fields.writ5) or "trait"

    local ok, _, _, traitKnown = pcall(GetSmithingResearchLineTraitInfo, school.skill, researchLine, traitIndex)
    if not ok then
        Dbg("GetSmithingResearchLineTraitInfo failed: " .. tostring(traitKnown))
        return "unknown"
    end

    local reasons = {}
    if not traitKnown then
        table.insert(reasons, string.format("%s not researched on %s", traitName, itemName))
    end

    -- Style/motif: real check via LibCharacterKnowledge, using the item's
    -- actual style-chapter "page" (motifPage) as WritWorthy's own source
    -- confirmed is required alongside the motif number itself.
    local motifName = nil
    if fields.writ6 and fields.writ6 > 0 and school.motif then
        motifName = WritWorthy and WritWorthy.Motif and WritWorthy.Motif(fields.writ6)
            or GetString("SI_ITEMSTYLE" .. tostring(fields.writ6))
            or ("style #" .. fields.writ6)

        if not motifPage then
            table.insert(reasons, string.format("style requirement (%s) not checked - jewelry has no style chapter to verify against", tostring(motifName)))
        elseif LibCharacterKnowledge and LibCharacterKnowledge.GetMotifKnowledgeForCharacter then
            local ok2, knowledge = pcall(LibCharacterKnowledge.GetMotifKnowledgeForCharacter, fields.writ6, motifPage)
            if ok2 and knowledge ~= nil then
                if knowledge ~= LibCharacterKnowledge.KNOWLEDGE_KNOWN then
                    table.insert(reasons, string.format("style not known: %s", tostring(motifName)))
                end
            else
                Dbg("GetMotifKnowledgeForCharacter failed: " .. tostring(knowledge))
                table.insert(reasons, string.format("style requirement (%s) - couldn't verify, check yourself", tostring(motifName)))
            end
        else
            table.insert(reasons, string.format("style requirement (%s) not checked - LibCharacterKnowledge not found", tostring(motifName)))
        end
    end

    local status = (#reasons == 0) and "ready" or "not_ready"
    return status, itemName, traitName, reasons
end

-- ---------------------------------------------------------------------------
-- Inventory scan -> chat report
-- ---------------------------------------------------------------------------
local function DisplayName(bag, slot, link)
    -- GetItemName can come back blank for specially-encoded items like
    -- writs. GetItemLinkName reads the link itself and is more reliable
    -- for these; fall back through both before giving up.
    local n = GetItemLinkName and GetItemLinkName(link)
    if n and n ~= "" then return n end
    if bag and slot then
        n = GetItemName and GetItemName(bag, slot)
        if n and n ~= "" then return n end
    end
    return "Unknown Writ"
end

-- Report one writ link's status as a chat block. Shared by bag scans and
-- trading house scans so the report format is identical everywhere.
local function ReportOne(name, link)
    local status, itemName, traitName, reasons = CheckWrit(link)
    if status == "unknown" then
        Msg(string.format("%s - couldn't check (unsupported writ type)", name))
    elseif status == "ready" then
        Msg(string.format("|c66FF66READY|r  %s (%s, %s)", name, itemName, traitName))
    else
        Msg(string.format("|cFF6666NOT READY|r  %s", name))
        for _, reason in ipairs(reasons) do
            Msg("    - " .. reason)
        end
    end
end

-- Scan one bag (backpack or bank) for writs.
local function ScanBag(bagId, label)
    local numSlots = GetBagSize(bagId)
    if not numSlots then return 0 end
    local found = 0

    for slot = 0, numSlots - 1 do
        local link = GetItemLink(bagId, slot)
        if link and link ~= "" then
            -- Detect by decoding the link itself, not by name - the name
            -- lookup is unreliable for writs, but the link's hidden fields
            -- (writ1/writ5) are always present on a real writ link.
            local fields = DecodeWritLink(link)
            if fields.writ1 and fields.writ5 and ITEM_TABLE[fields.writ1] then
                found = found + 1
                ReportOne(DisplayName(bagId, slot, link) .. (label and (" [" .. label .. "]") or ""), link)
            end
        end
    end
    return found
end

local function ScanAndReport(includeBank)
    local found = ScanBag(BAG_BACKPACK)

    if includeBank then
        found = found + ScanBag(BAG_BANK, "bank")
        if BAG_SUBSCRIBER_BANK then
            found = found + ScanBag(BAG_SUBSCRIBER_BANK, "ESO+ bank")
        end
    end

    if found == 0 then
        Msg("No Master Writs found" .. (includeBank and " in inventory or bank." or " in your inventory."))
    end
end

-- ---------------------------------------------------------------------------
-- Guild trader (Trading House) search results
-- ---------------------------------------------------------------------------
local function ScanTradingHouseResults(numItemsOnPage)
    local found = 0
    for i = 1, (numItemsOnPage or 0) do
        local ok, link = pcall(GetTradingHouseSearchResultItemLink, i, LINK_STYLE_DEFAULT)
        if not ok or not link or link == "" then
            Dbg(string.format("result %d: link fetch failed (%s)", i, tostring(link)))
        else
            local fields = DecodeWritLink(link)
            local name = DisplayName(nil, nil, link)
            -- Always show what we decoded, even for non-matches, so a
            -- wrong-position decode is visible rather than silent.
            Dbg(string.format("result %d [%s]: writ1=%s writ5=%s writ6=%s",
                i, tostring(name), tostring(fields.writ1), tostring(fields.writ5), tostring(fields.writ6)))

            if fields.writ1 and fields.writ5 and ITEM_TABLE[fields.writ1] then
                found = found + 1
                ReportOne(name .. " [trader]", link)
            end
        end
    end
    Msg(string.format("Trader scan complete: %d result(s), %d recognized writ(s).", numItemsOnPage or 0, found))
    if found == 0 and (numItemsOnPage or 0) > 0 then
        Msg("None matched a known Smithing/Clothier/Woodworking/Jewelry writ slot - turn on /writready debug and search again to see raw decoded values.")
    end
end

local function OnTradingHouseResultsReceived(_, guildId, numItemsOnPage, currentPage, hasMorePages)
    -- Unconditional (not debug-gated) so we can confirm the event fires at all.
    Msg(string.format("Trader results received: %d item(s) on this page.", numItemsOnPage or 0))
    if not sv or not sv.enabled then return end
    -- Known timing quirk: reading results the instant this event fires can
    -- return blank data. A short delay avoids it (same fix used elsewhere).
    zo_callLater(function() ScanTradingHouseResults(numItemsOnPage) end, 50)
end

-- ---------------------------------------------------------------------------
-- Fallback: poll for trading house results instead of relying solely on the
-- event above. Console addon events have repeatedly diverged from documented
-- PC behavior in this project, so this sidesteps the question of whether
-- EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED fires here at all. Cheap: one
-- link fetch per second, only meaningful while a trader search is showing
-- results, and only reports when the visible result set actually changes.
-- ---------------------------------------------------------------------------
local lastPollSignature = nil
local POLL_NAME = "WritReady_TraderPoll"

local function PollTradingHouse()
    local ok, firstLink = pcall(GetTradingHouseSearchResultItemLink, 1, LINK_STYLE_DEFAULT)
    if not ok or not firstLink or firstLink == "" then
        lastPollSignature = nil  -- no results currently showing
        return
    end

    -- Cheap signature: how many results are visible, keyed off item 1's
    -- link. Good enough to detect "the result set changed" without a full
    -- rescan every second.
    local count = 0
    for i = 1, 50 do
        local ok2, link2 = pcall(GetTradingHouseSearchResultItemLink, i, LINK_STYLE_DEFAULT)
        if ok2 and link2 and link2 ~= "" then count = count + 1 else break end
    end
    local signature = firstLink .. "|" .. count

    if signature ~= lastPollSignature then
        lastPollSignature = signature
        Dbg("Poll detected new/changed trader results (" .. count .. " items) - scanning.")
        ScanTradingHouseResults(count)
    end
end

-- Polling permanently removed: even calling GetTradingHouseSearchResultItemLink
-- once a second in the background (regardless of screen visibility) was
-- confirmed to corrupt the trading house detail panel later. The
-- EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED event alone has been confirmed
-- to work correctly for auto-reporting trader results, so nothing is lost.
local function StartTraderPolling()
    EVENT_MANAGER:UnregisterForUpdate(POLL_NAME)
    -- intentionally not re-registered
end

-- ---------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------
local function RegisterSlash()
    SLASH_COMMANDS["/writready"] = function(args)
        args = zo_strtrim(args or "")
        local cmd = zo_strlower(args)
        if cmd == "on" then sv.enabled = true; Msg("Enabled")
        elseif cmd == "off" then sv.enabled = false; Msg("Disabled")
        elseif cmd == "debug" then sv.debug = not sv.debug; Msg("debug=" .. tostring(sv.debug))
        elseif cmd == "bank" then ScanAndReport(true)
        elseif cmd == "trader" then
            local ok, count = pcall(function()
                local n = 0
                for i = 1, 50 do
                    local ok2, link2 = pcall(GetTradingHouseSearchResultItemLink, i, LINK_STYLE_DEFAULT)
                    if ok2 and link2 and link2 ~= "" then n = n + 1 else break end
                end
                return n
            end)
            if not ok or not count or count == 0 then
                Msg("No trader search results found. Open a guild trader, search for writs, then run /writready trader.")
            else
                ScanTradingHouseResults(count)
            end
        else ScanAndReport(false) end
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

    LAM:RegisterAddonPanel("WritReadyPanel", {
        type = "panel", name = "Writ Ready",
        author = "@Dicen95728", version = "3.20", registerForRefresh = true,
    })
    LAM:RegisterOptionControls("WritReadyPanel", {
        { type = "checkbox", name = "Enabled",
          getFunc = function() return sv.enabled end,
          setFunc = function(v) sv.enabled = v end },
        { type = "button", name = "Scan inventory now",
          func = ScanAndReport },
        { type = "description",
          text = "Checks trait research. Style/motif checking needs LibCharacterKnowledge, which may not be on console." },
    })
end

-- ---------------------------------------------------------------------------
-- Init
-- ---------------------------------------------------------------------------
local function OnAddOnLoaded(_, addOnName)
    if addOnName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("WritReadySV", 1, nil, defaults)

    RegisterSlash()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_TRADING_HOUSE_SEARCH_RESULTS_RECEIVED, OnTradingHouseResultsReceived)
    StartTraderPolling()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
        if not panelBuilt then BuildSettingsPanel() end
        end)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
