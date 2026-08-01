--Library: libPotionBuff
--Description: Determine if a potion was used (by the help of it's buff) and get its cooldown etc.
--Author: Baertram
--Thanks to:
-- Ayantir: For the potion buff info
-- Scootworks: For the libFoodDrinkBuff idea

local LIB_IDENTIFIER = "LibPotionBuff"
assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " has already been loaded")
local LIB_VERSION    = "3.0"

local lib = {}
lib.version = LIB_VERSION
lib.name = LIB_IDENTIFIER

lib.chat = {}
if LibChatMessage then
	lib.chat = LibChatMessage(LIB_IDENTIFIER, "LibPB")
end
if not lib.chat.Print then
	lib.chat.Print = function(self, message) df("[%s] %s", LIB_IDENTIFIER, message) end
end

--------------------
-- POTIONs --
--------------------
--Potions
--Ability IDs for the potions

--Crafted potion buffs
local isCrafted = {
	[45222] = true, --"Major Fortitude",
	[45224] = true, --"Major Intellect",
	[45226] = true, --"Major Endurance",
	[45236] = true, --"Increase Detection",
	[45237] = true, --"Vanish",
	[45239] = true, --"Unstoppable",

	[46113] = true, --"Health Potion Poison",
	[46193] = true, --"Ravage Magicka",
	[46199] = true, --"Ravage Stamina",
	[46202] = true, --"Minor Cowardice",
	[46204] = true, --"Minor Maim",
	[46206] = true, --"Minor Breach",
	[46208] = true, --"Minor Fracture",
	[46210] = true, --"Hindrance",

	[47203] = true, --"Minor Enervation",

	[64555] = true, --"Major Brutality",
	[64558] = true, --"Major Sorcery",
	[64562] = true, --"Major Ward",
	[64566] = true, --"Major Expedition",
	[64568] = true, --"Major Savagery",
	[64570] = true, --"Major Prophecy",

	[79705] = true, --"Lingering Restore Health",
	[79709] = true, --"Creeping Ravage Health",
	[79712] = true, --"Minor Protection",
	[79848] = true, --"Major Vitality",
	[79860] = true, --"Minor Defile",
}
--Non-crafted potion buffs (bought at a vendor or found)
local isNonCrafted = {
	[63672] = true, --"Major Fortitude",
	[63678] = true, --"Major Intellect",
	[63683] = true, --"Major Endurance",

	[72928] = true, --"Major Fortitude",
	[72930] = true, --"Unstoppable",
	[72932] = true, --"Major Intellect",
	[72933] = true, --"Major Sorcery",
	[72935] = true, --"Major Endurance",
	[72936] = true, --"Major Brutality",

	[78054] = true, --"Major Endurance",
	[78058] = true, --"Vanish",
	[78080] = true, --"Major Endurance",
	[78081] = true, --"Major Expedition",
}
--Crown-Store potion buffs
local isCrownStore = {
	[68405] = true, --"Major Fortitude",
	[68406] = true, --"Major Intellect",
	[68408] = true, --"Major Endurance",

	[86683] = true, --"Major Intellect",
	[86684] = true, --"Major Prophecy",
	[86685] = true, --"Major Sorcery",
	[86693] = true, --"Major Endurance",
	[86694] = true, --"Major Savagery",
	[86695] = true, --"Major Brutality",
	[86697] = true, --"Major Fortitude",
	[86698] = true, --"Unstoppable",
	[86699] = true, --"Invisibility",
	[86780] = true, --"Invisibility",
}

---------------
-- VARIABLEs --
---------------
--Debug message output divider
local DIVIDER = ZO_ERROR_COLOR:Colorize("____________________________________")

--The unitTag for the active playing player
local PLAYER_TAG = "player"


---------------
-- FUNCTIONS --
---------------
function lib:GetTimeLeftInSeconds(timeInMilliseconds)
    -- Calculate time left in seconds of buff
	return math.max(zo_roundToNearest(timeInMilliseconds-(GetGameTimeMilliseconds()/1000), 1), 0)
end

function lib:GetPotionBuffInfos(unitTag)
-- Parameter: string unitTag - any unitTag (http://wiki.esoui.com/UnitTag)
-- Returns: boolean isBuffActive, bool isCrafted, bool isFromCrownStore, number abilityId, string buffName, number timeStarted, number timeEnds, textureString iconTexture
    unitTag = unitTag or PLAYER_TAG
    local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		for i = 1, numBuffs do
			-- get buff infos
			--** _Returns: _buffName_, _timeStarted_, _timeEnding_, _buffSlot_, _stackCount_, _iconFilename_, _buffType_, _effectType_, _abilityType_, _statusEffectType_, _abilityId_, _canClickOff_
			local buffName, timeStarted, timeEnding, _, _, iconTexture, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
			local buffTypeCrafted       = isCrafted[abilityId] or false
            local buffTypeNonCrafted    = isNonCrafted[abilityId] or false
            local buffTypeCrownStore    = isCrownStore[abilityId] or false
			local buffActive = false
			-- It's a drink?
			if buffTypeCrafted then
                buffActive = buffTypeCrafted
			elseif buffTypeNonCrafted then
                buffActive = buffTypeNonCrafted
            elseif buffTypeCrownStore then
                buffActive = buffTypeCrownStore
			end
            -- return if active
			if buffActive then
                return buffActive, buffTypeCrafted, buffTypeCrownStore, abilityId, zo_strformat("<<C:1>>", buffName), timeStarted, timeEnding, iconTexture
			end
		end
	end
	return false, nil, nil, nil, nil, nil, nil, nil
end

function lib:IsPotionBuffActive(unitTag)
-- Parameter: string unitTag - any unitTag (http://wiki.esoui.com/UnitTag)
-- Returns: bool isBuffActive
    unitTag = unitTag or PLAYER_TAG
    local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		for i = 1, numBuffs do
			local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
				if isCrafted[abilityId] or isNonCrafted[abilityId] or isCrownStore[abilityId] then
				return true
			end
		end
	end
	return false
end

function lib:IsPotionBuffActiveAndGetTimeLeft(unitTag)
-- Parameter: string unitTag - any unitTag (http://wiki.esoui.com/UnitTag)
-- Returns: bool isBuffActive, number timeLeftInSeconds , number abilityId
	unitTag = unitTag or PLAYER_TAG
    local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		for i = 1, numBuffs do
			local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
            if isCrafted[abilityId] or isNonCrafted[abilityId] or isCrownStore[abilityId] then
				return true, lib:GetTimeLeftInSeconds(timeEnding), abilityId
			end
		end
	end
	return false, 0, nil
end

function lib:GetPotionSlotCooldown(chatOutput)
    -- Parameter:   boolean chatOutput: true = output the info to the chat; false = do not show anyhting into the chat
    -- Returns:     number timeLeftInMilliseconds, number buffTotalCooldownInMilliseconds
    chatOutput = chatOutput or false
    -- GetSlotCooldownInfo(*luaindex* _slotIndex_)
    -- _Returns:_ *integer* _remain_, *integer* _duration_, *bool* _global_, *[ActionBarSlotType|#ActionBarSlotType]* _globalSlotType_

    --Get the quicklsot index slot ID (quickslot index) = 9
    local remain, duration = GetSlotCooldownInfo(GetCurrentQuickslot())
    if chatOutput then
        d("Potion cooldown active, remaining: " .. tostring(remain) .. " of " .. tostring(duration))
    end
    return remain, duration
end

function lib:IsAbilityACraftedPotionBuff(abilityId)
	--Parameter: integer abilityId - any abilityId (http://esoitem.uesp.net/viewlog.php?record=minedSkills)
	-- Returns: nilable:bool IsAbilityACraftedPotionBuff(true) or false if not, or nil if not any potion buff
	if nil == abilityId then return nil end
	if isCrafted[abilityId] then return true end        --> True
	if isNonCrafted[abilityId] then return false end
    if isCrownStore[abilityId] then return false end
	return nil
end

function lib:IsAbilityACrownStorePotionBuff(abilityId)
	--Parameter: integer abilityId - any abilityId (http://esoitem.uesp.net/viewlog.php?record=minedSkills)
    -- Returns: nilable:bool isAbilityACrownStorePotionBuff(true) or false if not, or nil if not any potion buff
    if nil == abilityId then return nil end
    if isCrafted[abilityId] then return false end
    if isNonCrafted[abilityId] then return false end
    if isCrownStore[abilityId] then return true end     --> True
    return nil
end

function lib:IsAbilityAPotionBuff(abilityId)
	--Parameter: integer abilityId - any abilityId (http://esoitem.uesp.net/viewlog.php?record=minedSkills)
	-- Returns: bool isAbilityAnActivePotionBuff(true) or false if not
    if nil == abilityId then return nil end
    if isCrafted[abilityId] or isNonCrafted[abilityId] or isCrownStore[abilityId] then return true end
    return false
end

-- Filter the event EVENT_EFFECT_CHANGED to the local player and only the abilityIds of the potion buffs
-- Possible additional filterTypes are: REGISTER_FILTER_UNIT_TAG, REGISTER_FILTER_UNIT_TAG_PREFIX
--> Performance gain as you check if a potion buff got active (gained, refreshed), or was  removed (faded, refreshed)
function lib:RegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace, callbackFunc, filterType, filterParameter)
	if addonEventNameSpace == nil or addonEventNameSpace == "" then return nil end
	if callbackFunc == nil or type(callbackFunc) ~= "function" then return nil end
	local eventCounter = 0
	for abilityId, _ in pairs(isCrafted) do
		eventCounter = eventCounter + 1
		local eventName = addonEventNameSpace .. eventCounter
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, callbackFunc)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, filterType, filterParameter)
	end
	for abilityId, _ in pairs(isNonCrafted) do
		eventCounter = eventCounter + 1
		local eventName = addonEventNameSpace .. eventCounter
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, callbackFunc)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, filterType, filterParameter)
	end
    for abilityId, _ in pairs(isCrownStore) do
        eventCounter = eventCounter + 1
        local eventName = addonEventNameSpace .. eventCounter
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, callbackFunc)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, filterType, filterParameter)
    end
	return true
end

-- Unregister the register function above
function lib:UnRegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace)
    local eventCounter = 0
    if addonEventNameSpace == nil or addonEventNameSpace == "" then return nil end
    for abilityId, _ in pairs(isCrafted) do
        eventCounter = eventCounter + 1
        local eventName = addonEventNameSpace .. eventCounter
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_EFFECT_CHANGED)
    end
    for abilityId, _ in pairs(isNonCrafted) do
        eventCounter = eventCounter + 1
        local eventName = addonEventNameSpace .. eventCounter
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_EFFECT_CHANGED)
    end
    for abilityId, _ in pairs(isCrownStore) do
        eventCounter = eventCounter + 1
        local eventName = addonEventNameSpace .. eventCounter
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_EFFECT_CHANGED)
    end
    return true
end

-------------
-- GLOBALS --
-------------
lib.IS_CRAFTED_POTION_BUFF      = isCrafted
lib.IS_NON_CRAFTED_POTION_BUFF  = isNonCrafted
lib.IS_CROWNSTORE_POTION_BUFF   = isCrownStore

-----------
-- DEBUG --
-----------
local function debugInfoStart()
    return DIVIDER .. "\n" .. string.format(ZO_ERROR_COLOR:Colorize("|cFF0000%s Debug:|r"), LIB_IDENTIFIER)
end

------------------
-- GLOBAL DEBUG --
------------------
--Same function exists within library LibFoodDrinBuff. Make sure to keep both functions the same!
function DEBUG_ACTIVE_BUFFS(unitTag)
	unitTag = unitTag or PLAYER_TAG
	local entries = {}
    table.insert(entries, debugInfoStart())
	table.insert(entries, zo_strformat("\"<<1>>\" Buffs:", unitTag))
	local buffName, abilityId, _
	local numBuffs = GetNumBuffs(unitTag)
	if numBuffs > 0 then
		for i = 1, numBuffs do
			buffName, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
			table.insert(entries, zo_strformat("<<1>>. [<<2>>] <<C:3>>", i, abilityId, ZO_SELECTED_TEXT:Colorize(buffName)))
		end
	else
		table.insert(entries, GetString(SI_LIB_FOOD_DRINK_BUFF_NO_BUFFS) or "<NO buffs active!")
	end
    table.insert(entries, DIVIDER)
	lib.chat:Print(table.concat(entries, "\n"))
end

--Show info about active potion buff into chat
function DEBUG_ACTIVE_POTION_BUFFS(unitTag)
    unitTag = unitTag or PLAYER_TAG
	local entries = {}
    table.insert(entries, debugInfoStart())
	table.insert(entries, zo_strformat("\"<<1>>\" potion buffs:", unitTag))
    local buffActive, buffTypeCrafted, buffTypeCrownStore, abilityId, buffName, _, timeEnding, iconTexture = lib:GetPotionBuffInfos(unitTag)
    if buffActive then
        local buffTimeLeft = lib:GetTimeLeftInSeconds(timeEnding)
        local iconTextureStr = zo_iconTextFormatNoSpace(iconTexture, 24, 24)
        table.insert(entries, zo_strformat("[<<1>>] Name: <<C:2>>, isCrafted: <<3>>, isFromCrownStore: <<4>>, abilityId: <<5>>, time left: <<6>>",
            iconTextureStr,
            buffName,
            tostring(buffTypeCrafted),
            tostring(buffTypeCrownStore),
            abilityId,
            buffTimeLeft)
        )
    else
        table.insert(entries, "<NO potion buffs currently active!")
    end
    table.insert(entries, DIVIDER)
	lib.chat:Print(table.concat(entries, "\n"))
end

--Global variable of the library: LibPotionBuff
_G[LIB_IDENTIFIER] = lib