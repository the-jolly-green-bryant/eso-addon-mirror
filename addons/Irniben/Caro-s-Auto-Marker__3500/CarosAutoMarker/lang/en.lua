local L = {}

--L.SI_BINDING_NAME_CPC_StartPreCrafting = "Start pre-crafting"

L.CaroAM_LocationDropdown = "Location"
L.CaroAM_LocationAddCurrent = "Add current location"
L.CaroAM_EnemyDropdown = "Enemy names"
L.CaroAM_EnemyRecordNames = "Record encounters"
L.CaroAM_EnemyAddNameDiag = "Enter the exact name of the enemy."
L.CaroAM_EnemyAddName = "Add name"
L.CaroAM_EnemyRemoveName = "Remove name"
L.CaroAM_OnlyAsGroupLeader = "Activate only as group leader"
L.CaroAM_OnlyAsGroupLeaderTT = "Activate this setting to prevent the addon from auto-marking enemies when in a group and not the group-leader."
L.CaroAM_OnlyTrialsAndDungeons = "This function is only available for dungeons, arenas and trials."
L.CaroAM_ExplainNames = "You can specify enemies by their names, to let the addon automatically set your choosen markers, once you look at the enemy. You can either add names manually (but the name would have to be exactly as written in the game) or activate the record function to fill the dropdown list while playing."

for stringId, stringValue in pairs(L) do
	ZO_CreateStringId(stringId, stringValue)
end

CarosAutoMarker.PreSetEnemies = {
	[636]= { -- HRC
		"Enraging Welwa",
		"Firstmage Chainspinner",
		"Anka-Ra Flame-Shaper",
		"Firstmage Overcharger",
	}, 	
	[638]= { -- AA
		"Firstmage Overcharger",
	}, 
	[639]= { -- SO
		"Scaled Court Overcharger",
	}, 
	[725]= { -- MoL
		"Dro-m'Athra Sun-Eater",
		"Dro-m'Athra Savage",
		"Ogre Shaman",
		"Ogre Flesh-Render",
	}, 
	[975]= { -- HoF
		"Capacitor",
		"Refabricated Arquebus",
		"Hunter-Killer Negatrix",
		"Hunter-Killer Positrox",
	}, 
	[1000]= { -- AS
		"Ordinated Purifier",
	}, 
	[1051]= { -- CR
		"Shadow of the Fallen",
		"Malicious Sphere",
		"Shade of Siroria",
		"Shade of Relequen",
		"Shade of Galenwe",
	}, 
	[1121]= { -- SS
		"Alkosh's Fate",
		"Storm Atronach",
		"Alkosh's Will",
		"Flame Atronach",
		"Vigil Statue",
		"Jone's Gale-Claw",
		"Jode's Fire-Fang",
		"Senche-Raht",
		"Alkosh's Roar",
	}, 
	[1196]= { -- KA
		"Vampire Infuser",
		"Half-Giant Tidebreaker",
		"Half-Giant Sea Shaman",
		"Half-Giant Bulwark",
	}, 
	[1263] = { -- RG
		"Sul-Xan Soulweaver",
		"Prime Meteor",
		"Fire Behemoth",
		"Flesh Abomination",
		"Havocrel Butcher",
		"Havocrel Barbarian",
		"Havocrel Torchcaster",
	}, 	
	[1344] = { -- DSR
		"Dreadsail Keelcutter",
		"Dreadsail Brewmaster",
	},
}