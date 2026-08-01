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

-- Simplified Chinese translation | 简体中文翻译

--Main Title (not translated)
ZO_CreateStringId("SI_AUTO_INVITE", "AutoInvite")

--Status messages
ZO_CreateStringId("SI_AUTO_INVITE_NO_GROUP_MESSAGE", "队伍目前为空。")
ZO_CreateStringId("SI_AUTO_INVITE_SEND_TO_USER", "已向 <<1>> 发送邀请。")
ZO_CreateStringId("SI_AUTO_INVITE_KICK", "已移出 <<1>>（已离线 <<2>>）。")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_OPEN_RESTART", "队伍有空位。重新开始监听关键短语 '<<1>>'。")
ZO_CreateStringId("SI_AUTO_INVITE_START_ON", "开始监听关键短语 '<<1>>'。")
ZO_CreateStringId("SI_AUTO_INVITE_STOP", "停止监听。")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_FULL_STOP", "队伍已满。AutoInvite 已禁用。")
ZO_CreateStringId("SI_AUTO_INVITE_OFF", "AutoInvite 已关闭。")

--Error messages
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ACCOUNT", "找不到玩家 <<1>>。请手动邀请。")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ZONE", "玩家 <<1>> 不在西罗帝尔，而是在 '<<2>>'。")
ZO_CreateStringId("SI_AUTO_INVITE_INV_BLOCK", "已拦截邀请以防止游戏崩溃。")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_INVITE", "错误 - 无法在此频道发送邀请：")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_KICK_TABLE", "扫描未能找到名为 '<<1>>' 的玩家。请手动移出。")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_NOT_GROUP_LEADER", "你不是队长！")

--Menu
ZO_CreateStringId("SI_AUTO_INVITE_OPT_ENABLED", "启用")
ZO_CreateStringId("SI_AUTO_INVITE_TT_ENABLED", "用于启用或禁用 AutoInvite。")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_STRING", "监听文本")
ZO_CreateStringId("SI_AUTO_INVITE_TT_STRING", "AutoInvite 将在聊天信息中寻找的特定文本。")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_MAX_SIZE", "最大队伍人数")
ZO_CreateStringId("SI_AUTO_INVITE_TT_MAX_SIZE", "限制邀请加入队伍的最大玩家数量。")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_RESTART", "重新开始")
ZO_CreateStringId("SI_AUTO_INVITE_TT_RESTART", "当达到最大人数后又有空位时，重新启动 AutoInvite。")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_CYRCHECK", "检查西罗帝尔")
ZO_CreateStringId("SI_AUTO_INVITE_TT_CYRCHECK", "仅邀请位于西罗帝尔的玩家。（仅在你本人也位于西罗帝尔时生效）。")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK", "自动移出离线者")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK", "自动将离线的玩家移出队伍。")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK_TIME", "移出前等待时间")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK_TIME", "玩家离线后，将其移出队伍前等待的秒数。")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_SLASHCMD", "斜杠命令操作")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFRESH", "刷新列表")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFORM", "重组队伍")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REINVITE", "重新邀请全队")

ZO_CreateStringId("SI_AUTO_INVITE_OPT_ENROLMENT", "预设的招募信息")
ZO_CreateStringId("SI_AUTO_INVITE_TT_ENROLMENT", "点击上方按钮时，此处的文本将自动填充到聊天栏，以便你发布招募信息。使用以下标签，AutoInvite 会将其替换为：\n++cn 当前的联盟战役名称\n++gs 当前队伍人数\n++rs 队伍剩余空位\n++ro 缺少的职责角色（在下方配置）")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_NEEDED", "招募信息所需的队伍职责角色（包括你自己的角色）")

ZO_CreateStringId("SI_AUTO_INVITE_OTHER_SETTINGS", "核心设置")
ZO_CreateStringId("SI_AUTO_INVITE_CHATS_LISTEN", "监听的聊天频道")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_SETTINGS", "队伍设置")

-- keybind
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REGROUP", "重组队伍")
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REINVITE", "重新邀请全队")

--Slash commands
--Note: Don't translate between the color codes  |C ... |r
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_INFO", "AutoInvite - 命令格式：|CFFFF00/ai <str>|r。示例：")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_START", "|CFFFF00/ai foo|r - 开始监听关键短语 'foo'。")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_STOP", "|CFFFF00/ai|r - 关闭 AutoInvite。")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_REGRP", "|CFFFF00/ai regrp|r - 解散并重新组建队伍。")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_HELP", "|CFFFF00/ai help|r - 显示此帮助菜单。")

--Templates for using in code (reference):
--ZO_CreateStringId("SI_AUTO_INVITE_", )
--GetString(SI_AUTO_INVITE...)
--zo_strformat(GetString(SI_AUTO_INVITE_...), param1, param2))