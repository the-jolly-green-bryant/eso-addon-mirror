------------------------------------------------
-- TIC TAC TOE MENU
-- LibAddonMenu-2.0
------------------------------------------------

local LAM = LibAddonMenu2


if not LAM then

    d("[TicTacToe] LibAddonMenu missing!")

    return

end



local panelData =
{
    type = "panel",
    name = "Queue Time Tic-Tac-Toe",
    displayName = "Queue Time Tic-Tac-Toe",
    author = "|ca12d21H|r|c424242M|r - @Hardmodes (PC-NA)",
    version = "1.0",
    registerForRefresh = true,
    registerForDefaults = true,
}



local options =
{


------------------------------------------------
-- THEME
------------------------------------------------

{
    type = "dropdown",
    name = "Theme",
    tooltip = "Change TicTacToe background theme",

    choices =
    {
        "Dark",
        "ESO Gold",
        "Blue",
        "Purple",
        "Red",
    },


    getFunc = function()

        return TicTacToe.theme

    end,


    setFunc = function(value)

        TicTacToe.theme = value

        TicTacToe:SaveData()


        if TicTacToe.SetTheme then

            TicTacToe:SetTheme()

        end

    end,

},



------------------------------------------------
-- UI SCALE
------------------------------------------------

{
    type = "dropdown",
    name = "UI Scale",
    tooltip = "Change TicTacToe size",

    choices =
    {
        "0.5",
        "1.0",
        "1.5",
        "2.0",
    },


    getFunc = function()

        return tostring(
            TicTacToe.Scale or 1
        )

    end,


    setFunc = function(value)

        TicTacToe.Scale =
            tonumber(value)


        TicTacToe:SaveData()


        if TicTacToe.UIFrame then

            TicTacToe.UIFrame:SetScale(
                TicTacToe.Scale
            )

        end


        d(
            "[TicTacToe] Scale: "
            ..TicTacToe.Scale
        )

    end,

},


------------------------------------------------
-- SHOW
------------------------------------------------

{
    type = "button",
    name = "Open TicTacToe",
    tooltip = "Show TicTacToe window",

    func = function()

        if TicTacToe.UIFrame then

            TicTacToe.Hidden = false

            TicTacToe.UIFrame:SetHidden(false)

            TicTacToe:SaveData()

        end

    end,

},



------------------------------------------------
-- HIDE
------------------------------------------------

{
    type = "button",
    name = "Hide TicTacToe",
    tooltip = "Hide TicTacToe window",

    func = function()

        if TicTacToe.UIFrame then

            TicTacToe.Hidden = true

            TicTacToe.UIFrame:SetHidden(true)

            TicTacToe:SaveData()

        end

    end,

},



------------------------------------------------
-- DIFFICULTY
------------------------------------------------

{
    type = "dropdown",
    name = "Difficulty",
    tooltip = "Change AI difficulty",

    choices =
    {
        "Easy",
        "Normal",
        "Hard",
    },


    getFunc = function()

        return string.upper(
            TicTacToe.difficulty
        )

    end,


    setFunc = function(value)

        -- Save new difficulty
        TicTacToe.difficulty =
            string.lower(value)


        TicTacToe:SaveData()


        -- Update the board UI immediately
        if TicTacToe.DifficultyLabel then

            TicTacToe.DifficultyLabel:SetText(
                "Difficulty: "
                .. string.upper(TicTacToe.difficulty)
            )

        end


        -- Update status message immediately
        if TicTacToe.StatusLabel then

            TicTacToe.StatusLabel:SetText(
                "Difficulty Changed: "
                .. string.upper(TicTacToe.difficulty)
            )


            zo_callLater(
                function()

                    if TicTacToe.StatusLabel then

                        TicTacToe.StatusLabel:SetText(
                            "Your Turn (X)"
                        )

                    end

                end,
                1500
            )

        end


        d(
            "[TicTacToe] Difficulty set to "
            .. string.upper(TicTacToe.difficulty)
        )

    end,

},

------------------------------------------------
-- MOVE WINDOW
------------------------------------------------

{
    type = "checkbox",
    name = "Enable Moving",
    tooltip = "Allows dragging the window",


    getFunc = function()

        return TicTacToe.moveMode

    end,


    setFunc = function(value)

        TicTacToe.moveMode = value


        if TicTacToe.UIFrame then

            TicTacToe.UIFrame:SetMovable(value)

        end

    end,

},



------------------------------------------------
-- RESET STATS
------------------------------------------------

{
    type = "button",
    name = "Reset Statistics",
    tooltip = "Reset wins, losses, and draws",

    func = function()

        TicTacToe.winsCount = 0

        TicTacToe.lossesCount = 0

        TicTacToe.drawsCount = 0


        TicTacToe:SaveData()

        TicTacToe:UpdateScore()

    end,

},



------------------------------------------------
-- INFO
------------------------------------------------

{
    type = "description",

    text =
    "Queue Time Tic-Tac-Toe\n\n" ..
    "Created by |ca12d21H|r|c424242M|r - @Hardmodes (PC-NA)"

},


}



------------------------------------------------
-- REGISTER MENU
------------------------------------------------

function TicTacToe:RegisterMenu()


    LAM:RegisterAddonPanel(
        "TicTacToePanel",
        panelData
    )


    LAM:RegisterOptionControls(
        "TicTacToePanel",
        options
    )


    d("[TicTacToe] Menu Registered")


end