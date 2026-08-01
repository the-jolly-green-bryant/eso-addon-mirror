local WW = WizardsWardrobe
WW.zones["DOM"] = {}
local DOM = WW.zones["DOM"]

DOM.name = GetString(WWE_DOM_NAME)
DOM.tag = "DOM"
DOM.icon = "/esoui/art/icons/achievement_depthsofmalatar_vet_bosses.dds"
DOM.priority = 111
DOM.id = 1081
DOM.node = 390
DOM.category = WW.ACTIVITIES.DLC_DUNGEONS

DOM.bosses = {
	[1] = {
		name = GetString(WWE_TRASH),
	},
	[2] = {
		name = GetString(WWE_DOM_BOSS1),
	},
	[3] = {
		name = GetString(WWE_DOM_BOSS2),
	},
	[4] = {
		name = GetString(WWE_DOM_BOSS3),
	},
	[5] = {
		name = GetString(WWE_DOM_BOSS4),
	},
	[6] = {
		name = GetString(WWE_DOM_BOSS5),
	},
}

function DOM.Init()

end

function DOM.Reset()

end

function DOM.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
