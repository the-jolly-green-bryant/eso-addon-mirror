local ADDON_TITLE   = "Covetous Countess Assistant"
local ADDON_NAME    = "CovetousCountessAssistant"
local ADDON_AUTHOR  = "@AlexD"
local ADDON_VERSION = "1.2.1"
local ADDON_WEBSITE = "https://www.esoui.com/downloads/info4778-CovetousCountessAssistant.html"
local SV_VERSION    = 1
local LANGUAGE_CVAR = "Language.2"

local SLASH_TRACK_SETTINGS  = "/ccatracksettings"  -- opens settings
local SLASH_TRACK_STATUS    = "/ccatrackstatus"    -- show status
local SLASH_TRACK_COUNTESS  = "/ccatrackcountess"  -- toggle Covetous Countess tracking
local SLASH_TRACK_CROW      = "/ccatrackcrow"      -- toggle Bursar of Tributes tracking
local SLASH_TRACK_HIGHLIGHT = "/ccatrackhighlight" -- toggle highlight
local SLASH_TRACK_AUTOSKIP  = "/ccatrackautoskip"  -- toggle Tip Board auto-skip

local CCA = {}

-- debugging
local DEBUG = false

local function ddebug(...)
    if not DEBUG then return end

    local n = select("#", ...)
    if n == 0 then
        return
    elseif n == 1 then
        d(...)
    else
        d(string.format(...)) -- first arg = format string, rest = values
    end
end

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
local tconcat                       = table.concat

local string_lower                  = zo_strlower
local string_sub                    = zo_strsub
local string_len                    = string.len
local string_byte                   = string.byte
local string_gsub                   = string.gsub
local string_format                 = string.format
local table_insert                  = table.insert
local table_concat                  = table.concat

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
    ["Curiosities"]                 = {
        ["Ritual Objects"]          = "64413",
        ["Oddities"]                = "61442",
        -- ["Magic Curiosities"]       = "64389", -- does not count as a curiosity
    },
    ["Documents"]                   = {
        ["Writings"]                = "61207",
        ["Scrivener Supplies"]      = "62584",
        ["Maps"]                    = "62081",
    },
    ["Accessories"]                 = {
        ["Cosmetics"]               = "63157",
        ["Dry Goods"]               = "61382",
        ["Wardrobe Accessories"]    = "61107",
    },
    ["Kitchenware"]                 = {
        ["Drinkware"]               = "61458",
        ["Utensils"]                = "64326",
        ["Dishes and Cookware"]     = "61263",
    },
}

local MAPS_DUMMY_IDS = {
    ["Collectibles"] = { ["Davon's Watch"] = "24",  },
    ["Curiosities"]  = { ["Mournhold"]     = "205", },
    ["Documents"]    = { ["Stormhold"]     = "217", },
    ["Accessories"]  = { ["Windhelm"]      = "160", },
    ["Kitchenware"]  = { ["Riften"]        = "198", },
}

local COUNTESS_EXTRA_TAGS = {
    ["jp"] = {
        ["Collectibles"]                = {
            ["Games"]                   = "ゲーム",
            ["Dolls"]                   = "人形",
            ["Statues"]                 = "像",
        },
        ["Curiosities"]                 = {
            ["Ritual Objects"]          = "儀式用品",
            ["Oddities"]                = { "半端もの", "奇妙な品" },
        },
        ["Documents"]                   = {
            ["Writings"]                = "文書",
            ["Maps"]                    = { "マップ", "地図" },
        },
        ["Accessories"]  = {
            ["Cosmetics"]               = "化粧品",
            ["Dry Goods"]               = "下着",
            ["Wardrobe Accessories"]    = { "小物", "服飾小物" },
        },
        ["Kitchenware"]  = {
            ["Drinkware"]               = "カップ",
            ["Utensils"]                = { "台所器具", "台所用品" },
            ["Dishes and Cookware"]     = "皿",
        },
    },
    ["zh"] = {
        ["Collectibles"]                = {
            ["Games"]                   = "玩具",
            ["Dolls"]                   = "玩偶",
            ["Statues"]                 = "雕像",
        },
        ["Curiosities"]                 = {
            ["Ritual Objects"]          = "仪式物品",
            ["Oddities"]                = "奇异物品",
        },
        ["Documents"]                   = {
            ["Writings"]                = "文字作品",
            ["Maps"]                    = "地图",
        },
        ["Accessories"]  = {
            ["Cosmetics"]               = "装扮品",
            ["Dry Goods"]               = "织物",
            ["Wardrobe Accessories"]    = { "配件", "其他物品" },
        },
        ["Kitchenware"]  = {
            ["Drinkware"]               = "杯具",
            ["Utensils"]                = "器皿",
            ["Dishes and Cookware"]     = "盘子",
        }
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
    ["Respect"]                     = {
        ["Drinkware"]               = "61458",
        ["Utensils"]                = "64326",
        ["Dishes and Cookware"]     = "61263",
    },
    ["Tributes"]                    = {
        ["Cosmetics"]               = "63157",
        ["Grooming Items"]          = "62810",
    },
}

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

-- Unlike the Countess, each Crow (Bursar of Tributes) quest always wants a
-- fixed, known category -- no fuzzy text matching required.
local CROW_QUEST_CATEGORY = {
    [6072] = "Respect",  -- A Matter of Respect
    [6106] = "Tributes", -- A Matter of Tributes
    [6107] = "Leisure",  -- A Matter of Leisure
}

local FENCE_ICON                = "/esoui/art/icons/servicemappins/servicepin_fence.dds"
local FENCE_ICON_COLOR_WHITE    = ZO_ColorDef:New("FFFFFF")
local FENCE_ICON_COLOR_GREEN    = ZO_ColorDef:New("00FF00")

local USED_ICONS = { [FENCE_ICON] = true, }

local TIPBOARD_TARGET_NAMES           = {
    -- en
    ["Tip Board"] = true,
    -- de
    ["Brett für Aufträge"] = true,
    -- fr
    ["Tableau des tuyaux"] = true,
    -- es
    ["Tablón de informes"] = true,
    -- ru
    ["Доска объявлений"] = true,
    -- jp
    ["ジョブボード"] = true,
    -- zh
    ["提示板"] = true,
}

local TIPBOARD_SKIP_RESPONSES         = {
    -- en
    ["<Keep reading.>"] = true,
    ["<Make a note of the request.>"] = true,

    -- de
    ["<Weiterlesen.>"] = true,
    ["<Weiterlesen>"] = true,
    ["<Diese Anfrage vermerken.>"] = true,

    -- fr
    ["<Continuer à lire.>"] = true,
    ["<Prendre note de la requête.>"] = true,

    -- es
    ["<Continuar leyendo.>"] = true,
    ["<Apuntar la petición.>"] = true,

    -- ru
    ["<Продолжить чтение.>"] = true,
    ["<Записать подробности.>"] = true,

    -- jp
    ["<続きを読む>"] = true,
    ["<要求をメモする>"] = true,

    -- zh
    ["<继续阅读。>"] = true,
    ["<记下任务要求。>"] = true,
}

--[[
local TIPBOARD_COUNTESS_RESPONSES     = {
    -- en
    ["<Read the contract.>"] = true,

    -- de
    ["<Den Kontrakt lesen.>"] = true,

    -- fr
    ["<Lire le contrat.>"] = true,

    -- es
    ["<Leer el contrato.>"] = true,

    -- ru
    ["<Прочесть контракт.>"] = true,

    -- jp
    ["<契約書を読む>"] = true,

    -- zh
    ["<阅读契约>"] = true,
}
--]]

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
    STRINGS.OPTION_TRACK_COUNTESS 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS)
    STRINGS.OPTION_TRACK_COUNTESS_TOOLTIP 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP)
    STRINGS.OPTION_TRACK_CROW 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW)
    STRINGS.OPTION_TRACK_CROW_TOOLTIP 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP)
    STRINGS.OPTION_HIGHLIGHT_QUEST_ITEMS
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS)
    STRINGS.OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = GetString(
        SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP)
    STRINGS.OPTION_AUTOSKIP_TIPBOARD
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD)
    STRINGS.OPTION_AUTOSKIP_TIPBOARD_TOOLTIP 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP)
    STRINGS.OPTION_AUTOSKIP_TIPBOARD_WARNING 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING)
    STRINGS.SETTINGS 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS)
    STRINGS.MSG_COUNTESS_ON 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON)
    STRINGS.MSG_COUNTESS_OFF 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF)
    STRINGS.MSG_CROW_ON 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON)
    STRINGS.MSG_CROW_OFF 
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF)
    STRINGS.MSG_AUTOSKIP_ON
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON)
    STRINGS.MSG_AUTOSKIP_OFF
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF)
    STRINGS.MSG_HIGHLIGHT_ON
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON)
    STRINGS.MSG_HIGHLIGHT_OFF
        = GetString(SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF)
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
        local listView = inv and inv.listView
        if listView and not listView:IsHidden() then
            ZO_ScrollList_RefreshVisible(listView)
        end
    end
end

local function InitSettings()
    local defaults = {
        trackCountess       = true,
        trackCrow           = false,
        highlightQuestItems = true,
        autoSkipTipBoard    = false,
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
        slashCommand         = SLASH_TRACK_SETTINGS,
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
        {
            type    = "checkbox",
            name    = STRINGS.OPTION_HIGHLIGHT_QUEST_ITEMS,
            tooltip = STRINGS.OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP,
            getFunc = function() return SV.highlightQuestItems end,
            setFunc = function(v)
                SV.highlightQuestItems = v
                RefreshInventoryIcons()
            end,
            default = defaults.highlightQuestItems,
        },
        {
            type    = "checkbox",
            name    = STRINGS.OPTION_AUTOSKIP_TIPBOARD,
            tooltip = STRINGS.OPTION_AUTOSKIP_TIPBOARD_TOOLTIP,
            warning = STRINGS.OPTION_AUTOSKIP_TIPBOARD_WARNING,
            getFunc = function() return SV.autoSkipTipBoard end,
            setFunc = function(v) SV.autoSkipTipBoard = v end,
            default = defaults.autoSkipTipBoard,
        },
    }

    LibAddonMenu2:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)
    LibAddonMenu2:RegisterOptionControls(ADDON_NAME .. "Panel", options)
end

----------------------------------------------------------------------
-- Treasure tag tables (built once at load)
----------------------------------------------------------------------
local COUNTESS_CITIES   = {}
local COUNTESS_TAGS     = {} -- category -> { tag = true }
local COUNTESS_TAGS_SET = {} -- flat set
local CROW_TAGS         = {}
local CROW_TAGS_SET     = {}
local COMBINED_TAGS_SET = {}

local ACTIVE_QUESTS_ID   = {}
local ACTIVE_QUESTS_TAGS = {}

-- itemLink -> tags table | false (no matching tags). Tags never change mid-session.
local tagCache          = {}

local function ToItemLink(itemId)
    if not itemId then return nil end
    return "|H0:item:" .. itemId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
end

local function NormalizeLanguageKey(lang)
    if not lang or lang == "" then return "en" end
    local key = string_lower(string_sub(lang, 1, 2))
    if key == "ja" then return "jp" end
    if key == "ko" then return "kr" end
    if key == "pt" then return "br" end
    return key
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
                if #tags ~= 1 then 
                    ddebug("[%s] unexpected tag count for dummyId %s: %d tags (tags: %s)", ADDON_NAME,
                    tostring(dummyId), #tags, table.concat(tags, ", ")) 
                end
                for _, tag in ipairs(tags) do
                    dest[category][tag] = true
                    flatSet[tag] = true
                    break -- only one tag per dummy
                end
            end
        end
    end
end

local function BuildCitiesNames(source, dest)
    for category, items in pairs(source) do
        dest[category] = {}
        for _, mapId in pairs(items) do
            local rawMapName = GetMapNameById(mapId)
            local mapName = ZO_CachedStrFormat(SI_ZONE_NAME, rawMapName)
            dest[category][mapName] = true
        end
    end
end

local function MergeExtraTags(langKey)
    local extraLang = COUNTESS_EXTRA_TAGS[langKey]
    if not extraLang then return end

    for category, items in pairs(extraLang) do
        COUNTESS_TAGS[category] = COUNTESS_TAGS[category] or {}
        for subCategory, tagOrTable in pairs(items) do
            if type(tagOrTable) == "table" then
                for _, tag in ipairs(tagOrTable) do
                    COUNTESS_TAGS[category][tag] = true
                    COUNTESS_TAGS_SET[tag] = true
                end
            else
                COUNTESS_TAGS[category][tagOrTable] = true
                COUNTESS_TAGS_SET[tagOrTable] = true
            end
        end
    end
end

local function BuildTreasureTags()
    BuildTagTables(COUNTESS_DUMMY_IDS, COUNTESS_TAGS, COUNTESS_TAGS_SET)
    BuildTagTables(CROW_DUMMY_IDS, CROW_TAGS, CROW_TAGS_SET)
    BuildCitiesNames(MAPS_DUMMY_IDS, COUNTESS_CITIES)

    -- Merge language-specific extra tags for JP/ZH
    local rawLang = GetCVar(LANGUAGE_CVAR)
    local langKey = NormalizeLanguageKey(rawLang)
    MergeExtraTags(langKey)

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

local function IsQuestItem(itemLink)
    if not itemLink or itemLink == "" then return false end
    local itemTags = GetTreasureTags(itemLink)

    local matchesQuest = false
    if itemTags then
        for _, questTags in pairs(ACTIVE_QUESTS_TAGS) do
            if questTags then
                for _, tag in ipairs(itemTags) do
                    if questTags[tag] then
                        matchesQuest = true
                        break
                    end
                end
            end
            if matchesQuest then break end     -- stop scanning quests too
        end
    end

    return matchesQuest
end

-- create local function to avoid globals for hooks
local function UpdateStatusControlIcons()

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

        local itemLink
        if slotData and slotData.bagId and slotData.slotIndex then
            itemLink = GetItemLink(slotData.bagId, slotData.slotIndex)
        end

        local color = (CCA.SV.highlightQuestItems and IsQuestItem(itemLink))
            and FENCE_ICON_COLOR_GREEN
            or FENCE_ICON_COLOR_WHITE

        local tinted = false
        for _, data in ipairs(statusControl.iconData) do
            if data.iconTexture == FENCE_ICON and data.iconTint ~= color then
                data.iconTint = color
                tinted = true
            end
        end

        if tinted then
            statusControl:SetHidden(true)
            statusControl:SetHidden(false)
        end
    end)

end

----------------------------------------------------------------------
-- Diagnostics
----------------------------------------------------------------------
local function CountEntries(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function CheckTreasureTagsLoaded()
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
-- Quests Tracking – simplified multi-order n-gram fuzzy matcher
--
-- Design (minimal normalization – game already provides consistent text):
--   1. N-grams generated PER TAG, then unioned into the category set.
--      No cross-tag grams.
--   2. CJK: character unigrams + bigrams; Latin/Cyrillic: 2+3.
--   3. NO character rewriting (no half-width/full-width, no dakuten).
--      Only strip control chars, punctuation and extra whitespace.
--   4. Coverage score = |category ∩ quest| / |category|
----------------------------------------------------------------------

-- Language → preferred n-gram orders
local NGRAM_ORDERS         = {
    zh = { 1, 2 }, -- Chinese
    jp = { 1, 2 }, -- Japanese
    -- kr = { 1, 2 }, -- Korean
    -- th = { 1, 2 }, -- Thai
    de = { 2, 3 },
    en = { 2, 3 },
    es = { 2, 3 },
    fr = { 2, 3 },
    ru = { 2, 3 },
    -- br = { 2, 3 },
    -- it = { 2, 3 },
    -- pl = { 2, 3 },
    -- tr = { 2, 3 },
    -- ua = { 2, 3 },
}

local DEFAULT_NGRAM_ORDERS = { 2, 3 }

-- Per-order gram weight: higher-order grams are more specific matches,
-- so they count for more. unigram = 1, bigram = 2, trigram = 3 ...
-- Tune freely; falls back to `n` itself for any order not listed here.
local NGRAM_ORDER_WEIGHT   = { [1] = 1, [2] = 5, [3] = 50 }

local MATCH_SCORE_FLOOR      = 0.08  -- floor for the plain-fraction score

----------------------------------------------------------------------
-- Multi-byte safe UTF-8 character iterator (Lua 5.1)
-- MUST be defined before any function that uses it.
----------------------------------------------------------------------
local function StringToChars(str)
    local chars = {}
    if not str or str == "" then return chars end

    local i = 1
    local len = string_len(str)

    while i <= len do
        local b = string_byte(str, i)
        local char_bytes = 1

        if b >= 0xC0 and b <= 0xDF then
            char_bytes = 2
        elseif b >= 0xE0 and b <= 0xEF then
            char_bytes = 3
        elseif b >= 0xF0 and b <= 0xF7 then
            char_bytes = 4
        end

        if i + char_bytes - 1 > len then
            char_bytes = 1
        end

        table_insert(chars, string_sub(str, i, i + char_bytes - 1))
        i = i + char_bytes
    end

    return chars
end

----------------------------------------------------------------------
-- Minimal safe normalizer
--   - lowercase (useful for Latin; harmless for CJK)
--   - trim + collapse whitespace
--   - strip ONLY pure ASCII control + punctuation (never touch 0x80+)
--   - strip common CJK punctuation
--   - for CJK: remove remaining spaces → continuous character stream
-- NO half-width / full-width / dakuten rewriting.
-- NEVER use %c or %p – they are locale-dependent and corrupt UTF-8.
----------------------------------------------------------------------

local function DumpBytes(label, s)
    local bytes = {}
    for i = 1, #s do
        bytes[#bytes + 1] = string.format("%02X", string.byte(s, i))
    end
    d(label .. ": " .. table.concat(bytes, " "))
end

local function NormalizeForNgrams(langKey, text)
    if not text then return "" end
    local s = tostring(text)
    
    -- Strip ESO formatting tags (|cFFFFFF, |t...|t, |H...|h, etc.)
    s = string_gsub(s, "|c%x%x%x%x%x%x", "")
    s = string_gsub(s, "|r", "")
    s = string_gsub(s, "|t.-|t", "")
    s = string_gsub(s, "|H.-|h", "")
    s = string_gsub(s, "|h", "")

    -- Lowercase ONLY for non-CJK languages
    if langKey ~= "zh" and langKey ~= "jp" and langKey ~= "kr" and langKey ~= "th" then
        s = string_lower(s)
    end

    -- UTF-8 Safe Control Char Stripping (Explicit byte numbers: 9=Tab, 10=LF, 13=CR)
    s = string_gsub(s, "\009", " ")
    s = string_gsub(s, "\010", " ")
    s = string_gsub(s, "\013", " ")

    -- Strip ONLY pure ASCII control (0x01-0x1F, 0x7F)
    -- Explicit byte ranges – never use %c (locale-dependent)
    -- NOTE: range must start at \1, not \0 — a literal NUL as a class
    -- range boundary is a MALFORMED PATTERN in Lua 5.1's gsub and throws
    -- "malformed pattern (missing ']')" on every single call, regardless
    -- of input. Game text won't contain real NULs anyway.
    s = string_gsub(s, "[\1-\31\127]", " ") -- removes controls

    -- Replace ASCII punctuation (including dots and commas) with spaces
    -- (Listed individually to avoid byte range UTF-8 corruption)
    s = string_gsub(s, "[-.,?!:*%+~#@^&()%[%]{}<>\"'_=/\\]", " ")

    -- In Lua 5.1 pattern classes, a trailing colon :] breaks character matching, causing the full-width colon to be ignored completely.

    -- UTF-8 Safe Quote Stripping (Explicit hex bytes, no bracket classes)
    s = string_gsub(s, "\194\171", " ") -- «
    s = string_gsub(s, "\194\187", " ") -- »
    s = string_gsub(s, "\226\128\152", " ") -- ‘
    s = string_gsub(s, "\226\128\153", " ") -- ’
    s = string_gsub(s, "\226\128\154", " ") -- ‚
    s = string_gsub(s, "\226\128\155", " ") -- ‛
    s = string_gsub(s, "\226\128\156", " ") -- “
    s = string_gsub(s, "\226\128\157", " ") -- ”
    s = string_gsub(s, "\226\128\158", " ") -- „
    s = string_gsub(s, "\226\128\159", " ") -- ‟
    s = string_gsub(s, "\226\128\185", " ") -- ‹
    s = string_gsub(s, "\226\128\186", " ") -- ›
    
    -- UTF-8 Safe CJK Punctuation (Explicit byte replacement outside of [...])
    s = string_gsub(s, "\227\128\129", " ") -- 、
    s = string_gsub(s, "\227\128\130", " ") -- 。
    s = string_gsub(s, "\239\188\140", " ") -- ，
    s = string_gsub(s, "\239\188\129", " ") -- ！
    s = string_gsub(s, "\239\188\159", " ") -- ？
    s = string_gsub(s, "\239\188\154", " ") -- ：
    s = string_gsub(s, "\227\128\140", " ") -- 「
    s = string_gsub(s, "\227\128\141", " ") -- 」
    s = string_gsub(s, "\227\128\142", " ") -- 『
    s = string_gsub(s, "\227\128\143", " ") -- 』
    s = string_gsub(s, "\227\128\144", " ") -- 【
    s = string_gsub(s, "\227\128\145", " ") -- 】
    s = string_gsub(s, "\227\128\158", " ") -- 〝
    s = string_gsub(s, "\227\128\159", " ") -- 〞

    -- In Lua 5.1, %d is locale-dependent via C's isdigit(). In multi-byte CJK encodings, the second or third byte of certain Japanese/Chinese characters happens to fall into the byte range that standard C library locale headers classify as "digits" or digit-adjacent encodings. When %d+ runs, it strips out those specific bytes from inside multi-byte characters, corrupting Japanese text.
    -- Strip numbers & counter formatting (e.g. 0/3)
    s = string_gsub(s, "[0-9]+", "")

    -- Strips non-breaking spaces (0xC2 0xA0) explicitly
    s = string_gsub(s, "\194\160", " ")

    -- Safe whitespace handling (explicit ASCII space " " instead of %s)
    if langKey == "zh" or langKey == "jp" or langKey == "kr" or langKey == "th" then
        -- Completely strip ASCII spaces for continuous CJK stream
        s = string_gsub(s, " ", "")
    else
        -- Collapse multiple ASCII spaces for Latin/Cyrillic
        s = string_gsub(s, " +", " ")
        -- Trim ASCII leading/trailing spaces
        s = string_gsub(s, "^ +", "")
        s = string_gsub(s, " +$", "")
    end

    return s
end

----------------------------------------------------------------------
-- Generate unique n-grams for one order (with short-string fallback)
----------------------------------------------------------------------
local function GetNgramsOfOrder(chars, n)
    local ngrams = {}
    local total = #chars
    if total == 0 then return ngrams end

    if n > total then
        -- Degenerate: whole string becomes one gram
        ngrams[table_concat(chars)] = true
        return ngrams
    end

    for i = 1, total - n + 1 do
        local gram = ""
        for j = 0, n - 1 do
            gram = gram .. chars[i + j]
        end
        ngrams[gram] = true
    end
    return ngrams
end

----------------------------------------------------------------------
-- Multi-order n-gram set (union)
----------------------------------------------------------------------
local function GetMultiNgrams(chars, orders)
    local ngrams = {}
    for _, n in ipairs(orders) do
        local set = GetNgramsOfOrder(chars, n)
        for g in pairs(set) do
            ngrams[g] = true
        end
    end
    return ngrams
end

----------------------------------------------------------------------
-- Build category → { [order] = n-gram-set }
-- CRITICAL: n-grams are generated PER TAG, then unioned per order.
-- No cross-tag grams are ever created. Sets are kept SEPARATE per order
-- (not merged together) so the scorer can apply a per-order weight.
----------------------------------------------------------------------
local function BuildCategoryNgramSetsByOrder(sourceTags, langKey, orders)
    local categorySets = {}

    for category, tags in pairs(sourceTags) do
        local catByOrder = {}
        for _, n in ipairs(orders) do
            catByOrder[n] = {}
        end

        for tag, _ in pairs(tags) do
            local norm = NormalizeForNgrams(langKey, tag)
            if norm and norm ~= "" then
                local chars = StringToChars(norm)
                for _, n in ipairs(orders) do
                    local tagNgrams = GetNgramsOfOrder(chars, n)
                    for g in pairs(tagNgrams) do
                        catByOrder[n][g] = true
                    end
                end
            end
        end

        categorySets[category] = catByOrder
    end

    return categorySets
end

----------------------------------------------------------------------
-- Weighted coverage score.
-- Sums weight (per NGRAM_ORDER_WEIGHT) instead of raw gram counts, so
-- bigram matches (more specific) count more than unigram matches.
--
-- score = Σ weight(matched) / Σ weight(category)
--
-- Returns score, weighted_intersection, weighted_total (last two are
-- handy for debug/tuning output).
----------------------------------------------------------------------
local function ScoreCoverageWeighted(catByOrder, questByOrder, orders)
    local weighted_intersection = 0
    local weighted_total = 0

    for _, n in ipairs(orders) do
        local weight = NGRAM_ORDER_WEIGHT[n] or n
        local catSet = catByOrder[n] or {}
        local qSet = questByOrder[n] or {}

        for gram in pairs(catSet) do
            weighted_total = weighted_total + weight
            if qSet[gram] then
                weighted_intersection = weighted_intersection + weight
            end
        end
    end

    if weighted_total == 0 then
        return 0, 0, 0
    end

    return weighted_intersection / weighted_total, weighted_intersection, weighted_total
end

----------------------------------------------------------------------
-- Cache for n-grams
----------------------------------------------------------------------

-- module-level cache, keyed by langKey
local categorySetCache = {}

local function GetCategorySets(sourceTags, langKey, orders)
    local cacheKey = langKey .. ":" .. (sourceTags == COUNTESS_TAGS and "tags" or "cities")
    local cached = categorySetCache[cacheKey]
    if cached then return cached end

    local built = BuildCategoryNgramSetsByOrder(sourceTags, langKey, orders)
    categorySetCache[cacheKey] = built
    return built
end

local questNgramCache = {}

local function GetQuestNgramsCached(normalizedText, langKey, orders)
    local cacheKey = langKey .. ":" .. normalizedText
    local cached = questNgramCache[cacheKey]
    if cached then
        return cached
    end

    local questChars = StringToChars(normalizedText)
    local questNgramsByOrder = {}
    for _, n in ipairs(orders) do
        questNgramsByOrder[n] = GetNgramsOfOrder(questChars, n)
    end

    questNgramCache[cacheKey] = questNgramsByOrder
    return questNgramsByOrder
end

----------------------------------------------------------------------
-- Main matcher
----------------------------------------------------------------------
local function FindMatchingGroup(questText, sourceTags, langKey)
    if not questText or questText == "" then
        return nil, 0
    end

    local orders = NGRAM_ORDERS[langKey] or DEFAULT_NGRAM_ORDERS

    -- Build per-category n-gram sets, kept separate per order (no cross-tag grams)
    local categorySets = GetCategorySets(sourceTags, langKey, orders)

    -- Quest n-grams (once)
    local normalizedText = NormalizeForNgrams(langKey, questText)

    if DEBUG then
        ddebug("Original text: " .. questText)
        ddebug("Normalized text: " .. normalizedText)
        -- DumpBytes("Original bytes", questText)
        -- DumpBytes("Normalized bytes", normalizedText)
    end

    local questNgramsByOrder = GetQuestNgramsCached(normalizedText, langKey, orders)

    local best_group_id = nil
    local max_score = -1
    local floor = MATCH_SCORE_FLOOR

    for group_id, catByOrder in pairs(categorySets) do
        local score, matched_w, total_w = ScoreCoverageWeighted(catByOrder, questNgramsByOrder, orders)
        if DEBUG then
            ddebug("DEBUG ngram: %s → %.3f  (matched_w=%d / total_w=%d)", tostring(group_id), score, matched_w, total_w)
            -- print category
            local tags = {}
            for tag in pairs(sourceTags[group_id]) do tinsert(tags, tag) end
            ddebug("DEBUG group: %s, tags: %s", group_id, table_concat(tags, ", "))
        end
        if score > max_score then
            max_score = score
            best_group_id = group_id
        end
    end

    if DEBUG then
        if best_group_id then
            local tags = {}
            for tag in pairs(sourceTags[best_group_id]) do tinsert(tags, tag) end
            ddebug("Best group: %s, score: %.3f, tags: %s",
                best_group_id, max_score, table_concat(tags, ", "))
        else
            ddebug("No matching group found (max_score below floor)")
        end
    end

    if max_score >= floor then
        return best_group_id, max_score
    end

    return nil, 0
end

----------------------------------------------------------------------
-- Public entry point
----------------------------------------------------------------------
local function FindBestGroup(questText, sourceTags)
    local rawLang = GetCVar(LANGUAGE_CVAR)
    local langKey = NormalizeLanguageKey(rawLang)
    return FindMatchingGroup(questText, sourceTags, langKey)
end

----------------------------------------------------------------------
-- Start (or refresh) tracking for a quest
----------------------------------------------------------------------

-- Temporarily disabled some languages.
-- The n-gram tables already contain orders for these languages, but the
-- matcher has not yet been fully validated / tuned against real quest text
-- in those locales.
local function IsLanguageSupported()
    return NGRAM_ORDERS[NormalizeLanguageKey(GetCVar(LANGUAGE_CVAR))] ~= nil
end

local function ActivateQuestTracking(questId, journalIndex)
    if not QUEST_ID[questId] then return end

    if not IsLanguageSupported() then return end

    ACTIVE_QUESTS_ID[questId] = true

    -- LDebug.PrintQuestDebugInfo(journalIndex)

    if questId == QUEST_NAME_ID["The Covetous Countess"] then
        local questText = ""
        local isDeliveryStep = false

        local rawLang = GetCVar(LANGUAGE_CVAR)
        local langKey = NormalizeLanguageKey(rawLang)

        local numSteps = GetJournalQuestNumSteps(journalIndex)

        if numSteps > 0 then
            isDeliveryStep = numSteps == 1
            for stepIndex = 1, numSteps do
                local stepText, _, _, _, numConditions =
                    GetJournalQuestStepInfo(journalIndex, stepIndex)
                if isDeliveryStep then
                    questText = questText .. " " .. stepText
                else 
                    if numConditions > 0 then
                        local conditionIndex = 1
                        local conditionText =
                            GetJournalQuestConditionInfo(journalIndex, stepIndex, conditionIndex)
                        questText = questText .. " " .. conditionText
                    end
                end
            end
        end

        if DEBUG then
            ddebug("Condition quest text: " .. questText)
            ddebug("IsDeliveryStep: " .. tostring(isDeliveryStep))
        end

        local sourceTags = isDeliveryStep and COUNTESS_CITIES or COUNTESS_TAGS

        local best_group_id, max_score = FindBestGroup(questText, sourceTags)

        if best_group_id then
            ACTIVE_QUESTS_TAGS[questId] = COUNTESS_TAGS[best_group_id]
        elseif not ACTIVE_QUESTS_TAGS[questId] then
            -- TODO: Add a warning message?
        end
    elseif CROW_QUEST_CATEGORY[questId] then
        -- Fixed category, no fuzzy matching needed.
        ACTIVE_QUESTS_TAGS[questId] = CROW_TAGS[CROW_QUEST_CATEGORY[questId]]
    end

    RefreshInventoryIcons()
end

-- Stop tracking a quest
local function DeactivateQuestTracking(questId)
    if not questId or not ACTIVE_QUESTS_ID[questId] then return end
    if not QUEST_ID[questId] then return end

    -- if not IsLanguageSupported() then return end

    ACTIVE_QUESTS_ID[questId] = nil
    ACTIVE_QUESTS_TAGS[questId] = nil

    RefreshInventoryIcons()
end

-- On load / zone-in: pick up any relevant quests already in the journal
local function ScanActiveQuests()
    local numQuests = GetNumJournalQuests()
    for journalIndex = 1, numQuests do
        if IsValidQuestIndex(journalIndex) then
            local questId = GetJournalQuestId(journalIndex)
            if QUEST_ID[questId] then
                ActivateQuestTracking(questId, journalIndex)
            end
        end
    end
end

local function OnQuestAdded(eventCode, journalIndex, questName, objectiveName)
    local questId = GetJournalQuestId(journalIndex)
    if QUEST_ID[questId] then
        if DEBUG then
            ddebug("[" .. ADDON_NAME .. "] OnQuestAdded: " .. questName)
        end
        ActivateQuestTracking(questId, journalIndex)
    end
end

local function OnQuestConditionCounterChanged(
    eventCode,                                   -- number
    journalIndex,                                -- number (luaindex)
    questName,                                   -- string
    conditionText,                               -- string
    conditionType,                               -- number (QuestConditionType enum)
    currConditionVal,                            -- number (previous value)
    newConditionVal,                             -- number (new value)
    conditionMax,                                -- number
    isFailCondition,                             -- boolean
    stepOverrideText,                            -- string
    isPushed,                                    -- boolean
    isComplete,                                  -- boolean
    isConditionComplete,                         -- boolean
    isStepHidden,                                -- boolean
    isConditionCompleteStatusChanged,            -- boolean (added in API 100028)
    isConditionCompletableBySiblingStatusChanged -- boolean (added in API 100028)
)
    local questId = GetJournalQuestId(journalIndex)
    if QUEST_ID[questId] then
        -- quest condition went backwards (item dropped, etc.)
        if DEBUG then
            -- TEMP: force re-match on every condition change while testing item-by-item
            ActivateQuestTracking(questId, journalIndex)
        else
            if newConditionVal < currConditionVal then
                ActivateQuestTracking(questId, journalIndex)
            end
        end
    end
end

local function OnQuestRemoved(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questId)
    if QUEST_ID[questId] then
        DeactivateQuestTracking(questId)
    end
end

local function IsTargetBoard()
    return TIPBOARD_TARGET_NAMES[GetUnitName("interact") or ""] ~= nil
end

local function OnQuestOffered(eventCode)
    if not CCA.SV.autoSkipTipBoard then return end
    if not IsTargetBoard() then return end
    local _, response = GetOfferedQuestInfo()
    if TIPBOARD_SKIP_RESPONSES[response] then
        local interaction = SYSTEMS:GetObjectBasedOnCurrentScene(ZO_INTERACTION_SYSTEM_NAME)
        if interaction then interaction:CloseChatter() end
    end
end

local function RegisterQuestEvents()
    EM:RegisterForEvent(ADDON_NAME, EVENT_QUEST_ADDED, OnQuestAdded)
    EM:RegisterForEvent(ADDON_NAME, EVENT_QUEST_CONDITION_COUNTER_CHANGED, OnQuestConditionCounterChanged)
    EM:RegisterForEvent(ADDON_NAME, EVENT_QUEST_REMOVED, OnQuestRemoved)
    EM:RegisterForEvent(ADDON_NAME, EVENT_QUEST_OFFERED, OnQuestOffered)
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

local function ToggleHighlightQuestItems()
    CCA.SV.highlightQuestItems = not CCA.SV.highlightQuestItems
    RefreshInventoryIcons()
    local msg = CCA.SV.highlightQuestItems and STRINGS.MSG_HIGHLIGHT_ON or STRINGS.MSG_HIGHLIGHT_OFF
    if msg and msg ~= "" then
        d("[" .. ADDON_TITLE .. "] " .. msg)
    else
        d(string.format("[%s] Quest item highlighting: %s",
            ADDON_TITLE, CCA.SV.highlightQuestItems and "ON" or "OFF"))
    end
end

local function ToggleAutoSkipTipBoard()
    CCA.SV.autoSkipTipBoard = not CCA.SV.autoSkipTipBoard
    local msg = CCA.SV.autoSkipTipBoard and STRINGS.MSG_AUTOSKIP_ON or STRINGS.MSG_AUTOSKIP_OFF
    if msg and msg ~= "" then
        d("[" .. ADDON_TITLE .. "] " .. msg)
    else
        d(string.format("[%s] Tip Board auto-skip: %s",
            ADDON_TITLE, CCA.SV.autoSkipTipBoard and "ON" or "OFF"))
    end
end

local function ShowTrackingStatus()
    local sv = CCA.SV

    local function getStatus(isActive, msgOn, msgOff, label)
        local customMsg = isActive and msgOn or msgOff
        if customMsg and customMsg ~= "" then return customMsg end
        return string.format("%s tracking: %s", label, isActive and "ON" or "OFF")
    end

    local params = {}

    tinsert(params, getStatus(sv.trackCountess, STRINGS.MSG_COUNTESS_ON, STRINGS.MSG_COUNTESS_OFF, "Countess"))
    tinsert(params, getStatus(sv.trackCrow, STRINGS.MSG_CROW_ON, STRINGS.MSG_CROW_OFF, "Bursar of Tributes"))
    tinsert(params, getStatus(sv.highlightQuestItems, STRINGS.MSG_HIGHLIGHT_ON, STRINGS.MSG_HIGHLIGHT_OFF, "Highlight"))
    tinsert(params, getStatus(sv.autoSkipTipBoard, STRINGS.MSG_AUTOSKIP_ON, STRINGS.MSG_AUTOSKIP_OFF, "Tip Board auto-skip"))

    d(string.format("[%s]\n%s", ADDON_TITLE, tconcat(params, "\n")))
end

----------------------------------------------------------------------
-- Load
----------------------------------------------------------------------
local function OnPlayerActivated()
    EM:UnregisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED)

    RegisterQuestEvents()
    ScanActiveQuests()

    -- TODO: disabled for now, as it does not work for all languages
    -- if not CheckTreasureTagsLoaded() then
    --     d("[" .. ADDON_NAME .. "] Missing treasure tags — please report to the author.")
    -- end
end

local function OnLoaded(_, name)
    if name ~= ADDON_NAME then return end
    EM:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    EM:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    CacheLocalizedStrings()
    InitSettings()
    BuildTreasureTags()
    UpdateStatusControlIcons()

    SLASH_COMMANDS[SLASH_TRACK_COUNTESS]  = ToggleTrackCountess
    SLASH_COMMANDS[SLASH_TRACK_CROW]      = ToggleTrackCrow
    SLASH_COMMANDS[SLASH_TRACK_STATUS]    = ShowTrackingStatus
    SLASH_COMMANDS[SLASH_TRACK_HIGHLIGHT] = ToggleHighlightQuestItems
    SLASH_COMMANDS[SLASH_TRACK_AUTOSKIP]  = ToggleAutoSkipTipBoard
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)
