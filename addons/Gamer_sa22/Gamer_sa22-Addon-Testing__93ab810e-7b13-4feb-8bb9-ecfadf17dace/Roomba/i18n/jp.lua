--[[
Author: Ayantir
Filename: ja.lua
Version: 7
]]--

local strings = {
    ROOMBA_GBANK            = "ギルド銀行でRoombaを有効にする",
    ROOMBA_GBANK_TOOLTIP    = "このオプションを有効にすると、ギルド銀行でRoombaが有効になります。",
	
    ROOMBA_LITEMODE         = "ライトモードを有効にする",
    ROOMBA_LITEMODE_TOOLTIP    = "このオプションを有効にすると、ギルド銀行に預けられたアイテムをRoombaが自動的に再スタックします。",

    ROOMBA_POSITION         = "ボタンの位置",
    ROOMBA_POSITION_TOOLTIP = "再スタックボタンの水平方向の位置を設定します。",

    ROOMBA_POSITION_CHOICE1 = "左",
    ROOMBA_POSITION_CHOICE2 = "中央",
    ROOMBA_POSITION_CHOICE3 = "右"
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(stringId, stringValue, 1)
end