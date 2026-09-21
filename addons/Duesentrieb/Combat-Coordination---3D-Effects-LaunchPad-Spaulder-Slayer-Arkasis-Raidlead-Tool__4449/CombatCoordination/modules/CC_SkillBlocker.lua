local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "SkillBlocker",
    menuName  = "SKILL BLOCKER",
    iconPath  = "/esoui/art/icons/ability_warrior_015.dds",
    menuLayer = 0,

    isPreHooked = false,
    isUpdateLoop = false,

    EquippedSkills = {},
    BlockableSkills = {},
    BlockableBuffs = {},
    PlayerBuffs = {},
    ShouldBlock = {},
    BlockedSkills = {},
    BlockedModules = {},
    PermanentBlocked = {},

    FirstBlockTime = {},
    LastBlockTime = {},
    BlockCount = {},
    OverrideTime = {},

    Default = {
        enablePermanentBlocker = true,
        enablePermanentOverride = false,
        permanentBlockList = "",
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CUSTOM ENABLE / DISABLE
----------------------------------------------------------------------------------------------------
function Module:CustomEnable()
    self:ParsePermanentBlockList()
    if not self.isPreHooked then
        self:RegisterPreHook()
        self.isPreHooked = true
    end
end

function Module:CustomDisable()
    self:StopSkillBlockerLoop()
end

----------------------------------------------------------------------------------------------------
-- SCRIBING SUPPORT
----------------------------------------------------------------------------------------------------
function Module:GetAbilityIdFromSlotNum(slotNum)
    local abilityId = GetSlotBoundId(slotNum)
    if GetSlotType(slotNum) == ACTION_TYPE_CRAFTED_ABILITY then
        abilityId = GetAbilityIdForCraftedAbilityId(abilityId)
    end
    return abilityId
end

----------------------------------------------------------------------------------------------------
-- PARSE PERMANENT LIST
----------------------------------------------------------------------------------------------------
function Module:ParsePermanentBlockList()
    ZO_ClearTable(self.PermanentBlocked)
    if not self.SV.enablePermanentBlocker then return end

    local blockString = self.SV.permanentBlockList or ""
    for abilityString in string.gmatch(blockString, "%d+") do
        local abilityId = tonumber(abilityString)
        if abilityId then
            self.PermanentBlocked[abilityId] = true
        end
    end
end

----------------------------------------------------------------------------------------------------
-- PRE HOOK
----------------------------------------------------------------------------------------------------
function Module:RegisterPreHook()
    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
        if ZO_IsTableEmpty(self.BlockedSkills) and ZO_IsTableEmpty(self.PermanentBlocked) then return false end

        -- TRACEBACK
        local tracebackString = debug.traceback()
        local slotString = tracebackString:match("keybind = \".*ACTION_BUTTON_(%d)")
        local slotNum = tonumber(slotString)

        if slotNum then
            local abilityId = self:GetAbilityIdFromSlotNum(slotNum)

            if abilityId then
                -- CHECK PERMANENT BLOCK
                if self.PermanentBlocked[abilityId] then
                    if self.SV.enablePermanentOverride then
                        local shouldBlock = self:CheckOverride(slotNum, abilityId)

                        if shouldBlock then
                            ZO_ActionBar_OnActionButtonUp(slotNum)
                            return true
                        end

                        return false -- ALLOW CAST
                    else
                        local currentTime = GetGameTimeMilliseconds()

                        if currentTime - (self.LastBlockTime[abilityId] or 0) > 1000 then
                            CC.DisplayIcon:TriggerAnimation(abilityId)
                            self.LastBlockTime[abilityId] = currentTime
                        end

                        ZO_ActionBar_OnActionButtonUp(slotNum)
                        return true
                    end
                end

                -- CHECK DYNAMIC BLOCK
                if self.BlockedSkills[abilityId] then
                local shouldBlock = self:CheckOverride(slotNum, abilityId)

                    if shouldBlock then
                        ZO_ActionBar_OnActionButtonUp(slotNum)
                        return true
                    end
                end
            end
        end
        return false
    end)
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
        EVENT_MANAGER:RegisterForUpdate(CC.NAME .. "SkillBlocker_HandleSkillBlocker", 100, function() self:HandleSkillBlocker() end)
    end
end

function Module:StopSkillBlockerLoop()
    if self.isUpdateLoop then
        self.isUpdateLoop = false
        EVENT_MANAGER:UnregisterForUpdate(CC.NAME .. "SkillBlocker_HandleSkillBlocker")

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

    -- BUFFS
    for buffId, expireTime in pairs(self.PlayerBuffs) do
        if expireTime > 0 and currentTime > expireTime then
            self.PlayerBuffs[buffId] = nil
        else
            local MappedSkills = self.BlockableBuffs[buffId]
            if MappedSkills then
                for abilityId, _ in pairs(MappedSkills) do
                    local SkillData = CC.SkillData[abilityId]

                    if SkillData and SkillData.moduleName and SkillData.name then
                        local moduleName = SkillData.moduleName
                        local skillName = SkillData.name
                        local SourceModule = CC[moduleName]

                        if SourceModule and SourceModule.SkillBlocker and SourceModule.SkillBlocker[skillName] then
                            local isBlockerEnabled = CC.SV[moduleName].enableSkillBlocker
                            if isBlockerEnabled then
                                self.BlockedModules[moduleName] = true
                            end
                        end
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
            -- CC.DisplayIcon:TriggerAnimation(abilityId)
        end
        self.BlockedSkills[abilityId] = currentTime + 2000
    end

    -- REMOVE OLD FROM LIST
    for abilityId, timeoutTime in pairs(self.BlockedSkills) do
        if not self.ShouldBlock[abilityId] or currentTime > timeoutTime then
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
-- LAM2 MENU
----------------------------------------------------------------------------------------------------
function Module:GetMenuOptions()
    local menuIcon = string.format("|t%d:%d:%s|t", CC.SIZE_ICON_LAM_SM, CC.SIZE_ICON_LAM_SM, self.iconPath)

    return {
        type = "submenu",
        name = string.format("%s %s", menuIcon, CC.ColorString(self.menuName, "tier2")),
        controls = {
            { type = "header", name = CC.ColorString("PERMANENT SKILL BLOCKING", "tier3") },
            {
                type = "checkbox",
                name = "Enable Permanent Blocking",
                getFunc = function() return self.SV.enablePermanentBlocker end,
                setFunc = function(value)
                    self.SV.enablePermanentBlocker = value
                    self:ParsePermanentBlockList()
                end,
                default = self.Default.enablePermanentBlocker,
                disabled = function() return not CC.SV.enableAddon end,
            },
            {
                type = "checkbox",
                name = "Enable Override",
                tooltip = "Casting 3x within 1.5 second bypasses the protocol.",
                getFunc = function() return self.SV.enablePermanentOverride end,
                setFunc = function(value) self.SV.enablePermanentOverride = value end,
                default = self.Default.enablePermanentOverride,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enablePermanentBlocker end,
            },
            {
                type = "description",
                text = CC.ColorString("Examples:", "tier2") .. "\n- Blinding Flare (61524)\n- Camouflaged Hunter (40195)\n- Inner Light (40478)\n- Temporal Guard (103564)",
                width = "full",
            },
            {
                type = "description",
                text = "Enter skill IDs separated by commas: 61524, 40195, 40478, 103564, ...",
                width = "full",
            },
            {
                type = "editbox",
                name = "Permanent Blocked Skill IDs:",
                isMultiline = true,
		        isExtraWide = true,
                width = "full",
                getFunc = function() return self.SV.permanentBlockList end,
                setFunc = function(value)
                    self.SV.permanentBlockList = value
                    self:ParsePermanentBlockList()
                end,
                default = self.Default.permanentBlockList,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enablePermanentBlocker end,
            },
        },
    }
end

----------------------------------------------------------------------------------------------------
-- MODULE REGISTRATION
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)