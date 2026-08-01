function clone(table)
    table = {}

    for method, value in pairs(Pomodoro) do
        table[method] = value
    end

    return table
end

