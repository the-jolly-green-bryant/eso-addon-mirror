local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_U46"
Module.NAME = CA2.GenerateModuleName(46, 1548)
Module.AUTHOR = "@code65536"
Module.ZONES = {
	1548, -- Ossein Cage
}

Module.STRINGS = {
	-- Extracted
}

Module.DATA = {
	barrage = 238800,
	carrion = 240708,
	carrionB2 = 241089,
	carrionThreshold = {
		[240708] = 9,
		[241089] = 5,
	},
	etherealBurst = 236466,
	twinsHeavyProjectile = {
		[233750] = true, -- Jyn Incinerate PROJ
		[233756] = true, -- Skor Incinerate PROJ
	},
	stricken = 235594,
	blaze = 235356,
}
local DATA = Module.DATA
local Vars

local Identifier = function(x) return Module.ID .. x end

function Module:Initialize( )
	self.MONITOR_UNIT_IDS = true

	self.TIMER_ALERTS_LEGACY = {
		-- Cast time 3000, actual windup time 2567
		[233596] = { 0, 0, false, { 1, 0, 0.6, 0.8 }, offset = -433, cutthroat = true }, -- Spark Smash
		[233606] = { 0, 0, false, { 1, 0, 0.6, 0.8 }, offset = -433, cutthroat = true }, -- Blazing Smash

		-- Cast time 3000, actual windup time 1650, projectile ranges from 100 to 700 (using 150)
		[233720] = { 0, 0, false, { 1, 0, 0.6, 0.8 }, offset = -1200, cutthroat = true }, -- Spark Surge Bolt
		[233751] = { 0, 0, false, { 1, 0, 0.6, 0.8 }, offset = -1200, cutthroat = true }, -- Forge Fire Bolt

		[235146] = { -2, 2, offset = 100 }, -- Shadow Strike
		[236458] = { -3, 2 }, -- Potent Ethereal Burst
		[236569] = { -2, 1, vet = true }, -- Spectral Revenge
		[245273] = { -2, 1 }, -- Bone Saw
	}

	self.AOE_ALERTS = {
		-- { alert_duration, exclude_tanks }
		[232620] = { 400, false }, -- Ground Plague
	}

	self.vars = {
		lastBarrage = 0,
	}
	Vars = self.vars

	-- Deconflict OCH timers
	zo_callLater(function( )
		if (CA2.IsModuleLoaded("OCH_U46")) then
			local ochTimers = CA2.GetModule("OCH_U46").TIMER_ALERTS_LEGACY
			if (ochTimers) then
				for abilityId in pairs(self.TIMER_ALERTS_LEGACY) do
					ochTimers[abilityId] = nil
				end
			end
		end
	end, 1000)

	self.CarrionUpdate = function( _, changeType, _, _, unitTag, _, endTime, stackCount, _, _, _, _, _, _, unitId, abilityId )
		if (self.panelMode ~= "carrion") then
			if (changeType == EFFECT_RESULT_GAINED) then
				self:TogglePanelMode("carrion")
			else
				return
			end
		end

		if (changeType == EFFECT_RESULT_FADED) then
			stackCount = 0
		end

		local max = DATA.carrionThreshold[abilityId]

		if (stackCount > 0) then
			local remaining = max - stackCount
			local ratio = zo_clamp(remaining / max, 0, 1)
			CA2.GroupPanelUpdate(unitTag, nil, LCA.PackRGBA(LCA.HSLToRGB(ratio / 3, 1, 0.5, 0.8)), stackCount)
		else
			-- Clear the cell
			CA2.GroupPanelUpdate(unitTag)
		end
	end

	self.BlazeUpdate = function( _, changeType, _, _, unitTag, _, endTime, stackCount, _, _, _, _, _, _, unitId, abilityId )
		if (self.panelMode ~= "blaze") then
			if (changeType == EFFECT_RESULT_GAINED) then
				self:TogglePanelMode("blaze")
			else
				return
			end
		end

		if (changeType == EFFECT_RESULT_GAINED) then
			CA2.GroupPanelUpdate(unitTag, nil, 0x3399FFFF)
		elseif (changeType == EFFECT_RESULT_FADED) then
			CA2.GroupPanelUpdate(unitTag)
		end
	end
end

function Module:PostLoad( )
	self:TogglePanelMode("carrion")
	EVENT_MANAGER:RegisterForEvent(Identifier("CARRION"), EVENT_EFFECT_CHANGED, self.CarrionUpdate)
	EVENT_MANAGER:AddFilterForEvent(Identifier("CARRION"), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, DATA.carrion)
	EVENT_MANAGER:AddFilterForEvent(Identifier("CARRION"), EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

	EVENT_MANAGER:RegisterForEvent(Identifier("CARRION_B2"), EVENT_EFFECT_CHANGED, self.CarrionUpdate)
	EVENT_MANAGER:AddFilterForEvent(Identifier("CARRION_B2"), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, DATA.carrionB2)
	EVENT_MANAGER:AddFilterForEvent(Identifier("CARRION_B2"), EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")

	EVENT_MANAGER:RegisterForEvent(Identifier("BLAZE"), EVENT_EFFECT_CHANGED, self.BlazeUpdate)
	EVENT_MANAGER:AddFilterForEvent(Identifier("BLAZE"), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, DATA.blaze)
	EVENT_MANAGER:AddFilterForEvent(Identifier("BLAZE"), EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

function Module:PreUnload( )
	EVENT_MANAGER:UnregisterForEvent(Identifier("CARRION"), EVENT_EFFECT_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(Identifier("CARRION_B2"), EVENT_EFFECT_CHANGED)
	EVENT_MANAGER:UnregisterForEvent(Identifier("BLAZE"), EVENT_EFFECT_CHANGED)
	CA2.GroupPanelDisable()
end

function Module:PreStartListening( )
end

function Module:PostStopListening( )
end

function Module:ProcessCombatEvents( result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow )
	-- Mini Boss 1
	if (result == ACTION_RESULT_BEGIN and abilityId == DATA.barrage) then
		local currentTime = GetGameTimeMilliseconds()
		if (currentTime - Vars.lastBarrage > hitValue) then
			Vars.lastBarrage = currentTime
			CA1.AlertCast(abilityId, nil, hitValue, { -3, 0, false, { 0.7, 0.3, 1, 0.3 }, { 0.7, 0.3, 1, 0.7 } })
		end

	-- Boss 1
	elseif (result == ACTION_RESULT_BEGIN and abilityId == DATA.etherealBurst and targetType == COMBAT_UNIT_TYPE_PLAYER and not LCA.isTank) then
		CA1.AlertCast(abilityId, sourceName, 800, { 800, 1 })

	-- Boss 2
	elseif (result == ACTION_RESULT_EFFECT_GAINED and targetType == COMBAT_UNIT_TYPE_PLAYER and hitValue > 100 and DATA.twinsHeavyProjectile[abilityId]) then
		CA2.UpdateNightbladeCutthroatExclusionStopTime(GetGameTimeMilliseconds() + hitValue)

	-- Boss 3
	elseif (result == ACTION_RESULT_EFFECT_GAINED_DURATION and abilityId == DATA.stricken and (targetType == COMBAT_UNIT_TYPE_PLAYER or LCA.DoesPlayerHaveTauntSlotted())) then
		local _, name = LCA.IdentifyGroupUnitIdWithRole(targetUnitId, true)
		CA1.Alert(LCA.GetAbilityName(abilityId), name, 0xCC3399FF, SOUNDS.CHAMPION_POINTS_COMMITTED, 2000)
	end
end

function Module:TogglePanelMode( mode )
	self.panelMode = mode
	if (CA2.GroupPanelIsEnabled()) then
		CA2.GroupPanelDisable()
	end
	CA2.GroupPanelEnable({
		headerText = LCA.GetAbilityName(DATA[mode]),
		statWidth = 48,
		colorStat = 0x66CCFFFF,
		useUnitId = false,
		useRange = false,
	})
end

CA2.RegisterModule(Module)
