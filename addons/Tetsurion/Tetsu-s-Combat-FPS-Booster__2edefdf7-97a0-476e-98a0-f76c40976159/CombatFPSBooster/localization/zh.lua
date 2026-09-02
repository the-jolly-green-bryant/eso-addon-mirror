CombatFPSBooster = CombatFPSBooster or {}
CombatFPSBooster.L = CombatFPSBooster.L or {}

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
    CombatFPSBooster.L.TITLE          = "Tetsu's Combat FPS Booster"
    CombatFPSBooster.L.HIDE_INSTANCE   = "整个副本隐藏 HUD"
    CombatFPSBooster.L.HIDE_INSTANCE_TT= "开启后：在队伍副本、试炼、竞技场或无尽档案中，罗盘和任务追踪全程隐藏。经验、掉落和中央提示仍只在战斗中隐藏。小型洞穴和公共地下城不生效。"

    CombatFPSBooster.L.WHOLE_WHERE       = "“整个副本”模式生效区域"
    CombatFPSBooster.L.WHOLE_WHERE_TT    = "在勾选的区域，战斗间隙也隐藏罗盘和任务追踪（需同时开启对应选项）。经验、金币、掉落和中央提示仍只在战斗中隐藏。在西罗帝尔不会用此模式隐藏罗盘。"
    CombatFPSBooster.L.WHOLE_DUNGEON     = "副本与试炼"
    CombatFPSBooster.L.WHOLE_DUNGEON_TT  = "队伍副本和试炼。"
    CombatFPSBooster.L.WHOLE_ARENA       = "竞技场"
    CombatFPSBooster.L.WHOLE_ARENA_TT    = "漩涡、龙星、瓦特什兰、黑玫瑰。"
    CombatFPSBooster.L.WHOLE_ARCHIVE     = "无尽档案"
    CombatFPSBooster.L.WHOLE_ARCHIVE_TT  = "无尽档案挑战。"
    CombatFPSBooster.L.WHOLE_BG          = "战场"
    CombatFPSBooster.L.WHOLE_BG_TT       = "战场对局。此处不会切换插件预设。"
    CombatFPSBooster.L.WHOLE_CYRO        = "西罗帝尔与帝都"
    CombatFPSBooster.L.WHOLE_CYRO_TT     = "联盟战争。罗盘保持显示；战斗间隙只能继续隐藏任务追踪。"
    CombatFPSBooster.L.PRESET_APPLY_PVP  = "Combat FPS Booster：无法在西罗帝尔或战场中应用预设。"
    CombatFPSBooster.L.HIDE_COMPASS   = "战斗中隐藏罗盘"
    CombatFPSBooster.L.HIDE_COMPASS_TT= "在战斗中完全隐藏顶部罗盘，以减轻 CPU 负担。"
    CombatFPSBooster.L.HIDE_QUESTS    = "战斗中隐藏任务追踪"
    CombatFPSBooster.L.HIDE_QUESTS_TT = "在战斗中隐藏右侧的任务列表。"
    CombatFPSBooster.L.HIDE_ALERTS    = "战斗中隐藏经验/金币提示"
    CombatFPSBooster.L.HIDE_ALERTS_TT = "仅在战斗中隐藏经验、金币和掉落。整个副本模式不会在战斗之间继续隐藏它们。"
    CombatFPSBooster.L.FILTER_MASTER    = "副本中只保留需要的插件"
    CombatFPSBooster.L.FILTER_MASTER_TT = "按角色过滤。进入队伍副本、试炼、竞技场或无尽档案时保存当前插件组合，只启用勾选的插件并重载界面。离开后恢复。洞穴和公共地下城不生效。"
    CombatFPSBooster.L.FILTER_ITEM_TT   = "开 = 在副本中保留该插件。关 = 在副本中关闭。上方总开关关闭时不可改。"
    CombatFPSBooster.L.FILTER_EMPTY_WARN= "Combat FPS Booster：过滤已开，但没有勾选任何插件。未做更改。"
    CombatFPSBooster.L.FILTER_APPLY     = "Combat FPS Booster：正在启用插件预设 "
    CombatFPSBooster.L.FILTER_APPLY_TAIL = "，正在重载界面。"
    CombatFPSBooster.L.FILTER_RESTORE   = "Combat FPS Booster：正在恢复之前的插件设置，正在重载界面。"
    CombatFPSBooster.L.FILTER_NOAPI     = "Combat FPS Booster：无法更改插件状态。不会再次重载。"
    CombatFPSBooster.L.FILTER_SECTION   = "副本插件"
    CombatFPSBooster.L.FILTER_SECTION_TT= "副本或试炼中保持启用的已安装插件。"
    CombatFPSBooster.L.PRESET_SELECT    = "预设"
    CombatFPSBooster.L.PRESET_SELECT_TT = "已保存的插件组合。预设对整个账号生效。"
    CombatFPSBooster.L.PRESET_NAME      = "预设名称"
    CombatFPSBooster.L.PRESET_NAME_TT   = "保存用的名称。同名会覆盖该预设。"
    CombatFPSBooster.L.PRESET_SAVE      = "保存预设"
    CombatFPSBooster.L.PRESET_SAVE_BTN  = "保存"
    CombatFPSBooster.L.PRESET_SAVE_TT   = "把当前开关保存到这个名称。"
    CombatFPSBooster.L.PRESET_DELETE    = "删除预设"
    CombatFPSBooster.L.PRESET_DELETE_BTN= "删除"
    CombatFPSBooster.L.PRESET_DELETE_TT = "删除当前预设。最后一个预设不能删除。"
    CombatFPSBooster.L.PRESET_DIVIDER   = "──────── 插件 ────────"
    CombatFPSBooster.L.PRESET_SAVED     = "Combat FPS Booster：已保存预设："
    CombatFPSBooster.L.PRESET_DELETED   = "Combat FPS Booster：已删除预设："
    CombatFPSBooster.L.PRESET_LAST      = "Combat FPS Booster：不能删除最后一个预设。"
    CombatFPSBooster.L.PRESET_NOW       = "Combat FPS Booster：当前预设："
    CombatFPSBooster.L.HIDE_CSA       = "战斗中隐藏副本提示"
    CombatFPSBooster.L.HIDE_CSA_TT    = "仅在战斗中隐藏屏幕中央的大型游戏提示。不会在整个副本期间隐藏。"

end
