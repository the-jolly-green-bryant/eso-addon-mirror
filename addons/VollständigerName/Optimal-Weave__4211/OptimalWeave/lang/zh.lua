-- =============================================================================
-- === OptimalWeave Language File: Simplified Chinese (zh.lua)                ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/zh.lua
    Description:        Chinese localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ==============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "信息 & 说明")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "全局冷却 (GCD) 为1000毫秒。OptimalWeave根据所选模式管理技能队列以优化轻击。使用以下设置自定义行为。")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "核心机制")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "激活规则")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "高级控制")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "性能设置")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "插件已启用")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "插件已禁用")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "该选项当前已禁用")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "警告：高延迟值可能导致输入延迟！")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000注意|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP",  "|cFF0000免责声明:|r 本插件与ZeniMax Media Inc.无关联。The Elder Scrolls®是ZeniMax Media Inc.的注册商标。版权所有。")

-- =============================================================================
-- == CORE SETTINGS ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "核心设置")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "操作模式")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00顺序:|r 仅在进行轻攻击后才允许使用技能。\n|cFF0000严格:|r 完全阻止。\n|cFFFF00智能:|r 无轻击时允许队列。\n|c00FFFF无:|r 禁用。")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "顺序")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "严格")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "智能")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "无")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "仅在战斗中激活")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "仅在战斗期间管理队列。")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "仅敌对目标时激活")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "需要选择敌对目标。")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "格挡时忽略")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "格挡时禁用控制。")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "阻止重复地面技能")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "防止意外重复施放。")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "禁用作为坦克")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "坦克角色时自动禁用")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "禁用作为治疗")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "治疗角色时自动禁用")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "在副栏上禁用功能")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "在副栏上禁用大部分插件功能。")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "在副栏上禁用轻击辅助")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "在副栏上禁用轻击辅助（GCD 管理）。")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "PvP 停用")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "在 PvP 中停用功能")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "在 PvP 区域停用大部分插件功能")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "在 PvP 中停用编织辅助")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "在 PvP 区域停用编织辅助（GCD 管理）")

-- =============================================================================
-- == BLOCK ID SETTINGS =======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "已阻止技能")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "阻止新ID")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "输入技能ID（例如：134160）")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "当前已阻止ID")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "点击移除")

-- =============================================================================
-- == ADVANCED SETTINGS =======================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "瞬发缓冲（毫秒）")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "瞬发技能安全间隔（0-100毫秒）")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "引导缓冲（毫秒）")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "引导技能缓冲时间（0-400毫秒）")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "GCD跟踪栏位")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "用于GCD检测的动作栏位（1-8）")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "重置时间（秒）")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "在这么长时间内没有施放任何技能后重置跟踪。")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "自动GCD跟踪槽")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "自动从3-8槽中选择最佳的GCD跟踪槽")
ZO_CreateStringId("OW_MENU_MIN_GCD", "最小GCD阈值（毫秒）")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "识别最小GCD时长（0-20毫秒）")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "基础队列时间（毫秒）")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "默认输入队列窗口（100-2000毫秒）")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "武器切换时重置")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "武器切换时重置全局冷却")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "翻滚时重置")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "翻滚时重置全局冷却")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "自动拔武器")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "在战斗中自动拔出武器")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "重置所有")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "将所有设置重置为默认值")

-- =============================================================================
-- == LATENCY COMPENSATION ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "延迟补偿")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "自动延迟调整")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "根据延迟自动调整。")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "手动输入延迟（毫秒）")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "不稳定连接时使用固定值（0-200毫秒）。")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "职业和公会专属设置")

ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "严峻焦点")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "所需堆叠数")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "激活严峻焦点前所需的堆叠数 (推荐：10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "阻止所有严峻焦点变形")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• 不懈焦点：|r 始终阻断\n|cFFFF00• 严峻焦点和无情决心：|r 仅在10层堆叠时可用\n|cAAAAAA停用：|r 所有变形采用默认行为")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "启用自定义堆叠数")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700启用：|r 使用自定义堆叠设置 \n|cAAAAAA停用：|r 始终阻断严峻焦点和无情决心至10层堆叠，并始终阻断不懈焦点\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "公会")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "屏蔽战士公会猎人技能")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "屏蔽战士公会猎人技能的所有变体（专家猎人、伪装猎人 & 邪恶猎人）")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "屏蔽法师公会光之技能")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "屏蔽光之技能的所有变体（法师之光、心灵之光 & 炽热法师之光）")

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "在PvP中禁用")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "在PvP区域禁用猎人/光明技能封锁")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "熔岩长鞭")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "屏蔽熔岩长鞭技能")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "屏蔽熔岩长鞭技能以防止失去三层效果")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "奥术师命运雕刻者")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "阻止命运雕刻者施放")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "满足条件前阻止施放命运雕刻者")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "需要核心堆叠")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "施放命运雕刻者所需的核心堆叠数（推荐：3）")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "生命值阈值 (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "当生命值低于此值时，停止阻止命运刻蚀者")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "为命运刻蚀者启用生命值检查")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "生命值过低时停止阻止命运刻蚀者")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "耐力阈值 (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "耐力过低时停止阻止命运刻蚀者")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "为命运刻蚀者启用耐力检查")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "耐力过低时停止阻止命运刻蚀者")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS =======================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "首脑连枷")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "阻挡首脑连枷")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "当有3层克鲁克斯时阻挡首脑连枷")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "触须恐惧")
ZO_CreateStringId("OW_MENU_TENTACULAR", "阻止触须恐惧")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "满足条件前阻止触须恐惧技能")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "处决检查")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "启用处决检查")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "启用或禁用处决检查功能")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "处决阈值 (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "目标生命值百分比，低于此值时允许使用处决技能")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "处决技能")

-- == Grouped Execute Spells ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "辉煌毁灭, 辉煌荣耀, 辉煌压迫")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "在目标达到处决范围前阻止辉煌毁灭变形技能")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "刺客之刃, 穿刺击, 杀手之刃")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "在目标达到处决范围前阻止刺客之刃变形技能")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "法师之怒, 法师之怒, 无尽之怒")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "在目标达到处决范围前阻止法师之怒变形技能")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "反向斩击, 反向劈砍, 处决者")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "在目标达到处决范围前阻止反向斩击变形技能")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "WIP")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "根据武器类型禁用")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "在武器类型上禁用轻击辅助")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "仅对选定的武器类型禁用轻击辅助（GCD 管理）")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "在武器类型上禁用功能")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "对选定的武器类型禁用大部分插件功能")

-- 单手武器
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "斧")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "装备斧时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "锤")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "装备锤时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "剑")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "装备剑时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "匕首")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "装备匕首时禁用")

-- 双手武器
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "双手剑")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "装备双手剑时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "双手斧")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "装备双手斧时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "双手锤")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "装备双手锤时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "弓")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "装备弓时禁用")

-- 法杖
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "火焰法杖")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "装备火焰法杖时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "冰霜法杖")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "装备冰霜法杖时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "闪电法杖")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "装备闪电法杖时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "治疗法杖")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "装备治疗法杖时禁用")

-- 其他武器
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "盾牌")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "装备盾牌时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "符文")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "装备符文时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "无武器")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "未装备武器时禁用")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "保留武器")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "装备保留武器类型时禁用")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "自定义屏蔽列表")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "自定义阻止列表")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "添加技能ID以阻止其使用。你也可以通过右键点击动作栏位来添加技能（需要重载界面）")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "技能ID")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "输入数字技能ID（例如：185805）")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "添加到阻止列表")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "已阻止技能：")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "启用自定义阻止列表")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "启用或禁用自定义阻止列表功能")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "检查你的SavedVariables文件：\n customBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "启用阻止列表的生命值检查")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "启用后，阻止列表中的技能只有在生命值高于阈值时才会被阻止。")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "阻止列表的生命值阈值 (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "只有当生命值高于此百分比时，阻止列表中的技能才会被阻止。")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "自定义重新施放阻止列表")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "添加技能ID以阻止其重新施放，直到剩余效果时间低于阈值。你也可以通过右键点击动作栏位来添加技能（需要重载界面）。")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "技能ID")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "输入数字技能ID（例如：185805）")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "添加到重新施放阻止列表")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "重新施放阻止的技能：")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "启用自定义重新施放阻止列表")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "启用或禁用自定义重新施放阻止列表功能")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "重新施放阻止时间 (秒)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "时间（秒），低于此值时重新施放阻止列表中的技能可以再次施放（1.0 = 1秒）")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "检查你的SavedVariables文件：\n customRecastBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "启用重新施放阻止列表的生命值检查")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "启用后，重新施放阻止列表中的技能只有在生命值高于阈值时才会被阻止。")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "重新施放阻止列表的生命值阈值 (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "只有当生命值高于此百分比时，重新施放阻止列表中的技能才会被阻止。")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "技能ID已被添加/移除。如果您不想再添加或移除更多技能，请重新加载界面以便显示更改。")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "重新加载界面")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "稍后")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "确定")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "错误：请输入有效的技能ID")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "技能ID不存在")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "技能ID已在阻止列表中")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "基于资源的阻止列表")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "添加技能ID以在主要资源（魔力或耐力）低于阈值时阻止它们。您也可以通过右键点击动作条槽位添加技能（需要重新加载界面）。")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "启用基于资源的阻止列表")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "启用或禁用基于资源的阻止列表功能")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "启用资源检查")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "启用后，资源阻止列表中的技能仅当您的主要资源（魔力或耐力）高于阈值时才会被阻止。")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "资源阈值 (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "资源阻止列表中的技能仅当您的主要资源（魔力或耐力）高于此百分比时才会被阻止。")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "技能：")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "魔力检查")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "为此技能启用基于魔力的阻止")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "当魔力低于阈值时阻止")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "当魔力低于阈值时阻止技能（取消勾选以仅在低于时允许）")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "魔力阈值 (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "魔力百分比阈值")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "耐力检查")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "为此技能启用基于耐力的阻止")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "当耐力低于阈值时阻止")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "当耐力低于阈值时阻止技能（取消勾选以仅在低于时允许）")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "耐力阈值 (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "耐力百分比阈值")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")

ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "切换模式（严格/智能/无）")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "切换自定义阻止列表")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "切换自定义重新施放阻止列表")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "切换副栏功能停用")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "切换副栏轻击辅助停用")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "切换处决检查")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "移除")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "将此技能从阻止列表中移除（需要/reloadui）")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "设置模式")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "选择设置是此账户下的所有角色共享（账号通用）还是为每个角色单独保存（每个角色）。")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "账号通用")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "每个角色")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "设置模式已更改。是否重新加载界面以应用更改？")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "战斗中屏蔽上一个菜单")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "防止在战斗中打开上一个菜单 (ALT)。")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "战斗中屏蔽角色菜单")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "防止在战斗中打开角色菜单 (C)。")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "显示全局冷却时间 (GCD)")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "在动作条上方显示 GCD 指示器（由 ZOS 提供）。")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "仅在战斗中使用阻止列表")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "所有自定义阻止列表仅在战斗中生效。战斗外所有阻止列表均被禁用。")

-- =============================================================================
-- === END OF CHINESE LOCALIZATION =============================================
-- =============================================================================