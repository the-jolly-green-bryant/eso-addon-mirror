-- Custom Badges for the "Hunger Force" Guild (NA)
-- Made by @aquateen for sirinsidiator's addon "Aetherius Badge Filter" - http://www.esoui.com/downloads/info1354-AetheriusBadgeFilter.html
-- Last edited:
-- 05/06/2017
AetheriusBadgeFilter:RegisterGuild(AetheriusBadgeFilter.SERVER_NA, "Hunger Force", {
    {
        name = "Trading",
        description = "Badges that are awarded to members for their economic exploits.",
        badges = {
            {
                name = "Top Trader",
                description = "Has been one of the top 5 sellers of last week. Will be removed after a week.",
                color = "A4A578",
            },
            {
                name = "Merchant",
                description = "Has been responsible for more than 250k gold in sales during a week. Can be awarded multiple times.",
                color = "80A36B",
                limit = 10,
                turnsInto = "Shopkeeper"
            },
            {
                name = "Shopkeeper",
                description = "Has received 10 Merchant badges. Can be awarded multiple times.",
                color = "46A085",
                limit = 10,
                turnsInto = "Tycoon"
            },
            {
                name = "Entrepreneur",
                description = "Has been one of the top 5 sellers in the past. Can be awarded multiple times.",
                color = "74739E",
                limit = 10,
                turnsInto = "Executive"
            },
            {
                name = "Executive",
                description = "Has received 10 Entrepreneur badges. Can be awarded multiple times.",
                color = "996380",
                limit = 10,
                turnsInto = "Tycoon"
            },
            {
                name = "Tycoon",
                description = "Has either received 10 Shopkeeper badges or 10 Executive badges. Can be awarded multiple times.",
                color = "B55A05",
                limit = false,
            },
        }
    },
    {
        name = "Participation",
        description = "Badges that are awarded to members for their activities in the guild.",
        badges = {
            {
                name = "Officer",
                description = "An active officer of Hunger Force. Contact them if you have questions, suggestions, problems, etc.",
                color = "349118",
            },
            {
                name = "Benefactor",
                description = "Has donated more than 25k gold in a week. Can be awarded multiple times.",
                color = "D87C2F",
                limit = false,
            },
            {
                name = "Philanthropist",
                description = "Has helped members of the guild with knowledge, action or coin. Can be awarded multiple times.",
                color = "64BCB3",
                limit = false,
            },
            {
                name = "Discord Regular",
                description = "A badge for players who regularly use discord while ingame.",
                color = "375F7A",
            },
            {
                name = "Participant",
                description = "A badge for players who maintain activity within the guild.",
                color = "6DD374",
                limit = false,
            },
            {
                name = "Open House",
                description = "A badge for players who have their houses available to guildmates.",
                color = "74739E",
            },
        }
    },
    {
        name = "Crafting",
        description = "Badges that identify crafters. To get one for yourself, contact an officer.",
        badges = {
            {
                name = "Master Blacksmith",
                description = "Knows all traits for weapons and heavy armor.",
                color = "375F7A",
            },
            {
                name = "Master Clothier",
                description = "Knows all traits for light and medium armor.",
                color = "A52B5E",
            },
            {
                name = "Master Woodworker",
                description = "Knows all traits for staves and shields.",
                color = "AF6438",
            },
            {
                name = "Master Alchemist",
                description = "Brews potions and poisons.",
                color = "349118",
            },
            {
                name = "Master Enchanter",
                description = "Enchants glyphs.",
                color = "A44DBC",
            },
            {
                name = "Master Provisioner",
                description = "Cooks food and brews drinks.",
                color = "A83E39",
            },
            {
                name = "Aetherial Ambrosia Crafter",
                description = "Can craft Mythic Aetherial Ambrosia.",
                color = "AD8D1B",
            },
            {
                name = "Psijic Ambrosia Crafter",
                description = "Can craft Psijic Ambrosia.",
                color = "AD8D1B",
            },
            {
                name = "Craft House",
                description = "A badge for players who have their houses available to guildmates. Must also have a banker/merchant and all tables available in the house (Attuned excluded).",
                color = "FF0000",
            },
        }
    },
    {
        name = "Bites",
        description = "Badges for Vampires and Werewolves. To get one for yourself, contact an officer.",
        badges = {
            {
                name = "Werewolf",
                description = "Can give you a Werewolf bite.",
                color = "D87F31",
            },
            {
                name = "Vampire",
                description = "Can give you a Vampire bite.",
                color = "D8318D",
            },
        }
    },
    {
        name = "Other",
        description = "Other stuff.",
        badges = {
            {
                name = "Streamer",
                description = "A badge for players who stream. To get one for yourself, contact an officer.",
                color = "3FC6C6",
            },
        }
    },
})
