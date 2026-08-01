local MP = Mephisto
MP.zones["BV"] = {}
local BV = MP.zones["BV"]

BV.name = GetString(MP_BV_NAME)
BV.tag = "BV"
BV.icon = "/esoui/art/icons/achievement_u41_dun2_vet_bosses.dds"
BV.priority =  128
BV.id = 1471
BV.node = 565

BV.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_BV_B1),
	},
	[3] = {
		name = GetString(MP_BV_B2),
	},
	[4] = {
		name = GetString(MP_BV_B3),
	},
}

function BV.Init()

end

function BV.Reset()

end

function BV.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = BV.lookupBosses[bossName]
	MP.LoadSetup(BV, pageId, index, true)
end
