ThatchorsTips = {
	name = "ThatchorsTips",
	version = "1.04",

	-- Default settings
	default = {},
}

local TT = ThatchorsTips
local EM = EVENT_MANAGER

-- Add some toxicity
local mockText = {}
local mockZones = {
	[636] = true, -- hrc
	[638] = true, -- aa
	[639] = true, -- so
	[725] = true, -- mol
	[975] = true, -- hof
	[1000] = true, -- as
	[1051] = true, -- cr
	[1121] = true, -- ss
	[1196] = true, -- ka
}

-- Death recap is shown/hidden
local function DeathRecapChanged(status)
	if status and ZO_DeathRecapScrollContainerScrollChildHintsContainerHints1Text then
		text = mockText[math.random(#mockText)]
		ZO_DeathRecapScrollContainerScrollChildHintsContainerHints1Text:SetText(GetString(text))
	end
	-- if status and ZO_DeathRecapScrollContainerScrollChildHintsContainerHints2Text then
	-- 	text = mockText[math.random(#mockText)]
	-- 	ZO_DeathRecapScrollContainerScrollChildHintsContainerHints2Text:SetText(GetString(text))
	-- end
end

local function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

-- Generate mocking strings
local function GenerateMock()
	DEATH_RECAP:UnregisterCallback("OnDeathRecapAvailableChanged", DeathRecapChanged)
	mockText = {} -- wipe the current table
	local zoneID = GetZoneId(GetUnitZoneIndex('player'))
	local roleID = GetSelectedLFGRole() -- 1 = dps; 2 = tank; 4 = healer
	local classID = GetUnitClass('player')
	local lang = GetCVar("language.2")

	local player1 = GetUnitDisplayName('group1')
	local player2 = GetUnitDisplayName('group2')
	local player3 = GetUnitDisplayName('group3')
	local player4 = GetUnitDisplayName('group4')
	local player5 = GetUnitDisplayName('group5')
	local player6 = GetUnitDisplayName('group6')
	local player7 = GetUnitDisplayName('group7')
	local player8 = GetUnitDisplayName('group8')
	local player9 = GetUnitDisplayName('group9')
	local player10 = GetUnitDisplayName('group10')
	local player11 = GetUnitDisplayName('group11')
	local player12 = GetUnitDisplayName('group12')

	local players = {player1, player2, player3, player4, player5, player6, player7, player8, player9, player10, player11, player12}

	if (lang == "en") then

		mockText = {TT_MOCK1, TT_MOCK2, TT_MOCK3, TT_MOCK4, TT_MOCK5, TT_MOCK6, TT_MOCK7, TT_MOCK8, TT_MOCK9, TT_MOCK10, TT_MOCK11, TT_MOCK12, TT_MOCK13, TT_MOCK14, TT_MOCK15, TT_MOCK16, TT_MOCK17, TT_MOCK18, TT_MOCK19, TT_MOCK20, TT_MOCK21, TT_MOCK22, TT_MOCK23, TT_MOCK24, TT_MOCK25, TT_MOCK26, TT_MOCK27, TT_MOCK28, TT_MOCK29, TT_MOCK30, TT_MOCK31, TT_MOCK32, TT_MOCK33, TT_MOCK34, TT_MOCK35, TT_MOCK36, TT_MOCK37, TT_MOCK38, TT_MOCK39, TT_MOCK40, TT_MOCK41, TT_MOCK42, TT_MOCK43, TT_MOCK44, TT_MOCK45, TT_MOCK46, TT_MOCK_47, TT_MOCK48, TT_MOCK49, TT_MOCK50, TT_MOCK51, TT_MOCK52, TT_MOCK53, TT_MOCK54}

		------------------------------------------------------------------------
		---------------------------- Zones -------------------------------------
		------------------------------------------------------------------------

		if zoneID == 636 or zoneID == 638 or zoneID == 639 then
			table.insert(mockText, TT_MOCK_CRAG1)
		end

		if zoneID == 639 then
			table.insert(mockText, TT_MOCK_SO1)
			table.insert(mockText, TT_MOCK_SO2)
		end

		if zoneID == 725 then
			table.insert(mockText, TT_MOCK_MOL1)
		end

		if zoneID == 975 then
			table.insert(mockText, TT_MOCK_HOF1)
			table.insert(mockText, TT_MOCK_HOF2)
		end

		if zoneID == 1000 then
			table.insert(mockText, TT_MOCK_AS1)
			table.insert(mockText, TT_MOCK_AS2)
		end

		if zoneID == 1000 and roleID < 3 then
			table.insert(mockText, TT_MOCK_AS3)
		end

		if zoneID == 1051 then
			table.insert(mockText, TT_MOCK_CR1)
			table.insert(mockText, TT_MOCK_CR2)
			table.insert(mockText, TT_MOCK_CR3)
			table.insert(mockText, TT_MOCK_CR4)
			table.insert(mockText, TT_MOCK_CR5)
			table.insert(mockText, TT_MOCK_CR6)
		end

		if zoneID == 1121 then
			table.insert(mockText, TT_MOCK_SS1)
			table.insert(mockText, TT_MOCK_SS2)
			table.insert(mockText, TT_MOCK_SS3)
			table.insert(mockText, TT_MOCK_SS4)
			table.insert(mockText, TT_MOCK_SS5)
		end

		if zoneID == 1196 then
			table.insert(mockText, TT_MOCK_KA1)
		end

		------------------------------------------------------------------------
		---------------------------- Roles -------------------------------------
		------------------------------------------------------------------------

		if roleID == 1 then
			table.insert(mockText, TT_MOCK_DPS1)
			table.insert(mockText, TT_MOCK_DPS2)
			table.insert(mockText, TT_MOCK_DPS3)
			table.insert(mockText, TT_MOCK_DPS4)
			table.insert(mockText, TT_MOCK_DPS5)
			table.insert(mockText, TT_MOCK_DPS6)
			table.insert(mockText, TT_MOCK_DPS7)
			table.insert(mockText, TT_MOCK_DPS8)
			table.insert(mockText, TT_MOCK_DPS9)
			table.insert(mockText, TT_MOCK_DPS10)
			table.insert(mockText, TT_MOCK_DPS11)
			table.insert(mockText, TT_MOCK_DPS12)
			table.insert(mockText, TT_MOCK_DPS13)
			table.insert(mockText, TT_MOCK_DPS14)
			table.insert(mockText, TT_MOCK_DPS15)
			table.insert(mockText, TT_MOCK_DPS16)
		end

		if roleID == 2 then
			table.insert(mockText, TT_MOCK_TANK1)
			table.insert(mockText, TT_MOCK_TANK2)
			table.insert(mockText, TT_MOCK_TANK3)
			table.insert(mockText, TT_MOCK_TANK4)
			table.insert(mockText, TT_MOCK_TANK5)
			table.insert(mockText, TT_MOCK_TANK6)
			table.insert(mockText, TT_MOCK_TANK7)
			table.insert(mockText, TT_MOCK_TANK8)
			table.insert(mockText, TT_MOCK_TANK9)
			table.insert(mockText, TT_MOCK_TANK10)
			table.insert(mockText, TT_MOCK_TANK11)
			table.insert(mockText, TT_MOCK_TANK12)
		end

		if roleID == 4 then
			table.insert(mockText, TT_MOCK_HEAL1)
			table.insert(mockText, TT_MOCK_HEAL2)
			table.insert(mockText, TT_MOCK_HEAL3)
			table.insert(mockText, TT_MOCK_HEAL4)
			table.insert(mockText, TT_MOCK_HEAL5)
			table.insert(mockText, TT_MOCK_HEAL6)
			table.insert(mockText, TT_MOCK_HEAL7)
			table.insert(mockText, TT_MOCK_HEAL8)
			table.insert(mockText, TT_MOCK_HEAL9)
			table.insert(mockText, TT_MOCK_HEAL10)
			table.insert(mockText, TT_MOCK_HEAL11)
			table.insert(mockText, TT_MOCK_HEAL12)
		end

		------------------------------------------------------------------------
		---------------------------- Classes -----------------------------------
		------------------------------------------------------------------------

		if classID == "Warden" and roleID == 1 then
			table.insert(mockText, TT_MOCK_WARD1)
			table.insert(mockText, TT_MOCK_WARD2)
		end

		if classID == "Dragonknight" then
			table.insert(mockText, TT_MOCK_DK1)
		end

		if classID == "Dragonknight" and roleID == 1 then
			table.insert(mockText, TT_MOCK_DK2)
		end

		if classID == "Dragonknight" and roleID == 4 then
			table.insert(mockText, TT_MOCK_DK3)
		end

		if classID == "Templar" then
			table.insert(mockText, TT_MOCK_TEMP1)
		end

		if classID == "Templar" and roleID == 2 then
			table.insert(mockText, TT_MOCK_TEMP2)
		end

		if classID == "Necromancer" then
			table.insert(mockText, TT_MOCK_NEC1)
			table.insert(mockText, TT_MOCK_NEC2)
		end

		if classID == "Nightblade" then
			table.insert(mockText, TT_MOCK_NB1)
		end

		if classID == "Nightblade" and roleID == 4 then
			table.insert(mockText, TT_MOCK_NB4)
			table.insert(mockText, TT_MOCK_DK3)
		end

		if classID == "Sorcerer" then
			table.insert(mockText, TT_MOCK_SORC1)
		end

		if classID == "Sorcerer" and roleID == 1 then
			table.insert(mockText, TT_MOCK_SORC2)
			table.insert(mockText, TT_MOCK_SORC3)
			table.insert(mockText, TT_MOCK_SORC4)
			table.insert(mockText, TT_MOCK_SORC5)
		end

		------------------------------------------------------------------------
		---------------------------- Players -----------------------------------
		------------------------------------------------------------------------

		if has_value(players, "@Sir_Thatchor") then
			table.insert(mockText, TT_MOCK_THATCH1)
		end

		if has_value(players, "@LeviathanScream") then
			table.insert(mockText, TT_MOCK_LEVI1)
		end

		if has_value(players, "@OwnLight88") then
			table.insert(mockText, TT_MOCK_OWN1)
			table.insert(mockText, TT_MOCK_OWN2)
		end

		if has_value(players, "@OptiePrime") then
			table.insert(mockText, TT_MOCK_OWN2)
			table.insert(mockText, TT_MOCK_OPTIE1)
		end

		if has_value(players, "@Stealthhyy") then
			table.insert(mockText, TT_MOCK_STEALTH1)
			table.insert(mockText, TT_MOCK_STEALTH2)
		end

		if has_value(players, "@ChaosFractal") then
			table.insert(mockText, TT_MOCK_CHAOS1)
		end

		if has_value(players, "@MasAmedda") then
			table.insert(mockText, TT_MOCK_MAS1)
		end

		if has_value(players, "@Skittile") then
			table.insert(mockText, TT_MOCK_SKIT1)
		end

		if has_value(players, "@KnowingQuasar") then
			table.insert(mockText, TT_MOCK_QUAS1)
		end

		if has_value(players, "@SoppaPK") then
			table.insert(mockText, TT_MOCK_CADD1)
		end

		------------------------------------------------------------------------
		---------------------------- Misc. -------------------------------------
		------------------------------------------------------------------------

		if GetWorldName() == "EU Megaserver" then table.insert(mockText, TT_MOCK_EU1) end

		if GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_NORMAL then
			table.insert(mockText, TT_MOCK_NORMAL1)
		elseif GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN then
			table.insert(mockText, TT_MOCK_VET1)
		else
			table.insert(mockText, TT_MOCK_OVER1)
		end
		DEATH_RECAP:RegisterCallback("OnDeathRecapAvailableChanged", DeathRecapChanged)
	end
end

function ThatchorsTips.Initialize()
	GenerateMock()
end

function ThatchorsTips.OnAddOnLoaded(event, addonName)
	if addonName == ThatchorsTips.name then
		ThatchorsTips.Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(ThatchorsTips.name, EVENT_ADD_ON_LOADED, ThatchorsTips.OnAddOnLoaded)

EVENT_MANAGER:RegisterForEvent(ThatchorsTips.name, EVENT_PLAYER_DEAD, ThatchorsTips.Initialize)
