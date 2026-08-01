MotA_Sounds = {}

local NodeSounds = {
	[1]  = {sound = "Smithing_Finish_Research"},
	[2]  = {sound = "Book_Collection_Completed"},
	[3]  = {sound = "Ability_Ultimate_Ready_Sound"},
	[4]  = {sound = "SkillLine_Leveled"},
	[5]  = {sound = "Market_CrownsSpent"},
	[6]  = {sound = "Skill_Gained"},
	[7]  = {sound = "Champion_PointGained"},
}

function MotA_Sounds:GetSoundChoices(parent)
	local choices = {}
	local customSound = true

	for k,v in ipairs(NodeSounds) do
		choices[#choices+1] = v.sound

		if v.sound == parent.savedVariables.timers.notificationSound then
			customSound = false
		end
	end

	if customSound then
		choices[#choices+1] = parent.savedVariables.timers.notificationSound
	end

	return choices
end
