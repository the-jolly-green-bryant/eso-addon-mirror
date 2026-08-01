local DTAddon = _G['DTAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- Japanese (Needs human translation!)
--------------------------------------------------------------------------------------------------------------------

-- General Strings
--	L.DTAddon_Title			= "ダンジョントラッカー"
	L.DTAddon_CNorm			= "正常終了： "
	L.DTAddon_CVet			= "完成したベテラン： "
	L.DTAddon_CNormI		= "完了標準I： "
	L.DTAddon_CNormII		= "正常終了II： "
	L.DTAddon_CVetI			= "完成ベテランI： "
	L.DTAddon_CVetII		= "完成ベテランII： "
L.DTAddon_CGChal		= "グループチャレンジスキルポイント"
	L.DTAddon_CDBoss		= "すべての上司が敗北： "
	L.DTAddon_Unlock		= "レベルでロック解除： "
L.DTAddon_True			= "真実"
L.DTAddon_False			= "偽"
L.DTAddon_None			= "無し"
L.DTAddon_MQOPT1		= "すべての文字"
L.DTAddon_MQOPT2		= "現在の文字"
L.DTAddon_MQOPT3		= "表示しない"
	L.DTAddon_CTOPT1		= "両方を表示"
	L.DTAddon_CTOPT2		= "完了した"
	L.DTAddon_CTOPT3		= "不完全なだけ"
L.DTAddon_QComp			= "クエスト完了： "
L.DTAddon_QCompI		= "クエスト1完了： "
L.DTAddon_QCompII		= "クエスト2完了： "
L.DTAddon_AWide			= " (アカウントワイド)"
L.DTAddon_QMQ			= "不完全なクエストを選択します"
L.DTAddon_QMQTip		= "現在のキャラクターがまだスキルポイントクエストを完了していないダンジョンを選択します。"
L.DTAddon_QMQVTip		= "チェックされた場合、ダンジョンのベテランバージョンが選択され、スキルポイントクエストを完了します（推奨されません）。\n\n|cffffffノート|r: スキルポイントクエストは、通常のモードとベテランモードで同じであり、1回しか完了できません。"

-- Account Options
	L.DTAddon_SHMComp		= "ハードモード完了を表示"
L.DTAddon_SHMCompD		= "選択したベテランダンジョンまたはトライアルハードモードの達成を完了した場合、アイコンを表示します。"
	L.DTAddon_STTComp		= "トライアルの完了を表示する"
L.DTAddon_STTCompD		= "選択したベテランダンジョンまたはトライアル時刻の達成を完了した場合、アイコンを表示します。"
	L.DTAddon_SNDComp		= "死の完了を表示しない"
L.DTAddon_SNDCompD		= "選択したベテランダンジョンまたは試行の死の達成を完了した場合は、アイコンを表示してください。"
	L.DTAddon_SGFComp		= "グループダンジョン派閥完成"
L.DTAddon_SGFCompD		= "強調表示されているダンジョンの派閥におけるすべてのグループダンジョンを完了することに向けた現在の進歩を示します。"
	L.DTAddon_SLFGt			= "LFG：ダンジョンの完了を表示します"
L.DTAddon_SLFGtD		= "Group Finderの達成情報を表示します。"
	L.DTAddon_SLFGd			= "LFG：ダンジョンの説明を表示します"
	L.DTAddon_SLFGdD		= "ダンジョンのゲームの説明をLFGのツールチップに表示します。 これは通常隠されています。"
	L.DTAddon_SNComp		= "地図：通常のグループダンジョンの完了"
L.DTAddon_SNCompD		= "通常モードでダンジョンまたは試用を完了したかどうかを示します。"
	L.DTAddon_SVComp		= "地図：ベテラングループダンジョンの完成"
L.DTAddon_SVCompD		= "あなたがベテランモードでダンジョンまたは試用を完了したかどうかを示します。"
L.DTAddon_SGCCompM		= "地図："
L.DTAddon_SGCComp		= "公共ダンジョンスキルポイント"
L.DTAddon_SGCCompD		= "現在の文字がツールチップでパブリックダンジョンスキルポイントグループのチャレンジを完了したかどうかを表示します。"
L.DTAddon_SDBComp		= "地図：パブリックダンジョンボス完成"
L.DTAddon_SDBCompD		= "あなたがツールチップですべてのパブリックダンジョンのボスを破ったかどうかを示します。"
L.DTAddon_SDFComp		= "地図：パブリックダンジョン派閥完了"
L.DTAddon_SDFCompD		= "派閥の達成におけるすべての公衆ダンジョンを完成させるための現在の進歩を示す。"
L.DTAddon_CNColor		= "完成した色："
L.DTAddon_CNColorD		= "完了ステータスの色、またはダンジョンスキルポイントクエストを完了したキャラクターの名前を選択します。"
L.DTAddon_NNColor		= "不完全な色："
L.DTAddon_NNColorD		= "完了ステータスの色、またはダンジョンスキルポイントクエストを完了していないキャラクターの名前を選択します。"
L.DTAddon_QCompHead		= "ダンジョンクエスト完成"
L.DTAddon_QCompS		= "ダンジョンクエストを表示する"
L.DTAddon_QCompSD		= "ダンジョンクエストの完了状況を表示するかどうかを選択します。 すべてのキャラクターのステータスを表示するか、現在のみを表示するかを選択します。\n\n注：すべてのキャラクターのリストに表示するには、各キャラクターに少なくとも1回ログインする必要があります。"
L.DTAddon_CTDROPDOWN	= "完了テキストの形式"
L.DTAddon_CTDROPDOWND	= "すべてのキャラクターを表示する場合は、ダンジョンスキルポイントクエストを完了した人だけを表示するか、完了していない人だけを表示するか、または両方を表示するかを選択します（デフォルト）。"
L.DTAddon_ALPHAN		= "アルファベット順の名前リスト"
L.DTAddon_ALPHAND		= "有効にすると、ツールチップの完了リストがアルファベット順になります。 それ以外の場合、リストの順序はキャラクターの作成順序と一致します。"
L.DTAddon_CHighlight	= "現在のキャラクターをハイライト"
L.DTAddon_CHighlightD	= "アスタリスク（*）を表示し、現在の文字実績色を使用して、現在のログインしているキャラクターのDungeonクエスト完了をハイライト表示します。"
L.DTAddon_HColor		= "現在の文字の色"
L.DTAddon_HColorD		= "ダンジョンクエスト完了の名前のリスト内の現在の文字を強調表示するための色を変更します。"

-- Character Tracking
L.DTAddon_CharTracking	= "キャラクタートラッキング"
L.DTAddon_TrackChar		= "現在の文字を追跡"
L.DTAddon_TrackCharD	= L.DTAddon_QCompS.." を "..L.DTAddon_MQOPT1.." に設定すると、現在ログインしているキャラクターがクエスト完了の概要に含まれます。ログイン中に再度有効にすると、再度追加されます。"
L.DTAddon_TrackWarn		= "警告: UI が自動的に再読み込みされます。"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(DTAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DTAddon:GetLanguage() -- set new language return
		return L
	end
end
