if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix
------------------------------------------------------------------------------------------------------------
-- Sounds for notifications
------------------------------------------------------------------------------------------------------------
    PTSF.sounds              = {
    "ACTIVE_SKILL_MORPH_CHOSEN",
    "ALCHEMY_CREATE_TOOLTIP_GLOW_SUCCESS",
    "ALCHEMY_SOLVENT_PLACED",
    "ALCHEMY_SOLVENT_REMOVED",
    "BLACKSMITH_EXTRACTED_BOOSTER",
    "CHAMPION_CYCLED_TO_MAGE",
    "CHAMPION_MAGE_MOUSEOVER", --1.08 no sound "CHAMPION_DAMAGE_TAKEN",
    "CHAMPION_PENDING_POINTS_CLEARED",
    "CHAMPION_POINTS_COMMITTED",
    "CHAMPION_STAR_LOCKED",
    "CHAMPION_STAR_MOUSEOVER",
    "CHAMPION_STAR_UNLOCKED",
    "CHAMPION_SYSTEM_UNLOCKED",
    "CROWN_CRATES_PURCHASED_WITH_GEMS",
    "DAEDRIC_ENERGY_LOW",
    "DEATH_RECAP_ATTACK_SHOWN",
    "DEATH_RECAP_KILLING_BLOW_SHOWN",
    "DUEL_ACCEPTED",
    "DUEL_START",
    "DYEING_APPLY_CHANGES",
    "DYEING_TOOL_DYE_USED",
    "DYEING_TOOL_FILL_USED",
    "DYEING_UNDO_CHANGES",
    "GAMEPAD_STATS_SINGLE_PURCHASE",
    "GIFT_INVENTORY_VIEW_FANFARE_SPARKS",
    "INVENTORY_ITEM_APPLY_CHARGE",
    "INVENTORY_ITEM_APPLY_ENCHANT",
    "JUSTICE_PICKPOCKET_BONUS",
    "JUSTICE_PICKPOCKET_FAILED",
    "LOCKPICKING_BREAK",
    "NEW_TIMED_NOTIFICATION",
    "RETRAITING_RETRAIT_TOOLTIP_GLOW_SUCCESS",
    "RETRAITING_START_RETRAIT",
    "ZONE_STORIES_TRACK_ACTIVITY",
    --new static 1.08
    "ABILITY_WEAPON_SWAP_FAIL",
    "BOOK_METAL_OPEN",
    "CC_GAMEPAD_CHARACTER_CLICK",
    "CC_RANDOMIZE",
    "CC_UNLOCK_VALUE",
    "CHAMPION_STAR_PICKED_UP",
    "CHAMPION_STAR_SLOTTED",
    "CLOTHIER_IMPROVE_TOOLTIP_GLOW_FAIL",
    "CODE_REDEMPTION_SUCCESS",
    "COLLECTIBLE_UNLOCKED",
    "CONSOLE_GAME_ENTER",
    "CROWN_CRATES_CARD_FLIPPING", --no boost
    "DAILY_LOGIN_REWARDS_CLAIM_FANFARE",
    "DYEING_RANDOMIZE_DYES",
    "DYEING_TOOL_SET_FILL_USED",
    "ENCHANTING_POTENCY_RUNE_PLACED",
    "ENCHANTING_POTENCY_RUNE_REMOVED",
    "ENCHANTING_WEAPON_GLYPH_PLACED",
    "ENCHANTING_WEAPON_GLYPH_REMOVED",
    "GIFT_INVENTORY_VIEW_FANFARE_BLAST",
    "JEWELRYCRAFTER_IMPROVE_TOOLTIP_GLOW_SUCCESS",
    "RAID_TRIAL_SCORE_ADDED_VERY_LOW",
    "RAID_TRIAL_SCORE_ADDED_LOW",
    "RAID_TRIAL_SCORE_ADDED_NORMAL",
    "RAID_TRIAL_SCORE_ADDED_HIGH",
    "RAID_TRIAL_SCORE_ADDED_VERY_HIGH",
    "SCRYING_START_INTRO",
    "SCRYING_START_END_OF_GAME",
    "SCRYING_CAPTURE_GOAL",
    "SCRYING_CAPTURE_HEX_SMALL",
    "SCRYING_CAPTURE_HEX_MEDIUM",
    "SCRYING_CAPTURE_HEX_LARGE",
    "SCRYING_ACTIVATE_BOMB",
    "SCRYING_CO_OPT_HEX_SMALL",
    "SCRYING_CO_OPT_HEX_MEDIUM",
    "SCRYING_CO_OPT_HEX_LARGE",
    "SCRYING_ACTIVATE_LINE",
    "SCRYING_CHOOSE_SKILL",
    "SCRYING_PROGRESS_ADDED",
    "SCRYING_NO_PROGRESS_ADDED",
    "SCRYING_PROGRESS_GOAL_FADEIN",
}

--1.08 table.sort(PTSF.sounds)
table.insert(PTSF.sounds, 1, "DEFAULT")
table.insert(PTSF.sounds, 2, "NONE")

local debug_sounds = false

if(debug_sounds) then
    if PTSF.sounds then
        for i, soundName in pairs(PTSF.sounds) do
        	d(i.."- soundName="..soundName)
        end
    end
end

--Sounds list: https://wiki.esoui.com/Sounds


--DEV, all game sounds will be added after our static list above
function doesSoundExist(sound)
	    for i, soundName in pairs(PTSF.sounds) do
	    	if soundName == sound then
	    		return true
	    	end
        end
        return false
end

if PTSF.sounds and debug_sounds then
	local counter = 1
	local TotalStaticSounds = #PTSF.sounds-1
	--Create another temp table
	local ALLSOUNDSTEMP = {}
	for i, soundName in pairs(SOUNDS) do
		table.insert(ALLSOUNDSTEMP, counter, tostring(i))
		counter = counter + 1
	end
	table.sort(ALLSOUNDSTEMP)
	
	counter = TotalStaticSounds+2 --37 --We start after total static sounds. These will also be in dynamic sound db
	
	for i, soundName in pairs(ALLSOUNDSTEMP) do
			if not doesSoundExist(soundName) then
				table.insert(PTSF.sounds, counter, soundName)
				--d(tostring(counter).."- soundName="..soundName)
				counter = counter + 1
			end
    end
end