Rotations = Rotations or {}

Rotations.Dots = {
    61919, --	Nightblade		- 	Assassination		-	Merciless Resolve
    61930, --	Nightblade		-	Assassination		-	Merciless Resolve Proc
    39053, --	Weapon			-	Destruction Staff	-	Unstable Wall of Fire
    --39052,			--	Weapon			-	Destruction Staff	-	Unstable Wall of Elements

    20930, --	Dragonknight	-	Ardent Flame		-	Engulfing Flames
    35823, --	Dragonknight	-	Ardent Flame		-	Flames of Oblivion
    20660, --	Dragonknight	-	Ardent Flame		-	Burning Embers
    22095, --	Templar			-	Dawn's Wrath		-	Solar Barrage
    26869, --	Templar			-	Aedric Spear		-	Blazing Spear
    36049, --	Nightblade		-	Shadow				-	Twisting Path
    24328, --	Sorcerer		-	Daedric Summoning	-	Daedric Prey
    114716, --	Sorcerer		-	Dark Magic			-	Crystal Shards Proc
    117749, --	Necromancer		-	Grave Lord			-	Stalking Blastbones
    86015, --	Warden			-	Animal Companions	-	Deep Fissure
    86169, --	Warden			-	Winter's Embrace	-	Winter's Revenge
    42028, --	Guild			-	Undaunted			-	Mystic Orb
    117850, --	Necromancer		-	Grave Lord			-	Avid Boneyard
    35434, --	Nightblade		-	Shadow				-	Dark Shade
    40382, --	Guild			-	Fighters Guild		-	Barbed trap
    103706, --	Guild			-	Psijic Order		-	Channeled Acceleration
    118726, --	Necromancer		-	Grave Lord			-	Skeletal Mage
    118763, --	Necromancer		-	Grave Lord			-	Detonating Siphon
    32710, --	Dragonknight	-	Earthen Heart		-	Eruption
    40465, --	Guild			-	Mages Guild			-	Scalding Rune
    36943, --	Nightblade		-	Siphoning			-	Debilitate
    77182, --	Sorcerer		-	Daedric Summoning	-	Summon Volatile Familiar
    86027, --	Warden			-	Animal Companions	-	Fetcher Infection
    40457, --	Guild			-	Mages Guild			-	Degeneration
    22259, --	Templar			-	Restoring Light		-	Ritual of Retribution
    36935, --	Nightblade		-	Siphoning			-	Siphoning Attacks
    22240, --	Templar			-	Restoring Light		-	Channeled Focus
    86054, --	Warden			-	Animal Companions	-	Blue Betty
    21765 --	Templar			-	Dawn's Wrath		-	Purifying Light 			(low priority to make sure that at least 1 spammable gets casted after this)
}

Rotations.AdditionalSkillDurations = {
    --	barbed trap (reapply every 16 sec due to 2 sec arming)
    [40382] = 16,
    --	volatile familiar
    [77182] = 10,
    --	channeled acceleration
    [103706] = 34.7,
	--	stalking blastbones
	[117749] = 3,
	--	scalding rune
	[40465] = 12
}

Rotations.Spammables = {
    25267, --	Nightblade		-	Shadow				-	Concealed Weapon
    34835, --	Nightblade		-	Siphoning			-	Swallow Soul
    46324, --	Sorcerer		-	Dark Magic			-	Crystal Shards
    26797, --	Templar			-	Aedric Spear		-	Puncturing Sweeps
    20805, --	Dragonknight	-	Ardent Flame		-	Molten Whip
    103571, --	Guild			-	Psijic Order		-	Elemental Weapon
    46356, --	Weapon			-	Destruction Staff	-	Force Pulse
	
	--	executes
    63046, --	Templar			-	Dawn's Wrath		-	Radiant Oppression
    34851 --	Nightblade		-	Assassination		-	Impale
}

Rotations.SkillsToDropAtHpPercent = {
    [25267] = 0.25, --	Nightblade		-	Shadow				-	Concealed Weapon
    [34835] = 0.25, --	Nightblade		-	Siphoning			-	Swallow Soul
    [61919] = 0.25, --	Nightblade		- 	Assassination		-	Merciless Resolve
    [61930] = 0.25, --	Nightblade		-	Assassination		-	Merciless Resolve Proc
    [36943] = 0.25, --	Nightblade		-	Siphoning			-	Debilitate
    [40457] = 0.25, --	Guild			-	Mages Guild			-	Degeneration
    [36935] = 0.25, --	Nightblade		-	Siphoning			-	Siphoning Attacks
    [26797] = 0.25, --	Templar			-	Aedric Spear		-	Puncturing Sweeps
    [22095] = 0.2, --	Templar			-	Dawn's Wrath		-	Solar Barrage
    [42028] = 0.1, --	Guild			-	Undaunted			-	Mystic Orb
    [26869] = 0.05, --	Templar			-	Aedric Spear		-	Blazing Spear
    [22240] = 0.05, --	Templar			-	Restoring Light		-	Channeled Focus
    [22259] = 0.05, --	Templar			-	Restoring Light		-	Ritual of Retribution
    [35434] = 0.05, --	Nightblade		-	Shadow				-	Dark Shade
    [40382] = 0.05, --	Guild			-	Fighters Guild		-	Barbed trap
    [103706] = 0.05, --	Guild			-	Psijic Order		-	Channeled Acceleration
    [39053] = 0.05, --	Weapon			-	Destruction Staff	-	Unstable Wall of Fire
    [39052] = 0.05, --	Weapon			-	Destruction Staff	-	Unstable Wall of Elements
    [36049] = 0.05, --	Nightblade		-	Shadow				-	Twisting Path
    [21765] = 0.05 --	Templar			-	Dawn's Wrath		-	Purifying Light
}
