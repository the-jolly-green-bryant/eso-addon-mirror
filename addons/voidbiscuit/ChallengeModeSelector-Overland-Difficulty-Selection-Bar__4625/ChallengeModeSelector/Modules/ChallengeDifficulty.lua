-- Addon
ChallengeModeSelector = ChallengeModeSelector or {}
local CMS = ChallengeModeSelector

-- Modules
CMS.Difficulty = CMS.Difficulty or {}
local Difficulty = CMS.Difficulty

-- Helper
local map = CMS.Helper.map

-- Main
do
	-- Difficulty lookup table borrowed from:
	-- esoui/esoui/ingame/challengedifficulty/keyboard/challengedifficulty_keyboard.lua
	local DIFFICULTY_NAME_LOOKUP = {
		[OVERLAND_DIFFICULTY_TYPE_BASEGAME] = "basegame",
		[OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN] = "journeyman",
		[OVERLAND_DIFFICULTY_TYPE_ADVENTURER] = "adventurer",
		[OVERLAND_DIFFICULTY_TYPE_VETERAN] = "veteran",
	}
	-- Difficulty table
	local difficulty_name_lookup = "SI_OVERLANDDIFFICULTYTYPE"
	local difficulty_texture_format = "EsoUI/Art/ChallengeDifficulty/challengeDifficulty_%s_%%s.dds"
	local difficulties = map(function(difficulty_id)
		local difficulty_name = GetString(difficulty_name_lookup, difficulty_id)
		local difficulty_id_name = DIFFICULTY_NAME_LOOKUP[difficulty_id]
		return {
			id = difficulty_id,
			id_name = difficulty_id_name,
			name = difficulty_name,
			texture_format = string.format(difficulty_texture_format, string.lower(difficulty_id_name)),
			sound = SOUNDS[string.format("CHALLENGE_DIFFICULTY_SELECTED_%s", string.upper(difficulty_id_name))],
		}
	end, {
		OVERLAND_DIFFICULTY_TYPE_BASEGAME,
		OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN,
		OVERLAND_DIFFICULTY_TYPE_ADVENTURER,
		OVERLAND_DIFFICULTY_TYPE_VETERAN,
	})
	CMS.Difficulty.difficulties = difficulties

	-- Wrappers
	function Difficulty.GetOverlandDifficultyId()
		return GetOverlandDifficulty()
	end

	function Difficulty.GetOverlandDifficultyDisabledReasonId()
		return GetOverlandDifficultyDisabledReason()
	end

	-- Helpers
	function Difficulty.IsOverlandDifficultyEnabled()
		return Difficulty.GetOverlandDifficultyDisabledReasonId() == OVERLAND_DIFFICULTY_DISABLED_REASON_NONE
	end

	function Difficulty.GetOverlandDifficultyDisabledReason()
		local disabled_reason_id = Difficulty.GetOverlandDifficultyDisabledReasonId()
		return GetString("SI_OVERLANDDIFFICULTYDISABLEDREASON", disabled_reason_id)
	end
end
