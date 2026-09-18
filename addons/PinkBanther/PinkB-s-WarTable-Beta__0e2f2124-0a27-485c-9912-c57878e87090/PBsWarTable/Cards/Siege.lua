local E = PBWT.Engine
PBWT.Cards.Register("siege", { name = "攻城", description = "通常攻撃と同時に使用。旗上の敵守護者の防御ボーナスだけを無効化。", targeting = "enemy", validate = function(s, player, c)
    local p, err = E.Own(s, player, c.id)
    if not p then return false, err end
    local target = E.Piece(s, c.target)
    local ok; ok, err = E.CanAttack(s, p, target, true)
    if not ok then return false, err end
    return true, E.Attack(s,p) >= E.Defense(s, target, true) and "defeated" or "repelled"
end, apply = function(s, player, c)
    return true, E.ResolveAttack(s, E.Piece(s, c.id), E.Piece(s, c.target), true)
end })
