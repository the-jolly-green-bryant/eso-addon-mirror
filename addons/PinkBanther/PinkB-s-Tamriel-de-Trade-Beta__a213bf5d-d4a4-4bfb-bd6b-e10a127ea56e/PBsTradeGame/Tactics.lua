local D=PBTrade.Data
D.tactics={
    {id="smile",name="商人の微笑み",cost=0,resistanceKey="smile",effect={type="playerAcceleration",amount=.35,duration=12},learn={starting=true},description="自社側の加速度を穏やかに高める。",
        scene={act="穏やかな笑みを崩さず、相手の言葉にゆっくりと頷く……",success="場の空気が和らぎ、交渉の流れがこちらへ傾いた。",resist="相手の目は笑っていない。愛想は通じなかった。"}},
    {id="gift",name="心づけ",cost=500,resistanceKey="gift",effect={type="playerAcceleration",amount=1.35,duration=10},learn={result="won",chance=.28},description="資金を贈り、自社側の加速度を大きく高める。",
        scene={act="封蝋付きの小箱をそっと卓上へ滑らせる……",success="受け取った手が止まり、相手の口調が明らかに柔らいだ。",resist="「職能の誇りを金で買えるとでも？」箱は突き返された。"}},
    {id="rumor",name="悪評を流す",cost=250,resistanceKey="rumor",effect={type="enemyAccelerationPenalty",amount=.90,duration=12},learn={category="books",chance=.30},description="相手商会の勢いを削ぐ。",
        scene={act="酒場の片隅で、相手商会の帳簿の噂を囁かせる……",success="噂は街を駆け巡り、相手の出資者たちがざわめき始めた。",resist="相手は噂を一笑に付した。誰も耳を貸さない。"}},
    {id="bard",name="吟遊詩人を雇う",cost=400,resistanceKey="bard",effect={type="velocity",amount=-2.6},learn={category="tavern",chance=.26},description="世論を動かし、ゲージ速度を自社側へ押す。",
        scene={act="広場に吟遊詩人を立たせ、我らが商会の歌を響かせる……",success="群衆が歌を口ずさみ、世論が一気にこちらへ流れた！",resist="歌声は喧噪にかき消され、足を止める者はいなかった。"}},
    {id="justice",name="正当性を訴える",cost=100,resistanceKey="justice",effect={type="randomVelocity",amount=4.5},learn={result="lost",chance=.42},description="大きな成功と失敗の両方があり得る訴え。",
        scene={act="評議の場に立ち、この買収の正当性を声高に訴える……",success="訴えは胸を打ち、場内がこちらの味方についた！",resist="言葉が過ぎた。場内の視線が冷たく突き刺さる……"}},
    {id="messenger",name="俊足の伝令",cost=300,resistanceKey="messenger",effect={type="playerWaitMultiplier",amount=.55,duration=16},learn={category="caravan",chance=.30},description="自社の伝令待ち時間を短縮する。",
        scene={act="最速の伝令に替え馬を用意させ、街道へ走らせる……",success="蹄の音が遠ざかる。次の報せは驚くほど早く届くだろう。",resist="関所で足止めを食らった。伝令の脚は活かせない。"}},
    {id="falseMessenger",name="偽の伝令",cost=350,resistanceKey="falseMessenger",effect={type="enemyWait",amount=3.5},learn={category="books",chance=.24},description="相手の次の資金投入を遅らせる。",
        scene={act="相手の伝令に偽の指示書を掴ませる……",success="相手の伝令は見当違いの街道へ。次の出資は大きく遅れる。",resist="偽書は見破られた。相手の伝令は迷わず駆けていく。"}},
    {id="banquet",name="豪華な宴席",cost=900,resistanceKey="banquet",effect={type="delayedAcceleration",amount=2.0,delay=4,duration=10},learn={category="inn",chance=.24},description="次周期から自社側の速度を強く押す。",
        scene={act="燭台が並ぶ大広間に、有力者たちを招き入れる……",success="杯が重なるたび、影響力がじわりと広がっていく。",resist="招待客の多くは席を立った。宴は空回りに終わる。"}},
    {id="council",name="評議会を招集",cost=200,resistanceKey="council",effect={type="resetWaits"},learn={defense=true,chance=.35},description="双方の伝令待ち時間を初期状態へ戻す。",
        scene={act="地元評議会の鐘を鳴らし、双方を議場へ呼び出す……",success="議長の木槌が響く。双方の伝令は振り出しに戻った。",resist="評議会は開かれなかった。空席の議場に鐘だけが響く。"}},
    {id="freeze",name="市場を凍結",cost=450,resistanceKey="freeze",effect={type="valueMultiplier",amount=1.45,duration=12},learn={category="mages",chance=.24},description="評価額を一時的に上げ、ゲージを動きにくくする。",
        scene={act="魔術師ギルドの印章で、市場の取引を一時封じる……",success="市場は凍りつき、評価額が跳ね上がった。天秤は動きにくい。",resist="封印は破られた。市場は何事もなく動き続ける。"}},
    {id="bargain",name="席を立つ",cost=150,resistanceKey="bargain",effect={type="valueMultiplier",amount=.68,duration=10},learn={category="market",chance=.30},description="評価額を一時的に下げ、ゲージを動きやすくする。",
        scene={act="「この値では話にならない」と席を立つ素振りを見せる……",success="相手は慌てて呼び止めた。評価額が目に見えて下がる。",resist="相手は動じない。「どうぞお帰りを」と扉を指した。"}},
    {id="defection",name="離反工作",cost=700,resistanceKey="defection",effect={type="enemyRisk",amount=28},learn={category="alchemy",chance=.20},description="交渉相手の独立危険度を高める。",
        scene={act="相手物件の番頭に、独立の甘い未来を吹き込む……",success="番頭の目に迷いが宿った。相手の足元が揺らぎ始める。",resist="番頭は忠義を貫いた。工作は相手の知るところとなった。"}},
    {id="roots",name="根回し",cost=500,resistanceKey="roots",effect={type="ownRisk",amount=-42},learn={category="farm",chance=.38},description="最も危険な自社物件を大きく安定させる。",
        scene={act="自社の最も不安な拠点へ、根回しの使者を送る……",success="使者の言葉が届き、拠点の動揺が大きく静まった。",resist="使者は門前払いを受けた。拠点の不満は燻ったままだ。"}},
}
-- Negotiation stances: how an opponent guards a property. While a stance holds, money is
-- counted at `weights` toward the border (by source); the matching counter breaks it, after
-- which everything already contributed counts in full. Critical negotiations need two hits.
D.stances={
    {id="vault",name="鉄壁の金庫",short="資金半減",
        hint="資金の効きが半分以下。心づけ・宴席・市場凍結・席を立つで崩せる",
        weights={request=.45,group=.45,ally=.45,treasury=.45},breakers={gift=true,banquet=true,freeze=true,bargain=true}},
    {id="courier",name="電撃の伝令網",short="相手倍速",
        hint="相手の出資が倍の速さで届く。偽の伝令・評議会・俊足の伝令で崩せる",
        weights={request=.8,group=.8,ally=.8,treasury=.8},enemyWait=.4,enemyBudget=1.4,breakers={falseMessenger=true,council=true,messenger=true}},
    {id="bloc",name="系列の結束",short="単独出資半減",
        hint="単独の出資が半分しか効かない。グループ・同盟の出資か離反工作で崩せる",
        weights={request=.5,group=1.3,ally=1.3,treasury=.5},breakers={defection=true},breakByGroup=true,breakByAlly=true},
    {id="opinion",name="世論の盾",short="自社資金無効",
        hint="自社資金がほとんど効かない。吟遊詩人・正当性を訴える・悪評を流すで崩せる",
        weights={request=.7,group=.8,ally=.8,treasury=.3},breakers={bard=true,justice=true,rumor=true}},
}
D.stanceById={}
for _,stance in ipairs(D.stances) do D.stanceById[stance.id]=stance end
D.tacticById={}
for _,tactic in ipairs(D.tactics) do D.tacticById[tactic.id]=tactic end
return D.tactics
