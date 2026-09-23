# Store listing copy

Text for the Bethesda.net / ZOS Console AddOn Uploader entry. Plain text, no markdown —
paste as-is. The **name** field is what the in-game add-on browser shows, so it must read
`PB's WarTable` there; `## Title` in the manifest does not reach that screen. In the PC
add-on list the manifest shows it as `|cFF69B4PB's WarTable|r 0.17.0`, the same pink and the
same name-plus-version shape as the other PB's add-ons.

Two things are repeated in both Overview and Description on purpose. The language note,
because a player has to know the board reads its language from the client and can be forced
with a command, and the fact that a duel needs both players on the same version with
LibGroupBroadcast, because somebody who installs this to play against a friend will otherwise
find that out only after the invite fails.

---

## Name

PB's WarTable

## Overview (JP)

シロディールの戦を木の盤に移した陣取りゲームです。ゲームパッドのメインメニューから開いて、
COM相手にひとりで遊べます。9×9の**スタンダード版**では帝位を決める六砦 — アレスウェル、
チャルマン、アッシュ、ブルーロード、ローベック、アレッシア — を帝都の周りに円状に並べ、
六砦すべてを自分の手番終了時に支配すると皇帝即位で即勝利します。5×5の**軽量版**は3旗・
20点先取の短い盤です。同じグループの相手を誘えば対人戦になります（両者に同じ版の本アドオン
とLibGroupBroadcastが必要）。COMは初級・中級・上級、練習用のチュートリアルは全14章。遊んで
いるあいだのBGMはテイルズオブトリビュートの対戦曲に差し替わります。表示は日本語と英語に対応
し、クライアントの言語に合わせて自動で切り替わります（`/pbwt lang ja` / `en` / `auto`）。
日本語表示には日本語フォントが必要です。

## Overview (EN)

Cyrodiil's war, moved onto a wooden table. Open it from the gamepad main menu and play alone
against the COM. The 9x9 **standard board** puts the six emperor keeps -- Aleswell, Chalman,
Ash, Blue Road, Roebeck and Alessia -- in their ring around the Imperial City, and holding all
six when your turn ends crowns you emperor and wins the match on the spot. The 5x5 **light
board** is a shorter three-keep game to twenty points. Invite someone in your group and the
two of you play it out across the group channel -- a duel needs the same version of this
add-on and LibGroupBroadcast on both sides. Three COM levels, a fourteen-chapter tutorial, and
the Tales of Tribute match music while the table is open. The interface speaks Japanese and
English and follows your client language, or `/pbwt lang ja` / `en` / `auto`. Japanese text
needs a Japanese font.

---

## Description (JP)

木札を進め、砦を押さえ、得点で相手を上回る二人用の盤上遊戯です。盤は2種類、駒は3種類、
戦術札は6種類。すべてPlayStationゲームパッドの操作を前提に作ってあります。

■ 開き方

　　メニュー　メインメニューの「ヘルプ」と「オプション」のあいだ
　　　　　　　→「ゲームセンターPX」→「三旗の戦卓 ― 帝位と星霜 ―」
　　　　　　　→ スタンダード／軽量の初級・中級・上級、ローカル検証、チュートリアル
　　対戦　　　相手を選んでインタラクトメニュー →「三旗の戦卓で対戦」
　　コマンド　/pbwt　（/pbwt beginner、/pbwt tutorial、/pbwt local など直接指定も可）

■ 操作

　　方向キー／左スティック　カーソル
　　×　　　　　駒を選ぶ → 移動先を決める
　　○　　　　　選択解除。無選択なら閉じる
　　□　　　　　戦術札
　　△　　　　　詳細・ヘルプ
　　L1／R1　　　駒・札を順に巡回
　　L3　　　　　戦績（□で演出あり／軽量を切替）
　　盤の右端からさらに右　ターン終了へ移動し、×で得点を確定
　　盤の左端からさらに左　星霜の書

■ 盤

　　軽量版　　5×5。各軍6枚（兵士3・斥候2・守護者1）。旗は左1点・中央2点・右1点。
　　　　　　　20点先取（後攻は21点）、最大30手番、1手番1回行動（後攻の初手のみ2回）。
　　スタンダード版　9×9。各軍10枚（兵士5・斥候3・守護者2）。六砦が各1点。
　　　　　　　60点先取（後攻は59点）、最大40手番、1手番2回行動（後攻の初手のみ4回）。
　　　　　　　六砦すべてを支配して自分の手番を終えると皇帝即位で即勝利。

　砦・旗は一度支配すると、相手に奪われるまで自分の手番終了ごとに得点を生みます。離れても
　支配は続きます。手番上限に達したときは得点→支配数→残存駒数で判定し、すべて同じなら
　引き分けです。

■ 駒

　　兵士　　攻撃2／防御2／移動1
　　斥候　　攻撃1／防御1／移動2
　　守護者　攻撃2／防御3／移動1　旗の上ではさらに防御＋1

　攻撃は、縦横に隣接する敵のマスへ通常移動で進入したときだけ起こります。攻撃側の攻撃が
　防御側の防御以上なら撃破し、そのマスへ進みます。届かなければ元の位置に留まります。
　騎兵突撃・角笛の追加移動では戦闘できません。

■ 陣営

　開始時に双方が六面ダイスを1個ずつ振ります（同点は振り直し）。大きい側は「同盟を先に選ぶ
　権利」か「先攻・後攻を選ぶ権利」のどちらかを取り、小さい側は残った権利を得ます。

　　アルドメリ・ドミニオン　斥候の通常移動が3マス
　　ダガーフォール・カバナント　旗の上の兵士の防御＋1
　　エボンハート・パクト　味方守護者に隣接する兵士の攻撃＋1

■ 戦術札

　各軍が6種を1回ずつ使えます。通常行動とは別枠です。

　　騎兵突撃　兵士・斥候1枚を縦横2マスまで直進（守護者は不可）
　　隠密　　　自軍の斥候1体を次の自分の手番開始まで攻撃対象外にする
　　攻城　　　通常攻撃と同時に使い、旗上の敵の防御補正を無効化して攻撃＋1
　　蘇生　　　撃破された自軍の兵士1枚を初期配置の空きマスへ戻す
　　角笛　　　選んだ駒の隣の味方兵士・斥候に、この手番だけ1マスの追加移動
　　補給　　　使用済みの自軍札1種をもう一度使えるようにする（補給自身は不可）

■ 星霜の書

　軽量版は中央旗を含む2旗を支配し、中央に隠密でない自軍札がいること。スタンダード版は
　帝都(5,5)に自軍札を置き、3砦以上を支配していること。どちらも敵がどの旗・砦にも乗って
　いないことが条件です。開封には点（軽量4点／スタンダード10点）と通常行動を払い、各軍1回
　だけ。読者の防御は1に落ち、相手の次の手番終了まで凌げば得点に関係なく勝利します。読者
　を撃破されるか、動かすか、隠密にするか、敵が旗へ入れば即失敗し、費用は戻りません。相手
　の得点勝利が先に成立した場合はそちらが優先されます。

■ COMと練習

　初級・中級・上級の3段階。上級はスタンダード版で皇帝即位の手順も探します。チュートリアル
　は全14章で、ダイスと同盟、移動、旗、攻撃、守護者、各札、星霜の書、阻止、得点勝利までを
　順に練習します。練習盤は本番と分離され、戦績には残りません。

■ 対戦

　同じグループにいて、両者がオンラインなら、インタラクトメニューから誘えます。盤面はESOの
　グループ通信で同期するため、相手の指し手が届くまで数秒かかることがあります。双方が同じ版
　でなければ始まりません。切断したまま戻らない対局は無効として集計しません。

■ 音とBGM

　戦卓を開いているあいだ、BGMをテイルズオブトリビュートの対戦曲に差し替えます。閉じると
　元へ戻し、他のアドオンが先に曲を握っていた場合は譲ります。`/pbwt music` で切り替えられ、
　設定はアカウント共通です。効果音はESO内蔵のもので、木札の着地と撃破（トリビュートの
　カード破壊音）に当ててあります。

■ 表示言語

　日本語と英語に対応しています。既定ではクライアントの言語に従い、日本語クライアントは
　日本語、それ以外は英語で表示します。`/pbwt lang ja`、`/pbwt lang en`、`/pbwt lang auto`
　で切り替えられ、選択はアカウント共通で保存されます。日本語表示には日本語フォントが必要
　です。

■ 戦績

　COM難易度別・盤別・対人戦別の勝敗と直近20件をアカウント共通で保存します。L3で表示し、
　L1／R1で履歴を送れます。ローカル検証と未完了の対局は集計しません。

■ 既知の制限

　チュートリアルは軽量版のみです。対人戦は双方が同じ版である必要があります。

対人戦には LibGroupBroadcast が必要です。ひとりで遊ぶだけならライブラリは要りません。

## Description (EN)

A two-player game of ground taken and held: move your tablets, sit on the keeps, and out-score
the other side. Two boards, three kinds of tablet, six tactic cards, all built around a
PlayStation gamepad.

■ Opening it

　　Menu　　　 main menu, between Help and Options
　　　　　　　 -> Game Centre PX -> The Three Banners War Table
　　　　　　　 -> standard or light at three COM levels, local test, tutorial
　　Duel　　　 target a player -> interact menu -> War Table duel
　　Command　　/pbwt　(/pbwt beginner, /pbwt tutorial, /pbwt local go straight in)

■ Controls

　　D-pad / left stick　　the cursor
　　X　　　　　　pick a tablet, then pick where it goes
　　O　　　　　　deselect; with nothing selected, close the table
　　Square　　　 tactic cards
　　Triangle　　 details and help
　　L1 / R1　　　cycle through your tablets or your cards
　　L3　　　　　 your record (Square switches full effects and light)
　　Right, past the right edge of the board　 end turn, X banks the points
　　Left, past the left edge　 the Elder Scroll

■ The boards

　　Light　　　 5x5, six tablets a side (3 soldiers, 2 scouts, 1 guardian). Keeps are worth
　　　　　　　　1, 2 and 1 points. First to 20 (21 for the second seat), 30 turns at most,
　　　　　　　　one action a turn -- the second seat gets two on its opening turn.
　　Standard　　9x9, ten tablets a side (5 soldiers, 3 scouts, 2 guardians). Each of the six
　　　　　　　　keeps is worth 1 point. First to 60 (59 for the second seat), 40 turns at
　　　　　　　　most, two actions a turn -- the second seat gets four on its opening turn.
　　　　　　　　Hold all six keeps as your turn ends and you are crowned emperor: an
　　　　　　　　immediate win, whatever the score.

　A keep you take stays yours until somebody takes it back, and pays you every time your own
　turn ends -- you do not have to stand on it. If the turn cap runs out, the win goes on
　points, then on keeps held, then on tablets left standing, and it is a draw if all three
　are level.

■ Tablets

　　Soldier　　 attack 2 / defence 2 / moves 1
　　Scout　　　 attack 1 / defence 1 / moves 2
　　Guardian　　attack 2 / defence 3 / moves 1, and +1 more defence on a keep

　You attack by moving onto an enemy: a normal move into an orthogonally adjacent square they
　occupy. Match or beat their defence and they are destroyed and you advance into the square;
　fall short and you stay where you were. The extra movement from Charge and War Horn cannot start
　a fight.

■ Alliances

　Both sides roll one six-sided die to open, re-rolling a tie. The higher roll takes either
　the right to choose an alliance first or the right to choose the turn order, and the lower
　roll takes whichever right is left.

　　Aldmeri Dominion　　scouts move three squares on a normal move
　　Daggerfall Covenant　soldiers standing on a keep defend at +1
　　Ebonheart Pact　　　soldiers beside a friendly guardian attack at +1

■ Tactic cards

　Six of them, once each per side, and none of them costs your normal action.

　　Charge　　 one soldier or scout advances up to two squares in a straight line
　　Stealth　　one of your scouts cannot be attacked until your next turn begins
　　Siege　　　used with a normal attack on an enemy standing on a keep: +1 attack,
　　　　　　　 and the keep's defence bonus is cancelled
　　Revive　　 one of your destroyed soldiers returns to an empty starting square
　　War Horn　 friendly soldiers and scouts beside the chosen tablet gain a square this turn
　　Supply　　 one spent card of yours becomes usable again (not Supply itself)

■ The Elder Scroll

　On the light board you need the centre keep plus one more, and an unhidden tablet of yours
　on the centre. On the standard board you need a tablet on the Imperial City (5,5) and three
　keeps or more. Either way, no enemy may be standing on a keep. Opening it costs points --
　4 on the light board, 10 on the standard one -- plus your normal action, once per side. The
　reader drops to defence 1, and if it survives until your opponent's next turn ends, you win
　regardless of the score. Killing the reader, moving it, hiding it, or an enemy stepping onto
　any keep ends the attempt at once, and nothing is refunded. A score victory that lands first
　takes priority.

■ The COM and the tutorial

　Three levels. The top one also looks for a coronation on the standard board, so leaving all
　six keeps within its reach is a real risk. The tutorial runs fourteen chapters: the dice and
　the alliances, movement, keeps, attacking, the guardian, each card, the Elder Scroll and how
　to break one, and a win on points. Practice boards are kept apart from real games and are
　never recorded.

■ Duels

　You can invite anyone in your group who is online. The board is kept in step over the game's
　group channel, so a move can take a few seconds to arrive. Both sides must be on the same
　version or the match will not start. A game that is disconnected and never resumed is not
　counted.

■ Sound and music

　While the table is open the music changes to the Tales of Tribute match track. Closing it
　puts the music back, and if another add-on had already taken the music over, this one leaves
　it alone. `/pbwt music` turns the change off, account-wide. The sound effects are the game's
　own: a tablet landing, and Tribute's card-destruction sound when one is taken off the board.

■ Language

　Japanese and English. By default the table follows your client: Japanese on a Japanese
　client, English everywhere else. `/pbwt lang ja`, `/pbwt lang en` and `/pbwt lang auto`
　switch it, and the choice is remembered account-wide. The Japanese text needs a Japanese
　font to render.

■ Records

　Wins and losses are kept per COM level, per board and for duels, along with your last twenty
　games, account-wide. L3 shows them and L1 / R1 page through the history. Local test games
　and unfinished games are not counted.

■ Known limitations

　The tutorial only teaches the light board. Duels require the same version on both sides.

LibGroupBroadcast is required for duels. Playing alone needs no libraries.
