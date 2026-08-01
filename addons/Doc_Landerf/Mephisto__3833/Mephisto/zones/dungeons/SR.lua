local MP = Mephisto
MP.zones["SR"] = {}
local SR = MP.zones["SR"]

SR.name = GetString(MP_SR_NAME)
SR.tag = "SR"
SR.icon = "/esoui/art/icons/u33_dun2_vet_bosses.dds"
SR.priority = 123
SR.id = 1302
SR.node = 498

SR.bosses = { [1] = {
		name = GetString(MP_TRASH),
	}, [2] = {
		name = GetString(MP_SR_B1),
	}, [3] = {
		name = GetString(MP_SR_B2),
	}, [4] = {
		name = GetString(MP_SR_B3),
	}, [5] = {
		name = GetString(MP_SR_SCB1),
	}, [6] = {
		name = GetString(MP_SR_SCB2),
	},[7] = {
		name = GetString(MP_SR_SCB3),
	},
}

function SR.Init()

end

function SR.Reset()

end

function SR.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = SR.lookupBosses[bossName]
	MP.LoadSetup(SR, pageId, index, true)
end
