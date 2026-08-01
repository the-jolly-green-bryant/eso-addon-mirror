local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_U20"
Module.NAME = CA2.GenerateModuleName(20, 1082)
Module.AUTHOR = "@code65536"
Module.ZONES = {
	1082, -- Blackrose Prison
}

Module.STRINGS = {
	-- Extracted
	["8290981-0-86045"] = { default = "Drakeeh the Unchained^M", de = "Drakeeh der Entfesselte^M", es = "Drakeeh el Desencadenado^M", fr = "Drakeeh le Déchaîné^M", jp = "解き放たれしドラキー^M", ru = "Драки Освобожденный^M", zh = "被解放的德拉基^M" },
}

Module.DATA = {
	roots = {
		[110916] = true,
		[110922] = true,
		[110971] = true,
		[110978] = true,
		duration = 2250,
		damage = {
			[110940] = true,
			[110965] = true,
			[110969] = true,
			[110976] = true,
		},
	},
	spirit = {
		increments = {
			[110639] = true, -- Spirit Ignition, initial projectile
			[111749] = true, -- Spirit Ignition, boss absorption
		},
		golden = 111779,
		ignition = 110613,
		scream = 110661,
	},
}
local DATA = Module.DATA
local Vars

function Module:Initialize( )
	self.MONITOR_BOSSES = true
	self.MONITOR_UNIT_IDS = true

	self.TIMER_ALERTS_LEGACY = {
		[71771] = { -3, 2 }, -- Ball Lightning
		[110898] = { -3, 2, true }, -- Taking Aim
		[111209] = { -3, 2, true }, -- Taking Aim
		[113146] = { -3, 2, true }, -- Taking Aim
	}

	self.SMALL_GROUP_SIZE = true
	self.PURGEABLE_EFFECTS = {
		[109992] = 0, -- Poisonbloom
		[113150] = 0, -- Arrow Spray Poison
	}

	self.vars = {
		spirits = 0,
	}
	Vars = self.vars

	do
		local SPIRIT_COLORS = {
			[0] = 0x00FF00FF,
			[1] = 0xFFFF00FF,
			[2] = 0xFF9900FF,
			[3] = 0xFF0000FF,
		}
		self.StatusPoll_SpiritScream = function( )
			CA2.StatusSetCellText(1, 2, Vars.spirits)
			CA2.StatusSetRowColor(1, SPIRIT_COLORS[Vars.spirits] or SPIRIT_COLORS[3])
		end
	end
end

function Module:OnBossesChanged( )
	if (LCA.MatchStrings(GetUnitName("boss1"), self:GetString("8290981-0-86045"))) then
		CA2.WorldTexturePlace({
			pos = { 96000, 48100, 30709 },
			texture = "world-circle-bordered",
			color = 0xCC000066,
		})
	else
		CA2.WorldCanvasClear()
	end
end

function Module:PreStartListening( )
	Vars.achState = 0
end

function Module:PostStopListening( )
	CA2.StatusDisable()
end

function Module:ProcessCombatEvents( result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	if ((result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION) and targetType == COMBAT_UNIT_TYPE_PLAYER and DATA.roots[abilityId] and hitValue == DATA.roots.duration) then
		CA1.AlertCast(abilityId, nil, hitValue, { -2, 1 })
	elseif (LCA.isVet and result == ACTION_RESULT_DAMAGE and DATA.roots.damage[abilityId]) then
		if (Vars.achState == 0 and not IsAchievementComplete(2370)) then
			CA2.ChatMessage(string.format("|cCC0000%s|r |H1:achievement:2370:0:0|h|h", zo_iconFormatInheritColor(LCA.GetTexture("misc-x"), "100%", "100%")), true)
		end
		Vars.achState = 1
	elseif (result == ACTION_RESULT_EFFECT_GAINED and DATA.spirit.increments[abilityId] and hitValue == 1) then
		Vars.spirits = Vars.spirits + 1
	elseif (result == ACTION_RESULT_EFFECT_FADED and abilityId == DATA.spirit.golden) then
		Vars.spirits = Vars.spirits - 1
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.spirit.ignition) then
		Vars.spirits = 0
		CA2.StatusEnable({
			ownerId = "u20spirit",
			rowLabels = LCA.GetAbilityName(abilityId),
			pollingInterval = 10,
			pollingFunction = self.StatusPoll_SpiritScream,
		})
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.spirit.scream) then
		zo_callLater(CA2.StatusDisable, hitValue)
	elseif (self.PURGEABLE_EFFECTS[abilityId] and LCA.DoesPlayerHaveAoePurgeSlotted()) then
		if (result == ACTION_RESULT_EFFECT_GAINED) then
			CA2.ScreenBorderEnable(0xFFDD0066, nil, "u20purge")
		elseif (result == ACTION_RESULT_EFFECT_FADED) then
			CA2.ScreenBorderDisable("u20purge")
		end
	end
end

CA2.RegisterModule(Module)
