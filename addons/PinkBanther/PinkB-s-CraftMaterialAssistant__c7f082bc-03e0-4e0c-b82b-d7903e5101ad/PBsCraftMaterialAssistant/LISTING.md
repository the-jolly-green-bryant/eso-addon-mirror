# Store listing copy

Text for the Bethesda.net / ZOS Console AddOn Uploader entry. Plain text, no markdown —
paste as-is. The **name** field is what the in-game add-on browser shows, so it must read
`PB's CraftMaterialAssistant` there; `## Title` in the manifest does not reach that screen.

---

## Name

PB's CraftMaterialAssistant

## Overview (JP)

作りたいクラフトアイテムを選び、作る回数を指定すると、必要な材料・現在の所持数・不足数を
別ウィンドウに一覧表示します。料理・飲み物・家具図面など、覚えているレシピが対象です。
候補はカテゴリー絞り込みと名前検索から選べます。

## Overview (EN)

Pick something you know how to make, say how many, and a window of its own lists every
ingredient it needs, how many you are carrying, and how many you are short. Food, drink and
furnishing plans. Narrow the list by category, or search it by name.

---

## Description (JP)

覚えているレシピ（料理・飲み物・家具図面など）から作りたいものを選ぶと、必要な材料が別
ウィンドウに表で出ます。

■ 表示される内容

　材料名 ／ 必要数 ／ 所持数 ／ 不足数

　不足している材料は赤で表示されます。上段には「いま手持ちで何回作れるか」も出ます。
　所持数はバッグ・銀行・クラフトバッグを合計した数です（設定で変更できます。家の金庫は
　クラフト台から取り出せないため、初期設定では数えません）。

■ 作るものの選び方

　1. 設定パネルの「カテゴリー」で絞り込む、または チャットで /pbcraft find <文字列>
　2. 候補一覧がウィンドウに表示されます
　3. 「ページ」「候補」スライダーで印を動かし、「決定」を押す

　候補一覧は設定パネルではなくアドオンのウィンドウ側に描画します。設定パネルの項目名は
　すべて固定文字列で、実行時に中身が変わる一覧を設定ライブラリに作らせていません。
　コンソールで確実に動かすための設計です。

■ 作成回数

　スライダーで 1〜200 回。これは「作る回数」で、できあがる個数ではありません。1回で4個
　できるレシピを3回作れば、材料は3回ぶん、できあがりは12個です。できあがりの個数は
　ウィンドウの上段に表示します。

■ チャット欄を汚しません

　ログイン時の通知も、設定を変えたときの通知もありません。表示は専用ウィンドウに出し、
　チャットに書くのは /pbcraft コマンドを打ったときの返事だけです。

■ 表示のオン／オフ

　設定パネルのいちばん上が「ウィンドウを表示する」スイッチです。必要なときだけ出して、
　終わったら消す使い方を想定しています。オフの間はウィンドウを閉じるだけでなく、
　インベントリの監視も完全に止めます。選択中のアイテムと作成回数はそのまま残るので、
　オンに戻せば続きから使えます。チャットからは /pbcraft on と /pbcraft off です。

■ ウィンドウの調整

　幅・高さ・基準位置・縦横のずれ・文字サイズ・書体・縁取り・背景の濃さ・表示レイヤー。
　マウス操作は一切受け付けないので、ゲーム側のクリックを奪うことはありません。

■ 主なコマンド

　/pbcraft find <文字列>  名前で検索
　/pbcraft pick <番号>    候補を選択
　/pbcraft qty <n>        作成回数
　/pbcraft probe          カタログ件数と走査時間の計測

■ 対象外

　鍛冶・仕立て・木工・宝飾（装備）、錬金、付呪は対象外です。これらは一覧から1つ選ぶ形に
　ならない（型紙・素材・素材数・スタイル・特性の組み合わせ）ため、別の選択画面が必要です。

必須ライブラリはありません。LibHarvensAddonSettings があれば設定パネルが追加されます。
なくても /pbcraft ですべて操作できます。

## Description (EN)

Pick something you know how to make — food, drink, a furnishing plan — and the window lists
what it takes.

■ What it shows

　Material / Need / Have / Short

　Anything you are short of is drawn in red, and the top line says how many batches your
　materials actually cover. The held count is your backpack, bank and craft bag added up
　(configurable; house banks are not counted by default, because you cannot reach them from a
　crafting station).

■ Choosing something

　1. Narrow with the Category dropdown, or search with /pbcraft find <text>
　2. The candidates appear in the window
　3. Move the Page and Candidate sliders, then press Take

　The candidate list is drawn in the add-on's own window rather than in the settings panel.
　Every panel row has a fixed label; nothing asks the settings library to draw a list that
　changes at runtime. That is what makes it dependable on a console.

■ How many

　1 to 200, and it is the number of crafts, not of items. A recipe that yields four, made
　three times, is three sets of ingredients and twelve items — and the window says so.

■ It stays out of your chat window

　No login banner, nothing when you change a setting, nothing when the table updates. The
　only lines it writes are answers to a /pbcraft command you typed.

■ Showing and hiding it

　The first row of the settings panel is the switch. It is meant to be put up while you plan
　a batch and taken down again; while it is off the window is gone and the add-on stops
　listening to your bags entirely. What you picked and how many are kept, so turning it back
　on carries on where you left off. /pbcraft on and /pbcraft off do the same.

■ The window

　Width, height, corner, offsets, text size, typeface, outline, background opacity and draw
　order are all settings. It takes no mouse input at all, so it can never take a click away
　from the game underneath it.

■ Commands

　/pbcraft find <text>   search by name
　/pbcraft pick <n>      take a candidate
　/pbcraft qty <n>       how many times to make it
　/pbcraft probe         count the catalogue and time one pass

■ Not included

　Smithing (blacksmithing, clothier, woodworking, jewellery), alchemy and enchanting. None of
　them is a list you pick one row out of — a smithed item is a pattern crossed with a
　material, a level, a style and a trait — so they need a picker of their own.

No required libraries. LibHarvensAddonSettings adds the settings panel if you have it;
everything is reachable from /pbcraft without it.
