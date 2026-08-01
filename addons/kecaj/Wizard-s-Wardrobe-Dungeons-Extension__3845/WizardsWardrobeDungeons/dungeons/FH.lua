local WW = WizardsWardrobe
WW.zones["FH"] = {}
local FH = WW.zones["FH"]

FH.name = GetString(WWD_FH_NAME)
FH.tag = "FH"
FH.icon = "/esoui/art/icons/achievement_update15_008.dds"
FH.priority = 104
FH.id = 974
FH.node = 332
FH.category = WW.ACTIVITIES.DLC_DUNGEONS

FH.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_FH_MORRIGH_BULLBLOOD),
	},
	[3] = {
		name = GetString(WWD_FH_SIEGE_MAMMOTH),
	},
	[4] = {
		name = GetString(WWD_FH_CERNUNNON),
	},
	[5] = {
		name = GetString(WWD_FH_DEATHLORD_BJARFRUD_SKJORALMOR),
	},
	[6] = {
		name = GetString(WWD_FH_DOMIHAUS_THE_BLOODY_HORNED),
	},
}

function FH.Init()

end

function FH.Reset()

end

function FH.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
