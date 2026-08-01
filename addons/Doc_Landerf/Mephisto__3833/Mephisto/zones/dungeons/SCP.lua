local MP = Mephisto
MP.zones["SCP"] = {}
local SCP = MP.zones["SCP"]

SCP.name = GetString(MP_SCP_NAME)
SCP.tag = "SCP"
SCP.icon = "/esoui/art/icons/achievement_scalecaller_veteran.dds"
SCP.priority = 107
SCP.id = 1010
SCP.node = 363

SCP.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_SCP_ORZUN_THE_FOUL_SMELLING),
	},
	[3] = {
		name = GetString(MP_SCP_DOYLEMISH_IRONHEARTH),
	},
	[4] = {
		name = GetString(MP_SCP_MATRIACH_ALDIS),
	},
	[5] = {
		name = GetString(MP_SCP_PLAGUE_CONCOCTER_MORTIEU),
	},
	[6] = {
		name = GetString(MP_SCP_ZAAN_THE_SCALECALLER),
	},
}

function SCP.Init()

end

function SCP.Reset()

end

function SCP.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = SCP.lookupBosses[bossName]
	MP.LoadSetup(SCP, pageId, index, true)
end
