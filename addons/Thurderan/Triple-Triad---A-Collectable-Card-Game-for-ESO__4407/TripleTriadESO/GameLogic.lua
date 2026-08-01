--[[
    Triple Triad ESO - Game Logic
    Implements the classic Triple Triad rules:
    - 3x3 board
    - Each card has 4 edge values (top, right, bottom, left)
    - Place card adjacent to opponent's card, compare touching edges
    - Higher edge value captures opponent's card (flips ownership)
    - Player with most cards on board (+ remaining hand) wins

    Advanced rules (can be toggled):
    - Same: If two or more adjacent edges match exactly, capture those cards
    - Plus: If the sum of touching edges equals on two or more sides, capture
    - Elemental: Board cells have elements that boost/reduce card values
]]--

local TT = TripleTriadESO

TT.GameLogic = {}
local GL = TT.GameLogic

-- ─────────────────────────────────────────────
-- Constants
-- ─────────────────────────────────────────────
GL.BOARD_SIZE = 3
GL.PLAYER = 1
GL.NPC = 2

-- Direction offsets: [dir] = { rowOffset, colOffset, oppositeEdge }
GL.DIRECTIONS = {
    top    = { -1,  0, "bottom" },
    right  = {  0,  1, "left"   },
    bottom = {  1,  0, "top"    },
    left   = {  0, -1, "right"  },
}

GL.EDGE_ORDER = { "top", "right", "bottom", "left" }

-- ─────────────────────────────────────────────
-- Game State
-- ─────────────────────────────────────────────
GL.gameActive = false
GL.currentTurn = GL.PLAYER  -- Player goes first
GL.board = {}               -- [row][col] = { card, owner }
GL.playerHand = {}          -- array of card objects
GL.npcHand = {}             -- array of card objects
GL.currentNPC = nil
GL.selectedCard = nil       -- index in playerHand
GL.turnCount = 0
GL.rules = {
    same = false,
    plus = false,
    elemental = false,
}

-- ─────────────────────────────────────────────
-- Start Game
-- ─────────────────────────────────────────────
function GL:StartGame(npc)
    self.currentNPC = npc
    self.gameActive = true
    self.turnCount = 0
    self.selectedCard = nil

    -- Random first turn
    if math.random(1, 2) == 1 then
        self.currentTurn = GL.PLAYER
    else
        self.currentTurn = GL.NPC
    end

    -- Initialize empty board
    self.board = {}
    for r = 1, GL.BOARD_SIZE do
        self.board[r] = {}
        for c = 1, GL.BOARD_SIZE do
            self.board[r][c] = nil
        end
    end

    -- Setup player hand from their deck
    self.playerHand = {}
    local deckCards = TT:GetDeckCards()
    for _, card in ipairs(deckCards) do
        table.insert(self.playerHand, {
            card = card,
            owner = GL.PLAYER,
            inHand = true,
        })
    end

    -- Setup NPC hand from their deck
    self.npcHand = {}
    for _, cardId in ipairs(npc.deck) do
        local card = TT:GetCard(cardId)
        if card then
            table.insert(self.npcHand, {
                card = card,
                owner = GL.NPC,
                inHand = true,
            })
        end
    end

    -- Determine rules based on NPC rank
    self.rules.same = (npc.rank >= 3)
    self.rules.plus = (npc.rank >= 4)
    self.rules.elemental = (npc.rank >= 5)

    -- Open game UI
    TT.UI:ShowGameBoard()

    local ruleStr = ""
    if self.rules.same then ruleStr = ruleStr .. " |cFFFF00[Same]|r" end
    if self.rules.plus then ruleStr = ruleStr .. " |cFF8800[Plus]|r" end
    if self.rules.elemental then ruleStr = ruleStr .. " |cFF00FF[Elemental]|r" end

    TT:Msg(string.format("|cFFD700[Triple Triad]|r Match started vs |cFF8800%s|r!%s", npc.name, ruleStr ~= "" and (" Rules:" .. ruleStr) or ""))

    if self.currentTurn == GL.PLAYER then
        TT:Msg("|cFFD700[Triple Triad]|r You go first! Select a card and place it on the board.")
    else
        TT:Msg(string.format("|cFFD700[Triple Triad]|r %s goes first!", npc.name))
        zo_callLater(function() self:NPCTurn() end, 1200)
    end
end

-- ─────────────────────────────────────────────
-- Place Card
-- ─────────────────────────────────────────────
function GL:PlaceCard(row, col, handIndex, isPlayer)
    if not self.gameActive then return false end
    if row < 1 or row > GL.BOARD_SIZE or col < 1 or col > GL.BOARD_SIZE then return false end
    if self.board[row][col] then return false end  -- Cell occupied

    local hand = isPlayer and self.playerHand or self.npcHand
    if handIndex < 1 or handIndex > #hand then return false end

    local entry = hand[handIndex]
    if not entry.inHand then return false end

    -- Place the card
    entry.inHand = false
    local placement = {
        card = entry.card,
        owner = isPlayer and GL.PLAYER or GL.NPC,
    }
    self.board[row][col] = placement

    -- Resolve captures
    local captured = self:ResolveCaptures(row, col, placement)

    self.turnCount = self.turnCount + 1

    if captured > 0 then
        local who = isPlayer and "You" or self.currentNPC.name
        TT:Msg(string.format("|cFFD700[Triple Triad]|r %s captured %d card%s!", who, captured, captured > 1 and "s" or ""))
    end

    -- Check for game end FIRST (board full = 9 cards placed)
    if self.turnCount >= 9 then
        -- Update the board visuals one last time before showing result
        TT.UI:UpdateGameBoard()
        -- Small delay so player can see the final board state
        zo_callLater(function() self:EndGame() end, 800)
        return true
    end

    -- Switch turns BEFORE updating UI so the indicator is correct
    if isPlayer then
        self.currentTurn = GL.NPC
    else
        self.currentTurn = GL.PLAYER
    end

    -- Now update UI (turn indicator will reflect new turn)
    TT.UI:UpdateGameBoard()

    -- NPC takes turn after delay
    if isPlayer then
        zo_callLater(function() self:NPCTurn() end, 1000)
    end

    return true
end

-- ─────────────────────────────────────────────
-- Capture Resolution
-- ─────────────────────────────────────────────
function GL:ResolveCaptures(row, col, placement)
    local totalCaptured = 0

    -- Standard captures
    totalCaptured = totalCaptured + self:ResolveStandardCaptures(row, col, placement)

    -- Same rule
    if self.rules.same then
        totalCaptured = totalCaptured + self:ResolveSameRule(row, col, placement)
    end

    -- Plus rule
    if self.rules.plus then
        totalCaptured = totalCaptured + self:ResolvePlusRule(row, col, placement)
    end

    return totalCaptured
end

function GL:ResolveStandardCaptures(row, col, placement)
    local captured = 0
    local placedCard = placement.card

    for dir, offsets in pairs(GL.DIRECTIONS) do
        local adjRow = row + offsets[1]
        local adjCol = col + offsets[2]
        local oppEdge = offsets[3]

        if adjRow >= 1 and adjRow <= GL.BOARD_SIZE and adjCol >= 1 and adjCol <= GL.BOARD_SIZE then
            local adjacent = self.board[adjRow][adjCol]
            if adjacent and adjacent.owner ~= placement.owner then
                local myValue = placedCard[dir]
                local theirValue = adjacent.card[oppEdge]

                if myValue > theirValue then
                    adjacent.owner = placement.owner
                    captured = captured + 1
                end
            end
        end
    end

    return captured
end

function GL:ResolveSameRule(row, col, placement)
    local captured = 0
    local placedCard = placement.card
    local sameMatches = {}

    for dir, offsets in pairs(GL.DIRECTIONS) do
        local adjRow = row + offsets[1]
        local adjCol = col + offsets[2]
        local oppEdge = offsets[3]

        if adjRow >= 1 and adjRow <= GL.BOARD_SIZE and adjCol >= 1 and adjCol <= GL.BOARD_SIZE then
            local adjacent = self.board[adjRow][adjCol]
            if adjacent then
                local myValue = placedCard[dir]
                local theirValue = adjacent.card[oppEdge]

                if myValue == theirValue then
                    table.insert(sameMatches, { row = adjRow, col = adjCol })
                end
            end
        end
    end

    -- Same rule requires 2+ matching edges
    if #sameMatches >= 2 then
        for _, match in ipairs(sameMatches) do
            local adjacent = self.board[match.row][match.col]
            if adjacent.owner ~= placement.owner then
                adjacent.owner = placement.owner
                captured = captured + 1
            end
        end
    end

    return captured
end

function GL:ResolvePlusRule(row, col, placement)
    local captured = 0
    local placedCard = placement.card
    local sumMatches = {} -- sum -> list of {row, col}

    for dir, offsets in pairs(GL.DIRECTIONS) do
        local adjRow = row + offsets[1]
        local adjCol = col + offsets[2]
        local oppEdge = offsets[3]

        if adjRow >= 1 and adjRow <= GL.BOARD_SIZE and adjCol >= 1 and adjCol <= GL.BOARD_SIZE then
            local adjacent = self.board[adjRow][adjCol]
            if adjacent then
                local myValue = placedCard[dir]
                local theirValue = adjacent.card[oppEdge]
                local sum = myValue + theirValue

                if not sumMatches[sum] then sumMatches[sum] = {} end
                table.insert(sumMatches[sum], { row = adjRow, col = adjCol })
            end
        end
    end

    -- Plus rule: if any sum has 2+ matches, capture those cards
    for _, matches in pairs(sumMatches) do
        if #matches >= 2 then
            for _, match in ipairs(matches) do
                local adjacent = self.board[match.row][match.col]
                if adjacent.owner ~= placement.owner then
                    adjacent.owner = placement.owner
                    captured = captured + 1
                end
            end
        end
    end

    return captured
end

-- ─────────────────────────────────────────────
-- NPC AI
-- ─────────────────────────────────────────────
function GL:NPCTurn()
    if not self.gameActive then return end
    if self.currentTurn ~= GL.NPC then return end

    local bestScore = -999
    local bestMove = nil
    local bestHandIndex = nil

    -- Evaluate all possible moves
    for i, entry in ipairs(self.npcHand) do
        if entry.inHand then
            for r = 1, GL.BOARD_SIZE do
                for c = 1, GL.BOARD_SIZE do
                    if not self.board[r][c] then
                        local score = self:EvaluateMove(r, c, entry.card, GL.NPC)
                        -- Add difficulty-based randomness
                        local npcRank = self.currentNPC and self.currentNPC.rank or 1
                        local randomFactor = 0
                        if npcRank <= 2 then
                            randomFactor = math.random(-3, 3)
                        elseif npcRank <= 3 then
                            randomFactor = math.random(-1, 1)
                        end
                        score = score + randomFactor

                        if score > bestScore then
                            bestScore = score
                            bestMove = { row = r, col = c }
                            bestHandIndex = i
                        end
                    end
                end
            end
        end
    end

    if bestMove and bestHandIndex then
        TT:Msg(string.format("|cFFD700[Triple Triad]|r %s plays |cFF8800%s|r!",
            self.currentNPC.name, self.npcHand[bestHandIndex].card.name))
        self:PlaceCard(bestMove.row, bestMove.col, bestHandIndex, false)
    end
end

function GL:EvaluateMove(row, col, card, owner)
    local score = 0

    for dir, offsets in pairs(GL.DIRECTIONS) do
        local adjRow = row + offsets[1]
        local adjCol = col + offsets[2]
        local oppEdge = offsets[3]

        if adjRow >= 1 and adjRow <= GL.BOARD_SIZE and adjCol >= 1 and adjCol <= GL.BOARD_SIZE then
            local adjacent = self.board[adjRow][adjCol]
            if adjacent then
                local myValue = card[dir]
                local theirValue = adjacent.card[oppEdge]

                if adjacent.owner ~= owner then
                    -- Can capture
                    if myValue > theirValue then
                        score = score + 10
                    elseif myValue == theirValue then
                        score = score + 1  -- Neutral
                    else
                        score = score - 5  -- Vulnerable to nothing, but expose weak side
                    end
                else
                    -- Adjacent to own card, prioritize defense
                    score = score + 1
                end
            else
                -- Empty adjacent cell — prefer placing strong edges toward edges of board
                if adjRow < 1 or adjRow > GL.BOARD_SIZE or adjCol < 1 or adjCol > GL.BOARD_SIZE then
                    -- Board edge, no threat
                    score = score + 0
                else
                    -- Open cell, prefer strong values facing it
                    score = score + (card[dir] >= 5 and 2 or 0)
                end
            end
        else
            -- Board edge — high values wasted here, low values safe
            local edgeValue = card[dir]
            if edgeValue <= 3 then
                score = score + 2  -- Good: weak side protected
            end
        end
    end

    -- Slight preference for center and corners
    if row == 2 and col == 2 then score = score + 3 end
    if (row == 1 or row == 3) and (col == 1 or col == 3) then score = score + 1 end

    return score
end

-- ─────────────────────────────────────────────
-- Player Action
-- ─────────────────────────────────────────────
function GL:PlayerSelectCard(handIndex)
    if not self.gameActive then return end
    if self.currentTurn ~= GL.PLAYER then
        TT:Msg("|cFFD700[Triple Triad]|r Wait for your turn!")
        return
    end
    if handIndex < 1 or handIndex > #self.playerHand then return end
    if not self.playerHand[handIndex].inHand then return end

    self.selectedCard = handIndex
    TT.UI:HighlightSelectedCard(handIndex)
end

function GL:PlayerPlaceCard(row, col)
    TT:Msg(string.format("|cFFD700[Triple Triad DEBUG]|r Cell clicked: row=%d col=%d active=%s turn=%s selected=%s",
        row, col,
        tostring(self.gameActive),
        tostring(self.currentTurn),
        tostring(self.selectedCard)))

    if not self.gameActive then
        TT:Msg("|cFFD700[Triple Triad DEBUG]|r BLOCKED: game not active")
        return
    end
    if self.currentTurn ~= GL.PLAYER then
        TT:Msg("|cFFD700[Triple Triad DEBUG]|r BLOCKED: not player turn")
        return
    end
    if not self.selectedCard then
        TT:Msg("|cFFD700[Triple Triad]|r Select a card from your hand first!")
        return
    end

    local success = self:PlaceCard(row, col, self.selectedCard, true)
    TT:Msg(string.format("|cFFD700[Triple Triad DEBUG]|r PlaceCard result: %s", tostring(success)))
    if success then
        self.selectedCard = nil
    end
end

-- ─────────────────────────────────────────────
-- End Game
-- ─────────────────────────────────────────────
function GL:EndGame()
    self.gameActive = false

    -- Count cards owned by each player on the board only
    local playerCount = 0
    local npcCount = 0

    for r = 1, GL.BOARD_SIZE do
        for c = 1, GL.BOARD_SIZE do
            local cell = self.board[r][c]
            if cell then
                if cell.owner == GL.PLAYER then
                    playerCount = playerCount + 1
                else
                    npcCount = npcCount + 1
                end
            end
        end
    end

    -- Determine winner
    local result
    if playerCount > npcCount then
        result = "win"
        TT.sv.wins = TT.sv.wins + 1
        TT.sv.npcDefeated[self.currentNPC.id] = true
        TT:Msg(string.format("|cFFD700[Triple Triad]|r |c00FF00VICTORY!|r You win %d to %d!", playerCount, npcCount))
        self:GrantReward()
    elseif npcCount > playerCount then
        result = "loss"
        TT.sv.losses = TT.sv.losses + 1
        TT:Msg(string.format("|cFFD700[Triple Triad]|r |cFF4444DEFEAT!|r You lose %d to %d.", playerCount, npcCount))
    else
        result = "draw"
        TT.sv.draws = TT.sv.draws + 1
        TT:Msg(string.format("|cFFD700[Triple Triad]|r |cFFFF00DRAW!|r %d to %d.", playerCount, npcCount))
    end

    -- Track per-NPC stats
    if self.currentNPC and self.currentNPC.name then
        local npcName = self.currentNPC.name
        if not TT.sv.npcStats then TT.sv.npcStats = {} end
        if not TT.sv.npcStats[npcName] then
            TT.sv.npcStats[npcName] = { wins = 0, losses = 0, draws = 0 }
        end
        local s = TT.sv.npcStats[npcName]
        if result == "win" then s.wins = s.wins + 1
        elseif result == "loss" then s.losses = s.losses + 1
        else s.draws = s.draws + 1 end
    end

    -- Show result in UI
    TT.UI:ShowGameResult(result, playerCount, npcCount)

    -- Track plays and set cooldown after MAX_REPLAYS games
    if self.currentNPC and self.currentNPC.name then
        local cooldownKey = string.lower(self.currentNPC.name)
        local cd = TT.npcCooldowns[cooldownKey] or { plays = 0, cooldownEnd = nil }
        cd.plays = cd.plays + 1
        if cd.plays >= (TT.MAX_REPLAYS or 3) then
            cd.cooldownEnd = GetGameTimeMilliseconds() + 300000  -- 5 minutes
        end
        TT.npcCooldowns[cooldownKey] = cd
    end
end

-- ─────────────────────────────────────────────
-- Rewards — win = 1 random card from NPC's hand
-- ─────────────────────────────────────────────
function GL:GrantReward()
    if not self.currentNPC then return end

    -- Pick a random card from the NPC's actual hand (the 5 cards they played with)
    local npcCards = {}
    for _, entry in ipairs(self.npcHand) do
        if entry.card then
            table.insert(npcCards, entry.card.id)
        end
    end

    if #npcCards == 0 then return end

    local rewardCardId = npcCards[math.random(1, #npcCards)]
    TT:CollectCard(rewardCardId)
end

-- ─────────────────────────────────────────────
-- Forfeit
-- ─────────────────────────────────────────────
function GL:Forfeit()
    if not self.gameActive then return end
    self.gameActive = false
    TT.sv.losses = TT.sv.losses + 1
    TT:Msg("|cFFD700[Triple Triad]|r You forfeited the match.")
    TT.UI:HideGameBoard()
end

-- ─────────────────────────────────────────────
-- Get Board State (for UI)
-- ─────────────────────────────────────────────
function GL:GetBoardState()
    return self.board
end

function GL:GetPlayerHand()
    return self.playerHand
end

function GL:GetNPCHand()
    return self.npcHand
end

function GL:IsPlayerTurn()
    return self.currentTurn == GL.PLAYER
end
