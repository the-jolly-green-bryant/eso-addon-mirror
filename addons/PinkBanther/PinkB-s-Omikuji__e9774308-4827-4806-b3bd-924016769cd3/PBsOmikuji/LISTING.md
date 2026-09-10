# Store listing copy

Text for the Bethesda.net / ZOS Console AddOn Uploader entry. Plain text, no markdown —
paste as-is. The **name** field is what the in-game add-on browser shows, so it must read
`PB's Omikuji` there; `## Title` in the manifest does not reach that screen.

The Japanese font note is in both Overview and Description on purpose. It is the one thing
that decides whether the add-on is usable at all for a given player, and it belongs where
somebody sees it before installing rather than after.

---

## Name

PB's Omikuji

## Overview (JP)

ログインすると、チャット欄に今日のおみくじを一枚引きます。大吉から大凶まで七段階、本文は
一年分の全365種類。内容はすべてタムリエルの話です。同じキャラクターならその日はずっと同じ
運勢で、引き直しはできません。表示には日本語フォントが必要です。

## Overview (EN)

Draws a Japanese fortune slip in chat when you log in. Seven ranks from 大吉 (great blessing)
down to 大凶 (great curse), and 365 written fortunes -- one for every day of a year -- all of
them about Tamriel. The same
character sees the same slip all day and nothing rerolls it. The fortunes are Japanese and
need a Japanese font to render.

---

## Description (JP)

おみくじは、神社で引く紙の運勢占いです。運勢の段階と、その下に一行の言葉が書かれています。
このアドオンはそれをログイン時にチャット欄へ一枚引きます。書いてあるのはタムリエルの話です。

　PB's Omikuji: ブンブン、2026年9月10日（木）の運勢は……
　　【中吉】 料理をひとつ作り置きしておくと、あとで効いてくる。

二行だけです。ゾーン移動では表示しません。

■ 運勢は全365種類（一年分）

　　大吉　50種類　13.7%
　　中吉　60種類　16.4%
　　小吉　60種類　16.4%
　　吉　　60種類　16.4%
　　末吉　60種類　16.4%
　　凶　　45種類　12.3%
　　大凶　30種類　 8.2%

　抽選は七段階に対してではなく365本の本文に対して一様です。つまり収録数がそのまま出現率に
　なります。中間の四段を厚くしてあるのは、三日に一度大吉が出るおみくじは意味を持たなくなる
　からです。大凶がいちばん薄いのは、それがいちばん人に言いたくなる一枚だからです。

　365は収録数であって、一周の長さではありません。抽選はカードを配るのではなくハッシュなので、
　一年のうちに同じ一枚が二度出ることも、一度も出ない一枚があることもあります。

■ 同じ日は、同じ一枚

　引き直せる運勢は、運勢ではなくただの乱数です。そこでこのアドオンは乱数を使いません。
　運勢は「日付」と「引いた人」だけから決まります。

　　・同じキャラクターは、その日ずっと同じ運勢です。ゾーン移動でも、/reloadui でも、
　　　クラッシュでも、再インストールでも、設定ファイルを失っても変わりません。
　　・キャラクターごとに別の運勢です。メインが大吉の日に、書付用のサブが大凶になります。
　　・/omikuji で今日の一枚をもう一度表示します。引き直す方法はどこにもありません。

　一日に八回引きたくない場合は /omikuji scope account でアカウント単位にできます。

■ 日付はあなたのローカル時間です

　ESOのクライアントには日付を返す関数がありません。サーバー時計とローカル時計の二つから
　日付を計算しているので、運勢が切り替わるのはサーバーの深夜ではなく、あなたの深夜です。
　単純に作ると日本では朝9時に切り替わってしまい、夜の途中で運勢が変わることになります。

■ 主なコマンド

　　/omikuji                今日の運勢をもう一度表示
　　/omikuji status         現在の設定
　　/omikuji ranks          運勢の段階と収録数
　　/omikuji scope character | account   運勢の単位
　　/omikuji once on | off  その日の最初のログインだけ表示
　　/omikuji date on | off  一行目の日付表示
　　/omikuji on | off       ログイン時に引くかどうか
　　/omikuji reset          設定を初期値に戻す

　すべて /pbomi でも打てます。

■ 設定

　　ログイン時に引く　　　　　　　　初期値：オン
　　その日の最初のログインだけ　　　初期値：オフ（毎回表示。内容は同じ一枚です）
　　運勢の単位　　　　　　　　　　　初期値：キャラクターごと
　　日付を表示する　　　　　　　　　初期値：オン

■ チャット欄を汚しません

　表示はログイン時の二行だけです。ゾーン移動では出ません。設定を変えたときの通知もあり
　ません。それ以外にチャットへ書くのは、/omikuji コマンドを打ったときの返事だけです。

■ 日本語フォントについて

　運勢の本文と段階名は日本語です。これは仕様です。英語のおみくじは別のものですし、大吉は
　Great Blessing ではなく大吉だからです。日本語フォントを導入していないクライアントでは
　本文が表示されません。設定パネルやコマンドの応答は言語ファイルにあるので、日本語
　クライアントなら日本語、英語クライアントなら英語で表示されます。

■ 既知の制限

　クライアントにタイムゾーンを返す関数がないため、UTC-11 と UTC+13 は原理的に区別でき
　ません。人口の多い UTC+13（ニュージーランド・トンガの夏時間）側に合わせてあります。
　UTC-11、UTC+13:45、UTC+14 の地域では、日付が隣の日として表示され、切り替わりも隣の日の
　深夜になります。それ以外のすべての地域では正確です。

必須ライブラリはありません。LibHarvensAddonSettings があれば設定パネルが追加されます。
なくても /omikuji ですべて操作できます。

## Description (EN)

An omikuji is the paper fortune slip you draw at a Japanese shrine: a rank, and a line of
advice under it. This one is drawn in chat when you log in, and the advice is about Tamriel.

　PB's Omikuji: ブンブン、2026年9月10日（木）の運勢は……
　　【中吉】 料理をひとつ作り置きしておくと、あとで効いてくる。

Two lines. Never on a zone change.

■ 365 written fortunes, one for every day of a year

　　大吉　great blessing　　　50　13.7%
　　中吉　middle blessing　　 60　16.4%
　　小吉　small blessing　　　60　16.4%
　　吉　　blessing　　　　　　60　16.4%
　　末吉　blessing to come　　60　16.4%
　　凶　　curse　　　　　　　 45　12.3%
　　大凶　great curse　　　　 30　 8.2%

　The draw is uniform over the 365 slips rather than over the seven ranks, so a rank's share
　of your days is its share of the lines. The four middle ranks are the fat part, because a
　fortune that hands out 大吉 every third day stops meaning anything, and 大凶 is the
　thinnest, because it is the one people quote at each other and it should cost something to
　get.

　365 is the size of the writing, not a cycle length. The draw is a hash rather than a deal of
　a deck, so a year will repeat some slips and never reach others.

■ The same day is the same fortune

　A fortune you can reroll is not a fortune, it is a random number. So there is no random
　number here. The slip is decided by the date and by who is drawing, and by nothing else.

　　- The same character sees the same slip all day: through zone changes, /reloadui, a
　　  crash, a reinstall, or a lost settings file.
　　- Each character gets its own. Your main can have 大吉 on a day your writ alt has 大凶.
　　- /omikuji shows today's again. Nothing anywhere rerolls it.

　/omikuji scope account gives every character the same slip, if one fortune a day suits you
　better than eight.

■ The date is your date

　The client has no call that returns the date, so it is worked out from the server clock and
　the machine clock together. The fortune therefore rolls over at your midnight, not the
　server's — done the obvious way it would roll over at nine in the morning in Japan, in the
　middle of somebody's evening.

■ Commands

　　/omikuji                today's fortune again
　　/omikuji status         what the settings are
　　/omikuji ranks          the seven ranks and how many fortunes each has
　　/omikuji scope character | account   who gets their own fortune
　　/omikuji once on | off  only the first login of the day
　　/omikuji date on | off  the date in the first line
　　/omikuji on | off       draw at login, or do not
　　/omikuji reset          every setting back to default

　/pbomi is the short form of all of them.

■ Settings

　　Draw at login　　　　　　　　　　　　default: on
　　Only the first login of the day　　　default: off (every login; it is the same slip)
　　One fortune per　　　　　　　　　　　default: Character
　　Show the date　　　　　　　　　　　　default: on

■ It stays out of your chat window

　Two lines at login and nothing else. Nothing on a zone change, nothing when you change a
　setting. The only other lines it writes are answers to an /omikuji command you typed.

■ About the Japanese font

　The fortunes and the rank names are Japanese, and that is a decision rather than an
　oversight: an omikuji in English is a different object, and 大吉 is not "Great Blessing",
　it is 大吉. On a client without a Japanese font the fortunes will not render. The settings
　panel, the commands and the errors are in the string table, so an English client gets an
　English panel.

■ Known limitation

　The client has no timezone call, and a local clock reading cannot be told apart between
　UTC-11 and UTC+13. The band is set for UTC+13 — New Zealand and Tonga in summer. At UTC-11,
　UTC+13:45 or UTC+14 the date reads as the neighbouring day and rolls over at that day's
　midnight. Every other zone is exact.

No required libraries. LibHarvensAddonSettings adds the settings panel if you have it;
everything is reachable from /omikuji without it.
