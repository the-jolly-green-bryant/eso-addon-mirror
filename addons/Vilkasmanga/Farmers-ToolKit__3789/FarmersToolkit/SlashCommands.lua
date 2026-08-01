
FarmersToolkit = FarmersToolkit or {}

d(FarmersToolkit.FTChat, " Startup: Loading slash commands")
zo_callLater(function()
    FarmersToolkit.dft("FT: SlashCommands.lua loaded (delayed message)")
end, 2000)


-- SLASH_COMMANDS["/ft"] = function(cmd)
SLASH_COMMANDS["/ft"] = FarmersToolkit.Help 
SLASH_COMMANDS["/ftcount"] = function() FarmersToolkit.dft("# of items you have have collected this session:" .. comma_value(FarmersToolkit.tvalue) .. " !") end
SLASH_COMMANDS["/ftgold"] = function() FarmersToolkit.dft("Gold gained this session: " .. comma_value(FarmersToolkit.TotalGoldGain) .. ", total in bags: " .. comma_value(FarmersToolkit.NewGoldCount)) end
SLASH_COMMANDS["/ftfl"] = FarmersToolkit.ListFarmedItems
SLASH_COMMANDS["/ftfl2"] = FarmersToolkit.ListFarmedItemsDebug
SLASH_COMMANDS["/ftfarmlist"] = FarmersToolkit.ListFarmedItems
SLASH_COMMANDS["/ftoff"] = function() FarmersToolkit.FlipReport ("off") end
SLASH_COMMANDS["/fton"] = function() FarmersToolkit.FlipReport ("on") end
SLASH_COMMANDS["/fttop10"] = function() FarmersToolkit.Help ("craftbag 0 10") end
SLASH_COMMANDS["/ftreset"] = FarmersToolkit.ResetLists
SLASH_COMMANDS["/ftdg"] = function() FarmersToolkit.DailyGifts ("show") end
SLASH_COMMANDS["/fthelp"] = FarmersToolkit.Help
SLASH_COMMANDS["/fthelp2"] = FarmersToolkit.Help
SLASH_COMMANDS["/ft news"] = function() FarmersToolkit.Help ("news") end
SLASH_COMMANDS["/ftdebug1"] = function() FarmersToolkit.SetDebug (1) end
SLASH_COMMANDS["/ftdebug0"] = function() FarmersToolkit.SetDebug (0) end
SLASH_COMMANDS["/ft stats"] = function() FarmersToolkit.FarmingStats("plain") end
SLASH_COMMANDS["/ft fullstats"] = function() FarmersToolkit.FarmingStats("detail") end
SLASH_COMMANDS["/petoff"] = function() FarmersToolkit.FlipPet ("off") end
SLASH_COMMANDS["/peton"] = function() FarmersToolkit.FlipPet ("on") end
SLASH_COMMANDS["/petnow"] = function() FarmersToolkit.LaunchRandomPet("now") end
SLASH_COMMANDS["/showrap2"] = function() d(GetActiveCompanionRapport() .. " / " .. GetMaximumRapport()) end
-- SLASH_COMMANDS["/sr"] = function() d(GetActiveCompanionDefId() .. " = " .. GetMaximumRapport() .. " for " .. GetCompanionName(GetActiveCompanionDefId()) ) end
SLASH_COMMANDS["/sr"] = function() d( "SR@FT: " ..   string.gsub(GetCompanionName(GetActiveCompanionDefId()),"[%p%c%s][MF]","") .. " has a rapport level of " .. GetActiveCompanionRapport() .. " / " .. GetMaximumRapport()  ) end
SLASH_COMMANDS["/showrap"] = function() d( "SR@FT: " ..   string.gsub(GetCompanionName(GetActiveCompanionDefId()),"[%p%c%s][MF]","") .. " has a rapport level of " .. GetActiveCompanionRapport() .. " / " .. GetMaximumRapport()  ) end
-- ############# End of SLASH_COMMAND block
SLASH_COMMANDS["/breda"] = function() RequestJumpToHouse(63, true) end

SLASH_COMMANDS["/ttd"] = function() JumpToFriend("@vilkasmanga") end
