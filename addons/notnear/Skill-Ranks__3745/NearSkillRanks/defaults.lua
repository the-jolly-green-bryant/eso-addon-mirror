local addon = NEAR_SR
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

NEAR_SR.defaults = {
	settings = {
		debug = false,
		charInfo = {},
	},
	char_data = {
		char = {},
	}
}

local function createSkillLineEntry()
	return {
		rank = 0,
		discovered = false,
	}
end

local function createAbilityEntry()
	return { [0] = 0, [1] = 0, [2] = 0, }
end

local function checkDataAndCreate(table, data)
	for skillLineIndex, skillLine in pairs(data) do
		table[skillLineIndex] = createSkillLineEntry()

		for ability, _ in ipairs(skillLine) do
			if type(ability) == "number" then
				table[skillLineIndex][ability] = createAbilityEntry()
			end
		end
	end
end

NEAR_SR.defaults_char = {}

for skillType, skillTypeData in ipairs(addon.skilldata) do
	NEAR_SR.defaults_char[skillType] = {}

	if skillType == SKILL_TYPE_CLASS then
		for classId, classData in pairs(skillTypeData) do
			NEAR_SR.defaults_char[skillType][classId] = {}
			checkDataAndCreate(NEAR_SR.defaults_char[skillType][classId], classData)
		end
	else
		checkDataAndCreate(NEAR_SR.defaults_char[skillType],skillTypeData)
	end
end
