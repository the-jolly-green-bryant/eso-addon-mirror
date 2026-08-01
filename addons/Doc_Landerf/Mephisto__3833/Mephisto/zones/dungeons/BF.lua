local MP = Mephisto
MP.zones["BF"] = {}
local BF = MP.zones["BF"]

BF.name = GetString(MP_BF_NAME)
BF.tag = "BF"
BF.icon = "/esoui/art/icons/achievement_update15_002.dds"
BF.priority = 105
BF.id = 973
BF.node = 326

BF.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_BF_MATHGAMAIN),
	},
	[3] = {
		name = GetString(MP_BF_CAILLAOIFE),
	},
	[4] = {
		name = GetString(MP_BF_STONEHEARTH),
	},
	[5] = {
		name = GetString(MP_BF_GALCHOBHAR),
	},
	[6] = {
		name = GetString(MP_BF_GHERIG_BULLBLOOD),
	},
	[7] = {
		name = GetString(MP_BF_EARTHGORE_AMALGAM),
	},
}

function BF.Init()

end

function BF.Reset()

end

function BF.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = BF.lookupBosses[bossName]
	MP.LoadSetup(BF, pageId, index, true)
end
