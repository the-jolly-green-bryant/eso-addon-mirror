strings = {
  TBUST_TRAITBUSTER = "形質バスター",
  TBUST_ACTIVATED = "有効化されました。オプションは%sを使用します。",
  TBUST_LONG_SINGULAR = "形質バスター: 研究可能な同じ形質を所有する他の1アイテム。",
  TBUST_SHORT_SINGULAR = "1調査可能な重複。",
  TBUST_LONG_PLURAL = "形質バスター: 研究可能な同じ形質を所有する%sつの他の項目。",
  TBUST_SHORT_PLURAL = "%sつの調査可能な重複。",
  TBUST_SLASH_TBUST = "/独裁者",
  TBUST_SLASH_ON = "に",
  TBUST_SLASH_OFF = "オフ",
  TBUST_SLASH_LONG = "長いです",
  TBUST_SLASH_SHORT = "ショート",
  TBUST_SLASH_GREET = "挨拶する",
  TBUST_SLASH_DEFAULT = "デフォルト",
  TBUST_MENU_TITLE = " -=-=-= メインメニュー =-=-=-",
  TBUST_MENU_ON = "= この文字のツールヒントを有効にします。 [デフォルト]",
  TBUST_MENU_OFF = "= この文字のツールヒントを無効にします。",
  TBUST_MENU_LONG = "= より説明的なツールチップ。 [デフォルト]",
  TBUST_MENU_SHORT = "= 短い簡略化されたツールチップ。",
  TBUST_MENU_GREET_ON = "= ログイングリーティングを有効にします。 [デフォルト]",
  TBUST_MENU_GREET_OFF = "= ログイングリーティングを無効にします。",
  TBUST_MENU_DEFAULT = "= デフォルト設定にリセットします。",
  TBUST_MENU_SELECT_ON = "この文字に対してツールチップが有効になっています。",
  TBUST_MENU_SELECT_OFF = "この文字のツールチップが無効です。",
  TBUST_MENU_SELECT_LONG = "ツールチップは長くなり、説明的になります。",
  TBUST_MENU_SELECT_SHORT = "ツールチップは短く簡潔です。",
  TBUST_MENU_SELECT_GREET_ON = "ログインの挨拶が表示されます。",
  TBUST_MENU_SELECT_GREET_OFF = "ログイングリーティングは表示されません。",
  TBUST_MENU_SELECT_DEFAULT = "デフォルト設定が読み込まれました。"
}

if GetString(TBUST_TRAITBUSTER):len() == 0 then
  for key,value in pairs(strings) do
    SafeAddVersion(key, 1)
    ZO_CreateStringId(key, value)
  end
end