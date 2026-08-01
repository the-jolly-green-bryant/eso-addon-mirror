--[[
Copyright (c) 2017-2019 Dolores Scott
All rights reserved.
See LICENSE file for terms.
]]

local SF = LibSFUtils
local color = SF.hex

local FR = FastRide

-- send debug messages to chat if enabled
-- enhanced to be able to use LibDebugLogger if loaded
local debugmode=false

local function toChat(...)
	CHAT_ROUTER:AddSystemMessage(SF.str(...)) 
end


-- skill index in skill line (last of triple)
local RAPIDS_INDEX = 3

-- rapidsMode states
local Mode_False=0
local Mode_True=1
local Mode_2False = 2
local Mode_2True=3

local rapidsMode = Mode_False

local modeStates = {
    dark = {
        dbgstr = "go to dark",
        texture = "FastRide/dkhorse.dds",
    },
    gold = {
        dbgstr = "go to gold",
        texture = "FastRide/goldhorse.dds",
    },
    purple = {
		dbgstr = "go to purple",
		texture = "FastRide/purplehorse.dds",
    },
}

local combatT = {
    [Mode_False] = {
        wantFalse = { mode=modeStates.dark, nextState = Mode_False, },
        wantTrue = { mode=modeStates.dark, nextState = Mode_2True, },
        wantSame = { mode=modeStates.dark, nextState = Mode_False, },
        },
    [Mode_True] = {
        wantFalse = { mode=modeStates.purple, nextState = Mode_2False, },
        wantTrue = { mode=modeStates.gold, nextState = Mode_True, },
        wantSame = { mode=modeStates.gold, nextState = Mode_True, },
        },
    [Mode_2False] = {
        wantFalse = { mode=modeStates.dark, nextState = Mode_2False, },
        wantTrue = { mode=modeStates.gold, nextState = Mode_True, },
        wantSame = { mode=modeStates.dark, nextState = Mode_2False, },
        },
    [Mode_2True] = {
        wantFalse = { mode=modeStates.dark, nextState = Mode_False, },
        wantTrue = { mode=modeStates.gold, nextState = Mode_2True, },
        wantSame = { mode=modeStates.gold, nextState = Mode_2True, },
        },
}

local normalT = {
    [Mode_False] = {
        wantFalse = { mode=modeStates.dark, nextState = Mode_False, },
        wantTrue = { mode=modeStates.gold, nextState = Mode_True, },
        wantSame = { mode=modeStates.dark, nextState = Mode_False, },
        },
    [Mode_True] = {
        wantFalse = { mode=modeStates.dark, nextState = Mode_False, },
        wantTrue = { mode=modeStates.gold, nextState = Mode_True, },
        wantSame = { mode=modeStates.gold, nextState = Mode_True, },
        },
    [Mode_2False] = {
        wantFalse = { mode=modeStates.dark, nextState = Mode_False, },
        wantTrue = { mode=modeStates.gold, nextState = Mode_True, },
        wantSame = { mode=modeStates.dark, nextState = Mode_2False, },
        },
    [Mode_2True] = {
        wantFalse = { mode=modeStates.dark, nextState = Mode_False, },
        wantTrue = { mode=modeStates.gold, nextState = Mode_True, },
        wantSame = { mode=modeStates.gold, nextState = Mode_2True, },
        },
}

local swap_queued = false

local baseSkill = {
    [1] = 0,
    [2] = 0,
}
--FR.baseSkill = baseSkill

FR.RapidsSkillsArray = {}
FR.skillChoices = {}

-- saved variable tables
local toon = {}
local saved = {}
-------------------------------

local currentHotBar = 1

-------------------------------
-- default is to not expect LibDebugLogger so just
-- log to chat
local logger = {
}
function logger.Debug(self,...)
    if debugmode then
        FRmsg:debugMsg(...)
    end
end
function logger.Info(self,...)
    if debugmode then
        FRmsg:debugMsg(...)
    end
end
function logger.Warn(self,...)
    if debugmode then
        FRmsg:debugMsg(...)
    end
end
function logger.Error(self,...)
    FRmsg:systemMessage(...)
end

-- create a logger for FastRide if possible
if LibDebugLogger then
    logger = LibDebugLogger(FR.name)
end

-- logging mechanism without LibDebugLogger
local FRmsg = SF.addonChatter:New(FR.name)
FRmsg:disableDebug()

-- older functions
local function dbg(...)	-- mostly because I hate to type
	logger:Debug(...)
end

local function dbar()
	logger:Debug(SF.str("mode: ", rapidsMode,  "  in combat: ", SF.bool2str(IsUnitInCombat('player')),
			"   belt: ",currentHotBar,
			"  isRapids: ",SF.bool2str(FR.toon.savedSkillId[currentHotBar] ~= nil)))
end

-------------------------------
-- saved variable defaults for both aw and toon
FR.Defaults = {
	switchSlot = 1,
	autoswitchEnabled = true,
    noSwitchActive = false,
	revertSwitch = true,
	fadeswitch = true,
	fadesecs = 2,
	soundEnabled = false,
	sound = SOUNDS.HELP_WINDOW_OPEN,
    offsetx = 0,
    offsety = 0,
	iconEnabled = true,
    unsheatheEnabled = true,
    notify = true,
    skillsloc = 1,
	baseSkill = {
		[1] = 0,
		[2] = 0,
	},
}
-------------------------------

local rapidsRefId = 0
local isSkillsLoaded = false
local rapidsDuration = 30000

function FR.setRapidsId(id)
    rapidsRefId = id
end

AbilityInfo = {}

-- a pseudo-object that cannot use the metatable because instances of it are stored in
-- saved variables. (Storing metatabled objects in saved vars results in CTDs on loading.)
--
-- For a type,index,ability triple, acquire:
-- * ability index,
-- * name,
-- * passive status, and
-- * if the skill is currently unlocked.
function AbilityInfo.New(skillType, skillIndex, abilityIndex, abilityName, abilityId)
	local o = {}

	o.skillType = skillType
	o.skillIndex = skillIndex
	o.abilityIndex = abilityIndex
	if( abilityId == nil) then
		o.abilityId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, false)
	else
		o.abilityId = abilityId
	end
	if( abilityName == nil ) then
		o.abilityName = GetAbilityName(o.abilityId)
	else
		o.abilityName = abilityName
	end
    o.isPassive = IsAbilityPassive(o.abilityId)
    o.unlocked = GetAbilityProgressionXPInfoFromAbilityId(o.abilityId)
	--logger:Debug(SF.str(o.abilityName,' (',o.skillType,',',o.skillIndex,',',
	--	o.abilityIndex,') abilityId:',(o.abilityId or 'not saved'), ' passive: ',
	--	SF.bool2str(o.isPassive), ' unlocked: ',SF.bool2str(o.unlocked)))	

	return o
end

-- debug printout of an ability info table
function AbilityInfo:dbgPrint(funcname)
	funcname = SF.nilDefault(funcname,"debug")
	--logger:Debug(SF.str(funcname,':  ',self.abilityName,' (',self.skillType,',',self.skillIndex,',',
	--	self.abilityIndex,') abilityId:',(self.abilityId or 'not saved'), ' passive: ',
    --    SF.bool2str(self.isPassive), ' unlocked: ',SF.bool2str(self.unlocked)))
end

local function setNewMode( mode, nextState )
    logger:Debug("setNewMode:  "..mode.dbgstr.."  ".. mode.texture .. "  next="..nextState)
	local p = FastRideWindowIndicator
    p:SetTexture(mode.texture)
    rapidsMode = nextState
end

-- Change rapidsmode setting based on val (nil, true, or false)
-- while in combat
function FR.setCombatRapidsMode(val)
    local stateinfo
	if rapidsMode == nil then rapidsMode = Mode_False end
	
	if( val == true ) then
        stateinfo = combatT[rapidsMode].wantTrue
        setNewMode(stateinfo.mode,stateinfo.nextState)
        return rapidsMode
	end
	if( val == false ) then
        stateinfo = combatT[rapidsMode].wantFalse
        setNewMode(stateinfo.mode,stateinfo.nextState)
        return rapidsMode
	end
	
	--stateinfo = combatT[rapidsMode].wantFalse
	--setNewMode(stateinfo.mode,stateinfo.nextState)
	dbar()
	return rapidsMode
end

-- change rapidsmode based on val (nil, true, or false)
-- when not in combat
function FR.setNormalRapidsMode(val)
    local stateinfo
	if( val == nil ) then
		-- nil was passed because we got out of combat
        -- finish transition
		if( rapidsMode == Mode_2False ) then
            stateinfo = normalT[rapidsMode].wantFalse
            setNewMode(stateinfo.mode,stateinfo.nextState)
            return rapidsMode
		elseif( rapidsMode == Mode_2True ) then
            stateinfo = normalT[rapidsMode].wantTrue
            setNewMode(stateinfo.mode,stateinfo.nextState)
            return rapidsMode
		end
		--stateinfo = normalT[rapidsMode].wantSame
		--setNewMode(stateinfo.mode,stateinfo.nextState)
		dbar()
		return rapidsMode
	end

	if( val == true ) then
        stateinfo = normalT[rapidsMode].wantTrue
        setNewMode(stateinfo.mode, stateinfo.nextState)
        return rapidsMode
	end

	-- val == false
    stateinfo = normalT[rapidsMode].wantFalse
    setNewMode(stateinfo.mode,stateinfo.nextState)
    return rapidsMode
end

-- set rapidsmode to appropriate state when we want true or false
-- allow for differences between combat and non-
function FR.setRapidsMode(val)

	dbar()
	if( IsUnitInCombat('player') ) then
		return FR.setCombatRapidsMode(val)
	end
	return FR.setNormalRapidsMode(val)
end

-------------------------------
-- Check if the rapids effect is currently active
--  returns true or false
--
-- We compare icon filenames because those do not change with localization
function FR.checkRapidsActive()
    -- look for rapids buff by iconFilename as it is not likely to change
    -- with localization.
    local unitTag='player'
    for i = 1, GetNumBuffs(unitTag) do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, 
				buffType, effectType, abilityType, 	statusEffectType, abilityId, 
				canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)
        --dbg("active: "..buffName..", id "..abilityId.." iconFilename "..iconFilename)
        if( iconFilename == '/esoui/art/icons/ability_buff_major_gallop.dds' ) then
            return true
        end
    end
    return false
end

-------------------------------

-- Put an ability described by abilityid and assign it
-- to the specified slot number (1-5)
-- Note:
-- slotNum = beltSlot - ACTION_BAR_FIRST_NORMAL_SLOT_INDEX
--
--    SlotSkillAbilityInSlot() requires the beltSlot, not the slotNum.
--
-- Returns:
--		true, old_abilityId (might be nil)	- ability was slotted
--		false, old_abilityId (if available, might be nil)	- ability was not slotted
--
function FR.slotAbilityById(slotnum, abilityid)
	if not slotnum or slotnum < 1 or slotnum > 5 then return false end
    if not abilityid then return false end

	local beltslot = slotnum + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX
	local old_abilityId = GetSlotBoundId(beltSlot)
	
    local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(abilityid)
    if progression then
        local skillType, skillIndex, abilityIndex = progression:GetIndices()
        SlotSkillAbilityInSlot(skillType, skillIndex,
                abilityIndex, beltslot)
        return true, old_abilityId
    end
    --logger:Debug("Unable to slot ability "..(abilityid or "nil").." into slot "..slotnum)
    --logger:Debug("Old slot ability "..(old_abilityId or "nil").." is in slot "..slotnum)
	return false, old_abilityId
end

-- check if bar should be reverted after a call to rapids
--
function FR.onSlotAbilityUsed(eventCode, beltSlot)
	if rapidsMode == Mode_False then return end     -- we're not in rapids mode
    -- if not the rapids mode slot then return
	if( beltSlot ~= saved.switchSlot + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX ) then return end

	-- check revert after use setting
    if saved.revertSwitch == true then
		FR.setRapidsMode(false)
		FR.SwapSkill()

		-- set up to swap back when fading if enabled
		FR.recoverFading()
	else
		FR.SwapSkill()
	end

	dbar()
end

function FR.onSlotAbilityChanged(eventCode, beltSlot)
	if( beltSlot ~= saved.switchSlot + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX ) then return end

	if saved.soundEnabled and rapidsMode == Mode_True then
        SF.PlaySound(saved.sound)
	end
	if rapidsMode == Mode_False then
		FR.SaveSlot(beltSlot)
		FR.SaveOriginal(beltSlot)
	end
end

-- When the bar is changed, set/unset rapids skill according to current rapidsMode
-- Can revert bar to original when swapped
function FR.onActiveWeaponPairChanged(eventCode, newWeaponPair, locked)
	currentHotBar = newWeaponPair
	--logger:Debug("onActiveWeaponPairChanged("..eventCode..", "..newWeaponPair..", ",SF:bool2str(locked))

    -- is primary or backup
	FR.SwapSkill()
end

function FR.SaveSlot(beltSlot)
	if not beltSlot or beltSlot < 3 or beltSlot > 8 then
		return
	end
    if( rapidsRefId==abilityId ) then
		return false
	end
	local abilityId = GetSlotBoundId(beltSlot,HOTBAR_CATEGORY_PRIMARY)
    if( rapidsRefId~=abilityId ) then
		baseSkill[1] =  abilityId
	end
	abilityId = GetSlotBoundId(beltSlot,HOTBAR_CATEGORY_BACKUP)
    if( rapidsRefId~=abilityId ) then
		baseSkill[2] =  abilityId
	end
	
	return true
end

-- Save the replaced skill from the weapon bar
-- returns false if it was unable to save
function FR.SaveOriginal(beltSlot)
	if( FR.hasRapids() == false ) then return false end

    local abilityId = GetSlotBoundId(beltSlot)
    logger:Debug("SaveOriginal: slot %d ability to save %d (rapids %d)", beltSlot,abilityId,rapidsRefId)
    if( rapidsRefId==abilityId ) then
		return false
	end

	local hotBar = currentHotBar
	toon.savedSkillId[hotBar] = abilityId
	--beltSkill[hotBar] = abilityId
	return true
end

function FR.showOriginal()
	toChat("bar 1: "..(baseSkill[1] or "nil"))
	toChat("bar 2: "..(baseSkill[2] or "nil"))
end

function FR.recoverFading()
    local function 	unfade()		-- handle fading
		if( IsMounted() ) then
            FR.setRapidsMode(IsMounted())
		end
        FR.SwapSkill()
	end

	if( FR.hasRapids() == false ) then return end
	if saved.fadeswitch == true then
		local waitTime = rapidsDuration - saved.fadesecs*1000
		--logger:Debug("rapidsDuration="..rapidsDuration.."  remaining wait time="..waitTime)
		if waitTime > 0 then
			zo_callLater(function() unfade() end, waitTime)
			return
		end
	end

end

-- Swap the skill in the rapids slot either to or from the rapids skill
-- based on the current setting of rapidsMode.
-- If rapidsMode is one of the trues, then we want to add rapids to the bar.
-- If rapidsMode is one of the falses, then we want to remove rapids
-- from the bar, and put the original skill back.
--
-- This can only ever change the active weapon bar, we must wait on a bar swap to
-- change the skills on a different weapon bar.
--
-- force is only true when called by slash command or key bind
--
-- This is a local 'queue-able' version of SwapSkill to try to prevent
-- double execution.
local function queuedSwapSkill(force)
	local hotBar = currentHotBar
	local beltSlot = saved.switchSlot + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX
	local abilityId = GetSlotBoundId(beltSlot)

	--logger:Debug("switchSlot = "..saved.switchSlot.."   bar "..currentHotBar)
	--dbar()
	
	-- case to handle keybind actions
	if( force == true ) then
		if( rapidsMode == Mode_True or rapidsMode == Mode_2True ) then
			-- swap back to original skill
            local skb = baseSkill[hotBar]
			if(skb ~= nil) then
				local rslt = FR.slotAbilityById(saved.switchSlot, skb)
				if rslt == true then
					toon.savedSkillId[hotBar] = nil
				end
			end
			FR.setRapidsMode(false)

		else
			-- swap to rapids
			if FR.SaveOriginal(beltSlot) then
                if saved.soundEnabled then SF.PlaySound(saved.sound) end
                local rslt, oldid = FR.slotAbilityById(saved.switchSlot, rapidsRefId)
				if rslt == true then
					toon.savedSkillId[hotBar] = oldid
				end
            else
                local slt = beltSlot-2
                if saved.notify then
                    logger:Warn("Unable to swap skill in slot "..slt.." for Rapids")
                    local abilityId = GetSlotBoundId(beltSlot)
                    local abilityName = GetAbilityName(abilityId)
                    logger:Info("Current skill: "..abilityId.." "..abilityName)
                end
            end
            if saved.unsheatheEnabled == true and IsMounted() ~= true and ArePlayerWeaponsSheathed() == true then
                TogglePlayerWield()
            end
            FR.setRapidsMode(true)
		end
		swap_queued = false
		return
	end

	-- case to reset bar after rapidsMode is exited.
	if toon.savedSkillId[hotBar] then
		if( rapidsMode == Mode_False or rapidsMode == Mode_2False ) then
			-- swap back to original skill
			--logger:Debug('SwapSkill: original '..(baseSkill[hotBar] or "nil").." on bar "..hotBar)
			FR.slotAbilityById(saved.switchSlot, baseSkill[hotBar])
			toon.savedSkillId[hotBar] = nil
            if rapidsMode == Mode_2False and not toon.savedSkillId[1]  and not toon.savedSkillId[2] then
			    FR.setRapidsMode(false)
            end
			swap_queued = false
            return
		end
	end

	-- case to set bar when in rapidsMode
	if( rapidsMode == Mode_True or rapidsMode == Mode_2True ) then
		--  bar has not been set yet, so do it
		if( toon.savedSkillId[hotBar] == nil) then
			-- swap to rapids
			if FR.SaveOriginal(beltSlot) then
                if saved.soundEnabled then SF.PlaySound(saved.sound) end
                local rslt, oldid = FR.slotAbilityById(saved.switchSlot, rapidsRefId)
				if rslt == true then
					toon.savedSkillId[hotBar] = oldid
				end
            else
                local slt = beltSlot-2
                if saved.notify then
                    logger:Warn("Unable to swap skill in slot "..slt.." for Rapids")
                    local abilityId = GetSlotBoundId(beltSlot)
                    local abilityName = GetAbilityName(abilityId)
                    logger:Info("Current skill: "..abilityId.." "..abilityName)
                end
            end
            if saved.unsheatheEnabled == true and IsMounted() ~= true and ArePlayerWeaponsSheathed() == true then
                TogglePlayerWield()
            end
            if rapidsMode == Mode_2True and toon.savedSkillId[1]  and toon.savedSkillId[2] then
                FR.setRapidsMode(true)
            end
			swap_queued = false
			return
		end
	end
	swap_queued = false
end

-- Determine if we can swap skills now or if we must delay
-- If queuedSwapSkill() is already waiting to execute, don't
-- double exec.
function FR.SwapSkill(force)
	if( FR.hasRapids() == false ) then return end
	
	force = SF.nilDefault(force, false)

	-- cannot swap skills if in combat
	if IsUnitInCombat('player') then
		swap_queued = true
		--zo_callLater(function() queuedSwapSkill(force) end, 300)
		return
	end
	if swap_queued == false then
		swap_queued = true
		queuedSwapSkill(force)
	end
end

function FR.SetToBase()
	local hotBar = currentHotBar
	local beltSlot = saved.switchSlot + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX
	FR.slotAbilityById(saved.switchSlot, baseSkill[hotBar])
	FR.setRapidsMode(false)
end

function FR.hasRapids()
    local progression = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(rapidsRefId)
    if not progression then return false end
    return progression:GetSkillData():IsPurchased()
end

-- Note that FR.loadSkillLocsArray() must be called before this
-- so that our tables have values in them.
function FR.loadRapids()
    if(saved.skillsloc == nil) then
        local var = FR.skillChoices[1]
        saved.skillsloc = FR.RapidsSkillsArray[var]
    end
    if ( FR.RapidsSkillsArray[saved.skillsloc] == nil) then
        local var = FR.skillChoices[1]
        saved.skillsloc = FR.RapidsSkillsArray[var]
    end
    -- always load rapids even if not unlocked
    local ai = AbilityInfo.New(SKILL_TYPE_AVA, saved.skillsloc, RAPIDS_INDEX)
    rapidsRefId = ai.abilityId
	-- Major Expedition lasts 8 seconds
    --rapidsDuration = GetAbilityDuration(ai.abilityId)
	--logger:Debug(ai.abilityName .. "  duration="..rapidsDuration)
    rapidsDuration = 28000   -- Major Gallop lasts 30 seconds
end

-- load in the localized name candidates for Rapids for settings
function FR.loadSkillLocsArray()
    FR.RapidsSkillsArray = {}
    FR.skillChoices = {}
    for lineIndex = 1, GetNumSkillLines(SKILL_TYPE_AVA) do
        local ai = AbilityInfo.New(SKILL_TYPE_AVA, lineIndex, RAPIDS_INDEX)
		if ai.isPassive == false then
            -- add it to the skill localization array
            FR.RapidsSkillsArray[lineIndex] = ai.abilityName
            FR.RapidsSkillsArray[ai.abilityName] = lineIndex
            table.insert(FR.skillChoices, ai.abilityName)
        end
    end
end

-- returns true or false if toon has RapidManeuvers or morph
function FR.LoadSkillInfo()
    -- always load rapids even if not unlocked
    FR.loadSkillLocsArray()
    FR.loadRapids()
	return true
end

function FR.SetSkills()
	FR.SaveSlot(saved.switchSlot + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX)
end

function FR.onMountedStateChanged(eventCode, mounted)
	if( FR.hasRapids() == false ) then return end
	
	local isCombat = IsUnitInCombat('player')
	--logger:Debug("onMountedStateChanged: "..SF.nilDefault(eventCode,"nil").." "..tostring(mounted).."  isCombat="..tostring(isCombat))
	if saved.autoswitchEnabled == false then
		--logger:Debug("autoswitchEnabled="..tostring(saved.autoswitchEnabled))
		return
	end
	
	--logger:Debug("noSwitchActive="..tostring(saved.noSwitchActive))
	--logger:Debug("checkRapidsActive="..tostring(FR.checkRapidsActive()))
    if mounted == true and saved.noSwitchActive == true then
        if FR.checkRapidsActive() == true then
			--logger:Debug("no switching when rapids is active")
			FR.setRapidsMode()
            return
        end
    end

	FR.setRapidsMode(mounted)
	FR.SwapSkill()
end

-- Interesting: This will get called when teleporting between zones as well as on character login.
local function onPlayerActivated(ev, init)
	currentHotBar = GetActiveWeaponPairInfo()
	local beltSlot = saved.switchSlot + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX
	if rapidsMode == Mode_False then
		FR.SaveSlot(beltSlot)
	end
    if FR.hasRapids() == true then
		if IsMounted() then
			FR.onMountedStateChanged(nil,true)
		else
			FR.SwapSkill()
		end
	end
end

function FR.isAccountWide()
	return toon.accountWide
end

function FR.setCurrentSV(newval)
    FR.saved = SF.currentSavedVars(FR.aw, toon, newval)
end

function FR.RegisterMountSwitch()
	if FR.hasRapids() == false then 
		return 
	end	-- must check here because settings uses this also

	if saved.autoswitchEnabled == true then
		EVENT_MANAGER:RegisterForEvent(FR.name, EVENT_MOUNTED_STATE_CHANGED, FR.onMountedStateChanged)
    else
		EVENT_MANAGER:UnregisterForEvent(FR.name, EVENT_MOUNTED_STATE_CHANGED)
	end

end

function FR:SavePosition()
	local w = FastRideWindow
    local x, y

   y = w:GetTop()
   x = w:GetLeft()

   if (x < 0 ) then x = 0 end
   if( y < 0 ) then y = 0 end
   saved.offsetx = x
   saved.offsety = y
end

function FR:ResetPosition()
   saved.offsetx = 0
   saved.offsety = 0
end

function FR.onCombatMode(eventCode, inCombat)
    if inCombat == false then
		if swap_queued == true then 
			queuedSwapSkill()
		end
	end
end

local function SaveTerminator(term_mode)
	-- 1 == reloadui/setCvar
	-- 2 == logout
	-- 3 == quit
	saved.term_mode = term_mode
end

local function onAddonLoaded(ev, addonName)
	if addonName ~= FR.name then return end
	
	EVENT_MANAGER:UnregisterForEvent(FR.name, EVENT_ADD_ON_LOADED)

   -- load string table(s)
   SF.LoadLanguage(FastRide_localization_strings,"en")

   -- manage saved variables
   FR.aw, FR.toon = SF.getAllSavedVars("FastRideVars", 1, FR.Defaults)
   toon = FR.toon
   toon.savedSkillId = toon.savedSkillId or {}

	FR.setCurrentSV()
	saved = FR.saved

	--
	FR.LoadSkillInfo()
	baseSkill = saved.baseSkill
	--if not saved.baseSkill then saved.baseSkill = baseSkill end

	SF.initSounds()

	-- config change conversion
	if saved.soundIndex then
		saved.sound = SF.getSound(saved.soundIndex)
		saved.soundIndex = nil
	end
	
	FR.SaveSlot(saved.switchSlot + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX)

	-- settings page
	FR.RegisterSettings()

	EVENT_MANAGER:RegisterForEvent(FR.name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
	if( FR.hasRapids() == true ) then
		EVENT_MANAGER:RegisterForEvent(FR.name, EVENT_ACTION_SLOT_ABILITY_USED, FR.onSlotAbilityUsed)
		EVENT_MANAGER:RegisterForEvent(FR.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, FR.onActiveWeaponPairChanged)
		EVENT_MANAGER:RegisterForEvent(FR.name, EVENT_ACTION_SLOT_UPDATED, FR.onSlotAbilityChanged)
		EVENT_MANAGER:RegisterForEvent(FR.name, EVENT_PLAYER_COMBAT_STATE, FR.onCombatMode)
		FR.RegisterMountSwitch()
	end
	FastRideWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saved.offsetx, saved.offsety)
	FastRideWindow:SetHandler("OnMoveStop", FR.SavePosition)
	if( saved.iconEnabled == true and FR.hasRapids()) then
		FastRideWindowIndicator:SetAlpha(1)
	else
		FastRideWindowIndicator:SetAlpha(0)
	end
	FastRideWindow:SetDrawLayer(DL_BACKGROUND)

    ZO_PreHook("ReloadUI", function()
        SaveTerminator(1)
    end)

    ZO_PreHook("SetCVar", function()
        SaveTerminator(1)
    end)

    ZO_PreHook("Logout", function()
        SaveTerminator(2)
    end)

    ZO_PreHook("Quit", function()
        SaveTerminator(3)
    end)
end

local function slashToggleDebug()
	-- have a local debugmode variable instead of just using FRmsg:toggleDebug()
	-- (the addonChatter keeps track of its own state without outside assistance)
	-- just so that I can print to chat that I am enabling or disabling debug mode.
	if( debugmode == false ) then
		debugmode = true
		FRmsg:enableDebug()
		FRmsg:systemMessage("Enabling debug")

	else
		FRmsg:systemMessage("Disabling debug")
		debugmode = false
		FRmsg:disableDebug()
	end
end

function FR.slashHelp()
	if FRmsg == nil then return end
    local cmdtable = {
        {"/fastride", FR_SLASH_HELP},
        {"/fastride.key", FR_SLASH_KEY},
		{"/fastride setskills", FR_SLASH_SKILLS},
        {"/fastride rescan", FR_SLASH_RELOAD},
        {"/fastride reload", FR_SLASH_RELOAD},
        {"/fastride debug", FR_SLASH_DEBUG},
    }
    local title = "FastRide commands"
    FRmsg:slashHelp(title, cmdtable)
end

-- slash commands (must not have capital letters!!)
SLASH_COMMANDS["/fastride"] = function(...)
	local nargs = select('#',...)
	if( nargs == 0 ) then
		FR.slashHelp()
	else
		i = 1
		local v = select(i,...)
        local t = type(v)
        if(v == nil or v == "") then
			FR.slashHelp()
		elseif(t == "table") then
			logger:Warn("Invalid argument for /fastride")
		else
			local s = tostring(v)
			if( s == "debug" ) then
				slashToggleDebug()
			elseif( s == "setskills" ) then
				FR.SetSkills()
			elseif( s == "rescan" ) then
				FR.LoadSkillInfo()
			elseif( s == "reload" ) then
				FR.LoadSkillInfo()
			elseif( s == "help") then
				FR.slashHelp()
            else
                logger:Warn("Invalid argument for /fastride")
			end
		end
	end
end

-- toggle Rapids mode command
SLASH_COMMANDS["/fastride.key"] = function()
	FR.SwapSkill(true)
end

EVENT_MANAGER:RegisterForEvent(FR.name, EVENT_ADD_ON_LOADED, onAddonLoaded)

