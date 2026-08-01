--[[
/script SetCVar("Language.2", "en")
/script SetCVar("Language.2", "fr")
/script SetCVar("Language.2", "de")
/script d(GetAPIVersion())
--]]

local function fName(id)
	return zo_strformat("<<t:1>>",GetAbilityName(id))
end

VWoeAddon.CriminalDB = {
-- Necromancer Abilities
	[fName(122380)] = true, -- Frozen Colossus
	[fName(122391)] = true, -- Glacial Colossus
	[fName(122398)] = true, -- Pestilent Colossus
	[fName(115001)] = true, -- Bone Goliath
	[fName(118279)] = true, -- Ravenous Goliath
	[fName(118664)] = true, -- Pummeling Goliath
	[fName(114861)] = true, -- Blastbones
	[fName(117692)] = true, -- Blighted Blastbones
	[fName(117751)] = true, -- Stalking Blastbones
	[fName(114317)] = true, -- Skeletal Mage
	[fName(118680)] = true, -- Skeletal Archer
	[fName(118726)] = true, -- Skeletal Arcanist
	[fName(115710)] = true, -- Spirit Mender
	[fName(118840)] = true, -- Intensive Mender
	[fName(118912)] = true, -- Spirit Guardian
-- Vampire Skills
	[fName(32624)] = true, -- Blood Scion
	[fName(38931)] = true, -- Perfect Scion
	[fName(38932)] = true, -- Swarming Scion
	[fName(132141)] = true, -- Blood Frenzy
	[fName(134160)] = true, -- Simmering Frenzy
	[fName(135841)] = true, -- Sated Fury
	[fName(134583)] = true, -- Vampiric Drain
	[fName(135905)] = true, -- Drain Vigor
	[fName(137259)] = true, -- Exhilarating Drain
	[fName(32986)] = true, --  Mist Form
	[fName(38963)] = true, --  Elusive Mist 
	[fName(38965)] = true, --  Blood Mist
-- Werewolf Skills
	[fName(32455)] = true, -- Werewolf Transformation
	[fName(39075)] = true, -- Pack Leader
	[fName(39076)] = true, -- Werewolf Berserker
	[fName(32632)] = true, -- Pounce
	[fName(39104)] = true, -- Feral Pounce
	[fName(39105)] = true, -- Brutal Pounce
	[fName(58405)] = true, -- Piercing Howl
	[fName(58742)] = true, -- Howl of Despair
	[fName(58798)] = true, -- Howl of Agony
	[fName(32633)] = true, -- Roar
	[fName(39113)] = true, -- Ferocious Roar
	[fName(39114)] = true, -- Deafening Roar
	[fName(58310)] = true, -- Hircine's Bounty
	[fName(58317)] = true, -- Hircine's Rage
	[fName(58325)] = true, -- Hircine's Fortitude
	[fName(58855)] = true, -- Infectious Claws
	[fName(58864)] = true, -- Claws of Anguish
	[fName(58879)] = true, -- Claws of Life
}

VWoeAddon.StageDB = {
	[135397]	= 1,	-- [[Srendarr/Icons/Vamp_Stage1.dds]],	-- Stage 1 Vampirism
	[135399]	= 2,	-- [[Srendarr/Icons/Vamp_Stage2.dds]],	-- Stage 2 Vampirism
	[135400]	= 3,	-- [[Srendarr/Icons/Vamp_Stage3.dds]],	-- Stage 3 Vampirism
	[135402]	= 4,	-- [[Srendarr/Icons/Vamp_Stage4.dds]],	-- Stage 4 Vampirism
}
