describe("Stop pomodoro:", function()
    -- https://github.com/rdok/eso-pomodoro/issues/10

    after_each(function()
        Command.pomodoro = null
    end)

    it("a player may stop a pomodoro", function()
        -- Given I am acting as a player
        require('Player')

        -- And I have started a pomodoro
        Player.execStartCommand()

        -- When I stop the pomodoro
        Player.execStopCommand()

        -- Then i should see in the chat window message about the new pomodoro
        assert.has_chat('Pomodoro stopped.')
    end)

    it("a player may attempt to stop a pomodoro without having started it", function()
        -- Given I am acting as a player
        require('Player')

        -- And I have NOT started a pomodoro

        -- When I stop the pomodoro
        Player.execStopCommand()

        -- Then i should see in the chat window message about the new pomodoro
        assert.has_chat('No pomodoro is running.')
    end)

end)
