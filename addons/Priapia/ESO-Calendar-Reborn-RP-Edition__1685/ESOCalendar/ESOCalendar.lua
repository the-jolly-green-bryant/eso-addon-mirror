day = { "Morndas", "Tirdas", "Middas", "Turdas", "Fredas", "Loredas", "Sundas" }
month = { "Morning Star", "Sun's Dawn", "First Seed", "Rain's Hand", "Second Seed", "Midyear", "Sun's Height", "Last Seed", "Heathfire", "Frostfall", "Sun's Dusk", "Evening Star" }
constellation = { "The Ritual", "The Lover", "The Lord", "The Mage", "The Shadow", "The Steed", "The Apprentice", "The Warrior", "The Lady", "The Tower", "The Atronach", "The Thief" }
daedric_days = { }
holidays = {}

first_inweek_day = 1
first_day = 1
current_date = 0
current_year = 0
current_month = 0
current_day = 0
ig_year = 0

date_computed = true

function ESOCalendar_Init()
	
	-- init daedric days array
	daedric_days[0101] = "Clavicus Vile"
	daedric_days[1301] = "Meridia"
	daedric_days[0202] = "Sheogorath"
	daedric_days[1602] = "Sanguine"
	daedric_days[0503] = "Hermaeus Mora"
	daedric_days[2103] = "Azura"
	daedric_days[0904] = "Peryite"
	daedric_days[0905] = "Namira"
	daedric_days[0506] = "Hircine"
	daedric_days[1007] = "Vaermina"
	daedric_days[0809] = "Nocturnal"
	daedric_days[0810] = "Malacath"
	daedric_days[1310] = "Mephala"
	daedric_days[0211] = "Boethia"
	daedric_days[2011] = "Mehrunes Dagon"
	daedric_days[2012] = "Molag Bal"
	
	-- init holidays array
	holidays[0101] = "New Life Festival"
	holidays[0201] = "Scour Day"
	holidays[1201] = "Ovank'a"
	holidays[1501] = "South Winds Prayer"
	holidays[1601] = "Day of Lights"
	holidays[1801] = "Waking Day"
	holidays[0802] = "Mad Pelagius"
	holidays[1602] = "Okthrotide"
	holidays[2802] = "Aduros Nau"
	holidays[0703] = "First Planting"
	holidays[0903] = "Day of Waiting"
	holidays[2103] = "Hogithum"
	holidays[2503] = "Flower Day"
	holidays[2603] = "Festival of Blades"
	holidays[0104] = "Gardtide"
	holidays[1304] = "Day of the Dead"
	holidays[2004] = "Day of Shame"
	holidays[2804] = "Jester's Day"
	holidays[0705] = "Second Planting"
	holidays[0905] = "Marukh's Day"
	holidays[2005] = "Fire Festival"
	holidays[3005] = "Fishing Day"
	holidays[0106] = "Drigh R'Zimb"
	holidays[1606] = "Mid Year Celebration"
	holidays[2306] = "Dancing Day"
	holidays[1007] = "Merchant's Festival"
	holidays[1207] = "Divad Etep't"
	holidays[2007] = "Sun's Rest"
	holidays[2907] = "Fiery Night"
	holidays[0208] = "Maiden Katrika"
	holidays[1108] = "Koomu Alazer'i"
	holidays[1408] = "Feast of the Tiger"
	holidays[2108] = "Appreciation Day"
	holidays[2708] = "Harvest's End"
	holidays[0309] = "Tales and Tallows"
	holidays[0609] = "Khurat"
	holidays[1209] = "Riglametha"
	holidays[1909] = "Children's Day"
	holidays[0510] = "Dirij Tereur"
	holidays[1310] = "Witch's Festival"
	holidays[3010] = "Emperor's Day"
	holidays[0311] = "Serpent's Dance"
	holidays[0811] = "Moon Festival"
	holidays[1811] = "Hel Anseilak"
	holidays[2011] = "Warrior's Festival"
	holidays[1512] = "North Winds Prayer"
	holidays[1812] = "Baranth Do"
	holidays[2012] = "Chil'a"
	holidays[2512] = "Saturalia"
	holidays[3012] = "Old Life Festival"
	
end

function ESOCalendar_UpdateDate()

	current_date = GetDate()
	current_year = math.floor(current_date / 10000)
	current_month = math.floor((current_date % 10000) / 100)
	current_day = math.floor(current_date % 100)
	current_inweek_day = ((current_day-first_day)+first_inweek_day) % 7
	ig_year = (current_year - 2014) + 582
	date_computed = true
	
end

function ESOCalendar_GetRace()

	return GetUnitZone("player")
	
end