-- * _JOKER_VERSION: 0.0.1 ** Please do not modify this line.
--[[----------------------------------------------------------
	Joker - Jokes, Riddles, Fun Facts, & Other Tomfoolery
  ----------------------------------------------------------
  *
  * ADDING YOUR OWN TRIVIA:
  * Be aware that modifying this file incorrectly could break Joker,
  * so for normal users I recommend just compiling your trivia in the
  * '_MyCustomTrivia.lua' file instead.
  *
  * COMPILATION: ESO-related trivia
	*
	* SOURCES:
  * ESO Wiki, Reddit, UESP
	*
]]--

JokerData = JokerData or {}
JokerData.Config = JokerData.Config or {}

JokerData.Config.TriviaESO = {
  label = "ESO Trivia",
  command = "trivia-eso",
  trivia = true,
  nsfw = false,
  whitelistSlashCommand = true
}

JokerData.TriviaESO = {
  { q = "What year was The Elder Scrolls Online originally released?", a = "2014" },
  { q = "Which Daedric Prince is associated with madness?", a = "Sheogorath" },
  { q = "What is the name of the main antagonist in the base game storyline?", a = "Molag Bal" },
  { q = "How many playable races are there in ESO?", a = "Ten (or 10)" },
  { q = "What is the name of the Prophet who guides you in the main quest?", a = "Varen Aquilarios" },
  { q = "Which alliance is represented by the color red?", a = "Ebonheart Pact" },
  { q = "Which alliance is represented by the color blue?", a = "Daggerfall Covenant" },
  { q = "Which alliance is represented by the color yellow/gold?", a = "Aldmeri Dominion" },
  { q = "What is the maximum level for Champion Points?", a = "3600" },
  { q = "What is the name of the assassin's guild in Tamriel?", a = "Dark Brotherhood" },
  { q = "What is the name of the thieves guild base in Abah's Landing?", a = "The Thieves Den" },
  { q = "Which Khajiit is known as the Silencer in the Dark Brotherhood?", a = "Razum-dar (or Raz)" },
  { q = "What type of creature is a Wamasu?", a = "A large reptilian creature (or lightning lizard)" },
  { q = "What is the name of the floating city in Summerset?", a = "Cloudrest" },
  { q = "Which Daedric Prince is the patron of vampires?", a = "Molag Bal" },
  { q = "What is the name of the crafting material used for the highest tier of gear?", a = "Rubedite (for weapons/armor)" },
  { q = "How many skill points does each Skyshards grant when collected in groups of three?", a = "One (1) skill point" },
  { q = "What is the name of the currency used in PvP?", a = "Alliance Points (or AP)" },
  { q = "What was the first DLC released for ESO?", a = "Craglorn" },
  { q = "What is the maximum number of players in a standard dungeon group?", a = "Four (4)" },
  { q = "What is the maximum number of players in a trial?", a = "Twelve (12)" },
  { q = "What is the name of the zone where the Psijic Order is located?", a = "Artaeum" },
  { q = "Which race is known for their proficiency in magic and their homeland of Summerset?", a = "High Elves (or Altmer)" },
  { q = "What is the name of the neutral city that serves as a hub for all three alliances?", a = "Vivec City (or various answers depending on interpretation)" },
  { q = "Which Daedric Prince is associated with the plane of Oblivion called The Shivering Isles?", a = "Sheogorath" },
  { q = "What is the name of the main PvP zone in ESO?", a = "Cyrodiil" },
  { q = "How many crafting skill lines are there in ESO?", a = "Seven (7): Alchemy, Blacksmithing, Clothing, Enchanting, Jewelcrafting, Provisioning, Woodworking" },
  { q = "What is the name of the vampire lord skill line?", a = "Vampire" },
  { q = "What is the name of the werewolf skill line?", a = "Werewolf" },
  { q = "Which alliance includes the Nords, Dark Elves, and Argonians?", a = "Ebonheart Pact" },
  { q = "Which DLC introduced the Warden class?", a = "Morrowind" },
  { q = "Which Chapter introduced the Necromancer class?", a = "Elsweyr" },
  { q = "What is the name of the main city in Summerset?", a = "Alinor" },
  { q = "What is the capital city of the Daggerfall Covenant?", a = "Wayrest" },
  { q = "What are the primary stats that affect weapon damage?", a = "Stamina and Weapon Damage" },
  { q = "What are the primary stats that affect spell damage?", a = "Magicka and Spell Damage" },
  { q = "What is the name of the Khajiit homeland featured in the Elsweyr chapter?", a = "Elsweyr" },
  { q = "What is the level cap in ESO before Champion Points?", a = "Level 50" },
  { q = "What is the name of the crafting station used to improve item quality?", a = "Varies by craft (Blacksmithing Station, Clothing Station, Woodworking Station)" },
  { q = "Which Daedric Prince's realm is called The Deadlands?", a = "Mehrunes Dagon" },
  { q = "What year does ESO take place in the Second Era?", a = "2E 582" },
  
  -- Additional Elder Scrolls Trivia (from various games)
  { q = "In Oblivion, what is the name of the Guild Master of the Thieves Guild?", a = "The Gray Fox" },
  { q = "Which Daedric Prince created Vampires?", a = "Molag Bal" },
  { q = "What was the name of the cult that started The Oblivion Crisis?", a = "The Mythic Dawn" },
  { q = "In Skyrim, what is the name of the first dragon you kill?", a = "Mirmulnir" },
  { q = "Who built Sky Haven Temple?", a = "Akaviri" },
  { q = "Who is the Daedric Prince of debauchery?", a = "Sanguine" },
  { q = "Who was Talos before he became a god?", a = "Tiber Septim" },
  { q = "Who is NOT part of the Tribunal?", a = "Dagoth Ur" },
  { q = "What does the Dunmer word 'N'wah' mean?", a = "Foreigner" },
  { q = "Who are the Maormer?", a = "Sea-elves (or Sea Elves)" },
  { q = "Who do the Dark Brotherhood worship?", a = "Sithis" },
  { q = "Which Skyrim city was founded by Ysgramor?", a = "Windhelm" },
  { q = "What race has a special connection to the Hist Trees?", a = "Argonians" },
  { q = "What weapon does Sheogorath task you to kill a netch with?", a = "Fork (or A Fork)" },
  { q = "Once a vampire, can you be cured?", a = "Yes" },
  { q = "In Skyrim, where does the Dark Brotherhood move after losing the Falkreath sanctuary?", a = "Dawnstar" },
  { q = "What is the native race of the province of High Rock?", a = "Bretons" },
  { q = "What is the name of the planet in the Elder Scrolls universe?", a = "Nirn" },
  { q = "What is the name of the volcano/mountain in Morrowind?", a = "Red Mountain" },
  { q = "What will eventually happen if you keep reading Elder Scrolls, even with training?", a = "You will go blind" },
  { q = "Jiub became a Saint after driving out which creatures from Vvardenfell?", a = "Cliff racers (or Cliff Racers)" },
  { q = "What is the main ingredient in Skooma?", a = "Moon Sugar" },
  { q = "Why did the Dwemer race vanish?", a = "They vanished after interacting with the Heart of Lorkhan" },
  { q = "Why didn't Yagrum Bagarn vanish with the Dwemer?", a = "He was in another realm when the event happened" },
  { q = "What happened when Mehrunes Dagon invaded Black Marsh during the Oblivion Crisis?", a = "The Argonians were called together by the Hist and stopped the invasion" },
  { q = "What is the name of the spiritual enlightenment obtained by Vivec?", a = "CHIM" },
  { q = "Who became the new Sheogorath at the end of the Third Era?", a = "The Hero of Kvatch" },
  { q = "What is the name of the lake surrounding the Imperial City?", a = "Lake Rumare" },
  { q = "In Skyrim, how many Standing Stones are there?", a = "13" },
  { q = "What is Mannimarco also known as?", a = "King of Worms" },
  { q = "What is the cover of the Oghma Infinium made of?", a = "The skins of 5 elves" },
  { q = "Before the Nords, what was the native race of Skyrim?", a = "Snow Elves" },
  { q = "As of 4E 201, what is the capital of Morrowind?", a = "Blacklight" },
  { q = "Are there Aedric artifacts in the Elder Scrolls?", a = "Yes" },
  { q = "Who guards the Whalebone Bridge to the Hall of Valor in Sovngarde?", a = "Tsun" },
  { q = "Which book was written by Crassius Curio?", a = "The Lusty Argonian Maid" },
  { q = "Before Malacath was turned into a Daedric Prince by Boethiah, what was he known as?", a = "Trinimac" },
  { q = "Which is NOT a race native to Akavir?", a = "Sload" },
  { q = "What does the door to the Dark Brotherhood depict?", a = "The black sacrament, the Night Mother, and her children" },
  { q = "When was the Mages Guild founded?", a = "Second Era" },
  
  -- Additional Lore & Deep Cuts
  { q = "Which structure of Direnni design is widely considered to be the oldest in all of Nirn?", a = "Adamantine Tower (or Direnni Tower)" },
  { q = "In which year did the Soulburst occur?", a = "2E 579" },
  { q = "What is the primary language spoken by the Khajiit?", a = "Ta'agra" },
  { q = "Which region in western Tamriel includes the Alik'r Desert?", a = "Hammerfell" },
  { q = "In Imperial culture, who is the God of Time?", a = "Akatosh" },
  { q = "Who is Uriel Septim's illegitimate son in Oblivion?", a = "Martin Septim" },
  { q = "What is Azura's Daedric artifact called?", a = "Azura's Star" },
  { q = "What is the name of the red gem in the Amulet of Kings?", a = "Chim-el Adabal" },
  { q = "What was Vivec's original name before becoming part of the Tribunal?", a = "Vehk" },
  { q = "What powers the Brass Tower (Numidium)?", a = "The Heart of Lorkhan" },
  { q = "Which Daedric Prince is considered the most powerful?", a = "Jyggalag" },
  { q = "Which Daedric Prince is known as the Prince of Plots?", a = "Boethiah" },
  { q = "Which Daedric Prince is associated with the realm of Apocrypha?", a = "Hermaeus Mora" },
  { q = "Which Daedric Prince's realm is called Quagmire?", a = "Vaermina" },
  { q = "Where did Ysgramor and the 500 Companions come from?", a = "Atmora" },
  { q = "Which of the following is NOT a province of Tamriel: Elsweyr, Hammerfell, or Yokuda?", a = "Yokuda" },
  { q = "What stone do you receive when you close an Oblivion Gate?", a = "Sigil Stone" },
  { q = "What are Sigil Stones used for?", a = "Enchanting weapons and armor" },
  { q = "What is the name of the celestial beings in ESO's Craglorn storyline?", a = "The Celestials" },
  { q = "Who founded the first Empire of Tamriel?", a = "Alessia (or Saint Alessia)" },
  { q = "How many types of Mer (elves) exist in Elder Scrolls lore?", a = "Ten (10)" },
  
  -- Skyrim Specific
  { q = "On what date was Skyrim released?", a = "November 11, 2011 (or 11/11/11)" },
  { q = "Where is Skyrim's College of Magic located?", a = "Winterhold" },
  { q = "How many Dragon Shouts can you learn in Skyrim (including all DLC)?", a = "27" },
  { q = "What is the first dragon that attacks you at the beginning of Skyrim?", a = "Alduin" },
  { q = "How many DLC expansions were released for Skyrim?", a = "Three (3): Dawnguard, Hearthfire, and Dragonborn" },
  { q = "Skyrim takes place how many years after Oblivion?", a = "200 years" },
  { q = "What is the opening line spoken to you in Skyrim?", a = "Hey, you. You're finally awake." },
  { q = "Who directed Skyrim?", a = "Todd Howard" },
  { q = "What Shout is required to finally defeat Alduin?", a = "Dragonrend" },
}
