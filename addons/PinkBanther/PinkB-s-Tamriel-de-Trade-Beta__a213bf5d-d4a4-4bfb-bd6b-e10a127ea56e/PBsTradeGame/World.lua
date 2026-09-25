-- Explicit coverage catalog; no network access or random generation at runtime.
-- Includes all named trade regions in docs/WORLD.md; instances are not regions.
local D=PBTrade.Data
local catalog={
    -- id, display name, business naming motif, economic biome, unlock tier, map abbreviation
    {"auridon","オーリドン","朝凪","island",0},
    {"grahtwood","グラーウッド","樹冠","forest",0},
    {"greenshade","グリーンシェイド","翠雨","forest",1},
    {"reapers","リーパーズ・マーチ","双月","savanna",1},
    {"stonefalls","ストーンフォール","灰峰","volcanic",2},
    {"deshaan","デシャーン","蓮灰","marsh",2},
    {"rift","リフト","白樺","nord",3},
    {"stormhaven","ストームヘヴン","風見","breton",0},
    {"rivenspire","リベンスパイアー","霧鐘","breton",3},
    {"alikr","アリクル砂漠","砂星","desert",1},
    {"khenarthi","ケナーシズルースト","風羽","island",0},
    {"malabal","マラバル・トール","深枝","forest",2},
    {"glenumbra","グレナンブラ","獅子湾","breton",0},
    {"bangkorai","バンコライ","峠旗","desert",2},
    {"stros","ストロス・エムカイ","赤帆","island",0},
    {"betnikh","ベトニク","砦潮","island",1},
    {"bleakrock","ブリークロック島","雪帆","nord",0},
    {"balfoyen","バル・フォイエン","葦舟","marsh",0},
    {"eastmarch","イーストマーチ","湯霜","nord",2},
    {"shadowfen","シャドウフェン","黒葦","marsh",2},
    {"cyrodiil","シロディール","白塔","imperial",3},
    {"imperialcity","帝都","六区","imperial",4},
    {"sewers","帝都下水道","暗渠","underground",4},
    {"craglorn","クラグローン","星砂","desert",3},
    {"wrothgar","ロスガー","雪牙","nord",3},
    {"hewsbane","ヒューズベイン","宵港","desert",2},
    {"goldcoast","ゴールドコースト","金岸","imperial",2},
    {"vvardenfell","ヴァーデンフェル","火山硝","volcanic",3},
    {"summerset","サマーセット","白珊瑚","island",3},
    {"murkmire","マークマイア","泥蓮","marsh",3},
    {"northelsweyr","北エルスウェア","月砂","savanna",3},
    {"southelsweyr","南エルスウェア","蜜月","savanna",3},
    {"tideholm","タイドホルム","竜潮","island",4},
    {"westskyrim","西スカイリム","孤峰","nord",3},
    {"reach","リーチ","石蔦","nord",4},
    {"blackreach_greymoor","ブラックリーチ：グレイムーア洞窟","青燐","underground",4,"グレイムーア洞窟"},
    {"blackreach_arkthzand","ブラックリーチ：アークスザンド洞窟","赤燐","underground",4,"アークスザンド洞窟"},
    {"blackwood","ブラックウッド","黒樫","marsh",3},
    {"highisle","ハイ・アイルとアメノス","騎士帆","island",4},
    {"galen","ガレンとイフェロン","蔦火","forest",4},
    {"telvanni","テルヴァンニ半島","胞子灯","volcanic",4},
    {"westweald","ウェストウィールド","葡萄金","imperial",4},
    {"solstice","ソルスティス","陽潮","island",4},
    {"coldharbour","コールドハーバー","虚灯","realm",5},
    {"clockwork","クロックワーク・シティ","歯車","mechanical",5},
    {"brassfortress","真鍮要塞","真鍮","mechanical",5},
    {"artaeum","アルテウム","時環","arcane",5},
    {"eyevea","アイベア","秘文","arcane",5},
    {"earthforge","アースフォージ","地炉","underground",5},
    {"deadlands","デッドランド","灼鉄","realm",5},
    {"fargrave","ファーグレイブ","骸星","realm",5},
    {"apocrypha","アポクリファ","墨海","arcane",5},
    {"nightmarket","ナイトマーケット","宵骨","realm",5},
}
D.zones={}; D.zoneById={}; D.propertyById={}; D.propertyIdsByZone={}
local biomeCategories={
    island={"port","jewelry","tailor","farm","market","inn","alchemy","caravan"},
    forest={"lumber","alchemy","farm","tailor","tavern","caravan","books","market"},
    savanna={"caravan","ranch","farm","market","tailor","inn","jewelry","tavern"},
    volcanic={"mine","forge","mages","alchemy","jewelry","books","caravan","market"},
    marsh={"alchemy","farm","port","lumber","inn","market","tailor","caravan"},
    nord={"mine","forge","ranch","tavern","lumber","fighters","inn","caravan"},
    breton={"market","books","forge","farm","inn","tailor","fighters","jewelry"},
    desert={"caravan","jewelry","market","mine","tailor","inn","farm","fighters"},
    imperial={"market","farm","port","books","forge","tavern","caravan","fighters"},
    underground={"mine","forge","alchemy","caravan","jewelry","fighters","market","books"},
    realm={"caravan","market","alchemy","forge","mages","inn","books","jewelry"},
    mechanical={"forge","mine","alchemy","mages","market","caravan","books","jewelry"},
    arcane={"books","mages","alchemy","jewelry","market","tailor","inn","caravan"},
}
D.businessProfiles={
    {id="steady",name="堅実経営",yield=.048,risk=5,increase=6,acceleration=.8,description="利益率は控えめですが、資金要求への耐性を重視した経営です。"},
    {id="growth",name="高収益・高負担",yield=.095,risk=27,increase=19,acceleration=1.1,description="大きな利益を生む反面、再投資を削る出資への反発が強い事業です。"},
    {id="network",name="伝達・機動型",yield=.060,risk=15,increase=12,acceleration=2.1,description="調達額よりも交渉の勢いを生む連絡網に強みがあります。"},
    {id="anchor",name="資産保全型",yield=.038,risk=8,increase=8,acceleration=1.3,description="資産価値を守り、系列の安定した拠点となる事業です。"},
}
-- Generated businesses still have stable IDs, but their display names are assembled from
-- regional heraldry, terrain vocabulary and trade-specific house names.  This keeps all
-- 1,272 generated names distinct without touching the individually authored or ESO names.
local nameMarks={"黎明","黄昏","灯火","疾風","北星","銀月","円環","白翼"}
local biomeEmblems={
    island={"潮","白帆","珊瑚"}, forest={"若葉","古根","樹冠"}, savanna={"陽炎","双月","金草"},
    volcanic={"火硝","黒曜","熔鉄"}, marsh={"葦露","泥蓮","蛍沼"}, nord={"霜","雪角","炉火"},
    breton={"青盾","石橋","薔薇"}, desert={"砂鐘","星泉","金砂"}, imperial={"白塔","月桂","赤鷲"},
    underground={"青燐","深晶","残響"}, realm={"虚空","骸星","鎖炎"},
    mechanical={"真鍮","歯環","時針"}, arcane={"秘文","星霊","時環"},
}
local businessNames={
    mine={"採掘坑","鉱脈院","鉱業会"}, lumber={"製材座","材木商館","樵業組合"},
    forge={"鍛造房","炉匠院","鉄工組合"}, tailor={"織房","服飾商館","染織組合"},
    alchemy={"調合所","霊薬院","錬金商会"}, tavern={"酒房","醸造亭","杯商会"},
    inn={"旅籠","客館","宿泊組合"}, port={"波止場","港務院","海運商館"},
    caravan={"隊商宿","駅逓院","運送組合"}, farm={"果樹園","耕作院","農産商会"},
    ranch={"牧場","厩務院","畜産組合"}, books={"書房","写本院","書籍商会"},
    mages={"秘術工房","魔導院","呪具商会"}, fighters={"護衛所","武門会館","傭兵組合"},
    jewelry={"彫金房","宝玉院","宝飾商会"}, market={"市庭","取引院","交易商館"},
}
local kanaRegionRoots={
    auridon="オーリドン",grahtwood="グラーウッド",greenshade="グリーンシェイド",reapers="リーパーズマーチ",
    stonefalls="ストーンフォール",deshaan="デシャーン",rift="リフト",stormhaven="ストームヘヴン",
    rivenspire="リベンスパイアー",alikr="アリクル",khenarthi="ケナーシズルースト",malabal="マラバルトール",
    glenumbra="グレナンブラ",bangkorai="バンコライ",stros="ストロスエムカイ",betnikh="ベトニク",
    bleakrock="ブリークロック",balfoyen="バルフォイエン",eastmarch="イーストマーチ",shadowfen="シャドウフェン",
    cyrodiil="シロディール",imperialcity="インペリアルシティ",sewers="インペリアルセワーズ",craglorn="クラグローン",
    wrothgar="ロスガー",hewsbane="ヒューズベイン",goldcoast="ゴールドコースト",vvardenfell="ヴァーデンフェル",
    summerset="サマーセット",murkmire="マークマイア",northelsweyr="ノーザンエルスウェア",southelsweyr="サザンエルスウェア",
    tideholm="タイドホルム",westskyrim="ウェスタンスカイリム",reach="リーチ",blackreach_greymoor="グレイムーアブラックリーチ",
    blackreach_arkthzand="アークスザンドブラックリーチ",blackwood="ブラックウッド",highisle="ハイアイルアメノス",
    galen="ガレンイフェロン",telvanni="テルヴァンニ",westweald="ウェストウィールド",solstice="ソルスティス",
    coldharbour="コールドハーバー",clockwork="クロックワークシティ",brassfortress="ブラスフォートレス",
    artaeum="アルテウム",eyevea="アイベア",earthforge="アースフォージ",deadlands="デッドランド",
    fargrave="ファーグレイブ",apocrypha="アポクリファ",nightmarket="ナイトマーケット",
}
local kanaMarks={"アルバ","ヴェスパー","ルーメン","ゼフィール","アステル","アルジェン","オルビス","アラ",
    "カンパナ","ヴェラム","セレネ","ノクス","ソラリス","ウンブラ","コロナ","ファロス",
    "ミラージュ","テンペスト","ルーン","シグナム","オーロラ","クレスト","エクリプス","フォルトゥナ"}
local kanaBusiness={mine="マイニング",lumber="ティンバー",forge="フォージ",tailor="アトリエ",alchemy="アルケミア",
    tavern="タヴェルナ",inn="ロッジ",port="ハーバー",caravan="キャラバン",farm="オーチャード",ranch="ランチ",
    books="スクリプトリウム",mages="アルカナ",fighters="ガード",jewelry="ジュエルズ",market="バザール"}
local kanaSlots={ [1]=true,[3]=true,[6]=true,[8]=true,[10]=true,[13]=true,[15]=true,[18]=true,[20]=true,[23]=true }
local function generatedBusinessName(zone,category,slot)
    if kanaSlots[slot] then
        return assert(kanaRegionRoots[zone.id]).."・"..kanaMarks[slot].."・"..assert(kanaBusiness[category]),true
    end
    local cycle=math.floor((slot-1)/8)+1
    local mark=nameMarks[(slot-1)%8+1]
    local emblem=assert(biomeEmblems[zone.biome])[cycle]
    local house=assert(businessNames[category])[cycle]
    if cycle==1 then return zone.motif.."の"..mark..emblem..house,false end
    if cycle==2 then return mark..emblem.."の"..zone.motif..house,false end
    return zone.motif.."・"..mark..emblem..house,false
end
local function contains(list,id) for _,v in ipairs(list) do if v==id then return true end end end
local tacticKeys={"smile","gift","rumor","bard","justice","messenger","falseMessenger","banquet","council","freeze","bargain","defection","roots"}
for i,z in ipairs(catalog) do
    local zone={id=z[1],name=z[2],motif=z[3],biome=z[4],unlockTier=z[5],shortName=z[6] or z[2],
        atlas=i>=44 and "beyond" or "tamriel",minChapter=i>=44 and 5 or 1,catalogIndex=i}
    if z[1]=="nightmarket" then zone.eventRegion=true end
    D.zones[#D.zones+1]=zone; D.zoneById[zone.id]=zone; D.propertyIdsByZone[zone.id]={}
    D.groups["region_"..zone.id]={name=zone.name.."交易連合",minimum=3,bonus=1.35,discoveryChance=.15}
    -- Region-wide grand market: most of a zone's businesses under one banner.
    D.groups["grand_"..zone.id]={name=zone.name.."大商圏",minimum=10,bonus=2.2,discoveryChance=.12,discoverAt=10,tier="grand"}
end
-- Super-scale groups: the three alliances, the imperial heartland and all of Tamriel.
-- They can only be discovered once their full activation requirement is already owned.
D.alliances={
    {id="alliance_dominion",name="アルドメリ・ドミニオン交易同盟",zones={"auridon","khenarthi","grahtwood","greenshade","malabal","reapers","summerset"}},
    {id="alliance_covenant",name="ダガーフォール・カバナント交易同盟",zones={"stros","betnikh","glenumbra","stormhaven","rivenspire","alikr","bangkorai"}},
    {id="alliance_pact",name="エボンハート・パクト交易同盟",zones={"bleakrock","balfoyen","stonefalls","deshaan","shadowfen","eastmarch","rift"}},
    {id="imperial_heartland",name="帝国中枢商圏",zones={"cyrodiil","imperialcity","sewers","goldcoast"},minimum=20,bonus=2.8},
}
D.allianceByZone={}
for _,a in ipairs(D.alliances) do
    D.groups[a.id]={name=a.name,minimum=a.minimum or 30,bonus=a.bonus or 3.0,discoveryChance=.1,discoverAt=a.minimum or 30,tier="alliance"}
    for _,zoneId in ipairs(a.zones) do D.allianceByZone[zoneId]=a.id end
end
D.groups.tamriel={name="タムリエル大交易網",minimum=120,bonus=4.0,discoveryChance=.08,discoverAt=120,tier="tamriel"}
for category,name in pairs(D.categories) do D.groups["industry_"..category]={name=name.."職能組合",minimum=4,bonus=1.5,discoveryChance=.12} end
-- Thematic groups shared by generated properties and real ESO places.
function D.ThemeGroups(zone,category)
    local groups={}
    if (zone.id=="grahtwood" or zone.id=="greenshade" or zone.id=="malabal") and category=="lumber" then groups[#groups+1]="valenwood" end
    if (zone.id=="auridon" or zone.id=="summerset") and category=="jewelry" then groups[#groups+1]="jewels" end
    if zone.biome=="volcanic" and category=="mine" then groups[#groups+1]="mines" end
    if category=="tavern" or category=="inn" then groups[#groups+1]="hospitality" end
    if category=="caravan" or category=="port" then groups[#groups+1]="roads" end
    return groups
end
-- Real places visited in ESO form their own trade route and strengthen every group they join.
D.groups.landmarks={name="名所巡り商路",minimum=3,bonus=1.6,discoveryChance=.2}
local function indexProperty(p)
    assert(not D.propertyById[p.id],"Duplicate property ID: "..p.id)
    local region="region_"..p.zone; local industry="industry_"..p.category
    if not contains(p.groups,region) then p.groups[#p.groups+1]=region end
    if not contains(p.groups,industry) then p.groups[#p.groups+1]=industry end
    local zoneData=D.zoneById[p.zone]
    local grand="grand_"..p.zone; if not contains(p.groups,grand) then p.groups[#p.groups+1]=grand end
    local alliance=D.allianceByZone[p.zone]; if alliance and not contains(p.groups,alliance) then p.groups[#p.groups+1]=alliance end
    if zoneData and zoneData.atlas=="tamriel" and not contains(p.groups,"tamriel") then p.groups[#p.groups+1]="tamriel" end
    if p.canonical then
        local zone=D.zoneById[p.zone]
        for _,id in ipairs(zone and D.ThemeGroups(zone,p.category) or {}) do
            if not contains(p.groups,id) then p.groups[#p.groups+1]=id end
        end
        if not contains(p.groups,"landmarks") then p.groups[#p.groups+1]="landmarks" end
    end
    D.propertyById[p.id]=p
    local ids=assert(D.propertyIdsByZone[p.zone]); ids[#ids+1]=p.id
end
D.AddProperty=indexProperty
for _,p in ipairs(D.properties) do indexProperty(p) end
-- One ordinary trading company is rooted in every region.  Four established companies use
-- their existing headquarters; the remaining regions receive a local company whose body is
-- itself a purchasable property.  Boss organisations are added separately below.
local legacyRegionalCompanies={stormhaven="amber",rivenspire="ash",stonefalls="iron",glenumbra="ink"}
local companyLabels={"商会","交易社","産業組合","共同商団","物産会"}
local companyPersonalities={"steady","wealth","aggressive","information","subversion"}
local companyTactics={steady="smile",wealth="gift",aggressive="messenger",information="rumor",subversion="defection"}
local regionalCompanyByZone={}
for zi,z in ipairs(D.zones) do
    local id=legacyRegionalCompanies[z.id] or ("regional_"..z.id)
    regionalCompanyByZone[z.id]=id
    if not D.companies[id] then
        local katakana=zi%5==1 or zi%5==2
        local personality=companyPersonalities[(zi-1)%#companyPersonalities+1]
        D.companies[id]={id=id,
            name=katakana and (assert(kanaRegionRoots[z.id]).."・トレーディング") or (z.motif..companyLabels[(zi-1)%#companyLabels+1]),
            cash=14000+z.unlockTier*4500+zi*650,personality=personality,
            aggression=.38+(zi*7%39)/100,defense=.40+(zi*11%41)/100,
            tacticBias=companyTactics[personality],acquisitionBias=biomeCategories[z.biome][1],
            minChapter=z.minChapter,alliances={},ordinaryCompany=true,homeZone=z.id,katakanaName=katakana}
    else
        D.companies[id].ordinaryCompany=true; D.companies[id].homeZone=z.id
    end
end
-- These established Great Houses dominate their home regions while retaining the ordinary
-- company rules: one directly purchasable body and a 10–20 property starting portfolio.
D.companies.regional_telvanni.name="テルヴァンニ家"
D.companies.regional_telvanni.katakanaName=true
D.companies.veil.bossCompany=true; D.companies.worm.bossCompany=true; D.companies.molag.bossCompany=true
local reservedBossBodyZones={grahtwood=true,deshaan=true,rivenspire=true,bangkorai=true,eastmarch=true,cyrodiil=true,
    coldharbour=true,deadlands=true,fargrave=true}
local regionalBodySlot={}
for _,z in ipairs(D.zones) do
    if not legacyRegionalCompanies[z.id] then regionalBodySlot[z.id]=reservedBossBodyZones[z.id] and 23 or 24 end
end
for zi,z in ipairs(D.zones) do
    local categories=biomeCategories[z.biome]
    for slot=1,24 do
        local category=categories[(slot-1)%#categories+1]
        local profile=D.businessProfiles[(slot+math.floor((slot-1)/#categories)+zi-2)%#D.businessProfiles+1]
        local value=math.floor((1800+z.unlockTier*1250+slot*210+(zi*137)%1100)*(1+(slot%3)*.15)/50)*50
        local owner="neutral"; local minChapter=z.minChapter
        local regionalSlot=slot<=10 or (slot>=12 and slot<=16) or slot==24 or regionalBodySlot[z.id]==slot
        if regionalCompanyByZone[z.id]=="amber" and slot==16 then regionalSlot=false end
        if regionalSlot then owner=regionalCompanyByZone[z.id]
        elseif z.atlas=="beyond" then owner="molag"
        elseif slot==11 then owner="veil"; minChapter=3
        elseif slot==17 then owner="worm"; minChapter=4 end
        local groups=D.ThemeGroups(z,category)
        local resistances={}
        for ti,key in ipairs(tacticKeys) do
            resistances[key]=((slot+zi+ti)%5)*.15
        end
        resistances.roots=0; resistances.council=0; resistances.messenger=0
        if category=="fighters" then resistances.gift=1 end
        if category=="mages" then resistances.rumor=1 end
        local generatedName,katakanaName=generatedBusinessName(z,category,slot)
        local p={id=z.id.."_trade_"..string.format("%02d",slot),
            name=generatedName,zone=z.id,category=category,
            marketValue=value,expectedProfit=math.floor(value*profile.yield),owner=owner,
            independenceRisk=profile.risk+(zi%4),independenceIncrease=profile.increase,
            gaugeAcceleration=profile.acceleration+(slot%3)*.1,groups=groups,
            negotiationResistances=resistances,isHeadquarters=false,
            businessProfile=profile.id,profileName=profile.name,
            description=z.name.."に根を張る独立事業者。"..profile.description,
            minChapter=minChapter,generatedName=true,katakanaName=katakanaName,
        }
        D.properties[#D.properties+1]=p; indexProperty(p)
    end
end
-- The true last acquisition in chapter 5. It is absent from the market until the
-- three outer-realm headquarters are all under the player's banner.
local finalResistances={}
for _,key in ipairs(tacticKeys) do finalResistances[key]=.75 end
finalResistances.roots=0; finalResistances.council=0; finalResistances.messenger=0
local finalStronghold={
    id="molag_bal_citadel",name="モラグ・バルの居城",zone="coldharbour",category="mages",
    marketValue=75000,expectedProfit=4875,owner="molag",
    independenceRisk=64,independenceIncrease=24,gaugeAcceleration=3.4,groups={},
    negotiationResistances=finalResistances,isHeadquarters=true,businessProfile="anchor",profileName="最終中枢",
    description="三つの異界中枢を束ねるモラグ・バル コンツェルン最後の居城。外郭三社をすべて買収した商会だけが、その帳簿へ挑めます。",
    minChapter=5,finalStronghold=true,
    requiresProperties={"coldharbour_trade_24","deadlands_trade_24","fargrave_trade_24"},
}
D.properties[#D.properties+1]=finalStronghold; indexProperty(finalStronghold)
local campaignHeadquarters={
    grahtwood_trade_24="veil",deshaan_trade_24="veil",rivenspire_trade_24="veil",
    bangkorai_trade_24="worm",eastmarch_trade_24="worm",cyrodiil_trade_24="worm",
}
local campaignHeadquartersNames={
    grahtwood_trade_24="樹冠盟約の大評議所",deshaan_trade_24="灰蓮の封印商府",rivenspire_trade_24="霧冠の守護院",
    bangkorai_trade_24="星砂の黒繭会堂",eastmarch_trade_24="凍炉の黒繭商城",cyrodiil_trade_24="白塔地下の繭議院",
    coldharbour_trade_24="コールドハーバー・チェイン・コンツェルン",
    deadlands_trade_24="デッドランド・フレイム・コンツェルン",
    fargrave_trade_24="ファーグレイブ・ゲート・コンツェルン",
}
for id,owner in pairs(campaignHeadquarters) do
    local p=assert(D.propertyById[id]); p.owner=owner; p.minChapter=D.companies[owner].minChapter; p.name=campaignHeadquartersNames[id] or p.name
end
-- Company headquarters: owning every one of a company's headquarters dissolves the company
-- and brings all of its remaining properties under the player's banner.
D.companyHeadquarters={
    amber={"str_hq"}, ash={"riv_hq"}, ink={"glenumbra_trade_24"}, iron={"stonefalls_trade_24"},
    veil={"grahtwood_trade_24","deshaan_trade_24","rivenspire_trade_24"},
    worm={"bangkorai_trade_24","eastmarch_trade_24","cyrodiil_trade_24"},
    molag={"coldharbour_trade_24","deadlands_trade_24","fargrave_trade_24","molag_bal_citadel"},
}
for id,name in pairs(campaignHeadquartersNames) do
    local p=D.propertyById[id]; if p then p.name=name end
end
for _,z in ipairs(D.zones) do
    local company=regionalCompanyByZone[z.id]
    if not legacyRegionalCompanies[z.id] then
        local id=z.id.."_trade_"..string.format("%02d",regionalBodySlot[z.id])
        D.companyHeadquarters[company]={id}
        local p=assert(D.propertyById[id]); p.name=D.companies[company].name; p.owner=company; p.companyBody=true
        p.katakanaName=D.companies[company].katakanaName or false
    end
end
-- A rival can be taken over from its own chapter onward (headquarters bought earlier still count).
D.companyTakeoverChapter={amber=1,ash=1,iron=1,ink=1,veil=3,worm=4,molag=5}
for company in pairs(D.companyHeadquarters) do
    if D.companies[company].ordinaryCompany then D.companyTakeoverChapter[company]=1 end
end
D.headquartersOf={}
local ordinaryBodyNames={ink="エリック社本館",iron="鉄環輸送組合本部",ash="レイヴンウォッチ城館"}
for company,ids in pairs(D.companyHeadquarters) do
    for _,id in ipairs(ids) do
        local p=assert(D.propertyById[id],"missing headquarters "..id)
        p.owner=company; p.isHeadquarters=true; p.companyHeadquarters=company
        if D.companies[company].ordinaryCompany then
            p.companyBody=true
            if ordinaryBodyNames[company] then p.name=ordinaryBodyNames[company] end
        end
        if (D.companies[company].minChapter or 1)>(p.minChapter or 1) then p.minChapter=D.companies[company].minChapter end
        D.headquartersOf[id]=company
    end
end
D.campaigns={
    {id=1,title="第1章　小さな羅針盤",subtitle="商会の足場を築く",background="chapter_1",
        description="二つの小さな事業を束ね、八十期を見据えた商会の土台を築きます。成長する市場で買収先を見極め、総資産70億ゴールドを達成してください。",
        objective={type="assets",target=PBTrade.Config.campaign.chapterOneAssets,minimumCycles=80}},
    {id=2,title="第2章　琥珀帆を越えて",subtitle="大商会への挑戦",background="chapter_2",
        description="市場は毎期複利で拡大し、琥珀帆商会も再投資を続けます。第200期と総資産5000億ゴールドを越え、大交易所を獲得してください。",
        objective={type="properties",targets={"str_hq"},assetTarget=50000000,minimumCycles=200}},
    {id=3,title="第3章　ベールの向こう側",subtitle="守護者連合を解体する",background="chapter_3",
        description="長期成長した三つの中枢を奪い、第350期を越え、総資産40兆ゴールドの広域商会を築いて守護者連合を解体してください。",
        objective={type="properties",targets={"grahtwood_trade_24","deshaan_trade_24","rivenspire_trade_24"},assetTarget=4000000000,minimumCycles=350}},
    {id=4,title="第4章　黒繭の帳簿",subtitle="虫の教団を解体する",background="chapter_4",
        description="黒繭交易教団は膨張した市場を直接支配します。第525期、総資産5000兆ゴールド、三中枢の支配をすべて満たしてください。",
        objective={type="properties",targets={"bangkorai_trade_24","eastmarch_trade_24","cyrodiil_trade_24"},assetTarget=500000000000,minimumCycles=525}},
    {id=5,title="第5章　鎖の外へ",subtitle="モラグ・バル コンツェルンとの戦い",background="chapter_5",
        description="帳簿の最終頁はタムリエルの外へ続いていました。異界三中枢を買収すると、コンツェルン最後の物件「モラグ・バルの居城」への道が開きます。資金源の消耗と離反を抑えながら、第750期、総資産300京ゴールド、居城の買収をすべて達成してください。",
        objective={type="properties",targets={"coldharbour_trade_24","deadlands_trade_24","fargrave_trade_24","molag_bal_citadel"},assetTarget=300000000000000,minimumCycles=750}},
}
-- Convert the former abstract unit to gold.  Every property/company gets a deterministic
-- lower-than-10,000 remainder; campaign milestones stay deliberately round.
for _,p in ipairs(D.properties) do
    p.marketValue=PBTrade.Config.Money(p.marketValue,p.id..":value")
    p.expectedProfit=PBTrade.Config.Money(p.expectedProfit,p.id..":profit")
end
for id,company in pairs(D.companies) do company.cash=PBTrade.Config.Money(company.cash,id..":cash") end
for _,chapter in ipairs(D.campaigns) do
    if chapter.objective.assetTarget then chapter.objective.assetTarget=PBTrade.Config.Money(chapter.objective.assetTarget) end
end
D.catalogVersion=5
local staticNames={}
for _,p in ipairs(D.properties) do
    assert(not staticNames[p.name],"Duplicate property name: "..p.name)
    staticNames[p.name]=p.id
end
assert(#D.properties>=1000,"Trade catalog must contain at least 1000 properties")
