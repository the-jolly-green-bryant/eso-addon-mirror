# Store listing copy

Text for the Bethesda.net / ZOS Console AddOn Uploader entry. Plain text, no markdown —
paste as-is. The **name** field is what the in-game add-on browser shows, so it must read
`PB's ChatFilter` there; `## Title` in the manifest does not reach that screen.

---

## Name

PB's ChatFilter

## Overview (JP)

読みたいギルドのチャットだけをチャット欄に残します。5つのギルドチャンネルと5つの役員
チャンネルを1つの欄で受け止める必要はありません。ギルドリンク付きの勧誘メッセージを
隠すオプションもあります。ギルド以外のチャンネルには一切触れません。

## Overview (EN)

Keeps the guild chat you actually read and drops the rest. Five guild channels and five
officer channels do not all have to land in one window. There is an option to hide guild
recruitment adverts as well. No other channel is touched.

---

## Description (JP)

ギルドに複数入っていると、ギルドチャンネルと役員チャンネルが同じチャット欄に一度に
流れ込みます。コンソールにはこれをタブで振り分ける手段がありません（ゲーム本体の
ソースにも「タブとフィルタを実装したらコンソールでも許可する」という書きかけのメモが
残っています）。そのフィルタを、ギルドチャンネルに限って用意したのがこのアドオンです。

■ ギルドごとの表示設定

・所属ギルドごとに「ギルドチャット」「役員チャット」を個別にオン／オフできます。
　別チャンネルなのでスイッチも別です。通常チャットは非表示のまま役員チャットだけ
　追う、といった使い方ができます。
・全体スイッチが1つあります。オフにすると、個別の設定を残したまま一時的に
　すべてのギルドチャンネルを表示します。
・自分の発言は、非表示にしたギルドでも既定で表示されます。これがないと、
　非表示のギルドに書き込んでも何も出ず、送信できていないように見えてしまいます。

■ ギルド勧誘メッセージの非表示（任意・初期はオフ）

ギルドの勧誘は、ギルドファインダーの「チャットにリンク」でゾーンチャットに自ギルドの
リンクを貼る形で行われます。このアドオンはそのギルドリンクの有無を見ます。文面を
推測するのではなく、ゲーム自身がメッセージに埋め込んだリンクを正確に判定するため、
勧誘文が何語で書かれていても等しく効きます。

3つは対象外です。

・ギルドチャンネル
　自分のギルドに貼られたギルドリンクはそのギルドの会話です。そのチャンネルを読むか
　どうかは上のギルド別スイッチですでに決めているため、こちらは口を出しません。
・ウィスパー
　既定で対象外です。ウィスパーでの勧誘も実際にありますが、ウィスパーは相手が直接
　あなたに話しかけてきたものです。黙って消える損失のほうが、勧誘を1件読むより
　大きいと考えました。設定でウィスパーも対象にできます。
・自分の発言
　上と同じ扱いです。

リンクを含まない、ただの文章としての勧誘は対象外です。通常の会話と区別する材料が
文面しかなく、文面での照合は会話まで巻き込んで消し始めるためです。

■ 触れないもの

ゾーン、say、yell、ウィスパー、グループ、エモート、NPCの発言、各種システムメッセージ、
他のアドオンの出力。これらはチャンネルを見た時点で素通しします。処理の分岐がそもそも
ありません（勧誘フィルタをオンにした場合のみ、リンクの有無だけを見ます）。

■ 動作の特徴

・判断できないときは必ず「表示」に倒します。
　ギルド情報が読み込まれていない、設定したことがない、フックに失敗した——
　どの場合も表示します。隠しすぎるフィルタは、待っていたギルドの招待を
　黙って失わせます。
・入れただけの状態は、入れていない状態と完全に同じです。
　どれか1つをオフにするまで何も書き込みません。
・ゲーム本体の設定は一切書き換えません。
　チャットのカテゴリ設定を書き換える方法もありますが、コンソールにはそれを戻す
　画面がなく、アドオンを外した後もギルドチャットが消えたままになります。
　この方法は採っていません。アドオンを外せば完全に元通りです。
・非表示にした件数を数えています。/pbfilter で確認できます。

■ 注意

・設定パネルのギルド一覧は「ログイン時点の所属ギルド」です。加入・脱退したあとは
　UIを再読み込みすると描き直されます。チャットコマンドは常に最新の一覧を見ます。
・ギルド番号はゲームと同じ並びです（2番目のギルド＝ /g2）。
・PCにはゲーム本体にタブごとのカテゴリフィルタがあります。このアドオンは、それが
　用意されていないコンソール向けに作っています（PCでも動作します）。

■ 設定

設定 → アドオン設定 → PB's ChatFilter
（LibHarvensAddonSettings があれば表示されます。無くてもアドオンは動作し、
　チャットコマンドですべて操作できます）

チャットコマンド
　/pbfilter                        現在の状態と、非表示にした件数
　/pbfilter on | off               全体スイッチ
　/pbfilter <n> on | off           n番目のギルドの両チャンネル
　/pbfilter <n> guild on | off     n番目のギルドのギルドチャットのみ
　/pbfilter <n> officer on | off   n番目のギルドの役員チャットのみ
　/pbfilter only <n> [<n> ...]     指定したギルドだけ表示し、残りは非表示
　/pbfilter all                    すべてのギルドを表示
　/pbfilter none                   すべてのギルドを非表示
　/pbfilter own on | off           自分の発言を常に表示
　/pbfilter recruit on | off       ギルドリンクを含むメッセージを非表示
　/pbfilter recruit whisper on|off ウィスパーも対象にする
　/pbfilter banner on | off        ログイン時に状態を表示
　/pbfilter reset                  設定をすべて破棄
　（/pbcf でも同じ）

## Description (EN)

Being in several guilds means the guild channels and the officer channels all arrive in one
chat window, and on console there is nothing to sort them into — the game's own source still
carries an unfinished note about allowing tabs and filters there one day. This add-on is that
filter, for the guild channels.

■ Per guild

- Each guild you are in gets two switches, guild chat and officer chat. They are separate
  channels, so you can follow the officer channel of a guild whose main chat you have muted,
  or the other way round.
- One master switch turns the whole thing off, so you can see everything for a while without
  losing the choices underneath.
- Your own messages are shown even in a guild you have switched off. Without that, typing into
  a hidden guild channel prints nothing and looks as though the message was never sent.

■ Guild recruitment adverts (optional, off by default)

Guilds advertise by linking themselves in zone chat: the Guild Finder's "Link in Chat" puts a
guild link in the message. This spots that link. It is an exact test on something the game
itself put in the message, not a guess about wording, so it works whatever language the advert
is written in.

Three things stay exempt.

- Guild channels. A guild link in your own guild's chat is your guild talking, and whether you
  read that channel at all is already the per-guild switch's business.
- Whispers, unless you ask for them. Whisper recruitment is real, but a whisper is a person
  addressing you directly, and losing one silently is worse than reading an advert.
- Your own messages, on the same switch as everywhere else.

An advert typed as plain text with no link in it is not affected. Nothing tells such a message
apart from ordinary chat except its wording, and matching on wording is how a filter starts
eating conversations.

■ What it never touches

Zone, say, yell, whisper, group, emote, NPC speech, every system message, and every other
add-on's output. The filter looks at the channel, sees it is not a guild channel, and hands the
message straight on — there is no second code path for them to fall down. (With the
recruitment option on, those channels are checked for a guild link and nothing else.)

■ How it behaves

- When it cannot be sure, it shows the message. Guild data not loaded yet, a guild never
  configured, the hook failing to install — all of them show. A filter that hides too much
  loses the guild invite you were waiting for and never tells you.
- An untouched install is identical to not having it. Nothing is written until you switch
  something off.
- No game setting is changed. There is a way to do this by rewriting the client's own chat
  category settings, but console has no screen to undo that, so an uninstall would leave guild
  chat permanently gone. This does not go near it. Removing the add-on is a complete undo.
- It counts what it hides, and /pbfilter reports the count.

■ Notes

- The guild list on the settings panel is the guilds you had when you logged in. Join or leave
  one and reload the UI to redraw it; the chat command always reads the current list.
- Guild numbers are the game's own (the second guild is /g2).
- On PC the game already has per-tab category filters. This is built for console, where it does
  not, and works on PC as well.

■ Settings

Settings → Add-On Settings → PB's ChatFilter
(shown if LibHarvensAddonSettings is installed; without it the add-on still works and the chat
command does everything)

Chat commands:
  /pbfilter                        state, and how much has been hidden
  /pbfilter on | off               master switch
  /pbfilter <n> on | off           guild n, both channels
  /pbfilter <n> guild on | off     guild n, guild chat only
  /pbfilter <n> officer on | off   guild n, officer chat only
  /pbfilter only <n> [<n> ...]     show these guilds, hide the rest
  /pbfilter all                    show every guild
  /pbfilter none                   hide every guild
  /pbfilter own on | off           always show your own messages
  /pbfilter recruit on | off       hide messages that link a guild
  /pbfilter recruit whisper on|off and in whispers too
  /pbfilter banner on | off        print the state at login
  /pbfilter reset                  forget every choice
  (/pbcf is the same command)

---

## Dependencies

LibHarvensAddonSettings (optional — the settings panel only; the add-on loads and filters
without it)

## Version

1.2.0

---

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its
affiliates. The Elder Scrolls and related logos are registered trademarks or trademarks of
ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
