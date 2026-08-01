local MP = Mephisto
MP.zones["COS"] = {}
local COS = MP.zones["COS"]

COS.name = GetString(MP_COS_NAME)
COS.tag = "COS"
COS.icon = "/esoui/art/icons/achievement_update11_dungeons_034.dds"
COS.priority = 103
COS.id = 848
COS.node = 261

COS.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_COS_KHEPHIDAEN),
	},
	[3] = {
		name = GetString(MP_COS_DRANOS_VELEADOR),
	},
	[4] = {
		name = GetString(MP_COS_VELIDRETH),
	},
}

function COS.Init()

end

function COS.Reset()

end

function COS.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = COS.lookupBosses[bossName]
	MP.LoadSetup(COS, pageId, index, true)
end
