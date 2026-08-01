local CH = CompanionHelper

CH.CompanionData.Companion[1] = {
    name = "Bastian Hallix",
    gender = "Male",
    class = "Dragonknight",
    race = "Imperial",
    perk = "Bastian's Insight",
    effect = "Potions looted from monsters have a 30% chance to be improved by Bastian's Insight.",
    rapport = {
        {
            task = "Complete Things Lost, Things Found and Family Secrets companion quests",
            change = { initial = 500 },
            cooldown = "Once each",
        },
        {
            task = "Complete a Mages Guild daily offered by Alvur Baren",
            change = { initial = 125 },
            cooldown = "0",
        },
        {
            task = "Visit or pass by a Mages Guild guildhall within Alliance zones",
            change = { initial = 10 },
            cooldown = "20 hours",
        },
        {
            task = "Visit Artaeum via portal in Keep of the Eleven Forces, the Grand Psijic Villa, quest specific zone, by stepping one meter away from the wayshrine, or Eyevea (cooldown shared across both)",
            change = { initial = 10 },
            cooldown = "20 hours",
        },
        {
            task = "Complete random Encounters that help people (e.g., rescuing merchants from bandits, summoners from Daedra, travelers during Ambushes)",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Scry an Antiquity",
            change = { initial = 5 },
            cooldown = "5 minutes",
        },
        {
            task = "Loot a Psijic portal",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Kill a Worm Cultist at the start of a Dark Anchor",
            change = { initial = 5 },
            cooldown = "5-10 minutes (?)",
        },
        {
            task = "Kill any Cultist",
            change = { initial = 1 },
            cooldown = "1 minute",
        },
        {
            task = "Kill bandits anywhere",
            change = { initial = 1 },
            cooldown = "1 minute",
        },
        {
            task = "Read a book",
            change = { initial = 1 },
            cooldown = "15 minutes",
        },
        {
            task = "Murder",
            change = { initial = -25 },
            cooldown = "(?)",
        },
        {
            task = "Attacking innocents",
            change = { initial = -10 },
            cooldown = "(?)",
        },
        {
            task = "Getting caught stealing or pickpocketing",
            change = { initial = -10 },
            cooldown = "(?)",
        },
        {
            task = "Killing livestock",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Stealing",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Pickpocketing",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Cooking food with cheese",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Attempting to flee from guards",
            change = { initial = -1 },
            cooldown = "(?)",
        },
    },
}