local WW = WizardsWardrobe
WW.zones["LOM"] = {}
local LOM = WW.zones["LOM"]

LOM.name = GetString(WWD_LOM_NAME)
LOM.tag = "LOM"
LOM.icon = "/esoui/art/icons/achievement_u23_dun2_flavorboss5b.dds"
LOM.priority = 112
LOM.id = 1123
LOM.node = 398
LOM.category = WW.ACTIVITIES.DLC_DUNGEONS

LOM.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_LOM_SELENE),
	},
	[3] = {
		name = GetString(WWD_LOM_AZUREBLIGHT_LURCHER),
	},
	[4] = {
		name = GetString(WWD_LOM_AZUREBLIGHT_CANCROID),
	},
	[5] = {
		name = GetString(WWD_LOM_MAARSELOK),
	},
	[6] = {
		name = GetString(WWD_LOM_MAARSELOK_BOSS),
	},
}

LOM.LOCATIONS = {
	FIRST = {
		x1 = 101000, -- porte entrée selene
		x2 = 109000, -- porte sortie selene
		z1 = 27000, -- Z1 corespond pas
		z2 = 35000, -- Z2 corespond pas
	},
	SECOND = {
		x1 = 134000,
		x2 = 143000,
		z1 = 59000, -- Z1 corespond pas
		z2 = 68000, -- Z2 corespond pas
	},
	THIRD = {
		x1 = 70000,
		x2 = 79000,
		z1 = 104300, -- Z1 corespond pas
		z2 = 114200, -- Z2 corespond pas
	},
	FORTH = {
		x1 = 83000,
		x2 = 98000,
		z1 = 141000, -- Z1 corespond pas
		z2 = 150000, -- Z2 corespond pas
	},
	FIFTH = {
		x1 = 128000, --porte entrée
		x2 = 140000, --boss
		z1 = 137000, -- Z1 corespond pas
		z2 = 144000, -- Z2 corespond pas
	}
}

function LOM.Init()

end

function LOM.Reset()

end


function LOM.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end

