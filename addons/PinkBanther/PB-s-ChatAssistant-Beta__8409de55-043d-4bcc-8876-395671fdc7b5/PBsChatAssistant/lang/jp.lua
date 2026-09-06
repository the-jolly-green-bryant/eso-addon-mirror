local strings = {
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
