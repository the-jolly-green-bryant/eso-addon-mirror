-- Custom Badges for the "Black Horse Courier" Guild (PC/EU & NA)
-- Made by @CradonWar for @sirinsidiator's addon "Aetherius Badge Filter" - http://www.esoui.com/downloads/info1354-AetheriusBadgeFilter.html
-- Thanks a lot for all the help and for this awesome addon, @sirinsidiator!
-- Last edited: 31/07/2019
AetheriusBadgeFilter:RegisterGuild(AetheriusBadgeFilter.SERVER_ALL, "Black Horse Courier", {
    {
        name = "|cFDFFBFInfo (Mouseover)|r",
        description = "Welcome to Aetherius Badge Filter of the Black Horse Courier!\n\n|cFDFFBFWhat are Badges?|r\nBadges are simply labels with a color format placed in the notes of a guild member. For example |cFF0000My Badge|r is a badge. Unlike ranks, badges are a lot more transient and versatile as they are not limited in their number. There are some non-ranked badges that you can simply ask to any officer to add into your notes. But you need Ranked Badges to improve your guild rank and get promoted.\n\n|cFDFFBFWhat are Ranked Badges?|r\nRanked Badges determines your improvement to get promoted in the guild. E.g. staying loyal, participating into Guild Events, selling items in Guild Store (when we have a Guild Trader), donating golds into Guild Bank, etc.",
        badges = {
        },
    },
    {
        name = "|cFDFFBFGuild Ranks (Mouseover)|r",
        description = "|cFDFFBF[Legendary]|r\nEarn 100 ranked badges to reach this rank.\n\n|cFDFFBF[Master]|r\nEarn 50 ranked badges to reach this rank.\n\n|cFDFFBF[Expert]|r\nEarn 25 ranked badges to reach this rank.\n\n|cFDFFBF[Adept]|r\nEarn 10 ranked badges to reach this rank.\n\n|cFDFFBF[Apprentice]|r\nEarn 5 ranked badges to reach this rank.\n\n|cFDFFBF[Novice]|r\nWelcome to Black Horse Courier!",
        badges = {
        },
    },
    {
        name = "|cFFD700NEW!|r |cFDFFBFArena Ranks (Mouseover)|r",
        description = "|cFDFFBFArena Ranks|r are given to the |cC64343Fighters|r of the Dueling Tournament. Aside from |cFDFFBFGuild Ranks|r and |cFDFFBFBadges|r, the only purpose is to show your progress in the |cFDFFBFHammerdeath Arena|r.\n\n|cFDFFBF[Pit Dog]|r\nNewest member of the Arena who either applied to the |c0087BDBlue Team|r or the |cFFD300Yellow Team|r.\n\n|cFDFFBF[Brawler]|r\nDefeat 5 combatants to reach this rank.\n\n|cFDFFBF[Bloodletter]|r\nDefeat 10 combatants to reach this rank.\n\n|cFDFFBF[Myrmidon]|r\nDefeat 15 combatants to reach this rank.\n\n|cFDFFBF[Warrior]|r\nDefeat 20 combatants to reach this rank.\n\n|cFDFFBF[Gladiator]|r\nDefeat 25 combatants to reach this rank.\n\n|cFDFFBF[Hero]|r\nDefeat 50 combatants to reach this rank.\n\n|cFDFFBF[Champion]|r\nBecome a |cFDFFBFChampion|r of the |c0087BDBlue Team|r or the |cFFD300Yellow Team|r in the latest tournament.\n|cFDFFBFNOTE:|r This title may lost if another combatant becomes the next Champion.\n\n|cFDFFBF[Grand Champion]|r\nBecome the |c7851A9Grand Champion|r of the arena.\n|cFDFFBFNOTE:|r This title may lost if another Champion becomes the next Grand Champion.",
        badges = {
            {
                name = "Grand Champion",
                description = "Became the |c7851A9Grand Champion|r of the arena.\n\n|cFDFFBFNOTE:|r This title may lost if another Champion becomes the next Grand Champion.",
                color = "7851A9",
            },
            {
                name = "Champion",
                description = "Became the Champion of the |c0087BDBlue Team|r in the latest tournament.\n\n|cFDFFBFNOTE:|r This title may lost if another combatant becomes the next Champion.",
                color = "0087BD",
            },
            {
                name = "Champion ",
                description = "Became the Champion of the |cFFD300Yellow Team|r in the latest tournament.\n\n|cFDFFBFNOTE:|r This title may lost if another combatant becomes the next Champion.",
                color = "FFD300",
            },
        },
    },
    {
        name = "Staff",
        description = "Authorized people who you can contact them if you have questions, suggestions, problems, etc.",
        badges = {
            {
                name = "Guildmaster",
                description = "First Courier(s) of the Black Horse Courier.",
                color = "FFD700",
            },
            {
                name = "Officer",
                description = "An active officer of the Black Horse Courier.",
                color = "FF0000",
            },
        }
    },
    {
        name = "Loyalty Badges",
        description = "Badges that are awarded to member for their loyalty in the guild. These badges will be used as a basis for promotions in the guild.",
        badges = {
            {
                name = "VIP",
                description = "Known members of the guild either who has been in the guild since its foundation or aided the guild or community in a special way. Has a different set of rules applied. You can only get this badge from guildmasters.\n\n|cFDFFBFNOTE: These members may immune to be kicked!|r",
                color = "FFD700",
            },
            {
                name = "Ancient",
                description = "Has been in the guild for more than a year.\nCounts as 4 badges.",
                color = "A19CDE",
            },
            {
                name = "Elder",
                description = "Has been in the guild for more than 200 days.\nCounts as 3 badges.",
                color = "A19CDE",
            },
            {
                name = "Veteran",
                description = "Has been in the guild for more than 100 days.\nCounts as 2 badges.",
                color = "A19CDE",
            },
            {
                name = "Associate",
                description = "Has been in the guild for more than 30 days.",
                color = "A19CDE",
            },
            {
                name = "Recruit",
                description = "Welcome to Black Horse Courier!\n\n|cFDFFBFNOTE: This badge is non-ranked.|r",
                color = "C5C29E",
            },
        }
    },
    {
        name = "Event Badges",
        description = "Badges that are awarded to members for their participation in guild events. These badges will be used as a basis for promotions in the guild. Can be awarded multiple times.",
        badges = {
            {
                name = "Auction",
                description = "Join a guild Auction and win a lot that you bid to earn this badge. Can be awarded multiple times in a single auction.",
                color = "C64343",
                limit = false,
            },
            {
                name = "Undaunted",
                description = "Join a PVE guild event and complete at least one major activity to earn this badge.",
                color = "C64343",
                limit = false,
            },
            {
                name = "Fighter",
                description = "Join a PVP guild event and complete at least one major activity to earn this badge.",
                color = "C64343",
                limit = false,
            },
            {
                name = "Blademaster",
                description = "Join a Dueling Tournament and become the last man standing to earn this badge.\nCounts as 5 badges.|r",
                color = "C64343",
                limit = false,
            },
            {
                name = "Participant",
                description = "Participants of the #Summerfall community event by Zenimax back in October 2018.\nCounts as 5 badges.|r",
                color = "C64343",
                limit = false,
            },
        }
    },
    --    {
    --        name = "Trade Badges",
    --        description = "Badges that are awarded to members for their economic exploits. These badges will be used as a basis for promotions in the guild. Can be awarded once a week.",
    --        badges = {
    --            {
    --                name = "Top Trader",
    --                description = "Has been one of the top 5 sellers when we had a Guild Trader.",
    --                color = "55C855",
    --                limit = 10,
    --                turnsInto = "Entrepreneur"
    --            },
    --            {
    --                name = "Vendor",
    --                description = "Has sold wares for more than 50k gold during a week.",
    --                color = "55C855",
    --                limit = 10,
    --                turnsInto = "Merchant"
    --            },
    --            {
    --                name = "Entrepreneur",
    --                description = "Has received 10 Top Trader badges.\nCounts as 10 badges.",
    --                color = "55C855",
    --                limit = 10,
    --                turnsInto = "Tycoon"
    --            },
    --            {
    --                name = "Merchant",
    --                description = "Has received 10 Vendor badges.\nCounts as 10 badges.",
    --                color = "55C855",
    --                limit = 10,
    --                turnsInto = "Tycoon"
    --            },
    --            {
    --                name = "Tycoon",
    --                description = "Has either received 10 Merchant badges or 10 Entrepreneur badges.\nCounts as 100 badges.",
    --                color = "55C855",
    --                limit = false,
    --            },
    --        }
    --    },
    {
        name = "Donation Badges",
        description = "Badges that are awarded to members for their donations to the guild bank. These badges will be used as a basis for promotions in the guild. Can be awarded multiple times.",
        badges = {
            {
                name = "Subscriber",
                description = "Has donated more than 5k gold.",
                color = "97FFBE",
                limit = 10,
                turnsInto = "Supporter"
            },
            {
                name = "Supporter",
                description = "Has donated more than 50k gold.\nCounts as 10 badges.",
                color = "97FFBE",
                limit = 2,
                turnsInto = "Benefactor"
            },
            {
                name = "Benefactor",
                description = "Has donated more than 100k gold.\nCounts as 20 badges.",
                color = "97FFBE",
                limit = 5,
                turnsInto = "Investor"
            },
            {
                name = "Investor",
                description = "Has donated more than 500k gold.\nCounts as 100 badges.",
                color = "97FFBE",
                limit = 2,
                turnsInto = "Sponsor"
            },
            {
                name = "Sponsor",
                description = "Has donated more than 1m gold.\nCounts as 200 badges.",
                color = "97FFBE",
                limit = false,
            },
        }
    },
    {
        name = "Non-Ranked Badges",
        description = "Badges that identify your qualifications. These badges will NOT be used as a basis for promotions in the guild. To get one for yourself, contact an officer.",
        badges = {
            {
                name = "Master Crafter",
                description = "Can craft any equipments or consumables in any category.",
                color = "2DFFF8",
            },
            {
                name = "Trait Master",
                description = "Can provide research materials.",
                color = "2DFFF8",
            },
            {
                name = "Tank",
                description = "Takes the role of a tank in a dungeon or trial.",
                color = "FD7A1A",
            },
            {
                name = "Healer",
                description = "Takes the role of a healer in a dungeon or trial.",
                color = "FD7A1A",
            },
            {
                name = "Damage Dealer",
                description = "Takes the role of a damage dealer in a dungeon or trial.",
                color = "FD7A1A",
            },
            {
                name = "Vampire",
                description = "Can give you a free Vampire bite.",
                color = "879B7D",
            },
            {
                name = "Werewolf",
                description = "Can give you a free Werewolf bite.",
                color = "879B7D",
            },
        }
    },
    {
        name = "Misc",
        badges = {
            {
                name = "Away",
                description = "Is currently unavailable and will be back at the date specified next to the badge.",
                color = "C5C29E",
            },
            {
                name = "Warning",
                description = "Has broken guild rules and been warned via mail or chat.",
                color = "C5C29E",
                limit = 3,
            },
        },
    },
    {
        name = "|cFDFFBFCredits (Mouseover)|r",
        description = "|cFDFFBFAetherius Badge Filter by|r\n@Arkadius & @sirinsidiator\n\n|cFDFFBFBadges for Black Horse Courier by|r\n@CradonWar\n\nSpecial thanks to @sirinsidiator who helped us to upload data for Black Horse Courier.\n\nThanks for using this addon and being a member of our Guild!\n\n|cFDFFBFBlack Horse Courier - 2019|r",
        badges = {
        },
    },
})
