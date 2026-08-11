local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name = "SkillBlocker",

    EquippedSkills = {},
    BlockableSkills = {},
    BlockableBuffs = {},
    PlayerBuffs = {},
    ShouldBlock = {},
    BlockedSkills = {},
    BlockedModules = {},

    isUpdateLoop = false,

    FirstBlockTime = {},
    LastBlockTime = {},
    BlockCount = {},
    OverrideTime = {},

    Default = {
        enableDisplayIcon = true,
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
end

function Module:CustomDisable()
    self:StopSkillBlockerLoop()
end

----------------------------------------------------------------------------------------------------
-- EQUIPPED SKILLS
----------------------------------------------------------------------------------------------------
function Module:UpdateEquippedSkills()
    ZO_ClearTable(self.EquippedSkills)

    local function AddAbilityId(abilityId)
        if abilityId > 0 then
            self.EquippedSkills[abilityId] = true
        end
    end

    for i = 3, 8 do
        AddAbilityId(GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY))
        AddAbilityId(GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP))
    end
end

----------------------------------------------------------------------------------------------------
-- PREVENT DOUBLE CAST LOOP
----------------------------------------------------------------------------------------------------
function Module:StartSkillBlockerLoop()
    if not self.isUpdateLoop then
        self.isUpdateLoop = true
        EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "HandleSkillBlocker", 100, function() self:HandleSkillBlocker() end)
    end
end

function Module:StopSkillBlockerLoop()
    if self.isUpdateLoop then
        self.isUpdateLoop = false
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "HandleSkillBlocker")

        if LibSkillBlocker then
            for abilityId, _ in pairs(self.BlockedSkills) do
                LibSkillBlocker.UnregisterSkillBlock(CC.NAME .. tostring(abilityId), abilityId)
            end
        end

        ZO_ClearTable(self.PlayerBuffs)
        ZO_ClearTable(self.ShouldBlock)
        ZO_ClearTable(self.BlockedSkills)
        ZO_ClearTable(self.FirstBlockTime)
        ZO_ClearTable(self.LastBlockTime)
        ZO_ClearTable(self.OverrideTime)
        ZO_ClearTable(self.BlockCount)
    end
end

----------------------------------------------------------------------------------------------------
-- HANDLE BLOCK
----------------------------------------------------------------------------------------------------
function Module:HandleSkillBlocker()
    -- YEAH YEAH I KNOW.. IT'S IN THE DEPENDENCIES. BUT I MIGHT CHANGE THAT.
    if not LibSkillBlocker then return end

    local _, worldX, worldY, worldZ = GetUnitRawWorldPosition("player")
    local cameraX, _, cameraZ = CC.GetCameraTargetPosition(worldY, 0)

    local currentTime = GetGameTimeMilliseconds()

    ZO_ClearTable(self.ShouldBlock)
    ZO_ClearTable(self.BlockedModules)

    local hasProtectedTextures = false

    -- CHECK GROUND EFFECTS
    for _, Effect in pairs(CC.DisplayEffect.TrackedEffects) do
        if Effect.isActive then
            local ID = Effect.skillId
            local SkillData = CC.SkillData[ID]

            if SkillData and SkillData.moduleName and SkillData.name then
                local moduleName = SkillData.moduleName
                local skillName = SkillData.name
                local SourceModule = CC[moduleName]

                if SourceModule and SourceModule.SkillBlocker and SourceModule.SkillBlocker[skillName] then
                    local isBlockerEnabled = CC.SV[moduleName].enableSkillBlocker

                    if isBlockerEnabled then
                        hasProtectedTextures = true

                        local checkX, checkZ
                        local isValid = true

                        if SkillData.type == CC.SKILL_TYPE_FIXED then
                            checkX, checkZ = worldX, worldZ
                        else
                            checkX, checkZ = cameraX, cameraZ
                            if not checkX or not checkZ then isValid = false end
                        end

                        if isValid then
                            local isInside = false
                            local dx = checkX - Effect.TX
                            local dz = checkZ - Effect.TZ

                            -- SQUARE AOES
                            if Effect.targetWidth ~= Effect.targetHeight then
                                local cosY = math.cos(-Effect.RY)
                                local sinY = math.sin(-Effect.RY)

                                local localX = (dx * cosY) - (dz * sinY)
                                local localZ = (dx * sinY) + (dz * cosY)

                                local halfWidth = SkillData.width * 50
                                local halfHeight = SkillData.height * 50

                                if localX > -halfWidth and localX < halfWidth and localZ > -halfHeight and localZ < halfHeight then
                                    isInside = true
                                end

                            -- CIRCLE AOES LIKE STANDARD, COLOSSUS
                            else
                                local distanceSquared = (dx * dx) + (dz * dz)
                                local radius = math.min(SkillData.width, SkillData.height) * 50

                                if distanceSquared <= (radius * radius) then
                                    isInside = true
                                end
                            end

                            if isInside then
                                self.BlockedModules[moduleName] = true
                            end
                        end
                    end
                end
            end
        end
    end

    for buffId, expireTime in pairs(self.PlayerBuffs) do
        if expireTime > 0 and currentTime > expireTime then
            self.PlayerBuffs[buffId] = nil
        else
            local SkillData = CC.SkillData[buffId]
            if SkillData and SkillData.moduleName and SkillData.name then
                local moduleName = SkillData.moduleName
                local skillName = SkillData.name
                local SourceModule = CC[moduleName]

                -- MODULE SKILLBLOCKER TABLE
                if SourceModule and SourceModule.SkillBlocker and SourceModule.SkillBlocker[skillName] then
                    local isBlockerEnabled = CC.SV[moduleName].enableSkillBlocker
                    if isBlockerEnabled then
                        self.BlockedModules[moduleName] = true
                    end
                end
            end
        end
    end

    -- BLOCK EQUIPPED SKILLS
    for equippedId, _ in pairs(self.EquippedSkills) do
        local SkillData = CC.SkillData[equippedId]

        if SkillData and SkillData.moduleName and SkillData.name then
            local moduleName = SkillData.moduleName
            local skillName = SkillData.name

            if self.BlockedModules[moduleName] then
                local SourceModule = CC[moduleName]

                if SourceModule and SourceModule.SkillBlocker and SourceModule.SkillBlocker[skillName] then
                    local isImmune = false
                    if self.OverrideTime[equippedId] and currentTime < self.OverrideTime[equippedId] then
                        isImmune = true
                    end

                    if not isImmune then
                        self.ShouldBlock[equippedId] = true
                    end

                    -- SPECIAL.. INSTANT BLOOM AND SH!T
                    for _, abilityId in ipairs(SourceModule.SkillBlocker[skillName]) do
                        local isFlipImmune = false
                        if self.OverrideTime[abilityId] and currentTime < self.OverrideTime[abilityId] then
                            isFlipImmune = true
                        end

                        if not isFlipImmune then
                            self.ShouldBlock[abilityId] = true
                        end
                    end
                end
            end
        end
    end

    -- ADD NEW SKILL TO BLOCKER
    for abilityId, _ in pairs(self.ShouldBlock) do
        if not self.BlockedSkills[abilityId] then
            LibSkillBlocker.RegisterSkillBlock(CC.NAME .. tostring(abilityId), abilityId, function(slot, ability) return self:CheckOverride(slot, ability) end, false)
            --CC.DisplayIcon:TriggerAnimation(abilityId)
        end
        self.BlockedSkills[abilityId] = currentTime + 2000
    end

    -- REMOVE OLD FROM LIST / FROM BLOCKER
    for abilityId, timeoutTime in pairs(self.BlockedSkills) do
        if not self.ShouldBlock[abilityId] or currentTime > timeoutTime then
            LibSkillBlocker.UnregisterSkillBlock(CC.NAME .. tostring(abilityId), abilityId)
            self.BlockedSkills[abilityId] = nil

            self.FirstBlockTime[abilityId] = nil
            self.LastBlockTime[abilityId] = nil
            self.BlockCount[abilityId] = nil
            self.OverrideTime[abilityId] = nil
        end
    end

    -- END LOOP WHEN THERE IS NOTHING TO CARE ABOUT
    local hasBlockedSkills = not ZO_IsTableEmpty(self.BlockedSkills)
    local hasPlayerBuffs = not ZO_IsTableEmpty(self.PlayerBuffs)

    if not hasProtectedTextures and not hasPlayerBuffs and not hasBlockedSkills then
        self:StopSkillBlockerLoop()
    end
end

----------------------------------------------------------------------------------------------------
-- BLOCK OVERRIDE
----------------------------------------------------------------------------------------------------
function Module:CheckOverride(slotNum, abilityId)
    local currentTime = GetGameTimeMilliseconds()

    local immunityEnd = self.OverrideTime[abilityId] or 0
    if currentTime < immunityEnd then return false end -- ALLOW

    local lastBlockTime = self.LastBlockTime[abilityId] or 0
    local firstBlockTime = self.FirstBlockTime[abilityId] or 0
    local blockCount = self.BlockCount[abilityId] or 0

    local passedTimeLast = currentTime - lastBlockTime
    local passedTimeFirst = currentTime - firstBlockTime

    if passedTimeLast < 150 then return true end
    if blockCount > 0 and passedTimeFirst > 1500 then blockCount = 0 end

    blockCount = blockCount + 1
    self.LastBlockTime[abilityId] = currentTime

    if blockCount == 1 then
        self.FirstBlockTime[abilityId] = currentTime
        self.BlockCount[abilityId] = 1
        CC.DisplayIcon:TriggerAnimation(abilityId)
        return true -- BLOCK
    elseif blockCount == 2 then
        self.BlockCount[abilityId] = 2
        return true -- BLOCK
    else
        self.OverrideTime[abilityId] = currentTime + 500
        self.LastBlockTime[abilityId] = 0
        self.FirstBlockTime[abilityId] = 0
        self.BlockCount[abilityId] = 0

        CC.Debug("|c00FF00SkillBlocker override!|r")
        return false -- DONT BLOCK
    end
end

----------------------------------------------------------------------------------------------------
-- MODULE REGISTRATION
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)