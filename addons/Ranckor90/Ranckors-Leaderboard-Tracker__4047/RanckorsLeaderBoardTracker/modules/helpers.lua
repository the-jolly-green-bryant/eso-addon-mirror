RanckorsHelpers = {}

function RanckorsHelpers.FormatReignDuration(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60
    return string.format("%d days %02d:%02d:%02d", days, hours, minutes, remainingSeconds)
end


function RanckorsHelpers.FormatNumberWithCommas(number)
    local formatted = tostring(number)
    while true do
        formatted, count = formatted:gsub("^(%d+)(%d%d%d)", "%1,%2")
        if count == 0 then break end
    end
    return formatted
end
