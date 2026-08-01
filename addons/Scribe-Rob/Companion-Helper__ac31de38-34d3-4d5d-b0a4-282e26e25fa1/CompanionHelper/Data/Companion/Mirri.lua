local CH = CompanionHelper

CH.CompanionData.Companion[2] = {
    name = "Mirri Elendis",
    gender = "Female",
    class = "Nightblade",
    race = "Dark Elf",
    perk = "Mirri's Expertise",
    effect = "Treasure chests found through treasure maps and in the Overland have a 30% chance to provide additional loot from hidden compartments.",
    rapport = {
        {
            task = "Companion Quest",
            change = {
                initial = 500,
            }
        },
        {
            task = "Returning Dark Anchor contract offered by Cardea Gallus in Fighters Guild",
            change = {
                initial = 125
            }
        },
        {
            task = "Returning Numani-Rasi relics daily in Vvardenfell (Ashlander Daily)",
            change = {
                initial = 125
            },
            cooldown = "Resets at 10:00 UTC"
        },
        {
            task = "Mirri commenting Clockwork City while visiting it.",
            change = {
                initial = 10
            },
            cooldown = "Between 24 and 44 hours"
        },
        {
            task = "Enter certain daedric delves and public dungeons, such as Ashalmawia, Broken Tusk, Mehrunes' Spite, Sanguine's Demesne, The Cave of Trophies and The Grotto of Depravity",
            change = {
                initial = 10
            },
            cooldown = "30 minutes"
        },
        {
            task = "Talking to Sotha Sil",
            change = {
                initial = 10
            },
        },
        {
            task = "Fully looting a treasure chest",
            change = {
                initial = 10,
                subsequent = 1,
            },
            cooldown = "60 minutes"
        },
        {
            task = "Excavate an Antiquity",
            change = {
                initial = 5
            },
            cooldown = "5 minutes"
        },
        {
            task = "View a completed Khajiit of the Moons",
            change = {
                initial = 75,
                subsequent = 5,
            },
            cooldown = "20 hours"
        },
        {
            task = "View a completed Library of Vivec",
            change = {
                initial = 75,
                subsequent = 5,
            },
            cooldown = "20 hours"
        },
        {
            task = "View a completed Kari's Hit List",
            change = {
                initial = 75,
                subsequent = 5,
            },
            cooldown = "20 hours"
        },
        {
            task = "View a completed House of Orsimer Glories",
            change = {
                initial = 75,
                subsequent = 5,
            },
            cooldown = "20 hours"
        },
        {
            task = "View a completed Vault of Moawita ",
            change = {
                initial = 75,
                subsequent = 5,
            },
            cooldown = "20 hours"
        },
        {
            task = "View a completed Rithana-di-Renada",
            change = {
                initial = 75,
                subsequent = 5,
            },
            cooldown = "20 hours"
        },
        {
            task = "View a completed Bards College ",
            change = {
                initial = 75,
                subsequent = 5,
            },
            cooldown = "20 hours"
        },
        {
            task = "Kill a goblin",
            change = {
                initial = 1
            },
            cooldown = "5 minutes"
        },
        {
            task = "Kill a riekling",
            change = {
                initial = 1
            },
            cooldown = "5 minutes"
        },
        {
            task = "Kill a snake. Includes passive snakes, giant snakes and others (cooldown shared across all snake types)",
            change = {
                initial = 1
            },
            cooldown = "150 seconds"
        },
        {
            task = "Craft an alcoholic beverage",
            change = {
                initial = 1
            },
            cooldown = "5 minutes"
        },
        {
            task = "Reading a book from a shelf",
            change = {
                initial = 1
            },
            cooldown = ">30 minutes"
        },
        {
            task = "Summoning certain Daedric pets such as the Daemon Chicken and Slate-Skinned Daedrat",
            change = {
                initial = 1
            }
        },
        {
            task = "Use the Blade of Woe, including against enemies",
            change = {
                initial = -25,
                subsequent = -5
            },
            cooldown = "5 minutes"
        },
        {
            task = "Enter the Dark Brotherhood Sanctuary",
            change = {
                initial = -10
            }
        },
        {
            task = "Harvest a torchbug, butterfly or honeybee (cooldown shared)",
            change = {
                initial = -1
            }
        }
    }
}