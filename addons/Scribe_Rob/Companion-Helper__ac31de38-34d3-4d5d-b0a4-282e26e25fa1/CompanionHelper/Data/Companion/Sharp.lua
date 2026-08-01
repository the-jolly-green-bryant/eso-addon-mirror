local CH = CompanionHelper

CH.CompanionData.Companion[8] = {
    name = "Sharp-as-night",
    gender = "Male",
    class = "Warden",
    race = "Argonian",
    perk = "Sharp's Patience",
    effect = "Fish bite at an increased rate and have a higher chance of being trophy fish. Note that this does not reduce your chance to hook special items.",
    rapport = {
        {
            task = "Returning Between a Rock and a Whetstone, Dim and Distant Pasts, and Light the Way to Freedom companion quests",
            change = { initial = 500 },
            cooldown = "Once each",
        },
        {
            task = "Returning Daily Boss quest offered by Ordinator Nelyn in Necrom",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Completing an Ashlander daily quest offered by Huntmaster Sorim-Nakar or Numani-Rasi in Vvardenfell (only one or the other, not both)",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Obtain monster trophy",
            change = { initial = 10 },
            cooldown = "10 minutes",
        },
        {
            task = "Visiting the Hist tree sapling in Ebonheart, Hatching Pools, Haj Uxith or Bright-Throat Village",
            change = { initial = 10 },
            cooldown = "10 minutes",
        },
        {
            task = "Talking to M'aiq the Liar",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Eat a meal",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Craft a poison",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Find Treasure Map Chest",
            change = { initial = 5, subsequent = 1 },
            cooldown = "No cooldown",
        },
        {
            task = "Find Heavy Sack",
            change = { initial = 5, subsequent = 1 },
            cooldown = "No cooldown",
        },
        {
            task = "Catch a rare fish (green or better)",
            change = { initial = 5, subsequent = 1 },
            cooldown = "1 hour / no cooldown",
        },
        {
            task = "Kill a Ghost",
            change = { initial = 1 },
            cooldown = "5 minutes",
        },
        {
            task = "Kill a Fabricant or Dwarven Construct",
            change = { initial = 1 },
            cooldown = "5 minutes",
        },
        {
            task = "Repair gear (can be done at a merchant as well as repair kit)",
            change = { initial = 1 },
            cooldown = "Daily",
        },
        {
            task = "Recharge weapon with Soul Gem",
            change = { initial = 1 },
            cooldown = "(?)",
        },
        {
            task = "Travel via Wayshrine",
            change = { initial = 1 },
            cooldown = "(?) (verification needed)",
        },
        {
            task = "Using soul gem to resurrect someone",
            change = { initial = 1 },
            cooldown = "(?)",
        },
        {
            task = "Go fishing",
            change = { initial = 1 },
            cooldown = "10 minutes (verification needed)",
        },
        {
            task = "Harvest any (flower, mushroom, water or apothecary satchel) alchemy node",
            change = { initial = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Pay a bounty to a guard",
            change = { initial = -10 },
            cooldown = "(?)",
        },
        {
            task = "Destroy item or multiple items of the same type at once in inventory worth over 20 gold",
            change = { initial = -5 },
            cooldown = ">5 minutes",
        },
        {
            task = "Pickpocket a beggar, laborer, or fisher",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Let your gear break",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Use an outfitting station (rapport decreases even if the outfit is not changed)",
            change = { initial = -1 },
            cooldown = "(?)",
        },
    },
}