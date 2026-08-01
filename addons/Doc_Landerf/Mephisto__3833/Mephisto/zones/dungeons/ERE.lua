local MP = Mephisto
MP.zones["ERE"] = {}
local ERE = MP.zones["ERE"]

ERE.name = GetString(MP_ERE_NAME)
ERE.tag = "ERE"
ERE.icon = "/esoui/art/icons/achievement_u35_dun1_vet_bosses.dds"
ERE.priority =  124
ERE.id = 1360
ERE.node = 520

ERE.bosses = { [1] = {
		name = GetString(MP_TRASH),
	}, [2] = {
		name = GetString(MP_ERE_B1),
	}, [3] = {
		name = GetString(MP_ERE_B2),
	}, [4] = {
		name = GetString(MP_ERE_B3),
	}, [5] = {
		name = GetString(MP_ERE_SCB1),
	}, [6] = {
		name = GetString(MP_ERE_SCB2),
	},[7] = {
		name = GetString(MP_ERE_SCB3),
	},
}

function ERE.Init()

end

function ERE.Reset()

end

function ERE.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = ERE.lookupBosses[bossName]
	MP.LoadSetup(ERE, pageId, index, true)
end
