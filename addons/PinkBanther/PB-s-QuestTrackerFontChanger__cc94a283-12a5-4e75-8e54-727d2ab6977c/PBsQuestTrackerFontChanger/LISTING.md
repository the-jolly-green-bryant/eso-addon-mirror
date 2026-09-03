# Store listing copy

Text for the Bethesda.net / ZOS Console AddOn Uploader entry. Plain text, no markdown —
paste as-is. The **name** field is what the in-game add-on browser shows, so it must read
`PB's QuestTrackerFontChanger` there; `## Title` in the manifest does not reach that screen.

---

## Name

PB's QuestTrackerFontChanger

## Overview (JP)

画面右上のクエストトラッカーと、家の中でその下に出るハウス情報（ホームツアーで訪れた家の
名前・所有者・人数など）の文字サイズを変更します。小さくて読めない、大きすぎて視界を塞ぐ、
どちらも設定パネルのスライダーで調整できます。2つは別々に設定できます。

## Overview (EN)

Changes the text size of the quest tracker in the top right, and of the house information
panel that appears under it while you are in a house — the house name, owner and visitor count
you see on a home tour. Too small to read, or big enough to block your view — either way it is
a slider in the settings panel. The two are configured separately.

---

## Description (JP)

HUD右上の2つのトラッカーのフォントを調整するアドオンです。設定画面は2つの欄に分かれています。

■ クエストトラッカー

・文字サイズの変更（10〜72）
　クエスト名／ステップ説明／目標行 の3種類を個別に設定できます。
　ゲーム側でこの3つには別々のサイズが割り当てられているため（コンソール表示では
　目標行のほうがクエスト名より大きい）、スライダーも分けてあります。
　すべて同じ大きさにしたい場合は3つとも同じ値にしてください。

■ ハウス情報（ホームツアー）

家の中にいる間、クエストトラッカーの下に出るパネルです。自分の家でも、ホームツアーで
訪れた他人の家でも表示されます。

・文字サイズの変更（10〜72）
　家の名前／詳細行（愛称と所有者・人数・タグ）の2種類。
　ゲーム側が詳細の3行を同じフォントで描画しているため、スライダーは1本にまとめてあります。

■ 両方に共通

・書体の変更
　ゲームが持っている書体から5種類。欄ごとに別々に選べます。
・縁取りの変更
　影・縁取りなど、背景から文字を浮き立たせる方法。こちらも欄ごとです。

■ 特徴

・各スライダーの初期値は「ゲームが実際に描画しているサイズ」です。
　フォント定義の数値をそのまま使うのではなく、実際のラベルから測っています
　（ゲーム内部のサイズ指定は解像度に応じて拡縮されるため、定義上の数値をそのまま
　書き戻すと意図しないサイズ変更になります）。
・設定がゲーム標準と同じ間は、アドオンは一切フォントを書き換えません。
　入れただけの状態は、入れていない状態と完全に同じです。
・書体を変更してもUIの再読み込みは発生しません。
・設定はセッションを越えて残りません。アドオンを外せば元通りです。

■ 注意

・縁取り系を選ぶとクライアントが縁取り用の字形を生成します。日本語フォントでは
　これに約100MBかかり、コンソールのアドオン共有メモリと同規模です。動作が不安定に
　なる場合は「デフォルト」に戻してください。
・各トラッカーを表示するかどうかはゲーム本体の設定です
　（設定 > インターフェース）。
・タイマー付きクエストのカウントダウン表示は対象外です。

■ 設定

設定 → アドオン設定 → PB's QuestTrackerFontChanger（LibHarvensAddonSettings が必要です）

チャットコマンドでも操作できます。
　/pbquest                        コマンド一覧
　/pbquest status                 現在の設定と、実際に画面に出ているフォント
　/pbquest quest <数値>           クエストトラッカーの3種類すべて
　/pbquest quest <部分> <数値>    個別に設定（name / step / goal）
　/pbquest house <数値>           ハウス情報の2種類すべて
　/pbquest house <部分> <数値>    個別に設定（name / detail）
　/pbquest size <数値>            両方のすべて
　/pbquest on | off               両方の適用／解除
　/pbquest quest on | off         クエストトラッカーのみ
　/pbquest house on | off         ハウス情報のみ
　/pbquest reset                  ゲーム本来のフォントに戻す
　（/pbqt でも同じ）

## Description (EN)

Adjusts the fonts of the two HUD trackers in the top right. The settings panel is split into
two sections.

■ Quest tracker

- Text size (10–72), separately for the quest name, the step description and the objective
  lines. The game gives those three different sizes — in console display the objectives are
  drawn larger than the quest name — so the sliders are separate too. Set all three to the
  same number if you want them uniform.

■ House tracker

The panel under the quest tracker while you are in a house, yours or someone else's on a home
tour.

- Text size (10–72), for the house name and for the details under it: the nickname and owner,
  the visitor count, and the House Tours tags. The game draws all three detail lines with one
  font, so they share one slider.

■ Both

- Typeface: five of the game's own faces, chosen per section.
- Outline: shadow and outline styles, for separating the text from the scenery behind it.
  Also per section.

■ How it behaves

- Each slider starts at the size the game itself draws that part at, measured off a real label
  rather than taken from the font definition. The game's own size constants are scaled by
  resolution, so writing the definition's number back would be a size change nobody asked for.
- While every setting in a section still matches the game's own, the add-on never changes a
  font there at all. An untouched install is identical to not having it.
- Changing the typeface does not reload the interface.
- Nothing outlives the session. Removing the add-on is a complete undo.

■ Notes

- Outline styles make the client build outline glyphs, which the game's own source puts at
  about 100 MB for a CJK font — the same size as the whole memory pool console add-ons share.
  If the game becomes unstable, put this back to Default.
- Whether either tracker is shown at all is the game's own setting, under Settings > Interface.
- The countdown on timed quests is a separate piece of UI and is not touched.

■ Settings

Settings → Add-On Settings → PB's QuestTrackerFontChanger (requires LibHarvensAddonSettings)

Chat commands:
  /pbquest                        this list
  /pbquest status                 settings, and the font actually on screen
  /pbquest quest <n>              all three quest tracker sizes
  /pbquest quest <part> <n>       one part: name | step | goal
  /pbquest house <n>              both house tracker sizes
  /pbquest house <part> <n>       one part: name | detail
  /pbquest size <n>               every size in both
  /pbquest on | off               both sections
  /pbquest quest on | off         the quest tracker only
  /pbquest house on | off         the house tracker only
  /pbquest reset                  back to the game's own fonts
  (/pbqt is the same command)

---

## Dependencies

LibHarvensAddonSettings

## Version

1.0.0
