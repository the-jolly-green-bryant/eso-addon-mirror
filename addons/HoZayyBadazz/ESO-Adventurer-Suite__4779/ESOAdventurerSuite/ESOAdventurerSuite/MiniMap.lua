-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.MiniMap = EPC.MiniMap or {}
local M = EPC.MiniMap

-- v0.27.00 minimap rebuild: delegate map-state ownership and cross-map
-- coordinate conversion to the established ESO libraries instead of forcing
-- the World Map ourselves.
local LMD = LibMapData
local GPS = LibGPS3
local LMP = LibMapPins

local EPC_SQUARE_FRAME_TEXTURE = "ESOAdventurerSuite/Art/minimap_eso_square_frame.dds"

local wm = WINDOW_MANAGER

local COLORS = {
    white = {0.96, 0.97, 0.99, 1},
    muted = {0.68, 0.72, 0.78, 1},
    gold = {0.91, 0.70, 0.28, 1},
    cyan = {0.30, 0.78, 0.94, 1},
    blue = {0.30, 0.55, 0.96, 1},
    purple = {0.69, 0.46, 0.94, 1},
    green = {0.34, 0.82, 0.48, 1},
    red = {0.90, 0.28, 0.28, 1},
}

local PLAYER_TEXTURE = "EsoUI/Art/MapPins/UI-WorldMapPlayerPip.dds"
local GROUP_TEXTURE = "EsoUI/Art/MapPins/UI-WorldMapGroupPip.dds"

local function headingFromMapDelta(dx, dy)
    dx, dy = tonumber(dx), tonumber(dy)
    if not dx or not dy then return nil end
    if math.abs(dx) < 0.000001 and math.abs(dy) < 0.000001 then return nil end

    -- ESO map Y increases downward. Convert movement into the same clockwise
    -- radians used by SetTextureRotation/GetMapPlayerPosition: 0 = north.
    local x = -dy
    local y = dx
    local angle
    if x > 0 then
        angle = math.atan(y / x)
    elseif x < 0 and y >= 0 then
        angle = math.atan(y / x) + math.pi
    elseif x < 0 and y < 0 then
        angle = math.atan(y / x) - math.pi
    elseif x == 0 and y > 0 then
        angle = math.pi * 0.5
    elseif x == 0 and y < 0 then
        angle = -math.pi * 0.5
    else
        angle = 0
    end
    if angle < 0 then angle = angle + (math.pi * 2) end
    return angle
end
local WAYPOINT_TEXTURE = "EsoUI/Art/MapPins/UI_Worldmap_pin_customDestination_white.dds"
local COMPANION_TEXTURE = "EsoUI/Art/MapPins/activeCompanion_pin.dds"
local POI_FALLBACK_TEXTURE = WAYPOINT_TEXTURE

-- Promote sell-capable town merchants to an always-on minimap layer.
local function isStableMasterPOI(name, icon)
    local text = string.lower(tostring(name or "") .. " " .. tostring(icon or ""))
    local needles = {
        "stablemaster", "stable master", "servicepin_stable", "servicetooltipicon_stablemaster", "stable"
    }
    for i = 1, #needles do
        if string.find(text, needles[i], 1, true) then return true end
    end
    return false
end

local function isSellMerchantPOI(name, icon)
    local text = string.lower(tostring(name or "") .. " " .. tostring(icon or ""))
    local needles = {
        "merchant", "vendor", "generalstore", "general_store", "general goods",
        "shop", "store", "armsman", "armorer", "clothier", "woodworker",
        "alchemist", "enchanter", "mystic", "chef", "brewer", "outfitter",
        "blacksmith", "weaponsmith"
    }
    for i = 1, #needles do
        if string.find(text, needles[i], 1, true) then return true end
    end
    return false
end


local STORE_TYPE_LABELS = {
    blacksmith = "Blacksmith", clothier = "Clothier", woodworker = "Woodworker",
    alchemist = "Alchemist", enchanter = "Enchanter", grocer = "Grocer",
    brewer = "Brewer", chef = "Chef", mystic = "Mystic", stable = "Stable",
    armsman = "Armsman", armorer = "Armorer", merchant = "Merchant",
}

local function classifyStoreText(text)
    text = string.lower(tostring(text or ""))
    local rules = {
        {"blacksmith", "blacksmith"}, {"weaponsmith", "blacksmith"}, {"smith", "blacksmith"},
        {"clothier", "clothier"}, {"tailor", "clothier"},
        {"woodworker", "woodworker"}, {"woodworking", "woodworker"},
        {"alchemist", "alchemist"}, {"alchemy", "alchemist"}, {"potion", "alchemist"}, {"poison", "alchemist"},
        {"enchanter", "enchanter"}, {"enchant", "enchanter"}, {"glyph", "enchanter"},
        {"grocer", "grocer"}, {"provision", "grocer"}, {"ingredient", "grocer"},
        {"brewer", "brewer"}, {"drink", "brewer"},
        {"chef", "chef"}, {"food", "chef"},
        {"mystic", "mystic"}, {"jewelry", "mystic"},
        {"stable", "stable"}, {"horse", "stable"}, {"mount", "stable"},
        {"armsman", "armsman"}, {"weapon", "armsman"},
        {"armorer", "armorer"}, {"armor", "armorer"},
    }
    for i = 1, #rules do
        if string.find(text, rules[i][1], 1, true) then return rules[i][2] end
    end
    return nil
end

local VALID_MODES = {
    SMART = true,
    QUEST = true,
    EXPLORE = true,
    GROUP = true,
    MINIMAL = true,
    CUSTOM = true,
}

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e, f, g, h, i = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d, e, f, g, h, i
end

local function getGroupRoleDotColor(unitTag)
    if type(GetGroupMemberSelectedRole) == "function" then
        local role = safe(GetGroupMemberSelectedRole, LFG_ROLE_INVALID, unitTag)
        if LFG_ROLE_TANK ~= nil and role == LFG_ROLE_TANK then return COLORS.blue end
        if LFG_ROLE_HEAL ~= nil and role == LFG_ROLE_HEAL then return COLORS.green end
        if LFG_ROLE_DPS ~= nil and role == LFG_ROLE_DPS then return COLORS.red end
    end
    return COLORS.cyan
end

-- Collapse multi-return ESO APIs before numeric conversion. This avoids
-- accidentally feeding a second API return into tonumber(value, base).
local function safeNumber(fn, fallback, ...)
    local value = safe(fn, fallback, ...)
    local number = tonumber(value)
    if number ~= nil then return number end
    return tonumber(fallback) or 0
end

local function clamp(value, low, high)
    value = tonumber(value) or low
    if value < low then return low end
    if value > high then return high end
    return value
end

local function clean(text, fallback)
    text = tostring(text or "")
    text = string.gsub(text, "[%c]+", " ")
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    if text == "" then return fallback or "" end
    return text
end

-- Defined after safe/safeNumber/clean so these are captured as locals rather
-- than looked up as globals when a store opens.
function M:GetCurrentStoreIdentity()
    local storeName = "Merchant"
    if type(GetStoreName) == "function" then
        local rawName = safe(GetStoreName, "Merchant")
        storeName = clean(rawName, "Merchant")
    end

    local storeType = classifyStoreText(storeName)
    local representativeIcon = nil
    local sampleText = storeName

    if type(GetNumStoreItems) == "function" and type(GetStoreEntryInfo) == "function" then
        local count = math.min(24, safeNumber(GetNumStoreItems, 0))
        for i = 1, count do
            local icon, itemName = safe(GetStoreEntryInfo, nil, i)
            icon = tostring(icon or "")
            itemName = tostring(itemName or "")
            if not representativeIcon and icon ~= "" then representativeIcon = icon end
            sampleText = sampleText .. " " .. itemName .. " " .. icon
            if not storeType then storeType = classifyStoreText(itemName .. " " .. icon) end
        end
    end

    storeType = storeType or classifyStoreText(sampleText) or "merchant"
    return storeName, storeType, representativeIcon or POI_FALLBACK_TEXTURE
end


-- Legacy walk-up/interaction pin learning is retired in 0.27.02.
-- Native ESO/LibMapPins town icons are now the authoritative source.
-- Keep the old functions for saved-variable compatibility, but do not learn or
-- render those historical pins after the user clears them.
M.LEGACY_LEARNED_PINS_ENABLED = false

-- Learned town services. ESO does not expose every service NPC/station through
-- the regular POI list, so remember the player's exact map position when a
-- service UI is actually used. Whenever possible, borrow the nearest ESO POI
-- texture so the learned pin matches the icon the base game uses for that spot.
local CRAFTING_SERVICE_TYPES = {}
local function addCraftingServiceType(constantValue, key, label)
    if constantValue ~= nil then CRAFTING_SERVICE_TYPES[constantValue] = { key=key, label=label } end
end
addCraftingServiceType(CRAFTING_TYPE_BLACKSMITHING, "blacksmithing", "Blacksmithing Station")
addCraftingServiceType(CRAFTING_TYPE_CLOTHIER, "clothing", "Clothing Station")
addCraftingServiceType(CRAFTING_TYPE_WOODWORKING, "woodworking", "Woodworking Station")
addCraftingServiceType(CRAFTING_TYPE_ALCHEMY, "alchemy", "Alchemy Station")
addCraftingServiceType(CRAFTING_TYPE_ENCHANTING, "enchanting", "Enchanting Table")
addCraftingServiceType(CRAFTING_TYPE_PROVISIONING, "provisioning", "Provisioning Station")
addCraftingServiceType(CRAFTING_TYPE_JEWELRYCRAFTING, "jewelry", "Jewelry Crafting Station")
addCraftingServiceType(CRAFTING_TYPE_SCRIBING, "scribing", "Scribing Altar")

-- Service-specific ESO UI art used only when the base map does not expose a
-- nearby service pin. The first choice is always the actual nearby ESO POI
-- texture captured at interaction time.
local SERVICE_FALLBACK_ICONS = {
    stable = "EsoUI/Art/Icons/ServiceMapPins/servicepin_stable.dds",
    enchanting = "EsoUI/Art/Crafting/crafting_runestone02_slot.dds",
    jewelry = "EsoUI/Art/Crafting/jewelry_tabIcon_icon_up.dds",
    blacksmithing = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
    clothing = "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds",
    woodworking = "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds",
    alchemy = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_up.dds",
    provisioning = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_up.dds",
    scribing = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_up.dds",
    service = "EsoUI/Art/Inventory/inventory_tabIcon_crafting_up.dds",
}

local function getServiceFallbackIcon(kind)
    return SERVICE_FALLBACK_ICONS[tostring(kind or "service")] or SERVICE_FALLBACK_ICONS.service
end

function M:FindNearestPOIIdentity(x, y, kind, label)
    local zoneIndex = tonumber(self.zoneIndex)
    if not zoneIndex or type(GetNumPOIs) ~= "function" or type(GetPOIMapInfo) ~= "function" then
        return nil, nil
    end
    local wanted = string.lower(tostring(kind or "") .. " " .. tostring(label or ""))
    local bestName, bestIcon, bestScore
    local count = safeNumber(GetNumPOIs, 0, zoneIndex)
    for poiIndex = 1, count do
        local px, py, _, icon, shown, locked = safe(GetPOIMapInfo, nil, zoneIndex, poiIndex)
        px, py = tonumber(px), tonumber(py)
        if shown == true and locked ~= true and px and py then
            local name = ""
            if type(GetPOIInfo) == "function" then
                name = clean(select(1, safe(GetPOIInfo, "", zoneIndex, poiIndex)), "")
            end
            local dx, dy = px - x, py - y
            local d2 = dx * dx + dy * dy
            -- Search a wider neighborhood than before. Town service icons are
            -- often offset from the exact NPC/station interaction position.
            if d2 <= 0.000625 then
                local hay = string.lower(name .. " " .. tostring(icon or ""))
                local score = d2
                -- Strongly prefer a nearby pin whose name/texture resembles
                -- the service we just interacted with.
                for token in string.gmatch(wanted, "%a+") do
                    if #token >= 4 and string.find(hay, token, 1, true) then
                        score = score - 0.001
                    end
                end
                if icon and icon ~= "" and (bestScore == nil or score < bestScore) then
                    bestScore, bestName, bestIcon = score, name, icon
                end
            end
        end
    end
    return bestName, bestIcon
end

function M:RememberServiceHere(kind, label, iconOverride)
    if self.LEGACY_LEARNED_PINS_ENABLED ~= true then return false end
    if not EPC.saved then return false end
    kind = tostring(kind or "service")
    if kind == "stable" then return false end

    -- Save services in the exact minimap map context currently being rendered.
    -- Using a cached pre-interaction map caused stable records to land in the
    -- wrong bucket on some characters.
    local mapId = tonumber(self.mapId)
    local x, y

    if not mapId and type(GetCurrentMapId) == "function" then mapId = safeNumber(GetCurrentMapId, 0) end
    if not mapId or mapId <= 0 then return false end

    if not x or not y then
        local px, py, _, shown = safe(GetMapPlayerPosition, nil, "player")
        px, py = tonumber(px), tonumber(py)
        if shown == true and px and py and px > 0 and px < 1 and py > 0 and py < 1 then
            x, y = px, py
        end
    end

    -- Interaction scenes can hide map-position data. Fall back to the most
    -- recent minimap position if the direct API position is unavailable.
    if not x or not y or x <= 0 or x >= 1 or y <= 0 or y >= 1 then
        x, y = tonumber(self.playerX), tonumber(self.playerY)
    end
    if not x or not y or x <= 0 or x >= 1 or y <= 0 or y >= 1 then return false end

    local poiName, poiIcon = self:FindNearestPOIIdentity(x, y, kind, label)
    local name = clean(label or poiName, "Service")
    local icon = iconOverride
    if not icon or icon == "" then icon = poiIcon end
    if not icon or icon == "" then icon = getServiceFallbackIcon(kind) end

    EPC.saved.miniMapKnownServices = EPC.saved.miniMapKnownServices or {}
    local mapKey = tostring(mapId)
    local list = EPC.saved.miniMapKnownServices[mapKey]
    if type(list) ~= "table" then list = {}; EPC.saved.miniMapKnownServices[mapKey] = list end

    for i = 1, #list do
        local old = list[i]
        local dx = x - (tonumber(old.x) or -10)
        local dy = y - (tonumber(old.y) or -10)
        -- Every learned service is a one-time location. Interaction callbacks
        -- can report slightly different coordinates on later visits, so use a
        -- forgiving radius and never append/update a second copy.
        local sameLocationRadius2 = 0.000225
        if tostring(old.kind or "service") == kind and (dx * dx + dy * dy) < sameLocationRadius2 then
            return true
        end
    end

    list[#list + 1] = { x=x, y=y, kind=kind, name=name, icon=icon, learned=true, lastSeen=safeNumber(GetTimeStamp, 0) }
    while #list > 80 do table.remove(list, 1) end
    self.staticPinsDirty = true
    return true
end

function M:RememberCurrentCraftingStation()
    if type(GetCraftingInteractionType) ~= "function" then return false end
    local craftingType = safeNumber(GetCraftingInteractionType, 0)
    local info = CRAFTING_SERVICE_TYPES[craftingType]
    if not info then return false end
    return self:RememberServiceHere(info.key, info.label)
end

function M:RememberStableHere()
    -- Stable learning was removed. Native ESO stable POIs, when exposed by the
    -- map API, are rendered as ordinary POIs instead of being persisted by us.
    return false
end

-- Stable masters are not exposed consistently through one dedicated event on
-- every UI/input path. Detect them while the conversation/chatter window is
-- still open, before the stable scene can hide map-position data.
function M:ChatterLooksLikeStable()
    if type(GetNumChatterOptions) ~= "function" or type(GetChatterOption) ~= "function" then return false end
    local count = safeNumber(GetNumChatterOptions, 0)
    for i = 1, count do
        local text, optionType = safe(GetChatterOption, nil, i)
        local lower = string.lower(tostring(text or ""))
        -- English text fallback plus optional API constants when present.
        if string.find(lower, "stable", 1, true)
            or string.find(lower, "riding", 1, true)
            or string.find(lower, "train mount", 1, true)
            or string.find(lower, "train my mount", 1, true)
            or (CHATTER_START_STABLE ~= nil and optionType == CHATTER_START_STABLE)
            or (CHATTER_BEGIN_STABLE ~= nil and optionType == CHATTER_BEGIN_STABLE)
            or (CHATTER_STABLE ~= nil and optionType == CHATTER_STABLE) then
            return true
        end
    end
    return false
end

function M:ActiveSceneLooksLikeStable()
    if not SCENE_MANAGER then return false end
    local scene = nil
    if type(SCENE_MANAGER.GetCurrentScene) == "function" then
        scene = safe(function() return SCENE_MANAGER:GetCurrentScene() end, nil)
    end
    if scene and type(scene.GetName) == "function" then
        local name = string.lower(tostring(safe(function() return scene:GetName() end, "") or ""))
        if string.find(name, "stable", 1, true) or string.find(name, "riding", 1, true) then return true end
    end
    return false
end

local function mapPointNear(ax, ay, bx, by, radius2)
    ax, ay, bx, by = tonumber(ax), tonumber(ay), tonumber(bx), tonumber(by)
    if not ax or not ay or not bx or not by then return false end
    local dx, dy = ax - bx, ay - by
    return (dx * dx + dy * dy) <= (radius2 or 0.000225)
end

local function normalizedPinIdentity(item)
    if type(item) ~= "table" then return "" end
    local name = string.lower(clean(item.name or "", ""))
    local icon = string.lower(tostring(item.icon or ""))
    local kind = string.lower(tostring(item.kind or item.storeType or ""))
    local pinType = tostring(item.pinType or "")
    return name .. "|" .. icon .. "|" .. kind .. "|" .. pinType
end

-- Merchant dedupe must identify the actual store, not just the map position.
-- This preserves two genuinely different merchants that happen to stand beside
-- each other while preventing repeated visits to the same merchant from adding
-- another saved pin.
local function normalizedMerchantIdentity(item)
    if type(item) ~= "table" then return "" end
    local name = string.lower(clean(item.name or "", ""))
    local storeType = string.lower(tostring(item.storeType or "merchant"))
    local icon = string.lower(tostring(item.icon or ""))
    if name ~= "" and name ~= "merchant" and name ~= "store" then
        return name .. "|" .. storeType
    end
    return name .. "|" .. storeType .. "|" .. icon
end

function M:CleanupLearnedMapData()
    if not EPC.saved then return end

    -- Remove the abandoned custom stable-learning records entirely.
    if type(EPC.saved.miniMapKnownServices) == "table" then
        for mapKey, list in pairs(EPC.saved.miniMapKnownServices) do
            if type(list) == "table" then
                local compact = {}
                for i = 1, #list do
                    local item = list[i]
                    if type(item) == "table" and tostring(item.kind or "service") ~= "stable" then
                        local duplicate = false
                        for j = 1, #compact do
                            local old = compact[j]
                            if tostring(old.kind or "service") == tostring(item.kind or "service")
                                and mapPointNear(old.x, old.y, item.x, item.y, 0.000225) then
                                duplicate = true
                                break
                            end
                        end
                        if not duplicate then compact[#compact + 1] = item end
                    end
                end
                EPC.saved.miniMapKnownServices[mapKey] = compact
            end
        end
    end

    -- Collapse legacy duplicate merchant records created by repeated visits.
    if type(EPC.saved.miniMapKnownMerchants) == "table" then
        for mapKey, list in pairs(EPC.saved.miniMapKnownMerchants) do
            if type(list) == "table" then
                local compact = {}
                for i = 1, #list do
                    local item = list[i]
                    if type(item) == "table" then
                        local duplicate = false
                        for j = 1, #compact do
                            local old = compact[j]
                            local sameIdentity = normalizedMerchantIdentity(old) == normalizedMerchantIdentity(item)
                            if sameIdentity and mapPointNear(old.x, old.y, item.x, item.y, 0.000225) then
                                duplicate = true
                                break
                            end
                        end
                        if not duplicate then compact[#compact + 1] = item end
                    end
                end
                EPC.saved.miniMapKnownMerchants[mapKey] = compact
            end
        end
    end

    -- Collapse duplicate learned POIs while preserving genuinely different POIs
    -- that happen to be close together in dense towns.
    if type(EPC.saved.miniMapKnownPOIs) == "table" then
        for mapKey, list in pairs(EPC.saved.miniMapKnownPOIs) do
            if type(list) == "table" then
                local compact = {}
                for i = 1, #list do
                    local item = list[i]
                    if type(item) == "table" then
                        local duplicate = false
                        local ident = normalizedPinIdentity(item)
                        for j = 1, #compact do
                            local old = compact[j]
                            if ident ~= "|||" and ident == normalizedPinIdentity(old)
                                and mapPointNear(old.x, old.y, item.x, item.y, 0.000225) then
                                duplicate = true
                                break
                            end
                        end
                        if not duplicate then compact[#compact + 1] = item end
                    end
                end
                EPC.saved.miniMapKnownPOIs[mapKey] = compact
            end
        end
    end
end

function M:ClearLegacyMapIcons()
    if not EPC.saved then return false end

    -- These are the pre-0.27 walk-up/interaction caches. Do NOT clear
    -- miniMapNativeTownPins: those are the new ESO/LibMapPins snapshots.
    EPC.saved.miniMapKnownServices = {}
    EPC.saved.miniMapKnownMerchants = {}
    EPC.saved.miniMapKnownPOIs = {}

    -- Drop any already-built legacy rows from the current render and force a
    -- clean native-pin rebuild immediately.
    self.merchantData = {}
    self.serviceData = {}
    self.poiData = {}
    self.staticPinsDirty = true
    if type(self.RefreshStaticPins) == "function" then self:RefreshStaticPins() end
    if type(self.UpdatePanAndPins) == "function" then self:UpdatePanAndPins(true) end

    if EPC.Print then
        EPC:Print("Legacy walk-up map icons cleared. Native ESO town icons, checkpoints, and minimap settings were kept.")
    end
    return true
end

function M:RememberVisiblePOIs()
    if self.LEGACY_LEARNED_PINS_ENABLED ~= true then return end
    if not EPC.saved then return end
    local mapId, zoneIndex = tonumber(self.mapId), tonumber(self.zoneIndex)
    if not mapId or not zoneIndex or type(GetNumPOIs) ~= "function" or type(GetPOIMapInfo) ~= "function" then return end
    EPC.saved.miniMapKnownPOIs = EPC.saved.miniMapKnownPOIs or {}
    local mapKey = tostring(mapId)
    local list = EPC.saved.miniMapKnownPOIs[mapKey]
    if type(list) ~= "table" then list = {}; EPC.saved.miniMapKnownPOIs[mapKey] = list end

    local count = safeNumber(GetNumPOIs, 0, zoneIndex)
    for poiIndex = 1, count do
        local x, y, pinType, icon, shown, locked, discovered, nearby = safe(GetPOIMapInfo, nil, zoneIndex, poiIndex)
        x, y = tonumber(x), tonumber(y)
        if shown == true and locked ~= true and x and y and (discovered == true or nearby == true) then
            local name = type(GetPOIInfo) == "function" and clean(select(1, safe(GetPOIInfo, "", zoneIndex, poiIndex)), "Point of Interest") or "Point of Interest"
            local found = false
            for i = 1, #list do
                local old = list[i]
                local dx, dy = x - (tonumber(old.x) or -10), y - (tonumber(old.y) or -10)
                if (dx * dx + dy * dy) < 0.000225 then
                    found = true
                    break
                end
            end
            if not found then list[#list + 1] = { x=x, y=y, name=name, icon=icon, pinType=pinType, learned=true } end
        end
    end
    while #list > 220 do table.remove(list, 1) end
end

function M:AddRememberedServices()
    if self.LEGACY_LEARNED_PINS_ENABLED ~= true then return end
    if not EPC.saved then return end
    local mapId = tonumber(self.mapId)
    if not mapId then return end

    self.serviceData = self.serviceData or {}
    local services = type(EPC.saved.miniMapKnownServices) == "table" and EPC.saved.miniMapKnownServices[tostring(mapId)] or nil
    if type(services) == "table" then
        for i = 1, #services do
            local saved = services[i]
            local x, y = tonumber(saved.x), tonumber(saved.y)
            local kind = tostring(saved.kind or "service")
            if kind ~= "stable" and x and y and x > 0 and x < 1 and y > 0 and y < 1 then
                local duplicate = false
                for j = 1, #self.serviceData do
                    local old = self.serviceData[j]
                    if tostring(old.kind or "service") == kind and mapPointNear(old.x, old.y, x, y, 0.000225) then
                        duplicate = true
                        break
                    end
                end
                -- If ESO already exposes a live POI at this spot, prefer the
                -- native pin rather than drawing a second learned icon on top.
                if not duplicate then
                    for j = 1, #(self.poiData or {}) do
                        local old = self.poiData[j]
                        if mapPointNear(old.x, old.y, x, y, 0.000225) then
                            duplicate = true
                            break
                        end
                    end
                end
                if not duplicate then
                    local rememberedIcon = saved.icon
                    if not rememberedIcon or rememberedIcon == "" or rememberedIcon == POI_FALLBACK_TEXTURE then
                        rememberedIcon = getServiceFallbackIcon(kind)
                        saved.icon = rememberedIcon
                    end
                    self.serviceData[#self.serviceData + 1] = {
                        x=x, y=y, name=clean(saved.name, "Service"), icon=rememberedIcon,
                        kind=kind, discovered=true, nearby=true, learned=true, isService=true,
                    }
                end
            end
        end
    end

    local pois = type(EPC.saved.miniMapKnownPOIs) == "table" and EPC.saved.miniMapKnownPOIs[tostring(mapId)] or nil
    if type(pois) == "table" then
        self.poiData = self.poiData or {}
        for i = 1, #pois do
            local saved = pois[i]
            local x, y = tonumber(saved.x), tonumber(saved.y)
            if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                local duplicate = false
                -- Prefer live ESO POIs over remembered copies.
                for j = 1, #self.poiData do
                    local old = self.poiData[j]
                    if mapPointNear(old.x, old.y, x, y, 0.000225) then
                        duplicate = true
                        break
                    end
                end
                -- Also prevent an old remembered POI from duplicating a learned
                -- merchant/service at the same location.
                if not duplicate then
                    for j = 1, #(self.merchantData or {}) do
                        local old = self.merchantData[j]
                        if mapPointNear(old.x, old.y, x, y, 0.000225) then
                            duplicate = true
                            break
                        end
                    end
                end
                if not duplicate then
                    for j = 1, #(self.serviceData or {}) do
                        local old = self.serviceData[j]
                        if mapPointNear(old.x, old.y, x, y, 0.000225) then
                            duplicate = true
                            break
                        end
                    end
                end
                if not duplicate then
                    self.poiData[#self.poiData + 1] = {
                        x=x, y=y, name=clean(saved.name, "Point of Interest"), icon=saved.icon,
                        pinType=saved.pinType, discovered=true, nearby=true, learned=true, distance2=0,
                    }
                end
            end
        end
    end
end

local function directionText(dx, dy)
    dx = tonumber(dx) or 0
    dy = tonumber(dy) or 0
    local ax, ay = math.abs(dx), math.abs(dy)
    if ax < 0.00001 and ay < 0.00001 then return "HERE" end
    if ax < ay * 0.42 then return dy < 0 and "N" or "S" end
    if ay < ax * 0.42 then return dx > 0 and "E" or "W" end
    if dx > 0 then return dy < 0 and "NE" or "SE" end
    return dy < 0 and "NW" or "SW"
end

local function nowSeconds()
    if type(GetFrameTimeSeconds) == "function" then return tonumber(GetFrameTimeSeconds()) or 0 end
    if type(GetGameTimeMilliseconds) == "function" then return (tonumber(GetGameTimeMilliseconds()) or 0) / 1000 end
    return 0
end

local function makeBackdrop(parent, name)
    local control = wm:CreateControl(name, parent, CT_BACKDROP)
    control:SetCenterColor(0.035, 0.045, 0.060, 0.22)
    control:SetEdgeColor(0.20, 0.23, 0.30, 0.34)
    control:SetEdgeTexture(nil, 1, 1, 1)
    return control
end

local function makeLabel(parent, name, font, color, align)
    local label = wm:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "$(BOLD_FONT)|14|soft-shadow-thin")
    label:SetColor(unpack(color or COLORS.white))
    label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    if label.SetMaxLineCount then label:SetMaxLineCount(1) end
    return label
end

local function easSceneIsShowingOrShown(scene)
    if not scene then return false end
    if type(scene.IsShowing) == "function" then
        local ok, showing = pcall(scene.IsShowing, scene)
        if ok and showing == true then return true end
    end
    -- ESO commonly builds native map pins while the scene is still entering
    -- SCENE_SHOWING. IsShowing() can remain false during that exact window,
    -- so accept SHOWING/SHOWN explicitly without accepting hidden background
    -- map changes used by quest/travel resolution.
    if type(scene.GetState) == "function" then
        local ok, state = pcall(scene.GetState, scene)
        if ok then
            if SCENE_SHOWING ~= nil and state == SCENE_SHOWING then return true end
            if SCENE_SHOWN ~= nil and state == SCENE_SHOWN then return true end
        end
    end
    return false
end

local function isWorldMapShowing()
    if easSceneIsShowingOrShown(WORLD_MAP_SCENE) then return true end
    if easSceneIsShowingOrShown(GAMEPAD_WORLD_MAP_SCENE) then return true end
    return false
end

local MENU_SCENES = {
    "inventory", "character", "skills", "championPerks", "journal",
    "collectionsBook", "groupMenu", "contacts", "guildHome", "mailInbox",
    "bank", "store", "tradingHouse", "crafting", "gameMenuInGame", "settings",
}

local function isMenuShowing()
    if type(IsGameCameraUIModeActive) == "function" then
        local ok, active = pcall(IsGameCameraUIModeActive)
        if ok and active == true then return true end
    end
    if SCENE_MANAGER and type(SCENE_MANAGER.IsShowing) == "function" then
        for i = 1, #MENU_SCENES do
            local ok, showing = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, MENU_SCENES[i])
            if ok and showing == true then return true end
        end
    end
    return false
end

function M:GetMode()
    local mode = string.upper(tostring(EPC.saved and EPC.saved.miniMapMode or "SMART"))
    if not VALID_MODES[mode] then mode = "SMART" end
    return mode
end

function M:SetMode(mode)
    if not EPC.saved then return false end
    mode = string.upper(tostring(mode or ""))
    if not VALID_MODES[mode] then return false end
    EPC.saved.miniMapMode = mode
    self.staticPinsDirty = true
    self:RefreshStaticPins()
    self:UpdatePanAndPins(true)
    self:UpdateContextText(true)
    return true
end

function M:LayerEnabled(layer)
    if not EPC.saved then return false end
    local mode = self:GetMode()
    local profiles = {
        -- Navigation landmarks stay visible in every profile. Mode now changes
        -- supplemental layers, not the core town/POI/wayshrine information.
        SMART = { quest=true, waypoint=true, shrines=true, group=true, companion=true, rally=true, pois=true, trail=true },
        QUEST = { quest=true, waypoint=true, shrines=true, group=false, companion=false, rally=false, pois=true, trail=false },
        EXPLORE = { quest=true, waypoint=true, shrines=true, group=false, companion=false, rally=false, pois=true, trail=true },
        GROUP = { quest=true, waypoint=true, shrines=true, group=true, companion=true, rally=true, pois=true, trail=false },
        MINIMAL = { quest=true, waypoint=true, shrines=true, group=false, companion=false, rally=false, pois=true, trail=false },
        CUSTOM = { quest=true, waypoint=true, shrines=true, group=true, companion=true, rally=true, pois=true, trail=true },
    }
    local p = profiles[mode] or profiles.SMART
    if p[layer] ~= true then return false end

    local toggles = {
        quest = "miniMapShowQuest",
        waypoint = "miniMapShowWaypoint",
        shrines = "miniMapShowWayshrines",
        group = "miniMapShowGroup",
        companion = "miniMapShowCompanion",
        rally = "miniMapShowRally",
        pois = "miniMapShowPOIs",
        trail = "miniMapShowTrail",
    }
    local key = toggles[layer]
    if key and EPC.saved[key] == false then return false end

    -- Keep navigation landmarks visible even in combat. SMART may still hide the
    -- breadcrumb trail, but it never removes POIs or wayshrines from the map.
    if mode == "SMART" and safe(IsUnitInCombat, false, "player") == true then
        if layer == "trail" then return false end
    end
    return true
end

function M:SavePosition()
    if not EPC.saved or not self.frame then return end
    local left = tonumber(self.frame:GetLeft())
    local top = tonumber(self.frame:GetTop())
    if left and top then
        EPC.saved.miniMapLeft = left
        EPC.saved.miniMapTop = top
    end
end

function M:AnchorFrame()
    if not self.frame or not EPC.saved then return end
    self.frame:ClearAnchors()
    local left = tonumber(EPC.saved.miniMapLeft) or -1
    local top = tonumber(EPC.saved.miniMapTop) or -1
    if left >= 0 and top >= 0 then
        self.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        self.frame:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -34, 185)
    end
end

function M:ResetPosition()
    if not EPC.saved then return end
    EPC.saved.miniMapLeft = -1
    EPC.saved.miniMapTop = -1
    self:AnchorFrame()
end

function M:CreatePin(name, size, texture, color)
    local pin = wm:CreateControl(name, self.viewport, CT_TEXTURE)
    pin:SetDimensions(size, size)
    pin:SetTexture(texture or WAYPOINT_TEXTURE)
    pin:SetDrawLayer(DL_OVERLAY)
    pin:SetDrawLevel(60)
    if color then pin:SetColor(unpack(color)) end
    pin:SetHidden(true)
    return pin
end

-- Special game modes benefit from a denser, fully labeled navigation view.
-- Keep normal overland PvE icon-focused, but show names automatically in
-- Cyrodiil / Imperial City / Battlegrounds and instanced dungeons.
function M:IsPvPIconOnlyMode()
    if safe(IsPlayerInAvAWorld, false) == true then return true end
    if safe(IsActiveWorldBattleground, false) == true then return true end
    if safe(IsInCampaign, false) == true then return true end
    return false
end

function M:IsLabeledMapMode()
    -- PvP mirrors ESO's own Cyrodiil presentation: icons + alliance transit
    -- connections, without map-object names cluttering the field.
    if self:IsPvPIconOnlyMode() then return false end
    if type(IsUnitInDungeon) == "function" and safe(IsUnitInDungeon, false, "player") == true then return true end
    return false
end

function M:EnsureMapObjectLabels(kind, count)
    self.mapObjectLabels = self.mapObjectLabels or {}
    local pool = self.mapObjectLabels[kind]
    if not pool then pool = {}; self.mapObjectLabels[kind] = pool end
    for i = #pool + 1, count do
        local label = makeLabel(self.viewport, "EPC_MiniMap_Label_" .. tostring(kind) .. "_" .. tostring(i), "$(BOLD_FONT)|11|soft-shadow-thick", COLORS.white, TEXT_ALIGN_CENTER)
        label:SetDimensions(150, 18)
        label:SetDrawLayer(DL_OVERLAY)
        label:SetDrawLevel(96)
        label:SetHidden(true)
        pool[i] = label
    end
    return pool
end

function M:HideMapObjectLabels()
    if not self.mapObjectLabels then return end
    for _, pool in pairs(self.mapObjectLabels) do
        for i = 1, #pool do pool[i]:SetHidden(true) end
    end
end

function M:PlaceMapObjectLabel(label, text, x, y, yOffset, color)
    if not label or not text or text == "" then return false end
    local px, py, inside = self:MapToScreen(x, y)
    if not inside or px == nil or py == nil then label:SetHidden(true) return false end
    label:ClearAnchors()
    label:SetAnchor(TOP, self.viewport, TOPLEFT, px, py + (tonumber(yOffset) or 10))
    label:SetText(tostring(text))
    if color then label:SetColor(unpack(color)) else label:SetColor(unpack(COLORS.white)) end
    label:SetHidden(false)
    return true
end

function M:GetPvPPinTexture(pinType)
    if pinType == nil then return nil end
    if type(GetMapPinTexture) == "function" then
        local tex = safe(GetMapPinTexture, nil, pinType)
        if type(tex) == "string" and tex ~= "" then return tex end
    end
    if ZO_MapPin and type(ZO_MapPin.PIN_DATA) == "table" then
        local def = ZO_MapPin.PIN_DATA[pinType]
        if type(def) == "table" then
            local tex = def.texture
            if type(tex) == "string" and tex ~= "" then return tex end
            if type(tex) == "function" then
                local ok, value = pcall(tex, pinType)
                if ok and type(value) == "string" and value ~= "" then return value end
            end
        end
    end
    return nil
end

-- Normal PvE maps should use the same native-icon approach as the Cyrodiil
-- layer.  Prefer the exact texture ESO supplies for the POI.  Some POIs only
-- expose a MapDisplayPinType, so fall back to ESO's native pin definition
-- instead of drawing the Suite's generic custom-destination diamond.
function M:GetNativePvEMapPinTexture(icon, pinType)
    if type(icon) == "string" and icon ~= "" and icon ~= POI_FALLBACK_TEXTURE and icon ~= WAYPOINT_TEXTURE then
        return icon
    end
    local native = self:GetPvPPinTexture(pinType)
    if type(native) == "string" and native ~= "" and native ~= POI_FALLBACK_TEXTURE and native ~= WAYPOINT_TEXTURE then
        return native
    end
    return nil
end

-- v0.26.19 - Native town/service pin mirror. ESO creates the complete city/town
-- icon set on its World Map pin manager (banks, crafting, stables, merchants,
-- guild traders, shrines, etc.). Capture those native pins when ESO builds a
-- map and reuse their exact texture/coordinates on the Suite minimap.
local function easNativeTownPinIsDynamic(texture)
    local t = string.lower(tostring(texture or ""))
    if t == "" then return true end
    local dynamic = {
        "player", "group", "companion", "quest", "waypoint", "rally",
        "ping", "ava_", "battleground", "killlocation", "elder_scroll",
    }
    for i=1,#dynamic do if string.find(t, dynamic[i], 1, true) then return true end end
    return false
end

local function easUniversalPointForMap(mapId, x, y)
    mapId = tonumber(mapId) or 0
    x, y = tonumber(x), tonumber(y)
    if mapId <= 0 or x == nil or y == nil then return nil, nil end

    -- LibGPS measurements are map-id aware and do not require changing the
    -- player's visible World Map. This is the primary projection path.
    if GPS and type(GPS.GetMapMeasurementByMapId) == "function" then
        local ok, measurement = pcall(GPS.GetMapMeasurementByMapId, GPS, mapId)
        if ok and measurement and type(measurement.ToGlobal) == "function" then
            local ok2, gx, gy = pcall(measurement.ToGlobal, measurement, x, y)
            gx, gy = tonumber(gx), tonumber(gy)
            if ok2 and gx ~= nil and gy ~= nil then return gx, gy end
        end
    end

    -- Safe fallback for maps not yet measured by LibGPS. This API is passive;
    -- unlike SetMapToPlayerLocation/ProcessMapClick it never changes map state.
    if type(GetUniversallyNormalizedMapInfo) == "function" then
        local ok, ox, oy, w, h = pcall(GetUniversallyNormalizedMapInfo, mapId)
        ox, oy, w, h = tonumber(ox), tonumber(oy), tonumber(w), tonumber(h)
        if ok and ox and oy and w and h and w > 0 and h > 0 then
            return ox + (x * w), oy + (y * h)
        end
    end
    return nil, nil
end

local function easLocalPointForMap(mapId, gx, gy)
    mapId = tonumber(mapId) or 0
    gx, gy = tonumber(gx), tonumber(gy)
    if mapId <= 0 or gx == nil or gy == nil then return nil, nil end

    if GPS and type(GPS.GetMapMeasurementByMapId) == "function" then
        local ok, measurement = pcall(GPS.GetMapMeasurementByMapId, GPS, mapId)
        if ok and measurement and type(measurement.ToLocal) == "function" then
            local ok2, x, y = pcall(measurement.ToLocal, measurement, gx, gy)
            x, y = tonumber(x), tonumber(y)
            if ok2 and x and y then
                local epsilon = 0.001
                if x >= -epsilon and x <= 1 + epsilon and y >= -epsilon and y <= 1 + epsilon then
                    return clamp(x, 0, 1), clamp(y, 0, 1)
                end
            end
        end
    end

    if type(GetUniversallyNormalizedMapInfo) == "function" then
        local ok, ox, oy, w, h = pcall(GetUniversallyNormalizedMapInfo, mapId)
        ox, oy, w, h = tonumber(ox), tonumber(oy), tonumber(w), tonumber(h)
        if ok and ox and oy and w and h and w > 0 and h > 0 then
            local x, y = (gx - ox) / w, (gy - oy) / h
            local epsilon = 0.001
            if x >= -epsilon and x <= 1 + epsilon and y >= -epsilon and y <= 1 + epsilon then
                return clamp(x, 0, 1), clamp(y, 0, 1)
            end
        end
    end
    return nil, nil
end

function M:CaptureNativeTownPin(pinType, pinTag, x, y, textureOverride)
    if not EPC.saved then return end
    -- Only mirror pins produced by the World Map the player actually opened.
    -- Background quest/wayshrine scans also rebuild the native pin manager and
    -- must never be allowed to pollute this cache.
    if not self:IsWorldMapShowing() then return end
    x, y = tonumber(x), tonumber(y)
    if not x or not y or x < 0 or x > 1 or y < 0 or y > 1 then return end

    local mapId = 0
    if type(GetCurrentMapId) == "function" then mapId = tonumber(safe(GetCurrentMapId, 0)) or 0 end
    if mapId <= 0 then return end

    local texture = type(textureOverride) == "string" and textureOverride or nil
    if type(texture) ~= "string" or texture == "" then
        texture = self:GetNativePvEMapPinTexture(nil, pinType)
    end
    if (type(texture) ~= "string" or texture == "") and ZO_MapPin and type(ZO_MapPin.PIN_DATA) == "table" then
        local def = ZO_MapPin.PIN_DATA[pinType]
        local tex = type(def) == "table" and def.texture or nil
        if type(tex) == "function" then
            local attempts = {
                function() return tex(pinTag) end,
                function() return tex(pinType, pinTag) end,
                function() return tex(pinType) end,
            }
            for i=1,#attempts do
                local ok, value = pcall(attempts[i])
                if ok and type(value) == "string" and value ~= "" then texture=value; break end
            end
        elseif type(tex) == "string" then texture=tex end
    end
    if type(texture) ~= "string" or texture == "" or easNativeTownPinIsDynamic(texture) then return end

    local ux, uy = easUniversalPointForMap(mapId, x, y)
    local zoneIndex, zoneId, zoneName = 0, 0, ""
    if type(GetCurrentMapZoneIndex) == "function" then
        local ok, value = pcall(GetCurrentMapZoneIndex)
        if ok then zoneIndex = tonumber(value) or 0 end
    end
    if zoneIndex > 0 and type(GetZoneId) == "function" then
        local ok, value = pcall(GetZoneId, zoneIndex)
        if ok then zoneId = tonumber(value) or 0 end
    end
    if zoneIndex > 0 and type(GetZoneNameByIndex) == "function" then
        local ok, value = pcall(GetZoneNameByIndex, zoneIndex)
        if ok and type(value) == "string" then zoneName = clean(value, "") end
    end

    EPC.saved.miniMapNativeTownPins = EPC.saved.miniMapNativeTownPins or {}
    local key = tostring(mapId)
    local list = EPC.saved.miniMapNativeTownPins[key]
    if type(list) ~= "table" then list = {}; EPC.saved.miniMapNativeTownPins[key] = list end

    local name = "Map Location"
    if type(pinTag) == "table" then
        local zi = tonumber(pinTag.zoneIndex or pinTag.zone or 0) or 0
        local pi = tonumber(pinTag.poiIndex or pinTag.poi or 0) or 0
        if zi > 0 and pi > 0 and type(GetPOIInfo) == "function" then
            local n = select(1, safe(GetPOIInfo, "", zi, pi))
            if type(n) == "string" and n ~= "" then name = clean(n, name) end
        elseif type(pinTag.name) == "string" and pinTag.name ~= "" then
            name = clean(pinTag.name, name)
        end
    end

    local rx, ry = math.floor(x * 100000 + 0.5), math.floor(y * 100000 + 0.5)
    local id = tostring(pinType or "") .. ":" .. tostring(rx) .. ":" .. tostring(ry)
    for i=1,#list do
        if list[i] and list[i].id == id then
            list[i].texture, list[i].name, list[i].x, list[i].y = texture, name, x, y
            list[i].sourceMapId, list[i].ux, list[i].uy = mapId, ux, uy
            list[i].zoneIndex, list[i].zoneId, list[i].zoneName = zoneIndex, zoneId, zoneName
            self.staticPinsDirty = true
            self.nativeTownPinsChanged = true
            return
        end
    end
    list[#list+1] = {
        id=id, pinType=pinType, texture=texture, name=name, x=x, y=y,
        sourceMapId=mapId, ux=ux, uy=uy,
        zoneIndex=zoneIndex, zoneId=zoneId, zoneName=zoneName,
    }
    while #list > 320 do table.remove(list, 1) end
    self.staticPinsDirty = true
    self.nativeTownPinsChanged = true
end

function M:HookNativeTownPins()
    if self.nativeTownPinHooked then return end
    local owner = self

    -- Capture the fully initialized native pin whenever possible.  The old
    -- CreatePin pre-hook ran before ESO finished SetData(), which meant some
    -- city/service pins were cached with incomplete texture/tag information.
    -- Post-hooking ZO_MapPin:SetData gives us the final normalized position and
    -- the exact texture ESO chose for that pin.
    if ZO_MapPin and type(ZO_MapPin.SetData) == "function" and type(ZO_PostHook) == "function" then
        ZO_PostHook(ZO_MapPin, "SetData", function(pin, pinType, pinTag)
            if not owner:IsWorldMapShowing() or not pin then return end
            local x, y
            if type(pin.GetNormalizedPosition) == "function" then
                local ok, px, py = pcall(pin.GetNormalizedPosition, pin)
                if ok then x, y = tonumber(px), tonumber(py) end
            end
            if not x or not y then return end

            local texture
            if type(pin.GetControl) == "function" then
                local ok, control = pcall(pin.GetControl, pin)
                if ok and control then
                    if type(control.GetTextureFileName) == "function" then
                        local okTex, tex = pcall(control.GetTextureFileName, control)
                        if okTex and type(tex) == "string" and tex ~= "" then texture = tex end
                    end
                    if (not texture or texture == "") and type(control.GetNamedChild) == "function" then
                        local childNames = {"Icon", "Texture", "Pin", "MapPin"}
                        for i=1,#childNames do
                            local okChild, child = pcall(control.GetNamedChild, control, childNames[i])
                            if okChild and child and type(child.GetTextureFileName) == "function" then
                                local okTex, tex = pcall(child.GetTextureFileName, child)
                                if okTex and type(tex) == "string" and tex ~= "" then texture = tex; break end
                            end
                        end
                    end
                end
            end
            owner:CaptureNativeTownPin(pinType, pinTag, x, y, texture)
        end)
    end

    -- Keep the manager hook as a compatibility fallback for clients where the
    -- pin class cannot be post-hooked. Duplicate entries are deduped by id.
    if type(ZO_WorldMap_GetPinManager) == "function" and type(ZO_PreHook) == "function" then
        local manager = ZO_WorldMap_GetPinManager()
        if manager and type(manager.CreatePin) == "function" then
            ZO_PreHook(manager, "CreatePin", function(_, pinType, pinTag, x, y)
                owner:CaptureNativeTownPin(pinType, pinTag, x, y)
                return false
            end)
        end
    end
    self.nativeTownPinHooked = true
end

function M:CaptureAllNativeMapPins()
    -- LibMapPins exposes ESO's live World Map pin manager. Snapshot every
    -- finalized, non-dynamic native pin while the player is actually viewing
    -- the map, then project it onto the independent minimap via LibGPS.
    if not self:IsWorldMapShowing() or not LMP then return end
    local manager = LMP.pinManager
    if not manager and type(ZO_WorldMap_GetPinManager) == "function" then
        manager = ZO_WorldMap_GetPinManager()
    end
    if not manager or type(manager.GetActiveObjects) ~= "function" then return end

    local ok, pins = pcall(manager.GetActiveObjects, manager)
    if not ok or type(pins) ~= "table" then return end

    for _, pin in pairs(pins) do
        if pin then
            local pinType, pinTag
            if type(pin.GetPinTypeAndTag) == "function" then
                local okType, a, b = pcall(pin.GetPinTypeAndTag, pin)
                if okType then pinType, pinTag = a, b end
            elseif type(pin.GetPinType) == "function" then
                local okType, a = pcall(pin.GetPinType, pin)
                if okType then pinType = a end
            end

            local x, y
            if type(pin.GetNormalizedPosition) == "function" then
                local okPos, px, py = pcall(pin.GetNormalizedPosition, pin)
                if okPos then x, y = tonumber(px), tonumber(py) end
            end

            local texture
            if type(pin.GetControl) == "function" then
                local okControl, control = pcall(pin.GetControl, pin)
                if okControl and control then
                    local candidates = { control }
                    if type(GetControl) == "function" then
                        local okBg, bg = pcall(GetControl, control, "Background")
                        if okBg and bg then candidates[#candidates + 1] = bg end
                    end
                    if type(control.GetNamedChild) == "function" then
                        for _, childName in ipairs({"Background", "Icon", "Texture", "Pin", "MapPin"}) do
                            local okChild, child = pcall(control.GetNamedChild, control, childName)
                            if okChild and child then candidates[#candidates + 1] = child end
                        end
                    end
                    for i = 1, #candidates do
                        local c = candidates[i]
                        if c and type(c.GetTextureFileName) == "function" then
                            local okTex, tex = pcall(c.GetTextureFileName, c)
                            if okTex and type(tex) == "string" and tex ~= "" then
                                texture = tex
                                break
                            end
                        end
                    end
                end
            end

            if x and y then
                self:CaptureNativeTownPin(pinType, pinTag, x, y, texture)
            end
        end
    end
end

local function easUniversalMapRect(mapId)
    mapId = tonumber(mapId) or 0
    if mapId <= 0 or type(GetUniversallyNormalizedMapInfo) ~= "function" then return nil end
    local ok, ox, oy, w, h = pcall(GetUniversallyNormalizedMapInfo, mapId)
    ox, oy, w, h = tonumber(ox), tonumber(oy), tonumber(w), tonumber(h)
    if not ok or not ox or not oy or not w or not h or w <= 0 or h <= 0 then return nil end
    return { x=ox, y=oy, w=w, h=h, area=w*h }
end

local function easNativeTownPinAllowedOnMap(sourceMapId, currentMapId)
    sourceMapId = tonumber(sourceMapId) or 0
    currentMapId = tonumber(currentMapId) or 0
    if sourceMapId <= 0 or currentMapId <= 0 then return false end
    if sourceMapId == currentMapId then return true end

    local source = easUniversalMapRect(sourceMapId)
    local current = easUniversalMapRect(currentMapId)
    if not source or not current then
        -- Without map bounds, never project town-detail icons across map IDs.
        -- This avoids leaking city services onto the surrounding zone map.
        return false
    end

    -- Town/service detail may be captured from a parent map while ESO is
    -- building a town/sub-map. Allow projection only when the minimap is at
    -- least as detailed (same size or smaller) than the source map. Never
    -- project a smaller town map outward onto a larger overland/zone map.
    local tolerance = 1.02
    if current.area > (source.area * tolerance) then return false end

    -- The current map must also overlap the source map in universal space.
    local sx2, sy2 = source.x + source.w, source.y + source.h
    local cx2, cy2 = current.x + current.w, current.y + current.h
    local overlaps = not (cx2 < source.x or current.x > sx2 or cy2 < source.y or current.y > sy2)
    return overlaps
end

function M:AddCapturedNativeTownPins()
    if not EPC.saved or type(EPC.saved.miniMapNativeTownPins) ~= "table" then return end
    local currentMapId = tonumber(self.mapId) or 0
    if currentMapId <= 0 then return end

    local function alreadyNativeService(x, y, texture)
        for i=1,#(self.serviceData or {}) do
            local d=self.serviceData[i]
            if d and d.nativeTown == true and mapPointNear(d.x,d.y,x,y,0.00012) and tostring(d.icon or "") == tostring(texture or "") then
                return true
            end
        end
        return false
    end

    -- Native town pins are rendered through the always-on service pool rather
    -- than the optional POI layer.  This guarantees that the exact ESO icons
    -- captured from an opened city/town map remain visible on the minimap even
    -- when the user's generic POI layer is disabled or the normal POI scan does
    -- not expose those services.
    local caches = EPC.saved.miniMapNativeTownPins
    for cacheKey, list in pairs(caches) do
        if type(list) == "table" then
            local sourceMapId = tonumber(cacheKey) or 0
            local allowOnCurrentMap = easNativeTownPinAllowedOnMap(sourceMapId, currentMapId)
            if allowOnCurrentMap then
            for i=1,#list do
                local row=list[i]
                if type(row)=="table" and type(row.texture)=="string" and row.texture~="" then
                    local x, y
                    local ux, uy = tonumber(row.ux), tonumber(row.uy)
                    if ux ~= nil and uy ~= nil then
                        x, y = easLocalPointForMap(currentMapId, ux, uy)
                    elseif sourceMapId == currentMapId then
                        x, y = tonumber(row.x), tonumber(row.y)
                        if x and y and (x < 0 or x > 1 or y < 0 or y > 1) then x, y = nil, nil end
                    else
                        local lx, ly = tonumber(row.x), tonumber(row.y)
                        if sourceMapId > 0 and lx and ly then
                            ux, uy = easUniversalPointForMap(sourceMapId, lx, ly)
                            if ux and uy then
                                row.sourceMapId, row.ux, row.uy = sourceMapId, ux, uy
                                x, y = easLocalPointForMap(currentMapId, ux, uy)
                            end
                        end
                    end

                    if x and y and not alreadyNativeService(x,y,row.texture) then
                        local data={
                            x=x,y=y,icon=row.texture,name=clean(row.name,"Map Location"),
                            discovered=true,nearby=true,nativeIcon=true,nativeTown=true,
                            isService=true,kind="native_town",pinType=row.pinType,
                        }
                        if isStableMasterPOI(data.name,row.texture) then
                            data.kind="stable"
                            data.name=clean(data.name,"Stablemaster")
                        elseif isSellMerchantPOI(data.name,row.texture) then
                            data.kind="merchant"
                        end
                        self.serviceData[#self.serviceData+1]=data
                    end
                end
            end
            end
        end
    end
end

function M:GetPvPAllianceColor(alliance)
    alliance = tonumber(alliance) or 0
    if type(GetAllianceColor) == "function" and alliance > 0 then
        local r, g, b = safe(GetAllianceColor, nil, alliance)
        if tonumber(r) and tonumber(g) and tonumber(b) then return {r, g, b, 1} end
    end
    if alliance == ALLIANCE_ALDMERI_DOMINION then return {0.95, 0.78, 0.16, 1} end
    if alliance == ALLIANCE_DAGGERFALL_COVENANT then return {0.22, 0.50, 0.90, 1} end
    if alliance == ALLIANCE_EBONHEART_PACT then return {0.88, 0.24, 0.20, 1} end
    return COLORS.white
end

function M:EnsurePvPPins(count)
    self.pvpPins = self.pvpPins or {}
    for i = #self.pvpPins + 1, count do
        local pin = self:CreatePin("EPC_MiniMap_PvPObjective_" .. tostring(i), 26, POI_FALLBACK_TEXTURE, COLORS.white)
        pin:SetDrawLevel(88)
        self.pvpPins[i] = pin
    end
end

function M:HidePvPPins()
    for i = 1, #(self.pvpPins or {}) do self.pvpPins[i]:SetHidden(true) end
end

function M:EnsurePvPTransitLines(count)
    self.pvpTransitLines = self.pvpTransitLines or {}
    for i = #self.pvpTransitLines + 1, count do
        local line = wm:CreateControl("EPC_MiniMap_PvPTransit_" .. tostring(i), self.viewport, CT_LINE)
        line:SetThickness(3)
        line:SetColor(1, 1, 1, 0.88)
        line:SetDrawLayer(DL_OVERLAY)
        line:SetDrawLevel(82)
        line:SetHidden(true)
        self.pvpTransitLines[i] = line
    end
    return self.pvpTransitLines
end

function M:HidePvPTransitLines()
    for i = 1, #(self.pvpTransitLines or {}) do self.pvpTransitLines[i]:SetHidden(true) end
end

function M:PlacePvPTransitLine(line, data)
    if not line or not data then return false end
    local x1, y1, in1 = self:MapToScreen(data.startX, data.startY)
    local x2, y2, in2 = self:MapToScreen(data.endX, data.endY)
    if x1 == nil or y1 == nil or x2 == nil or y2 == nil or (not in1 and not in2) then
        line:SetHidden(true)
        return false
    end

    -- A LineControl stretches between two anchors. Pick opposing corners based
    -- on slope so both positive- and negative-slope Cyrodiil links render.
    line:ClearAnchors()
    if (x2 - x1) * (y2 - y1) >= 0 then
        local leftX, leftY, rightX, rightY
        if x1 <= x2 then leftX, leftY, rightX, rightY = x1, y1, x2, y2
        else leftX, leftY, rightX, rightY = x2, y2, x1, y1 end
        if leftY <= rightY then
            line:SetAnchor(TOPLEFT, self.viewport, TOPLEFT, leftX, leftY)
            line:SetAnchor(BOTTOMRIGHT, self.viewport, TOPLEFT, rightX, rightY)
        else
            line:SetAnchor(BOTTOMLEFT, self.viewport, TOPLEFT, leftX, leftY)
            line:SetAnchor(TOPRIGHT, self.viewport, TOPLEFT, rightX, rightY)
        end
    else
        local leftX, leftY, rightX, rightY
        if x1 <= x2 then leftX, leftY, rightX, rightY = x1, y1, x2, y2
        else leftX, leftY, rightX, rightY = x2, y2, x1, y1 end
        line:SetAnchor(BOTTOMLEFT, self.viewport, TOPLEFT, leftX, leftY)
        line:SetAnchor(TOPRIGHT, self.viewport, TOPLEFT, rightX, rightY)
    end

    local color = data.color or COLORS.white
    local alpha = data.active == false and 0.34 or 0.88
    line:SetColor(color[1] or 1, color[2] or 1, color[3] or 1, alpha)
    line:SetThickness(data.active == false and 2 or 3)
    line:SetHidden(false)
    return true
end

function M:RenderPvPTransitLines()
    local data = self.pvpTravelLinks or {}
    if safe(IsPlayerInAvAWorld, false) ~= true or #data == 0 then
        self:HidePvPTransitLines()
        return
    end
    local pool = self:EnsurePvPTransitLines(#data)
    local used = 0
    for i = 1, #data do
        local d = data[i]
        if d and d.startX and d.startY and d.endX and d.endY then
            used = used + 1
            self:PlacePvPTransitLine(pool[used], d)
        end
    end
    for i = used + 1, #pool do pool[i]:SetHidden(true) end
end

function M:RenderPvPPins()
    local data = self.pvpKeepData or {}
    if safe(IsPlayerInAvAWorld, false) ~= true or #data == 0 then self:HidePvPPins(); return end
    self:EnsurePvPPins(#data)
    local used = 0
    for i = 1, #data do
        local d = data[i]
        if d and d.x and d.y then
            used = used + 1
            local pin = self.pvpPins[used]
            local texture = d.texture
            if type(texture) == "string" and texture ~= "" then
                pin:SetTexture(texture)
                -- Native ESO PvP pin textures already encode ownership/state.
                pin:SetColor(1, 1, 1, 1)
            else
                pin:SetTexture(POI_FALLBACK_TEXTURE)
                pin:SetColor(unpack(d.color or COLORS.white))
            end
            local size = tonumber(d.size) or 26
            pin:SetDimensions(size, size)
            self:PlacePin(pin, d.x, d.y, size, false)
        end
    end
    for i = used + 1, #self.pvpPins do self.pvpPins[i]:SetHidden(true) end
end

function M:EnsureGroupPins(count)
    self.groupPins = self.groupPins or {}
    for i = #self.groupPins + 1, count do
        local pin = self:CreatePin("EPC_MiniMap_Group_" .. tostring(i), 16, GROUP_TEXTURE, COLORS.cyan)
        if type(pin.SetTextureCoords) == "function" then pin:SetTextureCoords(0, 1, 0, 1) end
        if type(pin.SetBlendMode) == "function" then pin:SetBlendMode(TEX_BLEND_MODE_ALPHA) end
        pin:SetDrawLevel(75)
        self.groupPins[i] = pin
    end
end

function M:EnsureShrinePins(count)
    self.shrinePins = self.shrinePins or {}
    for i = #self.shrinePins + 1, count do
        self.shrinePins[i] = self:CreatePin("EPC_MiniMap_Shrine_" .. tostring(i), 17, WAYPOINT_TEXTURE, COLORS.gold)
    end
end

function M:EnsurePOIPins(count)
    self.poiPins = self.poiPins or {}
    for i = #self.poiPins + 1, count do
        self.poiPins[i] = self:CreatePin("EPC_MiniMap_POI_" .. tostring(i), 17, POI_FALLBACK_TEXTURE, COLORS.white)
    end
end

function M:EnsureMerchantPins(count)
    self.merchantPins = self.merchantPins or {}
    for i = #self.merchantPins + 1, count do
        local pin = self:CreatePin("EPC_MiniMap_Merchant_" .. tostring(i), 22, POI_FALLBACK_TEXTURE, COLORS.gold)
        pin:SetDrawLayer(DL_OVERLAY)
        pin:SetDrawLevel(55)
        self.merchantPins[i] = pin
    end
end

function M:EnsureServicePins(count)
    self.servicePins = self.servicePins or {}
    self.serviceBackings = self.serviceBackings or {}
    for i = #self.servicePins + 1, count do
        -- A guaranteed-visible backing means a learned service can never vanish
        -- just because ESO rejects a service-specific texture path.
        local backing = self:CreatePin("EPC_MiniMap_ServiceBacking_" .. tostring(i), 30, POI_FALLBACK_TEXTURE, COLORS.gold)
        backing:SetDrawLayer(DL_OVERLAY)
        backing:SetDrawLevel(78)
        self.serviceBackings[i] = backing

        local pin = self:CreatePin("EPC_MiniMap_Service_" .. tostring(i), 24, POI_FALLBACK_TEXTURE, COLORS.white)
        pin:SetDrawLayer(DL_OVERLAY)
        -- Above the player arrow (70) so the Stable icon is visible immediately
        -- while the player is still standing on top of the learned location.
        pin:SetDrawLevel(82)
        self.servicePins[i] = pin
    end
end

function M:EnsureTrailPins(count)
    self.trailPins = self.trailPins or {}
    for i = #self.trailPins + 1, count do
        local pin = self:CreatePin("EPC_MiniMap_Trail_" .. tostring(i), 6, PLAYER_TEXTURE, COLORS.muted)
        pin:SetDrawLevel(8)
        self.trailPins[i] = pin
    end
end

function M:GetEffectiveZoom()
    -- ESO's map art is raster-based. Keeping the zoom range tighter prevents
    -- the minimap from magnifying the source tiles until they look blocky.
    local zoom = clamp(EPC.saved and EPC.saved.miniMapZoom or 0.90, 0.70, 1.35)
    if not EPC.saved or EPC.saved.miniMapAdaptiveZoom == false or self.layoutMode then return zoom end
    if safe(IsUnitInCombat, false, "player") == true then
        zoom = zoom * 1.22
    elseif safe(IsMounted, false) == true then
        zoom = zoom * 0.82
    end
    return clamp(zoom, 0.70, 1.35)
end

function M:IsInteractive()
    -- The suite interaction hotkey (often bound to Enter by users) enters ESO UI
    -- mode so the mouse is available. Keep the minimap usable in that mode without
    -- requiring the minimap to be unlocked/movable.
    return self.layoutMode == true or EPC.interactionMode == true
end

function M:AdjustZoom(delta)
    if not self:IsInteractive() or not EPC.saved then return end
    local zoom = clamp((tonumber(EPC.saved.miniMapZoom) or 0.90) + ((tonumber(delta) or 0) * 0.05), 0.70, 1.35)
    EPC.saved.miniMapZoom = zoom
    self:RebuildMap(true)
end

function M:BeginDrag(button)
    if not self.layoutMode or not self.frame then return end
    if MOUSE_BUTTON_INDEX_LEFT ~= nil and button ~= nil and button ~= MOUSE_BUTTON_INDEX_LEFT then return end
    if self.dragging then return end
    self.dragging = true
    if type(self.frame.StartMoving) == "function" then self.frame:StartMoving() end
end

function M:EndDrag()
    if not self.frame then return end
    if type(self.frame.StopMovingOrResizing) == "function" then self.frame:StopMovingOrResizing() end
    self.dragging = false
    self:SavePosition()
end

function M:Create()
    self.frame = wm:CreateTopLevelWindow("EPC_MiniMap")
    self.frame:SetClampedToScreen(true)
    self.frame:SetDrawTier(DT_HIGH)
    self.frame:SetDrawLayer(DL_CONTROLS)
    self.frame:SetMovable(true)
    self.frame:SetMouseEnabled(false)

    self.background = makeBackdrop(self.frame, "EPC_MiniMap_Background")
    self.background:SetAnchorFill(self.frame)

    -- Reliable ESO-style square minimap. Use a guaranteed visible gold frame backdrop
    -- plus the addon artwork as an optional decorative overlay.
    self.viewport = wm:CreateControl("EPC_MiniMap_Viewport", self.frame, CT_CONTROL)
    self.viewport:SetDrawLayer(DL_BACKGROUND)
    self.viewport:SetDrawLevel(5)
    if type(self.viewport.SetAutoRectClipChildren) == "function" then self.viewport:SetAutoRectClipChildren(true) end

    self.tileContainer = wm:CreateControl("EPC_MiniMap_Tiles", self.viewport, CT_CONTROL)
    self.tileContainer:SetDrawLayer(DL_BACKGROUND)
    self.tileContainer:SetDrawLevel(1)
    self.tiles = {}

    -- Modern map-surface treatment: a soft glass tint above the raw ESO tiles
    -- plus a subtle inner chrome ring so the minimap feels more like a modern
    -- navigation product without losing the ESO world-map art.
    self.mapGlass = makeBackdrop(self.viewport, "EPC_MiniMap_MapGlass")
    self.mapGlass:SetAnchorFill(self.viewport)
    self.mapGlass:SetDrawLayer(DL_OVERLAY)
    self.mapGlass:SetDrawLevel(6)
    self.mapGlass:SetMouseEnabled(false)

    self.mapChrome = makeBackdrop(self.viewport, "EPC_MiniMap_MapChrome")
    self.mapChrome:SetAnchorFill(self.viewport)
    self.mapChrome:SetDrawLayer(DL_OVERLAY)
    self.mapChrome:SetDrawLevel(7)
    self.mapChrome:SetMouseEnabled(false)

    self.mapNorthFade = makeBackdrop(self.viewport, "EPC_MiniMap_MapNorthFade")
    self.mapNorthFade:SetDrawLayer(DL_OVERLAY)
    self.mapNorthFade:SetDrawLevel(8)
    self.mapNorthFade:SetMouseEnabled(false)

    self.frameBorder = makeBackdrop(self.frame, "EPC_MiniMap_FrameBorder")
    self.frameBorder:SetAnchorFill(self.frame)
    self.frameBorder:SetDrawLayer(DL_OVERLAY)
    self.frameBorder:SetDrawLevel(50)
    self.frameBorder:SetMouseEnabled(false)

    -- Build the visible skin from native controls so it always renders, even if a
    -- custom DDS fails to load on a particular client install.
    local function skinPiece(name)
        local c = makeBackdrop(self.frame, name)
        c:SetDrawLayer(DL_OVERLAY)
        c:SetDrawLevel(58)
        c:SetMouseEnabled(false)
        return c
    end
    self.skinTop = skinPiece("EPC_MiniMap_SkinTop")
    self.skinBottom = skinPiece("EPC_MiniMap_SkinBottom")
    self.skinLeft = skinPiece("EPC_MiniMap_SkinLeft")
    self.skinRight = skinPiece("EPC_MiniMap_SkinRight")
    self.skinTL = skinPiece("EPC_MiniMap_SkinTL")
    self.skinTR = skinPiece("EPC_MiniMap_SkinTR")
    self.skinBL = skinPiece("EPC_MiniMap_SkinBL")
    self.skinBR = skinPiece("EPC_MiniMap_SkinBR")
    self.skinTopGem = skinPiece("EPC_MiniMap_SkinTopGem")

    self.esoFrame = wm:CreateControl("EPC_MiniMap_ESOFrame", self.frame, CT_TEXTURE)
    self.esoFrame:SetAnchorFill(self.frame)
    self.esoFrame:SetTexture(EPC_SQUARE_FRAME_TEXTURE)
    self.esoFrame:SetDrawLayer(DL_OVERLAY)
    self.esoFrame:SetDrawLevel(60)
    self.esoFrame:SetMouseEnabled(false)
    self.esoFrame:SetHidden(true)

    self.modeLabel = makeLabel(self.frame, "EPC_MiniMap_Mode", "$(BOLD_FONT)|11|soft-shadow-thick", COLORS.gold, TEXT_ALIGN_LEFT)
    self.modeLabel:SetAnchor(TOPLEFT, self.frame, TOPLEFT, 15, 10)
    self.modeLabel:SetDimensions(72, 20)
    self.modeLabel:SetDrawLayer(DL_OVERLAY)
    self.modeLabel:SetDrawLevel(55)
    self.modeLabel:SetHidden(true)

    self.zoneLabel = makeLabel(self.frame, "EPC_MiniMap_Zone", "$(BOLD_FONT)|14|soft-shadow-thick", COLORS.white, TEXT_ALIGN_CENTER)
    self.zoneLabel:SetAnchor(TOPLEFT, self.frame, TOPLEFT, 76, 10)
    self.zoneLabel:SetAnchor(TOPRIGHT, self.frame, TOPRIGHT, -56, 10)
    self.zoneLabel:SetHeight(20)
    self.zoneLabel:SetDrawLayer(DL_OVERLAY)
    self.zoneLabel:SetDrawLevel(55)
    self.zoneLabel:SetHidden(true)

    self.coordsLabel = makeLabel(self.frame, "EPC_MiniMap_Coords", "$(BOLD_FONT)|11|soft-shadow-thin", COLORS.muted, TEXT_ALIGN_RIGHT)
    self.coordsLabel:SetAnchor(TOPRIGHT, self.frame, TOPRIGHT, -14, 10)
    self.coordsLabel:SetDimensions(58, 20)
    self.coordsLabel:SetDrawLayer(DL_OVERLAY)
    self.coordsLabel:SetDrawLevel(55)
    self.coordsLabel:SetHidden(true)

    local function cardinal(name, text, point, relativePoint, x, y)
        local label = makeLabel(self.frame, name, "$(BOLD_FONT)|12|soft-shadow-thick", text == "N" and COLORS.gold or COLORS.muted, TEXT_ALIGN_CENTER)
        label:SetText(text)
        label:SetDimensions(18, 18)
        label:SetAnchor(point, self.frame, relativePoint, x, y)
        label:SetDrawLayer(DL_OVERLAY)
        label:SetDrawLevel(55)
        return label
    end
    self.northLabel = cardinal("EPC_MiniMap_North", "N", TOP, TOP, 0, 34)
    self.eastLabel = cardinal("EPC_MiniMap_East", "E", RIGHT, RIGHT, -12, 0)
    self.southLabel = cardinal("EPC_MiniMap_South", "S", BOTTOM, BOTTOM, 0, -34)
    self.westLabel = cardinal("EPC_MiniMap_West", "W", LEFT, LEFT, 12, 0)
    self.northLabel:SetHidden(true)
    self.eastLabel:SetHidden(true)
    self.southLabel:SetHidden(true)
    self.westLabel:SetHidden(true)

    self.contextLabel = makeLabel(self.frame, "EPC_MiniMap_Context", "$(BOLD_FONT)|11|soft-shadow-thin", COLORS.white, TEXT_ALIGN_CENTER)
    self.contextLabel:SetAnchor(BOTTOMLEFT, self.frame, BOTTOMLEFT, 18, -10)
    self.contextLabel:SetAnchor(BOTTOMRIGHT, self.frame, BOTTOMRIGHT, -18, -10)
    self.contextLabel:SetHeight(18)
    self.contextLabel:SetDrawLayer(DL_OVERLAY)
    self.contextLabel:SetDrawLevel(55)
    self.contextLabel:SetHidden(true)

    self.moveHint = makeLabel(self.frame, "EPC_MiniMap_MoveHint", "$(BOLD_FONT)|12|soft-shadow-thick", COLORS.gold, TEXT_ALIGN_CENTER)
    self.moveHint:SetText("DRAG MINI MAP  |  WHEEL = ZOOM  |  INTERACT = LOCK")
    self.moveHint:SetAnchor(BOTTOMLEFT, self.frame, BOTTOMLEFT, 12, -10)
    self.moveHint:SetAnchor(BOTTOMRIGHT, self.frame, BOTTOMRIGHT, -12, -10)
    self.moveHint:SetHeight(22)
    self.moveHint:SetDrawLayer(DL_OVERLAY)
    self.moveHint:SetDrawLevel(70)
    self.moveHint:SetHidden(true)

    self.statusLabel = makeLabel(self.frame, "EPC_MiniMap_Status", "$(BOLD_FONT)|14|soft-shadow-thick", COLORS.muted, TEXT_ALIGN_CENTER)
    self.statusLabel:SetAnchor(CENTER, self.frame, CENTER, 0, 0)
    self.statusLabel:SetDimensions(220, 44)
    self.statusLabel:SetDrawLayer(DL_OVERLAY)
    self.statusLabel:SetDrawLevel(60)
    self.statusLabel:SetHidden(true)

    self.playerGlow = self:CreatePin("EPC_MiniMap_PlayerGlow", 40, PLAYER_TEXTURE, COLORS.cyan)
    self.playerGlow:SetHidden(false)
    self.playerGlow:SetAnchor(CENTER, self.viewport, CENTER, 0, 0)
    self.playerGlow:SetDrawLevel(66)
    self.playerGlow:SetAlpha(0.28)

    self.playerPin = self:CreatePin("EPC_MiniMap_Player", 26, PLAYER_TEXTURE, COLORS.white)
    self.playerPin:SetHidden(false)
    self.playerPin:SetAnchor(CENTER, self.viewport, CENTER, 0, 0)
    self.playerPin:SetDrawLevel(70)

    self.waypointPin = self:CreatePin("EPC_MiniMap_Waypoint", 24, WAYPOINT_TEXTURE, {0.24, 0.56, 0.97, 1})
    self.questPin = self:CreatePin("EPC_MiniMap_Quest", 25, WAYPOINT_TEXTURE, {1.00, 0.76, 0.18, 1})
    self.rallyPin = self:CreatePin("EPC_MiniMap_Rally", 22, WAYPOINT_TEXTURE, {0.21, 0.78, 0.52, 1})
    self.companionPin = self:CreatePin("EPC_MiniMap_Companion", 18, COMPANION_TEXTURE, COLORS.white)

    self.frame:SetHandler("OnMouseDown", function(_, button) self:BeginDrag(button) end)
    self.frame:SetHandler("OnMouseUp", function() if self.layoutMode then self:EndDrag() end end)
    self.frame:SetHandler("OnMouseWheel", function(_, delta) self:AdjustZoom(delta) end)
    self.frame:SetHandler("OnMoveStop", function() self:SavePosition() end)

    self.dragSurface = wm:CreateControl("EPC_MiniMap_DragSurface", self.frame, CT_CONTROL)
    self.dragSurface:SetAnchorFill(self.frame)
    self.dragSurface:SetDrawLayer(DL_OVERLAY)
    self.dragSurface:SetDrawLevel(1000)
    self.dragSurface:SetMouseEnabled(false)
    self.dragSurface:SetHidden(true)
    if type(self.dragSurface.RegisterForDrag) == "function" and MOUSE_BUTTON_INDEX_LEFT ~= nil then
        pcall(self.dragSurface.RegisterForDrag, self.dragSurface, MOUSE_BUTTON_INDEX_LEFT)
    end
    self.dragSurface:SetHandler("OnMouseDown", function(_, button) self:BeginDrag(button) end)
    self.dragSurface:SetHandler("OnDragStart", function(_, button) self:BeginDrag(button) end)
    self.dragSurface:SetHandler("OnMouseUp", function() if self.layoutMode then self:EndDrag() end end)
    self.dragSurface:SetHandler("OnDragStop", function() if self.layoutMode then self:EndDrag() end end)
    self.dragSurface:SetHandler("OnMouseWheel", function(_, delta) self:AdjustZoom(delta) end)

    self:ApplySizeAndStyle()
    self:AnchorFrame()
end

function M:ApplySizeAndStyle()
    if not self.frame or not EPC.saved then return end
    local frameSize = math.floor(clamp(EPC.saved.miniMapSize or 270, 180, 420))
    local inset = math.floor(math.max(12, frameSize * 0.055))
    local contentSize = frameSize - (inset * 2)
    local sizeChanged = self.frameSize ~= frameSize or self.size ~= contentSize
    EPC.saved.miniMapSize = frameSize
    self.frameSize = frameSize
    self.inset = inset
    self.size = contentSize
    self.circularStyle = false

    self.frame:SetDimensions(frameSize, frameSize)
    self.viewport:ClearAnchors()
    self.viewport:SetDimensions(contentSize, contentSize)
    self.viewport:SetAnchor(CENTER, self.frame, CENTER, 0, 0)

    local alpha = clamp(EPC.saved.miniMapAlpha or 0.92, 0.35, 1.0)
    self.frame:SetAlpha(alpha)

    local softAlpha = clamp(EPC.saved.unitFrameBackgroundAlpha or 0.20, 0.08, 0.45)
    if self.layoutMode then
        self.background:SetCenterColor(0.10, 0.08, 0.05, 0.34)
        self.background:SetEdgeColor(0.82, 0.66, 0.26, 0.72)
    else
        self.background:SetCenterColor(0.06, 0.05, 0.03, math.max(0.14, softAlpha * 0.78))
        self.background:SetEdgeColor(0, 0, 0, 0)
    end
    if self.frameBorder then
        self.frameBorder:SetCenterColor(0, 0, 0, 0)
        self.frameBorder:SetEdgeTexture(nil, 1, 1, 3)
        self.frameBorder:SetEdgeColor(0.52, 0.37, 0.14, self.layoutMode and 0.98 or 0.92)
    end
    if self.mapGlass then
        self.mapGlass:SetCenterColor(0.88, 0.95, 1.00, self.layoutMode and 0.08 or 0.11)
        self.mapGlass:SetEdgeTexture(nil, 1, 1, 0)
        self.mapGlass:SetEdgeColor(0, 0, 0, 0)
    end
    if self.mapChrome then
        self.mapChrome:SetCenterColor(0, 0, 0, 0)
        self.mapChrome:SetEdgeTexture(nil, 1, 1, 1)
        self.mapChrome:SetEdgeColor(0.92, 0.97, 1.00, self.layoutMode and 0.34 or 0.26)
    end
    if self.mapNorthFade then
        self.mapNorthFade:ClearAnchors()
        self.mapNorthFade:SetAnchor(TOPLEFT, self.viewport, TOPLEFT, 0, 0)
        self.mapNorthFade:SetAnchor(TOPRIGHT, self.viewport, TOPRIGHT, 0, 0)
        self.mapNorthFade:SetHeight(math.max(16, math.floor(contentSize * 0.13)))
        self.mapNorthFade:SetCenterColor(1.00, 1.00, 1.00, self.layoutMode and 0.05 or 0.08)
        self.mapNorthFade:SetEdgeTexture(nil, 1, 1, 0)
        self.mapNorthFade:SetEdgeColor(0, 0, 0, 0)
    end

    local rail = math.max(5, math.floor(frameSize * 0.022))
    local corner = math.max(15, math.floor(frameSize * 0.060))
    local goldR, goldG, goldB = 0.82, 0.65, 0.28
    local darkR, darkG, darkB = 0.12, 0.08, 0.035
    local pieces = { self.skinTop, self.skinBottom, self.skinLeft, self.skinRight }
    for i = 1, #pieces do
        local c = pieces[i]
        if c then
            c:SetCenterColor(goldR, goldG, goldB, 0.90)
            c:SetEdgeColor(0.30, 0.20, 0.07, 0.98)
            c:SetEdgeTexture(nil, 1, 1, 1)
        end
    end
    if self.skinTop then
        self.skinTop:ClearAnchors()
        self.skinTop:SetAnchor(TOPLEFT, self.viewport, TOPLEFT, -rail, -rail)
        self.skinTop:SetAnchor(TOPRIGHT, self.viewport, TOPRIGHT, rail, -rail)
        self.skinTop:SetHeight(rail)
    end
    if self.skinBottom then
        self.skinBottom:ClearAnchors()
        self.skinBottom:SetAnchor(BOTTOMLEFT, self.viewport, BOTTOMLEFT, -rail, rail)
        self.skinBottom:SetAnchor(BOTTOMRIGHT, self.viewport, BOTTOMRIGHT, rail, rail)
        self.skinBottom:SetHeight(rail)
    end
    if self.skinLeft then
        self.skinLeft:ClearAnchors()
        self.skinLeft:SetAnchor(TOPLEFT, self.viewport, TOPLEFT, -rail, 0)
        self.skinLeft:SetAnchor(BOTTOMLEFT, self.viewport, BOTTOMLEFT, -rail, 0)
        self.skinLeft:SetWidth(rail)
    end
    if self.skinRight then
        self.skinRight:ClearAnchors()
        self.skinRight:SetAnchor(TOPRIGHT, self.viewport, TOPRIGHT, rail, 0)
        self.skinRight:SetAnchor(BOTTOMRIGHT, self.viewport, BOTTOMRIGHT, rail, 0)
        self.skinRight:SetWidth(rail)
    end

    local corners = {
        {self.skinTL, TOPLEFT, self.viewport, TOPLEFT, -corner * 0.45, -corner * 0.45},
        {self.skinTR, TOPRIGHT, self.viewport, TOPRIGHT, corner * 0.45, -corner * 0.45},
        {self.skinBL, BOTTOMLEFT, self.viewport, BOTTOMLEFT, -corner * 0.45, corner * 0.45},
        {self.skinBR, BOTTOMRIGHT, self.viewport, BOTTOMRIGHT, corner * 0.45, corner * 0.45},
    }
    for i = 1, #corners do
        local c, point, rel, relPoint, x, y = unpack(corners[i])
        if c then
            c:ClearAnchors()
            c:SetDimensions(corner, corner)
            c:SetAnchor(point, rel, relPoint, x, y)
            c:SetCenterColor(darkR, darkG, darkB, 0.98)
            c:SetEdgeTexture(nil, 1, 1, 2)
            c:SetEdgeColor(goldR, goldG, goldB, 0.96)
        end
    end
    if self.skinTopGem then
        self.skinTopGem:ClearAnchors()
        self.skinTopGem:SetDimensions(corner, math.max(9, math.floor(corner * 0.55)))
        self.skinTopGem:SetAnchor(TOP, self.viewport, TOP, 0, -math.floor(corner * 0.45))
        self.skinTopGem:SetCenterColor(0.36, 0.23, 0.07, 0.98)
        self.skinTopGem:SetEdgeTexture(nil, 1, 1, 2)
        self.skinTopGem:SetEdgeColor(0.92, 0.74, 0.32, 1.0)
    end
    if self.esoFrame then self.esoFrame:SetHidden(true) end

    if sizeChanged and self.mapId then self:RebuildMap(true) end
end

function M:SetLayoutMode(active)
    active = active == true
    if not active and self.dragging then self:EndDrag() end
    self.layoutMode = active
    if not self.frame then return end
    self.frame:SetMouseEnabled(self:IsInteractive())
    self.frame:SetMovable(self.layoutMode)
    if self.dragSurface then
        self.dragSurface:SetHidden(not self.layoutMode)
        self.dragSurface:SetMouseEnabled(self.layoutMode)
    end
    self.moveHint:SetHidden(not self.layoutMode)
    self.contextLabel:SetHidden(true)
    self:ApplySizeAndStyle()
    self:Refresh(true)
end

function M:IsWorldMapShowing()
    return isWorldMapShowing()
end

function M:IsMenuShowing()
    -- Suite interaction mode deliberately activates ESO's UI cursor. That is not a
    -- menu and must not hide the minimap; users need the map to remain on screen
    -- while they interact with the suite.
    if self.layoutMode or EPC.interactionMode == true then return false end
    if EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed() == true then return true end
    if not EPC.saved or EPC.saved.miniMapHideInMenus == false then return false end
    return isMenuShowing()
end

-- Keep ESO's normal top compass during gameplay, but hide it whenever the player
-- enters a menu/UI scene. The custom minimap has separate interaction handling and
-- can remain available while the Suite interaction cursor is active.
function M:SetESOCompassHidden(hidden)
    hidden = hidden == true
    if self.esoCompassHidden == hidden then return end
    self.esoCompassHidden = hidden

    if COMPASS_FRAME_FRAGMENT and type(COMPASS_FRAME_FRAGMENT.SetHiddenForReason) == "function" then
        pcall(COMPASS_FRAME_FRAGMENT.SetHiddenForReason, COMPASS_FRAME_FRAGMENT, "ESOAdventurerSuiteMenu", hidden)
        return
    end

    -- Compatibility fallback for UI revisions where the fragment is unavailable.
    local controls = { ZO_CompassFrame, ZO_Compass, ZO_CompassContainer }
    for i = 1, #controls do
        local control = controls[i]
        if control and type(control.SetHidden) == "function" then
            pcall(control.SetHidden, control, hidden)
        end
    end
end

function M:SyncESOCompassVisibility()
    -- Use the raw menu/UI detector here rather than M:IsMenuShowing(), because
    -- M:IsMenuShowing() intentionally ignores Suite interaction mode so the custom
    -- minimap can stay on screen and receive mouse input.
    local hideCompass = isWorldMapShowing() or isMenuShowing()
    self:SetESOCompassHidden(hideCompass == true)
end

function M:SyncToPlayerMap(force)
    -- Never move ESO's visible map from the minimap. LibMapData owns the
    -- current player-map state and refreshes it on zone/map transitions.
    if self:IsWorldMapShowing() and not self.layoutMode then
        self.mapWasOpen = true
        return false
    end
    if self.mapWasOpen then
        self.mapWasOpen = false
        force = true
    end

    local mapId = 0
    local zoneIndex = nil
    local mapName = nil
    if LMD then
        mapId = tonumber(LMD.mapId) or 0
        zoneIndex = tonumber(LMD.zoneIndex)
        mapName = clean(LMD.mapName or LMD.subzoneName or "", "")
    end

    -- Fallback only when LibMapData has not populated yet. Importantly this
    -- reads the map; it never calls SetMapToPlayerLocation.
    if mapId <= 0 and type(DoesCurrentMapMatchMapForPlayerLocation) == "function" and safe(DoesCurrentMapMatchMapForPlayerLocation, false) == true then
        mapId = safeNumber(GetCurrentMapId, 0)
        local _, _, _, zi = safe(GetMapInfoById, nil, mapId)
        zoneIndex = tonumber(zi)
        mapName = clean(safe(GetMapNameById, "", mapId), "")
    end
    if mapId <= 0 then
        self.playerShown = false
        return false
    end

    local x, y, heading, shown = safe(GetMapPlayerPosition, nil, "player")
    x, y = tonumber(x), tonumber(y)
    if x == nil or y == nil or shown == false then
        self.playerShown = false
        return false
    end

    self.playerShown = true
    self.playerX = clamp(x, 0, 1)
    self.playerY = clamp(y, 0, 1)
    self.playerHeading = tonumber(heading) or safeNumber(GetPlayerCameraHeading, 0)
    self.lastGameplayMapId = mapId
    self.lastGameplayX = self.playerX
    self.lastGameplayY = self.playerY
    if self.viewPlayerX == nil or force == true then self.viewPlayerX = self.playerX end
    if self.viewPlayerY == nil or force == true then self.viewPlayerY = self.playerY end

    if self.mapId ~= mapId or force then
        local changed = self.mapId ~= mapId
        self.mapId = mapId
        if not mapName or mapName == "" then
            mapName = clean(safe(GetMapNameById, "", mapId), "Current Area")
        end
        self.mapName = mapName
        if self.zoneLabel then self.zoneLabel:SetText(mapName) end
        self.zoneIndex = zoneIndex
        if not self.zoneIndex then
            local _, _, _, zi = safe(GetMapInfoById, nil, mapId)
            self.zoneIndex = tonumber(zi)
        end
        if changed then self.trailData = {} end
        self:RebuildMap(true)
        self:RefreshStaticPins()
        self:UpdateContextText(true)
    end
    return true
end

function M:EnsureTiles(count)
    for i = #self.tiles + 1, count do
        local tile = wm:CreateControl("EPC_MiniMap_Tile_" .. tostring(i), self.tileContainer, CT_TEXTURE)
        tile:SetDrawLayer(DL_BACKGROUND)
        tile:SetDrawLevel(1)
        tile:SetHidden(true)
        self.tiles[i] = tile
    end
end

function M:RebuildMap(force)
    if not self.frame or not EPC.saved then return end
    local mapId = tonumber(self.mapId) or 0
    if mapId <= 0 then return end

    local horizontal, vertical = safe(GetMapNumTilesForMapId, nil, mapId)
    horizontal = tonumber(horizontal) or 0
    vertical = tonumber(vertical) or 0
    if horizontal <= 0 or vertical <= 0 then
        self.statusLabel:SetHidden(true)
        return
    end

    local zoom = self:GetEffectiveZoom()
    self.effectiveZoom = zoom
    -- Show more territory at each zoom level so the native map texture stays
    -- closer to its intended sampling scale and looks less pixelated.
    local visibleSpan = clamp(0.34 / zoom, 0.18, 0.48)
    local fullW = self.size / visibleSpan
    local fullH = fullW * (vertical / horizontal)
    self.fullMapWidth = fullW
    self.fullMapHeight = fullH
    self.horizontalTiles = horizontal
    self.verticalTiles = vertical

    self.tileContainer:SetDimensions(fullW, fullH)
    self:EnsureTiles(horizontal * vertical)
    local tileW = fullW / horizontal
    local tileH = fullH / vertical
    local mapAlpha = math.max(0.94, clamp(EPC.saved.miniMapMapAlpha or 0.94, 0.55, 1.0))

    local index = 1
    for row = 1, vertical do
        for col = 1, horizontal do
            local tile = self.tiles[index]
            tile:ClearAnchors()
            tile:SetAnchor(TOPLEFT, self.tileContainer, TOPLEFT, (col - 1) * tileW, (row - 1) * tileH)
            tile:SetDimensions(tileW + 0.75, tileH + 0.75)
            local filename = safe(GetMapTileTextureForMapId, "", mapId, index)
            if filename and filename ~= "" then
                tile:SetTexture(filename)
                tile:SetColor(0.97, 0.99, 0.95, 1.0)
                tile:SetAlpha(mapAlpha)
                tile:SetHidden(false)
            else
                tile:SetHidden(true)
            end
            index = index + 1
        end
    end
    for i = index, #self.tiles do self.tiles[i]:SetHidden(true) end
    self.statusLabel:SetHidden(true)
    self:UpdatePanAndPins(true)
end

function M:MapToScreen(x, y)
    if not self.playerShown or not self.fullMapWidth or not self.fullMapHeight then return nil, nil, false end
    x = tonumber(x)
    y = tonumber(y)
    if not x or not y or x < 0 or x > 1 or y < 0 or y > 1 then return nil, nil, false end
    local centerX = self.viewPlayerX or self.playerX
    local centerY = self.viewPlayerY or self.playerY
    local px = (self.size * 0.5) + ((x - centerX) * self.fullMapWidth)
    local py = (self.size * 0.5) + ((y - centerY) * self.fullMapHeight)
    local inside = px >= 0 and py >= 0 and px <= self.size and py <= self.size
    return px, py, inside
end

function M:PlacePin(pin, x, y, size, allowEdge)
    if not pin then return false, false end
    local px, py, inside = self:MapToScreen(x, y)
    if px == nil then pin:SetHidden(true) return false, false end
    local margin = math.max(10, (tonumber(size) or 18) * 0.6)
    local edge = false
    if not inside then
        if allowEdge == true and EPC.saved and EPC.saved.miniMapEdgeGuidance ~= false then
            if self.circularStyle == true then
                local center = self.size * 0.5
                local dx = px - center
                local dy = py - center
                local distance = math.sqrt((dx * dx) + (dy * dy))
                local radius = math.max(12, center - margin - 4)
                if distance > 0.0001 then
                    local scale = radius / distance
                    px = center + (dx * scale)
                    py = center + (dy * scale)
                else
                    px = center
                    py = center
                end
            else
                px = clamp(px, margin, self.size - margin)
                py = clamp(py, margin + 18, self.size - margin - 14)
            end
            edge = true
        else
            pin:SetHidden(true)
            return false, false
        end
    end
    pin:ClearAnchors()
    pin:SetAnchor(CENTER, self.viewport, TOPLEFT, px, py)
    pin:SetHidden(false)
    pin:SetAlpha(edge and 0.96 or 1.0)
    return true, edge
end

function M:GetDirectionTo(x, y)
    if not self.playerShown then return "" end
    x, y = tonumber(x), tonumber(y)
    if not x or not y then return "" end
    return directionText(x - (self.playerX or 0.5), y - (self.playerY or 0.5))
end

function M:UpdatePOIDistances()
    local data = self.poiData or {}
    self.nearestUndiscoveredPOI = nil
    for i = 1, #data do
        local poi = data[i]
        local dx = (tonumber(poi.x) or 0) - (self.playerX or 0.5)
        local dy = (tonumber(poi.y) or 0) - (self.playerY or 0.5)
        poi.distance2 = (dx * dx) + (dy * dy)
        if poi.discovered ~= true and (not self.nearestUndiscoveredPOI or poi.distance2 < self.nearestUndiscoveredPOI.distance2) then
            self.nearestUndiscoveredPOI = poi
        end
    end
    table.sort(data, function(a, b)
        if a.discovered ~= b.discovered then return a.discovered == false end
        if a.nearby ~= b.nearby then return a.nearby == true end
        if a.isCompletion ~= b.isCompletion then return a.isCompletion == true end
        return (a.distance2 or 999) < (b.distance2 or 999)
    end)
end

function M:RememberMerchantHere()
    if self.LEGACY_LEARNED_PINS_ENABLED ~= true then return false end
    if not EPC.saved then return false end
    local mapId = tonumber(self.mapId)
    if not mapId and type(GetCurrentMapId) == "function" then
        mapId = safeNumber(GetCurrentMapId, 0)
    end
    if not mapId or mapId <= 0 then return false end

    local x, y, _, shown = safe(GetMapPlayerPosition, nil, "player")
    x, y = tonumber(x), tonumber(y)
    if shown ~= true or not x or not y or x <= 0 or x >= 1 or y <= 0 or y >= 1 then return false end

    EPC.saved.miniMapKnownMerchants = EPC.saved.miniMapKnownMerchants or {}
    local mapKey = tostring(mapId)
    local list = EPC.saved.miniMapKnownMerchants[mapKey]
    if type(list) ~= "table" then
        list = {}
        EPC.saved.miniMapKnownMerchants[mapKey] = list
    end

    local storeName, storeType, storeIcon = self:GetCurrentStoreIdentity()

    -- Opening a store can fire more than once. Only collapse a visit when both
    -- the store identity and location match. Different merchants at the same
    -- market stall/area are intentionally allowed to keep separate pins.
    local candidate = { name=storeName, storeType=storeType, icon=storeIcon }
    local candidateIdentity = normalizedMerchantIdentity(candidate)
    for i = 1, #list do
        local old = list[i]
        if normalizedMerchantIdentity(old) == candidateIdentity
            and mapPointNear(old.x, old.y, x, y, 0.000225) then
            -- Same merchant revisited: refresh metadata but never add a second pin.
            old.name = storeName
            old.storeType = storeType
            old.icon = storeIcon
            old.lastSeen = safeNumber(GetTimeStamp, 0)
            self.staticPinsDirty = true
            return true
        end
    end

    list[#list + 1] = {
        x=x, y=y, name=storeName, storeType=storeType, icon=storeIcon,
        learned=true, lastSeen=safeNumber(GetTimeStamp, 0)
    }
    while #list > 24 do table.remove(list, 1) end
    self.staticPinsDirty = true
    return true
end

function M:AddRememberedMerchants()
    if self.LEGACY_LEARNED_PINS_ENABLED ~= true then return end
    if not EPC.saved or type(EPC.saved.miniMapKnownMerchants) ~= "table" then return end
    local mapId = tonumber(self.mapId)
    if not mapId then return end
    local list = EPC.saved.miniMapKnownMerchants[tostring(mapId)]
    if type(list) ~= "table" then return end

    self.merchantData = self.merchantData or {}
    for i = 1, #list do
        local saved = list[i]
        local x, y = tonumber(saved.x), tonumber(saved.y)
        if x and y and x > 0 and x < 1 and y > 0 and y < 1 then
            local duplicate = false
            local savedIdentity = normalizedMerchantIdentity(saved)
            for j = 1, #self.merchantData do
                local existing = self.merchantData[j]
                -- Do not suppress a different merchant just because it occupies
                -- the same small market area. Only the same learned identity is
                -- considered a duplicate here.
                if existing.learned == true
                    and normalizedMerchantIdentity(existing) == savedIdentity
                    and mapPointNear(existing.x, existing.y, x, y, 0.000225) then
                    duplicate = true
                    break
                end
            end
            if not duplicate then
                self.merchantData[#self.merchantData + 1] = {
                    x=x, y=y,
                    name=clean(saved.name, STORE_TYPE_LABELS[saved.storeType] or "Merchant"),
                    storeType=saved.storeType or "merchant",
                    icon=(saved.icon and saved.icon ~= "") and saved.icon or POI_FALLBACK_TEXTURE,
                    discovered=true, nearby=true, isMerchant=true, learned=true,
                }
            end
        end
    end
end

function M:RefreshStaticPins()
    if not EPC.saved then return end

    self.shrineData = {}
    if self:LayerEnabled("shrines") and type(GetNumFastTravelNodes) == "function" and type(GetFastTravelNodeInfo) == "function" then
        local count = safeNumber(GetNumFastTravelNodes, 0)
        for nodeIndex = 1, count do
            local known, name, x, y, icon, _, _, shown, locked = safe(GetFastTravelNodeInfo, nil, nodeIndex)
            if known == true and shown == true and locked ~= true and tonumber(x) and tonumber(y) then
                self.shrineData[#self.shrineData + 1] = {
                    x=tonumber(x), y=tonumber(y), icon=icon, name=clean(name, "Wayshrine"),
                    nativeIcon=(type(icon) == "string" and icon ~= ""),
                }
                if #self.shrineData >= 96 then break end
            end
        end
    end
    self:EnsureShrinePins(#self.shrineData)
    for i = 1, #self.shrinePins do
        local data = self.shrineData[i]
        local pin = self.shrinePins[i]
        if data then
            if data.icon and data.icon ~= "" then
                pin:SetTexture(data.icon)
                -- ESO's wayshrine / fast-travel artwork already carries its own
                -- visual treatment, so do not recolor it with the old gold tint.
                pin:SetColor(1, 1, 1, 1)
            else
                pin:SetTexture(WAYPOINT_TEXTURE)
                pin:SetColor(1, 1, 1, 1)
            end
        else
            pin:SetHidden(true)
        end
    end

    self.poiData = {}
    self.merchantData = {}
    self.serviceData = {}
    self.nearestUndiscoveredPOI = nil
    local zoneIndex = tonumber(self.zoneIndex)
    -- Merchants are scanned even if the normal POI layer is disabled.
    if zoneIndex and type(GetNumPOIs) == "function" and type(GetPOIMapInfo) == "function" then
        local poiCount = safeNumber(GetNumPOIs, 0, zoneIndex)
        local noneType = ZONE_COMPLETION_TYPE_NONE or 0
        local mode = self:GetMode()
        for poiIndex = 1, poiCount do
            local x, y, pinType, icon, shown, locked, discovered, nearby = safe(GetPOIMapInfo, nil, zoneIndex, poiIndex)
            x = tonumber(x)
            y = tonumber(y)
            if shown == true and locked ~= true and x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                local completionType = type(GetPOIZoneCompletionType) == "function" and safe(GetPOIZoneCompletionType, noneType, zoneIndex, poiIndex) or noneType
                local isCompletion = completionType ~= noneType
                -- Base map tiles do not contain ESO map pins, so render every POI the
                -- API says should be shown. Layer toggles/modes still decide whether
                -- the POI layer itself is enabled.
                local include = true
                if include then
                    local name = type(GetPOIInfo) == "function" and clean(select(1, safe(GetPOIInfo, "", zoneIndex, poiIndex)), "Point of Interest") or "Point of Interest"
                    local dx = (x - (self.playerX or 0.5))
                    local dy = (y - (self.playerY or 0.5))
                    local dist2 = (dx * dx) + (dy * dy)
                    local nativeIcon = self:GetNativePvEMapPinTexture(icon, pinType)
                    local data = {
                        x=x, y=y, icon=nativeIcon or icon, name=name, discovered=discovered == true,
                        nearby=nearby == true, isCompletion=isCompletion, distance2=dist2, pinType=pinType,
                        nativeIcon=nativeIcon ~= nil,
                    }
                    if isStableMasterPOI(name, icon) then
                        -- Stablemasters are promoted to the always-on service layer so
                        -- every stable ESO exposes on the current zone/town map remains
                        -- visible even when the general POI layer is disabled.
                        data.kind = "stable"
                        data.isService = true
                        data.name = clean(name, "Stablemaster")
                        if not data.icon or data.icon == "" then data.icon = getServiceFallbackIcon("stable") end
                        self.serviceData[#self.serviceData + 1] = data
                    elseif isSellMerchantPOI(name, icon) then
                        data.isMerchant = true
                        self.merchantData[#self.merchantData + 1] = data
                    elseif self:LayerEnabled("pois") then
                        self.poiData[#self.poiData + 1] = data
                        if discovered ~= true and (not self.nearestUndiscoveredPOI or dist2 < self.nearestUndiscoveredPOI.distance2) then
                            self.nearestUndiscoveredPOI = data
                        end
                    end
                end
            end
        end
        self:UpdatePOIDistances()
    end
    -- Add the complete native icon set ESO exposed for this exact town/location
    -- map. This is intentionally after POI scanning so duplicates can be skipped.
    self:AddCapturedNativeTownPins()
    -- Persist POIs the player has actually reached/discovered, then merge all
    -- learned merchants, crafting stations, stables, and other saved POIs.
    self:RememberVisiblePOIs()
    self:AddRememberedMerchants()
    self:AddRememberedServices()

    local maxPins = math.max(24, math.min(220, tonumber(EPC.saved.miniMapPOIMax) or 160))
    self:EnsurePOIPins(maxPins)
    self:EnsureMerchantPins(math.min(96, math.max(16, #(self.merchantData or {}))))
    self:EnsureServicePins(math.min(96, math.max(8, #(self.serviceData or {}))))
    self:RefreshPvPKeepData()
    self.staticPinsDirty = false
end

function M:RefreshPvPKeepData()
    self.pvpKeepData = {}
    self.pvpTravelLinks = {}
    if safe(IsPlayerInAvAWorld, false) ~= true then return end
    if type(GetNumKeeps) ~= "function" or type(GetKeepKeysByIndex) ~= "function" or type(GetKeepPinInfo) ~= "function" then return end
    local count = safeNumber(GetNumKeeps, 0)
    for i = 1, count do
        local keepId = select(1, safe(GetKeepKeysByIndex, nil, i))
        if keepId then
            local name = type(GetKeepName) == "function" and clean(safe(GetKeepName, "", keepId), "PvP Objective") or "PvP Objective"
            local x, y, pinType, contextUsed
            for context = 1, 3 do
                local pType, kx, ky = safe(GetKeepPinInfo, nil, keepId, context)
                kx, ky = tonumber(kx), tonumber(ky)
                if kx and ky and kx > 0 and ky > 0 and kx <= 1 and ky <= 1 then
                    pinType, x, y, contextUsed = pType, kx, ky, context
                    break
                end
            end
            if x and y then
                local alliance = 0
                if type(GetKeepAlliance) == "function" then alliance = tonumber(safe(GetKeepAlliance, 0, keepId, contextUsed or 1)) or 0 end
                local keepType = type(GetKeepType) == "function" and safe(GetKeepType, nil, keepId) or nil
                local resourceType = type(GetKeepResourceType) == "function" and safe(GetKeepResourceType, nil, keepId) or nil
                local size = 26
                -- Resources are visually smaller than keeps/outposts on ESO's PvP map.
                if resourceType and resourceType ~= 0 then size = 20 end
                self.pvpKeepData[#self.pvpKeepData + 1] = {
                    x=x, y=y, name=name, keepId=keepId, pinType=pinType,
                    texture=self:GetPvPPinTexture(pinType), alliance=alliance,
                    color=self:GetPvPAllianceColor(alliance), keepType=keepType,
                    resourceType=resourceType, size=size, context=contextUsed,
                }
            end
        end
    end

    -- Cyrodiil transitus network. ESO exposes each connection with owner,
    -- restriction, state, and normalized map endpoints. Use those values
    -- directly so the minimap mirrors who owns each connected supply line.
    if type(GetNumKeepTravelNetworkLinks) == "function" and type(GetKeepTravelNetworkLinkInfo) == "function" then
        local context = BGQUERY_LOCAL or 1
        local linkCount = safeNumber(GetNumKeepTravelNetworkLinks, 0, context)
        for i = 1, linkCount do
            local linkType, linkOwner, restrictedToAlliance, startX, startY, endX, endY = safe(GetKeepTravelNetworkLinkInfo, nil, i, context)
            startX, startY, endX, endY = tonumber(startX), tonumber(startY), tonumber(endX), tonumber(endY)
            if startX and startY and endX and endY and startX >= 0 and startX <= 1 and startY >= 0 and startY <= 1 and endX >= 0 and endX <= 1 and endY >= 0 and endY <= 1 then
                local owner = tonumber(linkOwner) or 0
                if owner <= 0 then owner = tonumber(restrictedToAlliance) or 0 end
                local active = true
                if FAST_TRAVEL_LINK_ACTIVE ~= nil and tonumber(linkType) ~= nil then
                    active = tonumber(linkType) == tonumber(FAST_TRAVEL_LINK_ACTIVE)
                end
                self.pvpTravelLinks[#self.pvpTravelLinks + 1] = {
                    startX=startX, startY=startY, endX=endX, endY=endY,
                    linkType=linkType, alliance=owner, active=active,
                    color=self:GetPvPAllianceColor(owner),
                }
            end
        end
    end
end

function M:RenderModeLabels()
    -- PvP intentionally uses icons only, matching ESO's Cyrodiil map.
    if self:IsPvPIconOnlyMode() then self:HideMapObjectLabels(); return end
    if not self:IsLabeledMapMode() then self:HideMapObjectLabels(); return end

    local function render(kind, data, nameFn, offset, colorFn)
        data = data or {}
        local pool = self:EnsureMapObjectLabels(kind, #data)
        local used = 0
        for i = 1, #data do
            local d = data[i]
            if d and d.x and d.y then
                used = used + 1
                local text = nameFn and nameFn(d, i) or d.name
                local color = colorFn and colorFn(d, i) or COLORS.white
                self:PlaceMapObjectLabel(pool[used], text, d.x, d.y, offset, color)
            end
        end
        for i = used + 1, #pool do pool[i]:SetHidden(true) end
    end

    render("shrines", self.shrineData, function(d) return d.name end, 10, function() return COLORS.gold end)
    render("pois", self.poiData, function(d) return d.name end, 10, function(d) return d.discovered and COLORS.white or COLORS.gold end)
    render("merchants", self.merchantData, function(d) return d.name or "Merchant" end, 13, function() return COLORS.gold end)
    render("services", self.serviceData, function(d) return d.name or STORE_TYPE_LABELS[d.kind] or "Service" end, 15, function() return COLORS.gold end)
    render("keeps", self.pvpKeepData, function(d) return d.name end, 15, function(d) return d.color or COLORS.white end)

    local groupData = {}
    for i, st in pairs(self.groupPinState or {}) do
        if st and st.x and st.y and st.name then groupData[#groupData + 1] = {x=st.x,y=st.y,name=st.name,leader=st.leader} end
    end
    render("group", groupData, function(d) return d.leader and (d.name .. " [LEADER]") or d.name end, 10, function() return COLORS.cyan end)

    local specials = {}
    if self.questPosition and self.questPosition.x and self.questPosition.y then specials[#specials+1] = {x=self.questPosition.x,y=self.questPosition.y,name=self.questPosition.name or "Quest",color=COLORS.gold} end
    if self.waypointPosition and self.waypointPosition.x and self.waypointPosition.y then specials[#specials+1] = {x=self.waypointPosition.x,y=self.waypointPosition.y,name="Waypoint",color=COLORS.blue} end
    if self.rallyPosition and self.rallyPosition.x and self.rallyPosition.y then specials[#specials+1] = {x=self.rallyPosition.x,y=self.rallyPosition.y,name="Rally Point",color=COLORS.green} end
    render("special", specials, function(d) return d.name end, 14, function(d) return d.color end)

    local playerPool = self:EnsureMapObjectLabels("player", 1)
    self:PlaceMapObjectLabel(playerPool[1], "YOU", self.playerX, self.playerY, 16, COLORS.white)

    local companionData = {}
    if safe(DoesUnitExist, false, "companion") == true then
        local x, y, _, shown = safe(GetMapPlayerPosition, nil, "companion")
        if shown == true and tonumber(x) and tonumber(y) then companionData[1] = {x=tonumber(x),y=tonumber(y),name=clean(safe(GetUnitName,"","companion"),"Companion")} end
    end
    render("companion", companionData, function(d) return d.name end, 10, function() return COLORS.white end)
end

function M:RefreshQuestPin()
    self.questPosition = nil
    if not self.questPin or not self:LayerEnabled("quest") then
        if self.questPin then self.questPin:SetHidden(true) end
        return
    end

    -- Use the exact same live ESO breadcrumb/objective resolver as the quest
    -- direction tracker. This keeps the minimap marker and the tracked objective
    -- synchronized on multi-objective quests instead of choosing a different
    -- incomplete condition.
    if EPC.ActiveQuest and type(EPC.ActiveQuest.GetQuestTrackingSource2513) == "function"
        and type(EPC.ActiveQuest.ResolveQuestSource2516) == "function"
        and type(EPC.ActiveQuest.GetQuestDirectionPosition2512) == "function" then
        local source = EPC.ActiveQuest:GetQuestTrackingSource2513()
        local questIndex = EPC.ActiveQuest:ResolveQuestSource2516(source)
        if questIndex then
            local position = EPC.ActiveQuest:GetQuestDirectionPosition2512(questIndex)
            if position and position.available == true and tonumber(position.x) and tonumber(position.y) then
                local questName = "Quest"
                if type(GetJournalQuestName) == "function" then
                    questName = clean(safe(GetJournalQuestName, "Quest", questIndex), "Quest")
                end
                self.questPosition = {
                    x = tonumber(position.x),
                    y = tonumber(position.y),
                    name = questName,
                    objective = position.targetText,
                }
                self:PlacePin(self.questPin, self.questPosition.x, self.questPosition.y, 25, true)
                return
            end
        end
    end

    -- Fallback to the Travel resolver for clients/maps where live breadcrumbs
    -- have not populated yet.
    if not EPC.Travel or type(EPC.Travel.GetFocusedQuest) ~= "function" then self.questPin:SetHidden(true) return end
    local quest = EPC.Travel:GetFocusedQuest(EPC.lastSnapshot or {})
    local position = quest and quest.position or nil
    if position and position.available == true then
        local x, y = tonumber(position.x), tonumber(position.y)
        local currentMapId = 0
        if type(GetCurrentMapId) == "function" then currentMapId = tonumber(safe(GetCurrentMapId, 0)) or 0 end

        local gx, gy = tonumber(position.globalX), tonumber(position.globalY)
        if gx ~= nil and gy ~= nil and currentMapId > 0 then
            local projectedX, projectedY = easLocalPointForMap(currentMapId, gx, gy)
            if projectedX ~= nil and projectedY ~= nil then
                x, y = projectedX, projectedY
            elseif tonumber(position.mapId) ~= currentMapId then
                self.questPin:SetHidden(true)
                return
            end
        elseif tonumber(position.mapId) and tonumber(position.mapId) > 0 and tonumber(position.mapId) ~= currentMapId then
            self.questPin:SetHidden(true)
            return
        end

        if x ~= nil and y ~= nil then
            self.questPosition = { x=x, y=y, name=clean(quest.name or quest.title or "Quest", "Quest"), objective=quest.objectiveName }
            self:PlacePin(self.questPin, x, y, 25, true)
        else
            self.questPin:SetHidden(true)
        end
    else
        self.questPin:SetHidden(true)
    end
end

function M:RefreshWaypointPin()
    self.waypointPosition = nil
    if not self.waypointPin or not self:LayerEnabled("waypoint") or type(GetMapPlayerWaypoint) ~= "function" then
        if self.waypointPin then self.waypointPin:SetHidden(true) end
        return
    end
    local x, y = safe(GetMapPlayerWaypoint, nil)
    x = tonumber(x)
    y = tonumber(y)
    if x and y and (x > 0 or y > 0) then
        self.waypointPosition = { x=x, y=y }
        self:PlacePin(self.waypointPin, x, y, 24, true)
    else self.waypointPin:SetHidden(true) end
end

function M:RefreshRallyPin()
    self.rallyPosition = nil
    if not self.rallyPin or not self:LayerEnabled("rally") or type(GetMapRallyPoint) ~= "function" then
        if self.rallyPin then self.rallyPin:SetHidden(true) end
        return
    end
    local x, y = safe(GetMapRallyPoint, nil)
    x = tonumber(x)
    y = tonumber(y)
    if x and y and (x > 0 or y > 0) then
        self.rallyPosition = { x=x, y=y }
        self:PlacePin(self.rallyPin, x, y, 22, true)
    else self.rallyPin:SetHidden(true) end
end

function M:RefreshCompanionPin()
    if not self.companionPin or not self:LayerEnabled("companion") then
        if self.companionPin then self.companionPin:SetHidden(true) end
        return
    end
    if safe(DoesUnitExist, false, "companion") ~= true then self.companionPin:SetHidden(true) return end
    local x, y, heading, shown = safe(GetMapPlayerPosition, nil, "companion")
    if shown == true then
        if type(self.companionPin.SetTextureRotation) == "function" and tonumber(heading) then
            self.companionPin:SetTextureRotation(tonumber(heading), 0.5, 0.5)
        end
        self:PlacePin(self.companionPin, x, y, 18, false)
    else self.companionPin:SetHidden(true) end
end

function M:RefreshGroupPins()
    self.groupLeaderPosition = nil
    self.groupPinState = self.groupPinState or {}
    if not self:LayerEnabled("group") then
        if self.groupPins then for i = 1, #self.groupPins do self.groupPins[i]:SetHidden(true) end end
        return
    end
    local groupSize = safeNumber(GetGroupSize, 0)
    self:EnsureGroupPins(groupSize)
    for i = 1, #self.groupPins do
        local pin = self.groupPins[i]
        if i <= groupSize then
            local unitTag
            if type(ZO_Group_GetUnitTagForGroupIndex) == "function" then unitTag = safe(ZO_Group_GetUnitTagForGroupIndex, nil, i) end
            unitTag = unitTag or ("group" .. tostring(i))
            local exists = safe(DoesUnitExist, false, unitTag) == true
            local isSelf = safe(AreUnitsEqual, false, unitTag, "player") == true
            if exists and not isSelf then
                local x, y, heading, shown = safe(GetMapPlayerPosition, nil, unitTag)
                x, y = tonumber(x), tonumber(y)
                if shown == true and x and y then
                    local leader = safe(IsUnitGroupLeader, false, unitTag) == true
                    if leader then self.groupLeaderPosition = { x=x, y=y } end
                    local dotColor = getGroupRoleDotColor(unitTag)
                    local inSupportRange = safe(IsUnitInGroupSupportRange, true, unitTag) ~= false
                    pin:SetDimensions(leader and 20 or 16, leader and 20 or 16)
                    pin:SetColor(unpack(dotColor))
                    if type(pin.SetTextureRotation) == "function" then pin:SetTextureRotation(0, 0.5, 0.5) end

                    local state = self.groupPinState[i] or {}
                    local drawHeading = tonumber(heading)
                    if state.x and state.y then
                        local dx, dy = x - state.x, y - state.y
                        local movementHeading = headingFromMapDelta(dx, dy)
                        local moved2 = (dx * dx) + (dy * dy)
                        if movementHeading and moved2 > 0.0000000025 then
                            drawHeading = movementHeading
                        elseif state.heading ~= nil and drawHeading == nil then
                            drawHeading = state.heading
                        end
                    end
                    if drawHeading ~= nil then state.heading = drawHeading end
                    state.x, state.y = x, y
                    state.name = clean(safe(GetUnitName, "", unitTag), unitTag)
                    state.leader = leader
                    state.outOfRange = not inSupportRange
                    self.groupPinState[i] = state

                    -- Normal group marker only. Out-of-range members are not
                    -- given a glow or an artificial minimap-edge locator.
                    self:PlacePin(pin, x, y, leader and 20 or 16, false)
                else
                    pin:SetHidden(true)
                    self.groupPinState[i] = nil
                end
            else
                pin:SetHidden(true)
                self.groupPinState[i] = nil
            end
        else
            pin:SetHidden(true)
            self.groupPinState[i] = nil
        end
    end
end

function M:RenderServicePins()
    if not self.servicePins then return end
    local used = 0
    for i = 1, #(self.serviceData or {}) do
        if used >= #self.servicePins then break end
        local data = self.serviceData[i]
        local _, _, inside = self:MapToScreen(data.x, data.y)
        if inside then
            used = used + 1
            local pin = self.servicePins[used]
            local backing = self.serviceBackings and self.serviceBackings[used] or nil
            local isStable = data.kind == "stable"
            local size = isStable and 28 or 24
            local backingSize = isStable and 36 or 30

            if backing then
                -- Never draw the generic white/custom-destination backing.
                -- Only the real service icon should be visible on the minimap.
                backing:SetHidden(true)
            end

            pin:SetDimensions(size, size)
            -- Stable uses a known ESO mount texture; other learned services keep
            -- their captured/specific texture with a reliable fallback.
            local texture = ((data.icon and data.icon ~= "") and data.icon or getServiceFallbackIcon(data.kind))
            if not texture or texture == "" or texture == POI_FALLBACK_TEXTURE or texture == WAYPOINT_TEXTURE then
                pin:SetHidden(true)
            else
                pin:SetTexture(texture)
            -- Reset texture state because pooled minimap pins may previously have
            -- displayed atlas-like ESO textures.  Packaged service icons use the
            -- full 0..1 texture surface.
            if type(pin.SetTextureCoords) == "function" then pin:SetTextureCoords(0, 1, 0, 1) end
            if type(pin.SetBlendMode) == "function" then pin:SetBlendMode(TEX_BLEND_MODE_ALPHA) end
                pin:SetColor(1, 1, 1, 1)
                pin:SetDrawLevel(isStable and 90 or 82)
                self:PlacePin(pin, data.x, data.y, size, true)
            end
        end
    end
    for i = used + 1, #self.servicePins do self.servicePins[i]:SetHidden(true) end
    if self.serviceBackings then
        for i = used + 1, #self.serviceBackings do self.serviceBackings[i]:SetHidden(true) end
    end
end

function M:RenderMerchantPins()
    if not self.merchantPins then return end
    local used = 0
    for i = 1, #(self.merchantData or {}) do
        if used >= #self.merchantPins then break end
        local data = self.merchantData[i]
        local _, _, inside = self:MapToScreen(data.x, data.y)
        if inside then
            used = used + 1
            local pin = self.merchantPins[used]
            local size = data.learned and 26 or 22
            pin:SetDimensions(size, size)
            if data.icon and data.icon ~= "" then pin:SetTexture(data.icon) else pin:SetTexture(POI_FALLBACK_TEXTURE) end
            -- Learned stores use the actual representative ESO store-item icon
            -- discovered when the player opened that store. Keep it full-color
            -- so a blacksmith, alchemist, clothier, etc. are visually distinct.
            if data.learned then
                pin:SetColor(1, 1, 1, 1)
            else
                pin:SetColor(1.00, 0.82, 0.28, 1.00)
            end
            self:PlacePin(pin, data.x, data.y, size, true)
        end
    end
    for i = used + 1, #self.merchantPins do self.merchantPins[i]:SetHidden(true) end
end

function M:RenderPOIPins()
    if not self.poiPins then return end
    if not self:LayerEnabled("pois") then
        for i = 1, #self.poiPins do self.poiPins[i]:SetHidden(true) end
        return
    end

    local maxPins = math.max(24, math.min(220, tonumber(EPC.saved.miniMapPOIMax) or 160))
    local used = 0
    local nativePvE = not self:IsPvPIconOnlyMode()

    for i = 1, #(self.poiData or {}) do
        if used >= maxPins then break end
        local data = self.poiData[i]
        local _, _, inside = self:MapToScreen(data.x, data.y)
        if inside then
            local texture = self:GetNativePvEMapPinTexture(data.icon, data.pinType)

            -- Never replace a missing ESO icon with the generic white/custom
            -- destination diamond.  This keeps the overland map looking like
            -- ESO's own map rather than a field of addon fallback markers.
            if texture then
                used = used + 1
                local pin = self.poiPins[used]
                local size = data.nearby and 21 or (data.isCompletion and 19 or 18)
                pin:SetDimensions(size, size)
                pin:SetTexture(texture)

                if nativePvE then
                    -- Match the PvP implementation: let ESO's native texture
                    -- encode POI type/state and leave the artwork untinted.
                    -- Unlike the old minimap pass, discovered overland POIs are
                    -- no longer hidden just because they are not nearby.
                    pin:SetColor(1, 1, 1, 1)
                    self:PlacePin(pin, data.x, data.y, size, false)
                else
                    -- Preserve the established PvP behavior so Cyrodiil remains
                    -- focused on keeps, scrolls, and transit-network ownership.
                    if data.discovered == true and data.nearby ~= true and data.learned ~= true and not self:IsLabeledMapMode() then
                        pin:SetHidden(true)
                        used = used - 1
                    else
                        if data.discovered ~= true then
                            pin:SetColor(0.98, 0.72, 0.18, 0.98)
                        elseif data.nearby then
                            pin:SetColor(0.24, 0.56, 0.97, 0.94)
                        else
                            pin:SetColor(1, 1, 1, 1)
                        end
                        self:PlacePin(pin, data.x, data.y, size, false)
                    end
                end
            end
        end
    end

    for i = used + 1, #self.poiPins do self.poiPins[i]:SetHidden(true) end
end

function M:CaptureTrailPoint(force)
    if not self:LayerEnabled("trail") or not self.playerShown then return end
    self.trailData = self.trailData or {}
    local x = tonumber(self.playerX)
    local y = tonumber(self.playerY)
    if not x or not y then return end
    local last = self.trailData[#self.trailData]
    if not force and last then
        local dx = x - last.x
        local dy = y - last.y
        if (dx * dx) + (dy * dy) < 0.000010 then return end
    end
    self.trailData[#self.trailData + 1] = { x=x, y=y }
    local maxPoints = 10
    while #self.trailData > maxPoints do table.remove(self.trailData, 1) end
end

function M:RenderTrail()
    self:EnsureTrailPins(10)
    if not self:LayerEnabled("trail") then
        for i = 1, #self.trailPins do self.trailPins[i]:SetHidden(true) end
        return
    end
    local data = self.trailData or {}
    local total = #data
    local used = 0
    for i = 1, total do
        local point = data[i]
        used = used + 1
        local pin = self.trailPins[used]
        local frac = total > 1 and (i / total) or 1
        local size = 4 + math.floor(frac * 3)
        pin:SetDimensions(size, size)
        pin:SetColor(0.70, 0.82, 0.94, 0.18 + (0.42 * frac))
        self:PlacePin(pin, point.x, point.y, size, false)
    end
    for i = used + 1, #self.trailPins do self.trailPins[i]:SetHidden(true) end
end

function M:UpdateContextText(force)
    -- Normal overland mode stays icon-focused. Object labels for special game
    -- modes are rendered separately by RenderModeLabels().
    if self.modeLabel then self.modeLabel:SetHidden(true) end
    if self.zoneLabel then self.zoneLabel:SetHidden(true) end
    if self.coordsLabel then self.coordsLabel:SetHidden(true) end
    if self.contextLabel then self.contextLabel:SetHidden(true) end
    if self.northLabel then self.northLabel:SetHidden(true) end
    if self.eastLabel then self.eastLabel:SetHidden(true) end
    if self.southLabel then self.southLabel:SetHidden(true) end
    if self.westLabel then self.westLabel:SetHidden(true) end
end

function M:PulsePriorityPins()
    local t = nowSeconds()
    local scale = 1.0 + (0.06 * ((math.sin(t * 5.0) + 1) * 0.5))
    if self.questPin and not self.questPin:IsHidden() and self.questPin.SetScale then self.questPin:SetScale(scale) end
    if self.waypointPin and not self.waypointPin:IsHidden() and self.waypointPin.SetScale then self.waypointPin:SetScale(scale) end
end

function M:UpdatePanAndPins(forceStatic)
    if not self.playerShown or not self.fullMapWidth or not self.fullMapHeight then return end
    local x, y, heading, shown = safe(GetMapPlayerPosition, nil, "player")
    if shown == true and tonumber(x) and tonumber(y) then
        self.playerX = clamp(x, 0, 1)
        self.playerY = clamp(y, 0, 1)
        self.playerHeading = tonumber(heading) or self.playerHeading or 0
    end

    -- Keep the camera inside the actual ESO map texture. Near zone/map edges the
    -- player is allowed to move away from the center instead of exposing empty
    -- space beyond the source map, similar to modern navigation apps.
    local halfVisibleX = math.min(0.5, (self.size * 0.5) / self.fullMapWidth)
    local halfVisibleY = math.min(0.5, (self.size * 0.5) / self.fullMapHeight)
    local targetViewX = clamp(self.playerX, halfVisibleX, 1.0 - halfVisibleX)
    local targetViewY = clamp(self.playerY, halfVisibleY, 1.0 - halfVisibleY)

    -- GetMapPlayerPosition can advance in visible steps even with a 60 Hz pulse.
    -- Ease the camera center toward the clamped target so movement glides instead
    -- of snapping between map coordinates.
    if forceStatic or self.viewPlayerX == nil or self.viewPlayerY == nil then
        self.viewPlayerX = targetViewX
        self.viewPlayerY = targetViewY
    else
        local follow = 0.18
        self.viewPlayerX = self.viewPlayerX + ((targetViewX - self.viewPlayerX) * follow)
        self.viewPlayerY = self.viewPlayerY + ((targetViewY - self.viewPlayerY) * follow)
        -- Never let interpolation itself drift outside the legal camera range.
        self.viewPlayerX = clamp(self.viewPlayerX, halfVisibleX, 1.0 - halfVisibleX)
        self.viewPlayerY = clamp(self.viewPlayerY, halfVisibleY, 1.0 - halfVisibleY)
    end

    local offsetX = (self.size * 0.5) - (self.viewPlayerX * self.fullMapWidth)
    local offsetY = (self.size * 0.5) - (self.viewPlayerY * self.fullMapHeight)
    self.tileContainer:ClearAnchors()
    self.tileContainer:SetAnchor(TOPLEFT, self.viewport, TOPLEFT, offsetX, offsetY)

    -- The player stays centered in the interior of a map, but naturally shifts
    -- toward the viewport edge when the camera reaches the map boundary.
    local playerScreenX, playerScreenY = self:MapToScreen(self.playerX, self.playerY)
    playerScreenX = playerScreenX or (self.size * 0.5)
    playerScreenY = playerScreenY or (self.size * 0.5)
    if self.playerGlow then
        if type(self.playerGlow.SetTextureRotation) == "function" then self.playerGlow:SetTextureRotation(self.playerHeading or 0, 0.5, 0.5) end
        self.playerGlow:ClearAnchors()
        self.playerGlow:SetAnchor(CENTER, self.viewport, TOPLEFT, playerScreenX, playerScreenY)
        self.playerGlow:SetHidden(false)
    end
    if type(self.playerPin.SetTextureRotation) == "function" then self.playerPin:SetTextureRotation(self.playerHeading or 0, 0.5, 0.5) end
    self.playerPin:ClearAnchors()
    self.playerPin:SetAnchor(CENTER, self.viewport, TOPLEFT, playerScreenX, playerScreenY)
    self.playerPin:SetHidden(false)

    if self.shrineData and self.shrinePins then
        if self:LayerEnabled("shrines") then
            for i = 1, #self.shrinePins do
                local data = self.shrineData[i]
                if data then self:PlacePin(self.shrinePins[i], data.x, data.y, 17, false) else self.shrinePins[i]:SetHidden(true) end
            end
        else
            for i = 1, #self.shrinePins do self.shrinePins[i]:SetHidden(true) end
        end
    end

    self:RenderMerchantPins()
    self:RenderServicePins()
    self:RenderPOIPins()
    -- Draw alliance-owned transitus connections beneath PvP objective icons.
    self:RenderPvPTransitLines()
    self:RenderPvPPins()
    self:RenderTrail()
    self:RefreshWaypointPin()
    self:RefreshQuestPin()
    self:RefreshRallyPin()
    self:RefreshGroupPins()
    self:RefreshCompanionPin()
    self:PulsePriorityPins()
    self:RenderModeLabels()
    self:UpdateContextText(false)
end

function M:Refresh(force)
    if not self.frame or not EPC.saved then return end
    self:SyncESOCompassVisibility()
    local show = EPC.saved.showMiniMap ~= false or self.layoutMode == true
    if self.layoutMode ~= true and EPC.OverlayModeAllows then show = show and EPC:OverlayModeAllows("miniMapVisibility") end
    local mapOpen = self:IsWorldMapShowing()
    local menuOpen = self:IsMenuShowing()
    if mapOpen then show = false
    elseif menuOpen and not self.layoutMode then show = false end
    self.frame:SetHidden(not show)
    if not show then return end

    self.frame:SetMouseEnabled(self:IsInteractive())
    self.frame:SetMovable(self.layoutMode == true)
    self:ApplySizeAndStyle()
    if self:SyncToPlayerMap(force == true) then
        self:UpdatePanAndPins(force == true)
    else
        self.statusLabel:SetHidden(true)
    end
end

function M:RegisterEvents()
    local prefix = EPC.name .. "_MiniMap"

    -- LibMapData is now the single owner of player-map transitions. The Suite
    -- listens and redraws instead of forcing map changes itself.
    local function syncMapTransitionNow()
        self.needsSync = true
        self.staticPinsDirty = true

        -- Town/sub-map boundaries can change underneath the player without a
        -- normal zone load. Do the handoff immediately so the player marker
        -- never keeps running across the stale town map while waiting for the
        -- periodic update/watchdog.
        if self.frame and not self:IsWorldMapShowing() then
            local synced = self:SyncToPlayerMap(true)
            self.needsSync = not synced
            if synced then
                self:RefreshStaticPins()
                self:UpdatePanAndPins(true)
            end
        end
    end

    if LMD and type(LMD.RegisterCallback) == "function" and LMD.callbackType then
        local function onMapDataChanged()
            syncMapTransitionNow()
        end
        if LMD.callbackType.OnWorldMapChanged then
            LMD:RegisterCallback(LMD.callbackType.OnWorldMapChanged, onMapDataChanged)
        end
        if LMD.callbackType.EVENT_ZONE_CHANGED then
            LMD:RegisterCallback(LMD.callbackType.EVENT_ZONE_CHANGED, onMapDataChanged)
        end
        -- Entering/leaving towns and other linked sub-maps often does not fire a
        -- normal zone change. LibMapData exposes this callback specifically for
        -- those player-position map transitions, so the minimap must follow it.
        if LMD.callbackType.EVENT_LINKED_WORLD_POSITION_CHANGED then
            LMD:RegisterCallback(LMD.callbackType.EVENT_LINKED_WORLD_POSITION_CHANGED, onMapDataChanged)
        end
        if LMD.callbackType.EVENT_PLAYER_ACTIVATED then
            LMD:RegisterCallback(LMD.callbackType.EVENT_PLAYER_ACTIVATED, onMapDataChanged)
        end
    end
    local seen = {}
    local function register(eventId, staticPinsDirty)
        if not eventId or seen[eventId] or not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForEvent) ~= "function" then return end
        seen[eventId] = true
        EVENT_MANAGER:RegisterForEvent(prefix .. "_" .. tostring(eventId), eventId, function()
            if eventId == EVENT_LINKED_WORLD_POSITION_CHANGED then
                syncMapTransitionNow()
                return
            end
            self.needsSync = true
            if staticPinsDirty == true then self.staticPinsDirty = true end
        end)
    end

    register(EVENT_PLAYER_ACTIVATED, true)
    register(EVENT_ZONE_CHANGED, true)
    register(EVENT_LINKED_WORLD_POSITION_CHANGED, true)
    register(EVENT_FAST_TRAVEL_NETWORK_UPDATED, true)
    register(EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED, true)
    register(EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED, true)
    register(EVENT_GROUP_UPDATE, false)
    register(EVENT_GROUP_MEMBER_JOINED, false)
    register(EVENT_GROUP_MEMBER_LEFT, false)
    register(EVENT_TRACKING_UPDATE, false)
    register(EVENT_POI_UPDATED, true)

    -- ESO does not consistently publish merchant NPCs as map POIs. Learn a
    -- merchant's normalized map position whenever the player actually opens a
    -- store, then keep that pin permanently for this character/account save.
    if EVENT_OPEN_STORE and EVENT_MANAGER and type(EVENT_MANAGER.RegisterForEvent) == "function" then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_MerchantStoreOpen", EVENT_OPEN_STORE, function()
            self:RememberMerchantHere()
        end)
    end


    -- Learn crafting stations when their interaction opens. Event constants can
    -- vary between client/API revisions, so this hook remains optional.
    if EVENT_CRAFTING_STATION_INTERACT and EVENT_MANAGER and type(EVENT_MANAGER.RegisterForEvent) == "function" then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_CraftingStationOpen", EVENT_CRAFTING_STATION_INTERACT, function()
            self:RememberCurrentCraftingStation()
        end)
    end
    -- Custom stable learning intentionally removed. Native stable map POIs
    -- continue to render through the ordinary ESO POI layer when available.
    register(EVENT_QUEST_ADDED, false)
    register(EVENT_QUEST_REMOVED, false)
    register(EVENT_QUEST_ADVANCED, false)
    register(EVENT_QUEST_CONDITION_COUNTER_CHANGED, false)

    if not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then return end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Pulse", 33, function()
        if not self.frame or not EPC.saved then return end
        self:SyncESOCompassVisibility()
        local show = EPC.saved.showMiniMap ~= false or self.layoutMode == true
        if self.layoutMode ~= true and EPC.OverlayModeAllows then show = show and EPC:OverlayModeAllows("miniMapVisibility") end
        if not show then self.frame:SetHidden(true) return end

        local mapOpen = self:IsWorldMapShowing()
        local menuOpen = self:IsMenuShowing()
        if mapOpen or (menuOpen and not self.layoutMode) then
            self.frame:SetHidden(true)
            if mapOpen then
                self.mapWasOpen = true
                -- Snapshot ESO's complete native pin set from the map the player
                -- is viewing. This is the source for town/city service icons.
                self:CaptureAllNativeMapPins()
            end
            self.menuWasOpen = menuOpen == true
            return
        end

        self.frame:SetHidden(false)
        self.frame:SetMouseEnabled(self:IsInteractive())
        self.frame:SetMovable(self.layoutMode == true)
        local worldMapJustClosed = self.mapWasOpen == true
        if worldMapJustClosed then
            -- The close edge belongs to this pulse only. Clear it before syncing so
            -- later pulses cannot repeatedly treat the World Map as freshly closed.
            self.mapWasOpen = false
        end
        if worldMapJustClosed or self.menuWasOpen then
            self.needsSync = true
            self.staticPinsDirty = true
            if self.nativeTownPinsChanged then
                self.nativeTownPinsChanged = false
            end
        end
        self.menuWasOpen = false

        -- Safety net for same-zone town/sub-map transitions. Some locations can
        -- change LibMapData.mapId without ESO producing a zone event on the exact
        -- frame our callbacks run. Poll the library-owned map id at a fast fallback rate and
        -- request a full sync whenever it differs from the minimap map. This never
        -- changes ESO's visible World Map.
        local mapWatchNow = nowSeconds()
        if LMD and (not self.lastMapIdWatch or mapWatchNow - self.lastMapIdWatch >= 0.05) then
            self.lastMapIdWatch = mapWatchNow
            local libraryMapId = tonumber(LMD.mapId) or 0
            if libraryMapId > 0 and libraryMapId ~= (tonumber(self.mapId) or 0) then
                self.needsSync = true
                self.staticPinsDirty = true
            end
        end

        if self.needsSync or not self.mapId then
            local synced = self:SyncToPlayerMap(true)
            self.needsSync = not synced
            self.staticPinsDirty = true
            -- Native map pins may have been learned while the player viewed the
            -- World Map. One clean redraw is enough; LibMapData restores the
            -- player-map state without the Suite touching zoom/map selection.
            if synced and worldMapJustClosed then
                self.lastStaticRefresh = nowSeconds()
                self:RefreshStaticPins()
                self:UpdatePanAndPins(true)
            end
        else
            local x, y, heading, shown = safe(GetMapPlayerPosition, nil, "player")
            if shown == true and tonumber(x) and tonumber(y) then
                self.playerShown = true
                self.playerX = clamp(x, 0, 1)
                self.playerY = clamp(y, 0, 1)
                self.playerHeading = tonumber(heading) or self.playerHeading or 0
                if tonumber(self.mapId) and self.mapId > 0 then
                    self.lastGameplayMapId = self.mapId
                    self.lastGameplayX = self.playerX
                    self.lastGameplayY = self.playerY
                end
            else
                self.needsSync = true
            end
        end

        local effective = self:GetEffectiveZoom()
        if self.effectiveZoom and math.abs(effective - self.effectiveZoom) > 0.01 then self:RebuildMap(true) end

        local now = nowSeconds()
        if self.staticPinsDirty and (not self.lastStaticRefresh or now - self.lastStaticRefresh >= 0.50) then
            self.lastStaticRefresh = now
            self:RefreshStaticPins()
        end
        if not self.lastPOIOrder or now - self.lastPOIOrder >= 0.75 then
            self.lastPOIOrder = now
            if self:LayerEnabled("pois") then self:UpdatePOIDistances() end
        end
        if not self.lastTrailCapture or now - self.lastTrailCapture >= 0.55 then
            self.lastTrailCapture = now
            self:CaptureTrailPoint(false)
        end
        -- Poll crafting interactions as a fallback for clients where a dedicated
        -- crafting event is absent. Learned locations are save-once and deduped.
        local t = nowSeconds()
        if t - (self.lastServiceLearnCheck or 0) >= 2.0 then
            self.lastServiceLearnCheck = t
            self:RememberCurrentCraftingStation()
        end

        self:UpdatePanAndPins(false)
    end)
end

function M:Initialize()
    self.layoutMode = false
    self.mapBackend = (LMD and GPS and LMP) and "LibMapData + LibGPS + LibMapPins" or "fallback"
    self.esoCompassHidden = nil
    self.mapId = nil
    self.lastGameplayMapId = nil
    self.lastGameplayX = nil
    self.lastGameplayY = nil
    self.stableInteractionActive = false
    self:CleanupLearnedMapData()
    self.mapWasOpen = false
    self.needsSync = true
    self.staticPinsDirty = true
    self.trailData = {}
    self:Create()
    self:RegisterEvents()
    self:HookNativeTownPins()
    if type(zo_callLater) == "function" then zo_callLater(function() self:HookNativeTownPins() end, 1200) end
    self:Refresh(true)
end


-- ============================================================================
-- v0.24.84 - Live Cyrodiil Elder Scroll objective layer
-- Elder Scrolls are objective records, not keep pins. Query them separately so
-- carried/returned scrolls remain visible on the icon-only PvP minimap.
-- ============================================================================
function M:EnsurePvPScrollPins(count)
    self.pvpScrollPins = self.pvpScrollPins or {}
    for i = #self.pvpScrollPins + 1, count do
        local pin = self:CreatePin("EPC_MiniMap_ElderScroll_" .. tostring(i), 30, POI_FALLBACK_TEXTURE, COLORS.white)
        pin:SetDrawLevel(94)
        self.pvpScrollPins[i] = pin
    end
end

function M:HidePvPScrollPins()
    for i = 1, #(self.pvpScrollPins or {}) do self.pvpScrollPins[i]:SetHidden(true) end
end

function M:IsElderScrollObjective(keepId, objectiveId, objectiveName)
    keepId = tonumber(keepId) or 0
    objectiveId = tonumber(objectiveId) or 0
    if keepId > 0 and type(GetKeepArtifactObjectiveId) == "function" then
        local artifactId = tonumber(safe(GetKeepArtifactObjectiveId, 0, keepId)) or 0
        if artifactId > 0 and artifactId == objectiveId then return true end
    end
    local name = string.lower(tostring(objectiveName or ""))
    return name:find("elder scroll", 1, true) ~= nil
end

function M:RefreshPvPScrollData()
    self.pvpScrollData = {}
    if safe(IsPlayerInAvAWorld, false) ~= true then return end
    if type(GetNumObjectives) ~= "function" or type(GetObjectiveIdsForIndex) ~= "function" or type(GetObjectivePinInfo) ~= "function" then return end

    local num = safeNumber(GetNumObjectives, 0)
    for index = 1, num do
        local keepId, objectiveId, context = safe(GetObjectiveIdsForIndex, nil, index)
        keepId, objectiveId = tonumber(keepId) or 0, tonumber(objectiveId) or 0
        context = context or BGQUERY_LOCAL or 1
        if objectiveId > 0 then
            local objectiveName, objectiveType, objectiveState = "", nil, nil
            if type(GetObjectiveInfo) == "function" then
                objectiveName, objectiveType, objectiveState = safe(GetObjectiveInfo, "", keepId, objectiveId, context)
            end
            if self:IsElderScrollObjective(keepId, objectiveId, objectiveName) then
                local pinType, x, y, continuous = safe(GetObjectivePinInfo, nil, keepId, objectiveId, context)
                x, y = tonumber(x), tonumber(y)

                -- At-base or transition states may temporarily omit a current
                -- coordinate. Fall back to return/spawn locations so the scroll
                -- never disappears from the minimap merely because it was reset.
                if not x or not y or x <= 0 or y <= 0 or x > 1 or y > 1 then
                    if type(GetObjectiveReturnPinInfo) == "function" then
                        local returnPinType, rx, ry = safe(GetObjectiveReturnPinInfo, nil, keepId, objectiveId, context)
                        rx, ry = tonumber(rx), tonumber(ry)
                        if rx and ry and rx > 0 and ry > 0 and rx <= 1 and ry <= 1 then
                            pinType, x, y = returnPinType or pinType, rx, ry
                        end
                    end
                end
                if not x or not y or x <= 0 or y <= 0 or x > 1 or y > 1 then
                    if type(GetObjectiveSpawnPinInfo) == "function" then
                        local spawnPinType, sx, sy = safe(GetObjectiveSpawnPinInfo, nil, keepId, objectiveId, context)
                        sx, sy = tonumber(sx), tonumber(sy)
                        if sx and sy and sx > 0 and sy > 0 and sx <= 1 and sy <= 1 then
                            pinType, x, y = spawnPinType or pinType, sx, sy
                        end
                    end
                end

                if x and y and x > 0 and y > 0 and x <= 1 and y <= 1 then
                    local color = COLORS.white
                    if type(GetObjectiveAuraPinInfo) == "function" then
                        local _, r, g, b = safe(GetObjectiveAuraPinInfo, nil, keepId, objectiveId, context)
                        if tonumber(r) and tonumber(g) and tonumber(b) then color = {r, g, b, 1} end
                    end
                    self.pvpScrollData[#self.pvpScrollData + 1] = {
                        x=x, y=y, keepId=keepId, objectiveId=objectiveId, context=context,
                        name=objectiveName, pinType=pinType, objectiveType=objectiveType,
                        objectiveState=objectiveState, continuous=continuous == true,
                        texture=self:GetPvPPinTexture(pinType), color=color,
                    }
                end
            end
        end
    end
end

function M:RenderPvPScrollPins()
    if not self:IsPvPIconOnlyMode() then self:HidePvPScrollPins(); return end

    local now = type(GetFrameTimeMilliseconds) == "function" and tonumber(GetFrameTimeMilliseconds()) or 0
    if now == 0 or not self.lastPvPScrollRefreshMs or (now - self.lastPvPScrollRefreshMs) >= 250 then
        self.lastPvPScrollRefreshMs = now
        self:RefreshPvPScrollData()
    end

    local data = self.pvpScrollData or {}
    self:EnsurePvPScrollPins(#data)
    for i = 1, #self.pvpScrollPins do
        local pin = self.pvpScrollPins[i]
        local scroll = data[i]
        if scroll then
            if scroll.texture and scroll.texture ~= "" then pin:SetTexture(scroll.texture) else pin:SetTexture(POI_FALLBACK_TEXTURE) end
            local c = scroll.color or COLORS.white
            pin:SetColor(c[1] or 1, c[2] or 1, c[3] or 1, c[4] or 1)
            self:PlacePin(pin, scroll.x, scroll.y, 30, false)
        else
            pin:SetHidden(true)
        end
    end
end

local easLegacyRenderPvPPins_2484 = M.RenderPvPPins
function M:RenderPvPPins()
    if easLegacyRenderPvPPins_2484 then easLegacyRenderPvPPins_2484(self) end
    self:RenderPvPScrollPins()
end

local easLegacyRefreshPvPKeepData_2484 = M.RefreshPvPKeepData
function M:RefreshPvPKeepData()
    easLegacyRefreshPvPKeepData_2484(self)
    self:RefreshPvPScrollData()
end


-- ============================================================================
-- v0.24.86 - Native Elder Scroll artwork resolver
-- Use the exact objective pin type returned by ESO and try the game's native
-- map-pin texture definitions with objective context. Native textures are
-- rendered untinted so their built-in alliance/artifact colors remain intact.
-- ============================================================================
function M:GetNativeObjectivePinTexture(pinType, keepId, objectiveId, context, objectiveName)
    if pinType == nil then return nil end

    if type(GetMapPinTexture) == "function" then
        local tex = safe(GetMapPinTexture, nil, pinType)
        if type(tex) == "string" and tex ~= "" then return tex end
    end

    if ZO_MapPin and type(ZO_MapPin.PIN_DATA) == "table" then
        local def = ZO_MapPin.PIN_DATA[pinType]
        if type(def) == "table" then
            local tex = def.texture
            if type(tex) == "string" and tex ~= "" then return tex end
            if type(tex) == "function" then
                local tag = {
                    pinType = pinType,
                    keepId = keepId,
                    objectiveId = objectiveId,
                    bgContext = context,
                    context = context,
                    objectiveName = objectiveName,
                }
                local attempts = {
                    function() return tex(tag) end,
                    function() return tex(pinType, tag) end,
                    function() return tex(keepId, objectiveId, context) end,
                    function() return tex(pinType, keepId, objectiveId, context) end,
                    function() return tex(pinType) end,
                }
                for i = 1, #attempts do
                    local ok, value = pcall(attempts[i])
                    if ok and type(value) == "string" and value ~= "" then return value end
                end
            end
        end
    end

    return self:GetPvPPinTexture(pinType)
end

local easLegacyRefreshPvPScrollData_2486 = M.RefreshPvPScrollData
function M:RefreshPvPScrollData()
    easLegacyRefreshPvPScrollData_2486(self)
    for i = 1, #(self.pvpScrollData or {}) do
        local scroll = self.pvpScrollData[i]
        scroll.texture = self:GetNativeObjectivePinTexture(
            scroll.pinType, scroll.keepId, scroll.objectiveId, scroll.context, scroll.name
        )
        scroll.hasNativeTexture = type(scroll.texture) == "string" and scroll.texture ~= ""
    end
end

local easLegacyRenderPvPScrollPins_2486 = M.RenderPvPScrollPins
function M:RenderPvPScrollPins()
    if not self:IsPvPIconOnlyMode() then self:HidePvPScrollPins(); return end

    local now = type(GetFrameTimeMilliseconds) == "function" and tonumber(GetFrameTimeMilliseconds()) or 0
    if now == 0 or not self.lastPvPScrollRefreshMs or (now - self.lastPvPScrollRefreshMs) >= 250 then
        self.lastPvPScrollRefreshMs = now
        self:RefreshPvPScrollData()
    end

    local data = self.pvpScrollData or {}
    self:EnsurePvPScrollPins(#data)
    for i = 1, #self.pvpScrollPins do
        local pin = self.pvpScrollPins[i]
        local scroll = data[i]
        if scroll then
            if scroll.hasNativeTexture then
                pin:SetTexture(scroll.texture)
                -- Do not tint ESO's native Elder Scroll artwork. The texture
                -- itself carries the correct multi-color scroll appearance.
                pin:SetColor(1, 1, 1, 1)
            else
                pin:SetTexture(POI_FALLBACK_TEXTURE)
                local c = scroll.color or COLORS.white
                pin:SetColor(c[1] or 1, c[2] or 1, c[3] or 1, c[4] or 1)
            end
            self:PlacePin(pin, scroll.x, scroll.y, 30, false)
        else
            pin:SetHidden(true)
        end
    end
end
