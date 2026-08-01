local MP = Mephisto
MP.zones["CT"] = {}
local CT = MP.zones["CT"]

CT.name = GetString(MP_CT_NAME)
CT.tag = "CT"
CT.icon = "/esoui/art/icons/achievement_u27_dun2_vetbosses.dds"
CT.priority = 117
CT.id = 1201
CT.node = 436


CT.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_CT_DREAD_TINDULRA),
	},
	[3] = {
		name = GetString(MP_CT_BLOOD_TWILIGHT),
	},
	[4] = {
		name = GetString(MP_CT_VADUROTH),
	},
	[5] = {
		name = GetString(MP_CT_TALFYG),
	},
	[6] = {
		name = GetString(MP_CT_LADY_THORN),
	},
}

function CT.Init()

end

function CT.Reset()

end

function CT.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = CT.lookupBosses[bossName]
	MP.LoadSetup(CT, pageId, index, true)
end
