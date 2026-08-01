BetterScoreboard = {}
local bs = BetterScoreboard
-- Written by M0R_Gaming

bs.name = "BetterScoreboard"
bs.scores = {}
bs.queues = {}
bs.vars = {}

local classIcons = {
	"esoui/art/icons/class/gamepad/gp_class_dragonknight.dds",
	"esoui/art/icons/class/gamepad/gp_class_sorcerer.dds",
	"esoui/art/icons/class/gamepad/gp_class_nightblade.dds",
	"esoui/art/icons/class/gamepad/gp_class_warden.dds",
	"esoui/art/icons/class/gamepad/gp_class_necromancer.dds",
	"esoui/art/icons/class/gamepad/gp_class_templar.dds"
}

classIcons[117] = "esoui/art/icons/class/gamepad/gp_class_arcanist.dds"


local function updateScore(i, roundIndex, showAggregate)
	local damage = 0
	local heal = 0
	if not showAggregate then -- to show aggrigate its a seperate function, instead of a paramater for some reason
		damage = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_DAMAGE_DONE, roundIndex)
		heal = GetScoreboardEntryScoreByType(i, SCORE_TRACKER_TYPE_HEALING_DONE, roundIndex)
	else
		damage = GetBattlegroundCumulativeScoreForScoreboardEntryByType(i, SCORE_TRACKER_TYPE_DAMAGE_DONE, roundIndex)
		heal = GetBattlegroundCumulativeScoreForScoreboardEntryByType(i, SCORE_TRACKER_TYPE_HEALING_DONE, roundIndex)
	end
	

	damage = string.format("%sk",math.floor(damage/1000))
	heal = string.format("%sk",math.floor(heal/1000))

	if damage and bs.scores[i] then
		bs.scores[i].damage:SetText(damage)
	end
	if heal and bs.scores[i] then
		bs.scores[i].heal:SetText(heal)
	end
end


local function updateRow(row)
	local charName = zo_strformat(SI_PLAYER_NAME, row.data.characterName)
	local displayName = zo_strformat(SI_PLAYER_NAME, row.data.displayName)
	local formattedName = ""
	
	if ZO_ShouldPreferUserId() then
		formattedName = string.format("%s (%s)", displayName, charName)
	else
		formattedName = string.format("%s (%s)", charName, displayName)
	end
	row.nameLabel:SetText(formattedName)


	local classId = GetScoreboardEntryClassId(row.data.entryIndex)
	row.classIcon:SetTexture(classIcons[classId])



	if row.data.isPlaceholderEntry then -- new bgs have placeholders
		row.nameLabel:SetText("")
		row.classIcon:SetTexture("/esoui/art/icons/heraldrycrests_misc_blank_01.dds") -- blank texture
		row.heal:SetText("")
		row.damage:SetText("")
	end
end



SecurePostHook(ZO_Battleground_Scoreboard_Player_Row_Object, "UpdateRow", updateRow)

SecurePostHook(ZO_Battleground_Scoreboard_Player_Row_Object, "Initialize", function(self, row)
	local rowName = row:GetName()
	local metalScore = row:GetNamedChild("MedalScore")
	local nameLabel = row:GetNamedChild("NameLabel")

	local damage = CreateControl(rowName.."DamageScore",row,CT_LABEL)
	local heal = CreateControl(rowName.."HealScore",row,CT_LABEL)
	heal:SetAnchor(LEFT,metalScore,RIGHT,15,0,0)
	damage:SetAnchor(LEFT,metalScore,RIGHT,15,0,0)
	heal:SetTransformOffsetY(15)
	damage:SetTransformOffsetY(-5)
	heal:SetColor(1,0.85,0)
	damage:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_18)|soft-shadow-thin")
	heal:SetFont("$(GAMEPAD_MEDIUM_FONT)|$(GP_18)|soft-shadow-thin")

	local classIcon = CreateControl(rowName.."ClassIcon",row,CT_TEXTURE)
	classIcon:SetAnchor(RIGHT,nameLabel,LEFT,-15,0,0)
	classIcon:SetDimensions(32,32)
	classIcon:SetDrawLevel(6)


	self.damage = damage
	self.heal = heal
	self.classIcon = classIcon
end)



SecurePostHook(BATTLEGROUND_SCOREBOARD_FRAGMENT, "UpdateAll", function(self)
	local showAggregate = BATTLEGROUND_SCOREBOARD_FRAGMENT:ShouldShowAggregateScores()
	local roundIndex = showAggregate and GetCurrentBattlegroundRoundIndex() or BATTLEGROUND_SCOREBOARD_FRAGMENT.viewedRound



	-- when the stuff updates, reload the row list as things prob changed
	bs.scores = {}
	for i,v in pairs(self.playerEntryData) do
		bs.scores[v.entryIndex] = v.rowObject
		updateRow(v.rowObject)
		updateScore(v.entryIndex, roundIndex, showAggregate)
	end
end)




SecurePostHook(ZO_Battleground_Scoreboard_Player_Row_Object, "SetupOnAcquire", function(self, panel, poolKey, data)
	local showAggregate = BATTLEGROUND_SCOREBOARD_FRAGMENT:ShouldShowAggregateScores()
	local roundIndex = showAggregate and GetCurrentBattlegroundRoundIndex() or BATTLEGROUND_SCOREBOARD_FRAGMENT.viewedRound

	for i=1,GetNumScoreboardEntries() do
		local _, name = GetScoreboardEntryInfo(i)
		if name == data.displayName then
			bs.scores[i] = self
			updateScore(i, roundIndex, showAggregate)
		end
	end
end)


function bs.somethingChanged(code)
	-- logic used in base game BATTLEGROUND_SCOREBOARD_FRAGMENT to identify round index. Hopefully it just works without any issues
	local showAggregate = BATTLEGROUND_SCOREBOARD_FRAGMENT:ShouldShowAggregateScores()
	local roundIndex = showAggregate and GetCurrentBattlegroundRoundIndex() or BATTLEGROUND_SCOREBOARD_FRAGMENT.viewedRound
	
	for i=1,GetNumScoreboardEntries() do
		updateScore(i, roundIndex, showAggregate)
	end
end
EVENT_MANAGER:RegisterForEvent(bs.name, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, bs.somethingChanged)