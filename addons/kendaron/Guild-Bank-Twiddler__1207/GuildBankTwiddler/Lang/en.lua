
GuildBankTwiddlerLanguage = {}

local function l(obj)
  GuildBankTwiddlerLanguage.language[#GuildBankTwiddlerLanguage.language + 1] = obj
  return #GuildBankTwiddlerLanguage.language
end


GuildBankTwiddlerLanguage.language = {
  
}


GBQC_BUTTON_TWIDDLE_TOOLTIP = l("Twiddle")

GBT_CHAT_OPTION_KEY = l("gbt")
GBT_CHAT_OPTION_HIDE_OFF = l("hideoff")
GBT_CHAT_OPTION_HIDE_OFF_DESCRIPTION = l(" switch autohide off")
GBT_CHAT_OPTION_HIDE_ON = l("hideon")
GBT_CHAT_OPTION_HIDE_ON_DESCRIPTION = l(" switch autohide on")
GBT_CHAT_OPTION_INVALID = l("invalid option")
GBT_CHAT_OPTION_SORT_INDEX = l("sortindex")
GBT_CHAT_OPTION_SORT_INDEX_DESCRIPTION = l(" sort guild list by guild index")
GBT_CHAT_OPTION_SORT_ALPHA = l("sortalpha")
GBT_CHAT_OPTION_SORT_ALPHA_DESCRIPTION = l(" sort guild list alphabetically")
