local Addon = LarvalTearMod
local M = Addon.Modules.GearLinkSummary

local MAX_LINKS = 4
local EQUIPMENT_SLOT_IDS = Addon.Common.Domains.EquipmentSlotIds

local function IsValidItemLink(link)
    return type(link) == "string" and link ~= ""
end

local function SafeGetItemLinkSetInfo(link)
    if type(GetItemLinkSetInfo) ~= "function" or not IsValidItemLink(link) then
        return nil, nil, nil, nil, nil, nil, nil
    end

    local ok, hasSetBonus, setName, numBonuses, numEquipped, maxEquipped, setId, setCollectionId =
        pcall(GetItemLinkSetInfo, link, false)
    if ok then
        return hasSetBonus, setName, numBonuses, numEquipped, maxEquipped, setId, setCollectionId
    end

    return nil, nil, nil, nil, nil, nil, nil
end

local function SafeGetItemLinkDisplayQuality(link)
    if type(GetItemLinkDisplayQuality) ~= "function" or not IsValidItemLink(link) then
        return nil
    end

    local ok, displayQuality = pcall(GetItemLinkDisplayQuality, link)
    return ok and displayQuality or nil
end

local function SafeGetItemLinkEquipType(link)
    if type(GetItemLinkEquipType) ~= "function" or not IsValidItemLink(link) then
        return nil
    end

    local ok, equipType = pcall(GetItemLinkEquipType, link)
    return ok and equipType or nil
end

local function GetNumberConstant(name)
    local value = rawget(_G, name)
    return type(value) == "number" and value or nil
end

local function IsEquipTypeOneOf(equipType, names)
    if type(equipType) ~= "number" then
        return false
    end

    for _, name in ipairs(names or {}) do
        local value = GetNumberConstant(name)
        if value ~= nil and equipType == value then
            return true
        end
    end

    return false
end

local function IsMythicLink(link)
    return SafeGetItemLinkDisplayQuality(link) == 6
end

local function IsMonsterCandidate(info)
    return type(info) == "table"
        and info.hasSetBonus == true
        and info.maxEquipped == 2
        and IsEquipTypeOneOf(info.equipType, {
            "EQUIP_TYPE_HEAD",
            "EQUIP_TYPE_SHOULDERS",
        })
end

local function IsMajorSetCandidate(info)
    return type(info) == "table"
        and info.hasSetBonus == true
        and type(info.setId) == "number"
        and info.setId > 0
        and type(info.maxEquipped) == "number"
        and info.maxEquipped >= 3
end

local function BuildLinkInfo(slotId, entry, slotOrder)
    local link = type(entry) == "table" and entry.itemLink or nil
    if not IsValidItemLink(link) then
        return nil
    end

    local hasSetBonus, setName, numBonuses, numEquipped, maxEquipped, setId, setCollectionId =
        SafeGetItemLinkSetInfo(link)

    return {
        slotId = slotId,
        slotOrder = slotOrder,
        itemLink = link,
        equipType = SafeGetItemLinkEquipType(link),
        hasSetBonus = hasSetBonus,
        setName = setName,
        numBonuses = numBonuses,
        numEquipped = numEquipped,
        maxEquipped = maxEquipped,
        setId = setId,
        setCollectionId = setCollectionId,
    }
end

local function AppendLink(result, link)
    if #result >= MAX_LINKS or not IsValidItemLink(link) then
        return
    end

    result[#result + 1] = link
end

local function SortMajorGroups(left, right)
    if left.pieceCount ~= right.pieceCount then
        return left.pieceCount > right.pieceCount
    end

    return left.firstSlotOrder < right.firstSlotOrder
end

local function CollectInfos(equipment)
    local infos = {}
    if type(equipment) ~= "table" then
        return infos
    end

    for slotOrder, slotId in ipairs(EQUIPMENT_SLOT_IDS) do
        local info = BuildLinkInfo(slotId, equipment[slotId], slotOrder)
        if info ~= nil then
            infos[#infos + 1] = info
        end
    end

    return infos
end

local function FindMythicLink(infos)
    for _, info in ipairs(infos or {}) do
        if IsMythicLink(info.itemLink) then
            return info.itemLink
        end
    end

    return nil
end

local function FindMonsterLink(infos)
    for _, info in ipairs(infos or {}) do
        if IsMonsterCandidate(info) then
            return info.itemLink
        end
    end

    return nil
end

local function CollectMajorSetLinks(infos)
    local groupsBySetId = {}
    local groups = {}

    for _, info in ipairs(infos or {}) do
        if IsMajorSetCandidate(info) then
            local group = groupsBySetId[info.setId]
            if group == nil then
                group = {
                    setId = info.setId,
                    firstSlotOrder = info.slotOrder,
                    representativeLink = info.itemLink,
                    pieceCount = 0,
                }
                groupsBySetId[info.setId] = group
                groups[#groups + 1] = group
            end

            group.pieceCount = group.pieceCount + 1
        end
    end

    table.sort(groups, SortMajorGroups)

    local links = {}
    for index = 1, math.min(2, #groups) do
        links[#links + 1] = groups[index].representativeLink
    end

    return links
end

function M:Extract(equipment)
    local result = {}
    local infos = CollectInfos(equipment)

    AppendLink(result, FindMythicLink(infos))
    AppendLink(result, FindMonsterLink(infos))

    local majorLinks = CollectMajorSetLinks(infos)
    for _, link in ipairs(majorLinks) do
        AppendLink(result, link)
    end

    return result
end

function M:BuildChatText(equipment, prefix)
    local links = self:Extract(equipment)
    if #links == 0 then
        return nil
    end

    local parts = {
        type(prefix) == "string" and prefix ~= "" and prefix or "[LTM Gear]",
    }
    for index = 1, math.min(MAX_LINKS, #links) do
        parts[#parts + 1] = "[ " .. links[index] .. " ]"
    end

    return table.concat(parts, " ")
end
