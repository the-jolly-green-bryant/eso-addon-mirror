local WW = WizardsWardrobe
WW.zones["MA"] = {}
local MA = WW.zones["MA"]

MA.name = GetString(WWE_MA_NAME)
MA.tag = "MA"
MA.icon = "esoui/art/icons/achievement_wrothgar_039"
MA.priority = -99
MA.id = 677
MA.node = 250
MA.category = WW.ACTIVITIES.ARENAS

MA.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_MA_BOSS1),
	}, [3] = {
		name = GetString(WWE_MA_BOSS2),
	}, [4] = {
		name = GetString(WWE_MA_BOSS3),
	}, [5] = {
		name = GetString(WWE_MA_BOSS4),
	}, [6] = {
		name = GetString(WWE_MA_BOSS5),
	}, [7] = {
		name = GetString(WWE_MA_BOSS6),
	}, [8] = {
		name = GetString(WWE_MA_BOSS7),
	}, [9] = {
		name = GetString(WWE_MA_BOSS8),
	}, [10] = {
		name = GetString(WWE_MA_BOSS9),
	},
	
}

function MA.Init()

end

function MA.Reset()

end

function MA.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
