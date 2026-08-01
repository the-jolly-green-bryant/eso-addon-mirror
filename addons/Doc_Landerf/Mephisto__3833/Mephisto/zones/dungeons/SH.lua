local MP = Mephisto
MP.zones["SH"] = {}
local SH = MP.zones["SH"]

SH.name = GetString(MP_SH_NAME)
SH.tag = "SH"
SH.icon = "/esoui/art/icons/u37_dun2_vet_bosses.dds"
SH.priority =  127
SH.id = 1390
SH.node = 532

SH.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_SH_B1),
	},
	[3] = {
		name = GetString(MP_SH_B2),
	},
	[4] = {
		name = GetString(MP_SH_B3),
	},
}

function SH.Init()

end

function SH.Reset()

end

function SH.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = SH.lookupBosses[bossName]
	MP.LoadSetup(SH, pageId, index, true)
end
