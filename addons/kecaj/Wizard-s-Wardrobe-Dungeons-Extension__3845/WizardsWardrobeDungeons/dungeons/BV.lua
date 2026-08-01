local WW = WizardsWardrobe
WW.zones["BV"] = {}
local BV = WW.zones["BV"]

BV.name = GetString(WWD_BV_NAME)
BV.tag = "BV"
BV.icon = "/esoui/art/icons/achievement_u41_dun2_vet_bosses.dds"
BV.priority =  128
BV.id = 1471
BV.node = 565
BV.category = WW.ACTIVITIES.DLC_DUNGEONS

BV.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_BV_B1),
	},
	[3] = {
		name = GetString(WWD_BV_B2),
	},
	[4] = {
		name = GetString(WWD_BV_B3),
	},
}

function BV.Init()

end

function BV.Reset()

end

function BV.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
