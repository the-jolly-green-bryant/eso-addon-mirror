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
			name = "|cFFFACD配置|r"
		},
		{
			type = "checkbox",
			name = "UIロック",
			tooltip = "再配置の通知",
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
			name = "|cFFFACD色設定|r"
		},
		{
			type = "colorpicker",
			name = "危険なギミック",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.win1Color)),
			getFunc = function() return unpack(BR.savedVariables.win1Color) end,
			setFunc = function(r, g, b)
				SetSavedVars("win1Color", {r, g, b})
				BRHelperWin1_Label:SetColor(unpack(BR.savedVariables.win1Color))
			end,
		},
		{
			type = "colorpicker",
			name = "重要なギミック",
			default = ZO_ColorDef:New(unpack(BR.savedVariables.win2Color)),
			getFunc = function() return unpack(BR.savedVariables.win2Color) end,
			setFunc = function(r, g, b)
				SetSavedVars("win2Color", {r, g, b})
				BRHelperWin2_Label:SetColor(unpack(BR.savedVariables.win2Color))
			end,
		},
		{
			type = "colorpicker",
			name = "その他のギミック",
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
			name = "|cFFFACD通知設定|r"
		},
		{
			type = "checkbox",
			name = "ウェーブの情報",
			tooltip = "現在のウェーブについての情報を表示",
            default = settings.showWaveInfo,
			getFunc = function() return BR.savedVariables.showWaveInfo end,
			setFunc = function(value)
				BR.savedVariables.showWaveInfo = value or false
			end,
		},
		{
			type = "checkbox",
			name = "矢印の表示",
			tooltip = "メイジとーチャーが出る場所に向かって矢印を表示（2体のメイジ・アーチャーが出た場合はプレイヤーのロールに合わせてそれぞれ違う矢印が表示される）",
            default = settings.showArrow,
			getFunc = function() return BR.savedVariables.showArrow end,
			setFunc = function(value)
				BR.savedVariables.showArrow = value or false
			end,
		},
		{
			type = "colorpicker",
			name = "矢印の色",
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
			name = "矢印の大きさ",
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
			name = "|cFFFACDArena 3|r"
		},
		{
			type = "checkbox",
			name = "蝙蝠の群れ（Bat Swarm）",
			tooltip = "レディ・ミナラのAOE（タンクが対象）",
            default = settings.trackBatSwarm,
			getFunc = function() return BR.savedVariables.trackBatSwarm end,
			setFunc = function(value)
				BR.savedVariables.trackBatSwarm = value or false
			end,
		},
		{
			type = "checkbox",
			name = "蝙蝠の群れ（Bat Swarm）のカウントダウン",
			tooltip = "蝙蝠の群れ（Bat Swarm）の10秒前にカウントダウンを表示（特にアリーナ4面で、ボスのアニメーションや乱数生成によって数秒から10秒ほど前後する可能性がある）",
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
			name = "|cFFFACDArena 5|r"
		},
		{
			type = "checkbox",
			name = "虚無（Void）",
			tooltip = "バッシュ可能なAOE呪文。妨害できたかどうかの判定ができないのでバッシュしても表示は消えないまま0までカウントダウンが継続する",
            default = settings.trackVoid,
			getFunc = function() return BR.savedVariables.trackVoid end,
			setFunc = function(value)
				BR.savedVariables.trackVoid = value or false
			end,
		},
		{
			type = "checkbox",
			name = "冷気の槍（Chill Spear）",
			tooltip = "ゴーストが唱える冷気の槍は不自由デバフを付与する。ロール回避かブロックが必要。重攻撃の通知と重複してしまうのでタンクはこの設定をオフにすることを推奨",
            default = settings.trackChillSpear,
			getFunc = function() return BR.savedVariables.trackChillSpear end,
			setFunc = function(value)
				BR.savedVariables.trackChillSpear = value or false
			end,
		},
		{
			type = "checkbox",
			name = "投石（Barrage of Stone）",
			tooltip = "トーテムの攻撃。重攻撃の通知と重複してしまうのでタンクはこの設定をオフにすることを推奨",
            default = settings.trackBarrageOfStone,
			getFunc = function() return BR.savedVariables.trackBarrageOfStone end,
			setFunc = function(value)
				BR.savedVariables.trackBarrageOfStone = value or false
			end,
		},
		-- MISC
		{
			type = "header",
			name = "|cFFFACDその他|r"
		},
		{
			type = "checkbox",
			name = "チャットのメッセージ",
			tooltip = "現在のステージ・ウェーブの番号をチャット欄に表示",
            default = settings.enableChatMessages,
			getFunc = function() return BR.savedVariables.enableChatMessages end,
			setFunc = function(value)
				BR.savedVariables.enableChatMessages = value or false
			end,
		},
	}

    LibAddonMenu2:RegisterOptionControls(BR.name .. "Options", options)

end