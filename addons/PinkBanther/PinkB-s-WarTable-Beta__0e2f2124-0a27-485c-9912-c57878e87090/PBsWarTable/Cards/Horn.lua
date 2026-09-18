local E = PBWT.Engine
PBWT.Cards.Register("horn", { name = "角笛", description = "選択駒の縦横に隣接する味方それぞれに、この手番中1マスの追加移動。", targeting = "piece", validate = function(s, player, c)
    local p, err = E.Own(s, player, c.id)
    if not p then return false, err end
    local count = 0
    for _, other in ipairs(s.pieces) do
        if other.alive and other.owner == player and math.abs(p.x - other.x) + math.abs(p.y - other.y) == 1 then count = count + 1 end
    end
    if count == 0 then return false, "no_neighbors" end
    return true, "horn_applied"
end, apply = function(s, player, c)
    local p = E.Piece(s, c.id)
    for _, other in ipairs(s.pieces) do
        if other.alive and other.owner == player and math.abs(p.x - other.x) + math.abs(p.y - other.y) == 1 then s.horn[other.id] = true end
    end
    return true, "horn_applied"
end })
