# ギルドチャットのフィルタに何が使えるか — 調査結果

調査対象: `esoui/esoui`（live ブランチ、ゲームクライアント本体の Lua ソース + `ESOUIDocumentation.txt`）

## 結論

**`CHAT_ROUTER` のメッセージフォーマッタを差し替えるのが唯一の妥当な経路。** 公開メソッドだけで完結し、
クライアント設定を一切書き換えず、アドオンを外せば痕跡なく元に戻る。

## 経路は2つあり、採ったのは片方だけ

### 採用: フォーマッタの差し替え（`CHAT_ROUTER`）

`esoui/ingame/chatsystem/chathandlers.lua` の `ZO_ChatRouter:FormatAndAddChatMessage`:

```lua
local formattedEventText, ... = messageFormatter(...)
if formattedEventText then
    self:FireCallbacks("FormattedChatMessage", ...)
end
```

- `"FormattedChatMessage"` は **キーボード版・ゲームパッド版の両方**が購読している唯一の口
  （`sharedchatsystem.lua:1351` と `gamepad/chatmenu_gamepad.lua:100`）。
  つまりフォーマッタが `nil` を返せば、どちらのチャットにも出ない。ログにも残らない。
- 使う API は `CHAT_ROUTER:GetRegisteredMessageFormatters()` と
  `CHAT_ROUTER:RegisterMessageFormatter()` の2つだけ。どちらも `ESOUIDocumentation.txt` に
  private 表記のない通常の Lua メソッド（そもそもクライアント Lua 側の定義であって C 関数ですらない）。
- 元のフォーマッタを掴んでから差し替えるので、**書式は一切自作しない**。表示するメッセージは
  ゲーム本体のフォーマッタがそのまま整形する。他アドオンが同じフォーマッタを包んでいても壊れない。

ギルドチャンネルを運ぶイベントは2つ:

| イベント | 内容 |
| --- | --- |
| `EVENT_CHAT_MESSAGE_CHANNEL` | 発言そのもの。第1引数がチャンネル |
| `EVENT_GUILD_KEEP_ATTACK_UPDATE` | AvA の砦通知。**ギルドチャンネルに向けて**投稿される。送信者なし |

### 不採用: タブのカテゴリフィルタ（`SetChatContainerTabCategoryEnabled`）

こちらも技術的には存在する。`SharedChatContainer:SetWindowFilterEnabled(tabIndex, category, enabled)`
（`sharedchatsystem.lua:855`）が中で `SetChatContainerTabCategoryEnabled` を呼んでおり、
ゲームパッド版のコンテナ `GamepadChatContainer` は `SharedChatContainer` のサブクラスなので、
コンソールでも呼べる形にはなっている。カテゴリは `CHAT_CATEGORY_GUILD_1..5` とギルドごとに分かれている。

採らなかった理由:

1. **クライアント側の設定を永続的に書き換える。** アドオンの SavedVariables ではなく、ゲーム本体が
   保持する「このコンテナのこのタブでこのカテゴリを表示するか」という状態を書く。
2. **コンソールには元に戻す UI がない。** カテゴリの ON/OFF を操作する画面は
   `esoui/ingame/chatsystem/chatoptions.lua`、つまりキーボード UI のチャット設定だけ。
   `chatdata.lua` にも `--TODO: Allow these in console when we implement tabs and filters` と
   書かれている。アドオンがカテゴリを OFF にしたままアンインストールされると、
   **プレイヤーは戻す手段のないままギルドチャットを失う。**
3. `SetChatContainerTabCategoryEnabled` はドキュメント上 private 表記がないが、
   **書き込み系のクライアント設定関数は表記が当てにならない**（PB's ChatAssistant で
   `SetSetting` が表記なしの private だと実測済み。private 関数の呼び出しは pcall でも
   捕まえられず、実行中のチャンクごと落ちる）。試すこと自体に代償がある以上、
   同じ結果が無害な経路で得られるなら試す理由がない。
4. コンテナとタブがアドオンのロード時点で存在している保証もない。

## チャンネルとギルドの対応

ギルドチャンネルは **ギルド ID ではなくギルドのインデックス（1〜5）** で番号が振られている。
根拠は `chatdata.lua` の `ChannelInfo`:

```lua
[CHAT_CHANNEL_GUILD_2] = {
    ...
    requirementErrorMessage = GetGuildChannelErrorFunction(2),   -- 中で GetGuildId(2)
},
```

`CHAT_CHANNEL_OFFICER_2` も同じギルド（インデックス2）の役員チャンネル。

**`CHAT_CHANNEL_GUILD_1 + n` のような算術はしていない。** `ChannelType` 列挙体の数値は
`ESOUIDocumentation.txt` に載っておらず（名前の一覧しかない）、将来クライアントが振り直した場合、
算術は「別のギルドを黙って消す」という最悪の壊れ方をする。`Main.lua` では対応表を手書きしてある。
テストのスタブはチャンネル番号をわざと不連続・順不同にしてあり、算術に戻した実装はそこで落ちる。

設定の保存キーは **ギルド ID**。インデックスは加入・脱退で並び替わる「位置」でしかない。

## ギルド勧誘メッセージの判定

ギルドの勧誘は「ギルドファインダー → ギルド募集 → チャットにリンク」で行われる。
`SI_GUILD_RECRUITMENT_LINK_IN_CHAT` のキーバインドがキーボード側・**ゲームパッド側の両方**にあり
（`guildrecruitment_gamepad.lua:106,132`）、中身は:

```lua
local link = GetGuildRecruitmentLink(self.guildId, LINK_STYLE_BRACKETS)
ZO_LinkHandler_InsertLinkAndSubmit(link)
```

つまり勧誘文はチャット本文にリンクを含んだ状態で届く。リンクの形は
`ZO_LinkHandler_CreateLink` の `"|H%d:%s|h[%s]|h"` に従い、

```
|H<style>:guild:<guildId>|h[ギルド名]|h
```

`guild` は `zo_linkhandler.lua:16` の `GUILD_LINK_TYPE`。受信側もこれを見て分岐しており
（`guildbrowser_guildinfo_gamepad.lua:334`、`zo_gamepadlinks.lua:13` は
`ZO_LinkHandler_ParseLinkData(link)` で guildId を取り出している）、
`ZO_VALID_LINK_TYPES_CHAT` にも含まれている＝チャットに正規に流れるリンク種別である。

判定は本文に `|H%d+:guild:` があるかどうかだけ。**文面の推測ではなくゲーム自身が埋め込んだ
マークアップの照合**なので、勧誘文が何語で書かれていても等しく効く。逆に、リンクを含まない
ただの文章としての勧誘は原理的に判定できない（通常の会話と区別する材料が文面しかなく、
文面での照合は会話を巻き込んで消し始める）。

チャンネル種別のうち、ウィスパー（`CHAT_CHANNEL_WHISPER` / `CHAT_CHANNEL_WHISPER_SENT`）と
ギルドチャンネルはこの規則の対象外にしてある。理由は README と `Main.lua` の冒頭コメントに。

## 使えるギルド API

| API | 内容 |
| --- | --- |
| `GetNumGuilds()` | 所属ギルド数 |
| `GetGuildId(guildIndex)` | インデックス → ギルド ID。未読み込み・範囲外は 0 |
| `GetGuildName(guildId)` | 表示名 |
| `GetChannelName(channelId)` | `sharedchatsystem.lua` のグローバル関数。ギルドチャンネルは `dynamicName` なので中で `GetDynamicChatChannelName()` を呼ぶ |

`GetGuildId()` はアドオンのロード時点ではまだ 0 を返しうる（ギルドデータ未読み込み）。
そのため **ギルドが特定できない場合は必ず「表示する」に倒す**。設定パネルの行ラベルは
ギルド名で、LibHarvensAddonSettings の行ラベルは生成時に固定されるため、
パネルの構築は `EVENT_PLAYER_ACTIVATED` まで遅らせている。

## 自分の発言について

ギルドチャットは送信者本人にも同じチャンネルイベントで返ってくる。非表示にしたギルドに書き込むと
自分の発言まで消え、「送信できていない」ようにしか見えない。`keepOwn`（既定 ON）で
自分の発言だけは常に通す。`fromName` は文脈によってキャラクター名だったり装飾済み表示名だったりする
（クライアント側フォーマッタも `IsDecoratedDisplayName` で分岐している）ため、
表示名・キャラクター名の両方を、先頭の `@` を無視して比較している。

## 関連

- 実測優先の方針、コンソールでの検証コストについては ChatAssistant の知見を参照。
- private 関数は pcall で捕まえられず、チャンクごと落ちる（実測済み）。
