local LAM = LibAddonMenu2
local options = {}

function ZBNS.AddBossControl(i, vars, reRegister)
	if reRegister then
		for k = #options, 1, -1 do
			local v = options[k]
			if v and v.bossKey and v.bossKey == i then
				table.remove(options, k)
				break
			end
		end
	end

	local bossData = {}
	local bossName = 'Boss ' .. i
	if vars and vars.bossData and vars.bossData[i] then

		for key, value in pairs(vars.bossData[i]) do
			bossName = key
			bossData = value
			break
		end
	else
		bossName = 'Boss ' .. i
	end
	local barOptions = {
		{
			type = 'submenu',
			name = bossName,
			bossKey = i,
			controls = {
				{
					type = 'editbox',
					name = 'Boss Name',
					getFunc = function() return bossName end,
					setFunc = function(value)
						bossName = value
					end,
				},
				{
					type = 'slider',
					name = 'Phase 1',
					min = 0,
					max = 100,
					step = 1,
					getFunc = function() return bossData[1] or 0 end,
					setFunc = function(value)
						bossData[1] = value
					end,
				},
				{
					type = 'slider',
					name = 'Phase 2',
					min = 0,
					max = 100,
					step = 1,
					getFunc = function() return bossData[2] or 0 end,
					setFunc = function(value)
						bossData[2] = value
					end,
				},
				{
					type = 'slider',
					name = 'Phase 3',
					min = 0,
					max = 100,
					step = 1,
					getFunc = function() return bossData[3] or 0 end,
					setFunc = function(value)
						bossData[3] = value
					end,
				},
				{
					type = 'slider',
					name = 'Phase 4',
					min = 0,
					max = 100,
					step = 1,
					getFunc = function() return bossData[4] or 0 end,
					setFunc = function(value)
						bossData[4] = value
					end,
				},
				{
					type = "button",
					name = "Remove boss data",
					warning = "Phase data for "..bossName.." will be deleted",
					isDangerous = true,
    				warning = "The UI will be reloaded.",
					disabled = function() return bossName == 'Boss ' .. i end,
					func = function()
						vars.bossData[i] = nil
						ReloadUI("ingame")
					end,
				},
				{
					type = "button",
					name = "Save boss data",
					disabled = function() return bossName == 'Boss ' .. i end,
					func = function()
						vars.bossData[i] = {[bossName] = { bossData[1], bossData[2], bossData[3], bossData[4] }}
						ZBNS.BossesChanged();
					end,
				},
			},
		},
	}
	table.insert(options, barOptions[1])

	if reRegister then
		local name = ZBNS.name .. 'Menu'
		LAM:RegisterOptionControls(name, options)
	end
end


function ZBNS.BuildMenu(vars, defaults)

	local panel = {
		type = 'panel',
		name = 'Boss Next Stage',
		displayName = 'Boss Next Stage',
		author = '@AwfulDead',
		registerForRefresh = true,
	}

	options = {
		{
			type = "header",
			name = "|cFFFACDGeneral|r",
		},
		{
			type = "button",
			name = "Apply changes",
			tooltip = "After any changes, restart the interface so that all settings are successfully applied and saved",
			func = function() ReloadUI("ingame") end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Lock UI",
			disabled = function() return ZBNS.checkLUI() or ZBNS.checkAUI() end,
			getFunc = function() return vars.lockUI end,
			setFunc = function(value)
				if not value then

					ZBNSFrame:SetMovable(true)
					ZBNSFrame:SetMouseEnabled(true)
					--ZBNS.rows[1]:SetHidden(false)
					vars.lockUI = false
					else
					ZBNSFrame:SetMovable(false)
					ZBNSFrame:SetMouseEnabled(false)
					vars.lockUI = true
				end
			end
		},
		{
			type = "dropdown",
			name = "Frame mode",
			choices = {"Text", "Custom"},
			getFunc = function() return vars.mode end,
			setFunc = function(value) vars.mode = value
				if value=="Custom" then
					vars.showHP = false
					vars.showName = false
					vars.showStage = false
				end
			ReloadUI("ingame")  end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Show current hp",
			disabled = function() return vars.mode=="Custom" end,
			default = defaults.showHP,
			getFunc = function() return vars.showHP end,
			setFunc = function(value)
				vars.showHP = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Show name the boss",
			disabled = function() return vars.mode=="Custom" end,
			default = defaults.showName,
			getFunc = function() return vars.showName end,
			setFunc = function(value)
				vars.showName = value or false
			end,
		},
		{
			type = "checkbox",
			name = "Show next stage",
			disabled = function() return vars.mode=="Custom" end,
			default = defaults.showStage,
			getFunc = function() return vars.showStage end,
			setFunc = function(value)
				vars.showStage = value or false
			end,
		},
		{
			type = "slider",
			name = "Custom frame width",
			disabled = function() return vars.mode=="Text" end,
			default = defaults.BossWidth,
			getFunc = function() return vars.BossWidth end,
			min = 200, max = 360, step = 10,
			setFunc = function(value)
				vars.BossWidth = value or false
			end,
		},
		{
			type = "slider",
			name = "Custom frame height",
			disabled = function() return vars.mode=="Text" end,
			default = defaults.BossHeight,
			getFunc = function() return vars.BossHeight end,
			min = 20, max = 50, step = 2,
			setFunc = function(value)
				vars.BossHeight = value or false
			end,
		},
		{
			type = "slider",
			name = "Custom frame font size",
			disabled = function() return vars.mode=="Text" end,
			default = defaults.FontSize,
			getFunc = function() return vars.FontSize end,
			min = 8, max = 20, step = 1,
			setFunc = function(value)
				vars.FontSize = value or false
			end,
		},
	}
	ZO_CombineNumericallyIndexedTables(options, {
		{
			type = 'header',
			name = ZO_ColorDef:New('6699ff'):Colorize('Bosses data'),
		},
		{
			
			type = 'slider',
			name = 'Number of Bosses',
			min = 1,
			max = 100,
			step = 1,
			warning = 'Reload UI',
			getFunc = function() return vars.numberOfCustomBosses end,
			setFunc = function(value)
				vars.numberOfCustomBosses = value
				if vars.bossData and #vars.bossData > vars.numberOfCustomBosses then
					while #vars.bossData > vars.numberOfCustomBosses do
						vars.bossData[#vars.bossData] = nil
					end
				end
				ReloadUI("ingame")
			end,
		},
		{
            type = "description",
            title = nil,
            text = "If you have added a new boss/updated the old one's data but the changes do not appear, please reload the interface",
            width = "full"
        }
	})
	for i=1, vars.numberOfCustomBosses do
		ZBNS.AddBossControl(i, vars)
	end

	local name = ZBNS.name .. 'Menu'
	LAM:RegisterAddonPanel(name, panel)
	LAM:RegisterOptionControls(name, options)

end
