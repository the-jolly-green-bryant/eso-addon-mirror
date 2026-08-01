local PAC = PersonalAssistant.Constants
local PACOStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAConsume Menu --
    SI_PA_MENU_CONSUME_DESCRIPTION = "PAConsumeは毒の適用、または料理/飲料 & 経験値スクロールの消費を自動的に行うことができます",

    -- auto poison --
    SI_PA_MENU_CONSUME_POISON_HEADER = "毒の自動適用",
    SI_PA_MENU_CONSUME_POISON_ENABLE = "毒の自動適用を有効にする",
    SI_PA_MENU_CONSUME_POISON_ENABLE_T = "武器に毒が適用されていない場合、戦闘終了後に最もスタック数の多い毒を自動的に適用します",
    SI_PA_MENU_CONSUME_POISON_SMALL_STACKS_FIRST = "少量のスタックを優先して使用",
    SI_PA_MENU_CONSUME_POISON_SMALL_STACKS_FIRST_T = "インベントリの空き容量を確保するため、スタック数の少ない毒から優先して使用します",
    
    -- auto potion --
    SI_PA_MENU_CONSUME_POTION_HEADER = "ポーションの自動スロット登録",
    SI_PA_MENU_CONSUME_POTION_ENABLE = "ポーションの自動スロット登録を有効にする",
    SI_PA_MENU_CONSUME_POTION_ENABLE_T = "選択されているクイックスロットにポーションがない場合、戦闘終了後に最もスタック数の多いポーションを自動的に登録します",
    SI_PA_MENU_CONSUME_POTION_SMALL_STACKS_FIRST = "少量のスタックを優先して使用",
    SI_PA_MENU_CONSUME_POTION_SMALL_STACKS_FIRST_T = "インベントリの空き容量を確保するため、スタック数の少ないポーションから優先して使用します",
	
    -- auto consume food & exp --
    SI_PA_MENU_CONSUME_FOOD_HEADER = "料理/飲料の自動消費",
    SI_PA_MENU_CONSUME_EXP_HEADER = "経験値スクロールの自動消費",
    SI_PA_MENU_CONSUME_CURRENT_FOOD_BUFF = "このキャラクターの現在の食事バフ: ",
    SI_PA_MENU_CONSUME_CURRENT_EXP_BUFF = "このキャラクターの現在の経験値バフ: ",
    SI_PA_MENU_CONSUME_LABEL_ON = "自動的に消費する",
    SI_PA_MENU_CONSUME_LABEL_OFF = "自動消費を停止する",
    SI_PA_MENU_CONSUME_USE_NUMBER_FOOD = "バッファ (終了前の秒数)",
    SI_PA_MENU_CONSUME_USE_NUMBER_FOOD_T = "現在のバフが切れる何秒前に食事バフを使用するか設定します。0〜600秒の間で数値を変更できます。",
    SI_PA_MENU_CONSUME_USE_NUMBER_EXP = "バッファ (終了後の秒数)",
    SI_PA_MENU_CONSUME_USE_NUMBER_EXP_T = "現在のバフが切れた何秒後に経験値バフを使用するか設定します。0〜600秒の間で数値を変更できます。",
    SI_PA_MENU_CONSUME_TURN_OFF_FOOD = "一時停止",
    SI_PA_MENU_CONSUME_TURN_OFF_FOOD_T = "対象の料理/飲料の消費を一時的に停止します",
    SI_PA_MENU_CONSUME_TURN_OFF_EXP = "一時停止",
    SI_PA_MENU_CONSUME_TURN_OFF_EXP_T = "対象の経験値バフの消費を一時的に停止します",


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAConsume poison--
    SI_PA_CHAT_CONSUME_POISON_MAIN = "メイン武器に以下が塗られました: ",
    SI_PA_CHAT_CONSUME_POISON_BACKUP = "サブ武器に以下が塗られました: ",
    
    -- PAConsume potion--
    SI_PA_CHAT_CONSUME_POTION = "現在のクイックスロットに以下が装備されました: ",
    
    -- PAConsume food & exp--
    SI_PA_CHAT_CONSUME_NO_FOOD = "料理が選択されていません。インベントリを開き、自動消費したい料理または飲料のスタックを右クリックして、「自動的に消費する」を選択してください。",
    SI_PA_CHAT_CONSUME_AUTO_EATING_OFF_BUT = "自動食事は無効化されています。ただし、優先する料理として <<1>> が選択されています。",
    SI_PA_CHAT_CONSUME_TO_ENABLE_EATING = "このキャラクターの自動食事を有効にするには、インベントリを開き、対象の料理または飲料を右クリックして、「自動的に消費する」を選択してください。",
    SI_PA_CHAT_CONSUME_LOOKS_LIKE = "<<1>> がメニューにあるようです。",
    SI_PA_CHAT_CONSUME_THIS_FOOD_WILL_BE_MINUTES = "これは現在の食事が切れる <<1[切れると同時/$d分前/$d分前]>> に消費されます。",
    SI_PA_CHAT_CONSUME_THIS_FOOD_WILL_BE_SECONDS = "これは現在の食事が切れる <<1[切れると同時/$d秒前/$d秒前]>> に消費されます。",
    SI_PA_CHAT_CONSUME_YOU_HAVE_ONLY = "バッグの中にあと <<1>> しか残っていません。",
    SI_PA_CHAT_CONSUME_YOU_HAVE = "バッグの中にあと <<1>> 残っています。",
    SI_PA_CHAT_CONSUME_WISH_STOP_EATING = "このキャラクターの自動食事を停止したい場合は、PAConsumeのメニューを使用してください。",
	
    SI_PA_CHAT_CONSUME_NO_EXP = "経験値バフが選択されていません。インベントリを開き、自動消費したい経験値スクロールのスタックを右クリックして、「自動的に消費する」を選択してください。",
    SI_PA_CHAT_CONSUME_AUTO_EXPING_OFF_BUT = "経験値バフの自動消費は無効化されています。ただし、優先する経験値バフとして <<1>> が選択されています。",
    SI_PA_CHAT_CONSUME_TO_ENABLE_EXPING = "このキャラクターの経験値バフ自動消費を有効にするには、インベントリを開き、対象の経験値スクロールを右クリックして、「自動的に消費する」を選択してください。",
    SI_PA_CHAT_CONSUME_THIS_EXP_WILL_BE_MINUTES = "これは現在の経験値バフが切れてから <<1[切れると同時/$d分後/$d分後]>> に消費されます。",
    SI_PA_CHAT_CONSUME_THIS_EXP_WILL_BE_SECONDS = "これは現在の経験値バフが切れてから <<1[切れると同時/$d秒後/$d秒後]>> に消費されます。",
    SI_PA_CHAT_CONSUME_WISH_STOP_EXPING = "このキャラクターの経験値バフ自動消費を停止したい場合は、PAConsumeのメニューを使用してください。",

    SI_PA_CHAT_CONSUME_FOOD_WILL_BE_CONSUMED = "料理は現在の食事が切れる <<1>> 秒前に自動消費されます。",
    SI_PA_CHAT_CONSUME_EXP_WILL_BE_CONSUMED = "経験値バフは現在の経験値効果が切れてから <<1>> 秒後に自動消費されます。",
    
    SI_PA_CHAT_CONSUME_HAS_BEEN_AUTOMATICALLY_CONSUMED = " が自動的に消費されました。",
    SI_PA_CHAT_CONSUME_BUT_HAVE_ZERO = "<<1>> が自動消費に設定されていますが、バッグ内に1つもありません。",

    SI_PA_CHAT_CONSUME_FOOD_EXPIRE_SECONDS = "現在の食事効果はあと <<1[$d秒/$d秒/$d秒]>> で切れます。",
    SI_PA_CHAT_CONSUME_FOOD_EXPIRE_MINUTES = "現在の食事効果はあと <<1[$d分/$d分/$d分]>> で切れます。",
    SI_PA_CHAT_CONSUME_EXP_EXPIRE_SECONDS = "現在の経験値バフ効果はあと <<1[$d秒/$d秒/$d秒]>> で切れます。",
    SI_PA_CHAT_CONSUME_EXP_EXPIRE_MINUTES = "現在の経験値バフ効果はあと <<1[$d分/$d分/$d分]>> で切れます。",
}

for key, value in pairs(PACOStrings) do
    SafeAddString(_G[key], value, 1)
end


local PACOGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    --SI_PA_CHAT_Consume_CHARGE_WEAPON = "%s (%d%% --> %d%%) - %s",
}

for key, value in pairs(PACOGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end