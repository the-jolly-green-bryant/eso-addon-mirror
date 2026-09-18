local E, C = PBWT.Engine, PBWT.Config
PBWT.Cards.Register("charge", { name = "騎兵突撃", description = "自軍1駒を追加で縦横2マスまで直進。飛び越し不可。", targeting = "destination", validate = function(s, player, c)
    local p, err = E.Own(s, player, c.id)
    if not p then return false, err end
    local ok; ok, err = E.CanMove(s, p, c.x, c.y, C.CHARGE_DISTANCE)
    if not ok then return false, err end
    return true, "moved"
end, apply = function(s, player, c)
    local p = E.Piece(s, c.id)
    p.x, p.y = c.x, c.y
    return true, "moved"
end })
