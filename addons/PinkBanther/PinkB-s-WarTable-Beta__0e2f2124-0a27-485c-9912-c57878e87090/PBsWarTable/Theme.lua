PBWT.Theme = {
    base = {0.09, 0.08, 0.07, 0.99}, wood = {0.19, 0.14, 0.11, 1},
    tile = {0.22, 0.21, 0.19, 1}, tileAlt = {0.27, 0.25, 0.21, 1},
    brass = {0.70, 0.60, 0.38, 1}, text = {0.91, 0.87, 0.78, 1},
    cursor = {0.84, 0.95, 0.95, 1}, selected = {0.94, 0.85, 0.55, 1},
    players = { "dominion", "covenant" },
    themes = {
        dominion = { color = {0.85, 0.73, 0.34, 1}, motif = "alliance_dominion" },
        covenant = { color = {0.39, 0.61, 0.80, 1}, motif = "alliance_covenant" },
        pact = { color = {0.73, 0.33, 0.30, 1}, motif = "alliance_pact" },
        neutral = { color = {0.72, 0.71, 0.65, 1}, motif = "knot" },
        ancient = { color = {0.46, 0.70, 0.63, 1}, motif = "geometry" },
    },
}
function PBWT.Theme.Id(player,state)
    return state and PBWT.Factions.order[state.factions[player]] or PBWT.Theme.players[player]
end
function PBWT.Theme.Player(player,state) return PBWT.Theme.themes[PBWT.Theme.Id(player,state)].color end
