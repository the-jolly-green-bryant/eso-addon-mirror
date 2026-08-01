--[[
Author: Ayantir
Updated by Armodeniz, Lykeion
Filename: ze.lua
Version: 6.0.0
]]--

local strings = {

	SI_BINDING_NAME_SUPERSTAR_SHOW_PANEL			= "开关 SuperStar",
-- Scene Titles:
	SUPERSTAR_IMPORT_MENU_TITLE				= "角色模板导入",
	SUPERSTAR_FAVORITES_MENU_TITLE				= "角色模板收藏",
	SUPERSTAR_RESPEC_MENU_TITLE				= "角色模板重载",
	SUPERSTAR_SCRIBING_MENU_TITLE				= "篆刻模拟器",

-- Main Scene:
	SUPERSTAR_XML_SKILLPOINTS				= "技能点",
	SUPERSTAR_XML_CHAMPIONPOINTS				= "勇士点",

	SUPERSTAR_XML_BUTTON_SHARE				= "分享SuperStar (/sss)",
	SUPERSTAR_XML_BUTTON_SHARE_LINK				= "分享游戏内链接 (/ssl)",

	SUPERSTAR_XML_DMG					= "伤害",
	SUPERSTAR_XML_CRIT					= "暴击率 / %",
	SUPERSTAR_XML_PENE					= "穿透",
	SUPERSTAR_XML_RESIST					= "抗性 / %",

	SUPERSTAR_EQUIP_SET_BONUS			        = "套装",

-- Skills Scene:
	SUPERSTAR_XML_SKILL_BUILD				= "技能构建器",
	SUPERSTAR_XML_SKILL_BUILD_EXPLAIN				= "选择你的种族以开始使用技能构建器。你可以将构建保存为技能模版，以供将来再次分配使用\n\n完全支持副职业系统！你可以自由地将任何职业技能线添加到你的技能构建中，SuperStar会自动检测并在重新分配时应用所有当前可用的职业技能",

	SUPERSTAR_SCENE_SKILL_RACE_LABEL			= "种族",

	SUPERSTAR_XML_BUTTON_START				= "开始构建",

	SUPERSTAR_XML_BUTTON_FAV				= "加入收藏",
	SUPERSTAR_XML_BUTTON_FAV_WITH_CP		= "与CP一并保存",
	SUPERSTAR_XML_BUTTON_REINIT				= "重置构建器",

-- Import Scene:
	SUPERSTAR_XML_IMPORT_EXPLAIN				= "通过此页面可以导入他人的角色模板。\n\n角色模板包括勇士点、技能点以及属性点的分配方式。",

	SUPERSTAR_IMPORT_MYBUILD				= "我的当前角色哈希码",

	SUPERSTAR_IMPORT_ATTR_DISABLED				= "导入属性点",
	SUPERSTAR_IMPORT_ATTR_ENABLED				= "移除属性点",
	SUPERSTAR_IMPORT_SP_DISABLED				= "导入技能点",
	SUPERSTAR_IMPORT_SP_ENABLED				= "移除技能点",
	SUPERSTAR_IMPORT_CP_DISABLED				= "导入勇士点",
	SUPERSTAR_IMPORT_CP_ENABLED				= "移除勇士点",
	SUPERSTAR_IMPORT_BUILD_OK				= "查看此模板中的技能",
	SUPERSTAR_IMPORT_BUILD_NO_SKILLS			= "此模板中不含技能",
	SUPERSTAR_IMPORT_BUILD_NOK				= "哈希码出错，无法解读角色模板",
	SUPERSTAR_IMPORT_BUILD_LABEL				= "在此粘贴哈希码，以导入角色模板",

-- Favorite Scene:
	SUPERSTAR_XML_FAVORITES_EXPLAIN				= "你可以使用此处保存的模板进行快速自动配装。建议预先在军械库中保存一个基础构建，以便每次应用不同的模板\n\n请注意，若需要重新分配勇士点数，需为此支付金币",

	SUPERSTAR_XML_FAVORITES_HEADER_NAME			= "收藏名称",
	SUPERSTAR_XML_FAVORITES_HEADER_CP			= "勇士点",
	SUPERSTAR_XML_FAVORITES_HEADER_SP			= "技能点",
	SUPERSTAR_XML_FAVORITES_HEADER_ATTR			= "属性点",

	SUPERSTAR_VIEWFAV					= "查看技能",
	SUPERSTAR_RESPECFAV_SP					= "载入技能",
	SUPERSTAR_RESPECFAV_CP					= "载入勇士点",
	SUPERSTAR_VIEWHASH					= "查看哈希码",
	SUPERSTAR_REMFAV					= "删除此收藏",
	SUPERSTAR_UPDATEHASH					= "更新哈希码",

-- Respec Scene:
	SUPERSTAR_RESPEC_SPTITLE				= "将以 <<1>> 为模板，重新分配当前角色的|cFF0000技能点|r。",
	SUPERSTAR_RESPEC_CPTITLE				= "将以 <<1>> 为模板，重新分配当前角色的|cFF0000勇士点|r。",

	SUPERSTAR_RESPEC_SKILLLINES_MISSING			= "警告：下列技能线因为尚未解锁无法载入",
	SUPERSTAR_RESPEC_CPREQUIRED				= "使用此模板将会载入 <<1>> 勇士点",

	SUPERSTAR_XML_BUTTON_RESPEC				= "重新分配",

	SUPERSTAR_RESPEC_ERROR1					= "无法重新分配技能点：职业不合",
	SUPERSTAR_RESPEC_ERROR2					= "警告：当前技能点少于模板所需，重新分配或将不完整",
	SUPERSTAR_RESPEC_ERROR3					= "警告：模板种族与实际种族不合，载入时将忽略种族技能",
	SUPERSTAR_RESPEC_ERROR5					= "无法重新分配勇士点：你还不是勇士",
	SUPERSTAR_RESPEC_ERROR6					= "无法重新分配勇士点：勇士点不足",

	SUPERSTAR_RESPEC_INPROGRESS1				= "已分配职业技能",
	SUPERSTAR_RESPEC_INPROGRESS2				= "已分配武器技能",
	SUPERSTAR_RESPEC_INPROGRESS3				= "已分配护甲技能",
	SUPERSTAR_RESPEC_INPROGRESS4				= "已分配世界技能",
	SUPERSTAR_RESPEC_INPROGRESS5				= "已分配工会技能",
	SUPERSTAR_RESPEC_INPROGRESS6				= "已分配联盟技能",
	SUPERSTAR_RESPEC_INPROGRESS7				= "已分配种族技能",
	SUPERSTAR_RESPEC_INPROGRESS8				= "已分配交易技能",

	SUPERSTAR_CSA_RESPECDONE_TITLE				= "分配已完成",
	SUPERSTAR_CSA_RESPECDONE_POINTS				= "已配置 <<1>> 个技能",
	SUPERSTAR_CSA_RESPEC_INPROGRESS				= "正在重新分配",
	SUPERSTAR_CSA_RESPEC_TIME				= "大概需要 <<1>> <<1[分钟/分钟/分钟]>>",

-- Companion Scene:
        SUPERSTAR_XML_NO_COMPANION                              = "当前未激活同伴",
-- Dialogs:
	SUPERSTAR_SAVEFAV					= "保存收藏",
	SUPERSTAR_FAVNAME					= "收藏名称",

	SUPERSTAR_DIALOG_SPRESPEC_TITLE				= "重新分配技能",
	SUPERSTAR_DIALOG_SPRESPEC_TEXT				= "确定要使用这个模板来重新分配技能吗？",

	SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TITLE		= "技能设计器重置",
	SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TEXT		= "当前的技能设计器中存储了勇士点和属性点，如果你选择重置，这些记录也都会被清空。\n\n如果你只是想修改某些技能，在技能图标上按鼠标右键就可以清除这个技能。",

	SUPERSTAR_DIALOG_CPRESPEC_NOCOST_TEXT			= "你将要重新分配勇士点。\n\n此次分配免费。",


	SUPERSTAR_QUEUE_SCRIBING						= "加入篆刻队列",
	SUPERSTAR_CLEAR_QUEUE							= "清空队列",

	SUPERSTAR_DIALOG_QUEUE_REJECTED_TITLE			= "加入队列失败",
	SUPERSTAR_DIALOG_QUEUE_REJECTED_TEXT			= "加入队列的技能会在你下次使用篆刻祭坛时被自动制造\n队列中使用同种魔典的较旧技能会被较新技能替代\n\n部分选定的技能尚未被解锁，无法将他们加入队列",
	SUPERSTAR_DIALOG_QUEUE_FOR_SCRIBING_TEXT		= "加入队列的技能会在你下次使用篆刻祭坛时被自动制造\n队列中使用同种魔典的较旧技能会被较新技能替代\n\n选定的技能将被加入篆刻队列",
	SUPERSTAR_DIALOG_CLEAR_QUEUE_TEXT		        = "你将要清空篆刻队列\n\n在你下次使用篆刻祭坛时将不再自动制造技能",
	SUPERSTAR_DIALOG_MAJOR_UPDATE_TEXT              = "SuperStar 已更新至Update 50!\n\n插件现已支持<<1>>的展示。\nSuperstar分享链接功能也已重写。现在它更加稳定，并为即将到来的众多职业重做做好了准备",

-- Chatbox Info:
	SUPERSTAR_CHATBOX_PRINT			        		= "点此查看",
	SUPERSTAR_CHATBOX_QUEUE_INFO			        = "|c215895[Super|cCC922FStar]|r 队列中共有<<1>>个技能，预计消耗<<2>>墨水，持有<<3>>",
	SUPERSTAR_CHATBOX_QUEUE_WARN			        = "|c215895[Super|cCC922FStar]|r 队列中共有<<1>>技能，预计消耗<<2>>墨水，持有<<3>>",
	SUPERSTAR_CHATBOX_QUEUE_ABORTED		            = "|c215895[Super|cCC922FStar]|r 自动篆刻由于中断而被终止。队列已被清空",
	SUPERSTAR_CHATBOX_QUEUE_CANCELED		        = "|c215895[Super|cCC922FStar]|r 自动篆刻由于墨水不足而被取消。需要<<1>>, 持有<<2>>",
	SUPERSTAR_CHATBOX_TEMPLATE_OUTDATED		        = "|c215895[Super|cCC922FStar]|r 该模板已过时，请重新创建",
	SUPERSTAR_CHATBOX_SUPERSTAR_OUTDATED		    = "|c215895[Super|cCC922FStar]|r 无法解析的SuperStar链接。您或对方的Superstar可能不是最新版本，或者链接中的一些字符已被聊天敏感词系统屏蔽导致解析失效",


--[[
	SUPERSTAR_XML_CUSTOMIZABLE				= "自定义",
	SUPERSTAR_XML_GRANTED							= "获得",
	SUPERSTAR_XML_TOTAL									= "总",
	SUPERSTAR_XML_BUTTON_EXPORT						= "导出",
	SUPERSTAR_XML_NEWBUILD								= "新build :",
        ]]

		SUPERSTAR_DESC_ENCHANT_MAX							= " 最大",

		SUPERSTAR_DESC_ENCHANT_SEC							= " 秒",
		SUPERSTAR_DESC_ENCHANT_SEC_SHORT					= " 秒",
	
		SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG				= "魔力伤害",
		SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG_SHORT		= "法伤",
	
		SUPERSTAR_DESC_ENCHANT_BASH						= "猛击",
		SUPERSTAR_DESC_ENCHANT_BASH_SHORT				= "猛击",
	
		SUPERSTAR_DESC_ENCHANT_REDUCE						= " 并减少",
		SUPERSTAR_DESC_ENCHANT_REDUCE_SHORT				= " 和",

}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
