---------------------------------------
-- Polska lokalizacja------------------
---------------------------------------

--worldmap filters
ZO_CreateStringId("DH_FILTER_BOSSES", "Dungon I (białe czaszki)")
ZO_CreateStringId("DH_FILTER_BOSSES_OTHER", "Dungeon II (czarne czaszki)")

local DHLocalizedData = {
--------------------------------Spindleclutch I	START--------------------------------
	["glenumbra"] = {
		["spindleclutch_base"] = {
						
			{[[Spindlekin (Spindleclutch I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka obok niego kilka pająków
-Boss co jakiś czas przywołuje więcej pająków.
-Jeżeli ktoś zginie, lub zabijemy jakiegoś pająka, boss może podejść do niego i zacząć go jeść aby się uleczyć. Można to przerwać klasycznym bashem.
*Loot specjalny:
"Silky Threads" - Naszyjnik. Set Prayer Shawl. Trait Arcane
.]]},
			
			
			{[[Swarm Mother (Spindleclutch I)]], [[*Boss główny
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować.
-Boss przywołuje co jakiś czas pająki
-Boss co jakiś czas skacze na najdalszą osobę.
*Loot specjalny:
"Swarm Mother's Sprig" - Kostur leczenia. Set Prayer Shawl. Trait Training
"Spinner's Pierce" - Miecz jednoręczny. Set Knightmare. Trait Sharpened]]},


			{[[Cerise the Widow-Maker (Spindleclutch I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować.
-Boss czasem uziemia(immobilize) kogoś z grupy.
*Loot specjalny:
"Widow's Band" - Pierścień. Set Prayer Shawl. Trait Arcane
"Gilded Choker" - Naszyjnik. Set Spelunker. Trait Ornate
]]},

			{[[Big Rabbu (Spindleclutch I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas sporo dodatkowych przeciwników
-Boss co jakiś czas przyciąga do siebie gracza łańcuchem
-Boss co jakiś czas wykonuje szarżę(czerwony obszar). Można ją zablokować
*Loot specjalny:
"Guardsman Mark" - Pierścień. Set Knightmare. Trait Healthy]]},

			{[[The Whisperer (Spindleclutch I)]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Boss co jakiś czas wysyła trujący pocisk w losową osobę w drużynie. Można go uniknąć.
-Boss co jakiś czas wysyła magiczny pocisk na losową osobę w grupie, zadający obrażenia i wywołujący szaleństwo (zielone pająki). Można go uniknąć.
-Boss co jakiś czas przyciąga wszystkich do siebie i wykonuje duży atak obszarowy(Czerwone kółko).
-Na hard modzie wszystkie mechaniki zabijają.
*Loot specjalny:
"Spindlecleave" - Topór dwuręczny. Set Knightmare. Trait Sharpened
"Whisperwoe" - Łuk. Set Spelunker. Trait ...
]]},
		},
	},
-------------------------------------------------------------------------------------

--------------------------------Fungal Grotto I	START--------------------------------
	["stonefalls"] = {
		["fungalgrotto_base"] = {
			{[[Tazkad the Packmaster (Fungal Grotto I)]], [[**Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas obok 4 dodatkowych przeciwników, w tym 2 jego durzogi(minibossy).
-Boss wykonuje umiejętność(castuje) która dezorientuje(stunuje) tanka. Można jednak to przerwać klasycznym bashem
*Loot specjalny:
"Tazkad's Band" - Pierścień. Set Viper. Trait Robust
"Huntmaster's Leash" - Naszyjnik. Set Viper. Trait Robust]]},

			{[[Warchief Ozazai (Fungal Grotto I)]], [[*Boss główny
*Mechaniki:
-Prócz bossa czekają na nas 2 dodatkowe gobliny
-Boss zaczyna walkę skokiem zadającym obrażenia
-Boss wykonuje ciężki atak(heavy attack). Można go normalnie zablokować.
-Boss może rzucić sztandar(Wielkie czerwone kółko na ziemi). Ten zadaje obrażenia i obniża leczenie otrzymywane(heala).
-Boss co jakiś czas zaczyna ładować kogoś promieniem. Po kilku sekundach osoba ta wybucha zadając dookoła obrażenia.
-Boss mając mało życia(HP) wykonuje co jakiś czas bojowy krzyk zadający obszarowe obrażenia
*Loot specjalny:
"Dreughsdeath" - Miecz Dwuręczny. Set Dreugh King Slayer. Trait Infused
"War Chief's Firebrand" - Kostur Ognia. Set Spider Cultist Cowl. Trait Charged]]},

			{[[Broodbirther (Fungal Grotto I)]], [[**Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas obok 2 dodatkowe dreughy
-Boss czasem przyciąga losową osobę do siebie.
-Boss co jakiś czas wykonuje elektryczne kombo przed siebie
*Loot specjalny:
"Broothmather's Knot" - Pierścień. Set Spider Cultist Cowl. Trait Healthy]]},

			{[[Kra'gh The Dreugh King (Fungal Grotto I)]], [[*Last Boss
*Hard mode:
-Aby wykonać utrudnioną wersję(Hard Mode) należy odpalić leżący w pobliżu "Scroll of Glorius Battle" który wzmacnia bossa. Dodaje mu życia(HP) i obrażeń.
*Mechaniki:
-Boss co jakiś czas przyzywa stado krabów
-Boss wykonuje od czasu do czasu ciężki atak(Heavy Attack). Można go normalnie zablokować.
-Boss od czasu do czasu przyciąga do siebie losową osobę.
-Boss czasem wykonuje przed siebie elektrycznie kombo.
-Od czasu do czasu Kra'gh zaczyna ładować potężny atak obszarowy(czerwone kółko). Zadaje ono bardzo duże obrażenia i zazwyczaj zabija.
*Loot specjalny:
"Goblinsbane" - Macka jednoręczna. Set Viper. Trait Defending
"Dreugh King's Totem" - Kostur Elektryczności. Set Dreugh King Slayer. Trait Sharpened]]},

			{[[Clatterclaw (Fungal Grotto I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas stado krabów
-Boss co jakiś czas przywołuje więcej krabów
*Loot specjalny:
"Crabclaw Charm" - Naszyjnik. Set Dreugh King Slayer. Trait Healthy
]]},
},
},
-------------------------------------------------------------------------------------
--------------------------------Banished Cells I START-------------------------------
	["auridon"] = {
		["thebanishedcells_base"] = {
			{[[Cell Haunter (Banished Cells I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka obok niego kilka szkieletów
-Boss co jakiś czas łączy się promieniem z jedną osobą, wysysając z niej życie(HP)
-Boss co jakiś czas ładuje lodową falę. Można ją przerwać klasycznym bashem.
*Loot specjalny:
"Renanimating Pedant" - Naszyjnik. Set Jailbreaker. Trait Robust]]},

			{[[Shadowrend (Banished Cells I)]], [[*Boss główny
*Mechaniki:
-Boss co jakiś czas przywołuje cienisty klon samego siebie.
-Boss przywołuje co jakiś czas  wykonuje atak obszarowy dookoła siebie(czerwone kółko)
-Boss co jakiś czas skacze na losową osobę i zaczyna ją jeść. Można to przełamać(break free) lub przerwać klasycznym bashem.
*Loot specjalny:
"Darktarge" - Tarcza. Set Tormentor. Trait Reinforced
"Render's Axe" - Topór jednoręczny. Set Jailbreaker. Trait Precise]]},

			{[[Angata the Clanfear handler (Banished Cells I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Boss co jakiś czas przywołuje clanfeara
*Loot specjalny:
"Angata's Signet" - Pierścień. Set Sanctuary. Trait Arcane
]]},

			{[[Skeletal Destroyer (Banished Cells I)]], [[*Boss główny
*Mechaniki:
-Prócz bossa czeka na nas sporo dodatkowych przeciwników
-Boss co jakiś czas przywołuje szkielety
-Boss co jakiś czas uderza w ziemie przywołując duży atak obszarowy(czerwone kółko)
*Loot specjalny:
"Vertebral Ring" - Pierścień. Set Tormentor. Trait Healthy
]]},

			{[[High Kinlord Rilis (Banished Cells I)]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować
-Boss co jakiś czas wysyła ognisty pocisk na losową osobę w grupie. Można go uniknąć lub zablokować.
-Boss co jakiś czas unosi miecz i przywołuje ogniowe ataki obszarowe(czerwone kółka).
-Co jakiś czas pojawiają się latające orby które powoli wędrują w stronę bossa. Jeżeli do niego dotrą, uleczą go. Można je normalnie zniszczyć.
-Na hard modzie niezablokowany ognisty pocisk zazwyczaj zabija.
*Loot specjalny:
"Guilehammer" - Młot dwuręczny. Set Jailbreaker. Trait Decisive
"High Kinlord's Revenge" - Topór. Set Sanctuary. Trait Precise
]]},

		},
	},
-------------------------------------------------------------------------------------
	
--------------------------------Darkshade Caverns I	START----------------------------
	["deshaan"] = {
		["darkshadecaverns_base"] = {
			{[[Head Shepherd Neloren (Darkshade Caverns I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka obok niego kilka dodatkowych przeciwników
-Boss co jakiś czas zaczyna się leczyć. Można to przerwać klasycznym bashem.
-Boss co jakiś czas ładuje ognistą falę. Można ją przerwać klasycznym bashem.
*Loot specjalny:
"Kwama Sharpherd Charm" - Pierścień. Set Armor of the Truth. Trait Health]]},

			{[[Foleman Llothan (Darkshade Caverns I)]], [[*Boss główny
*Mechaniki:
-Boss co jakiś czas przemiszcza sie po pomieszczeniu a następnie przywołuje 6 kwama(czerwone kółko)
-Boss przywołuje co jakiś czas  wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Boss co jakiś czas rzuca truciznę(czerwone kółko). Każdy kto w niej staje staje się zatruty.
*Loot specjalny:
"Llothan's Burning Crutch" - Kostur Ognia. Set Netch's Touch. Trait Charged]]},

			{[[The Hive Lord (Darkshade Caverns I)]], [[*Boss głowny
*Mechaniki:
-Boss co jakiś czas wykonuje duży atak obszarowy(wielkie czerwone kółko). Można go przerwać klasycznym bashem
-Boss co jakiś czas przywołuje 3 kwama(czerwone kółko)
-Boss co jakiś czas skacze na najdalszą osobę
-Boss wykonuje kombo przed siebie(czerwony obszar)
*Loot specjalny:
"Hive Lord's Shell" - Tarcza. Set Netch's Touch. Trait Reinforced
"Deadly Pincer" - Miecz jednoręczny. Set Netch's Touch. Trait Powered]]},

			{[[Cavern Patriarch (Darkshade Caverns I)]], [[*Boss dodatkowy
*Mechaniki:
-Boss co jakiś czas rzuca na ziemie truciznę(czerwone kółko)
*Loot specjalny:
"Lambent Netch Tentacles" - Pierścień. Set Strength of the Automaton. Trait Robust]]},

			{[[Cutting Sphere (Darkshade Caverns I)]], [[*Boss dodatkowy
*Mechaniki:
-Boss co jakiś czas wykonuje ciężki atak(heavy attack)
-Boss co jakiś czas wykonuje falę kamienną po ziemi. Da się ją przerwać klasycznym bashem.
-Boss co jakiś czas zaczyna się kręcić zadając obszarowe obrażenia(czerwone kółko).
*Loot specjalny:
"Lost Imperial Band" - Pierścień. Set Netch's Touch. Trait Arcane
]]},

			{[[Sentinel of Rkugamz (Darkshade Caverns I)]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Kiedy boss staje się czerwony, po chwili rozpoczyna atak obszarowy(czerwone kółko), podążając jednocześnie za jedną z osób.
-Kiedy boss staje się niebieski, po chwili zaczyna strzelać w górę wykonując ataki obszarowe(czerwone kółka) na jednej z osób.
-Kiedy boss staje się żółto-zielony, wykonuje na przemian ciężkie ataki(heavy attack) oraz kombo przed siebie(czerwony obszar)
-Podczas walki pojawią się zielone pająki, generujące zielone obszary(kółka) które leczą bossa jeżeli w nie wejdzie.
*Loot specjalny:
"Imperial Arm Cleaver" - Topór jednoręczny. Set Armor of the Truth. Trait Sharpened
"Imperial Warhammer" - Młot dwuręczny. Set Strength of the Automaton. Trait Charged
]]},
		},
	},
-------------------------------------------------------------------------------------	
--------------------------------Elden Hollow I START---------------------------------
	["grahtwood"] = {	
		["eldenhollow_base"] = {
			{[[ Ahash gra-Mal (Elden Hollow I)]], [[*Boss Głowny
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować
-Boss wykonuje kombo przed siebie(czerwony obszar)
-Boss co jakiś czas robi atak obszarowy(czerwone kółko) dookoła siebie
*Loot specjalny:
...]]},

			{[[Ancient Spriggan (Elden Hollow I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz boss czeka na nas kilka zwykłych spriganów
-Boss wykonuje kombo przed siebie(czerwony obszar)
*Loot specjalny:
...]]},


			{[[Chokethorn (Elden Hollow I)]], [[*Boss główny
*Mechaniki:
-Boss co jakiś czas wykonuje rosnący atak obszarowy(czerwone kółko), dookoła siebie
-Boss przyzywa stranglery które go leczą
-Boss co jakiś czas przyciąga losową osobę do siebie
*Loot specjalny:
...
]]},

{[[Nenesh gro-Mal (Elden Hollow I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Boss wykonuje ciężki atak(heavy attack)
-Boss co jakiś czas wykonuje atak obszarowy(czerwone kółko), dookoła siebie. Można to przerwać klasycznym bashem.
-Boss co jakiś czas aktywuje aurę piorunów która zadaje obrażenia wszystkim dookoła.
*Loot specjalny:
...
]]},

{[[Leafseether (Elden Hollow I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas dwa dodatkowe ality
-Boss co jakiś czas wykonuje ciężki atak(heavy attack)
-Boss co jakiś czas wykonuje kombo przed siebie(czerwony obszar)
*Loot specjalny:
...
]]},

{[[Canonreeve Oraneth (Elden Hollow I)]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Boss co jakiś czas wykonuje rosnący atak obszarowy(czerwone kółko) dookoła siebie. Zadaje on bardzo duże obrażenia.
-Boss co jakiś czas narzuca truciznę na losową osobę
-Boss co jakiś czas przyzywa stabilny atak obszarowy(czerwone kółko) pod jedną z osób. Po chwili kółko zadaje obrażenia, a kiedy się skończy, wychodzą z niego 4 szkielety.
*Loot specjalny:
...
]]},
},
},
-------------------------------------------------------------------------------------
--------------------------------Wayrest Sewers I START-------------------------------
	["stormhaven"] = {
		["wayrestsewers_base"] = {
			{[[Slimecrew (Wayrest Sewers I)]], [[*Boss dodatkowy
*Mechaniki:
-Boss wykonuje kombo przed siebie(czerwony obszar)
*Loot specjalny:
"Lost Wedding Band" - Pierścień. Set Combat Physician. Trait Ornate]]},

			{[[Investigator Garron (Wayrest Sewers I)]], [[*Boss główny
*Mechaniki:
-Boss ignoruje tanka
-Boss przywołuje wędrujący atak obszarowy(czerwone kółko). Kółko podąża za losowym graczem.
-Boss 2 razy podczas walki przywołuje 3 duchy atakujące lodem.
-Boss teleportuje się losowo po pomieszczeniu.
-Co jakiś czas boss rzuca pociskiem odrzucającym w losowego gracza.
*Loot specjalny:
"Garron's Cold Betrayal" - Kostur Mrozu. Set Sergent's Mail. Trait Sharpened
]]},

			{[[Uulgarg the Hungry (Wayrest Sewers I)]], [[*Boss dodatkowy
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Boss zsyła strach na graczy. Można to przełamać(break free)
*Loot specjalny:
"Uulgarg's Charm" - Pierścień. Set Toothrow. Trait Robust
"Smuggler's Luck Beads" - Naszyjnik. Set Toothrow. Trait Healthy]]},

			{[[Rat Whisperer (Wayrest Sewers I)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas stado szczurów
-Boss co jakiś czas przyzywa więcej szczurów
-Boss co jakiś czas wykonuje atak obszarowy(czerwone kołko)
*Loot specjalny:
"Rattail Necklace" - Naszyjnik. Set Toothrow. Trait Robust]]},

			{[[Valaine Pallingare (Wayrest Sewers I)]], [[*Boss Główny
*Mechaniki:
-Boss co jakiś czas wykonuje ciężki atak(heavy attack)
-Boss co jakiś czas wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Boss co jakiś czas odwraca się do losowej osoby oraz wykonuje szybkie kombo przed siebie(czerwony obszar)
*Loot specjalny:
"Mightmaker" - Miecz dwuręczny. Set Sergent's Mail. Trait Precise]]},

			{[[Allene Pallingare (Wayrest Sewers I)]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować
-Boss co jakiś czas wykonuje szybki atak obszarowy(czerwone kółko) dookoła siebie
-Boss co jakiś czas skacze na losową osobę, zadając jej obrażenia
-Boss co jakiś czas znika i na jego miejsce pojawiają się duchy nietoperzy. Gdy się je zabije, boss wraca.
-Poniżej 25% HP boss wchodzi w tryb ducha, zwiększając swoje obrażenia
*Loot specjalny:
"Wicked Bite" - Sztylet. Set Combat Physician. Trait Infused
"Ratskewer Bow" - Łuk. Set Toothrow. Trait Decisive
]]},
		},
		},
-------------------------------------------------------------------------------------		
		--nazwa
	["shadowfen"] = {
		["arxcorinium_base"] = {
			{[[Fanged Menace]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas sporo lamii
-Boss wykonuje cięzki atak(heavy attack)
-Boss wykonuje kombo przed siebie(czerwony obszar)
-Boss co jakiś czas zwija się w kulkę, aktywując atak obszarowy(duże czerwone kółko). Przebywanie w kółku leczy bossa oraz zadaje obrażenia.
*Loot specjalny:
"Chain of the Snake Charmer" - Naszyjnik. Set Undaunted Infiltrator. Trait Robust]]},

			{[[Ganakton the Tempest]], [[*Boss Główny
*Mechaniki:
-Boss wykonuje kombo przed siebie(czerwony obszar)
-Boss co jakiś czas wysyła elektryczną ścieżkę, zadającą obrażenia i ogłuszającą trafionego gracza
-Boss co jakiś czas zadaje niewielkie obrażenia wszystkim stojącym w wodzie.
*Loot specjalny:
"Belisaro's Bolt" - Kostur Piorunów. Set Lamia's Song. Trait Charged]]},

			{[[Silkenia the Songstress]], [[*Boss główny
*Mechaniki:
-Prócz bossa czeka na nas wąż
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować.
-Boss co jakiś czas zaczyna śpiewać, zadając wszystkim obrażenia. Chroni jednak swojego peta(węża) barierą. Pod barierą nie otrzymuje się obrażeń.
*Loot specjalny:
"Sweetsong" - Miecz jednoręczny. Set Undaunted Infiltrator. Trait Precise
]]},

			{[[Matron Ixniaa]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Boss co jakiś czas wykonuje atak obszarowy(Dwa czerwone kółka, jedno w drugim) pod jednym z graczy. Po jakimś czasie kółka wybuchają. Stanie w wewnętrznym zadaje duże obrażenia, w zewnętrznym, małe.
*Loot specjalny:
"Matron's Mark" - Pierścień. Set Lamia's Song. Trait Arcane
"Ixniaa's Jewels" - Naszyjnik. Set Lamia's Song. Trait Arcane]]},

			{[[Ancient Lurcher]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas kilka dodatkowych przeciwników
-Boss co jakiś czas łączy się z losową osobą promieniem, wysysając jej HP
-Boss co jakiś czas wykonuje ciężki atak(heavy attack)
-Boss co jakiś czas wykonuje atak obszarowy(czerwone kółko)
*Loot specjalny:
"Swampbinder" - Pierścień. Set Medusa. Trait Healthy]]},

			{[[Sellstrix the Lamia Queen]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Boss ustawiony w wodzie, elektryzuje ją, sprawiając że zadaje obrażenia każdemu kto do niej wejdzie
-Boss ustawiony na ziemi otrzymuje tarczę ochronną
-Boss co jakiś czas zaczyna śpiewać wykonując ataki obszarowe(duże czerwone kółka) tam gdzie nie ma wody
-Boss co jakiś czas wykonuje kombo przed siebie(czerwony obszar)
-Boss często sam z siebie zmienia target, ignorując prowokacje(taunta)
*Loot specjalny:
"Sellstrix's Siphon" - Miecz dwuręczny. Set Medusa. Trait Infused
"Fang of the Lamia Queen" - Sztylet. Set Medusa. Trait Sharpened]]},
		},
	},	
	
	
	["reapersmarch"] = {
		["selenesweb_base"] = {
			{[[Treethane Keminn]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Boss wykonuje ciężki atak(heavy attack)
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Boss co jakiś czas przyciąga wszystkich do siebie a następnie przywołuje nietoperze(czerwone kółko)
*Loot specjalny:
"Treethane's Sigil" - Pierścień. Set Vestments of Warlock. Trait Arcane]]},

			{[[Longclaw]], [[*Boss Główny
*Mechaniki:
-Na początku czekają na nas 4 pantery. Póki ich nie zabijemy, boss nie zejdzie z drzewa.
-Podczas walki boss wciąż przywołuje duchy zabitych panter. Potrafią one wykonać ciężkie ataki(heavy attack)
-Boss co jakiś czas wykonuje atak obszarowy(czerwone kółko) pod siebie. Atak ogłusza i zadaje duże obrażenia
-Boss wykonuje stabilny atak obszarowy(czerwone kółko)
*Loot specjalny:
"Longclaw's Bow" - Łuk. Set Hircine's Veneer. Trait Precise]]},

			{[[Queen Aklayah]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas kleszcze
-Boss co jakiś czas przywołuje więcej kleszczy
-Boss co jakiś czas zatruwa jednego z graczy, sprawiając iż ten ma na sobie atak obszarowy(czerwone kółko) który za nim podąża.
-Boss co jakiś czas wykonuje kombo przed siebie(czerwony obszar)
*Loot specjalny:
"Adventurer's Lost Medalion" - Naszyjnik. Set Hircine's Veneer. Trait Robust]]},

			{[[Foulhide]], [[*Boss główny
*Mechaniki:
-Boss co jakiś czas wykonuje kombo przed siebie(czerwony obszar). Po kombie z ziemi wyrastają stranglery
-Boss co jakiś czas zsyła strach na graczy. Można to przełamać(break free)
-Boss co jakiś czas wykonuje szarżę(czerwony obszar), zabijając przy okazji stranglery przez które przebiegnie
*Loot specjalny:
"Foulhide's Fang" - Sztylet. Set Vestments of Warlock. Trait Decisive
"Bearslayer" - Topór dwuręczny. Set Durok's Bane. Trait Infused
]]},

			{[[Mennir Many-Legs]], [[*Boss dodatkowy
*Mechaniki:
-Boss co jakiś czas przyzywa pająki
-Boss co jakiś czas wykonuje elektryczny atak obszarowy(czerwone kółko)
-Boss co jakiś czas ogłusza losową osobę. Można to przełamać(break free)
*Loot specjalny:
"Arachnoid Ring" - Pierścień. Set Durok's Bane. Trait Arcane
]]},

			{[[Selene]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Boss ma 2 fazy. Pająka i człowieka.
-Pająk: Boss łapie losową osobę w kokon. Można to przełamać(break free) lub zostać uwolnionym przez inną osobę za pomocą synergii
-Pająk: Boss po jakimś czasie rozwala pajęczyna i wszyscy spadają na dół, gdzie dalej się toczy walka.
-Pająk: Boss mając 10% HP zmienia się w człowieka i leczy do full HP.
-Człowiek: Boss wykonuje ciężki atak(heavy attack), ten zadaje bardzo duże obrażenia i potrafi zabić nawet tanka na bloku.
-Człowiek: Boss wysyła w losową osobę ducha pantery, ogłuszając ją.
-Człowiek: Boss co jakiś czas przyciąga wszystkich do siebie  a następnie wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Człowiek: Z drzew wciąż schodzą dodatkowi przeciwnicy. Łucznicy, magowie i wojownicy
*Loot specjalny:
"Webcutter" - Topór jednoręczny. Set Durok's Bane. Trait Sharpened
"Selene's Scepter" - Kostur Piorunów. Set Vestments of Warlock. Trait Sharpened
]]},
		},
	},	
	
	["malabaltor"] = {
		["tempestisland_base"] = {
			{[[Valaran Stormcaller]], [[*Boss Główny
*Mechaniki:
- Boss wykonuje ciężki atak(heavy attack)
- Od początku walki z bossem po terenie przemieszcza się burza(czerwone kółko) zadając obrażenia wszystkim którzy w nią wejdą
-Boss co jakiś czas ogłusza losową osobę. Można to przełamać(break free)
-Boss co jakiś czas przyzywa elektryczną kopię samego siebie
*Loot specjalny:
"Stormcaller Blade" - Miecz jednoręczny. Set Jolting Arms. Trait Sharpened
]]},
			{[[Stormfist]], [[*Boss główny
*Mechaniki:
-Boss co jakiś czas wykonuje rosnący atak obszarowy(czerwone kółko) dookoła siebie. Atak ten wyrzuca w powietrze trafionych
-Boss co jakiś czas przywołuje miniaturowe kopie siebie
-Boss co jakiś czas stawia w losowym miejscu kamienny atak obszarowy(czerwone kółko)
-Boss, gdy ma poniżej 20% HP zaczyna wybuchać elektrycznością dookoła, zadając wszystkim obrażenia.
*Loot specjalny:
"Tempestshield" - Tarcza. Set Jolting Arms. Trait Reinforced
"Raining Hammer" - Młot dwuręczny. Set Storm Master. Trait Decisive]]},
			{[[Stormreeve Neidir]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Podczas walki z bossem po terenie walki przemieszczają się wichry, zadające obrażenia i odrzucające przy kontakcie
-Boss skacze na osobę która znajduje się zbyt daleko od niej. Skok bywa zabójczy, jeżeli się go nie zablokuje
-Boss przywołuje piorun z nieba na losową osobę. Zadaje to duże obrażenia.
-Boss wykonuje co jakiś czas rosnący atak obszarowy(czerwone kółko), który zadaje duże obrażenia i odrzuca.
*Loot specjalny:
"Windwhisper" - Łuk. Set Storm Master. Trait Decisive
"Neidir's Thundering Staff" - Kostur piorunów. Set Owerwhelming Surge. Trait Sharpened
]]},
		},
		["tempestislandswcave_base"] = {
			{[[Sonolia the Matriarch]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Bossa wykonuje ciężki atak(heavy attack)
-Boss co jakiś czas wykonuje kombo przed siebie(czerwony obszar)
*Loot specjalny:
"Matriarch's Ring" - Pierścień. Set Jolting Arms. Trait Healthy]]},
			},
		["tempestislandncave_base"] = {
			{[[Yalorasse the Speaker]], [[*Boss dodatkowy
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack)
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Boss rzuca elektryczny obszar(czerwone kółko) pod osobę którą atakuje
*Loot specjalny:
"Speaker's Band" - Pierścień. Set Overwhelming Surge. Trait Arcane]]},
		},
		["tempestislandsecave_base"] = {
			{[[Commodore Ohmamil]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas wiele dodatkowych przeciwników
-Boss wykonuje ciężki atak(heavy attack)
-Boss co jakiś czas unosi w górę atakowaną osobę, wysysając z niej HP. Może to zostać przerwane klasycznym bashem lub przełamane(break free)
*Loot specjalny:
"Commodore's Medal" - Naszyjnik. Set Overwhelming Surge. Trait Arcane
]]},
		},
	},
	
	["bangkorai"] = {
		["blackhearthavenarea1_base"] = {
			{[[Iron-Heel]], [[*Boss dodatkowy
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack)
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Boss co jakiś czas kopie losową osobę, odrzucając ją daleko do tyłu
*Loot specjalny:
"Pillager's Ring" - Pierścień. Set Knight-Errant's Mail. Trait Healthy
"Jewels of Iliac Bay" - Naszyjnik. Set Undaunted Unweaver. Trait Arcane
]]},
		},
		["blackhearthavenarea2_base"] = {
			{[[Atarus]], [[*Boss Główny
*Mechaniki:
-Boss co jakiś czas wykonuje szarżę(czerwony obszar)
-Boss co jakiś czas wykonuje atak obszarowy(czerwone kółko) dookoła siebie, podrzucając trafionych
-Boss co jakiś czas rzuca trucizną(czerwone kółko) pod jednego z graczy
-Boss, posiadając mało HP, leczy się i powiększa. Od tej chwili jego mechaniki są wzmocnione.
*Loot specjalny:
"Atarus' Masher" - Młot Dwuręczny. Set Undaunted Unweaver. Trait Precise]]},
			},
			
		["blackhearthavenarea3_base"] = {
			{[[First Mate Wavecutter]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas harpie
-Boss wykonuje ciężki atak(heavy attack)
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Boss co jakiś czas wysyła we wszystkich magiczne pociski, zadające duże obrażenia. Można to przerwać klasycznym bashem.
*Loot specjalny:
"First Mate's Mark" - Pierścień. Set Bone Pirate's Tatters. Trait Robust]]},
			{[[Roost Mother]], [[*Boss główny
*Mechaniki:
-Boss co jakiś czas teleportuje się po polu walki
-Boss wykonuje kombo przed siebie(czerwony obszar)
-Boss co jakiś czas przywołuje falę ognia przed siebie
-Boss co jakiś czas strzela kulami ognia w powietrze. Po chwili kule spadają w losowe miejsca(czerwone kółka)
*Loot specjalny:
"Roost Mother's Branch" - Kostur Ognia. Set Undaunted Unweaver. Trait Charged]]},
			{[[Hollow Heart]], [[*Boss dodatkowy
*Mechaniki:
-Boss co jakiś czas wysyła przed siebie falę lodu
*Loot specjalny:
"Hollow Heart's Pedant" - Naszyjnik. Set Undaunted Unweaver. Trait Arcane]]},
		},
		["blackhearthavenarea4_base"] = {
			{[[Captain Blackheart]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Z wody wciąż wychodzą nowe szkielety
-Boss co jakiś czas skacze na losową osobę a następnie przemienia ją w szkieleta. Póki przemieniona, osoba nie może używać żadnych umiejętności.
*Loot specjalny:
"Skullmaker" - Miecz jednoręczny. Set Bone Pirate's Tatters. Trait Infused
"Shield of the Black Death" - Tarcza. Set Knight-Errant's Mail. Trait Reinforced
]]},
		},
	},
	
	["eastmarch"] = {
		["direfrostkeep_base"] = {
			{[[Teethnasher the Frostbound]], [[*Boss dodatkowy
*Mechaniki:
-Bossa otacza lodowa aura(czerwone kółko), zadająca obrażenia wszystkim co do niej wejdą
-Boss wykonuje kombo przed siebie(czerwony obszar)
*Loot specjalny:
"Troll-Tooth Necklace" - Naszyjnik. Set Ice Furnace. Trait Healthy
]]},
			{[[Keeper of the Flame]], [[*Boss Główny
*Mechaniki:
-Boss wykonuje kombo przed siebie(czerwony obszar)
-Boss co jakiś czas przywołuje stabilny atak obszarowy(czerwone kółko) pod jednego z graczy
-Boss co jakiś czas skacze na losowego gracza
-Boss wykonuje ciężki atak(heavy attack)
*Loot specjalny:
"Witchdrinker" - Topór dwuręczny. Set Magica Furnance. Trait Powered
]]},

			{[[Drodda's Dreadlord]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka lodowych scampów
-Boss co jakiś czas przywołuje więcej scampów
-Scampy wybuchają jak podejdą do gracza
-Boss wykonuje ciężki atak(heavy attack)
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
*Loot specjalny:
"Dreadlord's Mark" - Pierścień. Set Draugr Hulkr. Trait Robust
]]},

			{[[Drodda's Apprentice]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Boss co jakiś czas wykonuje rosnący atak obszarowy(czerwone kółko) dookoła siebie
-Boss co jakiś czas przywołuje lodową falę. Można ją przerwać klasycznym bashem
-Boss co jakiś czas zaczyna wysysać HP z losowej osoby, jednocześnie ogłuszając ją. Można to przełamać(break free)
*Loot specjalny:
"Snowy Signet" - Pierścień. Set Magica Furnance. Trait Robust
"Apprentice's Chain" - Naszyjnik. Set Magica Furnance. Trait Arcane
]]},

{[[Iceheart]], [[*Boss główny
*Mechaniki:
-Boss wykonuje kombo przed siebie(czerwony obszar)
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Boss co jakiś czas uderza w ziemie, przyzywając ataki obszarowe(czerwone kółka) w losowych miejscach. Kółka po chwili wybuchają ogłuszając i przywołując lodowe szkielety.
*Loot specjalny:
"Shard of Iceheaer" - Topór jednoręczny. Set Ice Furnance. Trait Infused
]]},
},
["direfrostkeepsummit_base"] = {
			{[[Drodda the  Icereach]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Boss ignoruje prowokacje(taunta)
-Boss co jakiś czas teleportuje się na losową osobę po czym wykonuje rosnący atak obszarowy(czerwone kółko)
-Boss co jakiś czas przywołuje lodowe upiory
-Boss co jakiś czas wysysa z kogoś HP, stunując go jednocześnie. Dodatkowo się wówczas leczy. Można to przełamać(brak free)
-Po jakimś czasie boss wpada w furię. Zmienia się wóczas na błękitny kolor a wszystkie mechaniki ulegają zaostrzeniu. Atak obszarowy zadaje więcej obrażeń, wysysanie HP leczy bossa o wiele mocniej a zamiast upiorów pojawiają się lodowe atronachy.
*Loot specjalny:
"Drodda's Boreal Staff" - Kostur mrozu. Set Ice Furnance. Trait Infused
"Drodda's Withering Edge" - Sztylet. Set Draugr. Trait Precise
]]},
},
},

--------------------------------Vollenfell START---------------------------------------------------
	["alikr"] = {
		["volenfell_base"] = {
			--Desert Lion
			{[[Desert Lion]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych lwów
-Bossa wykonuje ciężki atak(heavy attack)
-Boss co jakiś czas zsyła strach na wszystkich, można to przełamać(break free)
*Loot specjalny:
"Lion-Tooth Pedant" - Naszyjnik. Set Crusader. Trait Robust
]]},
		--Quintus Verres & Monsterous Gargoyle
		{[[Quintus Verres & Monsterous Gargoyle]], [[*Boss Główny
*Mechaniki:
-Boss ma 3 fazy. Faza z mieczem, z kosturem oraz z gargulcem
-Faza 1: Boss wykonuje ciężki atak(heavy attack)
-Faza 1: Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie.
-Faza 2: Boss co jakiś czas przywołuje stabilny atak obszarowy(czerwone kółko) pod jednym z graczy
-Faza 2: Boss wykonuje kombo przed siebie
-Faza 3: Gargulec krzyczy przed siebie(czerwony obszar) ogłuszając trafionych 
-Faza 3: Gargulec wykonuje atak obszarowy(czerwone kółko) dookoła siebie
*Loot specjalny:
"Quintus' Exploding Staff" - Kostur Ognia. Set Crusader. Trait Charged
]]},
		--Tremorscale
		{[[Tremorscale]], [[*Boss główny
*Mechaniki:
-Boss wykonuje kombo przed siebie(czerwony obszar)
-Boss co jakiś czas znika pod ziemią a następnie wyskakuje w powietrze, wykonując atak obszarowy(czerwone kółko) na losową osobę. Atak ten ogłusza.
*Loot specjalny:
"Tremorscale's Tooth" - Miecz dwuręczny. Set Duneripper. Trait Sharpened
]]},
},
		--Guardian Constructs
		["eyeschamber_base"] = {
		
		{[[Guardian Constructs]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Bossy są 3 na raz. Czerwony, niebieski i żółto-zielony.
-Czerwony boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie, podążając jednocześnie za losową osobą.
-Niebieski boss strzela w górę pociskami, przywołując ataki obszarowe(czerwone kółka) na ziemi, pod losową osobą
-Zielono-Żółty boss wykonuje ciężki atak(heavy attack) oraz kombo przed siebie(czerwony obszar).
-Boss przekazują sobie HP, jeżeli jeden ma mniej niż pozostali, po chwili się wyrównają.
-Niebieski i czerwony boss ignorują prowokacje(taunta)
*Loot specjalny:
"Ancient ImperialStaff" - Kostur leczenia. Set Treasure Hunter. Trait Infused
"Ancient Imperial Hammer" - Macka. Set Duneripper. Trait Defending
]]},
},
		--Boilbite
		["volenfell_pledge"] = {
		
		{[[Boilbite]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka żuków
-Boss co jakiś czas  teleportuje się
-Boss co jakiś czas zwija się w kulkę, wykonując rosnący atak obszarowy(czerwone kółko)
*Loot specjalny:
"Beetle Eye Ring" - Pierścień. Set Treasure Hunter. Trait Arcane
]]},
},
},

--Vollenfell cd..
	["bangkorai"] = {
		["the_guardians"] = {
			--Unstable Construct
			{[[Unstable Construct]], [[*Boss dodatkowy
*Mechaniki:
-Boss co jakiś czas ładuje kulę ognia w losową osobę(czerwone kółko). Po chwili osoba ta wybucha zadając obrażenia obszarowe
-Boss co jakiś czas wykonuje atak obszarowy(czerwone kółko)
-Boss co jakiś czas wykonuje ciężki atak(heavy attack). Można go zablokować
*Loot specjalny:
"Ancient Ring" - Pierścień. Set Crusader. Trait Robust
"Ancient Necklace" - Naszyjnik. Set Crusader. Trait Robust
]]},
},
},
---------------------------------------------------------------------------------------------------
--------------------------------Vaults of Madness--------------------------------------------------
	["coldharbor"] = {
		["vaultsofmadness1_base"] = {
						
			{[[Cursed One]], 
[[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Boss wykonuje falę lodu
-Boss co jakiś czas łączy się promieniem z losową osobą. Na tą osobę przekazywane są wszystkie obrażenia które otrzymuje wówczas boss.
*Loot specjalny:
"Game of Curses" - Pierścień. Set Rattlecage. Trait Arcane
"Forbiden Jewels" - Naszyjnik. Set Rattlecage. Trait Arcane]]},
			
			
			{[[Ulguna Soul-Reaver]], [[*Boss Główny
*Mechaniki:
-Boss wykonuje dużą falę ognia przed siebie
-Boss unosi losową osobę w powietrze, jednocześnie przywołując orby. Póki orby nie zostaną zniszczone, latająca osoba nie może nic zrobić.
*Loot specjalny:
"Soul Siphon" - ?. Set Rattlecage. Trait ?
"Maleficence" - ?. Set Worm Raiment. Trait ?
"Soul Reave" - ?. Set Worm Raiment. Trait ?]]},


			{[[Death Hand]], [[*Boss dodatkowy
*Mechaniki:
-Boss co jakiś czas wykonuje kombo przed siebie(czerwony obszar)
-Boss co jakiś czas przywołuje 3 szkielety
-Boss co jakiś czas wykonuje szarżę(czerwony obszar), zostawiając za sobą runy(czerwone obszary)
*Loot specjalny:
"Bonebound Ring" - Pierścień. Set Rattlecage. Trait Healthy
"Death's Amulet" - Naszyjnik. Set Oblivion's Edge. Trait ?
]]},

			{[[Grothdarr]], [[*Boss główny
*Mechaniki:
-Boss co jakiś czas wykonuje kombo przed siebie(czerwony obszar). Trafione osoby zostają odrzucone do tyłu
-Boss wykonuje ciężki atak(heavy attack)
-Po terenie walki krążą sobie kałuże lawy, zadające obrażenia trafionym osobom.
*Loot specjalny:
"Despair" - ?. Set Rattlecage. Trait ?
"Grothdarr's Fist" - ?. Set Oblivion's Edge. Trait ?
"Fleshsear" - ?. Set Oblivion's Edge. Trait ?
]]},

			{[[Archearaizur]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas wiele dodatkowych przeciwników
-Boss zionie ogniem przed siebie(czerwony obszar)
-Boss zostawia stabilny płomień(czerwony obszar) pod losową osobą
*Loot specjalny:
"Archearaizur's Chain" - ?. Set Rattlecage. Trait ?
]]},
			{[[Ancient One]], [[*Boss dodatkowy
*Mechaniki:
-Boss wykonuje kombo przed siebie. Trafione osoby są ogłuszone
-Boss co jakiś czas wykonuje atak obszarowy, który zadaje obrażenia zależne od jego HP. Im ma mniej, tym większe obrażenia
*Loot specjalny:
"Watcher's Eye" - ?. Set Worm's Raiment. Trait ?
"Ring of the Ancient One" - ?. Set Worm's Raiment. Trait ?

]]},
			{[[Iskra the Omen]], [[*Boss główny
*Mechaniki:
-Boss wykonuje atak obszarowy(czerwone kółko) pod sobą. Trafione osoby są odrzucone
-Boss zionie ogniem w losową osobę, pozostawiając podpalony teren(czerwone kółka)
-Boss skacze na losową osobę, zadając obrażenia obszarowe(czerwone kółko)
*Loot specjalny:
"Omen's Edge" - ?. Set Rattlecage. Trait ?
"Ruin" - ?. Set Worm's Raiment. Trait ?
"Ill Omen" - ?. Set Oblivion's Edge. Trait ?]]},
},

		["vaultsofmadness2_base"] = {
		
			{[[Mad Architect]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Boss co jakiś czas przywołuje dodatkowych przeciwników
-Boss co jakiś czas stawia pod losową osobą atak obszarowy(czarny obszar)
-Boss co jakiś czas zaczyna ładować zaklęcie. Po chwili je uwalnia, aktywując jedną z dwóch mechanik. Jeżeli pojawi się bariera,  atak będzie poza nią, trzeba więc wejść do środka. Jeżeli pojawi się światło, atak będzie dookoła bossa, trzeba więc szybko się odsunąć.
*Loot specjalny:
"Vengeance" - ?. Set Rattlecage. Trait ?
"The Mad Cleaver" - ?. Set Worm's Raiment. Trait ?
"The Mad Maul" - ?. Set Worm's Raiment. Trait ?
"Architect's Shield" - ?. Set Oblivion's Edge. Trait ?
]]},
},
},
---------------------------------------------------------------------------------------------------
--------------------------------------------Blessed Crucible---------------------------------------
----------------------------Vaults of Madness--------------------------------------------------
	["therift"] = {
		["blessedcrucible1_base"] = {
						
			--Grunt the Clever
			{[[Grunt the Clever]], 
[[*Boss dodatkowy
*Mechaniki:
-Boss co jakiś czas zsyła strach na wszystkich. Można to przełamać(break free)
-Boss wykonuje kombo przed siebie(czerwony obszar), wszyscy trafieni są odrzuceni daleko do tyłu.
-Boss wykonuje kamienną falę po ziemi przed siebie
*Loot specjalny:
"Necklace of Giant Toes" - Naszyjnik Set Nikulas' Heavy Armors. Trait Healthy]]},
},

["blessedcrucible2_base"] = {
		--The Pack
		{[[The Pack]], [[*Boss Główny
*Mechaniki:
-Bossy są aż 4
-Każdy z bossów, kiedy ma mało HP przemienia się w wilkołaka
-Jeden z bossów przyzywa ogień pod sobą(czerwone kółko)
-Jeden z bossów wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Jeden z bossów leczy innych oraz przyzywa fale ognia. Obie mechaniki można przerwać klasycznym bashem.
-Jeden z bossów wykonuje ciężki atak(heavy attack).
*Loot specjalny:
"Wolfpack Staff" - Kostur Leczenia. Set Nikula's Heavy Armor. Trait Defending
]]},
},

["blessedcrucible3_base"] = {
		--Teranya the Faceless
		{[[Teranya the Faceless]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas dwa durzogi
-Boss wykonuje ciężki atak(heavy attack)
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
*Loot specjalny:
"Mark of the Morag Tong" - Pierścień. Set Sword Dancer. Trait Robust
]]},
},

["blessedcrucible4_base"] = {
		--Beast Army: Beetles & Singer & Troll King
		{[[Beast Army: Beetles & Singer & Troll King]], [[*Boss główny
*Mechaniki:
-Po kolei są fale bossów. Najpier 4 żuki, później skorpion a na końcu troll.
-Żuki: Strzelają płomieniami podpalając trafiony teren
-Skorpion: Boss co jakiś czas przywołuje truciznowy atak obszarowy(czerwone kólko) pod losową osobą.
-Skorpion: Boss wykonuje ciężki atak(heavy attack)
-Troll: Boss co jakiś czas skacze na najdalszą osobę
-Troll: Boss co jakiś czas wykonuje kamienne fale przed siebie
-Troll: Boss co jakiś czas wykonuje rosnący atak obszarowy(czerwone kółko)
*Loot specjalny:
"Beastmaster's Crop" - Macka. Set Nobles Duelist. Trait Defending
]]},
},

["blessedcrucible5_base"] = {
		--Captain Thoran
		{[[Captain Thoran]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas wiele dodatkowych przeciwników
-Boss co jakiś czas rzuca runę(czerwone kółko) pod nogi losowej osoby. Runna wybucha gdy ktoś na nią wejdzie
-Boss przywołuje stabilne ataki obszarowe(czerwone kółka)
-Boss mając mało HP, przyzywa ogniste atronachy które go chronią. Aby móc bić dalej bossa, muszą zostać zabite.
*Loot specjalny:
"Captain's Medalion" - Naszyjnik. Set Sword Dancer. Trait Robust
"Thorand's Bond Ring" - Pierścień. Set Noble Duelist. Trait Arcane
]]},
},

["blessedcrucible6_base"] = {
		--Lava Queen
		{[[Lava Queen]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Scroll of Glorius Battle", leżący nieopodal bossa. Dodaje to życia(HP) i obrażeń bossowi
*Mechaniki:
-Podczas walki z lawy wyskakują pociski które zadają obrażenia obszarowe(czerwone kółko)
-Boss wykonuje ciężki atak(heavy attack)
-Boss co jakiś czas strzela kulą ognia w losową osobę
-Boss co jakiś czas wbija miecz w ziemie, wysyłają we wszystkie strony fale lawy. Bywają one zabójcze.
-Co jakiś czas pojawiają się ogniste atronachy, chroniące bossa przed obrażeniami. Aby boss ponownie mógł byś atakowany, muszą zostać zabite.
*Loot specjalny:
"Claymore of the Crucible" - Miecz dwuręczny. Set Noble Duelist. Trait Sharpened
"Brimestone Staff" - Kostur Ognia. Set Noble Duelist. Trait Precise
]]},
},

},
}

local DHLocalizedDataOther = {
--Spindleclutch II	
	["glenumbra"] = {
		["spindleclutch_base"] = {
						
			{[[Mad Mortine (Spindleclutch II)]], 
[[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka obok niego kilku nieumarłych
-Boss wykonuje ciężki atak(heavy atak). Można go zablokować.
*Loot specjalny:
"Gem of Madness" - Pierścień. Set Knightmare. Trait Robust]]},
			
			
			{[[Bloodspawn (Spindleclutch II)]], [[*Boss główny
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować.
-Boss co jakiś czas biegnie na środek pomieszczenia i zaczyna bić w ziemie zadając obrażenia obszarowe(wielkie czerwone kółko)
-Jeżeli nie zabijemy bossa dostatecznie szybko, wpadnie on w furię(enrage) i będzie bił w ziemię w nieskończoność. 
*Loot specjalny:
brak :(]]},


			{[[Praxin Douare (Spindleclutch II)]], [[*Boss głowny
*Mechaniki:
-Przed bossem czekają nas aż 4 fale dodatkowych przeciwników. Póki ich nie zabijemy boss będzie niemal niewrażliwy na obrażenia Są to:
1)Małe pająki
2)Wielki pająk z małymi pająkami
3)Grupa ludzi
4)Daedryczny pająk z dwójką ludzi
-Boss co jakiś czas rzuca klątwę na losową osobę odbierającą życie, magię i wytrzymałość(HP, Magice i Stamine)
-Boss co jakiś czas wysyła przed siebie 3 fale po ziemi zadające obrażenia
-Boss co jakiś czas zamyka jedną z osób w czerwonym okręgu. Przejście przez okrąg powoduje śmierć tzn nie wolno wejść do środka gdy jest się na zewnątrz oraz nie wolno wyjść gdy jest się w środku. Każdy kontakt z okręgiem kończy się śmiercią(w wersji veteran).
*Loot specjalny:
"Nightmare" - Łuk. Set Spelunker. Trait Precise
]]},

			{[[Flesh Atronach Trio (Spindleclutch II)]], [[*Boss dodatkowy
*Mechaniki:
-Bossy są aż 3. 3 cielesne atronachy
-Bossy wykonują ciężki atak(heavy attack). Można go zablokować
-Bossy co jakiś czas wykonują kombo przed siebie które odrzuca. Można je zablokować. 
-Jeżeli jeden z bossów zginie, pozostałe leczą się za 30% życia. Można tego uniknąć jeśli zabije się je jednocześnie.
*Loot specjalny:
"Fleshlinks" - Naszyjnik. Set Prayer Shawl. Trait Arcane]]},

			{[[Urvan Veleth (Spindleclutch II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas dodatkowo 4 czerwone szkielety
-Boss wykonują ciężki atak(heavy attack). Można go zablokować
-Boss co jakiś czas rzuca sztandar(wielkie czerwone kółko). Zadaje ono obrażenia i obniża leczenie(heala)
-Boss co jakiś czas znika i zmienia się w wędrujące czerwone kółko. Zadaje ono obrażenia oraz leczy bossa.
*Loot specjalny:
"Chain of the Coven" - Naszyjnik. Set Prayer Shawl. Trait Arcane
"Signet of the Stalker" - Pierścień. Set Knightmare. Trait Robust
]]},
			{[[Vorenor Winterbourne (Spindleclutch II)]], [[*Last Boss
*Hard mode:
-Aby wykonać utrudnioną wersję(hard mode) nie wolno zabijać żadnej z kobiet z których boss wysysa życie(są 4).
*Mechaniki:
-Boss co jakiś czas przywołuje pod losową osobą czerwone kółko. Zadaje ono bardzo duże obrażenia.
-Boss co jakiś czas zaczyna wysysać życie z przywiązanych do pali kobiet. Można zabić wówczas te kobiety ale spowoduje to niewykonanie hard moda.
-Boss co jakiś czas zaczyna teleportować się od jednej osoby do drugiej, zadając przy tym duże obrażenia. Można to zablokować.
*Loot specjalny:
"Vampiric Scepter" - Kostur Leczenia. Set Prayer Shawl. Trait Infused
"Axe of Secrifice" - Topór jednoręczny. Set Spelunker. Trait Infused
]]},
},
},
--Fungal Grotto II	
	["stonefalls"] = {
		["fungalgrotto_base"] = {
			{[[Mephala's Fang (Fungal Grotto II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają obok niego dwaj kultyści healerzy
-Boss narzuca na jedną z osób truciznę. Ta osoba zostawia w miejscu w którym stoi, pola trucizny (czerwone kółka). Znikają one po pewnym czasie ale jeżeli osoba się nie ruszy to pojawi się ich  pod nogami tyle że obrażenia będą ogromne.
-Jeżeli ktoś zginie, albo zabijemy kultystów, boss podejdzie do trupa i zacznie go jeść, lecząc się. Da się przerwać klasycznie bashem.
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować.
-Boss co jakiś czas wykonuje truciznowe kombo przed siebie.
*Loot specjalny:
"Spidersilk Garland" - Naszyjnik. Set Viper. Trait Robust]]},

			{[[Gaymne Bandu (Fungal Grotto II)]], [[*Boss główny
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować.
-Co jakiś czas boss rzuca w losową osobę pociskiem. Pojawia się wtedy promień łączący dwie osoby z drużyny. Zadaje on obrażenia. Aby go zerwać dwie osoby muszą odbiec od siebie jak najdalej.
-Boss przywołuje 4 cienie które uwiązują łańcuchami jedną z osób. Osoba ta nic nie może wówczas robić. Jeżeli nie zostanie uwolniona, zginie. Aby ją uwolnić należy zabić jednego z cieni.
-Boss co jakiś czas znika i zamiast tego pojawiają się jego 4 kopie. Aby powrócił należy je zabić.
*Loot specjalny:
"Knife of Shadows" - Sztylet. Set Viper. Trait Sharpened]]},

			{[[Ciirenas the Shepherd (Fungal Grotto II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas 3 pająki
-Zabicie każdego pająka wzmacnia obronę bossa. Po zabiciu wszystkich trzech boss jest niemal niewrażliwy na ataki
-Boss co jakiś czas wykonuje(castuje) ogniową falę. Można to przerwać bashem
-Boss co jakiś czas wykonuje(castuje) zaklęcie strachu(feara). Można to przerwać bashem.
*Loot specjalny:
"Mender's Mark" - Pierścień. Set Dreugh King Slayer. Trait Healthy]]},

			{[[Spawn of Mephala (Fungal Grotto II)]], [[*Boss główny
*Mechaniki:
-Podczas walki od czasu do czasu pojawia się portal. Wciąga on najbliższą osobę. Osoba ta pojawia się w innym wymiarze, pełnym pająków. Musi je zabić aby móc wrócić.
-Boss co jakiś czas wykonuje duży atak obszarowy. Po nim zrywa prowokacje(taunta).
-Boss co jakiś czas odwraca się do losowej osoby i rzuca w nią pociskiem. Da się to zablokować lub uniknąć.
-Po polu walki wędruje promień (czerwone kółko). Każda osoba na którą trafi otrzymuje duże obrażenia.
*Loot specjalny:
"Debaser" - Miecz dwuręczny. Set Viper. Trait Sharpened
"Webspinner Brace" - Tarcza. Set Dreugh King Slayer. Trait Reinforced]]},

			{[[Reggr Dark-Down (Fungal Grotto II)]], [[*Boss dodatkowy
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować
-Boss co jakiś czas zaczyna kręcić dookoła siebie bronią(czerwone kółko)
-Boss co jakiś czas unosi broń w górę wysysając z wszystkich  życie i magię(HP i Magice).
*Loot specjalny:
"Band of the Breaker" - Pierścień. Set Spider Cultist Cowl. Trait Arcane]]},

			{[[Vila Tharen (Fungal Grotto II)]], [[*Last Boss
*Hard mode:
-Aby wykonać utrudnioną wersję(hard mode) nie wolno wchodzić pod barierę ochronną podczas walki.
*Mechaniki:
-Boss co jakiś czas teleportuje się na każdego w drużynie, zostawiając pod nim rosnący atak obszarowy. Można normalnie z niego wyjść.
-Boss co jakiś czas wykonuje specjalny atak wysysający z wszystkich życie(HP). Zadaje on bardzo duże obrażenia. Można go jednak uniknąć wchodząc pod barierę ochronną (ale spowoduje to niewykonanie hard moda).
*Loot specjalny:
"Nightcaller" - Macka jednoręczna. Set Dreugh king Slayer. Trait Defending
"Widow's Voidstaff" - Kostur Elektryczności. Set Spider Cultist Cowl. Trait Sharpened]]},
},
},

-- Banished Cells II
	["auridon"] = {
		["thebanishedcells_base"] = {
			{[[Keeper Areldur (Banished Cells II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka obok niego kilku dodatkowych przeciwników
-Boss co jakiś czas zaczyna przywoływać dookoła siebie fale płomieni.
*Loot specjalny:
"Areldur's Ring" - Pierścień. Set Sanctuary. Trait ...]]},

			{[[Maw of the infernal (Banished Cells II)]], [[*Boss główny
*Mechaniki:
-Boss podpala osobę którą atakuje. Podpalona osoba zostawia pod sobą ogień. Ten ogień nie znika więc jeżeli podpalona osoba będzie się przemieszczać, coraz większa część sali zacznie płonąć.
-Boss przywołuje co odwraca się i zionie ogniem na losową osobę.
*Loot specjalny:
"Staff of Conflagration" - Kostur ognia. Set Sanctuary. Trait Charged]]},

			{[[Keeper Voranil (Banished Cells II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować.
*Loot specjalny:
"Keeper's Insignia" - Pierścień. Set Tormentor. Trait Arcane
"Keeper's  Medalion" - Naszyjnik. Set Tormentor. Trait Robust
]]},

			{[[Keeper Imiril (Banished Cells II)]], [[*Boss główny
*Mechaniki:
-Boss przywołuje lewitujące orby(czerwone kółka) które zdają obrażenia jak się do nich zbliżymy
-Boss wykonuje ciężki atak (heavy attack). Można go zablokować
-Boss co jakiś czas ładuje duży atak obszarowy(czerwone kółko)
-Boss co jakiś czas biegnie do jednego z orbów i znika. Na jego miejsce pojawia się stado daedr. Po jakimś czasie powraca.
*Loot specjalny:
"Firetooth" - Miecz jednoręczny. Set Jailbreaker. Trait Precise]]},

			{[[Sister Vera and Sister Sihna (Banished Cells II)]], [[*Boss dodatkowy
*Mechaniki:
-Bossy są dwa na raz.
-Bossy co jakiś czas będą ładować magiczną falę przed siebie. Można przerwać ją bashem.
-Bossy co jakiś czas wyciągają w górę(stun) atakowana osobę, przywołując jednocześnie latające orby. Jeżeli orby dotrą do bossów, uleczą je.
-Bossy dostają na przemian magiczną tarczę która chroni je przed obrażeniami. Jeżeli jeden boss ją dostanie, drugi ją traci. Tak na przemian.
*Loot specjalny:
"Talisman of the Sisters" - Naszyjnik. Set Sanctuary. Trait Healthy]]},

			{[[High Kinlord Rilis (Banished Cells II)]], [[*Last Boss
*Hard mode:
-Aby wykonać utrudnioną wersję(hard mode) należy zabić bossa podczas gdy 3 przyzwane przez niego daedrothy jeszcze żyją.
*Mechaniki:
-Boss teleportuje się po całym terenie walki.
-Boss co jakiś czas unosi losową osobę wysoko w górę i nakłada na nią czerwoną lub niebieską klątwę. Klątwa zadaje obrażenia. Aby ją zdjąć należy udać się do czerwonej lub niebieskiej runy(ta sama runa co kolor klątwy). Runy umieszczone są po dwóch różnych końcach pomieszczenia.
-Boss co jakiś czas przyzywa daedrotha(aby wykonać hard moda musimy mieć takie 3).
-Boss co jakiś czas unosi kostur i przywołuje ogniowe ataki obszarowe(czerwone kółka).
-Co jakiś czas pojawiają się latające orby które powoli wędrują w stronę bossa. Jeżeli do niego dotrą, uleczą go. Można je normalnie zniszczyć.
*Loot specjalny:
"Corruptor's Maul" - Młot dwuręczny. Set Jailbreaker. Trait Precise
"Staff of the Banished" - Kostur Lodu. Set Sanctuary. Trait Precise
]]},

		},
	},
	
	--Darkshade Caverns II	
	["deshaan"] = {
		["darkshadecaverns_base"] = {
			{[[The Fallen Foreman (Darkshade Caverns II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka obok niego kilka dodatkowych przeciwników
-Boss co jakiś czas wykonuje ogniowe zaklęcie, poruszające się powoli dookoła bossa. Zadaje ono duże obrażenia.
-Boss co jakiś czas ładuje ognistą falę. Można ją przerwać klasycznym bashem.
*Loot specjalny:
"Foreman's  Ring" - Pierścień. Set Armor of the Truth. Trait Robust]]},

			{[[Transmuted Hive Lord (Darkshade Caverns II)]], [[*Boss główny
*Mechaniki:
-Prócz bossa czekają na nas dwie kwamy, które potrafią przewrócić i wyssać staminę.
-Boss co jakiś czas wykonuje ciężki atak(heavy atack).
-Boss co jakiś czas aktywuje tarczę obronną i zaczyna bić w ziemię, zadając obrażenia obszarowe. Aby przestał należy zbić jego tarcze.
*Loot specjalny:
"Fist of the Hive Lord" - Macka. Set Armor of the Truth. Trait Defending
"Transmuted Kwama Shell" - Tarcza. Set Armor of the Truth. Trait Reinforced]]},

			{[[Transmuted Alit (Darkshade Caverns II)]], [[*Boss dodatkowy
*Mechaniki:
-Są aż 3 bossy na raz
-Bossy wykonują ciężkie ataki(heavy attack). Można to zablokować.
-Jeżeli bossy nie zginą na raz, po chwili się wskrzeszają z niskim poziomem HP
*Loot specjalny:
"Alit Tongue Charm" - Naszyjnik. Set Netch's Touch. Trait Arcane]]},

			{[[Grubull the Transmuted (Darkshade Caverns II)]], [[*Boss główny
*Mechaniki:
-Boss póki wisi w powietrzu jest odporny na obrażenia
-Boss co jakiś czas teleportuje się wykonując atak obszarowy(czerwone kółko)
-Boss co jakiś czas rzuca na ziemie elektryczność. Kto w nią wejdzie  jest sparaliżowany.
-Boss przyzywa bardzo dużo dodatkowych przeciwników.
-Boss co jakiś czas spada na ziemię. Wtedy jest wrażliwy na ataki.
*Loot specjalny:
"Grobull's Charge" - Kostur Piorunów Set Netch's Touch. Trait Charged]]},

			{[[Dwarven Gauntlet (Darkshade Caverns II)]], [[*Boss dodatkowy
*Mechaniki:
-Bossem jest armia dwemerskich maszyn
-Przeciwnicy przychodzą falami.
-Centuriony potrafią wykonać atak obszarowy(czerwone kółko)
-Sfery potrafią wykonać kamienną falę po ziemi(można przerwać bashem)
*Loot specjalny:
"Automaton Gem" - Pierścień. Set Netch's Touch. Trait Arcane
]]},

			{[[Last Boss - Engine Guardian (Darkshade Caverns II)]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy nie dotykać żadnej z dźwigni umieszczonych na środku
*Mechaniki:
-Boss ignoruje graczy i przemieszcza się dookoła.
-Kiedy boss staje się czerwony, po chwili rozpoczyna atak obszarowy(ogień dookoła siebie), jednocześnie wysyłając w graczy ogniste pociski(czerwone kółka)
-Kiedy boss staje się niebieski, zaczyna strzelać w pobliskich graczy z błyskawicy. Jednocześnie pojawiają się 3 sfery dwemerskie.
-Kiedy boss staje się żółto-zielony, całą komnatę wypełnia trucizna zadająca obrażenia.
-Na środku pomieszczenia znajdują się dźwignie przełączające fazy. Można ich użyć ale spowoduje to niewykonanie hard moda.
*Loot specjalny:
"Ancient Great Axe" - Topór dwuręczny. Set Strength of the Automaton. Trait Precise
"Pincer of the Guardian" -Miecz jednoręczny. Set Strength of the Automaton. Trait Precise]]},
		},
	},
	
--Elden Hollow II	
	["grahtwood"] = {	
		["eldenhollow_base"] = {
			{[[Dubroze the Infestor (Elden Hollow II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas wiele dodatkowych przeciwników
-Boss zaczyna walkę szarżą
-Boss co jakiś czas zieje ogniem przed siebie(czerwony obszar).
*Loot specjalny:
...]]},

			{[[Dark Root (Elden Hollow II)]], [[*Boss główny
*Mechaniki:
-Boss co jakiś czas zadaje obrażenia osobom w pobliżu
-Boss przyzywa dwa kleszcze(zielonego i niebieskiego) które wysysają stamine i magice. Jeżeli je zabijemy, na ich ciałach pojawi się obszar dodający nam staminy lub magicy.
*Loot specjalny:
...]]},

			{[[Azura the Frightener (Elden Hollow II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilku dodatkowych przeciwników
-Boss co jakiś czas przyzywa duchy które ogłuszają. Można je zabić.
*Loot specjalny:]]},


			{[[Shadow Guard (Elden Hollow II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czekają na nas cztery jego cienie
-Boss przyzywa stabilne ataki obszarowe(czerwone kółka)
*Loot specjalny:
...
]]},
		},
		
		
		["eldenhollowheroic1_base"] = {
			{[[Murklight (Elden Hollow II)]], [[*Boss Główny
*Mechaniki:
-Boss wykonuje kombo przed siebie(czerwony obszar)
-Boss wykonuje ciężki atak(heavy attack)
-Boss przyzywa stabilne ataki obszarowe(czerwone kółka)
-Boss co jakiś czas uderza w ziemię, zamieniając czerwone kółka w białe. Wówczas osoby stojące poza nimi będą otrzymywać obrażenia.
-Po jakimś czasie białe kołka zmienią się z powrotem w czerwone
*Loot specjalny:
...]]},
			
			{[[Bogdan the Nightflame (Elden Hollow II)]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy odpalić "Bogdan's Tome", leżący nieopodal bossa. Spowoduje to pojawianie się dodatkowych cieni podczas walki.
*Mechaniki:
-Boss co jakiś czas strzela ogniem w tanka, zadając duże obrażenia
-Boss co jakiś czas podskakuje w górę, zadając obrażenia wszystkim, jednocześnie gasząc płomienie i zabijając cienie
-Boss co jakiś czas strzela ogniem w górę i po chwili płomienie spadają na każdego. Zostają one w miejscu w którym upadły aż do następnego skoku bossa
-Boss przyzywa czarne cienie które zsyłają na  graczy strach
-Jeżeli odpaliliśmy tom, boss przyzywa białe cienie ktore go leczą. Można to przerwać klasycznym bashem.
-Cienie znikają przy każdym skoku.
*Loot specjalny:
...]]},
		},
	},
	--Wayrest Sewers II
	["stormhaven"] = {
		["wayrestsewers_base"] = {
			{[[Malubeth the Scourger (Wayrest Sewers II)]], [[*Boss dodatkowy
*Mechaniki:
-Boss przywołuje magiczne koła(czerwone), które pozostają w miejscu, zadając obrażenia
-Boss co jakiś czas staje się fioletowy i odporny na obrażenia, wysysając jednocześnie życie z losowej osoby. Robi tak póki nie dezaktywuje się dwóch ołtarzy po obu stronach bossa.
*Loot specjalny:
"Malubeth's Stinger" - Sztylet. Set Toothrow. Trait Infused]]},

			{[[Uulgarg the Risen (Wayrest Sewers II)]], [[*Boss dodatkowy
*Mechaniki:
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować
-Boss wykonuje atak obszarowy(czerwone kółko) dookoła siebie
-Boss zsyła strach na graczy, jednocześnie podpalając teren dookoła. Można to przełamać(break free)
*Loot specjalny:
"Ring of the Risen" - Pierścień. Set Sergent's Mail. Trait Healthy
"Uulgarg's Bones" - Naszyjnik. Set Combat Physician. Trait Arcane
]]},

			{[[Skull Reaper (Wayrest Sewers II)]], [[*Boss dodatkowy
*Mechaniki:
-Boss wykonuje kombo przed siebie(czerwony obszar)
-Boss przywołuje 4 szkielety które go leczą
*Loot specjalny:
"Reaper's Choker" - Naszyjnik. Set Sergent's Mail. Trait Robust]]},

			{[[Garron the Returned (Wayrest Sewers II)]], [[*Boss główny
*Mechaniki:
-Boss wykonuje ataki obszarowe(czerwone kółka) pojawiające się w całym pomieszczeniu
-Boss przywołuje lodowe duchy
-Boss co jakiś czas się teleportuje a następnie wysysa HP z wszystkich.
*Loot specjalny:
"Garron's Icy Grasp" - Kostur Mrozu. Set Combat Physician. Trait Sharpened]]},

			{[[The Lost One (Wayrest Sewers II)]], [[*Boss dodatkowy
*Mechaniki:
-Prócz bossa czeka na nas kilka dodatkowych przeciwników
-Boss co jakiś czas odsuwa się do tyłu i zsyła strach, zadając duże obrażenia. Można to przełamać(break free)
*Loot specjalny:
"Loop of the Lost" - Pierścień. Set Combat Physician. Trait Robust]]},

			{[[Allene Pallingare & Varaine Pallingare (Wayrest Sewers II)]], [[*Last Boss
*Hard mode:
-Aby wykonać  utrudnioną wersję(hard mode) należy podczas walki z bossem zabić 15 zombie. Zombie znajdują się korytarzu obok i odnawiają się jeżeli zginiemy i próbujemy jeszcze raz.
*Mechaniki:
-Bossy są 2 na raz
-Boss wykonuje ciężki atak(heavy attack). Można go zablokować
-Boss co jakiś czas wykonuje szybki atak obszarowy(czerwone kółko) dookoła siebie
-Boss co jakiś czas wykonuje kombo przed siebie(czerwony obszar)
-Bossy co jakiś czas znikają i na ich miejsce pojawiają się duchy nietoperzy. Gdy się je zabije, bossy wracają.
-Jeżeli któryś z bossów ma 15% mniej HP od drugiego, otrzymuje tarcze ochronną.
*Loot specjalny:
"Varaine's Death Knell" - ... Set Sergent's Mail. Trait ...
"Allane's Deadly Bow" - Łuk. Set Toothrow. Trait Precise
]]},
		},
},
	
}


function DH_GetLocalizedData(zone, subzone, bossId)
	if type(zone) == "string" and type(subzone) == "string" and type(bossId) == "number" and DHLocalizedData[zone] and DHLocalizedData[zone][subzone] and DHLocalizedData[zone][subzone][bossId] then
		return DHLocalizedData[zone][subzone][bossId][1], DHLocalizedData[zone][subzone][bossId][2]
	end
function DH_GetLocalizedDataOther (zone, subzone, bossId)
	if type(zone) == "string" and type(subzone) == "string" and type(bossId) == "number" and DHLocalizedDataOther[zone] and DHLocalizedDataOther[zone][subzone] and DHLocalizedDataOther[zone][subzone][bossId] then
		return DHLocalizedDataOther[zone][subzone][bossId][1], DHLocalizedDataOther[zone][subzone][bossId][2]
	end	
end
end