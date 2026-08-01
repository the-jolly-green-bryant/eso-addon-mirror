--[[
Updated by Lykeion
Filename: jp.lua
Version: 6.0.0
Translate: Lionas
]]--

local strings = {
SI_BINDING_NAME_SUPERSTAR_SHOW_PANEL			= "SuperStarをトグル",
	
SUPERSTAR_RESPECFAV_SP							= "スキルを振りなおす",
SUPERSTAR_RESPECFAV_CP							= "チャンピオンポイントを振りなおす",
SUPERSTAR_SAVEFAV									= "お気に入りを登録",
SUPERSTAR_VIEWFAV									= "お気に入りを見る",
SUPERSTAR_REMFAV									= "お気に入りを削除",
SUPERSTAR_FAVNAME									= "お気に入りの名前",

SUPERSTAR_CSA_RESPECDONE_TITLE					= "振り直しを完了しました",
SUPERSTAR_CSA_RESPECDONE_POINTS				= "<<1>> 個のスキルを構成完了",
SUPERSTAR_CSA_RESPEC_INPROGRESS				= "振り直し中",
SUPERSTAR_CSA_RESPEC_TIME						= "この操作はおよそ <<1>> <<1[分]>>　かかります",

SUPERSTAR_RESPEC_SPTITLE							= "テンプレートに従って、|cFF0000スキル|rを振りなおそうとしています :\n\n <<1>>",
SUPERSTAR_RESPEC_CPTITLE							= "テンプレートに従って、|cFF0000チャンピオンポイント|r を振りなおそうとしています :\n\n <<1>>",

SUPERSTAR_RESPEC_ERROR1							= "スキルポイントの振り直しができません, 不正なクラス",
SUPERSTAR_RESPEC_ERROR2							= "警告: 現在のスキルポイントがテンプレートの条件より少ない。リスペックが不完全な可能性があります",
SUPERSTAR_RESPEC_ERROR3							= "警告: このビルドで定義された種族はあなたのものではありません, 種族ポイントは設定されません",
SUPERSTAR_RESPEC_ERROR5							= "チャンピオンポイントを振りなおせません。あなたはチャンピオンではありません。",
SUPERSTAR_RESPEC_ERROR6							= "チャンピオンポイントを振りなおせません。十分なチャンピオンポイントがありません。",
	
SUPERSTAR_RESPEC_SKILLLINES_MISSING			= "警告: スキルラインがアンロックされていないため、スキルポイントは設定されません",
SUPERSTAR_RESPEC_CPREQUIRED						= "このテンプレートは <<1>> チャンピオンポイント使用します。",
	
SUPERSTAR_RESPEC_INPROGRESS1					= "クラススキルセット",
SUPERSTAR_RESPEC_INPROGRESS2					= "武器スキルセット",
SUPERSTAR_RESPEC_INPROGRESS3					= "防具スキルセット",
SUPERSTAR_RESPEC_INPROGRESS4					= "ワールドスキルセット",
SUPERSTAR_RESPEC_INPROGRESS5					= "ギルドスキルセット",
SUPERSTAR_RESPEC_INPROGRESS6					= "同盟戦争スキルセット",
SUPERSTAR_RESPEC_INPROGRESS7					= "種族スキルセット",
SUPERSTAR_RESPEC_INPROGRESS8					= "トレードスキルセット",

SUPERSTAR_IMPORT_MENU_TITLE						= "インポート",
SUPERSTAR_FAVORITES_MENU_TITLE					= "お気に入り",
SUPERSTAR_RESPEC_MENU_TITLE						= "振り直し",
SUPERSTAR_SCRIBING_MENU_TITLE				= "書記シミュレーター",

SUPERSTAR_XML_BUTTON_SHARE				= "共有SuperStar (/sss)",
SUPERSTAR_XML_BUTTON_SHARE_LINK				= "ゲーム内リンクで共有する (/ssl)",

SUPERSTAR_DIALOG_SPRESPEC_TITLE				= "スキルポイントを設定",
SUPERSTAR_DIALOG_SPRESPEC_TEXT					= "選択されたテンプレートに従ってスキルポイントを設定しますか?",

SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TITLE	= "スキルビルダーのリセット",
SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TEXT	= "属性と/またはチャンピオンポイントを含むスキルビルダーをリセットしようとしています。\n\nこれは値もリセットします。\n\nスキルをリセットしたい場合は、シンプルにそのアイコンを右クリックします。",

SUPERSTAR_DIALOG_CPRESPEC_NOCOST_TEXT		= "チャンピオンポイントを振りなおそうとしています。\n\nこの変更は無料です。",

SUPERSTAR_QUEUE_SCRIBING						= "書記キューに参加する",
SUPERSTAR_CLEAR_QUEUE							= "キューを空にする",

SUPERSTAR_DIALOG_QUEUE_REJECTED_TITLE			= "キューへの参加に失敗",
SUPERSTAR_DIALOG_QUEUE_REJECTED_TEXT			= "キューに追加されたスキルは、次に書記祭壇を使用するときに自動的に作成されます\n同じ魔法コーデックスを使用するキュー内の古いスキルは、新しいスキルに置き換えられます\n\n一部のスキルはまだアンロックされていないため、キューに追加できません",
SUPERSTAR_DIALOG_QUEUE_FOR_SCRIBING_TEXT		= "キューに追加されたスキルは、次に書記祭壇を使用するときに自動的に作成されます\n同じ魔法コーデックスを使用するキュー内の古いスキルは、新しいスキルに置き換えられます\n\n選択されたスキルがキューに追加される",
SUPERSTAR_DIALOG_CLEAR_QUEUE_TEXT		        = "キューは空になり\n\n次に書記祭壇を使用するときに自動的にスキルを作成することはできなくなります",
SUPERSTAR_DIALOG_MAJOR_UPDATE_TEXT              = "SuperStarがアップデート50に対応しました！\n\nアドオンが<<1>>表示をサポートするようになりました。\nSuperStar共有リンク機能も書き直され、より安定し、今後のクラス改修に対応できるようになりました。",

-- Chatbox Info:
SUPERSTAR_CHATBOX_PRINT			        		= "クリックして見る",
SUPERSTAR_CHATBOX_QUEUE_INFO			        = "|c215895[Super|cCC922FStar]|r キューには合計<<1>>個のスキルがあり、<<2>>個のインクが消費されると予想される、<<3>>を保持",
SUPERSTAR_CHATBOX_QUEUE_WARN			        = "|c215895[Super|cCC922FStar]|r キューには合計<<1>>個のスキルがあり、<<2>>個のインクが消費されると予想される、<<3>>を保持",
SUPERSTAR_CHATBOX_QUEUE_ABORTED		            = "|c215895[Super|cCC922FStar]|r 自動書記は中断のため終了しました。 キューが空になりました",
SUPERSTAR_CHATBOX_QUEUE_CANCELED		        = "|c215895[Super|cCC922FStar]|r インク不足のため、自動書記がキャンセルされました。 <<1>>が必要、<<2>>は保持",
SUPERSTAR_CHATBOX_TEMPLATE_OUTDATED		        = "|c215895[Super|cCC922FStar]|r テンプレートが古いため、再作成してください",
SUPERSTAR_CHATBOX_SUPERSTAR_OUTDATED		    = "|c215895[Super|cCC922FStar]|r 解決できないSuperStarリンク。あなたまたは相手が最新バージョンのSuperStarを使用していないか、リンク内の一部の文字がチャット検閲システムによってブロックされた可能性があります",

SUPERSTAR_XML_SKILL_BUILD				= 		"スキルビルダー",
SUPERSTAR_XML_SKILL_BUILD_EXPLAIN				= "ここで種族を選択してスキルビルドを開始しましょう。ビルドをテンプレートとして保存すれば、今後のリスペックに活用できます。\n\nサブクラス機能完全対応！任意のクラススキルラインをビルドに追加可能、リスペック時、SuperStarが自動的に使用可能な全クラススキルを検出・適用",
SUPERSTAR_SCENE_SKILL_RACE_LABEL				= "種族",

SUPERSTAR_XML_CUSTOMIZABLE						= "カスタム可能",
SUPERSTAR_XML_GRANTED								= "付与された",
SUPERSTAR_XML_TOTAL								= "合計",
SUPERSTAR_XML_BUTTON_FAV							= "お気に入り",
SUPERSTAR_XML_BUTTON_FAV_WITH_CP				= "CPで保存",
SUPERSTAR_XML_BUTTON_REINIT						= "再初期化",
SUPERSTAR_XML_BUTTON_EXPORT						= "エクスポート",
SUPERSTAR_XML_NEWBUILD							= "新しいビルド :",
SUPERSTAR_XML_BUTTON_RESPEC						= "振り直し",
SUPERSTAR_XML_BUTTON_START						= "START",

SUPERSTAR_XML_IMPORT_EXPLAIN					= "このフォームで他のビルドをインポートします\n\nビルドはチャンピオンポイント、スキルポイント、能力を含むことができます",
SUPERSTAR_XML_FAVORITES_EXPLAIN				= "保存されたテンプレートを使って自動的にリスペックすることができる。毎回異なるテンプレートを適用できるように、ベースとなるビルドをあらかじめ武器庫に保存しておくことをお勧めします。\n\nリスペックにCPが含まれる場合、ゴールドを消費することに注意してください。",

SUPERSTAR_XML_SKILLPOINTS						= "スキルポイント",
SUPERSTAR_XML_CHAMPIONPOINTS					= "チャンピオンポイント",

SUPERSTAR_XML_DMG									= "ダメージ",
SUPERSTAR_XML_CRIT									= "クリティカル / %",
SUPERSTAR_XML_PENE									= "貫通",
SUPERSTAR_XML_RESIST								= "耐性 / %",

--SUPERSTAR_MAELSTROM_WEAPON						= "メイルストローム",
SUPERSTAR_DESC_ENCHANT_MAX						= " 最大",

SUPERSTAR_DESC_ENCHANT_SEC						= " 秒",
SUPERSTAR_DESC_ENCHANT_SEC_SHORT				= " 秒",

SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG			= "魔法ダメージ",
SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG_SHORT	= "魔法ダメ",

SUPERSTAR_DESC_ENCHANT_BASH						= "バッシュ",
SUPERSTAR_DESC_ENCHANT_BASH_SHORT				= "バッシュ",

SUPERSTAR_DESC_ENCHANT_REDUCE					= " と 削減",
SUPERSTAR_DESC_ENCHANT_REDUCE_SHORT			= " と　削減",

SUPERSTAR_IMPORT_ATTR_DISABLED					= "能力を加える",
SUPERSTAR_IMPORT_ATTR_ENABLED					= "能力を外す",
SUPERSTAR_IMPORT_SP_DISABLED					= "スキルポイントを含む",
SUPERSTAR_IMPORT_SP_ENABLED						= "スキルポイントを外す",
SUPERSTAR_IMPORT_CP_DISABLED					= "チャンピオンポイントを加える",
SUPERSTAR_IMPORT_CP_ENABLED						= "チャンピオンポイントを外す",
SUPERSTAR_IMPORT_BUILD_OK						= "ビルドは正しい, 表示します!",
SUPERSTAR_IMPORT_BUILD_NO_SKILLS				= "このビルドはスキルセットを有していません。",
SUPERSTAR_IMPORT_BUILD_NOK						= "ビルドが不正, ハッシュをチェック",

SUPERSTAR_IMPORT_BUILD_LABEL					= "インポート:ハッシュを貼付",
SUPERSTAR_IMPORT_MYBUILD							= "マイビルド",

--SUPERSTAR_XML_SWITCH_PLACEHOLDER				= "オフバー用に武器を切り替え",

SUPERSTAR_XML_FAVORITES_HEADER_NAME				= "Name",
SUPERSTAR_XML_FAVORITES_HEADER_CP				= "CP",
SUPERSTAR_XML_FAVORITES_HEADER_SP				= "SP",
SUPERSTAR_XML_FAVORITES_HEADER_ATTR				= "Attr",
SUPERSTAR_EQUIP_SET_BONUS                          = "Set",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end