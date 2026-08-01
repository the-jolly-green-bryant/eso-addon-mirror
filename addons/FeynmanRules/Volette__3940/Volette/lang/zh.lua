local localizationStrings = {
    VOLETTE_YES = "是",
    VOLETTE_NO = "否",

    VOLETTE_REQUIRES_RELOADUI = "需要重新加载用户界面。",
    VOLETTE_RELOADUI_DIALOG_TITLE = "重新加载界面",
    VOLETTE_RELOADUI_DIALOG_DESCRIPTION = "更改将在下次重新加载用户界面时生效。现在要重新加载吗？",

    VOLETTE_CONFIRM_DIALOG_TITLE = "确认",
    VOLETTE_CONFIRM_DIALOG_DESCRIPTION = "您确认此操作吗？",

    VOLETTE_HQ_OWNER_CRAFT = "制作HQ的所有者",
    VOLETTE_HQ_OWNER_PARSE = "训练HQ的所有者",
    VOLETTE_HQ_OWNER_MISSING = "您必须在设置中选择总部的所有者。",

    VOLETTE_CONTACTS_ENABLE = "启用联系人菜单",
    VOLETTE_CONTACTS_ENABLE_TOOLTIP = "启用后，在好友列表旁将获得一个额外的联系人菜单",
    VOLETTE_CONTACTS_ADDED = "<<1>> 已添加到联系人。",
    VOLETTE_CONTACTS_REMOVED = "<<1>> 已从联系人中移除。",
    VOLETTE_CONTACTS_EXISTS = "<<1>> 已在联系人中。",
    VOLETTE_CONTACTS_WAS_INVITED = "<<1>> 已被邀请。",
    VOLETTE_CONTACTS_WHISPER_BUTTON_TOOLTIP = "私聊",
    VOLETTE_CONTACTS_INVITE_BUTTON_TOOLTIP = "邀请",
    VOLETTE_CONTACTS_REMOVE_BUTTON_TOOLTIP = "从列表中删除",
    VOLETTE_CONTACTS_PIN_BUTTON_TOOLTIP = "固定",
    VOLETTE_CONTACTS_UNPIN_BUTTON_TOOLTIP = "取消固定",

    VOLETTE_TRAVEL_WAYSHRINE_CHOICE = "选择一个靠近圣坛的房子",
    VOLETTE_TRAVEL_WAYSHRINE_CHOICE_TOOLTIP = "尝试使用命令 |cffcc00/v-wayshrine|r 时传送到这座房子的外面。如果没有拥有这座房子，将使用另一座。",
    VOLETTE_TRAVEL_AUTO = "自动",
    VOLETTE_TRAVEL_WAYSHRINE_RECOMMENDATION = "你必须拥有兼容的房屋之一。推荐使用\"<<1>>\"。",
    VOLETTE_TRAVEL_WAYSHRINE_PORTING = "传送到\"<<1>>\"之外。",
    VOLETTE_TRAVEL_SEARCHING_ANOTHER_WAYSHRINE = "你必须拥有\"<<1>>\"。尝试找到另一座房子...",

    VOLETTE_SAVINGS_SUBMENU_TITLE = "储蓄",
    VOLETTE_SAVINGS_SUBMENU_DESCRIPTION = "不要让你的财富闲置在小号上！当货币开始累积时，自动存入银行。",
    VOLETTE_SAVINGS_ENABLE = "|c66a3ff启用|r",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT = "最低金额",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT = "最高金额",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP = "你的角色背包中始终会保留至少该金额。",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP = "你的角色背包中不会保留超过该金额。",
    VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION = "为以下角色启用：",
    VOLETTE_SAVINGS_DEPOSIT = "存款: <<1>>",
    VOLETTE_SAVINGS_WITHDRAWAL = "取款: <<1>>",
    VOLETTE_SAVINGS_NOT_ENOUGH_CURRENCIES = "无法在银行中找到<<1>>。",

    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HOME = "传送到主要住宅",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_CRAFT = "传送到工艺总部",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_PARSE = "传送到训练总部",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_WAYSHRINE = "传送到路边神龛",

}


for stringId, stringValue in pairs(localizationStrings) do
    SafeAddString(_G[stringId], stringValue, 6)
end
