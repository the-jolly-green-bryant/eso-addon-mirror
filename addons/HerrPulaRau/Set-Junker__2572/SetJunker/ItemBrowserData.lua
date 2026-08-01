ItemBrowserData = {
	flags = {
		crafted       = 0x01,
		jewelry       = 0x02,
		weapon        = 0x04,
		monster       = 0x08,
		mixedWeights  = 0x10,
		allianceStyle = 0x20,
		multiStyle    = 0x40,
		manualStyle   = 0x80,
		mythic        = 0x100,
	},

	items = {
		-- Crafted -------------------------------------------------------------
		{ 46177, 0x51, { 3, 381, 41 }, 2 }, -- Death's Wind
		{ 46563, 0x51, { 19, 383, 57 }, 3 }, -- Twilight's Embrace
		{ 46954, 0x51, { 3, 381, 41 }, 2 }, -- Night's Silence
		{ 47322, 0x51, { 20, 108, 117 }, 4 }, -- Whitestrake's Retribution
		{ 47712, 0x51, { 19, 383, 57 }, 3 }, -- Armor of the Seducer
		{ 48088, 0x51, { 104, 58, 101 }, 5 }, -- Vampire's Kiss
		{ 48478, 0x51, { 20, 108, 117 }, 4 }, -- Magnus' Gift
		{ 48869, 0x51, { 92, 382, 103 }, 6 }, -- Night Mother's Gaze
		{ 49252, 0x51, { 3, 381, 41 }, 2 }, -- Ashen Grip
		{ 49627, 0x51, { 347 }, 8 }, -- Oblivion's Foe
		{ 50001, 0x51, { 347 }, 8 }, -- Spectre's Eye
		{ 50389, 0x51, { 19, 383, 57 }, 3 }, -- Torug's Pact
		{ 50764, 0x51, { 20, 108, 117 }, 4 }, -- Hist Bark
		{ 51152, 0x51, { 92, 382, 103 }, 6 }, -- Willow's Path
		{ 51541, 0x51, { 92, 382, 103 }, 6 }, -- Hunding's Rage
		{ 51907, 0x51, { 104, 58, 101 }, 5 }, -- Song of Lamae
		{ 52288, 0x51, { 104, 58, 101 }, 5 }, -- Alessia's Bulwark
		{ 52669, 0x51, { 642 }, 8 }, -- Orgnum's Scales
		{ 53057, 0x51, { 267 }, 8 }, -- Eyes of Mara
		{ 53438, 0x51, { 642 }, 8 }, -- Kagrenac's Hope
		{ 53812, 0x51, { 267 }, 8 }, -- Shalidor's Curse
		{ 55233, 0x51, { 888 }, 8 }, -- Way of the Arena
		{ 58483, 0x51, { 888 }, 9 }, -- Twice-Born Star
		{ 60203, 0x51, { 584 }, 5 }, -- Noble's Conquest
		{ 60560, 0x51, { 584 }, 7 }, -- Redistributor
		{ 60903, 0x51, { 584 }, 9 }, -- Armor Master
		{ 69907, 0x51, { 684 }, 6 }, -- Law of Julianos
		{ 70243, 0x51, { 684 }, 3 }, -- Trial by Fire
		{ 70950, 0x51, { 684 }, 9 }, -- Morkuldin
		{ 72107, 0x51, { 816 }, 5 }, -- Tava's Favor
		{ 72471, 0x51, { 816 }, 7 }, -- Clever Alchemist
		{ 72674, 0x51, { 816 }, 9 }, -- Eternal Hunt
		{ 75484, 0x51, { 823 }, 5 }, -- Kvatch Gladiator
		{ 75819, 0x51, { 823 }, 7 }, -- Varen's Legacy
		{ 76169, 0x51, { 823 }, 9 }, -- Pelinal's Aptitude
		{ 121634, 0x51, { 849 }, 3 }, -- Assassin's Guile
		{ 121984, 0x51, { 849 }, 8 }, -- Daedric Trickery
		{ 122334, 0x51, { 849 }, 6 }, -- Shacklebreaker
		{ 130460, 0x51, { 980 }, 2 }, -- Innate Axiom
		{ 130803, 0x51, { 980, { 981 } }, 4 }, -- Fortified Brass
		{ 131168, 0x51, { 980 }, 6 }, -- Mechanical Acuity
		{ 135800, 0x51, { 1011 }, 3 }, -- Adept Rider
		{ 136157, 0x51, { 1011, { 1027 } }, 6 }, -- Sload's Semblance
		{ 136515, 0x51, { 1011 }, 9 }, -- Nocturnal's Favor
		{ 142894, 0x51, { 726 }, 7 }, -- Grave-Stake Collector
		{ 143271, 0x51, { 726 }, 2 }, -- Naga Shaman
		{ 143634, 0x51, { 726 }, 4 }, -- Might of the Lost Legion
		{ 148058, 0x51, { 1086 }, 8 }, -- Coldharbour's Favorite
		{ 148421, 0x51, { 1086 }, 5 }, -- Senche-raht's Grit
		{ 148791, 0x51, { 1086 }, 3 }, -- Vastarie's Tutelage
		{ 155507, 0x51, { 1133 }, 3 }, -- Daring Corsair
		{ 155881, 0x51, { 1133 }, 6 }, -- Ancient Dragonguard
		{ 156255, 0x51, { 1133 }, 9 }, -- New Moon Acolyte
		{ 158419, 0x51, { 181, { -202 } }, 3 }, -- Critical Riposte
		{ 158793, 0x51, { 181, { -201 } }, 3 }, -- Unchained Aggressor
		{ 159167, 0x51, { 181, { -203 } }, 3 }, -- Dauntless Combatant
		{ 161324, 0x51, { 1160 }, 5 }, -- Stuhn's Favor
		{ 161713, 0x51, { 1160 }, 7 }, -- Dragon's Appetite
		{ 163167, 0x51, { 1160, { 1161 } }, 3 }, -- Spell Parasite

		-- Non-Crafted ---------------------------------------------------------
		{ 68476, 0x20, { 643 } }, -- Black Rose
		{ 68483, 0x00, { 684 } }, -- Trinimac's Valor
		{ 68491, 0x00, { 684 } }, -- Briarheart
		{ 68571, 0x00, { 677 } }, -- Winterborn
		{ 68579, 0x20, { 643 } }, -- Powerful Assault
		{ 68652, 0x00, { 684 } }, -- Mark of the Pariah
		{ 68659, 0x20, { 643 } }, -- Meritorious Service
		{ 68667, 0x00, { 677 } }, -- Para Bellum
		{ 68740, 0x00, { 677 } }, -- Glorious Defender
		{ 68747, 0x00, { 677 } }, -- Elemental Succession
		{ 68755, 0x20, { 643 } }, -- Shield Breaker
		{ 68828, 0x00, { 677 } }, -- Permafrost
		{ 68835, 0x20, { 643 } }, -- Phoenix
		{ 68843, 0x00, { 677 } }, -- Hunt Leader
		{ 68916, 0x20, { 643 } }, -- Reactive Armor
		{ 72892, 0x10, { 816 } }, -- Bahraha's Curse
		{ 72972, 0x10, { 816 } }, -- Syvarra's Scales
		{ 73001, 0x00, { 725 } }, -- Moondancer
		{ 73027, 0x00, { 725 } }, -- Twilight Remedy
		{ 73051, 0x00, { 725 } }, -- Roar of Alkosh
		{ 73074, 0x00, { 725 } }, -- Lunar Bastion
		{ 73880, 0x00, { 181 } }, -- Marksman's Crest
		{ 73942, 0x00, { 181 } }, -- Leki's Focus
		{ 74004, 0x00, { 181 } }, -- Fasalla's Guile
		{ 74087, 0x00, { 181 } }, -- Warrior's Fury
		{ 74149, 0x00, { 181 } }, -- Vicious Death
		{ 74222, 0x00, { 181 } }, -- Robes of Transmutation
		{ 74824, 0x00, { 20 } }, -- Darkstride
		{ 74990, 0x00, { 108 } }, -- Shadow Dancer's Raiment
		{ 76969, 0x00, { 823 } }, -- Hide of Morihaus
		{ 77109, 0x00, { 823 } }, -- Flanking Strategist
		{ 77291, 0x10, { 823 } }, -- Sithis' Touch
		{ 78103, 0x00, { 643 } }, -- Galerion's Revenge
		{ 78391, 0x00, { 643 } }, -- Vicecanon of Venom
		{ 78656, 0x00, { 643 } }, -- Thews of the Harbinger
		{ 78954, 0x10, { 643 } }, -- Imperial Physique
		{ 79967, 0x00, { 636, 638, 639 } }, -- Eternal Warrior
		{ 80119, 0x00, { 636, 638, 639 } }, -- Vicious Serpent
		{ 80272, 0x00, { 636, 638, 639 } }, -- Infallible Mage
		{ 80735, 0x00, { 381 } }, -- Queen's Elegance
		{ 81065, 0x00, { 382 } }, -- Senche's Bite
		{ 82264, 0x00, { 843 } }, -- Aspect of Mazzatun
		{ 82447, 0x00, { 843 } }, -- Amber Plasm
		{ 82637, 0x00, { 843 } }, -- Heem-Jas' Retribution
		{ 82819, 0x00, { 848 } }, -- Hand of Mephala
		{ 83002, 0x00, { 848 } }, -- Gossamer
		{ 83192, 0x00, { 848 } }, -- Widowmaker
		{ 84558, 0x00, { 101 } }, -- Akaviri Dragonguard
		{ 84741, 0x00, { 41 } }, -- Silks of the Sun
		{ 84931, 0x00, { 41 } }, -- Shadow of the Red Mountain
		{ 85114, 0x00, { 383 } }, -- Syrabane's Grip
		{ 85486, 0x00, { 58 } }, -- Salvation
		{ 86041, 0x00, { 3 } }, -- Hide of the Werewolf
		{ 86224, 0x00, { 104 } }, -- Robes of the Withered Hand
		{ 86596, 0x00, { 19 } }, -- Storm Knight's Plate
		{ 86779, 0x00, { 20 } }, -- Necropotence
		{ 86969, 0x00, { 635 } }, -- Footman's Fortune
		{ 87152, 0x00, { 635 } }, -- Healer's Habit
		{ 87343, 0x00, { 635 } }, -- Robes of Destruction Mastery
		{ 87533, 0x00, { 635 } }, -- Archer's Mind
		{ 88020, 0x20, { 181, { -202, -204 } } }, -- Alessian Order
		{ 88384, 0x20, { 181, { -202, -204 } } }, -- Crest of Cyrodiil
		{ 88566, 0x20, { 181, { -202, -204 } } }, -- Bastion of the Heartland
		{ 88748, 0x20, { 181, { -202, -204 } } }, -- Beckoning Steel
		{ 88930, 0x20, { 181, { -202, -204 } } }, -- The Juggernaut
		{ 89294, 0x20, { 181, { -202, -205 } } }, -- Affliction
		{ 89476, 0x20, { 181, { -202, -205 } } }, -- Ravager
		{ 89840, 0x20, { 181, { -202, -205 } } }, -- Elf Bane
		{ 90261, 0x20, { 181, { -203, -204 } } }, -- Desert Rose
		{ 90834, 0x20, { 181, { -203, -204 } } }, -- Curse Eater
		{ 91025, 0x20, { 181, { -203, -204 } } }, -- Almalexia's Mercy
		{ 91407, 0x20, { 181, { -203, -204 } } }, -- Robes of Alteration Mastery
		{ 91598, 0x20, { 181, { -203, -205 } } }, -- The Arch-Mage
		{ 91789, 0x20, { 181, { -203, -205 } } }, -- Light of Cyrodiil
		{ 91980, 0x20, { 181, { -203, -204 } } }, -- Buffer of the Swift
		{ 92300, 0x80, { 381 }, 7 }, -- Twin Sisters
		{ 92664, 0x20, { 181, { -201, -204 } } }, -- Shield of the Valiant
		{ 92846, 0x20, { 181, { -201, -205 } } }, -- Shadow Walker
		{ 93210, 0x20, { 181, { -201, -205 } } }, -- Hawk's Eye
		{ 93392, 0x20, { 181, { -201, -205 } } }, -- The Morag Tong
		{ 93574, 0x20, { 181, { -201, -205 } } }, -- Kyne's Kiss
		{ 93756, 0x20, { 181, { -201, -205 } } }, -- Ward of Cyrodiil
		{ 93938, 0x20, { 181, { -201, -205 } } }, -- Sentry
		{ 94289, 0x00, { 381 } }, -- Armor of the Veiled Heritance
		{ 95305, 0x00, { 888 } }, -- Way of Fire
		{ 95488, 0x00, { 888 } }, -- Way of Martial Knowledge
		{ 95698, 0x00, { 888 } }, -- Way of Air
		{ 95983, 0x50, { 534, 537, 280, 535, 281 } }, -- Armor of the Trainee
		{ 96432, 0x00, { 3 } }, -- Bloodthorn's Touch
		{ 96622, 0x00, { 41 } }, -- Shalk Exoskeleton
		{ 96804, 0x00, { 3 } }, -- Wyrd Tree's Blessing
		{ 96979, 0x00, { 57 } }, -- Night Mother's Embrace
		{ 97070, 0x00, { 57 } }, -- Plague Doctor
		{ 97253, 0x00, { 57 } }, -- Mother's Sorrow
		{ 97443, 0x00, { 108 } }, -- Wilderqueen's Arch
		{ 97625, 0x00, { 383 } }, -- Green Pact
		{ 97807, 0x00, { 19 } }, -- Night Terror
		{ 97990, 0x00, { 19 } }, -- Dreamer's Mantle
		{ 98180, 0x00, { 383 } }, -- Ranger's Gait
		{ 98362, 0x00, { 108 } }, -- Beekeeper's Gear
		{ 98544, 0x00, { 20 } }, -- Vampire Cloak
		{ 98727, 0x00, { 117 } }, -- Robes of the Hist
		{ 98917, 0x00, { 117 } }, -- Swamp Raider
		{ 99099, 0x00, { 117 } }, -- Hatchling's Shell
		{ 99318, 0x00, { 104 } }, -- Sword-Singer
		{ 99500, 0x00, { 104 } }, -- Order of Diagna
		{ 99683, 0x00, { 58 } }, -- Spinner's Garments
		{ 99873, 0x00, { 58 } }, -- Thunderbug's Carapace
		{ 100056, 0x00, { 101 } }, -- Stendarr's Embrace
		{ 100246, 0x00, { 101 } }, -- Fiord's Legacy
		{ 100432, 0x00, { 92 } }, -- Vampire Lord
		{ 100622, 0x00, { 92 } }, -- Spriggan's Thorns
		{ 100804, 0x00, { 92 } }, -- Seventh Legion Brute
		{ 100987, 0x00, { 382 } }, -- Skooma Smuggler
		{ 101177, 0x00, { 382 } }, -- Soulshine
		{ 101360, 0x00, { 103 } }, -- Ysgramor's Birthright
		{ 101550, 0x00, { 103 } }, -- Witchman Armor
		{ 101732, 0x00, { 103 } }, -- Draugr's Heritage
		{ 101916, 0x00, { 347 } }, -- Prisoner's Rags
		{ 102106, 0x00, { 347 } }, -- Stygian
		{ 102288, 0x00, { 347 } }, -- Meridia's Blessed Armor
		{ 102471, 0x00, { 380, 935 } }, -- Sanctuary
		{ 102661, 0x00, { 380, 935 } }, -- Jailbreaker
		{ 102843, 0x00, { 380, 935 } }, -- Tormentor
		{ 103025, 0x00, { 144, 936 } }, -- Spelunker
		{ 103208, 0x00, { 283, 934 } }, -- Spider Cultist Cowl
		{ 103399, 0x00, { 126, 931 } }, -- Light Speaker
		{ 103589, 0x00, { 126, 931 } }, -- Undaunted Bastion
		{ 103772, 0x00, { 146, 933 } }, -- Combat Physician
		{ 103962, 0x00, { 146, 933 } }, -- Toothrow
		{ 104145, 0x00, { 63, 930 } }, -- Netch's Touch
		{ 104335, 0x00, { 63, 930 } }, -- Strength of the Automaton
		{ 104518, 0x00, { 176, 681 } }, -- Burning Spellweave
		{ 104708, 0x00, { 176, 681 } }, -- Sunderflame
		{ 104890, 0x00, { 176, 681 } }, -- Embershield
		{ 105072, 0x00, { 31 } }, -- Hircine's Veneer
		{ 105254, 0x00, { 64 } }, -- Sword Dancer
		{ 105437, 0x00, { 22 } }, -- Treasure Hunter
		{ 105627, 0x00, { 22 } }, -- Duneripper's Scales
		{ 105810, 0x00, { 130, 932 } }, -- Shroud of the Lich
		{ 106000, 0x00, { 130, 932 } }, -- Leviathan
		{ 106182, 0x00, { 130, 932 } }, -- Ebon Armory
		{ 106365, 0x00, { 148 } }, -- Lamia's Song
		{ 106555, 0x00, { 148 } }, -- Undaunted Infiltrator
		{ 106737, 0x00, { 148 } }, -- Medusa
		{ 106920, 0x00, { 449 } }, -- Magicka Furnace
		{ 107110, 0x00, { 449 } }, -- Draugr Hulk
		{ 107293, 0x00, { 38 } }, -- Undaunted Unweaver
		{ 107483, 0x00, { 38 } }, -- Bone Pirate's Tatters
		{ 107665, 0x00, { 38 } }, -- Knight-errant's Mail
		{ 107848, 0x00, { 144, 936 } }, -- Prayer Shawl
		{ 108038, 0x00, { 144, 936 } }, -- Knightmare
		{ 108220, 0x00, { 283, 934 } }, -- Viper's Sting
		{ 108402, 0x00, { 283, 934 } }, -- Dreugh King Slayer
		{ 108584, 0x00, { 126, 931 } }, -- Barkskin
		{ 108766, 0x00, { 146, 933 } }, -- Sergeant's Mail
		{ 108948, 0x00, { 63, 930 } }, -- Armor of Truth
		{ 109150, 0x00, { 22 } }, -- Crusader
		{ 109312, 0x00, { 449 } }, -- The Ice Furnace
		{ 109495, 0x00, { 31 } }, -- Vestments of the Warlock
		{ 109685, 0x00, { 31 } }, -- Durok's Bane
		{ 109868, 0x00, { 64 } }, -- Noble Duelist's Silks
		{ 110058, 0x00, { 64 } }, -- Nikulas' Heavy Armor
		{ 110241, 0x00, { 131 } }, -- Overwhelming Surge
		{ 110431, 0x00, { 131 } }, -- Storm Master
		{ 110613, 0x00, { 131 } }, -- Jolting Arms
		{ 110796, 0x00, { 11 } }, -- The Worm's Raiment
		{ 110986, 0x00, { 11 } }, -- Oblivion's Edge
		{ 111168, 0x00, { 11 } }, -- Rattlecage
		{ 111351, 0x00, { 678 } }, -- Scathing Mage
		{ 111541, 0x00, { 678 } }, -- Sheer Venom
		{ 111723, 0x00, { 678 } }, -- Leeching Plate
		{ 111906, 0x00, { 688 } }, -- Spell Power Cure
		{ 112096, 0x00, { 688 } }, -- Essence Thief
		{ 112278, 0x00, { 688 } }, -- Brands of Imperium
		{ 112479, 0x00, { 638 } }, -- Healing Mage
		{ 112669, 0x00, { 638 } }, -- Quick Serpent
		{ 112851, 0x00, { 638 } }, -- Defending Warrior
		{ 113034, 0x00, { 636 } }, -- Destructive Mage
		{ 113224, 0x00, { 636 } }, -- Poisonous Serpent
		{ 113406, 0x00, { 636 } }, -- Berserking Warrior
		{ 113589, 0x00, { 639 } }, -- Wise Mage
		{ 113779, 0x00, { 639 } }, -- Twice-Fanged Serpent
		{ 113961, 0x00, { 639 } }, -- Immortal Warrior
		{ 122645, 0x00, { 849 } }, -- Warrior-Poet
		{ 122828, 0x00, { 849 } }, -- War Maiden
		{ 123018, 0x00, { 849 } }, -- Infector
		{ 123201, 0x00, { -2 } }, -- Vanguard's Challenge
		{ 123383, 0x00, { -2 } }, -- Coward's Gear
		{ 123566, 0x00, { -2 } }, -- Knight Slayer
		{ 123757, 0x00, { -2 } }, -- Wizard's Riposte
		{ 123947, 0x00, { 975 } }, -- Automated Defense
		{ 124129, 0x00, { 975 } }, -- War Machine
		{ 124312, 0x00, { 975 } }, -- Master Architect
		{ 124503, 0x00, { 975 } }, -- Inventor's Guard
		{ 125743, 0x10, { -2 } }, -- Impregnable Armor
		{ 127185, 0x00, { 974 } }, -- Ironblood
		{ 127368, 0x00, { 974 } }, -- Draugr's Rest
		{ 127558, 0x00, { 974 } }, -- Pillar of Nirn
		{ 127788, 0x00, { 973 } }, -- Hagraven's Garden
		{ 127971, 0x00, { 973 } }, -- Flame Blossom
		{ 128161, 0x00, { 973 } }, -- Blooddrinker
		{ 128407, 0x00, { 1009 } }, -- Ulfnor's Favor
		{ 128590, 0x00, { 1009 } }, -- Caluurion's Legacy
		{ 128780, 0x00, { 1009 } }, -- Trappings of Invigoration
		{ 128962, 0x00, { 1010 } }, -- Curse of Doylemish
		{ 129145, 0x00, { 1010 } }, -- Jorvuld's Guidance
		{ 129335, 0x00, { 1010 } }, -- Plague Slinger
		{ 132884, 0x00, { 980, 1000 } }, -- Mad Tinkerer
		{ 133074, 0x00, { 980, 1000 } }, -- Unfathomable Darkness
		{ 132701, 0x00, { 980, 1000 } }, -- Livewire
		{ 135197, 0x00, { 1011, 1027 } }, -- Grace of Gloom
		{ 135379, 0x00, { 1011, 1027 } }, -- Gryphon's Ferocity
		{ 135562, 0x00, { 1011, 1027 } }, -- Wisdom of Vanus
		{ 136802, 0x00, { 1051 } }, -- Aegis of Galenwe
		{ 136984, 0x00, { 1051 } }, -- Arms of Relequen
		{ 137167, 0x00, { 1051 } }, -- Mantle of Siroria
		{ 137358, 0x00, { 1051 } }, -- Vestment of Olorime
		{ 137999, 0x00, { 1051 } }, -- Perfect Aegis of Galenwe
		{ 138181, 0x00, { 1051 } }, -- Perfect Arms of Relequen
		{ 138364, 0x00, { 1051 } }, -- Perfect Mantle of Siroria
		{ 138555, 0x00, { 1051 } }, -- Perfect Vestment of Olorime
		{ 140547, 0x00, { 1055 } }, -- Haven of Ursus
		{ 140730, 0x00, { 1055 } }, -- Hanu's Compassion
		{ 140920, 0x00, { 1055 } }, -- Blood Moon
		{ 141102, 0x00, { 1052 } }, -- Jailer's Tenacity
		{ 141285, 0x00, { 1052 } }, -- Moon Hunter
		{ 141475, 0x00, { 1052 } }, -- Savage Werewolf
		{ 142271, 0x00, { 726, 1082 } }, -- Champion of the Hist
		{ 142453, 0x00, { 726, 1082 } }, -- Dead-Water's Guile
		{ 142636, 0x00, { 726, 1082 } }, -- Bright-Throat's Boast
		{ 143937, 0x20, { -4 } }, -- Indomitable Fury
		{ 144128, 0x20, { -4 } }, -- Spell Strategist
		{ 144318, 0x20, { -4 } }, -- Battlefield Acrobat
		{ 144500, 0x20, { -4 } }, -- Soldier of Anguish
		{ 144682, 0x20, { -4 } }, -- Steadfast Hero
		{ 144864, 0x20, { -4 } }, -- Battalion Defender
		{ 146112, 0x00, { 1080 } }, -- Mighty Glacier
		{ 146294, 0x00, { 1080 } }, -- Tzogvin's Warband
		{ 146477, 0x00, { 1080 } }, -- Icy Conjuror
		{ 146715, 0x00, { 1081 } }, -- Frozen Watcher
		{ 146897, 0x00, { 1081 } }, -- Scavenging Demise
		{ 147080, 0x00, { 1081 } }, -- Auroran's Thunder
		{ 147372, 0x20, { 181, { -201, -205 } } }, -- Deadly Strike
		{ 149093, 0x00, { 1086 } }, -- Call of the Undertaker
		{ 149276, 0x00, { 1086 } }, -- Crafty Afliq
		{ 149466, 0x00, { 1086 } }, -- Vesture of Darloc Brae
		{ 149648, 0x00, { 1121 } }, -- Claw of Yolnahkriin
		{ 149830, 0x00, { 1121 } }, -- Tooth of Lokkestiiz
		{ 150013, 0x00, { 1121 } }, -- False God's Devotion
		{ 150204, 0x00, { 1121 } }, -- Eye of Nahviintaas
		{ 150849, 0x00, { 1121 } }, -- Perfected Claw of Yolnahkriin
		{ 151031, 0x00, { 1121 } }, -- Perfected Tooth of Lokkestiiz
		{ 151214, 0x00, { 1121 } }, -- Perfected False God's Devotion
		{ 151405, 0x00, { 1121 } }, -- Perfected Eye of Nahviintaas
		{ 152391, 0x00, { 1122 } }, -- Renald's Resolve
		{ 152574, 0x00, { 1122 } }, -- Hollowfang Thirst
		{ 152764, 0x00, { 1122 } }, -- Dro'Zakar's Claws
		{ 152946, 0x00, { 1123 } }, -- Dragon's Defilement
		{ 153129, 0x00, { 1123 } }, -- Z'en's Redress
		{ 153319, 0x00, { 1123 } }, -- Azureblight Reaper
		{ 154871, 0x00, { 1133 } }, -- Senchal Defender
		{ 155057, 0x00, { 1133 } }, -- Marauder's Haste
		{ 155250, 0x00, { 1133 } }, -- Dragonguard Elite
		{ 156885, 0x00, { 1152 } }, -- Hiti's Hearth
		{ 157078, 0x00, { 1152 } }, -- Titanborn Strength
		{ 157263, 0x00, { 1152 } }, -- Bani's Torment
		{ 157571, 0x00, { 1153 } }, -- Draugrkin's Grip
		{ 157764, 0x00, { 1153 } }, -- Aegis Caller
		{ 157949, 0x00, { 1153 } }, -- Grave Guardian
		{ 160663, 0x00, { 1160, 1161 } }, -- Winter's Respite
		{ 160856, 0x00, { 1160, 1161 } }, -- Venomous Smite
		{ 161041, 0x00, { 1160, 1161 } }, -- Eternal Vigor
		{ 162001, 0x00, { 1196 } }, -- Roaring Opportunist
		{ 162135, 0x00, { 1196 } }, -- Yandir's Might
		{ 162264, 0x00, { 1196 } }, -- Vrol's Command
		{ 162410, 0x00, { 1196 } }, -- Kyne's Wind
		{ 162544, 0x00, { 1196 } }, -- Perfected Roaring Opportunist
		{ 162678, 0x00, { 1196 } }, -- Perfected Yandir's Might
		{ 162807, 0x00, { 1196 } }, -- Perfected Vrol's Command
		{ 162953, 0x00, { 1196 } }, -- Perfected Kyne's Wind

		-- Monster Sets --------------------------------------------------------
		{ 59391, 0x18, { 934, { -101 } } }, -- Spawn of Mephala
		{ 59427, 0x18, { 936, { -101 } } }, -- Blood Spawn
		{ 59457, 0x18, { 678, { -103 } } }, -- Lord Warden
		{ 59493, 0x18, { 933, { -101 } } }, -- Scourge Harvester
		{ 59529, 0x18, { 930, { -101 } } }, -- Engine Guardian
		{ 59577, 0x18, { 931, { -101 } } }, -- Nightflame
		{ 59613, 0x18, { 932, { -102 } } }, -- Nerien'eth
		{ 59649, 0x18, { 681, { -102 } } }, -- Valkyn Skoria
		{ 59679, 0x18, { 935, { -101 } } }, -- Maw of the Infernal
		{ 68124, 0x18, { 688, { -103 } } }, -- Molag Kena
		{ 82130, 0x18, { 848, { -103 } } }, -- Velidreth
		{ 82176, 0x18, { 843, { -103 } } }, -- Mighty Chudan
		{ 94477, 0x18, { 144, { -101 } } }, -- Swarm Mother
		{ 94501, 0x18, { 146, { -101 } } }, -- Slimecraw
		{ 94549, 0x18, {  22, { -102 } } }, -- Tremorscale
		{ 94557, 0x18, {  38, { -102 } } }, -- Pirate Skeleton
		{ 94733, 0x18, { 380, { -101 } } }, -- Shadowrend
		{ 94757, 0x18, {  63, { -101 } } }, -- Sentinel of Rkugamz
		{ 94765, 0x18, { 126, { -101 } } }, -- Chokethorn
		{ 94789, 0x18, { 176, { -102 } } }, -- Infernal Guardian
		{ 94797, 0x18, { 130, { -102 } } }, -- Ilambris
		{ 94805, 0x18, { 449, { -102 } } }, -- Iceheart
		{ 94837, 0x18, {  64, { -102 } } }, -- The Troll King
		{ 94853, 0x18, {  11, { -102 } } }, -- Grothdarr
		{ 95013, 0x18, { 283, { -101 } } }, -- Kra'gh
		{ 95053, 0x18, { 148, { -102 } } }, -- Sellistrix
		{ 95085, 0x18, { 131, { -102 } } }, -- Stormfist
		{ 95117, 0x18, {  31, { -102 } } }, -- Selene
		{ 127722, 0x18, { 973, { -103 } } }, -- Earthgore
		{ 128309, 0x18, { 974, { -103 } } }, -- Domihaus
		{ 129483, 0x18, { 1009, { -103 } } }, -- Thurvokun
		{ 129547, 0x18, { 1010, { -103 } } }, -- Zaan
		{ 141628, 0x18, { 1055, { -103 } } }, -- Balorgh
		{ 141676, 0x18, { 1052, { -103 } } }, -- Vykosa
		{ 146638, 0x18, { 1080, { -103 } } }, -- Stonekeeper
		{ 147243, 0x18, { 1081, { -103 } } }, -- Symphony of Blades
		{ 152266, 0x18, { 1122, { -103 } } }, -- Grundwulf
		{ 152318, 0x18, { 1123, { -103 } } }, -- Maarselok
		{ 158177, 0x18, { 1152, { -103 } } }, -- Mother Ciannait
		{ 158239, 0x18, { 1153, { -103 } } }, -- Kjalnar's Nightmare

		-- 3p Jewelry Sets -----------------------------------------------------
		{ 69166, 0x22, { 584, -1 } }, -- Endurance
		{ 69278, 0x22, { 584, -1 } }, -- Willpower
		{ 69390, 0x22, { 584, -1 } }, -- Agility
		{ 87748, 0x22, { 181, { -202 } } }, -- Blessing of the Potentates
		{ 89988, 0x22, { 181, { -203 } } }, -- Wrath of the Imperium
		{ 90107, 0x22, { 181, { -203 } } }, -- Grace of the Ancients
		{ 92136, 0x22, { 181, { -201 } } }, -- Eagle Eye
		{ 92147, 0x22, { 181, { -201 } } }, -- Vengeance Leech

		-- Special Weapons -----------------------------------------------------
		{ 133275, 0x04, { 1000 } }, -- The Asylum's Perfected Restoration Staff
		{ 133284, 0x04, { 1000 } }, -- The Asylum's Perfected Dagger
		{ 133287, 0x04, { 1000 } }, -- The Asylum's Perfected Greatsword
		{ 133288, 0x04, { 1000 } }, -- The Asylum's Perfected Bow
		{ 133289, 0x04, { 1000 } }, -- The Asylum's Perfected Inferno Staff
		{ 133296, 0x04, { 1000 } }, -- The Asylum's Perfected Sword
		{ 133428, 0x04, { 1000 } }, -- The Asylum's Restoration Staff
		{ 133437, 0x04, { 1000 } }, -- The Asylum's Dagger
		{ 133440, 0x04, { 1000 } }, -- The Asylum's Greatsword
		{ 133441, 0x04, { 1000 } }, -- The Asylum's Bow
		{ 133442, 0x04, { 1000 } }, -- The Asylum's Inferno Staff
		{ 133449, 0x04, { 1000 } }, -- The Asylum's Sword
		{ 133657, 0x04, { 677 } }, -- The Maelstrom's Restoration Staff
		{ 133666, 0x04, { 677 } }, -- The Maelstrom's Dagger
		{ 133669, 0x04, { 677 } }, -- The Maelstrom's Greatsword
		{ 133670, 0x04, { 677 } }, -- The Maelstrom's Bow
		{ 133671, 0x04, { 677 } }, -- The Maelstrom's Inferno Staff
		{ 133678, 0x04, { 677 } }, -- The Maelstrom's Sword
		{ 133810, 0x04, { 635 } }, -- The Master's Restoration Staff
		{ 133819, 0x04, { 635 } }, -- The Master's Dagger
		{ 133822, 0x04, { 635 } }, -- The Master's Greatsword
		{ 133823, 0x04, { 635 } }, -- The Master's Bow
		{ 133824, 0x04, { 635 } }, -- The Master's Inferno Staff
		{ 133831, 0x04, { 635 } }, -- The Master's Sword
		{ 145043, 0x04, { 1082 } }, -- Blackrose Restoration Staff
		{ 145052, 0x04, { 1082 } }, -- Blackrose Dagger
		{ 145055, 0x04, { 1082 } }, -- Blackrose Greatsword
		{ 145056, 0x04, { 1082 } }, -- Blackrose Bow
		{ 145057, 0x04, { 1082 } }, -- Blackrose Inferno Staff
		{ 145064, 0x04, { 1082 } }, -- Blackrose Sword
		{ 145196, 0x04, { 1082 } }, -- Blackrose Perfected Restoration Staff
		{ 145205, 0x04, { 1082 } }, -- Blackrose Perfected Dagger
		{ 145208, 0x04, { 1082 } }, -- Blackrose Perfected Greatsword
		{ 145209, 0x04, { 1082 } }, -- Blackrose Perfected Bow
		{ 145210, 0x04, { 1082 } }, -- Blackrose Perfected Inferno Staff
		{ 145217, 0x04, { 1082 } }, -- Blackrose Perfected Sword
		{ 166081, 0x04, { 635 } }, -- Perfected Grand Rejuvenation
		{ 166090, 0x04, { 635 } }, -- Perfected Stinging Slashes
		{ 166093, 0x04, { 635 } }, -- Perfected Titanic Cleave
		{ 166094, 0x04, { 635 } }, -- Perfected Caustic Arrow
		{ 166095, 0x04, { 635 } }, -- Perfected Destructive Impact
		{ 166102, 0x04, { 635 } }, -- Perfected Puncturing Remedy
		{ 166218, 0x04, { 677 } }, -- Perfected Precise Regeneration
		{ 166227, 0x04, { 677 } }, -- Perfected Cruel Flurry
		{ 166230, 0x04, { 677 } }, -- Perfected Merciless Charge
		{ 166231, 0x04, { 677 } }, -- Perfected Thunderous Volley
		{ 166232, 0x04, { 677 } }, -- Perfected Crushing Wall
		{ 166239, 0x04, { 677 } }, -- Perfected Rampaging Slash

		-- Level Up Rewards ----------------------------------------------------
		--{ 134955, 0x02, { -3 } }, -- Broken Soul
		--{ 134975, 0x02, { -3 } }, -- Prophet's

		-- Mythic Items --------------------------------------------------------
		{ 163052, 0x102, { -5 } }, -- Ring of the Wild Hunt
		{ 163451, 0x102, { -5 } }, -- Torc of Tonal Constancy
		{ 164291, 0x100, { -5 } }, -- Thrassian Stranglers
		{ 165879, 0x100, { -5 } }, -- Snow Treaders
		{ 165880, 0x102, { -5 } }, -- Malacath's Band of Brutality
		{ 165899, 0x100, { -5 } }, -- Bloodlord's Embrace
	},

	specialNames = {
		[-101] = "Maj",
		[-102] = "Glirion",
		[-103] = "Urgarlag",

		[-201] = "Bruma",
		[-202] = "Vlastarus",
		[-203] = "Cropsford",
		[-204] = "Chorrol",
		[-205] = "Cheydinhal",
	},

	zoneTypes = {
		overland = 1,
		pvp      = 2,
		dungeon  = 3,
		trial    = 4,
	},

	zoneClassification = {
		-- Daggerfall Covenant -------------------------------------------------
		[ 534] = 1, -- Stros M'Kai
		[ 535] = 1, -- Betnikh
		[   3] = 1, -- Glenumbra
		[  19] = 1, -- Stormhaven
		[  20] = 1, -- Rivenspire
		[ 104] = 1, -- Alik'r Desert
		[  92] = 1, -- Bangkorai

		-- Aldmeri Dominion ----------------------------------------------------
		[ 537] = 1, -- Khenarthi's Roost
		[ 381] = 1, -- Auridon
		[ 383] = 1, -- Grahtwood
		[ 108] = 1, -- Greenshade
		[  58] = 1, -- Malabal Tor
		[ 382] = 1, -- Reaper's March

		-- Ebonheart Pact ------------------------------------------------------
		[ 280] = 1, -- Bleakrock Isle
		[ 281] = 1, -- Bal Foyen
		[  41] = 1, -- Stonefalls
		[  57] = 1, -- Deshaan
		[ 117] = 1, -- Shadowfen
		[ 101] = 1, -- Eastmarch
		[ 103] = 1, -- The Rift

		-- Neutral -------------------------------------------------------------
		[ 347] = 1, -- Coldharbour
		[ 267] = 1, -- Eyevea
		[ 642] = 1, -- The Earth Forge
		[ 888] = 1, -- Craglorn
		[ 684] = 1, -- Wrothgar
		[ 816] = 1, -- Hew's Bane
		[ 823] = 1, -- The Gold Coast
		[ 849] = 1, -- Vvardenfell
		[ 980] = 1, -- The Clockwork City
		[ 981] = 1, -- The Brass Fortress
		[1011] = 1, -- Summerset
		[1027] = 1, -- Artaeum
		[ 726] = 1, -- Murkmire
		[1086] = 1, -- Northern Elsweyr
		[1133] = 1, -- Southern Elsweyr
		[1160] = 1, -- Western Skyrim
		[1161] = 1, -- Blackreach: Greymoor Caverns

		-- PvP -----------------------------------------------------------------
		[ 181] = 2, -- Cyrodiil
		[ 584] = 2, -- Imperial City
		[ 643] = 2, -- Imperial Sewers

		-- Dungeons ------------------------------------------------------------
		[ 144] = 3, -- Spindleclutch I
		[ 936] = 3, -- Spindleclutch II
		[ 380] = 3, -- The Banished Cells I
		[ 935] = 3, -- The Banished Cells II
		[ 283] = 3, -- Fungal Grotto I
		[ 934] = 3, -- Fungal Grotto II
		[ 146] = 3, -- Wayrest Sewers I
		[ 933] = 3, -- Wayrest Sewers II
		[ 126] = 3, -- Elden Hollow I
		[ 931] = 3, -- Elden Hollow II
		[  63] = 3, -- Darkshade Caverns I
		[ 930] = 3, -- Darkshade Caverns II
		[ 130] = 3, -- Crypt of Hearts I
		[ 932] = 3, -- Crypt of Hearts II
		[ 176] = 3, -- City of Ash I
		[ 681] = 3, -- City of Ash II
		[ 148] = 3, -- Arx Corinium
		[  22] = 3, -- Volenfell
		[ 131] = 3, -- Tempest Island
		[ 449] = 3, -- Direfrost Keep
		[  38] = 3, -- Blackheart Haven
		[  31] = 3, -- Selene's Web
		[  64] = 3, -- Blessed Crucible
		[  11] = 3, -- Vaults of Madness
		[ 678] = 3, -- Imperial City Prison
		[ 688] = 3, -- White-Gold Tower
		[ 843] = 3, -- Ruins of Mazzatun
		[ 848] = 3, -- Cradle of Shadows
		[ 973] = 3, -- Bloodroot Forge
		[ 974] = 3, -- Falkreath Hold
		[1009] = 3, -- Fang Lair
		[1010] = 3, -- Scalecaller Peak
		[1052] = 3, -- Moon Hunter Keep
		[1055] = 3, -- March of Sacrifices
		[1080] = 3, -- Frostvault
		[1081] = 3, -- Depths of Malatar
		[1122] = 3, -- Moongrave Fane
		[1123] = 3, -- Lair of Maarselok
		[1152] = 3, -- Icereach
		[1153] = 3, -- Unhallowed Grave

		-- Trials --------------------------------------------------------------
		[ 636] = 4, -- Hel Ra Citadel
		[ 638] = 4, -- Aetherian Archive
		[ 639] = 4, -- Sanctum Ophidia
		[ 635] = 4, -- Dragonstar Arena
		[ 677] = 4, -- Maelstrom Arena
		[ 725] = 4, -- Maw of Lorkhaj
		[ 975] = 4, -- Halls of Fabrication
		[1000] = 4, -- Asylum Sanctorium
		[1051] = 4, -- Cloudrest
		[1082] = 4, -- Blackrose Prison
		[1121] = 4, -- Sunspire
		[1196] = 4, -- Kyne's Aegis

		-- Miscellaneous -------------------------------------------------------
		[  -1] = 3, -- Random Dungeon Finder
		[  -2] = 2, -- Battlegrounds
		[  -3] = 0, -- Level Up Rewards
		[  -4] = 2, -- Rewards for the Worthy
		[  -5] = 1, -- Antiquities
	},
}
