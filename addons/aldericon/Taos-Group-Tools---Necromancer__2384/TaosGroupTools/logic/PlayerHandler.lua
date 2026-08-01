--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Global callbacks
]]--
TGT_PLAYER_ACTIVATED = "TGT-PlayerActivated"
TGT_PLAYER_DATA_OFFLINE_CHANGED = "TGT-PlayerDataOfflineChanged"
TGT_PLAYER_DATA_BUFFS_CHANGED = "TGT-PlayerDataBuffsChanged"
TGT_PLAYER_DATA_REMOTE_CHANGED = "TGT-PlayerDataRemoteChanged"
TGT_PLAYER_DATA_REFRESH = "TGT-PlayerHandlerRefresh"
TGT_PLAYER_DATA_CLEAR = "TGT-PlayerDataClear"
TGT_PLAYER_DATA_SUB_GROUP_CHANGED = "TGT-PlayerDataSubGroupChanged"
TGT_PLAYER_DATA_PURGE_CHANGED = "TGT-PlayerDataPurgeChanged"

--[[
	Global values
]]--
PLAYERTIMEOUT = 4 -- s; GetTimeStamp() is in seconds
COMBATTIMEOUT = 30000 -- ms

--[[
	Local variables
]]--
-- Set to local for faster access
local MESSAGE_PLAYER_RESOURCES = MESSAGE_PLAYER_RESOURCES
local MESSAGE_PLAYER_DPS = MESSAGE_PLAYER_DPS
local MESSAGE_PLAYER_HPS = MESSAGE_PLAYER_HPS

local REFRESHRATE = 1000 -- ms; RegisterForUpdate is in miliseconds
local TIMEOUT = PLAYERTIMEOUT
local EARTHGORE_ID = 97855
local EARTHGORE_CD = 35000 -- ms
local EARTHGORE = EARTHGORE_ICON_ID

local _logger = nil
local _settingsHandler = TGT_SettingsHandler

local _name = "TGT-PlayerHandler"
local _playerMyself = nil
local _groupPlayers = {}
local _lastCombatTimestamp = 0
local _lastGarbageCollectionTimestamp = 0

local _foodBuffs = FOOD_BUFFS
local _trackedBuffs = TRACKED_BUFFS
local _trackedSpecificBuffs = {
    [EARTHGORE_ICON_ID] = {},
    [DETONATON_ICON_ID] = {},
    [SPEEDBUFF_ICON_ID] = {},
}

--[[
	Table TGT_PlayerHandler
]]--
TGT_PlayerHandler = {}
TGT_PlayerHandler.__index = TGT_PlayerHandler

--[[
	==============
    PRIVATE METHODS
    ==============
]]--

--[[
	GetAllReceivedHealing gets healing from all players
]]--
local function GetAllReceivedHealing()
    local healingSum = 0

    for i, player in pairs(_groupPlayers) do
        healingSum = healingSum + player.HealingReceived
    end

    return healingSum
end

--[[
	UpdateAllRelativeHeal updates all relative heal
]]--
local function UpdateAllRelativeHeal()
    local allReceivedHealing = GetAllReceivedHealing()

    for i, player in pairs(_groupPlayers) do
        player.HealingReceivedRelative = player.HealingReceived / allReceivedHealing * 100
    end
end

--[[
	ResetAllPlayerHeal resets all player heal
]]--
local function ResetAllPlayerHeal()
    for i, player in pairs(_groupPlayers) do
        player.HealingReceived = 0
        player.HealingReceivedRelative = 0
    end
end

--[[
	UpdatePlayerHps updates player hps from pingPlayer
]]--
local function UpdatePlayerHps(player, pingPlayer)
    if (pingPlayer.HealingReceived > 0) then
        player.HealingReceived = player.HealingReceived + pingPlayer.HealingReceived
        UpdateAllRelativeHeal()
    elseif (pingPlayer.HealingReceived == 0) then
        ResetAllPlayerHeal()
    else
        _logger:logError("PlayerHandler -> UpdatePlayerHps; HealingReceived unexpected value", pingPlayer.HealingReceived)
    end
end

--[[
	GetAllReceivedDamage gets damage from all players
]]--
local function GetAllReceivedDamage()
    local damageSum = 0

    for i, player in pairs(_groupPlayers) do
        damageSum = damageSum + player.DamageReceived
    end
	
    return damageSum
end

--[[
	UpdateAllRelativeDmg updates all relative dmg
]]--
local function UpdateAllRelativeDmg()
    local allReceivedDmg = GetAllReceivedDamage()

    for i, player in pairs(_groupPlayers) do
        player.DamageReceivedRelative = player.DamageReceived / allReceivedDmg * 100
    end
end

--[[
	ResetAllPlayerDmg resets all player dmg
]]--
local function ResetAllPlayerDmg()
    for i, player in pairs(_groupPlayers) do
        player.DamageReceived = 0
        player.DamageReceivedRelative = 0
    end
end

--[[
	UpdatePlayerDps updates player dps from pingPlayer
]]--
local function UpdatePlayerDps(player, pingPlayer)
    if (pingPlayer.DamageReceived > 0) then
        player.DamageReceived = player.DamageReceived + pingPlayer.DamageReceived
        UpdateAllRelativeDmg()
    elseif (pingPlayer.DamageReceived == 0) then
        ResetAllPlayerDmg()
    else
        _logger:logError("PlayerHandler -> UpdatePlayerDps; DamageReceived unexpected value", pingPlayer.DamageReceived)
    end
end

--[[
	UpdatePlayerResources updates player resources from pingPlayer
]]--
local function UpdatePlayerResources(player, pingPlayer)
    -- Update UltimateGroup or Earthgore, if procced
    if (pingPlayer.IsEarthgoreProcced) then
        -- -1000, because of lag
        player.IsEarthgoreProccedTimestamp = GetGameTimeMilliseconds() - 1000
    else
        if (player.UltimateGroup == nil or
            player.UltimateGroup.GroupAbilityPing ~= pingPlayer.GroupAbilityPing) then

            local ultimateGroup = TGT_UltimateGroupHandler.GetUltimateGroupByAbilityPing(pingPlayer.GroupAbilityPing)
            local ultimateName = GetAbilityName(ultimateGroup.GroupAbilityId)
            local ultimateIcon = GetAbilityIcon(ultimateGroup.GroupAbilityId)

            player.UltimateGroup = ultimateGroup
            player.UltimateName = ultimateName
            player.UltimateIcon = ultimateIcon
        end
    end
    
    -- Update relative ultimate
    if (player.IsPlayerDead) then
        player.RelativeUltimate = 0
    else
        if (player.RelativeUltimate ~= pingPlayer.RelativeUltimate) then
            -- play sound if ultimate ready
		    if (player.RelativeUltimate < 100 and pingPlayer.RelativeUltimate >= 100) then
			    local sound = TGT_SettingsHandler.SavedVariables.SoundOnReady
			    if (sound[1] > 1) then PlaySound(SOUNDS[sound[2]]) end
		    end

            -- play sound if ultimate raised
		    if (player.RelativeUltimate >= 100 and pingPlayer.RelativeUltimate < 100) then
			    local sound = TGT_SettingsHandler.SavedVariables.SoundOnThrown
			    if (sound[1] > 1) then PlaySound(SOUNDS[sound[2]]) end
		    end

            player.RelativeUltimate = pingPlayer.RelativeUltimate
        end
    end

    -- Update relative magicka
    if (player.RelativeMagicka ~= pingPlayer.RelativeMagicka) then
        player.RelativeMagicka = pingPlayer.RelativeMagicka
    end

    -- Update relative stamina
    if (player.RelativeStamina ~= pingPlayer.RelativeStamina) then
        player.RelativeStamina = pingPlayer.RelativeStamina
    end
end

--[[
	UpdateFoodBuff on player
]]--
local function UpdateFoodBuff(player)
    -- Reset first
    player.FoodBuffActive = false
    player.FoodBuffIcon = nil

    -- Iterate buffs and set new
    for i = 1, GetNumBuffs(player.PingTag) do
        local _, _, _, _, _, iconFile, _, _, _, _, abilityId = GetUnitBuffInfo(player.PingTag, i)

        if (_foodBuffs[abilityId] ~= nil) then
            player.FoodBuffActive = true
            player.FoodBuffIcon = iconFile
            break
        end
    end
end

--[[
	GetNewPlayer Gets new empty player
]]--
local function GetNewPlayer(pingTag)
    local current, max, effectiveMax = GetUnitPower(pingTag, POWERTYPE_HEALTH)
    local relativeHealth = math.floor((current / max * 100))

    if (relativeHealth > 100) then
        relativeHealth = 100
    end
    
    local playerName = GetUnitName(pingTag)

    local newPlayer = {
        PingTag = pingTag,
        PlayerPosition = tonumber(pingTag:match('(%d+)$')),
        GroupIdentifer = _settingsHandler.SavedVariables.PlayerFrameGroups[playerName],
        PlayerName = playerName,
        IsPlayerDead = IsUnitDead(pingTag),
        IsPlayerInCombat = IsUnitInCombat(pingTag),
        IsPlayerTimedOut = true,
        IsPlayerOnline = true,
        LastMapPingTimestamp = 0,
        UltimateName = nil,
        UltimateIcon = nil,
        UltimateGroup = nil,
        CurentHealth = current,
        CurrentHealthPool = max,
        RelativeHealth = (current / max * 100),
        RelativeUltimate = 0,
        RelativeMagicka = 0,
        RelativeStamina = 0,
        CurrentShield = 0,
        RelativeShield = 0,
		DamageDone = 0,
		HealingDone = 0,
        DamageToSend = 0,
        HealingToSend = 0,
        DamageReceived = 0,
        DamageReceivedRelative = 0,
        HealingReceived = 0,
        HealingReceivedRelative = 0,
        IsEarthgoreProcced = false,
        IsEarthgoreProccedTimestamp = 0,
        Buffs = {},
        FoodBuffActive = false,
        FoodBuffIcon = nil,
        PurgableDebuffs = 0,
        IsPurgable = false
    }

    -- Updates Buffs
    UpdateFoodBuff(newPlayer)

    return newPlayer
end

--[[
	SetUltimate Sets PlayerMyself ultimate; called on TGT_STATIC_ULTIMATE_ID_CHANGED
]]--
local function SetUltimate(staticUltimateID)
    _playerMyself.UltimateGroup = TGT_UltimateGroupHandler.GetUltimateGroupByAbilityId(staticUltimateID)
end

--[[
	UpdatePlayers Removes player if left; called on TAO_GROUP_CHANGED
]]--
local function UpdatePlayers(playerName, isJoined)
    if (playerName ~= "" or playerName ~= nil) then
        -- Player joined
        if (isJoined) then
            if (_groupPlayers[playerName] == nil) then
                local isGroupMember, unitTag = IsTargetGroupMember(playerName)
				
				if (isGroupMember) then
					local player = GetNewPlayer(unitTag)

					_groupPlayers[playerName] = player

					FireCallbacksAsync(TGT_PLAYER_DATA_OFFLINE_CHANGED, player)
				else
					_logger:logDebug("isGroupMember == false", unitTag, playerName)
				end
            end
        -- Player left
        else
            if (_groupPlayers[playerName] ~= nil) then
                local player = _groupPlayers[playerName]

                FireCallbacksAsync(TGT_PLAYER_DATA_CLEAR, player)

                _groupPlayers[playerName] = nil
            end
        end
    else
        _logger:logError("PlayerHandler -> UpdatePlayers; playerName invalid", playerName)
    end

    -- Prevent spam
    if (GetGameTimeMilliseconds() - _lastGarbageCollectionTimestamp > 10000) then
        _lastGarbageCollectionTimestamp = GetGameTimeMilliseconds()
        collectgarbage()
    end
end

--[[
	UpdateGroup Add or removes complete groupPlayers list; called on TAO_UNIT_GROUPED_CHANGED
]]--
local function UpdateGroup(isGrouped)
    for i,player in pairs(_groupPlayers) do
        if (isGrouped) then
            local isGroupMember, unitTag = IsTargetGroupMember(player.PlayerName)

            if (not isGroupMember) then
                FireCallbacksAsync(TGT_PLAYER_DATA_CLEAR, player)
                _groupPlayers[player.PlayerName] = nil
            end
        else
            FireCallbacksAsync(TGT_PLAYER_DATA_CLEAR, player)
            _groupPlayers[player.PlayerName] = nil
        end
    end

    -- Add all group players, which not already in group list
    if (isGrouped) then
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if (unitTag) then
                local playerName = GetUnitName(unitTag)

                if (_groupPlayers[playerName] == nil) then
                    local player = GetNewPlayer(unitTag)

                    _groupPlayers[playerName] = player

                    FireCallbacksAsync(TGT_PLAYER_DATA_OFFLINE_CHANGED, player)
                else
                    -- Refresh tag / position
                    local player = _groupPlayers[playerName]
                    player.PingTag = unitTag
                    player.PlayerPosition = tonumber(unitTag:match('(%d+)$'))
                end
            end
        end
    end
    
    -- Prevent spam
    if (GetGameTimeMilliseconds() - _lastGarbageCollectionTimestamp > 10000) then
        _lastGarbageCollectionTimestamp = GetGameTimeMilliseconds()
        collectgarbage()
    end
end

--[[
	OnCombatEvent Handles several combat events; called on EVENT_COMBAT_EVENT
]]--
local function OnCombatEvent(eventCode, result, isError, abilityName, graphic, actionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitID, targetUnitID, abilityID)
    -- Actions
    local isMyAction = (sourceType == COMBAT_UNIT_TYPE_PLAYER) or (sourceType == COMBAT_UNIT_TYPE_PLAYER_PET)
    local isDmgAction = (result == ACTION_RESULT_DAMAGE) or (result == ACTION_RESULT_CRITICAL_DAMAGE) or (result == ACTION_RESULT_DOT_TICK) or (result == ACTION_RESULT_DOT_TICK_CRITICAL)
    local isHealAction = (result == ACTION_RESULT_HEAL) or (result == ACTION_RESULT_CRITICAL_HEAL) or (result == ACTION_RESULT_HOT_TICK) or (result == ACTION_RESULT_HOT_TICK_CRITICAL)

    -- DMG
    if (isMyAction and isDmgAction and (sourceName ~= targetName) and (hitValue > 0)) then
		_playerMyself.DamageDone = _playerMyself.DamageDone + hitValue
    end

    -- HEAL
	local isTargetGroupMember, unitTag = IsTargetGroupMember(targetName)
    if (isMyAction and isHealAction and (sourceName ~= targetName) and (hitValue > 0) and isTargetGroupMember) then
		local currentHealth, maxHealth, effectiveMaxHealth = GetUnitPower(unitTag, POWERTYPE_HEALTH)
		-- Realy healed?
		if (currentHealth ~= maxHealth) then
			_playerMyself.HealingDone = _playerMyself.HealingDone + hitValue
		end
    end
end

--[[
	IsTrackedBuff Checks abilityId or IconName, because ZOS buff/debuff tracking sends inconsistend values for abilityId's
]]--
local function IsTrackedBuff(abilityId, iconName)
    -- Check specific buffs like speedbuff, deto, earthgore
    if (_trackedSpecificBuffs[abilityId] ~= nil) then
        return true, abilityId
    end

    -- Check buffs via icons
    for i, buff in ipairs(_trackedBuffs) do
        if (string.match(iconName, buff.IconName)) then
            return true, buff.IconId -- found
        end
    end

    -- Nothing found
    return false, nil
end

--[[
	IsPurgableEffect Checks several values, because ZOS buff/debuff tracking sends inconsistend values for abilities
]]--
local function IsPurgableEffect(abilityId, abilityType, statusEffectType)
    local purgableAbilities = {
        [15775] = {},  -- Öl
        [15776] = {},  -- Öl
        [28480] = {},  -- Feuerballiste
        [66243] = {},  -- Kalthafen Feuerballiste
        [25869] = {},  -- Feuertopf-Tribok
        [66247] = {},  -- Feuertopf-Tribok
        [20528] = {},  -- DK Krallen
        [31898] = {},  -- DK Krallen
        [104825] = {}, -- Warden Eis
        [44549] = {},  -- Bogen Gift
        [89491] = {},  -- Heimsuchender Fluch
        [28452] = {},  -- Daedrisches Grabmal
    }

    local isPurgableAbility = purgableAbilities[abilityId] ~= nil
    local isPurgableAbilityType = 
        abilityType == ABILITY_TYPE_STUN or
        abilityType == ABILITY_TYPE_DISORIENT or
        abilityType == ABILITY_TYPE_FEAR
    local isPurgableStatusEffect = 
        statusEffectType == STATUS_EFFECT_TYPE_DISEASE or 
        statusEffectType == STATUS_EFFECT_TYPE_MESMERIZE or
        statusEffectType == STATUS_EFFECT_TYPE_ROOT or
        statusEffectType == STATUS_EFFECT_TYPE_STUN

    return isPurgableAbility or isPurgableAbilityType or isPurgableStatusEffect
end

--[[
	OnEffectChangedEvent Handles several effect events; called on EVENT_EFFECT_CHANGED
]]--
local function OnEffectChangedEvent(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    local isMyself = sourceType == COMBAT_UNIT_TYPE_PLAYER
    local isGroupPlayer = string.match(unitTag, "group")
    local isGained = changeType == EFFECT_RESULT_GAINED
    local isFaded = changeType == EFFECT_RESULT_FADED

    -- Earthgore
    if (abilityId == EARTHGORE_ID and isGained and isMyself) then
        _playerMyself.IsEarthgoreProcced = true
    end
    
    -- TODO: To find further purgable skills
    if (GetUnitName(unitTag) == GetUnitName("player")) then
        _logger:logDebug(effectName, unitTag, unitName, abilityId, changeType)
        --_logger:logDebug(iconName, buffType, effectType, abilityType, statusEffectType)
    end

    if (isGroupPlayer) then
        -- Purge
        if (IsPurgableEffect(abilityId, abilityType, statusEffectType)) then
            local playerName = GetUnitName(unitTag)

            if (_groupPlayers[playerName] ~= nil) then
                local player = _groupPlayers[playerName]
            
                if (changeType == EFFECT_RESULT_GAINED) then
                    if (player.PurgableDebuffs < 0) then
                        -- to prevent purgable debuffs are smaller than zero, because ZOS api sends sometimes updates after death or not
                        player.PurgableDebuffs = 0
                    end

                    player.PurgableDebuffs = player.PurgableDebuffs + 1
                    player.IsPurgable = true

                    --_logger:logDebug(playerName, "Purge add", effectName, abilityId, player.PurgableDebuffs)
                elseif (changeType == EFFECT_RESULT_FADED) then
                    player.PurgableDebuffs = player.PurgableDebuffs - 1

                    if (player.PurgableDebuffs <= 0) then
                        player.PurgableDebuffs = 0
                        player.IsPurgable = false

                        --_logger:logDebug(playerName, "Purge remove", effectName, abilityId, player.PurgableDebuffs)
                    else
                        --_logger:logDebug(playerName, "Purge remove and update", effectName, abilityId, player.PurgableDebuffs)
                    end
                else
                    player.IsPurgable = player.PurgableDebuffs > 0
                    --_logger:logDebug(playerName, "Purge update", effectName, abilityId, player.PurgableDebuffs)
                end

                FireCallbacksAsync(TGT_PLAYER_DATA_PURGE_CHANGED, player)
            end
        end

        -- TrackedBuffs
        local isTrackedBuff, iconId = IsTrackedBuff(abilityId, iconName)

        if (isTrackedBuff) then
            local playerName = GetUnitName(unitTag)

            if (_groupPlayers[playerName] ~= nil) then
                local player = _groupPlayers[playerName]
            
                if (changeType == EFFECT_RESULT_GAINED) then
                    player.Buffs[iconId] = { isActive = true, startTime = beginTime, finishTime = endTime }
                elseif (changeType == EFFECT_RESULT_FADED) then
                    player.Buffs[iconId] = { isActive = false, startTime = beginTime, finishTime = endTime }
                else
                    player.Buffs[iconId] = { isActive = true, startTime = beginTime, finishTime = endTime }
                end

                FireCallbacksAsync(TGT_PLAYER_DATA_BUFFS_CHANGED, player, iconId)
            end
        end
    end
end

--[[
	UpdatePlayerHealth updates player health and fires TGT_PLAYER_DATA_OFFLINE_CHANGED
]]--
local function UpdatePlayerHealth(player, powerPool, powerPoolMax)
    local isPlayerDead = IsUnitDead(player.PingTag)
    
    if (isPlayerDead or powerPool == 0) then 
        player.CurentHealth = 0
        player.IsPlayerDead = true

        -- to prevent purgable debuffs will not disappear, because ZOS api sends sometimes updates after death or not
        player.PurgableDebuffs = 0
        player.IsPurgable = false

        FireCallbacksAsync(TGT_PLAYER_DATA_PURGE_CHANGED, player)
    else
        player.CurentHealth = powerPool
        player.IsPlayerDead = false
    end
    
    player.CurrentHealthPool = powerPoolMax
    
    local relativeHealth = math.floor((powerPool / powerPoolMax * 100))

    if (relativeHealth > 100) then
        relativeHealth = 100
    end

    player.RelativeHealth = relativeHealth

    FireCallbacksAsync(TGT_PLAYER_DATA_OFFLINE_CHANGED, player)
end

--[[
	OnPowerUpdate Handles several player pool events; called on EVENT_POWER_UPDATE
]]--
local function OnPowerUpdate(evt, unitTag, powerPoolIndex, powerType, powerPool, powerPoolMax)
    if (powerType == POWERTYPE_HEALTH) then
        local playerName = GetUnitName(unitTag)
        if (TGT_MOCKED) then
            local isNotMyself = string.find(playerName, "reticleover")
            if (isNotMyself == nil) then
                for i,player in pairs(_groupPlayers) do
                    UpdatePlayerHealth(player, powerPool, powerPoolMax)
                end
            end
        else
            if (_groupPlayers[playerName] ~= nil) then
                local player = _groupPlayers[playerName]
                UpdatePlayerHealth(player, powerPool, powerPoolMax)
            end
        end
    end
end

--[[
	UpdatePlayerShield updates player shield and fires TGT_PLAYER_DATA_OFFLINE_CHANGED
]]--
local function UpdatePlayerShield(player, value)
    local isPlayerDead = IsUnitDead(player.PingTag)
    player.IsPlayerDead = isPlayerDead

    if (isPlayerDead) then 
        player.CurrentShield = 0
    else
        player.CurrentShield = value
        local relativeShield = math.floor((value / player.CurrentHealthPool * 100))

        if (relativeShield > 100) then
            relativeShield = 100
        end

        player.RelativeShield = relativeShield
    end
    
    FireCallbacksAsync(TGT_PLAYER_DATA_OFFLINE_CHANGED, player)
end

--[[
	HandleVisualEvents Handles visual events from different base handlers
]]--
local function HandleVisualEvents(unitTag, powerType, visualType, value)
    if (powerType == POWERTYPE_HEALTH) then
        -- Shield
        if (visualType == ATTRIBUTE_VISUAL_POWER_SHIELDING) then
            local playerName = GetUnitName(unitTag)

            if (TGT_MOCKED) then
                local isNotMyself = string.find(playerName, "reticleover")
                if (isNotMyself == nil) then
                    for i,player in pairs(_groupPlayers) do
                        UpdatePlayerShield(player, value)
                    end
                end
            else
                if (_groupPlayers[playerName] ~= nil) then
                    local player = _groupPlayers[playerName]
                    UpdatePlayerShield(player, value)
                end
            end
        end
    end
end

--[[
	OnVisualAdded Handles EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED events
]]--
local function OnVisualAdded(evt, unitTag, visualType, stat, attribute, powerType, value, maxValue)
    HandleVisualEvents(unitTag, powerType, visualType, value)
end

--[[
	OnVisualUpdated Handles EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED events
]]--
local function OnVisualUpdated(evt, unitTag, visualType, stat, attribute, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
    HandleVisualEvents(unitTag, powerType, visualType, newValue)
end

--[[
	OnVisualRemoved Handles EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED events
]]--
local function OnVisualRemoved(evt, unitTag, visualType, stat, attribute, powerType, value, maxValue)
    HandleVisualEvents(unitTag, powerType, visualType, 0)
end

--[[
	OnPlayerActivated fires TGT_PLAYER_ACTIVATED callbacks
]]--
local function OnPlayerActivated(eventCode)
    FireCallbacksAsync(TGT_PLAYER_ACTIVATED)

    for i,player in pairs(_groupPlayers) do
        UpdateFoodBuff(player)
        local health, maxHealth = GetUnitPower(player.PingTag, POWERTYPE_HEALTH)
        UpdatePlayerHealth(player, health, maxHealth) -- Calls update offline player
        FireCallbacksAsync(TGT_PLAYER_DATA_REMOTE_CHANGED, player)
    end

    FireCallbacksAsync(TGT_PLAYER_DATA_REFRESH)
end

--[[
	UpdatePlayerData Updates group player data
]]--
local function UpdatePlayerData(pingPlayer)
    local playerName = GetUnitName(pingPlayer.PingTag)
    if (string.len(playerName) > 0) then
        local player = nil

        if (_groupPlayers[playerName] == nil) then
            -- Should not happens, especially in MOCKED mode
            _logger:logError("PlayerHandler -> UpdatePlayerData; Added player via UpdatePlayerData", playerName)

            player = GetNewPlayer(pingPlayer.PingTag)
            _groupPlayers[playerName] = player
        else
            player = _groupPlayers[playerName]
            
            -- Refresh tag / position
            player.PingTag = pingPlayer.PingTag
            player.PlayerPosition = tonumber(pingPlayer.PingTag:match('(%d+)$'))
        end

        -- Update timestamp
        player.LastMapPingTimestamp = GetTimeStamp()
        if (pingPlayer.MessageType == MESSAGE_PLAYER_RESOURCES) then
            UpdatePlayerResources(player, pingPlayer)
        elseif (pingPlayer.MessageType == MESSAGE_PLAYER_DPS) then
            UpdatePlayerDps(player, pingPlayer)
        elseif (pingPlayer.MessageType == MESSAGE_PLAYER_HPS) then
            UpdatePlayerHps(player, pingPlayer)
        else
            -- should not happen
            _logger:logError(zo_strformat("PlayerHandler -> UpdatePlayerData; Message Type not valid (<<1>>)", messageType))
        end
    
        -- Update Earthgore procc; If last earthgore timestamp < EARTHGORE_CD, procc is on CD (true); otherwhise false
        local lastProcDifference = GetGameTimeMilliseconds() - player.IsEarthgoreProccedTimestamp
        player.Buffs[EARTHGORE] = { isActive = lastProcDifference < EARTHGORE_CD, startTime = 0, finishTime = 0 }

        -- update the player
        FireCallbacksAsync(TGT_PLAYER_DATA_REMOTE_CHANGED, player)

    else
        _logger:logError("PlayerHandler -> UpdatePlayerData; Ping Player name empty", pingPlayer.PingTag)
    end

    -- Clear ping player
    pingPlayer = nil
end

--[[
	GetMyselfData Gets PlayerMyself and updates values before
]]--
local function GetMyselfData(messageType)
    -- Update combat timestamp
    if (IsGroupInCombat()) then
        _lastCombatTimestamp = GetGameTimeMilliseconds()
    end
    -- get combatPause
    local combatPause = math.abs(_lastCombatTimestamp - GetGameTimeMilliseconds())

    -- update needed
    local updateNeeded = true

    -- Get current image of player resources
    if (messageType == MESSAGE_PLAYER_RESOURCES) then
        local currentUltimate, maxUltimate, effectiveMaxUltimate = GetUnitPower("player", POWERTYPE_ULTIMATE)
        local ultimateCost = math.max(1, GetAbilityCost(_playerMyself.UltimateGroup.GroupAbilityId))
        local relativeUltimate = math.floor((currentUltimate / ultimateCost) * 100)

	    if (relativeUltimate > 100) then
		    relativeUltimate = 100
	    end

        local currentMagicka, maxMagicka, effectiveMaxMagicka = GetUnitPower("player", POWERTYPE_MAGICKA)
        local relativeMagicka = math.floor((currentMagicka / maxMagicka) * 100)
        
	    if (relativeMagicka > 100) then
		    relativeMagicka = 100
	    end

        local currentStamina, maxStamina, effectiveMaxStamina = GetUnitPower("player", POWERTYPE_STAMINA)
        local relativeStamina = math.floor((currentStamina / maxStamina) * 100)
        
	    if (relativeStamina > 100) then
		    relativeStamina = 100
	    end

        _playerMyself.RelativeUltimate = relativeUltimate
        _playerMyself.RelativeMagicka = relativeMagicka
        _playerMyself.RelativeStamina = relativeStamina
    elseif (messageType == MESSAGE_PLAYER_DPS) then
        if (_playerMyself.DamageDone > 0) then
            _playerMyself.DamageToSend = _playerMyself.DamageDone
            _playerMyself.DamageDone = _playerMyself.DamageDone - _playerMyself.DamageToSend
        else
            if (combatPause >= COMBATTIMEOUT) then
                _playerMyself.DamageToSend = 0
            else
                -- Damage not changed
                updateNeeded = false
            end
        end
    elseif (messageType == MESSAGE_PLAYER_HPS) then
        if (_playerMyself.HealingDone > 0) then
            _playerMyself.HealingToSend = _playerMyself.HealingDone
            _playerMyself.HealingDone = _playerMyself.HealingDone - _playerMyself.HealingToSend
        else
            if (combatPause >= COMBATTIMEOUT) then
                _playerMyself.HealingToSend = 0
            else
                -- Healing not changed
                updateNeeded = false
            end
        end
    end

    return _playerMyself, updateNeeded
end

--[[
	UpdatePlayerStatus updates offline, online timedout, combat values and fires TGT_PLAYER_DATA_REFRESH callbacks, if needed
]]--
local function UpdatePlayerStatus()
    for i,player in pairs(_groupPlayers) do
        -- Update timeout
        local isPlayerTimedOut = (GetTimeStamp() - player.LastMapPingTimestamp) >= PLAYERTIMEOUT

        if (player.IsPlayerTimedOut ~= isPlayerTimedOut) then
            player.IsPlayerTimedOut = isPlayerTimedOut
            FireCallbacksAsync(TGT_PLAYER_DATA_REMOTE_CHANGED, player)
        end

        -- Update Offline/Online
        local isOnline = IsUnitOnline(player.PingTag)

        if (player.IsPlayerOnline ~= isOnline) then
            player.IsPlayerOnline = isOnline
        end

        -- Update Combat
        local isInCombat = IsUnitInCombat(player.PingTag)
        
        if (player.IsPlayerInCombat ~= isInCombat) then
            player.IsPlayerInCombat = isInCombat
        end

        UpdateFoodBuff(player)
        local health, maxHealth = GetUnitPower(player.PingTag, POWERTYPE_HEALTH)
        UpdatePlayerHealth(player, health, maxHealth) -- Calls update offline player
    end
end

--[[
	OnTimedUpdate fires TGT_PLAYER_DATA_REFRESH callbacks, if needed
]]--
local function OnTimedUpdate()
    -- Only if player is in group
    if (GetIsUnitGrouped()) then
        local functionTimestamp = GetGameTimeMilliseconds()

        UpdatePlayerStatus()
	    FireCallbacksAsync(TGT_PLAYER_DATA_REFRESH)

        -- Send data
        if (_settingsHandler.SavedVariables.IsSendingDataActive) then
            if (_lastMessageType == nil or _lastMessageType == MESSAGE_PLAYER_HPS) then
                TGT_Communicator.SendData(GetMyselfData(MESSAGE_PLAYER_RESOURCES), MESSAGE_PLAYER_RESOURCES)
                _lastMessageType = MESSAGE_PLAYER_RESOURCES
            elseif (_lastMessageType == nil or _lastMessageType == MESSAGE_PLAYER_RESOURCES) then
                local player, updateNeeded = GetMyselfData(MESSAGE_PLAYER_DPS)

                if (updateNeeded) then
                    TGT_Communicator.SendData(player, MESSAGE_PLAYER_DPS)
                else
                    TGT_Communicator.SendData(GetMyselfData(MESSAGE_PLAYER_RESOURCES), MESSAGE_PLAYER_RESOURCES)
                end

                _lastMessageType = MESSAGE_PLAYER_DPS
            elseif (_lastMessageType == nil or _lastMessageType == MESSAGE_PLAYER_DPS) then
                local player, updateNeeded = GetMyselfData(MESSAGE_PLAYER_HPS)

                if (updateNeeded) then
                    TGT_Communicator.SendData(player, MESSAGE_PLAYER_HPS)
                else
                    TGT_Communicator.SendData(GetMyselfData(MESSAGE_PLAYER_RESOURCES), MESSAGE_PLAYER_RESOURCES)
                end

                _lastMessageType = MESSAGE_PLAYER_HPS
            end
        end

        _logger:logTrace("TGT_PlayerHandler -> OnTimedUpdate", GetGameTimeMilliseconds() - functionTimestamp)
    end
end

--[[
	Called on new data from Communication
]]--
local function MockPlayerData(pingPlayer)
    local pingTag = pingPlayer.PingTag

    for i = 1, GetGroupSize() do
        pingPlayer.PingTag = pingTag .. tostring(i)
        if (i <= 4) then
            pingPlayer.GroupAbilityPing = 1
        elseif (i <= 8) then
            pingPlayer.GroupAbilityPing = 6
        elseif (i <= 12) then
            pingPlayer.GroupAbilityPing = 13
        elseif (i <= 16) then
            pingPlayer.GroupAbilityPing = 15
        elseif (i <= 20) then
            pingPlayer.GroupAbilityPing = 25
        else
            pingPlayer.GroupAbilityPing = 27
        end
        UpdatePlayerData(pingPlayer)
    end
end

--[[
	Called on new data from Communication
]]--
local function OnData(pingPlayer)
    if (pingPlayer ~= nil) then
        local functionTimestamp = GetGameTimeMilliseconds()
        if (TGT_MOCKED) then
            MockPlayerData(pingPlayer)
        else
            UpdatePlayerData(pingPlayer)
        end
        _logger:logTrace("PlayerHandler -> OnData", GetGameTimeMilliseconds() - functionTimestamp)
    else
        _logger:logError("PlayerHandler -> OnMapPing; Ping invalid ultimateGroup: " .. tostring(ultimateGroup) .. "; relativeUltimate: " .. tostring(relativeUltimate))
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	GetRemoteGroupPlayers returns internal group players, filtered by remote attribute
]]--
function TGT_PlayerHandler.GetRemoteGroupPlayers()
    local remotePlayers = {}

    for i,player in pairs(_groupPlayers) do
        if (player.LastMapPingTimestamp ~= 0) then
            remotePlayers[player.PlayerName] = player
        end
    end

    return remotePlayers
end

--[[
	GetGroupPlayers returns internal group players
]]--
function TGT_PlayerHandler.GetGroupPlayers()
    return _groupPlayers
end

--[[
	SetPlayerSubGroup sets sub group for player and sets in SettingsHandler
]]--
function TGT_PlayerHandler.SetPlayerSubGroup(groupIdentifer, player)
    if (_groupPlayers[player.PlayerName] ~= nil) then
        _settingsHandler.SavedVariables.PlayerFrameGroups[player.PlayerName] = groupIdentifer
        player.GroupIdentifer = groupIdentifer

        FireCallbacksAsync(TGT_PLAYER_DATA_SUB_GROUP_CHANGED, player)
    else
        _logger:logError("PlayerHandler -> SetPlayerSubGroup; Player not in group list", player.PlayerName)
    end
end

--[[
	Initialize initializes TGT_PlayerHandler
]]--
function TGT_PlayerHandler.Initialize()
    _logger = TGT_LOGGER

    _playerMyself = GetNewPlayer("player")
    _playerMyself.UltimateGroup = 
		TGT_UltimateGroupHandler.GetUltimateGroupByAbilityId(TGT_SettingsHandler.GetStaticUltimateIDSettings())
        
    -- Register events
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_EFFECT_CHANGED, OnEffectChangedEvent)
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnVisualAdded)
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, OnVisualUpdated)
    EVENT_MANAGER:RegisterForEvent(_name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnVisualRemoved)

    -- Start update timer
	EVENT_MANAGER:RegisterForUpdate(_name, REFRESHRATE, OnTimedUpdate)

    -- Register callbacks
    CALLBACK_MANAGER:RegisterCallback(TGT_MAP_PING_CHANGED, OnData)
    CALLBACK_MANAGER:RegisterCallback(TGT_STATIC_ULTIMATE_ID_CHANGED, SetUltimate)
    CALLBACK_MANAGER:RegisterCallback(TAO_GROUP_CHANGED, UpdatePlayers)
    CALLBACK_MANAGER:RegisterCallback(TAO_UNIT_GROUPED_CHANGED, UpdateGroup)
    
    _logger:logTrace("TGT_PlayerHandler -> Initialized")
end