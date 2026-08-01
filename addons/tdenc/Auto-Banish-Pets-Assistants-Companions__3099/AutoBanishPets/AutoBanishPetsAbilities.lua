AutoBanishPets = AutoBanishPets or {}
local AutoBanishPets = AutoBanishPets

AutoBanishPets.abilities = {
    [SKILL_TYPE_CLASS] = {
        [2] = { -- Sorcerer
            -- Familiars and Clannfears
            [23304] = true, [30631] = true, [30636] = true, [30641] = true,
            [23319] = true, [30647] = true, [30652] = true, [30657] = true,
            [23316] = true, [30664] = true, [30669] = true, [30674] = true,
            -- Twilights
            [24613] = true, [30581] = true, [30584] = true, [30587] = true,
            [24636] = true, [30592] = true, [30595] = true, [30598] = true,
            [24639] = true, [30618] = true, [30622] = true, [30626] = true,
        },
        [4] = { -- Warden
            -- Bears
            [85982] = true, [85983] = true, [85984] = true, [85985] = true,
            [85986] = true, [85987] = true, [85988] = true, [85989] = true,
            [85990] = true, [85991] = true, [85992] = true, [85993] = true,
        },
    },
    [SKILL_TYPE_WORLD] = {
        [5] = { -- Vampire
            [32624] = true, [32624] = true, [32624] = true, [32624] = true,
	    	[38932] = true, [38932] = true, [38932] = true, [38932] = true,
	        [38931] = true, [38931] = true, [38931] = true, [38931] = true,
        },
        [6] = { -- Werewolf
		    [32455] = true, [32455] = true, [32455] = true, [32455] = true,
		    [39075] = true, [39075] = true, [39075] = true, [39075] = true,
		    [39076] = true, [39076] = true, [39076] = true, [39076] = true,
        }
    }
}

AutoBanishPets.companions = {
    [1] = 9245, -- Bastian
    [2] = 9353, -- Mirri
    [3] = 9911, -- Ember
    [4] = 9912, -- Isobel
    [5] = 11113, -- Sharp
    [6] = 11114, -- Azandar
}

AutoBanishPets.bankers = {
    [267] = true, -- Tythis
    [6376] = true, -- Ezabi
    [8994] = true, -- Baron
    [9743] = true, -- Factotum Property
    [11097] = true, -- Pyroclast
    -- Eri
}

AutoBanishPets.merchants = {
    [301] = true, -- Nuzhimeh
    [6378] = true, -- Fezez
    [8995] = true, -- Peddler
    [9744] = true, -- Factotum Commerce
    [11059] = true, -- Hoarfrost
    -- Xyn
}

AutoBanishPets.fences = {
    [300] = true, -- Pirharri
}

AutoBanishPets.otherAssistants = {
    [9745] = true, -- Ghrasharog
    [10184] = true, -- Giladil
    [10617] = true, -- Aderene
    [10618] = true, -- Zuqoth
    [11876] = true, -- Drinweth
    -- Tzozabrar
}

AutoBanishPets.locations = {
    -- zoneId: https://wiki.esoui.com/Zones
    [9245] = {},
    [9353] = {
        [826] = true, -- Dark Brotherhood Sanctuary
    },
    [9911] = {},
    [9912] = {
        [826] = true, -- Dark Brotherhood Sanctuary
        [746] = true, -- Vulkhel Guard Outlaws Refuge
        [747] = true, -- Elden Root Outlaws Refuge
        [748] = true, -- Marbruk Outlaws Refuge
        [749] = true, -- Velyn Harbor Outlaws Refuge
        [750] = true, -- Rawl'kha Outlaws Refuge
        [751] = true, -- Belkarth Outlaws Refuge
        [752] = true, -- Wayrest Outlaws Refuge
        [753] = true, -- Daggerfall Outlaws Refuge
        [754] = true, -- Evermore Outlaws Refuge
        [755] = true, -- Shornhelm Outlaws Refuge
        [756] = true, -- Sentinel Outlaws Refuge
        [757] = true, -- Davon's Watch Outlaws Refuge
        [758] = true, -- Windhelm Outlaws Refuge
        [759] = true, -- Stormhold Outlaws Refuge
        [760] = true, -- Mournhold Outlaws Refuge
        [761] = true, -- Riften Outlaws Refuge
        [780] = true, -- Orsinium Outlaws Refuge
        [821] = true, -- Thieves Den
        [837] = true, -- Anvil Outlaws Refuge
        [971] = true, -- Vivec City Outlaws Refuge
        [982] = true, -- Slag Town Outlaws Refuge
        [1028] = true, -- Alinor Outlaws Refuge
        [1070] = true, -- Lilmoth Outlaws Refuge
        [1088] = true, -- Rimmen Outlaws Refuge
        [1139] = true, -- Senchal Outlaws Refuge
        [1178] = true, -- Solitude Outlaws Refuge
        [1211] = true, -- Markarth Outlaws Refuge
        [1252] = true, -- Leyawiin Outlaws Refuge
        [1293] = true, -- Fargrave Outlaws Refuge
        [1311] = true, -- Ascendant Order Hideout
        [1319] = true, -- Gonfalon Bay Outlaws Refuge
        [1367] = true, -- Vastyr Outlaws Refuge
        [1412] = true, -- Necrom Outlaws Refuge
    },
    [11113] = {},
    [11114] = {
        -- Eyevea
        [203] = true, -- Cheesemonger's Hollow
        [218] = true, -- Circus of Cheerful Slaughter
        [219] = true, -- Chateau of the Ravenous Rodent
        [267] = true, -- Eyevea
        [529] = true, -- Eyevea Mages Guild
        [541] = true, -- Glade of the Divines
        -- Artaeum
        [1027] = true, -- Artaeum
        [1063] = true, -- Grand Psijic Villa
    },
}

AutoBanishPets.wayshrines = {
    [9245] = {},
    [9353] = {},
    [9911] = {},
    [9912] = {},
    [11113] = {},
    [11114] = {
        -- Eyevea
        [215] = true, -- Eyevea
        -- Artaeum
        [360] = true, -- Artaeum
        [373] = true, -- Grand Psijic Villa
    },

}

AutoBanishPets.ingredients = {
    [9245] = {
        ["Cheese"] = true, ["Käse"] = true, ["Fromage"] = true, ["Сыр"] = true, ["チーズ"] = true, ["Queso"] = true, ["奶酪"] = true,
    },
    [9353] = {},
    [9911] = {},
    [9912] = {},
    [11113] = {},
    [11114] = {
        ["Coffee"] = true, ["Kaffee"] = true, ["Café"] = true, ["Кофе"] = true, ["コーヒー"] = true, ["Café"] = true, ["咖啡豆"] = true,
    },
}

AutoBanishPets.harvests = {
    [9245] = {},
    [9353] = {
        ["Butterfly"] = true, ["Schmetterling"] = true, ["Papillon"] = true, ["Бабочка"] = true, ["蝶"] = true, ["Mariposa"] = true, ["蝴蝶"] = true,
        ["Torchbug"] = true, ["Fackelkäfer"] = true, ["Flammouche"] = true, ["Светлячок"] = true, ["ホタル"] = true, ["Luciérnaga"] = true, ["流萤虫"] = true,
    },
    [9911] = {},
    [9912] = {},
    [11113] = {},
    [11114] = {
        ["Blue Entoloma"] = true, ["Blauer Glöckling"] = true, ["Entoloma bleue"] = true, ["Голубая знтолома"] = true, ["アオイッポンシメジ"] = true, ["Entoloma azul"] = true, ["蓝草菇"] = true,
        ["Emetic Russula"] = true, ["Brechtäubling"] = true, ["Russule émétique"] = true, ["Жгучеедкая сыроежка"] = true, ["ドクベニタケ"] = true, ["Rúsula emética"] = true, ["臭红菇"] = true,
        ["Imp Stool"] = true, ["Koboldschemel"] = true, ["Pied-de-lutin"] = true, ["Бесовский гриб"] = true, ["木椅子キノコ"] = true, ["Seta de diablillo"] = true, ["小恶魔粪菌"] = true,
        ["Luminous Russula"] = true, ["Leuchttäubling"] = true, ["Russule phosphorescente"] = true, ["Светящаяся сыроежка"] = true, ["光ベニタケ"] = true, ["Rúsula luminosa"] = true, ["发光红菇"] = true,
        ["Namira's Rot"] = true, ["Namiras Fäulnis"] = true, ["Truffe de Namira"] = true, ["Гниль Намиры"] = true, ["ナミラキノコ"] = true, ["Seta de Namira"] = true, ["娜米拉腐菌"] = true,
        ["Stinkhorn"] = true, ["Stinkmorchel"] = true, ["Mutinus elegans"] = true, ["Цветохвостник"] = true, ["スッポンタケ"] = true, ["Falacea"] = true, ["臭角菇"] = true,
        ["Violet Coprinus"] = true, ["Violetter Tintling"] = true, ["Coprin violet"] = true, ["Лиловый копринус"] = true, ["ムラサキヒトヨタケ"] = true, ["Coprinus violeta"] = true, ["紫鬼伞菌"] = true,
        ["White Cap"] = true, ["Weißkappe"] = true, ["Chapeau blanc"] = true, ["Белянка"] = true, ["白かさキノコ"] = true, ["Hongo blanco"] = true, ["白伞菌"] = true,
    },
}

AutoBanishPets.thievesTrove = {
    ["Thieves Trove"] = true, ["Diebesgut^ns"] = true, ["Trésor des voleurs^m"] = true, ["Воровской клад"] = true, ["盗賊の宝"] = true, ["Tesoro de los ladrones"] = true, ["盗贼宝库"] = true,
}
