local MP = Mephisto
MP.zones["FV"] = {}
local FV = MP.zones["FV"]

FV.name = GetString(MP_FV_NAME)
FV.tag = "FV"
FV.icon = "/esoui/art/icons/achievement_frostvault_vet_bosses.dds"
FV.priority = 110
FV.id = 1080
FV.node = 389

FV.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_FV_ICESTALKER),
	},
	[3] = {
		name = GetString(MP_FV_WARLORD_TZOGVIN),
	},
	[4] = {
		name = GetString(MP_FV_VAULT_PROTECTOR),
	},
	[5] = {
		name = GetString(MP_FV_RIZZUK_BONECHILL),
	},
	[6] = {
		name = GetString(MP_FV_THE_STONEKEEPER),
	},
}

function FV.Init()

end

function FV.Reset()

end

function FV.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = FV.lookupBosses[bossName]
	MP.LoadSetup(FV, pageId, index, true)
end
