local E = PBWT.Engine
PBWT.Cards.Register("stealth", { key = "stealth", targeting = "piece", validate = function(s, player, c)
    local p, err = E.Own(s, player, c.id)
    if not p then return false, err end
    if p.kind ~= "scout" then return false, "scout_required" end
    return true, "stealth_applied"
end, apply = function(s, player, c)
    local p = E.Piece(s, c.id)
    p.hiddenUntil = s.turn + 2
    return true, "stealth_applied"
end })
