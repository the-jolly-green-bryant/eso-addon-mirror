local WW = WizardsWardrobe
WW.zones["FV"] = {}
local FV = WW.zones["FV"]

FV.name = GetString(WWD_FV_NAME)
FV.tag = "FV"
FV.icon = "/esoui/art/icons/achievement_frostvault_vet_bosses.dds"
FV.priority = 110
FV.id = 1080
FV.node = 389
FV.category = WW.ACTIVITIES.DLC_DUNGEONS

FV.bosses = {
	[1] = {
		name = GetString(WWD_TRASH),
	},
	[2] = {
		name = GetString(WWD_FV_ICESTALKER),
	},
	[3] = {
		name = GetString(WWD_FV_WARLORD_TZOGVIN),
	},
	[4] = {
		name = GetString(WWD_FV_VAULT_PROTECTOR),
	},
	[5] = {
		name = GetString(WWD_FV_RIZZUK_BONECHILL),
	},
	[6] = {
		name = GetString(WWD_FV_THE_STONEKEEPER),
	},
}

function FV.Init()

end

function FV.Reset()

end

function FV.OnBossChange(bossName)
	WW.conditions.OnBossChange(bossName)
end
