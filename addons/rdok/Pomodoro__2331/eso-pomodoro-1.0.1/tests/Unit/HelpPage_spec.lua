describe("HelpPage", function()

    local helpMessages = {
        ['description'] = 'A break time reminder for players, based on the pomodoro technique.',
        ['helpPomodoro'] = '> help   Display help information.',
        ['startPomodoro'] = '> start   Start a Pomodoro.',
        ['stopPomodoro'] = '> stop   Stop the current Pomodoro.',
        ['stopPomodoro'] = '> status   Display pomodoro duration.',
    }

    it("should print the help page to the chat system upon initialization", function()
        spy.on(CHAT_SYSTEM, "AddMessage")
        HelpPage.print()

        primaryMessage = 'Usage:  pomodoro COMMAND'
        primaryMessage = TextFormatter.primary(primaryMessage)
        assert.spy(CHAT_SYSTEM.AddMessage).was_called_with(CHAT_SYSTEM, primaryMessage)

        for section, description in pairs(helpMessages) do
            infoMessage = description
            infoMessage = TextFormatter.info(infoMessage)
            assert.spy(CHAT_SYSTEM.AddMessage).was_called_with(CHAT_SYSTEM, infoMessage)
        end

    end)
end)
