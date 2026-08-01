--------------------------------------------------------------
-- Seamstress v1.0.2.9 "Perfect Fit"
-- Author: SugaComa (Rik Sprint)
--
-- • Loads defaults from /data/*.lua
-- • Waits politely after companion activation
-- • Manual save via /smscan
-- • Auto-saves on Companion Menu close
-- • Console-safe with minimal factual messages
--------------------------------------------------------------

--------------------------------------------------------------
-- 1. Metadata & setup
--------------------------------------------------------------
local ADDON   = "Seamstress"
local VERSION = "1.0.2.9"

Seamstress = Seamstress or {}
local SM = Seamstress
local EM = EVENT_MANAGER
SM.debug = false
SM.Companions = Seamstress.Companions or {}
SM._scan = SM._scan or { running = false, queue = {}, index = 0 }
SM._suppressAutoUntil = SM._suppressAutoUntil or 0

local function NowMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end
    return 0
end

--------------------------------------------------------------
-- 2. Helpers
--------------------------------------------------------------
local function Msg(str)
    CHAT_ROUTER:AddSystemMessage("|cC080FF[Seamstress]|r " .. tostring(str))
end
local function Dbg(str)
    if SM.debug then Msg("(debug) " .. tostring(str)) end
end
local function Timestamp()
    return os.date("%Y-%m-%d %H:%M:%S", GetTimeStamp())
end

--------------------------------------------------------------
-- 3. Global state
--------------------------------------------------------------
local activeCompanionName = nil
local seamstressReady = false
local initialized = false

--------------------------------------------------------------
-- 4. Colour map & slot map
--------------------------------------------------------------
local QUALITY_COLOUR = {
    [0] = "|c999999", [1] = "|c999999",
    [2] = "|c5CFF5C", [3] = "|c4DD2FF", [4] = "|cA44EFF", [5] = "|cFF6B6B",
}

local SLOT_MAP = {
    { id = EQUIP_SLOT_HEAD,       name = "Head" },
    { id = EQUIP_SLOT_NECK,       name = "Neck" },
    { id = EQUIP_SLOT_CHEST,      name = "Chest" },
    { id = EQUIP_SLOT_SHOULDERS,  name = "Shoulders" },
    { id = EQUIP_SLOT_MAIN_HAND,  name = "MainHand" },
    { id = EQUIP_SLOT_OFF_HAND,   name = "OffHand" },
    { id = EQUIP_SLOT_LEGS,       name = "Legs" },
    { id = EQUIP_SLOT_HAND,       name = "Hands" },
    { id = EQUIP_SLOT_WAIST,      name = "Waist" },
    { id = EQUIP_SLOT_FEET,       name = "Feet" },
    { id = EQUIP_SLOT_RING1,      name = "Ring1" },
    { id = EQUIP_SLOT_RING2,      name = "Ring2" },
}

--------------------------------------------------------------
-- 5. SavedVars initialization
--------------------------------------------------------------
local function EnsureIntegrity()
    local acc  = GetDisplayName()
    local char = GetUnitName("player")
    SM.SV = SM.SV or {}
    SM.SV[acc] = SM.SV[acc] or {}
    SM.SV[acc][char] = SM.SV[acc][char] or {}
    SM.SV.ui = SM.SV.ui or { selectedCompanion = "" }
    SM.SV.settings = SM.SV.settings or {
        autoUpdateOnSummon = true,
        autoDebug = false,
    }
    return acc, char
end

--------------------------------------------------------------
-- 6. Gear capture
--------------------------------------------------------------
local function GetGearInfo(bagId, slot)
    local ok, link = pcall(GetItemLink, bagId, slot)
    if not ok or not link or link == "" then
        return { link = "empty", trait = "empty", weight = "empty", quality = 0, itemId = 0, enchantId = 0, weaponType = 0 }
    end

    local trait, weight, quality = "empty", "empty", 0
    local itemId, enchantId, weaponType = 0, 0, 0

    local hasTrait, traitType = pcall(GetItemTrait, bagId, slot)
    if hasTrait and traitType and traitType > 0 then
        trait = GetString("SI_ITEMTRAITTYPE", traitType) or "empty"
    end

    local hasArmor, armorType = pcall(GetItemArmorType, bagId, slot)
    if hasArmor and armorType and armorType > 0 then
        weight = GetString("SI_ARMORTYPE", armorType) or "empty"
    end

    local hasQuality, q = pcall(GetItemQuality, bagId, slot)
    if hasQuality and q then quality = q end

    if GetItemLinkItemId then
        itemId = GetItemLinkItemId(link) or 0
    end
    if GetItemLinkAppliedEnchantId then
        enchantId = GetItemLinkAppliedEnchantId(link) or 0
    end
    if GetItemWeaponType then
        local hasWeapon, wt = pcall(GetItemWeaponType, bagId, slot)
        if hasWeapon and wt then
            weaponType = wt
        end
    end

    return { link = link, trait = trait, weight = weight, quality = quality, itemId = itemId, enchantId = enchantId, weaponType = weaponType }
end

--------------------------------------------------------------
-- 7. Save logic
--------------------------------------------------------------
local function SaveActiveCompanionGear()
    if not initialized then Msg("Not initialized.") return end
    if not HasActiveCompanion() then Msg("No active companion.") return end
    if not activeCompanionName then Msg("Companion name not detected.") return end

    local acc, char = EnsureIntegrity()

    -- Map the active full name to its nickname key in SM.Companions
    local saveKey = nil
    local clean = zo_strlower(activeCompanionName)
    for nick, comp in pairs(SM.Companions) do
        if zo_strlower(comp.name or nick) == clean then
            saveKey = nick   -- nick is the table key (nickname)
            break
        end
    end

    -- If not found (edge cases), fall back to active name so we don't crash
    saveKey = saveKey or activeCompanionName

    SM.SV[acc][char][saveKey] = SM.SV[acc][char][saveKey] or {
        lastUpdated = "never",
        gear = {}
    }

    local record = SM.SV[acc][char][saveKey]
    for _, slotData in ipairs(SLOT_MAP) do
        record.gear[slotData.id] = GetGearInfo(BAG_COMPANION_WORN, slotData.id)
    end

    record.lastUpdated = Timestamp()
    Msg(string.format("Saved %s (%s)", saveKey, record.lastUpdated))
    return saveKey
end

--------------------------------------------------------------
-- 8. Display helpers
--------------------------------------------------------------
local function PrintGear(comp, record)
    if not record or not record.gear then
        Msg(string.format("%s: no data.", comp))
        return
    end
    Msg(string.format("%s (updated %s):", comp, record.lastUpdated or "?"))
    for _, slotData in ipairs(SLOT_MAP) do
        local data = record.gear[slotData.id] or {link="empty",trait="empty",weight="empty",quality=0}
        local c = QUALITY_COLOUR[data.quality] or "|cFFFFFF"
        Msg(string.format("  %-12s: %s%s|r  [|cAAAAAA%s – %s|r]",
            slotData.name, c, data.link, data.weight, data.trait))
    end
end

local function IsTwoHandedWeaponType(weaponType)
    return weaponType == WEAPONTYPE_TWO_HANDED_SWORD
        or weaponType == WEAPONTYPE_TWO_HANDED_AXE
        or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER
        or weaponType == WEAPONTYPE_BOW
        or weaponType == WEAPONTYPE_FIRE_STAFF
        or weaponType == WEAPONTYPE_FROST_STAFF
        or weaponType == WEAPONTYPE_LIGHTNING_STAFF
        or weaponType == WEAPONTYPE_HEALING_STAFF
end

local function GetWeaponTypeName(weaponType)
    if weaponType and weaponType ~= 0 then
        local name = GetString and GetString("SI_WEAPONTYPE", weaponType)
        if name and name ~= "" then return name end
    end
    return "Unknown"
end

local function HasGearChanged(record, fresh)
    if not record or not record.gear then return true end
    for _, slotData in ipairs(SLOT_MAP) do
        local old = record.gear[slotData.id] or {}
        local new = fresh[slotData.id] or {}
        if old.link ~= new.link
            or old.trait ~= new.trait
            or old.weight ~= new.weight
            or old.quality ~= new.quality
            or (old.itemId or 0) ~= (new.itemId or 0)
            or (old.enchantId or 0) ~= (new.enchantId or 0)
            or (old.weaponType or 0) ~= (new.weaponType or 0) then
            return true
        end
    end
    return false
end

local function ScanAndResaveIfChanged(reason)
    local acc, char = EnsureIntegrity()
    if not SM.SV.settings.autoUpdateOnSummon then return end
    if not HasActiveCompanion() then return end
    if not activeCompanionName then return end

    local now = NowMs()
    if now < (SM._suppressAutoUntil or 0) then
        if SM.SV.settings.autoDebug then
            Msg("Auto-scan suppressed (" .. tostring(reason or "unknown") .. ").")
        end
        return
    end

    local saveKey = nil
    local clean = zo_strlower(activeCompanionName)
    for nick, comp in pairs(SM.Companions) do
        if zo_strlower(comp.name or nick) == clean then
            saveKey = nick
            break
        end
    end
    saveKey = saveKey or activeCompanionName

    local record = SM.SV[acc][char][saveKey]
    if not record or not record.gear or record.lastUpdated == "never" then
        if SM.SV.settings.autoDebug then
            Msg("Auto-scan skipped (no existing snapshot) for " .. tostring(saveKey))
        end
        return
    end

    local fresh = {}
    for _, slotData in ipairs(SLOT_MAP) do
        fresh[slotData.id] = GetGearInfo(BAG_COMPANION_WORN, slotData.id)
    end

    if HasGearChanged(record, fresh) then
        record.gear = fresh
        record.lastUpdated = Timestamp()
        Msg(string.format("%s has updated their wardrobe.", tostring(saveKey)))
        if SM.SV.settings.autoDebug then
            Msg("Auto-scan saved updates for " .. tostring(saveKey))
        end
    else
        if SM.SV.settings.autoDebug then
            Msg("Auto-scan found no changes for " .. tostring(saveKey))
        end
    end
end

local function GetCompanionList()
    local acc, char = EnsureIntegrity()
    local saved = SM.SV[acc][char] or {}
    local hasSaved = false
    for key, record in pairs(saved) do
        if record and record.gear and record.lastUpdated and record.lastUpdated ~= "never" then
            hasSaved = true
            break
        end
    end
    local list = {}
    for key, comp in pairs(SM.Companions) do
        local record = saved[key]
        if not hasSaved or (record and record.lastUpdated and record.lastUpdated ~= "never") then
            local display = comp.name or key
            list[#list + 1] = { name = display, data = key }
        end
    end
    table.sort(list, function(a, b) return tostring(a.name) < tostring(b.name) end)
    return list
end

local function GetSelectedCompanionKey()
    local key = SM.SV and SM.SV.ui and SM.SV.ui.selectedCompanion or ""
    if key ~= "" and SM.Companions[key] then
        return key
    end
    for k, _ in pairs(SM.Companions) do
        SM.SV.ui.selectedCompanion = k
        return k
    end
    return ""
end

local function BuildGearTooltip(key)
    if not key or key == "" then return "No companion selected." end
    local acc, char = EnsureIntegrity()
    local record = SM.SV[acc][char] and SM.SV[acc][char][key]
    if not record or not record.gear then
        return key .. ": no data."
    end
    local lines = {}
    lines[#lines + 1] = string.format("%s (updated %s):", key, record.lastUpdated or "?")
    local main = record.gear[EQUIP_SLOT_MAIN_HAND]
    local mainTwoHand = main and IsTwoHandedWeaponType(main.weaponType or 0)
    for _, slotData in ipairs(SLOT_MAP) do
        local data = record.gear[slotData.id] or { link="empty", trait="empty", weight="empty", quality=0 }
        local trait = data.trait or "empty"
        if slotData.id == EQUIP_SLOT_NECK
            or slotData.id == EQUIP_SLOT_RING1
            or slotData.id == EQUIP_SLOT_RING2 then
            lines[#lines + 1] = string.format("%-10s %s", slotData.name, trait)
        elseif slotData.id == EQUIP_SLOT_MAIN_HAND or slotData.id == EQUIP_SLOT_OFF_HAND then
            if slotData.id == EQUIP_SLOT_OFF_HAND and mainTwoHand then
                lines[#lines + 1] = string.format("%-10s Unavailable", slotData.name)
            else
                local wtype = GetWeaponTypeName(data.weaponType or 0)
                lines[#lines + 1] = string.format("%-10s %s • %s", slotData.name, wtype, trait)
            end
        else
            local weight = data.weight or "empty"
            lines[#lines + 1] = string.format("%-10s %s • %s", slotData.name, weight, trait)
        end
    end
    return table.concat(lines, "\n")
end

local function CanAutoSummon()
    return type(_G.GetCompanionCollectibleId) == "function"
        and type(_G.UseCollectible) == "function"
end

local function SummonCompanionByKey(key)
    if not key or key == "" then return false end
    local comp = SM.Companions[key]
    if not comp or not comp.id then return false end
    if not CanAutoSummon() then return false end
    local collectibleId = GetCompanionCollectibleId(comp.id)
    if not collectibleId or collectibleId == 0 then return false end
    if GetCollectibleUnlockStateById and GetCollectibleUnlockStateById(collectibleId) == COLLECTIBLE_UNLOCK_STATE_LOCKED then
        return false
    end
    if GAMEPLAY_ACTOR_CATEGORY_PLAYER then
        UseCollectible(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    else
        UseCollectible(collectibleId)
    end
    return true
end

local function ContinueScan()
    if not SM._scan.running then return end
    if SCENE_MANAGER and SCENE_MANAGER.IsInUIMode and SCENE_MANAGER:IsInUIMode() then
        Msg("Close menus to continue Fitting Room scan.")
        SM._scan.running = false
        return
    end
    SM._scan.index = SM._scan.index + 1
    local key = SM._scan.queue[SM._scan.index]
    if not key then
        SM._scan.running = false
        Msg("Fitting Room scan complete.")
        return
    end
    local ok = SummonCompanionByKey(key)
    if not ok then
        Msg("Cannot auto-summon " .. tostring(key) .. ". Please summon manually then press 'Capture Active Companion'.")
        SM._scan.running = false
        return
    end
end

local function StartFittingRoomScan()
    if SM._scan.running then
        Msg("Fitting Room scan already running.")
        return
    end
    SM._scan.queue = {}
    for key, _ in pairs(SM.Companions) do
        SM._scan.queue[#SM._scan.queue + 1] = key
    end
    table.sort(SM._scan.queue)
    if #SM._scan.queue == 0 then
        Msg("No companions found.")
        return
    end
    SM._scan.running = true
    SM._scan.index = 0
    Msg("Fitting Room scan started.")
    ContinueScan()
end

--------------------------------------------------------------
-- 9. Companion activation
--------------------------------------------------------------
local function OnCompanionActivated(_, companionId)
    local compName = GetCompanionName(companionId)
    if not compName or compName == "" then return end
    activeCompanionName = zo_strformat(SI_UNIT_NAME, compName)
    seamstressReady = false
    Msg(string.format("Active companion: %s", activeCompanionName))

    zo_callLater(function()
        seamstressReady = true
        Dbg(string.format("Ready for %s", activeCompanionName))
        if SM._scan.running then
            SaveActiveCompanionGear()
            zo_callLater(function() ContinueScan() end, 9000)
        else
            ScanAndResaveIfChanged("companion_activated")
        end
    end, 1800)
end
EM:RegisterForEvent(ADDON .. "_ACTIVATED", EVENT_COMPANION_ACTIVATED, OnCompanionActivated)

--------------------------------------------------------------
-- 10. Initialization
--------------------------------------------------------------
local function BuildCompanionDefaults()
    return {
        [EQUIP_SLOT_HEAD]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Head" },
        [EQUIP_SLOT_NECK]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Neck" },
        [EQUIP_SLOT_CHEST]      = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Chest" },
        [EQUIP_SLOT_SHOULDERS]  = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Shoulders" },
        [EQUIP_SLOT_MAIN_HAND]  = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "MainHand" },
        [EQUIP_SLOT_OFF_HAND]   = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "OffHand" },
        [EQUIP_SLOT_LEGS]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Legs" },
        [EQUIP_SLOT_HAND]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Hands" },
        [EQUIP_SLOT_WAIST]      = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Waist" },
        [EQUIP_SLOT_FEET]       = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Feet" },
        [EQUIP_SLOT_RING1]      = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Ring1" },
        [EQUIP_SLOT_RING2]      = { link = "empty", trait = "empty", weight = "empty", quality = 0, name = "Ring2" },
    }
end

local function LoadCompanionFiles()
    SM.Companions = SM.Companions or {}
    local known = {
        { id = 1,  name = "Bastian Hallix",   nickname = "Bastian" },
        { id = 2,  name = "Mirri Elendis",    nickname = "Mirri" },
        { id = 5,  name = "Ember",            nickname = "Ember" },
        { id = 6,  name = "Isobel Veloise",   nickname = "Isobel" },
        { id = 8,  name = "Sharp-as-Night",   nickname = "Sharp" },
        { id = 9,  name = "Azandar al-Cybiades", nickname = "Azandar" },
        { id = 12, name = "Tanlorin",         nickname = "Tanlorin" },
        { id = 13, name = "Zerith-var",       nickname = "Zerith" },
    }
    for _, c in ipairs(known) do
        SM.Companions[c.nickname] = {
            id = c.id,
            name = c.name,
            nickname = c.nickname,
            defaults = BuildCompanionDefaults(),
        }
    end
    Dbg(string.format("Companion list loaded (%d)", #known))
end

local function OnAddonLoaded(_, name)
    if name ~= ADDON then return end
    SM.SV = ZO_SavedVars:NewAccountWide("Seamstress_SV", 1, nil, {})
    LoadCompanionFiles()
    EnsureIntegrity()
    initialized = true

    CALLBACK_MANAGER:RegisterCallback("CompanionCharacterWindowHidden", function()
        if seamstressReady and activeCompanionName then
            SaveActiveCompanionGear()
        end
    end)

    Msg(string.format("Seamstress v%s initialized.", VERSION))
    EM:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)
end
EM:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, OnAddonLoaded)

local function OnPlayerActivated()
    SM._suppressAutoUntil = NowMs() + 8000
    if SM.SV and SM.SV.settings and SM.SV.settings.autoDebug then
        Msg("Auto-scan suppressed on activation.")
    end
end
EM:RegisterForEvent(ADDON .. "_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

--------------------------------------------------------------
-- 11. LHAS menu
--------------------------------------------------------------
local function CreateMenu()
    if not LibHarvensAddonSettings then
        Msg("LibHarvensAddonSettings not found. Menu disabled.")
        return
    end

    local LHA = LibHarvensAddonSettings
    local menu = LHA:AddAddon("Seamstress", { allowDefaults = true, allowRefresh = true })
    if not menu then return end
    SM.menu = menu

    menu:AddSetting({ type = LHA.ST_SECTION, label = "Fitting Room" })

    menu:AddSetting({
        type = LHA.ST_BUTTON,
        label = "Start Scan (close menu + auto-summon)",
        tooltip = "Closes menus, then cycles companions to capture gear.",
        buttonText = "Start",
        clickHandler = function()
            if SCENE_MANAGER and SCENE_MANAGER.SetInUIMode then
                SCENE_MANAGER:SetInUIMode(false)
            elseif SCENE_MANAGER and SCENE_MANAGER.ShowBaseScene then
                SCENE_MANAGER:ShowBaseScene()
            end
            zo_callLater(function()
                StartFittingRoomScan()
            end, 300)
        end,
    })

    menu:AddSetting({
        type = LHA.ST_BUTTON,
        label = "Capture Active Companion",
        tooltip = "Saves gear from the currently active companion.",
        buttonText = "Capture",
        clickHandler = function()
            SaveActiveCompanionGear()
        end,
    })

    menu:AddSetting({ type = LHA.ST_SECTION, label = "Automation" })

    menu:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Auto-update on summon",
        tooltip = "When you manually summon a companion, update their saved gear if anything changed.",
        default = true,
        getFunction = function() return SM.SV.settings.autoUpdateOnSummon == true end,
        setFunction = function(state)
            SM.SV.settings.autoUpdateOnSummon = (state == true)
        end,
    })

    menu:AddSetting({
        type = LHA.ST_CHECKBOX,
        label = "Auto-update debug",
        tooltip = "Prints why auto-scan ran and whether it saved.",
        default = false,
        getFunction = function() return SM.SV.settings.autoDebug == true end,
        setFunction = function(state)
            SM.SV.settings.autoDebug = (state == true)
        end,
    })

    menu:AddSetting({ type = LHA.ST_SECTION, label = "Companion Quick View" })

    local list = GetCompanionList()
    if #list == 0 then
        menu:AddSetting({
            type = LHA.ST_LABEL,
            label = "No saved companions yet. Capture a companion first.",
        })
    else
        for _, item in ipairs(list) do
            local key = item.data
            local label = item.name
            menu:AddSetting({
                type = LHA.ST_BUTTON,
                label = label,
                buttonText = "View",
                tooltip = function()
                    return BuildGearTooltip(key)
                end,
                clickHandler = function()
                    SM.SV.ui.selectedCompanion = key
                    if SM.menu and SM.menu.RefreshSettings then
                        SM.menu:RefreshSettings()
                    end
                end,
            })
        end
    end
end
zo_callLater(CreateMenu, 1000)

--------------------------------------------------------------
-- 12. Slash commands
--------------------------------------------------------------
SLASH_COMMANDS["/smscan"] = function()
    if not initialized then Msg("Not initialized.") return end
    if not seamstressReady or not activeCompanionName then
        Msg("Companion not ready.")
        return
    end
    SaveActiveCompanionGear()
end

SLASH_COMMANDS["/smgear"] = function(arg)
    if not initialized then Msg("Not initialized.") return end
    local acc, char = EnsureIntegrity()
    local charData = SM.SV[acc][char] or {}

    local input = zo_strtrim(arg or "")
    local target = input ~= "" and input or activeCompanionName
    if not target then Msg("No companion specified.") return end

    -- normalise to nickname key (case-insensitive)
    local want = zo_strlower(target)
    local nickKey = nil
    for nick,_ in pairs(SM.Companions) do
        if zo_strlower(nick) == want then nickKey = nick break end
    end
    target = nickKey or target

    local record = charData[target]
    if not record then Msg("No saved wardrobe for " .. target) return end
    PrintGear(target, record)
end


SLASH_COMMANDS["/smlist"] = function()
    if not initialized then Msg("Not initialized.") return end
    local acc, char = EnsureIntegrity()
    local charData = SM.SV[acc][char] or {}
    Msg("Saved companions for " .. char .. ":")
    for name, data in pairs(charData) do
        Msg(string.format(" - %s (%s)", name, data.lastUpdated or "never"))
    end
end

SLASH_COMMANDS["/smdebug"] = function()
    SM.debug = not SM.debug
    Msg("Debug mode " .. (SM.debug and "enabled" or "disabled") .. ".")
end

SLASH_COMMANDS["/seamstress"] = function()
    Msg("Commands: /smscan | /smgear [name] | /smlist | /smdebug")
end
