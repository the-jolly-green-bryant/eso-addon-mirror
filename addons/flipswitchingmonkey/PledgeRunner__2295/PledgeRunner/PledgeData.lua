PledgeRunner = PledgeRunner or {}
local PR = PledgeRunner

-- Undaunted Pledges
PR.ZONEDATA = {
    [380] = {
        zone = 380,
        pledge = 5244,
        numBosses = 5,
        en = {
            zone = "The Banished Cells I",
            pledge = "Pledge: Banished Cells I",
            final = "Return to Maj al-Ragath",
            bosses = {
                "Cell Haunter",
                "Shadowrend",
                "Angata the Clannfear Handler",
                "Skeletal Destroyer",
                "High Kinlord Rilis",
            },
        },
        de = {
            zone = "Verbannungszellen I",
            pledge = "Pledge: Banished Cells I",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Cachot interdit I",
            pledge = "Serment : Cachot interdit I",
            final = "Retournez voir Maj al-Ragath",
        }
    },
    [935] = { 
        zone = 935,
        pledge = 5246,
        numBosses = 7,
        en = {
            zone = "The Banished Cells II",
            pledge = "Pledge: Banished Cells II",
            final = "Return to Maj al-Ragath",
            bosses = {
                "Keeper Areldur",
                "Maw of the Infernal",
                "Keeper Voranil",
                "Keeper Imiril",
                "Sister Sihna",
                "Sister Vera",
                "High Kinlord Rilis",
            },
        },
        de = {
            zone = "Verbannungszellen II",
            pledge = "Gelöbnis: Verbannungszellen II",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
		fr = {
            zone = "Cachot interdit II",
            pledge = "Serment : Cachot interdit II",
            final = "Retournez voir Maj al-Ragath",
        }
    },
    [283] = {
        zone = 283,
        pledge = 5247,
        numBosses = 5,
        en = {
            zone = "Fungal Grotto I",
            final = "Return to Maj al-Ragath",
            pledge = "Pledge: Fungal Grotto I",
        },
        de = {
            zone = "Pilzgrotte I",
            pledge = "Gelöbnis: Pilzgrotte I",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Champignonnière I",
            pledge = "Serment : Champignonnière I",
            final = "Retournez voir Maj al-Ragath",
        }
    },
    [934] = { 
        zone = 934,
        pledge = 5248,
        numBosses = 5,
        en = {
            zone = "Fungal Grotto II",
            pledge = "Pledge: Fungal Grotto II",
            final = "Return to Maj al-Ragath",
            bosses = {
                "Mephala's Fang",
                "Gamyne Bandu",
                "Ciirenas the Shepherd",
                "Spawn of Mephala",
                "Reggr Dark-Dawn",
            },
        },
        de = {
            zone = "Pilzgrotte II",
            pledge = "Gelöbnis: Pilzgrotte II",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Champignonnière II",
            pledge = "Serment : Champignonnière II",
            final = "Retournez voir Maj al-Ragath",
        }
    },
    [144] = { 
        zone = 144,
        pledge = 5260,
        numBosses = 8,
        en = {
            zone = "Spindleclutch I",
            pledge = "Pledge: Spindleclutch I",
            final = "Return to Maj al-Ragath",
        },
        de = {
            zone = "Spindeltiefen I",
            pledge = "Gelöbnis: Spindeltiefen I",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Tressefuseau I",
            pledge = "Serment : Tressefuseau I",
            final = "Retournez voir Maj al-Ragath",
        }
    },
    [936] = {
        zone = 936,
        pledge = 5273,
        numBosses = 8,
        en = {
            zone = "Spindleclutch II",
            pledge = "Pledge: Spindleclutch II",
            final = "Return to Maj al-Ragath",
            bosses = {
                "Mad Mortine",
                "Blood Spawn",
                "Praxin Douare",
                "Flesh Atronach",
                "Flesh Atronach",
                "Flesh Atronach",
                "Urvan Veleth",
                "Vorenor Winterbourne",
                },
        },
        de = {
            zone = "Spindeltiefen II",
            pledge = "Gelöbnis: Spindeltiefen II",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Tressefuseau II",
            pledge = "Serment : Tressefuseau II",
            final = "Retournez voir Maj al-Ragath",
        },
    },
    [63] = {
        zone = 63,
        pledge = 5274,
        numBosses = 6,
        en = {
            zone = "Darkshade Caverns I",
            pledge = "Pledge: Darkshade Caverns I",
            final = "Return to Maj al-Ragath",
        },
        de = {
            zone = "Dunkelschattenkavernen I",
            pledge = "Gelöbnis: Dunkelschattenkavernen I",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Cavernes d'Ombre-noire I",
            pledge = "Serment : Cavernes d'Ombre-noire I",
            final = "Retournez voir Maj al-Ragath",
        },
    },
    [930] = {
        zone = 930,
        pledge = 5275,
        en = {
            zone = "Darkshade II",
            pledge = "Pledge: Darkshade II",
            final = "Return to Maj al-Ragath",
            
        },
        de = {
            zone = "Dunkelschattenkavernen II",
            pledge = "Gelöbnis: Dunkelschattenkavernen II",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Cavernes d'Ombre-noire II",
            pledge = "Serment : Cavernes d'Ombre-noire II",
            final = "Retournez voir Maj al-Ragath",
        },
    },
    [126] = {
        zone = 126,
        pledge = 5276,
        en = {
            zone = "Elden Hollow I",
            pledge = "Pledge: Elden Hollow I",
            final = "Return to Maj al-Ragath",
        },
        de = {
            zone = "Eldengrund I",
            pledge = "Gelöbnis: Eldengrund I",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Creuset des aînés I",
            pledge = "Serment : Creuset des aînés I",
            final = "Retournez voir Maj al-Ragath",
        },
    },
    [931] = {
        zone = 931,
        pledge = 5277,
        numBosses = 6,
        en = {
            zone = "Elden Hollow II",
            pledge = "Pledge: Elden Hollow II",
            final = "Return to Maj al-Ragath",
        },
        de = {
            zone = "Eldengrund II",
            pledge = "Gelöbnis: Eldengrund II",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Creuset des aînés II",
            pledge = "Serment : Creuset des aînés II",
            final = "Retournez voir Maj al-Ragath",
        },
    },
    [146] = {
        zone = 146,
        pledge = 5278,
        numBosses = 5,
        en = {
            zone = "Wayrest Sewers I",
            pledge = "Pledge: Wayrest Sewers I",
            final = "Return to Maj al-Ragath",
            bosses = {
                        "Slimecraw",
                        "Investigator Garron",
                        "The Rat Whisperer",
                        "Uulgarg the Hungry",
                        "Varaine Pellingare",
            },
        },
        de = {
            zone = "Kanalisation von Wegesruh I",
            pledge = "Gelöbnis: Kanalisation von Wegesruh I",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Égouts d'Haltevoie I",
            pledge = "Serment : Égouts d'Haltevoie I",
            final = "Retournez voir Maj al-Ragath",
        },
    },
    [933] = {
        zone = 933,
        pledge = 5282,
        en = {
            zone = "Wayrest Sewers II",
            pledge = "Pledge: Wayrest Sewers II",
            final = "Return to Maj al-Ragath",
        },
        de = {
            zone = "Kanalisation von Wegesruh II",
            pledge = "Gelöbnis: Kanalisation von Wegesruh II",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Égouts d'Haltevoie II",
            pledge = "Serment : Égouts d'Haltevoie II",
            final = "Retournez voir Maj al-Ragath",
        },
    },
    [130] = {
        zone = 130,
        pledge = 5283,
        numBosses = 7,
        en = {
            zone = "Crypt of Hearts I",
            pledge = "Pledge: Crypt of Hearts I",
            final = "Return to Maj al-Ragath",
        },
        de = {
            zone = "Krypta der Herzen I",
            pledge = "Gelöbnis: Krypta der Herzen I",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Crypte des cœurs I",
            pledge = "Serment : Crypte des cœurs I",
            final = "Retournez voir Maj al-Ragath",
        },
    },
    [932] = {
        zone = 932,
        pledge = 5283,
        numBosses = 6,
        en = {
            zone = "Crypt of Hearts II",
            pledge = "Pledge: Crypt of Hearts II",
            final = "Return to Maj al-Ragath",
            bosses = {
                "Ibelgast",
                "Ruzozuzalpamaz",
                "Ilambris-Athor",
                "Ilambris-Zaven",
                "Ilambris Amalgam",
                "Mezeluth",
            },
        },
        de = {
            zone = "Krypta der Herzen II",
            pledge = "Gelöbnis: Krypta der Herzen II",
            final = "Kehrt zu Maj al-Ragath zurück",
        },
        fr = {
            zone = "Crypte des cœurs II",
            pledge = "Serment : Crypte des cœurs II",
            final = "Retournez voir Maj al-Ragath",
        },
    },
    [148] = {
        zone = 148,
        pledge = 5288,
        en = {
            zone = "Arx Corinium",
            pledge = "Pledge: Arx Corinium",
            final = "Return to Glirion the Redbeard",
        },
        de = {
            zone = "Arx Corinium",
            pledge = "Gelöbnis: Arx Corinium",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Arx Corinium",
            pledge = "Serment : Arx Corinium",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [176] = {
        zone = 176,
        pledge = 5290,
        numBosses = 6,
        en = {
            zone = "City of Ash I",
            pledge = "Pledge: City of Ash I",
            final = "Return to Glirion the Redbeard",
        },
        de = {
            zone = "Stadt der Asche I",
            pledge = "Gelöbnis: Stadt der Asche I",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Cité des cendres I",
            pledge = "Serment : Cité des cendres I",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [449] = {
        zone = 449,
        pledge = 5291,
        numBosses = 5,
        en = {
            zone = "Direfrost Keep I",
            pledge = "Pledge: Direfrost Keep I",
            final = "Return to Glirion the Redbeard",
            bosses = {
                "Teethnasher the Frostbound",
                "Guardian of the Flame",
                "Drodda's Dreadlord",
                "Iceheart",
                "Drodda of Icereach",
            },
        },
        de = {
            zone = "Burg Grauenfrost I",
            pledge = "Gelöbnis: Burg Grauenfrost I",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Donjon d'Affregivre I",
            pledge = "Serment : Donjon d'Affregivre I",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [131] = {
        zone = 131,
        pledge = 5301,
        numBosses = 6,
        en = {
            zone = "Tempest Island",
            pledge = "Pledge: Tempest Island",
            final = "Return to Glirion the Redbeard",
            bosses = {
                "Sonolia the Matriarch",
                "Valaran Stormcaller",
                "Yalorasse the Speaker",
                "Stormfist",
                "Commodore Ohmanil",
                "Stormreeve Neidir",
            },
        },
        de = {
            zone = "Orkaninsel",
            pledge = "Gelöbnis: Orkaninsel",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Île des Tempêtes",
            pledge = "Serment : Île des Tempêtes",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [22] = {
        zone = 22,
        pledge = 5303,
        numBosses = 9,
        en = {
            zone = "Volenfell",
            pledge = "Pledge: Volenfell",
            final = "Return to Glirion the Redbeard",
        },
        de = {
            zone = "Volenfell",
            pledge = "Gelöbnis: Volenfell",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Volenfell",
            pledge = "Serment : Volenfell",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [38] = {
        zone = 38,
        pledge = 5305,
        en = {
            zone = "Blackheart Haven",
            pledge = "Pledge: Blackheart Haven",
            final = "Return to Glirion the Redbeard",
        },
        de = {
            zone = "Schwarzherz-Unterschlupf",
            pledge = "Gelöbnis: Schwarzherz-Unterschlupf",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Havre de Cœurnoir",
            pledge = "Serment : Havre de Cœurnoir",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [64] = {
        zone = 64,
        pledge = 5306,
        en = {
            zone = "Blessed Crucible I",
            pledge = "Pledge: Blessed Crucible I",
            final = "Return to Glirion the Redbeard",
        },
        de = {
            zone = "Gesegnete Feuerprobe I",
            pledge = "Gelöbnis: Gesegnete Feuerprobe I",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Creuset béni I",
            pledge = "Serment : Creuset béni I",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [31] = {
        zone = 31,
        pledge = 5307,
        en = {
            zone = "Selene's Web",
            pledge = "Pledge: Selene's Web",
            final = "Return to Glirion the Redbeard",
        },
        de = {
            zone = "Selenes Netz",
            pledge = "Gelöbnis: Selenes Netz",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Toile de Sélène",
            pledge = "Serment : Toile de Sélène",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [11] = {
        zone = 11,
        pledge = 5309,
        numBosses = 8,
        en = {
            zone = "Vaults of Madness",
            pledge = "Pledge: Vaults of Madness",
            final = "Return to Glirion the Redbeard",
            bosses = {
                "The Cursed One",
                "Ulguna Soul-Reaver",
                "Death's Head",
                "Grothdarr",
                "Achaeraizur",
                "The Ancient One",
                "Iskra the Omen",
                "Mad Architect"
            },
        },
        de = {
            zone = "Kammern des Wahnsinns",
            pledge = "Gelöbnis: Kammern des Wahnsinns",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Chambres de la folie",
            pledge = "Serment : Chambres de la folie",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [681] = {
        zone = 681,
        pledge = 5381,
        numBosses = 11,
        en = {
            zone = "City of Ash II",
            pledge = "Pledge: City of Ash II",
            final = "Return to Glirion the Redbeard",
            bosses = {
                "Akezel",
                "Marruz",
                "Rukhan",
                "Urata the Legion",
                "Urata the Legion",
                "Urata the Legion",
                "Horvantud the Fire Maw",
                "Ash Titan",
                "Xivilai Boltaic",
                "Xivilai Fulminator",
                "Valkyn Skoria",
            },
        },
        de = {
            zone = "Stadt der Asche II",
            pledge = "Gelöbnis: Stadt der Asche II",
            final = "Kehrt zu Glirion dem Rotbart zurück",
        },
        fr = {
            zone = "Cité des cendres II",
            pledge = "Serment : Cité des cendres II",
            final = "Retournez voir Glirion Barbe-Rousse"
        },
    },
    [678] = {
        zone = 678,
        pledge = 5382,
        en = {
            zone = "Imperial City Prison",
            pledge = "Pledge: Imperial City Prison",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Gefängnis der Kaiserstadt",
            pledge = "Gelöbnis: Gefängnis der Kaiserstadt",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Prison de la cité impériale",
            pledge = "Serment : Prison de la cité impériale",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [688] = {
        zone = 688,
        pledge = 5431,
        en = {
            zone = "White-Gold Tower",
            pledge = "Pledge: White-Gold Tower",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Weißgoldturm",
            pledge = "Gelöbnis: Weißgoldturm",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Tour d'or blanc",
            pledge = "Serment : Tour d'or blanc",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [843] = {
        zone = 843,
        pledge = 5636,
        en = {
            zone = "Ruins of Mazzatun",
            pledge = "Pledge: Ruins of Mazzatun",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Ruinen von Mazzatun",
            pledge = "Gelöbnis: Ruinen von Mazzatun",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Ruines de Mazzatun",
            pledge = "Serment : Ruines de Mazzatun",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [848] = {
        zone = 848,
        pledge = 5780,
        numBosses = 4,
        en = {
            zone = "Cradle of Shadows",
            pledge = "Pledge: Cradle of Shadows",
            final = "Return to Urgarlag Chief-bane",
            bosses = {
                "Khephidaen",
                "Votary of Velidreth",
                "Dranos Velador",
                "Velidreth",
            },
        },
        de = {
            zone = "Wiege der Schatten",
            pledge = "Gelöbnis: Wiege der Schatten",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Berceau des ombres",
            pledge = "Serment : Berceau des ombres",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [973] = {
        zone = 973,
        pledge = 6053,
        en = {
            zone = "Bloodroot Forge",
            pledge = "Pledge: Bloodroot Forge",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Blutquellschmiede",
            pledge = "Gelöbnis: Blutquellschmiede",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Forge de Sangracine",
            pledge = "Serment : Forge de Sangracine",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [974] = {
        zone = 974,
        pledge = 6054,
        numBosses = 5,
        en = {
            zone = "Falkreath Hold",
            pledge = "Pledge: Falkreath Hold",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Falkenring",
            pledge = "Gelöbnis: Falkenring",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Forteresse d'Épervine",
            pledge = "Serment : Forteresse d'Épervine",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [1010] = {
        zone = 1010,
        pledge = 6154,
        numBosses = 6,
        en = {
            zone = "Scalecaller Peak",
            pledge = "Pledge: Scalecaller Peak",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Gipfel der Schuppenruferin",
            pledge = "Gelöbnis: Gipfel der Schuppenruferin",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Pic de la Mandécailles",
            pledge = "Serment : Pic de la Mandécailles",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [1009] = {
        zone = 1009,
        pledge = 6155,
        numBosses = 8,
        en = {
            zone = "Fang Lair",
            pledge = "Pledge: Fang Lair",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Krallenhort",
            pledge = "Gelöbnis: Krallenhort",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Repaire du croc",
            pledge = "Serment : Repaire du croc",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [1052] = {
        zone = 1052,
        pledge = 6187,
        en = {
            zone = "Moon Hunter Keep",
            pledge = "Pledge: Moon Hunter Keep",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Mondjägerfeste",
            pledge = "Gelöbnis: Mondjägerfeste",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Fort du Chasseur lunaire",
            pledge = "Serment : Fort du Chasseur lunaire",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [1081] = {
        zone = 1081,
        pledge = 6252,
        numBosses = 5,
        en = {
            zone = "Depths of Malatar",
            pledge = "Pledge: Depths of Malatar",
            final = "Return to Urgarlag Chief-bane",
            bosses = {
                "The Scavenging Maw",
                "The Weeping Woman",
                "Dark Orb",
                "King Narilmor",
                "Symphony of Blades",
                },
        },
        de = {
            zone = "Tiefen von Malatar",
            pledge = "Gelöbnis: Tiefen von Malatar",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
            bosses = {
                "Der Raubschlund",
                "Die Trauernde",
                "Dunkle Sphäre",
                "König Narilmor",
                "Die Sinfonie der Klingen",
                },
        },
        fr = {
            zone = "Les Profondeurs de Malatar",
            pledge = "Serment : Les Profondeurs de Malatar",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [1055] = {
        zone = 1055,
        pledge = 6189,
        en = {
            zone = "March of Sacrifices",
            pledge = "Pledge: March of Sacrifices",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Marsch der Aufopferung",
            pledge = "Gelöbnis: Marsch der Aufopferung",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Procession des Sacrifiés",
            pledge = "Serment : Procession des Sacrifiés",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
    [1080] = {
        zone = 1080,
        pledge = 9999999,
        numBosses = 5,
        en = {
            zone = "Frostvault",
            pledge = "Pledge: Frostvault",
            final = "Return to Urgarlag Chief-bane",
        },
        de = {
            zone = "Frostgewölbe",
            pledge = "Gelöbnis: Frostgewölbe",
            final = "Kehrt zu Urgarlag Häuptlingsfluch zurück",
        },
        fr = {
            zone = "Arquegivre",
            pledge = "Serment : Arquegivre",
            final = "Retournez voir Urgalarg l'Émasculatrice"
        },
    },
}

function PR.GetZoneDataByName(zoneName)
    if zoneName == nil then return nil end
    for id, data in pairs(PR.ZONEDATA) do
        if data[PR.locale]["zone"] == zoneName or data["en"]["zone"] then
            return data
        end
    end
    return nil
end
