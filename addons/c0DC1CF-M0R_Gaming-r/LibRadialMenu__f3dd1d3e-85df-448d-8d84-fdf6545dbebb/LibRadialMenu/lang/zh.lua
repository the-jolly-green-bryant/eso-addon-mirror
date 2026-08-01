local LIBRADIAL_WHEEL = HOTBAR_CATEGORY_MAX_VALUE + 100
local libradialwheelcategory = string.format("SI_HOTBARCATEGORY%d",LIBRADIAL_WHEEL)


-- do special stuff for zh
LibRadialMenu = LibRadialMenu or {}


function LibRadialMenu.loadSimpleCN()
	SafeAddString(_G[libradialwheelcategory], "插件菜单", 1)

	SafeAddString(SI_LIBRADIALMENU_ASSIGN_TITLE, "请配置槽位 %d。", 1)
	SafeAddString(SI_LIBRADIALMENU_ASSIGN_SLOT, "槽位 %d： ", 1)
	SafeAddString(SI_LIBRADIALMENU_ASSIGN_NOTHING, "该槽位目前暂无内容！", 1)
	SafeAddString(SI_LIBRADIALMENU_NUM_SLOTS, "槽位数量", 1)
	SafeAddString(SI_LIBRADIALMENU_NUM_SLOTS_TOOLTIP, "设置快捷轮盘中的槽位总数。", 1)
	SafeAddString(SI_LIBRADIALMENU_REFRESH_MENU, "刷新设置界面", 1)
	SafeAddString(SI_LIBRADIALMENU_REFRESH_MENU_TOOLTIP, "更改快捷轮盘槽位数量后，请点击此按钮刷新下方设定按钮。", 1)
	SafeAddString(SI_LIBRADIALMENU_ASSIGN_SLOTS_HEADER, "槽位配置", 1)
	SafeAddString(SI_LIBRADIALMENU_OPEN_SETTINGS, "打开设置", 1)
	SafeAddString(SI_LIBRADIALMENU_OPEN_SETTINGS_TOOLTIP, "打开快捷轮盘插件设置面板", 1)

	SafeAddString(SI_LIBRADIALMENU_TRANSLATEDBY, "本地化：einjw", 1) -- translated by
end


function LibRadialMenu.loadTradCN()
	SafeAddString(_G[libradialwheelcategory], "插件選單", 1)

	SafeAddString(SI_LIBRADIALMENU_ASSIGN_TITLE, "設定第 %d 個欄位的功能。", 1)
	SafeAddString(SI_LIBRADIALMENU_ASSIGN_SLOT, "欄位 %d： ", 1)
	SafeAddString(SI_LIBRADIALMENU_ASSIGN_NOTHING, "此欄位目前沒有內容！", 1)
	SafeAddString(SI_LIBRADIALMENU_NUM_SLOTS, "欄位數量", 1)
	SafeAddString(SI_LIBRADIALMENU_NUM_SLOTS_TOOLTIP, "設定快速輪盤中的欄位總數。", 1)
	SafeAddString(SI_LIBRADIALMENU_REFRESH_MENU, "重新整理設定介面", 1)
	SafeAddString(SI_LIBRADIALMENU_REFRESH_MENU_TOOLTIP, "變更快速輪盤的欄位數量後，請點選此按鈕以更新下方的設定按鈕。", 1)
	SafeAddString(SI_LIBRADIALMENU_ASSIGN_SLOTS_HEADER, "管理欄位", 1)
	SafeAddString(SI_LIBRADIALMENU_OPEN_SETTINGS, "開啟設定", 1)
	SafeAddString(SI_LIBRADIALMENU_OPEN_SETTINGS_TOOLTIP, "開啟快速輪盤的設定頁面", 1)

	SafeAddString(SI_LIBRADIALMENU_TRANSLATEDBY, "本地化翻譯：einjw", 1) -- translated by
end


ZO_CreateStringId("SI_LIBRADIALMENU_SIMPLECN", "簡體中文")
ZO_CreateStringId("SI_LIBRADIALMENU_TRADCN", "繁體中文")


LibRadialMenu.isCN = true

LibRadialMenu.loadSimpleCN()