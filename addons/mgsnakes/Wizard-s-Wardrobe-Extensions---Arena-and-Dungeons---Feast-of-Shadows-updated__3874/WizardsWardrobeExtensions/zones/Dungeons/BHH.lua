local WW = WizardsWardrobe
WW.zones["BHH"] = {}
local BHH = WW.zones["BHH"]

BHH.name = GetString(WWE_BHH_NAME)
BHH.tag = "BHH"
BHH.icon = "esoui/art/icons/achievement_025"
BHH.priority = 121
BHH.id = 38
BHH.node = 186
BHH.category = WW.ACTIVITIES.DUNGEONS

BHH.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_BHH_BOSS1),
	}, [3] = {
		name = GetString(WWE_BHH_BOSS2),
	}, [4] = {
		name = GetString(WWE_BHH_BOSS3),
	}, [5] = {
		name = GetString(WWE_BHH_BOSS4),
	}, [6] = {
		name = GetString(WWE_BHH_BOSS5),
	}, [7] = {
		name = GetString(WWE_BHH_BOSS6),
	},
}

function BHH.Init()

end

function BHH.Reset()

end

function BHH.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
