local ADDON_TITLE   = "Covetous Countess Assistant"
local ADDON_NAME    = "CovetousCountessAssistant"
local ADDON_AUTHOR  = "@AlexD"
local ADDON_VERSION = "1.0.0"
local ADDON_WEBSITE = "https://www.esoui.com/downloads/info4778-CovetousCountessAssistant.html"
local SV_VERSION    = 1

local SLASH_TRACK_COUNTESS = "/ccatrackcountess" -- toggle Covetous Countess tracking
local SLASH_TRACK_CROW     = "/ccatrackcrow"     -- toggle Bursar of Tributes tracking
local SLASH_TRACK_STATUS   = "/ccatrackstatus"   -- show addon status

CovetousCountessAssistant = CovetousCountessAssistant or {}
local CCA                 = CovetousCountessAssistant

-- Cached ESO globals / functions
local EM                            = EVENT_MANAGER
local GetItemLink                   = GetItemLink
local GetItemLinkNumItemTags        = GetItemLinkNumItemTags
local GetItemLinkItemTagInfo        = GetItemLinkItemTagInfo
local ZO_ColorDef                   = ZO_ColorDef
local ZO_ScrollList_RefreshVisible  = ZO_ScrollList_RefreshVisible
local zo_strformat                  = zo_strformat
local GetString                     = GetString
local ZO_SavedVars                  = ZO_SavedVars
local tinsert                       = table.insert
local tremove                       = table.remove

--[[
Treasure categories used by The Covetous Countess:
https://en.uesp.net/wiki/Online:Treasures
https://en.uesp.net/wiki/Online:The_Covetous_Countess
- Games, Dolls, and Statues
- Ritual Objects and Oddities
- Writings (inc. Scrivener Supplies) and Maps
- Cosmetics, Linens (Dry Goods), and Wardrobe Accessories
- Drinkware, Utensils, and Dishes and Cookware
--]]
local COUNTESS_DUMMY_IDS = {
    ["Collectibles"]                = {
        ["Games"]                   = "61630",
        ["Dolls"]                   = "64365",
        ["Statues"]                 = "61536",
    },
    [ "Curiosities" ]               = {
        ["Ritual Objects"]          = "64413",
        ["Oddities"]                = "61442",
        ["Magic Curiosities"]       = "64389",
    },
    [ "Documents" ]                 = {
        ["Writings"]                = "61207",
        ["Scrivener Supplies"]      = "62584",
        ["Maps"]                    = "62081",
    },
    [ "Accessories" ]               = {
        ["Cosmetics"]               = "63157",
        ["Dry Goods"]               = "61382",
        ["Wardrobe Accessories"]    = "61107",
    },
    [ "Kitchenware" ]               = {
        ["Drinkware"]               = "61458",
        ["Utensils"]                = "64326",
        ["Dishes and Cookware"]     = "61263",
    },
}

--[[
Treasure categories used by Bursar of Tributes (Crow):
https://en.uesp.net/wiki/Online:Bursar_of_Tributes
- A Matter of Leisure: toys, dolls or games
- A Matter of Respect: utensils, drinkware, dishes or cookware
- A Matter of Tributes: cosmetics and grooming supplies
--]]
local CROW_DUMMY_IDS = {
    ["Leisure"]                     = {
        ["Games"]                   = "61630",
        ["Dolls"]                   = "64365",
        ["Children's Toys"]         = "64325",
    },
    ["Respect"]     = {
        ["Drinkware"]               = "61458",
        ["Utensils"]                = "64326",
        ["Dishes and Cookware"]     = "61263",
    },
    ["Tributes"]    = {
        ["Cosmetics"]               = "63157",
        ["Grooming Items"]          = "62810",
    },
}

-- Quest IDs (reserved for future quest-aware highlighting)
local QUEST_NAME_ID = {
    ["The Covetous Countess"]   = 5584,
    ["A Matter of Respect"]     = 6072,
    ["A Matter of Tributes"]    = 6106,
    ["A Matter of Leisure"]     = 6107,
}
local QUEST_ID = {
    [5584] = true, -- The Covetous Countess
    [6072] = true, -- A Matter of Respect
    [6106] = true, -- A Matter of Tributes
    [6107] = true, -- A Matter of Leisure
}

local FENCE_ICON                = "/esoui/art/icons/servicemappins/servicepin_fence.dds"
local FENCE_ICON_COLOR_WHITE    = ZO_ColorDef:New("FFFFFF")
local FENCE_ICON_COLOR_ORANGE   = ZO_ColorDef:New("FF6600")
local FENCE_ICON_COLOR_RED      = ZO_ColorDef:New("FF3333")

local USED_ICONS = { [FENCE_ICON] = true, }

----------------------------------------------------------------------
-- Localization cache
-- https://wiki.esoui.com/How_to_add_localization_support
-- dynamically change the language ingame via a slash command in the chat editbox:
-- /script SetCVar("language.2", "de")
--[[
Languages:
de	German
en	English
es	Spanish
fr	French
ru	Russian
jp	Japanese
zh	Chinese Simplified
br	Portugese
it	Italian
kr	Korean
pl	Polish
th	Thai
tr	Turkish
ua	Ukrainian
--]]
----------------------------------------------------------------------
local STRINGS = {}

local function CacheLocalizedStrings()
    STRINGS.OPTION_TRACK_COUNTESS         = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS)
    STRINGS.OPTION_TRACK_COUNTESS_TOOLTIP = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP)
    STRINGS.OPTION_TRACK_CROW             = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW)
    STRINGS.OPTION_TRACK_CROW_TOOLTIP     = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP)
    STRINGS.SETTINGS                      = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS)
    STRINGS.MSG_COUNTESS_ON               = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON)
    STRINGS.MSG_COUNTESS_OFF              = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF)
    STRINGS.MSG_CROW_ON                   = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON)
    STRINGS.MSG_CROW_OFF                  = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF)
end

----------------------------------------------------------------------
-- Saved Variables + LibAddonMenu2 panel
----------------------------------------------------------------------
local function RefreshInventoryIcons()
    if not PLAYER_INVENTORY or not PLAYER_INVENTORY.inventories then return end
    local types = {
        INVENTORY_BACKPACK,
        INVENTORY_BANK,
        INVENTORY_GUILD_BANK,
        INVENTORY_HOUSE_BANK,
        INVENTORY_CRAFT_BAG,
    }
    for _, invType in ipairs(types) do
        local inv = PLAYER_INVENTORY.inventories[invType]
        if inv and inv.listView then
            ZO_ScrollList_RefreshVisible(inv.listView)
        end
    end
end

local function InitSettings()
    local defaults = {
        trackCountess = true,   -- track Covetous Countess treasure tags
        trackCrow     = false,  -- track Bursar of Tributes (Crow Store) treasure tags
    }

    local SV = ZO_SavedVars:NewAccountWide(ADDON_NAME .. "_SV", SV_VERSION, "Settings", defaults)
    CCA.SV = SV

    if not LibAddonMenu2 then return end

    local panelData = {
        type                 = "panel",
        name                 = ADDON_TITLE,
        displayName          = ADDON_TITLE,
        author               = ADDON_AUTHOR,
        version              = ADDON_VERSION,
        website              = ADDON_WEBSITE,
        registerForRefresh   = true,
        registerForDefaults  = true,
    }

    local options = {
        {
            type    = "checkbox",
            name    = STRINGS.OPTION_TRACK_COUNTESS,
            tooltip = STRINGS.OPTION_TRACK_COUNTESS_TOOLTIP,
            getFunc = function() return SV.trackCountess end,
            setFunc = function(v)
                SV.trackCountess = v
                RefreshInventoryIcons()
            end,
            default = defaults.trackCountess,
        },
        {
            type    = "checkbox",
            name    = STRINGS.OPTION_TRACK_CROW,
            tooltip = STRINGS.OPTION_TRACK_CROW_TOOLTIP,
            getFunc = function() return SV.trackCrow end,
            setFunc = function(v)
                SV.trackCrow = v
                RefreshInventoryIcons()
            end,
            default = defaults.trackCrow,
        },
    }

    LibAddonMenu2:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)
    LibAddonMenu2:RegisterOptionControls(ADDON_NAME .. "Panel", options)
end

----------------------------------------------------------------------
-- Treasure tag tables (built once at load)
----------------------------------------------------------------------
local COUNTESS_TAGS     = {} -- category -> { tag = true }
local COUNTESS_TAGS_SET = {} -- flat set
local CROW_TAGS         = {}
local CROW_TAGS_SET     = {}
local COMBINED_TAGS_SET = {}

-- itemLink -> tags table | false (no matching tags). Tags never change mid-session.
local tagCache          = {}

local function ToItemLink(itemId)
    if not itemId then return nil end
    return "|H0:item:" .. itemId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end

local function GetTreasureTags(itemLink)
    if not itemLink or itemLink == "" then return nil end

    local cached = tagCache[itemLink]
    if cached ~= nil then
        return cached or nil
    end

    local tags = {}
    local count = GetItemLinkNumItemTags(itemLink)
    for i = 1, count do
        local tag, category = GetItemLinkItemTagInfo(itemLink, i)
        if category == TAG_CATEGORY_TREASURE_TYPE and tag and tag ~= "" then
            tinsert(tags, zo_strformat(SI_TOOLTIP_ITEM_TAG_FORMATER, tag))
        end
    end

    local result = #tags > 0 and tags or false
    tagCache[itemLink] = result
    return result or nil
end

local function BuildTagTables(source, dest, flatSet)
    for category, items in pairs(source) do
        dest[category] = {}
        for _, dummyId in pairs(items) do
            local tags = GetTreasureTags(ToItemLink(dummyId))
            if tags then
                for _, tag in ipairs(tags) do
                    dest[category][tag] = true
                    flatSet[tag] = true
                end
            end
        end
    end
end

local function BuildTreasureTags()
    BuildTagTables(COUNTESS_DUMMY_IDS, COUNTESS_TAGS, COUNTESS_TAGS_SET)
    BuildTagTables(CROW_DUMMY_IDS, CROW_TAGS, CROW_TAGS_SET)

    for tag in pairs(COUNTESS_TAGS_SET) do COMBINED_TAGS_SET[tag] = true end
    for tag in pairs(CROW_TAGS_SET) do COMBINED_TAGS_SET[tag] = true end
end

local function IsTrackedTreasure(itemLink)
    local tags = GetTreasureTags(itemLink)
    if not tags then return false end

    local set
    if CCA.SV.trackCountess and CCA.SV.trackCrow then
        set = COMBINED_TAGS_SET
    elseif CCA.SV.trackCountess then
        set = COUNTESS_TAGS_SET
    elseif CCA.SV.trackCrow then
        set = CROW_TAGS_SET
    else
        return false
    end

    for _, t in ipairs(tags) do
        if set[t] then return true end
    end
    return false
end

----------------------------------------------------------------------
-- Inventory icon hooks
----------------------------------------------------------------------
-- PreHook: inject (or strip) our icon path into additionalIcons before vanilla runs.
ZO_PreHook("ZO_UpdateStatusControlIcons", function(inventorySlot, slotData)
    if not slotData or not slotData.bagId or not slotData.slotIndex then
        return false
    end

    local itemLink = GetItemLink(slotData.bagId, slotData.slotIndex)
    if not itemLink or itemLink == "" then return false end

    -- Prevent stacking on repeated redraws
    if slotData.additionalIcons then
        for i = #slotData.additionalIcons, 1, -1 do
            if USED_ICONS[slotData.additionalIcons[i]] then
                tremove(slotData.additionalIcons, i)
            end
        end
    end

    if IsTrackedTreasure(itemLink) then
        slotData.additionalIcons = slotData.additionalIcons or {}
        slotData.additionalIcons[#slotData.additionalIcons + 1] = FENCE_ICON
    end

    return false -- let vanilla continue
end)

-- PostHook: apply tint. Vanilla AddIcon takes only the path, so tint must be
-- set on iconData after the fact. Force hide/show so single-icon rows re-read tint.
-- (See zo_multiicon.lua: each iconData entry is { iconTexture, iconTint, iconNarration }).
ZO_PostHook("ZO_UpdateStatusControlIcons", function(inventorySlot, slotData)
    if not slotData or not slotData.additionalIcons then return end

    local hasOurs = false
    for _, icon in ipairs(slotData.additionalIcons) do
        if USED_ICONS[icon] then
            hasOurs = true
            break
        end
    end
    if not hasOurs then return end

    local statusControl = inventorySlot:GetNamedChild("StatusTexture")
    if not statusControl or not statusControl.iconData then return end

    local tinted = false
    -- TODO: Not implemented yet
    -- for _, data in ipairs(statusControl.iconData) do
    --     if data.iconTexture == FENCE_ICON and data.iconTint ~= FENCE_ICON_COLOR_RED then
    --         data.iconTint = FENCE_ICON_COLOR_RED
    --         tinted = true
    --     end
    -- end

    if tinted then
        statusControl:SetHidden(true)
        statusControl:SetHidden(false)
    end
end)

----------------------------------------------------------------------
-- Diagnostics
----------------------------------------------------------------------
local function CountEntries(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

function CCA.CheckTreasureTagsLoaded()
    local expectedCountess, expectedCrow = 0, 0
    for _, items in pairs(COUNTESS_DUMMY_IDS) do
        expectedCountess = expectedCountess + CountEntries(items)
    end
    for _, items in pairs(CROW_DUMMY_IDS) do
        expectedCrow = expectedCrow + CountEntries(items)
    end
    return CountEntries(COUNTESS_TAGS_SET) == expectedCountess
        and CountEntries(CROW_TAGS_SET) == expectedCrow
end

----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------
local function ToggleTrackCountess()
    CCA.SV.trackCountess = not CCA.SV.trackCountess
    RefreshInventoryIcons()
    local msg = CCA.SV.trackCountess and STRINGS.MSG_COUNTESS_ON or STRINGS.MSG_COUNTESS_OFF
    if msg and msg ~= "" then
        d("[" .. ADDON_TITLE .. "] " .. msg)
    else
        d(string.format("[%s] Covetous Countess tracking: %s",
            ADDON_TITLE, CCA.SV.trackCountess and "ON" or "OFF"))
    end
end

local function ToggleTrackCrow()
    CCA.SV.trackCrow = not CCA.SV.trackCrow
    RefreshInventoryIcons()
    local msg = CCA.SV.trackCrow and STRINGS.MSG_CROW_ON or STRINGS.MSG_CROW_OFF
    if msg and msg ~= "" then
        d("[" .. ADDON_TITLE .. "] " .. msg)
    else
        d(string.format("[%s] Bursar of Tributes tracking: %s",
            ADDON_TITLE, CCA.SV.trackCrow and "ON" or "OFF"))
    end
end

local function ShowTrackingStatus()
    local sv = CCA.SV

    local function getStatus(isActive, msgOn, msgOff, label)
        local customMsg = isActive and msgOn or msgOff
        if customMsg and customMsg ~= "" then return customMsg end
        return string.format("%s tracking: %s", label, isActive and "ON" or "OFF")
    end

    local countess = getStatus(sv.trackCountess, STRINGS.MSG_COUNTESS_ON, STRINGS.MSG_COUNTESS_OFF, "Countess")
    local crow = getStatus(sv.trackCrow, STRINGS.MSG_CROW_ON, STRINGS.MSG_CROW_OFF, "Bursar of Tributes")

    d(string.format("[%s]\n%s\n%s", ADDON_TITLE, countess, crow))
end

SLASH_COMMANDS[SLASH_TRACK_COUNTESS] = ToggleTrackCountess
SLASH_COMMANDS[SLASH_TRACK_CROW]     = ToggleTrackCrow
SLASH_COMMANDS[SLASH_TRACK_STATUS]   = ShowTrackingStatus

----------------------------------------------------------------------
-- Load
----------------------------------------------------------------------
local function OnPlayerActivated()
    EM:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)
    if not CCA.CheckTreasureTagsLoaded() then
        d("[" .. ADDON_NAME .. "] Missing treasure tags — please report to the author.")
    end
end

local function OnLoaded(_, name)
    if name ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    EM:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    CacheLocalizedStrings()
    InitSettings()
    BuildTreasureTags()
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)
