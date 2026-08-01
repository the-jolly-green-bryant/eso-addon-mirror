AetheriusBadgeFilter:RegisterGuild(AetheriusBadgeFilter.SERVER_EU, "Tamriel Stock Exchange", {
    {
        name = "Social",
        badges = {       
            {
                name = "Elder",
                description = "Is since min. 200 days member of the guild.",
            },  
            {
                name = "Veteran",
                description = "Is since min. 100 days member of the guild.",
            }, 
            {
                name = "Donator",
                description = "Donated over 100k.",
            },
            {
                name = "Generous Donator",
                description = "Donated over 250k.",
            },
            {
                name = "Patron",
                description = "Donated over 500k.",
            },  
            {
                name = "Generous Patron",
                description = "Donated over 1kk.",
            },                    
        }
    },
    {
        name = "Trading",
        badges = {
            {
                name = "Aspirant",
                description = "Reached 500k sales/week. Can be awarded multiple times.",
                limit = false,
            },
            {
                name = "Glorious",
                description = "Reached 1kk sales/week. Can be awarded multiple times.",
                limit = false,
            },
            {
                name = "Master Trader",
                description = "Has been Top-Trader in one trading week. Can be awarded multiple times.",
                limit = 10,
                turnsInto = "Trading Monster"
            },
            {
                name = "Trading Monster",
                description = "Has been 10 times Top-Trader. Can be awarded multiple times.",
                limit = false,
            },
        }
    },
    {
        name = "Crafting",
        badges = {
            {
                name = "Master Crafter",
                description = "Mastered Alchemy, Enchanting, Provisioning, Backsmithing, Clothing and Woodworking",
                relations = {"Alchemist", "Provisioner", "Woodworker", "Tailor", "Blacksmith", "Enchanter"},
            },
            {
                name = "Set-Provider",
                description = "Has following Crafting-Stations in his house accessible for everyone in this guild.",
            },
            {
                name = "Alchemist",
                description = "Knows all ingredients and reached lvl 50 in Alchemy",
            },
            {
                name = "Provisioner",
                description = "Knows 90% of all recipes and mastered Provisioning",
            },
            {
                name = "Blacksmith",
                description = "Knows all 9 traits on heavy armor and weapons and reached lvl 50 in Blacksmithing.",
            },
            {
                name = "Tailor",
                description = "Knows all 9 traits on light and medium armor and reached lvl 50 in Clothing.",
            },
            {
                name = "Woodworker",
                description = "Knows all 9 traits on shields and wooden weapons and reached lvl 50 in Woodworking.",
            },
            {
                name = "Enchanter",
                description = "Knows all runes and reached lvl 50 in Enchanting.",
            },
            {
                name = "Karl Lagerfeld",
                description = "Knows all recent crafting styles.",
            },
        }
    },
})
