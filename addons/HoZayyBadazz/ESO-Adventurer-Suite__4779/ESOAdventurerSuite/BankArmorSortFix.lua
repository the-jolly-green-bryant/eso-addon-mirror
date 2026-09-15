-- ESO Adventurer Suite
-- v0.29.652 - Bank gear set-name sorting.
-- Set-bearing gear is grouped alphabetically by set name before its secondary
-- equipment ordering. Armor keeps Head -> Shoulders -> Chest -> Hands -> Waist
-- -> Legs -> Feet inside each set. Non-set gear follows named sets.

local EPC = ESOProgressionCoach
if not EPC then return end
local U = EPC.BankGridUnifiedV2
if not U or type(U.Collect) ~= "function" or U._easArmorSort029652 then return end
U._easArmorSort029652 = true

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function setNameForLink(link)
    if link == "" or type(GetItemLinkSetInfo) ~= "function" then return "", false end
    local ok, hasSet, setName = pcall(GetItemLinkSetInfo, link, false)
    if not ok or hasSet ~= true then return "", false end
    setName = tostring(setName or "")
    if setName == "" then return "", false end
    return setName, true
end

local ARMOR_SLOT_ORDER = {}
local function put(name, order)
    local value = rawget(_G, name)
    if value ~= nil then ARMOR_SLOT_ORDER[value] = order end
end
put("EQUIP_TYPE_HEAD", 10)
put("EQUIP_TYPE_SHOULDERS", 20)
put("EQUIP_TYPE_CHEST", 30)
put("EQUIP_TYPE_HAND", 40)
put("EQUIP_TYPE_WAIST", 50)
put("EQUIP_TYPE_LEGS", 60)
put("EQUIP_TYPE_FEET", 70)

local GEAR_GROUPS = { WEAPONS=true, ARMOR=true, JEWELRY=true }

local baseCollect = U.Collect
function U:Collect(mode, ...)
    local items = baseCollect(self, mode, ...)
    if type(items) ~= "table" or #items < 1 then return items end

    for _, item in ipairs(items) do
        item._easArmorSlotOrder029652 = nil
        item._easSetName029652 = ""
        item._easSetDisplayName029652 = ""
        item._easHasSet029652 = false

        if item and GEAR_GROUPS[item.group] then
            local link = ""
            if type(GetItemLink) == "function" and item.bag ~= nil and item.slot ~= nil then
                link = tostring(first(GetItemLink, "", item.bag, item.slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
            end

            local setName, hasSet = setNameForLink(link)
            item._easSetDisplayName029652 = setName
            item._easSetName029652 = string.lower(setName)
            item._easHasSet029652 = hasSet

            if item.group == "ARMOR" then
                local equipType = 0
                if link ~= "" and type(GetItemLinkEquipType) == "function" then
                    equipType = tonumber(first(GetItemLinkEquipType, 0, link)) or 0
                end
                item._easArmorSlotOrder029652 = ARMOR_SLOT_ORDER[equipType] or 999
            end
        end
    end

    table.sort(items, function(a, b)
        local ao, bo = tonumber(a and a.order) or 90, tonumber(b and b.order) or 90
        if ao ~= bo then return ao < bo end

        local sameGearGroup = a and b and a.group == b.group and GEAR_GROUPS[a.group] == true
        if sameGearGroup then
            local ah, bh = a._easHasSet029652 == true, b._easHasSet029652 == true
            if ah ~= bh then return ah end

            if ah and bh then
                local aset = tostring(a._easSetName029652 or "")
                local bset = tostring(b._easSetName029652 or "")
                if aset ~= bset then return aset < bset end
            end

            if a.group == "ARMOR" then
                local as = tonumber(a._easArmorSlotOrder029652) or 999
                local bs = tonumber(b._easArmorSlotOrder029652) or 999
                if as ~= bs then return as < bs end
            end
        end

        local aq, bq = tonumber(a and a.quality) or 0, tonumber(b and b.quality) or 0
        if aq ~= bq then return aq > bq end

        return string.lower(tostring(a and a.name or "")) < string.lower(tostring(b and b.name or ""))
    end)

    return items
end
