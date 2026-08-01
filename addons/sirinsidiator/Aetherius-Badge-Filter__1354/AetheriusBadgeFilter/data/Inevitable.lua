AetheriusBadgeFilter:RegisterGuild(AetheriusBadgeFilter.SERVER_EU, "Inevitable", {
    {
        name = "Trading",
        badges = {
            {
                name = "Dealer",
                description = "Reached 300k sales/week (Can be awarded multiple times)",
                color = "fab2b2",
                limit = false,
            },
            {
                name = "Merchant",
                description = "Reached 500k sales/week (Can be awarded multiple times)",
                color = "f66b6b",
                limit = false,
            },
            {
                name = "Businessman",
                description = "Reached 1M sales/week (Can be awarded multiple times)",
                color = "f91111",
                limit = false,
            },
            {
                name = "Top Seller",
                description = "Has been top seller in one week (Can be awarded multiple times)",
                color = "fa35e0",
                limit = 10,
                turnsInto = "Tycoon"
            },
            {
                name = "Tycoon",
                description = "Has been top seller 10 times (Can be awarded multiple times)",
                color = "bf02fa",
                limit = false,
            },
        }
    },
    {
        name = "Donations",
        badges = {
            {
                name = "Supporter",
                description = "Has donated 20k at once (Can be awarded multiple times)",
                color = "87f38a",
                limit = false,
            },
            {
                name = "Donor",
                description = "Has donated 50k at once (Can be awarded multiple times)",
                color = "0ab30f",
                limit = false,
            },
            {
                name = "Contributor",
                description = "Has donated 100k at once (Can be awarded multiple times)",
                color = "035e06",
                limit = false,
            },
            {
                name = "Major Contributor",
                description = "Has donated more than 1m in total",
                color = "00fcea",
            },
        }
    },
    {
        name = "General",
        badges = {
            {
                name = "PVE",
                description = "Organises PVE events (trials, dungeons, etc)",
                color = "14a481",
            },
            {
                name = "PVP",
                description = "Organises PVP events (raids, battlegrounds, etc)",
                color = "007c5d",
            },
            {
                name = "Vampire",
                description = "Giving free vampire bites to guild members",
                color = "bfa1f9",
            },
            {
                name = "Werewolf",
                description = "Giving free werewolf bites to guild members",
                color = "9173ca",
            },
        }
    },
    {
        name = "Misc",
        badges = {
            {
                name = "Away",
                description = "Away until specified date",
                color = "1957fe",
            },
            {
                name = "Inbox Full",
                description = "Cannot receive any mails",
                color = "777906",
            },
            {
                name = "Status:Offline",
                description = "Has status set to offline - recommended to put it to online a.s.a.p.",
                color = "737274",
            },
            {
                name = "TaxBack pending",
                description = "Didnt recive his reward because of full inbox",
                color = "ffffcc",
            },
        }
    },
})
