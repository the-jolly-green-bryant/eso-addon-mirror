local strings = {
	SI_PBSCHATASSISTANT_CHANNEL_LABEL = "投稿先: %s",
	SI_PBSCHATASSISTANT_OFFICER_SUFFIX = "（オフィサー）",
	SI_PBSCHATASSISTANT_HUDCHANNEL = "L2＋十字キー右で投稿先を切り替える",
	SI_PBSCHATASSISTANT_HUDCHANNEL_TOOLTIP = "HUDでL2を押したまま十字キー右を押すと、投稿先チャンネルを順に切り替えます。L2の防御は維持し、同時押し中は右のクエスト切り替えを抑制します。L2を少し先に押してください。",
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
