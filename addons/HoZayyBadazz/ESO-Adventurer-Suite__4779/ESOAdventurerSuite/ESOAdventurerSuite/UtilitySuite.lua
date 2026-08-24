-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.UtilitySuite = EPC.UtilitySuite or {}
local U = EPC.UtilitySuite

U.validModes = { OVERVIEW=true, INVENTORY=true, RESEARCH=true, COLLECTIONS=true, DAILIES=true, RETICLE=true }
U.modeLabels = { OVERVIEW="OVERVIEW", INVENTORY="INVENTORY", RESEARCH="RESEARCH", COLLECTIONS="COLLECTIONS", DAILIES="DAILIES", RETICLE="RETICLE" }
U.setIdCache = U.setIdCache or {}
U.lastInventoryScanMs = 0
U.inventoryCache = nil
U.loreCache = nil
U.loreCacheAt = 0
-- v0.6.3 performance caches. Tool buttons should switch views immediately; expensive
-- inventory/research/collection scans are refreshed separately and reused.
U.viewCache = U.viewCache or {}
U.viewCacheAt = U.viewCacheAt or {}
U.researchCache = nil
U.researchCacheAt = 0
U.zoneCache = nil
U.zoneCacheAt = 0
U.dailyCache = nil
U.dailyCacheAt = 0
U.pendingModeRefresh = U.pendingModeRefresh or {}
U.inventoryCacheTtlMs = 30000
U.researchCacheTtlMs = 30000
U.zoneCacheTtlMs = 8000
U.dailyCacheTtlMs = 15000
U.viewCacheTtlMs = 8000

local function num(v, d)
    v = tonumber(v)
    if v == nil then return d or 0 end
    return v
end

local function trim(s)
    s = tostring(s or "")
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    return s
end

local function lower(s)
    return string.lower(trim(s))
end

local function nowMs()
    if type(GetGameTimeMilliseconds) == "function" then
        local ok, value = pcall(GetGameTimeMilliseconds)
        if ok then return num(value, 0) end
    end
    return 0
end

local function nowSeconds()
    if type(GetTimeStamp) == "function" then
        local ok, value = pcall(GetTimeStamp)
        if ok then return num(value, 0) end
    end
    return 0
end

local function formatNumber(value)
    local n = math.floor(num(value, 0) + 0.5)
    local s = tostring(math.abs(n))
    local out = s
    while true do
        local changed
        out, changed = string.gsub(out, "^(%d+)(%d%d%d)", "%1,%2")
        if changed == 0 then break end
    end
    if n < 0 then out = "-" .. out end
    return out
end

local function formatDuration(seconds)
    seconds = math.max(0, math.floor(num(seconds, 0)))
    if seconds <= 0 then return "Ready" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if days > 0 then return string.format("%dd %dh", days, hours) end
    if hours > 0 then return string.format("%dh %dm", hours, minutes) end
    return string.format("%dm", math.max(1, minutes))
end

local function safeStringId(prefix, value, fallback)
    if type(GetString) ~= "function" or value == nil then return fallback or tostring(value or "") end
    local ok, text = pcall(GetString, prefix, value)
    if ok and text and text ~= "" then return text end
    return fallback or tostring(value)
end

function U:Initialize()
    if not EPC.saved then return end
    local mode = string.upper(tostring(EPC.saved.utilityMode or "OVERVIEW"))
    if not self.validModes[mode] then mode = "OVERVIEW" end
    EPC.saved.utilityMode = mode
    EPC.saved.inventoryCharacters = EPC.saved.inventoryCharacters or {}
    EPC.saved.sharedInventory = EPC.saved.sharedInventory or { items={} }
    EPC.saved.utilityLootAlerts = EPC.saved.utilityLootAlerts ~= false
    EPC.saved.utilityInventoryTracking = EPC.saved.utilityInventoryTracking ~= false
end

function U:GetMode()
    local mode = EPC.saved and string.upper(tostring(EPC.saved.utilityMode or "OVERVIEW")) or "OVERVIEW"
    if not self.validModes[mode] then mode = "OVERVIEW" end
    return mode
end

function U:GetCachedModeView(mode)
    mode = string.upper(tostring(mode or self:GetMode()))
    local view = self.viewCache and self.viewCache[mode] or nil
    if not view then return nil, false end
    local at = self.viewCacheAt and num(self.viewCacheAt[mode], 0) or 0
    local now = nowMs()
    local fresh = at > 0 and now > 0 and (now - at) < self.viewCacheTtlMs
    return view, fresh
end

function U:PresentModeView(view)
    if not view or not EPC.saved or EPC.saved.activeTab ~= "TOOLS" or not EPC.UI then return end
    -- Re-render the existing model instead of rebuilding Engine/Advisor/Activities.
    -- This updates title/stats/cards instantly without the expensive global refresh path.
    if EPC.lastModel and EPC.lastModel.snapshot and type(EPC.UI.Render) == "function" then
        EPC.lastModel.tools = view
        EPC.UI:Render(EPC.lastModel)
    elseif type(EPC.UI.RenderTools) == "function" then
        EPC.UI:RenderTools(view)
    end
end

function U:LoadingView(mode)
    mode = string.upper(tostring(mode or self:GetMode()))
    return {
        mode=mode, modeLabel=self.modeLabels[mode] or mode,
        header="UTILITY COMMAND CENTER", title="Refreshing " .. string.lower(self.modeLabels[mode] or mode) .. "...",
        description="Showing this view immediately while the latest utility snapshot is prepared.",
        stats={{label="STATUS",value="REFRESHING"}}, rows={"Cached utility data is being refreshed."},
        hint="Tab switching no longer waits for a full character/build recalculation.",
    }
end

function U:ScheduleModeRefresh(mode, delayMs)
    mode = string.upper(tostring(mode or self:GetMode()))
    if not self.validModes[mode] or self.pendingModeRefresh[mode] then return end
    self.pendingModeRefresh[mode] = true
    local function run()
        self.pendingModeRefresh[mode] = nil
        local snapshot = EPC.lastSnapshot or (EPC.lastModel and EPC.lastModel.snapshot) or {}
        local ok, view = pcall(self.BuildModeView, self, mode, snapshot, true)
        if ok and view then
            if EPC.saved and EPC.saved.activeTab == "TOOLS" and self:GetMode() == mode then
                self:PresentModeView(view)
            end
        elseif not ok and EPC.Compatibility then
            EPC.Compatibility:DisableModule("UTILITY_SUITE", view)
        end
    end
    delayMs = math.max(0, num(delayMs, 1))
    if type(zo_callLater) == "function" then
        zo_callLater(run, delayMs)
    else
        run()
    end
end

function U:SetMode(mode)
    if not EPC.saved then return false end
    mode = string.upper(trim(mode))
    if mode == "CRAFTING" then mode = "RESEARCH" end
    if mode == "COLLECTION" then mode = "COLLECTIONS" end
    if mode == "DAILY" then mode = "DAILIES" end
    if not self.validModes[mode] then return false end
    EPC.saved.utilityMode = mode

    local cached, fresh = self:GetCachedModeView(mode)
    if cached then
        self:PresentModeView(cached)
    elseif EPC.saved.activeTab == "TOOLS" then
        self:PresentModeView(self:LoadingView(mode))
    end

    -- Only rebuild this utility mode. Do not force the full Engine snapshot/evaluation
    -- just because a sub-tab changed.
    if not fresh then self:ScheduleModeRefresh(mode, 1) end
    return true
end

function U:Invalidate(kind)
    kind = string.upper(tostring(kind or "ALL"))
    if kind == "ALL" or kind == "INVENTORY" then
        self.inventoryCache = nil
        self.lastInventoryScanMs = 0
        self.viewCache.INVENTORY = nil
        self.viewCache.RESEARCH = nil
        self.viewCache.OVERVIEW = nil
    end
    if kind == "ALL" or kind == "RESEARCH" then
        self.researchCache = nil
        self.researchCacheAt = 0
        self.viewCache.RESEARCH = nil
        self.viewCache.OVERVIEW = nil
    end
    if kind == "ALL" or kind == "ZONE" or kind == "COLLECTIONS" then
        self.zoneCache = nil
        self.zoneCacheAt = 0
        self.viewCache.COLLECTIONS = nil
        self.viewCache.OVERVIEW = nil
    end
    if kind == "ALL" or kind == "DAILIES" then
        self.dailyCache = nil
        self.dailyCacheAt = 0
        self.viewCache.DAILIES = nil
    end
end

local function bagCapacity(bagId)
    if bagId == nil or type(GetBagSize) ~= "function" then return 0, 0 end
    local size = EPC:Safe(GetBagSize, 0, bagId)
    local used = type(GetNumBagUsedSlots) == "function" and EPC:Safe(GetNumBagUsedSlots, 0, bagId) or 0
    return num(size, 0), num(used, 0)
end

function U:ScanBag(bagId, out, saveItems)
    if bagId == nil or type(GetBagSize) ~= "function" or type(GetItemLink) ~= "function" then return end
    local size = num(EPC:Safe(GetBagSize, 0, bagId), 0)
    if size <= 0 then return end

    for slotIndex = 0, size - 1 do
        local link = EPC:Safe(GetItemLink, "", bagId, slotIndex, LINK_STYLE_BRACKETS or 1)
        if link and link ~= "" then
            local stack = 1
            if type(GetSlotStackSize) == "function" then
                stack = num(EPC:Safe(GetSlotStackSize, 1, bagId, slotIndex), 1)
            end
            local name = trim(EPC:Safe(GetItemLinkName, "", link))
            if name == "" and type(GetItemName) == "function" then name = trim(EPC:Safe(GetItemName, "", bagId, slotIndex)) end
            if name == "" then name = "Unknown item" end

            out.stacks = out.stacks + 1
            out.itemCount = out.itemCount + stack
            if saveItems then
                local key = lower(name)
                out.items[key] = out.items[key] or { name=name, count=0 }
                out.items[key].count = out.items[key].count + stack
            end

            local sell = 0
            if type(GetItemSellValueWithBonuses) == "function" then sell = num(EPC:Safe(GetItemSellValueWithBonuses, 0, bagId, slotIndex), 0)
            elseif type(GetItemLinkValue) == "function" then sell = num(EPC:Safe(GetItemLinkValue, 0, link, true), 0) end
            out.vendorValue = out.vendorValue + (sell * stack)

            if type(CanItemLinkBeTraitResearched) == "function" and EPC:Safe(CanItemLinkBeTraitResearched, false, link) == true then
                out.researchCandidates = out.researchCandidates + 1
                if #out.researchItems < 8 then out.researchItems[#out.researchItems + 1] = name end
            end

            if type(GetItemLinkSetInfo) == "function" then
                local hasSet, setName = EPC:Safe(GetItemLinkSetInfo, false, link, false)
                if hasSet and setName and setName ~= "" then
                    out.setItems = out.setItems + 1
                    local targetVerdict = EPC.TargetBuild and EPC.TargetBuild:EvaluateItemLink(link) or nil
                    if targetVerdict then
                        out.targetItems = out.targetItems + stack
                        if #out.targetItemNames < 8 then out.targetItemNames[#out.targetItemNames + 1] = name end
                    end
                end
            end
        end
    end
end

function U:ScanVirtualBag(out)
    if BAG_VIRTUAL == nil or type(GetNextVirtualBagSlotId) ~= "function" or type(GetItemLink) ~= "function" then return end
    local slotIndex = nil
    local safety = 0
    while safety < 5000 do
        slotIndex = EPC:Safe(GetNextVirtualBagSlotId, nil, slotIndex)
        if slotIndex == nil then break end
        safety = safety + 1
        local link = EPC:Safe(GetItemLink, "", BAG_VIRTUAL, slotIndex, LINK_STYLE_BRACKETS or 1)
        if link and link ~= "" then
            out.craftBagStacks = out.craftBagStacks + 1
            local stack = type(GetSlotStackSize) == "function" and num(EPC:Safe(GetSlotStackSize, 1, BAG_VIRTUAL, slotIndex), 1) or 1
            out.craftBagItems = out.craftBagItems + stack
        end
    end
end

function U:PersistInventory(scan)
    if not EPC.saved or EPC.saved.utilityInventoryTracking == false then return end
    local charId = type(GetCurrentCharacterId) == "function" and EPC:Safe(GetCurrentCharacterId, "") or ""
    if not charId or charId == "" then charId = trim(EPC:Safe(GetUnitName, "Player", "player")) end
    EPC.saved.inventoryCharacters = EPC.saved.inventoryCharacters or {}
    EPC.saved.inventoryCharacters[charId] = {
        name = trim(EPC:Safe(GetUnitName, "Player", "player")),
        updated = nowSeconds(),
        items = scan.characterItems or {},
    }
    EPC.saved.sharedInventory = {
        updated = nowSeconds(),
        items = scan.sharedItems or {},
    }
end

function U:ScanInventory(force)
    local now = nowMs()
    if not force and self.inventoryCache and now > 0 and now - self.lastInventoryScanMs < self.inventoryCacheTtlMs then return self.inventoryCache end

    local backpackSize, backpackUsed = bagCapacity(BAG_BACKPACK)
    local bankSize, bankUsed = bagCapacity(BAG_BANK)
    local subBankSize, subBankUsed = bagCapacity(BAG_SUBSCRIBER_BANK)
    local scan = {
        backpackSize=backpackSize, backpackUsed=backpackUsed, backpackFree=math.max(0, backpackSize-backpackUsed),
        bankSize=bankSize+subBankSize, bankUsed=bankUsed+subBankUsed, bankFree=math.max(0, bankSize+subBankSize-bankUsed-subBankUsed),
        stacks=0, itemCount=0, vendorValue=0, researchCandidates=0, researchItems={}, setItems=0,
        targetItems=0, targetItemNames={}, craftBagStacks=0, craftBagItems=0, characterItems={}, sharedItems={},
    }

    local current = { stacks=0,itemCount=0,vendorValue=0,researchCandidates=0,researchItems={},setItems=0,targetItems=0,targetItemNames={},items={} }
    self:ScanBag(BAG_BACKPACK, current, true)
    self:ScanBag(BAG_WORN, current, true)
    scan.stacks = scan.stacks + current.stacks
    scan.itemCount = scan.itemCount + current.itemCount
    scan.vendorValue = scan.vendorValue + current.vendorValue
    scan.researchCandidates = scan.researchCandidates + current.researchCandidates
    scan.researchItems = current.researchItems
    scan.setItems = scan.setItems + current.setItems
    scan.targetItems = scan.targetItems + current.targetItems
    scan.targetItemNames = current.targetItemNames
    scan.characterItems = current.items

    local shared = { stacks=0,itemCount=0,vendorValue=0,researchCandidates=0,researchItems={},setItems=0,targetItems=0,targetItemNames={},items={} }
    self:ScanBag(BAG_BANK, shared, true)
    self:ScanBag(BAG_SUBSCRIBER_BANK, shared, true)
    scan.stacks = scan.stacks + shared.stacks
    scan.itemCount = scan.itemCount + shared.itemCount
    scan.vendorValue = scan.vendorValue + shared.vendorValue
    scan.setItems = scan.setItems + shared.setItems
    scan.targetItems = scan.targetItems + shared.targetItems
    scan.sharedItems = shared.items

    -- Enumerating the virtual craft bag can mean thousands of API calls and was the
    -- biggest source of TOOLS-tab stalls. None of the current cards needs a full
    -- craft-bag item count, so keep that deep scan out of normal UI refreshes.
    self:PersistInventory(scan)
    self.inventoryCache = scan
    self.lastInventoryScanMs = now
    return scan
end

function U:FindItem(query)
    query = lower(query)
    if query == "" or not EPC.saved then return {} end
    self:ScanInventory(true)
    local results = {}
    local function addSource(label, items)
        for key, entry in pairs(items or {}) do
            if string.find(key, query, 1, true) then
                results[#results + 1] = { location=label, name=entry.name or key, count=num(entry.count,0) }
            end
        end
    end
    for _, data in pairs(EPC.saved.inventoryCharacters or {}) do
        addSource(data.name or "Character", data.items)
    end
    addSource("Bank", EPC.saved.sharedInventory and EPC.saved.sharedInventory.items)
    table.sort(results, function(a,b)
        if a.name == b.name then return a.location < b.location end
        return a.name < b.name
    end)
    return results
end

local CRAFTS = {}
local function addCraft(constantValue, label)
    if constantValue ~= nil then CRAFTS[#CRAFTS + 1] = { id=constantValue, label=label } end
end
addCraft(CRAFTING_TYPE_BLACKSMITHING, "Blacksmithing")
addCraft(CRAFTING_TYPE_CLOTHIER, "Clothier")
addCraft(CRAFTING_TYPE_WOODWORKING, "Woodworking")
addCraft(CRAFTING_TYPE_JEWELRYCRAFTING, "Jewelry")

function U:BuildResearchSummary(force)
    local now = nowMs()
    if not force and self.researchCache and now > 0 and self.researchCacheAt > 0 and (now - self.researchCacheAt) < self.researchCacheTtlMs then
        return self.researchCache
    end
    local summary = { known=0,total=0,active=0,maxActive=0,nextRemaining=nil,nextName=nil,crafts={} }
    if type(GetNumSmithingResearchLines) ~= "function" or type(GetSmithingResearchLineInfo) ~= "function" or type(GetSmithingResearchLineTraitInfo) ~= "function" then
        summary.unavailable = true
        self.researchCache = summary
        self.researchCacheAt = now
        return summary
    end

    for i=1,#CRAFTS do
        local craft = CRAFTS[i]
        local data = { label=craft.label, known=0,total=0,active=0,maxActive=0,nextRemaining=nil,nextName=nil }
        data.maxActive = type(GetMaxSimultaneousSmithingResearch) == "function" and num(EPC:Safe(GetMaxSimultaneousSmithingResearch,0,craft.id),0) or 0
        summary.maxActive = summary.maxActive + data.maxActive
        local lineCount = num(EPC:Safe(GetNumSmithingResearchLines,0,craft.id),0)
        for lineIndex=1,lineCount do
            local lineName, _, traitCount = EPC:Safe(GetSmithingResearchLineInfo,"",craft.id,lineIndex)
            traitCount = num(traitCount,0)
            for traitIndex=1,traitCount do
                local _, _, known = EPC:Safe(GetSmithingResearchLineTraitInfo,nil,craft.id,lineIndex,traitIndex)
                data.total = data.total + 1
                summary.total = summary.total + 1
                if known == true then
                    data.known = data.known + 1
                    summary.known = summary.known + 1
                elseif type(GetSmithingResearchLineTraitTimes) == "function" then
                    local _, remaining = EPC:Safe(GetSmithingResearchLineTraitTimes,nil,craft.id,lineIndex,traitIndex)
                    remaining = num(remaining,0)
                    if remaining > 0 then
                        data.active = data.active + 1
                        summary.active = summary.active + 1
                        if not data.nextRemaining or remaining < data.nextRemaining then
                            data.nextRemaining = remaining
                            data.nextName = lineName ~= "" and lineName or craft.label
                        end
                        if not summary.nextRemaining or remaining < summary.nextRemaining then
                            summary.nextRemaining = remaining
                            summary.nextName = (lineName and lineName ~= "" and lineName or craft.label) .. " / " .. craft.label
                        end
                    end
                end
            end
        end
        summary.crafts[#summary.crafts+1] = data
    end
    self.researchCache = summary
    self.researchCacheAt = now
    return summary
end

function U:FindSetIdByName(name)
    name = trim(name)
    if name == "" then return nil end
    local key = lower(name)
    if self.setIdCache[key] ~= nil then return self.setIdCache[key] ~= 0 and self.setIdCache[key] or nil end
    if type(GetNextItemSetCollectionId) ~= "function" or type(GetItemSetName) ~= "function" then return nil end
    local last = nil
    local safety = 0
    while safety < 10000 do
        local setId = EPC:Safe(GetNextItemSetCollectionId, nil, last)
        if setId == nil then break end
        safety = safety + 1
        last = setId
        local setName = trim(EPC:Safe(GetItemSetName, "", setId))
        if lower(setName) == key then
            self.setIdCache[key] = setId
            return setId
        end
    end
    self.setIdCache[key] = 0
    return nil
end

function U:GetSetCollectionProgress(name)
    local setId = self:FindSetIdByName(name)
    if not setId then return nil end
    local total = type(GetNumItemSetCollectionPieces) == "function" and num(EPC:Safe(GetNumItemSetCollectionPieces,0,setId),0) or 0
    local unlocked = type(GetNumItemSetCollectionSlotsUnlocked) == "function" and num(EPC:Safe(GetNumItemSetCollectionSlotsUnlocked,0,setId),0) or 0
    return { name=name, setId=setId, unlocked=unlocked, total=total }
end

function U:SearchSets(query, limit)
    query = lower(query)
    limit = math.max(1, math.min(20, num(limit, 10)))
    if query == "" or type(GetNextItemSetCollectionId) ~= "function" or type(GetItemSetName) ~= "function" then return {} end
    local results, last, safety = {}, nil, 0
    while safety < 10000 and #results < limit do
        local setId = EPC:Safe(GetNextItemSetCollectionId, nil, last)
        if setId == nil then break end
        safety = safety + 1
        last = setId
        local name = trim(EPC:Safe(GetItemSetName, "", setId))
        if name ~= "" and string.find(lower(name), query, 1, true) then
            local total = type(GetNumItemSetCollectionPieces) == "function" and num(EPC:Safe(GetNumItemSetCollectionPieces,0,setId),0) or 0
            local unlocked = type(GetNumItemSetCollectionSlotsUnlocked) == "function" and num(EPC:Safe(GetNumItemSetCollectionSlotsUnlocked,0,setId),0) or 0
            results[#results+1] = { setId=setId, name=name, unlocked=unlocked, total=total }
        end
    end
    table.sort(results, function(a,b) return a.name < b.name end)
    return results
end

function U:GetZoneCompletion(snapshot)
    local zoneIndex = type(GetUnitZoneIndex) == "function" and EPC:Safe(GetUnitZoneIndex,nil,"player") or nil
    local zoneId = zoneIndex and type(GetZoneId) == "function" and EPC:Safe(GetZoneId,0,zoneIndex) or 0
    if num(zoneId,0) <= 0 and type(GetUnitWorldPosition) == "function" then zoneId = select(1, EPC:Safe(GetUnitWorldPosition,0,"player")) end
    local result = { zoneId=num(zoneId,0), zoneIndex=zoneIndex, zoneName=snapshot and snapshot.zoneName or trim(EPC:Safe(GetUnitZone,"Unknown zone","player")), poiDone=0, poiTotal=0, skyDone=0, skyTotal=0, nearestSky=nil, undiscoveredPOIs={} }
    local now = nowMs()
    if self.zoneCache and self.zoneCache.zoneId == result.zoneId and now > 0 and self.zoneCacheAt > 0 and (now - self.zoneCacheAt) < self.zoneCacheTtlMs then
        return self.zoneCache
    end

    if zoneIndex and type(GetNumPOIs) == "function" and type(GetPOIMapInfo) == "function" then
        local count = num(EPC:Safe(GetNumPOIs,0,zoneIndex),0)
        for poiIndex=1,count do
            local _, _, _, _, _, locked, discovered = EPC:Safe(GetPOIMapInfo,0,zoneIndex,poiIndex)
            local completionType = type(GetPOIZoneCompletionType) == "function" and EPC:Safe(GetPOIZoneCompletionType,ZONE_COMPLETION_TYPE_NONE or 0,zoneIndex,poiIndex) or (ZONE_COMPLETION_TYPE_NONE or 0)
            if completionType ~= (ZONE_COMPLETION_TYPE_NONE or 0) and locked ~= true then
                result.poiTotal = result.poiTotal + 1
                if discovered == true then result.poiDone = result.poiDone + 1
                elseif #result.undiscoveredPOIs < 5 then
                    local name = type(GetPOIInfo) == "function" and select(1,EPC:Safe(GetPOIInfo,"",zoneIndex,poiIndex)) or ""
                    if name and name ~= "" then result.undiscoveredPOIs[#result.undiscoveredPOIs+1] = name end
                end
            end
        end
    end

    if result.zoneId > 0 and type(GetNumSkyshardsInZone) == "function" and type(GetZoneSkyshardId) == "function" and type(GetSkyshardDiscoveryStatus) == "function" then
        local count = num(EPC:Safe(GetNumSkyshardsInZone,0,result.zoneId),0)
        result.skyTotal = count
        local pZone, px, py, pz = nil,0,0,0
        if type(GetUnitWorldPosition) == "function" then pZone, px, py, pz = EPC:Safe(GetUnitWorldPosition,0,"player") end
        local bestDist = nil
        for i=1,count do
            local skyId = EPC:Safe(GetZoneSkyshardId,0,result.zoneId,i)
            if num(skyId,0) > 0 then
                local status = EPC:Safe(GetSkyshardDiscoveryStatus,SKYSHARD_DISCOVERY_STATUS_UNDISCOVERED or 0,skyId)
                if status == SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
                    result.skyDone = result.skyDone + 1
                else
                    local hint = type(GetSkyshardHint) == "function" and trim(EPC:Safe(GetSkyshardHint,"",skyId)) or "Undiscovered skyshard"
                    if type(GetWorldPositionForSkyshardId) == "function" then
                        local sZone, sx, sy, sz = EPC:Safe(GetWorldPositionForSkyshardId,0,skyId)
                        if sZone == pZone and num(sZone,0) > 0 then
                            local dx, dz = num(sx,0)-num(px,0), num(sz,0)-num(pz,0)
                            local dist = math.sqrt(dx*dx + dz*dz)
                            if not bestDist or dist < bestDist then
                                bestDist = dist
                                result.nearestSky = { id=skyId, hint=hint ~= "" and hint or "Undiscovered skyshard", distance=dist, status=status }
                            end
                        elseif not result.nearestSky then
                            result.nearestSky = { id=skyId, hint=hint ~= "" and hint or "Undiscovered skyshard", distance=nil, status=status }
                        end
                    elseif not result.nearestSky then
                        result.nearestSky = { id=skyId, hint=hint ~= "" and hint or "Undiscovered skyshard", distance=nil, status=status }
                    end
                end
            end
        end
    end
    self.zoneCache = result
    self.zoneCacheAt = now
    return result
end

function U:GetLoreProgress()
    local now = nowSeconds()
    if self.loreCache and now > 0 and self.loreCacheAt > 0 and (now - self.loreCacheAt) < 60 then
        return self.loreCache.known, self.loreCache.total
    end
    local known,total=0,0
    if type(GetNumLoreCategories) ~= "function" or type(GetLoreCategoryInfo) ~= "function" or type(GetLoreCollectionInfo) ~= "function" then return known,total end
    local cats = num(EPC:Safe(GetNumLoreCategories,0),0)
    for c=1,cats do
        local _, collections = EPC:Safe(GetLoreCategoryInfo,"",c)
        for col=1,num(collections,0) do
            local _,_,k,t,hidden = EPC:Safe(GetLoreCollectionInfo,"",c,col)
            if hidden ~= true then known=known+num(k,0); total=total+num(t,0) end
        end
    end
    self.loreCache = { known=known, total=total }
    self.loreCacheAt = now
    return known,total
end

function U:GetDailySummary(snapshot, force)
    local now = nowMs()
    if not force and self.dailyCache and now > 0 and self.dailyCacheAt > 0 and (now - self.dailyCacheAt) < self.dailyCacheTtlMs then
        return self.dailyCache
    end
    local entries = EPC.Activities and EPC.Activities:GetAcceptedQuests(snapshot or EPC.lastSnapshot or {}) or {}
    local repeatable, names = 0, {}
    for i=1,#entries do
        if entries[i].repeatable then
            repeatable = repeatable + 1
            if #names < 5 then names[#names+1] = entries[i].name or "Repeatable quest" end
        end
    end
    local loginClaimable = type(GetNumClaimableDailyLoginRewardsInCurrentMonth) == "function" and num(EPC:Safe(GetNumClaimableDailyLoginRewardsInCurrentMonth,0),0) or 0
    local dungeon = EPC.Activities and EPC.Activities:GetDailyRewardEligibility(LFG_ACTIVITY_DUNGEON) or nil
    local bg = EPC.Activities and EPC.Activities:GetBattlegroundEligibility() or nil
    local result = { acceptedRepeatables=repeatable, repeatableNames=names, loginClaimable=loginClaimable, dungeon=dungeon, battleground=bg }
    self.dailyCache = result
    self.dailyCacheAt = now
    return result
end

function U:BuildOverview(snapshot)
    local inv = self:ScanInventory(false)
    local research = self:BuildResearchSummary()
    local zone = self:GetZoneCompletion(snapshot)
    local targets = EPC.TargetBuild and EPC.TargetBuild:GetTargetSets() or {}
    local targetProgress = nil
    if targets[1] then targetProgress = self:GetSetCollectionProgress(targets[1]) end
    local nextSky = zone.nearestSky and zone.nearestSky.hint or "No unfinished skyshard detected"
    local items = {
        string.format("Backpack: %d/%d used — %d free slots", inv.backpackUsed, inv.backpackSize, inv.backpackFree),
        research.unavailable and "Crafting research API unavailable" or string.format("Research: %d/%d traits known — %d active", research.known,research.total,research.active),
        string.format("Zone: %d/%d completion POIs — skyshards %d/%d", zone.poiDone,zone.poiTotal,zone.skyDone,zone.skyTotal),
        targetProgress and string.format("Sticker Book: %s — %d/%d collected",targetProgress.name,targetProgress.unlocked,targetProgress.total) or "Set a target set to add Sticker Book progress here",
        "Nearest unfinished: " .. nextSky,
    }
    return {
        header="UTILITY COMMAND CENTER", title="Everything important outside combat, in one place",
        description="Inventory, research, collections, daily value, and zone completion are read together so the coach can surface useful work without forcing another full-screen addon.",
        stats={{label="BAG FREE",value=tostring(inv.backpackFree)},{label="RESEARCH",value=research.unavailable and "N/A" or string.format("%d/%d",research.known,research.total)},{label="SKYSHARDS",value=string.format("%d/%d",zone.skyDone,zone.skyTotal)},{label="TARGET ITEMS",value=tostring(inv.targetItems)}},
        rows=items, hint="Use the buttons above for deeper Inventory, Research, Collections, or Dailies details.",
    }
end

function U:BuildInventoryView(snapshot)
    local inv = self:ScanInventory(false)
    local rows = {}
    if #inv.targetItemNames > 0 then
        for i=1,math.min(3,#inv.targetItemNames) do rows[#rows+1]="TARGET: "..inv.targetItemNames[i] end
    end
    if #rows < 5 and #inv.researchItems > 0 then
        for i=1,#inv.researchItems do
            if #rows>=5 then break end
            rows[#rows+1]="RESEARCH: "..inv.researchItems[i]
        end
    end
    if #rows==0 then rows[1]="No target-set or research-priority items were found in the backpack." end
    rows[#rows+1]="Search saved character/bank snapshots with /esocoach find <item name>."
    return {
        header="INVENTORY INTELLIGENCE", title=string.format("%d free backpack slots",inv.backpackFree),
        description="Tracks useful inventory signals and remembers compact item counts for characters that have loaded this addon. Vendor value is an NPC sell-value estimate, not a guild-trader market price.",
        stats={{label="BACKPACK",value=string.format("%d/%d",inv.backpackUsed,inv.backpackSize)},{label="BANK",value=inv.bankSize>0 and string.format("%d/%d",inv.bankUsed,inv.bankSize) or "Unavailable"},{label="NPC VALUE",value=formatNumber(inv.vendorValue).."g"},{label="RESEARCHABLE",value=tostring(inv.researchCandidates)}},
        rows=rows, hint="Advisory only: the coach never sells, destroys, deconstructs, locks, or moves items.",
    }
end

function U:BuildResearchView(snapshot)
    local r = self:BuildResearchSummary()
    local inv = self:ScanInventory(false)
    if r.unavailable then
        return { header="CRAFTING & RESEARCH",title="Research data unavailable",description="The smithing research API could not be read on this client.",stats={},rows={"Use /esocoach compat to inspect capability status."},hint="No crafting action is automated." }
    end
    local rows={}
    for i=1,#r.crafts do
        local c=r.crafts[i]
        local text=string.format("%s: %d/%d known — %d/%d active",c.label,c.known,c.total,c.active,c.maxActive)
        if c.nextRemaining then text=text.." — next "..formatDuration(c.nextRemaining) end
        rows[#rows+1]=text
    end
    if inv.researchCandidates>0 then rows[#rows+1]=string.format("%d backpack item%s can teach an unknown trait.",inv.researchCandidates,inv.researchCandidates==1 and "" or "s") end
    return {
        header="CRAFTING & RESEARCH",title=r.nextRemaining and ("Next research finishes in "..formatDuration(r.nextRemaining)) or "No active trait research detected",
        description="Tracks smithing trait knowledge and active timers across Blacksmithing, Clothier, Woodworking, and Jewelry Crafting. It flags research candidates but never starts or cancels research.",
        stats={{label="TRAITS KNOWN",value=string.format("%d/%d",r.known,r.total)},{label="ACTIVE",value=string.format("%d/%d",r.active,r.maxActive)},{label="CANDIDATES",value=tostring(inv.researchCandidates)},{label="NEXT",value=r.nextRemaining and formatDuration(r.nextRemaining) or "Ready"}},
        rows=rows,hint="Research candidate alerts help protect useful traits before you decide to deconstruct or sell an item.",
    }
end

function U:BuildCollectionsView(snapshot)
    local zone=self:GetZoneCompletion(snapshot)
    local loreKnown,loreTotal=self:GetLoreProgress()
    local targets=EPC.TargetBuild and EPC.TargetBuild:GetTargetSets() or {}
    local rows={}
    if zone.nearestSky then
        local d=zone.nearestSky.distance and string.format(" (~%d world units straight-line)",math.floor(zone.nearestSky.distance+0.5)) or ""
        rows[#rows+1]="Nearest unfinished skyshard: "..zone.nearestSky.hint..d
    else rows[#rows+1]="No unfinished skyshard detected in this zone." end
    for i=1,math.min(2,#zone.undiscoveredPOIs) do rows[#rows+1]="Unfinished POI: "..zone.undiscoveredPOIs[i] end
    for i=1,#targets do
        local p=self:GetSetCollectionProgress(targets[i])
        if p then rows[#rows+1]=string.format("Sticker Book: %s — %d/%d",p.name,p.unlocked,p.total) end
    end
    return {
        header="COLLECTIONS & ZONE COMPLETION",title=zone.zoneName,
        description="Uses ESO's live zone POI, skyshard, lore, and Item Set Collection APIs. It can show progress without shipping someone else's map-pin database.",
        stats={{label="SKYSHARDS",value=string.format("%d/%d",zone.skyDone,zone.skyTotal)},{label="ZONE POIS",value=string.format("%d/%d",zone.poiDone,zone.poiTotal)},{label="LORE BOOKS",value=loreTotal>0 and string.format("%d/%d",loreKnown,loreTotal) or "Unavailable"},{label="TARGET SETS",value=tostring(#targets)}},
        rows=rows,hint="Use /esocoach set <name> to search the Sticker Book. Straight-line world-position distance is only a proximity hint and ignores doors, caves, cliffs, or phasing.",
    }
end

function U:BuildDailiesView(snapshot)
    local d=self:GetDailySummary(snapshot)
    local curated=EPC.Activities and EPC.Activities:GetCuratedActivities(snapshot or EPC.lastSnapshot or {}) or {}
    local rows={}
    for i=1,math.min(2,#(d.repeatableNames or {})) do rows[#rows+1]="ACCEPTED: "..d.repeatableNames[i] end
    for i=1,#curated do
        if #rows>=5 then break end
        rows[#rows+1]=(curated[i].name or "Daily activity").." — "..(curated[i].status or "Check availability")
    end
    local dungeonText=d.dungeon==true and "READY" or (d.dungeon==false and "USED / UNAVAILABLE" or "UNKNOWN")
    local bgText=d.battleground==true and "READY" or (d.battleground==false and "USED / UNAVAILABLE" or "UNKNOWN")
    return {
        header="DAILY / WEEKLY DASHBOARD",title=d.loginClaimable>0 and "A daily login reward is claimable" or "High-value routine status",
        description="Brings daily reward eligibility, accepted repeatable quests, and the coach's high-value routine list into one dashboard. It does not auto-claim rewards or auto-queue activities.",
        stats={{label="LOGIN REWARD",value=d.loginClaimable>0 and "CLAIMABLE" or "Checked"},{label="RANDOM DUNGEON",value=dungeonText},{label="BATTLEGROUND",value=bgText},{label="REPEATABLE QUESTS",value=tostring(d.acceptedRepeatables)}},
        rows=rows,hint="Use ACTIVITY to rank these routines by XP, GOLD, or BALANCED value and to route accepted quests.",
    }
end


function U:BuildReticleView(snapshot)
    local enabled = EPC.saved and EPC.saved.customReticleEnabled == true
    local style = tostring(EPC.saved and EPC.saved.customReticleStyle or "RUNE")
    local color = tostring(EPC.saved and EPC.saved.customReticleColor or "GOLD")
    local styleNames = { DEFAULT="ESO Default", RUNE="Tamriel Rune", BRACKETS="Corner Brackets", COMPASS="Compass Cross", MINIMAL="Minimal Cross", DAEDRIC="Daedric Diamond", AYLEID="Ayleid Star", DRAGON="Dragon Eye" }
    local colorNames = { GOLD="ESO Gold", IVORY="Ivory", CRIMSON="Crimson", BLUE="Arcane Blue", RGB="RGB Rainbow" }
    local size = tonumber(EPC.saved and EPC.saved.customReticleSize) or 100
    local opacity = math.floor((tonumber(EPC.saved and EPC.saved.customReticleOpacity) or 0.95) * 100 + 0.5)
    return {
        header="CUSTOM ESO RETICLE",
        title=enabled and "Custom reticle enabled" or "Custom reticle disabled",
        description="Change the Suite-owned crosshair directly from the Tamriel Codex. ESO interaction prompts and target text remain intact.",
        stats={
            {label="STATUS", value=enabled and "ON" or "OFF"},
            {label="STYLE", value=styleNames[style] or style},
            {label="COLOR", value=colorNames[color] or color},
            {label="SIZE", value=tostring(size) .. "%"},
            {label="OPACITY", value=tostring(opacity) .. "%"},
        },
        rows={
            "ON / OFF toggles the custom reticle.",
            "STYLE cycles through ESO Default and the custom ESO-style designs.",
            "COLOR cycles through the available reticle colors, including RGB Rainbow.",
            "SIZE - / SIZE + decrease or increase reticle size.",
            "OPACITY - / OPACITY + decrease or increase reticle opacity.",
        },
        hint="You can also change these under Settings > Addons > ESO Adventurer Suite > Custom ESO Reticle.",
    }
end

function U:ToggleReticle()
    if not EPC.saved then return end
    EPC.saved.customReticleEnabled = not (EPC.saved.customReticleEnabled == true)
    if EPC.Reticle then EPC.Reticle:Refresh(true) end
end

function U:CycleReticleStyle()
    if not EPC.saved then return end
    local order={"DEFAULT","RUNE","BRACKETS","COMPASS","MINIMAL","DAEDRIC","AYLEID","DRAGON"}
    local current=tostring(EPC.saved.customReticleStyle or "RUNE")
    local idx=1
    for i,v in ipairs(order) do if v==current then idx=i break end end
    EPC.saved.customReticleStyle=order[(idx % #order)+1]
    if EPC.Reticle then EPC.Reticle:Refresh(true) end
end

function U:CycleReticleColor()
    if not EPC.saved then return end
    local order={"GOLD","IVORY","CRIMSON","BLUE","RGB"}
    local current=tostring(EPC.saved.customReticleColor or "GOLD")
    local idx=1
    for i,v in ipairs(order) do if v==current then idx=i break end end
    EPC.saved.customReticleColor=order[(idx % #order)+1]
    if EPC.Reticle then EPC.Reticle:Refresh(true) end
end

function U:DecreaseReticleSize()
    if not EPC.saved then return end
    EPC.saved.customReticleSize=math.max(60,(tonumber(EPC.saved.customReticleSize) or 100)-10)
    if EPC.Reticle then EPC.Reticle:Refresh(true) end
end

function U:IncreaseReticleSize()
    if not EPC.saved then return end
    EPC.saved.customReticleSize=math.min(180,(tonumber(EPC.saved.customReticleSize) or 100)+10)
    if EPC.Reticle then EPC.Reticle:Refresh(true) end
end

function U:DecreaseReticleOpacity()
    if not EPC.saved then return end
    local pct=math.floor((tonumber(EPC.saved.customReticleOpacity) or 0.95)*100+0.5)-10
    EPC.saved.customReticleOpacity=math.max(25,pct)/100
    if EPC.Reticle then EPC.Reticle:Refresh(true) end
end

function U:IncreaseReticleOpacity()
    if not EPC.saved then return end
    local pct=math.floor((tonumber(EPC.saved.customReticleOpacity) or 0.95)*100+0.5)+10
    EPC.saved.customReticleOpacity=math.min(100,pct)/100
    if EPC.Reticle then EPC.Reticle:Refresh(true) end
end

function U:BuildModeView(mode, snapshot, force)
    mode = string.upper(tostring(mode or self:GetMode()))
    if not self.validModes[mode] then mode = "OVERVIEW" end

    if not force then
        local cached, fresh = self:GetCachedModeView(mode)
        if cached and fresh then return cached end
    end

    local view
    if mode=="INVENTORY" then view=self:BuildInventoryView(snapshot)
    elseif mode=="RESEARCH" then view=self:BuildResearchView(snapshot)
    elseif mode=="COLLECTIONS" then view=self:BuildCollectionsView(snapshot)
    elseif mode=="DAILIES" then view=self:BuildDailiesView(snapshot)
    elseif mode=="RETICLE" then view=self:BuildReticleView(snapshot)
    else view=self:BuildOverview(snapshot) end
    view.mode=mode
    view.modeLabel=self.modeLabels[mode] or mode
    self.viewCache[mode] = view
    self.viewCacheAt[mode] = nowMs()
    return view
end

function U:BuildView(snapshot)
    return self:BuildModeView(self:GetMode(), snapshot, false)
end

function U:Prewarm(snapshot)
    snapshot = snapshot or EPC.lastSnapshot or {}
    local modes = {"INVENTORY", "RESEARCH", "COLLECTIONS", "DAILIES", "RETICLE", "OVERVIEW"}
    for i=1,#modes do
        local mode = modes[i]
        local function warm()
            -- Skip if another refresh already produced this mode.
            local cached, fresh = self:GetCachedModeView(mode)
            if fresh then return end
            pcall(self.BuildModeView, self, mode, snapshot, true)
        end
        if type(zo_callLater) == "function" then zo_callLater(warm, 175 * i) else warm() end
    end
end

function U:EvaluateLoot(bagId,slotIndex,isNewItem)
    if not isNewItem or bagId ~= BAG_BACKPACK or type(GetItemLink) ~= "function" then return nil end
    local link=EPC:Safe(GetItemLink,"",bagId,slotIndex,LINK_STYLE_BRACKETS or 1)
    if not link or link=="" then return nil end
    local name=trim(EPC:Safe(GetItemLinkName,"Item",link))
    if not EPC.saved or EPC.saved.targetLootAlerts ~= false then
        local target=EPC.TargetBuild and EPC.TargetBuild:EvaluateItemLink(link) or nil
        if target then return {tag="TARGET KEEP",reason=target.reason,itemName=name,priority=100} end
    end
    if EPC.saved and EPC.saved.utilityLootAlerts == false then return nil end
    if type(CanItemBeUsedToLearn)=="function" and EPC:Safe(CanItemBeUsedToLearn,false,bagId,slotIndex)==true then
        return {tag="LEARN",reason="This item can teach your character something",itemName=name,priority=95}
    end
    if type(CanItemLinkBeTraitResearched)=="function" and EPC:Safe(CanItemLinkBeTraitResearched,false,link)==true then
        return {tag="RESEARCH",reason="Unknown trait can be researched",itemName=name,priority=90}
    end
    if type(IsItemLinkSetCollectionPiece)=="function" and EPC:Safe(IsItemLinkSetCollectionPiece,false,link)==true and type(GetItemLinkSetInfo)=="function" then
        local hasSet,setName,_,_,_,setId=EPC:Safe(GetItemLinkSetInfo,false,link,false)
        local slot=type(GetItemLinkItemSetCollectionSlot)=="function" and EPC:Safe(GetItemLinkItemSetCollectionSlot,nil,link) or nil
        if hasSet and num(setId,0)>0 and slot~=nil and type(IsItemSetCollectionSlotUnlocked)=="function" then
            local unlocked=EPC:Safe(IsItemSetCollectionSlotUnlocked,true,setId,slot)
            if unlocked==false then return {tag="COLLECTION",reason="Uncollected Sticker Book piece: "..tostring(setName or "set"),itemName=name,priority=80} end
        end
    end
    return nil
end

function U:OnInventorySlotUpdate(bagId,slotIndex,isNewItem)
    self:Invalidate("INVENTORY")
    if not EPC.saved or (EPC.saved.utilityLootAlerts==false and EPC.saved.targetLootAlerts==false) then return end
    local verdict=self:EvaluateLoot(bagId,slotIndex,isNewItem)
    if verdict then EPC:Print(string.format("|c66FF99%s|r — %s: %s",verdict.tag,verdict.itemName,verdict.reason)) end
end

function U:GetMapHint(snapshot)
    local zone=self:GetZoneCompletion(snapshot)
    if zone.skyTotal>0 then
        local text=string.format("Zone progress: skyshards %d/%d; completion POIs %d/%d.",zone.skyDone,zone.skyTotal,zone.poiDone,zone.poiTotal)
        if zone.nearestSky then text=text.." Nearest unfinished skyshard: "..zone.nearestSky.hint.."." end
        return text
    end
    if zone.poiTotal>0 then return string.format("Zone progress: completion POIs %d/%d.",zone.poiDone,zone.poiTotal) end
    return nil
end
