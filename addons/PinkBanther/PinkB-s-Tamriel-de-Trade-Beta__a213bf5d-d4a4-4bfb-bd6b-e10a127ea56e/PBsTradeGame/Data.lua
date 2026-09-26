local D = {zones = {}, properties = {}, companies = {}, groups = {}}
PBTrade.Data = D
-- Positions are a schematic trading chart, not ESO world-map coordinates.
local zones = {
    {"auridon", "オーリドン", .00, .86, 0},
    {"grahtwood", "グラーウッド", .60, .86, 0},
    {"greenshade", "グリーンシェイド", .28, .70, 1},
    {"reapers", "リーパーズ・マーチ", .51, .51, 1},
    {"stonefalls", "ストーンフォール", .92, .30, 2},
    {"deshaan", "デシャーン", .95, .59, 2},
    {"rift", "リフト", .62, .10, 3},
    {"stormhaven", "ストームヘヴン", .28, .25, 0},
    {"rivenspire", "リベンスパイアー", .15, .05, 3},
    {"alikr", "アリクル砂漠", .00, .45, 1},
}
for _, z in ipairs(zones) do
    D.zones[#D.zones + 1] = {id=z[1], name=z[2], x=z[3], y=z[4], unlockTier=z[5]}
end
D.categories = {
    mine="鉱山", lumber="製材所", forge="鍛冶工房", tailor="仕立屋",
    alchemy="錬金工房", tavern="酒場", inn="宿屋", port="港湾",
    caravan="キャラバン", farm="農場", ranch="牧場", books="書店",
    mages="魔術ギルド系施設", fighters="戦士ギルド系施設", jewelry="宝石商", market="市場",
}
D.companies = {
    player={id="player", name="薄紅の羅針商会", cash=6500, personality="player", alliances={}},
    neutral={id="neutral", name="地元出資者", cash=0, personality="steady", alliances={}},
    amber={id="amber", name="ドフォーレ商会", cash=42000, personality="wealth", aggression=.68, defense=.8, tacticBias="gift", acquisitionBias="port", minChapter=2, alliances={}},
    iron={id="iron", name="レドラン家", cash=24000, personality="aggressive", aggression=.8, defense=.4, tacticBias="messenger", acquisitionBias="mine", alliances={}},
    ink={id="ink", name="メナント家", cash=31000, personality="information", aggression=.62, defense=.7, tacticBias="rumor", acquisitionBias="books", alliances={}},
    ash={id="ash", name="レイヴンウォッチ家", cash=58000, personality="subversion", aggression=.7, defense=.7, tacticBias="defection", acquisitionBias="mages", alliances={}},
    veil={id="veil", name="ベールの守護者連合", cash=84000, personality="subversion", aggression=.76, defense=.82, tacticBias="defection", acquisitionBias="market", minChapter=3, alliances={}},
    worm={id="worm", name="黒繭交易教団", cash=118000, personality="information", aggression=.84, defense=.88, tacticBias="rumor", acquisitionBias="alchemy", minChapter=4, alliances={}},
    molag={id="molag", name="モラグ・バル コンツェルン", cash=220000, personality="dominion", aggression=.94, defense=.96, tacticBias="gift", acquisitionBias="mages", minChapter=5, alliances={}},
}
D.groups = {
    valenwood={name="ヴァレンウッド木材連合", minimum=2, bonus=1.5, discoveryChance=.18},
    jewels={name="サマーセット宝飾網", minimum=2, bonus=1.6, discoveryChance=.15},
    mines={name="モロウウィンド鉱業連盟", minimum=2, bonus=1.5, discoveryChance=.15},
    hospitality={name="タムリエル酒造組合", minimum=3, bonus=1.7, discoveryChance=.12},
    roads={name="帝国交易路", minimum=3, bonus=1.8, discoveryChance=.10},
}
-- Ten-period board policies. Their trade-offs affect settlements, delegation and hostile bids.
D.tradePolicies = {
    {id="expansion",name="拡張路線",description="設備投資と支店開設を優先。資産成長と委任買収に強い反面、敵の注目を集めます。",
        playerGrowthBonus=.004,delegateChance=.10,counterattackMultiplier=1.20},
    {id="consolidation",name="基盤固め",description="既存事業の準備金と忠誠を回復。成長と委任速度を抑えて守りを固めます。",
        profitMultiplier=.92,reserveRecoveryMultiplier=1.45,riskRecovery=6,delegateChance=-.06,counterattackMultiplier=.72},
    {id="intelligence",name="情報優位",description="帳簿・伝令・相場情報へ投資。委任の成功率を高め、敵の買収予算を削ります。",
        profitMultiplier=.96,delegateChance=.16,enemyBudgetMultiplier=.86,counterattackMultiplier=.90},
    {id="dividend",name="利益還元",description="今期利益を最大化しますが、準備金と忠誠回復は遅れます。",
        profitMultiplier=1.28,reserveRecoveryMultiplier=.72,riskRecovery=-2,delegateChance=-.04},
}
D.tradePolicyById={}; for _,p in ipairs(D.tradePolicies) do D.tradePolicyById[p.id]=p end
-- One event is revealed before each policy choice. Category effects make the portfolio mix matter.
D.marketEvents = {
    {id="harvest",name="豊穣祭と大宴会",description="農牧・宿泊・酒造の需要が急増しています。",
        categories={farm=true,ranch=true,inn=true,tavern=true},profitMultiplier=1.45,growthBonus=.004},
    {id="ore_rush",name="新鉱脈の熱狂",description="鉱石と加工品へ投機資金が流れ込んでいます。",
        categories={mine=true,forge=true,jewelry=true},profitMultiplier=1.35,growthBonus=.006},
    {id="road_blockade",name="街道封鎖",description="輸送網が乱れ、港湾と隊商の利益が落ち、敵商会が攻勢を強めています。",
        categories={port=true,caravan=true},profitMultiplier=.68,delegateChance=-.10,counterattackMultiplier=1.25},
    {id="credit_fair",name="帝国信用市",description="資金が市場を巡り、全事業が活況です。ただし敵の買収資金も増えます。",
        profitMultiplier=1.12,growthBonus=.002,enemyBudgetMultiplier=1.12},
    {id="arcane_route",name="秘術物流網の開通",description="魔術・錬金・書籍の流通が急拡大しています。",
        categories={mages=true,alchemy=true,books=true},profitMultiplier=1.40,growthBonus=.005},
}
D.marketEventById={}; for _,e in ipairs(D.marketEvents) do D.marketEventById[e.id]=e end
-- Fictional businesses; only zone names are taken from the setting.
local rows = {
    {"aur_farm","朝露の果樹園","auridon","farm",3400,190,"player",8,8,.8,{}},
    {"aur_port","月白の船荷場","auridon","port",6800,350,"neutral",12,12,1.1,{"roads"}},
    {"aur_jewel","潮真珠の彫金房","auridon","jewelry",9500,480,"amber",20,14,1.4,{"jewels"}},
    {"gra_lumber","流木の製材座","grahtwood","lumber",4200,230,"player",12,10,1.0,{"valenwood"}},
    {"gra_inn","枝陰の旅籠","grahtwood","inn",4000,260,"neutral",10,9,.9,{"hospitality"}},
    {"gra_alchemy","琥珀樹脂の調合所","grahtwood","alchemy",6200,320,"ink",16,12,1.2,{}},
    {"gre_lumber","遠枝の輸入木材所","greenshade","lumber",6500,400,"neutral",16,14,1.3,{"valenwood"}},
    {"gre_tailor","木漏れ日の織房","greenshade","tailor",5000,300,"neutral",10,12,.9,{}},
    {"gre_tavern","雨音の杯亭","greenshade","tavern",5700,340,"amber",18,10,1.1,{"hospitality"}},
    {"rea_caravan","双月の荷車隊","reapers","caravan",7800,420,"iron",20,16,1.5,{"roads"}},
    {"rea_ranch","砂金の厩舎","reapers","ranch",5100,280,"neutral",12,10,1.2,{}},
    {"rea_market","夕市の交易座","reapers","market",9300,510,"amber",22,14,1.5,{"roads"}},
    {"sto_mine","赤玻璃の採掘坑","stonefalls","mine",10000,620,"iron",25,16,1.8,{"mines"}},
    {"sto_forge","灰鉄の鍛造房","stonefalls","forge",8500,480,"neutral",18,12,1.5,{"mines"}},
    {"sto_fighters","黒曜の護送詰所","stonefalls","fighters",11000,520,"iron",10,10,1.7,{"roads"}},
    {"des_mine","湿原の鉱石洗場","deshaan","mine",10500,580,"neutral",20,14,1.5,{"mines"}},
    {"des_mages","夜灯の写本研究所","deshaan","mages",17000,820,"ash",32,20,2.0,{}},
    {"des_books","蒼葦の書庫","deshaan","books",7600,460,"ink",16,12,1.1,{}},
    {"rif_tavern","霜麦の酒蔵","rift","tavern",9500,650,"neutral",20,16,1.4,{"hospitality"}},
    {"rif_ranch","白樺の放牧地","rift","ranch",7300,440,"neutral",10,10,1.2,{}},
    {"rif_port","湖鏡の積出場","rift","port",13000,700,"amber",24,16,1.7,{"roads"}},
    {"str_market","風見の商人会館","stormhaven","market",5500,300,"neutral",12,10,1.0,{}},
    {"str_books","潮風の書店","stormhaven","books",3900,240,"neutral",10,8,.9,{}},
    {"str_hq","ドフォーレ商会本社","stros","port",30000,1400,"amber",28,22,2.4,{"roads"},true},
    {"riv_inn","霧鐘の宿","rivenspire","inn",7200,490,"neutral",16,12,1.2,{"hospitality"}},
    {"riv_jewel","銀雫の宝石庫","rivenspire","jewelry",12500,800,"ink",24,18,1.6,{"jewels"}},
    {"riv_hq","灰燭の契約院","rivenspire","mages",38000,1700,"ash",36,24,2.6,{},true},
    {"ali_caravan","暁砂の隊商宿","alikr","caravan",6800,400,"neutral",14,14,1.3,{"roads"}},
    {"ali_farm","泉縁の果実園","alikr","farm",4700,290,"neutral",8,10,1.0,{}},
    {"ali_market","金砂の量衡所","alikr","market",11500,680,"iron",22,16,1.6,{"roads"}},
}
for _, r in ipairs(rows) do
    D.properties[#D.properties+1] = {
        id=r[1], name=r[2], zone=r[3], category=r[4], marketValue=r[5], expectedProfit=r[6],
        owner=r[7], independenceRisk=r[8], independenceIncrease=r[9], gaugeAcceleration=r[10],
        groups=r[11], isHeadquarters=r[12] or false,
        negotiationResistances={rumor=r[4]=="mages" and 1 or .2, gift=r[4]=="fighters" and 1 or 0},
    }
end
