-- PB's Translate dictionary: Cyrodiil and PvP chat
--
-- Kept separately from ESO.lua; in Cyrodiil a PvP meaning wins over the PvE one: "push"
-- is attacking a keep, "hold" is defending one, "tv" is Tel Var and not a television.
--
-- Keep, outpost and town names are the ones PB supplied. A keep without a supplied name stays
-- in English with 砦 after it (Kingscrest砦) rather than being guessed into katakana.
--
-- Some of PB's short forms are ordinary words or other ESO terms, and in this dictionary the
-- Cyrodiil meaning wins while in Cyrodiil: "dragon" is Dragonclaw, "warden" is Fort Warden (not the
-- class), "wp" is the outpost (not "well played"), "mine" is the mine.
--
-- Order within the file: nouns, adjectives, verbs, expressions (see ESO.lua).

local D = PBsTranslate.DefineCyrodiil

D("n", [[
-- keep structure
ms=鉱山サイド/join=の
ls=製材所サイド/join=の
fs=農場サイド/join=の
fd=正門/join=の
front door=正門/join=の
front gate=正門
main gate=正門
bd=裏門/join=の
back door=裏門/join=の
back gate=裏門
postern=通用門/join=の
postern door=通用門
inner=内門/join=の
inner door=内門
inner gate=内門
inner wall=内壁
inner walls=内壁
outer=外壁/join=の
outer wall=外壁
outer walls=外壁
outer door=外門
wall=壁
walls=壁
door=門
doors=門
flag=旗/join=の
flags=旗/join=の
flag pole=旗
keep=砦
keeps=砦
outpost=前哨基地
outposts=前哨基地
town=町
towns=町
tower=塔
milegate=マイルゲート/join=の
milegates=マイルゲート/join=の
bridge=橋/join=の
bridges=橋/join=の
ifd=内郭の扉/join=の
inner fd=内郭の扉/join=の
inner front door=内郭の扉/join=の
-- resources
farm=農場
mine=鉱山
lm=製材所
lumber=製材所
rss=資源
res=資源
resource=資源
resources=資源
the farm=農場
the mine=鉱山
the lumbermill=製材所
the lumber mill=製材所
lumbermill=製材所
lumber mill=製材所
mill=製材所
-- siege
siege=包囲攻撃
sieges=包囲攻撃
ua=奇襲/join=に
ram=破城槌
rams=破城槌
cata=カタパルト
catas=カタパルト
catapult=カタパルト
catapults=カタパルト
treb=トレビュシェット
trebs=トレビュシェット
tre=トレビュシェット
ballista=バリスタ
ballistas=バリスタ
fire ballista=炎バリスタ
stone ballista=石バリスタ
lightning ballista=稲妻バリスタ
firepot=火壺トレビュシェット
fire pot=火壺トレビュシェット
firepot trebuchet=火壺トレビュシェット
iceball=氷球トレビュシェット
iceball trebuchet=氷球トレビュシェット
iceball treb=氷球トレビュシェット
firepot treb=火壺トレビュシェット
fire pot treb=火壺トレビュシェット
ice treb=氷球トレビュシェット
frost treb=氷球トレビュシェット
coldfire treb=氷炎トレビュシェット
coldfire trebuchet=氷炎トレビュシェット
cold stone treb=氷石トレビュシェット
cold stone trebuchet=氷石トレビュシェット
meat cata=肉カタパルト
meatbag cata=肉カタパルト
meatbag catapult=肉カタパルト
oil cata=オイルカタパルト
oil catapult=オイルカタパルト
scattershot=散弾カタパルト
scattershot cata=散弾カタパルト
scattershot catapult=散弾カタパルト
coldfire=コールドファイア
coldfire siege=コールドファイア攻城兵器
oil=燃え盛る油
oils=燃え盛る油
hot oil=燃え盛る油
boiling oil=燃え盛る油
flaming oil=燃え盛る油
meatbag=肉袋
meatbags=肉袋
meat bag=肉袋
stone treb=石トレビュシェット
stone trebuchet=石トレビュシェット
fire treb=火壺トレビュシェット
wall repair kit=塁壁石工修理キット
wall repair kits=塁壁石工修理キット
wall kits=塁壁石工修理キット
wall kit=塁壁石工修理キット
wall repair=塁壁石工修理キット
door repair kit=扉維持用木工修理キット
door repair kits=扉維持用木工修理キット
door kits=扉維持用木工修理キット
door kit=扉維持用木工修理キット
door repair=扉維持用木工修理キット
bridge repair kit=門とマイルゲートの修理キット
milegate repair kit=門とマイルゲートの修理キット
repair kit=修理キット
repair kits=修理キット
forward camp=前線キャンプ
tent=テント
tents=テント
forward camps=前線キャンプ
camp=前線キャンプ
fc=前線キャンプ
def=防衛
defense=防衛
-- the war
inc=インカミング/end
incoming=インカミング/end
dethrone=廃帝
alliance war=同盟戦争
cyro=シロディール
cyrodiil=シロディール
campaign=キャンペーン
home campaign=ホームキャンペーン
guest campaign=ゲストキャンペーン
gray host=グレイホスト
greyhost=グレイホスト
grey host=グレイホスト
blackreach campaign=ブラックリーチ
ravenwatch=レイブンウォッチ
emperor=皇帝
emp=皇帝
emperorship=皇帝位
scroll=星霜の書
scrolls=星霜の書
elder scroll=星霜の書
elder scrolls=星霜の書
scroll temple=星霜の書の神殿
hammer=ヴォレンドラング
ham=ヴォレンドラング
volendrung=ヴォレンドラング
chim=チムの星霜の書
ghartok=ガルトクの星霜の書
mnem=ムネムの星霜の書
altadoon=アルタドゥーンの星霜の書
ni mohk=ニ・モークの星霜の書
nimohk=ニ・モークの星霜の書
alma ruma=アルマ・ルーマの星霜の書
almaruma=アルマ・ルーマの星霜の書
ap=同盟ポイント
alliance points=同盟ポイント
alliance point=同盟ポイント
tel var=テルヴァー
telvar=テルヴァー
tv=テルヴァー
tv stones=テルヴァーストーン
transitus=トランシタスの祠
transitus shrine=トランシタスの祠
transit shrine=トランシタスの祠
keep network=砦ネットワーク
ic=インペリアルシティ
imperial city=インペリアルシティ
sewers=下水道
district=地区
districts=地区
arena district=アリーナ地区
memorial district=記念地区
temple district=神殿地区
elven gardens=エルフ庭園地区
nobles district=貴族地区
arboretum=植物園地区
ad=アルドメリ・ドミニオン/then=の
dc=ダガーフォール・カバナント/then=の
ep=エボンハート・パクト/then=の
dominion=ドミニオン/then=の
covenant=カバナント/then=の
pact=パクト/then=の
yellows=ドミニオン勢/then=の
blues=カバナント勢/then=の
reds=パクト勢/then=の
enemy=敵/then=の
enemies=敵/then=の
enemy zerg=敵の大集団
ad zerg=ドミニオンの大集団
dc zerg=カバナントの大集団
ep zerg=パクトの大集団
zerg=大集団
zergs=大集団
ball group=ボールグループ
ball=ボールグループ
bg=バトルグラウンド
bomber=ボマー
bombers=ボマー
ganker=ガンカー
gankers=ガンカー
nb ganker=NBガンカー
solo player=ソロプレイヤー
solo players=ソロプレイヤー
small scale=少人数戦
small group=少人数グループ
pug group=野良グループ
raid group=レイドグループ
crown=グループリーダー
leader crown=グループリーダー
pvp guild=PvPギルド
pvp=PvP
pvper=PvPプレイヤー
pvpers=PvPプレイヤー
tick=時間経過による同盟ポイント
ap tick=時間経過による同盟ポイント
defense tick=防衛ティック
def tick=防衛ティック
bounty=懸賞金
-- from the jazbay.com Cyrodiil glossary (2026-09-14)
eso=ESO
teso=ESO
zos=ゼニマックス・オンライン・スタジオ
zeni=ゼニマックス
blue=カバナント/then=の
yellow=ドミニオン/then=の
red=パクト/then=の
faction=陣営
factions=陣営
faction stacking=陣営の集中
avava=同盟vs同盟vs同盟
lowpop=ローポップ
low pop=ローポップ
lowpop bonus=ローポップ・ボーナス
low pop bonus=ローポップ・ボーナス
underdog bonus=ローポップ・ボーナス
poplock=陣営人数の上限到達
pop lock=陣営人数の上限到達
pop locked=陣営人数の上限到達
1bar=陣営人数バー1本
2bar=陣営人数バー2本
3bar=陣営人数バー3本
rss cutting=資源の占領による切断
rss cut=資源の占領による切断
cut=切断
battle spirit=戦いの精神
quartermaster=補給係
rewards of the worthy=功労者報酬
volendrung=ヴォレンドラング
port=テレポート祠
transitus port=テレポート祠
guards=NPC衛兵
keep guards=NPC衛兵
merchant=商人
pvdoor=PvDoor（無人の砦攻め）
pve door=PvDoor（無人の砦攻め）
retake=奪還
ball grp=ボールグループ
troll=荒らし
trolls=荒らし
scroll troll=星霜の書を餌に戦う人
chat troll=チャット荒らし
camp troll=キャンプ妨害者
spy=スパイ
spi=スパイ
spies=スパイ
farmer=同盟ポイント稼ぎ
ap farmer=同盟ポイント稼ぎ
heal bot=回復ボット
healbot=回復ボット
team orange=チームオレンジ（パクトとドミニオンの結託）
team green=チームグリーン（ドミニオンとカバナントの結託）
team purple=チームパープル（カバナントとパクトの結託）
temp=テンプラー
ww=ウェアウルフ
hybrid=ハイブリッド
glass cannon=ガラスの大砲
fotm=流行のクラス
flavor of the month=流行のクラス
trash=ゴミ
garbage=ゴミ
dot=継続ダメージ
dots=継続ダメージ
hot=継続回復
hots=継続回復
cc=集団制御
snare=鈍足
snares=鈍足
sneak=隠密
stealth=隠密
sustain=継続力
burst=バースト
burst heal=バーストヒール
burst damage=バーストダメージ
cross heal=クロスヒール
cross heals=クロスヒール
proc=効果発動
procs=効果発動
black out=ブラックアウト
blackout=ブラックアウト
async=非同期
asynchronous=非同期
desync=非同期
time zone=標準時間
prime time=ゴールデンタイム
em=彼ら
-- community glossaries (UESP "Abbreviations and Terms", Fextralife "Abbreviations and
-- Glossary", Walks-the-Uncharted glossary; 2026-09-15)
percent=パーセント/unit
counter=対抗攻城兵器
counter siege=対抗攻城兵器
anti siege=対抗攻城兵器
train=トレイン（大集団）
blob=大集団
zergball=大集団
wrecking ball=統率された大集団
hotspot=激戦地
hot spot=激戦地
ring keeps=皇帝の砦
emp keeps=皇帝の砦
emperor keeps=皇帝の砦
emperor farming=皇帝ファーミング
d tick=防衛ティック
dtick=防衛ティック
dee tick=防衛ティック
keep recall stone=砦帰還の石
recall stone=砦帰還の石
bloodport=死に戻り
blood port=死に戻り
luring=釣り
lure=釣り
pilejumping=弱った陣営への便乗攻撃
pile jumping=弱った陣営への便乗攻撃
pj=弱った陣営への便乗攻撃
pjing=弱った陣営への便乗攻撃
choking=補給線の切断
choke=補給線の切断
lfc=キャンプ募集
rep=修理
zc=ゾーンチャット
rftw=功労者報酬
rvr=陣営戦
ava=同盟戦
1v1=1対1
1vx=1対多数
los=射線
line of sight=射線
pking=プレイヤーキル
pvper=PvPプレイヤー
greens=グリーン同盟（ドミニオンとカバナントの結託）
green alliance=グリーン同盟（ドミニオンとカバナントの結託）
oranges=オレンジ同盟（パクトとドミニオンの結託）
orange alliance=オレンジ同盟（パクトとドミニオンの結託）
purples=パープル同盟（カバナントとパクトの結託）
purple alliance=パープル同盟（カバナントとパクトの結託）
bananas=ドミニオン/then=の
tree huggers=ドミニオン/then=の
simpsons=ドミニオン/then=の
smurfs=カバナント/then=の
blueberries=カバナント/then=の
covvies=カバナント/then=の
cherries=パクト/then=の
tomatoes=パクト/then=の
apples=パクト/then=の
br=ブラックリーチ
rw=レイヴンウォッチ
ir=アイスリーチ
gh=グレイホスト
tv stones=テルヴァーストーン
-- keep nicknames from the same glossaries
blk=侵入者の基地
carm=カーマラ基地
brin=ブリンドル砦
brind=ブリンドル砦
dclaw=ドラゴンクロー砦
drag=ドラゴンクロー砦
chalm=チャルマン砦
chalamo=チャルマン砦
dlk=ドレイクロー砦
blood=ブラッドメイン砦
cbm=ブラッドメイン砦
cfg=フェアユール砦
-- keeps, outposts and towns (names as PB supplied them, 2026-09-14)
chalman=チャルマン砦
chalman keep=チャルマン砦
chal=チャルマン砦
arrius=アリウス砦
arrius keep=アリウス砦
kingscrest=キングクレスト砦
kingscrest keep=キングクレスト砦
kings=キングクレスト砦
king=キングクレスト砦
kc=キングクレスト砦
cbb=ブラックブート砦
farragut=ファラガット砦
farragut keep=ファラガット砦
farra=ファラガット砦
blue road=ブルーロード砦
blue road keep=ブルーロード砦
blueroad=ブルーロード砦
brk=ブルーロード砦
drakelowe=ドレイクロー砦
drakelowe keep=ドレイクロー砦
drake=ドレイクロー砦
alessia=アレッシア砦
aless=アレッシア砦
lessy=アレッシア砦
castle alessia=アレッシア砦
alessia bridge=アレッシア橋
faregyl=フェアユール砦
castle faregyl=フェアユール砦
fare=フェアユール砦
fair=フェアユール砦
roebeck=ローベック砦
castle roebeck=ローベック砦
roe=ローベック砦
brindle=ブリンドル砦
castle brindle=ブリンドル砦
black boot=ブラックブート砦
castle black boot=ブラックブート砦
blackboot=ブラックブート砦
bb=ブラックブート砦
bloodmayne=ブラッドメイン砦
castle bloodmayne=ブラッドメイン砦
bm=ブラッドメイン砦
warden=ウォーデン砦
fort warden=ウォーデン砦
warden keep=ウォーデン砦
rayles=レイレス砦
fort rayles=レイレス砦
glademist=グレイドミスト砦
fort glademist=グレイドミスト砦
glade=グレイドミスト砦
fort ash=アッシュ砦
ash=アッシュ砦
aleswell=アレスウェル砦
fort aleswell=アレスウェル砦
ales=アレスウェル砦
dragonclaw=ドラゴンクロー砦
fort dragonclaw=ドラゴンクロー砦
dragon=ドラゴンクロー砦
claw=ドラゴンクロー砦
sejanus=セヤヌス基地
sejanus outpost=セヤヌス基地
sej=セヤヌス基地
nikel=ニケリ基地
nikel outpost=ニケリ基地
nike=ニケリ基地
nik=ニケリ基地
bleaks=侵入者の基地
bleakers=侵入者の基地
bleaker 's=侵入者の基地
bleaker 's outpost=侵入者の基地
bleakers outpost=侵入者の基地
carmala=カーマラ基地
carmala outpost=カーマラ基地
harlun=ハルルン基地
harlun 's outpost=ハルルン基地
harluns outpost=ハルルン基地
ho=ハルルン基地
wp=ウィンターズ・ピークス基地
winter=ウィンターズ・ピークス基地
winters peak=ウィンターズ・ピークス基地
winter 's peak=ウィンターズ・ピークス基地
bruma=ブルーマの街
vlastarus=ヴラスタルスの街
vlas=ヴラスタルスの街
vlast=ヴラスタルスの街
cropsford=クロップスの街
crops=クロップスの街
cheydinhal=Cheydinhal
chorrol=Chorrol
weynon priory=Weynon修道院
]])

-- "fd down", "the door is down": broken, for anything a siege can break
D("a", [[
down=破られた/na
gone=奪われた/na
open=破られた/na
salty=イライラしている/na
killable=倒せる/na
unkillable=倒せない/i
]])

D("v", [[
hk=砦の修理・味方の回復・防衛維持を行う/5
bone=全滅させる/1/を
push=攻める/1
push in=攻め込む/5
hold=守る/5
def=防衛する/s
defend=防衛する/s
take=取る/5
flip=奪う/5
cap=占領する/s
capture=占領する/s
siege=包囲攻撃する/s
ram=破城槌で叩く/5
bomb=爆撃する/s
ball up=固まる/5
rally=集合する/s
regroup=再集合する/s
retreat=撤退する/s
fall back=後退する/s
reinforce=増援する/s
scout=偵察する/s
repair=修理する/s
port=ポートする/s
transit=移動する/s/に
camp=キャンプする/s
zerg=数で押す/5
gank=奇襲する/s
kite=引き回す/5
pull=引きつける/1
split=分断する/s
drop=置く/5
lose=失う/5
place=置く/5
dethrone=廃帝にする/s
lit=攻撃されている/1
prep=準備する/s
rep=修理する/s
lure=釣る/5
choke=切断する/s
bloodport=死に戻りする/s
stone=帰還の石で移動する/s
stone port=帰還の石で移動する/s/に
cut=切断する/s
cut off=切断する/s
ram on=破城槌に乗る/5
retake=取り戻す/5
pvdoor=無人の砦を攻める/1
troll=荒らす/5
spam=連発する/s
snare=足止めする/s
cc=拘束する/s
sneak=隠密する/s
freeze=フリーズする/s
crash=クラッシュする/s
spy=スパイする/s
drop siege=攻城兵器を置く/5
set up siege=攻城兵器を置く/5
]])

D("x", [[
hk=砦を修理して味方を回復し、防衛を維持してください
fd down=正門が破られました
front door down=正門が破られました
bd down=裏門が破られました
back door down=裏門が破られました
door down=門が破られました
doors down=門が破られました
inner down=内門が破られました
inner door down=内門が破られました
outer down=外壁が破られました
wall down=壁が破られました
walls down=壁が破られました
outer wall down=外壁が破られました
inner wall down=内壁が破られました
postern down=通用門が破られました
ua=奇襲
lit=攻撃されている
lfg=グループメンバーを探している
ty=ありがとう！
under attack=攻撃を受けています
under siege=攻城されています
flipped=奪われました
keep flipped=砦が奪われました
we lost the keep=砦を奪われました
we took it=奪いました
capped=占領しました
flag capped=旗を取りました
need def=防衛が必要です
need defense=防衛が必要です
def pls=防衛お願いします
def please=防衛お願いします
def plz=防衛お願いします
defend please=防衛お願いします
need help at fd=正門に援護が必要です
need rams=破城槌が必要です
need oils=燃え盛る油が必要です
need siege=攻城兵器が必要です
rally=集合
rally up=集合してください
regroup=再集合
regroup at=再集合
stack on crown=グループリーダーに集合
stack crown=グループリーダーに集合
on crown=グループリーダーに集合
follow crown=グループリーダーについていって
crown dead=グループリーダーが死にました
crown down=グループリーダーが死にました
push=攻めて
push push=押し込め
push in=突入
go in=突入
hold=待機
hold here=ここで待機
hold position=その場で待機
fall back=後退
retreat=撤退
bomb=爆撃
ball up=固まって
spread=散開
zerg inc=大集団インカミング
zerg incoming=大集団インカミング
enemy inc=敵インカミング
enemies inc=敵インカミング
ad inc=ドミニオンインカミング
dc inc=カバナントインカミング
ep inc=パクトインカミング
ez ap=楽なAP
free ap=楽なAP
ap farm=同盟ポイント稼ぎ
tv farm=テルヴァー稼ぎ
scroll taken=星霜の書が奪われました
scroll lost=星霜の書を失いました
new emp=新しい皇帝
hammy=ヴォレンドラングを取得しました
we have emp=皇帝を取りました
emp inc=皇帝インカミング
dethrone inc=廃帝インカミング
repair the wall=壁を修理してください
repair the door=門を修理してください
repair wall=壁を修理してください
repair door=門を修理してください
drop siege=攻城兵器を置いてください
drop rams=破城槌を置いてください
drop oils=燃え盛る油を置いてください
drop camp=キャンプを置いてください
camp down=キャンプを置きました
camp up=キャンプを置きました
port to keep=砦にポートしてください
transit=トランジタスで移動
gg ez=楽勝
gf=よい戦いでした
us=攻撃を受けています
gone=奪われました
lfc=キャンプ募集
ifd down=内郭の扉が破られました
inner fd down=内郭の扉が破られました
cut off=切断されました
we are cut off=切断されました
we got cut off=切断されました
keep is cut off=砦が切断されました
cutting=切断中
ram on=破城槌に乗って！
please ram on=破城槌を手伝ってください
ram on please=破城槌を手伝ってください
get on ram=破城槌に乗って！
get on the ram=破城槌に乗って！
on ram=破城槌に乗って！
need people on ram=破城槌に人が必要です
need ppl on ram=破城槌に人が必要です
drop tent=テントを置いてください
tent up=テントを置きました
tent down=テントを置きました
camp is up=キャンプを置きました
unstuck=スタックから解放
use unstuck=「スタックから解放」を使ってください
gg=いい戦いでした
tyfg=グループありがとう
ty for rez=蘇生ありがとう
ty for the rez=蘇生ありがとう
nvmd=気にしないで
nice try=惜しかったね
l2p=もっと上手くなれ
learn to play=もっと上手くなれ
mornin=おはよう
morning=おはよう
retake=奪還
retake it=取り戻して
lowpop=ローポップ
poplocked=陣営人数の上限です
pop locked=陣営人数の上限です
type x for invite=招待希望は x と入力
type 1 for invite=招待希望は 1 と入力
type inv for invite=招待希望は inv と入力
x for inv=招待希望は x と入力
x for invite=招待希望は x と入力
def=防衛して
inc=インカミング
incoming=インカミング
dethrone=廃帝
dethroned=廃帝
otw=向かっている途中
omw=向かっている途中
on my way=向かっている途中
on the way=向かっている途中
good fight=よい戦いでした
nice fight=よい戦いでした
]])

-- Conjugatable readings for negation and modal verbs; fixed calls below remain the defaults.
D("v", [[
ult dump=アルティメットを一斉に使う/5
ulti dump=アルティメットを一斉に使う/5
ultimate dump=アルティメットを一斉に使う/5
dump ults=アルティメットを一斉に使う/5
dump ult=アルティメットを使う/5
break los=障害物で敵の射線を切る/5
burn siege=敵の攻城兵器を燃やす/5
burn their siege=敵の攻城兵器を燃やす/5
hold block=防御し続ける/1
push together=一緒に突撃する/s
push as one=足並みを揃えて突撃する/s
]])

-- Community chat expansion (2026-09-16). Sources and scope: SLANG_SOURCES.md [pvp].
D("x", [[
ult dump=アルティメットを一斉に使って
ulti dump=アルティメットを一斉に使って
ultimate dump=アルティメットを一斉に使って
dump ults=アルティメットを一斉に使って
dump ult=アルティメットを使って
bomb inc=範囲バースト攻撃が来る
bomb incoming=範囲バースト攻撃が来る
bomber inc=ボマーが来る
ball inc=ボールグループが来る
ball group inc=ボールグループが来る
negate down=魔法無効化フィールドを設置した
negate up=魔法無効化フィールドを展開中
push together=一緒に突撃して
push as one=足並みを揃えて突撃して
stay on crown=リーダーから離れないで
tight on crown=リーダーにぴったり集合
back on crown=リーダーの位置に戻って
do not chase=深追いしないで
stop chasing=深追いをやめて
peel for healer=ヒーラーを狙う敵を引き離して
peel for healers=ヒーラーを狙う敵を引き離して
peel for me=私を狙う敵を引き離して
hold block=防御し続けて
break los=障害物で敵の射線を切って
stay in los=射線が通る位置にいて
out of los=射線が通っていません
los them=障害物で敵の射線を切って
rez at camp=前線キャンプで復活して
res at camp=前線キャンプで復活して
camp on cooldown=キャンプ復活はクールダウン中
camp cd=キャンプ復活のクールダウン
siege cap=攻城兵器の設置上限
siege capped=攻城兵器が設置上限に達した
burn siege=敵の攻城兵器を燃やして
burn their siege=敵の攻城兵器を燃やして
]])

D("n", [[
backcap=手薄な後方拠点の占領
back cap=手薄な後方拠点の占領
backcapping=手薄な後方拠点を占領中
resource flip=資源拠点の占領
rss flip=資源拠点の占領
no cp=チャンピオンポイント無効
nocp=チャンピオンポイント無効
smallscale=少人数戦
outnumbering=人数有利
outnumbered fight=人数不利の戦闘
outnumbered fights=人数不利の戦闘
zerg surfing=大集団に便乗する戦い方
zerg surfer=大集団に便乗するプレイヤー
faction stack=陣営全体の大集合
crosshealing=味方同士での相互回復
cross healing=味方同士での相互回復
heal stacking=回復効果の重ねがけ
perma block=常時防御
permablock=常時防御
permablocker=常時防御するプレイヤー
perma stun=行動不能が続く状態
permastun=行動不能が続く状態
cc immunity=行動妨害への耐性時間
cc immune=行動妨害が効かない状態
snare immunity=鈍足への耐性
immovable pot=行動妨害耐性ポーション
immov pot=行動妨害耐性ポーション
detection pot=隠密看破ポーション
detect pot=隠密看破ポーション
detect pots=隠密看破ポーション
siege shield=攻城兵器シールド
meatbags down=ミートバッグ・カタパルトを設置した
]])

-- Explicit short negative calls (no + action).
D("x", [[
no ult dump=アルティメットを一斉に使わないでください
no ulti dump=アルティメットを一斉に使わないでください
]])
