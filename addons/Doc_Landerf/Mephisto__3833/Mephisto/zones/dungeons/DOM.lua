local MP = Mephisto
MP.zones["DOM"] = {}
local DOM = MP.zones["DOM"]

DOM.name = GetString(MP_DOM_NAME)
DOM.tag = "DOM"
DOM.icon = "/esoui/art/icons/achievement_depthsofmalatar_vet_bosses.dds"
DOM.priority = 111
DOM.id = 1081
DOM.node = 390

DOM.bosses = {
	[1] = {
		name = GetString(MP_TRASH),
	},
	[2] = {
		name = GetString(MP_DOM_THE_SCAVENGING_MAW),
	},
	[3] = {
		name = GetString(MP_DOM_THE_WEEPING_WOMAN),
	},
	[4] = {
		name = GetString(MP_DOM_DARK_ORB),
	},
	[5] = {
		name = GetString(MP_DOM_KING_NARILMOR),
	},
	[6] = {
		name = GetString(MP_DOM_SYMPHONY_OF_BLADE),
	},
}

function DOM.Init()

end

function DOM.Reset()

end

function DOM.OnBossChange(bossName)
	if #bossName == 0 then
		bossName = GetString(MP_TRASH)
	end

	local pageId = MP.selection.pageId
	local index = DOM.lookupBosses[bossName]
	MP.LoadSetup(DOM, pageId, index, true)
end
