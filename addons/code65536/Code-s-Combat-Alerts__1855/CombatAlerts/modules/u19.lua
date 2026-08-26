local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_U19"
Module.NAME = CA2.GenerateModuleName(19, 1052, 1055)
Module.AUTHOR = "@code65536"
Module.ZONES = {
	1052, -- Moon Hunter Keep
	1055, -- March of Sacrifices
	1592, -- March of Sacrifices (Solo)
	1593, -- Moon Hunter Keep (Solo)
}

Module.DATA = {
	-- March of Sacrifices
	balorgh = {
		fireId = 112386,
		hardHealth = 6300000, -- 5645195 non-HM, 6491974 HM (pre-U35: 6272440 non-HM, 7213306 HM)
		water = {
			id = 107624, -- Electric Water
			color = 0x66CCFFFF,
		},
		venom = {
			id = 107777, -- Venomous Spores
			color = 0x00CC00FF,
		},
		[106541] = "water", -- Thunder Stomp
		[106727] = "venom", -- Venomous Slam
		[107624] = "water", -- Electric Water
		[107740] = "venom", -- Venom Slam
	},

	-- Moon Hunter Keep
	root = {
		[104196] = true, -- Group
		[265085] = true, -- Solo
	},
	shockBlast = {
		[104197] = true, -- Group
		[265086] = true, -- Solo
	},
	pounce = 104863,
	switch = 113626,
}
local DATA = Module.DATA
local Vars

function Module:Initialize( )
	self.TIMER_ALERTS_LEGACY = {
		-- Moon Hunter Keep (Group)
		[102107] = { -2, 2 }, -- Crushing Leap
		[103587] = { -2, 2 }, -- Shred
		[103951] = { -2, 2 }, -- Lunge (Dire Wolf)
		[103994] = { -2, 2 }, -- Rending Slash
		[105324] = { -2, 2 }, -- Devastating Leap
		[105494] = { -2, 2 }, -- Crushing Limbs
		[110225] = { -2, 2 }, -- Crushing Leap

		-- March of Sacrifices (Group)
		[ 29400] = { -2, 2 }, -- Power Bash (Bloodscent Guardian)
		[106808] = { -2, 2 }, -- Ravaging Blow (Dagrund the Bulky)
		[106885] = { -2, 2 }, -- Crushing Limbs
		[107323] = { -2, 2 }, -- Horn Burst
		[107654] = { -3, 2, true }, -- Taking Aim (Wyress Strigidae)
		[107697] = { -2, 2 }, -- Power Bash (Wyress Ursus)
		[107711] = { -2, 2 }, -- Shield Charge
		[107955] = { -2, 1 }, -- Slaughtering Strike
		[108152] = { -2, 2 }, -- Dire Lunge
		[108155] = { -2, 2 }, -- Crushing Leap
		[108564] = { -3, 2 }, -- Fetid Globule
		[108569] = { -2, 2 }, -- Ravaging Blow (Bloodscent Thundermaul)
		[111420] = { -3, 1, true }, -- Trapping Bolt

		-- Moon Hunter Keep (Solo)
		[254074] = { -2, 0 }, -- Heavy Strike
		[265060] = { -2, 0 }, -- Shred
		[265074] = { -2, 0 }, -- Rending Slash
		[265101] = { -2, 0 }, -- Lunge (Ary/Zel)
		[265116] = { -2, 0 }, -- Devastating Leap
		[265177] = { -2, 0 }, -- Lunge (Dire Wolf)
		[267405] = { -2, 0 }, -- Slam (Wildbriar Bear)
		[269249] = { -2, 0 }, -- Double Strike

		-- March of Sacrifices (Solo)
		[254088] = { -3, 1, true }, -- Taking Aim (Bearfang Hunter)
		[254109] = { -2, 0 }, -- Power Bash (Bloodscent Guardian)
		[254248] = { -2, 0 }, -- Uppercut
		[263966] = { -2, 0 }, -- Ravaging Blow
		[264020] = { -2, 0 }, -- Horn Burst
		[264038] = { -3, 1, true }, -- Taking Aim (Wyress Strigidae)
		[264047] = { -2, 0 }, -- Power Bash (Wyress Ursus)
		[264049] = { -2, 0 }, -- Shield Charge (Wyress Ursus)
		[264064] = { -2, 0 }, -- Slaughtering Strike
		[264099] = { -2, 0 }, -- Sunder
		[267201] = { -3, 0 }, -- Fetid Globule

		-- General
		[105303] = { -3, 2, true }, -- Taking Aim (Group)
		[273266] = { -3, 1, true }, -- Taking Aim (Solo)
		[263979] = { -2, 0 }, -- Crushing Limbs
		[267268] = { -2, 0 }, -- Assassinate
		[267392] = { -2, 0 }, -- Crushing Leap
	}

	self.vars = {
		lastBalorghEnvironment = 0,
	}
	Vars = self.vars
end

function Module:ProcessCombatEvents( result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	-- March of Sacrifices
	if (result == ACTION_RESULT_BEGIN and abilityId == DATA.balorgh.fireId) then
		local _, _, effectiveMax = GetUnitPower("boss1", COMBAT_MECHANIC_FLAGS_HEALTH)
		if (effectiveMax >= DATA.balorgh.hardHealth) then
			CA1.AlertCast(abilityId, nil, hitValue, { -3, 1 })
		end
	elseif ((result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED_DURATION) and DATA.balorgh[abilityId]) then
		if (GetGameTimeMilliseconds() - Vars.lastBalorghEnvironment >= 3000) then
			Vars.lastBalorghEnvironment = GetGameTimeMilliseconds()
			local mechanic = DATA.balorgh[DATA.balorgh[abilityId]]
			CA1.Alert(nil, LCA.GetAbilityName(mechanic.id), mechanic.color, SOUNDS.OBJECTIVE_DISCOVERED, 2500)
		end

	-- Moon Hunter Keep
	elseif (result == ACTION_RESULT_BEGIN and DATA.root[abilityId]) then
		CA1.AlertCast(abilityId, nil, hitValue, { -2, 1 })
	elseif (result == ACTION_RESULT_BEGIN and DATA.shockBlast[abilityId] and targetType == COMBAT_UNIT_TYPE_PLAYER and hitValue > 2000) then
		CA1.AlertCast(abilityId, nil, hitValue, { -2, 0, false, { 0.3, 0.9, 1, 0.6 }, { 0, 0.5, 1, 1 } })
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.pounce) then
		CA1.AlertCast(abilityId, nil, hitValue, { -2, 2 })
	elseif (result == ACTION_RESULT_EFFECT_GAINED and abilityId == DATA.switch) then
		CA1.Alert(nil, LCA.GetAbilityName(abilityId), 0xCC3366FF, SOUNDS.OBJECTIVE_DISCOVERED, 2500)
	end
end

CA2.RegisterModule(Module)
