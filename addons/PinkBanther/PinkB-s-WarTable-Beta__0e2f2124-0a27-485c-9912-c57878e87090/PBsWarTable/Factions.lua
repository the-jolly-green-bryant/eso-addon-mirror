-- Tabletop abilities are original rules, not ESO character passives.
local F={}; PBWT.Factions=F
F.order={'dominion','covenant','pact'}
F.definitions={
    dominion={name='アルドメリ・ドミニオン',short='ドミニオン',motif='alliance_dominion',ability='鷲の機動',description='斥候の通常移動が縦横3マスに。飛び越し不可。騎兵突撃・角笛の距離は変わらない。'},
    covenant={name='ダガーフォール・カバナント',short='カバナント',motif='alliance_covenant',ability='獅子の守り',description='旗拠点上の兵士の防御＋1。支配していない旗でも有効。守護者には加算しない。'},
    pact={name='エボンハート・パクト',short='パクト',motif='alliance_pact',ability='竜の共闘',description='味方守護者に縦横で隣接する兵士の攻撃＋1。通常攻撃と攻城に適用。重複加算なし。'},
}
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
