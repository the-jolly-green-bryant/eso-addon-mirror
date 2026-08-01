HelpPage = {
    print = function()
        -- Not using loop due to lua not guarantying any iteration order
        -- TODO: find package offering this functionality when this table becomes
        -- hard to maintain
        print_primary('Usage:  pomodoro COMMAND')
        print_info('A break time reminder for players, based on the pomodoro technique.')
        print_info('> help   Display help information.')
        print_info('> start   Start a Pomodoro.')
        print_info('> stop   Stop the current Pomodoro.')
        print_info('> status   Display pomodoro duration.')
    end,
}

