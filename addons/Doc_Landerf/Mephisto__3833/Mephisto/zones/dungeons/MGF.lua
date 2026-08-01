local MP = Mephisto
MP.zones["MGF"] = {}
local MGF = MP.zones["MGF"]

MGF.name = GetString(MP_MGF_NAME)
MGF.tag = "MGF"
MGF.icon = "/esoui/art/icons/achievement_u23_dun1_meta.dds"
MGF.priority = 113
MGF.id = 1122
MGF.node = 391

MGF.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_MGF_RISEN_RUINS),
	},
	[3] = {
		name = GetString(MP_MGF_DRO_ZAKAR),
	},
	[4] = {
		name = GetString(MP_MGF_KUJO_KETHBA),
	},
	[5] = {
		name = GetString(MP_MGF_NISAAZDA),
	},
	[6] = {
		name = GetString(MP_MGF_GRUNDWULF),
	},
}

function MGF.Init()

end

function MGF.Reset()

end

function MGF.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = MGF.lookupBosses[bossName]
	MP.LoadSetup(MGF, pageId, index, true)
end
