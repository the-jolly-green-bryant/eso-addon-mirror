------------------------------------------------------------------
--TargetLookup.lua
--Author: mra4nii
--[[

Show target player's class icon(right side of health bar)
Show target player's alliance icon(left side of health bar)
Colour the target's level by its expected difficulty.
]]
------------------------------------------------------------------

TargetLookup = {}

TargetLookup.name = 'TargetLookup'
TargetLookup.version = '0.6.0'

local GetUnitLevel = GetUnitLevel
local GetUnitVeteranRank = GetUnitVeteranRank
local IsUnitVeteran = IsUnitVeteran
local DoesUnitExist = DoesUnitExist
local GetConColor = GetConColor
local IsUnitPlayer = IsUnitPlayer
local GetUnitClassId = GetUnitClassId

local classIcons = {
	[1] = [[/esoui/art/icons/class/class_dragonknight.dds]],
	[2] = [[/esoui/art/icons/class/class_sorcerer.dds]],
	[3] = [[/esoui/art/icons/class/class_nightblade.dds]],
	[4] = [[/esoui/art/icons/class/class_warden.dds]],
	[5] = [[/esoui/art/icons/class/class_necromancer.dds]],
	[6] = [[/esoui/art/icons/class/class_templar.dds]],
	[117] = [[/esoui/art/icons/class/class_arcanist.dds]],
	default = [[/esoui/art/icons/class/class_warden.dds]],
}

local allianceIcons = {
	[100] = [[/esoui/art/ava/ava_allianceflag_neutral.dds]],
	[1] = [[/esoui/art/guild/guildbanner_icon_aldmeri.dds]],
	[2] = [[/esoui/art/guild/guildbanner_icon_ebonheart.dds]],
	[3] = [[/esoui/art/guild/guildbanner_icon_daggerfall.dds]],
}

local playerLevel
local playerRank
local targetLevel


local function CreateClassIcon()
	if ( TargetLookup.ClassIcon ) then
		TargetLookup.ClassIcon:SetHidden(true)
		return
	end
	
	TargetLookup.ClassIcon = WINDOW_MANAGER:CreateControl("TargetLookup_ClassIcon", ZO_TargetUnitFramereticleover, CT_TEXTURE)
	TargetLookup.ClassIcon:SetDimensions(40,40)
	TargetLookup.ClassIcon:SetAnchor(RIGHT, ZO_TargetUnitFramereticleoverBgContainerBgRight, CENTER, 48, 5)
	TargetLookup.ClassIcon:SetHidden(true)
end

local function CreateAllianceIcon()
	if ( TargetLookup.AllianceIcon ) then
		TargetLookup.AllianceIcon:SetHidden(true)
		return
	end
	
	TargetLookup.AllianceIcon = WINDOW_MANAGER:CreateControl("TargetLookup_AllianceIcon", ZO_TargetUnitFramereticleover, CT_TEXTURE)
	TargetLookup.AllianceIcon:SetDimensions(32,32)
	TargetLookup.AllianceIcon:SetAnchor(LEFT, ZO_TargetUnitFramereticleoverBgContainerBgLeft, CENTER, -48, 5)
	TargetLookup.AllianceIcon:SetHidden(true)
end

-- what we should do when reticle is moved to another target
local function TargetChange()
	if ( not DoesUnitExist('reticleover') ) then
		TargetLookup.ClassIcon:SetHidden(true)
		TargetLookup.AllianceIcon:SetHidden(true)
		return
	end
	
	local cR, cG, cB = GetConColor( (GetUnitLevel('reticleover') + GetUnitVeteranRank('reticleover') ) + 10 * GetUnitDifficulty('reticleover'), playerLevel + playerRank)
	targetLevel:SetColor(cR, cG, cB)
--	d("Name: " .. GetUnitName('reticleover') .. " " .. "Class: " .. GetUnitClass('reticleover') .. " " .. "Level: " .. GetUnitLevel('reticleover') .. " " .. "Efective Level: " .. GetUnitEffectiveLevel('reticleover') .. " " .. "Type: " .. GetUnitType('reticleover') .. " " .. "Difficulty: " .. GetUnitDifficulty('reticleover'))
	
	if ( IsUnitPlayer('reticleover') ) then
		TargetLookup.AllianceIcon:SetTexture(allianceIcons[GetUnitAlliance('reticleover')])
		TargetLookup.AllianceIcon:SetHidden(false)
		TargetLookup.ClassIcon:SetTexture(classIcons[GetUnitClassId('reticleover')])
		TargetLookup.ClassIcon:SetHidden(false)
	else
		TargetLookup.AllianceIcon:SetHidden(true)
		TargetLookup.ClassIcon:SetHidden(true)
	end

end

-- update information on levelup
local function LevelUp(code, unitTag, level)
	if ( unitTag == 'player' ) then
		if ( IsUnitVeteran(unitTag) ) then
			playerRank = level
		else
			playerLevel = level
		end
	end
end

-- get info we need for next steps, create controls for icons
local function TargetLookup_Intro(eventCode, addOnName)

	playerLevel = GetUnitLevel('player')
	playerRank = IsUnitVeteran('player') and GetUnitVeteranRank('player') or 0
	targetLevel = ZO_TargetUnitFramereticleoverLevel
	
	CreateAllianceIcon()
	CreateClassIcon()
	
	EVENT_MANAGER:UnregisterForEvent("TargetLookup", EVENT_PLAYER_ACTIVATED)	
end

-- register for necessary in-game events
local function TargetLookup_Loaded(eventCode, addOnName)
	if ( addOnName ~= TargetLookup.name ) then
        return
    end

	EVENT_MANAGER:RegisterForEvent('TargetLookup', EVENT_RETICLE_TARGET_CHANGED, TargetChange)
	EVENT_MANAGER:RegisterForEvent('TargetLookup', EVENT_MOUSEOVER_CHANGED, TargetChange)
	EVENT_MANAGER:RegisterForEvent('TargetLookup', EVENT_DISPOSITION_UPDATE, TargetChange)
	EVENT_MANAGER:RegisterForEvent('TargetLookup', EVENT_LEVEL_UPDATE, LevelUp)
	EVENT_MANAGER:RegisterForEvent('TargetLookup', EVENT_VETERAN_RANK_UPDATE, LevelUp)
	
	EVENT_MANAGER:UnregisterForEvent("TargetLookup", EVENT_ADD_ON_LOADED)
end

-- initialize add-on
local function TargetLookup_Initialized()
	EVENT_MANAGER:RegisterForEvent("TargetLookup", EVENT_ADD_ON_LOADED, TargetLookup_Loaded)
	EVENT_MANAGER:RegisterForEvent("TargetLookup", EVENT_PLAYER_ACTIVATED, TargetLookup_Intro)
end

TargetLookup_Initialized()