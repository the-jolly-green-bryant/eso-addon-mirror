local WW = WizardsWardrobe
WW.zones["CA"] = {}
local CA = WW.zones["CA"]

CA.name = GetString(WWE_CA_NAME)
CA.tag = "CA"
CA.icon = "/esoui/art/icons/u33_dun1_vet_bosses.dds"
CA.priority =  122
CA.id = 1301
CA.node = 497
CA.category = WW.ACTIVITIES.DLC_DUNGEONS

CA.bosses = { [1] = {
		name = GetString(WWE_TRASH),
	},[2] = {
		name = GetString(WWE_CA_BOSS1),
	},[3] = {
		name = GetString(WWE_CA_BOSS2),
	},[4] = {
		name = GetString(WWE_CA_BOSS3),
	},
}

function CA.Init()

end

function CA.Reset()

end

function CA.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
