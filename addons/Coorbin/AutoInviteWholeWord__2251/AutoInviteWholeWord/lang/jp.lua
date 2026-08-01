-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

-- Japanese translated by @Lionas

--Main Title
ZO_CreateStringId("SI_AUTO_INVITE", "自動招待")

--Status messages
ZO_CreateStringId("SI_AUTO_INVITE_NO_GROUP_MESSAGE", "グループが空です")
ZO_CreateStringId("SI_AUTO_INVITE_SEND_TO_USER", "<<1>>に招待を送っています")
ZO_CreateStringId("SI_AUTO_INVITE_KICK", "<<1>>をキックしています (<<2>>の理由でオフラインです)")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_OPEN_RESTART", "現在のグループを空けます。'<<1>>'を聞くように再起動されました。")
ZO_CreateStringId("SI_AUTO_INVITE_START_ON", "自動招待は'<<1>>'の文字列を検知しています")
ZO_CreateStringId("SI_AUTO_INVITE_STOP", "自動招待を止める")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_FULL_STOP", "グループが一杯です。自動招待を無効にします。")
ZO_CreateStringId("SI_AUTO_INVITE_OFF", "自動招待は無効です")

--Error messages
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ACCOUNT", "<<1>> のプレイヤー名が見つかりませんでした。手動で招待してください。")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ZONE", "プレイヤー <<1>> はシロディールにいませんが、<<2>> にいます。")
ZO_CreateStringId("SI_AUTO_INVITE_INV_BLOCK", "衝突を防止するために招待をブロックしています。")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_INVITE", "エラー - このチャンネルで招待できません:")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_KICK_TABLE", "グループスキャンで <<1>> の名前が見つかりませんでした。手動でキックしてください。")

--Menu
ZO_CreateStringId("SI_AUTO_INVITE_OPT_ENABLED", "有効化")
ZO_CreateStringId("SI_AUTO_INVITE_TT_ENABLED", "自動招待を有効にするかどうか")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_STRING", "招待文字列")
ZO_CreateStringId("SI_AUTO_INVITE_TT_STRING", "自動招待のためのメッセージをチェックする文字列")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_MAX_SIZE", "最大グループサイズ")
ZO_CreateStringId("SI_AUTO_INVITE_TT_MAX_SIZE", "グループに招待するプレイヤーの最大数")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_RESTART", "再起動")
ZO_CreateStringId("SI_AUTO_INVITE_TT_RESTART", "最大数以下になったら自動招待を再起動する")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_CYRCHECK", "シロディールチェック")
ZO_CreateStringId("SI_AUTO_INVITE_TT_CYRCHECK", "シロディールにいるプレイヤーのみ招待する\n(自身がシロディールにいる時のみ動作します)")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK", "自動キック")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK", "オフラインになったプレイヤーをキックします")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK_TIME", "キック猶予時間")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK_TIME", "オフラインになったプレイヤーをキックするまでの秒数")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_SLASHCMD", "スラッシュコマンド")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFRESH", "リストの更新")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFORM", "グループの再編")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REINVITE", "グループの再招待")

-- keybind
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REGROUP", "グループの再編")
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REINVITE", "グループの再招待")

--Slash commands
--Note: Don't translate between the color codes  |C ... |r
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_INFO", "自動招待(AutoInvite) - コマンド |CFFFF00/ai <str>|r. 使い方:")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_START", "|CFFFF00/ai foo|r - 'foo'の聞き取りを開始する")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_STOP", "|CFFFF00/ai|r - AutoInviteをオフにする")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_REGRP", "|CFFFF00/ai regrp|r - グループを再編する")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_HELP", "|CFFFF00/ai help|r - このヘルプを表示する")

--Templates for using in code (reference):
--ZO_CreateStringId("SI_AUTO_INVITE_", )
--GetString(SI_AUTO_INVITE...)
--zo_strformat(GetString(SI_AUTO_INVITE_...), param1, param2))
