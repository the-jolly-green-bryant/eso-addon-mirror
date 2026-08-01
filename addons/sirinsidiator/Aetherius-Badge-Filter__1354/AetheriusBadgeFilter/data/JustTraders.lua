AetheriusBadgeFilter:RegisterGuild(AetheriusBadgeFilter.SERVER_EU, "Just Traders", {
    {
        name = "Social",
        badges = {
            {
                name = "Elder",
                description = "Is since min. 200 days member of the guild.",
                color = "9833ff",
            },
            {
                name = "Veteran",
                description = "Is since min. 100 days member of the guild.",
                color = "d933ff",
            },
            {
                name = "Set-Provider",
                description = "Has following Crafting-Stations in his house accessible for everyone in this guild.",
                color = "ffdd00",
            },
            {
                name = "Donator",
                description = "Donated over 100k.",
                color = "baff98",
            },
            {
                name = "Generous Donator",
                description = "Donated over 250k.",
                color = "3fff55",
            },
            {
                name = "Patron",
                description = "Donated over 500k.",
                color = "0dd324",
            },
            {
                name = "Generous Patron",
                description = "Donated over 1kk.",
                color = "ff002a",
            },
        }
    },
    {
        name = "Trading",
        badges = {
            {
                name = "Aspirant",
                description = "Reached 500k sales/week. Can be awarded multiple times.",
                color = "ff7700",
                limit = false,
            },
            {
                name = "Glorious",
                description = "Reached 1kk sales/week. Can be awarded multiple times.",
                color = "00f8e9",
                limit = 10,
                turnsInto = "Premium Trader"
            },
            {
                name = "Premium Trader",
                description = "Reached 1kk sales/week 10 times.",
                color = "99fffa",
                limit = false,
            },
            {
                name = "Master Trader",
                description = "Has been Top-Trader in one trading week. Can be awarded multiple times.",
                color = "ff00e0",
                limit = 10,
                turnsInto = "Trading Monster"
            },
            {
                name = "Trading Monster",
                description = "Has been 10 times Top-Trader. Can be awarded multiple times.",
                color = "f00683",
                limit = false,
            },
        }
    },
    {
        name = "Misc",
        badges = {
            {
                name = "Away",
                color = "200ce0",
                description = "Won't be online for a while.",
            },
            {
                name = "Inbox FULL",
                color = "f49db4",
                description = "Can't receive any mails.",
            },
            {
                name = "Taxback Pending",
                color = "e77ecd",
                description = "Has not received his taxes back yet.",
            },
        }
    },
})
