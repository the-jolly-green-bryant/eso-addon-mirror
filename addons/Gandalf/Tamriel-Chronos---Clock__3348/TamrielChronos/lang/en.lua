-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local strings = {
	-- keybindings
	SI_BINDING_NAME_TAMRIELCHRONOS_CLOCK = "Show/Hide Clock",			
	SI_BINDING_NAME_TAMRIELCHRONOS_ZOOM  = "Toggle Clock Zoom",		
	SI_BINDING_NAME_TAMRIELCHRONOS_CONV  = "Show/Hide Conversion",		
	SI_BINDING_NAME_TAMRIELCHRONOS_CAL   = "Show/Hide Calendar",		
	
	-- Chronos.lua		
	SI_TACHRONOS_PLAYER_ALERT		 = "You are playing for more than <<1>> minutes, please take a health break!",
	SI_TACHRONOS_PLAYER_ALERT_FINAL  = "You are playing for more than <<1>> minutes, please take a health break! (Final Message)",
	
	-- cm.lua		
	SI_TACHRONOS_TITLE_CONF          = "Configuration",
	
	SI_TACHRONOS_MODE                = "Clock Type",
	SI_TACHRONOS_MODE_tt             = "",

	SI_TACHRONOS_MODE_h24            = "24h Dual", 
	SI_TACHRONOS_MODE_monD           = "Moons Digital",
	SI_TACHRONOS_MODE_mon            = "Moons",    
	SI_TACHRONOS_MODE_noMoD          = "Digital Clock",    
	SI_TACHRONOS_MODE_dualA          = "12h Dual analog",   
	SI_TACHRONOS_MODE_dualD          = "12h Dual digital",     
	SI_TACHRONOS_MODE_e24            = "24h Dual Earth Time",     
	
	SI_TACHRONOS_DESC_h24            = "\nTamriel clock with digital 2nd time, day/night display, moon phases and a clock face that adapts to daylight", 
	SI_TACHRONOS_DESC_monD           = "\nDigital clock with moon phases",
	SI_TACHRONOS_DESC_mon            = "\nMoon phases only",    
	SI_TACHRONOS_DESC_noMoD          = "",    
	SI_TACHRONOS_DESC_dualA          = "\nTamriel clock with analog 2nd time and moon phase display",   
	SI_TACHRONOS_DESC_dualD          = "\nTamriel clock with digital 2nd time and moon phase display",   
	SI_TACHRONOS_DESC_e24            = "\nEarthtime clock with digital 2nd time, Tamriel nights overlay, moon phases and a clock face that adapts to daylight", 
	
	SI_TACHRONOS_SECS                = "Show Seconds",
	SI_TACHRONOS_SECS_tt             = "",

	SI_TACHRONOS_REAL                = "Digital Clock in Earth Time",
	SI_TACHRONOS_REAL_tt             = "or in TST (Tamriel Standard Time)",

	SI_TACHRONOS_SCALE               = "Scale Factor",
	SI_TACHRONOS_SCALE_tt            = "",

	SI_TACHRONOS_TIME_FONT           = "Digital Clock Font",
	SI_TACHRONOS_TIME_FONT_tt        = "",
	
	SI_TACHRONOS_TIME_COLOR          = "Digital Clock Color",
	SI_TACHRONOS_TIME_COLOR_tt       = "",
	
	SI_TACHRONOS_SHOW_HOLIDAYS       = "Show today's holidays in chat",
	SI_TACHRONOS_SHOW_HOLIDAYS_tt    = "On login, write links of today's holidays into chat",
	
	SI_TACHRONOS_HEALTH              = "Game Breaks",
	SI_TACHRONOS_HEALTH_tt           = "Reminder to take a health break after you played these many minutes",
	
	SI_TACHRONOS_HIDE                = "Hide clock on startup",
	SI_TACHRONOS_HIDE_tt             = "",
	
	SI_TACHRONOS_HELP                = "Help",
	SI_TACHRONOS_HELP_F              = "",
	SI_TACHRONOS_HELP_F_DESC         = "Tamriel Chronos provides Tamriel clocks, astronomical data, holidays,\n"
	                               .."a calendar and a date/time conversion tool.\n\n"
								   .."The clocks can be moved freely and will remember their position.\n"
								   .."The astronomical data is provided in the tooltip of the clock.\n"
								   .."You may define hotkeys to toggle the visibility and to zoom the clock.\n"
								   .."Right mouse click the clock will post Chronos data into chat.\n\n"
								   .."Double mouse click the clock will bring up the time conversion tool\n"
								   .."or you can define a hotkey to toggle the visibility of it\n\n"
								   .."The Tamriel Holiday Calendar can be shown by using the info button\n"
								   .."in the conversion tool or by a defined hotkey\n\n"
								   .."Tamriel time conversion methods are based on:\n   - https://esoclock.uesp.net/\n"
								   .."Tamriel lore calendar and holidays are based on:\n"
								   .."   - https://www.imperial-library.info/content/calendar-tamriel\n"
								   .."   - https://en.uesp.net/wiki/Lore:Holidays",
								   
	-- base.lua/tooltip
	SI_TACHRONOS_M_WAINING		   = "(waining)",
	SI_TACHRONOS_M_WAXING		       = "(waxing)",
	SI_TACHRONOS_T_TITLE             = "Time",
	SI_TACHRONOS_T_REAL              = "\n   Earth:       %s  %02d.%02d.%04d",
	SI_TACHRONOS_T_TAMRIEL           = "\n   Tamriel:     %s  %02d.%02d.2E%03d\n",
	SI_TACHRONOS_M_TITLE             = "\nMoons",
	SI_TACHRONOS_M_LEVEL             = "\n   Level:       %.0f%%",
	SI_TACHRONOS_M_PHASE             = "\n   Phase:       %s %s\n",
	SI_TACHRONOS_E_TITLE             = "\nNext Events",
	SI_TACHRONOS_E_SUNSET            = "\n   Sunset:      ",
	SI_TACHRONOS_E_SUNRISE           = "\n   Sunrise:     ",
	SI_TACHRONOS_E_FULLMOON          = "\n   Full Moons:  ",
	SI_TACHRONOS_E_NEWMOON           = "\n   New Moons:   ",
	SI_TACHRONOS_T_PLAYED            = "\nTime played:    %s\n",
	
	-- moon.lua
	SI_TACHRONOS_MOON_00X            = "???",
	SI_TACHRONOS_MOON_000            = "New",
	SI_TACHRONOS_MOON_025            = "Waxing Crescent",
	SI_TACHRONOS_MOON_050            = "First Quarter",
	SI_TACHRONOS_MOON_075            = "Waxing Gibbous",
	SI_TACHRONOS_MOON_100            = "Full",
	SI_TACHRONOS_MOON_125            = "Waning Gibbous",
	SI_TACHRONOS_MOON_150            = "Third Quarter",
	SI_TACHRONOS_MOON_175            = "Waning Crescent",
	
	-- conv.lua
	SI_TACHRONOS_CONV_TITLE          = "Tamriel Chronos - Conversion",
	SI_TACHRONOS_CONV_EST            = "Earth Time",
	SI_TACHRONOS_CONV_TST            = "Tamriel Time",
	SI_TACHRONOS_CONV_NUMBER         = "Error: Values must be numeric",
	SI_TACHRONOS_CONV_HH             = "Error: Hours must be in the range 0..23",
	SI_TACHRONOS_CONV_MM             = "Error: Minutes must be in the range 0..59",
	SI_TACHRONOS_CONV_SS             = "Error: Seconds must be in the range 0..59",
	SI_TACHRONOS_CONV_YY             = "Error: Years must be in the range 2014..2037",
	SI_TACHRONOS_CONV_YY_T           = "Error: Years must be in the range 2E 582..2E 679",
	SI_TACHRONOS_CONV_MO             = "Error: Months must be in the range 1..12",
	SI_TACHRONOS_CONV_DD             = "Error: Day must be in the range 1..31",
	SI_TACHRONOS_CONV_MOON           = "Moons:  %.0f%% - %s %s",
	
	
	SI_TACHRONOS_New_Life                   = "New Life Festival",
	SI_TACHRONOS_New_Life_date              = "1st Morning Star",
	SI_TACHRONOS_New_Life_text              = "The New Life Festival is a Tamriel-wide event that celebrates the birth of a new year, and celebrates the death of the old year. In contrast to the Old Life Festival, New Life takes place at the beginning of Morning Star. It was originally the celebration of the sun god, Magnus, but over time it changed into a celebration of the gift of New Life, heralded by the sun. The New Life Festival also marks the start of the Winter Solstice, when Magnus the Sun begins his return, and the days start to grow longer. Almost all major races in Tamriel celebrate the New Life Festival in their own unique cultural way, and the celebrations themselves have been known to change over time. Many of the celebrations are symbolic of a historical event or have some form of deeper meaning. Celebrations include races, feasts, games and dancing. Clavicus Vile's Summoning Day coincides with the New Life Festival, the 1st of Morning Star.",

	SI_TACHRONOS_Scour_Day                  = "Scour Day",
	SI_TACHRONOS_Scour_Day_date             = "2nd Morning Star",
	SI_TACHRONOS_Scour_Day_text             = "Scour Day is a celebration held in most High Rock villages on the day after New Life. It was once the day one cleans up after New Life, but has changed into a party of its own.",

	SI_TACHRONOS_Ovanka	                    = "Ovank'a",
	SI_TACHRONOS_Ovanka_date                = "12th Morning Star",
	SI_TACHRONOS_Ovanka_text                = "Ovank'a is the day the people of the Alik'r Desert offer prayers to Stendarr in the hopes of a mild and merciful year. It is considered very holy.",

	SI_TACHRONOS_Meridias_Summoning 	    = "Meridia's Summoning Day",
	SI_TACHRONOS_Meridias_Summoning_date    = "13th Morning Star",
	SI_TACHRONOS_Meridias_Summoning_text    = "In TES2, this is the day when Meridia may be summoned.",

	SI_TACHRONOS_South_Winds_Prayer         = "South Wind's Prayer",
	SI_TACHRONOS_South_Winds_Prayer_date    = "15th Morning Star",
	SI_TACHRONOS_South_Winds_Prayer_text    = "The 15th of Morning Star is a holiday taken very seriously in Tamriel, where they call it South Wind's Prayer, a plea by all the religions of Tamriel for a good planting season. Citizens with every affliction known in Tamriel flock to services in the every temples, as the clergy is known to perform free healings on this day. Only a few will be judged worthy of this service, but few can afford the temples usual price.",

	SI_TACHRONOS_The_Day_of_Lights          = "The Day of Lights",
	SI_TACHRONOS_The_Day_of_Lights_date     = "16th Morning Star",
	SI_TACHRONOS_The_Day_of_Lights_text     = "The Day of Lights is celebrated as a holy day by most villages in Hammerfell on the Iliac Bay. It is a prayer for a good farming and fishing year, and is taken very seriously.",

	SI_TACHRONOS_Waking_Day                 = "Waking Day - 18th Morning Star",
	SI_TACHRONOS_Waking_Day_date            = "18th Morning Star",
	SI_TACHRONOS_Waking_Day_text            = "The people in Yeorth Burrowland invented Waking Day in prehistoric times to wake the spirits of nature after a long, cold winter. It has evolved into a sort of orgiastic celebration of the end of winter.",

	SI_TACHRONOS_Mad_Pelagius               = "Mad Pelagius",
	SI_TACHRONOS_Mad_Pelagius_date          = "2nd Sun's Dawn",
	SI_TACHRONOS_Mad_Pelagius_text          = "Mad Pelagius is a silly little tradition in High Rock in a mock memorial to Pelagius Septim II, one of the maddest emperors in recent history. He died about 350 years ago, so the Septims since have taken it with good humor. In TES2, this is also the summoning day of Sheogorath.",

	SI_TACHRONOS_Othroktide                 = "Othroktide",
	SI_TACHRONOS_Othroktide_date            = "5th Sun's Dawn",
	SI_TACHRONOS_Othroktide_text            = "The people of Dwynnen have a huge party to celebrate Othroktide, the day when Baron Othrok took Dwynnen from the undead forces who claimed it in the Battle of Wightmoor.",

	SI_TACHRONOS_Day_of_Release             = "Day of Release",
	SI_TACHRONOS_Day_of_Release_date        = "8th Sun's Dawn",
	SI_TACHRONOS_Day_of_Release_text        = "The people of Glenumbra Moors may be the only people to remember or care about the battle between Aiden Direnni and the Alessian Army in the first era. They celebrate it vigorously on the Day of Release.",

	SI_TACHRONOS_Hearts_Day                 = "Heart's Day",
	SI_TACHRONOS_Hearts_Day_date            = "16th Sun's Dawn",
	SI_TACHRONOS_Hearts_Day_text            = "Today is the 16th of Sun's Dawn, a holiday celebrated all over Tamriel as Heart's Day. It seems that in every house, the Legend of the Lovers is being sung for the younger generation. In honor of these Lovers, Polydor and Eloisa, the inns of all Tamriel offer a free room for visitors. If such kindness had been given the Lovers, it is said, it would always be springtime in the world. In TES2, Heart's Day corresponds to the summoning day of Sanguine.",

	SI_TACHRONOS_Perseverance_Day           = "Perseverance Day",
	SI_TACHRONOS_Perseverance_Day_date      = "27th Sun's Dawn",
	SI_TACHRONOS_Perseverance_Day_text      = "Perseverance Day is quite a party in Ykalon. It was originally held as a solemn memorial to those killed in battle, resisting the Camoran Usurper, but has since become a boisterous festival.",

	SI_TACHRONOS_Aduros_Nau                 = "Aduros Nau",
	SI_TACHRONOS_Aduros_Nau_date            = "28th Sun's Dawn",
	SI_TACHRONOS_Aduros_Nau_text            = "The villages in the Bantha celebrate the baser urges that come with Springtide on Aduros Nau. The traditions vary from village to village, but none of them are for the overly virtuous.",

	SI_TACHRONOS_Hermaeus_Moras     	    = "Hermaeus Mora's Summoning Day",
	SI_TACHRONOS_Hermaeus_Moras_date        = "5th First Seed",
	SI_TACHRONOS_Hermaeus_Moras_text        = "In TES2, the Daedra prince Hermaeus Mora may be summoned on this day.",

	SI_TACHRONOS_First_Planting             = "First Planting",
	SI_TACHRONOS_First_Planting_date        = "7th First Seed",
	SI_TACHRONOS_First_Planting_text        = "On the 7th of First Seed every year, the people of Tamriel celebrate First Planting, symbolically sowing the seeds for the autumn harvest. It is a festival of fresh beginnings, both for the crops and for the men and women of the celebrated city. Neighbors are reconciled in their disputes, resolutions are formed, bad habits dropped, the diseased cured. The clerics at the temples run a free clinic all day long to cure people of poisoning, different diseases, paralyzation, and the other banes found in the world of Tamriel.",

	SI_TACHRONOS_Day_of_Waiting             = "The Day of Waiting",
	SI_TACHRONOS_Day_of_Waiting_date        = "9th First Seed",
	SI_TACHRONOS_Day_of_Waiting_text        = "The Day of Waiting is a very old holy day among certain settlements in the Dragontail Mountains. Every year at that time, a dragon is supposed to come out of the desert and devour the wicked, so everyone locks himself up inside.",

	SI_TACHRONOS_Hogithum                   = "Hogithum",
	SI_TACHRONOS_Hogithum_date              = "21st First Seed",
	SI_TACHRONOS_Hogithum_text              = "Hogithum, the day that all dark elven priests summon Daedra Prince Azura for her guidance and support.",

	SI_TACHRONOS_New_Jesters_Festival       = "Jester's Festival",
	SI_TACHRONOS_New_Jesters_Festival_date  = "21 First Seed to 19 Rain's Hand",
	SI_TACHRONOS_New_Jesters_Festival_text  = "This second era festival was introduced in The Elder Scrolls Online. The official website describes this festival thusly: Once a year, troupes of jesters and fools gather and encourage the people of Tamriel to toss aside their notions of status, honor, and class in a celebration of absurdity. Performers roam the streets mocking the rich and famous, towns celebrate with a variety of traditional festive pranks, and guests are encouraged to participate in silly games to win joke prizes.",
	
	SI_TACHRONOS_Festival_of_Blades         = "Festival of Blades",
	SI_TACHRONOS_Festival_of_Blades_date    = "25th First Seed",
	SI_TACHRONOS_Festival_of_Blades_text    = "During the Festival of Blades, the people of the Alik'r Desert celebrate the victor of the first Redguard over a race of giant goblins. The story is considered a myth by most scholars, but the holiday is still very popular in the desert.",
	
	SI_TACHRONOS_Flower_Day                 = "Flower Day",
	SI_TACHRONOS_Flower_Day_date            = "25th First Seed",
	SI_TACHRONOS_Flower_Day_text            = "Flower Day is another of the frivolous celebrations of High Rock. Children pick the new flowers of spring while older Bretons, cooped up all winter, come out to welcome the season with dancing and singing.",
	
	SI_TACHRONOS_Gardtide                   = "Gardtide",
	SI_TACHRONOS_Gardtide_date              = "1st Rain's Hand",
	SI_TACHRONOS_Gardtide_text              = "On Gardtide, the people of Tamarilyn Point hold a festival to honor Druagaa, the old goddess of flowers. Worship of the goddess is all but dead, but the celebration is always a great success.",
	
	SI_TACHRONOS_Peryites_Summoning         = "Peryite's Summoning Day",
	SI_TACHRONOS_Peryites_Summoning_date    = "9th Rain's Hand",
	SI_TACHRONOS_Peryites_Summoning_text    = "In TES2, this is the day when Peryite may be summoned.",
	
	SI_TACHRONOS_Day_of_the_Dead            = "The Day of the Dead",
	SI_TACHRONOS_Day_of_the_Dead_date       = "13th Rain's Hand",
	SI_TACHRONOS_Day_of_the_Dead_text       = "The Day of the Dead is one of the more peculiar holidays of Daggerfall. The superstitious say that the dead rise on this holiday to wreak vengeance on the living. It is a fact that King Lysandus's spectre began its haunting on the Day of the Dead, 3E 404.",
	
	SI_TACHRONOS_The_Day_of_Shame           = "The Day of Shame",
	SI_TACHRONOS_The_Day_of_Shame_date      = "20th Rain's Hand",
	SI_TACHRONOS_The_Day_of_Shame_text      = "All along the seaside of Hammerfell, no one leaves their houses on the Day of Shame. It is said that the Crimson Ship, a vessel filled with victims of the Knahaten Plague who were refused refuge hundreds of years ago, will return on this day.",
	
	SI_TACHRONOS_Jesters_Day                = "Jester's Day",
	SI_TACHRONOS_Jesters_Day_date           = "28th Rain's Hand",
	SI_TACHRONOS_Jesters_Day_text           = "Be warned that today is Jester's Day in the all cities of Tamriel, and pranks are being set up from one end of town to the other. It is as if a spell has been cast over the community, for even the most taciturn and dignified councilman might attempt to play a joke. The Thieves Guild finds particular attention as everyone looks for pickpockets in particular.",
	
	SI_TACHRONOS_Second_Planting	        = "Second Planting",
	SI_TACHRONOS_Second_Planting_date       = "7th Second Seed",
	SI_TACHRONOS_Second_Planting_text       = "The celebration of Second Planting is in full glory this day. It is a holiday with traditions similar to First Planting, improvements on the first seeding symbolically to suggest improvements on the soul. The free clinics of the temples are open for the second and last time this year, offering cures for those suffering from any kind of disease or affliction. Because peace and not conflict is stressed at this time, battle injuries are healed only at full price.",
	
	SI_TACHRONOS_Marukhs_Day                = "Marukh's Day",
	SI_TACHRONOS_Marukhs_Day_date           = "9th Second Seed",
	SI_TACHRONOS_Marukhs_Day_text           = "Marukh's Day is only observed by certain communities in Skeffington Wood. By comparing themselves to the virtuous prophet Marukh, the people of Skeffington Wood pray for the strength to resist temptation. In TES2, this is also the summoning day of Namira.",
	
	SI_TACHRONOS_The_Fire_Festival          = "The Fire Festival",
	SI_TACHRONOS_The_Fire_Festival_date     = "20th Second Seed",
	SI_TACHRONOS_The_Fire_Festival_text     = "The Fire Festival in Northmoor is one of the most attended celebrations in High Rock. It began as a pompous display of magic and military strength in ancient days and has become quite a festival.",

	SI_TACHRONOS_Fishing_Day                = "Fishing Day",
	SI_TACHRONOS_Fishing_Day_date           = "30th Second Seed",
    SI_TACHRONOS_Fishing_Day_text           = "Fishing Day is a big celebration for the Bretons who live off the bounty of the Iliac Bay. They are not a usually flamboyant people, but on Fishing Day, they make so much noise, fish have been scared away for weeks.",
	
	SI_TACHRONOS_Drigh_RZimb                = "Drigh R'Zimb",
	SI_TACHRONOS_Drigh_RZimb_date           = "1st Mid Year",
	SI_TACHRONOS_Drigh_RZimb_text           = "The festival of Drigh R'Zimb, held in the hottest time of year in Abibon-Gora, is a jubilation held for the sun Daibethe itself. Scholars do not know how long Drigh R'Zimb has been held, but it is possible the Redguards brought the festival with them when they came in the first era.",
	
	SI_TACHRONOS_Hircines_Summoning         = "Hircine's Summoning Day",
	SI_TACHRONOS_Hircines_Summoning_date    = "5th Mid Year",
	SI_TACHRONOS_Hircines_Summoning_text    = "In TES2, Hircine may be summoned on this day",
	
	SI_TACHRONOS_Mid_Year_Celebration       = "Mid Year Celebration",
	SI_TACHRONOS_Mid_Year_Celebration_date  = "16th Mid Year",
	SI_TACHRONOS_Mid_Year_Celebration_text  = "Today is the 16th of Mid Year, the traditional day for the Mid Year Celebration. Perhaps to alleviate the annual news of the Emperor's latest tax increase, the temples offer blessings for only half the donation they usually suggest. Many so blessed feel confident enough to enter the dungeons when they are not fully prepared, so this joyous festival has often been known to turn suddenly into a day of defeat and tragedy.",
	
	SI_TACHRONOS_Dancing_Day                = "Dancing Day",
	SI_TACHRONOS_Dancing_Day_date           = "23rd Mid Year",
	SI_TACHRONOS_Dancing_Day_text           = "Dancing Day is a time-honored holiday in Daggerfall. Who started it is questionable, but the Red Prince Atryck popularized it in the second era. It is an occasion of great pomp and merriment for all the people of Daggerfall, from the nobles down.",
	
	SI_TACHRONOS_Tibedetha                  = "Tibedetha",
	SI_TACHRONOS_Tibedetha_date             = "24th Mid Year",
	SI_TACHRONOS_Tibedetha_text             = "Tibedetha is middle Tamrielic for 'Tibers Day'. It is not surprising that the lorddom of Alcaire celebrates its most famous native with a great party. Historically, Tiber Septim never returned once to his beloved birthplace.",
	
	SI_TACHRONOS_Merchants_Festival         = "Merchants's Festival",
	SI_TACHRONOS_Merchants_Festival_date    = "10th Sun's Height",
	SI_TACHRONOS_Merchants_Festival_text    = "The bargain shoppers of the known world are out in force today and it is little wonder, for the 10th of Sun's Height is a holiday called the Merchants's Festival. Every marketplace and equipment store has dropped their prices to at least half. The only shop not being patronized today is the Mages Guild, where prices are as exorbitant as usual. Most citizens in need of a magical item are waiting two months for the celebration of Tales and Tallows when prices will be more reasonable. In TES2, this is also the summoning day of Vaernima.",
	
	SI_TACHRONOS_Divad_Etept                = "Divad Etep't",
	SI_TACHRONOS_Divad_Etept_date           = "12th Sun's Height",
	SI_TACHRONOS_Divad_Etept_text           = "During Divad Etep't, the people of Antiphyllos mourn the death of the one of the greatest of the early Redguard heroes, Divad, son of Frandar of the Hel Ansei. His deeds are questioned by historians, but his tomb in Antiphyllos is almost certainly genuine.",
	
	SI_TACHRONOS_Suns_Rest                  = "Sun's Rest",
	SI_TACHRONOS_Suns_Rest_date             = "20th Sun's Height",
	SI_TACHRONOS_Suns_Rest_text             = "You will have to wait until tomorrow if you are planning on making any equipment purchases, for all stores are closed in observance of Sun's Rest. Of course, the temples, taverns, and Mages Guild in all cities are still open their regular hours, but most citizens chose to devote this day to relaxation, not commerce or prayer. This is not a convenient arrangement for all, but the Merchants's Guild heavily fines any shop that stays open, so everyone complies.",

	SI_TACHRONOS_Fiery_Night                = "Fiery Night",
    SI_TACHRONOS_Fiery_Night_date           = "29th Sun's Height",
    SI_TACHRONOS_Fiery_Night_text           = "Few besides the natives of the Alik'r Desert would venture out on the hottest day of the year, Fiery Night. It's a lively celebration with a meaning lost in antiquity.",

	SI_TACHRONOS_Maiden_Katrica             = "The day of Maiden Katrica",
	SI_TACHRONOS_Maiden_Katrica_date        = "2nd Last Seed",
	SI_TACHRONOS_Maiden_Katrica_text        = "On the day of Maiden Katrica, the people of Ayasofya show their appreciation for the warrior that saved their county with the biggest party of the year.",

	SI_TACHRONOS_Koomu_Alezeri              = "Koomu Alezer'i",
	SI_TACHRONOS_Koomu_Alezeri_date         = "11th Last Seed",
	SI_TACHRONOS_Koomu_Alezeri_text         = "Koomu Alezer'i means simply 'We Acknowledge' in old Redguard, and it has been a tradition in Sentinel for thousands of years. No matter the harvest, the people of Sentinel solemnly thank the gods for their bounty, and pray to be worthy of the graces of the gods.",

	SI_TACHRONOS_Feast_of_the_Tiger         = "The Feast of the Tiger",
	SI_TACHRONOS_Feast_of_the_Tiger_date    = "14th Last Seed",
	SI_TACHRONOS_Feast_of_the_Tiger_text    = "The Feast of the Tiger in the Bantha rainforest is like other holidays in praise of a bountiful harvest. It is not, however, a solemn occasion for introspection and thanksgiving, but a great celebration and festival from village to village.",

	SI_TACHRONOS_Appreciation_Day           = "Appreciation Day",
	SI_TACHRONOS_Appreciation_Day_date      = "21st Last Seed",
	SI_TACHRONOS_Appreciation_Day_text      = "Appreciation Day in Anticlere is an ancient holiday of thanksgiving for a bountiful harvest for the people of Anticlere. It is considered a holy and contemplative day, devoted to Mara, the goddess-protector of Anticlere.",

	SI_TACHRONOS_Harvests_End               = "Harvest's End",
	SI_TACHRONOS_Harvests_End_date          = "27th Last Seed",
	SI_TACHRONOS_Harvests_End_text          = "Perhaps no other festival fires the spirit of Tamriel as much as the one held today, Harvest's End. The work of the year is over, the seeding, sowing, and reaping. Now is the time to celebrate and enjoy the fruits of the harvest, and even visitors to the celebrated region are invited to join the farmers. The taverns offer free drinks all day long, an extravagance before the economy of the coming winter months. Underfed farm hands gorging themselves and then getting sick in the town square are the most common sights of the celebration of Harvest's End.",

	SI_TACHRONOS_Tales_and_Tallows          = "Tales and Tallows",
	SI_TACHRONOS_Tales_and_Tallows_date     = "3rd Hearth Fire",
	SI_TACHRONOS_Tales_and_Tallows_text     = "No other holiday divides the people of Tamriel like the 3rd of Hearth Fire. A few of the oldest, more superstitious men and women do not speak all day long for fear that the evil spirits of the dead will enter their bodies. Most citizens enjoy the holiday, calling it Tales and Tallows, but even the most lighthearted avoid the dark streets of Tamriel cities, for everyone knows the dead do walk tonight. Only the Mages Guild completely thrives on this day. In celebration of the oldest magical science, necromancy, all magical items are half price today.",

	SI_TACHRONOS_Khurat                     = "Khurat",
	SI_TACHRONOS_Khurat_date                = "6th Hearth Fire",
	SI_TACHRONOS_Khurat_text                = "Every town and fellowship in the Wrothgarian Mountains celebrates Khurat, the day when the finest young scholars are accepted into the various priesthoods. Even those people without children of age go to pray for the wisdom and benevolence of the clergy.",

	SI_TACHRONOS_Nocturnals_Summoning       = "Nocturnal's Summoning Day",
	SI_TACHRONOS_Nocturnals_Summoning_date  = "8th Hearth Fire",
	SI_TACHRONOS_Nocturnals_Summoning_text  = "In TES2, Noturnal may be summoned on this date.",

	SI_TACHRONOS_Riglametha                 = "Riglametha",
	SI_TACHRONOS_Riglametha_date            = "12th Hearth Fire",
	SI_TACHRONOS_Riglametha_text            = "Riglametha is celebrated on the twelfth of Hearth Fire every year in Lainlyn as a celebration of Lainlyns many blessings. Pageants are held on such themes as the Ghraewaj, when the daedra worshippers in Lainlyn were changed to harpies for their blasphemy.",

	SI_TACHRONOS_Childrens_Day              = "Children's Day",
	SI_TACHRONOS_Childrens_Day_date         = "19th Hearth Fire",
	SI_TACHRONOS_Childrens_Day_text         = "Children's Day in Betony is a festive occasion with a grim history. All know though few choose to recall that Children's Day began as a memorial to the dozens of children in Betony who were stolen from their homes by vampires one night never to be seen again. This happened over a hundred years ago, and the holiday has since become a celebration of youth.",

	SI_TACHRONOS_Whitestrakes_Mayhem        = "Whitestrake's Mayhem",
    SI_TACHRONOS_Whitestrakes_Mayhem_date   = "29th Hearthfire to 18th Sun's Dusk",
	SI_TACHRONOS_Whitestrakes_Mayhem_text   = "First introduced in Elder Scrolls Online. The official website describes it thusly: This event is celebrated by Imperial priests of St. Alessia every summer in commemoration of the Whitestrake's slaughter of Elves at the Bridge of Heldon.",

	SI_TACHRONOS_Dirij_Tereur               = "Dirij Tereur",
	SI_TACHRONOS_Dirij_Tereur_date          = "5th Frost Fall",
	SI_TACHRONOS_Dirij_Tereur_text          = "The fifth of Frost Fall marks Dirij Tereur for the people of the Alik'r Desert. It is a sacred day honoring Frandar Hunding, the traditional spiritual leader of the Redguards who led them to Hammerfell in the first era. Stories are read from Hunding's Book of Circles, and the temples in the region are filled to capacity.",

	SI_TACHRONOS_Gauntlet                   = "Gauntlet",
	SI_TACHRONOS_Gauntlet_date              = "9th Frost Fall",
	SI_TACHRONOS_Gauntlet_text              = "In TES2, this is the day when mortals may summon Boethiah.",

	SI_TACHRONOS_Witches_Festival           = "Witches's Festival",
	SI_TACHRONOS_Witches_Festival_date      = "13th Frost Fall",
	SI_TACHRONOS_Witches_Festival_text      = "Today is the 13th of Frost Fall, known throughout Tamriel as the Witches's Festival when the forces of sorcery and religion clash. The Mages Guild gets most of the business since weapons and items are evaluated for their mystic potential free of charge and magic spells are one half their usual price. Demonologists, conjurers, lamias, warlocks, and thaumaturgists meet in the wilderness outside city, and the creatures created or summoned there may plague Tamriel for eons. Most wise men choose not to wander this night. In TES2, this is also the summoning day of Mephala.",

	SI_TACHRONOS_Broken_Diamonds            = "Broken Diamonds",
	SI_TACHRONOS_Broken_Diamonds_date       = "23rd Frost Fall",
	SI_TACHRONOS_Broken_Diamonds_text       = "On the 23rd of Frost Fall in the 121st year of the third era, the empress Kintyra Septim II met her death in the imperial dungeons in Glenpoint on the orders of her cousin and usurper Cephorus I. Her death is remembered in Glenpoint as the day called Broken Diamonds. It is a day of silent prayer for the wisdom and benevolence of the imperial family of Tamriel.\nNote: It is Uriel III who killed Kintyra, not Cephorus. This is a scribe's error in Daggerfall. Thanks to Leshek for spotting this.",

	SI_TACHRONOS_Emperors_Birthday          = "The Emperor's Birthday",
	SI_TACHRONOS_Emperors_Birthday_date     = "30th Frost Fall",
	SI_TACHRONOS_Emperors_Birthday_text     = "On the 30th of Frostfall, the Emperor's Birthday was the most popular holiday of the year. Great traveling carnivals entertained the masses, while the aristocracy of Tamriel enjoyed the annual Goblin Chase on horseback.",

	SI_TACHRONOS_Serpents_Dance             = "The Serpents Dance",
	SI_TACHRONOS_Serpents_Dance_date        = "3rd Sun's Dusk",
	SI_TACHRONOS_Serpents_Dance_text        = "The Serpents Dance in Satakalaam may or may not have begun as a serious religious holiday dedicated to a snake god, but this day is a reason for a great street festival.",

	SI_TACHRONOS_Moon_Festival              = "Moon Festival",
	SI_TACHRONOS_Moon_Festival_date         = "8th Sun's Dusk",
	SI_TACHRONOS_Moon_Festival_text         = "On the 8th of Suns Dusk, the Bretons of Glenumbra Moors hold the Moon Festival, a joyous holiday in honor of Secunda, goddess of the moon. Although the goddess has no active worshippers, the traditional celebration has continued through the ages as a time of feasting and merriment.",
	
	SI_TACHRONOS_Hel_Anseilak               = "Hel Anseilak",
	SI_TACHRONOS_Hel_Anseilak_date          = "18th Sun's Dusk",
	SI_TACHRONOS_Hel_Anseilak_text          = "Hel Anseilak, which means 'Communion with the Saints of the Sword' in Old Redguard, is the most serious of holy days for the people of Pothago. The ancient way of Hel Ansei is never practiced by modern Redguards, but its rich heritage is remembered and honored on this day.",
	
	SI_TACHRONOS_Warriors_Festival          = "Warriors Festival",
	SI_TACHRONOS_Warriors_Festival_date     = "20th Sun's Dusk",
	SI_TACHRONOS_Warriors_Festival_text     = "Today is the 20th of Sun's Dusk, the Warriors Festival in Tamriel. Most all the local warriors, spellswords, and rogues come to the equipment stores and blacksmiths where all weapons are half price. Unfortunately, the low prices also tempt many an untrained boy to buy his first sword and the normally quiet streets ring with amateur skirmishes. In TES2, this is also the summoning day of Mehrunes Dagon.",
	
	SI_TACHRONOS_North_Winds_Prayer         = "North Wind's Prayer",
	SI_TACHRONOS_North_Winds_Prayer_date    = "15th Evening Star",
	SI_TACHRONOS_North_Winds_Prayer_text    = "Today is the 15th of Evening Star, a holiday reverently observed by the temples as North Wind's Prayer. It is a thanksgiving to the Gods for a good harvest and a mild winter. The temples offer all their services blessing, curing, healing for half the donation usually requested.",
	
	SI_TACHRONOS_Baranth_Do                 = "Baranth Do",
	SI_TACHRONOS_Baranth_Do_date            = "18th Evening Star",
	SI_TACHRONOS_Baranth_Do_text            = "Baranth Do is celebrated on the 18th of Evening. Star by the Redguards of the Alik'r Desert. Its meaning is 'Goodbye to the Beast of Last Year'. Pageants featuring demonic representations of the old year are popular, and revelry to honor the new year is everywhere.",

	SI_TACHRONOS_Chila                      = "Chil'a",
	SI_TACHRONOS_Chila_date                 = "21th Evening Star",
	SI_TACHRONOS_Chila_text                 = "Chil'a, the blessing of the new year in the barony of Kairou, is both a sacred day and a festival. The archpriest and the baroness each consecrate the ashes of the old year in solemn ceremony, then street parades, balls, and tournaments conclude the event.\nAccording to the book Holidays of the Iliac Bay, this festival instead takes place on the 24th.\nIn TES2, this date is also the summoning day of Molag Bal.",
	
	SI_TACHRONOS_Saturalia                  = "Saturalia",
	SI_TACHRONOS_Saturalia_date             = "25th Evening Star",
	SI_TACHRONOS_Saturalia_text             = "Saturalia is a Breton celebration that heralds the New Life Festival, and is held on the 25th of Evening Star. Originally a holiday for the god of debauchery, it has become a time of gift giving, parties, and parading. Visitors are encouraged to participate. Among the Khajiit the Saturalia celebration and sharing of gifts is known as the 'Saturalia Baan Dar gift swap'. In Elinhir, the youth of the gentry give each other licentious presents during Saturalia that are intended to dare the recipients into lascivious behavior, though the giver's name is never revealed it's up to each recipient to guess who their 'Secret Sanguine' was. Saturalia shares many similarities to the New Life Festival. A shared tradition involves decorating evergreen trees with elaborate decorations, and are topped with a shining light ornament on its peak. Evergreen trees are chosen because they are associated with resilience and rebirth. Gift giving is another thing shared, and 'giving gifts' are placed under these festive trees. Saturalia trees are used in both Saturalia and the New Life Festival. In both holidays, shades of cerulean are used as the color of clothing for these holidays",

	SI_TACHRONOS_Old_Life                   = "Old Life",
	SI_TACHRONOS_Old_Life_date              = "30th Evening Star",
	SI_TACHRONOS_Old_Life_text              = "On the last day of the year the Empire celebrates the holiday called Old Life. Many go to the temples to reflect on their past. Some go for more than this, for it is rumored that priests will, as the last act of the year, perform resurrections on beloved friends and family members free of the usual charge. Worshippers know better than to expect this philanthropy, but they arrive in a macabre procession with the recently deceased nevertheless.\nFor information on how this festival was percieved in 2nd Era Tamriel, see From Old Life to New.",

    SI_TACHRONOS_TODAYS_HOLIDAYS            = "Tamriel Chronos - <<1>>",
    
    SI_TACHRONOS_CALENDAR_TITLE             = "Tamriel Holiday Calendar",

	SI_TACHRONOS_Legend_Year                = "Month of the year",
	SI_TACHRONOS_Jan                        = "January",
	SI_TACHRONOS_Feb                        = "February",
	SI_TACHRONOS_Mar                        = "March",
	SI_TACHRONOS_Apr                        = "April",
	SI_TACHRONOS_May                        = "May",
	SI_TACHRONOS_Jun                        = "June",
	SI_TACHRONOS_Jul                        = "July",
	SI_TACHRONOS_Aug                        = "August",
	SI_TACHRONOS_Sep                        = "September",
	SI_TACHRONOS_Oct                        = "October",
	SI_TACHRONOS_Nov                        = "November",
	SI_TACHRONOS_Dec                        = "December",

	SI_TACHRONOS_Legend_Week                = "Day of the week",
	SI_TACHRONOS_Sunday                     = "Sunday",
	SI_TACHRONOS_Monday                     = "Monday",
	SI_TACHRONOS_Tuesday                    = "Tuesday",
	SI_TACHRONOS_Wednesday                  = "Wednesday",
	SI_TACHRONOS_Thursday                   = "Thursday",
	SI_TACHRONOS_Friday                     = "Friday",
	SI_TACHRONOS_Saturday                   = "Saturday ",
}

local pairs = pairs
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end