-- DungeonGear - role/class-aware ESO set recommendations.
-- Slash: /dungeongear (alias /dg)
-- Subcommands: tank|healer|dps|beginner|monster|overland|trial|builds|
--   collection|farming|advisor|audit|assign|unassign|export|import|share|pin

DungeonGear = DungeonGear or {}
local ADDON_NAME = "DungeonGear"

-- Per-server saved variables reference, set during onLoaded.
local sv

-- Helper: update a combo box's display text to match a label without firing
-- any callbacks. ESO's ZO_ComboBox:SelectItem always fires the callback,
-- so we just set the text directly to avoid side-effects during restore.
local function selectComboByLabel(container, label)
    local combo = ZO_ComboBox_ObjectFromContainer(container)
    if combo and combo.SetSelectedItemText then
        combo:SetSelectedItemText(label)
    end
end

local DATA_TYPE_ROW = 1
local ROW_HEIGHT = 128

local DAMAGE_TYPES = { "Any", "Stamina", "Magicka", "Hybrid" }

-- LibSets setType constants (fallbacks for when LibSets is not installed)
local ST_CRAFTED  = LIBSETS_SETTYPE_CRAFTED  or 3
local ST_DUNGEON  = LIBSETS_SETTYPE_DUNGEON  or 6
local ST_MONSTER  = LIBSETS_SETTYPE_MONSTER  or 8
local ST_OVERLAND = LIBSETS_SETTYPE_OVERLAND or 9
local ST_TRIAL    = LIBSETS_SETTYPE_TRIAL    or 11

-- Role -> LibSets setType ids. Used by the "All" toggle to enumerate everything
-- LibSets knows about for the current view category.
local ROLE_LIBSETS_SETTYPES = {
    tank     = { ST_DUNGEON, ST_TRIAL },
    healer   = { ST_DUNGEON, ST_TRIAL },
    dps      = { ST_DUNGEON, ST_TRIAL },
    beginner = { ST_CRAFTED, ST_OVERLAND },
    monster  = { ST_MONSTER },
    overland = { ST_OVERLAND },
    trial    = { ST_TRIAL },
}

local SETTYPE_DISPLAY = {
    [ST_CRAFTED]  = "Crafted",
    [ST_DUNGEON]  = "Dungeon",
    [ST_MONSTER]  = "Monster helm",
    [ST_OVERLAND] = "Overland",
    [ST_TRIAL]    = "Trial",
}

-- Equip-type groupings shown in the Collection view, in display order.
local COLLECTION_SLOTS = {
    { name = "Head",      eq = { EQUIP_TYPE_HEAD } },
    { name = "Shoulders", eq = { EQUIP_TYPE_SHOULDERS } },
    { name = "Chest",     eq = { EQUIP_TYPE_CHEST } },
    { name = "Waist",     eq = { EQUIP_TYPE_WAIST } },
    { name = "Legs",      eq = { EQUIP_TYPE_LEGS } },
    { name = "Hands",     eq = { EQUIP_TYPE_HAND } },
    { name = "Feet",      eq = { EQUIP_TYPE_FEET } },
    { name = "Necklace",  eq = { EQUIP_TYPE_NECK } },
    { name = "Rings",     eq = { EQUIP_TYPE_RING } },
    { name = "Weapons",   eq = { EQUIP_TYPE_MAIN_HAND, EQUIP_TYPE_OFF_HAND, EQUIP_TYPE_TWO_HAND } },
}

-- ---------------------------------------------------------------------------
-- Activity Finder index (built lazily for auto-queue)

local activityNameIndex = nil  -- { [normalizedName] = { id=activityId, vet=bool } }

local function normalizeDungeonName(name)
    if not name then return "" end
    return name:lower():gsub("[''']", ""):gsub("%s+", " "):gsub("^%s+",""):gsub("%s+$","")
end

local function buildActivityIndex()
    if activityNameIndex then return activityNameIndex end
    activityNameIndex = {}
    local types = {}
    if LFG_ACTIVITY_DUNGEON then types[#types+1] = { t = LFG_ACTIVITY_DUNGEON, vet = false } end
    if LFG_ACTIVITY_MASTER_DUNGEON then types[#types+1] = { t = LFG_ACTIVITY_MASTER_DUNGEON, vet = true } end
    for _, entry in ipairs(types) do
        local count = GetNumActivitiesByType and GetNumActivitiesByType(entry.t) or 0
        for i = 1, count do
            local activityId = GetActivityIdByTypeAndIndex(entry.t, i)
            if activityId then
                local rawName = GetActivityInfo(activityId)
                if rawName and rawName ~= "" then
                    local key = normalizeDungeonName(rawName)
                    activityNameIndex[key] = { id = activityId, vet = entry.vet }
                end
            end
        end
    end
    return activityNameIndex
end

local function findActivityId(dungeonName, preferVet)
    local idx = buildActivityIndex()
    local key = normalizeDungeonName(dungeonName)
    -- Exact match first.
    if idx[key] then return idx[key].id end
    -- Substring: find index entries that contain or are contained by the key.
    for indexKey, entry in pairs(idx) do
        if preferVet == entry.vet or not preferVet then
            if indexKey:find(key, 1, true) or key:find(indexKey, 1, true) then
                return entry.id
            end
        end
    end
    -- Fallback: any substring match regardless of vet preference.
    for indexKey, entry in pairs(idx) do
        if indexKey:find(key, 1, true) or key:find(indexKey, 1, true) then
            return entry.id
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Helpers

-- Detect the player's likely role from currently equipped gear.
local function detectRole()
    local hasRestoStaff, hasFrostStaff = false, false
    local heavy, medium, light = 0, 0, 0
    for slotId = 0, GetBagSize(BAG_WORN) - 1 do
        local link = GetItemLink(BAG_WORN, slotId)
        if link and link ~= "" then
            local wt = GetItemLinkWeaponType(link)
            if wt == WEAPONTYPE_HEALING_STAFF then hasRestoStaff = true end
            if wt == WEAPONTYPE_FROST_STAFF   then hasFrostStaff = true end
            local at = GetItemLinkArmorType(link)
            if at == ARMORTYPE_HEAVY  then heavy  = heavy  + 1
            elseif at == ARMORTYPE_MEDIUM then medium = medium + 1
            elseif at == ARMORTYPE_LIGHT  then light  = light  + 1 end
        end
    end
    if (hasFrostStaff or heavy >= 5) and heavy > medium then return "tank" end
    if hasRestoStaff and light > heavy then return "healer" end
    return "dps"
end

local function resolveName(row)
    if LibSets and row.setId and LibSets.GetSetInfo then
        local info = LibSets.GetSetInfo(row.setId)
        if info and info.name then
            local lang = GetCVar("language.2") or "en"
            return info.name[lang] or info.name.en or row.set
        end
    end
    return row.set
end

local function matchesClass(row, cls)
    if cls == nil or cls == "Any" then return true end
    if not row.classes or #row.classes == 0 then return true end
    for _, c in ipairs(row.classes) do
        if c == cls then return true end
    end
    return false
end

local function matchesDamageType(row, dt)
    if dt == nil or dt == "Any" then return true end
    local rdt = row.damageType
    if rdt == nil then return true end
    if rdt == "hybrid" then return true end
    if dt == "Stamina" and rdt == "stam" then return true end
    if dt == "Magicka" and rdt == "mag"  then return true end
    if dt == "Hybrid"  and rdt == "hybrid" then return true end
    return false
end

-- Strict variants used in "Showing: All" (LibSets) mode.
-- Rows without the relevant metadata field are REJECTED instead of waved
-- through, so picking a specific class/damage filter actually narrows the
-- list even when sourcing from LibSets (where rows have no tags).

local function matchesClassStrict(row, cls)
    if cls == nil or cls == "Any" then return true end
    if not row.classes or #row.classes == 0 then return false end
    for _, c in ipairs(row.classes) do
        if c == cls then return true end
    end
    return false
end

local function matchesDamageTypeStrict(row, dt)
    if dt == nil or dt == "Any" then return true end
    local rdt = row.damageType
    if rdt == nil then return false end
    if rdt == "hybrid" then return true end
    if dt == "Stamina" and rdt == "stam" then return true end
    if dt == "Magicka" and rdt == "mag"  then return true end
    if dt == "Hybrid"  and rdt == "hybrid" then return true end
    return false
end

-- Case-insensitive substring match against current search box text.
-- Empty search = match everything.
local function matchesSearch(text)
    local q = DungeonGear.searchText
    if not q or q == "" then return true end
    if not text then return false end
    return string.find(string.lower(text), q, 1, true) ~= nil
end

local function buildMetaLine(row)
    local parts = { row.dungeon or "?" }
    if row.priority then parts[#parts + 1] = "[" .. row.priority .. "]" end
    if row.slots    then parts[#parts + 1] = "slot: " .. row.slots end
    if row.weight   then parts[#parts + 1] = row.weight end
    if row.traits   then parts[#parts + 1] = "traits: " .. row.traits end
    return table.concat(parts, "  |  ")
end

function DungeonGear.IsTracked(setName)
    return sv
        and sv.tracked
        and sv.tracked[setName] == true
end

-- Find the first row in DungeonGear_Data that matches the given set name.
-- Used by ShowBuilds to pull the real dungeon / reason / meta for each set in a build.
local function findSetRow(setName)
    if not setName then return nil end
    for _, category in pairs(DungeonGear_Data) do
        for _, row in ipairs(category) do
            if row.set == setName then return row end
        end
    end
    return nil
end

-- Shallow copy so we can override slots without mutating the data table.
local function copyRow(row)
    local out = {}
    for k, v in pairs(row) do out[k] = v end
    return out
end

-- ---------------------------------------------------------------------------
-- ZO_ScrollList row wiring

local function setupRow(rowControl, data)
    local row = data
    local nameLabel   = rowControl:GetNamedChild("SetName")
    local metaLabel   = rowControl:GetNamedChild("Meta")
    local reasonLabel = rowControl:GetNamedChild("Reason")
    local trackBtn    = rowControl:GetNamedChild("TrackBtn")
    local bg          = rowControl:GetNamedChild("BG")

    local displayName = resolveName(row)
    if row._buildHeader then
        nameLabel:SetText("|cFFD700[BUILD]  " .. displayName .. "|r")
        if bg and bg.SetCenterColor then
            bg:SetCenterColor(0.35, 0.25, 0.05, 0.70)
            bg:SetEdgeColor(1.00, 0.84, 0.00, 1.00)
        end
    elseif row._collectionHeader then
        nameLabel:SetText("|c66CCFF[TRACKED]  " .. displayName .. "|r")
        if bg and bg.SetCenterColor then
            bg:SetCenterColor(0.05, 0.20, 0.32, 0.70)
            bg:SetEdgeColor(0.40, 0.80, 1.00, 1.00)
        end
    elseif row._buildComponent then
        if row.bis then
            nameLabel:SetText("    |cFFEA00* " .. displayName .. " (BiS)|r")
        else
            nameLabel:SetText("    " .. displayName)
        end
        if bg and bg.SetCenterColor then
            bg:SetCenterColor(0.18, 0.15, 0.04, 0.55)
            bg:SetEdgeColor(0.60, 0.48, 0.08, 0.80)
        end
    elseif row.bis then
        nameLabel:SetText("|cFFEA00* " .. displayName .. " (BiS)|r")
        if bg and bg.SetCenterColor then
            bg:SetCenterColor(0.13, 0.13, 0.13, 0.40)
            bg:SetEdgeColor(0.27, 0.27, 0.27, 0.53)
        end
    else
        nameLabel:SetText(displayName)
        if bg and bg.SetCenterColor then
            bg:SetCenterColor(0.13, 0.13, 0.13, 0.40)
            bg:SetEdgeColor(0.27, 0.27, 0.27, 0.53)
        end
    end
    metaLabel:SetText(buildMetaLine(row))
    reasonLabel:SetText(row.reason or "")

    if row._buildName then
        trackBtn:SetHidden(false)
        trackBtn:SetText("Details")
        trackBtn.isDetailButton = true
        trackBtn.detailBuildName = row._buildName
        trackBtn.isLinkButton = false
        trackBtn.setName = nil
    elseif row._noTrack then
        trackBtn:SetHidden(true)
        trackBtn.isDetailButton = false
        trackBtn.isLinkButton = false
    else
        trackBtn:SetHidden(false)
        trackBtn.isDetailButton = false
        trackBtn.isLinkButton = false
        trackBtn.setName = row.set
        trackBtn:SetText(DungeonGear.IsTracked(row.set) and "Untrack" or "Track")
    end

    -- Progress bar (shown on collection/farming header rows only).
    local progressBar  = rowControl:GetNamedChild("ProgressBar")
    local progressText = rowControl:GetNamedChild("ProgressText")
    if progressBar and progressText then
        if row._collectionHeader and row._slotsTotal and row._slotsTotal > 0 then
            progressBar:SetHidden(false)
            progressText:SetHidden(false)
            progressBar:SetMinMax(0, row._slotsTotal)
            progressBar:SetValue(row._slotsOwned or 0)
            progressText:SetText(string.format("%d/%d", row._slotsOwned or 0, row._slotsTotal))
        else
            progressBar:SetHidden(true)
            progressText:SetHidden(true)
        end
    end

    -- Queue button: shown as "Queue" for dungeon rows, or "Assign"/"Unassign" for build headers.
    local queueBtn = rowControl:GetNamedChild("QueueBtn")
    if queueBtn then
        if row._buildHeader and row._buildName then
            -- Show Assign/Unassign button on build header rows.
            local assigned = DungeonGear.GetAssignedBuild()
            queueBtn:SetHidden(false)
            queueBtn.dungeonName = nil
            queueBtn.assignBuildName = row._buildName
            if assigned == row._buildName then
                queueBtn:SetText("Unassign")
            else
                queueBtn:SetText("Assign")
            end
        elseif row.dungeon and row.dungeon ~= ""
            and not row._noTrack and not row._collectionHeader
        then
            queueBtn:SetHidden(false)
            queueBtn:SetText("Queue")
            queueBtn.dungeonName = row.dungeon
            queueBtn.assignBuildName = nil
        else
            queueBtn:SetHidden(true)
            queueBtn.assignBuildName = nil
        end
    end
end

function DungeonGear.InitScrollList()
    local list = DungeonGearWindowList
    ZO_ScrollList_AddDataType(list, DATA_TYPE_ROW, "DungeonGearRow", ROW_HEIGHT, setupRow)
    ZO_ScrollList_SetTypeSelectable(list, DATA_TYPE_ROW, false)
end

-- ---------------------------------------------------------------------------
-- Inventory scan (for Collection view)

local function scanInventoryForSets()
    -- Returns { [setName] = { [equipType] = count } }
    local result = {}
    local bags = { BAG_WORN, BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK }
    for _, bagId in ipairs(bags) do
        if bagId then
            local numSlots = GetBagSize(bagId) or 0
            for slotId = 0, numSlots - 1 do
                local itemLink = GetItemLink(bagId, slotId)
                if itemLink and itemLink ~= "" then
                    local hasSet, setName = GetItemLinkSetInfo(itemLink, false)
                    if hasSet and setName and setName ~= "" then
                        local equipType = GetItemLinkEquipType(itemLink)
                        result[setName] = result[setName] or {}
                        result[setName][equipType] = (result[setName][equipType] or 0) + 1
                    end
                end
            end
        end
    end
    return result
end

local function countSlotOwned(ownedByEquip, slot)
    local n = 0
    for _, et in ipairs(slot.eq) do
        n = n + (ownedByEquip[et] or 0)
    end
    return n
end

-- Reverse index: set display name -> LibSets setId. Built lazily, cached forever
-- (LibSets data doesn't change at runtime).
local libSetNameIndex = nil
local function getSetNameIndex()
    if libSetNameIndex then return libSetNameIndex end
    if not LibSets or not LibSets.setInfo then return nil end
    local idx = {}
    for setId, info in pairs(LibSets.setInfo) do
        if info.setNames then
            for _, name in pairs(info.setNames) do
                if name and name ~= "" then idx[name] = setId end
            end
        end
    end
    libSetNameIndex = idx
    return idx
end

local function isCuratedMonsterSet(setName)
    for _, row in ipairs(DungeonGear_Data.monster or {}) do
        if row.set == setName then return true end
    end
    return false
end

-- Return the subset of COLLECTION_SLOTS that apply to this set, based on LibSets
-- equip-type metadata if available, else heuristics.
local function getValidSlotsForSet(setName)
    local idx = getSetNameIndex()
    if idx and LibSets and LibSets.setInfo then
        local setId = idx[setName]
        if setId then
            local info = LibSets.setInfo[setId]
            if info then
                -- Monster helm: only head + shoulders.
                if info.setType == 8 then
                    return { COLLECTION_SLOTS[1], COLLECTION_SLOTS[2] }
                end
                -- Use LibSets setsEquipTypes to narrow if available.
                if info.setsEquipTypes and type(info.setsEquipTypes) == "table" then
                    local allowed = {}
                    for _, et in pairs(info.setsEquipTypes) do
                        allowed[et] = true
                    end
                    local filtered = {}
                    for _, slot in ipairs(COLLECTION_SLOTS) do
                        for _, et in ipairs(slot.eq) do
                            if allowed[et] then
                                filtered[#filtered + 1] = slot
                                break
                            end
                        end
                    end
                    if #filtered > 0 then return filtered end
                end
            end
        end
    end
    -- Fallback when LibSets isn't loaded or the set is unknown to LibSets:
    -- at least catch curated monster sets so they don't show all 10 slots.
    if isCuratedMonsterSet(setName) then
        return { COLLECTION_SLOTS[1], COLLECTION_SLOTS[2] }
    end
    return COLLECTION_SLOTS
end

-- Pull a set name from ESO natively by building an item link from any known itemId.
-- This is the ground truth (matches what shows on tooltips) and is always localized.
local function setNameFromItemId(itemId)
    if not itemId then return nil end
    local link = string.format(
        "|H1:item:%d:364:50:0:0:0:0:0:0:0:0:0:0:0:0:30:0:0:0:0:0|h|h", itemId)
    local hasSet, setName = GetItemLinkSetInfo(link, false)
    if hasSet and setName and setName ~= "" then return setName end
    return nil
end

-- Extract any itemId from the (nested) setItemIds table LibSets stores per set.
local function firstItemIdFromSetInfo(info)
    local ids = info.setItemIds
    if not ids then return nil end
    if type(ids) == "number" then return ids end
    if type(ids) == "table" then
        for k, v in pairs(ids) do
            if type(k) == "number" and k > 1000 then return k end
            if type(v) == "number" and v > 1000 then return v end
            if type(v) == "table" then
                for kk, vv in pairs(v) do
                    if type(kk) == "number" and kk > 1000 then return kk end
                    if type(vv) == "number" and vv > 1000 then return vv end
                end
            end
        end
    end
    return nil
end

local function resolveLibSetName(setId, info, lang)
    if info.setNames then
        local n = info.setNames[lang] or info.setNames.en or info.setNames["en"]
        if n and n ~= "" then return n end
    end
    local n2 = setNameFromItemId(firstItemIdFromSetInfo(info))
    if n2 then return n2 end
    return nil
end

-- Returns the top-tier bonus text for a set, via an item link built from
-- any representative itemId. Uses ESO's native GetItemLinkSetBonusInfo,
-- which returns the exact localized tooltip text.
local function getSetBonusSummary(itemId)
    if not itemId then return nil end
    local link = string.format(
        "|H1:item:%d:364:50:0:0:0:0:0:0:0:0:0:0:0:0:30:0:0:0:0:0|h|h", itemId)
    local hasSet, _, numBonuses = GetItemLinkSetInfo(link, false)
    if not hasSet or not numBonuses or numBonuses == 0 then return nil end
    -- Top bonus (usually 5pc for armor, 2pc for monster, 3pc for jewelry) is
    -- the one players care about.
    local numRequired, desc = GetItemLinkSetBonusInfo(link, false, numBonuses)
    if not desc or desc == "" then return nil end
    return string.format("(%d) %s", numRequired or numBonuses, desc)
end

-- Build a full-library row list for the current view by iterating LibSets.setInfo.
-- Returns nil if LibSets isn't loaded, empty table if role has no mapping.
local function gatherFromLibSets(role)
    if not LibSets or not LibSets.setInfo then return nil end
    local wanted = ROLE_LIBSETS_SETTYPES[role]
    if not wanted then return {} end
    local wantedMap = {}
    for _, t in ipairs(wanted) do wantedMap[t] = true end

    -- Pre-build a name -> curated row index so we can enrich LibSets rows
    -- with class/damageType/bis tags where we have them, letting the filters
    -- surface curated sets in All mode.
    local curatedByName = {}
    for _, category in pairs(DungeonGear_Data) do
        for _, crow in ipairs(category) do
            if crow.set and not curatedByName[crow.set] then
                curatedByName[crow.set] = crow
            end
        end
    end

    local lang = GetCVar("language.2") or "en"
    local rows = {}
    for setId, info in pairs(LibSets.setInfo) do
        if info and wantedMap[info.setType] then
            local name = resolveLibSetName(setId, info, lang)
                      or ("(unnamed setId " .. tostring(setId) .. ")")
            local itemId = firstItemIdFromSetInfo(info)
            local bonus  = getSetBonusSummary(itemId) or "(from LibSets library)"
            local curated = curatedByName[name]
            rows[#rows + 1] = {
                set        = name,
                dungeon    = SETTYPE_DISPLAY[info.setType] or ("setType " .. tostring(info.setType)),
                reason     = bonus,
                setId      = setId,
                priority   = nil,
                classes    = curated and curated.classes    or nil,
                damageType = curated and curated.damageType or nil,
                bis        = curated and curated.bis        or nil,
            }
        end
    end
    table.sort(rows, function(a, b) return (a.set or "") < (b.set or "") end)
    return rows
end

-- ---------------------------------------------------------------------------
-- Router: re-run whichever view is currently active with current filters

local initComplete = false   -- suppress refreshCurrent during addon load

local function refreshCurrent()
    if not initComplete then return end
    if DungeonGear.currentRole == "builds" then
        DungeonGear.ShowBuilds()
    elseif DungeonGear.currentRole == "collection" then
        DungeonGear.ShowCollection()
    elseif DungeonGear.currentRole == "farming" then
        DungeonGear.ShowFarming()
    elseif DungeonGear.currentRole == "advisor" then
        DungeonGear.ShowUpgradeAdvisor()
    elseif DungeonGear.currentRole == "audit" then
        DungeonGear.ShowAudit()
    elseif DungeonGear.currentRole then
        DungeonGear.ShowRole(DungeonGear.currentRole)
    end
end

-- ---------------------------------------------------------------------------
-- Filter dropdowns

function DungeonGear.InitClassCombo()
    local combo = ZO_ComboBox_ObjectFromContainer(DungeonGearWindowClassFilter)
    combo:SetSortsItems(false)
    combo:ClearItems()
    for _, cls in ipairs(DungeonGear_Classes) do
        local entry = combo:CreateItemEntry(cls, function()
            DungeonGear.currentClass = cls
            if sv then sv.currentClass = cls end
            refreshCurrent()
        end)
        combo:AddItem(entry)
    end
    combo:SelectFirstItem()
    DungeonGear.currentClass = "Any"
end

function DungeonGear.InitDamageCombo()
    local combo = ZO_ComboBox_ObjectFromContainer(DungeonGearWindowDamageFilter)
    combo:SetSortsItems(false)
    combo:ClearItems()
    for _, dt in ipairs(DAMAGE_TYPES) do
        local entry = combo:CreateItemEntry(dt, function()
            DungeonGear.currentDamageType = dt
            if sv then sv.currentDamageType = dt end
            refreshCurrent()
        end)
        combo:AddItem(entry)
    end
    combo:SelectFirstItem()
    DungeonGear.currentDamageType = "Any"
end

-- View dropdown replaces the old role button grid. Each entry dispatches to
-- ShowRole / ShowBuilds / ShowCollection as appropriate.
local VIEW_ITEMS = {
    { label = "Tank",     action = function() DungeonGear.ShowRole("tank") end },
    { label = "Healer",   action = function() DungeonGear.ShowRole("healer") end },
    { label = "DPS",      action = function() DungeonGear.ShowRole("dps") end },
    { label = "Beginner", action = function() DungeonGear.ShowRole("beginner") end },
    { label = "Monster",  action = function() DungeonGear.ShowRole("monster") end },
    { label = "Overland", action = function() DungeonGear.ShowRole("overland") end },
    { label = "Trial",    action = function() DungeonGear.ShowRole("trial") end },
    { label = "Builds",   action = function() DungeonGear.ShowBuilds() end },
    { label = "Farming",  action = function() DungeonGear.ShowFarming() end },
    { label = "Advisor", action = function() DungeonGear.ShowUpgradeAdvisor() end },
    { label = "Audit",   action = function() DungeonGear.ShowAudit() end },
}

function DungeonGear.InitViewCombo()
    local combo = ZO_ComboBox_ObjectFromContainer(DungeonGearWindowViewCombo)
    combo:SetSortsItems(false)
    combo:ClearItems()
    for _, item in ipairs(VIEW_ITEMS) do
        combo:AddItem(combo:CreateItemEntry(item.label, item.action))
    end
    -- Do NOT call SelectFirstItem during init - it would fire the Tank
    -- callback which opens the window on /reloadui. Set the display text
    -- only; actual data load happens when the user opens the window via /dg.
    if combo.SetSelectedItemText then
        combo:SetSelectedItemText(VIEW_ITEMS[1].label)
    end
end

function DungeonGear.InitDetailWindow()
    local scroll = DungeonGearDetailWindowScroll
    if not scroll then return end
    local scrollChild = scroll:GetNamedChild("ScrollChild")
    if not scrollChild then return end
    local label = WINDOW_MANAGER:CreateControl(
        "DungeonGearDetailText", scrollChild, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetColor(0.93, 0.93, 0.93, 1)
    label:SetWrapMode(TEXT_WRAP_MODE_WRAP)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    -- Only anchor TOPLEFT. Width is set explicitly in ShowBuildDetail so
    -- there's no size cycle back through the scroll child.
    label:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 4, 4)
    DungeonGear._detailLabel = label
end

-- ---------------------------------------------------------------------------
-- Show / Hide / Toggle (manages cursor/UI mode)

function DungeonGear.Show()
    DungeonGearWindow:SetHidden(false)
    -- Only grab cursor mode if nothing else currently holds it.
    if IsGameCameraUIModeActive and not IsGameCameraUIModeActive() then
        SetGameCameraUIMode(true)
    end
end

function DungeonGear.Hide()
    -- NEVER call SetGameCameraUIMode(false) here. Force-releasing UI mode
    -- strands the game in a half-closed state where the action bar stays
    -- disabled. Just hide the window; press Alt (or your cursor-toggle key)
    -- to return to combat.
    DungeonGearWindow:SetHidden(true)
end

function DungeonGear.Toggle()
    if DungeonGearWindow:IsHidden() then
        DungeonGear.Show()
    else
        DungeonGear.Hide()
    end
end

-- ---------------------------------------------------------------------------
-- Main view

function DungeonGear.ShowRole(role)
    local metaOnly = DungeonGear.metaOnly
    local rows
    local sourceLabel

    if metaOnly then
        rows = DungeonGear_Data[role]
        if not rows then
            d("[DungeonGear] Unknown role: " .. tostring(role))
            return
        end
        sourceLabel = "meta"
    else
        rows = gatherFromLibSets(role)
        if rows == nil then
            d("[DungeonGear] 'All' mode requires LibSets. Install it or toggle back to Meta.")
            DungeonGearWindowStatus:SetText(
                "LibSets not loaded - 'All' mode unavailable. Toggle back to Meta.")
            DungeonGear.currentRole = role
            if sv then sv.currentRole = role end
            DungeonGear.Show()
            return
        end
        sourceLabel = "all/lib"
    end

    DungeonGear.currentRole = role
    if sv then sv.currentRole = role end

    local list = DungeonGearWindowList
    ZO_ScrollList_Clear(list)
    local dataList = ZO_ScrollList_GetDataList(list)

    local cls = DungeonGear.currentClass or "Any"
    local dt  = DungeonGear.currentDamageType or "Any"
    -- In meta mode, universal (untagged) rows pass any filter. In All mode
    -- we require explicit tag matches so the filters actually narrow the
    -- LibSets dump.
    local classFn = metaOnly and matchesClass or matchesClassStrict
    local dtFn    = metaOnly and matchesDamageType or matchesDamageTypeStrict
    local count = 0
    for _, row in ipairs(rows) do
        if classFn(row, cls) and dtFn(row, dt) and matchesSearch(row.set) then
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, row)
            count = count + 1
        end
    end
    ZO_ScrollList_Commit(list)
    if ZO_ScrollList_ResetToTop then
        ZO_ScrollList_ResetToTop(list)
    end

    DungeonGearWindowStatus:SetText(
        string.format("%d sets  -  role: %s  -  class: %s  -  dmg: %s  -  source: %s",
                      count, role, cls, dt, sourceLabel))
    DungeonGear.Show()
end

-- ---------------------------------------------------------------------------
-- Builds view: curated complete loadouts.
-- Each build is rendered as 4 rows: a header, then the 3 component sets
-- with their real dungeon/reason pulled from DungeonGear_Data.

local function makeBuildHeaderRow(b)
    local parts = {}
    if b.role       then parts[#parts+1] = b.role end
    if b.class      then parts[#parts+1] = b.class end
    if b.damageType then parts[#parts+1] = b.damageType end
    local assigned = DungeonGear.GetAssignedBuild and DungeonGear.GetAssignedBuild()
    local setLabel = b.name
    if assigned == b.name then
        setLabel = "|c00FF00[ASSIGNED]|r  " .. b.name
    end
    return {
        set          = setLabel,
        dungeon      = table.concat(parts, " / "),
        priority     = "build",
        reason       = b.summary or "",
        _buildHeader = true,
        _noTrack     = true,
        _buildName   = b.name,
    }
end

local function makeBuildComponentRow(setName, slotLabel)
    local real = findSetRow(setName)
    if real then
        local row = copyRow(real)
        row.slots = slotLabel
        row._buildComponent = true
        return row
    end
    return {
        set             = setName or "?",
        dungeon         = "(set not in data - check DungeonGearData.lua)",
        slots           = slotLabel,
        reason          = "",
        _buildComponent = true,
    }
end

function DungeonGear.ShowBuilds()
    DungeonGear.currentRole = "builds"
    if sv then sv.currentRole = "builds" end

    local list = DungeonGearWindowList
    ZO_ScrollList_Clear(list)
    local dataList = ZO_ScrollList_GetDataList(list)

    local cls = DungeonGear.currentClass or "Any"
    local dt  = DungeonGear.currentDamageType or "Any"
    local buildCount = 0

    for _, b in ipairs(DungeonGear_Builds or {}) do
        local classOk = (cls == "Any") or (b.class == nil) or (b.class == cls)
        local dtOk
        if dt == "Any" or b.damageType == nil or b.damageType == "hybrid" then
            dtOk = true
        elseif dt == "Stamina" and b.damageType == "stam" then
            dtOk = true
        elseif dt == "Magicka" and b.damageType == "mag" then
            dtOk = true
        elseif dt == "Hybrid" and b.damageType == "hybrid" then
            dtOk = true
        else
            dtOk = false
        end

        local searchOk = matchesSearch(b.name)
            or matchesSearch(b.body) or matchesSearch(b.jewelry) or matchesSearch(b.monster)
        if classOk and dtOk and searchOk then
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(
                DATA_TYPE_ROW, makeBuildHeaderRow(b))
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(
                DATA_TYPE_ROW, makeBuildComponentRow(b.body,    "5pc body"))
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(
                DATA_TYPE_ROW, makeBuildComponentRow(b.jewelry, "5pc jewelry+weapons"))
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(
                DATA_TYPE_ROW, makeBuildComponentRow(b.monster, "2pc monster helm+shoulder"))
            buildCount = buildCount + 1
        end
    end

    ZO_ScrollList_Commit(list)
    if ZO_ScrollList_ResetToTop then
        ZO_ScrollList_ResetToTop(list)
    end

    DungeonGearWindowStatus:SetText(
        string.format("%d builds  -  class: %s  -  dmg: %s", buildCount, cls, dt))
    DungeonGear.Show()
end

-- ---------------------------------------------------------------------------
-- Sticker book (set collection) integration.
-- Lazily checks each tracked set via LibSets item IDs +
-- IsItemSetCollectionPieceUnlocked(itemId).

local stickerBookCache = nil
local nameToSetId = nil    -- { [setName] = setId } reverse lookup

local function buildNameToSetIdIndex()
    if nameToSetId then return nameToSetId end
    if not LibSets or not LibSets.setInfo then return nil end
    nameToSetId = {}
    local lang = GetCVar("language.2") or "en"
    for setId, info in pairs(LibSets.setInfo) do
        if info then
            -- Index by localized name and English name.
            if info.name then
                local locName = info.name[lang]
                local enName  = info.name.en
                if locName and locName ~= "" then nameToSetId[locName] = setId end
                if enName and enName ~= "" and enName ~= locName then
                    nameToSetId[enName] = setId
                end
            end
            -- Also index by setNames if available.
            if info.setNames then
                local locName = info.setNames[lang]
                local enName  = info.setNames.en
                if locName and locName ~= "" then nameToSetId[locName] = setId end
                if enName and enName ~= "" then nameToSetId[enName] = setId end
            end
        end
    end
    return nameToSetId
end

local function getStickerBookStatus(setName)
    if not IsItemSetCollectionPieceUnlocked then return nil end
    if not LibSets or not LibSets.GetSetItemIds then return nil end

    -- Check cache first.
    if stickerBookCache and stickerBookCache[setName] then
        return stickerBookCache[setName]
    end

    -- Build name index if needed.
    local idx = buildNameToSetIdIndex()
    if not idx then return nil end

    local setId = idx[setName]
    if not setId then return nil end

    local itemIds = LibSets.GetSetItemIds(setId)
    if not itemIds then return nil end

    local total, unlocked = 0, 0
    for itemId, _ in pairs(itemIds) do
        total = total + 1
        if IsItemSetCollectionPieceUnlocked(itemId) then
            unlocked = unlocked + 1
        end
    end

    stickerBookCache = stickerBookCache or {}
    stickerBookCache[setName] = { total = total, unlocked = unlocked }
    return stickerBookCache[setName]
end

-- ---------------------------------------------------------------------------
-- Collection view: tick list of pieces owned vs missing for each tracked set

function DungeonGear.ShowCollection()
    DungeonGear.currentRole = "collection"
    if sv then sv.currentRole = "collection" end
    stickerBookCache = nil   -- refresh sticker book data each time

    local list = DungeonGearWindowList
    ZO_ScrollList_Clear(list)
    local dataList = ZO_ScrollList_GetDataList(list)

    local tracked = (sv and sv.tracked) or {}

    local trackedNames = {}
    for name, v in pairs(tracked) do
        if v then trackedNames[#trackedNames + 1] = name end
    end
    table.sort(trackedNames)

    if #trackedNames == 0 then
        local empty = {
            set      = "No tracked sets yet",
            dungeon  = "Open any role view and click 'Track' on a set to add it here",
            reason   = "The Collection view shows which pieces you already own vs still need.",
            _noTrack = true,
        }
        dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, empty)
    else
        local scanned = scanInventoryForSets()
        for _, setName in ipairs(trackedNames) do
            if matchesSearch(setName) then
            local owned = scanned[setName] or {}
            local validSlots = getValidSlotsForSet(setName)

            local totalOwned = 0
            for _, v in pairs(owned) do totalOwned = totalOwned + v end

            local slotsWithPieces = 0
            for _, slot in ipairs(validSlots) do
                if countSlotOwned(owned, slot) > 0 then
                    slotsWithPieces = slotsWithPieces + 1
                end
            end

            -- Sticker book / reconstructible status.
            local stickerStatus = getStickerBookStatus(setName)
            local stickerText = ""
            if stickerStatus then
                if stickerStatus.unlocked >= stickerStatus.total and stickerStatus.total > 0 then
                    stickerText = "  |c00FF00[Reconstructible]|r"
                elseif stickerStatus.unlocked > 0 then
                    stickerText = string.format("  |cFFAA00[Sticker Book: %d/%d]|r",
                        stickerStatus.unlocked, stickerStatus.total)
                end
            end

            local header = {
                set               = setName,
                dungeon           = string.format("%d pieces owned  -  %d / %d slot types covered",
                                                  totalOwned, slotsWithPieces, #validSlots),
                reason            = "Tracked set progress (scanned inventory + bank + equipped)"
                                    .. stickerText,
                _collectionHeader = true,
                _noTrack          = true,
                _slotsOwned       = slotsWithPieces,
                _slotsTotal       = #validSlots,
            }
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, header)

            -- Resolve setId for sticker book per-slot checks.
            local setIdForSlot = nameToSetId and nameToSetId[setName] or nil

            for _, slot in ipairs(validSlots) do
                local count = countSlotOwned(owned, slot)
                local pieceRow
                if count > 0 then
                    local suffix = (count > 1) and (" (x" .. count .. ")") or ""
                    pieceRow = {
                        set      = "|c66FF66[X] " .. slot.name .. suffix .. "|r",
                        dungeon  = "Found in your inventory / bank / equipped",
                        reason   = "",
                        _noTrack = true,
                    }
                else
                    -- Check if this slot is reconstructible from sticker book.
                    local canReconstruct = false
                    if setIdForSlot and IsItemSetCollectionPieceUnlocked and LibSets and LibSets.GetSetItemIds then
                        for _, eqType in ipairs(slot.eq) do
                            local slotItemIds = LibSets.GetSetItemIds(setIdForSlot, nil, eqType)
                            if slotItemIds then
                                for itemId, _ in pairs(slotItemIds) do
                                    if IsItemSetCollectionPieceUnlocked(itemId) then
                                        canReconstruct = true
                                        break
                                    end
                                end
                            end
                            if canReconstruct then break end
                        end
                    end

                    if canReconstruct then
                        pieceRow = {
                            set      = "|cAA66FF[R] " .. slot.name .. " (reconstructible)|r",
                            dungeon  = "Unlocked in sticker book - reconstruct at any transmute station",
                            reason   = "",
                            _noTrack = true,
                        }
                    else
                        pieceRow = {
                            set      = "|c888888[ ] " .. slot.name .. "|r",
                            dungeon  = "Not found yet",
                            reason   = "",
                            _noTrack = true,
                        }
                    end
                end
                dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, pieceRow)
            end
            end -- if matchesSearch(setName)
        end
    end

    ZO_ScrollList_Commit(list)
    if ZO_ScrollList_ResetToTop then
        ZO_ScrollList_ResetToTop(list)
    end

    DungeonGearWindowStatus:SetText(
        string.format("%d tracked sets  -  click Collection again to refresh after looting",
                      #trackedNames))
    DungeonGear.Show()
end

-- ---------------------------------------------------------------------------
-- Farming priority view: rank dungeons by how many tracked sets drop there

function DungeonGear.ShowFarming()
    DungeonGear.currentRole = "farming"
    if sv then sv.currentRole = "farming" end

    local list = DungeonGearWindowList
    ZO_ScrollList_Clear(list)
    local dataList = ZO_ScrollList_GetDataList(list)

    local tracked = (sv and sv.tracked) or {}

    -- Aggregate tracked sets by dungeon.
    local dungeonSets = {}   -- { [dungeonName] = { set1, set2, ... } }
    local totalTracked = 0
    for setName, v in pairs(tracked) do
        if v then
            totalTracked = totalTracked + 1
            local row = findSetRow(setName)
            local dungeon = row and row.dungeon or "Unknown"
            if not dungeonSets[dungeon] then dungeonSets[dungeon] = {} end
            dungeonSets[dungeon][#dungeonSets[dungeon] + 1] = setName
        end
    end

    -- Sort by count descending, then name ascending.
    local sorted = {}
    for dungeon, sets in pairs(dungeonSets) do
        table.sort(sets)
        sorted[#sorted + 1] = { dungeon = dungeon, sets = sets, count = #sets }
    end
    table.sort(sorted, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return a.dungeon < b.dungeon
    end)

    if #sorted == 0 then
        dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, {
            set      = "No tracked sets yet",
            dungeon  = "Track sets from any role view to see farming priorities here",
            reason   = "",
            _noTrack = true,
        })
    else
        for _, entry in ipairs(sorted) do
            -- Header row for the dungeon.
            local headerRow = {
                set     = string.format("%s  (%d tracked set%s)",
                              entry.dungeon, entry.count, entry.count > 1 and "s" or ""),
                dungeon = "Sets: " .. table.concat(entry.sets, ", "),
                reason  = string.format("Run this dungeon to farm %d of your tracked sets",
                              entry.count),
                _noTrack          = true,
                _collectionHeader = true,
            }
            dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, headerRow)

            -- Individual set rows under this dungeon.
            for _, setName in ipairs(entry.sets) do
                local real = findSetRow(setName)
                local row = {
                    set     = setName,
                    dungeon = real and real.dungeon or entry.dungeon,
                    reason  = real and real.reason or "",
                    priority = real and real.priority or "",
                    weight  = real and real.weight or nil,
                    traits  = real and real.traits or nil,
                    slots   = real and real.slots or nil,
                    _noTrack = true,
                }
                dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, row)
            end
        end
    end

    ZO_ScrollList_Commit(list)
    if ZO_ScrollList_ResetToTop then
        ZO_ScrollList_ResetToTop(list)
    end

    DungeonGearWindowStatus:SetText(
        string.format("%d dungeon%s covering %d tracked sets  -  sorted by priority",
                      #sorted, #sorted ~= 1 and "s" or "", totalTracked))
    DungeonGear.Show()
end

-- ---------------------------------------------------------------------------
-- Upgrade Advisor: compare equipped gear to recommended builds

-- ESO class IDs to DungeonGear_Classes names.
local CLASS_ID_TO_NAME = {
    [1] = "DragonKnight", [2] = "Sorcerer",    [3] = "Nightblade",
    [4] = "Warden",       [5] = "Necromancer",  [6] = "Templar",
    [117] = "Arcanist",
}

function DungeonGear.ShowUpgradeAdvisor()
    DungeonGear.currentRole = "advisor"
    if sv then sv.currentRole = "advisor" end

    local list = DungeonGearWindowList
    ZO_ScrollList_Clear(list)
    local dataList = ZO_ScrollList_GetDataList(list)

    -- Detect player class.
    local classId = GetUnitClassId("player")
    local playerClass = CLASS_ID_TO_NAME[classId] or "Unknown"

    -- Scan worn sets.
    local wornSets = {}
    for slotId = 0, GetBagSize(BAG_WORN) - 1 do
        local link = GetItemLink(BAG_WORN, slotId)
        if link and link ~= "" then
            local hasSet, setName = GetItemLinkSetInfo(link, false)
            if hasSet and setName and setName ~= "" then
                wornSets[setName] = true
            end
        end
    end

    -- Check each build that matches this player's class.
    -- Prioritize the assigned build by sorting it first.
    local assignedBuild = DungeonGear.GetAssignedBuild and DungeonGear.GetAssignedBuild()
    local sortedBuilds = {}
    for _, b in ipairs(DungeonGear_Builds) do sortedBuilds[#sortedBuilds+1] = b end
    if assignedBuild then
        table.sort(sortedBuilds, function(a, b)
            if a.name == assignedBuild and b.name ~= assignedBuild then return true end
            if b.name == assignedBuild and a.name ~= assignedBuild then return false end
            return false  -- preserve original order otherwise
        end)
    end

    local upgradeCount = 0
    local matchedBuilds = 0
    for _, build in ipairs(sortedBuilds) do
        local classMatch = (build.class == nil) or (build.class == playerClass)
        if classMatch then
            matchedBuilds = matchedBuilds + 1
            local slots = {
                { name = build.body,    label = "5pc body" },
                { name = build.jewelry, label = "5pc jewelry+weapons" },
                { name = build.monster, label = "2pc monster helm+shoulder" },
            }

            -- Build header.
            local missing = {}
            for _, s in ipairs(slots) do
                if s.name and not wornSets[s.name] then
                    missing[#missing + 1] = s.name
                end
            end

            if #missing > 0 then
                -- Header for this build.
                local headerRow = {
                    set     = string.format("|cFFD700[ADVISOR]|r  %s", build.name),
                    dungeon = build.summary or "",
                    reason  = string.format("%d of 3 sets equipped - %d upgrade(s) available",
                                  3 - #missing, #missing),
                    _noTrack      = true,
                    _buildHeader  = true,
                    _buildName    = build.name,
                }
                dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, headerRow)

                for _, s in ipairs(slots) do
                    if s.name and not wornSets[s.name] then
                        upgradeCount = upgradeCount + 1
                        local real = findSetRow(s.name)
                        local row = {
                            set     = string.format("|cFF6666UPGRADE:|r %s  (%s)", s.name, s.label),
                            dungeon = real and real.dungeon or "Unknown",
                            reason  = string.format("Farm from: %s", real and real.dungeon or "?"),
                            _noTrack = true,
                        }
                        dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, row)
                    else
                        local row = {
                            set     = string.format("|c66FF66EQUIPPED:|r %s  (%s)", s.name, s.label),
                            dungeon = "Already wearing this set",
                            reason  = "",
                            _noTrack = true,
                        }
                        dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, row)
                    end
                end
            else
                -- All sets equipped for this build!
                local row = {
                    set     = string.format("|c66FF66[COMPLETE]|r  %s", build.name),
                    dungeon = build.summary or "",
                    reason  = "You're running this full loadout!",
                    _noTrack     = true,
                    _buildHeader = true,
                    _buildName   = build.name,
                }
                dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, row)
            end
        end
    end

    if matchedBuilds == 0 then
        dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, {
            set      = "No builds found for your class: " .. playerClass,
            dungeon  = "Check the Builds view for available loadouts",
            reason   = "",
            _noTrack = true,
        })
    end

    ZO_ScrollList_Commit(list)
    if ZO_ScrollList_ResetToTop then
        ZO_ScrollList_ResetToTop(list)
    end

    DungeonGearWindowStatus:SetText(
        string.format("%s (%s)  -  %d build(s) checked  -  %d upgrade(s) available",
                      "Advisor", playerClass, matchedBuilds, upgradeCount))
    DungeonGear.Show()
end

-- ---------------------------------------------------------------------------
-- Trait / Quality Audit view

-- Parse a traits string like "Divines", "Reinforced / Sturdy",
-- "Infused (weapons) / Reinforced" into a set of acceptable trait names.
local function parseAcceptableTraits(traitsStr)
    if not traitsStr or traitsStr == "" or traitsStr == "any" then return nil end
    local result = {}
    for token in traitsStr:gmatch("[^/,]+") do
        local clean = token:match("^%s*(.-)%s*$")  -- trim
        clean = clean:gsub("%s*%(.-%)%s*", "")       -- strip annotations like (weapons)
        if clean ~= "" then
            result[clean:lower()] = true
        end
    end
    if not next(result) then return nil end
    return result
end

function DungeonGear.ShowAudit()
    DungeonGear.currentRole = "audit"
    if sv then sv.currentRole = "audit" end

    local list = DungeonGearWindowList
    ZO_ScrollList_Clear(list)
    local dataList = ZO_ScrollList_GetDataList(list)

    local issueCount = 0
    local checkedCount = 0

    -- Scan worn gear, group by set.
    local wornBySet = {}  -- { [setName] = { { slotId, link, traitType, quality } } }
    for slotId = 0, GetBagSize(BAG_WORN) - 1 do
        local link = GetItemLink(BAG_WORN, slotId)
        if link and link ~= "" then
            local hasSet, setName = GetItemLinkSetInfo(link, false)
            if hasSet and setName and setName ~= "" then
                local traitType = GetItemLinkTraitInfo(link)
                local quality = GetItemLinkFunctionalQuality(link)
                wornBySet[setName] = wornBySet[setName] or {}
                wornBySet[setName][#wornBySet[setName] + 1] = {
                    slotId = slotId, link = link,
                    traitType = traitType, quality = quality,
                }
            end
        end
    end

    -- For each worn set, find the data row for recommended traits.
    local sortedSets = {}
    for name in pairs(wornBySet) do sortedSets[#sortedSets+1] = name end
    table.sort(sortedSets)

    for _, setName in ipairs(sortedSets) do
        if matchesSearch(setName) then
        local dataRow = findSetRow(setName)
        local acceptable = dataRow and parseAcceptableTraits(dataRow.traits) or nil
        local recTraits = (dataRow and dataRow.traits) or "any"

        -- Header for this set.
        dataList[#dataList+1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, {
            set      = "|cFFD700[AUDIT]|r  " .. setName,
            dungeon  = "Recommended traits: " .. recTraits,
            reason   = "",
            _noTrack = true,
            _buildHeader = true,
        })

        for _, piece in ipairs(wornBySet[setName]) do
            checkedCount = checkedCount + 1
            local traitName = GetString("SI_ITEMTRAITTYPE", piece.traitType) or "None"
            local qualityName = GetString("SI_ITEMQUALITY", piece.quality) or "Unknown"
            local equipType = GetItemLinkEquipType(piece.link)
            local slotName = GetString("SI_EQUIPTYPE", equipType) or ("slot " .. tostring(piece.slotId))

            local traitOk = true
            if acceptable and piece.traitType ~= 0 then
                traitOk = acceptable[traitName:lower()] or false
            end
            local qualityOk = piece.quality >= (ITEM_FUNCTIONAL_QUALITY_ARTIFACT or 4)

            local statusParts = {}
            if not traitOk then
                statusParts[#statusParts+1] = string.format("|cFF6666WRONG TRAIT:|r has %s, want %s", traitName, recTraits)
                issueCount = issueCount + 1
            end
            if not qualityOk then
                statusParts[#statusParts+1] = string.format("|cFFAA00LOW QUALITY:|r %s (want Epic+)", qualityName)
                issueCount = issueCount + 1
            end

            local status
            if #statusParts > 0 then
                status = table.concat(statusParts, "  |  ")
            else
                status = "|c66FF66OK|r — " .. traitName .. " / " .. qualityName
            end

            dataList[#dataList+1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, {
                set      = "    " .. slotName .. ": " .. traitName .. " (" .. qualityName .. ")",
                dungeon  = status,
                reason   = "",
                _noTrack = true,
            })
        end
        end -- if matchesSearch
    end

    if #sortedSets == 0 then
        dataList[#dataList+1] = ZO_ScrollList_CreateDataEntry(DATA_TYPE_ROW, {
            set      = "No set items equipped",
            dungeon  = "Equip gear with set bonuses to audit traits and quality",
            reason   = "",
            _noTrack = true,
        })
    end

    ZO_ScrollList_Commit(list)
    if ZO_ScrollList_ResetToTop then ZO_ScrollList_ResetToTop(list) end

    DungeonGearWindowStatus:SetText(
        string.format("Audit  -  %d pieces checked  -  %d issue(s) found",
                      checkedCount, issueCount))
    DungeonGear.Show()
end

-- ---------------------------------------------------------------------------
-- Tracking

function DungeonGear.OpenLink(url)
    if not url or url == "" then return end
    CHAT_SYSTEM:AddMessage("|cFFD700[DungeonGear]|r Build guide: " .. url)
    CHAT_SYSTEM:AddMessage("|c888888(copy the URL above and paste it in your browser)|r")
end

function DungeonGear.ShowBuildDetail(buildName)
    if not buildName then return end
    local text = DungeonGear_BuildText and DungeonGear_BuildText[buildName]
    if not text or text == "" then
        text = "No detail text found for build: " .. tostring(buildName)
            .. "\n\nAdd an entry to DungeonGearBuildText.lua to populate this view."
    end
    DungeonGearDetailWindowTitle:SetText(buildName)

    local label = DungeonGear._detailLabel
    if label then
        local scroll = DungeonGearDetailWindowScroll
        local scrollWidth = (scroll and scroll:GetWidth()) or 640
        local textWidth = scrollWidth - 40
        -- Set the label's width EXPLICITLY before SetText so GetTextHeight
        -- can compute a deterministic height without feeding back through
        -- the scroll child's dimensions (that was the anchor-cycle crash).
        label:SetDimensions(textWidth, 0)
        label:SetText(text)
        local scrollChild = scroll and scroll:GetNamedChild("ScrollChild")
        if scrollChild and label.GetTextHeight then
            local h = label:GetTextHeight() + 16
            if h < 100 then h = 100 end
            scrollChild:SetDimensions(textWidth + 8, h)
        end
        if scroll and ZO_Scroll_OnExtentsChanged then
            ZO_Scroll_OnExtentsChanged(scroll)
        end
    end

    DungeonGearDetailWindow:SetHidden(false)
    -- Raise above the main window so it isn't hidden behind it.
    if DungeonGearDetailWindow.BringWindowToTop then
        DungeonGearDetailWindow:BringWindowToTop()
    end
end

function DungeonGear.OnTrackClicked(btn)
    if btn.isDetailButton then
        DungeonGear.ShowBuildDetail(btn.detailBuildName)
        return
    end
    if btn.isLinkButton then
        DungeonGear.OpenLink(btn.linkUrl)
        return
    end
    local name = btn.setName
    if not name then return end
    local wasTracked = DungeonGear.IsTracked(name)
    if wasTracked then
        sv.tracked[name] = nil
        btn:SetText("Track")
        d("[DungeonGear] Untracked: " .. name)
    else
        sv.tracked[name] = true
        btn:SetText("Untrack")
        d("[DungeonGear] Now tracking: " .. name)
    end
    if DungeonGear._refreshInventoryHighlights then
        DungeonGear._refreshInventoryHighlights()
    end
    DungeonGear.RefreshMapPins()
end

-- Dungeon Finder: queue for a specific dungeon via the Activity Finder API.
function DungeonGear.OnQueueClicked(btn)
    -- Build assignment button (Feature 5).
    if btn.assignBuildName then
        local current = DungeonGear.GetAssignedBuild()
        if current == btn.assignBuildName then
            DungeonGear.UnassignBuild()
        else
            DungeonGear.AssignBuild(btn.assignBuildName)
        end
        refreshCurrent()
        return
    end

    local dungeonName = btn.dungeonName
    if not dungeonName then return end

    -- Strip suffixes like "(overland)", "(Trial)", "(vet)", "(Tel Var)" etc.
    local isVet = dungeonName:find("%(vet%)") ~= nil
    local isTrial = dungeonName:find("%(Trial%)") or dungeonName:find("Trial")
    local cleanName = dungeonName
        :gsub("%s*%(overland%)",""):gsub("%s*%(Trial%)","")
        :gsub("%s*%(vet%)",""):gsub("%s*%(Tel Var%)","")
        :gsub("^Crafted .*","")
    if cleanName == "" then
        d("[DungeonGear] This set is crafted or overland — no specific dungeon to queue for.")
        return
    end

    if isTrial then
        d(string.format("|cFFD700[DungeonGear]|r Trials cannot be auto-queued. Look for: |cFFFFFF%s|r",
              cleanName))
        return
    end

    -- Try to find the activity ID and queue directly.
    local activityId = findActivityId(cleanName, isVet)
    if not activityId then
        d(string.format("|cFFD700[DungeonGear]|r Could not find activity for: |cFFFFFF%s|r — opening Group Finder.",
              cleanName))
        if SCENE_MANAGER then SCENE_MANAGER:Show("groupMenuKeyboard") end
        return
    end

    if IsCurrentlySearchingForGroup and IsCurrentlySearchingForGroup() then
        d("[DungeonGear] Already queued — leave your current queue first.")
        return
    end

    if DoesPlayerMeetActivityLevelRequirements and not DoesPlayerMeetActivityLevelRequirements(activityId) then
        d("[DungeonGear] You don't meet the level requirements for this dungeon.")
        return
    end

    ClearActivityFinderSearch()
    AddActivityFinderSpecificSearchEntry(activityId)
    local result = StartActivityFinderSearch()
    if result == ACTIVITY_QUEUE_RESULT_SUCCESS then
        d(string.format("|cFFD700[DungeonGear]|r |c66FF66Queued for:|r %s", cleanName))
    else
        d(string.format("|cFFD700[DungeonGear]|r Queue failed (code %s) — opening Group Finder.",
              tostring(result)))
        if SCENE_MANAGER then SCENE_MANAGER:Show("groupMenuKeyboard") end
    end
end

function DungeonGear.ToggleMetaOnly()
    DungeonGear.metaOnly = not DungeonGear.metaOnly
    if sv then sv.metaOnly = DungeonGear.metaOnly end
    if DungeonGearWindowMetaToggle then
        DungeonGearWindowMetaToggle:SetText(
            DungeonGear.metaOnly and "Showing: Meta" or "Showing: All")
    end
    refreshCurrent()
end

function DungeonGear.OnSearchChanged(editBox)
    local text = (editBox and editBox.GetText and editBox:GetText()) or ""
    DungeonGear.searchText = string.lower(text)
    if sv then sv.searchText = DungeonGear.searchText end
    refreshCurrent()
end

function DungeonGear.ClearSearch()
    DungeonGear.searchText = ""
    if sv then sv.searchText = "" end
    if DungeonGearWindowSearchBox and DungeonGearWindowSearchBox.SetText then
        DungeonGearWindowSearchBox:SetText("")
    end
    refreshCurrent()
end

-- ---------------------------------------------------------------------------
-- Window position

function DungeonGear.OnWindowMoveStop()
    sv.windowX = DungeonGearWindow:GetLeft()
    sv.windowY = DungeonGearWindow:GetTop()
end

function DungeonGear.OnWindowResizeStop()
    sv.windowW = DungeonGearWindow:GetWidth()
    sv.windowH = DungeonGearWindow:GetHeight()
end

local function restoreWindowPos()
    if sv.windowW and sv.windowH then
        DungeonGearWindow:SetDimensions(sv.windowW, sv.windowH)
    end
    if sv.windowX and sv.windowY then
        DungeonGearWindow:ClearAnchors()
        DungeonGearWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.windowX, sv.windowY)
    end
end

-- ---------------------------------------------------------------------------
-- Loot notification hook

local function onLootReceived(_, receivedBy, itemLink, quantity, itemSound, lootType, lootedBySelf)
    if not lootedBySelf then return end
    if not itemLink or itemLink == "" then return end
    local hasSet, setName = GetItemLinkSetInfo(itemLink, false)
    if not hasSet or not setName then return end
    if DungeonGear.IsTracked(setName) then
        CHAT_SYSTEM:AddMessage(string.format(
            "|cFFD700[DungeonGear]|r |cFFFFFFTracked set drop:|r %s", setName))
        PlaySound(SOUNDS.QUEST_COMPLETED)

        -- Show which slot types are still missing for this set.
        local scanned = scanInventoryForSets()
        local owned = scanned[setName] or {}
        local validSlots = getValidSlotsForSet(setName)
        local missing = {}
        for _, slot in ipairs(validSlots) do
            if countSlotOwned(owned, slot) == 0 then
                missing[#missing + 1] = slot.name
            end
        end
        if #missing > 0 then
            CHAT_SYSTEM:AddMessage(string.format(
                "|cFFD700[DungeonGear]|r Still need: %s", table.concat(missing, ", ")))
        else
            CHAT_SYSTEM:AddMessage(
                "|cFFD700[DungeonGear]|r |c66FF66All slot types covered!|r")
        end
    end
end

-- ---------------------------------------------------------------------------
-- Passive set completion monitor (fires on inventory changes, not just loot)

local function onInventorySlotUpdate(_, bagId, slotIndex, isNewItem)
    if not isNewItem then return end
    if bagId ~= BAG_BACKPACK and bagId ~= BAG_WORN then return end
    local itemLink = GetItemLink(bagId, slotIndex)
    if not itemLink or itemLink == "" then return end
    local hasSet, setName = GetItemLinkSetInfo(itemLink, false)
    if not hasSet or not setName or not DungeonGear.IsTracked(setName) then return end

    -- Check if all slot types are now covered for this set.
    local scanned = scanInventoryForSets()
    local owned = scanned[setName] or {}
    local validSlots = getValidSlotsForSet(setName)
    if #validSlots == 0 then return end
    local covered = 0
    for _, slot in ipairs(validSlots) do
        if countSlotOwned(owned, slot) > 0 then covered = covered + 1 end
    end
    if covered >= #validSlots then
        CHAT_SYSTEM:AddMessage(string.format(
            "|cFFD700[DungeonGear]|r |c00FF00SET COMPLETE:|r %s — all %d slot types covered!",
            setName, #validSlots))
        PlaySound(SOUNDS.ACHIEVEMENT_AWARDED)
    end
end

-- ---------------------------------------------------------------------------
-- Sticker book update notification

local function onStickerBookUpdated(_, itemSetId)
    -- Invalidate cache so Collection view refreshes.
    stickerBookCache = nil
    -- Try to resolve the set name and notify if tracked.
    if nameToSetId then
        for name, id in pairs(nameToSetId) do
            if id == itemSetId and DungeonGear.IsTracked(name) then
                CHAT_SYSTEM:AddMessage(string.format(
                    "|cFFD700[DungeonGear]|r |cAA66FFSticker book updated:|r %s — new piece(s) unlocked!",
                    name))
                if DungeonGear.currentRole == "collection" then refreshCurrent() end
                return
            end
        end
    end
end

-- ---------------------------------------------------------------------------
-- Export / Import tracked sets

local function serializeTracked()
    local names = {}
    for name, v in pairs((sv and sv.tracked) or {}) do
        if v then names[#names + 1] = name end
    end
    table.sort(names)
    return table.concat(names, "|")
end

function DungeonGear.ShowExportDialog()
    local str = serializeTracked()
    DungeonGearExportWindowEditBox:SetText(str)
    DungeonGearExportWindow:SetHidden(false)
end

function DungeonGear.DoImport()
    local text = DungeonGearExportWindowEditBox:GetText() or ""
    -- Strip the optional "DG:" prefix from shared strings.
    text = text:gsub("^DG:", "")
    local count = 0
    for name in text:gmatch("[^|]+") do
        name = name:match("^%s*(.-)%s*$")  -- trim whitespace
        if name ~= "" then
            sv.tracked[name] = true
            count = count + 1
        end
    end
    d(string.format("[DungeonGear] Imported %d set(s)", count))
    DungeonGearExportWindow:SetHidden(true)
    refreshCurrent()
    if DungeonGear._refreshInventoryHighlights then
        DungeonGear._refreshInventoryHighlights()
    end
end

function DungeonGear.ShareToChat()
    local str = serializeTracked()
    if str == "" then
        d("[DungeonGear] Nothing to share - no tracked sets.")
        return
    end
    CHAT_SYSTEM:AddMessage("|cFFD700[DungeonGear Share]|r DG:" .. str)
    d("[DungeonGear] Tracked sets printed to chat. Others can /dg import the DG: string.")
end

-- ---------------------------------------------------------------------------
-- Slash command

local function onSlash(args)
    local role = (args or ""):lower():match("^(%S+)")
    if not role or role == "" then
        if DungeonGearWindow:IsHidden() then
            if DungeonGear.currentRole == "builds" then
                DungeonGear.ShowBuilds()
            elseif DungeonGear.currentRole == "collection" then
                DungeonGear.ShowCollection()
            elseif DungeonGear.currentRole == "farming" then
                DungeonGear.ShowFarming()
            elseif DungeonGear.currentRole == "advisor" then
                DungeonGear.ShowUpgradeAdvisor()
            elseif DungeonGear.currentRole == "audit" then
                DungeonGear.ShowAudit()
            elseif DungeonGear.currentRole then
                DungeonGear.ShowRole(DungeonGear.currentRole)
            else
                DungeonGear.ShowRole("tank")
            end
        else
            DungeonGear.Hide()
        end
        return
    end
    if role == "builds" then
        DungeonGear.ShowBuilds()
        return
    end
    if role == "collection" or role == "coll" then
        DungeonGear.ShowCollection()
        return
    end
    if role == "farming" or role == "farm" then
        DungeonGear.ShowFarming()
        return
    end
    if role == "export" then
        DungeonGear.ShowExportDialog()
        return
    end
    if role == "import" then
        -- Allow inline import: /dg import DG:set1|set2
        local payload = (args or ""):match("^%S+%s+(.+)$")
        if payload and payload ~= "" then
            DungeonGearExportWindowEditBox:SetText(payload)
            DungeonGear.DoImport()
        else
            DungeonGear.ShowExportDialog()
        end
        return
    end
    if role == "share" then
        DungeonGear.ShareToChat()
        return
    end
    if role == "advisor" then
        DungeonGear.ShowUpgradeAdvisor()
        return
    end
    if role == "audit" then
        DungeonGear.ShowAudit()
        return
    end
    if role == "assign" then
        local buildName = (args or ""):match("^%S+%s+(.+)$")
        if not buildName or buildName == "" then
            d("[DungeonGear] Usage: /dg assign Build Name")
            return
        end
        DungeonGear.AssignBuild(buildName)
        return
    end
    if role == "unassign" then
        DungeonGear.UnassignBuild()
        return
    end
    if role == "pin" then
        -- /dg pin Dungeon Name — saves current position as the pin location
        local dungeonName = (args or ""):match("^%S+%s+(.+)$")
        if not dungeonName or dungeonName == "" then
            d("[DungeonGear] Usage: /dg pin Dungeon Name")
            d("[DungeonGear] Stand at the dungeon entrance and run this to save the pin location.")
            return
        end
        local x, y = GetMapPlayerPosition("player")
        local zoneKey = LibMapPins and LibMapPins:GetZoneAndSubzone(true) or nil
        if not zoneKey then
            d("[DungeonGear] LibMapPins not loaded.")
            return
        end
        -- Save to per-server saved variables so it persists.
        sv.customPins = sv.customPins or {}
        sv.customPins[dungeonName] = { zone = zoneKey, x = x, y = y }
        d(string.format("[DungeonGear] Saved pin for '%s' at zone=%s x=%.4f y=%.4f",
            dungeonName, zoneKey, x, y))
        DungeonGear.RefreshMapPins()
        return
    end
    if not DungeonGear_Data[role] then
        d("[DungeonGear] Usage: /dg [tank|healer|dps|beginner|monster|overland|trial|builds|collection|farming|advisor|audit|assign|unassign|export|import|share|pin]")
        return
    end
    DungeonGear.ShowRole(role)
end

-- ---------------------------------------------------------------------------
-- Inventory row highlight: mark tracked-set items in the player's bags
-- with a gold star overlay. Hooks the ZO_ScrollList dataType setupCallback
-- so every row gets decorated as it scrolls into view.

local DG_MARKER_SUFFIX = "DGMark"

local function ensureTrackedMarker(rowControl)
    local existing = rowControl:GetNamedChild(DG_MARKER_SUFFIX)
    if existing then return existing end
    -- Full-row gold-tinted backdrop. Anchored to fill the whole inventory
    -- row and drawn at the lowest layer so the item icon / text stay on top.
    local marker = WINDOW_MANAGER:CreateControl(
        rowControl:GetName() .. DG_MARKER_SUFFIX, rowControl, CT_BACKDROP)
    marker:SetAnchor(TOPLEFT, rowControl, TOPLEFT, 0, 0)
    marker:SetAnchor(BOTTOMRIGHT, rowControl, BOTTOMRIGHT, 0, 0)
    marker:SetCenterColor(1.00, 0.82, 0.05, 0.22)
    marker:SetEdgeColor(1.00, 0.82, 0.05, 0.00)
    if marker.SetDrawLayer then marker:SetDrawLayer(0) end
    if marker.SetDrawTier  then marker:SetDrawTier(0)  end
    marker:SetHidden(true)
    return marker
end

local function decorateInventoryRow(rowControl, slot)
    if not rowControl or not slot then return end
    if STABLES_SCENE:IsShowing() then return end
    -- Slot data may have bagId/slotIndex directly or nested in .dataEntry.data
    local bagId = slot.bagId
    local slotIndex = slot.slotIndex
    if (not bagId or not slotIndex) and slot.dataEntry and slot.dataEntry.data then
        bagId = bagId or slot.dataEntry.data.bagId
        slotIndex = slotIndex or slot.dataEntry.data.slotIndex
    end
    if not bagId or not slotIndex then return end
    local marker = ensureTrackedMarker(rowControl)
    local itemLink = GetItemLink(bagId, slotIndex)
    if itemLink and itemLink ~= "" then
        local hasSet, setName = GetItemLinkSetInfo(itemLink, false)
        if hasSet and setName and DungeonGear.IsTracked(setName) then
            marker:SetHidden(false)
            return
        end
    end
    marker:SetHidden(true)
end

local function tryHookList(list)
    if not list or not list.dataTypes then return false end
    local hookedAny = false
    -- ESO inventory scroll lists register multiple data types (one per row
    -- category). Hook every data type that has a setupCallback so we cover
    -- whichever one binds the item rows.
    for _, dt in pairs(list.dataTypes) do
        if type(dt) == "table" and dt.setupCallback then
            SecurePostHook(dt, "setupCallback", decorateInventoryRow)
            hookedAny = true
        end
    end
    return hookedAny
end

local function installInventoryHooks()
    if DungeonGear._inventoryHooked then return true end
    local ok1 = tryHookList(ZO_PlayerInventoryBackpack)
    local ok2 = tryHookList(ZO_PlayerBankBackpack)
    local ok3 = false
    if ZO_HouseBankBackpack then
        ok3 = tryHookList(ZO_HouseBankBackpack)
    end
    if ok1 or ok2 or ok3 then
        DungeonGear._inventoryHooked = true
        return true
    end
    return false
end

-- Re-run the setup callback on every currently visible row of every hooked
-- inventory list. Called after track/untrack so existing rows update
-- immediately instead of waiting for a scroll / lock-unlock to rebind them.
local function refreshInventoryHighlights()
    if not ZO_ScrollList_RefreshVisible then return end
    local lists = {
        ZO_PlayerInventoryBackpack,
        ZO_PlayerBankBackpack,
        ZO_HouseBankBackpack,
    }
    for _, list in ipairs(lists) do
        if list and not list:IsHidden() then
            ZO_ScrollList_RefreshVisible(list)
        end
    end
end
DungeonGear._refreshInventoryHighlights = refreshInventoryHighlights

-- ---------------------------------------------------------------------------
-- Per-character build assignment

local dgCharId  -- set during onLoaded

function DungeonGear.GetAssignedBuild()
    if not sv or not sv.charBuilds or not dgCharId then return nil end
    return sv.charBuilds[dgCharId]
end

function DungeonGear.AssignBuild(buildName)
    if not buildName or buildName == "" then
        d("[DungeonGear] Usage: /dg assign Build Name")
        return
    end
    -- Validate build exists.
    local found = false
    for _, b in ipairs(DungeonGear_Builds or {}) do
        if b.name == buildName then found = true; break end
    end
    if not found then
        d("[DungeonGear] Build not found: " .. buildName)
        return
    end
    sv.charBuilds = sv.charBuilds or {}
    sv.charBuilds[dgCharId] = buildName
    d("|cFFD700[DungeonGear]|r |c66FF66Assigned build:|r " .. buildName)

    -- Auto-track the build's sets.
    for _, b in ipairs(DungeonGear_Builds) do
        if b.name == buildName then
            if b.body    then sv.tracked[b.body] = true end
            if b.jewelry then sv.tracked[b.jewelry] = true end
            if b.monster then sv.tracked[b.monster] = true end
            break
        end
    end
end

function DungeonGear.UnassignBuild()
    if not sv or not dgCharId then return end
    sv.charBuilds = sv.charBuilds or {}
    local old = sv.charBuilds[dgCharId]
    sv.charBuilds[dgCharId] = nil
    if old then
        d("|cFFD700[DungeonGear]|r Unassigned build: " .. old)
    else
        d("[DungeonGear] No build was assigned.")
    end
end

-- Apply assigned build's filters on login (without opening the window).
local function applyAssignedBuildOnLogin()
    local buildName = DungeonGear.GetAssignedBuild()
    if not buildName then return end
    for _, b in ipairs(DungeonGear_Builds or {}) do
        if b.name == buildName then
            -- Map damageType to display string.
            local dtMap = { stam = "Stamina", mag = "Magicka", hybrid = "Hybrid" }
            local dtDisplay = dtMap[b.damageType] or "Any"
            DungeonGear.currentClass = b.class or "Any"
            DungeonGear.currentDamageType = dtDisplay
            if sv then
                sv.currentClass = DungeonGear.currentClass
                sv.currentDamageType = DungeonGear.currentDamageType
            end
            selectComboByLabel(DungeonGearWindowClassFilter, DungeonGear.currentClass)
            selectComboByLabel(DungeonGearWindowDamageFilter, DungeonGear.currentDamageType)
            break
        end
    end
end

-- ---------------------------------------------------------------------------
-- Map pins: show tracked-set farm locations on zone maps (requires LibMapPins)
-- Pins appear when viewing the zone map that contains a tracked set's source.
-- Uses LMP:GetZoneAndSubzone() to match the current map, per LibMapPins pattern.

local DG_PIN_TYPE = "DungeonGearTrackedPin"

local function initMapPins()
    local LMP = LibMapPins
    if not LMP then return end

    local pinTooltipCreator = {
        creator = function(pin)
            local data = pin.m_PinTag
            if data then
                if IsInGamepadPreferredMode() then
                    local tip = ZO_MapLocationTooltip_Gamepad
                    local base = tip.tooltip
                    tip:LayoutIconStringLine(base, nil,
                        (data.dungeonName or "") .. " - " .. (data.setList or ""),
                        base:GetStyle("mapLocationTooltipContentName"))
                else
                    SetTooltipText(InformationTooltip, data.dungeonName or "")
                    InformationTooltip:AddLine(data.setList or "")
                end
            end
        end,
        tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
    }

    local pinLayout = {
        level   = 50,
        size    = 38,
        texture = "EsoUI/Art/MapPins/hostile_pin.dds",
        tint    = ZO_ColorDef:New(1, 0.82, 0.05, 1),
    }

    LMP:AddPinType(DG_PIN_TYPE, function()
        -- Only show pins on zone-level maps (not world/alliance/cosmic).
        if GetMapType() > MAPTYPE_ZONE then return end

        -- Merge hardcoded coords with user-saved custom pins.
        local mapCoords = DungeonGear_DungeonMapCoords or {}
        local custom = (sv and sv.customPins) or {}

        -- Get the current map zone key.
        local zone = LMP:GetZoneAndSubzone(true)
        if not zone or zone == "" then return end

        -- Lookup helper: check custom pins first (user overrides), then hardcoded.
        local function getCoords(dungeonName)
            local c = custom[dungeonName]
            if c and c.zone == zone then return c end
            c = mapCoords[dungeonName]
            if c and c.zone == zone then return c end
            return nil
        end

        local tracked = (sv and sv.tracked) or {}
        -- Aggregate tracked sets by dungeon, filtered to this zone.
        local dungeonSets = {}
        for setName, v in pairs(tracked) do
            if v then
                local row = findSetRow(setName)
                if row and row.dungeon then
                    if getCoords(row.dungeon) then
                        if not dungeonSets[row.dungeon] then
                            dungeonSets[row.dungeon] = {}
                        end
                        dungeonSets[row.dungeon][#dungeonSets[row.dungeon] + 1] = setName
                    end
                end
            end
        end

        for dungeon, sets in pairs(dungeonSets) do
            local c = getCoords(dungeon)
            LMP:CreatePin(DG_PIN_TYPE, {
                dungeonName = dungeon,
                setList     = table.concat(sets, ", "),
            }, c.x, c.y)
        end
    end, nil, pinLayout, pinTooltipCreator)
end

function DungeonGear.RefreshMapPins()
    if LibMapPins then
        LibMapPins:RefreshPins(DG_PIN_TYPE)
    end
end

-- ---------------------------------------------------------------------------
-- Init

local function onLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    ZO_CreateStringId("SI_BINDING_NAME_DUNGEONGEAR_TOGGLE", "Toggle DungeonGear")

    -- Raw global SavedVars init, namespaced per server so EU/NA/PTS
    -- don't overwrite each other.
    DungeonGearSavedVars = DungeonGearSavedVars or {}
    local server = GetWorldName()
    DungeonGearSavedVars[server] = DungeonGearSavedVars[server] or {}
    sv = DungeonGearSavedVars[server]

    -- Per-character tracked sets and build assignment (keyed by character ID).
    local charId = GetCurrentCharacterId()
    dgCharId = charId
    sv.charTracked = sv.charTracked or {}
    sv.charBuilds  = sv.charBuilds  or {}
    -- One-time migration: copy old account-wide tracked into this character's slot.
    if not sv.charTracked[charId] and sv.tracked then
        local copy = {}
        for k, v in pairs(sv.tracked) do copy[k] = v end
        sv.charTracked[charId] = copy
    end
    sv.charTracked[charId] = sv.charTracked[charId] or {}
    sv.tracked = sv.charTracked[charId]

    -- Restore persisted filter state, or use defaults for first run.
    DungeonGear.metaOnly    = (sv.metaOnly ~= nil) and sv.metaOnly or true
    DungeonGear.searchText  = sv.searchText or ""
    DungeonGear.currentRole = sv.currentRole or detectRole()
    DungeonGear.currentClass      = sv.currentClass or "Any"
    DungeonGear.currentDamageType = sv.currentDamageType or "Any"

    DungeonGear.InitScrollList()
    DungeonGear.InitClassCombo()
    DungeonGear.InitDamageCombo()
    DungeonGear.InitViewCombo()
    DungeonGear.InitDetailWindow()
    restoreWindowPos()

    -- Restore combo selections and UI to match persisted state (without
    -- firing callbacks that would open the window).
    if DungeonGear.currentClass ~= "Any" then
        selectComboByLabel(DungeonGearWindowClassFilter, DungeonGear.currentClass)
    end
    if DungeonGear.currentDamageType ~= "Any" then
        selectComboByLabel(DungeonGearWindowDamageFilter, DungeonGear.currentDamageType)
    end
    if DungeonGear.currentRole then
        -- Only update the display text — do NOT call SelectItem which would
        -- fire the callback and open the window on login.
        local viewCombo = ZO_ComboBox_ObjectFromContainer(DungeonGearWindowViewCombo)
        for _, entry in ipairs(viewCombo.m_sortedItems or {}) do
            if entry.name and entry.name:lower() == DungeonGear.currentRole then
                if viewCombo.SetSelectedItemText then
                    viewCombo:SetSelectedItemText(entry.name)
                end
                break
            end
        end
    end
    if DungeonGear.searchText ~= "" and DungeonGearWindowSearchBox then
        DungeonGearWindowSearchBox:SetText(DungeonGear.searchText)
    end
    if not DungeonGear.metaOnly and DungeonGearWindowMetaToggle then
        DungeonGearWindowMetaToggle:SetText("Showing: All")
    end

    SLASH_COMMANDS["/dungeongear"] = onSlash
    SLASH_COMMANDS["/dg"] = onSlash

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LOOT_RECEIVED, onLootReceived)

    -- Passive set completion alerts (Feature 3).
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_InvMon", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onInventorySlotUpdate)
    if REGISTER_FILTER_IS_NEW_ITEM then
        EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "_InvMon", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
            REGISTER_FILTER_IS_NEW_ITEM, true)
    end

    -- Sticker book update notification (Feature 4).
    if EVENT_ITEM_SET_COLLECTION_UPDATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Sticker", EVENT_ITEM_SET_COLLECTION_UPDATED, onStickerBookUpdated)
    end

    -- Inventory highlight hooks. If not ready yet, retry on player activation.
    if not installInventoryHooks() then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_InvHook", EVENT_PLAYER_ACTIVATED, function()
            if installInventoryHooks() then
                EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_InvHook", EVENT_PLAYER_ACTIVATED)
            end
        end)
    end

    -- Map pins (requires LibMapPins).
    initMapPins()

    -- Apply assigned build filters on login (Feature 5).
    applyAssignedBuildOnLogin()

    initComplete = true
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, onLoaded)
