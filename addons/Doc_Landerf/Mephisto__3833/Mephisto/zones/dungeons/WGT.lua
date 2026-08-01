local MP = Mephisto
MP.zones["WGT"] = {}
local WGT = MP.zones["WGT"]

WGT.name = GetString(MP_WGT_NAME)
WGT.tag = "WGT"
WGT.icon = "/esoui/art/icons/achievement_ic_027_heroic.dds"
WGT.priority = 100
WGT.id = 688
WGT.node = 247

WGT.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_WGT_THE_ADJUDICATOR),
	},
	[3] = {
		name = GetString(MP_WGT_THE_ADJUDICATOR),
	},
	[4] = {
		name = GetString(MP_WGT_THE_PLANAR_INHIBITOR),
	},
	[5] = {
		name = GetString(MP_WGT_MOLAG_KENA),
	},
}

function WGT.Init()

end

function WGT.Reset()

end

function WGT.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = WGT.lookupBosses[bossName]
	MP.LoadSetup(WGT, pageId, index, true)
end
