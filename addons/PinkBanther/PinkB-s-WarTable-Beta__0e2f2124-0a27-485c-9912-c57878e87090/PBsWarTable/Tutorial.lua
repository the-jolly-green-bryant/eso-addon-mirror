-- Isolated practice boards use the production engine. Lesson gates never mutate it.
local T={};T.__index=T;PBWT.Tutorial=T
local E,C=PBWT.Engine,PBWT.Config
local L=C.VARIANTS.light -- the tutorial always teaches the light board
local function board(pieces)
 local s=E.New();s.factions={1,2}
 for _,p in ipairs(s.pieces) do p.alive=false end
 for _,v in ipairs(pieces or {}) do local p=s.pieces[v[1]];p.alive,p.x,p.y=true,v[2],v[3] end
 return s
end
T.lessons={
 {title='ダイスと選択権',text='×で六面ダイスを振ります。\n今回は練習用にあなた5、相手2。\n勝者は同盟の優先選択か先後選択を取得。敗者が残る権利を得ます。\n選ばれていない2同盟から残る側が選んで開始。\n好きな権利・同盟を選んでください。',opening=true,seed=function() return E.New(true) end},
 {title='木札を持ち上げて移動',text='この章は兵士1枚だけの練習盤です。\n金枠の兵士を×で選び、右隣の金枠へカーソルを動かして×。\n兵士は縦横1マス。通常行動は手番に1回です。\n移動か攻撃のどちらかを行います。',pieces={{2,1,3}},commands={{type='move',id=2,x=2,y=3}}},
 {title='旗を制圧して得点',text='木札を置くだけでは旗を支配できません。\n盤の右端からさらに右で「ターン終了」を選び、×。\n左旗を制圧して1点獲得します。\n旗は左1・中央2・右1点。離れても支配は続きます。',pieces={{2,2,3}},commands={{type='end_turn'}}},
 {title='斥候と同盟能力',text='斥候を選び、右へ3マスの金枠に移動。\n通常の斥候は最大2マスですが、ドミニオンなら3マスです。\n直進だけで、曲がれず、木札を飛び越せません。',pieces={{4,2,2}},commands={{type='move',id=4,x=5,y=2}}},
 {title='兵士で攻撃',text='自軍兵士を×で選び、右隣の敵兵士に×。\n攻撃2≧防御2なので撃破できます。\n反撃やHPの蓄積はなく、撃破しても自動では進みません。',pieces={{1,2,2},{7,3,2}},commands={{type='attack',id=1,target=7}}},
 {title='守護者の防御',text='兵士で下隣の旗上守護者を攻撃してみましょう。\n攻撃2では防御4を突破できず、通常行動だけを消費します。\n旗外でも守護者の防御は3。カバナントの兵士は旗上で防御3です。',pieces={{1,3,2},{12,3,3}},commands={{type='attack',id=1,target=12}}},
 {title='騎兵突撃から攻撃',text='□でカード、騎兵突撃を×。自軍兵士→中央旗を選び、2マス追加移動します。守護者は突撃できません。\n続けて同じ兵士を選び、右隣の敵を攻撃。\n突撃は通常行動を使わず、移動と攻撃を組み合わせられます。',pieces={{2,1,3},{7,4,3}},commands={{type='card',card='charge',id=2,x=3,y=3},{type='attack',id=2,target=7}}},
 {title='隠密',text='□→隠密を選び、金枠の斥候を指定。\n次の自分の手番開始まで攻撃対象になりません。位置は見えたまま、移動も旗制圧もできます。\n全カードは各軍1ゲームに各1回。',pieces={{4,2,3}},commands={{type='card',card='stealth',id=4}}},
 {title='パクトの支援と攻城',text='今回はあなたがパクト。味方守護者に隣接する兵士の攻撃は3です。\n□→攻城→兵士→下隣の敵守護者。\n攻城は旗由来の防御補正を消し、攻撃を＋1します。攻撃4≧防御3で撃破。攻城は通常行動も消費します。',seed=function() local s=board({{1,3,2},{6,2,2},{12,3,3}});s.factions={3,2};return s end,commands={{type='card',card='siege',id=1,target=12}}},
 {title='蘇生',text='□→蘇生を選び、左上の金枠を指定。\n撃破された兵士1体が初期配置エリアの空きマスに復帰します。\n斥候・守護者は蘇生できません。通常行動は消費しません。',pieces={{6,2,2}},commands={{type='card',card='revive',id=1,x=1,y=1}}},
 {title='角笛',text='□→角笛→金枠の兵士を選択。\n隣接する味方の兵士・斥候それぞれに追加1マス移動を与えます。守護者は対象外です。\n次に右隣の斥候を選び、下の中央旗へ移動。\n発動元は対象外。未使用分は手番終了で消えます。',pieces={{2,2,2},{4,3,2},{6,2,1}},commands={{type='card',card='horn',id=2},{type='horn_move',id=4,x=3,y=3}}},
 {title='星霜の書で決着',text='中央含む2旗支配・中央に自軍札・敵の旗占有なしが開封条件。\n盤左端から左で星霜の書を選び、×。4点＋通常行動を支払います。\n次にターン終了。練習相手は今回はパスし、星霜勝利を体験できます。\n実戦では読者は防御1、阻止されれば費用は戻りません。',seed=function() local s=board({{6,3,3},{2,2,3},{10,5,2}});s.score={4,6};s.flags={1,1,0};return s end,commands={{type='invoke_scroll'},{type='end_turn'}},opponentPass=true},
 {title='相手の開封を阻止',text='今度は相手が星霜の書を開封中です。\n自軍兵士を右へ1マス、左旗へ進めて阻止しましょう。\n中立旗でも、どれかの旗へ敵が進入すれば開封は即失敗。読者撃破でも阻止できます。',seed=function() local s=board({{2,1,3},{12,3,3},{8,4,3}});s.player,s.turn=2,2;s.score={0,4};s.flags={0,2,2};assert(E.Apply(s,2,{type='invoke_scroll'}));assert(E.Apply(s,2,{type='end_turn'}));return s end,commands={{type='move',id=2,x=2,y=3}}},
 {title=L.WIN_SCORE..'点で勝利',text='最後は通常の得点勝利です。ターン終了を選び、'..(L.WIN_SCORE-1)..'点から'..L.WIN_SCORE..'点にしましょう。\n最大'..L.MAX_TURNS..'手番は両者合計。未決着なら得点→支配旗数→残存木札数で判定し、同じなら引き分け。\n相手が開封中でも、先に'..L.WIN_SCORE..'点へ届けば得点勝利を優先します。',seed=function() local s=board({{2,2,3}});s.score[1]=L.WIN_SCORE-1;s.flags[1]=1;return s end,commands={{type='end_turn'}}},
}
function T.New() local self=setmetatable({index=1},T);self:Load();return self end
function T:Load()
 self.lesson=T.lessons[self.index];self.progress=1;self.complete=false
 self.state=self.lesson.seed and self.lesson.seed() or board(self.lesson.pieces)
end
function T:Next() if self.index<#T.lessons then self.index=self.index+1 else self.index=1 end;self:Load() end
function T:Apply(command)
 if self.complete then return false,'tutorial_next' end
 if self.lesson.opening then
  local c=command
  if c.type=='roll_dice' then c={type='roll_dice',roll=5} end
  local ok,why=E.Apply(self.state,1,c);if not ok then return ok,why end
  while self.state.status=='setup' and self.state.player==2 do
   assert(E.Apply(self.state,2,PBWT.Opening.ComputerCommand(self.state,function() return 2 end)))
  end
  self.complete=self.state.status=='playing';return true,why
 end
 local expected=self.lesson.commands[self.progress]
 for k,v in pairs(expected) do if command[k]~=v then return false,'tutorial_goal' end end
 local ok,why=E.Apply(self.state,self.state.player,command)
 if ok then
  self.progress=self.progress+1;self.complete=self.progress>#self.lesson.commands
  if self.complete and self.lesson.opponentPass then assert(E.Apply(self.state,self.state.player,{type='end_turn'})) end
 end
 return ok,why
end
function T:TargetAt(x,y)
 if self.complete or self.lesson.opening then return false end
 local c=self.lesson.commands[self.progress];local p=E.Piece(self.state,c.id);local enemy=E.Piece(self.state,c.target)
 return (p and p.alive and p.x==x and p.y==y) or (c.x==x and c.y==y) or (enemy and enemy.alive and enemy.x==x and enemy.y==y)
end
function T:Text()
    local text=string.format('練習 %d / %d：%s\n\n%s',self.index,#T.lessons,self.lesson.title,self.lesson.text)
    if not self.complete and not self.lesson.opening then
        local c=self.lesson.commands[self.progress]
        local action=c.card and PBWT.Cards.definitions[c.card].name or ({move='移動',attack='攻撃',horn_move='角笛の追加移動',end_turn='ターン終了',invoke_scroll='星霜の書を開封'})[c.type]
        text=string.format('次の操作 %d/%d：%s\n\n',self.progress,#self.lesson.commands,action)..text
    end
 if self.complete then text=text..(self.index==#T.lessons and '\n\n全課程クリア！ ×：最初から / ○：終了' or '\n\n成功！ ×：次の練習盤へ')
 else
    local c=self.lesson.commands and self.lesson.commands[self.progress]
    local guide=c and (c.type=='end_turn' or c.type=='invoke_scroll') and '案内に沿って項目を選んでください。' or '金枠が課題の木札・マスです。'
    text=text..'\n\n'..guide..'\nL3：この章をやり直す / ○：戻る'
 end
 return text
end
