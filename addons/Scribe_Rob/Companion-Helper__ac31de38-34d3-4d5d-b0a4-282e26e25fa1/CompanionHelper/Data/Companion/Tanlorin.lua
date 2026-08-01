local CH = CompanionHelper

CH.CompanionData.Companion[12] = {
    name = "Tanlorin",
    gender = "Non-binary",
    class = "Dragonknight",
    race = "High Elf",
    perk = "Tanlorin's Finesse",
    effect = "When lockpicking, it bestows an increased time to pick a lock, an increased chance to force a lock, and a reduced chance to break a lockpick.",
    rapport = {
        -- Positive
        {
            task = "Returning their companion quests",
            change = { initial = 500 },
            cooldown = "Once",
        },
        {
            task = "Returning an Alchemy Writ daily",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Returning Dark Anchor contract offered by Cardea Gallus in Fighters Guild",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Scribe a spell",
            change = { initial = 25 },
            cooldown = "(?)",
        },
        {
            task = "Visit a Mundus Stone",
            change = { initial = 10 },
            cooldown = "Daily",
        },
        {
            task = "Use a Mystery Transformation Verse in the Infinite Archive",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Use the Persuasive Will passive in dialogue",
            change = { initial = 10 },
            cooldown = "(?)",
        },
        {
            task = "Pickpocket a guard",
            change = { initial = 10, subsequent = 1 },
            cooldown = "(?) / no cooldown",
        },
        {
            task = "Pickpocket a noble",
            change = { initial = 10, subsequent = 1 },
            cooldown = "(?) / no cooldown",
        },
        {
            task = "Visit Alinor",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Use the Campfire Kit memento",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Use the Glanir's Smoke Bomb memento",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Drink wine",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Successfully lockpick a container or door",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Hide in a basket while trespassing",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Use an Ayleid well",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Obtain a skyshard",
            change = { initial = 5, subsequent = 1 },
            cooldown = "(?)",
        },
        {
            task = "Gain any skill point",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Use the Antiquarian's Eye at a dig site",
            change = { initial = 5 },
            cooldown = "1 hour",
        },
        {
            task = "Obtain a vision in the Infinite Archive",
            change = { initial = 5 },
            cooldown = "5 minutes",
        },
        {
            task = "Harvest a flower",
            change = { initial = 5, subsequent = 1 },
            cooldown = "1 hour / no cooldown",
        },
        {
            task = "Fill a Soul Gem using Soul Trap skill",
            change = { initial = 5, subsequent = 1 },
            cooldown = "1 hour / no cooldown",
        },
        {
            task = "Loot a Scribing script",
            change = { initial = 5, subsequent = 1 },
            cooldown = "(?) / no cooldown",
        },
        {
            task = "Returning a Witches Festival Writ or Imperial Charity Writ",
            change = { initial = 5, subsequent = 1 },
            cooldown = "(?) / no cooldown",
        },
        {
            task = "Interact (dance/pet) with an animal",
            change = { initial = 5, subsequent = 1 },
            cooldown = "(?)",
        },
        {
            task = "Craft a Furnishing",
            change = { initial = 5, subsequent = 1 },
            cooldown = "(?) / no cooldown",
        },
        {
            task = "Return a New Life Festival quest",
            change = { initial = 5, subsequent = 1 },
            cooldown = "1 hour / no cooldown",
        },
        {
            task = "Learn a furnishing plan",
            change = { initial = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Craft a wine",
            change = { initial = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Mount an Indrik",
            change = { initial = 1 },
            cooldown = "1 hour",
        },
        {
            task = "Trespass",
            change = { initial = 1 },
            cooldown = "(?)",
        },
        {
            task = "Successfully run away from a guard",
            change = { initial = 1 },
            cooldown = "(?)",
        },
        {
            task = "Kill a hostile daedra",
            change = { initial = 1 },
            cooldown = "4 minutes",
        },
        {
            task = "Kill a hostile Maormer",
            change = { initial = 1 },
            cooldown = "5 minutes",
        },
        {
            task = "Obtain a verse in the Infinite Archive",
            change = { initial = 1 },
            cooldown = "No cooldown (?)",
        },
        {
            task = "Loot a Plunder Skull",
            change = { initial = 1 },
            cooldown = "(?)",
        },

        -- Negative
        {
            task = "Murder",
            change = { initial = -10, subsequent = -1 },
            cooldown = "3 hours / no cooldown",
        },
        {
            task = "Use the Blade of Woe (including against enemies)",
            change = { initial = -10, subsequent = -1 },
            cooldown = "5 minutes / no cooldown",
        },
        {
            task = "Visit Artaeum",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Loot a Psijic Portal",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Kill a Gryphon, Indrik, or Chimera",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Harvest Nirnroot or Crimson Nirnroot",
            change = { initial = -1 },
            cooldown = "1 hour",
        },
        {
            task = "Visit a Mages Guild guildhall",
            change = { initial = -1 },
            cooldown = "1 hour",
        },
        {
            task = "Read a lorebook",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Steal treasure type of Children's Toys or Dolls",
            change = { initial = -1 },
            cooldown = "(?)",
        },
    },
}