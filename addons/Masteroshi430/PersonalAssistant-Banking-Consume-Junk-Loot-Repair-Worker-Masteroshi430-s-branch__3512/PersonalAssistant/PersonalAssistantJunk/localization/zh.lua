-- Translated by: PersonalAssistant Localization Team (Completed & Fixed)

local PAC = PersonalAssistant.Constants
local PAJStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk Menu --
    SI_PA_MENU_JUNK_DESCRIPTION = "PAJunk将标记符合规则的物品为垃圾，除非该物品为制造或从邮件取出", 

    -- Standard Items --
    SI_PA_MENU_JUNK_STANDARD_ITEMS_HEADER = "标准物品", 
    SI_PA_MENU_JUNK_AUTOMARK_ENABLE = "启用自动标记垃圾", 
    SI_PA_MENU_JUNK_AUTOMARK_ENABLE_T = "仅适用于'标准物品'。自定义垃圾规则不适用于该规则，如果需要禁用请在自定义规则处设置", 

    SI_PA_MENU_JUNK_TRASH_AUTOMARK = table.concat({"自动标记 [", GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), "]"}), 
    SI_PA_MENU_JUNK_TRASH_AUTOMARK_T = table.concat({"自动标记 [", GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), "] 为垃圾"}), 
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_ITEMS_DESC = table.concat({"禁止标记 [", GetString("SI_ITEMTYPE", ITEMTYPE_TRASH), "] 为垃圾，如果. . ."}), 
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_NIBBLES_AND_BITS = table.concat({"> 日常任务需要 ", PAC.COLOR.YELLOW:Colorize("Nibbles and Bits")}),
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_NIBBLES_AND_BITS_T = table.concat({PAC.COLOR.YELLOW:Colorize("任务地点: "), PAC.COLOR.ORANGE:Colorize("发条城"), "\n启用后，以下物品不会被标记为垃圾:\n[甲壳 (Carapace)]\n[脏烂皮革 (Daedra Husks)]\n[魔族外皮 (Dirty Hide)]"}),
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_MORSELS_AND_PECKS = table.concat({"> 日常任务需要 ", PAC.COLOR.YELLOW:Colorize("Morsels and Pecks")}), 
    SI_PA_MENU_JUNK_TRASH_EXCLUDE_MORSELS_AND_PECKS_T = table.concat({PAC.COLOR.YELLOW:Colorize("任务地点: "), PAC.COLOR.ORANGE:Colorize("发条城"), "\n启用后，以下物品不会被标记为垃圾:\n[元素精华 (Elemental Essence)]\n[韧皮部 (Supple Roots)]\n[外质 (Ectoplasm)]"}),

    SI_PA_MENU_JUNK_COLLECTIBLES_AUTOMARK = table.concat({"自动标记 [", GetString("SI_ITEMSELLINFORMATION", ITEM_SELL_INFORMATION_PRIORITY_SELL), "]"}),
    SI_PA_MENU_JUNK_COLLECTIBLES_AUTOMARK_T = table.concat({"自动标记拥有特性 [", GetString("SI_ITEMSELLINFORMATION", ITEM_SELL_INFORMATION_PRIORITY_SELL), "]的物品为垃圾."}), 
    SI_PA_MENU_JUNK_COLLECTIBLES_EXCLUDE_ITEMS_DESC = table.concat({"禁止标记 [", GetString("SI_ITEMSELLINFORMATION", ITEM_SELL_INFORMATION_PRIORITY_SELL), "]为垃圾，如果. . ."}),
    SI_PA_MENU_JUNK_COLLECTIBLES_EXCLUDE_RARE_FISH = table.concat({"> [", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH), "] 用于节日日常 ", PAC.COLOR.YELLOW:Colorize("鱼之恩赐盛宴")}),
    SI_PA_MENU_JUNK_COLLECTIBLES_EXCLUDE_RARE_FISH_T = table.concat({PAC.COLOR.YELLOW:Colorize("活动时间: "), PAC.COLOR.ORANGE:Colorize("新生节"), "（冬季举办）\n如果启用，任何 [", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH),"] 将不会被标记为垃圾"}),

    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_AUTOMARK = table.concat({"自动标记 [", GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE), "]"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_AUTOMARK_T = table.concat({"自动标记 [", GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE), "]为垃圾"}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_ITEMS_DESC = table.concat({"禁止摧毁或标记 [", GetString("SI_ITEMTYPE", ITEMTYPE_TREASURE), "]为垃圾，如果 . . ."}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_LEISURE = table.concat({"> 日常任务需要 ", PAC.COLOR.YELLOW:Colorize("A Matter of Leisure")}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_LEISURE_T = table.concat({PAC.COLOR.YELLOW:Colorize("任务地点: "), PAC.COLOR.ORANGE:Colorize("发条城"), "\n启用后，以下物品不会被标记为垃圾:\n[儿童玩具]\n[玩偶]\n[游戏]"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_RESPECT = table.concat({"> 日常任务需要 ", PAC.COLOR.YELLOW:Colorize("A Matter of Respect")}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_RESPECT_T = table.concat({PAC.COLOR.YELLOW:Colorize("任务地点: "), PAC.COLOR.ORANGE:Colorize("发条城"), "\n启用后，以下物品不会被标记为垃圾:\n[餐具]\n[饮具]\n[器皿与厨具]"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_TRIBUTES = table.concat({"> 日常任务需要 ", PAC.COLOR.YELLOW:Colorize("A Matter of Tributes")}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_A_MATTER_OF_TRIBUTES_T = table.concat({PAC.COLOR.YELLOW:Colorize("任务地点: "), PAC.COLOR.ORANGE:Colorize("发条城"), "\n启用后，以下物品不会被标记为垃圾:\n[化妆品]\n[梳洗用品]"}),
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_THE_COVETOUS_COUNTESS = table.concat({"> 日常任务需要 ", PAC.COLOR.YELLOW:Colorize("The Covetous Countess")}), 
    SI_PA_MENU_JUNK_MISCELLANEOUS_TREASURES_EXCLUDE_THE_COVETOUS_COUNTESS_T = table.concat({PAC.COLOR.YELLOW:Colorize("任务地点: "), PAC.COLOR.ORANGE:Colorize("盗贼公会"), "\n启用后，以下物品不会被标记为垃圾:\n[化妆品]\n[干货 (织物)]\n[衣着配饰]\n\n[饮具]\n[餐具]\n[器皿与厨具]\n\n[游戏]\n[玩偶]\n[雕像]\n\n[书写物] 与 [抄写员用品]\n[地图]\n\n[仪式器物]\n[奇珍异宝]"}),

    -- Stolen Items --
    SI_PA_MENU_JUNK_AUTOMARK_STOLEN_HEADER = "偷取的物品", 
    SI_PA_MENU_JUNK_ACTION_STOLEN_PLACEHOLDER = "%s", 

    -- Custom Items --
    SI_PA_MENU_JUNK_CUSTOM_ITEMS_HEADER = "自定义物品", 
    SI_PA_MENU_JUNK_CUSTOM_ITEMS_DESCRIPTION = table.concat({GetString(SI_PA_MENU_RULES_HOW_TO_ADD_PAJ), "\n\n", GetString(SI_PA_MENU_RULES_HOW_TO_FIND_MENU)}), 

    -- Quest Items --
    SI_PA_MENU_JUNK_QUEST_ITEMS_HEADER = "保护任务用品", 
    SI_PA_MENU_JUNK_QUEST_CLOCKWORK_CITY_HEADER = "发条城", 
    SI_PA_MENU_JUNK_QUEST_THIEVES_GUILD_HEADER = "盗贼公会", 
    SI_PA_MENU_JUNK_QUEST_NEW_LIFE_FESTIVAL_HEADER = "新生节", 

    -- Auto-Sell --
    SI_PA_MENU_JUNK_AUTO_SELL_JUNK_HEADER = "自动出售垃圾", 

    -- Auto-Launder --
    SI_PA_MENU_JUNK_AUTO_LAUNDER_HEADER = "自动清洗赃物",
    SI_PA_MENU_JUNK_AUTO_LAUNDER = "开启自动清洗赃物",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_LOCKPICKS = "清洗开锁器？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_INGREDIENTS = "清洗烹饪食材？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_MATERIALS = "清洗手艺材料？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_CRAFTING_BOOSTERS = "清洗强化材料（改良剂）？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_ENCHANTING_RUNES = "清洗附魔符文？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_GLYPHS = "清洗附魔符文片？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_FURNISHING = "清洗家具与蓝图？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_SOULGEMS = "清洗灵魂石？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_TREASURES = "清洗宝藏？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_TREASURE_MAPS = "清洗藏宝图？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_RECIPES = "清洗配方与设计图？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_MOTIFS = "清洗样式书页？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_EDICTS = "清洗赦免令？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_CONTAINERS = "清洗容器？",
    SI_PA_MENU_JUNK_AUTO_LAUNDER_REPAIR_KITS = "清洗修理工具？",

    -- Auto-Destroy --
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_HEADER = "自动摧毁垃圾", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK = "启用自动摧毁垃圾", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_T = "当获取的物品符合自动标记为垃圾的条件，且销售价值或物品品质低于设定的阈值时，则自动摧毁。该操作不可逆转!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_W = "警告：请注意启用该设置后，摧毁符合条件的物品不会要求您二次确认！\n该类物品将被直接摧毁!\n永久性!\n请自行承担后果!", 

    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_JUNK_HEADER = "垃圾", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_VALUE_THRESHOLD = "当出售价值小于等于", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_VALUE_THRESHOLD_T = "仅自动摧毁销售价格小于或等于阈值的垃圾，一旦该物品被摧毁，无法找回!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_QUALITY_THRESHOLD = "且物品品质小于或等于", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_MAX_QUALITY_THRESHOLD_T = "仅自动摧毁品质低于或等于阈值的垃圾，一旦该物品被摧毁，无法找回!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_JUNK_EXCLUSION_DISCLAIMER = "例外：任何'未知'的物品（配方，样式书，样式书页等）永远不会被自动摧毁，即使符合销售价格和物品品质的阈值", 

    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_JUNK_HEADER = "偷取的垃圾", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK = "启用自动摧毁偷取的垃圾", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_T = "当偷取的物品符合自动标记为垃圾的条件，且销售价值或物品品质低于设定的阈值时，则自动摧毁。该操作不可逆转!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_VALUE_THRESHOLD = "当销赃价值小于等于", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_VALUE_THRESHOLD_T = "仅自动摧毁销赃价格小于或等于阈值的垃圾，一旦该物品被摧毁，无法找回!", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_QUALITY_THRESHOLD = "且物品品质小于或等于", 
    SI_PA_MENU_JUNK_AUTO_DESTROY_STOLEN_JUNK_MAX_QUALITY_THRESHOLD_T = "仅自动摧毁品质小于或等于阈值的垃圾，一旦该物品被摧毁，无法找回!", 

    -- Other Settings --
    SI_PA_MENU_JUNK_MAILBOX_IGNORE = "禁止标记通过邮件获取的物品为垃圾", 
    SI_PA_MENU_JUNK_MAILBOX_IGNORE_T = "通过邮件获取的物品永远不会被标记为垃圾", 
    SI_PA_MENU_JUNK_CRAFTED_IGNORE = "禁止标记玩家制造的物品为垃圾", 
    SI_PA_MENU_JUNK_CRAFTED_IGNORE_T = "玩家制造的物品永远不会被标记为垃圾", 
    SI_PA_MENU_JUNK_AUTOSELL_JUNK = "在商人或销赃处自动出售垃圾", 
    SI_PA_MENU_JUNK_AUTOSELL_JUNK_PIRHARRI = "允许自动出售给销赃盟友", 
    SI_PA_MENU_JUNK_AUTOSELL_JUNK_PIRHARRI_W = "销赃盟友会额外收取35%走私费用", 

    SI_PA_MENU_JUNK_KEYBINDINGS_HEADER = "快捷键", 
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_JUNK_ENABLE = "启用\"标记为垃圾\"快捷键", 
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_JUNK_SHOW = "显示\"标记为垃圾\"快捷键", 
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_PERM_JUNK_ENABLE = "启用\"永久标记为垃圾\"快捷键", 
    SI_PA_MENU_JUNK_KEYBINDINGS_MARK_UNMARK_PERM_JUNK_SHOW = "显示\"永久标记为垃圾\"快捷键", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_ITEM_ENABLE = "启用\"摧毁物品\"快捷键", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_ITEM_ENABLE_W = "警告:注意通过该快捷键摧毁物品不会要求您二次确认！\n该物品将被直接摧毁!\n永久性!\n请自行承担后果!", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_ITEM_SHOW = "显示\"摧毁物品\"快捷键", 
    SI_PA_MENU_JUNK_KEYBINDINGS_EXCLUDE_DESCRIPTION = "禁用\"摧毁物品\"快捷键，如果物品 . . .", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_QUALITY_THRESHOLD = "> 大于或等于设定的品质", 
    SI_PA_MENU_JUNK_KEYBINDINGS_DESTROY_UNKNOWN = "> 可以被学习/研究且为未知", 

    -- General texts used across: Weapons, Armor, Jewelry
    SI_PA_MENU_JUNK_AUTOMARK_QUALITY_THRESHOLD = "自动标记 %s 小于或等于品质", 
    SI_PA_MENU_JUNK_AUTOMARK_QUALITY_THRESHOLD_T = "自动标记%s为垃圾，如果小于或等于所选品质", 
    SI_PA_MENU_JUNK_AUTOMARK_ORNATE = table.concat({"自动标记 %s [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "]特性"}),
    SI_PA_MENU_JUNK_AUTOMARK_ORNATE_T = table.concat({"自动标记%s [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "]特性（增加出售价格）的物品为垃圾"}),
    SI_PA_MENU_JUNK_AUTOMARK_INTRICATE = table.concat({"自动标记 %s [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "]特性"}),
    SI_PA_MENU_JUNK_AUTOMARK_INTRICATE_T = table.concat({"自动标记%s [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "]特性（增加拆解经验）的物品为垃圾"}),
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_SETS = "自动标记 %s 套装物品",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_SETS_T = "如果关闭，仅 %s 中不属于套装的物品将被标记为垃圾",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_KNOWN_TRAITS = "自动标记 %s 已知特性",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_KNOWN_TRAITS_T = "如果关闭，仅 %s 中无特性或未知特性的物品会被标记为垃圾",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_UNKNOWN_TRAITS = "自动标记 %s 未知特性",
    SI_PA_MENU_JUNK_AUTOMARK_INCLUDE_UNKNOWN_TRAITS_T = "如果关闭，仅 %s 中无特性或已知特性的物品会被标记为垃圾",


    -- =================================================================================================================
    -- == MAIN MENU TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk --
    SI_PA_MAINMENU_JUNK_HEADER = "垃圾标记规则", 

    SI_PA_MAINMENU_JUNK_HEADER_ITEM = "物品", 
    SI_PA_MAINMENU_JUNK_HEADER_JUNK_COUNT = "垃圾数量", 
    SI_PA_MAINMENU_JUNK_HEADER_LAST_JUNK = "最近的垃圾", 
    SI_PA_MAINMENU_JUNK_HEADER_RULE_ADDED = "已添加规则", 
    SI_PA_MAINMENU_JUNK_HEADER_ACTIONS = "操作", 

    SI_PA_MAINMENU_JUNK_ROW_NEVER_JUNKED = "绝不", 


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAJunk --
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_TRASH = table.concat({"将%s移动至垃圾箱 (", PAC.COLOR.ORANGE:Colorize(GetString("SI_ITEMTYPE", ITEMTYPE_TRASH)), ")"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_ORNATE = table.concat({"将%s移动至垃圾箱 (", PAC.COLOR.ORANGE:Colorize(GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE)), ")"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_INTRICATE = table.concat({"将%s移动至垃圾箱 (", PAC.COLOR.ORANGE:Colorize(GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE)), ")"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_QUALITY = table.concat({"将%s移动至垃圾箱 (", PAC.COLOR.ORANGE:Colorize("品质"), ")"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_MERCHANT = table.concat({"将%s移动至垃圾箱 (", PAC.COLOR.ORANGE:Colorize("出售"), ")"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_TREASURE = table.concat({"将%s移动至垃圾箱 (", PAC.COLOR.ORANGE:Colorize("宝藏"), ")"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_KEYBINDING = table.concat({"将%s移动至垃圾箱 (", PAC.COLOR.ORANGE:Colorize("手动"), ")"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_STOLEN = table.concat({"将%s移动至垃圾箱 (", PAC.COLOR.ORANGE:Colorize("偷取"), ")"}),
    SI_PA_CHAT_JUNK_MARKED_AS_JUNK_PERMANENT = table.concat({"将%s移动至垃圾箱 (", PAC.COLOR.ORANGE:Colorize("永久规则"), ")"}),

    SI_PA_CHAT_JUNK_DESTROYED_KEYBINDING = table.concat({PAC.COLOR.ORANGE_RED:Colorize("已摧毁"), " %d x %s"}),
    SI_PA_CHAT_JUNK_DESTROYED_ALWAYS = table.concat({PAC.COLOR.ORANGE_RED:Colorize("已摧毁"), " %d x %s (", PAC.COLOR.ORANGE:Colorize("总是"), ")"}),
    SI_PA_CHAT_JUNK_DESTROYED_CRITERIA_MATCH = table.concat({PAC.COLOR.ORANGE_RED:Colorize("已摧毁"), " %d x %s (出售价格: %s)"}),
    SI_PA_CHAT_JUNK_AUTO_LAUNDERED = table.concat({PAC.COLOR.ORANGE_RED:Colorize("已清洗赃物"), " %d x %s (清洗费用: %s)"}),

    SI_PA_CHAT_JUNK_DESTROY_ON = table.concat({"自动摧毁垃圾已", PAC.COLOR.RED:Colorize("开启")}), 
    SI_PA_CHAT_JUNK_DESTROY_OFF = table.concat({"自动摧毁垃圾已", PAC.COLOR.GREEN:Colorize("关闭")}), 
    SI_PA_CHAT_JUNK_DESTROY_STOLEN_ON = table.concat({"自动摧毁偷取物品已", PAC.COLOR.RED:Colorize("开启")}), 
    SI_PA_CHAT_JUNK_DESTROY_STOLEN_OFF = table.concat({"自动摧毁偷取物品已", PAC.COLOR.GREEN:Colorize("关闭")}), 

    SI_PA_CHAT_JUNK_SOLD_ITEMS_INFO = "已出售物品，总共获得 %s",
    SI_PA_CHAT_JUNK_FENCE_LIMIT_HOURS = table.concat({GetString("SI_STOREFAILURE", STORE_FAILURE_AT_FENCE_LIMIT), "请等待 ~%d 小时"}),
    SI_PA_CHAT_JUNK_FENCE_LIMIT_MINUTES = table.concat({GetString("SI_STOREFAILURE", STORE_FAILURE_AT_FENCE_LIMIT), "请等待 ~%d 分钟"}),
    SI_PA_CHAT_JUNK_FENCE_ITEM_WORTHLESS = table.concat({"无法出售%s. ", GetString("SI_STOREFAILURE", STORE_FAILURE_WORTHLESS_TO_FENCE)}), 
    SI_PA_CHAT_JUNK_CANNOT_SELL_ITEM = "无法出售%s", 

    SI_PA_CHAT_JUNK_RULES_ADDED = table.concat({"%s 已", PAC.COLOR.ORANGE:Colorize("添加"), "至自定义垃圾列表!"}),
    SI_PA_CHAT_JUNK_RULES_DELETED = table.concat({"%s 已", PAC.COLOR.ORANGE:Colorize("移除"), "自自定义垃圾列表!"}),


    -- =================================================================================================================
    -- == KEY BINDINGS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- Addon Keybindings menu --
    SI_BINDING_NAME_PA_JUNK_TOGGLE_ITEM = "标记为垃圾/非垃圾",
    SI_BINDING_NAME_PA_JUNK_PERMANENT_TOGGLE_ITEM = "添加至/移出垃圾规则列表",
    SI_BINDING_NAME_PA_JUNK_DESTROY_ITEM = "直接摧毁物品",

    -- Actual keybindings --
    SI_PA_ITEM_ACTION_MARK_AS_PERM_JUNK = "添加至垃圾规则列表",
    SI_PA_ITEM_ACTION_UNMARK_AS_PERM_JUNK = "自垃圾规则列表移除",


    -- =================================================================================================================
    -- == OTHER STRINGS == --   !!! NEED TO BE AN EXACT MATCH WITH THE "TAG" ON THE ITEM !!!
    -- -----------------------------------------------------------------------------------------------------------------
    -- Quest: "A Matter of Leisure"
    SI_PA_TREASURE_ITEM_TAG_DESC_TOYS = "儿童玩具",
    SI_PA_TREASURE_ITEM_TAG_DESC_DOLLS = "玩偶",
    SI_PA_TREASURE_ITEM_TAG_DESC_GAMES = "游戏",

    -- Quest: "A Matter of Respect"
    SI_PA_TREASURE_ITEM_TAG_DESC_UTENSILS = "餐具",
    SI_PA_TREASURE_ITEM_TAG_DESC_DRINKWARE = "饮具",
    SI_PA_TREASURE_ITEM_TAG_DESC_DISHES_COOKWARE = "器皿与厨具",

    -- Quest: "A Matter of Tributes"
    SI_PA_TREASURE_ITEM_TAG_DESC_COSMETICS = "化妆品",
    SI_PA_TREASURE_ITEM_TAG_DESC_GROOMING = "梳洗用品",

    -- Quest: "The Covetous Countess" (only additional tags)
    SI_PA_TREASURE_ITEM_TAG_DESC_LINENS = "纺织品",
    SI_PA_TREASURE_ITEM_TAG_DESC_ACCESSORIES = "衣着配饰",
    SI_PA_TREASURE_ITEM_TAG_DESC_STATUES = "雕像",
    SI_PA_TREASURE_ITEM_TAG_DESC_WRITINGS = "书写物",
    SI_PA_TREASURE_ITEM_TAG_DESC_SCRIVENER = "抄写员用品",
    SI_PA_TREASURE_ITEM_TAG_DESC_MAPS = "地图",
    SI_PA_TREASURE_ITEM_TAG_DESC_RITUAL_OBJECTS = "仪式器物",
    SI_PA_TREASURE_ITEM_TAG_DESC_ODDITIES = "奇珍异宝",

    -- OTHERS: Not yet used
    SI_PA_TREASURE_ITEM_TAG_DESC_INSTRUMENTS = "乐器",
    SI_PA_TREASURE_ITEM_TAG_DESC_ARTWORK = "艺术品",
    SI_PA_TREASURE_ITEM_TAG_DESC_DECOR = "墙壁装饰品",
    SI_PA_TREASURE_ITEM_TAG_DESC_TRIFLES_ORNAMENTS = "小玩意与装饰品",
    SI_PA_TREASURE_ITEM_TAG_DESC_DEVICES = "装置",
    SI_PA_TREASURE_ITEM_TAG_DESC_SMITHING = "锻造设备",
    SI_PA_TREASURE_ITEM_TAG_DESC_TOOLS = "工具",
    SI_PA_TREASURE_ITEM_TAG_DESC_MEDICAL_SUPPLIES = "医疗用品",
    SI_PA_TREASURE_ITEM_TAG_DESC_CURIOSITIES = "魔法奇珍",
    SI_PA_TREASURE_ITEM_TAG_DESC_FURNISHINGS = "家具用品",
    SI_PA_TREASURE_ITEM_TAG_DESC_LIGHTS = "照明设备",


    -- =================================================================================================================
    -- PAJunk Menu --
    -- Fix wrong endings of headers and fix unused collectibles translation
    SI_PA_MENU_JUNK_COLLECTIBLES_HEADER = zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_COLLECTIBLE), 2), 
    SI_PA_MENU_JUNK_WEAPONS_HEADER = zo_strformat(GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), 1), 
    SI_PA_MENU_JUNK_ARMOR_HEADER= zo_strformat(GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR),1 ), 
    SI_PA_MENU_JUNK_JEWELRY_HEADER = zo_strformat(GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), 1), 
}

for key, value in pairs(PAJStrings) do
    SafeAddString(_G[key], value, 1) 
end