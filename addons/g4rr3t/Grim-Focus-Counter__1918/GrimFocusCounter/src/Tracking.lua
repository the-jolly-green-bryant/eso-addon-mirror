-- -----------------------------------------------------------------------------
-- Grim Focus Counter
-- Author:  g4rr3t
-- Created: Jan 28, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

--- Workaround diagnostic errors due to type mismatch
--- @alias luaindex integer
--- @alias bool boolean

local GFC = GFC
local ABAM = ACTION_BAR_ASSIGNMENT_MANAGER
local EM = EVENT_MANAGER
local SDM = SKILLS_DATA_MANAGER

--- @type integer Current number of stacks
GFC.currentStacks = 0

--- @type boolean True when Grim Focus (or one of its morphs) is slotted
GFC.skillSlotted = false

--- @type boolean True when the player is in combat
GFC.isInCombat = false

--- @type table<string, boolean> Event registration tracking
GFC.tracking = {
    combat  = false,
    changes = false,
    hotbar  = false,
}

--- @type integer|nil Ability ID that tracking is active for, nil if none
GFC.trackedAbilityId = nil

--- Check action bars for slotted skill
--- @return integer|nil abilityId Ability ID of slotted skill, nil if no ability slotted
local function getSlottedAbilityId()
    local skillData = SDM:GetSkillDataByIndices(GFC.skillType, GFC.skillLineIndex, GFC.skillIndex)
    if not skillData then
        GFC:Trace(1, "Could not get skill data when checking for slotted skill")
        return nil
    end

    local searchBars = {
        [HOTBAR_CATEGORY_PRIMARY] = "primary",
        [HOTBAR_CATEGORY_BACKUP] = "backup",
    }

    for hotbar, hotbarName in pairs(searchBars) do
        local skillSlot = ABAM:GetHotbar(hotbar):FindSlotMatchingSkill(skillData)
        if skillSlot then
            local abilityId = skillData:GetCurrentProgressionData():GetAbilityId()
            GFC:Trace(2, "Found skill on <<1>> hotbar, <<2>> (<<3>>)", hotbarName, GetAbilityName(abilityId), abilityId)
            return abilityId
        end
    end

    -- No skill matching ID slotted
    return nil
end

--- Register stack tracking for the given ability ID
--- @param abilityId integer The ability ID to track stacks for
--- @return nil
function GFC:RegisterStacksForId(abilityId)
    -- Skip updating tracking if the ability ID is already being tracked
    if self.trackedAbilityId ~= nil and self.trackedAbilityId == abilityId then return end

    local stackId = self.skills[abilityId]

    GFC:Trace(2, "Registering <<1>> (<<2>>) for stackId <<3>>", GetAbilityName(abilityId), abilityId, stackId)

    EM:RegisterForEvent(self.name .. "Stack", EVENT_EFFECT_CHANGED, self.OnEffectChanged)
    EM:AddFilterForEvent(self.name .. "Stack", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, stackId,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER
    )

    self.trackedAbilityId = abilityId
end

--- Check if Grim Focus (or one of its morphs) is slotted and register/unregister events accordingly
--- @return boolean slotted True when skill is slotted
function GFC:CheckSkillSlotted()
    local skillPurchased = IsSkillAbilityPurchased(self.skillType, self.skillLineIndex, self.skillIndex)

    -- Check if skill is purchased
    if not skillPurchased then
        GFC:Trace(2, "Skill not purchased")
        return false
    end

    local abilityId = getSlottedAbilityId()

    -- If skill is slotted
    if abilityId ~= nil then
        GFC:Trace(1, "Skill <<1>> (<<2>>) slotted, enabling", GetAbilityName(abilityId), abilityId)
        self:RegisterStacksForId(abilityId)
        return true
    end

    GFC:Trace(1, "Skill not slotted, disabling")
    self:UnregisterStacks()
    return false
end

--- Callback when hotbars have been updated, e.g. skill (un)slotted
--- @return nil
local function hotbarsUpdated()
    GFC:Trace(2, "Hotbars Updated!")
    GFC:OnPlayerChanged()
end

--- Register events for when tracking is enabled
--- @return nil
function GFC:RegisterTrackingEvents()
    -- Combat enter/exit events
    if self.preferences.hideOutOfCombat then
        self:RegisterCombatEvent()
    end

    if self.tracking.changes then return end

    local function onPlayerChanged()
        self:OnPlayerChanged()
    end

    -- Zone change or load
    EM:RegisterForEvent(self.name .. "PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, onPlayerChanged)
    EM:RegisterForEvent(self.name .. "ZONE_UPDATE", EVENT_ZONE_UPDATE, onPlayerChanged)

    -- Dead or alive
    EM:RegisterForEvent(self.name .. "PlayerDead", EVENT_PLAYER_DEAD, onPlayerChanged)
    EM:RegisterForEvent(self.name .. "PlayerAlive", EVENT_PLAYER_ALIVE, onPlayerChanged)

    self.tracking.changes = true
end

--- Unregister events for when tracking is disabled
--- @return nil
function GFC:UnregisterTrackingEvents()
    self:UnregisterCombatEvent()

    if not self.tracking.changes then return end

    EM:UnregisterForEvent(self.name .. "PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
    EM:UnregisterForEvent(self.name .. "ZONE_UPDATE", EVENT_ZONE_UPDATE)
    EM:UnregisterForEvent(self.name .. "PlayerDead", EVENT_PLAYER_DEAD)
    EM:UnregisterForEvent(self.name .. "PlayerAlive", EVENT_PLAYER_ALIVE)

    self.tracking.changes = false
end

--- Register monitoring events that determine when the skill is active
--- @return nil
function GFC:RegisterHotbarEvents()
    if self.tracking.hotbar then return end

    EM:RegisterForEvent(self.name .. "HotbarUpdated", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, hotbarsUpdated)
    self.tracking.hotbar = true
end

--- Unregister tracking for hotbar events
--- @return nil
function GFC:UnregisterHotbarEvents()
    if not self.tracking.hotbar then return end

    EM:UnregisterForEvent(self.name .. "HotbarUpdated", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    self.tracking.hotbar = false
end

--- Register combat state tracking events
--- @return nil
function GFC:RegisterCombatEvent()
    -- Register start/end combat events
    if self.tracking.combat then return end

    EM:RegisterForEvent(self.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, function() self:OnPlayerChanged() end)
    self.tracking.combat = true
end

--- Unregister combat state tracking events
--- @return nil
function GFC:UnregisterCombatEvent()
    -- Register start/end combat events
    if not self.tracking.combat then return end

    EM:UnregisterForEvent(self.name .. "COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
    self.tracking.combat = false
end

--- Unregister stack tracking events
--- @return nil
function GFC:UnregisterStacks()
    if self.trackedAbilityId == nil then return end

    GFC:Trace(2, "Unregistering stacks")

    EM:UnregisterForEvent(GFC.name .. 'Stack', EVENT_EFFECT_CHANGED)
    self.trackedAbilityId = nil
end

--- Set the in combat state
--- @param inCombat boolean True when in combat
--- @return nil
function GFC:SetInCombat(inCombat)
    self:Trace(2, "In Combat: <<1>>", tostring(inCombat))

    self.isInCombat = inCombat
end

--- Get the current number of stacks active
--- @return integer stackCount Current number of stacks
function GFC:GetBuffStacks()
    for i = 1, GetNumBuffs("player") do
        -- Fix diagnostic for stackCount type
        local _, _, _, _, stackCount --[[ @as integer ]], _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        for ability, stackId in pairs(GFC.skills) do
            local abilityName = GetAbilityName(ability)
            GFC:Trace(3, "Checking for <<1>> (<<2>>)", abilityName, ability)
            if stackId == abilityId then
                -- Fix diagnostic for GetUnitBuffInfo() returns
                return stackCount --[[@as integer]]
            end
        end
    end

    return 0
end

--- Update various states when something about the player changed
--- @return nil
function GFC:OnPlayerChanged()
    self:SetInCombat(IsUnitInCombat("player") --[[@as boolean]])

    local slotted = self:CheckSkillSlotted()

    self.skillSlotted = slotted

    if slotted then
        self:Enable()
        self.currentStacks = self:GetBuffStacks()
    else
        self:Disable()
        self.currentStacks = 0
    end

    if self.preferences.hideOutOfCombat and not self.isInCombat then
        self:RemoveSceneFragments()
    elseif not slotted and not self.preferences.alwaysShow then
        self:RemoveSceneFragments()
    else
        self:AddSceneFragments()
    end

    self:UpdateUI()
end

--- Handle stack effect changes
--- @param changeType integer
--- @param effectName string
--- @param stackCount integer
--- @param effectAbilityId integer
--- @return nil
function GFC.OnEffectChanged(_, changeType, _, effectName, _, _, _, stackCount, _, _, _, _, _, _, _, effectAbilityId)
    GFC:Trace(3, "Effect changed: " .. effectName .. " (" .. effectAbilityId .. ")")

    -- If we have a stack
    GFC:Trace(2, "Stack for Ability ID: " .. effectAbilityId)

    if stackCount == 5 and changeType == EFFECT_RESULT_FADED then
        GFC:Trace(2, "Used proc: <<1>> (<<2>>) with stacks <<3>>", effectName, effectAbilityId, stackCount)
        GFC.currentStacks = 0
    else
        GFC:Trace(1, "Stack #<<1>> (effect changed)", GFC.currentStacks)
        GFC.currentStacks = stackCount
    end

    GFC:UpdateUI()
end

--- Enable tracking
--- @return nil
function GFC:Enable()
    self:RegisterTrackingEvents()
end

--- Disable tracking
--- @return nil
function GFC:Disable()
    self:UnregisterTrackingEvents()
    self:UnregisterStacks()
end

--- Register event tracking without a filter
--- @return nil
function GFC.RegisterUnfilteredEvents()
    EM:RegisterForEvent(GFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED, GFC.OnEffectChanged)
    GFC:Trace(3, "Registering unfiltered complete")
end

--- Unregister event tracking without a filter
--- @return nil
function GFC.UnregisterUnfilteredEvents()
    EM:UnregisterForEvent(GFC.name .. "UNFILTERED", EVENT_EFFECT_CHANGED)
    GFC:Trace(3, "Unregistering unfiltered complete")
end
