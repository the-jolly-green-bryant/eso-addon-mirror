local CH = CompanionHelper

CH.CompanionData.Companion[6] = {
    name = "Isobel Veloise",
    gender = "Female",
    class = "Templar",
    race = "Breton",
    perk = "Isobel's Grace",
    effect = "Bestows a chance, after defeating a world boss, to recover the pack of a slain knight. Packs may contain additional loot.",
    rapport = {
        {
            task = "Completing The Lost Symbol, A Mother's Request, The Princess Detective companion quest",
            change = { initial = 500 },
            cooldown = "Once each",
        },
        {
            task = "Return an Undaunted daily challenge offered by Bolgrul",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Return High Isle group boss daily offered by Parisse Plouff",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Visit an Undaunted Enclave",
            change = { initial = 25, subsequent = 5 },
            cooldown = "20 hours",
        },
        {
            task = "Talk to an alliance leader (Emeric, Ayrenn, Jorunn)",
            change = { initial = 10, subsequent = 5, repeat2 = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Talk to Lyris Titanborn",
            change = { initial = 10 },
            cooldown = "1 hour",
        },
        {
            task = "Complete a volcanic vent",
            change = { initial = 10 },
            cooldown = "(?) (verification needed, bugged?)",
        },
        {
            task = "Kill a world boss",
            change = { initial = 10 },
            cooldown = "5 minutes",
        },
        {
            task = "Craft sweet delicacies or fruit dishes",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Craft an item at a blacksmithing station",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Kill a delve boss or group dungeon boss",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Kill a daedric boss",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Kill a daedra",
            change = { initial = 1 },
            cooldown = "210 seconds",
        },
        {
            task = "Use a repair kit",
            change = { initial = 1 },
            cooldown = "Daily",
        },
        {
            task = "Accept a duel",
            change = { initial = 1 },
            cooldown = "(?)",
        },
        {
            task = "Summoning a dog non-combat pet",
            change = { initial = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Murder",
            change = { initial = -10, subsequent = -1 },
            cooldown = "0",
        },
        {
            task = "Enter the Dark Brotherhood Sanctuary",
            change = { initial = -5 },
            cooldown = "20 hours",
        },
        {
            task = "Steal from container or loot a thieves trove",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Enter an Outlaw's Refuge",
            change = { initial = -1 },
            cooldown = "(?)",
        },
    },
}