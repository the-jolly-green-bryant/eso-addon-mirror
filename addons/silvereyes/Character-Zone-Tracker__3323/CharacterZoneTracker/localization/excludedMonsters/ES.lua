-- Monster difficulty data provided by https://en.uesp.net/wiki/Online:Creatures. Thank you!

CZT_EXCLUDED_MONSTER_NAMES = {

-- TODO: Localize the following for ES once Update 34 gets to PTS
-- TODO: Use [Black Book Browser](https://www.esoui.com/downloads/info2532-BlackBookBrowser.html) to open the PTS depot\eso.mnf file.
-- TODO: Then, extract /gamedata/lang/es.lang
-- TODO: Then, use [ESOExtractData](https://en.uesp.net/wiki/Online_Mod:EsoExtractData) to convert the file to es.lang.csv
-- TODO:   EsoExtractData -l es.lang -o es.lang.csv
-- TODO: Now, you have the es.lang.csv file to search for localizations inside.
-- TODO: In order to search, use grep.
-- TODO: Copy/paste the below into Notepad++
-- TODO: Then, do a Replace with this regex in Notepad++ to get grep commands
-- TODO:   Replace: .*-- *("[0-9]+","[0-9]+","[0-9]+")
-- TODO:   With:    grep -i '\1' es.lang.csv | cut -d, -f5
-- TODO: Finally, run the commands in WSL / Ubuntu from the directory your es.lang.csv is in.
-- TODO: Copy the results into a new Notepad++ window and Replace ubuntu.*\n with empty
-- TODO: Then replace \n"([^"^]+).* with \ngrep -io '"\1.*"' es.lang.csv | sort | uniq
-- TODO: Run the commands in WSL again to get a list of all variations of the monster names.
-- TODO: Observe any lines that got no results, and run them again with just .*" instead of ^.*"
-- TODO: Then, copy to notepad++ and replace ubuntu.*\n with empty again.
-- TODO: Sort and remove duplicates, then replace \n with ,\n
-- TODO: Finally, replace the text below and this TODO with the results from Notepad++
-- TODO: Afterwards, log in to PTS and switch to Spanish mode /script SetCVar("language.2","ru")
-- TODO: Then run /script CharacterZoneTracker.ExcludedMonsters:PrintEscapedArray()
-- TODO: Copy with pchat into Excel, sort and remove dups, then replace the strings in this file with the second column (tab delimited)
"argonian behemoth", --"81344020","0","830"
"avrusa duleri", -- "8290981","0","74205"
"bone colossus", --"8290981","0","12911"
"bull netch", --"8290981","0","21303"
"captain jena apinia", -- "8290981","0","68879"
"celestial bat", --"8290981","0","73466"
"celestial scorpion", --"8290981","0","73467"
"craghammer giant",--"8290981","0","17024"
"daedric titan",--"8290981","0","45743"
"daedroth",--"8290981","0","106454"
"draugr corpse",--"87370069","0","26983"
"draugr stormlord", --"8290981","0","54101"
"dremora kynreeve", --"191999749","0","2732"
"drovos nelvayn", -- "8290981","0","74728"
"drublog mammoth", --"8290981","0","31254"
"dwarven centurion", --"168675493","0","4091"
"dwarven sphere", --"8290981","0","100009"
"dwarven sphere master", --"168675493","0","4113"
"emperor tarish-zi", -- "8290981","0","72305"
"fetcherfly hive golem", --"8290981","0","74370"
"frost atronach", --"8290981","0","23570"
"frost troll", --"8290981","0","96938"
"frostbite spider", --"8290981","0","24495"
"gargoyle", --"8290981","0","23880"
"giant", --"8290981","0","23865"
"giant scorpion", --"8290981","0","55181"
"grievous twilight", --"8290981","0","61165"
"haj mota", --"8290981","0","70388"
"harvester", --"8290981","0","71995"
"harvester", --"8290981","0","98928"
"haunted centurion", --"8290981","0","75399"
"hive golem", --"8290981","0","75754"
"dévoreur^m", --"8290981","0","81174"
"Dévoreur^md", --"8290981","0","56590"
"atronach de fer^m", --"8290981","0","74742"
"iron head", --"8290981","0","72270"
"justiciar avanaire", -- "8290981","0","81627"
"lieutenant lepida", -- "8290981","0","88130"
"rosathild", -- "8290981","0","72293"
"mammoth", --"8290981","0","23507"
"mantikora", --"8290981","0","73119"
"miregaunt", --"8290981","0","101455"
"Minotaure", --"8290981","0","70273"
"Minotaure", --"8290981","0","70966"
"Minotaure", --"8290981","0","88271"
"Minotaure", --"8290981","0","93186"
"Minotaure", --"8290981","0","99243"
"minotaur shaman", --"8290981","0","100230"
"nereid", --"8290981","0","80854"
"nereid empress", --"8290981","0","48189"
"river troll", --"8290981","0","70759"
"sangrebête d'ombres^mf", --"8290981","0","71666"
"sangrebête d'ombres^f", --"8290981","0","69801"
"arachnide daedrique^f", --"8290981","0","24836"
"arachnide daedrique^m", --"8290981","0","73275"
"spirit giant", --"8290981","0","73430"
"storm atronach", --"198758357","0","147943"
"the swarming tide", -- "8290981","0","72369"
"timber mammoth", --"8290981","0","50389"
"titan", --"198758357","0","65742"
"troll^m", --"8290981","0","74762"
"Troll^n", --"8290981","0","93188"
"tundra mammoth", --"8290981","0","17025"
"veiled colossus", --"8290981","0","39563"
"vessel of worms", -- "8290981","0","81045"
"wamasu", --"8290981","0","88102"
"gardien^m", --"198758357","0","160530"
"Gardien^md", --"8290981","0","21853"
"Gardien^m", --"198758357","0","155588"
"white fall giant", --"8290981","0","49364"
"wispmother", --"8290981","0","80779"
"Spectre-des-Corbeaux^M", --"8290981","0","79034"
"Spectre-des-Corbeaux^N", --"8290981","0","104240"
"zalar-do", -- "8290981","0","68856"
"zylara", -- "8290981","0","74603"

}