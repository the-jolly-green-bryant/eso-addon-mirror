TicTacToe = {}
TicTacToe.name = "TicTacToe"


------------------------------------------------
-- GAME DATA
------------------------------------------------

TicTacToe.board =
{
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    ""
}

TicTacToe.currentPlayer = "X"
TicTacToe.gameOver = false


TicTacToe.UIFrame = nil
TicTacToe.StatusLabel = nil
TicTacToe.ScoreLabel = nil
TicTacToe.DifficultyLabel = nil
TicTacToe.cellButtons = {}
TicTacToe.cellBackgrounds = {}

TicTacToe.Minimized = false
TicTacToe.Hidden = true
TicTacToe.FullHeight = 460
TicTacToe.MinHeight = 60
TicTacToe.MaxHeight = 700
TicTacToe.ResizeEnabled = true
TicTacToe.MinWidth = 250
TicTacToe.MinHeightSize = 300
TicTacToe.MaxWidth = 600
TicTacToe.MaxHeight = 700
TicTacToe.Scale = 1


------------------------------------------------
-- SETTINGS
------------------------------------------------

TicTacToe.difficulty = "normal"
TicTacToe.moveMode = false
TicTacToe.theme = "Dark"


TicTacToe.themes =
{

    ["Dark"] =
    {
        0.05,
        0.05,
        0.05,
        0.90
    },


    ["ESO Gold"] =
    {
        0.20,
        0.15,
        0.05,
        0.90
    },


    ["Blue"] =
    {
        0.05,
        0.10,
        0.25,
        0.90
    },


    ["Purple"] =
    {
        0.15,
        0.05,
        0.25,
        0.90
    },


    ["Red"] =
    {
        0.25,
        0.05,
        0.05,
        0.90
    },

}

------------------------------------------------
-- STATS
------------------------------------------------

TicTacToe.winsCount = 0
TicTacToe.lossesCount = 0
TicTacToe.drawsCount = 0



------------------------------------------------
-- SAVED VARIABLES
------------------------------------------------

------------------------------------------------
-- SAVED VARIABLES
------------------------------------------------

function TicTacToe:LoadSavedData()

    TicTacToeSavedVars =
        TicTacToeSavedVars or {}


    -- Window position
    TicTacToeSavedVars.x =
        TicTacToeSavedVars.x or 0


    TicTacToeSavedVars.y =
        TicTacToeSavedVars.y or 0


    -- Stats
    self.winsCount =
        TicTacToeSavedVars.wins or 0


    self.lossesCount =
        TicTacToeSavedVars.losses or 0


    self.drawsCount =
        TicTacToeSavedVars.draws or 0


    -- Settings
    self.difficulty =
        TicTacToeSavedVars.difficulty or "normal"


    self.Scale =
        TicTacToeSavedVars.scale or 1


    self.theme =
        TicTacToeSavedVars.theme or "Dark"

end



function TicTacToe:SaveData()

    -- Stats
    TicTacToeSavedVars.wins =
        self.winsCount


    TicTacToeSavedVars.losses =
        self.lossesCount


    TicTacToeSavedVars.draws =
        self.drawsCount



    -- Settings
    TicTacToeSavedVars.difficulty =
        self.difficulty


    TicTacToeSavedVars.scale =
        self.Scale


    TicTacToeSavedVars.theme =
        self.theme



    -- Window
    TicTacToeSavedVars.hidden =
        self.Hidden


    TicTacToeSavedVars.x =
        TicTacToeSavedVars.x or 0


    TicTacToeSavedVars.y =
        TicTacToeSavedVars.y or 0

end

------------------------------------------------
-- WIN CHECK
------------------------------------------------

function TicTacToe:CheckWin(board, player)

    local combos =
    {
        {1,2,3},
        {4,5,6},
        {7,8,9},

        {1,4,7},
        {2,5,8},
        {3,6,9},

        {1,5,9},
        {3,5,7}
    }


    for _, combo in ipairs(combos) do

        if board[combo[1]] == player
        and board[combo[2]] == player
        and board[combo[3]] == player then

            return true

        end

    end


    return false

end



------------------------------------------------
-- DRAW CHECK
------------------------------------------------

function TicTacToe:IsDraw()

    for i = 1,9 do

        if self.board[i] == "" then

            return false

        end

    end


    return true

end



------------------------------------------------
-- AVAILABLE MOVES
------------------------------------------------

function TicTacToe:GetAvailableMoves()

    local moves = {}


    for i = 1,9 do

        if self.board[i] == "" then

            table.insert(
                moves,
                i
            )

        end

    end


    return moves

end



------------------------------------------------
-- AI
------------------------------------------------

function TicTacToe:GetRandomMove()

    local moves =
        self:GetAvailableMoves()


    if #moves == 0 then

        return nil

    end


    return moves[
        math.random(
            1,
            #moves
        )
    ]

end



function TicTacToe:GetWinningMove(player)

    for i = 1,9 do

        if self.board[i] == "" then

            self.board[i] = player


            local win =
                self:CheckWin(
                    self.board,
                    player
                )


            self.board[i] = ""


            if win then

                return i

            end

        end

    end


    return nil

end
------------------------------------------------
-- AI CONTINUED
------------------------------------------------

function TicTacToe:GetBotMove()


    if self.difficulty == "easy" then

        return self:GetRandomMove()

    end



    if self.difficulty == "normal" then


        local win =
            self:GetWinningMove("O")


        if win then

            return win

        end



        local block =
            self:GetWinningMove("X")


        if block then

            return block

        end



        return self:GetRandomMove()

    end



    -- HARD

    local win =
        self:GetWinningMove("O")


    if win then

        return win

    end



    local block =
        self:GetWinningMove("X")


    if block then

        return block

    end



    if self.board[5] == "" then

        return 5

    end



    return self:GetRandomMove()

end




function TicTacToe:BotMove()

    if self.gameOver then

        return

    end


    local move =
        self:GetBotMove()


    if move then

        self:MakeMove(move)

    end

end



------------------------------------------------
-- COMMANDS
------------------------------------------------

SLASH_COMMANDS["/tttdifficulty"] =
function(text)

    text = string.lower(text)

    if text == "easy"
    or text == "normal"
    or text == "hard" then

        TicTacToe.difficulty = text

        TicTacToe:SaveData()

        d(
            "[TicTacToe] Difficulty: "
            ..text
        )

    else

        d(
            "[TicTacToe] Use: /tttdifficulty easy|normal|hard"
        )

    end

end

SLASH_COMMANDS["/ttt"] =
function()

    if TicTacToe.UIFrame then

        local hidden =
            TicTacToe.UIFrame:IsHidden()


        TicTacToe.UIFrame:SetHidden(
            not hidden
        )

    end

end

SLASH_COMMANDS["/tttscale"] =
function(value)

    local scale = tonumber(value)

    if scale then

        TicTacToe.Scale = scale

        TicTacToeSavedVars.scale = scale

        if TicTacToe.UIFrame then

            TicTacToe.UIFrame:SetScale(scale)

        end

        d("[TicTacToe] Scale: "..scale)

    else

        d("[TicTacToe] Use: /tttscale 0.5 - 2")

    end

end


SLASH_COMMANDS["/tttresetstats"] =
function()

    TicTacToe.winsCount = 0
    TicTacToe.lossesCount = 0
    TicTacToe.drawsCount = 0


    TicTacToe:SaveData()


    d(
        "[TicTacToe] Stats Reset"
    )

end



SLASH_COMMANDS["/tttmove"] =
function()


    TicTacToe.moveMode =
        not TicTacToe.moveMode



    if TicTacToe.UIFrame then


        TicTacToe.UIFrame:SetMovable(
            TicTacToe.moveMode
        )


        TicTacToe.UIFrame:SetMouseEnabled(
            TicTacToe.moveMode
        )


    end



    if TicTacToe.moveMode then

        d(
            "[TicTacToe] Move Enabled"
        )

    else

        d(
            "[TicTacToe] Move Locked"
        )

    end

end

------------------------------------------------
-- WINDOW COMMANDS
------------------------------------------------

SLASH_COMMANDS["/ttthide"] =
function()

    if TicTacToe.UIFrame then

        TicTacToe.UIFrame:SetHidden(true)

    end


    d("[TicTacToe] Hidden")

end



SLASH_COMMANDS["/tttshow"] =
function()

    if TicTacToe.UIFrame then

        TicTacToe.UIFrame:SetHidden(false)

    end


    d("[TicTacToe] Shown")

end



SLASH_COMMANDS["/tttmin"] =
function()

    if not TicTacToe.UIFrame then
        return
    end


    if TicTacToe.Minimized then

        TicTacToe.UIFrame:SetDimensions(
            270,
            TicTacToe.FullHeight
        )

        TicTacToe.Minimized = false

        d("[TicTacToe] Restored")

    else

        TicTacToe.UIFrame:SetDimensions(
            270,
            TicTacToe.MinHeight
        )

        TicTacToe.Minimized = true

        d("[TicTacToe] Minimized")

    end

end

SLASH_COMMANDS["/tttreload"] =
function()

    if TicTacToe.UIFrame then

        TicTacToe.UIFrame:SetHidden(true)

    end


    TicTacToe:ResetGame()


    d("[TicTacToe] Reloaded")

end

------------------------------------------------
-- SCORE DISPLAY
------------------------------------------------

function TicTacToe:UpdateScore()

    if self.ScoreLabel then


        local total =
            self.winsCount +
            self.lossesCount +
            self.drawsCount


        local rate = 0


        if total > 0 then

            rate =
                math.floor(
                    (self.winsCount / total) * 100
                )

        end



        self.ScoreLabel:SetText(
            "Wins: "..self.winsCount..
            "  Loss: "..self.lossesCount..
            "  Draw: "..self.drawsCount..
            "  ("..rate.."%)"
        )


    end

end



------------------------------------------------
-- MAKE MOVE
------------------------------------------------

function TicTacToe:MakeMove(index)


    if self.gameOver then
        return
    end


    if self.board[index] ~= "" then
        return
    end



    self.board[index] =
        self.currentPlayer



    self.cellButtons[index]:SetText(
        self.currentPlayer
    )



    if self.currentPlayer == "X" then


        self.cellButtons[index]:SetNormalFontColor(
            0.2,
            0.6,
            1,
            1
        )


    else


        self.cellButtons[index]:SetNormalFontColor(
            1,
            0.2,
            0.2,
            1
        )


    end



    PlaySound(
        SOUNDS.OBJECTIVE_COMPLETED
    )



    if self:CheckWin(
        self.board,
        self.currentPlayer
    ) then


        self.gameOver = true



        if self.currentPlayer == "X" then


            self.StatusLabel:SetText(
                "You Win!"
            )


            self.winsCount =
                self.winsCount + 1


            PlaySound(
                SOUNDS.CHAMPION_POINTS_GAINED
            )


        else


            self.StatusLabel:SetText(
                "Bot Wins!"
            )


            self.lossesCount =
                self.lossesCount + 1


            PlaySound(
                SOUNDS.NEGATIVE_CLICK
            )


        end



        self:SaveData()
        self:UpdateScore()


        return

    end



    if self:IsDraw() then


        self.gameOver = true


        self.StatusLabel:SetText(
            "Draw!"
        )


        self.drawsCount =
            self.drawsCount + 1


        PlaySound(
            SOUNDS.GAMEPAD_MENU_CLOSE
        )


        self:SaveData()
        self:UpdateScore()


        return

    end



    if self.currentPlayer == "X" then


        self.currentPlayer = "O"


        self.StatusLabel:SetText(
            "Bot Thinking..."
        )


        zo_callLater(
            function()

                self:BotMove()

            end,
            500
        )


    else


        self.currentPlayer = "X"


        self.StatusLabel:SetText(
            "Your Turn (X)"
        )


    end


end
------------------------------------------------
-- RESET GAME
------------------------------------------------

function TicTacToe:ResetGame()

    self.board =
    {
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
    }


    self.currentPlayer = "X"
    self.gameOver = false


    for i = 1,9 do

        self.cellButtons[i]:SetText("")

        self.cellButtons[i]:SetNormalFontColor(
            1,
            1,
            1,
            1
        )

    end


    self.StatusLabel:SetText(
        "Your Turn (X)"
    )

end

------------------------------------------------
-- APPLY THEME
------------------------------------------------

function TicTacToe:SetTheme()

    if not self.Background then
        return
    end


    local color =
        self.themes[self.theme]


    if not color then

        color =
            self.themes["Dark"]

    end


    -- Main window
    self.Background:SetCenterColor(
        color[1],
        color[2],
        color[3],
        color[4]
    )


    -- Board squares
    if self.cellBackgrounds then

        for i = 1,9 do

            local cell =
                self.cellBackgrounds[i]


            if cell then

                cell:SetCenterColor(
                    color[1] + 0.10,
                    color[2] + 0.10,
                    color[3] + 0.10,
                    1
                )

            end

        end

    end

end
------------------------------------------------
-- CREATE UI
------------------------------------------------

function TicTacToe:CreateUI()


    self.UIFrame =
        WINDOW_MANAGER:CreateTopLevelWindow(
            "TicTacToeFrame"
        )


    self.UIFrame:SetDimensions(
    330,
    460
)

	self.UIFrame:SetScale(
    	self.Scale or 1
)

    self.UIFrame:SetAnchor(
    CENTER,
    GuiRoot,
    CENTER,
    TicTacToeSavedVars.x or 0,
    TicTacToeSavedVars.y or 0
)

------------------------------------------------
-- WINDOW MOVEMENT
------------------------------------------------

self.UIFrame:SetMovable(true)
self.UIFrame:SetMouseEnabled(true)
self.UIFrame:SetClampedToScreen(true)

self.UIFrame:SetHandler(
    "OnMouseUp",
    function(_, button)

        if button == MOUSE_BUTTON_INDEX_LEFT then

            self.UIFrame:StopMoving()


            local x, y =
                self.UIFrame:GetCenter()


            local guiX, guiY =
                GuiRoot:GetCenter()


            TicTacToeSavedVars.x =
                x - guiX


            TicTacToeSavedVars.y =
                y - guiY


            d("[TicTacToe] Position Saved")

        end

    end
)


self.UIFrame:SetHandler(
    "OnMouseUp",
    function(_, button)

        if button == MOUSE_BUTTON_INDEX_LEFT then

            self.UIFrame:StopMoving()

        end

    end
)

------------------------------------------------
-- RESIZE CORNER
------------------------------------------------

local resize =
    WINDOW_MANAGER:CreateControl(
        "TicTacToeResize",
        self.UIFrame,
        CT_BACKDROP
    )


resize:SetDimensions(
    20,
    20
)


resize:SetAnchor(
    BOTTOMRIGHT,
    self.UIFrame,
    BOTTOMRIGHT,
    0,
    0
)


resize:SetCenterColor(
    1,
    1,
    1,
    0.25
)


resize:SetMouseEnabled(true)


resize:SetHandler(
    "OnMouseDown",
    function()

        TicTacToe.Resizing = true

        resize.startWidth,
        resize.startHeight =
            self.UIFrame:GetDimensions()


        resize.startX,
        resize.startY =
            GetUIMousePosition()


    end
)


resize:SetHandler(
    "OnMouseUp",
    function()

        TicTacToe.Resizing = false

    end
)


resize:SetHandler(
    "OnMouseMove",
    function()

        if not TicTacToe.Resizing then
            return
        end


        local mouseX,
        mouseY =
            GetUIMousePosition()


        local newWidth =
            resize.startWidth +
            (mouseX - resize.startX)


        local newHeight =
            resize.startHeight +
            (mouseY - resize.startY)



        newWidth =
            zo_clamp(
                newWidth,
                TicTacToe.MinWidth,
                TicTacToe.MaxWidth
            )


        newHeight =
    zo_clamp(
        newHeight,
        TicTacToe.MinHeightSize,
        TicTacToe.MaxHeight
    )


        self.UIFrame:SetDimensions(
            newWidth,
            newHeight
        )

    end
)

    ------------------------------------------------
    -- BACKGROUND
    ------------------------------------------------

    self.Background =
    WINDOW_MANAGER:CreateControl(
        "TicTacToeBackground",
        self.UIFrame,
        CT_BACKDROP
    )


    self.Background:SetDimensions(
        330,
        460
    )


    self.Background:SetAnchor(
        TOPLEFT,
        self.UIFrame,
        TOPLEFT,
        0,
        0
    )


    self:SetTheme()

    ------------------------------------------------
    -- TITLE
    ------------------------------------------------

    local title =
        WINDOW_MANAGER:CreateControl(
            "TicTacToeTitle",
            self.UIFrame,
            CT_LABEL
        )


    title:SetFont(
        "ZoFontWinH2"
    )


    title:SetAnchor(
        TOP,
        self.UIFrame,
        TOP,
        0,
        15
    )


    title:SetText(
        "Queue Time Tic-Tac-Toe"
    )



    ------------------------------------------------
    -- SCORE
    ------------------------------------------------

    self.ScoreLabel =
        WINDOW_MANAGER:CreateControl(
            "TicTacToeScore",
            self.UIFrame,
            CT_LABEL
        )


    self.ScoreLabel:SetFont(
        "ZoFontGameSmall"
    )


    self.ScoreLabel:SetAnchor(
        TOP,
        title,
        BOTTOM,
        0,
        8
    )


    self:UpdateScore()



    ------------------------------------------------
    -- DIFFICULTY
    ------------------------------------------------

    self.DifficultyLabel =
        WINDOW_MANAGER:CreateControl(
            "TicTacToeDifficulty",
            self.UIFrame,
            CT_LABEL
        )


    self.DifficultyLabel:SetFont(
        "ZoFontGameSmall"
    )


    self.DifficultyLabel:SetAnchor(
        TOP,
        self.ScoreLabel,
        BOTTOM,
        0,
        5
    )


    self.DifficultyLabel:SetText(
        "Difficulty: "
        ..string.upper(self.difficulty)
    )



    ------------------------------------------------
    -- STATUS
    ------------------------------------------------

    self.StatusLabel =
        WINDOW_MANAGER:CreateControl(
            "TicTacToeStatus",
            self.UIFrame,
            CT_LABEL
        )


    self.StatusLabel:SetFont(
        "ZoFontGameBold"
    )


    self.StatusLabel:SetAnchor(
        TOP,
        self.DifficultyLabel,
        BOTTOM,
        0,
        8
    )


    self.StatusLabel:SetText(
        "Your Turn (X)"
    )



    ------------------------------------------------
    -- BOARD
    ------------------------------------------------

    local size = 70


    for i = 1,9 do


        local col =
            (i-1)%3


        local row =
            math.floor(
                (i-1)/3
            )



        local button =
            WINDOW_MANAGER:CreateControl(
                "TicTacToeButton"..i,
                self.UIFrame,
                CT_BUTTON
            )


        button:SetDimensions(
            size,
            size
        )


        button:SetAnchor(
            TOPLEFT,
            self.UIFrame,
            TOPLEFT,
            55 + col * 75,
            165 + row * 75
        )


        button:SetFont(
            "ZoFontWinH1"
        )


        button:SetText(
            ""
        )



        local cellBG =
            WINDOW_MANAGER:CreateControl(
                "TicTacToeCellBG"..i,
                button,
                CT_BACKDROP
            )

cellBG:SetCenterColor(
    0.15,
    0.15,
    0.15,
    1
)


self.cellBackgrounds[i] = cellBG

    cellBG:SetAnchor(
    	TOPLEFT,
    	button,
    	TOPLEFT,
    	0,
    	0
)

cellBG:SetDimensions(
    70,
    70
)


        cellBG:SetCenterColor(
            0.15,
            0.15,
            0.15,
            1
        )


        



        local index = i


        button:SetHandler(
            "OnClicked",
            function()

                self:MakeMove(index)

            end
        )


        self.cellButtons[i] =
            button


    end



    ------------------------------------------------
    -- RESET BUTTON
    ------------------------------------------------

    local reset =
        WINDOW_MANAGER:CreateControl(
            "TicTacToeReset",
            self.UIFrame,
            CT_BUTTON
        )


    reset:SetDimensions(
        200,
        40
    )


    reset:SetAnchor(
    	TOP,
    	self.UIFrame,
    	TOP,
    	0,
    	390
)


    reset:SetFont(
        "ZoFontGameBold"
    )


    reset:SetText(
        "Reset Game"
    )


   reset:SetHandler(
    "OnClicked",
    function()

        self:ResetGame()

    end
)

------------------------------------------------
-- START HIDDEN
------------------------------------------------
self:SetTheme()

self.UIFrame:SetHidden(true)

end

------------------------------------------------
-- INITIALIZE
------------------------------------------------

function TicTacToe:Initialize()

    self:LoadSavedData()

    self:CreateUI()

    self:RegisterMenu()

    d("[TicTacToe] Loaded Successfully")
    d("[TicTacToe] Menu Registered")
    d("[TicTacToe] Difficulty: "..self.difficulty)

end

------------------------------------------------
-- LOAD EVENT
------------------------------------------------

local function OnAddOnLoaded(
    eventCode,
    addonName
)


    if addonName ~= TicTacToe.name then

        return

    end



    EVENT_MANAGER:UnregisterForEvent(
        TicTacToe.name,
        EVENT_ADD_ON_LOADED
    )



    TicTacToe:Initialize()


end



EVENT_MANAGER:RegisterForEvent(
    TicTacToe.name,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)