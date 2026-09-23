local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "SkillBlocker",
    menuName  = "SKILL BLOCKER & OVERRIDE",
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
    LastDebugTime = {},

    Default = {
        enableModule = true,
        enablePermanentBlocker = true,
        enablePermanentOverride = false,
        permanentBlockList = "",
        enableDebug = false,

        enableFlailBlocker = false,
        enableFatecarverBlocker = false,
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
-- DEBUG
----------------------------------------------------------------------------------------------------
function Module:Debug(message)
    if not message then return end
    if not self.SV.enableDebug then return end
    d("|cFF7F00[CC " .. self.name .. " Debug]|r " .. tostring(message))
end

----------------------------------------------------------------------------------------------------
-- PRE HOOK
----------------------------------------------------------------------------------------------------
function Module:RegisterPreHook()
    ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
        local isBlockerActive = false

        if not ZO_IsTableEmpty(self.BlockedSkills) then isBlockerActive = true end
        if not ZO_IsTableEmpty(self.PermanentBlocked) then isBlockerActive = true end
        if self.SV.enableFlailBlocker then isBlockerActive = true end
        if self.SV.enableFatecarverBlocker then isBlockerActive = true end

        if not isBlockerActive and not CC.Events.SV.enableDebugAbilityUsed then return false end

        -- TRACEBACK
        local tracebackString = debug.traceback()
        local slotString = tracebackString:match("keybind = \".*ACTION_BUTTON_(%d)")
        local slotNum = tonumber(slotString)

        if slotNum then
            local abilityId = self:GetAbilityIdFromSlotNum(slotNum)

            if abilityId then
                if CC.Events.SV.enableDebugAbilityUsed then
                    local currentTime = GetGameTimeMilliseconds()
                    if currentTime - (self.LastDebugTime[abilityId] or 0) > 100 then
                        local abilityName = zo_strformat("<<1>>", GetAbilityName(abilityId))
                        d(string.format("|cFF7F00[CC Debug]|r Pressed: %s - ID: %s", abilityName, abilityId))
                        self.LastDebugTime[abilityId] = currentTime
                    end
                end

                -- ONLY DEBUG
                if not isBlockerActive then return false end

                -- CHECK FATECARVER (UNMORPHED, EXHAUSTING, PRAGMATIC)
                -- BLOCK IF CRUX < 3
                if self.SV.enableFatecarverBlocker and (abilityId == 193331 or abilityId == 193397 or abilityId == 193398) then
                    local counterCrux = 0
                    local numBuffs = GetNumBuffs("player")

                    for i = 1, numBuffs do
                        local _, _, _, _, stackCount, _, _, _, _, _, buffId = GetUnitBuffInfo("player", i)
                        if buffId == 184220 then -- CRUX EFFECT ID
                            counterCrux = stackCount or 0
                            break
                        end
                    end

                    if counterCrux < 3 then
                        local currentTime = GetGameTimeMilliseconds()

                        if currentTime - (self.LastBlockTime[abilityId] or 0) > 1000 then
                            CC.DisplayIcon:TriggerAnimation(abilityId)
                            if self.SV.enableDebug then self:Debug(zo_strformat("Blocked: <<1>>", GetAbilityName(abilityId))) end
                            self.LastBlockTime[abilityId] = currentTime
                        end

                        ZO_ActionBar_OnActionButtonUp(slotNum)
                        return true
                    end
                end

                -- CHECK FLAIL (CEPHALIARCH'S FLAIL)
                -- BLOCK IF CRUX >= 3 AND HEALTH > 50%
                if self.SV.enableFlailBlocker and abilityId == 183006 then
                    local counterCrux = 0
                    local numBuffs = GetNumBuffs("player")

                    for i = 1, numBuffs do
                        local _, _, _, _, stackCount, _, _, _, _, _, buffId = GetUnitBuffInfo("player", i)
                        if buffId == 184220 then -- CRUX EFFECT ID
                            counterCrux = stackCount or 0
                            break
                        end
                    end

                    if counterCrux >= 3 then
                        local currentHealth, maxHealth, _ = GetUnitPower("player", POWERTYPE_HEALTH)
                        local percentHealth = (maxHealth > 0) and (currentHealth / maxHealth) or 1

                        if percentHealth >= 0.5 then
                            local currentTime = GetGameTimeMilliseconds()

                            if currentTime - (self.LastBlockTime[abilityId] or 0) > 1000 then
                                CC.DisplayIcon:TriggerAnimation(abilityId)
                                if self.SV.enableDebug then self:Debug(zo_strformat("Blocked: <<1>>", GetAbilityName(abilityId))) end
                                self.LastBlockTime[abilityId] = currentTime
                            end

                            ZO_ActionBar_OnActionButtonUp(slotNum)
                            return true
                        end
                    end
                end

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
                            if self.SV.enableDebug then self:Debug(zo_strformat("Blocked Permanent: <<1>>", GetAbilityName(abilityId))) end
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
        if self.SV.enableDebug then self:Debug(zo_strformat("Blocked (Tap 1/3): <<1>>", GetAbilityName(abilityId))) end
        return true -- BLOCK
    elseif blockCount == 2 then
        self.BlockCount[abilityId] = 2
        if self.SV.enableDebug then self:Debug(zo_strformat("Blocked (Tap 2/3): <<1>>", GetAbilityName(abilityId))) end
        return true -- BLOCK
    else
        self.OverrideTime[abilityId] = currentTime + 500
        self.LastBlockTime[abilityId] = 0
        self.FirstBlockTime[abilityId] = 0
        self.BlockCount[abilityId] = 0

        if self.SV.enableDebug then self:Debug("|c00FF00Override! (Tap 3/3):|r " .. zo_strformat("<<1>>", GetAbilityName(abilityId))) end
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
        name = function()
            local stringEnable = self.SV.enableModule and "" or CC.ColorString("[OFF] ", "RD")
            return string.format("%s %s%s", menuIcon, stringEnable, CC.ColorString(self.menuName, "tier2"))
        end,
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
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },
            {
                type = "checkbox",
                name = "Enable Override",
                tooltip = "Casting 3x within 1.5 second bypasses the protocol.",
                getFunc = function() return self.SV.enablePermanentOverride end,
                setFunc = function(value) self.SV.enablePermanentOverride = value end,
                default = self.Default.enablePermanentOverride,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule or not self.SV.enablePermanentBlocker end,
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
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule or not self.SV.enablePermanentBlocker end,
            },
            {
                type = "checkbox",
                name = CC.ColorString("[Print to Chat]", "GN") .. " Pressed Ability IDs",
                tooltip = "Prints the name and ID of every pressed skill to the chat. Useful for finding the correct IDs for your permanent block list.",
                getFunc = function() return CC.Events.SV.enableDebugAbilityUsed end,
                setFunc = function(value) CC.Events.SV.enableDebugAbilityUsed = value end,
                default = CC.Events.Default.enableDebugAbilityUsed,
                disabled = function() return not CC.SV.enableAddon end,
            },

            { type = "divider" },
            {
                type = "checkbox",
                name = "Block Cephaliarchs Flail (3 Crux, Health > 50%)",
                getFunc = function() return self.SV.enableFlailBlocker end,
                setFunc = function(value) self.SV.enableFlailBlocker = value end,
                default = self.Default.enableFlailBlocker,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },
            {
                type = "checkbox",
                name = "Block Fatecarver (Crux Counter < 3)",
                getFunc = function() return self.SV.enableFatecarverBlocker end,
                setFunc = function(value) self.SV.enableFatecarverBlocker = value end,
                default = self.Default.enableFatecarverBlocker,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },

            { type = "divider" },
            {
                type = "checkbox",
                name = "Enable Debug",
                getFunc = function() return self.SV.enableDebug end,
                setFunc = function(value) self.SV.enableDebug = value end,
                default = self.Default.enableDebug,
                disabled = function() return not CC.SV.enableAddon or not self.SV.enableModule end,
            },
        },
    }
end

----------------------------------------------------------------------------------------------------
-- MODULE REGISTRATION
----------------------------------------------------------------------------------------------------
CC[Module.name] = Module
table.insert(CC.Modules, Module)