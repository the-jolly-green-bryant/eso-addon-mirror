local BR = BRHelper

function BR.BuildMenu(savedVars)

	local settings = savedVars

	local function SetSavedVars(control, value)
		settings[control] = value
		BR.savedVariables[control] = value
	end

    local panelInfo = {
        type = 'panel',
        name = 'Blackrose Prison Helper',
        displayName = 'Blackrose Prison Helper',
        author = "|cFFFF00@andy.s|r",
        version = "|c00FF00" .. BR.version .. "|r",
        registerForRefresh = true
    }

    LibAddonMenu2:RegisterAddonPanel(BR.name .. "Options", panelInfo)

    local options = {
		--[[
		{
			type = "description",
			text = "There are more notifications provided by the addon than you can configure here. I just didn't want to add a separate switch for every single mechanic. Most of the notifications will save your life, so you don't really want to disable them. Enjoy and good luck! ;)",
		},
		]]
		-- POSITION
		{
			type = "header",
			name = "|cFFFACD提示定位|r"
		},
		{
			type = "checkbox",
			name = "锁定UI",
			tooltip = "设置提示位置.",
			getFunc = function() return BR.uiLocked end,
			setFunc = function(value)
				if not value then
					BR.UnlockUI()
				else
					BR.LockUI()
				end
			end
		},
		-- COLORS
		{
			type = "header",
			name = "|cFFFACD提示颜色|r"
		},
		{
			type = "colorpicker",
			name = "危险机制",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.win1Color)),
			getFunc = function() return unpack(BR.savedVariables.win1Color) end,
			setFunc = function(r, g, b)
				SetSavedVars("win1Color", {r, g, b})
				BRHelperWin1_Label:SetColor(unpack(BR.savedVariables.win1Color))
			end,
		},
		{
			type = "colorpicker",
			name = "重要机制",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.win2Color)),
			getFunc = function() return unpack(BR.savedVariables.win2Color) end,
			setFunc = function(r, g, b)
				SetSavedVars("win2Color", {r, g, b})
				BRHelperWin2_Label:SetColor(unpack(BR.savedVariables.win2Color))
			end,
		},
		{
			type = "colorpicker",
			name = "一般机制",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.win3Color)),
			getFunc = function() return unpack(BR.savedVariables.win3Color) end,
			setFunc = function(r, g, b)
				SetSavedVars("win3Color", {r, g, b})
				BRHelperWin3_Label:SetColor(unpack(BR.savedVariables.win3Color))
			end,
		},
		-- GENERAL SETTINGS
		{
			type = "header",
			name = "|cFFFACD一般提示|r"
		},
		{
			type = "checkbox",
			name = "波数信息",
			tooltip = "展示当前怪物刷新波数信息.",
            default = settings.showWaveInfo,
			getFunc = function() return BR.savedVariables.showWaveInfo end,
			setFunc = function(value)
				BR.savedVariables.showWaveInfo = value or false
			end,
		},
		{
			type = "checkbox",
			name = "显示箭头",
			tooltip = "显示一个指向法师/弓手刷新位置的箭头. 如果同时刷新了两个法师/弓手则箭头指向会根据你的角色定位而不同.",
            default = settings.showArrow,
			getFunc = function() return BR.savedVariables.showArrow end,
			setFunc = function(value)
				BR.savedVariables.showArrow = value or false
			end,
		},
		{
			type = "colorpicker",
			name = "箭头颜色",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.arrowColor)),
			getFunc = function() return unpack(BR.savedVariables.arrowColor) end,
			setFunc = function(r, g, b)
				SetSavedVars("arrowColor", {r, g, b})
				BR.UpdateArrowStyle()
			end,
			width = "full",
			disabled = function() return not BR.savedVariables.showArrow end,
		},
		{
			type = "slider",
			name = "箭头比例",
			min = 1,
			max = 2,
			step = 0.1,
			decimals = 1,
			clampInput = true,
			default = settings.arrowScale,
			getFunc = function() return BR.savedVariables.arrowScale end,
			setFunc = function(value)
				SetSavedVars("arrowScale", value)
				BR.UpdateArrowStyle()
			end,
			width = "full",
			disabled = function() return not BR.savedVariables.showArrow end,
		},
		-- ARENA 3
		{
			type = "header",
			name = "|cFFFACD第3层|r"
		},
		{
			type = "checkbox",
			name = "蝠群涌现",
			tooltip = "米纳拉夫人对坦克使用的AOE.",
            default = settings.trackBatSwarm,
			getFunc = function() return BR.savedVariables.trackBatSwarm end,
			setFunc = function(value)
				BR.savedVariables.trackBatSwarm = value or false
			end,
		},
		{
			type = "checkbox",
			name = "蝠群倒计时",
			tooltip = "在蝠群涌现前10秒倒计时. 注意该机制很可能会因为Boss的动作队列变化而提前或推迟, 尤其是在第四层时.",
            default = settings.enableBatSwarmCountdown,
			getFunc = function() return BR.savedVariables.enableBatSwarmCountdown end,
			setFunc = function(value)
				BR.savedVariables.enableBatSwarmCountdown = value or false
			end,
			disabled = function() return not BR.savedVariables.trackBatSwarm end,
		},
		-- ARENA 5
		{
			type = "header",
			name = "|cFFFACD第5层|r"
		},
		{
			type = "checkbox",
			name = "虚无",
			tooltip = "提示打断AOE. 很遗憾本插件无法监控AOE是否已经被打断, 所以它会保持倒计时直到时间结束.",
            default = settings.trackVoid,
			getFunc = function() return BR.savedVariables.trackVoid end,
			setFunc = function(value)
				BR.savedVariables.trackVoid = value or false
			end,
		},
		{
			type = "checkbox",
			name = "冰冷尖矛",
			tooltip = "提示幽灵释放的冰矛, 你需要闪避或格挡它. 推荐坦克关闭该提示, 因为该提示会覆盖重击提示",
            default = settings.trackChillSpear,
			getFunc = function() return BR.savedVariables.trackChillSpear end,
			setFunc = function(value)
				BR.savedVariables.trackChillSpear = value or false
			end,
		},
		{
			type = "checkbox",
			name = "巨石炮轰",
			tooltip = "提示图腾的攻击. 推荐坦克关闭该提示, 因为该提示会覆盖重击提示",
            default = settings.trackBarrageOfStone,
			getFunc = function() return BR.savedVariables.trackBarrageOfStone end,
			setFunc = function(value)
				BR.savedVariables.trackBarrageOfStone = value or false
			end,
		},
		-- MISC
		{
			type = "header",
			name = "|cFFFACD杂项|r"
		},
		{
			type = "checkbox",
			name = "聊天栏信息",
			tooltip = "在聊天栏打印当前怪物刷新波数信息.",
            default = settings.enableChatMessages,
			getFunc = function() return BR.savedVariables.enableChatMessages end,
			setFunc = function(value)
				BR.savedVariables.enableChatMessages = value or false
			end,
		},
	}

    LibAddonMenu2:RegisterOptionControls(BR.name .. "Options", options)

end