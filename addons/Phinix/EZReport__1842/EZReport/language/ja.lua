local EZReport = _G['EZReport']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Labels
L.EZReport_GOpts				= "グローバルオプション"
L.EZReport_TIcon				= "ターゲット報告アイコンを表示"
L.EZReport_DTime				= "目標報告時間を表示"
L.EZReport_RCooldown			= "クールダウンの報告"
L.EZReport_RCooldownM			= "EZReportはすでに本日報告されています：Reporting Cooldownが有効になっています。"
L.EZReport_OutputChat			= "チャットメッセージを表示する"
L.EZReport_12HourFormat			= "12時間形式"
L.EZReport_IncPrev				= "以前のレポートデータを含める"
L.EZReport_DCategory			= "デフォルトのカテゴリ"
L.EZReport_DReason				= "デフォルトの理由"
L.EZReport_Reset				= "レポート履歴をリセット"
L.EZReport_Clear				= "クリア"

-- Target Reported Colors
L.EZReport_RColorS				= "目標報告色"
L.EZReport_RColor1				= "一般的な色"
L.EZReport_RColor2				= "悪い名前の色"
L.EZReport_RColor3				= "有毒な色"
L.EZReport_RColor4				= "浮気色"
L.EZReport_RColor5				= "代替報告色"

-- Addon Setting Tooltips
L.EZReport_TIconT				= "以前に報告したターゲットを示すアイコンを表示します。レポートウィンドウでカテゴリを選択したときに表示されるアイコンと一致します。"
L.EZReport_DTimeT				= "ターゲットが最後に報告された時刻をターゲット報告アイコンの隣に表示します。現在のキャラクターが一度も報告されていない場合は、自分のアカウントのいずれかのキャラクターが報告された最新の時間を示します。"
L.EZReport_RCooldownT			= "有効にすると、今日すでにターゲットを報告している場合にホットキーの報告を防止します。大量のボットを報告するときに役立ちます。キーバインドをスパムする可能性があり、報告システムは、まだ報告していないターゲットがある場合にのみアクティブになります。"
L.EZReport_OutputChatT			= "チャットのさまざまなアドオン機能に関連する有益なメッセージを表示します。"
L.EZReport_12HourFormatT		= "有効にすると、生成されたタイムスタンプは12時間形式（時間プラス午前または午後）を使用します。これをオフにすると、「軍事時間」の24時間形式が表示されます。"
L.EZReport_IncPrevT				= "この文字の以前のレポートに関する日付、時刻、および名前のデータ、またはレポートを送信するときの既知の代替情報が含まれます。"
L.EZReport_DCategoryT			= "レポートウィンドウを開くときに自動的に選択するデフォルトのサブカテゴリを選択します。"
L.EZReport_DReasonT				= "選択した理由をレポート作成ウィンドウのカスタム詳細セクションに含めます。手動（デフォルト）オプションでは、手動で入力するためにこれを空白のままにします。"
L.EZReport_ResetT				= "以前に報告されたキャラクターとアカウントのデータベース全体をクリアします。"
L.EZReport_ResetM				= "EZReportデータベースがリセットされました。"

-- Category List
L.EZReport_CatList1				= "悪い名前"
L.EZReport_CatList2				= "嫌がらせ"
L.EZReport_CatList3				= "不正行為"
L.EZReport_CatList4				= "その他の"
L.EZReport_CatList5				= "なし（デフォルト）"

-- Reason List
L.EZReport_ReasonList1			= "ボッティング"
L.EZReport_ReasonList2			= "悪用する"
L.EZReport_ReasonList3			= "嫌がらせ"
L.EZReport_ReasonList4			= "手動（デフォルト）"

-- Chat List
L.EZReport_CReason1				= "一般レポート"
L.EZReport_CReason2				= "悪い名前"
L.EZReport_CReason3				= "毒性行動"
L.EZReport_CReason4				= "不正行為"

-- Chat Strings
L.EZReport_RepT					= "報告："
L.EZReport_RepC					= "報告されたキャラクター："
L.EZReport_Unkn					= "不明なアカウント"
L.EZReport_Now					= "今："
L.EZReport_Char					= "キャラクター："
L.EZReport_For					= "にとって："
L.EZReport_NoMatch				= "一致するものが見つかりませんでした。"

-- Info Panel
L.EZReport_RAcct				= "アカウントを報告： "
L.EZReport_RAlts				= "以前に報告されたAlts： "

-- General Strings
L.EZReport_RLast				= "最後のプレイヤーターゲットを報告"
L.EZReport_RHistory				= "ターゲットレポートの履歴"
L.EZReport_ROpen				= "メインウィンドウを開く"
L.EZReport_Reason				= "理由（オプション）："
L.EZReport_CName				= "キャラクター名："
L.EZReport_AName				= "アカウント名："
L.EZReport_MLoc					= "地図："
L.EZReport_Coords				= "コーディス："
L.EZReport_Time					= "日付時刻："
L.EZReport_CButton				= "クリア"
L.EZReport_Today				= "今日"
L.EZReport_Updated				= "EZReportデータベースが更新されました。"
L.EZReport_AccUnavail			= "アカウントが利用できません"
L.EZReport_LocUnavail			= "利用できない場所"
L.EZReport_Wayshrine			= "Wayshrine"
L.EZReport_Accounts				= "アカウント別レポート"
L.EZReport_Characters			= "キャラクター別レポート"
L.EZReport_Locations			= "場所別レポート"
L.EZReport_Generated			= "生成：PhinixによるEZReport"
L.EZReport_Previous				= "以前に報告された："
L.EZReport_Confirm				= "削除を確認"
L.EZReport_Cancel				= "キャンセル"
L.EZReport_Delete				= "削除する"

-- Tooltip strings
L.EZReport_TTShow				= "クリックするとレポートの概要が表示されます。"
L.EZReport_TTClick				= "結果フィールドをクリックしてを押します。"
L.EZReport_TTSelect1			= "Ctrl + A"
L.EZReport_TTSelect2			= " すべて選択します。"
L.EZReport_TTCopy1				= "Ctrl + C"
L.EZReport_TTCopy2				= " コピーする。"
L.EZReport_TTPaste1				= "Ctrl + V"
L.EZReport_TTPaste2				= " 他の場所に貼り付ける。"
L.EZReport_TTAccounts			= "アカウントの表示に切り替えます。"
L.EZReport_TTCharacters			= "表示文字に切り替えます。"
L.EZReport_TTEMode				= "データベース編集モードに切り替えます。"
L.EZReport_TTRMode				= "テキストレポートモードに切り替えます。"
L.EZReport_TTCEntry1			= "左クリック"
L.EZReport_TTCEntry2			= " 文字入力を表示します。"
L.EZReport_TTAEntry1			= "Shift+左クリック"
L.EZReport_TTAEntry2			= " アカウントエントリを表示します。"
L.EZReport_TTDEntry1			= "右クリック"
L.EZReport_TTDEntry2			= " 選択したエントリを削除します。"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k, v in pairs(EZReport:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function EZReport:GetLanguage() -- set new language return
		return L
	end
end
