function EchoingVigorTracker.printHelp()
    d("/evt help")
    d("/evt colors -- export colors to create the defaults")
    --d("/evt debug")
end

function EchoingVigorTracker.slashCommands(name)

    if name == nil then return EchoingVigorTracker.printHelp() end
    if name == "" then return EchoingVigorTracker.printHelp() end
    if name == "?" then return EchoingVigorTracker.printHelp() end
    if name == "help" then return EchoingVigorTracker.printHelp() end

    --if name == "debug" then return EchoingVigorTracker.printDebug() end
    if name == "colors" then return EchoingVigorTracker.printColors() end

end

function EchoingVigorTracker.printColors()

    d(string.format('["activeEchoingVigorInRangeColor"]=                {%.2f,%.2f,%.2f,%.2f,},',EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor[1],EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor[2],EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor[3],EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor[4]))
    d(string.format('["activeEchoingVigorOutsideRangeColor"]=           {%.2f,%.2f,%.2f,%.2f,},',EchoingVigorTracker.savedVars.activeEchoingVigorOutsideRangeColor[1],EchoingVigorTracker.savedVars.activeEchoingVigorOutsideRangeColor[2],EchoingVigorTracker.savedVars.activeEchoingVigorOutsideRangeColor[3],EchoingVigorTracker.savedVars.activeEchoingVigorOutsideRangeColor[4]))
    d(string.format('["inactiveEchoingVigorCanReceieveColor"]=          {%.2f,%.2f,%.2f,%.2f,},',EchoingVigorTracker.savedVars.inactiveEchoingVigorCanReceieveColor[1],EchoingVigorTracker.savedVars.inactiveEchoingVigorCanReceieveColor[2],EchoingVigorTracker.savedVars.inactiveEchoingVigorCanReceieveColor[3],EchoingVigorTracker.savedVars.inactiveEchoingVigorCanReceieveColor[4]))
    d(string.format('["inactiveEchoingVigorCannotReceieveColor"]=       {%.2f,%.2f,%.2f,%.2f,},',EchoingVigorTracker.savedVars.inactiveEchoingVigorCannotReceieveColor[1],EchoingVigorTracker.savedVars.inactiveEchoingVigorCannotReceieveColor[2],EchoingVigorTracker.savedVars.inactiveEchoingVigorCannotReceieveColor[3],EchoingVigorTracker.savedVars.inactiveEchoingVigorCannotReceieveColor[4]))
    d(string.format('["recommendCastingEchoingVigorBackgroundColor"]=   {%.2f,%.2f,%.2f,%.2f,},',EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor[1],EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor[2],EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor[3],EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor[4]))
    d(string.format('["normalBackgroundColor"]=                         {%.2f,%.2f,%.2f,%.2f,},',EchoingVigorTracker.savedVars.normalBackgroundColor[1],EchoingVigorTracker.savedVars.normalBackgroundColor[2],EchoingVigorTracker.savedVars.normalBackgroundColor[3],EchoingVigorTracker.savedVars.normalBackgroundColor[4]))

end


function EchoingVigorTracker.boolToStr(bool)
	if bool then
		return "true"
	else
		return "false"
	end

end
--[[

function EchoingVigorTracker.printDebug()
	d("EchoingVigorTracker.savedVars.enabled="..EchoingVigorTracker.boolToStr(EchoingVigorTracker.savedVars.enabled))
	d("EchoingVigorTracker.savedVars.showOnlyInCombat="..EchoingVigorTracker.boolToStr(EchoingVigorTracker.savedVars.showOnlyInCombat))
	d("EchoingVigorTracker.isEchoingVigorSkillSlotted()="..EchoingVigorTracker.boolToStr(EchoingVigorTracker.isEchoingVigorSkillSlotted()))
	d("EchoingVigorTracker.addonLoaded="..EchoingVigorTracker.boolToStr(EchoingVigorTracker.addonLoaded))
	d("EchoingVigorTracker.inCombat="..EchoingVigorTracker.boolToStr(EchoingVigorTracker.inCombat))



end

--]]