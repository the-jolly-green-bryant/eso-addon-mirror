CardCombo = CardCombo or {}
local CardCombo = CardCombo

CardCombo.ADDON_NAME = "CardCombo"
CardCombo.DISPLAY_NAME = "Card Combo"

CardCombo.ROWS = 4
CardCombo.COLS = 4
CardCombo.CARD_COUNT = CardCombo.ROWS * CardCombo.COLS
CardCombo.BASE_MOVES = 4
CardCombo.MOVE_LIMIT = CardCombo.BASE_MOVES

CardCombo.SAVED_VAR_VERSION = 1
CardCombo.SAVED_VAR_DEFAULTS = {
    bestScore = 0,
    game = nil,
    window = {
        x = nil,
        y = nil,
    },
}

local ADDON_NAME = CardCombo.ADDON_NAME
local SAVED_VAR_VERSION = CardCombo.SAVED_VAR_VERSION
local SAVED_VAR_DEFAULTS = CardCombo.SAVED_VAR_DEFAULTS
local ROWS = CardCombo.ROWS
local COLS = CardCombo.COLS
local CARD_COUNT = CardCombo.CARD_COUNT
local BASE_MOVES = CardCombo.BASE_MOVES
local MOVE_LIMIT = CardCombo.MOVE_LIMIT
local MATCH_LENGTH = 4
local CLEAR_HOLD_MS = 325
local REFILL_HOLD_MS = 150
local MAX_CASCADE_STEPS = 12

-- Small local game helpers
local function IsPositiveInteger(value)
    return type(value) == "number" and value >= 1 and value == math.floor(value)
end

-- Save and restore logic
function CardCombo:SerializeBoard()
    if not self.board then
        return nil
    end

    local serializedBoard = {}

    for index = 1, CARD_COUNT do
        local card = self.board[index]

        if not card or not IsPositiveInteger(card.value) then
            return nil
        end

        serializedBoard[index] = card.value
    end

    return serializedBoard
end

function CardCombo:IsSavedGameValid(savedGame)
    if type(savedGame) ~= "table" or type(savedGame.board) ~= "table" then
        return false
    end

    if type(savedGame.score) ~= "number" or savedGame.score < 0 then
        return false
    end

    if type(savedGame.moves) ~= "number" or savedGame.moves < 0 or savedGame.moves > MOVE_LIMIT then
        return false
    end

    if type(savedGame.gameOver) ~= "boolean" then
        return false
    end

    if savedGame.gameOver or savedGame.moves <= 0 then
        return false
    end

    for index = 1, CARD_COUNT do
        if not IsPositiveInteger(savedGame.board[index]) then
            return false
        end
    end

    return true
end

function CardCombo:SaveGameState()
    if self.resolving or self.gameOver then
        return
    end

    local serializedBoard = self:SerializeBoard()

    if not serializedBoard then
        return
    end

    self.saved.game = {
        board = serializedBoard,
        score = self.score or 0,
        moves = self.moves or BASE_MOVES,
        gameOver = false,
    }
end

function CardCombo:RestoreGame()
    local savedGame = self.saved and self.saved.game or nil

    if not self:IsSavedGameValid(savedGame) then
        return false
    end

    self.resolveToken = (self.resolveToken or 0) + 1
    self.score = savedGame.score
    self.moves = savedGame.moves
    self.gameOver = savedGame.gameOver
    self.resolving = false
    self.board = {}

    for index = 1, CARD_COUNT do
        self.board[index] = {
            value = savedGame.board[index],
        }
    end

    -- Restored boards should match the same stable state expected from fresh boards.
    if #self:FindMatchingGroups() > 0 then
        self.saved.game = nil
        self.board = nil
        return false
    end

    self:Refresh()
    return true
end

-- Board math and matching logic
function CardCombo:Index(row, col)
    return ((row - 1) * COLS) + col
end

function CardCombo:RowCol(index)
    local row = math.floor((index - 1) / COLS) + 1
    local col = ((index - 1) % COLS) + 1
    return row, col
end

function CardCombo:InBounds(row, col)
    return row >= 1 and row <= ROWS and col >= 1 and col <= COLS
end

function CardCombo:GetNeighbors(index)
    local row, col = self:RowCol(index)
    local neighbors = {}
    local deltas = {
        { -1, 0 },
        { 1,  0 },
        { 0,  -1 },
        { 0,  1 },
    }

    for i = 1, #deltas do
        local nextRow = row + deltas[i][1]
        local nextCol = col + deltas[i][2]

        if self:InBounds(nextRow, nextCol) then
            neighbors[#neighbors + 1] = self:Index(nextRow, nextCol)
        end
    end

    return neighbors
end

function CardCombo:GetHighSpawnValue()
    local score = self.score or 0

    if score >= 1200 then
        return 7
    end

    if score >= 500 then
        return 6
    end

    return 5
end

function CardCombo:NewCard()
    return {
        value = math.random(1, self:GetHighSpawnValue()),
    }
end

function CardCombo:CardMatchesTarget(card, targetValue)
    if not card then
        return false
    end

    return card.value == targetValue
end

function CardCombo:GetTargetValues()
    local values = {}
    local seen = {}

    for index = 1, CARD_COUNT do
        local card = self.board[index]

        if card and not seen[card.value] then
            seen[card.value] = true
            values[#values + 1] = card.value
        end
    end

    return values
end

function CardCombo:FindMatchingGroups()
    local groups = {}
    local targets = self:GetTargetValues()

    for targetIndex = 1, #targets do
        local targetValue = targets[targetIndex]
        local visited = {}

        for startIndex = 1, CARD_COUNT do
            if not visited[startIndex] and self:CardMatchesTarget(self.board[startIndex], targetValue) then
                local queue = { startIndex }
                local head = 1
                local cells = {}

                visited[startIndex] = true

                while head <= #queue do
                    local currentIndex = queue[head]

                    head = head + 1
                    cells[#cells + 1] = currentIndex

                    local neighbors = self:GetNeighbors(currentIndex)
                    for i = 1, #neighbors do
                        local neighborIndex = neighbors[i]

                        if not visited[neighborIndex]
                            and self:CardMatchesTarget(self.board[neighborIndex], targetValue)
                        then
                            visited[neighborIndex] = true
                            queue[#queue + 1] = neighborIndex
                        end
                    end
                end

                if #cells >= MATCH_LENGTH then
                    groups[#groups + 1] = {
                        value = targetValue,
                        cells = cells,
                    }
                end
            end
        end
    end

    return groups
end

function CardCombo:FillBoard()
    for index = 1, CARD_COUNT do
        if not self.board[index] then
            self.board[index] = self:NewCard()
        end
    end
end

function CardCombo:BuildFreshBoard()
    for tries = 1, 80 do
        self.board = {}

        for index = 1, CARD_COUNT do
            self.board[index] = self:NewCard()
        end

        if #self:FindMatchingGroups() == 0 then
            return
        end
    end

    for tries = 1, 120 do
        local groups = self:FindMatchingGroups()

        if #groups == 0 then
            return
        end

        for i = 1, #groups do
            local group = groups[i]
            local index = group.cells[math.random(1, #group.cells)]
            self.board[index] = {
                value = math.random(1, self:GetHighSpawnValue()),
            }
        end
    end

    local highSpawnValue = self:GetHighSpawnValue()

    for index = 1, CARD_COUNT do
        local row, col = self:RowCol(index)
        self.board[index] = {
            value = ((row * 2 + col) % highSpawnValue) + 1,
        }
    end
end

-- Scoring and resolve flow
function CardCombo:ScoreMarkedCells(marked)
    local score = 0

    for index in pairs(marked) do
        local card = self.board[index]

        if card and card.value then
            score = score + card.value
        end
    end

    return score
end

function CardCombo:UpdateBestScore()
    self.saved.bestScore = self.saved.bestScore or 0

    if (self.score or 0) > self.saved.bestScore then
        self.saved.bestScore = self.score or 0
    end
end

function CardCombo:FinishResolve(totalScore)
    self.resolving = false
    self.score = self.score + totalScore
    self.moves = BASE_MOVES
    self:UpdateBestScore()
    self:SaveGameState()

    self:Refresh()
end

function CardCombo:ResolveMatchStep(token, chain, totalScore, pendingGroups)
    if token ~= self.resolveToken then
        return
    end

    local groups = pendingGroups or self:FindMatchingGroups()

    if #groups == 0 or chain > MAX_CASCADE_STEPS then
        self:FinishResolve(totalScore)
        return
    end

    local marked = {}

    for i = 1, #groups do
        local group = groups[i]

        for j = 1, #group.cells do
            marked[group.cells[j]] = true
        end
    end

    local chainScore = self:ScoreMarkedCells(marked)

    for index in pairs(marked) do
        if self.board[index] then
            self.board[index] = nil
        end
    end

    PlaySound(SOUNDS.ITEM_MONEY_CHANGED)
    totalScore = totalScore + chainScore

    self:Refresh()

    zo_callLater(function()
        if token ~= self.resolveToken then
            return
        end

        self:FillBoard()
        self:Refresh()

        zo_callLater(function()
            self:ResolveMatchStep(token, chain + 1, totalScore)
        end, REFILL_HOLD_MS)
    end, CLEAR_HOLD_MS)
end

function CardCombo:ResolveMatches()
    local groups = self:FindMatchingGroups()

    if #groups == 0 then
        return false
    end

    self.resolving = true
    self.resolveToken = (self.resolveToken or 0) + 1
    self:ResolveMatchStep(self.resolveToken, 1, 0, groups)

    return true
end

-- Turn flow and game state
function CardCombo:ClickCard(index)
    if self.resolving then
        return
    end

    if self.gameOver then
        return
    end

    local card = self.board[index]

    if not card then
        return
    end

    if self.moves <= 0 then
        return
    end

    self.moves = self.moves - 1
    card.value = card.value + 1

    local matched = self:ResolveMatches()

    if matched then
        return
    end

    if self.moves <= 0 then
        self:EndGame()
    else
        self:SaveGameState()
        self:Refresh()
    end
end

function CardCombo:EndGame()
    self.gameOver = true
    PlaySound(SOUNDS.QUEST_STEP_FAILED)

    self:UpdateBestScore()
    self.saved.game = nil

    self:Refresh()
end

function CardCombo:NewGame()
    self.resolveToken = (self.resolveToken or 0) + 1
    self.score = 0
    self.moves = BASE_MOVES
    self.gameOver = false
    self.resolving = false
    self:BuildFreshBoard()
    self:SaveGameState()
    self:Refresh()
end

-- Initialization
function CardCombo:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("CardComboSavedVariables", SAVED_VAR_VERSION, GetWorldName(),
        SAVED_VAR_DEFAULTS)
    self.saved.bestScore = self.saved.bestScore or 0
    self.saved.window = self.saved.window or {}

    math.randomseed(GetTimeStamp())
    self:CreateUI()

    if not self:RestoreGame() then
        self:NewGame()
    end

    SLASH_COMMANDS["/cardcombo"] = function()
        self:Toggle()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    CardCombo:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
