# Store listing copy

Text for the Bethesda.net / ZOS Console AddOn Uploader entry. Plain text, no markdown —
paste as-is. The **name** field is what the in-game add-on browser shows, so it must read
`PB's DiceExtension` there; `## Title` in the manifest does not reach that screen.

The "only you / everyone" split is in both Overview and Description on purpose. It is the one
thing somebody has to understand before installing rather than after: a dice roll you think
your group saw and they did not is worse than no dice roll at all.

---

## Name

PB's DiceExtension

## Overview (JP)

チャット画面のランダムロールは1〜100の一個振りで固定です。このアドオンは振るダイスを
覚えておきます。個数は最大10個、出目は最大1000面。チャット画面のR3で振れて、各ダイスの
出目と合計も出ます。アドオンが振った結果は自分にしか見えません。全員に見せたいときは
R3長押しで入力欄に /roll を用意するので、送信だけ押してください。

## Overview (EN)

The chat screen's Random Roll is one die of 100, and nothing else. This remembers the dice you
want instead -- up to 10 of them, up to 1000 sides -- rolls them on R3 in the chat screen, and
shows every die as well as the total. Rolls the add-on makes are visible only to you; for one
the group can see, hold R3 to leave the matching /roll in the chat box and press Send.

---

## Description (JP)

チャット画面には「ランダムロール」が付いています。△を押すと1〜100の数字が一つ出て、周りの
人にも見えます。振れるのはこれだけで、個数も出目の幅も変えられません。

/roll コマンド自体は 3d20 のような書き方に対応していますが、コントローラーのキーボードで
毎回 3d20 と打つ人はいません。だからこのアドオンは、振るダイスの方を覚えておきます。


■ 振り方

　R3（右スティック押し込み）
　　設定したダイスを振り、自分のチャットに表示します。

　R3長押し（0.5秒）
　　入力欄に /roll 3d20 を用意します。送信を押すとゲーム本体が振ります。

　/pbdice
　　同じくその場で振ります。/pbdice 3d20 と書けば、設定を変えずにその一回だけ振れます。

　設定パネルの「振る」ボタン
　　同じです。

　結果はこう出ます。

　　ブンブンが34をロール(3 x 20面)。(自分のみ)
　　　17 + 3 + 14 = 34

　二行目の内訳は、ゲーム本体のロールには出せないものです。本体は合計しか報告しません。


■ 誰に見えるか

　ここだけは先に読んでください。

　アドオンが振ったダイスは、あなたのチャットにしか出ません。他の人には見えていません。
　表示が本物のロールとまったく同じ文章になるので、末尾に「(自分のみ)」という印を付けて
　あります。見えていると思っていたものが見えていなかった、という事故を防ぐためです。

　全員に見せたいときは、ゲーム本体に振ってもらう必要があります。それがR3長押しです。
　入力欄に /roll が入った状態になるので、送信を押してください。押すのはあなたです。

　　R3長押し → 送信

　これで、設定したダイスがゲーム本体のロールとしてグループのチャットに流れます。1〜100
　固定ではなく、あなたの 3d20 が全員に見える形です。

　なぜ最後の一押しが必要なのか。ロールを実行するAPIも、チャットに文章を送るAPIも、
　アドオンからは呼べないよう閉じられているためです。アドオンから任意の文章を他人の画面に
　出せてしまうとスパムそのものになるので、これは意図的な仕様です。回避する方法はありません。

　チャット画面を開いたときに自動で入力欄へ /roll を入れておく設定もあります（初期はオフ）。
　オンにすると入力欄を常に占有するので、普通に発言したいときは消してから入力してください。


■ 標準のランダムロールはそのまま

　△のランダムロールには一切手を入れていません。今までどおり1〜100を振ります。

　△の長押しに割り当てなかったのには理由があります。ゲームは△を押し込んだ瞬間にロールを
　実行するので、長押しかどうかを判定できる頃にはもう振られています。判定するには△の動作を
　アドオンが乗っ取るしかなく、乗っ取ると今度は全員に見える本物のロールに手が届かなくなり
　ます。だから空いているR3を使い、△はゲームが書いたまま残してあります。


■ 設定

　設定パネル（LibHarvensAddonSettings があるとき）で変えられます。

　　ダイスの個数　　　　　　　　1〜10
　　ダイスの面数　　　　　　　　2〜1000
　　チャット画面のR3で振る　　　初期オン
　　各ダイスの出目を表示　　　　初期オン
　　自分のみの印を付ける　　　　初期オン
　　チャット入力欄に /roll を入れておく　初期オフ

　初期値は「100面が1個」です。チャット画面のランダムロールと同じなので、入れただけでは
　ロールの意味は何も変わりません。

　ライブラリが無くても、すべて /pbdice から操作できます。


■ コマンド

　　/pbdice　　　　　　　　　設定したダイスを振る
　　/pbdice 3d20　　　　　　 その場かぎりで振る（設定は変わりません）
　　/pbdice count 3　　　　　ダイスの個数、1〜10
　　/pbdice sides 20　　　　 ダイスの面数、2〜1000
　　/pbdice keybind on|off　 チャット画面のR3
　　/pbdice each on|off　　　各ダイスの出目を表示
　　/pbdice tag on|off　　　 自分のみの印
　　/pbdice prefill on|off　 チャット画面を開いたら入力欄に /roll を入れる
　　/pbdice status　　　　　 現在の設定
　　/pbdice reset　　　　　　初期設定に戻す

　/dice も、他のアドオンが使っていなければ同じように使えます。


■ その他

　日本語と英語に対応しています。ロール結果の文章はゲーム本体の翻訳をそのまま使うため、
　どの言語のクライアントでも本物のロールと同じ表示になります。

　設定はアカウント共通です。キャラクターを変えてもダイスはそのままです。

---

## Description (EN)

The chat screen has a Random Roll on it. Press the third button and you get one number out of
1 to 100, and the people around you see it. That is all it does: you cannot change how many
dice or how many sides.

The /roll command itself understands 3d20 if you type it, but nobody types 3d20 on a controller
keyboard twice. So this add-on remembers the dice instead.


ROLLING

  R3 (right stick click)
    Rolls the dice you set and puts the result in your chat.

  R3, held for half a second
    Leaves /roll 3d20 in the chat box. Press Send and the game rolls it.

  /pbdice
    Rolls it there and then. /pbdice 3d20 rolls that once without changing the setting.

  The Roll button on the settings panel
    The same.

  What comes out:

    Bosmer Bunbun rolls 34 with 3 x 20-sided dice. (only you)
       17 + 3 + 14 = 34

  The second line is the one the game's own roll cannot show you. It reports the total and
  nothing else.


WHO SEES IT

  Read this part first.

  Dice the add-on rolls appear in your chat and nobody else's. The line is word for word the
  sentence the game uses for a real roll, which is exactly why it carries a quiet "(only you)"
  marker -- a roll you think your group saw and they did not is worse than no roll at all.

  For a roll the group can see, the game has to do the rolling. That is what holding R3 is
  for: the chat box ends up with /roll in it and you press Send.

    hold R3 -> Send

  Your 3d20 then goes out as a real roll, in the group's chat, instead of a fixed 1 to 100.

  Why the last press has to be yours: the calls that roll dice and the call that sends chat
  are both closed to add-ons. An add-on that could put arbitrary text on other people's screens
  would be a spam bot, so this is deliberate, and there is no way around it.

  There is also a setting that fills the chat box the moment you open the chat screen (off by
  default). It occupies the box, so when you opened chat to say something, clear it and type.


THE GAME'S RANDOM ROLL IS UNTOUCHED

  The third button still rolls 1 to 100, exactly as it always did.

  It is not on a long press of that button for a reason. The game rolls the instant the button
  goes down, so by the time a hold could be measured it has already rolled. Measuring it would
  mean the add-on taking that button over, and an add-on that owns it can no longer reach the
  roll the group sees. So the dice went on the spare button and the game's was left alone.


SETTINGS

    How many dice                        1 to 10
    How many sides                       2 to 1000
    Roll on R3 in the chat screen        on
    Show every die                       on
    Mark rolls only you can see          on
    Put /roll in the chat box            off

  Shipped as one die of 100 sides, which is what the chat screen's Random Roll already does --
  so installing it changes nothing about what a roll means until you decide otherwise.

  LibHarvensAddonSettings adds the panel. Without it, everything is on /pbdice.


COMMANDS

    /pbdice                  roll the dice you set
    /pbdice 3d20             roll that once, without changing the setting
    /pbdice count 3          how many dice, 1 to 10
    /pbdice sides 20         how many sides, 2 to 1000
    /pbdice keybind on|off   R3 in the chat screen
    /pbdice each on|off      show what each die rolled
    /pbdice tag on|off       mark rolls only you can see
    /pbdice prefill on|off   fill the chat box when the screen opens
    /pbdice status           what the settings are
    /pbdice reset            every setting back to default

  /dice works too, if no other add-on has taken it.


ANYTHING ELSE

  English and Japanese. The roll sentence is the client's own translated string, so it reads
  like a real roll in whatever language you play in.

  Settings are account-wide. Your dice do not change when you change character.
