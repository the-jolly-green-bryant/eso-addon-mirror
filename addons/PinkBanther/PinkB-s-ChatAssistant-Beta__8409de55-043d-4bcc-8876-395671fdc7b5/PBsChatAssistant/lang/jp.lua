local strings = {
	SI_PBSCHATASSISTANT_CHANNEL_LABEL = "投稿先: %s",
	SI_PBSCHATASSISTANT_OFFICER_SUFFIX = "（オフィサー）",
	SI_PBSCHATASSISTANT_HUDCHANNEL = "L2＋L3で投稿先を切り替える",
	SI_PBSCHATASSISTANT_HUDCHANNEL_TOOLTIP = "HUDでL2を押したままL3を押すと、投稿先チャンネルを順に切り替えます。L2は読み取るだけで割り当てを変えず、L3もL2を押している間だけ置き換えます。",
	SI_PBSCHATASSISTANT_DEFAULT_CHANNEL = "ログイン時の投稿先",
	SI_PBSCHATASSISTANT_DEFAULT_CHANNEL_TOOLTIP = "セッション開始時の投稿先チャンネルです。ワールドに入った直後に一度だけ適用し、以降は切り替えても戻しません。現在使用できないチャンネルは適用しません。",
	SI_PBSCHATASSISTANT_DEFAULT_CHANNEL_NONE = "変更しない",
	SI_BINDING_NAME_PBSCHATASSISTANT_START_CHAT = "チャットを開く",
	SI_BINDING_NAME_PBSCHATASSISTANT_CHANNEL_NEXT = "次のチャンネル",
	SI_BINDING_NAME_PBSCHATASSISTANT_CHANNEL_PREV = "前のチャンネル",

	SI_PBSCHATASSISTANT_DELAY = "開くまでの待ち時間",
	SI_PBSCHATASSISTANT_DELAY_TOOLTIP = "本体の文字入力画面は、チャット欄が新たにフォーカスを得たときにのみ表示されます。そのため即座にではなく、少し待ってから開きます。チャット欄は開くのに入力画面が出ない場合、この値が短すぎます。",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
