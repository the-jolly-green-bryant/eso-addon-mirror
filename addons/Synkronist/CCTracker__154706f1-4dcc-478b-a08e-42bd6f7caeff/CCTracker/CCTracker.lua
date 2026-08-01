-- CCTracker.lua
-- CCTracker v1.0 for ESO Update 46 (June 2025)
-- Core logic for CC tracking, integrated with CCTrackerFloats.lua for UI

local EM = EVENT_MANAGER
local LAM = LibAddonMenu2

CCTracker = CCTracker or {
    name = "CCTracker",
    timerActive = false,
    version = "v1.0.0",
    activeEffects = {},
    status = {
        alive = 0,
        dead = 0,
        immunityToImmobilization = false,
        zone = "",
        subzone = "",
        playerDeactivated = 0,
    },
    ccActive = {},
    ccAdded = { combatEvents = 0, effectsChanged = 0, endTimeUpdated = 0 },
    currentCharacterName = "",
    constants = {
        breakFree = 16565,
        rollDodge = { abilityId = 28549, buffId = 28549 },
        ignore = {},
        possibleRoots = {},
        definiteRoots = {},
        definiteSnares = {},
        exceptions = {},
    },
    ccVariables = {
        ["charm"] = { icon = "/esoui/art/icons/ability_debuff_charm.dds", tracked = true, res = 3510, active = false, name = "Charm" },
        [32] = { icon = "/esoui/art/icons/ability_debuff_disorient.dds", tracked = true, res = 2340, active = false, name = "Disoriented" },
        [27] = { icon = "/esoui/art/icons/ability_debuff_fear.dds", tracked = true, res = 2320, active = false, name = "Fear" },
        [17] = { icon = "/esoui/art/icons/ability_debuff_knockback.dds", tracked = true, res = 2475, active = false, name = "Knockback" },
        [48] = { icon = "/esoui/art/icons/ability_debuff_levitate.dds", tracked = true, res = 2400, active = false, name = "Levitating" },
        [53] = { icon = "/esoui/art/icons/ability_debuff_offbalance.dds", tracked = true, res = 2440, active = false, name = "Offbalance" },
        ["root"] = { icon = "/esoui/art/icons/ability_debuff_root.dds", tracked = true, res = 2480, active = false, name = "Root" },
        [11] = { icon = "/esoui/art/icons/ability_debuff_silence.dds", tracked = true, res = 2010, active = false, name = "Silence" },
        [10] = { icon = "/esoui/art/icons/ability_debuff_snare.dds", tracked = true, res = 2025, active = false, name = "Snare" },
        [33] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", tracked = true, res = 2470, active = false, name = "Stagger" },
        [9] = { icon = "/esoui/art/icons/ability_debuff_stun.dds", tracked = true, res = 2020, active = false, name = "Stun" },
    },
    couldBeRoot = {},
    couldJustBeSnare = {},
}

-- Saved Variables module setup
CCTrackerSettings = CCTrackerSettings or {}
function CCTrackerSettings:Initialize()
    self.savedVars = ZO_SavedVars:New("CCTrackerSV", 1, nil, {
        baseX = 500,
        baseY = 520,
        iconScale = 1.0,
    })
end

-- Initialize SavedVariables on addon load
EVENT_MANAGER:RegisterForEvent("CCTrackerSettingsInit", EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if addOnName == "CCTracker" then
        CCTrackerSettings:Initialize()
    end
end)

function CCTracker:Init()
    if self.started then return end
    self.started = true
    self.currentCharacterName = GetUnitName("player") or "Unknown"
    self.status.alive = GetFrameTimeMilliseconds()
    self.status.zone = self:CropZOSString(GetPlayerActiveZoneName())
    self.status.subzone = self:CropZOSString(GetPlayerActiveSubzoneName())
    self:CheckForCCRegister()
    self:CreateSettingsWindow()
end

function CCTracker:CheckForCCRegister()
    for _, check in pairs(self.ccVariables) do
        if check.tracked then
            self:Register()
            break
        end
    end
end

function CCTracker:Register()
    EM:RegisterForEvent(self.name .. "CombatEvents", EVENT_COMBAT_EVENT, function(...) self:HandleCombatEvents(...) end)
    EM:RegisterForEvent(self.name .. "EffectsChanged", EVENT_EFFECT_CHANGED, function(...) self:HandleEffectsChanged(...) end)
    EM:RegisterForEvent(self.name .. "PlayerDeactivated", EVENT_PLAYER_DEACTIVATED, function() self.status.zone = self:CropZOSString(GetPlayerActiveZoneName()); self.status.subzone = self:CropZOSString(GetPlayerActiveSubzoneName()) end)
    EM:RegisterForEvent(self.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        local zName = self:CropZOSString(GetPlayerActiveZoneName())
        local sZName = self:CropZOSString(GetPlayerActiveSubzoneName())
        if zName ~= self.status.zone or sZName ~= self.status.subzone then self:ClearCCThatIsNotBuff() end
    end)
    EM:RegisterForEvent(self.name .. "PlayerAlive", EVENT_PLAYER_ALIVE, function() self.status.alive = GetFrameTimeMilliseconds(); self.status.dead = 0 end)
    EM:RegisterForEvent(self.name .. "PlayerDead", EVENT_PLAYER_DEAD, function() self.status.alive = 0; self.status.dead = GetFrameTimeMilliseconds(); self:ClearAllCC() end)
    EM:RegisterForEvent(self.name .. "WeaponPairLockChanged", EVENT_WEAPON_PAIR_LOCK_CHANGED, function(_, isLocked)
        if self.ccVariables[17].active and not isLocked then
            local cache = {}
            local time = GetFrameTimeMilliseconds()
            for _, entry in ipairs(self.ccActive) do
                if entry.type ~= 17 then table.insert(cache, entry)
                elseif entry.isSubeffect then self:ClearSubeffects(entry.id, time) end
            end
            self.ccActive = cache
            self:CCChanged()
        end
    end)
    EM:RegisterForEvent(self.name .. "StunStateChanged", EVENT_PLAYER_STUNNED_STATE_CHANGED, function(_, stunned) if not stunned then self:BreakFreeDetected() end end)
    self.registered = true
end

function CCTracker:Unregister()
    EM:UnregisterForEvent(self.name .. "CombatEvents", EVENT_COMBAT_EVENT)
    EM:UnregisterForEvent(self.name .. "EffectsChanged", EVENT_EFFECT_CHANGED)
    EM:UnregisterForEvent(self.name .. "PlayerDeactivated", EVENT_PLAYER_DEACTIVATED)
    EM:UnregisterForEvent(self.name .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
    EM:UnregisterForEvent(self.name .. "PlayerAlive", EVENT_PLAYER_ALIVE)
    EM:UnregisterForEvent(self.name .. "PlayerDead", EVENT_PLAYER_DEAD)
    EM:UnregisterForEvent(self.name .. "WeaponPairLockChanged", EVENT_WEAPON_PAIR_LOCK_CHANGED)
    EM:UnregisterForEvent(self.name .. "StunStateChanged", EVENT_PLAYER_STUNNED_STATE_CHANGED)
    self.registered = false
end

function CCTracker:HandleCombatEvents(_, res, err, aName, _, _, sName, _, tName, _, hVal, _, _, _, _, _, aId, _)
    local time = GetFrameTimeMilliseconds()
    if self.status.alive == 0 or (self.status.dead ~= 0 and self.status.dead <= time) then return end
    if self:CropZOSString(tName) == self.currentCharacterName then
        local aName = self:CropZOSString(aName)
        if aId == self.constants.breakFree and self.currentCharacterName == self:CropZOSString(sName) and self:DoesBreakFreeWork() then
            self:BreakFreeDetected(); return
        elseif aId == self.constants.rollDodge.abilityId and self.currentCharacterName == self:CropZOSString(sName) and res == ACTION_RESULT_EFFECT_GAINED then
            self:RolldodgeDetected(); return
        elseif self.constants.ignore[aId] then return end
        self:ClearOutdatedLists(time, "Combat events")
        if res == ACTION_RESULT_EFFECT_FADED then
            if aId == self.constants.rollDodge.buffId then self.status.immunityToImmobilization = false; return end
            if self.activeEffects[aId] and self.activeEffects[aId].subeffects then
                for _, id in ipairs(self.activeEffects[aId].subeffects) do
                    local inActiveList, number = self:AbilityInList(id, self.ccActive)
                    if inActiveList then self:SnareRootCheck(id, number, aName); if self.ccActive[number].isSubeffect then self:ClearSubeffects(id, time) end; table.remove(self.ccActive, number); self:CCChanged() end
                end
                self.activeEffects[aId] = nil; return
            else
                local inList, num = self:AbilityInList(aId, self.ccActive)
                if inList then self:SnareRootCheck(aId, num, aName); if self.ccActive[num].isSubeffect then self:ClearSubeffects(aId, time) end; table.remove(self.ccActive, num); self:CCChanged(); return end
            end
        elseif res == ACTION_RESULT_EFFECT_GAINED then
            if aId == self.constants.rollDodge.buffId then self.status.immunityToImmobilization = true; return end
            if not self.activeEffects[aId] then self.activeEffects[aId] = { name = aName, time = time } end; return
        elseif not err then
            if res == ACTION_RESULT_SNARED and not self:AbilityInList(aId, self.constants.definiteSnares) and self:IsRoot(aId) then res = 2480; if self.status.immunityToImmobilization then return end end
            for ccType, check in pairs(self.ccVariables) do
                if check.res == res and check.tracked and not self.constants.exceptions[aId] then
                    local isSubeffect = false
                    for eId, entry in pairs(self.activeEffects) do if entry.time == time then if not entry.subeffects then entry.subeffects = {} end; table.insert(entry.subeffects, aId); isSubeffect = true end end
                    local newAbility = { id = aId, type = ccType, startTime = time, endTime = 0, cacheId = 0, isSubeffect = isSubeffect }
                    local inList, num = self:AbilityInList(aId, self.ccActive)
                    if not inList then if not self.ccVariables[ccType].active then check.playSound = true end; table.insert(self.ccActive, newAbility); self.ccAdded.combatEvents = self.ccAdded.combatEvents + 1; if check.playSound then self:CCChanged(check.playSound) end end
                    if self.SV and self.SV.settings and self.SV.settings.ccIgnoreLinks then self:PrintIgnoreLink(aName, aId) end
                    break
                end
            end
        end
    end
end

function CCTracker:HandleEffectsChanged(_, changeType, _, eName, unitTag, beginTime, endTime, _, _, _, buffType, abilityType, _, unitName, _, aId, sType)
    local time = GetFrameTimeMilliseconds()
    if not (unitTag == "player" or unitName == self.currentCharacterName) or self.status.alive == 0 or (self.status.dead ~= 0 and self.status.dead <= time) then return end
    if self.constants.ignore[aId] then return end
    local eName = self:CropZOSString(eName)
    local playCCSound, ccChanged = false, false
    self:ClearOutdatedLists(time, "Effect changed")
    if IsUnitDeadOrReincarnating("player") then self:ClearAllCC(); return end
    if changeType == EFFECT_RESULT_FADED or changeType == EFFECT_RESULT_ITERATION_END then
        if aId == self.constants.rollDodge.buffId then self.status.immunityToImmobilization = false; return end
        local inList, num = self:AbilityInList(aId, self.ccActive)
        if inList then self:SnareRootCheck(aId, num, eName); table.remove(self.ccActive, num); ccChanged = true end
    elseif changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_FULL_REFRESH or changeType == EFFECT_RESULT_ITERATION_BEGIN then
        if aId == self.constants.rollDodge.buffId then self.status.immunityToImmobilization = true; return end
        local inList, num = self:AbilityInList(aId, self.ccActive)
        if inList then self.ccActive[num].endTime = endTime * 1000; self.ccAdded.endTimeUpdated = self.ccAdded.endTimeUpdated + 1
        else
            if abilityType == ABILITY_TYPE_SNARE and not self:AbilityInList(aId, self.constants.definiteSnares) and self:IsRoot(aId) then abilityType = "root"; if self.status.immunityToImmobilization then return end end
            if self.ccVariables[abilityType] and self.ccVariables[abilityType].tracked then
                local ending = ((endTime - beginTime ~= 0) and endTime) or 0
                local newAbility = { id = aId, type = abilityType, startTime = time, endTime = ending * 1000, cacheId = 0, isSubeffect = false }
                if not self.ccVariables[abilityType].active then playCCSound, ccChanged = true, true end
                table.insert(self.ccActive, newAbility)
                self.ccAdded.effectsChanged = self.ccAdded.effectsChanged + 1
                if self.SV and self.SV.settings and self.SV.settings.ccIgnoreLinks then self:PrintIgnoreLink(eName, aId) end
            end
        end
        if ccChanged then self:CCChanged(playSound) end
    end
end

function CCTracker:ClearOutdatedLists(time, context)
    -- Implement if needed
end

function CCTracker:CreateSettingsWindow()
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "CCTracker",
        displayName = "|cFFD700CCTracker|r",
        author = "Synkronist",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.settingsPanel = LAM:RegisterAddonPanel("CCTrackerSettings", panelData)

    local optionsData = {
        {
            type = "slider",
            name = "Base X Offset",
            tooltip = "Adjust the horizontal position of the CCTracker icons.",
            min = 0,
            max = 1920,
            step = 10,
            getFunc = function() return CCTrackerSettings.savedVars.baseX end,
            setFunc = function(value)
                CCTrackerSettings.savedVars.baseX = value
                CCTracker:UpdateIconPositions()
            end,
            default = 500,
        },
        {
            type = "slider",
            name = "Base Y Offset",
            tooltip = "Adjust the vertical position of the CCTracker icons.",
            min = 0,
            max = 1080,
            step = 10,
            getFunc = function() return CCTrackerSettings.savedVars.baseY end,
            setFunc = function(value)
                CCTrackerSettings.savedVars.baseY = value
                CCTracker:UpdateIconPositions()
            end,
            default = 520,
        },
        {
            type = "slider",
            name = "Icon Scale",
            tooltip = "Adjust the size of the CCTracker icons (0.5x to 2.0x).",
            min = 0.5,
            max = 2.0,
            step = 0.1,
            getFunc = function() return CCTrackerSettings.savedVars.iconScale end,
            setFunc = function(value)
                CCTrackerSettings.savedVars.iconScale = value
                CCTracker:UpdateIconPositions()
            end,
            default = 1.0,
        },
    }

    LAM:RegisterOptionControls("CCTrackerSettings", optionsData)
end

function CCTracker:OnAddOnLoaded(eventCode, addOnName)
    if addOnName == self.name then
        self:Init()
        EM:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(CCTracker.name, EVENT_ADD_ON_LOADED, function(eventCode, addOnName) CCTracker:OnAddOnLoaded(eventCode, addOnName) end)
