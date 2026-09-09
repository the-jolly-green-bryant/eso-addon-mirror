# PB’s ChatAssistant 1.14.6

1.14.6では投稿先の表示をチャットログに一本化しました。アドオン独自のHUD表示は削除し、
切り替えのたびにチャットログへ出力します。ログ設定に関係なく表示するので、後から遡って確認できます。
オフィサーチャンネルは `ギルド名（オフィサー）` と表示し、同名のギルドチャンネルと区別できます。

ESOコンソール版のチャット入力補助と、HUDでの投稿先チャンネル切り替え。

## HUDでの切り替え

1. チャット入力画面を閉じ、通常のHUDに戻ります。
2. **L2を押したままL3（左スティック押し込み）を押します。**
3. L2を保持したままL3を押すたびに、次の投稿先へ切り替えます。
4. L2を離すと、L3の通常操作へ戻ります。

L2はバインドせず、押し込み量だけを読みます。L3の入力レイヤーはL2を押している間だけHUDに追加します。
L2の防御を奪った1.8.0の二重バインドには戻していません。
同時押しで取りこぼす場合は、L2を少し先に押してからL3を押してください（確認周期10ms、実際はフレーム更新にも依存）。

1.14.0で切り替えが動作したとの実機報告を受けています。以降は表示とログの整理のみで、入力の仕組みは変えていません。
L2を押しながらL3の元の操作を使うこととは両立しません。その組み合わせをチャンネル切り替えへ割り当てます。

120秒の制限はありません。通常時の診断ログは出しません。HUDには選択中の投稿先を表示します。
文字入力画面、メニュー、Enter捕捉中は切り替え用レイヤーを外します。エリア移動後は自動で再開します。

## 設定と診断

- `/pbchat hudchannel off` / `on`：HUDショートカットを停止・再開。
- `/pbchat entrychannel off` / `on`：互換用の別名。新しいHUDショートカットへ適用します。
- `/pbchat hudstatus`：L2の読み取り値、L3の受信回数、レイヤー状態、エラーを一度だけ表示。
- `/pbchat binds`：実際に宣言しているL3アクションと継承元を表示。
- `/pbchat forcelayer`：旧強制モードは廃止。通常操作を妨げるレイヤーを強制維持しません。
- `/pbchat safe`：既存のEnter捕捉を停止してコントローラー操作へ戻す。

以前の試行でHUD切り替えを無効にした保存設定とは別の `hudChannelEnabled` を使い、今回の新機能は初期状態で有効です。
アドオン全体のオフ設定やEnter捕捉設定は維持します。

## チャット入力補助

コントローラーで通常どおりチャットを開いたときに、本体の文字入力画面を出す既存の監視処理を維持しています。
Enterで開きたい場合は `/pbchat enter` で捕捉を有効にします。
設定 → アドオン → PB’s ChatAssistantから、入力画面を開くまでの待ち時間を調整できます。

## 導入

LibHarvensAddonSettings（20106以上）が必要です。
ZIP内のPBsChatAssistantフォルダを使い、別のPBsHUDChannelProbeは無効にしてください。
元の配置ソースは `PBsChatAssistant-1.13.1-source-backup.zip` に保存しました。

著者：PinkBanther

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates.
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc.
in the United States and/or other countries. All rights reserved.
