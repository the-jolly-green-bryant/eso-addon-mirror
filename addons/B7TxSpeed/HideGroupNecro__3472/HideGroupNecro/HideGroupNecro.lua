-- Global definitions
HideGroupNecro = HideGroupNecro or {
	name = "HideGroupNecro",
	label = "HideGroup|c5050ffNecro|r",
	author = "|c00fffe@B7TxSpeed|r",
	version = "1.5.1",
}
local HG = HideGroupNecro
local EM = EVENT_MANAGER
local SM = SCENE_MANAGER

-- Utility variables
local groupIsHidden = false

-- Necro specific ids
local GRAVE_LORD_SKILL_LINE_ID = 131
local LIVING_DEATH_SKILL_LINE_ID = 133

local siphonSkillIds = {
	115924, -- Shocking Siphon
	118008, -- Mystic Siphon
	118763, -- Detonating Siphon
}

local tetherSkillIds = {
	115926, -- Restoring Tether
	118070, -- Braided Tether
	118122, -- Mortal Coil
}

--- Debug function
local function debugMessage(message)
	if HG.savedVariables.Debug then
		d("HideGroupNecro: "..message)
	end
end

-- Subclassing filter
local function IsSkillLineActive(skillLineId)
	local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataById(skillLineId)
	return skillLineData and skillLineData:IsActive()
end


-- Skill filter
local function IsAtLeastOneSkillSlotted(skillIds)
	for i = 3, 7 do
		local slot1 = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY) -- Frontbar skill
		local slot2 = GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP) -- Backbar skill
		for _, skillId in ipairs(skillIds) do
			if skillId == slot1 or skillId == slot2 then
				debugMessage("Necro skill found with id: " .. skillId)
				return true
			end
		end
	end
	return false
end


local function isNecro()
	return IsSkillLineActive(GRAVE_LORD_SKILL_LINE_ID) and IsAtLeastOneSkillSlotted(siphonSkillIds)
	or IsSkillLineActive(LIVING_DEATH_SKILL_LINE_ID) and IsAtLeastOneSkillSlotted (tetherSkillIds)
end

-- Picked from SpeedRun
local function ForceGroupVisible()
	if not IsPlayerActivated() then return end
	local scene = SM.currentScene:GetName()
	if scene == "stats" then return end
	SM:Show("stats")
	zo_callLater(function()
	  SetCrownCrateNPCVisible(false)
	  if scene == "hudui" then SM:Show("hud")
	  else
		if scene ~= "" then SM:Show(scene) end
	  end
	end, 20)
  end

  local function IsPCUI()
	return not IsConsoleUI()
  end

--- Picked from Wheels HideGroup 2.1
function HG.hideMembers(enable)
	if enable then
		debugMessage("HideGroup")
		SetCrownCrateNPCVisible(true)
		groupIsHidden = true
		if HG.savedVariables.HideState ~= enable then
			d("HideGroupNecro: Hiding group members")
			HG.savedVariables.GroupMemberNameplates = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES)
			HG.savedVariables.GroupMemberHealthBars = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS)
		end
		if IsPCUI() then
			SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, tostring(HG.savedVariables.NameplateMode))
			SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS, tostring(HG.savedVariables.HealthBarMode))
		end
	else
		debugMessage("ShowGroup")
		ForceGroupVisible()
		groupIsHidden = false
		if HG.savedVariables.HideState ~= enable then
			d("HideGroupNecro: Showing group members")
			if IsPCUI() then
				SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, tostring(HG.savedVariables.GroupMemberNameplates))
				SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS, tostring(HG.savedVariables.GroupMemberHealthBars))
			end
		end
	end
	HG.savedVariables.HideState = enable
end

local function playerActivatedHandler()
	if HG.savedVariables.HideState and not IsUnitInCombat("player") then
		HG.hideMembers(HG.savedVariables.HideState)
	end
end

local function playerCombatStateHandler(_, inCombat)
	-- Player's combat state has changed
	if inCombat and HG.savedVariables.HideState and groupIsHidden and isNecro() then
		debugMessage("ShowGroup for necro")
		SetCrownCrateNPCVisible(false)
		groupIsHidden = false
	end
end

function HG.switchCommand(arg)
	if arg == "true" or arg == "1" then
		HG.hideMembers(true)
	elseif arg == "false" or arg == "0" then
		HG.hideMembers(false)
	elseif arg == nil or arg == "" then
		HG.hideMembers(not HG.savedVariables.HideState)
	else
		HG.hideMembers(false)
	end
end

function HG.toggleHide()
	HG.hideMembers(not HG.savedVariables.HideState)
end

function HG.init(event, addon)
	if addon ~= HG.name then return end
	
	EM:UnregisterForEvent(HG.name.."Init", EVENT_ADD_ON_LOADED)
	HG.defaults = {
		["GroupMemberNameplates"] = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES),
		["GroupMemberHealthBars"] = GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS),
		["NameplateMode"] = NAMEPLATE_CHOICE_NEVER,
		["HealthBarMode"] = NAMEPLATE_CHOICE_NEVER,
		["HideState"] = false,
		["Debug"] = false,
	}
	HG.savedVariables = ZO_SavedVars:New("HideGroupNecroSavedVars", 1, nil, HG.defaults, GetWorldName())

	if IsPCUI() then
		ZO_CreateStringId('SI_BINDING_NAME_HIDEGROUPNECRO_TOGGLE', 'Show/Hide Group Members')
	end

	SLASH_COMMANDS["/hidegroup"] = HG.switchCommand

	EM:RegisterForEvent(HG.name.."PlayerActivated", EVENT_PLAYER_ACTIVATED, playerActivatedHandler)
	EM:RegisterForEvent(HG.name.."PlayerCombatState", EVENT_PLAYER_COMBAT_STATE, playerCombatStateHandler)

	-- Load Menu
	HG.loadMenu()
end

EM:RegisterForEvent(HG.name.."Init", EVENT_ADD_ON_LOADED, HG.init)
