-- RdK Group Tool Util Ultimates
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}

local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.ultimates = RdKGToolUtil.ultimates or {}

local RdKGToolUltimates = RdKGToolUtil.ultimates

RdKGToolUltimates.constants = RdKGToolUltimates.constants or {}

function RdKGToolUltimates.InitializeUltimates()
	--Not much room left here for compatibility reasons... Yet some people did their own thing and all of it is now a mess. congrats
	--GetSkillAbilityId(number SkillType skillType, number skillLineIndex, number skillIndex, boolean showUpgrade) 
	RdKGToolUltimates.ultimates = {}
	RdKGToolUltimates.ultimates[1] = {}
	RdKGToolUltimates.ultimates[1].name = RdKGToolUltimates.constants.NEGATE
	RdKGToolUltimates.ultimates[1].abilityId = 28341
	RdKGToolUltimates.ultimates[1].id = 1
	
	RdKGToolUltimates.ultimates[2] = {}
	RdKGToolUltimates.ultimates[2].name = RdKGToolUltimates.constants.NEGATE_OFFENSIVE
	RdKGToolUltimates.ultimates[2].abilityId = 28341
	RdKGToolUltimates.ultimates[2].id = 32 --29
	RdKGToolUltimates.ultimates[2].iconColor = {}
	RdKGToolUltimates.ultimates[2].iconColor.r = 0.6
	RdKGToolUltimates.ultimates[2].iconColor.g = 0.2
	RdKGToolUltimates.ultimates[2].iconColor.b = 0.2
	
	RdKGToolUltimates.ultimates[3] = {}
	RdKGToolUltimates.ultimates[3].name = RdKGToolUltimates.constants.NEGATE_COUNTER
	RdKGToolUltimates.ultimates[3].abilityId = 28341
	RdKGToolUltimates.ultimates[3].id = 33 --30
	RdKGToolUltimates.ultimates[3].iconColor = {}
	RdKGToolUltimates.ultimates[3].iconColor.r = 0.2
	RdKGToolUltimates.ultimates[3].iconColor.g = 0.2
	RdKGToolUltimates.ultimates[3].iconColor.b = 0.6

	RdKGToolUltimates.ultimates[4] = {}
	RdKGToolUltimates.ultimates[4].name = RdKGToolUltimates.constants.ATRONACH
	RdKGToolUltimates.ultimates[4].abilityId = 23634
	RdKGToolUltimates.ultimates[4].id = 2

	RdKGToolUltimates.ultimates[5] = {}
	RdKGToolUltimates.ultimates[5].name = RdKGToolUltimates.constants.OVERLOAD
	RdKGToolUltimates.ultimates[5].abilityId = 24785
	RdKGToolUltimates.ultimates[5].id = 3

	RdKGToolUltimates.ultimates[6] = {}
	RdKGToolUltimates.ultimates[6].name = RdKGToolUltimates.constants.SWEEP
	RdKGToolUltimates.ultimates[6].abilityId = 22138
	RdKGToolUltimates.ultimates[6].id = 4

	RdKGToolUltimates.ultimates[7] = {}
	RdKGToolUltimates.ultimates[7].name = RdKGToolUltimates.constants.NOVA
	RdKGToolUltimates.ultimates[7].abilityId = 21752
	RdKGToolUltimates.ultimates[7].id = 5

	RdKGToolUltimates.ultimates[8] = {}
	RdKGToolUltimates.ultimates[8].name = RdKGToolUltimates.constants.T_HEAL
	RdKGToolUltimates.ultimates[8].abilityId = 22223
	RdKGToolUltimates.ultimates[8].id = 6

	RdKGToolUltimates.ultimates[9] = {}
	RdKGToolUltimates.ultimates[9].name = RdKGToolUltimates.constants.STANDARD
	RdKGToolUltimates.ultimates[9].abilityId = 32958 --28988
	RdKGToolUltimates.ultimates[9].id = 7

	RdKGToolUltimates.ultimates[10] = {}
	RdKGToolUltimates.ultimates[10].name = RdKGToolUltimates.constants.LEAP
	RdKGToolUltimates.ultimates[10].abilityId = 29012
	RdKGToolUltimates.ultimates[10].id = 8

	RdKGToolUltimates.ultimates[11] = {}
	RdKGToolUltimates.ultimates[11].name = RdKGToolUltimates.constants.MAGMA
	RdKGToolUltimates.ultimates[11].abilityId = 15957
	RdKGToolUltimates.ultimates[11].id = 9

	RdKGToolUltimates.ultimates[12] = {}
	RdKGToolUltimates.ultimates[12].name = RdKGToolUltimates.constants.STROKE
	RdKGToolUltimates.ultimates[12].abilityId = 33398
	RdKGToolUltimates.ultimates[12].id = 10

	RdKGToolUltimates.ultimates[13] = {}
	RdKGToolUltimates.ultimates[13].name = RdKGToolUltimates.constants.DARKNESS
	RdKGToolUltimates.ultimates[13].abilityId = 25411
	RdKGToolUltimates.ultimates[13].id = 11

	RdKGToolUltimates.ultimates[14] = {}
	RdKGToolUltimates.ultimates[14].name = RdKGToolUltimates.constants.SOUL
	RdKGToolUltimates.ultimates[14].abilityId = 25091
	RdKGToolUltimates.ultimates[14].id = 12
	
	RdKGToolUltimates.ultimates[15] = {}
	RdKGToolUltimates.ultimates[15].name = RdKGToolUltimates.constants.SOUL_SIPHON
	RdKGToolUltimates.ultimates[15].abilityId = 35508
	RdKGToolUltimates.ultimates[15].id = 37
	
	RdKGToolUltimates.ultimates[16] = {}
	RdKGToolUltimates.ultimates[16].name = RdKGToolUltimates.constants.SOUL_TETHER
	RdKGToolUltimates.ultimates[16].abilityId = 35460
	RdKGToolUltimates.ultimates[16].id = 38

	RdKGToolUltimates.ultimates[17] = {}
	RdKGToolUltimates.ultimates[17].name = RdKGToolUltimates.constants.STORM
	RdKGToolUltimates.ultimates[17].abilityId = 86109
	RdKGToolUltimates.ultimates[17].id = 13
	
	RdKGToolUltimates.ultimates[18] = {}
	RdKGToolUltimates.ultimates[18].name = RdKGToolUltimates.constants.NORTHERN_STORM
	RdKGToolUltimates.ultimates[18].abilityId = 86113
	RdKGToolUltimates.ultimates[18].id = 35
	
	RdKGToolUltimates.ultimates[19] = {}
	RdKGToolUltimates.ultimates[19].name = RdKGToolUltimates.constants.PERMAFROST
	RdKGToolUltimates.ultimates[19].abilityId = 86117
	RdKGToolUltimates.ultimates[19].id = 36

	RdKGToolUltimates.ultimates[20] = {}
	RdKGToolUltimates.ultimates[20].name = RdKGToolUltimates.constants.W_HEAL
	RdKGToolUltimates.ultimates[20].abilityId = 85532
	RdKGToolUltimates.ultimates[20].id = 14
	
	RdKGToolUltimates.ultimates[21] = {}
	RdKGToolUltimates.ultimates[21].name = RdKGToolUltimates.constants.GUARDIAN
	RdKGToolUltimates.ultimates[21].abilityId = 85982
	RdKGToolUltimates.ultimates[21].id = 31
	
	RdKGToolUltimates.ultimates[22] = {}
	RdKGToolUltimates.ultimates[22].name = RdKGToolUltimates.constants.COLOSSUS
	RdKGToolUltimates.ultimates[22].abilityId = 122174
	RdKGToolUltimates.ultimates[22].id = 29 --32
	
	RdKGToolUltimates.ultimates[23] = {}
	RdKGToolUltimates.ultimates[23].name = RdKGToolUltimates.constants.GOLIATH
	RdKGToolUltimates.ultimates[23].abilityId = 115001
	RdKGToolUltimates.ultimates[23].id = 28 --33
	
	RdKGToolUltimates.ultimates[24] = {}
	RdKGToolUltimates.ultimates[24].name = RdKGToolUltimates.constants.REANIMATE
	RdKGToolUltimates.ultimates[24].abilityId = 115410
	RdKGToolUltimates.ultimates[24].id = 30 --34
		
	RdKGToolUltimates.ultimates[25] = {}
	RdKGToolUltimates.ultimates[25].name = RdKGToolUltimates.constants.UNBLINKING_EYE
	RdKGToolUltimates.ultimates[25].abilityId = 189791
	RdKGToolUltimates.ultimates[25].id = 39
	
	RdKGToolUltimates.ultimates[26] = {}
	RdKGToolUltimates.ultimates[26].name = RdKGToolUltimates.constants.GIBBERING_SHIELD
	RdKGToolUltimates.ultimates[26].abilityId = 183676
	RdKGToolUltimates.ultimates[26].id = 40
	
	RdKGToolUltimates.ultimates[27] = {}
	RdKGToolUltimates.ultimates[27].name = RdKGToolUltimates.constants.VITALIZING_GLYPHIC
	RdKGToolUltimates.ultimates[27].abilityId = 183709
	RdKGToolUltimates.ultimates[27].id = 41
	
	RdKGToolUltimates.ultimates[28] = {}
	RdKGToolUltimates.ultimates[28].name = RdKGToolUltimates.constants.DESTRUCTION
	RdKGToolUltimates.ultimates[28].abilityId = 83619
	RdKGToolUltimates.ultimates[28].id = 15

	RdKGToolUltimates.ultimates[29] = {}
	RdKGToolUltimates.ultimates[29].name = RdKGToolUltimates.constants.RESTORATION
	RdKGToolUltimates.ultimates[29].abilityId = 83552
	RdKGToolUltimates.ultimates[29].id = 16

	RdKGToolUltimates.ultimates[30] = {}
	RdKGToolUltimates.ultimates[30].name = RdKGToolUltimates.constants.TWO_HANDED
	RdKGToolUltimates.ultimates[30].abilityId = 83216
	RdKGToolUltimates.ultimates[30].id = 17

	RdKGToolUltimates.ultimates[31] = {}
	RdKGToolUltimates.ultimates[31].name = RdKGToolUltimates.constants.SHIELD
	RdKGToolUltimates.ultimates[31].abilityId = 83272
	RdKGToolUltimates.ultimates[31].id = 18

	RdKGToolUltimates.ultimates[32] = {}
	RdKGToolUltimates.ultimates[32].name = RdKGToolUltimates.constants.DUAL_WIELD
	RdKGToolUltimates.ultimates[32].abilityId = 83600
	RdKGToolUltimates.ultimates[32].id = 19

	RdKGToolUltimates.ultimates[33] = {}
	RdKGToolUltimates.ultimates[33].name = RdKGToolUltimates.constants.BOW
	RdKGToolUltimates.ultimates[33].abilityId = 83465
	RdKGToolUltimates.ultimates[33].id = 20

	RdKGToolUltimates.ultimates[34] = {}
	RdKGToolUltimates.ultimates[34].name = RdKGToolUltimates.constants.SOUL_MAGIC
	RdKGToolUltimates.ultimates[34].abilityId = 39270
	RdKGToolUltimates.ultimates[34].id = 21

	RdKGToolUltimates.ultimates[35] = {}
	RdKGToolUltimates.ultimates[35].name = RdKGToolUltimates.constants.WEREWOLF
	RdKGToolUltimates.ultimates[35].abilityId = 32455
	RdKGToolUltimates.ultimates[35].id = 22

	RdKGToolUltimates.ultimates[36] = {}
	RdKGToolUltimates.ultimates[36].name = RdKGToolUltimates.constants.VAMPIRE
	RdKGToolUltimates.ultimates[36].abilityId = 32624
	RdKGToolUltimates.ultimates[36].id = 23

	RdKGToolUltimates.ultimates[37] = {}
	RdKGToolUltimates.ultimates[37].name = RdKGToolUltimates.constants.MAGES
	RdKGToolUltimates.ultimates[37].abilityId = 16536
	RdKGToolUltimates.ultimates[37].id = 24

	RdKGToolUltimates.ultimates[38] = {}
	RdKGToolUltimates.ultimates[38].name = RdKGToolUltimates.constants.FIGHTERS
	RdKGToolUltimates.ultimates[38].abilityId = 35713
	RdKGToolUltimates.ultimates[38].id = 25

	RdKGToolUltimates.ultimates[39] = {}
	RdKGToolUltimates.ultimates[39].name = RdKGToolUltimates.constants.PSIJIC
	RdKGToolUltimates.ultimates[39].abilityId = 103478
	RdKGToolUltimates.ultimates[39].id = 34 --28

	RdKGToolUltimates.ultimates[40] = {}
	RdKGToolUltimates.ultimates[40].name = RdKGToolUltimates.constants.ALLIANCE_SUPPORT
	RdKGToolUltimates.ultimates[40].abilityId = 38573
	RdKGToolUltimates.ultimates[40].id = 26

	RdKGToolUltimates.ultimates[41] = {}
	RdKGToolUltimates.ultimates[41].name = RdKGToolUltimates.constants.ALLIANCE_ASSAULT
	RdKGToolUltimates.ultimates[41].abilityId = 38563
	RdKGToolUltimates.ultimates[41].id = 27


end

function RdKGToolUltimates.Initialize()
	RdKGToolUltimates.InitializeUltimates()
	for i = 1, #RdKGToolUltimates.ultimates do
		local ultimate = RdKGToolUltimates.ultimates[i]
		ultimate.icon = GetAbilityIcon(ultimate.abilityId)
		ultimate.cost = GetAbilityCost(ultimate.abilityId)
	end
end

function RdKGToolUltimates.UpdateAbilityCosts(index)
	if index ~= nil and RdKGToolUltimates.ultimates[index] ~= nil then
		RdKGToolUltimates.ultimates[index].cost = GetAbilityCost(RdKGToolUltimates.ultimates[index].abilityId)
	end
end

function RdKGToolUltimates.GetUltimateIndexFromUltimateId(id)
	local selectedIndex = nil
	if id ~= nil then
		local ultimates = RdKGToolUltimates.ultimates
		for i = 1, #ultimates do
			if id == ultimates[i].id then
				selectedIndex = i
				break
			end
		end
		
	end
	return selectedIndex
end