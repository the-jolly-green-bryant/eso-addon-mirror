describe("Status pomodoro:", function()
    -- https://github.com/rdok/eso-pomodoro/issues/12

    after_each(function()
        Command.pomodoro = null
    end)

    it("a player may check the pomodoro status", function()
        -- Given I am acting as a player
        require('Player')

        -- And I have started a pomodoro
        Player.execStartCommand()

        -- When I stop the pomodoro
        Player.execStatusCommand()

        -- Then i should see in the chat window message about the new pomodoro
        assert.has_chat('Pomodoro duration: ')
    end)

    it("a player may attempt to check the pomodoro status without having started one", function()
        -- Given I am acting as a player
        require('Player')

        -- And I have NOT started a pomodoro

        -- When I stop the pomodoro
        Player.execStatusCommand()

        -- Then i should see in the chat window message about the new pomodoro
        assert.has_chat('No pomodoro is running.')
    end)

end)
