-- PortToFriendsHouseLibraryData
-- By @s0rdrak (PC / EU)

local PortToFriend = _G['PortToFriend']
PortToFriend.libData = PortToFriend.libData or {}
local PortToFriendData = PortToFriend.libData

PortToFriendData.euData = {}
PortToFriendData.naData = {}
PortToFriendData.currentData = {}

function PortToFriendData.CreateEuDataList()
	local i = 1
	local list = PortToFriendData.euData
	list[#list + 1] = {
		name = "@schorse4044",
		houseId = 62,
		description = "If you want to have fun with hard Jump and Run stuff feel free to visit me. At the moment there are 5 tracks. Purple marks the start of each track and yellow the goal. Have fun!",
		category = {PortToFriend.constants.FILTER_ID_JUMPNRUN, PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@s0rdrak",
		houseId = 47,
		description = "This surreal estate contains a labyrinth that is in a building and built on different floors.\r\n\r\nYou might want to think a bit out of the box at a later point in the labyrinth.",
		category = {PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 81,
		description = "Big Toy House\r\n\r\nTwo life sized doll's houses and a inn beneath the stairs",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 75,
		description = "Icy Falls Inn\r\n\r\nTwo Nord lodges serving mead and snacks",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 80,
		description = "Blue-ice Palace\r\n\r\nJust like Solitude, but on a frozen lake",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 47,
		description = "Mushroom Manor\r\n\r\nA giant mushroom house",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 38,
		description = "Vampire Academy with wine bar\r\n\r\nCome for the nibbles; stay for eternity",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 29,
		description = "Three Pillows War\r\n\r\nRe-enact the three banners war with pillow forts and floof balls",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 71,
		description = "Treefern House\r\n\r\nA treehouse build around a giant treefern",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 62,
		description = "Artaeum Threatre/Operahouse/Divine Chapel\r\n\r\nTiered Balcony with many seats",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 46,
		description = "Imperial Bridal Suite\r\n\r\nExtension with Alinor wedding theme",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 69,
		description = "Dragonguard Penthouse\r\n\r\n3 Extra floors, with indoor conservatory and top floor gym",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 79,
		description = "Lava Submarine Base\r\n\r\nAn evil vampire alchemy lab, accessible only via a lava submarine",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 72,
		description = "Spirit-tree Library\r\n\r\nA library built atop an ancient forest that is growing in an even more ancient daedric ruin",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 76,
		description = "Golden Beach Palace\r\n\r\nA dwarven inspired Redguard pool and beach resort",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 61,
		description = "Hircine's Hunt Club\r\n\r\nA relaxing villa for all werewolves to come and feast in the ever flowing hunting grounds",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 82,
		description = "Lost Dwarven Kingdom\r\n\r\nThe palace of a lost Dwemer king has been found in a mage's pocket realm",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 40,
		description = "Topal Fishing Resort\r\n\r\nA resort in the middle of a fishing lake on a private island",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 59,
		description = "Castleton Manor\r\n\r\nThe house of Lord Castleton and his daughter Sonja",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 41,
		description = "Cave of BBQ N Ribs\r\n\r\nA secret dome, built inside a dank and secluded cavern, hosts the best BBQ and ribs restaurant",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 11,
		description = "Who Lived in a Shoe\r\n\r\nThere was an old reach witch who lived in a shoe",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 70,
		description = "Dwemer Party Tower\r\n\r\nA dwarven flying tower redesigned for parties",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 23,
		description = "A Taste of Alinor\r\n\r\nA small piece of Alinor situated beside a Rawl’kha creek",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 83,
		description = "Markarth Bath House\r\n\r\nA relaxing spa and bath house with an arts and craft centre for visitors to unwind. Or pay extra to stay the night in our VIP suite.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 15,
		description = "Treeboat house\r\n\r\nNo one know how an imperial ship ended up in the treetops, but it makes a great treehouse.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 86,
		description = "Varlaisvea College\r\n\r\nAn ancient library has been discovered deep inside an Ayleid ruin.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 55,
		description = "City on the Moon\r\n\r\nCity Moonbase with housing and an inn under the stars.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 64,
		description = "Lakemire Water Gardens\r\n\r\nRelaxing hanging gardens and a fish restaurant beneath the Xanmeer.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 91,
		description = "Cascadia Wine N Dine\r\n\r\nVineyard and meadery with two restaurants and a chapel.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 43,
		description = "Walled Kitchen Garden\r\n\r\nFresh produce and cut flowers for sale. Hot food served in a family restaurant.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 73,
		description = "Luckycat Summerhouse\r\n\r\nA khajiiti villa with spa and dining.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 88,
		description = "Helene's Boutique\r\n\r\nThe famous dressmaker has opened a new dress shop in town.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 9,
		description = "Alinor Garden Party\r\n\r\nA party in the flower gardens of a Altmer noble's manor.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 25,
		description = "Mad Scientists House\r\n\r\nWorkshop in the garage with an experimental De-lore-ean.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 27,
		description = "Arenthian Water Temple\r\n\r\nA relaxing water temple outside Arenthia.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 44,
		description = "Woodland Cottage\r\n\r\nA house in a tree, but not a treehouse.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 63,
		description = "Winter Snow Meadhall\r\n\r\nA winter meadhall has opened to get everyone in the festive mood.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 66,
		description = "Fire and Ice Hotel\r\n\r\nAn new hotel has opened with an ice bar and a lava room.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 89,
		description = "City of Princes\r\n\r\nCitadese is under attack from a dragon invasion. Prince Tarvia is leading the escape through the sewers.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 12,
		description = "Dark Brotherhood Home\r\n\r\nA Dark Brotherhood Sanctuary found beneath an Argonian village.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 20,
		description = "Volkihar Courtyard\r\n\r\nA castle courtyard modelled on the famous Volkihar Castle in Skyrim.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 74,
		description = "Rada's Summer Getaway\r\n\r\nA Redguard mansion with a dark vampiric secret in the basement.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 57,
		description = "Dawnlight Health Spa\r\n\r\nOur spa waters are revitalising and ready to heal your aching body.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 54,
		description = "Mountainside Retreat\r\n\r\nAn orc mountainside hall with an amazing view.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 85,
		description = "Volcanic Vile Villa\r\n\r\nA private hollowed out volcano for all your mad alchemist needs.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 45,
		description = "Argonian Sea Town\r\n\r\nAn argonian sea port",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 94,
		description = "Daedric Princess Tower\r\n\r\nAn underwater tower dedicated to the Daedric Prince Meridia",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 92,
		description = "Fargrave Observatory\r\n\r\nAn observatory in the portal realm of Fargrave",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 36,
		description = "Hundings Beach House\r\n\r\nBeach house and hottub",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 13,
		description = "Crystal Gardens\r\n\r\nEnchanted Gardens with crystalline trees",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 49,
		description = "The Secret Tower\r\n\r\nA hidden mage tower in the swamps on the Hag Fen",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 65,
		description = "Knight Club\r\n\r\nA disco in a dwarven mineshaft",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 56,
		description = "Dwemer Cave City\r\n\r\nA lost dwarven city has been found deep underground",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 60,
		description = "Alinor Gryphon Aerie\r\n\r\nA place where gryphons are trained",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 90,
		description = "The Charred Towers\r\n\r\nDeadlands themed fortress with two towers and custom furniture",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 96,
		description = "Pirate New Life For Me\r\nA pirate tavern where they gift you loot",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 93,
		description = "Woodvine Cathedral\r\nA living cathedral thriving in the Deadlands",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@seecodenotgames",
		houseId = 21,
		description = "Dark Elf Town House\r\nA small and cosy town house on the edge of Mournhold",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Holy_Mary",
		houseId = 47,
		description = "Former Guild House of Just Traders and Tamriel Stock Exchange and current main Guild House of First Trading Guild. All sets, all munduses, different dummies, transmute station.",
		category = {PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Holy_Mary",
		houseId = 10,
		description = "Cozy small house for lil' smoky sessions.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Holy_Mary",
		houseId = 26,
		description = "Built by an unknown imperial explorer, this house started to become an awkward merge of imperial and mechanical architecture.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Holy_Mary",
		houseId = 23,
		description = "A sweet summer grill party garden.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Holy_Mary",
		houseId = 31,
		description = "Rumours say, this house has been a secret retreat of a Direnni.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Holy_Mary",
		houseId = 58,
		description = "Cozy bathroom.",
		category = {PortToFriend.constants.FILTER_ID_ERP}
	}
	list[#list + 1] = {
		name = "@Holy_Mary",
		houseId = 22,
		description = "A house for all the nice things in life: Smoke skooma, drink a lot of alcohol...and well...maybe some fine dancers.",
		category = {PortToFriend.constants.FILTER_ID_ERP}
	}
	list[#list + 1] = {
		name = "@Holy_Mary",
		houseId = 4,
		description = "You need some place for you and your friend alone? This luxurious and romantic bedroom might be perfect. ",
		category = {PortToFriend.constants.FILTER_ID_ERP}
	}
	list[#list + 1] = {
		name = "@Holy_Mary",
		houseId = 20,
		description = "The place, where ruthless magicians study.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@MayhemGrrr",
		houseId = 36,
		description = "Pirate theme park with gambling, beach and waterslide!",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lausebengel",
		houseId = 54,
		description = "Gildenhalle der Legendary Revolution",
		category = {PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@Cyberqueen01",
		houseId = 39,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Cyberqueen01",
		houseId = 81,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Cyberqueen01",
		houseId = 36,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@OgieOgilthorpe",
		houseId = 38,
		description = "If this castle appears inviting and hospitable at the first glance, on closer inspection you can see which god its owner actually serves. Beware of the six-legged spider in the dungeon.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@OgieOgilthorpe",
		houseId = 62,
		description = "Welcome to my noble main house, enjoy the beauty of Artaeum. All Mundus Stones available and an assassin cult site for Sithis in the vaults.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@OgieOgilthorpe",
		houseId = 39,
		description = "Celebrate your parties in the huge hall, watch the dragon from the tower or meet up with Prince Irnskar at the bar and chat about your heroics.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@OgieOgilthorpe",
		houseId = 37,
		description = "Stroll with your partners in the romantic garden and enjoy the end of a peaceful day with a relaxing Skooma Pipe.",
		category = {PortToFriend.constants.FILTER_ID_ERP}
	}
	list[#list + 1] = {
		name = "@OgieOgilthorpe",
		houseId = 36,
		description = "This romantic holiday home is located in a secluded bay. Ideal for weddings and a quiet honeymoons. The well-guarded treasury reveals that the owner has more gold than a single person should own.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@OgieOgilthorpe",
		houseId = 47,
		description = "For just a million gold I couldn´t resist. A dark cult place, some craft tables and a deadric library.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Cox14",
		houseId = 62,
		description = "Family guild house with a beatiful aquarium.",
		category = {PortToFriend.constants.FILTER_ID_GUILD}
	}
	list[#list + 1] = {
		name = "@MistressBanana",
		houseId = 62,
		description = "Entspannungszone - sogar mit Toilette",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@MistressBanana",
		houseId = 78,
		description = "Friseursalon, Sauna + Wellnessbad",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@MistressBanana",
		houseId = 39,
		description = "Gruselfaktor garantiert! Am besten nach Mitternacht anschauen!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@MistressBanana",
		houseId = 70,
		description = "Für Entdecker und Höhlenforscher",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@MistressBanana",
		houseId = 38,
		description = "für Vampire und alle die es noch werden wollen :) - Im Verlies geht es durch die Bodenklappe noch weiter! Viel Spass!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@MistressBanana",
		houseId = 81,
		description = "Lust auf eine Bergwanderung mit Grillabend auf der Berghütte - kommt vorbei!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@MistressBanana",
		houseId = 94,
		description = "Auf ins Dschungelcamp - aber verirrt euch nicht und lasst euch nicht von eventuellen fleischfressenden Pflanzen anknabbern! Viel Spass!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@MistressBanana",
		houseId = 14,
		description = "Druidenzuflucht zum relaxen und meditieren - ich liebe halt die Natur.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Sturmfaenger",
		houseId = 48,
		description = "Explore the old tomb and try to solve the following quest:\r\n\r\nThree syllables are hidden somewhere in here. Find them and use the orcish clan seals in the main burial chamber to bring them into the right order. Who is buried in this grave?",
		category = {PortToFriend.constants.FILTER_ID_JUMPNRUN, PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@fred571",
		houseId = 62,
		description = "Parkour House",
		category = {PortToFriend.constants.FILTER_ID_JUMPNRUN, PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 78,
		description = "Mit Spielzimmer für lange Winterabende.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 63,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 49,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 80,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 88,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 89,
		description = "Willkommen in der Panthgerzahnkappelle, dem Ort wo Mirri und Basti wohnen.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 91,
		description = "Ein kleines Hotel mit Bar.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 90,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 47,
		description = "Eine Stadt am Abgrund, mit einer Schule, Spielplatz, Bibliothek, Fasthaus und einem Marktplatz.\r\nWer mag kann auch einen Schaufensterbummel machen.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 94,
		description = "kleiner versunkener Stadtbereich mit Marktplatz.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 12,
		description = "Kleines Haus ganz \"Groß\"",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 74,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 71,
		description = "Ewige Nacht mit Lichtblick",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 98,
		description = "Du möchtest einfach mal raus? Ein wenig Urlaub machen? Dann reise doch mal zum Nebelbruch Leuchtturm.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 76,
		description = "Auch Langfinger haben ein zu hause^^.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 105,
		description = "Druidendorf",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 99,
		description = "Eine Seepartie ist Lustig ...",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 79,
		description = "Vampirische Einblicke",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 30,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 104,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Greetha",
		houseId = 103,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@sheitana",
		houseId = 47,
		description = "Optimized for fast and easy crafting",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Nalos",
		houseId = 81,
		description = "Nicht Soli sondern Multitude",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Nalos",
		houseId = 80,
		description = "Shoemaker's Memorial",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Nalos",
		houseId = 45,
		description = "hmmm",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Nalos",
		houseId = 61,
		description = "Rückzugsort",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Nalos",
		houseId = 49,
		description = "Gemütlichkeit im Nebel",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Nalos",
		houseId = 66,
		description = "Jump'n Run, bitte beachten, das Haus ist ein PvP Gebiet: Ihr könnt euch heilen, an Ort und Stelle wieder beleben und euch auch gegenseitig liebevoll behandeln :D\r\nFür den optimalen Genuss bitte alle 3 Hebel im Raum links ziehen.",
		category = {PortToFriend.constants.FILTER_ID_JUMPNRUN, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Nalos",
		houseId = 62,
		description = "Pompeji vor dem Ausbruch des Vulkans",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Nalos",
		houseId = 15,
		description = "Das Rauschen im Wald, unbedingt in Ego Perspektive gehen , und bei Kocht-viele-Suppen zum Abschluss was Leckeres geniessen.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Nalos",
		houseId = 74,
		description = "Purr'kha",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Grila",
		houseId = 81,
		description = "Dschungelhaus",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Grila",
		houseId = 15,
		description = "Baumhaus",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Grila",
		houseId = 35,
		description = "Nachbau der Schatzkammer aus Prince of Persia Sands of Time",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Grila",
		houseId = 70,
		description = "Only, in the ancient legends it is stated, that one day an undead shall be chosen to leave the undead asylum, in pilgrimage, to the land of ancient lords, Lordran. Enjoy your visit to beautiful Blighttown, Dukes Archive, Lost Izalith and Darkroot Forest!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Grila",
		houseId = 25,
		description = "Grüne Laube",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@LordStorm1978",
		houseId = 71,
		description = "Kirche",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@LordStorm1978",
		houseId = 83,
		description = "Dampflok zurück in die Zukunft",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Koshjuha",
		houseId = 56,
		description = "I love to build with colorlights and trees. Dark broderhood? Well not really. A hain for assassins.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Koshjuha",
		houseId = 72,
		description = "I love to build with colorlights and trees. My home is my castle enjoy it;)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Koshjuha",
		houseId = 81,
		description = "Ritual site of a nord. Visit it at night and enjoy the light and atmosphere.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Koshjuha",
		houseId = 34,
		description = "A Redguard tavern with charm and rock garden.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Koshjuha",
		houseId = 25,
		description = "Enjoy food and drink or chill out with a game of redguard billiards.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Radulf_Silberwolf",
		houseId = 62,
		description = "Ein Ort für Templer, zum Treffen und Meditieren",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Radulf_Silberwolf",
		houseId = 28,
		description = "Jägertreff eines Nord",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Radulf_Silberwolf",
		houseId = 34,
		description = "Kleine Taverne am Rande des Weges",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Kyatos",
		houseId = 81,
		description = "Just a vampiric styled house. All munduses, about 3/4 crafting set stations collected for now (still in progress), training dummies, ayleid well, vampire thrall/fountain, transmute station",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@ClevaTreva",
		houseId = 81,
		description = "Antiquarians College",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@ClevaTreva",
		houseId = 49,
		description = "Witch Evicted by Covenant Forces",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@ClevaTreva",
		houseId = 32,
		description = "Adventurers beware!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@ClevaTreva",
		houseId = 80,
		description = "Nord themed Wedding Venue - with Nightclub!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@ClevaTreva",
		houseId = 86,
		description = "Warden's Retreat & Spa",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@ClevaTreva",
		houseId = 59,
		description = "Museum with scratchbuilt courtyard extension",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 62,
		description = "Ein Ort für Handwerk und Transmutieren oder einfach zur geistigen Entspannung und zum Abschalten. Inkl. alle Antiquitäten",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 59,
		description = "Gemütlich",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 81,
		description = "Nicht nur für Vampire",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 23,
		description = "Teppiche mal anders ;)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 70,
		description = "Liebe Elsweyr einfach. Gemütlich",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 64,
		description = "Relaxen, Fische schauen",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 73,
		description = "Gemütlich",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 83,
		description = "Dwemer Idylle",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 78,
		description = "Gemütliches Stadthaus",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 91,
		description = "Gemütlich stielecht",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 36,
		description = "Gemütlich - mit Pool",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 71,
		description = "Meine Tempelstadt + Dorf - stielecht",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 26,
		description = "Wintertraum - festlich",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 35,
		description = "Funke's Heim",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 75,
		description = "Auch ein Ork mag es Gemütlich ? oder ?",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 96,
		description = "Traditional",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 9,
		description = "Traditional Allianz Haus Aldmeri Dominion",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 34,
		description = "chic , goldig",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 49,
		description = "Hier wohnt die Hexe Grusel grusel",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 28,
		description = "Hier wohnt die Isobel - Herbstlich und gemütlich",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 80,
		description = "Hier ein 4 Länder Eck - eingefrorenes Venedig",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 88,
		description = "stielecht - gemütlich - mit Spielhalle",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 14,
		description = "Druiden Heim - Baumhaus",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 74,
		description = "liebe halt Elsweyr mit all seinem Flair",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 21,
		description = "liebevolles Heim zum Relaxen und Spielen",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 18,
		description = "Wohne und Arbeiten unter einem Dach",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 44,
		description = "Wohnen unter Pilzen",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 98,
		description = "Alles für die Liebe Hochzeit und Flitterwochen",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 16,
		description = "Pizzeria / Bäckerei",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 46,
		description = "Ferien auf dem Reiterhof/Hotel",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lokia99",
		houseId = 101,
		description = "Shopping Center mit Restaurant",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Heynrich1976",
		houseId = 41,
		description = "Felsgold-Kaverne/Rockgold Cavern\r\n\r\nRebuild cave ruins with merchants & bank, training & crafing area.",
		category = {PortToFriend.constants.FILTER_ID_GUILD}
	}
	list[#list + 1] = {
		name = "@Heynrich1976",
		houseId = 70,
		description = "Elsweyr-Heldenhalle/Elweyr Heroes Hall\r\n\r\nService Hall with portals to POI.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Heynrich1976",
		houseId = 1,
		description = "Vulkhelwacht Stube/Vulkhel Guard Room\r\n\r\nNice fireplace.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Heynrich1976",
		houseId = 13,
		description = "Eldenwurz Baumhaus/Elden Root Treehouse\r\n\r\nBuild in a second floor.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@mae_glunenstein",
		houseId = 64,
		description = "Argonische Wohlfühloase",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@mae_glunenstein",
		houseId = 71,
		description = "Niederländisches Dorf",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@mae_glunenstein",
		houseId = 70,
		description = "Dekadentes Katzenhaus ganz ohne Mäuse",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@mae_glunenstein",
		houseId = 61,
		description = "Poolhaus in Stein gemeißelt",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@mae_glunenstein",
		houseId = 79,
		description = "Klassisches Vampirheim mit allem was ein richtiger Vampir braucht",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Moytira",
		houseId = 71,
		description = "Alle Settische, Transmutation, Monturtisch, Übungspuppen. Gemütliches Strandcafé",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Moytira",
		houseId = 62,
		description = "Ein Ort des Wissens und Forschens",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Troodon80",
		houseId = 47,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Herma's",
		houseId = 47,
		description = "Cold Harbour Tower\r\n\r\nA daedric mage tower in a Coldharbour pocket plane, with some alive daedric prince.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Ridlok",
		houseId = 41,
		description = "Blut Tempel",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Ridlok",
		houseId = 39,
		description = "Drache",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Ridlok",
		houseId = 62,
		description = "Luftschiff blau",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Ridlok",
		houseId = 70,
		description = "Luftschiff rot",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Ridlok",
		houseId = 33,
		description = "Keep",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Ridlok",
		houseId = 54,
		description = "Valhalla",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Ridlok",
		houseId = 47,
		description = "Arena",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 31,
		description = "Golden Habitat",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 28,
		description = "The Experiment (mit EHT Buch)",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 61,
		description = "Razahrdark Valley (mit EHT Buch)",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 46,
		description = "Summer Residence",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 80,
		description = "Freezing SPA ( Mit EHT Effekten)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 5,
		description = "Eyes in the Dark (mit EHT Buch)",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 71,
		description = "Green Hell Maze/ Irrgarten (EHT erforderlich)",
		category = {PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 32,
		description = "The Lucky Dwemer",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 38,
		description = "Under the Castle ( Kleine Geschichte in EHT Büchern)",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 26,
		description = "Vampires Retreat",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 15,
		description = "Refuguim, (kleine Geschichte in EHT Büchern)",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 81,
		description = "Wedding celebration with a little secret",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 12,
		description = "Assassins Sanctuary, (mit EHT Büchern)",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@strike4",
		houseId = 16,
		description = "Blue Fox Bar, kleines Cafe' / Bar",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@swanee9480",
		houseId = 82,
		description = "Von der Winkelgasse inspirierte \"Einkaufsstraße\"",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@swanee9480",
		houseId = 45,
		description = "Magierturm mit allen Annehmlichkeiten nicht nur für Stäbchen-Schwinger (inklusive Wellness-Pool)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Akay13",
		houseId = 40,
		description = "Die Ebenherzpakt Allianz lädt alle Spieler zu unserer Gildeninsel ein.\r\n\r\nIhr findet dort sämtliche Settische alphabetisch sortiert. Ein Transmutationstein in der unteren Hütte gibt euch die Möglichkeit Rüstungen, Traits zu ändern oder wieder herzustellen.\r\n\r\nZum üben findet ihr alle notwendigen Übungspuppen inkl. Raidpuppen abseits am Strand. Damit ihr auch die Ultis aufladen könnt ist die ätherische Quelle zum Auffrischen auch dort auf dem Berg zu finden.\r\n\r\nAlle Mundussteine findet ihr rechts am Strand.\r\nDahinter ist der Platz für unsere lichtscheuen Gäste den Vampiren. Für sie steht das Becken des Verlusts und ein Seelenbeschworener Leibeigner bereit.\r\n\r\nUnsere Händler und Bänker stehen euch 24/7 zur Verfügung.\r\n\r\nStrandmatten und Verpflegung ist \"all Inklusive\".",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 23,
		description = "Jahrmarktslabyrinth mit Bar und Livemusik",
		category = {PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 80,
		description = "Molag Bal Festival - Ein Riesenfestivalgelände mit Chillout, Foodstands, Bühne, Band, Musik und latürnich Backstage",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 13,
		description = "Kleiner Raum um schnell mal an seine Sachen zu kommen, inkl. Färbetisch",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 28,
		description = "Eine kleine Muffbude mit Mühlenhobby",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 31,
		description = "Ein kleines, leicht ungewöhnlich eingerichtetes Häuslein, eines nie anwesenden Gelehrten",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 25,
		description = "Ein kleines gemütliches Häusle im Grünen",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 34,
		description = "Unterschlupf eines nicht näher definierbaren obskuren Kultes",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_LABYRINTH, PortToFriend.constants.FILTER_ID_JUMPNRUN, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 49,
		description = "Leicht spukender Unterschlupf einer bastelfreudigen Hexe kurz vor dem Halloweenfest",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 63,
		description = "Rückzugsort für wahre Legenden, klein, fein, mit Secretareas und allem möglichen Entdeckbaren",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_HIDE_SEEK}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 54,
		description = "Persönliche Mainresidence mit Handwerkstischen, Angelschifferei und Megaausblick",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 62,
		description = "Großer, edel ausgestatter Stammsitz, mit allem möglichen Luxus für Angestellte und Gäste",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 22,
		description = "Kleines praktisches Domizil",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 6,
		description = "Irgendwas ist seltsam hier, die falsche Tür genommen? Ich nehme mal den Stuhl da...",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 42,
		description = "Das... kommt.. unerwartet!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 58,
		description = "Hui, edel!",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 77,
		description = "Sehr komfortable - passend zu dem Wetter da draussen (wir lieben dieses Wetter!)",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 68,
		description = "Zuckersüße Studienkammer",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 5,
		description = "Sitz, Bett und Gallerie - was will man mehr?",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 10,
		description = "Ein Haus, ein Garten, ein Feuchtgebiet...",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 29,
		description = "Ein Stadthaus mit Versammlungscharakter - hier verpeil...ve.. 'PLANT' Rakeipa ihre Feldzüge! *Prost*",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 35,
		description = "A sweet little Markethall",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 75,
		description = "Sunrise Orsinioasis",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 65,
		description = "'World's DeAR': World's Deadliest Adventure Restaurant!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 19,
		description = "Aua, meine Augen.... schön hell hier, wo sind denn die Lampen???",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 3,
		description = "Klein, fein, gemütlich",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 4,
		description = "Was ne Party, gestern...",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 17,
		description = "A walkers 'Home' - a true, real amd cozy home of a tamrilian hereo",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 33,
		description = "Tamriel Trade Ikea - basically are all items available - just send me ingame pm (storage and outbag)\r\n(under permanent construction - it is a real furnish trade and storage hall)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 40,
		description = "A small coastsided fishermens village, with some ancient sites, a grand topal Holiday In Hotel, an traditional Restaurant and Lyranth lives there... dont wonder about her pathes through her house - dremora are not really understanding that 'walls thing'... A summers traditional 5 Star Resort!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 95,
		description = "A simple room with a desktop for cards",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 70,
		description = "Garten für die Verwendung von etwas Zeit, für sich selbst, zu verweilen, abzufeiern, ne Runde zu zocken, Sauna, Botanik: Natürlich mit Bar und Kaninchen, so wie hauseigenem Friedhof! (Also vorsichtig, nicht zu lange verweilen)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}	
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 81,
		description = "Das Haus am Berg, meine offene Handwerkshalle, es gibt sogar Plätzchen um sich kurz zu setzen.",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Tolour",
		houseId = 14,
		description = "'Vamp's Cove' - some wilde Vampirers seems to live here - I can't see them, might they are not at home, happy that I am alone here - not sure if I am, but .. nice.. it is!",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Sathyrius",
		houseId = 81,
		description = "Ist eine Mischung zwischen Galerie und \"Hotel\" geworden.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Sathyrius",
		houseId = 27,
		description = "Ist mein Lieblingswohnort mit allem Was man braucht, inkl. Kultplatz ;-)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Sathyrius",
		houseId = 71,
		description = "Mein modernes Haus mit Ausblick auf einen fantstischen Khajiit Tempel",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Valin96",
		houseId = 70,
		description = "Ist mein Haupthaus",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Valin96",
		houseId = 71,
		description = "Tempel mit einem kleinen Geheimnis",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Valin96",
		houseId = 81,
		description = "Berglandschaft",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Ewhax",
		houseId = 36,
		description = "Dagoberts treasure",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Ydlar",
		houseId = 71,
		description = "Die Gilde Elfenwald hat hier ihren gleichnamigen Wohnsitz. Alle Set-Tische, Mundus-Steine, Raid-Atro und andere Dummys. Oder einfach nur am Wasser oder im Baumhaus chillen. Keldora sorgt für euer leibliches Wohl ^^ ;-)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 47,
		description = "Ayleïden Garten in Kalthafen mit vielen Sammlungsstücken und Co.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 22,
		description = "Die Bank",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 12,
		description = "Archiv der Gelehrten mit lesbaren Büchern aus dem Spiel",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 81,
		description = "Die Grotte",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 11,
		description = "Ayleïdengrube",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 23,
		description = "Der Garten von Knurr'kha",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 44,
		description = "Gartenhaus",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 35,
		description = "Räubernest",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 43,
		description = "Herrenhaus im Walde",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@FwooperXCI",
		houseId = 71,
		description = "Ein Tempel als Sommerresidenz",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Araphorn83",
		houseId = 71,
		description = "All Crafting stations, all Mundus stones, Trial Dummy + AoE Dummies, jumping platform mini-game and more!",
		category = {PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_RAID, PortToFriend.constants.FILTER_ID_JUMPNRUN}
	}
	list[#list + 1] = {
		name = "@CrazyVogue",
		houseId = 59,
		description = "Classic townhouse in Altmeri style.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@CrazyVogue",
		houseId = 11,
		description = "Altmer-style garden.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@CrazyVogue",
		houseId = 70,
		description = "The middle part of a larger town.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@CrazyVogue",
		houseId = 14,
		description = "The high part of a larger town.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@CrazyVogue",
		houseId = 78,
		description = "Hall of an order of paladins.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@CrazyVogue",
		houseId = 27,
		description = "Noble's Manor.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@CrazyVogue",
		houseId = 35,
		description = "House of an Redguard botanist.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@CrazyVogue",
		houseId = 31,
		description = "A small restaurant with an custom aquarium build.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@CrazyVogue",
		houseId = 43,
		description = "Classic dunmer manor.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Moguntia",
		houseId = 38,
		description = "A place to relax: fishing, sailing, playing Go or just sitting down in the inhouse garden. Enjoy your stay !",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@tïm'99",
		houseId = 60,
		description = "Set tables sorted after their german names, 50 Precursor to yell at you",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_GUILD}
	}
	list[#list + 1] = {
		name = "@Iriidsuke",
		houseId = 59,
		description = "Art museum",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Iriidsuke",
		houseId = 49,
		description = "My witch house",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Iriidsuke",
		houseId = 47,
		description = "a dwemer engineer with a penchant for alchemy has built a lab on a floating island in Coldharbour to try to create dwarven machines that will infuse life energy from monsters as he inoculates himself. He asked Mirri to test all the sets on the mannequins to find the best combo to put his creatures to the test and thus make them indestructible\r\nAll Crafting stations, some Mundus stones, trial training dummies, vampire stuff",
		category = {PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Iriidsuke",
		houseId = 13,
		description = "a wood elf house with an argonian touch",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Iriidsuke",
		houseId = 15,
		description = "Labyritnh + Jump'n Run. Each pet/mount is a checkpoint, if you fall after it you can take the cut of this checkpoint",
		category = {PortToFriend.constants.FILTER_ID_LABYRINTH, PortToFriend.constants.FILTER_ID_JUMPNRUN}
	}
	list[#list + 1] = {
		name = "@Iriidsuke",
		houseId = 70,
		description = "Labyritnh + Jump'n Run. Each pet/mount is a checkpoint, if you fall after it you can take the cut of this checkpoint",
		category = {PortToFriend.constants.FILTER_ID_LABYRINTH, PortToFriend.constants.FILTER_ID_JUMPNRUN}
	}
	list[#list + 1] = {
		name = "@Iriidsuke",
		houseId = 27,
		description = "An house for shows, parade and shootings, red carpet for parades, lodges, 4 shooting zone, 1 by season",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Iriidsuke",
		houseId = 63,
		description = "a retreat with thermal baths, sauna for winter holidays",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Iriidsuke",
		houseId = 81,
		description = "a skyrim antiquarian gallery",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@J.ugo",
		houseId = 80,
		description = "Jotunhiem\r\n\r\nAll crafting sets, all mundus, x3 Dummies (21m) x3 Wells, transmute stations, armoury and of course free to use for everyone. Don't need to be a part of any guild.",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@Aetherlethe",
		houseId = 13,
		description = "A nice place to stay after all your adventures.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Aetherlethe",
		houseId = 47,
		description = "Vampire Castle",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_RAID, PortToFriend.constants.FILTER_ID_HIDE_SEEK}
	}
	list[#list + 1] = {
		name = "@Dixitos",
		houseId = 75,
		description = "Nordheim - A cozy northern style home, far from civilization, with everything you need in ESO everyday life.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Zhikander",
		houseId = 18,
		description = "Häuser einer Magierin, die Antiquitäten sammelt und Licht liebt",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Zhikander",
		houseId = 59,
		description = "Häuser einer Magierin, die Antiquitäten sammelt und Licht liebt",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Zhikander",
		houseId = 81,
		description = "Häuser einer Magierin, die Antiquitäten sammelt und Licht liebt",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Zhikander",
		houseId = 56,
		description = "Häuser einer Magierin, die Antiquitäten sammelt und Licht liebt",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 41,
		description = "maison de guilde avec son bar à chat",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_GUILD}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 73,
		description = "Maison de khajiit",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 81,
		description = "Musée",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 19,
		description = "Médiathèque",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 25,
		description = "boutique occulte",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 18,
		description = "Maison brétonne",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 43,
		description = "pavillon du lac d'amaya",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 71,
		description = "prairie asiatique",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 37,
		description = "Maison de khajiit",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 15,
		description = "Maison de bosmer",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_JUMPNRUN}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 30,
		description = "Taverne",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 7,
		description = "boutique d'apothicaire",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 34,
		description = "boulangerie",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 13,
		description = "boutique bazar",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 27,
		description = "maison impériale",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 9,
		description = "maison altmer avec fontaine + esclave pour vampire",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 36,
		description = "SPA",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 14,
		description = "restaurant druidique",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 91,
		description = "auberge",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 74,
		description = "villa du sud",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 42,
		description = "bibliothèque oubliée",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 6,
		description = "Mini temple Khajiit",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 47,
		description = "restaurant",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 82,
		description = "guilde des mages",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 11,
		description = "grotte sous-marine",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 23,
		description = "temple khajiit",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 64,
		description = "maison Hlaalu",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 33,
		description = "guilde des guerriers",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 56,
		description = "guilde des assassins",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 94,
		description = "palais de corail et grotte de dragon",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 86,
		description = "bibliothèque perdue dans ruines ayléides",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 40,
		description = "onsen",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 80,
		description = "bar à chat en cristal",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 39,
		description = "necropole",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 44,
		description = "maison des 4 saisons - printemps",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 35,
		description = "maison des 4 saisons - été",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 28,
		description = "maison des 4 saisons - automne",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 76,
		description = "guilde des voleurs",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 20,
		description = "maison dunmer",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 60,
		description = "grotte maormer",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 104,
		description = "laboratoire de recherche",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 61,
		description = "laboratoire dwemer",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 98,
		description = "village druidique",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 57,
		description = "maison rougegarde",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 38,
		description = "iles flottantes",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 70,
		description = "temple khajiit",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 26,
		description = "quartier résidentiel d'un village",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 105,
		description = "maison des 4 bardes Griff'mélodieuse",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 62,
		description = "royaume d'Azura - ombrelune",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 48,
		description = "forêt enchantée",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 55,
		description = "planétarium dwemer",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 107,
		description = "temple en ruines",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 108,
		description = "jardin oriental",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 46,
		description = "maison moderne",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 58,
		description = "banque",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 3,
		description = "aquarium",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 103,
		description = "village rougegarde",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 111,
		description = "salon de thé/café",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 2,
		description = "atelier d'art",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 87,
		description = "théâtre",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 100,
		description = "salle de méditation",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
		list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 22,
		description = "glacier",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Lazulischaton",
		houseId = 16,
		description = "chocolaterie",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Neomazu",
		houseId = 47,
		description = "Alle Set Tische, 21 Puppen in doppelter Ausführung in allen Großen, Blutbrunnen Humanoid für die Vampire, 6 Quellen für ultimative Kraft, Kochstellen, Alchemie, Verzaubern, Transmutation, Montur und Färber, alle Mundusstein.",
		category = {PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Rioja",
		houseId = 34,
		description = "Haus eines Alchemisten - mit eigenem Kräuteranbau",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Rioja",
		houseId = 46,
		description = "Rückzugsort eines weitgereisten Tamriel-Abenteurers - mit Werkstatt, Trainingsgelände und Badezimmer",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Rekcuz",
		houseId = 41,
		description = "Guild Cave - To be on the ground of the Elder Scrolls Guild Cave can inspire your crafting skills. Yes! I will reward you with recipes after a sight seeing tour. (Currently under construction phase)",
		category = {PortToFriend.constants.FILTER_ID_GUILD}
	}
	list[#list + 1] = {
		name = "@Rekcuz",
		houseId = 74,
		description = "Boss of Elder Scrolls Lucury Boardwalk - Yes... also the Boss of Elder Scrolls likes to rest, once the entired support requests feds up my nose. Therefore i built this broadwalk with a tiny little swimming pool. Come visit me!",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Rhagoon",
		houseId = 70,
		description = "Mein Haupthaus",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Rhagoon",
		houseId = 33,
		description = "Gildenhaus von Lupus Luna",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_GUILD}
	}
	list[#list + 1] = {
		name = "@Rhagoon",
		houseId = 27,
		description = "Vielleicht ein kleines bisschen unheimlich",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Rhagoon",
		houseId = 49,
		description = "verhext :)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Raghor",
		houseId = 47,
		description = "Vor sehr, sehr langer Zeit kämpfte ein Drache um sein Leben - und verlor ... heute nennt man den Ort \"Drachenfels\"",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@Raghor",
		houseId = 33,
		description = "\"New Greyskull\" - meine (tamrielische) Version der \"He-Man-Burg\"",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Raghor",
		houseId = 81,
		description = "\"Verlassene Kultstatt\" - vor längerer Zeit schon hat 'Das Übel' Einzug erhalten und die Kultisten haben ihre Stätte verlassen. Übrig geblieben sind ... ach, seht selbst!",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Raghor",
		houseId = 48,
		description = "\"Szenen aus Narnia\" - Ein Gang durch bekannte Szenen der Narnia-Buchreihe, inklusive Kleiderschrank mit Durchgang in den Wald.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Raghor",
		houseId = 32,
		description = "Ein selbstgebautes Dungeon, wenn man so will. ZIELE: 3 verschiedene Gegner besiegen (empfohlene Anzahl an Spielern: mind. 3 DDs), 1 \"Puzzle\" zusammen setzen, die Dunkelheit vertreiben (Stundenglas von Mitternacht auf Sonnenaufgang stellen) - REGEL: Beim Verlassen des Hauses bitte wieder alles \"auf Anfang\" setzen (Türen, \"Puzzel\", etc ...)",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@Graham82",
		houseId = 18,
		description = "Graham's Gardner House\r\n\r\nIn diesem Haus hat sich Graham, die alte PvP-Legende, die einst mit Zweihänder und Drachensprung in Cyrodiil ihr Unwesen getrieben hat, sich endgültig zur Ruhe gesetzt.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@KAIDISTORTION",
		houseId = 81,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Dux-Nihilus",
		houseId = 89,
		description = "",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Nemedon",
		houseId = 23,
		description = "CSI-Tamriel in einem befestigten Handelsposten:\r\n- Entdecke alle 7 Totem.\r\n- Suche alle 3 versteckten Überlebendem.\r\n- Finde alle 4 Täter.\r\n- Starb jemand vor dem Überfall?\r\n- Was taten die Opfer zuletzt?\r\n- Was war die Motivation der 'Killer'?\r\n- Finde alle 6 Kollateralschäden auẞerhalb des Handelspostens.\r\n\r\nCrime Scene Investigation in a fortified trading post.\r\n- Discover the all 7 dead.\r\n- Search and find all 3 hidden survivors.\r\n- Find all 4 perpetrators.\r\n- Did someone die before the rampage?\r\n- What were the victims in their last moments doing?\r\n- What was the 'killers' motive?\r\n- Find all 6 collateral damage outside the trading post.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIDE_SEEK}
	}	
	list[#list + 1] = {
		name = "@Nemedon",
		houseId = 81,
		description = "Escape House",
		category = {PortToFriend.constants.FILTER_ID_LABYRINTH, PortToFriend.constants.FILTER_ID_JUMPNRUN}
	}
	list[#list + 1] = {
		name = "@O'mighty",
		houseId = 98,
		description = "Utilitarian all purpose guild hall with all amenities within close proximity of spawn\r\nDirectly to your left when you enter you'll find the crafting hub, this includes:\r\nAll fully attuned Grand Master Crafting stations\r\nAlchemy, Enchanting and Provisioning stations\r\nTransmute, Armoury and Outfit stations\r\nBanker, Merchant and Fence NPCs\r\nAetherial Well, Vampire Fountain and Thrall\r\nPvP Duelling Arena\r\nTo your right from spawn you will find a Trial Dummy (21 million health) in addition to another Aetherial Well, Armoury Assistant and all 13 Mundus Stones.",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@Nocternity3",
		houseId = 102,
		description = "This is the cradle of nightmares, with the flipped-over haunted house, a small witches laboratory and a big library with daedric summoning part",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 62,
		description = "Unused villa but home construction above water",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 94,
		description = "Inspired by the realm of Meridia, the colored rooms",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 39,
		description = "Inspired by Shivering Isles, Mania & Dementia (Sheogorath)",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 93,
		description = "Dremora's house & altmer laboratory",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 56,
		description = "Abandoned Khajiit temple",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 98,
		description = "Abandoned redguard villa",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 90,
		description = "PvP arena & training house",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 71,
		description = "Kynareth temple",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 80,
		description = "abandoned Dwemer fortress",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 27,
		description = "Inspired by Hircine's Hunting Ground",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alamyël",
		houseId = 38,
		description = "Vampire castle",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@CaptainKeranga",
		houseId = 91,
		description = "Guild House, All Gear Sets in Grand Master Stations, All Mundus Stones, 3 x Trial Dummies, Vampire Well and Thrall, Aetherian Well, all set in a tranquil surroundings",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING, PortToFriend.constants.FILTER_ID_RAID}
	}
end

function PortToFriendData.CreateNaDataList()
	local i = 1
	local list = PortToFriendData.naData
	list[#list + 1] = {
		name = "@craybest",
		houseId = 78,
		description = "The new abandoned Ravenhill Manor, up in the Skyrim ravines. It's still a mystery what truly happened in there, but you can feel an uneasy feeling whenever you get close to it. Signs of failed summonings, corpses lying around in a darkness that envelopps the area. what is its true story? maybe you can help finally solving the mystery, if you're brave enough to enter, that is.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Gadolyah",
		houseId = 47,
		description = "Maw of Lorkaj Training Centre",
		category = {PortToFriend.constants.FILTER_ID_RAID}
	}
	list[#list + 1] = {
		name = "@SoftPink",
		houseId = 80,
		description = "Perfect for all your needs. My house is equipped with all Grandmaster crafting stations (current sets), all Mundus, all Assistants, Vampire needs, Aetherial well, and 21M parse dummies. Feel free to stop by ^_^",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@G1Countdown",
		houseId = 40,
		description = "Tropical Island paradise. Fully decorated.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Alexsae",
		houseId = 63,
		description = "A cozy hideaway with amenities. There are basic crafting stations, transmutation, Mundus and a raid training dummy. Come relax and read in front of the fire. Don't forget to stop by the aquarium downstairs.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Alexsae",
		houseId = 61,
		description = "A home of horrors. Explore the caves and encampment. Venture down the hillside to a place of rest. Death awaits the unwary.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Alexsae",
		houseId = 23,
		description = "Location, location! This home has the basic crafting stations, outfit station, transmutation and is next to the social hub of Rawl'kha. A handy fence is right outside the gate.",
		category = {PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Alexsae",
		houseId = 60,
		description = "A shipwrecked home with amenities. There are basic crafting stations and an outfit station. Explore the ruins which have been repurposed into a cozy home and library. Climb the hillside to enjoy the views. Rest at the well with a good book.",
		category = {PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Evilspock",
		houseId = 55,
		description = "Vulcan Commandos Guild Hall. Beam aboard the warship K'Lemal and you'll find all craftable set stations inside! All Mundus Stones and Trial Atronach. Transmute Station, Aethereal Well, Vampire Util, Armory, Assistants and more immediately available at the entrance.",
		category = {PortToFriend.constants.FILTER_ID_GUILD, PortToFriend.constants.FILTER_ID_CRAFTING}
	}
	list[#list + 1] = {
		name = "@Sharktoes",
		houseId = 81,
		description = "Antiquities and magical items from all over Tamriel are brought to this Alpine College for study and display. And extensive library, collection of banned books, and sacred relics can be found",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Sharktoes",
		houseId = 16,
		description = "A small, quaint alchemy and enchanting laboratory filled with plants, elixirs, and poisons from all over Tamriel.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Sharktoes",
		houseId = 41,
		description = "At first glance, the sanctuary ruins are a place of meditation and reflection. But hidden behind the facade is the seedy underbelly of an Outlaw's Refuge, specializing in the buying and selling of sacred relics.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Sharktoes",
		houseId = 70,
		description = "Below the luxury on display in the inner chamber and upper courtyard is a world for those less fortunate. Precariously clinging to the rock face, weave your way down to the waters below, with nooks and crannies to explore along the way.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT}
	}
	list[#list + 1] = {
		name = "@Sharktoes",
		houseId = 91,
		description = "A hall of respite after the toils of battle in Cyrodiil. Collections of relics and research materials, a hospital and armory, barracks, shrines and memorials to honor our brothers-in-arms, and more.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY}
	}
	list[#list + 1] = {
		name = "@Dolgubon",
		houseId = 36,
		description = "A tricky maze with lots of doors that may or may not be safe. Get to the rooftop to finish, and say hi to Bob the statue on the way!",
		category = { PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@Dolgubon",
		houseId = 9,
		description = "A maze best played with friends - but still great solo!",
		category = { PortToFriend.constants.FILTER_ID_LABYRINTH}
	}
	list[#list + 1] = {
		name = "@Nemedon",
		houseId = 23,
		description = "Crime Scene Investigation in a fortified trading post.\r\n- Discover the all 7 dead.\r\n- Search and find all 3 hidden survivors.\r\n- Find all 4 perpetrators.\r\n- Did someone die before the rampage?\r\n- What were the victims in their last moments doing?\r\n- What was the 'killers' motive?\r\n- Find all 6 collateral damage outside the trading post.\r\n\r\nCSI-Tamriel in einem befestigten Handelsposten:\r\n- Entdecke alle 7 Totem.\r\n- Suche alle 3 versteckten Überlebendem.\r\n- Finde alle 4 Täter.\r\n- Starb jemand vor dem Überfall?\r\n- Was taten die Opfer zuletzt?\r\n- Was war die Motivation der 'Killer'?\r\n- Finde alle 6 Kollateralschäden auẞerhalb des Handelspostens.",
		category = {PortToFriend.constants.FILTER_ID_HIGHLIGHT, PortToFriend.constants.FILTER_ID_ROLEPLAY, PortToFriend.constants.FILTER_ID_HIDE_SEEK}
	}	
end

function PortToFriendData.CreateDataList()
	if GetWorldName() == "EU Megaserver" then
		PortToFriendData.CreateEuDataList()
	else
		PortToFriendData.CreateNaDataList()
	end
end

function PortToFriendData.GetLibraryData()
	PortToFriendData.CreateDataList()
	if GetWorldName() == "EU Megaserver" then
		return PortToFriendData.euData
	else
		return PortToFriendData.naData
	end
end