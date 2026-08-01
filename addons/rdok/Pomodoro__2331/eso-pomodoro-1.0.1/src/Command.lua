Command = {
    pomodoro = nil,

    register = function()
        SLASH_COMMANDS['/pomodoro'] = Command.call
    end,

    onUpdate = function()
        Command.pomodoro = Pomodoro.ping(Command.pomodoro)

        if (nil ~= Command.pomodoro.completedAt) then
            EVENT_MANAGER:UnregisterForUpdate(Pomodoro.updateId)
        end
    end,

    call = function(argument)
        if ('start' == argument) then
            return Command.startPomodoro()
        end

        if ('stop' == argument) then
            return Command.stopPomodoro()
        end

        if ('status' == argument) then
            return Command.statusPomodoro()
        end

        return HelpPage.print()
    end,

    stopPomodoro = function()
        local pomodoro = Command.pomodoro

        if (nil == pomodoro) then
            print_error('No pomodoro is running.')
            return
        end

        Command.pomodoro = Pomodoro.stop(pomodoro)
        EVENT_MANAGER:UnregisterForUpdate(Pomodoro.updateId)
    end,

    startPomodoro = function()
        Command.pomodoro = Pomodoro.new()

        EVENT_MANAGER:RegisterForUpdate(
                Pomodoro.updateId,
                Pomodoro.tenSecondsInMilliseconds,
                Command.onUpdate
        )
    end,

    statusPomodoro = function()
        if (nil == Command.pomodoro) then
            print_error('No pomodoro is running.')
            return
        end

        Command.pomodoro = Pomodoro.status(Command.pomodoro)
    end,
}

Command.register()