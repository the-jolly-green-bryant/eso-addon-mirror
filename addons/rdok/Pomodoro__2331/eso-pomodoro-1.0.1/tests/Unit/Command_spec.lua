describe("Command", function()

    after_each(function()
        Command.pomodoro = null
    end)

    it("should auto register to the esoui commands", function()
        assert.are.same({ ['/pomodoro'] = Command.call }, SLASH_COMMANDS)
    end)

    it("may print the help page", function()
        spy.on(HelpPage, "print")
        Command.call()
        Command.call('help')
        assert.spy(HelpPage.print).was_called(2)
    end)

    it("may start pomodoro", function()
        spy.on(Pomodoro, "new")
        Command.call('start')
        assert.spy(Pomodoro.new).was_called()
    end)

    it("may stop a pomodoro ", function()
        spy.on(CHAT_SYSTEM, "AddMessage")
        spy.on(Pomodoro, "stop")
        Command.call('start')
        Command.call('stop')

        assert.is_nil(Command.pomodoro)

        assert.spy(Pomodoro.stop).was_called()
        message = TextFormatter.error('No pomodoro is running.')
        assert.spy(CHAT_SYSTEM.AddMessage).was_not_called_with(CHAT_SYSTEM, message)
    end)

    it("should error when attempting to stop non-existent pomodoro.", function()
        assert_error_without_pomodoro('stop', Pomodoro.stop)
    end)

    it("may get the status pomodoro ", function()
        spy.on(Pomodoro, "status")
        Command.call('start')
        Command.call('status')

        assert.spy(Pomodoro.status).was_called()
    end)

    it("Status: should error when attempting to get the status of an non-existent pomodoro.", function()
        assert_error_without_pomodoro('status', Pomodoro.status)
    end)

    function assert_error_without_pomodoro(argument, callback)
        spy.on(CHAT_SYSTEM, "AddMessage")
        Command.call(argument)
        message = TextFormatter.error('No pomodoro is running.')
        assert.spy(CHAT_SYSTEM.AddMessage).was_called_with(CHAT_SYSTEM, message)
    end

    it("#dd should register for update when creating a pomodoro.", function()
        stub(EVENT_MANAGER, "RegisterForUpdate")
        Command.call('start')
        assert.stub(EVENT_MANAGER.RegisterForUpdate)
              .was_called_with(EVENT_MANAGER, Pomodoro.updateId, Pomodoro.tenSecondsInMilliseconds, Command.onUpdate)
    end)

    it("should deregister when pomodoro is complete", function()
        spy.on(EVENT_MANAGER, "UnregisterForUpdate")
        Command.call('start')
        Command.pomodoro.completedAt = os.time()
        Command.onUpdate()
        assert.spy(EVENT_MANAGER.UnregisterForUpdate).was_called_with(EVENT_MANAGER, Pomodoro.updateId)
    end)

    it("should not deregister if pomodoro hasn't complete", function()
        spy.on(EVENT_MANAGER, "UnregisterForUpdate")
        Command.call('start')
        Command.pomodoro.completedAt = nil
        Command.onUpdate()
        assert.spy(EVENT_MANAGER.UnregisterForUpdate).was_not_called(

        )
    end)

    it("should deregister when pomodoro is stopped. #cmd_register", function()
        stub(_G, EVENT_MANAGER)
        Command.call('start')
        Command.call('stop')
        assert.stub(EVENT_MANAGER.UnregisterForUpdate).was_called_with(EVENT_MANAGER, Pomodoro.updateId)
    end)
end)
