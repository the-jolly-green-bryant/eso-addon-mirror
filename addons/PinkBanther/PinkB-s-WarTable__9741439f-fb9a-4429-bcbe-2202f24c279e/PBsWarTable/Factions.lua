-- Tabletop abilities are original rules, not ESO character passives.
local F={}; PBWT.Factions=F
F.order={'dominion','covenant','pact'}
F.definitions={
    dominion={key='dominion',motif='alliance_dominion'},
    covenant={key='covenant',motif='alliance_covenant'},
    pact={key='pact',motif='alliance_pact'},
}
-- The screens read these; the words themselves live in Strings.lua.
function F.Name(faction,short) return PBWT.L('faction_'..faction.key..(short and '_short' or '')) end
function F.Ability(faction) return PBWT.L('faction_'..faction.key..'_ability') end
function F.Description(faction) return PBWT.L('faction_'..faction.key..'_text') end
function F.Get(s,player)
    return F.definitions[F.order[s.factions and s.factions[player] or 0]]
end
function F.Is(s,player,name) return F.order[s.factions and s.factions[player] or 0]==name end
function F.Move(s,p)
    local C=PBWT.Config
    return C.PIECES[p.kind].move+(p.kind=='scout' and F.Is(s,p.owner,'dominion') and C.FACTION_BONUSES.DOMINION_SCOUT_MOVE or 0)
end
function F.Defense(s,p,siege)
    if siege then return 0 end -- 攻城は旗に由来する防御補正をすべて無効にする
    return p.kind=='soldier' and F.Is(s,p.owner,'covenant') and PBWT.Engine.Flag(s,p.x,p.y)~=nil and PBWT.Config.FACTION_BONUSES.COVENANT_FLAG_DEFENSE or 0
end
function F.Attack(s,p)
    local value=PBWT.Config.PIECES[p.kind].attack
    if p.kind=='soldier' and F.Is(s,p.owner,'pact') then
        for _,ally in ipairs(s.pieces) do
            if ally.alive and ally.owner==p.owner and ally.kind=='guardian' and math.abs(ally.x-p.x)+math.abs(ally.y-p.y)==1 then
                return value+PBWT.Config.FACTION_BONUSES.PACT_GUARDIAN_ATTACK
            end
        end
    end
    return value
end
