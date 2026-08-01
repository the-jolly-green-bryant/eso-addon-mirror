NTCam = {}
local NTakCamera = NTCam
local ADDON_NAME = "NTakCamera"
local texts	= NTCam_Texts


------------------------------------------
--		UTILITY FUNCTIONS

local function debug(str, force)
	if not(NTakCamera.settings.debug) and not(force) then return end
	if str == nil then str = "nil" end
	d("NTak Camera: " .. str)
end
local function round(value, decimals)
	if decimals == nil then decimals = 0 end
	local e = 10^decimals
	return math.floor(0.5 + (value * e)) / e	
end
local function smooth(val1, val2, factor)
	return (val1 * factor) + (val2 * (1 - factor))
end
local function booltonumber(bool)
	return bool and 1 or 0
end
local function TextPad(pad)
	return "|u" .. pad .. ":::|u"
end
local function TextIcon(path, size, pad)
	--	Prevent nil
	if size == nil then size = 32 end
	--	Format path
	path = "/esoui/" .. path
	-- path = path:gsub("\\", "/")
	--	Format icon with size
	local icon = "|t" .. size .. ":" .. size .. ":" .. path .. "|t"
	--	Add padding
	if pad	~= nil then
		icon = TextPad(pad) .. icon .. TextPad(pad)
    end
	--	Result
    return icon
end
local function numbersign(value)
	if value > 0 then return  1 end
	if value < 0 then return -1 end
	return 0
end
local function copyTree(elm)
    local copy
    if type(elm) == 'table' then
		-- Copy object by iterating into it
        copy = {}
        for key, val in next, elm, nil do
            copy[copyTree(key)] = copyTree(val)
        end
        setmetatable(copy, copyTree(getmetatable(elm)))
    else
		-- Not a table, simple copy
        copy = elm
    end
    return copy
end
function math.average(a)
  local s = 0
  for _,v in pairs(a) do
    s = s + v
  end
  return s / #a
end
function math.round(a, e)
	local b = 10^e
	return math.floor((a*b)+0.5) / b
end


------------------------------------------
--		INITIALIZATIONS

--	Variables from languages files
local shoulderSideCenter	= texts.cat1.choices[1]
local shoulderSideLeft		= texts.cat1.choices[2]
local shoulderSideRight		= texts.cat1.choices[3]
local presetNone			= texts.menuX.choices[1]
local presetCenter3rd		= texts.menuX.choices[2]
local presetSwitch1st		= texts.menuX.choices[3]
local presetSwitch3rd		= texts.menuX.choices[4]
local presetDistant			= texts.menuX.choices[5]
local presetFocus			= texts.menuX.choices[6]
local presetCustom			= texts.menuX.choices[7]

--	Icons for options
NTakCamera.icons = {
	--	Interactions
	["Chat"]		= TextIcon('art/chatwindow/chat_notification_up.dds',				32),
	["Craft"]		= TextIcon('art/treeicons/store_indexicon_craftingmotiff_up.dds',	32),
	["Outfit"]		= TextIcon('art/icons/mapkey/mapkey_outfitstation.dds',				28, 2),
	["Lockpick"]	= TextIcon('art/icons/lockpick.dds',								28, 2),
	--	Events	
	["Move"]		= TextIcon('art/icons/gear_breton_medium_feet_a.dds',				24, 4),
	["Mount"] 		= TextIcon('art/mounts/tabicon_mounts_up.dds',						32),
	["Stealth"]		= TextIcon('art/tutorial/stealth-seen.dds',							32),
	["Wield"]		= TextIcon('art/inventory/inventory_tabicon_weapons_up.dds',		32),
	["Combat"]		= TextIcon('art/progression/progression_tabicon_weapons_active.dds',32),
	["Werewolf"]	= TextIcon('art/icons/store_werewolfbite_01.dds',					28, 2),
}

--	Camera initialize
local shoulderCoef = 1
function InitCameraValues(init)
	local name		= "Preferred camera"
	local static	= NTakCamera.settings.staticCamera > 0
	if static then
    --	STATIC CAMERAS
		name = "staticCamera" .. NTakCamera.settings.staticCamera
		local staticCameraX = NTakCamera.settings[name]
		name = "Static Camera #" .. NTakCamera.settings.staticCamera -- Better for chat output
		
		--	Load static cameras
		SetCameraDistance(staticCameraX.distance, true)
		SetCameraFieldOfView(staticCameraX.fieldOfView, true)
		SetCameraVOffset(staticCameraX.verticalPosition)
		SetCameraHOffset(staticCameraX.horizontalPosition)

		--	The below trick updates the camera without transition
		-- ToggleGameCameraFirstPerson()
		-- ToggleGameCameraFirstPerson()
		--	But what causing issues when switching from/to 1st person.
    else
    --	PREFERRED CAMERA
		--	Position calculation
		shoulderCoef = 1
		if (NTakCamera.settings.defaultHorizontalSide == shoulderSideCenter) then
			shoulderCoef = shoulderCoef / 1024
		end
		if (NTakCamera.settings.defaultHorizontalSide == shoulderSideLeft) then
			shoulderCoef = shoulderCoef * -1
		end
    
		--	Load default settings
		SetCameraDistance(NTakCamera.settings.defaultDistance, true)
		SetCameraFieldOfView(NTakCamera.settings.defaultFieldOfView, true)
		SetCameraPosition(
			shoulderCoef * NTakCamera.settings.defaultHorizontalOffset,
			NTakCamera.settings.defaultVerticalOffsetMin,
			true, true, true
		)
    end

	--	Initialize saved values
	SaveCameraSettings(true)

	--	Escape if nothing more to do
	if not((init == 1) or NTakCamera.settings.debug) then return end
	
	--	Debug output
	local t = 0
	if init == 1 then
		if not(static) then return end
		t = 5000
		name = name .. " on init."
	end
	
	--	Message
	zo_callLater(function()
		debug("Loaded " .. name, true)
	end, t)
end

--	Block interaction list
local blockInteractions
function InitBlockingInteractions()
	blockInteractions = {
		--	Dialogs
		[INTERACTION_BANK]					= NTakCamera.settings.chatPreventCam,
		[INTERACTION_BUY_BAG_SPACE]			= NTakCamera.settings.chatPreventCam,
		[INTERACTION_CONVERSATION]			= NTakCamera.settings.chatPreventCam,
		[INTERACTION_GUILDBANK]				= NTakCamera.settings.chatPreventCam,
		[INTERACTION_PAY_BOUNTY]			= NTakCamera.settings.chatPreventCam,
		[INTERACTION_QUEST]					= NTakCamera.settings.chatPreventCam,
		[INTERACTION_STABLE]				= NTakCamera.settings.chatPreventCam,
		[INTERACTION_STORE]					= NTakCamera.settings.chatPreventCam,
		[INTERACTION_TRADINGHOUSE]			= NTakCamera.settings.chatPreventCam,
		[INTERACTION_VENDOR]				= NTakCamera.settings.chatPreventCam,
		[INTERACTION_RETRAIT]				= NTakCamera.settings.chatPreventCam,
		--	Crafting
		[INTERACTION_CRAFT]					= NTakCamera.settings.craftPreventCam,
		--	Styling
		[INTERACTION_DYE_STATION]			= NTakCamera.settings.stylePreventCam,
		--	Lockpick
		[INTERACTION_LOCKPICK] 				= NTakCamera.settings.lockpickPreventCam,
		--	Others
		-- [INTERACTION_BOOK] 				=
		-- [INTERACTION_SIEGE] 				=
		[INTERACTION_FURNITURE] 			= false,
	}
end

--	States helpers
local stealthStates = {
	STEALTH_STATE_NONE,						--	0
	STEALTH_STATE_DETECTED,					--	1
	STEALTH_STATE_HIDING,					--	2
	STEALTH_STATE_HIDDEN,					--	3
	STEALTH_STATE_STEALTH,					--	4
	STEALTH_STATE_HIDDEN_ALMOST_DETECTED,	--	5
	STEALTH_STATE_STEALTH_ALMOST_DETECTED,	--	6
}
function IsStealthed(value) -- value = playerStealthState
	if value == nil then
		value = GetUnitStealthState("player")
	end
	-- local state = stealthStates[value]
	return not(stealthStates[value] == nil)
end
local function IsHidden(value)	return (value >= STEALTH_STATE_HIDDEN)	end
local function IsWielding()		return not(ArePlayerWeaponsSheathed())	end
local function IsInCombat()		return IsUnitInCombat("player")			end


------------------------------------------
--		INTERACTION/EVENT HANDLING

--	State variables
local flagInStealth	= IsStealthed("player")
local flagIsWield	= IsWielding()
local flagInCombat	= IsInCombat()
local flagInRide	= IsMounted()
local flagInWolf	= IsWerewolf()
local flagInMove 	= false

--	Handle chat state change
local flagInChat = false
function OnChatter()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if flagInRide and NTakCamera.settings.ridePreventChange then return end
	if flagInChat then return end
	debug("Chat ON")
	if NTakCamera.settings.chatPrevent == false then return end
	if NTakCamera.settings.chatAction == presetNone then return end
	--	Save
	SaveCameraSettings()
	--	Flag
	flagInChat = true
	--	Update values
	SetCameraDistance(NTakCamera.settings.chatDistance, NTakCamera.settings.chatDoDistance)
	SetCameraFieldOfView(NTakCamera.settings.chatFieldOfView, NTakCamera.settings.chatDoFieldOfView)
	SetCameraPosition(
		NTakCamera.settings.chatHorizontalPos, NTakCamera.settings.chatVerticalOffset, false,
		NTakCamera.settings.chatDoHorizontalPos, NTakCamera.settings.chatDoVerticalOffset
	)
end
function OffChatter()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if not(flagInChat) then return end
	debug("Chat OFF")
	
	--	Set as done and restore settings
	flagInChat = false
	LoadCameraSettings()
end

--	Handle craft state change
local flagInCraft = false
function OnCrafting()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if flagInRide and NTakCamera.settings.ridePreventChange then return end
	if flagInCraft then return end
	debug("Crafting ON")
	if NTakCamera.settings.craftPrevent == false then return end
	if NTakCamera.settings.craftAction == presetNone then return end
	--	Save
	SaveCameraSettings()
	--	Flag
	flagInCraft = true
	--	Update values
	SetCameraDistance(NTakCamera.settings.craftDistance, NTakCamera.settings.craftDoDistance)
	SetCameraFieldOfView(NTakCamera.settings.craftFieldOfView, NTakCamera.settings.craftDoFieldOfView)
	SetCameraPosition(
		NTakCamera.settings.craftHorizontalPos, NTakCamera.settings.craftVerticalOffset, false,
		NTakCamera.settings.craftDoHorizontalPos, NTakCamera.settings.craftDoVerticalOffset
	)
end
function OffCrafting()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if not(flagInCraft) then return end
	debug("Crafting OFF")
	
	--	Set as done and restore settings
	flagInCraft = false
	LoadCameraSettings()
end

--	Handle style state change
local flagInStyle = false
function OnStyling()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if flagInRide and NTakCamera.settings.ridePreventChange then return end
	if flagInStyle then return end
	debug("Styling ON")
	if NTakCamera.settings.stylePrevent == false then return end
	if NTakCamera.settings.styleAction == presetNone then return end
	--	Save
	SaveCameraSettings()
	--	Flag
	flagInStyle = true
	--	Update values
	SetCameraDistance(NTakCamera.settings.styleDistance, NTakCamera.settings.styleDoDistance)
	SetCameraFieldOfView(NTakCamera.settings.styleFieldOfView, NTakCamera.settings.styleDoFieldOfView)
	SetCameraPosition(
		NTakCamera.settings.styleHorizontalPos, NTakCamera.settings.styleVerticalOffset, false,
		NTakCamera.settings.styleDoHorizontalPos, NTakCamera.settings.styleDoVerticalOffset
	)
end
function OffStyling()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if not(flagInStyle) then return end
	debug("Styling OFF")
	
	--	Set as done and restore settings
	flagInStyle = false
	LoadCameraSettings()
end

--	Handle lockpick state change
local flagInLockpick = false
function OnLockpick()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if flagInLockpick then return end
	if NTakCamera.settings.lockpickPrevent == false then return end
	if NTakCamera.settings.lockpickAction == presetNone then return end
	debug("Lockpicking ON")
	--	Save
	SaveCameraSettings()
	--	Flag
	flagInLockpick = true
	--	Update values
	SetCameraDistance(NTakCamera.settings.lockpickDistance, NTakCamera.settings.lockpickDoDistance)
	SetCameraFieldOfView(NTakCamera.settings.lockpickFieldOfView, NTakCamera.settings.lockpickDoFieldOfView)
	SetCameraPosition(
		NTakCamera.settings.lockpickHorizontalPos, NTakCamera.settings.lockpickVerticalOffset, false,
		NTakCamera.settings.lockpickDoHorizontalPos, NTakCamera.settings.lockpickDoVerticalOffset
	)
end
function OffLockpick()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if not(flagInLockpick) then return end
	debug("Lockpicking OFF")
	
	--	Set as done and restore settings
	flagInLockpick = false
	LoadCameraSettings()
end


--	EVENTS

--	Handle stealth state change
function OnStealthStateChanged(event, unit, stealthState)
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if NTakCamera.settings.stealthAction == presetNone then return end

	--	Debug
	debug("Stealth state #" .. stealthState)

	--	Continue
	local inStealth = IsStealthed(stealthState)
	if flagInStealth ~= inStealth then
		--	If in combat
		if inStealth then
			--	Save
			SaveCameraSettings()
			--	Flag
			flagInStealth = true
			debug("Stealth ON")
			--	Update values
			SetCameraDistance(NTakCamera.settings.stealthDistance, NTakCamera.settings.stealthDoDistance)
			SetCameraFieldOfView(NTakCamera.settings.stealthFieldOfView, NTakCamera.settings.stealthDoFieldOfView)
			SetCameraPosition(
				NTakCamera.settings.stealthHorizontalPos, NTakCamera.settings.stealthVerticalOffset, false,
				NTakCamera.settings.stealthDoHorizontalPos, NTakCamera.settings.stealthDoVerticalOffset
			)
		else
			--	Wait a moment after end of stealth + Added MAGIC 67 to prevent "normal" between 2 stealth
			zo_callLater(OffStealthStateChanged, (NTakCamera.settings.stealthOffDelay * 100) + 67)
		end
	end
end
function OffStealthStateChanged()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	local inStealth = IsStealthed(stealthState)
	if inStealth then return end
	
	--	Debug
	debug("Stealth OFF")
	
	--	Escape if already restored
	if flagInStealth == false then return end
	--	Set as done and restore settings
	flagInStealth = false	
	--	Change settings
	LoadCameraSettings()
end

--	Handle draw/sheath weapon state change
function CheckTogglePlayerWield(v, i)
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if NTakCamera.settings.wieldAction == presetNone then return end

	--	Init on first execution
	if i == nil then
		i = 0
		v = IsWielding()
		debug("“TogglePlayerWield” triggered… Starting check-loop.")
	end
	
	--	If state change
	if v ~= IsWielding() then
		--	IsWielding() returns an info that seems to be ping related
		--	I use a tempo-loop to check state multiple times after the player key-press
		
		debug("“TogglePlayerWield” confirmed [" .. booltonumber(IsWielding()) .. "] on iteration #" .. i .. " (~" .. i * 67 .. "ms)") -- MAGIC!
		
		--	Toggle
		OnTogglePlayerWield()
		return
	end

	--	Limit number of loops
	if i > 16 then
		debug("“TogglePlayerWield” escaping loop: Too many iterations")
		return
	end
	--	Loop
	zo_callLater(function()
		CheckTogglePlayerWield(v, i + 1)
	end, 67) -- MAGIC!
end
function OnTogglePlayerWield(inCombat)
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if NTakCamera.settings.wieldAction == presetNone then return end

	--	Continue
	--	Get current state
	local isWield = IsWielding()
	--	Combat overrides
	if inCombat then
		isWield = true --	should be already drawn if in combat
	end
	--	Do things
	if flagIsWield ~= isWield then
		if isWield then
			--	Save
			SaveCameraSettings()
			--	Flag
			flagIsWield = true
			debug("Wield ON")
			--	Update values
			SetCameraDistance(NTakCamera.settings.wieldDistance, NTakCamera.settings.wieldDoDistance)
			SetCameraFieldOfView(NTakCamera.settings.wieldFieldOfView, NTakCamera.settings.wieldDoFieldOfView)
			SetCameraPosition(
				NTakCamera.settings.wieldHorizontalPos, NTakCamera.settings.wieldVerticalOffset, false,
				NTakCamera.settings.wieldDoHorizontalPos, NTakCamera.settings.wieldDoVerticalOffset
			)
		else
			OffTogglePlayerWield()
		end
	end
end
function OffTogglePlayerWield()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if IsInCombat() then return end
	if flagIsWield == false then return end
	
	--	Escape (loop) if player is still wielding
	if IsWielding() then
		zo_callLater(OffTogglePlayerWield, 400)
		return
	end
	
	--	Set as done and restore settings
	debug("Wield OFF")
	flagIsWield = false
	LoadCameraSettings()
end

--	Handle combat state change
local flagInCombatNb = booltonumber(flagInCombat)
function OnPlayerCombatState(event, inCombat)		
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if flagInRide and NTakCamera.settings.ridePreventChange then return end
  
	--	Trigger wield state
	if NTakCamera.settings.wieldOnCombat then
		if inCombat then
			OnTogglePlayerWield(true)
		else
			OffTogglePlayerWield()
		end
	end
	
	--	Interrupt current interactions
	if inCombat then OffLockpick() end -- TEST
	
	--	Escape
	if NTakCamera.settings.combatAction == presetNone then return end

	--	Continue
	if flagInCombat ~= inCombat then
		--	If in combat
		if inCombat then
			--	Save
			SaveCameraSettings()
			--	Flag
			flagInCombat = true
			flagInCombatNb = flagInCombatNb + 1
			debug("Combat ON")
			--	Update values
			SetCameraDistance(NTakCamera.settings.combatDistance, NTakCamera.settings.combatDoDistance)
			SetCameraFieldOfView(NTakCamera.settings.combatFieldOfView, NTakCamera.settings.combatDoFieldOfView)
			SetCameraPosition(
				NTakCamera.settings.combatHorizontalPos, NTakCamera.settings.combatVerticalOffset, false,
				NTakCamera.settings.combatDoHorizontalPos, NTakCamera.settings.combatDoVerticalOffset
			)
		else
			--	Wait a moment after end of combat
			zo_callLater(OffPlayerCombatState, NTakCamera.settings.combatOffDelay * 100)
		end
	end
end
function OffPlayerCombatState()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if IsUnitInCombat("player") then return end
	if flagInCombat == false then return end
	
	--	Debug
	debug("Combat OFF")
	
	--	Just in case
	OffTogglePlayerWield()
	
	--	Sheath weapon
	if NTakCamera.settings.combatAutoSheath and IsWielding() then
		debug("Combat - Auto-sheath")
		zo_callLater(TogglePlayerWield, 100)
	end
	
	--	Set as done and restore settings
	flagInCombat = false
	--	
	flagInCombatNb = flagInCombatNb - 1
	if flagInCombatNb > 0 then return end
	--	
	LoadCameraSettings()
end

--	Handle riding state change
function OnMountedStateChanged(event, inRide)
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if NTakCamera.settings.rideAction == presetNone then return end

	--	Continue
	if flagInRide ~= inRide then
		if inRide then
			--	Save
			SaveCameraSettings()
			--	Flag
			flagInRide = true
			debug("Ride ON")
			--	Update values
			SetCameraDistance(NTakCamera.settings.rideDistance, NTakCamera.settings.rideDoDistance)
			SetCameraFieldOfView(NTakCamera.settings.rideFieldOfView, NTakCamera.settings.rideDoFieldOfView)
			SetCameraPosition(
				NTakCamera.settings.rideHorizontalPos, NTakCamera.settings.rideVerticalOffset, false,
				NTakCamera.settings.rideDoHorizontalPos, NTakCamera.settings.rideDoVerticalOffset
			)
		else
			OffMountedStateChanged()
		end
	end
end
function OffMountedStateChanged()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if IsMounted() and GetCameraDistance() > 0 then return end -- Ignore status for 1st person

	debug("Ride OFF")
	--	Escape if already restored
	if flagInRide == false then return end
	--	Set as done and restore settings
	flagInRide = false

	--	Switch to combat if active
	if NTakCamera.settings.ridePreventChange then
		LoadCameraSettings(true)	--	Force reload the preferred cam
		if IsInCombat() then OnPlayerCombatState(nil, true) end
		if IsWielding() then OnTogglePlayerWield(true) end
		return
	end
	
	--	Reload the preferred camera
	LoadCameraSettings()
end

--	Handle werewolf state change
function OnWerewolfStateChanged(event, inWolf)
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if NTakCamera.settings.wolfAction == presetNone then return end

	--	Continue
	if flagInWolf ~= inWolf then
		if inWolf then
			--	Save
			SaveCameraSettings()
			--	Flag
			flagInWolf = true
			debug("Werewolf ON")
			--	Update values
			SetCameraDistance(NTakCamera.settings.wolfDistance, NTakCamera.settings.wolfDoDistance)
			SetCameraFieldOfView(NTakCamera.settings.wolfFieldOfView, NTakCamera.settings.wolfDoFieldOfView)
			SetCameraPosition(
				NTakCamera.settings.wolfHorizontalPos, NTakCamera.settings.wolfVerticalOffset, false,
				NTakCamera.settings.wolfDoHorizontalPos, NTakCamera.settings.wolfDoVerticalOffset
			)
		else
			OffWerewolfStateChanged()
		end
	end
end
function OffWerewolfStateChanged()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if IsWerewolf() then return end

	debug("Werewolf OFF")
	--	Escape if already restored
	if flagInWolf == false then return end
	--	Set as done and restore settings
	flagInWolf = false
	LoadCameraSettings()
end


------------------------------------------
--		GETTERS / SETTERS


--	Get/Set Camera Distance
local currentDistance
function GetCameraDistance()
	return tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end
function SetCameraDistance(value, doD)
	--	Escapes
	if not(doD) then return end
	if value == nil then return end
	-- if value == currentDistance then return end -- No, because it can be changed easily by the user
	
	--	Keep wolf distance functionality
	if wolfKeepDistance and flagInWolf then
		value = wolfDistance
	end
	--	Set and save
	SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, value)
	currentDistance = value
end

--	Get/Set Camera Fields of View
local currentFOV
function GetCameraFieldOfView()
	return tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW))
end
function SetCameraFieldOfView(value, doF)
	--	Escapes
	if not(doF) then return end
	if value == nil then return end
	if value == currentFOV then return end
	--	Set and save
	SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW, value)
	SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, value)
	currentFOV = value
end

--	Get/Set Camera Horizontal Position
local currentHPosition
function GetCameraHPosition()
	return tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))
end
function SetCameraHPosition(value)
	--	Escapes
	if value == nil then return end
	if value == currentHPosition then return end
	--	Set and save
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER, value / 100)	
	currentHPosition = value
end

--	Get/Set Camera Horizontal Offset
local currentHOffset
function GetCameraHOffset()
	return tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET)) * 100
end
function SetCameraHOffset(value)
	--	Set additional H offset first
	if NTakCamera.settings.staticCamera > 0 then
		--	Enhanced range management for static cameras
		if value > 100	then SetCameraHPosition(value - 100) end
		if value < -100	then SetCameraHPosition(value + 100) end
	else
		SetCameraHPosition(NTakCamera.settings.defaultHorizontalPosition)
	end
	
	--	Escapes
	if value == nil then return end
	if value == currentHOffset then return end

	--	Set
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, value / 100)
  
	--	Save current value
	currentHOffset = value
end

--	Get/Set Camera Vertical Offset
local currentVOffset
function GetCameraVOffset()
	return tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET)) * 100
end
function SetCameraVOffset(value)
	--	Escapes
	if value == nil then return end
	if value == currentVOffset then return end

	--	Set and save
	SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, value / 100)
	currentVOffset = value
end


------------------------------------------
--		FUNCTIONS

--	Events detection
local function inEvents()
	if NTakCamera.settings.moveAction		~= presetNone	and flagInMove		then return true end
	if NTakCamera.settings.rideAction 		~= presetNone	and flagInRide		then return true end
	if NTakCamera.settings.stealthAction	~= presetNone	and flagInStealth	then return true end
	if NTakCamera.settings.wieldAction		~= presetNone	and flagIsWield		then return true end
	if NTakCamera.settings.combatAction		~= presetNone	and flagInCombat	then return true end	
	return false
end

--	Game camera save/load management 
local savedChatDistance
local savedChatHOffset
local savedChatVOffset
local savedChatFieldOfView
local flagInteraction = false
--	Handle camera change event
function OnGameCameraDeactivated()
	debug("Interaction type #" .. GetInteractionType())

	--	Do something only if blocked
	flagInteraction = blockInteractions[GetInteractionType()] or (NTakCamera.settings.staticCamera > 0)
	if flagInteraction then		
		--	Early
		SetInteractionUsingInteractCamera(false)
	else
		--	Save values before interaction
		-- SaveCameraSettings()
		-- savedChatDistance		= GetCameraDistance()
		-- savedChatHOffset		= GetCameraHOffset()
		-- savedChatVOffset		= GetCameraVOffset()
		-- savedChatFieldOfView	= GetCameraFieldOfView()
		
		debug("Interaction camera allowed")
	end
	return
end
function OnGameCameraActivated()
	--	Restore camera before interaction
	if flagInteraction then
		--	Debug
		debug("Interaction camera prevented")
	else
		debug("Interaction camera exited")
		--	Apply settings
		-- SetCameraDistance(savedChatDistance, true)
		-- SetCameraFieldOfView(savedChatFieldOfView, true)
		-- SetCameraPosition(savedChatHOffset, savedChatVOffset, false, true, true)	
	end
end

--	Camera save/load management 
local savedDistance
local savedHOffset
local savedVOffset
local savedFieldOfView
--	Camera save/load management
function SaveCameraSettings(force)
	--	Escape if interactions or events already running
	if not(force) and inEvents() then return end
	
	--	Save values
	savedDistance		= GetCameraDistance()		-- currentDistance
	savedHOffset		= GetCameraHOffset()		-- currentHOffset
	savedVOffset		= GetCameraVOffset()		-- currentVOffset
	savedFieldOfView	= GetCameraFieldOfView()	-- currentFOV
end
function LoadCameraSettings(force)
	--	Escape if interactions or events still running
	if not(force) and inEvents() then return end

	--	Get saved values
	local z = savedDistance
	local f = savedFieldOfView
	local h = savedHOffset
	local v = savedVOffset

	--	Get default settings if option
	if NTakCamera.settings.defaultAfterEvents or z == nil then
		z = NTakCamera.settings.defaultDistance
		f = NTakCamera.settings.defaultFieldOfView
		h = NTakCamera.settings.defaultHorizontalOffset
		v = NTakCamera.settings.defaultVerticalOffsetMin
		if h == 0 then
			v = NTakCamera.settings.defaultVerticalOffsetMax
		end		
		debug("Loading preferred cam.")
	else
		debug("Loading previous cam.")
	end
	
	--	Keep minimal distance while in werewolf
	if NTakCamera.settings.wolfKeepDistance and flagInWolf then
		z = math.max(z, NTakCamera.settings.wolfDistance)
	end	
	
	--	Apply settings
	SetCameraDistance(z, true)
	SetCameraFieldOfView(f, true)
	SetCameraPosition(h, v, false, true, true)
end

--	Vertical offset management
local targetVMove
local stepVMove = 0
local function LoopCameraVMove()
	--	Calculate position to apply
	local t = GetFrameDeltaTimeMilliseconds() / 10
	local v = currentVOffset + (stepVMove * t)
	
	--	If beyond or equal to target position
	if	((stepVMove >= 0) and (v >= targetVMove)) or
		((stepVMove <= 0) and (v <= targetVMove))
	then
		--	Correct value and unregister loop
		-- v = targetVMove
		-- EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME)
		SetCameraVOffset(targetVMove)
		return
	end
	
	--	Apply position
	SetCameraVOffset(v)

	--	Call next iteration
	zo_callLater(function()
		LoopCameraVMove()
	end, 1)
end
local function InitCameraVMove(v, h)
	--	Escape
	if v == nil then return end

	--	Calculate V Offset to apply, escape if no difference
	-- currentVOffset = GetCameraVOffset() -- Necessary?!… currentVOffset should already be good 
	local vDiff = math.abs(v - currentVOffset)
	if vDiff == 0 then return end

	--	Calculate H Offset to linearize V step
	local hDiff = math.abs(h - currentHOffset)
	if hDiff < 32 then hDiff = 32 end

	--	Set start values and start loop!
	targetVMove = v
	stepVMove = vDiff / hDiff
	if v < currentVOffset then stepVMove = -1 * stepVMove end
	-- if stepVMove == 0 then return end -- Never happens, already covered by vDiff == 0
	-- EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, 10, LoopCameraVMove)
	LoopCameraVMove()
end

--	Camera Position management
function SetCameraPosition(h, v, fast, doH, doV)
	--	H offset treatment
	if h == nil then h = currentHOffset end
	-- if not(inEvents()) then
		-- h = NTakCamera.settings.defaultHorizontalOffset
	-- end
	h = math.abs(h) * shoulderCoef

	--	V offset treatment
	if v == nil then -- Should be nil only when toggling center
		v = currentVOffset
		
		--	If nothing is running
		if not(inEvents()) then
			v = NTakCamera.settings.defaultVerticalOffsetMin
			if math.abs(h) < 0.5 then
				v = NTakCamera.settings.defaultVerticalOffsetMax
			end
		end
	end

	--	Apply offsets
	if fast == true then
		--	Directly set offsets
		if doV then SetCameraVOffset(v) end
		if doH then SetCameraHOffset(h) end
		--	The below trick updates the camera without transition
		ToggleGameCameraFirstPerson()
		ToggleGameCameraFirstPerson()
	else
		--	Start animations
		if doV then InitCameraVMove(v, h) end
		if doH then SetCameraHOffset(h) end -- Horizontal movement already uses a transition by default
	end
	
	-- debug("dhv =  " .. currentDistance .. ",  " .. h .. ",  " .. v )
end


------------------------------------------
--		BINDINGS & ASSOCIATED FUNCTIONS

--	Center/Swap
function KeyUp_ToggleCenter(fast)
	--	Prevent nil
	if fast == nil then fast = false end

	if math.abs(currentHOffset) < 0.5 then
		--	Back to shoulder
		shoulderCoef = numbersign(shoulderCoef)
		SetCameraPosition(currentHOffset * 1024, nil, fast, true, true)
	else
		--	Center
		shoulderCoef = numbersign(shoulderCoef) / 1024
		SetCameraPosition(currentHOffset, nil, fast, true, true)
	end
end
function KeyUp_SwapShoulder(fast, step)
	--	Prevent nil
	if fast == nil then fast = false end
	if step == nil then step = false end
	
	if math.abs(currentHOffset) < 0.5 then
	--	In center, switch side
		shoulderCoef = -1 * numbersign(shoulderCoef)
		KeyUp_ToggleCenter(fast)
	else
	-- Not in center
		if step then
			--	Toggle center
			KeyUp_ToggleCenter(fast)
		else
			--	Simply change side
			shoulderCoef = -1 * numbersign(shoulderCoef)
			SetCameraPosition(nil, nil, fast, true, false)
		end
	end
end
function KeyUp_SwapCenter(fast)
	if fast == nil then fast = false end
	KeyUp_SwapShoulder(fast, true)
end

--	Distance toggle
function KeyUp_ToggleAltDistance()
	--	Value
	local value = NTakCamera.settings.defaultDistance
	if value == currentDistance then
		value = NTakCamera.settings.altDistance
	end
	
	--	Save and apply
	SetCameraDistance(value, true)
	debug("Toggle distance to " .. value)
end

--	FOV toggle
local altFOVflag = 5
function KeyUp_ToggleAltFOV()	
	--	Value
	local value = NTakCamera.settings.defaultFieldOfView
	if value == currentFOV then
		value = NTakCamera.settings.altFieldOfView
	end
	
	--	Save and apply
	SetCameraFieldOfView(value, true)
	debug("Toggle field of view to " .. value)
end

--	H Position toggle
function KeyUp_ToggleAltHPosition()
	-- altHorizontalOffset
end

--	H offset toggle
function KeyUp_ToggleAltHOffset()
	-- altHorizontalPosition
end

--	ALL toggle
function KeyUp_ToggleAltAll()
	KeyUp_ToggleAltDistance()
	KeyUp_ToggleAltFOV()
	KeyUp_ToggleAltHPosition()
	KeyUp_ToggleAltHOffset()
end

--	Siege toggle
function KeyUp_ToggleSiege()
	--	Get current value and complement it
    local value = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_SIEGE_WEAPONRY))
    value = math.abs(value - 1)
	--	Set value
    SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_SIEGE_WEAPONRY, value, 1)
end

--	Interactions toggles
function KeyUp_ToggleChat()
	NTakCamera.settings.chatPreventCam = not(NTakCamera.settings.chatPreventCam)
	InitBlockingInteractions()
end
function KeyUp_ToggleCraft()
	NTakCamera.settings.craftPreventCam = not(NTakCamera.settings.craftPreventCam)
	InitBlockingInteractions()
end
function KeyUp_ToggleLockpicking()
	NTakCamera.settings.lockpickPreventCam = not(NTakCamera.settings.lockpickPreventCam)
	InitBlockingInteractions()
end

--	Static cameras
function KeyUp_StaticCamera(num)
	if num == nil then num = 0 end
	if NTakCamera.settings.staticCamera == num then num = 0 end
  	NTakCamera.settings.staticCamera = num
  	InitCameraValues()
	
	--	Chat output
	debug(NTCam_Texts.cat2.msg0 .. num, NTakCamera.settings.staticOutputInChat)
end

--	Debug
local function debugToggle()
	NTakCamera.settings.debug = not(NTakCamera.settings.debug)
end
SLASH_COMMANDS["/ntcam_debug"] = debugToggle



--	Movement Speed
local X1 = 0
local Y1 = 0
--local V1 = 0
local Varray = {0,0,0,0,0,0,0,0}
local Vindex = 0
local Vavg = 0
local Vavg1 = 0
local Vmax = 0
local inMove = false
--	Handle move state change
function OnPlayerMove()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end
	if NTakCamera.settings.moveAction == presetNone then return end
		
	--	Continue
	if flagInMove ~= inMove then		
		if inMove then
			--	Save
			SaveCameraSettings()
			flagInMove = true
			debug("Move ON")
		else
			if NTakCamera.settings.moveDebugSpeed then
				debug("Maximum speed: " .. Vmax, true)
				Vmax = 0
			end
			OffPlayerMove()
		end
	end
	
	--	
	if flagInMove then
		--	Speed		
		if NTakCamera.settings.moveDebugSpeed then
			if Vavg1 ~= Vavg then
				debug("Speedometer: " .. Vavg, true)
				Vavg1 = Vavg
			end
			if Vavg > Vmax then Vmax = Vavg end
		end
		
		--	Do update values ?		
		local doD, doF, doH, doV
		doD = NTakCamera.settings.moveDoDistance
		doF = NTakCamera.settings.moveDoFieldOfView
		doH = NTakCamera.settings.moveDoHorizontalPos
		doV = NTakCamera.settings.moveDoVerticalOffset

		--	Values when moving normally
		local d, f, h, v
		local Vcap = math.min(Vavg, 1)
		d = smooth(NTakCamera.settings.moveDistance, savedDistance, Vcap)
		f = smooth(NTakCamera.settings.moveFieldOfView, savedFieldOfView, Vcap)
		h = smooth(NTakCamera.settings.moveHorizontalPos, savedHOffset, Vcap)
		v = smooth(NTakCamera.settings.moveVerticalOffset, savedVOffset, Vcap)
		
		--	Overrides if running "fast"
		if Vavg > NTakCamera.settings.moveFastThreshold then
			if doD and NTakCamera.settings.moveFastDoDistance then d = NTakCamera.settings.moveFastDistance end
			if doF and NTakCamera.settings.moveFastDoFieldOfView then f = NTakCamera.settings.moveFastFieldOfView end			
			if doH and NTakCamera.settings.moveFastDoHorizontalPos then h = NTakCamera.settings.moveFastHorizontalPos end			
			if doV and NTakCamera.settings.moveFastDoVerticalOffset then v = NTakCamera.settings.moveFastVerticalOffset end
		end
		
		--	Update values
		SetCameraDistance(d, doD)
		SetCameraFieldOfView(f, doF)
		SetCameraPosition(h, v, false, doH, doV)
		
	end
end
function OffPlayerMove()
	--	Escape
	if NTakCamera.settings.staticCamera > 0 then return end

	--	Escape if already restored
	if flagInMove == false then return end
	--	Set as done and restore settings
	flagInMove = false
	debug("Move OFF")
	
	--	Reload the preferred camera
	LoadCameraSettings()
end
local function MoveSpeedCalculation()
	--	Update position, deltas, and save for next iteration
	local _, X, _, Y = GetUnitRawWorldPosition('player')
	local dX = X - X1
	local dY = Y - Y1
	X1 = X
	Y1 = Y
	
	--	Calculate velocity
	local V
	if inEvents() and not(flagInMove) then
		V = 0									--	Override calculation
	else
		V = math.sqrt(dX * dX + dY * dY) / 67	--	This tends to 1 when running fast		
		if V > 5 then V = 0 end					--	Prevent doing bad stuff when loading
	end
		
	--	Average
	Vindex = Vindex + 1
	if Vindex >= 8 then Vindex = 0 end
	Varray[Vindex] = V
	Vavg = math.round(math.average(Varray), 2)
	
	--	Apply
	inMove = (Vavg > 0.01)
	OnPlayerMove()
end



------------------------------------------
--		ADDON LOAD

local function OnAddOnLoaded(eventCode, addonName)
	--	Escape if incorrect
	if addonName ~= ADDON_NAME then return end

	--	Unregister on load
	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

	--	Default settings
	local defaults = {
		--	Account wide ?
		accountWide					= true,
		--	PREFERRED
		defaultDistance				= 4,
		defaultFieldOfView			= 50,
		defaultHorizontalSide		= shoulderSideRight,
		defaultHorizontalOffset		= 66,
		defaultHorizontalPosition	= 0,
		defaultVerticalOffsetMin	= 0,
		defaultVerticalOffsetMax	= 0,
		defaultAfterEvents			= false,		
		--	ALTERNAVE VALUES
		altDistance					= 10,
		altFieldOfView				= 65,
		altHorizontalOffset			= 100,
		altHorizontalPosition		= 100,
		--	OVERRIDE PROFILES
    	staticCamera				= 0,
    	staticCamera1	= {
			distance				= 4,
			fieldOfView				= 50,
			horizontalPosition		= 66,
			verticalPosition		= 0,
		},
    	staticCamera2	= {
			distance				= 4,
			fieldOfView				= 50,
			horizontalPosition		= 66,
			verticalPosition		= 0,
		},
    	staticCamera3	= {
			distance				= 4,
			fieldOfView				= 50,
			horizontalPosition		= 66,
			verticalPosition		= 0,
		},
		staticOutputInChat			= true,
		--	INTERACTIONS
		--	Chat
		chatPreventCam				= true,
		chatAction					= presetNone,
		chatDoDistance				= false,
		chatDoFieldOfView			= false,
		chatDoHorizontalPos			= false,
		chatDoVerticalOffset		= false,
		chatDistance				= 5,
		chatFieldOfView				= 50,
		chatHorizontalPos			= 0,
		chatVerticalOffset			= 0,
		--	Craft station
		craftPreventCam				= false,
		craftAction					= presetNone,
		craftDoDistance				= false,
		craftDoFieldOfView			= false,
		craftDoHorizontalPos		= false,
		craftDoVerticalOffset		= false,
		craftDistance				= 5,
		craftFieldOfView			= 50,
		craftHorizontalPos			= 0,
		craftVerticalOffset			= 0,
		--	Style station
		stylePreventCam				= false,
		styleAction					= presetNone,
		styleDoDistance				= false,
		styleDoFieldOfView			= false,
		styleDoHorizontalPos		= false,
		styleDoVerticalOffset		= false,
		styleDistance				= 5,
		styleFieldOfView			= 50,
		styleHorizontalPos			= 0,
		styleVerticalOffset			= 0,
		--	Lockpicking
		lockpickPreventCam			= true,
		lockpickAction				= presetNone,
		lockpickDoDistance			= false,
		lockpickDoFieldOfView		= false,
		lockpickDoHorizontalPos		= false,
		lockpickDoVerticalOffset	= false,
		lockpickDistance			= 5,
		lockpickFieldOfView			= 50,
		lockpickHorizontalPos		= 0,
		lockpickVerticalOffset		= 0,
		--	Furniture
		furniturePreventCam			= true,
		furnitureAction				= presetNone,
		furnitureDoDistance			= false,
		furnitureDoFieldOfView		= false,
		furnitureDoHorizontalPos	= false,
		furnitureDoVerticalOffset	= false,
		furnitureDistance			= 5,
		furnitureFieldOfView		= 50,
		furnitureHorizontalPos		= 0,
		furnitureVerticalOffset		= 0,
		--	EVENTS
		--	Move
		moveAction					= presetNone,
		moveDoDistance				= true,
		moveDoFieldOfView			= false,
		moveDoHorizontalPos			= false,
		moveDoVerticalOffset		= false,
		moveDistance				= 12,
		moveFieldOfView				= 50,
		moveHorizontalPos			= 0,
		moveVerticalOffset			= 0,
		moveDebugSpeed				= false,
		--	Move fast !
		moveFastThreshold			= 0.9,
		moveFastDoDistance			= true,
		moveFastDoFieldOfView		= true,
		moveFastDoHorizontalPos		= false,
		moveFastDoVerticalOffset	= false,
		moveFastDistance			= 20,
		moveFastFieldOfView			= 65,
		moveFastHorizontalPos		= 0,
		moveFastVerticalOffset		= 0,
		--	Ride
		rideAction					= presetCenter3rd,
		rideDoDistance				= false,
		rideDoFieldOfView			= false,
		rideDoHorizontalPos			= true,
		rideDoVerticalOffset		= false,
		rideDistance				= 15,
		rideFieldOfView				= 50,
		rideHorizontalPos			= 0,
		rideVerticalOffset			= 0,
		ridePreventChange			= true,
		--	Stealth
		stealthAction				= presetNone,
		stealthDoDistance			= false,
		stealthDoFieldOfView		= false,
		stealthDoHorizontalPos		= false,
		stealthDoVerticalOffset		= false,
		stealthDistance				= 5,
		stealthFieldOfView			= 50,
		stealthHorizontalPos		= 0,
		stealthVerticalOffset		= 0,
		stealthOffDelay				= 0,
		--	Wield
		wieldOnCombat				= false,
		wieldAction					= presetNone,
		wieldDoDistance				= false,
		wieldDoFieldOfView			= false,
		wieldDoHorizontalPos		= false,
		wieldDoVerticalOffset		= false,
		wieldDistance				= 5,
		wieldFieldOfView			= 50,
		wieldHorizontalPos			= 0,
		wieldVerticalOffset			= 0,
		--	Combat
		combatAction				= presetNone,
		combatDoDistance			= false,
		combatDoFieldOfView			= false,
		combatDoHorizontalPos		= false,
		combatDoVerticalOffset		= false,
		combatDistance				= 5,
		combatFieldOfView			= 50,
		combatHorizontalPos			= 0,
		combatVerticalOffset		= 0,
		combatOffDelay				= 20,
		combatAutoSheath			= false,
		--	Werewolf
		wolfAction					= presetNone,
		wolfDoDistance				= false,
		wolfDoFieldOfView			= false,
		wolfDoHorizontalPos			= false,
		wolfDoVerticalOffset		= false,
		wolfKeepDistance			= true,
		wolfDistance				= 5,
		wolfFieldOfView				= 50,
		wolfHorizontalPos			= 0,
		wolfVerticalOffset			= 0,
		--	DEBUG
		debug						= false,
		beta						= false,
	}
	
	-- Get character settings
	NTakCamera.settings = ZO_SavedVars:NewCharacterIdSettings("NTakCamera_SavedVariables", 1, "Settings", defaults)
	-- Get (or create) account wide if selected
	if NTakCamera.settings.accountWide then
		if NTakCamera_SavedVariables.Default[GetDisplayName()]["$AccountWide"] == nil then
			local currents = copyTree(NTakCamera_SavedVariables.Default[GetDisplayName()][GetCurrentCharacterId()]["Settings"])
			NTakCamera.settings = ZO_SavedVars:NewAccountWide("NTakCamera_SavedVariables", 1, "Settings", currents)
			zo_callLater(function()
				d("NTakCamera: Account-wide settings have been created from current character settings.")
			end, 5000)
		else
			NTakCamera.settings = ZO_SavedVars:NewAccountWide("NTakCamera_SavedVariables", 1, "Settings", defaults)
		end
	end
	
	--	Initialize all
	NTCam.InitSettings()
	InitCameraValues(1)
	InitBlockingInteractions()
	
	--	Register to various events
	--	Interactions
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN,						OnChatter)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_END,						OffChatter)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_STORE,						OffChatter)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_BANK,						OffChatter)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_CLOSE_BUY_SPACE,			OffChatter)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_GUILD_BANK,					OffChatter)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CLOSE_TRADING_HOUSE,				OffChatter)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CRAFTING_STATION_INTERACT,			OnCrafting)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_END_CRAFTING_STATION_INTERACT,		OffCrafting)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_DYEING_STATION_INTERACT_START,		OnStyling)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_DYEING_STATION_INTERACT_END,		OffStyling)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_BEGIN_LOCKPICK,					OnLockpick)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LOCKPICK_SUCCESS,					OffLockpick)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_LOCKPICK_FAILED,					OffLockpick)
	--	Other events
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAME_CAMERA_ACTIVATED,				OnGameCameraActivated)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GAME_CAMERA_DEACTIVATED,			OnGameCameraDeactivated)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_MOUNTED_STATE_CHANGED,				OnMountedStateChanged)	
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_STEALTH_STATE_CHANGED,				OnStealthStateChanged)
	EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_STEALTH_STATE_CHANGED,			REGISTER_FILTER_UNIT_TAG,	"player")
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE,				OnPlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_WEREWOLF_STATE_CHANGED,			OnWerewolfStateChanged)
	--	
	EVENT_MANAGER:RegisterForUpdate("NTCamMoveSpeedRefresh", 67, MoveSpeedCalculation)
	ZO_PreHook("TogglePlayerWield", function()
		CheckTogglePlayerWield()	--	Launch the Toggle-checking
		return false				--	Run original function without delay!
	end)
end
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
