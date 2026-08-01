-- SorcererHelper
-- Reminds you to summon your minion and alerts you when Crystal Fragments procs and a number of other timed effects.
-- Patched by: Vahrokh Vain, compatible with APIversion 100030
-- Author: RunningDuck, adaptation to LibAddonMenu 2.0 r16 and APIversion 100010 (patch 1.5) and later, plus substantial additions
-- Original author: stjobe
-- LibAddonMenu courtesy of Seerah: http://www.esoui.com/downloads/info7-LibAddonMenu.html
-- Animation tips from acies and Garkin
-- Many thanks to Garkin the guru and the rest of the ESOUI community for their (knowing or unknowing) help.

local DebugMe = 0 -- Debug level, set to 0 to disable entirely
-- DebugMe == 1 detects Crystal Fragment Procs
-- DebugMe == 2 detects Lightning Splash
-- DebugMe == 3 writes all skills and morphs, current slotted skills and when their button is pressed

local SH = {}
SH.name = "SorcererHelper"
SH.displayVersion = "3.2.1"
SH.saveVersion = "251"

-- Index of the abilities in various arrays
-- Note that it must; (1) be consecutive (2) start with abFirst and (3) end with abLast
local abFirst = 1
local Sum1  = abFirst
local Sum2  = 2
local ML    = 3
local BA    = 4
local CF    = 5
local Surge = 6
local LF    = 7
local EH    = 8
local Curse = 9
local Ward  = 10
local Bolt  = 11
local Fury	= 12
local Rune	= 13
local Priso	= 14
local Entro	= 15
local Weak	= 16
local Trap	= 17
local Heal	= 18
local LS	= 19
local Uneg	= 20
local Uatro	= 21
local Annul	= 22
local Deto  = 23
local Wall  = 24
local abLast = Wall

-- Index in the ability array SH.AB, note don't change unless changing in the array...
local abType		= 1  -- [is ability a 0=buff, 1=proc, 2=alert]
local abDuration 	= 2  -- [of ability]
local abMorphed 	= 3  -- [is this ability and it changes the duration]
local abMorphDura 	= 4  -- [new duration due to morph]
local abSkillClass	= 5  -- [SKILL_TYPE_CLASS or SKILL_TYPE_GUILD or SKILL_TYPE_WORLD or SKILL_TYPE_WEAPON or SKILL_TYPE_ARMOR]
local abSkillType	= 6  -- [Index under each Skill Class, see left-hand menu in skill window in the game (k-key)]
local abSkillIndex	= 7  -- [1-6, see right-hand list for each type in skill window in the game (k-key)]
local abSettingTxt	= 8  -- [title text in settings menu]
local abSettingHelp	= 9  -- [mouseover text explaining the setting]
local abCost		= 10 -- [for use of this ability]
local abSlot 		= 11 -- [used for this ability]
local abProc 		= 12 -- [this ability activated; as a buff, via direct key, or as secondary proc]
local abTimer 		= 13 -- [to time we should count until it fades]
local abName		= 14 -- [of ability]
local abIcon		= 15 -- [image for ability]
local abWin			= 16 -- [top level window]
local abWBD			= 17 -- [back drop window]
local abWIcon 		= 18 -- [icon window for ability]
local abWTxt 		= 19 -- [text window over icon]
local abRank		= 20 -- [of ability]
local abButtonPress	= 21 -- [use to detect when a ground target is hit]
local abAPIdura		= 22 -- [Duration from API]

SH.AB = {
-- [ab]  = {Type,	Dura,	Morph,	MDura,	Class,				Type,	Index,
--			Setting title,				Help txt,
--			Cost,	Slot,	Proc,	Timer,	Name,	Icon,	Window handles,	Rank,	BPress, APIdura}
-- Buffs
[Sum1]   = {0,		0,		false,	0,		SKILL_TYPE_CLASS,	2,		2,
		 	"Unstable Familiar", 	"Sorc: Remind if Unstable Familiar or morph (Unstable Clannfear or Volatile Familiar) is not summoned",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Sum2]   = {0,		0,		false,	0,		SKILL_TYPE_CLASS,	2,		4,
			"Winged Twilight", 		"Sorc: Remind if Winged Twilight or morph (Restoring Twilight or Twilight Matriarch) is not summoned",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[ML]  	 = {0,		0,		false,	0,		SKILL_TYPE_GUILD,	2,		2,
			"Magelight", 			"Remind if Magelight or morph (Inner Light or Radiant Magelight) is not summoned",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_},
[BA]     = {0,		0,		false,	0,		SKILL_TYPE_CLASS,	2,		6,
			"Bound Armor", 			"Sorc: Remind if Bound Armor or morph (Bound Armaments or Bound Aegis) is not summoned",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
-- Procs
[CF]     = {1,		8,		false,	0,		SKILL_TYPE_CLASS,	1,		2,
			"Crystal Fragment", 	"Sorc: Alert when Crystal Fragment (a morph of Crystal Shard) procs and start countdown",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
-- Alerts			
[Surge]  = {2,		33,		false,	0,		SKILL_TYPE_CLASS,	3,		5,
			"Surge", 				"Sorc: Countdown when Surge or morph (Power Surge or Critical Surge) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[LF]     = {2,		20,		false,	23,		SKILL_TYPE_CLASS,	3,		3,
			"Lightning Form", 		"Sorc: Countdown when Lightning Form or morph (Hurricane or Boundless Storm) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[EH]     = {2,		5,		false,	0,		SKILL_TYPE_GUILD,	1,		4,
			"Expert Hunter", 		"Countdown when Expert Hunter or morph (Evil Hunter or Camouflaged Hunter) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Curse]  = {2,		6,		false,	8,		SKILL_TYPE_CLASS,	2,		3,
			"Daedric Curse", 		"Sorc: Countdown when Daedric Curse or morph (Daedric Prey or Haunting Curse) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Ward]   = {2,		6,		false,	0,		SKILL_TYPE_CLASS,	2,		5,
			"Conjured Ward", 		"Sorc: Countdown when Conjured Ward or morph (Empowered Ward or Hardened Ward) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Bolt]   = {2,		4,		false,	0,		SKILL_TYPE_CLASS,	3,		6,
			"Bolt Escape", 			"Sorc: Countdown when Bolt Escape or morph (Ball of Lightning or Streak) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Fury]   = {2,		4,		false,	0,		SKILL_TYPE_CLASS,	3,		2,
			"Mages' Fury", 			"Sorc: Countdown when Mages' Fury or morph (Endless Fury or Mages' Wrath) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Rune]   = {2,		16,		false,	0,		SKILL_TYPE_CLASS,	1,		4,
			"Rune Prison", 			"Sorc: Countdown when Rune Prison or morph (Defensive Rune or Rune Cage) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Priso]  = {2,		4,		false,	0,		SKILL_TYPE_CLASS,	1,		3,
			"Encase", 				"Sorc: Countdown when Encase or morph (Restraining Prison or Shattering Prison) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Entro]  = {2,		12,		false,	0,		SKILL_TYPE_GUILD,	2,		3,
			"Entropy", 				"Countdown when Entropy or morph (Degeneration or Structured Entropy) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Weak]   = {2,		21,		false,	24,		SKILL_TYPE_WEAPON,	5,		5,
			"Weakness to Elements", "Countdown when Weakness to Elements or morph (Elemental Drain or Elemental Susceptibility) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Trap]   = {2,		10,		false,	0,		SKILL_TYPE_WORLD,	2,		2,
			"Soul Trap", 			"Countdown when Soul Trap or morph (Consuming Trap or Soul Splitting Trap) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Heal]   = {2,		6,		false,	0,		SKILL_TYPE_WEAPON,	6,		5,
			"Steadfast Ward", 		"Countdown when Steadfast Ward or morph (Healing Ward or Ward Ally) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[LS] 	 = {2,		10,		false,	10,		SKILL_TYPE_CLASS,	3,		4,
			"Lightning Splash", 	"Sorc: Countdown when Lightning Splash or morph (Lightning Flood or Liquid Lightning) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Uneg] 	 = {2,		10,		false,	0,		SKILL_TYPE_CLASS,	1,		1,
			"Negate Magic", 		"Countdown when Ultimate Negate Magic or morph (Absorption Field or Suppression Field) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Uatro]  = {2,		15,		false,	28,		SKILL_TYPE_CLASS,	2,		1,
			"Summon Storm Atronach","Sorc: Countdown when Ultimate Summon Storm Atronach or morph (Greater Storm Atronach or Summon Charged Atronach) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Annul]  = {2,		6,		false,	0,		SKILL_TYPE_ARMOR,	1,		1,
			"Annulment", 			"Countdown when Ultimate Annulment or morph (Dampen Magic or Harness Magicka) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Deto]   = {2,		4,		false,	8,		SKILL_TYPE_AVA, 	1,		5,
			"Magicka Detonation", 	"Countdown when Magicka Detonation or morph (Inevitable Detonation or Proximity Detonation) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
[Wall]   = {2,		10,		false,	8,		SKILL_TYPE_WEAPON, 	5,		3,
			"Wall of Elements", 	"Countdown when Wall of Elements or morph (Unstable Wall or Elemental Blockade) expires",
			0,		0,		false,	0,		"",		_,		_,	_,	_,	_, 	0, 		false,	0},
}

SH.Defaults = {
	NonSorc = false,
	BBx = 400,
	BBy = 43,
	buffScale = 1,
	ABx = 402,
	ABy = 80,
	alertScale = 2,
	SBx = 500,
	SBy = 820,
	skillScale = 2,
	ShowSkillbar = false,	
	LockMove = true,
	ShowMove = false,
	HideInMenus = false,
	saveMode = false, -- false = use account wide, i.e. same settings for all chars

	Show = {
		[Sum1] 	= true,
		[Sum2] 	= true,
		[ML] 	= true,
		[BA] 	= true,
		[CF] 	= true,
		[Surge] = true,
		[LF] 	= true,
		[EH] 	= true,
		[Curse] = true,
		[Ward] 	= true,
		[Bolt]	= true,
		[Fury]	= true,
		[Rune]	= true,
		[Priso]	= true,
		[Entro]	= true,
		[Weak]	= true,
		[Trap]	= true,
		[Heal]	= true,
		[LS]	= true,
		[Uneg]	= true,
		[Uatro]	= true,
		[Annul]	= true,
		[Deto]	= true,		
		[Wall]	= true,
		}
}
SH.SV = {}
SH.alwaysAccountWide = SH.Defaults
SH.SV = SH.Defaults

SH.BuffBar = 0
SH.AlertBar = 0
SH.SkillBar = 5

SH.ScanKeys = false
SH.CustomEasing = ZO_GenerateCubicBezierEase(.05, 1.85, .75, .75)

SH.ClassId = 2 -- 2 = Sorcerer

local panelData = {
	type = "panel",
    name = "Sorcerer Helper",
	author = "RunningDuck",
    version = SH.displayVersion,
	website = "http://www.esoui.com/downloads/info853-SorcererHelper.html",
}
-----------------------------------------------------

-----------------------------------------------------
-- User interface

-- Get name and icons for the skills
function SH.GetAbilities()

	if DebugMe == 300 then
		local skillClass, skillType, skillIndex
		for skillClass = 1, GetNumSkillTypes() do
			for skillType = 1, GetNumSkillLines(skillClass) do
				for skillIndex = 1, GetNumSkillAbilities(skillClass, skillType) do
					local abilityID = GetSkillAbilityId(skillClass, skillType, skillIndex)
					local name, _, _, _, _, _, _ =  GetSkillAbilityInfo(skillClass, skillType, skillIndex)
					d(name.." [ID:Type/Line/Index]="..abilityID..":"..skillClass.."/"..skillType.."/"..skillIndex.." Dura"..GetAbilityDuration(abilityID)/1000)
				end
			end
		end
	end 

	for ability = abFirst, abLast do
		SH.AB[ability][abName], SH.AB[ability][abIcon], SH.AB[ability][abRank], _, _, _, _ =  GetSkillAbilityInfo(SH.AB[ability][abSkillClass], SH.AB[ability][abSkillType], SH.AB[ability][abSkillIndex])
		if DebugMe == 3 then d(ability.."="..SH.AB[ability][abName].." ("..SH.AB[ability][abSettingTxt]..")") end
	end
	
	
	-- Handle where morphs change ability from a time perspective
	-- Lightning Form
	local progressionIndex
	local ability
	
	-- Daedric Curse
	ability = Curse
	SH.AB[ability][abMorphed] = false
	_, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(SH.AB[ability][abSkillClass], SH.AB[ability][abSkillType], SH.AB[ability][abSkillIndex])
	if progressionIndex then
		if SH.AB[ability][abName] == GetAbilityProgressionAbilityInfo(progressionIndex, 2, 1) then
			SH.AB[ability][abMorphed] = true -- Morphed to Haunting Curse 
			if DebugMe == 3 then d(ability.."="..SH.AB[ability][abName].." detected morphed") end
		end
	end
	-- Lightning Splash
	ability = LS
	SH.AB[ability][abMorphed] = false
	_, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(SH.AB[ability][abSkillClass], SH.AB[ability][abSkillType], SH.AB[ability][abSkillIndex])
	if progressionIndex then
		if SH.AB[ability][abName] == GetAbilityProgressionAbilityInfo(progressionIndex, 1, 1) then
			SH.AB[ability][abMorphed] = true -- Morphed to Liquid Lightning 
			if DebugMe == 3 then d(ability.."="..SH.AB[ability][abName].." detected morphed") end
		end
	end
	-- Summon Storm Atronach
	ability = Uatro
	SH.AB[ability][abMorphed] = false
	_, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(SH.AB[ability][abSkillClass], SH.AB[ability][abSkillType], SH.AB[ability][abSkillIndex])
	if progressionIndex then
		if SH.AB[ability][abName] == GetAbilityProgressionAbilityInfo(progressionIndex, 1, 1) then
			SH.AB[ability][abMorphed] = true -- Morphed to Greater Storm Atronach 
			if DebugMe == 3 then d(ability.."="..SH.AB[ability][abName].." detected morphed") end
		end
	end
	-- Magicka Detonation
	ability = Deto
	SH.AB[ability][abMorphed] = false
	_, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(SH.AB[ability][abSkillClass], SH.AB[ability][abSkillType], SH.AB[ability][abSkillIndex])
	if progressionIndex then
		if SH.AB[ability][abName] == GetAbilityProgressionAbilityInfo(progressionIndex, 2, 1) then
			SH.AB[ability][abMorphed] = true -- Morphed to Proximity Detonation 
			if DebugMe == 3 then d(ability.."="..SH.AB[ability][abName].." detected morphed") end
		end
	end
	-- Wall of Elements
	ability = Wall
	SH.AB[ability][abMorphed] = false
	_, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(SH.AB[ability][abSkillClass], SH.AB[ability][abSkillType], SH.AB[ability][abSkillIndex])
	if progressionIndex then
		if SH.AB[ability][abName] == GetAbilityProgressionAbilityInfo(progressionIndex, 2, 1) then
			SH.AB[ability][abMorphed] = true -- Morphed to Elemental Blockade 
			if DebugMe == 3 then d(ability.."="..SH.AB[ability][abName].." detected morphed") end
		end
	end
	-- Weakness to Elements
	ability = Weak
	SH.AB[ability][abMorphed] = false
	_, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(SH.AB[ability][abSkillClass], SH.AB[ability][abSkillType], SH.AB[ability][abSkillIndex])
	if progressionIndex then
		if SH.AB[ability][abName] == GetAbilityProgressionAbilityInfo(progressionIndex, 1, 1) then
			SH.AB[ability][abMorphed] = true -- Morphed to Elemental susceptability 
			if DebugMe == 3 then d(ability.."="..SH.AB[ability][abName].." detected morphed") end
		end
	end
end

-- Event handler for EVENT_ACTIVE_WEAPON_PAIR_CHANGED and indirectly for EVENT_ACTION_SLOT_ABILITY_SLOTTED
-- Find what is slotted in the buttons if the settings say we should watch this 
function SH.GetSlotted()
	SH.ScanKeys = false
	
	-- Clear out old slot values
	for ability = abFirst, abLast do
		SH.AB[ability][abSlot] = 0
	end
	
	-- Find what is slotted now
	for slot = 3, 8 do -- keys 1-5 + R (ultimate), slot 3 = key 1
	    local name = GetSlotName(slot)
		local slotname, abilityname, tempname
		if DebugMe == 3 then d(name.." is in slot "..slot) end
		for ability = abFirst, abLast do
			if SH.SV.Show[ability] then
				if ability == Wall or ability == Weak then
					local abilityId = GetSlotBoundId(slot)
					local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
					local unMorphedName, morphChoice, rank = GetAbilityProgressionInfo(progressionIndex)
					local morphedName, texture, abilityIndex = GetAbilityProgressionAbilityInfo(progressionIndex, morphChoice, rank)
					if morphChoice > 0 then slotname =  morphedName else slotname = unMorphedName end
					if DebugMe == 3 then d("abilityId="..abilityId..", progressionIndex="..progressionIndex..", unMorphedName="..unMorphedName..", morphChoice="..morphChoice..", rank="..rank..", morphedName="..morphedName..", abilityIndex="..abilityIndex..", GetAbilityName(abilityId)="..GetAbilityName(abilityId)..", selected name="..slotname) end					
				else
					slotname = name
				end
				if slotname == SH.AB[ability][abName] then	
					SH.AB[ability][abSlot] = slot
					if DebugMe == 3 then d(SH.AB[ability][abName].." should be detected via key scanning") end
					if SH.AB[ability][abType] == 2 then -- abType = 2 = alert = detected by key
						SH.ScanKeys = true
						-- Get duration from API and update
						SH.AB[ability][abAPIdura] = GetAbilityDuration(GetSlotBoundId(slot))/1000
						if DebugMe == 3 then d("Is static dura "..SH.AB[ability][abDuration].." = "..SH.AB[ability][abAPIdura].." to the API dura? MorphDura = "..SH.AB[ability][abMorphDura]) end
						if SH.AB[ability][abMorphed] then
							if SH.AB[ability][abMorphDura] < SH.AB[ability][abAPIdura] then SH.AB[ability][abMorphDura] = SH.AB[ability][abAPIdura] end
						else
							if SH.AB[ability][abDuration] < SH.AB[ability][abAPIdura] then SH.AB[ability][abMorphDura] = SH.AB[ability][abAPIdura] end
						end
					end
				end
			end
		end
	end
end

-- Helper function to create the icon windows
function SH.CreateBuffWindow(name, px, icontexture)
	local tlw = WINDOW_MANAGER:CreateTopLevelWindow("SorcererHelper"..name)
		tlw:SetDimensions(px, px)
		tlw:SetHidden(false)
		tlw:SetAlpha(0)
	local bd = WINDOW_MANAGER:CreateControlFromVirtual("SorcererHelper"..name.."BD", tlw, "ZO_DefaultBackdrop")
		bd:SetAlpha(1)
	local icon = WINDOW_MANAGER:CreateControl("SorcererHelper"..name.."Icon", tlw, CT_TEXTURE)
		icon:SetDimensions(px+10,px+10)
		icon:SetAnchor(CENTER, tlw, CENTER, 0, 0)
		icon:SetTexture(icontexture)
		icon:SetDrawLevel(1)
	local text = WINDOW_MANAGER:CreateControl("SorcererHelper"..name.."Text", tlw, CT_LABEL)
		text:SetDimensions(px+10,px+10)
		text:SetVerticalAlignment(1)
		text:SetHorizontalAlignment(1)
		text:SetAnchor(CENTER, tlw, CENTER, 0, 0)
		text:SetAlpha(1)
		text:SetFont("ZoFontGame")
        text:SetColor(1,0.98,0.8,1)
        text:SetStyleColor(0,0,0,1)
		text:SetDrawLevel(2)
	return tlw,bd,icon,text
end

-- Create the remainder (buff) window and the alert window, as well as the windows for the icons
function SH.CreateUI()
	-- Reminder (buff) window, wherein the buff icons are displayed
	if not SH.BuffBarWindow then
		SH.BuffBarWindow = WINDOW_MANAGER:CreateTopLevelWindow("SorcererHelperBuffBarWindow")
		SorcererHelperBuffBarWindow:SetDimensions(121, 28)
		SorcererHelperBuffBarWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SH.SV.BBx, SH.SV.BBy)
		SorcererHelperBuffBarWindow:SetHidden(false)
		SorcererHelperBuffBarWindow:SetAlpha(0)

		SorcererHelperBuffBarWindow:SetMovable(false)
		SorcererHelperBuffBarWindow:SetMouseEnabled(true)
		SorcererHelperBuffBarWindow:SetHandler("OnMouseUp", function(_, button)
			if button == 1 then
				SH.SV.BBx = math.floor(SorcererHelperBuffBarWindow:GetLeft())
				SH.SV.BBy = math.floor(SorcererHelperBuffBarWindow:GetTop())
			end
		end)

		SH.BuffBarWindowBD = WINDOW_MANAGER:CreateControlFromVirtual("SorcererHelperBuffBarWindowBD", SH.BuffBarWindow, "ZO_DefaultBackdrop")
		SorcererHelperBuffBarWindowBD:SetAnchor(TOPLEFT, SH.BuffBarWindow, TOPLEFT, -12, -12 )
    	SorcererHelperBuffBarWindowBD:SetInheritAlpha(false)
    	SorcererHelperBuffBarWindowBD:SetAlpha(1)
	end

	-- Alert window, wherein the alert icons are displayed
	if not SH.AlertBarWindow then
		SH.AlertBarWindow = WINDOW_MANAGER:CreateTopLevelWindow("SorcererHelperAlertBarWindow")
		SorcererHelperAlertBarWindow:SetDimensions(64, 64)
		SorcererHelperAlertBarWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SH.SV.ABx, SH.SV.ABy)
		SorcererHelperAlertBarWindow:SetHidden(false)
		SorcererHelperAlertBarWindow:SetAlpha(0)

		SorcererHelperAlertBarWindow:SetMovable(false)
		SorcererHelperAlertBarWindow:SetMouseEnabled(true)
		SorcererHelperAlertBarWindow:SetHandler("OnMouseUp", function(_, button)
			if button == 1 then
				SH.SV.ABx = math.floor(SorcererHelperAlertBarWindow:GetLeft())
				SH.SV.ABy = math.floor(SorcererHelperAlertBarWindow:GetTop())
			end
		end)

		SH.AlertBarWindowBD = WINDOW_MANAGER:CreateControlFromVirtual("SorcererHelperAlertBarWindowBD", SH.AlertBarWindow, "ZO_DefaultBackdrop")
		SorcererHelperAlertBarWindowBD:SetAnchor(TOPLEFT, SH.AlertBarWindow, TOPLEFT, -12, -12 )
    	SorcererHelperAlertBarWindowBD:SetInheritAlpha(false)
    	SorcererHelperAlertBarWindowBD:SetAlpha(1)
	end

	-- Skill window, wherein the alert icons are displayed
	if not SH.SkillBarWindow then
		SH.SkillBarWindow = WINDOW_MANAGER:CreateTopLevelWindow("SorcererHelperSkillBarWindow")
		SorcererHelperSkillBarWindow:SetDimensions(5*64, 64)
		SorcererHelperSkillBarWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, SH.SV.SBx, SH.SV.SBy)
		SorcererHelperSkillBarWindow:SetHidden(false)
		SorcererHelperSkillBarWindow:SetAlpha(0)

		SorcererHelperSkillBarWindow:SetMovable(false)
		SorcererHelperSkillBarWindow:SetMouseEnabled(true)
		SorcererHelperSkillBarWindow:SetHandler("OnMouseUp", function(_, button)
			if button == 1 then
				SH.SV.SBx = math.floor(SorcererHelperSkillBarWindow:GetLeft())
				SH.SV.SBy = math.floor(SorcererHelperSkillBarWindow:GetTop())
			end
		end)

		SH.SkillBarWindowBD = WINDOW_MANAGER:CreateControlFromVirtual("SorcererHelperSkillBarWindowBD", SH.SkillBarWindow, "ZO_DefaultBackdrop")
		SorcererHelperSkillBarWindowBD:SetAnchor(TOPLEFT, SH.SkillBarWindow, TOPLEFT, -12, -12 )
    	SorcererHelperSkillBarWindowBD:SetInheritAlpha(false)
    	SorcererHelperSkillBarWindowBD:SetAlpha(1)
	end

	if SH.SV.LockMove then
		SorcererHelperBuffBarWindow:SetMovable(false)
		SorcererHelperAlertBarWindow:SetMovable(false)
		SorcererHelperSkillBarWindow:SetMovable(false)
	else
		SorcererHelperBuffBarWindow:SetMovable(true)
		SorcererHelperAlertBarWindow:SetMovable(true)
		SorcererHelperSkillBarWindow:SetMovable(true)
	end
	if SH.SV.ShowMove then
		SorcererHelperBuffBarWindow:SetHidden(false)
		SorcererHelperAlertBarWindow:SetHidden(false)
		SorcererHelperSkillBarWindow:SetHidden(false)
	else
		SorcererHelperBuffBarWindow:SetHidden(true)
		SorcererHelperAlertBarWindow:SetHidden(true)
		SorcererHelperSkillBarWindow:SetHidden(true)
	end
	
	-- icons for all abilities
	for ability = abFirst, abLast do
		if not SH.AB[ability][abWin] then
			SH.AB[ability][abWin], SH.AB[ability][abWBD], SH.AB[ability][abWIcon], SH.AB[ability][abWTxt] = SH.CreateBuffWindow(ability, 22, SH.AB[ability][abIcon])
			if DebugMe > 40 then d(ability..": GetAlpha()="..SH.AB[ability][abWin]:GetAlpha()) end
		end
	end
	SH.ResetScales()
end

-- Reset scales
function SH.ResetScales()
	local scale
	
	for ability = abFirst, abLast do
		if SH.AB[ability][abWin] then
			if SH.SV.ShowSkillbar then
				scale = SH.SV.skillScale
			elseif SH.AB[ability][abType] > 0 then 
				scale = SH.SV.alertScale
			else
				scale = SH.SV.buffScale
			end

			if DebugMe > 30 then d(SH.AB[ability][abName].." ("..SH.AB[ability][abSettingTxt]..")") end
			SH.AB[ability][abWin]:SetScale(scale)
			SH.AB[ability][abWBD]:SetScale(scale)
			SH.AB[ability][abWIcon]:SetScale(scale)
			SH.AB[ability][abWTxt]:SetScale(scale)
		end
	end
end

-- Animation to nicely fade in window
function SH.FadeIn(control, pAbility)
	if control:GetAlpha() == 1 then return end -- Already fully displayed
	
	-- Create anchor (if not already there)
	if not control.anchor then
        control.anchor = ZO_Anchor:New()
    end
    control.anchor:SetFromControlAnchor(control, 0)

	-- Reuse old animation or create if missing
    if not control.fadeIn then
        control.fadeIn = ANIMATION_MANAGER:CreateTimeline()
 
        local popin = control.fadeIn:InsertAnimation(ANIMATION_SCALE, control)
        popin:SetScaleValues(0, 1)
        popin:SetDuration(500)
        popin:SetEasingFunction(SH.CustomEasing)
 
        local fadeIn = control.fadeIn:InsertAnimation(ANIMATION_ALPHA, control)
        fadeIn:SetAlphaValues(0, 1)
        fadeIn:SetDuration(150)
        fadeIn:SetEasingFunction(ZO_EaseInQuartic)
 
        control.fadeIn:SetHandler('OnStop', function()  control.anchor:Set(control)  end)
    end
	

	if DebugMe > 30 then 
		if control.fadeIn:IsPlaying() then d("FadeIn ALREADY playing for "..control:GetName()..", Alpha="..control:GetAlpha()) end
	end
	if (not control.fadeIn:IsPlaying()) then -- Don't start again if it's already playing
	    control.fadeIn:PlayFromStart()
		-- Play Sound if Crystal Fragments (well, at the moment DON'T play sound)
--		if (pAbility == CF) then 
--			PlaySound("Display_Announcement")
--			PlaySound("Achievement_Awarded") 
--			d("PlaySound() for Crystal Fragment") 
--		end
	end
end

-- Animation to nicely fade in window
function SH.FadeOut(control)
	if control:GetAlpha() == 0 then return end -- Already hidden
	
	-- Create anchor (if not already there)
	if not control.anchor then
        control.anchor = ZO_Anchor:New()
    end
    control.anchor:SetFromControlAnchor(control, 0)
 
	-- Reuse old animation or create if missing
    if not control.fadeOut then
        control.fadeOut = ANIMATION_MANAGER:CreateTimeline()
 
        local popout = control.fadeOut:InsertAnimation(ANIMATION_SCALE, control)
        popout:SetScaleValues(1, 0)
        popout:SetDuration(1000)
        popout:SetEasingFunction(SH.CustomEasing)
 
        local fadeOut = control.fadeOut:InsertAnimation(ANIMATION_ALPHA, control)
        fadeOut:SetAlphaValues(1, 0)
        fadeOut:SetDuration(500)
        fadeOut:SetEasingFunction(ZO_EaseInQuartic)
 
        control.fadeOut:SetHandler('OnStop', function()  control.anchor:Set(control)  end)
    end
 
	if DebugMe > 30 then 
		if control.fadeOut:IsPlaying() then d("FadeOut ALREADY playing for "..control:GetName()..", Alpha="..control:GetAlpha()) end
	end
	if (not control.fadeOut:IsPlaying()) then -- Don't start again if it's already playing
		control.fadeOut:PlayFromStart()
	end
end
-----------------------------------------------------

-----------------------------------------------------
-- Detection routines

-- Detection function called every update (every new frame?) so be careful to keep it simple and quick!
local buffTimer = 0
local framesPerBuffCheck = 25 -- No hurry
local keyTimer = 0
local framesPerKeyCheck = 2 -- Do this frequent!
local procTimer = 0
local framesPerProcCheck = 6 -- Do this fairly frequent!


-- SH_Detection called via OnUpdate declaration in XML-file
function SH_Detection()
	if buffTimer >= framesPerBuffCheck then
		SH.GetBuffs()
		buffTimer = 0
	else buffTimer = buffTimer + 1 end
	
	if keyTimer >= framesPerKeyCheck then
		SH.KeyScanner()
		keyTimer = 0 
	else keyTimer = keyTimer + 1 end
	
	-- Detect proc of Crystal Fragment via it's cost
    -- Disable cost-based proc detection
	--	if procTimer >= framesPerProcCheck then
	if false then
		ability = CF
		if SH.SV.Show[ability] and SH.AB[ability][abSlot] > 0 then
			local cost = GetSlotAbilityCost(SH.AB[ability][abSlot])
			if cost > (SH.AB[ability][abCost] + 1) * 1/2 then -- Changed from 3/4 (75%) to 1/2 (50%)
				if DebugMe == 1 and SH.AB[ability][abProc] then d("Endproc detected by Cost at "..(GetGameTimeMilliseconds()/1000)) end
				SH.AB[ability][abProc] = false
				SH.AB[ability][abCost] = cost -- Saves "normal" value of cost
			else -- Cost has halved = Proc!
				if not SH.AB[ability][abProc] then -- But if already detected don't change timer
					if DebugMe == 1 then d("Proc detected by Cost at "..(GetGameTimeMilliseconds()/1000)..", newcost="..cost.." < 75% of oldcost="..SH.AB[ability][abCost]) end
					SH.AB[ability][abProc] = true
					SH.AB[ability][abTimer] = GetGameTimeMilliseconds()/1000 + SH.AB[ability][abDuration]
				end
			end
		end
		procTimer = 0 
	else procTimer = procTimer + 1 end
end

-- Scan through the action button to detect if an ability is cast (activated) and set the timer for it
local KeyScannerRunning = false
function SH.KeyScanner()
	if SH.ScanKeys == false then return end

	if KeyScannerRunning == true then return end -- Safety net to avoid multiple simultaneous calls to this function
	KeyScannerRunning = true
	
	for ability = abFirst, abLast do
		if SH.AB[ability][abSlot] > 0 and SH.AB[ability][abType] == 2 then -- abType = 2 = alerts
			local AbilityButton = _G["ActionButton"..SH.AB[ability][abSlot].."Button"]
			if AbilityButton:GetState() == BSTATE_PRESSED then
				if DebugMe == 4 then d(SH.AB[ability][abSlot].."="..SH.AB[ability][abName].." button pressed") end
				if ability == LS then -- not SH.AB[ability][abButtonPress]
					if DebugMe == 2 and not SH.AB[ability][abButtonPress] then d("Start cast of "..SH.AB[ability][abName]) end
					SH.AB[ability][abButtonPress] = true
				else
					if DebugMe == 2 and SH.AB[LS][abButtonPress] then d("Abort cast of "..SH.AB[LS][abName]) end
					SH.AB[LS][abButtonPress] = false
					SH.AB[ability][abProc] = true
					if SH.AB[ability][abMorphed] then
						SH.AB[ability][abTimer] = GetGameTimeMilliseconds()/1000 + SH.AB[ability][abMorphDura]
						if DebugMe > 30 then d("Proc! (morph) "..SH.AB[ability][abName].." for "..(SH.AB[ability][abTimer] - GetGameTimeMilliseconds()/1000).." sec, dura="..SH.AB[ability][abMorphDura] ) end
					else
						SH.AB[ability][abTimer] = GetGameTimeMilliseconds()/1000 + SH.AB[ability][abDuration]
						if DebugMe > 30 then d("Proc! "..SH.AB[ability][abName].." for "..(SH.AB[ability][abTimer] - GetGameTimeMilliseconds()/1000).." sec, dura="..SH.AB[ability][abDuration] ) end
					end
				end
			end
		end
	end

	KeyScannerRunning = false
end



-- Detect active buffs (which we should remind if they are not active)
-- Temporary skill are not recognized as buffs, for example Surge
local GetBuffsRunning = false
function SH.GetBuffs()
	if GetBuffsRunning == true then return end -- Safety net to avoid multiple simultaneous calls to this function
	GetBuffsRunning = true

	-- Clear old buff status
	for ability = abFirst, abLast do
		if SH.AB[ability][abType] == 0 then -- abType = 0 = buffs
			SH.AB[ability][abProc] = true -- inverse logic for buffs, as we want to alert when not active
		end
	end
	
	-- Get current buff status
    local numBuffs = GetNumBuffs("player")
	for buff = 1, numBuffs do
		local name = GetUnitBuffInfo("player", buff)
		for ability = abFirst, abLast do
			if SH.AB[ability][abType] == 0 and SH.SV.Show[ability] and name == SH.AB[ability][abName] then -- abType = 0 = buffs
				SH.AB[ability][abProc] = false -- inverse logic for buffs, as we want to alert when not active
				if DebugMe > 40 then d(buff.."="..name) end
			end
		end		
	end
	
	GetBuffsRunning = false
end


-- Called on EVENT_EFFECT_CHANGED callback
-- EVENT_EFFECT_CHANGED (*integer* _changeType_, *integer* _effectSlot_, *string* _effectName_, *string* _unitTag_, *number* _beginTime_, *number* _endTime_, 
--                        *integer* _stackCount_, *string* _iconName_, *string* _buffType_, *integer* _effectType_, *integer* _abilityType_, *integer* _statusEffectType_,
--                          *string* _unitName_, *integer* _unitId_, *integer* _abilityId_)
function SH.EffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitID, abilityID)
	if unitTag ~= "player" then return end
	if DebugMe > 30 then
		d("EC: "..eventCode..", "..changeType..", "..effectSlot..", "..effectName..", "..unitTag..", "..beginTime..", "..endTime..", "..stackCount..", "..iconName..", "..buffType..", "..effectType..", "..abilityType..", "..statusEffectType..", "..unitName..", "..unitID..", "..abilityID)
		for ability = abFirst, abLast do
			if SH.AB[ability][abName] == effectName then
				d("EC: "..changeType..", "..effectName.." found")
			end
		end		
	end
	
	-- Update 2.3 changed name from Passive to Proc, unclear what name used in German and French
	if effectName == "Crystal Fragments Proc" or effectName == "Crystal Fragments Passive" or effectName == "Kristallfragmente^p" or effectName ==  "Fragments de cristal passifs^pm" then
		local ability = CF
		if beginTime > 0 then 
			if DebugMe == 1 then
				if SH.AB[ability][abProc] == true then d("Re-proc detected by EFFECT_CHANGED at "..beginTime)
				else d("Proc detected by EFFECT_CHANGED at "..beginTime) end
			end
			-- Why not always restart timer??? Let's try
--			if not SH.AB[ability][abProc] then
			if true then
				SH.AB[ability][abProc] = true
				SH.AB[ability][abTimer] = beginTime + SH.AB[ability][abDuration]
			end
		else
			SH.AB[ability][abProc] = false
			if DebugMe == 1 then d("Endproc detected by EFFECT_CHANGED at "..(GetGameTimeMilliseconds()/1000) ) end
		end
	end
end


-- Called on EVENT_ACTION_UPDATE_COOLDOWNS callback
function SH.UpdateCooldowns(eventCode) 
	ability = LS
	if SH.AB[ability][abButtonPress] then
		if DebugMe == 2 then d("End cast of "..SH.AB[ability][abName].." and start countdown") end
		SH.AB[ability][abButtonPress] = false
		SH.AB[ability][abProc] = true
		if SH.AB[ability][abMorphed] then
			SH.AB[ability][abTimer] = GetGameTimeMilliseconds()/1000 + SH.AB[ability][abMorphDura]
			if DebugMe > 30 then d("Proc! (morph) "..SH.AB[ability][abName].." for "..(SH.AB[ability][abTimer] - GetGameTimeMilliseconds()/1000).." sec, dura="..SH.AB[ability][abMorphDura] ) end
		else
			SH.AB[ability][abTimer] = GetGameTimeMilliseconds()/1000 + SH.AB[ability][abDuration]
			if DebugMe > 30 then d("Proc! "..SH.AB[ability][abName].." for "..(SH.AB[ability][abTimer] - GetGameTimeMilliseconds()/1000).." sec, dura="..SH.AB[ability][abDuration] ) end
		end
	end
end
-----------------------------------------------------

function SH.CountDown(endTime)
	local countdown

	-- add 125 ms to cover up some of the delay between calls to MainLoop
	countdown = endTime + 0.125 - GetGameTimeMilliseconds()/1000
	if countdown < 0 then 
		countdown = -1
	else
		countdown = math.floor(countdown)
	end
	
	return countdown
end

-- Main loop updates the icons
function SH.MainLoop()
	SH.BuffBar = 0
	SH.AlertBar = 0
	SH.SkillBar = 5 -- For abilities no longer slotted
	local doShow = false
	local inMenu = ZO_Compass:IsHidden()

	-- If we should not use it for non-Sorcs, then return immediately to save computing resources
	-- Note, it will on purpose cause the zo_callLater() to NOT be initiated
	if not (SH.ClassId == 2 or SH.SV.NonSorc) then return end
	
	for ability = abFirst, abLast do
		doShow = false	
		
		if SH.AB[ability][abType] > 0 then -- manage timer for alerts and procs	, but not buffs that don't have a countdown
			if DebugMe == 1 and ability == CF and SH.AB[ability][abProc] and SH.CountDown(SH.AB[CF][abTimer]) < 0 then d("Endproc detected by timer at "..(GetGameTimeMilliseconds()/1000)) end
			if SH.CountDown(SH.AB[ability][abTimer]) < 0 then SH.AB[ability][abProc] = false end
		end

		-- Select if and where to display		
		if SH.AB[ability][abProc] and SH.SV.Show[ability] and not (SH.SV.HideInMenus and inMenu) and (SH.ClassId == 2 or (SH.SV.NonSorc and not (SH.AB[ability][abSkillClass] == SKILL_TYPE_CLASS))) then
			if DebugMe > 40 then d(SH.AB[ability][abName].."="..SH.AB[ability][abSlot].."->"..SH.CountDown(SH.AB[ability][abTimer]) ) end
		
			if SH.SV.ShowSkillbar then
				if SH.AB[ability][abSlot] > 0 then
					SH.AB[ability][abWin]:SetAnchor(TOPLEFT, SH.SkillBarWindow, TOPLEFT, SH.SV.skillScale * (SH.AB[ability][abSlot]-3) * 39, 0)
					doShow = true
				elseif SH.AB[ability][abType] == 2 then -- Alert not on skillbar, display offset to right
					SH.AB[ability][abWin]:SetAnchor(TOPLEFT, SH.SkillBarWindow, TOPLEFT, SH.SV.skillScale * SH.SkillBar * 39 + 20, 20)
					SH.SkillBar = SH.SkillBar + 1
					doShow = true					
				end
			else -- Use separate bars for alert/procs and buffs
				if SH.AB[ability][abType] == 0 and SH.AB[ability][abSlot] > 0 then -- Buff reminder
					SH.AB[ability][abWin]:SetAnchor(TOPLEFT, SH.BuffBarWindow, TOPLEFT, SH.SV.buffScale * SH.BuffBar * 39, 0)
					SH.BuffBar = SH.BuffBar + 1
					doShow = true
				elseif SH.AB[ability][abType] == 1 and SH.AB[ability][abSlot] > 0 then -- Crystal Fragment proc
					SH.AB[ability][abWin]:SetAnchor(TOPLEFT, SH.AlertBarWindow, TOPLEFT, SH.SV.alertScale * SH.AlertBar * 39, 0)
					SH.AlertBar = SH.AlertBar + 1
					doShow = true
				elseif SH.AB[ability][abType] == 2 then -- Alert and display regardless if slotted or not
					SH.AB[ability][abWin]:SetAnchor(TOPLEFT, SH.AlertBarWindow, TOPLEFT, SH.SV.alertScale * SH.AlertBar * 39, 0)
					SH.AlertBar = SH.AlertBar + 1
					doShow = true
				end
			end
		end
			
		-- display and start countdown
		if doShow then
			SH.FadeIn(SH.AB[ability][abWin], ability)
			if SH.AB[ability][abType] > 0 then -- set timer for alerts and procs
				SH.AB[ability][abWTxt]:SetText(SH.CountDown(SH.AB[ability][abTimer]))
			end
		else -- hide
			if SH.AB[ability][abWin]:GetAlpha() > 0 then 
				SH.FadeOut(SH.AB[ability][abWin])
			end
		end
	end
	
	-- call again in 1/4 sec, note dependency to FadeOut function
	zo_callLater(function() SH.MainLoop() end, 250)
end
-----------------------------------------------------

-----------------------------------------------------
-- Settings and save variables

-- Define settings menu
function SH.CreateSettings()
	local LAM2 = LibStub("LibAddonMenu-2.0")
	local optionsData = {
		[1] = {
			type = "header",
			name = "Setup",
		},		
		[2] = {
			type = "checkbox",
			name = "Enable for non-Sorcs",
			tooltip = "NOTE, you must logout and then login again to make a enable the any change of this setting!",
			getFunc = function() return SH.SV.NonSorc end,
			setFunc = function(value) 
				SH.SV.NonSorc = value 
			end,
		},
		[3] = {
			type = "checkbox",
			name = "Show repositioning help",
			tooltip = "Unlock bars and show frame for the reminder and alert windows in the UI, to aid repositioning",
			getFunc = function() return SH.SV.ShowMove end,
			setFunc = function(value) 
				if value == true then
					SorcererHelperBuffBarWindow:SetHidden(false)
					SorcererHelperAlertBarWindow:SetHidden(false)
					SorcererHelperSkillBarWindow:SetHidden(false)
					SorcererHelperBuffBarWindow:SetMovable(true)
					SorcererHelperAlertBarWindow:SetMovable(true)
					SorcererHelperSkillBarWindow:SetMovable(true)
				elseif value == false then
					SorcererHelperBuffBarWindow:SetHidden(true)
					SorcererHelperAlertBarWindow:SetHidden(true)
					SorcererHelperSkillBarWindow:SetHidden(true)
					SorcererHelperBuffBarWindow:SetMovable(false)
					SorcererHelperAlertBarWindow:SetMovable(false)
					SorcererHelperSkillBarWindow:SetMovable(false)
				end
				SH.SV.ShowMove = value 
			end,
		},
		[4] = {
			type = "checkbox",
			name = "Hide in menus",
			tooltip = "Hide reminders and alerts when 'compass' is hidden",
			getFunc = function() return SH.SV.HideInMenus end,
			setFunc = function(value) 
				SH.SV.HideInMenus = value 
			end,
		},
		[5] = {
			type = "checkbox",
			name = "Enable one common skill bar",
			tooltip = "Disables bars for reminders and alerts. The common skill bar displays reminders, alerts and procs shown in skill bar order",
			getFunc = function() return SH.SV.ShowSkillbar end,
			setFunc = function(value) 
				SH.SV.ShowSkillbar = value 
				SH.ResetScales()
			end,
		},
		[6] = {
			type = "slider",
			name = "Reminder bar scaling (percent)",
			tooltip = "Sets the scaling for buffs (reminders)",
			min = 100,
			max = 300,
			step = 25,
			getFunc = function() return SH.SV.buffScale * 100 end,
			setFunc = function(value) 
				if value ~= SH.SV.buffScale then
					SH.SV.buffScale = value / 100
					SH.ResetScales()
				end
			end,
		},
		[7] = {
			type = "slider",
			name = "Alert bar scaling (percent)",
			tooltip = "Sets the scaling for alerts and procs",
			min = 100,
			max = 300,
			step = 25,
			getFunc = function() return SH.SV.alertScale * 100 end,
			setFunc = function(value) 
				if value ~= SH.SV.alertScale then
					SH.SV.alertScale = value / 100
					SH.ResetScales()
				end
			end,
		},
		[8] = {
			type = "slider",
			name = "Skill bar scaling (percent)",
			tooltip = "Sets the scaling for reminders, alerts and procs shown in skill bar order",
			min = 100,
			max = 300,
			step = 25,
			getFunc = function() return SH.SV.skillScale * 100 end,
			setFunc = function(value) 
				if value ~= SH.SV.skillScale then
					SH.SV.skillScale = value / 100
					SH.ResetScales()
				end
			end,
		},
		[9] = {
			type = "checkbox",
			name = "Save settings per character",
			tooltip = "Don't use account wide settings, but rather for each character. Note, this setting (only) is ALWAYS account wide.",
			getFunc = function() return SH.alwaysAccountWide.saveMode end,
			setFunc = function(value) 
				SH.alwaysAccountWide.saveMode = value 
			end,
		},
		[10] = {
			type = "header",
			name = "Show (or hide) abilities",
		},
	}
	-- dynamically add all abilities
	for ability = abFirst, abLast do		
		local checkbox = {
			type = "checkbox",
			name = SH.AB[ability][abSettingTxt],
			tooltip = SH.AB[ability][abSettingHelp],
			getFunc = function() return SH.SV.Show[ability] end,
			setFunc = function(value) 
				if value == false then
					SH.AB[ability][abWin]:SetAlpha(0)
				end
				SH.SV.Show[ability] = value
			end
		}
		table.insert(optionsData, checkbox)
	end
			
	LAM2:RegisterAddonPanel("SorcererHelperOptions", panelData)
	LAM2:RegisterOptionControls("SorcererHelperOptions", optionsData)
end
-----------------------------------------------------

-----------------------------------------------------
-- Event handlers not under detection routines
local function OnPlayerActivated()
	SH.GetAbilities()
	SH.GetSlotted()
	SH.CreateUI()
	
	SH.MainLoop()
end

local isUpdating = false
local function OnAbilitySlotted(newAbility)
    -- workaround for EVENT_ACTION_SLOT_ABILITY_SLOTTED firing too fast
	-- and filter out any additional calls to reduce strain on system
	-- (and hoping the important one is not too close to the end)
    if not isUpdating then
        isUpdating = true
        zo_callLater(function()
                SH.GetSlotted()
                isUpdating = false
            end, 300)
    end
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName == SH.name then
		--Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
		SH.alwaysAccountWide = ZO_SavedVars:NewAccountWide(SH.name.."_SavedVariables", 999, "SettingsForAll", SH.Defaults)
		--Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
		--Use the current addon version to read the settings now
		if (SH.alwaysAccountWide.saveMode == true) then
			--Use each character settings
			SH.SV = ZO_SavedVars:New(SH.name.."_SavedVariables", SH.saveVersion , "Settings", SH.Defaults)
		else
			--Use standard: account wide settings
			SH.SV = ZO_SavedVars:NewAccountWide(SH.name.."_SavedVariables", SH.saveVersion, "Settings", SH.Defaults)
		end
        -- old SH.SV = ZO_SavedVars:NewAccountWide(SH.name.."_SavedVariables", 2, nil, SH.Defaults)
		
		SH.ClassId = GetUnitClassId("player")
		
		EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
		EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_ACTION_SLOT_ABILITY_SLOTTED, OnAbilitySlotted)
		EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, SH.GetSlotted)

		-- Don't load detection routines for non-Sorcs, if not allowed
		-- If setting changed to allow non-Sorc these will not be enabled unless logout and then login again
		if SH.ClassId == 2 or SH.SV.NonSorc then
			-- Events for detection
			EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_EFFECT_CHANGED, SH.EffectChanged)
			EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_ACTION_UPDATE_COOLDOWNS, SH.UpdateCooldowns)

			-- EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, SH.VisualAdded)
			-- EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, SH.VisualRemoved)
			-- EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, SH.VisualUpdated) -- Does not seem to detect Crystal Fragment
			-- EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_COMBAT_EVENT, SH.CombatEvent)
			-- EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_POWER_UPDATE, SH.PowerUpdate)
		end
		
		SH.CreateSettings()
	end
end

function SorcererHelperInitialize()
	EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end
-----------------------------------------------------

-----------------------------------------------------
-- Unused callbacks

-- Called on EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED callback
function SH.VisualAdded(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if unitTag ~= "player" then return end
	if DebugMe == 1 then 
		d("VisualTempl: "..ATTRIBUTE_VISUAL_INCREASED_STAT..", "..STAT_POWER..", "..ATTRIBUTE_HEALTH..", "..POWERTYPE_HEALTH..", 200, 200") 
		d("VisualEvent: "..unitAttributeVisual..", "..statType..", "..attributeType..", "..powerType..", "..value..", "..maxValue) 
	end

	if unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and statType == STAT_POWER and attributeType == ATTRIBUTE_HEALTH and powerType == POWERTYPE_HEALTH then
		ability = CF
		if not SH.AB[ability][abProc] then
			SH.AB[ability][abProc] = true
			SH.AB[ability][abTimer] = GetGameTimeMilliseconds()/1000 + SH.AB[ability][abDuration]
		end
		if DebugMe == 1 then d("Proc detected by VISUAL_ADDED at "..(GetGameTimeMilliseconds()/1000)) end
	end
end

-- Called on EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED callback
function SH.VisualRemoved(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if unitTag ~= "player" then return end
	if DebugMe == 1 then 
		d("VisualTempl: "..ATTRIBUTE_VISUAL_INCREASED_STAT..", "..STAT_POWER..", "..ATTRIBUTE_HEALTH..", "..POWERTYPE_HEALTH..", 200, 200") 
		d("VisualEvent: "..unitAttributeVisual..", "..statType..", "..attributeType..", "..powerType..", "..value..", "..maxValue) 
	end

	if unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and statType == STAT_POWER and attributeType == ATTRIBUTE_HEALTH and powerType == POWERTYPE_HEALTH then
		ability = CF
		SH.AB[ability][abProc] = false
		if DebugMe == 1 then d("Endproc detected by VISUAL_REMOVED at "..(GetGameTimeMilliseconds()/1000)) end
	end
end

-- Called on EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED callback
function SH.VisualUpdated(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldvalue, newvalue, oldmaxValue, newmaxValue)
	if unitTag ~= "player" then return end
	if DebugMe == 1 then 
		d("VisualTempl: "..ATTRIBUTE_VISUAL_INCREASED_STAT..", "..STAT_POWER..", "..ATTRIBUTE_HEALTH..", "..POWERTYPE_HEALTH) 
		d("VisualEvent: "..unitAttributeVisual..", "..statType..", "..attributeType..", "..powerType..", "..oldvalue..", "..newvalue..", "..oldmaxValue..", "..newmaxValue) 
	end

	if unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT and statType == STAT_POWER and attributeType == ATTRIBUTE_HEALTH and powerType == POWERTYPE_HEALTH then
		if DebugMe == 1 then d("Proc or endproc detected by VISUAL_UPDATED at "..(GetGameTimeMilliseconds()/1000)) end
	end
end

--  EVENT_COMBAT_EVENT(integer eventCode, integer result, bool isError, string abilityName, integer abilityGraphic, integer abilityActionSlotType, string sourceName, integer sourceType, string targetName, integer targetType, integer hitValue, integer powerType, integer damageType, bool log) 
function SH.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, loginfo)
	if DebugMe == 2 and abilityName == SH.AB[LS][abName] then 
		d("CombatEvent: "..result..", "..abilityName..", "..abilityGraphic..", "..abilityActionSlotType..", "..sourceName..", "..sourceType..", "..targetName..", "..targetType..", "..hitValue..", "..powerType..", "..damageType) 
	end
	if DebugMe == 1 and abilityName == SH.AB[CF][abName] then 
		d("CombatEvent: "..result..", "..abilityName..", "..abilityGraphic..", "..abilityActionSlotType..", "..sourceName..", "..sourceType..", "..targetName..", "..targetType..", "..hitValue..", "..powerType..", "..damageType) 
	end
end

-- EVENT_POWER_UPDATE (integer eventCode, string unitTag, integer powerIndex, integer powerType, integer powerValue, integer powerMax, integer powerEffectiveMax) 
function SH.PowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax) 
	if DebugMe == 2 or DebugMe == 1 then 
		d("PowerUpdate: "..unitTag..", "..powerIndex..", "..powerType..", "..powerValue..", "..powerMax..", "..powerEffectiveMax) 
	end
end