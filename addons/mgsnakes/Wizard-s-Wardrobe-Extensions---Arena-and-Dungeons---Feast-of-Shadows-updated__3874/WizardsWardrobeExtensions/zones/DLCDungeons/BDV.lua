local WW = WizardsWardrobe
WW.zones["BDV"] = {}
local BDV = WW.zones["BDV"]

BDV.name = GetString(WWE_BDV_NAME)
BDV.tag = "BDV"
BDV.icon = "/esoui/art/icons/achievement_u29_dun1_vet_bosses.dds"
BDV.priority = 118
BDV.id = 1228
BDV.node = 437
BDV.category = WW.ACTIVITIES.DLC_DUNGEONS

BDV.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_BDV_BOSS1),
	}, [3] = {
		name = GetString(WWE_BDV_BOSS2),
	}, [4] = {
		name = GetString(WWE_BDV_BOSS3),
	},
}

function BDV.Init()

end

function BDV.Reset()

end

function BDV.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
