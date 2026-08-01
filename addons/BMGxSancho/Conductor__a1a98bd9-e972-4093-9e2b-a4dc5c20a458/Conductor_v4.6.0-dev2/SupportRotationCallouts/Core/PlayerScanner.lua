local C = Conductor
C.PlayerScanner = C.PlayerScanner or {}
local Scanner = C.PlayerScanner

Scanner.scanIntervalMs = 5000
Scanner.updateName = "ConductorPlayerScannerUpdate"
Scanner.eventNamespace = "ConductorPlayerScanner"
Scanner.lastLocalSignature = nil
Scanner.lastLocalSnapshot = nil

local function GetRoleForUnit(unitTag)
    if GetGroupMemberSelectedRole then
        local role = GetGroupMemberSelectedRole(unitTag)
        if role == LFG_ROLE_TANK then return "TANK" end
        if role == LFG_ROLE_HEAL then return "HEALER" end
        if role == LFG_ROLE_DPS then return "DAMAGE" end
    end
    return "UNKNOWN"
end

local function BuildCapabilityContainer()
    return {
        gear = {},
        gearSets = {},
        skills = {},
        scribedSkills = {},
        ultimates = {},
        effects = {},
        masteries = {},
        championPoints = {},
        responsibilities = {},
        interpreted = {},
        scan = {
            gearSupported = false,
            skillsSupported = false,
            scribingSupported = false,
            scribedAbilityCount = 0,
            scribingScriptCount = 0,
            championPointsSupported = false,
            scannedAt = 0,
        },
    }
end

local EQUIPMENT_SLOTS = {
    { key = "HEAD", slot = EQUIP_SLOT_HEAD },
    { key = "SHOULDERS", slot = EQUIP_SLOT_SHOULDERS },
    { key = "CHEST", slot = EQUIP_SLOT_CHEST },
    { key = "HANDS", slot = EQUIP_SLOT_HAND },
    { key = "WAIST", slot = EQUIP_SLOT_WAIST },
    { key = "LEGS", slot = EQUIP_SLOT_LEGS },
    { key = "FEET", slot = EQUIP_SLOT_FEET },
    { key = "NECK", slot = EQUIP_SLOT_NECK },
    { key = "RING1", slot = EQUIP_SLOT_RING1 },
    { key = "RING2", slot = EQUIP_SLOT_RING2 },
    { key = "MAIN_HAND", slot = EQUIP_SLOT_MAIN_HAND },
    { key = "OFF_HAND", slot = EQUIP_SLOT_OFF_HAND },
    { key = "BACKUP_MAIN", slot = EQUIP_SLOT_BACKUP_MAIN },
    { key = "BACKUP_OFF", slot = EQUIP_SLOT_BACKUP_OFF },
}

local function SafeAbilityName(abilityId)
    if not abilityId or abilityId == 0 then return "" end
    if GetAbilityName then return zo_strformat("<<1>>", GetAbilityName(abilityId) or "") end
    return ""
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d
end

local SCRIPT_SLOT_NAMES = { "FOCUS", "SIGNATURE", "AFFIX" }

local function ReadScriptName(manager, scriptId)
    local scriptName = ""
    if manager and type(manager.GetCraftedAbilityScriptData) == "function" then
        local scriptData = SafeCall(function() return manager:GetCraftedAbilityScriptData(scriptId) end)
        if scriptData and type(scriptData.GetFormattedName) == "function" then
            scriptName = SafeCall(function() return scriptData:GetFormattedName() end) or ""
        elseif scriptData and type(scriptData.GetName) == "function" then
            scriptName = SafeCall(function() return scriptData:GetName() end) or ""
        end
    end
    if scriptName == "" and GetCraftedAbilityScriptDisplayName then
        scriptName = SafeCall(GetCraftedAbilityScriptDisplayName, scriptId) or ""
    end
    if scriptName == "" and GetCraftedAbilityScriptName then
        scriptName = SafeCall(GetCraftedAbilityScriptName, scriptId) or ""
    end
    return zo_strformat("<<1>>", scriptName ~= "" and scriptName or ("Script " .. tostring(scriptId)))
end

local function ReadActiveScriptIds(craftedAbilityId, craftedData)
    local first, second, third
    if craftedData then
        for _, methodName in ipairs({ "GetActiveScriptIds", "GetSelectedScriptIds", "GetScriptIds" }) do
            local method = craftedData[methodName]
            if type(method) == "function" then
                first, second, third = SafeCall(function() return method(craftedData) end)
                if (tonumber(first) or 0) > 0 or (tonumber(second) or 0) > 0 or (tonumber(third) or 0) > 0 then
                    return first, second, third
                end
            end
        end
    end
    for _, globalName in ipairs({ "GetCraftedAbilityActiveScriptIds", "GetCraftedAbilityScriptIds" }) do
        local fn = rawget(_G, globalName)
        if type(fn) == "function" then
            first, second, third = SafeCall(fn, craftedAbilityId)
            if (tonumber(first) or 0) > 0 or (tonumber(second) or 0) > 0 or (tonumber(third) or 0) > 0 then
                return first, second, third
            end
        end
    end
    if type(rawget(_G, "GetCraftedAbilityScriptId")) == "function" then
        local fn = rawget(_G, "GetCraftedAbilityScriptId")
        return SafeCall(fn, craftedAbilityId, 1), SafeCall(fn, craftedAbilityId, 2), SafeCall(fn, craftedAbilityId, 3)
    end
    return nil, nil, nil
end

local function GetScribingScriptData(craftedAbilityId)
    local scriptIds, scriptNames, scriptSlots = {}, {}, {}
    local manager = rawget(_G, "SCRIBING_DATA_MANAGER")
    local craftedData
    if manager and type(manager.GetCraftedAbilityData) == "function" then
        craftedData = SafeCall(function() return manager:GetCraftedAbilityData(craftedAbilityId) end)
    end

    local first, second, third = ReadActiveScriptIds(craftedAbilityId, craftedData)
    local activeIds = { [1] = first, [2] = second, [3] = third }
    for index = 1, 3 do
        local scriptId = tonumber(activeIds[index]) or 0
        if scriptId > 0 then
            local scriptName = ReadScriptName(manager, scriptId)
            scriptIds[#scriptIds + 1] = scriptId
            scriptNames[#scriptNames + 1] = scriptName
            scriptSlots[#scriptSlots + 1] = {
                slotType = SCRIPT_SLOT_NAMES[index] or ("SCRIPT_" .. tostring(index)),
                scriptId = scriptId,
                scriptName = scriptName,
            }
        end
    end
    return scriptIds, scriptNames, scriptSlots
end

local function ResolveSlottedAbility(rawId)
    local rawActionId = tonumber(rawId) or 0
    local craftedAbilityId = 0
    local generatedAbilityId = 0

    -- Depending on platform/API revision, the action bar may expose either the
    -- crafted ability id or the generated ability id. Resolve both directions.
    if GetAbilityIdForCraftedAbilityId then
        generatedAbilityId = tonumber(SafeCall(GetAbilityIdForCraftedAbilityId, rawActionId)) or 0
        if generatedAbilityId > 0 then craftedAbilityId = rawActionId end
    end
    if craftedAbilityId == 0 then
        for _, functionName in ipairs({ "GetCraftedAbilityIdForAbilityId", "GetCraftedAbilityIdForAbility" }) do
            local fn = rawget(_G, functionName)
            if type(fn) == "function" then
                local candidate = tonumber(SafeCall(fn, rawActionId)) or 0
                if candidate > 0 then
                    craftedAbilityId = candidate
                    generatedAbilityId = rawActionId
                    break
                end
            end
        end
    end

    local resolvedId = generatedAbilityId > 0 and generatedAbilityId or rawActionId
    local resolvedName = SafeAbilityName(resolvedId)
    local result = {
        abilityId = resolvedId,
        abilityName = resolvedName,
        rawActionId = rawActionId,
        isScribed = craftedAbilityId > 0,
        craftedAbilityId = craftedAbilityId,
        grimoireName = "",
        scriptIds = {},
        scriptNames = {},
        scriptSlots = {},
    }

    if craftedAbilityId > 0 then
        local craftedName = ""
        if GetCraftedAbilityDisplayName then
            craftedName = zo_strformat("<<1>>", SafeCall(GetCraftedAbilityDisplayName, craftedAbilityId) or "")
        end
        result.grimoireName = craftedName
        result.abilityName = resolvedName ~= "" and resolvedName or craftedName
        result.scriptIds, result.scriptNames, result.scriptSlots = GetScribingScriptData(craftedAbilityId)
    end

    return result
end

local function IsFrontWeaponSlot(slotKey)
    return slotKey == "MAIN_HAND" or slotKey == "OFF_HAND"
end

local function IsBackWeaponSlot(slotKey)
    return slotKey == "BACKUP_MAIN" or slotKey == "BACKUP_OFF"
end

local function GetSetPieceWeight(itemLink, slotKey)
    if not IsFrontWeaponSlot(slotKey) and not IsBackWeaponSlot(slotKey) then return 1 end
    local equipType = GetItemLinkEquipType and SafeCall(GetItemLinkEquipType, itemLink) or nil
    if equipType == EQUIP_TYPE_TWO_HAND then return 2 end
    return 1
end

local function RecalculateSetPieces(setEntry)
    local body = tonumber(setEntry.bodyPieces) or 0
    local front = tonumber(setEntry.frontWeaponPieces) or 0
    local back = tonumber(setEntry.backWeaponPieces) or 0
    local observed = body + math.max(front, back)
    setEntry.observedEquippedPieces = observed
    setEntry.equippedPieces = math.max(tonumber(setEntry.reportedEquippedPieces) or 0, observed)
end

function Scanner:ScanEquipment()
    local gear = {}
    local setMap = {}
    if not GetItemLink or not BAG_WORN then return gear, {}, false end

    for _, definition in ipairs(EQUIPMENT_SLOTS) do
        if definition.slot ~= nil then
            local itemLink = GetItemLink(BAG_WORN, definition.slot, LINK_STYLE_DEFAULT)
            if itemLink and itemLink ~= "" then
                local itemName = GetItemLinkName and zo_strformat("<<1>>", GetItemLinkName(itemLink) or "") or ""
                local entry = {
                    slot = definition.key,
                    equipSlot = definition.slot,
                    itemLink = itemLink,
                    itemName = itemName,
                    setId = 0,
                    setName = "",
                    enchantId = 0,
                    enchantName = "",
                    enchantDescription = "",
                }
                if GetItemLinkEnchantInfo then
                    local hasEnchant, enchantHeader, enchantDescription = SafeCall(GetItemLinkEnchantInfo, itemLink)
                    if hasEnchant then
                        entry.enchantName = zo_strformat("<<1>>", enchantHeader or "")
                        entry.enchantDescription = zo_strformat("<<1>>", enchantDescription or "")
                    end
                end
                if GetItemLinkDefaultEnchantId then
                    entry.enchantId = tonumber(SafeCall(GetItemLinkDefaultEnchantId, itemLink)) or 0
                end
                if GetItemLinkSetInfo then
                    local hasSet, setName, _, numEquipped, maxEquipped, setId = GetItemLinkSetInfo(itemLink, false)
                    if hasSet then
                        entry.setId = tonumber(setId) or 0
                        entry.setName = zo_strformat("<<1>>", setName or "")
                        local setKey = entry.setId > 0 and tostring(entry.setId) or string.lower(entry.setName)
                        if setKey ~= "" then
                            local reportedPieces = tonumber(numEquipped) or 0
                            local setEntry = setMap[setKey] or {
                                setId = entry.setId,
                                setName = entry.setName,
                                equippedPieces = 0,
                                reportedEquippedPieces = 0,
                                observedEquippedPieces = 0,
                                bodyPieces = 0,
                                frontWeaponPieces = 0,
                                backWeaponPieces = 0,
                                maxPieces = tonumber(maxEquipped) or 0,
                                observedSlots = {},
                            }
                            setEntry.reportedEquippedPieces = math.max(setEntry.reportedEquippedPieces or 0, reportedPieces)
                            setEntry.maxPieces = math.max(setEntry.maxPieces or 0, tonumber(maxEquipped) or 0)
                            local pieceWeight = GetSetPieceWeight(itemLink, definition.key)
                            if IsFrontWeaponSlot(definition.key) then
                                setEntry.frontWeaponPieces = (setEntry.frontWeaponPieces or 0) + pieceWeight
                            elseif IsBackWeaponSlot(definition.key) then
                                setEntry.backWeaponPieces = (setEntry.backWeaponPieces or 0) + pieceWeight
                            else
                                setEntry.bodyPieces = (setEntry.bodyPieces or 0) + pieceWeight
                            end
                            setEntry.observedSlots[#setEntry.observedSlots + 1] = definition.key
                            RecalculateSetPieces(setEntry)
                            setMap[setKey] = setEntry
                        end
                    end
                end
                gear[#gear + 1] = entry
            end
        end
    end

    local gearSets = {}
    for _, setEntry in pairs(setMap) do
        RecalculateSetPieces(setEntry)
        if (tonumber(setEntry.equippedPieces) or 0) > 0 then
            gearSets[#gearSets + 1] = setEntry
        end
    end
    table.sort(gearSets, function(a, b) return tostring(a.setName) < tostring(b.setName) end)
    return gear, gearSets, true
end

function Scanner:ScanHotbar(hotbarCategory, barName)
    local skills = {}
    local ultimates = {}
    if not GetSlotBoundId then return skills, ultimates, false end

    -- ESO's ACTION_BAR_ULTIMATE_SLOT_INDEX identifies the final normal slot;
    -- the bound ultimate is stored at the following action-button index.
    -- Current console constants resolve to normal slots 2-7 and ultimate slot 8.
    local firstSlot = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX or 2
    local ultimateSlot = (ACTION_BAR_ULTIMATE_SLOT_INDEX or 7) + 1
    for slotIndex = firstSlot, ultimateSlot do
        local rawActionId = GetSlotBoundId(slotIndex, hotbarCategory)
        if rawActionId and rawActionId > 0 then
            local entry = ResolveSlottedAbility(rawActionId)
            entry.slotIndex = slotIndex
            entry.bar = barName
            entry.hotbarCategory = hotbarCategory
            if slotIndex == ultimateSlot then
                ultimates[#ultimates + 1] = entry
            else
                skills[#skills + 1] = entry
            end
        end
    end
    return skills, ultimates, true
end

function Scanner:ScanSkills()
    local skills = {}
    local scribedSkills = {}
    local ultimates = {}
    local supported = false
    local bars = {
        { category = HOTBAR_CATEGORY_PRIMARY, name = "FRONT" },
        { category = HOTBAR_CATEGORY_BACKUP, name = "BACK" },
    }
    for _, bar in ipairs(bars) do
        if bar.category ~= nil then
            local barSkills, barUltimates, barSupported = self:ScanHotbar(bar.category, bar.name)
            supported = supported or barSupported
            for _, entry in ipairs(barSkills) do
                skills[#skills + 1] = entry
                if entry.isScribed then scribedSkills[#scribedSkills + 1] = entry end
            end
            for _, entry in ipairs(barUltimates) do ultimates[#ultimates + 1] = entry end
        end
    end
    return skills, scribedSkills, ultimates, supported
end

function Scanner:ScanLocalCapabilities()
    local capabilities = BuildCapabilityContainer()
    local gear, gearSets, gearSupported = self:ScanEquipment()
    local skills, scribedSkills, ultimates, skillsSupported = self:ScanSkills()
    capabilities.gear = gear
    capabilities.gearSets = gearSets
    capabilities.skills = skills
    capabilities.scribedSkills = scribedSkills
    capabilities.ultimates = ultimates
    capabilities.scan.gearSupported = gearSupported
    capabilities.scan.skillsSupported = skillsSupported
    capabilities.scan.scribingSupported = #scribedSkills > 0
    capabilities.scan.scribedAbilityCount = #scribedSkills
    local scribingScriptCount = 0
    for _, skill in ipairs(scribedSkills) do scribingScriptCount = scribingScriptCount + #(skill.scriptIds or {}) end
    capabilities.scan.scribingScriptCount = scribingScriptCount
    capabilities.scan.championPointsSupported = false
    capabilities.scan.scannedAt = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if C.CapabilityEngine and C.CapabilityEngine.Interpret then
        C.CapabilityEngine:Interpret(capabilities)
    end
    return capabilities
end

function Scanner:BuildUnitSnapshot(unitTag)
    if not unitTag or not DoesUnitExist(unitTag) then return nil end
    local accountName = GetUnitDisplayName(unitTag)
    if not accountName or accountName == "" then return nil end
    return {
        accountName = accountName,
        characterName = zo_strformat("<<1>>", GetUnitName(unitTag) or ""),
        classId = GetUnitClassId(unitTag) or 0,
        role = unitTag == "player" and string.upper(C.saved and C.saved.displayRole or "UNKNOWN") or GetRoleForUnit(unitTag),
        unitTag = unitTag,
        online = IsUnitOnline and IsUnitOnline(unitTag) or true,
        dead = IsUnitDead and IsUnitDead(unitTag) or false,
        isLocalPlayer = unitTag == "player",
        zoneIndex = GetUnitZoneIndex and GetUnitZoneIndex(unitTag) or 0,
        capabilities = BuildCapabilityContainer(),
        observedAt = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0,
    }
end

local function BuildSignature(snapshot)
    local parts = {
        tostring(snapshot.characterName or ""),
        tostring(snapshot.classId or 0),
        tostring(snapshot.role or ""),
    }
    local capabilities = snapshot.capabilities or {}
    for _, setEntry in ipairs(capabilities.gearSets or {}) do
        parts[#parts + 1] = string.format("G:%s:%s", tostring(setEntry.setId or 0), tostring(setEntry.equippedPieces or 0))
    end
    for _, gearEntry in ipairs(capabilities.gear or {}) do
        parts[#parts + 1] = string.format("E:%s:%s:%s", tostring(gearEntry.slot or ""), tostring(gearEntry.enchantId or 0), tostring(gearEntry.enchantName or ""))
    end
    for _, skill in ipairs(capabilities.skills or {}) do
        local scripts = table.concat(skill.scriptIds or {}, ",")
        parts[#parts + 1] = string.format("S:%s:%s:%s:%s:%s", tostring(skill.bar), tostring(skill.slotIndex), tostring(skill.abilityId), tostring(skill.craftedAbilityId or 0), scripts)
    end
    for _, ultimate in ipairs(capabilities.ultimates or {}) do
        parts[#parts + 1] = string.format("U:%s:%s", tostring(ultimate.bar), tostring(ultimate.abilityId))
    end
    for _, capability in ipairs(capabilities.interpreted or {}) do
        parts[#parts + 1] = string.format("C:%s", tostring(capability.key))
    end
    return table.concat(parts, "|")
end

function Scanner:ScanLocalPlayer(forcePublish)
    local snapshot = self:BuildUnitSnapshot("player") or {}
    snapshot.capabilities = self:ScanLocalCapabilities()
    snapshot.gear = snapshot.capabilities.gear
    snapshot.gearSets = snapshot.capabilities.gearSets
    snapshot.skills = snapshot.capabilities.skills
    snapshot.scribedSkills = snapshot.capabilities.scribedSkills
    snapshot.ultimates = snapshot.capabilities.ultimates
    snapshot.masteries = snapshot.capabilities.masteries
    snapshot.championPoints = snapshot.capabilities.championPoints
    snapshot.responsibilities = snapshot.capabilities.responsibilities
    snapshot.conductorVersion = C.Platform and C.Platform.version or C.version
    snapshot.protocolVersion = C.Network and C.Network.protocolVersion or 0
    snapshot.networkState = "LOCAL"
    if C.RaidIntelligenceEngine and C.RaidIntelligenceEngine.BuildProfile then
        C.RaidIntelligenceEngine:BuildProfile(snapshot)
    end

    local signature = BuildSignature(snapshot)
    local changed = signature ~= self.lastLocalSignature
    self.lastLocalSignature = signature
    self.lastLocalSnapshot = snapshot
    if (changed or forcePublish) and C.EventBus then
        C.EventBus:Publish("LOCAL_CAPABILITIES_CHANGED", { snapshot = snapshot, signature = signature, forced = forcePublish == true })
    end
    return snapshot
end

function Scanner:GetLastLocalSnapshot()
    return self.lastLocalSnapshot or self:ScanLocalPlayer(false)
end

function Scanner:ScanGroup()
    if not C.Database then return end
    local seen = {}
    local localSnapshot = self:ScanLocalPlayer(false)
    if localSnapshot.accountName then
        seen[string.lower(localSnapshot.accountName)] = true
        C.Database:UpdatePlayer(localSnapshot.accountName, localSnapshot, "local")
    end

    local groupSize = GetGroupSize and GetGroupSize() or 0
    for index = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(index)
        local snapshot = self:BuildUnitSnapshot(unitTag)
        if snapshot then
            seen[string.lower(snapshot.accountName)] = true
            local existing = C.Database:GetPlayer(snapshot.accountName)
            if existing and existing.source == "network" and existing.capabilities and existing.capabilities.scan and existing.capabilities.scan.networkProfile then
                -- Keep the synchronized capability profile. Roster scans only refresh
                -- live unit metadata for players whose Conductor profile is already known.
                C.Database:UpdatePlayer(snapshot.accountName, {
                    characterName = snapshot.characterName,
                    classId = snapshot.classId ~= 0 and snapshot.classId or existing.classId,
                    unitTag = snapshot.unitTag,
                    online = snapshot.online,
                    dead = snapshot.dead,
                    zoneIndex = snapshot.zoneIndex,
                    observedAt = snapshot.observedAt,
                }, "network")
            else
                C.Database:UpdatePlayer(snapshot.accountName, snapshot, "roster")
            end
        end
    end
    C.Database:PruneRoster(seen)
    if C.EventBus then C.EventBus:Publish("GROUP_SCANNED", { count = groupSize, seen = seen }) end
end

function Scanner:RefreshLocalCapabilities(forcePublish)
    if forcePublish == nil then forcePublish = true end
    local snapshot = self:ScanLocalPlayer(forcePublish == true)
    if snapshot and snapshot.accountName and C.Database then
        C.Database:UpdatePlayer(snapshot.accountName, snapshot, "local")
    end
    return snapshot
end

function Scanner:ScheduleLocalRefresh(delayMs)
    delayMs = tonumber(delayMs) or 50
    self.refreshGeneration = (self.refreshGeneration or 0) + 1
    local generation = self.refreshGeneration
    local function refreshIfCurrent()
        if generation ~= self.refreshGeneration then return end
        self:RefreshLocalCapabilities()
    end
    if zo_callLater then zo_callLater(refreshIfCurrent, delayMs) else refreshIfCurrent() end
end

function Scanner:ScheduleLoadoutRefresh()
    -- Inventory and action-bar changes arrive in bursts. Collapse the burst into
    -- one settled scan instead of rescanning three times per change.
    self:ScheduleLocalRefresh(350)
end

function Scanner:RegisterEvents()
    if not EVENT_MANAGER then return end
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(self.eventNamespace .. "Inventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId)
            if bagId == BAG_WORN then self:ScheduleLoadoutRefresh() end
        end)
    end
    if EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED then
        EVENT_MANAGER:RegisterForEvent(self.eventNamespace .. "Hotbar", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function()
            self:ScheduleLoadoutRefresh()
        end)
    end
    if EVENT_ACTION_SLOT_UPDATED then
        EVENT_MANAGER:RegisterForEvent(self.eventNamespace .. "ActionSlot", EVENT_ACTION_SLOT_UPDATED, function()
            self:ScheduleLoadoutRefresh()
        end)
    end
    if EVENT_INVENTORY_FULL_UPDATE then
        EVENT_MANAGER:RegisterForEvent(self.eventNamespace .. "InventoryFull", EVENT_INVENTORY_FULL_UPDATE, function()
            self:ScheduleLoadoutRefresh()
        end)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(self.eventNamespace .. "Activated", EVENT_PLAYER_ACTIVATED, function()
            self:ScheduleLoadoutRefresh()
        end)
    end
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED then
        EVENT_MANAGER:RegisterForEvent(self.eventNamespace .. "WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
            self:ScheduleLoadoutRefresh()
        end)
    end
    if EVENT_SKILLS_FULL_UPDATE then
        EVENT_MANAGER:RegisterForEvent(self.eventNamespace .. "SkillsFull", EVENT_SKILLS_FULL_UPDATE, function()
            self:ScheduleLoadoutRefresh()
        end)
    end
    if EVENT_SKILL_POINTS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(self.eventNamespace .. "SkillPoints", EVENT_SKILL_POINTS_CHANGED, function()
            self:ScheduleLoadoutRefresh()
        end)
    end
    -- Scribing-specific events differ between API revisions. Register any that
    -- exist and debounce them through the normal loadout refresh path.
    for _, eventName in ipairs({
        "EVENT_CRAFTED_ABILITY_UPDATED",
        "EVENT_CRAFTED_ABILITY_SCRIPT_SELECTED",
        "EVENT_CRAFTED_ABILITY_SCRIPT_CHANGED",
        "EVENT_SCRIBING_CRAFTED_ABILITY_UPDATED",
    }) do
        local eventId = rawget(_G, eventName)
        if eventId then
            EVENT_MANAGER:RegisterForEvent(self.eventNamespace .. eventName, eventId, function()
                self:ScheduleLoadoutRefresh()
            end)
        end
    end
end

function Scanner:Initialize()
    EVENT_MANAGER:UnregisterForUpdate(self.updateName)
    EVENT_MANAGER:RegisterForUpdate(self.updateName, self.scanIntervalMs, function() self:ScanGroup() end)
    self:RegisterEvents()
    self:ScanGroup()
    self.initialized = true
end
