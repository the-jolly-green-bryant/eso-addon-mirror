local WG = SDC_WareGuild

--[[
For translation, you have to copy this file and rename it in xx.lua, and translated the strings below. 
you can get the xx for your language by typing following line in game chat
/script d(GetCVar("language.2"))
]]

WG.Lang = {
  --Craft Type, No Need to Translate
  ["BLACKSMITH"] = GetString(SI_ITEMFILTERTYPE13),
  ["CLOTH"] = GetString(SI_ITEMFILTERTYPE14),
  ["ENCHANT"] = GetString(SI_ITEMFILTERTYPE17),
  ["ALCHEMY"] = GetString(SI_ITEMFILTERTYPE16),
  ["COOK"] = GetString(SI_ITEMFILTERTYPE18),
  ["WOOD"] = GetString(SI_ITEMFILTERTYPE15),
  ["JEWELRY"] = GetString(SI_ITEMFILTERTYPE25),
  
  ["STYLE"] = GetString(SI_ITEMFILTERTYPE19),
  ["TRAIT"] = GetString(SI_ITEMFILTERTYPE20),
  
  --Info Displayed in Chat Window, Need to Translate
  
  ["CHAT_FUZZY"] = " (模糊匹配)", --Added to ItemName Matched by ItemId
  
  ["CHAT_TAKE_TO"] = "使背包中 <<1>> 数量为 <<2>>", -- <<1>> ItemName, <<2>> Quantity
  ["CHAT_TAKE_ALL"] = "取出所有 <<1>>", -- <<1>> ItemName
  
  ["CHAT_STORE_TO"] = "使银行中 <<1>> 数量为 <<2>>", -- <<1>> ItemName, <<2>> Quantity
  ["CHAT_STORE_ALL"] = "存储所有 <<1>>", -- <<1>> ItemName
  ["CHAT_STORE_ALL_TYPE"] = "存储所有 <<1>> 材料", -- <<1>> Craft Type
  
  ["CHAT_DAILY_WRITS"] = "尝试取出 日常制造 材料/物品",
  
  ["CHAT_NE_TAKE"] = "[<<1>>] 取出 <<2>> 时，数量不足", -- <<1>> Guild Name, <<2>> ItemName
  ["CHAT_NE_STORE"] = "[<<1>>] 存储 <<2>> 时，数量不足", -- <<1>> Guild Name, <<2>> ItemName
  
  ["CHAT_DONE"] = "完工！",
  ["CHAT_NO_WORK"] = "无事可做！",
  ["CHAT_STOP"] = "停机！",
  ["CHAT_ERROR"] = "发生错误！",
  
  ["CHAT_BACKBAG_FULL"] = "背包已满！",
  ["CHAT_GUILD_BANK_FULL"] = "银行已满！",
  
  --Setting, Need to Translate
  
  ["SETTING_CHARACTER_CONFIG"] = "为当前角色单独配置",
  ["SETTING_CHARACTER_CONFIG_TOOLTIP"] = "默认使用账户配置",
  
  ["SETTING_AUTO_OPEN_STORE"] = "需要存储时，自动打开公会银行",
  ["SETTING_AUTO_OPEN_STORE_TOOLTIP"] = "仅当WG发现有物品需要储存时生效\r\n对 [存储至 x 件] 操作步骤不生效",
  
  ["SETTING_AUTO_OPEN_WRITS"] = "生产日常时，自动打开公会银行",
  ["SETTING_AUTO_OPEN_WRITS_TOOLTIP"] = "仅当 [取出日常生产物品] 操作步骤存在\r\n且持有生产日常任务时生效",
  
  ["SETTING_AUTO_CLOSE"] = "自动关闭公会银行",
  ["SETTING_AUTO_CLOSE_TOOLTIP"] = "仅当WG实际进行存取操作后生效",
  
  ["SETTING_STEPS_LOG"] = "输出存取操作记录",
  ["SETTING_STEPS_LOG_TOOLTIP"] = "将WG实际存储物品的操作输出至聊天栏",
  
  ["SETTING_BAN_STORE_WRITS"] = "生产日常时，禁用存储相关步骤",
  ["SETTING_BAN_STORE_WRITS_TOOLTIP"] = "需要利用公会银行进行生产日常时，推荐开启",
  
  ["SETTING_IGNORE_INVENTORY"] = "[取出日常生产物品] 步骤无视库存",
  ["SETTING_IGNORE_INVENTORY_TOOLTIP"] = "开启后，该步骤将无视背包、个人银行和制作包裹中，可用于制作产物的材料数量（例：共需要42锭生产，已有30锭。开启后将尝试从公会银行取出42锭而不是12锭）",
  
  ["SETTING_NE_TAKE"] = "物品不足时，取出所有剩余",
  ["SETTING_NE_TAKE_TOOLTIP"] = "关闭时，物品不足将跳过该取出步骤",
  
  ["SETTING_NE_STORE"] = "物品不足时，存储所有剩余",
  ["SETTING_NE_STORE_TOOLTIP"] = "关闭时, 物品不足将跳过该存储步骤",
  
  ["SETTING_IGNORE_FCOIS"] = "无视 FCO ItemSaver 插件",
  ["SETTING_IGNORE_FCOIS_TOOLTIP"] = "无视 FCO ItemSaver 插件对于存取公会银行物品的限制",
  
  ["SETTING_HEADER_SELECT_GUILD"] = "选择公会银行",
  ["SETTING_GUILD_TIPS"] = "小贴士:\r\nWG将按顺序依次执行各银行步骤，请自行确保公会银行权限\r\n新加入公会后需重新加载UI，以读取公会列表", -- \r\n Line Feed
  
  ["GUILD_ITEM_SCROLL"] = "选择背包物品,创建操作步骤",
  
  ["GUILD_FUZZY"] = "模糊匹配",
  ["GUILD_FUZZY_TOOLTIP"] = "物品链接(精确匹配)/物品ID(模糊匹配)\r\n不推荐启用",
  
  ["GUILD_UPDATE_ITEM_LIST"] = "刷新物品列表",
  ["GUILD_TAKE_ALL"] = "取出所有",
  ["GUILD_STORE_ALL"] = "存储所有",
  
  ["GUILD_TAKE_TO_SLIDER"] = "使背包中，物品数量为 x",
  ["GUILD_TAKE_TO"] = "取出至 x 件",
  
  ["GUILD_STORE_TO_SLIDER"] = "使银行中，物品数量为 x",
  ["GUILD_STORE_TO"] = "存储至 x 件",
  
  ["GUILD_STORE_ALL_TYPE_DROP"] = "选择存储的材料类型",
  ["GUILD_STORE_ALL_TYPE"] = "存储该类材料",
  
  ["GUILD_TAKE_WRITS"] = "取出日常生产物品",
  ["GUILD_TAKE_WRITS_TOOLTIP"] = "需要先接取日常制造任务！\n每个公会仅需添加一次，具体规则如下：\n为 锻铁、制衣、木匠、珠宝和附魔 取出制作缺少的原材料\n为 烹饪和炼金 取出成品\n为 附魔和炼金 取出需提交的材料\n*不含有样式材料",
  
  ["GUILD_HEADER_STEPS"] = "操作步骤",
  ["GUILD_STEPS_SLIDER"] = "选择步骤所在行",
  ["GUILD_STEPS_EMPTY"] = "清空步骤",
  ["GUILD_STEPS_DELETE"] = "删除所选步骤",
  
  ["CLIP"] = "剪切板",
  ["CLIP_PASTE"] = "粘贴",
  
  ["SETTING_BOTTOM_TIPS"] = "可在 Guar Protection/Splendid Achievers 公会群，找到作者 @MelanAster",
}