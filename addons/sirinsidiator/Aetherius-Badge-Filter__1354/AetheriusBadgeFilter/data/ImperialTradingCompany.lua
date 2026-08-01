AetheriusBadgeFilter:RegisterGuild(AetheriusBadgeFilter.SERVER_EU, "Imperial Trading Company", {
    {
        name = "Trading",
        description = "Badges that are awarded to members for their economic exploits. These badges will be used as a basis for promotions to a higher rank",
        badges = {
            {
                name = "Vendor",
                description = "Has sold wares for more than 1M gold during a week. Can be awarded multiple times",
                color = "80A36B",
                limit = 5,
                turnsInto = "Shopkeeper"
            },
            {
                name = "Shopkeeper",
                description = "Has received 5 Vendor badges. Can be awarded multiple times",
                color = "46A085",
                limit = 5,
                turnsInto = "Tycoon"
            },
            {
                name = "Entrepreneur",
                description = "Has been one of the top 10 sellers during a week. Can be awarded multiple times",
                color = "74739E",
                limit = 5,
                turnsInto = "Executive"
            },
            {
                name = "Executive",
                description = "Has received 5 Entrepreneur badges. Can be awarded multiple times",
                color = "996380",
                limit = 5,
                turnsInto = "Tycoon"
            },
            {
                name = "Tycoon",
                description = "Has either received 5 Shopkeeper or 5 Executive badges. Can be awarded multiple times",
                color = "B55A05",
                limit = false,
            },
        }
    },
    {
        name = "Participation",
        description = "Badges that are awarded to members for their activities in the guild. Some of these badges will be used as a basis for promotions, others will earn you much appreciation",
        badges = {
            {
                name = "Benefactor",
                description = "Has donated more than 50k gold in a single week. Can be awarded multiple times",
                color = "D87C2F",
                limit = false,
            },
            {
                name = "Investor",
                description = "Has donated a cumulative sum of 1M gold over time. Can be awarded multiple times",
                color = "AD8D1B",
                limit = false,
            },
            {
                name = "Participant",
                description = "Has participated in an event or helped guild members in some notable way. Members are welcome to inform officers about those acts. Can be awarded multiple times",
                color = "6DD374",
                limit = false,
            },
            {
                name = "Associate",
                description = "Has joined our discord server at |c3ABAFFhttps://discord.gg/bpsDzmE|r",
                color = "A37AD6",
            },
        }
    },
    {
        name = "Services",
        description = "Badges that identify services offered by guild members, either for free or for a commissions. To get one for yourself, contact an officer",
        badges = {
            {
                name = "Artisan",
                description = "Can craft items for coin. Message them for details",
                color = "AD8D1B",
            },
            {
                name = "Trait Master",
                description = "Can provide research materials. Message them for details",
                color = "3FC6C6",
            },
            {
                name = "Werewolf",
                description = "Can give you a free Werewolf bite",
                color = "D87F31",
            },
            {
                name = "Vampire",
                description = "Can give you a free Vampire bite",
                color = "D8318D",
            },
        }
    },
    {
        name = "Organisational",
        description = "Badges used to keep track of various things related to the management of the guild",
        badges = {
            {
                name = "Officer",
                description = "An active officer of the Imperial Trading Company. Contact them if you have questions, suggestions, problems, etc.",
                color = "349118",
            },
            {
                name = "Away",
                description = "Benefactor Badges can be traded in for Away Badges. Every week that goes beyond the inactivity limit will consume one Away badge. Once they are gone, you will be kicked for inactivity. The sales requirement will also be suspended during that time",
                color = "AAAAAA",
                limit = false,
            },
            {
                name = "Warned",
                description = "Has not met the 15k minimum sales per month (= 4 trading weeks) and is at risk of being kicked at the beginning of the next trading week",
                color = "FF0000",
                limit = 3,
            },
        },
    },
})
