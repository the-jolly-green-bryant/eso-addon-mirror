local s = PBS_CLOCK_STRINGS
local jp = {
    real = "現在時刻", game = "ゲーム内時刻", unavailable = "時刻を取得できません",
    display = "表示する時刻", both = "両方", style = "時計の種類",
    digital = "デジタル（テキストのみ）", analog = "アナログ", enabled = "時計を表示",
    seconds = "秒・秒針を表示", hour24 = "デジタルを24時間表記にする",
    size = "アナログ文字盤の大きさ", fontSize = "文字サイズ", opacity = "不透明度（%）",
    dialScale = "アナログ文字盤の倍率（%・文字サイズは独立）",
    align = "文字の揃え方", left = "左寄せ", center = "中央揃え", right = "右寄せ",
    x = "横位置（px）", y = "縦位置（px）", reset = "設定を初期化", resetButton = "初期化",
    preview = "設定調整中にプレビューを表示", previewButton = "この時計をプレビュー",
    showText = "下部の時刻テキストを表示（見出しを含む）",
    color = "文字色", layer = "HUDの表示レイヤー", back = "HUDの背面", normal = "標準", front = "HUDの前面",
    red = "文字色：赤（%）", green = "文字色：緑（%）", blue = "文字色：青（%）",
    source = "ゲーム内時刻の基準", global = "タムリエル共通", zone = "現在のゾーン",
    note = "現在時刻は端末の時計、ゲーム内時刻はESOのAPIから取得します。ゾーンによって昼夜が異なる場合があります。4つの時計それぞれに位置・サイズ・文字色・HUDレイヤーを保存します。調整した時計は設定画面の前面に実際の位置で表示され、設定画面を閉じると通常の表示条件とレイヤーに戻ります。位置は画面左上からのピクセル数で指定します。",
}
for key, value in pairs(jp) do s[key] = value end
