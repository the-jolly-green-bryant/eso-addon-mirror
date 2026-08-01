local WW = WizardsWardrobe
WW.zones["CA"] = {}
local CA = WW.zones["CA"]

CA.name = GetString(WWD_CA_NAME)
CA.tag = "CA"
CA.icon = "/esoui/art/icons/u33_dun1_vet_bosses.dds"
CA.priority =  122
CA.id = 1301
CA.node = 497
CA.category = WW.ACTIVITIES.DLC_DUNGEONS

CA.bosses = { [1] = {
		name = GetString(WWD_TRASH),
	},[2] = {
		name = GetString(WWD_CA_B1),
	},[3] = {
		name = GetString(WWD_CA_B2),
	},[4] = {
		name = GetString(WWD_CA_B3),
	},
}

function CA.Init()

end

function CA.Reset()

end

function CA.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
