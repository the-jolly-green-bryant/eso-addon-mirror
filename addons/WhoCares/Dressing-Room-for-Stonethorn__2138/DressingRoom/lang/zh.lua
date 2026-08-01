-- translated by 海姆

ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE", "显示/隐藏窗口")
for i = 1, 24 do
  ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_SET_"..i, "使用配装 "..i)
end
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_UNDRESS", "解除所有装备")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_PREVIOUS", "上一页")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_NEXT", "下一页")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_CANCEL_PENDING_LOAD", "取消待定加载")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE_GROUP_ROLE", "切换设置组")

DressingRoom._msg = {
  weaponType = {
    [WEAPONTYPE_AXE] = "斧",
    [WEAPONTYPE_BOW] = "弓",
    [WEAPONTYPE_DAGGER] = "匕首",
    [WEAPONTYPE_FIRE_STAFF] = "火焰法杖",
    [WEAPONTYPE_FROST_STAFF] = "寒冰法杖",
    [WEAPONTYPE_HAMMER] = "锤",
    [WEAPONTYPE_HEALING_STAFF] = "治疗法杖",
    [WEAPONTYPE_LIGHTNING_STAFF] = "闪电法杖",
    [WEAPONTYPE_NONE] = "无",
    [WEAPONTYPE_RUNE] = "符文",
    [WEAPONTYPE_SHIELD] = "盾",
    [WEAPONTYPE_SWORD] = "剑",
    [WEAPONTYPE_TWO_HANDED_AXE] = "战斧",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "巨锤",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "巨剑",
  },
  
  loadingSet = "加载配装 %s...",
  skillBarSaved = "技能配置 %d 栏位 %d 已保存",
  skillBarLoaded = "技能配置 %d 栏位 %d 已读取",
  skillBarDeleted = "技能配置 %d 栏位 %d 已删除",
  gearSetSaved = "套装配置 %d 已保存",
  gearSetLoaded = "套装配置 %d 已读取",
  gearSetDeleted = "套装配置 %d 已删除",
  noGearSaved = "%d 没有对应套装配置",

  options = {
    reloadUIWarning = "需要重载界面",
    autoReloadUIWarning = "此选项会自动重载界面!",
    reloadUI = "重载界面",
    accountWideSettings = {
      name = "全局设置",
      tooltip = "在账号内使用同样的界面设置\n更改此项目不会更改当前的设置",
    },
    sectionBehaviour = "动作设置",
    autoRechargeWeapons = {
      name = "自动充能武器",
      tooltip = "当你的武器附魔耗尽时,自动使用灵魂宝石为其充能",
    },
    clearEmptyGear = {
      name = "清除空装备槽",
      tooltip = "加载装备槽位为空时,清除之前的装备",
    },
    clearEmptyPoisons = {
      name = "清除空毒药槽",
      tooltip = "当配装中不包含毒药, 清除之前的毒药",
    },
    clearEmptySkill = {
      name = "清除空技能槽",
      tooltip = "当用空槽装载技能集时，清除之前的技能",
    },
    ignoreAppearanceSlot = {
      name = "忽视外观槽",
      tooltip = "不装备或解除伪装或公会战袍",
    },
    enableOutfits = {
      name = "Save/load outfits",
      tooltip = "Save and load the active outfit with gear presets",
    },
    disableInCombat = {
      name = "战斗中禁用",
      tooltip = "战斗中禁止更换配置,且结束后也不更换",
    },
    sectionUI = "界面设置",
    showNotificationArea = {
      name = "显示通知",
      tooltip = "显示通知区域和当前加载的预置的名称",
    },
    lockNotificationArea = {
      name = "锁定通知区域",
      tooltip = "锁定通知区域的界面位置",
    },
    activeBarOnly = {
      name = "技能设置按钮仅限活动栏位",
      tooltip = "只显示当前活动栏的技能设置按钮",
    },
    lockWindowPosition = {
      name = "锁定窗口位置",
      tooltip = "锁定窗口防止拖动",
    },
    fontSize = {
      name = "文字大小",
      tooltip = "界面字体大小",
    },
    btnSize = {
      name = "技能图标大小",
      tooltip = "技能图标大小",
    },
    columnMajorOrder = {
      name = "首列排序",
      tooltip = "对于接口中的集合,使用列(垂直)排序",
    },
    openWithSkillsWindow = {
      name = "在技能窗口显示",
      tooltip = "打开技能窗口时自动显示界面",
    },
    openWithInventoryWindow = {
      name = "在道具窗口显示",
      tooltip = "打开道具窗口时自动显示界面",
    },
    numRows = {
      name = "行数",
      tooltip = "窗口中包含的配置行数",
    },
    numCols = {
      name = "列数",
      tooltip = "窗口中包含的列数",
    },
    showChatMessages = {
      name = "显示聊天消息",
      tooltip = "保存、装备或删除齿轮组或动作栏时显示聊天消息",
    },
    singleBarToCurrent = {
      name = "加载单个技能栏,并激活",
      tooltip = "加载一个动作栏,不加载套装配置,忽略空栏",
    },
    autoCloseOnMovement = {
      name = "移动时自动关闭",
      tooltip = "移动时自动关闭Dressing Room的窗口",
    },
    enablePages = {
      name = "使用配置页",
      tooltip = "禁用此选项不会清除现有配置页",
    },
    confirmPageDelete = {
      name = "确认配置页删除",
      tooltip = "删除配置页时显示确认提示",
    },
    alwaysChangePageOnZoneChanged = {
      name = "区域变更时总回变更配置页",
      tooltip = "如果没有配置预设,加载默认(第一个)配置页",
    },
    useOldUI = {
      name = "使用旧版界面",
      tooltip = "使用原版界面",
    },
    roleSpecificPresets = {
      name = "启用独立角色页面",
      tooltip = "账号内角色使用单独的页面",
    },
    roleFromLFGTool = {
      name = "LFG工具自动选择角色",
      tooltip = "在LFG工具中更改您的组角色后，自动选择适当的替代页面",
    },
    autoSaveChangesOnClose = {
      name = "Auto save changes on window close",
      tooltip = "Automatically save all your changes when you close the Dressing Room window.\n|cff8000Note that you always need to reload UI or log out to save data to disk.|r",
    },
    expertFeatures = "专家模式",
    enableExpertFeatures = {
      name = "开启专家模式",
      tooltip = "我已经阅读了所有的警告,并备份了Dressing Room 的配置信息",
    },
    changeDefaultRole = {
      name = "更改默认设置",
      tooltip = "如果你选择了错误的默认设置，你可以选择这个.",
    },
    exchangePages = {
      name = "交換页",
      tooltip = "这将 *替换* 所有\"%s\"已选中的预设.",
    },
    purgeCharacterData = {
      name = "|cff0000 清除角色数据 |r",
      tooltip = "删除所有信息, 并且重置所有角色配置 \n\n按键绑定不会重置",
    },
    importPresetsFromCharacter = {
      name = "Import presets from character",
      tooltip = "This will not delete your current presets if the option below isn't enabled, only add the new pages to the end of the list.",
    },
    purgePresetsBeforeImporting = {
      name = "Purge presets before importing",
      tooltip = "Copy presets from another character without keeping the old ones.",
    },
    importAlphaGear = "|cff0000从 AlphaGear导入配置|r",
    importAlphaGearWarning = "|cff0000注意 - 实验功能! - 按键之前仔细阅读!|r\n\n此操作会删除 Dressing Room 的所有配置信息. .\n\n 此操作仅兼容'|cFFAA33AlphaGear 2 %s|r', .使用其他版本风险自负.%s\n\n此选项同时会重载界面.",
    importAlphaGearVersionMismatchWarning = "已安装版本:",
    importAlphaGearNotDetected = "未找到AlphaGear 2, 请启用后再试",
    importAlphaGearRebindKeys = {
      name = "重新绑定按键",
      tooltip = "建议先关闭，检查配置后再开启.",
    },
  },

  setupWindowText = "选择角色的首选设置:",
  setupWindowText2 = "这个可以在插件设置中进行设置.",

  confirmDeletePagePromptOld = "删除配置页?",
  confirmDeletePagePrompt = "删除配置页 \"<<1>>\"?",
  editPageNamePrompt = "为 \"<<1>>\"输入新名称:",

  changesSave = "Confirm Changes",
  changesUndo = "Cancel All Changes",

  barBtnText = "点击单独加载技能栏\nShift + 左键点击保存\nCtrl + 左键点击删除",
  gearBtnText = "点击使用套装配置\nShift + 左键点击保存\nCtrl + 左键点击删除",
  setBtnText = "单击此处加载套装配置和技能配置",

  bttnUndressText = "解除装备",
  undressClicked = "解除所有装备",

  set = "设置",
  usedBy = "使用者:",

  rechargedWeapon = "充能 |cff0000%s|r using |c00ff00%s|r",

  waitingForWeaponSwap = "需要切换技能栏",
  waitingForOutOfCombat = "需要脱离战斗",
}

