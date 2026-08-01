local ESOFacts = {}

-- Make globally accessible for keybind
_G.ESOFacts = ESOFacts

-- Addon info
ESOFacts.name = "ESOFacts"
ESOFacts.version = "1.3.0"

-- Default settings (saved between sessions)
ESOFacts.Defaults = {
    channel = "say",
    shownFacts = {},
    totalShared = 0,
    cooldown = 5,
    autoMaxCount = 10,
    autoMinInterval = 5,
    customFacts = {},
}

-- Runtime settings
ESOFacts.Cooldown = 5 -- Seconds between uses (loaded from saved vars)
ESOFacts.LastUsed = 0
ESOFacts.ShownFacts = {}
ESOFacts.CurrentChannel = CHAT_CHANNEL_SAY
ESOFacts.TotalShared = 0

-- Auto mode settings
ESOFacts.AutoEnabled = false
ESOFacts.AutoInterval = 300 -- Seconds (5 minutes minimum)
ESOFacts.AutoCount = 0
ESOFacts.AutoMaxCount = 10 -- Stop after this many auto-posts
ESOFacts.AutoAllowedChannels = {
    [CHAT_CHANNEL_PARTY] = true,
    [CHAT_CHANNEL_GUILD_1] = true,
    [CHAT_CHANNEL_GUILD_2] = true,
    [CHAT_CHANNEL_GUILD_3] = true,
    [CHAT_CHANNEL_GUILD_4] = true,
    [CHAT_CHANNEL_GUILD_5] = true,
}

-- Keybind string
ZO_CreateStringId("SI_BINDING_NAME_ESOFACTS_SHARE_FACT", "Share Random Fact")

-- Channel mapping
ESOFacts.Channels = {
    ["say"] = CHAT_CHANNEL_SAY,
    ["yell"] = CHAT_CHANNEL_YELL,
    ["group"] = CHAT_CHANNEL_PARTY,
    ["party"] = CHAT_CHANNEL_PARTY,
    ["guild1"] = CHAT_CHANNEL_GUILD_1,
    ["guild2"] = CHAT_CHANNEL_GUILD_2,
    ["guild3"] = CHAT_CHANNEL_GUILD_3,
    ["guild4"] = CHAT_CHANNEL_GUILD_4,
    ["guild5"] = CHAT_CHANNEL_GUILD_5,
    ["zone"] = CHAT_CHANNEL_ZONE,
}

-- Database of facts
ESOFacts.Facts = {
    -- Lore: Timeline & World
    "The Elder Scrolls Online takes place in the Second Era, around 800 years before Skyrim.",
    "Nirn, the planet where Tamriel exists, has multiple continents including Akavir and Atmora.",
    "Tamriel has two moons: Masser and Secunda, which are actually the body of the dead god Lorkhan.",
    "The continent of Akavir is home to races like the Tsaesci, Ka Po' Tun, and the Tang Mo.",
    "The Atmoran people migrated to Tamriel and eventually became the Nords.",
    "There are over 500 years of history between ESO and the events of Skyrim.",

    -- Lore: Races
    "Argonians are the only race that can breathe underwater indefinitely.",
    "The Khajiit's form at birth is determined by the phases of the moons.",
    "Orcs were originally Aldmer who were transformed when their god Trinimac was eaten by Boethiah.",
    "Bosmer are bound by the Green Pact, which forbids them from harming vegetation in Valenwood.",
    "The Altmer of Summerset believe they are the closest descendants of the original Aldmer.",
    "Dunmer were once Chimer until Azura cursed them with ash-colored skin and red eyes.",
    "Bretons have elven blood in their ancestry from when the Direnni ruled High Rock.",
    "Imperials are known for their discipline and diplomacy, founding several empires throughout history.",
    "Redguards originally came from the lost continent of Yokuda.",

    -- Lore: Gods & Daedra
    "The Daedric Princes are not actually gods, but powerful beings from Oblivion.",
    "The Aedra sacrificed much of their power to create Mundus, which is why they rarely intervene.",
    "Sheogorath was once Jyggalag, the Daedric Prince of Order, cursed by the other Princes.",
    "Meridia despises the undead and was originally a being called Merid-Nunda.",
    "Hermaeus Mora's realm, Apocrypha, contains all forbidden knowledge in existence.",
    "Molag Bal created vampires by corrupting a Nedic woman named Lamae Beolfag.",
    "Hircine is the creator of lycanthropy and holds the Great Hunt in his realm.",
    "Nocturnal is known as the Ur-Dra, claiming to be the oldest Daedric Prince.",

    -- Lore: History & Events
    "The Dwemer, or Deep Elves, mysteriously vanished in 1E 700 and no one knows exactly what happened to them.",
    "The Thu'um, or Voice, was taught to mortals by the dragon Paarthurnax.",
    "Vivec, one of the Tribunal gods, allegedly held Baar Dau (a meteor) above his city through sheer willpower.",
    "Red Mountain in Morrowind is actually a volcano that formed around the Heart of Lorkhan.",
    "The Imperial City was built around White-Gold Tower, a structure created by the Ayleids.",
    "The Akaviri Dragonguard eventually became the Blades who served the Emperors.",
    "The Mages Guild was founded by Vanus Galerion, a former Psijic monk.",
    "The Fighters Guild was established by the Akaviri Potentate in the Second Era.",

    -- Lore: Organizations
    "The Psijic Order is the oldest monastic group in Tamriel, predating the Mages Guild.",
    "The Dark Brotherhood's sanctuary password 'What is the music of life? Silence, my brother' has been used for centuries.",
    "The Thieves Guild worships Nocturnal and protects her shrine in the Evergloam.",
    "The Morag Tong is a legal assassin's guild in Morrowind, sanctioned by the government.",
    "The Companions of Whiterun trace their origins back to Ysgramor and his Five Hundred.",

    -- Lore: Creatures & Nature
    "The Hist are sentient trees that are worshipped by the Argonians.",
    "Mudcrabs are considered a delicacy in some parts of Tamriel.",
    "Clannfear are Daedric creatures often summoned by worshippers of Mehrunes Dagon.",
    "Netches are floating creatures native to Morrowind that produce a jelly used in alchemy.",
    "Dreugh are ancient creatures that once ruled the world before the races of men and mer.",
    "Welwas are fierce beasts native to Hammerfell that are sometimes used as war animals.",
    "Senche-Tigers are massive cats native to Elsweyr, sometimes mistaken for Khajiit.",

    -- Lore: Items & Artifacts
    "Sweet rolls have been a staple of Elder Scrolls games since Arena in 1994.",
    "Skooma is made from refined moon sugar, which comes from sugarcane grown in Elsweyr.",
    "The Staff of Chaos was used by Jagar Tharn to imprison Emperor Uriel Septim VII.",
    "Goldbrand is a katana created by the dragons as a gift for those who pleased them.",
    "The Skeleton Key is an artifact of Nocturnal that can unlock any lock, physical or metaphorical.",
    "Volendrung was created by the Dwemer but is now associated with Malacath.",
    "The Wabbajack is Sheogorath's staff that transforms targets into random creatures.",

    -- Lore: Places
    "Nords believe that dying in battle earns them a place in Sovngarde.",
    "Coldharbour, Molag Bal's realm of Oblivion, is a twisted mirror of Nirn.",
    "The Clockwork City was created by Sotha Sil to perfect the laws of nature.",
    "Artaeum, home of the Psijic Order, has disappeared from Nirn multiple times throughout history.",
    "The Deadlands is the realm of Mehrunes Dagon, a place of lava and destruction.",
    "Craglorn is the only zone in ESO that was designed for groups at launch.",

    -- ESO Specific
    "The Vestige's soul was stolen by Molag Bal, which is why they can resurrect at wayshrines.",
    "The Three Banners War in ESO involves the Aldmeri Dominion, Daggerfall Covenant, and Ebonheart Pact.",
    "Cadwell is the first soul to enter Coldharbour and has gone completely mad as a result.",
    "The Amulet of Kings was created from the blood of Akatosh and the soul of Lorkhan.",
    "Abnur Tharn is over 160 years old due to life-extending magic.",
    "Razum-dar, or Raz, is one of the Queen's Eyes and a fan-favorite character.",
    "The Soulburst event allowed Molag Bal to begin his Planemeld.",

    -- Fun Facts
    "You can find a talking mudcrab merchant in Morrowind named Telvanni Bug-Musk.",
    "M'aiq the Liar appears in every Elder Scrolls game since Morrowind.",
    "The cheese wheel is one of the most iconic items in Elder Scrolls games.",
    "Lyranth the Dremora appears in multiple ESO storylines and is surprisingly helpful.",
    "The Lusty Argonian Maid is a famous in-game book series written by Crassius Curio.",
    "Naryu Virian is a Morag Tong assassin who appears throughout the ESO storyline.",
    "Sheogorath's realm, the Shivering Isles, is divided into Mania and Dementia.",
    "The Giant's Camp in Skyrim was inspired by the developers launching players into the sky during testing.",
}

-- Get all facts (built-in + custom)
function ESOFacts.GetAllFacts()
    local allFacts = {}
    for _, fact in ipairs(ESOFacts.Facts) do
        table.insert(allFacts, fact)
    end
    if ESOFacts.savedVars and ESOFacts.savedVars.customFacts then
        for _, fact in ipairs(ESOFacts.savedVars.customFacts) do
            table.insert(allFacts, fact)
        end
    end
    return allFacts
end

-- Function to get a random fact (no repeats until all shown)
function ESOFacts.GetRandomFact()
    local allFacts = ESOFacts.GetAllFacts()

    -- Reset if we've shown all facts
    if #ESOFacts.ShownFacts >= #allFacts then
        ESOFacts.ShownFacts = {}
    end

    -- Build list of unshown facts
    local available = {}
    for i, fact in ipairs(allFacts) do
        local shown = false
        for _, shownIndex in ipairs(ESOFacts.ShownFacts) do
            if shownIndex == i then
                shown = true
                break
            end
        end
        if not shown then
            table.insert(available, i)
        end
    end

    -- Pick a random fact from available
    local pick = available[math.random(1, #available)]
    table.insert(ESOFacts.ShownFacts, pick)

    -- Save shown facts to saved variables
    if ESOFacts.savedVars then
        ESOFacts.savedVars.shownFacts = ESOFacts.ShownFacts
    end

    return allFacts[pick]
end

-- Slash command handler
function ESOFacts.SlashCommand(args)
    -- Check cooldown
    local currentTime = GetGameTimeMilliseconds() / 1000
    local timeSince = currentTime - ESOFacts.LastUsed

    if timeSince < ESOFacts.Cooldown then
        local remaining = math.ceil(ESOFacts.Cooldown - timeSince)
        d("Please wait " .. remaining .. " seconds before sharing another fact.")
        return
    end

    ESOFacts.LastUsed = currentTime
    local fact = ESOFacts.GetRandomFact()
    StartChatInput(fact, ESOFacts.CurrentChannel)

    -- Track total shared
    ESOFacts.TotalShared = ESOFacts.TotalShared + 1
    if ESOFacts.savedVars then
        ESOFacts.savedVars.totalShared = ESOFacts.TotalShared
    end
end

-- Channel command handler
function ESOFacts.ChannelCommand(args)
    local channel = string.lower(args)

    if channel == "" then
        d("Current channel: " .. ESOFacts.GetChannelName(ESOFacts.CurrentChannel))
        d("Available channels: say, yell, zone, group, guild1-5")
        return
    end

    if ESOFacts.Channels[channel] then
        ESOFacts.CurrentChannel = ESOFacts.Channels[channel]
        -- Save to saved variables
        if ESOFacts.savedVars then
            ESOFacts.savedVars.channel = channel
        end
        d("Facts will now be sent to: " .. channel)
    else
        d("Unknown channel: " .. channel)
        d("Available channels: say, yell, zone, group, guild1-5")
    end
end

-- Keybind handler
function ESOFacts.KeybindPressed()
    ESOFacts.SlashCommand("")
end

-- Get channel name from constant
function ESOFacts.GetChannelName(channel)
    for name, const in pairs(ESOFacts.Channels) do
        if const == channel then
            return name
        end
    end
    return "say"
end

-- Auto mode: send a fact automatically
function ESOFacts.AutoSendFact()
    if not ESOFacts.AutoEnabled then return end

    -- Check if we've hit the max
    if ESOFacts.AutoCount >= ESOFacts.AutoMaxCount then
        ESOFacts.StopAuto()
        d("[ESOFacts] Auto mode stopped: reached maximum of " .. ESOFacts.AutoMaxCount .. " facts.")
        return
    end

    -- Send the fact directly to chat
    local fact = ESOFacts.GetRandomFact()
    StartChatInput(fact, ESOFacts.CurrentChannel)
    -- Simulate pressing enter to send
    ZO_ChatWindowTextEntryEditBox:GetParent():OnTextEntryExecute()

    ESOFacts.AutoCount = ESOFacts.AutoCount + 1
    d("[ESOFacts] Auto-sent fact " .. ESOFacts.AutoCount .. "/" .. ESOFacts.AutoMaxCount)
end

-- Start auto mode
function ESOFacts.StartAuto(intervalMinutes)
    -- Validate channel
    if not ESOFacts.AutoAllowedChannels[ESOFacts.CurrentChannel] then
        d("[ESOFacts] Auto mode only works with group or guild channels.")
        d("Use /factschannel to set: group, guild1, guild2, guild3, guild4, guild5")
        return
    end

    local minInterval = ESOFacts.savedVars and ESOFacts.savedVars.autoMinInterval or 5
    local interval = tonumber(intervalMinutes) or minInterval
    if interval < minInterval then
        interval = minInterval
        d("[ESOFacts] Minimum interval is " .. minInterval .. " minutes. Setting to " .. minInterval .. ".")
    end

    ESOFacts.AutoInterval = interval * 60 -- Convert to seconds
    ESOFacts.AutoEnabled = true
    ESOFacts.AutoCount = 0

    -- Register the update handler
    EVENT_MANAGER:RegisterForUpdate("ESOFacts_Auto", ESOFacts.AutoInterval * 1000, ESOFacts.AutoSendFact)

    d("[ESOFacts] Auto mode started! Sending to " .. ESOFacts.GetChannelName(ESOFacts.CurrentChannel) .. " every " .. interval .. " minutes.")
    d("[ESOFacts] Will stop after " .. ESOFacts.AutoMaxCount .. " facts. Use /factstop to stop early.")
end

-- Stop auto mode
function ESOFacts.StopAuto()
    ESOFacts.AutoEnabled = false
    EVENT_MANAGER:UnregisterForUpdate("ESOFacts_Auto")
end

-- Auto command handler
function ESOFacts.AutoCommand(args)
    local interval = tonumber(args)
    if not interval then
        d("Usage: /factsauto <minutes>")
        d("Example: /factsauto 5 (sends a fact every 5 minutes)")
        d("Minimum interval: 5 minutes. Max facts: " .. ESOFacts.AutoMaxCount)
        return
    end
    ESOFacts.StartAuto(interval)
end

-- Stop command handler
function ESOFacts.StopCommand(args)
    if not ESOFacts.AutoEnabled then
        d("[ESOFacts] Auto mode is not running.")
        return
    end
    ESOFacts.StopAuto()
    d("[ESOFacts] Auto mode stopped. Sent " .. ESOFacts.AutoCount .. " facts.")
end

-- Stats command handler
function ESOFacts.StatsCommand(args)
    local allFacts = ESOFacts.GetAllFacts()
    local shown = #ESOFacts.ShownFacts
    local total = #allFacts
    local remaining = total - shown
    local customCount = ESOFacts.savedVars and #ESOFacts.savedVars.customFacts or 0

    d("[ESOFacts] Statistics:")
    d("  Total facts shared (all time): " .. ESOFacts.TotalShared)
    d("  Facts shown this cycle: " .. shown .. "/" .. total)
    d("  Remaining until cycle resets: " .. remaining)
    d("  Built-in facts: " .. #ESOFacts.Facts)
    d("  Custom facts: " .. customCount)
    d("  Current channel: " .. ESOFacts.GetChannelName(ESOFacts.CurrentChannel))
    if ESOFacts.AutoEnabled then
        d("  Auto mode: ON (" .. ESOFacts.AutoCount .. "/" .. ESOFacts.AutoMaxCount .. " sent)")
    else
        d("  Auto mode: OFF")
    end
end

-- Add custom fact command handler
function ESOFacts.AddFactCommand(args)
    if not args or args == "" then
        d("Usage: /factsadd Your custom fact here")
        return
    end

    if not ESOFacts.savedVars.customFacts then
        ESOFacts.savedVars.customFacts = {}
    end

    table.insert(ESOFacts.savedVars.customFacts, args)
    d("[ESOFacts] Added custom fact #" .. #ESOFacts.savedVars.customFacts .. ": " .. args)
end

-- List custom facts command handler
function ESOFacts.ListFactsCommand(args)
    if not ESOFacts.savedVars.customFacts or #ESOFacts.savedVars.customFacts == 0 then
        d("[ESOFacts] No custom facts added yet. Use /factsadd to add one.")
        return
    end

    d("[ESOFacts] Custom facts:")
    for i, fact in ipairs(ESOFacts.savedVars.customFacts) do
        -- Truncate long facts for display
        local display = fact
        if #display > 60 then
            display = string.sub(display, 1, 57) .. "..."
        end
        d("  " .. i .. ". " .. display)
    end
end

-- Remove custom fact command handler
function ESOFacts.RemoveFactCommand(args)
    local index = tonumber(args)
    if not index then
        d("Usage: /factsremove <number>")
        d("Use /factslist to see custom facts and their numbers.")
        return
    end

    if not ESOFacts.savedVars.customFacts or #ESOFacts.savedVars.customFacts == 0 then
        d("[ESOFacts] No custom facts to remove.")
        return
    end

    if index < 1 or index > #ESOFacts.savedVars.customFacts then
        d("[ESOFacts] Invalid fact number. Use /factslist to see valid numbers.")
        return
    end

    local removed = table.remove(ESOFacts.savedVars.customFacts, index)
    -- Reset shown facts since indices changed
    ESOFacts.ShownFacts = {}
    ESOFacts.savedVars.shownFacts = {}

    d("[ESOFacts] Removed custom fact #" .. index)
end

-- Build LibAddonMenu settings panel
function ESOFacts.BuildSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "ESO Facts",
        author = "Chris Roberts",
        version = ESOFacts.version,
        slashCommand = "/factsettings",
    }

    local optionsData = {
        {
            type = "header",
            name = "General Settings",
        },
        {
            type = "slider",
            name = "Cooldown (seconds)",
            tooltip = "Time to wait between sharing facts",
            min = 0,
            max = 30,
            step = 1,
            getFunc = function() return ESOFacts.savedVars.cooldown end,
            setFunc = function(value)
                ESOFacts.savedVars.cooldown = value
                ESOFacts.Cooldown = value
            end,
            default = ESOFacts.Defaults.cooldown,
        },
        {
            type = "dropdown",
            name = "Default Channel",
            tooltip = "Channel to send facts to",
            choices = {"say", "yell", "zone", "group", "guild1", "guild2", "guild3", "guild4", "guild5"},
            getFunc = function() return ESOFacts.savedVars.channel end,
            setFunc = function(value)
                ESOFacts.savedVars.channel = value
                ESOFacts.CurrentChannel = ESOFacts.Channels[value]
            end,
            default = ESOFacts.Defaults.channel,
        },
        {
            type = "header",
            name = "Auto Mode Settings",
        },
        {
            type = "slider",
            name = "Minimum Interval (minutes)",
            tooltip = "Minimum time between auto-sent facts",
            min = 1,
            max = 30,
            step = 1,
            getFunc = function() return ESOFacts.savedVars.autoMinInterval end,
            setFunc = function(value)
                ESOFacts.savedVars.autoMinInterval = value
            end,
            default = ESOFacts.Defaults.autoMinInterval,
        },
        {
            type = "slider",
            name = "Max Auto Facts",
            tooltip = "Maximum facts to send before auto mode stops",
            min = 1,
            max = 50,
            step = 1,
            getFunc = function() return ESOFacts.savedVars.autoMaxCount end,
            setFunc = function(value)
                ESOFacts.savedVars.autoMaxCount = value
                ESOFacts.AutoMaxCount = value
            end,
            default = ESOFacts.Defaults.autoMaxCount,
        },
        {
            type = "header",
            name = "Statistics",
        },
        {
            type = "description",
            text = function()
                local customCount = ESOFacts.savedVars and #ESOFacts.savedVars.customFacts or 0
                return "Total facts shared: " .. ESOFacts.TotalShared .. "\n" ..
                       "Built-in facts: " .. #ESOFacts.Facts .. "\n" ..
                       "Custom facts: " .. customCount .. "\n" ..
                       "Shown this cycle: " .. #ESOFacts.ShownFacts
            end,
        },
        {
            type = "button",
            name = "Reset Cycle",
            tooltip = "Reset the shown facts list to see all facts again",
            func = function()
                ESOFacts.ShownFacts = {}
                ESOFacts.savedVars.shownFacts = {}
                d("[ESOFacts] Fact cycle reset!")
            end,
        },
    }

    LAM:RegisterAddonPanel("ESOFactsOptions", panelData)
    LAM:RegisterOptionControls("ESOFactsOptions", optionsData)
end

-- Initialization
function ESOFacts.OnAddOnLoaded(event, addonName)
    if addonName ~= "ESOFacts" then return end

    -- Unregister the event since we only need it once
    EVENT_MANAGER:UnregisterForEvent("ESOFacts", EVENT_ADD_ON_LOADED)

    -- Initialize saved variables
    ESOFacts.savedVars = ZO_SavedVars:NewAccountWide("ESOFactsSavedVars", 1, nil, ESOFacts.Defaults, GetWorldName())

    -- Load saved settings
    if ESOFacts.savedVars.channel and ESOFacts.Channels[ESOFacts.savedVars.channel] then
        ESOFacts.CurrentChannel = ESOFacts.Channels[ESOFacts.savedVars.channel]
    end
    if ESOFacts.savedVars.shownFacts then
        ESOFacts.ShownFacts = ESOFacts.savedVars.shownFacts
    end
    if ESOFacts.savedVars.totalShared then
        ESOFacts.TotalShared = ESOFacts.savedVars.totalShared
    end
    if ESOFacts.savedVars.cooldown then
        ESOFacts.Cooldown = ESOFacts.savedVars.cooldown
    end
    if ESOFacts.savedVars.autoMaxCount then
        ESOFacts.AutoMaxCount = ESOFacts.savedVars.autoMaxCount
    end

    -- Register the slash commands
    SLASH_COMMANDS["/facts"] = ESOFacts.SlashCommand
    SLASH_COMMANDS["/factschannel"] = ESOFacts.ChannelCommand
    SLASH_COMMANDS["/factsauto"] = ESOFacts.AutoCommand
    SLASH_COMMANDS["/factstop"] = ESOFacts.StopCommand
    SLASH_COMMANDS["/factsstats"] = ESOFacts.StatsCommand
    SLASH_COMMANDS["/factsadd"] = ESOFacts.AddFactCommand
    SLASH_COMMANDS["/factslist"] = ESOFacts.ListFactsCommand
    SLASH_COMMANDS["/factsremove"] = ESOFacts.RemoveFactCommand

    -- Build settings menu if LAM is available
    if LibAddonMenu2 then
        ESOFacts.BuildSettingsMenu()
    end

    local allFacts = ESOFacts.GetAllFacts()
    d("ESOFacts v" .. ESOFacts.version .. " loaded! " .. #allFacts .. " facts available.")
    d("Commands: /facts, /factschannel, /factsauto, /factstop, /factsstats")
    d("Custom facts: /factsadd, /factslist, /factsremove")

    if not LibAddonMenu2 then
        d("Tip: Install LibAddonMenu for a settings panel (/factsettings)")
    end
end

-- Register for the addon loaded event
EVENT_MANAGER:RegisterForEvent("ESOFacts", EVENT_ADD_ON_LOADED, ESOFacts.OnAddOnLoaded)
