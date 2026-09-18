local Cards = { definitions = {} }
PBWT.Cards = Cards
function Cards.Register(id, definition)
    assert(not Cards.definitions[id], "duplicate card: " .. id)
    Cards.definitions[id] = definition
end
-- Build one UI command; no cloned boards, timers or simulation needed.
function Cards.CommandAt(s, card, selected, x, y)
    local definition = Cards.definitions[card]
    local p = PBWT.Engine.At(s, x, y)
    return {type="card", card=card,
        id=definition.targeting=="piece" and (p and p.id) or selected,
        x=x, y=y, target=p and p.id}
end
function Cards.SourceAt(s, player, card, x, y)
    local E = PBWT.Engine
    local p = E.At(s, x, y)
    if not p or p.owner~=player then return false, "own_piece_required" end
    -- A source is eligible only when at least one legal destination exists.
    local command = {type="card", card=card, id=p.id}
    for cy=1,PBWT.Config.SIZE do for cx=1,PBWT.Config.SIZE do
        local target = E.At(s, cx, cy)
        command.x, command.y, command.target = cx, cy, target and target.id
        if Cards.Preview(s, player, command) then return true end
    end end
    return false, "no_card_target"
end
-- Read-only validation is shared by previews, targeting and execution.
function Cards.Preview(s, player, command)
    local ok, reason = PBWT.Engine.Active(s, player)
    if not ok then return false, reason end
    local definition = Cards.definitions[command.card]
    if not definition then return false, "unknown_card" end
    if not s.cards[player][command.card] then return false, "card_spent" end
    return definition.validate(s, player, command)
end
function Cards.Use(s, player, command)
    local valid, reason = Cards.Preview(s, player, command)
    if not valid then return false, reason end
    local definition = Cards.definitions[command.card]
    -- Validation completed before any mutation or card consumption.
    local ok, result = definition.apply(s, player, command)
    if ok then s.cards[player][command.card] = false end
    return ok, result
end
