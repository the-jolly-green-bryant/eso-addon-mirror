local strings = {
    SI_HAA_PANEL_NAME               = "Heavy Attack Alerter",
    SI_HAA_COMBAT_ONLY_NAME         = "仅在战斗中显示",
    SI_HAA_COMBAT_ONLY_TIP          = "脱战时自动隐藏护盾图标。",
    SI_HAA_SOUND_NAME               = "警报提示音",
    SI_HAA_SOUND_TIP                = "敌方准备重击时的提示音效。",
    SI_HAA_SOUND_CHAMPION           = "钟鸣 (冠军点数)",
    SI_HAA_SOUND_DUEL               = "决斗 (决斗开始)",
    SI_HAA_SOUND_QUEST              = "胜利 (任务完成)",
    SI_HAA_SOUND_NONE               = "静音",
    SI_HAA_ALPHA_NAME               = "绿盾透明度 (%)",
    SI_HAA_ALPHA_TIP                = "常规状态下绿盾的不透明度。",
    SI_HAA_ALERT_ALPHA_NAME         = "红盾透明度 (%)",
    SI_HAA_ALERT_ALPHA_TIP          = "重击警报时红盾的不透明度。",
    SI_HAA_SIZE_NAME                = "图标尺寸 (px)",
    SI_HAA_OFFSET_X_NAME            = "水平偏移 (X)",
    SI_HAA_OFFSET_Y_NAME            = "垂直偏移 (Y)",
    SI_HAA_TEST_BUTTON_NAME         = "测试警报",
    SI_HAA_TEST_BUTTON_TIP          = "触发1.5秒的测试警报及提示音，以便预览当前设置。",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end