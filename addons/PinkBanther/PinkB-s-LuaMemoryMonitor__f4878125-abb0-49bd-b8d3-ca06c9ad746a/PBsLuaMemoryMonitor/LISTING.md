# Store listing copy

Text for the Bethesda.net / ZOS Console AddOn Uploader entry. Plain text, no markdown —
paste as-is. The **name** field is what the in-game add-on browser shows, so it must read
`PB's LuaMemoryMonitor` there; `## Title` in the manifest does not reach that screen.

---

## Name

PB's LuaMemoryMonitor

## Overview (JP)

各アドオンが使っているメモリ量を、HUD上のウィンドウでランキング表示します。
アドオン全体の合計ではなくアドオンごとの量がわかるので、どのアドオンがメモリを多く
使っているか、ログイン後にどのアドオンが増え続けているかを見つけられます。

## Overview (EN)

Ranks your add-ons by the memory each one uses, in a window on the HUD. Not the total for all
add-ons, but a figure per add-on — so you can find which add-on uses the most memory, and which
one keeps growing after login.

---

## Description (JP)

ゲーム本体で確認できるのは、アドオン全体のメモリ使用量の合計だけです（/addonmem）。
このアドオンは、それをアドオンごとに分けて、多い順に表示します。

■ ウィンドウの表示内容

・保持(推定)
　各アドオンが現在持っているデータ量の推定値です。
　表示中は一定間隔で測り直します。
・増減
　ログイン後の最初の計測からの増加量です。
　遊んでいるうちに膨らみ続けるアドオンが見つかります。
・SV読込
　そのアドオンの保存データ（SavedVariables）の読み込みで増えた量です（実測）。
・初期化
　そのアドオンが読み込み完了時の初期化処理で使った量です（実測）。

ウィンドウ上部には、アドオン用メモリの現在値と上限、ログイン時の値も表示します。

ランキングの合計は、アドオン用メモリの使用量と一致します。
どのアドオンにも割り振れない分は、一覧の下に次の行で表示します。
・ファイル読込（分離不可）
　全アドオンのプログラム本体の読み込み分です（実測）。
・その他（システム側・未解放など）
　まだ解放されていない一時データや画面部品など、上記以外の残りです。

■ 設定

・ウィンドウの表示／非表示
・並び順（保持／増減／SV読込／初期化）
・保持量の自動再計測の間隔（しない／30秒／1分／5分）
・ウィンドウの位置、背景の濃さ
・ログイン時のメッセージのオン／オフ
・定期的なメモリ解放（しない／1分／5分／10分）
　使われなくなったデータのメモリを、ガベージコレクションで解放します。
　実行時にゲームが一瞬止まるため、初期設定はオフです。
　戦闘中に実行時刻が来た場合は、戦闘が終わるまで待ちます（設定で変更可）。

■ チャットコマンド

/pbmem　ウィンドウの表示／非表示
/pbmem scan　保持量を今すぐ測り直す
/pbmem sort　並び順を切り替える
/pbmem next　次のページ
/pbmem detail 名前　そのアドオンの数値の内訳をチャットに表示
/pbmem gc　今すぐメモリを解放し、解放できた量をチャットに表示
（/pbluamem でも同じです）

■ ご注意

・ゲームにはアドオンごとのメモリ量を直接知る方法がないため、数値は測定と推定から
　求めています。アドオン同士の比較や、時間による増減の確認にお使いください。
・各アドオンのプログラム本体の読み込み分は、アドオン別に分けられないため、
　合計のみ表示します。
・アドオンが内部だけで持っているデータや、画面部品は保持量に含まれません。
・ログイン時の読み込みが少し（約0.5秒）長くなります。
・他のアドオンやゲームの動作には手を加えません。読み取るだけです。

※設定画面の表示には LibHarvensAddonSettings が必要です（チャットコマンドは不要）。

## Description (EN)

The game only shows the total memory used by all add-ons together (/addonmem). This add-on
splits it per add-on and ranks them, largest first.

■ What the window shows

- Held (est.): what each add-on holds now, estimated. Measured again at an interval while the
  window is shown.
- Change: how much that has grown since the first measurement after login — finds the add-on
  that keeps growing while you play.
- Saved vars: what loading the add-on's saved data (SavedVariables) took, measured.
- Start-up: what the add-on's own start-up took, measured.

The top of the window also shows the current add-on memory against its limit, and its value at
login.

The ranking adds up to the add-on memory in use. What cannot be given to any one add-on is
shown under the list:
- File loading (not per add-on): loading every add-on's program files, measured.
- Other (system, not yet freed...): the rest, such as temporary data not yet freed and
  on-screen controls.

■ Settings

- Show or hide the window
- Sort by Held, Change, Saved vars or Start-up
- How often held memory is measured again: off, 30 s, 1 min or 5 min
- Window position and background opacity
- Message at login on or off
- Free memory regularly: off, every 1, 5 or 10 minutes. Runs the garbage collector to give back
  the memory of data no longer used. Each run stalls the game for a moment, so it is off by
  default, and a run that falls in combat waits until combat ends (can be changed).

■ Chat commands

/pbmem shows or hides the window | /pbmem scan measures again now | /pbmem sort changes the
order | /pbmem next shows the next page | /pbmem detail <name> lists what an add-on's figure is
made of | /pbmem gc frees memory now and says how much it gave back. /pbluamem works the same.

■ Please note

- The game has no way to read an add-on's memory directly, so the figures are measured and
  estimated. Use them to compare add-ons and to watch them change over time.
- The memory taken by loading every add-on's program files cannot be split per add-on, and is
  shown as one total.
- Data an add-on keeps only internally, and its on-screen controls, are not counted in Held.
- Logging in takes slightly longer (about 0.5 s).
- Nothing in other add-ons or in the game is changed; this add-on only reads.

The settings panel needs LibHarvensAddonSettings; the chat commands do not.
