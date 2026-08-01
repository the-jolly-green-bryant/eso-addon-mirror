local addon = AssistRapidRiding --Addon#Addon

---
--@type SlotedSkill
--@field #number weaponPair
--@field #number slotNum
--@field #SkillInfo info

---
--@type SkillInfo
--@field #number skillType
--@field #number skillIndex
--@field #number abilityIndex
--@field #number abilityId
--@field #string abilityName
--@field #number progressionIndex


--========================================
--        Saved Vars
--========================================

---
--@type CoreSavedVars
local coreSavedVarsDefaults = {
    switchAtAbilitySlot = 5,
    autoSwitchWhenMounted = true,
    alwaysSwitchWhenMounted = false,
    switchBackWhenMounted = true,
    autoSwitchAgainBeforeEffectFades = true,
    secondsLeftToSwitchAgain = 1,
    soundEnabled = false,
    soundIndex = 28,
    debugLevel = 0,
    oldSlotedSkill = nil--#SlotedSkill
}
addon.AddSavedVarsDefaults(coreSavedVarsDefaults)
---
--@return #CoreSavedVars
local function SavedVars()
    return addon.SavedVars()
end
---
--@return #CoreSavedVars
local function CharacterSavedVars()
    return addon.CharacterSavedVars()
end

--========================================
--        Menu Options
--========================================

local soundChoices = {}
for k,v in pairs(SOUNDS) do
    table.insert(soundChoices, k)
end
table.sort(soundChoices)

addon.AddMenuOptions(
    --
    {
        type = "slider",
        name = addon.GetText("Switch At Ability Slot"),
        min = 1, max = 5, step = 1,
        getFunc = function() return SavedVars().switchAtAbilitySlot end,
        setFunc = function(value) SavedVars().switchAtAbilitySlot=value end,
        width = "full",
        default = coreSavedVarsDefaults.switchAtAbilitySlot,
    },
    --
    {
        type = "checkbox",
        name = addon.GetText("Auto Switch When Mounted"),
        getFunc = function() return SavedVars().autoSwitchWhenMounted end,
        setFunc = function(value) SavedVars().autoSwitchWhenMounted=value end,
        width = "full",
        default =coreSavedVarsDefaults.autoSwitchWhenMounted,
    },
    --
    {
        type = "checkbox",
        name = addon.GetText("Always Auto Switch Even Buffed"),
        getFunc = function() return SavedVars().alwaysSwitchWhenMounted end,
        setFunc = function(value) SavedVars().alwaysSwitchWhenMounted=value end,
        disabled = function() return not SavedVars().autoSwitchWhenMounted end,
        width = "full",
        default =coreSavedVarsDefaults.autoSwitchWhenMounted,
    },
    --
    {
        type = "checkbox",
        name = addon.GetText("Switch Back After Use When Mounted"),
        getFunc = function() return SavedVars().switchBackWhenMounted end,
        setFunc = function(value) SavedVars().switchBackWhenMounted=value end,
        width = "full",
        default =coreSavedVarsDefaults.switchBackWhenMounted,
    },
    --
    {
        type = "checkbox",
        name = addon.GetText("Auto Switch Again Before Effect Fades"),
        getFunc = function() return SavedVars().autoSwitchAgainBeforeEffectFades end,
        setFunc = function(value) SavedVars().autoSwitchAgainBeforeEffectFades=value end,
        width = "full",
        default =coreSavedVarsDefaults.autoSwitchAgainBeforeEffectFades,
    },
    --
    {
        type = "slider",
        name = addon.GetText("Seconds Left To Switch Again"),
        min = 0, max = 5, step = 1,
        getFunc = function() return SavedVars().secondsLeftToSwitchAgain end,
        setFunc = function(value) SavedVars().secondsLeftToSwitchAgain=value end,
        width = "full",
        disabled = function() return not SavedVars().autoSwitchAgainBeforeEffectFades end,
        default = coreSavedVarsDefaults.secondsLeftToSwitchAgain,
    },
    --
    {
        type = "checkbox",
        name = addon.GetText("Sound Enabled"),
        getFunc = function() return SavedVars().soundEnabled end,
        setFunc = function(value) SavedVars().soundEnabled = value end,
        width = "full",
        default = coreSavedVarsDefaults.soundEnabled,
    },
    --
    {
        type = "slider",
        name = addon.GetText("Sound Index"),
        --tooltip = "",
        min = 1, max = #soundChoices, step = 1,
        getFunc = function() return SavedVars().soundIndex end,
        setFunc = function(value) SavedVars().soundIndex=value; PlaySound(SOUNDS[soundChoices[value]]) end,
        width = "full",
        disabled = function() return not SavedVars().soundEnabled end,
        default = coreSavedVarsDefaults.soundIndex,
    },
    --
    --    {
    --        type = "slider",
    --        name = "Debug Level",
    --        --tooltip = "",
    --        min = 0, max = 1, step = 1,
    --        getFunc = function() return SavedVars().debugLevel end,
    --        setFunc = function(value) SavedVars().debugLevel=value end,
    --        width = "full",
    --        default = coreSavedVarsDefaults.debugLevel,
    --    },
    --
    {
        type = "description",
        text = addon.GetText("There is a hot key to switch manually."), -- or string id or function returning a string
        title = addon.GetText("Hint"), -- or string id or function returning a string (optional)
        width = "full", --or "half" (optional)
    }
)

--========================================
--        Module Define
--========================================

---
--@module Core
--@extends Addon#Class
local module = addon.AddClass("arr.Core",
    ---
    -- @callof #Core
    -- @param #Core self
    -- @return #Core
    function(self)
        self.token = 0 --#number
        self.tokenSeed = 1 --#number
        self.mounted = IsMounted() --#boolean
        self.waitRecover = false --#boolean
        self.rmSkillInfo = nil --#SkillInfo
        self.coverTime = 0 --#number
        self.progressionIndexToSkillInfo = {} --#map<#number,#SkillInfo>
        self:Listen()
        self:LoadSkillInfo()
        addon.AddExtension("core:Switch",function()
            local oss = CharacterSavedVars().oldSlotedSkill
            if oss and oss.info then
                self:Recover()
                return
            end
            self.tokenSeed = self.tokenSeed+1
            self.token=self.tokenSeed
            self:Switch(self.token,true)
        end)
    end
)--#Core
addon.AddExtension("addon:Start",function() module() end)

---
--@param #Core self
--@param #number level
function module:Debug(level, ...)
    if SavedVars().debugLevel<level then return end
    d(...)
end

---
--@param #Core self
function module:Listen()
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_MOUNTED_STATE_CHANGED, function(...) self:OnMountedStateChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ACTION_SLOT_ABILITY_USED, function(...) self:OnActionSlotAbilityUsed(...) end)
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function(...) self:OnActiveWeaponPairChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_PLAYER_ACTIVATED, function(...) self:OnPlayerActivated(...) end)
end

---
--@param #Core self
function module:LoadSkillInfo()
    if not IsPlayerActivated() then return end
    self.rmSkillInfo = nil
    self.progressionIndexToSkillInfo = {}
    local hasPrgression,rmProgressionIndex = GetAbilityProgressionXPInfoFromAbilityId(38566) -- XXX change to gallop ability id
    if not hasPrgression then return end
    for skillType = 1, GetNumSkillTypes() do
        for skillIndex = 1, GetNumSkillLines(skillType) do
            for abilityIndex = 1, math.min(7, GetNumAbilities(skillType, skillIndex)) do
                local abilityId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, false)
                local abilityName, _,_,_,_,_, progressionIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
                local info = {
                    skillType = skillType,
                    skillIndex = skillIndex,
                    abilityIndex = abilityIndex,
                    abilityId = abilityId,
                    abilityName = abilityName,
                    progressionIndex = progressionIndex,
                }--#SkillInfo
                if rmProgressionIndex == progressionIndex then
                    self.rmSkillInfo = info
                elseif progressionIndex then
                    self.progressionIndexToSkillInfo[progressionIndex] = info
                end
            end
        end
    end
end

---
--@param #Core self
--@param #number eventCode
--@param #number slotNum
function module:OnActionSlotAbilityUsed(eventCode, slotNum)
    if not IsMounted() then return end -- do not check if not mounted
    if not SavedVars().switchBackWhenMounted then return end
    local oss = CharacterSavedVars().oldSlotedSkill
    if not oss then return end
    if oss.slotNum ~= slotNum then return end
    local weaponPair = GetActiveWeaponPairInfo()
    if oss.weaponPair ~= weaponPair then return end

    self:Debug(1,"arr:OnActionSlotAbilityUsed .."..GetSlotName(slotNum))
    local abilityId = GetSlotBoundId(slotNum)
    local _,progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
    if progressionIndex == self.rmSkillInfo.progressionIndex then
        self.coverTime = GetGameTimeMilliseconds() + GetAbilityDuration(abilityId)
        if SavedVars().autoSwitchAgainBeforeEffectFades then
            self.coverTime = self.coverTime - SavedVars().secondsLeftToSwitchAgain*1000
        end
        -- recover
        self:Recover()

        -- keep on check beyond buff
        if SavedVars().autoSwitchAgainBeforeEffectFades then
            self.tokenSeed = self.tokenSeed+1
            self.token = self.tokenSeed
            self:Switch(self.token,false)
        end
        return
    end
end

---
--@param #Core self
--@param #number eventCode
--@param #number weaponPair
--@param #boolean locked
function module:OnActiveWeaponPairChanged(eventCode, weaponPair, locked)
    if self.waitRecover and CharacterSavedVars().oldSlotedSkill then
        self:Recover()
    end
end

---
--@param #Core self
--@param #number eventCode
--@param #boolean mounted
function module:OnMountedStateChanged(eventCode, mounted)
    if not SavedVars().autoSwitchWhenMounted then return end
    self.mounted = mounted
    if not mounted then
        if CharacterSavedVars().oldSlotedSkill ~= nil then
            self:Recover()
        end
        return
    end
    if SavedVars().alwaysSwitchWhenMounted then self.coverTime = 0 end
    self.tokenSeed = self.tokenSeed+1
    self.token = self.tokenSeed
    self:Switch(self.token, false)
end

---
--@param #Core self
--@param #number eventCode
function module:OnPlayerActivated(eventCode)
    self:LoadSkillInfo()
    if not IsMounted() then
        self:Recover()
    end
end

---
--@param #Core self
function module:Recover()
    self:Debug(1, 'arr.UtilRecover called')
    local oss = CharacterSavedVars().oldSlotedSkill
    if oss ~= nil then
        if IsUnitInCombat('player') then
            zo_callLater(function() self:Recover() end, 1000)
            return
        end
        local weaponPair = GetActiveWeaponPairInfo()
        if weaponPair ~= oss.weaponPair then
            self.waitRecover = true
            return
        end
        local info = oss.info;
        self:Debug(1, 'arr.UtilRecover '..' ('..info.skillType..','..info.skillIndex..','..info.abilityIndex..') abilityId:'..(info.abilityId or 'not saved'))
        SlotSkillAbilityInSlot(info.skillType, info.skillIndex, info.abilityIndex, oss.slotNum)
        CharacterSavedVars().oldSlotedSkill = nil
        self.waitRecover = false
    end
end

---
--@param #Core self
--@param #number slotNum
function module:SaveOldSlotedSkill(slotNum)
    local abilityId = GetSlotBoundId(slotNum)
    if self.rmSkillInfo.abilityId == abilityId then return end
    if GetSkillAbilityId(self.rmSkillInfo.skillType,self.rmSkillInfo.skillIndex,self.rmSkillInfo.abilityIndex,false)==abilityId then
        self.rmSkillInfo.abilityId = abilityId -- auto patch
        return
    end
    local _,progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
    local info = self.progressionIndexToSkillInfo[progressionIndex]
    if not info then
        d('ARR can not find info for ability id:'..abilityId)
        return
    end
    local weaponPair = GetActiveWeaponPairInfo()
    self:Debug(1,'arr:SaveOldSlotedSkill('..slotNum..')('..info.skillType..','..info.skillIndex..','..info.abilityIndex..') abilityId:'..info.abilityId)
    CharacterSavedVars().oldSlotedSkill = {
        slotNum = slotNum,
        weaponPair = weaponPair,
        info = info,
    }
end

---
--@param #Core self
--@param #number token
--@param #boolean force
function module:Switch(token, force)
    local now = GetGameTimeMilliseconds()
    -- check
    if not self.rmSkillInfo then return end
    if token ~= self.token then return end
    if not force and not self.mounted then return end
    if not force and self.coverTime and self.coverTime > now then
        zo_callLater(function() self:Switch(token) end, self.coverTime-now)
        return
    end
    if IsUnitInCombat('player') then
        zo_callLater(function() self:Switch(token) end, 1000)
        return
    end
    self:Debug(1,'arr:Switch('..token..','..(force and 'true' or 'false')..')')

    --  save old info
    local slotNum = SavedVars().switchAtAbilitySlot + 2
    if self.rmSkillInfo.abilityId == GetSlotBoundId(slotNum) then return end
    self:SaveOldSlotedSkill(slotNum)

    -- switch ability
    self.waitRecover = false
    if SavedVars().soundEnabled then PlaySound(SOUNDS[soundChoices[SavedVars().soundIndex]]) end
    SlotSkillAbilityInSlot(self.rmSkillInfo.skillType, self.rmSkillInfo.skillIndex, self.rmSkillInfo.abilityIndex, slotNum)
end

return module
