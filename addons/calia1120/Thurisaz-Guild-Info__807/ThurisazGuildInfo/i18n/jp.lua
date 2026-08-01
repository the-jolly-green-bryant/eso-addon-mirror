-- Copyright (c) 2014 User Froali from ESOUI.com
-- All Rights Reserved. If you want to use arts of my AddOns for your own work, please contact me first!

if (TI.locale == nil) then TI.locale = {} end
if (TI.locale.templates == nil) then TI.locale.templates = {} end
if (TI.locale.settings == nil) then TI.locale.settings = {} end
if (TI.locale.settings.tooltip == nil) then TI.locale.settings.tooltip = {} end

TI.locale["online"]="オンライン"
TI.locale["offline"] =  "オフライン"
TI.locale["away"] = "離れて"
TI.locale["dontdisturb"] =  "邪魔しないでください"
TI.locale["unknown"] =  "未知の"

TI.locale["CharNameHeader"] =   "キャラクター"

TI.locale.templates["status_change"] =  "<<1>> <<2>> は現在 <<3>> です"
TI.locale.templates["guild_left"] = "<<1>> が <<2>> から脱退しました"
TI.locale.templates["guild_joined"] =   "<<1>> が <<2>> に入会しました"
TI.locale.templates["new_level"] =  "<<1>> <<2>> がレベル <<3>> に到達しました"
TI.locale.templates["new_champion"] ="<<1>> <<2>> が <<3>> CPに到達しました"
TI.locale.templates["motd_changed"] =   "<<1>> の今日のひとことが変更されました:\r\n<<2>>"
TI.locale.templates["motd_startup"] =   "<<1>> の今日のひとこと:\r\n<<2>>"
TI.locale.templates["characterName_tooltip"] =  "メインキャラクター:"
   
--settings strings
-- General
TI.locale.settings["ThurisazCtrlP"] =   "Thurisaz Guild Info"
TI.locale.settings["TGI_SettingsGuildRosterHeader"] =   "ギルド名簿"
--Roster General
TI.locale.settings["TGI_SettingsCharNames"] =   "キャラクター名を表示"
TI.locale.settings.tooltip["TGI_SettingsCharNames"] =   "ギルド名簿にキャラクター名を表示します"

TI.locale.settings["ReloadWarning"] =   "UIをリロード"

-- Announces General
TI.locale.settings["TGI_SettingsAnnouncementsHeader"] = "アナウンス"

--ShowAnnouncements
TI.locale.settings["TGI_SettingsAnnounce"] ="アナウンスを表示"
TI.locale.settings.tooltip["TGI_SettingsAnnounce"] ="ギルドアクティビティについてのメッセージを表示します"
  
-- Unlock Announcement Window
TI.locale.settings["TGI_SettingsAnnounceDisplayMoveable"] = "アンロックウィンドウ"
TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayMoveable"] = "アナウンスウィンドウをアンロックし、移動したり表示サイズを変更可能にします。"

-- How to display Announcements
TI.locale.settings["TGI_SettingsAnnounceType"] ="表示するアナウンスのタイプ"
TI.locale.settings.tooltip["TGI_SettingsAnnounceType"] ="アナウンスをどのように表示するかを設定します"
   
-- Use Colored Display Messages?
TI.locale.settings["DisplayColorMode"] ="色付けされたメッセージ表示"
TI.locale.settings.tooltip["DisplayColorMode"] ="メッセージ表示に色を付けますか？"

-- AnnounceDisplayAlignment
TI.locale.settings["TGI_SettingsAnnounceDisplayAlign"] ="水平アライメント"
TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayAlign"] ="HUD内のアナウンスの水平アライメントを設定します"

-- Show time on chat announcements
TI.locale.settings["TGI_SettingsShowTimestamp"] =   "チャットに時間を表示"
TI.locale.settings.tooltip["TGI_SettingsShowTimestamp"] =   "チャットアナウンスにタイムスタンプをプリフィクスとして表示します"

-- Set how long to show Announcement
TI.locale.settings["TGI_SettingsAnnounceDisplayTime"] = "アナウンス表示時間"
TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayTime"] = "アナウンスをどのくらいの間表示しますか？"
 
-- Announcement Font Settings
TI.locale.settings["TGI_SettingsAnnounceFont"] ="アナウンスフォント"
TI.locale.settings.tooltip["TGI_SettingsAnnounceFont"] ="HUD内で表示するアナウンスのフォントを選択します"
 
-- Announcement Display Width
TI.locale.settings["TGI_SettingsAnnounceDisplayWidth"] ="アナウンス幅"
TI.locale.settings.tooltip["TGI_SettingsAnnounceDisplayWidth"] ="HUD内でのアナウンスの幅を設定します"
 
-- Player Display Name Preferences
TI.locale.settings["TGI_SettingsNameFormat"] =  "プレイヤー名表示"
TI.locale.settings.tooltip["TGI_SettingsNameFormat"] =  "アナウンス内で表示される名前のフォーマットを設定します"
   
-- Set Player Name Color
TI.locale.settings["TGI_SettingsPlayerNameColor"] = "プレイヤー名カラー"
TI.locale.settings.tooltip["TGI_SettingsPlayerNameColor"] = "アナウンス内で表示されるプレイヤー名の色を設定します"
 
 
-- Per Guild Settings
TI.locale.settings["TGI_SettingsGuildsHeader"] ="ギルド設定"
 
-- Show Announcements
TI.locale.settings["TGI_SettingsOverallAnnounceGuild"] ="アナウンスを表示"
TI.locale.settings.tooltip["TGI_SettingsOverallAnnounceGuild"] ="このギルドのアクティビティについてのシステムメッセージを表示します（今日のひとことを含む）"
 
-- Guild Name Abbreviation
TI.locale.settings["TGI_SettingsAbbreviationAnnounceGuild"] =   "ギルド略称"
TI.locale.settings.tooltip["TGI_SettingsAbbreviationAnnounceGuild"] =   "このギルドの略称を定義します。空欄にするとフルにギルド名を表示します"
 
-- Guild Name Color
TI.locale.settings["TGI_SettingsGuildNameColorGuild"] = "ギルド名カラー"
TI.locale.settings.tooltip["TGI_SettingsGuildNameColorGuild"] = "アナウンス内で表示されるギルド名の色を設定します"
 
-- Show roster changes
TI.locale.settings["TGI_SettingsMemberAnnounceGuild"] = "名簿変更を表示"
TI.locale.settings.tooltip["TGI_SettingsMemberAnnounceGuild"] = "ギルド名簿に変更があった場合システムメッセージを表示します（入会/脱退）"
 
-- Show online changes
TI.locale.settings["TGI_SettingsStatusAnnounceGuild"] = "オンライン変更を表示"
TI.locale.settings.tooltip["TGI_SettingsStatusAnnounceGuild"] = "ギルドメンバーのオンラインステータスの変更があった場合システムメッセージを表示します"
 
-- Show level changes
TI.locale.settings["TGI_SettingsLevelAnnounceGuild"] =  "レベル変更を表示"
TI.locale.settings.tooltip["TGI_SettingsLevelAnnounceGuild"] =  "ギルドメンバーのレベルに変更があった場合システムメッセージを表示します"

--TI.locale.settings["TGI_SettingsRaidScoreNotificationsGuild"] = "Show Raid Score Notifications (EXPERIMENTAL)"
--TI.locale.settings.tooltip["TGI_SettingsRaidScoreNotificationsGuild"] = "Show Standard Notifications about new Raid Scores in our guild"

