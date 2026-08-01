--	----------------------------------------------------------------------
--	InCombat by Onigar
--	----------------------------------------------------------------------

-- Addon Common Definitions
local ADDON_NAME 		= "InCombat"
local ADDON_AUTHOR 		= "Onigar"
local ADDON_WEBSITE		= "https://www.esoui.com/downloads/info2268-InCombat.html#info"
local ADDON_VERSION		= "1.3.0"
-- Version = MajorVersion.MinorVersion.MiniFixes

local accountEnlightenedState  = true
local charEnlightenedState     = true
local charWasEnlightened       = true
local characterJustLoggedIn    = true
local currentEnlightenedAmount = 0
local storedEnlightenedAmount  = 0
local accumulatedExpGain       = 10000
local dailyEnlightenedAmount   = 400000


-- Create a namespace for the addon by declaring a top-level table that will hold everything else.
InCombat = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
InCombat.name = "InCombat"

-- Next we create a function that will initialize our addon
function InCombat:Initialize()

	-- EVENT_PLAYER_COMBAT_STATE (bool inCombat)
	-- inCombat is true if the player just entered combat, and false if the player just ended combat.

	self.inCombat = IsUnitInCombat("player")

	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)

	-- EVENT_COMBAT_EVENT (integer eventCode, integer result, bool isError, string abilityName, 
	-- integer abilityGraphic, integer abilityActionSlotType, string sourceName, integer sourceType, 
	-- string targetName, integer targetType, integer hitValue, integer powerType, integer damageType, bool log)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnCombatEvent)

	--EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ (character login), self.JustLoggedIn)
end

-- returns a number to a given number of decimal places
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function ShowEnlightenedInfo()

	local numberEnlightenedDays = 0
	
	-- from ESOUI function API List
    -- Search on ESOUI Source Code GetEnlightenedMultiplier()
        -- Returns: number multiplier 
    -- Search on ESOUI Source Code GetEnlightenedPool()
        -- Returns: number poolAmount 
    -- Search on ESOUI Source Code IsEnlightenedAvailableForAccount()
        -- Returns: boolean availableForAccount 
    -- Search on ESOUI Source Code IsEnlightenedAvailableForCharacter()
        -- Returns: boolean availableForCharacter 
	
	if IsEnlightenedAvailableForAccount() then
		if IsEnlightenedAvailableForCharacter() then
			
			-- this calculation is as shown in the ESOUI API code for IsEnlightenedAvailableForCharacter()
			-- takes an accumulated "pool" value and applies a 4x multiplier.
			-- it gives the same enlightenment value as mousing over EXP Bar
			currentEnlightenedAmount = GetEnlightenedPool() * (GetEnlightenedMultiplier() + 1)
			
			-- reduce spamming: only output message after a preset accumulated experience gain
			-- storedEnlightenedAmount will initially be zero
			-- should set this in an Initialise function and remove test from here -- todo
			if storedEnlightenedAmount > currentEnlightenedAmount + accumulatedExpGain or
				storedEnlightenedAmount == 0 then
			
				if charWasEnlightened then
					d("inCombat: Enlightenment available = " .. zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(currentEnlightenedAmount)))
					
					if currentEnlightenedAmount > 0 then
						numberEnlightenedDays = currentEnlightenedAmount / dailyEnlightenedAmount
						numberEnlightenedDays = round(numberEnlightenedDays, 1)
						d("inCombat: Days worth of stored Enlightment (Max 12) = " .. zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(numberEnlightenedDays)) .. " Days")
						
						--d("inCombat: Enlightenment Pool = " .. zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(GetEnlightenedPool())))
						--d("inCombat: Enlightenment Level Scaling Multiplier = " .. (GetEnlightenedMultiplier() + 1))
					end
				end
				storedEnlightenedAmount = currentEnlightenedAmount
			end
			
			-- control to determine display of messages next cycle
			if storedEnlightenedAmount > 0 then
				charWasEnlightened = true
			else
				charWasEnlightened = false
			end
		else
			-- will only display max 1 time per login or after reoadui
			if charEnlightenedState then
				charEnlightenedState = false
				d("inCombat: Enlightenment is not available for this character")
			end
		end
	else
		-- will only display max 1 time per login or after reoadui
		if accountEnlightenedState then
			accountEnlightenedState = false
			d("inCombat: Enlightenment is not available for this account")
		end
	end
end


function InCombat.OnPlayerCombatState(event, inCombat)
	-- detect if player is level 50
	local isChampion = IsUnitChampion("player")

	-- The ~= operator is "not equal to" in Lua.
	if inCombat ~= InCombat.inCombat then
		-- The player's state has changed. Update the stored state...
		InCombat.inCombat = inCombat

		-- ...and then announce the change.
		if inCombat then
			d("inCombat: Entering combat.")
		else
			d("inCombat: Exiting combat.")

			if isChampion then
				-- after leaving Combat display current Enlightenment in chat window
				ShowEnlightenedInfo()
			end
		end
	end
end

--[[ 
 * Runs on the EVENT_COMBAT_EVENT listener.
 * This handler fires every time a combat effect is registered on a valid unitTag
 ]]--
function InCombat.OnCombatEvent( eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log )

	if InCombat.inCombat and hitValue > 0 then
		--d("OnCombatEvent")
		--d("Source=" .. sourceType)
		--d("Target=" .. targetType)
		-- this is ok
		--d( "combatData>> source="..sourceName..",srcType="..sourceType..",target="..targetName..",tgtType="..targetType..",damage="..hitValue )
	
		-- Display all combat events for debugging
		--d( "Raw>> [eventCode=" ..eventCode .. "]," .. "[" ..result .. "]," .. "[" ..abilityName .. "]," .. "[" ..sourceName .. "]," .. "[" ..sourceType .. "]," .. "[" ..targetName .. "]," .. "[" ..targetType .. "]," .. "[" ..hitValue .. "]," .. "[" ..abilityActionSlotType .. "]," .. "[" ..powerType .. "]," .. "[" ..damageType .. "]" )
		--d( "Inf>> [eventCode=" ..eventCode .. "],"  .. "[damageType=" ..damageType .. "]" )

	end
	
	-- Verify it's a valid result type
	--isValid, result , abilityName , sourceType , sourceName , targetName , hitValue = FTC.Damage:Filter( result , abilityName , sourceType , sourceName , targetName , hitValue )
	--if not isValid then return end
	
	-- Determine the context
	--local context = ( sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET ) and "Out" or ""
	--if ( sourceType == COMBAT_UNIT_TYPE_NONE ) then context = "In"
	--elseif ( sourceType == COMBAT_UNIT_TYPE_GROUP ) then context = "Group" end

	-- Strip parentheses from name
	--abilityName = string.gsub ( abilityName , ' %(.*%)' , "" )
	
	-- Localize damage sources
	--abilityName = SanitizeLocalization(abilityName)
	
	-- Setup a new damage object
	local combatData = {
		["target"]	= targetName,
		["source"]	= sourceName,
		["name"]	= abilityName,
		["result"]	= result,
		["damage"]	= hitValue,
		["power"]	= powerType,
		["type"]	= damageType,
		--["ms"]		= GetGameTimeMilliseconds(),
		--["crit"]	= ( result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_DOT_TICK_CRITICAL or result == ACTION_RESULT_HOT_TICK_CRITICAL ) and true or false,
		--["heal"]	= ( result == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL or result == ACTION_RESULT_HOT_TICK or result == ACTION_RESULT_HOT_TICK_CRITICAL ) and true or false,
		--["multi"]	= 1,
	}
	
	--d( "combatData>> source=" ..combatData.source .. " <<" )
	--d( "combatData>> source=" ..combatData.source .. ", target=" ..combatData.target .. ", damage=" ..combatData.damage .. )
	
	-- Pass damage to scrolling combat text
	--if ( FTC.init.SCT and context ~= "Group" ) then FTC.SCT:NewSCT( damage , context ) end
	
	-- Pass damage to damage meter tracking
	--if ( FTC.init.Damage ) then	FTC.Damage:UpdateMeter( damage , context ) end
	
	-- Pass damage to a callback for extensions to use
	--CALLBACK_MANAGER:FireCallbacks( "FTC_NewDamage" , damage )
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function InCombat.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == InCombat.name then
    InCombat:Initialize()
  end
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(InCombat.name, EVENT_ADD_ON_LOADED, InCombat.OnAddOnLoaded)