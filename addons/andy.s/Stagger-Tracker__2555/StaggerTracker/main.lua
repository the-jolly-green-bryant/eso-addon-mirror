StaggerTracker = {
	name = "StaggerTracker",
	version = "0.3",

	varVersion = 1, -- savedVariables version
	uiLocked = true,
	defaultSettings = {
	},
}

local SLOT_ID = 31816 -- Stone Giant button id
local SLOT_ID_PROJ = 133027 -- Stone Giant projectile button id
local ABILITY_ID = 134336 -- Stagger effect id
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

	ST.RestorePosition()

	-- Create UI fragment.
	stFragment = ZO_SimpleSceneFragment:New(StaggerTrackerControl)
	stFragment:SetConditional(function() return stActive and inCombat or not ST.uiLocked end)
	HUD_SCENE:AddFragment(stFragment)
	HUD_UI_SCENE:AddFragment(stFragment)

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
	local function CombatState()
		inCombat = IsUnitInCombat("player")
		EM:UnregisterForUpdate(NAME .. 'Update')
		if inCombat and stActive then
			EM:RegisterForUpdate(NAME .. 'Update', 200, function() UpdateDuration() end)
		end
		stFragment:Refresh()
	end

	-- Check if Stone Giant is slotted.
	local function SkillCheck()
		stActive = false
		for i = 3, 7 do
			local slot1 = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY)
			local slot2 = GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP)
			if SLOT_ID == slot1 or SLOT_ID == slot2 or SLOT_ID_PROJ == slot1 or SLOT_ID_PROJ == slot2 then
				stActive = true
				break
			end
		end
		CombatState()
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

	if GetUnitClassId('player') == 1 then -- register events only for dragonknights
		EM:RegisterForEvent(NAME, EVENT_PLAYER_ACTIVATED, SkillCheck)
		EM:RegisterForEvent(NAME, EVENT_PLAYER_COMBAT_STATE, CombatState)
		EM:RegisterForEvent(NAME, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, SkillCheck)
		EM:RegisterForEvent(NAME, EVENT_ACTION_SLOT_UPDATED, OnSlotUpdated)
		EM:RegisterForEvent(NAME, EVENT_RETICLE_TARGET_CHANGED, UpdateControl)

		EM:RegisterForEvent(NAME, EVENT_EFFECT_CHANGED, OnStackChanged)
		EM:AddFilterForEvent(NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, ABILITY_ID)
		EM:AddFilterForEvent(NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	end

end

function ST.Move()

	SV.controlCenterX, SV.controlCenterY = StaggerTrackerControl:GetCenter()

	StaggerTrackerControl:ClearAnchors()
	StaggerTrackerControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, SV.controlCenterX, SV.controlCenterY)

end

function ST.RestorePosition()

	local controlCenterX = SV.controlCenterX
	local controlCenterY = SV.controlCenterY

	if controlCenterX or controlCenterY then
		StaggerTrackerControl:ClearAnchors()
		StaggerTrackerControl:SetAnchor(CENTER, GuiRoot, TOPLEFT, controlCenterX, controlCenterY)
	end

	StaggerTrackerControl_Icon:SetTexture(GetAbilityIcon(ABILITY_ID))

end

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