local strings = {
	DUR_HEADING1 = "装備の項目",
	DUR_HEADING2 = "武器のた電荷",
	DUR_HEADING3 = "その他",
	DUR_SHOW_DURABILITY = "耐久性のパーセンテージを表示",
	DUR_SHOW_DURABILITY_TT = "アイテムの右下隅に耐久性のパーセンテージを表示",
	DUR_SHOW_ALWAYS = "常にパーセンテージを示し",
	DUR_SHOW_ALWAYS_TT = "どんなに耐久性ある耐久性のパーセンテージを示し",
	DUR_SHOW_CHARGE_ALWAYS_TT = "どんなに料金がでであるかを費用の割合を表示",
	DUR_SHOW_HIGHLIGHT = "ショーハイライト",
	DUR_SHOW_HIGHLIGHT_TT = "アイテムは耐久性のしきい値に達したときに、カラーハイライトを表示",
	DUR_COLOUR = "ハイライトカラー",
	DUR_COLOUR_TT = "耐久性警告ハイライトの色",
	DUR_THRESHOLD = "しきい値",
	DUR_THRESHOLD_TT = "パーセンテージ数はあなた表示されるように警告耐久性をしたい",
	DUR_REPAIR = "ベンダー訪問時にプロンプトを修復する",
	DUR_REPAIR_PER = "修理プロンプト率",
	DUR_REPAIR_PER_TT = "最悪のギアがこのレベル以下にある場合にのみ修理を促",
}

if GetString(DUR_HEADING1):len() == 0 then
	for key,value in pairs(strings) do
		SafeAddVersion(key, 1)
		ZO_CreateStringId(key, value)
	end
end