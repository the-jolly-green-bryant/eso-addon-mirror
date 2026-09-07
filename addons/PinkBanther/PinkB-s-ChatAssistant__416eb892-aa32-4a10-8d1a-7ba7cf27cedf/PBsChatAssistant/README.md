# PB’s ChatAssistant 1.9.0

コンソール版ESOで、**キーボードのEnter**からチャット入力欄を開き、同時に本体の文字入力画面
（日本語入力）を表示します。コントローラーに持ち替える必要がありません。

## 使い方

1. PBsChatAssistantとLibHarvensAddonSettings（20106以上）を有効にします。
2. コントローラーで普通にチャットを開いても、文字入力画面が自動で出ます。ここは常時有効です。
3. Enterで開きたい場合は `/pbchat enter` で有効化します。文字入力画面が出た時点で自動的に
   解除され、コントローラーのボタンが戻ります。

設定 → アドオン → PB’s ChatAssistant から、入力画面が開くまでの待ち時間を調整できます。
チャット欄が開くのに入力画面が出ない場合は、この値を大きくしてください。

## チャンネル切り替え

Enterの捕捉が有効な間、**チャット欄を閉じた状態で左右キー**を押すと投稿先チャンネルを
切り替えます。入力欄を開いている間はカーソル移動が優先されます。

ゲーム標準の方法も使えます。入力欄でメッセージの前に `/say` `/zone` `/party` `/guild1`
などを打つ方法で、こちらは何も有効化せずコントローラーにも影響しません。

## 1.9.0の変更

**L2＋L3によるHUDチャンネル切り替えを取り下げました。** HUD上でL2を覆ってしまい、
防御ができなくなるためです。`allowFallthrough="true"` とハンドラの `return false` では、
ゲーム本来のL2を下に残すことができませんでした。

実装は `HUDChannel.lua` に残していますが、マニフェストから読み込んでおらず、
必要なレイヤーの宣言も `Bindings.xml` から削除しているため動作しません。
手法自体は有効で、問題はボタンの選択だけです。経緯は [FINDINGS.md](FINDINGS.md) にあります。

## 開発者向け

コンソール版で計測した挙動、およびドキュメントと実クライアントの食い違いは
[FINDINGS.md](FINDINGS.md) にまとめてあります。

## 更新・配布

バージョンは **1.9.0** です。ZIP内のPBsChatAssistantフォルダを使用します。
既存の保存設定を維持します。

著者：PinkBanther

This Add-On is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates.
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc.
in the United States and/or other countries. All rights reserved.
