-- =========================
-- Lore Tooltips - System Aliasów
-- =========================
-- Ten plik zawiera mapowanie odmian polskich na klucze wiki
-- Format: ["odmiana w tekście"] = "Klucz_Wiki"
-- Wielkość liter nie ma znaczenia (case-insensitive)
--
-- WAŻNE: Ten plik jest edytowany ręcznie! 
-- Baza LoreDatabase.lua jest generowana automatycznie z API. 

LoreTooltips = LoreTooltips or {}


-- =========================
-- Przykładowe wykluczenie krótszego aliasu
-- =========================
-- Alias z wykluczeniem
--    ["gamyne"] = { 
--        key = "Gamyne", 
--        excluded = { "gamyne bandu" } 
--    },

-- =========================
-- ALIASY - Mapowanie odmian na klucze wiki
-- =========================
LoreTooltips.Aliases = {
----------------------------------------------------------------------------------------------------------------------------
	-- Miejsca start --
----------------------------------------------------------------------------------------------------------------------------
    -- Cambray Pass  
    ["cambray pass"] = "Cambray_Pass",
    ["przesmyk cambray"] = "Cambray_Pass",   
    ["przesmyku cambray"] = "Cambray_Pass",
    ["przesmykiem cambray"] = "Cambray_Pass",  
    ["przesmykowi cambray"] = "Cambray_Pass",  
	-- Lost Prospect
    ["lost prospect"] = "Kopalnia_Utracone_Widoki",
	["kopalnia utracone widoki"] = "Kopalnia_Utracone_Widoki",
    ["utracone widoki"] = "Kopalnia_Utracone_Widoki",   
    ["utraconych widoków"] = "Kopalnia_Utracone_Widoki",  
    ["utraconym widokom"] = "Kopalnia_Utracone_Widoki",   
    ["utraconymi widokami"] = "Kopalnia_Utracone_Widoki", 
    ["utraconych widokach"] = "Kopalnia_Utracone_Widoki", 
	["grobowiec rodziny gimothran"] = "Grobowiec_rodziny_Gimothran",	-- Brak nazwy w grze	
    -- Coiled Path Landing    
    ["coiled path landing"] = "Coiled_Path_Landing",
    ["pomost skręconej ścieżki"] = "Coiled_Path_Landing", 
    ["pomostu skręconej ścieżki"] = "Coiled_Path_Landing",  
    ["pomostowi skręconej ścieżki"] = "Coiled_Path_Landing",
    ["pomostem skręconej ścieżki"] = "Coiled_Path_Landing", 
    ["pomoście skręconej ścieżki"] = "Coiled_Path_Landing",    
    -- Khenarthi's Roost    
    ["khenarthi's roost"] = "Khenarthi's_Roost",
    -- Grzęda Khenarthi
    ["grzęda khenarthi"] = "Khenarthi's_Roost",   
    ["grzędy khenarthi"] = "Khenarthi's_Roost",   
    ["grzędzie khenarthi"] = "Khenarthi's_Roost", 
    ["grzędę khenarthi"] = "Khenarthi's_Roost",   
    ["grzędą khenarthi"] = "Khenarthi's_Roost",   
    ["grzędo khenarthi"] = "Khenarthi's_Roost",   	
    -- Farmer's Nook   
    ["farmer's nook"] = "Farmer's_Nook",
    ["zakątek rolnika"] = "Farmer's_Nook", 
    ["zakątka rolnika"] = "Farmer's_Nook",   
    ["zakątkowi rolnika"] = "Farmer's_Nook", 
    ["zakątkiem rolnika"] = "Farmer's_Nook", 
    ["zakątku rolnika"] = "Farmer's_Nook",   
    -- Grymharth's Woe    
    ["grymharth's woe"] = "Grymharth's_Woe",
    ["zguba grymhartha"] = "Grymharth's_Woe",   
    ["zguby grymhartha"] = "Grymharth's_Woe",   
    ["zgubie grymhartha"] = "Grymharth's_Woe",  
    ["zgubę grymhartha"] = "Grymharth's_Woe",   
    ["zgubą grymhartha"] = "Grymharth's_Woe",   
    ["zgubo grymhartha"] = "Grymharth's_Woe",   
	["senie"] = "Senie",	-- en=pl
	["vlastarus"] = "Vlastarus",	-- en=pl	
    -- Windhelm Bank   
    ["windhelm bank"] = "Windhelm_Bank",
    ["bank wichrowego tronu"] = "Windhelm_Bank", 
    ["banku wichrowego tronu"] = "Windhelm_Bank",
    ["bankowi wichrowego tronu"] = "Windhelm_Bank",
    ["bankiem wichrowego tronu"] = "Windhelm_Bank",
	["cyrodiil"] = "Cyrodiil",	-- en=pl
	-- Morthal
    ["morthal"] = "Morthal",
    ["morthalu"] = "Morthal", 
    ["morthalowi"] = "Morthal", 
    ["morthalem"] = "Morthal",  
	["stone eagle aerie"] = "Stone_Eagle_Aerie",
	-- Blue Palace
    ["blue palace"] = "Błękitny_Pałac",
    ["błękitny pałac"] = "Błękitny_Pałac",    
    ["błękitnego pałacu"] = "Błękitny_Pałac",   
    ["błękitnemu pałacowi"] = "Błękitny_Pałac", 
    ["błękitnym pałacem"] = "Błękitny_Pałac",   
    ["błękitnym pałacu"] = "Błękitny_Pałac",    
	["grobowiec rodziny thiralas"] = "Grobowiec_rodziny_Thiralas",	-- Brak w grze
	-- Scalecaller Peak
    ["scalecaller peak"] = "Scalecaller_Peak",
    ["łuskowaty szczyt"] = "Scalecaller_Peak",   
    ["łuskowatego szczytu"] = "Scalecaller_Peak",  
    ["łuskowatemu szczytowi"] = "Scalecaller_Peak",
    ["łuskowatym szczytem"] = "Scalecaller_Peak",  
    ["łuskowatym szczycie"] = "Scalecaller_Peak",  
    ["łuskowaty szczycie"] = "Scalecaller_Peak",   
	-- Hircine's Henge
    ["hircine's henge"] = "Hircine's_Henge",
    ["krąg hircyna"] = "Hircine's_Henge",   
    ["kręgu hircyna"] = "Hircine's_Henge",
    ["kręgowi hircyna"] = "Hircine's_Henge",  
    ["kręgiem hircyna"] = "Hircine's_Henge",  
	-- Abandoned Orchard
    ["abandoned orchard"] = "Abandoned_Orchard",
    ["opuszczony sad"] = "Abandoned_Orchard",   
    ["opuszczonego sadu"] = "Abandoned_Orchard",  
    ["opuszczonemu sadowi"] = "Abandoned_Orchard",
    ["opuszczonym sadem"] = "Abandoned_Orchard",  
    ["opuszczonym sadzie"] = "Abandoned_Orchard", 
    ["opuszczony sadzie"] = "Abandoned_Orchard",  
	-- Bonestrewn Crest
    ["bonestrewn crest"] = "Kościany_Szczyt",
    ["kościany szczyt"] = "Kościany_Szczyt",   
    ["kościanego szczytu"] = "Kościany_Szczyt",  
    ["kościanemu szczytowi"] = "Kościany_Szczyt",
    ["kościanym szczytem"] = "Kościany_Szczyt",  
    ["kościanym szczycie"] = "Kościany_Szczyt",  
    ["kościany szczycie"] = "Kościany_Szczyt",   
	-- Skyshroud Barrow
    ["skyshroud barrow"] = "Skyshroud_Barrow",
    ["kurhan niebieskiego całunu"] = "Skyshroud_Barrow",   
    ["kurhanu niebieskiego całunu"] = "Skyshroud_Barrow",    
    ["kurhanowi niebieskiego całunu"] = "Skyshroud_Barrow",  
    ["kurhanem niebieskiego całunu"] = "Skyshroud_Barrow",   
    ["kurhanie niebieskiego całunu"] = "Skyshroud_Barrow",   
	-- The Rise of Queen Ayrenn
    ["the rise of queen ayrenn"] = "The_Rise_of_Queen_Ayrenn",
    ["początki królowej ayrenn"] = "The_Rise_of_Queen_Ayrenn", 
    ["początków królowej ayrenn"] = "The_Rise_of_Queen_Ayrenn",  
    ["początkom królowej ayrenn"] = "The_Rise_of_Queen_Ayrenn",  
    ["początkami królowej ayrenn"] = "The_Rise_of_Queen_Ayrenn", 
    ["początkach królowej ayrenn"] = "The_Rise_of_Queen_Ayrenn", 
	-- Sky's Edge Tavern
    ["sky's edge tavern"] = "Sky's_Edge_Tavern",
    ["tawerna brzeg nieba"] = "Sky's_Edge_Tavern",   
    ["tawerny brzeg nieba"] = "Sky's_Edge_Tavern",   
    ["tawernie brzeg nieba"] = "Sky's_Edge_Tavern",  
    ["tawernę brzeg nieba"] = "Sky's_Edge_Tavern",   
    ["tawerną brzeg nieba"] = "Sky's_Edge_Tavern",   
    ["tawerno brzeg nieba"] = "Sky's_Edge_Tavern",   
	["sutch"] = "Sutch",	-- en=pl
	["naj-caldeesh"] = "Naj-Caldeesh",	-- en=pl
	["piukanda"] = "Piukanda",	-- en=pl
	-- Halmaera's House
    ["halmaera's house"] = "Halmaera's_House",
    ["dom halmaery"] = "Halmaera's_House",   
    ["domu halmaery"] = "Halmaera's_House",
    ["domowi halmaery"] = "Halmaera's_House",  
    ["domem halmaery"] = "Halmaera's_House",   
	["jaskinia nisin"] = "Jaskinia_Nisin",
	-- Heimlyn Keep
    ["heimlyn keep"] = "Heimlyn_Keep",
    ["warownia heimlyn"] = "Heimlyn_Keep",   
    ["warowni heimlyn"] = "Heimlyn_Keep",   
    ["warownię heimlyn"] = "Heimlyn_Keep",   
    ["warownią heimlyn"] = "Heimlyn_Keep",   
    ["warownio heimlyn"] = "Heimlyn_Keep",   
	-- Colovian Revolt Forge Yard
    ["colovian revolt forge yard"] = "Colovian_Revolt_Forge_Yard",
    ["dziedziniec kuźni przewrotu coloviańskiego"] = "Colovian_Revolt_Forge_Yard", 
    ["dziedzińca kuźni przewrotu coloviańskiego"] = "Colovian_Revolt_Forge_Yard",    
    ["dziedzińcowi kuźni przewrotu coloviańskiego"] = "Colovian_Revolt_Forge_Yard",  
    ["dziedzińcem kuźni przewrotu coloviańskiego"] = "Colovian_Revolt_Forge_Yard",   
    ["dziedzińcu kuźni przewrotu coloviańskiego"] = "Colovian_Revolt_Forge_Yard",    
	-- The Fragrant Fungus
    ["the fragrant fungus"] = "The_Fragrant_Fungus",
    ["wonne grzyby"] = "The_Fragrant_Fungus",   
    ["wonnych grzybów"] = "The_Fragrant_Fungus",  
    ["wonnym grzybom"] = "The_Fragrant_Fungus",   
    ["wonnymi grzybami"] = "The_Fragrant_Fungus", 
    ["wonnych grzybach"] = "The_Fragrant_Fungus", 
	-- Autumn's-Gate
    ["autumn's-gate"] = "Autumn's-Gate",
    ["jesienna brama"] = "Autumn's-Gate",     
    ["jesiennej bramy"] = "Autumn's-Gate",    
    ["jesiennej bramie"] = "Autumn's-Gate",   
    ["jesienną bramę"] = "Autumn's-Gate",     
    ["jesienną bramą"] = "Autumn's-Gate",     
    ["jesienna bramo"] = "Autumn's-Gate",     
	-- Paddlefloe Fishing Camp
    ["paddlefloe fishing camp"] = "Paddlefloe_Fishing_Camp",
    ["obóz rybacki wiosłująca kra"] = "Paddlefloe_Fishing_Camp",   
    ["obozu rybackiego wiosłująca kra"] = "Paddlefloe_Fishing_Camp",  
    ["obozowi rybackiemu wiosłująca kra"] = "Paddlefloe_Fishing_Camp",
    ["obozem rybackim wiosłująca kra"] = "Paddlefloe_Fishing_Camp",   
    ["obozie rybackim wiosłująca kra"] = "Paddlefloe_Fishing_Camp",   
    ["obozie rybacki wiosłująca kra"] = "Paddlefloe_Fishing_Camp",    
	-- Uveran Bank
    ["uveran bank"] = "Uveran_Bank",
    ["bank uveran"] = "Uveran_Bank",   
    ["banku uveran"] = "Uveran_Bank",
    ["bankowi uveran"] = "Uveran_Bank",  
    ["bankiem uveran"] = "Uveran_Bank",  
	-- Kingscrest Milegate
    ["kingscrest milegate"] = "Kingscrest_Milegate",

    -- Wersja: Brama milowa Kingcrest (Twoja)
    ["brama milowa kingcrest"] = "Kingscrest_Milegate",   
    ["bramy milowej kingcrest"] = "Kingscrest_Milegate",  
    ["bramie milowej kingcrest"] = "Kingscrest_Milegate", 
    ["bramę milową kingcrest"] = "Kingscrest_Milegate",   
    ["bramą milową kingcrest"] = "Kingscrest_Milegate",   
    ["bramo milowa kingcrest"] = "Kingscrest_Milegate",   

    -- Wersja: Brama milowa Królewskiego Herbu (z bazy)
    ["brama milowa królewskiego herbu"] = "Kingscrest_Milegate",   
    ["bramy milowej królewskiego herbu"] = "Kingscrest_Milegate",  
    ["bramie milowej królewskiego herbu"] = "Kingscrest_Milegate", 
    ["bramę milową królewskiego herbu"] = "Kingscrest_Milegate",   
    ["bramą milową królewskiego herbu"] = "Kingscrest_Milegate",   
    ["bramo milowa królewskiego herbu"] = "Kingscrest_Milegate",   
	-- Chalman Milegate
    ["chalman milegate"] = "Chalman_Milegate",
    ["brama milowa chalman"] = "Chalman_Milegate",   
    ["bramy milowej chalman"] = "Chalman_Milegate",  
    ["bramie milowej chalman"] = "Chalman_Milegate", 
    ["bramę milową chalman"] = "Chalman_Milegate",   
    ["bramą milową chalman"] = "Chalman_Milegate",   
    ["bramo milowa chalman"] = "Chalman_Milegate",   
	-- Fort Popielny
    ["fort ash"] = "Fort_Popielny",
	["fort popielny"] = "Fort_Popielny",
    ["fortu popielnego"] = "Fort_Popielny",   
    ["fortowi popielnemu"] = "Fort_Popielny", 
    ["fortem popielnym"] = "Fort_Popielny",   
    ["forcie popielnym"] = "Fort_Popielny",   
    ["forcie popielny"] = "Fort_Popielny",    
	-- Giant's Heart
    ["giant's heart"] = "Giant's_Heart",
    ["serce giganta"] = "Giant's_Heart",   
    ["serca giganta"] = "Giant's_Heart",     
    ["sercu giganta"] = "Giant's_Heart",     
    ["sercem giganta"] = "Giant's_Heart",    
	-- Predator Mesa
    ["predator mesa"] = "Predator_Mesa",
    ["płaskowyż drapieżcy"] = "Predator_Mesa",   
    ["płaskowyżu drapieżcy"] = "Predator_Mesa",
    ["płaskowyżowi drapieżcy"] = "Predator_Mesa",  
    ["płaskowyżem drapieżcy"] = "Predator_Mesa",   
	["ayrenn online"] = "Ayrenn_Online",
	-- The Brahma's Grove
    ["the brahma's grove"] = "The_Brahma's_Grove",
    ["gaj brahmy"] = "The_Brahma's_Grove",   
    ["gaju brahmy"] = "The_Brahma's_Grove",
    ["gajowi brahmy"] = "The_Brahma's_Grove",  
    ["gajem brahmy"] = "The_Brahma's_Grove",   
	-- Bergama
    ["bergama"] = "Bergama",
    ["bergamy"] = "Bergama",   
    ["bergamie"] = "Bergama",  
    ["bergamę"] = "Bergama",   
    ["bergamą"] = "Bergama",   
    ["bergamo"] = "Bergama",   
	-- The Bastard's Tomb
    ["the bastard's tomb"] = "The_Bastard's_Tomb",
    ["grób bękarta"] = "The_Bastard's_Tomb",   
    ["grobu bękarta"] = "The_Bastard's_Tomb",    
    ["grobowi bękarta"] = "The_Bastard's_Tomb",  
    ["grobem bękarta"] = "The_Bastard's_Tomb",   
    ["grobie bękarta"] = "The_Bastard's_Tomb",   
	-- Newt Cave
    ["newt cave"] = "Jaskinia_Traszki",
    ["jaskinia traszki"] = "Jaskinia_Traszki",     
    ["jaskini traszki"] = "Jaskinia_Traszki",     
    ["jaskinię traszki"] = "Jaskinia_Traszki",     
    ["jaskinią traszki"] = "Jaskinia_Traszki",     
    ["jaskinio traszki"] = "Jaskinia_Traszki",     
	-- Easterly Aerie
    ["easterly aerie"] = "Easterly_Aerie",
    ["wschodnie gniazdo"] = "Easterly_Aerie",   
    ["wschodniego gniazda"] = "Easterly_Aerie",   
    ["wschodniemu gniazdu"] = "Easterly_Aerie",   
    ["wschodnim gniazdem"] = "Easterly_Aerie",    
    ["wschodnim gnieździe"] = "Easterly_Aerie",   
	-- Forsaken Hamlet
    ["forsaken hamlet"] = "Forsaken_Hamlet",
    ["zapomniana wioska"] = "Forsaken_Hamlet",     
    ["zapomnianej wioski"] = "Forsaken_Hamlet",    
    ["zapomnianej wiosce"] = "Forsaken_Hamlet",    
    ["zapomnianą wioskę"] = "Forsaken_Hamlet",     
    ["zapomnianą wioską"] = "Forsaken_Hamlet",     
    ["zapomniana wiosko"] = "Forsaken_Hamlet",     
	-- Shrine of the Hunt-Father
    ["shrine of the hunt-father"] = "Shrine_of_the_Hunt-Father",
    ["kapliczka ojca łowów"] = "Shrine_of_the_Hunt-Father",     
    ["kapliczki ojca łowów"] = "Shrine_of_the_Hunt-Father",     
    ["kapliczce ojca łowów"] = "Shrine_of_the_Hunt-Father",     
    ["kapliczkę ojca łowów"] = "Shrine_of_the_Hunt-Father",     
    ["kapliczką ojca łowów"] = "Shrine_of_the_Hunt-Father",     
    ["kapliczko ojca łowów"] = "Shrine_of_the_Hunt-Father",     
	-- Wayrest Sewers
    ["wayrest sewers"] = "Kanały_w_Wayrest",
	["kanały w wayrest"] = "Kanały_w_Wayrest",
    ["kanały wayrest"] = "Kanały_w_Wayrest",   
    ["kanałów wayrest"] = "Kanały_w_Wayrest",    
    ["kanałom wayrest"] = "Kanały_w_Wayrest",    
    ["kanałami wayrest"] = "Kanały_w_Wayrest",   
    ["kanałach wayrest"] = "Kanały_w_Wayrest",   
	-- Halls of Submission
    ["halls of submission"] = "Halls_of_Submission",
    ["sale posłuszeństwa"] = "Halls_of_Submission",   
    ["sal posłuszeństwa"] = "Halls_of_Submission",      
    ["salom posłuszeństwa"] = "Halls_of_Submission",    
    ["salami posłuszeństwa"] = "Halls_of_Submission",   
    ["salach posłuszeństwa"] = "Halls_of_Submission",   
	-- Mistwatch (Strażnica Mgły)
    ["mistwatch"] = "Strażnica_Mgły",
    ["strażnica mgły"] = "Strażnica_Mgły",        
    ["strażnicy mgły"] = "Strażnica_Mgły",       
    ["strażnicę mgły"] = "Strażnica_Mgły",        
    ["strażnicą mgły"] = "Strażnica_Mgły",        
    ["strażnico mgły"] = "Strażnica_Mgły",        
	-- Crestshade
    ["crestshade"] = "Crestshade",
    ["zacieniona grań"] = "Crestshade",     
    ["zacienionej grani"] = "Crestshade",  
    ["zacienioną grań"] = "Crestshade",     
    ["zacienioną granią"] = "Crestshade",   
    ["zacieniona grani"] = "Crestshade",    
	-- Del's Claim
    ["del's claim"] = "Del's_Claim",
    ["roszczenie dela"] = "Del's_Claim",   
    ["roszczenia dela"] = "Del's_Claim",     
    ["roszczeniu dela"] = "Del's_Claim",     
    ["roszczeniem dela"] = "Del's_Claim",    
	["nornal"] = "Nornal",	-- en=pl
	-- Harlun's Watch
    ["harlun's watch"] = "Warownia_Harluna",
    ["warownia harluna"] = "Warownia_Harluna",    
    ["warowni harluna"] = "Warownia_Harluna",    
    ["warownię harluna"] = "Warownia_Harluna",    
    ["warownią harluna"] = "Warownia_Harluna",    
    ["warownio harluna"] = "Warownia_Harluna",    
	-- Darkwater Crossing
    ["darkwater crossing"] = "Czarny_Ruczaj",
    ["czarny ruczaj"] = "Czarny_Ruczaj",  
    ["czarnego ruczaju"] = "Czarny_Ruczaj",       
    ["czarnemu ruczajowi"] = "Czarny_Ruczaj",     
    ["czarnym ruczajem"] = "Czarny_Ruczaj",       
    ["czarnym ruczaju"] = "Czarny_Ruczaj",        
    ["czarny ruczaju"] = "Czarny_Ruczaj",         
	["wittestadr"] = "Wittestadr",	-- en=pl
	["chorrol"] = "Chorrol",	-- en=pl
	["bal foyen"] = "Bal_Foyen",	-- en=pl
	["urasek"] = "Urasek",	-- en=pl
	-- Serpent Hollow Cave
    ["serpent hollow cave"] = "Jaskinia_Gniazda_Węży",
    ["jaskinia gniazda węży"] = "Jaskinia_Gniazda_Węży",   
    ["jaskini gniazda węży"] = "Jaskinia_Gniazda_Węży",   
    ["jaskinię gniazda węży"] = "Jaskinia_Gniazda_Węży",   
    ["jaskinią gniazda węży"] = "Jaskinia_Gniazda_Węży",   
    ["jaskinio gniazda węży"] = "Jaskinia_Gniazda_Węży",   
	-- Indoril Manor
    ["indoril manor"] = "Indoril_Manor",
    ["rezydencja indoril"] = "Indoril_Manor",   
    ["rezydencji indoril"] = "Indoril_Manor",  
    ["rezydencję indoril"] = "Indoril_Manor",   
    ["rezydencją indoril"] = "Indoril_Manor",   
    ["rezydencjo indoril"] = "Indoril_Manor",   
	-- The Wolf's Camp
    ["the wolf's camp"] = "The_Wolf's_Camp",
    ["obóz wilka"] = "The_Wolf's_Camp",   
    ["obozu wilka"] = "The_Wolf's_Camp",    
    ["obozowi wilka"] = "The_Wolf's_Camp",  
    ["obozem wilka"] = "The_Wolf's_Camp",   
    ["obozie wilka"] = "The_Wolf's_Camp",   
	-- Black Gem Foundry
    ["black gem foundry"] = "Black_Gem_Foundry",
    ["odlewnia czarnych klejnotów"] = "Black_Gem_Foundry",   
    ["odlewni czarnych klejnotów"] = "Black_Gem_Foundry",   
    ["odlewnię czarnych klejnotów"] = "Black_Gem_Foundry",   
    ["odlewnią czarnych klejnotów"] = "Black_Gem_Foundry",   
    ["odlewnio czarnych klejnotów"] = "Black_Gem_Foundry",   
	-- Knife Ear Grotto
    ["knife ear grotto"] = "Knife_Ear_Grotto",
    ["grota sztyletouchych"] = "Knife_Ear_Grotto",     
    ["groty sztyletouchych"] = "Knife_Ear_Grotto",     
    ["grocie sztyletouchych"] = "Knife_Ear_Grotto",    
    ["grotę sztyletouchych"] = "Knife_Ear_Grotto",     
    ["grotą sztyletouchych"] = "Knife_Ear_Grotto",     
    ["groto sztyletouchych"] = "Knife_Ear_Grotto",     
	-- Solitude
    ["solitude"] = "Samotnia",
    ["samotnia"] = "Samotnia",     
    ["samotni"] = "Samotnia",     
    ["samotnię"] = "Samotnia",     
    ["samotnią"] = "Samotnia",     
    ["samotnio"] = "Samotnia",     
	["variela"] = "Variela",	-- ?
	-- Stone Garden
    ["stone garden"] = "Stone_Garden",
    ["kamienny ogród"] = "Stone_Garden",   
    ["kamiennego ogrodu"] = "Stone_Garden",  
    ["kamiennemu ogrodowi"] = "Stone_Garden",
    ["kamiennym ogrodem"] = "Stone_Garden",  
    ["kamiennym ogrodzie"] = "Stone_Garden", 
    ["kamienny ogrodzie"] = "Stone_Garden",  
	-- Triple Circle Mine
    ["triple circle mine"] = "Triple_Circle_Mine",
    ["kopalnia potrójnego okręgu"] = "Triple_Circle_Mine",   
    ["kopalni potrójnego okręgu"] = "Triple_Circle_Mine",   
    ["kopalnię potrójnego okręgu"] = "Triple_Circle_Mine",   
    ["kopalnią potrójnego okręgu"] = "Triple_Circle_Mine",   
    ["kopalnio potrójnego okręgu"] = "Triple_Circle_Mine",   
	-- Thulvald's Logging Camp
    ["thulvald's logging camp"] = "Thulvald's_Logging_Camp",
    ["obóz drwali thulvalda"] = "Thulvald's_Logging_Camp",   
    ["obozu drwali thulvalda"] = "Thulvald's_Logging_Camp",    
    ["obozowi drwali thulvalda"] = "Thulvald's_Logging_Camp",  
    ["obozem drwali thulvalda"] = "Thulvald's_Logging_Camp",   
    ["obozie drwali thulvalda"] = "Thulvald's_Logging_Camp",   
	-- Proudspire Manor
    ["proudspire manor"] = "Posiadłość_Dumna_Wieżyca",
    ["posiadłość dumna wieżyca"] = "Posiadłość_Dumna_Wieżyca",   
    ["posiadłości dumnej wieżycy"] = "Posiadłość_Dumna_Wieżyca",  
    ["posiadłość dumną wieżycę"] = "Posiadłość_Dumna_Wieżyca",     
    ["posiadłością dumną wieżycą"] = "Posiadłość_Dumna_Wieżyca",   
    ["posiadłości dumna wieżyco"] = "Posiadłość_Dumna_Wieżyca",    
	-- Library of Arkthzand
    ["library of arkthzand"] = "Library_of_Arkthzand",
    ["biblioteka arkthzand"] = "Library_of_Arkthzand",     
    ["biblioteki arkthzand"] = "Library_of_Arkthzand",     
    ["bibliotece arkthzand"] = "Library_of_Arkthzand",     
    ["bibliotekę arkthzand"] = "Library_of_Arkthzand",     
    ["biblioteką arkthzand"] = "Library_of_Arkthzand",     
    ["biblioteko arkthzand"] = "Library_of_Arkthzand",     
	-- Ice-Heart Home
    ["ice-heart home"] = "Ice-Heart_Home",
    ["dom lodowych serc"] = "Ice-Heart_Home",   
    ["domu lodowych serc"] = "Ice-Heart_Home",
    ["domowi lodowych serc"] = "Ice-Heart_Home",  
    ["domem lodowych serc"] = "Ice-Heart_Home",   
	-- Wolf's Eye Lighthouse
    ["wolf's eye lighthouse"] = "Latarnia_morska_w_Samotni",
	["latarnia morska w samotni"] = "Latarnia_morska_w_Samotni",
    ["latarnia wilczego oka"] = "Latarnia_morska_w_Samotni",     
    ["latarni wilczego oka"] = "Latarnia_morska_w_Samotni",     
    ["latarnię wilczego oka"] = "Latarnia_morska_w_Samotni",     
    ["latarnią wilczego oka"] = "Latarnia_morska_w_Samotni",     
    ["latarnio wilczego oka"] = "Latarnia_morska_w_Samotni",     
	["roebeck"] = "Roebeck",	-- en=pl
	["antiquarian's alpine gallery"] = "Antiquarian's_Alpine_Gallery",
	-- Riverside Inn
    ["riverside inn"] = "Riverside_Inn",
    ["nadrzeczna karczma"] = "Riverside_Inn",     
    ["nadrzecznej karczmy"] = "Riverside_Inn",    
    ["nadrzecznej karczmie"] = "Riverside_Inn",   
    ["nadrzeczną karczmę"] = "Riverside_Inn",     
    ["nadrzeczną karczmą"] = "Riverside_Inn",     
    ["nadrzeczna karczmo"] = "Riverside_Inn",     
	-- Haynekhtnamet's Lair
    ["haynekhtnamet's lair"] = "Haynekhtnamet's_Lair",
    ["gniazdo haynekhtnameta"] = "Haynekhtnamet's_Lair",   
    ["gniazda haynekhtnameta"] = "Haynekhtnamet's_Lair",     
    ["gniazdu haynekhtnameta"] = "Haynekhtnamet's_Lair",     
    ["gniazdem haynekhtnameta"] = "Haynekhtnamet's_Lair",    
    ["gnieździe haynekhtnameta"] = "Haynekhtnamet's_Lair",   
	-- Crow's Wood
    ["crow's wood"] = "Crow's_Wood",

    -- Wersja 1: Wronia Puszcza 
    ["wronia puszcza"] = "Crow's_Wood",     
    ["wroniej puszczy"] = "Crow's_Wood",   
    ["wronią puszczę"] = "Crow's_Wood",     
    ["wronią puszczą"] = "Crow's_Wood",     
    ["wronia puszczo"] = "Crow's_Wood",     

    -- Wersja 2: Las Wron (Nazwa w bazie)
    ["las wron"] = "Crow's_Wood",   
    ["lasu wron"] = "Crow's_Wood", 
    ["lasowi wron"] = "Crow's_Wood", 
    ["lasem wron"] = "Crow's_Wood",
    ["lesie wron"] = "Crow's_Wood",         
	-- Helan Ancestral Tomb
    ["helan ancestral tomb"] = "Grobowiec_rodziny_Helan",
    ["grobowiec rodziny helan"] = "Grobowiec_rodziny_Helan",   
    ["grobowca rodziny helan"] = "Grobowiec_rodziny_Helan",      
    ["grobowcowi rodziny helan"] = "Grobowiec_rodziny_Helan",    
    ["grobowcem rodziny helan"] = "Grobowiec_rodziny_Helan",     
    ["grobowcu rodziny helan"] = "Grobowiec_rodziny_Helan",      
	-- Eldbjorg's Hideaway
    ["eldbjorg's hideaway"] = "Eldbjorg's_Hideaway",
    ["kryjówka eldbjorga"] = "Eldbjorg's_Hideaway",     
    ["kryjówki eldbjorga"] = "Eldbjorg's_Hideaway",     
    ["kryjówce eldbjorga"] = "Eldbjorg's_Hideaway",     
    ["kryjówkę eldbjorga"] = "Eldbjorg's_Hideaway",     
    ["kryjówką eldbjorga"] = "Eldbjorg's_Hideaway",     
    ["kryjówko eldbjorga"] = "Eldbjorg's_Hideaway",     
	-- Valeguard Tower
    ["valeguard tower"] = "Valeguard_Tower",
    ["strażnica doliny"] = "Valeguard_Tower",     
    ["strażnicy doliny"] = "Valeguard_Tower",    
    ["strażnicę doliny"] = "Valeguard_Tower",     
    ["strażnicą doliny"] = "Valeguard_Tower",     
    ["strażnico doliny"] = "Valeguard_Tower",     
	["kozanset"] = "Kozanset",	-- en=pl
	-- Midnight Barrow
    ["midnight barrow"] = "Midnight_Barrow",

    -- Wersja 1: Północny Kurhan 
    ["północny kurhan"] = "Midnight_Barrow",   
    ["północnego kurhanu"] = "Midnight_Barrow",  
    ["północnemu kurhanowi"] = "Midnight_Barrow",
    ["północnym kurhanem"] = "Midnight_Barrow",  
    ["północnym kurhanie"] = "Midnight_Barrow",  
    ["północny kurhanie"] = "Midnight_Barrow",   

    -- Wersja 2: Kurhan Północy (Nazwa w bazie)
    ["kurhan północy"] = "Midnight_Barrow",    
    ["kurhanu północy"] = "Midnight_Barrow",    
    ["kurhanem północy"] = "Midnight_Barrow",    
    ["kurhanie północy"] = "Midnight_Barrow",    
	-- Rethan Holdings
    ["rethan holdings"] = "Rethan_Holdings",

    -- Wersja 1: Spółka Handlowa Rethan 
    ["spółka handlowa rethan"] = "Rethan_Holdings",     
    ["spółki handlowej rethan"] = "Rethan_Holdings",    
    ["spółce handlowej rethan"] = "Rethan_Holdings",    
    ["spółkę handlową rethan"] = "Rethan_Holdings",     
    ["spółką handlową rethan"] = "Rethan_Holdings",     
    ["spółko handlowa rethan"] = "Rethan_Holdings",     

    -- Wersja 2: Zasoby Rethana (Nazwa w bazie)
    ["zasoby rethana"] = "Rethan_Holdings",
    ["zasobów rethana"] = "Rethan_Holdings",   
    ["zasobom rethana"] = "Rethan_Holdings",     
    ["zasobami rethana"] = "Rethan_Holdings",  
    ["zasobach rethana"] = "Rethan_Holdings", 
	-- Tsonashap Mine
    ["tsonashap mine"] = "Tsonashap_Mine",
    ["kopalnia tsonashap"] = "Tsonashap_Mine",     
    ["kopalni tsonashap"] = "Tsonashap_Mine",     
    ["kopalnię tsonashap"] = "Tsonashap_Mine",     
    ["kopalnią tsonashap"] = "Tsonashap_Mine",     
    ["kopalnio tsonashap"] = "Tsonashap_Mine",     
	-- Taleon's Crag
    ["taleon's crag"] = "Taleon's_Crag",

    -- Wersja 1: Szczelina Taleona 
    ["szczelina taleona"] = "Taleon's_Crag",     
    ["szczeliny taleona"] = "Taleon's_Crag",     
    ["szczelinie taleona"] = "Taleon's_Crag",    
    ["szczelinę taleona"] = "Taleon's_Crag",     
    ["szczeliną taleona"] = "Taleon's_Crag",     
    ["szczelino taleona"] = "Taleon's_Crag",     

    -- Wersja 2: Urwisko Taleona (Nazwa w bazie)
    ["urwisko taleona"] = "Taleon's_Crag",     
    ["urwiska taleona"] = "Taleon's_Crag",       
    ["urwisku taleona"] = "Taleon's_Crag",
    ["urwiskiem taleona"] = "Taleon's_Crag",     
	-- Armature's Upheaval
    ["armature's upheaval"] = "Armature's_Upheaval",
    ["drżąca armatura"] = "Armature's_Upheaval",     
    ["drżącej armatury"] = "Armature's_Upheaval",    
    ["drżącej armaturze"] = "Armature's_Upheaval",   
    ["drżącą armaturę"] = "Armature's_Upheaval",     
    ["drżącą armaturą"] = "Armature's_Upheaval",     
    ["drżąca armaturo"] = "Armature's_Upheaval",     
	-- Jorunn's Stand
    ["jorunn's stand"] = "Jorunn's_Stand",
    ["trybuna jorunna"] = "Jorunn's_Stand",     
    ["trybuny jorunna"] = "Jorunn's_Stand",     
    ["trybunie jorunna"] = "Jorunn's_Stand",    
    ["trybunę jorunna"] = "Jorunn's_Stand",     
    ["trybuną jorunna"] = "Jorunn's_Stand",     
    ["trybuno jorunna"] = "Jorunn's_Stand",     
	-- Etavarn's House
    ["etavarn's house"] = "Opuszczony_dom_(Markart)",
	["opuszczony dom"] = "Opuszczony_dom_(Markart)",
    ["dom etavarna"] = "Opuszczony_dom_(Markart)",   
    ["domu etavarna"] = "Opuszczony_dom_(Markart)",
    ["domowi etavarna"] = "Opuszczony_dom_(Markart)",  
    ["domem etavarna"] = "Opuszczony_dom_(Markart)",   
	-- Riften
    ["riften"] = "Pęknina",
    ["pęknina"] = "Pęknina",     
    ["pękniny"] = "Pęknina",     
    ["pękninie"] = "Pęknina",    
    ["pękninę"] = "Pęknina",     
    ["pękniną"] = "Pęknina",     
    ["pęknino"] = "Pęknina",     
	-- Breakneck Cave
    ["breakneck cave"] = "Jaskinia_Skręcikarku",
    ["jaskinia skręcikarku"] = "Jaskinia_Skręcikarku",     
    ["jaskini skręcikarku"] = "Jaskinia_Skręcikarku",     
    ["jaskinię skręcikarku"] = "Jaskinia_Skręcikarku",     
    ["jaskinią skręcikarku"] = "Jaskinia_Skręcikarku",     
    ["jaskinio skręcikarku"] = "Jaskinia_Skręcikarku",     
	-- March of Sacrifices
    ["march of sacrifices"] = "March_of_Sacrifices",

    -- Wersja 1: Marsz Ofiar 
    ["marsz ofiar"] = "March_of_Sacrifices",   
    ["marszu ofiar"] = "March_of_Sacrifices",
    ["marszowi ofiar"] = "March_of_Sacrifices",  
    ["marszem ofiar"] = "March_of_Sacrifices",   

    -- Wersja 2: Marchia Ofiar (Nazwa w bazie)
    ["marchia ofiar"] = "March_of_Sacrifices",   
    ["marchii ofiar"] = "March_of_Sacrifices",  
    ["marchię ofiar"] = "March_of_Sacrifices",   
    ["marchią ofiar"] = "March_of_Sacrifices",   
    ["marchio ofiar"] = "March_of_Sacrifices",   
	-- Hermit's Hideout
    ["hermit's hideout"] = "Hermit's_Hideout",

    -- Wersja 1: Schronienie pustelnika 
    ["schronienie pustelnika"] = "Hermit's_Hideout",   
    ["schronienia pustelnika"] = "Hermit's_Hideout",     
    ["schronieniu pustelnika"] = "Hermit's_Hideout",     
    ["schronieniem pustelnika"] = "Hermit's_Hideout",    

    -- Wersja 2: Kryjówka Pustelnika (Nazwa w bazie)
    ["kryjówka pustelnika"] = "Hermit's_Hideout",        
    ["kryjówki pustelnika"] = "Hermit's_Hideout",        
    ["kryjówce pustelnika"] = "Hermit's_Hideout", 
    ["kryjówkę pustelnika"] = "Hermit's_Hideout",        
    ["kryjówką pustelnika"] = "Hermit's_Hideout",        
    ["kryjówko pustelnika"] = "Hermit's_Hideout",        
	-- Forgotten Crypts
    ["forgotten crypts"] = "Forgotten_Crypts",
    ["zapomniane krypty"] = "Forgotten_Crypts",   
    ["zapomnianych krypt"] = "Forgotten_Crypts",
    ["zapomnianym kryptom"] = "Forgotten_Crypts",   
    ["zapomnianymi kryptami"] = "Forgotten_Crypts", 
	-- Fort Greenwall
    ["fort greenwall"] = "Zielony_Mur",
	["zielony mur"] = "Zielony_Mur",
    ["fort zielony mur"] = "Zielony_Mur",    
    ["fortu zielonego muru"] = "Zielony_Mur",  
    ["fortowi zielonemu murowi"] = "Zielony_Mur",
    ["fortem zielonym murem"] = "Zielony_Mur", 
    ["forcie zielonym murze"] = "Zielony_Mur", 
	["culotte"] = "Culotte",	-- en=pl
	-- Kynesgrove
	["gajkyne"] = "Gajkyne",
    ["kynesgrove"] = "Gajkyne",
    ["gaj kyne"] = "Gajkyne",   
    ["gaju kyne"] = "Gajkyne",
    ["gajowi kyne"] = "Gajkyne",  
    ["gajem kyne"] = "Gajkyne",   
	["torinaan"] = "Torinaan_(miejsce)",	-- en=pl
	["torinaan (miejsce)"] = "Torinaan_(miejsce)",
	-- Exiled Redoubt
    ["exiled redoubt"] = "Exiled_Redoubt",
    ["reduta wygnańców"] = "Exiled_Redoubt",     
    ["reduty wygnańców"] = "Exiled_Redoubt",     
    ["reducie wygnańców"] = "Exiled_Redoubt",    
    ["redutę wygnańców"] = "Exiled_Redoubt",     
    ["redutą wygnańców"] = "Exiled_Redoubt",     
    ["reduto wygnańców"] = "Exiled_Redoubt",     
	-- Castle Bloodmayne
    ["castle bloodmayne"] = "Castle_Bloodmayne",

    -- Wersja 1: Zamek Bloodmayne 
    ["zamek bloodmayne"] = "Castle_Bloodmayne",   
    ["zamku bloodmayne"] = "Castle_Bloodmayne", 
    ["zamkowi bloodmayne"] = "Castle_Bloodmayne",   
    ["zamkiem bloodmayne"] = "Castle_Bloodmayne",   

    -- Wersja 2: Zamek Krwawej Grzywy (Nazwa w bazie)
    ["zamek krwawej grzywy"] = "Castle_Bloodmayne", 
    ["zamku krwawej grzywy"] = "Castle_Bloodmayne", 
    ["zamkowi krwawej grzywy"] = "Castle_Bloodmayne", 
    ["zamkiem krwawej grzywy"] = "Castle_Bloodmayne", 
	-- Aleswell
    ["aleswell"] = "Aleswell",

    -- Wersja: Fort Aleswell
    ["fort aleswell"] = "Aleswell",    
    ["fortu aleswell"] = "Aleswell",     
    ["fortowi aleswell"] = "Aleswell",   
    ["fortem aleswell"] = "Aleswell",    
    ["forcie aleswell"] = "Aleswell",    

    -- Wersja: Piwny Zdrój (z opisu w bazie)
    ["piwny zdrój"] = "Aleswell",
    ["piwnego zdroju"] = "Aleswell",     
    ["piwnemu zdrojowi"] = "Aleswell",   
    ["piwnym zdrojem"] = "Aleswell",     
    ["piwnym zdroju"] = "Aleswell",      
	["grobowiec rodziny savel"] = "Grobowiec_rodziny_Savel",	-- brak w grze
	-- The Adept's Retreat
    ["the adept's retreat"] = "The_Adept's_Retreat",
    ["kryjówka adepta"] = "The_Adept's_Retreat",     
    ["kryjówki adepta"] = "The_Adept's_Retreat",     
    ["kryjówce adepta"] = "The_Adept's_Retreat",     
    ["kryjówkę adepta"] = "The_Adept's_Retreat",     
    ["kryjówką adepta"] = "The_Adept's_Retreat",     
    ["kryjówko adepta"] = "The_Adept's_Retreat",     
	-- The Corpse Garden
    ["the corpse garden"] = "The_Corpse_Garden",
    ["ogród truposzy"] = "The_Corpse_Garden",   
    ["ogrodu truposzy"] = "The_Corpse_Garden",    
    ["ogrodowi truposzy"] = "The_Corpse_Garden",  
    ["ogrodem truposzy"] = "The_Corpse_Garden",   
    ["ogrodzie truposzy"] = "The_Corpse_Garden",  
	["wieża kamiennej kołyski"] = "Wieża_Kamiennej_Kołyski",	-- brak w grze
	["silatar"] = "Silatar",	-- en=pl
	-- The Chill Hollow
    ["the chill hollow"] = "The_Chill_Hollow",

    -- Wersja 1: Chłodne Zapadlisko 
    ["chłodne zapadlisko"] = "The_Chill_Hollow",   
    ["chłodnego zapadliska"] = "The_Chill_Hollow",   
    ["chłodnemu zapadlisku"] = "The_Chill_Hollow",   
    ["chłodnym zapadliskiem"] = "The_Chill_Hollow",  
    ["chłodnym zapadlisku"] = "The_Chill_Hollow",    

    -- Wersja 2: Chłodna Dziura (Nazwa w bazie)
    ["chłodna dziura"] = "The_Chill_Hollow",         
    ["chłodnej dziury"] = "The_Chill_Hollow",        
    ["chłodnej dziurze"] = "The_Chill_Hollow",
    ["chłodną dziurę"] = "The_Chill_Hollow",
    ["chłodną dziurą"] = "The_Chill_Hollow",
    ["chłodna dziuro"] = "The_Chill_Hollow",         
	-- Bloodmayne Cave
    ["bloodmayne cave"] = "Jaskinia_Krwawej_Grzywy",
    ["jaskinia krwawej grzywy"] = "Jaskinia_Krwawej_Grzywy",   
    ["jaskini krwawej grzywy"] = "Jaskinia_Krwawej_Grzywy",   
    ["jaskinię krwawej grzywy"] = "Jaskinia_Krwawej_Grzywy",   
    ["jaskinią krwawej grzywy"] = "Jaskinia_Krwawej_Grzywy",   
    ["jaskinio krwawej grzywy"] = "Jaskinia_Krwawej_Grzywy",   
	["betony"] = "Betony",	-- en=pl
	-- Flyleaf Catacombs
    ["flyleaf catacombs"] = "Flyleaf_Catacombs",
    ["katakumby latającego liścia"] = "Flyleaf_Catacombs", 
    ["katakumb latającego liścia"] = "Flyleaf_Catacombs",    
    ["katakumbom latającego liścia"] = "Flyleaf_Catacombs",  
    ["katakumbami latającego liścia"] = "Flyleaf_Catacombs", 
    ["katakumbach latającego liścia"] = "Flyleaf_Catacombs", 
	-- Tanglehaven
    ["tanglehaven"] = "Przystań_Gęstwiny",
    ["przystań gęstwiny"] = "Przystań_Gęstwiny",   
    ["przystani gęstwiny"] = "Przystań_Gęstwiny",   
    ["przystanią gęstwiny"] = "Przystań_Gęstwiny",   
	-- The Anvil & Pauldron
	["the anvil  pauldron"] = "The_Anvil__Pauldron",
    ["the anvil & pauldron"] = "The_Anvil__Pauldron",
    ["kowadło i naramiennik"] = "The_Anvil__Pauldron",    
    ["kowadła i naramiennika"] = "The_Anvil__Pauldron",     
    ["kowadłu i naramiennikowi"] = "The_Anvil__Pauldron",   
    ["kowadłem i naramiennikiem"] = "The_Anvil__Pauldron",  
    ["kowadle i naramienniku"] = "The_Anvil__Pauldron",     
	-- Hedoran Estate
    ["hedoran estate"] = "Hedoran_Estate",

    -- Wersja: Rezydencja Hedoran (Twoja)
    ["rezydencja hedoran"] = "Hedoran_Estate",   
    ["rezydencji hedoran"] = "Hedoran_Estate",  
    ["rezydencję hedoran"] = "Hedoran_Estate",   
    ["rezydencją hedoran"] = "Hedoran_Estate",   
    ["rezydencjo hedoran"] = "Hedoran_Estate",   

    -- Wersja: Posiadłość Hedoran (z bazy)
    ["posiadłość hedoran"] = "Hedoran_Estate", 
    ["posiadłości hedoran"] = "Hedoran_Estate", 
    ["posiadłością hedoran"] = "Hedoran_Estate", 
	-- Varen's Wall
    ["varen's wall"] = "Varen's_Wall",
    ["mur varena"] = "Varen's_Wall",   
    ["muru varena"] = "Varen's_Wall",    
    ["murowi varena"] = "Varen's_Wall",  
    ["murem varena"] = "Varen's_Wall",   
    ["murze varena"] = "Varen's_Wall",   
	-- Avani Bladeworks
    ["avani bladeworks"] = "Avani_Bladeworks",

    -- Wersja: Ostrza Rodu Avani (Twoja)
    ["ostrza rodu avani"] = "Avani_Bladeworks",    
    ["ostrzy rodu avani"] = "Avani_Bladeworks",      
    ["ostrzom rodu avani"] = "Avani_Bladeworks",     
    ["ostrzami rodu avani"] = "Avani_Bladeworks",    
    ["ostrzach rodu avani"] = "Avani_Bladeworks",    

    -- Wersja: Kuźnia Avani (z bazy)
    ["kuźnia avani"] = "Avani_Bladeworks",     
    ["kuźni avani"] = "Avani_Bladeworks",     
    ["kuźnię avani"] = "Avani_Bladeworks",     
    ["kuźnią avani"] = "Avani_Bladeworks",     
    ["kuźnio avani"] = "Avani_Bladeworks",     
	["nagastani"] = "Nagastani",	-- en=pl
	["stros m'kai"] = "Stros_M'Kai",	-- en=pl
	-- Glister Vale
    ["glister vale"] = "Glister_Vale",
    ["błyszcząca dolina"] = "Glister_Vale",     
    ["błyszczącej doliny"] = "Glister_Vale",    
    ["błyszczącej dolinie"] = "Glister_Vale",   
    ["błyszczącą dolinę"] = "Glister_Vale",     
    ["błyszczącą doliną"] = "Glister_Vale",     
    ["błyszcząca dolino"] = "Glister_Vale",     
	-- Redoran Blades
    ["redoran blades"] = "Redoran_Blades",

    -- Wersja 1: Redorańskie Ostrza (Twoja)
    ["redorańskie ostrza"] = "Redoran_Blades",    
    ["redorańskich ostrzy"] = "Redoran_Blades",     
    ["redorańskim ostrzom"] = "Redoran_Blades",     
    ["redorańskimi ostrzami"] = "Redoran_Blades",   
    ["redorańskich ostrzach"] = "Redoran_Blades",   

    -- Wersja 2: Ostrza Redoranów (z bazy)
    ["ostrza redoranów"] = "Redoran_Blades",
    ["ostrzy redoranów"] = "Redoran_Blades",        
    ["ostrzom redoranów"] = "Redoran_Blades",
    ["ostrzami redoranów"] = "Redoran_Blades",      
    ["ostrzach redoranów"] = "Redoran_Blades",      
	-- Hordrek's Hunting Grounds
    ["hordrek's hunting grounds"] = "Hordrek's_Hunting_Grounds",

    -- Wersja 1: Tereny łowieckie Hordreka (Twoja)
    ["tereny łowieckie hordreka"] = "Hordrek's_Hunting_Grounds", 
    ["terenów łowieckich hordreka"] = "Hordrek's_Hunting_Grounds", 
    ["terenom łowieckim hordreka"] = "Hordrek's_Hunting_Grounds",  
    ["terenami łowieckimi hordreka"] = "Hordrek's_Hunting_Grounds",

    -- Wersja 2: Pola Łowieckie Hordreka (z bazy)
    ["pola łowieckie hordreka"] = "Hordrek's_Hunting_Grounds",   
    ["pól łowieckich hordreka"] = "Hordrek's_Hunting_Grounds",
    ["polom łowieckim hordreka"] = "Hordrek's_Hunting_Grounds",   
    ["polami łowieckimi hordreka"] = "Hordrek's_Hunting_Grounds", 
	["naril nagaia"] = "Naril_Nagaia",	-- en=pl
	-- Northsalt Village
    ["northsalt village"] = "Northsalt_Village",
    ["wioska północna sól"] = "Northsalt_Village",      
    ["wioski północnej soli"] = "Northsalt_Village",    
    ["wiosce północnej soli"] = "Northsalt_Village",    
    ["wioskę północną sól"] = "Northsalt_Village",      
    ["wioską północną solą"] = "Northsalt_Village",     
    ["wiosko północna soli"] = "Northsalt_Village",     
	["vilverin"] = "Vilverin",	-- en=pl
	-- Lair of Maarselok
    ["lair of maarselok"] = "Lair_of_Maarselok",
    ["leże maarseloka"] = "Lair_of_Maarselok",   
    ["leża maarseloka"] = "Lair_of_Maarselok",     
    ["leżu maarseloka"] = "Lair_of_Maarselok",     
    ["leżem maarseloka"] = "Lair_of_Maarselok",    
	-- Fardir's Folly
    ["fardir's folly"] = "Fardir's_Folly",
    ["szaleństwo fardira"] = "Fardir's_Folly",   
    ["szaleństwa fardira"] = "Fardir's_Folly",     
    ["szaleństwu fardira"] = "Fardir's_Folly",     
    ["szaleństwem fardira"] = "Fardir's_Folly",    
    ["szaleństwie fardira"] = "Fardir's_Folly",    
	-- Ammabani's Pride
    ["ammabani's pride"] = "Ammabani's_Pride_(miejsce)",
	["ammabani's pride (miejsce)"] = "Ammabani's_Pride_(miejsce)",
    -- Wersja 1: Stado Ammabani (Twoja)
    ["stado ammabani"] = "Ammabani's_Pride_(miejsce)", 
    ["stada ammabani"] = "Ammabani's_Pride_(miejsce)",   
    ["stadu ammabani"] = "Ammabani's_Pride_(miejsce)",   
    ["stadem ammabani"] = "Ammabani's_Pride_(miejsce)",  

    -- Wersja 2: Duma Ammabani (z bazy)
    ["duma ammabani"] = "Ammabani's_Pride_(miejsce)",    
    ["dumy ammabani"] = "Ammabani's_Pride_(miejsce)",    
    ["dumie ammabani"] = "Ammabani's_Pride_(miejsce)",   
    ["dumę ammabani"] = "Ammabani's_Pride_(miejsce)",    
    ["dumą ammabani"] = "Ammabani's_Pride_(miejsce)",    
    ["dumo ammabani"] = "Ammabani's_Pride_(miejsce)",    
	["morvunskar"] = "Morvunskar",	-- en=pl
	["anutwyll"] = "Anutwyll",	-- en=pl
	-- Forlorn Watchtower
    ["forlorn watchtower"] = "Forlorn_Watchtower",

    -- Wersja 1: Opuszczona Strażnica (Twoja)
    ["opuszczona strażnica"] = "Forlorn_Watchtower",     
    ["opuszczonej strażnicy"] = "Forlorn_Watchtower",   
    ["opuszczoną strażnicę"] = "Forlorn_Watchtower",     
    ["opuszczoną strażnicą"] = "Forlorn_Watchtower",     
    ["opuszczona strażnico"] = "Forlorn_Watchtower",     
    
    -- Wersja 2: Opuszczona Wieża Strażnicza (z bazy)
    ["opuszczona wieża strażnicza"] = "Forlorn_Watchtower",     
    ["opuszczonej wieży strażniczej"] = "Forlorn_Watchtower",   
    ["opuszczoną wieżę strażniczą"] = "Forlorn_Watchtower",     
    ["opuszczoną wieżą strażniczą"] = "Forlorn_Watchtower",     
    ["opuszczona wieżo strażnicza"] = "Forlorn_Watchtower",     
	-- Crooked Finger Redoubt
    ["crooked finger redoubt"] = "Crooked_Finger_Redoubt",
    ["reduta skrzywionego palca"] = "Crooked_Finger_Redoubt",     
    ["reduty skrzywionego palca"] = "Crooked_Finger_Redoubt",     
    ["redutowi skrzywionego palca"] = "Crooked_Finger_Redoubt",   
    ["redutem skrzywionego palca"] = "Crooked_Finger_Redoubt",    
    ["redutach skrzywionego palca"] = "Crooked_Finger_Redoubt",   
    ["reduto skrzywionego palca"] = "Crooked_Finger_Redoubt",     
	-- Haynote Cave
    ["haynote cave"] = "Jaskinia_w_Haynote",

    -- Wersja 1: Jaskinia Słomianych Wieści 
    ["jaskinia słomianych wieści"] = "Jaskinia_w_Haynote",     
    ["jaskini słomianych wieści"] = "Jaskinia_w_Haynote",     
    ["jaskinię słomianych wieści"] = "Jaskinia_w_Haynote",     
    ["jaskinią słomianych wieści"] = "Jaskinia_w_Haynote",     
    ["jaskinio słomianych wieści"] = "Jaskinia_w_Haynote",     
    
    -- Wersja 2: Jaskinia w Haynote (Nazwa w bazie)
    ["jaskinia w haynote"] = "Jaskinia_w_Haynote",
    ["jaskini w haynote"] = "Jaskinia_w_Haynote",
	-- Agrippa Mento's House
    ["agrippa mento's house"] = "Agrippa_Mento's_House",
    ["dom agrippy mento"] = "Agrippa_Mento's_House",     
    ["domu agrippy mento"] = "Agrippa_Mento's_House",
    ["domowi agrippy mento"] = "Agrippa_Mento's_House",  
    ["domem agrippy mento"] = "Agrippa_Mento's_House",   
    ["domie agrippy mento"] = "Agrippa_Mento's_House",   
	["fort drewnianej ręki"] = "Fort_Drewnianej_Ręki",	-- brak w EsoPL
	-- Atanaz Ruins
    ["atanaz ruins"] = "Atanaz_Ruins",
    ["ruiny atanaz"] = "Atanaz_Ruins", 
    ["ruin atanaz"] = "Atanaz_Ruins",    
    ["ruinom atanaz"] = "Atanaz_Ruins",  
    ["ruinami atanaz"] = "Atanaz_Ruins", 
    ["ruinach atanaz"] = "Atanaz_Ruins", 
	-- Under-Root Bank
    ["under-root bank"] = "Under-Root_Bank",
    ["bank pod korzeniem"] = "Under-Root_Bank",   
    ["banku pod korzeniem"] = "Under-Root_Bank",
    ["bankowi pod korzeniem"] = "Under-Root_Bank",  
    ["bankiem pod korzeniem"] = "Under-Root_Bank",  
	-- The Horker's Tusk Tavern
    ["the horker's tusk tavern"] = "The_Horker's_Tusk_Tavern",
    ["tawerna pod kłem horkera"] = "The_Horker's_Tusk_Tavern",   
    ["tawerny pod kłem horkera"] = "The_Horker's_Tusk_Tavern",   
    ["tawernie pod kłem horkera"] = "The_Horker's_Tusk_Tavern",  
    ["tawernę pod kłem horkera"] = "The_Horker's_Tusk_Tavern",   
    ["tawerną pod kłem horkera"] = "The_Horker's_Tusk_Tavern",   
    ["tawerno pod kłem horkera"] = "The_Horker's_Tusk_Tavern",   
	-- The Withered Tree
    ["the withered tree"] = "The_Withered_Tree",

    -- Wersja 1: Pod Uschłym Konarem 
    ["pod uschłym konarem"] = "The_Withered_Tree",
    ["do uschłego konaru"] = "The_Withered_Tree",
    ["ku uschłemu konarowi"] = "The_Withered_Tree",    
    ["o uschłym konarze"] = "The_Withered_Tree",
    -- Wersja 2: Uschłe Drzewo (Karczma z bazy)
    ["uschłe drzewo"] = "The_Withered_Tree",   
    ["uschłego drzewa"] = "The_Withered_Tree",
    ["uschłemu drzewu"] = "The_Withered_Tree",  
    ["uschłym drzewem"] = "The_Withered_Tree",
    ["uschłym drzewie"] = "The_Withered_Tree",         
	-- Beacon Falls
    ["beacon falls"] = "Beacon_Falls",

    -- Wersja 1: Upadła Latarnia 
    ["upadła latarnia"] = "Beacon_Falls",     
    ["upadłej latarni"] = "Beacon_Falls",   
    ["upadłą latarnię"] = "Beacon_Falls",    
    ["upadłą latarnią"] = "Beacon_Falls",    
    ["upadła latarnio"] = "Beacon_Falls",    

    -- Wersja 2: Upadła Strażnica 
    ["upadła strażnica"] = "Beacon_Falls",     
    ["upadłej strażnicy"] = "Beacon_Falls",   
    ["upadłą strażnicę"] = "Beacon_Falls",     
    ["upadłą strażnicą"] = "Beacon_Falls",     
    ["upadła strażnico"] = "Beacon_Falls",     
	-- The Gray Mire
    ["the gray mire"] = "The_Gray_Mire",
    ["szare bagno"] = "The_Gray_Mire",    
    ["szarego bagna"] = "The_Gray_Mire",    
    ["szaremu bagnu"] = "The_Gray_Mire",    
    ["szarym bagnem"] = "The_Gray_Mire",    
    ["szarym bagnie"] = "The_Gray_Mire",    
	-- Artisan's Hall
    ["artisan's hall"] = "Artisan's_Hall",
    ["hala rzemieślników"] = "Artisan's_Hall",     
    ["hali rzemieślników"] = "Artisan's_Hall",    
    ["halę rzemieślników"] = "Artisan's_Hall",     
    ["halą rzemieślników"] = "Artisan's_Hall",     
	-- Onkobra Kwama Mine
    ["onkobra kwama mine"] = "Onkobra_Kwama_Mine",
    ["kopalnia kwama onkobra"] = "Onkobra_Kwama_Mine",     
    ["kopalni kwama onkobra"] = "Onkobra_Kwama_Mine",     
    ["kopalnię kwama onkobra"] = "Onkobra_Kwama_Mine",     
    ["kopalnią kwama onkobra"] = "Onkobra_Kwama_Mine",     
    ["kopalnio kwama onkobra"] = "Onkobra_Kwama_Mine",     
	-- Etavarn's House
    ["etavarn's house"] = "Opuszczony_dom_(Markart)",
    ["dom etavarna"] = "Opuszczony_dom_(Markart)",   
    ["domu etavarna"] = "Opuszczony_dom_(Markart)",
    ["domowi etavarna"] = "Opuszczony_dom_(Markart)",  
    ["domem etavarna"] = "Opuszczony_dom_(Markart)",   
    ["domie etavarna"] = "Opuszczony_dom_(Markart)",   
	["szczyt postradanej mowy"] = "Szczyt_Postradanej_Mowy",	-- brak w grze
	-- Sanguine's Demesne
    ["sanguine's demesne"] = "Sanguine's_Demesne",

    -- Wersja 1: Majątek Sanguina (Twoja nazwa/z bazy)
    ["majątek sanguina"] = "Sanguine's_Demesne",   
    ["majątku sanguina"] = "Sanguine's_Demesne", 
    ["majątkowi sanguina"] = "Sanguine's_Demesne",   
    ["majątkiem sanguina"] = "Sanguine's_Demesne",   

    -- Wersja 2: Majątek Sanguine'a (z bazy/alternatywna)
    ["majątek sanguine'a"] = "Sanguine's_Demesne", 
    ["majątku sanguine'a"] = "Sanguine's_Demesne", 
    ["majątkowi sanguine'a"] = "Sanguine's_Demesne", 
    ["majątkiem sanguine'a"] = "Sanguine's_Demesne", 
	-- The Lion's Den
    ["the lion's den"] = "The_Lion's_Den",

    -- Wersja 1: Legowisko Lwa (Twoje tłumaczenie / z bazy)
    ["legowisko lwa"] = "The_Lion's_Den",   
    ["legowiska lwa"] = "The_Lion's_Den",     
    ["legowisku lwa"] = "The_Lion's_Den",     
    ["legowiskiem lwa"] = "The_Lion's_Den",   

    -- Wersja 2: Stalowogłowa Szczelina (alternatywna nazwa z bazy)
    ["stalowogłowa szczelina"] = "The_Lion's_Den",     
    ["stalowogłowej szczeliny"] = "The_Lion's_Den",    
    ["stalowogłowej szczelinie"] = "The_Lion's_Den",   
    ["stalowogłową szczelinę"] = "The_Lion's_Den",     
    ["stalowogłową szczeliną"] = "The_Lion's_Den",     
    ["stalowogłowa szczelino"] = "The_Lion's_Den",     
	-- Pilgrim's Rest Inn
    ["pilgrim's rest inn"] = "Pilgrim's_Rest_Inn",
    ["karczma odpoczywającego pielgrzyma"] = "Pilgrim's_Rest_Inn", 
    ["karczmy odpoczywającego pielgrzyma"] = "Pilgrim's_Rest_Inn", 
    ["karczmie odpoczywającemu pielgrzymowi"] = "Pilgrim's_Rest_Inn",-- Celownik
    ["karczmę odpoczywającego pielgrzyma"] = "Pilgrim's_Rest_Inn", 
    ["karczmą odpoczywającym pielgrzymem"] = "Pilgrim's_Rest_Inn", 
    ["karczmie odpoczywającym pielgrzymie"] = "Pilgrim's_Rest_Inn",
    ["karczmo odpoczywający pielgrzymie"] = "Pilgrim's_Rest_Inn", 
	-- Whispering Axe Tavern
    ["whispering axe tavern"] = "Whispering_Axe_Tavern",
    ["tawerna pod szepczącym toporem"] = "Whispering_Axe_Tavern",   
    ["tawerny pod szepczącym toporem"] = "Whispering_Axe_Tavern",   
    ["tawernie pod szepczącym toporem"] = "Whispering_Axe_Tavern",  
    ["tawernę pod szepczącym toporem"] = "Whispering_Axe_Tavern",   
    ["tawerną pod szepczącym toporem"] = "Whispering_Axe_Tavern",   
    ["tawerno pod szepczącym toporem"] = "Whispering_Axe_Tavern",   
	-- Kuna's Delve
    ["kuna's delve"] = "Kuna's_Delve",

    -- Wersja 1: Grota Kuny 
    ["grota kuny"] = "Kuna's_Delve",     
    ["groty kuny"] = "Kuna's_Delve",     
    ["grocie kuny"] = "Kuna's_Delve",    
    ["grotę kuny"] = "Kuna's_Delve",     
    ["grotą kuny"] = "Kuna's_Delve",     
    ["groto kuny"] = "Kuna's_Delve",     

    -- Wersja 2: Wykop Kuny 
    ["wykop kuny"] = "Kuna's_Delve",   
    ["wykopu kuny"] = "Kuna's_Delve",    
    ["wykopowi kuny"] = "Kuna's_Delve",  
    ["wykopem kuny"] = "Kuna's_Delve",   
    ["wykopie kuny"] = "Kuna's_Delve",   
	["arx corinium"] = "Arx_Corinium",	-- en=pl
	-- College of Aldmeri Propriety
    ["college of aldmeri propriety"] = "College_of_Aldmeri_Propriety",
    ["kolegium aldmerskiej poprawności"] = "College_of_Aldmeri_Propriety",   
    ["kolegium aldmerskiej poprawności"] = "College_of_Aldmeri_Propriety",
    ["kolegium aldmerskiej poprawności"] = "College_of_Aldmeri_Propriety",     
    ["kolegium aldmerskiej poprawności"] = "College_of_Aldmeri_Propriety",     
    ["kolegium aldmerskiej poprawności"] = "College_of_Aldmeri_Propriety",
	-- Tempest Island
    ["tempest island"] = "Tempest_Island",

    -- Wersja 1: Wyspa Nawałnicy (Twoje tłumaczenie / z bazy)
    ["wyspa nawałnicy"] = "Tempest_Island",     
    ["wyspy nawałnicy"] = "Tempest_Island",     
    ["wyspie nawałnicy"] = "Tempest_Island",    
    ["wyspę nawałnicy"] = "Tempest_Island",     
    ["wyspą nawałnicy"] = "Tempest_Island",     
    ["wyspo nawałnicy"] = "Tempest_Island",     

    -- Wersja 2: Wyspa Sztormów (alternatywna nazwa z bazy)
    ["wyspa sztormów"] = "Tempest_Island",      
    ["wyspy sztormów"] = "Tempest_Island",      
    ["wyspie sztormów"] = "Tempest_Island",     
    ["wyspę sztormów"] = "Tempest_Island",      
    ["wyspą sztormów"] = "Tempest_Island",      
    ["wyspo sztormów"] = "Tempest_Island",      
	-- Meadblood Home
    ["meadblood home"] = "Meadblood_Home",
    ["dom miodowej krwi"] = "Meadblood_Home",   
    ["domu miodowej krwi"] = "Meadblood_Home",
    ["domowi miodowej krwi"] = "Meadblood_Home",  
    ["domem miodowej krwi"] = "Meadblood_Home",   
	-- Nikel Outpost
	["fort nikel"] = "Fort_Nikel",
    ["nikel outpost"] = "Fort_Nikel",
    ["posterunek nikel"] = "Fort_Nikel", 
    ["posterunku nikel"] = "Fort_Nikel",
    ["posterunkowi nikel"] = "Fort_Nikel",  
    ["posterunkiem nikel"] = "Fort_Nikel",  
	-- Dragon Bridge
    ["dragon bridge"] = "Smoczymost",
    ["smoczymost"] = "Smoczymost",    
    ["smoczymostu"] = "Smoczymost", 
    ["smoczymostowi"] = "Smoczymost",   
    ["smoczymostem"] = "Smoczymost",    
	["carmala"] = "Carmala",	-- en=pl
	-- High Rock
    ["high rock"] = "Wysoka_Skała",
    ["wysoka skała"] = "Wysoka_Skała",     
    ["wysokiej skały"] = "Wysoka_Skała",    
    ["wysokiej skale"] = "Wysoka_Skała",    
    ["wysoką skałę"] = "Wysoka_Skała",     
    ["wysoką skałą"] = "Wysoka_Skała",     
    ["wysoka skało"] = "Wysoka_Skała",     
	-- Sulfur Pools
    ["sulfur pools"] = "Sulfur_Pools",
    ["siarkowe jeziora"] = "Sulfur_Pools",   
    ["siarkowych jezior"] = "Sulfur_Pools",    
    ["siarkowym jeziorom"] = "Sulfur_Pools",   
    ["siarkowymi jeziorami"] = "Sulfur_Pools", 
    ["siarkowych jeziorach"] = "Sulfur_Pools", 
	-- Shadowgreen
    ["shadowgreen"] = "Szmaragdowa_Pieczara",
    ["szmaragdowa pieczara"] = "Szmaragdowa_Pieczara",     
    ["szmaragdowej pieczary"] = "Szmaragdowa_Pieczara",    
    ["szmaragdowej pieczarze"] = "Szmaragdowa_Pieczara",   
    ["szmaragdową pieczarę"] = "Szmaragdowa_Pieczara",     
    ["szmaragdową pieczarą"] = "Szmaragdowa_Pieczara",     
    ["szmaragdowa pieczaro"] = "Szmaragdowa_Pieczara",     
	-- Heart's Grief
    ["heart's grief"] = "Heart's_Grief",
    ["żal serca"] = "Heart's_Grief",   
    ["żalu serca"] = "Heart's_Grief",    
    ["żalowi serca"] = "Heart's_Grief",  
    ["żalem serca"] = "Heart's_Grief",   
    ["żalu serca"] = "Heart's_Grief",    
	-- Moffka's Lament
    ["moffka's lament"] = "Moffka's_Lament",
    ["lament moffki"] = "Moffka's_Lament",  
    ["lamentu moffki"] = "Moffka's_Lament", 
    ["lamentowi moffki"] = "Moffka's_Lament", 
    ["lamentem moffki"] = "Moffka's_Lament",  
	-- Red Ruby Cave
    ["red ruby cave"] = "Jaskinia_Czerwonych_Rubinów",
    ["jaskinia czerwonych rubinów"] = "Jaskinia_Czerwonych_Rubinów",     
    ["jaskini czerwonych rubinów"] = "Jaskinia_Czerwonych_Rubinów",     
    ["jaskinię czerwonych rubinów"] = "Jaskinia_Czerwonych_Rubinów",     
    ["jaskinią czerwonych rubinów"] = "Jaskinia_Czerwonych_Rubinów",     
    ["jaskinio czerwonych rubinów"] = "Jaskinia_Czerwonych_Rubinów",     
	-- Werewolf Ritual Site
    ["werewolf ritual site"] = "Werewolf_Ritual_Site_(Reaper's_March)",

    -- Wersja 1: Rytualne miejsce wilkołaków 
    ["rytualne miejsce wilkołaków"] = "Werewolf_Ritual_Site_(Reaper's_March)",
    ["rytualnego miejsca wilkołaków"] = "Werewolf_Ritual_Site_(Reaper's_March)", 
    ["rytualnemu miejscu wilkołaków"] = "Werewolf_Ritual_Site_(Reaper's_March)", 
    ["rytualnym miejscem wilkołaków"] = "Werewolf_Ritual_Site_(Reaper's_March)", 
    ["rytualnym miejscu wilkołaków"] = "Werewolf_Ritual_Site_(Reaper's_March)", 

    -- Wersja 2: Tereny Rytualne Wilkołaków 
    ["tereny rytualne wilkołaków"] = "Werewolf_Ritual_Site_(Reaper's_March)", 
    ["terenów rytualnych wilkołaków"] = "Werewolf_Ritual_Site_(Reaper's_March)",
    ["terenom rytualnym wilkołaków"] = "Werewolf_Ritual_Site_(Reaper's_March)",  
    ["terenami rytualnymi wilkołaków"] = "Werewolf_Ritual_Site_(Reaper's_March)",
	
	-- Dodatkowe aliasy dla Rifta (aby nie stracić linkowania)
    ["werewolf ritual site the rift"] = "Werewolf_Ritual_Site_(The_Rift)",
    ["teren rytualny the rift"] = "Werewolf_Ritual_Site_(The_Rift)",
	["werewolf ritual site (the rift)"] = "Werewolf_Ritual_Site_(The_Rift)",
	-- Firsthold
    ["firsthold"] = "Pierwsza_Twierdza",
    ["pierwsza twierdza"] = "Pierwsza_Twierdza",     
    ["pierwszej twierdzy"] = "Pierwsza_Twierdza",   
    ["pierwszą twierdzę"] = "Pierwsza_Twierdza",     
    ["pierwszą twierdzą"] = "Pierwsza_Twierdza",     
    ["pierwsza twierdzo"] = "Pierwsza_Twierdza",     
	-- Northern Morrowind Gate
    ["northern morrowind gate"] = "Northern_Morrowind_Gate",
    ["północna brama morrowind"] = "Northern_Morrowind_Gate",   
    ["północnej bramy morrowind"] = "Northern_Morrowind_Gate",  
    ["północnej bramie morrowind"] = "Northern_Morrowind_Gate", 
    ["północną bramę morrowind"] = "Northern_Morrowind_Gate",   
    ["północną bramą morrowind"] = "Northern_Morrowind_Gate",   
    ["północna bramo morrowind"] = "Northern_Morrowind_Gate",   
	["kemen"] = "Kemen",	--en=pl
	-- Lower Yorgrim
    ["lower yorgrim"] = "Lower_Yorgrim",
    ["dolne yorgrim"] = "Lower_Yorgrim",   
    ["dolnego yorgrim"] = "Lower_Yorgrim",   
    ["dolnemu yorgrim"] = "Lower_Yorgrim",   
    ["dolnym yorgrimem"] = "Lower_Yorgrim",  
    ["dolnym yorgrim"] = "Lower_Yorgrim",    
	["summerset"] = "Wyspy_Summerset",
	["wyspy summerset"] = "Wyspy_Summerset",
	-- Captain Viveka's House
    ["captain viveka's house"] = "Captain_Viveka's_House",
    ["dom kapitan viveki"] = "Captain_Viveka's_House",   
    ["domu kapitan viveki"] = "Captain_Viveka's_House",
    ["domowi kapitan viveki"] = "Captain_Viveka's_House",  
    ["domem kapitan viveki"] = "Captain_Viveka's_House",   
    ["domie kapitan viveki"] = "Captain_Viveka's_House",   
	-- Starwalk Cavern
    ["starwalk cavern"] = "Starwalk_Cavern",
    ["jaskinia gwiezdnego spaceru"] = "Starwalk_Cavern",     
    ["jaskini gwiezdnego spaceru"] = "Starwalk_Cavern",     
    ["jaskinię gwiezdnego spaceru"] = "Starwalk_Cavern",     
    ["jaskinią gwiezdnego spaceru"] = "Starwalk_Cavern",     
    ["jaskinio gwiezdnego spaceru"] = "Starwalk_Cavern",     
	["magmaflow overlook"] = "Magmaflow_Overlook",
	-- Blue Road Keep
    ["blue road keep"] = "Blue_Road_Keep",

    -- Wersja 1: Warownia Blue Road 
    ["warownia blue road"] = "Blue_Road_Keep",   
    ["warowni blue road"] = "Blue_Road_Keep",   
    ["warownię blue road"] = "Blue_Road_Keep",   
    ["warownią blue road"] = "Blue_Road_Keep",   
    ["warownio blue road"] = "Blue_Road_Keep",   

    -- Wersja 2: Twierdza Błękitnej Drogi (Nazwa z bazy)
    ["twierdza błękitnej drogi"] = "Blue_Road_Keep",   
    ["twierdzy błękitnej drogi"] = "Blue_Road_Keep", 
    ["twierdzę błękitnej drogi"] = "Blue_Road_Keep",  
    ["twierdzą błękitnej drogi"] = "Blue_Road_Keep",  
    ["twierdzo błękitnej drogi"] = "Blue_Road_Keep",  
	-- Cragwallow
    ["cragwallow"] = "Zdradliwy_Stok",

    -- Wersja: Zdradliwy Stok
    ["zdradliwy stok"] = "Zdradliwy_Stok",     
    ["zdradliwego stoku"] = "Zdradliwy_Stok",  
    ["zdradliwemu stokowi"] = "Zdradliwy_Stok", 
    ["zdradliwy stok"] = "Zdradliwy_Stok",     
    ["zdradliwym stokiem"] = "Zdradliwy_Stok",  
    ["zdradliwym stoku"] = "Zdradliwy_Stok",   
	-- Hightide Hollow
    ["hightide hollow"] = "Hightide_Hollow",
    ["jaskinia wysokiej fali"] = "Hightide_Hollow",     
    ["jaskini wysokiej fali"] = "Hightide_Hollow",     
    ["jaskinię wysokiej fali"] = "Hightide_Hollow",     
    ["jaskinią wysokiej fali"] = "Hightide_Hollow",     
    ["jaskinio wysokiej fali"] = "Hightide_Hollow",     
	-- Sheogorath's Tongue
    ["sheogorath's tongue"] = "Sheogorath's_Tongue",
    ["jęzor sheogoratha"] = "Sheogorath's_Tongue",   
    ["jęzora sheogoratha"] = "Sheogorath's_Tongue",    
    ["jęzorowi sheogoratha"] = "Sheogorath's_Tongue",  
    ["jęzorem sheogoratha"] = "Sheogorath's_Tongue",   
    ["jęzorze sheogoratha"] = "Sheogorath's_Tongue",   
	["komnata umarłych w wichrowym tronie"] = "Komnata_Umarłych_w_Wichrowym_Tronie",	-- brak w grze
	-- Cracked Wood Cave
    ["cracked wood cave"] = "Jaskinia_Pękniętej_Kłody",

    -- Wersja 1: Jar Złamanej Gałęzi 
    ["jar złamanej gałęzi"] = "Jaskinia_Pękniętej_Kłody", 
    ["jaru złamanej gałęzi"] = "Jaskinia_Pękniętej_Kłody", 
    ["jarowi złamanej gałęzi"] = "Jaskinia_Pękniętej_Kłody", 
    ["jarem złamanej gałęzi"] = "Jaskinia_Pękniętej_Kłody",  

    -- Wersja 2: Jaskinia Pękniętej Kłody 
    ["jaskinia pękniętej kłody"] = "Jaskinia_Pękniętej_Kłody",  
    ["jaskini pękniętej kłody"] = "Jaskinia_Pękniętej_Kłody",  
    ["jaskinię pękniętej kłody"] = "Jaskinia_Pękniętej_Kłody",  
    ["jaskinią pękniętej kłody"] = "Jaskinia_Pękniętej_Kłody",  
    ["jaskinio pękniętej kłody"] = "Jaskinia_Pękniętej_Kłody",  
	-- Bleakrock Isle
    ["bleakrock isle"] = "Bleakrock_Isle",

    -- Wersja 1: Wyspa Ponurej Skały (Twoje tłumaczenie / z bazy)
    ["wyspa ponurej skały"] = "Bleakrock_Isle",     
    ["wyspy ponurej skały"] = "Bleakrock_Isle",     
    ["wyspie ponurej skale"] = "Bleakrock_Isle",    
    ["wyspę ponurą skałę"] = "Bleakrock_Isle",      
    ["wyspą ponurą skałą"] = "Bleakrock_Isle",      
    ["wyspo ponura skało"] = "Bleakrock_Isle",      

    -- Wersja 2: Ponura Skała (Skrócona nazwa z bazy)
    ["ponura skała"] = "Bleakrock_Isle",     
    ["ponurej skały"] = "Bleakrock_Isle",    
    ["ponurej skale"] = "Bleakrock_Isle",    
    ["ponurą skałę"] = "Bleakrock_Isle",     
    ["ponurą skałą"] = "Bleakrock_Isle",     
    ["ponura skało"] = "Bleakrock_Isle",     
	-- Autumnshade Clearing
    ["autumnshade clearing"] = "Polana_Jesiennego_Cienia",
    ["polana jesiennego cienia"] = "Polana_Jesiennego_Cienia",     
    ["polany jesiennego cienia"] = "Polana_Jesiennego_Cienia",    
    ["polanie jesiennego cienia"] = "Polana_Jesiennego_Cienia",   
    ["polanę jesiennego cienia"] = "Polana_Jesiennego_Cienia",    
    ["polaną jesiennego cienia"] = "Polana_Jesiennego_Cienia",    
    ["polano jesiennego cienia"] = "Polana_Jesiennego_Cienia",    
	["nimalten"] = "Nimalten",	-- en=pl
	-- Wraithhome
    ["wraithhome"] = "Wraithhome",
    ["dom upiorów"] = "Wraithhome",   
    ["domu upiorów"] = "Wraithhome",
    ["domowi upiorów"] = "Wraithhome",  
    ["domem upiorów"] = "Wraithhome",   
	-- Crimson Kada's Crafting Cavern
    ["crimson kada's crafting cavern"] = "Crimson_Kada's_Crafting_Cavern",
    ["jaskinia rzemiosła karmazynowej kady"] = "Crimson_Kada's_Crafting_Cavern",     
    ["jaskini rzemiosła karmazynowej kady"] = "Crimson_Kada's_Crafting_Cavern",     
    ["jaskinię rzemiosła karmazynowej kady"] = "Crimson_Kada's_Crafting_Cavern",     
    ["jaskinią rzemiosła karmazynowej kady"] = "Crimson_Kada's_Crafting_Cavern",     
    ["jaskinio rzemiosła karmazynowej kady"] = "Crimson_Kada's_Crafting_Cavern",     
	["kaplica molag bala"] = "Kaplica_Molag_Bala",	-- brak w grze
	["czarne buty (miejsce)"] = "Czarne_Buty_(miejsce)",	-- brak w grze
	["czarne buty"] = "Czarne_Buty_(miejsce)",
	-- Harlun's Outpost
    ["harlun's outpost"] = "Harlun's_Outpost",
    ["posterunek harluna"] = "Harlun's_Outpost",   
    ["posterunku harluna"] = "Harlun's_Outpost",
    ["posterunkowi harluna"] = "Harlun's_Outpost",  
    ["posterunkiem harluna"] = "Harlun's_Outpost",  
	["hakoshae"] = "Hakoshae",	-- en=pl
	["ivarstead"] = "Ivarstead",	-- en=pl a powinno byc tłumaczenie
	-- Giant Camp
    ["giant camp"] = "Giant_Camp_(Rift)",

    -- Wersja 1: Obóz gigantów 
    ["obóz gigantów"] = "Giant_Camp_(Rift)",     
    ["obozu gigantów"] = "Giant_Camp_(Rift)",      
    ["obozowi gigantów"] = "Giant_Camp_(Rift)",    
    ["obozem gigantów"] = "Giant_Camp_(Rift)",     
    ["obozie gigantów"] = "Giant_Camp_(Rift)",     

    -- Wersja 2: Obozowisko gigantów 
    ["obozowisko gigantów"] = "Giant_Camp_(Rift)",
    ["obozowiska gigantów"] = "Giant_Camp_(Rift)", 
    ["obozowisku gigantów"] = "Giant_Camp_(Rift)", 
    ["obozowiskiem gigantów"] = "Giant_Camp_(Rift)",
	-- Companions Point
    ["companions point"] = "Companions_Point",
    ["monument towarzyszy"] = "Companions_Point",   
    ["monumentu towarzyszy"] = "Companions_Point",    
    ["monumentowi towarzyszy"] = "Companions_Point",  
    ["monumentem towarzyszy"] = "Companions_Point",   
    ["monumencie towarzyszy"] = "Companions_Point",   
	["alezer kotu"] = "Alezer_Kotu",	-- en=pl
	-- Shadowed Path Tower
    ["shadowed path tower"] = "Shadowed_Path_Tower",
    ["wieża cienistej ścieżki"] = "Shadowed_Path_Tower",     
    ["wieży cienistej ścieżki"] = "Shadowed_Path_Tower",   
    ["wieżę cienistej ścieżki"] = "Shadowed_Path_Tower",    
    ["wieżą cienistej ścieżki"] = "Shadowed_Path_Tower",    
    ["wieżo cienistej ścieżki"] = "Shadowed_Path_Tower",    
	-- Shipwright's Regret
    ["shipwright's regret"] = "Shipwright's_Regret",
    ["żal szkutnika"] = "Shipwright's_Regret",   
    ["żalu szkutnika"] = "Shipwright's_Regret",
    ["żalowi szkutnika"] = "Shipwright's_Regret",  
    ["żalem szkutnika"] = "Shipwright's_Regret",   
	-- Tal'Deic Fortress
    ["tal'deic fortress"] = "Tal'Deic_Fortress",
    ["forteca tal'deic"] = "Tal'Deic_Fortress",     
    ["fortecy tal'deic"] = "Tal'Deic_Fortress",    
    ["fortecę tal'deic"] = "Tal'Deic_Fortress",     
    ["fortecą tal'deic"] = "Tal'Deic_Fortress",     
    ["forteco tal'deic"] = "Tal'Deic_Fortress",     
	-- Chalman Keep
    ["chalman keep"] = "Fort_Chalman",
	["fort chalman"] = "Fort_Chalman",
    ["warownia chalman"] = "Fort_Chalman",   
    ["warowni chalman"] = "Fort_Chalman",   
    ["warownię chalman"] = "Fort_Chalman",   
    ["warownią chalman"] = "Fort_Chalman",   
    ["warownio chalman"] = "Fort_Chalman",   
	-- Davenas Farm
    ["davenas farm"] = "Davenas_Farm",
    ["farma davenas"] = "Davenas_Farm",     
    ["farmy davenas"] = "Davenas_Farm",     
    ["farmie davenas"] = "Davenas_Farm",    
    ["farmę davenas"] = "Davenas_Farm",     
    ["farmą davenas"] = "Davenas_Farm",     
    ["farmo davenas"] = "Davenas_Farm",     
	["ponure urwisko"] = "Ponure_Urwisko",	-- brak w grze
	-- Reman's Bluff
    ["reman's bluff"] = "Reman's_Bluff",
    ["urwisko remana"] = "Reman's_Bluff",   
    ["urwiska remana"] = "Reman's_Bluff",     
    ["urwisku remana"] = "Reman's_Bluff",     
    ["urwiskiem remana"] = "Reman's_Bluff",   
	-- Mehrunes' Spite
    ["mehrunes' spite"] = "Mehrunes'_Spite",
    ["gniew mehrunesa"] = "Mehrunes'_Spite",   
    ["gniewu mehrunesa"] = "Mehrunes'_Spite",    
    ["gniewowi mehrunesa"] = "Mehrunes'_Spite",  
    ["gniewem mehrunesa"] = "Mehrunes'_Spite",   
    ["gniewie mehrunesa"] = "Mehrunes'_Spite",   
	-- Lower Bthanual
    ["lower bthanual"] = "Lower_Bthanual",
    ["dolne bthanual"] = "Lower_Bthanual",   
    ["dolnego bthanual"] = "Lower_Bthanual",   
    ["dolnemu bthanual"] = "Lower_Bthanual",   
    ["dolnym bthanual"] = "Lower_Bthanual",
	-- North Beacon
    ["north beacon"] = "North_Beacon",

    -- Wersja 1: Północna Latarnia 
    ["północna latarnia"] = "North_Beacon",     
    ["północnej latarni"] = "North_Beacon",   
    ["północną latarnię"] = "North_Beacon",    
    ["północną latarnią"] = "North_Beacon",    
    ["północna latarnio"] = "North_Beacon",    

    -- Wersja 2: Północna Strażnica 
    ["północna strażnica"] = "North_Beacon",   
    ["północnej strażnicy"] = "North_Beacon", 
    ["północną strażnicę"] = "North_Beacon",   
    ["północną strażnicą"] = "North_Beacon",   
    ["północna strażnico"] = "North_Beacon",   
	["kopalnia lewej ręki"] = "Kopalnia_Lewej_Ręki",	-- brak w grze
	["pa'alat"] = "Pa'alat",	-- en=pl
	-- Ruined Guardhouse
    ["ruined guardhouse"] = "Ruined_Guardhouse",

    -- Wersja 1: Zniszczona wartownia 
    ["zniszczona wartownia"] = "Ruined_Guardhouse",     
    ["zniszczonej wartowni"] = "Ruined_Guardhouse",   
    ["zniszczoną wartownię"] = "Ruined_Guardhouse",  
    ["zniszczona wartownio"] = "Ruined_Guardhouse",    

    -- Wersja 2: Zrujnowana Wartownia 
    ["zrujnowana wartownia"] = "Ruined_Guardhouse",     
    ["zrujnowanej wartowni"] = "Ruined_Guardhouse",   
    ["zrujnowaną wartownię"] = "Ruined_Guardhouse",  
    ["zrujnowana wartownio"] = "Ruined_Guardhouse",    
	-- Artisan's Oasis
    ["artisan's oasis"] = "Artisan's_Oasis",

    -- Wersja 1: Oaza Rzemieślnika (Twoja nazwa, l. poj.)
    ["oaza rzemieślnika"] = "Artisan's_Oasis",     
    ["oazy rzemieślnika"] = "Artisan's_Oasis",     
    ["oazie rzemieślnikowi"] = "Artisan's_Oasis",  
    ["oazę rzemieślnika"] = "Artisan's_Oasis",     
    ["oazą rzemieślnikiem"] = "Artisan's_Oasis",   
    ["oazie rzemieślniku"] = "Artisan's_Oasis",    

    -- Wersja 2: Oaza Rzemieślników (Zgodnie z opisem w bazie, l. mn.)
    ["oaza rzemieślników"] = "Artisan's_Oasis",     
    ["oazy rzemieślników"] = "Artisan's_Oasis",     
    ["oazie rzemieślnikom"] = "Artisan's_Oasis",    
    ["oazę rzemieślników"] = "Artisan's_Oasis",     
    ["oazą rzemieślnikami"] = "Artisan's_Oasis",    
    ["oazie rzemieślnikach"] = "Artisan's_Oasis",   
    ["oazo rzemieślnicy"] = "Artisan's_Oasis",      
	["ceyatatar"] = "Ceyatatar",	-- en=pl
	-- The Frigid Grotto
    ["the frigid grotto"] = "The_Frigid_Grotto",
    ["oziębła grota"] = "The_Frigid_Grotto",      
    ["oziębłej groty"] = "The_Frigid_Grotto",     
    ["oziębłej grocie"] = "The_Frigid_Grotto",    
    ["oziębłą grotę"] = "The_Frigid_Grotto",    
    ["oziębła groto"] = "The_Frigid_Grotto",      
	-- Moon Hunter Keep
    ["moon hunter keep"] = "Moon_Hunter_Keep",

    -- Wersja 1: Twierdza Księżycowego Łowcy 
    ["twierdza księżycowego łowcy"] = "Moon_Hunter_Keep",   
    ["twierdzy księżycowego łowcy"] = "Moon_Hunter_Keep", 
    ["twierdzę księżycowego łowcy"] = "Moon_Hunter_Keep",   
    ["twierdzą księżycowego łowcy"] = "Moon_Hunter_Keep",   
    ["twierdzo księżycowy łowco"] = "Moon_Hunter_Keep",     

    -- Wersja 2: Twierdza Nocnych Łowców 
    ["twierdza nocnych łowców"] = "Moon_Hunter_Keep",       
    ["twierdzy nocnych łowców"] = "Moon_Hunter_Keep",      
    ["twierdzę nocnych łowców"] = "Moon_Hunter_Keep",       
    ["twierdzą nocnych łowców"] = "Moon_Hunter_Keep",       
    ["twierdzo nocnych łowców"] = "Moon_Hunter_Keep",       
	-- Lunar Fang Docks
    ["lunar fang docks"] = "Lunar_Fang_Docks",
    ["doki księżycowego kła"] = "Lunar_Fang_Docks",    
    ["doków księżycowego kła"] = "Lunar_Fang_Docks",     
    ["dokom księżycowego kła"] = "Lunar_Fang_Docks",     
    ["dokami księżycowego kła"] = "Lunar_Fang_Docks",    
    ["dokach księżycowego kła"] = "Lunar_Fang_Docks",    
	-- Xal Haj-Ei Shrine
    ["xal haj-ei shrine"] = "Xal_Haj-Ei_Shrine",
    ["kapliczka xal haj-ei"] = "Xal_Haj-Ei_Shrine",     
    ["kapliczki xal haj-ei"] = "Xal_Haj-Ei_Shrine",     
    ["kapliczce xal haj-ei"] = "Xal_Haj-Ei_Shrine",     
    ["kapliczkę xal haj-ei"] = "Xal_Haj-Ei_Shrine",     
    ["kapliczką xal haj-ei"] = "Xal_Haj-Ei_Shrine",     
    ["kapliczko xal haj-ei"] = "Xal_Haj-Ei_Shrine",     
	["coldcorn"] = "Coldcorn",	-- en=pl
	["sejanus"] = "Sejanus",	-- en=pl
	-- Stillwaters Retreat
    ["stillwaters retreat"] = "Stillwaters_Retreat",
    ["kryjówka spokojnych wód"] = "Stillwaters_Retreat",     
    ["kryjówki spokojnych wód"] = "Stillwaters_Retreat",     
    ["kryjówce spokojnych wód"] = "Stillwaters_Retreat",     
    ["kryjówkę spokojnych wód"] = "Stillwaters_Retreat",     
    ["kryjówką spokojnych wód"] = "Stillwaters_Retreat",     
    ["kryjówko spokojnych wód"] = "Stillwaters_Retreat",     
	-- Fort Dragonclaw
    ["fort dragonclaw"] = "Fort_Dragonclaw",
    ["fort smoczego pazura"] = "Fort_Dragonclaw",   
    ["fortu smoczego pazura"] = "Fort_Dragonclaw",    
    ["fortowi smoczego pazura"] = "Fort_Dragonclaw",  
    ["fortem smoczego pazura"] = "Fort_Dragonclaw",   
    ["forcie smoczego pazura"] = "Fort_Dragonclaw",   
	-- Empire Tower (Klucz: Fort Cesarski)
    ["empire tower"] = "Fort_Cesarski",
	["fort cesarski"] = "Fort_Cesarski",
    ["cesarska wieża"] = "Fort_Cesarski",     
    ["cesarskiej wieży"] = "Fort_Cesarski",  
    ["cesarską wieżę"] = "Fort_Cesarski",   
    ["cesarska wieżo"] = "Fort_Cesarski",     
	-- Exorcised Coven Cottage
    ["exorcised coven cottage"] = "Exorcised_Coven_Cottage",

    -- Wersja 1: Egzorcyzmowana chatka wiedźm 
    ["egzorcyzmowana chatka wiedźm"] = "Exorcised_Coven_Cottage",     
    ["egzorcyzmowanej chatki wiedźm"] = "Exorcised_Coven_Cottage",   
    ["egzorcyzmowaną chatkę wiedźm"] = "Exorcised_Coven_Cottage",     
    ["egzorcyzmowaną chatką wiedźm"] = "Exorcised_Coven_Cottage",     
    ["egzorcyzmowana chatko wiedźm"] = "Exorcised_Coven_Cottage",     

    -- Wersja 2: Egzorcyzmowana chatka sabatu 
    ["egzorcyzmowana chatka sabatu"] = "Exorcised_Coven_Cottage",     
    ["egzorcyzmowanej chatki sabatu"] = "Exorcised_Coven_Cottage",   
    ["egzorcyzmowaną chatkę sabatu"] = "Exorcised_Coven_Cottage",     
    ["egzorcyzmowaną chatką sabatu"] = "Exorcised_Coven_Cottage",     
    ["egzorcyzmowana chatko sabatu"] = "Exorcised_Coven_Cottage",     
	["seyda neen"] = "Seyda_Neen",	-- en=pl
	["vulkwasten"] = "Vulkwasten", --en=pl
	-- Ebonheart Unified Metalworks
    ["ebonheart unified metalworks"] = "Ebonheart_Unified_Metalworks",
    ["zjednoczona kuźnia ebonheart"] = "Ebonheart_Unified_Metalworks",     
    ["zjednoczonej kuźni ebonheart"] = "Ebonheart_Unified_Metalworks",   
    ["zjednoczoną kuźnię ebonheart"] = "Ebonheart_Unified_Metalworks",    
    ["zjednoczoną kuźnią ebonheart"] = "Ebonheart_Unified_Metalworks",    
    ["zjednoczona kuźnio ebonheart"] = "Ebonheart_Unified_Metalworks",    
	-- Arrius Keep
    ["arrius keep"] = "Arrius_Keep",

    -- Wersja 1: Warownia Arrius 
    ["warownia arrius"] = "Arrius_Keep",   
    ["warowni arrius"] = "Arrius_Keep",   
    ["warownię arrius"] = "Arrius_Keep",   
    ["warownią arrius"] = "Arrius_Keep",   
    ["warownio arrius"] = "Arrius_Keep",   

    -- Wersja 2: Twierdza Arrius (Nazwa z bazy)
    ["twierdza arrius"] = "Arrius_Keep",   
    ["twierdzy arrius"] = "Arrius_Keep",  
    ["twierdzę arrius"] = "Arrius_Keep",   
    ["twierdzą arrius"] = "Arrius_Keep",   
    ["twierdzo arrius"] = "Arrius_Keep",   
	-- Fort Arand
    ["fort arand"] = "Fort_Arand",   
    ["fortu arand"] = "Fort_Arand",    
    ["fortowi arand"] = "Fort_Arand",  
    ["fortem arand"] = "Fort_Arand",   
    ["forcie arand"] = "Fort_Arand",   
	["virtue"] = "Virtue", --za krótkie nie znaleziono
	-- Winter's Peak Outpost
    ["winter's peak outpost"] = "Winter's_Peak_Outpost",

    -- Wersja 1: Posterunek Winter's Peak 
    ["posterunek winter's peak"] = "Winter's_Peak_Outpost", 
    ["posterunku winter's peak"] = "Winter's_Peak_Outpost",
    ["posterunkowi winter's peak"] = "Winter's_Peak_Outpost",  
    ["posterunkiem winter's peak"] = "Winter's_Peak_Outpost",  

    -- Wersja 2: Posterunek Zimowego Szczytu 
    ["posterunek zimowego szczytu"] = "Winter's_Peak_Outpost", 
    ["posterunku zimowego szczytu"] = "Winter's_Peak_Outpost",
    ["posterunkowi zimowego szczytu"] = "Winter's_Peak_Outpost",  
    ["posterunkiem zimowego szczytu"] = "Winter's_Peak_Outpost",  
	-- Fort Rayles
    ["fort rayles"] = "Fort_Rayles",   
    ["fortu rayles"] = "Fort_Rayles",    
    ["fortowi rayles"] = "Fort_Rayles",  
    ["fortem rayles"] = "Fort_Rayles",   
    ["forcie rayles"] = "Fort_Rayles",   
	["weye"] = "Weye",	-- en=pl
	-- Frostedge Camp
    ["frostedge camp"] = "Frostedge_Camp",
    ["obóz mroźnej grani"] = "Frostedge_Camp",   
    ["obozu mroźnej grani"] = "Frostedge_Camp",
    ["obozowi mroźnej grani"] = "Frostedge_Camp",  
    ["obozem mroźnej grani"] = "Frostedge_Camp",   
	-- Bay Bridge
    ["bay bridge"] = "Bay_Bridge",

    -- Wersja 1: Most Zatoki 
    ["most zatoki"] = "Bay_Bridge",   
    ["mostu zatoki"] = "Bay_Bridge",    
    ["mostowi zatoki"] = "Bay_Bridge",  
    ["mostem zatoki"] = "Bay_Bridge",   
    ["moście zatoki"] = "Bay_Bridge",   

    -- Wersja 2: Most Zatokowy 
    ["most zatokowy"] = "Bay_Bridge",   
    ["mostu zatokowego"] = "Bay_Bridge",  
    ["mostowi zatokowemu"] = "Bay_Bridge",
    ["mostem zatokowym"] = "Bay_Bridge",  
    ["moście zatokowym"] = "Bay_Bridge",  
	-- Hunter's Glade
    ["hunter's glade"] = "Hunter's_Glade",
    ["łowiecka polana"] = "Hunter's_Glade",     
    ["łowieckiej polany"] = "Hunter's_Glade",    
    ["łowieckiej polanie"] = "Hunter's_Glade",   
    ["łowiecką polanę"] = "Hunter's_Glade",     
    ["łowiecką polaną"] = "Hunter's_Glade",     
    ["łowiecka polano"] = "Hunter's_Glade",     
	-- The Wailing Prison
    ["the wailing prison"] = "The_Wailing_Prison",
    ["lochy zawodzenia"] = "The_Wailing_Prison",   
    ["lochów zawodzenia"] = "The_Wailing_Prison",    
    ["lochom zawodzenia"] = "The_Wailing_Prison",    
    ["lochami zawodzenia"] = "The_Wailing_Prison",   
    ["lochach zawodzenia"] = "The_Wailing_Prison",   
	-- Forsaken Citadel
    ["forsaken citadel"] = "Forsaken_Citadel",

    -- Wersja 1: Zapomniana Cytadela 
    ["zapomniana cytadela"] = "Forsaken_Citadel",     
    ["zapomnianej cytadeli"] = "Forsaken_Citadel",   
    ["zapomnianą cytadelę"] = "Forsaken_Citadel",   
    ["zapomniana cytadelo"] = "Forsaken_Citadel",     

    -- Wersja 2: Opuszczona Cytadela 
    ["opuszczona cytadela"] = "Forsaken_Citadel",     
    ["opuszczonej cytadeli"] = "Forsaken_Citadel",   
    ["opuszczoną cytadelę"] = "Forsaken_Citadel",   
    ["opuszczona cytadelo"] = "Forsaken_Citadel",     
	-- The Erstwhile Sanctuary
    ["the erstwhile sanctuary"] = "The_Erstwhile_Sanctuary",
    ["niegdysiejsze sanktuarium"] = "The_Erstwhile_Sanctuary",   
    ["niegdysiejszego sanktuarium"] = "The_Erstwhile_Sanctuary",   
    ["niegdysiejszemu sanktuarium"] = "The_Erstwhile_Sanctuary",   
    ["niegdysiejszym sanktuarium"] = "The_Erstwhile_Sanctuary",
	-- Dusk Keep
    ["dusk keep"] = "Dusk",
	["dusk"] = "Dusk",
    ["twierdza zmierzchu"] = "Dusk",   
    ["twierdzy zmierzchu"] = "Dusk",   
    ["twierdzę zmierzchu"] = "Dusk",   
    ["twierdzą zmierzchu"] = "Dusk",   
    ["twierdzo zmierzchu"] = "Dusk",   
	-- Dark Stone Hollow
    ["dark stone hollow"] = "Dark_Stone_Hollow",

    -- Wersja 1: Kotlina Ciemnej Skały 
    ["kotlina ciemnej skały"] = "Dark_Stone_Hollow",     
    ["kotliny ciemnej skały"] = "Dark_Stone_Hollow",    
    ["kotlinie ciemnej skale"] = "Dark_Stone_Hollow",   
    ["kotlinę ciemną skałę"] = "Dark_Stone_Hollow",     
    ["kotliną ciemną skałą"] = "Dark_Stone_Hollow",     
    ["kotlino ciemna skało"] = "Dark_Stone_Hollow",     

    -- Wersja 2: Dziura Czarnego Kamienia 
    ["dziura czarnego kamienia"] = "Dark_Stone_Hollow",   
    ["dziury czarnego kamienia"] = "Dark_Stone_Hollow",   
    ["dziurze czarnego kamienia"] = "Dark_Stone_Hollow",  
    ["dziurę czarnego kamienia"] = "Dark_Stone_Hollow",   
    ["dziurą czarnego kamienia"] = "Dark_Stone_Hollow",   
    ["dziuro czarnego kamienia"] = "Dark_Stone_Hollow",   
	-- Tinkerer Tobin's Workshop
    ["tinkerer tobin's workshop"] = "Tinkerer_Tobin's_Workshop",
    ["warsztat majsterkowicza tobina"] = "Tinkerer_Tobin's_Workshop", 
    ["warsztatu majsterkowicza tobina"] = "Tinkerer_Tobin's_Workshop",  
    ["warsztatowi majsterkowicza tobina"] = "Tinkerer_Tobin's_Workshop",
    ["warsztatem majsterkowicza tobina"] = "Tinkerer_Tobin's_Workshop", 
    ["warsztacie majsterkowicza tobina"] = "Tinkerer_Tobin's_Workshop", 
	-- The Vile Laboratory
    ["the vile laboratory"] = "The_Vile_Laboratory",

    -- Wersja 1: Wstrętne Laboratorium 
    ["wstrętne laboratorium"] = "The_Vile_Laboratory",   
    ["wstrętnego laboratorium"] = "The_Vile_Laboratory",   
    ["wstrętnemu laboratorium"] = "The_Vile_Laboratory",   
    ["wstrętnym laboratorium"] = "The_Vile_Laboratory",

    -- Wersja 2: Niegodziwe Laboratorium 
    ["niegodziwe laboratorium"] = "The_Vile_Laboratory", 
    ["niegodziwego laboratorium"] = "The_Vile_Laboratory", 
    ["niegodziwemu laboratorium"] = "The_Vile_Laboratory", 
    ["niegodziwym laboratorium"] = "The_Vile_Laboratory",
	-- Spindleclutch
    ["spindleclutch"] = "Spindleclutch",

    -- Wersja 1: Pajęcza Wylęgarnia (Twoje tłumaczenie / z bazy)
    ["pajęcza wylęgarnia"] = "Spindleclutch",     
    ["pajęczej wylęgarni"] = "Spindleclutch",   
    ["pajęczą wylęgarnię"] = "Spindleclutch",     
    ["pajęczą wylęgarnią"] = "Spindleclutch",     
    ["pajęcza wylęgarnio"] = "Spindleclutch",     

    -- Wersja 2: Jaskinia pod Dwynnarth (z opisu w bazie, jako bardziej opisowa nazwa)
    ["jaskinia pod dwynnarth"] = "Spindleclutch",
    ["jaskini pod dwynnarth"] = "Spindleclutch",
	-- Broken Helm Hollow
    ["broken helm hollow"] = "Jar_Pękniętego_Hełmu",
    ["jar pękniętego hełmu"] = "Jar_Pękniętego_Hełmu", 
    ["jaru pękniętego hełmu"] = "Jar_Pękniętego_Hełmu",
    ["jarowi pękniętego hełmu"] = "Jar_Pękniętego_Hełmu",  
    ["jarem pękniętego hełmu"] = "Jar_Pękniętego_Hełmu",   
	--["khajiiti arms and armor"] = "Khajiiti_Arms_and_Armor",
	["ebon wastes"] = "Ebon_Wastes", -- brak w grze
	["fungal grotto"] = "Fungal_Grotto",	-- en=pl
	-- Waterside Mine
    ["waterside mine"] = "Waterside_Mine",
    ["przybrzeżna kopalnia"] = "Waterside_Mine",     
    ["przybrzeżnej kopalni"] = "Waterside_Mine",   
    ["przybrzeżną kopalnię"] = "Waterside_Mine",     
    ["przybrzeżną kopalnią"] = "Waterside_Mine",     
    ["przybrzeżna kopalnio"] = "Waterside_Mine",     
	-- Moira's Hope
    ["moira's hope"] = "Moira's_Hope",
    ["nadzieja moiry"] = "Moira's_Hope",     
    ["nadziei moiry"] = "Moira's_Hope",     
    ["nadzieję moiry"] = "Moira's_Hope",     
    ["nadzieją moiry"] = "Moira's_Hope",     
	-- Snapleg Cave
    ["snapleg cave"] = "Jaskinia_Łaminoga",
    ["jaskinia łaminoga"] = "Jaskinia_Łaminoga",     
    ["jaskini łaminoga"] = "Jaskinia_Łaminoga",     
    ["jaskinię łaminoga"] = "Jaskinia_Łaminoga",     
    ["jaskinią łaminoga"] = "Jaskinia_Łaminoga",     
    ["jaskinio łaminoga"] = "Jaskinia_Łaminoga",     
	-- Icereach
    ["icereach"] = "Icereach",
    ["lodowe pogranicze"] = "Icereach",   
    ["lodowego pogranicza"] = "Icereach",   
    ["lodowemu pograniczu"] = "Icereach",   
    ["lodowym pograniczem"] = "Icereach",   
    ["lodowym pograniczu"] = "Icereach",    
	-- Steamlake Encampment
    ["steamlake encampment"] = "Steamlake_Encampment",
    ["obóz przy parującym jeziorze"] = "Steamlake_Encampment",   
    ["obozu przy parującym jeziorze"] = "Steamlake_Encampment",
    ["obozowi przy parującym jeziorze"] = "Steamlake_Encampment",  
    ["obozem przy parującym jeziorze"] = "Steamlake_Encampment",   
	-- Lady Llarel's Shelter
    ["lady llarel's shelter"] = "Lady_Llarel's_Shelter",
    ["schronienie lady llarel"] = "Lady_Llarel's_Shelter",   
    ["schronienia lady llarel"] = "Lady_Llarel's_Shelter",     
    ["schronieniu lady llarel"] = "Lady_Llarel's_Shelter",     
    ["schronieniem lady llarel"] = "Lady_Llarel's_Shelter",    
	-- Softloam Cavern
    ["softloam cavern"] = "Softloam_Cavern",
    ["jaskinia miękkiej gliny"] = "Softloam_Cavern",     
    ["jaskini miękkiej gliny"] = "Softloam_Cavern",     
    ["jaskinię miękkiej gliny"] = "Softloam_Cavern",     
    ["jaskinią miękkiej gliny"] = "Softloam_Cavern",     
    ["jaskinio miękkiej gliny"] = "Softloam_Cavern",     
	-- Reconnaissance Camp
    ["reconnaissance camp"] = "Reconnaissance_Camp",

    -- Wersja 1: Obóz szpiegów 
    ["obóz szpiegów"] = "Reconnaissance_Camp",   
    ["obozu szpiegów"] = "Reconnaissance_Camp",
    ["obozowi szpiegów"] = "Reconnaissance_Camp",  
    ["obozem szpiegów"] = "Reconnaissance_Camp",   

    -- Wersja 2: Obóz zwiadowców 
    ["obóz zwiadowców"] = "Reconnaissance_Camp",   
    ["obozu zwiadowców"] = "Reconnaissance_Camp",
    ["obozowi zwiadowców"] = "Reconnaissance_Camp",  
    ["obozem zwiadowców"] = "Reconnaissance_Camp",   
	-- Stormcrag Crypt
    ["stormcrag crypt"] = "Stormcrag_Crypt",
    ["krypta burzowej skały"] = "Stormcrag_Crypt",     
    ["krypty burzowej skały"] = "Stormcrag_Crypt",    
    ["krypcie burzowej skały"] = "Stormcrag_Crypt",   
    ["kryptę burzowej skały"] = "Stormcrag_Crypt",     
    ["kryptą burzowej skały"] = "Stormcrag_Crypt",     
    ["krypto burzowej skały"] = "Stormcrag_Crypt",     
	-- Old Mistveil Manor
    ["old mistveil manor"] = "Mglista_Twierdza",
	["mglista twierdza"] = "Mglista_Twierdza",
    ["stary mglisty dwór"] = "Mglista_Twierdza",   
    ["starego mglistego dworu"] = "Mglista_Twierdza", 
    ["staremu mglistemu dworowi"] = "Mglista_Twierdza",
    ["starym mglistym dworem"] = "Mglista_Twierdza",  
    ["starym mglistym dworze"] = "Mglista_Twierdza",  
	-- Lipsand Tarn
    ["lipsand tarn"] = "Staw_Piaskousty",

    -- Wersja 1: Staw Piaskousty 
    ["staw piaskousty"] = "Staw_Piaskousty",   
    ["stawu piaskoustego"] = "Staw_Piaskousty",  
    ["stawowi piaskoustemu"] = "Staw_Piaskousty",
    ["stawem piaskoustym"] = "Staw_Piaskousty",  
    ["stawie piaskoustym"] = "Staw_Piaskousty",  

    -- Wersja 2: Zagłębienie Mydlanego Kamienia (Alternatywna nazwa z bazy)
    ["zagłębienie mydlanego kamienia"] = "Staw_Piaskousty",   
    ["zagłębienia mydlanego kamienia"] = "Staw_Piaskousty",     
    ["zagłębieniu mydlanego kamienia"] = "Staw_Piaskousty",     
    ["zagłębieniem mydlanego kamienia"] = "Staw_Piaskousty",    

    -- Wersja 3: Elfickie Legowisko (Alternatywna nazwa z bazy)
    ["elfickie legowisko"] = "Staw_Piaskousty",   
    ["elfickiego legowiska"] = "Staw_Piaskousty",   
    ["elfickiemu legowisku"] = "Staw_Piaskousty",   
    ["elfickim legowiskiem"] = "Staw_Piaskousty",   
    ["elfickim legowisku"] = "Staw_Piaskousty",     
	-- Niben River Bridge
    ["niben river bridge"] = "Niben_River_Bridge",

    -- Wersja 1: Most rzeki Niben 
    ["most rzeki niben"] = "Niben_River_Bridge",   
    ["mostu rzeki niben"] = "Niben_River_Bridge",    
    ["mostowi rzeki niben"] = "Niben_River_Bridge",  
    ["mostem rzeki niben"] = "Niben_River_Bridge",   
    ["moście rzeki niben"] = "Niben_River_Bridge",   
	-- Timberscar Hollow
    ["timberscar hollow"] = "Jama_Rozłupanego_Pnia",
    ["jama rozłupanego pnia"] = "Jama_Rozłupanego_Pnia",     
    ["jamy rozłupanego pnia"] = "Jama_Rozłupanego_Pnia",     
    ["jamie rozłupanego pnia"] = "Jama_Rozłupanego_Pnia",    
    ["jamę rozłupanego pnia"] = "Jama_Rozłupanego_Pnia",     
    ["jamą rozłupanego pnia"] = "Jama_Rozłupanego_Pnia",     
    ["jamo rozłupanego pnia"] = "Jama_Rozłupanego_Pnia",     
	-- Fort Zeren
    ["fort zeren"] = "Fort_Zeren",
    ["fortu zeren"] = "Fort_Zeren",    
    ["fortowi zeren"] = "Fort_Zeren",  
    ["fortem zeren"] = "Fort_Zeren",   
    ["forcie zeren"] = "Fort_Zeren",   
	["shadehome inn"] = "Shadehome_Inn",
	-- Sea and Sword Lodge
    ["sea and sword lodge"] = "Sea_and_Sword_Lodge",
    ["kwatera morza i miecza"] = "Sea_and_Sword_Lodge",     
    ["kwatery morza i miecza"] = "Sea_and_Sword_Lodge",     
    ["kwaterze morza i miecza"] = "Sea_and_Sword_Lodge",    
    ["kwaterę morza i miecza"] = "Sea_and_Sword_Lodge",     
    ["kwaterą morza i miecza"] = "Sea_and_Sword_Lodge",     
    ["kwatero morza i miecza"] = "Sea_and_Sword_Lodge",     
	["opuszczony dom (markart)"] = "Opuszczony_dom_(Markart)",
	-- Jaskinia Winnej Śmierci
    ["vinedeath cave"] = "Vinedeath_Cave",                     --  en=pl
    ["jaskinia winnej śmierci"] = "Vinedeath_Cave",           
    ["jaskini winnej śmierci"] = "Vinedeath_Cave",  
    ["jaskinię winnej śmierci"] = "Vinedeath_Cave",  
    ["jaskinią winnej śmierci"] = "Vinedeath_Cave",  
    ["jaskinio winnej śmierci"] = "Vinedeath_Cave",
	["akavir"] = "Akavir",
	-- Lantern of Lies
	["lantern of lies"] = "Lantern_of_Lies",
	["latarnia kłamstw"] = "Lantern_of_Lies",
	["latarni kłamstw"] = "Lantern_of_Lies",
	["latarnię kłamstw"] = "Lantern_of_Lies",
	["latarnią kłamstw"] = "Lantern_of_Lies",
	["latarnio kłamstw"] = "Lantern_of_Lies",
	-- Meridia's Beacon
	["latarnia meridii"] = "Latarnia_Meridii", -- do
	-- Obsidian Scar (Obsydianowa Blizna)
	["obsidian scar"] = "Obsidian_Scar",
	["obsydianowa blizna"] = "Obsidian_Scar",
	["obsydianowej blizny"] = "Obsidian_Scar",
	["obsydianowej bliznie"] = "Obsidian_Scar",
	["obsydianową bliznę"] = "Obsidian_Scar",
	["obsydianową blizną"] = "Obsidian_Scar",
	-- Southern Morrowind Gate
	["southern morrowind gate"] = "Southern_Morrowind_Gate",
	["południowa brama morrowind"] = "Southern_Morrowind_Gate",
	["południowej bramy morrowind"] = "Southern_Morrowind_Gate",
	["południowej bramie morrowind"] = "Southern_Morrowind_Gate",
	["południową bramę morrowind"] = "Southern_Morrowind_Gate",
	["południową bramą morrowind"] = "Southern_Morrowind_Gate",

	-- Mud Tree Village
	["mud tree village"] = "Mud_Tree_Village",
	["wioska błotnego drzewa"] = "Mud_Tree_Village",
	["wioski błotnego drzewa"] = "Mud_Tree_Village",
	["wiosce błotnego drzewa"] = "Mud_Tree_Village",
	["wioskę błotnego drzewa"] = "Mud_Tree_Village",
	["wioską błotnego drzewa"] = "Mud_Tree_Village",

	-- Huntsman's Fortress
	["huntsman's fortress"] = "Huntsman's_Fortress",
	["forteca łowczego"] = "Huntsman's_Fortress",
	["fortecy łowczego"] = "Huntsman's_Fortress",
	["fortecę łowczego"] = "Huntsman's_Fortress",
	["fortecą łowczego"] = "Huntsman's_Fortress",
	-- Black Marsh (Czarne Mokradła)
	["black marsh"] = "Czarne_Mokradła",
	["czarne mokradła"] = "Czarne_Mokradła",
	["czarnych mokradeł"] = "Czarne_Mokradła",
	["czarnym mokradłom"] = "Czarne_Mokradła",
	["czarnymi mokradłami"] = "Czarne_Mokradła",
	["czarnych mokradłach"] = "Czarne_Mokradła",
	-- Skyrim
	["skyrim"] = "Skyrim",
	["skyrimu"] = "Skyrim",
	["skyrimowi"] = "Skyrim",
	["skyrimem"] = "Skyrim",
	["skyrimie"] = "Skyrim",
	-- Coldharbour Colosseum
	["coldharbour colosseum"] = "Coldharbour_Colosseum",
	["koloseum mroźnego azylu"] = "Coldharbour_Colosseum",
----------------------------------------------------------------------------------------------------------------------------
	-- Miejsca koniec--
----------------------------------------------------------------------------------------------------------------------------   
	-- Postacie start--
----------------------------------------------------------------------------------------------------------------------------   
    -- Hears-the-Stone
    ["hears-the-stone"] = "Hears-the-Stone",
    ["słyszy-kamień"] = "Hears-the-Stone",      
    ["słyszy-kamienia"] = "Hears-the-Stone",  
    ["słyszy-kamieniowi"] = "Hears-the-Stone",  
    ["słyszy-kamieniem"] = "Hears-the-Stone",   
    ["słyszy-kamieniu"] = "Hears-the-Stone",    
    ["nomeg hyril"] = "Nomeg_Hyril",	-- en=pl
    -- Euthar Neckbender
    ["euthar neckbender"] = "Euthar_Neckbender",
    ["euthar kręgołamacz"] = "Euthar_Neckbender",     
    ["euthara kręgołamacza"] = "Euthar_Neckbender", 
    ["eutharowi kręgołamaczowi"] = "Euthar_Neckbender",
    ["eutharem kręgołamaczem"] = "Euthar_Neckbender", 
    ["eutharze kręgołamaczu"] = "Euthar_Neckbender",  
    -- Centurion Mobareed
    ["centurion mobareed"] = "Centurion_Mobareed",
    ["centurion mobareed"] = "Centurion_Mobareed",         
    ["centuriona mobareeda"] = "Centurion_Mobareed",     
    ["centurionowi mobareedowi"] = "Centurion_Mobareed",   
    ["centurionem mobareedem"] = "Centurion_Mobareed",     
    ["centurionie mobareedzie"] = "Centurion_Mobareed",    
    -- Vilia Pamphelius
    ["vilia pamphelius"] = "Vilia_Pamphelius",
    ["vilia pamphelius"] = "Vilia_Pamphelius",      
    ["vilii pamphelius"] = "Vilia_Pamphelius",     
    ["vilię pamphelius"] = "Vilia_Pamphelius",      
    ["vilią pamphelius"] = "Vilia_Pamphelius",      
    ["vilio pamphelius"] = "Vilia_Pamphelius",      
    ["alfa"] = "Alfa",	--en=pl
    -- Slimecraw
    ["slimecraw"] = "Slimecraw",
    ["śluzowiec"] = "Slimecraw",      
    ["śluzowca"] = "Slimecraw",     
    ["śluzowcowi"] = "Slimecraw",     
    ["śluzowcem"] = "Slimecraw",      
    ["śluzowcu"] = "Slimecraw",       
    -- Armorer Reistaff
    ["armorer reistaff"] = "Armorer_Reistaff",
    ["płatnerz reistaff"] = "Armorer_Reistaff",      
    ["płatnerza reistaffa"] = "Armorer_Reistaff",  
    ["płatnerzowi reistaffowi"] = "Armorer_Reistaff",
    ["płatnerzem reistaffem"] = "Armorer_Reistaff",  
    ["płatnerzu reistaffie"] = "Armorer_Reistaff",   
    -- Jand
    ["jand"] = "Jand",
    ["janda"] = "Jand",    
    ["jandowi"] = "Jand",    
    ["jandem"] = "Jand",     
    ["jandzie"] = "Jand",    
    -- Skips-the-Pebble
    ["skips-the-pebble"] = "Skips-the-Pebble",
    ["przeskakuje-kamyki"] = "Skips-the-Pebblei",   
    ["przeskakuje-kamyków"] = "Skips-the-Pebble",    
    ["przeskakuje-kamykom"] = "Skips-the-Pebble",    
    ["przeskakuje-kamykami"] = "Skips-the-Pebble",   
    ["przeskakuje-kamykach"] = "Skips-the-Pebble",   
    -- Hahnin
    ["hahnin"] = "Hahnin",
    ["hahnina"] = "Hahnin",    
    ["hahninowi"] = "Hahnin",    
    ["hahninem"] = "Hahnin",     
    ["hahninie"] = "Hahnin",     
    -- Euraxia Tharn
    ["euraxia tharn"] = "Euraxia_Tharn",
    ["euraxia tharn"] = "Euraxia_Tharn",      
    ["euraxii tharn"] = "Euraxia_Tharn",     
    ["euraxię tharn"] = "Euraxia_Tharn",      
    ["euraxią tharn"] = "Euraxia_Tharn",      
    ["euraxio tharn"] = "Euraxia_Tharn",      
    ["aodhait"] = "Aodhait",	-- en=pl
    -- Birkhu the Bold
    ["birkhu the bold"] = "Birkhu_the_Bold",
    ["birkhu śmiały"] = "Birkhu_the_Bold",     
    ["birkhu śmiałego"] = "Birkhu_the_Bold", 
    ["birkhu śmiałemu"] = "Birkhu_the_Bold",   
    ["birkhu śmiałym"] = "Birkhu_the_Bold",
    -- Barnaxi
    ["barnaxi"] = "Barnaxi",
    ["barnaxiego"] = "Barnaxi",  
    ["barnaxiemu"] = "Barnaxi",    
    ["barnaxim"] = "Barnaxi",
    -- Imeretto
    ["imeretto"] = "Imeretto",
    ["imeretta"] = "Imeretto",    
    ["imerettowi"] = "Imeretto",    
    ["imerettem"] = "Imeretto",     
    ["imeretcie"] = "Imeretto",     
    ["niralin"] = "Niralin",	-- en=pl
    -- Caecilia Attius
    ["caecilia attius"] = "Caecilia_Attius",
    ["caecilia attius"] = "Caecilia_Attius",      
    ["caecilii attius"] = "Caecilia_Attius",     
    ["caecilię attius"] = "Caecilia_Attius",      
    ["caecilią attius"] = "Caecilia_Attius",      
    ["caecilio attius"] = "Caecilia_Attius",      
    -- Gwinor
    ["gwinor"] = "Gwinor",
    ["gwinora"] = "Gwinor",    
    ["gwinorowi"] = "Gwinor",    
    ["gwinorem"] = "Gwinor",     
    ["gwinorze"] = "Gwinor",     
    ["dar-zish"] = "Dar-Zish",	-- en=pl
    -- Arkas
    ["arkas"] = "Arkas",
    ["arkasa"] = "Arkas",    
    ["arkasowi"] = "Arkas",    
    ["arkasem"] = "Arkas",     
    ["arkasie"] = "Arkas",     
    -- Gaston Ashham
    ["gaston ashham"] = "Gaston_Ashham",
    ["gaston ashham"] = "Gaston_Ashham",      
    ["gastona ashhama"] = "Gaston_Ashham",  
    ["gastonowi ashhamowi"] = "Gaston_Ashham",
    ["gastonem ashhamem"] = "Gaston_Ashham",  
    ["gastonie ashhamie"] = "Gaston_Ashham",  
    ["radreth"] = "Radreth",	-- en=pl
    -- Mondran Sarinith
    ["mondran sarinith"] = "Mondran_Sarinith",
    ["mondran sarinith"] = "Mondran_Sarinith",      
    ["mondrana sarinitha"] = "Mondran_Sarinith",  
    ["mondranowi sarinithowi"] = "Mondran_Sarinith",
    ["mondranem sarinithem"] = "Mondran_Sarinith",  
    ["mondranie sarinicie"] = "Mondran_Sarinith",   
    -- Ikran
    ["ikran"] = "Ikran",
    ["ikrana"] = "Ikran",    
    ["ikranowi"] = "Ikran",    
    ["ikranem"] = "Ikran",     
    ["ikranie"] = "Ikran",     
    -- Nirahni
    ["nirahni"] = "Nirahni",
    ["nirahni"] = "Nirahni",      
    ["nirahni"] = "Nirahni",     
    ["nirahni"] = "Nirahni",      
    ["nirahni"] = "Nirahni",      
    ["nirahni"] = "Nirahni",      
    -- Lights-the-Way
    ["lights-the-way"] = "Lights-the-Way",
    ["oświetla-drogę"] = "Lights-the-Way",    
    ["oświetla-drogi"] = "Lights-the-Way",      
    ["oświetla-drodze"] = "Lights-the-Way",     
    ["oświetla-drogą"] = "Lights-the-Way",      
    ["oświetla-drogo"] = "Lights-the-Way",      
    -- Fildgor Orcthane
    ["fildgor orcthane"] = "Fildgor_Orcthane",
    ["fildgor tan orków"] = "Fildgor_Orcthane",      
    ["fildgora tana orków"] = "Fildgor_Orcthane",  
    ["fildgorowi tanowi orków"] = "Fildgor_Orcthane",
    ["fildgorem tanem orków"] = "Fildgor_Orcthane",  
    ["fildgorze tanie orków"] = "Fildgor_Orcthane",  
    -- Fresmara
    ["fresmara"] = "Fresmara",
    ["fresmara"] = "Fresmara",      
    ["fresmary"] = "Fresmara",      
    ["fresmarze"] = "Fresmara",     
    ["fresmarę"] = "Fresmara",      
    ["fresmarą"] = "Fresmara",      
    ["fresmaro"] = "Fresmara",      
    -- Ferocious Jakidi
    ["ferocious jakidi"] = "Ferocious_Jakidi",
    ["sroga jakidi"] = "Ferocious_Jakidi",      
    ["srogiej jakidi"] = "Ferocious_Jakidi",   
    ["srogą jakidi"] = "Ferocious_Jakidi",    
    -- Zazabernura
    ["zazabernura"] = "Zazabernura",
    ["zazabernura"] = "Zazabernura",      
    ["zazabernury"] = "Zazabernura",      
    ["zazabernurze"] = "Zazabernura",     
    ["zazabernurę"] = "Zazabernura",      
    ["zazabernurą"] = "Zazabernura",      
    ["zazabernuro"] = "Zazabernura",      
    -- General Zasimba
    ["general zasimba"] = "General_Zasimba",
    ["generał zasimba"] = "General_Zasimba",      
    ["generał zasimby"] = "General_Zasimba",      
    ["generał zasimbie"] = "General_Zasimba",     
    ["generał zasimbę"] = "General_Zasimba",      
    ["generał zasimbą"] = "General_Zasimba",      
    ["generał zasimbo"] = "General_Zasimba",      
    -- Wita
    ["wita"] = "Wita",
    ["wita"] = "Wita",      
    ["wity"] = "Wita",      
    ["wicie"] = "Wita",     
    ["witę"] = "Wita",      
    ["witą"] = "Wita",      
    ["wito"] = "Wita",      
    ["terendras varro"] = "Terendras_Varro", -- en=pl
    -- Eyes-of-Steel
    ["eyes-of-steel"] = "Oczy-ze-Stali",
    ["oczy-ze-stali"] = "Oczy-ze-Stali",    
    ["oczu-ze-stali"] = "Oczy-ze-Stali",      
    ["oczom-ze-stali"] = "Oczy-ze-Stali",     
    ["oczami-ze-stali"] = "Oczy-ze-Stali",    
    ["oczach-ze-stali"] = "Oczy-ze-Stali",    
    -- Grunhere Wintermist
    ["grunhere wintermist"] = "Grunhere_Wintermist",
    ["grunhere zimowa mgła"] = "Grunhere_Wintermist",   
    ["grunhere zimowej mgły"] = "Grunhere_Wintermist",  
    ["grunhere zimowej mgle"] = "Grunhere_Wintermist",  
    ["grunhere zimową mgłę"] = "Grunhere_Wintermist",   
    ["grunhere zimową mgłą"] = "Grunhere_Wintermista",   
    ["grunhere zimowa mgło"] = "Grunhere_Wintermist",   
    -- Dalosil Rethan
    ["dalosil rethan"] = "Dalosil_Rethan",
    ["dalosil rethan"] = "Dalosil_Rethan",        
    ["dalosila rethana"] = "Dalosil_Rethan",    
    ["dalosilowi rethanowi"] = "Dalosil_Rethan",  
    ["dalosilem rethanem"] = "Dalosil_Rethan",    
    ["dalosilu rethanie"] = "Dalosil_Rethan",     
    -- Vurvyn
    ["vurvyn"] = "Vurvyn_(Nimalten)",         
    ["vurvyna"] = "Vurvyn_(Nimalten)",
    ["vurvynowi"] = "Vurvyn_(Nimalten)",
    ["vurvynem"] = "Vurvyn_(Nimalten)",       
    ["vurvynie"] = "Vurvyn_(Nimalten)",       
    -- Marodeen
    ["marodeen"] = "Marodeen",
    ["marodeena"] = "Marodeen",
    ["marodeenowi"] = "Marodeen",  
    ["marodeenem"] = "Marodeen", 
    ["marodeenie"] = "Marodeen",
    -- Trynhild Obracająca-Ziemię
    ["trynhild earth-turner"] = "Trynhild_Earth-Turner",             --  en=pl
    ["trynhild obracająca-ziemię"] = "Trynhild_Earth-Turner",       
    ["trynhildy obracającej-ziemię"] = "Trynhild_Earth-Turner",     
    ["trynhildzie obracającej-ziemię"] = "Trynhild_Earth-Turner",   
    ["trynhildę obracającą-ziemię"] = "Trynhild_Earth-Turner",      
    ["trynhildą obracającą-ziemię"] = "Trynhild_Earth-Turner",      
    ["trynhildo obracająca-ziemię"] = "Trynhild_Earth-Turner",      
    -- Kothekel
    ["kothekel"] = "Kothekel",
    ["kothekela"] = "Kothekel",
    ["kothekelowi"] = "Kothekel",  
    ["kothekelem"] = "Kothekel", 
    ["kothekelu"] = "Kothekel", 
    -- Legionary Calvo Dorso
    ["legionista calvo dorso"] = "Legionary_Calvo_Dorso",
	["legionary calvo dorso"] = "Legionary_Calvo_Dorso",	
    ["legionisty calvo dorso"] = "Legionary_Calvo_Dorso",      
    ["legioniście calvo dorso"] = "Legionary_Calvo_Dorso",     
    ["legionistę calvo dorso"] = "Legionary_Calvo_Dorso",      
    ["legionistą calvo dorso"] = "Legionary_Calvo_Dorso",      
    -- Araki Ice-Heart
    ["araki ice-heart"] = "Araki_Ice-Heart",      
    ["araki ice-heart"] = "Araki_Ice-Heart",
    ["araki ice-heart"] = "Araki_Ice-Heart",
    ["araki ice-heart"] = "Araki_Ice-Heart",      
    ["araki ice-heart"] = "Araki_Ice-Heart",      
    ["araki ice-heart"] = "Araki_Ice-Heart",      
    -- Elmera Llandu
    ["elmera llandu"] = "Elmera_Llandu",          
    ["elmery llandu"] = "Elmera_Llandu", 
    ["elmerze llandu"] = "Elmera_Llandu",
    ["elmerę llandu"] = "Elmera_Llandu", 
    ["elmerą llandu"] = "Elmera_Llandu", 
    ["elmero llandu"] = "Elmera_Llandu",          
    ["calanyese"] = "Calanyese",	-- en=pl
    -- Bolay Uvani
    ["bolay uvani"] = "Bolay_Uvani",           
    ["bolaya uvani"] = "Bolay_Uvani",
    ["bolayowi uvani"] = "Bolay_Uvani", 
    ["bolayem uvani"] = "Bolay_Uvani",
    ["bolayu uvani"] = "Bolay_Uvani",
    -- Lyfskar Zimne-Oko
    ["lyfskar cold-eye"] = "Lyfskar_Cold-Eye",           -- en=pl
    ["lyfskar zimne-oko"] = "Lyfskar_Cold-Eye",         
    ["lyfskara zimnego-oka"] = "Lyfskar_Cold-Eye",      
    ["lyfskarowi zimnemu-oku"] = "Lyfskar_Cold-Eye",    
    ["lyfskara zimne-oko"] = "Lyfskar_Cold-Eye",        
    ["lyfskarem zimnym-okiem"] = "Lyfskar_Cold-Eye",    
    ["lyfskarze zimnym-oku"] = "Lyfskar_Cold-Eye",      
    ["lyfskarze zimne-oko"] = "Lyfskar_Cold-Eye",       
    -- Noryesar
    ["noryesar"] = "Noryesar",
    ["noryesara"] = "Noryesar",
    ["noryesarowi"] = "Noryesar",  
    ["noryesarem"] = "Noryesar", 
    ["noryesarze"] = "Noryesar",
    -- Freca
    ["freca"] = "Freca",      
    ["frecy"] = "Freca",        
    ["frecę"] = "Freca",         
    ["frecą"] = "Freca",         
    ["freco"] = "Freca",       
    -- Narana
    ["narana"] = "Narana",      
    ["narany"] = "Narana",         
    ["naranie"] = "Narana",    
    ["naranę"] = "Narana",         
    ["naraną"] = "Narana",         
    ["narano"] = "Narana",       
    -- Vivien Armene
    ["vivien armene"] = "Vivien_Armene",           -- en=pl
    -- Wiljar
    ["wiljar"] = "Wiljar",    
    ["wiljara"] = "Wiljar",    
    ["wiljarowi"] = "Wiljar",      
    ["wiljarem"] = "Wiljar",     
    ["wiljarze"] = "Wiljar",    
    -- Appius Castorius
    ["appius castorius"] = "Appius_Castorius",
    ["appiusa castoriusa"] = "Appius_Castorius",
    ["appiusowi castoriusowi"] = "Appius_Castorius",
    ["appiusem castoriusem"] = "Appius_Castorius",        
    ["appiusie castoriusie"] = "Appius_Castorius",        
    -- Beridi Włochate-Nogi
	["beridi-hairy-legs"] = "Beridi_Hairy-Legs",
    ["beridi włochate-nogi"] = "Beridi_Hairy-Legs",       
    ["beridi włochatych-nóg"] = "Beridi_Hairy-Legs",      
    ["beridi włochatym-nogom"] = "Beridi_Hairy-Legs",     
    ["beridi włochate-nogi"] = "Beridi_Hairy-Legs",       
    ["beridi włochatymi-nogami"] = "Beridi_Hairy-Legs",   
    ["beridi włochatych-nogach"] = "Beridi_Hairy-Legs",   
    ["beridi włochate-nogi"] = "Beridi_Hairy-Legs",       
    -- Ilflynn
    ["ilflynn"] = "Ilflynn",  
    ["ilflynna"] = "Ilflynn",  
    ["ilflynnowi"] = "Ilflynn",    
    ["ilflynnem"] = "Ilflynn",   
    ["ilflynnie"] = "Ilflynn",  
    -- Agila
    ["agila"] = "Agila",      
    ["agili"] = "Agila",        
    ["agilę"] = "Agila",         
    ["agilą"] = "Agila",         
    ["agilo"] = "Agila",       
    -- Malizluz
    ["malizluz"] = "Malizluz",             -- en=pl
    -- Valga Atrius
    ["valga atrius"] = "Valga_Atrius",
    ["valgi atrius"] = "Valga_Atrius",   
    ["valdze atrius"] = "Valga_Atrius",
    ["valgę atrius"] = "Valga_Atrius",   
    ["valgą atrius"] = "Valga_Atrius",   
    ["valgo atrius"] = "Valga_Atrius", 
    -- Condalin
    ["condalin"] = "Condalin",
    ["condalina"] = "Condalin",
    ["condalinowi"] = "Condalin",  
    ["condalinem"] = "Condalin", 
    ["condalinie"] = "Condalin",
    -- Kłóci-Się-z-Żabami
    ["argues-with-frogs"] = "Argues-with-Frogs",           -- en=pl
    ["kłóci-się-z-żabami"] = "Argues-with-Frogs",         
    ["kłóci-się-z-żabami"] = "Argues-with-Frogs",
    ["kłóci-się-z-żabami"] = "Argues-with-Frogs",  
    ["kłóci-się-z-żabami"] = "Argues-with-Frogs",
    ["kłóci-się-z-żabami"] = "Argues-with-Frogs",
    ["kłóci-się-z-żabami"] = "Argues-with-Frogs",         
    -- Amelie Crowe
    ["amelie crowe"] = "Amelie_Crowe",             -- en=pl
    -- Fangaril
    ["fangaril"] = "Fangaril",             --  en=pl
    ["fangarila"] = "Fangaril",
    ["fangarilowi"] = "Fangaril",  
    ["fangarilem"] = "Fangaril", 
    ["fangarilu"] = "Fangaril", 
    -- Irrki
    ["irrki"] = "Irrki",                   -- en=pl
    -- Jareki
    ["jareki"] = "Jareki",                 --  en=pl
    ["jarekiego"] = "Jareki",  
    ["jarekiemu"] = "Jareki",      
    ["jarekim"] = "Jareki",
    ["jareki"] = "Jareki",     
    -- Gemma Invel
    ["gemma invel"] = "Gemma_Invel",               --  en=pl
    ["gemma invel"] = "Gemma_Invel",  
    ["gemmy invel"] = "Gemma_Invel",     
    ["gemmie invel"] = "Gemma_Invel",
    ["gemmę invel"] = "Gemma_Invel",     
    ["gemmą invel"] = "Gemma_Invel",     
    ["gemmo invel"] = "Gemma_Invel",   
    -- Shamaea
    ["shamaea"] = "Shamaea",               --  en=pl
    ["shamaei"] = "Shamaea",    
    ["shamaeę"] = "Shamaea",     
    ["shamaeą"] = "Shamaea",     
    ["shamaeo"] = "Shamaea",   
    -- Kroczy-Dumnie
    ["marches-proud"] = "Marches-Proud",           -- en=pl
    ["kroczy-dumnie"] = "Marches-Proud",          
    ["kroczy-dumnie"] = "Marches-Proud",
    ["kroczy-dumnie"] = "Marches-Proud",   
    ["kroczy-dumnie"] = "Marches-Proud", 
    ["kroczy-dumnie"] = "Marches-Proud", 
    ["kroczy-dumnie"] = "Marches-Proud",
    -- Narion
    ["narion"] = "Narion",                 --  en=pl
    ["nariona"] = "Narion",    
    ["narionowi"] = "Narion",      
    ["narionem"] = "Narion",     
    ["narionie"] = "Narion",    
    -- Wicenamiestnik Pelidil
    ["vicereeve pelidil"] = "Vicereeve_Pelidil",               --  en=pl
    ["wicenamiestnik pelidil"] = "Vicereeve_Pelidil",         
    ["wicenamiestnika pelidila"] = "Vicereeve_Pelidil",     
    ["wicenamiestnikowi pelidilowi"] = "Vicereeve_Pelidil",   
    ["wicenamiestnikiem pelidilem"] = "Vicereeve_Pelidil",    
    ["wicenamiestniku pelidilu"] = "Vicereeve_Pelidil",       
    -- Qumehdi
    ["qumehdi"] = "Qumehdi",                   -- en=pl
    -- Firolmoth
    ["firolmoth"] = "Firolmoth",             --  en=pl
    ["firolmotha"] = "Firolmoth",
    ["firolmothowi"] = "Firolmoth",  
    ["firolmothem"] = "Firolmoth", 
    ["firolmothcie"] = "Firolmoth",         
    -- Nelgorn
    ["nelgorn"] = "Nelgorn",               --  en=pl
    ["nelgorna"] = "Nelgorn",  
    ["nelgornowi"] = "Nelgorn",    
    ["nelgornem"] = "Nelgorn",   
    ["nelgornie"] = "Nelgorn",  
    -- Rinareth Wędrowczyni
    ["rinareth the wanderer"] = "Rinareth_the_Wanderer",         -- en=pl
    ["rinareth wędrowczyni"] = "Rinareth_the_Wanderer",
    ["rinareth wędrowczynię"] = "Rinareth_the_Wanderer",        
    ["rinareth wędrowczynią"] = "Rinareth_the_Wanderer",        
    -- Liranaire
    ["liranaire"] = "Liranaire",                   -- en=pl
    -- Kralald
    ["kralald"] = "Kralald",               --  en=pl
    ["kralald"] = "Kralald",  
    ["kralalda"] = "Kralald",  
    ["kralaldowi"] = "Kralald",    
    ["kralaldem"] = "Kralald",   
    ["kralaldzie"] = "Kralald", 
    -- Lucia Livianus
    ["lucia livianus"] = "Lucia_Livianus",             --  en=pl
    ["lucia livianus"] = "Lucia_Livianus",
    ["lucii livianus"] = "Lucia_Livianus",  
    ["lucię livianus"] = "Lucia_Livianus",   
    ["lucią livianus"] = "Lucia_Livianus",   
    ["lucjo livianus"] = "Lucia_Livianus", 
    -- Zwiadowca Śnieżny-Łowca
    ["scout snowhunter"] = "Scout_Snowhunter",                 --  en=pl
    ["zwiadowca śnieżny-łowca"] = "Scout_Snowhunter",         
    ["zwiadowcy śnieżnego-łowcy"] = "Scout_Snowhunter",       
    ["zwiadowcy śnieżnemu-łowcy"] = "Scout_Snowhunter",
    ["zwiadowcę śnieżnego-łowcę"] = "Scout_Snowhunter",       
    ["zwiadowcą śnieżnym-łowcą"] = "Scout_Snowhunter",        
    ["zwiadowcy śnieżnym-łowcy"] = "Scout_Snowhunter",        
    ["zwiadowco śnieżny-łowco"] = "Scout_Snowhunter",         
    -- Droi
    ["droi"] = "Droi",                     --  en=pl
    ["droi"] = "Droi",        
    ["droia"] = "Droi",  
    ["droiowi"] = "Droi",          
    ["droiem"] = "Droi",         
    ["droiu"] = "Droi",         
    -- Karulae (Auridon)
    ["karulae (auridon)"] = "Karulae_(Auridon)",            -- en=pl
    ["karulae"] = "Karulae_(Auridon)",
    ["karulaego"] = "Karulae_(Auridon)", 
    ["karulaemu"] = "Karulae_(Auridon)",           
    ["karulaem"] = "Karulae_(Auridon)",          
    ["karulaem"] = "Karulae_(Auridon)",
    ["karulae"] = "Karulae_(Auridon)",         
    -- Nindaeril Monsun
    ["nindaeril the monsoon"] = "Nindaeril_the_Monsoon",       -- en=pl
    ["nindaeril monsun"] = "Nindaeril_the_Monsoon",           
    ["nindaeril monsunu"] = "Nindaeril_the_Monsoon", 
    ["nindaeril monsunowi"] = "Nindaeril_the_Monsoon", 
    ["nindaeril monsun"] = "Nindaeril_the_Monsoon",  
    ["nindaeril monsunem"] = "Nindaeril_the_Monsoon",
    ["nindaeril monsunie"] = "Nindaeril_the_Monsoon",         
    -- Tan Unnvald Żelazna-Ręka
    ["thane unnvald ironhand"] = "Thane_Unnvald_Ironhand",     -- Oryginał
    ["tan unnvald żelazna-ręka"] = "Thane_Unnvald_Ironhand", 
    ["tana unnvalda żelaznej-ręki"] = "Thane_Unnvald_Ironhand",
    ["tanowi unnvaldowi żelaznej-ręce"] = "Thane_Unnvald_Ironhand",
    ["tana unnvalda żelazną-rękę"] = "Thane_Unnvald_Ironhand",
    ["tanem unnvaldem żelazną-ręką"] = "Thane_Unnvald_Ironhand",
    ["tanie unnvald żelaznej-ręce"] = "Thane_Unnvald_Ironhand",
    ["tanie unnvald żelazna-ręko"] = "Thane_Unnvald_Ironhand",
    -- Orochar
    ["orochar"] = "Orochar",               -- en=pl
    -- Czerwona Virgar
    ["virgar the red"] = "Virgar_the_Red",             --  en=pl
    ["czerwona virgar"] = "Virgar_the_Red",           
    ["czerwonej virgar"] = "Virgar_the_Red",
    ["czerwoną virgar"] = "Virgar_the_Red",
    ["czerwona virgar"] = "Virgar_the_Red",
    -- Faustina Papus
    ["faustina papus"] = "Faustina_Papus",             --  en=pl
    ["faustina papus"] = "Faustina_Papus",
    ["faustyny papus"] = "Faustina_Papus",  
    ["faustinę papus"] = "Faustina_Papus",   
    ["faustyną papus"] = "Faustina_Papus",   
    ["faustino papus"] = "Faustina_Papus", 
    -- Galms Fevur
    ["galms fevur"] = "Galms_Fevur",               --  en=pl
    ["galms fevur"] = "Galms_Fevur",  
    ["galmsa fevura"] = "Galms_Fevur", 
    ["galmsowi fevurowi"] = "Galms_Fevur", 
    ["galmsem fevurem"] = "Galms_Fevur", 
    ["galmsie fevurze"] = "Galms_Fevur",
    -- Chakuk
    ["chakuk"] = "Chakuk",                 --  en=pl
    ["chakuk"] = "Chakuk",    
    ["chakuka"] = "Chakuk",    
    ["chakukowi"] = "Chakuk",      
    ["chakukiem"] = "Chakuk",    
    ["chakuku"] = "Chakuk",     
    -- Bura-Natoo
    ["bura-natoo"] = "Bura_Natoo",                 -- en=pl
    -- Vikonn
    ["vikonn"] = "Vikonn",                 --  en=pl
    ["vikonn"] = "Vikonn",    
    ["vikonna"] = "Vikonn",    
    ["vikonnowi"] = "Vikonn",      
    ["vikonnem"] = "Vikonn",     
    ["vikonnie"] = "Vikonn",    
    -- Matka Gniazda
    ["the nestmother"] = "The_Nestmother",             --  en=pl
    ["matka gniazda"] = "The_Nestmother", 
    ["matki gniazda"] = "The_Nestmother",    
    ["matce gniazda"] = "The_Nestmother",
    ["matkę gniazda"] = "The_Nestmother",    
    ["matką gniazda"] = "The_Nestmother",    
    ["matko gniazda"] = "The_Nestmother",  
    -- Kapitan Tsuzo
    ["captain tsuzo"] = "Captain_Tsuzo",               --  en=pl
    ["kapitan tsuzo"] = "Captain_Tsuzo",  
    ["kapitana tsuza"] = "Captain_Tsuzo",  
    ["kapitanowi tsuzowi"] = "Captain_Tsuzo",  
    ["kapitanem tsuzom"] = "Captain_Tsuzo",  
    ["kapitanie tsuzcie"] = "Captain_Tsuzo",
    -- Król Ranser
    ["king ranser"] = "King_Ranser",               --  en=pl
    ["król ranser"] = "King_Ranser",  
    ["króla ransera"] = "King_Ranser", 
    ["królowi ranserowi"] = "King_Ranser", 
    ["królem ranserem"] = "King_Ranser", 
    ["królu ranserze"] = "King_Ranser", 
    -- Belgrod Srogie Ostrze
    ["belgrod sternblade"] = "Belgrod_Sternblade",         -- en=pl
    ["belgrod srogie ostrze"] = "Belgrod_Sternblade",     
    ["belgroda srogiego ostrza"] = "Belgrod_Sternblade",  
    ["belgrodowi srogiemu ostrzu"] = "Belgrod_Sternblade",
    ["belgroda srogie ostrze"] = "Belgrod_Sternblade",
    ["belgrodem srogim ostrzem"] = "Belgrod_Sternblade",  
    ["belgrodzie srogim ostrzu"] = "Belgrod_Sternblade",  
    ["belgrodzie srogie ostrze"] = "Belgrod_Sternblade",  
    -- Skoref Niedźwiedzia Krew
    ["skoref bearblood"] = "Skoref_Bearblood",                 --  en=pl
    ["skoref niedźwiedzia krew"] = "Skoref_Bearblood",        
    ["skorefa niedźwiedzia krew"] = "Skoref_Bearblood",     
    ["skorefowi niedźwiedzia krew"] = "Skoref_Bearblood",     
    ["skorefem niedźwiedzia krew"] = "Skoref_Bearblood",      
    ["skorefie niedźwiedzia krew"] = "Skoref_Bearblood",      
    -- Varien
    ["varien"] = "Varien",                 --  en=pl
    ["varien"] = "Varien",    
    ["variena"] = "Varien",    
    ["varienowi"] = "Varien",      
    ["varienem"] = "Varien",     
    ["varienie"] = "Varien",    
    -- Thilse Drom
    ["thilse drom"] = "Thilse_Drom",               -- en=pl
    -- Słuchający-się-Wody
    ["listens-to-water"] = "Listens-to-Water",             --  en=pl
    ["słuchający-się-wody"] = "Listens-to-Water",          -- en=pl (Kanoniczna CB)
    ["słucha-wody"] = "Listens-to-Water",                  -- Alias z CSV
    -- Kharez
    ["kharez"] = "Kharez",                 --  en=pl
    ["kharez"] = "Kharez",    
    ["khareza"] = "Kharez",    
    ["kharezowi"] = "Kharez",      
    ["kharezem"] = "Kharez",     
    ["kharezcie"] = "Kharez",   
    -- Błyszczy-w-Świetle-Księżyca
    ["shines-in-moonlight"] = "Shines-In-Moonlight",           -- en=pl
    ["błyszczy-w-świetle-księżyca"] = "Shines-In-Moonlight",  -- en=pl (kanoniczna)
    -- Atheval
    ["atheval"] = "Atheval",               -- en=pl
	["athevali"] = "Atheval",
    -- Rilyn Uvani
    ["rilyn uvani"] = "Rilyn_Uvani",             --  en=pl
    ["rilyn uvani"] = "Rilyn_Uvani",
    ["rilyna uvani"] = "Rilyn_Uvani",
    ["rilynowi uvani"] = "Rilyn_Uvani",  
    ["rilynem uvani"] = "Rilyn_Uvani", 
    ["rilynie uvani"] = "Rilyn_Uvani",
    -- Przecieka-Po-Uderzeniu
    ["leaks-when-struck"] = "Leaks-When-Struck",           -- en=pl
    ["przecieka-po-uderzeniu"] = "Leaks-When-Struck",      -- en=pl
    -- Zavour Emard
    ["zavour emard"] = "Zavour_Emard",           -- en=pl
    ["zavour emard"] = "Zavour_Emard",          
    ["zavoura emarda"] = "Zavour_Emard",
    ["zavourowi emardowi"] = "Zavour_Emard",    
    ["zavourem emardem"] = "Zavour_Emard",      
    ["zavourze emardzie"] = "Zavour_Emard",     
    -- Tyraniczny Obserwator
    ["watcher tyrant"] = "Watcher_Tyrant",                   --  en=pl
    ["tyraniczny obserwator"] = "Watcher_Tyrant",           
    ["tyranicznego obserwatora"] = "Watcher_Tyrant",
    ["tyranicznemu obserwatorowi"] = "Watcher_Tyrant",
    ["tyranicznym obserwatorem"] = "Watcher_Tyrant",        
    ["tyranicznym obserwatorze"] = "Watcher_Tyrant",        
    -- Tallatta Lśniąca
    ["tallatta the lustrous"] = "Tallatta_the_Lustrous",       -- en=pl
    ["tallatta lśniąca"] = "Tallatta_the_Lustrous",           
    ["tallatty lśniącej"] = "Tallatta_the_Lustrous", 
    ["tallatcie lśniącej"] = "Tallatta_the_Lustrous",  
    ["tallattę lśniącą"] = "Tallatta_the_Lustrous",  
    ["tallattą lśniącą"] = "Tallatta_the_Lustrous",  
    ["tallatcie lśniącej"] = "Tallatta_the_Lustrous",         
    ["tallatto lśniąca"] = "Tallatta_the_Lustrous",
    -- Idronea Elval
    ["idronea elval"] = "Idronea_Elval",           -- en=pl
    ["idronea elval"] = "Idronea_Elval",          
    ["idronei elval"] = "Idronea_Elval",
    ["idroneę elval"] = "Idronea_Elval", 
    ["idroneą elval"] = "Idronea_Elval", 
    ["idroneo elval"] = "Idronea_Elval",          
    -- Egzarcha Kraglen
    ["exarch kraglen"] = "Exarch_Kraglen",             --  en=pl
    ["egzarcha kraglen"] = "Exarch_Kraglen",          
    ["egzarchy kraglena"] = "Exarch_Kraglen",
    ["egzarsze kraglenowi"] = "Exarch_Kraglen",
    ["egzarchę kraglena"] = "Exarch_Kraglen",
    ["egzarchą kraglenem"] = "Exarch_Kraglen",        
    ["egzarsze kraglenie"] = "Exarch_Kraglen",        
    ["egzarcho kraglenie"] = "Exarch_Kraglen",        
    -- Chuzu
    ["chuzu"] = "Chuzu",                   -- en=pl
    -- Grasuje-w-Ukryciu
    ["prowls-in-stealth"] = "Prowls-in-Stealth",           -- en=pl
    ["grasuje-w-ukryciu"] = "Prowls-in-Stealth",           -- en=pl
    -- Kroczący-Pod-Cieniem
    ["walks-under-shadow"] = "Walks-Under-Shadow",           -- en=pl
    ["kroczący-pod-cieniem"] = "Walks-Under-Shadow",         -- en=pl (LUA)
    ["kroczy-pod-cieniem"] = "Walks-Under-Shadow",           -- Alias z CSV
    -- Anafira
    ["anafira"] = "Anafira",               --  en=pl
    ["anafira"] = "Anafira",  
    ["anafiry"] = "Anafira",     
    ["anafirze"] = "Anafira",      
    ["anafirę"] = "Anafira",     
    ["anafirą"] = "Anafira",     
    ["anafirze"] = "Anafira",   
    ["anafiro"] = "Anafira",   
    -- Ungalin
    ["ungalin"] = "Ungalin",               --  en=pl
    ["ungalin"] = "Ungalin",  
    ["ungalina"] = "Ungalin",  
    ["ungalinowi"] = "Ungalin",    
    ["ungalinem"] = "Ungalin",   
    ["ungalinie"] = "Ungalin",  
    -- Volghass
    ["volghass"] = "Volghass",               --  en=pl
    ["volghass"] = "Volghass",  
    ["volghassa"] = "Volghass",  
    ["volghassowi"] = "Volghass",    
    ["volghassem"] = "Volghass",   
    ["volghassie"] = "Volghass",  
    -- Mathilie Północny Wiatr
    ["mathilie northwind"] = "Mathilie_Northwind",           -- en=pl
    ["mathilie północny wiatr"] = "Mathilie_Northwind",      -- en=pl
    -- Żarłoczna Glina
    ["ravenous loam"] = "Ravenous_Loam",                   --  en=pl
    ["żarłoczna glina"] = "Ravenous_Loam",    
    ["żarłocznej gliny"] = "Ravenous_Loam",      
    ["żarłocznej glinie"] = "Ravenous_Loam", 
    ["żarłoczną glinę"] = "Ravenous_Loam",       
    ["żarłoczną gliną"] = "Ravenous_Loam",       
    ["żarłoczna glino"] = "Ravenous_Loam",     
    -- Arethil
    ["arethil"] = "Arethil",               --  en=pl
    ["arethil"] = "Arethil",  
    ["arethila"] = "Arethil",  
    ["arethilowi"] = "Arethil",    
    ["arethilem"] = "Arethil",   
    ["arethilu"] = "Arethil",   
    -- Neposh
    ["neposh"] = "Neposh",                 --  en=pl
    ["neposh"] = "Neposh",    
    ["neposha"] = "Neposh",    
    ["neposhowi"] = "Neposh",      
    ["neposhem"] = "Neposh",     
    ["neposhu"] = "Neposh",     
    -- Harald Winvale
    ["harald winvale"] = "Harald_Winvale",               --  en=pl
    ["harald winvale"] = "Harald_Winvale",  
    ["haralda winvale'a"] = "Harald_Winvale",
    ["haraldowi winvale'owi"] = "Harald_Winvale",
    ["haraldem winvale'em"] = "Harald_Winvale",
    ["haraldzie winvale'u"] = "Harald_Winvale",         
    -- Stary Kapłan
    ["the old priest"] = "The_Old_Priest",               --  en=pl
    ["stary kapłan"] = "The_Old_Priest",    
    ["starego kapłana"] = "The_Old_Priest",  
    ["staremu kapłanowi"] = "The_Old_Priest",    
    ["starym kapłanem"] = "The_Old_Priest",    
    ["starym kapłanie"] = "The_Old_Priest",   
    -- Talsrel
    ["talsrel"] = "Talsrel",               --  en=pl
    ["talsrel"] = "Talsrel",  
    ["talsrela"] = "Talsrel",  
    ["talsrelowi"] = "Talsrel",    
    ["talsrelem"] = "Talsrel",   
    ["talsrelu"] = "Talsrel",   
    -- Prymas Artorius
    ["primate artorius"] = "Primate_Artorius",               --  en=pl
    ["prymas artorius"] = "Primate_Artorius",   
    ["prymasa artoriusa"] = "Primate_Artorius",  
    ["prymasowi artoriusowi"] = "Primate_Artorius",  
    ["prymasem artoriusem"] = "Primate_Artorius",  
    ["prymasie artoriusie"] = "Primate_Artorius", 
    -- Akarn
    ["akarn"] = "Akarn",                   --  en=pl
    ["akarn"] = "Akarn",      
    ["akarna"] = "Akarn",
    ["akarnowi"] = "Akarn",        
    ["akarnem"] = "Akarn",       
    ["akarnie"] = "Akarn",      
    -- Stephen Callyn
    ["stephen callyn"] = "Stephen_Callyn",               --  en=pl
    ["stephen callyn"] = "Stephen_Callyn",  
    ["stephena callyna"] = "Stephen_Callyn", 
    ["stephenowi callynowi"] = "Stephen_Callyn", 
    ["stephenem callynem"] = "Stephen_Callyn", 
    ["stephenie callynie"] = "Stephen_Callyn",
    -- Kapitan Rhealt
    ["captain rhealt"] = "Captain_Rhealt",               --  en=pl
    ["kapitan rhealt"] = "Captain_Rhealt",  
    ["kapitan rhealt"] = "Captain_Rhealt",
    -- Druidka Peeska
    ["druid peeska"] = "Druid_Peeska",               --  en=pl
    ["druidka peeska"] = "Druid_Peeska",
    ["druidki peeski"] = "Druid_Peeska",   
    ["druidce peesce"] = "Druid_Peeska", 
    ["druidkę peeskę"] = "Druid_Peeska",   
    ["druidką peeską"] = "Druid_Peeska",   
    ["druidko peesko"] = "Druid_Peeska", 
    -- Bastian Hallix
    ["bastian hallix"] = "Bastian_Hallix",             --  en=pl
    ["bastian hallix"] = "Bastian_Hallix",
    ["bastiana hallixa"] = "Bastian_Hallix",
    ["bastianowi hallixowi"] = "Bastian_Hallix",
    ["bastianem hallixem"] = "Bastian_Hallix",        
    ["bastianie hallixie"] = "Bastian_Hallix",        
    -- Rianne
    ["rianne"] = "Rianne",                 --  en=pl
    ["rianne"] = "Rianne",    
    ["rianne"] = "Rianne",  
    -- Pani Pocieszenia
    ["lady solace"] = "Lady_Solace",               --  en=pl
    ["pani pocieszenia"] = "Lady_Solace",
    ["panią pocieszenia"] = "Lady_Solace",      
    -- Nezashul
    ["nezashul"] = "Nezashul",             --  en=pl
    ["nezashul"] = "Nezashul",
    ["nezashula"] = "Nezashul",
    ["nezashulowi"] = "Nezashul",  
    ["nezashulem"] = "Nezashul", 
    ["nezashulu"] = "Nezashul", 
    -- Quendia
    ["quendia"] = "Quendia",               --  en=pl
    ["quendia"] = "Quendia",  
    ["quendii"] = "Quendia",    
    ["quendię"] = "Quendia",     
    ["quendią"] = "Quendia",     
    ["quendio"] = "Quendia",   
    -- Thugrub Reformowany
    ["thugrub the reformed"] = "Thugrub_the_Reformed",           -- en=pl
    ["thugrub reformowany"] = "Thugrub_the_Reformed",           
    ["thugruba reformowanego"] = "Thugrub_the_Reformed",
    ["thugrubowi reformowanemu"] = "Thugrub_the_Reformed",
    ["thugrubem reformowanym"] = "Thugrub_the_Reformed",        
    ["thugrubie reformowanym"] = "Thugrub_the_Reformed",        
    ["thugrubie reformowany"] = "Thugrub_the_Reformed",         
	["thugrub odtworzony"] = "Thugrub_the_Reformed",
    -- Dithis Romori
    ["dithis romori"] = "Dithis_Romori",                 --  en=pl
    ["dithis romori"] = "Dithis_Romori",    
    ["dithisa romoriego"] = "Dithis_Romori", 
    ["dithisowi romoriemu"] = "Dithis_Romori",   
    ["dithisem romorim"] = "Dithis_Romori",    
    ["dithisie romorim"] = "Dithis_Romori",   
    ["dithisie romori"] = "Dithis_Romori",   
    -- Aliir
    ["aliir"] = "Aliir",                   --  en=pl
    ["aliir"] = "Aliir",      
    ["aliira"] = "Aliir",
    ["aliirowi"] = "Aliir",        
    ["aliirem"] = "Aliir",       
    ["aliirze"] = "Aliir",      
    -- Khosren al-Bergama
    ["khosren al-bergama"] = "Khosren_al-Bergama",           -- en=pl
    ["khosren al-bergama"] = "Khosren_al-Bergama",          
    ["khosrena al-bergamy"] = "Khosren_al-Bergama",
    ["khosrenowi al-bergamie"] = "Khosren_al-Bergama",      
    ["khosrena al-bergamę"] = "Khosren_al-Bergama",
    ["khosrenem al-bergamą"] = "Khosren_al-Bergama",        
    ["khosrenie al-bergamo"] = "Khosren_al-Bergama",        
    -- Dezirri
    ["dezirri"] = "Dezirri",                 -- en=pl
    -- Clivia Tharn
    ["clivia tharn"] = "Clivia_Tharn",               -- en=pl
    ["clivii tharn"] = "Clivia_Tharn",    
    ["clivię tharn"] = "Clivia_Tharn",     
    ["clivią tharn"] = "Clivia_Tharn",     
    ["clivio tharn"] = "Clivia_Tharn",   
    -- Jean-Jacques Alois
    ["jean-jacques alois"] = "Jean-Jacques_Alois",       -- en=pl
    ["jeana-jacques'a aloisa"] = "Jean-Jacques_Alois",
    ["jeanowi-jacques'owi aloisowi"] = "Jean-Jacques_Alois",
    ["jeanem-jacques'em aloisem"] = "Jean-Jacques_Alois",
    ["jeanie-jacques'u aloisie"] = "Jean-Jacques_Alois",
    -- Erila Morvayn
    ["erila morvayn"] = "Erila_Morvayn",               -- en=pl
    ["erili morvayn"] = "Erila_Morvayn",    
    ["erilę morvayn"] = "Erila_Morvayn",     
    ["erilą morvayn"] = "Erila_Morvayn",     
    ["erilo morvayn"] = "Erila_Morvayn",   
    -- Yanabil
    ["yanabil"] = "Yanabil",               -- en=pl
    ["yanabila"] = "Yanabil",  
    ["yanabilowi"] = "Yanabil",    
    ["yanabilem"] = "Yanabil",   
    ["yanabilu"] = "Yanabil",   
    -- Herminius Andus
    ["herminius andus"] = "Herminius_Andus",               -- en=pl
    ["herminiusa andusa"] = "Herminius_Andus", 
    ["herminiusowi andusowi"] = "Herminius_Andus", 
    ["herminiusem andusem"] = "Herminius_Andus", 
    ["herminiusie andusie"] = "Herminius_Andus",
    -- Rozmawia-z-Ostrzami
    ["speaks-with-blades"] = "Speaks-with-Blades",       -- en=pl
    ["rozmawia-z-ostrzami"] = "Speaks-with-Blades",
    -- Bosekus Słoneczny-Brzuch
    ["bosekus sun-belly"] = "Bosekus_Sun-Belly",                      --  en=pl
    ["bosekus słoneczny-brzuch"] = "Bosekus_Sun-Belly",  
    ["bosekusa słonecznego-brzucha"] = "Bosekus_Sun-Belly",
    ["bosekusowi słonecznemu-brzuchowi"] = "Bosekus_Sun-Belly",
    ["bosekusem słonecznym-brzuchem"] = "Bosekus_Sun-Belly",
    ["bosekusie słonecznym-brzuchu"] = "Bosekus_Sun-Belly",
    -- Vundling
    ["vundling"] = "Vundling",               -- en=pl
    ["vundlinga"] = "Vundling",  
    ["vundlingowi"] = "Vundling",    
    ["vundlingiem"] = "Vundling",  
    ["vundlingu"] = "Vundling",   
    -- Łapa niedźwiedziołaka na szczęście
    ["lucky werebear paw"] = "Lucky_Werebear_Paw",             --  en=pl
    ["łapa niedźwiedziołaka na szczęście"] = "Lucky_Werebear_Paw",
    ["łapy niedźwiedziołaka na szczęście"] = "Lucky_Werebear_Paw",
    ["łapie niedźwiedziołaka na szczęście"] = "Lucky_Werebear_Paw",
    ["łapę niedźwiedziołaka na szczęście"] = "Lucky_Werebear_Paw",
    ["łapą niedźwiedziołaka na szczęście"] = "Lucky_Werebear_Paw",
    ["łapo niedźwiedziołaka na szczęście"] = "Lucky_Werebear_Paw",
    -- Dolwinora
    ["dolwinora"] = "Dolwinora",                   -- en=pl
    ["dolwinory"] = "Dolwinora",         
    ["dolwinorze"] = "Dolwinora",    
    ["dolwinorę"] = "Dolwinora",         
    ["dolwinorą"] = "Dolwinora",         
    ["dolwinoro"] = "Dolwinora",       
    -- Książę Irnskar
    ["prince irnskar"] = "Prince_Irnskar",               --  en=pl
    ["książę irnskar"] = "Prince_Irnskar",  
    ["księcia irnskara"] = "Prince_Irnskar", 
    ["księciu irnskarowi"] = "Prince_Irnskar",   
    ["księciem irnskarem"] = "Prince_Irnskar", 
    ["księciu irnskarze"] = "Prince_Irnskar", 
    ["książę irnskarze"] = "Prince_Irnskar", 
    -- Navlos
    ["navlos"] = "Navlos",                   -- en=pl
    ["navlosa"] = "Navlos",
    ["navlosowi"] = "Navlos",        
    ["navlosem"] = "Navlos",       
    ["navlosie"] = "Navlos",      
    -- Neeti-Ra
    ["neeti-ra"] = "Neeti-Ra",               -- en=pl
    ["neeti-ry"] = "Neeti-Ra",     
    ["neeti-rze"] = "Neeti-Ra",
    ["neeti-rę"] = "Neeti-Ra",     
    ["neeti-rą"] = "Neeti-Ra",     
    ["neeti-ro"] = "Neeti-Ra",   
    -- Dowódca Devry
    ["commander devry"] = "Commander_Devry",               --  en=pl
    ["dowódca devry"] = "Commander_Devry",    
    ["dowódcy devry'ego"] = "Commander_Devry", 
    ["dowódcy devry'emu"] = "Commander_Devry",     
    ["dowódcą devrym"] = "Commander_Devry",      
    ["dowódcy devrym"] = "Commander_Devry",     
    ["dowódco devry"] = "Commander_Devry",     
    -- Icarian
    ["icarian"] = "Icarian",                   -- en=pl
    ["icariana"] = "Icarian",
    ["icarianowi"] = "Icarian",        
    ["icarianem"] = "Icarian",       
    ["icarianie"] = "Icarian",      
    -- Lassen Dorvayn
    ["lassen dorvayn"] = "Lassen_Dorvayn",             -- en=pl
    ["lassena dorvayna"] = "Lassen_Dorvayn",
    ["lassenowi dorvaynowi"] = "Lassen_Dorvayn",
    ["lassenem dorvaynem"] = "Lassen_Dorvayn",        
    ["lassenie dorvaynie"] = "Lassen_Dorvayn",        
    -- Sylvian Herius
    ["sylvian herius"] = "Sylvian_Herius",                 -- en=pl
    ["sylviana heriusa"] = "Sylvian_Herius",   
    ["sylvianowi heriusowi"] = "Sylvian_Herius",   
    ["sylvianem heriusem"] = "Sylvian_Herius",   
    ["sylvianie heriusie"] = "Sylvian_Herius",  
    -- Eeze of the Creeping Dusk
    ["eeze of the creeping dusk"] = "Eeze_of_the_Creeping_Dusk",     -- Oryginał
    ["eeze pełzającego zmroku"] = "Eeze_of_the_Creeping_Dusk", 
    -- Kapłan Zakhal
    ["priest zakhal"] = "Priest_Zakhal",                 --  en=pl (Klucz z bazy)
    ["kapłan zakhal"] = "Priest_Zakhal",    
    ["kapłana zakhala"] = "Priest_Zakhal",   
    ["kapłanowi zakhalowi"] = "Priest_Zakhal",   
    ["kapłanem zakhalem"] = "Priest_Zakhal",   
    ["kapłanie zakhalu"] = "Priest_Zakhal",   
    -- Varallion
    ["varallion"] = "Varallion",
    ["varalliona"] = "Varallion",
    ["varallionowi"] = "Varallion",  
    ["varallionem"] = "Varallion", 
    ["varallionie"] = "Varallion",
    -- Helna
    ["helna"] = "Helna",                     --  en=pl, Mianownik
    ["helny"] = "Helna",           
    ["helnie"] = "Helna",      
    ["helnę"] = "Helna",           
    ["helną"] = "Helna",           
    ["helno"] = "Helna",         
    -- Szeregowa Oiarah
    ["private oiarah"] = "Private_Oiarah",	-- en=pl
    ["szeregowa oiarah"] = "Private_Oiarah",
    ["szeregowej oiarah"] = "Private_Oiarah", 
    ["szeregową oiarah"] = "Private_Oiarah", 
    -- Lord Vurlop
    ["lord vurlop"] = "Lord_Vurlop",  	-- en=pl
    ["lorda vurlopa"] = "Lord_Vurlop",   
    ["lordowi vurlopowi"] = "Lord_Vurlop",   
    ["lordem vurlopem"] = "Lord_Vurlop",   
    ["lordzie vurlopie"] = "Lord_Vurlop", 
    -- Vorsholazh Kowadło
    ["vorsholazh the anvil"] = "Vorsholazh_the_Anvil",           -- en=pl (Klucz)
    ["vorsholazh kowadło"] = "Vorsholazh_the_Anvil",
    ["vorsholazha kowadła"] = "Vorsholazh_the_Anvil",  
    ["vorsholazhowi kowadłu"] = "Vorsholazh_the_Anvil",  
    ["vorsholazha kowadło"] = "Vorsholazh_the_Anvil",  
    ["vorsholazhem kowadłem"] = "Vorsholazh_the_Anvil",
    ["vorsholazhu kowadle"] = "Vorsholazh_the_Anvil", 
    ["vorsholazhu kowadło"] = "Vorsholazh_the_Anvil",
    -- Isara Fralinie
    ["isara fralinie"] = "Isara_Fralinie",	-- en=pl
    ["isary fralinie"] = "Isara_Fralinie",     
    ["isarze fralinie"] = "Isara_Fralinie",
    ["isarę fralinie"] = "Isara_Fralinie",     
    ["isarą fralinie"] = "Isara_Fralinie",     
    ["isaro fralinie"] = "Isara_Fralinie",   
    -- Tan Oda Wilcza-Siostra
    ["thane oda wolf-sister"] = "Thane_Oda_Wolf-Sister",	-- en=pl
    ["tan oda wilcza-siostra"] = "Thane_Oda_Wolf-Sister", 
    ["tan ody wilczej-siostry"] = "Thane_Oda_Wolf-Sister",   
    ["tan odzie wilczej-siostrze"] = "Thane_Oda_Wolf-Sister",
    ["tan odę wilczą-siostrę"] = "Thane_Oda_Wolf-Sister",    
    ["tan odą wilczą-siostrą"] = "Thane_Oda_Wolf-Sister",    
    ["tan odo wilcza-siostro"] = "Thane_Oda_Wolf-Sister",  
    -- Azartah
    ["azartah"] = "Azartah",  	-- en=pl
    -- Sebazi
    ["sebazi"] = "Sebazi",    	-- en=pl
    -- Krwawy Łowca Hranach
    ["blood-hunter hranach"] = "Blood-Hunter_Hranach",
    ["krwawy łowca hranach"] = "Blood-Hunter_Hranach",
    ["krwawego łowcy hranacha"] = "Blood-Hunter_Hranach",
    ["krwawemu łowcy hranachowi"] = "Blood-Hunter_Hranach",
    ["krwawego łowcę hranacha"] = "Blood-Hunter_Hranach",
    ["krwawym łowcą hranachem"] = "Blood-Hunter_Hranach",
    ["krwawym łowcy hranachu"] = "Blood-Hunter_Hranach",
    ["krwawy łowco hranachu"] = "Blood-Hunter_Hranach",
	-- Magarakh
    ["magarakh"] = "Magarakh",	-- en=pl
    ["aelwin favraud"] = "Aelwin_Favraud",	-- en=pl
    -- Netelyas
	["netelyas"] = "Netelyas",	-- en=pl
    -- Domitia Catullus
	["domitia catullus"] = "Domitia_Catullus",
	["domitii catullus"] = "Domitia_Catullus",
	["domitii catullus"] = "Domitia_Catullus",
	["domitię catullus"] = "Domitia_Catullus",
	["domitią catullus"] = "Domitia_Catullus",
	["domitii catullus"] = "Domitia_Catullus",
	["domitio catullus"] = "Domitia_Catullus",
    -- Yllolda
	["yllolda"] = "Yllolda",
	["ylloldy"] = "Yllolda",
	["ylloldzie"] = "Yllolda",
	["ylloldę"] = "Yllolda",
	["ylloldą"] = "Yllolda",
	["ylloldzie"] = "Yllolda",
	["ylloldo"] = "Yllolda",
    -- Dro-Dara
	["dro-dara"] = "Dro-Dara",
	["dro-dary"] = "Dro-Dara",
	["dro-darze"] = "Dro-Dara",
	["dro-darę"] = "Dro-Dara",
	["dro-darą"] = "Dro-Dara",
	["dro-darze"] = "Dro-Dara",
	["dro-daro"] = "Dro-Dara",
    -- Jyrwinn
	["jyrwinn"] = "Jyrwinn",	-- en=pl
    -- Bahara
	["bahara"] = "Bahara",
	["bahary"] = "Bahara",
	["baharze"] = "Bahara",
	["baharę"] = "Bahara",
	["baharą"] = "Bahara",
	["baharze"] = "Bahara",
	["baharo"] = "Bahara",
    -- Drathus Othral
	["drathus othral"] = "Drathus_Othral",
	["drathusa othrala"] = "Drathus_Othral",
	["drathusowi othralowi"] = "Drathus_Othral",
	["drathusa othrala"] = "Drathus_Othral",
	["drathusem othralem"] = "Drathus_Othral",
	["drathusie othralu"] = "Drathus_Othral",
	["drathusie othralu"] = "Drathus_Othral",
    -- Esteltin
	["esteltin"] = "Esteltin",
	["esteltina"] = "Esteltin",
	["esteltinowi"] = "Esteltin",
	["esteltina"] = "Esteltin",
	["esteltinem"] = "Esteltin",
	["esteltinie"] = "Esteltin",
	["esteltinie"] = "Esteltin",  
    -- Drovos Nelvayn
	["drovos nelvayn"] = "Drovos_Nelvayn",
	["drovosa nelvayna"] = "Drovos_Nelvayn",
	["drovosowi nelvaynowi"] = "Drovos_Nelvayn",
	["drovosa nelvayna"] = "Drovos_Nelvayn",
	["drovosem nelvaynem"] = "Drovos_Nelvayn",
	["drovosie nelvaynie"] = "Drovos_Nelvayn",
	["drovosie nelvaynie"] = "Drovos_Nelvayn",
    -- Annia Sisenna
	["annia sisenna"] = "Annia_Sisenna",
	["annii sisenny"] = "Annia_Sisenna",
	["annii sisennie"] = "Annia_Sisenna",
	["annię sisennę"] = "Annia_Sisenna",
	["annią sisenną"] = "Annia_Sisenna",
	["annii sisennie"] = "Annia_Sisenna",
	["annio sisenno"] = "Annia_Sisenna",
    -- Leśny Wilk
	["timberwolf"] = "Timberwolf",
	["leśny wilk"] = "Timberwolf",
	["leśnego wilka"] = "Timberwolf",
	["leśnemu wilkowi"] = "Timberwolf",
	["leśnym wilkiem"] = "Timberwolf",
	["leśnym wilku"] = "Timberwolf",
	["leśny wilku"] = "Timberwolf",
    -- Mal Sorra
	["mal sorra"] = "Mal_Sorra",
	["mal sorry"] = "Mal_Sorra",
	["mal sorze"] = "Mal_Sorra",
	["mal sorrę"] = "Mal_Sorra",
	["mal sorrą"] = "Mal_Sorra",
	["mal sorze"] = "Mal_Sorra",
	["mal sorro"] = "Mal_Sorra",
    -- Porucznik Lepida
	["lieutenant lepida"] = "Lieutenant_Lepida",
	["porucznik lepida"] = "Lieutenant_Lepida",
	["porucznik lepidy"] = "Lieutenant_Lepida",
	["porucznik lepidzie"] = "Lieutenant_Lepida",
	["porucznik lepidę"] = "Lieutenant_Lepida",
	["porucznik lepidą"] = "Lieutenant_Lepida",
	["porucznik lepidzie"] = "Lieutenant_Lepida",
	["porucznik lepido"] = "Lieutenant_Lepida",
    -- Norendo
	["norendo"] = "Norendo_(Auridon)",
	["norenda"] = "Norendo_(Auridon)",
	["norendowi"] = "Norendo_(Auridon)",
	["norenda"] = "Norendo_(Auridon)",
	["norendem"] = "Norendo_(Auridon)",
	["norendzie"] = "Norendo_(Auridon)",
	["norendo"] = "Norendo_(Auridon)",
    -- Hojard
	["hojard"] = "Hojard",
	["hojarda"] = "Hojard",
	["hojardowi"] = "Hojard",
	["hojarda"] = "Hojard",
	["hojardem"] = "Hojard",
	["hojardzie"] = "Hojard",
	["hojardzie"] = "Hojard",
    -- Archiwista Ernarde
	["archivist ernarde"] = "Archivist_Ernarde",
	["archiwista ernarde"] = "Archivist_Ernarde",
	["archiwisty ernarde'a"] = "Archivist_Ernarde",
	["archiwiście ernarde'owi"] = "Archivist_Ernarde",
	["archiwistę ernarde'a"] = "Archivist_Ernarde",
	["archiwistą ernarde'em"] = "Archivist_Ernarde",
	["archiwiście ernardzie"] = "Archivist_Ernarde",
	["archiwisto ernarde"] = "Archivist_Ernarde",
    -- Sinmur
	["sinmur"] = "Sinmur",
	["sinmura"] = "Sinmur",
	["sinmurowi"] = "Sinmur",
	["sinmura"] = "Sinmur",
	["sinmurem"] = "Sinmur",
	["sinmurze"] = "Sinmur",
	["sinmurze"] = "Sinmur",
    -- Mari Indoren
	["mari indoren"] = "Mari_Indoren",	-- en=pl
    -- Odei Philippe
	["odei philippe"] = "Odei_Philippe",
	["odeia philippe'a"] = "Odei_Philippe",
	["odeiowi philippe'owi"] = "Odei_Philippe",
	["odeia philippe'a"] = "Odei_Philippe",
	["odeiem philippe'em"] = "Odei_Philippe",
	["odeiu philippie"] = "Odei_Philippe",
	["odeiu philippe"] = "Odei_Philippe",
    -- Anslettar
	["anslettar"] = "Anslettar",
	["anslettara"] = "Anslettar",
	["anslettarowi"] = "Anslettar",
	["anslettara"] = "Anslettar",
	["anslettarem"] = "Anslettar",
	["anslettarze"] = "Anslettar",
	["anslettarze"] = "Anslettar",
    -- Baxold
	["baxold"] = "Baxold",
	["baxolda"] = "Baxold",
	["baxoldowi"] = "Baxold",
	["baxolda"] = "Baxold",
	["baxoldem"] = "Baxold",
	["baxoldzie"] = "Baxold",
	["baxoldzie"] = "Baxold",
    -- Ilildorian
	["ilildorian"] = "Ilildorian",
	["ilildoriana"] = "Ilildorian",
	["ilildorianowi"] = "Ilildorian",
	["ilildoriana"] = "Ilildorian",
	["ilildorianem"] = "Ilildorian",
	["ilildorianie"] = "Ilildorian",
	["ilildorianie"] = "Ilildorian",
    -- Helonel
	["helonel"] = "Helonel",
	["helonela"] = "Helonel",
	["helonelowi"] = "Helonel",
	["helonela"] = "Helonel",
	["helonelem"] = "Helonel",
	["helonelu"] = "Helonel",
	["helonelu"] = "Helonel",
	-- Engitaale
	["engitaale"] = "Engitaale",	-- en=pl
    -- Storbarda
	["storbarda"] = "Storbarda",
	["storbardy"] = "Storbarda",
	["storbardzie"] = "Storbarda",
	["storbardę"] = "Storbarda",
	["storbardą"] = "Storbarda",
	["storbardzie"] = "Storbarda",
	["storbardo"] = "Storbarda",
    -- Lamae Bal
	["lamae bal"] = "Lamae_Bal",	-- en=pl
    -- Uśmiecha-Się-z-Nożem
	["smiles-with-knife"] = "Smiles-With-Knife",
	["uśmiecha-się-z-nożem"] = "Smiles-With-Knife",
    -- Generał Endare
	["general endare"] = "General_Endare",
	["generał endare"] = "General_Endare",
    -- Vaereid
	["vaereid"] = "Vaereid",	-- en=pl
    -- Balorgh
	["balorgh"] = "Balorgh",
	["balorgha"] = "Balorgh",
	["balorghowi"] = "Balorgh",
	["balorgha"] = "Balorgh",
	["balorghem"] = "Balorgh",
	["balorghu"] = "Balorgh",
	["balorghu"] = "Balorgh",
    -- Brea Śnieżny-Jeździec
	["brea snowrider"] = "Brea_Snowrider",
	["brea śnieżny-jeździec"] = "Brea_Snowrider",
	["brei śnieżny-jeździec"] = "Brea_Snowrider",
	["breę śnieżny-jeździec"] = "Brea_Snowrider",
	["breą śnieżny-jeździec"] = "Brea_Snowrider",
	["breo śnieżny-jeździec"] = "Brea_Snowrider",
    -- Kapitan Juras
	["captain juras"] = "Captain_Juras",
	["kapitan juras"] = "Captain_Juras",
	["kapitana jurasa"] = "Captain_Juras",
	["kapitanowi jurasowi"] = "Captain_Juras",
	["kapitana jurasa"] = "Captain_Juras",
	["kapitanem jurasem"] = "Captain_Juras",
	["kapitanie jurasie"] = "Captain_Juras",
	["kapitanie jurasie"] = "Captain_Juras",
    -- Xal-Sisei
	["xal-sisei"] = "Xal-Sisei",	-- en=pl
    -- Mursold
	["mursold"] = "Mursold",
	["mursolda"] = "Mursold",
	["mursoldowi"] = "Mursold",
	["mursolda"] = "Mursold",
	["mursoldem"] = "Mursold",
	["mursoldzie"] = "Mursold",
	["mursoldzie"] = "Mursold",
    -- Reynir Niszczyciel
	["reynir the destroyer"] = "Reynir_the_Destroyer",
	["reynir niszczyciel"] = "Reynir_the_Destroyer",
	["reynira niszczyciela"] = "Reynir_the_Destroyer",
	["reynirowi niszczycielowi"] = "Reynir_the_Destroyer",
	["reynira niszczyciela"] = "Reynir_the_Destroyer",
	["reynirem niszczycielem"] = "Reynir_the_Destroyer",
	["reynirze niszczycielu"] = "Reynir_the_Destroyer",
	["reynirze niszczycielu"] = "Reynir_the_Destroyer",
    -- Dagrund Barczysty
	["dagrund the bulky"] = "Dagrund_the_Bulky",
	["dagrund barczysty"] = "Dagrund_the_Bulky",
	["dagrunda barczystego"] = "Dagrund_the_Bulky",
	["dagrundowi barczystemu"] = "Dagrund_the_Bulky",
	["dagrunda barczystego"] = "Dagrund_the_Bulky",
	["dagrundem barczystym"] = "Dagrund_the_Bulky",
	["dagrundzie barczystym"] = "Dagrund_the_Bulky",
	["dagrundzie barczysty"] = "Dagrund_the_Bulky",
    -- Baenelros
	["baenelros"] = "Baenelros",
	["baenelrosa"] = "Baenelros",
	["baenelrosowi"] = "Baenelros",
	["baenelrosa"] = "Baenelros",
	["baenelrosem"] = "Baenelros",
	["baenelrosie"] = "Baenelros",
	["baenelrosie"] = "Baenelros",
    -- Halronion
	["halronion"] = "Halronion",
	["halroniona"] = "Halronion",
	["halronionowi"] = "Halronion",
	["halroniona"] = "Halronion",
	["halronionem"] = "Halronion",
	["halronionie"] = "Halronion",
	["halronionie"] = "Halronion",
    -- Selenu
	["selenu"] = "Selenu_(postać)",	-- en=pl
	["selenu (postać)"] = "Selenu_(postać)",
    -- Aemilia Hadrianus
	["aemilia hadrianus"] = "Aemilia_Hadrianus",
	["aemilii hadrianus"] = "Aemilia_Hadrianus",
	["aemilię hadrianus"] = "Aemilia_Hadrianus",
	["aemilią hadrianus"] = "Aemilia_Hadrianus",
	["aemilio hadrianus"] = "Aemilia_Hadrianus",
    -- Skulreid Lisogryz
	["skulreid foxbite"] = "Skulreid_Foxbite",
	["skulreid lisogryz"] = "Skulreid_Foxbite",
	["skulreida lisogryza"] = "Skulreid_Foxbite",
	["skulreidowi lisogryzowi"] = "Skulreid_Foxbite",
	["skulreidem lisogryzem"] = "Skulreid_Foxbite",
	["skulreidzie lisogryzie"] = "Skulreid_Foxbite",
    -- Svarkjar Zguba-Gigantów
	["svarkjar giants-bane"] = "Svarkjar_Giants-Bane",
	["svarkjar zguba-gigantów"] = "Svarkjar_Giants-Bane",
	["svarkjara zguby-gigantów"] = "Svarkjar_Giants-Bane",
	["svarkjarowi zgubie-gigantów"] = "Svarkjar_Giants-Bane",
	["svarkjara zgubę-gigantów"] = "Svarkjar_Giants-Bane",
	["svarkjarem zgubą-gigantów"] = "Svarkjar_Giants-Bane",
	["svarkjarze zgubie-gigantów"] = "Svarkjar_Giants-Bane",
	["svarkjarze zgubo-gigantów"] = "Svarkjar_Giants-Bane",
    -- Veek-Gai Złoty-Ogon
	["veek-gai gold-tail"] = "Veek-Gai_Gold-Tail",
	["veek-gai złoty-ogon"] = "Veek-Gai_Gold-Tail", 
    -- Thodundor ze Wzgórza
	["thodundor of the hill"] = "Thodundor_of_the_Hill",
	["thodundor ze wzgórza"] = "Thodundor_of_the_Hill",
	["thodundora ze wzgórza"] = "Thodundor_of_the_Hill",
	["thodundorowi ze wzgórza"] = "Thodundor_of_the_Hill",
	["thodundorem ze wzgórza"] = "Thodundor_of_the_Hill",
	["thodundorze ze wzgórza"] = "Thodundor_of_the_Hill",
    -- Klovag
	["klovag"] = "Klovag",
	["klovaga"] = "Klovag",
	["klovagowi"] = "Klovag",
	["klovagiem"] = "Klovag",
	["klovagu"] = "Klovag",
    -- Admaer
	["admaer"] = "Admaer",
	["admaera"] = "Admaer",
	["admaerowi"] = "Admaer",
	["admaerem"] = "Admaer",
	["admaerze"] = "Admaer",
    -- Doshia
	["doshia"] = "Doshia",
	["doshii"] = "Doshia",
	["doshię"] = "Doshia",
	["doshią"] = "Doshia",
	["doshio"] = "Doshia",
    -- Riidras Avani
	["riidras avani"] = "Riidras_Avani",
	["riidrasa avani"] = "Riidras_Avani",
	["riidrasowi avani"] = "Riidras_Avani",
	["riidrasem avani"] = "Riidras_Avani",
	["riidrasie avani"] = "Riidras_Avani",
    -- Birin Bellec
	["birin bellec"] = "Birin_Bellec",
	["birina belleca"] = "Birin_Bellec",
	["birinowi bellecowi"] = "Birin_Bellec",
	["birinem bellekiem"] = "Birin_Bellec",
	["birinie bellecu"] = "Birin_Bellec",
    -- Flora Laftrius
	["flora laftrius"] = "Flora_Laftrius",
	["flory laftrius"] = "Flora_Laftrius",
	["florze laftrius"] = "Flora_Laftrius",
	["florę laftrius"] = "Flora_Laftrius",
	["florą laftrius"] = "Flora_Laftrius",
	["floro laftrius"] = "Flora_Laftrius",
    -- Gamyne Bandu
	-- Wykluczenie
    ["gamyne"] = { 
        key = "Gamyne", 
        excluded = { "gamyne bandu" } 
    },
    -- Na'ruzz Tkacz Kości
	["na'ruzz the boneweaver"] = "Na'ruzz_Tkacz_Kości",
	["na'ruzz tkacz kości"] = "Na'ruzz_Tkacz_Kości",
	["na'ruzza tkacza kości"] = "Na'ruzz_Tkacz_Kości",
	["na'ruzzowi tkaczowi kości"] = "Na'ruzz_Tkacz_Kości",
	["na'ruzzem tkaczem kości"] = "Na'ruzz_Tkacz_Kości",
	["na'ruzzie tkaczu kości"] = "Na'ruzz_Tkacz_Kości",
    -- Aldarch Wuufren
	["aldarch wuufren"] = "Aldarch_Wuufren",
	["aldarcha wuufrena"] = "Aldarch_Wuufren",
	["aldarchowi wuufrenowi"] = "Aldarch_Wuufren",
	["aldarchem wuufrenem"] = "Aldarch_Wuufren",
	["aldarchu wuufrenie"] = "Aldarch_Wuufren",
    -- Heknorr
	["heknorr"] = "Heknorr",
	["heknorra"] = "Heknorr",
	["heknorrowi"] = "Heknorr",
	["heknorrem"] = "Heknorr",
	["heknorze"] = "Heknorr",
    -- General Yeveth Noramil
	["general yeveth noramil"] = "General_Yeveth_Noramil",
	["generał yeveth noramil"] = "General_Yeveth_Noramil",
	["generała yevetha noramila"] = "General_Yeveth_Noramil",
	["generałowi yevethowi noramilowi"] = "General_Yeveth_Noramil",
	["generałem yevethem noramilem"] = "General_Yeveth_Noramil",
	["generale yevecie noramilu"] = "General_Yeveth_Noramil",
    -- Conol
	["conol"] = "Conol",
	["conola"] = "Conol",
	["conolowi"] = "Conol",
	["conolem"] = "Conol",
	["conolu"] = "Conol",
    -- Mozgosh
	["mozgosh"] = "Mozgosh",
	["mozgosha"] = "Mozgosh",
	["mozgoshowi"] = "Mozgosh",
	["mozgoshem"] = "Mozgosh",
	["mozgoshu"] = "Mozgosh",
    -- Njorfar the Gossip
	["njorfar the gossip"] = "Njorfar_the_Gossip",
	["njorfar plotkarz"] = "Njorfar_the_Gossip",
	["njorfara plotkarza"] = "Njorfar_the_Gossip",
	["njorfarowi plotkarzowi"] = "Njorfar_the_Gossip",
	["njorfarem plotkarzem"] = "Njorfar_the_Gossip",
	["njorfarze plotkarzu"] = "Njorfar_the_Gossip",
    -- Talsgryr
	["talsgryr"] = "Talsgryr",
	["talsgryra"] = "Talsgryr",
	["talsgryrowi"] = "Talsgryr",
	["talsgryrem"] = "Talsgryr",
	["talsgryrze"] = "Talsgryr",
    -- Eljhan
	["eljhan"] = "Eljhan",
	["eljhana"] = "Eljhan",
	["eljhanowi"] = "Eljhan",
	["eljhanem"] = "Eljhan",
	["eljhanie"] = "Eljhan",
    -- Deowyn
	["deowyn"] = "Deowyn",   
    -- Eludin the Cannibal King
	["eludin the cannibal king"] = "Eludin_the_Cannibal_King",
	["eludin król kanibali"] = "Eludin_the_Cannibal_King",
	["eludina króla kanibali"] = "Eludin_the_Cannibal_King",
	["eludinowi królowi kanibali"] = "Eludin_the_Cannibal_King",
	["eludinem królem kanibali"] = "Eludin_the_Cannibal_King",
	["eludinie królu kanibali"] = "Eludin_the_Cannibal_King",
    -- Alvila
	["alvila"] = "Alvila",
	["alvili"] = "Alvila",
	["alvilę"] = "Alvila",
	["alvilą"] = "Alvila",
	["alvilo"] = "Alvila",
    -- Irthor
	["irthor"] = "Irthor",
	["irthora"] = "Irthor",
	["irthorowi"] = "Irthor",
	["irthorem"] = "Irthor",
	["irthorze"] = "Irthor",
    -- Akrah
	["akrah"] = "Akrah",
	["akraha"] = "Akrah",
	["akrahowi"] = "Akrah",
	["akrahem"] = "Akrah",
	["akrahu"] = "Akrah",
    -- Leonique Gelves
	["leonique gelves"] = "Leonique_Gelves",
    -- Gorbarth
	["gorbarth"] = "Gorbarth",
	["gorbartha"] = "Gorbarth",
	["gorbarthowi"] = "Gorbarth",
	["gorbarthem"] = "Gorbarth",
	["gorbarthu"] = "Gorbarth",
    -- Tumande
	["tumande"] = "Tumande",
	["tumandego"] = "Tumande",
	["tumandemu"] = "Tumande",
	["tumandem"] = "Tumande",
    -- Tazkad (Lider/Przewodnik Stada)
	["tazkad the packmaster"] = "Tazkad_Lider_Stada",
	["tazkad lider stada"] = "Tazkad_Lider_Stada",
	["tazkada lidera stada"] = "Tazkad_Lider_Stada",
	["tazkadowi liderowi stada"] = "Tazkad_Lider_Stada",
	["tazkadem liderem stada"] = "Tazkad_Lider_Stada",
	["tazkadzie liderze stada"] = "Tazkad_Lider_Stada",
	["tazkad przewodnik stada"] = "Tazkad_Lider_Stada",
	["tazkada przewodnika stada"] = "Tazkad_Lider_Stada",
	["tazkadowi przewodnikowi stada"] = "Tazkad_Lider_Stada",
	["tazkadem przewodnikiem stada"] = "Tazkad_Lider_Stada",
	["tazkadzie przewodniku stada"] = "Tazkad_Lider_Stada",
    -- Harik Bearfang
	["harik bearfang"] = "Harik_Bearfang",
	["harik niedźwiedzi kieł"] = "Harik_Bearfang",
	["harika niedźwiedziego kła"] = "Harik_Bearfang",
	["harikowi niedźwiedziemu kłu"] = "Harik_Bearfang",
	["harikiem niedźwiedzim kłem"] = "Harik_Bearfang",
	["hariku niedźwiedzim kle"] = "Harik_Bearfang",
    -- Rilis XII
	["rilis xii"] = "Rilis_XII",
	["rilisa xii"] = "Rilis_XII",
	["rilisowi xii"] = "Rilis_XII",
	["rilisem xii"] = "Rilis_XII",
	["rilisie xii"] = "Rilis_XII",
    -- Dhalen
	["dhalen"] = "Dhalen",
	["dhalena"] = "Dhalen",
	["dhalenowi"] = "Dhalen",
	["dhalenem"] = "Dhalen",
	["dhalenie"] = "Dhalen",
    -- Arienne Kerbol
	["arienne kerbol"] = "Arienne_Kerbol",
    -- Callan
	["callan"] = "Callan",
	["callana"] = "Callan",
	["callanowi"] = "Callan",
	["callanem"] = "Callan",
	["callanie"] = "Callan",
    -- Viellia Harmevus
	["viellia harmevus"] = "Viellia_Harmevus",
	["viellii harmevus"] = "Viellia_Harmevus",
	["viellię harmevus"] = "Viellia_Harmevus",
	["viellią harmevus"] = "Viellia_Harmevus",
	["viellio harmevus"] = "Viellia_Harmevus",
    -- Ysolmarr the Roving Pyre
	["ysolmarr the roving pyre"] = "Ysolmarr_the_Roving_Pyre",
	["ysolmarr wędrujący stos"] = "Ysolmarr_the_Roving_Pyre",
	["ysolmarra wędrującego stosu"] = "Ysolmarr_the_Roving_Pyre",
	["ysolmarrowi wędrującemu stosowi"] = "Ysolmarr_the_Roving_Pyre",
	["ysolmarrem wędrującym stosem"] = "Ysolmarr_the_Roving_Pyre",
	["ysolmarrze wędrującym stosie"] = "Ysolmarr_the_Roving_Pyre",
    -- Rinweril
	["rinweril"] = "Rinweril",
    -- Aldolin
	["aldolin"] = "Aldolin",
	["aldolina"] = "Aldolin",
	["aldolinowi"] = "Aldolin",
	["aldolinem"] = "Aldolin",
	["aldolinie"] = "Aldolin",
    -- Swift-Tail
	["swift-tail"] = "Swift-Tail",
	["zwiewny-ogon"] = "Swift-Tail",
	["zwiewnego-ogona"] = "Swift-Tail",
	["zwiewnemu-ogonowi"] = "Swift-Tail",
	["zwiewnym-ogonem"] = "Swift-Tail",
	["zwiewnym-ogonie"] = "Swift-Tail",
    -- Ilwen
	["ilwen"] = "Ilwen",
	["ilwena"] = "Ilwen",
	["ilwenowi"] = "Ilwen",
	["ilwenem"] = "Ilwen",
	["ilwenie"] = "Ilwen",
    -- Lord Falgravn
	["lord falgravn"] = "Lord_Falgravn",
	["lorda falgravna"] = "Lord_Falgravn",
	["lordowi falgravnowi"] = "Lord_Falgravn",
	["lordem falgravnem"] = "Lord_Falgravn",
	["lordzie falgravnie"] = "Lord_Falgravn",
    -- Baladar
	["baladar"] = "Baladar",
	["baladara"] = "Baladar",
	["baladarowi"] = "Baladar",
	["baladarem"] = "Baladar",
	["baladarze"] = "Baladar",
    -- Ghum
	["ghum"] = "Ghum",
	["ghuma"] = "Ghum",
	["ghumowi"] = "Ghum",
	["ghumem"] = "Ghum",
	["ghumie"] = "Ghum",
    -- Eager-to-Leave
	["eager-to-leave"] = "Eager-to-Leave",
	["chętny-do-wyjścia"] = "Eager-to-Leave",
	["chętnego-do-wyjścia"] = "Eager-to-Leave",
	["chętnemu-do-wyjścia"] = "Eager-to-Leave",
	["chętnym-do-wyjścia"] = "Eager-to-Leave",
    -- Thelman
	["thelman"] = "Thelman",
	["thelmana"] = "Thelman",
	["thelmanowi"] = "Thelman",
	["thelmanem"] = "Thelman",
	["thelmanie"] = "Thelman",
    -- Valentina Sette
	["valentina sette"] = "Valentina_Sette",
	["valentiny sette"] = "Valentina_Sette",
	["valentinie sette"] = "Valentina_Sette",
	["valentinę sette"] = "Valentina_Sette",
	["valentiną sette"] = "Valentina_Sette",
	["valentino sette"] = "Valentina_Sette",
    -- Cardea Gallus
	["cardea gallus"] = "Cardea_Gallus",
	["cardei gallus"] = "Cardea_Gallus",
	["cardeę gallus"] = "Cardea_Gallus",
	["cardeą gallus"] = "Cardea_Gallus",
	["cardeo gallus"] = "Cardea_Gallus",
    -- Beldorr
	["beldorr"] = "Beldorr",
	["beldorra"] = "Beldorr",
	["beldorrowi"] = "Beldorr",
	["beldorrem"] = "Beldorr",
	["beldorrze"] = "Beldorr",  
    -- Tredare Aradil
	["tredare aradil"] = "Tredare_Aradil",
    -- Nomeg Chal
	["nomeg chal"] = "Nomeg_Chal",
	["nomega chala"] = "Nomeg_Chal",
	["nomegowi chalowi"] = "Nomeg_Chal",
	["nomegiem chalem"] = "Nomeg_Chal",
	["nomegu chalu"] = "Nomeg_Chal",
    -- Sirkralf
	["sirkralf"] = "Sirkralf",
	["sirkralfa"] = "Sirkralf",
	["sirkralfowi"] = "Sirkralf",
	["sirkralfem"] = "Sirkralf",
	["sirkralfie"] = "Sirkralf",
    -- Huri
	["huri"] = "Huri",
    -- Nordahl
	["nordahl"] = "Nordahl",
	["nordahla"] = "Nordahl",
	["nordahlowi"] = "Nordahl",
	["nordahlem"] = "Nordahl",
	["nordahlu"] = "Nordahl",
    -- Cirterisse
	["cirterisse"] = "Cirterisse",
    -- Norrareth
	["norrareth"] = "Norrareth",
    -- Arlmar
	["arlmar"] = "Arlmar",
	["arlmara"] = "Arlmar",
	["arlmarowi"] = "Arlmar",
	["arlmarem"] = "Arlmar",
	["arlmarze"] = "Arlmar",
    -- Daniel Dutheil
	["daniel dutheil"] = "Daniel_Dutheil",
	["daniela dutheila"] = "Daniel_Dutheil",
	["danielowi dutheilowi"] = "Daniel_Dutheil",
	["danielem dutheilem"] = "Daniel_Dutheil",
	["danielu dutheilu"] = "Daniel_Dutheil",
    -- Nojaxia
	["nojaxia"] = "Nojaxia",
	["nojaxii"] = "Nojaxia",
	["nojaxię"] = "Nojaxia",
	["nojaxią"] = "Nojaxia",
	["nojaxio"] = "Nojaxia",
    -- Gekurek
	["gekurek"] = "Gekurek",
	["gekurka"] = "Gekurek",
	["gekurkowi"] = "Gekurek",
	["gekurkiem"] = "Gekurek",
	["gekurku"] = "Gekurek",
    -- Arlof
	["arlof"] = "Arlof",
	["arlofa"] = "Arlof",
	["arlofowi"] = "Arlof",
	["arlofem"] = "Arlof",
	["arlofie"] = "Arlof",
    -- Skull-Sister Bravora
	["skull-sister bravora"] = "Skull-Sister_Bravora",
	["siostra czaszki bravora"] = "Skull-Sister_Bravora",
	["siostry czaszki bravory"] = "Skull-Sister_Bravora",
	["siostrze czaszki bravorze"] = "Skull-Sister_Bravora",
	["siostrę czaszki bravorę"] = "Skull-Sister_Bravora",
	["siostrą czaszki bravorą"] = "Skull-Sister_Bravora",
	["siostro czaszki bravoro"] = "Skull-Sister_Bravora",
    -- Shagura
	["shagura"] = "Shagura",
	["shagury"] = "Shagura",
	["shagurze"] = "Shagura",
	["shagurę"] = "Shagura",
	["shagurą"] = "Shagura",
	["shaguro"] = "Shagura",
    -- Asiah
	["asiah"] = "Asiah",
    -- Nafobia
	["nafobia"] = "Nafobia",
	["nafobii"] = "Nafobia",
	["nafobię"] = "Nafobia",
	["nafobią"] = "Nafobia",
	["nafobio"] = "Nafobia",
    -- Ukha
	["ukha"] = "Ukha",
	["ukhy"] = "Ukha",
	["usze"] = "Ukha",
	["ukhę"] = "Ukha",
	["ukhą"] = "Ukha",
	["ukho"] = "Ukha",
    -- Goldyn Dalvani
	["goldyn dalvani"] = "Goldyn_Dalvani",
	["goldyna dalvaniego"] = "Goldyn_Dalvani",
	["goldynowi dalvaniemu"] = "Goldyn_Dalvani",
	["goldynem dalvanim"] = "Goldyn_Dalvani",
	["goldynie dalvanim"] = "Goldyn_Dalvani",
    -- Ylsi
	["ylsi"] = "Ylsi",
    -- Drisoal
	["drisoal"] = "Drisoal",
	["drisoala"] = "Drisoal",
	["drisoalowi"] = "Drisoal",
	["drisoalem"] = "Drisoal",
	["drisoalu"] = "Drisoal",
    -- Methas Andavel
	["methas andavel"] = "Methas_Andavel",
	["methasa andavela"] = "Methas_Andavel",
	["methasowi andavelowi"] = "Methas_Andavel",
	["methasem andavelem"] = "Methas_Andavel",
	["methasie andavelu"] = "Methas_Andavel",
    -- Rhea
	["rhea"] = "Rhea",
	["rhei"] = "Rhea",
	["rheę"] = "Rhea",
	["rheą"] = "Rhea",
	["rheo"] = "Rhea",
    -- Gorgath Deadeye
	["gorgath deadeye"] = "Gorgath_Deadeye",
	["gorhath strzelec wyborowy"] = "Gorgath_Deadeye",
	["gorhatha strzelca wyborowego"] = "Gorgath_Deadeye",
	["gorhathowi strzelcowi wyborowemu"] = "Gorgath_Deadeye",
	["gorhathem strzelcem wyborowym"] = "Gorgath_Deadeye",
	["gorhathu strzelcu wyborowym"] = "Gorgath_Deadeye",
    -- Knudvarr
	["knudvarr"] = "Knudvarr",
	["knudvarra"] = "Knudvarr",
	["knudvarrowi"] = "Knudvarr",
	["knudvarrem"] = "Knudvarr",
	["knudvarrze"] = "Knudvarr",
    -- Helene Danise
	["helene danise"] = "Helene_Danise",
    -- Malkur Valos
	["malkur valos"] = "Malkur_Valos",
	["malkura valosa"] = "Malkur_Valos",
	["malkurowi valosowi"] = "Malkur_Valos",
	["malkurem valosem"] = "Malkur_Valos",
	["malkurze valosie"] = "Malkur_Valos",
    -- Anarume
	["anarume"] = "Anarume",
	["anarumego"] = "Anarume",
	["anarumemu"] = "Anarume",
	["anarumem"] = "Anarume",
    -- Sanas Hlaalu
	["sanas hlaalu"] = "Sanas_Hlaalu",
	["sanasa hlaalu"] = "Sanas_Hlaalu",
	["sanasowi hlaalu"] = "Sanas_Hlaalu",
	["sanasem hlaalu"] = "Sanas_Hlaalu",
	["sanasie hlaalu"] = "Sanas_Hlaalu",
    -- Oskana
	["oskana"] = "Oskana",
	["oskany"] = "Oskana",
	["oskanie"] = "Oskana",
	["oskanę"] = "Oskana",
	["oskaną"] = "Oskana",
	["oskano"] = "Oskana",
    -- Arentus Rian
	["arentus rian"] = "Arentus_Rian",
	["arentusa riana"] = "Arentus_Rian",
	["arentusowi rianowi"] = "Arentus_Rian",
	["arentusem rianem"] = "Arentus_Rian",
	["arentusie rianie"] = "Arentus_Rian",
    -- Earunlad
	["earunlad"] = "Earunlad",
	["earunlada"] = "Earunlad",
	["earunladowi"] = "Earunlad",
	["earunladem"] = "Earunlad",
	["earunladzie"] = "Earunlad",
    -- Aralfwe
	["aralfwe"] = "Aralfwe",
    -- Allring
	["allring"] = "Allring",
	["allringa"] = "Allring",
	["allringowi"] = "Allring",
	["allringiem"] = "Allring",
	["allringu"] = "Allring",
    -- Rogrydda
	["rogrydda"] = "Rogrydda",
	["rogryddy"] = "Rogrydda",
	["rogryddzie"] = "Rogrydda",
	["rogryddę"] = "Rogrydda",
	["rogryddą"] = "Rogrydda",
	["rogryddo"] = "Rogrydda",
    -- Hurzjhad
	["hurzjhad"] = "Hurzjhad",
	["hurzjhada"] = "Hurzjhad",
	["hurzjhadowi"] = "Hurzjhad",
	["hurzjhadem"] = "Hurzjhad",
	["hurzjhadzie"] = "Hurzjhad",
    -- Hegris the Black Dagger
	["hegris the black dagger"] = "Hegris_the_Black_Dagger",
	["hegris czarny sztylet"] = "Hegris_the_Black_Dagger",
	["hegrisa czarnego sztyletu"] = "Hegris_the_Black_Dagger",
	["hegrisowi czarnemu sztyletowi"] = "Hegris_the_Black_Dagger",
	["hegrisem czarnym sztyletem"] = "Hegris_the_Black_Dagger",
	["hegrisie czarnym sztylecie"] = "Hegris_the_Black_Dagger",
    -- Adusa-daro
	["adusa-daro"] = "Adusa-daro",
	["adusy-daro"] = "Adusa-daro",
	["adusie-daro"] = "Adusa-daro",
	["adusę-daro"] = "Adusa-daro",
	["adusą-daro"] = "Adusa-daro",
	["aduso-daro"] = "Adusa-daro",
    -- Ribazhur
	["ribazhur"] = "Ribazhur",
	["ribazhura"] = "Ribazhur",
	["ribazhurowi"] = "Ribazhur",
	["ribazhurem"] = "Ribazhur",
	["ribazhurze"] = "Ribazhur",
    -- Khamira
	["khamira"] = {
		key = "Khamira",
		excluded = {
			"Queen Khamira",
			"Królowa Khamira",
			"Ja'khajiit Khamira"
		}
	},
	["khamiry"] = "Khamira",
	["khamirze"] = "Khamira",
	["khamirę"] = "Khamira",
	["khamirą"] = "Khamira",
	["khamiro"] = "Khamira",
    -- Anjuld
	["anjuld"] = "Anjuld",
	["anjulda"] = "Anjuld",
	["anjuldowi"] = "Anjuld",
	["anjuldem"] = "Anjuld",
	["anjuldzie"] = "Anjuld",
	-- Captain Attiring
	["captain attiring"] = "Captain_Attiring",
	["kapitan attiring"] = "Captain_Attiring",
    -- Songamdir
	["songamdir"] = "Songamdir",
	["songamdira"] = "Songamdir",
	["songamdirowi"] = "Songamdir",
	["songamdirem"] = "Songamdir",
	["songamdirze"] = "Songamdir",
    -- Odvan Vilaine
	["odvan vilaine"] = "Odvan_Vilaine",
	["odvana vilaine'a"] = "Odvan_Vilaine",
	["odvanowi vilaine'owi"] = "Odvan_Vilaine",
	["odvanem vilaine'em"] = "Odvan_Vilaine",
	["odvanie vilaine'ie"] = "Odvan_Vilaine",
    -- Beagan
	["beagan"] = "Beagan",
	["beagana"] = "Beagan",
	["beaganowi"] = "Beagan",
	["beaganem"] = "Beagan",
	["beaganie"] = "Beagan",
    -- Turqualie
	["turqualie"] = "Turqualie",
    -- Ghoragham
	["ghoragham"] = "Ghoragham",
	["ghoraghama"] = "Ghoragham",
	["ghoraghamowi"] = "Ghoragham",
	["ghoraghamem"] = "Ghoragham",
	["ghoraghamie"] = "Ghoragham",
    -- Daixth
	["daixth"] = "Daixth",
	["daixtha"] = "Daixth",
	["daixthowi"] = "Daixth",
	["daixthem"] = "Daixth",
	["daixthie"] = "Daixth",
    -- Adandora
	["adandora"] = "Adandora",
	["adandory"] = "Adandora",
	["adandorze"] = "Adandora",
	["adandorę"] = "Adandora",
	["adandorą"] = "Adandora",
	["adandoro"] = "Adandora",
    -- Aracar
	["aracar"] = "Aracar",
	["aracara"] = "Aracar",
	["aracarowi"] = "Aracar",
	["aracarem"] = "Aracar",
	["aracarze"] = "Aracar",
    -- Asjaila
	["asjaila"] = "Asjaila",
	["asjaili"] = "Asjaila",
	["asjailę"] = "Asjaila",
	["asjailą"] = "Asjaila",
	["asjailo"] = "Asjaila",
    -- Littrek Earth-Turner
	["littrek earth-turner"] = "Littrek_Earth-Turner",
	["littrek oracz-ziemi"] = "Littrek_Earth-Turner",
	["littreka oracza-ziemi"] = "Littrek_Earth-Turner",
	["littrekowi oraczowi-ziemi"] = "Littrek_Earth-Turner",
	["littrekiem oraczem-ziemi"] = "Littrek_Earth-Turner",
	["littreku oraczu-ziemi"] = "Littrek_Earth-Turner",
    -- Zaman
	["zaman"] = "Zaman",
	["zamana"] = "Zaman",
	["zamanowi"] = "Zaman",
	["zamanem"] = "Zaman",
	["zamanie"] = "Zaman",
    -- Ysavild
	["ysavild"] = "Ysavild",
	["ysavilda"] = "Ysavild",
	["ysavildowi"] = "Ysavild",
	["ysavildem"] = "Ysavild",
	["ysavildzie"] = "Ysavild",
    -- Danir
	["danir"] = "Danir",
	["danira"] = "Danir",
	["danirowi"] = "Danir",
	["danirem"] = "Danir",
	["danirze"] = "Danir",
    -- Lleran Bradyn
	["lleran bradyn"] = "Lleran_Bradyn",
	["llerana bradyna"] = "Lleran_Bradyn",
	["lleranowi bradynowi"] = "Lleran_Bradyn",
	["lleranem bradynem"] = "Lleran_Bradyn",
	["lleranie bradynie"] = "Lleran_Bradyn",
    -- Bandor
	["bandor"] = "Bandor",
	["bandora"] = "Bandor",
	["bandorowi"] = "Bandor",
	["bandorem"] = "Bandor",
	["bandorze"] = "Bandor",
    -- Maheelius
	["maheelius"] = "Maheelius",
	["maheeliusa"] = "Maheelius",
	["maheeliusowi"] = "Maheelius",
	["maheeliusem"] = "Maheelius",
	["maheeliusie"] = "Maheelius",
    -- Vicecanon Heita-Meen
	["vicecanon heita-meen"] = "Vicecanon_Heita-Meen",
	["wicekanoniczka heita-meen"] = "Vicecanon_Heita-Meen",
	["wicekanoniczki heity-meen"] = "Vicecanon_Heita-Meen",
	["wicekanoniczce heicie-meen"] = "Vicecanon_Heita-Meen",
	["wicekanoniczkę heitę-meen"] = "Vicecanon_Heita-Meen",
	["wicekanoniczką heitą-meen"] = "Vicecanon_Heita-Meen",
	["wicekanoniczko heito-meen"] = "Vicecanon_Heita-Meen",
    -- Vala Davel
	["vala davel"] = "Vala_Davel",
	["vali davel"] = "Vala_Davel",
	["valę davel"] = "Vala_Davel",
	["valą davel"] = "Vala_Davel",
	["valo davel"] = "Vala_Davel",
    -- Captain Veranim
	["captain veranim"] = "Captain_Veranim",
	["kapitan veranim"] = "Captain_Veranim",
    -- Dayarrus
	["dayarrus"] = "Dayarrus",
    -- Domitius Doran
	["domitius doran"] = "Domitius_Doran",
	["domitiusa dorana"] = "Domitius_Doran",
	["domitiusowi doranowi"] = "Domitius_Doran",
	["domitiusem doranem"] = "Domitius_Doran",
	["domitiusie doranie"] = "Domitius_Doran",
    -- Queen of Three Mercies
	["queen of three mercies"] = "Queen_of_Three_Mercies",
	["królowa trzech łask"] = "Queen_of_Three_Mercies",
	["królowej trzech łask"] = "Queen_of_Three_Mercies",
	["królową trzech łask"] = "Queen_of_Three_Mercies",
	["królowo trzech łask"] = "Queen_of_Three_Mercies",
    -- Famazar
	["famazar"] = "Famazar",
	["famazara"] = "Famazar",
	["famazarowi"] = "Famazar",
	["famazarem"] = "Famazar",
	["famazarze"] = "Famazar",
    -- Hetsha
	["hetsha"] = "Hetsha",
	["hetshy"] = "Hetsha",
	["hetshę"] = "Hetsha",
	["hetshą"] = "Hetsha",
	["hetsho"] = "Hetsha",
    -- Arnyeana
	["arnyeana"] = "Arnyeana",
	["arnyeany"] = "Arnyeana",
	["arnyeanie"] = "Arnyeana",
	["arnyeanę"] = "Arnyeana",
	["arnyeaną"] = "Arnyeana",
	["arnyeano"] = "Arnyeana",
    -- Baradin
	["baradin"] = "Baradin",
	["baradina"] = "Baradin",
	["baradinowi"] = "Baradin",
	["baradinem"] = "Baradin",
	["baradinie"] = "Baradin",
    -- Giron Rii
	["giron rii"] = "Giron_Rii",
	["girona rii"] = "Giron_Rii",
	["gironowi rii"] = "Giron_Rii",
	["gironem rii"] = "Giron_Rii",
	["gironie rii"] = "Giron_Rii",
    -- Haman Forgefire
	["haman forgefire"] = "Haman_Forgefire",
	["haman ogień kuźni"] = "Haman_Forgefire",
	["hamana ognia kuźni"] = "Haman_Forgefire",
	["hamanowi ogniowi kuźni"] = "Haman_Forgefire",
	["hamanem ogniem kuźni"] = "Haman_Forgefire",
	["hamanie ogniu kuźni"] = "Haman_Forgefire",
    -- Jahlasri
	["jahlasri"] = "Jahlasri",
    -- Aelif
	["aelif"] = "Aelif",
    -- Shagrum gra-Dumba
	["shagrum gra-dumba"] = "Shagrum_gra-Dumba",
	["shagrum gra-dumby"] = "Shagrum_gra-Dumba",
	["shagrum gra-dumbie"] = "Shagrum_gra-Dumba",
	["shagrum gra-dumbę"] = "Shagrum_gra-Dumba",
	["shagrum gra-dumbą"] = "Shagrum_gra-Dumba",
	["shagrum gra-dumbo"] = "Shagrum_gra-Dumba",
    -- Magarakh
	["magarakh"] = {
		key = "Magarakh_(Nimalten)",
		excluded = {
			"Sierżant Magarakh",
			"Sergeant Magarakh",
		},
    },
	["magarakh (nimalten)"] = "Magarakh_(Nimalten)",
    -- Oiomiralewen
	["oiomiralewen"] = "Oiomiralewen",
    -- Valanir's Shield
	["valanir's shield"] = "Valanir's_Shield",
	["tarcza valanira"] = "Valanir's_Shield",
	["tarczy valanira"] = "Valanir's_Shield",
	["tarczę valanira"] = "Valanir's_Shield",
	["tarczą valanira"] = "Valanir's_Shield",
	["tarczo valanira"] = "Valanir's_Shield",
    -- Ysgramor
	["ysgramor"] = "Ysgramor",
	["ysgramora"] = "Ysgramor",
	["ysgramorowi"] = "Ysgramor",
	["ysgramorem"] = "Ysgramor",
	["ysgramorze"] = "Ysgramor",
    -- Smooth-as-Wind
	["smooth-as-wind"] = "Smooth-as-Wind",
	["łagodny-jak-wiatr"] = "Smooth-as-Wind",
	["łagodnego-jak-wiatr"] = "Smooth-as-Wind",
	["łagodnemu-jak-wiatr"] = "Smooth-as-Wind",
	["łagodnym-jak-wiatr"] = "Smooth-as-Wind",
    -- J'ghanor
	["j'ghanor"] = "J'ghanor",
	["j'ghanora"] = "J'ghanor",
	["j'ghanorowi"] = "J'ghanor",
	["j'ghanorem"] = "J'ghanor",
	["j'ghanorze"] = "J'ghanor",
    -- Ra'ri
	["ra'ri"] = "Ra'ri",
	["ra'riego"] = "Ra'ri",
	["ra'riemu"] = "Ra'ri",
	["ra'rim"] = "Ra'ri",
    -- Aereus
	["aereus"] = "Aereus",
    -- Grand Warlord Dortene
	["grand warlord dortene"] = "Grand_Warlord_Dortene",
	["starsza gubernator wojskowa dortene"] = "Grand_Warlord_Dortene",
	["starszej gubernator wojskowej dortene"] = "Grand_Warlord_Dortene",
	["starszą gubernator wojskową dortene"] = "Grand_Warlord_Dortene",
    -- Alcedonia Delitian
	["alcedonia delitian"] = "Alcedonia_Delitian",
	["alcedonii delitian"] = "Alcedonia_Delitian",
	["alcedonię delitian"] = "Alcedonia_Delitian",
	["alcedonią delitian"] = "Alcedonia_Delitian",
	["alcedonio delitian"] = "Alcedonia_Delitian",
    -- Ohtimir
	["ohtimir"] = "Ohtimir",
	["ohtimira"] = "Ohtimir",
	["ohtimirowi"] = "Ohtimir",
	["ohtimirem"] = "Ohtimir",
	["ohtimirze"] = "Ohtimir",
    -- Storm-Cursed Sailor
	["storm-cursed sailor"] = "Storm-Cursed_Sailor",
	["żeglarz przeklętej burzy"] = "Storm-Cursed_Sailor",
	["żeglarza przeklętej burzy"] = "Storm-Cursed_Sailor",
	["żeglarzowi przeklętej burzy"] = "Storm-Cursed_Sailor",
	["żeglarzem przeklętej burzy"] = "Storm-Cursed_Sailor",
	["żeglarzu przeklętej burzy"] = "Storm-Cursed_Sailor",
    -- Alskar
	["alskar"] = "Alskar",
	["alskara"] = "Alskar",
	["alskarowi"] = "Alskar",
	["alskarem"] = "Alskar",
	["alskarze"] = "Alskar",
    -- Neiral
	["neiral"] = "Neiral",
	["neirala"] = "Neiral",
	["neiralowi"] = "Neiral",
	["neiralem"] = "Neiral",
	["neiralu"] = "Neiral",
    -- Ahirunz
	["ahirunz"] = "Ahirunz",
	["ahirunza"] = "Ahirunz",
	["ahirunzowi"] = "Ahirunz",
	["ahirunzem"] = "Ahirunz",
	["ahirunzie"] = "Ahirunz",
    -- Tzik'nith
	["tzik'nith"] = "Tzik'nith",
    -- Anriel
	["anriel"] = "Anriel",
    -- Helonel (Auridon)
	["helonel"] = "Helonel_(Auridon)",
	["helonel (auridon)"] = "Helonel_(Auridon)",
	["helonela"] = "Helonel_(Auridon)",
	["helonelowi"] = "Helonel_(Auridon)",
	["helonelem"] = "Helonel_(Auridon)",
	["helonelu"] = "Helonel_(Auridon)",
    -- Ciceri the Bold
	["ciceri the bold"] = "Ciceri_the_Bold",
	["ciceri śmiała"] = "Ciceri_the_Bold",
	["ciceri śmiałej"] = "Ciceri_the_Bold",
	["ciceri śmiałą"] = "Ciceri_the_Bold",
    -- Hoggvir
	["hoggvir"] = "Hoggvir",
	["hoggvira"] = "Hoggvir",
	["hoggvirowi"] = "Hoggvir",
	["hoggvirem"] = "Hoggvir",
	["hoggvirze"] = "Hoggvir",
    -- Druid Yrene
	["druid yrene"] = "Druid_Yrene",
	["druidka yrene"] = "Druid_Yrene",
	["druidki yrene"] = "Druid_Yrene",
	["druidce yrene"] = "Druid_Yrene",
	["druidkę yrene"] = "Druid_Yrene",
	["druidką yrene"] = "Druid_Yrene",
	["druidko yrene"] = "Druid_Yrene",
    -- Skull-Daughter Hjolbel
	["skull-daughter hjolbel"] = "Skull-Daughter_Hjolbel",
	["córka czaszki hjolbel"] = "Skull-Daughter_Hjolbel",
	["córki czaszki hjolbel"] = "Skull-Daughter_Hjolbel",
	["córce czaszki hjolbel"] = "Skull-Daughter_Hjolbel",
	["córkę czaszki hjolbel"] = "Skull-Daughter_Hjolbel",
	["córką czaszki hjolbel"] = "Skull-Daughter_Hjolbel",
	["córko czaszki hjolbel"] = "Skull-Daughter_Hjolbel",
    -- Skullbreaker
	["skullbreaker"] = "Skullbreaker",
	-- Męski (Łamacz Czaszek)
	["łamacz czaszek"] = "Skullbreaker",
	["łamacza czaszek"] = "Skullbreaker",
	["łamaczowi czaszek"] = "Skullbreaker",
	["łamaczem czaszek"] = "Skullbreaker",
	["łamaczu czaszek"] = "Skullbreaker",
	-- Żeński (Łamaczka Czaszek)
	["łamaczka czaszek"] = "Skullbreaker",
	["łamaczki czaszek"] = "Skullbreaker",
	["łamaczce czaszek"] = "Skullbreaker",
	["łamaczkę czaszek"] = "Skullbreaker",
	["łamaczką czaszek"] = "Skullbreaker",
	["łamaczko czaszek"] = "Skullbreaker",
    -- Snapjaw
	["snapjaw"] = "Snapjaw",
	["trzaskająca paszcza"] = "Snapjaw",
	["trzaskającej paszczy"] = "Snapjaw",
	["trzaskającą paszczę"] = "Snapjaw",
	["trzaskającą paszczą"] = "Snapjaw",
	["trzaskająca paszczo"] = "Snapjaw",
    -- Sergeant Chalda
	["sergeant chalda"] = "Sergeant_Chalda",
	["sierżant chalda"] = "Sergeant_Chalda",
	["sierżant chaldy"] = "Sergeant_Chalda",
	["sierżant chaldzie"] = "Sergeant_Chalda",
	["sierżant chaldę"] = "Sergeant_Chalda",
	["sierżant chaldą"] = "Sergeant_Chalda",
	["sierżant chaldo"] = "Sergeant_Chalda",
    -- Legate Gallus
	["legate gallus"] = "Legate_Gallus",
	["legat gallus"] = "Legate_Gallus",
	["legata gallusa"] = "Legate_Gallus",
	["legatowi gallusowi"] = "Legate_Gallus",
	["legatem gallusem"] = "Legate_Gallus",
	["legacie gallusie"] = "Legate_Gallus",
    -- Fadile Sonoril
	["fadile sonoril"] = "Fadile_Sonoril",
    -- Magnar Child-Eater
	["magnar child-eater"] = "Magnar_Child-Eater",
	["magnar dzieciożerca"] = "Magnar_Child-Eater",
	["magnara dzieciożercy"] = "Magnar_Child-Eater",
	["magnarowi dzieciożercy"] = "Magnar_Child-Eater",
	["magnara dzieciożercę"] = "Magnar_Child-Eater",
	["magnarem dzieciożercą"] = "Magnar_Child-Eater",
	["magnarze dzieciożercy"] = "Magnar_Child-Eater",
	["magnarze dzieciożerco"] = "Magnar_Child-Eater",
    -- Aera Earth-Turner
	["aera earth-turner"] = "Aera_Earth-Turner",
	["aera oraczka-ziemi"] = "Aera_Earth-Turner",
	["aery oraczki-ziemi"] = "Aera_Earth-Turner",
	["aerze oraczce-ziemi"] = "Aera_Earth-Turner",
	["aerę oraczkę-ziemi"] = "Aera_Earth-Turner",
	["aerą oraczką-ziemi"] = "Aera_Earth-Turner",
	["aero oraczko-ziemi"] = "Aera_Earth-Turner",
    -- Biro-dar
	["biro-dar"] = "Biro-dar",
	["biro-dara"] = "Biro-dar",
	["biro-darowi"] = "Biro-dar",
	["biro-darem"] = "Biro-dar",
	["biro-darze"] = "Biro-dar",
    -- Jailer Melitus
	["jailer melitus"] = "Jailer_Melitus",
	["strażnik więzienny melitus"] = "Jailer_Melitus",
	["strażnika więziennego melitusa"] = "Jailer_Melitus",
	["strażnikowi więziennemu melitusowi"] = "Jailer_Melitus",
	["strażnikiem więziennym melitusem"] = "Jailer_Melitus",
	["strażniku więziennym melitusie"] = "Jailer_Melitus",
	["strażniku więzienny melitusie"] = "Jailer_Melitus",
    -- Skull-Daughter Denninel
	["skull-daughter denninel"] = "Skull-Daughter_Denninel",
	["córka czaszki denninel"] = "Skull-Daughter_Denninel",
	["córki czaszki denninel"] = "Skull-Daughter_Denninel",
	["córce czaszki denninel"] = "Skull-Daughter_Denninel",
	["córkę czaszki denninel"] = "Skull-Daughter_Denninel",
	["córką czaszki denninel"] = "Skull-Daughter_Denninel",
	["córko czaszki denninel"] = "Skull-Daughter_Denninel",
    -- Medbrenna
	["medbrenna"] = "Medbrenna",
	["medbrenny"] = "Medbrenna",
	["medbrennie"] = "Medbrenna",
	["medbrennę"] = "Medbrenna",
	["medbrenną"] = "Medbrenna",
	["medbrenno"] = "Medbrenna",
    -- Dugan the Red
	["dugan the red"] = "Dugan_the_Red",
	["dugan czerwony"] = "Dugan_the_Red",
	["dugana czerwonego"] = "Dugan_the_Red",
	["duganowi czerwonemu"] = "Dugan_the_Red",
	["dugana czerwonego"] = "Dugan_the_Red",
	["duganem czerwonym"] = "Dugan_the_Red",
	["duganie czerwonym"] = "Dugan_the_Red",
    -- Aberius Geta
	["aberius geta"] = "Aberius_Geta",
	["aberiusa gety"] = "Aberius_Geta",
	["aberiusowi gecie"] = "Aberius_Geta",
	["aberiusa getę"] = "Aberius_Geta",
	["aberiusem getą"] = "Aberius_Geta",
	["aberiusie gecie"] = "Aberius_Geta",
	["aberiusie geto"] = "Aberius_Geta",
    -- Valanir the Restless
	["valanir the restless"] = "Valanir_the_Restless",
	["valanir niespokojny"] = "Valanir_the_Restless",
	["valanira niespokojnego"] = "Valanir_the_Restless",
	["valanirowi niespokojnemu"] = "Valanir_the_Restless",
	["valanira niespokojnego"] = "Valanir_the_Restless",
	["valanirem niespokojnym"] = "Valanir_the_Restless",
	["valanirze niespokojnym"] = "Valanir_the_Restless",
	["valanirze niespokojny"] = "Valanir_the_Restless",
    -- Nalgillarion
	["nalgillarion"] = "Nalgillarion",
	["nalgillariona"] = "Nalgillarion",
	["nalgillarionowi"] = "Nalgillarion",
	["nalgillarionem"] = "Nalgillarion",
	["nalgillarionie"] = "Nalgillarion",
    -- Stands-In-Still-Water
	["stands-in-still-water"] = "Stands-In-Still-Water",
	["stoi-w-spokojnej-wodzie"] = "Stands-In-Still-Water",
    -- Kloli
	["kloli"] = "Kloli",
	["klolego"] = "Kloli",
	["klolemu"] = "Kloli",
	["klolim"] = "Kloli",
    -- Tolendos Dreloth
	["tolendos dreloth"] = "Tolendos_Dreloth",
	["tolendosa drelotha"] = "Tolendos_Dreloth",
	["tolendosowi drelothowi"] = "Tolendos_Dreloth",
	["tolendosem drelothem"] = "Tolendos_Dreloth",
	["tolendosie drelothie"] = "Tolendos_Dreloth",
    -- Queen of the Reef
	["queen of the reef"] = "Queen_of_the_Reef",
	["królowa rafy"] = "Queen_of_the_Reef",
	["królowej rafy"] = "Queen_of_the_Reef",
	["królową rafy"] = "Queen_of_the_Reef",
	["królowo rafy"] = "Queen_of_the_Reef",
    -- Sharpfang
	["sharpfang"] = "Sharpfang",
	["ostry kieł"] = "Sharpfang",
	["ostrego kła"] = "Sharpfang",
	["ostremu kłu"] = "Sharpfang",
	["ostrym kłem"] = "Sharpfang",
	["ostrym kle"] = "Sharpfang",
	["ostry kle"] = "Sharpfang",
    -- Falwyn Stonewalker
	["falwyn stonewalker"] = "Falwyn_Stonewalker",
	["falwyn kamienna wędrowczyni"] = "Falwyn_Stonewalker",
	["falwyn kamiennej wędrowczyni"] = "Falwyn_Stonewalker",
	["falwyn kamienną wędrowczynię"] = "Falwyn_Stonewalker",
	["falwyn kamienną wędrowczynią"] = "Falwyn_Stonewalker",
	["falwyn kamienna wędrowczynio"] = "Falwyn_Stonewalker",
    -- 33180, Sorondil
	["sorondil"] = "Sorondil",
	["sorondila"] = "Sorondil",
	["sorondilowi"] = "Sorondil",
	["sorondilem"] = "Sorondil",
	["sorondilu"] = "Sorondil",
    -- Rogar Tanner
	["rogar tanner"] = "Rogar_Tanner",
	["rogar garbarz"] = "Rogar_Tanner",
	["rogara garbarza"] = "Rogar_Tanner",
	["rogarowi garbarzowi"] = "Rogar_Tanner",
	["rogarem garbarzem"] = "Rogar_Tanner",
	["rogarze garbarzu"] = "Rogar_Tanner",
    -- Leovic
	["leovic"] = "Leovic",
	["leovica"] = "Leovic",
	["leovicowi"] = "Leovic",
	["leovicem"] = "Leovic",
	["leovicu"] = "Leovic",
    -- Ysausa Relippe
	["ysausa relippe"] = "Ysausa_Relippe",
	["ysausy relippe"] = "Ysausa_Relippe",
	["ysausie relippe"] = "Ysausa_Relippe",
	["ysausę relippe"] = "Ysausa_Relippe",
	["ysausą relippe"] = "Ysausa_Relippe",
	["ysauso relippe"] = "Ysausa_Relippe",
    -- Sarazi
	["sarazi"] = "Sarazi",
	["sarazego"] = "Sarazi",
	["sarazemu"] = "Sarazi",
	["sarazim"] = "Sarazi",
    -- Belfrost the Shy
	["belfrost the shy"] = "Belfrost_the_Shy",
	["belfrost nieśmiała"] = "Belfrost_the_Shy",
	["belfrost nieśmiałej"] = "Belfrost_the_Shy",
	["belfrost nieśmiałą"] = "Belfrost_the_Shy",
	["belfrost nieśmiało"] = "Belfrost_the_Shy",
    -- Malana
	["malana"] = "Malana",
	["malany"] = "Malana",
	["malanie"] = "Malana",
	["malanę"] = "Malana",
	["malaną"] = "Malana",
	["malano"] = "Malana",
    -- Adord
	["adord"] = "Adord",
	["adorda"] = "Adord",
	["adordowi"] = "Adord",
	["adordem"] = "Adord",
	["adordzie"] = "Adord",
    -- Evening-Star-Rising
	["evening-star-rising"] = "Evening-Star-Rising",
	["wschodząca-gwiazda-wieczorna"] = "Evening-Star-Rising",
	["wschodzącej-gwiazdy-wieczornej"] = "Evening-Star-Rising",
	["wschodzącej-gwieździe-wieczornej"] = "Evening-Star-Rising",
	["wschodzącą-gwiazdę-wieczorną"] = "Evening-Star-Rising",
	["wschodzącą-gwiazdą-wieczorną"] = "Evening-Star-Rising",
	["wschodząca-gwiazdo-wieczorna"] = "Evening-Star-Rising",
    -- Berani
	["berani"] = "Berani",
    -- Belrengar
	["belrengar"] = "Belrengar",
	["belrengara"] = "Belrengar",
	["belrengarowi"] = "Belrengar",
	["belrengarem"] = "Belrengar",
	["belrengarze"] = "Belrengar",
    -- War Chief Ozozai
	["war chief ozozai"] = "War_Chief_Ozozai",
	["wojenny wódz ozozai"] = "War_Chief_Ozozai",
	["wojennego wodza ozozaia"] = "War_Chief_Ozozai",
	["wojennemu wodzowi ozozaiowi"] = "War_Chief_Ozozai",
	["wojennym wodzem ozozaiem"] = "War_Chief_Ozozai",
	["wojennym wodzu ozozaiu"] = "War_Chief_Ozozai",
	["wojenny wodzu ozozaiu"] = "War_Chief_Ozozai",
    -- Hoknir
	["hoknir"] = "Hoknir",
	["hoknira"] = "Hoknir",
	["hoknirowi"] = "Hoknir",
	["hoknirem"] = "Hoknir",
	["hoknirze"] = "Hoknir",
    -- Tarak
	["tarak"] = "Tarak_Silver-Claw",
	["taraka"] = "Tarak_Silver-Claw",
	["tarakowi"] = "Tarak_Silver-Claw",
	["tarakiem"] = "Tarak_Silver-Claw",
	["taraku"] = "Tarak_Silver-Claw",
    -- Alma Desticus
	["alma desticus"] = "Alma_Desticus",
	["almy desticus"] = "Alma_Desticus",
	["almie desticus"] = "Alma_Desticus",
	["almę desticus"] = "Alma_Desticus",
	["almą desticus"] = "Alma_Desticus",
	["almo desticus"] = "Alma_Desticus",
    -- 29637, Thjormar the Drowned
	["thjormar the drowned"] = "Thjormar_the_Drowned",
	["thjormar topielec"] = "Thjormar_the_Drowned",
	["thjormara topielca"] = "Thjormar_the_Drowned",
	["thjormarowi topielcowi"] = "Thjormar_the_Drowned",
	["thjormarem topielcem"] = "Thjormar_the_Drowned",
	["thjormarze topielcu"] = "Thjormar_the_Drowned",
    -- Skorvild Frostwind
	["skorvild frostwind"] = "Skorvild_Frostwind",
	["skorvild mroźny powiew"] = "Skorvild_Frostwind",
	["skorvilda mroźnego powiewu"] = "Skorvild_Frostwind",
	["skorvildowi mroźnemu powiewowi"] = "Skorvild_Frostwind",
	["skorvildem mroźnym powiewem"] = "Skorvild_Frostwind",
	["skorvildzie mroźnym powiewie"] = "Skorvild_Frostwind",
    -- Thane Mera Stormcloak
	["mera stormcloak"] = "Mera_Stormcloak",
	["thane mera stormcloak"] = "Mera_Stormcloak",
	["tan mera gromowładna"] = "Mera_Stormcloak",
	["tana mery gromowładnej"] = "Mera_Stormcloak",
	["tanowi merze gromowładnej"] = "Mera_Stormcloak",
	["tana merę gromowładną"] = "Mera_Stormcloak",
	["tanem merą gromowładną"] = "Mera_Stormcloak",
	["tanie merze gromowładnej"] = "Mera_Stormcloak",
	["tanie mero gromowładna"] = "Mera_Stormcloak",
    -- Thulendor
	["thulendor"] = "Thulendor",
	["thulendora"] = "Thulendor",
	["thulendorowi"] = "Thulendor",
	["thulendorem"] = "Thulendor",
	["thulendorze"] = "Thulendor",
    -- Skeletal Watch Captain
	["skeletal watch captain"] = "Skeletal_Watch_Captain",
	["szkieletowy kapitan straży"] = "Skeletal_Watch_Captain",
	["szkieletowego kapitana straży"] = "Skeletal_Watch_Captain",
	["szkieletowemu kapitanowi straży"] = "Skeletal_Watch_Captain",
	["szkieletowym kapitanem straży"] = "Skeletal_Watch_Captain",
	["szkieletowym kapitanie straży"] = "Skeletal_Watch_Captain",
	["szkieletowy kapitanie straży"] = "Skeletal_Watch_Captain",
    -- Adlugbuk
	["adlugbuk"] = "Adlugbuk",
    -- Lyrezi
	["lyrezi"] = "Lyrezi_(postać)",
	["lyrezi (postać)"] = "Lyrezi_(postać)",
	["lyrezego"] = "Lyrezi_(postać)",
	["lyrezemu"] = "Lyrezi_(postać)",
	["lyrezim"] = "Lyrezi_(postać)",
    ["levus cavus"] = "Levus_Cavus",
    -- Hannah Tailas
	["hannah tailas"] = "Hannah_Tailas",
    -- Titus Stolo
	["titus stolo"] = "Titus_Stolo",
	["titusa stola"] = "Titus_Stolo",
	["titusowi stolowi"] = "Titus_Stolo",
	["titusem stolem"] = "Titus_Stolo",
	["titusie stolu"] = "Titus_Stolo",
    -- Gathongor the Mauler
	["gathongor the mauler"] = "Gathongor_the_Mauler",
	["gathongor miażdżyciel"] = "Gathongor_the_Mauler",
	["gathongora miażdżyciela"] = "Gathongor_the_Mauler",
	["gathongorowi miażdżycielowi"] = "Gathongor_the_Mauler",
	["gathongorem miażdżycielem"] = "Gathongor_the_Mauler",
	["gathongorze miażdżycielu"] = "Gathongor_the_Mauler",
    -- Woodblight
	["woodblight"] = "Woodblight",
	["drzewna zaraza"] = "Woodblight",
	["drzewnej zarazy"] = "Woodblight",
	["drzewnej zarazie"] = "Woodblight",
	["drzewną zarazę"] = "Woodblight",
	["drzewną zarazą"] = "Woodblight",
	["drzewna zarazo"] = "Woodblight",
    -- Nikaolde
	["nikaolde"] = "Nikaolde",
    -- Evone
	["evone"] = "Evone",
    -- Mylenne Moon-Caller
	["mylenne moon-caller"] = "Mylenne_Moon-Caller",
	["mylenne wywoływaczka księżyca"] = "Mylenne_Moon-Caller",
	["mylenne wywoływaczki księżyca"] = "Mylenne_Moon-Caller",
	["mylenne wywoływaczce księżyca"] = "Mylenne_Moon-Caller",
	["mylenne wywoływaczkę księżyca"] = "Mylenne_Moon-Caller",
	["mylenne wywoływaczką księżyca"] = "Mylenne_Moon-Caller",
	["mylenne wywoływaczko księżyca"] = "Mylenne_Moon-Caller",
    -- Igazkad
	["igazkad"] = "Igazkad",
    -- Drorunn
	["drorunn"] = "Drorunn",
	["drorunna"] = "Drorunn",
	["drorunnowi"] = "Drorunn",
	["drorunnem"] = "Drorunn",
	["drorunnie"] = "Drorunn",
    -- Recruiter Andrilo
	["recruiter andrilo"] = "Recruiter_Andrilo",
	["rekruter andrilo"] = "Recruiter_Andrilo",
	["rekrutera andrilo"] = "Recruiter_Andrilo",
	["rekruterowi andrilo"] = "Recruiter_Andrilo",
	["rekruterem andrilo"] = "Recruiter_Andrilo",
	["rekruterze andrilo"] = "Recruiter_Andrilo",
    -- Ary
	["ary"] = "Ary",
	["ary'ego"] = "Ary",
	["ary'emu"] = "Ary",
	["arym"] = "Ary",
    -- Gravecaller Niramo
	["gravecaller niramo"] = "Gravecaller_Niramo",
	["grobowy przyzywacz niramo"] = "Gravecaller_Niramo",
	["grobowego przyzywacza nirama"] = "Gravecaller_Niramo",
	["grobowemu przyzywaczowi niramowi"] = "Gravecaller_Niramo",
	["grobowym przyzywaczem niramem"] = "Gravecaller_Niramo",
	["grobowym przyzywaczu niramie"] = "Gravecaller_Niramo",
	["grobowy przyzywaczu niramie"] = "Gravecaller_Niramo",
    -- Paints-the-Sky
	["paints-the-sky"] = "Paints-the-Sky",
	["maluje-niebo"] = "Paints-the-Sky",
    -- Quenyas
	["quenyas"] = "Quenyas",
    -- Overlord Nur-dro
	["overlord nur-dro"] = "Overlord_Nur-dro",
	["suweren nur-dro"] = "Overlord_Nur-dro",
	["suwerena nur-dro"] = "Overlord_Nur-dro",
	["suwerenowi nur-dro"] = "Overlord_Nur-dro",
	["suwerenem nur-dro"] = "Overlord_Nur-dro",
	["suwerenie nur-dro"] = "Overlord_Nur-dro",
    -- Mizzik Thunderboots
	["mizzik thunderboots"] = "Mizzik_Thunderboots",
	["mizzik grzmiące buty"] = "Mizzik_Thunderboots",
	["mizzika grzmiących butów"] = "Mizzik_Thunderboots",
	["mizzikowi grzmiącym butom"] = "Mizzik_Thunderboots",
	["mizzikiem grzmiącymi butami"] = "Mizzik_Thunderboots",
	["mizziku grzmiących butach"] = "Mizzik_Thunderboots",
	["mizziku grzmiące buty"] = "Mizzik_Thunderboots",
    -- Anchorite Garmar
	["anchorite garmar"] = "Anchorite_Garmar",
	["anachoreta garmar"] = "Anchorite_Garmar",
	["anachorety garmara"] = "Anchorite_Garmar",
	["anachorecie garmarowi"] = "Anchorite_Garmar",
	["anachoretę garmara"] = "Anchorite_Garmar",
	["anachoretą garmarem"] = "Anchorite_Garmar",
	["anachorecie garmarze"] = "Anchorite_Garmar",
	["anachoreto garmarze"] = "Anchorite_Garmar",
-- Norgred Hardhelm
	["norgred hardhelm"] = "Norgred_Hardhelm",
	["norgred twardy hełm"] = "Norgred_Hardhelm",
	["norgreda twardego hełmu"] = "Norgred_Hardhelm",
	["norgredowi twardemu hełmowi"] = "Norgred_Hardhelm",
	["norgredem twardym hełmem"] = "Norgred_Hardhelm",
	["norgredzie twardym hełmie"] = "Norgred_Hardhelm",
    -- Grethaa
	["grethaa"] = "Grethaa",
    -- Remius Balbus
	["remius balbus"] = "Remius_Balbus",
	["remiusa balbusa"] = "Remius_Balbus",
	["remiusowi balbusowi"] = "Remius_Balbus",
	["remiusem balbusem"] = "Remius_Balbus",
	["remiusie balbusie"] = "Remius_Balbus",
    -- Rageclaw
	["rageclaw"] = "Rageclaw_(wilkołak)",
	["rageclaw (wilkołak)"] = "Rageclaw_(wilkołak)",
	["gniewny pazur"] = "Rageclaw_(wilkołak)",
	["gniewnego pazura"] = "Rageclaw_(wilkołak)",
	["gniewnemu pazurowi"] = "Rageclaw_(wilkołak)",
	["gniewnym pazurem"] = "Rageclaw_(wilkołak)",
	["gniewnym pazurze"] = "Rageclaw_(wilkołak)",
    -- Bavura the Blizzard
	["bavura the blizzard"] = "Bavura_the_Blizzard",
	["bavura śnieżyca"] = "Bavura_the_Blizzard",
	["bavury śnieżycy"] = "Bavura_the_Blizzard",
	["bavurze śnieżycy"] = "Bavura_the_Blizzard",
	["bavurę śnieżycę"] = "Bavura_the_Blizzard",
	["bavurą śnieżycą"] = "Bavura_the_Blizzard",
	["bavuro śnieżyco"] = "Bavura_the_Blizzard",
    -- Olvyia Indaram
	["olvyia indaram"] = "Olvyia_Indaram",
	["olvyi indaram"] = "Olvyia_Indaram",
	["olvyię indaram"] = "Olvyia_Indaram",
	["olvyią indaram"] = "Olvyia_Indaram",
	["olvyio indaram"] = "Olvyia_Indaram",
    -- Arabelle Serene
	["arabelle serene"] = "Arabelle_Serene",
    -- Saryvn
	["saryvn"] = "Saryvn",
	["saryvna"] = "Saryvn",
	["saryvnowi"] = "Saryvn",
	["saryvnem"] = "Saryvn",
	["saryvnie"] = "Saryvn",
    -- Penwe
	["penwe"] = "Penwe",
    -- General Nedras
	["general nedras"] = "General_Nedras",
	["generał nedras"] = "General_Nedras",
	["generała nedrasa"] = "General_Nedras",
	["generałowi nedrasowi"] = "General_Nedras",
	["generałem nedrasem"] = "General_Nedras",
	["generale nedrasie"] = "General_Nedras",
    -- Lost Maiden
	["lost maiden"] = "Lost_Maiden",
	["zagubiona panna"] = "Lost_Maiden",
	["zagubionej panny"] = "Lost_Maiden",
	["zagubionej pannie"] = "Lost_Maiden",
	["zagubioną pannę"] = "Lost_Maiden",
	["zagubioną panną"] = "Lost_Maiden",
	["zagubiona panno"] = "Lost_Maiden",
    -- Belyn Raviro
	["belyn raviro"] = "Belyn_Raviro",
	["belyna ravira"] = "Belyn_Raviro",
	["belynowi ravirowi"] = "Belyn_Raviro",
	["belynem ravirem"] = "Belyn_Raviro",
	["belynie ravirze"] = "Belyn_Raviro",
    -- Teeth-Like-Stars
	["teeth-like-stars"] = "Teeth-Like-Stars",
	["zęby-jak-gwiazdy"] = "Teeth-Like-Stars",
    -- Ula-Reen
	["ula-reen"] = "Ula-Reen",
    -- Cordius Pontifio
	["cordius pontifio"] = "Cordius_Pontifio",
	["cordiusa pontifia"] = "Cordius_Pontifio",
	["cordiusowi pontifiowi"] = "Cordius_Pontifio",
	["cordiusem pontifiem"] = "Cordius_Pontifio",
	["cordiusie pontifiu"] = "Cordius_Pontifio",
    -- Silurra
	["silurra"] = "Silurra",
	["silurry"] = "Silurra",
	["silurze"] = "Silurra",
	["silurrę"] = "Silurra",
	["silurrą"] = "Silurra",
	["silurro"] = "Silurra",
    -- Hannura
	["hannura"] = "Hannura",
	["hannury"] = "Hannura",
	["hannurze"] = "Hannura",
	["hannurę"] = "Hannura",
	["hannurą"] = "Hannura",
	["hannuro"] = "Hannura",
    -- Chews-The-Marrow
	["chews-the-marrow"] = "Chews-The-Marrow",
	["żuje-szpik"] = "Chews-The-Marrow",
    -- Sonsu
	["sonsu"] = "Sonsu",
    ["giant camp (rift)"] = "Giant_Camp_(Rift)", --do ustalenia
    -- Zhaj'hassa the Forgotten
	["zhaj'hassa the forgotten"] = "Zhaj'hassa_the_Forgotten",
	["zhaj'hassa zapomniany"] = "Zhaj'hassa_the_Forgotten",
	["zhaj'hassy zapomnianego"] = "Zhaj'hassa_the_Forgotten",
	["zhaj'hassie zapomnianemu"] = "Zhaj'hassa_the_Forgotten",
	["zhaj'hassę zapomnianego"] = "Zhaj'hassa_the_Forgotten",
	["zhaj'hassą zapomnianym"] = "Zhaj'hassa_the_Forgotten",
	["zhaj'hassie zapomnianym"] = "Zhaj'hassa_the_Forgotten",
	["zhaj'hasso zapomniany"] = "Zhaj'hassa_the_Forgotten",
    -- Iron-Claws
	["iron-claws"] = "Iron-Claws",
	["metalowe-pazury"] = "Iron-Claws",
    -- Boran
	["boran"] = "Boran",
	["borana"] = "Boran",
	["boranowi"] = "Boran",
	["boranem"] = "Boran",
	["boranie"] = "Boran",
    -- Loncano
	["loncano"] = "Loncano",
	["loncana"] = "Loncano",
	["loncanowi"] = "Loncano",
	["loncanem"] = "Loncano",
	["loncanie"] = "Loncano",
    -- Zalsheem
	["zalsheem"] = "Zalsheem",
    -- Bagul
	["bagul"] = "Bagul",
    -- Beek-Ja
	["beek-ja"] = "Beek-Ja",
    -- Evolitte Ginise
	["evolitte ginise"] = "Evolitte_Ginise",
    -- Carusian Matius
	["carusian matius"] = "Carusian_Matius",
	["carusiana matiusa"] = "Carusian_Matius",
	["carusianowi matiusowi"] = "Carusian_Matius",
	["carusianem matiusem"] = "Carusian_Matius",
	["carusianie matiusie"] = "Carusian_Matius",
    -- Odela
	["odela"] = "Odela",
	["odeli"] = "Odela",
	["odelę"] = "Odela",
	["odelą"] = "Odela",
	["odelo"] = "Odela",
    -- Meluuran
	["meluuran"] = "Meluuran",
	["meluurana"] = "Meluuran",
	["meluuranowi"] = "Meluuran",
	["meluuranem"] = "Meluuran",
	["meluuranie"] = "Meluuran",
    -- Merric at-Aswala
	["merric at-aswala"] = "Merric_at-Aswala",
	["merrik at-aswala"] = "Merric_at-Aswala",
	["merrika at-aswali"] = "Merric_at-Aswala",
	["merrikowi at-aswali"] = "Merric_at-Aswala",
	["merrikiem at-aswalą"] = "Merric_at-Aswala",
	["merriku at-aswali"] = "Merric_at-Aswala",
    -- Commander Faldethil
	["commander faldethil"] = "Commander_Faldethil",
	["dowódczyni faldethil"] = "Commander_Faldethil",
	["dowódczynię faldethil"] = "Commander_Faldethil",
	["dowódczynią faldethil"] = "Commander_Faldethil",
    -- Wanam-Jush
	["wanam-jush"] = "Wanam-Jush",
    ["werewolf ritual site (reaper's march)"] = "Werewolf_Ritual_Site_(Reaper's_March)", -- do ustalenia
    -- Gulfar
	["gulfar"] = "Gulfar",
	["gulfara"] = "Gulfar",
	["gulfarowi"] = "Gulfar",
	["gulfarem"] = "Gulfar",
	["gulfarze"] = "Gulfar",
    -- Denskar Earth-Turner
	["denskar earth-turner"] = "Denskar_Earth-Turner",
	["denskar oracz-ziemi"] = "Denskar_Earth-Turner",
	["denskara oracza-ziemi"] = "Denskar_Earth-Turner",
	["denskarowi oraczowi-ziemi"] = "Denskar_Earth-Turner",
	["denskarem oraczem-ziemi"] = "Denskar_Earth-Turner",
	["denskarze oraczu-ziemi"] = "Denskar_Earth-Turner",
    -- Nari Buteo
	["nari buteo"] = "Nari_Buteo",
    -- Andilo Andrano
	["andilo andrano"] = "Andilo_Andrano",
    -- Runs-in-Wild
	["runs-in-wild"] = "Runs-in-Wild",
	["biega-w-dziczy"] = "Runs-in-Wild",
    -- Victoire Madach
	["victoire madach"] = "Victoire_Madach",
    -- Mevura Arothan
	["mevura arothan"] = "Mevura_Arothan",
	["mevury arothan"] = "Mevura_Arothan",
	["mevurze arothan"] = "Mevura_Arothan",
	["mevurę arothan"] = "Mevura_Arothan",
	["mevurą arothan"] = "Mevura_Arothan",
	["mevuro arothan"] = "Mevura_Arothan",
    -- Ridras
	["ridras"] = "Ridras",
	["ridrasa"] = "Ridras",
	["ridrasowi"] = "Ridras",
	["ridrasem"] = "Ridras",
	["ridrasie"] = "Ridras",
    -- Azeriba
	["azeriba"] = "Azeriba",
	["azeriby"] = "Azeriba",
	["azeribie"] = "Azeriba",
	["azeribę"] = "Azeriba",
	["azeribą"] = "Azeriba",
	["azeribo"] = "Azeriba",
    -- Ingritha
	["ingritha"] = "Ingritha",
	["ingrithy"] = "Ingritha",
	["ingricie"] = "Ingritha",
	["ingrithę"] = "Ingritha",
	["ingrithą"] = "Ingritha",
	["ingritho"] = "Ingritha",
    -- Nuxul
	["nuxul"] = "Nuxul",
	["nuxula"] = "Nuxul",
	["nuxulowi"] = "Nuxul",
	["nuxulem"] = "Nuxul",
	["nuxulu"] = "Nuxul",
    -- Haldriin
	["haldriin"] = "Haldriin",
	["haldriina"] = "Haldriin",
	["haldriinowi"] = "Haldriin",
	["haldriinem"] = "Haldriin",
	["haldriinie"] = "Haldriin",
    -- Zasha-Ja
	["zasha-ja"] = "Zasha-Ja",
    -- Eraman
	["eraman"] = "Eraman",
	["eramana"] = "Eraman",
	["eramanowi"] = "Eraman",
	["eramanem"] = "Eraman",
	["eramanie"] = "Eraman",
    -- Thane Jeggi Gap-Tooth
	["thane jeggi gap-tooth"] = "Thane_Jeggi_Gap-Tooth",
	["tan jeggi zębowa-furta"] = "Thane_Jeggi_Gap-Tooth",
	["tana jeggi zębowej-furty"] = "Thane_Jeggi_Gap-Tooth",
	["tanowi jeggi zębowej-furcie"] = "Thane_Jeggi_Gap-Tooth",
	["tanem jeggi zębową-furtą"] = "Thane_Jeggi_Gap-Tooth",
	["tanie jeggi zębowej-furcie"] = "Thane_Jeggi_Gap-Tooth",
    -- Alexandra Conele
	["alexandra conele"] = "Alexandra_Conele",
	["alexandry conele"] = "Alexandra_Conele",
	["alexandrze conele"] = "Alexandra_Conele",
	["alexandrę conele"] = "Alexandra_Conele",
	["alexandrą conele"] = "Alexandra_Conele",
    -- Gerent Saervild Steel-Wind
	["gerent saervild steel-wind"] = "Gerent_Saervild_Steel-Wind",
	["gerent saervild stalowy-wiatr"] = "Gerent_Saervild_Steel-Wind",
	["gerenta saervilda stalowego-wiatru"] = "Gerent_Saervild_Steel-Wind",
	["gerentowi saervildowi stalowemu-wiatrowi"] = "Gerent_Saervild_Steel-Wind",
	["gerentem saervildem stalowym-wiatrem"] = "Gerent_Saervild_Steel-Wind",
	["gerencie saervildzie stalowym-wietrze"] = "Gerent_Saervild_Steel-Wind",
    -- Commander Yjarnn
	["commander yjarnn"] = "Commander_Yjarnn",
	["dowódca yjarnn"] = "Commander_Yjarnn",
	["dowódcy yjarnna"] = "Commander_Yjarnn",
	["dowódcy yjarnnowi"] = "Commander_Yjarnn",
	["dowódcę yjarnna"] = "Commander_Yjarnn",
	["dowódcą yjarnnem"] = "Commander_Yjarnn",
	["dowódcy yjarnnie"] = "Commander_Yjarnn",
    -- Lyrezi
	["lyrezi"] = "Lyrezi",
    -- Shrouded Axeman
	["shrouded axeman"] = "Shrouded_Axeman",
	["zakapturzony drwal"] = "Shrouded_Axeman",
	["zakapturzonego drwala"] = "Shrouded_Axeman",
	["zakapturzonemu drwalowi"] = "Shrouded_Axeman",
	["zakapturzonym drwalem"] = "Shrouded_Axeman",
	["zakapturzonym drwalu"] = "Shrouded_Axeman",
    -- Carodus Atius
	["carodus atius"] = "Carodus_Atius",
	["carodusa atiusa"] = "Carodus_Atius",
	["carodusowi atiusowi"] = "Carodus_Atius",
	["carodusem atiusem"] = "Carodus_Atius",
	["carodusie atiusie"] = "Carodus_Atius",
    -- Kelaer
	["kelaer"] = "Kelaer",
    -- Lothson Cold-Eye
	["lothson cold-eye"] = "Lothson_Cold-Eye",
	["lothson chłodne-oko"] = "Lothson_Cold-Eye",
	["lothsona chłodnego-oka"] = "Lothson_Cold-Eye",
	["lothsonowi chłodnemu-oku"] = "Lothson_Cold-Eye",
	["lothsonem chłodnym-okiem"] = "Lothson_Cold-Eye",
	["lothsonie chłodnym-oku"] = "Lothson_Cold-Eye",
    -- Vree
	["vree"] = "Vree",
    -- Gamlunda
	["gamlunda"] = "Gamlunda",
	["gamlundy"] = "Gamlunda",
	["gamlundzie"] = "Gamlunda",
	["gamlundę"] = "Gamlunda",
	["gamlundą"] = "Gamlunda",
	["gamlundo"] = "Gamlunda",
    -- Tanisie Manas
	["tanisie manas"] = "Tanisie_Manas",
    -- Averio Brassac
	["averio brassac"] = "Averio_Brassac",
	["averia brassaca"] = "Averio_Brassac",
	["averiu brassacowi"] = "Averio_Brassac",
	["averiem brassakiem"] = "Averio_Brassac",
	["averiu brassacu"] = "Averio_Brassac",
    -- Ayddelsa
	["ayddelsa"] = "Ayddelsa",
	["ayddelsy"] = "Ayddelsa",
	["ayddelsie"] = "Ayddelsa",
	["ayddelsę"] = "Ayddelsa",
	["ayddelsą"] = "Ayddelsa",
	["ayddelso"] = "Ayddelsa",
    -- Llotha Nelvani
	["llotha nelvani"] = "Llotha_Nelvani",
	["llothy nelvani"] = "Llotha_Nelvani",
	["llocie nelvani"] = "Llotha_Nelvani",
	["llothę nelvani"] = "Llotha_Nelvani",
	["llothą nelvani"] = "Llotha_Nelvani",
	["llotho nelvani"] = "Llotha_Nelvani",
    -- Steidor
	["steidor"] = "Steidor",
	["steidora"] = "Steidor",
	["steidorowi"] = "Steidor",
	["steidorem"] = "Steidor",
	["steidorze"] = "Steidor",
    -- Flicks-His-Tongue
	["flicks-his-tongue"] = "Flicks-His-Tongue",
	["trzepie-swym-językiem"] = "Flicks-His-Tongue",
    -- Xokomar
	["xokomar"] = "Xokomar",
    -- Leric Cottret
	["leric cottret"] = "Leric_Cottret",
	["lerica cottreta"] = "Leric_Cottret",
	["lericowi cottretowi"] = "Leric_Cottret",
	["lericem cottretem"] = "Leric_Cottret",
	["lericu cottrecie"] = "Leric_Cottret",
    -- Aretino Buca
	["aretino buca"] = "Aretino_Buca",
	["aretina bucy"] = "Aretino_Buca",
	["aretinowi buce"] = "Aretino_Buca",
	["aretina bucę"] = "Aretino_Buca",
	["aretinem bucą"] = "Aretino_Buca",
	["aretinu buce"] = "Aretino_Buca",
    -- Fangoz
	["fangoz"] = "Fangoz",
	["fangoza"] = "Fangoz",
	["fangozowi"] = "Fangoz",
	["fangozem"] = "Fangoz",
	["fangozie"] = "Fangoz",
    -- Ondendil
	["ondendil"] = "Ondendil",
	["ondendila"] = "Ondendil",
	["ondendilowi"] = "Ondendil",
	["ondendilem"] = "Ondendil",
	["ondendilu"] = "Ondendil",
    -- Skull-Brother Alven
	["skull-brother alven"] = "Skull-Brother_Alven",
	["brat czaszki alven"] = "Skull-Brother_Alven",
	["brata czaszki alvena"] = "Skull-Brother_Alven",
	["bratu czaszki alvenowi"] = "Skull-Brother_Alven",
	["bratem czaszki alvenem"] = "Skull-Brother_Alven",
	["bracie czaszki alvenie"] = "Skull-Brother_Alven",
    -- Darloc Brae
	["darloc brae"] = "Darloc_Brae",
	["darloc's brae"] = "Darloc_Brae", -- Angielska forma dzierżawcza
	["darloca brae"] = "Darloc_Brae", -- Polski dopełniacz i forma dzierżawcza
	["darlocowi brae"] = "Darloc_Brae",
	["darlocem brae"] = "Darloc_Brae",
	["darlocu brae"] = "Darloc_Brae",
    -- Karulae
	["karulae"] = "Karulae",
    -- Fahurr
	["fahurr"] = "Fahurr",
	["fahurra"] = "Fahurr",
	["fahurrowi"] = "Fahurr",
	["fahurrem"] = "Fahurr",
	["fahurze"] = "Fahurr",
    -- Kelurm
	["kelurm"] = "Kelurm",
	["kelurma"] = "Kelurm",
	["kelurmowi"] = "Kelurm",
	["kelurmem"] = "Kelurm",
	["kelurmie"] = "Kelurm",
    -- Otho Rufinus
	["otho rufinus"] = "Otho_Rufinus",
	["otha rufinusa"] = "Otho_Rufinus",
	["othu rufinusowi"] = "Otho_Rufinus",
	["othem rufinusem"] = "Otho_Rufinus",
	["othu rufinusie"] = "Otho_Rufinus",
    -- Erotica for Werewolves
	["erotica for werewolves"] = "Erotica_for_Werewolves",
	["\"erotica for werewolves\""] = "Erotica_for_Werewolves",
	["erotyka dla wilkołaków"] = "Erotica_for_Werewolves",
	["erotyki dla wilkołaków"] = "Erotica_for_Werewolves",
	["erotyce dla wilkołaków"] = "Erotica_for_Werewolves",
	["erotykę dla wilkołaków"] = "Erotica_for_Werewolves",
	["erotyką dla wilkołaków"] = "Erotica_for_Werewolves",
	["erotyko dla wilkołaków"] = "Erotica_for_Werewolves",
    -- Fons Dreth
	["fons dreth"] = "Fons_Dreth",
	["fonsa dretha"] = "Fons_Dreth",
	["fonsowi drethowi"] = "Fons_Dreth",
	["fonsem drethem"] = "Fons_Dreth",
	["fonsie drethcie"] = "Fons_Dreth",
    -- Ramila
	["ramila"] = "Ramila",
	["ramili"] = "Ramila",
	["ramilę"] = "Ramila",
	["ramilą"] = "Ramila",
	["ramilo"] = "Ramila",
    -- Khuzi
	["khuzi"] = "Khuzi",
    -- Igarri
	["igarri"] = "Igarri",
    -- Lonely Papa
	["lonely papa"] = "Lonely_Papa",
	["samotny papa"] = "Lonely_Papa",
	["samotnego papy"] = "Lonely_Papa",
	["samotnemu papie"] = "Lonely_Papa",
	["samotnego papę"] = "Lonely_Papa",
	["samotnym papą"] = "Lonely_Papa",
	["samotnym papie"] = "Lonely_Papa",
    -- Lieutenant Livisii Alor
	["lieutenant livisii alor"] = "Lieutenant_Livisii_Alor",
	["porucznik livisii alor"] = "Lieutenant_Livisii_Alor",
    -- Vyctoria Girien
	["vyctoria girien"] = "Vyctoria_Girien",
	["vyctorii girien"] = "Vyctoria_Girien",
	["vyctorię girien"] = "Vyctoria_Girien",
	["vyctorią girien"] = "Vyctoria_Girien",
	["vyctorio girien"] = "Vyctoria_Girien",
    -- Eiman
	["eiman"] = "Eiman",
	["eimana"] = "Eiman",
	["eimanowi"] = "Eiman",
	["eimanem"] = "Eiman",
	["eimanie"] = "Eiman",
    -- Caldien
	["caldien"] = "Caldien",
	["caldiena"] = "Caldien",
	["caldienowi"] = "Caldien",
	["caldienem"] = "Caldien",
	["caldenie"] = "Caldien",
    -- Iron-In-Blood
	["iron-in-blood"] = "Iron-In-Blood",
	["żelazo-we-krwi"] = "Iron-In-Blood",
    -- Tana-Teeus
	["tana-teeus"] = "Tana-Teeus",
    -- Captain Blanchete
	["captain blanchete"] = "Captain_Blanchete",
	["kapitan blanchete"] = "Captain_Blanchete",
	["kapitana blanchete"] = "Captain_Blanchete",
	["kapitanowi blanchete"] = "Captain_Blanchete",
	["kapitanem blanchete"] = "Captain_Blanchete",
	["kapitanie blanchete"] = "Captain_Blanchete",
    -- Korignah
	["korignah"] = "Korignah",
    -- Hedge Maze Guardian
	["hedge maze guardian"] = "Hedge_Maze_Guardian",
	["strażnik krzewiastego labiryntu"] = "Hedge_Maze_Guardian",
	["strażnika krzewiastego labiryntu"] = "Hedge_Maze_Guardian",
	["strażnikowi krzewiastego labiryntu"] = "Hedge_Maze_Guardian",
	["strażnikiem krzewiastego labiryntu"] = "Hedge_Maze_Guardian",
	["strażniku krzewiastego labiryntu"] = "Hedge_Maze_Guardian",
    -- Tanuro Indoren
	["tanuro indoren"] = "Tanuro_Indoren",
	["tanura indorena"] = "Tanuro_Indoren",
	["tanuru indorenowi"] = "Tanuro_Indoren",
	["tanurem indorenem"] = "Tanuro_Indoren",
	["tanuru indorenie"] = "Tanuro_Indoren",
    -- Tavynu Aryon
	["tavynu aryon"] = "Tavynu_Aryon",
    -- Zel
	["zel"] = "Zel",
	["zela"] = "Zel",
	["zelowi"] = "Zel",
	["zelem"] = "Zel",
	["zelu"] = "Zel",
    -- Molla
	["molla"] = "Molla",
	["molli"] = "Molla",
	["mollę"] = "Molla",
	["mollą"] = "Molla",
	["mollo"] = "Molla",
    -- Volrina Quarra
	["volrina quarra"] = "Volrina_Quarra",
	["volriny quarry"] = "Volrina_Quarra",
	["volrinie quarrze"] = "Volrina_Quarra",
	["volrinę quarrę"] = "Volrina_Quarra",
	["volriną quarrą"] = "Volrina_Quarra",
	["volrino quarro"] = "Volrina_Quarra",
    -- Unddan
	["unddan"] = "Unddan",
	["unddana"] = "Unddan",
	["unddanowi"] = "Unddan",
	["unddanem"] = "Unddan",
	["unddanie"] = "Unddan",
    -- Gekunn
	["gekunn"] = "Gekunn",
    -- Gurgozu
	["gurgozu"] = "Gurgozu",
    -- Ronela Giroux
	["ronela giroux"] = "Ronela_Giroux",
	["roneli giroux"] = "Ronela_Giroux",
	["ronelę giroux"] = "Ronela_Giroux",
	["ronelą giroux"] = "Ronela_Giroux",
	["ronelo giroux"] = "Ronela_Giroux",
    -- Nalimeh
	["nalimeh"] = "Nalimeh",
    -- Guy LeBlanc
	["guy leblanc"] = "Guy_LeBlanc",
	["guy leblanca"] = "Guy_LeBlanc",
	["guy leblancowi"] = "Guy_LeBlanc",
	["guy leblancem"] = "Guy_LeBlanc",
	["guy leblancu"] = "Guy_LeBlanc",
    -- Nolaatamil
	["nolaatamil"] = "Nolaatamil",
	["nolaatamila"] = "Nolaatamil",
	["nolaatamilowi"] = "Nolaatamil",
	["nolaatamilem"] = "Nolaatamil",
	["nolaatamilu"] = "Nolaatamil",
    -- Big Ozur
	["big ozur"] = "Big_Ozur",
	["duży ozur"] = "Big_Ozur",
	["dużego ozura"] = "Big_Ozur",
	["dużemu ozurowi"] = "Big_Ozur",
	["dużym ozurem"] = "Big_Ozur",
	["dużym ozurze"] = "Big_Ozur",
    -- Arawe
	["arawe"] = "Arawe",
    -- Indur-sa
	["indur-sa"] = "Indur-sa",
	["indur-sy"] = "Indur-sa",
	["indur-sie"] = "Indur-sa",
	["indur-sę"] = "Indur-sa",
	["indur-są"] = "Indur-sa",
	["indur-so"] = "Indur-sa",
    -- Vanima
	["vanima"] = "Vanima",
	["vanimy"] = "Vanima",
	["vanimie"] = "Vanima",
	["vanimę"] = "Vanima",
	["vanimą"] = "Vanima",
	["vanimo"] = "Vanima",
    -- Wugirus-Sa
	["wugirus-sa"] = "Wugirus-Sa",
	["wugirus-sy"] = "Wugirus-Sa",
	["wugirus-sie"] = "Wugirus-Sa",
	["wugirus-sę"] = "Wugirus-Sa",
	["wugirus-są"] = "Wugirus-Sa",
	["wugirus-so"] = "Wugirus-Sa",
    -- Tumira
	["tumira"] = "Tumira",
	["tumiry"] = "Tumira",
	["tumirze"] = "Tumira",
	["tumirę"] = "Tumira",
	["tumirą"] = "Tumira",
	["tumiro"] = "Tumira",
    -- Narfar War-Wolf
	["narfar war-wolf"] = "Narfar_War-Wolf",
	["narfar wilk wojny"] = "Narfar_War-Wolf",
	["narfara wilka wojny"] = "Narfar_War-Wolf",
	["narfarowi wilkowi wojny"] = "Narfar_War-Wolf",
	["narfarem wilkiem wojny"] = "Narfar_War-Wolf",
	["narfarze wilku wojny"] = "Narfar_War-Wolf",
    -- Akumjhargo
	["akumjhargo"] = "Akumjhargo",
	["akumjharga"] = "Akumjhargo",
	["akumjhargowi"] = "Akumjhargo",
	["akumjhargiem"] = "Akumjhargo",
	["akumjhargu"] = "Akumjhargo",
    -- Songar Brightwind
	["songar brightwind"] = "Songar_Brightwind",
	["songar ciepły wiatr"] = "Songar_Brightwind",
    -- Iner Fathryon
	["iner fathryon"] = "Iner_Fathryon",
	["inera fathryona"] = "Iner_Fathryon",
	["inerowi fathryonowi"] = "Iner_Fathryon",
	["inerem fathryonem"] = "Iner_Fathryon",
	["inerze fathryonie"] = "Iner_Fathryon",
    -- Grand Warlord Zimmeron
	["grand warlord zimmeron"] = "Grand_Warlord_Zimmeron",
	["starszy gubernator wojskowy zimmeron"] = "Grand_Warlord_Zimmeron",
	["starszego gubernatora wojskowego zimmerona"] = "Grand_Warlord_Zimmeron",
	["starszemu gubernatorowi wojskowemu zimmeronowi"] = "Grand_Warlord_Zimmeron",
	["starszym gubernatorem wojskowym zimmeronem"] = "Grand_Warlord_Zimmeron",
	["starszym gubernatorze wojskowym zimmeronie"] = "Grand_Warlord_Zimmeron",
    -- Vashai
	["vashai"] = "Vashai",
    -- Mahadal at-Bergama
	["mahadal at-bergama"] = "Mahadal_at-Bergama",
	["mahadala at-bergamy"] = "Mahadal_at-Bergama",
	["mahadalowi at-bergamie"] = "Mahadal_at-Bergama",
	["mahadalem at-bergamą"] = "Mahadal_at-Bergama",
	["mahadalu at-bergamie"] = "Mahadal_at-Bergama",
	["mahadal z bergamy"] = "Mahadal_at-Bergama",
	["mahadala z bergamy"] = "Mahadal_at-Bergama",
	["mahadalowi z bergamy"] = "Mahadal_at-Bergama",
	["mahadalem z bergamy"] = "Mahadal_at-Bergama",
	["mahadalu z bergamy"] = "Mahadal_at-Bergama",
    -- Heart of Rootwater
	["heart of rootwater"] = "Heart_of_Rootwater",
	["serce korzennej wody"] = "Heart_of_Rootwater",
	["serca korzennej wody"] = "Heart_of_Rootwater",
	["sercu korzennej wody"] = "Heart_of_Rootwater",
	["sercem korzennej wody"] = "Heart_of_Rootwater",
    -- Sees-All-Colors
	["sees-all-colors"] = "Sees-All-Colors",
	["widzi-wszystkie-kolory"] = "Sees-All-Colors",
    -- Adalmor
	["adalmor"] = "Adalmor",
	["adalmora"] = "Adalmor",
	["adalmorowi"] = "Adalmor",
	["adalmorem"] = "Adalmor",
	["adalmorze"] = "Adalmor",
    -- Angbjar the New Guy
	["angbjar the new guy"] = "Angbjar_the_New_Guy",
	["angbjar nowy"] = "Angbjar_the_New_Guy",
	["angbjara nowego"] = "Angbjar_the_New_Guy",
	["angbjarowi nowemu"] = "Angbjar_the_New_Guy",
	["angbjarem nowym"] = "Angbjar_the_New_Guy",
	["angbjarze nowym"] = "Angbjar_the_New_Guy",
    -- Favas Rathri
	["favas rathri"] = "Favas_Rathri",
	["favasa rathri"] = "Favas_Rathri",
	["favasowi rathri"] = "Favas_Rathri",
	["favasem rathri"] = "Favas_Rathri",
	["favasu rathri"] = "Favas_Rathri",
    -- Vanus Galerion
	["vanus galerion"] = "Vanus_Galerion",
	["vanusa galeriona"] = "Vanus_Galerion",
	["vanusowi galerionowi"] = "Vanus_Galerion",
	["vanusem galerionem"] = "Vanus_Galerion",
	["vanusie galerionie"] = "Vanus_Galerion",
    -- Boyoagh
	["boyoagh"] = "Boyoagh",
	["boyoagha"] = "Boyoagh",
	["boyoaghowi"] = "Boyoagh",
	["boyoaghiem"] = "Boyoagh",
	["boyoaghu"] = "Boyoagh",
    -- Garach Wolf-Father
	["garach wolf-father"] = "Garach_Wolf-Father",
	["garach wilczy-ojciec"] = "Garach_Wolf-Father",
	["garacha wilczego-ojca"] = "Garach_Wolf-Father",
	["garachowi wilczemu-ojcu"] = "Garach_Wolf-Father",
	["garachem wilczym-ojcem"] = "Garach_Wolf-Father",
	["garachu wilczym-ojcu"] = "Garach_Wolf-Father",
	["garachu wilczy-ojcze"] = "Garach_Wolf-Father",
    -- Eranamo
	["eranamo"] = "Eranamo",
	["eranama"] = "Eranamo",
	["eranamowi"] = "Eranamo",
	["eranamem"] = "Eranamo",
	["eranamie"] = "Eranamo",
    -- Esona
	["esona"] = "Esona",
	["esony"] = "Esona",
	["esonie"] = "Esona",
	["esonę"] = "Esona",
	["esoną"] = "Esona",
	["esono"] = "Esona",
    -- Rald
	["rald"] = "Rald",
	["ralda"] = "Rald",
	["raldowi"] = "Rald",
	["raldem"] = "Rald",
	["raldzie"] = "Rald",
    -- Amifar Windtorn
	["amifar windtorn"] = "Amifar_Windtorn",
	["amifar szargana wiatrem"] = "Amifar_Windtorn",
	["amifar szarganej wiatrem"] = "Amifar_Windtorn",
	["amifar szarganą wiatrem"] = "Amifar_Windtorn",
    -- Gaulm
	["gaulm"] = "Gaulm",
    -- Aloysius Fulvianus
	["aloysius fulvianus"] = "Aloysius_Fulvianus",
	["aloysiusa fulvianusa"] = "Aloysius_Fulvianus",
	["aloysiusowi fulvianusowi"] = "Aloysius_Fulvianus",
	["aloysiusem fulvianusem"] = "Aloysius_Fulvianus",
	["aloysiusie fulvianusie"] = "Aloysius_Fulvianus",
    -- General Nesh-Tan
	["general nesh-tan"] = "General_Nesh-Tan",
	["generał nesh-tan"] = "General_Nesh-Tan",
    -- Keelsplitter
	["keelsplitter"] = "Keelsplitter",
	["kadłupacz"] = "Keelsplitter",
	["kadłupacza"] = "Keelsplitter",
	["kadłupaczowi"] = "Keelsplitter",
	["kadłupaczem"] = "Keelsplitter",
	["kadłupaczu"] = "Keelsplitter",
    -- Tharag
	["tharag"] = "Tharag",
	["tharaga"] = "Tharag",
	["tharagowi"] = "Tharag",
	["tharagiem"] = "Tharag",
	["tharagu"] = "Tharag",
    -- Marcellia Mero
	["marcellia mero"] = "Marcellia_Mero",
	["marcellii mero"] = "Marcellia_Mero",
	["marcellię mero"] = "Marcellia_Mero",
	["marcellią mero"] = "Marcellia_Mero",
	["marcellio mero"] = "Marcellia_Mero",
    -- Aphia Madalas
	["aphia madalas"] = "Aphia_Madalas",
	["aphii madalas"] = "Aphia_Madalas",
	["aphię madalas"] = "Aphia_Madalas",
	["aphią madalas"] = "Aphia_Madalas",
	["aphio madalas"] = "Aphia_Madalas",
    -- Asvorn Hairy-Legs
	["asvorn hairy-legs"] = "Asvorn_Hairy-Legs",
	["asvorn owłosione-nogi"] = "Asvorn_Hairy-Legs",
	["asvorna owłosionych-nóg"] = "Asvorn_Hairy-Legs",
	["asvornowi owłosionym-nogom"] = "Asvorn_Hairy-Legs",
	["asvornem owłosionymi-nogami"] = "Asvorn_Hairy-Legs",
	["asvornie owłosionych-nogach"] = "Asvorn_Hairy-Legs",
    -- Blodrat
	["blodrat"] = "Blodrat",
	["blodrata"] = "Blodrat",
	["blodratowi"] = "Blodrat",
	["blodratem"] = "Blodrat",
	["blodracie"] = "Blodrat",
    -- Shield-Corporal Thjol
	["shield-corporal thjol"] = "Shield-Corporal_Thjol",
	["kapral-tarczy thjol"] = "Shield-Corporal_Thjol",
	["kaprala-tarczy thjola"] = "Shield-Corporal_Thjol",
	["kapralowi-tarczy thjolowi"] = "Shield-Corporal_Thjol",
	["kapralem-tarczy thjolem"] = "Shield-Corporal_Thjol",
	["kapralu-tarczy thjolu"] = "Shield-Corporal_Thjol",
    -- Atifwe
	["atifwe"] = "Atifwe",
    -- Nurinwae
	["nurinwae"] = "Nurinwae",
    -- Mirise Dres
	["mirise dres"] = "Mirise_Dres",
	["mirise tres"] = "Mirise_Dres",
    -- Gezdak
	["gezdak"] = "Gezdak",
	["gezdaka"] = "Gezdak",
	["gezdakowi"] = "Gezdak",
	["gezdakiem"] = "Gezdak",
	["gezdaku"] = "Gezdak",
    -- Weaves-Nets
	["weaves-nets"] = "Weaves-Nets",
	["plecie-sieci"] = "Weaves-Nets",
    -- Sintaananil
	["sintaananil"] = "Sintaananil",
	["sintaananila"] = "Sintaananil",
	["sintaananilowi"] = "Sintaananil",
	["sintaananilem"] = "Sintaananil",
	["sintaananilu"] = "Sintaananil",
    -- Sahun
	["sahun"] = "Sahun",
	["sahuna"] = "Sahun",
	["sahunowi"] = "Sahun",
	["sahunem"] = "Sahun",
	["sahunie"] = "Sahun",
    -- Corporal Bredrek
	["corporal bredrek"] = "Corporal_Bredrek",
	["kapral bredrek"] = "Corporal_Bredrek",
	["kaprala bredreka"] = "Corporal_Bredrek",
	["kapralowi bredrekowi"] = "Corporal_Bredrek",
	["kapralem bredrekiem"] = "Corporal_Bredrek",
	["kapralu bredreku"] = "Corporal_Bredrek",
    -- Norendo
	["norendo"] = "Norendo_(Soulfire_Plateau)",
	["norendo (soulfire plateau)"] = "Norendo_(Soulfire_Plateau)",
	["norenda"] = "Norendo_(Soulfire_Plateau)",
	["norendowi"] = "Norendo_(Soulfire_Plateau)",
	["norendem"] = "Norendo_(Soulfire_Plateau)",
	["norendzie"] = "Norendo_(Soulfire_Plateau)",
    -- Nalur Garvon
	["nalur garvon"] = "Nalur_Garvon",
	["nalura garvona"] = "Nalur_Garvon",
	["nalurowi garvonowi"] = "Nalur_Garvon",
	["nalurem garvonem"] = "Nalur_Garvon",
	["nalurze garvonie"] = "Nalur_Garvon",
    -- Severin Charnis
	["severin charnis"] = "Severin_Charnis",
	["severina charnisa"] = "Severin_Charnis",
	["severinowi charnisowi"] = "Severin_Charnis",
	["severinem charnisem"] = "Severin_Charnis",
	["severinie charnisie"] = "Severin_Charnis",
    -- Perenius Caudinus
	["perenius caudinus"] = "Perenius_Caudinus",
	["pereniusa caudinusa"] = "Perenius_Caudinus",
	["pereniusowi caudinusowi"] = "Perenius_Caudinus",
	["pereniusem caudinusem"] = "Perenius_Caudinus",
	["pereniusie caudinusie"] = "Perenius_Caudinus",
    -- Grand Warlord Sorcalin
	["grand warlord sorcalin"] = "Grand_Warlord_Sorcalin",
	["starsza gubernator wojskowa sorcalin"] = "Grand_Warlord_Sorcalin",
	["starszej gubernator wojskowej sorcalin"] = "Grand_Warlord_Sorcalin",
	["starszą gubernator wojskową sorcalin"] = "Grand_Warlord_Sorcalin",
    -- King Casimir
	["king casimir"] = "King_Casimir",
	["król casimir"] = "King_Casimir",
	["króla casimira"] = "King_Casimir",
	["królowi casimirowi"] = "King_Casimir",
	["królem casimirem"] = "King_Casimir",
	["królu casimirze"] = "King_Casimir",
    -- General Dar-Liurz
	["general dar-liurz"] = "General_Dar-Liurz",
	["generał dar-liurz"] = "General_Dar-Liurz",
    -- Bittergreen the Wild
	["bittergreen the wild"] = "Bittergreen_the_Wild",
	["goryczak narowisty"] = "Bittergreen_the_Wild",
	["goryczaka narowistego"] = "Bittergreen_the_Wild",
	["goryczakowi narowistemu"] = "Bittergreen_the_Wild",
	["goryczakiem narowistym"] = "Bittergreen_the_Wild",
	["goryczaku narowistym"] = "Bittergreen_the_Wild",
    -- Vykosa the Ascendant
	["vykosa the ascendant"] = "Vykosa_the_Ascendant",
	["vykosa wschodząca"] = "Vykosa_the_Ascendant",
	["vykosy wschodzącej"] = "Vykosa_the_Ascendant",
	["vykosie wschodzącej"] = "Vykosa_the_Ascendant",
	["vykosę wschodzącą"] = "Vykosa_the_Ascendant",
	["vykosą wschodzącą"] = "Vykosa_the_Ascendant",
	["vykoso wschodząca"] = "Vykosa_the_Ascendant",
    -- Ulliceta gra-Kogg
	["ulliceta gra-kogg"] = "Ulliceta_gra-Kogg",
	["ullicety gra-kogg"] = "Ulliceta_gra-Kogg",
	["ullicecie gra-kogg"] = "Ulliceta_gra-Kogg",
	["ullicetę gra-kogg"] = "Ulliceta_gra-Kogg",
	["ullicetą gra-kogg"] = "Ulliceta_gra-Kogg",
	["ulliceto gra-kogg"] = "Ulliceta_gra-Kogg",
    -- Oriell
	["oriell"] = "Oriell",
	["oriella"] = "Oriell",
	["oriellowi"] = "Oriell",
	["oriellem"] = "Oriell",
	["oriellu"] = "Oriell",
    -- Kotholl Ironfist
	["kotholl ironfist"] = "Kotholl_Ironfist",
	["kotholl żelazna pięść"] = "Kotholl_Ironfist",
	["kotholla żelaznej pięści"] = "Kotholl_Ironfist",
	["kothollowi żelaznej pięści"] = "Kotholl_Ironfist",
	["kothollem żelazną pięścią"] = "Kotholl_Ironfist",
	["kothollu żelaznej pięści"] = "Kotholl_Ironfist",
    -- Head-in-Clouds
	["head-in-clouds"] = "Head-in-Clouds",
	["głowa-w-chmurach"] = "Head-in-Clouds",
    -- Hakgrym the Howler
	["hakgrym the howler"] = "Hakgrym_the_Howler",
	["hakgrym wyjec"] = "Hakgrym_the_Howler",
	["hakgryma wyjca"] = "Hakgrym_the_Howler",
	["hakgrymowi wyjcowi"] = "Hakgrym_the_Howler",
	["hakgrymem wyjcem"] = "Hakgrym_the_Howler",
	["hakgrymie wyjcu"] = "Hakgrym_the_Howler",
    -- Magreta
	["magreta"] = "Magreta",
	["magrety"] = "Magreta",
	["magrecie"] = "Magreta",
	["magretę"] = "Magreta",
	["magretą"] = "Magreta",
	["magreto"] = "Magreta",
    -- Drowned First Mate
	["drowned first mate"] = "Drowned_First_Mate",
	["utopiony pierwszy oficer"] = "Drowned_First_Mate",
	["utopionego pierwszego oficera"] = "Drowned_First_Mate",
	["utopionemu pierwszemu oficerowi"] = "Drowned_First_Mate",
	["utopionym pierwszym oficerem"] = "Drowned_First_Mate",
	["utopionym pierwszym oficerze"] = "Drowned_First_Mate",
    -- Nif
	["nif"] = "Nif",
	["nifa"] = "Nif",
	["nifowi"] = "Nif",
	["nifem"] = "Nif",
	["nifie"] = "Nif",
    -- Sinfay
	["sinfay"] = "Sinfay",
    -- Surgeon Andronicus
	["surgeon andronicus"] = "Surgeon_Andronicus",
	["chirurg andronicus"] = "Surgeon_Andronicus",
	["chirurga andronicusa"] = "Surgeon_Andronicus",
	["chirurgowi andronicusowi"] = "Surgeon_Andronicus",
	["chirurgiem andronicusem"] = "Surgeon_Andronicus",
	["chirurgu andronicusie"] = "Surgeon_Andronicus",
    -- Purifier Gunthafur
	["purifier gunthafur"] = "Purifier_Gunthafur",
	["puryfikatorka gunthafur"] = "Purifier_Gunthafur",
	["puryfikatorki gunthafur"] = "Purifier_Gunthafur",
	["puryfikatorce gunthafur"] = "Purifier_Gunthafur",
	["puryfikatorkę gunthafur"] = "Purifier_Gunthafur",
	["puryfikatorką gunthafur"] = "Purifier_Gunthafur",
	["puryfikatorko gunthafur"] = "Purifier_Gunthafur",
    -- Bahtra at-Hunding
	["bahtra at-hunding"] = "Bahtra_at-Hunding",
	["bahtry at-hunding"] = "Bahtra_at-Hunding",
	["bahtrze at-hunding"] = "Bahtra_at-Hunding",
	["bahtrę at-hunding"] = "Bahtra_at-Hunding",
	["bahtrą at-hunding"] = "Bahtra_at-Hunding",
	["bahtro at-hunding"] = "Bahtra_at-Hunding",
    -- Andur
	["andur"] = "Andur",
	["andura"] = "Andur",
	["andurowi"] = "Andur",
	["andurem"] = "Andur",
	["andurze"] = "Andur",
    -- Mograg
	["mograg"] = "Mograg",
    -- Maraamur
	["maraamur"] = "Maraamur",
	["maraamura"] = "Maraamur",
	["maraamurowi"] = "Maraamur",
	["maraamurem"] = "Maraamur",
	["maraamurze"] = "Maraamur",
    -- General Serien
	["general serien"] = "General_Serien",
	["generał serien"] = "General_Serien",
	["generała seriena"] = "General_Serien",
	["generałowi serienowi"] = "General_Serien",
	["generałem serienem"] = "General_Serien",
	["generale serienie"] = "General_Serien",
    ["general aklash"] = "General_Aklash",
    -- Captain Rythe
	["captain rythe"] = "Captain_Rythe",
	["kapitan rythe"] = "Captain_Rythe",
	["kapitana rythe'a"] = "Captain_Rythe",
	["kapitanowi rythe'owi"] = "Captain_Rythe",
	["kapitanem rythe'em"] = "Captain_Rythe",
	["kapitanie rythe'u"] = "Captain_Rythe",
    -- Zymel Etitan
	["zymel etitan"] = "Zymel_Etitan",
	["zymela etitana"] = "Zymel_Etitan",
	["zymelowi etitanowi"] = "Zymel_Etitan",
	["zymelem etitanem"] = "Zymel_Etitan",
	["zymelu etitanie"] = "Zymel_Etitan",
    -- Hyg
	["hyg"] = "Hyg",
	["hyga"] = "Hyg",
	["hygowi"] = "Hyg",
	["hygiem"] = "Hyg",
	["hygu"] = "Hyg",
    -- Zarum
	["zarum"] = "Zarum_(Pęknina)",
	["zarum (pęknina)"] = "Zarum_(Pęknina)",
	["zaruma"] = "Zarum_(Pęknina)",
	["zarumowi"] = "Zarum_(Pęknina)",
	["zarumem"] = "Zarum_(Pęknina)",
	["zarumie"] = "Zarum_(Pęknina)",
    -- Selene
	["selene"] = "Selene",
    -- Vurvyn
	["vurvyn (nimalten)"] = "Vurvyn_(Nimalten)",
	["vurvyna (nimalten)"] = "Vurvyn_(Nimalten)",
	["vurvynowi (nimalten)"] = "Vurvyn_(Nimalten)",
	["vurvynem (nimalten)"] = "Vurvyn_(Nimalten)",
	["vurvynie (nimalten)"] = "Vurvyn_(Nimalten)",
    -- Dohna Indoril
	["dohna indoril"] = "Dohna_Indoril",
	["dohny indorila"] = "Dohna_Indoril",
	["dohnie indorilowi"] = "Dohna_Indoril",
	["dohnę indorila"] = "Dohna_Indoril",
	["dohną indorilem"] = "Dohna_Indoril",
	["dohnie indorilu"] = "Dohna_Indoril",
    -- Sashee
	["sashee"] = "Sashee",
    -- Chef Amadour
	["chef amadour"] = "Chef_Amadour",
	["szef kuchni amadour"] = "Chef_Amadour",
	["szefa kuchni amadoura"] = "Chef_Amadour",
	["szefowi kuchni amadourowi"] = "Chef_Amadour",
	["szefem kuchni amadourem"] = "Chef_Amadour",
	["szefie kuchni amadourze"] = "Chef_Amadour",
    -- Jur
	["jur"] = "Jur",
	["jura"] = "Jur",
	["jurowi"] = "Jur",
	["jurem"] = "Jur",
	["jurze"] = "Jur",
    -- Felrar
	["felrar"] = "Felrar",
	["felrara"] = "Felrar",
	["felrarowi"] = "Felrar",
	["felrarem"] = "Felrar",
	["felrarze"] = "Felrar",
    -- Faer
	["faer"] = "Faer",
	["faera"] = "Faer",
	["faerowi"] = "Faer",
	["faerem"] = "Faer",
	["faerze"] = "Faer",
    -- Khabodir
	["khabodir"] = "Khabodir",
	["khabodira"] = "Khabodir",
	["khabodirowi"] = "Khabodir",
	["khabodirem"] = "Khabodir",
	["khabodirze"] = "Khabodir",
    -- Blaise Chatillon
	["blaise chatillon"] = "Blaise_Chatillon",
	["blaise'a chatillona"] = "Blaise_Chatillon",
	["blaise'owi chatillonowi"] = "Blaise_Chatillon",
	["blaise'em chatillonem"] = "Blaise_Chatillon",
	["blaise'u chatillonie"] = "Blaise_Chatillon",
    -- Trader Renko
	["trader renko"] = "Trader_Renko",
	["handlarz renko"] = "Trader_Renko",
	["handlarza renko"] = "Trader_Renko",
	["handlarzowi renko"] = "Trader_Renko",
	["handlarzem renko"] = "Trader_Renko",
	["handlarzu renko"] = "Trader_Renko",
    -- Eyes-of-Steel
	["eyes-of-steel"] = "Eyes-of-Steel",
	["oczy-ze-stali"] = "Eyes-of-Steel",
    -- Ghain
	["ghain"] = "Ghain",
	["ghaina"] = "Ghain",
	["ghainowi"] = "Ghain",
	["ghainem"] = "Ghain",
	["ghainie"] = "Ghain",
	-- Bone Grappler
	["bone grappler"] = "Bone_Grappler",
	["kościoplot"] = "Bone_Grappler",
	["kościoplota"] = "Bone_Grappler",
	["kościoplotowi"] = "Bone_Grappler",
	["kościoplotem"] = "Bone_Grappler",
	["kościoplocie"] = "Bone_Grappler",
	-- tarak silver-claw
	["tarak silver-claw"] = "Tarak_Silver-Claw", -- brak w grze
	-- Beridi Hairy-Legs
	["beridi owłosione-nogi"] = "Beridi_Hairy-Legs",
	["beridi hairy-legs"] = "Beridi_Hairy-Legs",
	-- Euda
	["euda"] = "Euda",
	["eudy"] = "Euda",
	["eudzie"] = "Euda",
	["eudę"] = "Euda",
	["eudą"] = "Euda",
	["eudo"] = "Euda",
	-- Gentle-Heart (Łagodne-Serce)
	["gentle-heart"] = "Gentle-Heart",
	["łagodne-serce"] = "Gentle-Heart",
	-- Predicant Maera
	["predicant maera"] = "Predicant_Maera",
	["predykantka maera"] = "Predicant_Maera",
	["predykantki maery"] = "Predicant_Maera",
	["predykantce maerze"] = "Predicant_Maera",
	["predykantkę maerę"] = "Predicant_Maera",
	["predykantką maerą"] = "Predicant_Maera",
	-- Mel Adrys
	["mel adrys"] = "Mel_Adrys",
	["mela adrysa"] = "Mel_Adrys",
	["melowi adrysowi"] = "Mel_Adrys",
	["melem adrysem"] = "Mel_Adrys",
	["melu adrysie"] = "Mel_Adrys",
	-- Floofer
	["floofer"] = "Floofer",
	["floofera"] = "Floofer",
	["flooferowi"] = "Floofer",
	["flooferem"] = "Floofer",
	["flooferze"] = "Floofer",
	-- Pippers (Ponurak)
	["pippers"] = "Pippers",
	["ponurak"] = "Pippers",
	["ponuraka"] = "Pippers",
	["ponurakowi"] = "Pippers",
	["ponurakiem"] = "Pippers",
	["ponuraku"] = "Pippers",
	-- Grazda
	["grazda"] = "Grazda",
	["grazdy"] = "Grazda",
	["grazdzie"] = "Grazda",
	["grazdę"] = "Grazda",
	["grazdą"] = "Grazda",
	["grazdo"] = "Grazda",
	-- Ganthis
	["ganthis"] = "Ganthis",
	["ganthisa"] = "Ganthis",
	["ganthisowi"] = "Ganthis",
	["ganthisem"] = "Ganthis",
	["ganthisie"] = "Ganthis",
----------------------------------------------------------------------------------------------------------------------------
	-- Postacie koniec--
----------------------------------------------------------------------------------------------------------------------------   
----------------------------------------------------------------------------------------------------------------------------
	-- Przedmioty start--
----------------------------------------------------------------------------------------------------------------------------   
	-- Stop do hartowania
    ["tempering alloy"] = "Tempering_Alloy",                 --  en=pl
    ["stop do hartowania"] = "Tempering_Alloy",
    ["stopu do hartowania"] = "Tempering_Alloy",   
    ["stopowi do hartowania"] = "Tempering_Alloy",   
    ["stopem do hartowania"] = "Tempering_Alloy",  
    ["stopie do hartowania"] = "Tempering_Alloy", 
	-- Łańcuch Zmiennokształtnych
    ["shapeshifter's chain"] = "Shapeshifter's_Chain",             --  en=pl
    ["łańcuch zmiennokształtnych"] = "Shapeshifter's_Chain",    
    ["łańcucha zmiennokształtnych"] = "Shapeshifter's_Chain",     
    ["łańcuchowi zmiennokształtnych"] = "Shapeshifter's_Chain",   
    ["łańcuchem zmiennokształtnych"] = "Shapeshifter's_Chain",    
    ["łańcuchu zmiennokształtnych"] = "Shapeshifter's_Chain",     
	-- Serce Róży
    ["briarheart"] = "Serce_róży",                       --  en=pl
    ["serce róży"] = "Serce_róży",  
    ["serca róży"] = "Serce_róży",             
    ["sercu róży"] = "Serce_róży",         
    ["sercem róży"] = "Serce_róży",            
	-- Miód
	["miód"] = "Miód",
	-- Amulet Królów Chwały
	["the amulet of the kings of glory"] = "Amulet_Królów",
	["amulet królów"] = "Amulet_Królów",
	["amulet królów chwały"] = "Amulet_Królów",
	["amuletu królów chwały"] = "Amulet_Królów",
	["amuletowi królów chwały"] = "Amulet_Królów",
	["amulet królów chwały"] = "Amulet_Królów",
	["amuletem królów chwały"] = "Amulet_Królów",
	["amulecie królów chwały"] = "Amulet_Królów",
	["amulecie królów chwały"] = "Amulet_Królów",
	-- Trofeum z czaszki indrika
	["indrik skull trophy"] = "Indrik_Skull_Trophy",
	["trofeum z czaszki indrika"] = "Indrik_Skull_Trophy",
	-- Goryczak
	["bittergreen"] = "Goryczak",
	["goryczak"] = "Goryczak",
	["goryczaka"] = "Goryczak",
	["goryczakowi"] = "Goryczak",
	["goryczakiem"] = "Goryczak",
	["goryczaku"] = "Goryczak",
	-- Pierścień Dzikich Łowów
	["ring of the wild hunt"] = "Ring_of_the_Wild_Hunt",
	["pierścień dzikich łowów"] = "Ring_of_the_Wild_Hunt",
	["pierścienia dzikich łowów"] = "Ring_of_the_Wild_Hunt",
	["pierścieniowi dzikich łowów"] = "Ring_of_the_Wild_Hunt",
	["pierścieniem dzikich łowów"] = "Ring_of_the_Wild_Hunt",
	["pierścieniu dzikich łowów"] = "Ring_of_the_Wild_Hunt",
	-- Czaszka Spaczenia
	["skull of corruption"] = "Czaszka_Spaczenia",
	["czaszka spaczenia"] = "Czaszka_Spaczenia",
	["czaszki spaczenia"] = "Czaszka_Spaczenia",
	["czaszce spaczenia"] = "Czaszka_Spaczenia",
	["czaszkę spaczenia"] = "Czaszka_Spaczenia",
	["czaszką spaczenia"] = "Czaszka_Spaczenia",
	["czaszko spaczenia"] = "Czaszka_Spaczenia",
	-- Mortuum Vivicus
	["mortuum vivicus"] = "Mortuum_Vivicus", --  en=pl
	-- Frost Mirriam
	["frost mirriam"] = "Mroźna_Mirriam",
	["mroźna mirriam"] = "Mroźna_Mirriam",
	["mroźnej mirriam"] = "Mroźna_Mirriam",
	["mroźną mirriam"] = "Mroźna_Mirriam",
	-- Werewolf Musk Oil
	["werewolf musk oil"] = "Werewolf_Musk_Oil",
	["olejek piżmowy z wilkołaka"] = "Werewolf_Musk_Oil",
	["olejku piżmowego z wilkołaka"] = "Werewolf_Musk_Oil",
	["olejkowi piżmowemu z wilkołaka"] = "Werewolf_Musk_Oil",
	["olejkiem piżmowym z wilkołaka"] = "Werewolf_Musk_Oil",
	["olejku piżmowym z wilkołaka"] = "Werewolf_Musk_Oil",
	-- Corn Flower
	["corn flower"] = "Corn_Flower",
	["chaber bławatek"] = "Corn_Flower",
	["chabra bławatka"] = "Corn_Flower",
	["chabrowi bławatkowi"] = "Corn_Flower",
	["chabrem bławatkiem"] = "Corn_Flower",
	["chabrze bławatku"] = "Corn_Flower",
	    -- Crown of Verity
	["crown of verity"] = "Crown_of_Verity",
	["korona prawości"] = "Crown_of_Verity",
	["korony prawości"] = "Crown_of_Verity",
	["koronie prawości"] = "Crown_of_Verity",
	["koronę prawości"] = "Crown_of_Verity",
	["koroną prawości"] = "Crown_of_Verity",
	["korono prawości"] = "Crown_of_Verity",
	-- Ivory Hircine Totem
	["ivory hircine totem"] = "Ivory_Hircine_Totem",
	["totem hircyna z kości słoniowej"] = "Ivory_Hircine_Totem",
	["totemu hircyna z kości słoniowej"] = "Ivory_Hircine_Totem",
	["totemowi hircyna z kości słoniowej"] = "Ivory_Hircine_Totem",
	["totemem hircyna z kości słoniowej"] = "Ivory_Hircine_Totem",
	["totemie hircyna z kości słoniowej"] = "Ivory_Hircine_Totem",
	-- Dirge of Thorns
	["dirge of thorns"] = "Dirge_of_Thorns",
	["lament cierni"] = "Dirge_of_Thorns",
	["lamentu cierni"] = "Dirge_of_Thorns",
	["lamentowi cierni"] = "Dirge_of_Thorns",
	["lamentem cierni"] = "Dirge_of_Thorns",
	["lamencie cierni"] = "Dirge_of_Thorns",
	-- Dwarven Oil
	["dwarven oil"] = "Krasnoludzki_olej",
	["krasnoludzki olej"] = "Krasnoludzki_olej",
	["krasnoludzkiego oleju"] = "Krasnoludzki_olej",
	["krasnoludzkiemu olejowi"] = "Krasnoludzki_olej",
	["krasnoludzkim olejem"] = "Krasnoludzki_olej",
	["krasnoludzkim oleju"] = "Krasnoludzki_olej",
	-- Nirnroot
	["nirnroot"] = "Korzeń_nirnu",
	["korzeń nirnu"] = "Korzeń_nirnu",
	["korzenia nirnu"] = "Korzeń_nirnu",
	["korzeniowi nirnu"] = "Korzeń_nirnu",
	["korzeniem nirnu"] = "Korzeń_nirnu",
	["korzeniu nirnu"] = "Korzeń_nirnu",
	-- Metheglin
	["metheglin"] = "Metheglin",
	["miód pitny sycony"] = "Metheglin",
	["miodu pitnego syconego"] = "Metheglin",
	["miodowi pitnemu syconemu"] = "Metheglin",
	["miodem pitnym syconym"] = "Metheglin",
	["miodzie pitnym syconym"] = "Metheglin",
	-- Rueful Axe
	["rueful axe"] = "Topór_Smutku",
	["topór smutku"] = "Topór_Smutku",
	["topora smutku"] = "Topór_Smutku",
	["toporowi smutku"] = "Topór_Smutku",
	["toporem smutku"] = "Topór_Smutku",
	["toporze smutku"] = "Topór_Smutku",
	-- Grain Solvent
	["grain solvent"] = "Grain_Solvent",
	["pasta do wytrawiania"] = "Grain_Solvent",
	["pasty do wytrawiania"] = "Grain_Solvent",
	["paście do wytrawiania"] = "Grain_Solvent",
	["pastę do wytrawiania"] = "Grain_Solvent",
	["pastą do wytrawiania"] = "Grain_Solvent",
	-- Giovessen Skull
	["giovessen skull"] = "Giovessen_Skull",
	["giovesseńska czaszka"] = "Giovessen_Skull",
	["giovesseńskiej czaszki"] = "Giovessen_Skull",
	["giovesseńskiej czaszce"] = "Giovessen_Skull",
	["giovesseńską czaszkę"] = "Giovessen_Skull",
	["giovesseńską czaszką"] = "Giovessen_Skull",
	-- Ivory-Handled Gooblet Cat Toy
	["ivory-handled gooblet cat toy"] = "Ivory-Handled_Gooblet_Cat_Toy",
	["zabawka dla kota z piór i kości słoniowej"] = "Ivory-Handled_Gooblet_Cat_Toy",
	["zabawki dla kota z piór i kości słoniowej"] = "Ivory-Handled_Gooblet_Cat_Toy",
	["zabawce dla kota z piór i kości słoniowej"] = "Ivory-Handled_Gooblet_Cat_Toy",
	["zabawkę dla kota z piór i kości słoniowej"] = "Ivory-Handled_Gooblet_Cat_Toy",
	["zabawką dla kota z piór i kości słoniowej"] = "Ivory-Handled_Gooblet_Cat_Toy",
	-- Kukurydza
	["kukurydza"] = "Kukurydza",
	["kukurydzy"] = "Kukurydza",
	["kukurydzę"] = "Kukurydza",
	["kukurydzą"] = "Kukurydza",
----------------------------------------------------------------------------------------------------------------------------
	-- Kontynety start--
---------------------------------------------------------------------------------------------------------------------------- 	
	["aldmeris"] = "Aldmeris",
	-- Atmora
	["atmora"] = "Atmora",
	["atmory"] = "Atmora",
	["atmorze"] = "Atmora",
	["atmorę"] = "Atmora",
	["atmorą"] = "Atmora",
	["atmoro"] = "Atmora",
	-- Tamriel
	["tamriel"] = "Tamriel",
	----------------------------------------------------------------------------------------------------------------------------
	-- Kontynety koniec--
---------------------------------------------------------------------------------------------------------------------------- 	
----------------------------------------------------------------------------------------------------------------------------
	-- Stworzenia start--
---------------------------------------------------------------------------------------------------------------------------- 
    -- Alit
	["alit"] = "Alit",
	["alita"] = "Alit",
	["alitowi"] = "Alit",
	["alitem"] = "Alit",
	["alicie"] = "Alit",
    -- Rabbit
	["rabbit"] = "Królik",
	["królik"] = "Królik",
	["królika"] = "Królik",
	["królikowi"] = "Królik",
	["królikiem"] = "Królik",
	["króliku"] = "Królik",
    -- Echatere
	["echatere"] = "Echatere",
	["echatera"] = "Echatere",
	["echatery"] = "Echatere",
	["echaterze"] = "Echatere",
	["echaterę"] = "Echatere",
	["echaterą"] = "Echatere",
    -- Giant
	["giant"] = "Giant",
	["gigant"] = "Giant",
	["giganta"] = "Giant",
	["gigantowi"] = "Giant",
	["gigantem"] = "Giant",
	["gigancie"] = "Giant",
    -- Silt Strider
	["silt strider"] = "Łazik",
	["łazik"] = "Łazik",
	["łazika"] = "Łazik",
	["łazikowi"] = "Łazik",
	["łazikiem"] = "Łazik",
	["łaziku"] = "Łazik",
    -- Thorn Gecko
	["thorn gecko"] = "Thorn_Gecko",
	["kolczasty gekon"] = "Thorn_Gecko",
	["kolczastego gekona"] = "Thorn_Gecko",
	["kolczastemu gekonowi"] = "Thorn_Gecko",
	["kolczastym gekonem"] = "Thorn_Gecko",
	["kolczastym gekonie"] = "Thorn_Gecko",
    -- Bog Dog
	["bog dog"] = "Bog_Dog",
	["bagienny pies"] = "Bog_Dog",
	["bagiennego psa"] = "Bog_Dog",
	["bagiennemu psu"] = "Bog_Dog",
	["bagiennym psem"] = "Bog_Dog",
	["bagiennym psie"] = "Bog_Dog",
    -- Waft
	["waft"] = "Waft",
	["powiew"] = "Waft",
	["powiewu"] = "Waft",
	["powiewowi"] = "Waft",
	["powiewem"] = "Waft",
	["powiewie"] = "Waft",
    -- Draugr
	["draugr"] = "Draugr",
	["draugra"] = "Draugr",
	["draugrowi"] = "Draugr",
	["draugrem"] = "Draugr",
	["draugrze"] = "Draugr",
    -- Faolchu the Changeling
	["faolchu the changeling"] = "Changeling",
	["faolchu przemieniony"] = "Changeling",
	["faolchu przemienionego"] = "Changeling",
	["faolchu przemienionemu"] = "Changeling",
	["faolchu przemienionym"] = "Changeling",
    -- Gryphon
	["gryphon"] = "Gryphon",
	["gryf"] = "Gryphon",
	["gryfa"] = "Gryphon",
	["gryfowi"] = "Gryphon",
	["gryfem"] = "Gryphon",
	["gryfie"] = "Gryphon",
    -- Horker
	["horker"] = "Horker",
	["horkera"] = "Horker",
	["horkerowi"] = "Horker",
	["horkerem"] = "Horker",
	["horkerze"] = "Horker",
    -- Draugulf
	["draugulf"] = "Draugulf",
	["draugowilk"] = "Draugulf",
	["draugowilka"] = "Draugulf",
	["draugowilkowi"] = "Draugulf",
	["draugowilkiem"] = "Draugulf",
	["draugowilku"] = "Draugulf",
    -- Solstheim Shiver Wolf
	["solstheim shiver wolf"] = "Solstheim_Shiver_Wolf",
	["dygoczący wilk z solstheim"] = "Solstheim_Shiver_Wolf",
	["dygoczącego wilka z solstheim"] = "Solstheim_Shiver_Wolf",
	["dygoczącemu wilkowi z solstheim"] = "Solstheim_Shiver_Wolf",
	["dygoczącym wilkiem z solstheim"] = "Solstheim_Shiver_Wolf",
	["dygoczącym wilku z solstheim"] = "Solstheim_Shiver_Wolf",
    -- Storm Wyrm
	["storm wyrm"] = "Storm_Wyrm",
	["burzowy żmij"] = "Storm_Wyrm",
	["burzowego żmija"] = "Storm_Wyrm",
	["burzowemu żmijowi"] = "Storm_Wyrm",
	["burzowym żmijem"] = "Storm_Wyrm",
	["burzowym żmiju"] = "Storm_Wyrm",
    -- Sa-m'Athra
	["sa-m'athra"] = "Sa-m'Athra",
	["sa-m'athry"] = "Sa-m'Athra",
	["sa-m'athrze"] = "Sa-m'Athra",
	["sa-m'athrę"] = "Sa-m'Athra",
	["sa-m'athrą"] = "Sa-m'Athra",
    -- Sabre Cat
	["sabre cat"] = "Kot_szablozębny",
	["kot szablozębny"] = "Kot_szablozębny",
	["kota szablozębnego"] = "Kot_szablozębny",
	["kotu szablozębnemu"] = "Kot_szablozębny",
	["kotem szablozębnym"] = "Kot_szablozębny",
	["kocie szablozębnym"] = "Kot_szablozębny",
    -- Bone Hawk
	["bone hawk"] = "Kościany_jastrząb",
	["kościany jastrząb"] = "Kościany_jastrząb",
	["kościanego jastrzębia"] = "Kościany_jastrząb",
	["kościanemu jastrzębiowi"] = "Kościany_jastrząb",
	["kościanym jastrzębiem"] = "Kościany_jastrząb",
	["kościanym jastrzębiu"] = "Kościany_jastrząb",
    -- Mudcrab
	["mudcrab"] = "Krab_błotny",
	["krab błotny"] = "Krab_błotny",
	["kraba błotnego"] = "Krab_błotny",
	["krabowi błotnemu"] = "Krab_błotny",
	["krabem błotnym"] = "Krab_błotny",
	["krabie błotnym"] = "Krab_błotny",
    -- Rat
	["rat"] = "Szczur",
	["szczur"] = "Szczur",
	["szczura"] = "Szczur",
	["szczurowi"] = "Szczur",
	["szczurem"] = "Szczur",
	["szczurze"] = "Szczur",
    -- Mammoth
	["mammoth"] = "Mamut",
	["mamut"] = "Mamut",
	["mamuta"] = "Mamut",
	["mamutowi"] = "Mamut",
	["mamutem"] = "Mamut",
	["mamucie"] = "Mamut",
    -- Ornaug
	["ornaug"] = "Ornaug",
	["ornauga"] = "Ornaug",
	["ornaugowi"] = "Ornaug",
	["ornaugiem"] = "Ornaug",
	["ornaugu"] = "Ornaug",
    -- Addax
	["addax"] = "Adaks",
	["adaks"] = "Adaks",
	["adaksa"] = "Adaks",
	["adaksowi"] = "Adaks",
	["adaksem"] = "Adaks",
	["adaksie"] = "Adaks",
    -- Wild Hunt Wolf
	["wild hunt wolf"] = "Wild_Hunt_Wolf",
	["wilk dzikich łowów"] = "Wild_Hunt_Wolf",
	["wilka dzikich łowów"] = "Wild_Hunt_Wolf",
	["wilkowi dzikich łowów"] = "Wild_Hunt_Wolf",
	["wilkiem dzikich łowów"] = "Wild_Hunt_Wolf",
	["wilku dzikich łowów"] = "Wild_Hunt_Wolf",
    -- Ice Wraith
	["ice wraith"] = "Lodowy_upiór",
	["lodowy upiór"] = "Lodowy_upiór",
	["lodowego upiora"] = "Lodowy_upiór",
	["lodowemu upiorowi"] = "Lodowy_upiór",
	["lodowym upiorem"] = "Lodowy_upiór",
	["lodowym upiorze"] = "Lodowy_upiór",
    -- Flame Wyrm
	["flame wyrm"] = "Ognisty_żmij",
	["płomienny żmij"] = "Ognisty_żmij",
	["płomiennego żmija"] = "Ognisty_żmij",
	["płomiennemu żmijowi"] = "Ognisty_żmij",
	["płomiennym żmijem"] = "Ognisty_żmij",
	["płomiennym żmiju"] = "Ognisty_żmij",
    -- Squirrel
	["squirrel"] = "Wiewiórka",
	["wiewiórka"] = "Wiewiórka",
	["wiewiórki"] = "Wiewiórka",
	["wiewiórce"] = "Wiewiórka",
	["wiewiórkę"] = "Wiewiórka",
	["wiewiórką"] = "Wiewiórka",
    -- Death Hound
	["death hound"] = "Ogar_śmierci",
	["ogar śmierci"] = "Ogar_śmierci",
	["ogara śmierci"] = "Ogar_śmierci",
	["ogarowi śmierci"] = "Ogar_śmierci",
	["ogarem śmierci"] = "Ogar_śmierci",
	["ogarze śmierci"] = "Ogar_śmierci",
    -- Titanborn's Revelry Wolf
	["titanborn's revelry wolf"] = "Titanborn's_Revelry_Wolf",
	["biesiadny wilk dziecięcia tytanów"] = "Titanborn's_Revelry_Wolf",
	["biesiadnego wilka dziecięcia tytanów"] = "Titanborn's_Revelry_Wolf",
	["biesiadnemu wilkowi dziecięcia tytanów"] = "Titanborn's_Revelry_Wolf",
	["biesiadnym wilkiem dziecięcia tytanów"] = "Titanborn's_Revelry_Wolf",
	["biesiadnym wilku dziecięcia tytanów"] = "Titanborn's_Revelry_Wolf",
    -- Minotaur
	["minotaur"] = "Minotaur",
	["minotaura"] = "Minotaur",
	["minotaurowi"] = "Minotaur",
	["minotaurem"] = "Minotaur",
	["minotaurze"] = "Minotaur",
    -- Werewolf
	["werewolf"] = "Wilkołak",
	["wilkołak"] = "Wilkołak",
	["wilkołaka"] = "Wilkołak",
	["wilkołakowi"] = "Wilkołak",
	["wilkołakiem"] = "Wilkołak",
	["wilkołaku"] = "Wilkołak",
    -- Wraithtide Wolf
	["wraithtide wolf"] = "Wraithtide_Wolf",
	["wilk upiornej fali"] = "Wraithtide_Wolf",
	["wilka upiornej fali"] = "Wraithtide_Wolf",
	["wilkowi upiornej fali"] = "Wraithtide_Wolf",
	["wilkiem upiornej fali"] = "Wraithtide_Wolf",
	["wilku upiornej fali"] = "Wraithtide_Wolf",
    -- Spectral Wolf
	["spectral wolf"] = "Widmowy_ogar_bojowy",
	["spektralny wilk"] = "Widmowy_ogar_bojowy",
	["spektralnego wilka"] = "Widmowy_ogar_bojowy",
	["spektralnemu wilkowi"] = "Widmowy_ogar_bojowy",
	["spektralnym wilkiem"] = "Widmowy_ogar_bojowy",
	["spektralnym wilku"] = "Widmowy_ogar_bojowy",
    -- Solstheim Lunar Wolf
	["solstheim lunar wolf"] = "Solstheim_Lunar_Wolf",
	["księżycowy wilk solstheim"] = "Solstheim_Lunar_Wolf",
	["księżycowego wilka solstheim"] = "Solstheim_Lunar_Wolf",
	["księżycowemu wilkowi solstheim"] = "Solstheim_Lunar_Wolf",
	["księżycowym wilkiem solstheim"] = "Solstheim_Lunar_Wolf",
	["księżycowym wilku solstheim"] = "Solstheim_Lunar_Wolf",
----------------------------------------------------------------------------------------------------------------------------
	-- Stworzenia koniec--
---------------------------------------------------------------------------------------------------------------------------- 
----------------------------------------------------------------------------------------------------------------------------
	-- Organizacje start--
---------------------------------------------------------------------------------------------------------------------------- 
    -- Wolfpack
	["wolfpack"] = "Wolfpack",
	["wataha"] = "Wolfpack",
	["watahy"] = "Wolfpack",
	["watasze"] = "Wolfpack",
	["watahę"] = "Wolfpack",
	["watahą"] = "Wolfpack",
    -- Gold Coast Mercenaries
	["gold coast mercenaries"] = "Gold_Coast_Mercenaries",
	["najemnicy złotego wybrzeża"] = "Gold_Coast_Mercenaries",
	["najemników złotego wybrzeża"] = "Gold_Coast_Mercenaries",
	["najemnikom złotego wybrzeża"] = "Gold_Coast_Mercenaries",
	["najemnikami złotego wybrzeża"] = "Gold_Coast_Mercenaries",
	["najemnikach złotego wybrzeża"] = "Gold_Coast_Mercenaries",
    -- Hounds of Hircine
	["hounds of hircine"] = "Hounds_of_Hircine",
	["ogary hircyna"] = "Hounds_of_Hircine",
	["ogarów hircyna"] = "Hounds_of_Hircine",
	["ogarom hircyna"] = "Hounds_of_Hircine",
	["ogarami hircyna"] = "Hounds_of_Hircine",
	["ogarach hircyna"] = "Hounds_of_Hircine",
    -- Death Hunters
	["death hunters"] = "Death_Hunters",
	["łowcy śmierci"] = "Death_Hunters",
	["łowców śmierci"] = "Death_Hunters",
	["łowcom śmierci"] = "Death_Hunters",
	["łowcami śmierci"] = "Death_Hunters",
	["łowcach śmierci"] = "Death_Hunters",
    -- Legion Zero
	["legion zero"] = "Legion_Zero",
	["legionu zero"] = "Legion_Zero",
	["legionowi zero"] = "Legion_Zero",
	["legionem zero"] = "Legion_Zero",
	["legionie zero"] = "Legion_Zero",
    -- Jovial Lambasters
	["jovial lambasters"] = "Jovial_Lambasters",
	["jowialni biczownicy"] = "Jovial_Lambasters",
	["jowialnych biczowników"] = "Jovial_Lambasters",
	["jowialnym biczownikom"] = "Jovial_Lambasters",
	["jowialnymi biczownikami"] = "Jovial_Lambasters",
	["jowialnych biczownikach"] = "Jovial_Lambasters",
    -- The Society of the Dragon
	["society of the dragon"] = "Society_of_the_Dragon",
	["stronnictwo smoka"] = "Society_of_the_Dragon",
	["stronnictwa smoka"] = "Society_of_the_Dragon",
	["stronnictwu smoka"] = "Society_of_the_Dragon",
	["stronnictwem smoka"] = "Society_of_the_Dragon",
	["stronnictwie smoka"] = "Society_of_the_Dragon",
    -- Skull-Brethren
	["skull-brethren"] = "Skull-Brethren",
	["bracia czaszki"] = "Skull-Brethren",
	["braci czaszki"] = "Skull-Brethren",
	["braciom czaszki"] = "Skull-Brethren",
	["braćmi czaszki"] = "Skull-Brethren",
	["braciach czaszki"] = "Skull-Brethren",
----------------------------------------------------------------------------------------------------------------------------
	-- Organizacje koniec--
---------------------------------------------------------------------------------------------------------------------------- 	
----------------------------------------------------------------------------------------------------------------------------
	-- Frakcje start--
---------------------------------------------------------------------------------------------------------------------------- 	
	-- Ebonheart Pact
	["ebonheart pact"] = "Pakt_Ebonheart",
	["pakt ebonheart"] = "Pakt_Ebonheart",
	["paktu ebonheart"] = "Pakt_Ebonheart",
	["paktowi ebonheart"] = "Pakt_Ebonheart",
	["paktem ebonheart"] = "Pakt_Ebonheart",
	["pakcie ebonheart"] = "Pakt_Ebonheart",
}


-- =========================
-- POMOCNICZE FUNKCJE DO GENEROWANIA ALIASÓW
-- =========================

-- ZMIANA: Wyczyszczona lista końcówek, aby nie generować automatów
local polishNounSuffixes = {
    "",       -- Tylko Mianownik (bazowa forma)
    -- "a",      <-- Zakomentowane, żeby nie dodawało automatycznie
    -- "u",
    -- "owi",
    -- "em",
    -- "ie",
    -- "ze",
    -- "e",
    -- "ów",
    -- "om",
    -- "ami",
    -- "ach",
    -- "y",
    -- "i",
    -- "owie",
}

-- Funkcja generująca podstawowe odmiany
-- Teraz zwróci tylko bazową formę, resztę dopiszesz ręcznie w sekcji ALIASY
function LoreTooltips.GenerateAliases(baseForm, wikiKey)
    local results = {}
    local baseLower = baseForm:lower()
    
    -- Dodaj bazową formę
    results[baseLower] = wikiKey
    
    -- Generuj odmiany (teraz pętla wykona się tylko dla pustego ciągu "", czyli nie doda śmieci)
    for _, suffix in ipairs(polishNounSuffixes) do
        if suffix ~= "" then
            local variant = baseLower .. suffix
            results[variant] = wikiKey
        end
    end
    
    -- Wypisz wyniki do skopiowania
    d("|cFFD700[LoreAliases]|r Wygenerowane (baza):")
    d("    -- " .. baseForm)
    for alias, key in pairs(results) do
        d('    ["' .. alias .. '"] = "' .. key .. '",')
    end
    d("-- Tu dopisz ręcznie pozostałe odmiany...")
    
    return results
end

-- Funkcja do dodawania aliasów w runtime (tymczasowo, do testów)
function LoreTooltips.AddAlias(alias, wikiKey)
    if not LoreTooltips.Aliases then
        LoreTooltips.Aliases = {}
    end
    LoreTooltips.Aliases[alias:lower()] = wikiKey
    d("|cFFD700[LoreAliases]|r Dodano alias: '" .. alias .. "' -> " .. wikiKey)
end

-- Funkcja do masowego dodawania aliasów
-- Przykład: /script LoreTooltips.AddAliasesForKey("Orsimer", {"ork", "orka", "orkiem"})
function LoreTooltips.AddAliasesForKey(wikiKey, aliasList)
    for _, alias in ipairs(aliasList) do
        LoreTooltips.AddAlias(alias, wikiKey)
    end
end

-- =========================
-- GENERATOR KODU Z OKNEM DO KOPIOWANIA
-- =========================

-- Pomocnicza funkcja tworząca okienko (GUI)
local function ShowCopyDialog(title, text)
    local winName = "LoreTooltipsCopyWindow"
    local tlw = _G[winName]
    
    -- Tworzenie okna, jeśli jeszcze nie istnieje
    if not tlw then
        tlw = WINDOW_MANAGER:CreateTopLevelWindow(winName)
        tlw:SetDimensions(600, 500)
        tlw:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        tlw:SetMouseEnabled(true)
        tlw:SetMovable(true)
        tlw:SetHidden(false)
        
        -- Tło
        local bg = WINDOW_MANAGER:CreateControl("$(parent)Bg", tlw, CT_BACKDROP)
        bg:SetAnchorFill()
        bg:SetCenterColor(0,0,0, 0.9)
        bg:SetEdgeColor(0.6, 0.6, 0.6, 1)
        bg:SetEdgeTexture("", 8, 1, 0)
        
        -- Tytuł
        local titleLbl = WINDOW_MANAGER:CreateControl("$(parent)Title", tlw, CT_LABEL)
        titleLbl:SetAnchor(TOP, tlw, TOP, 0, 10)
        titleLbl:SetFont("ZoFontWinH2")
        titleLbl:SetText(title)
        
        -- Kontener na tekst
        local container = WINDOW_MANAGER:CreateControl("$(parent)Container", tlw, CT_CONTROL)
        container:SetAnchor(TOPLEFT, tlw, TOPLEFT, 20, 50)
        container:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, -20, -60)
        
        -- Pole edycji (EditBox) - to pozwala kopiować!
        local edit = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Edit", container, "ZO_DefaultEditMultiLineForBackdrop")
        edit:SetAnchorFill()
        edit:SetMaxInputChars(100000)
        edit:SetFont("ZoFontGameSmall")
        edit:SetColor(1, 1, 1, 1)
        
        tlw.edit = edit
        
        -- Przycisk Zamknij
        local closeBtn = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Close", tlw, "ZO_DefaultButton")
        closeBtn:SetAnchor(BOTTOM, tlw, BOTTOM, 0, -10)
        closeBtn:SetText("Zamknij")
        closeBtn:SetHandler("OnClicked", function() tlw:SetHidden(true) end)
    end
    
    -- Ustawienie tekstu i pokazanie okna
    tlw.edit:SetText(text)
    tlw:SetHidden(false)
    tlw:SetTopmost(true)
    
    -- Automatyczne zaznaczenie wszystkiego
    tlw.edit:TakeFocus()
    tlw.edit:SelectAll()
end

function LoreTooltips.BuildAutoAliases()
    if not LoreTooltips.Database then return end
    if not LoreTooltips.Aliases then LoreTooltips.Aliases = {} end
    
    -- 1. Mapa zajętych aliasów (żeby wykryć konflikty)
    local usedAliases = {}
    local coveredDbKeys = {}
    
    for alias, value in pairs(LoreTooltips.Aliases) do
        local key = (type(value) == "table") and value.key or value
        coveredDbKeys[key] = true
        usedAliases[alias] = key
    end

    -- 2. Lista brakujących kluczy
    local missingEntries = {}
    for dbKey, entry in pairs(LoreTooltips.Database) do
        if not coveredDbKeys[dbKey] then
            table.insert(missingEntries, { key = dbKey, title = entry.title })
        end
    end

    if #missingEntries == 0 then
        d("|c00FF00[SUKCES]|r Baza jest kompletna! Nie ma nic do skopiowania.")
        return
    end

    -- 3. Generowanie tekstu do okna
    local outputString = ""
    local conflictCount = 0
    
    outputString = outputString .. "-- === NOWE ALIASY (" .. #missingEntries .. " szt.) ===\n"
    
    for _, item in ipairs(missingEntries) do
        local suggestedAlias = ""
        
        -- A. Generuj z tytułu
        if item.title then
            suggestedAlias = item.title:gsub("%s*%(.-%)%s*", ""):lower()
            suggestedAlias = suggestedAlias:gsub("^%s+", ""):gsub("%s+$", "")
        end
        
        -- B. Fallback: Generuj z klucza
        if suggestedAlias == "" then
            suggestedAlias = item.key:gsub("_", " "):lower()
        end
        
        -- Sprawdzenie konfliktu
        if usedAliases[suggestedAlias] then
            outputString = outputString .. "-- [KONFLIKT] '" .. suggestedAlias .. "' zajęte przez: " .. usedAliases[suggestedAlias] .. "\n"
            outputString = outputString .. "-- RĘCZNIE DOPASUJ: " .. item.key .. "\n"
            conflictCount = conflictCount + 1
        else
            outputString = outputString .. '    ["' .. suggestedAlias .. '"] = "' .. item.key .. '",\n'
            
            -- Dodajemy do pamięci sesji, żeby nie generowało duplikatów w tej samej pętli
            usedAliases[suggestedAlias] = item.key
        end
    end
    
    -- 4. Wyświetlenie okna
    d("|cFFD700[LoreTooltips]|r Otwieram okno z kodem do skopiowania (" .. #missingEntries .. " wpisów)...")
    if conflictCount > 0 then
        d("|cFF0000Uwaga: Znaleziono " .. conflictCount .. " konfliktów (opisane w oknie jako komentarze).|r")
    end
    
    ShowCopyDialog("Lore Tooltips - Skopiuj kod (Ctrl+C)", outputString)
end

-- =========================
-- FUNKCJA POMOCNICZA - Lista aliasów dla klucza
-- =========================
function LoreTooltips.GetAliasesForKey(wikiKey)
    local found = {}
    if LoreTooltips.Aliases then
        for alias, key in pairs(LoreTooltips.Aliases) do
            if key == wikiKey then
                table.insert(found, alias)
            end
        end
    end
    return found
end