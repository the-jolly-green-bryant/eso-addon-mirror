local MP = Mephisto
MP.zones["FL"] = {}
local FL = MP.zones["FL"]

FL.name = GetString(MP_FL_NAME)
FL.tag = "FL"
FL.icon = "/esoui/art/icons/achievement_fanglairpeak_veteran.dds"
FL.priority = 106
FL.id = 1009
FL.node = 341

FL.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_FL_LIZABET_CHARNIS),
	},
	[3] = {
		name = GetString(MP_FL_CADAVEROUS_BEAR),
	},
	[4] = {
		name = GetString(MP_FL_CALUURION),
	},
	[5] = {
		name = GetString(MP_FL_ULFNOR),
	},
	[6] = {
		name = GetString(MP_FL_THURVOKUN),
	},
}

function FL.Init()

end

function FL.Reset()

end

function FL.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = FL.lookupBosses[bossName]
	MP.LoadSetup(FL, pageId, index, true)
end
