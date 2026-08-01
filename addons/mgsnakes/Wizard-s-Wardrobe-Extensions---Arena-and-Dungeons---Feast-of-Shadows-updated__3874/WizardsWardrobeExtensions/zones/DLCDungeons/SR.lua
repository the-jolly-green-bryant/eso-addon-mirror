local WW = WizardsWardrobe
WW.zones["SR"] = {}
local SR = WW.zones["SR"]

SR.name = GetString(WWE_SR_NAME)
SR.tag = "SR"
SR.icon = "/esoui/art/icons/u33_dun2_vet_bosses.dds"
SR.priority = 123
SR.id = 1302
SR.node = 498
SR.category = WW.ACTIVITIES.DLC_DUNGEONS

SR.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	}, [2] = {
		name = GetString(WWE_SR_BOSS1),
	}, [3] = {
		name = GetString(WWE_SR_BOSS2),
	}, [4] = {
		name = GetString(WWE_SR_BOSS3),
	},
}

function SR.Init()

end

function SR.Reset()

end

function SR.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
