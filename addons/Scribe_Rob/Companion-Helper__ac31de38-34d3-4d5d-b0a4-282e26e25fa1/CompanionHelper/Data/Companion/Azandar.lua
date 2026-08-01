local CH = CompanionHelper

CH.CompanionData.Companion[9] = {
    name = "Azandar al-Cyblades",
    gender = "Male",
    class = "Arcanist",
    race = "Redguard",
    perk = "Azandar's Inquisitiveness",
    effect = "When searching containers, it bestows a chance to discover research portfolios. Portfolios can contain crafting recipes, treasure maps, research notes, survey reports, and other documents of value.",
    rapport = {
        {
            task = "Complete Paths Unwalked, Adversarial Adventures, and Tempting Fates companion quests",
            change = { initial = 500 },
            cooldown = "Once each",
        },
        {
            task = "Return Ordinator Tilena, Necrom delve daily",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Return Enchanter Writ daily",
            change = { initial = 125 },
            cooldown = "Daily",
        },
        {
            task = "Returning Master Enchanter writ",
            change = { initial = 15 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Collect a Psijic portal",
            change = { initial = 15 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Visit the Brass Fortress, The Hollow City, Fargrave City District (cooldown shared across all)",
            change = { initial = 10 },
            cooldown = "Daily (?)",
        },
        {
            task = "Visit any Mundus Stone",
            change = { initial = 10 },
            cooldown = "Daily (?)",
        },
        {
            task = "Complete an Oblivion Portal",
            change = { initial = 5 },
            cooldown = "No cooldown (?) (verification needed)",
        },
        {
            task = "Interact with any Ayleid Well (Aetherial Wells on Auridon do not count)",
            change = { initial = 5 },
            cooldown = "1 hour (?)",
        },
        {
            task = "Read a new Mages Guild book",
            change = { initial = 5 },
            cooldown = "1 hour (?)",
        },
        {
            task = "Upgrade an item",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Acquire a lead",
            change = { initial = 5 },
            cooldown = "(?)",
        },
        {
            task = "Scrying",
            change = { initial = 5 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Consume any tea type beverage",
            change = { initial = 5 },
            cooldown = "1 hour (?)",
        },
        {
            task = "Steal treasure type of Magic Curiosities, Maps, Writings, Ritual Objects",
            change = { initial = 5, subsequent = 1 },
            cooldown = "(?)",
        },
        {
            task = "Brew any tea type beverage",
            change = { initial = 5, subsequent = 1 },
            cooldown = "1 hour (?)",
        },
        {
            task = "Read a lorebook",
            change = { initial = 5, subsequent = 1 },
            cooldown = "(?)",
        },
        {
            task = "Kill a chaurus",
            change = { initial = 1 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Kill a duneripper",
            change = { initial = 1 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Kill a dreugh",
            change = { initial = 1 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Kill a harpy",
            change = { initial = 1 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Kill a mudcrab",
            change = { initial = 1 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Kill a nix-ox",
            change = { initial = 1 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Kill an ogre",
            change = { initial = 1 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Kill a troll",
            change = { initial = 1 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Visit Artaeum or Eyevea (he's okay with The Scholarium)",
            change = { initial = -10 },
            cooldown = "15 minutes",
        },
        {
            task = "Give to a beggar",
            change = { initial = -10 },
            cooldown = "(?)",
        },
        {
            task = "Light a Campfire (Lightbringer)",
            change = { initial = -10 },
            cooldown = "(?)",
        },
        {
            task = "Consume a beverage with coffee",
            change = { initial = -5 },
            cooldown = "(?)",
        },
        {
            task = "Pick a mushroom",
            change = { initial = -1 },
            cooldown = "15 minutes (?)",
        },
        {
            task = "Brew a beverage with coffee",
            change = { initial = -1 },
            cooldown = "(?)",
        },
        {
            task = "Play a game of Tales of Tribute",
            change = { initial = -1 },
            cooldown = "(?)",
        },
    },
}