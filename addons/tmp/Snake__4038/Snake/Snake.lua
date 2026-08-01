SnakeGame = SnakeGame or {}
SnakeGame.name = "SnakeGame"
SnakeGame.version = "1.2"
SnakeGame.author = "TheMrPancake"
SnakeGame.gameBoard = {}
SnakeGame.snake = {}
SnakeGame.direction = ""
SnakeGame.food = {}
SnakeGame.textures = {}
SnakeGame.textures_created = false
SnakeGame.active = false
SnakeGame.defaults = {
    highscore = 0,
    total_earned = 0,
}
SnakeGame.timer = 0
SnakeGame.timer_total = 0
SnakeGame.directionQueue = {}

local BOARD_SIZE = 25
local CELL_SIZE = 32
local PADDING = 4
local HEAD_COLOUR = {0, 1, 0}
local BODY_COLOUR = {0, 0.5, 0}

local function InitializeGameBoard()
    for i = 1, BOARD_SIZE do
        SnakeGame.gameBoard[i] = {}
        for j = 1, BOARD_SIZE do
            SnakeGame.gameBoard[i][j] = 0
        end
    end
end

local function CreateGameBoardTextures()
    for i = 1, BOARD_SIZE do
        SnakeGame.textures[i] = {}
        for j = 1, BOARD_SIZE do
            local texture = WINDOW_MANAGER:CreateControl(nil, SnakeGameTopLevelControl, CT_TEXTURE)
            texture:SetDimensions(CELL_SIZE, CELL_SIZE)
            texture:SetAnchor(TOPLEFT, SnakeGameTopLevelControl, TOPLEFT, (i - 1) * CELL_SIZE + PADDING, (j - 1) * CELL_SIZE + PADDING)
            SnakeGame.textures[i][j] = texture
        end
    end
end

local function InterpolateColor(color1, color2, t)
    return {
        color1[1] + (color2[1] - color1[1]) * t,
        color1[2] + (color2[2] - color1[2]) * t,
        color1[3] + (color2[3] - color1[3]) * t,
    }
end

local function UpdateGameBoardTextures()
    for i = 1, BOARD_SIZE do
        for j = 1, BOARD_SIZE do
            local texture = SnakeGame.textures[i][j]
            if SnakeGame.gameBoard[i][j] == 0 then
                texture:SetColor() -- Empty space
            elseif SnakeGame.gameBoard[i][j] == 1 then
                texture:SetColor(0, 1, 0, 1) -- Snake
            elseif SnakeGame.gameBoard[i][j] == 2 then
                texture:SetColor(1, 0, 0, 1) -- Food
            end
        end
    end
    for index, segment in ipairs(SnakeGame.snake) do
        local t = (index - 1) / (#SnakeGame.snake - 1)
        local color = InterpolateColor(HEAD_COLOUR, BODY_COLOUR, t)
        local texture = SnakeGame.textures[segment.x][segment.y]
        texture:SetColor(unpack(color))
    end
end

local function SpawnSnake()
    SnakeGame.snake = {
        {x = 10, y = 10},
        {x = 10, y = 9},
        {x = 10, y = 8}
    }
    for _, segment in ipairs(SnakeGame.snake) do
        SnakeGame.gameBoard[segment.x][segment.y] = 1
    end
end

local function SpawnFood()
    local x, y
    repeat
        x = math.random(1, BOARD_SIZE)
        y = math.random(1, BOARD_SIZE)
    until SnakeGame.gameBoard[x][y] == 0
    SnakeGame.food = {x = x, y = y}
    SnakeGame.gameBoard[x][y] = 2
end

local function ResetSnakeGame()
    EVENT_MANAGER:UnregisterForUpdate("SnakeGameUpdate")
    InitializeGameBoard()
    SpawnSnake()
    SpawnFood()
    SnakeGame.direction = "RIGHT"
    SnakeGame.StartSnakeGame()
    SnakeGame.timer_total = 0
    SnakeGame.timer = GetTimeStamp()
end

local function UpdateUI()
    local timer = GetTimeStamp() - SnakeGame.timer
    local formatted_timer = string.format("%01d:%02d", math.floor((SnakeGame.timer_total + timer) / 60), (SnakeGame.timer_total + timer) % 60)
    SnakeGameTopLevelControl_Title_SnakeName:SetText("Snake - " .. formatted_timer)
    SnakeGameTopLevelControl_Title_Scores:SetText("Current: " .. (#SnakeGame.snake - 3) .. " - Best: " .. SnakeGame.savedVariables.highscore)
end

local function ProcessDirectionQueue()
    if #SnakeGame.directionQueue > 0 then
        local newDirection = table.remove(SnakeGame.directionQueue)
        if (newDirection == "UP" and SnakeGame.direction ~= "DOWN") or
           (newDirection == "DOWN" and SnakeGame.direction ~= "UP") or
           (newDirection == "LEFT" and SnakeGame.direction ~= "RIGHT") or
           (newDirection == "RIGHT" and SnakeGame.direction ~= "LEFT") then
            SnakeGame.direction = newDirection
            SnakeGame.directionQueue = {}
        end
    end
end

local function MoveSnake()
    local head = SnakeGame.snake[1]
    local newHead = {x = head.x, y = head.y}
    UpdateUI()
    ProcessDirectionQueue()
    if SnakeGame.direction == "" then return end

    if SnakeGame.direction == "UP" then
        newHead.y = newHead.y - 1
    elseif SnakeGame.direction == "DOWN" then
        newHead.y = newHead.y + 1
    elseif SnakeGame.direction == "LEFT" then
        newHead.x = newHead.x - 1
    elseif SnakeGame.direction == "RIGHT" then
        newHead.x = newHead.x + 1
    end

    if newHead.x < 1 then
        newHead.x = BOARD_SIZE
    elseif newHead.x > BOARD_SIZE then
        newHead.x = 1
    end

    if newHead.y < 1 then
        newHead.y = BOARD_SIZE
    elseif newHead.y > BOARD_SIZE then
        newHead.y = 1
    end

    if SnakeGame.gameBoard[newHead.x][newHead.y] == 1 then
        ResetSnakeGame()
        return
    end

    table.insert(SnakeGame.snake, 1, newHead)
    SnakeGame.gameBoard[newHead.x][newHead.y] = 1

    if newHead.x == SnakeGame.food.x and newHead.y == SnakeGame.food.y then
        SpawnFood()
        SnakeGame.savedVariables.total_earned = SnakeGame.savedVariables.total_earned + 1
    else
        local tail = table.remove(SnakeGame.snake)
        SnakeGame.gameBoard[tail.x][tail.y] = 0
    end

    if #SnakeGame.snake - 3 > SnakeGame.savedVariables.highscore then
        SnakeGame.savedVariables.highscore = #SnakeGame.snake - 3
    end
    UpdateUI()
    UpdateGameBoardTextures()
end

function SnakeGame.StartSnakeGame()
    if not SnakeGame.textures_created then
        CreateGameBoardTextures()
        SnakeGame.textures_created = true
    end
    UpdateGameBoardTextures()
    SnakeGame.timer = GetTimeStamp()
    UpdateUI()
    EVENT_MANAGER:RegisterForUpdate("SnakeGameUpdate", 150, MoveSnake)
end

local function PauseSnakeGame()
    EVENT_MANAGER:UnregisterForUpdate("SnakeGameUpdate")
    SnakeGame.direction = ""
end

local function CreateSnakeUI()
    SnakeGame.topLevelControl = ZO_HUDFadeSceneFragment:New( SnakeGameTopLevelControl )
    SnakeGame.SNAKE_UI_SCENE = ZO_Scene:New("SnakeUI", SCENE_MANAGER)
    SnakeGame.SNAKE_UI_SCENE:AddFragment(SnakeGame.topLevelControl)
    SnakeGame.SNAKE_UI_SCENE:AddFragment(UNIFORM_BLUR_FRAGMENT)
    SnakeGame.SNAKE_UI_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            SnakeGame.StartSnakeGame()
        elseif newState == SCENE_HIDDEN then
            PauseSnakeGame()
            SnakeGame.timer_total = SnakeGame.timer_total + GetTimeStamp() - SnakeGame.timer
        end
    end)

    SnakeGameTopLevelControl:SetHandler("OnKeyDown", function(self,key,ctrl,alt,shift,command)
        if shift or key == KEY_LWINDOWS then return end
        if key == KEY_W or key == KEY_UPARROW then
            table.insert(SnakeGame.directionQueue, "UP")
        elseif key == KEY_S or key == KEY_DOWNARROW and not shift then
            table.insert(SnakeGame.directionQueue, "DOWN")
        elseif key == KEY_A or key == KEY_LEFTARROW then
            table.insert(SnakeGame.directionQueue, "LEFT")
        elseif key == KEY_D or key == KEY_RIGHTARROW then
            table.insert(SnakeGame.directionQueue, "RIGHT")
        else
            SnakeGame.ToggleSnakeUI()
        end
    end)
end

function SnakeGame.ToggleSnakeUI()
    if SnakeGame.SNAKE_UI_SCENE:IsShowing() then
        SCENE_MANAGER:Hide("SnakeUI")
    else
        SCENE_MANAGER:Show("SnakeUI")
    end
end

local function OnAddOnLoaded(_, name)
    if name ~= "Snake" then return end
    EVENT_MANAGER:UnregisterForEvent("Snake", EVENT_ADD_ON_LOADED)
    SnakeGame.savedVariables = ZO_SavedVars:NewAccountWide("SnakeSavedVariables", 1, nil, SnakeGame.defaults)
    CreateSnakeUI()
    PauseSnakeGame()
    InitializeGameBoard()
    CreateGameBoardTextures()
    SpawnSnake()
    SpawnFood()

    SLASH_COMMANDS["/snake"] = SnakeGame.ToggleSnakeUI
end

EVENT_MANAGER:RegisterForEvent("Snake", EVENT_ADD_ON_LOADED, OnAddOnLoaded)