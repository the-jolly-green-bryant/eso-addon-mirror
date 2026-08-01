local CH = CompanionHelper

CH.CompanionData.Companion[13] = {
    name = "Zerith-var",
    gender = "Male",
    class = "Necromancer",
    race = "Khajit",
    perk = "Zerith's Guidance",
    effect = "Ja'kh uses his keen eyes to point out heavy sacks.",
    rapport = {
        -- Positive
        {
            task = "Completing his companion quests",
            change = { initial = 500 },
            cooldown = "Once per quest",
        },
        {
            task = "Complete Maw of Lorkhaj with Zerith-var present",
            change = { initial = 150 },
            cooldown = "(?)",
        },
        {
            task = "Complete a Defense Force quest offered by Zahari at Grahtwood Northern Gate",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Complete a Tales of Tribute daily quest",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Complete an Antiquity that has multiple pieces (e.g., a Mythic item)",
            change = { initial = 25 },
            cooldown = "(?)",
        },
        {
            task = "Complete a Dark Anchor encounter",
            change = { initial = 10, subsequent = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Kill a Dragon",
            change = { initial = 10, subsequent = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Complete a Tales of Tribute match",
            change = { initial = 10, subsequent = 1 },
            cooldown = "10 minutes (?)",
        },
        {
            task = "Completing The Demon Weapon or The Halls of Colossus",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Kill a Marauder in the Infinite Archive",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Curing yourself of Vampirism",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Drink a Purifying Bloody Mara",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Excavate an Antiquity whose codex is incomplete",
            change = { initial = 10 },
            cooldown = "1 hour",
        },
        {
            task = "Giving to a beggar",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Healing yourself in combat while below 25%",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Visit Baandari Trading Post",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Loot a heavy sack",
            change = { initial = 5 },
            cooldown = "5 hours (?) (maybe 2 hours)",
        },
        {
            task = "Harvest a water node",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Defeat Tho'at Replicanum in the Infinite Archive",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Defeat Aramril in the Infinite Archive",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Kill an undead enemy (Vampire or Skeleton)",
            change = { initial = 1 },
            cooldown = "3 minutes",
        },
        {
            task = "Kill a dro-m'Athra",
            change = { initial = 1 },
            cooldown = "2 minutes",
        },
        {
            task = "Defeat a boss in the Infinite Archive",
            change = { initial = 1 },
            cooldown = "(?)",
        },

        -- Negative
        {
            task = "Completing the Scion of the Blood Matron quest to become a vampire",
            change = { initial = -50 },
            cooldown = "(?)",
        },
        {
            task = "Infecting another player with Vampirism",
            change = { initial = -25 },
            cooldown = "(?)",
        },
        {
            task = "Soultrapping someone with the Soul Trap skill",
            change = { initial = -10 },
            cooldown = "(?)",
        },
        {
            task = "Stealing a medicinal, religious, or sentimental item",
            change = { initial = -5, subsequent = -1 },
            cooldown = "1 hour or relog (?) / no cooldown",
        },
        {
            task = "Using a Counterfeit Pardon Edict or Leniency Edict",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Fencing stolen goods",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Drinking a Corrupting Bloody Mara",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Travelling to the Hollow City in Coldharbour",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Speaking to Cadwell",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Getting a bounty",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Selecting the Dro-m'Athra skin",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Murdering an innocent",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Feeding as a vampire (including on hostile NPCs)",
            change = { initial = -1 },
            cooldown = "(?)",
        },
    },
}