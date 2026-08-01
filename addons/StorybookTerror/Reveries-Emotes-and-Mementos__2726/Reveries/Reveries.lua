local LAM2 = LibAddonMenu2

local RV = {
    name = "Reveries",
    version = "0.9"
}

-- Automatically ignore all messages in these maps (like solo areas)
RV.disallowedMaps = {
    -- Vateshran Arena:
    [1843] = true, -- The Wounding
    [1844] = true, -- Hunter's Grotto
    [1845] = true, -- The Brimstone Den
    [1846] = true, -- Champion's Circle
    -- Maelstrom Arena:
    [977] = true,  -- Maelstrom Arena          (Lobby)
    [988] = true,  -- Vale of the Surreal      (Stage 1)
    [963] = true,  -- Seht's Balcony           (Stage 2)
    [978] = true,  -- The Drome of Toxic Shock (Stage 3)
    [970] = true,  -- Seht's Flywheel          (Stage 4)
    [976] = true,  -- The Rink of Frozen Blood (Stage 5)
    [973] = true,  -- The Spiral Shadows       (Stage 6)
    [987] = true,  -- The Vault of Umbrage     (Stage 7)
    [986] = true,  -- The Igneous Cistern      (Stage 8)
    [985] = true,  -- The Theater of Despair   (Stage 9)
    -- Thieves Guild Heists:
    [827] = true,  -- Secluded Sewers
    [831] = true,  -- Deadhollow Halls
    [834] = true,  -- The Hideaway
    [835] = true,  -- Glittering Grotto
    [829] = true,  -- Underground Sepulcher
    -- Dark Brotherhood Sacraments:
    [828] = true,  -- Smuggler's Den
    [833] = true,  -- Sewer Tenement
    [830] = true,  -- Trader's Cove
}

-- Mapping from emote slash command to numeric index
RV.emoteIndexes = {}
RV.mementoIndexes = {}
RV.mementoShortIndexes = {}

-----------------------------------------------------------------------------
-- Mapping from the full Memento name to a shortcut
-----------------------------------------------------------------------------
local mementoShortNames =
{
    ["Ghost Lantern"]                    = "ghostlantern",
    ["Snow Cadwell"]                     = "snowcadwell",
    ["Sanguine's Goblet"]                = "sanguine",
    ["Finvir's Trinket"]                 = "beam",
    ["Flame Eruption"]                   = "eruption",
    ["Dwarven Tonal Forks"]              = "tonalfork",
    ["Blackfeather Court Whistle"]       = "crowwhistle",
    ["Murderous Strike"]                 = "murderstrike",
    ["Wild Hunt Leaf-Dance Aura"]        = "leafdance",
    ["Dwemervamidium Mirage"]            = "dwemermirage",
    ["Breda's Bottomless Mead Mug"]      = "bredamug",
    ["Justal's Falcon"]                  = "falcon",
    ["Miniature Dwarven Sun"]            = "dwarvensun",
    ["Neramo's Lightning Stick"]         = "neramo",
    ["Lena's Wand of Finding"]           = "wandfind",
    ["Kyne's Tablet of Storms"]          = "kynestorm",
    ["Murkmire Grave-Stake"]             = "gravestake",
    ["Prismatic Banner Ribbon"]          = "rainbow",
    ["Gold Dragon Hand Projector"]       = "golddragon",
    ["Crow's Calling"]                   = "crowcall",
    ["Glanir's Smoke Bomb"]              = "smokebomb",
    ["Flame Pixie"]                      = "flamepixie",
    ["Blade of the Blood Oath"]          = "bloodoath",
    ["Clockwork Obscuros"]               = "obscuros",
    ["Nanwen's Sword"]                   = "nanwen",
    ["Box of Forbidden Relics"]          = "relicbox",
    ["Storm Atronach Transform"]         = "stormxform",
    ["Wild Hunt Transform"]              = "wildxform",
    ["Juggler's Knives"]                 = "juggleknives",
    ["Replica Tonal Inverter"]           = "tonalinverter",
    ["Gryphon Feather Talisman"]         = "gryphonfeather",
    ["Cherry Blossom Branch"]            = "petal",
    ["Fire-Breather's Torches"]          = "firebreath",
    ["Storm Orb Juggle"]                 = "juggleorb",
    ["Dragonhorn Curio"]                 = "dragonhorn",
    ["Questionable Meat Sack"]           = "meatsack",
    ["Brittle Burial Urn"]               = "maneurn",
    ["Twilight Shard"]                   = "twilightshard",
    ["Wyrd Elemental Plume"]             = "wyrdplume",
    ["Wall of Life Brush"]               = "walloflife",
    ["Bone Dragon Summons Focus"]        = "bonedragon",
    ["Storm Atronach Aura"]              = "stormaura",
    ["Dwarven Puzzle Orb"]               = "puzzleorb",
    ["Fetish of Anger"]                  = "fetishofanger",
    ["Psijic Celestial Orb"]             = "sloadpearl",
    ["Scalecaller Rune of Levitation"]   = "levitate",
    ["Chains of the Ice Witch"]          = "chains",
    ["Fire Rock"]                        = "firerock",
    ["Discourse Amaranthine"]            = "amaranthine",
    ["Sapiarchic Discorporation Lens"]   = "discorp",
    ["Bone Digger's Trinket"]            = "bonedig",
    ["Malacath's Wrathful Flame"]        = "malacath",
    ["Scalecaller Frost Shard"]          = "scalecaller",
    ["Token of Root Sunder"]             = "rootsunder",
    ["Fiery Orb"]                        = "fireorb",
    ["Gourd-Gallows Stump"]              = "gourdstump",
    ["Dreamer's Chime"]                  = "dreamers",
    ["Witchmother's Whistle"]            = "witchmother",
    ["Almalexia's Enchanted Lantern"]    = "lantern",
    ["Sword-Swallower's Blade"]          = "swallowsword",
    ["Battered Bear Trap"]               = "beartrap",
    ["Hidden Pressure Vent"]             = "vent",
    ["Meridian Possession Prism"]        = "meridiaprism",
    ["Mezha-dro's Sealing Amulet"]       = "sealtear",
    ["Dragon Flight Illusion Gem"]       = "dragons",
    ["Apple-Bobbing Cauldron"]           = "applebob",
    ["Nirnroot Wine"]                    = "nirnrootwine",
    ["Lodorr's Crown"]                   = "lodorr",
    ["Cadwell's Chaotic Portal"]         = "cadwellportal",
    ["Yokudan Totem"]                    = "yokudantotem",
    ["Antiquarian's Eye"]                = "scry",
    ["Umbral Projector"]                 = "umbral",
    ["Coin of Illusory Riches"]          = "coinfall",
    ["Wooden Grave-Stake"]               = "gravestake2",
    ["Swarm of Crows"]                   = "crowball",
    ["Psijic Tautology Glass"]           = "tautology",
    ["Bonesnap Binding Stone"]           = "bonesnap",
    ["Vossa-satl"]                       = "vossasatl",
    ["Mire Drum"]                        = "miredrum",
    ["Rind-Renewing Pumpkin"]            = "pumpkin",
    ["Fungimancer's Prayer-Beads"]       = "prayerbeads",
    ["Mud Ball Pouch"]                   = "mudball",
    ["Archaic Lore Tablets"]             = "loretablet",
    ["Werewolf Behemoth Sigil"]          = "werewolf",
    ["Psijic Scrying Talisman"]          = "portal",
    ["Kick Ball"]                        = "kickball",
    ["Festive Noise Maker"]              = "noisemaker",
    ["Corruption of Maarselok"]          = "maarselok",
    ["Antiquarian's Telescope"]          = "telescope",
    ["Jester's Scintillator"]            = "jester",
    ["Blizzard Globe"]                   = "blizzardglobe",
    ["Pint of Belching"]                 = "belch",
    ["Bright Moons"]                     = "brightmoons",
    ["Winnowing Plague Decoction"]       = "plague",
    ["Sea Sload Dorsal Fin"]             = "sloadfin",
    ["Orb of Magnus"]                    = "sunbeam",
    ["Dream Amulet of Argon"]            = "dreamargon",
    ["The Pie of Misrule"]               = "misrule",
    ["Everlasting Snowball"]             = "snowball",
    ["Skeletal Marionette"]              = "skellypuppet",
    ["Accursed Gray Reliquary"]          = "grayreliquary",
    ["Floral Swirl Aura"]                = "floralswirl",
    ["Ritual Circle Totem"]              = "ritualcircle",
    ["Jester's Festival Joke Popper"]    = "jokepop",
    ["Mostly Stable Juggling Potions"]   = "jugglepotions",
    ["Reliquary of Dark Designs"]        = "darkdesigns",
    ["Thetys Ramarys's Bait Kit"]        = "baitkit",
    ["Void Shard"]                       = "voidshard",
    ["Throwing Bones"]                   = "throwbones",
    ["Campfire Kit"]                     = "campfire",
    ["Full-Scale Golden Anvil Replica"]  = "goldanvil",
    ["Playful Prankster's Surprise Box"] = "prankster",
    ["Agonymium Stone"]                  = "agonymium",
    ["Daedric Unwarding Amulet"]         = "unwarding",
    ["Daedroth Illusion Gem"]            = "daedroth",
    ["Witch's Bonfire Dust"]             = "bonfire",
    ["Illusory Salamander Stone"]        = "salamander",
    ["Phial of Clockwork Lubricant"]     = "oilslick",
    ["Temperamental Grimoire"]           = "grimoire",
    ["Wilting Weed Killer Phial"]        = "weedkill",
    ["Jubilee Cake 2016"]                = "cake2016",
    ["Jubilee Cake 2017"]                = "cake2017",
    ["Jubilee Cake 2018"]                = "cake2018",
    ["Jubilee Cake 2019"]                = "cake2019",
    ["Jubilee Cake 2020"]                = "cake2020",
    ["Jubilee Cake 2021"]                = "cake2021",
    ["Jubilee Cake 2022"]                = "cake2022",
    ["Jubilee Cake 2023"]                = "cake2023",
    ["Jubilee Cake 2024"]                = "cake2024",
    ["Jubilee Cake 2025"]                = "cake2025",
    ["Jubilee Cake 2026"]                = "cake2026",
}

-----------------------------------------------------------------------------
-- Settings UI Panel
-----------------------------------------------------------------------------
local function sortedKeys(orig)
    local t = {}
    for k,v in pairs(orig) do
        table.insert(t, k)
    end
    table.sort(t)
    return t
end

function RV.CreateSettingsPanel()
    local panelData = {
        type = "panel",
        name = RV.name,
        displayName = RV.name .. ": Emotes and Mementos",
        author = "StorybookTerror",
        version = RV.version,
        registerForDefaults = true,
        website = "http://github.com/storybookterror/reveries"
    }
    LAM2:RegisterAddonPanel(RV.name, panelData)

    local options = {
        {
            type = "header",
            name = "Memento Cooldown Bar",
        },
        {
            type = "dropdown",
            name = "Show Memento Cooldown Bar",
            tooltip = "Display the cooldown of an active memento at the top of the screen.",
            width = "full",
            choices = { "On", "Scrying Only", "Off" },
            default = RV.vars.showbar,
            getFunc = function() return RV.vars.showbar end,
            setFunc = function(value) RV.vars.showbar = value end,
        },
        {
            type = "button",
            name = "Reset to Default Position",
            tooltip = "If you've dragged the bar to a custom location on screen, this will reset it to the default location.",
            func = RV.SetDefaultCollectibleBarPosition
        },
        {
            type = "header",
            name = "Synchronized Actions",
        },
        {
            type = "description",
            text = [[Reveries can listen to chat for messages like "RV dance" and auto-activate an emote or memento.  This makes it possible to synchronize actions (say, have everyone dance at once).  You can configure this below.

"/rv on" and "/rv off" let you quickly toggle this feature.]]
        },
        {
            type = "checkbox",
            name = "Listen to Chat",
            tooltip = "When set, Reveries will listen to chat and perform emotes and mementos.",
            width = "full",
            default = RV.vars.active,
            getFunc = function() return RV.vars.active end,
            setFunc =
                function(value)
                    if value then
                        RV.Enable()
                    else
                        RV.Disable()
                    end
                end
        },
        {
            type = "dropdown",
            name = "In Dungeons/Trials...",
            tooltip = "Listen normally / Only listen to group members / Ignore everyone (disable)",
            width = "full",
            choices = { "Allow", "Only Group", "Ignore" },
            default = RV.vars.dungeons,
            getFunc = function() return RV.vars.dungeons end,
            setFunc = function(value) RV.vars.dungeons = value end,
        },
    }

    -- Add chat channels
    local chatChannelNames = {
        { CHAT_CHANNEL_EMOTE, "/emote" },
        { CHAT_CHANNEL_PARTY, "/group" },
        { CHAT_CHANNEL_SAY, "/say" },
        { CHAT_CHANNEL_WHISPER, "/whisper" },
        { CHAT_CHANNEL_YELL, "/yell" },
        { CHAT_CHANNEL_ZONE, "/zone" },
    }

    chatCheckboxes = {
        type = "submenu",
        name = "Chat Channels",
        controls = {}
    }
    options[#options + 1] = chatCheckboxes

    for i = 1, 5 do
        local id = GetGuildId(i)
        local guild = GetGuildName(id)
        table.insert(chatChannelNames, { CHAT_CHANNEL_GUILD_1 + i - 1, string.format("/g%d: %s", i, guild) })
        table.insert(chatChannelNames, { CHAT_CHANNEL_OFFICER_1 + i - 1, string.format("/o%d: %s [Officers]", i, guild) })
    end

    for i, chanInfo in ipairs(chatChannelNames) do
        local channelEnum = chanInfo[1]
        local channelName = chanInfo[2]

        table.insert(chatCheckboxes.controls, {
            type = "checkbox",
            name = channelName,
            width = "full",
            default = channelEnum == CHAT_CHANNEL_PARTY,
            getFunc = function() return RV.vars.activeChats[channelEnum] end,
            setFunc = function(value) RV.vars.activeChats[channelEnum] = value end,
        })
    end

    -- Add emote checkboxes
    emoteCheckboxes = {
        type = "submenu",
        name = "Emotes to Allow",
        controls = {}
    }
    options[#options + 1] = emoteCheckboxes

    sortedEmotes = sortedKeys(RV.emoteIndexes)
    for _, k in ipairs(sortedEmotes) do
        table.insert(emoteCheckboxes.controls, {
            type = "checkbox",
            name = "/" .. k,
            width = "full",
            default = true,
            getFunc = function() return not RV.globals.disallowed_emotes[k] end,
            setFunc = function(value) if value then RV.globals.disallowed_emotes[k] = nil else RV.globals.disallowed_emotes[k] = not value end end,
        })
    end

    -- Add memento checkboxes
    mementoCheckboxes = {
        type = "submenu",
        name = "Mementos to Allow",
        controls = {}
    }
    options[#options + 1] = mementoCheckboxes

    sortedMementos = sortedKeys(RV.mementoIndexes)
    for _, k in pairs(sortedMementos) do
        if k:lower() ~= k then
            local m = RV.mementoIndexes[k]
            table.insert(mementoCheckboxes.controls, {
                type = "checkbox",
                name = mementoShortNames[k] and string.format("%s [%s]", k, mementoShortNames[k]) or k,
                width = "full",
                default = true,
                getFunc = function() return not RV.globals.disallowed_mementos[m] end,
                setFunc = function(value) if value then RV.globals.disallowed_mementos[m] = nil else RV.globals.disallowed_mementos[m] = true end end,
            })
        end
    end

    LAM2:RegisterOptionControls(RV.name, options)
end

function RV.PlayMemento(name)
    local memento = RV.mementoIndexes[name]

    if not memento then
        memento = RV.mementoShortIndexes[name]
    end

    if not memento then
        d(RV.name .. ': unknown memento "' .. name .. '"')
    elseif IsCollectibleUsable(memento) then
        UseCollectible(memento)
    else
        local blockReason = GetCollectibleBlockReason(memento)
        local blockReasons = {
            [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_SUBZONE] = "unable to use in subzone",
            [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_ZONE] = "unable to use in zone",
            [COLLECTIBLE_USAGE_BLOCK_REASON_DEAD] = "dead",
            [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_ALLIANCE] = "invalid alliance",
            [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_CLASS] = "class",
            [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_COLLECTIBLE] = "invalid collectible",
            [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_GENDER] = "invalid gender",
            [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_RACE] = "invalid race",
            [COLLECTIBLE_USAGE_BLOCK_REASON_IN_WATER] = "in water",
            [COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN] = "on cooldown",
            [COLLECTIBLE_USAGE_BLOCK_REASON_ON_MOUNT] = "on mount",
            [COLLECTIBLE_USAGE_BLOCK_REASON_PLACED_IN_HOUSE] = "placed in house",
            [COLLECTIBLE_USAGE_BLOCK_REASON_TARGET_REQUIRED] = "requires target",
        }
        d(RV.name .. ': Cannot use memento (' .. (blockReasons[blockReason] or 'unknown reason') .. ')')
    end
end

-----------------------------------------------------------------------------
-- Handle Chat Messages
-----------------------------------------------------------------------------
function RV.OnChatMessageChannel(eventCode, channelType, fromCharacter, msg, _, fromAccount)
    -- Treat Whisper/Sent Whispers the same
    if channelType == CHAT_CHANNEL_WHISPER_SENT then
        channelType = CHAT_CHANNEL_WHISPER
    end

    -- Skip any channels we're not supposed to listen to
    if not RV.vars.activeChats[channelType] then
        return
    end

    -- Ignore any messages not prefixed for our add-on
    if msg:sub(1, 3):upper() ~= "RV " then
        return
    end

    -- Ignore messages in dungeons based on settings
    if GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_NONE then
        if RV.vars.dungeons == "Ignore" then
            return
        end
        if RV.vars.dungeons == "Only Group" and not IsPlayerInGroup(fromAccount) then
            return
        end
    end

    -- Ignore messages in specific disallowed maps
    if RV.disallowedMaps[GetCurrentMapId()] then
        return
    end

    msg = msg:sub(4)

    local emote = RV.emoteIndexes[msg]
    local memento = RV.mementoIndexes[msg]

    if emote then
        if RV.globals.disallowed_emotes[msg] then
            d(RV.name .. ': Disallowed emote /' .. msg .. '...ignoring.')
        else
            PlayEmoteByIndex(emote)
        end
    elseif memento then
        if RV.globals.disallowed_mementos[memento] then
            d(RV.name .. ': Disallowed memento <' .. msg .. '>...ignoring.')
        else
            RV.PlayMemento(msg)
        end
    else
        d(RV.name .. ': Unrecognized command: ' .. msg)
    end
end

-----------------------------------------------------------------------------
-- Toggle Listening to Chat
-----------------------------------------------------------------------------
function RV.Enable()
    RV.vars.active = true
    EVENT_MANAGER:RegisterForEvent(RV.name, EVENT_CHAT_MESSAGE_CHANNEL, RV.OnChatMessageChannel)
end

function RV.Disable()
    RV.vars.active = false
    EVENT_MANAGER:UnregisterForEvent(RV.name, EVENT_CHAT_MESSAGE_CHANNEL)
end

-----------------------------------------------------------------------------
-- Collectible UI Bar
-----------------------------------------------------------------------------
local function CollectibleBarOnMoveStop()
    RV.vars.barX = RVFrame:GetLeft()
    RV.vars.barY = RVFrame:GetTop()
end

function RV.SetDefaultCollectibleBarPosition()
    RVFrame:ClearAnchors()
    RVFrame:SetAnchor(BOTTOMLEFT, ZO_CompassFrameLeft, TOPLEFT, 0, -5)
    CollectibleBarOnMoveStop()
end

local function UpdateCollectibleBar(id)
    local remaining, duration = GetCollectibleCooldownAndDuration(id)

    -- IsCollectibleUsable returns true for the Antiquarian's Eye when
    -- not at a dig site, so we use it, but it fails, resulting in a
    -- duration of zero.  Skip putting up the bar in that case.
    if duration == 0 then
        return
    end

    -- If you try and use a collectible while it's on cooldown, we'll
    -- end up here with the cooldown bar already in place.  Just let
    -- it continue the existing animation rather than resetting it.
    if RVFrameIcon:GetAlpha() > 0 then
        return
    end

    duration = math.max(duration, 2000)

    RVFrameIcon:SetTexture(GetCollectibleIcon(id))
    RVFrameIcon:SetAlpha(1)
    RVFrameBar:SetAlpha(RV.barAlpha)

    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local barSize = timeline:InsertAnimation(ANIMATION_SIZE, RVFrameBar)
    barSize:SetStartAndEndWidth(RV.barWidth, 0)
    barSize:SetStartAndEndHeight(RVFrameBar:GetHeight(), RVFrameBar:GetHeight())
    barSize:SetDuration(duration)

    local barFadeTime = 1500
    local barFade = timeline:InsertAnimation(ANIMATION_ALPHA, RVFrameBar)
    barFade = timeline:InsertAnimation(ANIMATION_ALPHA, RVFrameBar, duration - barFadeTime)
    barFade:SetAlphaValues(RV.barAlpha, 0)
    barFade:SetDuration(barFadeTime)

    local iconFadeTime = 500
    local iconFade = timeline:InsertAnimation(ANIMATION_ALPHA, RVFrameIcon)
    iconFade = timeline:InsertAnimation(ANIMATION_ALPHA, RVFrameIcon, duration - iconFadeTime)
    iconFade:SetAlphaValues(1, 0)
    iconFade:SetDuration(iconFadeTime)

    timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT)
    timeline:PlayFromStart()
end

local function ScheduleCollectibleUpdate(id)
    if RV.vars.showbar == "Off" or (RV.vars.showbar == "Scrying Only" and id ~= RV.mementoIndexes["Antiquarian's Eye"]) then
        return
    end

    if GetCollectibleCategoryType(id) ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
        return
    end

    -- The collectible duration isn't queriable at UseCollectible() time,
    -- because it hasn't actually activated yet.  Wait a few milliseconds
    -- before actually trying to do any work.
    zo_callLater(function() UpdateCollectibleBar(id) end, 250)
end

-----------------------------------------------------------------------------
-- Slash Command Handlers
-----------------------------------------------------------------------------
function RV.HandleSlashCommandRV(msg)
    if msg == "on" then
        RV.Enable()
        d(RV.name .. " activated - will listen to chat")
    elseif msg == "off" then
        RV.Disable()
        d(RV.name .. " disabled - will ignore chat")
    elseif msg == "help" then
        d(RV.name .. " Help: Use Settings > Addons > " .. RV.name .. " to configure the add-on.")
        d("/rv on - Listen to incoming chat and perform actions")
        d("/rv off - Ignore any incoming action requests")
    end
end

function RV.RegisterSubCommand(cmd, shortname, longname, callback, description)
    local sub = cmd:RegisterSubCommand()
    sub:AddAlias(shortname)
    sub:SetCallback(callback)
    sub:SetDescription(description)
end

function RV.RegisterEmoteSubCommand(name)
    RV.RegisterSubCommand(RV.SlashRV, name, name,
                          function() StartChatInput("rv " .. name) end,
                          "Play /" .. name .. " emote")
end

function RV.RegisterMementoSubCommand(name)
    local alias = name:gsub(" ", "-")
    RV.RegisterSubCommand(RV.SlashRV, alias, name,
                          function() StartChatInput("rv " .. name) end,
                          "Play \"" .. name .. "\" memento")
    RV.RegisterSubCommand(RV.SlashMeme, alias, name,
                          function() RV.PlayMemento(name) end,
                          "Play \"" .. name .. "\" memento")
    if mementoShortNames[name] then
        RV.RegisterSubCommand(RV.SlashRV, mementoShortNames[name], name,
                              function() StartChatInput("rv " .. name) end,
                              "Play \"" .. name .. "\" memento")
        RV.RegisterSubCommand(RV.SlashMeme, mementoShortNames[name], name,
                              function() RV.PlayMemento(name) end,
                              "Play \"" .. name .. "\" memento")
    end
end

-- Register our slash commands
function RV.RegisterSlashCommands()
    local lsc = LibSlashCommander
    if lsc then
        RV.SlashRV = lsc:Register("/rv", RV.HandleSlashCommandRV, "Reveries: Synchronize Action")
        RV.SlashMeme = lsc:Register("/meme", RV.PlayMemento, "Reveries: Activate Memento for Self")

        for name in pairs(RV.emoteIndexes) do
            RV.RegisterEmoteSubCommand(name)
        end

        for name in pairs(RV.mementoIndexes) do
            RV.RegisterMementoSubCommand(name)
        end

        RV.SlashScry = lsc:Register("/scry", function() RV.PlayMemento("Antiquarian's Eye") end, "Activate the Antiquarian's Eye Tool")
    else
        SLASH_COMMANDS["/rv"] = RV.HandleSlashCommandRV
        SLASH_COMMANDS["/meme"] = RV.PlayMemento
        SLASH_COMMANDS["/scry"] = function() RV.PlayMemento("Antiquarian's Eye") end
    end
end

-----------------------------------------------------------------------------
-- Add-on initialization
-----------------------------------------------------------------------------
local function SetupEmoteMappings(id)
    local name = GetEmoteSlashNameByIndex(id):sub(2)
    RV.emoteIndexes[name] = id
end

local function SetupMementoMappings(id)
    local name, _, _, _, unlocked = GetCollectibleInfo(id)
    if unlocked then
        RV.mementoIndexes[name] = id
        if mementoShortNames[name] then
            RV.mementoShortIndexes[mementoShortNames[name]] = id
        end
    end
end

local function SetupCollectibleMappings()
    -- Set up Emote -> Index mapping
    local num_emotes = GetNumEmotes()

    for i = 1, num_emotes do
        SetupEmoteMappings(i)
    end

    -- Set up Memento -> Index mapping
    local num_mementos = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO)

    for i = 1, num_mementos do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        SetupMementoMappings(id)
    end
end

local function GetNextDirtyUnlockStateCollectibleIdIter(_, lastCollectibleId)
    return GetNextDirtyUnlockStateCollectibleId(lastCollectibleId)
end

local function OnCollectiblesUnlockStateChanged()
    -- TODO: Update the addon settings UI

    for collectibleId in GetNextDirtyUnlockStateCollectibleIdIter do
        local categoryType = GetCollectibleCategoryType(collectibleId)
        if categoryType == COLLECTIBLE_CATEGORY_TYPE_MEMENTO then
            SetupMementoMappings(collectibleId)
            RV.RegisterMementoSubCommand(GetCollectibleName(collectibleId))
        end
    end
end

function RV.Initialize()
    -- Set up saved variables
    RV.globals = ZO_SavedVars:NewAccountWide("ReveriesVars", 1, nil, {
        disallowed_emotes = {},
        disallowed_mementos = {},
    })
    RV.vars = ZO_SavedVars:NewAccountWide("ReveriesServerVars", 1, GetWorldName(), {
        dungeons = "Only Group",
        showbar = "On",
        activeChats = {
            [CHAT_CHANNEL_EMOTE] = false,
            [CHAT_CHANNEL_SAY] = false,
            [CHAT_CHANNEL_YELL] = false,
            [CHAT_CHANNEL_PARTY] = true,
            [CHAT_CHANNEL_ZONE] = false,
            [CHAT_CHANNEL_WHISPER] = false,
            [CHAT_CHANNEL_GUILD_1] = false,
            [CHAT_CHANNEL_GUILD_2] = false,
            [CHAT_CHANNEL_GUILD_3] = false,
            [CHAT_CHANNEL_GUILD_4] = false,
            [CHAT_CHANNEL_GUILD_5] = false,
            [CHAT_CHANNEL_OFFICER_1] = false,
            [CHAT_CHANNEL_OFFICER_2] = false,
            [CHAT_CHANNEL_OFFICER_3] = false,
            [CHAT_CHANNEL_OFFICER_4] = false,
            [CHAT_CHANNEL_OFFICER_5] = false,
        },
    })

    -- Migrate any old global settings to the new per-server ones, if they're not already set up.
    if RV.vars.active == nil then
        RV.vars.active = true
        if RV.globals.active ~= nil then
            RV.vars.active = RV.globals.active
            RV.vars.activeChats = RV.globals.activeChats
        end
    end

    SetupCollectibleMappings()

    -- Set up Settings UI Panel
    RV.CreateSettingsPanel()

    RV.RegisterSlashCommands()

    if RV.vars.active then
        RV.Enable()
    end

    -- Hook up memento cooldown bar and restore saved position
    SecurePostHook("UseCollectible", ScheduleCollectibleUpdate)

    RVFrame:SetHandler("OnMoveStop", CollectibleBarOnMoveStop)

    if RV.vars.barX and RV.vars.barY then
        RVFrame:ClearAnchors()
        RVFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RV.vars.barX, RV.vars.barY)
    else
        RV.SetDefaultCollectibleBarPosition()
    end

    RV.barAlpha = RVFrameBar:GetAlpha()
    RV.barWidth = RVFrameBar:GetWidth()
    RVFrameBar:SetAlpha(0)
    RVFrameIcon:SetAlpha(0)

    local fragment = ZO_SimpleSceneFragment:New(RVFrame)
    SCENE_MANAGER:GetScene("hud"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(fragment)

    EVENT_MANAGER:RegisterForEvent(RV.name, EVENT_COLLECTIBLES_UNLOCK_STATE_CHANGED, function(_, ...) OnCollectiblesUnlockStateChanged(...) end)
end

-----------------------------------------------------------------------------
-- Add-on loading callback
-----------------------------------------------------------------------------
local function OnAddonLoaded(_, AddonName)
    if AddonName ~= RV.name then return end

    EVENT_MANAGER:UnregisterForEvent(RV.name, EVENT_ADD_ON_LOADED)
    RV.Initialize()
end

-- Register our add-on
EVENT_MANAGER:RegisterForEvent(RV.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
