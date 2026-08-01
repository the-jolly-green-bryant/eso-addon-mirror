local ADDON_NAME = 'TraderFilter'
local TraderFilter = TraderFilter or {}

TraderFilter.LOGGED_IN_PLAYER = {
    ACCOUNT = GetUnitDisplayName("player"),
    CHARACTER = GetUnitName("player"),
}
TraderFilter.AUTHORIZED_PLAYERS = {
    ['@wh0c4r35ab0utth15'] = {}
}

function TraderFilter.isAuthorized()
    if TraderFilter.AUTHORIZED_PLAYERS[TraderFilter.LOGGED_IN_PLAYER.ACCOUNT] then
        if type(TraderFilter.AUTHORIZED_PLAYERS[TraderFilter.LOGGED_IN_PLAYER.ACCOUNT]) == "table" then
            if #TraderFilter.AUTHORIZED_PLAYERS[TraderFilter.LOGGED_IN_PLAYER.ACCOUNT] == 0 or TraderFilter.AUTHORIZED_PLAYERS[TraderFilter.LOGGED_IN_PLAYER.ACCOUNT][TraderFilter.LOGGED_IN_PLAYER.CHARACTER] then
                return true
            end
        else
            return true
        end
    end

    return false
end

-- expose
_G[ADDON_NAME] = TraderFilter
