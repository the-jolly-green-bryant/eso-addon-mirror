local RPOTracker = _G['RPOTracker']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Panel Strings
--L.RPOTRACK_Title		= "|cFF9900Pale Order|r |cFEE854Tracker|r"
L.RPOTRACK_SOpts		= "セルフトラッカーオプション"
L.RPOTRACK_GOpts		= "グループトラッカーオプション"

-- Self Tracker Options
L.RPOTRACK_Show			= "トラッカーを表示します"
L.RPOTRACK_ShowD		= "プレーヤーのRotPO装備のステータストラッカーを表示します。"
L.RPOTRACK_Lock			= "ロックトラッカー"
L.RPOTRACK_LockD		= "ロックを解除すると、新しいポジションを保存するためにトラッカーを移動できます。"
L.RPOTRACK_ShowG		= "グループ化されたショー"
L.RPOTRACK_ShowGD		= "グループ化されたときに、プレーヤーのRotPO装備のステータストラッカーを表示します。"
L.RPOTRACK_ShowBG		= "背景を表示します"
L.RPOTRACK_ShowBGD		= "RotPOトラッカーアイコンの背後に黒い背景を表示します。"
L.RPOTRACK_Label		= "レーベルを表示します"
L.RPOTRACK_LabelD		= "存在するグループメンバーの数に基づいてRotPOの強度を示すテキストラベルを表示します。"
L.RPOTRACK_TScale		= "トラッカースケール"
L.RPOTRACK_TScaleD		= "トラッカーアイコンの寸法をスケーリングします。"
L.RPOTRACK_LScale		= "ラベルスケール"
L.RPOTRACK_LScaleD		= "テキストラベルの寸法をスケーリングします。"
L.RPOTRACK_LabelX		= "ラベル水平オフセット"
L.RPOTRACK_LabelXD		= "左から右にRotPOテキストラベルの位置を調整します。"
L.RPOTRACK_LabelY		= "ラベル垂直オフセット"
L.RPOTRACK_LabelYD		= "RotPOテキストラベルの位置を上下に調整します。"

-- Group Tracker Options
L.RPOTRACK_SGF			= "グループフレームを監視します"
L.RPOTRACK_SGFD			= "グループユニットフレームのRotPOアイコンを表示します。"
L.RPOTRACK_SRF			= "RAIDフレームを監視します"
L.RPOTRACK_SRFD			= "RAIDユニットフレームにRotPOアイコンを表示します。"
L.RPOTRACK_GIS			= "グループアイコンサイズ"
L.RPOTRACK_GISD			= "標準グループフレームに表示されたときのRotPOアイコンのサイズ。"
L.RPOTRACK_RIS			= "RAIDアイコンサイズ"
L.RPOTRACK_RISD			= "標準のRAIDフレームに表示されたときのRotPOアイコンのサイズ。"
L.RPOTRACK_GXIO			= "グループ水平アイコンオフセット"
L.RPOTRACK_GXIOD		= "グループフレームRotPOアイコンの位置を左から右に調整します。"
L.RPOTRACK_GYIO			= "グループ垂直アイコンオフセット"
L.RPOTRACK_GYIOD		= "グループフレームRotPOアイコンの位置を上下に調整します。"
L.RPOTRACK_RXIO			= "RAID水平アイコンオフセット"
L.RPOTRACK_RXIOD		= "RAIDフレームRotPOアイコンの位置を左から右に調整します。"
L.RPOTRACK_RYIO			= "RAID垂直アイコンオフセット"
L.RPOTRACK_RYIOD		= "RAIDフレームRotPOアイコンの位置を上下に調整します。"

-- 3rd Party Frame Options
L.RPOTRACK_Mode1		= "デフォルト"
--L.RPOTRACK_Mode2		= "Foundry Tactical Combat"
--L.RPOTRACK_Mode3		= "Lui Extended"
--L.RPOTRACK_Mode4		= "Bandits User Interface"
--L.RPOTRACK_Mode5		= "AUI"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k, v in pairs(RPOTracker:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function RPOTracker:GetLanguage() -- set new language return
		return L
	end
end
