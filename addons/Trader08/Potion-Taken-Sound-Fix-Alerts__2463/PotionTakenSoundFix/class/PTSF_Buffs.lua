if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix

------------------------------------------------------------------------------------------------------------
-- Sounds for notifications
------------------------------------------------------------------------------------------------------------
    PTSF.buffs          = { 	--Used in options
    { name = "Unstoppable", 				description = "Become immune to knockback and disabling effects", },
    { name = "Lingering Restore Health", 	description = "Restore x health every second", },
    { name = "Major Brutality", 			description = "+20% Weapon Damage", }, 									--To check
    { name = "Major Savagery", 				description = "2629 (+10% @ cp160) Weapon Critical", },					--To check
    { name = "Major Sorcery", 				description = "+20% Spell Damage", },									--To check
    { name = "Major Prophecy", 				description = "2629 (+10% @ cp160) Spell Critical", },					--To check
    { name = "Major Fortitude", 			description = "+30% Health Recovery", },
    { name = "Major Endurance", 			description = "+30% Stamina Recovery", },
    { name = "Major Intellect", 			description = "+30% Magicka Recovery", },
    { name = "Major Vitality", 				description = "+16% Healing Taken", },									--To check
    { name = "Minor Protection", 			description = "-5% Damage Taken", },									--To check
    { name = "Minor Heroism", 				description = "+1 Ultimate every 1.5 second", },						--To check
    { name = "Physical Resistance",			description = "Increase Physical Resistance by 5280", },
    { name = "Spell Resistance",			description = "Increase Spell Resistance by 5280", },
    { name = "Major Expedition", 			description = "+30% Movement Speed", },									--To check
    { name = "Increase Detection",		 	description = "Increase your Stealth Detection by 20 meters", },
    { name = "Invisibility", 				description = "Become invisible", },
    
--    { name = "Vanish", 	description = "Vanish (become invisible, crafted/looted potion)", },
}

PTSF.buffs_abilityIds          = { --We're doing it this way so we'll be able to do a direct compare instead of looping within arrays. We want to keep performance hit to a minimim
    -- Crafted Potions (2 Traits)
    [64564] = "Physical Resistance",
    [45236] = "Increase Detection",
    [45239] = "Unstoppable",
    [45237] = "Invisibility",
    [79705] = "Lingering Restore Health",
    [64562] = "Spell Resistance",
    [61721] = "Minor Protection",
    [61708] = "Minor Heroism",

    -- Crafted Potions (3 Traits)
    [64565] = "Physical Resistance",
    [45458] = "Increase Detection",
    [45463] = "Unstoppable",
    [45460] = "Invisibility",
    [79706] = "Lingering Restore Health",
    [64563] = "Spell Resistance",

    -- Vendor Potions + AVA Potions + Roguish Draughts
    [72930] = "Unstoppable",
    [137002] = "Invisibility",
    [78058] = "Invisibility",

    -- Crown Store Potions
    [86780] = "Invisibility",
    [86698] = "Unstoppable",
    [86699] = "Invisibility",
    [92416] = "Unstoppable",

    ----------------------------------------------------------------
    -- POTION UP FRONT EFFECTS -------------------------------------
    ----------------------------------------------------------------

    --Crafted Potions (2 Traits)
    [45221] = "Major Fortitude",
    [45223] = "Major Intellect",
    [45225] = "Major Endurance",

    --Crafted Potions (3 Traits)
    [45382] = "Major Fortitude",
    [45385] = "Major Intellect",
    [45388] = "Major Endurance",
    [61667] = "Major Savagery",
    [61736] = "Major Expedition", --Same as rapids
    [61713] = "Major Vitality",
    [61665] = "Major Brutality",

    -- Vendor Potions + AVA Potions + Roguish Draughts
    [17302] = "Major Fortitude",
    [17323] = "Major Intellect",
    [17328] = "Major Endurance",
    [72934] = "Major Endurance",
    [72927] = "Major Fortitude",
    [72931] = "Major Intellect",
    [78053] = "Major Endurance",
    [78079] = "Major Endurance",
    [61698] = "Major Fortitude",

    -- Crown Store Potions
    [68401] = "Major Fortitude",
    [68407] = "Major Intellect",
    [68409] = "Major Endurance",
    [86682] = "Major Intellect",
    [86696] = "Major Fortitude",
    [86692] = "Major Endurance",
    [92414] = "Major Fortitude",
    [61707] = "Major Intellect",
    [61705] = "Major Endurance",
    [61689] = "Major Prophecy",
    [61687] = "Major Sorcery",
}

local debug_buffs = false

function PTSF.list_abilities_to_chat()
--[[		if(PTSF.APIVersion ~= nil) then
			PTSF.DG("Using data for API Version: "..PTSF.APIVersion)
		else
			PTSF.D("Unknown API Version, using latest data from API Version 100029 Dragonhold", true)
		end--]]
		local count = 0
		local text = ""
		local abilityIds = {}
        for i, buff in pairs(PTSF.buffs) do
        	if(buff.name) then
        		for j, buffName in pairs(PTSF.buffs_abilityIds) do
        			if(buffName == buff.name) then
        				count = count + 1
        				abilityIds[count] = j
        			end
        		end
        		d(i.."- |c9853C6buff.name="..buff.name.."|r |c008B21 description="..buff.description.."|r")
        		if(count ~= 0) then
        			text = "    -> abilityId's |cFFAC03"
        			for k = 1, count do
        				text = text.." "..k.."-["..abilityIds[k].."]"
        			end
        			d(text.."|r")
        			count = 0
        			abilityIds = {}
        		end
        	end
        end
end

if(debug_buffs) then PTSF.list_abilities_to_chat() end