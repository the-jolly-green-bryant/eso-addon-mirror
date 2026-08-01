local CH = CompanionHelper

CH.CompanionData.Companion[5] = {
    name = "Ember",
    gender = "Female",
    class = "Sorcerer",
    race = "Khajit",
    perk = "Ember's Intuition",
    effect = "When pickpocketing, bestows a chance to acquire hidden wallets your mark hoped to keep secure. Hidden wallets may contain additional gold.",
    rapport = {
        {
            task = "Returning Cold Trail, Cold Blood, Old Pain, or Green with Envy companion quests",
            change = { initial = 500 },
            cooldown = "Once each",
        },
        {
            task = "Returning a Thieves Guild heist with or without the time bonus",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Returning a relic-retrieving quest offered by Alvur Baren in a Mages Guild",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Returning a delve quest offered by Wayllod in High Isle",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Fence a purple-quality stolen item",
            change = { initial = 25, subsequent = 5 },
            cooldown = "24 hours",
        },
        {
            task = "Win a game of Tales of Tribute",
            change = { initial = 10, subsequent = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Begin a Black Sacrament",
            change = { initial = 10, subsequent = 1 },
            cooldown = "24 hours",
        },
        {
            task = "Pickpocket a guard",
            change = { initial = 10, subsequent = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Using clemency",
            change = { initial = 10 },
            cooldown = "24 hours",
        },
        {
            task = "Loot a Thieves Trove or safebox",
            change = { initial = 5, subsequent = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Using a Counterfeit Pardon Edict",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Returning a Thieves Guild job from a Tip Board",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Visit an outlaws refuge or the Thieves Guild Den",
            change = { initial = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Harvest a runestone",
            change = { initial = 1 },
            cooldown = "5 minutes",
        },
        {
            task = "Kill a werewolf",
            change = { initial = 1 },
            cooldown = "5 minutes",
        },
        {
            task = "Kill a wolf",
            change = { initial = 1 },
            cooldown = "5 minutes",
        },
        {
            task = "Summon the Big-Eared Ginger Kitten pet",
            change = { initial = 1 },
            cooldown = "24 hours",
        },
        {
            task = "Summon the Witch's Infernal Familiar pet",
            change = { initial = 1 },
            cooldown = "24 hours",
        },
        {
            task = "Sell a purple-quality item to a vendor",
            change = { initial = 1 },
            cooldown = "(?)",
        },
        {
            task = "Successfully flee from the guard",
            change = { initial = 1 },
            cooldown = "(?)",
        },
        {
            task = "Trespass a restricted area",
            change = { initial = 1 },
            cooldown = "(?)",
        },
        {
            task = "Pay a bounty to a guard after being caught",
            change = { initial = -25, subsequent = -5 },
            cooldown = "1 hour",
        },
        {
            task = "Get caught committing a crime",
            change = { initial = -10 },
            cooldown = "5 minutes",
        },
        {
            task = "Get spotted while trespassing in a restricted area",
            change = { initial = -10 },
            cooldown = "(?)",
        },
        {
            task = "Entering The Halls of Colossus",
            change = { initial = -10 },
            cooldown = "(?)",
        },
        {
            task = "Start fishing",
            change = { initial = -5, subsequent = -1 },
            cooldown = "5 minutes",
        },
    },
}