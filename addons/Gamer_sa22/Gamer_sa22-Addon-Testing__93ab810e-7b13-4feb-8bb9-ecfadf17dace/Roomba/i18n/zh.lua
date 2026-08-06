--[[
Author: Ayantir
Filename: zh.lua
Version: 7
]]-- Chinese Translated By AK-ESO @shijian452

local strings = {
    ROOMBA_GBANK            = "在公会银行启用Roomba",
    ROOMBA_GBANK_TOOLTIP    = "如果启用，Roomba将在公会银行激活",
	
    ROOMBA_LITEMODE            = "启用自动模式",
    ROOMBA_LITEMODE_TOOLTIP    = "如果启用，Roomba将自动整理您发送到帮会银行的物品",

    ROOMBA_POSITION         = "水平位置",
    ROOMBA_POSITION_TOOLTIP = "设置Roomba按钮的水平位置",

    ROOMBA_POSITION_CHOICE1 = "左侧",
    ROOMBA_POSITION_CHOICE2 = "中间",
    ROOMBA_POSITION_CHOICE3 = "右侧",
    
    ROOMBA_RESCAN_BANK      = "整理工会银行"
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end