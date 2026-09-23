-- Deterministic opening state. Dice are supplied once by the local/host adapter;
-- replays only consume the recorded faces and never call the RNG.
local O={};PBWT.Opening=O
local function valid(v,max) return type(v)=='number' and v==math.floor(v) and v>=1 and v<=max end
function O.CanRoll(s,actor)
    return s.status=='setup' and s.player==actor and (s.opening=='roll' or s.opening=='reroll')
end
function O.Draw(random) return (random or math.random)(1,6) end
function O.Apply(s,actor,c)
    if actor~=s.player then return false,'wrong_turn' end
    if type(c)~='table' then return false,'bad_command' end
    if c.type=='roll_dice' then
        if not O.CanRoll(s,actor) or not valid(c.roll,6) then return false,'invalid_roll' end
        if s.opening=='reroll' then s.dice[1],s.dice[2]=0,0;s.rollRound=s.rollRound+1 end
        s.dice[actor]=c.roll
        if actor==1 then s.player,s.opening=2,'roll';return true,'die_rolled' end
        if s.dice[1]==s.dice[2] then s.player,s.opening=1,'reroll';return true,'dice_tie' end
        s.rollWinner=s.dice[1]>s.dice[2] and 1 or 2
        s.player,s.opening=s.rollWinner,'right';return true,'dice_decided'
    elseif c.type=='choose_right' then
        if s.opening~='right' or not valid(c.choice,2) then return false,'invalid_opening_choice' end
        s.factionChooser=c.choice==1 and actor or 3-actor
        s.orderChooser=3-s.factionChooser
        s.player,s.opening=actor,c.choice==1 and 'faction' or 'order';return true,'right_chosen'
    elseif c.type=='choose_faction' then
        if (s.opening~='faction' and s.opening~='other_faction') or not valid(c.faction,3) then return false,'invalid_faction' end
        if s.factions[3-actor]==c.faction then return false,'faction_taken' end
        s.factions[actor]=c.faction
        if s.opening=='faction' then s.player,s.opening=s.orderChooser,s.firstPlayer==0 and 'order' or 'other_faction'
        else s.player,s.status,s.opening=s.firstPlayer,'playing','done' end
        return true,'faction_selected'
    elseif c.type=='choose_order' then
        if s.opening~='order' or not valid(c.choice,2) then return false,'invalid_opening_choice' end
        s.firstPlayer=c.choice==1 and actor or 3-actor
        if s.factions[s.factionChooser]==0 then s.player,s.opening=s.factionChooser,'faction'
        else s.player,s.opening=s.orderChooser,'other_faction' end
        return true,'order_chosen'
    end
    return false,'opening_required'
end
function O.Command(s,index,random)
    if s.opening=='roll' or s.opening=='reroll' then return {type='roll_dice',roll=O.Draw(random)} end
    if s.opening=='right' then return {type='choose_right',choice=index} end
    if s.opening=='order' then return {type='choose_order',choice=index} end
    return {type='choose_faction',faction=index}
end
function O.Choices(s)
    if s.opening=='roll' or s.opening=='reroll' then return 1 end
    return (s.opening=='faction' or s.opening=='other_faction') and 3 or 2
end
function O.ComputerCommand(s,random)
    if s.opening=='roll' or s.opening=='reroll' then return O.Command(s,1,random) end
    if s.opening=='right' then return O.Command(s,2) end -- Prefer choosing initiative.
    if s.opening=='order' then return O.Command(s,1) end
    for _,faction in ipairs({3,1,2}) do if s.factions[3-s.player]~=faction then return O.Command(s,faction) end end
end
