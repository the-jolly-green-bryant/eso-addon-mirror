
local NAME = 'SimpleLongBuffs'

-------------------------------------
--Custom Container Object--
-------------------------------------
local UnitBuffTrackerContrainer

UnitBuffTrackerContrainer = ZO_BuffDebuff_ContainerObject:Subclass()

function UnitBuffTrackerContrainer:New(...)
    return ZO_BuffDebuff_ContainerObject.New(self, ...)
end

function UnitBuffTrackerContrainer:ShouldContextuallyShow()
    return true
end

function UnitBuffTrackerContrainer:CreateMetaPool(container, buffControlPool)
    local metaPool = ZO_MetaPool:New(buffControlPool)
    metaPool.container = container

    local function OnAcquired(control)
        control:ClearAnchors()

        if control.platformStyle ~= self.currentPlatformStyle then
            control.platformStyle = self.currentPlatformStyle
            ApplyTemplateToControl(control, ZO_GetPlatformTemplate("SimpleLongBuffs_BuffDebuffIcon"))
        end

        if not metaPool.firstControl then
            metaPool.firstControl = control
            control:SetAnchor(BOTTOM, container, BOTTOM)
        else
            control:SetAnchor(BOTTOM, metaPool.lastControl, TOP, 0, -5)
        end

        metaPool.lastControl = control

        control:SetParent(container)
    end

    local function OnReset(control)
        control.blinkAnimation:Stop()

        control.cooldown:ResetCooldown()
        control.cooldown:SetHidden(true)
    end

    metaPool:SetCustomAcquireBehavior(OnAcquired)
    metaPool:SetCustomResetBehavior(OnReset)

    return metaPool
end

-------------------------------------
--Custom Style--
-------------------------------------
local UnitBuffTrackerStyle

UnitBuffTrackerStyle = ZO_BuffDebuffStyleObject:Subclass()
function UnitBuffTrackerStyle:New(...)
    return ZO_BuffDebuffStyleObject.New(self, ...)
end

function UnitBuffTrackerStyle:UpdateContainer(containerObject)
    ZO_ClearNumericallyIndexedTable(self.sortedBuffs)
    ZO_ClearNumericallyIndexedTable(self.sortedDebuffs)

    local unitTag = containerObject:GetUnitTag()
    local uid = 1

    for i = 1, GetNumBuffs(unitTag) do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, _, castByPlayer = GetUnitBuffInfo(unitTag, i)
        local permanent = IsAbilityPermanent(abilityId)
        if permanent or GetAbilityDuration(abilityId) >= 600000 then
            local data = {
                buffName = buffName,
                timeStarted = timeStarted,
                timeEnding = timeEnding,
                buffSlot = buffSlot,
                stackCount = stackCount,
                iconFilename = iconFilename,
                buffType = buffType,
                effectType = effectType,
                abilityType = abilityType,
                statusEffectType = statusEffectType,
                abilityId = abilityId,
                uid = uid,
                duration = timeEnding - timeStarted,
                castByPlayer = castByPlayer,
                permanent = permanent,
                isArtificial = false,
            }
            local appropriateTable = (effectType == BUFF_EFFECT_TYPE_BUFF) and self.sortedBuffs or self.sortedDebuffs
            table.insert(appropriateTable, data)
            uid = uid + 1
        end
    end

    if #self.sortedBuffs then
        table.sort(self.sortedBuffs, self.SortCallbackFunction)
    end
    if #self.sortedDebuffs then
        table.sort(self.sortedDebuffs, self.SortCallbackFunction)
    end

    local buffPool, debuffPool = containerObject:GetPools()

    for _, data in ipairs(self.sortedBuffs) do
        local buffControl = buffPool:AcquireObject()
        buffControl.data = data
        self:SetupIcon(buffControl)
    end

    for _, data in ipairs(self.sortedDebuffs) do
        local debuffControl = debuffPool:AcquireObject()
        debuffControl.data = data
        self:SetupIcon(debuffControl)
    end
end

function UnitBuffTrackerStyle:SortFunction(buffData1, buffData2)
    if buffData1.permanent and buffData2.permanent then
        return buffData1.buffName > buffData2.buffName
    else
        if buffData1.permanent then
            return true
        elseif buffData2.permanent then
            return false
        end

        if buffData1.timeEnding == buffData2.timeEnding then
            return buffData1.buffName > buffData2.buffName
        else
            return buffData1.timeEnding > buffData2.timeEnding
        end
    end
end

function SimpleLongBuffs_Initialize(topLevelCtrl)

    local function OnAddOnLoaded(_, addonName)
        if addonName == NAME then

            EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

            local UnitBuffTrackerStyleObject = UnitBuffTrackerStyle:New("SimpleLongBuffs_BuffDebuffCenterOutStyle_Template")
            local controlPool = ZO_ControlPool:New("ZO_BuffDebuffIcon", nil, "SLBBuff")

            local containerControl = CreateControlFromVirtual(NAME..'BuffDebuffContainer', topLevelCtrl, 'ZO_BuffDebuffContainerTemplate')
            containerControl:ClearAnchors()
            containerControl:SetAnchor(BOTTOMRIGHT, topLevelCtrl, BOTTOMRIGHT, 0, 0)

            local containerObject = UnitBuffTrackerContrainer:New(containerControl, controlPool, 'player', EVENT_PLAYER_ACTIVATED)
            containerObject:SetStyleObject(UnitBuffTrackerStyleObject, true)

            BUFF_DEBUFF:AddContainerObject('player_longbuffs', containerObject)

        end
    end

    EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end