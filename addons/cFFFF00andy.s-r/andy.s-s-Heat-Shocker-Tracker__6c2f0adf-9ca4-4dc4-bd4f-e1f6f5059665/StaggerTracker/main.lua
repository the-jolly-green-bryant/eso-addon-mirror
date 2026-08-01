local StaggerTracker = {
	name = "StaggerTracker",
	version = "1.4",
	author = "andy.s",
	varVersion = 1, -- savedVariables version
	uiLocked = true,
	defaultSettings = {
		pos = {
			center = 0,
			mid = 0,
		},
		snap = 20,
	},
}

local LCA = LibCombatAlerts

local SLOT_ID = 31816 -- Stone Giant button id
local SLOT_ID_PROJ = 133027 -- Stone Giant projectile button id
local ABILITY_ID = 134340 -- Stagger effect id
local STATES = {
	[0] = {1,  0, 0},
	[1] = {1, .5, 0},
	[2] = {1, .8, 0},
	[3] = {0,  1, 0},
}

local ST = StaggerTracker
local NAME = ST.name
local EM = EVENT_MANAGER
local SV

local inCombat = false

local stFragment
local stActive = false -- currently tracking Stagger (player is DK, Stone Giant is slotted)
local stEnd = 0 -- when stagger effect ends (game seconds)
local stStacks = 0  -- current number of stacks
local targetStacks = 0 -- targeted unit stacks

-- Get targeted unit stacks.
local function GetTargetStacks()
	if inCombat and DoesUnitExist("reticleover") and not IsUnitPlayer("reticleover") then
		for i = 1, GetNumBuffs("reticleover") do
			local _, _, timeEnding, _, stackCount, _, _, _, _, _, abilityId, _, castByPlayer = GetUnitBuffInfo("reticleover", i)
			if castByPlayer and abilityId == ABILITY_ID then
				return stackCount
			end
		end
	end
	return 0
end

local function Initialize()
	SV = ZO_SavedVars:New("StaggerTrackerSV", ST.varVersion, nil, ST.defaultSettings)

	-- ST.RestorePosition()
	-- ST.AddonMenu()

	-- This part of the code is based on the MoveableControlDemo example
	-- Create UI fragment.
	stFragment = ZO_SimpleSceneFragment:New(StaggerTrackerControl)
	stFragment:SetConditional(function() return stActive and inCombat or not ST.uiLocked end)
	HUD_SCENE:AddFragment(stFragment)
	HUD_UI_SCENE:AddFragment(stFragment)

	-- Put something into the window that we can see
	StaggerTrackerControl_Icon:SetTexture(GetAbilityIcon(ABILITY_ID))
	local texture = WINDOW_MANAGER:CreateControl(StaggerTracker.name, StaggerTrackerControl, CT_TEXTURE)

	-- Create and attach MoveableControl handler
	local handler = LCA.MoveableControl:New(StaggerTrackerControl)
	StaggerTracker.positionHandler = handler

	-- Load position from saved variables
	handler:UpdatePosition(SV.pos)

	-- Set position snap
	handler:SetSnap(SV.snap)

	-- Listen for and save position changes
	handler:RegisterCallback(StaggerTracker.name, LCA.EVENT_CONTROL_MOVE_STOP, function(newPos)
		SV.pos = newPos
		-- d("Movement stopped; new position is:")
		-- d(newPos)
	end)

	-- Update stagger duration.
	local function UpdateDuration()
		local duration = stEnd - GetGameTimeSeconds()
		if duration > 0 then
			StaggerTrackerControl_Duration:SetText(zo_ceil(duration))
			targetStacks = GetTargetStacks()
			if targetStacks > 0 then
				stStacks = targetStacks
			end
		else
			StaggerTrackerControl_Duration:SetText(0)
			stStacks = 0
		end
	end

	-- Update UI control texts and colors.
	local function UpdateControl()
		UpdateDuration()
		local r, g, b = unpack(STATES[stStacks])
		StaggerTrackerControl_BG:SetColor(r, g, b)
		StaggerTrackerControl_Stacks:SetText(stStacks)
		stFragment:Refresh()
	end

	-- Combat state changes.
	local function OnCombatStateChange()
		inCombat = IsUnitInCombat("player")
		EM:UnregisterForUpdate(NAME .. 'Update')
		if inCombat and stActive then
			EM:RegisterForUpdate(NAME .. 'Update', 200, function() UpdateDuration() end)
		end
		stFragment:Refresh()
	end

	-- Check if Stone Giant is slotted.
	local function OnPlayerActivated()
		stActive = false
		for i = 3, 7 do
			local slot1 = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY)
			local slot2 = GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP)
			if SLOT_ID == slot1 or SLOT_ID == slot2 or SLOT_ID_PROJ == slot1 or SLOT_ID_PROJ == slot2 then
				stActive = true
				break
			end
		end
		OnCombatStateChange()
	end

	-- Stagger stacks changed.
	local function OnStackChanged(_, changeType, _, _, _, _, endTime, stackCount, _, _, _, _, _, _, unitId, abilityId)
		if changeType ~= EFFECT_RESULT_FADED then -- ignore faded event, because it can happen on an add from aoe cast
			stEnd = endTime
			targetStacks = GetTargetStacks()
			stStacks = targetStacks > 0 and targetStacks or stackCount
		end
		UpdateControl()
	end

	-- Initial cast / projectile.
	local function OnSlotUpdated(_, n)
		local id = GetSlotBoundId(n)
		if id == SLOT_ID then
			StaggerTrackerControl_Icon:SetDesaturation(1)
		elseif id == SLOT_ID_PROJ then
			StaggerTrackerControl_Icon:SetDesaturation(0)
		end
	end

	EM:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	EM:RegisterForEvent(NAME, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChange)
	EM:RegisterForEvent(NAME, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnPlayerActivated)
	EM:RegisterForEvent(NAME, EVENT_ACTION_SLOT_UPDATED, OnSlotUpdated)
	EM:RegisterForEvent(NAME, EVENT_RETICLE_TARGET_CHANGED, UpdateControl)

	EM:RegisterForEvent(NAME, EVENT_EFFECT_CHANGED, OnStackChanged)
	EM:AddFilterForEvent(NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITY_ID)
	EM:AddFilterForEvent(NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

end

-- function ST.Move()
-- 	SV.controlCenterX, SV.controlCenterY = StaggerTrackerControl:GetCenter()

-- 	StaggerTrackerControl:ClearAnchors()
-- 	StaggerTrackerControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)

-- end

-- function ST.RestorePosition()
-- 	local controlCenterX = SV.pos.center
-- 	local controlCenterY = SV.pos.mid

-- 	if controlCenterX or controlCenterY then
-- 		handler:UpdatePosition(MoveableControlDemo.vars.pos)
-- 	end

-- 	StaggerTrackerControl_Icon:SetTexture(GetAbilityIcon(ABILITY_ID))

-- end

-- function ST.AddonMenu()
--     LAM = LibAddonMenu2
--     if LAM then
--         local menuOptions
--         if IsConsoleUI() then
--             menuOptions = {
--                 type = "panel",
--                 name = "andy.s's Stagger Tracker",
--                 displayName = "andy.s's Sul-Xan Soul Catcher",
--                 author = ST.author,
--                 version = ST.version,
--                 registerForRefresh = true
--             }
--         else
--             menuOptions = {
--                 type = "panel",
--                 name = "Stagger Tracker",
--                 displayName = "Stagger Tracker",
--                 author = ST.author,
--                 version = ST.version,
--                 registerForRefresh = true
--             }
--         end
    
--         local dataTable = {
--             {
--                 type = "button",
--                 name = GetString(SI_INTERFACE_OPTIONS_FRAMERATE_LATENCY_POSITION_RESET),
--                 func = function()
--                     SV.controlCenterX = 0
--                     SV.controlCenterY = 0
--                     StaggerTrackerControl:ClearAnchors()
--                     StaggerTrackerControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)
--                 end
--             },
--             {
--                 type = "slider",
--                 name = GetString(SI_INTERFACE_OPTIONS_CAMERA_THIRD_PERSON_HORIZONTAL_OFFSET),
--                 min = 0,
--                 max = 4000,
--                 step = 20,
--                 getFunc = function()
--                     return SV.controlCenterX
--                 end,
--                 setFunc = function(value)
--                     SV.controlCenterX = value
--                     StaggerTrackerControl:ClearAnchors()
--                     StaggerTrackerControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)
--                 end,
--                 default = 0
--             },
--             {
--                 type = "slider",
--                 name = GetString(SI_INTERFACE_OPTIONS_CAMERA_THIRD_PERSON_VERTICAL_OFFSET),
--                 min = 0,
--                 max = 3000,
--                 step = 20,
--                 getFunc = function()
--                     return SV.controlCenterY
--                 end,
--                 setFunc = function(value)
--                     SV.controlCenterY = value
--                     StaggerTrackerControl:ClearAnchors()
--                     StaggerTrackerControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)
--                 end,
--                 default = 0
--             },
--         }
--         local settingPanel = LAM:RegisterAddonPanel(ST.name .. "Options", menuOptions)
--         LAM:RegisterOptionControls(ST.name .. "Options", dataTable)

--         CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
--             if panel ~= settingPanel then
--                 return
--             end
--             StaggerTrackerControl:SetHidden(false)
--         end)
    
--         CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
--             if panel ~= settingPanel then
--                 return
--             end
--             StaggerTrackerControl:SetHiddenu(true)
-- 			stFragment:SetConditional(function() return stActive and inCombat or not ST.uiLocked end)
--             stFragment:Refresh()
--         end)
--     end
-- end

local function OnAddOnLoaded(event, addonName)
	if addonName == NAME then
		EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
		Initialize()
	end
end

EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

SLASH_COMMANDS["/staggertracker"] = function(str)
	ST.uiLocked = not ST.uiLocked
	stFragment:Refresh()
end