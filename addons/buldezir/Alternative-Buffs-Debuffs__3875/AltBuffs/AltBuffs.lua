local NAME = 'AltBuffs'

local SETTINGS

local buggedLongDuration = {
    147417, -- Minor Courage
}

local PLAYER_UNIT_TAG = "player"
local TARGET_UNIT_TAG = "reticleover"

-------------------------------------
--Settings Menu--
-------------------------------------
local function InitializeAddonMenu()
    local LAM2 = LibAddonMenu2

    local listBuffs = {
        -- settings use half width, so let "paired buffs" be together
        61744,  -- Minor Berserk
        61745,  -- Major Berserk
        147417, -- Minor Courage
        109966, -- Major Courage
        61693,  -- Minor Resolve
        61694,  -- Major Resolve
        61715,  -- Minor Evasion
        61716,  -- Major Evasion
        61735,  -- Minor Expedition
        61736,  -- Major Expedition
        61708,  -- Minor Heroism
        61709,  -- Major Heroism

        88490,  -- Minor Toughness
        61691,  -- Minor Prophecy
        61666,  -- Minor Savagery
        61662,  -- Minor Brutality
        61685,  -- Minor Sorcery
        61737,  -- Empower

        93109,  -- Major Slayer
        61747,  -- Major Force

        61771,  -- Powerful Assault
        40224,  -- War Horn
        38564,  -- Aggressive Horn
        40221,  -- Sturdy Horn
    }
    local listDeBuffs = {
        -- settings use half width, so let "paired buffs" be together
        61742,  -- Minor Breach
        61743,  -- Major Breach
        79717,  -- Minor Vulnerability
        106754, -- Major Vulnerability
        61723,  -- Minor Maim
        61725,  -- Major Maim
        61726,  -- Minor Defile
        61727,  -- Major Defile
        88401,  -- Minor Magickasteal
        88402,  -- Major Magickasteal
        145975, -- Minor Brittle
        145977, -- Major Brittle
        79867,  -- Minor Cowardice
        147643, -- Major Cowardice

        79907,  -- Minor Enervation
        79895,  -- Minor Uncertainty
        61733,  -- Minor Mangle
        140699, -- Minor Timidity
        45902,  -- Off-Balance
        38254,  -- Taunt

        126597, -- Touch of Z'en
        142610, -- Flame Weakness (Catalist)
        142652, -- Frost Weakness (Catalist)
        142653, -- Shock Weakness (Catalist)
        75753,  -- Line-Breaker (Alkosh)
    }
    local aliasAbilityIds = {
        [45902] = { -- Off-Balance
            45902, -- bash/deep breath
            125750, -- ruinous scythe

            25256, -- Veiled Strike
            34733, -- Surprise Attack
            34737, -- concealed weapon

            23808, -- Lava Whip
            20806, -- molten whip
            34117, -- Flame Lash

            131562, -- Dizzying Swing

            62968, -- Wall of Elements (Shock)
            62988, -- blockade of storms
            39077, -- unstable wall of storms

            130129, -- dive
            130139, -- cutting dive
            130145, -- screaming cliff racer

            120014, -- trial dummy off balance
        },
    }

    local abilityLabels = {}
    for _, abilityId in ipairs(listBuffs) do
        abilityLabels[abilityId] = zo_iconFormat(GetAbilityIcon(abilityId), 18, 18) .. ' ' .. GetAbilityName(abilityId)
    end
    for _, abilityId in ipairs(listDeBuffs) do
        abilityLabels[abilityId] = zo_iconFormat(GetAbilityIcon(abilityId), 18, 18) .. ' ' .. GetAbilityName(abilityId)
    end

    -- clear old/unused abilityId settings (if listBuffs & listDeBuffs was changed)
    local aliasAbilityIdsSummary = {}
    for _, aliasIds in pairs(aliasAbilityIds) do
        for _, aliasId in pairs(aliasIds) do
            table.insert(aliasAbilityIdsSummary, aliasId)
        end
    end
    for abilityId, _ in pairs(SETTINGS.TRACK) do
        if ZO_IndexOfElementInNumericallyIndexedTable(listBuffs, abilityId) == nil
            and ZO_IndexOfElementInNumericallyIndexedTable(listDeBuffs, abilityId) == nil
            and ZO_IndexOfElementInNumericallyIndexedTable(aliasAbilityIdsSummary, abilityId) == nil
        then
            SETTINGS.TRACK[abilityId] = nil
        end
    end


    LAM2:RegisterAddonPanel("ALTBuffs_Settings", {
        type = "panel",
        name = "Alternative Buffs",
        displayName = "Alternative Buff/Debuff Tracker",
        author = "|c943810BulDeZir|r",
        version = string.format('|c00FF00%s|r', 1),
        registerForRefresh = true,
    })

    local OptionControls = {
        {
            type = "description",
            text =
            'This module settings are Character-wide. Addon replace default ZoS buff tracker, so it must be set to "automatic" or "always show" in Settings->Combat',
        },
        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "If disabled - default ZoS (combat->buffs&debuffs) settings used",
            default = true,
            getFunc = function() return SETTINGS.ENABLED end,
            setFunc = function(newValue)
                SETTINGS.ENABLED = newValue
            end,
        },
        {
            type = "header",
            name = "Buffs",
        },
        {
            type = "button",
            name = "Reset buffs",
            tooltip = "Uncheck all",
            func = function() for _, abilityId in ipairs(listBuffs) do SETTINGS.TRACK[abilityId] = nil end end,
        },
    }
    for _, abilityId in ipairs(listBuffs) do
        if abilityId > 0 then
            table.insert(OptionControls, {
                type = "checkbox",
                name = abilityLabels[abilityId],
                width = 'half',
                disabled = function() return not SETTINGS.ENABLED end,
                default = false,
                getFunc = function() return SETTINGS.TRACK[abilityId] end,
                setFunc = function(newValue)
                    if aliasAbilityIds[abilityId] == nil then
                        SETTINGS.TRACK[abilityId] = newValue
                    else
                        for _, aliasId in ipairs(aliasAbilityIds[abilityId]) do
                            SETTINGS.TRACK[aliasId] = newValue
                        end
                    end
                end,
            })
        end
    end
    table.insert(OptionControls, {
        type = "header",
        name = "DeBuffs",
    })
    table.insert(OptionControls, {
        type = "button",
        name = "Reset debuffs",
        tooltip = "Uncheck all",
        func = function() for _, abilityId in ipairs(listDeBuffs) do SETTINGS.TRACK[abilityId] = nil end end,
    })
    for _, abilityId in ipairs(listDeBuffs) do
        if abilityId > 0 then
            table.insert(OptionControls, {
                type = "checkbox",
                name = abilityLabels[abilityId],
                width = 'half',
                disabled = function() return not SETTINGS.ENABLED end,
                default = false,
                getFunc = function() return SETTINGS.TRACK[abilityId] end,
                setFunc = function(newValue)
                    if aliasAbilityIds[abilityId] == nil then
                        SETTINGS.TRACK[abilityId] = newValue
                    else
                        for _, aliasId in ipairs(aliasAbilityIds[abilityId]) do
                            SETTINGS.TRACK[aliasId] = newValue
                        end
                    end
                end,
            })
        end
    end

    LAM2:RegisterOptionControls("ALTBuffs_Settings", OptionControls)
end
-------------------------------------
--Custom Style--
-------------------------------------
local AltBuffTrackerStyle

AltBuffTrackerStyle = ZO_BuffDebuffStyleObject:Subclass()
function AltBuffTrackerStyle:New(...)
    return ZO_BuffDebuffStyleObject.New(self, ...)
end

local function IsVisibleZos(containerObject, effectType, timeStarted, timeEnding, permanent, castByPlayer)
    local visible = false
    local effectTypeSetting = (effectType == BUFF_EFFECT_TYPE_BUFF) and BUFFS_SETTING_BUFFS_ENABLED or
        BUFFS_SETTING_DEBUFFS_ENABLED
    if containerObject:GetVisibilitySetting(effectTypeSetting) then
        visible = true
        if containerObject:GetUnitTag() == TARGET_UNIT_TAG then
            if effectType == BUFF_EFFECT_TYPE_BUFF then
                visible = visible and containerObject:GetVisibilitySetting(BUFFS_SETTING_BUFFS_ENABLED_FOR_TARGET)
            elseif effectType == BUFF_EFFECT_TYPE_DEBUFF and not castByPlayer then
                visible = visible and
                    containerObject:GetVisibilitySetting(BUFFS_SETTING_DEBUFFS_ENABLED_FOR_TARGET_FROM_OTHERS)
            end
        end
        if permanent then
            visible = visible and containerObject:GetVisibilitySetting(BUFFS_SETTING_PERMANENT_EFFECTS)
        else
            local duration = timeEnding - timeStarted
            if duration >= ZO_BUFF_DEBUFF_LONG_EFFECT_DURATION_SECONDS then
                visible = visible and containerObject:GetVisibilitySetting(BUFFS_SETTING_LONG_EFFECTS)
            end
        end
    end
    return visible
end

local function IsVisible(containerObject, effectType, abilityId, timeEnding, currentTime)
    if effectType == BUFF_EFFECT_TYPE_DEBUFF and containerObject:GetUnitTag() == PLAYER_UNIT_TAG and containerObject:GetVisibilitySetting(BUFFS_SETTING_DEBUFFS_ENABLED) then
        return true
    end
    if SETTINGS.TRACK[abilityId] == true and (timeEnding - currentTime > 0 or ZO_IsElementInNumericallyIndexedTable(buggedLongDuration, abilityId)) then
        return true
    else
        return false
    end
end

function AltBuffTrackerStyle:UpdateContainer(containerObject)
    ZO_ClearNumericallyIndexedTable(self.sortedBuffs)
    ZO_ClearNumericallyIndexedTable(self.sortedDebuffs)

    if containerObject:ShouldContextuallyShow() then
        local currentTime = GetFrameTimeSeconds()
        local unitTag = containerObject:GetUnitTag()
        local uid = 1

        for i = 1, GetNumBuffs(unitTag) do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, _, castByPlayer =
                GetUnitBuffInfo(unitTag, i)
            local permanent = IsAbilityPermanent(abilityId)

            local shouldShow = false
            if SETTINGS.ENABLED then
                shouldShow = IsVisible(containerObject, effectType, abilityId, timeEnding, currentTime)
            else
                shouldShow = IsVisibleZos(containerObject, effectType, timeStarted, timeEnding, permanent, castByPlayer)
            end
            if shouldShow then
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
                local appropriateTable = (effectType == BUFF_EFFECT_TYPE_BUFF) and self.sortedBuffs or self
                    .sortedDebuffs
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
end

local function OnAddOnLoaded(_, addonName)
    if addonName == NAME then
        EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

        SETTINGS = ZO_SavedVars:NewCharacterIdSettings("AltBuffsSavedVariables", 1, nil, {
            TRACK = {},
            ENABLED = true,
        })

        local UnitBuffTrackerStyleObject = AltBuffTrackerStyle:New("ZO_BuffDebuffAllCenteredStyle_Template")
        BUFF_DEBUFF.containerObjectsByUnitTag[PLAYER_UNIT_TAG]:SetStyleObject(UnitBuffTrackerStyleObject, true)
        BUFF_DEBUFF.containerObjectsByUnitTag[TARGET_UNIT_TAG]:SetStyleObject(UnitBuffTrackerStyleObject, true)

        InitializeAddonMenu()
    end
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
