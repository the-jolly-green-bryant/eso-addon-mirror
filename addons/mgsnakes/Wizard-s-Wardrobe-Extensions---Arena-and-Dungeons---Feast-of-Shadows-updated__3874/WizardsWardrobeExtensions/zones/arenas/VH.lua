local WW = WizardsWardrobe
WW.zones["VH"] = {}
local VH = WW.zones["VH"]

VH.name = GetString(WWE_VH_NAME)
VH.tag = "VH"
VH.icon = "esoui/art/icons/u28_arena_flavor_2"
VH.priority = 101
VH.id = 1227
VH.node = 457
VH.category = WW.ACTIVITIES.ARENAS

VH.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_VH_BOSS1),
	}, [3] = {		
		name = GetString(WWE_VH_BOSS2),
	}, [4] = {
		name = GetString(WWE_VH_BOSS3),
	}, [5] = {
		name = GetString(WWE_VH_BOSS4),
	}, [6] = {
		name = GetString(WWE_VH_BOSS5),
	}, [7] = {
		name = GetString(WWE_VH_BOSS6),
	}, [8] = {
		name = GetString(WWE_VH_BOSS7),
	}, [9] = {		
		name = GetString(WWE_VH_BOSS8),
	}, [10] = {
		name = GetString(WWE_VH_BOSS9),
	}, [11] = {
		name = GetString(WWE_VH_BOSS10),
	},
	
}

function VH.Init()

end

function VH.Reset()

end

function VH.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
