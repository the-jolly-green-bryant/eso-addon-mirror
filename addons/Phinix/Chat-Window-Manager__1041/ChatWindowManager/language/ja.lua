local CWMAddon = _G['CWMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- General strings
L.CWMAddon_Reload			= "UIをリロード"
L.CWMAddon_Clear			= "チャットをクリア"
L.CWMAddon_ClearT			= "現在のチャットウィンドウを消去します."
L.CWMAddon_Toggle			= "チャットウィンドウの切り替え"
L.CWMAddon_Online			= "オンラインステータスを切り替えます"
L.CWMAddon_RBox				= "UIをリロードしますか？"

-- Settings panel
L.CWMAddon_Title			= "チャットウィンドウマネージャー"
L.CWMAddon_AutoHide			= "チャットウィンドウを自動的に隠す"
L.CWMAddon_AutoHideT		= "ログイン、ゾーンの変更、またはUIのリロード時にチャットウィンドウを最小化します."
L.CWMAddon_RemState			= "チャットの状態を覚えておいてください"
L.CWMAddon_RemStateT		= "ロード画面間で以前のチャット状態を維持して、次のオプションを上書きします。"
L.CWMAddon_RButton			= "リロード/クリアボタンを追加"
L.CWMAddon_RButtonT			= "チャットウィンドウにボタンを追加してUIをリロードするか、Shiftキーを押しながらクリックして現在のチャットをクリアします。"
L.CWMAddon_ROffset			= "リロードボタンオフセット"
L.CWMAddon_ROffsetT			= "チャットが最大化されたとき（他のアドオンとの互換性のために）リロードボタンの水平位置を変更します。"
L.CWMAddon_RConfirm			= "リロードUIを確認"
L.CWMAddon_RConfirmT		= "誤ってリロードしないように、[Reload UI]ボタンをクリックしたときに確認ボックスを追加します。"
L.CWMAddon_SButton			= "プレーヤーのステータスメニューを追加"
L.CWMAddon_SButtonT			= "プレーヤーのオンラインステータス選択メニューをチャットウィンドウに追加します。"
L.CWMAddon_SChat			= "チャットでのステータス切り替え"
L.CWMAddon_SChatT			= "キーバインドまたはその他の方法で変更されたときに、プレーヤーのオンラインステータスをチャットに表示します。"
L.CWMAddon_SOffset			= "ステータスオフセット"
L.CWMAddon_SOffsetT			= "チャットが最大化されたとき（他のアドオンとの互換性のために）オンラインステータスインジケータの水平位置を変更します。"
L.CWMAddon_Extras			= "追加オプション"
L.CWMAddon_DConfirm			= "単純な削除の確認"
L.CWMAddon_DConfirmT		= "特定のものを削除するときに「DELETE」と入力する必要がなくなります。 代わりに、[はい]または[いいえ]をクリックするためのボックスが表示されます。"
L.CWMAddon_HideFriend		= "友達ログイン/友達を隠すログイン＆ログアウト"
L.CWMAddon_HideFriendT		= "チャットに登場するから防ぐフレンドログイン＆ログアウトステータスメッセージ。"
L.CWMAddon_TutorialOff		= "チュートリアルの無効化"
L.CWMAddon_TutorialOffT		= "ログイン時 (およびこのオプションを有効にした場合) にポップアップ チュートリアルを自動的に無効にします。 ゲームプレイ設定から再度有効にすることができます。"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(CWMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function CWMAddon:GetLanguage() -- set new language return
		return L
	end
end
