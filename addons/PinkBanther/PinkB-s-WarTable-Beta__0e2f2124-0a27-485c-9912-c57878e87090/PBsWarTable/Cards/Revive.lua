local E = PBWT.Engine
PBWT.Cards.Register("revive", { name = "蘇生", description = "撃破された自軍兵士1体を初期配置6マスの空きへ戻す。", targeting = "home", validate = function(s, player, c)
    local p = E.Piece(s, c.id)
    if not p or p.alive or p.owner ~= player or p.kind ~= "soldier" then return false, "dead_soldier_required" end
    if not E.InBounds(s, c.x, c.y) or not E.IsHome(s, player, c.x, c.y) then return false, "home_required" end
    if E.At(s, c.x, c.y) then return false, "blocked" end
    return true, "revived"
end, apply = function(s, player, c)
    local p = E.Piece(s, c.id)
    p.x, p.y, p.alive, p.hiddenUntil = c.x, c.y, true, nil
    s.horn[p.id] = nil
    return true, "revived"
end })
