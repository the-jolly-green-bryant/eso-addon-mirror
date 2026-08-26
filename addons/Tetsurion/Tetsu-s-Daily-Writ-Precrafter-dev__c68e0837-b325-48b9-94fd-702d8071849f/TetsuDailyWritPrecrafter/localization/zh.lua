TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
local L = TetsuDailyWritPrecrafter.L
if not L then return end

L.TITLE                   = "|cFFD700Tetsu's|r Daily Writ Precrafter"

L.OPTIONS_SECTION_LABEL   = "自动化"
L.OPTIONS_SECTION_TT      = "适合手柄的安全自动化选项。"
L.AUTO_QUEST_LABEL        = "自动接取并交付制造委托"
L.AUTO_QUEST_TT           = "从告示板接取委托，并在箱子处自动交付。"
L.AUTO_BOX_LABEL          = "自动打开奖励箱"
L.AUTO_BOX_TT             = "每日委托奖励容器一进入背包即自动打开。"

L.PRECRAFT_SECTION_LABEL  = "预制造（本角色）"
L.PRECRAFT_SECTION_TT     = "设置按角色分别保存。"
L.PRECRAFT_ENABLED_LABEL  = "为未来预制造"
L.PRECRAFT_ENABLED_TT     = "开启时：R3 按每日轮换预制造多日物品。关闭时：R3 只制造当前委托所需物品。"
L.PRECRAFT_DAYS_LABEL     = "提前天数"
L.PRECRAFT_DAYS_TT        = "预制造多少天（含今天）。滑块 1–10。"

L.KEYBIND_PRECRAFT        = "|c00FF00[R3]|r 预制造 <<1>> 天（<<2>> 件）"
L.KEYBIND_QUEST_CRAFT     = "|c00FF00[R3]|r 制造当前委托（<<1>> 件）"
L.KEYBIND_NOTHING         = "|c888888[R3]|r 无需制造"

L.CONFIRM_TITLE_PRECRAFT  = "预制造每日委托"
L.CONFIRM_PROMPT_PRECRAFT = "预制造 <<1>> 天的物品？（共 <<2>> 件）"
L.CONFIRM_TITLE_QUEST     = "制造当前委托"
L.CONFIRM_PROMPT_QUEST    = "制造当前委托所需物品？（<<1>> 件）"

L.PROGRESS_CRAFTING       = "制造中..."
L.PROGRESS_STATUS         = "已处理：<<1>> / <<2>>"

L.ERR_BAG_FULL            = "背包空间不足（约需 <<1>> 个空位）。"
L.ERR_NO_STYLE            = "背包或制造袋中未找到已知样式材料。"
L.ERR_MISSING_RUNES       = "缺少附魔符文（效力 / 精华 / Ta）。"
L.ERR_CANNOT_CRAFT        = "无法制造 <<1>>（缺少材料、样式或技能）。"
L.ERR_CRAFT_FAILED        = "制造失败（<<1>>/<<2>>）。已跳过。"
L.ERR_NOT_AT_STATION      = "你不在制造台旁。"
L.ERR_PROV_SKIP_UNKNOWN   = "跳过（未学会配方）：<<1>>"
L.ERR_NOTHING_TO_CRAFT    = "没有可制造的物品。"
L.ERR_NO_ACTIVE_WRIT      = "此制造台没有进行中的制造委托。"

L.PRECHECK_HEADER         = "|cFF6666[Tetsu's Daily Writ Precrafter]|r 材料不足，已取消制造："
L.PRECHECK_JOBS           = "队列任务数：|cFFFFFF<<1>>|r"
L.PRECHECK_LINE           = "  - |cFFD700<<1>>|r：需要 |cFFFFFF<<2>>|r，拥有 |cFFFFFF<<3>>|r（|cFF6666-<<4>>|r）"
L.PRECHECK_ABORT          = "补齐缺失材料后再次按 R3。"
L.PRECHECK_OK             = "材料检查通过。正在制造 |c00FF00<<1>>|r 件物品..."

L.USING_QUEST_DATA        = "使用当前委托数据。"
L.USING_PREDICTED         = "预制造模式：<<1>> 天的每日轮换。"
L.CRAFT_DONE              = "完成。已制造：|c00FF00<<1>>|r，跳过：|cFFFF00<<2>>|r。"
L.PATTERN_TODAY           = "今日模板：|cFFD700<<1>>|r"
