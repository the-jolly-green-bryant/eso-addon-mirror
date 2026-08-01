local LCA = LibCombatAlerts
local CA1 = CombatAlerts
local CA2 = CombatAlerts2
local Module = CA_Module:Subclass()

Module.ID = "CA_M_U34"
Module.NAME = CA2.GenerateModuleName(34, 1344)
Module.AUTHOR = "@code65536"
Module.ZONES = {
	1344, -- Dreadsail Reef
}

function Module:TaleriaClockLabels( )
	local X, Y, ELEVATION = 169780, 30040, 36126
	local HOUR_ANGLE = ZO_TWO_PI / 12

	for i = 1, 12 do
		local angle = (9 - i) * HOUR_ANGLE
		CA2.WorldTexturePlace({
			pos = { X - 2100 * math.sin(angle), ELEVATION, Y - 2100 * math.cos(angle) },
			texture = "world-circle-bordered",
			size = 250,
			color = 0x33CCCC33,
			groundAngle = angle + ZO_PI,
			groundOverlay = {
				texture = "world-num-" .. i,
				size = 250,
				color = 0xFFFFFFCC,
			},
		})
	end
end

--CA2.RegisterModule(Module)
