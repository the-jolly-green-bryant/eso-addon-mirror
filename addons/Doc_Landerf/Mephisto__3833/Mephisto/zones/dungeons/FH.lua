local MP = Mephisto
MP.zones["FH"] = {}
local FH = MP.zones["FH"]

FH.name = GetString(MP_FH_NAME)
FH.tag = "FH"
FH.icon = "/esoui/art/icons/achievement_update15_008.dds"
FH.priority = 104
FH.id = 974
FH.node = 332

FH.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_FH_MORRIGH_BULLBLOOD),
	},
	[3] = {
		name = GetString(MP_FH_SIEGE_MAMMOTH),
	},
	[4] = {
		name = GetString(MP_FH_CERNUNNON),
	},
	[5] = {
		name = GetString(MP_FH_DEATHLORD_BJARFRUD_SKJORALMOR),
	},
	[6] = {
		name = GetString(MP_FH_DOMIHAUS_THE_BLOODY_HORNED),
	},
}

function FH.Init()

end

function FH.Reset()

end

function FH.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = FH.lookupBosses[bossName]
	MP.LoadSetup(FH, pageId, index, true)
end
