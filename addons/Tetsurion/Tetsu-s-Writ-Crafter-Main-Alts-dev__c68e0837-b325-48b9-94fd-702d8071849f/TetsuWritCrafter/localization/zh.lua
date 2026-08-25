TetsuWritCrafter = TetsuWritCrafter or {}

local function IsChinese()
    local lang = GetCVar("language.2")
    if not lang or lang == "" then lang = GetCVar("Language.lang") end
    if (not lang or lang == "") and GetLanguage then lang = GetLanguage() end
    if lang then
        lang = string.lower(lang)
        return lang == "zh" or string.sub(lang, 1, 2) == "zh"
    end
    return false
end

if IsChinese() then
    local L = TetsuWritCrafter.L
    L.TITLE                   = "|cFFD700Tetsu's|r Writ Crafter"
    L.ALTS_SECTION_LABEL      = "每日制作角色"
    L.ALTS_SECTION_TT         = "启用或禁用参与每日制作委托的角色。"
    L.CHAR_ENABLED_TT         = "为 <<1>> 启用每日预制作。"
    
    L.KEYBIND_CRAFT_ALL       = "|c00FF00[R3]|r 为所有人制作 (<<1>> 件)"
    L.CONFIRM_TITLE           = "批量制作委托"
    L.CONFIRM_PROMPT          = "是否为所有已启用的角色制作 <<1>> 件物品？"
    
    L.PROGRESS_CRAFTING       = "正在制作每日委托物品..."
    L.PROGRESS_BANK_DEPOSIT   = "银行：存入物品与奖励..."
    L.PROGRESS_BANK_WITHDRAW  = "银行：提取委托所需物品..."
    L.PROGRESS_STATUS         = "进度：<<1>> / <<2>>"
    
    L.ERR_NOT_ENOUGH_BANK     = "银行空间不足！需要：<<1>>，剩余：<<2>>。"
    L.ERR_BAG_FULL            = "背包空间不足！需要：<<1>>，剩余：<<2>>。"
    L.ERR_NOT_ENOUGH_MATS     = "材料不足！"
    
    L.SYNC_STATUS             = "已同步：|c00FF00<<1>> / <<2>>|r。需登录角色：|cFFFF00<<3>>|r"
    L.READY_BRIEFING          = "准备就绪！今日轮换：|cFFD700<<1>>|r。队列中角色数：|cFFD700<<2>>|r。"
end