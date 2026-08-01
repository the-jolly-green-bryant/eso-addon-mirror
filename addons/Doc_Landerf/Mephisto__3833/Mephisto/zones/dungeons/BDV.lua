local MP = Mephisto
MP.zones["BDV"] = {}
local BDV = MP.zones["BDV"]

BDV.name = GetString(MP_BDV_NAME)
BDV.tag = "BDV"
BDV.icon = "/esoui/art/icons/achievement_u29_dun1_vet_bosses.dds"
BDV.priority = 118
BDV.id = 1228
BDV.node = 437

BDV.bosses = { [1] = {
		name = GetString(MP_TRASH),
	}, [2] = {
		name = GetString(MP_BDV_KINRAS_IRONEYE),
	}, [3] = {
		name = GetString(MP_BDV_CAPTAIN_GEMINUS),
	}, [4] = {
		name = GetString(MP_BDV_PYROTURGE_ENCRATIS),
	}, [5] = {
		name = GetString(MP_BDV_AVATAR_OF_ZEAL),
	}, [6] = {
		name = GetString(MP_BDV_AVATAR_OF_VIGOR),
	}, [7] = {
		name = GetString(MP_BDV_AVATAR_OF_FORTITUDE),
	}, [8] = {
		name = GetString(MP_BDV_SENTINEL_AKSALAZ),
	},
}

function BDV.Init()

end

function BDV.Reset()

end

function BDV.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = BDV.lookupBosses[bossName]
	MP.LoadSetup(BDV, pageId, index, true)
end
