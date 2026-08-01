NEAR_SR.func = {}
local addon = NEAR_SR
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function GetMorphInfo(skillLineId, skillIndex, morphChoice)
	local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(skillLineId)

	local morphRank = GetSkillLineProgressionAbilityRank(skillType, skillLineIndex, skillIndex, morphChoice)

	return morphRank
end

local function GetSkillLineInfo(skillLineId)
	local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(skillLineId)

	local skillLineInfo = {}
	local sL = skillLineInfo
	sL.rank, sL.advised, sL.active, sL.discovered = GetSkillLineDynamicInfo(skillType, skillLineIndex)
	-- sL.lastRankXP, sL.nextRankXP, sL.currentXP = GetSkillLineXPInfo(skillType, skillLineIndex)

	return sL.rank, sL.discovered
end

---@param skillType integer
---@param skillLineIndex integer
---@return integer
function NEAR_SR.func.GetSkillLineMaxRank(skillType, skillLineIndex)
	local skillLineId = GetSkillLineId(skillType, skillLineIndex)

	local LEGERDEMAIN      = GetSkillLineId(SKILL_TYPE_WORLD, 2)
	local SOUL_MAGIC       = GetSkillLineId(SKILL_TYPE_WORLD, 4)
	local DARK_BROTHERHOOD = GetSkillLineId(SKILL_TYPE_GUILD, 1)
	local THIEVES_GUILD    = GetSkillLineId(SKILL_TYPE_GUILD, 5)

	if skillType == SKILL_TYPE_WORLD or skillType == SKILL_TYPE_GUILD or skillType == SKILL_TYPE_AVA then
		if skillLineId == LEGERDEMAIN then
			return 20
		end
		if skillLineId == SOUL_MAGIC then
			return 6
		end
		if skillLineId == THIEVES_GUILD or skillLineId == DARK_BROTHERHOOD then
			return 12
		end
		return 10
	end
	return 50
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function UpdateCharList()
	local sv = addon.ASV.settings
	for i = 1, GetNumCharacters() do
		local name, _, _, classId, _, _, id, _ = GetCharacterInfo(i)
		sv.charInfo[i] = { charId = id, charName = zo_strformat("<<1>>", name), classId = classId, }
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateCharData(skillType)
	local funcName = 'CreateCharData'
	local dbg      = addon.utils.dbg
	local sv       = addon.ASV.settings
	local c        = addon.utils.color

	--[[ Debug ]] if sv.debug then d(dbg.open) d(dbg.lightGrey .. 'start of ' .. funcName) end

	local charId = GetCurrentCharacterId()
	local classId = GetUnitClassId("player")

	-- not in use so that a rank updated without the addon will be updated on start
	--[[ if addon.ASV.char[charId] ~= nil and type(addon.ASV.char[charId][skillType]) == "table" then return end -- character already has data for this skilltype, exit early and use events to update later
	if type(addon.ASV.char[charId][skillType]) == "table" then return end -- character already has data for this skilltype, exit early and use events to update later ]]

	addon.ASV.char[charId] = addon.defaults_char -- add default table for charId

	local svc = addon.ASV.char[charId]

	if skillType == SKILL_TYPE_CLASS then
		-- purge other classes from that character's info
		if svc[skillType] ~= nil then
			for key, _ in pairs(svc[skillType]) do
				if key ~= classId then
					svc[skillType][key] = nil
				end
			end
		end
	end

	for skillLineIndex, skillLine in ipairs(skillType == SKILL_TYPE_CLASS and addon.skilldata[skillType][classId] or addon.skilldata[skillType]) do
		-- define skill line data
		local skillLineId = skillLine.id
		local skillLineRank, skillLineDiscovered = GetSkillLineInfo(skillLineId)

		--[[ Debug ]]
		if sv.debug then
			d(
				c.white .. '----------------------------------------' .. "\n          " ..
				c.lightGrey .. "skillLineName: |r" .. zo_strformat("<<C:1>>", GetSkillLineNameById(skillLineId)) ..
				c.lightGrey .. " skillLineId: |r" .. skillLineId .. "\n          " ..
				c.lightGrey .. "skillLineRank: |r" .. skillLineRank ..
				c.lightGrey .. " skillLineDiscovered: |r" .. tostring(skillLineDiscovered) .. "\n          " ..
				c.white .. '----------------------------------------'
			)
		end

		local newskilldata = {
			rank = skillLineRank,
			discovered = skillLineDiscovered,
		}

		-- insert new SKILL data into saved variable > charId > skillType > [classId] > skillLine
		if skillType == SKILL_TYPE_CLASS then
			svc[skillType][classId][skillLineIndex] = newskilldata
		else
			svc[skillType][skillLineIndex] = newskilldata
		end

		----------------------------------------------------------------------------------------------------
		-- define ability data
		for skillIndex = 1, 7, 1 do
			if skillLine[skillIndex] ~= nil and not IsCraftedAbilitySkill(skillType, skillLineIndex, skillIndex) then
				local morphRank_0 = GetMorphInfo(skillLineId, skillIndex, 0)
				local morphRank_1 = GetMorphInfo(skillLineId, skillIndex, 1)
				local morphRank_2 = GetMorphInfo(skillLineId, skillIndex, 2)

				--[[ Debug ]]
				if sv.debug then
					local ability = skillLine[skillIndex]
					d(
						c.grey .. '----------------------------------------' .. "\n          " ..
						c.lightGrey .. "morphName_0: |r" .. zo_strformat("<<C:1>>", GetAbilityName(ability[0].id)) ..
						c.lightGrey .. " morphRank_0: |r" .. morphRank_0 .. "\n          " ..
						c.lightGrey .. "morphName_1: |r" .. zo_strformat("<<C:1>>", GetAbilityName(ability[1].id)) ..
						c.lightGrey .. " morphRank_1: |r" .. morphRank_1 .. "\n          " ..
						c.lightGrey .. "morphName_2: |r" .. zo_strformat("<<C:1>>", GetAbilityName(ability[2].id)) ..
						c.lightGrey .. " morphRank_2: |r" .. morphRank_2
					)
				end

				local newabilitydata = {
					[0] = morphRank_0,
					[1] = morphRank_1,
					[2] = morphRank_2,
				}

				-- insert new ABILITY data into saved variable >  charId > skillType > [classId] > skillLine > skillIndex
				if skillType == SKILL_TYPE_CLASS then
					svc[skillType][classId][skillLineIndex][skillIndex] = newabilitydata
				else
					svc[skillType][skillLineIndex][skillIndex] = newabilitydata
				end
			end
		end
	end

	--[[ Debug ]] if sv.debug then d(dbg.grey .. 'end of ' .. funcName) d(dbg.close) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function UpdateCharData(updatedRankType, skillType, skillLineIndex, skillIndex)
	local funcName = 'UpdateCharData'
	local dbg      = addon.utils.dbg
	local sv       = addon.ASV.settings
	local c        = addon.utils.color

	--[[ Debug ]] if sv.debug then d(dbg.open) d(dbg.lightGrey .. 'start of ' .. funcName) end

	local charId = GetCurrentCharacterId()
	local classId = GetUnitClassId("player")

	-- warn if trying to update but the tables are empty then exit early, otherwise continue
	if addon.ASV.char[charId] == nil then
		d(dbg.lightGrey .. 'Something went wrong trying to update character skill data, character table is empty')
		return
	end

	local sv_skilldata

	if skillType == SKILL_TYPE_CLASS then
		sv_skilldata = addon.ASV.char[charId][skillType][classId][skillLineIndex]
	else
		sv_skilldata = addon.ASV.char[charId][(skillType == SKILL_TYPE_TRADESKILL) and addon.SKILL_TYPE_TRADESKILL or skillType][skillLineIndex]
	end

	if updatedRankType == 'skillLine' then
		local skillLineRank, _, _, skillLineDiscovered = GetSkillLineDynamicInfo(skillType, skillLineIndex)

		--[[ Debug ]]
		if sv.debug then
			d(
				c.white .. '----------------------------------------' .. "\n          " ..
				c.lightGrey .. "skillLineName: |r" .. zo_strformat("<<C:1>>", GetSkillLineNameById(GetSkillLineId(skillType, skillLineIndex))) ..
				c.lightGrey .. " skillLineId: |r" .. GetSkillLineId(skillType, skillLineIndex) .. "\n          " ..
				c.lightGrey .. "skillLineRank: |r" .. skillLineRank ..
				c.lightGrey .. " skillLineDiscovered: |r" .. tostring(skillLineDiscovered) .. "\n          " ..
				c.white .. '----------------------------------------'
			)
		end

		-- overwrite SKILL data on saved variable > skillType > [classId] > skillLine
		sv_skilldata.rank = skillLineRank
		sv_skilldata.discovered = skillLineDiscovered
	elseif updatedRankType == 'morph' then
		local skillLineId = GetSkillLineId(skillType, skillLineIndex)

		local morphRank_0 = GetMorphInfo(skillLineId, skillIndex, 0)
		local morphRank_1 = GetMorphInfo(skillLineId, skillIndex, 1)
		local morphRank_2 = GetMorphInfo(skillLineId, skillIndex, 2)

		--[[ Debug ]]
		if sv.debug then
			local ability = skillType == SKILL_TYPE_CLASS and addon.skilldata[skillType][classId][skillLineIndex][skillIndex] or addon.skilldata[skillType][skillLineIndex][skillIndex]
			d(
				c.grey .. '----------------------------------------' .. "\n          " ..
				c.lightGrey .. "morphName_0: |r" .. zo_strformat("<<C:1>>", GetAbilityName(ability[0].id)) ..
				c.lightGrey .. " morphRank_0: |r" .. morphRank_0 .. "\n          " ..
				c.lightGrey .. "morphName_1: |r" .. zo_strformat("<<C:1>>", GetAbilityName(ability[1].id)) ..
				c.lightGrey .. " morphRank_1: |r" .. morphRank_1 .. "\n          " ..
				c.lightGrey .. "morphName_2: |r" .. zo_strformat("<<C:1>>", GetAbilityName(ability[2].id)) ..
				c.lightGrey .. " morphRank_2: |r" .. morphRank_2
			)
		end

		local newabilitydata = {
			[0] = morphRank_0,
			[1] = morphRank_1,
			[2] = morphRank_2,
		}

		-- overwrite ABILITY data on saved variable > skillType > skillLine > skillIndex
		sv_skilldata[skillIndex] = newabilitydata
	else
		d(dbg.lightGrey .. 'Something went wrong trying to define what to update, updatedRankType is undefined or not "skillLine" nor "morph"')
	end

	--[[ Debug ]] if sv.debug then d(dbg.grey .. 'end of ' .. funcName) d(dbg.close) end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
function NEAR_SR.func.OnMorphRankUpdate(event, progressionIndex, rank, maxRank, morph)
	local skillType, skillLineIndex, skillIndex = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
	if skillType == SKILL_TYPE_CLASS and skillLineIndex > 3 then return end -- not tracking subclasses
	UpdateCharData('morph', skillType, skillLineIndex, skillIndex)
end

function NEAR_SR.func.OnSkillRankUpdate(event, skillType, skillLineIndex, skillLineRank)
	if skillType == SKILL_TYPE_RACIAL then return end -- racial is not being tracked so exit early
	if skillType == SKILL_TYPE_CLASS and skillLineIndex > 3 then return end -- not tracking subclasses
	UpdateCharData('skillLine', skillType, skillLineIndex)
end

function NEAR_SR.func.OnSkillLineAdded(event, skillType, skillLineIndex, advised)
	if skillType == SKILL_TYPE_RACIAL then return end -- racial is not being tracked so exit early
	if skillType == SKILL_TYPE_CLASS and skillLineIndex > 3 then return end -- not tracking subclasses
	UpdateCharData('skillLine', skillType, skillLineIndex)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local skillTypeIndexes = {
	SKILL_TYPE_CLASS,
	SKILL_TYPE_WEAPON,
	SKILL_TYPE_ARMOR,
	SKILL_TYPE_WORLD,
	SKILL_TYPE_GUILD,
	SKILL_TYPE_AVA,
	-- SKILL_TYPE_RACIAL,
	addon.SKILL_TYPE_TRADESKILL,
}

function NEAR_SR.func.Init()
	UpdateCharList()
	for _, v in ipairs(skillTypeIndexes) do
		CreateCharData(v)
	end
end
