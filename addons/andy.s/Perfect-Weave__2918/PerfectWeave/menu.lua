local M = PerfectWeave
local LAM = LibAddonMenu2

function M.BuildMenu(SW, defaults)

	local panel = {
		type = 'panel',
		name = 'Perfect Weave',
		displayName = 'Perfect Weave',
		author = '|cFFFF00@andy.s|r',
		version = string.format('|c00FF00%s|r', M.version),
		website = 'https://www.esoui.com/downloads/info2918-PerfectWeave.html',
		donation = 'https://www.esoui.com/downloads/info2918-PerfectWeave.html#donate',
		registerForRefresh = true,
	}

	local options = {
		{
			type = "submenu",
			name = "|cFF8800README|r",
			controls = {
				{
					type = "description",
					text = "Global cooldown (GCD) for skills is 1000ms. By default, after using a skill you can queue another one in 400ms, and it will fire automagically when GCD is over. If you try to queue two skills, then only the last one will be fired. This is the reason of missing light attacks (LA), because LA is also a skill. Settings below can prevent you from queueing a skill while there is a queued LA. That skill won't fire off automatically, so you need to press its button multiple times until GCD allows it. If you still have no idea what it all means, then try spamming LA + some skill in mode \"Hard\" and see what happens."
				},
			},
		},
		{
			type = "dropdown",
			name = "Mode",
			tooltip = "|cFF0000Hard:|r you can't queue a skill during GCD.\n|cFFFF00Soft:|r you can queue a skill, but only if you haven't queued LA yet.\n|c00FFFFNone:|r original behaviour.",
			getFunc = function() return SW.mode end,
			setFunc = function(value)
				SW.mode = value
			end,
			choices = {
				'Hard', 'Soft', 'None'
			},
			choicesValues = {
				1, 2, 3,
			},
		},
	}
	-- Only show this checkbox to nightblades. Too bad there is no "visible" option in LibAddonMenu :(
	if GetUnitClassId('player') == 3 then
		table.insert(options, {
			type = "checkbox",
			name = "Block Grim Focus",
			tooltip = "The addon won't let you recast Grim Focus and its morphs if you are doing a light attack at 4 stacks and trying to proc Assassin's Will too soon. To make sure it always goes off, you need to press the button 2-3 times in case the first attempt was blocked. This setting has no effect is mode None.",
			getFunc = function() return SW.blockGrimFocus end,
			setFunc = function(value)
				SW.blockGrimFocus = value
			end,
		})
	end
	for _, v in pairs(
	{
		{
			type = "checkbox",
			name = "Combat only",
			tooltip = "The addon will only block skills in combat.",
			getFunc = function() return SW.combat end,
			setFunc = function(value)
				SW.combat = value
			end,
		},
		{
			type = "checkbox",
			name = "Enemy target only",
			tooltip = "The addon will only block skills when you are targeting an enemy, so you can queue them while not looking at anything attackable in any mode.",
			getFunc = function() return SW.checkTarget end,
			setFunc = function(value)
				SW.checkTarget = value
			end,
		},
		{
			type = "checkbox",
			name = "Ignore while blocking",
			tooltip = "The addon won't block skills when you are holding block.",
			getFunc = function() return SW.block end,
			setFunc = function(value)
				SW.block = value
			end,
		},
		{
			type = "checkbox",
			name = "Block ground abilities",
			tooltip = "Always prevent ground target abiltiies from double casting in any mode.",
			getFunc = function() return SW.blockGroundAbilities end,
			setFunc = function(value)
				SW.blockGroundAbilities = value
			end,
		},
		{
			type = "checkbox",
			name = "Use whitelist",
			tooltip = "Only block skills from the whitelist. You can whitelist a skill by right clicking on it on your action bar. When this setting is off, then you can blacklist skills in the same manner.\n|cFFFF00NOTE:|r whitelisting a skill doesn't affect its other morphs or special attacks! It means that to block Assassin's Will you need to proc it first, and then right click on the skill.",
			getFunc = function() return SW.useWhitelist end,
			setFunc = function(value)
				SW.useWhitelist = value
			end,
		},
		{
			type = "checkbox",
			name = "Automatic lag",
			tooltip = "Let the addon decide how much you lag depending on the current latency. Generally it's better to leave it ON, but if you have really unstable ping, then you can try setting the lag manually below.",
			getFunc = function() return SW.autoLag end,
			setFunc = function(value)
				SW.autoLag = value
			end,
		},
		{
			type = "slider",
			name = "Input lag",
			tooltip = "Set this value somewhere between 10 and (average latency / 2). It is a \"window\" when you can press a skill at the end of GCD after you've queued a light attack without missing it. It depends both on your latency (mostly) and how fast you tap the keys. If your latency doesn't jump too often, then it's better to let the addon decide on this value.",
			min = 0,
			max = 100,
			clampInput = true,
			getFunc = function() return SW.inputLag end,
			setFunc = function(value)
				SW.inputLag = value
			end,
			disabled = function() return SW.autoLag end,
		},
	}) do table.insert(options, v) end

	local name = M.name .. 'Menu'
    LAM:RegisterAddonPanel(name, panel)
    LAM:RegisterOptionControls(name, options)

end