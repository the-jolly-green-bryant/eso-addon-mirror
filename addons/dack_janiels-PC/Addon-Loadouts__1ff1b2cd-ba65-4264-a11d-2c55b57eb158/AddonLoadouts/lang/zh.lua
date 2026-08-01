local strings =
{
    SI_ADDONLOADOUTS_LOADOUTS = "配置方案",
    SI_ADDONLOADOUTS_SAVE_CURRENT = "将当前状态另存为新方案",
    SI_ADDONLOADOUTS_APPLY_LOADOUT = "应用方案",
    SI_ADDONLOADOUTS_APPLY_LOADOUT_TOOLTIP = "选择要应用的已保存方案，然后重新加载界面。",
    SI_ADDONLOADOUTS_LOAD = "加载",
    SI_ADDONLOADOUTS_DELETE = "删除",
    SI_ADDONLOADOUTS_NEW_LOADOUT_NAME = "新方案名称",
    SI_ADDONLOADOUTS_APPLY = "应用",
    SI_ADDONLOADOUTS_RELOADING = "方案已应用。正在重新加载界面…",
    SI_ADDONLOADOUTS_NO_LOADOUTS = "没有已保存的方案。请在设置中将当前插件状态另存为新方案。",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE = "更新当前方案",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NAMED = "用当前已启用的插件覆盖「%s」（上次应用的方案）。",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NONE = "请先应用一个方案，然后再用当前选择更新它。",
    SI_ADDONLOADOUTS_MOVE_UP = "上移",
    SI_ADDONLOADOUTS_MOVE_DOWN = "下移",
    SI_ADDONLOADOUTS_ORGANIZE = "整理方案",
    SI_ADDONLOADOUTS_ORGANIZE_TITLE = "整理方案",
    SI_ADDONLOADOUTS_LOADOUT_TOOLTIP_EMPTY = "（此方案中没有启用的插件。）",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
