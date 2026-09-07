local strings = {
	SI_PBSNPC_EXPLANATION = "頭上の名前はゲーム本体が描画しているため、称号・キャラクター名・<ギルド名>の並び順はアドオンからは変更できません。変更できるのはフォント（大きさ・書体・縁取り）です。",

	SI_PBSNPC_ENABLED = "ネームタグのフォントを変更",
	SI_PBSNPC_ENABLED_TOOLTIP = "キャラクターの頭上に出る名前に、以下のフォント設定を適用します。オフにするとゲーム本来のフォントに戻ります。",

	SI_PBSNPC_SIZE = "文字の大きさ",
	SI_PBSNPC_SIZE_TOOLTIP = "キャラクターの頭上に出る文字の大きさです。",

	SI_PBSNPC_FACE = "書体",
	SI_PBSNPC_FACE_TOOLTIP = "ゲームが持っている書体から選びます。まだ読み込まれていない書体に変えると、フォント構築のためUIの再読み込みが発生します（ゲーム側の仕様で回避できません）。文字の大きさと縁取りでは発生しません。「デフォルト」はゲームが選んだ書体のままで一番安全です。選択肢はUIが既に読み込んでいる書体のみです（それ以外は設定時にクライアントが構築する必要があり、コンソールではアドオン共有メモリに計上されて落ちるため、石版・手書き・アンティーク・チャットは選択肢から外してあります）。日本語版では一部が同じフォントに解決されます（UI標準／UI太字／コンソール細字＝同じゴシック）。コンソール標準・太字は英数字だけが専用書体になり、日本語部分はゴシックになります。",
	SI_PBSNPC_FACE_DEFAULT = "デフォルト",
	SI_PBSNPC_FACE_GAMEPAD_MEDIUM = "コンソール（標準）",
	SI_PBSNPC_FACE_GAMEPAD_BOLD = "コンソール（太字）",
	SI_PBSNPC_FACE_GAMEPAD_LIGHT = "コンソール（細字）",
	SI_PBSNPC_FACE_MEDIUM = "UI（標準）",
	SI_PBSNPC_FACE_BOLD = "UI（太字）",

	SI_PBSNPC_STYLE = "縁取り",
	SI_PBSNPC_STYLE_TOOLTIP = "背景から文字を浮き立たせる方法です。明るい場所では縁を太くすると読みやすくなります。【注意】縁取り系を選ぶとクライアントが縁取り用の字形を生成します。ゲーム本体のソースによると日本語フォントではこれに約100MBかかり、コンソールのアドオン共有メモリ（100MB）と同規模です。動作が不安定になる場合は「デフォルト」のままにしてください。",
	SI_PBSNPC_STYLE_DEFAULT = "デフォルト",
	SI_PBSNPC_STYLE_NORMAL = "なし",
	SI_PBSNPC_STYLE_SHADOW = "影",
	SI_PBSNPC_STYLE_SOFT_SHADOW_THIN = "やわらかい影（細）",
	SI_PBSNPC_STYLE_SOFT_SHADOW_THICK = "やわらかい影（太）",
	SI_PBSNPC_STYLE_OUTLINE = "縁取り",
	SI_PBSNPC_STYLE_OUTLINE_THICK = "縁取り（太）",
	SI_PBSNPC_STYLE_OUTLINE_SHADOW = "縁取り＋影",

	SI_PBSNPC_REAPPLY_FACE = "ロード後も書体を維持する",
	SI_PBSNPC_REAPPLY_FACE_TOOLTIP = "クライアントはロード画面のたびにネームタグのフォントを破棄するため、毎回書き直す必要があります。サイズの書き戻しは無料ですが、書体と縁取りの書き戻しはクライアントにフォント構築をさせ、コンソールではそれがアドオン共有の100MBメモリに計上されます。数回のゾーン移動でアドオンが落ちることを実測済みです。オフ：書体と縁取りは次のロード画面まで有効で、以降は文字サイズのみ維持されます。オン：書体も維持しますが、上記のリスクを負います。",
	SI_PBSNPC_RESET = "初期設定に戻す",
	SI_PBSNPC_RESET_TOOLTIP = "上のすべての設定を初期値に戻します。",
	SI_PBSNPC_RESET_BUTTON = "戻す",

	SI_PBSNPC_GAME_SETTINGS_HINT = "称号行と<ギルド名>行を表示するかどうかはゲーム本体の設定です（設定 > ネームプレート の「称号を表示」「ギルドを表示」）。アドオンからは変更できないため、そちらで設定してください。",
}

for stringId, stringValue in pairs(strings) do
	SafeAddString(_G[stringId], stringValue, 2)
end
