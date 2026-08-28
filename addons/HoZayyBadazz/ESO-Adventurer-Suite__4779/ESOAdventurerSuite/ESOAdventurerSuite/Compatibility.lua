-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach
EPC.Compatibility = EPC.Compatibility or {}
local C = EPC.Compatibility

-- API 101050 is the live API this release was tested against.
-- This file does not download or modify code. It only detects the running API,
-- probes capabilities, and isolates failures so one changed API is less likely
-- to take down the whole coach.
C.testedApi = 101050
C.currentApi = 0
C.status = "UNKNOWN"
C.moduleStates = C.moduleStates or {}
C.capabilities = C.capabilities or {}
C.lastErrors = C.lastErrors or {}

local function functionExists(name)
    return type(_G[name]) == "function"
end

local function allFunctions(names)
    for i = 1, #names do
        if not functionExists(names[i]) then return false end
    end
    return true
end

function C:Initialize()
    local ok, api = pcall(function()
        if type(GetAPIVersion) == "function" then return GetAPIVersion() end
        return 0
    end)
    self.currentApi = ok and tonumber(api) or 0

    if self.currentApi == 0 then
        self.status = "UNKNOWN"
    elseif self.currentApi == self.testedApi then
        self.status = "TESTED"
    elseif self.currentApi > self.testedApi then
        self.status = "NEWER_GAME"
    else
        self.status = "OLDER_GAME"
    end

    self.capabilities = {
        CORE = allFunctions({"GetUnitName", "GetUnitLevel", "GetUnitPower", "GetItemLink"}),
        GEAR = allFunctions({"GetItemLink", "GetItemLinkSetInfo"}),
        ACTIVITIES = allFunctions({"GetNumJournalQuests", "GetJournalQuestInfo"}),
        QUEST_ROUTING = allFunctions({"GetJournalQuestInfo", "GetJournalQuestLocationInfo"}),
        QUEST_INDEX = allFunctions({"GetQuestName", "GetQuestZoneId", "GetZoneNameById"}),
        SHRINE_TRAVEL = allFunctions({"GetNumFastTravelNodes", "GetFastTravelNodeInfo", "FastTravelToNode"}),
        SOCIAL_TRAVEL = functionExists("JumpToFriend") or functionExists("JumpToGuildMember") or functionExists("JumpToGroupMember"),
        CHAMPION = allFunctions({"GetAssignableChampionBarStartAndEndSlots", "GetSlotBoundId"}),
        COMBAT = EVENT_COMBAT_EVENT ~= nil and EVENT_PLAYER_COMBAT_STATE ~= nil,
        ROLE_AUTO = functionExists("GetSelectedLFGRole"),
        UI_MODE = functionExists("SetGameCameraUIMode") or (SCENE_MANAGER and type(SCENE_MANAGER.SetInUIMode) == "function") or false,
        INVENTORY = allFunctions({"GetBagSize", "GetItemLink", "GetNumBagUsedSlots"}),
        RESEARCH = allFunctions({"GetNumSmithingResearchLines", "GetSmithingResearchLineInfo", "GetSmithingResearchLineTraitInfo"}),
        COLLECTIONS = allFunctions({"GetNextItemSetCollectionId", "GetNumItemSetCollectionSlotsUnlocked"}),
        SET_JOURNAL = allFunctions({"GetNextItemSetCollectionId", "GetItemSetName", "GetItemSetCollectionCategoryId", "GetItemSetCollectionCategoryName", "GetNumItemSetCollectionPieces", "GetItemSetCollectionPieceInfo", "GetItemSetCollectionPieceItemLink"}),
        ZONE_COMPLETION = allFunctions({"GetUnitZoneIndex", "GetNumPOIs", "GetPOIMapInfo", "GetPOIZoneCompletionType"}),
        SKYSHARDS = allFunctions({"GetNumSkyshardsInZone", "GetZoneSkyshardId", "GetSkyshardDiscoveryStatus"}),
        UNIT_FRAMES = allFunctions({"DoesUnitExist", "GetUnitName", "GetUnitPower", "GetNumBuffs", "GetUnitBuffInfo", "GetGroupSize"}),
        DUNGEON_CHEST_FINDER = allFunctions({"GetUnitRawWorldPosition", "WorldPositionToGuiRender3DPosition", "GetGameCameraInteractableActionInfo", "IsUnitInDungeon"}),
        ABILITY_OVERLAYS = allFunctions({"GetSlotTexture", "GetSlotName", "GetSlotCooldownInfo", "IsSlotUsed", "GetActiveHotbarCategory"}),
        REPAIR_COST_OVERLAY = allFunctions({"GetItemLink", "GetItemRepairCost", "GetItemCondition", "GetChargeInfoForItem"}),
        ADVANCED_STATS = allFunctions({"GetPlayerStat", "GetAdvancedStatValue"}),
        MINI_MAP = allFunctions({"GetCurrentMapId", "GetMapPlayerPosition", "GetMapNumTilesForMapId", "GetMapTileTextureForMapId"}),
        STABLE_TIMER = allFunctions({"GetTimeUntilCanBeTrained", "GetRidingStats"}),
        AUTO_MAINTENANCE = allFunctions({"GetChargeInfoForItem", "ChargeItemWithSoulGem", "GetItemCondition", "RepairItemWithRepairKit"}),
    }

    self.moduleStates = self.moduleStates or {}
    for name, available in pairs(self.capabilities) do
        if self.moduleStates[name] == nil then
            self.moduleStates[name] = available and "READY" or "UNAVAILABLE"
        elseif not available then
            self.moduleStates[name] = "UNAVAILABLE"
        end
    end
end

function C:GetApiStatus()
    return self.status, self.currentApi, self.testedApi
end

function C:GetStatusLabel()
    if self.status == "TESTED" then return "Tested / compatible" end
    if self.status == "NEWER_GAME" then return "Newer ESO API detected - compatibility not yet verified" end
    if self.status == "OLDER_GAME" then return "Older ESO API detected - compatibility not verified" end
    return "ESO API could not be detected"
end

function C:GetSummary()
    return string.format("Game API %s | Tested API %s | %s",
        tostring(self.currentApi > 0 and self.currentApi or "unknown"),
        tostring(self.testedApi), self:GetStatusLabel())
end

function C:IsCapabilityAvailable(name)
    return self.capabilities[name] == true
end

function C:DisableModule(name, err)
    name = tostring(name or "UNKNOWN")
    self.moduleStates[name] = "DEGRADED"
    if err then self.lastErrors[name] = tostring(err) end
end

function C:GetModuleState(name)
    return self.moduleStates[tostring(name or "")] or "UNKNOWN"
end

function C:Call(moduleName, object, methodName, fallback, ...)
    if not object or type(object[methodName]) ~= "function" then
        self:DisableModule(moduleName, "Missing method: " .. tostring(methodName))
        return fallback
    end

    local results = {pcall(object[methodName], object, ...)}
    local ok = table.remove(results, 1)
    if not ok then
        self:DisableModule(moduleName, results[1])
        return fallback
    end
    if self.moduleStates[moduleName] == "DEGRADED" then
        -- Keep the recorded error for diagnostics, but allow recovery if a later
        -- call succeeds after a temporary UI/game-state condition changes.
        self.moduleStates[moduleName] = "READY"
    elseif self.moduleStates[moduleName] == nil then
        self.moduleStates[moduleName] = "READY"
    end
    return unpack(results)
end

function C:InitializeModule(name, object)
    if not object or type(object.Initialize) ~= "function" then return true end
    local ok, err = pcall(object.Initialize, object)
    if not ok then
        self:DisableModule(name, err)
        return false
    end
    self.moduleStates[name] = self.moduleStates[name] == "UNAVAILABLE" and "UNAVAILABLE" or "READY"
    return true
end

function C:GetDiagnosticLines()
    local lines = { self:GetSummary() }
    local order = {
        "CORE", "GEAR", "ACTIVITIES", "QUEST_ROUTING", "QUEST_INDEX", "SHRINE_TRAVEL", "SOCIAL_TRAVEL",
        "CHAMPION", "COMBAT", "ROLE_AUTO", "UI_MODE", "INVENTORY", "RESEARCH", "COLLECTIONS", "SET_JOURNAL",
        "ZONE_COMPLETION", "SKYSHARDS", "UNIT_FRAMES", "DUNGEON_CHEST_FINDER", "ABILITY_OVERLAYS", "REPAIR_COST_OVERLAY", "ADVANCED_STATS", "MINI_MAP", "STABLE_TIMER", "AUTO_MAINTENANCE",
        "ROLE", "TRAVEL", "QUEST_FINDER", "SET_JOURNAL", "ENDGAME", "TARGET_BUILD", "ADVISOR", "MAINTENANCE", "STABLE_TIMER", "UTILITY_SUITE", "ENGINE", "UI", "EVENTS"
    }
    local seen = {}
    for i = 1, #order do
        local name = order[i]
        if not seen[name] then
            seen[name] = true
            local state = self.moduleStates[name]
            if state == nil then
                if self.capabilities[name] ~= nil then state = self.capabilities[name] and "READY" or "UNAVAILABLE"
                else state = "NOT PROBED" end
            end
            local err = self.lastErrors[name]
            if err and err ~= "" then
                if string.len(err) > 110 then err = string.sub(err, 1, 107) .. "..." end
                lines[#lines + 1] = string.format("%s: %s - %s", name, state, err)
            else
                lines[#lines + 1] = string.format("%s: %s", name, state)
            end
        end
    end
    return lines
end
