Near_SkillBlockerBanner.defaults = {}
local addon = Near_SkillBlockerBanner
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

Near_SkillBlockerBanner.defaults.skilldata = {} -- Toggle block skills/messages

local function createSkillEntry()
	local data = { block = false, block_inCombat = false, pvp = true, msg = { re_cast = false, pvp = true, } }

	return data
end

for index in ipairs(addon.skilldata) do
	Near_SkillBlockerBanner.defaults.skilldata[index] = createSkillEntry()
end
