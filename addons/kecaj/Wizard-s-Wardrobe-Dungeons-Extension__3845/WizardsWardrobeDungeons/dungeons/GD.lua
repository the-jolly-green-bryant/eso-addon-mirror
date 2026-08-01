local WW = WizardsWardrobe
WW.zones["GD"] = {}
local GD = WW.zones["GD"]

GD.name = GetString(WWD_GD_NAME)
GD.tag = "GD"
GD.icon = "/esoui/art/icons/achievement_u35_dun2_vet_bosses.dds"
GD.priority =  125
GD.id = 1361
GD.node = 521
GD.category = WW.ACTIVITIES.DLC_DUNGEONS

GD.bosses = { [1] = {
		name = GetString(WWD_TRASH),
	}, [2] = {
		name = GetString(WWD_GD_B1),
	}, [3] = {
		name = GetString(WWD_GD_B2),
	}, [4] = {
		name = GetString(WWD_GD_B3),
	},
}

function GD.Init()

end

function GD.Reset()

end

function GD.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
