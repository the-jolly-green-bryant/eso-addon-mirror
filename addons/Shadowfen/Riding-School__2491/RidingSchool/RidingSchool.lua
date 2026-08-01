local L = GetString
local RS = RidingSchool
local SF = LibSFUtils

-- for defaults, see RidingSchool_Global.lua

RS.saved = nil
RS.hasReloaded = true
RS.maxstats = {
    [RIDING_TRAIN_SPEED] = 60,
    [RIDING_TRAIN_STAMINA] = 60,
    [RIDING_TRAIN_CARRYING_CAPACITY] = 60,
}
RS.disables = {}


--  saved variable access variables
local aw, toon

-- Define translation array
RS.Mapping = {
    [RIDING_TRAIN_SPEED] = L(RS_NOPT_SPEED),
    [RIDING_TRAIN_CARRYING_CAPACITY] = L(RS_NOPT_CAPACITY),
    [RIDING_TRAIN_STAMINA] = L(RS_NOPT_STAMINA),
    speed = RIDING_TRAIN_SPEED,
    capacity = RIDING_TRAIN_CARRYING_CAPACITY,
    stamina = RIDING_TRAIN_STAMINA,
    [L(RS_NOPT_SPEED)] = RIDING_TRAIN_SPEED,
    [L(RS_NOPT_CAPACITY)] = RIDING_TRAIN_CARRYING_CAPACITY,
    [L(RS_NOPT_STAMINA)] = RIDING_TRAIN_STAMINA,
}

-- --------------------------------------------------------------
-- send debug messages to chat if enabled
local RSmsg = SF.addonChatter:New(RS.name)
local debugmode=false
RSmsg:disableDebug()

local function dbg(...)	-- mostly because I hate to type
	RSmsg:debugMsg(...)
end

local function SystemMessage(...) 
    RSmsg:systemMessage(...)
end

local function slashToggleDebug()
	-- have a local debugmode variable instead of just using RSmsg:toggleDebug()
	-- (the addonChatter keeps track of its own state without outside assistance)
	-- just so that I can print to chat that I am enabling or disabling debug mode.
	if( debugmode == false ) then
		debugmode = true
		RSmsg:enableDebug()
		RSmsg:systemMessage("Enabling debug")

	else
		RSmsg:systemMessage("Disabling debug")
		debugmode = false
		RSmsg:disableDebug()
	end
end

-- --------------------------------------------------------------

local function getStats()
	local capacityBonus, maxCapacityBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
    
	local statsMapped = {
		[RIDING_TRAIN_SPEED] = {speedBonus, maxSpeedBonus},
		[RIDING_TRAIN_CARRYING_CAPACITY] = {capacityBonus, maxCapacityBonus},
		[RIDING_TRAIN_STAMINA] = {staminaBonus, maxStaminaBonus},
	}
    return statsMapped
end

function RS.distributeEvenly()
end

-- figure out which skill to train this time
function RS.getOneSkillToTrain()
	local statsMapped = getStats()
	local order = RS.saved.Order
    local threshold = RS.saved.threshold
    for index, skillToTrain in pairs(order) do
        if RS.saved.disables[skillToTrain] == false then
            local stats = statsMapped[skillToTrain]
            if stats[1] < threshold[skillToTrain] then
                -- Improve this skill up to threshold
                return skillToTrain
            end
        end
	end
    -- all of the skills are at threshold,
    -- so start improving them beyond threshold in the same order.
    for index, skillToTrain in pairs(order) do
        if RS.saved.disables[skillToTrain] == false then
            local stats = statsMapped[skillToTrain]
            if stats[1] < stats[2] then
                return skillToTrain
            end
        end
    end
end

function RS.trainSkill(skillToTrain)
    if skillToTrain == nil then return end
    
    -- Improve this skill
    EVENT_MANAGER:RegisterForEvent(RS.name, EVENT_RIDING_SKILL_IMPROVEMENT, RS.OnRidingSkillImprovement)
    TrainRiding(skillToTrain)
end

function RS.OnStableInteract(eventCode)
	EVENT_MANAGER:UnregisterForEvent(RS.name, EVENT_STABLE_INTERACT_START)

    local skillToTrain = RS.getOneSkillToTrain()
    if skillToTrain ~= nil then
        RS.trainSkill(skillToTrain)
    end
end

function RS.OnRidingSkillImprovement(eventCode, ridingSkillType, previous, current, ridingTrainSource)
	EVENT_MANAGER:UnregisterForEvent(RS.name, EVENT_RIDING_SKILL_IMPROVEMENT)
	ZO_SharedInteraction:CloseChatterAndDismissAssistant()
	SCENE_MANAGER:Show('hud')
end

function RS.OnChatterBegin(eventCode, optionCount)
	local unitCaption = GetUnitCaption('interact')
	if unitCaption and string.find(unitCaption:lower(), L(RS_STABLE_MASTER):lower()) then
        dbg("checking skill levels")
        local skills = getStats()
        local cantrain = 0
        for i, v in pairs(skills) do
            dbg("index "..i.." cur "..v[1].." threshold "..RS.saved.threshold[i].." max "..v[2])
            if v[1] < v[2] then
                cantrain = cantrain + 1
            end
        end
        if cantrain > 0 then
            dbg("register OnStableInteract")
            EVENT_MANAGER:RegisterForEvent(RS.name, EVENT_STABLE_INTERACT_START, RS.OnStableInteract)
        end
        SelectChatterOption(1)
	end
end

-- Perform startup tasks for this addon
-- It is expected to be executed on player activation (login or zone change)
function RS.OnPlayerActive()
	EVENT_MANAGER:UnregisterForEvent(RS.name, EVENT_PLAYER_ACTIVATED)
    if RS.hasReloaded then
        if STABLE_MANAGER:IsRidingSkillMaxedOut() then
            --SystemMessage("Riding Skills are fully trained.")
            RS.StartUnneeded()
        else
            RS.Start()
            EVENT_MANAGER:RegisterForEvent(RS.name, EVENT_CHATTER_BEGIN, RS.OnChatterBegin)
        end
        RS.hasReloaded = false
    end
end

-- Perform all load preparation for this addon
-- It is expected to only be executed on addon load or reload
function RS.Load()
    RS.hasReloaded = true
    local capacityBonus, maxCapacityBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
    RS.maxstats[RIDING_TRAIN_SPEED]=maxSpeedBonus
    RS.maxstats[RIDING_TRAIN_STAMINA]=maxStaminaBonus
    RS.maxstats[RIDING_TRAIN_CARRYING_CAPACITY]=maxCapacityBonus

	EVENT_MANAGER:RegisterForEvent(RS.name, EVENT_PLAYER_ACTIVATED, RS.OnPlayerActive)
end

function RS.StartUnneeded()
    -- don't need saved vars here either
    RS.UnneededSettingsMenu()
end


-- Perform all preparation and start this addon
function RS.Start()
    RS.SettingsMenu()
end

-- shutdown all of my possible handlers
-- (except for EVENT_ADD_ON_LOADED which is already unregistered before this
-- could even potentially be called)
function RS.Stop()
	EVENT_MANAGER:UnregisterForEvent(RS.name, EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:UnregisterForEvent(RS.name, EVENT_CHATTER_BEGIN)
	EVENT_MANAGER:UnregisterForEvent(RS.name, EVENT_RIDING_SKILL_IMPROVEMENT)
    EVENT_MANAGER:UnregisterForEvent(RS.name, EVENT_STABLE_INTERACT_STRS)
end

-- This is the settings menu used for a character that can
-- no longer train because all riding skills are maxed out.
function RS.UnneededSettingsMenu()
	local menu = LibAddonMenu2
	local panel = {
		type = "panel",
		name = RS.name,
		displayName = RS.displayName,
		author = RS.author,
        version = RSversion,
	    slashCommand = "/rs.settings",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local options = {
		{
			type = "description",
			text = RS_UNNEEDED_DESC,
		},
    }
    
	menu:RegisterAddonPanel("RSOptionsMenu", panel)
	menu:RegisterOptionControls("RSOptionsMenu", options)
end

function RS.SettingsMenu()

	local notifyChoices = {
		L(RS_NOPT_SPEED), 
		L(RS_NOPT_STAMINA),
		L(RS_NOPT_CAPACITY), 
	}
	local menu = LibAddonMenu2
	
	local panel = {
		type = "panel",
		name = RS.name,
		displayName = RS.displayName,
		author = RS.author,
        version = RSversion,
	    slashCommand = "/rs.settings",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local options = {
		{
			type = "checkbox",
			name = SF.colors.bronze:Colorize(RS_ACCOUNTWIDE),
			tooltip = RS_ACCOUNTWIDE_TT,
			getFunc = function() return toon.accountWide end,
			setFunc = function(value) 
                RS.saved = SF.currentSavedVars(aw,toon,value)
			end,
			default = RS.defaults.accountWide,
		},
		{
			type = "header",
			name = SF.colors.teal:Colorize(RS_DISABLES_HDR),
		},
		{
			type = "description",
			text = SF.colors.mocassin:Colorize(RS_DISABLES_DESC),
		},
		{
			type = "checkbox",
			name = RS_DISABLE_SPEED,
			tooltip = RS_DISABLESPEED_TT,
			getFunc = function() return RS.saved.disables[RIDING_TRAIN_SPEED] end,
			setFunc = function(value) 
				RS.saved.disables[RIDING_TRAIN_SPEED] = value 
			end,
			default = RS.defaults.disables[RIDING_TRAIN_SPEED],
		},
		{
			type = "checkbox",
			name = RS_DISABLE_STAMINA,
			tooltip = RS_DISABLESTAMINA_TT,
			getFunc = function() return RS.saved.disables[RIDING_TRAIN_STAMINA] end,
			setFunc = function(value) 
				RS.saved.disables[RIDING_TRAIN_STAMINA] = value 
			end,
			default = RS.defaults.disables[RIDING_TRAIN_STAMINA],
		},
		{
			type = "checkbox",
			name = RS_DISABLE_CAPACITY,
			tooltip = RS_DISABLECAPACITY_TT,
			getFunc = function() return RS.saved.disables[RIDING_TRAIN_CARRYING_CAPACITY] end,
			setFunc = function(value) 
				RS.saved.disables[RIDING_TRAIN_CARRYING_CAPACITY] = value 
			end,
			default = RS.defaults.disables[RIDING_TRAIN_CARRYING_CAPACITY],
		},
		{
			type = "header",
			name = SF.colors.teal:Colorize(RS_ORDER_HDR),
		},
		{
			type = "description",
			text = SF.colors.mocassin:Colorize(RS_ORDER_DESC),
		},
		{
			type = "dropdown",
			name = RS_ORDER_FIRST,
			choices = notifyChoices,
			getFunc = function() return RS.Mapping[RS.saved.Order[1]] end,
			setFunc = function(var)
                local prev = RS.saved.Order[1]
				RS.saved.Order[1] = RS.Mapping[var]
                if RS.saved.Order[2] == RS.Mapping[var] then
                    RS.saved.Order[2] = prev
                elseif RS.saved.Order[3] == RS.Mapping[var] then
                    RS.saved.Order[3] = prev
                end
			end,
			disabled = function() 
					return RS.saved.disables[RS.saved.Order[1]]
				end,
			default = RS.Mapping[L(RS_NOPT_SPEED)], 
			width = "full",
		},  -- end dropdown
		{
			type = "dropdown",
			name = RS_ORDER_SECOND,
			choices = notifyChoices,
			getFunc = function() return RS.Mapping[RS.saved.Order[2]] end,
			setFunc = function(var)
                local prev = RS.saved.Order[2]
				RS.saved.Order[2] = RS.Mapping[var]
                if RS.saved.Order[1] == RS.Mapping[var] then
                    RS.saved.Order[1] = prev
                elseif RS.saved.Order[3] == RS.Mapping[var] then
                    RS.saved.Order[3] = prev
                end
			end,
			disabled = function() 
					return RS.saved.disables[RS.saved.Order[2]]
				end,
			default = RS.Mapping[L(RS_NOPT_CAPACITY)], 
			width = "full",
		},  -- end dropdown
		{
			type = "dropdown",
			name = RS_ORDER_THIRD,
			choices = notifyChoices,
			getFunc = function() return RS.Mapping[RS.saved.Order[3]] end,
			setFunc = function(var)
                local prev = RS.saved.Order[3]
				RS.saved.Order[3] = RS.Mapping[var]
                if RS.saved.Order[1] == RS.Mapping[var] then
                    RS.saved.Order[1] = prev
                elseif RS.saved.Order[2] == RS.Mapping[var] then
                    RS.saved.Order[2] = prev
                end
			end,
			disabled = function() 
					return RS.saved.disables[RS.saved.Order[3]]
				end,
			default = RS.Mapping[L(RS_NOPT_STAMINA)], 
			width = "full",
		},  -- end dropdown
		{
			type = "header",
			name = SF.colors.teal:Colorize(RS_THRESHOLDS_HDR),
		},
		{
			type = "description",
			text = SF.colors.mocassin:Colorize(RS_THRESHOLDS_DESC),
		},
		{
			type = "slider",
			name = L(RS_NOPT_SPEED),
			min = 0,
			max = 60,
			step = 1,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			disabled = function() 
					return RS.saved.disables[RIDING_TRAIN_SPEED]
				end,
			getFunc = function() return RS.saved.threshold[RIDING_TRAIN_SPEED] end,
			setFunc = function(value) RS.saved.threshold[RIDING_TRAIN_SPEED] = value end,
			default = RS.defaults.threshold[RIDING_TRAIN_SPEED],
		},
		{
			type = "slider",
			name = L(RS_NOPT_STAMINA),
			min = 0,
			max = 60,
			step = 1,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			disabled = function() 
					return RS.saved.disables[RIDING_TRAIN_STAMINA]
				end,
			getFunc = function() return RS.saved.threshold[RIDING_TRAIN_STAMINA] end,
			setFunc = function(value) RS.saved.threshold[RIDING_TRAIN_STAMINA] = value end,
			default = RS.defaults.threshold[RIDING_TRAIN_STAMINA],
		},
		{
			type = "slider",
			name = L(RS_NOPT_CAPACITY),
			min = 0,
			max = 60,
			step = 1,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			disabled = function() 
					return RS.saved.disables[RIDING_TRAIN_CARRYING_CAPACITY]
				end,
			getFunc = function() return RS.saved.threshold[RIDING_TRAIN_CARRYING_CAPACITY] end,
			setFunc = function(value) RS.saved.threshold[RIDING_TRAIN_CARRYING_CAPACITY] = value end,
			default = RS.defaults.threshold[RIDING_TRAIN_CARRYING_CAPACITY],
		},
	}

	menu:RegisterAddonPanel("RSOptionsMenu", panel)
	menu:RegisterOptionControls("RSOptionsMenu", options)

end


-- --------------------------------------------------------------------------
-- entrypoint for ZOS
function RS.OnLoad(eventCode, addon)
	if addon ~= RS.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(RS.name, EVENT_ADD_ON_LOADED)

    -- load our saved variables
    aw, toon = SF.getAllSavedVars(RS.savedVars, RS.savedVarVersion, RS.defaults, RS.defaults)
    RS.saved = SF.currentSavedVars(aw, toon)

    RS.Load()
end

EVENT_MANAGER:RegisterForEvent(RS.name, EVENT_ADD_ON_LOADED, RS.OnLoad)

-- --------------------------------------------------------------------------
function RS.slashHelp()
	if RSmsg == nil then return end
    local cmdtable = {
        {"/rs", RS_SLASH_HELP},
        {"/rs.settings", RS_SLASH_SETTINGS},
        {"/rs.display", RS_SLASH_DISPLAY},
        {"/rs debug", RS_SLASH_DEBUG},
    }
    local title = "RidingSchool commands"
    RSmsg:slashHelp(title, cmdtable)
end

-- slash commands (must not have capital letters!!)
SLASH_COMMANDS["/rs"] = function(...)
	local nargs = select('#',...)
	if( nargs == 0 ) then
		RS.slashHelp()
	else
		i = 1
		local v = select(i,...)
        local t = type(v)
        if(v == nil or v == "") then
			RS.slashHelp()
		elseif(t == "table") then
			RSmsg:debugMsg("Invalid argument for /rs")
		else
			local s = tostring(v)
			if( s == "debug" ) then
				slashToggleDebug()
			elseif( s == "help") then
				RS.slashHelp()
            else
                RSmsg:debugMsg("Invalid argument for /rs")
			end
		end
	end
end

SLASH_COMMANDS["/rs.display"] = function(command)
	if not command or command == "" then
		SystemMessage("Current riding skill order:")
		local order = RS.saved.Order
		for index, skillType in pairs(order) do
			SystemMessage(tostring(index)..". "..RS.Mapping[skillType])
		end
		if toon.accountWide then
			SystemMessage("Using account settings.")
		else
			SystemMessage("Using character settings.")
		end
		return
	end
end

