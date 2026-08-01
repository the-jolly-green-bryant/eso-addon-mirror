local RC = _G['RollCallAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

--Strings for /toss.
L.RollCallToss1			= "頭."
L.RollCallToss2			= "尾."
L.RollCallToss3			= " はドレイクを裏返して着陸する "
L.RollCallTossQ1		= "[トス] つかいます： /toss オプション"
L.RollCallTossQ2		= "[トス] 有効な選択肢は2（両面コインを意味します）です."
L.RollCallTossQ3		= "[トス] デフォルト（入力された値がない、または無効な場合）は2です."

--Strings for /roll.
L.RollCallRoll1			= "[ロール] の "
L.RollCallRoll2			= " のうち "
L.RollCallRoll3			= " によって： "
L.RollCallRoll4			= " が投げます "
L.RollCallRoll5			= " は木製のサイコロを投げてaを振ります "
L.RollCallRoll6			= " 木製のサイコロとロール "
L.RollCallRollQ1		= "[ロール] つかいます： /roll オプション"
L.RollCallRollQ2		= "[ロール] 有効なオプションは6、10、12、18、24、50、100、および1000です。"
L.RollCallRollQ3		= "[ロール] デフォルト（入力された値がない/無効な場合）は100です。オプションを参照してください。"
L.RollCallRollQ4		= "[ロール] '特別な'値は6、12、18、および24です。"

--Settings panel strings.
L.RollCallCharOpt		= "文字オプション"
L.RollCallRollO			= "デフォルトロールオプション"
L.RollCallRollOD		= "数字オプションを指定せずに/ rollを単独で入力するときのデフォルトの動作を選択します。 デフォルトは100の標準ロールアウトです。オプションを参照してください。"
L.RollCallOpt1			= "ダイスを1ロールする。"
L.RollCallOpt2			= "サイコロ2個を振る。"
L.RollCallOpt3			= "3個のサイコロを振る"
L.RollCallOpt4			= "4個のサイコロを振る"
L.RollCallOpt5			= "ロール / 10"
L.RollCallOpt6			= "ロール / 20"
L.RollCallOpt7			= "ロール / 50"
L.RollCallOpt8			= "ロール / 100"
L.RollCallOpt9			= "ロール / 1000"
L.RollCallDC			= "戦闘中に無効にする"
L.RollCallDCD			= "あなたが戦闘中の場合、RollCallがpingに応答しないようにします。 DPS共有アドオンが原因でマップのpingが頻繁に行われるグループの戦闘中に、不要なチャットスパムを回避します。"
L.RollCallCM			= "チャットモードを有効にする"
L.RollCallCMD			= "グループではなくアクティブなチャットへの出力（グラフィックなし）の送信を有効にします。 注：アドオンを介したチャットスパムを防ぐためのAPIの制限により、投稿するには手動でEnterキーを押す必要があります。"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(RC:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function RC:GetLanguage() -- set new language return
		return L
	end
end
