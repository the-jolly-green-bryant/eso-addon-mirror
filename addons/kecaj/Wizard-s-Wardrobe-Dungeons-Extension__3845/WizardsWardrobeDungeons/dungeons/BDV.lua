local WW = WizardsWardrobe
WW.zones["BDV"] = {}
local BDV = WW.zones["BDV"]

BDV.name = GetString(WWD_BDV_NAME)
BDV.tag = "BDV"
BDV.icon = "/esoui/art/icons/achievement_u29_dun1_vet_bosses.dds"
BDV.priority = 118
BDV.id = 1228
BDV.node = 437
BDV.category = WW.ACTIVITIES.DLC_DUNGEONS

BDV.bosses = { [1] = {
		name = GetString(WWD_TRASH),
	}, [2] = {
		name = GetString(WWD_BDV_KINRAS_IRONEYE),
	}, [3] = {
		name = GetString(WWD_BDV_CAPTAIN_GEMINUS),
	}, [4] = {
		name = GetString(WWD_BDV_PYROTURGE_ENCRATIS),
	},
}

function BDV.Init()

end

function BDV.Reset()

end

function BDV.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
