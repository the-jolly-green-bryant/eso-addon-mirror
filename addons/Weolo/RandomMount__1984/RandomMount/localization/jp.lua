-- @Origami: WARNING! Some of the new translations here are done via Google Translate. Sorry!
local strings = {
    RM_OP_HEADING1 = "マウントオプション",
    RM_OP_HEADING2 = "ペットオプション",
    RM_OP_HEADING3 = "マウント",
    RM_OP_HEADING4 = "ペット",
    RM_OP_HEADING6 = "スキントオプション",
    RM_OP_HEADING7 = "スキンス",
    RM_OP_ACCOUNT = "アカウント全体の設定を使用する",
    RM_OP_MOUNTS_ENABLE = "ランダムマウントを有効にする",
    RM_OP_MOUNTS_ENABLE_PVP = "PvPでランダムマウントを有効にする",
    RM_OP_MOUNTS_MULTI_GROUPED = "グループ化されている間はマルチライダーを好む",
    RM_OP_MOUNTS_MULTI_COMPANION = "コンパニオン アウト中はマルチライダーを好む",
    RM_OP_ACTIVATE_ZONE = "面積変化のランダム化",
    RM_OP_ACTIVATE_DISMOUNT = "降車のランダム化",
    RM_OP_PETS_ENABLE = "ランダムペットを有効にする",
    RM_OP_SKINS_ENABLE = "ランダムスキンを有効にする",
    RM_OP_DELAY = "遅れ",
    RM_OP_DELAY_TT = "ランダムマウントとペットの間の遅延とスキンス",
    RM_OP_ALLOW_DEFAULT = "デフォルトのスキンを許可する",
    RM_OP_PETS_UNSUMMON_PVP = "プレイヤー対プレイヤーゾーンでの召喚解除",
    RM_OP_PETS_UNSUMMON_DUNGEON = "ダンジョンゾーンで召喚解除",
    RM_OP_PETS_UNSUMMON_GROUP = "グループ化中に召喚解除"
}

if GetString(RM_OP_HEADING1):len() == 0 then
    for key, value in pairs(strings) do
        SafeAddVersion(key, 1)
        ZO_CreateStringId(key, value)
    end
end
