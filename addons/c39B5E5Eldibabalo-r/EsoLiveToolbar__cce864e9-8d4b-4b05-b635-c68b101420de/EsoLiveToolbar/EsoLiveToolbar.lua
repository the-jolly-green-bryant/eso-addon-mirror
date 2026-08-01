EsoLiveToolbar = EsoLiveToolbar or {}
local ELT = EsoLiveToolbar

ELT.name = "EsoLiveToolbar"
ELT.version = "1.0.12"
ELT.saved = nil
ELT.control = nil
ELT.label = nil
ELT.bg = nil
ELT.sectionListControl = nil
ELT.sectionListLabel = nil
ELT.sectionListRows = nil
ELT.sectionListScrollOffset = 0
ELT.sectionListSelectedRow = 1
ELT.sectionListKeybindDescriptor = nil
ELT.sectionListSceneName = "eltSectionListScene"
ELT.compassControl = nil
ELT.compassBumpApplied = false
ELT.compassBaseAnchor = nil
ELT.trialTimerRunning = false
ELT.trialTimerStartMs = nil
ELT.trialTimerAccumMs = 0
ELT.trialAutoInZone = false
ELT.trialAwaitingCombat = false
ELT.dungeonTimerRunning = false
ELT.dungeonTimerStartMs = nil
ELT.dungeonTimerAccumMs = 0
ELT.dungeonAutoInZone = false
ELT.dungeonAwaitingCombat = false
ELT.arenaTimerRunning = false
ELT.arenaTimerStartMs = nil
ELT.arenaTimerAccumMs = 0
ELT.arenaAutoInZone = false
ELT.arenaAwaitingCombat = false
ELT.speedrunModeCache = {}
ELT.speedrunModeReasonCache = {}
ELT.contentTimersDisabled = true
ELT.perf = { enabled = false, counters = {}, max = {} }
ELT.lastAutoRefreshMs = nil
ELT.lastRenderedText = nil
ELT.lastRenderedScale = nil
ELT.lastRenderedUiScale = nil
ELT.manualStartHintShown = {}

local SV_VERSION = 1
local UPDATE_MS = 1000

local defaults = {
    enabled = true,
    offsetX = 0,
    offsetY = 0,
    scale = 1.0,
    textScale = 0.75,
    followUiScale = true,
    hideInMenu = false,
    fontSize = 12,
    alpha = 1.0,
    showBackground = true,
    showIcons = true,
    bumpCompass = false,
    compassOffsetY = 24,
    sections = {
        time = true,
        fps = true,
        ping = true,
        zone = true,
        playerName = false,
        playerRace = false,
        playerClass = false,
        bag = true,
        gold = true,
        crowns = false,
        crownGems = false,
        soulGems = true,
        durability = true,
        weaponCharge = true,
        levelXP = true,
        xpProgress = false,
        championXP = false,
        bank = true,
        alliancePoints = true,
        pvpRank = false,
        pvpProgress = false,
        telVar = true,
        transmute = true,
        writVouchers = false,
        eventTickets = true,
        horseTimer = true,
    },
}

ZO_CreateStringId("SI_ELT_BINDINGS", "Eso Live Toolbar")
ZO_CreateStringId("SI_BINDING_NAME_ELT_TOGGLE", "Toggle Eso Live Toolbar")

local SECTION_ORDER = {
    "time",
    "fps",
    "ping",
    "zone",
    "playerName",
    "playerRace",
    "playerClass",
    "bag",
    "gold",
    "crowns",
    "crownGems",
    "soulGems",
    "durability",
    "weaponCharge",
    "levelXP",
    "xpProgress",
    "championXP",
    "bank",
    "alliancePoints",
    "pvpRank",
    "pvpProgress",
    "telVar",
    "transmute",
    "writVouchers",
    "eventTickets",
    "horseTimer",
}
local DEFAULT_SECTION_ORDER = ZO_DeepTableCopy(SECTION_ORDER)

local SECTION_ALIASES = {
    time = "time",
    fps = "fps",
    ping = "ping",
    zone = "zone",
    name = "playerName",
    playername = "playerName",
    race = "playerRace",
    playerrace = "playerRace",
    class = "playerClass",
    playerclass = "playerClass",
    bag = "bag",
    gold = "gold",
    crowns = "crowns",
    crown = "crowns",
    crowngems = "crownGems",
    gems = "crownGems",
    crowngem = "crownGems",
    soul = "soulGems",
    soulgem = "soulGems",
    soulgems = "soulGems",
    durability = "durability",
    dur = "durability",
    weapon = "weaponCharge",
    charge = "weaponCharge",
    weaponcharge = "weaponCharge",
    level = "levelXP",
    xp = "levelXP",
    levelxp = "levelXP",
    xpprogress = "xpProgress",
    xpraw = "xpProgress",
    cpxp = "championXP",
    championxp = "championXP",
    champion = "championXP",
    bank = "bank",
    ap = "alliancePoints",
    alliance = "alliancePoints",
    alliancepoints = "alliancePoints",
    pvp = "pvpRank",
    pvprank = "pvpRank",
    pvpbar = "pvpProgress",
    pvpxp = "pvpProgress",
    pvpprogress = "pvpProgress",
    ava = "pvpRank",
    avarank = "pvpRank",
    telvar = "telVar",
    tv = "telVar",
    transmute = "transmute",
    crystals = "transmute",
    writ = "writVouchers",
    writs = "writVouchers",
    writvoucher = "writVouchers",
    writvouchers = "writVouchers",
    tickets = "eventTickets",
    eventtickets = "eventTickets",
    horse = "horseTimer",
    horsetimer = "horseTimer",
}

local function Msg(text)
    d(string.format("[EsoLiveToolbar] %s", tostring(text)))
end

function ELT:PerfCount(key, delta)
    if not self.perf or not self.perf.enabled then
        return
    end
    self.perf.counters[key] = (self.perf.counters[key] or 0) + (delta or 1)
end

function ELT:PerfMax(key, value)
    if not self.perf or not self.perf.enabled then
        return
    end
    local current = self.perf.max[key]
    if current == nil or value > current then
        self.perf.max[key] = value
    end
end

local REMOVED_TIMER_SECTIONS = {
    trialTimer = true,
    dungeonTimer = true,
    arenaTimer = true,
}

local function CopyArray(list)
    local out = {}
    if type(list) ~= "table" then
        return out
    end
    for i = 1, #list do
        out[i] = list[i]
    end
    return out
end

local function SafeCall(func, ...)
    if type(func) ~= "function" then
        return nil
    end
    local ok, a, b, c, d = pcall(func, ...)
    if ok then
        return a, b, c, d
    end
    return nil
end

local function Percent(current, maxValue)
    if not current or not maxValue or maxValue <= 0 then
        return nil
    end
    return math.floor((current / maxValue) * 100)
end

local function Colorize(text, hex)
    return string.format("|c%s%s|r", hex or "FFFFFF", text or "")
end

local function FormatNum(n)
    if n == nil then
        return "--"
    end
    if type(ZO_CommaDelimitNumber) == "function" then
        return ZO_CommaDelimitNumber(math.floor(n))
    end
    return tostring(math.floor(n))
end

local function BuildProgressBar(current, maxValue, width)
    if not current or not maxValue or maxValue <= 0 then
        return "[----------]"
    end
    local pct = zo_clamp(current / maxValue, 0, 1)
    local filled = math.floor((width or 10) * pct + 0.5)
    local empty = (width or 10) - filled
    return string.format("[%s%s]", string.rep("=", filled), string.rep("-", empty))
end

local function NormalizeKey(text)
    local v = zo_strlower(tostring(text or ""))
    v = v:gsub("[^%w]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return v
end

local SPEEDRUN_LOOKUP = {
    -- Dungeons
    ["fungal grotto i"] = { contentType = "dungeon", srId = 1559 },
    ["fungal grotto ii"] = { contentType = "dungeon", srId = 340 },
    ["spindleclutch i"] = { contentType = "dungeon", srId = 1568 },
    ["spindleclutch ii"] = { contentType = "dungeon", srId = 446 },
    ["the banished cells i"] = { contentType = "dungeon", srId = 1552 },
    ["the banished cells ii"] = { contentType = "dungeon", srId = 449 },
    ["elden hollow i"] = { contentType = "dungeon", srId = 1576 },
    ["elden hollow ii"] = { contentType = "dungeon", srId = 461 },
    ["wayrest sewers i"] = { contentType = "dungeon", srId = 1592 },
    ["wayrest sewers ii"] = { contentType = "dungeon", srId = 679 },
    ["arx corinium"] = { contentType = "dungeon", srId = 1607 },
    ["city of ash i"] = { contentType = "dungeon", srId = 1600 },
    ["city of ash ii"] = { contentType = "dungeon", srId = 1108 },
    ["crypt of hearts i"] = { contentType = "dungeon", srId = 1613 },
    ["crypt of hearts ii"] = { contentType = "dungeon", srId = 941 },
    ["direfrost keep"] = { contentType = "dungeon", srId = 1626 },
    ["tempest island"] = { contentType = "dungeon", srId = 1620 },
    ["volenfell"] = { contentType = "dungeon", srId = 1632 },
    ["darkshade caverns i"] = { contentType = "dungeon", srId = 1584 },
    ["darkshade caverns ii"] = { contentType = "dungeon", srId = 465 },
    ["blackheart haven"] = { contentType = "dungeon", srId = 1650 },
    ["blessed crucible"] = { contentType = "dungeon", srId = 1644 },
    ["selene s web"] = { contentType = "dungeon", srId = 1638 },
    ["vaults of madness"] = { contentType = "dungeon", srId = 1656 },
    ["imperial city prison"] = { contentType = "dungeon", srId = 1128 },
    ["white gold tower"] = { contentType = "dungeon", srId = 1275 },
    ["ruins of mazzatun"] = { contentType = "dungeon", srId = 1507 },
    ["cradle of shadows"] = { contentType = "dungeon", srId = 1525 },
    ["falkreath hold"] = { contentType = "dungeon", srId = 1702 },
    ["bloodroot forge"] = { contentType = "dungeon", srId = 1694 },
    ["fang lair"] = { contentType = "dungeon", srId = 1963 },
    ["scalecaller peak"] = { contentType = "dungeon", srId = 1979 },
    ["moon hunter keep"] = { contentType = "dungeon", srId = 2155 },
    ["march of sacrifices"] = { contentType = "dungeon", srId = 2165 },
    ["frostvault"] = { contentType = "dungeon", srId = 2263 },
    ["depths of malatar"] = { contentType = "dungeon", srId = 2273 },
    ["lair of maarselok"] = { contentType = "dungeon", srId = 2428 },
    ["moongrave fane"] = { contentType = "dungeon", srId = 2418 },
    ["icereach"] = { contentType = "dungeon", srId = 2542 },
    ["unhallowed grave"] = { contentType = "dungeon", srId = 2552 },
    ["stone garden"] = { contentType = "dungeon", srId = 2697 },
    ["castle thorn"] = { contentType = "dungeon", srId = 2707 },
    ["black drake villa"] = { contentType = "dungeon", srId = 2834 },
    ["the cauldron"] = { contentType = "dungeon", srId = 2844 },
    ["red petal bastion"] = { contentType = "dungeon", srId = 3019 },
    ["the dread cellar"] = { contentType = "dungeon", srId = 3029 },
    ["coral aerie"] = { contentType = "dungeon", srId = 3107 },
    ["shipwright s regret"] = { contentType = "dungeon", srId = 3117 },
    ["earthen root enclave"] = { contentType = "dungeon", srId = 3378 },
    ["graven deep"] = { contentType = "dungeon", srId = 3397 },
    ["bal sunnar"] = { contentType = "dungeon", srId = 3471 },
    ["scrivener s hall"] = { contentType = "dungeon", srId = 3532 },
    ["oathsworn pit"] = { contentType = "dungeon", srId = 3813 },
    ["bedlam veil"] = { contentType = "dungeon", srId = 3854 },
    ["exiled redoubt"] = { contentType = "dungeon", srId = 4112 },
    ["lep seclusa"] = { contentType = "dungeon", srId = 4131 },
    ["naj caldeesh"] = { contentType = "dungeon", srId = 4314 },
    ["black gem foundry"] = { contentType = "dungeon", srId = 4337 },
    -- Trials
    ["aetherian archive"] = { contentType = "trial", srId = 1081 },
    ["hel ra citadel"] = { contentType = "trial", srId = 1080 },
    ["sanctum ophidia"] = { contentType = "trial", srId = 1124 },
    ["maw of lorkhaj"] = { contentType = "trial", srId = 1367 },
    ["halls of fabrication"] = { contentType = "trial", srId = 1809 },
    ["asylum sanctorium"] = { contentType = "trial", srId = 2081 },
    ["cloudrest"] = { contentType = "trial", srId = 2137 },
    ["sunspire"] = { contentType = "trial", srId = 2434 },
    ["kyne s aegis"] = { contentType = "trial", srId = 2733 },
    ["rockgrove"] = { contentType = "trial", srId = 2986 },
    ["dreadsail reef"] = { contentType = "trial", srId = 3243 },
    ["sanity s edge"] = { contentType = "trial", srId = 3559 },
    ["lucent citadel"] = { contentType = "trial", srId = 4014 },
    ["ossein cage"] = { contentType = "trial", srId = 4267 },
    -- Arenas with speedrun achievements
    ["blackrose prison"] = { contentType = "arena", srId = 2366 },
    ["vateshran hollows"] = { contentType = "arena", srId = 2910 },
}

local function FormatClockHMS(totalSeconds)
    local sec = zo_max(math.floor(totalSeconds or 0), 0)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function FormatSeconds(seconds)
    if not seconds or seconds <= 0 then
        return "Ready"
    end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    if h > 24 then
        local d = math.floor(h / 24)
        h = h % 24
        return string.format("%dd %02dh", d, h)
    end
    return string.format("%02d:%02d", h, m)
end

local function GetToolbarFontDescriptor(size)
    return string.format("$(MEDIUM_FONT)|%d|soft-shadow-thin", size or 12)
end

local ICON_SIZE = 14
local SECTION_LIST_MAX_VISIBLE_ROWS = 16
local SECTION_LIST_ROW_HEIGHT = 30
local SECTION_LIST_ROW_FONT = "$(MEDIUM_FONT)|24|soft-shadow-thin"
local SECTION_ICONS = {
    time = "/esoui/art/mainmenu/menubar_clock_up.dds",
    fps = "/esoui/art/tutorial/gamepad/gp_tutorial_idexicon_gameplay.dds",
    ping = "/esoui/art/help/help_tabicon_feedback_up.dds",
    zone = "/esoui/art/compass/ava_borderkeep_pin.dds",
    playerName = "/esoui/art/contacts/tabicon_contacts_up.dds",
    playerRace = "/esoui/art/charactercreate/charactercreate_raceicon_up.dds",
    playerClass = "/esoui/art/charactercreate/charactercreate_classicon_up.dds",
    bag = "/esoui/art/inventory/inventory_tabicon_all_up.dds",
    gold = "/esoui/art/currency/currency_gold.dds",
    crowns = "/esoui/art/currency/currency_crown.dds",
    crownGems = "/esoui/art/currency/currency_crown_gems.dds",
    soulGems = "/esoui/art/currency/currency_soulgem.dds",
    durability = "/esoui/art/ava/ava_resourcestatus_tabicon_defense_inactive.dds",
    weaponCharge = "/esoui/art/icons/icon_poison_001.dds",
    levelXP = "/esoui/art/progression/progression_indexicon_world_up.dds",
    xpProgress = "/esoui/art/progression/progression_tabicon_stats_up.dds",
    championXP = "/esoui/art/champion/champion_points_magicka_icon-hud-32.dds",
    bank = "/esoui/art/guild/tabicon_history_up.dds",
    alliancePoints = "/esoui/art/currency/alliancepoints_32.dds",
    pvpRank = false,
    pvpProgress = false,
    telVar = "/esoui/art/currency/currency_telvar.dds",
    transmute = "/esoui/art/currency/icon_seedcrystal.dds",
    writVouchers = "/esoui/art/currency/currency_writvoucher.dds",
    eventTickets = "/esoui/art/currency/currency_eventticket.dds",
    horseTimer = "/esoui/art/treeicons/store_indexicon_mounts_up.dds",
}

local function WithSectionIcon(sectionName, text)
    if not text then
        return text
    end
    if not ELT.saved or not ELT.saved.showIcons then
        return text
    end
    local path = SECTION_ICONS[sectionName]
    if not path then
        return text
    end
    -- Keep icon + label contiguous so wrapping does not split them across lines.
    return string.format("|t%d:%d:%s|t%s", ICON_SIZE, ICON_SIZE, path, text)
end

local function GetSectionListIconTag(sectionName)
    if not sectionName then
        return ""
    end
    if sectionName == "pvpRank" or sectionName == "pvpProgress" then
        local rank = SafeCall(GetUnitAvARank, "player")
        local iconPath = nil
        if type(_G["GetAvARankIcon"]) == "function" and rank ~= nil then
            iconPath = SafeCall(GetAvARankIcon, rank)
        end
        if not iconPath or iconPath == "" then
            iconPath = "/esoui/art/ava/ava_rankicon_general.dds"
        end
        if rank ~= nil then
            return string.format("|t14:14:%s|t", iconPath)
        end
        return "|t14:14:/esoui/art/ava/ava_rankicon_general.dds|t"
    end
    local path = SECTION_ICONS[sectionName]
    if type(path) == "string" and path ~= "" then
        return string.format("|t14:14:%s|t", path)
    end
    return ""
end

local function FormatMoney()
    local money = SafeCall(GetCurrencyAmount, CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    if money == nil then
        money = SafeCall(GetCurrentMoney)
    end
    if not money then
        return "Gold --"
    end
    return string.format("Gold %s", FormatNum(money))
end

local function FormatCrowns()
    local v = SafeCall(GetCurrencyAmount, CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT)
    if v == nil then return "Crowns --" end
    return string.format("Crowns %s", FormatNum(v))
end

local function FormatCrownGems()
    local v = SafeCall(GetCurrencyAmount, CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT)
    if v == nil then return "Gems --" end
    return string.format("Gems %s", FormatNum(v))
end

local function FormatBag()
    local used = SafeCall(GetNumBagUsedSlots, BAG_BACKPACK)
    local size = SafeCall(GetBagSize, BAG_BACKPACK)
    if not used or not size then
        return "Bag --/--"
    end
    local free = size - used
    local color = "66CC66"
    if free <= 10 then
        color = "FF4444"
    elseif free <= 25 then
        color = "FFBB33"
    end
    return string.format("Bag %s/%d", Colorize(tostring(used), color), size)
end

local function FormatFPS()
    local fps = SafeCall(GetFramerate)
    if not fps then
        return "FPS --"
    end
    local rounded = zo_round(fps)
    local color = "66CC66"
    if rounded < 30 then
        color = "FF4444"
    elseif rounded < 50 then
        color = "FFBB33"
    end
    return string.format("FPS %s", Colorize(tostring(rounded), color))
end

local function FormatPing()
    local ping = SafeCall(GetLatency)
    if not ping then
        return "Ping --"
    end
    local color = "66CC66"
    if ping >= 250 then
        color = "FF4444"
    elseif ping >= 120 then
        color = "FFBB33"
    end
    return string.format("Ping %s", Colorize(string.format("%dms", ping), color))
end

local function GetGroupDifficultyLabel()
    local grouped = false
    if type(IsUnitGrouped) == "function" then
        grouped = SafeCall(IsUnitGrouped, "player") == true
    elseif type(IsPlayerInGroup) == "function" then
        grouped = SafeCall(IsPlayerInGroup) == true
    end
    if not grouped then
        return "Solo"
    end

    local difficulty = nil
    if type(GetCurrentZoneDungeonDifficulty) == "function" then
        difficulty = SafeCall(GetCurrentZoneDungeonDifficulty)
    end
    if type(difficulty) == "number" then
        if DUNGEON_DIFFICULTY_VETERAN and difficulty == DUNGEON_DIFFICULTY_VETERAN then
            return "Veteran"
        end
        if DUNGEON_DIFFICULTY_NORMAL and difficulty == DUNGEON_DIFFICULTY_NORMAL then
            return "Normal"
        end
    end

    if type(IsInVeteranMode) == "function" and SafeCall(IsInVeteranMode) == true then
        return "Veteran"
    end
    return "Normal"
end

local function FormatZone()
    local zone = SafeCall(GetUnitZone, "player")
    if not zone or zone == "" then
        zone = SafeCall(GetPlayerLocationName)
    end
    if not zone or zone == "" then
        return "Zone --"
    end
    return string.format("Zone %s | Group %s", zone, GetGroupDifficultyLabel())
end

local function FormatTime()
    local t = SafeCall(GetTimeString)
    if not t then
        return "Time --:--"
    end
    return string.format("Time %s", t)
end

local function CleanGenderSuffix(text)
    if not text then
        return nil
    end
    return zo_strgsub(text, "%^.*$", "")
end

local function FormatPlayerName()
    local name = SafeCall(GetUnitName, "player")
    if not name or name == "" then
        return "Name --"
    end
    return string.format("Name %s", name)
end

local function FormatPlayerRace()
    local race = CleanGenderSuffix(SafeCall(GetUnitRace, "player"))
    if not race or race == "" then
        return "Race --"
    end
    return string.format("Race %s", race)
end

local function FormatPlayerClass()
    local className = CleanGenderSuffix(SafeCall(GetUnitClass, "player"))
    if not className or className == "" then
        return "Class --"
    end
    return string.format("Class %s", className)
end

local function CountSoulGems()
    local count = 0
    local bagSlots = SafeCall(GetBagSize, BAG_BACKPACK)
    if bagSlots then
        for slot = 0, bagSlots - 1 do
            local itemType = SafeCall(GetItemType, BAG_BACKPACK, slot)
            if itemType == ITEMTYPE_SOUL_GEM then
                local stack = SafeCall(GetSlotStackSize, BAG_BACKPACK, slot) or 0
                count = count + stack
            end
        end
        return count
    end

    local getSoulGemCount = _G["GetSoulGemCount"]
    if type(getSoulGemCount) == "function" and _G["SOUL_GEM_TYPE_FILLED"] then
        local filled = SafeCall(getSoulGemCount, SOUL_GEM_TYPE_FILLED) or 0
        local empty = SafeCall(getSoulGemCount, SOUL_GEM_TYPE_EMPTY) or 0
        return filled + empty
    end
    return nil
end

local function FormatSoulGems()
    local total = CountSoulGems()
    if total == nil then
        return "Soul --"
    end
    local color = total == 0 and "FF4444" or "66CC66"
    return string.format("Soul %s", Colorize(FormatNum(total), color))
end

local DURABILITY_SLOTS = {}
local function AddDurabilitySlot(slot)
    if type(slot) == "number" then
        table.insert(DURABILITY_SLOTS, slot)
    end
end
AddDurabilitySlot(EQUIP_SLOT_HEAD)
AddDurabilitySlot(EQUIP_SLOT_CHEST)
AddDurabilitySlot(EQUIP_SLOT_SHOULDERS)
AddDurabilitySlot(EQUIP_SLOT_HAND)
AddDurabilitySlot(EQUIP_SLOT_WAIST)
AddDurabilitySlot(EQUIP_SLOT_LEGS)
AddDurabilitySlot(EQUIP_SLOT_FEET)
AddDurabilitySlot(EQUIP_SLOT_WRIST)
AddDurabilitySlot(EQUIP_SLOT_MAIN_HAND)
AddDurabilitySlot(EQUIP_SLOT_OFF_HAND)
AddDurabilitySlot(EQUIP_SLOT_BACKUP_MAIN)
AddDurabilitySlot(EQUIP_SLOT_BACKUP_OFF)

local function FormatDurability()
    local wornSlots = SafeCall(GetBagSize, BAG_WORN) or 0
    local equipped = 0
    local minPct = nil
    local totalRepairCost = 0

    for _, slot in ipairs(DURABILITY_SLOTS) do
        local hasItem = SafeCall(HasItemInSlot, BAG_WORN, slot)
        if hasItem then
            equipped = equipped + 1
        end

        local cond, maxCond = SafeCall(GetItemCondition, BAG_WORN, slot)
        local pct = Percent(cond, maxCond)
        if pct and (not minPct or pct < minPct) then
            minPct = pct
        end

        local cost = SafeCall(GetItemRepairCost, BAG_WORN, slot)
        if cost and cost > 0 then
            totalRepairCost = totalRepairCost + cost
        end
    end

    if totalRepairCost <= 0 and wornSlots > 0 then
        for slot = 0, wornSlots - 1 do
            local cost = SafeCall(GetItemRepairCost, BAG_WORN, slot)
            if cost and cost > 0 then
                totalRepairCost = totalRepairCost + cost
            end
        end
    end

    if minPct == nil then
        if equipped > 0 or totalRepairCost > 0 then
            return "Dur 100%"
        end
        return "Dur --"
    end

    local color = "66CC66"
    if minPct <= 20 then
        color = "FF4444"
    elseif minPct <= 50 then
        color = "FFBB33"
    end
    return string.format("Dur %s%%", Colorize(tostring(minPct), color))
end

local function FormatLevelXP()
    local level = SafeCall(GetUnitLevel, "player")
    local cp = SafeCall(GetPlayerChampionPoints)
    if cp and cp > 0 then
        return string.format("CP %s", tostring(cp))
    end
    return string.format("Lvl %s", level and tostring(level) or "--")
end

local function GetXPValues()
    local earned, maxValue = SafeCall(GetUnitXP, "player")
    if maxValue == nil then
        maxValue = SafeCall(GetUnitXPMax, "player")
    end
    return earned, maxValue
end

local function FormatXPProgress()
    local earned, maxValue = GetXPValues()
    if earned == nil or maxValue == nil or maxValue <= 0 then
        return "XP --/--"
    end
    local pct = Percent(earned, maxValue) or 0
    local bar = BuildProgressBar(earned, maxValue, 10)
    return string.format("XP %s %d%%", bar, pct)
end

local function FormatChampionXP()
    local isChampion = SafeCall(IsUnitChampion, "player")
    if not isChampion then
        return "CP --"
    end

    local rank = SafeCall(GetPlayerChampionPointsEarned)
    if rank == nil then
        rank = SafeCall(GetPlayerChampionPoints)
    end
    if rank == nil then
        return "CP --"
    end

    local earned = SafeCall(GetPlayerChampionXP)
    local maxValue = SafeCall(GetNumChampionXPInChampionPoint, rank)
    if earned == nil or maxValue == nil or maxValue <= 0 then
        return string.format("CP %s --/--", tostring(rank))
    end

    local pct = Percent(earned, maxValue) or 0
    local bar = BuildProgressBar(earned, maxValue, 10)
    return string.format("CP %s %s %d%%", tostring(rank), bar, pct)
end

local function FormatBank()
    local bankSize = SafeCall(GetBagSize, BAG_BANK)
    local bankUsed = SafeCall(GetNumBagUsedSlots, BAG_BANK)
    if not bankSize or not bankUsed then
        return "Bank --/--"
    end

    -- ESO Plus can split bank capacity into BAG_BANK + BAG_SUBSCRIBER_BANK.
    local isPlus = SafeCall(IsESOPlusSubscriber)
    if isPlus and BAG_SUBSCRIBER_BANK then
        local subSize = SafeCall(GetBagSize, BAG_SUBSCRIBER_BANK) or 0
        local subUsed = SafeCall(GetNumBagUsedSlots, BAG_SUBSCRIBER_BANK) or 0
        bankSize = bankSize + subSize
        bankUsed = bankUsed + subUsed
    end

    return string.format("Bank %d/%d", bankUsed, bankSize)
end

local function GetCurrency(curt, location)
    if not curt or not location then
        return nil
    end
    return SafeCall(GetCurrencyAmount, curt, location)
end

local function FormatAlliancePoints()
    local v = GetCurrency(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
    if v == nil then return "AP --" end
    return string.format("AP %s", FormatNum(v))
end

local function GetPvPRank()
    return SafeCall(GetUnitAvARank, "player")
end

local function GetPvPRankIconTag(rank)
    local iconPath = nil
    local getIcon = _G["GetAvARankIcon"]
    if type(getIcon) == "function" and rank ~= nil then
        iconPath = SafeCall(getIcon, rank)
    end
    if not iconPath or iconPath == "" then
        iconPath = "/esoui/art/ava/ava_rankicon_general.dds"
    end
    return string.format("|t14:14:%s|t", iconPath)
end

local PVP_RANK_TITLES = {
    "Volunteer",
    "Recruit",
    "Tyro",
    "Legionary",
    "Veteran",
    "Corporal",
    "Sergeant",
    "First Sergeant",
    "Lieutenant",
    "Captain",
    "Major",
    "Centurion",
    "Colonel",
    "Tribune",
    "Brigadier",
    "Prefect",
    "Praetorian",
    "Palatine",
    "August Palatine",
    "Legate",
    "General",
    "Warlord",
    "Grand Warlord",
    "Overlord",
    "Grand Overlord",
}

local function GetPvPRankNameAndGrade(rank)
    if type(rank) ~= "number" or rank < 0 then
        return nil, nil
    end
    if rank == 0 then
        return "Citizen", nil
    end

    local rankName = nil
    local getRankName = _G["GetAvARankName"]
    if type(getRankName) == "function" then
        rankName = SafeCall(getRankName, rank)
    end

    local titleIndex = math.floor((rank - 1) / 2) + 1
    local fallbackTitle = PVP_RANK_TITLES[titleIndex]
    if not rankName or rankName == "" or zo_strlower(rankName) == "citizen" then
        rankName = fallbackTitle
    end

    local grade = ((rank - 1) % 2) + 1
    return rankName, grade
end

local function FormatPvPRank()
    local rank = GetPvPRank()
    if rank == nil then
        return "PvP Rank --"
    end

    local iconTag = GetPvPRankIconTag(rank)
    local rankName, grade = GetPvPRankNameAndGrade(rank)
    if rankName and grade then
        return string.format("%s %s Grade %s - Rank %s", iconTag, rankName, tostring(grade), tostring(rank))
    elseif rankName then
        return string.format("%s %s - Rank %s", iconTag, rankName, tostring(rank))
    end
    return string.format("%s PvP Rank %s", iconTag, tostring(rank))
end

local function GetPvPProgressValues(rank)
    local totalPoints = nil
    if type(_G["GetUnitAvARankPoints"]) == "function" then
        totalPoints = SafeCall(GetUnitAvARankPoints, "player")
    end

    local getNeeded = _G["GetNumPointsNeededForAvARank"]
    if type(getNeeded) == "function" and type(totalPoints) == "number" then
        local currentRankThreshold = SafeCall(getNeeded, rank)
        local nextRankThreshold = SafeCall(getNeeded, rank + 1)
        if type(currentRankThreshold) == "number" and type(nextRankThreshold) == "number" and nextRankThreshold > currentRankThreshold then
            local needed = nextRankThreshold - currentRankThreshold
            local current = zo_clamp(totalPoints - currentRankThreshold, 0, needed)
            local left = zo_max(needed - current, 0)
            return current, needed, rank, left
        end
    end

    if type(_G["GetAvARankProgress"]) == "function" then
        local a, b = SafeCall(GetAvARankProgress, rank)
        if type(a) == "number" and type(b) == "number" and b > 0 then
            local current = zo_clamp(a, 0, b)
            local left = zo_max(b - current, 0)
            return current, b, rank, left
        end
    end

    return nil, nil, rank, nil
end

local function FormatPvPProgress()
    local rank = GetPvPRank()
    if rank == nil then
        return "PvP XP --"
    end

    local current, needed, displayedRank, left = GetPvPProgressValues(rank)
    if not current or not needed or needed <= 0 then
        return "PvP XP --"
    end

    local pct = Percent(current, needed) or 0
    local bar = BuildProgressBar(current, needed, 10)
    local iconTag = GetPvPRankIconTag(displayedRank)
    return string.format("%s PvP %s %d%% Next:%s", iconTag, bar, pct, FormatNum(left or 0))
end

local function FormatTelVar()
    local v = GetCurrency(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
    if v == nil then return "TV --" end
    return string.format("TV %s", FormatNum(v))
end

local function FormatTransmute()
    local v = GetCurrency(CURT_TRANSMUTE_CRYSTALS, CURRENCY_LOCATION_ACCOUNT)
    if v == nil then return "Xmute --" end
    return string.format("Xmute %s", FormatNum(v))
end

local function FormatWritVouchers()
    local v = GetCurrency(CURT_WRIT_VOUCHERS, CURRENCY_LOCATION_CHARACTER)
    if v == nil then return "Writs --" end
    return string.format("Writs %s", FormatNum(v))
end

local function FormatEventTickets()
    local v = GetCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT)
    local maxV = GetCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_MAX) or 12
    if v == nil then return "Tickets --" end
    return string.format("Tickets %d/%d", v, maxV)
end

local function FormatHorseTimer()
    local secs = SafeCall(GetTimeUntilCanBeTrained)
    if secs == nil then
        return "Horse --"
    end
    return string.format("Horse %s", FormatSeconds(secs))
end

local function FormatTrialTimer()
    local elapsedMs = ELT:GetTrialTimerElapsedMs()
    if not elapsedMs or elapsedMs <= 0 then
        return "Trial 00:00:00"
    end
    return string.format("Trial %s", FormatClockHMS(elapsedMs / 1000))
end

local function FormatDungeonTimer()
    local elapsedMs = ELT:GetDungeonTimerElapsedMs()
    if not elapsedMs or elapsedMs <= 0 then
        return "Dungeon 00:00:00"
    end
    return string.format("Dungeon %s", FormatClockHMS(elapsedMs / 1000))
end

local function FormatArenaTimer()
    local elapsedMs = ELT:GetArenaTimerElapsedMs()
    if not elapsedMs or elapsedMs <= 0 then
        return "Arena 00:00:00"
    end
    return string.format("Arena %s", FormatClockHMS(elapsedMs / 1000))
end

local WEAPON_SLOTS = { EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_POISON }

local function FormatWeaponCharge()
    local minCharge = nil
    for _, slot in ipairs(WEAPON_SLOTS) do
        local current, maxValue = SafeCall(GetChargeInfoForItem, BAG_WORN, slot)
        local pct = Percent(current, maxValue)
        if pct and (not minCharge or pct < minCharge) then
            minCharge = pct
        end
    end
    if not minCharge then
        return "Charge --"
    end
    local color = "66CC66"
    if minCharge <= 20 then
        color = "FF4444"
    elseif minCharge <= 50 then
        color = "FFBB33"
    end
    return string.format("Charge %s%%", Colorize(tostring(minCharge), color))
end

local SECTION_RENDERERS = {
    time = FormatTime,
    fps = FormatFPS,
    ping = FormatPing,
    zone = FormatZone,
    playerName = FormatPlayerName,
    playerRace = FormatPlayerRace,
    playerClass = FormatPlayerClass,
    bag = FormatBag,
    gold = FormatMoney,
    crowns = FormatCrowns,
    crownGems = FormatCrownGems,
    soulGems = FormatSoulGems,
    durability = FormatDurability,
    weaponCharge = FormatWeaponCharge,
    levelXP = FormatLevelXP,
    xpProgress = FormatXPProgress,
    championXP = FormatChampionXP,
    bank = FormatBank,
    alliancePoints = FormatAlliancePoints,
    pvpRank = FormatPvPRank,
    pvpProgress = FormatPvPProgress,
    telVar = FormatTelVar,
    transmute = FormatTransmute,
    writVouchers = FormatWritVouchers,
    eventTickets = FormatEventTickets,
    horseTimer = FormatHorseTimer,
}

function ELT:GetSectionOrder()
    self.saved.sectionOrder = self.saved.sectionOrder or CopyArray(DEFAULT_SECTION_ORDER)
    local normalized = {}
    local known = {}
    for _, section in ipairs(DEFAULT_SECTION_ORDER) do
        known[section] = true
    end
    for _, section in ipairs(self.saved.sectionOrder) do
        if known[section] and not normalized[section] then
            normalized[section] = true
        end
    end
    local merged = {}
    for _, section in ipairs(self.saved.sectionOrder) do
        if normalized[section] then
            table.insert(merged, section)
            normalized[section] = nil
        end
    end
    for _, section in ipairs(DEFAULT_SECTION_ORDER) do
        if known[section] and not self:ContainsValue(merged, section) then
            table.insert(merged, section)
        end
    end
    self.saved.sectionOrder = merged
    return self.saved.sectionOrder
end

function ELT:ContainsValue(list, value)
    for i = 1, #list do
        if list[i] == value then
            return true, i
        end
    end
    return false, nil
end

function ELT:MoveSection(sectionName, targetPos)
    local order = self:GetSectionOrder()
    local exists, currentPos = self:ContainsValue(order, sectionName)
    if not exists then
        return false, "Unknown section"
    end
    local pos = tonumber(targetPos)
    if not pos then
        return false, "Position must be a number"
    end
    pos = zo_clamp(math.floor(pos), 1, #order)
    table.remove(order, currentPos)
    table.insert(order, pos, sectionName)
    self.saved.sectionOrder = order
    self:Refresh()
    return true, pos
end

function ELT:ResetSectionOrder()
    self.saved.sectionOrder = CopyArray(DEFAULT_SECTION_ORDER)
    self:Refresh()
end

function ELT:BuildText()
    self:PerfCount("build_text_calls", 1)
    local s = self.saved.sections or defaults.sections
    local parts = {}
    local enabledSections = 0
    local order = self:GetSectionOrder()
    for _, sectionName in ipairs(order) do
        if s[sectionName] then
            enabledSections = enabledSections + 1
            local formatter = SECTION_RENDERERS[sectionName]
            if formatter then
                table.insert(parts, WithSectionIcon(sectionName, formatter()))
            end
        end
    end
    self:PerfMax("enabled_sections", enabledSections)
    return table.concat(parts, "  |  ")
end

function ELT:NormalizeSection(sectionName)
    if not sectionName or sectionName == "" then
        return nil
    end
    return SECTION_ALIASES[zo_strlower(sectionName)]
end

function ELT:SetSectionEnabled(sectionName, enabled)
    local normalized = self:NormalizeSection(sectionName)
    if not normalized and type(sectionName) == "string" and self.saved.sections[sectionName] ~= nil then
        normalized = sectionName
    end
    if not normalized then
        return false, "Unknown section"
    end
    if REMOVED_TIMER_SECTIONS[normalized] then
        return false, "Timer sections were removed from this build"
    end
    self.saved.sections[normalized] = enabled and true or false
    self:Refresh()
    return true, normalized
end

function ELT:ResetSections()
    self.saved.sections = ZO_DeepTableCopy(defaults.sections)
    self:Refresh()
end

function ELT:GetSectionsListText()
    local parts = {}
    for index, key in ipairs(self:GetSectionOrder()) do
        local state = self.saved.sections[key] and "ON" or "OFF"
        table.insert(parts, string.format("%d.%s:%s", index, key, state))
    end
    return table.concat(parts, "\n")
end

function ELT:ListSections()
    Msg(zo_strgsub(self:GetSectionsListText(), "\n", " | "))
    local uiScale = self:GetUiScale()
    local textScale = self:GetEffectiveTextScale()
    Msg(string.format("Scale: base=%.2f effective=%.2f followUi=%s ui=%.2f", self.saved.textScale or 0.75, textScale, self.saved.followUiScale and "ON" or "OFF", uiScale))
    Msg("Hide in menus: ON (always)")
end

function ELT:SetAllSectionsEnabled(enabled)
    for _, key in ipairs(DEFAULT_SECTION_ORDER) do
        if not REMOVED_TIMER_SECTIONS[key] then
            self.saved.sections[key] = enabled and true or false
        end
    end
    self:Refresh()
end

function ELT:CreateSectionListWindow()
    if self.sectionListControl then
        return
    end
    local wm = WINDOW_MANAGER
    local ctrl = wm:CreateTopLevelWindow("ELT_SectionList")
    ctrl:SetDimensions(520, 720)
    ctrl:SetMovable(true)
    ctrl:SetMouseEnabled(true)
    ctrl:SetClampedToScreen(true)
    ctrl:SetDrawLayer(DL_OVERLAY)
    ctrl:SetDrawTier(DT_HIGH)
    ctrl:SetDrawLevel(20)
    ctrl:ClearAnchors()
    ctrl:SetAnchor(CENTER, GuiRoot, CENTER, 520, 0)
    ctrl:SetHidden(true)

    local bg = wm:CreateControl(nil, ctrl, CT_BACKDROP)
    bg:SetAnchorFill(ctrl)
    bg:SetCenterColor(0.02, 0.02, 0.02, 0.90)
    bg:SetEdgeColor(0.85, 0.85, 0.85, 0.85)
    bg:SetInsets(-6, -6, 6, 6)

    local title = wm:CreateControl(nil, ctrl, CT_LABEL)
    title:SetAnchor(TOPLEFT, ctrl, TOPLEFT, 12, 10)
    title:SetFont("$(BOLD_FONT)|26|soft-shadow-thick")
    title:SetText("Eso Live Toolbar Sections")
    title:SetColor(1, 1, 1, 1)

    local hint = wm:CreateControl(nil, ctrl, CT_LABEL)
    hint:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 6)
    hint:SetFont("$(MEDIUM_FONT)|20|soft-shadow-thin")
    hint:SetText("Primary: Toggle/Adjust  Back: Close  L2/R2: Up/Down  L1/R1: Page")
    hint:SetColor(0.85, 0.85, 0.85, 1)

    local listAnchor = hint
    local rows = {}
    local maxRows = SECTION_LIST_MAX_VISIBLE_ROWS
    for i = 1, maxRows do
        local row = wm:CreateControl(nil, ctrl, CT_BACKDROP)
        row:SetDimensions(490, SECTION_LIST_ROW_HEIGHT)
        if i == 1 then
            row:SetAnchor(TOPLEFT, listAnchor, BOTTOMLEFT, 0, 12)
        else
            row:SetAnchor(TOPLEFT, rows[i - 1], BOTTOMLEFT, 0, 2)
        end
        row:SetCenterColor(0.08, 0.08, 0.08, 0.75)
        row:SetEdgeColor(0.25, 0.25, 0.25, 0.8)
        row:SetInsets(-1, -1, 1, 1)
        row:SetMouseEnabled(true)
        row.entry = nil

        local toggle = wm:CreateControl(nil, row, CT_LABEL)
        toggle:SetAnchor(LEFT, row, LEFT, 8, 0)
        toggle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        toggle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        toggle:SetFont("$(BOLD_FONT)|24|soft-shadow-thick")
        toggle:SetColor(0.95, 0.85, 0.40, 1)
        row.toggle = toggle

        local label = wm:CreateControl(nil, row, CT_LABEL)
        label:SetAnchor(LEFT, toggle, RIGHT, 10, 0)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetFont(SECTION_LIST_ROW_FONT)
        label:SetColor(1, 1, 1, 1)
        row.label = label

        local rowIndex = i
        row:SetHandler("OnMouseUp", function()
            if not row.entry then
                return
            end
            self.sectionListSelectedRow = rowIndex
            self:ToggleSelectedSectionFromList()
        end)

        rows[i] = row
    end

    ctrl:SetHandler("OnMouseWheel", function(_, delta)
        if delta > 0 then
            self:ScrollSectionList(-1)
        else
            self:ScrollSectionList(1)
        end
    end)

    self.sectionListControl = ctrl
    self.sectionListRows = rows
    self.sectionListScrollOffset = 0
    self.sectionListSelectedRow = 1

    if SCENE_MANAGER then
        local scene = ZO_Scene:New(self.sectionListSceneName, SCENE_MANAGER)
        local fragment = ZO_SimpleSceneFragment:New(ctrl)
        scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
        scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
        if GAMEPAD_MENU_SOUND_FRAGMENT then
            scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
        end
        scene:AddFragment(fragment)
        scene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING then
                self.sectionListScrollOffset = 0
                self.sectionListSelectedRow = 1
                self:UpdateSectionListWindow()
                if KEYBIND_STRIP and self.sectionListKeybindDescriptor then
                    KEYBIND_STRIP:AddKeybindButtonGroup(self.sectionListKeybindDescriptor)
                    KEYBIND_STRIP:UpdateKeybindButtonGroup(self.sectionListKeybindDescriptor)
                end
            elseif newState == SCENE_HIDDEN then
                if KEYBIND_STRIP and self.sectionListKeybindDescriptor then
                    pcall(function()
                        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.sectionListKeybindDescriptor)
                    end)
                end
            end
        end)
    end
end

function ELT:GetSectionListAbsoluteIndex()
    return (self.sectionListScrollOffset or 0) + (self.sectionListSelectedRow or 1)
end

function ELT:GetSectionListEntries()
    local entries = {
        { kind = "action", action = "scale_down" },
        { kind = "action", action = "scale_up" },
    }
    for _, sectionName in ipairs(self:GetSectionOrder()) do
        entries[#entries + 1] = { kind = "section", sectionName = sectionName }
    end
    return entries
end

function ELT:GetSectionAtSelectedRow()
    local entries = self:GetSectionListEntries()
    return entries[self:GetSectionListAbsoluteIndex()]
end

function ELT:AdjustTextScale(delta)
    local oldScale = self.saved.textScale or 0.75
    local newScale = zo_clamp(oldScale + (delta or 0), 0.60, 2.50)
    newScale = math.floor((newScale * 100) + 0.5) / 100
    if math.abs(newScale - oldScale) <= 0.0001 then
        return false, oldScale
    end
    self.saved.textScale = newScale
    self.lastRenderedScale = nil
    self.lastRenderedUiScale = nil
    self:ApplyStyle()
    self:Refresh(true)
    return true, newScale
end

function ELT:ToggleSelectedSectionFromList()
    local entry = self:GetSectionAtSelectedRow()
    if not entry then
        return
    end
    if entry.kind == "section" and entry.sectionName then
        local sectionName = entry.sectionName
        self:SetSectionEnabled(sectionName, not self.saved.sections[sectionName])
    elseif entry.kind == "action" and entry.action == "scale_down" then
        self:AdjustTextScale(-0.10)
    elseif entry.kind == "action" and entry.action == "scale_up" then
        self:AdjustTextScale(0.10)
    end
    self:UpdateSectionListWindow()
end

function ELT:ScrollSectionList(delta)
    local total = #self:GetSectionListEntries()
    local maxOffset = zo_max(total - SECTION_LIST_MAX_VISIBLE_ROWS, 0)
    local newOffset = zo_clamp((self.sectionListScrollOffset or 0) + (delta or 0), 0, maxOffset)
    if newOffset ~= self.sectionListScrollOffset then
        self.sectionListScrollOffset = newOffset
        self:UpdateSectionListWindow()
    end
end

function ELT:MoveSectionListSelection(delta)
    local total = #self:GetSectionListEntries()
    if total <= 0 then
        return
    end
    local maxOffset = zo_max(total - SECTION_LIST_MAX_VISIBLE_ROWS, 0)
    local currentAbs = self:GetSectionListAbsoluteIndex()
    local newAbs = zo_clamp(currentAbs + (delta or 0), 1, total)
    local offset = self.sectionListScrollOffset or 0

    if newAbs < offset + 1 then
        offset = newAbs - 1
    elseif newAbs > offset + SECTION_LIST_MAX_VISIBLE_ROWS then
        offset = newAbs - SECTION_LIST_MAX_VISIBLE_ROWS
    end

    offset = zo_clamp(offset, 0, maxOffset)
    self.sectionListScrollOffset = offset
    self.sectionListSelectedRow = zo_clamp(newAbs - offset, 1, SECTION_LIST_MAX_VISIBLE_ROWS)
    self:UpdateSectionListWindow()
end

function ELT:UpdateSectionListWindow()
    if not self.sectionListControl or self.sectionListControl:IsHidden() then
        return
    end
    if self.sectionListRows then
        local entries = self:GetSectionListEntries()
        local total = #entries
        local maxOffset = zo_max(total - SECTION_LIST_MAX_VISIBLE_ROWS, 0)
        self.sectionListScrollOffset = zo_clamp(self.sectionListScrollOffset or 0, 0, maxOffset)
        self.sectionListSelectedRow = zo_clamp(self.sectionListSelectedRow or 1, 1, SECTION_LIST_MAX_VISIBLE_ROWS)

        local visibleCount = zo_min(SECTION_LIST_MAX_VISIBLE_ROWS, total)
        if visibleCount <= 0 then
            self.sectionListSelectedRow = 1
        else
            self.sectionListSelectedRow = zo_clamp(self.sectionListSelectedRow, 1, visibleCount)
        end

        local startIndex = self.sectionListScrollOffset + 1

        for i = 1, #self.sectionListRows do
            local row = self.sectionListRows[i]
            local listIndex = startIndex + i - 1
            local entry = entries[listIndex]
            if entry then
                row.entry = entry
                row:SetHidden(false)
                if i == self.sectionListSelectedRow then
                    row:SetCenterColor(0.30, 0.22, 0.08, 0.95)
                    row:SetEdgeColor(0.91, 0.75, 0.36, 0.95)
                else
                    row:SetCenterColor(0.08, 0.08, 0.08, 0.75)
                    row:SetEdgeColor(0.25, 0.25, 0.25, 0.8)
                end
                if row.toggle then
                    if entry.kind == "section" then
                        local enabled = self.saved.sections[entry.sectionName] and true or false
                        row.toggle:SetText(enabled and "X" or " ")
                    elseif entry.action == "scale_down" then
                        row.toggle:SetText("-")
                    elseif entry.action == "scale_up" then
                        row.toggle:SetText("+")
                    else
                        row.toggle:SetText(" ")
                    end
                end
                if row.label then
                    if entry.kind == "section" then
                        local sectionName = entry.sectionName
                        local enabled = self.saved.sections[sectionName] and true or false
                        local iconTag = GetSectionListIconTag(sectionName)
                        row.label:SetText(string.format("%d. %s %s", listIndex, iconTag, sectionName))
                        if enabled then
                            row.label:SetColor(0.65, 1.0, 0.65, 1)
                        else
                            row.label:SetColor(1.0, 0.75, 0.75, 1)
                        end
                    elseif entry.action == "scale_down" then
                        row.label:SetText(string.format("%d. Decrease toolbar scale (%.2f)", listIndex, self.saved.textScale or 0.75))
                        row.label:SetColor(0.75, 0.88, 1.0, 1.0)
                    elseif entry.action == "scale_up" then
                        row.label:SetText(string.format("%d. Increase toolbar scale (%.2f)", listIndex, self.saved.textScale or 0.75))
                        row.label:SetColor(0.75, 0.88, 1.0, 1.0)
                    else
                        row.label:SetText(string.format("%d. Action", listIndex))
                        row.label:SetColor(1, 1, 1, 1)
                    end
                end
            else
                row.entry = nil
                row:SetHidden(true)
            end
        end
    end
end

function ELT:BuildSectionListKeybinds()
    if self.sectionListKeybindDescriptor then
        return
    end
    self.sectionListKeybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_NEGATIVE",
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function()
                self:HideSectionListWindow()
            end,
            sound = SOUNDS.GAMEPAD_MENU_BACK,
        },
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = "Toggle",
            callback = function()
                self:ToggleSelectedSectionFromList()
            end,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            name = "Up",
            callback = function()
                self:MoveSectionListSelection(-1)
            end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            name = "Down",
            callback = function()
                self:MoveSectionListSelection(1)
            end,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            name = "Page Up",
            callback = function()
                self:MoveSectionListSelection(-SECTION_LIST_MAX_VISIBLE_ROWS)
            end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            name = "Page Down",
            callback = function()
                self:MoveSectionListSelection(SECTION_LIST_MAX_VISIBLE_ROWS)
            end,
        },
        -- Removed optional secondary/tertiary shortcuts to avoid NotBound
        -- footer entries on platforms where these bindings are unmapped.
    }
end

function ELT:ShowSectionListWindow()
    self:CreateSectionListWindow()
    self:BuildSectionListKeybinds()
    if SCENE_MANAGER then
        SCENE_MANAGER:Show(self.sectionListSceneName)
    else
        self.sectionListControl:SetHidden(false)
        self.sectionListScrollOffset = 0
        self.sectionListSelectedRow = 1
        self:UpdateSectionListWindow()
    end
end

function ELT:HideSectionListWindow()
    if SCENE_MANAGER and SCENE_MANAGER:IsShowing(self.sectionListSceneName) then
        SCENE_MANAGER:HideCurrentScene()
    elseif self.sectionListControl then
        self.sectionListControl:SetHidden(true)
    end
end

function ELT:ToggleSectionListWindow()
    self:CreateSectionListWindow()
    if SCENE_MANAGER and SCENE_MANAGER:IsShowing(self.sectionListSceneName) then
        self:HideSectionListWindow()
    elseif self.sectionListControl:IsHidden() then
        self:ShowSectionListWindow()
    else
        self:HideSectionListWindow()
    end
end

function ELT:NormalizePresetName(name)
    if not name or name == "" then
        return nil
    end
    return zo_strlower(name)
end

function ELT:EnsurePresets()
    if type(self.saved.presets) ~= "table" then
        self.saved.presets = {}
    end
    return self.saved.presets
end

function ELT:SavePreset(name)
    local key = self:NormalizePresetName(name)
    if not key then
        return false, "Usage: /elt preset save <name>"
    end
    local presets = self:EnsurePresets()
    presets[key] = {
        sections = ZO_DeepTableCopy(self.saved.sections),
        sectionOrder = CopyArray(self:GetSectionOrder()),
        showIcons = self.saved.showIcons,
        showBackground = self.saved.showBackground,
    }
    return true, key
end

function ELT:LoadPreset(name)
    local key = self:NormalizePresetName(name)
    if not key then
        return false, "Usage: /elt preset load <name>"
    end
    local preset = self:EnsurePresets()[key]
    if not preset then
        return false, "Preset not found"
    end
    if type(preset.sections) == "table" then
        self.saved.sections = ZO_DeepTableCopy(preset.sections)
    end
    if type(preset.sectionOrder) == "table" then
        self.saved.sectionOrder = CopyArray(preset.sectionOrder)
    end
    if preset.showIcons ~= nil then
        self.saved.showIcons = preset.showIcons
    end
    if preset.showBackground ~= nil then
        self.saved.showBackground = preset.showBackground
    end
    if self.contentTimersDisabled then
        self:StopTrialTimer()
        self:StopDungeonTimer()
        self:StopArenaTimer()
    end
    self:ApplyStyle()
    self:Refresh()
    return true, key
end

function ELT:DeletePreset(name)
    local key = self:NormalizePresetName(name)
    if not key then
        return false, "Usage: /elt preset delete <name>"
    end
    local presets = self:EnsurePresets()
    if not presets[key] then
        return false, "Preset not found"
    end
    presets[key] = nil
    return true, key
end

function ELT:GetNowMs()
    local ms = SafeCall(GetGameTimeMilliseconds)
    if type(ms) == "number" then
        return ms
    end
    ms = SafeCall(GetFrameTimeMilliseconds)
    if type(ms) == "number" then
        return ms
    end
    return 0
end

function ELT:IsLikelyInTrial()
    local isRaidGroupFn = _G["IsInRaidGroup"]
    if type(isRaidGroupFn) == "function" and SafeCall(isRaidGroupFn) then
        return true
    end

    -- Some trial zones (e.g. Cloudrest) do not always report as "dungeon" consistently.
    local zone = SafeCall(GetUnitZone, "player")
    if not zone or zone == "" then
        zone = SafeCall(GetPlayerLocationName)
    end
    zone = zone and zo_strlower(zone) or ""
    local trialZoneHints = {
        "cloudrest",
        "sunspire",
        "rockgrove",
        "kaalgrontiid's lair",
        "kyne's aegis",
        "asylum sanctorium",
        "sanctum ophidia",
        "aetherian archive",
        "hel ra citadel",
        "maw of lorkhaj",
        "hall of fabrication",
        "dreadsail reef",
        "sanity's edge",
        "lucent citadel",
    }
    for _, hint in ipairs(trialZoneHints) do
        if zone:find(hint, 1, true) then
            return true
        end
    end

    return false
end

function ELT:GetCurrentZoneName()
    local zone = SafeCall(GetUnitZone, "player")
    if not zone or zone == "" then
        zone = SafeCall(GetPlayerLocationName)
    end
    return zone or ""
end

function ELT:GetCurrentZoneKey()
    return NormalizeKey(self:GetCurrentZoneName())
end

function ELT:IsLikelyInArena()
    local zone = self:GetCurrentZoneKey()
    local arenaHints = {
        "dragonstar arena",
        "maelstrom arena",
        "vateshran hollows",
        "blackrose prison",
    }
    for _, hint in ipairs(arenaHints) do
        if zone:find(hint, 1, true) then
            return true
        end
    end
    return false
end

function ELT:IsLikelyInDungeon()
    local inDungeon = SafeCall(IsUnitInDungeon, "player")
    if not inDungeon then
        return false
    end
    -- Keep dungeon timer mutually exclusive with trial/arena timer.
    return not self:IsLikelyInTrial() and not self:IsLikelyInArena()
end

function ELT:IsBossCombatActive()
    for i = 1, 6 do
        local tag = "boss" .. tostring(i)
        local exists = SafeCall(DoesUnitExist, tag)
        if exists and SafeCall(IsUnitInCombat, tag) then
            return true
        end
    end
    return false
end

function ELT:GetTimerModeMap()
    if type(self.saved.timerModes) ~= "table" then
        self.saved.timerModes = {}
    end
    return self.saved.timerModes
end

function ELT:GetSpeedrunEntryForZone(zoneKey, contentType)
    if not zoneKey or zoneKey == "" then
        return nil
    end
    for nameKey, entry in pairs(SPEEDRUN_LOOKUP) do
        if (not contentType or entry.contentType == contentType) and zoneKey:find(nameKey, 1, true) then
            return entry
        end
    end
    return nil
end

function ELT:GetAchievementDerivedStartMode(contentType, zoneKey)
    if type(self.speedrunModeReasonCache) ~= "table" then
        self.speedrunModeReasonCache = {}
    end
    local cacheKey = string.format("%s|%s", contentType or "unknown", zoneKey or "")
    if self.speedrunModeCache[cacheKey] ~= nil then
        return self.speedrunModeCache[cacheKey], self.speedrunModeReasonCache[cacheKey]
    end

    local entry = self:GetSpeedrunEntryForZone(zoneKey, contentType)
    if not entry or not entry.srId then
        self.speedrunModeCache[cacheKey] = false
        self.speedrunModeReasonCache[cacheKey] = "missingEntry"
        return nil, "missingEntry"
    end

    local _, description = SafeCall(GetAchievementInfo, entry.srId)
    if type(description) ~= "string" then
        self.speedrunModeCache[cacheKey] = false
        self.speedrunModeReasonCache[cacheKey] = "missingDescription"
        return nil, "missingDescription"
    end

    local text = zo_strlower(description):gsub("[^%w]+", " ")
    local mode = nil
    local hasFirstBoss = text:find("first boss", 1, true) or (text:find("first", 1, true) and text:find("boss", 1, true))
    local hasDoorEnter = text:find("upon entering", 1, true) or text:find("of entering", 1, true) or text:find("after entering", 1, true)
        or text:find("on entering", 1, true) or text:find("entering ", 1, true) or text:find("enter the", 1, true)
        or text:find("through the door", 1, true) or text:find("open the door", 1, true) or text:find("opening the door", 1, true)
        or text:find("through the gate", 1, true) or text:find("open the gate", 1, true) or text:find("opening the gate", 1, true)
    local hasFirstCombat = (text:find("engage", 1, true) or text:find("combat", 1, true) or text:find("battle", 1, true))
        and text:find("first", 1, true)

    if hasFirstBoss then
        mode = "boss"
    elseif hasDoorEnter then
        mode = "enter"
    elseif hasFirstCombat then
        mode = "combat"
    end

    self.speedrunModeCache[cacheKey] = mode or false
    self.speedrunModeReasonCache[cacheKey] = mode and "derived" or "unrecognizedDescription"
    return mode, self.speedrunModeReasonCache[cacheKey]
end

function ELT:GetDefaultStartMode(contentType, zoneKey)
    local derived, reason = self:GetAchievementDerivedStartMode(contentType, zoneKey)
    if derived then
        return derived, "derived"
    end
    return "manual", reason or "unrecognizedDescription"
end

function ELT:GetStartMode(contentType)
    local zoneKey = self:GetCurrentZoneKey()
    local key = string.format("%s|%s", contentType or "unknown", zoneKey)
    local mode = self:GetTimerModeMap()[key]
    if mode == "enter" or mode == "combat" or mode == "boss" or mode == "manual" then
        return mode, zoneKey, "userOverride"
    end
    local defaultMode, reason = self:GetDefaultStartMode(contentType, zoneKey)
    return defaultMode, zoneKey, reason
end

function ELT:SetStartMode(contentType, mode)
    local zoneKey = self:GetCurrentZoneKey()
    local key = string.format("%s|%s", contentType or "unknown", zoneKey)
    self:GetTimerModeMap()[key] = mode
    return zoneKey
end

function ELT:ClearStartMode(contentType)
    local zoneKey = self:GetCurrentZoneKey()
    local key = string.format("%s|%s", contentType or "unknown", zoneKey)
    self:GetTimerModeMap()[key] = nil
    return zoneKey
end

function ELT:CanAutoStartForMode(mode)
    if mode == "enter" then
        return true
    elseif mode == "combat" then
        return SafeCall(IsUnitInCombat, "player") == true
    elseif mode == "boss" then
        return self:IsBossCombatActive()
    elseif mode == "manual" then
        return false
    end
    return false
end

function ELT:NotifyManualTimerStart(contentType, zoneKey, reason)
    if reason == nil or reason == "derived" or reason == "userOverride" then
        return
    end
    if type(self.manualStartHintShown) ~= "table" then
        self.manualStartHintShown = {}
    end
    local key = string.format("%s|%s", contentType or "unknown", zoneKey or "")
    if self.manualStartHintShown[key] then
        return
    end
    self.manualStartHintShown[key] = true

    local pretty = contentType and (contentType:sub(1, 1):upper() .. contentType:sub(2)) or "Timer"
    local cmd = "trialtimer"
    if contentType == "dungeon" then
        cmd = "dungeontimer"
    elseif contentType == "arena" then
        cmd = "arenatimer"
    end
    local reasonText = "speedrun start rule is not recognized for this zone"
    if reason == "missingEntry" then
        reasonText = "no speedrun achievement mapping exists for this zone"
    elseif reason == "missingDescription" then
        reasonText = "the speedrun achievement description is unavailable"
    end
    Msg(string.format("%s timer auto-start disabled (%s). Start manually with /elt %s start.", pretty, reasonText, cmd))
end

function ELT:OnDisplayAnnouncement(...)
    -- Live build: trial auto-timer via announcements is intentionally disabled.
    if true then
        return
    end

    local mode, _, reason = self:GetStartMode("trial")
    local manualOverride = (mode == "manual" and reason == "userOverride")

    local function NormalizeAnnouncementText(value)
        local msg = zo_strlower(tostring(value or ""))
        -- Strip ESO color and texture markup to keep matching stable.
        msg = msg:gsub("|c%x%x%x%x%x%x", "")
        msg = msg:gsub("|r", "")
        msg = msg:gsub("|t.-|t", " ")
        msg = msg:gsub("[^%w]+", " ")
        msg = msg:gsub("^%s+", ""):gsub("%s+$", "")
        return msg
    end

    local function EvaluateAnnouncementText(rawText)
        if type(rawText) ~= "string" or rawText == "" then
            return false
        end
        local msg = NormalizeAnnouncementText(rawText)
        local isVet = msg:find(" vet ", 1, true) or msg:find(" veteran ", 1, true)
            or msg:find(" vet$", 1, false) or msg:find(" veteran$", 1, false)
        local started = (msg:find("started", 1, true) or msg:find("start", 1, true)) and isVet
        local completed = (msg:find("completed", 1, true) or msg:find("complete", 1, true)) and isVet

        if completed and self.trialTimerRunning then
            self:StopTrialTimer()
            self.trialAwaitingCombat = false
            return true
        end

        if started and not self.trialTimerRunning and not manualOverride then
            self:StartTrialTimer()
            self.trialAwaitingCombat = false
            return true
        end
        return false
    end

    local function ScanValue(value, depth)
        if depth > 2 then
            return false
        end
        if type(value) == "string" then
            return EvaluateAnnouncementText(value)
        elseif type(value) == "table" then
            for k, v in pairs(value) do
                if type(k) == "string" and (k == "text" or k == "message" or k == "title" or k == "body") then
                    if ScanValue(v, depth + 1) then
                        return true
                    end
                else
                    if ScanValue(v, depth + 1) then
                        return true
                    end
                end
            end
        end
        return false
    end

    local n = select("#", ...)
    for i = 1, n do
        if ScanValue(select(i, ...), 0) then
            return
        end
    end
end

function ELT:StartTrialTimer()
    if self.trialTimerRunning then
        return
    end
    self.trialTimerStartMs = self:GetNowMs()
    self.trialTimerRunning = true
end

function ELT:StopTrialTimer()
    if not self.trialTimerRunning then
        return
    end
    local now = self:GetNowMs()
    if self.trialTimerStartMs then
        self.trialTimerAccumMs = self.trialTimerAccumMs + zo_max(now - self.trialTimerStartMs, 0)
    end
    self.trialTimerStartMs = nil
    self.trialTimerRunning = false
end

function ELT:ResetTrialTimer()
    self.trialTimerAccumMs = 0
    if self.trialTimerRunning then
        self.trialTimerStartMs = self:GetNowMs()
    else
        self.trialTimerStartMs = nil
    end
end

function ELT:GetTrialTimerElapsedMs()
    local elapsed = self.trialTimerAccumMs or 0
    if self.trialTimerRunning and self.trialTimerStartMs then
        elapsed = elapsed + zo_max(self:GetNowMs() - self.trialTimerStartMs, 0)
    end
    return elapsed
end

function ELT:UpdateTrialTimerAuto()
    -- Live build: keep trial timer manual-only (no auto-start/auto-stop behavior).
    self.trialAutoInZone = false
    self.trialAwaitingCombat = false
    if self.trialTimerRunning then
        self:StopTrialTimer()
    end
    return
end

function ELT:StartDungeonTimer()
    if self.dungeonTimerRunning then
        return
    end
    self.dungeonTimerStartMs = self:GetNowMs()
    self.dungeonTimerRunning = true
end

function ELT:StopDungeonTimer()
    if not self.dungeonTimerRunning then
        return
    end
    local now = self:GetNowMs()
    if self.dungeonTimerStartMs then
        self.dungeonTimerAccumMs = self.dungeonTimerAccumMs + zo_max(now - self.dungeonTimerStartMs, 0)
    end
    self.dungeonTimerStartMs = nil
    self.dungeonTimerRunning = false
end

function ELT:ResetDungeonTimer()
    self.dungeonTimerAccumMs = 0
    if self.dungeonTimerRunning then
        self.dungeonTimerStartMs = self:GetNowMs()
    else
        self.dungeonTimerStartMs = nil
    end
end

function ELT:GetDungeonTimerElapsedMs()
    local elapsed = self.dungeonTimerAccumMs or 0
    if self.dungeonTimerRunning and self.dungeonTimerStartMs then
        elapsed = elapsed + zo_max(self:GetNowMs() - self.dungeonTimerStartMs, 0)
    end
    return elapsed
end

function ELT:UpdateDungeonTimerAuto()
    if not self.saved or self.saved.dungeonTimerAuto == false then
        self.dungeonAutoInZone = false
        self.dungeonAwaitingCombat = false
        return
    end

    local inDungeon = self:IsLikelyInDungeon()
    if inDungeon and not self.dungeonAutoInZone then
        self:ResetDungeonTimer()
        self:StopDungeonTimer()
        self.dungeonAwaitingCombat = true
    end

    if inDungeon then
        local mode, zoneKey, reason = self:GetStartMode("dungeon")
        if mode == "manual" then
            self.dungeonAwaitingCombat = false
            self:NotifyManualTimerStart("dungeon", zoneKey, reason)
        elseif self.dungeonAwaitingCombat then
            if self:CanAutoStartForMode(mode) then
                self:StartDungeonTimer()
                self.dungeonAwaitingCombat = false
            end
        elseif not self.dungeonTimerRunning and self:CanAutoStartForMode(mode) then
            self:StartDungeonTimer()
        end
    elseif not inDungeon and self.dungeonTimerRunning then
        self:StopDungeonTimer()
    end

    if not inDungeon then
        self.dungeonAwaitingCombat = false
    end
    self.dungeonAutoInZone = inDungeon
end

function ELT:StartArenaTimer()
    if self.arenaTimerRunning then
        return
    end
    self.arenaTimerStartMs = self:GetNowMs()
    self.arenaTimerRunning = true
end

function ELT:StopArenaTimer()
    if not self.arenaTimerRunning then
        return
    end
    local now = self:GetNowMs()
    if self.arenaTimerStartMs then
        self.arenaTimerAccumMs = self.arenaTimerAccumMs + zo_max(now - self.arenaTimerStartMs, 0)
    end
    self.arenaTimerStartMs = nil
    self.arenaTimerRunning = false
end

function ELT:ResetArenaTimer()
    self.arenaTimerAccumMs = 0
    if self.arenaTimerRunning then
        self.arenaTimerStartMs = self:GetNowMs()
    else
        self.arenaTimerStartMs = nil
    end
end

function ELT:GetArenaTimerElapsedMs()
    local elapsed = self.arenaTimerAccumMs or 0
    if self.arenaTimerRunning and self.arenaTimerStartMs then
        elapsed = elapsed + zo_max(self:GetNowMs() - self.arenaTimerStartMs, 0)
    end
    return elapsed
end

function ELT:UpdateArenaTimerAuto()
    if not self.saved or self.saved.arenaTimerAuto == false then
        self.arenaAutoInZone = false
        self.arenaAwaitingCombat = false
        return
    end

    local inArena = self:IsLikelyInArena()
    if inArena then
        local zoneKey = self:GetCurrentZoneKey()
        local speedrunArena = self:GetSpeedrunEntryForZone(zoneKey, "arena")
        inArena = speedrunArena ~= nil
    end
    if inArena and not self.arenaAutoInZone then
        self:ResetArenaTimer()
        self:StopArenaTimer()
        self.arenaAwaitingCombat = true
    end

    if inArena then
        local mode, zoneKey, reason = self:GetStartMode("arena")
        if mode == "manual" then
            self.arenaAwaitingCombat = false
            self:NotifyManualTimerStart("arena", zoneKey, reason)
        elseif self.arenaAwaitingCombat then
            if self:CanAutoStartForMode(mode) then
                self:StartArenaTimer()
                self.arenaAwaitingCombat = false
            end
        elseif not self.arenaTimerRunning and self:CanAutoStartForMode(mode) then
            self:StartArenaTimer()
        end
    elseif not inArena and self.arenaTimerRunning then
        self:StopArenaTimer()
    end

    if not inArena then
        self.arenaAwaitingCombat = false
    end
    self.arenaAutoInZone = inArena
end

function ELT:HandleSlashCommand(raw)
    local text = raw or ""
    text = text:gsub("^%s+", ""):gsub("%s+$", "")

    if text == "" then
        self:Toggle()
        return
    end

    local cmd, rest = text:match("^(%S+)%s*(.*)$")
    cmd = cmd and zo_strlower(cmd) or ""
    rest = rest or ""

    if cmd == "list" then
        local uiScale = self:GetUiScale()
        local textScale = self:GetEffectiveTextScale()
        Msg(string.format("Scale: base=%.2f effective=%.2f followUi=%s ui=%.2f", self.saved.textScale or 0.75, textScale, self.saved.followUiScale and "ON" or "OFF", uiScale))
        Msg("Hide in menus: ON (always)")
        self:ToggleSectionListWindow()
        return
    end

    if cmd == "order" then
        local subcmd, args = rest:match("^(%S+)%s*(.*)$")
        subcmd = subcmd and zo_strlower(subcmd) or "list"
        args = args or ""
        if subcmd == "list" then
            self:ListSections()
            return
        elseif subcmd == "reset" then
            self:ResetSectionOrder()
            Msg("Section order reset.")
            return
        elseif subcmd == "move" then
            local section, posText = args:match("^(%S+)%s+(%S+)$")
            if not section or not posText then
                Msg("Usage: /elt order move <section> <position>")
                return
            end
            local normalized = self:NormalizeSection(section)
            if not normalized then
                Msg("Unknown section. Use /elt list")
                return
            end
            local ok, result = self:MoveSection(normalized, posText)
            if ok then
                Msg(string.format("Moved %s -> #%d", normalized, result))
            else
                Msg(result or "Failed to move section")
            end
            return
        end
        Msg("Usage: /elt order list | /elt order move <section> <position> | /elt order reset")
        return
    end

    if cmd == "preset" then
        local subcmd, args = rest:match("^(%S+)%s*(.*)$")
        subcmd = subcmd and zo_strlower(subcmd) or "list"
        args = args or ""
        if subcmd == "list" then
            local presets = self:EnsurePresets()
            local names = {}
            for name in pairs(presets) do
                table.insert(names, name)
            end
            table.sort(names)
            if #names == 0 then
                Msg("No presets saved.")
            else
                Msg("Presets: " .. table.concat(names, ", "))
            end
            return
        elseif subcmd == "save" then
            local ok, info = self:SavePreset(args:match("^(%S+)$"))
            Msg(ok and ("Preset saved: " .. info) or info)
            return
        elseif subcmd == "load" then
            local ok, info = self:LoadPreset(args:match("^(%S+)$"))
            Msg(ok and ("Preset loaded: " .. info) or info)
            return
        elseif subcmd == "delete" then
            local ok, info = self:DeletePreset(args:match("^(%S+)$"))
            Msg(ok and ("Preset deleted: " .. info) or info)
            return
        end
        Msg("Usage: /elt preset list | /elt preset save <name> | /elt preset load <name> | /elt preset delete <name>")
        return
    end

    if cmd == "trialtimer" then
        Msg("Trial timer was removed from this release build.")
        return
    end

    if cmd == "dungeontimer" then
        Msg("Dungeon timer was removed from this release build.")
        return
    end

    if cmd == "arenatimer" then
        Msg("Arena timer was removed from this release build.")
        return
    end

    if cmd == "timermode" then
        Msg("Timer mode commands are disabled because content timers were removed.")
        return
    end

    if false and cmd == "trialtimer" then
        local subcmd = rest:match("^(%S+)")
        subcmd = subcmd and zo_strlower(subcmd) or "status"
        if subcmd == "start" then
            self:StartTrialTimer()
            Msg("Trial timer started.")
        elseif subcmd == "stop" then
            self:StopTrialTimer()
            Msg("Trial timer stopped.")
        elseif subcmd == "reset" then
            self:ResetTrialTimer()
            Msg("Trial timer reset.")
        elseif subcmd == "auto" then
            local opt = rest:match("^%S+%s+(%S+)")
            opt = opt and zo_strlower(opt) or ""
            if opt == "on" then
                self.saved.trialTimerAuto = true
                self:UpdateTrialTimerAuto()
                Msg("Trial timer auto -> ON")
            elseif opt == "off" then
                self.saved.trialTimerAuto = false
                Msg("Trial timer auto -> OFF")
            else
                Msg("Usage: /elt trialtimer auto on|off")
            end
        else
            local elapsed = FormatClockHMS(self:GetTrialTimerElapsedMs() / 1000)
            Msg(string.format("Trial timer: %s (%s)", elapsed, self.trialTimerRunning and "running" or "stopped"))
        end
        self:Refresh()
        return
    end

    if cmd == "dungeontimer" then
        local subcmd = rest:match("^(%S+)")
        subcmd = subcmd and zo_strlower(subcmd) or "status"
        if subcmd == "start" then
            self:StartDungeonTimer()
            Msg("Dungeon timer started.")
        elseif subcmd == "stop" then
            self:StopDungeonTimer()
            Msg("Dungeon timer stopped.")
        elseif subcmd == "reset" then
            self:ResetDungeonTimer()
            Msg("Dungeon timer reset.")
        elseif subcmd == "auto" then
            local opt = rest:match("^%S+%s+(%S+)")
            opt = opt and zo_strlower(opt) or ""
            if opt == "on" then
                self.saved.dungeonTimerAuto = true
                self:UpdateDungeonTimerAuto()
                Msg("Dungeon timer auto -> ON")
            elseif opt == "off" then
                self.saved.dungeonTimerAuto = false
                Msg("Dungeon timer auto -> OFF")
            else
                Msg("Usage: /elt dungeontimer auto on|off")
            end
        else
            local elapsed = FormatClockHMS(self:GetDungeonTimerElapsedMs() / 1000)
            Msg(string.format("Dungeon timer: %s (%s)", elapsed, self.dungeonTimerRunning and "running" or "stopped"))
        end
        self:Refresh()
        return
    end

    if cmd == "arenatimer" then
        local subcmd = rest:match("^(%S+)")
        subcmd = subcmd and zo_strlower(subcmd) or "status"
        if subcmd == "start" then
            self:StartArenaTimer()
            Msg("Arena timer started.")
        elseif subcmd == "stop" then
            self:StopArenaTimer()
            Msg("Arena timer stopped.")
        elseif subcmd == "reset" then
            self:ResetArenaTimer()
            Msg("Arena timer reset.")
        elseif subcmd == "auto" then
            local opt = rest:match("^%S+%s+(%S+)")
            opt = opt and zo_strlower(opt) or ""
            if opt == "on" then
                self.saved.arenaTimerAuto = true
                self:UpdateArenaTimerAuto()
                Msg("Arena timer auto -> ON")
            elseif opt == "off" then
                self.saved.arenaTimerAuto = false
                Msg("Arena timer auto -> OFF")
            else
                Msg("Usage: /elt arenatimer auto on|off")
            end
        else
            local elapsed = FormatClockHMS(self:GetArenaTimerElapsedMs() / 1000)
            Msg(string.format("Arena timer: %s (%s)", elapsed, self.arenaTimerRunning and "running" or "stopped"))
        end
        self:Refresh()
        return
    end

    if cmd == "timermode" then
        local content, mode = rest:match("^(%S+)%s*(%S*)$")
        content = content and zo_strlower(content) or ""
        mode = mode and zo_strlower(mode) or ""

        local validContent = content == "trial" or content == "dungeon" or content == "arena"
        local validMode = mode == "enter" or mode == "combat" or mode == "boss" or mode == "manual"

        if content == "status" or content == "" then
            local zone = self:GetCurrentZoneName()
            local tMode = self:GetStartMode("trial")
            local dMode = self:GetStartMode("dungeon")
            local aMode = self:GetStartMode("arena")
            Msg(string.format("Timer modes @ %s -> trial:%s dungeon:%s arena:%s", zone, tMode, dMode, aMode))
            return
        end

        if validContent and mode == "clear" then
            local zoneKey = self:ClearStartMode(content)
            Msg(string.format("Timer mode cleared for %s @ %s", content, zoneKey))
            return
        end

        if validContent and validMode then
            local zoneKey = self:SetStartMode(content, mode)
            Msg(string.format("Timer mode set: %s -> %s @ %s", content, mode, zoneKey))
            return
        end

        Msg("Usage: /elt timermode status | /elt timermode <trial|dungeon|arena> <enter|combat|boss|manual|clear>")
        return
    end

    if cmd == "reset" then
        self:ResetSections()
        self:ResetSectionOrder()
        if not self.contentTimersDisabled then
            self:ResetTrialTimer()
            self:ResetDungeonTimer()
            self:ResetArenaTimer()
        end
        Msg("Sections and order reset to default.")
        return
    end

    if cmd == "bump" then
        local opt = rest:match("^(%S+)")
        opt = opt and zo_strlower(opt) or ""
        if opt == "on" then
            self.saved.bumpCompass = true
            self.compassBumpApplied = false
            self:UpdateCompassBumpState()
            Msg("Compass bump -> ON")
        elseif opt == "off" then
            self.saved.bumpCompass = false
            self:UpdateCompassBumpState()
            Msg("Compass bump -> OFF")
        else
            Msg("Usage: /elt bump on|off")
        end
        return
    end

    if cmd == "box" then
        local opt = rest:match("^(%S+)")
        opt = opt and zo_strlower(opt) or ""
        if opt == "on" then
            self.saved.showBackground = true
            self:ApplyStyle()
            Msg("Toolbar box -> ON")
        elseif opt == "off" then
            self.saved.showBackground = false
            self:ApplyStyle()
            Msg("Toolbar box -> OFF")
        else
            Msg("Usage: /elt box on|off")
        end
        return
    end

    if cmd == "icons" then
        local opt = rest:match("^(%S+)")
        opt = opt and zo_strlower(opt) or ""
        if opt == "on" then
            self.saved.showIcons = true
            self:Refresh()
            Msg("Toolbar icons -> ON")
        elseif opt == "off" then
            self.saved.showIcons = false
            self:Refresh()
            Msg("Toolbar icons -> OFF")
        else
            Msg("Usage: /elt icons on|off")
        end
        return
    end

    if cmd == "uiscale" then
        local opt = rest:match("^(%S+)")
        opt = opt and zo_strlower(opt) or "status"
        if opt == "on" then
            self.saved.followUiScale = true
            self.lastUiScale = nil
            self.lastRenderedText = nil
            self:ApplyStyle()
            self:Refresh(true)
            Msg("UI scale follow -> ON")
        elseif opt == "off" then
            self.saved.followUiScale = false
            self.lastUiScale = nil
            self.lastRenderedText = nil
            self:ApplyStyle()
            self:Refresh(true)
            Msg("UI scale follow -> OFF")
        elseif opt == "status" then
            local uiScale = self:GetUiScale()
            local textScale = self:GetEffectiveTextScale()
            Msg(string.format("UI scale follow: %s (ui=%.2f, text=%.2f)", self.saved.followUiScale and "ON" or "OFF", uiScale, textScale))
        else
            Msg("Usage: /elt uiscale on|off|status")
        end
        return
    end

    if cmd == "scale" then
        local opt = rest:match("^(%S+)")
        opt = opt and zo_strlower(opt) or "status"
        if opt == "status" then
            local uiScale = self:GetUiScale()
            local textScale = self:GetEffectiveTextScale()
            Msg(string.format("Scale: base=%.2f effective=%.2f followUi=%s ui=%.2f", self.saved.textScale or 0.75, textScale, self.saved.followUiScale and "ON" or "OFF", uiScale))
        else
            local value = tonumber(opt)
            if not value then
                Msg("Usage: /elt scale <0.60-2.50> | /elt scale status")
                return
            end
            value = zo_clamp(value, 0.60, 2.50)
            self.saved.textScale = value
            self.lastRenderedScale = nil
            self.lastRenderedUiScale = nil
            self:ApplyStyle()
            self:Refresh(true)
            local uiScale = self:GetUiScale()
            local textScale = self:GetEffectiveTextScale()
            Msg(string.format("Scale set: base=%.2f effective=%.2f (followUi=%s ui=%.2f)", value, textScale, self.saved.followUiScale and "ON" or "OFF", uiScale))
        end
        return
    end

    if cmd == "on" or cmd == "off" then
        local section = rest:match("^(%S+)")
        if not section then
            Msg("Usage: /elt on <section> or /elt off <section>")
            return
        end
        local ok, normalized = self:SetSectionEnabled(section, cmd == "on")
        if ok then
            Msg(string.format("%s -> %s", normalized, cmd == "on" and "ON" or "OFF"))
        else
            Msg("Unknown section. Use /elt list")
        end
        return
    end

    if cmd == "only" then
        if rest == "" then
            Msg("Usage: /elt only <section1> <section2> ...")
            return
        end
        local chosen = {}
        for token in rest:gmatch("%S+") do
            local normalized = self:NormalizeSection(token)
            if normalized then
                chosen[normalized] = true
            end
        end
        if next(chosen) == nil then
            Msg("No valid sections given. Use /elt list")
            return
        end
        for _, key in ipairs(DEFAULT_SECTION_ORDER) do
            self.saved.sections[key] = chosen[key] == true
        end
        self:Refresh()
        Msg("Applied custom section set.")
        return
    end

    Msg("Commands: /elt, /elt list, /elt on/off, /elt only, /elt order, /elt preset, /elt box on|off, /elt icons on|off, /elt scale <0.60-2.50>|status, /elt uiscale on|off|status, /elt bump on|off, /elt reset")
end

function ELT:Refresh(forceRefresh)
    if not self.control or not self.label then
        return
    end
    self:UpdateToolbarVisibility()
    self:PerfCount("refresh_calls", 1)

    if forceRefresh == nil then
        forceRefresh = true
    end
    if not forceRefresh then
        local nowMs = self:GetNowMs()
        local autoIntervalMs = 250
        if self.lastAutoRefreshMs and (nowMs - self.lastAutoRefreshMs) < autoIntervalMs then
            return
        end
        self.lastAutoRefreshMs = nowMs
    end

    local text = self:BuildText()
    local baseScale = self:GetEffectiveTextScale()
    local uiScale = self:GetUiScale()
    local textChanged = (text ~= self.lastRenderedText)
    local scaleChanged = (self.lastRenderedScale == nil) or (math.abs(baseScale - self.lastRenderedScale) > 0.0001)
    local uiScaleChanged = (self.lastRenderedUiScale == nil) or (math.abs(uiScale - self.lastRenderedUiScale) > 0.0001)

    if textChanged or scaleChanged or uiScaleChanged then
        self.label:SetScale(baseScale)
        self.label:SetText(text)

        local maxWidth = (self.control:GetWidth() or 0) - (40 / uiScale)
        local textWidth = self.label:GetTextWidth()
        if maxWidth > 0 and textWidth and textWidth > maxWidth then
            local fitScale = zo_clamp(baseScale * (maxWidth / textWidth), 0.5, baseScale)
            self.label:SetScale(fitScale)
        end
        self.lastRenderedText = text
        self.lastRenderedScale = baseScale
        self.lastRenderedUiScale = uiScale
    end

    if self.sectionListControl and not self.sectionListControl:IsHidden() then
        self:UpdateSectionListWindow()
    end
end

function ELT:GetUiScale()
    local scale = 1.0
    if GuiRoot and type(GuiRoot.GetScale) == "function" then
        local ok, value = pcall(function() return GuiRoot:GetScale() end)
        if ok and type(value) == "number" and value > 0 then
            scale = value
        end
    end
    return scale
end

function ELT:GetEffectiveTextScale()
    local baseScale = self.saved.textScale or 0.75
    if not self.saved.followUiScale then
        return baseScale
    end
    local uiScale = self:GetUiScale()
    return zo_clamp(baseScale / uiScale, 0.5, 2.5)
end

function ELT:ShouldHideForMenuScene()
    if not self.saved then
        return false
    end
    if not SCENE_MANAGER or type(SCENE_MANAGER.GetCurrentScene) ~= "function" then
        return false
    end

    local current = SCENE_MANAGER:GetCurrentScene()
    if not current or type(current.GetName) ~= "function" then
        return false
    end

    local sceneName = current:GetName()
    sceneName = sceneName and zo_strlower(sceneName) or ""
    if sceneName == "" then
        return false
    end

    if sceneName == "hud" or sceneName == "hudui" then
        return false
    end
    if self.sectionListSceneName and sceneName == zo_strlower(self.sectionListSceneName) then
        return false
    end

    return true
end

function ELT:UpdateToolbarVisibility()
    if not self.control or not self.saved then
        return
    end
    local shouldHide = (not self.saved.enabled) or self:ShouldHideForMenuScene()
    self.control:SetHidden(shouldHide)
end

function ELT:ApplyStyle()
    if not self.control then
        return
    end
    self.control:ClearAnchors()
    self.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, self.saved.offsetY)
    self.control:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, 0, self.saved.offsetY)
    self.control:SetScale(self.saved.scale or 1.0)
    self.control:SetAlpha(self.saved.alpha or 1.0)
    if self.label then
        local ok = pcall(function()
            self.label:SetFont(GetToolbarFontDescriptor(self.saved.fontSize))
        end)
        if not ok then
            self.label:SetFont("ZoFontGame")
        end
        self.label:SetScale(self:GetEffectiveTextScale())
    end
    if self.bg then
        self.bg:SetHidden(not self.saved.showBackground)
    end
end

function ELT:GetCompassControl()
    if self.compassControl then
        return self.compassControl
    end

    local candidates = {
        "ZO_CompassFrame",
        "ZO_CompassContainer",
        "ZO_Compass",
    }
    for _, name in ipairs(candidates) do
        local ctrl = _G[name]
        if ctrl and type(ctrl.GetNumAnchors) == "function" then
            local ok, num = pcall(function() return ctrl:GetNumAnchors() end)
            if ok and num and num > 0 then
                self.compassControl = ctrl
                return ctrl
            end
        end
    end

    for _, name in ipairs(candidates) do
        local ctrl = _G[name]
        if ctrl and type(ctrl.GetNumAnchors) == "function" then
            self.compassControl = ctrl
            return ctrl
        end
    end
    return nil
end

function ELT:GetFirstValidAnchor(ctrl)
    if not ctrl or type(ctrl.GetNumAnchors) ~= "function" then
        return nil
    end

    local okNum, numAnchors = pcall(function() return ctrl:GetNumAnchors() end)
    if not okNum or not numAnchors or numAnchors <= 0 then
        return nil
    end

    local function TryIndex(i)
        local ok, point, relTo, relPoint, x, y = pcall(function()
            return ctrl:GetAnchor(i)
        end)
        if ok and point and relPoint then
            return {
                point = point,
                relTo = relTo or GuiRoot,
                relPoint = relPoint,
                x = x or 0,
                y = y or 0,
            }
        end
        return nil
    end

    -- Some controls expose anchors with 0-based indices, others with 1-based.
    for i = 0, numAnchors - 1 do
        local anchor = TryIndex(i)
        if anchor then return anchor end
    end
    for i = 1, numAnchors do
        local anchor = TryIndex(i)
        if anchor then return anchor end
    end

    return nil
end

function ELT:RestoreCompassAnchors()
    local ctrl = self:GetCompassControl()
    if not ctrl or not self.compassBaseAnchor then
        return
    end
    local ok = pcall(function()
        ctrl:ClearAnchors()
        ctrl:SetAnchor(
            self.compassBaseAnchor.point,
            self.compassBaseAnchor.relTo,
            self.compassBaseAnchor.relPoint,
            self.compassBaseAnchor.x,
            self.compassBaseAnchor.y
        )
    end)
    if not ok then
        self.saved.bumpCompass = false
        Msg("Compass bump disabled: restore failed on this UI mode.")
    end
    self.compassBumpApplied = false
end

function ELT:ApplyCompassBump()
    local ctrl = self:GetCompassControl()
    if not ctrl then
        return
    end

    if self.compassBumpApplied then
        return
    end

    local base = self:GetFirstValidAnchor(ctrl)
    if not base then
        self.saved.bumpCompass = false
        Msg("Compass bump disabled: unable to read compass anchor.")
        return
    end

    self.compassBaseAnchor = base

    local bumpY = self.saved.compassOffsetY or defaults.compassOffsetY
    local ok = pcall(function()
        ctrl:ClearAnchors()
        ctrl:SetAnchor(
            self.compassBaseAnchor.point,
            self.compassBaseAnchor.relTo,
            self.compassBaseAnchor.relPoint,
            self.compassBaseAnchor.x,
            self.compassBaseAnchor.y + bumpY
        )
    end)
    if ok then
        self.compassBumpApplied = true
    else
        self.saved.bumpCompass = false
        self.compassBumpApplied = false
        Msg("Compass bump disabled: unsupported anchor layout.")
    end
end

function ELT:UpdateCompassBumpState()
    if not self.saved.bumpCompass then
        if self.compassBumpApplied then
            self:RestoreCompassAnchors()
        end
        return
    end

    if self.saved.enabled then
        self:ApplyCompassBump()
    elseif self.compassBumpApplied then
        self:RestoreCompassAnchors()
    end
end

function ELT:Toggle()
    if not self.control then
        return
    end
    self.saved.enabled = not self.saved.enabled
    self:UpdateToolbarVisibility()
    self:UpdateCompassBumpState()
end

function ELT:CreateToolbar()
    local wm = WINDOW_MANAGER

    self.control = wm:CreateTopLevelWindow("ELT_Toolbar")
    self.control:SetDimensions(200, 34)
    self.control:SetMouseEnabled(false)
    self.control:SetMovable(false)
    self.control:SetClampedToScreen(true)
    self.control:SetDrawLayer(DL_OVERLAY)
    self.control:SetDrawTier(DT_HIGH)
    self.control:SetDrawLevel(10)

    self.bg = wm:CreateControl(nil, self.control, CT_BACKDROP)
    self.bg:SetAnchorFill(self.control)
    self.bg:SetCenterColor(0.03, 0.03, 0.03, 0.32)
    self.bg:SetEdgeColor(0.85, 0.85, 0.85, 0.70)
    self.bg:SetInsets(-8, -4, 8, 4)

    self.label = wm:CreateControl(nil, self.control, CT_LABEL)
    self.label:SetAnchorFill(self.control)
    self.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.label:SetColor(1, 1, 1, 1)

    self:ApplyStyle()
    self:UpdateToolbarVisibility()
end

function ELT:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("EsoLiveToolbarSV", SV_VERSION, nil, defaults)

    -- Migrate old "scale makes whole bar bigger" to "textScale only".
    if self.saved.textScale == nil then
        if self.saved.scale and self.saved.scale > 1.0 then
            self.saved.textScale = self.saved.scale
            self.saved.scale = 1.0
        else
            self.saved.textScale = 0.75
        end
    end

    if not self.saved.scale or self.saved.scale < 1.0 then
        self.saved.scale = 1.0
    end
    if not self.saved.fontSize or self.saved.fontSize < 10 then
        self.saved.fontSize = 12
    end
    if self.saved.fontSize > 12 then
        self.saved.fontSize = 12
    end
    self.saved.offsetX = 0
    if not self.saved.offsetY or self.saved.offsetY > 0 then
        self.saved.offsetY = 0
    end
    if self.saved.textScale > 2.5 then
        self.saved.textScale = 2.5
    end
    if self.saved.textScale < 0.6 then
        self.saved.textScale = 0.6
    end
    if self.saved.followUiScale == nil then
        self.saved.followUiScale = true
    end
    if self.saved.hideInMenu == nil then
        self.saved.hideInMenu = false
    end
    if self.saved.showBackground == nil then
        self.saved.showBackground = true
    end
    if self.saved.showIcons == nil then
        self.saved.showIcons = true
    end
    self.saved.trialTimerAuto = false
    self.saved.dungeonTimerAuto = false
    self.saved.arenaTimerAuto = false
    self.saved.timerModes = {}
    if type(self.saved.sectionOrder) ~= "table" then
        self.saved.sectionOrder = CopyArray(DEFAULT_SECTION_ORDER)
    end
    if type(self.saved.presets) ~= "table" then
        self.saved.presets = {}
    end

    self.trialTimerRunning = false
    self.trialTimerStartMs = nil
    self.trialTimerAccumMs = 0
    self.trialAutoInZone = false
    self.trialAwaitingCombat = false
    self.dungeonTimerRunning = false
    self.dungeonTimerStartMs = nil
    self.dungeonTimerAccumMs = 0
    self.dungeonAutoInZone = false
    self.dungeonAwaitingCombat = false
    self.arenaTimerRunning = false
    self.arenaTimerStartMs = nil
    self.arenaTimerAccumMs = 0
    self.arenaAutoInZone = false
    self.arenaAwaitingCombat = false
    self.speedrunModeCache = {}
    self.speedrunModeReasonCache = {}
    self.manualStartHintShown = {}
    self.lastUiScale = self:GetUiScale()
    self:UpdateTrialTimerAuto()
    self:UpdateDungeonTimerAuto()
    self:UpdateArenaTimerAuto()

    self:CreateToolbar()
    self:Refresh()
    self:UpdateCompassBumpState()

    if EVENT_DISPLAY_ANNOUNCEMENT then
        EVENT_MANAGER:RegisterForEvent(self.name .. "_DisplayAnnouncement", EVENT_DISPLAY_ANNOUNCEMENT, function(_, ...)
            self:OnDisplayAnnouncement(...)
        end)
    end

    EVENT_MANAGER:RegisterForUpdate(self.name .. "_Update", UPDATE_MS, function()
        local currentUiScale = self:GetUiScale()
        if self.lastUiScale == nil or math.abs(currentUiScale - self.lastUiScale) > 0.01 then
            self.lastUiScale = currentUiScale
            self:ApplyStyle()
        end
        if not self.contentTimersDisabled then
            self:UpdateTrialTimerAuto()
            self:UpdateDungeonTimerAuto()
            self:UpdateArenaTimerAuto()
        end
        self:UpdateToolbarVisibility()
        self:Refresh(false)
        -- Some UI transitions can re-anchor compass; keep bump enforced.
        self:UpdateCompassBumpState()
    end)

    SLASH_COMMANDS["/elt"] = function(text) self:HandleSlashCommand(text) end
    SLASH_COMMANDS["/esolivetoolbar"] = function(text) self:HandleSlashCommand(text) end
end

function ELT_ToggleToolbar()
    ELT:Toggle()
    return true
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ELT.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ELT.name, EVENT_ADD_ON_LOADED)
    ELT:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ELT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
