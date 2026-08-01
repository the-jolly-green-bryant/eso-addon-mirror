local MP = Mephisto
MP.zones["GD"] = {}
local GD = MP.zones["GD"]

GD.name = GetString(MP_GD_NAME)
GD.tag = "GD"
GD.icon = "/esoui/art/icons/achievement_u35_dun2_vet_bosses.dds"
GD.priority =  125
GD.id = 1361
GD.node = 521

GD.bosses = { [1] = {
		name = GetString(MP_TRASH),
	}, [2] = {
		name = GetString(MP_GD_B1),
	}, [3] = {
		name = GetString(MP_GD_B2),
	}, [4] = {
		name = GetString(MP_GD_B3),
	}, [5] = {
		name = GetString(MP_GD_SCB1),
	}, [6] = {
		name = GetString(MP_GD_SCB2),
	},[7] = {
		name = GetString(MP_GD_SCB3),
	},
}

function GD.Init()

end

function GD.Reset()

end

function GD.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = GD.lookupBosses[bossName]
	MP.LoadSetup(GD, pageId, index, true)
end
