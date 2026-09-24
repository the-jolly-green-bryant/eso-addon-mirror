-- Opening narration, told sound-novel style: each page types out over its background.
local D=PBTrade.Data
local S={}; PBTrade.Story=S
D.opening={
    {bg="atlas",text="第二紀。\n三つの旗がタムリエルを裂き、剣戟の音が大陸を覆っていた。\nだが戦場の外にも、もう一つの戦がある。"},
    {bg="treasury",text="塩と香辛料、鉄と絹、酒と噂。\n帳簿に記された一行が、ときに千の兵よりも国を動かす。\n人はそれを――交易戦と呼んだ。"},
    {bg="chapter_1",text="港町の片隅に、看板の文字もかすれた小さな商館がある。\n手元に残ったのは、わずかな金貨と二つの小さな事業。\nそして、一枚の古い羅針盤だけ。"},
    {bg="chapter_2",text="琥珀の帆を掲げる大商会が港と市場を束ね、\n鉄の輪の組合が街道を押さえ、\n銀の墨で綴られた帳簿が、商人たちの秘密を握っている。"},
    {bg="chapter_3",text="その背後では……\nベールをまとう守護者たちが、\n黒い繭の奥で囁く者たちと、密かに契約を交わしているという。"},
    {bg="chapter_5",text="帳簿の最後の頁は、タムリエルの外へと続いていた。\n鎖の刻印。凍える炎。\n異界の主が、この大陸の富を量り始めている。"},
    {bg="chapter_4",text="金貨は剣より静かで、呪文より長く効く。\n物件を買い、連合を束ね、奪われれば奪い返す。\n一期、また一期と、帳簿を積み上げてゆくのだ。"},
    {bg="treasury",text="羅針盤の針が、ゆっくりと北を指す。\n――さあ、商会の名を記そう。\nタムリエルの帳簿に、最初の一行を。"},
}
-- True ending: shown once every buyable property belongs to the player. {company} is the
-- player's company name.
D.trueEnding={
    {bg="atlas",text="最後の証文に、封蝋が押された。\nタムリエルの交易地図から、他の商会の旗が一つ残らず消えていく。"},
    {bg="chapter_1",text="港町の片隅の、かすれた看板の商館。\nわずかな金貨と二つの事業から始まった帳簿は、\nいまや大陸そのものを綴っている。"},
    {bg="chapter_3",text="ベールは剥がれ、黒い繭は解かれ、\n異界の鎖は断ち切られた。\n剣が決められなかったことを、帳簿が決めたのだ。"},
    {bg="treasury",text="金庫に積まれた金貨は、もはや数えきれない。\nだが本当の財は、港から港へ、街道から街道へと\n絶えず流れ続ける品と人と約束のほうにある。"},
    {bg="chapter_4",text="三つの旗の戦はまだ終わらない。\nそれでも、兵がどの旗を掲げていようと、\n彼らのパンも、塩も、鉄も――{company}を通って届く。"},
    {bg="chapter_5",text="羅針盤の針が、静かに止まる。\n北でも南でもない。帳簿の最初の頁、あの小さな商館を指して。"},
    {bg="atlas",text="{company}\nタムリエル交易戦――完。\n\nそして帳簿は、次の頁へ。"},
}
-- Reveal timing: a steady pace with pauses after punctuation and line breaks.
local pauses={["、"]=.18,["。"]=.42,["…"]=.14,["―"]=.06,["！"]=.35,["？"]=.35,["\n"]=.32}
local cache={}
function S.Timeline(text)
    local timeline=cache[text]; if timeline then return timeline end
    local chars,times,t={},{},0
    for ch in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        t=t+PBTrade.Config.opening.charSeconds
        chars[#chars+1]=ch; times[#times+1]=t
        t=t+(pauses[ch] or 0)
    end
    -- A client string implementation may not support this byte-pattern splitter.
    -- Display the original page intact instead of constructing a nil concat range.
    if #chars==0 and text~="" then chars={text}; times={0}; t=0 end
    -- Keep the first sentence visible from the first rendered frame. Besides being easier to
    -- read, this prevents a dormant update callback from ever presenting an empty story page.
    local lead=#chars
    for i,ch in ipairs(chars) do if ch=="。" or ch=="！" or ch=="？" or ch=="\n" then lead=i; break end end
    timeline={chars=chars,times=times,total=t,lead=math.max(1,lead)}; cache[text]=timeline
    return timeline
end
-- Number of characters visible after `elapsed` seconds on a page.
function S.Visible(timeline,elapsed)
    local times=timeline.times; local lo,hi=0,#times
    while lo<hi do local mid=math.floor((lo+hi+1)/2); if times[mid]<=elapsed then lo=mid else hi=mid-1 end end
    return lo
end
return S
