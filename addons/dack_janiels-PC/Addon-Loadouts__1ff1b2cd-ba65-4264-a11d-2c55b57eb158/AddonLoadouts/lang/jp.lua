local strings =
{
    SI_ADDONLOADOUTS_LOADOUTS = "ロードアウト",
    SI_ADDONLOADOUTS_SAVE_CURRENT = "現在の設定を新しいロードアウトとして保存",
    SI_ADDONLOADOUTS_APPLY_LOADOUT = "ロードアウトを適用",
    SI_ADDONLOADOUTS_APPLY_LOADOUT_TOOLTIP = "適用するロードアウトを選んでから、UIを再読み込みしてください。",
    SI_ADDONLOADOUTS_LOAD = "ロード",
    SI_ADDONLOADOUTS_DELETE = "削除",
    SI_ADDONLOADOUTS_NEW_LOADOUT_NAME = "新規ロードアウト名",
    SI_ADDONLOADOUTS_APPLY = "適用",
    SI_ADDONLOADOUTS_RELOADING = "ロードアウトを適用しました。UIを再読み込みしています...",
    SI_ADDONLOADOUTS_NO_LOADOUTS = "ロードアウトは見つかりません。設定画面から現在のアドオン状態を新しいロードアウトとして保存しておいてください。",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE = "適用中のロードアウトを更新",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NAMED = "「%s」を、現在有効なアドオンで上書きします（最後に適用したロードアウト）。",
    SI_ADDONLOADOUTS_UPDATE_ACTIVE_TOOLTIP_NONE = "先にロードアウトを適用してください。その後、現在の選択で更新できます。",
    SI_ADDONLOADOUTS_MOVE_UP = "上へ",
    SI_ADDONLOADOUTS_MOVE_DOWN = "下へ",
    SI_ADDONLOADOUTS_ORGANIZE = "ロードアウトを整理",
    SI_ADDONLOADOUTS_ORGANIZE_TITLE = "ロードアウトを整理",
    SI_ADDONLOADOUTS_LOADOUT_TOOLTIP_EMPTY = "（このロードアウトで有効なアドオンはありません。）",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
