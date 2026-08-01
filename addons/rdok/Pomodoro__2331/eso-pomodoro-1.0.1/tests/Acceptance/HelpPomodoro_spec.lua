describe("Help Page:", function()
    -- https://github.com/rdok/eso-pomodoro/issues/3

    it("A player may request the command's help page", function()
        -- Given I am acting as a player
        require('Player')

        -- When I request the help page
        Player:execHelpCommand()

        -- Then i should see in the chat window a line from the help page
        assert.has_chat('Usage:  pomodoro COMMAND')
    end)

end)
