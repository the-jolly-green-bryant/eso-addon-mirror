# ゲームチャット語彙の拡充（1.1.4-dev）

調査日：2026-09-16。**新規キー486件**（共通チャット122件、ESO295件、シロディール69件）。省略形・複数語の表現・表記違いを含む件数で、486種類の独立した概念という意味ではありません。既存の7,352キーから7,838キーになります。追加した指示のうち26件には、否定・助動詞の文で使う動詞の読みも付けています（新規キー数には重複計上しません）。

日本語訳はゲーム内チャットで意味を把握しやすいよう、この辞書用に記述しています。サイトの説明文・用語集をそのまま転載したものではありません。参照先で語義と用例を確認した基本語に加え、`thx for the run`、`save ults`などの通常の語の組み合わせ、略語の表記違いを登録しています。登録した全フレーズが参照先にそのまま掲載されているという意味ではありません。

## 参照先と対応範囲

辞書末尾の `[chat]` などのコメントは、以下の調査区分を示します。

- **chat / shortchat**：休憩・復帰・感謝・謝罪・確認の略語と、その組み合わせ。
  - [Rei's Random Guide to MMP Gaming Terms](https://www.mit.edu/~rei/game-terms.html)：MMOチャットでのBRT、WTGなど。
  - [Webopedia: Text Abbreviations](https://www.webopedia.com/reference/text-abbreviations/)：BBS、BBIAF、TTFN、LTNS、TYT、LMK、FWIWなどの展開確認。
  - [VALORANTコミュニティのチャット用語相談](https://www.reddit.com/r/VALORANT/comments/1418kus)：NJなどの使用例。ESOと衝突する略語は取り込まない。
- **modern**：最近のネット会話・リアクション・対戦後の短評。
  - [Newgrounds: Glossary of BBS Slang](https://newgrounds.wiki.gg/wiki/Glossary_of_BBS_Slang)：capなどのネット会話の意味。
  - [Roblox Terms & Slang](https://progameguides.com/roblox/roblox-terms-slang-guide/)：bruh、ISTGなど。
  - [Reddit: Spoken as a Gen Z-er myself](https://www.reddit.com/r/memes/comments/zzi5j5/spoken_as_a_gen_zer_myself/)：frfr、no cap、ongの会話用例。
  - [BetterTTVのエモート解説](https://www.setupking.de/blog/betterttv-emotes)：monkaS、monkaW、OMEGALUL、Sadge、PepeHands。
  - [ゲーム会話の用語一覧](https://spawnpoint.be/gaming-terms-slang-glossary/)：競技・オンラインゲームの一般的な語義の照合。
- **eso**：募集・役割・ビルド・戦闘の用語。
  - [ESO公式フォーラム: Terminology and Abbreviations](https://forums.elderscrollsonline.com/en/discussion/584321/eso-terminology-and-abbreviations-explained-for-you)：PvX、lowbie、mule、クラス接頭辞、GCD、spammable、装備バーなど。日本語版の既存辞書に合わせた訳を作成。
  - [ESO公式フォーラム: Slang and Abbreviation Dictionary](https://forums.elderscrollsonline.com/en/discussion/136290/the-eso-slang-and-abbreviation-dictionary)：achisなど。古い仕様や当時の勢力評価は採用しない。
  - [ESOコミュニティ: Fake Tanks and Healers](https://www.reddit.com/r/elderscrollsonline/comments/1ltxcak)：役割を果たさず別のロールで参加するプレイヤーへの呼称。
  - [ESOコミュニティ: NRD / RND](https://www.reddit.com/r/elderscrollsonline/comments/zxukt9)：ランダムノーマルダンジョンの略語。
  - [ESO公式フォーラム: Arcanist specs](https://forums.elderscrollsonline.com/en/discussion/626587/poll-starcanist-marcanist-how-will-we-refer-to-arcanist-specs)：magarc、stamarc。
- **raid**：練習募集・進行・ギミック・火力測定。ESOでも通じる共通語を採用。
  - [FFXIV Community Wiki: Acronyms and common terms](https://ffxiv.consolegameswiki.com/wiki/Acronyms,_abbreviations,_and_common_terms)：prog、fresh prog、reclear、チェック系、編成など。他ゲームの固有コンテンツ名・クラス略号は採用しない。
  - [Late to the Party Finder: Glossary](https://latetothepartyfinder.com/glossary-of-ffxiv-acronyms-terms-and-lingo/)：blind、burn、uptime / downtimeなど。
  - [ESOコミュニティ: Parse DPS](https://www.reddit.com/r/elderscrollsonline/comments/1couno2/meaning_of_parse_dps_in_hardcore_pve_guilds/)：ESOでのparseの用法。
- **trade**：取引・クラフト依頼・素材・価格に関する略語と短文。
  - [Wowhead: Classic WoW Glossary](https://www.wowhead.com/classic/guide/classic-wow-glossary-terminology)：BoE、BoP、CoD、LFW、OBO、素材持参などの基本語。
  - 上記ESOフォーラムの用語集でも語義を照合。BoPはESOのグループ内取引の例外を踏まえ「取得時に譲渡制限」とし、「一切取引不可」とはしない。
- **calls**：募集条件、初心者の申告、集合・攻撃・蘇生・休憩の短文。上記eso / raid / chatの語を組み合わせた、訳文を確認済みの定型文。
  - [ESOコミュニティ: Falkreath Hold Hard Mode](https://www.reddit.com/r/elderscrollsonline/comments/ne5qat)：hard stackとsoft stackを異なる集合指示として扱う。
- **pvp**：シロディールの連携・攻城・装備・状態。
  - [ESOコミュニティ: Ball groups](https://www.reddit.com/r/elderscrollsonline/comments/1eeck3y)：ult / ulti dump、相互回復、negateなどの用法。
  - [ESOコミュニティ: PvP rank](https://www.reddit.com/r/elderscrollsonline/comments/suk9g8)：zerg surfingと人数不利での戦闘。
  - [ESO公式フォーラム: Burning Siege](https://forums.elderscrollsonline.com/en/discussion/216883/burning-siege-while-in-dark-cloak)：攻城兵器を燃やす行為。
  - [ESO公式フォーラム: Most used potion](https://forums.elderscrollsonline.com/en/discussion/387468/most-used-potion)：detect / immovのポーション略語。

## 衝突・誤訳への対処

- 新規キーは既存の共通辞書・ESO辞書・シロディール辞書と照合してから追加。ユーザー辞書の優先順位は維持。
- `DW`をdon't worryで上書きしない（二刀流）。`BB`、`WP`、`MS`、`LS`、`FS`など、既存のシロディールの登録も維持。
- `cap`を単独で「嘘」にしない。`no cap`全体を「嘘じゃないよ」と登録。
- `cheese`、`salty`などの一般語を一律にゲームスラングに変更しない。
- 表記を既存のTokenizerに通してから登録。`sry all` / `soz all`は`sorry all`、`dc'd`は`dcd`で照合される。届かないキーを増やさず、元の入力表記もテストする。
- `ult dump then push roe`のような連続指示では、`then`の前後の定型句を保持して順番どおりに訳す。
- `don't hard stack`、`don't ult dump`などは動詞の読みを使い、肯定の指示にしない。短い`no hard stack`なども明示的に登録。

## 検証と限界

`lua test/slang.lua` / `luajit test/slang.lua`：494入力形を大小文字・シロディール優先ON/OFFで確認し、文中使用・否定・連続指示・一般語・既存の地名・ユーザー辞書の優先を含む計2,012チェック。

既存の`test/run.lua`、`test/accuracy.lua`、`test/outgoing.lua`、共有関連テスト、`test/dict_check.lua`も実行。新語一覧と期待訳は`test/slang_cases.lua`、実際の辞書は各辞書ファイル末尾にある。

この辞書は一つの主要な訳を選ぶ方式。皮肉、地域・ギルド固有の使い方、任意の長文の文法や未知の省略形をすべて解釈できるわけではない。略語だけで宛先・主語などを補いすぎない。件数の増加は実際のチャット全体での正答率を測定した結果ではなく、実機での表示確認は別途必要。


## 1.1.5-dev：基本略語の追加

23キーと7種類の省略表記を追加。辞書は7,861キー。1.1.4-dev分を含むスラング検証は2,139チェックです。

- `tc`はTake careの別れの挨拶として「元気でね」。[Slang.net: TC](https://slang.net/meaning/tc)
- `cu`、`cul`、`cul8r`、`bfn`、`b4n`、`ttyl8r`などは別れ際の挨拶。[Albino Blacksheep: Internet Acronyms](https://www.albinoblacksheep.com/text/acronyms)、[Webopedia](https://www.webopedia.com/reference/text-abbreviations/)
- `ttys`、`hth`、`wya`、`wyd`の意味を個別確認。[TTYS](https://slang.net/meaning/ttys)、[HTH](https://slang.net/meaning/hth)、[WYA](https://slang.net/meaning/wya)、[WYD](https://slang.net/meaning/wyd)
- `w8`、`gr8`、`rly`、`prolly`、`plox`、`srs`、`m8`は既存の単語への展開として処理。[チャット用語一覧](https://slang.net/terms/text_messaging-all)
- `tc all`、`gtg tc`などは上記略語の組み合わせ。同じ語の大小文字・文中使用・否定・ユーザー辞書の優先も検証。

文脈次第で別の意味もあるため、TCは一般的な別れの挨拶、HTHは助言後の「参考になればうれしいです」を基本訳にしています。既存のESO用語・シロディール用語は上書きしていません。

## 1.1.6-dev：Slang.netの追加調査

2026-09-16時点の8カテゴリの全件一覧（`-all`）を取得し、重複を除いた4,538語を既存辞書・トークナイザーと照合しました。新規キーは1,363件、辞書全体は9,224キーです。日本語訳は短い語義を元に独自に作成しています。サイトの解説文は同梱していません。実行時のネット接続や外部ライブラリの追加はありません。

参照カテゴリ：

- [online_gaming](https://slang.net/terms/online_gaming-all)
- [online_chat](https://slang.net/terms/online_chat-all)
- [text_messaging](https://slang.net/terms/text_messaging-all)
- [common](https://slang.net/terms/common-all)
- [online_auctions](https://slang.net/terms/online_auctions-all)
- [web_forums](https://slang.net/terms/web_forums-all)
- [social_media](https://slang.net/terms/social_media-all)
- [email](https://slang.net/terms/email-all)

[SLANGNET_AUDIT.tsv](SLANGNET_AUDIT.tsv)は出典の表記・正規化キー・判定・カテゴリ・参照URLを収録しています。ステータスは以下です（これは原語表記の件数で、追加キー数とは一致しない場合があります）。

- `existing`：487件。既存キーに一致（この調査で語義を上書きしたものではありません）。
- `deferred_scope_or_ambiguity`：2504件。今回未採用：他ゲーム等の固有語、チャット用途の優先度、多義性などを考慮。
- `added`：1363件。追加したキーに一致。
- `inflected`：61件。既存語の活用形などで認識。
- `deferred_token_shape`：123件。数字のみ・句読点など、今回の単語辞書ではそのまま扱えず見送り。

未採用の区分は候補をまとめた記録であり、各語を永久に利用不可と判断したものではありません。サイト全体の全カテゴリを収録したものでもありません。既存キーと正規化後のキーが衝突するものは上書きせず、活用で認識できるものも重複登録を避けています。複数の意味がある略語はチャットで使う意味の一つを採用しています（例：`ib` は「戻りました」）。すべての文脈で正しい意味になる保証はなく、必要に応じてユーザー辞書で変更できます。

検証：`test/slangnet.lua` は新規1,363キーの原表記・大文字表記を両ゾーン設定で実際に翻訳し、未知語が残らないこと、名詞・定型句の全文一致、品詞・訳語を確認します。既存の翻訳・否定・ユーザー辞書優先順位・辞書共有の回帰テストも併用します。ゲーム実機での確認は別途必要です。
