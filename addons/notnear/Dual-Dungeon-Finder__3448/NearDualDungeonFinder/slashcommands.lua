local LSC = NEAR_DDF.LSC
local addon = NEAR_DDF
local color = NEAR_DDF.utils.color

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

function NEAR_DDF.activateSlashCommands()
    -- dDebug
    LSC:Register('/ddf/ddebug', function () addon.sc_toggleDevDebugMode() end, 'Toggle Debug mode')
	-- toggleAF
    LSC:Register({'/ddf', '/dual_dungeon_finder'}, function () addon.sc_toggleAF() end, 'Toggle the gamepad version of the Activity Finder interface')
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Slash command functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

function NEAR_DDF.sc_toggleDevDebugMode()
    if (addon.ASV.dDebug) then
	    d(color.white .. 'DDF: |r' .. 'Toggle Debug mode Off')
		addon.ASV.dDebug = false
	else
		d(color.white .. 'DDF: |r' .. 'Toggle Debug mode On')
		addon.ASV.dDebug = true
	end
end

function NEAR_DDF.sc_toggleAF()
	--[[ Debug ]] if (addon.ASV.dDebug) then d(color.white .. 'DDF: |r' .. 'toggleAF') end

    local sceneName = "gamepad_activity_finder_root"

    if not IsInGamepadPreferredMode() then NEAR_DDF.cycleGPM() SCENE_MANAGER:Show(sceneName)
		d(color.white .. 'DDF: |r' .. 'Use the slash command again to close and go back to keyboard UI')
    else NEAR_DDF.cycleGPM() end
end

-- Without LibSlashCommands
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- function addon:SlashCommand()
-- 	SLASH_COMMANDS["/gp/ddebug"] = function ()
-- 		if (addon.ASV.dDebug) then
-- 			if (addon.ASV.uDebug) then d('Toggle dev debug Off') end
-- 			addon.ASV.dDebug = false --[[ Debug d(addon.ASV.dDebug) ]]
-- 		else
-- 			if (addon.ASV.uDebug) then d('Toggle dev debug On') end
-- 			addon.ASV.dDebug = true --[[ Debug d(NEAR_DDF.ASV.dDebug) ]]
-- 		end
-- 	end
