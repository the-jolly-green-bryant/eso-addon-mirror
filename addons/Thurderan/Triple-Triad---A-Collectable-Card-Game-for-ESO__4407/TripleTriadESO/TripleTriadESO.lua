--[[
    Triple Triad ESO
    A Triple Triad card game addon for The Elder Scrolls Online
    Author: LogisticsDude
    Version: 1.0.0
    API Version: 101048 (Update 48)
]]--

TripleTriadESO = TripleTriadESO or {}
local TT = TripleTriadESO

TT.name = "TripleTriadESO"
TT.version = "1.0.0"
TT.apiVersion = 101048
TT.savedVarsVersion = 1

-- Default saved variables
TT.defaults = {
    collectedCards = {},       -- card IDs the player owns
    wins = 0,
    losses = 0,
    draws = 0,
    chatMessages = true,           -- toggle chat messages on/off
    npcDefeated = {},          -- npcId = true/false
    npcStats = {},             -- npcName = { wins = N, losses = N, draws = N }
    cardMultiples = {},        -- cardId = count (how many copies owned)
    firstRun = true,
    selectedDeck = { 1, 2, 3, 4, 5 }, -- 5-card deck by card ID
    difficulty = "normal",     -- "easy", "normal", "hard"
    soundEnabled = true,
    showTutorial = true,
}

-- ─────────────────────────────────────────────
-- Initialization
-- ─────────────────────────────────────────────
function TT:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("TripleTriadESO_SavedVars", self.savedVarsVersion, nil, self.defaults)

    -- Give starter cards on first run
    if self.sv.firstRun then
        self:GrantStarterCards()
        self.sv.firstRun = false
    end

    -- Build lookup tables
    self:BuildCardLookup()
    self:BuildNPCLookup()

    -- Cooldown tracker (not saved — resets on reload/relog)
    -- Each entry: { plays = N, cooldownEnd = timestamp or nil }
    self.npcCooldowns = {}
    self.MAX_REPLAYS = 3  -- games before cooldown kicks in

    -- Seed RNG with game time so coin flips are actually random
    math.randomseed(GetGameTimeMilliseconds())
    math.random(); math.random(); math.random()  -- discard first few values

    -- Initialize UI
    TT.UI:Initialize()

    -- Register slash commands
    SLASH_COMMANDS["/tt"] = function(args) self:HandleSlashCommand(args) end
    SLASH_COMMANDS["/tripletriad"] = function(args) self:HandleSlashCommand(args) end
    SLASH_COMMANDS["/triad"] = function(args) self:HandleSlashCommand(args) end

    d("|cFFD700[Triple Triad ESO]|r v" .. self.version .. " loaded! Use |cFFFFFF/tt|r to open your collection, or target an NPC and use |cFFFFFF/tt play|r to challenge them.")
end

-- Chat message helper - respects quiet mode
function TT:Msg(text)
    if self.sv and self.sv.chatMessages then d(text) end
end

-- ─────────────────────────────────────────────
-- Starter Cards
-- ─────────────────────────────────────────────
function TT:GrantStarterCards()
    -- Grant 5 basic starter cards
    local starterIds = { 1, 2, 3, 4, 5 }
    for _, id in ipairs(starterIds) do
        self.sv.collectedCards[id] = true
        self.sv.cardMultiples[id] = (self.sv.cardMultiples[id] or 0) + 1
    end
    self.sv.selectedDeck = { 1, 2, 3, 4, 5 }
end

-- ─────────────────────────────────────────────
-- Lookup Tables
-- ─────────────────────────────────────────────
function TT:BuildCardLookup()
    self.cardLookup = {}
    for _, card in ipairs(TT.CardDatabase) do
        self.cardLookup[card.id] = card
    end
end

function TT:BuildNPCLookup()
    self.npcLookup = {}
    self.npcNameLookup = {}
    for _, npc in ipairs(TT.NPCDatabase) do
        self.npcLookup[npc.id] = npc
        -- Normalize name to lowercase for matching
        self.npcNameLookup[string.lower(npc.name)] = npc
    end
end

-- ─────────────────────────────────────────────
-- Card Helpers
-- ─────────────────────────────────────────────
function TT:GetCard(cardId)
    return self.cardLookup[cardId]
end

function TT:HasCard(cardId)
    return self.sv.collectedCards[cardId] == true
end

function TT:CollectCard(cardId)
    if not self.cardLookup[cardId] then return false end
    self.sv.collectedCards[cardId] = true
    self.sv.cardMultiples[cardId] = (self.sv.cardMultiples[cardId] or 0) + 1
    local card = self.cardLookup[cardId]
    if card then
        TT:Msg(string.format("|cFFD700[Triple Triad]|r You obtained the |c00FF00%s|r card! (★%d)", card.name, card.stars))
    end
    return true
end

function TT:GetCollectedCards()
    local cards = {}
    for id, owned in pairs(self.sv.collectedCards) do
        if owned and self.cardLookup[id] then
            table.insert(cards, self.cardLookup[id])
        end
    end
    table.sort(cards, function(a, b) return a.id < b.id end)
    return cards
end

function TT:GetCollectedCount()
    local count = 0
    for id, owned in pairs(self.sv.collectedCards) do
        if owned then count = count + 1 end
    end
    return count
end

function TT:GetDeckCards()
    local deck = {}
    for _, cardId in ipairs(self.sv.selectedDeck) do
        local card = self.cardLookup[cardId]
        if card and self:HasCard(cardId) then
            table.insert(deck, card)
        end
    end
    return deck
end

function TT:SetDeckCard(slot, cardId)
    if slot < 1 or slot > 5 then return false end
    if not self:HasCard(cardId) then return false end
    -- Prevent duplicates in deck
    for i, id in ipairs(self.sv.selectedDeck) do
        if id == cardId and i ~= slot then
            return false
        end
    end
    self.sv.selectedDeck[slot] = cardId
    return true
end

-- ─────────────────────────────────────────────
-- NPC Targeting & Challenge (Dynamic — any NPC)
-- ─────────────────────────────────────────────
function TT:GetTargetAsOpponent()
    local unitTag = "reticleover"
    if not DoesUnitExist(unitTag) then return nil end
    if IsUnitPlayer(unitTag) then return nil end

    -- Reject hostile units, attackable creatures, and dead units
    local reaction = GetUnitReaction(unitTag)
    if reaction == UNIT_REACTION_HOSTILE then return nil end
    if IsUnitAttackable(unitTag) then return nil end
    if IsUnitDead(unitTag) then return nil end

    local name = GetUnitName(unitTag)
    if not name or name == "" then return nil end

    -- Get current zone
    local zoneName = GetZoneNameByIndex(GetCurrentMapZoneIndex())
    if not zoneName or zoneName == "" then
        zoneName = GetPlayerActiveZoneName()
    end

    -- Look up zone data for difficulty and card pool
    local zoneInfo = TT.ZoneData.GetZoneInfo(zoneName)
    if not zoneInfo then
        -- Unknown zone — use a sensible default
        zoneInfo = TT.ZoneData.GetDefaultZoneInfo()
    end

    -- Build a dynamic NPC opponent
    local rank = zoneInfo.rank
    local deck = TT.ZoneData.BuildNPCDeck(zoneInfo)
    local rankName = TT.ZoneData.GetRankName(rank)

    -- Build dialogue from a pool of generic lines
    local dialogues = {
        [1] = {
            "A card game? I suppose I have time for a quick round.",
            "You want to play cards? Very well, but don't expect me to go easy!",
            "Cards? Sure, I could use a break from my duties.",
            "Ha! I've been looking for someone to play against!",
        },
        [2] = {
            "You dare challenge me to a card game? Interesting...",
            "I've won a few games in my time. Let's see what you've got.",
            "A game of Triple Triad? You have my attention, traveler.",
            "Cards, eh? I'm better than I look. Prepare yourself!",
        },
        [3] = {
            "You wish to test your skill against me? Bold.",
            "Very well. But know that I've bested many challengers.",
            "A worthy distraction. Let us play.",
            "I accept your challenge. Don't disappoint me.",
        },
        [4] = {
            "Few dare challenge someone of my experience. Intriguing.",
            "You've chosen a formidable opponent. Let's begin.",
            "My collection is impressive. Think you can match it?",
            "This should be entertaining. Show me what you have.",
        },
        [5] = {
            "You challenge a master? Your courage outweighs your wisdom.",
            "I have defeated every challenger who stood before me.",
            "The cards themselves tremble at my approach. Begin.",
            "Only the bold or the foolish challenge me. Which are you?",
        },
    }

    local rankDialogues = dialogues[rank] or dialogues[1]
    local dialogue = rankDialogues[math.random(1, #rankDialogues)]

    local npc = {
        id = "dynamic_" .. string.lower(name):gsub("%s+", "_"),
        name = name,
        zone = zoneName or "Unknown",
        rank = rank,
        deck = deck,
        rewardPool = deck,  -- reward is any card from their deck
        dialogue = dialogue,
        isDynamic = true,    -- flag for the reward system
    }

    return npc
end

function TT:ChallengeTarget()
    local npc = self:GetTargetAsOpponent()
    if not npc then
        local unitTag = "reticleover"
        if DoesUnitExist(unitTag) and not IsUnitPlayer(unitTag) then
            local reaction = GetUnitReaction(unitTag)
            if reaction == UNIT_REACTION_HOSTILE or IsUnitAttackable(unitTag) then
                TT:Msg("|cFFD700[Triple Triad]|r |cFF4444You can't challenge enemies or creatures|r — find a friendly NPC!")
            else
                TT:Msg("|cFFD700[Triple Triad]|r You need to target an NPC to challenge them!")
            end
        else
            TT:Msg("|cFFD700[Triple Triad]|r You need to target an NPC to challenge them!")
        end
        return
    end

    -- Check cooldown (3 games allowed, then 5-minute cooldown)
    local cooldownKey = string.lower(npc.name)
    local now = GetGameTimeMilliseconds()
    local cd = self.npcCooldowns[cooldownKey]
    if cd and cd.cooldownEnd and now < cd.cooldownEnd then
        local remaining = math.ceil((cd.cooldownEnd - now) / 1000)
        local mins = math.floor(remaining / 60)
        local secs = remaining % 60
        TT:Msg(string.format("|cFFD700[Triple Triad]|r |cFF4444%s|r needs a break. Try again in |cFFFFFF%d:%02d|r.", npc.name, mins, secs))
        return
    end
    -- Reset if cooldown expired
    if cd and cd.cooldownEnd and now >= cd.cooldownEnd then
        self.npcCooldowns[cooldownKey] = nil
    end

    -- Check if player has enough cards for a deck
    local deckCards = self:GetDeckCards()
    if #deckCards < 5 then
        TT:Msg("|cFFD700[Triple Triad]|r You need at least 5 cards in your deck to play! Use |cFFFFFF/tt deck|r to manage your deck.")
        return
    end

    -- Show challenge info
    local rankName = TT.ZoneData.GetRankName(npc.rank)
    TT:Msg(string.format("|cFFD700[Triple Triad]|r Challenging |cFF8800%s|r — %s (Rank %d) from %s!",
        npc.name, rankName, npc.rank, npc.zone))
    if npc.dialogue then
        TT:Msg(string.format("|cFF8800%s|r: \"%s\"", npc.name, npc.dialogue))
    end

    TT.GameLogic:StartGame(npc)
end

-- ─────────────────────────────────────────────
-- Slash Command Handler
-- ─────────────────────────────────────────────
function TT:HandleSlashCommand(args)
    local cmd = string.lower(args or "")
    cmd = cmd:match("^%s*(.-)%s*$") -- trim whitespace

    if cmd == "" or cmd == "collection" or cmd == "cards" then
        TT.UI:ToggleCollection()
    elseif cmd == "play" or cmd == "challenge" then
        self:ChallengeTarget()
    elseif cmd == "deck" then
        TT.UI:ToggleDeckBuilder()
    elseif cmd == "stats" then
        self:ShowStats()
    elseif cmd == "rules" or cmd == "help me" or cmd == "howto" then
        TT.UI:ToggleRules()
    elseif cmd == "help" then
        self:ShowHelp()
    elseif cmd == "quiet" or cmd == "silent" then
        self.sv.chatMessages = not self.sv.chatMessages
        if self.sv.chatMessages then
            d("|cFFD700[Triple Triad]|r Chat messages |c00FF00enabled|r.")
        else
            d("|cFFD700[Triple Triad]|r Chat messages |cFF4444disabled|r. Use |cFFFFFF/tt quiet|r to re-enable.")
        end
    elseif string.sub(cmd, 1, 4) == "test" then
        self:StartTestMatch(cmd)
    else
        d("|cFFD700[Triple Triad]|r Unknown command. Use |cFFFFFF/tt help|r for a list of commands.")
    end
end

function TT:ShowStats()
    TT.UI:ToggleStats()
end

function TT:ShowHelp()
    d("|cFFD700═══════════════════════════════════════|r")
    d("|cFFD700   Triple Triad ESO - Commands|r")
    d("|cFFD700═══════════════════════════════════════|r")
    d("  |cFFFFFF/tt|r            - Open card collection")
    d("  |cFFFFFF/tt play|r       - Challenge targeted NPC")
    d("  |cFFFFFF/tt deck|r       - Open deck builder")
    d("  |cFFFFFF/tt stats|r      - Show your statistics")
    d("  |cFFFFFF/tt rules|r      - How to play / rules guide")
    d("  |cFFFFFF/tt quiet|r      - Toggle chat messages on/off")
    d("  |cFFFFFF/tt test|r       - Start a test match (Rank 1)")
    d("  |cFFFFFF/tt test 3|r     - Test match at specific rank (1-5)")
    d("  |cFFFFFF/tt test all|r   - Unlock all cards for testing")
    d("  |cFFFFFF/tt test reset|r - Reset save data to defaults")
    d("  |cFFFFFF/tt help|r       - Show this help")
    d("|cFFD700═══════════════════════════════════════|r")
end

-- ─────────────────────────────────────────────
-- Test / Debug Commands
-- ─────────────────────────────────────────────
function TT:StartTestMatch(cmd)
    local arg = cmd:match("^test%s*(.-)%s*$") or ""

    -- /tt test all — unlock every card
    if arg == "all" then
        local count = 0
        for _, card in ipairs(TT.CardDatabase) do
            if not self.sv.collectedCards[card.id] then
                self.sv.collectedCards[card.id] = true
                self.sv.cardMultiples[card.id] = (self.sv.cardMultiples[card.id] or 0) + 1
                count = count + 1
            end
        end
        d(string.format("|cFFD700[Triple Triad TEST]|r Unlocked |c00FF00%d|r new cards! You now have all %d cards.", count, #TT.CardDatabase))
        return
    end

    -- /tt test reset — wipe saved data
    if arg == "reset" then
        self.sv.collectedCards = {}
        self.sv.cardMultiples = {}
        self.sv.wins = 0
        self.sv.losses = 0
        self.sv.draws = 0
        self.sv.npcDefeated = {}
        self.sv.selectedDeck = { 1, 2, 3, 4, 5 }
        self.sv.firstRun = false
        self:GrantStarterCards()
        d("|cFFD700[Triple Triad TEST]|r Save data reset! Starter cards re-granted.")
        return
    end

    -- /tt test [rank] — play a test match
    local rank = tonumber(arg)
    if not rank or rank < 1 or rank > 5 then
        rank = 1
    end

    -- Make sure the player has enough cards for a deck
    local deckCards = self:GetDeckCards()
    if #deckCards < 5 then
        d("|cFFD700[Triple Triad TEST]|r Not enough cards in your deck. Granting starter cards...")
        self:GrantStarterCards()
        self:BuildCardLookup()
        deckCards = self:GetDeckCards()
        if #deckCards < 5 then
            d("|cFFD700[Triple Triad TEST]|r Still not enough cards. Use |cFFFFFF/tt test all|r to unlock everything, then |cFFFFFF/tt deck|r to pick 5.")
            return
        end
    end

    -- Build a dynamic test NPC at the requested rank
    local testZones = {
        [1] = { rank = 1, cards = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 } },
        [2] = { rank = 2, cards = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24 } },
        [3] = { rank = 3, cards = { 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36 } },
        [4] = { rank = 4, cards = { 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44 } },
        [5] = { rank = 5, cards = { 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50 } },
    }

    local zoneInfo = testZones[rank]
    local deck = TT.ZoneData.BuildNPCDeck(zoneInfo)
    local rankName = TT.ZoneData.GetRankName(rank)

    local testNames = { "Pacrooti", "Razum-dar", "Abnur Tharn", "Mannimarco", "Sheogorath" }
    local testNPC = {
        id = "test_rank_" .. rank,
        name = testNames[rank] or "Test Opponent",
        zone = "Test Arena",
        rank = rank,
        deck = deck,
        rewardPool = deck,
        dialogue = "This is a test match!",
        isDynamic = true,
    }

    d("|cFFD700[Triple Triad TEST]|r Starting test match...")
    d(string.format("|cFFD700[Triple Triad TEST]|r Opponent: |cFF8800%s|r — %s (Rank %d)", testNPC.name, rankName, rank))

    TT.GameLogic:StartGame(testNPC)
end

-- ─────────────────────────────────────────────
-- Event Registration
-- ─────────────────────────────────────────────
local function OnAddonLoaded(_, addonName)
    if addonName ~= TT.name then return end
    EVENT_MANAGER:UnregisterForEvent(TT.name, EVENT_ADD_ON_LOADED)
    TT:Initialize()
end

-- ─────────────────────────────────────────────
-- Global Keybind Handlers (called from bindings.xml)
-- ─────────────────────────────────────────────
function TT_OnChallengeKeybind()
    TripleTriadESO:ChallengeTarget()
end

function TT_OnCollectionKeybind()
    TripleTriadESO.UI:ToggleCollection()
end

function TT_OnDeckKeybind()
    TripleTriadESO.UI:ToggleDeckBuilder()
end

-- Register keybinding strings for the Controls menu
ZO_CreateStringId("SI_BINDING_NAME_TT_CHALLENGE_NPC", "Challenge NPC")
ZO_CreateStringId("SI_BINDING_NAME_TT_OPEN_COLLECTION", "Open Collection")
ZO_CreateStringId("SI_BINDING_NAME_TT_OPEN_DECK", "Open Deck Builder")

-- Register addon
EVENT_MANAGER:RegisterForEvent(TT.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
