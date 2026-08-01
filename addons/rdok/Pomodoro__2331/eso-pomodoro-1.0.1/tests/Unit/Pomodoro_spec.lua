describe("Pomodoro", function()
    local pomodoro

    before_each(function()
        spy.on(_G, "print_primary")
        spy.on(_G, "print_success")
        spy.on(_G, "print_error")
        spy.on(_G, "print_warning")
        spy.on(_G, "print_info")
    end)

    it("should print message about the new pomodoro upon initialization", function()
        pomodoro = Pomodoro:new()
        message = TextFormatter.primary('Pomodoro started.')
        assert.spy(CHAT_SYSTEM.AddMessage)
              .was_called_with(CHAT_SYSTEM, message)
    end)

    it("should store the time the pomodoro started", function()
        pomodoro = Pomodoro.new()
        assert.is_valid_time(pomodoro.createdAt)
    end)

    it("should print message when pomodoro is completed.", function()
        pomodoro = Pomodoro.new()
        pomodoro.createdAt = os.time() - 1500
        Pomodoro.ping(pomodoro)
        assert.stub(_G.print_success).was_called_with('Pomodoro finished.')
    end)

    it("should not print completion message if pomodoro hasn't finished.", function()
        pomodoro.createdAt = os.time() - 1499
        Pomodoro.ping(pomodoro)
        assert.stub(_G.print_success).was_not_called_with('Pomodoro finished.')
    end)

    it("should error when on pinging & pomodoro has already been completed", function()
        pomodoro = Pomodoro:new()
        pomodoro.completedAt = os.time()
        Pomodoro.ping(pomodoro)

        assert.stub(_G.print_error).was_called_with(Pomodoro.error_already_finished)
        assert.stub(_G.print_success).was_not_called_with("Pomodoro finished.")
    end)

    it("should print message when pomodoro is stopped.", function()
        pomodoro = Pomodoro:new()
        Pomodoro.stop(pomodoro)
        assert.stub(_G.print_warning).was_called_with('Pomodoro stopped.')
    end)

    it("should error when attempting to stop a pomodoro that has already been completed.", function()
        Pomodoro.stop(nil)
        assert.stub(_G.print_warning).was.not_called_with('Pomodoro stopped.')
        assert.stub(_G.print_error).was.called_with(Pomodoro.error_already_finished)
    end)

    it("should print pomodoro duration.", function()
        pomodoro = Pomodoro:new()
        pomodoro.createdAt = os.time() - 539
        Pomodoro.status(pomodoro)
        assert.stub(_G.print_info).was.called_with('Pomodoro duration: 08m 59s')
    end)

end)
