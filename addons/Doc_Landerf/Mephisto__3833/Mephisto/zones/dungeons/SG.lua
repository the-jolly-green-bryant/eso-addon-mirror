local MP = Mephisto
MP.zones["SG"] = {}
local SG = MP.zones["SG"]

SG.name = GetString(MP_SG_NAME)
SG.tag = "SG"
SG.icon = "/esoui/art/icons/achievement_u27_dun1_vetbosses.dds"
SG.priority = 116
SG.id = 1197
SG.node = 433

SG.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_SG_EXARCH_KRAGLEN),
	},
	[3] = {
		name = GetString(MP_SG_STONE_BEHEMOTH),
	},
	[4] = {
		name = GetString(MP_SG_ARKASIS_THE_MAD_ALCHEMIST),
	},
}

function SG.Init()

end

function SG.Reset()

end

function SG.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = SG.lookupBosses[bossName]
	MP.LoadSetup(SG, pageId, index, true)
end
