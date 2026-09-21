local E, C = PBWT.Engine, PBWT.Config
-- The restored card is named by its CARD_ORDER index so the wire format stays numeric.
PBWT.Cards.Register("supply", { name = "補給", description = "自軍の使用済みカード1種を選び、もう1回使えるようにする。補給自身は選べない。", targeting = "card", validate = function(s, player, c)
    local name = C.CARD_ORDER[c.id]
    if not name or name == "supply" then return false, "supply_target" end
    if s.cards[player][name] then return false, "supply_unused" end
    return true, "supplied"
end, apply = function(s, player, c)
    s.cards[player][C.CARD_ORDER[c.id]] = true
    return true, "supplied"
end })
