local E = PBWT.Engine
PBWT.Cards.Register("stealth", { name = "隠密", description = "斥候1体を次の自分の手番開始まで攻撃対象外にする。", targeting = "piece", validate = function(s, player, c)
    local p, err = E.Own(s, player, c.id)
    if not p then return false, err end
    if p.kind ~= "scout" then return false, "scout_required" end
    return true, "stealth_applied"
end, apply = function(s, player, c)
    local p = E.Piece(s, c.id)
    p.hiddenUntil = s.turn + 2
    return true, "stealth_applied"
end })
