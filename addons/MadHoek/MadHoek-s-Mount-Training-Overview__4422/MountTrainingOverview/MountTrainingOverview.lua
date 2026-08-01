-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- 							    Mount Training Overview aka HorseTrainingTime (MHMTO) ESO AddOn by MadHoek 												-----
---- 										Thanks to Cosh`s BiteTimers from which I learned a lot!															-----
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
---- This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates.													-----
---- The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 		-----
---- All rights reserved																																	-----
----																																						-----
---- You can read the full terms at https://account.elderscrollsonline.com/add-on-terms																		-----
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create a namespace for MHMTO by declaring a top-level table that will hold everything else.
if MHMTO == nil then MHMTO = {} end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Main AddOn Data
MHMTO.name     			= "MountTrainingOverview"
MHMTO.version  			= "3.0.4"
MHMTO.settings 			= {}
MHMTO.chars    			= {}
-- default colors
MHMTO.defaultColors = {
	titleR = .98,
	titleG = .98,
	titleB = .7,
	titleA = 1,
	maxR = 	.32,
	maxG =	.66,
	maxB = 	.3,
	maxA = 	1,
	notMaxR = .74,
	notMaxG = .74,
	notMaxB = .24,
	notMaxA = 1,
	canTrainR = .55,
	canTrainG =	.35,
	canTrainB = .7,
	canTrainA = 1,
	noTrainR = .55,
	noTrainG = .6,
	noTrainB = .9,
	noTrainA = 1,
	timeR = .79,
	timeG = .79,
	timeB = .79,
	timeA = 1,
	timeErrorR = .9,
	timeErrorG = .3,
	timeErrorB = .3,
	timeErrorA = 1

}
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
local activeCharID  	 = nil
local activeCharName  	 = nil
local activeCharAlliance = nil
local activeChar   		 = nil
local charsCount   		 = 0

local wm = GetWindowManager()
local em = GetEventManager()

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Setup -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- h2. Game API
-- * GetRidingStats()
-- ** _Returns:_ *integer* _inventoryBonus_, *integer* _maxInventoryBonus_, *integer* _staminaBonus_, *integer* _maxStaminaBonus_, *integer* _speedBonus_, *integer* _maxSpeedBonus_
--
-- * GetMaxRidingTraining(*[RidingTrainType|#RidingTrainType]* _trainTypeIndex_)
-- ** _Returns:_ *integer* _maxValue_
--
-- * GetTimeUntilCanBeTrained()
-- ** _Returns:_ *integer* _timeMs_, *integer* _totalDurationMs_
--
-- * GetTrainingCost()
-- ** _Returns:_ *integer* _cost_
--
-- * GetNumUpgradesPerStablemasterTraining()
-- ** _Returns:_ *integer* _numUpgrades_
--
-- * TrainRiding(*[RidingTrainType|#RidingTrainType]* _trainTypeIndex_)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Register the event handler function to be called to do initialization
em:RegisterForEvent(MHMTO.name, EVENT_ADD_ON_LOADED, function(...) MHMTO.Initialize(...) end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->

-- Function to initialize MHMTO with ESO
function MHMTO.Initialize(event, addon)
	if addon ~= MHMTO.name then return end

	em:UnregisterForEvent(MHMTO.name, EVENT_ADD_ON_LOADED)

	-- Default values for saved variables
	MHMTO.defaultSavedVars = { 
			chars = {},
			globalReadytime = -1,
			use24h = true,
			dateFormatMode = 0, -- 0=client default, 1=DD/MM/YYYY, 2=MM/DD/YYYY, 3=YYYY-MM-DD (ISO)
			shown = true,
			showtitle = true,
			alpha = 50,
			x = 40,
			y = 450,
			showAlliance = false,
			showStats = true,
			fontSize = 18,
			showTrainable = true,
			showMaxed = true,
			showCharID = false,
			locked = false,
			colors = {
				titleR = .98,
				titleG = .98,
				titleB = .7,
				titleA = 1,
				maxR = 	.32,
				maxG =	.66,
				maxB = 	.3,
				maxA = 	1,
				notMaxR = .74,
				notMaxG = .74,
				notMaxB = .24,
				notMaxA = 1,
				canTrainR = .55,
				canTrainG =	.35,
				canTrainB = .7,
				canTrainA = 1,
				noTrainR = .55,
				noTrainG = .6,
				noTrainB = .9,
				noTrainA = 1,
				timeR = .79,
				timeG = .79,
				timeB = .79,
				timeA = 1,
				timeErrorR = .9,
				timeErrorG = .3,
				timeErrorB = .3,
				timeErrorA = 1
			},
		}

	-- Create Saved Vars
	MHMTO.settings = ZO_SavedVars:NewAccountWide("MountTrainingOverviewSavedVars", 1, GetWorldName(), MHMTO.defaultSavedVars)

	if (MHMTO.settings.fontSize       == nil) then MHMTO.settings.fontSize       = 18    end
	if (MHMTO.settings.shown      	  == nil) then MHMTO.settings.shown          = true  end
	if (MHMTO.settings.showtitle  	  == nil) then MHMTO.settings.showtitle      = true  end
	if (MHMTO.settings.alpha      	  == nil) then MHMTO.settings.alpha          = 50    end
	if (MHMTO.settings.use24h 		  == nil) then MHMTO.settings.use24h 	     = true  end
	if (MHMTO.settings.dateFormatMode == nil) then MHMTO.settings.dateFormatMode = 0 	 end
	if (MHMTO.settings.x          	  == nil) then MHMTO.settings.x              = 40    end
	if (MHMTO.settings.y          	  == nil) then MHMTO.settings.y              = 450   end
	if (MHMTO.settings.showAlliance   == nil) then MHMTO.settings.showAlliance   = false end
	if (MHMTO.settings.showTrainable  == nil) then MHMTO.settings.showTrainable  = true  end
	if (MHMTO.settings.showMaxed      == nil) then MHMTO.settings.showMaxed      = true  end
	if (MHMTO.settings.showStats   	  == nil) then MHMTO.settings.showStats      = true  end
	if (MHMTO.settings.showCharID     == nil) then MHMTO.settings.showCharID     = false end
	if (MHMTO.settings.locked     	  == nil) then MHMTO.settings.locked     	 = false end

	if (MHMTO.settings.nameversion == nil) or (MHMTO.settings.nameversion ~= MHMTO.version) then MHMTO.settings.nameversion = MHMTO.version end
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->>
	-- Set Default Colors if no Custom Color is Set e.g. First Run
	----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->>
	-- Title Color
	if (MHMTO.settings.colors.titleR      == nil) then MHMTO.settings.colors.titleR    = MHMTO.defaultColors.titleR    	end
	if (MHMTO.settings.colors.titleG      == nil) then MHMTO.settings.colors.titleG    = MHMTO.defaultColors.titleG    	end
	if (MHMTO.settings.colors.titleB      == nil) then MHMTO.settings.colors.titleB    = MHMTO.defaultColors.titleB    	end
	if (MHMTO.settings.colors.titleA      == nil) then MHMTO.settings.colors.titleA    = MHMTO.defaultColors.titleA    	end
	-- Maxed Color
	if (MHMTO.settings.colors.maxR        == nil) then MHMTO.settings.colors.maxR 	   = MHMTO.defaultColors.maxR    	end
	if (MHMTO.settings.colors.maxG        == nil) then MHMTO.settings.colors.maxG 	   = MHMTO.defaultColors.maxG    	end
	if (MHMTO.settings.colors.maxB        == nil) then MHMTO.settings.colors.maxB 	   = MHMTO.defaultColors.maxB    	end
	if (MHMTO.settings.colors.maxA        == nil) then MHMTO.settings.colors.maxA 	   = MHMTO.defaultColors.maxA    	end
	-- Not Maxed Color
	if (MHMTO.settings.colors.notMaxR     == nil) then MHMTO.settings.colors.notMaxR   = MHMTO.defaultColors.notMaxR    end
	if (MHMTO.settings.colors.notMaxG     == nil) then MHMTO.settings.colors.notMaxG   = MHMTO.defaultColors.notMaxG    end
	if (MHMTO.settings.colors.notMaxB     == nil) then MHMTO.settings.colors.notMaxB   = MHMTO.defaultColors.notMaxB    end
	if (MHMTO.settings.colors.notMaxA     == nil) then MHMTO.settings.colors.notMaxA   = MHMTO.defaultColors.notMaxA    end
	-- Can Train Color
	if (MHMTO.settings.colors.canTrainR   == nil) then MHMTO.settings.colors.canTrainR = MHMTO.defaultColors.canTrainR	end
	if (MHMTO.settings.colors.canTrainG   == nil) then MHMTO.settings.colors.canTrainG = MHMTO.defaultColors.canTrainG 	end
	if (MHMTO.settings.colors.canTrainB   == nil) then MHMTO.settings.colors.canTrainB = MHMTO.defaultColors.canTrainB 	end
	if (MHMTO.settings.colors.canTrainA   == nil) then MHMTO.settings.colors.canTrainA = MHMTO.defaultColors.canTrainA 	end
	-- No Training Color
	if (MHMTO.settings.colors.noTrainR    == nil) then MHMTO.settings.colors.noTrainR  = MHMTO.defaultColors.noTrainR	end
	if (MHMTO.settings.colors.noTrainG    == nil) then MHMTO.settings.colors.noTrainG  = MHMTO.defaultColors.noTrainG   end
	if (MHMTO.settings.colors.noTrainB    == nil) then MHMTO.settings.colors.noTrainB  = MHMTO.defaultColors.noTrainB   end
	if (MHMTO.settings.colors.noTrainA    == nil) then MHMTO.settings.colors.noTrainA  = MHMTO.defaultColors.noTrainA   end
	-- Time Color
	if (MHMTO.settings.colors.timeR  	  == nil) then MHMTO.settings.colors.timeR 	   = MHMTO.defaultColors.timeR		end
	if (MHMTO.settings.colors.timeG  	  == nil) then MHMTO.settings.colors.timeG 	   = MHMTO.defaultColors.timeG 		end
	if (MHMTO.settings.colors.timeB  	  == nil) then MHMTO.settings.colors.timeB 	   = MHMTO.defaultColors.timeB 		end
	if (MHMTO.settings.colors.timeA  	  == nil) then MHMTO.settings.colors.timeA 	   = MHMTO.defaultColors.timeA 		end
	-- Time Error Color
	if (MHMTO.settings.colors.timeErrorR == nil) then MHMTO.settings.colors.timeErrorR = MHMTO.defaultColors.timeErrorR	end
	if (MHMTO.settings.colors.timeErrorG == nil) then MHMTO.settings.colors.timeErrorG = MHMTO.defaultColors.timeErrorG end
	if (MHMTO.settings.colors.timeErrorB == nil) then MHMTO.settings.colors.timeErrorB = MHMTO.defaultColors.timeErrorB end
	if (MHMTO.settings.colors.timeErrorA == nil) then MHMTO.settings.colors.timeErrorA = MHMTO.defaultColors.timeErrorA end

	-- Make a label for the keybinding
	GetString(SI_BINDING_NAME_MHMTO_WINDOW_TOGGLE)

	MHMTO.InitializeControls()

	-- Register for Player Activated Event in order to collect all data
	em:RegisterForEvent(MHMTO.name, EVENT_PLAYER_ACTIVATED, function(...) MHMTO.OnPlayerActivated(...) end)
	-- Register for Riding Skill Improvement Event fired whenever a riding stat increases-> save data on state change
	em:RegisterForEvent(MHMTO.name, EVENT_RIDING_SKILL_IMPROVEMENT, function(...) MHMTO.OnRidingSkillImprovement(...) end)
	-- Optional fallback: not required anymore
	-- em:RegisterForEvent(MHMTO.name, EVENT_STABLE_INTERACT_END, function(...) MHMTO.SaveRidingData(...) end)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Helpers ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Compare character names
function MHMTO.compareCharNames(char1, char2)
    local n1 = (char1 and char1.name) or ""
    local n2 = (char2 and char2.name) or ""
    return n1:lower() < n2:lower()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Always resolve the active runtime char entry
function MHMTO.GetCharById(charId)
	for idx = 1, charsCount do
		if MHMTO.chars[idx] and MHMTO.chars[idx].ID == charId then
			return MHMTO.chars[idx], idx
		end
	end
	return nil, nil
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Function to repair "num" field if a character is deleted out of the list
function MHMTO.RepairCharNumbers()
    if not MHMTO.settings or not MHMTO.settings.chars then return end

    -- ensure runtime list is in final order (already sorted by name)
    table.sort(MHMTO.chars, MHMTO.compareCharNames)

    for i = 1, #MHMTO.chars do
        local rt = MHMTO.chars[i]
        if rt and rt.ID and MHMTO.settings.chars[rt.ID] then
            MHMTO.settings.chars[rt.ID].num = i
            rt.num = i
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Function to check if the horse is trainable and when it can be trained
function MHMTO.GetActiveCharHorseReadyTimeSec()
	-- canTrain (UI semantic):
	-- true = character is not maxed and still participates in the mount training lifecycle
	-- does NOT mean "trainable right now"
	local horseInventoryStat, horseMaxInventory, horseStaminaStat, horseMaxStamina, horseSpeedStat, horseMaxSpeed = GetRidingStats("player")
	local readyTimeSec = -1
	--local neverTrained = false
	local canTrain = false
	local horseMaxed = false
	local trainingTimer = nil
	local activeCharHorseSpeed = 0
	local activeCharHorseStamina = 0
	local activeCharHorseInventory = 0

	trainingTimer = GetTimeUntilCanBeTrained("player")
	activeCharHorseSpeed = horseSpeedStat
	activeCharHorseStamina = horseStaminaStat
	activeCharHorseInventory = horseInventoryStat
	
	if (activeCharHorseSpeed == horseMaxSpeed) and (activeCharHorseStamina == horseMaxStamina) and (activeCharHorseInventory == horseMaxInventory) then
		horseMaxed = true
	elseif (horseMaxed == false) and ((activeCharHorseSpeed <= horseMaxSpeed) and (activeCharHorseStamina <= horseMaxStamina) and (activeCharHorseInventory <= horseMaxInventory)) then
		canTrain = true
		if trainingTimer and trainingTimer > 0 then
			readyTimeSec = (trainingTimer/1000) + GetTimeStamp()
		else
			readyTimeSec = -1
		end
	elseif (canTrain == false) and (horseMaxed == false) then
		readyTimeSec = -1
	end

	return readyTimeSec, canTrain, horseMaxed, activeCharHorseSpeed, activeCharHorseStamina, activeCharHorseInventory
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Check valid date values
function MHMTO.IsValidYMD(y,m,d)
	y=tonumber(y); m=tonumber(m); d=tonumber(d)
	return y and m and d and (y>=2000 and y<=2100) and (m>=1 and m<=12) and (d>=1 and d<=31)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Check and Save Char Data because of State Change
function MHMTO.SaveRidingData()
    local activeCharID = GetCurrentCharacterId("player")

    local readyTimeSec, canTrain, horseMaxed, horseSpeed, horseStamina, horseInventory =
        MHMTO.GetActiveCharHorseReadyTimeSec()

    local char = MHMTO.GetCharById(activeCharID)
    local saved = MHMTO.settings.chars[activeCharID]
    if not char or not saved then return end

    readyTimeSec = math.floor(readyTimeSec)
    local now = GetTimeStamp()

    local prevReady = saved.readytime or -1

    -- runtime
    char.horseSpeed = horseSpeed
    char.horseStamina = horseStamina
    char.horseInventory = horseInventory
	--char.neverTrained = neverTrained
    char.canTrain = canTrain
    char.horseMaxed = horseMaxed
    char.readytime = readyTimeSec

    -- saved vars
    saved.horseSpeed = horseSpeed
    saved.horseStamina = horseStamina
    saved.horseInventory = horseInventory
	--saved.neverTrained = neverTrained
    saved.canTrain = canTrain
    saved.horseMaxed = horseMaxed
    saved.readytime = readyTimeSec

    -- Detect timer state
    local prevWasRunning = (prevReady ~= -1) and (prevReady > now)
    local isTimerRunning = (readyTimeSec ~= -1) and (readyTimeSec > now)

    -- "trained" = transitioned into cooldown (NOT just a changed timestamp)
    local didStartCooldown = isTimerRunning and (not prevWasRunning)

    -- Keep globalReadytime sane (never allow 0)
    local g = tonumber(MHMTO.settings.globalReadytime) or -1
    if g == 0 then g = -1 end

	if saved.neverTrained == nil then
		local spd  = horseSpeed or 0
		local stam = horseStamina or 0
		local inv  = horseInventory or 0

		if spd == 0 and stam == 0 and inv == 0 then
			saved.neverTrained = true
		else
			saved.neverTrained = false
		end
	end

	-- didStartCooldown = you already compute this correctly
	if didStartCooldown then
		saved.neverTrained = false
	end

	char.neverTrained = saved.neverTrained

	if didStartCooldown then
		-- per-character: when this char trained (wall clock)
		saved.startedAtSec = now
		char.startedAtSec  = now

		-- store pure date integer (YYYYMMDD) - language/locale safe
		saved.startedAtDate = GetDate()
		char.startedAtDate  = saved.startedAtDate

		-- store exact local seconds-of-day for stable clock display
		saved.startedAtSod = GetSecondsSinceMidnight()
		char.startedAtSod  = saved.startedAtSod
	end

    -- Update globalReadytime whenever we see a running cooldown (books won't trigger this)
    if isTimerRunning then
        if readyTimeSec > g then
            MHMTO.settings.globalReadytime = readyTimeSec
            g = readyTimeSec
        end
    else
        -- If globalReadytime is expired/invalid, try to repair it from saved chars once
        if g <= now then
            local maxRt = -1
            for _, sv in pairs(MHMTO.settings.chars) do
                local crt = tonumber(sv.readytime) or -1
                if crt > now and crt > maxRt then
                    maxRt = crt
                end
            end
            MHMTO.settings.globalReadytime = (maxRt > now) and maxRt or -1
        end
    end

    table.sort(MHMTO.chars, MHMTO.compareCharNames)

    -- make it feel instant
    MHMTO.RefreshWindow()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Layout helper
function MHMTO.ApplyColumnLayout()
    -- show/hide the whole alliance column
    MHMTO.window.entries.column2:SetHidden(not MHMTO.window.showAlliance)

    -- re-anchor stats column depending on whether alliance column exists
    MHMTO.window.entries.column3:ClearAnchors()
    if MHMTO.window.showAlliance then
        MHMTO.window.entries.column3:SetAnchor(TOPLEFT, MHMTO.window.entries.column2, TOPRIGHT, 15, 0)
    else
        MHMTO.window.entries.column3:SetAnchor(TOPLEFT, MHMTO.window.entries.column1, TOPRIGHT, 15, 0)
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Title helper
function MHMTO.ApplyTitleLayout()
    MHMTO.window.entries:ClearAnchors()

    if MHMTO.settings.showtitle then
        MHMTO.window.title:SetHidden(false)
        MHMTO.window.icon1:SetHidden(false)
        MHMTO.window.icon2:SetHidden(false)
        MHMTO.window.entries:SetAnchor(TOP, MHMTO.window.title, BOTTOM, 0, 0)
    else
        MHMTO.window.title:SetHidden(true)
        MHMTO.window.icon1:SetHidden(true)
        MHMTO.window.icon2:SetHidden(true)
        MHMTO.window.entries:SetAnchor(TOP, MHMTO.window, TOP, 0, 0)
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Update row helper
function MHMTO.UpdateRow(i)
    local char = MHMTO.chars[i]
    local s = MHMTO.settings.colors

    -- Alliance text
    local allianceName = "    "
    if char.alliance == 1 then
        allianceName = GetString(MHMTO_HORSE_AD)
    elseif char.alliance == 2 then
        allianceName = GetString(MHMTO_HORSE_EP)
    elseif char.alliance == 3 then
        allianceName = GetString(MHMTO_HORSE_DC)
    end

    -- Name formatting
    local name = char.name
    if MHMTO.window.showCharID then
        name = tostring(char.ID) .. " / " .. name
    end

    -- Stats text
    local stringSpeed, stringStamina, stringInventory
    if MHMTO.window.showStats then
        stringSpeed     = GetString(MHMTO_HORSE_SPEED) .. tostring(char.horseSpeed or 0)
        stringStamina   = GetString(MHMTO_HORSE_STAMINA) .. tostring(char.horseStamina or 0)
        stringInventory = GetString(MHMTO_HORSE_INVENTORY) .. tostring(char.horseInventory or 0)
    else
        stringSpeed, stringStamina, stringInventory = "", "", ""
    end

	local item = MHMTO.window.entries.column1.items[i]
	if not item then return end

    -- Colors
    if char.horseMaxed then
        for col=1,6 do
            MHMTO.window.entries["column"..col].items[i]:SetColor(s.maxR, s.maxG, s.maxB, s.maxA)
        end
    elseif char.canTrain and not char.horseMaxed then
        MHMTO.window.entries.column1.items[i]:SetColor(s.canTrainR, s.canTrainG, s.canTrainB, s.canTrainA)
        MHMTO.window.entries.column2.items[i]:SetColor(s.canTrainR, s.canTrainG, s.canTrainB, s.canTrainA)

        MHMTO.window.entries.column3.items[i]:SetColor(s.notMaxR, s.notMaxG, s.notMaxB, s.notMaxA)
        MHMTO.window.entries.column4.items[i]:SetColor(s.notMaxR, s.notMaxG, s.notMaxB, s.notMaxA)
        MHMTO.window.entries.column5.items[i]:SetColor(s.notMaxR, s.notMaxG, s.notMaxB, s.notMaxA)

        if char.horseSpeed == 60 then
            MHMTO.window.entries.column3.items[i]:SetColor(s.maxR, s.maxG, s.maxB, s.maxA)
        end
        if char.horseStamina == 60 then
            MHMTO.window.entries.column4.items[i]:SetColor(s.maxR, s.maxG, s.maxB, s.maxA)
        end
        if char.horseInventory == 60 then
            MHMTO.window.entries.column5.items[i]:SetColor(s.maxR, s.maxG, s.maxB, s.maxA)
        end

		if char.neverTrained then
			MHMTO.window.entries.column1.items[i]:SetColor(s.noTrainR, s.noTrainG, s.noTrainB, s.noTrainA)
			MHMTO.window.entries.column2.items[i]:SetColor(s.noTrainR, s.noTrainG, s.noTrainB, s.noTrainA)

			MHMTO.window.entries.column3.items[i]:SetColor(s.noTrainR, s.noTrainG, s.noTrainB, s.noTrainA)
			MHMTO.window.entries.column4.items[i]:SetColor(s.noTrainR, s.noTrainG, s.noTrainB, s.noTrainA)
			MHMTO.window.entries.column5.items[i]:SetColor(s.noTrainR, s.noTrainG, s.noTrainB, s.noTrainA)
		end

    else
        for col=1,5 do
            MHMTO.window.entries["column"..col].items[i]:SetColor(s.timeErrorR, s.timeErrorG, s.timeErrorB, s.timeErrorA)
        end
    end

	-- Column 6 (time/status) color + initial text snapshot (non-ticking)
	local label6 = MHMTO.window.entries.column6.items[i]
	if label6 then
		local now = GetTimeStamp()
		if char.horseMaxed then
			label6:SetColor(s.maxR, s.maxG, s.maxB, s.maxA)
			label6:SetText(GetString(MHMTO_HORSE_MAX))
		elseif char.neverTrained then -- "never trained" bucket
			label6:SetColor(s.noTrainR, s.noTrainG, s.noTrainB, s.noTrainA)
			label6:SetText(GetString(MHMTO_HORSE_NO))

		else
			-- IMPORTANT: only show countdown if THIS character is actually on cooldown
			if char.readytime > now then
				local globalReady = MHMTO.settings.globalReadytime or -1
				local remaining = globalReady - now
				if remaining < 0 then remaining = 0 end

				if remaining == 0 then
					if char.canTrain then
						label6:SetColor(s.notMaxR, s.notMaxG, s.notMaxB, s.notMaxA)
						label6:SetText(GetString(MHMTO_HORSE_READY))
					else
						label6:SetColor(s.timeErrorR, s.timeErrorG, s.timeErrorB, s.timeErrorA)
						label6:SetText("?")
					end
				else
					label6:SetColor(s.timeR, s.timeG, s.timeB, s.timeA)
					label6:SetText(" ") -- IMPORTANT: don’t show placeholder junk before first tick
				end
			end	
		end
	end

    -- Finally, set texts
    MHMTO.window.entries.column1.items[i]:SetText(name)
    MHMTO.window.entries.column2.items[i]:SetText(allianceName)
    MHMTO.window.entries.column3.items[i]:SetText(stringSpeed)
    MHMTO.window.entries.column4.items[i]:SetText(stringStamina)
    MHMTO.window.entries.column5.items[i]:SetText(stringInventory)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Update the timer countdown
function MHMTO.UpdateTimeTick()
    if not MHMTO.window or MHMTO.window:IsHidden() then return end
    if charsCount <= 0 then return end

    local now = GetTimeStamp()
    local s = MHMTO.settings.colors

    for i = 1, charsCount do
        local char = MHMTO.chars[i]
        local label = MHMTO.window.entries.column6.items[i]
        if char and label and not label:IsHidden() then

            if char.horseMaxed then
                label:SetColor(s.maxR, s.maxG, s.maxB, s.maxA)
                label:SetText(GetString(MHMTO_HORSE_MAX))

            elseif char.neverTrained then
                label:SetColor(s.noTrainR, s.noTrainG, s.noTrainB, s.noTrainA)
                label:SetText(GetString(MHMTO_HORSE_NO))

            else
                -- IMPORTANT: only show countdown if THIS character is actually on cooldown
                if char.readytime > now then
					local globalReady = MHMTO.settings.globalReadytime or -1
                    local remaining = globalReady - now
					if remaining < 0 then remaining = 0 end

                    label:SetColor(s.timeR, s.timeG, s.timeB, s.timeA)

                    local h = math.floor(remaining / 3600)
                    remaining = remaining - (h * 3600)
                    local m = math.floor(remaining / 60)
                    remaining = remaining - (m * 60)
                    local sec = remaining

                    local stime = ""
                    if h > 0 then stime = stime .. h .. "h " end
                    if m > 0 then stime = stime .. m .. "m " end
                    stime = stime .. sec .. "s"

                    label:SetText(stime)
                else
                    label:SetColor(s.notMaxR, s.notMaxG, s.notMaxB, s.notMaxA)
                    label:SetText(GetString(MHMTO_HORSE_READY))
                end
            end
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Timestamp Format helper (LOCAL + 24h, + 12h)
function MHMTO.FormatClockTimeFromTimestamp(ts, savedSod)
    -- If we stored the exact local seconds-of-day at the time of training, use it.
    local secsSinceMidnight = nil
    if type(savedSod) == "number" and savedSod >= 0 and savedSod < 86400 then
        secsSinceMidnight = savedSod
    end

    -- Fallback for older saved data (no startedAtSod yet):
    -- derive local seconds-of-day relative to now (works, but can drift across DST changes)
    if not secsSinceMidnight then
        if not ts or ts <= 0 then return "" end
        local now = GetTimeStamp()
        local nowLocal = GetSecondsSinceMidnight()
        local delta = ts - now
        secsSinceMidnight = (nowLocal + delta) % 86400
        if secsSinceMidnight < 0 then secsSinceMidnight = secsSinceMidnight + 86400 end
    end

    -- 12h mode (ESO handles locale AM/PM)
    if not MHMTO.settings.use24h and type(FormatTimeSeconds) == "function" then
        return FormatTimeSeconds(secsSinceMidnight, TIME_FORMAT_STYLE_CLOCK_TIME, TIME_FORMAT_PRECISION_SECONDS)
    end

    -- 24h forced mode
    local h = math.floor(secsSinceMidnight / 3600)
    local m = math.floor((secsSinceMidnight - h * 3600) / 60)
    local s = math.floor(secsSinceMidnight - h * 3600 - m * 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Date Format helper (client default OR forced formats)
-- mode: 0=client default, 1=DD.MM.YYYY, 2=MM/DD/YYYY, 3=YYYY-MM-DD (ISO)
function MHMTO.FormatDate(ts, dateInt)
    local mode = MHMTO.settings.dateFormatMode or 0

    -- Client default (never touch)
    if mode == 0 then
        return GetDateStringFromTimestamp(ts)
    end

    if not dateInt or dateInt <= 0 then
        return ""
    end

    local y = math.floor(dateInt / 10000)
    local m = math.floor((dateInt % 10000) / 100)
    local d = dateInt % 100

    if mode == 1 then
        return string.format("%02d.%02d.%04d", d, m, y)
    elseif mode == 2 then
        return string.format("%02d/%02d/%04d", m, d, y)
    elseif mode == 3 then
        return string.format("%04d-%02d-%02d", y, m, d)
    end

    -- fallback safety
    return GetDateStringFromTimestamp(ts)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Tooltip Builder
function MHMTO.ShowStartedTooltip(control, idx)
    local char = MHMTO.chars[idx]
    if not char then return end

    local startedText = GetString(MHMTO_CHAR_STARTED)

    local hasRecord = char.startedAtSec and char.startedAtSec > 0

	local neverTrained = (char.neverTrained == true)

    InitializeTooltip(InformationTooltip, control, TOP, 0, 5)

    -- 1) Never trained ever
	if neverTrained then
		SetTooltipText(
			InformationTooltip,
			string.format(GetString(MHMTO_CHAR_NEVER_TRAINED), char.name)
		)
		return
	end

    -- 2) No record (addon installed later)
    if not hasRecord then
        SetTooltipText(InformationTooltip,
            string.format("%s %s",
                startedText,
                GetString(MHMTO_CHAR_BEFORE_RECORDS)
            )
        )
        return
    end

    -- 3) Normal recorded case
    local dateStr = MHMTO.FormatDate(char.startedAtSec, char.startedAtDate)
    local timeStr = MHMTO.FormatClockTimeFromTimestamp(char.startedAtSec, char.startedAtSod)

    SetTooltipText(InformationTooltip,
        string.format("%s %s %s", startedText, dateStr, timeStr)
    )
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Set Fontsize / Title-Iconsize & Iconposition
function MHMTO.SetFontSize(value)

	MHMTO.window.fontSize = value
	MHMTO.window.iconSize = value*2

	MHMTO.window.icon1:ClearAnchors()
	MHMTO.window.icon2:ClearAnchors()
	MHMTO.window.icon1:SetAnchor(RIGHT, MHMTO.window.title.label, LEFT, -MHMTO.window.iconSize*0.3, 0)
	MHMTO.window.icon2:SetAnchor(LEFT, MHMTO.window.title.label, RIGHT, MHMTO.window.iconSize*0.3, 0)
	MHMTO.window.icon1:SetDimensions(MHMTO.window.iconSize,MHMTO.window.iconSize)
	MHMTO.window.icon2:SetDimensions(MHMTO.window.iconSize,MHMTO.window.iconSize)
	MHMTO.window.title.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column1.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column2.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column3.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column4.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column5.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column6.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column1:ClearAnchors()
	MHMTO.window.entries.column1:SetAnchor(TOPLEFT, MHMTO.window.entries, TOPLEFT, 0, MHMTO.window.fontSize)
	for i=1, charsCount do
		MHMTO.window.entries.column1.items[i]:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		MHMTO.window.entries.column2.items[i]:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		MHMTO.window.entries.column3.items[i]:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		MHMTO.window.entries.column4.items[i]:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		MHMTO.window.entries.column5.items[i]:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		MHMTO.window.entries.column6.items[i]:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Function to restore the default Colors
function MHMTO.SetDefaultColors()
	-- Title Color
	MHMTO.settings.colors.titleR, MHMTO.settings.colors.titleG, MHMTO.settings.colors.titleB, MHMTO.settings.colors.titleA
	=
	MHMTO.defaultColors.titleR, MHMTO.defaultColors.titleG, MHMTO.defaultColors.titleB, MHMTO.defaultColors.titleA
	----------------------------------------------------------------------------------------------------------------------------------
	-- Training Possible Color
	MHMTO.settings.colors.canTrainR, MHMTO.settings.colors.canTrainG, MHMTO.settings.colors.canTrainB, MHMTO.settings.colors.canTrainA
	=
	MHMTO.defaultColors.canTrainR, MHMTO.defaultColors.canTrainG, MHMTO.defaultColors.canTrainB, MHMTO.defaultColors.canTrainA
	----------------------------------------------------------------------------------------------------------------------------------
	-- All Riding Stats Maxed Color
	MHMTO.settings.colors.maxR, MHMTO.settings.colors.maxG, MHMTO.settings.colors.maxB, MHMTO.settings.colors.maxA
	=
	MHMTO.defaultColors.maxR, MHMTO.defaultColors.maxG, MHMTO.defaultColors.maxB, MHMTO.defaultColors.maxA
	----------------------------------------------------------------------------------------------------------------------------------
	-- Riding Stats Not Maxed Color
	MHMTO.settings.colors.notMaxR, MHMTO.settings.colors.notMaxG, MHMTO.settings.colors.notMaxB, MHMTO.settings.colors.notMaxA
	=
	MHMTO.defaultColors.notMaxR, MHMTO.defaultColors.notMaxG, MHMTO.defaultColors.notMaxB, MHMTO.defaultColors.notMaxA
	----------------------------------------------------------------------------------------------------------------------------------
	-- No Training Color
	MHMTO.settings.colors.noTrainR, MHMTO.settings.colors.noTrainG, MHMTO.settings.colors.noTrainB, MHMTO.settings.colors.noTrainA
	=
	MHMTO.defaultColors.noTrainR, MHMTO.defaultColors.noTrainG, MHMTO.defaultColors.noTrainB, MHMTO.defaultColors.noTrainA
	----------------------------------------------------------------------------------------------------------------------------------
	-- Time Display Color
	MHMTO.settings.colors.timeR, MHMTO.settings.colors.timeG, MHMTO.settings.colors.timeB,MHMTO.settings.colors.timeA
	=
	MHMTO.defaultColors.timeR, MHMTO.defaultColors.timeG, MHMTO.defaultColors.timeB, MHMTO.defaultColors.timeA
	----------------------------------------------------------------------------------------------------------------------------------
	-- Time Display Error Color
	MHMTO.settings.colors.timeErrorR, MHMTO.settings.colors.timeErrorG, MHMTO.settings.colors.timeErrorB, MHMTO.settings.colors.timeErrorA
	=
	MHMTO.defaultColors.timeErrorR, MHMTO.defaultColors.timeErrorG, MHMTO.defaultColors.timeErrorB, MHMTO.defaultColors.timeErrorA
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Function to show or hide Characters
function MHMTO.ShowOrHideCharacters()

	local column1LastItem = MHMTO.window.entries.column1.label
	local column2LastItem = MHMTO.window.entries.column2.label
	local column3LastItem = MHMTO.window.entries.column3.label
	local column4LastItem = MHMTO.window.entries.column4.label
	local column5LastItem = MHMTO.window.entries.column5.label
	local column6LastItem = MHMTO.window.entries.column6.label
	
	for i = 1, charsCount do
		local c = MHMTO.chars[i]
		local T = MHMTO.settings.showTrainable
		local M = MHMTO.settings.showMaxed

		-- Decide visibility
		local showChar = false

		if c.horseMaxed then
			showChar = M

		elseif c.neverTrained then
			-- show if Trainable is on OR both toggles are off (fallback)
			-- (equivalently: hide only when M==true and T==false)
			showChar = T or (not M)

		elseif c.canTrain then
			showChar = T

		else
			-- "cooldown but not maxed" bucket or whatever trainable is considered
			-- Usually these should be controlled by showTrainable:
			showChar = T
		end

		if not showChar then
			-- hideChar = true
			MHMTO.window.entries.column1.items[i]:SetAnchor(TOPLEFT, MHMTO.window.entries.column1.label, BOTTOMLEFT, 0, 5)
			MHMTO.window.entries.column2.items[i]:SetAnchor(TOP, MHMTO.window.entries.column2.label, BOTTOM, 0, 5)
			MHMTO.window.entries.column3.items[i]:SetAnchor(TOP, MHMTO.window.entries.column3.label, BOTTOM, 0, 5)
			MHMTO.window.entries.column4.items[i]:SetAnchor(TOP, MHMTO.window.entries.column4.label, BOTTOM, 0, 5)
			MHMTO.window.entries.column5.items[i]:SetAnchor(TOP, MHMTO.window.entries.column5.label, BOTTOM, 0, 5)
			MHMTO.window.entries.column6.items[i]:SetAnchor(TOP, MHMTO.window.entries.column6.label, BOTTOM, 0, 5)
			MHMTO.window.entries.column1.items[i]:SetHidden(true)
			MHMTO.window.entries.column2.items[i]:SetHidden(true)
			MHMTO.window.entries.column3.items[i]:SetHidden(true)
			MHMTO.window.entries.column4.items[i]:SetHidden(true)
			MHMTO.window.entries.column5.items[i]:SetHidden(true)
			MHMTO.window.entries.column6.items[i]:SetHidden(true)
		else
			-- hideChar = false
			MHMTO.window.entries.column1.items[i]:SetAnchor(TOPLEFT, column1LastItem, BOTTOMLEFT, 0, 5)
			MHMTO.window.entries.column2.items[i]:SetAnchor(TOP, column2LastItem, BOTTOM, 0, 5)
			MHMTO.window.entries.column3.items[i]:SetAnchor(TOP, column3LastItem, BOTTOM, 0, 5)
			MHMTO.window.entries.column4.items[i]:SetAnchor(TOP, column4LastItem, BOTTOM, 0, 5)
			MHMTO.window.entries.column5.items[i]:SetAnchor(TOP, column5LastItem, BOTTOM, 0, 5)
			MHMTO.window.entries.column6.items[i]:SetAnchor(TOP, column6LastItem, BOTTOM, 0, 5)
			column1LastItem = MHMTO.window.entries.column1.items[i]
			column2LastItem = MHMTO.window.entries.column2.items[i]
			column3LastItem = MHMTO.window.entries.column3.items[i]
			column4LastItem = MHMTO.window.entries.column4.items[i]
			column5LastItem = MHMTO.window.entries.column5.items[i]
			column6LastItem = MHMTO.window.entries.column6.items[i]
			MHMTO.window.entries.column1.items[i]:SetHidden(false)
			MHMTO.window.entries.column2.items[i]:SetHidden(false)
			MHMTO.window.entries.column3.items[i]:SetHidden(false)
			MHMTO.window.entries.column4.items[i]:SetHidden(false)
			MHMTO.window.entries.column5.items[i]:SetHidden(false)
			MHMTO.window.entries.column6.items[i]:SetHidden(false)
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Show or hide the window
function MHMTO.SetWindowShown(show)
    -- Ensure window exists
    if MHMTO.window == nil then
        MHMTO.CreateWindow()
    end

    MHMTO.settings.shown = show

    -- If compass is hidden, window must remain hidden even if show=true
    local shouldHide = (not show) or ZO_CompassFrame:IsHidden()
    MHMTO.window:SetHidden(shouldHide)

    if MHMTO.settingsPanel then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MHMTO.settingsPanel)
    end
end

function MHMTO.ToggleWindow()
    MHMTO.SetWindowShown(not MHMTO.settings.shown)
end

-- lock/unlock window
function MHMTO.LockMHMTO()
	MHMTO.settings.locked = true
	MHMTO.window:SetMovable(not MHMTO.settings.locked)
end

function MHMTO.UnlockMHMTO()
	MHMTO.settings.locked = false
	MHMTO.window:SetMovable(not MHMTO.settings.locked)
end

-- Toggle window locked
function MHMTO.ToggleMovable()
	if MHMTO.settings.locked == true then
			MHMTO.UnlockMHMTO()
			MHMTO.settings.locked = false
		elseif MHMTO.settings.locked == false then
			MHMTO.LockMHMTO()
			MHMTO.settings.locked = true
	end
	CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", MHMTO.settingsPanel)
end

function MHMTO.InitializeControls()

	-- SLASH COMMANDS --Toggle (show/hide & lock/unlock)
	SLASH_COMMANDS["/mhmtov"] = MHMTO.ToggleWindow
	SLASH_COMMANDS["/mhmtom"] = MHMTO.ToggleMovable
	return

end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Handler ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- snapshot current state at riding skill improvement
function MHMTO.OnRidingSkillImprovement(eventCode, ridingSkillType, previousValue, currentValue, source)
    -- ridingSkillType will tell which one changed (speed/stamina/capacity),
    -- but it's not really needed, because all stats are going to be re-read anyway.
    MHMTO.SaveRidingData()
end

-- Mouse Enter
function MHMTO.OnTimeLabelEnter(self)
    if not self or not self.mhmtoIndex then return end
    MHMTO.ShowStartedTooltip(self, self.mhmtoIndex)
end

-- Mouse Exit
function MHMTO.OnTimeLabelExit(self)
    ClearTooltip(InformationTooltip)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Mount Training Overview -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Get all necessary data and create the window at session start
function MHMTO.OnPlayerActivated()
	activeCharID     		 = GetCurrentCharacterId("player")
	MHMTO.activeCharName     = GetUnitName("player")
	MHMTO.activeCharAlliance = GetUnitAlliance("player")

	-- Sync stored name/alliance for the currently logged-in character (handles rename token)
	do
		local id = activeCharID
		local currentName = MHMTO.activeCharName
		local currentAlliance = MHMTO.activeCharAlliance

		-- Ensure saved entry exists (the code already creates it later, this is just safe)
		if MHMTO.settings.chars[id] then
			local sv = MHMTO.settings.chars[id]

			if sv.name ~= currentName then
				sv.name = currentName
			end
			if sv.alliance ~= currentAlliance then
				sv.alliance = currentAlliance
			end
		end

		-- If runtime row already exists, update it too (so UI updates immediately)
		local rtChar, rtIdx = MHMTO.GetCharById(id)
		if rtChar then
			rtChar.name = currentName
			rtChar.alliance = currentAlliance
		end
	end

	-- Get active character actual parameters (one consistent call)
	local readyTimeSec, canTrain, horseMaxed, activeCharHorseSpeed, activeCharHorseStamina, activeCharHorseInventory = MHMTO.GetActiveCharHorseReadyTimeSec()

	local now = GetTimeStamp()
	local rt  = math.floor(readyTimeSec or -1)

	-- normalize globalReadytime
	local g = tonumber(MHMTO.settings.globalReadytime) or -1
	if g == 0 then g = -1 end

	-- 1) If CURRENT character is on cooldown, globalReadytime must be at least that
	if rt > now then
		if g < rt then
			g = rt
			MHMTO.settings.globalReadytime = g
		end
	else
		-- 2) Current char is READY, so DO NOT touch globalReadytime here.
		-- But if globalReadytime is invalid, try to repair it from saved chars once.
		if g <= now then
			local maxRt = -1
			for _, sv in pairs(MHMTO.settings.chars) do
				local crt = tonumber(sv.readytime) or -1
				if crt > now and crt > maxRt then
					maxRt = crt
				end
			end

			-- Only write back if we found a valid cooldown timestamp
			if maxRt > now then
				MHMTO.settings.globalReadytime = maxRt
			else
				-- no cooldown exists anywhere -> keep disabled
				MHMTO.settings.globalReadytime = -1
			end
		end
	end
	
	if charsCount == 0 then
		for k,v in pairs(MHMTO.settings.chars) do
		
			charsCount = charsCount + 1
			
			-- Settings checking and correction
			if MHMTO.settings.chars[k].num        	  == nil then MHMTO.settings.chars[k].num        	 = -1    end
			if MHMTO.settings.chars[k].alliance   	  == nil then MHMTO.settings.chars[k].alliance   	 = -1    end
			if MHMTO.settings.chars[k].horseSpeed     == nil then MHMTO.settings.chars[k].horseSpeed   	 = 0     end
			if MHMTO.settings.chars[k].horseStamina   == nil then MHMTO.settings.chars[k].horseStamina   = 0     end
			if MHMTO.settings.chars[k].horseInventory == nil then MHMTO.settings.chars[k].horseInventory = 0     end
			if MHMTO.settings.chars[k].canTrain 	  == nil then MHMTO.settings.chars[k].canTrain 		 = false end
			if MHMTO.settings.chars[k].horseMaxed 	  == nil then MHMTO.settings.chars[k].horseMaxed 	 = false end
			if MHMTO.settings.chars[k].readytime  	  == nil then MHMTO.settings.chars[k].readytime  	 = -1    end
			if MHMTO.settings.chars[k].startedAtSec   == nil then MHMTO.settings.chars[k].startedAtSec   = -1    end
			if MHMTO.settings.chars[k].startedAtSod   == nil then MHMTO.settings.chars[k].startedAtSod   = -1    end
			if MHMTO.settings.chars[k].startedAtDate  == nil then MHMTO.settings.chars[k].startedAtDate  = -1    end
			
			MHMTO.chars[charsCount] = {
				["ID"] 				= k,
				["name"] 			= MHMTO.settings.chars[k].name,
				["alliance"]   		= MHMTO.settings.chars[k].alliance,
				["horseSpeed"] 		= MHMTO.settings.chars[k].horseSpeed,
				["horseStamina"] 	= MHMTO.settings.chars[k].horseStamina,
				["horseInventory"] 	= MHMTO.settings.chars[k].horseInventory,
				["neverTrained"] 	= MHMTO.settings.chars[k].neverTrained,
				["canTrain"] 		= MHMTO.settings.chars[k].canTrain,
				["horseMaxed"] 		= MHMTO.settings.chars[k].horseMaxed,
				["readytime"]  		= MHMTO.settings.chars[k].readytime,
				["startedAtSec"] 	= MHMTO.settings.chars[k].startedAtSec,
				["startedAtSod"] 	= MHMTO.settings.chars[k].startedAtSod,
				["startedAtDate"]   = MHMTO.settings.chars[k].startedAtDate,
				}
	
			if (k == activeCharID) then activeChar = MHMTO.chars[charsCount] end
			
		end
	end

	-- Add active character settings
	if MHMTO.settings.chars[activeCharID] == nil then
		charsCount = charsCount + 1
		MHMTO.settings.chars[activeCharID] = {
			["num"]        	   = charsCount,
			["name"]      	   = MHMTO.activeCharName,
			["alliance"]   	   = MHMTO.activeCharAlliance,
			["horseSpeed"] 	   = activeCharHorseSpeed,
			["horseStamina"]   = activeCharHorseStamina,
			["horseInventory"] = activeCharHorseInventory,
			["neverTrained"]   = nil,
			["canTrain"] 	   = false,
			["horseMaxed"] 	   = false,
			["readytime"]  	   = -1,
			["startedAtSec"]   = -1,
			["startedAtSod"]   = -1,
			["startedAtDate"]  = -1,
			}

		MHMTO.chars[charsCount] = {}
		activeChar = MHMTO.chars[charsCount]
	end

	-- after you ensured MHMTO.settings.chars[activeCharID] exists:
	local saved = MHMTO.settings.chars[activeCharID]

	-- classify only once
	if saved.neverTrained == nil then
		local spd = activeCharHorseSpeed or 0
		local stam = activeCharHorseStamina or 0
		local inv = activeCharHorseInventory or 0

		-- Fresh character observed by addon
		if spd == 0 and stam == 0 and inv == 0 then
			saved.neverTrained = true
		else
			-- character existed before / or already had stats when first seen
			-- keep old behavior (not "never trained" bucket)
			saved.neverTrained = false
		end
	end

	-- runtime mirror
	activeChar.neverTrained = saved.neverTrained

	activeChar.ID = activeCharID
	activeChar.name = MHMTO.activeCharName
	activeChar.alliance = MHMTO.activeCharAlliance
	activeChar.horseSpeed = activeCharHorseSpeed
	activeChar.horseStamina = activeCharHorseStamina
	activeChar.horseInventory = activeCharHorseInventory
	activeChar.neverTrained = saved.neverTrained
	activeChar.canTrain = canTrain
	activeChar.horseMaxed = horseMaxed
	-- Only apply readytime if this character is the one who started the cooldown
	-- local globalReady = MHMTO.settings.globalReadytime or -1
	local now = GetTimeStamp()

	if readyTimeSec > now then
		activeChar.readytime = readyTimeSec
	else
		activeChar.readytime = -1
	end

	-- Save these parameters to settings
	MHMTO.activeCharSettings            	= MHMTO.settings.chars[activeCharID]
	MHMTO.activeCharSettings.name  			= MHMTO.activeCharName
	MHMTO.activeCharSettings.alliance   	= MHMTO.activeCharAlliance
	MHMTO.activeCharSettings.horseSpeed   	= activeCharHorseSpeed
	MHMTO.activeCharSettings.horseStamina   = activeCharHorseStamina
	MHMTO.activeCharSettings.horseInventory = activeCharHorseInventory
	MHMTO.activeCharSettings.neverTrained 	= activeChar.neverTrained
	MHMTO.activeCharSettings.canTrain 		= canTrain
	MHMTO.activeCharSettings.horseMaxed 	= horseMaxed
	MHMTO.activeCharSettings.readytime  	= math.floor(readyTimeSec)

	table.sort(MHMTO.chars, MHMTO.compareCharNames)

	activeChar = MHMTO.GetCharById(activeCharID)

	if not activeChar then
		-- fallback: create runtime row (prevents hard nil errors)
		charsCount = charsCount + 1
		MHMTO.chars[charsCount] = { ID = activeCharID, name = MHMTO.activeCharName, alliance = MHMTO.activeCharAlliance }
		activeChar = MHMTO.chars[charsCount]
	end
	
	MHMTO.RepairCharNumbers()

	MHMTO.RefreshWindow()

	MHMTO.CreateMenu()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Function to create the MHMTO Window if it wasn't created before
function MHMTO.CreateWindow()
	-- Main window
	MHMTO.window = wm:CreateTopLevelWindow(MHMTO.name)

	MHMTO.window:SetClampedToScreen(true)
	-- Keep the backdrop fully on-screen
	MHMTO.window:SetClampedToScreenInsets(-MHMTO.settings.fontSize, -MHMTO.settings.fontSize*0.5, MHMTO.settings.fontSize, MHMTO.settings.fontSize) -- SetClampedToScreenInsets(number left, number top, number right, number bottom)
	MHMTO.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MHMTO.settings.x, MHMTO.settings.y)
	MHMTO.window:SetMovable(not MHMTO.settings.locked)
	MHMTO.window:SetHidden(not MHMTO.settings.shown)
	MHMTO.window:SetMouseEnabled(true)
	MHMTO.window:SetDimensions(0,0)
	MHMTO.window:SetResizeToFitDescendents(true)
	MHMTO.window:SetHandler("OnMoveStop", function()
		MHMTO.settings.x = MHMTO.window:GetLeft()
		MHMTO.settings.y = MHMTO.window:GetTop()
	end)
	MHMTO.window:SetDrawLayer(DL_TEXT)
	
	MHMTO.window.fontSize       	= MHMTO.settings.fontSize
	MHMTO.window.iconSize       	= MHMTO.settings.fontSize*2
	MHMTO.window.showAlliance   	= MHMTO.settings.showAlliance
	MHMTO.window.showStats   		= MHMTO.settings.showStats
	MHMTO.window.showTrainable 	= MHMTO.settings.showTrainable
	MHMTO.window.showMaxed       	= MHMTO.settings.showMaxed
	MHMTO.window.showtitle       	= MHMTO.settings.showtitle

	-- Give it a backdground (backdrop) for the frame
	MHMTO.window.bg = wm:CreateControl("MHMTO_Background", MHMTO.window, CT_BACKDROP)
	MHMTO.window.bg:SetAnchorFill(MHMTO.window)
	MHMTO.window.bg:SetCenterColor(0, 0, 0, MHMTO.settings.alpha / 100)
	MHMTO.window.bg:SetEdgeColor(0, 0, 0, 0)
	MHMTO.window.bg:SetEdgeTexture(nil, 1, 1, 0, 0)
	MHMTO.window.bg:SetInsets(-MHMTO.settings.fontSize, -MHMTO.settings.fontSize*0.5, MHMTO.settings.fontSize, MHMTO.settings.fontSize)
	MHMTO.window.bg:SetExcludeFromResizeToFitExtents(true)

	-- Give it a header
	MHMTO.window.title = wm:CreateControl("MHMTO_Title", MHMTO.window, CT_CONTROL)
	MHMTO.window.title:SetAnchor(TOP, MHMTO.window, TOP, 0, 5)
	MHMTO.window.title:SetHidden(not MHMTO.settings.showtitle)
	MHMTO.window.title:SetResizeToFitDescendents(true)
	MHMTO.window.title:SetResizeToFitPadding(2, 0)
	-- Header text & icons
	MHMTO.window.title.label = wm:CreateControl("MHMTO_Title_Label", MHMTO.window.title, CT_LABEL)
	MHMTO.window.title.label:SetAnchor(TOP, MHMTO.window.title, TOP, 0, 5)
	MHMTO.window.title.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.title.label:SetColor(MHMTO.settings.colors.titleR, MHMTO.settings.colors.titleG, MHMTO.settings.colors.titleB, MHMTO.settings.colors.titleA)
	MHMTO.window.title.label:SetStyleColor(0, 0, 0, 1)
	if MHMTO.settings.shown then
		MHMTO.window.title.label:SetText(GetString(MHMTO_WINDOW_TITLE))
	end

	-- Define Header Icons
	MHMTO.window.icon1 = wm:CreateControl("MHMTO_Icon1", MHMTO.window.title, CT_TEXTURE)
	MHMTO.window.icon1:SetDimensions(MHMTO.window.iconSize,MHMTO.window.iconSize)
	MHMTO.window.icon1:SetAnchor(RIGHT, MHMTO.window.title.label, LEFT, -MHMTO.window.iconSize*0.3, 0)
	MHMTO.window.icon1:SetTexture("EsoUI/Art/Mounts/tabicon_mounts_up.dds")
	MHMTO.window.icon1:SetColor(MHMTO.settings.colors.titleR, MHMTO.settings.colors.titleG, MHMTO.settings.colors.titleB, MHMTO.settings.colors.titleA)
	MHMTO.window.icon1:SetTextureCoords(1, 0, 0, 1) -- flip horizontally
	MHMTO.window.icon1:SetHidden(not MHMTO.settings.showtitle)

	MHMTO.window.icon2 = wm:CreateControl("MHMTO_Icon2",MHMTO.window.title, CT_TEXTURE)
	MHMTO.window.icon2:SetDimensions(MHMTO.window.iconSize, MHMTO.window.iconSize)
	MHMTO.window.icon2:SetAnchor(LEFT, MHMTO.window.title.label, RIGHT, MHMTO.window.iconSize*0.3, 0)
	MHMTO.window.icon2:SetTexture("EsoUI/Art/Mounts/tabicon_mounts_up.dds")
	MHMTO.window.icon2:SetColor(MHMTO.settings.colors.titleR, MHMTO.settings.colors.titleG, MHMTO.settings.colors.titleB, MHMTO.settings.colors.titleA)
	MHMTO.window.icon2:SetTextureCoords(0, 1, 0, 1)  -- normal (not flipped)
	MHMTO.window.icon2:SetHidden(not MHMTO.settings.showtitle)

	-- Make a container for the list entries
	MHMTO.window.entries = wm:CreateControl("MHMTO_Entries", MHMTO.window, CT_CONTROL)
	
	if MHMTO.settings.showtitle and MHMTO.settings.shown then
		MHMTO.window.entries:SetAnchor(TOP, MHMTO.window.title, BOTTOM, 0, 0)
	else
		MHMTO.window.entries:SetAnchor(TOP, MHMTO.window, TOP, 0, 0)
	end

	MHMTO.window.entries:SetHidden(false)
	MHMTO.window.entries:SetResizeToFitDescendents(true)

	-- Characters
	MHMTO.window.entries.column1 = wm:CreateControl("MHMTO_Column1", MHMTO.window.entries, CT_CONTROL)
	MHMTO.window.entries.column1:SetAnchor(TOPLEFT, MHMTO.window.entries, TOPLEFT, 0, MHMTO.window.fontSize)
	MHMTO.window.entries.column1:SetHidden(false)
	MHMTO.window.entries.column1:SetResizeToFitDescendents(true)
	MHMTO.window.entries.column1:SetResizeToFitPadding(2, 0)

	MHMTO.window.entries.column1.label = wm:CreateControl("MHMTO_Column1_Label", MHMTO.window.entries.column1, CT_LABEL)
	MHMTO.window.entries.column1.label:SetAnchor(TOPLEFT, MHMTO.window.entries.column1, TOPLEFT, 0, 0)
	MHMTO.window.entries.column1.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column1.label:SetColor(1, 1, 1, 1)
	MHMTO.window.entries.column1.label:SetStyleColor(0, 0, 0, 1)
	local column1LastItem = MHMTO.window.entries.column1.label

	-- Alliance
	MHMTO.window.entries.column2 = wm:CreateControl("MHMTO_Column2", MHMTO.window.entries, CT_CONTROL)
	MHMTO.window.entries.column2:SetAnchor(TOPLEFT, MHMTO.window.entries.column1, TOPRIGHT, 15, 0)
	MHMTO.window.entries.column2:SetHidden(false)
	MHMTO.window.entries.column2:SetResizeToFitDescendents(true)
	MHMTO.window.entries.column2:SetResizeToFitPadding(2, 0)

	MHMTO.window.entries.column2.label = wm:CreateControl("MHMTO_Column2_Label", MHMTO.window.entries.column2, CT_LABEL)
	MHMTO.window.entries.column2.label:SetAnchor(TOP, MHMTO.window.entries.column2, TOP, 0, 0)
	MHMTO.window.entries.column2.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column2.label:SetColor(1, 1, 1, 1)
	MHMTO.window.entries.column2.label:SetStyleColor(0, 0, 0, 1)
	local column2LastItem = MHMTO.window.entries.column2.label

	-- Speed
	MHMTO.window.entries.column3 = wm:CreateControl("MHMTO_Column3", MHMTO.window.entries, CT_CONTROL)
	MHMTO.window.entries.column3:SetAnchor(TOPLEFT, MHMTO.window.entries.column2, TOPRIGHT, 15, 0)
	MHMTO.window.entries.column3:SetHidden(false)
	MHMTO.window.entries.column3:SetResizeToFitDescendents(true)
	MHMTO.window.entries.column3:SetResizeToFitPadding(2, 0)

	MHMTO.window.entries.column3.label = wm:CreateControl("MHMTO_Column3_Label", MHMTO.window.entries.column3, CT_LABEL)
	MHMTO.window.entries.column3.label:SetAnchor(TOP, MHMTO.window.entries.column3, TOP, 0, 0)
	MHMTO.window.entries.column3.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column3.label:SetColor(1, 1, 1, 1)
	MHMTO.window.entries.column3.label:SetStyleColor(0, 0, 0, 1)
	local column3LastItem = MHMTO.window.entries.column3.label

	-- Stamina
	MHMTO.window.entries.column4 = wm:CreateControl("MHMTO_Column4", MHMTO.window.entries, CT_CONTROL)
	MHMTO.window.entries.column4:SetAnchor(TOPLEFT, MHMTO.window.entries.column3, TOPRIGHT, 5, 0)
	MHMTO.window.entries.column4:SetHidden(false)
	MHMTO.window.entries.column4:SetResizeToFitDescendents(true)
	MHMTO.window.entries.column4:SetResizeToFitPadding(2, 0)

	MHMTO.window.entries.column4.label = wm:CreateControl("MHMTO_Column4_Label", MHMTO.window.entries.column4, CT_LABEL)
	MHMTO.window.entries.column4.label:SetAnchor(TOP, MHMTO.window.entries.column4, TOP, 0, 0)
	MHMTO.window.entries.column4.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column4.label:SetColor(1, 1, 1, 1)
	MHMTO.window.entries.column4.label:SetStyleColor(0, 0, 0, 1)
	local column4LastItem = MHMTO.window.entries.column4.label

	-- Capacity
	MHMTO.window.entries.column5 = wm:CreateControl("MHMTO_Column5", MHMTO.window.entries, CT_CONTROL)
	MHMTO.window.entries.column5:SetAnchor(TOPLEFT, MHMTO.window.entries.column4, TOPRIGHT, 5, 0)
	MHMTO.window.entries.column5:SetHidden(false)
	MHMTO.window.entries.column5:SetResizeToFitDescendents(true)
	MHMTO.window.entries.column5:SetResizeToFitPadding(2, 0)

	MHMTO.window.entries.column5.label = wm:CreateControl("MHMTO_Column5_Label", MHMTO.window.entries.column5, CT_LABEL)
	MHMTO.window.entries.column5.label:SetAnchor(TOP, MHMTO.window.entries.column5, TOP, 0, 0)
	MHMTO.window.entries.column5.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column5.label:SetColor(1, 1, 1, 1)
	MHMTO.window.entries.column5.label:SetStyleColor(0, 0, 0, 1)
	local column5LastItem = MHMTO.window.entries.column5.label
	
	-- Time/Ready/Max/Never Trained
	MHMTO.window.entries.column6 = wm:CreateControl("MHMTO_Column6", MHMTO.window.entries, CT_CONTROL)
	MHMTO.window.entries.column6:SetAnchor(TOPLEFT, MHMTO.window.entries.column5, TOPRIGHT, 15, 0)
	MHMTO.window.entries.column6:SetHidden(false)
	MHMTO.window.entries.column6:SetResizeToFitDescendents(true)
	MHMTO.window.entries.column6:SetResizeToFitPadding(2, 0)

	MHMTO.window.entries.column6.label = wm:CreateControl("MHMTO_Column6_Label", MHMTO.window.entries.column6, CT_LABEL)
	MHMTO.window.entries.column6.label:SetAnchor(TOP, MHMTO.window.entries.column6, TOP, 0, 0)
	MHMTO.window.entries.column6.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
	MHMTO.window.entries.column6.label:SetStyleColor(0, 0, 0, 1)
	MHMTO.window.entries.column6.label:SetColor(1, 1, 1, 1)
	local column6LastItem = MHMTO.window.entries.column6.label
	
	MHMTO.window.entries.column1.items = {}
	MHMTO.window.entries.column2.items = {}
	MHMTO.window.entries.column3.items = {}
	MHMTO.window.entries.column4.items = {}
	MHMTO.window.entries.column5.items = {}
	MHMTO.window.entries.column6.items = {}
	

	for i=1, charsCount do
		MHMTO.window.entries.column1.items[i] = wm:CreateControl("MHMTO_Column1_Item" .. i, MHMTO.window.entries.column1, CT_LABEL)
		local col1item = MHMTO.window.entries.column1.items[i]
		col1item:SetAnchor(TOPLEFT, column1LastItem, BOTTOMLEFT, 0, 5)
		col1item:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		col1item:SetColor(.9, .9, .9, 1)
		col1item:SetStyleColor(0, 0, 0, 1)
		col1item:SetText("HWSChar"..i)
		column1LastItem = col1item

		MHMTO.window.entries.column2.items[i] = wm:CreateControl("MHMTO_Column2_Item" .. i, MHMTO.window.entries.column2, CT_LABEL)
		local col2item = MHMTO.window.entries.column2.items[i]
		col2item:SetAnchor(TOP, column2LastItem, BOTTOM, 0, 5)
		col2item:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		col2item:SetColor(.9, .9, .9, 1)
		col2item:SetStyleColor(0, 0, 0, 1)
		col2item:SetText("HWSChar"..i)
		column2LastItem = col2item

		MHMTO.window.entries.column3.items[i] = wm:CreateControl("MHMTO_Column3_Item" .. i, MHMTO.window.entries.column3, CT_LABEL)
		local col3item = MHMTO.window.entries.column3.items[i]
		col3item:SetAnchor(TOP, column3LastItem, BOTTOM, 0, 5)
		col3item:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		col3item:SetColor(.9, .9, .9, 1)
		col3item:SetStyleColor(0, 0, 0, 1)
		col3item:SetText("HWSStats"..i)
		column3LastItem = col3item

		MHMTO.window.entries.column4.items[i] = wm:CreateControl("MHMTO_Column4_Item" .. i, MHMTO.window.entries.column4, CT_LABEL)
		local col4item = MHMTO.window.entries.column4.items[i]
		col4item:SetAnchor(TOP, column4LastItem, BOTTOM, 0, 5)
		col4item:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		col4item:SetColor(.9, .9, .9, 1)
		col4item:SetStyleColor(0, 0, 0, 1)
		col4item:SetText("HWSStats"..i)
		column4LastItem = col4item

		MHMTO.window.entries.column5.items[i] = wm:CreateControl("MHMTO_Column5_Item" .. i, MHMTO.window.entries.column5, CT_LABEL)
		local col5item = MHMTO.window.entries.column5.items[i]
		col5item:SetAnchor(TOP, column5LastItem, BOTTOM, 0, 5)
		col5item:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		col5item:SetColor(.9, .9, .9, 1)
		col5item:SetStyleColor(0, 0, 0, 1)
		col5item:SetText("HWSStats"..i)
		column5LastItem = col5item

		MHMTO.window.entries.column6.items[i] = wm:CreateControl("MHMTO_Column6_Item" .. i, MHMTO.window.entries.column6, CT_LABEL)
		local col6item = MHMTO.window.entries.column6.items[i]
		col6item.mhmtoIndex = i   -- attach index to control
		col6item:SetMouseEnabled(true)
		col6item:SetHandler("OnMouseEnter", MHMTO.OnTimeLabelEnter)
		col6item:SetHandler("OnMouseExit",  MHMTO.OnTimeLabelExit)
		col6item:SetAnchor(TOP, column6LastItem, BOTTOM, 0, 5)
		col6item:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		col6item:SetColor(.9, .9, .9, 1)
		col6item:SetStyleColor(0, 0, 0, 1)
		col6item:SetText("0d 0h 0m 0s")
		column6LastItem = col6item
	end
	
	MHMTO.ApplyColumnLayout()
	MHMTO.ShowOrHideCharacters();
	MHMTO.UpdateTimeTick()

	-- Hide the window when the compass frame gets hidden, if it's not hidden already
	if ZO_CompassFrame:IsHandlerSet("OnShow") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnShow")
		ZO_CompassFrame:SetHandler("OnShow", function(...) oldHandler(...) if MHMTO.settings.shown then MHMTO.window:SetHidden(false) end end)
	else
		ZO_CompassFrame:SetHandler("OnShow", function(...) if MHMTO.settings.shown then MHMTO.window:SetHidden(false) end end)
	end
	
	if ZO_CompassFrame:IsHandlerSet("OnHide") then
		local oldHandler = ZO_CompassFrame:GetHandler("OnHide")
		ZO_CompassFrame:SetHandler("OnHide", function(...) oldHandler(...) if MHMTO.settings.shown then MHMTO.window:SetHidden(true) end end)
	else
		ZO_CompassFrame:SetHandler("OnHide", function(...) if MHMTO.settings.shown then MHMTO.window:SetHidden(true) end end)
	end
	
	EVENT_MANAGER:RegisterForUpdate(MHMTO.name, 1000, function() MHMTO.UpdateTimeTick() end)

end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- Function to refresh the Window
function MHMTO.RefreshWindow()
	
	if MHMTO.window == nil then MHMTO.CreateWindow() end

	--activeCharID     	= GetCurrentCharacterId("player")
	MHMTO.activeCharName     = GetUnitName("player")
	MHMTO.activeCharAlliance = GetUnitAlliance("player")
	
	local readyTimeSec, canTrain, horseMaxed, activeCharHorseSpeed, activeCharHorseStamina, activeCharHorseInventory = MHMTO.GetActiveCharHorseReadyTimeSec()

	readyTimeSec = math.floor(readyTimeSec)

	-- Update "current character" identity consistently
	activeCharID = GetCurrentCharacterId("player")
	MHMTO.activeCharID = activeCharID
	activeChar = MHMTO.GetCharById(activeCharID)
	MHMTO.activeCharSettings = MHMTO.settings.chars[activeCharID]

	local saved = MHMTO.settings.chars[activeCharID]
	activeChar.neverTrained = (saved and saved.neverTrained == true) or false

	MHMTO.window.showAlliance   = MHMTO.settings.showAlliance
	MHMTO.window.showStats      = MHMTO.settings.showStats
	MHMTO.window.showTrainable  = MHMTO.settings.showTrainable
	MHMTO.window.showMaxed      = MHMTO.settings.showMaxed
	MHMTO.window.showCharID     = MHMTO.settings.showCharID

	-- Ensure pointers exist (should be true in normal flow, but keeps it safe)
	if MHMTO.activeCharSettings and activeChar then
		-- Update active char runtime entry
		activeChar.ID = activeCharID
		activeChar.name = MHMTO.activeCharName
		activeChar.alliance = MHMTO.activeCharAlliance
		activeChar.horseMaxed = horseMaxed
		activeChar.horseSpeed = activeCharHorseSpeed
		activeChar.horseStamina = activeCharHorseStamina
		activeChar.horseInventory = activeCharHorseInventory
		activeChar.canTrain = canTrain
		activeChar.readytime = readyTimeSec
	end

	MHMTO.ApplyTitleLayout()
	MHMTO.ApplyColumnLayout()
	
	-- Set Title if checked
	if MHMTO.settings.showtitle then
		MHMTO.window.title.label:SetFont("EsoUi/Common/Fonts/Univers67.otf|"..MHMTO.window.fontSize.."|soft-shadow-thin")
		MHMTO.window.title.label:SetColor(MHMTO.settings.colors.titleR, MHMTO.settings.colors.titleG, MHMTO.settings.colors.titleB, MHMTO.settings.colors.titleA)
		MHMTO.window.title.label:SetStyleColor(0, 0, 0, 1)
		MHMTO.window.title.label:SetText(GetString(MHMTO_WINDOW_TITLE))
		MHMTO.window.icon1:SetColor(MHMTO.settings.colors.titleR, MHMTO.settings.colors.titleG, MHMTO.settings.colors.titleB, MHMTO.settings.colors.titleA)
		MHMTO.window.icon2:SetColor(MHMTO.settings.colors.titleR, MHMTO.settings.colors.titleG, MHMTO.settings.colors.titleB, MHMTO.settings.colors.titleA)
		MHMTO.window.icon1:SetDimensions(MHMTO.window.iconSize,MHMTO.window.iconSize)
		MHMTO.window.icon2:SetDimensions(MHMTO.window.iconSize,MHMTO.window.iconSize)
		MHMTO.window.title:SetHidden(not MHMTO.settings.showtitle)
		MHMTO.window.icon1:SetHidden(not MHMTO.settings.showtitle)
		MHMTO.window.icon2:SetHidden(not MHMTO.settings.showtitle)
	end

	MHMTO.window.bg:SetInsets(-MHMTO.settings.fontSize, -MHMTO.settings.fontSize*0.5, MHMTO.settings.fontSize, MHMTO.settings.fontSize)
	MHMTO.window:SetClampedToScreenInsets(-MHMTO.settings.fontSize, -MHMTO.settings.fontSize*0.5, MHMTO.settings.fontSize, MHMTO.settings.fontSize)

	-- Set Content of the rows
	for i = 1, charsCount do
		MHMTO.UpdateRow(i)
	end

	MHMTO.UpdateTimeTick()

	MHMTO.window:SetMovable(not MHMTO.settings.locked)

	MHMTO.window:SetHidden(ZO_CompassFrame:IsHidden() or not MHMTO.settings.shown)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
-- EOF ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->