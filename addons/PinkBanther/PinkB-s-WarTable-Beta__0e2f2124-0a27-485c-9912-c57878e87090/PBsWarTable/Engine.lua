-- Pure deterministic Lua. No ESO globals, clock, randomness, UI or networking.
local C = PBWT.Config
local E = {}
PBWT.Engine = E
local function integer(v) return type(v) == "number" and v == math.floor(v) end
-- Board, keeps, army and thresholds all come from the variant the state was created with.
function E.Rules(s) return C.VARIANTS[s and s.variant or "light"] end
function E.InBounds(s, x, y)
    local size = E.Rules(s).SIZE
    return integer(x) and integer(y) and x >= 1 and x <= size and y >= 1 and y <= size
end
function E.At(s, x, y)
    for _, p in ipairs(s.pieces) do if p.alive and p.x == x and p.y == y then return p end end
end
function E.Piece(s, id)
    if integer(id) then return s.pieces[id] end
end
function E.Flag(s, x, y)
    for i, f in ipairs(E.Rules(s).FLAGS) do if f.x == x and f.y == y then return s.flags[i], i end end
end
-- setup=true is used by live games; default is a neutral rules/test fixture.
function E.New(setup, variant)
    variant = C.VARIANTS[variant] and variant or "light"
    local rules = C.VARIANTS[variant]
    local s = { version = 5, variant = variant, factions = {0,0}, scrollUsed={false,false}, scrollOwner=0, scrollReader=0, scrollTurn=0, turn = 1, player = 1, actions = C.ACTIONS_PER_TURN,
        score = { 0, 0 }, flags = {}, pieces = {}, cards = { {}, {} }, horn = {}, status = setup and "setup" or "playing" }
    s.opening=setup and "roll" or "done";s.dice={0,0};s.rollRound=1;s.rollWinner=0;s.factionChooser=0;s.orderChooser=0;s.firstPlayer=setup and 0 or 1
    for i = 1, #rules.FLAGS do s.flags[i] = 0 end
    for player = 1, 2 do
        for _, start in ipairs(rules.START) do
            local id = #s.pieces + 1
            s.pieces[id] = { id = id, owner = player, kind = start.kind,
                x = player == 1 and start.x or rules.SIZE + 1 - start.x, y = start.y, alive = true }
        end
        for _, card in ipairs(C.CARD_ORDER) do s.cards[player][card] = true end
    end
    return s
end
function E.Active(s, player)
    if s.status ~= "playing" then return false, "finished" end
    if player ~= s.player then return false, "wrong_turn" end
    return true
end
-- Bounded independent copy for AI simulation. No live-state references escape.
function E.Clone(s)
    local copy = {}
    for k, v in pairs(s) do
        if type(v) ~= "table" then copy[k] = v end
    end
    copy.factions={s.factions[1],s.factions[2]}
    copy.dice={s.dice[1],s.dice[2]}
    copy.scrollUsed={s.scrollUsed[1],s.scrollUsed[2]}
    copy.score, copy.flags, copy.horn, copy.pieces, copy.cards = {}, {}, {}, {}, { {}, {} }
    for k, v in pairs(s.score) do copy.score[k] = v end
    for k, v in pairs(s.flags) do copy.flags[k] = v end
    for k, v in pairs(s.horn) do copy.horn[k] = v end
    for i, p in ipairs(s.pieces) do
        local piece = {}; for k, v in pairs(p) do piece[k] = v end
        copy.pieces[i] = piece
    end
    for player = 1, 2 do
        for k, v in pairs(s.cards[player]) do copy.cards[player][k] = v end
    end
    return copy
end
function E.Own(s, player, id)
    local p = E.Piece(s, id)
    if not p or not p.alive or p.owner ~= player then return nil, "own_piece_required" end
    return p
end
function E.CanMove(s, p, x, y, distance)
    if not E.InBounds(s, x, y) then return false, "outside" end
    local dx, dy = x - p.x, y - p.y
    local length = math.abs(dx) + math.abs(dy)
    if (dx ~= 0 and dy ~= 0) or length < 1 or length > distance then return false, "move_range" end
    local sx, sy = dx == 0 and 0 or dx / math.abs(dx), dy == 0 and 0 or dy / math.abs(dy)
    for step = 1, length do
        if E.At(s, p.x + sx * step, p.y + sy * step) then return false, "blocked" end
    end
    return true
end
function E.MoveRange(s,p) return PBWT.Factions.Move(s,p) end
function E.Attack(s,p,siege) return PBWT.Factions.Attack(s,p) + (siege and C.SIEGE_ATTACK_BONUS or 0) end
-- Charge and horn are cavalry orders: the heavy guardian never receives them.
function E.CardMovable(p) return C.CARD_MOVE_KINDS[p.kind] == true end
function E.Defense(s, p, siege)
    if s.scrollOwner~=0 and s.scrollReader==p.id then return C.SCROLL.READER_DEFENSE end
    local bonus = p.kind == "guardian" and E.Flag(s, p.x, p.y) ~= nil and C.GUARDIAN_FLAG_BONUS or 0
    return C.PIECES[p.kind].defense + (siege and 0 or bonus) + PBWT.Factions.Defense(s,p,siege)
end
function E.CanAttack(s, attacker, target, siege)
    if s.actions < 1 then return false, "no_action" end
    if not target or not target.alive or target.owner == attacker.owner then return false, "enemy_required" end
    if math.abs(attacker.x - target.x) + math.abs(attacker.y - target.y) ~= 1 then return false, "attack_range" end
    if target.hiddenUntil then return false, "hidden" end
    -- Siege now answers any defender standing on a flag, not only guardians.
    if siege and E.Flag(s, target.x, target.y) == nil then return false, "siege_target" end
    return true
end
function E.ResolveAttack(s, attacker, target, siege)
    s.actions = s.actions - 1
    if E.Attack(s,attacker,siege) >= E.Defense(s, target, siege) then
        target.alive, target.hiddenUntil = false, nil
        s.horn[target.id] = nil
        -- No advance into the defeated unit's square, and no retaliation.
        return "defeated"
    end
    return "repelled"
end
function E.Counts(s, player)
    local flags, pieces = 0, 0
    for _, owner in ipairs(s.flags) do if owner == player then flags = flags + 1 end end
    for _, p in ipairs(s.pieces) do if p.alive and p.owner == player then pieces = pieces + 1 end end
    return flags, pieces
end
-- The second player scores first-move compensation but needs one more point to win.
function E.Komi(s, player)
    return (s.firstPlayer ~= 0 and player ~= s.firstPlayer) and E.Rules(s).KOMI or 0
end
function E.WinScore(s, player) return E.Rules(s).WIN_SCORE + E.Komi(s, player) end
-- Turn-limit comparison uses the same handicap as the victory threshold.
function E.Standing(s, player) return s.score[player] - E.Komi(s, player) end
function E.Tiebreak(s)
    local f1, p1 = E.Counts(s, 1)
    local f2, p2 = E.Counts(s, 2)
    local a, b = E.Standing(s, 1), E.Standing(s, 2)
    if a ~= b then return a > b and 1 or 2 end
    if f1 ~= f2 then return f1 > f2 and 1 or 2 end
    if p1 ~= p2 then return p1 > p2 and 1 or 2 end
    return 0
end
function E.IsHome(s, player, x, y)
    local rules = E.Rules(s)
    for _, p in ipairs(rules.START) do
        if (player == 1 and p.x or rules.SIZE + 1 - p.x) == x and p.y == y then return true end
    end
    return false
end
-- Holding every keep at the end of your own turn crowns an emperor (standard board only).
function E.Emperor(s, player)
    local rules = E.Rules(s)
    if not rules.EMPEROR then return false end
    for i = 1, #rules.FLAGS do if s.flags[i] ~= player then return false end end
    return true
end
function E.EndTurn(s)
    local player = s.player
    local rules = E.Rules(s)
    for i, f in ipairs(rules.FLAGS) do
        local p = E.At(s, f.x, f.y)
        if p and p.owner == player then s.flags[i] = player end
        if s.flags[i] == player then s.score[player] = s.score[player] + f.points end
    end
    if E.Emperor(s, player) then
        s.status, s.winner, s.reason = "finished", player, "emperor"
    elseif s.score[player] >= E.WinScore(s, player) then
        s.status, s.winner, s.reason = "finished", player, "score"
    elseif PBWT.Scroll.Resolve(s,player) then
        -- The opponent had a complete response turn; score victory takes priority.
    elseif s.turn >= rules.MAX_TURNS then
        s.status, s.winner, s.reason = "finished", E.Tiebreak(s), "turn_limit"
    else
        s.turn, s.player = s.turn + 1, 3 - player
        s.actions = s.turn == 2 and rules.SECOND_TURN_ACTIONS or C.ACTIONS_PER_TURN
        for _, p in ipairs(s.pieces) do
            if p.hiddenUntil and s.turn >= p.hiddenUntil then p.hiddenUntil = nil end
        end
    end
    s.horn = {}
    return true, "turn_ended"
end
-- This is the single public mutation entry point. Invalid commands never mutate.
local function applyCommand(s, player, command)
    if s.status=='setup' then
        return PBWT.Opening.Apply(s,player,command)
    end
    local ok, reason = E.Active(s, player)
    if not ok then return false, reason end
    if type(command) ~= "table" then return false, "bad_command" end
    if command.type == "end_turn" then return E.EndTurn(s) end
    if command.type == "invoke_scroll" then return PBWT.Scroll.Invoke(s,player) end
    if command.type == "card" then return PBWT.Cards.Use(s, player, command) end
    local p, err = E.Own(s, player, command.id)
    if not p then return false, err end
    if command.type == "move" or command.type == "horn_move" then
        local bonus = command.type == "horn_move"
        if bonus and not s.horn[p.id] then return false, "no_horn_move" end
        if not bonus and s.actions < 1 then return false, "no_action" end
        ok, err = E.CanMove(s, p, command.x, command.y, bonus and C.HORN_DISTANCE or E.MoveRange(s,p))
        if not ok then return false, err end
        p.x, p.y = command.x, command.y
        if bonus then s.horn[p.id] = nil else s.actions = s.actions - 1 end
        return true, "moved"
    elseif command.type == "attack" then
        local target = E.Piece(s, command.target)
        ok, err = E.CanAttack(s, p, target, false)
        if not ok then return false, err end
        return true, E.ResolveAttack(s, p, target, false)
    end
    return false, "bad_command"
end
function E.Apply(s,player,command)
    local ok,reason=applyCommand(s,player,command)
    if ok and PBWT.Scroll.Check(s) and s.status=='playing' then reason='scroll_broken' end
    return ok,reason
end
-- Stable order includes every gameplay field, including spent cards and effects.
-- Diagnostic only, not authentication or a production synchronization protocol.
function E.Serialize(s)
    local values = { s.version, s.variant or "light", s.factions[1], s.factions[2], s.turn, s.player, s.actions, s.status, s.winner or -1, s.reason or "-", s.score[1], s.score[2] }
    values[#values+1]=table.concat({s.scrollOwner,s.scrollReader,s.scrollTurn,s.scrollUsed[1] and 1 or 0,s.scrollUsed[2] and 1 or 0},',')
    values[#values+1]=table.concat({s.opening,s.dice[1],s.dice[2],s.rollRound,s.rollWinner,s.factionChooser,s.orderChooser,s.firstPlayer},',')
    for _, owner in ipairs(s.flags) do values[#values + 1] = owner end
    for _, p in ipairs(s.pieces) do
        values[#values + 1] = table.concat({p.id, p.owner, p.kind, p.x, p.y, p.alive and 1 or 0, p.hiddenUntil or 0, s.horn[p.id] and 1 or 0}, ",")
    end
    for player = 1, 2 do
        for _, name in ipairs(C.CARD_ORDER) do values[#values + 1] = s.cards[player][name] and 1 or 0 end
    end
    return table.concat(values, "|")
end
function E.Checksum(s)
    local text, a, b = E.Serialize(s), 1, 0
    for i = 1, #text do a = (a + string.byte(text, i)) % 65521; b = (b + a) % 65521 end
    return b * 65536 + a
end
